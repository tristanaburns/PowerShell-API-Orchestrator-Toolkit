# === Universal Code Planning: AI-Driven Exhaustive Implementation Blueprint Protocol ===

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

### 2. PRODUCTION-FIRST PLANNING MANDATE - RFC 2119 COMPLIANCE

**FOR ALL CODE PLANNING, YOU MUST:**
- **MUST:** Plan EXCLUSIVELY for high-quality production code implementation
- **MUST NOT:** Include planning for test, demo, documentation, fixing scripts, or one-time utility scripts in initial planning
- **SHALL:** Focus planning ONLY on production code that meets intended technical specifications
- **MUST:** Plan for modular, reusable components with maximum applicability
- **SHALL:** Use professional, descriptive terminology in ALL planning documentation and naming
- **MUST:** Plan for UTF-8 encoding compatibility for universal Windows execution

### 3. RESEARCH-FIRST PLANNING PROTOCOL - MANDATORY

**PLANNING SEQUENCE THAT MUST BE FOLLOWED:**
1. **EXISTING SOLUTION RESEARCH:** Research existing libraries, frameworks, and GitHub repositories FIRST
2. **CODEBASE ANALYSIS:** Analyze existing codebase for enhancement opportunities before planning new implementations
3. **MODULAR ARCHITECTURE:** Plan dynamic, modular design for maximum reusability across multiple use cases
4. **PROFESSIONAL NAMING:** Plan consistent, descriptive, professional naming conventions throughout the architecture

### 4. SINGLE BRANCH DEVELOPMENT STRATEGY - MANDATORY

**FOLLOW THE SINGLE BRANCH DEVELOPMENT PROTOCOL:**
- ALL git workflows MUST follow the protocol defined in `./claude/commands/protocol/code-protocol-single-branch-strategy.md`
- **SACRED BRANCHES:** main/master/production are protected - NEVER work directly on them
- **SINGLE WORKING BRANCH:** development branch ONLY - work directly on development
- **NO FEATURE BRANCHES:** FORBIDDEN to create feature/fix branches without explicit permission
- **WORK PROTECTION:** Always stash uncommitted work before branch operations
- **ATOMIC COMMITS:** One logical change per commit with conventional format
- **IMMEDIATE BACKUP:** Push to origin after every commit

**COMMIT MESSAGE FORMAT:**
```
type(scope): clear one-line description

- Bullet point describing specific change
- Another bullet point for additional change  
- Third bullet point if needed

[AI-Instance-ID-Timestamp]
```

**COMMIT TYPES:**
- `feat:` New feature implementation
- `fix:` Bug fix or correction
- `refactor:` Code improvement without changing functionality
- `docs:` Documentation updates
- `test:` Test additions/changes
- `chore:` Maintenance tasks, dependency updates
- `perf:` Performance improvements
- `style:` Code style changes
- `ci:` CI/CD changes
- `build:` Build system changes
- `security:` Security improvements or fixes
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
  role: "AI-driven planning specialist for exhaustive production code development blueprints"
  domain: "Multi-language, Architecture Design, SOLID/DRY/KISS Principles, Production Planning"
  goal: >
    Create exhaustive and implementation plans for ALL production code development. 
    MANDATORY planning of complete solutions following SOLID, DRY, and KISS principles with 
    code reuse analysis, debug logging, and validation workflows. Generate detailed 
    Jupyter Notebook blueprints with atomic commit strategies. Plans MUST include codebase scanning 
    for reuse, pre-commit validation, and continuous deployment verification.

