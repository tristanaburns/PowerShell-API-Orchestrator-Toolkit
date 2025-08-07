# === Universal Code Implementation: AI-Driven Exhaustive Production Code Implementation Protocol ===

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

### 2. PRODUCTION-FIRST DEVELOPMENT MANDATE - RFC 2119 COMPLIANCE

**FOR ALL CODE IMPLEMENTATION, YOU MUST:**
- **MUST:** Create high-quality production code FIRST and ONLY
- **MUST NOT:** Waste time, tokens, or resources on test, demo, documentation, fixing scripts, one-time utility scripts
- **MUST:** Focus EXCLUSIVELY on production code that meets intended technical specifications
- **SHALL:** Create testing and demo code ONLY upon explicit specific instructions AFTER production code is 100% functional
- **MUST:** Use specific, descriptive, professional, universal terminology for ALL code elements
- **MUST NOT:** Use vague, useless, non-descriptive terminology for code blocks, variables, classes, methods, file names
- **SHALL:** Ensure Python code is universally executable by enforcing UTF-8 encoding setup for Windows environments

### 3. MODULAR REUSABILITY AND RESEARCH-FIRST PROTOCOL - MANDATORY

**BEFORE IMPLEMENTING ANY CODE, YOU MUST:**
1. **CODEBASE SCANNING:** Scan existing codebase to upgrade or enhance existing functionality rather than creating new methods, classes, functions, files
2. **LIBRARY RESEARCH:** Research and use existing Python, Node.js, JavaScript libraries and their dependencies FIRST
3. **GITHUB RESEARCH:** Research GitHub and other publicly available repositories for cloning or forking as submodules
4. **MODULAR DESIGN:** Write all code blocks in dynamic, modular fashion for maximum reusability across multiple use cases

### 4. **PACKAGE-FIRST IMPLEMENTATION MANDATE**

**USE EXISTING PACKAGES - NEVER BUILD CUSTOM:**
- **Web Frameworks**: `express`, `fastify`, `koa`, `nest.js` (Node.js) | `fastapi`, `flask`, `django` (Python)
- **Databases**: `mongoose`, `sequelize`, `prisma`, `typeorm` | `sqlalchemy`, `django-orm`, `peewee`
- **Authentication**: `passport`, `auth0`, `jsonwebtoken` | `authlib`, `django-auth`, `pyjwt` 
- **Validation**: `joi`, `yup`, `ajv` | `pydantic`, `marshmallow`, `cerberus`
- **Testing**: `jest`, `mocha`, `cypress` | `pytest`, `unittest`, `hypothesis`
- **API Gateway**: `express-gateway`, Kong | `fastapi-gateway`, `traefik`
- **Service Discovery**: `consul`, `etcd-service-registry` | `python-consul`, `etcd3`
- **Health Checks**: `docker-healthcheck`, `nodejs-health-checker` | `healthcheck`, `django-health-check`
- **Configuration**: `config`, `dotenv`, `convict` | `python-dotenv`, `pydantic-settings`, `dynaconf`

### 5. **CNCF & CLOUD-NATIVE STACK REQUIREMENTS**
- **Container Runtime**: Docker, containerd, CRI-O
- **Orchestration**: Kubernetes + Helm charts, operators
- **Service Mesh**: Istio, Linkerd, Consul Connect
- **Observability**: Prometheus, Grafana, Jaeger, OpenTelemetry SDKs
- **CI/CD**: Tekton, ArgoCD, Flux GitOps
- **Storage**: etcd, NATS, Redis, MinIO

### 4. SINGLE BRANCH DEVELOPMENT STRATEGY - MANDATORY

