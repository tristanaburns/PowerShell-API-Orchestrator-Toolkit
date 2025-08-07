#!/usr/bin/env python3
"""
POST-PROMPT MCP ENFORCEMENT HOOK
Runs after each user prompt to ensure MCP tools were used appropriately
Provides feedback and suggestions for better MCP tool utilization

Hook Type: UserPromptSubmit
"""

import json
import logging
import re
import sys
from datetime import datetime
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(".claude/hooks/logs/mcp_post_enforcement.log", mode="a"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("MCPPostEnforcementHook")


def analyze_response_for_mcp_usage(response_text):
    """Analyze Claude's response for MCP tool usage patterns"""

    # Common MCP tool indicators
    mcp_indicators = {
        "filesystem": ["read_file", "write_file", "list_directory"],
        "memory": ["mcp_memory", "create_entities", "search_nodes"],
        "context7": ["context7", "get-library-docs", "resolve-library-id"],
        "sequential-thinking": ["sequential", "thinking", "thought"],
        "task-orchestrator": ["orchestrator", "plan_task", "execute_subtask"],
        "browserbase": ["browserbase", "browser automation"],
        "e2b": ["e2b", "sandbox", "code execution"],
        "brave-search": ["brave", "web search"],
        "chroma": ["chroma", "vector search"],
        "notion": ["notion", "documentation"],
        "linear": ["linear", "project management"],
        "make": ["make", "workflow"],
        "zapier": ["zapier", "automation"],
    }

    # Basic operation indicators (should be avoided)
    basic_operations = [
        "run_in_terminal",
        "basic file operations",
        "manual web browsing",
        "simple terminal commands",
    ]

    used_mcp_tools = []
    used_basic_ops = []

    response_lower = response_text.lower()

    # Check for MCP tool usage
    for tool, indicators in mcp_indicators.items():
        for indicator in indicators:
            if indicator in response_lower:
                if tool not in used_mcp_tools:
                    used_mcp_tools.append(tool)

    # Check for basic operations
    for basic_op in basic_operations:
        if basic_op in response_lower:
            used_basic_ops.append(basic_op)

    return used_mcp_tools, used_basic_ops


def generate_mcp_feedback(used_mcp_tools, used_basic_ops, user_prompt):
    """Generate feedback on MCP tool usage"""

    feedback = "\n" + "=" * 80 + "\n"
    feedback += "🤖 MCP TOOL USAGE ANALYSIS & RECOMMENDATIONS\n"
    feedback += "=" * 80 + "\n"

    # Positive feedback for MCP usage
    if used_mcp_tools:
        feedback += f"✅ **EXCELLENT!** Used {len(used_mcp_tools)} MCP tools: {', '.join(used_mcp_tools)}\n\n"
    else:
        feedback += "⚠️ **WARNING:** No MCP tools detected in response!\n\n"

    # Warnings for basic operations
    if used_basic_ops:
        feedback += f"❌ **AVOID THESE:** Detected basic operations: {', '.join(used_basic_ops)}\n"
        feedback += "💡 **RECOMMENDATION:** Replace with appropriate MCP tools\n\n"

    # Task-specific MCP recommendations
    user_prompt_lower = user_prompt.lower()
    recommendations = []

    if any(
        word in user_prompt_lower for word in ["file", "read", "write", "directory"]
    ):
        if "filesystem" not in used_mcp_tools:
            recommendations.append("📁 Use **filesystem MCP** for file operations")

    if any(
        word in user_prompt_lower for word in ["search", "web", "internet", "lookup"]
    ):
        if "brave-search" not in used_mcp_tools:
            recommendations.append("🌐 Use **brave-search MCP** for web searches")
        if "context7" not in used_mcp_tools:
            recommendations.append("📚 Use **Context7 MCP** for documentation lookup")

    if any(word in user_prompt_lower for word in ["code", "execute", "run", "test"]):
        if "e2b" not in used_mcp_tools:
            recommendations.append("🏗️ Use **E2B MCP** for secure code execution")

    if any(
        word in user_prompt_lower for word in ["task", "complex", "project", "workflow"]
    ):
        if "task-orchestrator" not in used_mcp_tools:
            recommendations.append(
                "🎯 Use **task-orchestrator MCP** for complex task management"
            )

    if any(
        word in user_prompt_lower for word in ["remember", "context", "store", "memory"]
    ):
        if "memory" not in used_mcp_tools:
            recommendations.append("🧠 Use **memory MCP** for context retention")

    if any(
        word in user_prompt_lower for word in ["think", "analyze", "reason", "plan"]
    ):
        if "sequential-thinking" not in used_mcp_tools:
            recommendations.append(
                "🤔 Use **sequential-thinking MCP** for deep reasoning"
            )

    if any(
        word in user_prompt_lower
        for word in ["browser", "web app", "automation", "scrape"]
    ):
        if "browserbase" not in used_mcp_tools:
            recommendations.append("🌍 Use **browserbase MCP** for browser automation")

    if any(
        word in user_prompt_lower for word in ["data", "analytics", "vector", "search"]
    ):
        if "chroma" not in used_mcp_tools:
            recommendations.append(
                "📊 Use **chroma MCP** for vector operations and data analytics"
            )

    if any(
        word in user_prompt_lower for word in ["document", "note", "wiki", "knowledge"]
    ):
        if "notion" not in used_mcp_tools:
            recommendations.append("📝 Use **notion MCP** for documentation management")

    if any(word in user_prompt_lower for word in ["automate", "integrate", "connect"]):
        if "make" not in used_mcp_tools and "zapier" not in used_mcp_tools:
            recommendations.append("⚡ Use **make/zapier MCP** for workflow automation")

    # Display recommendations
    if recommendations:
        feedback += "💡 **NEXT TIME, CONSIDER THESE MCP TOOLS:**\n"
        for rec in recommendations:
            feedback += f"   {rec}\n"
        feedback += "\n"

    # MCP tool chaining suggestions
    if len(used_mcp_tools) < 2 and len(recommendations) > 1:
        feedback += "🔗 **MCP TOOL CHAINING OPPORTUNITY:**\n"
        feedback += (
            "   Consider using multiple MCP tools in sequence for better results!\n"
        )
        feedback += "   Example: Context7 → Sequential-Thinking → Task-Orchestrator → Memory\n\n"

    # Score and encouragement
    mcp_score = len(used_mcp_tools) * 10 - len(used_basic_ops) * 5
    mcp_score = max(0, mcp_score)

    if mcp_score >= 30:
        feedback += f"🏆 **MCP MASTERY LEVEL:** {mcp_score}/100 - EXCELLENT!\n"
    elif mcp_score >= 20:
        feedback += f"🥉 **MCP USAGE LEVEL:** {mcp_score}/100 - Good, but room for improvement!\n"
    elif mcp_score >= 10:
        feedback += f"📈 **MCP USAGE LEVEL:** {mcp_score}/100 - Getting better!\n"
    else:
        feedback += f"🎯 **MCP USAGE LEVEL:** {mcp_score}/100 - Focus on using more MCP tools!\n"

    feedback += (
        "\n🚀 **REMEMBER:** Always prioritize MCP tools for better capabilities!\n"
    )
    feedback += "=" * 80 + "\n"

    return feedback


def main():
    """Main hook execution"""
    try:
        # Get the user prompt and response from hook context
        # In a real hook, this would come from the hook's stdin/environment
        # For now, we'll generate general MCP enforcement reminders

        mcp_reminder = f"""

🔥 **MCP TOOL ENFORCEMENT REMINDER** - {datetime.now().strftime('%H:%M:%S')}

## Quick MCP Tool Reference:

📁 **Files**: Use filesystem MCP instead of basic file operations
🌐 **Web**: Use brave-search MCP instead of basic web browsing  
📚 **Docs**: Use Context7 MCP for up-to-date documentation
🏗️ **Code**: Use E2B MCP for secure code execution
🎯 **Tasks**: Use task-orchestrator MCP for complex workflows
🧠 **Memory**: Use memory MCP to retain context
🤔 **Thinking**: Use sequential-thinking MCP for deep reasoning
🌍 **Browser**: Use browserbase MCP for web automation
📊 **Data**: Use chroma/motherduck MCP for analytics
📝 **Docs**: Use notion/linear MCP for project management
⚡ **Automation**: Use make/zapier MCP for workflows

## MCP-First Mindset:
1. **Identify** the operation type
2. **Select** appropriate MCP tool(s)
3. **Chain** multiple tools for complex tasks
4. **Store** results in memory MCP
5. **Document** in notion/linear MCP

**Always ask: "What MCP tool should I use for this?"**

"""

        print(mcp_reminder)
        logger.info("MCP enforcement reminder generated")

        sys.exit(0)

    except Exception as e:
        logger.error("Error in MCP post-enforcement hook: %s", str(e))
        sys.exit(0)


if __name__ == "__main__":
    main()
