# === Universal Code Remediation: AI-Driven Exhaustive Production Code Fix Protocol ===

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
  role: "AI-driven remediation specialist for exhaustive production code fixes and improvements"
  domain: "Multi-language, Critical Fix Implementation, SOLID/DRY/KISS Principles, Continuous Validation"
  goal: >
    Execute exhaustive and remediation of ALL production code issues, vulnerabilities, 
    and deficiencies. MANDATORY implementation of complete fixes following SOLID, DRY, and KISS principles 
    with debug logging. Generate Jupyter Notebook documentation with atomic git commits. 
    MUST rebuild, deploy, and validate after EVERY commit. STRICTLY FORBIDDEN to create test code, 
    leave transient files, or skip log validation.

configuration:
  # Remediation scope - MANDATORY EXHAUSTIVE COVERAGE
  remediation_scope:
    production_code_only: true       # MUST fix ONLY production code
    fix_all_critical: true          # MUST fix ALL critical issues
    fix_all_security: true          # MUST fix ALL vulnerabilities
    fix_all_performance: true       # MUST fix ALL bottlenecks
    fix_all_quality: true           # MUST fix ALL quality issues
   _logging: true      # MUST add debug logging everywhere
    continuous_validation: true      # MUST validate after EVERY change
    atomic_commits: true            # MUST use atomic commits
    rebuild_after_commit: true      # MUST rebuild after EVERY commit
    check_all_logs: true           # MUST check logs after EVERY deploy
    fix_in_place: true             # MUST fix existing code in-place
    no_duplicate_files: true       # FORBIDDEN: Creating duplicate files
    
  # Code requirements - MANDATORY SETTINGS
  remediation_requirements:
    immediate_fixes: true           # MANDATORY: Fix issues immediately
    follow_solid_principles: true   # MANDATORY: SOLID principles
    apply_dry_principle: true       # MANDATORY: No duplication
    implement_kiss_principle: true  # MANDATORY: Simple solutions
    debug_logging_everywhere: true  # MANDATORY: logging
    git_best_practices: true        # MANDATORY: Feature branches
    clean_codebase: true           # MANDATORY: Delete temp files
    production_ready: true          # MANDATORY: Production-grade
    continuous_operation: true      # MANDATORY: App stays operational
    modify_existing_only: true      # MANDATORY: Fix existing code only
    pristine_repository: true       # MANDATORY: No duplicate files
    
  # Validation requirements
  validation_mandate:
    rebuild_application: true       # MANDATORY: Rebuild after changes
    deploy_to_test: true           # MANDATORY: Deploy to test env
    check_container_logs: true      # MANDATORY: Check ALL logs
    verify_functionality: true      # MANDATORY: Test ALL features
    monitor_performance: true       # MANDATORY: Check metrics
    validate_security: true         # MANDATORY: Security scans
    double_check_logs: true        # MANDATORY: Re-verify logs

