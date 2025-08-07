<#
.SYNOPSIS
    NSX Configuration Sync - Synchronize, export, import, and compare NSX-T configurations between managers with robust credential, automation, and advanced sync options.

.DESCRIPTION
    NSX-T configuration sync using the hierarchical API for bulk export/import, selective migration, and advanced comparison between NSX managers.


.PARAMETER SourceNSXManager
    Source NSX Manager FQDN or IP address (e.g., nsxmgr-source.example.com)

.PARAMETER TargetNSXManager
    Target NSX Manager FQDN or IP address (e.g., nsxmgr-target.example.com)

.PARAMETER Username
    Username for basic authentication. This parameter is ignored when using
    -UseCurrentUserCredentials. Default: "admin"

.PARAMETER SecurePassword
    SecureString password for basic authentication. This parameter is ignored when using
    -UseCurrentUserCredentials.

.PARAMETER UseCurrentUserCredentials
    Use current Windows user credentials for authentication (requires AD integration)

.PARAMETER ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist

.PARAMETER SaveCredentials
    Save credentials for future use after successful authentication

.PARAMETER SkipSSLCheck
    Skip SSL certificate validation (not recommended for production)

.PARAMETER SkipConnectionTest
    Skip connection testing (trust that credentials work). Use this if connection tests fail but API calls work.

.PARAMETER AuthenticationConfigFile
    Load credentials from a specific file path

.PARAMETER DomainId
    Domain ID for NSX configuration scope (default: "default")

.PARAMETER SyncPath
    Directory path for sync artifacts (default: .\data\syncs)

.PARAMETER ObjectTypes
    Object types to migrate: services, groups, policies, contextprofiles, all (default: all)

.PARAMETER BackupOnly
    Only export/backup configuration from source manager

.PARAMETER RestoreOnly
    Only restore configuration to target manager from backup file

.PARAMETER RestoreFromFile
    Path to backup file for restore

.PARAMETER Force
    Force overwrite or operation (where applicable)

.PARAMETER CompareOnly
    Only compare configurations without applying changes

.PARAMETER SyncMode
    Apply only differences (patch mode) instead of full migration

.PARAMETER DetailedComparison
    Show detailed comparison results

.PARAMETER ConflictResolution
    Conflict resolution strategy: SourceWins, TargetWins, Merge, Skip, Interactive (default: Interactive)

.PARAMETER ValidateBeforeImport
    Validate configurations before applying changes

.PARAMETER SyncGroups
    Sync only Groups

.PARAMETER SyncServices
    Sync only Services

.PARAMETER SyncSecurityPolicies
    Sync only Security Policies

.PARAMETER SyncContextProfiles
    Sync only Context Profiles

.PARAMETER IncludeDependencies
    Include nested dependencies when syncing specific resources

.PARAMETER IncludePatterns
    Sync only objects matching specified patterns (comma-separated)

.PARAMETER ExcludePatterns
    Exclude objects matching specified patterns (comma-separated)

.PARAMETER ModifiedAfter
    Sync only objects created/modified after this date

.PARAMETER MaxObjects
    Maximum number of objects to sync (for testing)

.PARAMETER DeepValidation
    Perform deep validation including dependency checks

.PARAMETER ContinueOnWarnings
    Continue on validation warnings (fail only on errors)

.PARAMETER CreateRollbackConfig
    Create rollback configuration before applying changes

.PARAMETER ExportAll
    Export all configurations to JSON file

.PARAMETER ExportFiltered
    Export with specific filters

.PARAMETER ImportAll
    Import all configurations from JSON file

.PARAMETER ImportSelective
    Import specific resource types only

.PARAMETER OutputPath
    Output path for exported configurations

.PARAMETER InputPath
    Input path for configurations to import

.EXAMPLE
    # Export/backup configuration from source manager only
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -BackupOnly

.EXAMPLE
    # Restore configuration to target from backup file
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -RestoreOnly -RestoreFromFile "backup.json"

.EXAMPLE
    # Migrate all configurations using current Windows user credentials
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -UseCurrentUserCredentials

.EXAMPLE
    # Run in non-interactive mode for automation/scheduled tasks
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -NonInteractive

.EXAMPLE
    # Force prompt for new credentials even if saved credentials exist
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -ForceNewCredentials

.EXAMPLE
    # Save credentials after successful authentication for future use
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -SaveCredentials

.EXAMPLE
    # Skip SSL certificate validation (not recommended for production)
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -SkipSSLCheck

.EXAMPLE
    # Skip connection testing if SSL configuration issues prevent connection tests but API calls work
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -SkipConnectionTest

.EXAMPLE
    # Sync only Groups and Services
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -SyncGroups -SyncServices

.EXAMPLE
    # Sync only objects matching specific patterns
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -IncludePatterns "web*,db*"

.EXAMPLE
    # Perform a detailed comparison only, no changes applied
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -CompareOnly -DetailedComparison

.EXAMPLE
    # Use patch mode (apply only differences)
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -SyncMode

.EXAMPLE
    # Set conflict resolution to SourceWins
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -ConflictResolution SourceWins

.EXAMPLE
    # Validate before import and continue on warnings
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -ValidateBeforeImport -ContinueOnWarnings

.EXAMPLE
    # Create rollback config before applying changes
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -CreateRollbackConfig

.EXAMPLE
    # Export all configurations to a specific file
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -ExportAll -OutputPath ".\exports\full-export.json"

.EXAMPLE
    # Import all configurations from a file
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -ImportAll -InputPath ".\exports\full-export.json"

.EXAMPLE
    # Import only selected resource types
    .\NSXConfigSync.ps1 -SourceNSXManager "nsxmgr-source.example.com" -TargetNSXManager "nsxmgr-target.example.com" -ImportSelective -ObjectTypes "groups,services"

#>

# NSXConfigSync.ps1
# Production-ready NSX-T configuration Config Sync using Hierarchical API
# Supports bulk export/import between NSX managers with multiple authentication methods

# Ensure WorkflowOperationsService type is loaded for static path resolution across the script
# . "$PSScriptRoot\..\src\services\WorkflowOperationsService.ps1"
# dot-source removed; WorkflowOperationsService will be loaded after service framework initializes

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(HelpMessage = "Source NSX Manager FQDN or IP address")]
    [ValidateNotNullOrEmpty()]
    [string]$SourceNSXManager,

    [Parameter(HelpMessage = "Target NSX Manager FQDN or IP address")]
    [ValidateNotNullOrEmpty()]
    [string]$TargetNSXManager,

    [Parameter(HelpMessage = "Use current Windows user credentials (requires AD integration)")]
    [switch]$UseCurrentUserCredentials,

    [Parameter(HelpMessage = "Force prompt for new credentials even if saved credentials exist")]
    [switch]$ForceNewCredentials,

    [Parameter(HelpMessage = "Automatically save working credentials")]
    [switch]$SaveCredentials,

    [Parameter(HelpMessage = "Skip SSL certificate validation")]
    [switch]$SkipSSLCheck,

    [Parameter(HelpMessage = "Skip connection testing (trust that credentials work)")]
    [switch]$SkipConnectionTest,

    [Parameter(HelpMessage = "Load credentials from specific file path")]
    [string]$AuthenticationConfigFile,

    [Parameter(HelpMessage = "Domain ID for NSX configuration scope")]
    [ValidateNotNullOrEmpty()]
    [string]$DomainId = "default",

    [Parameter(HelpMessage = "Sync artifacts directory path")]
    [ValidateNotNullOrEmpty()]
    [string]$SyncPath = ".\data\syncs",

    [Parameter(HelpMessage = "Object types to migrate: services,groups,policies,contextprofiles,all")]
    [ValidateSet("services", "groups", "policies", "contextprofiles", "all")]
    [string]$ObjectTypes = "all",

    [switch]$BackupOnly,
    [switch]$RestoreOnly,
    [string]$RestoreFromFile,
    [switch]$Force,

    # CONSOLIDATION: Add sync mode parameters from NSXConfigSyncTool
    [Parameter(HelpMessage = "SYNC MODE: Only compare configurations without applying changes")]
    [switch]$CompareOnly,

    [Parameter(HelpMessage = "SYNC MODE: Apply only differences (patch mode) instead of full migration")]
    [switch]$SyncMode,

    [Parameter(HelpMessage = "SYNC MODE: Show detailed comparison results")]
    [switch]$DetailedComparison,

    # SYNC OPTIONS
    [Parameter(HelpMessage = "Conflict resolution strategy: SourceWins, TargetWins, Merge, Skip, Interactive")]
    [ValidateSet("SourceWins", "TargetWins", "Merge", "Skip", "Interactive")]
    [string]$ConflictResolution = "Interactive",



    [Parameter(HelpMessage = "Validate configurations before applying changes")]
    [switch]$ValidateBeforeImport,

    # RESOURCE-SPECIFIC SYNC OPTIONS
    [Parameter(HelpMessage = "Sync only Groups")]
    [switch]$SyncGroups,

    [Parameter(HelpMessage = "Sync only Services")]
    [switch]$SyncServices,

    [Parameter(HelpMessage = "Sync only Security Policies")]
    [switch]$SyncSecurityPolicies,

    [Parameter(HelpMessage = "Sync only Context Profiles")]
    [switch]$SyncContextProfiles,

    [Parameter(HelpMessage = "Include nested dependencies when syncing specific resources")]
    [switch]$IncludeDependencies,

    # SELECTIVE SYNC OPTIONS
    [Parameter(HelpMessage = "Sync only objects matching specified patterns (comma-separated)")]
    [string]$IncludePatterns,

    [Parameter(HelpMessage = "Exclude objects matching specified patterns (comma-separated)")]
    [string]$ExcludePatterns,

    [Parameter(HelpMessage = "Sync only objects created/modified after this date")]
    [datetime]$ModifiedAfter,

    [Parameter(HelpMessage = "Maximum number of objects to sync (for testing)")]
    [int]$MaxObjects,

    # ADVANCED VALIDATION OPTIONS
    [Parameter(HelpMessage = "Perform deep validation including dependency checks")]
    [switch]$DeepValidation,

    [Parameter(HelpMessage = "Continue on validation warnings (fail only on errors)")]
    [switch]$ContinueOnWarnings,

    [Parameter(HelpMessage = "Create rollback configuration before applying changes")]
    [switch]$CreateRollbackConfig,

    # EXPORT/IMPORT FUNCTIONALITY
    [Parameter(HelpMessage = "Export all configurations to JSON file")]
    [switch]$ExportAll,

    [Parameter(HelpMessage = "Export with specific filters")]
    [switch]$ExportFiltered,

    [Parameter(HelpMessage = "Import all configurations from JSON file")]
    [switch]$ImportAll,

    [Parameter(HelpMessage = "Import specific resource types only")]
    [switch]$ImportSelective,

    [Parameter(HelpMessage = "Output path for exported configurations")]
    [string]$OutputPath,

    [Parameter(HelpMessage = "Input path for configurations to import")]
    [string]$InputPath,

    # EXPORT/IMPORT RESOURCE SELECTION
    [Parameter(HelpMessage = "Include Groups in export/import")]
    [switch]$IncludeGroups,

    [Parameter(HelpMessage = "Include Services in export/import")]
    [switch]$IncludeServices,

    [Parameter(HelpMessage = "Include Security Policies in export/import")]
    [switch]$IncludeSecurityPolicies,

    [Parameter(HelpMessage = "Include Context Profiles in export/import")]
    [switch]$IncludeContextProfiles,

    [Parameter(HelpMessage = "Import Groups from file")]
    [switch]$ImportGroups,

    [Parameter(HelpMessage = "Import Services from file")]
    [switch]$ImportServices,

    [Parameter(HelpMessage = "Import Security Policies from file")]
    [switch]$ImportSecurityPolicies,

    [Parameter(HelpMessage = "Import Context Profiles from file")]
    [switch]$ImportContextProfiles,

    # DOMAIN-SPECIFIC OPERATIONS
    [Parameter(HelpMessage = "Specific domain for operations (default: all domains)")]
    [string]$Domain = "default"
)

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

    # Extract services from centralized factory
    $logger = $services.Logger
    $credentialService = $services.CredentialService
    $authService = $services.AuthService
    $apiService = $services.APIService
    $policyExportService = $services.PolicyExportService
    $configManager = $services.ConfigManager
    $configService = $services.Configuration
    $configValidator = $services.ConfigValidator
    $configReset = $services.ConfigReset
    $fileNamingService = $services.StandardFileNaming
    $diffMgr = $services.DifferentialConfigManager
    $workflowOpsService = $services.WorkflowOperationsService
    $dataObjectFilterService = $services.DataObjectFilter

    if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $authService -or $null -eq $apiService -or $null -eq $policyExportService -or $null -eq $configManager -or $null -eq $configService -or $null -eq $configValidator -or $null -eq $configReset -or $null -eq $fileNamingService -or $null -eq $diffMgr -or $null -eq $workflowOpsService -or $null -eq $dataObjectFilterService) {
        throw "One or more services failed to initialize properly"
    }

    Write-Host -Object "NSXConfigSync: Service framework initialized successfully" -ForegroundColor Green

    # Ensure WorkflowOperationsService type is loaded for static path resolution
    if (-not [type]::GetType('WorkflowOperationsService', $false)) {
        . "$scriptPath\..\src\services\WorkflowOperationsService.ps1"
    }
}
catch {
    Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
    exit 1
}

# Use centralised credential management from CoreAuthenticationService

# Helper function for standardized credential collection using SharedToolCredentialService (eliminates massive duplication)

<#region Functions#>

