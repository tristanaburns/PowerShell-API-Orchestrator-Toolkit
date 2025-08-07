#!/usr/bin/env python3
"""
Verify that all updates have been applied to command files.
"""

import os
import glob

def check_file_for_requirements(filepath):
    """Check if a file has all required compliance sections."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return None
    
    requirements = {
        "Protocol Compliance": "CANONICAL PROTOCOL ENFORCEMENT" in content,
        "Git Best Practices": "GIT BEST PRACTICES - MANDATORY" in content,
        "Container Requirements": "CONTAINERIZED APPLICATION REQUIREMENTS" in content,
        "Code Compliance": "CODE CHANGE COMPLIANCE" in content,
        "RTFM": "RTFM (READ THE FUCKING MANUAL)" in content,
        "DevSecOps Loop": "MANDATORY DEVSECOPS LOOP" in content,
        "Enterprise Safety": "ENTERPRISE CODE CHANGE SAFETY" in content,
        "MCP Tools": "MANDATORY MCP SERVER TOOL USAGE" in content,
        "Compliance Checklist": "COMPLIANCE VERIFICATION CHECKLIST" in content,
        "Codebase Hygiene": "MANDATORY CODEBASE HYGIENE ENFORCEMENT" in content,
        "Post-Init": "POST-COMPLETION REINITIALIZATION" in content,
        "No Mocking": "NO MOCKING" in content and "NO TODOs" in content,
        "200% Verification": "200% VERIFICATION METHODOLOGY" in content,
        "FORBIDDEN Git": "FORBIDDEN: Work directly" in content,
    }
    
    return requirements

def check_repo_cleanup_files():
    """Check repo cleanup files for specific requirements."""
    repo_files = glob.glob('../commands/repo/repo-cleanup-*.md')
    
    print("\nRepo Cleanup Files Check:")
    print("-" * 50)
    
    for filepath in repo_files:
        if 'README' in filepath:
            continue
            
        filename = os.path.basename(filepath)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            checks = {
                "Forbidden words (simple, etc.)": any(word in content for word in ['"simple"', '"clean"', '"enhanced"', '"intelligent"']),
                "Vague naming instruction": "FORBIDDEN: Add vague non-descriptive words" in content,
                "Vague naming constraint": "FORBIDDEN: Using vague non-descriptive names" in content,
            }
            
            print(f"\n{filename}:")
            for check, result in checks.items():
                status = "[OK]" if result else "[MISSING]"
                print(f"  {status} {check}")
                
        except Exception as e:
            print(f"\n{filename}: ERROR - {e}")

def main():
    """Check all command files for updates."""
    print("Verifying all Claude Code CLI command updates")
    print("=" * 70)
    
    # Check main command files
    command_patterns = [
        '../commands/code/*.md',
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
    skip_files = ['README.md', 'CANONICAL', 'MANDATORY-PROTOCOL']
    command_files = [f for f in all_files if not any(skip in f for skip in skip_files)]
    
    print(f"Checking {len(command_files)} command files for compliance requirements...")
    
    missing_sections = {}
    fully_compliant = 0
    
    for filepath in sorted(command_files):
        requirements = check_file_for_requirements(filepath)
        if requirements is None:
            continue
            
        missing = [req for req, present in requirements.items() if not present]
        
        if not missing:
            fully_compliant += 1
        else:
            filename = os.path.basename(filepath)
            dirname = os.path.basename(os.path.dirname(filepath))
            missing_sections[f"{dirname}/{filename}"] = missing
    
    # Report results
    print(f"\nCompliance Summary:")
    print(f"  Fully compliant files: {fully_compliant}/{len(command_files)}")
    
    if missing_sections:
        print(f"\nFiles missing sections:")
        for file, missing in missing_sections.items():
            print(f"\n  {file}:")
            for section in missing:
                print(f"    - {section}")
    
    # Check repo cleanup files
    check_repo_cleanup_files()
    
    # Final summary
    print("\n" + "=" * 70)
    if fully_compliant == len(command_files) and not missing_sections:
        print("[OK] All command files are fully updated!")
    else:
        print(f"[INCOMPLETE] {len(missing_sections)} files need updates")

if __name__ == "__main__":
    main()