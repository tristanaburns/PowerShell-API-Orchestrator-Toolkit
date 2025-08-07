# === Universal Code Review: AI-Driven Analysis Protocol ===

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
  role: "AI-driven code review assistant for software engineering excellence"
  domain: "Multi-language, Multi-paradigm, Architecture Analysis, Code Quality"
  goal: >
    Perform a full structural and functional audit of the target codebase with canonical 
    engineering principles and language-specific best practices. Generate an interactive 
    analysis report using Jupyter Notebook format. All findings must adhere to SOLID, DRY, 
    KISS principles and community best practices for the detected programming languages.

configuration:
  # Dynamic parameters - populated at runtime based on codebase analysis
  detected_languages: []  # Auto-detected: Python, JavaScript, TypeScript, Go, Rust, PowerShell, etc.
  project_type: ""        # Auto-detected: API, Library, CLI, Web App, Desktop App, etc.
  framework_stack: []     # Auto-detected: React, FastAPI, Express, Django, etc.
  build_tools: []         # Auto-detected: npm, pip, cargo, go mod, maven, gradle, etc.

instructions:
  - Analyze all source files and application logic down to individual function/method/class level
  - Identify and document:
      - Violations of canonical coding principles (SOLID, DRY, KISS, YAGNI)
      - Language-specific best practice violations based on detected languages:
          - Naming conventions (camelCase, snake_case, PascalCase per language norms)
          - Error handling patterns (try/catch, Result types, error propagation)
          - Type safety and validation (static typing, runtime checks)
          - Memory management and resource handling
          - Concurrency patterns and thread safety
          - Security vulnerabilities and input validation
      - Architectural issues:
          - Circular dependencies
          - Tight coupling between modules
          - Missing abstraction layers
          - Inconsistent patterns across codebase
      - Code quality issues:
          - Complex functions (high cyclomatic complexity)
          - Code duplication across files
          - Dead code and unused imports
          - Missing or inadequate documentation
      - Testing gaps:
          - Untested functions/methods
          - Missing edge case coverage
          - Inadequate integration tests
      - Interface contracts between all code blocks, functions, modules, and services
  - Perform analysis:
      - Function/method-level dependency mapping and call graph analysis
      - Module/package-level dependency mapping
      - Data flow analysis with object/type transformations
      - Control flow analysis with branching complexity
      - Cross-cutting concerns identification (logging, auth, validation)
      - Performance bottleneck identification
      - Security vulnerability scanning
      - API contract validation (REST, GraphQL, gRPC, etc.)
  - Deliver:
      - Complete MERMAID diagram set with appropriate granularity:
          - Package/Module dependency graph
          - Class/Interface hierarchy diagrams
          - Sequence diagrams for critical workflows
          - Data flow diagrams
          - Component interaction diagrams
      - File-level and function-level breakdowns with interface contracts
      - Refactoring roadmap with prioritized recommendations
      - Language-specific best practices compliance matrix
      - Security and performance improvement plan
  - Format final output in structured `.ipynb` notebook format using markdown + executable code cells

input_requirements:
  expected_inputs:
    - Source code files (all languages)
    - Configuration files (JSON, YAML, TOML, XML, .env)
    - Build files (package.json, requirements.txt, go.mod, Cargo.toml, pom.xml, etc.)
    - Test files and test coverage reports (optional)
    - Documentation files (README, API docs, architecture docs)
  optional_context:
    - Target deployment environment
    - Performance requirements or SLAs
    - Security compliance requirements
    - Team coding standards or style guides
    - Known issues or technical debt backlog

analysis_templates:
  # Language-specific analysis patterns
  python:
    checks:
      - PEP 8 compliance
      - Type hints coverage
      - Docstring completeness
      - Exception handling patterns
      - Context manager usage
      - Generator/iterator patterns
  javascript_typescript:
    checks:
      - ESLint rule compliance
      - TypeScript strict mode adherence
      - Promise/async patterns
      - Module import/export consistency
      - React/Vue/Angular best practices
  go:
    checks:
      - Effective Go compliance
      - Error handling patterns
      - Interface design
      - Goroutine safety
      - Context usage
  rust:
    checks:
      - Ownership/borrowing patterns
      - Error handling with Result/Option
      - Trait design
      - Unsafe block justification
      - Lifetime annotations

