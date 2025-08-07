# AuthenticationFailureRecoveryService.ps1
# Comprehensive authentication failure recovery system for API Orchestrator
# Handles detection, interactive prompts, auto-detection, secure storage, and retry logic

class AuthenticationFailureRecoveryService {
    hidden [object] $logger
    hidden [object] $credentialService
    hidden [object] $configService
    hidden [hashtable] $retryAttempts
    hidden [int] $maxRetries = 2
    hidden [object] $authTypeCache

    # Constructor with dependency injection
    AuthenticationFailureRecoveryService([object] $loggingService, [object] $credentialService, [object] $configService) {
        $this.logger = $loggingService
        $this.credentialService = $credentialService
        $this.configService = $configService
        $this.retryAttempts = @{}
        $this.authTypeCache = @{}
        
        $this.logger.LogInfo("AuthenticationFailureRecoveryService initialized", "AuthRecovery")
    }

    # Main authentication failure detection and recovery method
    [object] HandleAuthenticationFailure([string] $baseUrl, [object] $response, [string] $endpoint = "") {
        try {
            $this.logger.LogInfo("Handling authentication failure for: $baseUrl", "AuthRecovery")
            
            # Step 1: Detect authentication failure
            $authFailure = $this.DetectAuthenticationFailure($response)
            if (-not $authFailure.IsAuthFailure) {
                $this.logger.LogDebug("No authentication failure detected", "AuthRecovery")
                return @{
                    Success = $false
                    RequiresAuth = $false
                    Message = "No authentication failure detected"
                }
            }

            $this.logger.LogWarning("Authentication failure detected: $($authFailure.FailureReason)", "AuthRecovery")
            
            # Step 2: Check retry limits to prevent account lockouts
            $retryKey = $this.GetRetryKey($baseUrl)
            if ($this.HasExceededRetryLimit($retryKey)) {
                $this.logger.LogError("Maximum retry attempts ($($this.maxRetries)) exceeded for $baseUrl", "AuthRecovery")
                return @{
                    Success = $false
                    RequiresAuth = $true
                    Message = "Maximum authentication attempts exceeded. Account lockout protection activated."
                    RetryCount = $this.retryAttempts[$retryKey]
                }
            }

            # Step 3: Auto-detect authentication type from response
            $detectedAuthType = $this.DetectAuthenticationTypeFromResponse($response, $baseUrl, $endpoint)
            $this.logger.LogInfo("Detected authentication type: $($detectedAuthType.AuthType)", "AuthRecovery")

            # Step 4: Prompt for authentication details interactively
            $authDetails = $this.PromptForAuthentication($baseUrl, $detectedAuthType)
            if (-not $authDetails.Success) {
                return @{
                    Success = $false
                    RequiresAuth = $true
                    Message = "Authentication details collection failed"
                }
            }

            # Step 5: Store credentials securely if requested
            if ($authDetails.SaveCredentials) {
                $this.SaveAuthenticationDetails($baseUrl, $authDetails)
            }

            # Step 6: Increment retry counter
            $this.IncrementRetryAttempt($retryKey)

            return @{
                Success = $true
                RequiresAuth = $true
                AuthDetails = $authDetails
                AuthType = $detectedAuthType.AuthType
                Headers = $this.BuildAuthHeaders($authDetails, $detectedAuthType.AuthType)
                Message = "Authentication details collected successfully"
                RetryCount = $this.retryAttempts[$retryKey]
            }
        }
        catch {
            $this.logger.LogError("Failed to handle authentication failure: $($_.Exception.Message)", "AuthRecovery")
            return @{
                Success = $false
                RequiresAuth = $false
                Error = $_.Exception.Message
                Message = "Authentication failure handler error"
            }
        }
    }

