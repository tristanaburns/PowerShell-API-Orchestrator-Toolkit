#!/usr/bin/env python3
"""
MCP Server Detection and Dynamic Loading Hook
Detects available MCP tool servers and generates dynamic configuration
"""

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any


class MCPServerDetector:
    """Detects and configures available MCP tool servers dynamically"""
    
    def __init__(self, project_root: Optional[str] = None):
        """Initialize MCP server detector
        
        Args:
            project_root: Project root directory path
        """
        self.project_root = Path(project_root) if project_root else Path.cwd()
        self.settings_file = self.project_root / ".claude" / "settings.json"
        self.mcp_servers = {}
        
    def detect_npx_mcp_servers(self) -> Dict[str, Dict[str, Any]]:
        """Detect available npx MCP servers"""
        common_mcp_servers = [
            {
                "name": "filesystem",
                "package": "@modelcontextprotocol/server-filesystem",
                "description": "File system operations and management",
                "args": [self.project_root.as_posix()]
            },
            {
                "name": "git",
                "package": "@modelcontextprotocol/server-git", 
                "description": "Git repository operations and version control",
                "args": [self.project_root.as_posix()]
            },
            {
                "name": "memory",
                "package": "@modelcontextprotocol/server-memory",
                "description": "Persistent memory and context management",
                "args": []
            },
            {
                "name": "sequential-thinking",
                "package": "@modelcontextprotocol/server-sequential-thinking",
                "description": "Sequential reasoning and thinking processes", 
                "args": []
            },
            {
                "name": "sqlite",
                "package": "@modelcontextprotocol/server-sqlite",
                "description": "SQLite database operations",
                "args": [str(self.project_root / "data" / "database.db")]
            },
            {
                "name": "postgres",
                "package": "@modelcontextprotocol/server-postgres",
                "description": "PostgreSQL database operations",
                "args": ["postgresql://localhost/python_rest_api"]
            },
            {
                "name": "docker",
                "package": "@modelcontextprotocol/server-docker",
                "description": "Docker container management and operations",
                "args": []
            },
            {
                "name": "kubernetes",
                "package": "@modelcontextprotocol/server-kubernetes",
                "description": "Kubernetes cluster operations",
                "args": []
            },
            {
                "name": "github",
                "package": "@modelcontextprotocol/server-github",
                "description": "GitHub repository and API operations",
                "args": []
            },
            {
                "name": "slack",
                "package": "@modelcontextprotocol/server-slack",
                "description": "Slack workspace integration",
                "args": []
            },
            {
                "name": "brave-search",
                "package": "@modelcontextprotocol/server-brave-search",
                "description": "Web search via Brave Search API",
                "args": []
            },
            {
                "name": "puppeteer",
                "package": "@modelcontextprotocol/server-puppeteer",
                "description": "Web scraping and browser automation",
                "args": []
            },
            {
                "name": "fetch",
                "package": "@modelcontextprotocol/server-fetch",
                "description": "HTTP requests and web content fetching",
                "args": []
            },
            {
                "name": "everything",
                "package": "@modelcontextprotocol/server-everything",
                "description": "Everything search integration for Windows",
                "args": []
            }
        ]
        
        available_servers = {}
        
        for server in common_mcp_servers:
            if self._check_npx_package_available(server["package"]):
                available_servers[server["name"]] = {
                    "command": "npx",
                    "args": ["-y", server["package"]] + server["args"],
                    "transport": "stdio",
                    "description": server["description"]
                }
                
        return available_servers
    
    def detect_python_mcp_servers(self) -> Dict[str, Dict[str, Any]]:
        """Detect available Python MCP servers"""
        python_servers = {}
        
        # Check for local Python MCP server implementations
        mcp_scripts_dir = self.project_root / "scripts" / "mcp"
        if mcp_scripts_dir.exists():
            for script_file in mcp_scripts_dir.glob("*_mcp_server.py"):
                server_name = script_file.stem.replace("_mcp_server", "")
                python_servers[f"python-{server_name}"] = {
                    "command": "python",
                    "args": [str(script_file)],
                    "transport": "stdio",
                    "description": f"Custom Python MCP server for {server_name}"
                }
        
        # Check for pip-installed MCP servers
        pip_mcp_servers = [
            {
                "name": "mcp-server-time",
                "module": "mcp_server_time",
                "description": "Time and date operations"
            },
            {
                "name": "mcp-server-weather",
                "module": "mcp_server_weather", 
                "description": "Weather information and forecasts"
            }
        ]
        
        for server in pip_mcp_servers:
            if self._check_python_module_available(server["module"]):
                python_servers[server["name"]] = {
                    "command": "python",
                    "args": ["-m", server["module"]],
                    "transport": "stdio", 
                    "description": server["description"]
                }
                
        return python_servers
    
    def _check_npx_package_available(self, package: str) -> bool:
        """Check if an npx package is available"""
        try:
            # Try to get package info without installing
            result = subprocess.run(
                ["npx", "--yes", "--quiet", package, "--version"],
                capture_output=True,
                text=True,
                timeout=10
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.SubprocessError):
            return False
    
    def _check_python_module_available(self, module: str) -> bool:
        """Check if a Python module is available"""
        try:
            subprocess.run(
                [sys.executable, "-c", f"import {module}"],
                capture_output=True,
                check=True,
                timeout=5
            )
            return True
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def detect_all_servers(self) -> Dict[str, Dict[str, Any]]:
        """Detect all available MCP servers"""
        all_servers = {}
        
        # Detect npx-based servers
        npx_servers = self.detect_npx_mcp_servers()
        all_servers.update(npx_servers)
        
        # Detect Python-based servers
        python_servers = self.detect_python_mcp_servers()
        all_servers.update(python_servers)
        
        return all_servers
    
    def update_settings_file(self, detected_servers: Dict[str, Dict[str, Any]]) -> bool:
        """Update settings.json with detected MCP servers"""
        try:
            if not self.settings_file.exists():
                print(f"Settings file not found: {self.settings_file}")
                return False
                
            with open(self.settings_file, 'r', encoding='utf-8') as f:
                settings = json.load(f)
            
            # Update or create mcpServers section
            settings["mcpServers"] = detected_servers
            
            # Write updated settings
            with open(self.settings_file, 'w', encoding='utf-8') as f:
                json.dump(settings, f, indent=2, ensure_ascii=False)
                
            return True
            
        except Exception as e:
            print(f"Error updating settings file: {e}")
            return False
    
    def generate_report(self, detected_servers: Dict[str, Dict[str, Any]]) -> str:
        """Generate a report of detected MCP servers"""
        report = ["=== MCP Server Detection Report ===", ""]
        
        if not detected_servers:
            report.append("No MCP servers detected.")
            return "\n".join(report)
        
        report.append(f"Found {len(detected_servers)} available MCP servers:")
        report.append("")
        
        for name, config in detected_servers.items():
            report.append(f"• {name}")
            report.append(f"  Command: {config['command']} {' '.join(config['args'])}")
            report.append(f"  Description: {config['description']}")
            report.append("")
        
        return "\n".join(report)


def main():
    """Main execution function"""
    try:
        # Initialize detector
        detector = MCPServerDetector()
        
        # Detect available servers
        print("Detecting available MCP servers...")
        detected_servers = detector.detect_all_servers()
        
        # Generate and print report
        report = detector.generate_report(detected_servers)
        print(report)
        
        # Update settings file
        if detected_servers:
            print("Updating settings.json with detected servers...")
            if detector.update_settings_file(detected_servers):
                print("Settings file updated successfully.")
            else:
                print("Failed to update settings file.")
        else:
            print("No servers detected - settings file not modified.")
            
        return len(detected_servers)
        
    except Exception as e:
        print(f"Error in MCP server detection: {e}")
        return 0


if __name__ == "__main__":
    exit_code = main()
    sys.exit(0 if exit_code > 0 else 1)