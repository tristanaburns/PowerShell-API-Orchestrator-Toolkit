#!/usr/bin/env python3
"""
MCP Integration Hook - Auto-loads and configures MCP servers
Runs as part of Claude Code startup process to ensure MCP servers are available
"""

import json
import sys
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional


class MCPIntegrationHook:
    """Integrates MCP server auto-loading into Claude Code workflow"""
    
    def __init__(self, project_root: Optional[str] = None):
        """Initialize MCP integration hook
        
        Args:
            project_root: Project root directory path
        """
        self.project_root = Path(project_root) if project_root else Path.cwd()
        self.settings_file = self.project_root / ".claude" / "settings.json"
        self.hooks_dir = self.project_root / ".claude" / "hooks"
        self.mcp_loader_script = self.hooks_dir / "mcp_auto_installer.py"
        
    def should_run_mcp_loader(self) -> bool:
        """Determine if MCP loader should run
        
        Returns:
            bool: True if loader should run
        """
        # Check if MCP loader script exists
        if not self.mcp_loader_script.exists():
            print("[WARNING] MCP loader script not found - skipping MCP auto-loading")
            return False
        
        try:
            # Check existing MCP servers via Claude CLI
            configured_servers = self._get_configured_mcp_servers()
            
            # If no MCP servers configured, run loader
            if not configured_servers:
                print("[CHECK] No MCP servers configured - running auto-loader...")
                return True
            
            # Check if core servers are missing (excluding filesystem which is disabled for CLI)
            core_servers = ["memory", "sequential-thinking"]
            missing_core = [server for server in core_servers if server not in configured_servers]
            
            if missing_core:
                print(f"[CHECK] Missing core MCP servers: {', '.join(missing_core)} - running auto-loader...")
                return True
            
            print("[OK] MCP servers already configured")
            return False
            
        except Exception as e:
            print(f"[WARNING] Error checking MCP configuration: {e}")
            return False
    
    def _get_configured_mcp_servers(self) -> list:
        """Get list of configured MCP servers using Claude CLI
        
        Returns:
            List of configured server names
        """
        try:
            # Try different commands to access Claude CLI
            commands_to_try = ["claude.cmd", "claude"]
            
            for claude_cmd in commands_to_try:
                try:
                    result = subprocess.run(
                        [claude_cmd, "mcp", "list"],
                        capture_output=True,
                        text=True,
                        timeout=15
                    )
                    
                    if result.returncode == 0:
                        print(f"[DEBUG] Claude MCP list output: {repr(result.stdout)}")
                        servers = self._parse_mcp_list_output(result.stdout)
                        print(f"[DEBUG] Parsed servers: {servers}")
                        return servers
                        
                except FileNotFoundError:
                    continue
            
            # If Claude CLI not accessible, return empty list
            print("[DEBUG] Claude CLI not accessible")
            return []
            
        except Exception as e:
            print(f"[DEBUG] Exception in _get_configured_mcp_servers: {e}")
            return []
    
    def _parse_mcp_list_output(self, output: str) -> list:
        """Parse claude mcp list output to extract server names
        
        Args:
            output: Output from claude mcp list command
            
        Returns:
            List of server names
        """
        servers = []
        lines = output.strip().split('\n')
        
        for line in lines:
            # Look for server entries (format: "server_name: command - ✓ Connected")
            if ':' in line and ('✓ Connected' in line or '✗ Failed' in line or '⚠ Warning' in line):
                server_name = line.split(':')[0].strip()
                if server_name and not server_name.startswith('[') and not server_name.startswith('Checking'):
                    servers.append(server_name)
        
        return servers
    
    def run_mcp_auto_loader(self) -> bool:
        """Run the enhanced MCP auto-loader script
        
        Returns:
            bool: True if successful
        """
        try:
            print(" Running MCP server auto-loader...")
            
            result = subprocess.run(
                [sys.executable, str(self.mcp_loader_script)],
                capture_output=True,
                text=True,
                timeout=300,  # 5 minute timeout
                cwd=self.project_root
            )
            
            # Print loader output
            if result.stdout:
                print(result.stdout)
            
            if result.stderr:
                print("Loader warnings/errors:")
                print(result.stderr)
            
            if result.returncode == 0:
                print("[OK] MCP auto-loader completed successfully")
                return True
            else:
                print(f"[ERROR] MCP auto-loader failed with return code: {result.returncode}")
                return False
                
        except subprocess.TimeoutExpired:
            print("[TIMEOUT] MCP auto-loader timed out")
            return False
        except Exception as e:
            print(f"[ERROR] Error running MCP auto-loader: {e}")
            return False
    
    def verify_mcp_configuration(self) -> Dict[str, Any]:
        """Verify the MCP configuration after loading
        
        Returns:
            Dict containing verification results
        """
        try:
            configured_servers = self._get_configured_mcp_servers()
            
            return {
                "success": True,
                "total_servers": len(configured_servers),
                "server_names": configured_servers,
                "message": f"[OK] {len(configured_servers)} MCP servers configured"
            }
            
        except Exception as e:
            return {
                "success": False,
                "total_servers": 0,
                "server_names": [],
                "message": f"[ERROR] Error verifying configuration: {e}"
            }
    
    def run_integration_check(self) -> Dict[str, Any]:
        """Run the complete MCP integration check
        
        Returns:
            Dict containing integration results
        """
        results = {
            "hook_executed": True,
            "loader_ran": False,
            "loader_successful": False,
            "verification": {}
        }
        
        print(" MCP Integration Hook Starting...")
        
        # Check if loader should run
        if self.should_run_mcp_loader():
            results["loader_ran"] = True
            
            # Run the auto-loader
            if self.run_mcp_auto_loader():
                results["loader_successful"] = True
        
        # Verify final configuration
        results["verification"] = self.verify_mcp_configuration()
        
        print(" MCP Integration Hook Complete")
        print(results["verification"]["message"])
        
        return results


def main():
    """Main execution function for hook"""
    try:
        # Initialize hook
        hook = MCPIntegrationHook()
        
        # Run integration check
        results = hook.run_integration_check()
        
        # Return success if verification passed
        return 0 if results["verification"]["success"] else 1
        
    except Exception as e:
        print(f"[ERROR] MCP Integration Hook Error: {e}")
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)