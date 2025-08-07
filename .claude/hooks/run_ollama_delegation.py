#!/usr/bin/env python3
"""
Run actual Ollama delegation for list_models() implementation
"""

import json
import sys
from pathlib import Path
from datetime import datetime

# Add modules to path
sys.path.insert(0, str(Path(__file__).parent / "modules"))

# Import modules directly
from ollama_delegation import OllamaDelegation
import canonical_protocol_minimal

print("[OLLAMA DELEGATION] Implementing list_models() method\n")

# Create realistic work package
work_package = {
    "id": "prod-" + datetime.now().strftime("%Y%m%d%H%M%S"),
    "created_at": datetime.now().isoformat(),
    "task_type": "function_implementation",
    "description": "create list_models() method for AI provider strategies",
    "claude_command": "/code/code-implement",
    "command_prefix": "[COMMAND: /code/code-implement]",
    "requirements": [
        "Abstract method in BaseAIStrategy class with @abstractmethod decorator",
        "Return type must be List[str]",
        "Each provider (ClaudeStrategy, OpenAIStrategy, OllamaStrategy) implements it",
        "Handle API errors gracefully with try/except",
        "Cache results to avoid repeated API calls",
        "Include proper docstrings with Args/Returns sections"
    ],
    "context": {
        "language": "python",
        "framework": "FastAPI",
        "project_root": str(Path.cwd()),
        "current_file": "backend/app/services/ai_orchestrator.py"
    },
    "enhanced_prompt": "Implement list_models() method in AI provider strategies to fix TODO at line 87",
    "devsecops_checks": {
        "linting": True,
        "type_checking": True,
        "security_scan": True,
        "coverage_threshold": 80
    }
}

# Add minimal canonical protocol
work_package = canonical_protocol_minimal.integrate_minimal_protocol(work_package)

# Test delegation
delegation = OllamaDelegation()

# Check Ollama health
if delegation.monitor_ollama_health():
    print("[SUCCESS] Ollama is running with GPU acceleration")
    
    # Get available models
    models = delegation.get_available_models()
    print(f"Available models: {models}")
    
    # Select model
    selected_model = delegation.select_best_model(work_package)
    print(f"Selected model: {selected_model}\n")
    
    # Show minimal prompt
    print("[PROMPT BEING SENT]")
    print("-" * 60)
    print(work_package['minimal_canonical_prompt'][:500] + "...")
    print("-" * 60)
    
    print(f"\n[DELEGATING] Sending to {selected_model}...")
    
    # Delegate
    result = delegation.delegate_to_ollama(work_package)
    
    if result["success"]:
        print(f"\n[SUCCESS] Code generated in {result['generation_time']:.2f}s")
        print(f"Output file: {result['output_file']}")
        
        # Show generated code
        code_file = Path(result['output_file'])
        if code_file.exists():
            code = code_file.read_text()
            print("\n[GENERATED CODE]")
            print("=" * 80)
            print(code)
            print("=" * 80)
            
            # Quick quality check
            print("\n[QUALITY CHECK]")
            if "@abstractmethod" in code:
                print("✓ Abstract method decorator found")
            if "List[str]" in code:
                print("✓ Correct return type")
            if "try:" in code and "except" in code:
                print("✓ Error handling present")
            if '"""' in code:
                print("✓ Docstrings present")
            if "cache" in code.lower():
                print("✓ Caching logic present")
    else:
        print(f"\n[ERROR] Generation failed: {result['error']}")
else:
    print("[ERROR] Ollama is not running")