    # Detect authentication failure from HTTP responses
    hidden [object] DetectAuthenticationFailure([object] $response) {
        try {
            # Check for common authentication failure indicators
            $isAuthFailure = $false
            $failureReason = ""
            $statusCode = 0
            
            if ($response -is [System.Net.WebException]) {
                $httpResponse = $response.Response
                if ($httpResponse) {
                    $statusCode = [int]$httpResponse.StatusCode
                    if ($statusCode -eq 401) {
                        $isAuthFailure = $true
                        $failureReason = "401 Unauthorized - Invalid or missing credentials"
                    }
                    elseif ($statusCode -eq 403) {
                        $isAuthFailure = $true
                        $failureReason = "403 Forbidden - Insufficient permissions or invalid authentication method"
                    }
                }
            }
            elseif ($response.Exception -and $response.Exception.Response) {
                $statusCode = [int]$response.Exception.Response.StatusCode
                if ($statusCode -eq 401 -or $statusCode -eq 403) {
                    $isAuthFailure = $true
                    $failureReason = "$statusCode authentication failure"
                }
            }
            elseif ($response.StatusCode) {
                $statusCode = [int]$response.StatusCode
                if ($statusCode -eq 401 -or $statusCode -eq 403) {
                    $isAuthFailure = $true
                    $failureReason = "$statusCode authentication failure"
                }
            }

            # Check for authentication-related error messages in response content
            if (-not $isAuthFailure -and $response.ErrorDetails) {
                $errorContent = $response.ErrorDetails.Message
                $authKeywords = @("authentication", "unauthorized", "forbidden", "invalid credentials", "access denied", "token", "api key")
                foreach ($keyword in $authKeywords) {
                    if ($errorContent -match $keyword) {
                        $isAuthFailure = $true
                        $failureReason = "Authentication error detected in response: $keyword"
                        break
                    }
                }
            }

            return @{
                IsAuthFailure = $isAuthFailure
                StatusCode = $statusCode
                FailureReason = $failureReason
            }
        }
        catch {
            $this.logger.LogError("Error detecting authentication failure: $($_.Exception.Message)", "AuthRecovery")
            return @{
                IsAuthFailure = $false
                StatusCode = 0
                FailureReason = "Detection error"
            }
        }
    }

    # Auto-detect authentication type from API response headers and content
    hidden [object] DetectAuthenticationTypeFromResponse([object] $response, [string] $baseUrl, [string] $endpoint) {
        try {
            # Check cache first
            $cacheKey = $baseUrl.ToLower()
            if ($this.authTypeCache.ContainsKey($cacheKey)) {
                $this.logger.LogDebug("Using cached authentication type for $baseUrl", "AuthRecovery")
                return $this.authTypeCache[$cacheKey]
            }

            $detectedType = "Basic"  # Default fallback
            $authHints = @()
            $confidence = "Low"

            # Analyze WWW-Authenticate header
            if ($response.Headers -and $response.Headers["WWW-Authenticate"]) {
                $wwwAuth = $response.Headers["WWW-Authenticate"]
                if ($wwwAuth -match "Bearer") {
                    $detectedType = "Bearer"
                    $authHints += "Bearer token required (WWW-Authenticate header)"
                    $confidence = "High"
                }
                elseif ($wwwAuth -match "Basic") {
                    $detectedType = "Basic"
                    $authHints += "Basic authentication required (WWW-Authenticate header)"
                    $confidence = "High"
                }
                elseif ($wwwAuth -match "Digest") {
                    $detectedType = "Digest"
                    $authHints += "Digest authentication detected"
                    $confidence = "Medium"
                }
            }

            # Analyze response content for authentication hints
            if ($response.ErrorDetails -or $response.Content) {
                $content = if ($response.ErrorDetails) { $response.ErrorDetails.Message } else { $response.Content }
                
                if ($content -match "api.?key|x-api-key") {
                    $detectedType = "ApiKey"
                    $authHints += "API Key authentication suggested (content analysis)"
                    $confidence = "Medium"
                }
                elseif ($content -match "bearer.?token|jwt") {
                    $detectedType = "Bearer"
                    $authHints += "Bearer token authentication suggested (content analysis)"
                    $confidence = "Medium"
                }
                elseif ($content -match "basic.?auth") {
                    $detectedType = "Basic"
                    $authHints += "Basic authentication suggested (content analysis)"
                    $confidence = "Medium"
                }
            }

            # Analyze URL patterns for common API types
            if ($baseUrl -match "github\.com|gitlab\.com") {
                $detectedType = "Bearer"
                $authHints += "GitHub/GitLab API detected - typically uses Bearer tokens"
                $confidence = "High"
            }
            elseif ($baseUrl -match "amazonaws\.com") {
                $detectedType = "Custom"
                $authHints += "AWS API detected - typically uses custom signature authentication"
                $confidence = "Medium"
            }
            elseif ($baseUrl -match "google.*api|googleapis\.com") {
                $detectedType = "Bearer"
                $authHints += "Google API detected - typically uses Bearer tokens"
                $confidence = "High"
            }

            # Check for common API key header requirements
            $commonApiKeyHeaders = @("X-API-Key", "X-API-TOKEN", "Authorization", "X-Auth-Token")
            $suggestedHeaders = @()
            foreach ($header in $commonApiKeyHeaders) {
                # Get content for header matching analysis
                $contentToAnalyze = if ($response.ErrorDetails) { $response.ErrorDetails.Message } else { if ($response.Content) { $response.Content } else { "" } }
                if ($contentToAnalyze -match $header) {
                    $detectedType = "ApiKey"
                    $suggestedHeaders += $header
                    $authHints += "Detected required header: $header"
                    $confidence = "High"
                }
            }

            $result = @{
                AuthType = $detectedType
                Confidence = $confidence
                AuthHints = $authHints
                SuggestedHeaders = $suggestedHeaders
                DetectionMethod = "ResponseAnalysis"
            }

            # Cache the result
            $this.authTypeCache[$cacheKey] = $result

            return $result
        }
        catch {
            $this.logger.LogError("Error detecting authentication type: $($_.Exception.Message)", "AuthRecovery")
            return @{
                AuthType = "Basic"
                Confidence = "Low"
                AuthHints = @("Detection failed - defaulting to Basic")
                SuggestedHeaders = @()
                DetectionMethod = "Fallback"
            }
        }
    }

