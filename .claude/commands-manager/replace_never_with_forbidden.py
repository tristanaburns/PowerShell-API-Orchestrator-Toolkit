#!/usr/bin/env python3
"""
Replace "NEVER" with "FORBIDDEN" in command instructions across all repo cleanup files.
"""

import os
import glob

def replace_never_with_forbidden(filepath):
    """Replace NEVER with FORBIDDEN in a single file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"  ERROR reading {filepath}: {e}")
        return False
    
    original_content = content
    
    # Replace the specific instruction text
    content = content.replace(
        "NEVER add vague non-descriptive words to:",
        "FORBIDDEN: Add vague non-descriptive words to:"
    )
    
    # Also replace any other NEVER instances in the vague naming section
    # Look for the section and replace within it
    if "forbidden_naming_patterns:" in content:
        lines = content.split('\n')
        in_naming_section = False
        for i, line in enumerate(lines):
            if "forbidden_naming_patterns:" in line:
                in_naming_section = True
            elif in_naming_section and line.strip() and not line.startswith(' '):
                # End of the section
                in_naming_section = False
            
            if in_naming_section and "NEVER" in line:
                lines[i] = line.replace("NEVER", "FORBIDDEN")
        
        content = '\n'.join(lines)
    
    if content != original_content:
        try:
            # Replace checkmarks to avoid encoding issues
            content = content.replace('✓', '[OK]').replace('✗', '[ERROR]')
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  [OK] Updated: {os.path.basename(filepath)}")
            return True
        except Exception as e:
            print(f"  ERROR writing {filepath}: {e}")
            return False
    else:
        print(f"  - No changes needed: {os.path.basename(filepath)}")
        return False

def main():
    """Update all repo cleanup commands."""
    print("Replacing NEVER with FORBIDDEN in repo cleanup commands")
    print("=" * 60)
    
    # Find all repo cleanup command files
    repo_cleanup_files = glob.glob('../commands/repo/repo-cleanup-*.md')
    
    # Also check all command files for compliance sections
    all_command_files = []
    all_command_files.extend(glob.glob('../commands/code/*.md'))
    all_command_files.extend(glob.glob('../commands/repo/*.md'))
    all_command_files.extend(glob.glob('../commands/actions/*.md'))
    all_command_files.extend(glob.glob('../commands/testing/*.md'))
    all_command_files.extend(glob.glob('../commands/docs/*.md'))
    all_command_files.extend(glob.glob('../commands/composite/*.md'))
    all_command_files.extend(glob.glob('../commands/frontend/*.md'))
    all_command_files.extend(glob.glob('../commands/backend/*.md'))
    all_command_files.extend(glob.glob('../commands/architecture/*.md'))
    all_command_files.extend(glob.glob('../commands/planning/*.md'))
    all_command_files.extend(glob.glob('../commands/implementation/*.md'))
    
    print(f"Found {len(repo_cleanup_files)} repo cleanup files")
    print(f"Found {len(all_command_files)} total command files to check")
    
    updated_count = 0
    
    # First update repo cleanup files
    print("\nUpdating repo cleanup files:")
    for filepath in repo_cleanup_files:
        if replace_never_with_forbidden(filepath):
            updated_count += 1
    
    print("\n" + "=" * 60)
    print(f"Updated {updated_count} files")
    
    if updated_count > 0:
        print("\n[OK] Successfully replaced NEVER with FORBIDDEN in vague naming instructions")

if __name__ == "__main__":
    main()