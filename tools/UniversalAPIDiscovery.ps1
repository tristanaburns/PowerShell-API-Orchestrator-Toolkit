# UniversalAPIDiscovery.ps1
# Universal OpenAPI discovery and endpoint exploration tool
# Demonstrates automatic API discovery capabilities

[CmdletBinding()]
param(
    [string]$ApiBaseUrl = "https://petstore.swagger.io",
    [string]$OpenAPISpecPath = "/v2/swagger.json",
    [string]$LogLevel = "Info",
    [switch]$DiscoverEndpoints,
    [switch]$ListEndpoints,
    [switch]$ShowSchema,
    [string]$EndpointPath,
    [switch]$TestEndpoint
)

# Import the universal service framework
try {
    . "$PSScriptRoot\..\src\services\LoggingService.ps1"
    . "$PSScriptRoot\..\src\services\ConfigurationService.ps1"
    . "$PSScriptRoot\..\src\services\CredentialService.ps1"
    . "$PSScriptRoot\..\src\services\CoreAuthenticationService.ps1"
    . "$PSScriptRoot\..\src\services\GenericAPIService.ps1"
}
catch {
    Write-Error "Failed to import service framework: $_"
    exit 1
}

function Initialize-DiscoveryServices {
    [CmdletBinding()]
    param([string]$LogLevel)
    
    Write-Host "=== UNIVERSAL API DISCOVERY ===" -ForegroundColor Green
    Write-Host "Initializing discovery services..." -ForegroundColor Cyan
    
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
        
        Write-Host "[SUCCESS] Discovery services initialized" -ForegroundColor Green
        
        return @{
            Logging = $loggingService
            Config = $configService
            Auth = $authService
            API = $apiService
        }
    }
    catch {
        Write-Error "Failed to initialize discovery services: $_"
        throw $_
    }
}

