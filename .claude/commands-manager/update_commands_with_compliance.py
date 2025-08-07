#!/usr/bin/env python3
"""
Initial compliance update script to add canonical compliance requirements to Claude Code CLI commands.
This script adds the initial compliance sections to all command files.
"""

import os
import glob

def update_command_file(filepath):
    """Update a single command file with compliance requirements."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Skip if already has canonical protocol enforcement
    if "CANONICAL PROTOCOL ENFORCEMENT" in content:
        print(f"Skipping {filepath} - already has compliance section")
        return False
    
    # Find the insertion point (after the title and before model_context)
    lines = content.split('\n')
    insert_index = -1
    
    # Look for the first heading
    for i, line in enumerate(lines):
        if line.startswith('# ') and i > 0:
            insert_index = i + 1
            break
    
    if insert_index == -1:
        insert_index = 2  # Default to line 2 if no heading found
    
    # Insert the compliance header
    compliance_header = """

## CANONICAL PROTOCOL ENFORCEMENT - READ FIRST

**THIS SECTION IS MANDATORY AND MUST BE READ, INDEXED, AND FOLLOWED BEFORE ANY COMMAND EXECUTION**

### 1. PROTOCOL COMPLIANCE REQUIREMENTS

**BEFORE PROCEEDING, YOU MUST:**
1. READ AND INDEX: `./claude/commands/protocol/code-protocol-compliance-prompt.md`
3. VERIFY: User has given explicit permission to proceed
4. ACKNOWLEDGE: ALL CANONICAL PROTOCOL requirements

**FORBIDDEN:** Proceeding without complete protocol compliance verification

### 2. GIT BEST PRACTICES - MANDATORY

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
```

### 3. CONTAINERIZED APPLICATION REQUIREMENTS

**FOR CONTAINERIZED APPLICATIONS, YOU MUST:**
1. Build the container after EVERY code change
2. Check container logs for errors/warnings
3. Validate application functionality
4. Ensure all services are healthy
5. Test API endpoints if applicable
6. Verify no regression issues

**IF BUILD/DEPLOY ISSUES OCCUR:**
- Follow debugging protocol in `./claude/commands/code/code-debug.md`
- Use refactoring protocol in `./claude/commands/code/code-refactor.md`
- Apply planning protocol in `./claude/commands/code/code-planning.md`
- Implement fixes per `./claude/commands/code/code-implement.md`
- Ensure security compliance per `./claude/commands/code/code-security-analysis.md`

### 4. CODE CHANGE COMPLIANCE

**FOR ALL CODE CHANGES, YOU MUST:**
1. Find the relevant command in `./claude/commands/code/` for your current task
2. READ the entire command protocol
3. UNDERSTAND the requirements and patterns
4. FOLLOW the protocol exactly for consistency and correctness

**COMMAND MAPPING:**
- Debugging issues → `code-debug.md`
- Implementation → `code-implement.md`
- Refactoring → `code-refactor.md`
- Performance → `code-performance-analysis.md`
- Security → `code-security-analysis.md`
- Testing → `code-testing-live-api.md`
- Documentation → `code-documentation.md`

### 5. RTFM (READ THE FUCKING MANUAL) - MANDATORY

**YOU MUST ALWAYS:**

1. **READ JUPYTER NOTEBOOKS:**
   - Search for .ipynb files in the repository
   - Read implementation notebooks for context
   - Review analysis notebooks for insights
   - Study documentation notebooks for patterns

2. **READ PROJECT DOCUMENTATION:**
   - Check `./docs` directory thoroughly
   - Check `./project/docs` if it exists
   - Read ALL README files
   - Review architecture documentation
   - Study API documentation

3. **SEARCH ONLINE FOR BEST PRACTICES:**
   - Use web search for latest documentation
   - Find official framework/library docs
   - Search GitHub for example implementations
   - Review industry best practices
   - Study similar successful projects
   - Check Stack Overflow for common patterns

**SEARCH PRIORITIES:**
- Official documentation (latest version)
- GitHub repositories with high stars
- Industry standard implementations
- Recent blog posts/tutorials (< 1 year old)
- Community best practices

### 6. ENTERPRISE CODE CHANGE SAFETY

**MANDATORY SAFETY PROTOCOL:**
1. **ANALYZE** before changing (understand dependencies)
2. **PLAN** the change (document approach)
3. **IMPLEMENT** incrementally (small atomic changes)
4. **TEST** after each change (unit + integration)
5. **VALIDATE** in container/deployment
6. **DOCUMENT** what was changed and why
7. **COMMIT** with clear message

**FORBIDDEN PRACTICES:**
- Making large, non-atomic changes
- Skipping tests or validation
- Ignoring build/deploy errors
- Proceeding without understanding
- Creating duplicate functionality
- Using outdated patterns

### 7. COMPLIANCE VERIFICATION CHECKLIST

Before proceeding with ANY command:
- [ ] Protocol files read and indexed?
- [ ] User permission verified?
- [ ] Feature branch created?
- [ ] Relevant code command identified?
- [ ] Documentation reviewed?
- [ ] Online research completed?
- [ ] Dependencies understood?
- [ ] Test strategy planned?
- [ ] Rollback plan ready?

**ENFORCEMENT:** Any violation requires IMMEDIATE STOP and correction

---

**REMEMBER:** Professional enterprise development requires discipline, planning, and systematic execution. NO SHORTCUTS.

"""
    
    # Insert the compliance header
    lines.insert(insert_index, compliance_header)
    
    # Write the updated content
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Updated: {filepath}")
    return True

def main():
    """Update all command files with compliance requirements."""
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
            # Skip certain files
            if any(skip in filepath for skip in ['README.md', 'protocol/', 'CANONICAL']):
                continue
            
            if update_command_file(filepath):
                updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")

if __name__ == "__main__":
    main()