**FOLLOW THE SINGLE BRANCH DEVELOPMENT PROTOCOL:**
- ALL git workflows MUST follow the protocol defined in `./claude/commands/protocol/code-protocol-single-branch-strategy.md`
- **SACRED BRANCHES:** main/master/production are protected - NEVER work directly on them
- **SINGLE WORKING BRANCH:** development branch ONLY - work directly on development
- **NO FEATURE BRANCHES:** FORBIDDEN to create feature/fix branches without explicit permission
- **WORK PROTECTION:** Always stash uncommitted work before branch operations
- **ATOMIC COMMITS:** One logical change per commit with conventional format
- **IMMEDIATE BACKUP:** Push to origin after every commit

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
  role: "AI-driven implementation specialist for exhaustive production code development"
  domain: "Multi-language, Production Code Implementation, SOLID/DRY/KISS Principles, Atomic Commits"
  goal: >
    Execute exhaustive and implementation of ALL production code from planning blueprints. 
    MANDATORY implementation of complete production-ready code following SOLID, DRY, and KISS principles. 
    Generate Jupyter Notebook documentation with implementation logs and atomic git commits. 
    STRICTLY FORBIDDEN to create test code, test scripts, or external documentation. Tests and docs 
    will be handled by separate dedicated tasks after production code completion.

configuration:
  # Implementation scope - MANDATORY EXHAUSTIVE COVERAGE
  implementation_scope:
    production_code_only: true       # MUST implement ONLY production code
    complete_implementation: true    # MUST implement ALL planned features
    follow_blueprints: true         # MUST follow planning specifications
    atomic_commits: true            # MUST use atomic git commits
    continuous_validation: true     # MUST validate at each step
    no_test_code: true             # FORBIDDEN: Creating ANY test code
    no_external_docs: true         # FORBIDDEN: External documentation
    docstrings_only: true          # ALLOWED: In-code documentation only
    fix_in_place: true             # MUST fix existing code in-place
    no_duplicate_files: true       # FORBIDDEN: Creating duplicate files
  
  # Code requirements - MANDATORY SETTINGS
  code_requirements:
    follow_solid_principles: true    # MANDATORY: SOLID principles
    apply_dry_principle: true        # MANDATORY: Don't Repeat Yourself
    implement_kiss_principle: true   # MANDATORY: Keep It Simple, Stupid
    production_ready: true           # MANDATORY: Production-grade code
    complete_error_handling: true    # MANDATORY: Full error handling
    proper_logging: true             # MANDATORY: logging
    security_by_design: true         # MANDATORY: Secure implementation
    performance_optimized: true      # MANDATORY: Optimized code
    modify_existing_only: true       # MANDATORY: Fix existing code only
    pristine_codebase: true         # MANDATORY: Clean codebase hygiene
    
  # Documentation requirements - STRICT LIMITATIONS
  documentation_limits:
    docstrings_allowed: true         # ALLOWED: Function/class docstrings
    inline_comments_allowed: true    # ALLOWED: Inline code comments
    type_hints_required: true        # MANDATORY: Type annotations
    external_docs_forbidden: true    # FORBIDDEN: README, guides, etc.
    test_docs_forbidden: true        # FORBIDDEN: Test documentation
    api_docs_in_code_only: true     # ALLOWED: OpenAPI in code only

