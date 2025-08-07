# === Universal Code Deployment: AI-Driven Exhaustive Production Deployment Protocol ===

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
  role: "AI-driven deployment specialist for exhaustive production deployment orchestration"
  domain: "Multi-environment, Container Orchestration, Infrastructure Management, Production Verification"
  goal: >
    Execute exhaustive and deployment of ALL production code and infrastructure. 
    MANDATORY staged deployment with complete validation at every phase. MUST ensure 100% operational 
    readiness following deployment best practices. Generate Jupyter Notebook documentation 
    with real-time monitoring, validation results, and zero-downtime deployment. STRICTLY FORBIDDEN 
    to skip any deployment steps or use shortcuts.

configuration:
  # Deployment scope - MANDATORY EXHAUSTIVE COVERAGE
  deployment_scope:
    full_system_deployment: true     # MUST deploy ALL components
    infrastructure_setup: true       # MUST provision ALL infrastructure
    database_migration: true         # MUST execute ALL migrations
    service_deployment: true         # MUST deploy ALL services
    network_configuration: true      # MUST configure ALL networking
    security_hardening: true         # MUST apply ALL security policies
    monitoring_setup: true           # MUST enable ALL monitoring
    backup_configuration: true       # MUST set up ALL backups
    production_only: true           # STRICTLY production deployment
  
  # Deployment requirements - MANDATORY SETTINGS
  deployment_requirements:
    zero_downtime: true             # MANDATORY: No service interruption
    staged_rollout: true            # MANDATORY: Gradual deployment
    health_validation: true         # MANDATORY: Health checks at each stage
    rollback_capability: true       # MANDATORY: Instant rollback ready
    complete_logging: true          # MANDATORY: Log everything
    double_verification: true       # MANDATORY: Verify all deployments
    atomic_deployments: true        # MANDATORY: All-or-nothing deploys
    follow_best_practices: true     # MANDATORY: Industry standards
    continuous_monitoring: true     # MANDATORY: Real-time monitoring
  
  # Environment configuration
  environment_mandate:
    pre_production_validation: true  # MANDATORY: Test in staging first
    production_readiness: true       # MANDATORY: All checks must pass
    security_compliance: true        # MANDATORY: Security scans clean
    performance_baseline: true       # MANDATORY: Meet SLAs
    disaster_recovery: true          # MANDATORY: DR plan active
    documentation_complete: true     # MANDATORY: Runbooks ready

