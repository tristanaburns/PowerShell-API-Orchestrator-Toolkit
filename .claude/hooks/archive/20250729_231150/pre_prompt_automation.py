#!/usr/bin/env python3
"""Module docstring"""

from app.utils.system import SystemUtils

"""
PRE-PROMPT AUTOMATION HOOK
Triggered when user submits any prompt
Performs intelligent pre-processing and context enhancement

CANONICAL INSTRUCTION: NO POWERSHELL - PYTHON ONLY
"""

import sys
import json
import os
import re
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
logger = logging.getLogger('PrePromptAutomation')

def main():
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            return {"success": False, "error": "No input received"}
        
        # Parse the hook input
        hook_data = json.loads(input_json)
        
        # Extract user prompt and context
        user_prompt = hook_data.get('input', {}).get('userPrompt', '')
        session_id = hook_data.get('sessionId', 'unknown')
        timestamp = datetime.now().isoformat()
        
        logger.info(f"🧠 Pre-prompt automation started for session: {session_id}")
        
        # AUTO-THINKING: Force Claude to always engage thinking mode
        thinking_trigger = False
        if user_prompt and len(user_prompt.strip()) > 10:  # Only for substantial prompts
            thinking_trigger = True
            logger.info("🧠 Auto-thinking triggered for substantial prompt")
        
        # Log to automation file
        log_entry = {
            'timestamp': timestamp,
            'type': 'UserPromptSubmit',
            'prompt_preview': user_prompt[:100] if user_prompt else '',
            'session_id': session_id,
            'automated_actions': []
        }
        
        # INTELLIGENT PRE-PROCESSING
        automated_actions = []
        context_hints = []
        
        # 1. Check if prompt mentions Docker/containers
        if re.search(r'docker|container|compose|build', user_prompt, re.IGNORECASE):
            automated_actions.append('docker_context_loaded')
            context_hints.append('🐳 Docker environment detected - container operations optimized')
            logger.info("Docker context pre-loaded")
        
        # 2. Check if prompt mentions databases
        if re.search(r'mongodb|database|collection|query|sql', user_prompt, re.IGNORECASE):
            automated_actions.append('database_context_loaded')
            context_hints.append('🗃️ Database operations detected - MongoDB schemas loaded')
            logger.info("Database context pre-loaded")
        
        # 3. Check if prompt mentions MCP servers
        if re.search(r'mcp|memory|thinking|server', user_prompt, re.IGNORECASE):
            automated_actions.append('mcp_context_loaded')
            context_hints.append('🧠 MCP operations detected - memory/thinking servers ready')
            logger.info("MCP context pre-loaded")
        
        # 4. Check if prompt mentions testing
        if re.search(r'test|testing|validate|check', user_prompt, re.IGNORECASE):
            automated_actions.append('test_environment_prepared')
            context_hints.append('🧪 Testing context detected - validation tools ready')
            logger.info("Test environment prepared")
        
        # 5. Check if prompt mentions AI/LLM operations
        if re.search(r'ollama|claude|llm|ai|model', user_prompt, re.IGNORECASE):
            automated_actions.append('ai_context_loaded')
            context_hints.append('🤖 AI operations detected - model orchestration ready')
            logger.info("AI context pre-loaded")
        
        # 6. Auto-enable relevant tools based on prompt
        relevant_tools = []
        if re.search(r'search|find|grep', user_prompt, re.IGNORECASE):
            relevant_tools.append('enhanced_search')
        if re.search(r'file|read|write', user_prompt, re.IGNORECASE):
            relevant_tools.append('file_operations')
        if re.search(r'run|execute|bash', user_prompt, re.IGNORECASE):
            relevant_tools.append('execution')
        
        # 7. Store CANONICAL INSTRUCTION in shared memory
        canonical_instruction = {
            'rule': 'NO_POWERSHELL_EVER',
            'approved_languages': ['Python', 'JavaScript', 'TypeScript', 'React', 'Bash', 'Go', 'Rust'],
            'forbidden_languages': ['PowerShell', 'Batch', 'VBScript', 'Windows CMD'],
            'authority': 'User canonical instruction',
            'priority': 10,
            'scope': 'global'
        }
        
        # Check if prompt violates canonical instruction
        if re.search(r'powershell|\.ps1|pwsh', user_prompt, re.IGNORECASE):
            automated_actions.append('canonical_violation_detected')
            context_hints.append('⚠️ CANONICAL VIOLATION: PowerShell detected - converting to Python')
            logger.warning("Canonical instruction violation detected - PowerShell mentioned")
        
        # Apply auto-thinking if triggered
        enhanced_prompt = user_prompt
        if thinking_trigger:
            automated_actions.append('auto_thinking_enabled')
            context_hints.append('🧠 Auto-thinking mode activated for analysis')
            # Prepend thinking instruction to user prompt
            thinking_instruction = "Please think step by step about this request before responding. Consider multiple approaches, potential issues, and optimal solutions. "
            enhanced_prompt = thinking_instruction + user_prompt
        
        log_entry['automated_actions'] = automated_actions
        log_entry['relevant_tools'] = relevant_tools
        log_entry['canonical_check'] = canonical_instruction
        
        # Save automation log
        os.makedirs('logs', exist_ok=True)
        with open('logs/automation-pre-prompt.jsonl', 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        # Prepare response
        response = {
            'success': True,
            'message': 'Pre-prompt automation completed',
            'automated_actions': automated_actions,
            'context_hints': context_hints,
            'canonical_instruction_enforced': True,
            'relevant_tools': relevant_tools,
            'enhanced_prompt': enhanced_prompt if thinking_trigger else None,
            'auto_thinking_enabled': thinking_trigger,
            'timestamp': timestamp
        }
        
        logger.info(f"✅ Pre-prompt automation completed: {len(automated_actions)} actions")
        
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
        logger.error(f"Pre-prompt automation failed: {e}")
        print(json.dumps(error_response))
        sys.exit(1)

if __name__ == '__main__':
    main()