# Single Branch Development Strategy Protocol

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:

1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**

---

## CANONICAL PROTOCOL ADHERENCE

### Required Protocol Reading

1. Read and Index the `CANONICAL-COMPLIANCE-HEADER.md`
2. Read and Index the `code-protocol-compliance-prompt.md`
3. Read and Index the `code-protocol-single-branch-strategy.md`
4. Read and Index the `MANDATORY BEHAVIOUR AND PROTOCOL COMPLIANCE`

---

## [CRITICAL] SIMPLIFIED SINGLE-BRANCH DEVELOPMENT STRATEGY

### RFC 2119 COMPLIANCE - DEVELOPMENT-FIRST APPROACH

**PRIMARY RULE - DEVELOPMENT BRANCH ONLY:**

- **development** - THE ONLY ACTIVE WORKING BRANCH
- **MUST:** Work directly on development branch for ALL coding activities
- **MUST NOT:** Create automatic feature branches for simple changes
- **SHALL:** Use backup branches ONLY for significant checkpoints

**SACRED BRANCHES - ABSOLUTELY FORBIDDEN FOR DIRECT WORK:**

- **main** - Production release branch - NEVER TOUCH
- **master** - Legacy production branch - NEVER TOUCH  
- **production** - Production deployment branch - NEVER TOUCH

**VIOLATION RESPONSE:**
```bash
# If accidentally on sacred branch, immediately switch to development
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" || "$CURRENT_BRANCH" == "production" ]]; then
    echo "ERROR: On sacred branch $CURRENT_BRANCH - switching to development"
    git checkout development
fi
```

### MANDATORY WORKING PROTOCOL

**PHASE 1: ENSURE DEVELOPMENT BRANCH IS ACTIVE**

```bash
# Always ensure on development branch
git checkout development

# Pull latest changes if working with remote
git pull origin development 2>/dev/null || echo "No remote configured"

# Verify we're on development
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "development" ]]; then
    echo "CRITICAL: Not on development branch. Current: $CURRENT_BRANCH"
    exit 1
fi
```

**PHASE 2: TRACK ALL FILES AND COMMIT ATOMICALLY**

```bash
# Track all new and modified files
git add .

# Verify what will be committed
git status

# Create atomic commit with descriptive message
git commit -m "type(scope): clear description of changes

- Specific change 1 implemented
- Specific change 2 fixed
- Specific change 3 enhanced

[AI-Type-Model-$(date -u +%Y-%m-%dT%H:%M:%SZ)]"

# Push to remote immediately for backup
git push origin development
```

### ATOMIC COMMIT MESSAGE FORMAT - MANDATORY

**COMMIT MESSAGE STRUCTURE:**
```
type(scope): clear one-line description

- Bullet point describing specific change
- Another bullet point for additional change
- Third bullet point if needed

[AI-Instance-ID-Timestamp]
```

**COMMIT TYPES:**
- **feat**: New feature implementation
- **fix**: Bug fix or correction
- **refactor**: Code improvement without changing functionality
- **docs**: Documentation updates
- **chore**: Maintenance tasks, dependency updates
- **security**: Security improvements or fixes

**EXAMPLES:**
```
feat(cli): implement user authentication validation

- Added password strength validation
- Implemented session timeout handling
- Enhanced error messaging for failed login

[Claude-Opus-4-2025-08-03T15:24:00Z]
```

```
fix(api): resolve connection timeout issues

- Increased default timeout from 30s to 60s
- Added retry logic for failed connections
- Fixed memory leak in connection pooling

[Claude-Opus-4-2025-08-03T15:24:00Z]
```

### BACKUP BRANCH CREATION - MANUAL ONLY

**WHEN TO CREATE BACKUP BRANCHES:**
- Before major refactoring operations
- Before risky architectural changes
- Before updating critical dependencies
- At significant development milestones

**BACKUP CREATION PROTOCOL:**
```bash
# Create backup branch with descriptive name
BACKUP_NAME="backup/$(date +%Y-%m-%d)-before-major-refactor"
git checkout -b "$BACKUP_NAME"

# Push backup to remote
git push origin "$BACKUP_NAME"

# Return to development branch immediately
git checkout development

echo "✅ BACKUP CREATED: $BACKUP_NAME"
echo "✅ RETURNED TO DEVELOPMENT BRANCH"
```

