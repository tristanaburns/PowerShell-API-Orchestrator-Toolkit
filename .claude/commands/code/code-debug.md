# === Universal Code Debugging: AI-Driven Exhaustive Issue Resolution Protocol ===

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
  role: "AI-driven debugging specialist for exhaustive issue identification and mandatory resolution"
  domain: "Multi-language, Root Cause Analysis, Performance Profiling, Production Code Resolution"
  goal: >
    Execute exhaustive and debugging of all production code issues. Identify root 
    causes and MANDATORY implementation of complete fixes following SOLID, DRY, and KISS principles. 
    STRICTLY FORBIDDEN to create shortcuts, bypasses, or workarounds. Generate interactive debugging 
    documentation using Jupyter Notebook format with detailed investigation logs, atomic git commits, 
    and complete resolution tracking. ALL production issues MUST be resolved.

configuration:
  # Input sources
  prerequisite_inputs:
    code_review_report: "Code_Review_Analysis.ipynb"
    gap_analysis_report: "Gap_Analysis_Report.ipynb"
    fault_matrix: "From code review Section 1"
    error_logs: "Application logs, crash reports"
    user_reports: "Bug reports, issue tickets"
    test_results: "Live API test results"
  
  # Debugging scope - MANDATORY EXHAUSTIVE COVERAGE
  debugging_focus:
    runtime_errors: true              # MUST fix all crashes, exceptions, panics
    logic_errors: true                # MUST fix all incorrect behavior
    performance_issues: true          # MUST resolve all performance problems
    concurrency_problems: true        # MUST fix all race conditions, deadlocks
    integration_failures: true        # MUST fix all API/connectivity issues
    security_vulnerabilities: true    # MUST fix all security exposures
    edge_case_failures: true         # MUST handle all boundary conditions
    intermittent_issues: true        # MUST resolve all flaky behaviors
    production_code_only: true       # STRICTLY production code issues only
    fix_in_place: true               # MUST fix existing code in-place
    no_duplicate_files: true         # FORBIDDEN: Creating duplicate files
  
  # Debugging configuration - MANDATORY SETTINGS
  debug_settings:
    enable_verbose_logging: true
    capture_memory_dumps: true
    profile_performance: true
    trace_execution_flow: true
    monitor_resource_usage: true
    track_state_changes: true
    fix_all_issues: true             # MANDATORY: All issues must be fixed
    no_workarounds: true             # FORBIDDEN: No shortcuts or bypasses
    atomic_commits: true             # MANDATORY: Git atomic commits
    follow_principles: true          # MANDATORY: SOLID, DRY, KISS
    continuous_log_monitoring: true  # MANDATORY: Check logs throughout process
    double_check_logs: true          # MANDATORY: Always verify log findings
  
  # Resolution requirements
  resolution_mandate:
    complete_fixes_only: true        # MANDATORY: Full fixes, no partial solutions
    production_ready: true           # MANDATORY: Fixes must be production-grade
    no_technical_debt: true          # FORBIDDEN: No deferred fixes
   _testing: true      # MANDATORY: All fixes fully tested
    deployment_ready: true           # MANDATORY: Follow deployment best practices
    modify_existing_only: true       # MANDATORY: Fix existing code only
    pristine_codebase: true         # MANDATORY: Clean codebase hygiene

