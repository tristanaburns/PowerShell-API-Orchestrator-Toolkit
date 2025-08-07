# NSXConnectionDiagnostics.ps1 - NSX Connection Troubleshooting Tool
<#
.SYNOPSIS
    diagnostic tool for NSX connection issues, credential problems, and SSL errors.

.DESCRIPTION
    This tool diagnoses and repairs common NSX connectivity issues including:
    - 403 Forbidden errors (credential problems)
    - SSL/TLS compilation errors
    - Service framework issues
    - Certificate validation problems
    - Network connectivity tests

.PARAMETER NSXManager
    NSX Manager FQDN or IP address to diagnose. Default: "lab-nsxlm-01.lab.vdcninja.com"

.PARAMETER RepairCredentials
    Automatically attempt to repair credential issues.

.PARAMETER ResetSSL
    Reset SSL/TLS configuration and bypass settings.

.PARAMETER TestNetwork
    Perform basic network connectivity tests.

.PARAMETER ForceCredentialReset
    Force complete credential reset and re-setup.

.PARAMETER Verbose
    Enable verbose diagnostic output.

.EXAMPLE
    .\NSXConnectionDiagnostics.ps1 -NSXManager "lab-nsxlm-01.lab.vdcninja.com" -RepairCredentials
    Diagnose and repair credential issues for the specified NSX Manager.

.EXAMPLE
    .\NSXConnectionDiagnostics.ps1 -NSXManager "lab-nsxlm-01.lab.vdcninja.com" -ResetSSL -TestNetwork
    Run full diagnostic with SSL reset and network tests.
#>

[CmdletBinding()]
param(
  [Parameter(HelpMessage = "NSX Manager FQDN or IP address")]
  [ValidateNotNullOrEmpty()]
  [string]$NSXManager = "lab-nsxlm-01.lab.vdcninja.com",

  [Parameter(HelpMessage = "Automatically repair credential issues")]
  [switch]$RepairCredentials,

  [Parameter(HelpMessage = "Reset SSL/TLS configuration")]
  [switch]$ResetSSL,

  [Parameter(HelpMessage = "Test network connectivity")]
  [switch]$TestNetwork,

  [Parameter(HelpMessage = "Force complete credential reset")]
  [switch]$ForceCredentialReset,

  [Parameter(HelpMessage = "Enable verbose diagnostic output")]
  [switch]$VerboseOutput
)

# ===================================================================
# DIAGNOSTIC FRAMEWORK INITIALIZATION
# ===================================================================

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$servicesPath = "$scriptPath\..\src\services"

# Global diagnostic state
$script:DiagnosticResults = @{
  OverallStatus   = "Unknown"
  Issues          = @()
  Repairs         = @()
  Recommendations = @()
  TestResults     = [PSCustomObject]@{}
}

function Write-DiagnosticOutput {
  param($Message, $Level = "INFO", $Color = "White")
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $prefix = switch ($Level.ToUpper()) {
    "ERROR" { "[ERROR]"; $Color = "Red" }
    "WARN" { "WARN"; $Color = "Yellow" }
    "WARNING" { "WARN"; $Color = "Yellow" }
    "SUCCESS" { "[SUCCESS]"; $Color = "Green" }
    "INFO" { "INFO"; $Color = "Cyan" }
    "DEBUG" { "DEBUG"; $Color = "Gray" }
    default { "LOG"; $Color = "White" }
  }

  Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $Color

  # Add to diagnostic results
  $script:DiagnosticResults.Issues += @{
    Timestamp = $timestamp
    Level     = $Level
    Message   = $Message
  }
}

# ===================================================================
# SERVICE FRAMEWORK DIAGNOSTIC FUNCTIONS
# ===================================================================