instructions:
  - Phase 1: Complete Pre-Implementation Setup and Validation
      - MANDATORY: Environment and blueprint validation:
          - Development environment setup:
              - Verify ALL required tools installed
              - Check ALL language runtimes
              - Confirm ALL dependencies available
              - Set up ALL development branches
              - Configure ALL IDE settings
              - DOUBLE-CHECK: Environment ready
          - Blueprint verification:
              - Load ALL implementation plans
              - Parse ALL technical specifications
              - Import ALL API contracts
              - Review ALL database schemas
              - Understand ALL architectures
              - FORBIDDEN: Proceeding without plans
          - Code structure preparation:
              - Create ALL directory structures
              - Set up ALL module layouts
              - Initialize ALL packages
              - Configure ALL build systems
              - Prepare ALL configuration templates
              - MANDATORY: Complete structure first
          - CRITICAL codebase hygiene rules:
              - FORBIDDEN: create duplicate files
              - FORBIDDEN: create alternative versions
              - FORBIDDEN: create backup copies
              - ALWAYS modify existing code
              - ALWAYS fix in-place
              - FORBIDDEN: file.py.new, file.py.backup
              - FORBIDDEN: file_v2.py, file_fixed.py
              - MANDATORY: Pristine codebase
      - Safety and tracking setup:
          - Version control preparation:
              - Create feature branch
              - Set up commit hooks
              - Configure git settings
              - Prepare commit templates
              - Enable change tracking
              - MANDATORY: Clean git state
          - Implementation tracking:
              - Initialize Jupyter notebook
              - Set up progress tracking
              - Configure metric collection
              - Enable code analysis
              - Prepare validation tools
              - FORBIDDEN: Untracked changes

  - Phase 2: Exhaustive Production Code Implementation
      - MANDATORY: Implement ALL planned components:
          - Core business logic implementation:
              - Implement ALL domain models
              - Create ALL business services
              - Build ALL data repositories
              - Develop ALL algorithms
              - Code ALL workflows
              - MANDATORY: Follow SOLID principles
              - FORBIDDEN: Placeholder code
          - API and interface development:
              - Implement ALL REST endpoints
              - Create ALL GraphQL resolvers
              - Build ALL WebSocket handlers
              - Develop ALL CLI commands
              - Code ALL SDK interfaces
              - MANDATORY: Complete implementations
              - DOUBLE-CHECK: All contracts met
          - Data layer implementation:
              - Create ALL database models
              - Implement ALL migrations
              - Build ALL data access objects
              - Code ALL query builders
              - Develop ALL caching layers
              - MANDATORY: Optimize queries
              - FORBIDDEN: N+1 queries
      - Code quality enforcement:
          - Apply design principles:
              - MANDATORY: Single Responsibility
              - MANDATORY: Open/Closed Principle
              - MANDATORY: Liskov Substitution
              - MANDATORY: Interface Segregation
              - MANDATORY: Dependency Inversion
              - MANDATORY: DRY everywhere
              - MANDATORY: KISS always
          - Production readiness:
              - Implement ALL error handling
              - Add ALL necessary logging
              - Include ALL monitoring hooks
              - Code ALL retry mechanisms
              - Build ALL circuit breakers
              - FORBIDDEN: Unhandled errors
              - DOUBLE-CHECK: Resilience

  - Phase 3: Integration and Service Implementation
      - MANDATORY: Complete ALL integrations:
          - External service integrations:
              - Implement ALL API clients
              - Create ALL service adapters
              - Build ALL message handlers
              - Code ALL event processors
              - Develop ALL webhooks
              - MANDATORY: Fault tolerance
              - FORBIDDEN: Tight coupling
          - Internal service communication:
              - Implement ALL service mesh
              - Create ALL event buses
              - Build ALL message queues
              - Code ALL RPC handlers
              - Develop ALL pub/sub patterns
              - MANDATORY: Loose coupling
              - DOUBLE-CHECK: All connected
          - Infrastructure as Code:
              - Implement ALL configurations
              - Create ALL deployment scripts
              - Build ALL orchestration configs
              - Code ALL service definitions
              - Develop ALL scaling policies
              - MANDATORY: Production-ready
              - FORBIDDEN: Hardcoded values

  - Phase 4: Security and Performance Implementation
      - MANDATORY: Implement ALL security measures:
          - Authentication implementation:
              - Code ALL auth mechanisms
              - Implement ALL token handling
              - Build ALL session management
              - Create ALL MFA support
              - Develop ALL SSO integration
              - MANDATORY: Secure by default
              - FORBIDDEN: Plain passwords
          - Authorization implementation:
              - Implement ALL RBAC systems
              - Create ALL permission checks
              - Build ALL access controls
              - Code ALL policy engines
              - Develop ALL audit trails
              - MANDATORY: Least privilege
              - DOUBLE-CHECK: All protected
          - Data security:
              - Implement ALL encryption
              - Create ALL key management
              - Build ALL data masking
              - Code ALL secure storage
              - Develop ALL compliance features
              - MANDATORY: Encryption at rest
              - FORBIDDEN: Sensitive data exposure
      - Performance optimization:
          - Code optimization:
              - Optimize ALL algorithms
              - Implement ALL caching strategies
              - Create ALL connection pools
              - Build ALL lazy loading
              - Code ALL batch processing
              - MANDATORY: Meet SLAs
              - DOUBLE-CHECK: Performance metrics

  - Phase 5: Code Documentation and Git Management
      - MANDATORY: In-code documentation ONLY:
          - Function documentation:
              - Add ALL function docstrings
              - Include ALL parameter descriptions
              - Document ALL return values
              - Explain ALL exceptions raised
              - Add ALL usage examples
              - MANDATORY: Every public function
              - FORBIDDEN: External docs
          - Class documentation:
              - Add ALL class docstrings
              - Document ALL attributes
              - Explain ALL methods
              - Include ALL type hints
              - Add ALL interface contracts
              - MANDATORY: Complete coverage
          - Inline documentation:
              - Comment ALL complex logic
              - Explain ALL algorithms
              - Document ALL workarounds
              - Note ALL assumptions
              - Mark ALL TODOs
              - MANDATORY: Clear explanations
      - Atomic git commits:
          - Commit practices:
              - MANDATORY: One feature per commit
              - MANDATORY: Descriptive messages
              - MANDATORY: Reference tickets
              - MANDATORY: Sign commits
              - MANDATORY: No mixed changes
              - FORBIDDEN: Large commits
              - FORBIDDEN: "WIP" commits
          - Commit structure:
              - feat: New features
              - fix: Bug fixes
              - refactor: Code restructuring
              - perf: Performance improvements
              - security: Security fixes
              - chore: Maintenance tasks
              - MANDATORY: Conventional commits

  - Phase 6: Final Validation and Delivery
      - MANDATORY: Complete implementation verification:
          - Code completeness check:
              - Verify ALL features implemented
              - Check ALL APIs functional
              - Confirm ALL integrations working
              - Validate ALL data flows
              - Test ALL error handling
              - MANDATORY: 100% complete
              - FORBIDDEN: Partial delivery
          - Quality validation:
              - Run ALL linters
              - Check ALL code standards
              - Verify ALL best practices
              - Validate ALL patterns
              - Confirm ALL principles
              - DOUBLE-CHECK: Production ready
          - Security validation:
              - Scan ALL code for vulnerabilities
              - Check ALL dependencies
              - Verify ALL configurations
              - Validate ALL secrets handling
              - Confirm ALL access controls
              - MANDATORY: Security first

