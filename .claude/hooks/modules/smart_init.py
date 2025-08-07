"""
Smart Init Module
Intelligently determines if /init command should be run
"""

import json
import logging
import os
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, Tuple

logger = logging.getLogger(__name__)

class SmartInitChecker:
    """Checks if project initialization is needed"""
    
    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = project_root or Path.cwd()
        self.claude_md = self.project_root / "CLAUDE.md"
        self.metadata_file = self.project_root / ".claude" / ".init_metadata.json"
        self.important_patterns = [
            "*.py", "*.js", "*.ts", "*.jsx", "*.tsx",
            "package.json", "requirements.txt", "Dockerfile",
            "docker-compose*.yml", ".env.template"
        ]
    
    def should_run_init(self) -> Tuple[bool, str]:
        """Determine if /init should be run
        
        Returns:
            Tuple of (should_run, reason)
        """
        # Check 1: CLAUDE.md doesn't exist
        if not self.claude_md.exists():
            return True, "CLAUDE.md not found - initial setup needed"
        
        # Check 2: CLAUDE.md is empty or too small
        if self.claude_md.stat().st_size < 100:
            return True, "CLAUDE.md is empty or incomplete"
        
        # Check 3: First time in this project (no metadata)
        if not self.metadata_file.exists():
            return True, "First session in this project"
        
        # Check 4: Major time gap since last init
        last_init = self.get_last_init_time()
        if last_init:
            days_since = (datetime.now() - last_init).days
            if days_since > 30:
                return True, f"Last init was {days_since} days ago"
        
        # Check 5: Significant project structure changes
        if self.has_significant_changes():
            return True, "Significant project structure changes detected"
        
        # Check 6: New important files added
        if self.has_new_important_files():
            return True, "New important files detected (package.json, requirements.txt, etc.)"
        
        return False, "Project structure appears up to date"
    
    def get_last_init_time(self) -> Optional[datetime]:
        """Get timestamp of last init"""
        try:
            if self.metadata_file.exists():
                with open(self.metadata_file, 'r') as f:
                    metadata = json.load(f)
                    timestamp = metadata.get('last_init')
                    if timestamp:
                        return datetime.fromisoformat(timestamp)
        except Exception as e:
            logger.error(f"Error reading init metadata: {e}")
        return None
    
    def has_significant_changes(self) -> bool:
        """Check if project structure has changed significantly"""
        try:
            # Get current project structure
            current_structure = self.analyze_project_structure()
            
            # Compare with saved structure
            if self.metadata_file.exists():
                with open(self.metadata_file, 'r') as f:
                    metadata = json.load(f)
                    saved_structure = metadata.get('project_structure', {})
                
                # Check for new directories
                current_dirs = set(current_structure.get('directories', []))
                saved_dirs = set(saved_structure.get('directories', []))
                new_dirs = current_dirs - saved_dirs
                
                if len(new_dirs) > 2:  # More than 2 new directories
                    return True
                
                # Check for significant file count changes
                current_count = current_structure.get('file_count', 0)
                saved_count = saved_structure.get('file_count', 0)
                
                if abs(current_count - saved_count) > 20:  # More than 20 files difference
                    return True
                    
        except Exception as e:
            logger.error(f"Error checking structure changes: {e}")
        
        return False
    
    def has_new_important_files(self) -> bool:
        """Check for new important configuration files"""
        important_files = [
            "package.json", "requirements.txt", "Pipfile", "poetry.lock",
            "Dockerfile", "docker-compose.yml", "Makefile",
            ".env.template", ".env.example", "setup.py", "setup.cfg"
        ]
        
        try:
            if self.metadata_file.exists():
                with open(self.metadata_file, 'r') as f:
                    metadata = json.load(f)
                    tracked_files = set(metadata.get('important_files', []))
                
                # Check for new important files
                for file in important_files:
                    file_path = self.project_root / file
                    if file_path.exists() and file not in tracked_files:
                        return True
                        
        except Exception as e:
            logger.error(f"Error checking important files: {e}")
        
        return False
    
    def analyze_project_structure(self) -> Dict[str, Any]:
        """Analyze current project structure"""
        structure = {
            'directories': [],
            'file_count': 0,
            'important_files': []
        }
        
        try:
            # Count directories and files
            for root, dirs, files in os.walk(self.project_root):
                # Skip hidden and build directories
                dirs[:] = [d for d in dirs if not d.startswith('.') and d not in 
                          ['node_modules', '__pycache__', 'dist', 'build', 'venv']]
                
                rel_path = Path(root).relative_to(self.project_root)
                if str(rel_path) != '.':
                    structure['directories'].append(str(rel_path))
                
                structure['file_count'] += len(files)
            
            # Track important files
            for pattern in ['package.json', 'requirements.txt', 'Dockerfile', 
                           'docker-compose.yml', '.env.template']:
                for file in self.project_root.glob(pattern):
                    if file.exists():
                        structure['important_files'].append(file.name)
                        
        except Exception as e:
            logger.error(f"Error analyzing project structure: {e}")
        
        return structure
    
    def save_init_metadata(self):
        """Save metadata after init is run"""
        metadata = {
            'last_init': datetime.now().isoformat(),
            'project_structure': self.analyze_project_structure(),
            'claude_md_size': self.claude_md.stat().st_size if self.claude_md.exists() else 0
        }
        
        self.metadata_file.parent.mkdir(exist_ok=True)
        with open(self.metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

def handle(event_type: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
    """Handle smart init check"""
    checker = SmartInitChecker()
    should_init, reason = checker.should_run_init()
    
    if should_init:
        logger.info(f"Init recommended: {reason}")
        return {
            "decision": "allow",
            "context": f"\n📋 **Project Initialization Recommended**\nReason: {reason}\n\nPlease run `/init` to update CLAUDE.md with current project structure.\n"
        }
    
    return {"decision": "allow"}

def mark_init_complete():
    """Call this after /init is run successfully"""
    checker = SmartInitChecker()
    checker.save_init_metadata()
    logger.info("Init metadata saved")