instructions:
  - Phase 1: Complete System Inventory and Pre-Deployment Analysis
      - MANDATORY: Exhaustive component discovery:
          - Application inventory:
              - Identify ALL backend services
              - List ALL frontend applications
              - Map ALL API endpoints
              - Document ALL microservices
              - Track ALL dependencies
              - Catalog ALL configurations
              - DOUBLE-CHECK: No component missed
              - FORBIDDEN: Partial inventory
          - Infrastructure inventory:
              - Document ALL servers/instances
              - List ALL containers
              - Map ALL orchestration configs
              - Track ALL load balancers
              - Identify ALL databases
              - Catalog ALL caches
              - Document ALL message queues
              - MANDATORY: Complete infrastructure map
          - Network topology mapping:
              - Map ALL service communications
              - Document ALL port assignments
              - Track ALL SSL certificates
              - List ALL domain names
              - Map ALL firewall rules
              - Document ALL VPNs/tunnels
              - FORBIDDEN: Incomplete network map
      - Pre-deployment validation:
          - System health verification:
              - Check ALL service statuses
              - Verify ALL database connections
              - Test ALL API endpoints
              - Validate ALL integrations
              - Confirm ALL dependencies
              - MANDATORY: 100% health before deploy
          - Resource availability check:
              - Verify CPU capacity
              - Check memory availability
              - Confirm storage space
              - Validate network bandwidth
              - Check license limits
              - DOUBLE-CHECK: Resources sufficient

  - Phase 2: Build and Artifact Preparation
      - MANDATORY: Complete build process:
          - Source code preparation:
              - Pull ALL latest code
              - Verify ALL branches correct
              - Check ALL submodules
              - Validate ALL dependencies
              - Run ALL linters
              - FORBIDDEN: Uncommitted changes
          - Container image building:
              - Build ALL Docker images
              - Tag ALL images properly
              - Scan ALL images for vulnerabilities
              - Sign ALL images
              - Push to ALL registries
              - MANDATORY: Multi-stage builds
              - DOUBLE-CHECK: Image integrity
          - Artifact generation:
              - Compile ALL binaries
              - Package ALL applications
              - Bundle ALL assets
              - Generate ALL configs
              - Create ALL manifests
              - FORBIDDEN: Missing artifacts
      - Build validation:
          - Security scanning:
              - Run ALL SAST scans
              - Execute ALL dependency checks
              - Perform ALL vulnerability scans
              - Check ALL compliance rules
              - Validate ALL signatures
              - MANDATORY: Zero critical issues
          - Quality verification:
              - Verify ALL build outputs
              - Check ALL file permissions
              - Validate ALL configurations
              - Test ALL entry points
              - Confirm ALL integrations
              - DOUBLE-CHECK: Build quality

  - Phase 3: Infrastructure Provisioning and Configuration
      - MANDATORY: Complete infrastructure setup:
          - Compute resources:
              - Provision ALL servers
              - Configure ALL containers
              - Set up ALL orchestrators
              - Initialize ALL clusters
              - Configure ALL auto-scaling
              - MANDATORY: High availability
          - Storage configuration:
              - Set up ALL databases
              - Configure ALL file systems
              - Initialize ALL object storage
              - Set up ALL backups
              - Configure ALL replication
              - FORBIDDEN: Single points of failure
          - Network infrastructure:
              - Configure ALL load balancers
              - Set up ALL DNS entries
              - Configure ALL SSL/TLS
              - Set up ALL CDNs
              - Configure ALL firewalls
              - MANDATORY: Secure by default
      - Infrastructure validation:
          - Connectivity testing:
              - Test ALL network paths
              - Verify ALL DNS resolution
              - Check ALL SSL certificates
              - Validate ALL firewall rules
              - Test ALL load balancing
              - DOUBLE-CHECK: Full connectivity

  - Phase 4: Database Migration and Data Management
      - MANDATORY: Safe database operations:
          - Pre-migration backup:
              - Backup ALL databases
              - Verify ALL backup integrity
              - Test restore procedures
              - Document recovery points
              - Store backups securely
              - MANDATORY: Verified backups
          - Migration execution:
              - Run ALL schema migrations
              - Execute ALL data migrations
              - Apply ALL indexes
              - Update ALL constraints
              - Verify ALL triggers
              - FORBIDDEN: Destructive operations
          - Data validation:
              - Verify ALL data integrity
              - Check ALL relationships
              - Validate ALL constraints
              - Test ALL queries
              - Confirm ALL performance
              - DOUBLE-CHECK: No data loss

  - Phase 5: Application Deployment with Zero Downtime
      - MANDATORY: Staged deployment process:
          - Blue-green deployment:
              - Deploy to green environment
              - Run ALL smoke tests
              - Validate ALL endpoints
              - Check ALL integrations
              - Monitor ALL metrics
              - MANDATORY: Full validation
          - Canary deployment:
              - Route 5% traffic to new version
              - Monitor ALL error rates
              - Check ALL performance metrics
              - Validate ALL user flows
              - Increase traffic gradually
              - FORBIDDEN: Big bang deployment
          - Progressive rollout:
              - Deploy to 25% of instances
              - Monitor for 15 minutes
              - Deploy to 50% of instances
              - Monitor for 30 minutes
              - Deploy to 100% of instances
              - MANDATORY: Monitoring at each stage
      - Service orchestration:
          - Container deployment:
              - Deploy ALL containers
              - Configure ALL health checks
              - Set up ALL readiness probes
              - Configure ALL liveness probes
              - Set resource limits
              - DOUBLE-CHECK: All running

  - Phase 6: Service Discovery and Load Balancing
      - MANDATORY: Complete service configuration:
          - Service registration:
              - Register ALL services
              - Configure ALL endpoints
              - Set up ALL health checks
              - Configure ALL metadata
              - Enable ALL discovery
              - MANDATORY: All services registered
          - Load balancer configuration:
              - Configure ALL algorithms
              - Set up ALL sticky sessions
              - Configure ALL timeouts
              - Set up ALL retries
              - Configure ALL circuit breakers
              - FORBIDDEN: Single endpoints

  - Phase 7: Security Hardening and Compliance
      - MANDATORY: Complete security setup:
          - Access control:
              - Configure ALL authentication
              - Set up ALL authorization
              - Enable ALL MFA
              - Configure ALL RBAC
              - Set up ALL API keys
              - MANDATORY: Least privilege
          - Network security:
              - Enable ALL firewalls
              - Configure ALL WAF rules
              - Set up ALL DDoS protection
              - Enable ALL rate limiting
              - Configure ALL geo-blocking
              - DOUBLE-CHECK: No open ports
          - Data security:
              - Enable ALL encryption at rest
              - Configure ALL TLS/SSL
              - Set up ALL key rotation
              - Configure ALL secret management
              - Enable ALL audit logging
              - FORBIDDEN: Plaintext secrets

  - Phase 8: Monitoring and Observability Setup
      - MANDATORY: Complete monitoring coverage:
          - Metrics collection:
              - Configure ALL Prometheus exporters
              - Set up ALL custom metrics
              - Configure ALL dashboards
              - Set up ALL alerts
              - Configure ALL thresholds
              - MANDATORY: 100% coverage
          - Log aggregation:
              - Configure ALL log shipping
              - Set up ALL parsing rules
              - Configure ALL retention
              - Set up ALL searching
              - Configure ALL alerting
              - DOUBLE-CHECK: No log gaps
          - Distributed tracing:
              - Enable ALL trace collection
              - Configure ALL sampling
              - Set up ALL correlation
              - Configure ALL visualization
              - Enable ALL analysis
              - MANDATORY: End-to-end tracing

  - Phase 9: Operational Verification and Validation
      - MANDATORY: Complete system validation:
          - Functional testing:
              - Test ALL user journeys
              - Verify ALL API endpoints
              - Check ALL integrations
              - Validate ALL workflows
              - Test ALL edge cases
              - FORBIDDEN: Skipping tests
          - Performance validation:
              - Run ALL load tests
              - Check ALL response times
              - Verify ALL throughput
              - Test ALL concurrency
              - Validate ALL SLAs
              - MANDATORY: Meet baselines
          - Security validation:
              - Run ALL penetration tests
              - Check ALL vulnerabilities
              - Verify ALL compliance
              - Test ALL access controls
              - Validate ALL encryption
              - DOUBLE-CHECK: Security posture

  - Phase 10: Documentation and Handover
      - MANDATORY: Complete documentation:
          - Deployment documentation:
              - Document ALL procedures
              - Create ALL runbooks
              - Write ALL troubleshooting guides
              - Document ALL configurations
              - Create ALL diagrams
              - MANDATORY: Jupyter notebooks
          - Operational documentation:
              - Create ALL monitoring guides
              - Write ALL alert responses
              - Document ALL recovery procedures
              - Create ALL escalation paths
              - Write ALL maintenance guides
              - FORBIDDEN: Missing procedures

