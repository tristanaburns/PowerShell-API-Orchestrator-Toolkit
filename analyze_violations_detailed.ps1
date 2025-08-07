# Detailed PSScriptAnalyzer Analysis for PSUseSingularNouns and PSUseApprovedVerbs

Import-Module PSScriptAnalyzer -ErrorAction Stop

$projectPath = "C:\github_development\projects\powershell-api-orchestrator-toolkit"

# Function to extract function name from script content
function Get-FunctionNameFromLine {
    param(
        [string]$FilePath,
        [int]$Line
    )
    
    try {
        $content = Get-Content -Path $FilePath -ErrorAction Stop
        
        # Look for function declaration within 10 lines before and after
        for ($i = [Math]::Max(0, $Line - 10); $i -lt [Math]::Min($content.Count, $Line + 10); $i++) {
            if ($content[$i] -match 'function\s+([\w-]+)') {
                return $Matches[1]
            }
        }
        
        # If not found, check if the line itself has the function
        if ($content[$Line - 1] -match 'function\s+([\w-]+)') {
            return $Matches[1]
        }
    }
    catch {
        return ""
    }
    return ""
}

# Function to determine if a function is exported/public
function Get-FunctionScope {
    param(
        [string]$FilePath,
        [string]$FunctionName
    )
    
    # Check if it's in a public/exported module
    if ($FilePath -like "*\tools\*") {
        return "PUBLIC-TOOL"
    }
    elseif ($FilePath -like "*\services\*") {
        # Check if function is exported
        $content = Get-Content -Path $FilePath -Raw -ErrorAction SilentlyContinue
        if ($content -match "Export-ModuleMember.*$FunctionName") {
            return "PUBLIC-SERVICE"
        }
        return "INTERNAL-SERVICE"
    }
    elseif ($FilePath -like "*\utilities\*") {
        return "INTERNAL-UTILITY"
    }
    elseif ($FilePath -like "*\interfaces\*") {
        return "INTERFACE"
    }
    else {
        return "INTERNAL"
    }
}

Write-Host "`n=== DETAILED ANALYSIS: PSUseSingularNouns Violations ===" -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Gray

$singularViolations = Invoke-ScriptAnalyzer -Path $projectPath -Recurse -IncludeRule PSUseSingularNouns

