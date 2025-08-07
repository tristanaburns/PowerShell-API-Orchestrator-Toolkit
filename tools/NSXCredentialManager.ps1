# NSXCredentialManager.ps1
# NSX credential management tool
# Provides complete credential lifecycle management: CREATE, READ, UPDATE, DELETE

<#
.SYNOPSIS
    NSX Manager Credential CRUD Operations

.DESCRIPTION
    Complete CRUD operations for NSX-T manager credentials:
    CREATE: Setup new credentials
    READ: List and view stored credentials
    UPDATE: Modify existing credentials
    DELETE: Remove credentials

.PARAMETER NSXManager
    NSX manager hostname or IP address

.PARAMETER Username
    Username for NSX manager authentication

.PARAMETER Password
    Password (will be prompted securely if not provided)

.PARAMETER Setup
    CREATE new credentials for an NSX manager

.PARAMETER TestConnection
    Test connection to NSX manager

.PARAMETER ListCredentials
    READ all stored credential files

.PARAMETER UpdateCredentials
    UPDATE existing credentials for an NSX manager

.PARAMETER ClearSpecific
    DELETE credentials for specific NSX manager

.PARAMETER ClearAll
    DELETE all stored credentials

.PARAMETER ShowInfo
    Show credential storage information

.PARAMETER Help
    Show help information

.EXAMPLE
    # CREATE new credentials
    .\NSXCredentialManager.ps1 -Setup -NSXManager lab-nsxlm-01.lab.vdcninja.com

.EXAMPLE
    # READ stored credentials
    .\NSXCredentialManager.ps1 -ListCredentials

.EXAMPLE
    # UPDATE existing credentials
    .\NSXCredentialManager.ps1 -UpdateCredentials -NSXManager lab-nsxlm-01.lab.vdcninja.com

.EXAMPLE
    # DELETE specific credentials
    .\NSXCredentialManager.ps1 -ClearSpecific lab-nsxlm-01.lab.vdcninja.com

.EXAMPLE
    # Interactive mode (shows all options)
    .\NSXCredentialManager.ps1
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$NSXManager,

    [Parameter(Mandatory = $false)]
    [string]$Username,

    [Parameter(Mandatory = $false)]
    [securestring]$Password,

    [Parameter(Mandatory = $false)]
    [switch]$Setup,

    [Parameter(Mandatory = $false)]
    [switch]$TestConnection,

    [Parameter(Mandatory = $false)]
    [switch]$ListCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$UpdateCredentials,

    [Parameter(Mandatory = $false)]
    [string]$ClearSpecific,

    [Parameter(Mandatory = $false)]
    [switch]$ClearAll,

    [Parameter(Mandatory = $false)]
    [switch]$ShowInfo,

    [Parameter(Mandatory = $false)]
    [switch]$Help
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

    # Load all services (including WorkflowOperationsService) via the centralized service framework
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
    $workflowOpsService = $services.WorkflowOperationsService

    if ($null -eq $logger -or $null -eq $credentialService -or $null -eq $authService -or $null -eq $apiService) {
        throw "One or more services failed to initialize properly"
    }

    Write-Host "NSXCredentialManager: Service framework initialized successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
    exit 1
}

function Show-CRUDHelp {
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "NSX CREDENTIAL MANAGER - CRUD OPERATIONS" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "CRUD OPERATIONS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "CREATE (Setup New Credentials):" -ForegroundColor Green
    Write-Host "  .\NSXCredentialManager.ps1 -Setup -NSXManager lab-nsxlm-01.lab.vdcninja.com"
    Write-Host "  .\NSXCredentialManager.ps1 -Setup  # Interactive mode"
    Write-Host ""
    Write-Host "READ (List Stored Credentials):" -ForegroundColor Green
    Write-Host "  .\NSXCredentialManager.ps1 -ListCredentials"
    Write-Host "  .\NSXCredentialManager.ps1 -ShowInfo  # Detailed info"
    Write-Host ""
    Write-Host "UPDATE (Modify Existing Credentials):" -ForegroundColor Green
    Write-Host "  .\NSXCredentialManager.ps1 -UpdateCredentials -NSXManager lab-nsxlm-01.lab.vdcninja.com"
    Write-Host "  .\NSXCredentialManager.ps1 -UpdateCredentials  # Interactive mode"
    Write-Host ""
    Write-Host "DELETE (Remove Credentials):" -ForegroundColor Green
    Write-Host "  .\NSXCredentialManager.ps1 -ClearSpecific lab-nsxlm-01.lab.vdcninja.com"
    Write-Host "  .\NSXCredentialManager.ps1 -ClearAll  # Remove all (with confirmation)"
    Write-Host ""
    Write-Host "TEST (Verify Credentials):" -ForegroundColor Green
    Write-Host "  .\NSXCredentialManager.ps1 -TestConnection -NSXManager lab-nsxlm-01.lab.vdcninja.com"
    Write-Host ""
    Write-Host "INTERACTIVE MODE:" -ForegroundColor Yellow
    Write-Host "  .\NSXCredentialManager.ps1  # Shows menu with all options"
    Write-Host ""
}

