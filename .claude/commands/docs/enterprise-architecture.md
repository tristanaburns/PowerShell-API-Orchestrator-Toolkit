# Enterprise Architecture Documentation Command

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
2. **READ AND INDEX: `./claude/commands/protocol/documentation-protocol-mandatory.md`** - MANDATORY documentation protocol
3. **READ AND INDEX: `./claude/commands/protocol/enduring-documentation-enforcement.md`** - MANDATORY enforcement protocol
4. VERIFY: User has given explicit permission to proceed
5. ACKNOWLEDGE: ALL CANONICAL PROTOCOL requirements including documentation protocols

**FORBIDDEN:** Proceeding without complete protocol compliance verification

### 2. MANDATORY DOCUMENTATION PROTOCOL ENFORCEMENT - RFC 2119 COMPLIANCE

**CANONICAL REQUIREMENT - DOCUMENTATION PROTOCOL READING:**
- **MUST READ AND ACKNOWLEDGE:** Production code deployment focused documentation protocol
- **MUST READ AND ACKNOWLEDGE:** Enduring documentation enforcement and destruction protocol
- **MANDATORY COMPLIANCE:** All architecture documentation creation MUST comply with enduring documentation directive
- **DESTRUCTION PROTOCOL:** Non-compliant documentation WILL BE DESTROYED per canonical directive

**FOR ALL ENTERPRISE ARCHITECTURE DOCUMENTATION, YOU MUST:**
- **MUST:** Create enduring architecture documentation that explains HOW TO USE architectural patterns and systems
- **MUST NOT:** Create temporal documents recording architectural changes made
- **MUST:** Follow date-stamped version-controlled filename convention
- **MUST:** Create documentation ONLY when explicitly instructed by user
- **FORBIDDEN:** Proactive architecture documentation creation without explicit user instruction
- **MUST:** Create documentation ONLY in Jupyter notebooks with proper cell structure
- **MUST:** Focus on enduring architectural guidance and system usage patterns

### 3. GIT BEST PRACTICES - MANDATORY

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


**REMEMBER:** Professional enterprise development requires discipline, planning, and systematic execution. NO SHORTCUTS.

Generate enterprise-class professional architecture and design documentation following Ditaxis principles for: $argument

## Architecture Documentation Framework

### Document Type Selection
Follow Ditaxis framework to determine documentation type:

1. **Tutorial** - Learning-oriented architecture guides
2. **How-to Guide** - Task-oriented implementation guides  
3. **Reference** - Information-oriented technical specifications
4. **Explanation** - Understanding-oriented design rationale

### Enterprise Architecture Requirements

The documentation MUST ALWAYS be written to include detailed architecture design technical content with coverage of:

#### 1. High-Level Architecture
```mermaid
graph TB
    subgraph "Enterprise Architecture Overview"
        A[External Systems] --> B[API Gateway]
        B --> C[Application Layer]
        C --> D[Business Logic Layer]
        D --> E[Data Access Layer]
        E --> F[Data Storage Layer]
    end
```

**Required Content:**
- System landscape and boundaries
- Stakeholder identification
- Business context and drivers
- Architectural principles and constraints
- Technology stack overview
- Integration patterns

#### 2. Architecture Components
```mermaid
C4Component
    title Component Diagram - System Components
    Person(user, "User", "System user")
    Container_Boundary(system, "System") {
        Component(api, "API Component", "REST API", "Handles requests")
        Component(service, "Business Service", "Service Layer", "Business logic")
        Component(data, "Data Component", "Data Access", "Data operations")
    }
    Rel(user, api, "Uses")
    Rel(api, service, "Calls")
    Rel(service, data, "Reads/Writes")
```

**Required Content:**
- Component identification and responsibilities
- Component interfaces and contracts
- Component lifecycle management
- Deployment architecture
- Infrastructure components
- Security components

#### 3. Workflow Architecture
```mermaid
sequenceDiagram
    participant User
    participant API
    participant Service
    participant Database
    
    User->>API: Request
    API->>Service: Process
    Service->>Database: Query
    Database-->>Service: Result
    Service-->>API: Response
    API-->>User: Result
```

**Required Content:**
- End-to-end process flows
- Decision points and business rules
- Error handling workflows
- Exception pathways
- Performance critical paths
- Security checkpoints

#### 4. Component Dependency Matrices
```mermaid
mindmap
  root((Dependencies))
    Services
      Authentication
      Authorization
      Logging
      Monitoring
    Infrastructure
      Load Balancer
      Database
      Cache
      Message Queue
    External
      Third-party APIs
      Legacy Systems
      Cloud Services
```

**Required Content:**
- Component dependency mapping
- Circular dependency identification
- Dependency hierarchy levels
- Runtime dependencies vs build dependencies
- Version compatibility matrices
- Impact analysis matrices

#### 5. Service-Level Architecture
```mermaid
graph LR
    subgraph "Microservices Architecture"
        MS1[User Service]
        MS2[Order Service]
        MS3[Payment Service]
        MS4[Notification Service]
        
        MS1 --> MS2
        MS2 --> MS3
        MS3 --> MS4
        
        MS1 --> DB1[(User DB)]
        MS2 --> DB2[(Order DB)]
        MS3 --> DB3[(Payment DB)]
    end
```

**Required Content:**
- Service boundaries and responsibilities
- Service communication patterns
- Data consistency patterns
- Service discovery mechanisms
- Health checks and monitoring
- Scaling and load balancing strategies