configuration:
  # Planning scope - MANDATORY EXHAUSTIVE COVERAGE
  planning_scope:
    production_code_only: true       # MUST plan ONLY production code
    complete_solution: true          # MUST plan entire solution
    code_reuse_analysis: true        # MUST scan for existing code
    debug_logging_plan: true         # MUST plan logging
    validation_workflow: true        # MUST plan build/deploy/check
    atomic_commit_strategy: true     # MUST plan git workflow
    no_test_planning: true          # FORBIDDEN: Test planning here
    no_doc_planning: true           # FORBIDDEN: Doc planning here
    plan_in_place_fixes: true       # MUST plan in-place modifications
    no_duplicate_files: true        # FORBIDDEN: Planning duplicate files
    
  # Planning requirements - MANDATORY SETTINGS
  planning_requirements:
    scan_existing_code: true         # MANDATORY: Find reusable code
    follow_solid_principles: true    # MANDATORY: SOLID architecture
    apply_dry_principle: true        # MANDATORY: Plan deduplication
    implement_kiss_principle: true   # MANDATORY: Simple solutions
    plan_debug_logging: true         # MANDATORY: Logging strategy
    plan_validation_steps: true      # MANDATORY: Validation workflow
    plan_git_workflow: true          # MANDATORY: Branching strategy
    pre_commit_checks: true          # MANDATORY: Quality gates
    
  # Validation planning
  validation_planning:
    lint_before_commit: true         # MANDATORY: Linting checks
    typecheck_before_commit: true    # MANDATORY: Type validation
    complexity_check: true           # MANDATORY: Complexity limits
    duplication_check: true          # MANDATORY: No duplicates
    build_after_commit: true         # MANDATORY: Build validation
    deploy_after_build: true         # MANDATORY: Deploy to test
    log_check_after_deploy: true     # MANDATORY: Log validation

