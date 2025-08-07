"""
Ollama Pipeline Module
Orchestrates the complete flow from work package to reviewed code
"""

import json
import logging
import asyncio
from pathlib import Path
from typing import Dict, Any, List
from datetime import datetime
import subprocess

from . import work_package_manager
from . import ollama_delegation
from . import devsecops_automation

logger = logging.getLogger(__name__)

class OllamaPipeline:
    """Complete pipeline from task detection to code review"""
    
    def __init__(self):
        self.work_manager = work_package_manager.WorkPackageManager()
        self.ollama = ollama_delegation.OllamaDelegation()
        self.devsecops = devsecops_automation.DevSecOpsAutomation()
        self.pipeline_dir = Path(__file__).parent.parent / "pipeline_results"
        self.pipeline_dir.mkdir(exist_ok=True)
    
    async def process_user_prompt(self, prompt: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Process user prompt through complete pipeline"""
        logger.info("Starting Ollama pipeline processing")
        
        # Step 1: Detect delegatable tasks
        tasks = self.work_manager.detect_delegatable_tasks(prompt)
        if not tasks:
            return {"decision": "allow", "message": "No delegatable tasks detected"}
        
        # Step 2: Create work packages
        packages = []
        for task in tasks:
            package = self.work_manager.create_work_package(task, context)
            packages.append(package)
        
        # Step 3: Process each package
        results = []
        for package in packages:
            result = await self.process_work_package(package)
            results.append(result)
        
        # Step 4: Generate summary for Claude
        summary = self.generate_pipeline_summary(results)
        
        return {
            "decision": "allow",
            "context": summary,
            "pipeline_results": results
        }
    
    async def process_work_package(self, package: Dict[str, Any]) -> Dict[str, Any]:
        """Process a single work package through the pipeline"""
        pipeline_result = {
            "package_id": package["id"],
            "task_type": package["task_type"],
            "status": "started",
            "stages": {}
        }
        
        try:
            # Stage 1: Ollama Generation
            logger.info(f"Delegating to Ollama: {package['id']}")
            ollama_result = self.ollama.delegate_to_ollama(package)
            pipeline_result["stages"]["ollama"] = ollama_result
            
            if not ollama_result["success"]:
                pipeline_result["status"] = "failed_generation"
                return pipeline_result
            
            # Stage 2: DevSecOps Checks
            logger.info(f"Running DevSecOps checks: {package['id']}")
            code_file = Path(ollama_result["output_file"])
            devsecops_result = await devsecops_automation.process_ollama_output(
                package, code_file
            )
            pipeline_result["stages"]["devsecops"] = devsecops_result
            
            # Stage 3: Auto-fix if needed
            if not devsecops_result["passed"]:
                logger.info(f"Attempting auto-fix: {package['id']}")
                fix_result = await self.attempt_auto_fix(
                    package, code_file, devsecops_result
                )
                pipeline_result["stages"]["auto_fix"] = fix_result
                
                if fix_result["success"]:
                    # Re-run DevSecOps checks
                    devsecops_result = await devsecops_automation.process_ollama_output(
                        package, code_file
                    )
                    pipeline_result["stages"]["devsecops_recheck"] = devsecops_result
            
            # Stage 4: Prepare for Claude review
            pipeline_result["status"] = "ready_for_review" if devsecops_result["passed"] else "needs_manual_fix"
            pipeline_result["code_file"] = str(code_file)
            
        except Exception as e:
            logger.error(f"Pipeline error for {package['id']}: {e}")
            pipeline_result["status"] = "error"
            pipeline_result["error"] = str(e)
        
        # Save pipeline result
        result_file = self.pipeline_dir / f"{package['id']}_pipeline.json"
        with open(result_file, 'w') as f:
            json.dump(pipeline_result, f, indent=2)
        
        return pipeline_result
    
    async def attempt_auto_fix(self, package: Dict[str, Any], code_file: Path, 
                              devsecops_result: Dict[str, Any]) -> Dict[str, Any]:
        """Attempt to automatically fix common issues"""
        fixes_applied = []
        
        # Auto-formatting
        if not devsecops_result["results"]["linting"]["success"]:
            if package["context"]["language"] == "python":
                # Run black to format
                subprocess.run(["black", str(code_file)], capture_output=True)
                fixes_applied.append("Applied black formatting")
                
                # Run isort
                subprocess.run(["isort", str(code_file)], capture_output=True)
                fixes_applied.append("Applied isort import sorting")
        
        # Add type hints if missing
        if not devsecops_result["results"]["type_checking"]["success"]:
            if package["context"]["language"] == "python":
                # Could use a tool like MonkeyType or pytype here
                fixes_applied.append("Type hints need manual addition")
        
        return {
            "success": len(fixes_applied) > 0,
            "fixes_applied": fixes_applied,
            "timestamp": datetime.now().isoformat()
        }
    
    def generate_pipeline_summary(self, results: List[Dict[str, Any]]) -> str:
        """Generate a summary of pipeline results for Claude"""
        summary = f"""
# 🤖 Ollama Pipeline Results

**Processed {len(results)} work packages**

"""
        
        for result in results:
            package_id = result["package_id"][:8]
            task_type = result["task_type"]
            status = result["status"]
            
            status_emoji = {
                "ready_for_review": "✅",
                "needs_manual_fix": "⚠️",
                "failed_generation": "❌",
                "error": "🔥"
            }.get(status, "❓")
            
            summary += f"\n## {status_emoji} Package {package_id} - {task_type}\n"
            
            # Ollama stage
            if "ollama" in result["stages"]:
                ollama = result["stages"]["ollama"]
                if ollama["success"]:
                    summary += f"- **Generated**: {ollama.get('generation_time', 'N/A'):.2f}s\n"
                    summary += f"- **Model**: {ollama.get('model', 'N/A')}\n"
                else:
                    summary += f"- **Generation Failed**: {ollama.get('error', 'Unknown error')}\n"
            
            # DevSecOps stage
            if "devsecops" in result["stages"]:
                devsecops = result["stages"]["devsecops"]
                if devsecops["passed"]:
                    summary += "- **Quality Checks**: ✅ All passed\n"
                else:
                    summary += "- **Quality Checks**: ❌ Failed\n"
                    failed_checks = [k for k, v in devsecops["results"].items() 
                                   if isinstance(v, dict) and not v.get("success", True)]
                    if failed_checks:
                        summary += f"  - Failed: {', '.join(failed_checks)}\n"
            
            # Auto-fix stage
            if "auto_fix" in result["stages"]:
                fix = result["stages"]["auto_fix"]
                if fix["success"]:
                    summary += f"- **Auto-fixes Applied**: {', '.join(fix['fixes_applied'])}\n"
            
            # Final status
            if status == "ready_for_review":
                summary += f"\n📄 **Ready for your review**: `{result['code_file']}`\n"
            elif status == "needs_manual_fix":
                summary += f"\n⚠️ **Needs manual fixes**: `{result['code_file']}`\n"
        
        summary += """
## Next Actions:
1. Review the generated code files
2. Accept/reject implementations
3. Request improvements if needed

Use `REVIEW_CODE: <package_id>` to review a specific implementation.
"""
        
        return summary

class ClaudeReviewWorkflow:
    """Handles Claude's review of Ollama-generated code"""
    
    def __init__(self):
        self.reviews_dir = Path(__file__).parent.parent / "code_reviews"
        self.reviews_dir.mkdir(exist_ok=True)
    
    async def review_code(self, pipeline_result: Dict[str, Any]) -> Dict[str, Any]:
        """Claude reviews the generated code"""
        code_file = Path(pipeline_result["code_file"])
        package_id = pipeline_result["package_id"]
        
        # Read the generated code
        with open(code_file, 'r', encoding='utf-8') as f:
            code = f.read()
        
        # Perform review checks
        review = {
            "package_id": package_id,
            "timestamp": datetime.now().isoformat(),
            "code_file": str(code_file),
            "checks": {}
        }
        
        # Architecture compliance
        review["checks"]["architecture"] = self.check_architecture_compliance(code)
        
        # Security best practices
        review["checks"]["security"] = self.check_security_practices(code)
        
        # Code quality
        review["checks"]["quality"] = self.check_code_quality(code)
        
        # Performance considerations
        review["checks"]["performance"] = self.check_performance(code)
        
        # Overall decision
        all_passed = all(check.get("passed", False) for check in review["checks"].values())
        review["decision"] = "approved" if all_passed else "needs_improvement"
        
        # Generate feedback
        review["feedback"] = self.generate_feedback(review["checks"])
        
        # Save review
        review_file = self.reviews_dir / f"{package_id}_review.json"
        with open(review_file, 'w') as f:
            json.dump(review, f, indent=2)
        
        return review
    
    def check_architecture_compliance(self, code: str) -> Dict[str, Any]:
        """Check if code follows architectural patterns"""
        issues = []
        
        # Check for proper imports
        if "import" in code and "from . import" not in code:
            issues.append("Consider using relative imports for local modules")
        
        # Check for error handling
        if "try:" not in code and "except" not in code:
            issues.append("Missing error handling")
        
        return {
            "passed": len(issues) == 0,
            "issues": issues
        }
    
    def check_security_practices(self, code: str) -> Dict[str, Any]:
        """Check for security best practices"""
        issues = []
        
        # Check for hardcoded secrets
        patterns = ["password=", "api_key=", "secret=", "token="]
        for pattern in patterns:
            if pattern in code.lower() and '"' in code:
                issues.append(f"Potential hardcoded secret: {pattern}")
        
        # Check for SQL injection risks
        if "query" in code and "%" in code:
            issues.append("Use parameterized queries to prevent SQL injection")
        
        return {
            "passed": len(issues) == 0,
            "issues": issues
        }
    
    def check_code_quality(self, code: str) -> Dict[str, Any]:
        """Check general code quality"""
        issues = []
        
        # Check for documentation
        if '"""' not in code and "'''" not in code:
            issues.append("Missing docstrings")
        
        # Check for magic numbers
        import re
        numbers = re.findall(r'\b\d+\b', code)
        if len(numbers) > 5:
            issues.append("Consider using named constants instead of magic numbers")
        
        return {
            "passed": len(issues) == 0,
            "issues": issues
        }
    
    def check_performance(self, code: str) -> Dict[str, Any]:
        """Check for performance considerations"""
        issues = []
        
        # Check for potential N+1 queries
        if "for" in code and ("query" in code or "fetch" in code):
            issues.append("Potential N+1 query pattern detected")
        
        # Check for inefficient operations
        if "in" in code and "list" in code and len(code) > 500:
            issues.append("Consider using set for membership testing")
        
        return {
            "passed": len(issues) == 0,
            "issues": issues
        }
    
    def generate_feedback(self, checks: Dict[str, Any]) -> str:
        """Generate constructive feedback"""
        feedback = []
        
        for check_name, result in checks.items():
            if not result["passed"]:
                feedback.append(f"\n**{check_name.title()} Issues:**")
                for issue in result["issues"]:
                    feedback.append(f"- {issue}")
        
        if not feedback:
            return "Great work! The code meets all quality standards."
        
        return "The code needs improvements in the following areas:" + "\n".join(feedback)

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle pipeline orchestration"""
    pipeline = OllamaPipeline()
    
    # Extract prompt from input
    prompt = input_data.get("content", "")
    if not prompt:
        return {"decision": "allow"}
    
    # Check for review requests
    if "REVIEW_CODE:" in prompt:
        # Handle code review
        package_id = prompt.split("REVIEW_CODE:")[1].strip()
        reviewer = ClaudeReviewWorkflow()
        # Load pipeline result and review
        # ... implementation
        return {"decision": "allow", "message": "Review functionality coming soon"}
    
    # Otherwise, process through pipeline
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    result = loop.run_until_complete(
        pipeline.process_user_prompt(prompt, input_data)
    )
    
    return result