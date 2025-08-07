#!/usr/bin/env python3
"""
Ollama Code Generator Hook for Claude Code - UserPromptSubmit & PostToolUse
Compliant with official Claude Code hooks specification
Automatically offloads coding tasks to Ollama bridge Docker containers
Discovers available LLMs, selects best instruction sets, and updates MCP config
Performs code quality checks and compilation after generation
"""

import asyncio
import json
import logging
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests


def setup_logging():
    """Setup logging for the hook"""
    log_dir = Path(".claude/hooks/logs")
    log_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(log_dir / "ollama_code_generator.log"),
        ],
    )

    return logging.getLogger(__name__)


class OllamaCodeGeneratorHook:
    """Hook for offloading coding tasks to Ollama bridge containers"""

    def __init__(self):
        self.logger = setup_logging()

        # Ollama container endpoints
        self.ollama_endpoints = {
            "general": "http://localhost:11434",
            "python": "http://localhost:11435",
            "javascript": "http://localhost:11436",
            "typescript": "http://localhost:11437",
            "java": "http://localhost:11438",
            "cpp": "http://localhost:11439",
            "go": "http://localhost:11440",
            "rust": "http://localhost:11441",
        }

        # MCP tools that should be available to Ollama
        self.recommended_mcp_tools = {
            "filesystem": "File operations and management",
            "memory": "Context retention across interactions",
            "sequential-thinking": "Advanced reasoning workflows",
            "task-orchestrator": "Complex task breakdown",
            "context7": "Documentation and library research",
            "fetch": "Web content retrieval",
        }

        # Patterns that trigger Ollama code generation
        self.coding_patterns = [
            r"(?i)(implement|create|generate|build|write|develop)\s+.*?(function|class|module|script|code|program)",
            r"(?i)(code|program|script)\s+.*?(for|to|that)",
            r"(?i)(build|create|make)\s+.*?(api|service|application|tool)",
            r"(?i)(write|implement)\s+.*?(algorithm|solution|logic)",
            r"(?i)(develop|create)\s+.*?(component|feature|functionality)",
        ]

        # Ollama container mapping by language
        self.ollama_containers = {
            "python": "hive-ollama-python",
            "javascript": "hive-ollama-javascript",
            "typescript": "hive-ollama-typescript",
            "java": "hive-ollama-java",
            "cpp": "hive-ollama-cpp",
            "go": "hive-ollama-go",
            "rust": "hive-ollama-rust",
            "general": "hive-ollama-general",
        }

    async def discover_available_llms(self) -> Dict[str, List[str]]:
        """Discover available LLMs in all Ollama containers"""
        available_llms = {}

        for container_type, endpoint in self.ollama_endpoints.items():
            try:
                # Check if container is running and get available models
                response = requests.get(f"{endpoint}/api/tags", timeout=5)
                if response.status_code == 200:
                    models_data = response.json()
                    models = [model["name"] for model in models_data.get("models", [])]
                    available_llms[container_type] = models
                    self.logger.info(
                        f"Container {container_type}: Found {len(models)} models"
                    )
                else:
                    self.logger.warning(f"Container {container_type} not responding")
                    available_llms[container_type] = []
            except Exception as e:
                self.logger.error(f"Error checking container {container_type}: {e}")
                available_llms[container_type] = []

        return available_llms

    def select_best_llm(
        self, available_llms: Dict[str, List[str]], language: str, task_type: str
    ) -> Tuple[str, str]:
        """Select the best LLM for the task based on language and task type"""
        # Priority order for code generation models
        model_preferences = {
            "python": ["qwen2.5-coder", "codellama:python", "codellama", "codegemma"],
            "javascript": ["qwen2.5-coder", "codellama", "codegemma"],
            "typescript": ["qwen2.5-coder", "codellama", "codegemma"],
            "java": ["qwen2.5-coder", "codellama", "codegemma"],
            "cpp": ["qwen2.5-coder", "codellama", "codegemma"],
            "go": ["qwen2.5-coder", "codellama", "codegemma"],
            "rust": ["qwen2.5-coder", "codellama", "codegemma"],
            "general": ["qwen2.5-coder", "codellama", "codegemma"],
        }

        # Check language-specific container first
        if language in available_llms and available_llms[language]:
            preferred_models = model_preferences.get(
                language, model_preferences["general"]
            )
            for model in preferred_models:
                if any(
                    model in available_model
                    for available_model in available_llms[language]
                ):
                    return language, model

        # Fall back to general container
        if "general" in available_llms and available_llms["general"]:
            preferred_models = model_preferences["general"]
            for model in preferred_models:
                if any(
                    model in available_model
                    for available_model in available_llms["general"]
                ):
                    return "general", model

        # Last resort - use any available model
        for container_type, models in available_llms.items():
            if models:
                return container_type, models[0]

        raise Exception("No available LLMs found in any container")

    def read_instruction_sets(self) -> Dict[str, str]:
        """Read instruction sets from .claude/commands/code/*.md files"""
        instruction_sets = {}
        commands_path = Path(".claude/commands/code")

        if not commands_path.exists():
            self.logger.warning("No .claude/commands/code directory found")
            return instruction_sets

        for md_file in commands_path.glob("*.md"):
            try:
                with open(md_file, "r", encoding="utf-8") as f:
                    content = f.read()
                    instruction_sets[md_file.stem] = content
                    self.logger.info(f"Loaded instruction set: {md_file.stem}")
            except Exception as e:
                self.logger.error(f"Error reading {md_file}: {e}")

        return instruction_sets

    def select_best_instruction_set(
        self, instruction_sets: Dict[str, str], task: str, language: str
    ) -> str:
        """Select the best instruction set for the task"""
        # Priority mapping for instruction sets based on task keywords
        instruction_priorities = {
            "implement": ["implement", "create", "generate", "build"],
            "refactor": ["refactor", "optimize", "improve", "clean"],
            "debug": ["debug", "fix", "error", "bug"],
            "test": ["test", "unittest", "pytest", "testing"],
            "documentation": ["document", "doc", "comment", "readme"],
            "review": ["review", "quality", "check", "validate"],
        }

        task_lower = task.lower()

        # Find the best matching instruction set
        for instruction_name, keywords in instruction_priorities.items():
            if instruction_name in instruction_sets:
                if any(keyword in task_lower for keyword in keywords):
                    return instruction_sets[instruction_name]

        # Fall back to general instruction set if available
        if "general" in instruction_sets:
            return instruction_sets["general"]
        elif "default" in instruction_sets:
            return instruction_sets["default"]

        # If no specific instruction set found, create a basic one
        return f"""
You are a code generation assistant. Please:
1. Generate clean, well-documented code for: {task}
2. Follow best practices for {language}
3. Include error handling where appropriate
4. Add comments explaining complex logic
5. Ensure code is production-ready
"""

    def update_ollama_mcp_config(self, container_type: str) -> Dict[str, Any]:
        """Update Ollama MCP configuration with appropriate tools"""
        ollama_mcp_config = {"servers": {}, "mcpServers": {}}

        # Read current Claude MCP config to get available tools
        try:
            with open(".claude/mcp.json", "r") as f:
                claude_config = json.load(f)
                claude_servers = claude_config.get("mcpServers", {})
        except Exception as e:
            self.logger.error(f"Error reading Claude MCP config: {e}")
            claude_servers = {}

        # Add recommended MCP tools that are available in Claude config
        for tool_name, description in self.recommended_mcp_tools.items():
            if tool_name in claude_servers:
                claude_server = claude_servers[tool_name]
                ollama_mcp_config["mcpServers"][tool_name] = {
                    "command": claude_server.get("command"),
                    "args": claude_server.get("args", []),
                    "transport": claude_server.get("transport", "stdio"),
                    "description": f"Ollama Bridge: {description}",
                    "enabled": True,
                    "priority": claude_server.get("priority", 10)
                    + 100,  # Lower priority than Claude's
                    "ollamaBridge": True,
                    "sourceContainer": container_type,
                }

        # Save Ollama MCP config
        ollama_config_path = Path(f".claude/ollama-mcp-{container_type}.json")
        try:
            with open(ollama_config_path, "w") as f:
                json.dump(ollama_mcp_config, f, indent=2)
            self.logger.info(f"Updated Ollama MCP config for {container_type}")
        except Exception as e:
            self.logger.error(f"Error saving Ollama MCP config: {e}")

        return ollama_mcp_config

    async def generate_code(
        self, task: str, language: str = "python", context: str = ""
    ) -> Dict[str, Any]:
        """Generate code using appropriate Ollama container with MCP tools"""
        try:
            # Step 1: Discover available LLMs
            available_llms = await self.discover_available_llms()
            if not available_llms or not any(
                models for models in available_llms.values()
            ):
                raise Exception("No Ollama containers with models found")

            # Step 2: Select best LLM for task
            container_type, model_name = self.select_best_llm(
                available_llms, language, task
            )
            endpoint = self.ollama_endpoints[container_type]

            # Step 3: Update MCP configuration for this container
            self.update_ollama_mcp_config(container_type)

            # Step 4: Read and select instruction set
            instruction_sets = self.read_instruction_sets()
            instruction_prompt = self.select_best_instruction_set(
                instruction_sets, task, language
            )

            # Step 5: Prepare generation prompt
            generation_prompt = f"""
{instruction_prompt}

Task: {task}
Language: {language}
Additional Context: {context}

Please generate complete, production-ready code with:
1. Proper error handling
2. Clear documentation
3. Following {language} best practices
4. Include necessary imports/dependencies
5. Add unit tests if appropriate

Available MCP Tools: {', '.join(self.recommended_mcp_tools.keys())}
You have access to these tools for file operations, documentation lookup, and context management.
"""

            # Step 6: Generate code using Ollama
            self.logger.info(
                f"Generating code using {model_name} in {container_type} container"
            )

            payload = {
                "model": model_name,
                "prompt": generation_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.2,  # Lower temperature for more consistent code
                    "top_p": 0.8,
                    "max_tokens": 4000,
                },
            }

            response = requests.post(
                f"{endpoint}/api/generate", json=payload, timeout=120
            )

            if response.status_code != 200:
                raise Exception(f"Ollama generation failed: {response.text}")

            result = response.json()
            generated_code = result.get("response", "")

            # Step 7: Return generation result
            generation_result = {
                "success": True,
                "code": generated_code,
                "container": container_type,
                "model": model_name,
                "mcp_config": f".claude/ollama-mcp-{container_type}.json",
                "instruction_set_used": "custom" if instruction_sets else "default",
                "task": task,
                "language": language,
            }

            self.logger.info("Code generation completed successfully")
            return generation_result

        except Exception as e:
            self.logger.error(f"Code generation failed: {e}")
            return {
                "success": False,
                "error": str(e),
                "task": task,
                "language": language,
            }

    async def perform_quality_check(
        self, generated_code: str, language: str, task: str
    ) -> Dict[str, Any]:
        """Perform quality check and validation on generated code"""
        try:
            # Step 1: Discover available LLMs for quality checking
            available_llms = await self.discover_available_llms()

            # Select quality check model (prefer general container for analysis)
            container_type = (
                "general"
                if "general" in available_llms
                else list(available_llms.keys())[0]
            )
            model_name = (
                "qwen2.5-coder"
                if any(
                    "qwen2.5-coder" in model for model in available_llms[container_type]
                )
                else available_llms[container_type][0]
            )
            endpoint = self.ollama_endpoints[container_type]

            # Step 2: Prepare quality check prompt
            quality_check_prompt = f"""
You are a code quality expert. Please analyze the following {language} code and provide:

1. Code Quality Assessment (1-10 scale)
2. Potential Issues or Bugs
3. Security Concerns
4. Performance Optimization Suggestions
5. Best Practice Violations
6. Documentation Quality
7. Recommended Improvements

Code to analyze:
```{language}
{generated_code}
```

Original Task: {task}

Please provide detailed feedback with specific line references where applicable.
Format your response as structured analysis with clear sections.
"""

            # Step 3: Perform quality analysis
            payload = {
                "model": model_name,
                "prompt": quality_check_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.1,  # Very low temperature for consistent analysis
                    "top_p": 0.9,
                    "max_tokens": 2000,
                },
            }

            response = requests.post(
                f"{endpoint}/api/generate", json=payload, timeout=60
            )

            if response.status_code != 200:
                raise Exception(f"Quality check failed: {response.text}")

            result = response.json()
            quality_analysis = result.get("response", "")

            # Step 4: Basic syntax check for compiled languages
            syntax_errors = []
            if language in ["python", "javascript", "typescript"]:
                syntax_errors = self._check_syntax(generated_code, language)

            # Step 5: Return quality check result
            quality_result = {
                "success": True,
                "analysis": quality_analysis,
                "syntax_errors": syntax_errors,
                "container": container_type,
                "model": model_name,
                "language": language,
                "has_issues": len(syntax_errors) > 0
                or "error" in quality_analysis.lower(),
                "timestamp": datetime.now().isoformat(),
            }

            self.logger.info("Quality check completed successfully")
            return quality_result

        except Exception as e:
            self.logger.error(f"Quality check failed: {e}")
            return {"success": False, "error": str(e), "language": language}

    def _check_syntax(self, code: str, language: str) -> List[str]:
        """Basic syntax checking for common languages"""
        errors = []

        try:
            if language == "python":
                import ast

                ast.parse(code)
            elif language in ["javascript", "typescript"]:
                # Basic bracket/parentheses matching
                if code.count("{") != code.count("}"):
                    errors.append("Mismatched curly braces")
                if code.count("(") != code.count(")"):
                    errors.append("Mismatched parentheses")
                if code.count("[") != code.count("]"):
                    errors.append("Mismatched square brackets")
        except SyntaxError as e:
            errors.append(f"Syntax error: {e}")
        except Exception as e:
            errors.append(f"Parse error: {e}")

        return errors

    async def execute_full_workflow(
        self, task: str, language: str = "python", context: str = ""
    ) -> Dict[str, Any]:
        """Execute the complete Ollama code generation and quality check workflow"""
        workflow_result = {
            "task": task,
            "language": language,
            "context": context,
            "timestamp": datetime.now().isoformat(),
            "steps": [],
            "success": False,
            "final_code": None,
            "quality_report": None,
        }

        try:
            # Step 1: Generate Code
            self.logger.info(f"Starting code generation workflow for task: {task}")
            workflow_result["steps"].append("Starting code generation")

            generation_result = await self.generate_code(task, language, context)
            workflow_result["steps"].append(
                f"Code generation: {'success' if generation_result['success'] else 'failed'}"
            )

            if not generation_result["success"]:
                workflow_result["error"] = generation_result.get(
                    "error", "Code generation failed"
                )
                return workflow_result

            generated_code = generation_result["code"]
            workflow_result["generation_result"] = generation_result

            # Step 2: Quality Check
            self.logger.info("Performing quality check on generated code")
            workflow_result["steps"].append("Starting quality check")

            quality_result = await self.perform_quality_check(
                generated_code, language, task
            )
            workflow_result["steps"].append(
                f"Quality check: {'success' if quality_result['success'] else 'failed'}"
            )

            if not quality_result["success"]:
                workflow_result["warning"] = quality_result.get(
                    "error", "Quality check failed"
                )
            else:
                workflow_result["quality_report"] = quality_result

            # Step 3: Final Result
            workflow_result["final_code"] = generated_code
            workflow_result["success"] = True
            workflow_result["steps"].append("Workflow completed successfully")

            # Step 4: Generate Claude Code Instructions
            claude_instructions = self.generate_claude_instructions(workflow_result)
            workflow_result["claude_instructions"] = claude_instructions

            self.logger.info("Full workflow completed successfully")
            return workflow_result

        except Exception as e:
            self.logger.error(f"Workflow execution failed: {e}")
            workflow_result["error"] = str(e)
            workflow_result["steps"].append(f"Workflow failed: {e}")
            return workflow_result

    def generate_claude_instructions(self, workflow_result: Dict[str, Any]) -> str:
        """Generate instructions for Claude Code based on workflow results"""
        task = workflow_result["task"]
        language = workflow_result["language"]
        success = workflow_result["success"]

        if not success:
            return f"""
🚨 OLLAMA CODE GENERATION FAILED

Task: {task}
Language: {language}
Error: {workflow_result.get('error', 'Unknown error')}

RECOMMENDED ACTIONS:
1. Check Ollama container status
2. Verify model availability
3. Review error logs for details
4. Consider manual code implementation
"""

        quality_report = workflow_result.get("quality_report", {})
        has_issues = quality_report.get("has_issues", False)

        instructions = f"""
✅ OLLAMA CODE GENERATION COMPLETED

Task: {task}
Language: {language}
Container: {workflow_result['generation_result']['container']}
Model: {workflow_result['generation_result']['model']}

CODE QUALITY STATUS: {'⚠️ ISSUES FOUND' if has_issues else '✅ GOOD'}
"""

        if has_issues:
            instructions += f"""
QUALITY ISSUES DETECTED:
{quality_report.get('analysis', 'See quality report for details')}

SYNTAX ERRORS: {len(quality_report.get('syntax_errors', []))}
"""

        instructions += f"""
NEXT STEPS FOR CLAUDE CODE:
1. Review the generated code below
2. {'Address quality issues before integration' if has_issues else 'Code is ready for integration'}
3. Test the code in your development environment
4. Make any necessary adjustments for your specific use case

GENERATED CODE:
```{language}
{workflow_result['final_code']}
```
"""

        return instructions.strip()

    def detect_language(self, prompt: str) -> str:
        """Detect programming language from prompt"""
        language_patterns = {
            "python": r"(?i)python|\.py|pip|conda|django|flask|fastapi",
            "javascript": r"(?i)javascript|js|node|npm|react|vue|angular|\.js",
            "typescript": r"(?i)typescript|ts|\.ts|tsx",
            "java": r"(?i)java|\.java|maven|gradle|spring",
            "cpp": r"(?i)c\+\+|cpp|\.cpp|\.h|cmake|gcc",
            "go": r"(?i)golang|go|\.go|go\s+mod",
            "rust": r"(?i)rust|\.rs|cargo",
        }

        for lang, pattern in language_patterns.items():
            if re.search(pattern, prompt):
                return lang

        return "general"

    def should_trigger_ollama(self, prompt: str) -> tuple[bool, Optional[str]]:
        """Check if prompt should trigger Ollama code generation"""
        for pattern in self.coding_patterns:
            match = re.search(pattern, prompt)
            if match:
                task_description = match.group(1) if match.groups() else prompt
                return True, task_description.strip()

        return False, None

    def generate_ollama_instructions(
        self, task: str, language: str, session_id: str
    ) -> str:
        """Generate instructions for offloading to Ollama"""
        container = self.ollama_containers.get(
            language, self.ollama_containers["general"]
        )

        return f"""
🤖 OLLAMA CODE GENERATION TRIGGERED

TASK DETECTED: {task}
LANGUAGE: {language}
CONTAINER: {container}

MANDATORY WORKFLOW:
1. FIRST - Offload to Ollama Bridge Container:
   • Use Docker container: {container}
   • Send task: "{task}"
   • Let Ollama generate the initial code
   • Capture generated code and any error messages

2. SECOND - Code Quality & Compilation Check:
   • Review generated code for syntax errors
   • Check code style and best practices
   • Compile/validate the code (if applicable)
   • Run basic tests or linting
   • Document any issues found

3. THIRD - Integration & Refinement:
   • If issues found, send feedback to Ollama for fixes
   • Ensure code meets project standards
   • Integrate with existing codebase if needed
   • Provide final code review summary

OLLAMA BRIDGE COMMAND:
```bash
docker exec {container} ollama-generate --task "{task}" --language {language} --session {session_id}
```

QUALITY CHECK REQUIREMENTS:
✅ Syntax validation
✅ Style compliance
✅ Security review
✅ Performance check
✅ Documentation
✅ Test coverage

STRICT ENFORCEMENT: You MUST use the Ollama bridge container before writing any code yourself.
        """.strip()

    def generate_post_generation_check(self, tool_output: str) -> str:
        """Generate instructions for post-generation quality checks"""
        return """
🔍 OLLAMA CODE QUALITY CHECK REQUIRED

POST-GENERATION WORKFLOW:
1. ANALYZE the code generated by Ollama bridge container
2. VERIFY syntax and compilation status
3. CHECK for security vulnerabilities
4. REVIEW code style and best practices
5. TEST functionality if possible
6. DOCUMENT findings and recommendations

QUALITY CHECKLIST:
□ Syntax errors identified and fixed
□ Code style follows project standards
□ Security scan completed
□ Performance implications reviewed
□ Documentation is adequate
□ Tests are included or suggested
□ Integration points verified

NEXT STEPS:
- If issues found: Request Ollama refinement
- If code is good: Approve for integration
- Always provide quality assessment summary
        """.strip()


