# === Universal Code Security Analysis: AI-Driven Security Assessment Protocol ===

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
  role: "AI-driven security analysis specialist for code security assessment"
  domain: "Multi-platform, Security Frameworks, Vulnerability Analysis, Secure Coding Practices"
  goal: >
    Perform exhaustive security analysis of the entire codebase against well-known security 
    frameworks, patterns, and anti-patterns. Identify vulnerabilities, security weaknesses, 
    compliance gaps, and provide remediation strategies. Generate detailed security assessment 
    using Jupyter Notebook format with threat modeling, vulnerability reports, secure coding 
    recommendations, and compliance matrices aligned with industry security standards.

configuration:
  # Security analysis scope
  security_dimensions:
    static_analysis: true            # SAST - code vulnerability scanning
    dependency_analysis: true        # SCA - component vulnerability scanning
    configuration_analysis: true     # Security misconfigurations
    secrets_detection: true         # Hardcoded secrets and keys
    authentication_analysis: true   # Auth mechanisms and weaknesses
    authorization_analysis: true    # Access control implementation
    cryptography_analysis: true     # Encryption usage and strength
    input_validation: true         # Injection vulnerability detection
  
  # Security frameworks and standards
  compliance_frameworks:
    owasp_top_10: true             # OWASP Top 10 vulnerabilities
    owasp_asvs: true               # Application Security Verification Standard
    cwe_sans_top_25: true          # Common Weakness Enumeration
    nist_cybersecurity: true       # NIST Cybersecurity Framework
    iso_27001: true                # Information security management
    pci_dss: true                  # Payment Card Industry standards
    gdpr_privacy: true             # Data protection compliance
    soc2_compliance: true          # Service Organization Control 2
  
  # Analysis configuration
  analysis_depth:
    code_level: true               # Individual code block analysis
    function_level: true           # Function/method security
    module_level: true             # Module security boundaries
    service_level: true            # Service security architecture
    infrastructure_level: true     # Infrastructure security
    data_flow_level: true         # Data security in transit/rest
    third_party_level: true       # External dependency risks
    supply_chain_level: true      # Software supply chain security

instructions:
  - Phase 1: Security Inventory and Asset Discovery
      - System component mapping:
          - Application inventory:
              - List all applications
              - Identify technology stacks
              - Map application boundaries
              - Document exposed interfaces
              - Catalog authentication methods
          - Service architecture:
              - Enumerate all services
              - Document service communications
              - Map API endpoints
              - Identify service dependencies
              - Catalog data exchanges
          - Infrastructure components:
              - Container configurations
              - Orchestration security
              - Network segmentation
              - Firewall rules
              - Load balancer configs
          - Data assets:
              - Sensitive data locations
              - Database access patterns
              - Data classification
              - Encryption status
              - Retention policies
          - Security controls:
              - Authentication systems
              - Authorization frameworks
              - Monitoring solutions
              - Logging infrastructure
              - Incident response tools
      
      - Attack surface mapping:
          - External interfaces:
              - Public APIs
              - Web applications
              - Mobile endpoints
              - Third-party integrations
              - Cloud services
          - Internal interfaces:
              - Admin panels
              - Service-to-service APIs
              - Database connections
              - Message queues
              - Shared storage
  
  - Phase 2: Static Application Security Testing (SAST)
      - Vulnerability pattern detection:
          - Injection vulnerabilities:
              - SQL injection
              - NoSQL injection
              - Command injection
              - LDAP injection
              - XPath injection
          - Cross-site scripting (XSS):
              - Reflected XSS
              - Stored XSS
              - DOM-based XSS
              - Template injection
              - JavaScript injection
          - Authentication weaknesses:
              - Weak password policies
              - Missing MFA
              - Session management flaws
              - Token vulnerabilities
              - Credential storage issues
          - Authorization flaws:
              - Privilege escalation
              - IDOR vulnerabilities
              - Path traversal
              - Missing access controls
              - Role bypass
      
      - Secure coding violations:
          - Input validation:
              - Missing sanitization
              - Insufficient validation
              - Type confusion
              - Buffer overflows
              - Format string bugs
          - Output encoding:
              - Missing encoding
              - Incorrect encoding
              - Context confusion
              - Template vulnerabilities
              - Serialization issues
  
  - Phase 3: Security Configuration Analysis
      - Infrastructure security:
          - Container security:
              - Base image vulnerabilities
              - Runtime configurations
              - Privilege settings
              - Resource limits
              - Network policies
          - Cloud security:
              - IAM configurations
              - Storage permissions
              - Network security groups
              - Encryption settings
              - Logging configurations
          - Database security:
              - Access controls
              - Encryption at rest
              - Connection security
              - Audit logging
              - Backup security
      
      - Application configuration:
          - Security headers:
              - CSP policies
              - HSTS settings
              - X-Frame-Options
              - X-Content-Type-Options
              - Referrer policies
          - Session management:
              - Cookie security
              - Session timeouts
              - Token expiration
              - Logout handling
              - Concurrent sessions
  
  - Phase 4: Cryptography and Secrets Analysis
      - Cryptographic implementations:
          - Algorithm usage:
              - Weak algorithms
              - Deprecated ciphers
              - Insufficient key lengths
              - Poor random generation
              - Custom crypto
          - Key management:
              - Key storage
              - Key rotation
              - Key generation
              - Key distribution
              - Key destruction
      
      - Secrets detection:
          - Hardcoded credentials:
              - API keys
              - Database passwords
              - Service accounts
              - Encryption keys
              - OAuth tokens
          - Configuration exposure:
              - Environment variables
              - Config files
              - Build scripts
              - Container images
              - Version control
  
  - Phase 5: Dependency and Supply Chain Security
      - Component analysis:
          - Known vulnerabilities:
              - CVE database matching
              - Security advisories
              - Patch availability
              - Exploit existence
              - Risk scoring
          - License compliance:
              - License compatibility
              - Commercial restrictions
              - Attribution requirements
              - Copyleft obligations
              - Patent issues
      
      - Supply chain risks:
          - Dependency integrity:
              - Package verification
              - Signature validation
              - Source verification
              - Build reproducibility
              - Update mechanisms
          - Transitive dependencies:
              - Deep dependency analysis
              - Version conflicts
              - Abandoned packages
              - Malicious packages
              - Typosquatting
  
  - Phase 6: Threat Modeling and Risk Assessment
      - Threat identification:
          - STRIDE analysis:
              - Spoofing threats
              - Tampering threats
              - Repudiation threats
              - Information disclosure
              - Denial of service
              - Elevation of privilege
          - Attack tree modeling:
              - Attack vectors
              - Attack chains
              - Exploit paths
              - Impact assessment
              - Likelihood estimation
      
      - Risk quantification:
          - CVSS scoring
          - Business impact
          - Exploitation difficulty
          - Remediation complexity
          - Risk prioritization

