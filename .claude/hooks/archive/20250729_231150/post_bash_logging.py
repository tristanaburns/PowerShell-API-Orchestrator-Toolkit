#!/usr/bin/env python3
"""
Post-Bash Logging Hook - Logs bash command execution results
Part of the Hive Mind Nexus Enterprise AI Orchestration Platform
"""
import sys
import json
import os
from pathlib import Path
from datetime import datetime

def main():
    """Main entry point for post-bash logging"""
    try:
        # Read input from stdin if available
        if not sys.stdin.isatty():
            input_data = sys.stdin.read()
            if input_data:
                try:
                    data = json.loads(input_data)
                    tool = data.get('tool', '')
                    params = data.get('params', {})
                    result = data.get('result', {})
                    
                    # Log the bash command and result
                    log_dir = Path(__file__).parent / 'logs'
                    log_dir.mkdir(exist_ok=True)
                    
                    timestamp = datetime.now().isoformat()
                    command = params.get('command', 'unknown')
                    exit_code = result.get('exit_code', 'N/A')
                    
                    with open(log_dir / 'bash_commands.log', 'a') as f:
                        f.write(f"[{timestamp}] Command: {command} | Exit Code: {exit_code}\n")
                    
                    # Log detailed output if needed
                    if result.get('output'):
                        with open(log_dir / 'bash_output.log', 'a') as f:
                            f.write(f"[{timestamp}] Command: {command}\n")
                            f.write(f"Output: {result.get('output', '')[:500]}...\n")
                            f.write("-" * 80 + "\n")
                    
                except json.JSONDecodeError:
                    # Not JSON, just continue
                    pass
        
        return 0
        
    except Exception as e:
        # Log error but don't block operations
        try:
            log_dir = Path(__file__).parent / 'logs'
            log_dir.mkdir(exist_ok=True)
            with open(log_dir / 'post_bash_logging_errors.log', 'a') as f:
                f.write(f"Error in post_bash_logging.py: {str(e)}\n")
        except:
            pass
        return 0

if __name__ == "__main__":
    sys.exit(main())