# Universal Git Emergency Recovery & Management Protocols

This directory contains **UNIVERSAL** git protocols for emergency data recovery, multi-instance safety, and systematic git management. These protocols work across **ANY PROJECT TYPE** (Python, Node.js, Java, Go, Rust, etc.) and are designed to prevent data loss and provide systematic recovery from any git-related corruption or issues.

## 🌐 UNIVERSAL APPLICABILITY

These protocols are **PROJECT-AGNOSTIC** and work with:
- **Python projects** (Django, Flask, FastAPI, etc.)  
- **Node.js projects** (React, Vue, Express, Next.js, etc.)
- **Java projects** (Spring, Maven, Gradle, etc.)
- **Go projects** (any Go modules)
- **Rust projects** (Cargo-based)
- **ANY other project type** with git version control

## 📊 LOGGING & TRACEABILITY

All recovery protocols include:
- **Tamper-proof audit logs** with cryptographic hashes
- **Full traceability** of every action and decision  
- **Timestamped entries** with git state snapshots
- **Multi-instance coordination** tracking
- **Forensic-grade documentation** for analysis

## 🚨 EMERGENCY RECOVERY PROTOCOLS

### When You Have Data Corruption or Loss

**IMMEDIATE ACTION REQUIRED:**

1. **STOP ALL WORK** - Do not make any changes until analysis is complete
2. **DO NOT CREATE NEW CODE** - Only recover existing working code  
3. **CREATE EMERGENCY BRANCH** - Isolate recovery work from main codebase
4. **MAINTAIN BRANCH CONSISTENCY** - Never switch branches during recovery
5. **USE MASTER RECOVERY PROTOCOL** - Execute recovery workflow
6. **PRIORITIZE DEPENDENCY COMPATIBILITY** - Best file ≠ latest file

```bash
# EMERGENCY: Use this command for any data corruption situation
/git:git-master-emergency-recovery
```

### Universal Protocol Overview

| Protocol | Purpose | When to Use | Key Features |
|----------|---------|-------------|--------------|
| **git-master-emergency-recovery.md** | Complete emergency recovery coordination | ANY data corruption or loss situation | Emergency branching, dependency analysis, full logging |
| **git-emergency-data-recovery.md** | Surgical file recovery from git history | When specific files need recovery | Dependency-based recovery, rollback points |
| **git-forensics-investigation.md** | Systematic investigation of corruption causes | To understand what went wrong | Timeline reconstruction, author analysis |
| **git-exhaustive-file-analysis.md** | Deep analysis of file versions across history | To compare file versions thoroughly | Function-level analysis, cross-language support |
| **git-comprehensive-history-recovery.md** | Complete local and remote history mining | To access ALL available git data sources | Orphaned commits, remote mining, fork analysis |

---

## 🔍 EMERGENCY RECOVERY WORKFLOW

### Phase 1: Emergency Response
```bash
# Step 1: Immediate emergency protocol activation
/git:git-master-emergency-recovery

# This will:
# - Establish instance safety
# - Document current crisis state
# - Create recovery workspace
# - Initialize forensics investigation
```

### Phase 2: Analysis
The master protocol automatically executes:
- **Forensics Investigation**: Traces exact changes that caused corruption
- **History Mining**: Searches ALL local and remote git sources
- **File Analysis**: Exhaustive content analysis of all file versions
- **Source Scoring**: Ranks all recovery candidates by quality

### Phase 3: Manual Recovery Execution
Based on analysis results, manually execute surgical recovery:
```bash
# Example recovery commands (from analysis results)
recover_file_from_commit "api-gateway-service/app/main.py" "abc123def" "Restore working API"
validate_recovery_step "API gateway restoration"
create_recovery_rollback_point "api-restored"
```

### Phase 4: Validation and Documentation
```bash
# After manual recovery
validation_log=$(execute_system_validation "$recovery_session_id" "$master_log")
complete_recovery_documentation "$recovery_session_id" "$master_log"
```

---

## 🛡️ MULTI-INSTANCE SAFETY PROTOCOLS

### When Multiple Claude Instances Are Working

**MANDATORY SAFETY PROTOCOLS:**

| Protocol | Purpose | When to Use |
|----------|---------|-------------|
| **git-atomic-commit.md** | Safe atomic commits with instance tracking | Every commit operation |
| **git-branch-strategy.md** | Multi-instance branch management | All branch operations |

### Multi-Instance Safety Workflow

1. **Instance Registration** - Every instance must register before work
2. **Branch Ownership** - Claim branch ownership before any operations  
3. **Atomic Commits** - One logical change per commit with tracking
4. **Immediate Backup** - Push after every commit
5. **Safe Handoffs** - Proper coordination when transferring work

```bash
# Before any git operations
echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] ACTIVE" > .claude_instance_registry
echo "[Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)] OWNS $(git branch --show-current)" > .claude_branch_ownership
```

---

## 📋 PROTOCOL SELECTION GUIDE

### Choose the Right Protocol

#### **🚨 EMERGENCY SITUATIONS**
- **System broken/corrupted** → `git-master-emergency-recovery.md`
- **API endpoints failing** → `git-master-emergency-recovery.md`
- **Missing critical files** → `git-master-emergency-recovery.md`
- **Container build failures** → `git-master-emergency-recovery.md`

#### **🔍 ANALYSIS SITUATIONS**
- **Need to understand what changed** → `git-forensics-investigation.md`
- **Compare file versions thoroughly** → `git-exhaustive-file-analysis.md`
- **Find all possible recovery sources** → `git-comprehensive-history-recovery.md`

#### **🔧 SURGICAL RECOVERY**
- **Recover specific files only** → `git-emergency-data-recovery.md`
- **Known good commit identified** → `git-emergency-data-recovery.md`

