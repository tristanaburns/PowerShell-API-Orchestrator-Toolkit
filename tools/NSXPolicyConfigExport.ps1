<#
.SYNOPSIS
    NSX Policy Config Export - Export NSX-T policies and configurations with robust credential and automation support.

.DESCRIPTION
    Dedicated tool for exporting NSX-T policies and configurations from NSX managers using the enterprise-grade policy export service architecture. Supports both Local Manager and Global Manager (Federation) environments, advanced filtering, multiple export formats, and performance optimization.

.PARAMETER NSXManager
    Target NSX Manager FQDN or IP address (e.g., nsxmgr01.example.com)

.PARAMETER OutputDirectory
    Directory to save exported policies (default: .\data\exports)

.PARAMETER NSXDomain
    NSX domain to export (default: default). Ignored when -ExportAllDomains is used.

.PARAMETER ExportAllDomains
    Export configurations from all available domains (Global and Local). Automatically discovers and exports all domains.

.PARAMETER UseCurrentUserCredentials
    Use current Windows user credentials for authentication (requires AD integration)

.PARAMETER NonInteractive
    Run without interactive prompts (for automation)

.PARAMETER ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist

.PARAMETER SaveCredentials
    Save credentials for future use after successful authentication

.PARAMETER OutputStatistics
    Display detailed performance and operation statistics

.PARAMETER LogLevel
    Logging level. Valid values: Debug, Info, Warning, Error, Critical (default: Info)

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -OutputDirectory ".\data\exports"
    Export all policies from the specified NSX manager.

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -NSXDomain "default" -OutputStatistics
    Export policies for a specific domain with statistics.

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -UseCurrentUserCredentials
    Use current Windows user credentials for authentication.

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -NonInteractive
    Run in non-interactive mode (for automation/scheduled tasks).

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -ForceNewCredentials
    Force prompt for new credentials even if saved credentials exist.

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -ExportAllDomains
    Export configurations from all available domains (Global and Local).

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -ExportAllDomains -OutputStatistics
    Export all domains with detailed statistics and progress tracking.

.EXAMPLE
    .\NSXPolicyConfigExport.ps1 -NSXManager "nsxmgr01.example.com" -SaveCredentials
    Save credentials after successful authentication for future use.
#>

<#
IMPORTANT: This script is fully compliant with strict production requirements:
- All service class files (especially CoreSSLManager.ps1) are dot-sourced at the top-level script scope, before any logic or try/catch.
- No class loading occurs inside any function, try/catch, or script block.
- Fail-fast checks ensure all required classes are available after loading.
- CoreSSLManager is loaded and initialized before any other service or HTTPS operation.
- All services are loaded globally and via the factory.
- No mock/demo data, no code duplication, SOLID principles enforced.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$NSXManager,

    [Parameter(Mandatory = $false, HelpMessage = "Directory for output files (canonical: ./data/exports)")]
    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory = "./data/exports", # Default; actual path can be overridden later

    [Parameter(Mandatory = $false)]
    [string]$NSXDomain = "default",

    [Parameter(Mandatory = $false)]
    [switch]$ExportAllDomains,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeMetadata,

    [Parameter(Mandatory = $false)]
    [switch]$UseCurrentUserCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$ForceNewCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$SaveCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$OutputStatistics,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'Critical')]
    [string]$LogLevel = 'Info',

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
    $policyExportService = $services.PolicyExportService
    $workflowOpsService = $services.WorkflowOperationsService

    if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $authService -or $null -eq $apiService -or $null -eq $policyExportService) {
        throw "One or more services failed to initialize properly"
    }

    Write-Host "NSXPolicyConfigExport: Service framework initialized successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
    exit 1
}

