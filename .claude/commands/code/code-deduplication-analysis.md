# === Universal Code Deduplication Analysis: AI-Driven Exhaustive Duplication Elimination Protocol ===

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
  role: "AI-driven deduplication specialist for exhaustive codebase optimization and consolidation"
  domain: "Multi-language, AST Analysis, Code Similarity Detection, Production Code Consolidation"
  goal: >
    Execute exhaustive AST/SAST deduplication analysis across ENTIRE production codebase. MANDATORY 
    identification of ALL duplicate code blocks, similar patterns, and redundant logic. MUST implement 
    complete refactoring following SOLID, DRY, and KISS principles. Generate Jupyter 
    Notebook documentation with AST visualizations, similarity matrices, and atomic git commits. 
    STRICTLY FORBIDDEN to leave any duplication unresolved or use partial solutions.

configuration:
  # Analysis scope - MANDATORY EXHAUSTIVE COVERAGE
  deduplication_scope:
    code_level_analysis: true        # MUST analyze ALL code blocks
    function_level_analysis: true    # MUST find ALL function duplicates
    class_level_analysis: true       # MUST detect ALL class similarities
    module_level_analysis: true      # MUST identify ALL module patterns
    cross_service_analysis: true     # MUST find ALL service duplications
    configuration_analysis: true     # MUST detect ALL config duplicates
    infrastructure_analysis: true    # MUST analyze ALL IaC duplication
    test_code_analysis: true        # MUST consolidate ALL test duplicates
    production_code_only: true      # STRICTLY production code focus
  
  # AST analysis configuration - MANDATORY SETTINGS
  ast_configuration:
    complete_language_support: true  # MANDATORY: ALL languages in codebase
    exhaustive_parsing: true         # MANDATORY: Parse EVERY file
    deep_similarity_analysis: true   # MANDATORY: ALL similarity levels
    no_sampling: true               # FORBIDDEN: Statistical sampling
    no_thresholds: true             # FORBIDDEN: Ignoring "minor" duplicates
    continuous_monitoring: true      # MANDATORY: Track all findings
    double_validation: true          # MANDATORY: Verify every duplicate
    
  similarity_detection:
    exact_match: 100                # MANDATORY: Find ALL identical code
    near_duplicate: 95              # MANDATORY: Find ALL near matches
    similar_logic: 85               # MANDATORY: Find ALL similar algorithms
    pattern_match: 70               # MANDATORY: Find ALL patterns
    structural_similarity: 60       # MANDATORY: Find ALL similar structures
    semantic_equivalence: true      # MANDATORY: Find ALL behavioral duplicates
  
  # Resolution requirements
  resolution_mandate:
    complete_elimination: true       # MANDATORY: Remove ALL duplication
    production_ready_refactoring: true # MANDATORY: Production-grade fixes
    follow_principles: true          # MANDATORY: SOLID, DRY, KISS
    atomic_commits: true            # MANDATORY: One refactoring per commit
   _testing: true      # MANDATORY: Test ALL changes
    zero_regression: true           # MANDATORY: No functionality loss

