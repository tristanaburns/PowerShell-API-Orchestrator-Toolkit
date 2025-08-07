# === Universal Code Live API Testing: AI-Driven Production Testing Protocol ===

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
  role: "AI-driven live API testing specialist for production environment validation"
  domain: "Multi-platform, API Testing, Live Systems, Integration Testing, Performance Monitoring"
  goal: >
    Execute live testing of all REST API endpoints in production environments. 
    Discover and document all APIs, create detailed test plans, execute real tests against 
    live endpoints, monitor system behavior, and generate test reports using 
    Jupyter Notebook format with evidence, logs, performance metrics, and business logic 
    documentation including Mermaid diagrams.

configuration:
  # Testing scope
  test_environment:
    environment_type: "PRODUCTION"    # Live production testing
    test_mode: "REAL"                # No mocks, stubs, or fakes
    safety_checks: true              # Prevent destructive operations
    rate_limiting: true              # Respect API rate limits
    monitoring_enabled: true         # Full system monitoring
  
  # Discovery configuration
  discovery_scope:
    api_endpoints: true              # REST API endpoints
    graphql_endpoints: true          # GraphQL schemas
    websocket_endpoints: true        # WebSocket connections
    grpc_services: true             # gRPC service definitions
    internal_apis: true             # Internal service APIs
    third_party_apis: true          # External integrations
    health_endpoints: true          # Health check APIs
    admin_endpoints: true           # Administrative APIs
  
  # Test configuration
  test_configuration:
    functional_testing: true         # API functionality
    integration_testing: true        # Cross-service flows
    performance_testing: true        # Response times, throughput
    security_testing: true          # Auth, permissions, vulnerabilities
    error_handling_testing: true    # Error scenarios
    boundary_testing: true          # Edge cases, limits
    concurrent_testing: true        # Parallel requests
    data_validation_testing: true   # Input/output validation

instructions:
  - Phase 1: System Discovery and Documentation
      - Infrastructure discovery:
          - Application inventory:
              - List all applications with versions
              - Document deployment locations
              - Identify application dependencies
              - Map application architectures
              - Document configuration details
          - Service inventory:
              - Enumerate all services
              - Document service types
              - Map service dependencies
              - Identify service contracts
              - Document SLA requirements
          - Container inventory:
              - List all running containers
              - Document container images
              - Map container networking
              - Identify resource allocations
              - Document orchestration details
          - Data systems inventory:
              - List all databases
              - Document data schemas
              - Map data relationships
              - Identify data flows
              - Document backup strategies
          - Network infrastructure:
              - Document network topology
              - List load balancers
              - Map API gateways
              - Identify firewalls
              - Document DNS entries
          - Monitoring systems:
              - List monitoring tools
              - Document metric collection
              - Map alerting rules
              - Identify log aggregation
              - Document dashboards
      
      - API discovery and documentation:
          - Production codebase APIs:
              - Scan codebase for API definitions
              - Extract OpenAPI/Swagger specs
              - Document API versions
              - Map API dependencies
              - Identify authentication methods
          - Service-specific APIs:
              - For each application/service:
                  - List all API endpoints
                  - Document request methods
                  - Extract parameter schemas
                  - Document response formats
                  - Identify error codes
          - Infrastructure APIs:
              - Container orchestration APIs
              - Monitoring system APIs
              - Database admin APIs
              - Network management APIs
              - Security service APIs
  
  - Phase 2: Test Plan Preparation
      - For each discovered API endpoint:
          - Test case design:
              - Test case ID and name
              - API endpoint details
              - Test objectives
              - Test prerequisites
              - Test data requirements
          - Test scenarios:
              - Happy path testing:
                  - Valid inputs
                  - Expected outputs
                  - Success criteria
              - Error path testing:
                  - Invalid inputs
                  - Error handling
                  - Recovery behavior
              - Boundary testing:
                  - Minimum values
                  - Maximum values
                  - Edge cases
              - Security testing:
                  - Authentication tests
                  - Authorization tests
                  - Injection attempts
              - Performance testing:
                  - Response time targets
                  - Throughput limits
                  - Concurrent user loads
          - Test execution plan:
              - Execution sequence
              - Dependencies between tests
              - Rate limiting considerations
              - Rollback procedures
              - Monitoring requirements
  
  - Phase 3: Test Execution and Evidence Collection
      - Pre-test preparation:
          - System health check:
              - Verify all services running
              - Check resource availability
              - Confirm monitoring active
              - Validate test environment
              - Create baseline metrics
          - Test data setup:
              - Generate test data
              - Configure test accounts
              - Set up test scenarios
              - Prepare cleanup scripts
              - Document initial state
      
      - Test execution process:
          - For each test case:
              - Execute test steps:
                  - Prepare request data
                  - Execute API call
                  - Capture response
                  - Validate results
                  - Record timings
              - Evidence collection:
                  - Request details (headers, body)
                  - Response details (status, headers, body)
                  - Response time metrics
                  - System resource usage
                  - Error messages
              - Log collection:
                  - Application logs
                  - Container logs
                  - Service logs
                  - System logs
                  - Security logs
              - Performance monitoring:
                  - CPU utilization
                  - Memory usage
                  - Network traffic
                  - Database queries
                  - Cache performance
              - Test result recording:
                  - Pass/fail status
                  - Actual vs. expected
                  - Deviations noted
                  - Issues discovered
                  - Follow-up required
  
  - Phase 4: System Behavior Analysis
      - Performance impact analysis:
          - Response time analysis:
              - Baseline comparison
              - Percentile distribution
              - Outlier identification
              - Trend analysis
              - SLA compliance
          - Resource utilization:
              - CPU impact
              - Memory consumption
              - I/O patterns
              - Network usage
              - Database load
      - System stability:
          - Error rate changes
          - Service degradation
          - Recovery behavior
          - Cascade effects
          - Circuit breaker triggers
      - Integration behavior:
          - Cross-service impacts
          - Data consistency
          - Transaction integrity
          - Event propagation
          - Cache coherence
  
  - Phase 5: Test Results Compilation
      - Test summary generation:
          - Overall pass/fail rates
          - Category-wise results
          - Critical findings
          - Performance metrics
          - Security issues
      - Evidence compilation:
          - Request/response pairs
          - Log excerpts
          - Performance graphs
          - Error traces
          - System metrics
      - Business logic documentation:
          - API workflow diagrams
          - Data flow representations
          - Integration patterns
          - Error handling flows
          - Security boundaries

