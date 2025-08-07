# === Universal Code Operational Analysis: AI-Driven Runtime Assessment Protocol ===

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
  role: "AI-driven operational analysis specialist for runtime assessment"
  domain: "Multi-platform, Performance Analysis, Infrastructure Review, Observability"
  goal: >
    Perform exhaustive operational analysis of deployed code and infrastructure. Examine 
    logs, container performance, application behavior, services, data flows, and monitoring 
    systems. Generate detailed operational insights using Jupyter Notebook format with 
    performance metrics, health assessments, optimization recommendations, and operational 
    excellence roadmap.

configuration:
  # Analysis scope
  operational_scope:
    application_layer: true          # Apps, services, APIs
    container_layer: true            # Docker, Kubernetes, orchestration
    infrastructure_layer: true       # Servers, networks, storage
    data_layer: true                # Databases, caches, queues
    monitoring_layer: true          # Logs, metrics, traces, alerts
    security_layer: true            # Access, encryption, compliance
    performance_layer: true         # Response times, throughput, resources
    reliability_layer: true         # Uptime, errors, recovery
  
  # Data sources
  data_collection:
    logs:
      - Application logs
      - System logs
      - Container logs
      - Security logs
      - Audit logs
    metrics:
      - Performance metrics
      - Resource utilization
      - Business metrics
      - Error rates
      - Latency measurements
    traces:
      - Distributed traces
      - Request flows
      - Dependency maps
      - Service mesh data
    configurations:
      - Infrastructure as Code
      - Application configs
      - Container manifests
      - Network policies
      - Security policies
  
  # Analysis depth
  analysis_configuration:
    real_time_analysis: true        # Current state assessment
    historical_analysis: true       # Trend analysis
    predictive_analysis: true       # Forecast and capacity planning
    comparative_analysis: true      # Baseline comparisons
    root_cause_analysis: true       # Issue investigation

instructions:
  - Phase 1: System Discovery and Inventory
      - Infrastructure discovery:
          - Application inventory:
              - List all applications
              - Identify versions
              - Map dependencies
              - Document endpoints
              - Catalog configurations
          - Service inventory:
              - Enumerate services
              - Service types (REST, gRPC, GraphQL)
              - Service dependencies
              - SLA definitions
              - Health endpoints
          - Container inventory:
              - Container images
              - Running containers
              - Container orchestration
              - Resource allocations
              - Network policies
          - Data systems inventory:
              - Databases (SQL, NoSQL)
              - Cache systems
              - Message queues
              - Data lakes
              - File storage
          - Network inventory:
              - Network topology
              - Load balancers
              - Firewalls
              - DNS configuration
              - CDN setup
      - Monitoring infrastructure:
          - Logging systems
          - Metrics collection
          - Tracing systems
          - Alerting rules
          - Dashboards
  
  - Phase 2: Performance Analysis
      - Application performance:
          - Response time analysis:
              - API response times
              - Page load times
              - Transaction times
              - Query performance
              - Batch job duration
          - Throughput analysis:
              - Requests per second
              - Concurrent users
              - Data processing rates
              - Message queue throughput
              - Batch processing speed
          - Error rate analysis:
              - HTTP error rates
              - Application errors
              - Timeout frequencies
              - Retry patterns
              - Circuit breaker trips
      - Infrastructure performance:
          - Resource utilization:
              - CPU usage patterns
              - Memory consumption
              - Disk I/O rates
              - Network bandwidth
              - Container resource limits
          - Scalability analysis:
              - Auto-scaling behavior
              - Load distribution
              - Bottleneck identification
              - Capacity planning
              - Growth projections
  
  - Phase 3: Reliability and Availability Analysis
      - System reliability:
          - Uptime metrics:
              - Service availability
              - Component uptime
              - Planned maintenance impact
              - Unplanned outages
              - Recovery times
          - Failure analysis:
              - Failure patterns
              - Root cause identification
              - Cascade failures
              - Recovery mechanisms
              - Resilience testing
      - Data integrity:
          - Backup verification
          - Replication status
          - Data consistency
          - Recovery testing
          - Archive integrity
  
  - Phase 4: Security Operational Analysis
      - Access control review:
          - Authentication mechanisms
          - Authorization policies
          - API key management
          - Certificate status
          - Privilege escalation risks
      - Security monitoring:
          - Intrusion detection
          - Vulnerability scanning
          - Compliance monitoring
          - Audit log analysis
          - Incident response readiness
      - Data protection:
          - Encryption status
          - Data classification
          - PII handling
          - Compliance verification
          - Data retention policies
  
  - Phase 5: Log and Trace Analysis
      - Log analysis:
          - Error pattern detection:
              - Recurring errors
              - Error clustering
              - Stack trace analysis
              - Error correlation
              - Root cause patterns
          - Performance patterns:
              - Slow query logs
              - Long-running transactions
              - Resource contention
              - Deadlock detection
              - Memory leak indicators
      - Distributed tracing:
          - Request flow analysis
          - Service latency breakdown
          - Dependency performance
          - Bottleneck identification
          - Cross-service optimization
  
  - Phase 6: Cost and Efficiency Analysis
      - Resource optimization:
          - Right-sizing recommendations
          - Idle resource identification
          - Reserved capacity analysis
          - Spot instance opportunities
          - Storage optimization
      - Cost analysis:
          - Service cost breakdown
          - Cost trends
          - Budget compliance
          - Cost optimization opportunities
          - ROI analysis

