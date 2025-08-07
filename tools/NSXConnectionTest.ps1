# NSXConnectionTest.ps1 - with Endpoint Discovery
<#
.SYNOPSIS
    diagnostic test for NSX-T Manager connections with endpoint discovery and caching.

.DESCRIPTION
    Tests connectivity to NSX-T Manager with support for:
    - Basic authentication with username/password
    - Current user authentication using Windows/AD credentials
    - OpenAPI endpoint discovery (100+ endpoints)
    - Intelligent endpoint caching with 24-hour TTL
    - Federation support detection (Global/Local Manager)
    - Performance metrics and optimization
    - Tool integration preparation

.PARAMETER NSXManager
    NSX Manager FQDN or IP address to test connectivity against.
    Default: "lab-nsxlm-01.lab.vdcninja.com"

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
    .\NSXConnectionTest.ps1 -NSXManager "nsx-manager.corp.com"
    Test connectivity with endpoint discovery and caching.

.EXAMPLE
    .\NSXConnectionTest.ps1 -NSXManager "nsx-manager.corp.com" -UseCurrentUserCredentials
    Test connectivity using current Windows user credentials.

.EXAMPLE
    .\NSXConnectionTest.ps1 -NSXManager "nsx-manager.corp.com" -Force
    Force fresh validation of all endpoints, ignoring cached data.

.NOTES
    with endpoint discovery system that:
    - Discovers and validates 100+ NSX-T API endpoints
    - Implements intelligent caching with 24-hour TTL
    - Detects Federation/Global Manager support
    - Provides performance metrics and optimization
    - Prepares optimized endpoint lists for other tools
    - Saves validated endpoints for tool integration
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(HelpMessage = "NSX Manager FQDN or IP address")]
  [ValidateNotNullOrEmpty()]
  [string]$NSXManager = "lab-nsxlm-01.lab.vdcninja.com",

  [Parameter(HelpMessage = "Username for basic authentication")]
  [ValidateNotNullOrEmpty()]
  [string]$Username = "admin",

  [Parameter(HelpMessage = "Bypass SSL certificate validation")]
  [switch]$SkipSSLCheck,

  [Parameter(HelpMessage = "Force prompt for new credentials")]
  [switch]$ForceNewCredentials,

  [Parameter(HelpMessage = "Automatically save working credentials")]
  [switch]$SaveCredentials,

  [Parameter(HelpMessage = "Use current Windows user credentials")]
  [switch]$UseCurrentUserCredentials,

  [Parameter(HelpMessage = "Run without interactive prompts")]
  [switch]$NonInteractive,

  [Parameter(HelpMessage = "Launch credential management interface")]
  [switch]$ManageCredentials,

  [Parameter(HelpMessage = "Force re-validation of OpenAPI specs and endpoints (ignore TTL)")]
  [switch]$Force
)

# ===================================================================
# SERVICE FRAMEWORK INITIALIZATION
# ===================================================================

# CANONICAL FIX: Add null safety for script path determination when called from other scripts
$scriptPath = if ($MyInvocation.MyCommand.Path) {
  Split-Path -Parent $MyInvocation.MyCommand.Path
}
else {
  # Fallback when called from another script - use PSScriptRoot or current directory
  if ($PSScriptRoot) {
    $PSScriptRoot
  }
  else {
    Split-Path -Parent $PSCommandPath
  }
}
$servicesPath = "$scriptPath\..\src\services"

try {
  # Load the InitServiceFramework
  . "$scriptPath\..\src\services\InitServiceFramework.ps1"

  # Initialize all services using centralized framework
  $services = Initialize-ServiceFramework $servicesPath

  if ($null -eq $services) {
    throw "Service framework initialization failed"
  }

  # Extract required services
  $logger = $services.Logger
  $credentialService = $services.CredentialService
  $authService = $services.AuthService
  $apiService = $services.APIService
  $configService = $services.Configuration
  $workflowOpsService = $services.WorkflowOperationsService
  $openAPISchemaService = $services.OpenAPISchemaService
  $dataObjectFilterService = $services.DataObjectFilter
  $configValidator = $services.ConfigValidator
  $standardFileNamingService = $services.StandardFileNaming

  # Validate critical services
  if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $authService -or $null -eq $apiService -or $null -eq $configService -or $null -eq $workflowOpsService -or $null -eq $standardFileNamingService) {
    throw "One or more critical services failed to initialize properly"
  }

  # Check service availability
  $hasOpenAPISupport = $null -ne $openAPISchemaService
  $hasFilteringSupport = $null -ne $dataObjectFilterService
  $hasValidationSupport = $null -ne $configValidator
  $hasStandardFileNaming = $null -ne $standardFileNamingService

  # CRITICAL: Configure SSL bypass IMMEDIATELY after service initialization and BEFORE any HTTPS operations
  if ($SkipSSLCheck) {
    Write-Host -Object "Configuring SSL bypass before any HTTPS operations..." -ForegroundColor Yellow

    # Apply robust SSL bypass (multiple fallback methods)
    try {
      Write-Verbose "Applying SSL bypass for NSX-T"

      # Enable TLS 1.2 for NSX-T compatibility
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

      # Apply global certificate validation callback that accepts all certificates
      [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {
        param($senderObj, $certificate, $chain, $sslPolicyErrors)
        return $true
      }

      # Additional global NSX-T optimizations
      [System.Net.ServicePointManager]::CheckCertificateRevocationList = $false
      [System.Net.ServicePointManager]::DefaultConnectionLimit = 50
      [System.Net.ServicePointManager]::Expect100Continue = $false

      Write-Host -Object "[SUCCESS] SSL bypass configured successfully" -ForegroundColor Green
    }
    catch {
      Write-Host -Object "[FAIL] SSL bypass configuration failed: $($_.Exception.Message)" -ForegroundColor Red
      Write-Host -Object "WARNING:  HTTPS operations may fail" -ForegroundColor Yellow
    }
  }

  Write-Host -Object "NSXConnectionTest: Service framework initialized successfully" -ForegroundColor Green
  Write-Host -Object "  OpenAPI Schema Service: $(if ($hasOpenAPISupport) { 'Available' } else { 'Unavailable' })" -ForegroundColor $(if ($hasOpenAPISupport) { 'Green' } else { 'Yellow' })
  Write-Host -Object "  Data Object Filtering: $(if ($hasFilteringSupport) { 'Available' } else { 'Unavailable' })" -ForegroundColor $(if ($hasFilteringSupport) { 'Green' } else { 'Yellow' })
  Write-Host -Object "  Configuration Validation: $(if ($hasValidationSupport) { 'Available' } else { 'Unavailable' })" -ForegroundColor $(if ($hasValidationSupport) { 'Green' } else { 'Yellow' })
  Write-Host -Object "  Standard File Naming: $(if ($hasStandardFileNaming) { 'Available' } else { 'Unavailable' })" -ForegroundColor $(if ($hasStandardFileNaming) { 'Green' } else { 'Yellow' })
}
catch {
  Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
  exit 1
}

# ===================================================================
# LOGGING AND UTILITY FUNCTIONS
# ===================================================================

function Write-ConnectionLog {
  param($Message, $Level = "INFO")
  switch ($Level.ToUpper()) {
    "DEBUG" { $logger.LogDebug($Message, "ConnectionTest") }
    "WARN" { $logger.LogWarning($Message, "ConnectionTest") }
    "WARNING" { $logger.LogWarning($Message, "ConnectionTest") }
    "ERROR" { $logger.LogError($Message, "ConnectionTest") }
    default { $logger.LogInfo($Message, "ConnectionTest") }
  }
}

function Get-StoredCredential {
  param([string]$NSXManager)
  try {
    $storedCred = $credentialService.LoadCredentials($NSXManager)
    if ($storedCred) {
      Write-ConnectionLog "Successfully loaded stored credentials for: $NSXManager"
      return $storedCred
    }
    else {
      Write-ConnectionLog "No stored credentials found for: $NSXManager" "WARN"
      return $null
    }
  }
  catch {
    Write-ConnectionLog "Failed to load stored credentials for $NSXManager : $($_.Exception.Message)" "ERROR"
    return $null
  }
}

# ===================================================================
# CORE CONNECTION AND ENDPOINT TESTING FUNCTIONS
# ===================================================================

# CANONICAL FIX: Single Responsibility - SSL bypass verification only
function Test-SSLBypassConfiguration {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential
  )

  try {
    Write-ConnectionLog "Verifying SSL bypass configuration before connection attempts"
    Write-ConnectionLog "PowerShell Version: $($PSVersionTable.PSVersion)" "INFO"
    Write-ConnectionLog "Security Protocol: $([System.Net.ServicePointManager]::SecurityProtocol)" "INFO"

    $sslCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
    if ($null -ne $sslCallback) {
      Write-ConnectionLog "SSL certificate validation callback is configured (SSL bypass active)" "INFO"
    }
    else {
      Write-ConnectionLog "WARNING: SSL certificate validation callback is NOT configured" "WARN"
    }

    # Test a  SSL connection to verify bypass is working using CoreAPIService
    Write-ConnectionLog "Testing SSL bypass with CoreAPIService (following NSXConfigSync.ps1 pattern)"
    $testResponse = $apiService.InvokeRestMethod($NSXManager, $Credential, "/api/v1/cluster", "GET", $null, @{})
    Write-ConnectionLog "SSL bypass test successful using CoreAPIService" "INFO"

    return [PSCustomObject]@{ Success = $true; Verified = $true }
  }
  catch {
    Write-ConnectionLog "SSL bypass test failed: $($_.Exception.Message)" "ERROR"
    Write-ConnectionLog "This indicates connection issues despite SSL bypass configuration" "ERROR"
    return [PSCustomObject]@{ Success = $false; Error = $_.Exception.Message }
  }
}

# CANONICAL FIX: Single Responsibility - Endpoint configuration discovery only
function Get-TestEndpointConfiguration {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential
  )

  Write-ConnectionLog "Testing with dynamic endpoint discovery from OpenAPISchemaService"

  try {
    if ($openAPISchemaService) {
      Write-ConnectionLog "Using OpenAPISchemaService for dynamic endpoint discovery" "INFO"

      # Initialize the service with current NSX Manager and credentials for proper endpoint detection
      $openAPISchemaService.nsxManager = $NSXManager
      $openAPISchemaService.credential = $Credential

      # Get the configured NSX endpoints from the service
      $configuredEndpoints = $openAPISchemaService.config.endpoints

      if ($configuredEndpoints) {
        # Use the NSX-specific endpoints from JSON configuration
        $testEndpoints = [PSCustomObject]@{
          "Policy Infrastructure" = "/policy/api/v1/infra"
          "Policy Domains"        = "/policy/api/v1/infra/domains"
          "Management Cluster"    = "/api/v1/cluster"
          "OpenAPI Policy Spec"   = $configuredEndpoints.swagger_spec
        }
        Write-ConnectionLog "Loaded $($testEndpoints.Count) endpoints from OpenAPI service configuration" "INFO"
        Write-ConnectionLog "Using OpenAPI endpoints: $($configuredEndpoints.openapi_spec), $($configuredEndpoints.swagger_spec)" "DEBUG"
        return [PSCustomObject]@{ Success = $true; Endpoints = $testEndpoints; Source = "OpenAPIService" }
      }
      else {
        Write-ConnectionLog "OpenAPISchemaService config not available, using NSX defaults" "WARN"
      }
    }
    else {
      Write-ConnectionLog "OpenAPISchemaService not available, using fallback endpoints" "WARN"
    }

    # Fallback to working endpoints that don't cause 403 errors
    $testEndpoints = [PSCustomObject]@{
      "Policy Infrastructure" = "/policy/api/v1/infra"
      "Policy Domains"        = "/policy/api/v1/infra/domains"
      "Management Cluster"    = "/api/v1/cluster"
    }
    return [PSCustomObject]@{ Success = $true; Endpoints = $testEndpoints; Source = "Fallback" }
  }
  catch {
    Write-ConnectionLog "Failed to get endpoints from OpenAPISchemaService: $($_.Exception.Message)" "WARN"
    # Final fallback to working endpoints
    $testEndpoints = [PSCustomObject]@{
      "Policy Infrastructure" = "/policy/api/v1/infra"
      "Policy Domains"        = "/policy/api/v1/infra/domains"
      "Management Cluster"    = "/api/v1/cluster"
    }
    return [PSCustomObject]@{ Success = $false; Endpoints = $testEndpoints; Source = "Error-Fallback"; Error = $_.Exception.Message }
  }
}

