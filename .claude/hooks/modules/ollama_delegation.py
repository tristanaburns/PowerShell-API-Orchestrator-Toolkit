"""
Ollama Delegation Module
Manages task delegation to Ollama LLMs and result collection
"""

import json
import logging
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional, List
import requests
import time
import asyncio
import aiohttp
from concurrent.futures import ThreadPoolExecutor
try:
    from . import canonical_protocol_enforcer
    from . import ollama_feedback_loop
    from . import ollama_mcp_config
except ImportError:
    # Direct import for testing
    import canonical_protocol_enforcer
    import ollama_feedback_loop
    import ollama_mcp_config

logger = logging.getLogger(__name__)

class OllamaDelegation:
    """Handles delegation of coding tasks to Ollama"""
    
    def __init__(self):
        self.ollama_url = "http://localhost:11444"  # Container port
        self.results_dir = Path(__file__).parent.parent / "ollama_results"
        self.results_dir.mkdir(exist_ok=True)
        # Cache for model context sizes to avoid repeated API calls
        self._model_context_cache = {}
    
    async def delegate_to_ollama_async(self, work_package: Dict[str, Any]) -> Dict[str, Any]:
        """Send work package to Ollama for implementation (async version)"""
        # Apply MCP configuration
        work_package = ollama_mcp_config.integrate_mcp_config(work_package)
        
        # Apply canonical protocol enforcement
        enforcer = canonical_protocol_enforcer.CanonicalProtocolEnforcer()
        work_package = canonical_protocol_enforcer.integrate_canonical_enforcement(work_package)
        
        # Apply feedback loop enhancements
        work_package = ollama_feedback_loop.integrate_feedback_loop(work_package)
        
        # Get the best model for the task
        model = self.select_best_model(work_package)
        work_package["selected_model"] = model
        
        # Use the canonical prompt which includes FORBIDDEN, MUST, SHALL, MCP instructions etc.
        prompt = work_package.get("canonical_prompt", self.create_prompt(work_package))
        
        try:
            # Call Ollama API asynchronously with timeout
            timeout = aiohttp.ClientTimeout(total=120)  # 2 minute timeout
            async with aiohttp.ClientSession(timeout=timeout) as session:
                async with session.post(
                    f"{self.ollama_url}/api/generate",
                    json={
                        "model": model,
                        "prompt": prompt,
                        "stream": False,
                        "tools": [
                            {
                                "type": "function",
                                "function": {
                                    "name": "write_file",
                                    "description": "Write content to a file",
                                    "parameters": {
                                        "type": "object",
                                        "properties": {
                                            "path": {"type": "string", "description": "File path to write to"},
                                            "content": {"type": "string", "description": "Content to write to file"}
                                        },
                                        "required": ["path", "content"]
                                    }
                                }
                            },
                            {
                                "type": "function", 
                                "function": {
                                    "name": "read_file",
                                    "description": "Read file contents",
                                    "parameters": {
                                        "type": "object",
                                        "properties": {
                                            "path": {"type": "string", "description": "File path to read"}
                                        },
                                        "required": ["path"]
                                    }
                                }
                            }
                        ],
                        "options": {
                            "temperature": 0.7,
                            "top_p": 0.9,
                            "num_predict": 4096,  # Output tokens
                            "num_ctx": self._get_max_context_for_model(model)  # Use maximum context
                        }
                    }
                ) as response:
                    
                    if response.status == 200:
                        result = await response.json()
                        
                        # Check if Qwen used tool calls
                        if "tool_calls" in result:
                            await self._handle_tool_calls(result["tool_calls"])
                        
                        code = self.extract_code(result["response"])
                        
                        # Save generated code
                        output_file = self.save_code(work_package, code)
                        
                        # Run quality checks on generated code (in thread pool to avoid blocking)
                        loop = asyncio.get_event_loop()
                        with ThreadPoolExecutor() as executor:
                            quality_result = await loop.run_in_executor(
                                executor, 
                                self.run_quality_checks, 
                                output_file, 
                                work_package["context"]["language"]
                            )
                        
                        # Run second validation prompt (async)
                        validation_result = await self.validate_with_second_prompt_async(code, work_package)
                        
                        # Determine overall success based on both checks
                        overall_success = (
                            quality_result.get("overall_passed", False) and 
                            validation_result.get("is_valid", False)
                        )
                        
                        return {
                            "success": overall_success,
                            "code": code,
                            "output_file": str(output_file),
                            "model": model,
                            "generation_time": result.get("total_duration", 0) / 1e9,  # Convert to seconds
                            "quality_checks": quality_result,
                            "validation_result": validation_result,
                            "validation_passed": validation_result.get("is_valid", False)
                        }
                    else:
                        return {
                            "success": False,
                            "error": f"Ollama API error: {response.status}"
                        }
                        
        except Exception as e:
            logger.error(f"Ollama delegation failed: {e}")
            return {
                "success": False,
                "error": str(e)
            }

    def delegate_to_ollama(self, work_package: Dict[str, Any]) -> Dict[str, Any]:
        """Send work package to Ollama for implementation"""
        # Apply MCP configuration
        work_package = ollama_mcp_config.integrate_mcp_config(work_package)
        
        # Apply canonical protocol enforcement
        enforcer = canonical_protocol_enforcer.CanonicalProtocolEnforcer()
        work_package = canonical_protocol_enforcer.integrate_canonical_enforcement(work_package)
        
        # Apply feedback loop enhancements
        work_package = ollama_feedback_loop.integrate_feedback_loop(work_package)
        
        # Get the best model for the task
        model = self.select_best_model(work_package)
        work_package["selected_model"] = model
        
        # Use the canonical prompt which includes FORBIDDEN, MUST, SHALL, MCP instructions etc.
        prompt = work_package.get("canonical_prompt", self.create_prompt(work_package))
        
        try:
            # Call Ollama API
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": model,
                    "prompt": prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.7,
                        "top_p": 0.9,
                        "num_predict": 4096,  # Use num_predict instead of max_tokens
                        "num_ctx": self._get_max_context_for_model(model)  # Use maximum context
                    }
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                code = self.extract_code(result["response"])
                
                # Save generated code
                output_file = self.save_code(work_package, code)
                
                # Run quality checks on generated code
                quality_result = self.run_quality_checks(output_file, work_package["context"]["language"])
                
                # Run second validation prompt
                validation_result = self.validate_with_second_prompt(code, work_package)
                
                # Determine overall success based on both checks
                overall_success = (
                    quality_result.get("overall_passed", False) and 
                    validation_result.get("is_valid", False)
                )
                
                return {
                    "success": overall_success,
                    "code": code,
                    "output_file": str(output_file),
                    "model": model,
                    "generation_time": result.get("total_duration", 0) / 1e9,  # Convert to seconds
                    "quality_checks": quality_result,
                    "validation_result": validation_result,
                    "validation_passed": validation_result.get("is_valid", False)
                }
            else:
                return {
                    "success": False,
                    "error": f"Ollama API error: {response.status_code}"
                }
                
        except Exception as e:
            logger.error(f"Ollama delegation failed: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    async def _handle_tool_calls(self, tool_calls):
        """Execute tool calls from Qwen"""
        for tool_call in tool_calls:
            function_name = tool_call.get("function", {}).get("name")
            arguments = tool_call.get("function", {}).get("arguments", {})
            
            if function_name == "write_file":
                path = arguments.get("path")
                content = arguments.get("content")
                
                if path and content:
                    try:
                        # Ensure directory exists
                        file_path = Path(path)
                        file_path.parent.mkdir(parents=True, exist_ok=True)
                        
                        # Write file
                        with open(file_path, 'w') as f:
                            f.write(content)
                        
                        logger.info(f"Tool call: wrote {len(content)} chars to {path}")
                        
                    except Exception as e:
                        logger.error(f"Tool call write_file failed: {e}")
                        
            elif function_name == "read_file":
                path = arguments.get("path")
                if path:
                    try:
                        with open(path, 'r') as f:
                            content = f.read()
                        logger.info(f"Tool call: read {len(content)} chars from {path}")
                    except Exception as e:
                        logger.error(f"Tool call read_file failed: {e}")
    
    def create_prompt(self, work_package: Dict[str, Any]) -> str:
        """Create prompt with all details inline - use full context window"""
        task_type = work_package["task_type"]
        description = work_package["description"]
        requirements = work_package["requirements"]
        language = work_package["context"]["language"]
        
        # Define role-based context
        role_context = self._get_role_context(task_type, language)
        
        prompt = f"""{role_context}

## TASK SPECIFICATION

**IMPLEMENT:** {description}

**REQUIREMENTS:**
{chr(10).join(f"- {req}" for req in requirements)}

**LANGUAGE:** {language}

## QUALITY STANDARDS (MANDATORY)

### COMPLETENESS REQUIREMENTS:
- ALL imports explicitly defined at the top
- ALL methods/classes/variables completely implemented  
- NO undefined method calls (every self.method() must be defined)
- NO missing dependencies or external calls without implementation
- MUST compile successfully

### FORBIDDEN PATTERNS:
- self._undefined_method() calls without method definition
- Using types without proper imports (List without from typing import List)
- Incomplete class definitions or stub methods
- TODO comments or placeholder code
- External API calls without complete implementation

### QUALITY GATES:
1. COMPILATION: Code must pass compilation tests
2. DEPENDENCIES: Every method/function called must be defined
3. IMPORTS: All type hints and libraries must be imported
4. COMPLETENESS: No partial implementations

## IMPLEMENTATION INSTRUCTIONS

Write complete, production-ready {language} code that:
- Has ALL necessary imports at the top
- Implements ALL required functionality
- Includes proper error handling and logging
- Uses appropriate type hints
- Follows {language} best practices
- Is ready for production deployment

## CRITICAL REQUIREMENTS - DO THIS NOW

WRITE THE CODE AND SAVE IT TO A FILE!

DO NOT GIVE EXPLANATIONS - JUST DO THESE STEPS:

1. WRITE YOUR COMPLETE {language} CODE  
2. SAVE IT TO FILE: ollama_results/{work_package['id']}_implementation.py

USE THIS EXACT SYNTAX TO SAVE THE FILE:
write_file(path="ollama_results/{work_package['id']}_implementation.py", content="YOUR_COMPLETE_PYTHON_CODE_HERE")

JUST WRITE THE FILE!

START CODING NOW!
        
        # Add task-specific instructions
        if task_type == "test_generation":
            prompt += """
Include test cases that:
- Test happy path scenarios
- Test edge cases
- Test error conditions
- Use appropriate mocking where needed
- Achieve at least 80% code coverage
"""
        elif task_type == "api_endpoint":
            prompt += """
Include:
- Input validation
- Authentication checks
- Error responses
- OpenAPI documentation comments
- Rate limiting considerations
"""
        
        return prompt
    
    def _get_role_context(self, task_type: str, language: str) -> str:
        """Generate role-based context for different task types"""
        role_contexts = {
            "function_implementation": f"""You are a SENIOR {language.upper()} SOFTWARE ENGINEER - Expert in writing production-grade functions and methods with complete implementations, error handling, and thorough testing considerations.""",
            
            "claude_code_command": f"""You are a CLAUDE CODE SPECIALIST - Expert in implementing Claude Code commands and workflows with deep understanding of automation, hooks, and integration patterns.""",
            
            "test_generation": f"""You are a SENIOR QA AUTOMATION ENGINEER - Expert in writing test suites with high coverage, edge case handling, and best testing practices for {language} applications.""",
            
            "api_endpoint": f"""You are a SENIOR BACKEND API ENGINEER - Expert in designing and implementing robust REST APIs with proper validation, authentication, error handling, and OpenAPI documentation.""",
            
            "bug_fix": f"""You are a SENIOR DEBUGGING SPECIALIST - Expert in identifying root causes, implementing targeted fixes, and ensuring solutions don't introduce regressions.""",
            
            "refactoring": f"""You are a SENIOR CODE ARCHITECT - Expert in improving code structure, maintainability, and performance while preserving functionality and ensuring backward compatibility.""",
            
            "performance_optimization": f"""You are a SENIOR PERFORMANCE ENGINEER - Expert in profiling, optimizing, and scaling {language} applications with focus on efficiency and resource utilization.""",
            
            "documentation": f"""You are a SENIOR TECHNICAL WRITER - Expert in creating clear,, and maintainable technical documentation with examples and best practices.""",
            
            "security_audit": f"""You are a SENIOR SECURITY ENGINEER - Expert in identifying vulnerabilities, implementing security best practices, and ensuring code meets security compliance standards.""",
            
            "code_review": f"""You are a SENIOR CODE REVIEW SPECIALIST - Expert in conducting thorough code reviews with focus on quality, maintainability, security, and adherence to best practices."""
        }
        
        return role_contexts.get(task_type, f"""You are a SENIOR {language.upper()} DEVELOPER - Expert in writing high-quality, production-ready code with implementations and best practices.""")
    
    def _get_file_extension(self, language: str) -> str:
        """Get file extension for the programming language"""
        extensions = {
            "python": "py",
            "javascript": "js", 
            "typescript": "ts",
            "go": "go",
            "rust": "rs",
            "java": "java",
            "cpp": "cpp",
            "c": "c"
        }
        return extensions.get(language.lower(), "txt")
    
    def _get_max_context_for_model(self, model: str) -> int:
        """Dynamically get maximum context window for the given model from Ollama"""
        # Check cache first
        if model in self._model_context_cache:
            return self._model_context_cache[model]
        
        try:
            # Query Ollama for model specifications
            response = requests.post(
                f"{self.ollama_url}/api/show",
                json={"name": model},
                timeout=10
            )
            
            if response.status_code == 200:
                model_info = response.json()
                
                # Try different possible context length fields
                context_fields = [
                    "qwen2.context_length",
                    "qwen3.context_length", 
                    "llama.context_length",
                    "context_length",
                    "n_ctx"
                ]
                
                for field in context_fields:
                    if field in model_info:
                        context_size = int(model_info[field])
                        logger.info(f"Model {model} max context: {context_size:,} tokens")
                        # Cache the result
                        self._model_context_cache[model] = context_size
                        return context_size
                
                # If no direct field found, search through all fields
                for key, value in model_info.items():
                    if "context" in key.lower() and isinstance(value, (int, float)):
                        context_size = int(value)
                        logger.info(f"Model {model} max context (found in {key}): {context_size:,} tokens")
                        # Cache the result
                        self._model_context_cache[model] = context_size
                        return context_size
                
                logger.warning(f"Could not find context length for {model}, using fallback")
                
        except Exception as e:
            logger.error(f"Error querying model {model} context: {e}")
        
        # Fallback values based on known model families
        fallback_contexts = {
            "qwen2.5-coder:14b": 32768,
            "qwen3:8b": 40960,
            "qwen2.5-coder:7b": 32768,
            "qwen2.5:14b": 32768,
            "codellama:13b": 16384,
            "codellama:7b": 16384,
            "deepseek-coder:6.7b": 16384,
            "llama3.1:8b": 8192,
            "llama3.2:3b": 8192
        }
        
        # Try exact match first
        if model in fallback_contexts:
            context_size = fallback_contexts[model]
            logger.info(f"Model {model} using fallback context: {context_size:,} tokens")
            # Cache the result
            self._model_context_cache[model] = context_size
            return context_size
        
        # Try fuzzy matching for model families
        for pattern, context_size in fallback_contexts.items():
            if any(part in model for part in pattern.split(':')):
                logger.info(f"Model {model} using family fallback context: {context_size:,} tokens")
                # Cache the result
                self._model_context_cache[model] = context_size
                return context_size
        
        # Conservative default
        logger.warning(f"Unknown model {model}, using conservative context: 8,192 tokens")
        # Cache the conservative default too
        self._model_context_cache[model] = 8192
        return 8192
    
    def extract_code(self, response: str) -> str:
        """Extract code from Ollama response"""
        # Look for code blocks
        import re
        
        # Try to extract code from markdown code blocks
        code_pattern = r"```(?:\w+)?\n(.*?)```"
        matches = re.findall(code_pattern, response, re.DOTALL)
        
        if matches:
            # Return the longest code block (likely the main implementation)
            return max(matches, key=len)
        
        # If no code blocks, assume entire response is code
        return response.strip()
    
    def save_code(self, work_package: Dict[str, Any], code: str) -> Path:
        """Save generated code to file"""
        # Determine file extension
        lang_extensions = {
            "python": ".py",
            "javascript": ".js",
            "typescript": ".ts",
            "go": ".go",
            "rust": ".rs"
        }
        
        language = work_package["context"]["language"]
        extension = lang_extensions.get(language, ".txt")
        
        # Create filename based on task
        filename = f"{work_package['id'][:8]}_{work_package['task_type']}{extension}"
        output_file = self.results_dir / filename
        
        # Save code
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(code)
        
        return output_file
    
    def run_quality_checks(self, code_file: Path, language: str) -> Dict[str, Any]:
        """Run quality checks on generated code"""
        quality_results = {
            "compilation": {"passed": False, "errors": []},
            "linting": {"passed": False, "errors": []},
            "type_checking": {"passed": False, "errors": []},
            "security": {"passed": False, "issues": []},
            "complexity": {"passed": False, "metrics": {}},
            "overall_passed": False
        }
        
        if language == "python":
            # 1. Compilation check
            try:
                result = subprocess.run(
                    ["python3", "-m", "py_compile", str(code_file)],
                    capture_output=True, text=True, timeout=30
                )
                quality_results["compilation"]["passed"] = result.returncode == 0
                if result.stderr:
                    quality_results["compilation"]["errors"] = result.stderr.split('\n')
            except Exception as e:
                quality_results["compilation"]["errors"] = [f"Compilation check failed: {str(e)}"]
            
            # 2. Linting with flake8 (if available)
            try:
                venv_path = Path(__file__).parent.parent / "venv" / "bin" / "flake8"
                if venv_path.exists():
                    result = subprocess.run(
                        [str(venv_path), str(code_file)],
                        capture_output=True, text=True, timeout=30
                    )
                    quality_results["linting"]["passed"] = result.returncode == 0
                    if result.stdout:
                        quality_results["linting"]["errors"] = result.stdout.split('\n')
            except Exception as e:
                quality_results["linting"]["errors"] = [f"Linting check failed: {str(e)}"]
            
            # 3. Security check with bandit (if available)
            try:
                venv_path = Path(__file__).parent.parent / "venv" / "bin" / "bandit"
                if venv_path.exists():
                    result = subprocess.run(
                        [str(venv_path), "-f", "json", str(code_file)],
                        capture_output=True, text=True, timeout=30
                    )
                    quality_results["security"]["passed"] = result.returncode == 0
                    if result.stdout and result.stdout.strip():
                        try:
                            bandit_data = json.loads(result.stdout)
                            quality_results["security"]["issues"] = bandit_data.get("results", [])
                        except:
                            pass
            except Exception as e:
                quality_results["security"]["issues"] = [f"Security check failed: {str(e)}"]
        
        # Determine overall pass/fail
        quality_results["overall_passed"] = (
            quality_results["compilation"]["passed"] and
            quality_results["linting"]["passed"] and 
            quality_results["security"]["passed"]
        )
        
        return quality_results
    
    def validate_with_second_prompt(self, code: str, work_package: Dict[str, Any]) -> Dict[str, Any]:
        """Send code to validation expert for review"""
        language = work_package["context"]["language"]
        task_type = work_package["task_type"]
        
        validation_prompt = f"""You are a SENIOR CODE VALIDATION EXPERT and QUALITY ASSURANCE SPECIALIST with 15+ years of experience in {language.upper()} development. Your expertise includes static code analysis, compilation validation, dependency checking, and production-readiness assessment.

## YOUR MISSION:
Perform a validation of the following code to ensure it meets enterprise production standards.

## CODE TO VALIDATE:
```{language}
{code}
```

## EXPERT VALIDATION PROCESS:

### 🔍 PHASE 1: COMPILATION ANALYSIS
As a compilation expert, verify:
1. ALL imports are present and syntactically correct
2. ALL methods, functions, and classes are completely defined
3. ALL variable references have corresponding definitions
4. Code would successfully pass `python -m py_compile filename.py`

### 🔍 PHASE 2: DEPENDENCY AUDIT
As a dependency specialist, check for:
1. Undefined method calls (especially `self._method_name()` without definition)
2. Missing type imports (e.g., `List`, `Dict`, `Optional` without `from typing import`)
3. External dependencies called without proper imports
4. Circular dependency issues

### 🔍 PHASE 3: COMPLETENESS REVIEW
As a code completeness auditor, ensure:
1. Full implementation of all specified requirements
2. No TODO comments, stubs, or placeholder methods
3. Complete error handling with proper exception types
4. All code paths are implemented (no `pass` statements in production logic)

### 🔍 PHASE 4: PRODUCTION READINESS
As a production systems expert, validate:
1. Proper logging and error reporting patterns
2. Thread safety considerations where applicable  
3. Resource management (file handles, connections, etc.)
4. Performance implications of the implementation

## CRITICAL VALIDATION CRITERIA:
- ❌ REJECT if any `self._method()` calls are undefined
- ❌ REJECT if any imports are missing for used types/modules
- ❌ REJECT if any classes have incomplete method definitions
- ❌ REJECT if code contains TODO, FIXME, or placeholder comments
- ❌ REJECT if compilation would fail
- ✅ ACCEPT only if code is complete, compilable, and production-ready

## RESPONSE FORMAT:
Provide ONLY a JSON response with this exact structure:
{{
    "is_valid": true/false,
    "compilation_issues": ["specific compilation errors found"],
    "missing_dependencies": ["undefined methods/imports/variables"],
    "completeness_issues": ["incomplete implementations found"],
    "production_issues": ["production readiness concerns"],
    "recommendations": ["specific fixes required for approval"],
    "overall_quality_score": 0-100
}}

Be extremely thorough - enterprise code quality depends on your validation.
"""
        
        try:
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": self.select_best_model(work_package),
                    "prompt": validation_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,  # Low temperature for analytical tasks
                        "num_predict": 2048,  # Shorter response for validation
                        "num_ctx": self._get_max_context_for_model(self.select_best_model(work_package))
                    }
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                validation_text = result["response"]
                
                # Try to extract JSON from response
                try:
                    import re
                    json_match = re.search(r'\{.*\}', validation_text, re.DOTALL)
                    if json_match:
                        return json.loads(json_match.group())
                except:
                    pass
                
                return {
                    "is_valid": "true" in validation_text.lower(),
                    "validation_response": validation_text
                }
            
        except Exception as e:
            logger.error(f"Validation prompt failed: {e}")
        
        return {"is_valid": False, "error": "Validation failed"}
    
    async def validate_with_second_prompt_async(self, code: str, work_package: Dict[str, Any]) -> Dict[str, Any]:
        """Send code to validation expert for review (async version)"""
        language = work_package["context"]["language"]
        
        validation_prompt = f"""You are a CODE VALIDATION EXPERT. Validate this {language} code for completeness and correctness.

## CODE TO VALIDATE:
```{language}
{code}
```

## VALIDATION CHECKS:
1. Are ALL imports present?
2. Are ALL methods/functions defined?
3. Would this code compile without errors?
4. Are there any undefined method calls?

## RESPONSE FORMAT:
Provide ONLY a JSON response:
{{
    "is_valid": true/false,
    "compilation_issues": ["list of issues"],
    "missing_dependencies": ["list of missing items"],
    "recommendations": ["list of fixes needed"]
}}
"""
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    f"{self.ollama_url}/api/generate",
                    json={
                        "model": self.select_best_model(work_package),
                        "prompt": validation_prompt,
                        "stream": False,
                        "options": {
                            "temperature": 0.1,
                            "num_predict": 1024,
                            "num_ctx": self._get_max_context_for_model(self.select_best_model(work_package))
                        }
                    }
                ) as response:
                    
                    if response.status == 200:
                        result = await response.json()
                        validation_text = result["response"]
                        
                        # Try to extract JSON from response
                        try:
                            import re
                            json_match = re.search(r'\\{.*\\}', validation_text, re.DOTALL)
                            if json_match:
                                return json.loads(json_match.group())
                        except:
                            pass
                        
                        return {
                            "is_valid": "true" in validation_text.lower(),
                            "validation_response": validation_text
                        }
            
        except Exception as e:
            logger.error(f"Async validation prompt failed: {e}")
        
        return {"is_valid": False, "error": "Async validation failed"}
    
    def monitor_ollama_health(self) -> bool:
        """Check if Ollama is running and healthy"""
        try:
            response = requests.get(f"{self.ollama_url}/api/tags")
            return response.status_code == 200
        except:
            return False
    
    def get_available_models(self) -> List[str]:
        """Get list of available Ollama models"""
        try:
            response = requests.get(f"{self.ollama_url}/api/tags")
            if response.status_code == 200:
                models_data = response.json()
                return [model["name"] for model in models_data.get("models", [])]
        except Exception as e:
            logger.error(f"Error fetching Ollama models: {e}")
        return []
    
    def select_best_model(self, work_package: Dict[str, Any]) -> str:
        """Claude selects the best model for the task based on available models"""
        available_models = self.get_available_models()
        task_type = work_package["task_type"]
        
        logger.info(f"Available Ollama models: {available_models}")
        
        # Model selection logic based on task type and available models
        # Prioritize qwen2.5-coder:14b for best code quality
        model_preferences = {
            "function_implementation": [
                "qwen2.5-coder:14b",  # BEST for complex implementations
                "qwen3:8b",           # Fallback with thinking
                "qwen2.5-coder:7b",   # Smaller qwen version
                "qwen2.5:14b",        # General qwen
                "codellama:13b",
                "codellama:7b", 
                "deepseek-coder:6.7b",
                "codegemma:7b"
            ],
            "test_generation": [
                "qwen2.5-coder:14b",  # BEST for test generation
                "qwen3:8b",
                "codellama:13b-instruct",
                "codellama:7b-instruct",
                "qwen2.5-coder:7b"
            ],
            "bug_fix": [
                "qwen2.5-coder:14b",  # BEST for bug fixes
                "qwen3:8b",
                "deepseek-coder:6.7b",
                "codellama:13b",
                "codellama:7b"
            ],
            "refactoring": [
                "qwen2.5-coder:14b",  # BEST for refactoring
                "qwen3:8b", 
                "codellama:13b",
                "deepseek-coder:6.7b",
                "codellama:7b"
            ],
            "api_endpoint": [
                "qwen2.5-coder:14b",  # BEST for API development
                "qwen3:8b",
                "codellama:13b",
                "codellama:7b"
            ],
            "claude_code_command": [
                "qwen2.5-coder:14b",  # BEST for Claude Code tasks
                "qwen3:8b",
                "codellama:13b"
            ],
            "documentation": [
                "llama3.2:3b",
                "llama3.1:8b",
                "mistral:7b",
                "phi3:medium"
            ],
            "performance_optimization": [
                "qwen2.5-coder:32b",
                "deepseek-coder-v2:16b",
                "codellama:13b"
            ]
        }
        
        # Check for feedback-based recommendation first
        feedback_loop = ollama_feedback_loop.OllamaFeedbackLoop()
        recommended_model = feedback_loop.recommend_model(task_type)
        if recommended_model and recommended_model in available_models:
            logger.info(f"Using feedback-recommended model: {recommended_model}")
            return recommended_model
        
        # Get preferences for this task type
        preferences = model_preferences.get(task_type, [
            "codellama:7b",
            "llama3.1:8b", 
            "deepseek-coder:6.7b",
            "qwen2.5-coder:7b"
        ])
        
        # Find first available preferred model
        for preferred_model in preferences:
            if preferred_model in available_models:
                logger.info(f"Selected model for {task_type}: {preferred_model}")
                return preferred_model
        
        # Fallback to any available code model
        code_models = [m for m in available_models if any(keyword in m.lower() for keyword in ["code", "deepseek", "qwen", "gemma"])]
        if code_models:
            # Prefer larger models
            code_models.sort(key=lambda x: self._extract_model_size(x), reverse=True)
            selected = code_models[0]
            logger.info(f"Fallback to available code model: {selected}")
            return selected
        
        # Last resort - use any available model
        if available_models:
            selected = available_models[0]
            logger.warning(f"Using any available model: {selected}")
            return selected
        
        # Default if no models available
        logger.error("No Ollama models available, using default")
        return "llama3.2:3b"
    
    def _extract_model_size(self, model_name: str) -> int:
        """Extract model size from name for sorting"""
        import re
        # Extract number before 'b' (billion parameters)
        match = re.search(r'(\d+)b', model_name)
        if match:
            return int(match.group(1))
        # Check for size indicators
        if "large" in model_name.lower():
            return 100
        elif "medium" in model_name.lower():
            return 50
        elif "small" in model_name.lower():
            return 10
        return 1

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle Ollama delegation requests"""
    delegation = OllamaDelegation()
    
    # Check if this is a work package delegation request
    if "work_package" not in input_data:
        return {"decision": "allow"}
    
    work_package = input_data["work_package"]
    
    # Check Ollama health
    if not delegation.monitor_ollama_health():
        return {
            "decision": "allow",
            "error": "Ollama is not running. Please start Ollama service."
        }
    
    # Delegate to Ollama
    result = delegation.delegate_to_ollama(work_package)
    
    if result["success"]:
        context = f"""
🤖 **Ollama Code Generation Complete**

**Model**: {result['model']}
**Generation Time**: {result['generation_time']:.2f}s
**Output File**: {result['output_file']}

The code has been generated and saved. Running DevSecOps checks...
"""
        
        # Trigger DevSecOps automation
        return {
            "decision": "allow",
            "context": context,
            "next_action": "devsecops_check",
            "code_file": result["output_file"],
            "work_package_id": work_package["id"]
        }
    else:
        return {
            "decision": "allow",
            "error": f"Ollama generation failed: {result['error']}"
        }

def batch_delegate(work_packages: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Delegate multiple work packages to Ollama in parallel"""
    delegation = OllamaDelegation()
    results = []
    
    for package in work_packages:
        result = delegation.delegate_to_ollama(package)
        results.append({
            "package_id": package["id"],
            "success": result["success"],
            "result": result
        })
        
        # Small delay to avoid overwhelming Ollama
        time.sleep(0.5)
    
    successful = sum(1 for r in results if r["success"])
    
    return {
        "total": len(work_packages),
        "successful": successful,
        "failed": len(work_packages) - successful,
        "results": results
    }