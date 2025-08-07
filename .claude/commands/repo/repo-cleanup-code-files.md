# === Repository Code File Cleanup Protocol ===

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

### 8. COMPLIANCE VERIFICATION CHECKLIST

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
  role: "Repository code cleanup specialist for ad-hoc file elimination with dependency analysis"
  domain: "Python scripts, Test files, Demo code, Temporary implementations, LLM artifacts"
  goal: >
    Execute MANDATORY cleanup of ALL ad-hoc code files scattered throughout repository.
    FORBIDDEN to keep test scripts, demos, temporary implementations, or duplicate code.
    MUST perform full dependency analysis before any modifications.
    MUST compile and validate all dependencies. MUST maintain pristine codebase.
    MUST comply with CANONICAL PROTOCOL at all times.

configuration:
  # Pre-cleanup analysis - MANDATORY DEPENDENCY MAPPING
  dependency_analysis:
    full_ast_analysis: true       # MUST parse AST for all files
    import_mapping: true          # MUST map all imports
    function_usage: true          # MUST track function calls
    class_inheritance: true       # MUST map class hierarchies
    module_dependencies: true     # MUST trace module deps
    compile_validation: true      # MUST compile all files
    production_detection: true    # MUST identify production code
    
  # Cleanup scope - MANDATORY EXHAUSTIVE COVERAGE
  cleanup_scope:
    root_python_files: true       # MUST process root directory .py files
    test_scripts: true            # MUST remove ad-hoc test files
    demo_files: true              # MUST delete ALL demo implementations
    temp_implementations: true    # MUST remove temporary code
    duplicate_scripts: true       # MUST eliminate code duplication
    one_off_scripts: true        # MUST clean up single-use files
    llm_artifacts: true          # MUST remove LLM-generated files
    
  # Forbidden patterns - MUST DELETE (with dependency check)
  forbidden_file_patterns:
    test_files: ["test_*.py", "*_test.py", "testing_*.py", "try_*.py", "check_*.py"]
    demo_files: ["demo_*.py", "*_demo.py", "example_*.py", "sample_*.py", "showcase_*.py"]
    temp_files: ["temp_*.py", "tmp_*.py", "*_temp.py", "*_tmp.py", "draft_*.py"]
    backup_files: ["*_backup.py", "*_old.py", "*.py.bak", "*_copy.py", "*_orig.py"]
    experiments: ["experiment_*.py", "poc_*.py", "prototype_*.py", "trial_*.py"]
    llm_artifacts: [
      "*_fix.py", "*_fixed.py", "fix_*.py",
      "*_clean.py", "*_cleaned.py", "clean_*.py",
      "*_final.py", "*_FINAL.py", "final_*.py",
      "*_updated.py", "updated_*.py", "update_*.py",
      "*_new.py", "new_*.py", "*_v2.py", "*_v3.py",
      "*_enhanced.py", "enhanced_*.py", "*_improved.py",
      "*_refactored.py", "refactored_*.py", "*_optimized.py",
      "*_corrected.py", "corrected_*.py", "*_patched.py",
      "*_working.py", "working_*.py", "*_stable.py",
      "*_simple.py", "simple_*.py", "*_simplified.py",
      "*_intelligent.py", "intelligent_*.py", "*_smart.py",
      "*_latest.py", "latest_*.py", "*_current.py"
    ]
    
  # Essential files - MANDATORY TO PRESERVE
  preserve_patterns:
    entry_points: ["__init__.py", "__main__.py", "main.py", "setup.py"]
    configs: ["config.py", "settings.py", "constants.py"]
    core_modules: ["src/**/*.py", "tests/**/*.py", "utils/**/*.py"]
    
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
      - validate_json_schema() → CORRECT

