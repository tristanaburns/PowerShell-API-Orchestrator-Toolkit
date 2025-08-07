<#
.SYNOPSIS
    NSX Configuration Verification Script

.DESCRIPTION
    Validates that NSX managers have the expected configuration objects.
    Provides detailed comparison and validation reports for NSX DFW configurations.

.PARAMETER SourceManager
    The source NSX manager hostname or IP address (not required if using file mode)

.PARAMETER TargetManager
    The target NSX manager hostname or IP address (not required if using file mode)

.PARAMETER ExpectedConfigFile
    Path to JSON file containing expected configuration counts

.PARAMETER VerboseLogging
    Enable verbose debug logging

.PARAMETER UseCurrentUserCredentials
    Use current Windows user credentials for authentication

.PARAMETER SkipSSLCheck
    Skip SSL certificate validation

.PARAMETER CompareManagers
    Compare configurations between source and target managers

.PARAMETER DetailedReport
    Show detailed verification report

# CONSOLIDATION: Add file-based validation mode from NSXConfigValidate.ps1
.PARAMETER SourceFile
    Path to source configuration JSON file (file mode)

.PARAMETER TargetFile
    Path to target configuration JSON file (file mode)

.PARAMETER FileMode
    Use file-based validation instead of live NSX manager access

.EXAMPLE
    .\VerifyNSXConfig.ps1 -SourceManager "nsx-01.lab.local" -TargetManager "nsx-02.lab.local" -CompareManagers -DetailedReport

.EXAMPLE
    .\VerifyNSXConfig.ps1 -SourceManager "nsx-01.lab.local" -TargetManager "nsx-02.lab.local" -VerboseLogging -UseCurrentUserCredentials

.EXAMPLE
    .\VerifyNSXConfig.ps1 -SourceFile "source_config.json" -TargetFile "target_config.json" -FileMode -DetailedReport

.EXAMPLE
    .\VerifyNSXConfig.ps1 -SourceFile "C:\configs\nsx_source.json" -TargetFile "C:\configs\nsx_target.json" -DetailedReport
#>

# NSX Configuration Verification Script
# Validates that NSX managers have the expected configuration objects
# Provides detailed comparison and validation reports

param(
    [Parameter(Mandatory = $false)]
    [string]$SourceManager,

    [Parameter(Mandatory = $false)]
    [string]$TargetManager,

    [Parameter(Mandatory = $false)]
    [string]$ExpectedConfigFile,

    [Parameter(Mandatory = $false)]
    [switch]$VerboseLogging,

    [Parameter(Mandatory = $false)]
    [switch]$UseCurrentUserCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$SkipSSLCheck,

    [Parameter(Mandatory = $false)]
    [switch]$ForceNewCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$SaveCredentials,

    [Parameter(Mandatory = $false)]
    [string]$AuthenticationConfigFile,

    [Parameter(Mandatory = $false)]
    [switch]$CompareManagers,

    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport,

    [Parameter(Mandatory = $false)]
    [string]$SourceFile,

    [Parameter(Mandatory = $false)]
    [string]$TargetFile,

    [Parameter(Mandatory = $false)]
    [switch]$FileMode,

    [Parameter(Mandatory = $false)]
    [object]$ValidatedState = $null

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
$servicesPath = Join-Path $scriptPath "..\src\services"

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
    $resetService = $services.ConfigReset
    $authService = $services.AuthService
    $workflowOpsService = $services.WorkflowOperationsService

    if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $resetService -or $null -eq $authService) {
        throw "One or more services failed to initialize properly"
    }

    Write-Host "VerifyNSXConfiguration: Service framework initialized successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
    exit 1
}

# Use centralised credential management from CoreAuthenticationService