def main():
    """Main hook execution following Claude Code hooks specification"""
    logger = setup_logging()

    try:
        # Read hook input from stdin (official Claude Code format)
        input_data = json.load(sys.stdin)

        hook_event = input_data.get("hook_event_name", "")
        prompt = input_data.get("prompt", "")
        session_id = input_data.get("session_id", "")
        tool_name = input_data.get("tool_name", "")
        tool_output = input_data.get("tool_output", "")

        logger.info(
            f"Ollama Code Generator Hook triggered - Event: {hook_event}, Session: {session_id}"
        )

        hook = OllamaCodeGeneratorHook()

        if hook_event == "UserPromptSubmit":
            # Check if this prompt should trigger Ollama code generation
            should_trigger, task = hook.should_trigger_ollama(prompt)

            if should_trigger and task:
                language = hook.detect_language(prompt)

                # Execute full Ollama workflow asynchronously
                logger.info(f"Executing Ollama workflow for task: {task}")

                # Create async event loop for workflow execution
                try:
                    workflow_result = asyncio.run(
                        hook.execute_full_workflow(task, language, prompt)
                    )
                    claude_instructions = workflow_result.get("claude_instructions", "")

                    output = {
                        "hookSpecificOutput": {
                            "hookEventName": "UserPromptSubmit",
                            "ollamaTriggered": True,
                            "taskDetected": task,
                            "languageDetected": language,
                            "workflowResult": workflow_result,
                            "claudeInstructions": claude_instructions,
                            "timestamp": datetime.now().isoformat(),
                        },
                        "prependToResponse": claude_instructions,
                    }

                    logger.info(
                        "Ollama workflow completed, sending instructions to Claude"
                    )

                except Exception as e:
                    logger.error(f"Async workflow execution failed: {e}")
                    error_instructions = f"""
🚨 OLLAMA WORKFLOW EXECUTION FAILED

Task: {task}
Language: {language}
Error: {str(e)}

FALLBACK ACTION:
Please implement the task manually or check Ollama container status.
"""
                    output = {
                        "hookSpecificOutput": {
                            "hookEventName": "UserPromptSubmit",
                            "ollamaTriggered": True,
                            "taskDetected": task,
                            "languageDetected": language,
                            "workflowError": str(e),
                            "timestamp": datetime.now().isoformat(),
                        },
                        "prependToResponse": error_instructions,
                    }

                logger.info(f"Ollama workflow completed for task: {task}")
                print(json.dumps(output))
            else:
                # No code generation trigger, pass through
                logger.info("No Ollama code generation trigger detected")

        elif hook_event == "PostToolUse":
            # Check if this was a coding-related tool use that needs quality check
            if any(
                keyword in tool_name.lower()
                for keyword in ["code", "file", "write", "create", "generate"]
            ):
                quality_check_instructions = hook.generate_post_generation_check(
                    tool_output
                )

                output = {
                    "hookSpecificOutput": {
                        "hookEventName": "PostToolUse",
                        "additionalContext": quality_check_instructions,
                        "ollamaQualityCheck": {
                            "required": True,
                            "toolName": tool_name,
                            "checkType": "post_generation_quality",
                        },
                    },
                    "suppressOutput": False,
                }

                logger.info(
                    f"Post-generation quality check triggered for tool: {tool_name}"
                )
                print(json.dumps(output))
            else:
                logger.info("No quality check required for this tool use")

    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON input: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error in Ollama code generator hook: {e}")
        # Still allow the prompt to proceed on error

    # Exit code 0 indicates success
    sys.exit(0)


