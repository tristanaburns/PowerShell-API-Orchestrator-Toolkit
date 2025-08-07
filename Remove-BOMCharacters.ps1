# Remove-BOMCharacters.ps1
# Removes UTF-8 BOM (Byte Order Mark) characters from all PowerShell files

param(
    [string]$Path = ".",
    [switch]$WhatIf
)

$scriptPath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$targetPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $scriptPath $Path }

Write-Host "Scanning for PowerShell files with BOM characters..." -ForegroundColor Cyan
Write-Host "Target Path: $targetPath" -ForegroundColor Yellow

# Get all PowerShell files
$psFiles = Get-ChildItem -Path $targetPath -Filter "*.ps1" -Recurse -File
$psd1Files = Get-ChildItem -Path $targetPath -Filter "*.psd1" -Recurse -File
$allFiles = @($psFiles) + @($psd1Files)

$filesWithBOM = @()
$processedCount = 0

foreach ($file in $allFiles) {
    try {
        # Read first 3 bytes to check for UTF-8 BOM (EF BB BF)
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        
        if ($bytes.Length -ge 3 -and 
            $bytes[0] -eq 0xEF -and 
            $bytes[1] -eq 0xBB -and 
            $bytes[2] -eq 0xBF) {
            
            $filesWithBOM += $file
            Write-Host "[BOM FOUND] $($file.FullName)" -ForegroundColor Yellow
            
            if (-not $WhatIf) {
                # Remove BOM by writing all bytes except the first 3
                $newBytes = $bytes[3..($bytes.Length - 1)]
                [System.IO.File]::WriteAllBytes($file.FullName, $newBytes)
                Write-Host "  [FIXED] BOM removed from $($file.Name)" -ForegroundColor Green
                $processedCount++
            }
        }
    }
    catch {
        Write-Warning "Error processing $($file.FullName): $_"
    }
}

Write-Host ""
Write-Host "=== BOM REMOVAL SUMMARY ===" -ForegroundColor Green
Write-Host "Total files scanned: $($allFiles.Count)" -ForegroundColor White
Write-Host "Files with BOM found: $($filesWithBOM.Count)" -ForegroundColor $(if ($filesWithBOM.Count -gt 0) { "Yellow" } else { "Green" })

if ($WhatIf) {
    Write-Host ""
    Write-Host "[WhatIf Mode] No changes were made." -ForegroundColor Cyan
    Write-Host "Run without -WhatIf to remove BOM characters from these files:" -ForegroundColor Yellow
    foreach ($file in $filesWithBOM) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "Files processed: $processedCount" -ForegroundColor Green
    Write-Host "[SUCCESS] All BOM characters have been removed!" -ForegroundColor Green
}