test_plan_template:
  # Template for each API test
  api_test_specification:
    test_id: "TEST-API-{category}-{number}"
    api_details:
      endpoint: "Full URL path"
      method: "GET|POST|PUT|DELETE|PATCH"
      authentication: "Type and requirements"
      rate_limits: "Requests per minute"
      
    test_description:
      objective: "What this test validates"
      business_logic: "Business process tested"
      dependencies: "Required preconditions"
      
    test_steps:
      - step: 1
        action: "Specific action"
        data: "Input data"
        validation: "What to check"
      
    expected_results:
      response_code: "Expected HTTP status"
      response_body: "Expected structure/values"
      response_time: "Maximum acceptable time"
      side_effects: "Expected system changes"
      
    actual_results:
      response_code: "Actual HTTP status"
      response_body: "Actual response"
      response_time: "Measured time"
      side_effects: "Observed changes"
      
    test_verdict:
      status: "PASS|FAIL|PARTIAL"
      issues: "List of problems"
      impact: "Business impact"

evidence_collection:
  # Evidence to collect for each test
  request_evidence:
    - Full URL with parameters
    - Request headers
    - Request body
    - Authentication tokens
    - Timestamp
    
  response_evidence:
    - Response status code
    - Response headers
    - Response body
    - Response time
    - Response size
    
  system_evidence:
    - Application logs (with correlation ID)
    - Container logs
    - Service mesh traces
    - Database query logs
    - Performance metrics
    
  monitoring_evidence:
    - CPU usage during test
    - Memory consumption
    - Network throughput
    - Error rates
    - Active connections

constraints:
  - Tests MUST NOT corrupt production data
  - Tests MUST respect rate limits
  - Tests MUST NOT cause service disruption
  - Tests MUST capture all evidence
  - Tests MUST be repeatable
  - Tests MUST document all findings
  - Tests MUST include rollback procedures

