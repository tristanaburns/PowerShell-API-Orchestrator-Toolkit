"""
Session Complete Module
Handles cleanup and automation when a Claude session ends
"""

import json
import logging
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict, Any

logger = logging.getLogger(__name__)

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle session complete event"""
    logger.info(f"Session complete handler called")
    
    try:
        # Check if git auto-commit is enabled
        if should_auto_commit():
            perform_git_commit()
        
        # Log session summary
        log_session_summary(input_data)
        
    except Exception as e:
        logger.error(f"Error in session complete: {e}")
    
    return {"decision": "approve"}

def should_auto_commit() -> bool:
    """Check if auto-commit is enabled in settings"""
    try:
        settings_path = Path(__file__).parent.parent.parent / "settings.json"
        if settings_path.exists():
            with open(settings_path, 'r') as f:
                settings = json.load(f)
                return settings.get('gitAutoCommit', {}).get('enabled', False)
    except Exception:
        pass
    return False

def perform_git_commit():
    """Perform atomic git commit"""
    try:
        # Check for changes
        result = subprocess.run(['git', 'status', '--porcelain'], 
                              capture_output=True, text=True)
        if result.stdout.strip():
            # Add all changes
            subprocess.run(['git', 'add', '-A'])
            
            # Create commit message
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            message = f"🤖 Automated commit from Hive Mind session - {timestamp}"
            
            # Commit
            subprocess.run(['git', 'commit', '-m', message])
            logger.info("Git auto-commit completed")
    except Exception as e:
        logger.error(f"Git commit failed: {e}")

def log_session_summary(input_data: Dict[str, Any]):
    """Log session summary"""
    summary = {
        "timestamp": datetime.now().isoformat(),
        "event": "session_complete",
        "data": input_data
    }
    
    log_file = Path(__file__).parent.parent / "logs" / "session-summaries.jsonl"
    log_file.parent.mkdir(exist_ok=True)
    
    with open(log_file, 'a') as f:
        f.write(json.dumps(summary) + '\n')