function Get-CredentialInput {
    param([string]$Manager)

    Write-Host "=== CREDENTIAL INPUT ===" -ForegroundColor Yellow
    Write-Host "NSX Manager: $Manager" -ForegroundColor White
    Write-Host ""

    $Username = Read-Host "Enter username for $Manager"
    if ([string]::IsNullOrWhiteSpace($Username)) {
        throw "Username cannot be empty"
    }

    $Password = Read-Host "Enter password for $Username@$Manager" -AsSecureString
    if ($Password.Length -eq 0) {
        throw "Password cannot be empty"
    }

    return New-Object System.Management.Automation.PSCredential($Username, $Password)
}

# New compliant function name (singular)
function Show-StoredCredential {
    Write-Host "=== STORED CREDENTIALS (READ) ===" -ForegroundColor Yellow
    Write-Host ""
    try {
        $credentials = $credentialService.ListStoredCredentials()
        if (-not $credentials -or ($credentials -isnot [System.Collections.IEnumerable]) -or ($credentials.Count -eq 0)) {
            Write-Host "No stored credentials found." -ForegroundColor Gray
            Write-Host ""
            Write-Host "To CREATE credentials, run:" -ForegroundColor Cyan
            Write-Host "  .\NSXCredentialManager.ps1 -Setup -NSXManager <hostname>" -ForegroundColor White
        }
        else {
            # HASH TABLE ERADICATION: Convert to PSCustomObject approach without hash table syntax
            $formattedCredentials = $credentials | ForEach-Object {
                [PSCustomObject]@{
                    NSXManager = $_.NSXManager
                    Username   = $_.Username
                    Modified   = $_.Modified.ToString("yyyy-MM-dd HH:mm")
                }
            }
            $formattedCredentials | Format-Table -AutoSize
            Write-Host "Total: $($credentials.Count) credential file(s)" -ForegroundColor Green
        }
    }
    catch {
        $errorMessage = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { $_.ToString() }
        Write-Host "Error reading credentials: $errorMessage" -ForegroundColor Red
    }
    Write-Host ""
}

# Backward compatible alias
Set-Alias -Name Show-StoredCredentials -Value Show-StoredCredential

function Invoke-CredentialCreate {
    param([string]$Manager)

    Write-Host "=== CREATE NEW CREDENTIALS ===" -ForegroundColor Green
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($Manager)) {
        $Manager = Read-Host "Enter NSX Manager hostname or IP address"
        if ([string]::IsNullOrWhiteSpace($Manager)) {
            throw "NSX Manager hostname cannot be empty"
        }
    }

    # Check if credentials already exist
    if ($credentialService.HasCredentials($Manager)) {
        Write-Host "Credentials already exist for $Manager" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to UPDATE them instead? (y/n)"
        if ($choice -match '^[Yy]') {
            return Invoke-CredentialUpdate -Manager $Manager
        }
        else {
            Write-Host "Operation cancelled." -ForegroundColor Gray
            return $false
        }
    }

    try {
        $credential = Get-CredentialInput -Manager $Manager

        $saveSuccess = $credentialService.SaveCredentials($Manager, $credential)
        if ($saveSuccess) {
            Write-Host " Credentials CREATED successfully for $Manager" -ForegroundColor Green
            $logger.LogInfo("Credentials created for $Manager", "CredentialManager")
            return $true
        }
        else {
            Write-Host " Failed to CREATE credentials for $Manager" -ForegroundColor Red
            return $false
        }
    }
    catch {
        $errorMessage = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { $_.ToString() }
        Write-Host " Error creating credentials: $errorMessage" -ForegroundColor Red
        return $false
    }
}