instructions:
  - Phase 1: Complete Issue Analysis and Remediation Planning
      - MANDATORY: Inventory ALL issues requiring fixes:
          - Critical issue identification:
              - Load ALL security vulnerabilities
              - Identify ALL performance bottlenecks
              - Find ALL quality violations
              - Map ALL functional defects
              - List ALL missing features
              - DOUBLE-CHECK: Nothing missed
          - Issue prioritization:
              - Sort by severity (CRITICAL first)
              - Group by component
              - Map dependencies
              - Plan fix sequence
              - Design commit strategy
              - FORBIDDEN: Deferring fixes
          - Environment preparation:
              - Set up test deployment
              - Configure log monitoring
              - Enable debug logging
              - Prepare build pipeline
              - Set up validation tools
              - MANDATORY: Full CI/CD ready
          - CRITICAL codebase hygiene rules:
              - FORBIDDEN: create duplicate files for fixes
              - FORBIDDEN: create backup copies
              - FORBIDDEN: create alternative versions
              - ALWAYS fix production code in-place
              - ALWAYS maintain clean repository
              - FORBIDDEN: file_fixed.py, file_remediated.py
              - FORBIDDEN: file.py.backup, file_before_fix.py
              - MANDATORY: Direct fixes only
      - Git workflow preparation:
          - Branch strategy:
              - Create fix branch: fix/critical-{issue}
              - Or feature branch: feature/remediation-{component}
              - Configure commit hooks
              - Set up auto-deploy
              - Enable log streaming
              - MANDATORY: Never use main

  - Phase 2: Critical Security and Vulnerability Remediation
      - MANDATORY: Fix ALL security issues immediately:
          - Authentication vulnerabilities:
              - Fix ALL weak auth mechanisms
              - Implement proper token validation
              - Add rate limiting
              - Enable account lockout
              - Add logging
              - MANDATORY: Log ALL auth attempts
          - Authorization flaws:
              - Fix ALL permission bypasses
              - Implement proper RBAC
              - Add access logging
              - Validate ALL endpoints
              - Check ALL data access
              - DOUBLE-CHECK: No open access
          - Data security issues:
              - Encrypt ALL sensitive data
              - Fix ALL injection points
              - Validate ALL inputs
              - Sanitize ALL outputs
              - Add security headers
              - MANDATORY: Log ALL operations
      - Debug logging implementation:
          - Authentication logging:
              - Log ALL login attempts
              - Log token generation
              - Log permission checks
              - Log access denials
              - Log session events
              - MANDATORY: Debug level
          - Data operation logging:
              - Log ALL CRUD operations
              - Log query parameters
              - Log data transformations
              - Log validation results
              - Log error details
              - FORBIDDEN: Logging secrets

  - Phase 3: Performance and Quality Remediation
      - MANDATORY: Fix ALL performance issues:
          - Algorithm optimization:
              - Replace ALL inefficient algorithms
              - Optimize ALL database queries
              - Add caching where needed
              - Implement connection pooling
              - Enable query optimization
              - MANDATORY: Log execution times
          - Resource optimization:
              - Fix ALL memory leaks
              - Optimize ALL I/O operations
              - Reduce ALL network calls
              - Batch ALL bulk operations
              - Stream large datasets
              - DOUBLE-CHECK: Resource usage
          - Performance logging:
              - Log ALL operation durations
              - Log resource consumption
              - Log cache hit/miss rates
              - Log query execution plans
              - Log bottleneck indicators
              - MANDATORY: Metrics in logs
      - Code quality fixes:
          - Apply SOLID principles:
              - Fix ALL SRP violations
              - Enable proper extensions
              - Ensure substitutability
              - Segregate interfaces
              - Invert dependencies
              - MANDATORY: Clean architecture
          - Quality logging:
              - Log component interactions
              - Log state changes
              - Log error recovery
              - Log retry attempts
              - Log circuit breaker states
              - FORBIDDEN: Silent failures

  - Phase 4: Functional Defect Remediation
      - MANDATORY: Fix ALL functional issues:
          - Business logic fixes:
              - Correct ALL calculations
              - Fix ALL workflows
              - Repair ALL integrations
              - Update ALL validations
              - Fix ALL edge cases
              - MANDATORY: Log ALL logic
          - Data handling fixes:
              - Fix ALL data corruption
              - Correct ALL transformations
              - Repair ALL mappings
              - Fix ALL serialization
              - Handle ALL nulls/undefined
              - DOUBLE-CHECK: Data integrity
          - Functional logging:
              - Log ALL business operations
              - Log decision points
              - Log calculation inputs/outputs
              - Log transformation steps
              - Log validation outcomes
              - MANDATORY: Trace ALL flows

  - Phase 5: Continuous Validation and Deployment
      - MANDATORY: Validate after EVERY atomic commit:
          - Commit and build process:
              - Make atomic commit
              - Trigger automatic build
              - Run ALL linters
              - Check build success
              - Generate artifacts
              - MANDATORY: No build failures
          - Deployment validation:
              - Deploy to test environment
              - Wait for startup completion
              - Check health endpoints
              - Verify ALL services up
              - Monitor startup logs
              - FORBIDDEN: Skipping deployment
          - Log validation process:
              - Stream container logs
              - Check for ERROR levels
              - Verify debug output present
              - Monitor performance logs
              - Check security logs
              - MANDATORY: No critical errors
      - log checking:
          - Container log analysis:
              - Check application logs
              - Review system logs
              - Monitor service logs
              - Analyze error patterns
              - Verify log completeness
              - DOUBLE-CHECK: All clear
          - Functional verification:
              - Test fixed functionality
              - Verify API responses
              - Check integrations
              - Monitor metrics
              - Validate performance
              - MANDATORY: All working

  - Phase 6: Cleanup and Final Validation
      - MANDATORY: Clean ALL transient artifacts:
          - Delete temporary files:
              - Remove debug scripts
              - Delete test configs
              - Clean temp data
              - Remove experiments
              - Delete scratch files
              - MANDATORY: Pristine repo
          - Repository hygiene:
              - Update .gitignore
              - Clean build artifacts
              - Remove old logs
              - Delete cache files
              - Prune containers
              - DOUBLE-CHECK: No junk
      - Final validation:
          - Full system check:
              - All features working
              - All APIs responding
              - All integrations connected
              - All metrics normal
              - All logs clean
              - MANDATORY: 100% operational
          - Documentation updates:
              - Update fix documentation
              - Log configuration changes
              - Document new logging
              - Update runbooks
              - Note monitoring setup
              - FORBIDDEN: External docs

