#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HOOK TIMEOUT HANDLER
Demonstrates timeout handling and optimization for Claude Code hooks
Default timeout: 60 seconds (configurable per command)

CANONICAL INSTRUCTION: NO POWERSHELL - PYTHON ONLY
"""

import sys
import json
import os
import time
import signal
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('HookTimeoutHandler')

class TimeoutError(Exception):
    """Custom timeout error for hook execution"""
    
    def __init__(self, message: str = "Hook execution timeout", 
                 timeout_seconds: Optional[int] = None, hook_name: Optional[str] = None):
        super().__init__(message)
        self.timeout_seconds = timeout_seconds
        self.hook_name = hook_name
        self.timestamp = datetime.now().isoformat()
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for logging"""
        return {
            "error": "timeout_error",
            "message": str(self),
            "timeout_seconds": self.timeout_seconds,
            "hook_name": self.hook_name,
            "timestamp": self.timestamp
        }

def timeout_handler(signum, frame):
    """Signal handler for timeout"""
    raise TimeoutError("Hook execution timeout")

def execute_with_timeout(func, timeout_seconds=55):
    """Execute a function with timeout (leaving 5s buffer for cleanup)"""
    # Set the signal handler
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(timeout_seconds)
    
    try:
        result = func()
        signal.alarm(0)  # Disable the alarm
        return result
    except TimeoutError:
        logger.error(f"Function timed out after {timeout_seconds} seconds")
        return None
    finally:
        signal.alarm(0)  # Ensure alarm is disabled

def estimate_execution_time(task_type, context):
    """Estimate how long a task might take"""
    estimates = {
        'quick_validation': 2,
        'code_formatting': 5,
        'linting': 10,
        'testing': 30,
        'build': 45,
        'complex_analysis': 50
    }
    
    return estimates.get(task_type, 10)

def prioritize_tasks(tasks, available_time=55):
    """Prioritize tasks to fit within timeout window"""
    prioritized = []
    time_used = 0
    
    # Sort by priority and estimated time
    sorted_tasks = sorted(tasks, key=lambda x: (x['priority'], x['estimated_time']))
    
    for task in sorted_tasks:
        if time_used + task['estimated_time'] <= available_time:
            prioritized.append(task)
            time_used += task['estimated_time']
        else:
            logger.warning(f"Skipping task {task['name']} - would exceed timeout")
    
    return prioritized

def optimize_for_timeout(operations):
    """Optimize operations to complete within timeout"""
    optimizations = {
        'parallel_execution': True,
        'cache_results': True,
        'skip_non_critical': True,
        'use_quick_checks': True
    }
    
    # Apply optimizations
    optimized_ops = []
    for op in operations:
        if op.get('critical', True) or optimizations['skip_non_critical'] is False:
            if op.get('can_parallelize') and optimizations['parallel_execution']:
                op['execution_mode'] = 'parallel'
            if op.get('cacheable') and optimizations['cache_results']:
                op['use_cache'] = True
            optimized_ops.append(op)
    
    return optimized_ops

def main():
    """Main hook execution with timeout awareness"""
    start_time = time.time()
    
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            return {"success": False, "error": "No input received"}
        
        # Parse the hook input
        hook_data = json.loads(input_json)
        
        # Extract context
        session_id = hook_data.get('sessionId', 'unknown')
        tool_name = hook_data.get('toolName', 'unknown')
        
        logger.info(f"Hook execution started - 60 second timeout window")
        
        # Define tasks with time estimates
        tasks = [
            {
                'name': 'validation',
                'type': 'quick_validation',
                'priority': 1,
                'estimated_time': 2,
                'critical': True
            },
            {
                'name': 'formatting',
                'type': 'code_formatting',
                'priority': 2,
                'estimated_time': 5,
                'critical': True
            },
            {
                'name': 'linting',
                'type': 'linting',
                'priority': 3,
                'estimated_time': 10,
                'critical': False
            },
            {
                'name': 'testing',
                'type': 'testing',
                'priority': 4,
                'estimated_time': 30,
                'critical': False
            }
        ]
        
        # Prioritize tasks to fit within timeout
        prioritized_tasks = prioritize_tasks(tasks, available_time=50)  # Keep 10s buffer
        
        executed_tasks = []
        
        for task in prioritized_tasks:
            task_start = time.time()
            
            # Check remaining time
            elapsed = time.time() - start_time
            remaining = 55 - elapsed  # 5s cleanup buffer
            
            if remaining < task['estimated_time']:
                logger.warning(f"Insufficient time for task {task['name']}, skipping")
                break
            
            logger.info(f"Executing task {task['name']} (est. {task['estimated_time']}s)")
            
            # Simulate task execution
            time.sleep(min(1, task['estimated_time']))  # Simulate work
            
            task_duration = time.time() - task_start
            executed_tasks.append({
                'name': task['name'],
                'duration': task_duration,
                'success': True
            })
            
            logger.info(f"Task {task['name']} completed in {task_duration:.2f}s")
        
        # Prepare response
        total_duration = time.time() - start_time
        
        response = {
            'success': True,
            'message': 'Hook execution completed within timeout',
            'execution_time': total_duration,
            'timeout_limit': 60,
            'time_remaining': 60 - total_duration,
            'tasks_executed': len(executed_tasks),
            'tasks_skipped': len(tasks) - len(executed_tasks),
            'executed_tasks': executed_tasks,
            'optimization_applied': True,
            'timestamp': datetime.now().isoformat()
        }
        
        # Ensure we complete before timeout
        if total_duration > 55:
            logger.warning(f"Hook execution took {total_duration:.2f}s - close to timeout!")
        
        print(json.dumps(response))
        sys.exit(0)
        
    except json.JSONDecodeError as e:
        error_response = {
            'success': False,
            'error': f'JSON decode error: {str(e)}',
            'execution_time': time.time() - start_time,
            'timestamp': datetime.now().isoformat()
        }
        print(json.dumps(error_response))
        sys.exit(1)
        
    except TimeoutError:
        error_response = {
            'success': False,
            'error': 'Hook execution timeout (60s limit)',
            'execution_time': time.time() - start_time,
            'partial_results': executed_tasks if 'executed_tasks' in locals() else [],
            'timestamp': datetime.now().isoformat()
        }
        print(json.dumps(error_response))
        sys.exit(1)
        
    except Exception as e:
        error_response = {
            'success': False,
            'error': f'Unexpected error: {str(e)}',
            'execution_time': time.time() - start_time,
            'timestamp': datetime.now().isoformat()
        }
        logger.error(f"Hook execution failed: {e}")
        print(json.dumps(error_response))
        sys.exit(1)

if __name__ == '__main__':
    main()