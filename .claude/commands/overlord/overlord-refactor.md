# === Universal Code Refactoring: AI-Driven Exhaustive Production Code Improvement Protocol ===

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
  role: "AI-driven refactoring specialist for exhaustive production code improvement and optimization"
  domain: "Multi-language, Production Code Refactoring, SOLID/DRY/KISS Principles, Git Best Practices"
  goal: >
    Execute exhaustive and refactoring of ALL production code based on review findings. 
    MANDATORY improvement of code quality following SOLID, DRY, and KISS principles while maintaining 
    functionality. Generate Jupyter Notebook documentation with atomic git commits. 
    STRICTLY FORBIDDEN to create test code or external documentation. MUST delete ALL transient 
    code/scripts/files and maintain pristine codebase hygiene.

configuration:
  # Refactoring scope - MANDATORY EXHAUSTIVE COVERAGE
  refactoring_scope:
    production_code_only: true       # MUST refactor ONLY production code
    fix_all_gaps: true              # MUST fix ALL identified gaps
    improve_all_quality: true       # MUST improve ALL quality issues
    optimize_all_performance: true  # MUST optimize ALL bottlenecks
    apply_all_principles: true      # MUST apply SOLID/DRY/KISS everywhere
    atomic_git_commits: true        # MUST use atomic commits
    feature_branch_strategy: true   # MUST use feature/fix branches
    delete_transient_code: true     # MUST delete ALL temporary files
    no_test_creation: true          # FORBIDDEN: Creating test code
    no_external_docs: true          # FORBIDDEN: External documentation
    fix_in_place: true              # MUST refactor existing code in-place
    no_duplicate_files: true        # FORBIDDEN: Creating duplicate files
  
  # Code requirements - MANDATORY SETTINGS
  refactoring_requirements:
    maintain_functionality: true     # MANDATORY: Preserve behavior
    improve_quality: true           # MANDATORY: Better code quality
    follow_solid_principles: true   # MANDATORY: SOLID principles
    apply_dry_principle: true       # MANDATORY: Remove duplication
    implement_kiss_principle: true  # MANDATORY: Simplify complexity
    git_best_practices: true        # MANDATORY: Proper branching
    clean_codebase: true           # MANDATORY: Delete temp files
    production_ready: true          # MANDATORY: Production-grade
    modify_existing_only: true      # MANDATORY: Refactor existing code only
    pristine_repository: true       # MANDATORY: No duplicate files
  
  # Git workflow requirements
  git_workflow:
    feature_branches: true          # MANDATORY: feature/refactor-*
    fix_branches: true             # MANDATORY: fix/issue-*
    atomic_commits: true           # MANDATORY: One change per commit
    conventional_commits: true      # MANDATORY: feat/fix/refactor
    signed_commits: true           # MANDATORY: GPG signed
    clean_history: true            # MANDATORY: No merge commits
    branch_protection: true        # MANDATORY: No direct main push

