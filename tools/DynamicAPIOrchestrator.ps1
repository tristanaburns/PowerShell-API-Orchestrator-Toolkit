# DynamicAPIOrchestrator.ps1
# Universal API orchestrator with dynamic inline properties
# Can CRUD any API endpoint with runtime parameters

[CmdletBinding()]
param(
    # Dynamic API Configuration
    [string]$BaseUrl,
    [string]$AuthType = "None",
    [string]$ApiKey,
    [string]$BearerToken,
    [string]$Username,
    [string]$Password,
    
    # Dynamic Operation Parameters  
    [string]$Method = "GET",
    [string]$Endpoint,
    [string]$Body,
    [hashtable]$QueryParams = @{},
    [hashtable]$Headers = @{},
    [hashtable]$PathParams = @{},
    
    # Operation Shortcuts
    [switch]$Get,
    [switch]$Post,
    [switch]$Put,
    [switch]$Delete,
    [switch]$Patch,
    
    # Utility Parameters
    [string]$LogLevel = "Info",
    [switch]$ShowRequest,
    [switch]$ShowResponse,
    [string]$OutputFormat = "Json",
    [switch]$SSLBypass
)

# Import the universal service framework
try {
    . "$PSScriptRoot\..\src\services\LoggingService.ps1"
    . "$PSScriptRoot\..\src\services\ConfigurationService.ps1"
    . "$PSScriptRoot\..\src\services\CredentialService.ps1"
    . "$PSScriptRoot\..\src\services\CoreAuthenticationService.ps1"
    . "$PSScriptRoot\..\src\services\AuthenticationFailureRecoveryService.ps1"
    . "$PSScriptRoot\..\src\services\GenericAPIService.ps1"
}
catch {
    Write-Error "Failed to import service framework: $_"
    exit 1
}

function Initialize-DynamicServices {
    [CmdletBinding()]
    param([string]$LogLevel, [bool]$SSLBypass)
    
    Write-Host "=== DYNAMIC API ORCHESTRATOR ===" -ForegroundColor Green
    Write-Host "Initializing dynamic orchestration services..." -ForegroundColor Cyan
    
    # Apply SSL bypass if requested
    if ($SSLBypass) {
        Write-Host "[WARNING] SSL Certificate validation bypass enabled" -ForegroundColor Yellow
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    
    try {
        # Initialize core services
        $loggingService = [LoggingService]::new($null, $true, $true)
        $loggingService.SetLogLevel($LogLevel)
        
        $configPath = Join-Path $PSScriptRoot "..\config"
        $configService = [ConfigurationService]::new($configPath, $loggingService)
        
        $credentialPath = Join-Path $PSScriptRoot "..\config\credentials"
        $credentialService = [CredentialService]::new($credentialPath, $loggingService)
        
        $authService = [CoreAuthenticationService]::new($loggingService, $credentialService, $configService)
        $apiService = [GenericAPIService]::new($loggingService, $authService, $configService)
        
        Write-Host "[SUCCESS] Dynamic services initialized" -ForegroundColor Green
        
        return @{
            Logging = $loggingService
            Config = $configService
            Auth = $authService
            API = $apiService
        }
    }
    catch {
        Write-Error "Failed to initialize dynamic services: $_"
        throw $_
    }
}

function New-DynamicAPIService {
    [CmdletBinding()]
    param(
        [object]$Services,
        [string]$BaseUrl,
        [string]$AuthType,
        [string]$ApiKey,
        [string]$BearerToken,
        [string]$Username,
        [string]$Password,
        [hashtable]$CustomHeaders
    )
    
    Write-Host ""
    Write-Host "=== CONFIGURING DYNAMIC API SERVICE ===" -ForegroundColor Cyan
    
    # Create a dynamic API service instance
    $dynamicAPI = [GenericAPIService]::new($Services.Logging, $Services.Auth, $Services.Config)
    
    # Override the base URL dynamically
    $dynamicAPI.baseUrl = $BaseUrl.TrimEnd('/')
    
    # Configure dynamic headers
    $dynamicAPI.headers = @{
        'Content-Type' = 'application/json'
        'User-Agent' = 'Dynamic-API-Orchestrator/1.0'
        'Accept' = 'application/json'
    }
    
    # Add custom headers
    if ($CustomHeaders -and $CustomHeaders.Count -gt 0) {
        foreach ($header in $CustomHeaders.GetEnumerator()) {
            $dynamicAPI.headers[$header.Key] = $header.Value
        }
    }
    
    # Configure authentication dynamically
    switch ($AuthType.ToLower()) {
        'apikey' {
            if ($ApiKey) {
                $dynamicAPI.headers['X-API-Key'] = $ApiKey
                Write-Host "[SUCCESS] API Key authentication configured" -ForegroundColor Green
            }
        }
        'bearer' {
            if ($BearerToken) {
                $dynamicAPI.headers['Authorization'] = "Bearer $BearerToken"
                Write-Host "[SUCCESS] Bearer token authentication configured" -ForegroundColor Green
            }
        }
        'basic' {
            if ($Username -and $Password) {
                $credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Password}"))
                $dynamicAPI.headers['Authorization'] = "Basic $credentials"
                Write-Host "[SUCCESS] Basic authentication configured" -ForegroundColor Green
            }
        }
        default {
            Write-Host "[SUCCESS] No authentication configured" -ForegroundColor Green
        }
    }
    
    Write-Host "Base URL: $($dynamicAPI.baseUrl)" -ForegroundColor White
    Write-Host "Headers: $($dynamicAPI.headers.Count) configured" -ForegroundColor White
    
    return $dynamicAPI
}

