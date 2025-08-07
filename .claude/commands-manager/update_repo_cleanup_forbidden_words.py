#!/usr/bin/env python3
"""
Update repo cleanup commands to include additional forbidden words and vague naming instructions.
Adds 'simple', 'clean', 'enhanced', 'intelligent' to forbidden patterns.
Adds instruction to NEVER use vague non-descriptive words in naming.
"""

import os
import glob
import re

def update_forbidden_patterns(content):
    """Update the forbidden file patterns section with new words."""
    
    # Find the llm_artifacts section
    llm_pattern = r'(llm_artifacts:\s*\[\s*\n)((?:.*\n)*?)(\s*\])'
    
    match = re.search(llm_pattern, content, re.MULTILINE)
    if match:
        # Extract current patterns
        current_patterns = match.group(2)
        
        # Add new patterns if not already present
        new_patterns = [
            '      "*_simple.py", "simple_*.py", "*_simplified.py",',
            '      "*_clean.py", "*_cleaned.py", "clean_*.py",',  # Already exists, but ensure it's there
            '      "*_enhanced.py", "enhanced_*.py", "*_enhancement.py",',  # Already exists, but ensure it's there
            '      "*_intelligent.py", "intelligent_*.py", "*_smart.py",',
        ]
        
        # Check which patterns need to be added
        patterns_to_add = []
        for pattern in new_patterns:
            pattern_core = pattern.strip().strip(',').strip('"')
            # Check if any of the pattern variations exist
            if not any(p in current_patterns for p in pattern_core.split(', ')):
                patterns_to_add.append(pattern)
        
        if patterns_to_add:
            # Insert new patterns before the last pattern
            lines = current_patterns.rstrip().split('\n')
            if lines:
                # Insert before the last line
                for pattern in patterns_to_add:
                    lines.insert(-1, pattern)
                
                # Reconstruct the section
                new_content = match.group(1) + '\n'.join(lines) + '\n' + match.group(3)
                content = content[:match.start()] + new_content + content[match.end():]
                print("  Added forbidden patterns: simple, clean, enhanced, intelligent")
    
    return content

def add_vague_naming_instruction(content):
    """Add instruction about vague naming after the forbidden patterns section."""
    
    # Find a good insertion point - after the forbidden_file_patterns section
    insertion_marker = "core_modules: [\"src/**/*.py\", \"tests/**/*.py\", \"utils/**/*.py\"]"
    
    vague_naming_section = """
    
  # FORBIDDEN NAMING PATTERNS - MANDATORY ENFORCEMENT
  forbidden_naming_patterns:
    vague_descriptors: [
      "simple", "clean", "enhanced", "intelligent", "smart",
      "better", "improved", "new", "old", "latest",
      "updated", "modified", "changed", "fixed", "final"
    ]
    instruction: |
      FORBIDDEN: Add vague non-descriptive words to:
      - File names
      - Code blocks
      - Methods/Functions
      - Classes
      - Variables
      - Module names
      - Package names
      
      MANDATORY: Use specific, descriptive names that explain:
      - What the code does
      - Its specific purpose
      - Its actual functionality
      
      FORBIDDEN examples:
      - clean_data() → WRONG
      - process_user_authentication() → CORRECT
      - simple_api() → WRONG  
      - rest_api_client() → CORRECT
      - enhanced_function() → WRONG
      - validate_json_schema() → CORRECT"""
    
    if insertion_marker in content and "forbidden_naming_patterns:" not in content:
        content = content.replace(
            insertion_marker,
            insertion_marker + vague_naming_section
        )
        print("  Added vague naming instruction")
    
    return content

def update_cleanup_examples(content):
    """Update the cleanup examples to include the new forbidden words."""
    
    # Update the llm_artifacts examples section
    old_examples = 'examples: ["api_fixed.py", "client_clean.py", "main_final.py", "utils_updated.py"]'
    new_examples = 'examples: ["api_fixed.py", "client_clean.py", "main_final.py", "utils_updated.py", "simple_script.py", "enhanced_module.py", "intelligent_handler.py"]'
    
    if old_examples in content:
        content = content.replace(old_examples, new_examples)
        print("  Updated cleanup examples")
    
    return content

def update_file(filepath):
    """Update a single repo cleanup command file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"  ERROR reading {filepath}: {e}")
        return False
    
    original_content = content
    updated = False
    
    # Only update files that have forbidden_file_patterns
    if "forbidden_file_patterns:" in content:
        # Update forbidden patterns
        content = update_forbidden_patterns(content)
        
        # Add vague naming instruction
        content = add_vague_naming_instruction(content)
        
        # Update examples
        content = update_cleanup_examples(content)
        
        updated = content != original_content
    
    # Always add the vague naming rule to constraints if not present
    if "constraints:" in content and "FORBIDDEN: Using vague non-descriptive names" not in content:
        # Find the constraints section and add the new rule
        constraints_pattern = r'(constraints:\s*\n)((?:.*\n)*?)(\n(?:# |[a-z_]+:))'
        match = re.search(constraints_pattern, content, re.MULTILINE)
        
        if match:
            constraints = match.group(2)
            new_constraint = "  - FORBIDDEN: Using vague non-descriptive names (simple, clean, enhanced, intelligent, etc.)\n"
            
            # Add the new constraint
            new_constraints = constraints + new_constraint
            content = content[:match.start()] + match.group(1) + new_constraints + match.group(3) + content[match.end():]
            updated = True
            print("  Added vague naming constraint")
    
    if updated:
        try:
            # Replace checkmark symbols to avoid encoding issues
            content = content.replace('✓', '[OK]').replace('✗', '[ERROR]')
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  [OK] Updated: {os.path.basename(filepath)}")
            return True
        except Exception as e:
            print(f"  ERROR writing {filepath}: {e}")
            return False
    else:
        print(f"  - Skipped: {os.path.basename(filepath)} (no updates needed)")
        return False

def main():
    """Update all repo cleanup commands with forbidden words and vague naming instructions."""
    print("Updating repo cleanup commands with forbidden words and vague naming instructions")
    print("=" * 70)
    
    # Find all repo cleanup command files
    repo_cleanup_files = glob.glob('../commands/repo/repo-cleanup-*.md')
    
    if not repo_cleanup_files:
        print("ERROR: No repo cleanup files found in .claude/commands/repo/")
        return
    
    print(f"Found {len(repo_cleanup_files)} repo cleanup command files")
    
    updated_count = 0
    for filepath in repo_cleanup_files:
        print(f"\nProcessing: {os.path.basename(filepath)}")
        if update_file(filepath):
            updated_count += 1
    
    print("\n" + "=" * 70)
    print(f"Updated {updated_count} files")
    
    if updated_count > 0:
        print("\n[OK] Successfully added forbidden words: simple, clean, enhanced, intelligent")
        print("[OK] Added instruction to avoid vague non-descriptive naming")
        print("\nThe repo cleanup commands will now:")
        print("1. Remove files with these forbidden words in their names")
        print("2. Enforce descriptive naming for all code elements")
        print("3. Prevent creation of vaguely named files and code")

if __name__ == "__main__":
    main()