function Test-ServiceFrameworkAvailability {
  Write-DiagnosticOutput "=== TESTING SERVICE FRAMEWORK AVAILABILITY ===" "INFO"

  try {
    if (Test-Path "$scriptPath\..\src\services\InitServiceFramework.ps1") {
      Write-DiagnosticOutput "Service framework initialization script found" "SUCCESS"

      # Attempt to load service framework
      . "$scriptPath\..\src\services\InitServiceFramework.ps1"
      $services = Initialize-ServiceFramework $servicesPath

      if ($null -ne $services) {
        Write-DiagnosticOutput "Service framework initialized successfully" "SUCCESS"
        $script:DiagnosticResults.TestResults["ServiceFramework"] = "Available"
        return $services
      }
      else {
        Write-DiagnosticOutput "Service framework initialization returned null" "ERROR"
        $script:DiagnosticResults.TestResults["ServiceFramework"] = "Failed"
        return $null
      }
    }
    else {
      Write-DiagnosticOutput "Service framework initialization script not found" "ERROR"
      $script:DiagnosticResults.TestResults["ServiceFramework"] = "Missing"
      return $null
    }
  }
  catch {
    Write-DiagnosticOutput "Service framework initialization failed: $($_.Exception.Message)" "ERROR"
    $script:DiagnosticResults.TestResults["ServiceFramework"] = "Error: $($_.Exception.Message)"
    return $null
  }
}

function Test-CoreServiceAvailability {
  param($services)

  Write-DiagnosticOutput "=== TESTING CORE SERVICE AVAILABILITY ===" "INFO"

  $serviceTests = [PSCustomObject]@{
    "Logger"                  = $services.Logger
    "CredentialService"       = $services.CredentialService
    "AuthService"             = $services.AuthService
    "WorkflowOpsService"      = $services.WorkflowOperationsService
    "APIService"              = $services.APIService
    "OpenAPISchemaService"    = $services.OpenAPISchemaService
    "DataObjectFilterService" = $services.DataObjectFilterService
    "NSXConfigValidator"      = $services.NSXConfigValidator
  }

  foreach ($serviceName in $serviceTests.Keys) {
    $service = $serviceTests[$serviceName]
    if ($null -ne $service) {
      Write-DiagnosticOutput "${serviceName}: Available" "SUCCESS"
      $script:DiagnosticResults.TestResults[$serviceName] = "Available"
    }
    else {
      Write-DiagnosticOutput "${serviceName}: Unavailable" "WARN"
      $script:DiagnosticResults.TestResults[$serviceName] = "Unavailable"
    }
  }
}

# ===================================================================
# NETWORK AND CONNECTIVITY DIAGNOSTIC FUNCTIONS
# ===================================================================