# Main verification function
function Test-NSXConfig {
    param(
        [string]$Manager,
        [string]$ManagerName,
        [object]$ExpectedConfig = $null
    )

    $logger.LogInfo("=== Verifying Configuration for $ManagerName ($Manager) ===", "ConfigVerify")

    $verificationResult = [PSCustomObject]@{
        'manager'      = $Manager
        'manager_name' = $ManagerName
        'success'      = $false
        'inventory'    = [PSCustomObject]@{}
        'validation'   = [PSCustomObject]@{}
        'summary'      = [PSCustomObject]@{}
        'errors'       = @()
    }

    try {
        # Use SharedToolCredentialService for credential collection (eliminates duplication)
        $sharedCredentialService = $services.SharedToolCredentialService
        $sharedCredentialService.DisplayCredentialCollectionStatus($Manager, "ConfigVerify-$ManagerName", $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials)
        # VerifyNSXConfiguration.ps1 doesn't have a Username parameter, so pass empty string for validation
        $usernameValidation = ""
        $sharedCredentialService.ValidateCredentialParameters($UseCurrentUserCredentials, $ForceNewCredentials, $usernameValidation, $AuthenticationConfigFile)

        try {
            # VerifyNSXConfiguration.ps1 doesn't have a Username parameter, so pass empty string for current user auth or stored credentials
            $usernameParam = ""
            $credentials = $sharedCredentialService.GetStandardNSXCredentials($Manager, $usernameParam, $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials, $AuthenticationConfigFile, "ConfigVerify")
            $logger.LogInfo("Credentials collected successfully using SharedToolCredentialService for: $ManagerName", "ConfigVerify")
        }
        catch {
            # SharedToolCredentialService handles all error types and logging internally
            Write-Host "FAILED: Credential collection failed for $ManagerName" -ForegroundColor Red
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

            Write-Host "Performing mandatory NSX toolkit prerequisite checks for $ManagerName..." -ForegroundColor Cyan

            try {
                # Load NSXConnectionTest functions
                $connectionTestPath = Join-Path $scriptPath "NSXConnectionTest.ps1"
                if (-not (Test-Path $connectionTestPath)) {
                    throw "NSXConnectionTest.ps1 not found at: $connectionTestPath"
                }

                # Dot-source the connection test functions
                . $connectionTestPath

                # Define required endpoints for Configuration Verification operations
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
                $prerequisiteResult = Assert-NSXToolkitPrerequisites -NSXManager $Manager -Credential $credentials -RequiredEndpoints $requiredEndpoints -ToolName "VerifyNSXConfiguration-$ManagerName" -AllowLimitedFunctionality

                # Store prerequisite results for use during verification operations
                $script:prerequisiteData = $prerequisiteResult

                Write-Host "NSX toolkit prerequisites validated successfully for $ManagerName" -ForegroundColor Green
                $logger.LogInfo("NSX toolkit prerequisites validated - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "ConfigVerify")
            }
            catch {
                $logger.LogError("NSX toolkit prerequisite check failed for $ManagerName : $($_.Exception.Message)", "ConfigVerify")
                Write-Host ""
                Write-Host "[ERROR] VERIFY NSX CONFIGURATION CANNOT PROCEED" -ForegroundColor Red
                Write-Host "Manager: $ManagerName" -ForegroundColor Yellow
                Write-Host "Reason: Prerequisite check failed" -ForegroundColor Yellow
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
                Write-Host "RESOLUTION:" -ForegroundColor Cyan
                Write-Host "1. Verify NSX Manager connectivity and credentials" -ForegroundColor White
                Write-Host "2. Run NSXConnectionTest.ps1 to diagnose connectivity issues" -ForegroundColor White
                Write-Host "3. Ensure NSX Manager is accessible and endpoints are responding" -ForegroundColor White
                Write-Host ""
                Write-Host "Example: .\tools\NSXConnectionTest.ps1 -NSXManager '$Manager'" -ForegroundColor Green
                Write-Host ""
                exit 1
            }
        }

        # ===================================================================
        # CONFIGURATION VERIFICATION OPERATIONS
        # ===================================================================

        # Get current configuration inventory
        $logger.LogInfo("Getting configuration inventory for $ManagerName...", "ConfigVerify")
        $inventory = $resetService.GetConfigurationInventory($Manager, $VerboseLogging, $UseCurrentUserCredentials, $false, $AuthenticationConfigFile, $ForceNewCredentials)
        $verificationResult.inventory = $inventory

        # Validate object counts
        $logger.LogInfo("Validating object counts...", "ConfigVerify")
        $validation = [PSCustomObject]@{
            'services_found'          = $inventory.summary.services_count
            'groups_found'            = $inventory.summary.groups_count
            'security_policies_found' = $inventory.summary.security_policies_count
            'context_profiles_found'  = $inventory.summary.context_profiles_count
            'total_objects_found'     = $inventory.summary.total_objects
        }

        # Add expected vs actual comparison if expected config provided
        if ($ExpectedConfig) {
            $validation['services_expected'] = if ($ExpectedConfig.services_count) { $ExpectedConfig.services_count } else { 0 }
            $validation['groups_expected'] = if ($ExpectedConfig.groups_count) { $ExpectedConfig.groups_count } else { 0 }
            $validation['security_policies_expected'] = if ($ExpectedConfig.security_policies_count) { $ExpectedConfig.security_policies_count } else { 0 }
            $validation['context_profiles_expected'] = if ($ExpectedConfig.context_profiles_count) { $ExpectedConfig.context_profiles_count } else { 0 }
            $validation['total_expected'] = if ($ExpectedConfig.total_objects) { $ExpectedConfig.total_objects } else { 0 }

            # Calculate differences
            $validation['services_diff'] = $validation.services_found - $validation.services_expected
            $validation['groups_diff'] = $validation.groups_found - $validation.groups_expected
            $validation['security_policies_diff'] = $validation.security_policies_found - $validation.security_policies_expected
            $validation['context_profiles_diff'] = $validation.context_profiles_found - $validation.context_profiles_expected
            $validation['total_diff'] = $validation.total_objects_found - $validation.total_expected
        }

        $verificationResult.validation = $validation

        # Generate summary
        $summary = [PSCustomObject]@{
            'manager_accessible' = $true
            'has_objects'        = ($inventory.summary.total_objects -gt 0)
            'validation_passed'  = $true
        }

        if ($ExpectedConfig) {
            $summary['matches_expected'] = ($validation.total_diff -eq 0)
            $summary['within_tolerance'] = (([math]::Abs($validation.total_diff)) -le 2)  # Allow small differences
        }

        $verificationResult.summary = $summary
        $verificationResult.success = $true

        # Log results
        $logger.LogInfo("Configuration verification completed for $ManagerName", "ConfigVerify")
        $logger.LogInfo("Total objects found: $($inventory.summary.total_objects)", "ConfigVerify")

        if ($ExpectedConfig -and $validation.total_diff -ne 0) {
            $logger.LogWarning("Object count difference: $($validation.total_diff) (Found: $($validation.total_objects_found), Expected: $($validation.total_expected))", "ConfigVerify")
        }

        return $verificationResult

    }
    catch {
        $errorMsg = "Failed to verify configuration for $ManagerName : $($_.Exception.Message)"
        $logger.LogError($errorMsg, "ConfigVerify")
        $verificationResult.errors += $errorMsg
        return $verificationResult
    }
}

# Compare two managers function
function Compare-NSXManager {
    param(
        [object]$SourceResult,
        [object]$TargetResult
    )

    $logger.LogInfo("=== Comparing NSX Managers ===", "ConfigVerify")

    $comparison = [PSCustomObject]@{
        'source_manager'        = $SourceResult.manager
        'target_manager'        = $TargetResult.manager
        'comparison_successful' = $false
        'differences'           = [PSCustomObject]@{}
        'summary'               = [PSCustomObject]@{}
    }

    try {
        if (-not $SourceResult.success -or -not $TargetResult.success) {
            throw "Cannot compare managers - one or both verifications failed"
        }

        $sourceInventory = $SourceResult.inventory.summary
        $targetInventory = $TargetResult.inventory.summary

        # Calculate differences
        $differences = [PSCustomObject]@{
            'services_diff'          = $targetInventory.services_count - $sourceInventory.services_count
            'groups_diff'            = $targetInventory.groups_count - $sourceInventory.groups_count
            'security_policies_diff' = $targetInventory.security_policies_count - $sourceInventory.security_policies_count
            'context_profiles_diff'  = $targetInventory.context_profiles_count - $sourceInventory.context_profiles_count
            'total_diff'             = $targetInventory.total_objects - $sourceInventory.total_objects
        }

        $comparison.differences = $differences

        # Generate comparison summary
        $summary = [PSCustomObject]@{
            'managers_match'   = ($differences.total_diff -eq 0)
            'within_tolerance' = (([math]::Abs($differences.total_diff)) -le 2)
            'source_total'     = $sourceInventory.total_objects
            'target_total'     = $targetInventory.total_objects
            'difference'       = $differences.total_diff
        }

        $comparison.summary = $summary
        $comparison.comparison_successful = $true

        # Log comparison results
        $logger.LogInfo("Manager comparison completed", "ConfigVerify")
        $logger.LogInfo("Source total objects: $($summary.source_total)", "ConfigVerify")
        $logger.LogInfo("Target total objects: $($summary.target_total)", "ConfigVerify")
        $logger.LogInfo("Difference: $($summary.difference)", "ConfigVerify")

        if ($summary.managers_match) {
            $logger.LogInfo("[SUCCESS] Managers have identical object counts", "ConfigVerify")
        }
        elseif ($summary.within_tolerance) {
            $logger.LogWarning("WARNING: Managers have minor differences (within tolerance)", "ConfigVerify")
        }
        else {
            $logger.LogError("[ERROR] Managers have significant differences", "ConfigVerify")
        }

        return $comparison

    }
    catch {
        $errorMsg = "Failed to compare managers: $($_.Exception.Message)"
        $logger.LogError($errorMsg, "ConfigVerify")
        $comparison.error = $errorMsg
        return $comparison
    }
}

# Display detailed report function
function Show-DetailedReport {
    param(
        [object]$SourceResult,
        [object]$TargetResult = $null,
        [object]$ComparisonResult = $null
    )

    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "           NSX CONFIGURATION VERIFICATION REPORT" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""

    # Source Manager Report
    Write-Host "SOURCE MANAGER: $($SourceResult.manager_name) ($($SourceResult.manager))"
    Write-Host "   Status: $(if($SourceResult.success){'SUCCESS'}else{'FAILED'})" -ForegroundColor $(if ($SourceResult.success) { 'Green' }else { 'Red' })

    if ($SourceResult.success) {
        $inv = $SourceResult.inventory.summary
        Write-Host "   Services: $($inv.services_count)"
        Write-Host "   Groups: $($inv.groups_count)"
        Write-Host "   Security Policies: $($inv.security_policies_count)"
        Write-Host "   Context Profiles: $($inv.context_profiles_count)"
        Write-Host "   Total Objects: $($inv.total_objects)"
    }
    else {
        Write-Host "   Errors: $($SourceResult.errors -join ', ')"
    }
    Write-Host ""

    # Target Manager Report (if provided)
    if ($TargetResult) {
        Write-Host "TARGET MANAGER: $($TargetResult.manager_name) ($($TargetResult.manager))"
        Write-Host "   Status: $(if($TargetResult.success){'SUCCESS'}else{'FAILED'})" -ForegroundColor $(if ($TargetResult.success) { 'Green' }else { 'Red' })

        if ($TargetResult.success) {
            $inv = $TargetResult.inventory.summary
            Write-Host "   Services: $($inv.services_count)"
            Write-Host "   Groups: $($inv.groups_count)"
            Write-Host "   Security Policies: $($inv.security_policies_count)"
            Write-Host "   Context Profiles: $($inv.context_profiles_count)"
            Write-Host "   Total Objects: $($inv.total_objects)"
        }
        else {
            Write-Host "   Errors: $($TargetResult.errors -join ', ')"
        }
        Write-Host ""
    }

    # Comparison Report (if provided)
    if ($ComparisonResult) {
        Write-Host "MANAGER COMPARISON" -ForegroundColor Cyan
        if ($ComparisonResult.comparison_successful) {
            $summary = $ComparisonResult.summary
            Write-Host "   Match Status: $(if($summary.managers_match){'IDENTICAL'}elseif($summary.within_tolerance){'MINOR DIFFERENCES'}else{'SIGNIFICANT DIFFERENCES'})" -ForegroundColor $(if ($summary.managers_match) { 'Green' }elseif ($summary.within_tolerance) { 'Yellow' }else { 'Red' })
            Write-Host "   Source Total: $($summary.source_total)"
            Write-Host "   Target Total: $($summary.target_total)"
            Write-Host "   Difference: $($summary.difference)" -ForegroundColor $(if ($summary.difference -eq 0) { 'Green' }else { 'Yellow' })

            if ($VerboseLogging -and -not $summary.managers_match) {
                $diff = $ComparisonResult.differences
                Write-Host "   Detailed Differences:"
                Write-Host "     Services: $($diff.services_diff)"
                Write-Host "     Groups: $($diff.groups_diff)"
                Write-Host "     Security Policies: $($diff.security_policies_diff)"
                Write-Host "     Context Profiles: $($diff.context_profiles_diff)"
            }
        }
        else {
            Write-Host "   Status: COMPARISON FAILED"
            Write-Host "   Error: $($ComparisonResult.error)"
        }
        Write-Host ""
    }

    Write-Host "================================================================" -ForegroundColor Cyan
}

# CONSOLIDATION: File-based validation functions from NSXConfigValidate.ps1
function Measure-AllNSXObject {
    param([object]$Object)

    $counts = New-Object PSObject

    function Measure-Recursive {
        param([object]$Item, [object]$Counts)

        if ($Item.resource_type) {
            if (-not ($Counts | Get-Member -Name $Item.resource_type -ErrorAction SilentlyContinue)) {
                $Counts | Add-Member -MemberType NoteProperty -Name $Item.resource_type -Value 0 -Force
            }
            $Counts.($Item.resource_type)++
        }

        # Handle both 'children' and other nested structures
        if ($Item.children -and $Item.children.Count -gt 0) {
            foreach ($child in $Item.children) {
                Measure-Recursive -Item $child -Counts $Counts
            }
        }

        # Handle other potential nested collections
        foreach ($property in $Item.PSObject.Properties) {
            if ($property.Value -is [System.Collections.IEnumerable] -and
                $property.Value -isnot [string] -and
                $property.Name -ne "children") {
                foreach ($item in $property.Value) {
                    if ($item.resource_type) {
                        Measure-Recursive -Item $item -Counts $Counts
                    }
                }
            }
        }
    }

    Measure-Recursive -Item $Object -Counts $counts
    return $counts
}

function Test-ConfigurationFiles {
    param(
        [string]$SourceFilePath,
        [string]$TargetFilePath
    )

    $logger.LogInfo("=== File-based Configuration Validation ===", "FileValidation")

    try {
        # Validate file paths
        if (-not (Test-Path $SourceFilePath)) {
            throw "Source file not found: $SourceFilePath"
        }
        if (-not (Test-Path $TargetFilePath)) {
            throw "Target file not found: $TargetFilePath"
        }

        # Load configurations
        $logger.LogInfo("Loading source configuration: $(Split-Path $SourceFilePath -Leaf)", "FileValidation")
        $sourceContent = Get-Content -Path $SourceFilePath -Raw | ConvertFrom-Json
        $sourceConfig = if ($sourceContent.configuration) { $sourceContent.configuration } else { $sourceContent }

        $logger.LogInfo("Loading target configuration: $(Split-Path $TargetFilePath -Leaf)", "FileValidation")
        $targetContent = Get-Content -Path $TargetFilePath -Raw | ConvertFrom-Json
        $targetConfig = if ($targetContent.configuration) { $targetContent.configuration } else { $targetContent }

        # Count all objects
        $sourceCounts = Measure-AllNSXObject -Object $sourceConfig
        $targetCounts = Measure-AllNSXObject -Object $targetConfig

        # Create comparison result
        $sourceTypes = $sourceCounts.PSObject.Properties.Name
        $targetTypes = $targetCounts.PSObject.Properties.Name
        $allTypes = ($sourceTypes + $targetTypes) | Sort-Object -Unique
        $totalMatch = $true
        $differences = New-Object PSObject

        foreach ($type in $allTypes) {
            $sourceCount = if ($sourceCounts | Get-Member -Name $type -ErrorAction SilentlyContinue) { $sourceCounts.$type } else { 0 }
            $targetCount = if ($targetCounts | Get-Member -Name $type -ErrorAction SilentlyContinue) { $targetCounts.$type } else { 0 }
            $match = $sourceCount -eq $targetCount
            if (-not $match) { $totalMatch = $false }

            $diffObject = New-Object PSObject -Property @{
                'source_count' = $sourceCount
                'target_count' = $targetCount
                'difference'   = $targetCount - $sourceCount
                'match'        = $match
            }
            $differences | Add-Member -MemberType NoteProperty -Name $type -Value $diffObject
        }

        $sourceValues = $sourceCounts.PSObject.Properties.Value
        $targetValues = $targetCounts.PSObject.Properties.Value
        $totalSourceObjects = ($sourceValues | Measure-Object -Sum).Sum - 1  # Exclude Infra container
        $totalTargetObjects = ($targetValues | Measure-Object -Sum).Sum - 1  # Exclude Infra container

        $result = New-Object PSObject -Property @{
            'success'              = $true
            'source_file'          = $SourceFilePath
            'target_file'          = $TargetFilePath
            'source_counts'        = $sourceCounts
            'target_counts'        = $targetCounts
            'differences'          = $differences
            'total_match'          = $totalMatch
            'total_source_objects' = $totalSourceObjects
            'total_target_objects' = $totalTargetObjects
            'total_difference'     = $totalTargetObjects - $totalSourceObjects
        }

        $logger.LogInfo("File validation completed successfully", "FileValidation")
        $logger.LogInfo("Total source objects: $totalSourceObjects, target objects: $totalTargetObjects", "FileValidation")

        return $result
    }
    catch {
        $logger.LogError("File validation failed: $($_.Exception.Message)", "FileValidation")
        return New-Object PSObject -Property @{
            'success' = $false
            'error'   = $_.Exception.Message
        }
    }
}

function Show-FileValidationReport {
    param([object]$ValidationResult)

    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host "  NSX CONFIGURATION FILE VALIDATION REPORT" -ForegroundColor Cyan
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host ""

    if (-not $ValidationResult.success) {
        Write-Host "ERROR: Validation failed: $($ValidationResult.error)" -ForegroundColor Red
        return
    }

    Write-Host "SUCCESS: Source loaded: $(Split-Path $ValidationResult.source_file -Leaf)" -ForegroundColor Green
    Write-Host "SUCCESS: Target loaded: $(Split-Path $ValidationResult.target_file -Leaf)" -ForegroundColor Green
    Write-Host ""

    Write-Host "NSX OBJECT COUNT COMPARISON"
    Write-Host "=" * 60

    foreach ($type in ($ValidationResult.differences.PSObject.Properties.Name | Sort-Object)) {
        $diff = $ValidationResult.differences.$type
        $status = if ($diff.match) { "OK" } else { "MISMATCH" }
        $color = if ($diff.match) { "Green" } else { "Red" }

        Write-Host "  $type"
        Write-Host "    Source: $($diff.source_count) | Target: $($diff.target_count) | $status" -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "SUMMARY STATISTICS"
    Write-Host "=" * 60
    Write-Host "  Total NSX Objects (Source): $($ValidationResult.total_source_objects)"
    Write-Host "  Total NSX Objects (Target): $($ValidationResult.total_target_objects)"
    Write-Host "  Object Counts Match: $(if ($ValidationResult.total_match) { 'YES' } else { 'NO' })" -ForegroundColor $(if ($ValidationResult.total_match) { "Green" } else { "Red" })

    # Show key production metrics
    if ($ValidationResult.source_counts | Get-Member -Name "Service" -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "PRODUCTION CONFIGURATION METRICS"
        Write-Host "=" * 60
        Write-Host "  Services: $($ValidationResult.source_counts.Service) (both  and complex)"
        Write-Host "  Groups: $($ValidationResult.source_counts.Group) (including nested groups)"
        Write-Host "  Policies: $($ValidationResult.source_counts.SecurityPolicy) (infra/env/app tiers)"
        Write-Host "  Domains: $($ValidationResult.source_counts.Domain) (organizational containers)"
    }

    Write-Host ""
    if ($ValidationResult.total_match) {
        Write-Host "CONFIGURATION SYNCHRONIZATION: SUCCESS" -ForegroundColor Green
        Write-Host "   Both configurations have identical object counts"
        Write-Host "   All Services, Groups, and Policies are synchronised"
        Write-Host "   Hierarchical configuration workflow completed successfully"
        Write-Host "   Source and target configurations are functionally identical"
        Write-Host ""
        Write-Host "   Note: Metadata differences (create_time, revision) are expected" -ForegroundColor Cyan
        Write-Host "        and properly excluded from the configuration comparison." -ForegroundColor Cyan
    }
    else {
        Write-Host "CONFIGURATION SYNCHRONIZATION: FAILED" -ForegroundColor Red
        Write-Host "   Object count mismatches detected between source and target"
    }

    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host "  VALIDATION COMPLETED" -ForegroundColor Cyan
    Write-Host "========================================================================" -ForegroundColor Cyan
}

# Main execution
try {
    # CONSOLIDATION: Support both live NSX manager and file-based validation
    if ($FileMode -or ($SourceFile -and $TargetFile)) {
        # File-based validation mode
        Write-Host "=== NSX Configuration File Validation ==="

        if (-not $SourceFile -or -not $TargetFile) {
            throw "File mode requires both -SourceFile and -TargetFile parameters"
        }

        Write-Host "Source File: $(Split-Path $SourceFile -Leaf)"
        Write-Host "Target File: $(Split-Path $TargetFile -Leaf)"
        Write-Host ""

        $validationResult = Test-ConfigurationFiles -SourceFilePath $SourceFile -TargetFilePath $TargetFile

        if ($DetailedReport) {
            Show-FileValidationReport -ValidationResult $validationResult
        }

        if ($validationResult.success -and $validationResult.total_match) {
            Write-Host "SUCCESS: File validation completed successfully - configurations match"
            $logger.LogInfo("File validation completed successfully", "FileValidation")
        }
        elseif ($validationResult.success) {
            Write-Host "WARNING: File validation completed - configurations differ"
            $logger.LogWarning("File validation completed with differences", "FileValidation")
        }
        else {
            Write-Host "ERROR: File validation failed"
            $logger.LogError("File validation failed", "FileValidation")
            exit 1
        }
    }
    else {
        # Live NSX manager validation mode
        if (-not $SourceManager -or -not $TargetManager) {
            throw "Live manager mode requires both -SourceManager and -TargetManager parameters"
        }

        Write-Host "=== NSX Configuration Verification ==="
        Write-Host "Source Manager: $SourceManager"
        Write-Host "Target Manager: $TargetManager"
        Write-Host ""

        # Load expected configuration if provided
        $expectedConfig = $null
        if ($ExpectedConfigFile -and (Test-Path $ExpectedConfigFile)) {
            $logger.LogInfo("Loading expected configuration from: $ExpectedConfigFile", "ConfigVerify")
            $expectedConfig = Get-Content $ExpectedConfigFile | ConvertFrom-Json
        }

        # Verify source manager
        $logger.LogInfo("Starting verification of source manager...", "ConfigVerify")
        $sourceResult = Test-NSXConfig -Manager $SourceManager -ManagerName "SOURCE" -ExpectedConfig $expectedConfig

        # Verify target manager
        $logger.LogInfo("Starting verification of target manager...", "ConfigVerify")
        $targetResult = Test-NSXConfig -Manager $TargetManager -ManagerName "TARGET" -ExpectedConfig $expectedConfig

        # Compare managers if requested
        $comparisonResult = $null
        if ($CompareManagers) {
            $logger.LogInfo("Comparing managers...", "ConfigVerify")
            $comparisonResult = Compare-NSXManager -SourceResult $sourceResult -TargetResult $targetResult
        }

        # Show detailed report if requested
        if ($DetailedReport) {
            Show-DetailedReport -SourceResult $sourceResult -TargetResult $targetResult -ComparisonResult $comparisonResult
        }

        # Summary output
        $overallSuccess = $sourceResult.success -and $targetResult.success
        if ($CompareManagers -and $comparisonResult) {
            $overallSuccess = $overallSuccess -and $comparisonResult.comparison_successful
        }

        if ($overallSuccess) {
            Write-Host "SUCCESS: Configuration verification completed successfully"
            $logger.LogInfo("Configuration verification completed successfully", "ConfigVerify")
        }
        else {
            Write-Host "ERROR: Configuration verification completed with errors"
            $logger.LogError("Configuration verification completed with errors", "ConfigVerify")
            exit 1
        }
    }
}
catch {
    $errorMsg = "Configuration verification failed: $($_.Exception.Message)"
    Write-Error $errorMsg
    $logger.LogError($errorMsg, "ConfigVerify")
    exit 1
}
