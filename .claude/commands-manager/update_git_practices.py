#!/usr/bin/env python3
"""
Update Git best practices with branch naming conventions.
Adds all standard branch types beyond just feature/fix.
"""

import os
import glob

def update_git_practices(filepath):
    """Update Git practices section with branch naming."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find and replace the Git best practices section
    old_git_section = """### 2. GIT BEST PRACTICES - MANDATORY

**YOU MUST ALWAYS:**
- Create feature/fix branches from development branch
- NEVER work directly on main/master branches
- Make atomic commits with descriptive messages
- Commit after EVERY logical change
- Push to remote frequently for backup

**COMMIT MESSAGE FORMAT:**
```
type(scope): description

- feat: New feature
- fix: Bug fix
- docs: Documentation only
- style: Code style changes
- refactor: Code refactoring
- test: Test additions/changes
- chore: Maintenance tasks
```"""

    new_git_section = """### 2. GIT BEST PRACTICES - MANDATORY

**YOU MUST ALWAYS:**
- Create properly named branches from development branch
- NEVER work directly on main/master/development branches
- Make atomic commits with descriptive messages
- Commit after EVERY logical change
- Push to remote frequently for backup
- Use conventional commit format: `type(scope): description`

**BRANCH NAMING CONVENTIONS:**
- `feature/<name>` - New features or enhancements
- `fix/<name>` or `bugfix/<name>` - Bug fixes
- `hotfix/<name>` - Urgent production fixes
- `refactor/<name>` - Code refactoring without functionality change
- `docs/<name>` - Documentation updates only
- `test/<name>` - Test additions or modifications
- `chore/<name>` - Maintenance tasks, dependency updates
- `perf/<name>` - Performance improvements
- `style/<name>` - Code style/formatting changes
- `ci/<name>` - CI/CD pipeline changes
- `build/<name>` - Build system changes
- `revert/<name>` - Reverting previous changes

**BRANCH EXAMPLES:**
- `feature/user-authentication`
- `fix/login-timeout-issue`
- `hotfix/critical-security-patch`
- `refactor/database-connection-pooling`
- `docs/api-documentation-update`
- `chore/update-dependencies`

**COMMIT TYPES:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code refactoring
- `docs:` Documentation only
- `test:` Test additions/changes
- `chore:` Maintenance tasks
- `perf:` Performance improvements
- `style:` Code style changes
- `ci:` CI/CD changes
- `build:` Build system changes
- `revert:` Revert previous commit"""

    if old_git_section in content:
        content = content.replace(old_git_section, new_git_section)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated Git practices in: {filepath}")
        return True
    
    return False

def main():
    """Update Git practices in all command files."""
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
            if update_git_practices(filepath):
                updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")

if __name__ == "__main__":
    main()