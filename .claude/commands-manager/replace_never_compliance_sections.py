#!/usr/bin/env python3
"""
Replace specific NEVER instances with FORBIDDEN in compliance sections of all command files.
This focuses on command/instruction contexts where FORBIDDEN is more appropriate.
"""

import os
import glob
import re

def replace_never_in_compliance(filepath):
    """Replace specific NEVER instances with FORBIDDEN in compliance sections."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"  ERROR reading {filepath}: {e}")
        return False
    
    original_content = content
    
    # Define specific replacements for compliance/command contexts
    replacements = [
        # Git practices
        ("- NEVER work directly on main/master/development branches", 
         "- FORBIDDEN: Work directly on main/master/development branches"),
        ("- NEVER work directly on main/master branches",
         "- FORBIDDEN: Work directly on main/master branches"),
         
        # YOU MUST NEVER patterns
        ("**YOU MUST NEVER:**", "**FORBIDDEN ACTIONS:**"),
        
        # Specific NEVER commands in lists
        (r"^(\s*)-\s+NEVER\s+", r"\1- FORBIDDEN: ", re.MULTILINE),
        
        # NEVER at start of line in bullet points
        (r"^(\s*)\*\s+NEVER\s+", r"\1* FORBIDDEN: ", re.MULTILINE),
        
        # Double asterisk NEVER patterns
        (r"\*\*NEVER\*\*\s+", "**FORBIDDEN:** "),
        
        # FORBIDDEN: Proceeding patterns (keep as is, already correct)
        # Skip: "**FORBIDDEN:** Proceeding without"
    ]
    
    # Apply replacements
    for old, new, *flags in replacements:
        if flags and flags[0] == re.MULTILINE:
            content = re.sub(old, new, content, flags=re.MULTILINE)
        else:
            content = content.replace(old, new)
    
    # Special handling for vague naming instructions
    content = content.replace(
        "NEVER add vague non-descriptive words to:",
        "FORBIDDEN: Add vague non-descriptive words to:"
    )
    
    # Check if in compliance sections and context makes sense
    # We'll keep some NEVER instances where they're part of natural language
    # e.g., "You should never" in explanatory text vs. command bullets
    
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
    """Update all command files with NEVER to FORBIDDEN replacements."""
    print("Replacing NEVER with FORBIDDEN in command compliance sections")
    print("=" * 70)
    
    # Find all command files
    command_patterns = [
        '../commands/code/*.md',
        '../commands/repo/*.md',
        '../commands/actions/*.md',
        '../commands/testing/*.md',
        '../commands/docs/*.md',
        '../commands/composite/*.md',
        '../commands/frontend/*.md',
        '../commands/backend/*.md',
        '../commands/architecture/*.md',
        '../commands/planning/*.md',
        '../commands/implementation/*.md'
    ]
    
    all_files = []
    for pattern in command_patterns:
        all_files.extend(glob.glob(pattern))
    
    # Skip certain files
    skip_files = ['README.md', 'CANONICAL-COMPLIANCE-HEADER.md']
    command_files = [f for f in all_files if not any(skip in f for skip in skip_files)]
    
    print(f"Found {len(command_files)} command files to check")
    
    updated_count = 0
    for filepath in sorted(command_files):
        print(f"\nChecking: {os.path.basename(os.path.dirname(filepath))}/{os.path.basename(filepath)}")
        if replace_never_in_compliance(filepath):
            updated_count += 1
    
    print("\n" + "=" * 70)
    print(f"Updated {updated_count} files")
    
    if updated_count > 0:
        print("\n[OK] Successfully replaced NEVER with FORBIDDEN in compliance sections")
        print("\nChanges made:")
        print("- Git practices: 'NEVER work directly' -> 'FORBIDDEN: Work directly'")
        print("- Command bullets: '- NEVER' -> '- FORBIDDEN:'")
        print("- Instruction headers: '**YOU MUST NEVER:**' -> '**FORBIDDEN ACTIONS:**'")

if __name__ == "__main__":
    main()