#!/usr/bin/env pwsh

# Check PSUseSingularNouns violations after Phase 2 remediation
try {
    Import-Module PSScriptAnalyzer -Force
    Write-Host "Running PSScriptAnalyzer for PSUseSingularNouns violations..." -ForegroundColor Cyan
    
    $violations = Invoke-ScriptAnalyzer -Path . -Recurse | Where-Object { $_.RuleName -eq 'PSUseSingularNouns' }
    
    Write-Host "Total PSUseSingularNouns violations found: $($violations.Count)" -ForegroundColor Yellow
    
    if ($violations.Count -gt 0) {
        Write-Host "`nRemaining violations:" -ForegroundColor Red
        $violations | ForEach-Object { 
            $fileName = Split-Path $_.ScriptPath -Leaf
            Write-Host "  $fileName (Line $($_.Line)): $($_.Message)" -ForegroundColor Red
        }
        
        # Group by file for summary
        Write-Host "`nSummary by file:" -ForegroundColor Yellow
        $violations | Group-Object ScriptPath | Sort-Object Count -Descending | ForEach-Object {
            $fileName = Split-Path $_.Name -Leaf
            Write-Host "  $($_.Count) violations in $fileName" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No PSUseSingularNouns violations found! Phase 2 remediation successful." -ForegroundColor Green
    }
}
catch {
    Write-Host "Error running PSScriptAnalyzer: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}