# PowerShell Script to Analyze PSUseSingularNouns and PSUseApprovedVerbs violations

# Import PSScriptAnalyzer module
Import-Module PSScriptAnalyzer -ErrorAction Stop

$projectPath = "C:\github_development\projects\powershell-api-orchestrator-toolkit"
$settingsPath = Join-Path $projectPath "PSScriptAnalyzerSettings.psd1"

Write-Host "`n=== Analyzing PSUseSingularNouns Violations ===" -ForegroundColor Yellow
Write-Host "=" * 80

# Get PSUseSingularNouns violations
$singularNounViolations = Invoke-ScriptAnalyzer -Path $projectPath -Recurse -IncludeRule PSUseSingularNouns

$singularNounDetails = @()
foreach ($violation in $singularNounViolations) {
    # Extract function name from the script
    $scriptContent = Get-Content -Path $violation.ScriptPath -ErrorAction SilentlyContinue
    $functionName = ""
    
    # Find the function declaration at or near the violation line
    if ($scriptContent) {
        for ($i = [Math]::Max(0, $violation.Line - 5); $i -lt [Math]::Min($scriptContent.Count, $violation.Line + 5); $i++) {
            if ($scriptContent[$i] -match 'function\s+([\w-]+)') {
                $functionName = $Matches[1]
                break
            }
        }
    }
    
    $singularNounDetails += [PSCustomObject]@{
        File = $violation.ScriptPath.Replace($projectPath, ".")
        Line = $violation.Line
        FunctionName = $functionName
        CurrentName = if ($violation.Extent.Text -match 'function\s+([\w-]+)') { $Matches[1] } else { "" }
        Message = $violation.Message
        Severity = $violation.Severity
    }
}

Write-Host "`nPSUseSingularNouns Violations Summary:" -ForegroundColor Cyan
$singularNounDetails | Format-Table -AutoSize -Wrap
Write-Host "Total PSUseSingularNouns violations: $($singularNounViolations.Count)" -ForegroundColor Magenta

Write-Host "`n=== Analyzing PSUseApprovedVerbs Violations ===" -ForegroundColor Yellow
Write-Host "=" * 80

# Get PSUseApprovedVerbs violations
$verbViolations = Invoke-ScriptAnalyzer -Path $projectPath -Recurse -IncludeRule PSUseApprovedVerbs

$verbDetails = @()
foreach ($violation in $verbViolations) {
    # Extract function name from the script
    $scriptContent = Get-Content -Path $violation.ScriptPath -ErrorAction SilentlyContinue
    $functionName = ""
    
    # Find the function declaration at or near the violation line
    if ($scriptContent) {
        for ($i = [Math]::Max(0, $violation.Line - 5); $i -lt [Math]::Min($scriptContent.Count, $violation.Line + 5); $i++) {
            if ($scriptContent[$i] -match 'function\s+([\w-]+)') {
                $functionName = $Matches[1]
                break
            }
        }
    }
    
    # Extract suggested verb from message if available
    $suggestedVerb = ""
    if ($violation.Message -match 'use one of the following approved verbs: (.+)') {
        $suggestedVerb = $Matches[1]
    }
    
    $verbDetails += [PSCustomObject]@{
        File = $violation.ScriptPath.Replace($projectPath, ".")
        Line = $violation.Line
        FunctionName = $functionName
        CurrentVerb = if ($functionName -match '^(\w+)-') { $Matches[1] } else { "" }
        SuggestedVerbs = $suggestedVerb
        Message = $violation.Message
        Severity = $violation.Severity
    }
}

Write-Host "`nPSUseApprovedVerbs Violations Summary:" -ForegroundColor Cyan
$verbDetails | Format-Table -AutoSize -Wrap
Write-Host "Total PSUseApprovedVerbs violations: $($verbViolations.Count)" -ForegroundColor Magenta

# Export detailed results to CSV for further analysis
$singularNounDetails | Export-Csv -Path (Join-Path $projectPath "PSUseSingularNouns_violations.csv") -NoTypeInformation
$verbDetails | Export-Csv -Path (Join-Path $projectPath "PSUseApprovedVerbs_violations.csv") -NoTypeInformation

Write-Host "`nDetailed results exported to:" -ForegroundColor Green
Write-Host "  - PSUseSingularNouns_violations.csv" 
Write-Host "  - PSUseApprovedVerbs_violations.csv"