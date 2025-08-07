#!/usr/bin/env python3
"""
Add no-mocking/no-shortcuts requirements to Claude Code CLI commands.
Enforces production-ready code without any mocking, TODOs, stubs, or shortcuts.
"""

import os
import glob

def add_no_mocking_section(filepath):
    """Add no-mocking requirements to a command file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already has the requirement
    if "NO MOCKING" in content and "NO TODOs" in content:
        print(f"Skipping {filepath} - already has no-mocking requirements")
        return False
    
    # Find the enterprise code safety section
    lines = content.split('\n')
    insert_index = -1
    
    for i, line in enumerate(lines):
        if "**FORBIDDEN PRACTICES:**" in line:
            # Find the end of forbidden practices list
            for j in range(i + 1, len(lines)):
                if lines[j].strip() and not lines[j].startswith('-'):
                    insert_index = j
                    break
            break
    
    if insert_index == -1:
        print(f"Warning: Could not find insertion point in {filepath}")
        return False
    
    no_mocking_section = """
**ABSOLUTELY FORBIDDEN - NO EXCEPTIONS:**
- **NO MOCKING** of data or services in production code
- **NO TODOs** - complete ALL work immediately
- **NO SHORTCUTS** - implement properly ALWAYS
- **NO STUBS** - write complete implementations
- **NO FIXED DATA** - use real, dynamic data
- **NO HARDCODED VALUES** - use configuration
- **NO WORKAROUNDS** - fix root causes
- **NO FAKE IMPLEMENTATIONS** - real code only
- **NO PLACEHOLDER CODE** - production-ready only
- **NO TEMPORARY SOLUTIONS** - permanent fixes only

**YOU MUST ALWAYS:**
- IMPLEMENT production code to HIGHEST enterprise standards
- FIX issues properly at the root cause
- COMPLETE all functionality before moving on
- USE real data, real services, real implementations
- MAINTAIN professional quality in EVERY line of code"""
    
    # Insert the section
    lines.insert(insert_index, no_mocking_section)
    
    # Write the updated content
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Added no-mocking requirements to: {filepath}")
    return True

def main():
    """Add no-mocking requirements to all command files."""
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
    
    updated_count = 0
    
    for pattern in command_dirs:
        files = glob.glob(pattern)
        for filepath in files:
            if add_no_mocking_section(filepath):
                updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")

if __name__ == "__main__":
    main()