"""
Delegation Enforcement Module
Prevents Claude from bypassing Ollama delegation system

This module actively enforces that coding tasks MUST be delegated to Ollama
and prevents Claude from implementing code directly when delegation is available.
"""

import json
import logging
import re
from pathlib import Path
from typing import Dict, Any, List
from datetime import datetime

logger = logging.getLogger(__name__)


class DelegationEnforcer:
    """Enforces mandatory delegation to Ollama for coding tasks"""
    
    def __init__(self):
        self.work_packages_dir = Path(__file__).parent.parent / "work_packages"
        self.enforcement_log = Path(__file__).parent.parent / "logs" / "delegation_enforcement.log"
        
        # Patterns that indicate Claude is trying to implement code directly
        self.bypass_patterns = [
            r"def\s+\w+\s*\(",  # Function definitions
            r"class\s+\w+\s*[:\(]",  # Class definitions  
            r"import\s+\w+",  # Import statements
            r"from\s+\w+\s+import",  # From imports
            r"```python",  # Python code blocks
            r"```javascript",  # JavaScript code blocks
            r"```typescript",  # TypeScript code blocks
            r"Write\(",  # File writing tool calls
            r"Edit\(",  # File editing tool calls
            r"MultiEdit\(",  # Multi-edit tool calls
        ]
        
        # Words that indicate implementation intent
        self.implementation_keywords = [
            "implement", "create", "write", "build", "develop", "code",
            "function", "class", "method", "script", "module", "component"
        ]
    
    def check_for_bypass_attempt(self, content: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Check if Claude is attempting to bypass delegation system
        
        Args:
            content: The content being processed
            context: Request context
            
        Returns:
            Dict with enforcement decision and message
        """
        # Check if there are pending work packages that should be delegated instead
        pending_packages = self._get_pending_packages()
        
        if pending_packages:
            # Check if content contains implementation attempts
            bypass_detected = self._detect_implementation_bypass(content)
            
            if bypass_detected:
                violation_msg = self._create_violation_message(pending_packages, bypass_detected)
                self._log_violation(content, bypass_detected)
                
                return {
                    "decision": "block",
                    "message": violation_msg,
                    "pending_packages": len(pending_packages),
                    "bypass_patterns_detected": bypass_detected
                }
        
        return {"decision": "allow"}
    
    def _get_pending_packages(self) -> List[Dict[str, Any]]:
        """Get all pending work packages that should be delegated"""
        pending = []
        
        if not self.work_packages_dir.exists():
            return pending
        
        for package_file in self.work_packages_dir.glob("*.json"):
            try:
                with open(package_file, 'r') as f:
                    package = json.load(f)
                    if package.get("status") == "pending":
                        pending.append(package)
            except Exception as e:
                logger.warning(f"Could not read work package {package_file}: {e}")
        
        return pending
    
    def _detect_implementation_bypass(self, content: str) -> List[str]:
        """Detect if content contains direct implementation attempts"""
        detected_patterns = []
        
        # Check for code patterns
        for pattern in self.bypass_patterns:
            if re.search(pattern, content, re.IGNORECASE | re.MULTILINE):
                detected_patterns.append(pattern)
        
        # Check for implementation keywords in context of file operations
        content_lower = content.lower()
        for keyword in self.implementation_keywords:
            if keyword in content_lower:
                # Additional context check - look for file operations nearby
                if any(op in content_lower for op in ["write(", "edit(", "create file", "implement function"]):
                    detected_patterns.append(f"implementation_keyword: {keyword}")
        
        return detected_patterns
    
    def _create_violation_message(self, pending_packages: List[Dict[str, Any]], patterns: List[str]) -> str:
        """Create violation message explaining why bypass is blocked"""
        
        package_summaries = []
        for pkg in pending_packages[:3]:  # Show first 3 packages
            pkg_summary = f"• {pkg.get('task_type', 'unknown')}: {pkg.get('description', 'No description')[:60]}..."
            package_summaries.append(pkg_summary)
        
        if len(pending_packages) > 3:
            package_summaries.append(f"• ... and {len(pending_packages) - 3} more packages")
        
        message = f"""
🚫 **DELEGATION BYPASS BLOCKED**

**VIOLATION**: Attempt to implement code directly when delegation system is available.

**PENDING WORK PACKAGES ({len(pending_packages)}):**
{chr(10).join(package_summaries)}

**DETECTED IMPLEMENTATION PATTERNS:**
{chr(10).join(f"• {pattern}" for pattern in patterns)}

**REQUIRED ACTION**: 
1. Let Ollama handle the pending work packages
2. Use: `python3 run_ollama_delegation.py` to process packages
3. Wait for Ollama results before proceeding

**CANONICAL PROTOCOL VIOLATION**: 
You MUST use the delegation system for coding tasks. Direct implementation is FORBIDDEN when delegation is available.

**ENFORCEMENT**: This request has been blocked to maintain system integrity.
"""
        
        return message
    
    def _log_violation(self, content: str, patterns: List[str]):
        """Log the violation for audit purposes"""
        try:
            self.enforcement_log.parent.mkdir(exist_ok=True)
            
            violation_entry = {
                "timestamp": datetime.now().isoformat(),
                "violation_type": "delegation_bypass",
                "patterns_detected": patterns,
                "content_preview": content[:200] + "..." if len(content) > 200 else content,
                "action": "blocked"
            }
            
            with open(self.enforcement_log, 'a') as f:
                f.write(json.dumps(violation_entry) + "\n")
                
            logger.warning(f"Delegation bypass blocked - {len(patterns)} patterns detected")
            
        except Exception as e:
            logger.error(f"Failed to log violation: {e}")
    
    def get_delegation_status(self) -> Dict[str, Any]:
        """Get current delegation system status"""
        pending_packages = self._get_pending_packages()
        
        return {
            "delegation_system_active": True,
            "pending_packages": len(pending_packages),
            "enforcement_active": True,
            "ollama_available": self._check_ollama_availability(),
            "package_details": [
                {
                    "id": pkg["id"][:8],
                    "type": pkg.get("task_type"),
                    "description": pkg.get("description", "")[:50] + "...",
                    "model": pkg.get("model"),
                    "created": pkg.get("created_at")
                }
                for pkg in pending_packages
            ]
        }
    
    def _check_ollama_availability(self) -> bool:
        """Check if Ollama service is available"""
        try:
            import requests
            response = requests.get("http://localhost:11444/api/tags", timeout=5)
            return response.status_code == 200
        except Exception:
            return False


def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle delegation enforcement for user prompts"""
    
    enforcer = DelegationEnforcer()
    content = input_data.get("content", "")
    
    if not content:
        return {"decision": "allow"}
    
    # Check for bypass attempts
    enforcement_result = enforcer.check_for_bypass_attempt(content, input_data)
    
    if enforcement_result["decision"] == "block":
        # Return blocking message
        return {
            "decision": "block",
            "message": enforcement_result["message"],
            "context": "Delegation enforcement active - bypass blocked"
        }
    
    # If no violation, add delegation status info
    status = enforcer.get_delegation_status()
    
    if status["pending_packages"] > 0:
        status_msg = f"""
📋 **Delegation Status**: {status['pending_packages']} work packages pending delegation
🤖 **Ollama**: {'✅ Available' if status['ollama_available'] else '❌ Unavailable'}
⚡ **Action**: Use `python3 run_ollama_delegation.py` to process packages
"""
        return {
            "decision": "allow",
            "context": status_msg,
            "delegation_status": status
        }
    
    return {"decision": "allow"}


if __name__ == "__main__":
    # Test the enforcer
    enforcer = DelegationEnforcer()
    
    # Test with implementation attempt
    test_content = """
    I'll implement the MCP validator function:
    
    ```python
    def validate_mcp_config(config_path: str):
        pass
    ```
    """
    
    result = enforcer.check_for_bypass_attempt(test_content, {})
    print("Enforcement Result:", result)
    
    # Show current status
    status = enforcer.get_delegation_status()
    print("Delegation Status:", json.dumps(status, indent=2))