instructions:
  - Phase 0: Dependency Analysis
      - MANDATORY: Full codebase dependency mapping:
          - Parse AST for every Python file
          - Build complete import graph
          - Map function call chains
          - Trace class inheritance
          - Identify production paths
          - FORBIDDEN: Skip analysis
          
      - Dependency mapping process:
          - Use ast.parse() on all files
          - Extract all imports (absolute/relative)
          - Map module.function usage
          - Build dependency tree
          - Identify circular deps
          - MANDATORY: Complete map
          
      - Production code identification:
          - Trace from entry points
          - Follow import chains
          - Mark reachable code
          - Flag production modules
          - Separate from artifacts
          - MANDATORY: Accurate marking
          
      - Compilation validation:
          - py_compile.compile() each file
          - Check syntax validity
          - Verify import resolution
          - Test module loading
          - Validate references
          - MANDATORY: All must compile

  - Phase 1: Root Directory Python File Audit
      - MANDATORY: Scan ALL Python files in root:
          - List all .py files in root directory
          - Check against dependency map
          - Verify production usage
          - Identify test/demo files
          - Find duplicate functionality
          - FORBIDDEN: Blind deletion
          
      - Analysis criteria:
          - Is it an entry point?
          - Is it imported by production?
          - Is it a configuration?
          - Does it belong in root?
          - Can it be refactored?
          - MANDATORY: Verify deps first

  - Phase 2: LLM Artifact Detection and Removal
      - MANDATORY: Identify ALL LLM-generated files:
          - Check for *_fix.py patterns
          - Find *_clean.py variants
          - Detect *_final.py files
          - Locate *_updated.py versions
          - Search enhanced/improved
          - FORBIDDEN: Keep any
          
      - Detection process:
          - Pattern match filenames
          - Check file headers/comments
          - Compare with originals
          - Verify not in production
          - Check dependency usage
          - MANDATORY: Remove if unused

  - Phase 3: Ad-hoc Test Script Elimination
      - MANDATORY: Remove non-production tests:
          - Verify not imported
          - Check not in test suite
          - Confirm ad-hoc nature
          - Delete if not needed
          - Update .gitignore
          - FORBIDDEN: Break deps
          
      - Safe removal process:
          - Check dependency map
          - Verify no imports
          - Test compilation
          - Remove file
          - Re-validate codebase
          - MANDATORY: Safe only

  - Phase 4: Demo and Example Cleanup
      - MANDATORY: Delete unused demos:
          - Verify not in docs
          - Check not imported
          - Confirm example only
          - Extract useful code
          - Delete demo file
          - FORBIDDEN: Break tutorials
          
      - Code extraction:
          - Identify useful patterns
          - Extract to utilities
          - Update references
          - Document if needed
          - Remove demo file
          - MANDATORY: Preserve value

  - Phase 5: Code Deduplication with Safety
      - MANDATORY: Merge duplicate code safely:
          - Run deduplication analysis
          - Check all usages
          - Plan consolidation
          - Update imports atomically
          - Test after each merge
          - FORBIDDEN: Break imports
          
      - Safe refactoring:
          - Create shared module first
          - Update one import at a time
          - Test after each change
          - Remove original only after
          - Validate all deps
          - MANDATORY: Incremental

  - Phase 6: Dependency-Aware Organization
      - MANDATORY: Move files with deps intact:
          - Plan moves with dep map
          - Update imports in order
          - Move file
          - Fix all references
          - Test compilation
          - DOUBLE-CHECK: All working
          
      - Import update process:
          - List all importers
          - Update systematically
          - Use relative imports wisely
          - Test each change
          - Validate entire tree
          - MANDATORY: No breaks

cleanup_patterns:
  llm_artifacts:
    pattern: "LLM-generated variations and fixes"
    action: "DELETE after dependency check"
    examples: ["api_fixed.py", "client_clean.py", "main_final.py", "utils_updated.py", "simple_script.py", "enhanced_module.py", "intelligent_handler.py"]
    
  test_scripts:
    pattern: "Ad-hoc test files not in production"
    action: "DELETE if no dependencies"
    examples: ["test_api.py", "testing_functions.py", "try_connection.py"]
    
  safe_refactoring:
    pattern: "Duplicate code with dependencies"
    action: "Extract to shared module, update imports atomically"
    strategy: "Create new → Update refs → Delete old"

validation_criteria:
  dependency_integrity: "MANDATORY - All imports working"
  compilation_success: "MANDATORY - All files compile"
  production_safety: "MANDATORY - Production code intact"
  no_broken_imports: "MANDATORY - Zero import errors"
  clean_structure: "MANDATORY - Organized hierarchy"
  no_llm_artifacts: "MANDATORY - No fix/clean/final files"

constraints:
  - MANDATORY: Full dependency analysis FIRST
  - MANDATORY: Compile validation before changes
  - MANDATORY: Preserve ALL production code
  - MANDATORY: Update imports atomically
  - MANDATORY: Test after EVERY change
  - FORBIDDEN: Breaking ANY import
  - FORBIDDEN: Deleting without dep check
  - FORBIDDEN: Blind file operations
  - FORBIDDEN: Keeping LLM artifacts
  - FORBIDDEN: Using vague non-descriptive names (simple, clean, enhanced, intelligent, etc.)

# Execution Command
usage: |
  /repo-cleanup-code-files                # Full code file cleanup
  /repo-cleanup-code-files --deps-only    # Dependency analysis only
  /repo-cleanup-code-files tests          # Focus on test scripts
  /repo-cleanup-code-files llm            # Focus on LLM artifacts
  /repo-cleanup-code-files --safe         # Extra cautious mode

execution_protocol: |
  MANDATORY DEPENDENCY REQUIREMENTS:
  - MUST map all dependencies first
  - MUST compile all files
  - MUST trace production usage
  - MUST verify before deletion
  - MUST update imports safely
  
  MANDATORY CLEANUP REQUIREMENTS:
  - MUST audit all Python files
  - MUST check LLM patterns
  - MUST preserve production
  - MUST refactor safely
  - MUST organize properly
  
  STRICTLY FORBIDDEN:
  - NO breaking imports
  - NO blind deletions
  - NO production damage
  - NO untested changes
  - NO dependency breaks