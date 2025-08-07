# === Repository Master Cleanup Orchestration Protocol ===

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:
1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**



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
- Create properly named branches from development branch
- FORBIDDEN: Work directly on main/master/development branches
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
- `revert:` Revert previous commit

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

### 6. MANDATORY DEVSECOPS LOOP

**ALL CODE OPERATIONS MUST FOLLOW THE DEVSECOPS CYCLE:**

**THE INFINITE LOOP (for each change):**
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. PLAN → 2. CODE → 3. BUILD → 4. TEST → 5. DEPLOY   │
│       ↑                                          ↓      │
│       │                                          ↓      │
│  8. MONITOR ← 7. OPERATE ← 6. SECURE/VALIDATE ←─┘      │
│       │                                                 │
│       └─────────────────────────────────────────────────┘
```

**MANDATORY PHASES FOR EVERY CODE CHANGE:**

1. **PLAN** (code-planning.md)
   - Requirements analysis
   - Code reuse discovery
   - Architecture design
   - Implementation blueprint
   - Validation workflow
   - Git strategy planning

2. **CODE** (code-implement.md)
   - Follow implementation blueprint
   - Apply SOLID/DRY/KISS
   - Implement debug logging
   - Write production code only
   - In-place modifications only

3. **BUILD** (code-validation.md)
   - Compile all code
   - Run linters
   - Type checking
   - Complexity analysis
   - Dependency validation

4. **TEST** (code-testing-live-api.md)
   - Unit tests
   - Integration tests
   - API tests
   - Performance tests
   - Security tests

5. **DEPLOY** (code-deploy.md)
   - Container build
   - Environment validation
   - Service health checks
   - Rollback preparation
   - Deployment execution

6. **SECURE/VALIDATE** (code-security-analysis.md)
   - Security scanning
   - Vulnerability assessment
   - Compliance checking
   - Access control validation
   - Encryption verification

7. **OPERATE** (code-operational-analysis.md)
   - Log analysis
   - Performance monitoring
   - Error tracking
   - Resource utilization
   - Service availability

8. **MONITOR** (code-review.md)
   - Code quality metrics
   - Technical debt assessment
   - Improvement identification
   - Feedback incorporation
   - Loop restart planning

**ENFORCEMENT RULES:**
- NO skipping phases
- NO proceeding on failures
- MUST complete each phase
- MUST document outcomes
- MUST validate before next phase

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


### 7. ENTERPRISE CODE CHANGE SAFETY

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


**ABSOLUTELY FORBIDDEN - NO EXCEPTIONS:**
- **NO MOCKING** of data or services in production code
- **NO TODOs** - complete ALL work immediately
- **NO SHORTCUTS** - implement properly ALWAYS
- **NO STUBS** - write complete implementations
- **NO FIXED DATA** - use real, dynamic data
- **NO HARDCODED VALUES** - use configuration
- **NO WORKAROUNDS** - fix root causes
- **NO FAKE IMPLEMENTATIONS** - real code only
- **NO PLACEHOLDER CODE** - production-ready only
- **NO TEMPORARY SOLUTIONS** - permanent fixes only

**YOU MUST ALWAYS:**
- IMPLEMENT production code to HIGHEST enterprise standards
- FIX issues properly at the root cause
- COMPLETE all functionality before moving on
- USE real data, real services, real implementations
- MAINTAIN professional quality in EVERY line of code
### 8. MANDATORY MCP SERVER TOOL USAGE

**ALL LLMs MUST UTILIZE MCP SERVER TOOLS:**

**REQUIRED MCP TOOLS FOR ALL OPERATIONS:**

1. **THINKING TOOLS** - MANDATORY for complex tasks
   - `thinking` - For deep analysis and problem solving
   - `sequential_thinking` - For step-by-step execution
   - Use BEFORE making decisions
   - Use DURING complex implementations
   - Use WHEN debugging issues

2. **CONTEXT & MEMORY TOOLS** - MANDATORY for continuity
   - `context7` - For maintaining conversation context
   - `memory` - For tracking actions, decisions, progress
   - `fetch` - For retrieving information
   - MUST record ALL decisions in memory
   - MUST track ALL progress in memory
   - MUST maintain context across sessions

3. **TASK ORCHESTRATION** - MANDATORY for organization
   - `task_orchestrator` - For managing tasks/subtasks
   - `project_maestro` - For project-level coordination
   - Create tasks for ALL work items
   - Track progress systematically
   - Update status continuously

4. **CODE & FILE TOOLS** - USE APPROPRIATE TOOL
   - `read_file` / `write_file` - For file operations
   - `search` / `grep` - For code searching
   - `git` - For version control
   - Choose the BEST tool for the task
   - Don't use generic when specific exists

**MCP TOOL DISCOVERY & INSTALLATION:**

**YOU MUST USE CLAUDE CODE CLI's OWN COMMANDS:**

1. **LIST AVAILABLE TOOLS** using Claude CLI:
   ```
   /mcp list              # List all available MCP servers
   /mcp status            # Check which tools are enabled
   ```

2. **ENABLE REQUIRED TOOLS** using Claude CLI:
   ```
   /mcp enable thinking
   /mcp enable sequential-thinking
   /mcp enable memory
   /mcp enable context7
   /mcp enable task-orchestrator
   /mcp enable fetch
   ```

3. **SEARCH & INSTALL** new tools if needed:
   ```
   /mcp search <tool-name>     # Search for available tools
   /mcp install <tool-repo>    # Install from repository
   /mcp configure <tool>       # Configure the tool
   /mcp enable <tool>          # Enable for use
   ```

4. **VERIFY TOOLS ARE ACTIVE**:
   ```
   /mcp status                 # Confirm tools are running
   /mcp test <tool>           # Test tool connectivity
   ```

**TOOL SELECTION CRITERIA:**
- Is there a SPECIFIC tool for this task?
- Would a specialized tool be BETTER?
- Can I COMBINE tools for efficiency?
- Should I INSTALL a new tool?

**MANDATORY TOOL USAGE PATTERNS:**

```
BEFORE ANY TASK:
1. Use 'thinking' to analyze approach
2. Use 'memory' to check previous work
3. Use 'task_orchestrator' to plan steps