    # Interactive authentication prompt system
    hidden [object] PromptForAuthentication([string] $baseUrl, [object] $detectedAuthType) {
        try {
            $this.logger.LogInfo("Prompting for authentication details for: $baseUrl", "AuthRecovery")
            
            Write-Host ""
            Write-Host "=== AUTHENTICATION REQUIRED ===" -ForegroundColor Yellow
            Write-Host "API Endpoint: $baseUrl" -ForegroundColor White
            Write-Host "Detected Type: $($detectedAuthType.AuthType) (Confidence: $($detectedAuthType.Confidence))" -ForegroundColor White
            
            if ($detectedAuthType.AuthHints.Count -gt 0) {
                Write-Host ""
                Write-Host "Authentication Hints:" -ForegroundColor Cyan
                foreach ($hint in $detectedAuthType.AuthHints) {
                    Write-Host "  - $hint" -ForegroundColor Gray
                }
            }

            Write-Host ""
            Write-Host "Please select authentication method:" -ForegroundColor Cyan
            Write-Host "1. API Key" -ForegroundColor White
            Write-Host "2. Bearer Token" -ForegroundColor White
            Write-Host "3. Basic Authentication (Username/Password)" -ForegroundColor White
            Write-Host "4. Custom Headers" -ForegroundColor White
            
            $choice = Read-Host "Enter choice (1-4) [default based on detection]"
            if ([string]::IsNullOrWhiteSpace($choice)) {
                $choice = switch ($detectedAuthType.AuthType) {
                    "ApiKey" { "1" }
                    "Bearer" { "2" }
                    "Basic" { "3" }
                    "Custom" { "4" }
                    default { "3" }
                }
                Write-Host "Using detected type: $($detectedAuthType.AuthType)" -ForegroundColor Green
            }

            $authDetails = @{}
            $authType = ""

            switch ($choice) {
                "1" {
                    $authType = "ApiKey"
                    $apiKey = Read-Host "Enter API Key" -AsSecureString
                    $headerName = "X-API-Key"
                    if ($detectedAuthType.SuggestedHeaders.Count -gt 0) {
                        $headerName = $detectedAuthType.SuggestedHeaders[0]
                        Write-Host "Using suggested header: $headerName" -ForegroundColor Green
                    }
                    else {
                        $customHeader = Read-Host "Enter header name for API key [$headerName]"
                        if (-not [string]::IsNullOrWhiteSpace($customHeader)) {
                            $headerName = $customHeader
                        }
                    }
                    $authDetails = @{
                        Type = "ApiKey"
                        ApiKey = $apiKey
                        HeaderName = $headerName
                    }
                }
                "2" {
                    $authType = "Bearer"
                    $token = Read-Host "Enter Bearer Token" -AsSecureString
                    $authDetails = @{
                        Type = "Bearer"
                        Token = $token
                    }
                }
                "3" {
                    $authType = "Basic"
                    $username = Read-Host "Enter Username"
                    $password = Read-Host "Enter Password" -AsSecureString
                    $authDetails = @{
                        Type = "Basic"
                        Username = $username
                        Password = $password
                    }
                }
                "4" {
                    $authType = "Custom"
                    $headers = @{}
                    Write-Host "Enter custom headers (press Enter with empty header name to finish):" -ForegroundColor Cyan
                    $headerName = $null
                    do {
                        $headerName = Read-Host "Header name"
                        if (-not [string]::IsNullOrWhiteSpace($headerName)) {
                            $headerValue = Read-Host "Header value"
                            $headers[$headerName] = $headerValue
                        }
                    } while (-not [string]::IsNullOrWhiteSpace($headerName))
                    
                    $authDetails = @{
                        Type = "Custom"
                        Headers = $headers
                    }
                }
                default {
                    throw "Invalid authentication method selection"
                }
            }

            # Ask if credentials should be saved
            $saveCredentials = $false
            $saveChoice = Read-Host "Save credentials securely for future use? (y/N)"
            if ($saveChoice -match '^(y|yes)$') {
                $saveCredentials = $true
            }

            return @{
                Success = $true
                AuthType = $authType
                AuthDetails = $authDetails
                SaveCredentials = $saveCredentials
            }
        }
        catch {
            $this.logger.LogError("Error during authentication prompt: $($_.Exception.Message)", "AuthRecovery")
            return @{
                Success = $false
                Error = $_.Exception.Message
            }
        }
    }

