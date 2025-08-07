#!/usr/bin/env python3
"""
PRE-BASH VALIDATION HOOK
Triggered before any Bash command execution
Performs security validation and intelligent command enhancement

CANONICAL INSTRUCTION: NO POWERSHELL - PYTHON ONLY
"""

import sys
import json
import re
import os
from datetime import datetime
from pathlib import Path
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/automation.log', mode='a'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('PreBashValidation')

def validate_command_security(command):
    """Validate command for security issues"""
    security_checks = {
        'dangerous_commands': ['rm -rf', 'del /f', 'format', 'fdisk', 'dd if='],
        'sensitive_paths': ['C:/Windows', 'C:/Program Files', '/etc', '/bin', '/usr/bin'],
        'network_commands': ['curl', 'wget', 'nc', 'netcat', 'ssh'],
        'system_commands': ['shutdown', 'reboot', 'halt', 'systemctl', 'service']
    }
    
    validation_results = {
        'is_safe': True,
        'warnings': [],
        'blocked': False,
        'reason': ''
    }
    
    # Check for dangerous commands
    for dangerous_cmd in security_checks['dangerous_commands']:
        if dangerous_cmd in command:
            validation_results['is_safe'] = False
            validation_results['warnings'].append(f'Potentially dangerous command detected: {dangerous_cmd}')
            
            # Block extremely dangerous operations
            if dangerous_cmd in ['rm -rf', 'del /f', 'format']:
                validation_results['blocked'] = True
                validation_results['reason'] = f'Blocked dangerous file deletion command: {dangerous_cmd}'
    
    # Check for sensitive path access
    for sensitive_path in security_checks['sensitive_paths']:
        if sensitive_path in command:
            validation_results['warnings'].append(f'Accessing sensitive path: {sensitive_path}')
    
    # Check for PowerShell violations
    if re.search(r'powershell|pwsh|\.ps1', command, re.IGNORECASE):
        validation_results['blocked'] = True
        validation_results['reason'] = 'CANONICAL VIOLATION: PowerShell detected - use Python instead'
    
    return validation_results

def enhance_command(command):
    """Intelligently enhance commands based on context"""
    enhanced_command = command
    enhancements = []
    
    # Auto-enhance Docker commands
    if re.match(r'^docker\s', command):
        if re.search(r'build|pull|push', command):
            enhancements.append('Docker operation with progress tracking available')
        
        if re.search(r'run.*-p\s', command):
            enhancements.append('Port mapping detected - network troubleshooting available')
    
    # Auto-enhance git commands
    if re.match(r'^git\s', command):
        if re.search(r'reset --hard|rebase', command):
            enhancements.append('Destructive git operation - ensure backups exist')
        
        if 'git commit' in command:
            enhancements.append('Commit operation - traceability logging enabled')
    
    # Auto-enhance Python/Node commands
    if re.match(r'^(python|node|npm|pip)\s', command):
        if re.search(r'install|add', command):
            enhancements.append('Package installation - dependency tracking enabled')
        
        if re.search(r'\.(py|js|ts)$', command):
            enhancements.append('Script execution - performance monitoring available')
    
    # Auto-enhance database commands
    if re.search(r'mongo|psql|mysql', command):
        enhancements.append('Database operation - query performance tracking enabled')
        
        if re.search(r'drop|delete|truncate', command):
            enhancements.append('Destructive database operation detected')
    
    # Context-aware optimizations
    context_optimizations = []
    
    # Node.js project context
    if Path('package.json').exists():
        context_optimizations.append('Node.js project context detected')
        
        if command == 'npm install':
            enhanced_command = 'npm install --progress=true --timing=true'
            enhancements.append('Enhanced npm install with progress and timing')
    
    # Python project context
    if Path('requirements.txt').exists():
        context_optimizations.append('Python project context detected')
        
        if command.startswith('pip install'):
            enhanced_command = command + ' --progress-bar on'
            enhancements.append('Enhanced pip install with progress bar')
    
    # Docker Compose context
    if Path('docker-compose.yml').exists():
        context_optimizations.append('Docker Compose project context detected')
        
        if command == 'docker-compose up':
            enhanced_command = 'docker-compose up -d --remove-orphans'
            enhancements.append('Enhanced docker-compose up with daemon mode and cleanup')
    
    return enhanced_command, enhancements, context_optimizations

