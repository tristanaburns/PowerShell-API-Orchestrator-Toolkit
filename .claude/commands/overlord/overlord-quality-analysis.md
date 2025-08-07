# Code Quality Analysis

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

Perform a code quality analysis of the entire PowerShell NSX toolkit codebase against industry-standard best practices, design patterns, and security principles.

## Analysis Framework

### Phase 1: Component Inventory
Create a complete inventory of all system components:

1. **Applications & Entry Points**
   - Enumerate all executable scripts
   - Identify all CLI tools in `/tools/`
   - Map all test executables in `/tests/`
   - Document all utility scripts

2. **Service Architecture**
   - List all services in `/src/services/`
   - Map service dependencies
   - Document service interfaces
   - Identify service contracts

3. **Modules & Libraries**
   - Catalog all PowerShell modules (.psm1)
   - Map module exports and imports
   - Document helper functions
   - Identify shared libraries

4. **Data & Configuration**
   - List all configuration files
   - Map data schemas
   - Document credential stores
   - Identify environment configs

5. **Infrastructure Components**
   - Document API integrations
   - Map network communication
   - List external dependencies
   - Identify monitoring hooks

### Phase 2: SOLID Principles Analysis

1. **Single Responsibility Principle**
   ```
   For each class/module:
   - Count responsibilities
   - Measure cohesion
   - Identify violation patterns
   - Suggest refactoring opportunities
   ```

2. **Open/Closed Principle**
   ```
   Analyze extensibility:
   - Check for hardcoded logic
   - Evaluate configuration flexibility
   - Identify extension points
   - Review modification risks
   ```

3. **Liskov Substitution Principle**
   ```
   Review inheritance/interfaces:
   - Verify contract compliance
   - Check behavioral consistency
   - Identify type violations
   - Analyze polymorphism usage
   ```

4. **Interface Segregation Principle**
   ```
   Examine interfaces:
   - Check interface granularity
   - Identify fat interfaces
   - Review client dependencies
   - Suggest interface splitting
   ```

5. **Dependency Inversion Principle**
   ```
   Analyze dependencies:
   - Map concrete dependencies
   - Check abstraction usage
   - Identify tight coupling
   - Review injection patterns
   ```

### Phase 3: Design Patterns Analysis

1. **Creational Patterns**
   - Factory pattern usage
   - Singleton implementation review
   - Builder pattern identification
   - Prototype pattern analysis

2. **Structural Patterns**
   - Adapter pattern usage
   - Facade pattern implementation
   - Decorator pattern review
   - Proxy pattern analysis

3. **Behavioral Patterns**
   - Strategy pattern usage
   - Observer pattern implementation
   - Command pattern review
   - Template method analysis

### Phase 4: Anti-Pattern Detection

1. **Code Smells**
   - Long methods (>50 lines)
   - Large classes (>500 lines)
   - Feature envy
   - Data clumps
   - Primitive obsession
   - Switch statements abuse
   - Parallel inheritance hierarchies
   - Lazy classes
   - Middle man
   - Message chains

2. **Design Anti-Patterns**
   - God objects/classes
   - Spaghetti code
   - Copy-paste programming
   - Magic numbers/strings
   - Hard coding
   - Premature optimization
   - Over-engineering
   - Under-abstraction
   - Circular dependencies
   - Tight coupling

3. **PowerShell-Specific Anti-Patterns**
   - Pipeline abuse
   - Inefficient filtering
   - Missing error handling
   - Improper scope usage
   - Synchronous-only operations
   - Missing parameter validation
   - Unsafe type conversions
   - Global variable pollution

### Phase 5: Clean Code Principles

1. **Naming Conventions**
   - Function naming clarity
   - Variable naming consistency
   - Parameter naming standards
   - Constant naming patterns

2. **Function Quality**
   - Function length analysis
   - Parameter count review
   - Side effect detection
   - Return type consistency

3. **Code Organization**
   - Module cohesion
   - Logical grouping
   - Dependency organization
   - File structure standards

4. **Comments & Documentation**
   - Comment quality
   - Documentation completeness
   - Code self-documentation
   - Outdated comment detection

### Phase 6: Security Best Practices

1. **Input Validation**
   - Parameter validation coverage
   - Type checking implementation
   - Boundary condition handling
   - Injection prevention

2. **Authentication & Authorization**
   - Credential handling review
   - Permission checking
   - Session management
   - Access control patterns

3. **Cryptography**
   - Encryption usage
   - Key management
   - Hash function selection
   - Random number generation

4. **Error Handling**
   - Exception management
   - Error message exposure
   - Logging practices
   - Fail-safe defaults

### Phase 7: Performance Patterns

1. **Resource Management**
   - Memory usage patterns
   - Connection pooling
   - Object disposal
   - Cache implementation

2. **Algorithmic Efficiency**
   - Time complexity analysis
   - Space complexity review
   - Optimization opportunities
   - Bottleneck identification

### Phase 8: Testing & Maintainability

1. **Testability**
   - Test coverage analysis
   - Mockability assessment
   - Dependency injection usage
   - Test isolation review

2. **Maintainability Metrics**
   - Cyclomatic complexity
   - Coupling metrics
   - Cohesion analysis
   - Change risk assessment

## Quality Metrics & Scoring

### Code Quality Score (0-100)
```
Components:
- SOLID Compliance: 20%
- Pattern Usage: 15%
- Anti-Pattern Absence: 20%
- Clean Code: 15%
- Security: 15%
- Performance: 10%
- Maintainability: 5%
```

### Severity Classification
- **Critical**: Security vulnerabilities, data loss risks
- **High**: Major anti-patterns, SOLID violations
- **Medium**: Code smells, minor pattern issues
- **Low**: Style inconsistencies, optimization opportunities

## Output Deliverables

1. **Executive Dashboard**
   - Overall quality score
   - Critical issue count
   - Trend analysis
   - Improvement roadmap

2. **Detailed Report**
   - Issue catalog by component
   - Best practice violations
   - Pattern analysis results
   - Remediation guidelines

3. **Code Metrics**
   - Complexity measurements
   - Coupling/cohesion metrics
   - Test coverage statistics
   - Technical debt estimation

4. **Visual Analysis**
   - Dependency graphs
   - Complexity heat maps
   - Pattern distribution charts
   - Anti-pattern clustering

## Execution Command

```powershell
# Perform code quality analysis
.\tools\PerformCodeQualityAnalysis.ps1 `
    -Scope "Full" `
    -AnalysisDepth "Comprehensive" `
    -IncludePatterns `
    -IncludeAntiPatterns `
    -IncludeSecurity `
    -IncludePerformance `
    -GenerateVisuals `
    -OutputFormat @("HTML", "JSON", "PDF")
```

## Quality Checkpoints

Ensure complete analysis coverage:
- [ ] All functions analyzed for SOLID compliance
- [ ] All modules checked for patterns
- [ ] All code blocks scanned for anti-patterns
- [ ] All inputs validated for security
- [ ] All algorithms reviewed for efficiency
- [ ] All dependencies mapped
- [ ] All complexity calculated
- [ ] All test coverage measured
- [ ] All documentation reviewed
- [ ] All metrics generated