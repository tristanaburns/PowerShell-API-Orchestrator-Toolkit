"""
DevSecOps Automation Module
Automatically runs quality checks on code from Ollama
"""

import json
import logging
import subprocess
from pathlib import Path
from typing import Dict, Any, List, Tuple
import asyncio

logger = logging.getLogger(__name__)

class DevSecOpsAutomation:
    """Automates DevSecOps checks on generated code"""
    
    def __init__(self):
        self.checks_dir = Path(__file__).parent.parent / "devsecops_results"
        self.checks_dir.mkdir(exist_ok=True)
    
    async def run_all_checks(self, code_file: Path, language: str) -> Dict[str, Any]:
        """Run all DevSecOps checks on code"""
        results = {
            "linting": await self.run_linting(code_file, language),
            "type_checking": await self.run_type_checking(code_file, language),
            "security": await self.run_security_scan(code_file, language),
            "tests": await self.run_tests(code_file),
            "coverage": await self.check_coverage(code_file)
        }
        
        results["passed"] = all(r["success"] for r in results.values() if r)
        return results
    
    async def run_linting(self, code_file: Path, language: str) -> Dict[str, Any]:
        """Run linting based on language"""
        linters = {
            "python": ["black", "--check", str(code_file)],
            "javascript": ["eslint", str(code_file)],
            "typescript": ["eslint", str(code_file)],
            "go": ["gofmt", "-l", str(code_file)],
            "rust": ["rustfmt", "--check", str(code_file)]
        }
        
        if language not in linters:
            return {"success": True, "message": "No linter configured"}
        
        try:
            result = subprocess.run(
                linters[language],
                capture_output=True,
                text=True
            )
            
            return {
                "success": result.returncode == 0,
                "output": result.stdout or result.stderr,
                "command": " ".join(linters[language])
            }
        except Exception as e:
            logger.error(f"Linting failed: {e}")
            return {"success": False, "error": str(e)}
    
    async def run_type_checking(self, code_file: Path, language: str) -> Dict[str, Any]:
        """Run type checking"""
        type_checkers = {
            "python": ["mypy", str(code_file)],
            "typescript": ["tsc", "--noEmit", str(code_file)]
        }
        
        if language not in type_checkers:
            return {"success": True, "message": "No type checker configured"}
        
        try:
            result = subprocess.run(
                type_checkers[language],
                capture_output=True,
                text=True
            )
            
            return {
                "success": result.returncode == 0,
                "output": result.stdout or result.stderr,
                "command": " ".join(type_checkers[language])
            }
        except Exception as e:
            logger.error(f"Type checking failed: {e}")
            return {"success": False, "error": str(e)}
    
    async def run_security_scan(self, code_file: Path, language: str) -> Dict[str, Any]:
        """Run security scanning"""
        scanners = {
            "python": ["bandit", "-r", str(code_file)],
            "javascript": ["semgrep", "--config=auto", str(code_file)],
            "go": ["gosec", str(code_file)]
        }
        
        if language not in scanners:
            return {"success": True, "message": "No security scanner configured"}
        
        try:
            result = subprocess.run(
                scanners[language],
                capture_output=True,
                text=True
            )
            
            # Security scanners often return non-zero for findings
            has_issues = "No issues" not in result.stdout
            
            return {
                "success": not has_issues,
                "output": result.stdout or result.stderr,
                "command": " ".join(scanners[language]),
                "has_security_issues": has_issues
            }
        except Exception as e:
            logger.error(f"Security scan failed: {e}")
            return {"success": False, "error": str(e)}
    
    async def run_tests(self, code_file: Path) -> Dict[str, Any]:
        """Run associated tests"""
        # Find test file
        test_patterns = [
            code_file.parent / f"test_{code_file.name}",
            code_file.parent / "tests" / f"test_{code_file.name}",
            code_file.parent.parent / "tests" / f"test_{code_file.name}"
        ]
        
        test_file = None
        for pattern in test_patterns:
            if pattern.exists():
                test_file = pattern
                break
        
        if not test_file:
            return {"success": True, "message": "No test file found"}
        
        try:
            # Detect test runner
            if test_file.suffix == ".py":
                cmd = ["pytest", "-v", str(test_file)]
            elif test_file.suffix in [".js", ".ts"]:
                cmd = ["jest", str(test_file)]
            else:
                return {"success": True, "message": "No test runner configured"}
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            return {
                "success": result.returncode == 0,
                "output": result.stdout or result.stderr,
                "command": " ".join(cmd)
            }
        except Exception as e:
            logger.error(f"Test execution failed: {e}")
            return {"success": False, "error": str(e)}
    
    async def check_coverage(self, code_file: Path) -> Dict[str, Any]:
        """Check test coverage"""
        try:
            if code_file.suffix == ".py":
                cmd = ["pytest", "--cov", str(code_file.stem), "--cov-report=json"]
                result = subprocess.run(cmd, capture_output=True, text=True)
                
                # Parse coverage report
                coverage_file = Path("coverage.json")
                if coverage_file.exists():
                    with open(coverage_file) as f:
                        coverage_data = json.load(f)
                        percent = coverage_data.get("totals", {}).get("percent_covered", 0)
                        
                    return {
                        "success": percent >= 80,
                        "coverage_percent": percent,
                        "message": f"Coverage: {percent}%"
                    }
            
            return {"success": True, "message": "Coverage check not configured"}
            
        except Exception as e:
            logger.error(f"Coverage check failed: {e}")
            return {"success": False, "error": str(e)}
    
    def generate_report(self, work_package: Dict[str, Any], results: Dict[str, Any]) -> str:
        """Generate DevSecOps report"""
        report = f"""
# DevSecOps Report
**Work Package ID**: {work_package['id'][:8]}
**Task Type**: {work_package['task_type']}
**Description**: {work_package['description']}

## Check Results:
"""
        
        for check, result in results.items():
            if isinstance(result, dict) and "success" in result:
                status = "✅ PASSED" if result["success"] else "❌ FAILED"
                report += f"\n### {check.title()}: {status}\n"
                
                if result.get("output"):
                    report += f"```\n{result['output'][:500]}\n```\n"
                elif result.get("message"):
                    report += f"{result['message']}\n"
        
        report += f"\n## Overall Status: {'✅ PASSED' if results.get('passed') else '❌ FAILED'}\n"
        
        return report

