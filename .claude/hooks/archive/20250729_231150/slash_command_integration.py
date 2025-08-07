#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SLASH COMMAND INTEGRATION HOOK
Integrates Claude Code slash commands with the hooks system
Enables running /commands as automated hooks for consistent workflow enforcement

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
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('SlashCommandIntegration')

def load_slash_command(command_path):
    """Load a slash command from .claude/commands directory"""
    try:
        if not os.path.exists(command_path):
            return None, f"Command not found: {command_path}"
        
        with open(command_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        return content, None
    except Exception as e:
        return None, f"Error loading command: {e}"

def execute_slash_command_as_hook(command_name, arguments, context):
    """Execute a slash command within the hooks system context"""
    
    # Map command names to file paths
    command_mapping = {
        'enforce': '.claude/commands/protocol/enforce.md',
        'security': '.claude/commands/protocol/security.md',
        'epct': '.claude/commands/epct.md',
        'implement': '.claude/commands/actions/implement.md',
        'debug': '.claude/commands/actions/debug.md',
        'refactor': '.claude/commands/actions/refactor.md',
        'decompose': '.claude/commands/planning/decompose.md',
        'sprint': '.claude/commands/planning/sprint.md',
        'react': '.claude/commands/frontend/react.md',
        'nodejs': '.claude/commands/backend/nodejs.md',
        'e2e': '.claude/commands/testing/e2e.md',
        'live': '.claude/commands/testing/live.md',
        'diataxis': '.claude/commands/docs/diataxis.md'
    }
    
    command_path = command_mapping.get(command_name)
    if not command_path:
        return {
            'success': False,
            'error': f'Unknown slash command: {command_name}',
            'available_commands': list(command_mapping.keys())
        }
    
    # Load the command template
    command_content, error = load_slash_command(command_path)
    if error:
        return {'success': False, 'error': error}
    
    # Replace argument placeholders
    if isinstance(arguments, str):
        # Single argument - replace $argument
        processed_content = command_content.replace('$argument', arguments)
    elif isinstance(arguments, list):
        # Multiple arguments - replace $1, $2, $3, etc.
        processed_content = command_content
        for i, arg in enumerate(arguments, 1):
            processed_content = processed_content.replace(f'${i}', str(arg))
    else:
        processed_content = command_content
    
    # Evaluate command success criteria for conditional chaining
    success_indicators = evaluate_command_success(command_name, processed_content, context)
    
    # Extract structured guidance from the command
    guidance = {
        'command': command_name,
        'arguments': arguments,
        'content': processed_content,
        'context': context,
        'execution_mode': 'hook_integration',
        'canonical_compliance': True,
        'success_indicators': success_indicators,
        'chainable': True
    }
    
    return {
        'success': True,
        'message': f'Slash command /{command_name} loaded as hook guidance',
        'guidance': guidance,
        'automated_actions': [f'slash_command_{command_name}_loaded'],
        'hook_enhanced': True,
        'success_indicators': success_indicators
    }

def evaluate_command_success(command_name, content, context):
    """Evaluate success criteria for command chaining conditionals"""
    
    success_criteria = {
        'enforce': ['AST analysis passes', 'Linting succeeds', 'Type checking passes'],
        'security': ['Input validation implemented', 'Authentication verified', 'OWASP compliance'],
        'implement': ['Unit tests complete', 'Integration tests pass', 'No duplicate code'],
        'debug': ['Root cause identified', 'Fix implemented', 'Preventive measures added'],
        'epct': ['Research complete', 'Plan validated', 'Code implemented', 'Tests passing'],
        'refactor': ['Functionality preserved', 'Quality improved', 'Tests updated']
    }
    
    return {
        'command': command_name,
        'criteria': success_criteria.get(command_name, ['Task completed successfully']),
        'evaluation_context': context.get('evaluation_mode', 'standard'),
        'chainable_on_success': True,
        'chainable_on_failure': False
    }

def execute_command_chain(commands_chain, context):
    """Execute a chain of slash commands with conditional logic"""
    
    results = []
    chain_context = context.copy()
    chain_context['chain_mode'] = True
    
    for i, command_spec in enumerate(commands_chain):
        if isinstance(command_spec, str):
            # Simple command
            command_name = command_spec
            arguments = ""
            condition = None
        elif isinstance(command_spec, dict):
            # Complex command with conditions
            command_name = command_spec.get('command')
            arguments = command_spec.get('arguments', "")
            condition = command_spec.get('condition')
        else:
            continue
        
        # Check if condition allows execution
        if condition and not evaluate_condition(condition, results, chain_context):
            logger.info(f"Skipping command {command_name} due to failed condition: {condition}")
            results.append({
                'command': command_name,
                'skipped': True,
                'reason': f'Condition failed: {condition}'
            })
            continue
        
        # Execute the command
        logger.info(f"Executing chained command {i+1}/{len(commands_chain)}: {command_name}")
        
        result = execute_slash_command_as_hook(command_name, arguments, chain_context)
        result['chain_position'] = i + 1
        result['chain_total'] = len(commands_chain)
        
        results.append(result)
        
        # Update chain context with result
        chain_context[f'result_{i+1}'] = result
        chain_context['last_result'] = result
        
        # Break chain if command failed and no error handling specified
        if not result.get('success', True) and not command_spec.get('continue_on_error', False):
            logger.warning(f"Breaking command chain due to failure in {command_name}")
            break
    
    return {
        'success': all(r.get('success', True) for r in results if not r.get('skipped')),
        'chain_results': results,
        'total_commands': len(commands_chain),
        'executed_commands': len([r for r in results if not r.get('skipped')]),
        'chain_context': chain_context
    }

def evaluate_condition(condition, previous_results, context):
    """Evaluate conditional logic for command chaining"""
    
    if not condition:
        return True
    
    # Simple condition types
    if condition == 'always':
        return True
    elif condition == 'never':
        return False
    elif condition == 'previous_success':
        return len(previous_results) == 0 or previous_results[-1].get('success', False)
    elif condition == 'previous_failure':
        return len(previous_results) > 0 and not previous_results[-1].get('success', True)
    elif condition.startswith('result_contains:'):
        search_term = condition.split(':', 1)[1]
        if previous_results:
            last_result = previous_results[-1]
            result_str = str(last_result)
            return search_term.lower() in result_str.lower()
        return False
    
    # Advanced condition evaluation
    try:
        # Safe evaluation of simple boolean expressions
        if 'and' in condition or 'or' in condition:
            # Get context values safely
            previous_success = len(previous_results) == 0 or previous_results[-1].get('success', False)
            has_errors = any('error' in str(r) for r in previous_results)
            
            # Replace context variables with actual values
            eval_condition = condition
            eval_condition = eval_condition.replace('previous_success', str(previous_success))
            eval_condition = eval_condition.replace('has_errors', str(has_errors))
            
            # Use ast.literal_eval for safe evaluation instead of eval()
            import ast
            try:
                # Only allow simple boolean expressions
                if all(allowed in eval_condition for allowed in ['True', 'False', 'and', 'or', 'not', '(', ')', ' ']):
                    return ast.literal_eval(eval_condition)
                else:
                    logger.warning(f"Unsafe condition expression: {condition}")
                    return True
            except (ValueError, SyntaxError):
                logger.warning(f"Invalid condition syntax: {condition}")
                return True
    except:
        logger.warning(f"Could not evaluate condition: {condition}")
        return True
    
    return True

def parse_command_chain(user_prompt):
    """Parse command chain syntax from user prompt"""
    
    # Chain syntax examples:
    # "/decompose task | /implement | /test"
    # "/enforce security && /test e2e"
    # "/debug issue || /refactor component"
    
    chain_patterns = [
        (r'/(\w+(?:/\w+)?)\s*([^|&]*?)\s*\|\s*', 'sequential'),      # pipe for sequential
        (r'/(\w+(?:/\w+)?)\s*([^|&]*?)\s*&&\s*', 'conditional_and'), # && for success condition
        (r'/(\w+(?:/\w+)?)\s*([^|&]*?)\s*\|\|\s*', 'conditional_or') # || for failure condition
    ]
    
    commands_chain = []
    
    for pattern, chain_type in chain_patterns:
        matches = re.findall(pattern, user_prompt)
        if matches:
            for i, (command, args) in enumerate(matches):
                command_spec = {
                    'command': command.replace('/', ''),
                    'arguments': args.strip(),
                    'chain_type': chain_type
                }
                
                # Add conditional logic based on chain type
                if chain_type == 'conditional_and' and i > 0:
                    command_spec['condition'] = 'previous_success'
                elif chain_type == 'conditional_or' and i > 0:
                    command_spec['condition'] = 'previous_failure'
                
                commands_chain.append(command_spec)
            
            return commands_chain
    
    # Single command fallback
    single_match = re.search(r'/(\w+(?:/\w+)?)\s*(.*)', user_prompt)
    if single_match:
        return [{
            'command': single_match.group(1).replace('/', ''),
            'arguments': single_match.group(2).strip(),
            'chain_type': 'single'
        }]
    
    return []

def integrate_command_with_hooks(hook_event, command_name, arguments=None):
    """Integrate slash commands with specific hook events"""
    
    # Define which commands work best with which hook events
    event_command_mapping = {
        'UserPromptSubmit': ['decompose', 'sprint', 'epct'],
        'PreToolUse': ['enforce', 'security'],
        'PostToolUse': ['implement', 'refactor', 'debug'],
        'Stop': ['live', 'e2e']
    }
    
    if command_name not in event_command_mapping.get(hook_event, []):
        logger.warning(f"Command {command_name} not optimal for {hook_event} event")
    
    context = {
        'hook_event': hook_event,
        'timestamp': datetime.now().isoformat(),
        'integration_mode': 'automated'
    }
    
    return execute_slash_command_as_hook(command_name, arguments, context)

def main():
    """Main hook execution function"""
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            return {"success": False, "error": "No input received"}
        
        # Parse the hook input
        hook_data = json.loads(input_json)
        
        # Extract hook context
        session_id = hook_data.get('sessionId', 'unknown')
        tool_name = hook_data.get('toolName', 'unknown')
        user_input = hook_data.get('input', {})
        
        # Check if user input contains slash command invocation
        user_prompt = user_input.get('userPrompt', '') or user_input.get('command', '')
        
        # Check for command chaining syntax first
        commands_chain = parse_command_chain(user_prompt)
        
        if commands_chain:
            if len(commands_chain) > 1:
                # Execute command chain
                logger.info(f"Command chain detected: {len(commands_chain)} commands")
                
                chain_context = {
                    'session_id': session_id,
                    'tool_name': tool_name,
                    'hook_triggered': True,
                    'chain_mode': True
                }
                
                result = execute_command_chain(commands_chain, chain_context)
                result['hook_integration'] = True
                result['session_id'] = session_id
                result['timestamp'] = datetime.now().isoformat()
                result['chain_executed'] = True
                
                # Log the chain execution
                log_entry = {
                    'timestamp': datetime.now().isoformat(),
                    'type': 'SlashCommandChainExecution',
                    'commands': [cmd.get('command') for cmd in commands_chain],
                    'chain_length': len(commands_chain),
                    'session_id': session_id,
                    'success': result['success']
                }
                
                os.makedirs('logs', exist_ok=True)
                with open('logs/slash-command-chains.jsonl', 'a') as f:
                    f.write(json.dumps(log_entry) + '\n')
                
                print(json.dumps(result))
                sys.exit(0)
            
            else:
                # Single command execution
                command_spec = commands_chain[0]
                command_name = command_spec['command']
                command_args = command_spec['arguments']
                
                logger.info(f"Single slash command detected: /{command_name} with args: {command_args}")
                
                # Execute the slash command as a hook
                result = execute_slash_command_as_hook(command_name, command_args, {
                    'session_id': session_id,
                    'tool_name': tool_name,
                    'hook_triggered': True
                })
                
                # Enhance the result with hook-specific information
                result['hook_integration'] = True
                result['session_id'] = session_id
                result['timestamp'] = datetime.now().isoformat()
                
                # Log the integration
                log_entry = {
                    'timestamp': datetime.now().isoformat(),
                    'type': 'SlashCommandHookIntegration',
                    'command': command_name,
                    'arguments': command_args,
                    'session_id': session_id,
                    'success': result['success']
                }
                
                os.makedirs('logs', exist_ok=True)
                with open('logs/slash-command-hooks.jsonl', 'a') as f:
                    f.write(json.dumps(log_entry) + '\n')
                
                print(json.dumps(result))
                sys.exit(0)
        
        else:
            # No slash command detected - return neutral response
            response = {
                'success': True,
                'message': 'No slash command detected in input',
                'hook_integration': False,
                'timestamp': datetime.now().isoformat()
            }
            
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
        logger.error(f"Slash command integration failed: {e}")
        print(json.dumps(error_response))
        sys.exit(1)

if __name__ == '__main__':
    main()