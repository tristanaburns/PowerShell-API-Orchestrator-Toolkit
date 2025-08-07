# === Live API Testing: Production Code Validation Protocol ===

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
  role: "Production API testing specialist with exhaustive validation capabilities"
  domain: "API Testing, OpenAPI/Swagger Validation, Integration Testing, Production Verification"
  goal: >
    Execute, repeatable testing of all production API methods and REST endpoints
    against OpenAPI/Swagger specifications. Validate actual production functionality without
    any mocks, stubs, or demo code. Deploy test environments as needed and generate detailed
    Jupyter Notebook documentation with debug-level logging, test evidence, and compliance matrices.

configuration:
  # Test scope configuration
  test_scope:
    api_focus: "${1:-all}"  # Variable parameter: specific API area or 'all' for complete testing
    test_environments:
      development: true
      staging: true
      production_mirror: true  # Isolated production-like environment
    
  # Test requirements
  test_requirements:
    production_code_only: true      # MANDATORY: No mocks, stubs, or demo code
    debug_logging: true             # MANDATORY: Full debug-level logging
    container_deployment: true      # Deploy test containers if needed
    api_discovery: true            # Discover all API methods
    spec_validation: true          # Validate against OpenAPI/Swagger
    functional_testing: true       # Test actual functionality
    integration_testing: true      # Test service integrations
    load_testing: true            # Basic load validation
    security_testing: true        # Security validation
    test_in_place: true           # MUST test existing code only
    no_duplicate_files: true      # FORBIDDEN: Creating duplicate test files
    
  # Documentation requirements
  documentation:
    format: "jupyter_notebook"     # MANDATORY: All docs in Jupyter
    test_directory: "./tests/live-api-testing/"  # MANDATORY: Dedicated test directory
    include_logs: true
    include_mermaid: true
    include_evidence: true
    
  # Validation strictness
  validation_mode:
    zero_mocks: true              # STRICTLY FORBIDDEN: No mock data
    zero_stubs: true              # STRICTLY FORBIDDEN: No stub implementations
    zero_demo_code: true          # STRICTLY FORBIDDEN: No demo endpoints
    production_parity: true       # Must match production behavior
    spec_compliance: true         # Must match OpenAPI/Swagger specs
    test_existing_only: true      # MANDATORY: Test existing code only
    pristine_codebase: true       # MANDATORY: No duplicate files

