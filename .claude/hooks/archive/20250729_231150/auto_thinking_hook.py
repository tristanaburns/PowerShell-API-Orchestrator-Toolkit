#!/usr/bin/env python3
"""
AUTO-THINKING HOOK
Forces Claude to always engage in thinking mode
Triggered on every user prompt submission
"""

import sys
import json
import os
import logging
from datetime import datetime
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/thinking.log', mode='a', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('AutoThinking')


def should_think(prompt: str) -> bool:
    """Determine if thinking should be triggered for this prompt."""
    if not prompt or len(prompt.strip()) < 5:
        return False
    
    # Skip thinking for very simple prompts
    simple_patterns = [
        'yes', 'no', 'ok', 'thanks', 'thank you', 'continue', 'done'
    ]
    
    if prompt.strip().lower() in simple_patterns:
        return False
    
    return True


def enhance_prompt_for_thinking(prompt: str) -> str:
    """Add thinking instructions to the user prompt."""
    thinking_prefix = (
        "Before responding, please think through this request step by step. "
        "Consider multiple approaches, potential challenges, and optimal solutions. "
        "Use the thinking tools available to analyze the problemly. "
        "\n\nOriginal request: "
    )
    
    return thinking_prefix + prompt


def main() -> None:
    """Main hook execution function."""
    try:
        # Read hook input from stdin
        input_json = sys.stdin.read().strip()
        if not input_json:
            logger.error("No input received from stdin")
            print(json.dumps({"success": False, "error": "No input received"}))
            sys.exit(1)
        
        # Parse the hook input
        hook_data = json.loads(input_json)
        
        # Extract user prompt
        user_prompt = hook_data.get('input', {}).get('userPrompt', '')
        session_id = hook_data.get('sessionId', 'unknown')
        timestamp = datetime.now().isoformat()
        
        logger.info("🧠 Auto-thinking hook activated for session: %s", session_id)
        
        # Determine if thinking should be triggered
        should_trigger_thinking = should_think(user_prompt)
        
        response = {
            'success': True,
            'message': 'Auto-thinking hook completed',
            'thinking_enabled': should_trigger_thinking,
            'timestamp': timestamp
        }
        
        if should_trigger_thinking:
            enhanced_prompt = enhance_prompt_for_thinking(user_prompt)
            response['enhanced_prompt'] = enhanced_prompt
            response['original_prompt'] = user_prompt
            logger.info("🧠 Thinking mode activated - prompt enhanced")
        else:
            logger.info("🧠 Thinking mode skipped for simple prompt")
        
        # Log the thinking decision
        os.makedirs('logs', exist_ok=True)
        log_entry = {
            'timestamp': timestamp,
            'session_id': session_id,
            'original_prompt': user_prompt,
            'thinking_triggered': should_trigger_thinking,
            'prompt_length': len(user_prompt),
        }
        
        with open('logs/auto-thinking.jsonl', 'a', encoding='utf-8') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        # Output response
        print(json.dumps(response))
        sys.exit(0)
        
    except json.JSONDecodeError as e:
        error_response = {
            'success': False,
            'error': f'JSON decode error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }
        logger.error("JSON decode error: %s", str(e))
        print(json.dumps(error_response))
        sys.exit(1)
        
    except (OSError, IOError) as e:
        error_response = {
            'success': False,
            'error': f'File operation error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }
        logger.error("File operation error: %s", str(e))
        print(json.dumps(error_response))
        sys.exit(1)
        
    except Exception as e:
        error_response = {
            'success': False,
            'error': f'Unexpected error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }
        logger.error("Auto-thinking hook failed: %s", str(e))
        print(json.dumps(error_response))
        sys.exit(1)


if __name__ == '__main__':
    main()
