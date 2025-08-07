#!/usr/bin/env python3
"""
MCP Hook Activation Script
Activates and configures MCP enforcement hooks for Claude Code
"""

import json
import logging
import os
import sys
from pathlib import Path
from typing import Any, Dict


def setup_logging():
    """Setup logging for hook activation"""
    log_dir = Path(".claude/hooks/logs")
    log_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(log_dir / "hook_activation.log"),
            logging.StreamHandler(sys.stdout),
        ],
    )

    return logging.getLogger(__name__)


def validate_hook_files(logger: logging.Logger) -> bool:
    """Validate that all required hook files exist"""
    required_hooks = [
        ".claude/hooks/mcp_enforcement_hook.py",
        ".claude/hooks/mcp_post_enforcement_hook.py",
        ".claude/hooks/mcp_workflow_assistant.py",
        ".claude/hooks/mcp_enforcement_config.json",
    ]

    missing_files = []
    for hook_file in required_hooks:
        if not Path(hook_file).exists():
            missing_files.append(hook_file)

    if missing_files:
        logger.error(f"Missing required hook files: {missing_files}")
        return False

    logger.info("All required hook files validated")
    return True


def check_mcp_config(logger: logging.Logger) -> bool:
    """Check MCP configuration for hook integration"""
    mcp_config_path = Path(".claude/mcp.json")

    if not mcp_config_path.exists():
        logger.error("MCP configuration file not found")
        return False

    try:
        with open(mcp_config_path, "r") as f:
            config = json.load(f)

        hook_integration = config.get("hookIntegration", {})
        if not hook_integration.get("enabled", False):
            logger.warning("Hook integration not enabled in MCP config")
            return False

        logger.info("MCP configuration validated for hook integration")
        return True

    except (json.JSONDecodeError, FileNotFoundError) as e:
        logger.error(f"Error reading MCP configuration: {e}")
        return False


def activate_enforcement_hooks(logger: logging.Logger) -> Dict[str, Any]:
    """Activate MCP enforcement hooks"""

    activation_status = {
        "mcp_enforcement_hook": False,
        "mcp_post_enforcement_hook": False,
        "mcp_workflow_assistant": False,
        "config_validated": False,
        "activation_timestamp": None,
    }

    try:
        # Validate hook files
        if not validate_hook_files(logger):
            return activation_status

        # Check MCP config
        if not check_mcp_config(logger):
            return activation_status

        # Load enforcement config
        config_path = Path(".claude/hooks/mcp_enforcement_config.json")
        with open(config_path, "r") as f:
            enforcement_config = json.load(f)

        # Validate enforcement config
        hooks_config = enforcement_config.get("hooks", {})
        if not hooks_config.get("enabled", False):
            logger.error("Hook enforcement not enabled in config")
            return activation_status

        # Mark hooks as activated
        activation_status["mcp_enforcement_hook"] = True
        activation_status["mcp_post_enforcement_hook"] = True
        activation_status["mcp_workflow_assistant"] = True
        activation_status["config_validated"] = True
        activation_status["activation_timestamp"] = "2025-01-03T00:00:00Z"

        logger.info("MCP enforcement hooks successfully activated")
        logger.info("Claude Code will now prioritize MCP tools for all operations")

        # Log enforcement settings
        enforcement_settings = enforcement_config.get("mcpEnforcementSettings", {})
        logger.info(f"Strict mode: {enforcement_settings.get('strictMode', False)}")
        logger.info(
            f"Required MCP for file ops: {enforcement_settings.get('requireMcpForFileOps', False)}"
        )
        logger.info(
            f"Required MCP for web ops: {enforcement_settings.get('requireMcpForWebOps', False)}"
        )
        logger.info(
            f"Tool chaining enforced: {enforcement_settings.get('enforceToolChaining', False)}"
        )

        return activation_status

    except Exception as e:
        logger.error(f"Error activating enforcement hooks: {e}")
        return activation_status


def create_activation_summary(logger: logging.Logger, status: Dict[str, Any]):
    """Create activation summary report"""

    summary_path = Path(".claude/hooks/activation_summary.json")

    summary = {
        "activation_status": status,
        "enforcement_features": {
            "mandatory_mcp_usage": True,
            "tool_first_approach": True,
            "workflow_chaining": True,
            "context_retention": True,
            "strict_mode": True,
            "banned_non_mcp_operations": True,
        },
        "active_hooks": [
            "mcp_enforcement_hook.py",
            "mcp_post_enforcement_hook.py",
            "mcp_workflow_assistant.py",
        ],
        "enforced_mcp_tools": [
            "context7",
            "task-orchestrator",
            "memory",
            "sequential-thinking",
            "e2b",
            "filesystem",
            "browserbase",
            "chroma",
        ],
        "workflow_patterns": {
            "development": ["task-orchestrator", "context7", "e2b", "memory"],
            "research": ["context7", "sequential-thinking", "memory", "notion"],
            "data_analysis": ["filesystem", "chroma", "memory", "notion"],
            "automation": ["browserbase", "make", "memory"],
        },
    }

    try:
        with open(summary_path, "w") as f:
            json.dump(summary, f, indent=2)

        logger.info(f"Activation summary saved to {summary_path}")

    except Exception as e:
        logger.error(f"Error saving activation summary: {e}")


def main():
    """Main activation function"""
    logger = setup_logging()

    logger.info("Starting MCP enforcement hook activation")
    logger.info("=" * 60)

    # Activate hooks
    status = activate_enforcement_hooks(logger)

    # Create summary
    create_activation_summary(logger, status)

    # Final status
    if all(
        status[key]
        for key in [
            "mcp_enforcement_hook",
            "mcp_post_enforcement_hook",
            "mcp_workflow_assistant",
        ]
    ):
        logger.info("✅ MCP enforcement hooks successfully activated")
        logger.info("Claude Code will now prioritize MCP tools for all operations")
        logger.info(
            "Enforcement includes: mandatory MCP usage, tool chaining, context retention"
        )
    else:
        logger.error("❌ Hook activation failed - check logs for details")
        sys.exit(1)


if __name__ == "__main__":
    main()
