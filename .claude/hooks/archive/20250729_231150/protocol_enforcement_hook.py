#!/usr/bin/env python3
"""
PROTOCOL ENFORCEMENT HOOK
Reinforces code-protocol.md and requirements-language.md on every user message
Ensures Claude Code follows canonical instructions without exception

CANONICAL INSTRUCTION: NO POWERSHELL - PYTHON ONLY
"""

import sys
import json
import os
from datetime import datetime
from pathlib import Path
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/protocol_enforcement.log', mode='a'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('ProtocolEnforcement')

def load_protocol_content():
    """Load the canonical protocol files"""
    protocol_base = Path(__file__).parent.parent.parent / '.claude' / 'commands' / 'protocol'
    
    protocols = {}
    
    # Load code-protocol.md
    code_protocol_path = protocol_base / 'code-protocol.md'
    if code_protocol_path.exists():
        with open(code_protocol_path, 'r', encoding='utf-8') as f:
            protocols['code_protocol'] = f.read()
    else:
        logger.warning(f"Code protocol not found at {code_protocol_path}")
    
    # Load requirements-language.md
    req_lang_path = protocol_base / 'requirements-language.md'
    if req_lang_path.exists():
        with open(req_lang_path, 'r', encoding='utf-8') as f:
            protocols['requirements_language'] = f.read()
    else:
        logger.warning(f"Requirements language protocol not found at {req_lang_path}")
    
    return protocols

def create_protocol_injection():
    """Create the protocol enforcement message to inject"""
    protocols = load_protocol_content()
    
    enforcement_message = f"""
<system-protocol-enforcement>
⚠️ CANONICAL PROTOCOL ENFORCEMENT ACTIVE ⚠️

YOU MUST STRICTLY ADHERE TO THE FOLLOWING PROTOCOLS WITHOUT EXCEPTION:

=== REQUIREMENTS LANGUAGE PROTOCOL (RFC 2119) ===
{protocols.get('requirements_language', '[Requirements Language Protocol Not Found]')}

=== CRITICAL REMINDERS FROM CODE PROTOCOL ===
1. FORBIDDEN to take any actions before RTFM (Read The F***ing Manual)
2. MANDATORY: When user says "listen and wait" — DO NOT ACT
3. MANDATORY: Only act when given EXPLICIT action command
4. FORBIDDEN: Ask "should I proceed?" — WAIT FOR ORDERS
5. MANDATORY: Apply KISS, SOLID, DRY, Clean Code principles
6. FORBIDDEN: Create duplicate files or enhanced versions
7. MANDATORY: Fix existing code in-place ONLY
8. MANDATORY: Use atomic commits with clear messages
9. MANDATORY: Check logs at every phase
10. FORBIDDEN: PowerShell, Batch files, VBScript - PYTHON ONLY

THESE PROTOCOLS ARE CANONICAL, MANDATORY, AND NON-NEGOTIABLE.
</system-protocol-enforcement>
"""
    
    return enforcement_message

def modify_user_prompt(original_prompt):
    """Prepend protocol reminder to user prompt"""
    protocol_prefix = """[PROTOCOL REMINDER: You MUST follow code-protocol.md and requirements-language.md. 
- MANDATORY means MUST do without exception
- FORBIDDEN means MUST NOT do ever
- Fix code in-place, never create duplicates
- Wait for explicit commands, don't ask to proceed]

"""
    return protocol_prefix + original_prompt

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
        
        logger.info(f"Protocol enforcement activated for session: {session_id}")
        
        # Create protocol injection
        protocol_injection = create_protocol_injection()
        
        # Check for protocol violations in user prompt
        violations = []
        
        # Check for PowerShell
        if 'powershell' in user_prompt.lower() or '.ps1' in user_prompt.lower():
            violations.append('PowerShell reference detected - FORBIDDEN')
        
        # Check for file duplication patterns
        duplication_patterns = ['enhanced', 'updated', 'fixed', '_v2', '_new', '_copy', '_backup']
        for pattern in duplication_patterns:
            if pattern in user_prompt.lower():
                violations.append(f'Potential file duplication pattern "{pattern}" detected')
        
        # Log enforcement action
        log_entry = {
            'timestamp': timestamp,
            'type': 'ProtocolEnforcement',
            'session_id': session_id,
            'prompt_preview': user_prompt[:100] if user_prompt else '',
            'violations_detected': violations,
            'protocol_injected': True
        }
        
        # Save enforcement log
        os.makedirs('logs', exist_ok=True)
        with open('logs/protocol-enforcement.jsonl', 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        # Modify the user prompt to include protocol reminder
        modified_prompt = modify_user_prompt(user_prompt)
        
        # Update hook data with modified prompt
        if 'input' in hook_data and 'userPrompt' in hook_data['input']:
            hook_data['input']['userPrompt'] = modified_prompt
        
        # Prepare response with protocol injection
        response = {
            'success': True,
            'message': 'Protocol enforcement completed',
            'protocol_injection': protocol_injection,
            'violations_detected': violations,
            'enforcement_level': 'CANONICAL',
            'timestamp': timestamp,
            'modified_prompt': modified_prompt,
            'output': hook_data  # Return modified hook data
        }
        
        if violations:
            response['warning'] = f"WARNING: {len(violations)} protocol violations detected"
            logger.warning(f"Protocol violations detected: {violations}")
        
        logger.info("Protocol enforcement injection completed")
        
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
        logger.error(f"Protocol enforcement failed: {e}")
        print(json.dumps(error_response))
        sys.exit(1)

if __name__ == '__main__':
    main()