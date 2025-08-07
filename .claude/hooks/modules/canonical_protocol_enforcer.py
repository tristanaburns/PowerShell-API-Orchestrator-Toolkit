"""
Canonical Protocol Enforcer Module
Enforces strict coding protocols in Ollama prompts using RFC 2119 language
"""

import json
from pathlib import Path
from typing import Dict, Any, List

class CanonicalProtocolEnforcer:
    """Enforces canonical coding protocols with RFC 2119 terminology"""
    
    def __init__(self):
        self.load_canonical_rules()
        self.commands_dir = Path(__file__).parent.parent.parent / "commands"
        self.protocol_cache = {}
    
    def load_canonical_rules(self):
        """Load canonical rules from CLAUDE.md"""
        self.canonical_rules = {
            "language_restrictions": {
                "PERMITTED": [
                    "Python",
                    "Node.js", 
                    "JavaScript",
                    "TypeScript",
                    "React",
                    "Go",
                    "Rust"
                ],
                "FORBIDDEN": [
                    "PowerShell",
                    "Batch files (.bat, .cmd)",
                    "VBScript",
                    "Shell scripts",
                    "Bash scripts"
                ]
            },
            "documentation_requirements": {
                "formats": ["Jupyter Notebook (.ipynb)", "Markdown (.md)"],
                "mandatory": True
            },
            "coding_standards": {
                "error_handling": "MANDATORY",
                "type_hints": "REQUIRED",
                "docstrings": "REQUIRED",
                "testing": "MANDATORY",
                "security": "CRITICAL"
            }
        }
    
    def generate_protocol_preamble(self) -> str:
        """Generate strict protocol preamble for Ollama"""
        return """
# CANONICAL PROTOCOL - MANDATORY COMPLIANCE REQUIRED

THIS PROTOCOL USES RFC 2119 TERMINOLOGY. YOU **MUST** UNDERSTAND:
- **MUST/SHALL/REQUIRED**: Absolute requirement, NO exceptions
- **MUST NOT/SHALL NOT**: Absolute prohibition, NO exceptions  
- **SHOULD/RECOMMENDED**: Strong preference, exceptions need justification
- **MAY/OPTIONAL**: Truly optional

## LANGUAGE RESTRICTIONS - ABSOLUTE REQUIREMENTS

### PERMITTED LANGUAGES (YOU **MUST** USE ONLY THESE):
- Python
- Node.js/JavaScript/TypeScript
- React and React frameworks
- Go
- Rust

### FORBIDDEN LANGUAGES (YOU **MUST NEVER** USE):
- PowerShell - **FORBIDDEN** - **NEVER** write .ps1 files
- Windows Batch - **FORBIDDEN** - **NEVER** write .bat or .cmd files
- VBScript - **FORBIDDEN**
- Shell/Bash scripts - **FORBIDDEN** - Use Node.js child_process instead
- ANY language not in the PERMITTED list - **FORBIDDEN**

## MANDATORY CODING REQUIREMENTS

### ERROR HANDLING - **REQUIRED**
You **MUST** include proper error handling:
- **MUST** use try-catch/try-except blocks
- **MUST** handle edge cases
- **MUST** provide meaningful error messages
- **SHALL NOT** allow unhandled exceptions

### TYPE SAFETY - **REQUIRED**
- Python: You **MUST** include type hints for all functions
- TypeScript: You **MUST** use strict type checking
- **MUST NOT** use 'any' type unless absolutely necessary

### DOCUMENTATION - **MANDATORY**
You **SHALL** include:
- Docstrings for ALL functions and classes
- Inline comments for complex logic
- **MUST** explain the "why", not just the "what"

### TESTING - **REQUIRED**
- You **MUST** make code testable
- **SHOULD** include example test cases
- **MUST** achieve minimum 80% coverage potential

### SECURITY - **CRITICAL**
You **MUST NEVER**:
- Hard-code secrets, passwords, or API keys
- Use string concatenation for SQL queries
- Trust user input without validation
- Log sensitive information

You **MUST ALWAYS**:
- Validate and sanitize all inputs
- Use parameterized queries
- Follow principle of least privilege
- Use environment variables for secrets

## DEVSECOPS COMPLIANCE - **MANDATORY**

Your code **MUST** pass ALL of these checks:
1. **Linting** - Code **MUST** be properly formatted
2. **Type checking** - Types **MUST** be correct
3. **Security scanning** - **MUST NOT** have vulnerabilities
4. **Test coverage** - **MUST** be testable with >80% coverage

## IMPLEMENTATION REQUIREMENTS

You **SHALL**:
1. Write complete, production-ready code
2. Handle ALL error conditions
3. Include proper logging
4. Follow SOLID principles
5. Write clean, maintainable code

You **MUST NOT**:
1. Write stub functions or TODO comments
2. Leave placeholder code
3. Write untested code paths
4. Ignore edge cases

## FINAL MANDATORY INSTRUCTION

ANY violation of these protocols will result in IMMEDIATE REJECTION.
You **MUST** follow these rules with ZERO exceptions.
Compliance is NOT optional - it is MANDATORY.

---
END OF CANONICAL PROTOCOL
"""
    
    def enforce_in_prompt(self, original_prompt: str, task_type: str, work_package: Dict[str, Any] = None) -> str:
        """Enforce canonical protocol in the prompt"""
        protocol_preamble = self.generate_protocol_preamble()
        
        # Load the canonical compliance header
        canonical_header = self.load_canonical_compliance_header()
        
        # Get Claude command from work package
        claude_command = work_package.get("claude_command", "/code/general") if work_package else "/code/general"
        command_prefix = work_package.get("command_prefix", f"[COMMAND: {claude_command}]") if work_package else ""
        
        # Load multiple commands for workflow (planning → implement → verify)
        command_protocols = []
        
        # For implementation tasks, include the full workflow
        if "implement" in claude_command or task_type == "function_implementation":
            # Load planning command first
            planning_protocol = self.load_specific_command("/code/code-planning")
            if planning_protocol and "not found" not in planning_protocol:
                command_protocols.append(f"## STEP 1: PLANNING PHASE\n{planning_protocol}")
            
            # Load implementation command
            impl_protocol = self.load_specific_command(claude_command)
            if impl_protocol:
                command_protocols.append(f"## STEP 2: IMPLEMENTATION PHASE\n{impl_protocol}")
            
            # Load verification command
            verify_protocol = self.load_specific_command("/code/code-validation")
            if verify_protocol and "not found" not in verify_protocol:
                command_protocols.append(f"## STEP 3: VERIFICATION PHASE\n{verify_protocol}")
        else:
            # For other tasks, just load the specific command
            command_protocol = self.load_specific_command(claude_command)
            if command_protocol:
                command_protocols.append(command_protocol)
        
        # Join all protocols
        combined_protocols = "\n\n".join(command_protocols)
        
        # Get MCP instructions if available
        mcp_instruction = work_package.get("mcp_instruction", "") if work_package else ""
        
        # Add task-specific enforcement
        task_enforcement = self.get_task_specific_enforcement(task_type)
        
        # Combine everything with structured format
        enforced_prompt = f"""
{canonical_header}

{protocol_preamble}

{mcp_instruction}

## CLAUDE COMMAND WORKFLOW: {command_prefix}

{combined_protocols}

## TASK-SPECIFIC REQUIREMENTS - {task_type.upper()}

{task_enforcement}

## YOUR SPECIFIC TASK

{command_prefix}
{original_prompt}

## MANDATORY COMPLIANCE REMINDER

You **MUST** follow ALL canonical protocols above.
You **SHALL** implement according to the command workflow: {claude_command}
You **MUST** use MCP tools as specified.
You **MUST NOT** violate any FORBIDDEN patterns.
Any violations **SHALL** result in IMMEDIATE REJECTION.
"""
        
        return enforced_prompt
    
    def get_task_specific_enforcement(self, task_type: str) -> str:
        """Get task-specific enforcement rules"""
        enforcements = {
            "function_implementation": """
You **MUST**:
- Include complete error handling
- Add docstrings
- Include type hints for ALL parameters and returns
- Validate ALL inputs
- Handle ALL edge cases
- Make the function thread-safe if applicable
- Follow single responsibility principle

You **MUST NOT**:
- Write incomplete implementations
- Use global variables
- Have side effects unless explicitly required
- Return inconsistent types
""",
            "test_generation": """
You **MUST**:
- Test ALL code paths
- Include edge case tests
- Test error conditions
- Use proper mocking for external dependencies
- Include both positive and negative test cases
- Use descriptive test names
- Group related tests

You **MUST NOT**:
- Write trivial tests
- Test implementation details
- Use real external services
- Write flaky tests
""",
            "api_endpoint": """
You **MUST**:
- Validate ALL inputs
- Implement proper authentication
- Include rate limiting logic
- Return proper HTTP status codes
- Include OpenAPI/Swagger documentation
- Implement CORS if needed
- Log all requests

You **MUST NOT**:
- Trust user input
- Return sensitive information in errors
- Use GET for state-changing operations
- Ignore HTTP method semantics
""",
            "bug_fix": """
You **MUST**:
- Understand the root cause
- Fix the actual problem, not symptoms
- Prevent regression
- Update or add tests
- Document the fix
- Consider edge cases

You **MUST NOT**:
- Introduce new bugs
- Break existing functionality
- Ignore related issues
- Make assumptions without verification
""",
            "refactoring": """
You **MUST**:
- Maintain exact functionality
- Improve code clarity
- Follow established patterns
- Update all references
- Preserve all tests
- Document significant changes

You **MUST NOT**:
- Change behavior
- Break interfaces
- Ignore deprecation warnings
- Mix refactoring with features
"""
        }
        
        return enforcements.get(task_type, """
You **MUST** follow all canonical protocols.
You **MUST** write production-ready code.
You **MUST NOT** violate any forbidden practices.
""")
    
    def validate_response(self, code: str, language: str) -> Dict[str, Any]:
        """Validate if response follows canonical protocol"""
        violations = []
        
        # Check for forbidden languages
        forbidden_patterns = {
            "powershell": [".ps1", "PowerShell", "Get-", "Set-", "$PSVersionTable"],
            "batch": [".bat", ".cmd", "@echo", "rem ", "goto "],
            "bash": ["#!/bin/bash", "#!/bin/sh", "$(", "${"],
            "vbscript": [".vbs", "Dim ", "Sub ", "End Sub"]
        }
        
        for lang, patterns in forbidden_patterns.items():
            for pattern in patterns:
                if pattern.lower() in code.lower():
                    violations.append(f"FORBIDDEN language detected: {lang} (pattern: {pattern})")
        
        # Check for required elements based on language
        if language == "python":
            if "def " in code and "->" not in code:
                violations.append("REQUIRED: Python functions MUST have return type hints")
            if "def " in code and '"""' not in code:
                violations.append("REQUIRED: Python functions MUST have docstrings")
            if "except:" in code and "except Exception" not in code:
                violations.append("SHOULD: Avoid bare except clauses")
        
        # Check for security violations
        security_patterns = [
            ("password=", "MUST NOT hard-code passwords"),
            ("api_key=", "MUST NOT hard-code API keys"),
            ("secret=", "MUST NOT hard-code secrets"),
            ("eval(", "MUST NOT use eval()"),
            ("exec(", "MUST NOT use exec()"),
        ]
        
        for pattern, message in security_patterns:
            if pattern in code.lower():
                violations.append(f"SECURITY VIOLATION: {message}")
        
        return {
            "compliant": len(violations) == 0,
            "violations": violations,
            "severity": "CRITICAL" if violations else "PASS"
        }

    def load_canonical_compliance_header(self) -> str:
        """Load the canonical compliance header"""
        if "canonical_header" in self.protocol_cache:
            return self.protocol_cache["canonical_header"]
        
        header_path = self.commands_dir / "CANONICAL-COMPLIANCE-HEADER.md"
        if header_path.exists():
            with open(header_path, 'r', encoding='utf-8') as f:
                content = f.read()
                self.protocol_cache["canonical_header"] = content
                return content
        return ""
    
    def load_specific_command(self, claude_command: str) -> str:
        """Load specific Claude command content"""
        # Convert command format to file path
        # e.g., "/code/code-implement" -> "code/code-implement.md"
        command_path = claude_command.strip('/') + ".md"
        
        full_path = self.commands_dir / command_path
        if full_path.exists():
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
                # Extract the core protocol parts (skip redundant headers)
                if "CANONICAL PROTOCOL ENFORCEMENT" in content:
                    # Extract just the specific instructions
                    lines = content.split('\n')
                    start_idx = 0
                    for i, line in enumerate(lines):
                        if any(marker in line for marker in ["## YOUR TASK", "## IMPLEMENTATION", "## OBJECTIVE"]):
                            start_idx = i
                            break
                    if start_idx > 0:
                        return '\n'.join(lines[start_idx:])
                return content
        
        # If exact command not found, try variations
        base_name = Path(command_path).stem
        parent_dir = Path(command_path).parent
        
        # Try without "code-" prefix
        alt_path = self.commands_dir / parent_dir / f"{base_name.replace('code-', '')}.md"
        if alt_path.exists():
            with open(alt_path, 'r', encoding='utf-8') as f:
                return f.read()
        
        return f"Command {claude_command} not found. Using general implementation guidelines."
    
    def find_best_matching_command(self, task_type: str) -> str:
        """Find the best matching command for a task type"""
        # Search for commands that might match
        code_dir = self.commands_dir / "code"
        if code_dir.exists():
            for cmd_file in code_dir.glob("*.md"):
                if task_type.lower() in cmd_file.stem.lower():
                    with open(cmd_file, 'r', encoding='utf-8') as f:
                        return f.read()
        return ""

def integrate_canonical_enforcement(work_package: Dict[str, Any]) -> Dict[str, Any]:
    """Integrate canonical protocol enforcement into work package"""
    enforcer = CanonicalProtocolEnforcer()
    
    # Get original prompt
    original_prompt = work_package.get("enhanced_prompt", work_package.get("description", ""))
    
    # Enforce protocol with Claude commands and structured format
    enforced_prompt = enforcer.enforce_in_prompt(
        original_prompt, 
        work_package["task_type"],
        work_package  # Pass the whole package for command info
    )
    
    # Update work package
    work_package["canonical_prompt"] = enforced_prompt
    work_package["protocol_enforced"] = True
    work_package["enforcement_level"] = "MANDATORY"
    work_package["claude_command_loaded"] = True
    work_package["prompt_structure"] = "COMMAND_PREFIX_FORMAT"
    
    return work_package