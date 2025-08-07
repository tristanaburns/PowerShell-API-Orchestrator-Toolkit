#!/usr/bin/env python3
"""
Enhanced MCP Server Auto-Loader with Installation
Auto-installs and configures MCP servers for complex coding work
"""

import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple


class MCPAutoInstaller:
    """Auto-installs and loads MCP servers for complex coding workflows"""
    
    def __init__(self, project_root: Optional[str] = None):
        """Initialize MCP auto-installer
        
        Args:
            project_root: Project root directory path
        """
        self.project_root = Path(project_root) if project_root else Path.cwd()
        self.settings_file = self.project_root / ".claude" / "settings.json"
        
        # Define MCP servers for complex coding work
        self.coding_mcp_servers = {
            # Core Essential Servers
            "memory": {
                "package": "@modelcontextprotocol/server-memory",
                "description": "Persistent memory and context management",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-memory"],
                "priority": 1,
                "category": "core",
                "auto_install": True
            },
            "sequential-thinking": {
                "package": "@modelcontextprotocol/server-sequential-thinking", 
                "description": "Sequential reasoning and thinking processes",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
                "priority": 2,
                "category": "core",
                "auto_install": True
            },
            "context7": {
                "package": "@context7/mcp-server",
                "description": "Context7 enhanced context management",
                "command": "npx",
                "args_template": ["-y", "@context7/mcp-server"],
                "priority": 3,
                "category": "core",
                "auto_install": False,  # Requires API key
                "requires_api_key": True
            },
            "zen": {
                "package": "git+https://github.com/BeehiveInnovations/zen-mcp-server.git",
                "github_repo": "BeehiveInnovations/zen-mcp-server",
                "description": "Zen MCP server for enhanced development workflows",
                "command": "node",
                "args_template": ["./mcp-servers/zen/index.js"],
                "priority": 3.5,
                "category": "core",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "fetch": {
                "package": "@modelcontextprotocol/server-fetch",
                "description": "HTTP requests and web content fetching",
                "command": "npx", 
                "args_template": ["-y", "@modelcontextprotocol/server-fetch"],
                "priority": 4,
                "category": "core",
                "auto_install": True
            },
            
            # Development & Version Control - DISABLED FOR CLAUDE CODE CLI
            "filesystem": {
                "package": "@modelcontextprotocol/server-filesystem",
                "description": "File system operations and management",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-filesystem", self.project_root.as_posix()],
                "priority": 5,
                "category": "development",
                "auto_install": False  # Disabled for Claude Code CLI
            },
            "desktop-commander": {
                "package": "@desktop-commander/mcp-server",
                "description": "Windows desktop management and system operations",
                "command": "npx",
                "args_template": ["-y", "@desktop-commander/mcp-server"],
                "priority": 5.5,
                "category": "development",
                "auto_install": False,  # Disabled for Claude Code CLI
                "os_specific": "windows"
            },
            
            # Database & Storage
            "sqlite": {
                "package": "@modelcontextprotocol/server-sqlite",
                "description": "SQLite database operations",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-sqlite", str(self.project_root / "data" / "database.db")],
                "priority": 6,
                "category": "database",
                "auto_install": True
            },
            "postgres": {
                "package": "@modelcontextprotocol/server-postgres",
                "description": "PostgreSQL database operations",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-postgres"],
                "priority": 7,
                "category": "database",
                "auto_install": False  # Requires database setup
            },
            
            # Container & Infrastructure
            "docker": {
                "package": "@modelcontextprotocol/server-docker",
                "description": "Docker container management and operations",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-docker"],
                "priority": 8,
                "category": "infrastructure",
                "auto_install": True
            },
            "kubernetes": {
                "package": "@modelcontextprotocol/server-kubernetes",
                "description": "Kubernetes cluster operations",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-kubernetes"],
                "priority": 9,
                "category": "infrastructure",
                "auto_install": False  # Requires cluster access
            },
            
            # Web & API Development
            "puppeteer": {
                "package": "@modelcontextprotocol/server-puppeteer",
                "description": "Web scraping and browser automation",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-puppeteer"],
                "priority": 10,
                "category": "web",
                "auto_install": True
            },
            
            # Code Analysis & Quality
            "everything": {
                "package": "@modelcontextprotocol/server-everything",
                "description": "Everything search integration for Windows",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-everything"],
                "priority": 12,
                "category": "search",
                "auto_install": True,
                "os_specific": "windows"
            },
            
            
            # Additional Coding Tools
            "time": {
                "package": "@modelcontextprotocol/server-time",
                "description": "Time and date operations for logging and scheduling",
                "command": "npx",
                "args_template": ["-y", "@modelcontextprotocol/server-time"],
                "priority": 14,
                "category": "utility",
                "auto_install": True
            },
            "claude-swarm": {
                "package": "git+https://github.com/parruda/claude-swarm.git",
                "github_repo": "parruda/claude-swarm",
                "description": "Claude swarm coordination and multi-agent orchestration",
                "command": "node",
                "args_template": ["./mcp-servers/claude-swarm/index.js"],
                "priority": 15,
                "category": "core",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "ccusage": {
                "package": "git+https://github.com/ryoppippi/ccusage.git",
                "github_repo": "ryoppippi/ccusage",
                "description": "Claude Code usage tracking and analytics",
                "command": "node",
                "args_template": ["./mcp-servers/ccusage/index.js"],
                "priority": 16,
                "category": "utility",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "claude-code-proxy": {
                "package": "git+https://github.com/1rgs/claude-code-proxy.git",
                "github_repo": "1rgs/claude-code-proxy",
                "description": "Claude Code proxy server for enhanced development workflows",
                "command": "node",
                "args_template": ["./mcp-servers/claude-code-proxy/index.js"],
                "priority": 17,
                "category": "development",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "claude-code-flow": {
                "package": "git+https://github.com/ruvnet/claude-code-flow.git",
                "github_repo": "ruvnet/claude-code-flow",
                "description": "Claude Code workflow automation and orchestration",
                "command": "node",
                "args_template": ["./mcp-servers/claude-code-flow/index.js"],
                "priority": 18,
                "category": "development",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "claude-code-requirements-builder": {
                "package": "git+https://github.com/rizethereum/claude-code-requirements-builder.git",
                "github_repo": "rizethereum/claude-code-requirements-builder",
                "description": "Claude Code requirements analysis and documentation builder",
                "command": "node",
                "args_template": ["./mcp-servers/claude-code-requirements-builder/index.js"],
                "priority": 19,
                "category": "development",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "agent-rules": {
                "package": "git+https://github.com/steipete/agent-rules.git",
                "github_repo": "steipete/agent-rules",
                "description": "Agent rules and guidelines for AI development workflows",
                "command": "node",
                "args_template": ["./mcp-servers/agent-rules/index.js"],
                "priority": 20,
                "category": "utility",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "dotai": {
                "package": "git+https://github.com/udecode/dotai.git",
                "github_repo": "udecode/dotai",
                "description": "DotAI - AI-powered development tools and utilities",
                "command": "node",
                "args_template": ["./mcp-servers/dotai/index.js"],
                "priority": 21,
                "category": "development",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "gemini-for-claude-code": {
                "package": "git+https://github.com/coffeegrind123/gemini-for-claude-code.git",
                "github_repo": "coffeegrind123/gemini-for-claude-code",
                "description": "Gemini integration for Claude Code development workflows",
                "command": "node",
                "args_template": ["./mcp-servers/gemini-for-claude-code/index.js"],
                "priority": 22,
                "category": "core",
                "auto_install": False,  # Requires Gemini API key
                "install_type": "git_clone",
                "requires_api_key": True
            },
            "claudebox": {
                "package": "git+https://github.com/RchGrav/claudebox.git",
                "github_repo": "RchGrav/claudebox",
                "description": "Claudebox - Sandbox environment for Claude Code development",
                "command": "node",
                "args_template": ["./mcp-servers/claudebox/index.js"],
                "priority": 23,
                "category": "development",
                "auto_install": True,
                "install_type": "git_clone"
            },
            "claudia": {
                "package": "git+https://github.com/getAsterisk/claudia.git",
                "github_repo": "getAsterisk/claudia",
                "description": "Claudia - Advanced Claude Code assistant and automation framework",
                "command": "node",
                "args_template": ["./mcp-servers/claudia/index.js"],
                "priority": 24,
                "category": "core",
                "auto_install": True,
                "install_type": "git_clone"
            }
        }
    
    def check_os_compatibility(self, server_config: Dict[str, Any]) -> bool:
        """Check if server is compatible with current OS
        
        Args:
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if compatible or no OS restriction
        """
        os_specific = server_config.get("os_specific")
        if not os_specific:
            return True
            
        current_os = sys.platform.lower()
        
        if os_specific == "windows" and not current_os.startswith("win"):
            return False
        elif os_specific == "linux" and not current_os.startswith("linux"):
            return False
        elif os_specific == "macos" and not current_os.startswith("darwin"):
            return False
            
        return True
    
    def check_prerequisites(self) -> Tuple[bool, List[str]]:
        """Check system prerequisites for MCP servers
        
        Returns:
            Tuple of (success, missing_prerequisites)
        """
        missing = []
        
        # Check Node.js/npm - try both direct and cmd wrapper
        if not self._check_command_available("node", "--version"):
            missing.append("Node.js")
        
        # Check npx - try both direct and cmd wrapper
        if not self._check_command_available("npx", "--version"):
            missing.append("npx")
        
        # Check Git - try both direct and cmd wrapper
        if not self._check_command_available("git", "--version"):
            missing.append("Git")
        
        return len(missing) == 0, missing
    
    def _check_command_available(self, command: str, *args) -> bool:
        """Check if a command is available, trying different execution methods
        
        Args:
            command: Command to check
            *args: Arguments to pass to command
            
        Returns:
            bool: True if command is available
        """
        import shutil
        
        # First try shutil.which
        if shutil.which(command):
            return True
            
        # Try common Windows locations for Node.js commands
        if command in ['node', 'npm', 'npx']:
            common_paths = [
                os.path.join(os.environ.get('PROGRAMFILES', 'C:\\Program Files'), 'nodejs', f'{command}.exe'),
                os.path.join(os.environ.get('PROGRAMFILES', 'C:\\Program Files'), 'nodejs', f'{command}.cmd'),
                os.path.join(os.environ.get('PROGRAMFILES(X86)', 'C:\\Program Files (x86)'), 'nodejs', f'{command}.exe'),
                os.path.join(os.environ.get('PROGRAMFILES(X86)', 'C:\\Program Files (x86)'), 'nodejs', f'{command}.cmd'),
                os.path.expanduser(f'~\\AppData\\Roaming\\npm\\{command}.cmd'),
                os.path.expanduser(f'~\\scoop\\apps\\nodejs\\current\\{command}.cmd'),
                os.path.expanduser(f'~\\scoop\\apps\\nodejs\\current\\{command}.exe')
            ]
            
            for path in common_paths:
                if os.path.exists(path):
                    # Test if it actually works
                    try:
                        result = subprocess.run(
                            [path] + list(args),
                            capture_output=True,
                            text=True,
                            timeout=5,
                            shell=False
                        )
                        if result.returncode == 0:
                            return True
                    except:
                        continue
        
        # Try different command variants for Windows compatibility
        commands_to_try = [
            [command] + list(args),
            ["cmd", "/c", command] + list(args),
            [f"{command}.cmd"] + list(args),
            [f"{command}.exe"] + list(args)
        ]
        
        for cmd_variant in commands_to_try:
            try:
                result = subprocess.run(
                    cmd_variant, 
                    capture_output=True, 
                    text=True, 
                    timeout=5,
                    shell=True  # Enable shell for better PATH resolution
                )
                if result.returncode == 0:
                    return True
            except (FileNotFoundError, subprocess.TimeoutExpired):
                continue
        
        return False
    
    def install_mcp_server(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Install a specific MCP server package
        
        Args:
            server_name: Name of the server
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if installation successful
        """
        if not server_config.get("auto_install", False):
            return False
        
        print(f"Installing {server_name}...")
        
        # Check installation type
        install_type = server_config.get("install_type", "npm")
        
        try:
            if install_type == "git_clone":
                return self._install_git_mcp_server(server_name, server_config)
            else:
                return self._install_npm_mcp_server(server_name, server_config)
                
        except subprocess.TimeoutExpired:
            print(f"[ERROR] {server_name}: Installation timeout")
            return False
        except Exception as e:
            print(f"[ERROR] {server_name}: Installation error - {e}")
            return False
    
    def _install_npm_mcp_server(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Install MCP server via npm
        
        Args:
            server_name: Name of the server
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if installation successful
        """
        # Use npm install -g for global installation
        install_cmd = ["npm", "install", "-g", server_config["package"]]
        
        result = subprocess.run(
            install_cmd,
            capture_output=True,
            text=True,
            timeout=120  # 2 minute timeout for installation
        )
        
        if result.returncode == 0:
            print(f"[OK] {server_name}: NPM installation successful")
            return True
        else:
            print(f"[ERROR] {server_name}: NPM installation failed")
            print(f"  Error: {result.stderr}")
            return False
    
    def _install_git_mcp_server(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Install MCP server via Git clone
        
        Args:
            server_name: Name of the server
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if installation successful
        """
        github_repo = server_config.get("github_repo")
        if not github_repo:
            print(f"[ERROR] {server_name}: No GitHub repository specified")
            return False
        
        # Create mcp-servers directory in project root
        mcp_servers_dir = self.project_root / "mcp-servers"
        mcp_servers_dir.mkdir(exist_ok=True)
        
        server_dir = mcp_servers_dir / server_name
        
        # Check if already cloned
        if server_dir.exists():
            print(f"[OK] {server_name}: Already cloned, updating...")
            # Try to update existing repo
            try:
                result = subprocess.run(
                    ["git", "pull"],
                    cwd=server_dir,
                    capture_output=True,
                    text=True,
                    timeout=60
                )
                if result.returncode == 0:
                    print(f"[OK] {server_name}: Updated successfully")
                    return self._install_git_dependencies(server_name, server_dir)
                else:
                    print(f"[WARNING] {server_name}: Update failed, will re-clone")
                    # Remove and re-clone
                    import shutil
                    shutil.rmtree(server_dir)
            except Exception:
                print(f"[WARNING] {server_name}: Update failed, will re-clone")
                import shutil
                shutil.rmtree(server_dir, ignore_errors=True)
        
        # Clone the repository
        git_url = f"https://github.com/{github_repo}.git"
        clone_cmd = ["git", "clone", git_url, str(server_dir)]
        
        result = subprocess.run(
            clone_cmd,
            capture_output=True,
            text=True,
            timeout=120
        )
        
        if result.returncode == 0:
            print(f"[OK] {server_name}: Git clone successful")
            return self._install_git_dependencies(server_name, server_dir)
        else:
            print(f"[ERROR] {server_name}: Git clone failed")
            print(f"  Error: {result.stderr}")
            return False
    
    def _install_git_dependencies(self, server_name: str, server_dir: Path) -> bool:
        """Install dependencies for Git-cloned MCP server
        
        Args:
            server_name: Name of the server
            server_dir: Directory containing the cloned repository
            
        Returns:
            bool: True if dependency installation successful
        """
        # Check if package.json exists
        package_json = server_dir / "package.json"
        if package_json.exists():
            print(f"[INSTALL] {server_name}: Installing npm dependencies...")
            result = subprocess.run(
                ["npm", "install"],
                cwd=server_dir,
                capture_output=True,
                text=True,
                timeout=180
            )
            
            if result.returncode == 0:
                print(f"[OK] {server_name}: Dependencies installed")
                return True
            else:
                print(f"[ERROR] {server_name}: Dependency installation failed")
                print(f"  Error: {result.stderr}")
                return False
        
        # Check if requirements.txt exists (Python)
        requirements_txt = server_dir / "requirements.txt"
        if requirements_txt.exists():
            print(f"[INSTALL] {server_name}: Installing Python dependencies...")
            result = subprocess.run(
                [sys.executable, "-m", "pip", "install", "-r", "requirements.txt"],
                cwd=server_dir,
                capture_output=True,
                text=True,
                timeout=180
            )
            
            if result.returncode == 0:
                print(f"[OK] {server_name}: Python dependencies installed")
                return True
            else:
                print(f"[ERROR] {server_name}: Python dependency installation failed")
                print(f"  Error: {result.stderr}")
                return False
        
        print(f"[OK] {server_name}: No dependencies found")
        return True
    
    def check_server_availability(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Check if a specific MCP server is available
        
        Args:
            server_name: Name of the server
            server_config: Server configuration dictionary
            
        Returns:
            bool: True if server is available
        """
        # Check OS compatibility first
        if not self.check_os_compatibility(server_config):
            print(f"- {server_name}: Skipped (OS incompatible)")
            return False
        
        # Handle Git-based installations differently
        install_type = server_config.get("install_type", "npm")
        
        if install_type == "git_clone":
            return self._check_git_server_availability(server_name, server_config)
        else:
            return self._check_npm_server_availability(server_name, server_config)
    
    def _check_npm_server_availability(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Check availability of npm-based MCP server"""
        try:
            # Test if package is available via npx
            test_args = server_config["args_template"] + ["--help"]
            
            result = subprocess.run(
                [server_config["command"]] + test_args,
                capture_output=True,
                text=True,
                timeout=15
            )
            
            # Check if server responds appropriately
            available = (
                result.returncode in [0, 1] or 
                "help" in result.stdout.lower() or
                "usage" in result.stdout.lower() or
                "error" in result.stderr.lower()  # Some servers show help via stderr
            )
            
            if available:
                print(f"[OK] {server_name}: Available")
                return True
            else:
                print(f"[INSTALL] {server_name}: Not available, attempting installation...")
                return self.install_mcp_server(server_name, server_config)
                
        except subprocess.TimeoutExpired:
            print(f"[TIMEOUT] {server_name}: Timeout, attempting installation...")
            return self.install_mcp_server(server_name, server_config)
        except FileNotFoundError:
            # Try to find the command in common locations on Windows
            if server_config['command'] == 'npx':
                import shutil
                npx_path = shutil.which('npx')
                if not npx_path:
                    # Try common Node.js installation paths
                    common_paths = [
                        r"C:\Program Files\nodejs\npx.cmd",
                        r"C:\Program Files (x86)\nodejs\npx.cmd",
                        os.path.expanduser(r"~\AppData\Roaming\npm\npx.cmd"),
                        os.path.expanduser(r"~\scoop\apps\nodejs\current\npx.cmd")
                    ]
                    for path in common_paths:
                        if os.path.exists(path):
                            npx_path = path
                            break
                
                if npx_path:
                    # Retry with full path
                    server_config['command'] = npx_path
                    return self.check_server_availability(server_name, server_config)
            
            print(f"[ERROR] {server_name}: Command '{server_config['command']}' not found")
            return False
        except Exception as e:
            print(f"[ERROR] {server_name}: Error checking availability, attempting installation...")
            return self.install_mcp_server(server_name, server_config)
    
    def _check_git_server_availability(self, server_name: str, server_config: Dict[str, Any]) -> bool:
        """Check availability of Git-based MCP server"""
        # Check if server directory exists and has required files
        mcp_servers_dir = self.project_root / "mcp-servers"
        server_dir = mcp_servers_dir / server_name
        
        if server_dir.exists():
            # Check if main file exists
            main_files = ["index.js", "server.js", "main.js", "app.js"]
            
            for main_file in main_files:
                if (server_dir / main_file).exists():
                    print(f"[OK] {server_name}: Available (local installation)")
                    return True
            
            # Check if package.json exists with main entry
            package_json = server_dir / "package.json"
            if package_json.exists():
                try:
                    import json
                    with open(package_json, 'r') as f:
                        pkg_data = json.load(f)
                    
                    main_entry = pkg_data.get("main", "index.js")
                    if (server_dir / main_entry).exists():
                        print(f"[OK] {server_name}: Available (local installation)")
                        return True
                        
                except Exception:
                    pass
        
        print(f"[INSTALL] {server_name}: Not found locally, attempting installation...")
        return self.install_mcp_server(server_name, server_config)
    
    def generate_mcp_configuration(self) -> Dict[str, Dict[str, Any]]:
        """Generate MCP server configuration for available servers
        
        Returns:
            Dict containing MCP server configurations
        """
        print("Enhanced MCP Server Auto-Loader")
        print("=" * 50)
        print("Checking prerequisites...")
        
        # Check prerequisites
        prereqs_ok, missing = self.check_prerequisites()
        if not prereqs_ok:
            print(f"[ERROR] Missing prerequisites: {', '.join(missing)}")
            print("Please install Node.js and npm first")
            return {}
        
        print("[OK] Prerequisites satisfied")
        print("")
        print("Checking and installing MCP servers...")
        print("-" * 50)
        
        mcp_config = {}
        
        # Sort servers by priority
        sorted_servers = sorted(
            self.coding_mcp_servers.items(),
            key=lambda x: x[1]["priority"]
        )
        
        for server_name, server_info in sorted_servers:
            print(f"[{server_info['category'].upper()}] ", end="")
            
            if self.check_server_availability(server_name, server_info):
                mcp_config[server_name] = {
                    "command": server_info["command"],
                    "args": server_info["args_template"],
                    "transport": "stdio",
                    "description": server_info["description"]
                }
            
            # Small delay to avoid overwhelming the system
            time.sleep(0.5)
        
        print("-" * 50)
        print(f"Configured {len(mcp_config)} out of {len(self.coding_mcp_servers)} available servers")
        
        return mcp_config
    
    def create_server_categories_summary(self, mcp_config: Dict[str, Dict[str, Any]]) -> str:
        """Create a summary of configured servers by category
        
        Args:
            mcp_config: MCP server configuration dictionary
            
        Returns:
            str: Formatted summary
        """
        categories = {}
        
        for server_name, config in mcp_config.items():
            # Find original category
            original_config = self.coding_mcp_servers.get(server_name, {})
            category = original_config.get("category", "unknown")
            
            if category not in categories:
                categories[category] = []
            
            categories[category].append({
                "name": server_name,
                "description": config["description"]
            })
        
        summary = ["MCP Server Configuration Summary", "=" * 40, ""]
        
        for category, servers in sorted(categories.items()):
            summary.append(f" {category.upper()} ({len(servers)} servers)")
            for server in servers:
                summary.append(f"  - {server['name']}: {server['description']}")
            summary.append("")
        
        return "\\n".join(summary)
    
    def update_settings_with_mcp_config(self, mcp_config: Dict[str, Dict[str, Any]]) -> bool:
        """Update settings.json with MCP server configuration
        
        Args:
            mcp_config: MCP server configuration dictionary
            
        Returns:
            bool: True if update successful
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
            
            print(f"[OK] Updated settings.json with {len(mcp_config)} MCP servers")
            return True
            
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in settings file - {e}")
            return False
        except Exception as e:
            print(f"Error updating settings file: {e}")
            return False
    
    def create_comprehensive_test_script(self) -> bool:
        """Create a test script for all MCP servers
        
        Returns:
            bool: True if script created successfully
        """
        test_script_path = self.project_root / ".claude" / "hooks" / "comprehensive_mcp_test.py"
        
        test_script_content = '''#!/usr/bin/env python3
"""
Comprehensive MCP Server Test Suite
Tests functionality of all configured MCP servers with detailed reporting
"""

import subprocess
import json
import sys
import time
from pathlib import Path
from typing import Dict, Any, List, Tuple


class MCPServerTester:
    """Comprehensive MCP server testing suite"""
    
    def __init__(self):
        self.settings_file = Path(".claude/settings.json")
        self.results = {}
    
    def test_server_initialization(self, server_name: str, server_config: Dict[str, Any]) -> Tuple[bool, str]:
        """Test MCP server initialization and basic communication"""
        try:
            cmd = [server_config["command"]] + server_config["args"]
            
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Test initialization message
            init_message = json.dumps({
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {
                        "name": "comprehensive-tester",
                        "version": "1.0.0"
                    }
                }
            }) + "\\n"
            
            stdout, stderr = process.communicate(input=init_message, timeout=10)
            
            if process.returncode == 0 or "result" in stdout.lower():
                return True, "Initialization successful"
            else:
                return False, f"Unexpected response: {stdout[:100]}"
                
        except subprocess.TimeoutExpired:
            process.kill()
            return False, "Timeout during initialization"
        except Exception as e:
            return False, f"Exception: {str(e)}"
    
    def test_server_capabilities(self, server_name: str, server_config: Dict[str, Any]) -> Tuple[bool, str]:
        """Test server capabilities discovery"""
        try:
            cmd = [server_config["command"]] + server_config["args"]
            
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Test capabilities message
            caps_message = json.dumps({
                "jsonrpc": "2.0",
                "id": 2,
                "method": "tools/list",
                "params": {}
            }) + "\\n"
            
            stdout, stderr = process.communicate(input=caps_message, timeout=8)
            
            if "tools" in stdout.lower() or "capabilities" in stdout.lower():
                return True, "Capabilities accessible"
            else:
                return False, "No capabilities found"
                
        except subprocess.TimeoutExpired:
            process.kill()
            return False, "Timeout during capabilities test"
        except Exception as e:
            return False, f"Exception: {str(e)}"
    
    def run_comprehensive_test(self) -> Dict[str, Any]:
        """Run tests on all configured MCP servers"""
        if not self.settings_file.exists():
            return {"error": "settings.json not found"}
        
        with open(self.settings_file, 'r') as f:
            settings = json.load(f)
        
        mcp_servers = settings.get("mcpServers", {})
        
        if not mcp_servers:
            return {"error": "No MCP servers configured"}
        
        print("🧪 MCP Server Test Suite")
        print("=" * 50)
        
        test_results = {
            "summary": {
                "total_servers": len(mcp_servers),
                "passed_init": 0,
                "passed_caps": 0,
                "failed": 0
            },
            "detailed_results": {}
        }
        
        for server_name, server_config in mcp_servers.items():
            print(f"\\n Testing {server_name}...")
            
            server_result = {
                "initialization": {"passed": False, "message": ""},
                "capabilities": {"passed": False, "message": ""},
                "overall_status": "FAILED"
            }
            
            # Test initialization
            init_passed, init_msg = self.test_server_initialization(server_name, server_config)
            server_result["initialization"] = {"passed": init_passed, "message": init_msg}
            
            if init_passed:
                test_results["summary"]["passed_init"] += 1
                print(f"  [OK] Initialization: {init_msg}")
                
                # Test capabilities if initialization passed
                caps_passed, caps_msg = self.test_server_capabilities(server_name, server_config)
                server_result["capabilities"] = {"passed": caps_passed, "message": caps_msg}
                
                if caps_passed:
                    test_results["summary"]["passed_caps"] += 1
                    print(f"  [OK] Capabilities: {caps_msg}")
                    server_result["overall_status"] = "PASSED"
                else:
                    print(f"  ⚠ Capabilities: {caps_msg}")
                    server_result["overall_status"] = "PARTIAL"
            else:
                test_results["summary"]["failed"] += 1
                print(f"  [ERROR] Initialization: {init_msg}")
            
            test_results["detailed_results"][server_name] = server_result
            
            # Brief pause between tests
            time.sleep(0.5)
        
        return test_results
    
    def print_summary_report(self, results: Dict[str, Any]):
        """Print a summary report"""
        if "error" in results:
            print(f"[ERROR] Test Error: {results['error']}")
            return
        
        summary = results["summary"]
        
        print("\\n" + "=" * 50)
        print(" TEST SUMMARY REPORT")
        print("=" * 50)
        print(f"Total Servers: {summary['total_servers']}")
        print(f"Initialization Passed: {summary['passed_init']}")
        print(f"Capabilities Passed: {summary['passed_caps']}")
        print(f"Failed: {summary['failed']}")
        
        success_rate = (summary['passed_init'] / summary['total_servers']) * 100
        print(f"Success Rate: {success_rate:.1f}%")
        
        print("\\n DETAILED RESULTS")
        print("-" * 30)
        
        for server_name, result in results["detailed_results"].items():
            status_icon = "[OK]" if result["overall_status"] == "PASSED" else "[WARNING]" if result["overall_status"] == "PARTIAL" else "[ERROR]"
            print(f"{status_icon} {server_name}: {result['overall_status']}")
            
            if result["overall_status"] != "PASSED":
                if not result["initialization"]["passed"]:
                    print(f"    L Init Issue: {result['initialization']['message']}")
                elif not result["capabilities"]["passed"]:
                    print(f"    L Caps Issue: {result['capabilities']['message']}")


def main():
    """Main test execution"""
    tester = MCPServerTester()
    results = tester.run_comprehensive_test()
    tester.print_summary_report(results)
    
    # Exit with appropriate code
    if "error" in results:
        return 1
    
    summary = results["summary"]
    return 0 if summary["failed"] == 0 else 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
'''
        
        try:
            with open(test_script_path, 'w', encoding='utf-8') as f:
                f.write(test_script_content)
            
            # Make script executable
            if hasattr(os, 'chmod'):
                os.chmod(test_script_path, 0o755)
            
            print(f"[OK] Created test script at {test_script_path}")
            return True
            
        except Exception as e:
            print(f"Error creating test script: {e}")
            return False
    
    def load_and_configure_all_servers(self) -> bool:
        """Main function to auto-install and configure all MCP servers
        
        Returns:
            bool: True if configuration successful
        """
        print(" MCP Server Auto-Installer")
        print("Configuring MCP servers for complex coding workflows...")
        print("")
        
        # Generate MCP configuration with auto-installation
        mcp_config = self.generate_mcp_configuration()
        
        if not mcp_config:
            print("[ERROR] No MCP servers could be configured")
            return False
        
        # Update settings file
        if not self.update_settings_with_mcp_config(mcp_config):
            print("[ERROR] Failed to update settings file")
            return False
        
        # Create test script
        self.create_comprehensive_test_script()
        
        # Print configuration summary
        print("")
        summary = self.create_server_categories_summary(mcp_config)
        print(summary)
        
        print("")
        print(" MCP server auto-installation complete!")
        print("")
        print("Next steps:")
        print("1. Run 'python .claude/hooks/comprehensive_mcp_test.py' to test all servers")
        print("2. Restart Claude Code to load the new MCP servers")
        print("3. Use '/mcp' command to verify server availability")
        
        return True


def main():
    """Main execution function"""
    try:
        loader = MCPAutoInstaller()
        success = loader.load_and_configure_all_servers()
        return 0 if success else 1
        
    except KeyboardInterrupt:
        print("\\n[CANCELLED] Operation cancelled by user")
        return 1
    except Exception as e:
        print(f"[ERROR] Error: {e}")
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)