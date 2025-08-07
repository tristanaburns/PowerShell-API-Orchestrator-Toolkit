#!/usr/bin/env python3
"""
Launch 5 sequential analytics tasks using fixed production system
"""

import sys
import os
import time
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'modules'))

from async_ollama_launcher import launch_async_task

def create_analytics_tasks():
    """Create 5 sequential analytics tasks"""
    
    timestamp = int(time.time())
    
    tasks = [
        {
            "id": f"analytics-001-{timestamp}",
            "created_at": time.strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
            "task_type": "function_implementation",
            "description": "create a Python class called CodeMetricsCollector that analyzes Python files and collects code metrics",
            "requirements": [
                "Analyze Python files using AST parsing",
                "Calculate cyclomatic complexity for functions", 
                "Count lines of code, classes, functions, and imports",
                "Extract dependency information from imports",
                "Handle multiple file analysis with summary statistics",
                "Include error handling and logging"
            ],
            "context": {
                "language": "python",
                "project_root": "/mnt/c/GitHub_Development/projects/hive-mind-nexus/.claude/hooks",
                "framework": None
            },
            "devsecops_checks": {
                "linting": True,
                "type_checking": True,
                "security_scan": True,
                "unit_tests": True,
                "coverage_threshold": 80
            }
        },
        {
            "id": f"analytics-002-{timestamp + 1}",
            "created_at": time.strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
            "task_type": "function_implementation", 
            "description": "create a Python class called PerformanceProfiler that measures execution time, memory usage, and resource consumption",
            "requirements": [
                "Measure function execution time with high precision",
                "Track memory usage before/after function calls",
                "Monitor CPU usage during execution",
                "Generate detailed performance reports with statistics",
                "Support context manager usage for easy profiling",
                "Include comparison tools for performance benchmarking"
            ],
            "context": {
                "language": "python",
                "project_root": "/mnt/c/GitHub_Development/projects/hive-mind-nexus/.claude/hooks",
                "framework": None
            },
            "devsecops_checks": {
                "linting": True,
                "type_checking": True,
                "security_scan": True,
                "unit_tests": True,
                "coverage_threshold": 80
            }
        },
        {
            "id": f"analytics-003-{timestamp + 2}",
            "created_at": time.strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
            "task_type": "function_implementation",
            "description": "create a Python class called SecurityAuditor that scans code for security vulnerabilities and unsafe patterns",
            "requirements": [
                "Detect common security vulnerabilities (SQL injection, XSS, etc.)",
                "Check for unsafe function usage (eval, exec, etc.)",
                "Validate input sanitization and validation patterns", 
                "Analyze authentication and authorization implementations",
                "Generate security audit reports",
                "Include severity ratings and remediation suggestions"
            ],
            "context": {
                "language": "python",
                "project_root": "/mnt/c/GitHub_Development/projects/hive-mind-nexus/.claude/hooks",
                "framework": None
            },
            "devsecops_checks": {
                "linting": True,
                "type_checking": True,
                "security_scan": True,
                "unit_tests": True,
                "coverage_threshold": 80
            }
        },
        {
            "id": f"analytics-004-{timestamp + 3}",
            "created_at": time.strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
            "task_type": "function_implementation",
            "description": "create a Python class called TestCoverageAnalyzer that analyzes test coverage and identifies gaps",
            "requirements": [
                "Parse test files and identify test cases",
                "Map test cases to source code functions",
                "Calculate coverage percentages by module/function",
                "Identify untested code paths and functions",
                "Generate detailed coverage reports with recommendations",
                "Support multiple test frameworks (pytest, unittest)"
            ],
            "context": {
                "language": "python",
                "project_root": "/mnt/c/GitHub_Development/projects/hive-mind-nexus/.claude/hooks",
                "framework": None
            },
            "devsecops_checks": {
                "linting": True,
                "type_checking": True,
                "security_scan": True,
                "unit_tests": True,
                "coverage_threshold": 80
            }
        },
        {
            "id": f"analytics-005-{timestamp + 4}",
            "created_at": time.strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
            "task_type": "function_implementation",
            "description": "create a Python class called AnalyticsDashboard that aggregates all analytics data into reports",
            "requirements": [
                "Integrate data from CodeMetricsCollector, PerformanceProfiler, SecurityAuditor, TestCoverageAnalyzer",
                "Generate HTML dashboard with charts and visualizations",
                "Calculate overall code quality scores and ratings",
                "Provide actionable recommendations for improvements",
                "Export reports in multiple formats (HTML, PDF, JSON)",
                "Include trend analysis and historical comparisons"
            ],
            "context": {
                "language": "python", 
                "project_root": "/mnt/c/GitHub_Development/projects/hive-mind-nexus/.claude/hooks",
                "framework": None
            }
        }
    ]
    
    return tasks

def launch_all_tasks():
    """Launch all 5 tasks sequentially"""
    
    tasks = create_analytics_tasks()
    
    print("🚀 Launching 5 Sequential Analytics Tasks")
    print("=" * 60)
    
    for i, task in enumerate(tasks, 1):
        print(f"Task {i}: {task['description'][:50]}...")
        task_id = launch_async_task(task)
        print(f"  ✅ Launched: {task_id}")
        time.sleep(0.1)  # Brief delay between submissions
    
    print("\n📊 All tasks submitted to sequential processor")
    print("💡 Tasks will process one at a time with Qwen 14B")
    print("📁 Check ollama_status/ for progress")
    print("📁 Check ollama_results/ for generated code")

if __name__ == "__main__":
    launch_all_tasks()