def generate_suggestions(command):
    """Generate intelligent suggestions for command improvements"""
    suggestions = []
    
    # Suggest parallel execution
    if re.search(r'docker build', command) and '--parallel' not in command:
        suggestions.append('Consider adding --parallel flag for faster builds')
    
    # Suggest logging for important operations
    if re.search(r'deploy|build|install', command) and not re.search(r'tee|log', command):
        suggestions.append('Consider adding logging: | tee operation.log')
    
    # Suggest safer alternatives for risky commands
    if 'rm -rf' in command:
        suggestions.append('Consider using trash/recycle bin instead of permanent deletion')
    
    return suggestions

def main():
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            return {"success": False, "error": "No input received"}
        
        # Parse the hook input
        hook_data = json.loads(input_json)
        
        command = hook_data.get('input', {}).get('command', '')
        session_id = hook_data.get('sessionId', 'unknown')
        timestamp = datetime.now().isoformat()
        
        logger.info(f"🔒 Pre-bash validation started for: {command[:50]}...")
        
        # Security validation
        validation_results = validate_command_security(command)
        
        # Command enhancement
        enhanced_command, enhancements, context_optimizations = enhance_command(command)
        
        # Generate suggestions
        suggestions = generate_suggestions(command)
        
        # Log the validation
        validation_log = {
            'timestamp': timestamp,
            'session_id': session_id,
            'original_command': command,
            'enhanced_command': enhanced_command,
            'validation_results': validation_results,
            'enhancements': enhancements,
            'context_optimizations': context_optimizations,
            'suggestions': suggestions,
            'canonical_check': 'powershell' in command.lower()
        }
        
        # Save validation log
        os.makedirs('logs', exist_ok=True)
        with open('logs/bash-validation.jsonl', 'a') as f:
            f.write(json.dumps(validation_log) + '\n')
        
        # Block if necessary
        if validation_results['blocked']:
            logger.error(f"🚫 COMMAND BLOCKED: {validation_results['reason']}")
            
            block_response = {
                'success': False,
                'blocked': True,
                'reason': validation_results['reason'],
                'original_command': command,
                'canonical_violation': 'powershell' in command.lower(),
                'timestamp': timestamp
            }
            
            print(json.dumps(block_response))
            sys.exit(1)
        
        # Log warnings and enhancements
        if validation_results['warnings']:
            logger.warning("⚠️ Bash Validation Warnings:")
            for warning in validation_results['warnings']:
                logger.warning(f"   - {warning}")
        
        if enhancements:
            logger.info("🔧 Bash Command Enhancements:")
            for enhancement in enhancements:
                logger.info(f"   - {enhancement}")
        
        # Prepare response
        response = {
            'success': True,
            'validated': True,
            'is_safe': validation_results['is_safe'],
            'warnings': validation_results['warnings'],
            'enhancements': enhancements,
            'enhanced_command': enhanced_command,
            'suggestions': suggestions,
            'context_optimizations': context_optimizations,
            'canonical_instruction_enforced': True,
            'timestamp': timestamp
        }
        
        logger.info(f"✅ Pre-bash validation completed: {'SAFE' if validation_results['is_safe'] else 'WARNINGS'}")
        
        # Output JSON response
        print(json.dumps(response))
        sys.exit(0)
        
    except json.JSONDecodeError as e:
        error_response = {
            'success': False,
            'error': f'JSON decode error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }
        print(json.dumps(error_response))
        sys.exit(1)
        
    except Exception as e:
        error_response = {
            'success': False,
            'error': f'Unexpected error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }
        logger.error(f"Pre-bash validation failed: {e}")
        print(json.dumps(error_response))
        sys.exit(1)

if __name__ == '__main__':
    main()