instructions:
  - Phase 1: Environment Setup and API Discovery
      - Container deployment check:
          - Verify production containers running:
              - Check docker-compose status
              - Validate service health endpoints
              - Ensure debug logging enabled
              - Verify network connectivity
              - Check database connections
          - Deploy test environment if needed:
              - Create isolated test network
              - Deploy production-like containers
              - Configure debug logging
              - Set up monitoring
              - Initialize test databases
      - API discovery and documentation:
          - Scan production codebase:
              - Identify all API routes
              - Extract method signatures
              - Document request/response models
              - Map service dependencies
              - List authentication requirements
          - Retrieve API specifications:
              - Download OpenAPI spec from /api/docs
              - Export Swagger documentation
              - Extract schema definitions
              - Document API versioning
              - Identify deprecated endpoints
      - Create test infrastructure:
          - Initialize Jupyter notebook structure
          - Set up logging framework
          - Configure test clients
          - Prepare authentication tokens
          - Create test data factories
      - CRITICAL codebase hygiene rules:
          - FORBIDDEN: create duplicate test files
          - FORBIDDEN: create test copies of production code
          - FORBIDDEN: make backup versions for testing
          - ALWAYS test production code directly
          - ALWAYS maintain clean test directory
          - FORBIDDEN: api_test_copy.py, test_api_v2.py
          - FORBIDDEN: backup test files or scripts
          - MANDATORY: Test artifacts in ./tests/ only

  - Phase 2: Specification Validation and Alignment
      - Compare discovered APIs with specs:
          - Route mapping validation:
              - Match code routes to spec paths
              - Verify HTTP methods alignment
              - Check parameter definitions
              - Validate response schemas
              - Identify undocumented endpoints
          - Schema validation:
              - Request body schemas
              - Response model schemas
              - Error response formats
              - Pagination structures
              - Filter/sort parameters
      - Update specifications if misaligned:
          - Document discrepancies:
              - Missing endpoints in spec
              - Incorrect parameter types
              - Outdated response models
              - Missing error codes
              - Incomplete examples
          - Generate spec updates:
              - Update OpenAPI definitions
              - Correct schema models
              - Add missing endpoints
              - Update examples
              - Version documentation
      - Create validation matrices:
          - API coverage matrix
          - Schema compliance matrix
          - Authentication matrix
          - Error handling matrix
          - Performance baseline matrix

  - Phase 3: Test Planning and Documentation
      - Create test plan:
          - Test methodology definition:
              - Unit-level API tests
              - Integration scenarios
              - End-to-end workflows
              - Error condition testing
              - Performance benchmarks
          - Test case documentation:
              - Test ID and description
              - Prerequisites and setup
              - Test steps and data
              - Expected results
              - Validation criteria
      - Document in Jupyter notebook:
          - Test plan overview cell
          - Mermaid workflow diagrams
          - Test case matrices
          - Environment configuration
          - Authentication setup
      - Prepare test execution framework:
          - HTTP client configuration
          - Request builders
          - Response validators
          - Assertion helpers
          - Logging utilities

  - Phase 4: Test Execution
      - Execute API endpoint tests:
          - Basic functionality tests:
              - GET endpoints: List, detail, filter
              - POST endpoints: Create operations
              - PUT/PATCH: Update operations
              - DELETE: Removal operations
              - OPTIONS: CORS validation
          - Authentication and authorization:
              - Valid token tests
              - Expired token handling
              - Invalid credential tests
              - Permission boundaries
              - Rate limiting validation
          - Data validation tests:
              - Required field validation
              - Type checking
              - Format validation
              - Constraint validation
              - Business rule enforcement
      - Integration testing:
          - Cross-service communication:
              - Service discovery
              - Request routing
              - Response aggregation
              - Transaction handling
              - Rollback scenarios
          - Database operations:
              - CRUD operations
              - Transaction integrity
              - Concurrent access
              - Data consistency
              - Migration compatibility
      - Error handling validation:
          - Client errors (4xx):
              - Bad requests (400)
              - Authentication (401)
              - Authorization (403)
              - Not found (404)
              - Validation errors (422)
          - Server errors (5xx):
              - Internal errors (500)
              - Service unavailable (503)
              - Gateway errors (502)
              - Timeout handling (504)
              - Circuit breaker activation

  - Phase 5: Performance and Load Validation
      - Baseline performance testing:
          - Response time measurement:
              - Individual endpoint latency
              - Database query performance
              - Service call overhead
              - Network latency
              - Total request time
          - Throughput testing:
              - Requests per second
              - Concurrent user limits
              - Resource utilization
              - Queue depths
              - Connection pools
      - Load pattern testing:
          - Gradual load increase
          - Spike testing
          - Sustained load
          - Resource exhaustion
          - Recovery validation
      - Performance documentation:
          - Response time graphs
          - Throughput charts
          - Resource utilization
          - Bottleneck analysis
          - Optimization recommendations

  - Phase 6: Security Validation
      - Authentication testing:
          - Token validation:
              - JWT verification
              - Session management
              - Token expiration
              - Refresh mechanisms
              - Logout functionality
          - Multi-factor authentication:
              - 2FA flows
              - Device verification
              - Biometric support
              - Recovery methods
              - Session elevation
      - Authorization testing:
          - Role-based access:
              - Permission matrices
              - Resource boundaries
              - Hierarchical access
              - Delegation testing
              - Privilege escalation
          - Data access control:
              - Row-level security
              - Field-level permissions
              - Tenant isolation
              - Data encryption
              - Audit logging
      - Security headers and policies:
          - CORS configuration
          - CSP headers
          - HSTS enforcement
          - X-Frame-Options
          - Rate limiting headers

  - Phase 7: Results Analysis and Reporting
      - Test execution summary:
          - Total tests executed:
              - Pass/fail counts
              - Skip reasons
              - Execution time
              - Coverage metrics
              - Flaky test identification
          - Failure analysis:
              - Root cause analysis
              - Impact assessment
              - Severity classification
              - Reproduction steps
              - Fix recommendations
      - Log analysis and evidence:
          - Application logs:
              - Debug trace analysis
              - Error log patterns
              - Performance logs
              - Security events
              - Integration logs
          - Container logs:
              - Service interactions
              - Resource usage
              - Health check logs
              - Startup/shutdown
              - Error recovery
      - Compliance reporting:
          - API specification compliance
          - Performance SLA compliance
          - Security policy compliance
          - Data protection compliance
          - Operational compliance

test_execution_protocol:
  pre_execution:
    - Verify all containers running with debug logging
    - Confirm test environment isolation
    - Initialize Jupyter notebook with test plan
    - Configure authentication tokens
    - Set up monitoring and logging
    
  during_execution:
    - Log every API call with full request/response
    - Capture performance metrics for each test
    - Document any deviations from expected behavior
    - Screenshot error responses and stack traces
    - Maintain test execution audit trail
    
  post_execution:
    - Analyze all debug logs for issues
    - Generate test coverage reports
    - Create failure investigation tickets
    - Document remediation requirements
    - Archive test artifacts and evidence

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST test ALL production APIs
  - MUST use real production code
  - MUST enable debug logging
  - MUST validate against specs
  - MUST document in Jupyter
  - MUST test existing code only
  - MUST maintain clean codebase
  
  STRICTLY FORBIDDEN:
  - NO mock implementations
  - NO stub services
  - NO demo endpoints
  - NO simplified tests
  - NO duplicate files EVER
  - NO backup copies EVER
  - NO alternative versions EVER
  - NO test_api_copy.py files
  
  CODEBASE HYGIENE RULES:
  - ALWAYS test existing code
  - FORBIDDEN: create duplicates
  - FORBIDDEN: create backups
  - FORBIDDEN: create alternatives
  - TEST production directly
  - DELETE transient files
  - MAINTAIN clean ./tests/

