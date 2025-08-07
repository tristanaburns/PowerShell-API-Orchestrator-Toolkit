# === Universal Code Validation: AI-Driven Implementation Verification Protocol ===

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
  role: "AI-driven validation specialist for implementation verification"
  domain: "Multi-language, Quality Assurance, Compliance Verification, Technical Analysis"
  goal: >
    Perform exhaustive technical and procedural validation of code implementation against 
    planning specifications. Verify that executed implementation matches blueprints, meets 
    quality standards, and fulfills all requirements. Generate detailed validation report 
    using Jupyter Notebook format with compliance matrices, quality metrics, and certification 
    of readiness for production deployment.

configuration:
  # Input artifacts for validation
  validation_inputs:
    planning_artifacts:
      implementation_plan: "Implementation_Plan.ipynb"
      technical_specs: "Technical_Specifications.md"
      test_specs: "Test_Specifications.md"
      api_contracts: "API_Contracts.yaml"
    implementation_artifacts:
      implementation_log: "Implementation_Log.ipynb"
      code_changes: "Code_Changes_Summary.md"
      test_results: "Test_Results_Report.md"
      performance_report: "Performance_Analysis.md"
      security_report: "Security_Audit_Report.md"
  
  # Validation scope
  validation_dimensions:
    functional_validation: true      # Features work as specified
    technical_validation: true       # Code quality and architecture
    procedural_validation: true      # Process compliance
    performance_validation: true     # Meets performance targets
    security_validation: true        # Security requirements met
    compliance_validation: true      # Standards adherence
    documentation_validation: true   # Documentation completeness
    operational_validation: true     # Production readiness
  
  # Validation strictness
  validation_mode:
    strict_compliance: true          # Exact match to specifications
    automated_checks: true           # Tool-based validation
    manual_inspection: true          # Human-readable analysis
    regression_testing: true         # No functionality broken
    cross_validation: true           # Multiple validation methods

instructions:
  - Phase 1: Validation Setup and Baseline
      - Load validation artifacts:
          - Parse planning documents:
              - Extract requirements
              - Identify specifications
              - Map expected outcomes
              - Define success criteria
              - List quality targets
          - Parse implementation results:
              - Extract actual changes
              - Collect test results
              - Gather metrics
              - Review issues log
              - Analyze performance data
      - Establish validation criteria:
          - Functional requirements matrix
          - Technical specifications checklist
          - Quality thresholds
          - Performance baselines
          - Security requirements
          - Compliance standards
  
  - Phase 2: Technical Implementation Validation
      - Code implementation verification:
          - Plan vs. actual comparison:
              - Each planned step executed
              - Code matches specifications
              - Patterns correctly applied
              - Standards followed
              - Dependencies satisfied
          - Architecture validation:
              - Component structure correct
              - Interfaces match contracts
              - Data flows as designed
              - Integration points verified
              - Design patterns applied
          - Code quality assessment:
              - Syntax and style compliance
              - Complexity within limits
              - Duplication minimized
              - Maintainability score
              - Readability assessment
      - Technical debt analysis:
          - Shortcuts taken
          - Deferred improvements
          - Known limitations
          - Future refactoring needs
          - Risk assessment
  
  - Phase 3: Functional and Behavioral Validation
      - Feature implementation verification:
          - Requirements coverage:
              - All features implemented
              - Acceptance criteria met
              - User stories satisfied
              - Edge cases handled
              - Error scenarios covered
          - Behavioral validation:
              - Input/output correctness
              - State transitions valid
              - Business logic accurate
              - Data integrity maintained
              - User experience validated
      - Integration validation:
          - Component interactions:
              - APIs function correctly
              - Data flows properly
              - Events trigger correctly
              - Messages route properly
              - Services communicate
          - System behavior:
              - End-to-end scenarios work
              - Performance acceptable
              - Scalability demonstrated
              - Reliability proven
              - Recovery mechanisms work
  
  - Phase 4: Quality and Compliance Validation
      - Testing validation:
          - Test coverage analysis:
              - Unit test coverage
              - Integration test coverage
              - E2E test coverage
              - Edge case coverage
              - Performance test coverage
          - Test quality assessment:
              - Test effectiveness
              - Test maintainability
              - Test reliability
              - Test performance
              - Test documentation
      - Standards compliance:
          - Coding standards:
              - Language conventions
              - Framework guidelines
              - Team standards
              - Industry best practices
              - Security standards
          - Process compliance:
              - Development workflow
              - Review process
              - Testing procedures
              - Documentation standards
              - Deployment practices
  
  - Phase 5: Operational Readiness Validation
      - Deployment readiness:
          - Production criteria:
              - All tests passing
              - Performance verified
              - Security validated
              - Documentation complete
              - Monitoring ready
          - Operational requirements:
              - Logging implemented
              - Metrics exposed
              - Alerts configured
              - Runbooks created
              - Support documented
      - Risk assessment:
          - Technical risks:
              - Known issues
              - Performance bottlenecks
              - Security vulnerabilities
              - Scalability limits
              - Integration challenges
          - Operational risks:
              - Deployment complexity
              - Rollback procedures
              - Data migration
              - Service dependencies
              - Team readiness