#### 6. User Workflows and Stories
```mermaid
journey
    title User Journey - Order Process
    section Discovery
      Browse Products: 5: User
      Search Items: 4: User
      View Details: 5: User
    section Purchase
      Add to Cart: 5: User
      Checkout: 3: User
      Payment: 2: User
    section Fulfillment
      Order Confirmation: 5: User
      Tracking: 4: User
      Delivery: 5: User
```

**Required Content:**
- User personas and roles
- User journey mapping
- Use case scenarios
- Acceptance criteria
- User interface wireframes
- Accessibility requirements

#### 7. Technical Implementation Details

##### Modules, Services, Classes, Functions
```mermaid
classDiagram
    class UserService {
        +createUser()
        +updateUser()
        +deleteUser()
        +getUser()
    }
    
    class UserRepository {
        +save()
        +findById()
        +findByEmail()
        +delete()
    }
    
    class User {
        -id: string
        -email: string
        -name: string
        +validate()
    }
    
    UserService --> UserRepository
    UserRepository --> User
```

**Required Content:**
- Class diagrams with relationships
- Method signatures and parameters
- Data models and schemas
- Interface definitions
- Abstract base classes
- Design patterns implementation

##### Technical Dependency Matrices
```mermaid
graph TD
    A[Application Layer] --> B[Service Layer]
    A --> C[Utility Layer]
    B --> D[Repository Layer]
    B --> C
    D --> E[Database Layer]
    C --> F[External Libraries]
```

**Required Content:**
- Module dependency graphs
- Library and framework dependencies
- Version requirements and constraints
- Dependency injection patterns
- Circular dependency analysis
- Upgrade impact assessment

#### 8. Network Traffic Flows
```mermaid
flowchart TD
    Internet[Internet] --> LB[Load Balancer]
    LB --> WAF[Web Application Firewall]
    WAF --> API[API Gateway]
    API --> MS1[Microservice 1]
    API --> MS2[Microservice 2]
    MS1 --> DB1[(Database 1)]
    MS2 --> DB2[(Database 2)]
    MS1 <--> MQ[Message Queue]
    MS2 <--> MQ
```

**Required Content:**
- Network topology diagrams
- Traffic routing rules
- Load balancing algorithms
- Firewall rules and security zones
- Bandwidth requirements
- Latency targets and SLAs

#### 9. Data Flows
```mermaid
flowchart LR
    Source[Data Source] --> ETL[ETL Process]
    ETL --> DW[Data Warehouse]
    DW --> Analytics[Analytics Engine]
    Analytics --> Dashboard[Dashboard]
    
    Source --> Stream[Stream Processing]
    Stream --> RT[Real-time Analytics]
    RT --> Alerts[Alert System]
```

**Required Content:**
- Data pipeline architecture
- Data transformation processes
- Data quality and validation
- Data governance and compliance
- Backup and recovery procedures
- Data retention policies

### Documentation Structure Template

#### Jupyter Notebook Structure
```python
# Cell 1: Title and Metadata
"""
# Enterprise Architecture Documentation
**System**: [System Name]
**Type**: [Ditaxis Type]
**Last Updated**: [Date]
**Version**: [Version]
**Author**: [Author]
"""

# Cell 2: Executive Summary
"""
## Executive Summary
[High-level overview for executives and stakeholders]
"""

# Cell 3: Architecture Overview
"""
## Architecture Overview
[Mermaid diagrams and high-level description]
"""

# Cell 4: Detailed Components
"""
## Component Details
[Detailed technical specifications]
"""

# Cell 5: Implementation Code Examples
# [Working code examples and demonstrations]

# Cell 6: Dependency Analysis
"""
## Dependency Analysis
[Matrices and relationship diagrams]
"""

# Cell 7: Performance and Scaling
"""
## Performance Considerations
[Performance metrics, bottlenecks, scaling strategies]
"""

# Cell 8: Security Architecture
"""
## Security Design
[Security patterns, threat models, mitigation strategies]
"""
```

#### Markdown Conversion Requirements
After creating Jupyter notebook, convert to markdown with:

- **Table of Contents** with deep linking
- **Mermaid diagram preservation** for GitHub/GitLab rendering
- **Code syntax highlighting** for multiple languages
- **Cross-references** between sections
- **Glossary** of technical terms
- **Index** for quick navigation

### Quality Assurance Checklist

#### Technical Completeness
- [ ] All 9 required architecture areas covered
- [ ] Mermaid diagrams for each major component
- [ ] Code examples tested and working
- [ ] Dependency matrices complete and accurate
- [ ] Performance metrics documented
- [ ] Security considerations addressed

#### Documentation Quality
- [ ] Follows Ditaxis principles
- [ ] Appropriate technical depth for audience
- [ ] Clear and consistent terminology
- [ ] Visual aids support understanding
- [ ] Examples are relevant and practical
- [ ] Navigation aids (TOC, cross-refs) included

#### Professional Standards
- [ ] Enterprise-grade presentation
- [ ] Stakeholder-appropriate language
- [ ] technical coverage
- [ ] Actionable recommendations
- [ ] Future-state roadmap included
- [ ] Compliance and governance addressed

### Output Deliverables

1. **Jupyter Notebook** with interactive content and live code examples
2. **Markdown Documentation** for version control and collaboration
3. **Architecture Diagrams** as separate Mermaid files
4. **Dependency Matrices** as CSV/JSON for analysis tools
5. **Executive Summary** for stakeholder communication

Generate enterprise architecture documentation following these requirements.