function Test-NetworkConnectivity {
  param([string]$NSXManager)

  Write-DiagnosticOutput "=== TESTING NETWORK CONNECTIVITY ===" "INFO"

  # DNS Resolution Test
  try {
    $ipAddress = [System.Net.Dns]::GetHostAddresses($NSXManager)
    Write-DiagnosticOutput "DNS Resolution: $NSXManager resolves to $($ipAddress[0])" "SUCCESS"
    $script:DiagnosticResults.TestResults["DNS"] = "Success: $($ipAddress[0])"
  }
  catch {
    Write-DiagnosticOutput "DNS Resolution: Failed to resolve $NSXManager" "ERROR"
    $script:DiagnosticResults.TestResults["DNS"] = "Failed: $($_.Exception.Message)"
    return $false
  }

  # Basic TCP connectivity test (port 443)
  try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.ConnectAsync($NSXManager, 443).Wait(5000)
    if ($tcpClient.Connected) {
      Write-DiagnosticOutput "TCP Connectivity: Port 443 accessible" "SUCCESS"
      $script:DiagnosticResults.TestResults["TCP443"] = "Success"
      $tcpClient.Close()
    }
    else {
      Write-DiagnosticOutput "TCP Connectivity: Port 443 not accessible" "ERROR"
      $script:DiagnosticResults.TestResults["TCP443"] = "Failed"
      return $false
    }
  }
  catch {
    Write-DiagnosticOutput "TCP Connectivity: Port 443 test failed - $($_.Exception.Message)" "ERROR"
    $script:DiagnosticResults.TestResults["TCP443"] = "Error: $($_.Exception.Message)"
    return $false
  }

  # HTTPS endpoint test (without authentication)
  try {
    $testUri = "https://$NSXManager/api/v1/node"
    Write-DiagnosticOutput "Testing HTTPS endpoint: $testUri" "INFO"

    # Use basic Invoke-WebRequest to test SSL handshake
    try {
      $response = Invoke-WebRequest -Uri $testUri -Method HEAD -TimeoutSec 10 -SkipCertificateCheck -ErrorAction Stop
      Write-DiagnosticOutput "HTTPS Endpoint: SSL handshake successful" "SUCCESS"
      $script:DiagnosticResults.TestResults["HTTPS"] = "SSL Success"
    }
    catch {
      if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 403) {
        Write-DiagnosticOutput "HTTPS Endpoint: SSL handshake successful, authentication required (expected)" "SUCCESS"
        $script:DiagnosticResults.TestResults["HTTPS"] = "SSL Success, Auth Required"
      }
      else {
        Write-DiagnosticOutput "HTTPS Endpoint: SSL/Network issue - $($_.Exception.Message)" "WARN"
        $script:DiagnosticResults.TestResults["HTTPS"] = "SSL Warning: $($_.Exception.Message)"
      }
    }
  }
  catch {
    Write-DiagnosticOutput "HTTPS Endpoint: Failed - $($_.Exception.Message)" "ERROR"
    $script:DiagnosticResults.TestResults["HTTPS"] = "Failed: $($_.Exception.Message)"
  }

  return $true
}

# ===================================================================
# SSL/TLS DIAGNOSTIC AND REPAIR FUNCTIONS
# ===================================================================

function Test-SSLConfiguration {
  Write-DiagnosticOutput "=== TESTING SSL/TLS CONFIGURATION ===" "INFO"

  # Test PowerShell version compatibility
  $psVersion = $PSVersionTable.PSVersion
  Write-DiagnosticOutput "PowerShell Version: $psVersion" "INFO"
  $script:DiagnosticResults.TestResults["PSVersion"] = $psVersion.ToString()

  # Test TLS protocol support
  $supportedProtocols = [System.Net.ServicePointManager]::SecurityProtocol
  Write-DiagnosticOutput "Supported TLS Protocols: $supportedProtocols" "INFO"
  $script:DiagnosticResults.TestResults["TLSProtocols"] = $supportedProtocols.ToString()

  # Test if TrustAllCertsPolicy type exists
  if ("TrustAllCertsPolicy" -as [type]) {
    Write-DiagnosticOutput "TrustAllCertsPolicy: Type available" "SUCCESS"
    $script:DiagnosticResults.TestResults["TrustAllCertsPolicy"] = "Available"
  }
  else {
    Write-DiagnosticOutput "TrustAllCertsPolicy: Type not available" "WARN"
    $script:DiagnosticResults.TestResults["TrustAllCertsPolicy"] = "Unavailable"
  }

  # Test current certificate policy
  $currentPolicy = [System.Net.ServicePointManager]::CertificatePolicy
  if ($null -ne $currentPolicy) {
    Write-DiagnosticOutput "Certificate Policy: $($currentPolicy.GetType().Name)" "INFO"
    $script:DiagnosticResults.TestResults["CertPolicy"] = $currentPolicy.GetType().Name
  }
  else {
    Write-DiagnosticOutput "Certificate Policy: None set" "INFO"
    $script:DiagnosticResults.TestResults["CertPolicy"] = "None"
  }
}