remediation_patterns:
  security_fixes:
    authentication_fix:
      issue: "Weak authentication"
      fix: "Implement strong auth with MFA"
      logging: "Log all auth events at DEBUG"
      validation: "Deploy and verify auth works"
    
    injection_fix:
      issue: "SQL/Command injection"
      fix: "Parameterize queries, validate input"
      logging: "Log all queries and parameters"
      validation: "Test with malicious input"
      
  performance_fixes:
    query_optimization:
      issue: "Slow database queries"
      fix: "Add indexes, optimize joins"
      logging: "Log query plans and durations"
      validation: "Verify query performance"
    
    caching_implementation:
      issue: "Repeated expensive operations"
      fix: "Implement caching layer"
      logging: "Log cache operations and hit rates"
      validation: "Monitor cache effectiveness"

validation_matrices:
  remediation_progress_matrix: |
    | Issue ID | Type | Severity | Fixed | Deployed | Logs OK | Operational | Status |
    |----------|------|----------|-------|----------|---------|-------------|--------|
    | SEC-001 | Auth | CRITICAL |  |  |  |  | COMPLETE |
  
  deployment_validation_matrix: |
    | Commit | Built | Deployed | Health OK | Logs Clean | Functional | Status |
    |--------|-------|----------|-----------|------------|------------|--------|
    | abc123 |  |  |  |  |  | VALID |
  
  logging_coverage_matrix: |
    | Component | Debug Logs | Error Handling | Performance | Security | Status |
    |-----------|------------|----------------|-------------|----------|--------|
    | Auth API |  |  |  |  | COMPLETE |

constraints:
  - MANDATORY: ALL critical issues MUST be fixed
  - MANDATORY: ALL fixes MUST follow SOLID/DRY/KISS
  - MANDATORY: ALL code MUST have debug logging
  - MANDATORY: ALL commits MUST be atomic
  - MANDATORY: MUST rebuild after EVERY commit
  - MANDATORY: MUST deploy after EVERY build
  - MANDATORY: MUST check logs after EVERY deploy
  - MANDATORY: ALL transient files MUST be deleted
  - MANDATORY: App MUST stay operational
  - MANDATORY: ALWAYS fix existing code in-place
  - MANDATORY: NEVER create duplicate files or copies
  - FORBIDDEN: Creating ANY test code
  - FORBIDDEN: Writing external documentation
  - FORBIDDEN: Skipping deployment validation
  - FORBIDDEN: Ignoring log errors
  - FORBIDDEN: Leaving debug/temp files
  - FORBIDDEN: Breaking functionality
  - FORBIDDEN: Creating duplicate code blocks/files
  - FORBIDDEN: Making backup copies of files
  - FORBIDDEN: Creating alternative implementations

