# Universal Git Emergency Recovery & Management Protocols

**UNIVERSAL git protocols for emergency data recovery, multi-instance safety, and systematic git management.**

These protocols work across **ANY PROJECT TYPE** (Python, Node.js, Java, Go, Rust, etc.) and are designed to prevent data loss and provide systematic recovery from any git-related corruption or issues.

---

## 🌐 UNIVERSAL APPLICABILITY

These protocols are **PROJECT-AGNOSTIC** and include:
- **Emergency branch isolation** for safe recovery operations
- **Dependency-based recovery** (best file ≠ latest file)
- **Branch consistency enforcement** (no switching during recovery)
- **Comprehensive audit logging** with tamper-proof hashes
- **Multi-language support** (Python, JS, Java, Go, Rust, etc.)
- **Full traceability** of every action and decision

## 📋 Universal Protocol Directory

- **git-master-emergency-recovery.md** - Master protocol with emergency branching
- **git-emergency-data-recovery.md** - Surgical file recovery with dependency analysis
- **git-forensics-investigation.md** - Systematic corruption investigation  
- **git-exhaustive-file-analysis.md** - Deep cross-language file analysis
- **git-comprehensive-history-recovery.md** - Complete local+remote history mining
- **git-atomic-commit.md** - Multi-instance safe commits with logging
- **git-branch-strategy.md** - Multi-instance branch management with consistency

## 🔐 AUDIT & TRACEABILITY SYSTEM

**MANDATORY AUDIT REQUIREMENTS - FULLY AUDITABLE RECOVERY**

Every git recovery operation MUST be fully auditable, traceable, and documented with:

1. **Tamper-Proof Logging** - Cryptographic hashes for integrity verification
2. **Complete Action Traceability** - Every command, decision, and outcome logged
3. **Multi-Instance Coordination** - Track all AI instances working simultaneously  
4. **Recovery Session Isolation** - Unique session IDs with complete documentation
5. **Jupyter Notebook Documentation** - All recovery processes documented in notebooks
6. **Forensic-Grade Audit Trail** - Professional audit standards with timestamps

### 🚨 AUDIT ENFORCEMENT

**CANONICAL REQUIREMENT:** All recovery processes MUST use the audit functions below for complete traceability and documentation in Jupyter notebook format.

## GitRecoveryAuditSystem Implementation

```python
import hashlib
import datetime
import json
import uuid
import os

# Initialize audit system for git recovery
class GitRecoveryAuditSystem:
    def __init__(self):
        self.recovery_session_id = f"recovery-{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}-{uuid.uuid4().hex[:8]}"
        self.audit_log = []
        self.recovery_start_time = datetime.datetime.now()
        
        # Create date-stamped audit filename
        self.audit_filename = f"Git_Recovery_Audit_{self.recovery_start_time.strftime('%Y%m%d_%H%M%S')}_DataCorruption_Emergency.ipynb"
        
        print(f"🔐 AUDIT SYSTEM INITIALIZED")
        print(f"Recovery Session ID: {self.recovery_session_id}")
        print(f"Start Time: {self.recovery_start_time.isoformat()}")
        print(f"Audit File: {self.audit_filename}")
    
    def create_tamper_proof_entry(self, action, details, result=None, files_affected=None):
        """Create tamper-proof audit entry with dates, times, and recovery details"""
        timestamp = datetime.datetime.now()
        
        entry = {
            "session_id": self.recovery_session_id,
            "timestamp": timestamp.isoformat(),
            "date": timestamp.strftime("%Y-%m-%d"),
            "time": timestamp.strftime("%H:%M:%S UTC"),
            "action": action,
            "details": details,
            "result": result or "PENDING",
            "files_affected": files_affected or [],
            "instance": f"[Claude-Sonnet-4-{timestamp.isoformat()}]",
            "recovery_phase": self._determine_recovery_phase(action)
        }
        
        # Create cryptographic hash for tamper detection
        entry_json = json.dumps(entry, sort_keys=True, default=str)
        entry["integrity_hash"] = hashlib.sha256(entry_json.encode()).hexdigest()
        
        self.audit_log.append(entry)
        return entry
```

### 📝 AUTOMATIC AUDIT DOCUMENTATION WITH DATE-STAMPED FILENAMES

**MANDATORY FILENAME CONVENTION:**

All recovery audit files MUST follow this date-stamped naming pattern:
- `Git_Recovery_Audit_YYYYMMDD_HHMMSS_[Purpose]_[Issue].ipynb`
- `Git_Recovery_Summary_YYYYMMDD_HHMMSS_[FilesRecovered]_[Outcome].json`