async def process_ollama_output(work_package: Dict[str, Any], code_file: Path) -> Dict[str, Any]:
    """Process code generated by Ollama through DevSecOps pipeline"""
    automation = DevSecOpsAutomation()
    
    # Run all checks
    language = work_package["context"]["language"]
    results = await automation.run_all_checks(code_file, language)
    
    # Generate report
    report = automation.generate_report(work_package, results)
    
    # Save report
    report_file = automation.checks_dir / f"{work_package['id']}_report.md"
    with open(report_file, 'w') as f:
        f.write(report)
    
    return {
        "passed": results["passed"],
        "results": results,
        "report": report,
        "report_file": str(report_file)
    }

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle DevSecOps automation for Ollama-generated code"""
    # This would be triggered after Ollama generates code
    work_package_id = input_data.get("work_package_id")
    code_file = input_data.get("code_file")
    
    if not work_package_id or not code_file:
        return {"decision": "allow"}
    
    # Load work package
    package_file = Path(__file__).parent.parent / "work_packages" / f"{work_package_id}.json"
    if not package_file.exists():
        return {"decision": "allow", "error": "Work package not found"}
    
    with open(package_file) as f:
        work_package = json.load(f)
    
    # Run DevSecOps checks asynchronously
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    results = loop.run_until_complete(
        process_ollama_output(work_package, Path(code_file))
    )
    
    if results["passed"]:
        context = f"""
✅ **DevSecOps Checks Passed!**

{results['report']}

The code from Ollama has passed all quality checks and is ready for your review.
"""
    else:
        context = f"""
❌ **DevSecOps Checks Failed**

{results['report']}

The code needs improvements. Would you like me to:
1. Send feedback to Ollama for fixes
2. Fix the issues myself
3. Review the specific failures
"""
    
    return {
        "decision": "allow",
        "context": context,
        "devsecops_results": results
    }