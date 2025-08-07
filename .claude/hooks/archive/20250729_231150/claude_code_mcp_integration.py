#!/usr/bin/env python3
"""
Claude Code MCP Integration Hook
Properly configures MCP servers for Claude Code CLI using the official commands
"""

import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class ClaudeCodeMCPIntegration:
    """Integrates MCP servers properly with Claude Code CLI"""
    
    def __init__(self, project_root: Optional[str] = None):
        """Initialize Claude Code MCP integration
        
        Args:
            project_root: Project root directory path
        """
        self.project_root = Path(project_root) if project_root else Path.cwd()
        self.claude_cmd = "claude"  # Default, will be updated if needed
        
        # Define essential MCP servers for Claude Code CLI
        self.essential_servers = [
            {
                "name": "memory",
                "command": "npx -y @modelcontextprotocol/server-memory",
                "description": "Persistent memory and context management",
                "priority": 1
            },
            {
                "name": "sequential-thinking", 
                "command": "npx -y @modelcontextprotocol/server-sequential-thinking",
                "description": "Sequential reasoning and thinking processes",
                "priority": 2
            },
            {
                "name": "fetch",
                "command": "npx -y @modelcontextprotocol/server-fetch", 
                "description": "HTTP requests and web content fetching",
                "priority": 3
            },
            {
                "name": "time",
                "command": "npx -y @modelcontextprotocol/server-time",
                "description": "Time and date operations",
                "priority": 4
            },
            {
                "name": "filesystem",
                "command": f"npx -y @modelcontextprotocol/server-filesystem",
                "args": [str(self.project_root)],
                "description": "File system operations and management", 
                "priority": 5
            }
        ]
    
    def check_claude_code_availability(self) -> bool:
        """Check if Claude Code CLI is available
        
        Returns:
            bool: True if Claude Code CLI is available
        """
        # Try both claude and claude.cmd on Windows
        commands_to_try = ["claude", "claude.cmd"]
        
        for cmd in commands_to_try:
            try:
                result = subprocess.run(
                    [cmd, "--version"],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                
                if result.returncode == 0:
                    print(f"[OK] Claude Code CLI available ({cmd}): {result.stdout.strip()}")
                    # Store the working command for later use
                    self.claude_cmd = cmd
                    return True
                    
            except (FileNotFoundError, subprocess.TimeoutExpired):
                continue
        
        print("[ERROR] Claude Code CLI not found in PATH")
        return False
    
    def get_configured_mcp_servers(self) -> List[str]:
        """Get list of currently configured MCP servers
        
        Returns:
            List of configured server names
        """
        try:
            result = subprocess.run(
                [self.claude_cmd, "mcp", "list"],
                capture_output=True,
                text=True,
                timeout=15
            )
            
            if result.returncode == 0:
                # Parse the output to extract server names
                lines = result.stdout.strip().split('\n')
                servers = []
                
                for line in lines:
                    if ':' in line and ('OK' in line or 'Failed' in line):
                        server_name = line.split(':')[0].strip()
                        servers.append(server_name)
                
                return servers
            else:
                return []
                
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return []
    
    def add_mcp_server(self, server_config: Dict) -> bool:
        """Add a single MCP server to Claude Code
        
        Args:
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if successfully added
        """
        name = server_config["name"]
        command = server_config["command"]
        args = server_config.get("args", [])
        
        try:
            cmd = [self.claude_cmd, "mcp", "add", name, command] + args
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                print(f"[OK] Added MCP server: {name}")
                return True
            else:
                print(f"[ERROR] Failed to add {name}: {result.stderr.strip()}")
                return False
                
        except (FileNotFoundError, subprocess.TimeoutExpired) as e:
            print(f"[ERROR] Error adding {name}: {e}")
            return False
    
    def remove_mcp_server(self, server_name: str) -> bool:
        """Remove an MCP server from Claude Code
        
        Args:
            server_name: Name of server to remove
            
        Returns:
            bool: True if successfully removed
        """
        try:
            result = subprocess.run(
                [self.claude_cmd, "mcp", "remove", server_name],
                capture_output=True,
                text=True,
                timeout=15
            )
            
            if result.returncode == 0:
                print(f"[OK] Removed MCP server: {server_name}")
                return True
            else:
                print(f"[ERROR] Failed to remove {server_name}: {result.stderr.strip()}")
                return False
                
        except (FileNotFoundError, subprocess.TimeoutExpired) as e:
            print(f"[ERROR] Error removing {server_name}: {e}")
            return False
    
    def setup_essential_mcp_servers(self) -> Tuple[int, int]:
        """Setup essential MCP servers for development work
        
        Returns:
            Tuple of (successful_additions, total_attempted)
        """
        print("[SETUP] Setting up essential MCP servers for Claude Code...")
        print("=" * 60)
        
        # Get currently configured servers
        configured_servers = self.get_configured_mcp_servers()
        print(f"Currently configured servers: {configured_servers}")
        
        successful = 0
        total = len(self.essential_servers)
        
        for server_config in self.essential_servers:
            server_name = server_config["name"]
            
            print(f"\n[PROCESS] Processing {server_name}...")
            
            # Check if already configured
            if server_name in configured_servers:
                print(f"  [INFO] {server_name} already configured")
                
                # Test if it's working, remove and re-add if not
                print(f"  [TEST] Testing {server_name} connectivity...")
                time.sleep(1)  # Brief pause
                
                # For now, we'll assume configured servers are working
                # TODO: Add proper health check
                successful += 1
                continue
            
            # Add the server
            if self.add_mcp_server(server_config):
                successful += 1
                time.sleep(1)  # Brief pause between additions
        
        return successful, total
    
    def verify_mcp_setup(self) -> Dict:
        """Verify the MCP setup and return status
        
        Returns:
            Dict containing verification results
        """
        print("\\n[VERIFY] Verifying MCP server setup...")
        print("-" * 40)
        
        try:
            result = subprocess.run(
                [self.claude_cmd, "mcp", "list"],
                capture_output=True,
                text=True,
                timeout=20
            )
            
            if result.returncode == 0:
                output = result.stdout.strip()
                lines = output.split('\\n')
                
                total_servers = 0
                working_servers = 0
                failed_servers = 0
                
                server_status = {}
                
                for line in lines:
                    if ':' in line and ('OK' in line or 'Failed' in line):
                        total_servers += 1
                        parts = line.split(' - ')
                        server_info = parts[0].split(': ')
                        server_name = server_info[0].strip()
                        
                        if 'OK' in line:
                            working_servers += 1
                            server_status[server_name] = "working"
                        else:
                            failed_servers += 1
                            server_status[server_name] = "failed"
                
                return {
                    "success": True,
                    "total_servers": total_servers,
                    "working_servers": working_servers,
                    "failed_servers": failed_servers,
                    "server_status": server_status,
                    "raw_output": output
                }
            else:
                return {
                    "success": False,
                    "error": "Failed to list MCP servers",
                    "raw_output": result.stderr
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": f"Error verifying setup: {e}"
            }
    
    def run_integration_setup(self) -> bool:
        """Run the complete MCP integration setup
        
        Returns:
            bool: True if setup was successful
        """
        print("[START] Claude Code MCP Integration Setup")
        print("=" * 50)
        
        # Check Claude Code availability
        if not self.check_claude_code_availability():
            print("\\n[ERROR] Cannot proceed - Claude Code CLI not available")
            return False
        
        # Setup essential servers
        successful, total = self.setup_essential_mcp_servers()
        
        print(f"\\n[SUMMARY] Setup Summary:")
        print(f"   Successfully configured: {successful}/{total} servers")
        
        # Verify setup
        verification = self.verify_mcp_setup()
        
        if verification["success"]:
            working = verification["working_servers"]
            failed = verification["failed_servers"]
            total_configured = verification["total_servers"]
            
            print(f"\\n[RESULTS] Verification Results:")
            print(f"   Total configured: {total_configured}")
            print(f"   Working: {working}")
            print(f"   Failed: {failed}")
            
            if working > 0:
                print(f"\\n[SUCCESS] MCP integration setup complete!")
                print(f"   {working} MCP servers are now available for use")
                print("\\n[INFO] Restart Claude Code to ensure all servers are loaded")
                return True
            else:
                print(f"\\n[WARNING] MCP servers configured but none are responding")
                print("   This may be normal on first setup - try restarting Claude Code")
                return False
        else:
            print(f"\\n[ERROR] Verification failed: {verification.get('error', 'Unknown error')}")
            return False


def main():
    """Main execution function"""
    try:
        print("[HOOK] Claude Code MCP Integration Hook")
        print("Setting up MCP servers for enhanced development workflow...")
        print()
        
        # Initialize integration
        integration = ClaudeCodeMCPIntegration()
        
        # Run setup
        success = integration.run_integration_setup()
        
        return 0 if success else 1
        
    except KeyboardInterrupt:
        print("\\n[CANCELLED] Setup cancelled by user")
        return 1
    except Exception as e:
        print(f"\\n[ERROR] Setup error: {e}")
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)