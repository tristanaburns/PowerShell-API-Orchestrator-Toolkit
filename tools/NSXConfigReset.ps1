<#
.SYNOPSIS
NSX Configuration Reset - Inventory and reset NSX DFW configuration objects

.DESCRIPTION
This tool provides a safe way to inventory and reset NSX DFW configuration objects.
It can operate in dry-run mode to show what would be deleted, or perform actual deletions.
Supports both single and multiple NSX managers.

.PARAMETER NSXManager
Target NSX Manager FQDN or IP address. For multiple managers, use comma-separated list.

.PARAMETER InventoryOnly
Only inventory existing configuration objects, don't perform any deletions

.PARAMETER WhatIf Mode
Show what would be deleted without making actual changes (default: true)

.PARAMETER ActualReset
Perform actual deletion of configuration objects (overrides WhatIf Mode)

.PARAMETER VerboseLogging
Enable verbose logging for detailed operation information

.PARAMETER UseCurrentUserCredentials
Use current Windows user credentials for authentication

.PARAMETER NonInteractive
Run without interactive prompts

.PARAMETER OutputFile
Path to save inventory results to JSON file

.PARAMETER ConfirmDestruction
Required flag to confirm destructive operations when using -ActualReset

.EXAMPLE
    .\NSXConfigReset.ps1 -NSXManager "lab-nsxlm-01.lab.vdcninja.com" -InventoryOnly
    Inventory configuration objects without any changes

.EXAMPLE
    .\NSXConfigReset.ps1 -NSXManager "lab-nsxlm-01.lab.vdcninja.com" -WhatIf Mode -VerboseLogging
    WhatIf Mode reset with verbose logging

.EXAMPLE
    .\NSXConfigReset.ps1 -NSXManager "lab-nsxlm-01.lab.vdcninja.com" -ActualReset -ConfirmDestruction -NonInteractive
    Perform actual reset with confirmation (destructive operation)

.EXAMPLE
    .\NSXConfigReset.ps1 -NSXManager "nsxmgr1.lab.com,nsxmgr2.lab.com" -WhatIf Mode -OutputFile ".\reset_analysis.json"
    WhatIf Mode reset on multiple managers and save results to file
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$NSXManager,

  [Parameter(Mandatory = $false)]
  [switch]$InventoryOnly,

  [Parameter(Mandatory = $false)]
  [switch]$WhatIfPreference,

  [Parameter(Mandatory = $false)]
  [switch]$ActualReset,

  [Parameter(Mandatory = $false)]
  [switch]$VerboseLogging,

  [Parameter(Mandatory = $false)]
  [switch]$UseCurrentUserCredentials,

  [Parameter(Mandatory = $false)]
  [switch]$ForceNewCredentials,

  [Parameter(Mandatory = $false)]
  [switch]$SaveCredentials,

  [Parameter(Mandatory = $false)]
  [string]$AuthenticationConfigFile,

  [Parameter(Mandatory = $false)]
  [string]$OutputFile,

  [Parameter(Mandatory = $false)]
  [switch]$ConfirmDestruction
)

# Initialize using centralized service framework
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

# Load all services (including WorkflowOperationsService) via the centralized service framework
. "$scriptPath\..\src\services\InitServiceFramework.ps1"

# Initialize services using SOLID-compliant factory pattern
$services = Initialize-ServiceFramework "$scriptPath\..\src\services"

# Extract services from centralized factory
$logger = $services.Logger
$credentialService = $services.CredentialService
$authService = $services.AuthService
$apiService = $services.APIService
$resetService = $services.ConfigReset
$workflowOpsService = $services.WorkflowOperationsService

# Use centralised credential management from CoreAuthenticationService

