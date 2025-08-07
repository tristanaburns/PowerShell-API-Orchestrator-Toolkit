# Claude Code Hooks & Settings Documentation

This document explains the Claude Code hooks system and settings configuration for the Hive Mind Nexus project.

## Overview

The hooks system enables automated processing at key stages of Claude Code interactions. The settings files configure permissions, automation, and hooks for optimal development workflow.

## Settings Files

### `.claude/settings.json` (Primary Project Settings)

This is the main project configuration file using the current Claude Code schema:

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Edit(*)", "Read(*)", "Write(*)", ...],
    "deny": [],
    "additionalDirectories": ["C:\\", "D:\\", ...],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "HIVE_MIND_PROJECT": "1",
    "HIVE_MIND_HOOKS_ENABLED": "1",
    "HIVE_MIND_AUTOMATION": "1",
    "CLAUDE_MODEL": "claude-sonnet-4-20250514",
    "CLAUDE_USE_SONNET_4": "1",
    "CLAUDE_ULTRATHINK_ENABLED": "1",
    "CLAUDE_THINKING_MODE": "ultra",
    "CLAUDE_ADVANCED_REASONING": "1",
    "CLAUDE_EXTENDED_THINKING": "1"
  },
  "includeCoAuthoredBy": true,
  "cleanupPeriodDays": 30,
  "enableAllProjectMcpServers": true,
  "hooks": {
    "UserPromptSubmit": [...],
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...],
    "Notification": [...]
  }
}
```

Key features:
- **Full system access**: permissions for development tasks
- **Project-focused**: Optimized for Hive Mind Nexus development
- **Automation enabled**: Auto-approval for edits with manual execution
- **Hooks integration**: Complete lifecycle automation

### `.claude/settings.local.json` (Minimal Override)

Simplified local configuration:

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Edit(*)", "Read(*)", "Write(*)", ...],
    "additionalDirectories": ["C:\\", "D:\\", ...],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "HIVE_MIND_PROJECT": "1"
  },
  "includeCoAuthoredBy": true,
  "enableAllProjectMcpServers": true
}
```

## Hooks System (New Matcher Format)

The hooks system now uses a matcher-based configuration format:

### Hook Event Types

1. **UserPromptSubmit**: Triggered when user submits a prompt
2. **PreToolUse**: Triggered before tool execution
3. **PostToolUse**: Triggered after tool execution
4. **Stop**: Triggered when session ends
5. **Notification**: Triggered for system notifications

### Hook Configuration Structure

```json
"hooks": {
  "EventType": [
    {
      "matcher": "pattern|*",
      "hooks": [
        {
          "type": "command",
          "command": "python \"$CLAUDE_PROJECT_DIR\\.claude\\hooks\\hook_script.py\"",
          "timeout": 10
        }
      ]
    }
  ]
}
```

### Matcher Patterns

- `"*"`: Matches all tools/events
- `"Bash|Terminal|PowerShell"`: Matches specific tool categories
- `"Write|Edit|MultiEdit"`: Matches file modification tools
- Uses pipe (`|`) for alternation

## Hook Scripts

### Core Hooks

#### 1. `protocol_enforcement_hook_v2.py`
- **Trigger**: UserPromptSubmit
- **Purpose**: Injects canonical protocols and documentation standards
- **Timing**: First hook to ensure proper context
- **Timeout**: 8 seconds

#### 2. `auto_thinking_hook.py`

- **Trigger**: UserPromptSubmit
- **Purpose**: Enables thinking and analysis
- **Timing**: After protocol enforcement
- **Timeout**: 15 seconds

#### 3. `ultrathink_hook.py`

- **Trigger**: UserPromptSubmit
- **Purpose**: Activates ultra-thinking mode with Sonnet optimization
- **Timing**: After auto-thinking hook
- **Timeout**: 20 seconds
- **Features**: Multi-layered reasoning, complexity analysis, strategic planning

#### 4. `mcp_integration_hook.py`
- **Trigger**: UserPromptSubmit, PreToolUse (all tools)
- **Purpose**: Ensures MCP servers are available and integrated
- **Timing**: Early in pipeline
- **Timeout**: 12 seconds

#### 4. `ollama_code_generator_hook.py`
- **Trigger**: UserPromptSubmit, PostToolUse (file operations)
- **Purpose**: Detects code patterns and generates implementations
- **Timing**: After user input and file modifications
- **Timeout**: 15-20 seconds

### Validation Hooks

#### 5. `mcp_server_detector.py`
- **Trigger**: PreToolUse (all tools)
- **Purpose**: Validates MCP server availability
- **Timeout**: 5 seconds

#### 6. `pre_bash_validation.py`
- **Trigger**: PreToolUse (terminal operations)
- **Purpose**: Validates terminal commands for safety
- **Timeout**: 6 seconds

#### 7. `pre_code_quality.py`
- **Trigger**: PreToolUse (file operations)
- **Purpose**: Code quality validation before modifications
- **Timeout**: 10 seconds

### Post-Processing Hooks

#### 8. `post_bash_logging.py`
- **Trigger**: PostToolUse (terminal operations)
- **Purpose**: Logs terminal command results
- **Timeout**: 5 seconds

#### 9. `post_code_automation.py`
- **Trigger**: PostToolUse (file operations)
- **Purpose**: Automated code quality, documentation, deployment
- **Timeout**: 25 seconds

