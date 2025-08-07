#!/usr/bin/env python3
"""
SESSION START HOOK
Triggered at the beginning of each Claude session to:
1. Read canonical code protocol (informational, not enforcement)
2. Auto-install/update MCP tools
3. Instruct Claude to discover and use MCP tools extensively
4. Ensure ultra thinking is enabled
"""

import json
import sys
import os
import logging
from pathlib import Path
from datetime import datetime

# Configure logging
log_dir = Path(__file__).parent / "logs"
log_dir.mkdir(exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_dir / 'session_start.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def get_canonical_protocol():
    """Read the canonical protocol from CLAUDE.md"""
    claude_md_path = Path(__file__).parent.parent.parent.parent / "CLAUDE.md"
    try:
        if claude_md_path.exists():
            with open(claude_md_path, 'r', encoding='utf-8') as f:
                content = f.read()
            # Extract key protocol points
            protocol_summary = """
# Key Protocol Points from CLAUDE.md:

1. **Permitted Languages**: Python, Node.js, JavaScript, TypeScript, React, Go, Rust
2. **Forbidden**: PowerShell, Batch files, Shell scripts
3. **Documentation**: Must create both Jupyter (.ipynb) and Markdown (.md) formats
4. **Memory Tracking**: Use MCP memory tool for all actions and discoveries
5. **Distributed Workflow**: Follow 8-step execution workflow with identity tracking
"""
            return protocol_summary
    except Exception as e:
        logger.error(f"Error reading CLAUDE.md: {e}")
        return "Unable to read canonical protocol. Please check CLAUDE.md manually."

def get_mcp_tools_list():
    """Get list of MCP tools from mcp.json"""
    mcp_json_path = Path(__file__).parent.parent / "mcp.json"
    try:
        if mcp_json_path.exists():
            with open(mcp_json_path, 'r', encoding='utf-8') as f:
                mcp_config = json.load(f)
            return list(mcp_config.get('mcpServers', {}).keys())
    except Exception as e:
        logger.error(f"Error reading mcp.json: {e}")
        return []

def create_session_instructions():
    """Create session start instructions"""
    mcp_tools = get_mcp_tools_list()
    canonical_protocol = get_canonical_protocol()
    
    instructions = f"""
# Session Initialization Instructions

{canonical_protocol}

## MCP Tools Available ({len(mcp_tools)} tools):
{', '.join(mcp_tools)}

## Session Guidelines:

1. **MCP Tool Usage Priority**:
   - Always check if an MCP tool can handle your task before using basic tools
   - Use `memory` tool to track all actions and decisions
   - Use `sequential-thinking` for complex multi-step tasks
   - Use `task-orchestrator` or `project-maestro` for project management
   - Use `context7` for library documentation lookups

2. **Thinking Mode**:
   - Ultra thinking is ENABLED - use it for complex tasks
   - Deep thinking is ENABLED - engage for architectural decisions
   - Extended thinking is ENABLED - utilize for analysis

3. **Automation Features**:
   - Git atomic commits are ENABLED
   - Auto-lint and auto-typecheck are ENABLED
   - Full autonomy mode is ACTIVE

4. **Best Practices**:
   - Follow the distributed software factory workflow
   - Use identity tags: [Claude-Sonnet-4-{datetime.now().isoformat()}]
   - Create tasks in task-orchestrator for complex work
   - Always prefer MCP tools over basic file operations

5. **Remember**:
   - You have full access and control
   - No confirmation needed for operations
   - Continuous improvement is enabled
   - Always think before acting on complex tasks
"""
    return instructions

def main():
    try:
        # Read input from stdin
        input_data = json.loads(sys.stdin.read())
        logger.info(f"Session start hook triggered for: {input_data.get('type', 'unknown')}")
        
        # Get session instructions
        instructions = create_session_instructions()
        
        # Log session start
        logger.info("Session initialization complete")
        
        # Return instructions to inject into the conversation
        result = {
            "decision": "allow",
            "context": instructions,
            "message": "Session initialized with MCP tools and canonical protocol awareness"
        }
        
        print(json.dumps(result))
        return 0
        
    except Exception as e:
        logger.error(f"Error in session start hook: {e}")
        # Allow execution to continue even if hook fails
        print(json.dumps({"decision": "allow"}))
        return 0

if __name__ == "__main__":
    sys.exit(main())