**EXAMPLES:**
- `Git_Recovery_Audit_20250801_143022_DataCorruption_Emergency.ipynb`
- `Git_Recovery_Audit_20250801_150445_APIEndpoints_Critical.ipynb`
- `Git_Recovery_Summary_20250801_143022_MainPy_DockerYml_SUCCESS.json`

**AUDIT CONTENT REQUIREMENTS:**
- **Dates and times** for every action
- **Complete recovery details** including what was corrupted and how it was fixed
- **Files affected** with before/after states
- **Recovery decisions** with rationale
- **Validation results** confirming successful recovery

## 🚨 UNIVERSAL EMERGENCY RECOVERY PROTOCOLS

### When You Have Data Corruption or Loss

**IMMEDIATE ACTION REQUIRED:**

1. **STOP ALL WORK** - Do not make any changes until analysis is complete
2. **DO NOT CREATE NEW CODE** - Only recover existing working code
3. **CREATE EMERGENCY BRANCH** - Isolate recovery work from main codebase  
4. **MAINTAIN BRANCH CONSISTENCY** - Never switch branches during recovery
5. **USE MASTER RECOVERY PROTOCOL** - Execute recovery workflow
6. **PRIORITIZE DEPENDENCY COMPATIBILITY** - Best file ≠ latest file

### 🔒 CRITICAL SAFETY REQUIREMENTS

**EMERGENCY BRANCH ISOLATION:**
- **MUST** create emergency branch: `emergency-recovery-YYYYMMDD-HHMMSS-[issue]`
- **SHALL** work EXCLUSIVELY from emergency branch during ALL recovery
- **MUST NOT** switch branches during recovery without explicit coordination

**DEPENDENCY-BASED RECOVERY:**
- **MUST** analyze import dependencies and code relationships
- **SHALL** prioritize files that match existing codebase dependencies  
- **MUST NOT** assume latest file is best recovery candidate

**COMPREHENSIVE AUDIT LOGGING:**
- **MUST** log every action, decision, and result with timestamps
- **SHALL** create tamper-proof logs with cryptographic hashes
- **MUST** maintain full traceability across all recovery events

```bash
# EMERGENCY: Use this command for any data corruption situation
/git:git-master-emergency-recovery
```

### Protocol Selection Matrix

| Protocol | Purpose | When to Use | Complexity |
|----------|---------|-------------|------------|
| **git-master-emergency-recovery.md** | Complete emergency recovery coordination | ANY data corruption or loss situation | High |
| **git-emergency-data-recovery.md** | Surgical file recovery from git history | When specific files need recovery | Medium |
| **git-forensics-investigation.md** | Systematic investigation of corruption causes | To understand what went wrong | Medium |
| **git-exhaustive-file-analysis.md** | Deep analysis of file versions across history | To compare file versions thoroughly | High |
| **git-comprehensive-history-recovery.md** | Complete local and remote history mining | To access ALL available git data sources | High |
| **git-atomic-commit.md** | Safe atomic commits with instance tracking | Every commit operation | Low |
| **git-branch-strategy.md** | Multi-instance branch management | All branch operations | Low |

## 🔍 EMERGENCY RECOVERY WORKFLOW

### Phase 1: Emergency Response

```python
# Step 1: Immediate emergency protocol activation
# /git:git-master-emergency-recovery

# This automatically executes:
emergency_actions = [
    "Establish instance safety",
    "Document current crisis state", 
    "Create recovery workspace",
    "Initialize forensics investigation"
]
```

### Phase 2: Analysis

The master protocol automatically executes:
- **Forensics Investigation**: Traces exact changes that caused corruption
- **History Mining**: Searches ALL local and remote git sources
- **File Analysis**: Exhaustive content analysis of all file versions
- **Source Scoring**: Ranks all recovery candidates by quality

```python
# Phase 2: Analysis Functions
analysis_protocols = {
    "Forensics Investigation": "execute_coordinated_forensics()",
    "History Mining": "execute_comprehensive_history_mining()", 
    "File Analysis": "execute_exhaustive_file_analysis()",
    "Source Scoring": "score_all_recovery_sources()"
}
```

### Phase 3: Manual Recovery Execution

Based on analysis results, manually execute surgical recovery:

```python
# Example recovery commands (from analysis results)
recovery_examples = [
    'recover_file_from_commit("api-gateway-service/app/main.py", "abc123def", "Restore working API")',
    'validate_recovery_step("API gateway restoration")',
    'create_recovery_rollback_point("api-restored")'
]
```

### Phase 4: Validation and Documentation

