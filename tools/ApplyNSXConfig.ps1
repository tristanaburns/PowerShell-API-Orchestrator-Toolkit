<#
.SYNOPSIS
    Apply NSX Configuration - Safely apply configurations to NSX managers using the hierarchical API.

.DESCRIPTION
    Dedicated tool for applying configuration files to NSX managers. Supports exporting existing configurations, backup, WhatIf Mode, verbose logging, and robust credential management.

.PARAMETER NSXManager
    Target NSX Manager FQDN or IP address (e.g., nsxmgr01.example.com)

.PARAMETER ConfigFile
    Path to configuration JSON file to apply

.PARAMETER BackupFirst
    Create a backup of existing configuration before applying new config

.PARAMETER UseCurrentUserCredentials
    Use current Windows user credentials for authentication (requires AD integration)

.PARAMETER NonInteractive
    Run without interactive prompts (for automation)

.PARAMETER ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist

.PARAMETER SaveCredentials
    Save credentials for future use after successful authentication

.PARAMETER AuthenticationConfigFile
    Optional authentication configuration file (currently unused - script uses standardized credential management)

.PARAMETER OutputDirectory
    Directory to save exported configurations (default: .\data\exports)

.PARAMETER UseSingleEndpoint
    Use single /policy/api/v1/infra endpoint to export entire configuration instead of separate API calls

.PARAMETER WhatIf Mode
    Show what would be applied without making actual changes

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ExportOnly
    Export existing configuration from NSX manager.

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -ApplyConfig -BackupFirst
    Apply configuration with backup of existing state.

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -WhatIf Mode
    Perform a WhatIf Mode apply of the configuration.

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -UseCurrentUserCredentials
    Use current Windows user credentials for authentication.

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -NonInteractive
    Run in non-interactive mode (for automation/scheduled tasks).

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist.

.EXAMPLE
    .\ApplyNSXConfig.ps1 -NSXManager "nsxmgr01.example.com" -ConfigFile "config.json" -SaveCredentials
    Save credentials after successful authentication for future use.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$NSXManager,

    [Parameter(Mandatory = $false)]
    [string]$ConfigFile,

    [Parameter(Mandatory = $false)]
    [switch]$BackupFirst,

    [Parameter(Mandatory = $false)]
    [switch]$UseCurrentUserCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$ForceNewCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$SaveCredentials,

    [Parameter(Mandatory = $false)]
    [string]$AuthenticationConfigFile,

    [Parameter(Mandatory = $false, HelpMessage = "Directory for output files (canonical: ./data/exports)")]
    [string]$OutputDirectory,

    [Parameter(Mandatory = $false)]
    [switch]$UseSingleEndpoint,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIfPreference,

    [Parameter(Mandatory = $false)]
    [string]$DomainId,

    [Parameter(Mandatory = $false)]
    [object]$ValidatedState = $null
)

# CANONICAL FIX: Set default OutputDirectory if not provided
if (-not $OutputDirectory) {
    $OutputDirectory = ".\data\exports"
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
    $configManager = $services.ConfigManager
    $configValidator = $services.ConfigValidator
    $workflowOpsService = $services.WorkflowOperationsService

    if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $authService -or $null -eq $configManager -or $null -eq $configValidator -or $null -eq $workflowOpsService) {
        throw "One or more services failed to initialize properly"
    }

    Write-Host "ApplyNSXConfig: Service framework initialized successfully" -ForegroundColor Green

}
catch {
    Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
    exit 1
}

# Use centralised credential management from CoreAuthenticationService