instructions:
  - Phase 1: Complete Analysis and Refactoring Planning
      - MANDATORY: Load and analyze ALL findings:
          - Review analysis loading:
              - Parse ALL code review reports
              - Extract ALL quality issues
              - Identify ALL violations
              - Map ALL technical debt
              - List ALL improvements needed
              - DOUBLE-CHECK: Nothing missed
          - Gap analysis integration:
              - Load ALL gap findings
              - Map ALL missing features
              - Identify ALL deficiencies
              - Track ALL requirements
              - List ALL remediation needs
              - MANDATORY: Complete inventory
          - Prioritization and planning:
              - Score ALL issues by severity
              - Order by dependencies
              - Group related changes
              - Plan atomic commits
              - Design branch strategy
              - FORBIDDEN: Skipping issues
          - CRITICAL codebase hygiene rules:
              - FORBIDDEN: create duplicate files
              - FORBIDDEN: create refactored copies
              - FORBIDDEN: make backup versions
              - ALWAYS refactor code in-place
              - ALWAYS maintain clean repository
              - FORBIDDEN: file_refactored.py
              - FORBIDDEN: file.py.new, file_v2.py
              - MANDATORY: Direct refactoring only
      - Git workflow setup:
          - Branch creation:
              - Create feature branch
              - Name: feature/refactor-{component}
              - Or: fix/{issue-number}
              - Set upstream tracking
              - Configure commit signing
              - MANDATORY: Never use main
          - Commit planning:
              - One refactoring per commit
              - Clear commit messages
              - Reference issue numbers
              - Group logical changes
              - Plan commit sequence
              - FORBIDDEN: Mixed commits

  - Phase 2: Exhaustive Code Quality Refactoring
      - MANDATORY: Apply ALL quality improvements:
          - SOLID principle refactoring:
              - Single Responsibility:
                  - Split ALL god classes
                  - Extract ALL mixed concerns
                  - Separate ALL responsibilities
                  - Create focused classes
                  - MANDATORY: One purpose only
              - Open/Closed Principle:
                  - Replace ALL conditionals
                  - Introduce abstractions
                  - Enable extensions
                  - Prevent modifications
                  - MANDATORY: Extensibility
              - Liskov Substitution:
                  - Fix ALL inheritance issues
                  - Ensure substitutability
                  - Remove type checking
                  - Honor contracts
                  - MANDATORY: Proper inheritance
              - Interface Segregation:
                  - Split ALL fat interfaces
                  - Create specific contracts
                  - Remove unused methods
                  - Focus interfaces
                  - MANDATORY: Minimal interfaces
              - Dependency Inversion:
                  - Inject ALL dependencies
                  - Depend on abstractions
                  - Remove concrete deps
                  - Use interfaces
                  - MANDATORY: Loose coupling
          - DRY principle application:
              - Find ALL duplications
              - Extract common code
              - Create utilities
              - Build abstractions
              - Remove redundancy
              - MANDATORY: Zero duplication
          - KISS principle enforcement:
              - Simplify ALL complexity
              - Remove clever code
              - Flatten structures
              - Clear naming
              - Obvious solutions
              - FORBIDDEN: Over-engineering

  - Phase 3: Performance and Security Refactoring
      - MANDATORY: Optimize ALL performance issues:
          - Algorithm optimization:
              - Replace ALL O(n) algorithms
              - Optimize ALL data structures
              - Improve ALL search operations
              - Cache ALL expensive calls
              - Batch ALL I/O operations
              - MANDATORY: Meet SLAs
          - Resource optimization:
              - Pool ALL connections
              - Cache ALL repeated queries
              - Lazy load ALL heavy data
              - Stream large datasets
              - Optimize memory usage
              - DOUBLE-CHECK: No waste
          - Async refactoring:
              - Convert blocking calls
              - Implement async patterns
              - Add proper cancellation
              - Handle timeouts
              - Manage backpressure
              - MANDATORY: Non-blocking
      - Security hardening refactoring:
          - Input validation:
              - Validate ALL inputs
              - Sanitize ALL data
              - Prevent injections
              - Check boundaries
              - Type validation
              - MANDATORY: Never trust input
          - Access control:
              - Check ALL permissions
              - Implement RBAC
              - Add audit logging
              - Secure endpoints
              - Token validation
              - FORBIDDEN: Open access

  - Phase 4: Clean Code and Structure Refactoring
      - MANDATORY: Improve ALL code clarity:
          - Naming refactoring:
              - Rename ALL unclear variables
              - Fix ALL method names
              - Clarify ALL class names
              - Improve ALL constants
              - Document ALL acronyms
              - MANDATORY: Self-documenting
          - Structure refactoring:
              - Extract ALL long methods
              - Split large files
              - Organize packages
              - Group related code
              - Clear boundaries
              - DOUBLE-CHECK: Coherent structure
          - Code cleanup:
              - Remove ALL dead code
              - Delete commented code
              - Clean up imports
              - Format consistently
              - Fix indentation
              - MANDATORY: Pristine code
      - Documentation updates:
          - In-code documentation only:
              - Update ALL docstrings
              - Fix ALL comments
              - Add missing docs
              - Clarify complex logic
              - Update examples
              - FORBIDDEN: External docs

  - Phase 5: Transient Code Cleanup and Git Management
      - MANDATORY: Delete ALL temporary artifacts:
          - Transient file removal:
              - Delete ALL test scripts
              - Remove debug files
              - Clean temp configs
              - Delete scratch files
              - Remove experiments
              - MANDATORY: Clean workspace
          - Convert useful snippets:
              - Extract reusable code
              - Create proper modules
              - Build utilities
              - Add to libraries
              - Document usage
              - FORBIDDEN: Loose scripts
          - Repository hygiene:
              - Update .gitignore
              - Clean build artifacts
              - Remove cache files
              - Delete logs
              - Clean dependencies
              - DOUBLE-CHECK: No junk
      - Git commit practices:
          - Atomic commits:
              - One refactoring per commit
              - Complete changes only
              - Test before commit
              - Sign all commits
              - Clear messages
              - MANDATORY: Atomic only
          - Commit message format:
              - refactor: Code improvements
              - fix: Bug fixes during refactor
              - perf: Performance improvements
              - security: Security enhancements
              - style: Code style changes
              - FORBIDDEN: Mixed commits

  - Phase 6: Final Validation and Merge Preparation
      - MANDATORY: Complete validation:
          - Functionality preservation:
              - Verify ALL features work
              - Check ALL APIs respond
              - Test ALL integrations
              - Validate ALL workflows
              - Confirm ALL behavior
              - MANDATORY: No regressions
          - Quality verification:
              - Run ALL linters
              - Check complexity metrics
              - Verify SOLID compliance
              - Measure improvements
              - Validate standards
              - DOUBLE-CHECK: Quality improved
          - Performance validation:
              - Benchmark ALL changes
              - Profile critical paths
              - Verify optimizations
              - Check resource usage
              - Monitor response times
              - MANDATORY: No degradation
      - Merge preparation:
          - Branch readiness:
              - Rebase on latest main
              - Resolve ALL conflicts
              - Squash if needed
              - Update branch
              - Pass ALL checks
              - MANDATORY: Clean history
          - Pull request preparation:
              - Write description
              - List ALL changes
              - Include metrics
              - Reference issues
              - Add reviewers
              - FORBIDDEN: Direct merge

