"""
Work Package Manager Module
Creates and manages coding work packages for delegation to Ollama LLMs
"""

import json
import logging
import uuid
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List, Optional
import re

logger = logging.getLogger(__name__)

class WorkPackageManager:
    """Manages work package creation and delegation"""
    
    def __init__(self):
        self.packages_dir = Path(__file__).parent.parent / "work_packages"
        self.packages_dir.mkdir(exist_ok=True)
        
        # Patterns that trigger work package creation
        self.delegation_patterns = {
            r"IMPLEMENT_FUNCTION:\s*(.+)": "function_implementation",
            r"WRITE_TESTS:\s*(.+)": "test_generation",
            r"FIX_BUG:\s*(.+)": "bug_fix",
            r"REFACTOR:\s*(.+)": "refactoring",
            r"DOCUMENT:\s*(.+)": "documentation",
            r"CREATE_API:\s*(.+)": "api_endpoint",
            r"OPTIMIZE:\s*(.+)": "performance_optimization",
            r"SECURE:\s*(.+)": "security_audit",
            r"REVIEW:\s*(.+)": "code_review",
            r"IMPLEMENT:\s*(.+)": "general_implementation",
            # Claude /overlord: command patterns
            r"/overlord:[\s-]*([^/\n]+)": "claude_overlord_command",
            r"/overlord/overlord-implement[\s:]*(.*)": "function_implementation",
            r"/overlord/overlord-debug[\s:]*(.*)": "bug_fix",
            r"/overlord/overlord-refactor[\s:]*(.*)": "refactoring",
            r"/overlord/overlord-review[\s:]*(.*)": "code_review",
            r"/overlord/overlord-security-analysis[\s:]*(.*)": "security_audit",
            r"/overlord/overlord-performance-analysis[\s:]*(.*)": "performance_optimization",
            r"/overlord/overlord-documentation[\s:]*(.*)": "documentation",
            r"/overlord/overlord-testing-live-api[\s:]*(.*)": "test_generation",
            r"/overlord/general[\s:]*(.*)": "general_implementation"
        }
        
        # Map task types to Claude commands
        self.command_mapping = {
            "function_implementation": "/overlord/overlord-implement",
            "test_generation": "/testing/e2e",
            "bug_fix": "/overlord/overlord-debug",
            "refactoring": "/overlord/overlord-refactor",
            "documentation": "/overlord/overlord-documentation",
            "api_endpoint": "/composite/api",
            "performance_optimization": "/overlord/overlord-performance-analysis",
            "security_audit": "/overlord/overlord-security-analysis",
            "code_review": "/overlord/overlord-review",
            "general_implementation": "/overlord/implement",
            "claude_overlord_command": "/overlord/general"
        }
        
        # Ollama model selection based on task type
        self.model_routing = {
            "function_implementation": "qwen3:8b",
            "test_generation": "qwen3:8b",
            "bug_fix": "qwen3:8b",
            "refactoring": "qwen3:8b", 
            "documentation": "qwen3:8b",
            "api_endpoint": "qwen3:8b",
            "performance_optimization": "qwen3:8b",
            "security_audit": "qwen3:8b",
            "code_review": "qwen3:8b",
            "general_implementation": "qwen3:8b",
            "claude_overlord_command": "qwen3:8b"
        }
    
    def detect_delegatable_tasks(self, content: str) -> List[Dict[str, Any]]:
        """Detect tasks that can be delegated to Ollama"""
        tasks = []
        
        for pattern, task_type in self.delegation_patterns.items():
            matches = re.findall(pattern, content, re.MULTILINE | re.IGNORECASE)
            for match in matches:
                tasks.append({
                    "type": task_type,
                    "description": match,
                    "pattern": pattern
                })
        
        return tasks
    
    def create_work_package(self, task: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        """Create a structured work package for Ollama"""
        package_id = str(uuid.uuid4())
        
        # Claude determines the best command for this task
        claude_command = self.select_claude_command(task, context)
        
        package = {
            "id": package_id,
            "created_at": datetime.now().isoformat(),
            "task_type": task["type"],
            "description": task["description"],
            "claude_command": claude_command,
            "command_prefix": f"[COMMAND: {claude_command}]",
            "model": self.model_routing.get(task["type"], "llama3.2:3b"),
            "context": {
                "project_root": str(Path.cwd()),
                "current_file": context.get("current_file"),
                "language": self.detect_language(context),
                "framework": self.detect_framework(context)
            },
            "requirements": self.generate_requirements(task),
            "devsecops_checks": {
                "linting": True,
                "type_checking": True,
                "security_scan": True,
                "unit_tests": task["type"] != "documentation",
                "coverage_threshold": 80 if task["type"] != "documentation" else 0
            },
            "acceptance_criteria": self.generate_acceptance_criteria(task),
            "status": "pending"
        }
        
        # Save work package
        package_file = self.packages_dir / f"{package_id}.json"
        with open(package_file, 'w') as f:
            json.dump(package, f, indent=2)
        
        logger.info(f"Created work package {package_id} for {task['type']}")
        return package
    
    def generate_requirements(self, task: Dict[str, Any]) -> List[str]:
        """Generate specific requirements based on task type"""
        base_requirements = [
            "Follow project coding standards",
            "Include appropriate error handling",
            "Add inline documentation/comments",
            "Ensure thread safety where applicable"
        ]
        
        type_specific = {
            "function_implementation": [
                "Include type hints",
                "Handle edge cases",
                "Optimize for readability"
            ],
            "test_generation": [
                "Achieve minimum 80% coverage",
                "Include edge case tests",
                "Test error conditions",
                "Use appropriate mocking"
            ],
            "bug_fix": [
                "Identify root cause",
                "Prevent regression",
                "Update related tests"
            ],
            "api_endpoint": [
                "Include input validation",
                "Implement proper authentication",
                "Add rate limiting",
                "Document with OpenAPI"
            ]
        }
        
        return base_requirements + type_specific.get(task["type"], [])
    
    def generate_acceptance_criteria(self, task: Dict[str, Any]) -> List[str]:
        """Generate acceptance criteria for task completion"""
        criteria = {
            "function_implementation": [
                "Function executes without errors",
                "All tests pass",
                "Code passes linting",
                "Type checking succeeds"
            ],
            "test_generation": [
                "Tests achieve required coverage",
                "All tests pass",
                "Tests are meaningful (not just trivial)",
                "Tests cover edge cases"
            ],
            "bug_fix": [
                "Bug is resolved",
                "No new bugs introduced",
                "Existing tests still pass",
                "New test prevents regression"
            ]
        }
        
        return criteria.get(task["type"], ["Task completed successfully"])
    
    def detect_language(self, context: Dict[str, Any]) -> str:
        """Detect programming language from context"""
        file_path = context.get("current_file", "")
        if file_path:
            ext = Path(file_path).suffix
            lang_map = {
                ".py": "python",
                ".js": "javascript",
                ".ts": "typescript",
                ".go": "go",
                ".rs": "rust"
            }
            return lang_map.get(ext, "unknown")
        return "python"  # Default
    
    def detect_framework(self, context: Dict[str, Any]) -> Optional[str]:
        """Detect framework from project structure"""
        indicators = {
            "package.json": ["react", "vue", "angular", "express", "next"],
            "requirements.txt": ["django", "flask", "fastapi"],
            "Cargo.toml": ["actix", "rocket"],
            "go.mod": ["gin", "echo", "fiber"]
        }
        
        for file, frameworks in indicators.items():
            if (Path.cwd() / file).exists():
                # Would need to parse file to detect specific framework
                return frameworks[0]  # Simplified
        
        return None
    
    def select_claude_command(self, task: Dict[str, Any], context: Dict[str, Any]) -> str:
        """Claude makes an intelligent decision about which command to use"""
        task_type = task["type"]
        description = task["description"].lower()
        
        # First check for direct mapping
        if task_type in self.command_mapping:
            base_command = self.command_mapping[task_type]
        else:
            base_command = "/overlord/general"
        
        # Claude's judgment based on description keywords
        if any(word in description for word in ["secure", "vulnerability", "exploit", "injection"]):
            return "/overlord/overlord-security-analysis"
        elif any(word in description for word in ["fast", "slow", "optimize", "performance", "speed"]):
            return "/overlord/overlord-performance-analysis"
        elif any(word in description for word in ["test", "coverage", "unit", "integration", "e2e"]):
            return "/testing/e2e"
        elif any(word in description for word in ["api", "endpoint", "rest", "graphql", "route"]):
            return "/composite/api"
        elif any(word in description for word in ["clean", "refactor", "improve", "restructure"]):
            return "/overlord/overlord-refactor"
        elif any(word in description for word in ["bug", "fix", "error", "issue", "broken"]):
            return "/overlord/overlord-debug"
        elif any(word in description for word in ["document", "docs", "comment", "explain"]):
            return "/overlord/overlord-documentation"
        elif any(word in description for word in ["review", "audit", "check", "validate"]):
            return "/overlord/overlord-review"
        elif any(word in description for word in ["deploy", "release", "production", "ship"]):
            return "/overlord/overlord-deploy"
        
        # Check file context for additional hints
        if context.get("current_file"):
            file_path = context["current_file"].lower()
            if "test" in file_path:
                return "/testing/e2e"
            elif "api" in file_path or "route" in file_path:
                return "/composite/api"
            elif "component" in file_path and context.get("language") in ["javascript", "typescript"]:
                return "/composite/component"
        
        # Return base command if no specific match
        return base_command

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle work package detection and creation"""
    manager = WorkPackageManager()
    
    # Extract content from input
    content = input_data.get("content", "")
    if not content:
        return {"decision": "allow"}
    
    # Detect delegatable tasks
    tasks = manager.detect_delegatable_tasks(content)
    
    if tasks:
        packages = []
        for task in tasks:
            package = manager.create_work_package(task, input_data)
            packages.append(package)
        
        # Return instructions for Claude
        instructions = f"""
📦 **Work Packages Created: {len(packages)}**

I've identified tasks that can be delegated to Ollama LLMs:

"""
        for pkg in packages:
            instructions += f"- **{pkg['task_type']}**: {pkg['description'][:50]}... (ID: {pkg['id'][:8]})\n"
        
        instructions += """
These tasks will be automatically:
1. Sent to appropriate Ollama models
2. Validated through DevSecOps checks
3. Submitted back for your review

You can focus on architecture and high-level decisions while Ollama handles implementation.
"""
        
        return {
            "decision": "allow",
            "context": instructions,
            "packages": packages
        }
    
    return {"decision": "allow"}