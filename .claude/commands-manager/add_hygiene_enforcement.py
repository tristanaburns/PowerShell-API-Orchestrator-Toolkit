#!/usr/bin/env python3
"""
Add codebase hygiene enforcement to Claude Code CLI commands.
Enforces strict codebase cleanliness using repo cleanup commands.
"""

import os
import glob

def add_hygiene_section(filepath):
    """Add codebase hygiene enforcement to a command file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already has hygiene section
    if "MANDATORY CODEBASE HYGIENE ENFORCEMENT" in content:
        print(f"Skipping {filepath} - already has hygiene section")
        return False
    
    # Find insertion point (before the final reminder)
    lines = content.split('\n')
    insert_index = -1
    
    # Look for the REMEMBER line near the end
    for i in range(len(lines) - 1, 0, -1):
        if "**REMEMBER:**" in lines[i] and "Professional enterprise development" in lines[i]:
            insert_index = i
            break
    
    if insert_index == -1:
        # If not found, insert before the model_context section
        for i, line in enumerate(lines):
            if line.strip() == "model_context:":
                insert_index = i - 1
                break
    
    if insert_index == -1:
        print(f"Warning: Could not find insertion point in {filepath}")
        return False
    
    hygiene_section = """### 10. MANDATORY CODEBASE HYGIENE ENFORCEMENT

**GOOD CODEBASE HYGIENE IS STRICTLY ENFORCED - NO EXCEPTIONS**

**AFTER EVERY CODE CHANGE, YOU MUST:**

1. **RUN REPO CLEANUP COMMANDS** from `.claude/commands/repo/`:
   ```
   /repo-cleanup-code-files        # Remove test scripts, demos, duplicates
   /repo-cleanup-documentation     # Clean doc sprawl, convert to notebooks
   /repo-cleanup-unicode-emoji     # Remove ALL Unicode/emoji
   /repo-cleanup-config-scripts    # Convert forbidden scripts
   ```

2. **ENFORCE HYGIENE ON YOUR OWN WORK:**
   - Check for files YOU created with "fix", "clean", "final" in names
   - Verify NO temporary files remain
   - Ensure NO duplicate code exists
   - Confirm NO TODOs or stubs left
   - Validate NO hardcoded values

3. **CODEBASE HYGIENE CHECKLIST:**
   - [ ] NO test_*.py files in root
   - [ ] NO demo or example files
   - [ ] NO duplicate implementations
   - [ ] NO Unicode or emoji anywhere
   - [ ] NO shell/batch/PowerShell scripts
   - [ ] NO point-in-time reports
   - [ ] NO multiple README files per directory
   - [ ] NO backup or temporary files

**MANDATORY CLEANUP SEQUENCE:**
```bash
# After final atomic commit:
/repo-cleanup-code-files        # Clean code artifacts
/repo-cleanup-documentation     # Clean doc artifacts
/repo-cleanup-unicode-emoji     # Clean Unicode
/repo-cleanup-master           # Run master cleanup
```

"""
    
    # Insert the section
    lines.insert(insert_index, hygiene_section)
    
    # Write the updated content
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Added hygiene enforcement to: {filepath}")
    return True

def main():
    """Add hygiene enforcement to all command files."""
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
            if add_hygiene_section(filepath):
                updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")

if __name__ == "__main__":
    main()