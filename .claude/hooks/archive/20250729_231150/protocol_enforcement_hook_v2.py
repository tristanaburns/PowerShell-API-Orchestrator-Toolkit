#!/usr/bin/env python3
"""
PROTOCOL ENFORCEMENT HOOK V2
Properly injects protocols into Claude's context following the hooks documentation
For UserPromptSubmit: stdout with exit code 0 is added to Claude's context

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
logger = logging.getLogger('ProtocolEnforcementV2')

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
    """Create the protocol enforcement message to inject into Claude's context"""
    protocols = load_protocol_content()
    
    enforcement_message = f"""
[CANONICAL PROTOCOL ENFORCEMENT ACTIVE]

YOU MUST STRICTLY ADHERE TO THE FOLLOWING PROTOCOLS WITHOUT EXCEPTION:

=== REQUIREMENTS LANGUAGE PROTOCOL (RFC 2119) ===
{protocols.get('requirements_language', '[Requirements Language Protocol Not Found]')}

=== CRITICAL REMINDERS FROM CODE PROTOCOL ===
1. FORBIDDEN to take any actions before RTFM (Read The Manual)
2. MANDATORY: When user says "listen and wait" - DO NOT ACT
3. MANDATORY: Only act when given EXPLICIT action command
4. FORBIDDEN: Ask "should I proceed?" - WAIT FOR ORDERS
5. MANDATORY: Apply KISS, SOLID, DRY, Clean Code principles
6. FORBIDDEN: Create duplicate files or enhanced versions
7. MANDATORY: Fix existing code in-place ONLY
8. MANDATORY: Use atomic commits with clear messages
9. MANDATORY: Check logs at every phase
10. FORBIDDEN: PowerShell, Batch files, VBScript - PYTHON ONLY

THESE PROTOCOLS ARE CANONICAL, MANDATORY, AND NON-NEGOTIABLE.

User's actual request follows:
"""
    
    return enforcement_message

def main():
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            sys.exit(1)
        
        # Parse the hook input
        hook_data = json.loads(input_json)
        
        # For UserPromptSubmit, the structure is different per documentation
        hook_event_name = hook_data.get('hook_event_name', '')
        
        if hook_event_name != 'UserPromptSubmit':
            # This hook is specifically for UserPromptSubmit
            logger.info(f"Hook called for {hook_event_name}, not UserPromptSubmit - skipping")
            sys.exit(0)
        
        # Extract correct fields for UserPromptSubmit
        user_prompt = hook_data.get('prompt', '')
        session_id = hook_data.get('session_id', 'unknown')
        timestamp = datetime.now().isoformat()
        
        logger.info(f"Protocol enforcement activated for session: {session_id}")
        
        # Check for protocol violations in user prompt
        violations = []
        
        # Check for PowerShell
        if 'powershell' in user_prompt.lower() or '.ps1' in user_prompt.lower():
            violations.append('PowerShell reference detected - FORBIDDEN')
            
            # Block the prompt with exit code 0 and JSON output
            output = {
                "decision": "block",
                "reason": "PowerShell is FORBIDDEN by canonical protocol. Use Python instead."
            }
            print(json.dumps(output))
            sys.exit(0)
        
        # Check for file duplication patterns that should be blocked
        blocking_patterns = {
            'create.*enhanced.*version': 'Creating enhanced versions is FORBIDDEN',
            'make.*backup.*copy': 'Creating backup copies is FORBIDDEN',
            'create.*duplicate': 'Creating duplicates is FORBIDDEN',
            'copy.*to.*new.*file': 'Creating new file copies is FORBIDDEN'
        }
        
        import re
        for pattern, message in blocking_patterns.items():
            if re.search(pattern, user_prompt, re.IGNORECASE):
                output = {
                    "decision": "block",
                    "reason": f"{message}. You must fix code in-place, never create duplicates."
                }
                print(json.dumps(output))
                sys.exit(0)
        
        # Check for warning patterns (not blocking)
        warning_patterns = ['enhanced', 'updated', 'fixed', '_v2', '_new', '_copy', '_backup']
        for pattern in warning_patterns:
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
        with open('logs/protocol-enforcement-v2.jsonl', 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        logger.info("Protocol enforcement injection completed")
        
        # Create protocol injection
        protocol_injection = create_protocol_injection()
        
        # For UserPromptSubmit with exit code 0, stdout is added to context
        # We can also use JSON with additionalContext
        if violations:
            # Use JSON output to add context and show warnings
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": protocol_injection + f"\n\n[WARNING: {len(violations)} potential protocol violations detected: {', '.join(violations)}]\n"
                }
            }
            print(json.dumps(output))
        else:
            # Simple stdout output for clean prompts
            print(protocol_injection)
        
        sys.exit(0)
        
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {str(e)}")
        sys.exit(1)
        
    except Exception as e:
        logger.error(f"Protocol enforcement failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()