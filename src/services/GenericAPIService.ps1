# GenericAPIService.ps1
# Universal API service for any REST endpoint
# Demonstrates the universal orchestration capabilities of the framework

class GenericAPIService {
    hidden [object] $logger
    hidden [object] $authService  
    hidden [object] $configService
    hidden [object] $authRecoveryService
    hidden [hashtable] $headers
    hidden [string] $baseUrl

    # Constructor with dependency injection
    GenericAPIService([object] $loggingService, [object] $authService, [object] $configService) {
        $this.logger = $loggingService
        $this.authService = $authService
        $this.configService = $configService
        $this.headers = @{}
        
        # Initialize authentication failure recovery service
        try {
            . "$PSScriptRoot\AuthenticationFailureRecoveryService.ps1"
            $credentialService = $authService.credentialService
            $this.authRecoveryService = [AuthenticationFailureRecoveryService]::new($loggingService, $credentialService, $configService)
        }
        catch {
            $this.logger.LogWarning("Failed to initialize AuthenticationFailureRecoveryService: $($_.Exception.Message)", "API")
            $this.authRecoveryService = $null
        }
        
        $this.logger.LogInfo("GenericAPIService initialized with authentication recovery", "API")
        $this.InitializeService()
    }

    # Initialize service with configuration
    hidden [void] InitializeService() {
        try {
            # Get configuration from the injected configuration service
            $config = $this.configService.LoadConfiguration("api-config")
            
            if ($config -and $config.BaseUrl) {
                $this.baseUrl = $config.BaseUrl
                $this.logger.LogInfo("Loaded API configuration: $($this.baseUrl)", "API")
                
                # Configure authentication if provided
                if ($config.Authentication) {
                    $this.AddAuthentication($config.Authentication)
                }
            }
            else {
                throw "API configuration 'api-config' not found or invalid. BaseUrl is required."
            }
            
            # Set default headers
            $this.headers = @{
                'Content-Type' = 'application/json'
                'User-Agent' = 'PowerShell-Universal-Orchestrator/1.0'
            }

            # Apply additional configuration if provided
            if ($config.Headers) {
                foreach ($header in $config.Headers.PSObject.Properties) {
                    $this.headers[$header.Name] = $header.Value
                }
            }

            $this.logger.LogInfo("GenericAPIService configured for: $($this.baseUrl)", "API")
        }
        catch {
            $this.logger.LogError("Failed to initialize GenericAPIService: $($_.Exception.Message)", "API")
            throw $_
        }
    }

    # Add authentication to headers
    hidden [void] AddAuthentication([object] $authConfig) {
        switch ($authConfig.Type) {
            'ApiKey' {
                $this.headers[$authConfig.HeaderName] = $authConfig.ApiKey
                $this.logger.LogInfo("API Key authentication configured", "API")
            }
            'Bearer' {
                $this.headers['Authorization'] = "Bearer $($authConfig.Token)"
                $this.logger.LogInfo("Bearer token authentication configured", "API") 
            }
            'Basic' {
                $credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($authConfig.Username):$($authConfig.Password)"))
                $this.headers['Authorization'] = "Basic $credentials"
                $this.logger.LogInfo("Basic authentication configured", "API")
            }
            default {
                $this.logger.LogInfo("No authentication configured", "API")
            }
        }
    }

    # Generic GET request with authentication recovery
    [object] Get([string] $endpoint) {
        return $this.Get($endpoint, $null)
    }

    [object] Get([string] $endpoint, [hashtable] $queryParams) {
        return $this.ExecuteRequestWithAuthRecovery("GET", $endpoint, $null, $queryParams)
    }

    # Generic POST request with authentication recovery
    [object] Post([string] $endpoint, [object] $body) {
        return $this.ExecuteRequestWithAuthRecovery("POST", $endpoint, $body, $null)
    }

    # Generic PUT request with authentication recovery
    [object] Put([string] $endpoint, [object] $body) {
        return $this.ExecuteRequestWithAuthRecovery("PUT", $endpoint, $body, $null)
    }

    # Generic DELETE request with authentication recovery
    [object] Delete([string] $endpoint) {
        return $this.ExecuteRequestWithAuthRecovery("DELETE", $endpoint, $null, $null)
    }