output_format:
  jupyter_structure:
    - "01_Remediation_Plan.ipynb":
        - Issue inventory
        - Fix priorities
        - Deployment strategy
        - Validation approach
        - Success criteria
    
    - "02_Security_Remediation.ipynb":
        - Vulnerability fixes
        - Auth improvements
        - Encryption added
        - Logging implemented
        - Deployment results
    
    - "03_Performance_Remediation.ipynb":
        - Algorithm optimizations
        - Query improvements
        - Caching added
        - Resource optimization
        - Performance validation
    
    - "04_Quality_Remediation.ipynb":
        - SOLID principle fixes
        - Code improvements
        - Debug logging added
        - Refactoring done
        - Quality metrics
    
    - "05_Deployment_Log.ipynb":
        - Build records
        - Deploy history
        - Health checks
        - Log analysis
        - Validation results
    
    - "06_Operational_Verification.ipynb":
        - Feature testing
        - API validation
        - Integration checks
        - Performance metrics
        - System status

validation_criteria:
  issue_resolution: "MANDATORY - 100% critical issues fixed"
  code_quality: "MANDATORY - SOLID/DRY/KISS compliance"
  logging_coverage: "MANDATORY - Debug logging everywhere"
  deployment_success: "MANDATORY - All deploys successful"
  log_validation: "MANDATORY - No errors in logs"
  operational_status: "MANDATORY - App fully functional"
  git_practices: "MANDATORY - Atomic commits on branches"
  codebase_hygiene: "MANDATORY - No transient files"

final_deliverables:
  - Remediation_Complete.ipynb (all fixes documented)
  - Security_Fixes_Applied.ipynb (vulnerabilities resolved)
  - Performance_Improvements.ipynb (optimizations done)
  - Debug_Logging_Added.ipynb (comprehensive logging)
  - Deployment_History.ipynb (all deployments logged)
  - Log_Validation_Report.ipynb (all logs verified)
  - Operational_Certificate.ipynb (app fully functional)
  - Clean_Repository.ipynb (no transient files)

# Execution Command
usage: |
  /code-remediation                    # Fix all critical issues
  /code-remediation "security"         # Focus on security fixes
  /code-remediation "performance"      # Focus on performance

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST fix ALL critical issues
  - MUST add debug logging everywhere
  - MUST use atomic commits
  - MUST rebuild after EVERY commit
  - MUST deploy after EVERY build
  - MUST check logs after EVERY deploy
  - MUST delete ALL transient files
  - MUST keep app operational
  - MUST fix existing code in-place
  - MUST maintain pristine codebase
  
  STRICTLY FORBIDDEN:
  - NO test code creation
  - NO external documentation
  - NO skipping deployments
  - NO ignoring log errors
  - NO silent failures
  - NO debug code in production
  - NO breaking changes
  - NO incomplete fixes
  - NO duplicate files EVER
  - NO backup copies EVER
  - NO alternative versions EVER
  - NO file_fixed.py or fix_file.py
  
  CODEBASE HYGIENE RULES:
  - ALWAYS modify existing files
  - FORBIDDEN: create duplicates
  - FORBIDDEN: create backups
  - FORBIDDEN: create alternatives
  - FIX in-place ONLY
  - DELETE transient files
  - MAINTAIN clean repository
  
  VALIDATION WORKFLOW:
  - COMMIT  BUILD  DEPLOY  CHECK LOGS
  - If logs show errors  FIX  REPEAT
  - If app not working  ROLLBACK  FIX
  - If performance degraded  OPTIMIZE
  - ALWAYS verify full functionality