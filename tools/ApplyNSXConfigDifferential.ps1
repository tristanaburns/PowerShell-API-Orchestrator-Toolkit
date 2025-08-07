# ApplyNSXConfigDifferential.ps1
# NSX configuration application tool with differential management

<#
.SYNOPSIS
    Apply NSX Configuration Differential - Safely apply configuration changes to NSX managers using a robust diff workflow.

.DESCRIPTION
    Advanced NSX configuration management with differential operations. Compares a proposed configuration file to the current NSX manager state, generates a delta, and applies only the necessary changes. Supports WhatIf Mode, delete enablement, verbose logging, and robust credential management.

.PARAMETER NSXManager
    Target NSX Manager FQDN or IP address (e.g., nsxmgr01.example.com)

.PARAMETER ConfigFile
    Path to proposed configuration JSON file

.PARAMETER WhatIf Mode
    Perform comparison and generate delta without applying changes

.PARAMETER EnableDeletes
    Allow deletion of objects not present in the proposed configuration

.PARAMETER VerboseLogging
    Enable verbose logging for troubleshooting

.PARAMETER UseCurrentUserCredentials
    Use current Windows user credentials for authentication (requires AD integration)

.PARAMETER ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist

.PARAMETER SaveCredentials
    Save credentials for future use after successful authentication

.PARAMETER Help
    Show this help information

.EXAMPLE
    .\ApplyNSXConfigDifferential.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -WhatIf Mode
    Perform a WhatIf Mode diff between the proposed config and the current NSX manager state.

.EXAMPLE
    .\ApplyNSXConfigDifferential.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -EnableDeletes
    Apply configuration, allowing deletion of objects not in the proposed config.

.EXAMPLE
    .\ApplyNSXConfigDifferential.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -VerboseLogging
    Run with verbose logging enabled for troubleshooting.

.EXAMPLE
    .\ApplyNSXConfigDifferential.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -UseCurrentUserCredentials
    Use current Windows user credentials for authentication.

.EXAMPLE
    .\ApplyNSXConfigDifferential.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist.

.EXAMPLE
    .\ApplyNSXConfigDifferential.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -SaveCredentials
    Save credentials after successful authentication for future use.

#>

[CmdletBinding()]
param(
  [string]$NSXManager,
  [string]$ConfigFile,
  [switch]$WhatIfPreference,
  [switch]$EnableDeletes,
  [switch]$VerboseLogging,
  [switch]$Help,
  [switch]$UseCurrentUserCredentials,
  [switch]$ForceNewCredentials,
  [switch]$SaveCredentials,
  [Parameter(Mandatory = $false, HelpMessage = "Directory for output files (canonical: ./data/exports)")]
  [ValidateNotNullOrEmpty()]
  [string]$OutputDirectory = [WorkflowOperationsService]::GetDataPath('Exports'), # Canonical default
  [Parameter(Mandatory = $false)]
  [object]$ValidatedState = $null
)

if ($VerboseLogging) {
  $logger.SetLogLevel("DEBUG")
}

# Show help information
if ($Help) {
  Write-Host ""
  Write-Host "================================================================================" -ForegroundColor Cyan
  Write-Host "  NSX DIFFERENTIAL CONFIGURATION MANAGEMENT TOOL" -ForegroundColor Cyan
  Write-Host "================================================================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "DESCRIPTION:" -ForegroundColor White
  Write-Host "  Advanced NSX configuration management with differential operations"
  Write-Host ""
  Write-Host "PARAMETERS:" -ForegroundColor White
  Write-Host "  -NSXManager      Target NSX Manager FQDN (required)"
  Write-Host "  -ConfigFile      Path to proposed configuration JSON file (required)"
  Write-Host "  -WhatIf Mode          Perform comparison and generate delta without applying"
  Write-Host "  -EnableDeletes   Allow deletion of objects not in proposed config"
  Write-Host "  -VerboseLogging  Enable verbose logging"
  Write-Host "  -Help            Show this help information"
  Write-Host ""
  Write-Host "EXAMPLES:" -ForegroundColor White
  Write-Host "  .\ApplyNSXConfigDifferential.ps1 -NSXManager 'nsxmgr.lab.com' -ConfigFile 'config.json' -WhatIf Mode"
  Write-Host ""
  exit 0
}

# Validate required parameters
if ([string]::IsNullOrWhiteSpace($NSXManager)) {
  Write-Host "ERROR: NSXManager parameter is required" -ForegroundColor Red
  Write-Host "Use -Help to see usage information" -ForegroundColor Yellow
  exit 1
}