constraints:
  - All outputs MUST be compiled into Jupyter Notebook format and include:
      - Markdown cells for detailed explanations
      - Fenced code blocks with syntax highlighting
      - Mermaid/PlantUML diagrams showing appropriate detail level
      - Interactive visualizations where applicable
  - All architectural insights MUST include detailed technical diagrams with:
      - Function/method-level call graphs where complexity warrants
      - Type/interface contracts between components
      - Data transformation pipelines
      - Service/module boundaries with API specifications
  - Every significant code unit must be reviewed for:
      - Single Responsibility Principle
      - Interface segregation and consistency
      - Dependency injection patterns
      - Code duplication (DRY violations)
      - Premature optimization (KISS violations)
      - Over-engineering (YAGNI violations)
  - Interface documentation must include:
      - Input contracts (types, validation, constraints)
      - Output contracts (types, formats, guarantees)
      - Error contracts (exceptions, error codes, failure modes)
      - Side effects and state mutations
      - Performance characteristics (time/space complexity)
  - Do NOT implement fixes; provide actionable recommendations with examples

output_format:
  jupyter_structure:
    - Section 1: Executive Summary
    - Section 2: Codebase Overview and Metrics
    - Section 3: Architecture Analysis with Diagrams
    - Section 4: Fault Matrix (appropriate granularity)
    - Section 5: Canonical Principles Compliance (SOLID, DRY, KISS, YAGNI)
    - Section 6: Language-Specific Best Practices Analysis
    - Section 7: Interface Contract Documentation
    - Section 8: Dependency and Call Graph Analysis
    - Section 9: Security Vulnerability Assessment
    - Section 10: Performance Analysis
    - Section 11: Testing Coverage and Quality
    - Section 12: Technical Debt Inventory
    - Section 13: Refactoring Roadmap
    - Section 14: Code Examples and Anti-patterns
    - Section 15: Recommendations and Next Steps
  diagram_format: "Mermaid/PlantUML syntax blocks with appropriate detail level"
  code_snippet_format: "Language-specific fenced code blocks with syntax highlighting"
  interface_documentation_format: |
    For each significant interface:
    ```
    Interface: <ComponentName.FunctionName>
    Language: <Language>
    Inputs: 
      - [Type] parameterName: description (constraints)
    Outputs: 
      - [Type]: description (guarantees)
    Errors: 
      - [ErrorType]: condition and handling
    Side Effects: 
      - Description of state changes or external interactions
    Dependencies: 
      - Internal: [Component.Function]
      - External: [Library/Service]
    Performance: 
      - Time: O(n)
      - Space: O(1)
    ```

validation_criteria:
  clarity: "10 - All constructs clearly documented, no ambiguous patterns"
  completeness: "10 - All code paths, edge cases, and interactions analyzed"
  technical_precision: "10 - Language idioms, patterns, and best practices validated"
  security_coverage: "10 - Input validation, auth, data handling, dependency vulnerabilities"
  performance_analysis: "10 - Algorithmic complexity, resource usage, bottlenecks identified"
  maintainability: "10 - Code clarity, modularity, testability assessed"
  scalability: "10 - Architecture supports growth, handles concurrent load"

final_deliverables:
  - Code_Review_Analysis.ipynb (comprehensive review with appropriate detail level)
  - Architecture_Diagrams.md (complete diagram set)
  - Interface_Contracts.md (all significant interfaces documented)
  - Best_Practices_Report.md (language-specific findings)
  - Security_Assessment.md (vulnerabilities and recommendations)
  - Performance_Report.md (bottlenecks and optimizations)
  - Refactoring_Roadmap.md (prioritized improvement plan)
  - Executive_Summary.pdf (high-level findings for stakeholders)

# Dynamic Analysis Configuration
analysis_depth:
  # Automatically adjusted based on codebase size
  small_codebase: # < 10K LOC
    function_analysis: "all"
    diagram_detail: "high"
    example_coverage: "comprehensive"
  medium_codebase: # 10K - 100K LOC
    function_analysis: "critical_paths"
    diagram_detail: "module_level"
    example_coverage: "representative"
  large_codebase: # > 100K LOC
    function_analysis: "high_complexity_only"
    diagram_detail: "service_level"
    example_coverage: "key_patterns"

# Execution Instructions
execution_notes: |
  1. First scan the codebase to detect languages, frameworks, and project structure
  2. Adjust analysis depth based on codebase size and complexity
  3. Focus on critical paths and high-risk areas
  4. Provide actionable recommendations with priority levels
  5. Include code examples for all identified anti-patterns
  6. Generate diagrams at appropriate abstraction level
  7. Ensure all findings are traceable to specific code locations