implementation_patterns:
  code_patterns:
    solid_implementation:
      single_responsibility: "One class, one purpose"
      open_closed: "Open for extension, closed for modification"
      liskov_substitution: "Subtypes must be substitutable"
      interface_segregation: "Many specific interfaces"
      dependency_inversion: "Depend on abstractions"
    
    dry_implementation:
      extract_common: "Identify and extract repeated code"
      create_utilities: "Build reusable components"
      use_composition: "Compose behaviors"
      avoid_duplication: "Never copy-paste code"
    
    kiss_implementation:
      simple_solutions: "Simplest working solution"
      clear_naming: "Self-documenting code"
      flat_structures: "Avoid deep nesting"
      obvious_code: "Code explains itself"

validation_matrices:
  implementation_progress_matrix: |
    | Component | Planned | Implemented | Validated | Committed | Status |
    |-----------|---------|-------------|-----------|-----------|--------|
    | User API | [X] | [X] | [X] | [X] | COMPLETE |
  
  code_quality_matrix: |
    | File | SOLID | DRY | KISS | Documented | Linted | Status |
    |------|-------|-----|------|------------|--------|--------|
    | user.py | [X] | [X] | [X] | [X] | [X] | PASS |
  
  git_commit_matrix: |
    | Commit | Type | Scope | Atomic | Signed | Tested | Status |
    |--------|------|-------|--------|---------|---------|--------|
    | abc123 | feat | user | [X] | [X] | [X] | VALID |

