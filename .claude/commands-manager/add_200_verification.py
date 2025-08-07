#!/usr/bin/env python3
"""
Add 200% verification methodology to Claude Code CLI commands.
Enforces two independent verification activities (check + double-check).
"""

import os
import glob

def add_verification_methodology(filepath):
    """Add 200% verification methodology to a command file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already has 200% verification
    if "200% VERIFICATION METHODOLOGY" in content:
        print(f"Skipping {filepath} - already has 200% verification")
        return False
    
    # Find the DevSecOps enforcement rules section
    lines = content.split('\n')
    insert_index = -1
    
    for i, line in enumerate(lines):
        if "**ENFORCEMENT RULES:**" in line and "NO skipping phases" in lines[i+1]:
            # Find the end of enforcement rules
            for j in range(i + 1, len(lines)):
                if lines[j].strip() and not lines[j].startswith('-'):
                    insert_index = j
                    break
            break
    
    if insert_index == -1:
        print(f"Warning: Could not find insertion point in {filepath}")
        return False
    
    verification_section = """
**200% VERIFICATION METHODOLOGY:**

**FIRST 100% - PRIMARY VERIFICATION:**
1. Execute all tests in the phase
2. Validate all outputs
3. Check all logs
4. Confirm functionality
5. Document results

**SECOND 100% - INDEPENDENT DOUBLE-CHECK:**
1. Different verification approach
2. Cross-validate results
3. Manual spot checks
4. Edge case testing
5. Third-party validation

**VERIFICATION RULES:**
- TWO independent verification activities
- DIFFERENT methodologies for each
- NO shared assumptions
- SEPARATE validation paths
- BOTH must pass 100%
"""
    
    # Insert the section
    lines.insert(insert_index, verification_section)
    
    # Write the updated content
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Added 200% verification to: {filepath}")
    return True

def main():
    """Add 200% verification to all command files."""
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
            if add_verification_methodology(filepath):
                updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")

if __name__ == "__main__":
    main()