function Repair-SSLConfiguration {
  Write-DiagnosticOutput "=== REPAIRING SSL CONFIGURATION ===" "INFO"

  try {
    # Reset SSL configuration
    Write-DiagnosticOutput "Resetting SSL/TLS configuration..." "INFO"

    # Set secure TLS protocols
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13
    [System.Net.ServicePointManager]::CheckCertificateRevocationList = $false
    [System.Net.ServicePointManager]::DefaultConnectionLimit = 50
    [System.Net.ServicePointManager]::Expect100Continue = $false

    Write-DiagnosticOutput "Basic SSL settings configured" "SUCCESS"

    # Attempt to create TrustAllCertsPolicy
    if (-not ("TrustAllCertsPolicy" -as [type])) {
      try {
        Add-Type -TypeDefinition @"
                    using System.Net;
                    using System.Security.Cryptography.X509Certificates;

                    public class TrustAllCertsPolicy : ICertificatePolicy {
                        public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                            return true;
                        }
                    }
"@
        Write-DiagnosticOutput "TrustAllCertsPolicy type created successfully" "SUCCESS"

        # Apply the policy
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        Write-DiagnosticOutput "TrustAllCertsPolicy applied successfully" "SUCCESS"

        $script:DiagnosticResults.Repairs += "SSL Configuration repaired successfully"
        return $true

      }
      catch {
        Write-DiagnosticOutput "Failed to create TrustAllCertsPolicy: $($_.Exception.Message)" "WARN"
        Write-DiagnosticOutput "Continuing with basic SSL settings only" "INFO"
        $script:DiagnosticResults.Repairs += "Partial SSL repair - basic settings only"
        return $false
      }
    }
    else {
      [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
      Write-DiagnosticOutput "Existing TrustAllCertsPolicy applied successfully" "SUCCESS"
      $script:DiagnosticResults.Repairs += "SSL Configuration verified and applied"
      return $true
    }
  }
  catch {
    Write-DiagnosticOutput "SSL configuration repair failed: $($_.Exception.Message)" "ERROR"
    $script:DiagnosticResults.Repairs += "SSL repair failed: $($_.Exception.Message)"
    return $false
  }
}

# ===================================================================
# CREDENTIAL DIAGNOSTIC AND REPAIR FUNCTIONS
# ===================================================================

function Test-StoredCredentials {
  param([string]$NSXManager, $services)

  Write-DiagnosticOutput "=== TESTING STORED CREDENTIALS ===" "INFO"

  if ($null -eq $services -or $null -eq $services.CredentialService) {
    Write-DiagnosticOutput "Credential service not available for testing" "ERROR"
    $script:DiagnosticResults.TestResults["StoredCredentials"] = "Service Unavailable"
    return $false
  }

  try {
    $storedCred = $services.CredentialService.LoadCredentials($NSXManager)
    if ($null -ne $storedCred) {
      Write-DiagnosticOutput "Stored credentials found for: $NSXManager" "SUCCESS"
      Write-DiagnosticOutput "Username: $($storedCred.UserName)" "INFO"
      $script:DiagnosticResults.TestResults["StoredCredentials"] = "Found: $($storedCred.UserName)"
      return $storedCred
    }
    else {
      Write-DiagnosticOutput "No stored credentials found for: $NSXManager" "WARN"
      $script:DiagnosticResults.TestResults["StoredCredentials"] = "Not Found"
      return $null
    }
  }
  catch {
    Write-DiagnosticOutput "Failed to load stored credentials: $($_.Exception.Message)" "ERROR"
    $script:DiagnosticResults.TestResults["StoredCredentials"] = "Error: $($_.Exception.Message)"
    return $null
  }
}

