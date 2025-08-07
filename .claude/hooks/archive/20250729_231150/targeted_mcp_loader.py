#!/usr/bin/env python3
"""
Targeted MCP Server Loader for Specific Tools
Loads memory, sequential-thinking, context7, and fetch MCP servers via stdio
"""

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any


class TargetedMCPLoader:
    """Loads specific MCP servers: memory, sequential-thinking, context7, fetch"""
    
    def __init__(self, project_root: Optional[str] = None):
        """Initialize targeted MCP loader
        
        Args:
            project_root: Project root directory path
        """
        self.project_root = Path(project_root) if project_root else Path.cwd()
        self.settings_file = self.project_root / ".claude" / "settings.json"
        
        # Define target MCP servers
        self.target_servers = {
            "memory": {
                "package": "@modelcontextprotocol/server-memory",
                "description": "Persistent memory and context management",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-memory"],
                "priority": 1
            },
            "sequential-thinking": {
                "package": "@modelcontextprotocol/server-sequential-thinking", 
                "description": "Sequential reasoning and thinking processes",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
                "priority": 2
            },
            "context7": {
                "package": "@context7/mcp-server",
                "description": "Context7 enhanced context management",
                "command": "npx",
                "args_template": ["-y", "@context7/mcp-server"],
                "priority": 3
            },
            "fetch": {
                "package": "@modelcontextprotocol/server-fetch",
                "description": "HTTP requests and web content fetching",
                "command": "npx", 
                "args_template": ["-y", "@modelcontextprotocol/server-fetch"],
                "priority": 4
            }
        }
    
    def check_server_availability(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Check if a specific MCP server is available
        
        Args:
            server_name: Name of the server
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if server is available, False otherwise
        """
        try:
            # Test if package is available via npx
            test_args = server_config["args_template"] + ["--help"]
            
            result = subprocess.run(
                [server_config["command"]] + test_args,
                capture_output=True,
                text=True,
                timeout=15
            )
            
            # If help command succeeds or fails with expected error, package exists
            available = result.returncode in [0, 1] or "help" in result.stdout.lower()
            
            if available:
                print(f"✓ {server_name}: Available")
            else:
                print(f"✗ {server_name}: Not available (return code: {result.returncode})")
                
            return available
            
        except subprocess.TimeoutExpired:
            print(f"✗ {server_name}: Timeout during availability check")
            return False
        except FileNotFoundError:
            print(f"✗ {server_name}: Command '{server_config['command']}' not found")
            return False
        except Exception as e:
            print(f"✗ {server_name}: Error checking availability - {e}")
            return False
    
    def generate_mcp_configuration(self) -> Dict[str, Dict[str, Any]]:
        """Generate MCP server configuration for available servers
        
        Returns:
            Dict containing MCP server configurations
        """
        mcp_config = {}
        
        print("Checking availability of target MCP servers...")
        print("=" * 50)
        
        for server_name, server_info in self.target_servers.items():
            if self.check_server_availability(server_name, server_info):
                mcp_config[server_name] = {
                    "command": server_info["command"],
                    "args": server_info["args_template"],
                    "transport": "stdio",
                    "description": server_info["description"]
                }
        
        print("=" * 50)
        print(f"Configured {len(mcp_config)} out of {len(self.target_servers)} target servers")
        
        return mcp_config
    
    def update_settings_with_mcp_config(self, mcp_config: Dict[str, Dict[str, Any]]) -> bool:
        """Update settings.json with MCP server configuration
        
        Args:
            mcp_config: MCP server configuration dictionary
            
        Returns:
            bool: True if update successful, False otherwise
        """
        try:
            if not self.settings_file.exists():
                print(f"Error: Settings file not found at {self.settings_file}")
                return False
            
            # Read current settings
            with open(self.settings_file, 'r', encoding='utf-8') as f:
                settings = json.load(f)
            
            # Update mcpServers section
            settings["mcpServers"] = mcp_config
            
            # Write updated settings with proper formatting
            with open(self.settings_file, 'w', encoding='utf-8') as f:
                json.dump(settings, f, indent=2, ensure_ascii=False)
            
            print(f"✓ Updated settings.json with {len(mcp_config)} MCP servers")
            return True
            
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in settings file - {e}")
            return False
        except Exception as e:
            print(f"Error updating settings file: {e}")
            return False
    
    def create_mcp_test_script(self) -> bool:
        """Create a test script to verify MCP server functionality
        
        Returns:
            bool: True if script created successfully
        """
        test_script_path = self.project_root / ".claude" / "hooks" / "test_mcp_servers.py"
        
        test_script_content = '''#!/usr/bin/env python3
"""
MCP Server Test Script
Tests the functionality of configured MCP servers
"""

import subprocess
import json
import sys
from pathlib import Path


def test_mcp_server(server_name, server_config):
    """Test a single MCP server"""
    print(f"Testing {server_name}...")
    
    try:
        cmd = [server_config["command"]] + server_config["args"]
        
        # Test server startup
        process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Send a simple test message
        test_message = json.dumps({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {"name": "test-client", "version": "1.0.0"}
            }
        }) + "\\n"
        
        stdout, stderr = process.communicate(input=test_message, timeout=5)
        
        if process.returncode == 0 or "result" in stdout:
            print(f"✓ {server_name}: Responding correctly")
            return True
        else:
            print(f"✗ {server_name}: Unexpected response")
            return False
            
    except subprocess.TimeoutExpired:
        print(f"✗ {server_name}: Timeout during test")
        process.kill()
        return False
    except Exception as e:
        print(f"✗ {server_name}: Test failed - {e}")
        return False


def main():
    """Main test function"""
    settings_file = Path(".claude/settings.json")
    
    if not settings_file.exists():
        print("Error: settings.json not found")
        return False
    
    with open(settings_file, 'r') as f:
        settings = json.load(f)
    
    mcp_servers = settings.get("mcpServers", {})
    
    if not mcp_servers:
        print("No MCP servers configured")
        return False
    
    print(f"Testing {len(mcp_servers)} MCP servers...")
    print("=" * 40)
    
    results = {}
    for server_name, server_config in mcp_servers.items():
        results[server_name] = test_mcp_server(server_name, server_config)
    
    print("=" * 40)
    successful = sum(results.values())
    total = len(results)
    print(f"Results: {successful}/{total} servers working correctly")
    
    return successful == total


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
'''
        
        try:
            with open(test_script_path, 'w', encoding='utf-8') as f:
                f.write(test_script_content)
            
            # Make script executable on Unix-like systems
            if hasattr(os, 'chmod'):
                os.chmod(test_script_path, 0o755)
            
            print(f"✓ Created MCP test script at {test_script_path}")
            return True
            
        except Exception as e:
            print(f"Error creating test script: {e}")
            return False
    
    def load_and_configure_servers(self) -> bool:
        """Main function to load and configure targeted MCP servers
        
        Returns:
            bool: True if configuration successful
        """
        print("Targeted MCP Server Loader")
        print("=" * 50)
        print("Target servers: memory, sequential-thinking, context7, fetch")
        print("")
        
        # Generate MCP configuration
        mcp_config = self.generate_mcp_configuration()
        
        if not mcp_config:
            print("No target MCP servers are available")
            return False
        
        # Update settings file
        if not self.update_settings_with_mcp_config(mcp_config):
            print("Failed to update settings file")
            return False
        
        # Create test script
        self.create_mcp_test_script()
        
        print("")
        print("Configuration Summary:")
        print("-" * 30)
        for server_name, config in mcp_config.items():
            print(f"• {server_name}: {config['description']}")
        
        print("")
        print("✓ MCP server configuration complete!")
        print("Use 'python .claude/hooks/test_mcp_servers.py' to test servers")
        
        return True


def main():
    """Main execution function"""
    try:
        loader = TargetedMCPLoader()
        success = loader.load_and_configure_servers()
        return 0 if success else 1
        
    except KeyboardInterrupt:
        print("\\nOperation cancelled by user")
        return 1
    except Exception as e:
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)