```python
# After manual recovery
validation_commands = [
    'validation_log=$(execute_system_validation "$recovery_session_id" "$master_log")',
    'complete_recovery_documentation "$recovery_session_id" "$master_log"'
]
```

## 🛡️ MULTI-INSTANCE SAFETY PROTOCOLS

### When Multiple Claude Instances Are Working

**MANDATORY SAFETY PROTOCOLS:**

| Protocol | Purpose | When to Use |
|----------|---------|-------------|
| **git-atomic-commit.md** | Safe atomic commits with instance tracking | Every commit operation |
| **git-branch-strategy.md** | Multi-instance branch management | All branch operations |

### Multi-Instance Safety Workflow:

1. Instance Registration - Every instance must register before work
2. Branch Ownership - Claim branch ownership before any operations
3. Atomic Commits - One logical change per commit with tracking
4. Immediate Backup - Push after every commit
5. Safe Handoffs - Proper coordination when transferring work

```bash
# Instance Registration Commands:
echo "[Claude-Sonnet-4-TIMESTAMP] ACTIVE" > .claude_instance_registry
echo "[Claude-Sonnet-4-TIMESTAMP] OWNS $(git branch --show-current)" > .claude_branch_ownership
```

## 📋 PROTOCOL SELECTION GUIDE

### Choose the Right Protocol

**🚨 EMERGENCY SITUATIONS**
- System broken/corrupted → git-master-emergency-recovery.md
- API endpoints failing → git-master-emergency-recovery.md
- Missing critical files → git-master-emergency-recovery.md
- Container build failures → git-master-emergency-recovery.md

**🔍 ANALYSIS SITUATIONS**
- Need to understand what changed → git-forensics-investigation.md
- Compare file versions thoroughly → git-exhaustive-file-analysis.md
- Find all possible recovery sources → git-comprehensive-history-recovery.md

**🔧 SURGICAL RECOVERY**
- Recover specific files only → git-emergency-data-recovery.md
- Known good commit identified → git-emergency-data-recovery.md

**👥 MULTI-INSTANCE WORK**
- Multiple Claude instances active → git-atomic-commit.md + git-branch-strategy.md
- Need to commit safely → git-atomic-commit.md
- Need to create/switch branches → git-branch-strategy.md

## 🎯 CRITICAL SUCCESS FACTORS

### ✅ ALWAYS DO:
- Stop and analyze first - Never rush into changes
- Use exhaustive analysis - Understand ALL options before recovery
- Create rollback points - Safety at every step
- Document everything - Complete audit trail
- Validate each step - Ensure functionality before proceeding
- Follow multi-instance safety - Prevent conflicts

### ❌ NEVER DO:
- Create new code during recovery - Only recover existing working code
- Skip analysis phases - Always understand before acting
- Work on main/master directly - Use proper branch strategy
- Force push without coordination - Respect multi-instance safety
- Delete anything permanently - Always preserve for analysis

## 🚨 MANDATORY AUDIT EXPORT AND DOCUMENTATION

**CANONICAL REQUIREMENT:** Every recovery operation MUST export complete audit documentation:

1. **Jupyter Notebook Export** - Complete interactive recovery documentation
2. **JSON Summary Export** - Machine-readable audit log for analysis
3. **Markdown Conversion** - Static documentation for version control
4. **Tamper-Proof Verification** - Cryptographic integrity validation

**AUDIT TRAIL MUST INCLUDE:**
- **Complete timeline** with dates, times, and durations
- **Every file affected** with before/after states  
- **All recovery decisions** with detailed rationale
- **Validation results** confirming successful recovery
- **Multi-instance coordination** tracking all AI instances
- **Forensic evidence** of corruption source and recovery method

This ensures **ZERO DATA LOSS TOLERANCE** and **COMPLETE RECOVERABILITY** for any future analysis or debugging needs.

## 🚨 REMEMBER: CANONICAL DIRECTIVES

1. **NEVER CREATE NEW CODE DURING RECOVERY** - Only recover existing working code
2. **EXHAUSTIVE ANALYSIS FIRST** - Understand all options before acting
3. **MULTI-INSTANCE SAFETY ALWAYS** - Coordinate with other AI instances
4. **COMPLETE AUDIT TRAIL** - Document every action and decision
5. **VALIDATION AT EVERY STEP** - Ensure functionality before proceeding
6. **ZERO DATA LOSS TOLERANCE** - Preserve everything during recovery

**These protocols are your lifeline when things go wrong. Use them systematically and completely.**

---

**Generated from Jupyter Notebook: Git_Emergency_Recovery_Protocols.ipynb**

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>