function Test-CredentialValidity {
  param([string]$NSXManager, [PSCredential]$Credential, $services)

  Write-DiagnosticOutput "=== TESTING CREDENTIAL VALIDITY ===" "INFO"

  if ($null -eq $Credential) {
    Write-DiagnosticOutput "No credentials provided for testing" "ERROR"
    return $false
  }

  try {
    # Use basic REST call to test credentials
    $testUri = "https://$NSXManager/api/v1/node"
    $restParams = [PSCustomObject]@{
      Uri        = $testUri
      Method     = 'GET'
      Credential = $Credential
      TimeoutSec = 15
    }

    # Add SSL bypass if available
    if ($PSVersionTable.PSVersion.Major -ge 6) {
      $restParams.SkipCertificateCheck = $true
    }

    Write-DiagnosticOutput "Testing credentials against: $testUri" "INFO"
    $response = Invoke-RestMethod @restParams

    if ($response -and $response.node_id) {
      Write-DiagnosticOutput "Credential validation: SUCCESS" "SUCCESS"
      Write-DiagnosticOutput "Node ID: $($response.node_id)" "INFO"
      Write-DiagnosticOutput "Version: $($response.version)" "INFO"
      $script:DiagnosticResults.TestResults["CredentialValidity"] = "Valid"
      return $true
    }
    else {
      Write-DiagnosticOutput "Credential validation: Unexpected response" "WARN"
      $script:DiagnosticResults.TestResults["CredentialValidity"] = "Unexpected Response"
      return $false
    }
  }
  catch {
    $statusCode = "Unknown"
    if ($_.Exception.Response) {
      $statusCode = $_.Exception.Response.StatusCode
    }

    Write-DiagnosticOutput "Credential validation: FAILED" "ERROR"
    Write-DiagnosticOutput "Error: $($_.Exception.Message)" "ERROR"
    Write-DiagnosticOutput "Status Code: $statusCode" "ERROR"

    $script:DiagnosticResults.TestResults["CredentialValidity"] = "Failed: $statusCode"

    # Provide specific guidance based on error
    if ($statusCode -eq 401) {
      Write-DiagnosticOutput "401 Unauthorized: Invalid username or password" "ERROR"
      $script:DiagnosticResults.Recommendations += "Invalid credentials - reset required"
    }
    elseif ($statusCode -eq 403) {
      Write-DiagnosticOutput "403 Forbidden: Valid credentials but insufficient permissions or account locked" "ERROR"
      $script:DiagnosticResults.Recommendations += "Account may be locked or lack permissions"
    }
    else {
      Write-DiagnosticOutput "Network or SSL error - check connectivity" "ERROR"
      $script:DiagnosticResults.Recommendations += "Network or SSL configuration issue"
    }

    return $false
  }
}

function Repair-Credentials {
  param([string]$NSXManager, $services)

  Write-DiagnosticOutput "=== CREDENTIAL REPAIR PROCESS ===" "INFO"

  if ($null -eq $services -or $null -eq $services.CredentialService) {
    Write-DiagnosticOutput "Credential service not available for repair" "ERROR"
    return $false
  }

  try {
    Write-DiagnosticOutput "Starting interactive credential setup for: $NSXManager" "INFO"
    Write-DiagnosticOutput "Please provide valid NSX Manager credentials..." "INFO"

    # Collect new credentials
    $username = Read-Host "Username (default: admin)"
    if ([string]::IsNullOrEmpty($username)) { $username = "admin" }

    $securePassword = Read-Host "Password" -AsSecureString
    $newCredential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

    # Test new credentials
    Write-DiagnosticOutput "Testing new credentials..." "INFO"
    $validationResult = Test-CredentialValidity -NSXManager $NSXManager -Credential $newCredential -services $services

    if ($validationResult) {
      # Save working credentials
      try {
        $services.CredentialService.SaveCredentials($NSXManager, $newCredential)
        Write-DiagnosticOutput "New credentials saved successfully" "SUCCESS"
        $script:DiagnosticResults.Repairs += "Credentials repaired and saved for $NSXManager"
        return $true
      }
      catch {
        Write-DiagnosticOutput "Failed to save credentials: $($_.Exception.Message)" "ERROR"
        $script:DiagnosticResults.Repairs += "Credential validation succeeded but save failed"
        return $false
      }
    }
    else {
      Write-DiagnosticOutput "New credentials failed validation" "ERROR"
      $script:DiagnosticResults.Repairs += "Credential repair failed - validation unsuccessful"
      return $false
    }
  }
  catch {
    Write-DiagnosticOutput "Credential repair process failed: $($_.Exception.Message)" "ERROR"
    $script:DiagnosticResults.Repairs += "Credential repair process error: $($_.Exception.Message)"
    return $false
  }
}

