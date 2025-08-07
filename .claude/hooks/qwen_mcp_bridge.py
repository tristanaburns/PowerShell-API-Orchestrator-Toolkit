#!/usr/bin/env python3
"""
MCP Bridge for Qwen - gives Qwen access to MCP filesystem tools like Claude Code
"""

import json
import subprocess
import tempfile
import requests
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

class QwenMCPBridge:
    """Bridge that gives Qwen access to MCP filesystem tools"""
    
    def __init__(self):
        self.ollama_url = "http://localhost:11444"
        self.mcp_tools = {
            "write_file": self._write_file,
            "read_file": self._read_file,
            "list_directory": self._list_directory
        }
    
    def _write_file(self, path: str, content: str) -> dict:
        """Write file using filesystem access"""
        try:
            file_path = Path(path)
            file_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(file_path, 'w') as f:
                f.write(content)
                
            return {
                "success": True,
                "message": f"Wrote {len(content)} chars to {path}",
                "path": str(file_path)
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def _read_file(self, path: str) -> dict:
        """Read file content"""
        try:
            with open(path, 'r') as f:
                content = f.read()
            return {
                "success": True,
                "content": content,
                "length": len(content)
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def _list_directory(self, path: str) -> dict:
        """List directory contents"""
        try:
            dir_path = Path(path)
            files = [str(f) for f in dir_path.iterdir()]
            return {
                "success": True,
                "files": files,
                "count": len(files)
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def parse_tool_calls(self, response_text: str) -> list:
        """Parse tool calls from Qwen response"""
        tool_calls = []
        
        # Look for tool call patterns
        import re
        
        # Pattern: write_file(path="...", content="...")
        write_pattern = r'write_file\s*\(\s*path\s*=\s*["\']([^"\']+)["\']\s*,\s*content\s*=\s*["\']([^"\']*)["\'].*?\)'
        for match in re.finditer(write_pattern, response_text, re.DOTALL):
            tool_calls.append({
                "function": "write_file",
                "arguments": {
                    "path": match.group(1),
                    "content": match.group(2)
                }
            })
        
        # Pattern: read_file(path="...")
        read_pattern = r'read_file\s*\(\s*path\s*=\s*["\']([^"\']+)["\'].*?\)'
        for match in re.finditer(read_pattern, response_text):
            tool_calls.append({
                "function": "read_file",
                "arguments": {
                    "path": match.group(1)
                }
            })
            
        return tool_calls
    
    def execute_tool_calls(self, tool_calls: list) -> list:
        """Execute tool calls and return results"""
        results = []
        
        for call in tool_calls:
            function_name = call.get("function")
            arguments = call.get("arguments", {})
            
            if function_name in self.mcp_tools:
                result = self.mcp_tools[function_name](**arguments)
                results.append({
                    "function": function_name,
                    "arguments": arguments,
                    "result": result
                })
                logger.info(f"Executed {function_name}: {result}")
            else:
                results.append({
                    "function": function_name,
                    "arguments": arguments,
                    "result": {"success": False, "error": f"Unknown function: {function_name}"}
                })
        
        return results
    
    def generate_with_mcp(self, prompt: str, task_id: str) -> dict:
        """Generate code with Qwen and execute any MCP tool calls"""
        
        # Enhanced prompt with MCP tool instructions
        mcp_prompt = f"""{prompt}

## AVAILABLE MCP TOOLS

You have access to these MCP filesystem tools (use exactly this syntax):

1. write_file(path="filename.py", content="your_code_here")
2. read_file(path="filename.py") 
3. list_directory(path="directory_path")

## IMPORTANT INSTRUCTIONS

AFTER generating your Python code, you MUST use the write_file tool to save it:

write_file(path="ollama_results/{task_id}_implementation.py", content="your_complete_python_code")

Example:
```python
# Your generated Python code here
class MyClass:
    def __init__(self):
        pass
```

write_file(path="ollama_results/{task_id}_implementation.py", content="class MyClass:\\n    def __init__(self):\\n        pass")

Start coding and use write_file to save your implementation."""

        try:
            # Send to Qwen
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": "qwen2.5-coder:14b",
                    "prompt": mcp_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.7,
                        "num_predict": 4096,
                        "num_ctx": 32768
                    }
                },
                timeout=120
            )
            
            if response.status_code == 200:
                result = response.json()
                response_text = result.get("response", "")
                
                # Parse and execute tool calls
                tool_calls = self.parse_tool_calls(response_text)
                tool_results = self.execute_tool_calls(tool_calls) if tool_calls else []
                
                return {
                    "success": True,
                    "response": response_text,
                    "tool_calls": tool_calls,
                    "tool_results": tool_results,
                    "files_written": [r["arguments"]["path"] for r in tool_results if r["function"] == "write_file" and r["result"]["success"]]
                }
            else:
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except Exception as e:
            return {"success": False, "error": str(e)}

def test_qwen_mcp():
    """Test Qwen with MCP tools"""
    bridge = QwenMCPBridge()
    
    task_id = f"mcp_test_{int(__import__('time').time())}"
    
    prompt = """Create a Python class called SimpleCalculator that:
- Has methods for add, subtract, multiply, divide
- Includes proper error handling
- Has docstrings for all methods"""
    
    print(f"🚀 Testing Qwen with MCP tools (task: {task_id})")
    
    result = bridge.generate_with_mcp(prompt, task_id)
    
    if result["success"]:
        print(f"✅ Generation successful")
        print(f"📝 Response length: {len(result['response'])} chars")
        print(f"🔧 Tool calls: {len(result['tool_calls'])}")
        print(f"📁 Files written: {result['files_written']}")
        
        for file_path in result['files_written']:
            if Path(file_path).exists():
                print(f"✅ Verified file exists: {file_path}")
            else:
                print(f"❌ File not found: {file_path}")
        
        return True
    else:
        print(f"❌ Generation failed: {result['error']}")
        return False

if __name__ == "__main__":
    success = test_qwen_mcp()
    if success:
        print("\n🎉 Qwen MCP Bridge working!")
    else:
        print("\n💥 Qwen MCP Bridge failed!")