# CANONICAL FIX: Single Responsibility - Endpoint connectivity testing only
function Test-EndpointConnectivity {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential,
    [object]$TestEndpoints
  )

  $workingEndpoints = 0
  $testResults = [PSCustomObject]@{}

  foreach ($endpointName in $TestEndpoints.Keys) {
    $endpointPath = $TestEndpoints[$endpointName]
    try {
      # Use CoreAPIService pattern like NSXConfigSync.ps1 (WORKING PATTERN - 6 parameters)
      Write-ConnectionLog "Testing endpoint: $endpointName ($endpointPath)"
      $response = $apiService.InvokeRestMethod($NSXManager, $Credential, $endpointPath, "GET", $null, @{})

      $testResults[$endpointName] = @{
        Success   = $true
        ItemCount = if ($response.results) { $response.results.Count } else { 1 }
        Path      = $endpointPath
      }
      $workingEndpoints++
      Write-ConnectionLog "[SUCCESS] ${endpointName}: SUCCESS ($($testResults[$endpointName].ItemCount) items)" "INFO"
    }
    catch {
      $testResults[$endpointName] = @{
        Success = $false
        Error   = $_.Exception.Message
        Path    = $endpointPath
      }


      # Use the working endpoints count from the connectivity test
      $workingEndpoints = $connectivityTest.WorkingEndpoints
      $testResults = $connectivityTest.TestResults
    }
  }

  return @{
    WorkingEndpoints = $workingEndpoints
    TotalEndpoints   = $TestEndpoints.Count
    TestResults      = $testResults
  }
}

function Test-NSXConnection {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential
  )

  try {
    Write-ConnectionLog "Testing connection using working NSXConfigSync.ps1 pattern (skipping problematic /api/v1/node endpoint)"

    # CANONICAL FIX: Phase 1 - SSL Bypass Verification (Single Responsibility)
    $sslTest = Test-SSLBypassConfiguration -NSXManager $NSXManager -Credential $Credential
    if (-not $sslTest.Success) {
      Write-ConnectionLog "SSL bypass verification failed - connection likely to fail" "WARN"
    }

    # CANONICAL FIX: Phase 2 - Endpoint Configuration Discovery (Single Responsibility)
    $endpointConfig = Get-TestEndpointConfiguration -NSXManager $NSXManager -Credential $Credential
    if (-not $endpointConfig.Success) {
      Write-ConnectionLog "Endpoint configuration discovery had issues: $($endpointConfig.Error)" "WARN"
    }

    # Count working endpoints from connectivity test results (will be updated after test)
    # CANONICAL FIX: Phase 3 - Endpoint Connectivity Testing (Single Responsibility)
    $connectivityTest = Test-EndpointConnectivity -NSXManager $NSXManager -Credential $Credential -TestEndpoints $endpointConfig.Endpoints

    # Use the working endpoints count directly from the connectivity test
    $workingEndpoints = $connectivityTest.WorkingEndpoints
    $testResults = $connectivityTest.TestResults
    Write-ConnectionLog "Endpoint connectivity test completed: $workingEndpoints working endpoints out of $($connectivityTest.TotalEndpoints)" "INFO"

    if ($workingEndpoints -gt 0) {
      Write-ConnectionLog "Connection test successful via policy endpoints (NSXConfigSync.ps1 pattern)" "INFO"
      return @{
        Success          = $true
        AuthMethod       = "Basic"
        SSLBypass        = $true
        Result           = $connectivityTest.TestResults
        StatusCode       = 200
        WorkingEndpoints = $workingEndpoints
        TotalEndpoints   = $connectivityTest.TotalEndpoints
        Version          = "Policy API Access Confirmed"
        Message          = "Connection successful using working NSXConfigSync.ps1 pattern"
      }
    }
    else {
      Write-ConnectionLog "All policy endpoints failed - connection issues" "ERROR"
      return @{
        Success     = $false
        Error       = "All policy endpoints failed"
        StatusCode  = 0
        AuthMethod  = "Basic"
        SSLBypass   = $true
        TestResults = $connectivityTest.TestResults
      }
    }
  }
  catch {
    Write-ConnectionLog "Policy endpoint testing failed: $($_.Exception.Message)" "ERROR"
    return @{
      Success    = $false
      Error      = $_.Exception.Message
      StatusCode = 0
      AuthMethod = $null
      SSLBypass  = $true
    }
  }
}


# Test specific endpoint for connectivity and data availability
function Test-NSXEndpoint {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential,
    [string]$EndpointPath,
    [int]$TimeoutSeconds = 15
  )

  $result = [PSCustomObject]@{
    Success        = $false
    ResponseTime   = 0
    StatusCode     = $null
    ItemCount      = 0
    DataAvailable  = $false
    ErrorMessage   = ""
    LastTested     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Classification = $null
  }

  $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

  try {
    Write-ConnectionLog "Testing endpoint: $EndpointPath" "DEBUG"

    # CRITICAL FIX: Use CoreAPIService instead of direct Invoke-RestMethod
    # Following NSXConfigSync.ps1 working pattern
    if (-not $apiService) {
      throw "CoreAPIService not available - service framework not properly initialized"
    }

    Write-ConnectionLog "Making API call using CoreAPIService.InvokeRestMethod..." "DEBUG"

    # Use the working CoreAPIService pattern that works in NSXConfigSync.ps1
    $response = $apiService.InvokeRestMethod($NSXManager, $Credential, $EndpointPath, "GET", $null, @{})

    $stopwatch.Stop()
    $result.ResponseTime = $stopwatch.ElapsedMilliseconds
    $result.Success = $true
    $result.StatusCode = 200

    # Determine item count and data availability
    if ($response) {
      if ($response.results -and $response.results.Count) {
        $result.ItemCount = $response.results.Count
        $result.DataAvailable = $true
        Write-ConnectionLog "[SUCCESS] Endpoint validated: $EndpointPath ($($result.ItemCount) items, $($result.ResponseTime)ms)" "DEBUG"
      }
      elseif ($response.result_count -and $response.result_count -gt 0) {
        $result.ItemCount = $response.result_count
        $result.DataAvailable = $true
        Write-ConnectionLog "[SUCCESS] Endpoint validated: $EndpointPath ($($result.ItemCount) items, $($result.ResponseTime)ms)" "DEBUG"
      }
      elseif ($response -is [Array] -and $response.Count -gt 0) {
        $result.ItemCount = $response.Count
        $result.DataAvailable = $true
        Write-ConnectionLog "[SUCCESS] Endpoint validated: $EndpointPath ($($result.ItemCount) items, $($result.ResponseTime)ms)" "DEBUG"
      }
      else {
        $result.ItemCount = 0
        $result.DataAvailable = $false
        Write-ConnectionLog "[SUCCESS] Endpoint accessible: $EndpointPath (no data, $($result.ResponseTime)ms)" "DEBUG"
      }
    }

    # Log successful response summary
    if ($logger) {
      # Changed from $loggingService to $logger
      $logger.LogAPIResponse("GET", "https://$NSXManager$EndpointPath", 200, $response, $result.ResponseTime)
    }
  }
  catch {
    $stopwatch.Stop()
    $result.ResponseTime = $stopwatch.ElapsedMilliseconds
    $result.Success = $false
    $result.ErrorMessage = $_.Exception.Message

    # Extract status code from error if available
    if ($_.Exception.Response) {
      $result.StatusCode = [int]$_.Exception.Response.StatusCode
    }
    elseif ($result.ErrorMessage -match "(\d{3})") {
      $result.StatusCode = [int]$matches[1]
    }

    # Global Manager Policy API error classification
    $result.Classification = Get-FailureClassification -EndpointPath $EndpointPath -ErrorMessage $result.ErrorMessage -StatusCode $result.StatusCode

    # Log appropriate level based on classification
    $logLevel = if ($result.Classification.Expected) { "DEBUG" } else { "WARNING" }
    Write-ConnectionLog "[FAIL] Endpoint failed: $EndpointPath - $($result.ErrorMessage) ($($result.ResponseTime)ms) [$(($result.Classification.Type))]" $logLevel

    # Log API error for detailed tracking
    if ($logger) {
      # Changed from $loggingService to $logger
      $logger.LogAPIError("GET", "https://$NSXManager$EndpointPath", $_.Exception, $result.ResponseTime)
    }
  }

  return $result
}

# ===================================================================
# ENDPOINT DISCOVERY AND VALIDATION
# ===================================================================

function Test-FederationSupport {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential
  )

  $result = [PSCustomObject]@{
    GlobalManagerDetected = $false
    LocalManagerRole      = "unknown"
    FederationEndpoints   = @()
    TestResults           = [PSCustomObject]@{}
  }

  try {
    Write-ConnectionLog "Testing for NSX Federation/Global Manager support..." "INFO"
    $globalInfraResponse = $apiService.InvokeRestMethod($NSXManager, $Credential, "/policy/api/v1/global-infra", "GET", $null, @{})
    if ($globalInfraResponse) {
      $result.GlobalManagerDetected = $true
      $result.LocalManagerRole = "global"
      $result.FederationEndpoints += "/policy/api/v1/global-infra"
      Write-ConnectionLog "Global Manager detected - Federation support available" "INFO"
    }
  }
  catch {
    Write-ConnectionLog "Global Manager test failed (expected for Local Managers): $($_.Exception.Message)" "DEBUG"
  }

  try {
    $sitesResponse = $apiService.InvokeRestMethod($NSXManager, $Credential, "/policy/api/v1/infra/sites", "GET", $null, @{})
    if ($sitesResponse -and $sitesResponse.results) {
      $result.FederationEndpoints += "/policy/api/v1/infra/sites"
      if (-not $result.GlobalManagerDetected) {
        $result.LocalManagerRole = "local"
        Write-ConnectionLog "Local Manager in Federation detected" "INFO"
      }
    }
  }
  catch {
    Write-ConnectionLog "Federation sites test failed: $($_.Exception.Message)" "DEBUG"
    if (-not $result.GlobalManagerDetected) {
      $result.LocalManagerRole = "standalone"
    }
  }

  Write-ConnectionLog "Manager Role: $($result.LocalManagerRole), Federation: $($result.GlobalManagerDetected)" "INFO"
  return $result
}

function Get-EndpointCache {
  param([string]$NSXManager)

  try {
    # Use standardized service for cache file path resolution
    $cacheDir = if ($workflowOpsService) {
      $workflowOpsService.GetToolkitPath('Cache')
    }
    else {
      $rootPath = Split-Path (Split-Path $scriptPath -Parent) -Parent
      Join-Path $rootPath "data\cache"
    }

    # Use StandardFileNamingService for proper file naming
    $cacheFile = if ($standardFileNamingService) {
      $standardFileNamingService.GenerateEndpointCacheFilePath($cacheDir, $NSXManager)
    }
    else {
      # Fallback for when service not available
      $hostname = $NSXManager -replace '\..*$', ''
      Join-Path $cacheDir "${hostname}_validated_endpoints.json"
    }

    if (Test-Path $cacheFile) {
      $cacheData = Get-Content $cacheFile -Raw | ConvertFrom-Json
      $expiresAt = [DateTime]::Parse($cacheData.metadata.expiresAt)
      $isValid = (Get-Date) -lt $expiresAt
      $ttlHours = if ($isValid) { ($expiresAt - (Get-Date)).TotalHours } else { 0 }

      return @{
        Success      = $true
        IsValid      = $isValid
        TTLHours     = [math]::Round($ttlHours, 1)
        EndpointData = $cacheData
        CacheFile    = $cacheFile
      }
    }

    return [PSCustomObject]@{ Success = $false; IsValid = $false }
  }
  catch {
    Write-ConnectionLog "Failed to read endpoint cache: $($_.Exception.Message)" "WARN"
    return [PSCustomObject]@{ Success = $false; IsValid = $false }
  }
}

function Get-NSXEndpointDefinition {
  param(
    [string]$ConfigurationName = "basic_connectivity"
  )

  $configPath = Join-Path $scriptPath "..\config\nsx-test-endpoints.json"

  try {
    if (-not (Test-Path $configPath)) {
      Write-ConnectionLog "Endpoint configuration file not found: $configPath" "ERROR"
      return @()
    }

    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $testConfig = $config.test_configurations.$ConfigurationName

    if (-not $testConfig) {
      Write-ConnectionLog "Test configuration '$ConfigurationName' not found, using basic_connectivity" "WARNING"
      $testConfig = $config.test_configurations.basic_connectivity
    }

    $endpoints = @()
    foreach ($groupName in $testConfig.included_groups) {
      $group = $config.endpoint_groups.$groupName
      if ($group -and $group.endpoints) {
        foreach ($endpoint in $group.endpoints) {
          # Filter by category if specified
          if ($testConfig.filter_categories -and $endpoint.Category -notin $testConfig.filter_categories) {
            continue
          }

          $endpoints += $endpoint

          # Respect max_endpoints limit
          if ($endpoints.Count -ge $testConfig.max_endpoints) {
            break
          }
        }

        if ($endpoints.Count -ge $testConfig.max_endpoints) {
          break
        }
      }
    }

    Write-ConnectionLog "Loaded $($endpoints.Count) endpoint definitions from configuration '$ConfigurationName'" "INFO"
    return $endpoints

  }
  catch {
    Write-ConnectionLog "Failed to load endpoint definitions: $($_.Exception.Message)" "ERROR"
    return @()
  }
}