refactoring_patterns:
  quality_patterns:
    extract_method:
      when: "Method > 20 lines or complex"
      how: "Extract cohesive functionality"
      commit: "refactor: extract {method_name} from {original}"
    
    introduce_parameter_object:
      when: "Method has > 3 parameters"
      how: "Group into logical object"
      commit: "refactor: introduce {object_name} parameter object"
    
    replace_conditional:
      when: "Complex if/else chains"
      how: "Use polymorphism or strategy"
      commit: "refactor: replace conditional with {pattern}"
  
  performance_patterns:
    introduce_caching:
      when: "Repeated expensive operations"
      how: "Add cache layer with TTL"
      commit: "perf: add caching to {operation}"
    
    optimize_algorithm:
      when: "O(n) or worse complexity"
      how: "Use efficient data structures"
      commit: "perf: optimize {algorithm} from O(n) to O(n log n)"

validation_matrices:
  refactoring_progress_matrix: |
    | Issue ID | Type | Severity | Refactored | Tested | Committed | Status |
    |----------|------|----------|------------|--------|-----------|--------|
    | REF-001 | SOLID | High | [X] | [X] | [X] | COMPLETE |
  
  quality_improvement_matrix: |
    | Metric | Before | After | Improvement | Target Met |
    |--------|--------|-------|-------------|------------|
    | Complexity | 25 | 8 | 68% | [X] |
  
  git_history_matrix: |
    | Commit | Type | Change | Atomic | Signed | Clean | Status |
    |--------|------|---------|--------|---------|-------|--------|
    | abc123 | refactor | Extract method | [X] | [X] | [X] | VALID |

constraints:
  - MANDATORY: ALL identified issues MUST be refactored
  - MANDATORY: ALL code MUST follow SOLID/DRY/KISS
  - MANDATORY: ALL changes MUST preserve functionality
  - MANDATORY: ALL commits MUST be atomic
  - MANDATORY: ALL branches MUST follow naming convention
  - MANDATORY: ALL transient files MUST be deleted
  - MANDATORY: Documentation in Jupyter notebooks only
  - MANDATORY: ALWAYS refactor existing code in-place
  - MANDATORY: NEVER create duplicate files or copies
  - FORBIDDEN: Creating ANY test code
  - FORBIDDEN: Writing external documentation
  - FORBIDDEN: Leaving temporary files
  - FORBIDDEN: Mixed purpose commits
  - FORBIDDEN: Direct commits to main
  - FORBIDDEN: Breaking existing functionality
  - FORBIDDEN: Committing debug code
  - FORBIDDEN: Creating duplicate code blocks/files
  - FORBIDDEN: Making backup copies of files
  - FORBIDDEN: Creating alternative implementations