function Invoke-CredentialUpdate {
    param([string]$Manager)

    Write-Host "=== UPDATE EXISTING CREDENTIALS ===" -ForegroundColor Blue
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($Manager)) {
        $credentials = $credentialService.ListStoredCredentials()
        if ($credentials.Count -eq 0) {
            Write-Host "No credentials found to update." -ForegroundColor Gray
            Write-Host "Use -Setup to CREATE new credentials." -ForegroundColor Cyan
            return $false
        }

        Write-Host "Available credentials:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $credentials.Count; $i++) {
            Write-Host "  $($i + 1). $($credentials[$i].NSXManager)" -ForegroundColor White
        }

        $choice = Read-Host "Select credential to update (1-$($credentials.Count)) or enter hostname"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $credentials.Count) {
            $Manager = $credentials[[int]$choice - 1].NSXManager
        }
        else {
            $Manager = $choice
        }
    }

    if (-not $credentialService.HasCredentials($Manager)) {
        Write-Host "No stored credentials found for: $Manager" -ForegroundColor Yellow
        Write-Host "Use -Setup to CREATE new credentials." -ForegroundColor Cyan
        return $false
    }

    try {
        Write-Host "Updating credentials for: $Manager" -ForegroundColor White
        $credential = Get-CredentialInput -Manager $Manager

        $saveSuccess = $credentialService.SaveCredentials($Manager, $credential)
        if ($saveSuccess) {
            Write-Host " Credentials UPDATED successfully for $Manager" -ForegroundColor Green
            $logger.LogInfo("Credentials updated for $Manager", "CredentialManager")
            return $true
        }
        else {
            Write-Host " Failed to UPDATE credentials for $Manager" -ForegroundColor Red
            return $false
        }
    }
    catch {
        $errorMessage = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { $_.ToString() }
        Write-Host "Error updating credentials: $errorMessage" -ForegroundColor Red
        return $false
    }
}