#### **👥 MULTI-INSTANCE WORK**
- **Multiple Claude instances active** → `git-atomic-commit.md` + `git-branch-strategy.md`
- **Need to commit safely** → `git-atomic-commit.md`
- **Need to create/switch branches** → `git-branch-strategy.md`

---

## 🎯 CRITICAL SUCCESS FACTORS

### ✅ ALWAYS DO
- **Stop and analyze first** - Never rush into changes
- **Use exhaustive analysis** - Understand ALL options before recovery
- **Create rollback points** - Safety at every step
- **Document everything** - Complete audit trail
- **Validate each step** - Ensure functionality before proceeding
- **Follow multi-instance safety** - Prevent conflicts

### ❌ NEVER DO
- **Create new code during recovery** - Only recover existing working code
- **Skip analysis phases** - Always understand before acting
- **Work on main/master directly** - Use proper branch strategy
- **Force push without coordination** - Respect multi-instance safety
- **Delete anything permanently** - Always preserve for analysis

---

## 🔧 TECHNICAL IMPLEMENTATION

### Function Library Usage

Each protocol provides reusable functions:

```bash
# Emergency Recovery Functions
initialize_master_emergency_recovery()
execute_coordinated_forensics()
execute_comprehensive_history_mining()
execute_exhaustive_file_analysis()
consolidate_recovery_sources()
execute_surgical_recovery()

# Forensics Functions  
establish_forensics_baseline()
reconstruct_change_timeline()
analyze_author_patterns()
binary_search_corruption()
commit_content_forensics()

# History Mining Functions
mine_complete_local_git_history()
recover_orphaned_commits()
perform_reflog_archaeology()
analyze_all_remote_repositories()
mine_all_remote_branches()
score_all_recovery_sources()

# File Analysis Functions
exhaustive_file_analysis()
comparative_content_analysis()
exhaustive_directory_analysis()
python_function_analysis()
config_file_deep_analysis()

# Recovery Functions
recover_file_from_commit()
recover_directory_from_commit()
validate_recovery_step()
create_recovery_rollback_point()
```

### Integration with Claude Code Commands

```bash
# Emergency protocols
/git:git-master-emergency-recovery
/git:git-emergency-data-recovery
/git:git-forensics-investigation

# Analysis protocols
/git:git-exhaustive-file-analysis
/git:git-comprehensive-history-recovery

# Safety protocols  
/git:git-atomic-commit
/git:git-branch-strategy
```

---

## 📚 PROTOCOL DEPENDENCIES

### Execution Order Dependencies

1. **git-master-emergency-recovery.md** (orchestrates all others)
   - Calls → **git-forensics-investigation.md**
   - Calls → **git-comprehensive-history-recovery.md**
   - Calls → **git-exhaustive-file-analysis.md**
   - Calls → **git-emergency-data-recovery.md**

2. **git-emergency-data-recovery.md**
   - Uses results from forensics and analysis protocols
   - Implements surgical recovery based on findings

3. **git-atomic-commit.md** + **git-branch-strategy.md**
   - Independent protocols for ongoing safety
   - Used in parallel with recovery protocols

### Data Flow

```
Crisis Detected → Master Recovery → Forensics Investigation
                                  ↓
User Problem ← Manual Recovery ← Analysis
                                  ↓
Validation ← Surgical Recovery ← Recovery Planning
```

---

## 🔐 SECURITY AND SAFETY

### Multi-Instance Coordination
- Instance registration prevents conflicts
- Branch ownership prevents work loss
- Atomic commits ensure data integrity
- Immediate backup prevents data loss

### Data Protection
- Emergency backups before any recovery
- Rollback points at every step
- Complete audit trail of all actions
- Validation before proceeding

### Access Control
- Only recover existing code (no new development)
- Respect branch protection rules
- Multi-source validation
- Professional audit standards

---

## 📖 QUICK REFERENCE

### Emergency Commands
```bash
# EMERGENCY - Any data corruption
/git:git-master-emergency-recovery

# Specific file recovery (when you know the source)
recover_file_from_commit "file-path" "commit-hash" "reason"

# Multi-instance safety before any git operation
echo "[Claude-Instance] ACTIVE" > .claude_instance_registry
echo "[Claude-Instance] OWNS $(git branch --show-current)" > .claude_branch_ownership
```

### Analysis Commands
```bash
# Understand what happened
establish_forensics_baseline()

# Find all recovery sources
mine_complete_local_git_history()
analyze_all_remote_repositories()

# Compare file versions
exhaustive_file_analysis "file-path"
comparative_content_analysis "file" "commit1" "commit2"
```

### Safety Commands
```bash
# Safe commit
git add specific-files  # Never use git add .
git commit -m "type(scope): description" --trailer="Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin $(git branch --show-current)

# Safe branch creation
git checkout development
git checkout -b feature/YYYY-MM-DD-description
git push -u origin feature/YYYY-MM-DD-description
```

---

## 🚨 REMEMBER: CANONICAL DIRECTIVES

1. **NEVER CREATE NEW CODE DURING RECOVERY** - Only recover existing working code
2. **EXHAUSTIVE ANALYSIS FIRST** - Understand all options before acting
3. **MULTI-INSTANCE SAFETY ALWAYS** - Coordinate with other AI instances
4. **COMPLETE AUDIT TRAIL** - Document every action and decision
5. **VALIDATION AT EVERY STEP** - Ensure functionality before proceeding
6. **ZERO DATA LOSS TOLERANCE** - Preserve everything during recovery

**These protocols are your lifeline when things go wrong. Use them systematically and completely.**