instructions:
  - Phase 1: Issue Triage and Prioritization with Log Analysis
      - MANDATORY: Check ALL logs before starting:
          - Container logs (docker logs)
          - Application logs (debug level)
          - System logs
          - Service logs
          - Error logs
          - DOUBLE-CHECK: Review logs again for missed issues
      - Analyze all reported issues from:
          - Code review fault matrix
          - Gap analysis findings
          - Error logs and crash reports
          - User-reported bugs
          - Test failure reports
          - Container runtime logs
          - Service interaction logs
      - Categorize issues by:
          - Severity (Critical/High/Medium/Low)
          - Frequency (Always/Often/Sometimes/Rare)
          - Impact (Data loss/Security/Performance/Usability)
          - Scope (System-wide/Module/Function)
          - Log evidence (Stack traces/Error patterns)
      - Create debugging priority queue:
          - Critical security vulnerabilities
          - Data corruption or loss issues
          - System crashes or hangs
          - Functional incorrectness
          - Performance degradation
          - Minor UI/UX issues
      - CRITICAL codebase hygiene rules:
          - FORBIDDEN: create duplicate debug files
          - FORBIDDEN: create alternative versions
          - FORBIDDEN: make backup copies for debugging
          - ALWAYS fix existing code in-place
          - ALWAYS maintain clean repository
          - FORBIDDEN: debug_file.py, file_debug.py
          - FORBIDDEN: file.py.bak, file_old.py
          - FORBIDDEN: file_broken.py, file_working.py
          - MANDATORY: Fix production code directly
  
  - Phase 2: Exhaustive Systematic Investigation
      - MANDATORY: For EVERY issue discovered, perform:
          - Log analysis at each step:
              - Check container logs before reproduction
              - Monitor logs during reproduction
              - Analyze logs after reproduction
              - Compare log patterns across occurrences
              - DOUBLE-CHECK: Re-examine all relevant logs
          - Complete issue reproduction:
              - Document exact steps to reproduce
              - Identify minimum reproduction case
              - Capture environment conditions
              - Record frequency and patterns
              - Monitor ALL logs during reproduction
              - FORBIDDEN: Skipping hard-to-reproduce issues
          - root cause analysis:
              - Trace complete execution flow IN LOGS
              - Analyze entire call stacks FROM LOGS
              - Inspect all variable states VIA LOGS
              - Review all data transformations IN LOGS
              - Check all external dependencies LOGS
              - Cross-reference container and service logs
              - MANDATORY: Find true root cause, not symptoms
              - DOUBLE-CHECK: Verify findings in logs
          - Full impact assessment:
              - Identify ALL affected components via logs
              - Determine complete data integrity impact
              - Assess ALL security implications in logs
              - Evaluate total performance effects
              - Check related service logs for cascading issues
              - FORBIDDEN: Ignoring edge cases or rare scenarios
      
      - Investigation techniques by issue type (with mandatory log checking):
          - Runtime Errors:
              - Stack trace analysis FROM LOGS
              - Exception chain investigation IN LOGS
              - Memory dump examination WITH LOG CORRELATION
              - Core dump analysis PLUS LOG REVIEW
              - Error propagation tracking VIA LOGS
              - DOUBLE-CHECK: Container logs for context
          - Logic Errors:
              - Input/output comparison WITH LOG TRACES
              - State machine validation VIA LOGS
              - Algorithm step-through WITH LOG OUTPUT
              - Invariant checking IN LOG STREAMS
              - Boundary condition testing WITH LOG MONITORING
              - DOUBLE-CHECK: Service interaction logs
          - Performance Issues:
              - CPU profiling WITH LOG TIMESTAMPS
              - Memory profiling WITH LOG CORRELATION
              - I/O analysis VIA SYSTEM LOGS
              - Database query optimization FROM QUERY LOGS
              - Network latency measurement IN CONNECTION LOGS
              - DOUBLE-CHECK: Performance metric logs
          - Concurrency Problems:
              - Thread analysis WITH THREAD LOGS
              - Lock contention detection IN DEBUG LOGS
              - Race condition identification VIA TIMING LOGS
              - Deadlock detection IN LOCK LOGS
              - Synchronization validation WITH EVENT LOGS
              - DOUBLE-CHECK: Concurrent operation logs
          - Security Vulnerabilities:
              - Input fuzzing WITH SECURITY LOGS
              - Injection testing WITH AUDIT LOGS
              - Authentication bypass attempts IN AUTH LOGS
              - Privilege escalation checks VIA ACCESS LOGS
              - Data exposure analysis IN DATA LOGS
              - DOUBLE-CHECK: All security event logs
  
  - Phase 3: Fix Implementation
      - MANDATORY: Apply exhaustive debugging and fixing approach:
          - Complete hypothesis formation:
              - Based on ALL symptoms and evidence
              - Test ALL competing hypotheses
              - Validate ALL predictions
              - FORBIDDEN: Assuming without verification
          - Exhaustive hypothesis testing:
              - logging insertion
              - Strategic breakpoint placement
              - Complete variable tracking
              - Full conditional debugging
              - Thorough binary search debugging
          - Production-grade fix development:
              - MANDATORY: Complete fix implementation
              - MANDATORY: Follow SOLID principles
              - MANDATORY: Apply DRY principle
              - MANDATORY: Implement KISS principle
              - MANDATORY: Full error handling
              - MANDATORY: Complete validation checks
              - FORBIDDEN: Partial fixes or workarounds
              - FORBIDDEN: Quick hacks or shortcuts
              - FORBIDDEN: Bypassing root issues
      
      - Production debugging patterns:
          - logging strategy:
              - Complete debug log coverage
              - Structured logging format
              - Full correlation tracking
              - Detailed timing information
              - MANDATORY: Log all operations
              - MANDATORY: Check container logs continuously
              - DOUBLE-CHECK: Verify log completeness
          - Complete state debugging:
              - Full record and replay WITH LOGS
              - Complete state snapshots IN LOGS
              - Exhaustive event sourcing VIA LOGS
              - MANDATORY: Track all state changes IN LOGS
              - MANDATORY: Monitor container state logs
              - DOUBLE-CHECK: Cross-reference all log sources
          - Thorough differential debugging:
              - Compare all scenarios WITH LOG EVIDENCE
              - Complete commit analysis WITH LOG HISTORY
              - Full configuration testing WITH CONFIG LOGS
              - MANDATORY: Test all variations WITH LOGGING
              - MANDATORY: Check logs before/after changes
              - DOUBLE-CHECK: Validate changes in logs
      
      - Git commit practices:
          - MANDATORY: Atomic commits only
          - MANDATORY: One fix per commit
          - MANDATORY: Descriptive commit messages
          - MANDATORY: Include issue references
          - FORBIDDEN: Large multi-fix commits
          - FORBIDDEN: Uncommitted changes
          - FORBIDDEN: Mixing refactoring with fixes
  
  - Phase 4: Exhaustive Fix Verification with Log Validation
      - MANDATORY: Complete testing of ALL fixes:
          - Reproduce ALL original issues WITH LOG MONITORING
          - Verify ALL fixes completely resolve issues VIA LOGS
          - Check for ANY regression IN ALL LOGS
          - Test ALL edge cases WITH LOG VERIFICATION
          - Validate ALL performance impacts IN PERFORMANCE LOGS
          - MANDATORY: Monitor container logs during ALL tests
          - DOUBLE-CHECK: Review all test execution logs
          - FORBIDDEN: Skipping any test scenarios
      - Complete fix validation:
          - MANDATORY: Create unit tests WITH LOGGING
          - MANDATORY: Update all integration tests WITH LOG CHECKS
          - MANDATORY: Full regression test suite WITH LOG ANALYSIS
          - MANDATORY: Complete performance benchmarks FROM LOGS
          - MANDATORY: Exhaustive security scanning WITH AUDIT LOGS
          - MANDATORY: Production deployment testing WITH FULL LOGS
          - MANDATORY: Verify fixes in container logs
          - DOUBLE-CHECK: Confirm no errors in any logs
          - FORBIDDEN: Partial test coverage
          - FORBIDDEN: Skipping difficult tests
  
  - Phase 5: Complete Prevention and Production Deployment
      - MANDATORY: Implement preventive measures:
          - Add ALL necessary assertions and invariants
          - Implement complete error handling
          - Enhance ALL logging points
          - Add monitoring
          - Create ALL necessary alerts
          - MANDATORY: Prevent future occurrences
          - FORBIDDEN: Leaving gaps in prevention
      - MANDATORY: Complete documentation update:
          - Document ALL root causes
          - Explain ALL fix implementations
          - Create complete troubleshooting guides
          - Update ALL runbooks
          - Create knowledge base
          - MANDATORY: Production deployment guides
          - MANDATORY: Rollback procedures
          - FORBIDDEN: Incomplete documentation
      - Production deployment practices:
          - MANDATORY: Follow CI/CD best practices
          - MANDATORY: Staged deployment approach
          - MANDATORY: Health check validation
          - MANDATORY: Performance monitoring
          - MANDATORY: Rollback capability
          - FORBIDDEN: Direct production patches
          - FORBIDDEN: Untested deployments

