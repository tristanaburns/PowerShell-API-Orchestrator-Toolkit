#!/usr/bin/env python3
"""
Notification Handler Hook - Handles system notifications
Part of the Hive Mind Nexus Enterprise AI Orchestration Platform
"""
import sys
import json
import os
from pathlib import Path
from datetime import datetime

def main():
    """Main entry point for notification handling"""
    try:
        # Read input from stdin if available
        if not sys.stdin.isatty():
            input_data = sys.stdin.read()
            if input_data:
                try:
                    data = json.loads(input_data)
                    notification_type = data.get('type', 'unknown')
                    message = data.get('message', '')
                    
                    # Log notifications
                    log_dir = Path(__file__).parent / 'logs'
                    log_dir.mkdir(exist_ok=True)
                    
                    timestamp = datetime.now().isoformat()
                    
                    with open(log_dir / 'notifications.log', 'a') as f:
                        f.write(f"[{timestamp}] Type: {notification_type} | Message: {message}\n")
                    
                    # Handle specific notification types if needed
                    if notification_type == 'error':
                        with open(log_dir / 'notification_errors.log', 'a') as f:
                            f.write(f"[{timestamp}] ERROR: {message}\n")
                    
                except json.JSONDecodeError:
                    # Not JSON, just continue
                    pass
        
        return 0
        
    except Exception as e:
        # Log error but don't block operations
        try:
            log_dir = Path(__file__).parent / 'logs'
            log_dir.mkdir(exist_ok=True)
            with open(log_dir / 'notification_handler_errors.log', 'a') as f:
                f.write(f"Error in notification_handler.py: {str(e)}\n")
        except:
            pass
        return 0

if __name__ == "__main__":
    sys.exit(main())