**BACKUP NAMING CONVENTIONS:**
```
backup/YYYY-MM-DD-description
backup/2025-08-03-before-framework-update
backup/2025-08-03-before-security-refactor
backup/2025-08-03-milestone-v1-complete
```

### MULTI-INSTANCE COORDINATION

**SIMPLE INSTANCE SAFETY:**
```bash
# Before starting work, check for uncommitted changes from other instances
git status
if ! git diff-index --quiet HEAD --; then
    echo "WARNING: Uncommitted changes detected"
    echo "Review changes before proceeding:"
    git diff --name-only
fi

# Pull latest changes from other instances
git pull origin development
```

**HANDOFF PROTOCOL:**
```bash
# Before ending session, ensure all work is committed and pushed
git add .
git commit -m "chore(session): end of development session

- All current work committed
- Ready for next instance handoff

[AI-Type-Model-$(date -u +%Y-%m-%dT%H:%M:%SZ)]"

git push origin development
echo "✅ SESSION COMPLETE - WORK SAFELY COMMITTED"
```

### DAILY WORKFLOW CHECKLIST

**BEFORE STARTING WORK:**
- [ ] Verify on development branch: `git branch --show-current`
- [ ] Pull latest changes: `git pull origin development`
- [ ] Check working directory status: `git status`

**DURING DEVELOPMENT:**
- [ ] Track all files: `git add .`
- [ ] Create atomic commits with clear messages
- [ ] Push after each logical change: `git push origin development`

**BEFORE ENDING SESSION:**
- [ ] Commit all current work
- [ ] Push final state to remote
- [ ] Verify clean working directory: `git status`

### RECOVERY PROTOCOL

**IF DEVELOPMENT BRANCH BECOMES CORRUPTED:**

```bash
# Option 1: Reset to last good commit
git log --oneline -10  # Find last good commit
git reset --hard <commit-hash>

# Option 2: Restore from backup branch
git checkout backup/YYYY-MM-DD-description
git checkout -b development-recovery
git checkout development
git reset --hard development-recovery
git branch -D development-recovery

# Option 3: Use git reflog to find lost commits
git reflog
git checkout <commit-hash>
git checkout -b development-temp
git checkout development
git reset --hard development-temp
git branch -D development-temp
```

### FORBIDDEN ACTIONS

**NEVER DO:**
- Create automatic feature branches for simple changes
- Work on main/master/production branches
- Leave uncommitted changes without proper commits
- Force push without explicit permission
- Delete development branch
- Create complex branch hierarchies

**ALWAYS DO:**
- Work on development branch only
- Commit frequently with clear messages
- Track all files before committing
- Push after each commit for backup
- Use backup branches for major checkpoints only

### COMPLIANCE VERIFICATION

**MANDATORY CHECKS BEFORE ANY GIT OPERATION:**
- Current branch is development
- All files are tracked (git add .)
- Commit messages follow format requirements
- Working directory is clean after commits
- Remote backup is up to date

**AUDIT TRAIL:**
- All commits tagged with instance identifier
- All actions logged with timestamps
- All backup branches documented with purpose
- All recovery actions recorded

---

## WHY THIS STRATEGY WORKS FOR MULTI-AI DEVELOPMENT

### The Problem It Solves
When multiple AI instances (Claude, GPT, Gemini, Ollama) work on the same codebase:
- Each AI might create different branch names for the same task
- Branch switching causes confusion and mixed purposes
- Complex branching strategies lead to conflicts

### The Solution
- **One branch** = No confusion possible
- **Clear commits** = Full traceability without branches
- **Instance tagging** = Know who did what
- **Atomic commits** = Easy to revert specific changes
- **Frequent pushes** = Automatic backup and coordination

### Perfect for AI Collaboration
- AIs follow protocols precisely
- No human ego or preferences
- Consistent execution every time
- Simple enough for any AI to understand
- Powerful enough for complex development

---

**ENFORCEMENT:** This simplified branch strategy eliminates complex multi-instance protocols while maintaining code safety through frequent atomic commits and manual backup branching only when needed.