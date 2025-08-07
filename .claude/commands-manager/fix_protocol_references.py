#!/usr/bin/env python3
"""
Fix protocol file references in Claude Code CLI commands.
Updates incorrect protocol file references to the correct filenames.
"""

import os
import glob

def fix_protocol_reference(filepath):
    """Fix protocol file references in a single command file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if file has the old reference
    if 'code-protocol.md' not in content:
        return False
    
    # Replace the old reference with the new one
    original_content = content
    content = content.replace(
        '`./claude/commands/protocol/code-protocol.md`',
        '`./claude/commands/protocol/code-protocol-compliance-prompt.md`'
    )
    
    # Only write if changes were made
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed protocol reference in: {filepath}")
        return True
    
    return False

def main():
    """Fix protocol references in all command files."""
    command_dirs = [
        '.claude/commands/code/*.md',
        '.claude/commands/repo/*.md',
        '.claude/commands/actions/*.md',
        '.claude/commands/testing/*.md',
        '.claude/commands/docs/*.md',
        '.claude/commands/composite/*.md',
        '.claude/commands/frontend/*.md',
        '.claude/commands/backend/*.md',
        '.claude/commands/architecture/*.md',
        '.claude/commands/planning/*.md',
        '.claude/commands/implementation/*.md'
    ]
    
    fixed_count = 0
    
    for pattern in command_dirs:
        files = glob.glob(pattern)
        for filepath in files:
            if fix_protocol_reference(filepath):
                fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()