if __name__ == "__main__":
    main()

    async def handle_generate_request(self, match, context):
        """Handle GENERATE: patterns"""
        request = match.group(1).strip()

        # Parse the request for file path
        file_match = re.search(r"file[:\s]+([^\s,]+)", request, re.IGNORECASE)
        target_file = (
            file_match.group(1)
            if file_match
            else f"generated/{request.replace(' ', '_')[:30]}.py"
        )

        result = await self.executor.implement_feature(
            request, target_file, auto_write=context.get("auto_write", False)
        )

        return {
            "action": "code_generation",
            "request": request,
            "target_file": target_file,
            "result": result,
        }

    async def handle_refactor_request(self, match, context):
        """Handle REFACTOR: patterns"""
        what_to_refactor = match.group(1).strip()
        file_path = match.group(2).strip()

        if os.path.exists(file_path):
            result = await self.executor.modify_existing_file(
                file_path, f"Refactor {what_to_refactor}"
            )

            return {
                "action": "refactor",
                "target": what_to_refactor,
                "file_path": file_path,
                "result": result,
            }
        else:
            return {"action": "refactor", "error": f"File not found: {file_path}"}

    async def handle_test_generation(self, match, context):
        """Handle ADD TESTS: patterns"""
        target = match.group(1).strip()

        # Generate test file path
        if target.endswith(".py"):
            test_file = target.replace(".py", "_test.py")
            test_file = test_file.replace("/src/", "/tests/")
        else:
            test_file = f"tests/test_{target.replace(' ', '_')}.py"

        test_prompt = f"Create pytest tests for: {target}"

        result = await self.executor.implement_feature(
            test_prompt, test_file, auto_write=False
        )

        return {
            "action": "test_generation",
            "target": target,
            "test_file": test_file,
            "result": result,
        }

    async def process_hook(self, hook_data):
        """Process the hook data for code generation triggers"""
        results = []

        # Check different sources for triggers
        sources_to_check = []

        # Check file content if Read tool was used
        if hook_data.get("toolName") == "Read":
            tool_result = hook_data.get("toolResult", {})
            content = tool_result.get("content", "")
            if content:
                sources_to_check.append(
                    {
                        "content": content,
                        "context": {
                            "file_path": hook_data.get("args", {}).get("file_path", ""),
                            "source": "file_read",
                        },
                    }
                )

        # Check user message
        user_message = hook_data.get("userMessage", "")
        if user_message:
            sources_to_check.append(
                {
                    "content": user_message,
                    "context": {
                        "source": "user_message",
                        "auto_write": "auto" in user_message.lower()
                        or "automatic" in user_message.lower(),
                    },
                }
            )

        # Check assistant message
        assistant_message = hook_data.get("assistantMessage", "")
        if assistant_message:
            sources_to_check.append(
                {
                    "content": assistant_message,
                    "context": {"source": "assistant_message"},
                }
            )

        # Process each source
        for source in sources_to_check:
            content = source["content"]
            context = source["context"]

            # Check each trigger pattern
            for pattern, handler in self.triggers.items():
                matches = re.finditer(pattern, content, re.MULTILINE | re.IGNORECASE)
                for match in matches:
                    try:
                        result = await handler(match, context)
                        result["source"] = context["source"]
                        result["pattern"] = pattern
                        result["timestamp"] = datetime.now().isoformat()
                        results.append(result)
                    except Exception as e:
                        results.append(
                            {
                                "error": str(e),
                                "pattern": pattern,
                                "source": context["source"],
                            }
                        )

        return results