validation_methodologies:
  # Systematic validation approaches
  automated_validation:
    static_analysis:
      tools: "Language-specific analyzers"
      checks: "Code quality, security, standards"
      threshold: "Zero critical issues"
    
    dynamic_analysis:
      tools: "Runtime analyzers, profilers"
      checks: "Performance, memory, behavior"
      threshold: "Meets all baselines"
    
    security_scanning:
      tools: "SAST, DAST, dependency scanners"
      checks: "Vulnerabilities, exposures"
      threshold: "No high/critical issues"
  
  manual_validation:
    code_review:
      method: "Line-by-line inspection"
      focus: "Logic, patterns, standards"
      criteria: "Matches specifications"
    
    architectural_review:
      method: "Component analysis"
      focus: "Structure, patterns, interfaces"
      criteria: "Follows design"
    
    documentation_review:
      method: "Completeness check"
      focus: "Accuracy, clarity, coverage"
      criteria: "Production ready"

validation_matrices:
  # Compliance tracking matrices
  requirements_traceability:
    structure: |
      | Requirement ID | Description | Implementation | Test Coverage | Status |
      |----------------|-------------|----------------|---------------|--------|
      | REQ-001        | Feature X   | file.ext:123   | test_x()      |  Pass |
  
  quality_metrics:
    structure: |
      | Metric          | Target | Actual | Status | Notes |
      |-----------------|--------|--------|--------|-------|
      | Test Coverage   | 80%    | 85%    |  Pass |       |
      | Complexity      | < 10   | 8.5    |  Pass |       |
  
  security_compliance:
    structure: |
      | Control         | Required | Implemented | Verified | Status |
      |-----------------|----------|-------------|----------|--------|
      | Input Validation| Yes      | Yes         | Yes      |  Pass |

constraints:
  - Validation MUST be objective and measurable
  - All findings MUST be evidence-based
  - Discrepancies MUST be documented
  - Critical issues MUST block certification
  - Quality metrics MUST meet thresholds
  - Security requirements MUST be satisfied
  - Documentation MUST be complete