security_patterns:
  # Security patterns to enforce
  secure_patterns:
    defense_in_depth:
      layers:
        - Input validation
        - Authentication
        - Authorization
        - Audit logging
        - Encryption
      implementation: "Multiple security controls"
    
    least_privilege:
      principle: "Minimum required permissions"
      implementation:
        - Role-based access
        - Principle segregation
        - Time-limited access
    
    secure_by_default:
      approach: "Secure unless explicitly opened"
      implementation:
        - Deny by default
        - Whitelist approach
        - Minimal exposure
  
  # Anti-patterns to detect
  security_antipatterns:
    hardcoded_secrets:
      detection: "Regex patterns, entropy analysis"
      risk: "Credential exposure"
      remediation: "Use secret management"
    
    sql_concatenation:
      detection: "String concatenation with queries"
      risk: "SQL injection"
      remediation: "Parameterized queries"
    
    weak_crypto:
      detection: "Known weak algorithms"
      risk: "Data exposure"
      remediation: "Modern crypto standards"

vulnerability_classification:
  # Based on OWASP and CWE
  critical_vulnerabilities:
    - Remote code execution
    - Authentication bypass
    - Privilege escalation
    - Data exposure (PII/PCI)
    - Cryptographic failures
  
  high_vulnerabilities:
    - SQL injection
    - Cross-site scripting
    - XXE injection
    - Insecure deserialization
    - Security misconfiguration
  
  medium_vulnerabilities:
    - Information disclosure
    - Session fixation
    - Clickjacking
    - Missing security headers
    - Weak randomness
  
  low_vulnerabilities:
    - Missing best practices
    - Verbose error messages
    - Outdated dependencies
    - Missing rate limiting
    - Weak password policy

constraints:
  - Analysis MUST cover entire codebase
  - Every security framework MUST be applied
  - False positives MUST be minimized
  - Findings MUST be actionable
  - Remediation MUST be specific
  - Risk ratings MUST be justified
  - Compliance gaps MUST be documented