jupyter_notebook_structure:
  notebooks:
    - "01_Test_Plan_and_Overview.ipynb":
        - Executive summary
        - Test scope and objectives
        - Environment configuration
        - Test methodology
        - Success criteria
    
    - "02_API_Discovery_and_Validation.ipynb":
        - Discovered API endpoints
        - OpenAPI spec comparison
        - Schema validation results
        - Discrepancy analysis
        - Specification updates
    
    - "03_Test_Execution_Results.ipynb":
        - Test case execution log
        - Pass/fail summary
        - Performance metrics
        - Error analysis
        - Debug log excerpts
    
    - "04_Integration_Test_Results.ipynb":
        - Service interaction tests
        - Data flow validation
        - Transaction testing
        - Dependency validation
        - System behavior analysis
    
    - "05_Performance_Analysis.ipynb":
        - Response time analysis
        - Throughput metrics
        - Resource utilization
        - Bottleneck identification
        - Optimization recommendations
    
    - "06_Security_Validation.ipynb":
        - Authentication test results
        - Authorization matrices
        - Security header validation
        - Vulnerability assessment
        - Compliance verification
    
    - "07_Test_Evidence_and_Logs.ipynb":
        - Raw test execution logs
        - Container debug logs
        - Error screenshots
        - Network traces
        - Database queries
    
    - "08_Compliance_and_Remediation.ipynb":
        - Compliance matrices
        - Issue tracking
        - Remediation plans
        - Risk assessment
        - Sign-off checklist

validation_matrices:
  api_coverage_matrix: |
    | Endpoint | Method | Spec | Code | Tested | Result | Notes |
    |----------|--------|------|------|--------|--------|-------|
    | /api/v1/users | GET |  |  |  | PASS | |
    | /api/v1/users | POST |  |  |  | FAIL | Validation error |
  
  test_execution_matrix: |
    | Test ID | Description | Expected | Actual | Status | Evidence |
    |---------|-------------|----------|---------|---------|----------|
    | API-001 | User creation | 201 Created | 201 | PASS | logs/test-001.log |
  
  performance_baseline_matrix: |
    | Endpoint | Target (ms) | Actual (ms) | P95 (ms) | Status | Load |
    |----------|-------------|-------------|----------|---------|------|
    | GET /users | < 100 | 87 | 95 | PASS | 100 RPS |

constraints:
  - NO mock implementations allowed - production code only
  - NO stub services permitted - real integrations only
  - NO demo data allowed - realistic test data only
  - NO simplified tests - validation only
  - ALL tests must have debug logging enabled
  - ALL results must be documented in Jupyter notebooks
  - ALL test artifacts must be in dedicated test directory
  - NO markdown documentation outside of code blocks
  - MANDATORY: Test existing production code only
  - MANDATORY: NEVER create duplicate files or copies
  - FORBIDDEN: Creating duplicate test files
  - FORBIDDEN: Making backup copies of code
  - FORBIDDEN: Creating alternative test implementations
  - FORBIDDEN: Test file copies like api_test_v2.py

output_format:
  test_summary: |
    Test Execution Summary
    =====================
    Environment: [dev|staging|prod-mirror]
    Focus Area: [specific area or 'all']
    
    Discovery Results:
    - Total API endpoints found: X
    - Documented in spec: Y
    - Undocumented: Z
    
    Test Results:
    - Total tests executed: N
    - Passed: P (X%)
    - Failed: F (Y%)
    - Skipped: S (Z%)
    
    Critical Issues:
    - [Issue 1 with endpoint and impact]
    - [Issue 2 with endpoint and impact]
    
    Performance:
    - Average response time: Xms
    - P95 response time: Yms
    - Throughput: Z RPS
    
    Security:
    - Authentication tests: PASS/FAIL
    - Authorization tests: PASS/FAIL
    - Security headers: PASS/FAIL
    
    Compliance:
    - OpenAPI compliance: X%
    - Performance SLAs: MET/NOT MET
    - Security policies: COMPLIANT/NON-COMPLIANT

validation_criteria:
  api_completeness: "100% of production endpoints tested"
  spec_accuracy: "100% alignment between code and specification"
  test_coverage: "100% of documented APIs have tests"
  performance_compliance: "All endpoints meet SLA targets"
  security_validation: "All security requirements verified"
  error_handling: "All error scenarios properly handled"
  integration_verification: "All service dependencies validated"
  data_integrity: "All CRUD operations maintain consistency"

final_deliverables:
  - Complete Jupyter notebook test documentation
  - Test execution logs with debug details
  - API compliance matrix
  - Performance analysis report
  - Security validation report
  - Issue tracking with severity
  - Remediation recommendations
  - Container logs archive
  - Test data cleanup scripts
  - Executive summary dashboard

# Execution Command
usage: |
  /code-testing-live-api                    # Test all APIs
  /code-testing-live-api authentication     # Test auth APIs only
  /code-testing-live-api "user management"  # Test user APIs
  /code-testing-live-api payments          # Test payment APIs