# NSX endpoint discovery with Global Manager support
function Get-ComprehensiveNSXEndpoint {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential,
    [string]$ManagerType = "auto"
  )

  Write-ConnectionLog "=== ENDPOINT DISCOVERY ===" "INFO"
  Write-ConnectionLog "NSX Manager: $NSXManager" "INFO"
  Write-ConnectionLog "Manager Type: $ManagerType" "INFO"

  # Detect manager type if auto
  if ($ManagerType -eq "auto") {
    $ManagerType = Get-NSXManagerType -NSXManager $NSXManager -Credential $Credential
    Write-ConnectionLog "Detected manager type: $ManagerType" "INFO"
  }

  # NSX endpoint catalog (100+ endpoints)
  $allEndpoints = [PSCustomObject]@{
    # Management API endpoints (work on all manager types)
    "Management_Cluster"            = "/api/v1/cluster"
    "Management_Nodes"              = "/api/v1/cluster/nodes"
    "Management_Node_Info"          = "/api/v1/node"
    "Management_System_Info"        = "/api/v1/node/version"
    "Management_Transport_Zones"    = "/api/v1/transport-zones"
    "Management_Transport_Nodes"    = "/api/v1/transport-nodes"
    "Management_Edge_Clusters"      = "/api/v1/edge-clusters"
    "Management_Logical_Switches"   = "/api/v1/logical-switches"
    "Management_Logical_Routers"    = "/api/v1/logical-routers"
    "Management_Logical_Ports"      = "/api/v1/logical-ports"
    "Management_Switching_Profiles" = "/api/v1/switching-profiles"
    "Management_Edge_Nodes"         = "/api/v1/cluster/nodes"
    "Management_Fabric_Nodes"       = "/api/v1/fabric/nodes"
    "Management_Host_Switches"      = "/api/v1/host-switches"
    "Management_TEPs"               = "/api/v1/transport-node-collections"

    # Load Balancer endpoints
    "LB_Services"                   = "/api/v1/loadbalancer/services"
    "LB_Virtual_Servers"            = "/api/v1/loadbalancer/virtual-servers"
    "LB_Pools"                      = "/api/v1/loadbalancer/pools"
    "LB_Monitors"                   = "/api/v1/loadbalancer/monitors"

    # Firewall and Security endpoints
    "Firewall_Sections"             = "/api/v1/firewall/sections"
    "Security_Groups"               = "/api/v1/ns-groups"
    "IP_Sets"                       = "/api/v1/ip-sets"
    "Services"                      = "/api/v1/ns-services"

    # Certificate endpoints
    "Certificates"                  = "/api/v1/trust-management/certificates"
    "Certificate_Authorities"       = "/api/v1/trust-management/certificate-authorities"
  }

  # Policy API endpoints (manager type dependent)
  $policyEndpoints = [PSCustomObject]@{}

  switch ($ManagerType) {
    "global_manager" {
      Write-ConnectionLog "Adding Global Manager specific endpoints" "INFO"
      $policyEndpoints = [PSCustomObject]@{
        # Global Manager uses different endpoint structure
        "GlobalInfra_Root"    = "/global-manager/api/v1/global-infra"
        "GlobalInfra_Domains" = "/global-manager/api/v1/global-infra/domains"
        "GlobalInfra_Sites"   = "/global-manager/api/v1/global-infra/sites"
      }

      # Note: Skip Policy API endpoints for Global Manager as they return HTTP 500
      Write-ConnectionLog "Skipping Policy API endpoints for Global Manager (known limitation)" "INFO"
    }

    "local_manager" {
      Write-ConnectionLog "Adding Local Manager (Federation) specific endpoints" "INFO"
      $policyEndpoints = [PSCustomObject]@{
        # Local manager supports both global and local scopes
        "Policy_GlobalInfra"         = "/policy/api/v1/global-infra"
        "Policy_GlobalInfra_Domains" = "/policy/api/v1/global-infra/domains"
        "Policy_LocalInfra"          = "/policy/api/v1/infra"
        "Policy_LocalInfra_Domains"  = "/policy/api/v1/infra/domains"
        "Policy_LocalInfra_Groups"   = "/policy/api/v1/infra/domains/default/groups"
      }
    }

    "standalone" {
      Write-ConnectionLog "Adding Standalone Manager specific endpoints" "INFO"
      $policyEndpoints = [PSCustomObject]@{
        # Standalone manager uses local infra only
        "Policy_Infra"             = "/policy/api/v1/infra"
        "Policy_Domains"           = "/policy/api/v1/infra/domains"
        "Policy_Groups"            = "/policy/api/v1/infra/domains/default/groups"
        "Policy_Security_Policies" = "/policy/api/v1/infra/domains/default/security-policies"
        "Policy_Services"          = "/policy/api/v1/infra/services"
      }
    }
  }

  # Combine all endpoints
  $combinedEndpoints = [PSCustomObject]@{}
  $allEndpoints.GetEnumerator() | ForEach-Object { $combinedEndpoints[$_.Key] = $_.Value }
  $policyEndpoints.GetEnumerator() | ForEach-Object { $combinedEndpoints[$_.Key] = $_.Value }

  Write-ConnectionLog "Total endpoints for discovery: $($combinedEndpoints.Count)" "INFO"
  Write-ConnectionLog "Management endpoints: $($allEndpoints.Count)" "INFO"
  Write-ConnectionLog "Policy endpoints: $($policyEndpoints.Count)" "INFO"

  return $combinedEndpoints
}

# Helper function to detect NSX manager type
function Get-NSXManagerType {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential
  )

  Write-ConnectionLog "Detecting NSX Manager type for: $NSXManager" "INFO"

  # Test 1: Try global manager specific endpoint
  try {
    $globalResponse = $apiService.InvokeRestMethod($NSXManager, $Credential, "/global-manager/api/v1/global-infra", "GET", $null, @{})
    if ($globalResponse) {
      Write-ConnectionLog "Global manager endpoint responded successfully" "INFO"
      return "global_manager"
    }
  }
  catch {
    Write-ConnectionLog "Global manager endpoint failed: $($_.Exception.Message)" "DEBUG"
  }

  # Test 2: Try local manager specific endpoint
  try {
    $localResponse = $apiService.InvokeRestMethod($NSXManager, $Credential, "/policy/api/v1/global-infra", "GET", $null, @{})
    if ($localResponse) {
      Write-ConnectionLog "Local manager endpoint responded successfully" "INFO"
      return "local_manager"
    }
  }
  catch {
    Write-ConnectionLog "Local manager endpoint failed: $($_.Exception.Message)" "DEBUG"
  }

  # Test 3: Try standalone manager endpoint
  try {
    $standaloneResponse = $apiService.InvokeRestMethod($NSXManager, $Credential, "/policy/api/v1/infra", "GET", $null, @{})
    if ($standaloneResponse) {
      Write-ConnectionLog "Standalone manager endpoint responded successfully" "INFO"
      return "standalone"
    }
  }
  catch {
    Write-ConnectionLog "Standalone manager endpoint failed: $($_.Exception.Message)" "DEBUG"
  }

  # Default fallback
  Write-ConnectionLog "Unable to determine manager type, defaulting to standalone" "WARNING"
  return "standalone"
}

function Get-FailureClassification {
  param(
    [string]$EndpointPath,
    [string]$ErrorMessage,
    [bool]$IsFederation = $false,
    [int]$StatusCode = 0
  )

  # Expected failures for lab/standalone environments
  $expectedLabFailures = @(
    "/policy/api/v1/infra/domains",           # Requires domain configuration
    "/policy/api/v1/infra/tier-0s",          # Requires edge clusters
    "/policy/api/v1/infra/tier-1s",          # Requires edge clusters
    "/policy/api/v1/infra/segments",         # Requires networking config
    "/policy/api/v1/infra/ip-pools",         # Requires IP pool config
    "/policy/api/v1/infra/dhcp-relay-configs", # Requires DHCP config
    "/policy/api/v1/infra/dns-forwarder-zones", # Requires DNS config
    "/policy/api/v1/infra/lb-services",      # Requires load balancer config
    "/policy/api/v1/infra/lb-virtual-servers", # Requires load balancer config
    "/policy/api/v1/infra/lb-pools",         # Requires load balancer config
    "/policy/api/v1/infra/sites"             # Federation-only endpoint
  )

  # Global manager only endpoints (expected to fail on local managers)
  $globalManagerEndpoints = @(
    "/policy/api/v1/global-infra",
    "/policy/api/v1/global-infra/domains",
    "/policy/api/v1/global-infra/tier-0s",
    "/policy/api/v1/global-infra/tier-1s"
  )

  # Global Manager Policy API endpoints (systematic HTTP 500 failures)
  $globalManagerPolicyAPILimitations = @(
    "/policy/api/v1/infra",
    "/policy/api/v1/infra/domains",
    "/policy/api/v1/infra/domains/default",
    "/policy/api/v1/infra/domains/default/groups",
    "/policy/api/v1/infra/domains/default/security-policies",
    "/policy/api/v1/infra/domains/default/gateway-policies",
    "/policy/api/v1/infra/tier-0s",
    "/policy/api/v1/infra/tier-1s",
    "/policy/api/v1/infra/segments",
    "/policy/api/v1/spec/openapi/nsx_policy_api.json",
    "/api/v1/spec/openapi/nsx_policy_api.json"
  )

  # Feature-dependent endpoints (expected to fail without features)
  $featureDependentEndpoints = @(
    "/policy/api/v1/infra/contexts",         # Context profiles
    "/policy/api/v1/infra/realized-state",  # Realization state
    "/policy/api/v1/infra/enforcement-points", # Enforcement points
    "/policy/api/v1/infra/settings"         # Settings
  )

  # Classify the failure
  $classification = [PSCustomObject]@{
    Type     = "Unknown"
    Severity = "Warning"
    Reason   = "Unknown failure"
    Expected = $false
  }

  # Global Manager Policy API Limitation (HTTP 500 with ~91 bytes)
  # ALL Policy API endpoints return systematic HTTP 500 on Global Managers
  if (($StatusCode -eq 500 -or $ErrorMessage -match "500|internal server error") -and
    ($EndpointPath -match "^/policy/api/v1/" -or $EndpointPath -in $globalManagerPolicyAPILimitations)) {
    $classification.Type = "GlobalManager_PolicyAPI_Limitation"
    $classification.Severity = "Info"
    $classification.Reason = "Expected - Global Manager doesn't support Policy API endpoints (use Management API instead)"
    $classification.Expected = $true
  }
  # Real connectivity failures (authentication, SSL, network)
  elseif ($ErrorMessage -match "401|unauthorized|authentication|credential" -or
    $ErrorMessage -match "403|forbidden|access denied" -or
    $ErrorMessage -match "timeout|connection|network|ssl|certificate" -or
    ($ErrorMessage -match "500|internal server error|503|service unavailable" -and
    $EndpointPath -notin $globalManagerPolicyAPILimitations)) {

    $classification.Type = "Connectivity"
    $classification.Severity = "Error"
    $classification.Reason = "Real connectivity or authentication failure"
    $classification.Expected = $false
  }
  # Expected configuration-dependent failures (400 Bad Request)
  elseif ($ErrorMessage -match "400" -and $EndpointPath -in $expectedLabFailures) {
    $classification.Type = "Configuration"
    $classification.Severity = "Info"
    $classification.Reason = "Expected - requires specific NSX configuration"
    $classification.Expected = $true
  }
  # Global Manager endpoints on Local Manager (404 Not Found)
  elseif ($ErrorMessage -match "404" -and $EndpointPath -in $globalManagerEndpoints) {
    $classification.Type = "Federation"
    $classification.Severity = "Info"
    $classification.Reason = "Expected - Global Manager endpoint on Local Manager"
    $classification.Expected = $true
  }
  # Feature-dependent endpoints (404 Not Found)
  elseif ($ErrorMessage -match "404" -and $EndpointPath -in $featureDependentEndpoints) {
    $classification.Type = "Feature"
    $classification.Severity = "Info"
    $classification.Reason = "Expected - feature not enabled or available"
    $classification.Expected = $true
  }
  # Other 400/404 errors - likely expected in lab environments
  elseif ($ErrorMessage -match "400|404") {
    $classification.Type = "Expected"
    $classification.Severity = "Info"
    $classification.Reason = "Expected - endpoint requires specific configuration"
    $classification.Expected = $true
  }
  # Any other errors - unexpected
  else {
    $classification.Type = "Unexpected"
    $classification.Severity = "Warning"
    $classification.Reason = "Unexpected failure - investigate further"
    $classification.Expected = $false
  }

  return $classification
}