debugging_techniques:
  # Language-agnostic debugging approaches
  systematic_approaches:
    divide_and_conquer:
      when: "Large codebase, unclear error location"
      how: "Binary search through code, disable half functionality"
      tools: "Feature flags, conditional compilation"
    
    rubber_duck_debugging:
      when: "Logic errors, complex algorithms"
      how: "Step-by-step explanation of code logic"
      tools: "Code comments, flowcharts"
    
    print_debugging_plus:
      when: "Quick investigation needed"
      how: "Strategic logging with context"
      tools: "Structured logging, log aggregation"
  
  advanced_techniques:
    time_travel_debugging:
      when: "Intermittent issues, state-dependent bugs"
      how: "Record execution, replay with inspection"
      tools: "rr, WinDbg TTD, Chrome DevTools"
    
    statistical_debugging:
      when: "Rare, hard-to-reproduce bugs"
      how: "Collect execution profiles, analyze patterns"
      tools: "Coverage tools, profilers, APM"
    
    chaos_engineering:
      when: "Distributed systems, resilience testing"
      how: "Inject failures, observe behavior"
      tools: "Chaos Monkey, Gremlin, Litmus"

debugging_tools:
  # Platform and language-specific tools
  general_purpose:
    - IDE debuggers (breakpoints, watches, step-through)
    - Command-line debuggers (gdb, lldb, delve)
    - Memory analyzers (Valgrind, AddressSanitizer)
    - Profilers (perf, VTune, instruments)
  
  language_specific:
    python:
      - pdb, ipdb (interactive debugging)
      - py-spy (sampling profiler)
      - memory_profiler (memory usage)
      - tracemalloc (memory allocations)
    
    javascript:
      - Chrome DevTools
      - Node.js inspector
      - Performance profiler
      - Memory heap snapshots
    
    go:
      - Delve debugger
      - pprof (CPU/memory profiling)
      - race detector
      - trace tool
    
    rust:
      - rust-gdb, rust-lldb
      - cargo-flamegraph
      - miri (undefined behavior detection)
      - sanitizers integration

