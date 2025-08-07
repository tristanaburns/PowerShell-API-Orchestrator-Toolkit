#!/usr/bin/env python3
"""
MCP Post-Enforcement Hook for Claude Code - PostToolUse
Compliant with official Claude Code hooks specification
Monitors and validates MCP tool usage after tool execution
"""

import json
import logging
import sys
from pathlib import Path


def setup_logging():
    """Setup logging for the hook"""
    log_dir = Path(".claude/hooks/logs")
    log_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(log_dir / "mcp_post_enforcement.log"),
        ],
    )

    return logging.getLogger(__name__)


def validate_mcp_usage(tool_name, logger):
    """Validate if MCP tools are being used appropriately"""

    # MCP tool patterns
    mcp_patterns = [
        "mcp__memory__",
        "mcp__sequential-thinking__",
        "mcp__task-orchestrator__",
        "mcp__filesystem__",
        "mcp__brave-search__",
        "mcp__context7__",
    ]

    is_mcp_tool = any(pattern in tool_name for pattern in mcp_patterns)

    # Check for non-MCP tools that should use MCP alternatives
    non_mcp_violations = {
        "Read": "Use mcp__filesystem__read_file instead",
        "Write": "Use mcp__filesystem__write_file instead",
        "Edit": "Use mcp__filesystem__edit_file instead",
        "WebFetch": "Use mcp__brave-search__search instead",
        "WebSearch": "Use mcp__brave-search__search instead",
    }

    if tool_name in non_mcp_violations:
        violation_message = non_mcp_violations[tool_name]
        logger.warning(
            "MCP violation detected - Tool: %s, Recommendation: %s",
            tool_name,
            violation_message,
        )
        return False, violation_message

    if is_mcp_tool:
        logger.info("MCP tool usage validated - Tool: %s", tool_name)
        return True, None

    # Allow other tools that don't have MCP alternatives
    return True, None


def main():
    """Main hook execution following Claude Code hooks specification"""
    logger = setup_logging()

    try:
        # Read hook input from stdin (official Claude Code format)
        input_data = json.load(sys.stdin)

        hook_event = input_data.get("hook_event_name", "")
        tool_name = input_data.get("tool_name", "")
        tool_response = input_data.get("tool_response", {})
        session_id = input_data.get("session_id", "")

        logger.info(
            "MCP Post-Enforcement Hook triggered - Event: %s, Tool: %s, Session: %s",
            hook_event,
            tool_name,
            session_id,
        )

        # Validate MCP tool usage
        is_valid, violation_message = validate_mcp_usage(tool_name, logger)

        if not is_valid:
            # Provide feedback to Claude about MCP enforcement
            feedback_message = f"""
🚨 MCP ENFORCEMENT VIOLATION DETECTED 🚨

Tool Used: {tool_name}
Violation: {violation_message}

REMINDER: You must use MCP tools for all supported operations:
• File operations → mcp__filesystem__*
• Web research → mcp__brave-search__*  
• Documentation → mcp__context7__*
• Complex tasks → mcp__task-orchestrator__*
• Reasoning → mcp__sequential-thinking__*
• Context retention → mcp__memory__*

Please retry using the appropriate MCP tool.
            """.strip()

            # Use "block" decision to provide automatic feedback to Claude
            output = {"decision": "block", "reason": feedback_message}

            logger.warning("MCP violation feedback sent to Claude")
            print(json.dumps(output))
        else:
            # Success - log positive MCP usage
            if "mcp__" in tool_name:
                logger.info("Excellent MCP tool usage - Tool: %s", tool_name)

            # No output needed for successful validation

    except json.JSONDecodeError as e:
        logger.error("Invalid JSON input: %s", str(e))
        sys.exit(1)
    except Exception as e:
        logger.error("Error in MCP post-enforcement hook: %s", str(e))
        # Don't block on error

    # Exit code 0 indicates success
    sys.exit(0)


if __name__ == "__main__":
    main()
