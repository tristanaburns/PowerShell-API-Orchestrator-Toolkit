# UniversalAPIDiscovery.ps1
# Universal OpenAPI discovery and endpoint exploration tool

[CmdletBinding()]
param(
    [string]$ApiBaseUrl = "https://petstore.swagger.io",
    [string]$OpenAPISpecPath = "/v2/swagger.json",
    [string]$LogLevel = "Info"
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
    param([string]$LogLevel)
    
    Write-Host "=== UNIVERSAL API DISCOVERY ===" -ForegroundColor Green
    Write-Host "Initializing discovery services..." -ForegroundColor Cyan
    
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

function Get-OpenAPISpec {
    param([object]$Services, [string]$BaseUrl, [string]$SpecPath)
    
    Write-Host ""
    Write-Host "=== OPENAPI SPEC DISCOVERY ===" -ForegroundColor Cyan
    
    try {
        Write-Host "Discovering OpenAPI spec from: $BaseUrl$SpecPath" -ForegroundColor Yellow
        
        # Create URL and make request
        $fullUrl = "$($BaseUrl.TrimEnd('/'))$($SpecPath)"
        $response = Invoke-RestMethod -Uri $fullUrl -Method GET -ErrorAction Stop
        
        if ($response) {
            Write-Host "[SUCCESS] OpenAPI spec retrieved successfully" -ForegroundColor Green
            Write-Host "API Info:" -ForegroundColor White
            
            if ($response.info) {
                Write-Host "  Title: $($response.info.title)" -ForegroundColor Gray
                Write-Host "  Version: $($response.info.version)" -ForegroundColor Gray
                if ($response.info.description) {
                    Write-Host "  Description: $($response.info.description)" -ForegroundColor Gray
                }
            }
            
            if ($response.host) {
                Write-Host "  Host: $($response.host)" -ForegroundColor Gray
            }
            
            if ($response.basePath) {
                Write-Host "  Base Path: $($response.basePath)" -ForegroundColor Gray
            }
            
            return $response
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
    param([object]$OpenAPISpec)
    
    Write-Host ""
    Write-Host "=== DISCOVERED API ENDPOINTS ===" -ForegroundColor Cyan
    
    if (-not $OpenAPISpec -or -not $OpenAPISpec.paths) {
        Write-Host "[FAILED] No endpoints found in OpenAPI spec" -ForegroundColor Red
        return
    }
    
    $endpointCount = 0
    
    foreach ($pathProperty in $OpenAPISpec.paths.PSObject.Properties) {
        $pathName = $pathProperty.Name
        $pathObj = $pathProperty.Value
        
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
        
        # Limit output to first 10 endpoints for readability
        if ($endpointCount -ge 10) {
            Write-Host "   ... and more endpoints" -ForegroundColor DarkGray
            break
        }
    }
    
    Write-Host ""
    Write-Host "[SUCCESS] Discovered $($OpenAPISpec.paths.PSObject.Properties.Count) total API endpoints (showing first $endpointCount)" -ForegroundColor Green
}

# Main execution
try {
    # Initialize discovery services
    $services = Initialize-DiscoveryServices -LogLevel $LogLevel
    
    Write-Host "Target API: $ApiBaseUrl" -ForegroundColor White
    Write-Host "OpenAPI Spec Path: $OpenAPISpecPath" -ForegroundColor White
    
    # Discover the OpenAPI spec
    $openApiSpec = Get-OpenAPISpec -Services $services -BaseUrl $ApiBaseUrl -SpecPath $OpenAPISpecPath
    
    if ($openApiSpec) {
        # Show discovered endpoints
        Show-DiscoveredEndpoints -OpenAPISpec $openApiSpec
        
        Write-Host ""
        Write-Host "SUCCESS - API DISCOVERY COMPLETE!" -ForegroundColor Green
        Write-Host "Universal framework successfully discovered API structure!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Complete - Universal API Discovery complete!" -ForegroundColor Green
}
catch {
    Write-Error "Universal API Discovery failed: $_"
    exit 1
}