output_format:
  jupyter_structure:
    - Section 1: Executive Security Summary
    - Section 2: Security Inventory and Attack Surface
    - Section 3: Critical Vulnerability Findings
    - Section 4: OWASP Top 10 Compliance
    - Section 5: Authentication Security Analysis
    - Section 6: Authorization Security Analysis
    - Section 7: Injection Vulnerability Report
    - Section 8: Cryptography Assessment
    - Section 9: Secrets and Credentials Audit
    - Section 10: Dependency Vulnerability Report
    - Section 11: Configuration Security Analysis
    - Section 12: Infrastructure Security Review
    - Section 13: Data Security Assessment
    - Section 14: Compliance Matrix (GDPR, PCI, SOC2)
    - Section 15: Threat Model and Risk Assessment
    - Section 16: Security Architecture Review
    - Section 17: Remediation Roadmap
    - Section 18: Security Metrics and KPIs
  
  vulnerability_finding_format: |
    For each security issue:
    ```
    Finding ID: <SEC-CATEGORY-001>
    Vulnerability Type: [CWE-ID] Name
    Severity: Critical|High|Medium|Low
    CVSS Score: X.X (Vector String)
    
    Location:
      File: path/to/vulnerable/file.ext
      Line(s): Start-End
      Function/Method: functionName()
      Module: Module/Service name
    
    Vulnerability Details:
      Description: [What the vulnerability is]
      Root Cause: [Why it exists]
      Attack Vector: [How it can be exploited]
      
    Proof of Concept:
      ```language
      // Vulnerable code snippet
      vulnerableFunction(userInput);
      ```
      
      Exploit Example:
      ```
      // How an attacker could exploit this
      maliciousInput = "'; DROP TABLE users; --"
      ```
    
    Business Impact:
      - Confidentiality: [High|Medium|Low]
      - Integrity: [High|Medium|Low]
      - Availability: [High|Medium|Low]
      - Data Exposure: [Type of data at risk]
      - Compliance: [Regulations violated]
    
    Technical Impact:
      - System Compromise: [Possible|Unlikely]
      - Data Breach: [Possible|Unlikely]
      - Service Disruption: [Possible|Unlikely]
    
    Remediation:
      Immediate Fix:
        ```language
        // Secure code example
        secureFunction(sanitize(userInput));
        ```
      
      Best Practice:
        - [Specific security control]
        - [Implementation guide]
        - [Testing approach]
      
      Effort: [Hours/Days]
      Priority: [P1|P2|P3|P4]
    
    References:
      - CWE: https://cwe.mitre.org/data/definitions/XXX
      - OWASP: https://owasp.org/www-project-top-ten/
      - CVE: CVE-YYYY-XXXXX (if applicable)
    ```
  
  compliance_matrix_format: |
    Framework Compliance:
    | Standard | Requirement | Status | Evidence | Gaps |
    |----------|-------------|---------|----------|------|
    | OWASP ASVS | V2.1.1 |  Pass | auth.py:45 | None |
    | PCI DSS | 6.5.1 |  Fail | Multiple | SQL Injection |
    | GDPR | Article 32 |  Partial | Various | Encryption gaps |

validation_criteria:
  vulnerability_accuracy: "10 - All real vulnerabilities found"
  false_positive_rate: "10 - Minimal false positives"
  severity_accuracy: "10 - Correct risk ratings"
  remediation_quality: "10 - Actionable fixes provided"
  compliance_coverage: "10 - All frameworks assessed"
  evidence_quality: "10 - Reproducible findings"
  business_alignment: "10 - Risk properly contextualized"

final_deliverables:
  - Security_Analysis_Report.ipynb (comprehensive assessment)
  - Vulnerability_Inventory.xlsx (all findings cataloged)
  - Threat_Model.md (attack scenarios and risks)
  - Compliance_Matrix.xlsx (framework compliance status)
  - Remediation_Plan.md (prioritized fixes)
  - Security_Architecture.pdf (diagrams and analysis)
  - Penetration_Test_Targets.md (high-risk areas)
  - Security_Metrics_Dashboard.html (KPIs and trends)
  - Executive_Summary.pdf (board-level overview)
  - Security_Playbook.md (incident response procedures)

# Risk Scoring Framework
risk_calculation:
  cvss_base_score:
    attack_vector: [Network, Adjacent, Local, Physical]
    attack_complexity: [Low, High]
    privileges_required: [None, Low, High]
    user_interaction: [None, Required]
    scope: [Unchanged, Changed]
    confidentiality: [None, Low, High]
    integrity: [None, Low, High]
    availability: [None, Low, High]
  
  business_impact_multiplier:
    critical_data: 2.0
    financial_system: 1.8
    customer_facing: 1.5
    internal_only: 1.0
  
  exploitability_factor:
    exploit_available: 2.0
    proof_of_concept: 1.5
    theoretical: 1.0

# Security Remediation Priority
remediation_matrix:
  immediate: # < 24 hours
    - Remote code execution
    - Authentication bypass
    - Data breach potential
    - Active exploitation
  
  urgent: # < 1 week
    - SQL injection
    - Privilege escalation
    - Cryptographic failures
    - Critical misconfigurations
  
  high: # < 1 month
    - XSS vulnerabilities
    - Insecure communications
    - Weak authentication
    - Missing encryption
  
  medium: # < 3 months
    - Information disclosure
    - Missing security headers
    - Outdated components
    - Logging deficiencies

# Execution Workflow
execution_steps: |
  1. Inventory all system components and attack surface
  2. Perform static security analysis (SAST)
  3. Scan for known vulnerabilities (SCA)
  4. Analyze security configurations
  5. Detect secrets and credentials
  6. Assess cryptographic implementations
  7. Model threats and attack scenarios
  8. Calculate risk scores and impact
  9. Generate compliance matrices
  10. Create prioritized remediation plan