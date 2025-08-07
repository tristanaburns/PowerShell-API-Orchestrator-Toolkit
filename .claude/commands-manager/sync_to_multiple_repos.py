#!/usr/bin/env python3
"""
Synchronize Claude Code CLI commands and configurations to multiple repositories.
This script copies all updated command files, scripts, hooks, and settings from
python-rest-api-scripts to specified target repositories.
"""

import os
import shutil
import glob
from pathlib import Path
from datetime import datetime

# Source and destination paths
SOURCE_BASE = Path(".claude")

# Target repositories
TARGETS = [
    {
        "name": "hive-mind-nexus",
        "path": Path("C:/GitHub_Development/projects/hive-mind-nexus/.claude"),
        "enabled": True
    },
    {
        "name": "vscode-toolkit (main)",
        "path": Path("C:/GitHub_Development/vscode-toolkit/.claude"),
        "enabled": True
    },
    {
        "name": "vscode-toolkit (prompt_templates)",
        "path": Path("C:/GitHub_Development/vscode-toolkit/prompt_templates/.claude"),
        "enabled": True
    }
]

def ensure_directory(path):
    """Ensure directory exists."""
    path.mkdir(parents=True, exist_ok=True)

def copy_file_with_backup(src, dest):
    """Copy file with optional backup of existing file."""
    if dest.exists():
        # Create backup with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup = dest.with_suffix(f"{dest.suffix}.backup_{timestamp}")
        shutil.copy2(dest, backup)
        print(f"    Backed up: {dest.name} -> {backup.name}")
    
    shutil.copy2(src, dest)
    print(f"    Copied: {src.name}")

def sync_directory(src_dir, dest_dir, pattern="*", verbose=True):
    """Synchronize all files matching pattern from source to destination directory."""
    ensure_directory(dest_dir)
    
    src_files = list(src_dir.glob(pattern))
    copied = 0
    
    for src_file in src_files:
        if src_file.is_file():
            dest_file = dest_dir / src_file.name
            if verbose:
                copy_file_with_backup(src_file, dest_file)
            else:
                shutil.copy2(src_file, dest_file)
            copied += 1
    
    return copied

def sync_to_target(target):
    """Synchronize to a single target repository."""
    print(f"\n{'='*60}")
    print(f"Synchronizing to: {target['name']}")
    print(f"Path: {target['path']}")
    print('='*60)
    
    dest_base = target['path']
    
    # Check if destination exists
    if not dest_base.parent.exists():
        print(f"ERROR: Destination directory does not exist: {dest_base.parent}")
        print("Skipping this target.")
        return {
            "target": target['name'],
            "status": "failed",
            "error": "Directory not found",
            "commands": 0,
            "scripts": 0,
            "hooks": 0,
            "settings": 0
        }
    
    # Sync commands
    print("\n1. Synchronizing command files...")
    command_dirs = [
        "commands/code",
        "commands/repo", 
        "commands/actions",
        "commands/testing",
        "commands/docs",
        "commands/composite",
        "commands/frontend",
        "commands/backend",
        "commands/architecture",
        "commands/planning",
        "commands/implementation",
        "commands/protocol"
    ]
    
    total_commands = 0
    for cmd_dir in command_dirs:
        src = SOURCE_BASE / cmd_dir
        dest = dest_base / cmd_dir
        if src.exists():
            count = sync_directory(src, dest, "*.md", verbose=False)
            total_commands += count
            if count > 0:
                print(f"  {cmd_dir}: {count} files")
    
    # Sync CANONICAL-COMPLIANCE-HEADER.md
    print("\n2. Synchronizing compliance header...")
    src_header = SOURCE_BASE / "commands/CANONICAL-COMPLIANCE-HEADER.md"
    dest_header = dest_base / "commands/CANONICAL-COMPLIANCE-HEADER.md"
    if src_header.exists():
        ensure_directory(dest_header.parent)
        copy_file_with_backup(src_header, dest_header)
    
    # Sync commands-manager scripts
    print("\n3. Synchronizing commands-manager scripts...")
    src_manager = SOURCE_BASE / "commands-manager"
    dest_manager = dest_base / "commands-manager"
    manager_count = 0
    if src_manager.exists():
        manager_count = sync_directory(src_manager, dest_manager, "*.py", verbose=False)
        print(f"  Total scripts: {manager_count}")
        # Also sync the README
        readme_src = src_manager / "README.md"
        if readme_src.exists():
            copy_file_with_backup(readme_src, dest_manager / "README.md")
    
    # Sync hooks if they exist
    print("\n4. Checking for hooks...")
    src_hooks = SOURCE_BASE / "hooks"
    hooks_count = 0
    if src_hooks.exists():
        dest_hooks = dest_base / "hooks"
        hooks_count = sync_directory(src_hooks, dest_hooks, "*", verbose=False)
        print(f"  Total hooks: {hooks_count}")
    else:
        print("  No hooks directory found")
    
    # Sync settings if they exist
    print("\n5. Checking for settings...")
    settings_files = ["settings.json", "config.json", ".env.template"]
    settings_count = 0
    for settings_file in settings_files:
        src_file = SOURCE_BASE / settings_file
        if src_file.exists():
            dest_file = dest_base / settings_file
            copy_file_with_backup(src_file, dest_file)
            settings_count += 1
    print(f"  Total settings files: {settings_count}")
    
    return {
        "target": target['name'],
        "status": "success",
        "commands": total_commands,
        "scripts": manager_count,
        "hooks": hooks_count,
        "settings": settings_count
    }

def main():
    """Main synchronization function."""
    print("Claude Code CLI Multi-Repository Synchronization Tool")
    print(f"Source: {SOURCE_BASE.absolute()}")
    print(f"\nConfigured targets ({len(TARGETS)}):")
    for i, target in enumerate(TARGETS, 1):
        status = "✓ Enabled" if target['enabled'] else "✗ Disabled"
        print(f"  {i}. {target['name']} - {status}")
    
    # Process each enabled target
    results = []
    for target in TARGETS:
        if target['enabled']:
            result = sync_to_target(target)
            results.append(result)
        else:
            print(f"\nSkipping disabled target: {target['name']}")
    
    # Summary
    print("\n" + "="*60)
    print("SYNCHRONIZATION SUMMARY")
    print("="*60)
    
    for result in results:
        if result['status'] == 'success':
            print(f"\n{result['target']}:")
            print(f"  ✓ Commands synchronized: {result['commands']}")
            print(f"  ✓ Manager scripts synchronized: {result['scripts']}")
            print(f"  ✓ Hooks synchronized: {result['hooks']}")
            print(f"  ✓ Settings synchronized: {result['settings']}")
        else:
            print(f"\n{result['target']}:")
            print(f"  ✗ Failed: {result.get('error', 'Unknown error')}")
    
    print("\n" + "="*60)
    print("\nNEXT STEPS:")
    print("1. Review changes in each target repository")
    print("2. Create feature branches before committing:")
    print("   git checkout -b feature/sync-claude-commands")
    print("3. Add and commit the .claude directory:")
    print("   git add .claude/")
    print("   git commit -m 'feat: sync Claude Code CLI commands with compliance requirements'")
    print("\nTo disable a target, edit the TARGETS list in this script.")

if __name__ == "__main__":
    main()