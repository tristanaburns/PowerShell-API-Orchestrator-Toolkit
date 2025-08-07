#!/usr/bin/env python3
"""
MCP ENFORCEMENT HOOK - Forces Claude Code to prioritize MCP tools
Injects MCP tool usage instructions and workflow enforcement into every interaction

This hook ensures Claude Code ALWAYS uses MCP tools for:
- File operations (use filesystem MCP instead of basic file reads)
- Web searches (use brave-search MCP)
- Code execution (use E2B sandbox MCP)
- Documentation lookup (use Context7 MCP)
- Task orchestration (use task-orchestrator MCP)
- Memory/context retention (use memory MCP)
- Sequential reasoning (use sequential-thinking MCP)
- Browser automation (use browserbase/playwright MCP)
- Data analysis (use chroma/motherduck MCP)
- Project management (use notion/linear MCP)
- Workflow automation (use make/zapier MCP)

CANONICAL INSTRUCTION: Force MCP tool usage at all times
"""

import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(".claude/hooks/logs/mcp_enforcement.log", mode="a"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("MCPEnforcementHook")


def get_available_mcp_servers():
    """Get list of available MCP servers from configuration"""
    mcp_config_path = Path(".claude/mcp.json")
    if not mcp_config_path.exists():
        return []

    try:
        with open(mcp_config_path, "r") as f:
            config = json.load(f)

        servers = []
        for server_name, server_config in config.get("mcpServers", {}).items():
            if server_config.get("enabled", True):
                servers.append(
                    {
                        "name": server_name,
                        "description": server_config.get("description", ""),
                        "priority": server_config.get("priority", 999),
                        "category": server_config.get("category", "general"),
                    }
                )

        # Sort by priority
        servers.sort(key=lambda x: x["priority"])
        return servers
    except Exception as e:
        logger.error(f"Error reading MCP config: {e}")
        return []


def generate_mcp_enforcement_instructions():
    """Generate MCP tool enforcement instructions"""

    available_servers = get_available_mcp_servers()

    instructions = f"""
# 🚨 MCP TOOL ENFORCEMENT - MANDATORY USAGE PROTOCOL 🚨

## CRITICAL DIRECTIVE: USE MCP TOOLS FOR ALL OPERATIONS

You have access to {len(available_servers)} MCP servers that MUST be used instead of basic operations:

## 📋 MANDATORY MCP TOOL MAPPING

### **File Operations** - ALWAYS use MCP tools:
- ❌ NEVER use basic read_file, write_file, list_dir
- ✅ ALWAYS use filesystem MCP or equivalent
- ✅ Use memory MCP to persist file context

### **Web Operations** - ALWAYS use MCP tools:
- ❌ NEVER use basic web browsing
- ✅ ALWAYS use brave-search MCP for web searches
- ✅ Use browserbase/playwright MCP for web automation
- ✅ Use fetch MCP for web content retrieval

### **Code Execution** - ALWAYS use MCP tools:
- ❌ NEVER use basic terminal commands for code execution
- ✅ ALWAYS use E2B sandbox MCP for secure code execution
- ✅ Use appropriate language-specific MCP servers

### **Documentation/Research** - ALWAYS use MCP tools:
- ❌ NEVER rely on training data for current documentation
- ✅ ALWAYS use Context7 MCP for up-to-date library documentation
- ✅ Use sequential-thinking MCP for complex research

### **Task Management** - ALWAYS use MCP tools:
- ❌ NEVER handle complex tasks manually
- ✅ ALWAYS use task-orchestrator MCP for task breakdown
- ✅ Use notion/linear MCP for project management
- ✅ Use memory MCP for task context retention

### **Data Operations** - ALWAYS use MCP tools:
- ❌ NEVER use basic data processing
- ✅ ALWAYS use chroma MCP for vector operations
- ✅ Use motherduck MCP for data analytics
- ✅ Use appropriate database MCP servers

### **Workflow Automation** - ALWAYS use MCP tools:
- ❌ NEVER create manual workflows
- ✅ ALWAYS use make/zapier MCP for automation
- ✅ Use claude-swarm MCP for multi-agent coordination

## 🎯 AVAILABLE MCP SERVERS ({len(available_servers)} total):

"""

    # Group servers by category
    categories = {}
    for server in available_servers:
        category = server["category"]
        if category not in categories:
            categories[category] = []
        categories[category].append(server)

    for category, servers in categories.items():
        instructions += (
            f"\n### {category.replace('-', ' ').title()} ({len(servers)} servers):\n"
        )
        for server in servers:
            instructions += f"- **{server['name']}** (Priority {server['priority']}): {server['description']}\n"

    instructions += f"""

## 🔥 ENFORCEMENT RULES - NO EXCEPTIONS:

1. **TOOL-FIRST APPROACH**: For ANY operation, first identify the appropriate MCP tool
2. **NO BASIC OPERATIONS**: Basic file/web/terminal operations are FORBIDDEN
3. **MCP CHAIN USAGE**: Use multiple MCP tools in sequence for complex tasks
4. **MEMORY INTEGRATION**: Always use memory MCP to maintain context
5. **DOCUMENTATION LOOKUP**: Always use Context7 MCP for current documentation
6. **TASK DECOMPOSITION**: Use task-orchestrator MCP for complex tasks
7. **SEQUENTIAL THINKING**: Use sequential-thinking MCP for complex reasoning
8. **BROWSER AUTOMATION**: Use browserbase/playwright MCP for web interactions
9. **DATA PROCESSING**: Use appropriate data MCP tools for analytics
10. **WORKFLOW CREATION**: Use automation MCP tools for process creation

## 💡 MCP WORKFLOW PATTERNS:

### Complex Development Task Pattern:
1. **task-orchestrator** → Break down the task
2. **memory** → Store task context and requirements
3. **context7** → Get up-to-date documentation
4. **sequential-thinking** → Plan implementation approach
5. **e2b** → Execute code in secure sandbox
6. **browserbase** → Test web functionality
7. **notion/linear** → Document progress and results

### Research & Analysis Pattern:
1. **brave-search** → Gather current information
2. **context7** → Get technical documentation
3. **sequential-thinking** → Analyze findings
4. **memory** → Store research insights
5. **chroma** → Vector search for relevant context
6. **notion** → Document research results

### Automation & Integration Pattern:
1. **task-orchestrator** → Define automation workflow
2. **make/zapier** → Create automated processes
3. **browserbase** → Test automation
4. **memory** → Store automation patterns
5. **monitoring tools** → Track automation performance

## ⚡ IMMEDIATE MCP TOOL SELECTION CRITERIA:

When user asks for ANY operation:
1. **Identify operation type** (file, web, code, docs, task, data)
2. **Select primary MCP tool** from available servers
3. **Plan MCP tool chain** for complex operations
4. **Execute using MCP tools ONLY**
5. **Store results in memory MCP** for future reference

## 🎯 TODAY'S MCP PRIORITY FOCUS:

- **Context7**: For all documentation and library information
- **Task-Orchestrator**: For breaking down complex tasks
- **Sequential-Thinking**: For deep reasoning and planning
- **Memory**: For maintaining context across all operations
- **E2B**: For all code execution and testing
- **Browserbase**: For all web interactions and testing

## 🚨 VIOLATION PREVENTION:

If you catch yourself about to use basic operations:
1. **STOP** - Identify the appropriate MCP tool
2. **REPLACE** - Use the MCP tool instead
3. **ENHANCE** - Add memory storage and context retention
4. **CHAIN** - Use multiple MCP tools for results

**REMEMBER: You have {len(available_servers)} powerful MCP tools - USE THEM ALL THE TIME!**

---
*MCP Enforcement Hook Active - Generated at {datetime.now().isoformat()}*
"""

    return instructions


def main():
    """Main hook execution"""
    try:
        # Generate enforcement instructions
        mcp_instructions = generate_mcp_enforcement_instructions()

        # Output to stdout to inject into Claude's context
        print(mcp_instructions)

        logger.info("MCP enforcement instructions injected successfully")

        # Exit with code 0 to ensure instructions are added to context
        sys.exit(0)

    except Exception as e:
        logger.error(f"Error in MCP enforcement hook: {e}")
        # Still exit with 0 to not break the workflow
        sys.exit(0)


if __name__ == "__main__":
    main()