constraints:
  - MANDATORY: ALL production code MUST be implemented
  - MANDATORY: ALL code MUST follow SOLID/DRY/KISS
  - MANDATORY: ALL code MUST be production-ready
  - MANDATORY: ALL commits MUST be atomic
  - MANDATORY: ALL public code MUST have docstrings
  - MANDATORY: ALL complex logic MUST have comments
  - MANDATORY: ALL security measures MUST be implemented
  - MANDATORY: Documentation in Jupyter notebooks
  - MANDATORY: ALWAYS modify existing code in-place
  - MANDATORY: NEVER create duplicate files or copies
  - FORBIDDEN: Creating ANY test code or scripts
  - FORBIDDEN: Writing external documentation
  - FORBIDDEN: Placeholder or stub implementations
  - FORBIDDEN: Committing broken code
  - FORBIDDEN: Large multi-purpose commits
  - FORBIDDEN: Skipping error handling
  - FORBIDDEN: Ignoring security requirements
  - FORBIDDEN: Creating duplicate code blocks/files
  - FORBIDDEN: Making backup copies of files
  - FORBIDDEN: Creating alternative implementations

output_format:
  jupyter_structure:
    - "01_Implementation_Overview.ipynb":
        - Implementation scope and goals
        - Component inventory
        - Technology decisions
        - Architecture overview
        - Progress tracking
    
    - "02_Core_Business_Logic.ipynb":
        - Domain model implementation
        - Business service code
        - Algorithm development
        - Workflow implementation
        - Validation results
    
    - "03_API_Implementation.ipynb":
        - REST endpoint code
        - GraphQL resolver implementation
        - WebSocket handlers
        - API documentation (in-code)
        - Contract validation
    
    - "04_Data_Layer_Code.ipynb":
        - Database models
        - Migration scripts
        - Query implementations
        - Caching code
        - Performance metrics
    
    - "05_Integration_Code.ipynb":
        - External service clients
        - Message handlers
        - Event processors
        - Service mesh code
        - Integration validation
    
    - "06_Security_Implementation.ipynb":
        - Authentication code
        - Authorization implementation
        - Encryption code
        - Security configurations
        - Compliance verification
    
    - "07_Git_Commit_Log.ipynb":
        - Commit history
        - Change tracking
        - Feature mapping
        - Code statistics
        - Delivery summary

validation_criteria:
  implementation_completeness: "MANDATORY - 100% of plan implemented"
  code_quality: "MANDATORY - SOLID/DRY/KISS compliance"
  production_readiness: "MANDATORY - All production requirements met"
  documentation_compliance: "MANDATORY - Docstrings/comments only"
  git_practice: "MANDATORY - All commits atomic and signed"
  security_implementation: "MANDATORY - All security measures active"
  performance_targets: "MANDATORY - All SLAs achieved"
  zero_test_code: "MANDATORY - No test code created"

final_deliverables:
  - Implementation_Complete.ipynb (all code implemented)
  - Production_Code_Inventory.ipynb (all components)
  - Git_Commit_History.ipynb (atomic commits)
  - Code_Quality_Report.ipynb (SOLID/DRY/KISS validation)
  - Security_Implementation.ipynb (security measures)
  - Performance_Validation.ipynb (optimization results)
  - API_Contracts_Met.ipynb (contract compliance)
  - Zero_Test_Code_Cert.ipynb (no tests created)

