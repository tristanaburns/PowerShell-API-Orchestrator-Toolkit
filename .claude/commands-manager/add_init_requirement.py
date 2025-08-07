#!/usr/bin/env python3
"""
Add /init requirement to Claude Code CLI commands.
Enforces running /init after cleanup to reinitialize CLAUDE.md.
"""

import os
import glob

def add_init_section(filepath):
    """Add /init requirement to a command file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already has init section
    if "POST-COMPLETION REINITIALIZATION" in content:
        print(f"Skipping {filepath} - already has init section")
        return False
    
    # Find insertion point (after hygiene section)
    lines = content.split('\n')
    insert_index = -1
    
    # Look for the end of hygiene section
    for i, line in enumerate(lines):
        if "**MANDATORY CLEANUP SEQUENCE:**" in line:
            # Find the end of the cleanup sequence
            for j in range(i + 1, len(lines)):
                if lines[j].strip() == "```":
                    # Find the next line after the code block
                    for k in range(j + 1, len(lines)):
                        if lines[k].strip() == "":
                            continue
                        else:
                            insert_index = k
                            break
                    break
            break
    
    if insert_index == -1:
        print(f"Warning: Could not find insertion point in {filepath}")
        return False
    
    init_section = """
### 11. POST-COMPLETION REINITIALIZATION

**AFTER CLEANUP AND HYGIENE CHECK, YOU MUST:**

```
/init                      # Reinitialize CLAUDE.md for next session
```

**THIS COMMAND:**
- Updates CLAUDE.md with latest context
- Clears temporary state
- Prepares for next command/instruction
- Ensures clean slate for next task

**MANDATORY EXECUTION:**
- AFTER repo cleanup commands
- AFTER final hygiene check
- BEFORE starting new task
- WHEN switching contexts
- AT session boundaries

"""
    
    # Insert the section
    lines.insert(insert_index, init_section)
    
    # Write the updated content
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Added /init requirement to: {filepath}")
    return True

def main():
    """Add /init requirement to all command files."""
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
            if add_init_section(filepath):
                updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")

if __name__ == "__main__":
    main()