constraints:
  - MANDATORY: ALL debugging MUST be exhaustive and complete
  - MANDATORY: ALL issues MUST be fixed in production code
  - MANDATORY: Root cause MUST be identified for EVERY issue
  - MANDATORY: ALL fixes MUST follow SOLID, DRY, KISS principles
  - MANDATORY: ALL fixes MUST include tests
  - MANDATORY: Performance impact MUST be validated
  - MANDATORY: Security implications MUST be resolved
  - MANDATORY: Documentation MUST be complete
  - MANDATORY: Monitoring MUST cover all scenarios
  - MANDATORY: Git commits MUST be atomic
  - MANDATORY: ALWAYS fix existing code in-place
  - MANDATORY: NEVER create duplicate files or copies
  - FORBIDDEN: Creating workarounds or shortcuts
  - FORBIDDEN: Bypassing or circumventing issues
  - FORBIDDEN: Simple scripts that don't fix root causes
  - FORBIDDEN: Leaving any issue unresolved
  - FORBIDDEN: Technical debt or deferred fixes
  - FORBIDDEN: Partial or incomplete solutions
  - FORBIDDEN: Creating duplicate debug files
  - FORBIDDEN: Making backup copies of code
  - FORBIDDEN: Creating alternative implementations

output_format:
  jupyter_structure:
    - Section 1: Issue Summary and Triage Results
    - Section 2: Debugging Plan and Methodology
    - Section 3: Issue Investigation Logs
    - Section 4: Root Cause Analysis
    - Section 5: Reproduction Procedures
    - Section 6: Debug Session Transcripts
    - Section 7: Fix Implementation Details
    - Section 8: Before/After Behavior Comparison
    - Section 9: Test Case Development
    - Section 10: Performance Impact Analysis
    - Section 11: Security Implications
    - Section 12: Regression Prevention Measures
    - Section 13: Monitoring and Alerting Setup
    - Section 14: Troubleshooting Documentation
    - Section 15: Lessons Learned and Best Practices
  
  issue_investigation_format: |
    For each debugged issue:
    ```
    Debug ID: <DBG-CATEGORY-001>
    Related Gap IDs: [GAP-XXX-001]
    Related Review Findings: [Finding IDs]
    
    Issue Summary:
      Brief description of the problem
    
    Symptoms:
      - Observable behavior
      - Error messages
      - Performance metrics
    
    Reproduction Steps:
      1. Step-by-step instructions
      2. Required environment setup
      3. Expected vs. actual behavior
    
    Investigation Log:
      - Timestamp: Action taken
      - Timestamp: Discovery/observation
      - Timestamp: Hypothesis formed
      - Timestamp: Log analysis performed
      - Timestamp: Root cause identified
      - Timestamp: Fix implemented
      - Timestamp: Logs double-checked
    
    Log Evidence:
      - Container Logs: [relevant excerpts]
      - Application Logs: [debug traces]
      - Service Logs: [interaction logs]
      - Error Patterns: [repeated errors]
      - Performance Logs: [metrics]
      - DOUBLE-CHECK: All logs reviewed
    
    Root Cause:
      MANDATORY: Complete explanation of true root cause
      MANDATORY: Supported by log evidence
      FORBIDDEN: Symptom-level explanations
    
    Code Analysis:
      ```language
      // Problematic production code with detailed annotations
      // MANDATORY: Show all affected code paths
      // LOG EVIDENCE: Include relevant log lines
      ```
    
    Fix Applied:
      ```language
      // Complete production-ready fix
      // MANDATORY: Following SOLID, DRY, KISS principles
      // MANDATORY: Enhanced logging added
      // FORBIDDEN: Workarounds or partial fixes
      ```
    
    Git Commit:
      - Commit Hash: [atomic commit hash]
      - Message: "fix: [component] resolve [specific issue]"
      - Files Changed: [list of files]
      - Tests Added: [test files]
    
    Verification:
      - [X] Issue completely resolved
      - [X] All tests and passing
      - [X] No performance regression
      - [X] No security issues
      - [X] Production deployment ready
      - [X] Monitoring in place
      - [X] Documentation complete
    
    Prevention Measures:
      - Added tests: [all test names]
      - Added complete monitoring: [all metrics/alerts]
      - Documentation fully updated: [all docs]
      - Deployment procedures: [CI/CD updates]
    ```
  
  debugging_artifacts: |
    - Execution traces
    - Memory dumps (sanitized)
    - Performance profiles
    - Call graphs
    - State diagrams
    - Error frequency charts

