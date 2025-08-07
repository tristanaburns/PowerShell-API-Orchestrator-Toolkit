#!/usr/bin/env python3
"""
Ultrathink Hook for Claude Code (Sonnet 4 Optimized)
====================================================

This hook enables ultra-thinking capabilities for Claude Sonnet 4, providing
deep analysis, reasoning, and advanced problem-solving.

Features:
- Multi-layered thinking processes with Sonnet 4 optimization
- Advanced reasoning chains leveraging 200K context
- Deep context analysis with extended thinking
- Strategic planning enhancement
- Complex problem decomposition
- Enhanced decision-making support
- Sonnet 4 specific optimizations

Environment Variables:
- CLAUDE_ULTRATHINK_ENABLED: Enable/disable ultrathink mode
- CLAUDE_USE_SONNET_4: Enable Sonnet 4 specific features
- CLAUDE_THINKING_MODE: Set thinking depth (ultra, deep, standard)
- CLAUDE_MODEL: Specify Claude model (claude-sonnet-4-20250514)
- CLAUDE_ADVANCED_REASONING: Enable advanced reasoning features
- CLAUDE_EXTENDED_THINKING: Enable extended thinking capabilities
"""

import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path

# Setup logging
log_dir = Path(".claude/logs")
log_dir.mkdir(exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(log_dir / "ultrathink_hook.log"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("ultrathink_hook")


def check_environment():
    """Check if ultrathink is enabled and environment is configured."""
    ultrathink_enabled = os.getenv("CLAUDE_ULTRATHINK_ENABLED", "0") == "1"
    thinking_mode = os.getenv("CLAUDE_THINKING_MODE", "standard")
    model = os.getenv("CLAUDE_MODEL", "")
    advanced_reasoning = os.getenv("CLAUDE_ADVANCED_REASONING", "0") == "1"

    logger.info(f"Ultrathink enabled: {ultrathink_enabled}")
    logger.info(f"Thinking mode: {thinking_mode}")
    logger.info(f"Model: {model}")
    logger.info(f"Advanced reasoning: {advanced_reasoning}")

    return ultrathink_enabled and thinking_mode in ["ultra", "deep"]


def get_user_input():
    """Get user input from environment or stdin."""
    user_input = os.getenv("CLAUDE_USER_INPUT", "")
    if not user_input and len(sys.argv) > 1:
        user_input = " ".join(sys.argv[1:])

    logger.info(f"Processing input length: {len(user_input)} characters")
    return user_input


def analyze_complexity(user_input):
    """Analyze input complexity to determine thinking depth needed."""
    complexity_indicators = [
        "analyze",
        "complex",
        "comprehensive",
        "detailed",
        "thorough",
        "strategy",
        "architecture",
        "design",
        "optimization",
        "refactor",
        "implement",
        "troubleshoot",
        "debug",
        "performance",
        "security",
        "integration",
        "workflow",
        "automation",
        "documentation",
        "testing",
    ]

    complexity_score = sum(
        1
        for indicator in complexity_indicators
        if indicator.lower() in user_input.lower()
    )

    # Additional complexity factors
    if len(user_input) > 500:
        complexity_score += 2
    if "?" in user_input:
        complexity_score += 1
    if any(
        word in user_input.lower() for word in ["how", "why", "what", "where", "when"]
    ):
        complexity_score += 1

    logger.info(f"Complexity score: {complexity_score}")
    return complexity_score


def generate_thinking_prompts(user_input, complexity_score):
    """Generate thinking enhancement prompts based on input complexity."""
    base_prompts = [
        "Before responding, engage in analysis of the user's request.",
        "Consider multiple perspectives and potential approaches to this problem.",
        "Think through the implications and consequences of different solutions.",
    ]

    if complexity_score >= 5:
        advanced_prompts = [
            "Break down this complex problem into smaller, manageable components.",
            "Consider the broader context and long-term implications of your response.",
            "Evaluate potential risks, benefits, and trade-offs of different approaches.",
            "Think about edge cases, error conditions, and alternative scenarios.",
            "Consider how this solution fits into the larger system architecture.",
        ]
        base_prompts.extend(advanced_prompts)

    if complexity_score >= 8:
        ultra_prompts = [
            "Engage in multi-layered reasoning, considering technical, business, and user perspectives.",
            "Perform a thorough analysis of requirements, constraints, and success criteria.",
            "Consider scalability, maintainability, and future extensibility in your approach.",
            "Think about testing strategies, documentation needs, and deployment considerations.",
            "Evaluate security implications and performance optimization opportunities.",
        ]
        base_prompts.extend(ultra_prompts)

    return base_prompts


def inject_sonnet_optimizations():
    """Inject Sonnet-specific optimization prompts."""
    sonnet_prompts = [
        "Leverage Claude Sonnet's advanced reasoning capabilities for this analysis.",
        "Use systematic thinking and structured problem-solving approaches.",
        "Consider both immediate solutions and strategic long-term planning.",
        "Apply best practices from software engineering, architecture, and design patterns.",
    ]
    return sonnet_prompts


def create_ultrathink_context(user_input):
    """Create enhanced context for ultrathinking."""
    complexity_score = analyze_complexity(user_input)
    thinking_prompts = generate_thinking_prompts(user_input, complexity_score)
    sonnet_prompts = inject_sonnet_optimizations()

    context = {
        "timestamp": datetime.now().isoformat(),
        "thinking_mode": "ultra",
        "complexity_score": complexity_score,
        "model_optimizations": "sonnet",
        "thinking_prompts": thinking_prompts,
        "sonnet_prompts": sonnet_prompts,
        "reasoning_depth": "comprehensive" if complexity_score >= 5 else "standard",
        "analysis_type": "multi-perspective" if complexity_score >= 8 else "focused",
    }

    return context


def save_thinking_context(context):
    """Save thinking context for reference."""
    context_dir = Path(".claude/contexts")
    context_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    context_file = context_dir / f"ultrathink_context_{timestamp}.json"

    with open(context_file, "w") as f:
        json.dump(context, f, indent=2)

    logger.info(f"Thinking context saved to: {context_file}")


def inject_thinking_enhancement():
    """Inject thinking enhancement into the conversation context."""
    thinking_enhancement = """
[ULTRATHINK MODE ACTIVATED - CLAUDE SONNET]

🧠 ANALYSIS MODE
• Engage multi-layered reasoning
• Consider technical, business, and user perspectives
• Analyze requirements, constraints, and success criteria
• Evaluate risks, benefits, and trade-offs
• Think through edge cases and alternative scenarios

🎯 STRATEGIC THINKING
• Break complex problems into manageable components
• Consider broader context and long-term implications
• Plan for scalability, maintainability, and extensibility
• Think about testing, documentation, and deployment
• Evaluate security and performance implications

⚡ SONNET OPTIMIZATION
• Leverage advanced reasoning capabilities
• Apply systematic problem-solving approaches
• Use structured analysis and design patterns
• Consider immediate solutions and strategic planning
• Integrate best practices from software engineering

🔍 ANALYSIS DEPTH: ULTRA
Ready to provide, well-reasoned responses with deep technical insight.
"""

    # Output thinking enhancement to be captured by Claude Code
    print(thinking_enhancement)
    logger.info("Ultrathink enhancement injected successfully")


def main():
    """Main ultrathink hook execution."""
    try:
        logger.info("=== Ultrathink Hook Started ===")

        # Check if ultrathink is enabled
        if not check_environment():
            logger.info("Ultrathink not enabled or configured, skipping")
            return 0

        # Get user input
        user_input = get_user_input()
        if not user_input:
            logger.warning("No user input provided")
            return 0

        # Create ultrathink context
        context = create_ultrathink_context(user_input)
        logger.info(
            f"Created context with complexity score: {context['complexity_score']}"
        )

        # Save context for reference
        save_thinking_context(context)

        # Inject thinking enhancement
        inject_thinking_enhancement()

        logger.info("=== Ultrathink Hook Completed Successfully ===")
        return 0

    except Exception as e:
        logger.error(f"Ultrathink hook failed: {str(e)}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
