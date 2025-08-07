<#
.SYNOPSIS
    Shared Tool Credential Service - Eliminates credential collection duplication across all tools

.DESCRIPTION
    Provides standardized credential collection functionality for all NSX toolkit tools.
    Eliminates ~200+ lines of duplicated credential handling code across 9 tool scripts.

.NOTES
    Part of NSX PowerShell Toolkit Architecture Refactoring Plan
    Target: Eliminate credential duplication across all tools
    Preserves existing SSL bypassing and authentication service functionality
#>

class SharedToolCredentialService {
  [object] $logger
  [object] $authService
  [object] $credentialService

  # Constructor
  SharedToolCredentialService([object] $logger, [object] $authService, [object] $credentialService) {
    $this.logger = $logger
    $this.authService = $authService
    $this.credentialService = $credentialService
    $this.logger.LogInfo("SharedToolCredentialService initialized successfully", "SharedCredentialService")
  }

  # Standard credential parameter block that all tools can use
  static [object] GetStandardCredentialParameters() {
    return @{
      UseCurrentUserCredentials = @{
        Type             = 'switch'
        HelpMessage      = 'Use current Windows user credentials (requires AD integration)'
        ParameterSetName = 'CredentialOptions'
      }
      ForceNewCredentials       = @{
        Type             = 'switch'
        HelpMessage      = 'Force prompt for new credentials even if saved credentials exist'
        ParameterSetName = 'CredentialOptions'
      }
      SaveCredentials           = @{
        Type             = 'switch'
        HelpMessage      = 'Automatically save working credentials'
        ParameterSetName = 'CredentialOptions'
      }
      AuthenticationConfigFile  = @{
        Type             = 'string'
        HelpMessage      = 'Load credentials from specific file path'
        ParameterSetName = 'CredentialOptions'
      }
      Username                  = @{
        Type             = 'string'
        HelpMessage      = 'Username for basic authentication (ignored with -UseCurrentUserCredentials)'
        ParameterSetName = 'CredentialOptions'
      }
      NonInteractive            = @{
        Type             = 'switch'
        HelpMessage      = 'Run without interactive prompts (for automation)'
        ParameterSetName = 'CredentialOptions'
      }
    }
  }

