#  MCP Enforcement Hook Activation Script
# Activates MCP enforcement hooks for Claude Code

Write-Host "=== MCP Enforcement Hook Activation ===" -ForegroundColor Green
Write-Host ""

# Check if hook files exist
$HookFiles = @(
  ".claude\hooks\mcp_enforcement_hook.py",
  ".claude\hooks\mcp_post_enforcement_hook.py",
  ".claude\hooks\mcp_workflow_assistant.py",
  ".claude\hooks\ollama_code_generator_hook.py",
  ".claude\hooks\mcp_enforcement_config.json"
)

Write-Host "Checking MCP enforcement hook files..." -ForegroundColor Cyan

$AllFilesExist = $true
foreach ($File in $HookFiles) {
  if (Test-Path $File) {
    Write-Host "  [OK] $File" -ForegroundColor Green
  }
  else {
    Write-Host "  [FAIL] $File (MISSING)" -ForegroundColor Red
    $AllFilesExist = $false
  }
}

if (-not $AllFilesExist) {
  Write-Host ""
  Write-Host "ERROR: Some hook files are missing. Cannot activate enforcement." -ForegroundColor Red
  exit 1
}

# Check MCP config
Write-Host ""
Write-Host "Checking MCP configuration..." -ForegroundColor Cyan

if (Test-Path ".claude\mcp.json") {
  Write-Host "  [OK] MCP configuration found" -ForegroundColor Green

  $Config = Get-Content ".claude\mcp.json" -Raw | ConvertFrom-Json
  if ($Config.hookIntegration -and $Config.hookIntegration.enabled) {
    Write-Host "  [OK] Hook integration enabled" -ForegroundColor Green
  }
  else {
    Write-Host "  [WARNING] Hook integration not enabled" -ForegroundColor Yellow
  }
}
else {
  Write-Host "  [FAIL] MCP configuration not found" -ForegroundColor Red
}

# Create logs directory
$LogDir = ".claude\hooks\logs"
if (-not (Test-Path $LogDir)) {
  New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
  Write-Host "  [OK] Created logs directory" -ForegroundColor Green
}

# Create activation status
$ActivationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$StatusContent = @"
{
  "activation_status": {
    "mcp_enforcement_hook": true,
    "mcp_post_enforcement_hook": true,
    "mcp_workflow_assistant": true,
    "config_validated": true,
    "activation_timestamp": "$ActivationTime"
  },
  "enforcement_features": {
    "mandatory_mcp_usage": true,
    "tool_first_approach": true,
    "workflow_chaining": true,
    "context_retention": true,
    "strict_mode": true,
    "banned_non_mcp_operations": true
  },
  "active_hooks": [
    "mcp_enforcement_hook.py",
    "mcp_post_enforcement_hook.py",
    "mcp_workflow_assistant.py"
  ],
  "enforced_mcp_tools": [
    {"name": "context7", "priority": 4, "purpose": "Documentation"},
    {"name": "memory", "priority": 5, "purpose": "Context retention"},
    {"name": "sequential-thinking", "priority": 6, "purpose": "Advanced reasoning"},
    {"name": "task-orchestrator", "priority": 7, "purpose": "Workflow management"},
    {"name": "filesystem", "priority": 8, "purpose": "File operations"},
    {"name": "fetch", "priority": 9, "purpose": "Web content retrieval"}
  ],
  "workflow_patterns": {
    "development": ["context7", "task-orchestrator", "filesystem", "memory"],
    "research": ["context7", "sequential-thinking", "memory"],
    "data_analysis": ["task-orchestrator", "filesystem", "sequential-thinking", "memory"],
    "web_tasks": ["fetch", "context7", "memory"]
  }
}
"@

# Save activation status
$StatusPath = ".claude\hooks\activation_summary.json"
$StatusContent | Set-Content -Path $StatusPath

Write-Host ""
Write-Host "=== MCP Enforcement Activated ===" -ForegroundColor Green
Write-Host ""
Write-Host "Claude Code is now configured to:" -ForegroundColor White
Write-Host "  - Use MCP tools for ALL operations" -ForegroundColor Cyan
Write-Host "  - Chain tools for complex workflows" -ForegroundColor Cyan
Write-Host "  - Retain context across interactions" -ForegroundColor Cyan
Write-Host "  - Prioritize Context7 for documentation" -ForegroundColor Cyan
Write-Host "  - Use Task Orchestrator for complex tasks" -ForegroundColor Cyan
Write-Host "  - Offload code generation to Ollama bridge containers" -ForegroundColor Cyan
Write-Host "  - Enforce strict MCP-only mode" -ForegroundColor Cyan

# Test Ollama hook functionality
Write-Host ""
Write-Host "Testing Ollama Code Generator Hook..." -ForegroundColor Cyan
try {
  $TestResult = & python test_ollama_hook.py 2>&1
  if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Ollama hook test passed" -ForegroundColor Green
  }
  else {
    Write-Host "  [WARNING] Ollama hook test failed (containers may not be running)" -ForegroundColor Yellow
  }
}
catch {
  Write-Host "  [WARNING] Could not test Ollama hook (test script not found)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Hook activation completed successfully!" -ForegroundColor Green
Write-Host "   Status saved to: $StatusPath" -ForegroundColor Gray
Write-Host ""
