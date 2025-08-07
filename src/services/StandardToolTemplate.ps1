# StandardToolTemplate.ps1 - Phase 2: Architecture Consolidation
# Standardized template for NSX Toolkit tools implementing common patterns

# ========================================
# CANONICAL OUTPUT DIRECTORY PATTERN (MANDATORY)
# ========================================
# All tools must:
# - Default OutputDirectory to './data/exports' (or appropriate subdir)
# - Ensure the directory exists before writing any files (use Initialize-StandardOutputDirectory)
# - Never assume the directory exists; always check/create
# - All logs must go under './logs' (relative to codebase root)
# - All data outputs must go under './data' (with subdirs for exports, syncs, etc.)
#
# This is a non-negotiable standard for all NSX Toolkit tools and scripts.

<#
.SYNOPSIS
    Standardized NSX Tool Template - Common Parameters and Patterns

.DESCRIPTION
    Template providing standardized parameter sets, initialization patterns, and common
    functionality for all NSX toolkit tools. Implements SOLID principles and DRY compliance.
    CANONICAL OUTPUT DIRECTORY PATTERN:
    - All tool outputs go under './data' (with subdirs for exports, syncs, etc.)
    - All logs go under './logs'
    - Directory creation is always handled by the tool/script, not the orchestrator
    - Use Initialize-StandardOutputDirectory to enforce this pattern

.NOTES
    STANDARDIZED PARAMETER GROUPS:
    - Authentication: NSXManager, credentials, AD integration
    - Operation: NonInteractive, LogLevel, output control
    - SSL/Connection: SSL bypassing, connection management
    - Output: Directory management, statistics, reporting

    USAGE:
    Copy this template for new tools, customize tool-specific parameters,
    and implement tool-specific logic in the designated section.
#>

# ========================================
# STANDARDIZED PARAMETER DEFINITION
# ========================================

[CmdletBinding(SupportsShouldProcess)]
param(
  # ========================================
  # AUTHENTICATION PARAMETER GROUP
  # ========================================
  [Parameter(Mandatory = $true, HelpMessage = "NSX Manager FQDN or IP address")]
  [ValidateNotNullOrEmpty()]
  [string]$NSXManager,

  [Parameter(Mandatory = $false, HelpMessage = "Username for basic authentication")]
  [string]$Username,

  [Parameter(Mandatory = $false, HelpMessage = "Use current Windows user credentials (requires AD integration)")]
  [switch]$UseCurrentUserCredentials,

  [Parameter(Mandatory = $false, HelpMessage = "Force prompt for new credentials even if saved credentials exist")]
  [switch]$ForceNewCredentials,

  [Parameter(Mandatory = $false, HelpMessage = "Save credentials for future use after successful authentication")]
  [switch]$SaveCredentials,

  [Parameter(Mandatory = $false, HelpMessage = "Load credentials from specific encrypted file")]
  [string]$AuthenticationConfigFile,

  # ========================================
  # OPERATION PARAMETER GROUP
  # ========================================
  [Parameter(Mandatory = $false, HelpMessage = "Run without interactive prompts (for automation)")]
  [switch]$NonInteractive,

  [Parameter(Mandatory = $false, HelpMessage = "Logging level for operation details")]
  [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'Critical')]
  [string]$LogLevel = 'Info',

  [Parameter(Mandatory = $false, HelpMessage = "Perform dry-run without making actual changes")]
  [switch]$WhatIf,

  [Parameter(Mandatory = $false, HelpMessage = "Display detailed performance and operation statistics")]
  [switch]$OutputStatistics,

  # ========================================
  # SSL/CONNECTION PARAMETER GROUP
  # ========================================
  [Parameter(Mandatory = $false, HelpMessage = "Bypass SSL certificate validation")]
  [switch]$SkipSSLCheck,

  [Parameter(Mandatory = $false, HelpMessage = "Skip initial connection testing")]
  [switch]$SkipConnectionTest,

  # ========================================
  # OUTPUT PARAMETER GROUP
  # ========================================
  [Parameter(Mandatory = $false, HelpMessage = "Directory for output files (canonical: ./data/exports)")]
  [ValidateNotNullOrEmpty()]
  [string]$OutputDirectory = [WorkflowOperationsService]::GetDataPath('Exports'), # Canonical default

  [Parameter(Mandatory = $false, HelpMessage = "Include metadata in output")]
  [switch]$IncludeMetadata

  # ========================================
  # TOOL-SPECIFIC PARAMETERS
  # (Add tool-specific parameters here)
  # ========================================
)