if ([string]::IsNullOrWhiteSpace($ConfigFile)) {
  Write-Host "ERROR: ConfigFile parameter is required" -ForegroundColor Red
  Write-Host "Use -Help to see usage information" -ForegroundColor Yellow
  exit 1
}


# Initialize service framework using SOLID-compliant pattern
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

  # Initialize all services using centralized framework (preserves SSL bypassing)
  $services = Initialize-ServiceFramework $servicesPath

  if ($null -eq $services) {
    throw "Service framework initialization failed"
  }

  # Extract required services from centralized factory
  $logger = $services.Logger
  $credentialService = $services.CredentialService
  $authService = $services.AuthService
  $apiService = $services.APIService
  $diffMgr = $services.DifferentialConfigManager
  $workflowOpsService = $services.WorkflowOperationsService
  $dataObjectFilter = $services.DataObjectFilterService

  if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $authService -or $null -eq $apiService -or $null -eq $diffMgr -or $null -eq $workflowOpsService -or $null -eq $dataObjectFilter) {
    throw "One or more services failed to initialize properly"
  }

  Write-Host "ApplyNSXConfigDifferential: Service framework initialized successfully" -ForegroundColor Green
}
catch {
  Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
  exit 1
}

Write-Host ""
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "  DIFFERENTIAL CONFIGURATION MANAGEMENT" -ForegroundColor Cyan
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "NSX Manager: $NSXManager" -ForegroundColor White
Write-Host "Configuration File: $ConfigFile" -ForegroundColor White
Write-Host "Operation Mode: $(if ($WhatIfPreference) { 'WhatIf Mode' } else { 'LIVE APPLICATION' })" -ForegroundColor $(if ($WhatIfPreference) { 'Yellow' } else { 'Green' })
Write-Host ""

# Validate configuration file exists
if (-not (Test-Path $ConfigFile)) {
  throw "Configuration file not found: $ConfigFile"
}

# Collect credentials using shared credential service (eliminates duplication)
$sharedCredentialService = $services.SharedToolCredentialService
try {
  $sharedCredentialService.DisplayCredentialCollectionStatus($NSXManager, "ApplyConfigDifferential", $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials)
  # ApplyNSXConfigDifferential.ps1 doesn't have a Username parameter, so pass empty string for validation
  $usernameValidation = ""
  $sharedCredentialService.ValidateCredentialParameters($UseCurrentUserCredentials, $ForceNewCredentials, $usernameValidation, $null)

  # ApplyNSXConfigDifferential.ps1 doesn't have a Usern ame parameter, so pass empty string for current user auth or stored credentials
  $usernameParam = ""
  try {
    $credentials = $sharedCredentialService.GetStandardNSXCredentials($NSXManager, $usernameParam, $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials, $null, "ApplyConfigDifferential")
    $logger.LogInfo("Credentials collected successfully using SharedToolCredentialService: $NSXManager", "ApplyConfigDifferential")
  }
  catch {
    $logger.LogError("Failed to collect credentials: $($_.Exception.Message)", "ApplyConfigDifferential")
    throw "Credential collection failed: $($_.Exception.Message)"
  }
}
catch {
  # SharedToolCredentialService handles all error types and logging internally
  Write-Host "FAILED: Credential collection failed for $NSXManager" -ForegroundColor Red
  exit 1
}


# ===================================================================
# MANDATORY NSX TOOLKIT PREREQUISITE CHECK
# ===================================================================