deployment_strategies:
  zero_downtime_methods:
    blue_green:
      when: "Stateless applications"
      how: "Switch router/load balancer"
      rollback: "Instant switch back"
    
    canary:
      when: "Risk mitigation needed"
      how: "Gradual traffic shift"
      rollback: "Stop traffic shift"
    
    rolling:
      when: "Resource constrained"
      how: "Sequential instance updates"
      rollback: "Reverse roll"
  
  validation_gates:
    health_checks:
      types: "Liveness, Readiness, Startup"
      frequency: "Every 10 seconds"
      threshold: "3 consecutive passes"
    
    smoke_tests:
      coverage: "Critical paths"
      automation: "Fully automated"
      blocking: "Deployment stops on failure"

validation_matrices:
  deployment_readiness_matrix: |
    | Component | Built | Tested | Scanned | Deployed | Verified | Status |
    |-----------|-------|--------|---------|----------|----------|--------|
    | API Service | [X] | [X] | [X] | [X] | [X] | READY |
  
  environment_validation_matrix: |
    | Check | Dev | Test | Staging | Prod | Status |
    |-------|-----|------|---------|------|--------|
    | Health | [X] | [X] | [X] | [X] | PASS |
  
  operational_metrics_matrix: |
    | Metric | Target | Actual | Status | Alert |
    |--------|--------|--------|--------|-------|
    | Uptime | 99.9% | 100% | [X] | No |