# Helper function for standardized credential collection using SharedToolCredentialService
function Get-ManagerCredentials {
  param(
    [string]$Manager,
    [bool]$UseCurrentUser,
    [bool]$ForceNew,
    [bool]$SaveCreds,
    [string]$AuthConfigFile,
    [string]$Operation
  )

  $sharedCredentialService = $services.SharedToolCredentialService
  $sharedCredentialService.DisplayCredentialCollectionStatus($Manager, $Operation, $UseCurrentUser, $ForceNew, $SaveCreds)
  # NSXConfigReset.ps1 doesn't have a Username parameter, so pass empty string for validation
  $usernameValidation = ""
  $sharedCredentialService.ValidateCredentialParameters($UseCurrentUser, $ForceNew, $usernameValidation, $AuthConfigFile)

  try {
    # NSXConfigReset.ps1 doesn't have a Username parameter, so pass empty string for current user auth or stored credentials
    $usernameParam = ""
    $credential = $sharedCredentialService.GetStandardNSXCredentials($Manager, $usernameParam, $UseCurrentUser, $ForceNew, $SaveCreds, $AuthConfigFile, $Operation)
    $logger.LogInfo("Credentials collected successfully using SharedToolCredentialService: $Manager", $Operation)
    return $credential
  }
  catch {
    # SharedToolCredentialService handles all error types and logging internally
    Write-Host -Object "FAILED: Credential collection failed for $Manager" -ForegroundColor Red
    exit 1
  }
}

