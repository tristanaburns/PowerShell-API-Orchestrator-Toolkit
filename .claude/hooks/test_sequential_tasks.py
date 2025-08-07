"""
Test Sequential Qwen 14B Tasks - Advanced Code Analytics Dashboard
Tests the async queuing system with 5 sequential interdependent tasks
"""

import sys
sys.path.append('modules')
from async_ollama_launcher import launch_async_task, get_task_status, list_active_tasks
import json
import time
from datetime import datetime

def create_test_work_packages():
    """Create 5 sequential work packages for code analytics dashboard"""
    
    base_timestamp = datetime.now().isoformat()
    
    tasks = [
        {
            "id": f"analytics-001-{int(time.time())}",
            "created_at": base_timestamp,
            "task_type": "function_implementation",
            "description": "create a Python class called CodeMetricsCollector that analyzes Python files and collects metrics like lines of code, complexity, dependencies, and function count",
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
            "id": f"analytics-002-{int(time.time())+1}",
            "created_at": base_timestamp,
            "task_type": "function_implementation", 
            "description": "create a Python class called PerformanceProfiler that measures execution time, memory usage, and resource consumption of code functions with detailed profiling reports",
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
            "id": f"analytics-003-{int(time.time())+2}",
            "created_at": base_timestamp,
            "task_type": "function_implementation",
            "description": "create a Python class called SecurityAuditor that scans code for security vulnerabilities, checks for unsafe patterns, validates input handling, and generates security reports",
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
            "id": f"analytics-004-{int(time.time())+3}",
            "created_at": base_timestamp,
            "task_type": "function_implementation",
            "description": "create a Python class called TestCoverageAnalyzer that analyzes test coverage, identifies untested code paths, generates coverage reports, and suggests test improvements",
            "requirements": [
                "Parse and analyze test coverage data from multiple formats",
                "Identify uncovered lines, branches, and functions",
                "Generate visual coverage reports with percentages",
                "Suggest specific test cases for uncovered code",
                "Track coverage trends over time",
                "Integration with popular testing frameworks (pytest, unittest)"
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
            "id": f"analytics-005-{int(time.time())+4}",
            "created_at": base_timestamp,
            "task_type": "function_implementation",
            "description": "create a Python class called AnalyticsDashboard that integrates all previous components (CodeMetricsCollector, PerformanceProfiler, SecurityAuditor, TestCoverageAnalyzer) into a unified dashboard with reporting and visualization",
            "requirements": [
                "Integrate all four analytics components into a single interface",
                "Generate project health reports", 
                "Create visualizations for metrics, performance, security, and coverage",
                "Export reports in multiple formats (JSON, HTML, PDF)",
                "Provide real-time dashboard updates and notifications",
                "Include historical tracking and trend analysis",
                "Support multiple project analysis and comparison"
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
        }
    ]
    
    return tasks

def launch_sequential_test():
    """Launch all 5 tasks sequentially and monitor progress"""
    
    print("🚀 Starting Sequential Qwen 14B Test - Advanced Code Analytics Dashboard")
    print("=" * 70)
    
    # Create the work packages
    tasks = create_test_work_packages()
    task_ids = []
    
    # Launch all tasks 
    for i, task in enumerate(tasks, 1):
        print(f"\n📋 Launching Task {i}/5: {task['description'][:60]}...")
        task_id = launch_async_task(task)
        task_ids.append(task_id)
        print(f"   Task ID: {task_id}")
        
        # Small delay between launches
        time.sleep(1)
    
    print(f"\n✅ All 5 tasks queued successfully!")
    print(f"📊 Task IDs: {task_ids}")
    
    return task_ids

def monitor_progress(task_ids):
    """Monitor the progress of all tasks"""
    
    print("\n🔍 Monitoring Task Progress...")
    print("=" * 70)
    
    completed_tasks = set()
    max_iterations = 100  # Prevent infinite loop
    iterations = 0
    
    while len(completed_tasks) < len(task_ids) and iterations < max_iterations:
        iterations += 1
        
        print(f"\n--- Progress Check #{iterations} ---")
        
        for i, task_id in enumerate(task_ids, 1):
            if task_id in completed_tasks:
                continue
                
            status = get_task_status(task_id)
            current_status = status.get('status', 'unknown')
            message = status.get('message', 'No message')
            
            print(f"Task {i}: {current_status.upper()} - {message}")
            
            if current_status in ['completed', 'failed', 'error', 'timeout']:
                completed_tasks.add(task_id)
                
                if current_status == 'completed':
                    completion_data = status.get('completion_data', {})
                    code_quality = completion_data.get('code_quality', {})
                    print(f"         ✅ Code Quality: {code_quality}")
                    
        # Show active tasks
        active_tasks = list_active_tasks()
        if active_tasks:
            print(f"\n📊 Active Tasks in Queue: {len(active_tasks)}")
            for task in active_tasks:
                print(f"   - {task.get('task_id', 'unknown')}: {task.get('status', 'unknown')}")
        
        if len(completed_tasks) < len(task_ids):
            print(f"\n⏳ Waiting 10 seconds... ({len(completed_tasks)}/{len(task_ids)} completed)")
            time.sleep(10)
        
    print(f"\n🎉 Test Complete! {len(completed_tasks)}/{len(task_ids)} tasks finished")
    return completed_tasks

def generate_final_report(task_ids):
    """Generate final test report"""
    
    print("\n📊 Final Test Report")
    print("=" * 70)
    
    for i, task_id in enumerate(task_ids, 1):
        status = get_task_status(task_id)
        
        print(f"\nTask {i}: {task_id}")
        print(f"  Status: {status.get('status', 'unknown')}")
        print(f"  Message: {status.get('message', 'No message')}")
        
        if status.get('status') == 'completed':
            completion_data = status.get('completion_data', {})
            output_file = completion_data.get('output_file', 'Unknown')
            code_quality = completion_data.get('code_quality', {})
            
            print(f"  Output File: {output_file}")
            print(f"  Code Quality: {code_quality}")
            
        print(f"  Full Status: {json.dumps(status, indent=2)}")

if __name__ == "__main__":
    # Run the complete test
    task_ids = launch_sequential_test()
    completed = monitor_progress(task_ids)
    generate_final_report(task_ids)
    
    print("\n🎯 Sequential Qwen 14B Test Results:")
    print(f"   Total Tasks: {len(task_ids)}")
    print(f"   Completed: {len(completed)}")
    print(f"   Success Rate: {len(completed)/len(task_ids)*100:.1f}%")