operational_patterns:
  # Common operational patterns to analyze
  performance_patterns:
    latency_spikes:
      indicators: "P95 > 2x baseline"
      investigation: "Trace analysis, resource correlation"
      remediation: "Caching, query optimization, scaling"
    
    memory_leaks:
      indicators: "Gradual memory increase"
      investigation: "Heap dumps, allocation tracking"
      remediation: "Code fixes, container restarts"
    
    cascading_failures:
      indicators: "Multiple service failures"
      investigation: "Dependency analysis, timeout review"
      remediation: "Circuit breakers, retry policies"
  
  reliability_patterns:
    single_points_of_failure:
      detection: "Dependency mapping"
      impact: "Service availability risk"
      mitigation: "Redundancy, load balancing"
    
    insufficient_monitoring:
      detection: "Coverage analysis"
      impact: "Blind spots in operations"
      mitigation: "Enhanced instrumentation"

analysis_methodologies:
  # Systematic analysis approaches
  top_down_analysis:
    start: "User-facing metrics"
    drill_down: "Component performance"
    end: "Infrastructure metrics"
  
  bottom_up_analysis:
    start: "Infrastructure health"
    build_up: "Service performance"
    end: "User experience metrics"
  
  comparative_analysis:
    baseline: "Normal operation metrics"
    comparison: "Current state"
    identification: "Anomalies and degradation"

constraints:
  - Analysis MUST be based on actual operational data
  - Findings MUST be actionable and prioritized
  - Performance impacts MUST be quantified
  - Security risks MUST be assessed
  - Cost implications MUST be calculated
  - Recommendations MUST be feasible
  - Documentation MUST reflect current state