    # Save authentication details to encrypted storage
    hidden [void] SaveAuthenticationDetails([string] $baseUrl, [object] $authDetails) {
        try {
            $this.logger.LogInfo("Saving authentication details for: $baseUrl", "AuthRecovery")
            
            # Create a safe filename from the base URL
            $safeUrl = $baseUrl -replace "https?://" -replace "[^a-zA-Z0-9\-\.]", "_"
            
            # Initialize credential variable
            $credential = $null
            
            # Create credential object based on auth type
            switch ($authDetails.AuthDetails.Type) {
                "ApiKey" {
                    $credential = [PSCredential]::new("ApiKey", $authDetails.AuthDetails.ApiKey)
                    # Store additional metadata
                    $metadata = @{
                        Type = "ApiKey"
                        HeaderName = $authDetails.AuthDetails.HeaderName
                        BaseUrl = $baseUrl
                        Timestamp = Get-Date
                    }
                    $this.SaveAuthMetadata($safeUrl, $metadata)
                }
                "Bearer" {
                    $credential = [PSCredential]::new("Bearer", $authDetails.AuthDetails.Token)
                    $metadata = @{
                        Type = "Bearer"
                        BaseUrl = $baseUrl
                        Timestamp = Get-Date
                    }
                    $this.SaveAuthMetadata($safeUrl, $metadata)
                }
                "Basic" {
                    $credential = [PSCredential]::new($authDetails.AuthDetails.Username, $authDetails.AuthDetails.Password)
                    $metadata = @{
                        Type = "Basic"
                        BaseUrl = $baseUrl
                        Timestamp = Get-Date
                    }
                    $this.SaveAuthMetadata($safeUrl, $metadata)
                }
                "Custom" {
                    # For custom headers, serialize as JSON and store as secure string (encrypted with user context)
                    $headersJson = $authDetails.AuthDetails.Headers | ConvertTo-Json
                    $secureJson = $headersJson | ConvertTo-SecureString
                    $credential = [PSCredential]::new("Custom", $secureJson)
                    $metadata = @{
                        Type = "Custom"
                        BaseUrl = $baseUrl
                        Timestamp = Get-Date
                    }
                    $this.SaveAuthMetadata($safeUrl, $metadata)
                }
                default {
                    $this.logger.LogWarning("Unknown authentication type: $($authDetails.AuthDetails.Type)", "AuthRecovery")
                    throw "Unsupported authentication type: $($authDetails.AuthDetails.Type)"
                }
            }
            
            # Validate that credential was created
            if ($null -eq $credential) {
                throw "Failed to create credential object for authentication type: $($authDetails.AuthDetails.Type)"
            }
            
            $success = $this.credentialService.SaveCredentials($safeUrl, $credential)
            if ($success) {
                $this.logger.LogInfo("Authentication details saved successfully", "AuthRecovery")
            }
            else {
                $this.logger.LogWarning("Failed to save authentication details", "AuthRecovery")
            }
        }
        catch {
            $this.logger.LogError("Error saving authentication details: $($_.Exception.Message)", "AuthRecovery")
        }
    }

    # Save authentication metadata
    hidden [void] SaveAuthMetadata([string] $safeUrl, [hashtable] $metadata) {
        try {
            $metadataPath = Join-Path $this.credentialService.credentialBasePath "$safeUrl.meta"
            $metadata | ConvertTo-Json | Out-File -FilePath $metadataPath -Encoding UTF8
            $this.logger.LogDebug("Saved authentication metadata", "AuthRecovery")
        }
        catch {
            $this.logger.LogWarning("Failed to save authentication metadata: $($_.Exception.Message)", "AuthRecovery")
        }
    }