# Main execution
try {
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "  NSX Policy Config Export" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host ""

    Write-Host "NSX Manager: $NSXManager"
    Write-Host "Output Directory: $OutputDirectory"

    # Determine export mode and display appropriate info
    if ($ExportAllDomains) {
        Write-Host "Export Mode: All Domains (Global and Local)" -ForegroundColor Cyan
        Write-Host "Domain Parameter: Ignored (auto-discovery enabled)" -ForegroundColor Gray
    }
    else {
        Write-Host "Export Mode: Single Domain" -ForegroundColor Cyan
        Write-Host "NSX Domain: $NSXDomain"
    }
    Write-Host ""

    # Validate parameter combinations
    if ($ExportAllDomains -and $PSBoundParameters['NSXDomain'] -and $NSXDomain -ne "default") {
        Write-Host "WARNING: -NSXDomain parameter ignored when -ExportAllDomains is specified" -ForegroundColor Yellow
        Write-Host ""
    }

    # Configure logging level
    $logger.SetLogLevel($LogLevel)
    $logger.LogInfo("NSX Policy Config Export started for: $NSXManager", "PolicyConfigExport")

    # Ensure output directory exists
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
        Write-Host "Created output directory: $OutputDirectory"
    }

    # Collect credentials using shared credential service (eliminates duplication)
    $sharedCredentialService = $services.SharedToolCredentialService
    $sharedCredentialService.DisplayCredentialCollectionStatus($NSXManager, "PolicyConfigExport", $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials)
    # NSXPolicyConfigExport.ps1 doesn't have a Username parameter, so pass empty string for validation
    $usernameValidation = ""
    $sharedCredentialService.ValidateCredentialParameters($UseCurrentUserCredentials, $ForceNewCredentials, $usernameValidation, $null)

    try {
        # NSXPolicyConfigExport.ps1 doesn't have a Username parameter, so pass empty string for current user auth or stored credentials
        $usernameParam = ""
        $credential = $sharedCredentialService.GetStandardNSXCredentials($NSXManager, $usernameParam, $UseCurrentUserCredentials, $ForceNewCredentials, $SaveCredentials, $null, "PolicyConfigExport")
        $logger.LogInfo("Credentials collected successfully using SharedToolCredentialService: $NSXManager", "PolicyConfigExport")
    }
    catch {
        $logger.LogError("Failed to collect credentials: $($_.Exception.Message)", "PolicyConfigExport")
        throw "Credential collection failed: $($_.Exception.Message)"
    }

    # ===================================================================
    # MANDATORY NSX TOOLKIT PREREQUISITE CHECK
    # ===================================================================
    Write-Host "Performing mandatory NSX toolkit prerequisite checks..." -ForegroundColor Cyan

    if ($ValidatedState.Success) {
        Write-Host "NSX toolkit prerequisites already validated" -ForegroundColor Green
        Write-Host "Validated State: $($ValidatedState.Success)" -ForegroundColor Green
        Write-Host "Validation Time: $($ValidatedState.Statistics.CacheTTL) hours" -ForegroundColor Green
        Write-Host "Valid Endpoints: $($ValidatedState.Statistics.ValidEndpoints)" -ForegroundColor Green
        Write-Host "Cache Valid: $($ValidatedState.Statistics.CacheValid)" -ForegroundColor Green
        Write-Host ""
    }
    else {
        try {
            # Load NSXConnectionTest functions
            $connectionTestPath = Join-Path $scriptPath "NSXConnectionTest.ps1"
            if (-not (Test-Path $connectionTestPath)) {
                throw "NSXConnectionTest.ps1 not found at: $connectionTestPath"
            }

            # Dot-source the connection test functions
            . $connectionTestPath

            # Define required endpoints for Policy Config Export operations
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
                ToolName                  = "NSXPolicyConfigExport"
                AllowLimitedFunctionality = $true
            }
            if ($ValidatedState) {
                $prerequisiteParams.ValidatedState = $ValidatedState
            }
            $prerequisiteResult = Assert-NSXToolkitPrerequisite @prerequisiteParams

            # Store prerequisite results for use during export operations
            $script:prerequisiteData = $prerequisiteResult

            Write-Host "NSX toolkit prerequisites validated successfully" -ForegroundColor Green
            $logger.LogInfo("NSX toolkit prerequisites validated - endpoint cache available with $($prerequisiteResult.Statistics.ValidEndpoints) valid endpoints", "PolicyConfigExport")
        }
        catch {
            $logger.LogError("NSX toolkit prerequisite check failed: $($_.Exception.Message)", "PolicyConfigExport")
            Write-Host ""
            Write-Host "[ERROR] NSX POLICY CONFIG EXPORT CANNOT PROCEED" -ForegroundColor Red
            Write-Host "Reason: Prerequisite check failed" -ForegroundColor Yellow
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "RESOLUTION:" -ForegroundColor Cyan
            Write-Host "1. Verify NSX Manager connectivity and credentials" -ForegroundColor White
            Write-Host "2. Run NSXConnectionTest.ps1 to diagnose connectivity issues" -ForegroundColor White
            Write-Host "3. Ensure NSX Manager is accessible and endpoints are responding" -ForegroundColor White
            Write-Host ""
            exit 1
        }
    }

    # ===================================================================
    # POLICY EXPORT OPERATIONS
    # ===================================================================

    Write-Host ""
    Write-Host "====================================================================="
    Write-Host "EXECUTING POLICY EXPORT" -ForegroundColor Cyan
    Write-Host "====================================================================="

    # Record start time for performance tracking
    $exportStartTime = Get-Date

    # Build export options
    $exportOptions = [PSCustomObject]@{
        include_metadata  = $IncludeMetadata.IsPresent
        log_level         = $LogLevel
        output_statistics = $OutputStatistics.IsPresent
    }

    if ($ExportAllDomains) {
        Write-Host "Starting Multi-Domain NSX Policy Export..."
        Write-Host "Manager: $NSXManager"
        Write-Host "Export Path: $OutputDirectory"
        Write-Host "Mode: Discover and export all available domains"
        Write-Host ""

        # Execute multi-domain export using the factory service
        Write-Host "Executing multi-domain policy export..."
        Write-Host "- Discovering available domains..."
        $exportResult = $policyExportService.ExportAllDomainConfigurations($NSXManager, $credential, $exportOptions)

        # result handling for multi-domain export
        if ($null -eq $exportResult -or -not $exportResult.success) {
            $errorMessage = if ($exportResult -and $exportResult.error) { $exportResult.error } else { "Unknown multi-domain export failure" }
            throw "Multi-domain policy export failed: $errorMessage"
        }

        Write-Host ""
        Write-Host "SUCCESS: Multi-domain policy export completed successfully!" -ForegroundColor Green
        Write-Host "   Total Domains Exported: $($exportResult.domains_exported)"
        Write-Host "   Successful Exports: $($exportResult.successful_exports)"
        Write-Host "   Failed Exports: $($exportResult.failed_exports)"
        Write-Host "   Total Objects Exported: $($exportResult.total_object_count)"

        if ($exportResult.domain_results) {
            Write-Host ""
            Write-Host "   Domain Export Summary:" -ForegroundColor Cyan
            foreach ($domain in $exportResult.domain_results.PSObject.Properties.Name) {
                $domainResult = $exportResult.domain_results.$domain
                $status = if ($domainResult.success) { "SUCCESS" } else { "FAILED" }
                $statusColor = if ($domainResult.success) { "Green" } else { "Red" }
                Write-Host "     $domain : $status ($($domainResult.object_count) objects)" -ForegroundColor $statusColor
            }
        }

        # Set variables for validation section
        $finalResult = $exportResult
        $exportType = "Multi-Domain"
    }
    else {
        Write-Host "Starting Single-Domain NSX Policy Export..."
        Write-Host "Manager: $NSXManager"
        Write-Host "Domain: $NSXDomain"
        Write-Host "Export Path: $OutputDirectory"
        Write-Host ""

        # Execute single domain export using the factory service
        Write-Host "Executing policy export..."
        $exportResult = $policyExportService.ExportPolicyConfiguration($NSXManager, $credential, $NSXDomain, $exportOptions)

        # Validate export result
        if ($null -eq $exportResult -or -not $exportResult.success) {
            $errorMessage = if ($exportResult -and $exportResult.error) { $exportResult.error } else { "Unknown export failure" }
            throw "Policy export failed: $errorMessage"
        }

        Write-Host ""
        Write-Host "SUCCESS: Policy export completed successfully!" -ForegroundColor Green
        Write-Host "   Manager Type: $($exportResult.manager_type)"
        Write-Host "   Domain: $($exportResult.domain)"
        Write-Host "   Objects Exported: $($exportResult.object_count)"

        # Set variables for validation section
        $finalResult = $exportResult
        $exportType = "Single-Domain"
    }

    # Record completion time
    $exportEndTime = Get-Date
    $exportDuration = $exportEndTime - $exportStartTime
    Write-Host "   Duration: $($exportDuration.ToString('mm\:ss\.fff'))"

    if ($exportResult.saved_files) {
        Write-Host "   Files Created:" -ForegroundColor Cyan
        if ($ExportAllDomains) {
            # For multi-domain export, show summary of all files
            $totalFiles = 0
            $totalSize = 0
            foreach ($domain in $exportResult.domain_results.PSObject.Properties.Name) {
                $domainResult = $exportResult.domain_results.$domain
                if ($domainResult.success -and $domainResult.saved_files) {
                    $totalFiles += ($domainResult.saved_files.PSObject.Properties.Name).Count
                    foreach ($fileType in $domainResult.saved_files.PSObject.Properties.Name) {
                        $filePath = $domainResult.saved_files.$fileType
                        if (Test-Path $filePath) {
                            $totalSize += (Get-Item $filePath).Length
                        }
                    }
                }
            }
            Write-Host "     Total Files: $totalFiles across $($exportResult.domains_exported) domains" -ForegroundColor Gray
            Write-Host "     Total Size: $([math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor Gray
        }
        else {
            # For single domain export, show individual files
            foreach ($fileType in $exportResult.saved_files.PSObject.Properties.Name) {
                $filePath = $exportResult.saved_files.$fileType
                $fileName = Split-Path $filePath -Leaf
                $fileSize = [math]::Round((Get-Item $filePath).Length / 1KB, 2)
                Write-Host "     $fileType : $fileName ($fileSize KB)" -ForegroundColor Gray
            }
        }
    }

    $logger.LogInfo("Policy export completed successfully in $($exportDuration.TotalSeconds) seconds", "PolicyConfigExport")

    # Export validation and verification
    Write-Host ""
    Write-Host "====================================================================="
    Write-Host "VALIDATING EXPORT INTEGRITY" -ForegroundColor Cyan
    Write-Host "====================================================================="

    Write-Host "Validating export integrity..."

    # Get the manager-specific export directory and verify files
    # Extract just the hostname part (before the first dot) to match service behavior
    $hostname = if ($NSXManager.Contains('.')) {
        $NSXManager.Split('.')[0]
    }
    else {
        $NSXManager
    }
    $managerExportDir = Join-Path $OutputDirectory ($hostname -replace '[^a-zA-Z0-9\-\.]', '_')

    if (Test-Path $managerExportDir) {
        if ($ExportAllDomains) {
            # Multi-domain validation
            $allExportFiles = Get-ChildItem -Path $managerExportDir -File -Recurse -ErrorAction SilentlyContinue
            $domainDirs = Get-ChildItem -Path $managerExportDir -Directory -ErrorAction SilentlyContinue

            if ($allExportFiles) {
                $totalExportSize = ($allExportFiles | Measure-Object -Property Length -Sum).Sum

                Write-Host "Multi-Domain Export Validation Results:"
                Write-Host "   Export Directory: $managerExportDir"
                Write-Host "   Domain Directories: $($domainDirs.Count)"
                Write-Host "   Total Files Created: $($allExportFiles.Count)"
                Write-Host "   Total Size: $([Math]::Round($totalExportSize / 1KB, 2)) KB"

                # Validate JSON format across all domains
                $jsonFiles = $allExportFiles | Where-Object { $_.Extension -eq '.json' }
                $validJsonCount = 0

                foreach ($jsonFile in $jsonFiles) {
                    try {
                        $content = Get-Content -Path $jsonFile.FullName -Raw
                        $null = ConvertFrom-Json -InputObject $content
                        $validJsonCount++
                    }
                    catch {
                        Write-Host "   WARNING: Invalid JSON file detected: $($jsonFile.Name)" -ForegroundColor Yellow
                    }
                }

                Write-Host "   Valid JSON Files: $validJsonCount of $($jsonFiles.Count)"

                # Show per-domain validation summary
                Write-Host ""
                Write-Host "   Per-Domain Validation:" -ForegroundColor Cyan
                foreach ($domainDir in $domainDirs) {
                    $domainFiles = Get-ChildItem -Path $domainDir.FullName -File -ErrorAction SilentlyContinue
                    $domainSize = ($domainFiles | Measure-Object -Property Length -Sum).Sum
                    Write-Host "     $($domainDir.Name): $($domainFiles.Count) files ($([Math]::Round($domainSize / 1KB, 2)) KB)" -ForegroundColor Gray
                }

                Write-Host "SUCCESS: Multi-domain export integrity validation completed" -ForegroundColor Green
            }
            else {
                Write-Host "WARNING: No export files found in manager directory" -ForegroundColor Yellow
            }
        }
        else {
            # Single domain validation (existing logic)
            $exportFiles = Get-ChildItem -Path $managerExportDir -File -ErrorAction SilentlyContinue

            if ($exportFiles) {
                $totalExportSize = ($exportFiles | Measure-Object -Property Length -Sum).Sum

                Write-Host "Export Validation Results:"
                Write-Host "   Export Directory: $managerExportDir"
                Write-Host "   Files Created: $($exportFiles.Count)"
                Write-Host "   Total Size: $([Math]::Round($totalExportSize / 1KB, 2)) KB"

                # Validate JSON format
                $jsonFiles = $exportFiles | Where-Object { $_.Extension -eq '.json' }
                $validJsonCount = 0

                foreach ($jsonFile in $jsonFiles) {
                    try {
                        $content = Get-Content -Path $jsonFile.FullName -Raw
                        $null = ConvertFrom-Json -InputObject $content
                        $validJsonCount++
                    }
                    catch {
                        Write-Host "   WARNING: Invalid JSON file detected: $($jsonFile.Name)" -ForegroundColor Yellow
                    }
                }

                Write-Host "   Valid JSON Files: $validJsonCount of $($jsonFiles.Count)"
                Write-Host "SUCCESS: Export integrity validation completed" -ForegroundColor Green
            }
            else {
                Write-Host "WARNING: No export files found in manager directory" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "WARNING: Manager export directory not found: $managerExportDir" -ForegroundColor Yellow
    }

    $logger.LogInfo("Export validation completed", "PolicyConfigExport")

    # Display statistics if requested
    if ($OutputStatistics) {
        Write-Host ""
        Write-Host "====================================================================="
        Write-Host "EXPORT STATISTICS AND PERFORMANCE METRICS" -ForegroundColor Cyan
        Write-Host "====================================================================="

        try {
            # Get export statistics from the service
            $exportStats = $policyExportService.GetExportStatistics()

            Write-Host "Export Summary:"
            Write-Host "   Total Exports: $($exportStats.total_exports)"
            Write-Host "   Managers: $(($exportStats.managers.PSObject.Properties.Name).Count)"
            Write-Host "   Domains: $(($exportStats.domains.PSObject.Properties.Name).Count)"

            Write-Host ""
            Write-Host "Manager Export Counts:"
            foreach ($manager in $exportStats.managers.PSObject.Properties.Name) {
                Write-Host "   $manager : $($exportStats.managers.$manager) exports"
            }

            Write-Host ""
            Write-Host "Domain Export Counts:"
            foreach ($domain in $exportStats.domains.PSObject.Properties.Name) {
                Write-Host "   $domain : $($exportStats.domains.$domain) exports"
            }

            # List recent exports
            Write-Host ""
            Write-Host "Recent Exports:"
            $recentExports = $policyExportService.ListExportedConfigurations($NSXManager) | Select-Object -First 5
            foreach ($export in $recentExports) {
                Write-Host "   $($export.timestamp) - $($export.nsx_manager) - $($export.nsx_domain) ($($export.size_kb) KB)"
            }

            # Show current session details
            Write-Host ""
            Write-Host "Current Session Details:"
            Write-Host "   Export Mode: $exportType"
            Write-Host "   Manager: $NSXManager"
            if ($ExportAllDomains) {
                Write-Host "   Domains Exported: $($finalResult.domains_exported)"
                Write-Host "   Total Objects: $($finalResult.total_object_count)"
                Write-Host "   Success Rate: $($finalResult.successful_exports)/$($finalResult.domains_exported)"
            }
            else {
                Write-Host "   Domain: $($finalResult.domain)"
                Write-Host "   Objects Exported: $($finalResult.object_count)"
                Write-Host "   Manager Type: $($finalResult.manager_type)"
            }
            Write-Host "   Duration: $($exportDuration.ToString('mm\:ss\.fff'))"

            $logger.LogInfo("Export statistics displayed", "PolicyConfigExport")

        }
        catch {
            Write-Host "WARNING: Could not retrieve export statistics: $($_.Exception.Message)" -ForegroundColor Yellow
            $logger.LogWarning("Failed to retrieve export statistics", "PolicyConfigExport")
        }
    }

    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "  EXPORT COMPLETED SUCCESSFULLY" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan

    Write-Host ""
    Write-Host "Export Summary:"
    Write-Host "   NSX Manager: $NSXManager"
    Write-Host "   Export Mode: $exportType"

    if ($ExportAllDomains) {
        Write-Host "   Domains Exported: $($finalResult.domains_exported)"
        Write-Host "   Successful Exports: $($finalResult.successful_exports)"
        Write-Host "   Failed Exports: $($finalResult.failed_exports)"
        Write-Host "   Total Objects Exported: $($finalResult.total_object_count)"
    }
    else {
        Write-Host "   Manager Type: $($finalResult.manager_type)"
        Write-Host "   Domain: $($finalResult.domain)"
        Write-Host "   Objects Exported: $($finalResult.object_count)"
    }

    Write-Host "   Export Directory: $managerExportDir"
    Write-Host "   Total Duration: $($exportDuration.ToString('mm\:ss\.fff'))"

    Write-Host ""
    Write-Host "Next Steps:"
    Write-Host "   - Review exported policies in: $managerExportDir"

    if ($ExportAllDomains) {
        Write-Host "   - Multi-domain export includes Global and Local domain configurations"
        Write-Host "   - Each domain has its own subdirectory with domain-specific exports"
        Write-Host "   - Review the multi-domain summary for analysis"
    }
    else {
        Write-Host "   - Single domain export focuses on $NSXDomain domain only"
        Write-Host "   - Use -ExportAllDomains to export all available domains"
    }

    Write-Host "   - Use exported data for documentation, analysis, or migration"
    Write-Host "   - Archive export files for compliance and audit purposes"
    Write-Host "   - JSON exports can be used for policy restoration or migration"

    if ($ExportAllDomains) {
        $logger.LogInfo("NSX Multi-Domain Policy Config Export execution completed successfully", "PolicyConfigExport")
    }
    else {
        $logger.LogInfo("NSX Policy Config Export execution completed successfully", "PolicyConfigExport")
    }

    # Return structured result for tool-to-tool integration
    return $finalResult
}
catch {
    $errorMsg = "Policy export operation failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "ERROR: $errorMsg" -ForegroundColor Red
    $logger.LogError($errorMsg, "PolicyConfigExport")

    # Provide troubleshooting suggestions
    Write-Host ""
    Write-Host "Troubleshooting Suggestions:" -ForegroundColor Yellow
    Write-Host "   - Verify NSX Manager connectivity and credentials"
    Write-Host "   - Check export path permissions and available disk space"
    Write-Host "   - Ensure NSX Manager is accessible and responsive"
    Write-Host "   - Enable debug logging with -LogLevel Debug for detailed information"

    exit 1
}
