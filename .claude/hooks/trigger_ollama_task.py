#!/usr/bin/env python3
"""
Trigger Ollama delegation through the actual hook system
"""

import subprocess
import json
import sys
from pathlib import Path

# The user command
user_input = "IMPLEMENT_FUNCTION: create a list_models() method for AI provider strategies that returns available models for each provider (Claude, OpenAI, Ollama, etc.)"

# Create hook input
hook_input = {
    "type": "UserPromptSubmit",
    "content": user_input,
    "current_file": "backend/app/services/ai_orchestrator.py",
    "project_root": str(Path.cwd())
}

print("[LAUNCH] Testing Ollama Delegation with Real Task\n")
print(f"User input: {user_input}\n")

# Run work package manager hook
print("[1] Running work package detection...")
result = subprocess.run(
    ["C:\\Program Files\\Python313\\python.exe", ".claude\\hooks\\hook_runner.py", "UserPromptSubmit", "work_package_manager", "handle"],
    input=json.dumps(hook_input),
    capture_output=True,
    text=True
)

if result.returncode == 0:
    try:
        output = json.loads(result.stdout)
        # Print result with safe encoding
        print(f"Result received (decision: {output.get('decision', 'unknown')})")
        
        # Debug: show full output structure
        print(f"Output keys: {list(output.keys())}")
        
        # Check if work packages were created
        if "packages" in output and output["packages"]:
            print(f"\n[SUCCESS] {len(output['packages'])} work package(s) created!")
            work_package = output["packages"][0]  # Get first package
            print(f"   ID: {work_package['id'][:8]}")
            print(f"   Task type: {work_package['task_type']}")
            print(f"   Claude command: {work_package['claude_command']}")
            
            # Now delegate to Ollama
            print("\n[2] Delegating to Ollama...")
            ollama_input = {
                "type": "UserPromptSubmit",
                "work_package": work_package
            }
            
            ollama_result = subprocess.run(
                ["C:\\Program Files\\Python313\\python.exe", ".claude\\hooks\\hook_runner.py", "UserPromptSubmit", "ollama_delegation", "handle"],
                input=json.dumps(ollama_input),
                capture_output=True,
                text=True
            )
            
            if ollama_result.returncode == 0:
                ollama_output = json.loads(ollama_result.stdout)
                print(f"Ollama hook output keys: {list(ollama_output.keys())}")
                
                if "error" in ollama_output:
                    print(f"[ERROR] {ollama_output['error']}")
                
                if ollama_output.get("code_file"):
                    print(f"\n[SUCCESS] Code generated: {ollama_output['code_file']}")
                    
                    # Show generated code
                    code_file = Path(ollama_output['code_file'])
                    if code_file.exists():
                        print("\n[GENERATED CODE]")
                        print("-" * 60)
                        print(code_file.read_text()[:1000] + "..." if len(code_file.read_text()) > 1000 else code_file.read_text())
                        print("-" * 60)
                    
                    # Run DevSecOps
                    print("\n[3] Running DevSecOps checks...")
                    devsecops_input = {
                        "type": "PostToolUse",
                        "code_file": ollama_output['code_file'],
                        "work_package_id": work_package['id']
                    }
                    
                    devsecops_result = subprocess.run(
                        ["C:\\Program Files\\Python313\\python.exe", ".claude\\hooks\\hook_runner.py", "PostToolUse", "devsecops_automation", "handle"],
                        input=json.dumps(devsecops_input),
                        capture_output=True,
                        text=True
                    )
                    
                    if devsecops_result.returncode == 0:
                        devsecops_output = json.loads(devsecops_result.stdout)
                        print(devsecops_output.get("context", "DevSecOps complete"))
                elif ollama_output.get("error"):
                    print(f"[ERROR] {ollama_output['error']}")
            else:
                print(f"[ERROR] Ollama delegation failed: {ollama_result.stderr}")
        else:
            print("[INFO] No delegatable task detected")
    except json.JSONDecodeError as e:
        print(f"[ERROR] Failed to parse output: {e}")
        print(f"Output: {result.stdout}")
else:
    print(f"[ERROR] Hook failed: {result.stderr}")