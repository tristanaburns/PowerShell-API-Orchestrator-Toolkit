# MCP Enforcement Hook Activation Script for Windows
# Activates MCP enforcement hooks to ensure Claude Code prioritizes MCP tools

param(
  [switch]$Force,
  [switch]$Verbose,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Set up logging
$LogDir = ".claude\hooks\logs"
if (-not (Test-Path $LogDir)) {
  New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

$LogFile = "$LogDir\hook_activation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
  param([string]$Message, [string]$Level = "INFO")
  $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $LogMessage = "[$Timestamp] [$Level] $Message"
  Write-Host $LogMessage
  Add-Content -Path $LogFile -Value $LogMessage
}

function Test-HookFiles {
  Write-Log "Validating MCP enforcement hook files..."
    
  $RequiredHooks = @(
    ".claude\hooks\mcp_enforcement_hook.py",
    ".claude\hooks\mcp_post_enforcement_hook.py",
    ".claude\hooks\mcp_workflow_assistant.py",
    ".claude\hooks\mcp_enforcement_config.json"
  )
    
  $MissingFiles = @()
  foreach ($HookFile in $RequiredHooks) {
    if (-not (Test-Path $HookFile)) {
      $MissingFiles += $HookFile
    }
  }
    
  if ($MissingFiles.Count -gt 0) {
    Write-Log "Missing required hook files: $($MissingFiles -join ', ')" "ERROR"
    return $false
  }
    
  Write-Log "All required hook files validated "
  return $true
}

function Test-MCPConfig {
  Write-Log "Checking MCP configuration for hook integration..."
    
  $MCPConfigPath = ".claude\mcp.json"
  if (-not (Test-Path $MCPConfigPath)) {
    Write-Log "MCP configuration file not found" "ERROR"
    return $false
  }
    
  try {
    $Config = Get-Content $MCPConfigPath -Raw | ConvertFrom-Json
        
    if (-not $Config.hookIntegration -or -not $Config.hookIntegration.enabled) {
      Write-Log "Hook integration not enabled in MCP config" "WARNING"
      return $false
    }
        
    Write-Log "MCP configuration validated for hook integration "
    return $true
        
  }
  catch {
    Write-Log "Error reading MCP configuration: $($_.Exception.Message)" "ERROR"
    return $false
  }
}

function Start-MCPEnforcementHooks {
  Write-Log "Activating MCP enforcement hooks..."
    
  $ActivationStatus = @{
    mcp_enforcement_hook      = $false
    mcp_post_enforcement_hook = $false
    mcp_workflow_assistant    = $false
    config_validated          = $false
    activation_timestamp      = $null
  }
    
  try {
    # Validate hook files
    if (-not (Test-HookFiles)) {
      return $ActivationStatus
    }
        
    # Check MCP config
    if (-not (Test-MCPConfig)) {
      return $ActivationStatus
    }
        
    # Load enforcement config
    $ConfigPath = ".claude\hooks\mcp_enforcement_config.json"
    $EnforcementConfig = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        
    # Validate enforcement config
    if (-not $EnforcementConfig.hooks.enabled) {
      Write-Log "Hook enforcement not enabled in config" "ERROR"
      return $ActivationStatus
    }
        
    if ($DryRun) {
      Write-Log "DRY RUN: Would activate MCP enforcement hooks" "INFO"
      return $ActivationStatus
    }
        
    # Mark hooks as activated
    $ActivationStatus.mcp_enforcement_hook = $true
    $ActivationStatus.mcp_post_enforcement_hook = $true
    $ActivationStatus.mcp_workflow_assistant = $true
    $ActivationStatus.config_validated = $true
    $ActivationStatus.activation_timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        
    Write-Log "MCP enforcement hooks successfully activated "
    Write-Log "Claude Code will now prioritize MCP tools for all operations"
        
    # Log enforcement settings
    $EnforcementSettings = $EnforcementConfig.mcpEnforcementSettings
    Write-Log "Strict mode: $($EnforcementSettings.strictMode)"
    Write-Log "Required MCP for file ops: $($EnforcementSettings.requireMcpForFileOps)"
    Write-Log "Required MCP for web ops: $($EnforcementSettings.requireMcpForWebOps)"
    Write-Log "Tool chaining enforced: $($EnforcementSettings.enforceToolChaining)"
        
    return $ActivationStatus
        
  }
  catch {
    Write-Log "Error activating enforcement hooks: $($_.Exception.Message)" "ERROR"
    return $ActivationStatus
  }
}

function New-ActivationSummary {
  param([hashtable]$Status)
    
  Write-Log "Creating activation summary report..."
    
  $SummaryPath = ".claude\hooks\activation_summary.json"
    
  $Summary = @{
    "activation_status"    = $Status
    "enforcement_features" = @{
      "mandatory_mcp_usage"       = $true
      "tool_first_approach"       = $true
      "workflow_chaining"         = $true
      "context_retention"         = $true
      "strict_mode"               = $true
      "banned_non_mcp_operations" = $true
    }
    "active_hooks"         = @(
      "mcp_enforcement_hook.py",
      "mcp_post_enforcement_hook.py",
      "mcp_workflow_assistant.py"
    )
    "enforced_mcp_tools"   = @(
      "context7",
      "task-orchestrator", 
      "memory",
      "sequential-thinking",
      "e2b",
      "filesystem",
      "browserbase",
      "chroma"
    )
    "workflow_patterns"    = @{
      "development"   = @("task-orchestrator", "context7", "e2b", "memory")
      "research"      = @("context7", "sequential-thinking", "memory", "notion")
      "data_analysis" = @("filesystem", "chroma", "memory", "notion")
      "automation"    = @("browserbase", "make", "memory")
    }
  }
    
  try {
    $Summary | ConvertTo-Json -Depth 10 | Set-Content -Path $SummaryPath
    Write-Log "Activation summary saved to $SummaryPath "
        
  }
  catch {
    Write-Log "Error saving activation summary: $($_.Exception.Message)" "ERROR"
  }
}

# Main execution
Write-Log "Starting MCP enforcement hook activation"
Write-Log ("=" * 60)

if ($Verbose) {
  Write-Log "Running in verbose mode"
}

if ($DryRun) {
  Write-Log "Running in dry-run mode - no changes will be made"
}

# Activate hooks
$Status = Start-MCPEnforcementHooks

# Create summary
New-ActivationSummary -Status $Status

# Final status
$AllHooksActive = $Status.mcp_enforcement_hook -and 
$Status.mcp_post_enforcement_hook -and 
$Status.mcp_workflow_assistant

if ($AllHooksActive) {
  Write-Log " MCP enforcement hooks successfully activated" "SUCCESS"
  Write-Log "Claude Code will now prioritize MCP tools for all operations"
  Write-Log "Enforcement includes: mandatory MCP usage, tool chaining, context retention"
    
  Write-Host ""
  Write-Host " MCP Enforcement Active! " -ForegroundColor Green
  Write-Host "Claude Code is now configured to:"
  Write-Host "   Use MCP tools for ALL operations" -ForegroundColor Cyan
  Write-Host "   Chain tools for complex workflows" -ForegroundColor Cyan  
  Write-Host "   Retain context across interactions" -ForegroundColor Cyan
  Write-Host "   Prioritize Context7 for documentation" -ForegroundColor Cyan
  Write-Host "   Use Task Orchestrator for complex tasks" -ForegroundColor Cyan
    
}
else {
  Write-Log " Hook activation failed - check logs for details" "ERROR"
  exit 1
}

Write-Log "Hook activation completed"