function Resolve-DynamicEndpoint {
    [CmdletBinding()]
    param(
        [string]$EndpointTemplate,
        [hashtable]$PathParams,
        [hashtable]$QueryParams
    )
    
    $resolvedEndpoint = $EndpointTemplate
    
    # Replace path parameters
    if ($PathParams -and $PathParams.Count -gt 0) {
        foreach ($param in $PathParams.GetEnumerator()) {
            $placeholder = "{$($param.Key)}"
            $resolvedEndpoint = $resolvedEndpoint -replace [regex]::Escape($placeholder), $param.Value
        }
    }
    
    # Add query parameters
    if ($QueryParams -and $QueryParams.Count -gt 0) {
        $queryString = ($QueryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
        $separator = if ($resolvedEndpoint -contains "?") { "&" } else { "?" }
        $resolvedEndpoint += "$separator$queryString"
    }
    
    return $resolvedEndpoint
}

function Invoke-DynamicAPIOperation {
    [CmdletBinding()]
    param(
        [object]$APIService,
        [string]$Method,
        [string]$Endpoint,
        [object]$Body,
        [bool]$ShowRequest,
        [bool]$ShowResponse
    )
    
    Write-Host ""
    Write-Host "=== DYNAMIC API OPERATION ===" -ForegroundColor Cyan
    
    if ($ShowRequest) {
        Write-Host "Request Details:" -ForegroundColor Yellow
        Write-Host "  Method: $Method" -ForegroundColor White
        Write-Host "  URL: $($APIService.baseUrl)/$($Endpoint.TrimStart('/'))" -ForegroundColor White
        Write-Host "  Headers:" -ForegroundColor White
        foreach ($header in $APIService.headers.GetEnumerator()) {
            Write-Host "    $($header.Key): $($header.Value)" -ForegroundColor Gray
        }
        if ($Body) {
            Write-Host "  Body:" -ForegroundColor White
            Write-Host "    $Body" -ForegroundColor Gray
        }
    }
    
    try {
        $result = switch ($Method.ToUpper()) {
            'GET' { 
                $APIService.Get($Endpoint.TrimStart('/'))
            }
            'POST' { 
                $bodyObject = if ($Body) { 
                    try {
                        $Body | ConvertFrom-Json -ErrorAction Stop
                    } catch {
                        # If JSON parsing fails, treat as string and try to fix common issues
                        $cleanBody = $Body -replace '\\"', '"'
                        $cleanBody | ConvertFrom-Json -ErrorAction Stop
                    }
                } else { @{} }
                $APIService.Post($Endpoint.TrimStart('/'), $bodyObject)
            }
            'PUT' {
                $bodyObject = if ($Body) { $Body | ConvertFrom-Json } else { @{} }
                $APIService.Put($Endpoint.TrimStart('/'), $bodyObject)
            }
            'DELETE' { 
                $APIService.Delete($Endpoint.TrimStart('/'))
            }
            'PATCH' {
                $bodyObject = if ($Body) { $Body | ConvertFrom-Json } else { @{} }
                # GenericAPIService doesn't have PATCH, so we'll use PUT as fallback
                Write-Host "[WARNING] PATCH method not directly supported, using PUT" -ForegroundColor Yellow
                $APIService.Put($Endpoint.TrimStart('/'), $bodyObject)
            }
            default { 
                throw "Unsupported HTTP method: $Method"
            }
        }
        
        Write-Host "[SUCCESS] $Method operation successful with authentication recovery support" -ForegroundColor Green
        
        if ($ShowResponse -and $result) {
            Write-Host ""
            Write-Host "Response:" -ForegroundColor Yellow
            $result | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Gray
        }
        
        return $result
    }
    catch {
        # Check if this was an authentication-related failure
        $errorMessage = $_.Exception.Message
        if ($errorMessage -match "authentication|credential|lockout") {
            Write-Host "[AUTH-FAILURE] Authentication-related error detected: $errorMessage" -ForegroundColor Yellow
            Write-Host "[INFO] The authentication recovery system should have attempted to resolve this automatically." -ForegroundColor Cyan
            Write-Host "[INFO] If you see this message, the recovery may have been blocked due to lockout protection." -ForegroundColor Cyan
        }
        else {
            Write-Host "[FAILED] $Method operation failed: $errorMessage" -ForegroundColor Red
        }
        return $null
    }
}

function Show-DynamicOperationSummary {
    [CmdletBinding()]
    param(
        [string]$Method,
        [string]$BaseUrl,
        [string]$Endpoint,
        [object]$Result,
        [string]$OutputFormat
    )
    
    Write-Host ""
    Write-Host "=== OPERATION SUMMARY ===" -ForegroundColor Green
    
    $success = ($Result -ne $null)
    $status = if ($success) { "[SUCCESS]" } else { "[FAILED]" }
    $color = if ($success) { "Green" } else { "Red" }
    
    Write-Host "Method: $Method" -ForegroundColor White
    Write-Host "URL: $BaseUrl/$($Endpoint.TrimStart('/'))" -ForegroundColor White
    Write-Host "Status: $status" -ForegroundColor $color
    
    if ($success -and $Result) {
        switch ($OutputFormat.ToLower()) {
            'json' {
                Write-Host ""
                Write-Host "Response Data:" -ForegroundColor Cyan
                $Result | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Gray
            }
            'table' {
                if ($Result -is [Array] -and $Result.Count -gt 0) {
                    Write-Host ""
                    Write-Host "Response Data (Table):" -ForegroundColor Cyan
                    $Result | Select-Object -First 10 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
                }
                elseif ($Result -is [PSCustomObject]) {
                    Write-Host ""
                    Write-Host "Response Data (Properties):" -ForegroundColor Cyan
                    $Result | Format-List | Out-String | Write-Host -ForegroundColor Gray
                }
            }
            'summary' {
                Write-Host ""
                if ($Result -is [Array]) {
                    Write-Host "Response: Array with $($Result.Count) items" -ForegroundColor Cyan
                }
                elseif ($Result -is [PSCustomObject]) {
                    $propCount = ($Result | Get-Member -MemberType NoteProperty | Measure-Object).Count
                    Write-Host "Response: Object with $propCount properties" -ForegroundColor Cyan
                }
                else {
                    Write-Host "Response: $($Result.GetType().Name)" -ForegroundColor Cyan
                }
            }
        }
    }
    
    if ($success) {
        Write-Host ""
        Write-Host "SUCCESS - DYNAMIC API ORCHESTRATION SUCCESSFUL!" -ForegroundColor Green
        Write-Host "[SUCCESS] Runtime API configuration worked perfectly" -ForegroundColor Green
        Write-Host "[SUCCESS] Dynamic endpoint resolution successful" -ForegroundColor Green
        Write-Host "[SUCCESS] Universal CRUD operation completed" -ForegroundColor Green
    }
}

# Main execution
try {
    # Validate required parameters
    if (-not $BaseUrl) {
        Write-Error "BaseUrl is required for dynamic API orchestration"
        exit 1
    }
    
    if (-not $Endpoint) {
        Write-Error "Endpoint is required for API operation"
        exit 1
    }
    
    # Determine HTTP method
    if ($Get) { $Method = "GET" }
    elseif ($Post) { $Method = "POST" }
    elseif ($Put) { $Method = "PUT" }
    elseif ($Delete) { $Method = "DELETE" }
    elseif ($Patch) { $Method = "PATCH" }
    
    # Initialize dynamic services
    $services = Initialize-DynamicServices -LogLevel $LogLevel -SSLBypass $SSLBypass
    
    # Create dynamic API service with runtime configuration
    $dynamicAPI = New-DynamicAPIService -Services $services -BaseUrl $BaseUrl -AuthType $AuthType -ApiKey $ApiKey -BearerToken $BearerToken -Username $Username -Password $Password -CustomHeaders $Headers
    
    # Resolve dynamic endpoint with path and query parameters
    $resolvedEndpoint = Resolve-DynamicEndpoint -EndpointTemplate $Endpoint -PathParams $PathParams -QueryParams $QueryParams
    
    Write-Host ""
    Write-Host "Resolved Endpoint: $resolvedEndpoint" -ForegroundColor White
    
    # Execute dynamic API operation
    $result = Invoke-DynamicAPIOperation -APIService $dynamicAPI -Method $Method -Endpoint $resolvedEndpoint -Body $Body -ShowRequest $ShowRequest -ShowResponse $ShowResponse
    
    # Show operation summary
    Show-DynamicOperationSummary -Method $Method -BaseUrl $BaseUrl -Endpoint $resolvedEndpoint -Result $result -OutputFormat $OutputFormat
    
    Write-Host ""
    Write-Host "Complete - Dynamic API Orchestrator execution complete!" -ForegroundColor Green
}
catch {
    Write-Error "Dynamic API Orchestrator failed: $_"
    exit 1
}