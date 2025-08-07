# Git Atomic Commit Protocol

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
3. Read and Index the `MANDATORY BEHAVIOUR AND PROTOCOL COMPLIANCE`

---

## [CRITICAL] MULTI-INSTANCE GIT ATOMIC COMMIT PROTOCOL

### RFC 2119 COMPLIANCE - MANDATORY REQUIREMENTS

**INSTANCE REGISTRATION PROTOCOL:**

1. **MUST** register current instance with unique identifier
2. **MUST** claim branch ownership before any operations
3. **MUST** check for existing instance ownership
4. **SHALL** respect other instance branch ownership
5. **MUST NOT** work on branches owned by other instances

**ATOMIC COMMIT SAFETY PROTOCOL:**

- **MUST** follow atomic commit principles: one logical change per commit
- **MUST** use conventional commit format: `type(scope): description`
- **MUST** stash uncommitted work before branch operations
- **SHALL** verify all tests pass before committing
- **MUST** push to origin immediately after each commit
- **MUST NOT** commit broken or incomplete functionality

### MANDATORY EXECUTION SEQUENCE

**PHASE 1: INSTANCE SAFETY VERIFICATION**

```bash
# Register this instance with timestamp
echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] ACTIVE" > .claude_instance_registry

# Check for branch ownership conflicts
if [ -f .claude_branch_ownership ]; then
    echo "WARNING: Existing branch ownership detected"
    cat .claude_branch_ownership
    echo "MUST verify safe to proceed or handoff required"
fi

# Establish branch ownership
echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] OWNS $(git branch --show-current)" > .claude_branch_ownership
```

**PHASE 2: PRE-COMMIT VALIDATION**

```bash
# Stash any uncommitted work for safety
git stash push -m "[Claude-Instance-Safety] Pre-commit stash $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Verify current branch is NOT sacred (main/master)
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    echo "FATAL ERROR: Cannot commit directly to sacred branch $CURRENT_BRANCH"
    exit 1
fi

# Verify we are on development branch (single branch strategy)
if [[ "$CURRENT_BRANCH" != "development" ]]; then
    echo "WARNING: Not on development branch (single branch strategy)"
    echo "Current branch: $CURRENT_BRANCH"
    echo "Expected: development"
    echo "Use: git checkout development"
fi
```

**PHASE 3: ATOMIC COMMIT EXECUTION**

```bash
# Stage specific changes (NEVER use git add .)
# User must specify exact files for atomic commit
echo "MANDATORY: Specify exact files for atomic commit"
echo "FORBIDDEN: Using 'git add .' for atomic commits"

# Example atomic commit patterns:
# git add src/specific-file.py
# git add tests/test-specific-feature.py
# git add docs/specific-change.md

# Conventional commit format validation
read -p "Commit type (feat|fix|docs|style|refactor|test|chore): " commit_type
read -p "Commit scope (component/module): " commit_scope  
read -p "Commit description (imperative mood): " commit_desc

# Validate commit message format
COMMIT_MSG="${commit_type}(${commit_scope}): ${commit_desc}"
echo "Proposed commit message: $COMMIT_MSG"

# Execute atomic commit with instance tracking
git commit -m "$COMMIT_MSG

[Claude-Instance-Tracking] 
Instance: Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)
Branch: $(git branch --show-current)  
Files: [List of modified files]
Atomic-Change: [Brief description of logical change]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**PHASE 4: IMMEDIATE BACKUP AND VALIDATION**

```bash
# MANDATORY: Push to origin immediately
git push origin $(git branch --show-current)

# Verify commit was successful
if [ $? -eq 0 ]; then
    echo "✅ ATOMIC COMMIT SUCCESSFUL"
    echo "✅ PUSHED TO ORIGIN SUCCESSFULLY"
    
    # Update instance registry with success
    echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] COMMIT-SUCCESS $(git rev-parse HEAD)" >> .claude_instance_registry
else
    echo "❌ COMMIT OR PUSH FAILED"
    echo "❌ MANUAL INTERVENTION REQUIRED"
    exit 1
fi