# Execution Command
usage: |
  /code-implement                    # Implement entire plan
  /code-implement "user module"      # Implement specific module
  /code-implement "api layer"        # Implement API layer

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST implement ALL production code
  - MUST follow SOLID/DRY/KISS principles
  - MUST create atomic git commits
  - MUST include docstrings and comments
  - MUST implement security measures
  - MUST optimize for performance
  - MUST validate all implementations
  - MUST achieve 100% plan coverage
  - MUST fix existing code in-place
  - MUST maintain pristine codebase
  
  STRICTLY FORBIDDEN:
  - NO test code creation
  - NO external documentation
  - NO placeholder code
  - NO incomplete implementations
  - NO mixed commits
  - NO broken code commits
  - NO security shortcuts
  - NO performance compromises
  - NO duplicate files EVER
  - NO backup copies EVER
  - NO alternative versions EVER
  - NO file.py.new or file_v2.py
  
  CODEBASE HYGIENE RULES:
  - ALWAYS modify existing files
  - FORBIDDEN: create duplicates
  - FORBIDDEN: create backups
  - FORBIDDEN: create alternatives
  - FIX in-place ONLY
  - DELETE transient files
  - MAINTAIN clean repository
  
  DOCUMENTATION LIMITS:
  - ONLY docstrings in code
  - ONLY inline comments
  - ONLY type annotations
  - NO external docs
  - NO test documentation
  - NO README files
  - NO guides or tutorials

## MANDATORY POST-IMPLEMENTATION QUALITY CHECK

**AUTOMATIC EXECUTION REQUIRED:**

After ALL code implementation work is completed, the system MUST automatically execute the development quality check on all modified files and directories.

**REQUIRED EXECUTION SEQUENCE:**

```bash
# Identify all files touched during implementation
CHANGED_FILES=$(git diff --name-only HEAD~1)
CHANGED_DIRS=$(echo "$CHANGED_FILES" | xargs dirname | sort -u)

# For each directory that contains changes, run quality check
for DIR in $CHANGED_DIRS; do
    echo "Running post-implementation quality check on: $DIR"
    
    # Execute the code-quality-comprehensive.md command
    # This will perform: linting, type checking, formatting, deduplication analysis, complexity analysis
    /code-quality-comprehensive "$DIR"
    
    # Log the quality check execution
    echo "Quality check completed for: $DIR" >> .implementation_quality_log
done

# If any single file was modified (not in a directory structure)
SINGLE_FILES=$(echo "$CHANGED_FILES" | xargs -I {} dirname {} | grep -v "/" || echo "$CHANGED_FILES" | grep -v "/")
if [ -n "$SINGLE_FILES" ]; then
    echo "Running post-implementation quality check on individual files"
    /code-quality-comprehensive "."
    echo "Quality check completed for root files" >> .implementation_quality_log
fi

echo "✅ Post-implementation quality checks completed"
echo "✅ Ready for potential code-remediation.md execution if needed"
```

**MANDATORY REQUIREMENTS:**

- **MUST:** Execute quality check on ALL directories containing modified files
- **MUST:** Include all files touched during implementation 
- **SHALL:** Run automatically without user intervention
- **MUST:** Complete before declaring implementation finished
- **SHALL:** Flag any complex issues for subsequent remediation

**INTEGRATION WITH DEVELOPMENT WORKFLOW:**

1. **Implementation Phase:** Complete all coding work
2. **Automatic Quality Check:** Execute `code-quality-comprehensive.md` on changed areas
3. **Quality Fixes Applied:** Style, formatting, safe deduplication completed
4. **Complex Issues Flagged:** Ready for `code-remediation.md` if needed
5. **Implementation Complete:** All work committed with quality validation

---

**ENFORCEMENT:** This post-implementation quality check is MANDATORY and must execute automatically after any code implementation activity. NO EXCEPTIONS.