# ===================================================================
# MAIN DIAGNOSTIC WORKFLOW
# ===================================================================

function Start-ComprehensiveDiagnostics {
  param([string]$NSXManager)

  Write-DiagnosticOutput "STARTING NSX CONNECTION DIAGNOSTICS" "INFO"
  Write-DiagnosticOutput "Target NSX Manager: $NSXManager" "INFO"
  Write-DiagnosticOutput "Timestamp: $(Get-Date)" "INFO"
  Write-DiagnosticOutput "=" * 80 "INFO"

  # Phase 1: Service Framework Tests
  $services = Test-ServiceFrameworkAvailability
  if ($null -ne $services) {
    Test-CoreServiceAvailability -services $services
  }

  # Phase 2: Network Connectivity Tests
  if ($TestNetwork) {
    $networkOk = Test-NetworkConnectivity -NSXManager $NSXManager
    if (-not $networkOk) {
      Write-DiagnosticOutput "Network connectivity issues detected - cannot proceed with further tests" "ERROR"
      $script:DiagnosticResults.OverallStatus = "Network Failure"
      return
    }
  }

  # Phase 3: SSL/TLS Configuration Tests
  Test-SSLConfiguration
  if ($ResetSSL) {
    Repair-SSLConfiguration
  }

  # Phase 4: Credential Tests
  if ($null -ne $services) {
    $storedCredentials = Test-StoredCredentials -NSXManager $NSXManager -services $services

    if ($null -ne $storedCredentials) {
      $credentialsValid = Test-CredentialValidity -NSXManager $NSXManager -Credential $storedCredentials -services $services

      if (-not $credentialsValid) {
        if ($RepairCredentials -or $ForceCredentialReset) {
          Write-DiagnosticOutput "Attempting automatic credential repair..." "INFO"
          $repairResult = Repair-Credentials -NSXManager $NSXManager -services $services

          if ($repairResult) {
            # Retest with new credentials
            $newCredentials = Test-StoredCredentials -NSXManager $NSXManager -services $services
            Test-CredentialValidity -NSXManager $NSXManager -Credential $newCredentials -services $services
          }
        }
        else {
          Write-DiagnosticOutput "Credential repair not requested - use -RepairCredentials to fix" "WARN"
          $script:DiagnosticResults.Recommendations += "Run with -RepairCredentials to fix credential issues"
        }
      }
    }
    else {
      if ($RepairCredentials -or $ForceCredentialReset) {
        Write-DiagnosticOutput "No stored credentials found - setting up new credentials..." "INFO"
        Repair-Credentials -NSXManager $NSXManager -services $services
      }
      else {
        Write-DiagnosticOutput "No stored credentials - use -RepairCredentials to set up" "WARN"
        $script:DiagnosticResults.Recommendations += "No credentials found - run with -RepairCredentials to set up"
      }
    }
  }

  # Determine overall status
  $criticalFailures = ($script:DiagnosticResults.TestResults.Values | Where-Object { $_ -like "*Failed*" -or $_ -like "*Error*" }).Count
  $warnings = ($script:DiagnosticResults.TestResults.Values | Where-Object { $_ -like "*Warning*" -or $_ -like "*Unavailable*" }).Count

  if ($criticalFailures -eq 0) {
    if ($warnings -eq 0) {
      $script:DiagnosticResults.OverallStatus = "Healthy"
    }
    else {
      $script:DiagnosticResults.OverallStatus = "Warning"
    }
  }
  else {
    $script:DiagnosticResults.OverallStatus = "Failed"
  }
}