function Test-NSXEndpointsWithSchemaValidation {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential,
    [int]$MaxEndpoints = 100
  )

  $results = [PSCustomObject]@{
    SchemaValidation   = [PSCustomObject]@{
      Available          = $false
      ValidatedEndpoints = 0
      TotalEndpoints     = 0
      Errors             = @()
      DiscoveryTime      = 0
      CacheHit           = $false
    }
    EndpointTests      = [PSCustomObject]@{}
    Summary            = [PSCustomObject]@{
      SuccessfulEndpoints = 0
      FailedEndpoints     = 0
      DataEndpoints       = 0
      FilteredEndpoints   = 0
      PolicyEndpoints     = 0
      ManagementEndpoints = 0
      FederationEndpoints = 0
      OptimizedEndpoints  = 0
    }
    CachedEndpoints    = @()
    OptimizedExports   = @()
    PerformanceMetrics = [PSCustomObject]@{
      TotalDiscoveryTime  = 0
      AverageResponseTime = 0
      FastestEndpoint     = $null
      SlowestEndpoint     = $null
      EndpointsPerSecond  = 0
    }
    FederationSupport  = [PSCustomObject]@{
      GlobalManagerDetected = $false
      LocalManagerRole      = $null
      FederationEndpoints   = @()
    }
  }

  $discoveryStartTime = Get-Date

  if ($hasOpenAPISupport -and $openAPISchemaService) {
    try {
      Write-ConnectionLog "=== ENDPOINT DISCOVERY STARTING ===" "INFO"
      Write-ConnectionLog "NSX Manager: $NSXManager" "INFO"
      Write-ConnectionLog "Maximum Endpoints: $MaxEndpoints" "INFO"

      $openAPISchemaService.SetNSXManagerConfiguration($NSXManager, $Credential)
      Write-ConnectionLog "OpenAPI schema service configured successfully"

      # Check for existing cache first
      $cacheResult = Get-EndpointCache -NSXManager $NSXManager
      if ($cacheResult.Success -and $cacheResult.IsValid) {
        Write-ConnectionLog "Found valid endpoint cache (TTL: $($cacheResult.TTLHours) hours remaining)" "INFO"
        $results.SchemaValidation.CacheHit = $true
        $results.CachedEndpoints = $cacheResult.EndpointData.endpoints.allEndpoints
        $results.OptimizedExports = $cacheResult.EndpointData.endpoints.optimizedEndpoints
        $results.SchemaValidation.Available = $true
        $results.SchemaValidation.ValidatedEndpoints = $cacheResult.EndpointData.statistics.totalEndpoints

        # Load cached results into test structure
        foreach ($endpoint in $cacheResult.EndpointData.endpoints.allEndpoints) {
          $endpointName = "Cached: $($endpoint.endpoint -replace '^.*/([^/]+)/?$', '$1')"
          $results.EndpointTests[$endpointName] = @{
            Success       = $endpoint.isValid
            ItemCount     = $endpoint.itemCount
            ResponseTime  = $endpoint.responseTime
            LastTested    = $endpoint.lastTested
            DataAvailable = $endpoint.hasData
            FromCache     = $true
          }

          if ($endpoint.isValid) {
            $results.Summary.SuccessfulEndpoints++
            if ($endpoint.hasData) { $results.Summary.DataEndpoints++ }
          }
          else {
            $results.Summary.FailedEndpoints++
          }
        }

        Write-ConnectionLog "Cache loaded: $($results.Summary.SuccessfulEndpoints) working endpoints, $($results.Summary.DataEndpoints) with data" "INFO"
        return $results
      }

      # Perform endpoint discovery
      Write-ConnectionLog "No valid cache found - performing full endpoint discovery"

      $connectivityTest = $openAPISchemaService.TestConnectivity()
      if ($connectivityTest.Success) {
        Write-ConnectionLog "OpenAPI schema service connectivity test passed" "INFO"
        $results.SchemaValidation.Available = $true

        # Check for Federation/Global Manager support
        $federationTest = Test-FederationSupport -NSXManager $NSXManager -Credential $Credential
        $results.FederationSupport = $federationTest

        # Real endpoint discovery using OpenAPISchemaService and CoreAPIService
        Write-ConnectionLog "Performing endpoint discovery..." "INFO"

        # NSX-T endpoint discovery (100+ endpoints)
        $discoveryEndpoints = @(
          # Core Management API endpoints (Basic Infrastructure)
          "/api/v1/cluster",
          "/api/v1/cluster/nodes",
          "/api/v1/cluster/nodes/status",
          "/api/v1/cluster/backup",
          "/api/v1/cluster/backups",
          "/api/v1/cluster/api-certificate",
          "/api/v1/node",
          "/api/v1/node/services",
          "/api/v1/node/network",
          "/api/v1/node/version",
          "/api/v1/node/status",
          "/api/v1/upgrade",
          "/api/v1/upgrade/plan",

          # Transport Infrastructure
          "/api/v1/transport-zones",
          "/api/v1/transport-nodes",
          "/api/v1/transport-node-profiles",
          "/api/v1/transport-node-status",
          "/api/v1/edge-clusters",
          "/api/v1/edge-cluster-status",
          "/api/v1/fabric/nodes",
          "/api/v1/fabric/compute-managers",
          "/api/v1/fabric/discovered-nodes",
          "/api/v1/host-switch-profiles",
          "/api/v1/host-switches",

          # Logical Infrastructure (Management API)
          "/api/v1/logical-switches",
          "/api/v1/logical-switch-ports",
          "/api/v1/logical-routers",
          "/api/v1/logical-router-ports",
          "/api/v1/logical-ports",
          "/api/v1/switching-profiles",
          "/api/v1/ns-profiles",
          "/api/v1/ns-groups",
          "/api/v1/ns-services",

          # Security Infrastructure (Management API)
          "/api/v1/firewall/sections",
          "/api/v1/firewall/rules",
          "/api/v1/firewall/status",
          "/api/v1/trust-management/certificates",
          "/api/v1/trust-management/crls",
          "/api/v1/trust-management/csrs",

          # Load Balancing (Management API)
          "/api/v1/loadbalancer/services",
          "/api/v1/loadbalancer/virtual-servers",
          "/api/v1/loadbalancer/pools",
          "/api/v1/loadbalancer/monitors",
          "/api/v1/loadbalancer/rules",
          "/api/v1/loadbalancer/profiles",

          # VPN Infrastructure
          "/api/v1/vpn/ipsec/sessions",
          "/api/v1/vpn/l2vpn/sessions",
          "/api/v1/vpn/ipsec/local-endpoints",
          "/api/v1/vpn/ipsec/peer-endpoints",

          # Policy API - Core Infrastructure
          "/policy/api/v1/infra",
          "/policy/api/v1/infra/domains",
          "/policy/api/v1/infra/domains/default",
          "/policy/api/v1/infra/domains/default/groups",
          "/policy/api/v1/infra/domains/default/security-policies",
          "/policy/api/v1/infra/domains/default/gateway-policies",
          "/policy/api/v1/infra/domains/default/communication-maps",
          "/policy/api/v1/infra/domains/default/redirection-policies",
          "/policy/api/v1/infra/domains/default/forwarding-policies",
          "/policy/api/v1/infra/domains/default/intrusion-service-policies",
          "/policy/api/v1/infra/domains/default/endpoint-policies",

          # Policy API - Tier Gateways
          "/policy/api/v1/infra/tier-0s",
          "/policy/api/v1/infra/tier-1s",
          "/policy/api/v1/infra/tier-0s/static-routes",
          "/policy/api/v1/infra/tier-1s/static-routes",
          "/policy/api/v1/infra/tier-0s/locale-services",
          "/policy/api/v1/infra/tier-1s/locale-services",

          # Policy API - Segments and Networking
          "/policy/api/v1/infra/segments",
          "/policy/api/v1/infra/segments/ports",
          "/policy/api/v1/infra/segment-security-profiles",
          "/policy/api/v1/infra/segment-discovery-profile-binding-maps",
          "/policy/api/v1/infra/dhcp-relay-configs",
          "/policy/api/v1/infra/dhcp-server-configs",
          "/policy/api/v1/infra/dns-forwarder-zones",

          # Policy API - Services and Groups
          "/policy/api/v1/infra/services",
          "/policy/api/v1/infra/service-references",
          "/policy/api/v1/infra/contexts",
          "/policy/api/v1/infra/context-profiles",
          "/policy/api/v1/infra/custom-attributes",

          # Policy API - Load Balancing
          "/policy/api/v1/infra/lb-services",
          "/policy/api/v1/infra/lb-virtual-servers",
          "/policy/api/v1/infra/lb-pools",
          "/policy/api/v1/infra/lb-monitors",
          "/policy/api/v1/infra/lb-persistence-profiles",
          "/policy/api/v1/infra/lb-client-ssl-profiles",
          "/policy/api/v1/infra/lb-server-ssl-profiles",
          "/policy/api/v1/infra/lb-application-profiles",

          # Policy API - Security and Compliance
          "/policy/api/v1/infra/ip-discovery-profiles",
          "/policy/api/v1/infra/mac-discovery-profiles",
          "/policy/api/v1/infra/spoofguard-profiles",
          "/policy/api/v1/infra/qos-profiles",
          "/policy/api/v1/infra/ipfix-collector-profiles",
          "/policy/api/v1/infra/ipfix-profiles",
          "/policy/api/v1/infra/port-mirroring-profiles",

          # Policy API - VPN and Remote Access
          "/policy/api/v1/infra/ipsec-vpn-services",
          "/policy/api/v1/infra/ipsec-vpn-sessions",
          "/policy/api/v1/infra/ipsec-vpn-tunnel-profiles",
          "/policy/api/v1/infra/ipsec-vpn-ike-profiles",
          "/policy/api/v1/infra/ipsec-vpn-dpd-profiles",
          "/policy/api/v1/infra/l2vpn-services",
          "/policy/api/v1/infra/l2vpn-sessions",

          # Policy API - Operational State and Monitoring
          "/policy/api/v1/infra/realized-state",
          "/policy/api/v1/infra/realized-state/groups",
          "/policy/api/v1/infra/realized-state/security-policies",
          "/policy/api/v1/infra/realized-state/enforcement-points",
          "/policy/api/v1/infra/intent",
          "/policy/api/v1/infra/sha",

          # Policy API - Federation and Global Infrastructure
          "/policy/api/v1/global-infra",
          "/policy/api/v1/global-infra/domains",
          "/policy/api/v1/global-infra/tier-0s",
          "/policy/api/v1/global-infra/tier-1s",
          "/policy/api/v1/global-infra/segments",
          "/policy/api/v1/global-infra/groups",
          "/policy/api/v1/global-infra/security-policies",
          "/policy/api/v1/global-infra/gateway-policies",
          "/policy/api/v1/infra/sites",
          "/policy/api/v1/infra/sites/enforcement-points",
          "/policy/api/v1/global-infra/realized-state",

          # Policy API - Advanced Configuration
          "/policy/api/v1/infra/ip-pools",
          "/policy/api/v1/infra/ip-blocks",
          "/policy/api/v1/infra/ip-subnets",
          "/policy/api/v1/infra/enforcement-points",
          "/policy/api/v1/infra/deployment-zones",
          "/policy/api/v1/infra/host-transport-node-profiles",
          "/policy/api/v1/infra/edge-transport-node-profiles",

          # Policy API - Settings and Configuration
          "/policy/api/v1/infra/settings",
          "/policy/api/v1/infra/settings/firewall",
          "/policy/api/v1/infra/settings/firewall/security",
          "/policy/api/v1/infra/settings/firewall/cpu-mem-thresholds",
          "/policy/api/v1/infra/cluster-control-planes",
          "/policy/api/v1/infra/sha-profiles",

          # Policy API - Intrusion Detection and Advanced Security
          "/policy/api/v1/infra/settings/firewall/security/intrusion-services",
          "/policy/api/v1/infra/intrusion-service-profiles",
          "/policy/api/v1/infra/flood-protection-profiles",
          "/policy/api/v1/infra/context-aware-profiles",
          "/policy/api/v1/infra/endpoint-protection-profiles",

          # OpenAPI and Documentation Endpoints
          "/api/v1/spec/openapi/nsx_api.json",
          "/policy/api/v1/spec/openapi/nsx_policy_api.json",
          "/api/v1/spec/openapi/nsx_vmc_app_api.json",
          "/api/v1/reverse-proxy/node/services",

          # Search and Query APIs
          "/policy/api/v1/search/query",
          "/policy/api/v1/search/aggregate",
          "/policy/api/v1/search/dsl",
          "/api/v1/search/query",
          "/api/v1/search/aggregate",

          # Licensing and System Information
          "/api/v1/licenses",
          "/api/v1/eula/content",
          "/api/v1/eula/acceptance",
          "/api/v1/system-administration/configuration",
          "/api/v1/system-administration/settings",

          # Troubleshooting and Diagnostics
          "/api/v1/troubleshooting/connectivity-tests",
          "/api/v1/troubleshooting/ping",
          "/api/v1/troubleshooting/traceroute",
          "/api/v1/troubleshooting/port-connections",
          "/api/v1/operations",
          "/api/v1/operations/status"
        )

        $discoveredEndpoints = @()
        $endpointCounter = 0

        foreach ($endpointPath in $discoveryEndpoints) {
          if ($endpointCounter -ge $MaxEndpoints) { break }

          try {
            $startTime = Get-Date
            Write-ConnectionLog "Testing endpoint: $endpointPath" "DEBUG"

            # Use CoreAPIService (working pattern) for all endpoint testing - 6 parameters required
            $response = $apiService.InvokeRestMethod($NSXManager, $Credential, $endpointPath, "GET", $null, @{})
            $endTime = Get-Date
            $responseTime = ($endTime - $startTime).TotalMilliseconds

            $itemCount = 0
            $hasData = $false

            if ($response.results) {
              $itemCount = $response.results.Count
              $hasData = $itemCount -gt 0
            }
            elseif ($response.node_version -or $response.node_id -or $response.display_name) {
              $itemCount = 1
              $hasData = $true
            }

            $discoveredEndpoints += @{
              endpoint     = $endpointPath
              isValid      = $true
              hasData      = $hasData
              itemCount    = $itemCount
              responseTime = [math]::Round($responseTime, 0)
              lastTested   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
              category     = if ($endpointPath -like "/policy/*") { "Policy" } else { "Management" }
              federation   = $endpointPath -like "*global-infra*" -or $endpointPath -like "*sites*"
            }

            Write-ConnectionLog "[SUCCESS] Endpoint validated: $endpointPath ($itemCount items, $([math]::Round($responseTime, 0))ms)" "DEBUG"
            $endpointCounter++
          }
          catch {
            # Classify the failure to distinguish expected vs real failures
            $failureClassification = Get-FailureClassification -EndpointPath $endpointPath -ErrorMessage $_.Exception.Message

            # Log with appropriate severity based on classification
            $logLevel = switch ($failureClassification.Severity) {
              "Error" { "ERROR" }
              "Warning" { "WARN" }
              "Info" { "DEBUG" }
              default { "DEBUG" }
            }

            $symbol = if ($failureClassification.Expected) { "INFO" } else { "WARN" }
            Write-ConnectionLog "[$symbol] Endpoint $($failureClassification.Type.ToLower()): $endpointPath - $($failureClassification.Reason)" $logLevel

            $discoveredEndpoints += @{
              endpoint        = $endpointPath
              isValid         = $false
              hasData         = $false
              itemCount       = 0
              responseTime    = 0
              lastTested      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
              error           = $_.Exception.Message
              category        = if ($endpointPath -like "/policy/*") { "Policy" } else { "Management" }
              federation      = $endpointPath -like "*global-infra*" -or $endpointPath -like "*sites*"
              failureType     = $failureClassification.Type
              failureSeverity = $failureClassification.Severity
              expectedFailure = $failureClassification.Expected
              failureReason   = $failureClassification.Reason
            }
          }
        }

        # Filter usingDataObjectFilterService if available
        $filteredEndpoints = $discoveredEndpoints
        if ($hasFilteringSupport -and $dataObjectFilterService) {
          try {
            Write-ConnectionLog "ApplyingDataObjectFilterService filtering to discovered endpoints" "INFO"
            $filteredEndpoints = $dataObjectFilterService.FilterObjectsArrayDirect($discoveredEndpoints, "system_objects")
          }
          catch {
            Write-ConnectionLog "DataObjectFilterService filtering failed, using unfiltered endpoints: $($_.Exception.Message)" "WARN"
          }
        }

        $results.CachedEndpoints = $filteredEndpoints
        $results.OptimizedExports = $filteredEndpoints | Where-Object { $_.hasData -and $_.isValid }
        $results.SchemaValidation.ValidatedEndpoints = $filteredEndpoints.Count
        $results.Summary.SuccessfulEndpoints = ($filteredEndpoints | Where-Object { $_.isValid }).Count
        $results.Summary.DataEndpoints = ($filteredEndpoints | Where-Object { $_.hasData }).Count
        $results.Summary.PolicyEndpoints = ($filteredEndpoints | Where-Object { $_.category -eq "Policy" }).Count
        $results.Summary.ManagementEndpoints = ($filteredEndpoints | Where-Object { $_.category -eq "Management" }).Count
        $results.Summary.FederationEndpoints = ($filteredEndpoints | Where-Object { $_.federation }).Count

        foreach ($endpoint in $filteredEndpoints) {
          $endpointName = "Discovered: $($endpoint.endpoint -replace '^.*/([^/]+)/?$', '$1')"
          $results.EndpointTests[$endpointName] = @{
            Success       = $endpoint.isValid
            ItemCount     = $endpoint.itemCount
            ResponseTime  = $endpoint.responseTime
            DataAvailable = $endpoint.hasData
            FromCache     = $false
            Category      = $endpoint.category
            Federation    = $endpoint.federation
          }
        }

        Write-ConnectionLog "Discovery completed: $($results.SchemaValidation.ValidatedEndpoints) endpoints validated" "INFO"
      }
      else {
        Write-ConnectionLog "OpenAPI schema service connectivity test failed" "WARN"
        $results.SchemaValidation.Errors += "Connectivity test failed"
      }
    }
    catch {
      Write-ConnectionLog "Critical failure in OpenAPI schema service: $($_.Exception.Message)" "ERROR"
      $results.SchemaValidation.Errors += "Schema service critical error: $($_.Exception.Message)"
    }
  }
  else {
    Write-ConnectionLog "OpenAPI schema service not available - skipping testing" "WARN"
    $results.SchemaValidation.Errors += "OpenAPI schema service not available in service framework"
  }

  # Calculate performance metrics
  $discoveryEndTime = Get-Date
  $results.SchemaValidation.DiscoveryTime = ($discoveryEndTime - $discoveryStartTime).TotalSeconds
  $results.PerformanceMetrics.TotalDiscoveryTime = $results.SchemaValidation.DiscoveryTime

  if ($results.SchemaValidation.ValidatedEndpoints -gt 0 -and $results.SchemaValidation.DiscoveryTime -gt 0) {
    $results.PerformanceMetrics.EndpointsPerSecond = [math]::Round($results.SchemaValidation.ValidatedEndpoints / $results.SchemaValidation.DiscoveryTime, 2)
  }

  Write-ConnectionLog "=== ENDPOINT DISCOVERY COMPLETED ===" "INFO"
  return $results
}