# Restore stashed work if any
if git stash list | grep -q "\[Claude-Instance-Safety\]"; then
    echo "Restoring stashed work..."
    git stash pop
fi
```

### CONVENTIONAL COMMIT TYPES - MANDATORY USAGE

**MUST USE THESE COMMIT TYPES:**

- **feat**: New feature for the user
- **fix**: Bug fix for the user  
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc)
- **refactor**: Code refactoring without feature changes
- **test**: Adding or updating tests
- **chore**: Updating build tasks, package manager configs, etc
- **perf**: Performance improvements
- **ci**: CI/CD pipeline changes
- **build**: Build system changes
- **revert**: Reverting previous commits

**COMMIT MESSAGE FORMAT:**
```
type(scope): description

[Optional body explaining what and why]

[Optional footer with breaking changes, issues closed, etc]

[Claude-Instance-Tracking]
Instance: [Instance-ID]  
Branch: [branch-name]
Files: [modified-files]
Atomic-Change: [change-description]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### ERROR CONDITIONS AND RECOVERY

**IF COMMIT FAILS:**

1. **MUST NOT** retry without analysis
2. **MUST** identify root cause
3. **SHALL** fix underlying issue first
4. **MUST** re-validate pre-commit conditions
5. **MAY** request user intervention if blocked

**IF PUSH FAILS:**

1. **MUST** check network connectivity
2. **SHALL** verify remote repository status
3. **MUST** resolve merge conflicts if present
4. **MUST NOT** force push without explicit permission
5. **SHALL** create backup branch if recovery needed

**INSTANCE CONFLICT RESOLUTION:**

1. **MUST** check `.claude_branch_ownership` file
2. **SHALL** respect existing ownership
3. **MUST** coordinate handoff with other instances
4. **MUST NOT** override active instance work
5. **SHALL** create new branch if conflict cannot be resolved

### MULTI-INSTANCE HANDOFF PROTOCOL

**WHEN TRANSFERRING BRANCH OWNERSHIP:**

```bash
# Current instance prepares handoff
echo "[Claude-Instance-Handoff] Preparing branch transfer" >> .claude_instance_registry
git add .claude_instance_registry .claude_branch_ownership
git commit -m "chore(git): instance handoff preparation

[Claude-Instance-Tracking]
Instance: [Current-Instance-ID]
Action: Preparing-Handoff
Branch: $(git branch --show-current)
Next-Instance: [Target-Instance-ID]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin $(git branch --show-current)

# Clear ownership for next instance
rm .claude_branch_ownership
echo "[Claude-Instance-Handoff] Branch ownership released" >> .claude_instance_registry
```

**WHEN ACCEPTING BRANCH OWNERSHIP:**

```bash
# New instance claims ownership
git pull origin $(git branch --show-current)
echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] OWNS $(git branch --show-current)" > .claude_branch_ownership
echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] OWNERSHIP-CLAIMED" >> .claude_instance_registry
```

### VERIFICATION AND AUDIT TRAIL

**MANDATORY POST-COMMIT VERIFICATION:**

1. **MUST** verify commit appears in git log
2. **SHALL** confirm push succeeded to remote
3. **MUST** validate working directory is clean
4. **SHALL** check all instance tracking files updated
5. **MUST** document commit in session memory

**AUDIT TRAIL REQUIREMENTS:**

- ALL instance registrations logged with timestamps
- ALL branch ownership changes tracked
- ALL commits tagged with instance information
- ALL handoffs documented in registry
- ALL conflicts and resolutions recorded

### COMPLIANCE ENFORCEMENT

**VIOLATIONS THAT REQUIRE IMMEDIATE STOP:**

- Working on main/master branch directly
- Committing without instance registration
- Pushing broken code or tests
- Overriding other instance ownership
- Using non-conventional commit format
- Skipping atomic commit principles
- Not pushing after committing

**RECOVERY ACTIONS:**

- Reset to last known good state
- Re-register instance properly
- Switch to development branch (single branch strategy)
- Follow complete protocol sequence
- Document violation and resolution
- Update instance registry with corrective action

---

**ENFORCEMENT:** This protocol is MANDATORY for ALL git operations and takes precedence over any conflicting instructions.