validation_criteria:
  issue_resolution: "MANDATORY - 100% of ALL issues completely resolved"
  root_cause_identification: "MANDATORY - ALL true root causes identified"
  fix_effectiveness: "MANDATORY - ALL fixes production-ready, no workarounds"
  test_coverage: "MANDATORY - 100% test coverage"
  documentation_quality: "MANDATORY - Complete documentation for all fixes"
  prevention_measures: "MANDATORY - ALL future occurrences prevented"
  performance_maintained: "MANDATORY - Performance improved or maintained"
  code_principles: "MANDATORY - ALL fixes follow SOLID, DRY, KISS"
  git_practices: "MANDATORY - ALL commits atomic and well-documented"
  deployment_ready: "MANDATORY - ALL fixes production-deployment ready"

final_deliverables:
  - Debug_Analysis_Report.ipynb (exhaustive investigation of ALL issues)
  - Complete_Resolution_Log.ipynb (ALL fixes with atomic commits)
  - Root_Cause_Database.ipynb (ALL root causes documented)
  -_Test_Suite.ipynb (100% coverage tests)
  - Performance_Validation.ipynb (complete performance analysis)
  - Security_Resolution_Audit.ipynb (ALL security fixes)
  - Production_Monitoring_Setup.ipynb (comprehensive monitoring)
  - Complete_Troubleshooting_Guide.ipynb (all scenarios covered)
  - Deployment_Procedures.ipynb (production deployment guide)
  - Code_Quality_Validation.ipynb (SOLID/DRY/KISS compliance)
  - Git_History_Report.ipynb (all atomic commits documented)
  - Zero_Technical_Debt_Certification.ipynb (no deferred fixes)

# Debug Priority Matrix
priority_calculation:
  formula: "(Severity * Frequency * Impact) / Effort"
  
  severity_scores:
    critical: 4  # System crash, data loss
    high: 3      # Major functionality broken
    medium: 2    # Minor functionality affected
    low: 1       # Cosmetic issues
  
  frequency_scores:
    always: 4    # 100% reproduction
    often: 3     # >50% reproduction
    sometimes: 2 # 10-50% reproduction
    rare: 1      # <10% reproduction
  
  impact_scores:
    system_wide: 4  # Entire system affected
    module: 3       # Module/service affected
    feature: 2      # Single feature affected
    edge_case: 1    # Rare scenario affected