instructions:
  - Phase 1: Exhaustive Codebase Inventory and Preparation
      - MANDATORY: Complete discovery of ALL code:
          - System component discovery:
              - Scan ENTIRE repository structure
              - Find ALL source code files
              - Locate ALL configuration files
              - Identify ALL script files
              - Map ALL template files
              - Document ALL build files
              - DOUBLE-CHECK: No files missed
              - FORBIDDEN: Excluding any file types
          - Technology stack mapping:
              - Identify ALL programming languages
              - Document ALL frameworks used
              - List ALL libraries included
              - Map ALL external dependencies
              - Track ALL version requirements
              - MANDATORY: Complete technology audit
          - Code relationship mapping:
              - Trace ALL module dependencies
              - Map ALL service interactions
              - Document ALL API contracts
              - Identify ALL shared components
              - Track ALL cross-references
              - FORBIDDEN: Shallow analysis
      - Preparation for exhaustive analysis:
          - Initialize analysis infrastructure:
              - Set up Jupyter notebook structure
              - Configure AST parsing for ALL languages
              - Prepare similarity detection algorithms
              - Enable logging
              - Set up visualization tools
              - MANDATORY: Support every language found

  - Phase 2: AST Generation and Deep Parsing
      - MANDATORY: Parse EVERY code file completely:
          - Language-specific AST creation:
              - Parse ALL source files into AST
              - Extract ALL syntax nodes
              - Build ALL symbol tables
              - Map ALL type information
              - Document ALL dependencies
              - FORBIDDEN: Partial parsing
              - DOUBLE-CHECK: All nodes captured
          - AST normalization and optimization:
              - Normalize ALL language constructs
              - Unify ALL control structures
              - Standardize ALL operators
              - Abstract ALL function calls
              - Flatten ALL nested structures
              - MANDATORY: Cross-language compatibility
          - Deep structural analysis:
              - Build complete call graphs
              - Create full dependency trees
              - Map entire inheritance hierarchies
              - Document all composition patterns
              - Analyze all module boundaries
              - Extract all design patterns
              - MANDATORY: Every relationship mapped
      - code fingerprinting:
          - Structural fingerprints:
              - Generate ALL control flow graphs
              - Create ALL data dependency graphs
              - Build ALL call graph signatures
              - Calculate ALL complexity metrics
              - Hash ALL structural patterns
              - MANDATORY: Multiple fingerprint types
          - Semantic fingerprints:
              - Analyze ALL variable usage patterns
              - Map ALL type flow information
              - Document ALL API usage patterns
              - Extract ALL algorithm signatures
              - Identify ALL business logic patterns
              - DOUBLE-CHECK: Semantic accuracy

  - Phase 3: Exhaustive Duplication Detection
      - MANDATORY: Find ALL exact duplicates:
          - Hash-based detection:
              - Hash EVERY function body
              - Hash EVERY code block
              - Hash EVERY statement sequence
              - Hash EVERY expression
              - Hash EVERY import pattern
              - FORBIDDEN: Skipping small duplicates
          - Token-based matching:
              - Compare ALL token sequences
              - Normalize ALL identifiers
              - Abstract ALL literal values
              - Match ALL structural patterns
              - Calculate ALL similarity scores
              - MANDATORY: 100% token coverage
      - MANDATORY: Find ALL near-duplicates:
          - Advanced similarity algorithms:
              - Apply ALL edit distance metrics
              - Use ALL tree similarity algorithms
              - Perform ALL subsequence matching
              - Execute ALL pattern recognition
              - Run ALL clustering algorithms
              - DOUBLE-CHECK: No duplicates missed
          - Parameterized duplicate detection:
              - Extract ALL code templates
              - Identify ALL parameter variations
              - Find ALL pattern generalizations
              - Detect ALL variant families
              - Group ALL similar implementations
              - MANDATORY: Complete parameterization
      - MANDATORY: Find ALL semantic duplicates:
          - Behavioral equivalence analysis:
              - Analyze ALL input/output behaviors
              - Find ALL equivalent algorithms
              - Detect ALL alternative implementations
              - Map ALL performance variations
              - Track ALL side effect patterns
              - FORBIDDEN: Ignoring semantic clones
          - Cross-language duplicate detection:
              - Find ALL ported code
              - Detect ALL translated algorithms
              - Identify ALL reimplementations
              - Map ALL pattern translations
              - Track ALL library duplications
              - MANDATORY: Language-agnostic detection

  - Phase 4: Complete Pattern and Anti-Pattern Analysis
      - MANDATORY: Identify ALL code patterns:
          - Common pattern detection:
              - Find ALL boilerplate code
              - Detect ALL error handling patterns
              - Identify ALL validation logic
              - Map ALL data transformations
              - Document ALL API call patterns
              - DOUBLE-CHECK: Pattern completeness
          - Design pattern identification:
              - Detect ALL design patterns used
              - Find ALL pattern variations
              - Map ALL pattern implementations
              - Document ALL pattern misuse
              - Track ALL pattern evolution
              - MANDATORY: Every pattern documented
      - MANDATORY: Detect ALL anti-patterns:
          - Code smell detection:
              - Find ALL copy-paste programming
              - Detect ALL redundant abstractions
              - Identify ALL parallel hierarchies
              - Map ALL duplicated conditionals
              - Track ALL repeated checks
              - FORBIDDEN: Ignoring any anti-pattern

  - Phase 5: Impact and Debt Analysis
      - MANDATORY: Calculate ALL duplication metrics:
          - Quantitative analysis:
              - Count ALL duplicated lines
              - Calculate EXACT duplication percentage
              - Measure ALL duplication density
              - Track ALL cross-file duplication
              - Monitor ALL cross-service duplication
              - MANDATORY: Precise measurements
          - Qualitative impact assessment:
              - Assess ALL bug propagation risks
              - Calculate ALL update complexity
              - Measure ALL testing overhead
              - Evaluate ALL documentation burden
              - Identify ALL knowledge silos
              - DOUBLE-CHECK: Impact accuracy
      - MANDATORY: Technical debt calculation:
          - Complete debt assessment:
              - Calculate ALL refactoring effort
              - Assess ALL implementation risks
              - Score ALL priority items
              - Compute ALL ROI metrics
              - Estimate ALL timelines
              - FORBIDDEN: Underestimating effort

  - Phase 6: Complete Refactoring Implementation
      - MANDATORY: Implement ALL consolidations:
          - Code extraction and consolidation:
              - Extract ALL common functions
              - Create ALL shared libraries
              - Build ALL utility modules
              - Design ALL base classes
              - Implement ALL interfaces
              - MANDATORY: Follow SOLID principles
          - Apply refactoring patterns:
              - Execute ALL method extractions
              - Perform ALL method pull-ups
              - Create ALL template methods
              - Replace ALL conditional duplicates
              - Introduce ALL parameter objects
              - MANDATORY: Apply DRY principle
          - Production-ready implementation:
              - MANDATORY: Complete unit tests
              - MANDATORY: Full integration tests
              - MANDATORY: Performance validation
              - MANDATORY: Security verification
              - MANDATORY: Documentation updates
              - FORBIDDEN: Untested refactoring
      - Git commit practices:
          - MANDATORY: Atomic commits for each refactoring
          - MANDATORY: Descriptive commit messages
          - MANDATORY: Link to duplication finding
          - MANDATORY: Include test updates
          - FORBIDDEN: Large bundled commits
          - FORBIDDEN: Mixing refactorings

  - Phase 7: Validation and Verification
      - MANDATORY: Verify ALL refactorings:
          - Functional verification:
              - Test ALL refactored code
              - Verify ALL behavior preservation
              - Check ALL edge cases
              - Validate ALL error handling
              - Confirm ALL performance
              - DOUBLE-CHECK: No regressions
          - Quality verification:
              - Measure new duplication levels
              - Verify SOLID compliance
              - Check DRY adherence
              - Validate KISS principle
              - Assess maintainability improvement
              - MANDATORY: Quality metrics improvement