$singularReport = @()
foreach ($violation in $singularViolations) {
    $functionName = Get-FunctionNameFromLine -FilePath $violation.ScriptPath -Line $violation.Line
    $scope = Get-FunctionScope -FilePath $violation.ScriptPath -FunctionName $functionName
    
    # Determine risk level
    $riskLevel = switch ($scope) {
        "PUBLIC-TOOL" { "HIGH" }
        "PUBLIC-SERVICE" { "HIGH" }
        "INTERNAL-SERVICE" { "MEDIUM" }
        "INTERNAL-UTILITY" { "LOW" }
        "INTERFACE" { "HIGH" }
        default { "LOW" }
    }
    
    # Extract the problematic noun
    $noun = ""
    if ($functionName -match '-(\w+)s$') {
        $noun = $Matches[1] + "s"
        $suggestedName = $functionName -replace 's$', ''
    }
    elseif ($functionName -match '-(\w+)ies$') {
        $noun = $Matches[1] + "ies"
        $suggestedName = $functionName -replace 'ies$', 'y'
    }
    else {
        $suggestedName = $functionName
    }
    
    $reportItem = [PSCustomObject]@{
        File = $violation.ScriptPath.Replace($projectPath + "\", "")
        Line = $violation.Line
        FunctionName = $functionName
        Scope = $scope
        RiskLevel = $riskLevel
        ProblematicNoun = $noun
        SuggestedName = $suggestedName
        Message = $violation.Message
    }
    
    $singularReport += $reportItem
}

# Display summary grouped by risk
Write-Host "`nHIGH RISK (Public API Functions):" -ForegroundColor Red
$singularReport | Where-Object RiskLevel -eq "HIGH" | Format-Table File, FunctionName, SuggestedName -AutoSize

Write-Host "`nMEDIUM RISK (Internal Service Functions):" -ForegroundColor Yellow
$singularReport | Where-Object RiskLevel -eq "MEDIUM" | Format-Table File, FunctionName, SuggestedName -AutoSize

Write-Host "`nLOW RISK (Internal Utilities):" -ForegroundColor Green
$singularReport | Where-Object RiskLevel -eq "LOW" | Format-Table File, FunctionName, SuggestedName -AutoSize

# Export detailed report
$singularReport | Export-Csv -Path (Join-Path $projectPath "PSUseSingularNouns_detailed.csv") -NoTypeInformation

Write-Host "`n=== DETAILED ANALYSIS: PSUseApprovedVerbs Violations ===" -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Gray

$verbViolations = Invoke-ScriptAnalyzer -Path $projectPath -Recurse -IncludeRule PSUseApprovedVerbs

$verbReport = @()
foreach ($violation in $verbViolations) {
    $functionName = Get-FunctionNameFromLine -FilePath $violation.ScriptPath -Line $violation.Line
    $scope = Get-FunctionScope -FilePath $violation.ScriptPath -FunctionName $functionName
    
    # Determine risk level
    $riskLevel = switch ($scope) {
        "PUBLIC-TOOL" { "HIGH" }
        "PUBLIC-SERVICE" { "HIGH" }
        "INTERNAL-SERVICE" { "MEDIUM" }
        "INTERNAL-UTILITY" { "LOW" }
        "INTERFACE" { "HIGH" }
        default { "LOW" }
    }
    
    # Extract current verb and suggested replacement
    $currentVerb = if ($functionName -match '^(\w+)-') { $Matches[1] } else { "" }
    
    # Map common unapproved verbs to approved ones
    $verbMapping = @{
        "Fix" = "Repair"
        "Repair" = "Repair"
        "Validate" = "Test"
        "Merge" = "Join"
        "Filter" = "Select"
        "Apply" = "Set"
        "Create" = "New"
        "Delete" = "Remove"
        "Cleanup" = "Clear"
        "Load" = "Import"
        "Fetch" = "Get"
    }
    
    $suggestedVerb = if ($verbMapping.ContainsKey($currentVerb)) { $verbMapping[$currentVerb] } else { "Get" }
    $suggestedName = if ($functionName -match '^(\w+)-(.+)') { "$suggestedVerb-$($Matches[2])" } else { $functionName }
    
    $reportItem = [PSCustomObject]@{
        File = $violation.ScriptPath.Replace($projectPath + "\", "")
        Line = $violation.Line
        FunctionName = $functionName
        Scope = $scope
        RiskLevel = $riskLevel
        CurrentVerb = $currentVerb
        SuggestedVerb = $suggestedVerb
        SuggestedName = $suggestedName
        Message = $violation.Message
    }
    
    $verbReport += $reportItem
}

# Display summary grouped by risk
Write-Host "`nHIGH RISK (Public API Functions):" -ForegroundColor Red
$verbReport | Where-Object RiskLevel -eq "HIGH" | Format-Table File, FunctionName, SuggestedName -AutoSize

Write-Host "`nMEDIUM RISK (Internal Service Functions):" -ForegroundColor Yellow
$verbReport | Where-Object RiskLevel -eq "MEDIUM" | Format-Table File, FunctionName, SuggestedName -AutoSize

Write-Host "`nLOW RISK (Internal Utilities):" -ForegroundColor Green
$verbReport | Where-Object RiskLevel -eq "LOW" | Format-Table File, FunctionName, SuggestedName -AutoSize

# Export detailed report
$verbReport | Export-Csv -Path (Join-Path $projectPath "PSUseApprovedVerbs_detailed.csv") -NoTypeInformation

# Summary statistics
Write-Host "`n=== SUMMARY STATISTICS ===" -ForegroundColor Cyan
Write-Host "PSUseSingularNouns Violations: $($singularReport.Count)" -ForegroundColor Yellow
Write-Host "  - HIGH Risk: $(($singularReport | Where-Object RiskLevel -eq 'HIGH').Count)"
Write-Host "  - MEDIUM Risk: $(($singularReport | Where-Object RiskLevel -eq 'MEDIUM').Count)"
Write-Host "  - LOW Risk: $(($singularReport | Where-Object RiskLevel -eq 'LOW').Count)"

Write-Host "`nPSUseApprovedVerbs Violations: $($verbReport.Count)" -ForegroundColor Yellow
Write-Host "  - HIGH Risk: $(($verbReport | Where-Object RiskLevel -eq 'HIGH').Count)"
Write-Host "  - MEDIUM Risk: $(($verbReport | Where-Object RiskLevel -eq 'MEDIUM').Count)"
Write-Host "  - LOW Risk: $(($verbReport | Where-Object RiskLevel -eq 'LOW').Count)"

Write-Host "`nDetailed reports saved to:" -ForegroundColor Green
Write-Host "  - PSUseSingularNouns_detailed.csv"
Write-Host "  - PSUseApprovedVerbs_detailed.csv"