function Invoke-CredentialDelete {
    param([string]$Manager)

    Write-Host "=== DELETE CREDENTIALS ===" -ForegroundColor Red
    Write-Host ""

    if (-not $credentialService.HasCredentials($Manager)) {
        Write-Host "No stored credentials found for: $Manager" -ForegroundColor Yellow
        return $false
    }

    Write-Host "WARNING: This will permanently DELETE credentials for: $Manager" -ForegroundColor Red
    $confirm = Read-Host "Are you sure? Type 'DELETE' to confirm"

    if ($confirm -eq "DELETE") {
        if ($credentialService.ClearCredentials($Manager)) {
            Write-Host " Credentials DELETED successfully for: $Manager" -ForegroundColor Green
            $logger.LogInfo("Credentials deleted for $Manager", "CredentialManager")
            return $true
        }
        else {
            Write-Host " Failed to DELETE credentials for: $Manager" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "Delete operation cancelled." -ForegroundColor Gray
        return $false
    }
}

function Test-NSXConnection {
    param([string]$Manager)

    Write-Host "=== TEST CONNECTION ===" -ForegroundColor Cyan
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($Manager)) {
        $Manager = Read-Host "Enter NSX Manager hostname or IP address"
        if ([string]::IsNullOrWhiteSpace($Manager)) {
            throw "NSX Manager hostname cannot be empty"
        }
    }

    try {
        $credential = $null
        if ($credentialService.HasCredentials($Manager)) {
            $credential = $credentialService.LoadCredentials($Manager)
            Write-Host "Using stored credentials for $Manager" -ForegroundColor Green
        }
        else {
            Write-Host "No stored credentials found for $Manager" -ForegroundColor Yellow
            $credential = Get-CredentialInput -Manager $Manager
        }

        Write-Host "Testing connection to $Manager..." -ForegroundColor White
        $connectionResult = $authService.TestConnection($Manager, $credential, $true)

        if ($connectionResult.success) {
            Write-Host " Connection successful!" -ForegroundColor Green
            Write-Host "  Response time: $($connectionResult.responseTime)ms" -ForegroundColor Gray
            if ($connectionResult.managerInfo) {
                Write-Host "  NSX Version: $($connectionResult.managerInfo.version)" -ForegroundColor Gray
            }
            return $true
        }
        else {
            Write-Host " Connection failed!" -ForegroundColor Red
            Write-Host "  Error: $($connectionResult.message)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        $errorMessage = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { $_.ToString() }
        Write-Host " Connection test failed!" -ForegroundColor Red
        Write-Host "  Exception: $errorMessage" -ForegroundColor Red
        return $false
    }
}

function Start-InteractiveMode {
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "NSX CREDENTIAL MANAGER - INTERACTIVE MODE" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan

    do {
        Write-Host ""
        Show-StoredCredential

        Write-Host "=== CRUD OPERATIONS MENU ===" -ForegroundColor Yellow
        Write-Host "1. CREATE new credentials" -ForegroundColor Green
        Write-Host "2. READ stored credentials" -ForegroundColor Green
        Write-Host "3. UPDATE existing credentials" -ForegroundColor Green
        Write-Host "4. DELETE specific credentials" -ForegroundColor Green
        Write-Host "5. DELETE all credentials" -ForegroundColor Red
        Write-Host "6. TEST connection" -ForegroundColor Cyan
        Write-Host "7. Show storage info" -ForegroundColor White
        Write-Host "8. Help" -ForegroundColor White
        Write-Host "0. Exit" -ForegroundColor Gray
        Write-Host ""

        $choice = Read-Host "Select operation (0-8)"

        switch ($choice) {
            "1" {
                $manager = Read-Host "Enter NSX Manager hostname"
                if (-not [string]::IsNullOrWhiteSpace($manager)) {
                    Invoke-CredentialCreate -Manager $manager
                }
            }
            "2" {
                Show-StoredCredential
            }
            "3" {
                if (Get-Command Invoke-CredentialUpdate -ErrorAction SilentlyContinue) {
                    Invoke-CredentialUpdate -Manager ""
                }
                else {
                    Write-Host "Update function not found." -ForegroundColor Red
                }
            }
            "4" {
                $manager = Read-Host "Enter NSX Manager hostname to delete"
                if (-not [string]::IsNullOrWhiteSpace($manager)) {
                    Invoke-CredentialDelete -Manager $manager
                }
            }
            "5" {
                $credentials = $credentialService.ListStoredCredentials()
                $credCount = if ($credentials -and ($credentials -is [System.Collections.IEnumerable])) { $credentials.Count } else { 0 }
                if ($credCount -gt 0) {
                    Write-Host "WARNING: Delete ALL $credCount credential(s)!" -ForegroundColor Red
                    $confirm = Read-Host "Type 'DELETE ALL' to confirm"
                    if ($confirm -eq "DELETE ALL") {
                        $credentialService.ClearAllCredentials()
                        Write-Host "All credentials deleted." -ForegroundColor Green
                    }
                }
                else {
                    Write-Host "No credentials to delete." -ForegroundColor Gray
                }
            }
            "6" {
                $manager = Read-Host "Enter NSX Manager hostname to test"
                if (-not [string]::IsNullOrWhiteSpace($manager)) {
                    Test-NSXConnection -Manager $manager
                }
            }
            "7" {
                $credentialService.ShowCredentialStorageInfo()
            }
            "8" {
                Show-CRUDHelp
            }
            "0" {
                Write-Host "Exiting..." -ForegroundColor Gray
                return
            }
            default {
                Write-Host "Invalid option. Please select 0-8." -ForegroundColor Red
            }
        }

        if ($choice -ne "0") {
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($true)
}

# Main execution logic
try {
    if ($Help) {
        Show-CRUDHelp
        exit 0
    }

    if ($ListCredentials) {
        Show-StoredCredential
        exit 0
    }

    if ($ShowInfo) {
        $credentialService.ShowCredentialStorageInfo()
        exit 0
    }

    if ($Setup) {
        $success = Invoke-CredentialCreate -Manager $NSXManager
        if ($success) {
            exit 0
        }
        else {
            exit 1
        }
    }

    if ($UpdateCredentials) {
        $success = Invoke-CredentialUpdate -Manager ([string]$NSXManager)
        if ($success) {
            exit 0
        }
        else {
            exit 1
        }
    }

    if ($ClearSpecific) {
        $success = Invoke-CredentialDelete -Manager $ClearSpecific
        if ($success) {
            exit 0
        }
        else {
            exit 1
        }
    }

    if ($ClearAll) {
        Write-Host "WARNING: Delete ALL stored credentials!" -ForegroundColor Red
        $confirm = Read-Host "Type 'DELETE ALL' to confirm"
        if ($confirm -eq "DELETE ALL") {
            $success = $credentialService.ClearAllCredentials()
            if ($success) {
                Write-Host "All credentials deleted." -ForegroundColor Green
                exit 0
            }
            else {
                Write-Host "Failed to delete all credentials." -ForegroundColor Red
                exit 1
            }
        }
        else {
            Write-Host "Operation cancelled." -ForegroundColor Gray
            exit 0
        }
    }

    if ($TestConnection) {
        $success = Test-NSXConnection -Manager $NSXManager
        if ($success) {
            exit 0
        }
        else {
            exit 1
        }
    }

    # Default to interactive mode
    Start-InteractiveMode
}
catch {
    $errorMessage = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { $_.ToString() }
    $errorMsg = "Operation failed: $errorMessage"
    Write-Host $errorMsg -ForegroundColor Red
    if ($null -ne $logger) {
        $logger.LogError($errorMsg, "CredentialManager")
    }
    exit 1
}

Write-Host "Operation completed." -ForegroundColor Green