if ($ValidatedState.Success) {
  Write-Host "NSX toolkit prerequisites already validated" -ForegroundColor Green
  Write-Host "Validated State: $($ValidatedState.Success)" -ForegroundColor Green
  Write-Host "Validation Time: $($ValidatedState.Statistics.CacheTTL) hours" -ForegroundColor Green
  Write-Host "Valid Endpoints: $($ValidatedState.Statistics.ValidEndpoints)" -ForegroundColor Green
  Write-Host "Cache Valid: $($ValidatedState.Statistics.CacheValid)" -ForegroundColor Green
  Write-Host ""
}
else {
  Write-Host "Performing mandatory NSX toolkit prerequisite checks..." -ForegroundColor Cyan

  try {
    # Load NSXConnectionTest functions
    $connectionTestPath = Join-Path $scriptPath "NSXConnectionTest.ps1"
    if (-not (Test-Path $connectionTestPath)) {
      throw "NSXConnectionTest.ps1 not found at: $connectionTestPath"
    }

    # Dot-source the connection test functions
    . $connectionTestPath

    # Define required endpoints for Differential Config operations
    $requiredEndpoints = @(
      "/policy/api/v1/infra",
      "/policy/api/v1/infra/domains",
      "/policy/api/v1/infra/domains/default/groups",
      "/policy/api/v1/infra/domains/default/security-policies",
      "/policy/api/v1/infra/services",
      "/policy/api/v1/infra/contexts",
      "/policy/api/v1/infra/realized-state"
    )

    # Run mandatory prerequisite check
    $prerequisiteResult = Assert-NSXToolkitPrerequisite -NSXManager $NSXManager -Credential $credentials -RequiredEndpoints $requiredEndpoints -ToolName "ApplyNSXConfigDifferential" -AllowLimitedFunctionality

    # Store prerequisite results for use during operations
    $script:prerequisiteData = $prerequisiteResult

    Write-Host "NSX toolkit prerequisites validated successfully" -ForegroundColor Green
    $logger.LogInfo("NSX toolkit prerequisites validated - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "ApplyConfigDifferential")
  }
  catch {
    $logger.LogError("NSX toolkit prerequisite check failed: $($_.Exception.Message)", "ApplyConfigDifferential")
    Write-Host ""
    Write-Host "[ERROR] APPLY NSX CONFIG DIFFERENTIAL CANNOT PROCEED" -ForegroundColor Red
    Write-Host "Reason: Prerequisite check failed" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "RESOLUTION:" -ForegroundColor Cyan
    Write-Host "1. Verify NSX Manager connectivity and credentials" -ForegroundColor White
    Write-Host "2. Run NSXConnectionTest.ps1 to diagnose connectivity issues" -ForegroundColor White
    Write-Host "3. Ensure NSX Manager is accessible and endpoints are responding" -ForegroundColor White
    Write-Host ""
    Write-Host "Example: .\tools\NSXConnectionTest.ps1 -NSXManager '$NSXManager'" -ForegroundColor Green
    Write-Host ""
    exit 1
  }
}

# ===================================================================
# DIFFERENTIAL CONFIGURATION OPERATIONS
# ===================================================================

# Set up operation options
$options = [PSCustomObject]@{
  WhatIfMode     = $WhatIfPreference
  EnableDeletes  = $EnableDeletes
  VerboseLogging = $VerboseLogging
}

# Child* System Object Filtering - Pass filter service to differential operations
if ($dataObjectFilter) {
  $options.DataObjectFilterService = $dataObjectFilter
  $logger.LogInfo("Child* system object filtering integrated into differential operations", "ApplyConfigDifferential")
}

# Execute differential configuration management workflow
Write-Host "Executing differential configuration management workflow..." -ForegroundColor Yellow
Write-Host ""

$result = $diffMgr.ExecuteDifferentialOperation($NSXManager, $credentials, $ConfigFile, $options)

# Display results
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "  DIFFERENTIAL CONFIGURATION RESULTS" -ForegroundColor Cyan
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Operation ID: $($result.operation_id)" -ForegroundColor White
Write-Host "Timestamp: $($result.timestamp)" -ForegroundColor White
Write-Host "NSX Manager: $($result.nsx_manager)" -ForegroundColor White
Write-Host ""

# Show configuration analysis
if ($result.results.ExistingConfig) {
  Write-Host "EXISTING CONFIGURATION:" -ForegroundColor Yellow
  Write-Host "  - Objects: $($result.results.ExistingConfig.ObjectCount)" -ForegroundColor White
  Write-Host "  - Baseline saved: $($result.results.ExistingConfigPath)" -ForegroundColor Gray
  Write-Host ""
}

if ($result.results.ProposedConfig) {
  Write-Host "PROPOSED CONFIGURATION:" -ForegroundColor Yellow
  Write-Host "  - Objects: $($result.results.ProposedConfig.ObjectCount)" -ForegroundColor White
  Write-Host "  - Source: $($result.results.ProposedConfig.Path)" -ForegroundColor Gray
  Write-Host ""
}

# Show differences analysis
if ($result.results.Differences) {
  $diff = $result.results.Differences
  Write-Host "CONFIGURATION DIFFERENCES:" -ForegroundColor Yellow
  Write-Host "  - Create: $($diff.CreateCount) objects" -ForegroundColor Green
  Write-Host "  - Update: $($diff.UpdateCount) objects" -ForegroundColor Yellow
  Write-Host "  - Delete: $($diff.DeleteCount) objects" -ForegroundColor Red
  Write-Host "  - Unchanged: $($diff.UnchangedCount) objects" -ForegroundColor Gray
  Write-Host "  - Total changes: $($diff.TotalChanges)" -ForegroundColor Cyan
  Write-Host "  - Delta config saved: $($result.results.DeltaConfigPath)" -ForegroundColor Gray

  # Display Child* system object filtering statistics if available
  if ($diff.FilteringStatistics -and $diff.FilteringStatistics.FilteredChildSystemObjects) {
    Write-Host "  - Child* system objects filtered: $($diff.FilteringStatistics.FilteredChildSystemObjects)" -ForegroundColor Magenta
    $logger.LogInfo("Child* system object filtering applied: $($diff.FilteringStatistics.FilteredChildSystemObjects) objects filtered out", "ApplyConfigDifferential")
  }
  elseif ($dataObjectFilter) {
    Write-Host "  - Child* system object filtering: Applied (see logs for details)" -ForegroundColor Magenta
  }
  Write-Host ""
}

# Show application results (if not WhatIf Mode)
if ((-not $WhatIfPreference) -and $result.results.ApplyResults) {
  $apply = $result.results.ApplyResults
  Write-Host "APPLICATION RESULTS:" -ForegroundColor Yellow
  Write-Host "  - Successful operations: $($apply.success_count)" -ForegroundColor Green
  Write-Host "  - Failed operations: $($apply.failure_count)" -ForegroundColor Red

  $successRate = 0
  if (($apply.success_count + $apply.failure_count) -gt 0) {
    $successRate = [math]::Round(($apply.success_count / ($apply.success_count + $apply.failure_count)) * 100, 2)
  }
  Write-Host "  - Success rate: $successRate%" -ForegroundColor Cyan
  Write-Host ""
}

# Show verification results (if not WhatIf Mode)
if ((-not $WhatIfPreference) -and $result.results.Verification) {
  $verify = $result.results.Verification.results
  Write-Host "VERIFICATION RESULTS:" -ForegroundColor Yellow
  Write-Host "  - Verified: $($verify.verified_count)/$($verify.total_expected)" -ForegroundColor Green
  Write-Host "  - Failed: $($verify.failed_count)" -ForegroundColor Red
  Write-Host "  - Success rate: $($verify.success_rate)%" -ForegroundColor Cyan
  Write-Host "  - Verification report: $($result.results.VerificationPath)" -ForegroundColor Gray
  Write-Host ""
}

# Show summary
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "  OPERATION SUMMARY" -ForegroundColor Cyan
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""

if ($WhatIfPreference) {
  if ($result.results.Differences.TotalChanges -eq 0) {
    Write-Host "NO CHANGES REQUIRED" -ForegroundColor Green
    Write-Host "   The proposed configuration matches the existing configuration." -ForegroundColor Gray
  }
  else {
    Write-Host "CHANGES IDENTIFIED" -ForegroundColor Yellow
    Write-Host "   $($result.results.Differences.TotalChanges) changes would be applied." -ForegroundColor Gray
    Write-Host "   Run without -WhatIf Mode to apply the changes." -ForegroundColor Gray
  }
}
else {
  if ($result.results.Verification.results.success_rate -eq 100) {
    Write-Host "CONFIGURATION APPLIED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "   All changes were applied and verified successfully." -ForegroundColor Gray
  }
  else {
    Write-Host "CONFIGURATION PARTIALLY APPLIED" -ForegroundColor Yellow
    Write-Host "   Some changes may not have been applied correctly." -ForegroundColor Gray
    Write-Host "   Check the verification report for details." -ForegroundColor Gray
  }
}

Write-Host ""
Write-Host "Operation completed successfully!" -ForegroundColor Green

# Child* System Object Filtering Summary
if ($dataObjectFilter) {
  Write-Host ""
  Write-Host "CAPABILITIES APPLIED:" -ForegroundColor Cyan
  Write-Host "  - Child* System Object Filtering: ACTIVE" -ForegroundColor Green
  Write-Host "    Compound filtering for resource_type='Child*' AND _system_owned=true" -ForegroundColor Gray
  Write-Host "    Configuration-driven via data-objects-filter.json" -ForegroundColor Gray
}
Write-Host ""

# Show generated files
Write-Host "GENERATED FILES:" -ForegroundColor White
if ($result.results.ExistingConfigPath) {
  Write-Host "  Baseline: $($result.results.ExistingConfigPath)" -ForegroundColor Gray
}
if ($result.results.DeltaConfigPath) {
  Write-Host "  Delta: $($result.results.DeltaConfigPath)" -ForegroundColor Gray
}
if ($result.results.VerificationPath) {
  Write-Host "  Verification: $($result.results.VerificationPath)" -ForegroundColor Gray
}
Write-Host ""

exit 0

catch {
  Write-Host ""
  Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host ""

  if ($logger) {
    $logger.LogError("Differential configuration operation failed: $($_.Exception.Message)", "ApplyConfigDifferential")
  }

  exit 1
}
