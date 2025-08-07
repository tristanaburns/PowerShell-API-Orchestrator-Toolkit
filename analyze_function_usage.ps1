# Script to analyze function usage across the codebase to assess rename risk

$projectPath = "C:\github_development\projects\nsx-powershell-toolkit"

# List of functions with violations that need to be analyzed
$functionsToAnalyze = @(
    # High Risk - Public Tool Functions
    'Get-ManagerCredentials',
    'Get-SyncManagerCredentials', 
    'Add-StandardCredentialParams',
    'Get-ConsolidatedResourceTypes',
    'Merge-ConfigurationObjects',
    'Get-ExportResourceTypes',
    'Get-ImportResourceTypes',
    'Select-ConfigurationByResourceType',
    'Select-ConfigurationByDomain',
    'Test-StoredCredentials',
    'Repair-Credentials',
    'Start-ComprehensiveDiagnostics',
    'Get-NSXEndpointDefinition',
    'Get-ComprehensiveNSXEndpoint',
    'Save-ValidatedEndpointsForTools',
    'Assert-NSXToolkitPrerequisites',
    'Show-StoredCredentials',
    'Test-ConfigurationFiles',
    'Initialize-StandardServices',
    'Get-StandardCredentials',
    # Low Risk - Internal Utilities
    'Fix-WriteHost',
    'Fix-CmdletAliases',
    'Fix-UnusedVariables',
    'Fix-PlainTextPassword',
    'Fix-ConvertToSecureString',
    'Fix-UnapprovedVerbs',
    'Fix-PluralNouns',
    'Fix-MandatoryParameterDefaults'
)

Write-Host "`n=== FUNCTION USAGE ANALYSIS ===" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$usageReport = @()

foreach ($function in $functionsToAnalyze) {
    Write-Host "`nAnalyzing usage of: $function" -ForegroundColor Yellow
    
    # Search for function calls across all PowerShell files
    $pattern = "\b$function\b"
    $files = Get-ChildItem -Path $projectPath -Include "*.ps1", "*.psm1" -Recurse -ErrorAction SilentlyContinue
    
    $usageCount = 0
    $usageLocations = @()
    
    foreach ($file in $files) {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $matches = [regex]::Matches($content, $pattern)
            if ($matches.Count -gt 0) {
                # Don't count the function definition itself
                $definitionPattern = "function\s+$function"
                $definitions = [regex]::Matches($content, $definitionPattern)
                $actualUsage = $matches.Count - $definitions.Count
                
                if ($actualUsage -gt 0) {
                    $usageCount += $actualUsage
                    $relativePath = $file.FullName.Replace($projectPath + "\", "")
                    $usageLocations += "$relativePath ($actualUsage calls)"
                }
            }
        }
    }
    
    # Determine risk assessment based on usage
    $riskAssessment = if ($usageCount -eq 0) {
        "VERY LOW - No external usage found"
    } elseif ($usageCount -eq 1) {
        "LOW - Single usage found"
    } elseif ($usageCount -le 3) {
        "MEDIUM - Limited usage ($usageCount calls)"
    } else {
        "HIGH - Extensive usage ($usageCount calls)"
    }
    
    $usageItem = [PSCustomObject]@{
        FunctionName = $function
        TotalUsage = $usageCount
        RiskAssessment = $riskAssessment
        UsageLocations = ($usageLocations -join "; ")
    }
    
    $usageReport += $usageItem
    
    # Display summary
    Write-Host "  Total Usage: $usageCount" -ForegroundColor $(if ($usageCount -eq 0) { "Green" } elseif ($usageCount -le 3) { "Yellow" } else { "Red" })
    Write-Host "  Risk: $riskAssessment" -ForegroundColor $(if ($usageCount -eq 0) { "Green" } elseif ($usageCount -le 3) { "Yellow" } else { "Red" })
    if ($usageLocations.Count -gt 0) {
        Write-Host "  Locations:" -ForegroundColor Gray
        foreach ($location in $usageLocations) {
            Write-Host "    - $location" -ForegroundColor Gray
        }
    }
}

# Export detailed usage report
$usageReport | Export-Csv -Path (Join-Path $projectPath "Function_Usage_Analysis.csv") -NoTypeInformation

# Display summary by risk level
Write-Host "`n=== USAGE SUMMARY BY RISK LEVEL ===" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$veryLowRisk = $usageReport | Where-Object { $_.RiskAssessment -like "VERY LOW*" }
$lowRisk = $usageReport | Where-Object { $_.RiskAssessment -like "LOW*" }
$mediumRisk = $usageReport | Where-Object { $_.RiskAssessment -like "MEDIUM*" }
$highRisk = $usageReport | Where-Object { $_.RiskAssessment -like "HIGH*" }

Write-Host "`nVERY LOW RISK (Safe to rename immediately):" -ForegroundColor Green
$veryLowRisk | ForEach-Object { Write-Host "  - $($_.FunctionName)" -ForegroundColor Green }

Write-Host "`nLOW RISK (Minimal changes needed):" -ForegroundColor Yellow
$lowRisk | ForEach-Object { Write-Host "  - $($_.FunctionName) (Used in: $($_.UsageLocations))" -ForegroundColor Yellow }

Write-Host "`nMEDIUM RISK (Multiple updates required):" -ForegroundColor DarkYellow
$mediumRisk | ForEach-Object { Write-Host "  - $($_.FunctionName) ($($_.TotalUsage) calls)" -ForegroundColor DarkYellow }

Write-Host "`nHIGH RISK (Extensive refactoring needed):" -ForegroundColor Red
$highRisk | ForEach-Object { Write-Host "  - $($_.FunctionName) ($($_.TotalUsage) calls)" -ForegroundColor Red }

Write-Host "`n=== STATISTICS ===" -ForegroundColor Cyan
Write-Host "Total Functions Analyzed: $($usageReport.Count)"
Write-Host "Very Low Risk (0 usage): $($veryLowRisk.Count)"
Write-Host "Low Risk (1 usage): $($lowRisk.Count)"
Write-Host "Medium Risk (2-3 usage): $($mediumRisk.Count)"
Write-Host "High Risk (4+ usage): $($highRisk.Count)"

Write-Host "`nDetailed report saved to: Function_Usage_Analysis.csv" -ForegroundColor Green