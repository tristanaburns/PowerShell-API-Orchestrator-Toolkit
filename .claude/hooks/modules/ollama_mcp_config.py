"""
Ollama MCP Configuration Module
Creates and manages MCP server configuration for Ollama
"""

import json
import logging
from pathlib import Path
from typing import Dict, Any, List
import shutil

logger = logging.getLogger(__name__)

class OllamaMCPConfig:
    """Manages MCP configuration for Ollama instances"""
    
    def __init__(self):
        self.ollama_config_dir = Path(__file__).parent.parent / "ollama_configs"
        self.ollama_config_dir.mkdir(exist_ok=True)
        self.base_mcp_config = self.load_base_mcp_config()
    
    def load_base_mcp_config(self) -> Dict[str, Any]:
        """Load the base MCP configuration from project"""
        mcp_config_path = Path(__file__).parent.parent.parent / "mcp.json"
        if mcp_config_path.exists():
            with open(mcp_config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
    
    def create_ollama_mcp_config(self, work_package: Dict[str, Any]) -> str:
        """Create a custom MCP configuration for Ollama based on task type"""
        task_type = work_package["task_type"]
        package_id = work_package["id"]
        
        # Select MCP servers based on task type
        required_servers = self.select_mcp_servers(task_type, work_package)
        
        # Create Ollama-specific configuration
        ollama_mcp_config = {
            "mcpServers": {},
            "enableAll": False,  # Only enable what's needed
            "autoStart": True,
            "connectionTimeout": 30000,
            "ollama_integration": {
                "enabled": True,
                "work_package_id": package_id,
                "task_type": task_type,
                "enforce_mcp_usage": True
            }
        }
        
        # Add selected servers from base config
        base_servers = self.base_mcp_config.get("mcpServers", {})
        for server_name in required_servers:
            if server_name in base_servers:
                ollama_mcp_config["mcpServers"][server_name] = base_servers[server_name]
        
        # Save configuration
        config_file = self.ollama_config_dir / f"mcp_config_{package_id[:8]}.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(ollama_mcp_config, f, indent=2)
        
        logger.info(f"Created Ollama MCP config: {config_file}")
        return str(config_file)
    
    def select_mcp_servers(self, task_type: str, work_package: Dict[str, Any]) -> List[str]:
        """Select appropriate MCP servers for the task"""
        # Core servers always needed
        core_servers = [
            "filesystem",      # File operations
            "memory",         # Context persistence
            "sequential-thinking"  # Planning
        ]
        
        # Task-specific servers
        task_servers = {
            "function_implementation": [
                "git",           # Version control
                "code-analysis", # Code quality
                "ast-grep"       # Code search
            ],
            "test_generation": [
                "jest",          # Test runner
                "pytest",        # Python tests
                "coverage"       # Coverage analysis
            ],
            "bug_fix": [
                "git",           # Check history
                "logs",          # Error logs
                "debugger"       # Debug tools
            ],
            "api_endpoint": [
                "http",          # API testing
                "swagger",       # API docs
                "postman"        # API client
            ],
            "performance_optimization": [
                "profiler",      # Performance profiling
                "metrics",       # Performance metrics
                "benchmark"      # Benchmarking
            ],
            "security_audit": [
                "security",      # Security scanning
                "vulnerability", # Vuln detection
                "auth"          # Auth testing
            ],
            "documentation": [
                "markdown",      # Doc generation
                "jsdoc",        # JS documentation
                "sphinx"        # Python docs
            ]
        }
        
        # Combine core and task-specific servers
        selected_servers = core_servers.copy()
        selected_servers.extend(task_servers.get(task_type, []))
        
        # Add language-specific servers
        language = work_package.get("context", {}).get("language", "")
        if language == "python":
            selected_servers.extend(["python", "pip", "venv"])
        elif language in ["javascript", "typescript"]:
            selected_servers.extend(["nodejs", "npm", "eslint"])
        elif language == "go":
            selected_servers.extend(["go", "gomod"])
        elif language == "rust":
            selected_servers.extend(["rust", "cargo"])
        
        # Remove duplicates and filter to available servers
        available_servers = set(self.base_mcp_config.get("mcpServers", {}).keys())
        selected_servers = list(set(selected_servers) & available_servers)
        
        logger.info(f"Selected MCP servers for {task_type}: {selected_servers}")
        return selected_servers
    
    def create_mcp_instruction(self, work_package: Dict[str, Any], mcp_config_path: str) -> str:
        """Create instructions for Ollama to use MCP tools"""
        selected_servers = self.select_mcp_servers(work_package["task_type"], work_package)
        
        instruction = f"""
## MANDATORY MCP TOOL USAGE

You **MUST** use the following MCP tools for this task:

### Available MCP Servers:
{chr(10).join(f"- **{server}**: Available for your use" for server in selected_servers)}

### REQUIRED MCP USAGE PATTERNS:

1. **File Operations**: You **MUST** use `filesystem` MCP tool for ALL file operations
   - **FORBIDDEN**: Direct file manipulation without MCP
   - **MUST**: Use filesystem.read, filesystem.write, filesystem.list

2. **Memory/Context**: You **MUST** use `memory` tool to track your progress
   - Save your plan before starting
   - Update progress after each step
   - Record any issues or decisions

3. **Code Analysis**: You **MUST** use appropriate analysis tools
   - Use `ast-grep` for code search
   - Use language-specific tools for validation

### MCP CONFIGURATION LOADED:
- Config file: {mcp_config_path}
- Servers available: {len(selected_servers)}
- Task-optimized selection

### ENFORCEMENT:
Any code generated WITHOUT using MCP tools will be **REJECTED**.
You **SHALL** demonstrate MCP tool usage in your implementation.
"""
        
        return instruction
    
    def cleanup_old_configs(self, keep_last: int = 10):
        """Clean up old Ollama MCP configurations"""
        configs = sorted(self.ollama_config_dir.glob("mcp_config_*.json"), 
                        key=lambda x: x.stat().st_mtime)
        
        if len(configs) > keep_last:
            for config in configs[:-keep_last]:
                config.unlink()
                logger.info(f"Cleaned up old config: {config}")

def integrate_mcp_config(work_package: Dict[str, Any]) -> Dict[str, Any]:
    """Integrate MCP configuration into work package"""
    mcp_manager = OllamaMCPConfig()
    
    # Create custom MCP config for this work package
    mcp_config_path = mcp_manager.create_ollama_mcp_config(work_package)
    
    # Add MCP instructions to the work package
    mcp_instruction = mcp_manager.create_mcp_instruction(work_package, mcp_config_path)
    
    # Update work package
    work_package["mcp_config_path"] = mcp_config_path
    work_package["mcp_instruction"] = mcp_instruction
    work_package["mcp_servers_selected"] = mcp_manager.select_mcp_servers(
        work_package["task_type"], work_package
    )
    
    # Cleanup old configs
    mcp_manager.cleanup_old_configs()
    
    return work_package