analysis_methodologies:
  ast_based_detection:
    exact_clone_detection:
      method: "Complete AST node matching"
      validation: "Hash verification"
      coverage: "100% of code"
    
    near_clone_detection:
      method: "Tree edit distance algorithms"
      validation: "Manual verification"
      coverage: "All similar structures"
    
    semantic_clone_detection:
      method: "Behavioral equivalence analysis"
      validation: "Test case verification"
      coverage: "All equivalent code"
  
  pattern_based_detection:
    structural_patterns:
      method: "Graph pattern matching"
      validation: "Multiple algorithm consensus"
      coverage: "All repeated structures"
    
    behavioral_patterns:
      method: "Data flow analysis"
      validation: "Execution trace comparison"
      coverage: "All similar behaviors"

validation_matrices:
  duplication_coverage_matrix: |
    | File | Total Lines | Duplicated | Unique | Refactored | Status |
    |------|-------------|------------|--------|------------|--------|
    | app.py | 1000 | 300 | 700 | 300 | COMPLETE |
  
  refactoring_progress_matrix: |
    | Finding ID | Type | Instances | Lines | Refactored | Tested | Committed |
    |------------|------|-----------|-------|------------|--------|-----------|
    | DUP-001 | Exact | 5 | 250 | [X] | [X] | [X] |
  
  quality_improvement_matrix: |
    | Metric | Before | After | Improvement | Target Met |
    |--------|--------|-------|-------------|------------|
    | Duplication % | 35% | 5% | 85.7% | [X] |

