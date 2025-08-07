#!/usr/bin/env python3
"""
Universal Hook Runner
Main entry point for all Claude hooks - routes to appropriate modules
"""

import json
import sys
import importlib
import logging
from pathlib import Path
from typing import Dict, Any, Optional

# Configure logging
log_dir = Path(__file__).parent / "logs"
log_dir.mkdir(exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_dir / 'hook_runner.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class HookRunner:
    """Routes hook events to appropriate handler modules"""
    
    def __init__(self):
        self.modules_dir = Path(__file__).parent / "modules"
        self.modules_dir.mkdir(exist_ok=True)
        
    def load_module(self, module_name: str):
        """Dynamically load a hook module"""
        try:
            # Add modules directory to Python path
            if str(self.modules_dir) not in sys.path:
                sys.path.insert(0, str(self.modules_dir))
            
            # Import the module
            module = importlib.import_module(module_name)
            return module
        except ImportError as e:
            logger.error(f"Failed to import module {module_name}: {e}")
            return None
    
    def run(self, event_type: str, module_name: str, function_name: str = "handle"):
        """Run a specific hook module"""
        try:
            # Read input from stdin
            input_data = json.loads(sys.stdin.read())
            logger.info(f"Hook runner triggered for {event_type} -> {module_name}.{function_name}")
            
            # Load the module
            module = self.load_module(module_name)
            if not module:
                logger.error(f"Module {module_name} not found")
                print(json.dumps({"decision": "approve"}))
                return 0
            
            # Get the handler function
            if not hasattr(module, function_name):
                logger.error(f"Function {function_name} not found in module {module_name}")
                print(json.dumps({"decision": "approve"}))
                return 0
            
            handler = getattr(module, function_name)
            
            # Call the handler
            result = handler(event_type, input_data)
            
            # Output result
            if isinstance(result, dict):
                print(json.dumps(result))
            else:
                print(json.dumps({"decision": "approve"}))
            
            return 0
            
        except Exception as e:
            logger.error(f"Error in hook runner: {e}", exc_info=True)
            # Allow execution to continue even if hook fails
            print(json.dumps({"decision": "approve"}))
            return 0

def main():
    """Main entry point"""
    if len(sys.argv) < 3:
        logger.error("Usage: hook_runner.py <event_type> <module_name> [function_name]")
        print(json.dumps({"decision": "approve"}))
        return 0
    
    event_type = sys.argv[1]
    module_name = sys.argv[2]
    function_name = sys.argv[3] if len(sys.argv) > 3 else "handle"
    
    runner = HookRunner()
    return runner.run(event_type, module_name, function_name)

if __name__ == "__main__":
    sys.exit(main())