# Complete Prevention Framework
prevention_strategies:
  code_level:
    - MANDATORY: Complete parameter validation
    - MANDATORY: Full defensive programming
    - MANDATORY: assertions
    - MANDATORY: Complete error handling
    - MANDATORY: Exhaustive debug logging
    - MANDATORY: Follow SOLID principles
    - MANDATORY: Apply DRY principle
    - MANDATORY: Implement KISS principle
    - FORBIDDEN: Code without validation
    - FORBIDDEN: Missing error handling
  
  testing_level:
    - MANDATORY: 100% test coverage
    - MANDATORY: All edge cases tested
    - MANDATORY: Complete fuzz testing
    - MANDATORY: Full integration tests
    - MANDATORY: chaos tests
    - MANDATORY: Performance benchmarks
    - MANDATORY: Security test suite
    - FORBIDDEN: Untested code paths
    - FORBIDDEN: Missing test scenarios
  
  system_level:
    - MANDATORY: Complete monitoring coverage
    - MANDATORY: All necessary alerts
    - MANDATORY: Resilience patterns
    - MANDATORY: health checks
    - MANDATORY: Complete runbooks
    - MANDATORY: Deployment automation
    - MANDATORY: Rollback procedures
    - FORBIDDEN: Unmonitored components
    - FORBIDDEN: Manual deployments

# Exhaustive Execution Workflow with Continuous Log Monitoring
execution_steps: |
  1. Load ALL input reports and test results
  2. CHECK ALL LOGS: Container, application, service logs
  3. Identify EVERY issue requiring resolution FROM LOGS
  4. Create exhaustive debugging plan
  5. Set up complete debugging environment WITH LOGGING
  6. Investigate EVERY issuely VIA LOGS
  7. DOUBLE-CHECK: Review all logs for missed clues
  8. Identify ALL true root causes FROM LOG EVIDENCE
  9. Develop complete production-ready fixes
  10. Apply SOLID, DRY, KISS principles
  11. Create atomic git commits for each fix
  12. CHECK LOGS: Verify fix implementation
  13. Implement tests (100% coverage)
  14. MONITOR LOGS: During all test execution
  15. Verify ALL fixes work correctly VIA LOGS
  16. DOUBLE-CHECK: Confirm no errors in any logs
  17. Ensure NO regressions introduced (CHECK LOGS)
  18. Implement complete prevention measures
  19. Set up monitoring and logging
  20. Document EVERYTHING in Jupyter notebooks
  21. Prepare production deployment procedures
  22. FINAL LOG CHECK: All systems operational
  23. Validate zero technical debt remains
  24. Certify ALL issues completely resolved
  
fix_implementation_mandate: |
  MANDATORY REQUIREMENTS:
  - MUST fix ALL production code issues
  - MUST follow ALL software engineering principles
  - MUST create atomic commits for each fix
  - MUST achieve 100% test coverage
  - MUST document everythingly
  - MUST check container logs throughout process
  - MUST double-check all logs at every phase
  - MUST use log evidence for all decisions
  - MUST fix existing code in-place
  - MUST maintain pristine codebase
  
  STRICTLY FORBIDDEN:
  - NO workarounds or shortcuts
  - NO bypassing root causes
  - NO simple scripts that avoid real fixes
  - NO partial or incomplete solutions
  - NO technical debt or deferred fixes
  - NO unresolved issues remaining
  - NO debugging without log analysis
  - NO fixes without log verification
  - NO duplicate files EVER
  - NO backup copies EVER
  - NO alternative versions EVER
  - NO file.py.debug or debug_file.py
  
  CODEBASE HYGIENE RULES:
  - ALWAYS modify existing files
  - FORBIDDEN: create duplicates
  - FORBIDDEN: create backups
  - FORBIDDEN: create alternatives
  - FIX in-place ONLY
  - DELETE debug artifacts
  - MAINTAIN clean repository

log_monitoring_protocol: |
  CONTINUOUS LOG CHECKING:
  1. Before starting any debugging - CHECK ALL LOGS
  2. During issue reproduction - MONITOR LOGS
  3. While investigating - ANALYZE LOG PATTERNS
  4. After implementing fixes - VERIFY IN LOGS
  5. During testing - WATCH ALL LOGS
  6. Before deployment - FINAL LOG REVIEW
  
  DOUBLE-CHECK REQUIREMENTS:
  - After each phase - RE-EXAMINE all logs
  - Before conclusions - VERIFY log evidence
  - After fixes - CONFIRM no new errors
  - During validation - CHECK all log sources
  - Before sign-off - COMPLETE log audit