    # Execute HTTP request with authentication failure recovery
    hidden [object] ExecuteRequestWithAuthRecovery([string] $method, [string] $endpoint, [object] $body, [hashtable] $queryParams) {
        $url = $this.BuildUrl($endpoint, $queryParams)
        $currentHeaders = $this.headers.Clone()
        
        # Try to load saved authentication details first
        if ($this.authRecoveryService) {
            $savedAuth = $this.authRecoveryService.LoadSavedAuthDetails($this.baseUrl)
            if ($savedAuth -and $savedAuth.Success) {
                $this.logger.LogInfo("Using saved authentication details for $($this.baseUrl)", "API")
                foreach ($header in $savedAuth.Headers.GetEnumerator()) {
                    $currentHeaders[$header.Key] = $header.Value
                }
            }
        }
        
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                $this.logger.LogInfo("$method request to: $url (Attempt: $attempt)", "API")
                
                $restParams = @{
                    Uri = $url
                    Method = $method
                    Headers = $currentHeaders
                    ErrorAction = 'Stop'
                }
                
                if ($body -and ($method -eq "POST" -or $method -eq "PUT")) {
                    $jsonBody = $body | ConvertTo-Json -Depth 10
                    $restParams.Body = $jsonBody
                }
                
                $response = Invoke-RestMethod @restParams
                
                # Reset retry attempts on success
                if ($this.authRecoveryService) {
                    $this.authRecoveryService.ResetRetryAttempts($this.baseUrl)
                }
                
                $this.logger.LogInfo("$method request successful", "API")
                return $response
            }
            catch {
                $this.logger.LogWarning("$method request failed (Attempt: $attempt): $($_.Exception.Message)", "API")
                
                # Only attempt recovery if we have the recovery service and it's not the final attempt
                if ($this.authRecoveryService -and $attempt -lt 3) {
                    $recoveryResult = $this.authRecoveryService.HandleAuthenticationFailure($this.baseUrl, $_, $endpoint)
                    
                    if ($recoveryResult.Success -and $recoveryResult.RequiresAuth) {
                        $this.logger.LogInfo("Authentication failure recovery successful, retrying request", "API")
                        
                        # Update headers with new authentication
                        foreach ($header in $recoveryResult.Headers.GetEnumerator()) {
                            $currentHeaders[$header.Key] = $header.Value
                        }
                        
                        # Continue to next attempt with new auth headers
                        continue
                    }
                    elseif ($recoveryResult.RequiresAuth -and $recoveryResult.Message -match "Maximum.*attempts") {
                        $this.logger.LogError("Authentication recovery failed: Account lockout protection activated", "API")
                        throw "Authentication failed: Maximum retry attempts exceeded to prevent account lockout"
                    }
                }
                
                # If this is the final attempt or recovery failed, throw the original exception
                if ($attempt -eq 3) {
                    $this.logger.LogError("$method request failed after all attempts", "API")
                    throw $_
                }
            }
        }
        
        # This should never be reached, but provide fallback
        throw "Request failed after maximum attempts"
    }

    # Build complete URL with query parameters
    hidden [string] BuildUrl([string] $endpoint, [hashtable] $queryParams) {
        $url = "$($this.baseUrl.TrimEnd('/'))/$($endpoint.TrimStart('/'))"
        
        if ($queryParams -and $queryParams.Count -gt 0) {
            $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            $url += "?$queryString"
        }
        
        return $url
    }

    # Health check method
    [bool] TestConnection() {
        try {
            $this.logger.LogInfo("Testing connection to API", "API")
            
            # Try a simple GET request to test connectivity
            $testResponse = $this.Get("")
            
            $this.logger.LogInfo("Connection test successful", "API")
            return $true
        }
        catch {
            $this.logger.LogError("Connection test failed: $($_.Exception.Message)", "API")
            return $false
        }
    }

    # Get service information
    [object] GetServiceInfo() {
        $info = @{
            BaseUrl = $this.baseUrl
            Headers = $this.headers.Clone()
            ServiceType = "GenericAPIService"
            Version = "1.1.0"
            AuthenticationRecovery = "Enabled"
        }
        
        if ($this.authRecoveryService) {
            $info.AuthRecoveryInfo = $this.authRecoveryService.GetServiceInfo()
        }
        else {
            $info.AuthenticationRecovery = "Disabled"
        }
        
        return $info
    }

    # Manual authentication recovery method for testing
    [object] TestAuthenticationRecovery([string] $endpoint = "") {
        if (-not $this.authRecoveryService) {
            return @{
                Success = $false
                Message = "Authentication recovery service not available"
            }
        }
        
        try {
            # Create a mock 401 response to test the recovery system
            $mockResponse = @{
                Exception = @{
                    Response = @{
                        StatusCode = 401
                    }
                }
                ErrorDetails = @{
                    Message = "Unauthorized access - authentication required"
                }
            }
            
            $result = $this.authRecoveryService.HandleAuthenticationFailure($this.baseUrl, $mockResponse, $endpoint)
            return $result
        }
        catch {
            return @{
                Success = $false
                Error = $_.Exception.Message
                Message = "Authentication recovery test failed"
            }
        }
    }
}