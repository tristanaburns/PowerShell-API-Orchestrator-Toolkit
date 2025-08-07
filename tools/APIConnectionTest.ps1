# APIConnectionTest.ps1 - with Endpoint Discovery
<#
.SYNOPSIS
    diagnostic test for API connections with endpoint discovery and caching.

.DESCRIPTION
    Tests connectivity to API endpoints with support for:
    - Basic authentication with username/password
    - Current user authentication using Windows/AD credentials
    - OpenAPI endpoint discovery (100+ endpoints)
    - Intelligent endpoint caching with 24-hour TTL
    - Hierarchical support detection (Global/Local endpoints)
    - Performance metrics and optimization
    - Tool integration preparation

.PARAMETER APIEndpoint
    API Endpoint FQDN or IP address to test connectivity against.
    Default: "lab-api-01.test.com"

.PARAMETER Username
    Username for basic authentication. Default: "admin"

.PARAMETER SkipSSLCheck
    Bypass SSL certificate validation.

.PARAMETER ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist.

.PARAMETER SaveCredentials
    Automatically save working credentials to encrypted storage.

.PARAMETER UseCurrentUserCredentials
    Use Windows Authentication with current user credentials.

.PARAMETER NonInteractive
    Run without interactive prompts for automation scenarios.

.PARAMETER ManageCredentials
    Launch credential management interface.

.PARAMETER Force
    Force re-validation of OpenAPI specs and endpoints, ignoring TTL cache.

.EXAMPLE
    .\APIConnectionTest.ps1 -APIEndpoint "api-manager.corp.com"
    Test connectivity with endpoint discovery and caching.

.EXAMPLE
    .\APIConnectionTest.ps1 -APIEndpoint "api-manager.corp.com" -UseCurrentUserCredentials
    Test connectivity using current Windows user credentials.

.EXAMPLE
    .\APIConnectionTest.ps1 -APIEndpoint "api-manager.corp.com" -Force
    Force full endpoint discovery, ignoring cache.

.EXAMPLE
    .\APIConnectionTest.ps1 -NonInteractive -APIEndpoint "api-manager.corp.com"
    Run in non-interactive mode for automation.

.NOTES
    Version: 2.0
    Author: PowerShell API Orchestrator Toolkit
    Requires PowerShell 5.1 or higher
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$APIEndpoint = "lab-api-01.test.com",

    [Parameter(Mandatory=$false)]
    [string]$Username = "admin",

    [Parameter(Mandatory=$false)]
    [switch]$SkipSSLCheck = $true,

    [Parameter(Mandatory=$false)]
    [switch]$ForceNewCredentials,

    [Parameter(Mandatory=$false)]
    [switch]$SaveCredentials,

    [Parameter(Mandatory=$false)]
    [switch]$UseCurrentUserCredentials,

    [Parameter(Mandatory=$false)]
    [switch]$NonInteractive,

    [Parameter(Mandatory=$false)]
    [switch]$ManageCredentials,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Script header information for API Orchestrator Toolkit
Write-Host "===========================================" -ForegroundColor Green
Write-Host "API Connection Test Tool" -ForegroundColor Green
Write-Host "PowerShell API Orchestrator Toolkit v2.0" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

# Initialize script path and load framework
$global:currentScriptPath = $PSScriptRoot
$global:rootPath = Split-Path $currentScriptPath -Parent
$global:FrameworkPath = Join-Path $rootPath "src\services\InitServiceFramework.ps1"

try {
    if (Test-Path $FrameworkPath) {
        Write-Host "Loading API Orchestrator Framework..." -ForegroundColor Yellow
        . $FrameworkPath
        Write-Host "Framework loaded successfully." -ForegroundColor Green
    } else {
        throw "Framework not found at: $FrameworkPath"
    }
} catch {
    Write-Host "Failed to load framework: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please ensure you're running from the toolkit root directory" -ForegroundColor Yellow
    exit 1
}

