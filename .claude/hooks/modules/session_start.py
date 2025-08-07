"""
Session Start Module
Handles initialization when a Claude session begins
"""

import json
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, Any
from . import smart_init

logger = logging.getLogger(__name__)

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle session start event"""
    logger.info(f"Session start handler called for {event_type}")
    
    # Check if init is needed
    init_result = smart_init.handle(event_type, input_data)
    init_message = init_result.get('context', '')
    
    # Get available MCP tools
    mcp_tools = get_mcp_tools()
    
    # Create session instructions
    instructions = f"""
# Session Initialized

## Available MCP Tools ({len(mcp_tools)}):
{', '.join(mcp_tools)}

## Session Configuration:
- Ultra thinking: ENABLED
- Deep thinking: ENABLED
- Extended thinking: ENABLED
- Full autonomy: ACTIVE
- Git atomic commits: ENABLED

## Remember:
- Prioritize MCP tools over basic operations
- Use memory tool to track all actions
- Use sequential-thinking for complex tasks
- Identity: [Claude-Sonnet-4-{datetime.now().isoformat()}]

## Task Delegation:
- Use IMPLEMENT_FUNCTION: for new functions
- Use WRITE_TESTS: for test generation
- Use FIX_BUG: for bug fixes
- Use CREATE_API: for API endpoints
- Small tasks will be delegated to Ollama automatically
"""
    
    # Combine init message with session instructions
    full_context = init_message + instructions if init_message else instructions
    
    return {
        "permissionDecision": "allow",
        "context": full_context
    }

def get_mcp_tools() -> list:
    """Get list of available MCP tools"""
    try:
        mcp_json = Path(__file__).parent.parent.parent / "mcp.json"
        if mcp_json.exists():
            with open(mcp_json, 'r') as f:
                config = json.load(f)
                return list(config.get('mcpServers', {}).keys())
    except Exception as e:
        logger.error(f"Error reading MCP tools: {e}")
    return []