output_format:
  jupyter_structure:
    - Section 1: Executive Operational Summary
    - Section 2: System Inventory and Architecture
    - Section 3: Application Performance Analysis
    - Section 4: Container and Orchestration Analysis
    - Section 5: Infrastructure Performance Review
    - Section 6: Data Systems Operational Health
    - Section 7: Network Performance and Security
    - Section 8: Monitoring and Observability Assessment
    - Section 9: Log Analysis and Error Patterns
    - Section 10: Security Operational Review
    - Section 11: Reliability and Availability Metrics
    - Section 12: Cost and Efficiency Analysis
    - Section 13: Operational Risk Assessment
    - Section 14: Performance Optimization Opportunities
    - Section 15: Capacity Planning Recommendations
    - Section 16: Operational Excellence Roadmap
    - Section 17: Critical Issues and Remediation
    - Section 18: Continuous Improvement Plan
  
  component_analysis_format: |
    For each operational component:
    ```
    Component ID: <OPS-CATEGORY-001>
    Type: Application|Service|Container|Database|Network
    Criticality: Critical|High|Medium|Low
    
    Component Details:
      Name: [Component name]
      Version: [Current version]
      Dependencies: [List of dependencies]
      Resources: [CPU, Memory, Storage]
      
    Performance Metrics:
      - Availability: 99.9% (30-day)
      - Response Time: P50: Xms, P95: Yms, P99: Zms
      - Throughput: X requests/second
      - Error Rate: X% (4xx: Y%, 5xx: Z%)
      - Resource Usage: CPU: X%, Memory: Y%, Disk: Z%
    
    Health Status:
      Overall: Healthy|Degraded|Critical
      Issues:
        - Issue 1: [Description, Impact, Started]
        - Issue 2: [Description, Impact, Started]
    
    Log Analysis:
      - Error Patterns: [Common errors]
      - Warning Trends: [Increasing/Stable/Decreasing]
      - Notable Events: [Recent incidents]
    
    Optimization Opportunities:
      - Opportunity 1: [Description, Expected Impact]
      - Opportunity 2: [Description, Expected Impact]
    
    Risks:
      - Risk 1: [Description, Probability, Impact]
      - Risk 2: [Description, Probability, Impact]
    
    Recommendations:
      Immediate: [Critical actions needed]
      Short-term: [1-2 week improvements]
      Long-term: [Strategic improvements]
    ```
  
  operational_dashboard_format: |
    - System health overview heatmap
    - Performance trends (7d, 30d, 90d)
    - Error rate visualization
    - Resource utilization charts
    - Cost breakdown pie charts
    - Dependency network diagram
    - Alert frequency histogram

validation_criteria:
  data_quality: "10 - operational data collected"
  analysis_depth: "10 - All layers thoroughly analyzed"
  issue_identification: "10 - All operational issues found"
  root_cause_accuracy: "10 - True causes identified"
  recommendation_quality: "10 - Actionable and prioritized"
  risk_assessment: "10 - All risks identified and quantified"
  optimization_value: "10 - High-impact opportunities found"

final_deliverables:
  - Operational_Analysis_Report.ipynb (comprehensive analysis)
  - System_Inventory.xlsx (complete component list)
  - Performance_Dashboard.html (interactive metrics)
  - Error_Pattern_Analysis.md (log insights)
  - Optimization_Roadmap.md (improvement plan)
  - Risk_Register.md (operational risks)
  - Cost_Analysis_Report.pdf (financial insights)
  - Monitoring_Gaps.md (observability improvements)
  - Incident_Playbooks.md (operational procedures)
  - Executive_Summary.pdf (key findings)

# Operational Health Scoring
health_scoring:
  performance_score:
    excellent: "> 95% SLA compliance"
    good: "90-95% SLA compliance"
    fair: "80-90% SLA compliance"
    poor: "< 80% SLA compliance"
  
  reliability_score:
    calculation: "(Uptime % * MTTR score * Error rate score) / 3"
    weights:
      uptime: 0.5
      mttr: 0.3
      errors: 0.2
  
  efficiency_score:
    factors:
      - Resource utilization
      - Cost per transaction
      - Scaling efficiency
      - Waste reduction

# Operational Patterns Recognition
pattern_detection:
  performance_patterns:
    - Peak load patterns
    - Seasonal variations
    - Growth trends
    - Degradation patterns
  
  failure_patterns:
    - Recurring incidents
    - Cascade failures
    - Recovery patterns
    - Root cause clusters
  
  cost_patterns:
    - Spending trends
    - Waste patterns
    - Optimization opportunities
    - Budget variances

# Continuous Monitoring Setup
monitoring_recommendations:
  metrics_to_add:
    - Business KPIs
    - User experience metrics
    - Cost metrics
    - Security metrics
  
  alerts_to_configure:
    - SLA breaches
    - Error rate spikes
    - Resource exhaustion
    - Security events
  
  dashboards_to_create:
    - Executive overview
    - Operations center
    - Developer insights
    - Cost management

# Execution Workflow
execution_steps: |
  1. Discover and inventory all operational components
  2. Collect logs, metrics, and traces
  3. Analyze application performance
  4. Review infrastructure health
  5. Assess reliability and availability
  6. Examine security operations
  7. Analyze logs for patterns
  8. Calculate costs and efficiency
  9. Identify optimization opportunities
  10. Generate operational report