    # Build authentication headers based on auth type
    hidden [hashtable] BuildAuthHeaders([object] $authDetails, [string] $authType) {
        $headers = @{}
        
        try {
            switch ($authType) {
                "ApiKey" {
                    $apiKeyValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($authDetails.AuthDetails.ApiKey))
                    $headers[$authDetails.AuthDetails.HeaderName] = $apiKeyValue
                }
                "Bearer" {
                    $tokenValue = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($authDetails.AuthDetails.Token))
                    $headers["Authorization"] = "Bearer $tokenValue"
                }
                "Basic" {
                    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($authDetails.AuthDetails.Password))
                    $credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($authDetails.AuthDetails.Username):$passwordText"))
                    $headers["Authorization"] = "Basic $credentials"
                }
                "Custom" {
                    foreach ($header in $authDetails.AuthDetails.Headers.GetEnumerator()) {
                        $headers[$header.Key] = $header.Value
                    }
                }
            }
            
            $this.logger.LogDebug("Built authentication headers for type: $authType", "AuthRecovery")
        }
        catch {
            $this.logger.LogError("Error building authentication headers: $($_.Exception.Message)", "AuthRecovery")
        }
        
        return $headers
    }

    # Retry mechanism management
    hidden [string] GetRetryKey([string] $baseUrl) {
        return $baseUrl.ToLower()
    }

    hidden [bool] HasExceededRetryLimit([string] $retryKey) {
        return $this.retryAttempts.ContainsKey($retryKey) -and $this.retryAttempts[$retryKey] -ge $this.maxRetries
    }

    hidden [void] IncrementRetryAttempt([string] $retryKey) {
        if ($this.retryAttempts.ContainsKey($retryKey)) {
            $this.retryAttempts[$retryKey]++
        }
        else {
            $this.retryAttempts[$retryKey] = 1
        }
        $this.logger.LogInfo("Retry attempt $($this.retryAttempts[$retryKey]) of $($this.maxRetries) for $retryKey", "AuthRecovery")
    }

    # Reset retry attempts for a specific URL
    [void] ResetRetryAttempts([string] $baseUrl) {
        $retryKey = $this.GetRetryKey($baseUrl)
        if ($this.retryAttempts.ContainsKey($retryKey)) {
            $this.retryAttempts.Remove($retryKey)
            $this.logger.LogInfo("Reset retry attempts for $baseUrl", "AuthRecovery")
        }
    }

    # Load saved authentication details
    [object] LoadSavedAuthDetails([string] $baseUrl) {
        try {
            $safeUrl = $baseUrl -replace "https?://" -replace "[^a-zA-Z0-9\-\.]", "_"
            
            if (-not $this.credentialService.HasCredentials($safeUrl)) {
                return $null
            }

            $credential = $this.credentialService.LoadCredentials($safeUrl)
            if (-not $credential) {
                return $null
            }

            # Load metadata if available
            $metadataPath = Join-Path $this.credentialService.credentialBasePath "$safeUrl.meta"
            $metadata = @{ Type = "Basic" }  # Default fallback
            if (Test-Path $metadataPath) {
                $metadata = Get-Content $metadataPath | ConvertFrom-Json -AsHashtable
            }

            # Build auth details based on type
            $authDetails = @{
                Type = $metadata.Type
                BaseUrl = $baseUrl
            }

            switch ($metadata.Type) {
                "ApiKey" {
                    $authDetails.ApiKey = $credential.Password
                    $authDetails.HeaderName = $metadata.HeaderName
                }
                "Bearer" {
                    $authDetails.Token = $credential.Password
                }
                "Basic" {
                    $authDetails.Username = $credential.UserName
                    $authDetails.Password = $credential.Password
                }
                "Custom" {
                    $headersJson = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
                    $authDetails.Headers = $headersJson | ConvertFrom-Json -AsHashtable
                }
            }

            $this.logger.LogInfo("Loaded saved authentication details for: $baseUrl", "AuthRecovery")
            return @{
                Success = $true
                AuthDetails = $authDetails
                Headers = $this.BuildAuthHeaders(@{ AuthDetails = $authDetails }, $metadata.Type)
            }
        }
        catch {
            $this.logger.LogError("Error loading saved authentication details: $($_.Exception.Message)", "AuthRecovery")
            return $null
        }
    }

    # Get service information
    [object] GetServiceInfo() {
        return @{
            ServiceType = "AuthenticationFailureRecoveryService"
            Version = "1.0.0"
            MaxRetries = $this.maxRetries
            ActiveRetryKeys = $this.retryAttempts.Keys
            CachedAuthTypes = $this.authTypeCache.Keys
        }
    }
}