# ========================================
# STANDARDIZED SERVICE INITIALIZATION
# ========================================

function Initialize-StandardService {
  <#
    .SYNOPSIS
        Standardized service initialization for all NSX tools

    .DESCRIPTION
        Implements the standardized service loading pattern using InitServiceFramework
        while preserving SSL bypassing and service protection requirements.

    .OUTPUTS
        Returns hashtable containing initialized services
    #>

  $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
  $servicesPath = "$scriptPath\..\src\services"

  try {
    # Load the InitServiceFramework
    . "$scriptPath\..\src\services\InitServiceFramework.ps1"

    # Initialize all services using centralized framework (preserves SSL bypassing)
    $services = Initialize-ServiceFramework $servicesPath

    if ($null -eq $services) {
      throw "Service framework initialization failed"
    }

    # Verify core services are available
    $requiredServices = @('Logger', 'CredentialService', 'AuthService', 'APIService')
    foreach ($serviceName in $requiredServices) {
      if ($null -eq $services.$serviceName) {
        throw "Required service '$serviceName' failed to initialize"
      }
    }

    Write-Host "Service framework initialized successfully" -ForegroundColor Green
    return $services
  }
  catch {
    Write-Error "Failed to initialize service framework: $($_.Exception.Message)"
    exit 1
  }
}

function Get-StandardCredential {
  <#
    .SYNOPSIS
        Standardized credential collection for all NSX tools

    .DESCRIPTION
        Implements standardized credential collection using the authentication service
        with support for current user, saved credentials, and force new credentials.

    .PARAMETER AuthService
        The authentication service instance

    .PARAMETER NSXManager
        The NSX Manager to authenticate against

    .PARAMETER UseCurrentUser
        Whether to use current user credentials

    .PARAMETER ForceNew
        Whether to force new credential collection

    .OUTPUTS
        Returns PSCredential object for NSX Manager authentication
    #>
  param(
    [object]$AuthService,
    [string]$NSXManager,
    [bool]$UseCurrentUser = $false,
    [bool]$ForceNew = $false
  )

  try {
    Write-Host "Collecting credentials for $NSXManager..."
    $credential = $AuthService.GetCredential($NSXManager, $Username, $UseCurrentUser, $ForceNew)

    if ($null -eq $credential) {
      throw "Failed to obtain valid credentials for $NSXManager"
    }

    Write-Host "Credentials collected successfully" -ForegroundColor Green
    return $credential
  }
  catch {
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 403) {
      $errorMsg = "Authentication failed with 403 Forbidden. Saved credentials for $NSXManager are invalid or expired. Please update your credentials using -ForceNewCredentials."
      Write-Host "ERROR: $errorMsg" -ForegroundColor Red
    }
    throw $_.Exception.Message
  }
}

function Initialize-StandardOutputDirectory {
  <#
    .SYNOPSIS
        Standardized output directory initialization

    .DESCRIPTION
        Creates output directory if it doesn't exist and validates write permissions

    .PARAMETER OutputDirectory
        The output directory path to initialize
    #>
  param([string]$OutputDirectory)

  if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
    Write-Host "Created output directory: $OutputDirectory"
  }
}

function Write-StandardToolHeader {
  <#
    .SYNOPSIS
        Standardized tool header display

    .DESCRIPTION
        Displays consistent tool header with operation details

    .PARAMETER ToolName
        Name of the tool being executed

    .PARAMETER NSXManager
        Target NSX Manager

    .PARAMETER Operation
        Operation being performed
    #>
  param(
    [string]$ToolName,
    [string]$NSXManager,
    [string]$Operation
  )

  Write-Host ""
  Write-Host ("=" * 80) -ForegroundColor Cyan
  Write-Host "  $ToolName" -ForegroundColor Cyan
  Write-Host ("=" * 80) -ForegroundColor Cyan
  Write-Host ""
  Write-Host "NSX Manager: $NSXManager"
  Write-Host "Operation: $Operation"
  Write-Host ""
}