#### 10. `mcp_auto_installer.py`
- **Trigger**: PostToolUse (all tools)
- **Purpose**: Auto-installs missing dependencies and MCP servers
- **Timeout**: 12 seconds

### Session Management

#### 11. `session_complete_automation.py`
- **Trigger**: Stop
- **Purpose**: End-of-session automation, logging, cleanup
- **Timeout**: 20 seconds

#### 12. `notification_handler.py`
- **Trigger**: Notification
- **Purpose**: Handles system notifications and alerts
- **Timeout**: 3 seconds

## Hook Execution Flow

### UserPromptSubmit Pipeline
```
User Input → Protocol Enforcement → Auto Thinking → Ultra Thinking (Sonnet 4) → MCP Integration → Ollama Pattern Detection
```

### PreToolUse Pipeline
```
Tool Request → MCP Server Detection → Validation (Bash/Code) → Tool Execution
```

### PostToolUse Pipeline
```
Tool Completion → Logging (Bash) → Code Automation → MCP Auto-installer
```

### Session End Pipeline
```
Session End → Complete Automation → Cleanup → Logging
```

## Environment Variables

The configuration uses several environment variables:

- `CLAUDE_CODE_ENABLE_TELEMETRY="1"`: Enable telemetry and notifications
- `HIVE_MIND_PROJECT="1"`: Project identification flag
- `HIVE_MIND_HOOKS_ENABLED="1"`: Global hooks enable flag
- `HIVE_MIND_AUTOMATION="1"`: Automation mode flag
- `CLAUDE_MODEL="claude-sonnet-4-20250514"`: Claude Sonnet 4 model identifier
- `CLAUDE_USE_SONNET_4="1"`: Enable Claude Sonnet 4 usage
- `CLAUDE_ULTRATHINK_ENABLED="1"`: Enable ultra-thinking mode
- `CLAUDE_THINKING_MODE="ultra"`: Set thinking mode to ultra
- `CLAUDE_ADVANCED_REASONING="1"`: Enable advanced reasoning capabilities
- `CLAUDE_EXTENDED_THINKING="1"`: Enable extended thinking features
- `CLAUDE_PROJECT_DIR`: Project directory path (auto-set)

## Permissions Configuration

### Core Permissions
- **File Operations**: `Read(*)`, `Write(*)`, `Edit(*)`, `MultiEdit(*)`
- **System Access**: `Bash(*)`, `Terminal(*)`, `PowerShell(*)`, `Process(*)`
- **Network**: `WebFetch(*)`, `HTTP(*)`, `HTTPS(*)`, `WebSocket(*)`
- **Development**: `Git(*)`, `Docker(*)`, `Container(*)`, `Kubernetes(*)`
- **MCP Integration**: `mcp__*`

### Directory Access
Full system access including:
- `C:\`, `D:\`, `E:\` (all drives)
- `%USERPROFILE%`, `%PROGRAMFILES%`, `%APPDATA%`
- Network shares: `\\*`

## Best Practices

### Hook Development
1. **Keep timeouts reasonable**: 5-25 seconds based on complexity
2. **Handle errors gracefully**: Use try/catch and appropriate exit codes
3. **Use environment variables**: Check flags before execution
4. **Log activities**: Use consistent logging format
5. **Validate inputs**: Check parameters and context

### Settings Management
1. **Project settings override global**: Use verbose project config
2. **Minimal global settings**: Keep global config simple
3. **Valid fields only**: Use only documented schema fields
4. **Test configurations**: Validate with `/doctor` command

### Hook Timing
1. **UserPromptSubmit**: Context enhancement, protocol injection
2. **PreToolUse**: Validation, infrastructure checks
3. **PostToolUse**: Automation, logging, cleanup
4. **Stop**: Session finalization, logging
5. **Notification**: Event handling, alerts

## Troubleshooting

### Common Issues

#### Invalid Settings
- **Problem**: "Found invalid settings files" error
- **Solution**: Use only valid schema fields, remove deprecated options

#### Hook Failures
- **Problem**: Hook timeouts or errors
- **Solution**: Check Python environment, file permissions, timeouts

#### Permission Denied
- **Problem**: Operations blocked despite permissions
- **Solution**: Verify `additionalDirectories`, check Windows UAC

#### MCP Server Issues
- **Problem**: MCP tools not available
- **Solution**: Check `mcp.json`, verify server installation

### Diagnostic Commands
- `/doctor`: Check settings validity
- `/settings`: View current configuration
- `/mcp`: Check MCP server status
- `/hooks`: View hook configuration (if available)

## Migration Notes

This configuration uses the current Claude Code schema (2024). Key changes from older versions:

1. **Matcher-based hooks**: Replaced condition-based hooks
2. **Simplified structure**: Removed deprecated automation/security sections from settings
3. **Valid fields only**: Removed unsupported configuration options
4. **Environment variables**: Streamlined env var usage

## File Locations

- **Project Settings**: `.claude/settings.json`
- **Local Override**: `.claude/settings.local.json`
- **MCP Configuration**: `.claude/mcp.json`
- **Hook Scripts**: `.claude/hooks/*.py`
- **Global Settings**: `~/.claude/settings.json` (minimal)

This configuration provides automation while maintaining safety and compliance with Claude Code requirements.