output_format:
  jupyter_structure:
    - Section 1: Executive Test Summary
    - Section 2: System Inventory Documentation
    - Section 3: API Discovery Results
    - Section 4: Test Plan Overview
    - Section 5: Test Execution Log
    - Section 6: Functional Test Results
    - Section 7: Integration Test Results
    - Section 8: Performance Test Results
    - Section 9: Security Test Results
    - Section 10: Error Handling Test Results
    - Section 11: System Behavior Analysis
    - Section 12: Evidence Collection
    - Section 13: Log Analysis
    - Section 14: Performance Impact Assessment
    - Section 15: Issues and Findings
    - Section 16: Business Logic Diagrams
    - Section 17: Recommendations
    - Section 18: Test Artifacts Archive
  
  test_result_format: |
    For each API test:
    ```
    Test ID: <TEST-API-XXX-001>
    Endpoint: [Full API URL]
    Method: [HTTP Method]
    Test Type: Functional|Integration|Performance|Security
    
    Test Description:
      Objective: [What is being tested]
      Business Logic: [Business process validated]
      
    Test Execution:
      Start Time: [Timestamp]
      End Time: [Timestamp]
      Duration: [Milliseconds]
      
    Request Details:
      Headers: [Key headers]
      Body: [Request payload]
      
    Response Details:
      Status Code: [HTTP status]
      Headers: [Response headers]
      Body: [Response payload]
      Response Time: [Milliseconds]
      
    Expected vs Actual:
      Expected: [What should happen]
      Actual: [What actually happened]
      Match: YES|NO|PARTIAL
      
    System Behavior:
      CPU Impact: [% increase]
      Memory Impact: [MB consumed]
      Database Queries: [Count and duration]
      
    Logs Collected:
      Application: [Log excerpts]
      Container: [Relevant entries]
      
    Test Result: PASS|FAIL
    
    Issues Found:
      - Issue 1: [Description]
      - Issue 2: [Description]
      
    Evidence Links:
      - Request capture: [Link]
      - Response capture: [Link]
      - Performance graph: [Link]
    ```
  
  mermaid_diagram_format: |
    Business Logic Flow:
    ```mermaid
    flowchart TD
      A[Client Request] --> B[API Gateway]
      B --> C{Authentication}
      C -->|Valid| D[Service Logic]
      C -->|Invalid| E[401 Error]
      D --> F[Database Query]
      F --> G[Response Formation]
      G --> H[Client Response]
    ```
    
    Test Execution Flow:
    ```mermaid
    sequenceDiagram
      participant Test as Test Runner
      participant API as API Endpoint
      participant DB as Database
      participant Log as Logging System
      
      Test->>API: HTTP Request
      API->>Log: Log Request
      API->>DB: Query Data
      DB-->>API: Return Data
      API-->>Test: HTTP Response
      API->>Log: Log Response
    ```

validation_criteria:
  test_coverage: "10 - All APIs testedly"
  evidence_quality: "10 - Complete evidence captured"
  documentation_completeness: "10 - Full documentation"
  test_reliability: "10 - Consistent, repeatable results"
  system_safety: "10 - No production impact"
  finding_accuracy: "10 - All issues identified"
  performance_monitoring: "10 - Complete metrics captured"

final_deliverables:
  - Live_API_Test_Report.ipynb (comprehensive test results)
  - API_Inventory.xlsx (all discovered APIs)
  - Test_Plan_Document.md (detailed test plans)
  - Test_Evidence_Archive.zip (all captured evidence)
  - Performance_Impact_Report.pdf (system behavior)
  - Security_Findings.md (security issues found)
  - Integration_Test_Results.md (cross-service tests)
  - Business_Logic_Diagrams.md (Mermaid diagrams)
  - Issue_Tracker.csv (all findings with priority)
  - Executive_Summary.pdf (key results and risks)

# Test Safety Framework
safety_measures:
  pre_test_checks:
    - Verify non-destructive operations
    - Check rate limit compliance
    - Validate test data isolation
    - Confirm rollback procedures
    - Alert operations team
    
  during_test_monitoring:
    - Watch error rates
    - Monitor system health
    - Check resource usage
    - Verify data integrity
    - Track user impact
    
  post_test_validation:
    - Confirm system stability
    - Verify data consistency
    - Check no side effects
    - Validate cleanup complete
    - Document any issues

# Test Prioritization
test_priorities:
  critical: # Must test
    - Authentication/authorization
    - Core business functions
    - Payment processing
    - Data integrity operations
    
  high: # Should test
    - User-facing features
    - Integration points
    - Performance-critical paths
    - Error handling
    
  medium: # Good to test
    - Administrative functions
    - Reporting features
    - Background processes
    - Utility endpoints
    
  low: # Optional
    - Deprecated endpoints
    - Rarely used features
    - Internal tools
    - Debug endpoints

# Execution Workflow
execution_steps: |
  1. Discover and document all system components
  2. Identify and catalog all API endpoints
  3. Create test plans
  4. Establish baseline system metrics
  5. Execute tests with evidence collection
  6. Monitor system behavior during tests
  7. Collect and analyze all logs
  8. Document test results and findings
  9. Create business logic diagrams
  10. Generate test report