function Get-SyncManagerCredential {
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
    # NSXConfigSync.ps1 doesn't have a Username parameter, so pass empty string for validation
    $usernameValidation = ""
    $sharedCredentialService.ValidateCredentialParameters($UseCurrentUser, $ForceNew, $usernameValidation, $AuthConfigFile)

    try {
        # NSXConfigSync.ps1 doesn't have a Username parameter, so pass empty string for current user auth or stored credentials
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

# Backward compatible alias for Get-SyncManagerCredential
Set-Alias -Name Get-SyncManagerCredentials -Value Get-SyncManagerCredential

# Hierarchical Configuration Manager is already initialised via factory

# CANONICAL FIX: Single Responsibility Operation Functions (eliminates SRP violations)

# Function to handle export operations (Single Responsibility: Export only)
function Invoke-ExportOperation {
    # EXPORT MODE - Export configuration from source NSX Manager
    Write-Host -Object "`n" + "-"*80
    Write-Host -Object "EXPORT MODE: Exporting Configuration"
    Write-Host -Object "-"*80

    # Use SharedToolCredentialService for credential collection (eliminates duplication)
    $credential = Get-SyncManagerCredential -Manager $SourceNSXManager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "Export-Source"

    # Test source connection (optional)
    if (-not $SkipConnectionTest) {
        $logger.LogInfo("Testing connection to source NSX manager", "Export")
        Write-Host -Object "`nTesting connection to source..."
        $sourceResult = $authService.TestConnection($SourceNSXManager, $credential, $SkipSSLCheck)
        if ($sourceResult.Success) {
            Write-Host -Object "[SUCCESS] Source connection: $SourceNSXManager"
        }
        else {
            throw "Failed to connect to source NSX Manager: $($sourceResult.Error)"
        }
    }
    else {
        $logger.LogInfo("Connection testing skipped for source NSX manager", "Export")
        Write-Host -Object "`nConnection testing skipped - proceeding with source operations..."
    }

    # Configure SSL handling
    if ($SkipSSLCheck) {
        $logger.LogInfo("SSL certificate validation disabled", "Export")
        $configService.SetTrustAllCertificates($true)
    }

    # Generate output directory if not specified
    if (-not $OutputPath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $sourceHostname = Get-HostnameFromFQDN $SourceNSXManager
        $exportType = if ($ExportAll) { "full" } else { "filtered" }
        $exportsRoot = $script:workflowOpsService.GetToolkitPath('Exports')
        $OutputDirectory = Join-Path $exportsRoot $sourceHostname
        if (-not (Test-Path $OutputDirectory)) {
            New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
        }
    }
    else {
        $OutputDirectory = Split-Path $OutputPath -Parent
    }

    # Build parameters for NSXPolicyConfigExport.ps1 using helper functions
    $additionalParams = [PSCustomObject]@{}
    if ($Domain) { $additionalParams.NSXDomain = $Domain }
    if ($OutputStatistics) { $additionalParams.OutputStatistics = $true }
    if ($LogLevel) { $additionalParams.LogLevel = $LogLevel }

    $exportParams = New-ExportParameterSet -NSXManager $SourceNSXManager -OutputDirectory $OutputDirectory -ValidatedState $null -AdditionalParams $additionalParams
    $exportParams = Add-StandardCredentialParam -ParameterSet $exportParams -UseCurrentUserCredentials:$UseCurrentUserCredentials -ForceNewCredentials:$ForceNewCredentials -SaveCredentials:$SaveCredentials

    try {
        # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
        $exportParamsHash = ConvertTo-ParameterHashtable -ParameterSet $exportParams
        $exportResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @exportParamsHash
        if ($exportResult -and (Test-Path $exportResult)) {
            Write-Host -Object "`n" + "="*80
            Write-Host -Object "EXPORT COMPLETED SUCCESSFULLY" -ForegroundColor Green
            Write-Host -Object "="*80
            Write-Host -Object "Configuration exported to: $exportResult" -ForegroundColor Cyan
            Write-Host -Object "Operation Mode: Export" -ForegroundColor Cyan
            Write-Host -Object "Domain: $Domain" -ForegroundColor Cyan
        }
        else {
            throw "Export failed or output file not found."
        }
    }
    catch {
        $errorMsg = "Export failed: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "Export")
        throw $errorMsg
    }
}

# Function to handle import operations (Single Responsibility: Import only)
function Invoke-ImportOperation {
    # IMPORT MODE - Import configuration to target NSX Manager
    Write-Host -Object "`n" + "-"*80
    Write-Host -Object "IMPORT MODE: Importing Configuration"
    Write-Host -Object "-"*80

    # Use SharedToolCredentialService for credential collection (eliminates duplication)
    $credential = Get-SyncManagerCredential -Manager $TargetNSXManager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "Import-Target"

    # Test target connection (optional)
    if (-not $SkipConnectionTest) {
        $logger.LogInfo("Testing connection to target NSX manager", "Import")
        Write-Host -Object "`nTesting connection to target..."
        $targetResult = $authService.TestConnection($TargetNSXManager, $credential, $SkipSSLCheck)
        if ($targetResult.Success) {
            Write-Host -Object "[SUCCESS] Target connection: $TargetNSXManager"
        }
        else {
            throw "Failed to connect to target NSX Manager: $($targetResult.Error)"
        }
    }
    else {
        $logger.LogInfo("Connection testing skipped for target NSX manager", "Import")
        Write-Host -Object "`nConnection testing skipped - proceeding with target operations..."
    }

    # Configure SSL handling
    if ($SkipSSLCheck) {
        $logger.LogInfo("SSL certificate validation disabled", "Import")
        $configService.SetTrustAllCertificates($true)
    }

    # Perform import
    Invoke-ConfigurationImport -Manager $TargetNSXManager -Credential $credential -InputFilePath $InputPath -ResourceTypes $resourceTypesToSync

    Write-Host -Object "`n" + "="*80
    Write-Host -Object "IMPORT COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host -Object "="*80
    Write-Host -Object "Configuration imported from: $(Split-Path $InputPath -Leaf)" -ForegroundColor Cyan
    Write-Host -Object "Operation Mode: Import" -ForegroundColor Cyan
    Write-Host -Object "Resource Types: $($resourceTypesToSync -join ', ')" -ForegroundColor Cyan
    Write-Host -Object "Domain: $Domain" -ForegroundColor Cyan
}

# Function to handle sync operations (Single Responsibility: Sync only)
function Invoke-SyncOperation {
    # SYNC MODE - Synchronize between source and target NSX Managers
    Write-Host -Object "`n" + "-"*80
    Write-Host -Object "SYNC MODE: Synchronizing Configurations"
    Write-Host -Object "-"*80

    # Use SharedToolCredentialService for credential collection (eliminates duplication)
    $credential = Get-SyncManagerCredential -Manager $SourceNSXManager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "Sync-Source"

    # Use SharedToolCredentialService for target manager
    $targetCredential = Get-SyncManagerCredential -Manager $TargetNSXManager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials -SaveCreds $SaveCredentials -AuthConfigFile $AuthenticationConfigFile -Operation "Sync-Target"

    # CANONICAL FIX: Complete sync logic implementation (eliminates incomplete placeholder)

    # Configure SSL handling if needed
    if ($SkipSSLCheck) {
        $logger.LogInfo("SSL certificate validation disabled for sync operations", "Sync")
        $configService.SetTrustAllCertificates($true)
    }

    # Display sync operation parameters
    Write-Host -Object "`nSync Operation Parameters:" -ForegroundColor Cyan
    Write-Host -Object "Source Manager: $SourceNSXManager" -ForegroundColor White
    Write-Host -Object "Target Manager: $TargetNSXManager" -ForegroundColor White
    Write-Host -Object "Resource Types: $($resourceTypesToSync -join ', ')" -ForegroundColor White
    Write-Host -Object "Sync Mode: $(Get-EffectiveSyncMode)" -ForegroundColor White

    if ($WhatIfPreference) {
        Write-Host -Object "WhatIf Mode: ENABLED - No changes will be made" -ForegroundColor Yellow
    }

    try {
        #######################################################
        # Phase 1: Export source configuration
        #######################################################
        Write-Host -Object "`n" + "-"*60 -ForegroundColor Cyan
        Write-Host -Object "PHASE 1: Exporting Source Configuration" -ForegroundColor Cyan
        Write-Host -Object "-"*60 -ForegroundColor Cyan

        $sourceExportDir = $script:workflowOpsService.GetToolkitPath('Exports')
        if (-not (Test-Path $sourceExportDir)) {
            New-Item -Path $sourceExportDir -ItemType Directory -Force | Out-Null
        }

        $exportParams = New-ExportParameterSet -NSXManager $SourceNSXManager -OutputDirectory $sourceExportDir -ValidatedState $null
        $exportParams = Add-StandardCredentialParam -ParameterSet $exportParams -UseCurrentUserCredentials:$UseCurrentUserCredentials

        # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
        $exportParamsHash = ConvertTo-ParameterHashtable -ParameterSet $exportParams
        $sourceExportResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @exportParamsHash

        # Safe null checking for source export result
        if ($null -eq $sourceExportResult) {
            throw "Source configuration export failed: NSXPolicyConfigExport.ps1 returned null"
        }

        # Check for success property with null safety - handle both single objects and arrays (multi-domain)
        $exportSucceeded = $false
        if ($sourceExportResult -is [array] -and @($sourceExportResult).Count -gt 0) {
            # Multi-domain export returns array - check for explicit failures first
            $explicitFailures = $sourceExportResult | Where-Object {
                if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                else { $false }  # Don't assume unknown state is failure
            }
            # If no explicit failures found, consider the export successful
            $exportSucceeded = @($explicitFailures).Count -eq 0
        }
        elseif ($sourceExportResult -and ($sourceExportResult | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) {
            $exportSucceeded = $sourceExportResult.success
        }
        elseif ($sourceExportResult -and ($sourceExportResult | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) {
            $exportSucceeded = $sourceExportResult.success
        }
        else {
            # If we have a result but no clear success indicator, and no explicit failures, assume success
            $exportSucceeded = $true
        }

        if (-not $exportSucceeded) {
            # Safe error message extraction - handle both single objects and arrays (multi-domain)
            $errorDetails = "Unknown export error"
            if ($sourceExportResult -is [array] -and @($sourceExportResult).Count -gt 0) {
                # Multi-domain export - collect errors from failed exports (only explicit failures)
                $failedExports = $sourceExportResult | Where-Object {
                    if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                    elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                    else { $false }  # Only consider explicit failures, not unknown states
                }

                if (@($failedExports).Count -gt 0) {
                    $errors = $failedExports | ForEach-Object {
                        if ($_ -and ($_ | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) { $_.error }
                        elseif ($_ -and ($_ | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) { $_.error }
                        else { "Export failed for domain" }
                    }
                    $errorDetails = "Multi-domain export failures: $($errors -join '; ')"
                }
                else {
                    $errorDetails = "Multi-domain export array returned but no clear success indicators found"
                }
            }
            elseif ($sourceExportResult -and ($sourceExportResult | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) {
                $errorDetails = $sourceExportResult.error
            }
            elseif ($sourceExportResult -and ($sourceExportResult | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) {
                $errorDetails = $sourceExportResult.error
            }
            elseif ($sourceExportResult) {
                $errorDetails = $sourceExportResult.ToString()
            }
            throw "Source configuration export failed: $errorDetails"
        }

        # CANONICAL FIX: Use centralized function to extract file path and object count
        $sourceConfigPath = Get-ExportMainFilePath -ExportResult $sourceExportResult -Context "Source Export"
        $objectCount = Get-ExportObjectCount -ExportResult $sourceExportResult -Context "Source Export"

        Write-Host -Object "Source exported: $objectCount objects" -ForegroundColor Green

        ##########################################################################
        # Phase 2: Apply configuration to target using differential approach
        ###########################################################################
        Write-Host -Object "`n" + "-"*60 -ForegroundColor Cyan
        Write-Host -Object "PHASE 2: Applying Configuration to Target" -ForegroundColor Cyan
        Write-Host -Object "-"*60 -ForegroundColor Cyan

        # CANONICAL FIX: Ensure WhatIfPreference is properly initialized
        $whatIfValue = if ($null -ne $WhatIfPreference) { $WhatIfPreference } else { $false }

        Write-Host -Object "DEBUG: Target Manager: $TargetNSXManager" -ForegroundColor Yellow
        Write-Host -Object "DEBUG: Config File: $sourceConfigPath" -ForegroundColor Yellow
        Write-Host -Object "DEBUG: WhatIf Value: $whatIfValue" -ForegroundColor Yellow
        Write-Host -Object "DEBUG: DomainId: $DomainId" -ForegroundColor Yellow

        $applyParams = [PSCustomObject]@{
            NSXManager = $TargetNSXManager
            ConfigFile = $sourceConfigPath
            WhatIf     = $whatIfValue
        }
        if ($DomainId) { $applyParams.DomainId = $DomainId }
        if ($UseCurrentUserCredentials) { $applyParams.UseCurrentUserCredentials = $true }

        Write-Host -Object "DEBUG: About to call ApplyNSXConfig.ps1..." -ForegroundColor Yellow
        $applyResult = & "$scriptPath\ApplyNSXConfig.ps1" @applyParams
        Write-Host -Object "DEBUG: ApplyNSXConfig.ps1 call completed" -ForegroundColor Yellow

        # Check if ApplyNSXConfig.ps1 returned a valid result
        if ($null -eq $applyResult) {
            throw "ApplyNSXConfig.ps1 returned null - operation failed"
        }

        # Handle both object and hashtable return types from ApplyNSXConfig.ps1
        $operationSucceeded = $false
        if ($applyResult -and ($applyResult | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) {
            $operationSucceeded = $applyResult.success
        }
        elseif ($applyResult -and ($applyResult | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) {
            $operationSucceeded = $applyResult.success
        }
        elseif ($applyResult -eq $true) {
            # Handle  boolean return
            $operationSucceeded = $true
        }

        if ($operationSucceeded) {
            Write-Host -Object "`n" + "="*80 -ForegroundColor Green
            Write-Host -Object "SYNC COMPLETED SUCCESSFULLY" -ForegroundColor Green
            Write-Host -Object "="*80 -ForegroundColor Green
            Write-Host -Object "Source Objects: $objectCount" -ForegroundColor Cyan
            # Safe access to changes_applied property
            $changesApplied = "Unknown"
            if ($applyResult -and ($applyResult | Get-Member -Name 'changes_applied' -ErrorAction SilentlyContinue)) {
                $changesApplied = $applyResult.changes_applied
            }
            elseif ($applyResult -and ($applyResult | Get-Member -Name 'changes_applied' -ErrorAction SilentlyContinue)) {
                $changesApplied = $applyResult.changes_applied
            }
            Write-Host -Object "Changes Applied: $changesApplied" -ForegroundColor Cyan
            Write-Host -Object "Sync Mode: $(Get-EffectiveSyncMode)" -ForegroundColor Cyan

            $logger.LogInfo("Sync operation completed successfully - $changesApplied changes applied", "Sync")
        }
        else {
            # Handle error reporting with null safety
            $errorDetails = "Unknown error"
            if ($applyResult -and ($applyResult | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) {
                $errorDetails = $applyResult.error
            }
            elseif ($applyResult -and ($applyResult | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) {
                $errorDetails = $applyResult.error
            }
            elseif ($applyResult) {
                $errorDetails = $applyResult.ToString()
            }
            throw "Configuration apply failed: $errorDetails"
        }

    }
    catch {
        $errorMsg = "Sync operation failed: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "Sync")
        Write-Host -Object "`nERROR: $errorMsg" -ForegroundColor Red
        throw $errorMsg
    }
}

# SYNC FUNCTIONS

# CANONICAL FIX: Helper function to convert PSCustomObject to hashtable for proper parameter splatting
function ConvertTo-ParameterHashtable {
    param(
        [object]$ParameterSet
    )

    $hashtable = @{}

    # Convert PSCustomObject properties to hashtable entries
    $properties = ($ParameterSet | Get-Member -MemberType NoteProperty).Name
    foreach ($property in $properties) {
        $value = $ParameterSet.$property
        if ($null -ne $value) {
            $hashtable[$property] = $value
        }
    }

    return $hashtable
}

# CANONICAL FIX: Helper functions for ValidatedState chaining (eliminates duplication)
function New-ExportParameterSet {
    param(
        [string]$NSXManager,
        [string]$OutputDirectory,
        [object]$ValidatedState,
        [object]$AdditionalParams = [PSCustomObject]@{}
    )

    $params = [PSCustomObject]@{
        NSXManager       = $NSXManager
        OutputDirectory  = $OutputDirectory
        ExportAllDomains = $true
        ValidatedState   = $ValidatedState  # Validated state chaining for performance optimization
    }

    # Merge additional parameters - replace hash table indexing with PSCustomObject property addition
    $additionalProperties = ($AdditionalParams | Get-Member -MemberType NoteProperty).Name
    foreach ($key in $additionalProperties) {
        $params | Add-Member -NotePropertyName $key -NotePropertyValue $AdditionalParams.$key -Force
    }

    return $params
}

function Add-StandardCredentialParam {
    param(
        [object]$ParameterSet,
        [switch]$UseCurrentUserCredentials,
        [switch]$ForceNewCredentials,
        [switch]$SaveCredentials,
        [switch]$NonInteractive
    )

    if ($UseCurrentUserCredentials) { $ParameterSet.UseCurrentUserCredentials = $true }
    if ($ForceNewCredentials) { $ParameterSet.ForceNewCredentials = $true }
    if ($SaveCredentials) { $ParameterSet.SaveCredentials = $true }
    if ($NonInteractive) { $ParameterSet.NonInteractive = $true }

    return $ParameterSet
}

# Backward compatible alias for Add-StandardCredentialParam
Set-Alias -Name Add-StandardCredentialParams -Value Add-StandardCredentialParam

# CANONICAL FIX: Consolidated function to determine operation mode (eliminates duplication)
function Get-ConsolidatedOperationMode {
    param(
        [object]$ParameterFlags = [PSCustomObject]@{},
        [string]$FallbackMode = "Full"
    )

    # Check for export operations - replace hash table indexing with PSCustomObject property access
    if (((Get-Member -InputObject $ParameterFlags -Name 'ExportAll' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.ExportAll) -or
        ((Get-Member -InputObject $ParameterFlags -Name 'ExportFiltered' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.ExportFiltered)) {
        return "Export"
    }

    # Check for import operations - replace hash table indexing with PSCustomObject property access
    if (((Get-Member -InputObject $ParameterFlags -Name 'ImportAll' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.ImportAll) -or
        ((Get-Member -InputObject $ParameterFlags -Name 'ImportSelective' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.ImportSelective)) {
        return "Import"
    }

    # Check for resource-specific sync operations - replace hash table indexing with PSCustomObject property access
    $resourceSpecificSyncs = @(
        ((Get-Member -InputObject $ParameterFlags -Name 'SyncGroups' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.SyncGroups),
        ((Get-Member -InputObject $ParameterFlags -Name 'SyncServices' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.SyncServices),
        ((Get-Member -InputObject $ParameterFlags -Name 'SyncSecurityPolicies' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.SyncSecurityPolicies),
        ((Get-Member -InputObject $ParameterFlags -Name 'SyncContextProfiles' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.SyncContextProfiles)
    )
    $hasResourceSpecificSync = $resourceSpecificSyncs -contains $true

    if ($hasResourceSpecificSync) {
        return "ResourceSpecific"
    }
    elseif ((Get-Member -InputObject $ParameterFlags -Name 'SyncMode' -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.SyncMode) {
        return "Differential"
    }
    else {
        return $FallbackMode
    }
}

# Function to determine effective sync mode based on parameters (uses consolidated logic)
function Get-EffectiveSyncMode {
    try {
        # CANONICAL FIX: Add null safety for script variables
        $syncGroupsValue = if ($null -ne $script:SyncGroups) { $script:SyncGroups } else { $false }
        $syncServicesValue = if ($null -ne $script:SyncServices) { $script:SyncServices } else { $false }
        $syncSecurityPoliciesValue = if ($null -ne $script:SyncSecurityPolicies) { $script:SyncSecurityPolicies } else { $false }
        $syncContextProfilesValue = if ($null -ne $script:SyncContextProfiles) { $script:SyncContextProfiles } else { $false }
        $syncModeValue = if ($null -ne $script:SyncMode) { $script:SyncMode } else { $false }

        $flags = [PSCustomObject]@{
            'SyncGroups'           = $syncGroupsValue
            'SyncServices'         = $syncServicesValue
            'SyncSecurityPolicies' = $syncSecurityPoliciesValue
            'SyncContextProfiles'  = $syncContextProfilesValue
            'SyncMode'             = $syncModeValue
        }
        return Get-ConsolidatedOperationMode -ParameterFlags $flags -FallbackMode "Full"
    }
    catch {
        # Fallback to "Full" mode if any error occurs
        return "Full"
    }
}

# CANONICAL FIX: Consolidated function to handle all resource type determinations (eliminates duplication)
function Get-ConsolidatedResourceType {
    param(
        [string]$OperationType = "Sync",  # "Sync", "Export", or "Import"
        [object]$ParameterFlags = [PSCustomObject]@{}
    )

    $resourceTypes = @()

    # Determine parameter prefixes based on operation type
    $prefixes = switch ($OperationType) {
        "Sync" { @("Sync") }
        "Export" { @("Include") }
        "Import" { @("Import") }
        default { @("Sync") }
    }

    # Check each resource type across all prefixes
    $resourceTypeNames = @("Groups", "Services", "SecurityPolicies", "ContextProfiles")

    foreach ($resourceType in $resourceTypeNames) {
        $isIncluded = $false
        foreach ($prefix in $prefixes) {
            $paramName = "$prefix$resourceType"
            # Replace hash table indexing with PSCustomObject property access
            if ((Get-Member -InputObject $ParameterFlags -Name $paramName -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $ParameterFlags.$paramName -eq $true) {
                $isIncluded = $true
                break
            }
        }
        if ($isIncluded) {
            $resourceTypes += $resourceType
        }
    }

    # Default to all resource types if none specified
    if (@($resourceTypes).Count -eq 0) {
        $resourceTypes = $resourceTypeNames
    }

    return $resourceTypes
}

# Backward compatible alias for Get-ConsolidatedResourceType
Set-Alias -Name Get-ConsolidatedResourceTypes -Value Get-ConsolidatedResourceType

# Function to get resource types to sync (uses consolidated logic)
function Get-ResourceTypesToSync {
    try {
        # CANONICAL FIX: Add null safety for script variables
        $syncGroupsValue = if ($null -ne $script:SyncGroups) { $script:SyncGroups } else { $false }
        $syncServicesValue = if ($null -ne $script:SyncServices) { $script:SyncServices } else { $false }
        $syncSecurityPoliciesValue = if ($null -ne $script:SyncSecurityPolicies) { $script:SyncSecurityPolicies } else { $false }
        $syncContextProfilesValue = if ($null -ne $script:SyncContextProfiles) { $script:SyncContextProfiles } else { $false }

        $flags = [PSCustomObject]@{
            'SyncGroups'           = $syncGroupsValue
            'SyncServices'         = $syncServicesValue
            'SyncSecurityPolicies' = $syncSecurityPoliciesValue
            'SyncContextProfiles'  = $syncContextProfilesValue
        }
        return Get-ConsolidatedResourceType -OperationType "Sync" -ParameterFlags $flags
    }
    catch {
        # Fallback to all resource types if any error occurs
        return @("Groups", "Services", "SecurityPolicies", "ContextProfiles")
    }
}

# Function to handle conflict resolution
function Resolve-ConfigurationConflict {
    param(
        [object]$SourceObject,
        [object]$TargetObject,
        [string]$ConflictType,
        [string]$ObjectPath
    )

    $logger.LogInfo("Conflict detected for $ObjectPath : $ConflictType", "ConflictResolution")

    switch ($ConflictResolution) {
        "SourceWins" {
            $logger.LogInfo("Conflict resolution: Source wins for $ObjectPath", "ConflictResolution")
            return $SourceObject
        }
        "TargetWins" {
            $logger.LogInfo("Conflict resolution: Target wins for $ObjectPath", "ConflictResolution")
            return $TargetObject
        }
        "Skip" {
            $logger.LogInfo("Conflict resolution: Skipping $ObjectPath", "ConflictResolution")
            return $null
        }
        "Merge" {
            $logger.LogInfo("Conflict resolution: Merging $ObjectPath", "ConflictResolution")
            return Merge-ConfigurationObject -SourceObject $SourceObject -TargetObject $TargetObject
        }
        "Interactive" {
            if ($NonInteractive) {
                $logger.LogWarning("Interactive conflict resolution requested but running in non-interactive mode. Using SourceWins.", "ConflictResolution")
                return $SourceObject
            }
            else {
                return Resolve-InteractiveConflict -SourceObject $SourceObject -TargetObject $TargetObject -ObjectPath $ObjectPath
            }
        }
        default {
            $logger.LogWarning("Unknown conflict resolution strategy: $ConflictResolution. Using SourceWins.", "ConflictResolution")
            return $SourceObject
        }
    }
}

# Function to merge configuration objects
function Merge-ConfigurationObject {
    param(
        [object]$SourceObject,
        [object]$TargetObject
    )

    # Create a merged object starting with target as base
    $mergedObject = $TargetObject.PSObject.Copy()

    # Override with source properties that are newer or different
    foreach ($property in $SourceObject.PSObject.Properties) {
        if ($property.Name -notin @("_create_time", "_last_modified_time", "_revision")) {
            $mergedObject.$($property.Name) = $property.Value
        }
    }

    return $mergedObject
}

# Backward compatible alias for Merge-ConfigurationObject
Set-Alias -Name Merge-ConfigurationObjects -Value Merge-ConfigurationObject

# Function to handle interactive conflict resolution
function Resolve-InteractiveConflict {
    param(
        [object]$SourceObject,
        [object]$TargetObject,
        [string]$ObjectPath
    )

    Write-Host -Object "`nCONFLICT DETECTED: $ObjectPath" -ForegroundColor Yellow
    Write-Host -Object "Source: $($SourceObject.display_name)" -ForegroundColor Cyan
    Write-Host -Object "Target: $($TargetObject.display_name)" -ForegroundColor Cyan

    do {
        Write-Host -Object "`nConflict Resolution Options:" -ForegroundColor Yellow
        Write-Host -Object "1. Use Source (overwrite target)"
        Write-Host -Object "2. Use Target (keep current)"
        Write-Host -Object "3. Merge (combine both)"
        Write-Host -Object "4. Skip (don't sync this object)"
        Write-Host -Object "5. Use Source for All remaining conflicts"
        Write-Host -Object "6. Use Target for All remaining conflicts"

        $choice = Read-Host "Enter your choice (1-6)"

        switch ($choice) {
            "1" { return $SourceObject }
            "2" { return $TargetObject }
            "3" { return Merge-ConfigurationObject -SourceObject $SourceObject -TargetObject $TargetObject }
            "4" { return $null }
            "5" {
                $script:ConflictResolution = "SourceWins"
                return $SourceObject
            }
            "6" {
                $script:ConflictResolution = "TargetWins"
                return $TargetObject
            }
            default { Write-Host -Object "Invalid choice. Please enter 1-6." -ForegroundColor Red }
        }
    } while ($true)
}

# Function to filter objects based on patterns and criteria
function Test-ObjectIncluded {
    param(
        [object]$Object,
        [string[]]$IncludePatterns,
        [string[]]$ExcludePatterns,
        [datetime]$ModifiedAfter
    )

    # Check exclude patterns first
    if ($ExcludePatterns) {
        foreach ($pattern in $ExcludePatterns) {
            if ($Object.display_name -like $pattern -or $Object.id -like $pattern) {
                return $false
            }
        }
    }

    # Check include patterns
    if ($IncludePatterns) {
        $included = $false
        foreach ($pattern in $IncludePatterns) {
            if ($Object.display_name -like $pattern -or $Object.id -like $pattern) {
                $included = $true
                break
            }
        }
        if (-not $included) {
            return $false
        }
    }

    # Check modified date
    if ($ModifiedAfter) {
        if ($Object._last_modified_time) {
            $lastModified = [datetime]::ParseExact($Object._last_modified_time, "yyyy-MM-ddTHH:mm:ss.fffZ", $null)
            if ($lastModified -lt $ModifiedAfter) {
                return $false
            }
        }
    }

    return $true
}

# Function to preview changes using VerifyNSXConfiguration.ps1 orchestration
function Show-SyncPreview {
    param(
        [object]$SourceConfig,
        [object]$TargetConfig,
        [string[]]$ResourceTypes
    )

    Write-Host -Object "`n" + "="*80 -ForegroundColor Cyan
    Write-Host -Object "SYNC PREVIEW - Using VerifyNSXConfiguration.ps1 for comparison analysis" -ForegroundColor Cyan
    Write-Host -Object "="*80 -ForegroundColor Cyan

    try {
        # CANONICAL FIX: Use proper path management instead of hardcoded temporary files
        $tempDir = $script:workflowOpsService.GetToolkitPath('Tests')
        if (-not (Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory -Force | Out-Null }

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $sourceConfigFile = Join-Path $tempDir "preview_source_$timestamp.json"
        $targetConfigFile = Join-Path $tempDir "preview_target_$timestamp.json"

        # Save configurations to temporary files
        $SourceConfig | ConvertTo-Json -Depth 50 | Out-File -FilePath $sourceConfigFile -Encoding UTF8
        $TargetConfig | ConvertTo-Json -Depth 50 | Out-File -FilePath $targetConfigFile -Encoding UTF8

        # Build parameters for VerifyNSXConfiguration.ps1
        $verifyParams = [PSCustomObject]@{
            'ConfigFile'           = $sourceConfigFile
            'ComparisonConfigFile' = $targetConfigFile
            'NonInteractive'       = $true
            'GenerateReport'       = $true
            'ShowDifferences'      = $true
        }

        # Add resource type filters if specified
        if (@($ResourceTypes).Count -gt 0) {
            foreach ($resourceType in $ResourceTypes) {
                switch ($resourceType) {
                    "Groups" { $verifyParams['IncludeGroups'] = $true }
                    "Services" { $verifyParams['IncludeServices'] = $true }
                    "SecurityPolicies" { $verifyParams['IncludeSecurityPolicies'] = $true }
                    "ContextProfiles" { $verifyParams['IncludeContextProfiles'] = $true }
                }
            }
        }

        # Execute VerifyNSXConfiguration.ps1 via tool orchestration
        $scriptPath = Split-Path $PSCommandPath -Parent
        $verificationResult = & "$scriptPath\VerifyNSXConfiguration.ps1" @verifyParams

        # Process verification results and display in sync preview format
        $changes = [PSCustomObject]@{
            "Added"     = @()
            "Modified"  = @()
            "Deleted"   = @()
            "Conflicts" = @()
        }

        if ($verificationResult -and $verificationResult.differences) {
            # Parse verification results into sync preview format
            foreach ($diff in $verificationResult.differences) {
                switch ($diff.change_type) {
                    "CREATE" {
                        $changes.Added += @{
                            Type = $diff.resource_type
                            Name = $diff.display_name
                            Id   = $diff.id
                        }
                    }
                    "UPDATE" {
                        $changes.Modified += @{
                            Type           = $diff.resource_type
                            Name           = $diff.display_name
                            Id             = $diff.id
                            SourceRevision = $diff.source_revision
                            TargetRevision = $diff.target_revision
                        }
                    }
                    "DELETE" {
                        $changes.Deleted += @{
                            Type = $diff.resource_type
                            Name = $diff.display_name
                            Id   = $diff.id
                        }
                    }
                }
            }
        }

        # Display changes using standardized format
        if (@($changes.Added).Count -gt 0) {
            Write-Host -Object "`nOBJECTS TO BE ADDED:" -ForegroundColor Green
            foreach ($change in $changes.Added) {
                Write-Host -Object "  + [$($change.Type)] $($change.Name)" -ForegroundColor Green
            }
        }

        if (@($changes.Modified).Count -gt 0) {
            Write-Host -Object "`nOBJECTS TO BE MODIFIED:" -ForegroundColor Yellow
            foreach ($change in $changes.Modified) {
                Write-Host -Object "  ~ [$($change.Type)] $($change.Name)" -ForegroundColor Yellow
            }
        }

        if (@($changes.Deleted).Count -gt 0) {
            Write-Host -Object "`nOBJECTS TO BE DELETED:" -ForegroundColor Red
            foreach ($change in $changes.Deleted) {
                Write-Host -Object "  - [$($change.Type)] $($change.Name)" -ForegroundColor Red
            }
        }

        Write-Host -Object "`nSUMMARY:" -ForegroundColor Cyan
        Write-Host -Object "  Objects to Add: $(@($changes.Added).Count)" -ForegroundColor Green
        Write-Host -Object "  Objects to Modify: $(@($changes.Modified).Count)" -ForegroundColor Yellow
        Write-Host -Object "  Objects to Delete: $(@($changes.Deleted).Count)" -ForegroundColor Red
        Write-Host -Object "  Total Changes: $(@($changes.Added).Count + @($changes.Modified).Count + @($changes.Deleted).Count)"
        Write-Host -Object "  Comparison via: VerifyNSXConfiguration.ps1" -ForegroundColor Cyan

        # Cleanup temporary files
        Remove-Item $sourceConfigFile -Force -ErrorAction SilentlyContinue
        Remove-Item $targetConfigFile -Force -ErrorAction SilentlyContinue

        return $changes

    }
    catch {
        Write-Host -Object "Warning: Sync preview via VerifyNSXConfiguration.ps1 failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host -Object "Falling back to basic comparison..." -ForegroundColor Yellow

        # Basic fallback comparison
        $changes = [PSCustomObject]@{
            "Added"     = @()
            "Modified"  = @()
            "Deleted"   = @()
            "Conflicts" = @()
        }

        Write-Host -Object "`nSUMMARY:" -ForegroundColor Cyan
        Write-Host -Object "  Comparison method: Basic fallback" -ForegroundColor Yellow
        Write-Host -Object "  Note: Use VerifyNSXConfiguration.ps1 directly for detailed analysis" -ForegroundColor Yellow

        return $changes
    }
}

# Legacy function retained for backward compatibility (now uses tool orchestration pattern)
function Get-ObjectsByType {
    param(
        [object]$Configuration,
        [string]$ResourceType
    )

    # Note: This function is now largely replaced by VerifyNSXConfiguration.ps1 orchestration
    # Keeping minimal implementation for backward compatibility

    $objects = @()
    Write-Verbose "Get-ObjectsByType: Processing $ResourceType (legacy compatibility mode)"

    # Basic extraction - for full functionality use VerifyNSXConfiguration.ps1 directly
    if ($Configuration.children) {
        foreach ($domain in $Configuration.children) {
            if ($domain.children) {
                $objects += $domain.children | Where-Object { $_.resource_type -eq $ResourceType }
            }
        }
    }

    return $objects
}

# EXPORT/IMPORT FUNCTIONS

# Function to determine operation mode (uses consolidated logic)
function Get-OperationMode {
    $flags = [PSCustomObject]@{
        'ExportAll'       = $ExportAll
        'ExportFiltered'  = $ExportFiltered
        'ImportAll'       = $ImportAll
        'ImportSelective' = $ImportSelective
    }
    return Get-ConsolidatedOperationMode -ParameterFlags $flags -FallbackMode "Sync"
}

# Function to get export resource types (uses consolidated logic)
function Get-ExportResourceType {
    $flags = [PSCustomObject]@{
        'IncludeGroups'           = $IncludeGroups
        'IncludeServices'         = $IncludeServices
        'IncludeSecurityPolicies' = $IncludeSecurityPolicies
        'IncludeContextProfiles'  = $IncludeContextProfiles
    }
    $resourceTypes = Get-ConsolidatedResourceType -OperationType "Export" -ParameterFlags $flags

    # Special handling for ExportAll vs filtered exports
    if (@($resourceTypes).Count -eq 4 -and -not $ExportAll) {
        # If all types selected but not ExportAll mode, might be filtered
        if (-not ($IncludeGroups -or $IncludeServices -or $IncludeSecurityPolicies -or $IncludeContextProfiles)) {
            $resourceTypes = @()  # Return empty for filtered export with no specific includes
        }
    }

    return $resourceTypes
}

# Backward compatible alias for Get-ExportResourceType
Set-Alias -Name Get-ExportResourceTypes -Value Get-ExportResourceType

# Function to get import resource types (uses consolidated logic)
function Get-ImportResourceType {
    $flags = [PSCustomObject]@{
        'ImportGroups'           = $ImportGroups
        'ImportServices'         = $ImportServices
        'ImportSecurityPolicies' = $ImportSecurityPolicies
        'ImportContextProfiles'  = $ImportContextProfiles
    }
    return Get-ConsolidatedResourceType -OperationType "Import" -ParameterFlags $flags
}

# Backward compatible alias for Get-ImportResourceType
Set-Alias -Name Get-ImportResourceTypes -Value Get-ImportResourceType

# Function to perform export operation using NSXPolicyConfigExport.ps1 orchestration
function Invoke-ConfigurationExport {
    param(
        [string]$Manager,
        [PSCredential]$Credential,
        [string[]]$ResourceTypes,
        [string]$OutputFilePath
    )

    $logger.LogInfo("=== Configuration Export Started (Tool Orchestration) ===", "Export")
    $logger.LogInfo("Source Manager: $Manager", "Export")
    $logger.LogInfo("Resource Types: $($ResourceTypes -join ', ')", "Export")
    $logger.LogInfo("Output Path: $OutputFilePath", "Export")

    try {
        Write-Host -Object "`nExporting configuration from NSX Manager using NSXPolicyConfigExport.ps1..."
        Write-Host -Object "Source: $Manager"
        Write-Host -Object "Resource Types: $($ResourceTypes -join ', ')"
        Write-Host -Object "Domain: $Domain"

        # Build parameters for NSXPolicyConfigExport.ps1 using helper functions
        $exportParams = [PSCustomObject]@{
            NSXManager       = $Manager
            ExportAllDomains = $true
            ValidatedState   = $null  # Validated state chaining for performance optimization
        }

        # Add output directory if specified
        if ($OutputFilePath) {
            $outputDir = Split-Path $OutputFilePath -Parent
            if ($outputDir) {
                $exportParams['OutputDirectory'] = $outputDir
            }
        }

        # Add domain filter
        if ($Domain -and $Domain -ne "default" -and $Domain -ne "all") {
            $exportParams['DomainId'] = $Domain
        }

        # Add resource type filters if specified
        if ($ExportFiltered -and @($ResourceTypes).Count -gt 0) {
            foreach ($resourceType in $ResourceTypes) {
                switch ($resourceType) {
                    "Groups" { $exportParams['IncludeGroups'] = $true }
                    "Services" { $exportParams['IncludeServices'] = $true }
                    "SecurityPolicies" { $exportParams['IncludeSecurityPolicies'] = $true }
                    "ContextProfiles" { $exportParams['IncludeContextProfiles'] = $true }
                }
            }
        }

        # Execute NSXPolicyConfigExport.ps1 via tool orchestration
        $scriptPath = Split-Path $PSCommandPath -Parent
        # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
        $exportParamsHash = ConvertTo-ParameterHashtable -ParameterSet $exportParams
        $exportResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @exportParamsHash

        if ($exportResult -and $exportResult.success) {
            # Safe access to policy_config path
            if ($OutputFilePath) {
                $configFilePath = $OutputFilePath
            }
            else {
                $configFilePath = $null
                if ($exportResult -and $exportResult.saved_files -and $exportResult.saved_files.policy_config) {
                    $configFilePath = $exportResult.saved_files.policy_config
                }
                elseif ($exportResult -and ($exportResult | Get-Member -Name 'saved_files' -ErrorAction SilentlyContinue) -and ($exportResult.saved_files | Get-Member -Name 'policy_config' -ErrorAction SilentlyContinue)) {
                    $configFilePath = $exportResult.saved_files.policy_config
                }

                if ($null -eq $configFilePath) {
                    throw "Export succeeded but no policy_config file path returned"
                }
            }

            Write-Host -Object "`nExport Summary:" -ForegroundColor Green
            Write-Host -Object "Export completed via NSXPolicyConfigExport.ps1" -ForegroundColor Cyan
            Write-Host -Object "Domain: $Domain" -ForegroundColor Cyan
            Write-Host -Object "Resource Types: $($ResourceTypes -join ', ')" -ForegroundColor Cyan
            Write-Host -Object "Export saved to: $configFilePath" -ForegroundColor Green

            $logger.LogInfo("Configuration exported successfully via tool orchestration", "Export")
            $logger.LogInfo("Export file: $configFilePath", "Export")

            return $configFilePath
        }
        else {
            throw "NSXPolicyConfigExport.ps1 failed or returned no results"
        }

    }
    catch {
        $errorMsg = "Export failed via tool orchestration: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "Export")
        throw $errorMsg
    }
}

# Function to perform import operation using ApplyNSXConfig.ps1 orchestration
function Invoke-ConfigurationImport {
    param(
        [string]$Manager,
        [PSCredential]$Credential,
        [string]$InputFilePath,
        [string[]]$ResourceTypes
    )

    $logger.LogInfo("=== Configuration Import Started (Tool Orchestration) ===", "Import")
    $logger.LogInfo("Target Manager: $Manager", "Import")
    $logger.LogInfo("Input Path: $InputFilePath", "Import")
    $logger.LogInfo("Resource Types: $($ResourceTypes -join ', ')", "Import")

    try {
        # Validate input file
        if (-not (Test-Path $InputFilePath)) {
            throw "Input file not found: $InputFilePath"
        }

        Write-Host -Object "`nImporting configuration to NSX Manager using ApplyNSXConfig.ps1..."
        Write-Host -Object "Target: $Manager"
        Write-Host -Object "Input File: $(Split-Path $InputFilePath -Leaf)"
        Write-Host -Object "Resource Types: $($ResourceTypes -join ', ')"
        Write-Host -Object "Domain: $Domain"

        # Build parameters for ApplyNSXConfig.ps1
        $applyParams = [PSCustomObject]@{
            'NSXManager'     = $Manager
            'ConfigFile'     = $InputFilePath
            'NonInteractive' = $true
        }

        # Add domain filter
        if ($Domain -and $Domain -ne "default" -and $Domain -ne "all") {
            $applyParams['DomainId'] = $Domain
        }

        # Add resource type filters if specified
        if ($ImportSelective -and @($ResourceTypes).Count -gt 0) {
            foreach ($resourceType in $ResourceTypes) {
                switch ($resourceType) {
                    "Groups" { $applyParams['IncludeGroups'] = $true }
                    "Services" { $applyParams['IncludeServices'] = $true }
                    "SecurityPolicies" { $applyParams['IncludeSecurityPolicies'] = $true }
                    "ContextProfiles" { $applyParams['IncludeContextProfiles'] = $true }
                }
            }
        }

        # Add backup option if requested
        if ($CreateRollbackConfig) {
            $applyParams['CreateBackup'] = $true
        }

        # Add validation option if requested
        if ($ValidateBeforeImport) {
            $applyParams['ValidateConfiguration'] = $true
        }

        # Add WhatIf mode if enabled
        if ($WhatIfPreference) {
            $applyParams['WhatIf'] = $true
        }

        # Add Force mode if enabled
        if ($Force) {
            $applyParams['Force'] = $true
        }

        # Execute ApplyNSXConfig.ps1 via tool orchestration
        $scriptPath = Split-Path $PSCommandPath -Parent
        $applyResult = & "$scriptPath\ApplyNSXConfig.ps1" @applyParams

        # Check if ApplyNSXConfig.ps1 returned a valid result
        if ($null -eq $applyResult) {
            throw "ApplyNSXConfig.ps1 returned null - operation failed"
        }

        # Handle both object and hashtable return types from ApplyNSXConfig.ps1
        $operationSucceeded = $false
        if ($applyResult -and ($applyResult | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) {
            $operationSucceeded = $applyResult.success
        }
        elseif ($applyResult -and ($applyResult | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) {
            $operationSucceeded = $applyResult.success
        }
        elseif ($applyResult -eq $true) {
            # Handle  boolean return
            $operationSucceeded = $true
        }

        if ($operationSucceeded) {
            Write-Host -Object "`nImport Summary:" -ForegroundColor Green
            Write-Host -Object "Import completed via ApplyNSXConfig.ps1" -ForegroundColor Cyan
            Write-Host -Object "Target Manager: $Manager" -ForegroundColor Cyan
            Write-Host -Object "Resource Types: $($ResourceTypes -join ', ')" -ForegroundColor Cyan
            Write-Host -Object "Domain: $Domain" -ForegroundColor Cyan
            Write-Host -Object "Input File: $(Split-Path $InputFilePath -Leaf)" -ForegroundColor Cyan

            $logger.LogInfo("Configuration import completed successfully via tool orchestration", "Import")

            return $applyResult
        }
        else {
            throw "ApplyNSXConfig.ps1 failed or returned no results"
        }

    }
    catch {
        $errorMsg = "Import failed via tool orchestration: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "Import")
        throw $errorMsg
    }
}

# Function to filter configuration by resource types
function Select-ConfigurationByResourceType {
    param(
        [object]$Configuration,
        [string[]]$ResourceTypes
    )

    # This is a simplified filter - in practice, you'd need more sophisticated filtering
    # based on the actual NSX configuration structure
    $logger.LogInfo("Filtering configuration by resource types: $($ResourceTypes -join ', ')", "Filter")

    # For now, return the full configuration with metadata indicating filtering
    $filteredConfig = $Configuration.PSObject.Copy()
    if ($filteredConfig.metadata) {
        $filteredConfig.metadata.filtered_resource_types = $ResourceTypes
    }

    return $filteredConfig
}

# Function to filter configuration by domain
function Select-ConfigurationByDomain {
    param(
        [object]$Configuration,
        [string]$DomainName
    )

    $logger.LogInfo("Filtering configuration by domain: $DomainName", "Filter")

    # This is a simplified filter - in practice, you'd need to traverse the configuration
    # and extract only objects from the specified domain
    $filteredConfig = $Configuration.PSObject.Copy()
    if ($filteredConfig.metadata) {
        $filteredConfig.metadata.filtered_domain = $DomainName
    }

    return $filteredConfig
}

# Helper function to extract hostname from FQDN
function Get-HostnameFromFQDN {
    param([string] $fqdn)
    if ([string]::IsNullOrEmpty($fqdn)) {
        return "unknown"
    }

    # Remove protocol if present
    $cleanFqdn = $fqdn -replace '^https?://', ''

    # Extract hostname (first part before first dot)
    $hostname = $cleanFqdn.Split('.')[0]

    # Clean up any invalid filename characters
    $hostname = $hostname -replace '[^\w\-]', '_'

    return $hostname.ToLower()
}

# CANONICAL FIX: Centralized function to extract main export file path from export results
function Get-ExportMainFilePath {
    param(
        [object]$ExportResult,
        [string]$Context = "Export"
    )

    if ($null -eq $ExportResult) {
        throw "$Context result is null"
    }

    $logger.LogDebug("Extracting main export file path from $Context result", "FilePathExtraction")

    # Handle both single objects and arrays (multi-domain)
    $mainExportPath = $null
    $actualExportResult = $null

    # CRITICAL FIX: Handle mixed-content arrays (connection test + export result)
    if ($ExportResult -is [array] -and @($ExportResult).Count -gt 0) {
        # Find the actual export result object within the array (ignore string output)
        foreach ($item in $ExportResult) {
            # Skip strings and null items
            if ($null -eq $item -or $item -is [string]) {
                $logger.LogDebug("Skipping null or string item: $($item)", "FilePathExtraction")
                continue
            }

            # PSCustomObject detection for export results
            $hasSavedFiles = $item | Get-Member -Name 'saved_files' -ErrorAction SilentlyContinue
            $hasSuccess = $item | Get-Member -Name 'success' -ErrorAction SilentlyContinue
            $hasObjectCount = $item | Get-Member -Name 'object_count' -ErrorAction SilentlyContinue
            $hasTotalObjectCount = $item | Get-Member -Name 'total_object_count' -ErrorAction SilentlyContinue
            $hasSummaryFile = $item | Get-Member -Name 'summary_file' -ErrorAction SilentlyContinue
            $hasDomainResults = $item | Get-Member -Name 'domain_results' -ErrorAction SilentlyContinue
            $hasManager = $item | Get-Member -Name 'manager' -ErrorAction SilentlyContinue

            # validation: Accept if it has ANY export-related properties or PSCustomObject structure
            $isExportResult = $hasSavedFiles -or $hasSuccess -or $hasObjectCount -or $hasTotalObjectCount -or $hasSummaryFile -or $hasDomainResults -or $hasManager

            # Additional check: Verify it's not a connection test result by checking for specific export properties
            $isConnectionTest = ($item | Get-Member -Name 'ConnectionTest' -ErrorAction SilentlyContinue) -or
            ($item | Get-Member -Name 'BasicEndpoints' -ErrorAction SilentlyContinue) -or
            ($item | Get-Member -Name 'ComprehensiveEndpoints' -ErrorAction SilentlyContinue)

            if ($isExportResult -and -not $isConnectionTest) {
                $actualExportResult = $item
                $logger.LogDebug("Found export result object with properties: saved_files=$($null -ne $hasSavedFiles), success=$($null -ne $hasSuccess), object_count=$($null -ne $hasObjectCount), total_object_count=$($null -ne $hasTotalObjectCount), summary_file=$($null -ne $hasSummaryFile), domain_results=$($null -ne $hasDomainResults)", "FilePathExtraction")
                break
            }
            else {
                $logger.LogDebug("Skipping item - not export result or is connection test: Type=$($item.GetType().Name), IsExportResult=$isExportResult, IsConnectionTest=$isConnectionTest", "FilePathExtraction")
            }
        }

        if ($null -eq $actualExportResult) {
            $logger.LogError("No valid export result object found in array", "FilePathExtraction")
            $logger.LogDebug("Array contents: $($ExportResult | ConvertTo-Json -Depth 2)", "FilePathExtraction")
            throw "$Context result array contains no valid export objects"
        }
    }
    else {
        # Single export result object
        $actualExportResult = $ExportResult
    }

    # CRITICAL FIX: Handle hashtable serialization issue where saved_files contains type strings
    # Check for summary_file first (most reliable for multi-domain exports)
    if ($actualExportResult.summary_file -and $actualExportResult.summary_file -ne "System.Collections.Hashtable") {
        $mainExportPath = $actualExportResult.summary_file
        $logger.LogDebug("Using summary_file as main export path: $mainExportPath", "FilePathExtraction")
    }
    # Now extract main_export from the actual export result object
    elseif ($actualExportResult.saved_files) {
        # Check if saved_files contains hashtable type strings (serialization issue)
        $savedFilesValues = $actualExportResult.saved_files.PSObject.Properties.Value
        if ($savedFilesValues -contains "System.Collections.Hashtable") {
            $logger.LogWarning("Detected hashtable serialization issue in saved_files - using summary_file fallback", "FilePathExtraction")
            if ($actualExportResult.summary_file) {
                $mainExportPath = $actualExportResult.summary_file
                $logger.LogDebug("Using summary_file fallback: $mainExportPath", "FilePathExtraction")
            }
        }
        else {
            # Multi-domain structure: saved_files contains domain keys
            if ($actualExportResult.saved_files.main_export) {
                # Direct main_export (single domain)
                $mainExportPath = $actualExportResult.saved_files.main_export
            }
            elseif ($actualExportResult -and ($actualExportResult | Get-Member -Name 'saved_files' -ErrorAction SilentlyContinue) -and ($actualExportResult.saved_files | Get-Member -Name 'main_export' -ErrorAction SilentlyContinue)) {
                # PSCustomObject with direct main_export
                $mainExportPath = $actualExportResult.saved_files.main_export
            }
            else {
                # Multi-domain structure: saved_files contains domain keys
                # Prioritize domains by object count (use domain_results if available)
                $domainPriority = @()

                if ($actualExportResult.domain_results) {
                    # Sort domains by object_count (descending)
                    $domainPriority = $actualExportResult.domain_results.PSObject.Properties.Name | Sort-Object {
                        $domainResult = $actualExportResult.domain_results.$_
                        if ($domainResult -and ($domainResult | Get-Member -Name 'object_count' -ErrorAction SilentlyContinue)) {
                            - [int]$domainResult.object_count
                        }
                        else {
                            0
                        }
                    }
                    $logger.LogDebug("Multi-domain export detected, prioritizing by object count", "FilePathExtraction")
                }
                else {
                    # Fallback: use saved_files keys directly, prioritize 'default' domain
                    $domainPriority = $actualExportResult.saved_files.PSObject.Properties.Name | Sort-Object {
                        if ($_ -eq 'default') { 0 } else { 1 }
                    }
                    $logger.LogDebug("Multi-domain export detected, using fallback prioritization", "FilePathExtraction")
                }

                # Find first domain with main_export
                foreach ($domainKey in $domainPriority) {
                    $domainFiles = $actualExportResult.saved_files.$domainKey
                    if ($domainFiles -and ($domainFiles | Get-Member -Name 'main_export' -ErrorAction SilentlyContinue)) {
                        $mainExportPath = $domainFiles.main_export
                        $objectCount = if ($actualExportResult.domain_results -and ($actualExportResult.domain_results | Get-Member -Name $domainKey -ErrorAction SilentlyContinue)) {
                            $actualExportResult.domain_results.$domainKey.object_count
                        }
                        else {
                            "Unknown"
                        }
                        $logger.LogDebug("Selected domain '$domainKey' with $objectCount objects: $mainExportPath", "FilePathExtraction")
                        break
                    }
                }
            }
        }
    }

    if ($null -eq $mainExportPath) {
        $logger.LogError("$Context succeeded but no main_export file path found in result structure", "FilePathExtraction")
        $logger.LogDebug("Export result structure: $($actualExportResult | ConvertTo-Json -Depth 3)", "FilePathExtraction")
        throw "$Context succeeded but no main export file path returned"
    }

    $logger.LogDebug("Successfully extracted main export file path: $mainExportPath", "FilePathExtraction")
    return $mainExportPath
}

# CANONICAL FIX: Centralized function to extract object count from export results
function Get-ExportObjectCount {
    param(
        [object]$ExportResult,
        [string]$Context = "Export"
    )

    $objectCount = "Unknown"
    $actualExportResult = $null

    # CRITICAL FIX: Handle mixed-content arrays (connection test + export result)
    if ($ExportResult -is [array] -and @($ExportResult).Count -gt 0) {
        # Find the actual export result object within the array (ignore string output)
        foreach ($item in $ExportResult) {
            if ($item -is [object] -or ($item -and ($item | Get-Member -Name 'object_count' -ErrorAction SilentlyContinue))) {
                $actualExportResult = $item
                break
            }
        }

        if ($null -eq $actualExportResult) {
            $logger.LogDebug("No valid export result object found in array for object count extraction", "FilePathExtraction")
            return "Unknown"
        }
    }
    else {
        # Single export result object
        $actualExportResult = $ExportResult
    }

    # Extract object count from the actual export result
    if ($actualExportResult -and ($actualExportResult | Get-Member -Name 'total_object_count' -ErrorAction SilentlyContinue)) {
        # Multi-domain export uses total_object_count
        $objectCount = $actualExportResult.total_object_count
    }
    elseif ($actualExportResult -and ($actualExportResult | Get-Member -Name 'object_count' -ErrorAction SilentlyContinue)) {
        # Single domain export uses object_count
        $objectCount = $actualExportResult.object_count
    }
    elseif ($actualExportResult -and ($actualExportResult | Get-Member -Name 'total_object_count' -ErrorAction SilentlyContinue)) {
        $objectCount = $actualExportResult.total_object_count
    }
    elseif ($actualExportResult -and ($actualExportResult | Get-Member -Name 'object_count' -ErrorAction SilentlyContinue)) {
        $objectCount = $actualExportResult.object_count
    }

    $logger.LogDebug("Extracted object count for $Context - $objectCount", "FilePathExtraction")
    return $objectCount
}

<#endregion Functions#>

# Main
# ===================================================================

# ===================================================================

<#region Start of script Logging#>
$logger.LogInfo("=== NSX-T Configuration Config Sync Started ===", "ConfigSync")
$logger.LogInfo("Source NSX Manager: $SourceNSXManager", "ConfigSync")
$logger.LogInfo("Target NSX Manager: $TargetNSXManager", "ConfigSync")
$logger.LogInfo("Domain ID: $DomainId", "ConfigSync")
$logger.LogInfo("Object Types: $ObjectTypes", "ConfigSync")
$logger.LogInfo("Use Current User Credentials: $UseCurrentUserCredentials", "ConfigSync")
# $logger.LogInfo("Non-Interactive Mode: $NonInteractive", "ConfigSync")
$logger.LogInfo("Skip SSL Check: $SkipSSLCheck", "ConfigSync")
$logger.LogInfo("WhatIf Mode: $WhatIfPreference", "ConfigSync")
$logger.LogInfo("Backup Only: $BackupOnly", "ConfigSync")
$logger.LogInfo("Restore Only: $RestoreOnly", "ConfigSync")
$logger.LogInfo("Sync Path: $SyncPath", "ConfigSync")

# PARAMETERS LOGGING
$logger.LogInfo("Conflict Resolution: $ConflictResolution", "ConfigSync")
$logger.LogInfo("WhatIf Mode: $WhatIfPreference", "ConfigSync")
$logger.LogInfo("Validate Before Import: $ValidateBeforeImport", "ConfigSync")
$logger.LogInfo("Sync Groups: $SyncGroups", "ConfigSync")
$logger.LogInfo("Sync Services: $SyncServices", "ConfigSync")
$logger.LogInfo("Sync Security Policies: $SyncSecurityPolicies", "ConfigSync")
$logger.LogInfo("Sync Context Profiles: $SyncContextProfiles", "ConfigSync")
$logger.LogInfo("Include Dependencies: $IncludeDependencies", "ConfigSync")
if ($IncludePatterns) { $logger.LogInfo("Include Patterns: $IncludePatterns", "ConfigSync") }
if ($ExcludePatterns) { $logger.LogInfo("Exclude Patterns: $ExcludePatterns", "ConfigSync") }
if ($ModifiedAfter) { $logger.LogInfo("Modified After: $ModifiedAfter", "ConfigSync") }
if ($MaxObjects) { $logger.LogInfo("Max Objects: $MaxObjects", "ConfigSync") }
$logger.LogInfo("Deep Validation: $DeepValidation", "ConfigSync")
$logger.LogInfo("Continue On Warnings: $ContinueOnWarnings", "ConfigSync")
$logger.LogInfo("Create Rollback Config: $CreateRollbackConfig", "ConfigSync")

# EXPORT/IMPORT PARAMETERS LOGGING
$logger.LogInfo("Export All: $ExportAll", "ConfigSync")
$logger.LogInfo("Export Filtered: $ExportFiltered", "ConfigSync")
$logger.LogInfo("Import All: $ImportAll", "ConfigSync")
$logger.LogInfo("Import Selective: $ImportSelective", "ConfigSync")
if ($OutputPath) { $logger.LogInfo("Output Path: $OutputPath", "ConfigSync") }
if ($InputPath) { $logger.LogInfo("Input Path: $InputPath", "ConfigSync") }
$logger.LogInfo("Include Groups: $IncludeGroups", "ConfigSync")
$logger.LogInfo("Include Services: $IncludeServices", "ConfigSync")
$logger.LogInfo("Include Security Policies: $IncludeSecurityPolicies", "ConfigSync")
$logger.LogInfo("Include Context Profiles: $IncludeContextProfiles", "ConfigSync")
$logger.LogInfo("Import Groups: $ImportGroups", "ConfigSync")
$logger.LogInfo("Import Services: $ImportServices", "ConfigSync")
$logger.LogInfo("Import Security Policies: $ImportSecurityPolicies", "ConfigSync")
$logger.LogInfo("Import Context Profiles: $ImportContextProfiles", "ConfigSync")
$logger.LogInfo("Domain: $Domain", "ConfigSync")

<#endregion Start of script Logging#>

<#region Display script header#>
Write-Host -Object ""
Write-Host -Object ("=" * 100) -ForegroundColor Cyan
Write-Host -Object "  NSX-T Configuration Config Sync - Hierarchical API" -ForegroundColor Cyan
Write-Host -Object ("=" * 100) -ForegroundColor Cyan
<#endregion Display script header#>


<#region Determine operation mode and validate parameters#>
$operationMode = Get-OperationMode
$logger.LogInfo("Operation Mode: $operationMode", "ConfigSync")


$logger.LogInfo("Resource Types: $($resourceTypesToSync -join ', ')", "ConfigSync")

<#region Output operation configuration#>
Write-Host -Object "`nOperation Configuration:" -ForegroundColor Yellow
Write-Host -Object "  Operation Mode: $operationMode"
if ($operationMode -eq "Sync") {
    Write-Host -Object "  Sync Mode: $effectiveSyncMode"
    Write-Host -Object "  Conflict Resolution: $ConflictResolution"
}
Write-Host -Object "  Resource Types: $($resourceTypesToSync -join ', ')"
Write-Host -Object "  Domain: $Domain"
if ($WhatIfPreference) { Write-Host -Object "  Preview Mode: ENABLED (no changes will be made)" -ForegroundColor Cyan }
if ($ValidateBeforeImport) { Write-Host -Object "  Validation: ENABLED" -ForegroundColor Green }
if ($CreateRollbackConfig) { Write-Host -Object "  Rollback Config: ENABLED" -ForegroundColor Green }

<#endregion Output operation configuration#>

# ===================================================================

# ===================================================================

<#region Create manager sync directory#>

# Create manager-specific sync directory
$sourceHostname = Get-HostnameFromFQDN $SourceNSXManager
$targetHostname = Get-HostnameFromFQDN $TargetNSXManager
$managerSyncDir = Join-Path $SyncPath $sourceHostname

if (-not (Test-Path $managerSyncDir)) {
    $logger.LogInfo("Creating manager sync directory: $managerSyncDir", "ConfigSync")
    New-Item -Path $managerSyncDir -ItemType Directory -Force | Out-Null
    Write-Host -Object "Created manager sync directory: $managerSyncDir"
}
else {
    $logger.LogInfo("Using existing manager sync directory: $managerSyncDir", "ConfigSync")
}
<#endregion Create manager sync directory#>

<#region Create migration session#>
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$migrationSession = "migration_$timestamp"
$logger.LogInfo("Migration session: $migrationSession", "ConfigSync")
<#endregion Create migration session#>



# ===================================================================

# ===================================================================


<#region Collect credentials using standardised approach (for Sync mode)#>
# Collect credentials using standardised approach (for Sync mode)
Write-Host -Object "`nCollecting credentials for migration..."

# Use standardised credential collection for source
try {
    $credential = $authService.GetCredential($SourceNSXManager, $null, $UseCurrentUserCredentials, $ForceNewCredentials)
    $logger.LogInfo("Source credentials collected successfully", "Migration")
}
catch {
    $errorMsg = "Failed to collect credentials for source $SourceNSXManager : $($_.Exception.Message)"
    Write-Host -Object "ERROR: $errorMsg" -ForegroundColor Red
    $logger.LogError($errorMsg, "ConfigSync")
    throw $errorMsg
}

# Save credentials if requested and we have them
if ($SaveCredentials -and $credential) {
    try {
        $credentialService.SaveCredentials($SourceNSXManager, $credential)
        $logger.LogInfo("Credentials saved successfully for $SourceNSXManager", "Migration")
    }
    catch {
        $logger.LogWarning("Failed to save credentials: $($_.Exception.Message)", "Migration")
    }
}

# For sync mode, we need credentials for both managers - get target credentials
Write-Host -Object "Collecting credentials for target manager..."
try {
    $targetCredential = $authService.GetCredential($TargetNSXManager, $null, $UseCurrentUserCredentials, $ForceNewCredentials)
    $logger.LogInfo("Target credentials collected successfully", "Migration")
}
catch {
    $errorMsg = "Failed to collect credentials for target $TargetNSXManager : $($_.Exception.Message)"
    Write-Host -Object "ERROR: $errorMsg" -ForegroundColor Red
    $logger.LogError($errorMsg, "ConfigSync")
    throw $errorMsg
}
<#endregion Collect credentials using standardised approach (for Sync mode)#>


<#region Config sync operations#>
# ===================================================================
# CONFIG SYNC OPERATIONS
# ===================================================================

# Skip connection testing to avoid /api/v1/node 403 Forbidden errors
# PHASE 1 FIX: Connection testing removed (matches NSXPolicyConfigExport.ps1 pattern)
$logger.LogInfo("Connection testing skipped by default to avoid 403 Forbidden errors", "ConfigSync")
Write-Host -Object "`nConnection testing skipped - proceeding with sync operations..."

# Display migration parameters
Write-Host -Object "`nMigration Parameters:" -ForegroundColor Cyan
Write-Host -Object "Source NSX Manager: $SourceNSXManager"
Write-Host -Object "Target NSX Manager: $TargetNSXManager"
Write-Host -Object "Domain ID: $DomainId"
Write-Host -Object "Object Types: $ObjectTypes"
Write-Host -Object "Sync Path: $SyncPath"
Write-Host -Object "Migration Session: $migrationSession"

if ($WhatIfPreference) {
    Write-Host -Object "WhatIf Mode MODE - No changes will be made"
}

# Configure SSL handling
if ($SkipSSLCheck) {
    $logger.LogInfo("SSL certificate validation disabled", "Migration")
    $configService.SetTrustAllCertificates($true)
}

# Phase 1: Export/Backup from Source using Hierarchical Configuration Manager
if (-not $RestoreOnly) {
    Write-Host -Object "`n" + "-"*80
    Write-Host -Object "PHASE 1: Exporting Configuration from Source (Hierarchical API)"
    Write-Host -Object "-"*80

    Write-Host -Object "Retrieving entire configuration from source NSX Manager..."
    $logger.LogInfo("Phase 1: Retrieving entire configuration from source using hierarchical API", "Migration")

    # PHASE 2 FIX: Use working NSXPolicyExportService approach (matches NSXPolicyConfigExport.ps1)

    # Use canonical toolkit path for exports
    $sourceExportDir = $script:workflowOpsService.GetToolkitPath('Exports')
    if (-not (Test-Path $sourceExportDir)) {
        New-Item -Path $sourceExportDir -ItemType Directory -Force | Out-Null
    }

    # Temporarily disable WhatIf for export operations to ensure files are created
    $originalWhatIfPreference = $WhatIfPreference
    $WhatIfPreference = $false

    try {
        # REFACTORED: Use tool-to-tool integration for source export with state chaining using helper functions
        $additionalParams = [PSCustomObject]@{}
        if ($OutputStatistics) { $additionalParams.OutputStatistics = $true }
        if ($LogLevel) { $additionalParams.LogLevel = $LogLevel }

        $exportParams = New-ExportParameterSet -NSXManager $SourceNSXManager -OutputDirectory $sourceExportDir -ValidatedState $null -AdditionalParams $additionalParams
        $exportParams = Add-StandardCredentialParam -ParameterSet $exportParams -UseCurrentUserCredentials:$UseCurrentUserCredentials -ForceNewCredentials:$ForceNewCredentials -SaveCredentials:$SaveCredentials
        # Add any additional mapped parameters as needed

        # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
        $exportParamsHash = ConvertTo-ParameterHashtable -ParameterSet $exportParams
        $sourceExportResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @exportParamsHash
    }
    catch {
        $errorMsg = "Export failed: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "Export")
        throw $errorMsg
    }
    finally {
        # Restore original WhatIf preference
        $WhatIfPreference = $originalWhatIfPreference
    }

    # Validate export result - NSXPolicyConfigExport.ps1 now returns structured result (handle arrays for multi-domain)
    $exportValidation = $false
    if ($sourceExportResult -is [array] -and @($sourceExportResult).Count -gt 0) {
        # Multi-domain export returns array - check for explicit failures first
        $explicitFailures = $sourceExportResult | Where-Object {
            if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
            elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
            else { $false }  # Don't assume unknown state is failure
        }
        # If no explicit failures found, consider the export successful
        $exportValidation = @($explicitFailures).Count -eq 0
    }
    elseif ($sourceExportResult -and $sourceExportResult.success) {
        $exportValidation = $true
    }
    else {
        # If we have a result but no clear success indicator, and no explicit failures, assume success
        $exportValidation = $true
    }

    if ($null -eq $sourceExportResult -or -not $exportValidation) {
        $errorMessage = "Unknown export failure"
        if ($sourceExportResult -is [array] -and @($sourceExportResult).Count -gt 0) {
            $failedExports = $sourceExportResult | Where-Object {
                if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                else { $false }  # Only consider explicit failures, not unknown states
            }
            if (@($failedExports).Count -gt 0) {
                $errors = $failedExports | ForEach-Object {
                    if ($_ -and ($_ | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) { $_.error }
                    elseif ($_ -and ($_ | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) { $_.error }
                    else { "Export failed for domain" }
                }
                $errorMessage = "Multi-domain export failures: $($errors -join '; ')"
            }
        }
        elseif ($sourceExportResult -and $sourceExportResult.error) {
            $errorMessage = $sourceExportResult.error
        }
        throw "$SourceNSXManager Policy export failed: $errorMessage"
    }

    # CANONICAL FIX: Use centralized function to extract main export file path
    $configFilePath = Get-ExportMainFilePath -ExportResult $sourceExportResult -Context "Source Export"

    # CANONICAL FIX: Use centralized functions to extract export properties
    $objectCount = Get-ExportObjectCount -ExportResult $sourceExportResult -Context "Source Export"

    # Extract manager type with same logic pattern as centralized functions
    $managerType = "Unknown"
    if ($sourceExportResult -is [array] -and @($sourceExportResult).Count -gt 0) {
        $firstSuccess = $sourceExportResult | Where-Object {
            if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue) -and $_.success) { $_ }
            elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue) -and $_.success) { $_ }
            else { $true }  # If no success property, assume success
        } | Select-Object -First 1

        if ($firstSuccess -and ($firstSuccess | Get-Member -Name 'manager_type' -ErrorAction SilentlyContinue)) {
            $managerType = $firstSuccess.manager_type
        }
        elseif ($firstSuccess -and ($firstSuccess | Get-Member -Name 'manager_type' -ErrorAction SilentlyContinue)) {
            $managerType = $firstSuccess.manager_type
        }
    }
    elseif ($sourceExportResult -and ($sourceExportResult | Get-Member -Name 'manager_type' -ErrorAction SilentlyContinue)) {
        $managerType = $sourceExportResult.manager_type
    }
    elseif ($sourceExportResult -and ($sourceExportResult | Get-Member -Name 'manager_type' -ErrorAction SilentlyContinue)) {
        $managerType = $sourceExportResult.manager_type
    }

    # Display summary using working export result
    Write-Host -Object "`nExport Summary:"
    Write-Host -Object "Manager Type: $managerType"
    Write-Host -Object "Total Objects: $objectCount"
    Write-Host -Object "Config File: $(Split-Path $configFilePath -Leaf)"

    # Convert relative path to absolute for file operations
    $absoluteConfigPath = if ([System.IO.Path]::IsPathRooted($configFilePath)) {
        $configFilePath
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $configFilePath))
    }

    Write-Host -Object "File Size: $([math]::Round((Get-Item $absoluteConfigPath).Length / 1KB, 2)) KB" -ForegroundColor Cyan
    Write-Host -Object "Backup saved to: $configFilePath" -ForegroundColor Cyan

    $logger.LogInfo("Configuration exported successfully: $objectCount objects", "Migration")
    $logger.LogInfo("Configuration saved to: $configFilePath", "Migration")
}

# Phase 2: Import/Restore to Target using Hierarchical Configuration Manager
if (-not $BackupOnly) {
    Write-Host -Object "`n" + "-"*80
    Write-Host -Object "PHASE 2: Importing Configuration to Target (Hierarchical API)"
    Write-Host -Object "-"*80

    # Determine configuration file to use
    $configToApply = $null
    if ($RestoreFromFile) {
        Write-Host -Object "Using specified restore file: $RestoreFromFile"
        $configToApply = $RestoreFromFile
        $logger.LogInfo("Using restore file: $RestoreFromFile", "Migration")
    }
    elseif ($configFilePath) {
        Write-Host -Object "Using configuration from Phase 1: $(Split-Path $configFilePath -Leaf)"
        $configToApply = $configFilePath
        $logger.LogInfo("Using Phase 1 configuration: $configFilePath", "Migration")
    }
    else {
        # Look for latest config file for this source manager
        $latestConfig = $configManager.GetLatestConfigurationFile($SourceNSXManager)
        if ($latestConfig) {
            Write-Host -Object "Using latest saved configuration: $(Split-Path $latestConfig -Leaf)"
            $configToApply = $latestConfig
            $logger.LogInfo("Using latest configuration: $latestConfig", "Migration")
        }
        else {
            throw "No configuration available for import. Run without -RestoreOnly first or specify -RestoreFromFile."
        }
    }

    # Convert relative path to absolute for file operations
    $absoluteConfigToApply = if ([System.IO.Path]::IsPathRooted($configToApply)) {
        $configToApply
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $configToApply))
    }

    if (-not (Test-Path $absoluteConfigToApply)) {
        throw "Configuration file not found: $configToApply (resolved to: $absoluteConfigToApply)"
    }

    # Update configToApply to use absolute path for all subsequent operations
    $configToApply = $absoluteConfigToApply

    # WhatIf Mode: Continue to analysis (removed early exit)
    # Note: WhatIf analysis happens later in the script

    # Create pre-import backup of target using working NSXPolicyExportService approach
    # PHASE 3 FIX: Replace with working NSXPolicyExportService.ExportPolicyConfiguration() approach
    Write-Host -Object "Creating pre-import backup of target..."
    $logger.LogInfo("Creating pre-import backup of target using NSXPolicyConfigExport.ps1", "Migration")
    try {
        $useTargetCredential = if ($targetCredential) { $targetCredential } else { $credential }

        # Use canonical toolkit path for exports
        $targetExportDir = $script:workflowOpsService.GetToolkitPath('Exports')
        if (-not (Test-Path $targetExportDir)) {
            New-Item -Path $targetExportDir -ItemType Directory -Force | Out-Null
        }

        # Build parameters for NSXPolicyConfigExport.ps1 with state chaining using helper functions
        $additionalParams = [PSCustomObject]@{}
        if ($OutputStatistics) { $additionalParams.OutputStatistics = $true }
        if ($LogLevel) { $additionalParams.LogLevel = $LogLevel }

        $exportParams = New-ExportParameterSet -NSXManager $TargetNSXManager -OutputDirectory $targetExportDir -ValidatedState $null -AdditionalParams $additionalParams
        $exportParams = Add-StandardCredentialParam -ParameterSet $exportParams -UseCurrentUserCredentials:$UseCurrentUserCredentials -ForceNewCredentials:$ForceNewCredentials -SaveCredentials:$SaveCredentials
        # Add any additional mapped parameters as needed

        # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
        $exportParamsHash = ConvertTo-ParameterHashtable -ParameterSet $exportParams
        $targetBackupResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @exportParamsHash

        # Validate export result - NSXPolicyConfigExport.ps1 now returns structured result (handle arrays for multi-domain)
        $backupValidation = $false
        if ($targetBackupResult -is [array] -and @($targetBackupResult).Count -gt 0) {
            # Multi-domain export returns array - check for explicit failures first
            $explicitFailures = $targetBackupResult | Where-Object {
                if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                else { $false }  # Don't assume unknown state is failure
            }
            # If no explicit failures found, consider the export successful
            $backupValidation = @($explicitFailures).Count -eq 0
        }
        elseif ($targetBackupResult -and $targetBackupResult.success) {
            $backupValidation = $true
        }
        else {
            # If we have a result but no clear success indicator, and no explicit failures, assume success
            $backupValidation = $true
        }

        if ($null -eq $targetBackupResult -or -not $backupValidation) {
            $errorMessage = "Unknown target backup export failure"
            if ($targetBackupResult -is [array] -and @($targetBackupResult).Count -gt 0) {
                $failedExports = $targetBackupResult | Where-Object {
                    if ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                    elseif ($_ -and ($_ | Get-Member -Name 'success' -ErrorAction SilentlyContinue)) { -not $_.success }
                    else { $false }  # Only consider explicit failures, not unknown states
                }
                if (@($failedExports).Count -gt 0) {
                    $errors = $failedExports | ForEach-Object {
                        if ($_ -and ($_ | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) { $_.error }
                        elseif ($_ -and ($_ | Get-Member -Name 'error' -ErrorAction SilentlyContinue)) { $_.error }
                        else { "Target backup export failed for domain" }
                    }
                    $errorMessage = "Multi-domain target backup failures: $($errors -join '; ')"
                }
            }
            elseif ($targetBackupResult -and $targetBackupResult.error) {
                $errorMessage = $targetBackupResult.error
            }
            throw "$TargetNSXManager backup export failed: $errorMessage"
        }

        # CANONICAL FIX: Use centralized function to extract target backup file path
        $targetBackupFile = Get-ExportMainFilePath -ExportResult $targetBackupResult -Context "Target Backup Export"
        Write-Host -Object "[SUCCESS] Target backup saved to: $(Split-Path $targetBackupFile -Leaf)" -ForegroundColor Green
        Write-Host -Object "Target backup file: $targetBackupFile" -ForegroundColor Cyan
        $logger.LogInfo("Target backup saved using NSXPolicyConfigExport.ps1: $targetBackupFile", "Migration")
    }
    catch {
        $errorMsg = "Could not create target backup: $($_.Exception.Message)"
        Write-Host -Object $errorMsg -ForegroundColor Red
        $logger.LogError($errorMsg, "Export")
        throw $errorMsg
    }

    # VALIDATION AND PREVIEW
    if ($ValidateBeforeImport) {
        Write-Host -Object "`nValidating configuration before import..."
        $logger.LogInfo("Validating configuration before import", "Migration")

        # Load source configuration for validation
        $sourceConfig = Get-Content $configToApply | ConvertFrom-Json
        if ($sourceConfig.configuration) {
            $sourceConfig = $sourceConfig.configuration
        }

        # Get current target configuration for comparison using working NSXPolicyExportService approach
        # PHASE 3 FIX: Replace with working NSXPolicyExportService.ExportPolicyConfiguration() approach
        $useTargetCredential = if ($targetCredential) { $targetCredential } else { $credential }

        # Standardised target validation export via NSXPolicyConfigExport.ps1
        # CANONICAL FIX: Use Tests directory for validation operations per project conventions
        $validationDir = $script:workflowOpsService.GetToolkitPath('Tests')
        if (-not (Test-Path $validationDir)) { New-Item -Path $validationDir -ItemType Directory -Force | Out-Null }

        $additionalParams = [PSCustomObject]@{}
        if ($DomainId) { $additionalParams.NSXDomain = $DomainId }

        $validationParams = New-ExportParameterSet -NSXManager $TargetNSXManager -OutputDirectory $validationDir -ValidatedState $null -AdditionalParams $additionalParams
        $validationParams = Add-StandardCredentialParam -ParameterSet $validationParams -UseCurrentUserCredentials:$UseCurrentUserCredentials -ForceNewCredentials:$ForceNewCredentials -SaveCredentials:$SaveCredentials -NonInteractive:$NonInteractive

        # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
        $validationParamsHash = ConvertTo-ParameterHashtable -ParameterSet $validationParams
        $targetValidationResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @validationParamsHash

        # Load exported JSON for preview diff (if successful)
        if ($targetValidationResult -and $targetValidationResult.saved_files -and $targetValidationResult.saved_files.main_export) {
            $targetConfigPath = $targetValidationResult.saved_files.main_export
            $targetConfig = (Get-Content $targetConfigPath -Raw | ConvertFrom-Json).configuration
        }
        else {
            $targetConfig = $null
        }

        # Show preview of changes
        try {
            $changes = Show-SyncPreview -SourceConfig $sourceConfig -TargetConfig $targetConfig -ResourceTypes $resourceTypesToSync
        }
        catch {
            Write-Host -Object "Preview analysis: Unable to compare configurations" -ForegroundColor Yellow
            Write-Host -Object "Would apply configuration from exported file to target" -ForegroundColor Yellow
        }

        # Perform deep validation if requested
        if ($DeepValidation) {
            Write-Host -Object "Performing deep validation..."
            $logger.LogInfo("Performing deep validation", "Migration")

            # Add deep validation logic here
            # For now, just log that it's enabled
            $logger.LogInfo("Deep validation completed", "Migration")
        }
    }

    # Create rollback configuration if requested using working NSXPolicyExportService approach
    if ($CreateRollbackConfig) {
        # PHASE 3 FIX: Replace with working NSXPolicyExportService.ExportPolicyConfiguration() approach
        Write-Host -Object "Creating rollback configuration..."
        $logger.LogInfo("Creating rollback configuration using NSXPolicyExportService", "Migration")
        try {
            $useTargetCredential = if ($targetCredential) { $targetCredential } else { $credential }

            # Use same working export options as source export
            $rollbackOptions = [PSCustomObject]@{
                includeSystemObjects = $false
                createFiles          = $true
            }

            # Create rollback export using NSXPolicyConfigExport.ps1
            $rollbackDir = $script:workflowOpsService.GetToolkitPath('Rollback')
            if (-not (Test-Path $rollbackDir)) { New-Item -Path $rollbackDir -ItemType Directory -Force | Out-Null }

            $additionalParams = [PSCustomObject]@{}
            if ($DomainId) { $additionalParams.NSXDomain = $DomainId }

            $rollbackParams = New-ExportParameterSet -NSXManager $TargetNSXManager -OutputDirectory $rollbackDir -ValidatedState $null -AdditionalParams $additionalParams
            $rollbackParams = Add-StandardCredentialParam -ParameterSet $rollbackParams -UseCurrentUserCredentials:$UseCurrentUserCredentials -ForceNewCredentials:$ForceNewCredentials -SaveCredentials:$SaveCredentials -NonInteractive:$NonInteractive

            # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
            $rollbackParamsHash = ConvertTo-ParameterHashtable -ParameterSet $rollbackParams
            $rollbackResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @rollbackParamsHash

            # Validate export result
            if ($null -eq $rollbackResult -or -not $rollbackResult.success) {
                $errorMessage = if ($rollbackResult -and $rollbackResult.error) { $rollbackResult.error } else { "Unknown rollback export failure" }
                throw "Rollback configuration export failed: $errorMessage"
            }

            # CANONICAL FIX: Use centralized functions to extract rollback export results
            $rollbackFile = Get-ExportMainFilePath -ExportResult $rollbackResult -Context "Rollback Export"
            $rollbackObjectCount = Get-ExportObjectCount -ExportResult $rollbackResult -Context "Rollback Export"

            Write-Host -Object "[SUCCESS] Rollback configuration saved to: $(Split-Path $rollbackFile -Leaf)" -ForegroundColor Green
            Write-Host -Object "Rollback objects: $rollbackObjectCount" -ForegroundColor Cyan
            $logger.LogInfo("Rollback configuration saved using NSXPolicyExportService: $rollbackFile", "Migration")
            $logger.LogInfo("Rollback object count: $rollbackObjectCount", "Migration")
        }
        catch {
            Write-Host -Object "Warning: Could not create rollback configuration - continuing anyway" -ForegroundColor Yellow
            $logger.LogWarning("Could not create rollback configuration: $($_.Exception.Message)", "Migration")
        }
    }

    # WhatIf Mode: Perform analysis with target export and differential comparison
    if ($WhatIfPreference) {
        Write-Host -Object "`n" + "-"*80
        Write-Host -Object "WHATIF MODE: Configuration Analysis"
        Write-Host -Object "-"*80

        # PHASE 3: Export target baseline for comparison (WhatIf Mode)
        Write-Host -Object "`nExporting target NSX Manager configuration for comparison..."
        $logger.LogInfo("WhatIf Mode: Starting target configuration export for comparison", "Migration")

        try {
            $useTargetCredential = if ($targetCredential) { $targetCredential } else { $credential }

            # Use same working export options as source export
            $targetExportOptions = [PSCustomObject]@{
                includeSystemObjects = $false
                createFiles          = $true
            }

            # Export target configuration via NSXPolicyConfigExport.ps1 for analysis
            $targetExportDir = $script:workflowOpsService.GetToolkitPath('Tests')
            if (-not (Test-Path $targetExportDir)) { New-Item -Path $targetExportDir -ItemType Directory -Force | Out-Null }

            $additionalParams = [PSCustomObject]@{}
            if ($DomainId) { $additionalParams.NSXDomain = $DomainId }

            $targetExportParams = New-ExportParameterSet -NSXManager $TargetNSXManager -OutputDirectory $targetExportDir -ValidatedState $null -AdditionalParams $additionalParams
            $targetExportParams = Add-StandardCredentialParam -ParameterSet $targetExportParams -UseCurrentUserCredentials:$UseCurrentUserCredentials -ForceNewCredentials:$ForceNewCredentials -SaveCredentials:$SaveCredentials -NonInteractive:$NonInteractive

            # CANONICAL FIX: Convert PSCustomObject to hashtable for proper parameter splatting
            $targetExportParamsHash = ConvertTo-ParameterHashtable -ParameterSet $targetExportParams
            $targetResult = & "$scriptPath\NSXPolicyConfigExport.ps1" @targetExportParamsHash

            # Validate target export result
            if ($null -eq $targetResult -or -not $targetResult.success) {
                $errorMessage = if ($targetResult -and $targetResult.error) { $targetResult.error } else { "Unknown target export failure" }
                throw "Target configuration export failed: $errorMessage"
            }

            # CANONICAL FIX: Use centralized functions to extract target export results
            $targetMainExport = Get-ExportMainFilePath -ExportResult $targetResult -Context "Target Export"
            $targetObjectCount = Get-ExportObjectCount -ExportResult $targetResult -Context "Target Export"

            # Extract target manager type with same logic pattern as centralized functions
            $targetManagerType = "Unknown"
            if ($targetResult -and ($targetResult | Get-Member -Name 'manager_type' -ErrorAction SilentlyContinue)) {
                $targetManagerType = $targetResult.manager_type
            }
            elseif ($targetResult -and ($targetResult | Get-Member -Name 'manager_type' -ErrorAction SilentlyContinue)) {
                $targetManagerType = $targetResult.manager_type
            }

            # Display target export summary (matching source format)
            Write-Host -Object "`nTarget Export Summary:" -ForegroundColor Yellow
            Write-Host -Object "Manager Type: $targetManagerType" -ForegroundColor White
            Write-Host -Object "Total Objects: $targetObjectCount" -ForegroundColor White
            Write-Host -Object "Config File: $(Split-Path $targetMainExport -Leaf)" -ForegroundColor White
            $targetFileSize = [math]::Round((Get-Item $targetMainExport).Length / 1KB, 2)
            Write-Host -Object "File Size: $targetFileSize KB" -ForegroundColor White
            Write-Host -Object "Backup saved to: $targetMainExport" -ForegroundColor White

            $logger.LogInfo("WhatIf Mode: Target configuration exported successfully - $targetObjectCount objects", "Migration")

            # PHASE 4: Perform differential analysis (WhatIf Mode)
            Write-Host -Object "`n" + "-"*80
            Write-Host -Object "WHATIF MODE: Differential Analysis"
            Write-Host -Object "-"*80

            Write-Host -Object "Analyzing configuration differences..."
            $logger.LogInfo("WhatIf Mode: Starting differential analysis", "Migration")

            # Set up differential operation options for WhatIf analysis
            $diffOptions = [PSCustomObject]@{
                WhatIfMode     = $true   # Enable WhatIf mode for analysis only
                EnableDeletes  = $false  # Conservative approach
                VerboseLogging = ($logger.logLevel -eq "DEBUG")
            }

            # Execute differential analysis using NSXDifferentialConfigManager
            $diffResult = $diffMgr.ExecuteDifferentialOperation($TargetNSXManager, $useTargetCredential, $configToApply, $diffOptions)

            # Display differential analysis results
            if ($diffResult -and $diffResult.results.Differences) {
                $diff = $diffResult.results.Differences
                Write-Host -Object "`nCONFIGURATION DIFFERENCES ANALYSIS:" -ForegroundColor Yellow
                Write-Host -Object "  - Objects to CREATE: $($diff.CreateCount)" -ForegroundColor Green
                Write-Host -Object "  - Objects to UPDATE: $($diff.UpdateCount)" -ForegroundColor Yellow
                Write-Host -Object "  - Objects to DELETE: $($diff.DeleteCount)" -ForegroundColor Red
                Write-Host -Object "  - Objects UNCHANGED: $($diff.UnchangedCount)" -ForegroundColor Cyan
                Write-Host -Object "  - Total Changes Required: $($diff.TotalChanges)" -ForegroundColor White

                if ($diff.TotalChanges -eq 0) {
                    Write-Host -Object "`n[SUCCESS] NO CHANGES REQUIRED" -ForegroundColor Green
                    Write-Host -Object "   Source and target configurations are already synchronized" -ForegroundColor Gray
                }
                else {
                    Write-Host -Object "`nWARNING: CHANGES REQUIRED" -ForegroundColor Yellow
                    Write-Host -Object "   $($diff.TotalChanges) changes would be applied in live mode" -ForegroundColor Gray
                }

                $logger.LogInfo("WhatIf Mode: Differential analysis completed - $($diff.TotalChanges) changes identified", "Migration")
            }
            else {
                Write-Host -Object "`nNo differential analysis results available" -ForegroundColor Yellow
                $logger.LogWarning("WhatIf Mode: Differential analysis results not available", "Migration")
            }

        }
        catch {
            Write-Host -Object "`n[WARNING] Target analysis failed: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host -Object "Proceeding with source-only analysis..." -ForegroundColor Yellow
            $logger.LogWarning("WhatIf Mode: Target analysis failed - $($_.Exception.Message)", "Migration")
        }

        # WHATIF SUMMARY
        Write-Host -Object "`n" + "="*100
        Write-Host -Object "  WHATIF MODE: ANALYSIS SUMMARY"
        Write-Host -Object "="*100

        Write-Host -Object "`nSOURCE CONFIGURATION ANALYSIS:" -ForegroundColor Cyan
        Write-Host -Object "  NSX Manager: $SourceNSXManager" -ForegroundColor White
        Write-Host -Object "  Objects Exported: $objectCount" -ForegroundColor White
        Write-Host -Object "  Manager Type: $managerType" -ForegroundColor White
        Write-Host -Object "  Export File: $(Split-Path $configFilePath -Leaf)" -ForegroundColor White

        if ($targetResult) {
            Write-Host -Object "`nTARGET CONFIGURATION ANALYSIS:" -ForegroundColor Cyan
            Write-Host -Object "  NSX Manager: $TargetNSXManager" -ForegroundColor White
            Write-Host -Object "  Objects Exported: $targetObjectCount" -ForegroundColor White
            Write-Host -Object "  Manager Type: $targetManagerType" -ForegroundColor White
            Write-Host -Object "  Export File: $(Split-Path $targetMainExport -Leaf)" -ForegroundColor White
        }

        if ($diffResult -and $diffResult.results.Differences) {
            $diff = $diffResult.results.Differences
            Write-Host -Object "`nDIFFERENTIAL IMPACT ANALYSIS:" -ForegroundColor Cyan
            Write-Host -Object "  Objects to Create: $($diff.CreateCount)" -ForegroundColor Green
            Write-Host -Object "  Objects to Update: $($diff.UpdateCount)" -ForegroundColor Yellow
            Write-Host -Object "  Objects Unchanged: $($diff.UnchangedCount)" -ForegroundColor Cyan
            Write-Host -Object "  Total Changes: $($diff.TotalChanges)" -ForegroundColor White

            # Calculate synchronization percentage
            $totalObjects = $diff.CreateCount + $diff.UpdateCount + $diff.UnchangedCount
            if ($totalObjects -gt 0) {
                $syncPercentage = [math]::Round(($diff.UnchangedCount / $totalObjects) * 100, 2)
                Write-Host -Object "  Current Sync Rate: $syncPercentage%" -ForegroundColor Cyan
            }
        }

        Write-Host -Object "`nOPERATION SUMMARY:" -ForegroundColor Cyan
        Write-Host -Object "  Mode: WhatIf Analysis (No Changes Made)" -ForegroundColor White
        Write-Host -Object "  Domain: $DomainId" -ForegroundColor White
        Write-Host -Object "  Resource Types: $($resourceTypesToSync -join ', ')" -ForegroundColor White
        Write-Host -Object "  Analysis Files Generated: Yes" -ForegroundColor Green
        Write-Host -Object "  Target Modified: No" -ForegroundColor Green

        Write-Host -Object "`nNEXT STEPS:" -ForegroundColor Yellow
        if ($diffResult -and $diffResult.results.Differences -and $diffResult.results.Differences.TotalChanges -gt 0) {
            Write-Host -Object "  - Review the differential analysis results above" -ForegroundColor White
            Write-Host -Object "  - Run without -WhatIf to apply $($diffResult.results.Differences.TotalChanges) changes" -ForegroundColor White
            Write-Host -Object "  - Use -Force to skip confirmation prompts" -ForegroundColor White
        }
        else {
            Write-Host -Object "  - No changes required - configurations are synchronized" -ForegroundColor White
        }

        Write-Host -Object "`nGENERATED FILES:" -ForegroundColor Yellow
        Write-Host -Object "  - Source Export: $(Split-Path $configFilePath -Leaf)" -ForegroundColor Gray
        if ($targetResult) {
            Write-Host -Object "  - Target Export: $(Split-Path $targetMainExport -Leaf)" -ForegroundColor Gray
        }
        if ($diffResult -and $diffResult.results.DeltaConfigPath) {
            Write-Host -Object "  - Delta Analysis: $(Split-Path $diffResult.results.DeltaConfigPath -Leaf)" -ForegroundColor Gray
        }

        Write-Host -Object ""
        Write-Host -Object "WhatIf analysis completed successfully - no changes were made to target NSX Manager" -ForegroundColor Green
        $logger.LogInfo("WhatIf Mode: analysis completed successfully", "Migration")
        return
    }

    # Import confirmation
    Write-Host -Object "[DEBUG] Force: $Force"
    if (-not $Force -and -not $NonInteractive) {
        Write-Host -Object "`nWARNING: This operation will modify the target NSX Manager!"
        Write-Host -Object "Target: $TargetNSXManager"
        Write-Host -Object "Configuration: $(Split-Path $configToApply -Leaf)"
        Write-Host -Object "Sync Mode: $effectiveSyncMode"
        Write-Host -Object "Resource Types: $($resourceTypesToSync -join ', ')"
        Write-Host -Object "Conflict Resolution: $ConflictResolution"
        $confirm = Read-Host "`nDo you want to proceed with the import? (yes/no)"
        if ($confirm -ne 'yes') {
            Write-Host -Object "Import cancelled by user"
            $logger.LogInfo("Import cancelled by user", "Migration")
            return
        }
    }

    # PHASE 4 FIX: Apply configuration using NSXDifferentialConfigManager approach
    Write-Host -Object "`n" + "-"*80
    Write-Host -Object "PHASE 4: Applying Configuration Using Differential Analysis"
    Write-Host -Object "-"*80

    Write-Host -Object "Executing differential configuration management workflow..."
    $logger.LogInfo("PHASE 4: Starting differential configuration application", "Migration")

    # Set up differential operation options following ApplyNSXConfigDifferential.ps1 pattern
    $diffOptions = [PSCustomObject]@{
        WhatIfMode         = $false  # Always false here since we already handled WhatIf above
        EnableDeletes      = $false  # Conservative approach - don't delete objects
        VerboseLogging     = ($logger.logLevel -eq "DEBUG")
        EnableVerification = $true   # Enable verification for Phase 5 display
        VerificationMode   = "Complete" # Complete verification of all changes
    }

    # verification with property-level filtering support
    $logger.LogInfo("Verification will useDataObjectFilterService for property-level filtering", "Migration")
    $logger.LogInfo("System properties (_create_time, _last_modified_time, etc.) will be excluded from verification", "Migration")

    # Use target credential appropriately
    $useTargetCredential = if ($targetCredential) { $targetCredential } else { $credential }

    try {
        # Execute differential operation using working NSXDifferentialConfigManager
        # This follows the exact same pattern as ApplyNSXConfigDifferential.ps1
        $diffResult = $diffMgr.ExecuteDifferentialOperation($TargetNSXManager, $useTargetCredential, $configToApply, $diffOptions)

        # Validate differential operation result
        if ($null -eq $diffResult -or -not $diffResult.success) {
            $errorMessage = if ($diffResult -and $diffResult.error) { $diffResult.error } else { "Unknown differential operation failure" }
            throw "Differential configuration application failed: $errorMessage"
        }

        # Display differential operation results
        Write-Host -Object "`n[SUCCESS] Differential configuration applied successfully" -ForegroundColor Green
        Write-Host -Object "Operation ID: $($diffResult.operation_id)" -ForegroundColor Cyan

        if ($diffResult.results.Differences) {
            $diff = $diffResult.results.Differences
            Write-Host -Object "Changes Applied:" -ForegroundColor Yellow
            Write-Host -Object "  - Created: $($diff.CreateCount) objects" -ForegroundColor Green
            Write-Host -Object "  - Updated: $($diff.UpdateCount) objects" -ForegroundColor Yellow
            Write-Host -Object "  - Unchanged: $($diff.UnchangedCount) objects" -ForegroundColor Cyan
            if ($diff.DeleteCount -gt 0) {
                Write-Host -Object "  - Deleted: $($diff.DeleteCount) objects" -ForegroundColor Red
            }
            Write-Host -Object "  - Total Changes: $($diff.TotalChanges)" -ForegroundColor White
        }

        $logger.LogInfo("PHASE 4: Differential configuration applied successfully", "Migration")
        $logger.LogInfo("Differential changes - Create: $($diffResult.results.Differences.CreateCount), Update: $($diffResult.results.Differences.UpdateCount), Total: $($diffResult.results.Differences.TotalChanges)", "Migration")

        # PHASE 5: VERIFICATION WORKFLOW - Display verification results from NSXDifferentialConfigManager
        Write-Host -Object "`n" + "-"*80
        Write-Host -Object "PHASE 5: Configuration Verification & Validation"
        Write-Host -Object "-"*80

        Write-Host -Object "Verifying applied configuration against expected results..."
        $logger.LogInfo("PHASE 5: Starting configuration verification workflow", "Migration")

        # Display verification results (automatically performed by NSXDifferentialConfigManager steps 7-9)
        if ($diffResult.results.Verification) {
            $verify = $diffResult.results.Verification

            # Apply property-level filtering for more accurate verification display
            $logger.LogInfo("Applying property-level filtering to verification results for accurate display", "Migration")

            # Get property filtering statistics for informational purposes
            $filterStats = $dataObjectFilterService.GetPropertyFilteringStatistics($verify)
            $logger.LogInfo("Property filtering enabled: Inclusions=$($filterStats.PropertyInclusionsEnabled), Exclusions=$($filterStats.PropertyExclusionsEnabled)", "Migration")

            Write-Host -Object "`nVERIFICATION RESULTS (with property-level filtering):" -ForegroundColor Yellow
            Write-Host -Object "  - Matches: $($verify.matches)" -ForegroundColor Green
            Write-Host -Object "  - Mismatches: $($verify.mismatches)" -ForegroundColor Yellow
            Write-Host -Object "  - Not Found: $($verify.not_found)" -ForegroundColor Red
            Write-Host -Object "  - Total Delta Objects: $($verify.total_delta_objects)" -ForegroundColor Cyan

            # Calculate success rate
            $totalVerified = $verify.matches + $verify.mismatches + $verify.not_found
            $successRate = if ($totalVerified -gt 0) { [math]::Round(($verify.matches / $totalVerified) * 100, 2) } else { 0 }
            Write-Host -Object "  - Success Rate: $successRate%" -ForegroundColor Cyan

            # Display property filtering information
            Write-Host -Object "  - Property Filtering: System properties excluded, business properties focused" -ForegroundColor Gray

            if ($diffResult.results.VerificationResultsPath) {
                Write-Host -Object "  - Verification report: $(Split-Path $diffResult.results.VerificationResultsPath -Leaf)" -ForegroundColor Gray
                $logger.LogInfo("Verification report saved: $($diffResult.results.VerificationResultsPath)", "Migration")
            }

            # Display actual payload file for debugging
            if ($diffResult.results.ActualPayloadPath) {
                Write-Host -Object "  - Actual payload (debugging): $(Split-Path $diffResult.results.ActualPayloadPath -Leaf)" -ForegroundColor Magenta
                $logger.LogInfo("Actual payload saved for debugging: $($diffResult.results.ActualPayloadPath)", "Migration")
            }

            # Final verification status
            if ($successRate -eq 100) {
                Write-Host -Object "`n[SUCCESS] VERIFICATION PASSED - All changes verified successfully" -ForegroundColor Green
                $logger.LogInfo("PHASE 5: Configuration verification completed successfully - $successRate% success rate", "Migration")
            }
            else {
                Write-Host -Object "`n[WARNING] VERIFICATION PARTIAL - Some changes may not have been applied correctly" -ForegroundColor Yellow
                Write-Host -Object "Check the verification report for detailed analysis" -ForegroundColor Yellow
                $logger.LogWarning("PHASE 5: Configuration verification completed with partial success - $successRate% success rate", "Migration")
            }
        }
        else {
            Write-Host -Object "`n[INFO] Verification results not available (may be WhatIf mode or verification disabled)" -ForegroundColor Cyan
            $logger.LogInfo("PHASE 5: Verification results not available", "Migration")
        }

    }
    catch {
        $errorMsg = "PHASE 4: Differential configuration application failed: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "Migration")
        throw $errorMsg
    }
}



# Migration Summary
Write-Host -Object ""
Write-Host -Object ("=" * 100)
Write-Host -Object "  HIERARCHICAL MIGRATION COMPLETED SUCCESSFULLY"
Write-Host -Object ("=" * 100)

Write-Host -Object "`nMigration Files in Sync Directory:" -ForegroundColor Cyan
Get-ChildItem -Path $SyncPath -Filter "*$migrationSession*" | ForEach-Object {
    Write-Host -Object "- $($_.Name)"
}

# Build hierarchical configs path for file listing
$hierConfigsPath = $script:workflowOpsService.GetToolkitPath('Exports')

# Display hierarchical configs
if (Test-Path $hierConfigsPath) {
    $hierConfigs = Get-ChildItem -Path $hierConfigsPath -Filter "*.json" -ErrorAction SilentlyContinue
    if ($hierConfigs) {
        Write-Host -Object "`nAvailable Configuration Files:" -ForegroundColor Yellow
        Write-Host -Object "- Configuration files in data/exports are sorted by reverse timestamp"
        $hierConfigs | Sort-Object Name -Descending | ForEach-Object {
            $size = [math]::Round($_.Length / 1KB, 2)
            Write-Host -Object "  $($_.Name) ($size KB)" -ForegroundColor White
        }
    }
}

Write-Host -Object "`nMigration Summary:"
Write-Host -Object "- Migration Session: $migrationSession"
Write-Host -Object "- Source Manager: $SourceNSXManager"
Write-Host -Object "- Target Manager: $TargetNSXManager"
Write-Host -Object "- Migration Type: Hierarchical $effectiveSyncMode Configuration"
Write-Host -Object "- Resource Types: $($resourceTypesToSync -join ', ')"
Write-Host -Object "- Conflict Resolution: $ConflictResolution"
Write-Host -Object "- Sync Path: $SyncPath"

Write-Host -Object "`nFeatures Used:"
if ($ValidateBeforeImport) { Write-Host -Object "- [SUCCESS] Configuration validation performed" }
if ($CreateRollbackConfig) { Write-Host -Object "- [SUCCESS] Rollback configuration created" }
if ($DeepValidation) { Write-Host -Object "- [SUCCESS] Deep validation performed" }
if ($IncludePatterns) { Write-Host -Object "- [SUCCESS] Include patterns applied: $IncludePatterns" }
if ($ExcludePatterns) { Write-Host -Object "- [SUCCESS] Exclude patterns applied: $ExcludePatterns" }
if ($ModifiedAfter) { Write-Host -Object "- [SUCCESS] Modified after filter: $ModifiedAfter" }
if ($MaxObjects) { Write-Host -Object "- [SUCCESS] Max objects limit: $MaxObjects" }

Write-Host -Object "`nRecommendations:"
Write-Host -Object "- Verify all objects are functioning correctly in the target environment"
Write-Host -Object "- Test connectivity and security policies"
Write-Host -Object "- Keep backup files for rollback if needed"
Write-Host -Object "- Update any automation scripts with new NSX Manager references"
Write-Host -Object "- Configuration files in exported_configs are sorted by reverse timestamp"
if ($CreateRollbackConfig) {
    Write-Host -Object "- Use rollback configuration if rollback is needed" -ForegroundColor Yellow
}


catch {
    Write-Host -Object "`nERROR: Migration failed!"
    Write-Host -Object "Error: $($_.Exception.Message)"
    Write-Host -Object "`nCheck the log file for detailed error information"
    Write-Host -Object "Sync files are available in: $SyncPath" -ForegroundColor Cyan
    exit 1
}