DURING EXECUTION:
1. Use 'sequential_thinking' for complex logic
2. Use appropriate file/code tools
3. Update 'memory' with progress

AFTER COMPLETION:
1. Update 'task_orchestrator' status
2. Save summary to 'memory'
3. Use 'context7' to maintain state
```

**FORBIDDEN PRACTICES:**
- Working WITHOUT MCP tools
- Using GENERIC tools when specific exist
- IGNORING available MCP capabilities
- NOT searching for better tools
- NOT installing needed tools


### 9. COMPLIANCE VERIFICATION CHECKLIST

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

- [ ] MCP tools inventory completed?
- [ ] Appropriate MCP tools selected?
- [ ] Memory/context tools engaged?

**ENFORCEMENT:** Any violation requires IMMEDIATE STOP and correction

---

**REMEMBER:** Professional enterprise development requires discipline, planning, and systematic execution. NO SHORTCUTS.
### 10. MANDATORY CODEBASE HYGIENE ENFORCEMENT

**GOOD CODEBASE HYGIENE IS STRICTLY ENFORCED - NO EXCEPTIONS**

**AFTER EVERY CODE CHANGE, YOU MUST:**

1. **RUN REPO CLEANUP COMMANDS** from `.claude/commands/repo/`:
   ```
   /repo-cleanup-code-files        # Remove test scripts, demos, duplicates
   /repo-cleanup-documentation     # Clean doc sprawl, convert to notebooks
   /repo-cleanup-unicode-emoji     # Remove ALL Unicode/emoji
   /repo-cleanup-config-scripts    # Convert forbidden scripts
   ```

2. **ENFORCE HYGIENE ON YOUR OWN WORK:**
   - Check for files YOU created with "fix", "clean", "final" in names
   - Verify NO temporary files remain
   - Ensure NO duplicate code exists
   - Confirm NO TODOs or stubs left
   - Validate NO hardcoded values

3. **CODEBASE HYGIENE CHECKLIST:**
   - [ ] NO test_*.py files in root
   - [ ] NO demo or example files
   - [ ] NO duplicate implementations
   - [ ] NO Unicode or emoji anywhere
   - [ ] NO shell/batch/PowerShell scripts
   - [ ] NO point-in-time reports
   - [ ] NO multiple README files per directory
   - [ ] NO backup or temporary files

**MANDATORY CLEANUP SEQUENCE:**
```bash
# After final atomic commit:
/repo-cleanup-code-files        # Clean code artifacts
/repo-cleanup-documentation     # Clean doc artifacts
/repo-cleanup-unicode-emoji     # Clean Unicode
/repo-cleanup-master           # Run master cleanup
```


### 11. POST-COMPLETION REINITIALIZATION

**AFTER CLEANUP AND HYGIENE CHECK, YOU MUST:**

```
/init                      # Reinitialize CLAUDE.md for next session
```

**THIS COMMAND:**
- Updates CLAUDE.md with latest context
- Clears temporary state
- Prepares for next command/instruction
- Ensures clean slate for next task

**MANDATORY EXECUTION:**
- AFTER repo cleanup commands
- AFTER final hygiene check
- BEFORE starting new task
- WHEN switching contexts
- AT session boundaries



model_context:
  role: "Repository master cleanup orchestrator and coordinator"
  domain: "Complete repository sanitization, All cleanup protocols, validation"
  goal: >
    Execute MANDATORY master cleanup orchestration of entire repository.
    MUST coordinate ALL cleanup protocols in optimal sequence.
    FORBIDDEN to leave any mess, sprawl, or non-compliance.
    MUST achieve pristine, professional codebase state.
    MUST comply with CANONICAL PROTOCOL at all times.

configuration:
  # Master cleanup phases - MANDATORY SEQUENCE
  cleanup_phases:
    phase_1_analysis: true        # Complete repository analysis
    phase_2_unicode: true         # Remove all Unicode/emoji first
    phase_3_scripts: true         # Convert forbidden scripts
    phase_4_documentation: true   # Clean documentation sprawl
    phase_5_code_files: true      # Clean code file chaos
    phase_6_deduplication: true   # Eliminate all duplicates
    phase_7_recursive: true       # Deep recursive cleanup
    phase_8_validation: true      # Final validation
    
  # Execution strategy
  execution_config:
    pre_cleanup_backup: true      # Git commit before start
    atomic_operations: true       # Rollback capability
    progress_tracking: true       # Detailed progress logs
    validation_gates: true        # Check between phases
    final_verification: true      # final check

instructions:
  - Phase 1: Pre-Cleanup Analysis and Backup
      - MANDATORY: Complete repository snapshot:
          - Git status and commit
          - File inventory creation
          - Size measurements
          - Issue identification
          - Backup critical files
          - FORBIDDEN: Skip backup
          
      - Analysis metrics:
          - Total files by type
          - Unicode contamination
          - Script compliance
          - Documentation sprawl
          - Code duplication
          - MANDATORY: Full metrics

  - Phase 2: Unicode and Emoji Elimination
      - MANDATORY: Execute unicode cleanup first:
          - Prevents corruption spread
          - Ensures ASCII baseline
          - Simplifies later phases
          - Run /repo-cleanup-unicode-emoji
          - Validate completion
          - FORBIDDEN: Skip this
          
      - Validation gate:
          - Zero Unicode found
          - All files ASCII
          - No emoji remains
          - References updated
          - Functionality intact
          - MANDATORY: Pass gate

  - Phase 3: Script Language Compliance
      - MANDATORY: Convert all scripts:
          - Shell to Python/Node
          - Batch to Python
          - PowerShell to Python
          - Run /repo-cleanup-config-scripts
          - Test conversions
          - FORBIDDEN: Script remains
          
      - Conversion validation:
          - All scripts converted
          - Functionality preserved
          - Cross-platform ready
          - No forbidden languages
          - Tests passing
          - MANDATORY: Compliant

  - Phase 4: Documentation Cleanup
      - MANDATORY: Eliminate doc sprawl:
          - Remove temporal reports
          - Consolidate READMEs
          - Convert to notebooks
          - Run /repo-cleanup-documentation
          - Update references
          - FORBIDDEN: Doc mess
          
      - Documentation gate:
          - One README per dir
          - No point-in-time docs
          - Useful docs as .ipynb
          - Clean structure
          - Links working
          - MANDATORY: Organized

  - Phase 5: Code File Organization
      - MANDATORY: Clean code chaos:
          - Remove test scripts
          - Delete demo files
          - Refactor utilities
          - Run /repo-cleanup-code-files
          - Update imports
          - FORBIDDEN: Ad-hoc files
          
      - Code organization gate:
          - Clean root directory
          - Proper file locations
          - No duplicate code
          - Working imports
          - Tests passing
          - MANDATORY: Structured

  - Phase 6: Deep Deduplication
      - MANDATORY: Eliminate ALL duplicates:
          - Run deduplication analyzer
          - Extract common code
          - Create shared modules
          - Update all references
          - Remove duplicates
          - FORBIDDEN: Any duplicates
          
      - Deduplication metrics:
          - Functions consolidated
          - Modules extracted
          - Lines saved
          - DRY compliance
          - No redundancy
          - MANDATORY: Deduplicated

  - Phase 7: Recursive Deep Clean
      - MANDATORY: Process entire tree:
          - Apply all protocols
          - Every subdirectory
          - Cross-dir optimization
          - Run /repo-cleanup-recursive
          - Final structure
          - FORBIDDEN: Shallow clean
          
      - Recursive validation:
          - All dirs processed
          - Consistent structure
          - No orphaned files
          - References intact
          - Clean hierarchy
          - MANDATORY: Complete

  - Phase 8: Final Master Validation
      - MANDATORY: validation:
          - Run all test suites
          - Check all imports
          - Validate structure
          - Verify compliance
          - Generate report
          - DOUBLE-CHECK: Perfect
          
      - Final checklist:
          - Zero Unicode/emoji
          - No forbidden scripts
          - No doc sprawl
          - No code chaos
          - No duplicates
          - MANDATORY: All pass

master_coordination:
  phase_dependencies:
    unicode_first: "Must clean Unicode before other text processing"
    scripts_early: "Convert scripts before moving files"
    docs_before_code: "Clean docs before code refactoring"
    recursive_last: "Final cleanup after individual phases"
    
  rollback_strategy:
    git_checkpoints: "Commit after each successful phase"
    validation_gates: "Rollback if gate fails"
    atomic_operations: "Each phase fully reversible"

validation_criteria:
  pre_cleanup_backup: "MANDATORY - Git committed"
  unicode_elimination: "MANDATORY - Zero Unicode"
  script_compliance: "MANDATORY - Permitted languages only"
  documentation_hygiene: "MANDATORY - No sprawl"
  code_organization: "MANDATORY - Proper structure"
  zero_duplication: "MANDATORY - DRY enforced"
  recursive_completion: "MANDATORY - All dirs clean"
  final_validation: "MANDATORY - All tests pass"

constraints:
  - MANDATORY: Execute ALL phases in sequence
  - MANDATORY: Pass ALL validation gates
  - MANDATORY: Complete EACH phase fully
  - MANDATORY: Track ALL progress
  - MANDATORY: Validate EVERYTHING
  - FORBIDDEN: Skipping phases
  - FORBIDDEN: Ignoring failures
  - FORBIDDEN: Partial execution
  - FORBIDDEN: No validation
  - FORBIDDEN: Using vague non-descriptive names (simple, clean, enhanced, intelligent, etc.)

# Execution Command
usage: |
  /repo-cleanup-master                    # Full master cleanup
  /repo-cleanup-master --dry-run          # Analysis only
  /repo-cleanup-master --from-phase 3     # Resume from phase
  /repo-cleanup-master --validate-only    # Validation only

execution_protocol: |
  MASTER CLEANUP SEQUENCE:
  1. Pre-cleanup analysis and backup
  2. Unicode/emoji elimination
  3. Script language compliance
  4. Documentation cleanup
  5. Code file organization
  6. Deep deduplication
  7. Recursive cleanup
  8. Final validation
  
  MANDATORY REQUIREMENTS:
  - MUST complete all phases
  - MUST pass all gates
  - MUST track progress
  - MUST validate fully
  - MUST achieve perfection
  
  STRICTLY FORBIDDEN:
  - NO skipping phases
  - NO partial cleanup
  - NO validation bypass
  - NO remaining mess
  - NO non-compliance