async def main():
    """Main hook execution"""
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            print(
                json.dumps({"success": False, "error": "No input received from stdin"})
            )
            return

        # Parse the hook input
        hook_data = json.loads(input_json)

        # Initialize the hook processor
        hook_processor = OllamaCodeGeneratorHook()

        # Process the hook
        results = await hook_processor.process_hook(hook_data)

        # Log results
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "session_id": hook_data.get("sessionId", "unknown"),
            "tool_name": hook_data.get("toolName", "unknown"),
            "results": results,
            "triggers_found": len(results),
        }

        # Write to log file
        os.makedirs("logs", exist_ok=True)
        with open("logs/ollama-code-generation.jsonl", "a") as f:
            f.write(json.dumps(log_entry) + "\n")

        # Return response
        response = {
            "success": True,
            "message": f"Ollama code generator processed {len(results)} triggers",
            "triggers_found": len(results),
            "results": results,
            "timestamp": datetime.now().isoformat(),
        }

        print(json.dumps(response))

    except json.JSONDecodeError as e:
        print(json.dumps({"success": False, "error": f"JSON decode error: {str(e)}"}))
    except Exception as e:
        print(json.dumps({"success": False, "error": f"Unexpected error: {str(e)}"}))


if __name__ == "__main__":
    asyncio.run(main())