output_format:
  jupyter_structure:
    - Section 1: Executive Validation Summary
    - Section 2: Planning vs. Implementation Analysis
    - Section 3: Technical Implementation Validation
    - Section 4: Functional Requirements Verification
    - Section 5: Code Quality Assessment
    - Section 6: Test Coverage and Quality Analysis
    - Section 7: Performance Validation Results
    - Section 8: Security Compliance Verification
    - Section 9: Integration and System Validation
    - Section 10: Documentation Completeness Review
    - Section 11: Standards Compliance Matrix
    - Section 12: Operational Readiness Assessment
    - Section 13: Risk and Issue Analysis
    - Section 14: Deviation and Gap Report
    - Section 15: Remediation Requirements
    - Section 16: Certification Recommendation
    - Section 17: Post-Implementation Metrics
    - Section 18: Continuous Improvement Suggestions
  
  validation_finding_format: |
    For each validation check:
    ```
    Validation ID: <VAL-CATEGORY-001>
    Type: Functional|Technical|Quality|Security|Compliance
    Severity: Critical|High|Medium|Low|Info
    
    Validation Check:
      What was validated and against what criteria
    
    Expected (from Plan):
      - Requirement: [specific requirement]
      - Specification: [technical spec]
      - Acceptance Criteria: [measurable criteria]
    
    Actual (from Implementation):
      - Implementation: [what was built]
      - Evidence: [file:line, test results, metrics]
      - Measurements: [specific values]
    
    Validation Result:
      Status:  Pass |  Warning |  Fail
      Compliance: 100% | Partial | Non-compliant
      
    Findings:
      - Finding 1: [description]
      - Finding 2: [description]
    
    Impact:
      - Functional Impact: [description]
      - Technical Impact: [description]
      - Risk Level: [Critical|High|Medium|Low]
    
    Remediation:
      Required: Yes|No
      Actions: [specific steps needed]
      Effort: [hours/days estimate]
    ```
  
  compliance_dashboard_format: |
    - Requirements coverage heatmap
    - Quality metrics dashboard
    - Test coverage visualization
    - Security compliance scorecard
    - Performance benchmark charts
    - Validation status overview

validation_criteria:
  functional_completeness: "10 - All requirements implemented correctly"
  technical_accuracy: "10 - Implementation matches specifications exactly"
  quality_standards: "10 - All quality metrics meet or exceed targets"
  test_effectiveness: "10 - test coverage and quality"
  security_compliance: "10 - All security requirements satisfied"
  performance_targets: "10 - Meets or exceeds all benchmarks"
  documentation_quality: "10 - Complete, accurate, and maintainable"
  operational_readiness: "10 - Fully prepared for production"

final_deliverables:
  - Validation_Report.ipynb (comprehensive analysis)
  - Compliance_Matrix.xlsx (requirements traceability)
  - Quality_Metrics_Dashboard.html (interactive metrics)
  - Deviation_Report.md (gaps and discrepancies)
  - Risk_Assessment.md (identified risks)
  - Remediation_Plan.md (required fixes)
  - Certification_Statement.pdf (sign-off ready)
  - Test_Evidence_Package.zip (proof of validation)
  - Audit_Trail.md (validation process log)
  - Executive_Summary.pdf (management overview)

# Validation Decision Framework
certification_criteria:
  pass_requirements:
    - All functional requirements implemented
    - No critical or high severity issues
    - Test coverage meets thresholds
    - Performance within targets
    - Security requirements satisfied
    - Documentation complete
  
  conditional_pass:
    - Minor issues with remediation plan
    - Medium severity issues documented
    - Acceptable technical debt
    - Known limitations documented
    - Risk mitigation in place
  
  fail_conditions:
    - Missing functional requirements
    - Critical security vulnerabilities
    - Performance below thresholds
    - Incomplete testing
    - Major quality issues

# Validation Workflow States
validation_states:
  in_progress:
    activities: "Collecting evidence, running checks"
    next: "review_complete"
  
  review_complete:
    activities: "Analyzing results, generating findings"
    next: "decision_pending"
  
  decision_pending:
    activities: "Evaluating against criteria"
    next: "certified|conditional|failed"
  
  certified:
    status: "Ready for production"
    actions: "Generate certificates"
  
  conditional:
    status: "Requires remediation"
    actions: "Create action items"
  
  failed:
    status: "Major issues found"
    actions: "Block deployment"

# Continuous Validation
ongoing_validation:
  post_deployment:
    - Monitor production metrics
    - Track issue reports
    - Validate performance
    - Check security posture
  
  feedback_loop:
    - Update validation criteria
    - Improve test coverage
    - Refine quality metrics
    - Enhance automation

# Execution Workflow
execution_steps: |
  1. Load planning and implementation artifacts
  2. Extract validation criteria and targets
  3. Execute automated validation checks
  4. Perform manual inspections
  5. Compare expected vs. actual results
  6. Identify gaps and deviations
  7. Assess impact and risks
  8. Generate compliance matrices
  9. Make certification decision
  10. Produce validation report and recommendations