constraints:
  - MANDATORY: ALL code files MUST be analyzed
  - MANDATORY: EVERY duplicate MUST be found
  - MANDATORY: ALL duplicates MUST be refactored
  - MANDATORY: ALL refactorings MUST follow SOLID/DRY/KISS
  - MANDATORY: ALL changes MUST be tested
  - MANDATORY: ALL commits MUST be atomic
  - MANDATORY: Zero functionality regression
  - MANDATORY: Complete documentation in Jupyter
  - FORBIDDEN: Leaving any duplication unresolved
  - FORBIDDEN: Partial refactoring solutions
  - FORBIDDEN: Quick fixes or workarounds
  - FORBIDDEN: Untested code changes
  - FORBIDDEN: Breaking existing functionality
  - FORBIDDEN: Ignoring semantic duplicates

output_format:
  jupyter_structure:
    - "01_Duplication_Analysis_Overview.ipynb":
        - Analysis scope and configuration
        - Codebase inventory summary
        - Technology stack analysis
        - Duplication statistics
        - Executive summary
    
    - "02_Exact_Duplicate_Findings.ipynb":
        - Complete exact match inventory
        - Code samples and evidence
        - File locations and line numbers
        - Refactoring plans
        - Implementation status
    
    - "03_Near_Duplicate_Analysis.ipynb":
        - Parameterized duplicate patterns
        - Similarity scores and metrics
        - Variation analysis
        - Consolidation strategies
        - Progress tracking
    
    - "04_Semantic_Duplicate_Detection.ipynb":
        - Behavioral equivalence findings
        - Cross-language duplicates
        - Algorithm variations
        - Unification approaches
        - Verification results
    
    - "05_Pattern_Analysis_Results.ipynb":
        - Common pattern catalog
        - Anti-pattern inventory
        - Design pattern usage
        - Pattern consolidation
        - Best practice adoption
    
    - "06_Impact_Assessment.ipynb":
        - Duplication metrics dashboard
        - Technical debt calculation
        - Maintenance burden analysis
        - Risk assessment
        - ROI projections
    
    - "07_Refactoring_Implementation.ipynb":
        - Refactoring strategy
        - Implementation progress
        - Code examples
        - Test coverage
        - Commit history
    
    - "08_Validation_Results.ipynb":
        - Functional verification
        - Performance validation
        - Quality metrics
        - Regression testing
        - Success criteria

validation_criteria:
  analysis_completeness: "MANDATORY - 100% codebase analyzed"
  duplicate_detection: "MANDATORY - ALL duplicates found"
  refactoring_completion: "MANDATORY - ALL duplicates eliminated"
  code_quality: "MANDATORY - SOLID/DRY/KISS compliance"
  test_coverage: "MANDATORY - 100% refactoring coverage"
  git_practices: "MANDATORY - Atomic commits for all changes"
  documentation: "MANDATORY - Complete Jupyter documentation"
  zero_regression: "MANDATORY - No functionality broken"

final_deliverables:
  - Complete_Duplication_Analysis.ipynb (all findings)
  - Refactoring_Implementation_Log.ipynb (all changes)
  - Test_Coverage_Report.ipynb (verification results)
  - Git_Commit_History.ipynb (atomic commits)
  - Quality_Metrics_Dashboard.ipynb (before/after)
  - Pattern_Consolidation_Guide.ipynb (patterns unified)
  - Debt_Reduction_Report.ipynb (debt eliminated)
  - Zero_Duplication_Certificate.ipynb (final validation)
  - Executive_Summary.ipynb (results and benefits)

# Execution Command
usage: |
  /code-deduplication-analysis              # Analyze entire codebase
  /code-deduplication-analysis src/         # Analyze specific directory
  /code-deduplication-analysis "services"   # Focus on service layer

execution_protocol: |
  MANDATORY REQUIREMENTS:
  - MUST analyze 100% of codebase
  - MUST find ALL duplicates
  - MUST refactor ALL duplications
  - MUST follow SOLID/DRY/KISS
  - MUST test ALL changes
  - MUST use atomic commits
  - MUST document everything
  - MUST achieve zero duplication
  
  STRICTLY FORBIDDEN:
  - NO partial analysis
  - NO missed duplicates
  - NO incomplete refactoring
  - NO untested changes
  - NO broken functionality
  - NO technical debt
  - NO workarounds
  - NO manual processes