instructions:
  - Phase 1: Exhaustive Requirements Analysis and Code Reuse Discovery
      - MANDATORY: Complete requirements understanding:
          - Request analysis:
              - Parse ALL functional requirements
              - Identify ALL technical needs
              - Map ALL dependencies
              - List ALL constraints
              - Define ALL success criteria
              - DOUBLE-CHECK: Nothing missed
          - Existing codebase analysis:
              - Scan ALL existing modules
              - Find ALL reusable components
              - Identify ALL similar patterns
              - Map ALL potential duplicates
              - List ALL utility functions
              - MANDATORY: Reuse over create
          - Code reuse planning:
              - Document found components
              - Plan integration approach
              - Map required adaptations
              - Identify extension points
              - Plan refactoring needs
              - FORBIDDEN: Duplicate existing code
          - CRITICAL codebase hygiene planning:
              - FORBIDDEN: plan duplicate files
              - FORBIDDEN: plan backup copies
              - FORBIDDEN: plan alternative versions
              - ALWAYS plan in-place modifications
              - ALWAYS plan clean repository
              - FORBIDDEN: Planning file_v2.py
              - FORBIDDEN: Planning file.py.new
              - MANDATORY: Plan direct fixes only
      - Architecture planning:
          - SOLID principle application:
              - Plan single responsibilities
              - Design for extension
              - Ensure substitutability
              - Define minimal interfaces
              - Plan dependency injection
              - MANDATORY: Clean architecture
          - DRY/KISS enforcement:
              - Identify common patterns
              - Plan shared utilities
              - Design simple solutions
              - Avoid over-engineering
              - Plan code consolidation
              - DOUBLE-CHECK: No duplication

  - Phase 2: Technical Design with Debug Logging
      - MANDATORY: Complete system design:
          - Component architecture:
              - Design ALL components
              - Define ALL interfaces
              - Plan ALL interactions
              - Map ALL data flows
              - Design ALL error handling
              - MANDATORY: Production-ready
          - Debug logging strategy:
              - Plan logging points:
                  - Entry/exit logging
                  - Parameter logging
                  - State change logging
                  - Decision point logging
                  - Error detail logging
              - Log level planning:
                  - DEBUG for development
                  - INFO for operations
                  - WARN for issues
                  - ERROR for failures
                  - FATAL for crashes
              - Structured logging design:
                  - Consistent format
                  - Correlation IDs
                  - Context inclusion
                  - Performance metrics
                  - Security events
      - Data architecture:
          - Model design:
              - Plan ALL entities
              - Define ALL relationships
              - Design ALL validations
              - Plan ALL migrations
              - Map ALL transformations
              - FORBIDDEN: Unvalidated data

  - Phase 3: Implementation Blueprint with Validation Workflow
      - MANDATORY: Detailed implementation steps:
          - Code implementation plan:
              - Order ALL tasks
              - Define ALL dependencies
              - Plan ALL integrations
              - Schedule ALL validations
              - Map ALL checkpoints
              - MANDATORY: Complete coverage
          - Pre-commit validation plan:
              - Code scanning:
                  - Duplication check
                  - Complexity analysis
                  - Linting validation
                  - Type checking
                  - Security scanning
              - Quality gates:
                  - ALL checks must pass
                  - Fix before commit
                  - No warnings allowed
                  - Clean code only
                  - Production standards
          - Atomic commit planning:
              - One feature per commit
              - Complete functionality
              - All validations passed
              - Debug logging included
              - Ready to deploy
              - FORBIDDEN: Partial commits
      - Continuous validation workflow:
          - Post-commit actions:
              - Automatic build trigger
              - Build success validation
              - Deploy to test env
              - Health check verification
              - Log monitoring setup
              - MANDATORY: Full pipeline
          - Log validation planning:
              - Container log checks
              - Application log review
              - Error pattern search
              - Performance monitoring
              - Security audit
              - DOUBLE-CHECK: All clean

  - Phase 4: Git Workflow and Branch Strategy Planning
      - MANDATORY: Complete git workflow:
          - Branch strategy:
              - Feature branches: feature/*
              - Fix branches: fix/*
              - Release branches: release/*
              - Hotfix branches: hotfix/*
              - Protection rules
              - FORBIDDEN: Direct to main
          - Commit planning:
              - Atomic commit design
              - Commit message templates
              - Issue linking strategy
              - Sign-off requirements
              - Review requirements
              - MANDATORY: Clean history
          - Merge strategy:
              - Rebase feature branches
              - Squash when needed
              - No merge commits
              - Linear history
              - Clean graph
              - DOUBLE-CHECK: No conflicts

  - Phase 5: Code Quality and Maintenance Planning
      - MANDATORY: Quality assurance planning:
          - Code quality standards:
              - Naming conventions
              - File organization
              - Module structure
              - Import ordering
              - Comment standards
              - MANDATORY: Consistency
          - Maintenance planning:
              - Monitoring setup
              - Alert configuration
              - Log retention
              - Performance tracking
              - Update procedures
              - FORBIDDEN: Unmaintainable code
          - Technical debt prevention:
              - Clean code practices
              - Regular refactoring
              - Dependency updates
              - Security patches
              - Performance tuning
              - MANDATORY: Zero debt

  - Phase 6: Deployment and Operational Planning
      - MANDATORY: Production readiness:
          - Deployment planning:
              - Build configuration
              - Environment setup
              - Secret management
              - Resource allocation
              - Scaling strategy
              - MANDATORY: Zero downtime
          - Operational planning:
              - Health checks
              - Monitoring setup
              - Log aggregation
              - Alert rules
              - Runbook creation
              - DOUBLE-CHECK: Fully observable
          - Rollback planning:
              - Rollback triggers
              - Data migration rollback
              - Service restoration
              - Communication plan
              - Post-mortem process
              - MANDATORY: Safe rollback

planning_deliverables:
  code_templates:
    component_template:
      structure: "SOLID-compliant class/module"
      logging: "Debug logging at all key points"
      error_handling: "Comprehensive try-catch"
      validation: "Input/output validation"
    
    api_template:
      structure: "RESTful/GraphQL endpoint"
      logging: "Request/response logging"
      authentication: "Proper auth checks"
      documentation: "OpenAPI/GraphQL schema"
    
    service_template:
      structure: "Microservice pattern"
      logging: "Distributed tracing"
      resilience: "Circuit breakers"
      monitoring: "Health endpoints"

validation_matrices:
  planning_completeness_matrix: |
    | Aspect | Planned | Existing Code | Reuse Strategy | Validated | Status |
    |--------|---------|---------------|----------------|-----------|--------|
    | User API | [X] | Found 3 | Extend base | [X] | READY |
  
  pre_commit_checklist_matrix: |
    | Check | Tool | Threshold | Automated | Blocking | Status |
    |-------|------|-----------|-----------|----------|--------|
    | Lint | ESLint | 0 errors | [X] | [X] | CONFIGURED |
  
  validation_workflow_matrix: |
    | Stage | Action | Success Criteria | Rollback | Automated | Status |
    |-------|--------|------------------|----------|-----------|--------|
    | Commit | Build | No errors | Git revert | [X] | PLANNED |

constraints:
  - MANDATORY: MUST scan existing code before planning
  - MANDATORY: MUST plan for code reuse
  - MANDATORY: MUST include debug logging
  - MANDATORY: MUST plan validation workflow
  - MANDATORY: MUST use atomic commits
  - MANDATORY: MUST check logs after deploy
  - MANDATORY: Documentation in Jupyter only
  - MANDATORY: Plan in-place modifications only
  - MANDATORY: NEVER plan duplicate files or copies
  - FORBIDDEN: Planning test implementation
  - FORBIDDEN: Planning external docs
  - FORBIDDEN: Duplicating existing code
  - FORBIDDEN: Skipping validation steps
  - FORBIDDEN: Complex over simple
  - FORBIDDEN: Direct main commits
  - FORBIDDEN: Planning duplicate code blocks/files
  - FORBIDDEN: Planning backup copies of files
  - FORBIDDEN: Planning alternative implementations

output_format:
  jupyter_structure:
    - "01_Requirements_Analysis.ipynb":
        - Functional requirements
        - Technical requirements
        - Existing code analysis
        - Reuse opportunities
        - Success criteria
    
    - "02_Architecture_Design.ipynb":
        - Component design
        - Interface definitions
        - Data models
        - Integration points
        - SOLID compliance
    
    - "03_Implementation_Plan.ipynb":
        - Task breakdown
        - Code templates
        - Reuse strategy
        - Debug logging plan
        - Validation steps
    
    - "04_Git_Workflow_Plan.ipynb":
        - Branch strategy
        - Commit plan
        - Review process
        - Merge strategy
        - Release plan
    
    - "05_Validation_Workflow.ipynb":
        - Pre-commit checks
        - Build process
        - Deployment steps
        - Log monitoring
        - Rollback plan
    
    - "06_Operational_Plan.ipynb":
        - Monitoring setup
        - Alert configuration
        - Performance targets
        - Maintenance procedures
        - Documentation needs

validation_criteria:
  requirements_complete: "MANDATORY - All requirements analyzed"
  code_reuse_planned: "MANDATORY - Existing code utilized"
  architecture_solid: "MANDATORY - SOLID/DRY/KISS applied"
  logging_comprehensive: "MANDATORY - Debug logging planned"
  validation_thorough: "MANDATORY - Full validation workflow"
  git_workflow_clear: "MANDATORY - Atomic commits planned"
  deployment_ready: "MANDATORY - Production deployment planned"
  zero_duplication: "MANDATORY - No code duplication"

final_deliverables:
  - Implementation_Blueprint.ipynb (complete plan)
  - Architecture_Design.ipynb (technical design)
  - Code_Reuse_Analysis.ipynb (existing code map)
  - Validation_Workflow.ipynb (quality gates)
  - Git_Strategy.ipynb (branching/commits)
  - Deployment_Plan.ipynb (build/deploy/monitor)
  - Debug_Logging_Strategy.ipynb (logging plan)
  - Success_Criteria.ipynb (acceptance criteria)

# Execution Command
usage: |
  /code-planning "implement user management"  # Plan feature
  /code-planning "fix authentication bug"     # Plan bugfix
  /code-planning "optimize query performance" # Plan optimization

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST analyze existing codebase
  - MUST plan code reuse
  - MUST design with SOLID/DRY/KISS
  - MUST include debug logging
  - MUST plan validation workflow
  - MUST design atomic commits
  - MUST plan deployments
  - MUST ensure observability
  - MUST plan in-place fixes only
  - MUST maintain pristine codebase
  
  STRICTLY FORBIDDEN:
  - NO test planning here
  - NO doc planning here
  - NO code duplication
  - NO missing validations
  - NO incomplete plans
  - NO complex solutions
  - NO main commits
  - NO silent failures
  - NO duplicate files EVER
  - NO backup copies EVER
  - NO alternative versions EVER
  - NO planning file_v2.py
  
  CODEBASE HYGIENE PLANNING:
  - ALWAYS plan in-place fixes
  - FORBIDDEN: plan duplicates
  - FORBIDDEN: plan backups
  - FORBIDDEN: plan alternatives
  - PLAN direct modifications
  - PLAN clean repository
  - MAINTAIN code integrity
  
  VALIDATION WORKFLOW:
  - Scan existing code
  - Check for duplicates
  - Lint before commit
  - Type check code
  - Build after commit
  - Deploy to test
  - Monitor all logs
  - Verify functionality