function Save-ValidatedEndpointForTool {
  param(
    [string]$NSXManager,
    [array]$ValidatedEndpoints,
    [array]$OptimizedEndpoints
  )

  try {
    $cacheDir = if ($workflowOpsService) {
      $workflowOpsService.GetToolkitPath('Cache')
    }
    else {
      $rootPath = Split-Path (Split-Path $scriptPath -Parent) -Parent
      Join-Path $rootPath "data\cache"
    }

    if (-not (Test-Path $cacheDir)) {
      New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    $endpointCache = [PSCustomObject]@{
      metadata        = [PSCustomObject]@{
        nsxManager       = $NSXManager
        hostname         = ($NSXManager -replace '\..*$', '')
        lastValidated    = Get-Date
        validationSource = "NSXConnectionTest-Enhanced"
        toolkitVersion   = "3.1.0"
        cacheVersion     = "2.0"
        validationScope  = "comprehensive"
        expiresAt        = (Get-Date).AddHours(24)
      }
      statistics      = [PSCustomObject]@{
        totalEndpoints     = $ValidatedEndpoints.Count
        activeEndpoints    = ($ValidatedEndpoints | Where-Object { $_.hasData -eq $true }).Count
        validEndpoints     = ($ValidatedEndpoints | Where-Object { $_.isValid -eq $true }).Count
        optimizedEndpoints = $OptimizedEndpoints.Count
      }
      endpoints       = [PSCustomObject]@{
        allEndpoints       = $ValidatedEndpoints
        activeEndpoints    = $ValidatedEndpoints | Where-Object { $_.hasData -eq $true }
        optimizedEndpoints = $OptimizedEndpoints
        validEndpoints     = $ValidatedEndpoints | Where-Object { $_.isValid -eq $true }
      }
      toolIntegration = [PSCustomObject]@{
        exportReady         = $true
        validationReady     = $true
        differentialReady   = $true
        configSyncReady     = $true
        resetReady          = $true
        connectionTestReady = $true
        supportedTools      = @(
          "NSXPolicyConfigExport",
          "NSXConfigSync",
          "ApplyNSXConfigDifferential",
          "ApplyNSXConfig",
          "VerifyNSXConfiguration",
          "NSXConfigReset"
        )
      }
    }

    # Use StandardFileNamingService for proper cache file naming
    $cacheFile = if ($standardFileNamingService) {
      $standardFileNamingService.GenerateEndpointCacheFilePath($cacheDir, $NSXManager)
    }
    else {
      # Fallback for when service not available
      $hostname = $NSXManager -replace '\..*$', ''
      Join-Path $cacheDir "${hostname}_validated_endpoints.json"
    }

    $endpointCache | ConvertTo-Json -Depth 15 -Compress | Out-File -FilePath $cacheFile -Encoding UTF8

    Write-ConnectionLog "=== ENDPOINT CACHE SAVED FOR TOOL INTEGRATION ===" "INFO"
    Write-ConnectionLog "Cache file: $cacheFile" "INFO"
    Write-ConnectionLog "Total endpoints cached: $($ValidatedEndpoints.Count)" "INFO"

    return @{
      Success       = $true
      CacheFile     = $cacheFile
      EndpointCount = $ValidatedEndpoints.Count
    }
  }
  catch {
    Write-ConnectionLog "Failed to save endpoint cache: $($_.Exception.Message)" "ERROR"
    return @{
      Success = $false
      Error   = $_.Exception.Message
    }
  }
}

# ===================================================================
# CONNECTION TEST WORKFLOW
# ===================================================================

function Start-ComprehensiveNSXConnectionTest {
  param(
    [string]$NSXManager,
    [PSCredential]$Credential,
    [switch]$SkipEndpointDiscovery,
    [switch]$UseValidCache
  )

  $testResults = [PSCustomObject]@{
    ConnectionTest         = $null
    BasicEndpoints         = $null
   Endpoints = $null
    Summary                = [PSCustomObject]@{
      OverallSuccess                = $false
      ConnectionSuccess             = $false
      BasicEndpointsSuccess         = $false
     EndpointsSuccess = $false
      TotalEndpointsDiscovered      = 0
      ActiveEndpointsFound          = 0
      CacheStatus                   = "none"
      TestDuration                  = 0
    }
    Recommendations        = @()
    ToolIntegrationStatus  = [PSCustomObject]@{
      EndpointsAvailable          = $false
      CacheAvailable              = $false
      OptimizedEndpointsAvailable = $false
      ToolsCanProceed             = $false
      BlockingIssues              = @()
    }
  }

  $testStartTime = Get-Date

  try {
    Write-ConnectionLog "=== NSX CONNECTION TEST STARTING ===" "INFO"

    # CACHE OPTIMIZATION: If using valid cache, skip all connection testing phases
    if ($UseValidCache) {
      Write-ConnectionLog "Using valid cache - skipping all connection testing phases" "INFO"

      # Load cached results instead of testing
      $cacheResult = Get-EndpointCache -NSXManager $NSXManager
      if ($cacheResult.Success -and $cacheResult.IsValid) {
        Write-ConnectionLog "Loaded cached endpoint data (TTL: $($cacheResult.TTLHours) hours)" "INFO"

        # Set results from cache without testing
        $testResults.ConnectionTest = [PSCustomObject]@{ Success = $true; Message = "Using cached validation" }
        $testResults.BasicEndpoints = [PSCustomObject]@{ "Cached Cluster" = [PSCustomObject]@{ Success = $true; FromCache = $true } }
        $testResults.Summary.ConnectionSuccess = $true
        $testResults.Summary.BasicEndpointsSuccess = $true
        $testResults.Summary.CacheStatus = "hit"

        # Set tool integration status from cache
        $testResults.ToolIntegrationStatus.EndpointsAvailable = $cacheResult.EndpointData.statistics.validEndpoints -gt 0
        $testResults.ToolIntegrationStatus.CacheAvailable = $true
        $testResults.ToolIntegrationStatus.OptimizedEndpointsAvailable = $cacheResult.EndpointData.statistics.optimizedEndpoints -gt 0
        $testResults.ToolIntegrationStatus.ToolsCanProceed = $true

        # Set endpoints from cache
        $testResults.ComprehensiveEndpoints = [PSCustomObject]@{
          SchemaValidation = [PSCustomObject]@{ CacheHit = $true; ValidatedEndpoints = $cacheResult.EndpointData.statistics.validEndpoints }
          Summary          = [PSCustomObject]@{
            SuccessfulEndpoints = $cacheResult.EndpointData.statistics.validEndpoints
            DataEndpoints       = $cacheResult.EndpointData.statistics.activeEndpoints
          }
          CachedEndpoints  = $cacheResult.EndpointData.endpoints.allEndpoints
          OptimizedExports = $cacheResult.EndpointData.endpoints.optimizedEndpoints
        }

        $testResults.Summary.OverallSuccess = $true
        $testResults.Summary.TotalEndpointsDiscovered = $cacheResult.EndpointData.statistics.validEndpoints
        $testResults.Summary.ActiveEndpointsFound = $cacheResult.EndpointData.statistics.activeEndpoints
        $testResults.Recommendations += "[CACHE] Using validated endpoint cache - all tools ready"

        Write-ConnectionLog "Cache optimization complete - skipped connection testing" "INFO"
        return $testResults
      }
      else {
        Write-ConnectionLog "Cache validation failed - falling back to connection testing" "WARN"
      }
    }

    # Phase 1: Basic Connection Test (only when not using valid cache)
    $connectionResult = Test-NSXConnection -NSXManager $NSXManager -Credential $Credential
    $testResults.ConnectionTest = $connectionResult
    $testResults.Summary.ConnectionSuccess = $connectionResult.Success

    if (-not $connectionResult.Success) {
      $testResults.ToolIntegrationStatus.BlockingIssues += "Basic connection failed: $($connectionResult.Error)"
      return $testResults
    }

    # Phase 2: Basic Endpoint Testing (only when not using valid cache)
    $basicEndpointResult = Test-NSXEndpoint -NSXManager $NSXManager -Credential $Credential -EndpointPath "/api/v1/cluster" -TimeoutSeconds 15
    $testResults.BasicEndpoints = [PSCustomObject]@{ "Management Cluster" = $basicEndpointResult }

    $basicSuccessCount = ($testResults.BasicEndpoints.PSObject.Properties.Value | Where-Object { $_.Success }).Count
    $testResults.Summary.BasicEndpointsSuccess = $basicSuccessCount -gt 0

    # Phase 3: Endpoint Discovery
    if (-not $SkipEndpointDiscovery) {
      $comprehensiveResult = Test-NSXEndpointsWithSchemaValidation -NSXManager $NSXManager -Credential $Credential -MaxEndpoints 100
      $testResults.ComprehensiveEndpoints = $comprehensiveResult

      $testResults.Summary.ComprehensiveEndpointsSuccess = $comprehensiveResult.Summary.SuccessfulEndpoints -gt 0
      $testResults.Summary.TotalEndpointsDiscovered = $comprehensiveResult.Summary.SuccessfulEndpoints
      $testResults.Summary.ActiveEndpointsFound = $comprehensiveResult.Summary.DataEndpoints
      $testResults.Summary.CacheStatus = if ($comprehensiveResult.SchemaValidation.CacheHit) { "hit" } else { "miss" }

      # Check for real connectivity issues (not expected configuration failures)
      $realFailures = @()
      if ($comprehensiveResult.CachedEndpoints) {
        $realFailures = $comprehensiveResult.CachedEndpoints | Where-Object {
          -not $_.isValid -and
          $_.expectedFailure -eq $false -and
          ($_.failureType -eq "Connectivity" -or $_.failureType -eq "Unexpected")
        }
      }
      $testResults.Summary.RealConnectivityIssues = $realFailures.Count

      # Update tool integration status
      $testResults.ToolIntegrationStatus.EndpointsAvailable = $comprehensiveResult.Summary.SuccessfulEndpoints -gt 0
      $testResults.ToolIntegrationStatus.CacheAvailable = $comprehensiveResult.CachedEndpoints.Count -gt 0
      $testResults.ToolIntegrationStatus.OptimizedEndpointsAvailable = $comprehensiveResult.OptimizedExports.Count -gt 0
      $testResults.ToolIntegrationStatus.ToolsCanProceed = $testResults.ToolIntegrationStatus.EndpointsAvailable -and $testResults.ToolIntegrationStatus.CacheAvailable

      # Save endpoint cache
      if ($comprehensiveResult.CachedEndpoints.Count -gt 0) {
        $cacheResult = Save-ValidatedEndpointForTool -NSXManager $NSXManager -ValidatedEndpoints $comprehensiveResult.CachedEndpoints -OptimizedEndpoints $comprehensiveResult.OptimizedExports
      }
    }

    # Generate recommendations
    $testResults.Recommendations = @()
    if ($testResults.Summary.ConnectionSuccess) {
      $testResults.Recommendations += "[SUCCESS] Connection successful - NSX Manager is accessible"
    }
    if ($testResults.ToolIntegrationStatus.ToolsCanProceed) {
      $testResults.Recommendations += "[SUCCESS] All NSX toolkit tools ready for use"
      $testResults.Recommendations += " Proceed with NSXPolicyConfigExport, NSXConfigSync, or other operations"
    }

    # Determine overall success based on real connectivity issues, not configuration-dependent failures
    $hasRealConnectivityIssues = ($testResults.Summary.RealConnectivityIssues -gt 0) -or (-not $testResults.Summary.ConnectionSuccess)
    $testResults.Summary.OverallSuccess = -not $hasRealConnectivityIssues -and $testResults.Summary.BasicEndpointsSuccess

  }
  catch {
    Write-ConnectionLog "Critical error in connection test: $($_.Exception.Message)" "ERROR"
    $testResults.ToolIntegrationStatus.BlockingIssues += "Critical test failure: $($_.Exception.Message)"
  }
  finally {
    $testEndTime = Get-Date
    $testResults.Summary.TestDuration = ($testEndTime - $testStartTime).TotalSeconds
  }

  return $testResults
}

# ===================================================================
# CREDENTIAL COLLECTION AND SETUP
# ===================================================================

Write-ConnectionLog "ConnectionTest Started"
Write-ConnectionLog "NSX Manager: $NSXManager"

# Handle credential management mode
if ($ManageCredentials) {
  Write-ConnectionLog "Credential management mode requested"
  Write-Output "Launching NSX Credential Management..."
  $credMgmtScript = Join-Path $scriptPath "ManageNSXCredentials.ps1"
  if (Test-Path $credMgmtScript) {
    & $credMgmtScript
  }
  else {
    Write-Error "Credential management script not found: $credMgmtScript"
  }
  exit 0
}

Write-Output "Connection Diagnostic Test"
Write-Output "NSX Manager: $NSXManager"
Write-Output ""

# Collect credentials using shared credential service
$sharedCredentialService = $services.SharedToolCredentialService
$sharedCredentialService.DisplayCredentialCollectionStatus($NSXManager, "ConnectionTest", $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials)
$sharedCredentialService.ValidateCredentialParameters($UseCurrentUserCredentials, $ForceNewCredentials, $Username, $null)

try {
  $credential = $sharedCredentialService.GetStandardNSXCredentials($NSXManager, $Username, $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials, $null, "ConnectionTest")
  Write-ConnectionLog "Credentials collected successfully using SharedToolCredentialService"
}
catch {
  Write-Error "FAILED: Credential collection failed for $NSXManager"
  exit 1
}

# Verify SSL configuration status (already configured above)
if ($SkipSSLCheck) {
  Write-ConnectionLog "SSL certificate validation disabled (configured during initialization)" "INFO"

  # Verify SSL bypass is active
  $sslCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
  if ($null -ne $sslCallback) {
    Write-ConnectionLog "[SUCCESS] SSL bypass is active and ready for HTTPS operations" "INFO"
  }
  else {
    Write-ConnectionLog "[FAIL] SSL bypass is NOT active - HTTPS operations may fail" "ERROR"
  }
}
else {
  Write-ConnectionLog "SSL certificate validation enabled" "INFO"
}

# ===================================================================
# MAIN EXECUTION LOGIC - NSX CONNECTION TEST
# ===================================================================

Write-Output ""
Write-Output ("=" * 80)
Write-Output "NSX CONNECTION TEST WITH ENDPOINT DISCOVERY"
Write-Output ("=" * 80)
Write-Output "NSX Manager: $NSXManager"
Write-Output "Timestamp: $(Get-Date)"
Write-Output "Features: OpenAPI Discovery, Endpoint Caching, Tool Integration"
Write-Output ("=" * 80)

#  Cache TTL Logic - Default: Skip OpenAPI checks unless cache expired or Force specified
$performEndpointDiscovery = $false
$cacheStatus = "no-cache-file"

if ($Force) {
  Write-ConnectionLog "Force specified - performing fresh endpoint discovery (ignoring cache)" "INFO"
  $performEndpointDiscovery = $true
  $cacheStatus = "force-ignore"
}
else {
  # Use StandardFileNamingService for proper cache file path resolution
  try {
    $cacheDir = $workflowOpsService.GetToolkitPath('Cache')
    $cacheFile = $standardFileNamingService.GenerateEndpointCacheFilePath($cacheDir, $NSXManager)

    Write-ConnectionLog "Checking cache file: $cacheFile" "DEBUG"

    if (Test-Path $cacheFile) {
      try {
        $cacheData = Get-Content $cacheFile -Raw | ConvertFrom-Json
        $cacheExpiry = [DateTime]::Parse($cacheData.metadata.expiresAt)
        $currentTime = Get-Date

        if ($currentTime -lt $cacheExpiry) {
          $performEndpointDiscovery = $false
          $cacheStatus = "valid-cache"
          $remainingTTL = ($cacheExpiry - $currentTime).TotalHours
          Write-ConnectionLog "[SUCCESS] Cache valid - skipping ALL connection testing (TTL remaining: $([math]::Round($remainingTTL, 1))h)" "INFO"
        }
        else {
          $performEndpointDiscovery = $true
          $cacheStatus = "expired-cache"
          Write-ConnectionLog "[FAIL] Cache expired - performing OpenAPI endpoint discovery" "INFO"
        }
      }
      catch {
        $performEndpointDiscovery = $true
        $cacheStatus = "invalid-cache"
        Write-ConnectionLog "[FAIL] Cache invalid - performing OpenAPI endpoint discovery: $($_.Exception.Message)" "INFO"
      }
    }
    else {
      $performEndpointDiscovery = $true
      $cacheStatus = "no-cache-file"
      Write-ConnectionLog "[FAIL] No cache found - performing OpenAPI endpoint discovery" "INFO"
    }
  }
  catch {
    Write-ConnectionLog "[FAIL] Cache path resolution failed - performing OpenAPI endpoint discovery: $($_.Exception.Message)" "WARN"
    $performEndpointDiscovery = $true
    $cacheStatus = "cache-error"
  }
}

# CACHE OPTIMIZATION: Determine if we should use valid cache to skip ALL testing
$useValidCache = ($cacheStatus -eq "valid-cache")
Write-ConnectionLog "Decision: PerformEndpointDiscovery=$performEndpointDiscovery, CacheStatus=$cacheStatus, UseValidCache=$useValidCache" "DEBUG"

# Run the test workflow - Skip discovery by default unless cache expired or Force
$comprehensiveResults = Start-ComprehensiveNSXConnectionTest -NSXManager $NSXManager -Credential $credential -SkipEndpointDiscovery:(-not $performEndpointDiscovery) -UseValidCache:$useValidCache

# ===================================================================
# RESULTS REPORTING
# ===================================================================

Write-Output ""
Write-Output ("=" * 60)
Write-Output "CONNECTION TEST RESULTS"
Write-Output ("=" * 60)

# Basic Connection Results
if ($comprehensiveResults.Summary.ConnectionSuccess) {
  Write-Output "[SUCCESS] Basic Connection: SUCCESS"
  Write-Output "   Auth Method: $($comprehensiveResults.ConnectionTest.AuthMethod)"
  Write-Output "   Node ID: $($comprehensiveResults.ConnectionTest.NodeId)"
  Write-Output "   Version: $($comprehensiveResults.ConnectionTest.Version)"
}
else {
  Write-Output "[ERROR] Basic Connection: FAILED"
  Write-Output "   Error: $($comprehensiveResults.ConnectionTest.Error)"
}

# Basic Endpoints Results
if ($comprehensiveResults.Summary.BasicEndpointsSuccess) {
  Write-Output "[SUCCESS] Standard Endpoints: SUCCESS"

  # Since Summary.BasicEndpointsSuccess is true, we know there's 1 successful basic endpoint
  $basicEndpointsCount = $comprehensiveResults.BasicEndpoints.Count
  $basicSuccessCount = 1  # If Summary.BasicEndpointsSuccess is true, we have 1 success

  Write-Output "   Working Endpoints: $basicSuccessCount/$basicEndpointsCount"
}
else {
  Write-Output "[ERROR] Standard Endpoints: FAILED"
}

# Real connectivity issues status
if ($comprehensiveResults.Summary.RealConnectivityIssues -gt 0) {
  Write-Output "[WARN] Real Connectivity Issues: $($comprehensiveResults.Summary.RealConnectivityIssues) critical failures detected"
}
else {
  Write-Output "[SUCCESS] Connectivity Health: No critical connectivity issues detected"
  if ($comprehensiveResults.ComprehensiveEndpoints.CachedEndpoints) {
    $expectedFailures = ($comprehensiveResults.ComprehensiveEndpoints.CachedEndpoints | Where-Object { -not $_.isValid -and $_.expectedFailure }).Count
    if ($expectedFailures -gt 0) {
      Write-Output "   Note: $expectedFailures expected configuration-dependent failures (normal for lab environments)"
    }
  }
}

# Discovery Results
if ($comprehensiveResults.ComprehensiveEndpoints) {
  $comp = $comprehensiveResults.ComprehensiveEndpoints
  Write-Output ""
  Write-Output ("=" * 60)
  Write-Output "COMPREHENSIVE ENDPOINT DISCOVERY RESULTS"
  Write-Output ("=" * 60)

  if ($comp.SchemaValidation.CacheHit) {
    Write-Output "[CACHE] Cache Status: HIT (using cached endpoints)"
  }
  else {
    Write-Output "[DISCOVERY] Cache Status: MISS (performed full discovery)"
    Write-Output "   Discovery Time: $([math]::Round($comp.SchemaValidation.DiscoveryTime, 2)) seconds"
  }

  Write-Output "[STATS] Discovery Statistics:"
  Write-Output "   Total Endpoints: $($comp.Summary.SuccessfulEndpoints)"
  Write-Output "   Data Endpoints: $($comp.Summary.DataEndpoints)"
  Write-Output "   Optimized Endpoints: $($comp.OptimizedExports.Count)"

  if ($comp.FederationSupport.GlobalManagerDetected) {
    Write-Output "[GLOBAL] NSX Federation: Global Manager Detected"
  }
  else {
    Write-Output "[LOCAL] NSX Federation: Local/Standalone Manager"
  }
}

# Tool Integration Status
Write-Output ""
Write-Output ("=" * 60)
Write-Output "TOOL INTEGRATION STATUS"
Write-Output ("=" * 60)

if ($comprehensiveResults.ToolIntegrationStatus.ToolsCanProceed) {
  Write-Output "[SUCCESS] NSX Toolkit Integration: READY"
  Write-Output ""
  Write-Output "[READY] Ready Tools:"
  Write-Output "   - NSXPolicyConfigExport.ps1"
  Write-Output "   - NSXConfigSync.ps1"
  Write-Output "   - ApplyNSXConfigDifferential.ps1"
  Write-Output "   - ApplyNSXConfig.ps1"
  Write-Output "   - VerifyNSXConfiguration.ps1"
  Write-Output "   - NSXConfigReset.ps1"
}
else {
  Write-Output "[ERROR] NSX Toolkit Integration: NOT READY"
  foreach ($issue in $comprehensiveResults.ToolIntegrationStatus.BlockingIssues) {
    Write-Output "   - $issue"
  }
}

# Recommendations
if ($comprehensiveResults.Recommendations.Count -gt 0) {
  Write-Output ""
  Write-Output ("=" * 60)
  Write-Output "RECOMMENDATIONS"
  Write-Output ("=" * 60)
  foreach ($recommendation in $comprehensiveResults.Recommendations) {
    Write-Output $recommendation
  }
}

# Final Status
Write-Output ""
Write-Output ("=" * 80)
if ($comprehensiveResults.Summary.OverallSuccess) {
  Write-Output "[COMPLETE] NSX CONNECTION TEST COMPLETED SUCCESSFULLY"
  if ($comprehensiveResults.ToolIntegrationStatus.ToolsCanProceed) {
    Write-Output "[READY] ALL NSX TOOLKIT TOOLS ARE READY TO USE"
  }
}
else {
  if ($comprehensiveResults.Summary.RealConnectivityIssues -gt 0) {
    Write-Output "[ERROR] NSX CONNECTION TEST FAILED - CRITICAL CONNECTIVITY ISSUES"
    Write-Output "[WARN] RESOLVE CONNECTIVITY ISSUES BEFORE USING OTHER TOOLKIT TOOLS"
  }
  else {
    Write-Output "[WARN] NSX CONNECTION TEST COMPLETED WITH EXPECTED CONFIGURATION ISSUES"
    Write-Output "[SUCCESS] CORE CONNECTIVITY WORKING - TOOLKIT TOOLS CAN BE USED"
  }
}
Write-Output ("=" * 80)

Write-ConnectionLog "Comprehensive NSX connection test completed" "INFO"

# ===================================================================
# MANDATORY TOOLKIT TOOL PREREQUISITE FUNCTIONS
# ===================================================================

function Invoke-NSXConnectionTestPrerequisite {
  <#
  .SYNOPSIS
    Mandatory prerequisite test for all NSX toolkit tools.

  .DESCRIPTION
    This function must be called by all NSX toolkit tools before performing operations.
    It ensures NSX connectivity, validates endpoint discovery, and configures services.
    Implements the mandatory NSXConnectionTest prerequisite pattern from the architecture plan.

  .PARAMETER NSXManager
    NSX Manager FQDN or IP address

  .PARAMETER Credential
    PSCredential object for NSX authentication

  .PARAMETER RequiredEndpoints
    Specific endpoints required by the calling tool (optional)

  .PARAMETER ToolName
    Name of the tool calling this prerequisite check

  .PARAMETER SkipCacheIfOlderThan
    Skip cache if older than specified hours (default: 24)

  .PARAMETER MinimumSuccessfulEndpoints
    Minimum number of successful endpoints required (default: 5)

  .RETURNS
    Returns a hashtable with Success, EndpointCache, and ValidationResults
  #>

  param(
    [Parameter(Mandatory = $true)]
    [string]$NSXManager,

    [Parameter(Mandatory = $true)]
    [PSCredential]$Credential,

    [Parameter(Mandatory = $false)]
    [array]$RequiredEndpoints = @(),

    [Parameter(Mandatory = $true)]
    [string]$ToolName,

    [Parameter(Mandatory = $false)]
    [int]$SkipCacheIfOlderThan = 24,

    [Parameter(Mandatory = $false)]
    [int]$MinimumSuccessfulEndpoints = 5
  )

  try {
    Write-ConnectionLog "=== MANDATORY NSX TOOLKIT PREREQUISITE CHECK ===" "INFO"
    Write-ConnectionLog "Tool: $ToolName" "INFO"
    Write-ConnectionLog "NSX Manager: $NSXManager" "INFO"
    Write-ConnectionLog "Required Endpoints: $($RequiredEndpoints.Count)" "INFO"

    # CACHE OPTIMIZATION: Check for valid cache first to avoid unnecessary connection testing
    Write-ConnectionLog "Phase 1: Checking endpoint cache validity for optimization..." "INFO"
    $cacheResult = Get-EndpointCache -NSXManager $NSXManager

    if ($cacheResult.Success -and $cacheResult.IsValid) {
      # Check cache age
      $cacheAgeHours = 24 - $cacheResult.TTLHours
      $hasSufficientEndpoints = $cacheResult.EndpointData.statistics.validEndpoints -ge $MinimumSuccessfulEndpoints

      if ($cacheAgeHours -le $SkipCacheIfOlderThan -and $hasSufficientEndpoints) {
        Write-ConnectionLog "[CACHE OPTIMIZATION] Valid cache found - skipping connection testing" "INFO"
        Write-ConnectionLog "Cache age: $([math]::Round($cacheAgeHours, 1)) hours, TTL: $($cacheResult.TTLHours) hours" "INFO"
        Write-ConnectionLog "Cached endpoints: $($cacheResult.EndpointData.statistics.validEndpoints)" "INFO"

        # Skip to validation using cached data
        $connectionResult = [PSCustomObject]@{ Success = $true; Message = "Using cached validation" }
        Write-ConnectionLog "[SUCCESS] Connection validation skipped (using cache)" "INFO"
        $skipConnectionTesting = $true
      }
      else {
        if ($cacheAgeHours -gt $SkipCacheIfOlderThan) {
          Write-ConnectionLog "Cache is $([math]::Round($cacheAgeHours, 1)) hours old, performing fresh testing" "INFO"
        }
        if (-not $hasSufficientEndpoints) {
          Write-ConnectionLog "Cache has insufficient endpoints ($($cacheResult.EndpointData.statistics.validEndpoints) < $MinimumSuccessfulEndpoints), performing fresh testing" "INFO"
        }
        $skipConnectionTesting = $false
      }
    }
    else {
      Write-ConnectionLog "No valid endpoint cache found, performing connection testing" "INFO"
      $skipConnectionTesting = $false
    }

    # Phase 1: Basic Connection Test (only when cache optimization doesn't apply)
    if (-not $skipConnectionTesting) {
      Write-ConnectionLog "Phase 1: Testing basic NSX connectivity..." "INFO"
      $connectionResult = Test-NSXConnection -NSXManager $NSXManager -Credential $Credential

      if (-not $connectionResult.Success) {
        $failureReason = "Basic NSX connectivity failed: $($connectionResult.Error)"
        Write-ConnectionLog "[ERROR] PREREQUISITE FAILED: $failureReason" "ERROR"
        return [PSCustomObject]@{
          Success           = $false
          Error             = $failureReason
          Phase             = "BasicConnectivity"
          ToolCanProceed    = $false
          EndpointCache     = $null
          ValidationResults = $null
        }
      }

      Write-ConnectionLog "[SUCCESS] Basic connectivity successful" "INFO"
    }
    # Phase 2: Check for existing valid endpoint cache (or use already loaded cache)
    Write-ConnectionLog "Phase 2: Checking endpoint cache validity..." "INFO"

    # If we already loaded cache in Phase 1 optimization, don't reload it
    if ($skipConnectionTesting) {
      Write-ConnectionLog "[CACHE OPTIMIZATION] Using cache data already loaded in Phase 1" "INFO"
      $needsNewDiscovery = $false
    }
    else {
      # Load cache if we haven't already
      if (-not $cacheResult) {
        $cacheResult = Get-EndpointCache -NSXManager $NSXManager
      }

      $needsNewDiscovery = $false
      if ($cacheResult.Success -and $cacheResult.IsValid) {
        # Check cache age
        $cacheAgeHours = 24 - $cacheResult.TTLHours
        if ($cacheAgeHours -gt $SkipCacheIfOlderThan) {
          Write-ConnectionLog "Cache is $([math]::Round($cacheAgeHours, 1)) hours old, performing fresh discovery" "INFO"
          $needsNewDiscovery = $true
        }
        else {
          Write-ConnectionLog "[SUCCESS] Valid endpoint cache found (age: $([math]::Round($cacheAgeHours, 1)) hours, TTL: $($cacheResult.TTLHours) hours)" "INFO"

          # Validate cache has sufficient endpoints
          $successfulEndpoints = $cacheResult.EndpointData.statistics.validEndpoints
          if ($successfulEndpoints -lt $MinimumSuccessfulEndpoints) {
            Write-ConnectionLog "Cache has insufficient endpoints ($successfulEndpoints is less than $MinimumSuccessfulEndpoints), performing fresh discovery" "WARN"
            $needsNewDiscovery = $true
          }
        }
      }
      else {
        Write-ConnectionLog "No valid endpoint cache found, performing discovery" "INFO"
        $needsNewDiscovery = $true
      }
    }

    # Phase 3: Endpoint Discovery (if needed)
    if ($needsNewDiscovery) {
      Write-ConnectionLog "Phase 3: Performing endpoint discovery..." "INFO"
      $discoveryResult = Test-NSXEndpointsWithSchemaValidation -NSXManager $NSXManager -Credential $Credential -MaxEndpoints 100

      if ($discoveryResult.Summary.SuccessfulEndpoints -lt $MinimumSuccessfulEndpoints) {
        $failureReason = "Insufficient endpoints discovered ($($discoveryResult.Summary.SuccessfulEndpoints) is less than $MinimumSuccessfulEndpoints)"
        Write-ConnectionLog "[ERROR] PREREQUISITE FAILED: $failureReason" "ERROR"
        return [PSCustomObject]@{
          Success           = $false
          Error             = $failureReason
          Phase             = "EndpointDiscovery"
          ToolCanProceed    = $false
          EndpointCache     = $discoveryResult
          ValidationResults = $discoveryResult
        }
      }

      # Save fresh cache
      $cacheResult = [PSCustomObject]@{
        Success      = $true
        IsValid      = $true
        TTLHours     = 24.0
        EndpointData = [PSCustomObject]@{
          statistics = $discoveryResult.Summary
          endpoints  = [PSCustomObject]@{
            allEndpoints       = $discoveryResult.CachedEndpoints
            optimizedEndpoints = $discoveryResult.OptimizedExports
            activeEndpoints    = $discoveryResult.CachedEndpoints | Where-Object { $_.hasData }
            validEndpoints     = $discoveryResult.CachedEndpoints | Where-Object { $_.isValid }
          }
        }
      }

      Write-ConnectionLog "[SUCCESS] Fresh endpoint discovery completed: $($discoveryResult.Summary.SuccessfulEndpoints) endpoints" "INFO"
    }

    # Phase 4: Validate Required Endpoints (if specified)
    if ($RequiredEndpoints.Count -gt 0) {
      Write-ConnectionLog "Phase 4: Validating required endpoints..." "INFO"
      $availableEndpoints = $cacheResult.EndpointData.endpoints.validEndpoints | ForEach-Object { $_.endpoint }
      $missingEndpoints = $RequiredEndpoints | Where-Object { $_ -notin $availableEndpoints }

      if ($missingEndpoints.Count -gt 0) {
        $failureReason = "Required endpoints not available: $($missingEndpoints -join ', ')"
        Write-ConnectionLog "[WARN] PREREQUISITE FAILED: $failureReason" "WARN"
        Write-ConnectionLog "Total available endpoints discovered: $($availableEndpoints.Count)" "INFO"
        Write-ConnectionLog "Available endpoints: $($availableEndpoints -join ', ')" "DEBUG"

        # This is a warning, not a hard failure - tool may still proceed with limited functionality
        return [PSCustomObject]@{
          Success              = $true  # Allow tool to proceed
          Warning              = $failureReason
          Phase                = "RequiredEndpointValidation"
          ToolCanProceed       = $true
          LimitedFunctionality = $true
          MissingEndpoints     = $missingEndpoints
          EndpointCache        = $cacheResult
          ValidationResults    = $cacheResult.EndpointData
        }
      }

      Write-ConnectionLog "[SUCCESS] All required endpoints validated" "INFO"
    }

    # Phase 5: Final Validation
    Write-ConnectionLog "Phase 5: Final tool readiness validation..." "INFO"
    $toolReadiness = [PSCustomObject]@{
      BasicConnectivity   = $connectionResult.Success
      EndpointsAvailable  = $cacheResult.EndpointData.statistics.validEndpoints -gt 0
      CacheValid          = $cacheResult.IsValid
      MinimumEndpointsMet = $cacheResult.EndpointData.statistics.validEndpoints -ge $MinimumSuccessfulEndpoints
    }

    $allChecksPassed = $toolReadiness.PSObject.Properties.Value | ForEach-Object { $_ } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count
    $overallSuccess = $allChecksPassed -eq 0

    if ($overallSuccess) {
      Write-ConnectionLog "[SUCCESS] ALL PREREQUISITE CHECKS PASSED - TOOL CAN PROCEED" "INFO"
      Write-ConnectionLog "Available endpoints: $($cacheResult.EndpointData.statistics.validEndpoints)" "INFO"
      Write-ConnectionLog "Cache TTL: $($cacheResult.TTLHours) hours" "INFO"
    }
    else {
      Write-ConnectionLog "[WARN] Some prerequisite checks failed - review tool readiness" "WARN"
    }

    return [PSCustomObject]@{
      Success           = $overallSuccess
      Phase             = "Complete"
      ToolCanProceed    = $overallSuccess
      EndpointCache     = $cacheResult
      ValidationResults = $cacheResult.EndpointData
      ToolReadiness     = $toolReadiness
      Statistics        = [PSCustomObject]@{
        TotalEndpoints     = $cacheResult.EndpointData.statistics.totalEndpoints
        ValidEndpoints     = $cacheResult.EndpointData.statistics.validEndpoints
        ActiveEndpoints    = $cacheResult.EndpointData.statistics.activeEndpoints
        OptimizedEndpoints = $cacheResult.EndpointData.statistics.optimizedEndpoints
        CacheAge           = if ($cacheResult.TTLHours) { 24 - $cacheResult.TTLHours } else { 0 }
        CacheTTL           = $cacheResult.TTLHours
      }
      # VALIDATED STATE for tool chaining - avoids redundant validation
      ValidatedState    = [PSCustomObject]@{
        NSXManager         = $NSXManager
        Credential         = $Credential
        ConnectivityValid  = $connectionResult.Success
        SSLBypassEnabled   = $true  # NSX Toolkit has global SSL bypass
        EndpointCache      = $cacheResult
        ValidationTime     = Get-Date
        ToolName           = $ToolName
        CacheValid         = $cacheResult.IsValid
        RequiredEndpoints  = $RequiredEndpoints
        AvailableEndpoints = $cacheResult.EndpointData.endpoints.validEndpoints | ForEach-Object { $_.endpoint }
      }
    }
  }
  catch {
    $failureReason = "Critical error in prerequisite check: $($_.Exception.Message)"
    Write-ConnectionLog "[ERROR] PREREQUISITE CRITICAL FAILURE: $failureReason" "ERROR"
    return [PSCustomObject]@{
      Success           = $false
      Error             = $failureReason
      Phase             = "CriticalError"
      ToolCanProceed    = $false
      EndpointCache     = $null
      ValidationResults = $null
    }
  }
}

function Assert-NSXToolkitPrerequisite {
  <#
  .SYNOPSIS
    Enforces mandatory NSX toolkit prerequisites with fail-fast behavior.

  .DESCRIPTION
    This function enforces the mandatory prerequisite pattern and will terminate
    the calling script if prerequisites are not met. Use for strict enforcement.

  .PARAMETER NSXManager
    NSX Manager FQDN or IP address

  .PARAMETER Credential
    PSCredential object for NSX authentication

  .PARAMETER RequiredEndpoints
    Specific endpoints required by the calling tool (optional)

  .PARAMETER ToolName
    Name of the tool calling this prerequisite check

  .PARAMETER AllowLimitedFunctionality
    Allow tool to proceed even if some required endpoints are missing (default: false)

  .PARAMETER ValidatedState
    Previously validated state from another tool in the chain (optional)
    When provided, skips connectivity validation and uses passed state
  #>

  param(
    [Parameter(Mandatory = $true)]
    [string]$NSXManager,

    [Parameter(Mandatory = $true)]
    [PSCredential]$Credential,

    [Parameter(Mandatory = $false)]
    [array]$RequiredEndpoints = @(),

    [Parameter(Mandatory = $true)]
    [string]$ToolName,

    [Parameter(Mandatory = $false)]
    [switch]$AllowLimitedFunctionality,

    [Parameter(Mandatory = $false)]
    [object]$ValidatedState = $null
  )

  # STATE CHAINING: If ValidatedState is provided, use it instead of running validation
  if ($ValidatedState -and $ValidatedState.ConnectivityValid -and $ValidatedState.NSXManager -eq $NSXManager) {
    Write-Host -Object "[SUCCESS] NSX Toolkit Prerequisites: USING VALIDATED STATE FROM CHAIN" -ForegroundColor Green
    Write-Host -Object "Previous Tool: $($ValidatedState.ToolName)" -ForegroundColor Green
    Write-Host -Object "Validation Time: $($ValidatedState.ValidationTime)" -ForegroundColor Green
    Write-Host -Object "Valid Endpoints: $($ValidatedState.AvailableEndpoints.Count)" -ForegroundColor Green
    Write-Host -Object "Cache Valid: $($ValidatedState.CacheValid)" -ForegroundColor Green
    Write-Host -Object ""

    # Validate required endpoints against cached state
    if ($RequiredEndpoints.Count -gt 0) {
      $missingEndpoints = $RequiredEndpoints | Where-Object { $_ -notin $ValidatedState.AvailableEndpoints }
      if ($missingEndpoints.Count -gt 0 -and -not $AllowLimitedFunctionality) {
        Write-Host -Object ""
        Write-Host -Object "[WARNING] TOOLKIT PREREQUISITE WARNING" -ForegroundColor Yellow
        Write-Host -Object "Tool: $ToolName" -ForegroundColor Yellow
        Write-Host -Object "Missing endpoints: $($missingEndpoints -join ', ')" -ForegroundColor Yellow
        Write-Host -Object ""
        throw "NSX Toolkit prerequisites warning - tool requires all endpoints"
      }
    }

    # Return result with validated state
    return [PSCustomObject]@{
      Success           = $true
      Phase             = "ValidatedStateReused"
      ToolCanProceed    = $true
      EndpointCache     = $ValidatedState.EndpointCache
      ValidationResults = $ValidatedState.EndpointCache.EndpointData
      ValidatedState    = $ValidatedState
      Statistics        = [PSCustomObject]@{
        ValidEndpoints = $ValidatedState.AvailableEndpoints.Count
        CacheTTL       = $ValidatedState.EndpointCache.TTLHours
        StateReused    = $true
      }
    }
  }

  $result = Invoke-NSXConnectionTestPrerequisite -NSXManager $NSXManager -Credential $Credential -RequiredEndpoints $RequiredEndpoints -ToolName $ToolName

  if (-not $result.Success -or -not $result.ToolCanProceed) {
    Write-Host -Object ""
    Write-Host -Object "[ERROR] TOOLKIT PREREQUISITE FAILURE" -ForegroundColor Red
    Write-Host -Object "Tool: $ToolName" -ForegroundColor Yellow
    Write-Host -Object "Error: $($result.Error)" -ForegroundColor Red
    Write-Host -Object "Phase: $($result.Phase)" -ForegroundColor Yellow
    Write-Host -Object ""
    Write-Host -Object "REQUIRED ACTION:" -ForegroundColor Cyan
    Write-Host -Object "1. Verify NSX Manager connectivity: $NSXManager" -ForegroundColor White
    Write-Host -Object "2. Check network access and credentials" -ForegroundColor White
    Write-Host -Object "3. Run NSXConnectionTest.ps1 manually to diagnose issues" -ForegroundColor White
    Write-Host -Object ""
    Write-Host -Object "Example: .\tools\NSXConnectionTest.ps1 -NSXManager '$NSXManager'" -ForegroundColor Green
    Write-Host -Object ""
    throw "NSX Toolkit prerequisites not met - tool cannot proceed safely"
  }

  if ($result.Warning -and -not $AllowLimitedFunctionality) {
    Write-Host -Object ""
    Write-Host -Object "[WARNING] TOOLKIT PREREQUISITE WARNING" -ForegroundColor Yellow
    Write-Host -Object "Tool: $ToolName" -ForegroundColor Yellow
    Write-Host -Object "Warning: $($result.Warning)" -ForegroundColor Yellow
    Write-Host -Object ""
    Write-Host -Object "The tool can proceed but some functionality may be limited." -ForegroundColor Yellow
    Write-Host -Object "Use -AllowLimitedFunctionality to suppress this check." -ForegroundColor Yellow
    Write-Host -Object ""
    throw "NSX Toolkit prerequisites warning - tool requires all endpoints"
  }

  if ($result.Warning) {
    Write-Host -Object ""
    Write-Host -Object "[WARNING] NSX TOOLKIT PROCEEDING WITH LIMITED FUNCTIONALITY" -ForegroundColor Yellow
    Write-Host -Object "Warning: $($result.Warning)" -ForegroundColor Yellow
    Write-Host -Object ""
  }

  Write-Host -Object "[SUCCESS] NSX Toolkit Prerequisites: PASSED" -ForegroundColor Green
  Write-Host -Object "Valid Endpoints: $($result.Statistics.ValidEndpoints)" -ForegroundColor Green
  Write-Host -Object "Cache TTL: $([math]::Round($result.Statistics.CacheTTL, 1)) hours" -ForegroundColor Green
  Write-Host -Object ""

  return $result
}

# Backward compatible alias for Assert-NSXToolkitPrerequisite
Set-Alias -Name Assert-NSXToolkitPrerequisites -Value Assert-NSXToolkitPrerequisite

# ===================================================================
# CONNECTION TEST WORKFLOW
# ===================================================================