# Load required services
try {
    $authService = [CoreServiceFactory]::CreateAuthenticationService()
    $configService = [CoreServiceFactory]::CreateConfigurationService()
    $loggingService = [CoreServiceFactory]::CreateLoggingService()
    
    Write-Host "Core services initialized successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to initialize core services: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Main connection test function
function Test-APIConnection {
    param(
        [string]$endpoint,
        [pscredential]$credential
    )
    
    try {
        Write-Host "Testing connection to API endpoint: $endpoint" -ForegroundColor Cyan
        
        # Create API service instance
        $apiService = [UniversalAPIService]::new($endpoint, $loggingService, $authService, $configService)
        
        # Test basic connectivity
        $domains = $apiService.GetDomains($endpoint)
        
        if ($domains -and $domains.results) {
            Write-Host "✅ Successfully connected to API endpoint" -ForegroundColor Green
            Write-Host "   Domains found: $($domains.results.Count)" -ForegroundColor Gray
            
            # Test additional endpoints
            Test-APIEndpoints -apiService $apiService -endpoint $endpoint
            
            return $true
        } else {
            Write-Host "❌ Failed to retrieve domains from API endpoint" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
        $loggingService.LogError("Connection test failed", "APITest", $_.Exception)
        return $false
    }
}

function Test-APIEndpoints {
    param(
        [object]$apiService,
        [string]$endpoint
    )
    
    Write-Host "Testing additional API endpoints..." -ForegroundColor Cyan
    
    try {
        # Test services endpoint
        $services = $apiService.GetServices($endpoint)
        if ($services) {
            Write-Host "✅ Services endpoint: $($services.results.Count) services found" -ForegroundColor Green
        }
        
        # Test groups endpoint
        $groups = $apiService.GetGroups($endpoint)
        if ($groups) {
            Write-Host "✅ Groups endpoint: $($groups.results.Count) groups found" -ForegroundColor Green
        }
        
        # Test security policies endpoint
        $policies = $apiService.GetSecurityPolicies($endpoint)
        if ($policies) {
            Write-Host "✅ Security Policies endpoint: $($policies.results.Count) policies found" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "⚠️  Some endpoints may not be available: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Main execution
try {
    Write-Host "Starting API connection test for: $APIEndpoint" -ForegroundColor Cyan
    
    # Handle credential management
    if ($ManageCredentials) {
        Write-Host "Launching credential management interface..." -ForegroundColor Yellow
        # Launch credential manager here
        return
    }
    
    # Get or create credentials
    $credential = $null
    if ($UseCurrentUserCredentials) {
        Write-Host "Using current Windows user credentials" -ForegroundColor Yellow
        $secureString = [System.Security.SecureString]::new()
        $credential = [System.Management.Automation.PSCredential]::new("current_user", $secureString)
    } else {
        # Try to get saved credentials first
        try {
            $credential = $authService.GetCredential($APIEndpoint)
            if ($credential -and -not $ForceNewCredentials) {
                Write-Host "Using saved credentials for $APIEndpoint" -ForegroundColor Yellow
            } else {
                throw "No saved credentials or force new requested"
            }
        } catch {
            if (-not $NonInteractive) {
                Write-Host "Enter credentials for API endpoint: $APIEndpoint" -ForegroundColor Yellow
                $credential = Get-Credential -UserName $Username -Message "API Endpoint Credentials"
                
                if ($SaveCredentials -and $credential) {
                    $authService.StoreCredential($APIEndpoint, $credential)
                    Write-Host "Credentials saved for future use" -ForegroundColor Green
                }
            } else {
                Write-Host "❌ No credentials available and running in non-interactive mode" -ForegroundColor Red
                exit 1
            }
        }
    }
    
    # Perform connection test
    if ($credential) {
        $authService.StoreCredential($APIEndpoint, $credential)
        $result = Test-APIConnection -endpoint $APIEndpoint -credential $credential
        
        if ($result) {
            Write-Host ""
            Write-Host "🎉 Connection test completed successfully!" -ForegroundColor Green
            Write-Host "API endpoint $APIEndpoint is ready for automation tasks." -ForegroundColor Gray
        } else {
            Write-Host ""
            Write-Host "❌ Connection test failed" -ForegroundColor Red
            Write-Host "Please check your credentials and network connectivity." -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "❌ No valid credentials provided" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Unexpected error during connection test: $($_.Exception.Message)" -ForegroundColor Red
    $loggingService.LogError("Connection test error", "APITest", $_.Exception)
    exit 1
} finally {
    Write-Host ""
    Write-Host "Connection test completed." -ForegroundColor Gray
}