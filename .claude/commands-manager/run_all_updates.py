#!/usr/bin/env python3
"""
Simple script to run all update scripts in sequence on one or more directories.

Usage:
    python run_all_updates_simple.py [dir1] [dir2] ...

    If no directories specified, updates the current directory.

Examples:
    python run_all_updates_simple.py
    python run_all_updates_simple.py C:/GitHub_Development/projects/hive-mind-nexus
    python run_all_updates_simple.py . ../another-repo ../third-repo
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import List

# List of scripts to run in order
UPDATE_SCRIPTS: List[str] = [
    "update_commands_with_compliance.py",
    "fix_protocol_references.py",
    "update_git_practices.py",
    "add_devsecops_loop.py",
    "add_mcp_requirements.py",
    "add_no_mocking_requirements.py",
    "add_200_verification.py",
    "add_hygiene_enforcement.py",
    "add_init_requirement.py"
]


def run_scripts_on_directory(target_dir: str) -> bool:
    """Run all update scripts on a specific directory."""
    target_path = Path(target_dir).absolute()
    
    print(f"\n{'='*60}")
    print(f"Processing directory: {target_path}")
    print('='*60)
    
    # Save current directory
    original_dir = os.getcwd()
    
    try:
        # Change to target directory
        os.chdir(target_path)
        
        # Get the commands-manager directory path
        if target_path.name == '.claude':
            # We're already in .claude, scripts are in commands-manager
            scripts_dir = target_path / 'commands-manager'
        else:
            # We're in the repo root, scripts are in .claude/commands-manager
            scripts_dir = target_path / '.claude' / 'commands-manager'
        
        if not scripts_dir.exists():
            print(f"ERROR: commands-manager directory not found at {scripts_dir}")
            return False
        
        # Run each script
        for script_name in UPDATE_SCRIPTS:
            script_path = scripts_dir / script_name
            
            if not script_path.exists():
                print(f"WARNING: Script not found: {script_path}")
                continue
            
            print(f"\nRunning: {script_name}")
            print("-" * 40)
            
            try:
                result = subprocess.run(
                    [sys.executable, str(script_path)],
                    capture_output=True,
                    text=True,
                    check=True
                )
                
                # Show output
                if result.stdout:
                    print(result.stdout)
                
                if result.stderr:
                    print(result.stderr)
                    
            except subprocess.CalledProcessError as e:
                print(f"ERROR: Script failed with return code {e.returncode}")
                if e.stdout:
                    print("STDOUT:", e.stdout)
                if e.stderr:
                    print("STDERR:", e.stderr)
            except (FileNotFoundError, PermissionError, OSError) as e:
                print(f"ERROR: {str(e)}")
                return False
        
        return True
        
    finally:
        # Always return to original directory
        os.chdir(original_dir)


def main() -> None:
    """Main function."""
    print("Claude Code CLI Update Runner")
    print("Running all update scripts in sequence...")
    
    # Get directories from command line or use current directory
    if len(sys.argv) > 1:
        directories = sys.argv[1:]
    else:
        directories = ['.']
    
    # Process each directory
    success_count = 0
    for directory in directories:
        if Path(directory).exists():
            if run_scripts_on_directory(directory):
                success_count += 1
            else:
                print(f"\nFailed to process: {directory}")
        else:
            print(f"\nERROR: Directory does not exist: {directory}")
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"Directories processed: {success_count}/{len(directories)}")
    
    if success_count == len(directories):
        print("\n✓ All updates completed successfully!")
    else:
        print("\n⚠ Some directories had errors.")


if __name__ == "__main__":
    main()