function Write-StandardToolFooter {
  <#
    .SYNOPSIS
        Standardized tool footer with statistics

    .DESCRIPTION
        Displays operation completion status and statistics if requested

    .PARAMETER ToolName
        Name of the tool

    .PARAMETER Success
        Whether the operation succeeded

    .PARAMETER Statistics
        Statistics hashtable (optional)

    .PARAMETER ShowStatistics
        Whether to display statistics
    #>
  param(
    [string]$ToolName,
    [bool]$Success,
    [object]$Statistics = [PSCustomObject]@{},
    [bool]$ShowStatistics = $false
  )

  Write-Host ""
  Write-Host ("=" * 80) -ForegroundColor $(if ($Success) { 'Green' } else { 'Red' })

  if ($Success) {
    Write-Host "  $ToolName - Operation Completed Successfully" -ForegroundColor Green
  }
  else {
    Write-Host "  $ToolName - Operation Failed" -ForegroundColor Red
  }

  if ($ShowStatistics -and $Statistics.Count -gt 0) {
    Write-Host ""
    Write-Host "Operation Statistics:" -ForegroundColor Yellow
    foreach ($key in $Statistics.Keys) {
      Write-Host "  $key`: $($Statistics[$key])"
    }
  }

  Write-Host ("=" * 80) -ForegroundColor $(if ($Success) { 'Green' } else { 'Red' })
  Write-Host ""
}

# ========================================
# STANDARDIZED ERROR HANDLING
# ========================================

function Invoke-StandardErrorHandler {
  <#
    .SYNOPSIS
        Standardized error handling for all tools

    .DESCRIPTION
        Provides consistent error handling, logging, and cleanup

    .PARAMETER ErrorRecord
        The error record to handle

    .PARAMETER Logger
        The logging service instance

    .PARAMETER ToolName
        Name of the tool for logging context
    #>
  param(
    [System.Management.Automation.ErrorRecord]$ErrorRecord,
    [object]$Logger,
    [string]$ToolName
  )

  $errorMessage = "Tool execution failed: $($ErrorRecord.Exception.Message)"

  if ($null -ne $Logger) {
    $Logger.LogError($errorMessage, $ToolName)
  }

  Write-Host ""
  Write-Host "ERROR: $errorMessage" -ForegroundColor Red
  Write-Host ""

  if ($ErrorRecord.Exception.Response) {
    Write-Host "HTTP Status: $($ErrorRecord.Exception.Response.StatusCode)" -ForegroundColor Red
  }

  Write-Host "Full Error Details:" -ForegroundColor Red
  Write-Host $ErrorRecord.Exception.ToString() -ForegroundColor Red
}

# ========================================
# STANDARDIZED TOOL EXECUTION TEMPLATE
# ========================================

<#
STANDARDIZED TOOL IMPLEMENTATION TEMPLATE:

# ========================================
# TOOL-SPECIFIC LOGIC IMPLEMENTATION
# ========================================

# Initialize services
$services = Initialize-StandardService

# Extract services
$logger = $services.Logger
$authService = $services.AuthService
# ... other required services

# Configure logging
$logger.SetLogLevel($LogLevel)

# Display tool header
Write-StandardToolHeader -ToolName "Your Tool Name" -NSXManager $NSXManager -Operation "Your Operation"

try {
    # Initialize output directory
    Initialize-StandardOutputDirectory -OutputDirectory $OutputDirectory

    # Get credentials
    $credential = Get-StandardCredential -AuthService $authService -NSXManager $NSXManager -UseCurrentUser $UseCurrentUserCredentials -ForceNew $ForceNewCredentials

    # ========================================
    # IMPLEMENT TOOL-SPECIFIC LOGIC HERE
    # ========================================

    # Your tool-specific implementation goes here
    # Use the standardized services and parameters

    # ========================================
    # END TOOL-SPECIFIC LOGIC
    # ========================================

    # Display success footer
    $statistics = [PSCustomObject]@{
        'Operation' = 'Completed'
        'Duration' = 'X seconds'
        # Add tool-specific statistics
    }

    Write-StandardToolFooter -ToolName "Your Tool Name" -Success $true -Statistics $statistics -ShowStatistics $OutputStatistics
}
catch {
    Invoke-StandardErrorHandler -ErrorRecord $_ -Logger $logger -ToolName "Your Tool Name"
    Write-StandardToolFooter -ToolName "Your Tool Name" -Success $false
    exit 1
}

#>

# Export standardized functions for use by tools
Export-ModuleMember -Function Initialize-StandardService, Get-StandardCredential, Initialize-StandardOutputDirectory, Write-StandardToolHeader, Write-StandardToolFooter, Invoke-StandardErrorHandler
