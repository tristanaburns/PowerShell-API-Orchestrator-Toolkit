#!/usr/bin/env python3
"""
MCP Enforcement Hook for Claude Code - UserPromptSubmit
Compliant with official Claude Code hooks specification
Injects MCP tool usage enforcement into every user prompt
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
            logging.FileHandler(log_dir / "mcp_enforcement_official.log"),
        ],
    )

    return logging.getLogger(__name__)


def main():
    """Main hook execution following Claude Code hooks specification"""
    logger = setup_logging()

    try:
        # Read hook input from stdin (official Claude Code format)
        input_data = json.load(sys.stdin)

        hook_event = input_data.get("hook_event_name", "")
        prompt = input_data.get("prompt", "")
        session_id = input_data.get("session_id", "")

        logger.info(
            f"MCP Enforcement Hook triggered - Event: {hook_event}, Session: {session_id}"
        )

        # MCP enforcement context following best practices
        mcp_enforcement_context = """
🔧 MCP TOOL ENFORCEMENT ACTIVE - MANDATORY USAGE REQUIRED

AVAILABLE MCP SERVERS (use via mcp__server__tool pattern):
✅ context7 - Documentation (Priority 4) (mcp__context7__get-library-docs)
✅ memory - Context retention (Priority 5) (mcp__memory__create_entities, mcp__memory__search_nodes)
✅ sequential-thinking - Advanced reasoning (Priority 6) (mcp__sequential-thinking__think)  
✅ task-orchestrator - Workflow management (Priority 7) (mcp__task-orchestrator__plan_task)
✅ filesystem - File operations (Priority 8) (mcp__filesystem__read_file, mcp__filesystem__write_file)
✅ fetch - Web content fetching (Priority 9) (mcp__fetch__fetch)

ENFORCEMENT PROTOCOL:
1. ALWAYS use context7 MCP for documentation and library information (Priority 4)
2. ALWAYS use memory MCP for context retention across interactions (Priority 5)
3. ALWAYS use sequential-thinking MCP for complex reasoning workflows (Priority 6)
4. ALWAYS use task-orchestrator MCP for multi-step tasks (Priority 7)
5. ALWAYS use filesystem MCP instead of basic file operations (Priority 8)
6. ALWAYS use fetch MCP for web content retrieval and webpage fetching (Priority 9)

MANDATORY WORKFLOW PATTERNS:
• Development: mcp__context7 → mcp__task-orchestrator → mcp__filesystem → mcp__memory
• Research: mcp__context7 → mcp__sequential-thinking → mcp__memory
• Analysis: mcp__sequential-thinking → mcp__filesystem → mcp__memory
• Web Tasks: mcp__fetch → mcp__context7 → mcp__memory

STRICT MODE: You must demonstrate MCP tool usage in your response.
        """.strip()

        # Use official Claude Code hooks JSON output format
        output = {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": mcp_enforcement_context,
            },
            "suppressOutput": True,  # Don't show in transcript mode
        }

        logger.info("MCP enforcement context injected via official hooks specification")
        print(json.dumps(output))

    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON input: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error in MCP enforcement hook: {e}")
        # Still allow the prompt to proceed on error

    # Exit code 0 indicates success
    sys.exit(0)


if __name__ == "__main__":
    main()