# Main execution
try {
  Write-Host -Object ""
  Write-Host -Object ("=" * 80) -ForegroundColor Cyan
  Write-Host -Object "  NSX Configuration Reset" -ForegroundColor Cyan
  Write-Host -Object ("=" * 80) -ForegroundColor Cyan
  Write-Host -Object ""

  # Parse NSX managers (support comma-separated list)
  # Force to array to handle single manager case properly
  $nsxManagers = @($NSXManager -split ',' | ForEach-Object { $_.Trim() })
  $isMultiManager = $nsxManagers.Count -gt 1

  Write-Host -Object "Target NSX Manager(s): $($nsxManagers -join ', ')" -ForegroundColor Yellow
  Write-Host -Object "Operation Mode: $(if ($InventoryOnly) { 'Inventory Only' } elseif ($ActualReset) { 'ACTUAL RESET (DESTRUCTIVE)' } else { 'WhatIf Mode' })" -ForegroundColor $(if ($ActualReset) { 'Red' } else { 'Green' })
  Write-Host -Object "Verbose Logging: $VerboseLogging" -ForegroundColor Gray
  Write-Host -Object ""

  # Safety checks for destructive operations
  if ($ActualReset) {
    if (-not $ConfirmDestruction) {
      Write-Host -Object "ERROR: -ActualReset requires -ConfirmDestruction flag for safety" -ForegroundColor Red
      Write-Host -Object "This operation will permanently delete NSX configuration objects!" -ForegroundColor Red
      exit 1
    }

    if (-not $NonInteractive) {
      Write-Host -Object "WARNING: This will permanently delete NSX configuration objects!" -ForegroundColor Red
      Write-Host -Object "This includes custom services, groups, security policies, and context profiles." -ForegroundColor Red
      Write-Host -Object ""

      $confirmation = Read-Host "Are you absolutely sure you want to proceed? Type 'DELETE' to confirm"
      if ($confirmation -ne 'DELETE') {
        Write-Host -Object "Operation cancelled by user" -ForegroundColor Yellow
        exit 0
      }
    }
  }

  # Determine operation mode
  $performReset = -not $InventoryOnly
  $isWhatIfMode = $WhatIfPreference -or (-not $ActualReset)

  if ($InventoryOnly) {
    Write-Host -Object "-" * 60
    Write-Host -Object "INVENTORY OPERATION"
    Write-Host -Object "-" * 60
    Write-Host -Object ""

    if ($isMultiManager) {
      Write-Host -Object "Processing multiple NSX managers..."
      $allResults = [PSCustomObject]@{}

      foreach ($manager in $nsxManagers) {
        Write-Host -Object ""
        Write-Host -Object "Processing manager: $manager" -ForegroundColor Cyan
        Write-Host -Object "-" * 40

        try {
          # Use SharedToolCredentialService for credential collection (eliminates duplication)
          $credentials = Get-ManagerCredentials -Manager $manager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "ResetTool-Inventory"

          # ===================================================================
          # MANDATORY NSX TOOLKIT PREREQUISITE CHECK
          # ===================================================================
          Write-Host -Object "Performing mandatory NSX toolkit prerequisite checks for $manager..." -ForegroundColor Cyan

          try {
            # Load NSXConnectionTest functions
            $connectionTestPath = Join-Path $scriptPath "NSXConnectionTest.ps1"
            if (-not (Test-Path $connectionTestPath)) {
              throw "NSXConnectionTest.ps1 not found at: $connectionTestPath"
            }

            # Dot-source the connection test functions
            . $connectionTestPath

            # Define required endpoints for Config Reset operations
            $requiredEndpoints = @(
              "/policy/api/v1/infra",
              "/policy/api/v1/infra/domains",
              "/policy/api/v1/infra/domains/default/groups",
              "/policy/api/v1/infra/domains/default/security-policies",
              "/policy/api/v1/infra/services",
              "/policy/api/v1/infra/contexts"
            )

            # Run mandatory prerequisite check
            $prerequisiteResult = Assert-NSXToolkitPrerequisites -NSXManager $manager -Credential $credentials -RequiredEndpoints $requiredEndpoints -ToolName "NSXConfigReset-$manager" -AllowLimitedFunctionality

            Write-Host -Object "NSX toolkit prerequisites validated successfully for $manager" -ForegroundColor Green
            $logger.LogInfo("NSX toolkit prerequisites validated for $manager - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "ConfigReset")
          }
          catch {
            $logger.LogError("NSX toolkit prerequisite check failed for $manager : $($_.Exception.Message)", "ConfigReset")
            Write-Host -Object ""
            Write-Host -Object "[ERROR] NSX CONFIG RESET CANNOT PROCEED" -ForegroundColor Red
            Write-Host -Object "Manager: $manager" -ForegroundColor Yellow
            Write-Host -Object "Reason: Prerequisite check failed" -ForegroundColor Yellow
            Write-Host -Object "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host -Object ""
            Write-Host -Object "RESOLUTION:" -ForegroundColor Cyan
            Write-Host -Object "1. Verify NSX Manager connectivity and credentials" -ForegroundColor White
            Write-Host -Object "2. Run NSXConnectionTest.ps1 to diagnose connectivity issues" -ForegroundColor White
            Write-Host -Object "3. Ensure NSX Manager is accessible and endpoints are responding" -ForegroundColor White
            Write-Host -Object ""
            Write-Host -Object "Example: .\tools\NSXConnectionTest.ps1 -NSXManager '$manager'" -ForegroundColor Green
            Write-Host -Object ""
            throw "NSX toolkit prerequisites not met for $manager"
          }

          # ===================================================================
          # CONFIG RESET/INVENTORY OPERATIONS
          # ===================================================================

          # Proceed with inventory using validated credentials approach
          $inventory = $resetService.GetConfigurationInventory($manager, $VerboseLogging, $UseCurrentUserCredentials, $NonInteractive, $AuthenticationConfigFile, $ForceNewCredentials)
          $allResults[$manager] = $inventory

          # Display summary
          Write-Host -Object "SUCCESS: Inventory completed for $manager" -ForegroundColor Green
          Write-Host -Object "  Services: $($inventory.summary.services_count)" -ForegroundColor Cyan
          Write-Host -Object "  Groups: $($inventory.summary.groups_count)" -ForegroundColor Cyan
          Write-Host -Object "  Security Policies: $($inventory.summary.security_policies_count)" -ForegroundColor Cyan
          Write-Host -Object "  Context Profiles: $($inventory.summary.context_profiles_count)" -ForegroundColor Cyan
          Write-Host -Object "  Total Objects: $($inventory.summary.total_objects)" -ForegroundColor Yellow
        }
        catch {
          Write-Host -Object "ERROR: Failed to inventory $manager - $($_.Exception.Message)" -ForegroundColor Red
          $allResults[$manager] = [PSCustomObject]@{ error = $_.Exception.Message }
        }
      }

      $results = $allResults
    }
    else {
      Write-Host -Object "Processing single NSX manager: $($nsxManagers[0])" -ForegroundColor Cyan

      # Use SharedToolCredentialService for credential collection (eliminates duplication)
      $manager = $nsxManagers[0]
      $credentials = Get-ManagerCredentials -Manager $manager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "ResetTool-SingleInventory"

      # ===================================================================
      # MANDATORY NSX TOOLKIT PREREQUISITE CHECK
      # ===================================================================
      Write-Host -Object "Performing mandatory NSX toolkit prerequisite checks for $manager..." -ForegroundColor Cyan

      try {
        # Load NSXConnectionTest functions
        $connectionTestPath = Join-Path $scriptPath "NSXConnectionTest.ps1"
        if (-not (Test-Path $connectionTestPath)) {
          throw "NSXConnectionTest.ps1 not found at: $connectionTestPath"
        }

        # Dot-source the connection test functions
        . $connectionTestPath

        # Define required endpoints for Config Reset operations
        $requiredEndpoints = @(
          "/policy/api/v1/infra",
          "/policy/api/v1/infra/domains",
          "/policy/api/v1/infra/domains/default/groups",
          "/policy/api/v1/infra/domains/default/security-policies",
          "/policy/api/v1/infra/services",
          "/policy/api/v1/infra/contexts"
        )

        # Run mandatory prerequisite check
        $prerequisiteResult = Assert-NSXToolkitPrerequisites -NSXManager $manager -Credential $credentials -RequiredEndpoints $requiredEndpoints -ToolName "NSXConfigReset-$manager" -AllowLimitedFunctionality

        Write-Host -Object "NSX toolkit prerequisites validated successfully for $manager" -ForegroundColor Green
        $logger.LogInfo("NSX toolkit prerequisites validated for $manager - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "ConfigReset")
      }
      catch {
        $logger.LogError("NSX toolkit prerequisite check failed for $manager : $($_.Exception.Message)", "ConfigReset")
        Write-Host -Object ""
        Write-Host -Object "[ERROR] NSX CONFIG RESET CANNOT PROCEED" -ForegroundColor Red
        Write-Host -Object "Manager: $manager" -ForegroundColor Yellow
        Write-Host -Object "Reason: Prerequisite check failed" -ForegroundColor Yellow
        Write-Host -Object "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host -Object ""
        Write-Host -Object "RESOLUTION:" -ForegroundColor Cyan
        Write-Host -Object "1. Verify NSX Manager connectivity and credentials" -ForegroundColor White
        Write-Host -Object "2. Run NSXConnectionTest.ps1 to diagnose connectivity issues" -ForegroundColor White
        Write-Host -Object "3. Ensure NSX Manager is accessible and endpoints are responding" -ForegroundColor White
        Write-Host -Object ""
        Write-Host -Object "Example: .\tools\NSXConnectionTest.ps1 -NSXManager '$manager'" -ForegroundColor Green
        Write-Host -Object ""
        throw "NSX toolkit prerequisites not met for $manager"
      }

      # ===================================================================
      # CONFIG RESET/INVENTORY OPERATIONS
      # ===================================================================

      # Proceed with inventory using validated credentials approach
      $inventory = $resetService.GetConfigurationInventory($nsxManagers[0], $VerboseLogging, $UseCurrentUserCredentials, $NonInteractive, $AuthenticationConfigFile, $ForceNewCredentials)
      $results = [PSCustomObject]@{ $nsxManagers[0] = $inventory }

      # Display detailed results
      Write-Host -Object ""
      Write-Host -Object "=== INVENTORY RESULTS ===" -ForegroundColor Green
      Write-Host -Object "Services: $($inventory.summary.services_count)" -ForegroundColor Cyan
      Write-Host -Object "Groups: $($inventory.summary.groups_count)" -ForegroundColor Cyan
      Write-Host -Object "Security Policies: $($inventory.summary.security_policies_count)" -ForegroundColor Cyan
      Write-Host -Object "Context Profiles: $($inventory.summary.context_profiles_count)" -ForegroundColor Cyan
      Write-Host -Object "Total Objects: $($inventory.summary.total_objects)" -ForegroundColor Yellow
    }
  }
  else {
    Write-Host -Object "-" * 60
    Write-Host -Object "RESET OPERATION ($(if ($isWhatIfMode) { 'WhatIf Mode' } else { 'ACTUAL RESET' }))"
    Write-Host -Object "-" * 60
    Write-Host -Object ""

    if ($isMultiManager) {
      Write-Host -Object "Processing multiple NSX managers..."

      # Use SharedToolCredentialService to validate credentials for all managers first (eliminates duplication)
      foreach ($manager in $nsxManagers) {
        $credentials = Get-ManagerCredentials -Manager $manager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "ResetTool-MultiReset"
      }

      # Proceed with reset using validated credentials approach
      $results = $resetService.ResetMultipleManagers($nsxManagers, $isWhatIfMode, $VerboseLogging, $UseCurrentUserCredentials, $NonInteractive, $AuthenticationConfigFile, $ForceNewCredentials)

      # Display multi-manager results
      Write-Host -Object ""
      Write-Host -Object "=== MULTI-MANAGER RESET RESULTS ===" -ForegroundColor Green
      Write-Host -Object "Total Managers: $($results.summary.total_managers)" -ForegroundColor Cyan
      Write-Host -Object "Successful Resets: $($results.summary.successful_resets)" -ForegroundColor Green
      Write-Host -Object "Failed Resets: $($results.summary.failed_resets)" -ForegroundColor Red
      Write-Host -Object "Total Objects $(if ($isWhatIfMode) { 'Would Be ' } else { '' })Deleted: $($results.summary.total_objects_deleted)" -ForegroundColor Yellow

      foreach ($manager in $results.managers.Keys) {
        $managerResult = $results.managers[$manager]
        Write-Host -Object ""
        Write-Host -Object "Manager: $manager" -ForegroundColor Cyan
        if ($managerResult.success) {
          Write-Host -Object "  Status: SUCCESS" -ForegroundColor Green
          if ($managerResult.summary) {
            Write-Host -Object "  Services: $($managerResult.summary.services_deleted)" -ForegroundColor Cyan
            Write-Host -Object "  Groups: $($managerResult.summary.groups_deleted)" -ForegroundColor Cyan
            Write-Host -Object "  Security Policies: $($managerResult.summary.security_policies_deleted)" -ForegroundColor Cyan
            Write-Host -Object "  Context Profiles: $($managerResult.summary.context_profiles_deleted)" -ForegroundColor Cyan
          }
        }
        else {
          Write-Host -Object "  Status: FAILED" -ForegroundColor Red
          if ($managerResult.error) {
            Write-Host -Object "  Error: $($managerResult.error)" -ForegroundColor Red
          }
        }
      }
    }
    else {
      Write-Host -Object "Processing single NSX manager: $($nsxManagers[0])" -ForegroundColor Cyan

      # Use SharedToolCredentialService for credential collection (eliminates duplication)
      $manager = $nsxManagers[0]
      $credentials = Get-ManagerCredentials -Manager $manager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "ResetTool-SingleReset"

      # ===================================================================
      # MANDATORY NSX TOOLKIT PREREQUISITE CHECK
      # ===================================================================
      Write-Host -Object "Performing mandatory NSX toolkit prerequisite checks for $manager..." -ForegroundColor Cyan

      try {
        # Load NSXConnectionTest functions
        $connectionTestPath = Join-Path $scriptPath "NSXConnectionTest.ps1"
        if (-not (Test-Path $connectionTestPath)) {
          throw "NSXConnectionTest.ps1 not found at: $connectionTestPath"
        }

        # Dot-source the connection test functions
        . $connectionTestPath

        # Define required endpoints for Config Reset operations
        $requiredEndpoints = @(
          "/policy/api/v1/infra",
          "/policy/api/v1/infra/domains",
          "/policy/api/v1/infra/domains/default/groups",
          "/policy/api/v1/infra/domains/default/security-policies",
          "/policy/api/v1/infra/services",
          "/policy/api/v1/infra/contexts"
        )

        # Run mandatory prerequisite check
        $prerequisiteResult = Assert-NSXToolkitPrerequisites -NSXManager $manager -Credential $credentials -RequiredEndpoints $requiredEndpoints -ToolName "NSXConfigReset-$manager" -AllowLimitedFunctionality

        Write-Host -Object "NSX toolkit prerequisites validated successfully for $manager" -ForegroundColor Green
        $logger.LogInfo("NSX toolkit prerequisites validated for $manager - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "ConfigReset")
      }
      catch {
        $logger.LogError("NSX toolkit prerequisite check failed for $manager : $($_.Exception.Message)", "ConfigReset")
        Write-Host -Object ""
        Write-Host -Object "[ERROR] NSX CONFIG RESET CANNOT PROCEED" -ForegroundColor Red
        Write-Host -Object "Manager: $manager" -ForegroundColor Yellow
        Write-Host -Object "Reason: Prerequisite check failed" -ForegroundColor Yellow
        Write-Host -Object "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host -Object ""
        Write-Host -Object "RESOLUTION:" -ForegroundColor Cyan
        Write-Host -Object "1. Verify NSX Manager connectivity and credentials" -ForegroundColor White
        Write-Host -Object "2. Run NSXConnectionTest.ps1 to diagnose connectivity issues" -ForegroundColor White
        Write-Host -Object "3. Ensure NSX Manager is accessible and endpoints are responding" -ForegroundColor White
        Write-Host -Object ""
        Write-Host -Object "Example: .\tools\NSXConnectionTest.ps1 -NSXManager '$manager'" -ForegroundColor Green
        Write-Host -Object ""
        throw "NSX toolkit prerequisites not met for $manager"
      }

      # ===================================================================
      # CONFIG RESET/INVENTORY OPERATIONS
      # ===================================================================

      # Proceed with reset using validated credentials approach
      $resetResult = $resetService.ResetConfiguration($nsxManagers[0], $isWhatIfMode, $VerboseLogging, $UseCurrentUserCredentials, $NonInteractive, $AuthenticationConfigFile, $ForceNewCredentials)
      $results = [PSCustomObject]@{ $nsxManagers[0] = $resetResult }

      # Display detailed results
      Write-Host -Object ""
      Write-Host -Object "=== RESET RESULTS ===" -ForegroundColor Green
      Write-Host -Object "Operation: $(if ($isWhatIfMode) { 'WhatIf Mode' } else { 'ACTUAL RESET' })" -ForegroundColor Yellow
      Write-Host -Object "Success: $($resetResult.success)" -ForegroundColor $(if ($resetResult.success) { 'Green' } else { 'Red' })

      if ($resetResult.summary) {
        Write-Host -Object "Services $(if ($isWhatIfMode) { 'Would Be ' } else { '' })Deleted: $($resetResult.summary.services_deleted)" -ForegroundColor Cyan
        Write-Host -Object "Groups $(if ($isWhatIfMode) { 'Would Be ' } else { '' })Deleted: $($resetResult.summary.groups_deleted)" -ForegroundColor Cyan
        Write-Host -Object "Security Policies $(if ($isWhatIfMode) { 'Would Be ' } else { '' })Deleted: $($resetResult.summary.security_policies_deleted)" -ForegroundColor Cyan
        Write-Host -Object "Context Profiles $(if ($isWhatIfMode) { 'Would Be ' } else { '' })Deleted: $($resetResult.summary.context_profiles_deleted)" -ForegroundColor Cyan
        Write-Host -Object "Total Objects $(if ($isWhatIfMode) { 'Would Be ' } else { '' })Deleted: $($resetResult.summary.total_deleted)" -ForegroundColor Yellow
      }

      if ($resetResult.failed_deletions -and $resetResult.failed_deletions.Count -gt 0) {
        Write-Host -Object ""
        Write-Host -Object "Failed Deletions:" -ForegroundColor Red
        foreach ($failure in $resetResult.failed_deletions) {
          Write-Host -Object "  $($failure.object_type): $($failure.object_name) - $($failure.error)" -ForegroundColor Red
        }
      }
    }
  }

  # Save results to file if requested
  if ($OutputFile) {
    try {
      $outputDir = Split-Path -Parent $OutputFile
      if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
      }

      $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
      Write-Host -Object ""
      Write-Host -Object "Results saved to: $OutputFile" -ForegroundColor Green
    }
    catch {
      Write-Host -Object "Warning: Failed to save results to file: $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }

  Write-Host -Object ""
  Write-Host -Object "Operation completed successfully!" -ForegroundColor Green

  if ($isWhatIfMode -and $performReset) {
    Write-Host -Object ""
    Write-Host -Object "NOTE: This was a WhatIf Mode. Use -ActualReset -ConfirmDestruction to perform actual deletions." -ForegroundColor Yellow
  }
}
catch {
  Write-Host -Object ""
  Write-Host -Object "ERROR: $($_.Exception.Message)" -ForegroundColor Red
  $logger.LogError("NSXConfigReset failed: $($_.Exception.Message)", "ResetTool")
  exit 1
}