# Main execution
try {
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "  Apply NSX Configuration" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host ""

    Write-Host "NSX Manager: $NSXManager"
    if ($ConfigFile) { Write-Host "Config File: $(Split-Path $ConfigFile -Leaf)" }
    Write-Host "Operation: $(if (!$WhatIfPreference) { "Apply Configuration" } else { "WhatIf Mode" })"
    if ($UseSingleEndpoint) { Write-Host "Apply Method: Single Endpoint (/policy/api/v1/infra)" -ForegroundColor Yellow }
    Write-Host ""

    # Validate parameters
    if ($WhatIfPreference -and -not $ConfigFile) {
        throw "-WhatIf Mode requires -ConfigFile parameter"
    }

    if ($ConfigFile -and -not (Test-Path $ConfigFile)) {
        throw "Configuration file not found: $ConfigFile"
    }

    # Ensure output directory exists
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
        Write-Host "Created output directory: $OutputDirectory"
    }

    # Collect credentials using shared credential service (eliminates duplication)
    $sharedCredentialService = $services.SharedToolCredentialService
    $sharedCredentialService.DisplayCredentialCollectionStatus($NSXManager, "ApplyNSXConfig", $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials)
    # ApplyNSXConfig.ps1 doesn't have a Username parameter, so pass empty string for validation
    $usernameValidation = if ($PSBoundParameters['Username']) { $Username } else { "" }
    $sharedCredentialService.ValidateCredentialParameters($UseCurrentUserCredentials, $ForceNewCredentials, $usernameValidation, $AuthenticationConfigFile)

    try {
        # ApplyNSXConfig.ps1 doesn't have a Username parameter, so pass empty string for current user auth or stored credentials
        $usernameParam = if ($PSBoundParameters['Username']) { $Username } else { "" }
        $credential = $sharedCredentialService.GetStandardNSXCredentials($NSXManager, $usernameParam, $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials, $AuthenticationConfigFile, "ApplyNSXConfig")
        $logger.LogInfo("Credentials collected successfully using SharedToolCredentialService: $NSXManager", "ApplyConfig")
    }
    catch {
        # SharedToolCredentialService handles all error types and logging internally
        Write-Host "FAILED: Credential collection failed for $NSXManager" -ForegroundColor Red
        exit 1
    }

    # ===================================================================
    # MANDATORY NSX TOOLKIT PREREQUISITE CHECK
    # ===================================================================

    if ($ValidatedState) {
        Write-Host "Using validated state from previous tool" -ForegroundColor Green
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

            # Define required endpoints for Apply NSX Config operations
            $requiredEndpoints = @(
                "/policy/api/v1/infra",
                "/policy/api/v1/infra/domains",
                "/policy/api/v1/infra/domains/default/groups",
                "/policy/api/v1/infra/domains/default/security-policies",
                "/policy/api/v1/infra/services",
                "/policy/api/v1/infra/contexts"
            )

            # Run mandatory prerequisite check (with optional state chaining)
            $prerequisiteParams = [PSCustomObject]@{
                NSXManager                = $NSXManager
                Credential                = $credential
                RequiredEndpoints         = $requiredEndpoints
                ToolName                  = "ApplyNSXConfig"
                AllowLimitedFunctionality = $true
            }
            if ($ValidatedState) {
                $prerequisiteParams.ValidatedState = $ValidatedState
            }
            $prerequisiteResult = Assert-NSXToolkitPrerequisites @prerequisiteParams

            # Store prerequisite results for use during operations
            $script:prerequisiteData = $prerequisiteResult

            Write-Host "NSX toolkit prerequisites validated successfully" -ForegroundColor Green
            $logger.LogInfo("NSX toolkit prerequisites validated - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "ApplyConfig")
        }
        catch {
            $logger.LogError("NSX toolkit prerequisite check failed: $($_.Exception.Message)", "ApplyConfig")
            Write-Host ""
            Write-Host "[ERROR] APPLY NSX CONFIG CANNOT PROCEED" -ForegroundColor Red
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
    # NSX CONFIGURATION OPERATIONS
    # ===================================================================

    # Backup existing configuration if requested using NSXPolicyConfigExport.ps1 orchestration
    if ($BackupFirst) {
        try {
            Write-Host ""
            Write-Host "====================================================================="
            Write-Host "BACKUP EXISTING CONFIGURATION VIA NSXPolicyConfigExport.ps1" -ForegroundColor Cyan
            Write-Host "====================================================================="

            Write-Host "Executing NSXPolicyConfigExport.ps1 for backup operation..."

            # Build parameters for NSXPolicyConfigExport.ps1
            $exportParams = [PSCustomObject]@{
                'NSXManager'       = $NSXManager
                'ExportAllDomains' = $true
            }

            # Set appropriate output directory and naming based on operation type
            Write-Host "Mode: Pre-Apply Backup - saving backup before configuration application" -ForegroundColor Yellow
            # Use WorkflowOperationsService to get backup directory
            $backupDir = $workflowOpsService.GetDataPath('Backups')
            if (-not (Test-Path $backupDir)) {
                New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
            }
            $exportParams['OutputDirectory'] = $backupDir

            # Add domain filter if specified
            if ($DomainId -and $DomainId -ne "default") {
                $exportParams['DomainId'] = $DomainId
            }

            # Execute NSXPolicyConfigExport.ps1 via tool orchestration
            # CANONICAL FIX: Use the already validated scriptPath instead of PSCommandPath
            $exportResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @exportParams

            if ($exportResult -and $exportResult.success) {
                $exportedFile = $exportResult.saved_files.policy_config

                Write-Host "SUCCESS: Configuration exported successfully via NSXPolicyConfigExport.ps1" -ForegroundColor Green
                Write-Host "   File: $(Split-Path $exportedFile -Leaf)" -ForegroundColor Cyan
                Write-Host "   Size: $([math]::Round((Get-Item $exportedFile).Length / 1KB, 2)) KB" -ForegroundColor Cyan
                Write-Host "   Path: $exportedFile" -ForegroundColor Gray

            }
            else {
                throw "NSXPolicyConfigExport.ps1 failed or returned no results for backup operation"
            }
        }
        catch {
            $errorMsg = "Backup operation failed: $($_.Exception.Message)"
            Write-Host $errorMsg -ForegroundColor Red
            throw $errorMsg
        }
    }

    # Apply configuration if NOT Whatif mode
    if (!$WhatIfPreference) {
        Write-Host ""
        Write-Host "====================================================================="
        Write-Host "APPLYING CONFIGURATION" -ForegroundColor Cyan
        Write-Host "====================================================================="

        Write-Host "Configuration file: $(Split-Path $ConfigFile -Leaf)"
        Write-Host "Target NSX Manager: $NSXManager"

        if ($WhatIfPreference) {
            Write-Host "Mode: WhatIf Mode (no changes will be made)" -ForegroundColor Yellow
        }

        # configuration validation
        Write-Host ""
        Write-Host "Validating configuration file..."

        # Validate configuration against NSX-T API schema
        $validationResult = $configValidator.ValidateConfigurationFile($ConfigFile, $NSXManager, $credential)

        if (-not $validationResult.valid) {
            Write-Host "VALIDATION FAILED:" -ForegroundColor Red
            foreach ($validationError in $validationResult.errors) {
                Write-Host "  ERROR: $validationError" -ForegroundColor Red
            }
            foreach ($validationWarning in $validationResult.warnings) {
                Write-Host "  WARNING: $validationWarning" -ForegroundColor Yellow
            }
            throw "Configuration validation failed. Please fix the errors and try again."
        }

        # Display validation results
        Write-Host "SUCCESS: Configuration validation passed" -ForegroundColor Green
        if ($validationResult.warnings.Count -gt 0) {
            Write-Host "Warnings found:" -ForegroundColor Yellow
            foreach ($validationWarning in $validationResult.warnings) {
                Write-Host "  WARNING: $validationWarning" -ForegroundColor Yellow
            }
        }

        # Handle auto-wrapping if it occurred
        $actualConfigFile = $ConfigFile
        if ($validationResult.needs_wrapping) {
            Write-Host "INFO: Auto-wrapping was applied for NSX hierarchical API compliance" -ForegroundColor Cyan
            Write-Host "INFO: Corrected configuration available at: $(Split-Path $validationResult.corrected_file_path -Leaf)" -ForegroundColor Cyan
            $actualConfigFile = $validationResult.corrected_file_path
        }

        # Use filtered configuration (deprecated fields removed + system objects filtered out)
        $configToApply = if ($validationResult.filtered_config) {
            $validationResult.filtered_config
        }
        elseif ($validationResult.cleaned_config) {
            $validationResult.cleaned_config
        }
        else {
            $validationResult.parsed_json
        }

        # Extract infra configuration based on structure (handle metadata/configuration wrapper)
        $config = if ($configToApply.configuration -and $configToApply.configuration.infra) {
            $configToApply.configuration.infra
        }
        elseif ($configToApply.infra) {
            $configToApply.infra
        }
        else {
            throw "Unable to find infra configuration in filtered config structure"
        }

        # Count objects
        $objectCount = if ($config.children) { $config.children.Count } else { 0 }
        Write-Host "Configuration contains $objectCount valid top-level objects"

        # Confirmation
        if (-not $WhatIfPreference -and -not $NonInteractive) {
            Write-Host ""
            Write-Host "WARNING: This will modify the target NSX Manager!" -ForegroundColor Yellow
            Write-Host "Target: $NSXManager"
            Write-Host "Objects: $objectCount"
            $confirm = Read-Host "Do you want to proceed? (yes/no)"
            if ($confirm -ne "yes") {
                Write-Host "Operation cancelled by user"
                return
            }
        }

        # Create configuration object in correct format for NSXConfigManager
        $tempConfig = [PSCustomObject]@{
            "metadata"      = @{
                "source_file"     = $actualConfigFile
                "original_file"   = $ConfigFile
                "target_manager"  = $NSXManager
                "apply_timestamp" = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                "script_version"  = "1.0"
                "config_type"     = "apply_configuration"
                "api_endpoint"    = "/policy/api/v1/infra"
                "auto_wrapped"    = $validationResult.needs_wrapping
            }
            "configuration" = $config
        }

        # Save the JSON payload to data directory before sending (using validator service)
        # Save both the wrapped config and the actual payload that will be sent to NSX-T
        $actualPayload = $config
        $savedFiles = $configValidator.SavePayloadFiles($actualPayload, $tempConfig, $NSXManager)

        if ($savedFiles.payload_file) {
            Write-Host "Payload saved to: $($savedFiles.payload_file)" -ForegroundColor Cyan
            Write-Host "Complete config saved to: $($savedFiles.temp_config_file)" -ForegroundColor Cyan
        }
        else {
            Write-Host "Warning: Failed to save payload files: $($savedFiles.error)" -ForegroundColor Yellow
        }

        if ($WhatIfPreference) {
            Write-Host ""
            Write-Host "SUCCESS: WhatIf Mode completed - configuration is valid and ready to apply" -ForegroundColor Green
            Write-Host "   Objects to apply: $objectCount"
            Write-Host "   Target manager: $NSXManager"
            if ($savedFiles.payload_file) {
                Write-Host "   Payload saved to: $(Split-Path $savedFiles.payload_file -Leaf)" -ForegroundColor Cyan
            }
        }
        else {
            Write-Host ""
            Write-Host "Applying configuration to NSX Manager..."
            $result = $configManager.ApplyConfiguration($NSXManager, $credential, $tempConfig, "PATCH")

            if ($result -and $result.success) {
                Write-Host "SUCCESS: Configuration applied successfully!" -ForegroundColor Green
                $logger.LogInfo("Configuration applied successfully to $NSXManager", "ApplyConfig")
            }
            else {
                $errorMsg = if ($result.error) { $result.error } else { "Unknown error occurred" }
                throw "Configuration application failed: $errorMsg"
            }
        }
    }

    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "  OPERATION COMPLETED SUCCESSFULLY" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan

}
catch {
    $errorMsg = "Configuration operation failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Error: $errorMsg" -ForegroundColor Red
    $logger.LogError($errorMsg, "ApplyConfig")
    exit 1
}
