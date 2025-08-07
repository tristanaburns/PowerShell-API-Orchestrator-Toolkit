#!/usr/bin/env python3
"""
MCP WORKFLOW ASSISTANT HOOK
Provides real-time MCP tool suggestions and workflow patterns
Helps Claude Code choose the optimal MCP tools for any task

Hook Type: PrePrompt / UserPromptSubmit
"""

import json
import logging
import sys
from datetime import datetime
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(".claude/hooks/logs/mcp_workflow.log", mode="a"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("MCPWorkflowAssistant")


def get_mcp_workflow_instructions():
    """Generate MCP workflow instructions based on available servers"""

    return f"""
# 🎯 MCP WORKFLOW ASSISTANT - ACTIVE AT {datetime.now().strftime('%H:%M:%S')}

## 🚀 IMMEDIATE MCP TOOL SELECTION GUIDE

### **When user mentions ANY of these keywords, USE these MCP tools:**

**📁 FILE OPERATIONS** → `filesystem MCP`
Keywords: file, read, write, directory, folder, path, save, load
- Use filesystem MCP for ALL file operations
- Store file context in memory MCP
- Chain with Context7 for file format documentation

**🌐 WEB/SEARCH OPERATIONS** → `brave-search MCP` + `browserbase MCP`
Keywords: search, web, internet, lookup, browse, website, scrape
- Use brave-search MCP for web searches
- Use browserbase MCP for web automation
- Use Context7 MCP for web technology documentation

**📚 DOCUMENTATION/LEARNING** → `Context7 MCP` + `sequential-thinking MCP`
Keywords: documentation, docs, how to, tutorial, guide, reference, API
- ALWAYS use Context7 MCP for current documentation
- Use sequential-thinking MCP for complex learning
- Store insights in memory MCP

**🏗️ CODE OPERATIONS** → `E2B MCP` + `Context7 MCP`
Keywords: code, execute, run, test, debug, compile, build
- ALWAYS use E2B MCP for code execution (never run_in_terminal)
- Use Context7 MCP for language/framework docs
- Store code patterns in memory MCP

**🎯 COMPLEX TASKS** → `task-orchestrator MCP` + Multiple tools
Keywords: complex, project, workflow, multi-step, planning, organize
- START with task-orchestrator MCP to break down tasks
- Use sequential-thinking MCP for planning
- Use memory MCP to track progress
- Chain with appropriate execution tools

**🧠 THINKING/ANALYSIS** → `sequential-thinking MCP` + `memory MCP`
Keywords: think, analyze, reason, plan, consider, evaluate, assess
- Use sequential-thinking MCP for deep reasoning
- Store thought processes in memory MCP
- Use Context7 MCP for research support

**📊 DATA OPERATIONS** → `chroma MCP` + `motherduck MCP`
Keywords: data, analytics, search, vector, database, query, analysis
- Use chroma MCP for vector operations
- Use motherduck MCP for data analytics
- Use memory MCP for data insights

**🌍 BROWSER/WEB APPS** → `browserbase MCP` + `playwright MCP`
Keywords: browser, web app, automation, testing, UI, interaction
- Use browserbase MCP for cloud browser automation
- Use playwright MCP for professional browser testing
- Store test patterns in memory MCP

**📝 PROJECT MANAGEMENT** → `notion MCP` + `linear MCP`
Keywords: project, task management, documentation, notes, organize
- Use notion MCP for documentation
- Use linear MCP for issue tracking
- Use memory MCP for project context

**⚡ AUTOMATION/INTEGRATION** → `make MCP` + `zapier MCP`
Keywords: automate, integrate, connect, workflow, process, trigger
- Use make MCP for workflow automation
- Use zapier MCP for app integrations
- Use task-orchestrator MCP for complex automation

## 🔗 STANDARD MCP WORKFLOW PATTERNS

### **RESEARCH & DOCUMENTATION PATTERN:**
```
1. Context7 MCP → Get current documentation
2. Sequential-thinking MCP → Analyze and plan
3. Memory MCP → Store insights
4. Notion MCP → Document findings
```

### **DEVELOPMENT TASK PATTERN:**
```
1. Task-orchestrator MCP → Break down development task
2. Context7 MCP → Get framework/library docs
3. Sequential-thinking MCP → Plan implementation
4. E2B MCP → Execute and test code
5. Memory MCP → Store patterns and solutions
6. Linear MCP → Track progress
```

### **DATA ANALYSIS PATTERN:**
```
1. Task-orchestrator MCP → Plan analysis approach
2. Filesystem MCP → Access data files
3. Motherduck MCP → Process and analyze data
4. Chroma MCP → Vector search for insights
5. Memory MCP → Store findings
6. Notion MCP → Document results
```

### **WEB AUTOMATION PATTERN:**
```
1. Task-orchestrator MCP → Plan automation workflow
2. Context7 MCP → Get web technology docs
3. Browserbase MCP → Execute browser automation
4. Memory MCP → Store automation patterns
5. Make/Zapier MCP → Create automated workflows
```

### **COMPLEX PROJECT PATTERN:**
```
1. Task-orchestrator MCP → Project breakdown
2. Sequential-thinking MCP → Strategic planning
3. Memory MCP → Project context management
4. Multiple execution MCPs → Implementation
5. Linear MCP → Progress tracking
6. Notion MCP → Documentation
7. Make/Zapier MCP → Process automation
```

## ⚡ INSTANT MCP TOOL MAPPING TABLE

| User Intent | Primary MCP | Secondary MCP | Support MCP |
|-------------|-------------|---------------|-------------|
| File tasks | filesystem | memory | context7 |
| Web search | brave-search | browserbase | memory |
| Code work | e2b | context7 | memory |
| Documentation | context7 | sequential-thinking | memory |
| Complex tasks | task-orchestrator | sequential-thinking | memory |
| Data analysis | chroma/motherduck | sequential-thinking | memory |
| Browser work | browserbase | playwright | memory |
| Project mgmt | notion/linear | task-orchestrator | memory |
| Automation | make/zapier | task-orchestrator | memory |
| Deep thinking | sequential-thinking | context7 | memory |

## 🎯 MCP ENFORCEMENT CHECKLIST

Before responding to ANY user request:

☐ **Identify operation type** (file, web, code, docs, task, data, etc.)
☐ **Select primary MCP tool** from the mapping above
☐ **Plan MCP tool chain** for complex operations
☐ **Include memory MCP** for context retention
☐ **AVOID basic operations** (run_in_terminal, basic file ops, etc.)
☐ **Use Context7 MCP** for any documentation needs
☐ **Consider task-orchestrator MCP** for multi-step tasks

## 🔥 CRITICAL REMINDERS

- **NEVER** use run_in_terminal for code execution → Use E2B MCP
- **NEVER** use basic file operations → Use filesystem MCP  
- **NEVER** rely on training data for docs → Use Context7 MCP
- **ALWAYS** use memory MCP to retain important context
- **ALWAYS** consider task-orchestrator MCP for complex workflows
- **ALWAYS** use sequential-thinking MCP for deep reasoning

## 🏆 MCP MASTERY GOALS

- Use **3+ MCP tools** for complex tasks
- **Chain MCP tools** logically for better results
- **Store context** in memory MCP consistently
- **Document workflows** in notion MCP
- **Automate repetitive tasks** with make/zapier MCP

**REMEMBER: You have 11+ powerful MCP servers - USE THEM STRATEGICALLY!**

---
*MCP Workflow Assistant Active - {datetime.now().isoformat()}*
"""


def main():
    """Main hook execution"""
    try:
        # Generate and output MCP workflow instructions
        workflow_instructions = get_mcp_workflow_instructions()
        print(workflow_instructions)

        logger.info("MCP workflow instructions provided")
        sys.exit(0)

    except Exception as e:
        logger.error("Error in MCP workflow assistant: %s", str(e))
        sys.exit(0)


if __name__ == "__main__":
    main()