constraints:
  - MANDATORY: ALL components MUST be deployed
  - MANDATORY: ZERO downtime during deployment
  - MANDATORY: ALL health checks MUST pass
  - MANDATORY: Rollback capability at EVERY stage
  - MANDATORY: Complete monitoring BEFORE traffic
  - MANDATORY: Security scanning at ALL phases
  - MANDATORY: Performance validation required
  - MANDATORY: Documentation in Jupyter notebooks
  - FORBIDDEN: Skipping deployment stages
  - FORBIDDEN: Manual deployment steps
  - FORBIDDEN: Untested deployments
  - FORBIDDEN: Missing rollback plans
  - FORBIDDEN: Incomplete monitoring
  - FORBIDDEN: Security compromises

output_format:
  jupyter_structure:
    - "01_Deployment_Plan.ipynb":
        - Deployment scope and strategy
        - Component inventory
        - Dependency mapping
        - Risk assessment
        - Rollback procedures
    
    - "02_Pre_Deployment_Validation.ipynb":
        - System health status
        - Resource availability
        - Dependency checks
        - Security validation
        - Go/No-go decision
    
    - "03_Build_Process.ipynb":
        - Build execution logs
        - Artifact inventory
        - Security scan results
        - Quality metrics
        - Container registry status
    
    - "04_Infrastructure_Setup.ipynb":
        - Resource provisioning
        - Network configuration
        - Security hardening
        - Load balancer setup
        - SSL/TLS configuration
    
    - "05_Database_Migration.ipynb":
        - Backup verification
        - Migration execution
        - Data validation
        - Performance testing
        - Rollback procedures
    
    - "06_Application_Deployment.ipynb":
        - Deployment progress
        - Health check results
        - Traffic routing
        - Performance metrics
        - Error monitoring
    
    - "07_Monitoring_Setup.ipynb":
        - Metrics configuration
        - Dashboard creation
        - Alert rules
        - Log aggregation
        - Trace setup
    
    - "08_Validation_Results.ipynb":
        - Functional tests
        - Performance tests
        - Security tests
        - Integration tests
        - User acceptance
    
    - "09_Operational_Handover.ipynb":
        - Runbook links
        - Contact information
        - Escalation procedures
        - Maintenance windows
        - Known issues

validation_criteria:
  deployment_completeness: "MANDATORY - 100% components deployed"
  zero_downtime_achieved: "MANDATORY - No service interruption"
  health_check_passage: "MANDATORY - All checks passing"
  performance_targets: "MANDATORY - SLAs met or exceeded"
  security_compliance: "MANDATORY - All scans clean"
  monitoring_coverage: "MANDATORY - 100% observability"
  documentation_quality: "MANDATORY - Complete runbooks"
  rollback_tested: "MANDATORY - Rollback verified"

final_deliverables:
  - Deployment_Execution_Log.ipynb (complete deployment record)
  - System_Health_Dashboard.ipynb (real-time status)
  - Performance_Validation.ipynb (load test results)
  - Security_Audit_Report.ipynb (penetration test results)
  - Monitoring_Configuration.ipynb (observability setup)
  - Operational_Runbooks.ipynb (procedures and guides)
  - Rollback_Procedures.ipynb (recovery documentation)
  - Post_Deployment_Report.ipynb (summary and metrics)
  - Lessons_Learned.ipynb (improvement opportunities)

# Execution Command
usage: |
  /code-deploy dev local                # Deploy to local dev
  /code-deploy test docker-desktop       # Deploy to Docker Desktop test
  /code-deploy staging k8s              # Deploy to Kubernetes staging
  /code-deploy prod cloud-aws           # Deploy to AWS production

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST deploy ALL components
  - MUST ensure ZERO downtime
  - MUST validate at EVERY stage
  - MUST have rollback ready
  - MUST monitor continuously
  - MUST follow best practices
  - MUST document everything
  - MUST achieve 100% success
  
  STRICTLY FORBIDDEN:
  - NO partial deployments
  - NO manual processes
  - NO untested changes
  - NO monitoring gaps
  - NO security shortcuts
  - NO documentation skips
  - NO cowboy deployments
  - NO production experiments