function Show-DiagnosticSummary {
  Write-DiagnosticOutput "=" * 80 "INFO"
  Write-DiagnosticOutput " DIAGNOSTIC SUMMARY REPORT" "INFO"
  Write-DiagnosticOutput "=" * 80 "INFO"

  # Overall Status
  $statusColor = switch ($script:DiagnosticResults.OverallStatus) {
    "Healthy" { "Green" }
    "Warning" { "Yellow" }
    "Failed" { "Red" }
    default { "Gray" }
  }
  Write-Host "Overall Status: $($script:DiagnosticResults.OverallStatus)" -ForegroundColor $statusColor

  # Test Results Summary
  Write-DiagnosticOutput "" "INFO"
  Write-DiagnosticOutput " TEST RESULTS:" "INFO"
  foreach ($test in $script:DiagnosticResults.TestResults.Keys) {
    $result = $script:DiagnosticResults.TestResults[$test]
    $resultColor = if ($result -like "*Success*" -or $result -like "*Available*" -or $result -like "*Valid*") {
      "Green"
    }
    elseif ($result -like "*Warning*" -or $result -like "*Unavailable*") {
      "Yellow"
    }
    else {
      "Red"
    }
    Write-Host "  $test`: $result" -ForegroundColor $resultColor
  }

  # Repairs Applied
  if ($script:DiagnosticResults.Repairs.Count -gt 0) {
    Write-DiagnosticOutput "" "INFO"
    Write-DiagnosticOutput " REPAIRS APPLIED:" "INFO"
    foreach ($repair in $script:DiagnosticResults.Repairs) {
      Write-DiagnosticOutput "  - $repair" "SUCCESS"
    }
  }

  # Recommendations
  if ($script:DiagnosticResults.Recommendations.Count -gt 0) {
    Write-DiagnosticOutput "" "INFO"
    Write-DiagnosticOutput " RECOMMENDATIONS:" "INFO"
    foreach ($recommendation in $script:DiagnosticResults.Recommendations) {
      Write-DiagnosticOutput "  - $recommendation" "WARN"
    }
  }

  # Next Steps
  Write-DiagnosticOutput "" "INFO"
  Write-DiagnosticOutput " NEXT STEPS:" "INFO"
  if ($script:DiagnosticResults.OverallStatus -eq "Healthy") {
    Write-DiagnosticOutput "  - Connection should now work - test with NSXConnectionTest.ps1" "SUCCESS"
    Write-DiagnosticOutput "  - Proceed with normal NSX toolkit operations" "SUCCESS"
  }
  elseif ($script:DiagnosticResults.OverallStatus -eq "Warning") {
    Write-DiagnosticOutput "  - Basic functionality available but some features may be limited" "WARN"
    Write-DiagnosticOutput "  - Address warnings if full functionality is needed" "WARN"
  }
  else {
    Write-DiagnosticOutput "  - Critical issues remain - address failed components before proceeding" "ERROR"
    Write-DiagnosticOutput "  - Consider running diagnostic again with repair options" "ERROR"
  }
}

# ===================================================================
# MAIN EXECUTION
# ===================================================================

Write-DiagnosticOutput "NSX CONNECTION DIAGNOSTICS TOOL" "INFO"
Write-DiagnosticOutput "Target: $NSXManager" "INFO"
Write-DiagnosticOutput "Options: RepairCredentials=$RepairCredentials, ResetSSL=$ResetSSL, TestNetwork=$TestNetwork" "INFO"

# Run diagnostics
Start-ComprehensiveDiagnostics -NSXManager $NSXManager

# Show summary report
Show-DiagnosticSummary

Write-DiagnosticOutput "=" * 80 "INFO"
Write-DiagnosticOutput "Diagnostics completed at $(Get-Date)" "INFO"