  # Collect credentials using standardized logic that all tools can use
  [PSCredential] GetStandardNSXCredentials(
    [string] $NSXManager,
    [string] $Username,
    [bool] $UseCurrentUserCredentials,
    [bool] $ForceNewCredentials,
    [bool] $SaveCredentials,
    [string] $AuthenticationConfigFile,
    [string] $ToolName
  ) {
    try {
      $this.logger.LogInfo("Starting standardized credential collection for: $NSXManager (Tool: $ToolName)", "SharedCredentialService")

      # Validate required parameters
      if ([string]::IsNullOrWhiteSpace($NSXManager)) {
        throw "NSXManager parameter cannot be empty"
      }

      if ([string]::IsNullOrWhiteSpace($ToolName)) {
        $ToolName = "UnknownTool"
      }

      # Collect credentials using existing CoreAuthenticationService
      $credential = $null
      if ($UseCurrentUserCredentials) {
        $this.logger.LogInfo("Using current user credentials for: $NSXManager", "SharedCredentialService")
        $credential = $this.authService.GetCredential($NSXManager, $Username, $true, $ForceNewCredentials)
      }
      else {
        $this.logger.LogInfo("Using saved/prompted credentials for: $NSXManager", "SharedCredentialService")
        $credential = $this.authService.GetCredential($NSXManager, $Username, $false, $ForceNewCredentials)
      }

      # Validate credential collection
      if ($null -eq $credential) {
        throw "Failed to obtain valid credentials for $NSXManager"
      }

      $this.logger.LogInfo("Credentials collected successfully for: $NSXManager (Tool: $ToolName)", "SharedCredentialService")

      # Save credentials if requested and we have them
      if ($SaveCredentials -and $credential) {
        try {
          $this.credentialService.SaveCredentials($NSXManager, $credential)
          $this.logger.LogInfo("Credentials saved successfully for $NSXManager (Tool: $ToolName)", "SharedCredentialService")
        }
        catch {
          $this.logger.LogWarning("Failed to save credentials: $($_.Exception.Message) (Tool: $ToolName)", "SharedCredentialService")
          # Don't fail the operation if save fails - just log warning
        }
      }

      return $credential
    }
    catch {
      $this.logger.LogError("Failed to collect credentials for $NSXManager (Tool: $ToolName): $($_.Exception.Message)", "SharedCredentialService")

      # Handle specific error types with standardized messages
      if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 403) {
        $errorMsg = "Authentication failed with 403 Forbidden. Saved credentials for $NSXManager are invalid or expired. Please update your credentials using -ForceNewCredentials."
        Write-Host "ERROR: $errorMsg" -ForegroundColor Red
        $this.logger.LogError($errorMsg, "SharedCredentialService")
        throw $errorMsg
      }
      elseif ($_.Exception.Message -match "SSL|TLS|certificate|trust") {
        $errorMsg = "SSL/Certificate validation failed for $NSXManager. SSL bypassing should be configured automatically."
        Write-Host "ERROR: $errorMsg" -ForegroundColor Red
        $this.logger.LogError($errorMsg, "SharedCredentialService")
        throw $errorMsg
      }
      else {
        $errorMsg = "Failed to collect credentials for $NSXManager : $($_.Exception.Message)"
        Write-Host "ERROR: $errorMsg" -ForegroundColor Red
        $this.logger.LogError($errorMsg, "SharedCredentialService")
        throw $errorMsg
      }
    }
  }

  # Display credential collection status (standardized output)
  [void] DisplayCredentialCollectionStatus(
    [string] $NSXManager,
    [string] $ToolName,
    [bool] $UseCurrentUserCredentials,
    [bool] $ForceNewCredentials,
    [bool] $SaveCredentials
  ) {
    Write-Host "Collecting credentials for $NSXManager..." -ForegroundColor Yellow
    $this.logger.LogInfo("Credential collection status display for: $NSXManager (Tool: $ToolName)", "SharedCredentialService")

    if ($UseCurrentUserCredentials) {
      Write-Host "  Authentication Method: Current Windows User" -ForegroundColor Green
    }
    else {
      Write-Host "  Authentication Method: Basic Authentication" -ForegroundColor Green
    }

    if ($ForceNewCredentials) {
      Write-Host "  Credential Source: Force New (ignoring saved credentials)" -ForegroundColor Yellow
    }
    else {
      Write-Host "  Credential Source: Saved or Prompted" -ForegroundColor Gray
    }

    if ($SaveCredentials) {
      Write-Host "  Credential Saving: Enabled" -ForegroundColor Green
    }
    else {
      Write-Host "  Credential Saving: Disabled" -ForegroundColor Gray
    }
  }

  # Validate credential requirements (prevent common parameter conflicts)
  [void] ValidateCredentialParameters(
    [bool] $UseCurrentUserCredentials,
    [bool] $ForceNewCredentials,
    [string] $Username,
    [string] $AuthenticationConfigFile
  ) {
    $this.logger.LogDebug("Validating credential parameter combination", "SharedCredentialService")

    # Check for parameter conflicts
    if ($UseCurrentUserCredentials -and -not [string]::IsNullOrWhiteSpace($Username)) {
      $this.logger.LogWarning("Username parameter ignored when using current user credentials", "SharedCredentialService")
      Write-Warning "Username parameter ignored when using -UseCurrentUserCredentials"
    }

    if ($UseCurrentUserCredentials -and -not [string]::IsNullOrWhiteSpace($AuthenticationConfigFile)) {
      $this.logger.LogWarning("AuthenticationConfigFile parameter ignored when using current user credentials", "SharedCredentialService")
      Write-Warning "AuthenticationConfigFile parameter ignored when using -UseCurrentUserCredentials"
    }

    $this.logger.LogDebug("Credential parameter validation completed", "SharedCredentialService")
  }

  # Get credential collection summary (for logging and reporting)
  [object] GetCredentialCollectionSummary(
    [string] $NSXManager,
    [string] $ToolName,
    [bool] $UseCurrentUserCredentials,
    [bool] $ForceNewCredentials,
    [bool] $SaveCredentials,
    [PSCredential] $credential
  ) {
    return @{
      NSXManager           = $NSXManager
      ToolName             = $ToolName
      AuthenticationMethod = if ($UseCurrentUserCredentials) { "Current User" } else { "Basic Authentication" }
      CredentialSource     = if ($ForceNewCredentials) { "Force New" } else { "Saved or Prompted" }
      CredentialSaving     = $SaveCredentials
      Success              = ($null -ne $credential)
      Timestamp            = Get-Date
      Username             = if ($credential) { $credential.UserName } else { "N/A" }
    }
  }
}