function Get-OpenAPISpec {
    [CmdletBinding()]
    param([object]$Services, [string]$BaseUrl, [string]$SpecPath)
    
    Write-Host ""
    Write-Host "=== OPENAPI SPEC DISCOVERY ===" -ForegroundColor Cyan
    
    try {
        # Create a temporary API service for the target API
        $tempApiService = [GenericAPIService]::new($Services.Logging, $Services.Auth, $Services.Config)
        $tempApiService.baseUrl = $BaseUrl.TrimEnd('/')
        
        Write-Host "Discovering OpenAPI spec from: $BaseUrl$SpecPath" -ForegroundColor Yellow
        
        # Try to get the OpenAPI/Swagger spec
        $spec = $tempApiService.Get($SpecPath.TrimStart('/'))
        
        if ($spec) {
            Write-Host "[SUCCESS] OpenAPI spec retrieved successfully" -ForegroundColor Green
            Write-Host "API Info:" -ForegroundColor White
            
            if ($spec.info) {
                Write-Host "  Title: $($spec.info.title)" -ForegroundColor Gray
                Write-Host "  Version: $($spec.info.version)" -ForegroundColor Gray
                Write-Host "  Description: $($spec.info.description)" -ForegroundColor Gray
            }
            
            if ($spec.host) {
                Write-Host "  Host: $($spec.host)" -ForegroundColor Gray
            }
            
            if ($spec.basePath) {
                Write-Host "  Base Path: $($spec.basePath)" -ForegroundColor Gray
            }
            
            return $spec
        }
        else {
            Write-Host "[FAILED] Failed to retrieve OpenAPI spec" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "[FAILED] OpenAPI spec discovery failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Show-DiscoveredEndpoints {
    [CmdletBinding()]
    param([object]$OpenAPISpec)
    
    Write-Host ""
    Write-Host "=== DISCOVERED API ENDPOINTS ===" -ForegroundColor Cyan
    
    if (-not $OpenAPISpec -or -not $OpenAPISpec.paths) {
        Write-Host "[FAILED] No endpoints found in OpenAPI spec" -ForegroundColor Red
        return
    }
    
    $endpointCount = 0
    
    foreach ($path in $OpenAPISpec.paths.PSObject.Properties) {
        $pathName = $path.Name
        $pathObj = $path.Value
        
        Write-Host "  * $pathName" -ForegroundColor White
        
        # Show available HTTP methods for this path
        $methods = @()
        if ($pathObj.get) { $methods += "GET" }
        if ($pathObj.post) { $methods += "POST" }
        if ($pathObj.put) { $methods += "PUT" }
        if ($pathObj.delete) { $methods += "DELETE" }
        if ($pathObj.patch) { $methods += "PATCH" }
        
        Write-Host "   Methods: $($methods -join ', ')" -ForegroundColor Gray
        
        # Show summary for GET method if available
        if ($pathObj.get -and $pathObj.get.summary) {
            Write-Host "   Summary: $($pathObj.get.summary)" -ForegroundColor Gray
        }
        
        $endpointCount++
    }
    
    Write-Host ""
    Write-Host "[SUCCESS] Discovered $endpointCount API endpoints" -ForegroundColor Green
}

function Show-EndpointSchema {
    [CmdletBinding()]
    param([object]$OpenAPISpec, [string]$EndpointPath)
    
    Write-Host ""
    Write-Host "=== ENDPOINT SCHEMA DETAILS ===" -ForegroundColor Cyan
    
    if (-not $OpenAPISpec -or -not $OpenAPISpec.paths) {
        Write-Host "[FAILED] No OpenAPI spec available" -ForegroundColor Red
        return
    }
    
    $endpoint = $OpenAPISpec.paths.PSObject.Properties | Where-Object Name -eq $EndpointPath
    
    if (-not $endpoint) {
        Write-Host "[FAILED] Endpoint '$EndpointPath' not found in API spec" -ForegroundColor Red
        Write-Host "Available endpoints:" -ForegroundColor Yellow
        $OpenAPISpec.paths.PSObject.Properties | ForEach-Object {
            Write-Host "  $($_.Name)" -ForegroundColor Gray
        }
        return
    }
    
    Write-Host "  * Endpoint: $EndpointPath" -ForegroundColor White
    
    $endpointObj = $endpoint.Value
    
    # Show details for each HTTP method
    foreach ($method in @('get', 'post', 'put', 'delete', 'patch')) {
        if ($endpointObj.$method) {
            $methodObj = $endpointObj.$method
            Write-Host ""
            Write-Host "  - $($method.ToUpper()) Method:" -ForegroundColor Yellow
            
            if ($methodObj.summary) {
                Write-Host "   Summary: $($methodObj.summary)" -ForegroundColor Gray
            }
            
            if ($methodObj.description) {
                Write-Host "   Description: $($methodObj.description)" -ForegroundColor Gray
            }
            
            if ($methodObj.parameters) {
                Write-Host "   Parameters:" -ForegroundColor Gray
                foreach ($param in $methodObj.parameters) {
                    $required = if ($param.required) { " (required)" } else { "" }
                    Write-Host "     - $($param.name): $($param.type)$required" -ForegroundColor DarkGray
                }
            }
            
            if ($methodObj.responses) {
                Write-Host "   Responses:" -ForegroundColor Gray
                foreach ($response in $methodObj.responses.PSObject.Properties) {
                    Write-Host "     - $($response.Name): $($response.Value.description)" -ForegroundColor DarkGray
                }
            }
        }
    }
}

function Test-DiscoveredEndpoint {
    [CmdletBinding()]
    param([object]$Services, [string]$BaseUrl, [string]$EndpointPath)
    
    Write-Host ""
    Write-Host "=== TESTING DISCOVERED ENDPOINT ===" -ForegroundColor Cyan
    
    try {
        # Create a temporary API service for the target API
        $tempApiService = [GenericAPIService]::new($Services.Logging, $Services.Auth, $Services.Config)
        $tempApiService.baseUrl = $BaseUrl.TrimEnd('/')
        
        Write-Host "Testing endpoint: $EndpointPath" -ForegroundColor Yellow
        
        # Try a GET request to the endpoint
        $result = $tempApiService.Get($EndpointPath.TrimStart('/'))
        
        Write-Host "[SUCCESS] Endpoint test successful" -ForegroundColor Green
        Write-Host "Response preview:" -ForegroundColor White
        
        # Show a preview of the response
        if ($result) {
            $preview = $result | ConvertTo-Json -Depth 2 -Compress
            if ($preview.Length -gt 500) {
                Write-Host "$($preview.Substring(0, 500))..." -ForegroundColor Gray
            }
            else {
                Write-Host $preview -ForegroundColor Gray
            }
        }
        
        return $true
    }
    catch {
        Write-Host "[FAILED] Endpoint test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-DiscoverySummary {
    [CmdletBinding()]
    param([object]$Results, [object]$OpenAPISpec)
    
    Write-Host ""
    Write-Host "=== API DISCOVERY SUMMARY ===" -ForegroundColor Green
    
    $totalOperations = $Results.Count
    $successfulOperations = ($Results.Values | Where-Object { $_ -ne $null -and $_ -ne $false }).Count
    $successRate = if ($totalOperations -gt 0) { [math]::Round(($successfulOperations / $totalOperations) * 100, 1) } else { 0 }
    
    Write-Host "Discovery Operations: $totalOperations" -ForegroundColor White
    Write-Host "Successful: $successfulOperations" -ForegroundColor Green
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { 'Green' } else { 'Yellow' })
    
    if ($OpenAPISpec -and $OpenAPISpec.paths) {
        $endpointCount = ($OpenAPISpec.paths.PSObject.Properties | Measure-Object).Count
        Write-Host "Endpoints Discovered: $endpointCount" -ForegroundColor Cyan
    }
    
    Write-Host ""
    foreach ($result in $Results.GetEnumerator()) {
        $status = if ($result.Value -ne $null -and $result.Value -ne $false) { "[SUCCESS]" } else { "[FAILED]" }
        $color = if ($result.Value -ne $null -and $result.Value -ne $false) { "Green" } else { "Red" }
        Write-Host "$($result.Key): $status" -ForegroundColor $color
    }
    
    if ($successRate -eq 100) {
        Write-Host ""
        Write-Host "SUCCESS - API DISCOVERY COMPLETE!" -ForegroundColor Green
        Write-Host "Universal framework successfully discovered API structure!" -ForegroundColor Green
    }
}

# Main execution
try {
    # Initialize discovery services
    $services = Initialize-DiscoveryServices -LogLevel $LogLevel
    $results = @{}
    $openApiSpec = $null
    
    Write-Host "Target API: $ApiBaseUrl" -ForegroundColor White
    Write-Host "OpenAPI Spec Path: $OpenAPISpecPath" -ForegroundColor White
    
    # Execute requested operations
    if ($DiscoverEndpoints -or (-not ($ListEndpoints -or $ShowSchema -or $TestEndpoint))) {
        $openApiSpec = Get-OpenAPISpec -Services $services -BaseUrl $ApiBaseUrl -SpecPath $OpenAPISpecPath
        $results['OpenAPI Discovery'] = ($openApiSpec -ne $null)
    }
    
    if ($ListEndpoints -or (-not ($DiscoverEndpoints -or $ShowSchema -or $TestEndpoint))) {
        if (-not $openApiSpec) {
            $openApiSpec = Get-OpenAPISpec -Services $services -BaseUrl $ApiBaseUrl -SpecPath $OpenAPISpecPath
        }
        Show-DiscoveredEndpoints -OpenAPISpec $openApiSpec
        $results['List Endpoints'] = ($openApiSpec -ne $null -and $openApiSpec.paths)
    }
    
    if ($ShowSchema -and $EndpointPath) {
        if (-not $openApiSpec) {
            $openApiSpec = Get-OpenAPISpec -Services $services -BaseUrl $ApiBaseUrl -SpecPath $OpenAPISpecPath
        }
        Show-EndpointSchema -OpenAPISpec $openApiSpec -EndpointPath $EndpointPath
        $results['Show Schema'] = $true
    }
    
    if ($TestEndpoint -and $EndpointPath) {
        $testResult = Test-DiscoveredEndpoint -Services $services -BaseUrl $ApiBaseUrl -EndpointPath $EndpointPath
        $results['Test Endpoint'] = $testResult
    }
    
    # Show summary
    if ($results.Count -gt 0) {
        Show-DiscoverySummary -Results $results -OpenAPISpec $openApiSpec
    }
    
    Write-Host ""
    Write-Host "Complete - Universal API Discovery complete!" -ForegroundColor Green
}
catch {
    Write-Error "Universal API Discovery failed: $_"
    exit 1
}