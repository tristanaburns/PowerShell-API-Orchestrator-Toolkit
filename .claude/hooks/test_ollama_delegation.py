#!/usr/bin/env python3
"""
Test Drive Ollama Delegation System
Tests the complete workflow from work package creation to Ollama delegation
"""

import json
import sys
from pathlib import Path
import asyncio

# Add modules directory to path
modules_path = Path(__file__).parent / "modules"
sys.path.insert(0, str(modules_path))

# Import modules directly
import work_package_manager
import ollama_delegation
import ollama_pipeline
import ollama_mcp_config
import canonical_protocol_enforcer

WorkPackageManager = work_package_manager.WorkPackageManager
OllamaDelegation = ollama_delegation.OllamaDelegation
OllamaPipeline = ollama_pipeline.OllamaPipeline

def test_delegation_system():
    """Test the complete delegation system"""
    print("🚀 Testing Ollama Delegation System\n")
    
    # Test cases
    test_prompts = [
        "IMPLEMENT_FUNCTION: create a rate limiter with Redis backend that supports sliding window",
        "WRITE_TESTS: tests for the authentication module",
        "FIX_BUG: memory leak in the WebSocket connection handler",
        "CREATE_API: RESTful endpoint for user profile management",
        "OPTIMIZE: database query performance for large datasets",
        "SECURE: audit the file upload functionality for vulnerabilities"
    ]
    
    # Test 1: Work Package Creation
    print("1️⃣ Testing Work Package Creation...")
    manager = WorkPackageManager()
    
    for prompt in test_prompts[:2]:  # Test first two
        print(f"\n  Testing: {prompt[:50]}...")
        
        # Simulate input context
        context = {
            "content": prompt,
            "current_file": "src/services/auth.py",
            "type": "UserPromptSubmit"
        }
        
        # Detect tasks
        tasks = manager.detect_delegatable_tasks(prompt)
        print(f"  ✓ Detected {len(tasks)} tasks")
        
        if tasks:
            # Create work package
            work_package = manager.create_work_package(tasks[0], context)
            print(f"  ✓ Created work package: {work_package['id'][:8]}")
            print(f"  ✓ Selected command: {work_package['claude_command']}")
            print(f"  ✓ Task type: {work_package['task_type']}")
            
            # Test 2: Check MCP configuration
            print("\n2️⃣ Testing MCP Configuration...")
            work_package = ollama_mcp_config.integrate_mcp_config(work_package)
            print(f"  ✓ MCP config created: {work_package['mcp_config_path']}")
            print(f"  ✓ Selected servers: {', '.join(work_package['mcp_servers_selected'])}")
            
            # Test 3: Check canonical enforcement
            print("\n3️⃣ Testing Canonical Protocol Enforcement...")
            work_package = canonical_protocol_enforcer.integrate_canonical_enforcement(work_package)
            print(f"  ✓ Protocol enforced: {work_package['protocol_enforced']}")
            print(f"  ✓ Claude command loaded: {work_package['claude_command_loaded']}")
            
            # Test 4: Check Ollama model selection
            print("\n4️⃣ Testing Ollama Model Selection...")
            delegation = OllamaDelegation()
            
            # Check if Ollama is running
            if delegation.monitor_ollama_health():
                available_models = delegation.get_available_models()
                print(f"  ✓ Ollama is running with {len(available_models)} models")
                
                selected_model = delegation.select_best_model(work_package)
                print(f"  ✓ Selected model: {selected_model}")
                
                # Show prompt preview
                print("\n5️⃣ Prompt Preview (first 500 chars):")
                print("-" * 50)
                print(work_package.get('canonical_prompt', '')[:500])
                print("-" * 50)
                
                # Test actual delegation (optional)
                test_actual = input("\n🤔 Test actual Ollama delegation? (y/n): ")
                if test_actual.lower() == 'y':
                    print("\n6️⃣ Testing Ollama Delegation...")
                    result = delegation.delegate_to_ollama(work_package)
                    if result['success']:
                        print(f"  ✅ Success! Generated code saved to: {result['output_file']}")
                        print(f"  ⏱️  Generation time: {result['generation_time']:.2f}s")
                    else:
                        print(f"  ❌ Failed: {result['error']}")
            else:
                print("  ⚠️  Ollama is not running. Start with: ollama serve")
    
    # Test pipeline integration
    print("\n\n7️⃣ Testing Full Pipeline Integration...")
    test_pipeline = input("Test full pipeline with DevSecOps? (y/n): ")
    if test_pipeline.lower() == 'y':
        pipeline = OllamaPipeline()
        test_prompt = "IMPLEMENT_FUNCTION: simple hello world function"
        context = {"content": test_prompt}
        
        # Run async pipeline
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        result = loop.run_until_complete(
            pipeline.process_user_prompt(test_prompt, context)
        )
        
        print("\n📊 Pipeline Result:")
        print(result.get("context", "No context"))

def show_system_info():
    """Show system configuration info"""
    print("\n📋 System Configuration:")
    print(f"  • Work packages dir: .claude/hooks/work_packages/")
    print(f"  • Ollama results dir: .claude/hooks/ollama_results/")
    print(f"  • MCP configs dir: .claude/hooks/ollama_configs/")
    print(f"  • Logs dir: .claude/hooks/logs/")
    
    # Check Claude commands
    commands_dir = Path(__file__).parent.parent / "commands"
    if commands_dir.exists():
        cmd_count = len(list(commands_dir.rglob("*.md")))
        print(f"  • Claude commands available: {cmd_count}")

if __name__ == "__main__":
    show_system_info()
    test_delegation_system()