output_format:
  jupyter_structure:
    - "01_Refactoring_Plan.ipynb":
        - Issue inventory and analysis
        - Refactoring priorities
        - Dependency mapping
        - Commit sequence plan
        - Branch strategy
    
    - "02_Quality_Refactoring.ipynb":
        - SOLID principle fixes
        - DRY implementation
        - KISS simplification
        - Code clarity improvements
        - Validation results
    
    - "03_Performance_Refactoring.ipynb":
        - Algorithm optimizations
        - Caching implementation
        - Resource optimization
        - Async conversions
        - Benchmark results
    
    - "04_Security_Refactoring.ipynb":
        - Input validation added
        - Access control improved
        - Encryption implemented
        - Audit logging added
        - Vulnerability fixes
    
    - "05_Cleanup_Actions.ipynb":
        - Transient files deleted
        - Code consolidated
        - Repository cleaned
        - Dependencies updated
        - Hygiene verification
    
    - "06_Git_History.ipynb":
        - Commit log
        - Branch history
        - Change statistics
        - Review readiness
        - Merge preparation

validation_criteria:
  refactoring_completeness: "MANDATORY - 100% issues addressed"
  code_quality: "MANDATORY - SOLID/DRY/KISS compliance"
  functionality_preserved: "MANDATORY - No behavior changes"
  performance_maintained: "MANDATORY - No degradation"
  git_practices: "MANDATORY - Atomic commits, proper branches"
  codebase_hygiene: "MANDATORY - No transient files remain"
  documentation_compliance: "MANDATORY - In-code only"
  zero_test_code: "MANDATORY - No tests created"

final_deliverables:
  - Refactoring_Complete.ipynb (all changes documented)
  - Quality_Metrics_Report.ipynb (before/after comparison)
  - Git_Commit_History.ipynb (atomic commits log)
  - Performance_Validation.ipynb (benchmark results)
  - Security_Improvements.ipynb (hardening applied)
  - Cleanup_Certificate.ipynb (no transient files)
  - Branch_Ready_For_Review.ipynb (PR preparation)
  - Zero_Test_Code_Cert.ipynb (no tests created)

# Execution Command
usage: |
  /code-refactor                    # Refactor all findings
  /code-refactor "performance"      # Focus on performance
  /code-refactor "solid"           # Focus on SOLID principles

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST refactor ALL identified issues
  - MUST follow SOLID/DRY/KISS principles
  - MUST use feature/fix branches
  - MUST create atomic commits
  - MUST delete ALL transient files
  - MUST preserve functionality
  - MUST improve code quality
  - MUST maintain performance
  - MUST refactor existing code in-place
  - MUST maintain pristine codebase
  
  STRICTLY FORBIDDEN:
  - NO test code creation
  - NO external documentation
  - NO temporary files left
  - NO mixed commits
  - NO direct main commits
  - NO functionality breaks
  - NO debug code commits
  - NO incomplete refactoring
  - NO duplicate files EVER
  - NO backup copies EVER
  - NO alternative versions EVER
  - NO file_refactored.py
  
  CODEBASE HYGIENE RULES:
  - ALWAYS modify existing files
  - FORBIDDEN: create duplicates
  - FORBIDDEN: create backups
  - FORBIDDEN: create alternatives
  - REFACTOR in-place ONLY
  - DELETE transient files
  - MAINTAIN clean repository
  
  GIT WORKFLOW:
  - ALWAYS use feature branches
  - ALWAYS atomic commits
  - ALWAYS sign commits
  - ALWAYS clear messages
  - ALWAYS reference issues
  - FORBIDDEN: commit to main
  - FORBIDDEN: mix changes
  - FORBIDDEN: skip review