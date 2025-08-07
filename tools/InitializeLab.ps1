<#
.SYNOPSIS
    initialise the NSX PowerShell Toolkit for use with real NSX lab environment.

.DESCRIPTION
    This script sets up the NSX PowerShell Toolkit for use with the real NSX lab environment
    including credential setup, configuration validation, and connectivity testing.

.PARAMETER NSXManager1
    First NSX Manager hostname (default: lab-nsxlm-01.lab.vdcninja.com)

.PARAMETER NSXManager2
    Second NSX Manager hostname (default: lab-nsxlm-02.lab.vdcninja.com)

.PARAMETER SetupCredentials
    Setup and test credentials for both NSX managers

.PARAMETER ValidateOnly
    Only validate existing setup without making changes

.EXAMPLE
    .\initialiseLab.ps1
    initialise with default lab NSX managers

.EXAMPLE
    .\initialiseLab.ps1 -SetupCredentials
    Setup credentials and initialise

.EXAMPLE
    .\initialiseLab.ps1 -NSXManager1 "my-nsx-01.company.com" -NSXManager2 "my-nsx-02.company.com" -SetupCredentials
    initialise with custom NSX managers
#>

param(
    [string]$NSXManager1 = "lab-nsxlm-01.lab.vdcninja.com",
    [string]$NSXManager2 = "lab-nsxlm-02.lab.vdcninja.com",
    [switch]$SetupCredentials,
    [switch]$ValidateOnly
)

Write-Host "NSX PowerShell Toolkit Lab Initialization"
Write-Host "============================================="

# Get the toolkit root directory
$ToolkitRoot = Split-Path $PSScriptRoot -Parent
$ConfigRoot = Join-Path $ToolkitRoot "config"
$ServicesRoot = Join-Path $ToolkitRoot "src\services"

Write-Host "Toolkit Root: $ToolkitRoot" -ForegroundColor Cyan

# Step 1: Validate directory structure
Write-Host "`n[1] Validating directory structure..."

$RequiredDirs = @(
    "src\services",
    "src\interfaces",
    "src\models",
    "tools",
    "config",
    "tests",
    "docs",
    "logs"
)

foreach ($dir in $RequiredDirs) {
    $fullPath = Join-Path $ToolkitRoot $dir
    if (-not (Test-Path $fullPath)) {
        Write-Error "ERROR: Required directory missing: $dir"
    }
    else {
        Write-Host "SUCCESS: $dir"
    }
}

# Step 2: Load core services
Write-Host "`n[2] Loading core services..."

try {
    $bootstrapPath = Join-Path $ServicesRoot "InitServiceFramework.ps1"
    if (-not (Test-Path $bootstrapPath)) {
        throw "InitServiceFramework.ps1 not found at: $bootstrapPath"
    }

    . $bootstrapPath
    Initialize-ServiceFramework -ServicePath $ServicesRoot
    Write-Host "SUCCESS: Core services loaded successfully"
}
catch {
    Write-Error "ERROR: Failed to load core services: $($_.Exception.Message)"
}

# Step 3: Validate configuration files
Write-Host "`n[3] Validating configuration files..."

$ConfigFiles = @(
    "nsx-config.json",
    "nsx-automation-config.json",
    "group-membership-config.json"
)

foreach ($configFile in $ConfigFiles) {
    $configPath = Join-Path $ConfigRoot $configFile
    if (Test-Path $configPath) {
        try {
            $null = Get-Content $configPath | ConvertFrom-Json
            Write-Host "SUCCESS: $configFile - Valid JSON"
        }
        catch {
            Write-Host "ERROR: $configFile - Invalid JSON: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "WARNING: $configFile - Missing (this may be expected)"
    }
}

if ($ValidateOnly) {
    Write-Host "SUCCESS: Validation complete. Use -SetupCredentials to setup NSX manager access."
    return
}

# Step 4: Setup credentials if requested
if ($SetupCredentials) {
    Write-Host "`n[4] Setting up NSX manager credentials..."

    $credentialScript = Join-Path $ToolkitRoot "tools\NSXCredentialTest.ps1"
    if (-not (Test-Path $credentialScript)) {
        Write-Error "ERROR: NSXCredentialTest.ps1 not found"
    }

    # Setup credentials for first manager
    Write-Host "[KEY] Setting up credentials for $NSXManager1..." -ForegroundColor Cyan
    try {
        & $credentialScript -ManagerHostname $NSXManager1 -SetupCredentials
        Write-Host "SUCCESS: Credentials setup for $NSXManager1"
    }
    catch {
        Write-Host "ERROR: Failed to setup credentials for $NSXManager1`: $($_.Exception.Message)"
    }

    # Setup credentials for second manager
    Write-Host "[KEY] Setting up credentials for $NSXManager2..." -ForegroundColor Cyan
    try {
        & $credentialScript -ManagerHostname $NSXManager2 -SetupCredentials
        Write-Host "SUCCESS: Credentials setup for $NSXManager2"
    }
    catch {
        Write-Host "ERROR: Failed to setup credentials for $NSXManager2`: $($_.Exception.Message)"
    }
}

# Step 5: Test connectivity
Write-Host "`n[5] Testing NSX manager connectivity..."

$connectionScript = Join-Path $ToolkitRoot "tools\NSXCredentialTest.ps1"

# Test first manager
Write-Host "[CONN] Testing connection to $NSXManager1..." -ForegroundColor Cyan
try {
    & $connectionScript -ManagerHostname $NSXManager1 -TestConnection
    Write-Host "SUCCESS: Connection successful to $NSXManager1"
}
catch {
    Write-Host "ERROR: Connection failed to $NSXManager1`: $($_.Exception.Message)"
}

# Test second manager
Write-Host "[CONN] Testing connection to $NSXManager2..." -ForegroundColor Cyan
try {
    & $connectionScript -ManagerHostname $NSXManager2 -TestConnection
    Write-Host "SUCCESS: Connection successful to $NSXManager2"
}
catch {
    Write-Host "ERROR: Connection failed to $NSXManager2`: $($_.Exception.Message)"
}

# Step 6: Run quick validation
Write-Host "`n[6] Running environment validation..."

$validationScript = Join-Path $ToolkitRoot "tools\QuickValidation.ps1"
if (Test-Path $validationScript) {
    try {
        & $validationScript
        Write-Host "SUCCESS: Environment validation completed"
    }
    catch {
        Write-Host "ERROR: Validation failed: $($_.Exception.Message)"
    }
}
else {
    Write-Host "WARNING: QuickValidation.ps1 not found - skipping validation"
}

# Step 7: Summary and next steps
Write-Host "`n[COMPLETE] Lab Initialization Complete!"
Write-Host "================================"

Write-Host "`n[NEXT] Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run configuration sync:"
Write-Host "   .\tools\NSXConfigSyncTool.ps1 -SourceNSXManager '$NSXManager1' -TargetNSXManager '$NSXManager2' -CompareOnly"

Write-Host "`n2. Run configuration inventory:"
Write-Host "   .\tools\NSXCredentialTest.ps1 -ManagerHostname '$NSXManager1' -RunInventory"

Write-Host "`n3. Verify configuration:"
Write-Host "   .\tools\VerifyNSXConfig.ps1 -NSXManager '$NSXManager1'"

Write-Host "`n4. View available documentation in the docs/ folder"

Write-Host "`n[INFO] Configured NSX Managers:" -ForegroundColor Cyan
Write-Host "   - Primary: $NSXManager1"
Write-Host "   - Secondary: $NSXManager2"

# Use centralised credential management from CoreAuthenticationService
