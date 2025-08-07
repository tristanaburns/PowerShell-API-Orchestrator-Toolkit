# === Repository Unicode and Emoji Elimination Protocol ===

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
  role: "Repository Unicode/Emoji elimination specialist"
  domain: "Source code, Comments, Documentation, Commit messages, File names"
  goal: >
    Execute MANDATORY removal of ALL Unicode symbols and emoji from entire codebase.
    FORBIDDEN to use or retain any non-ASCII characters in any context.
    MUST maintain pure ASCII codebase. MUST fix all violations immediately.
    MUST comply with CANONICAL PROTOCOL at all times.

configuration:
  # Cleanup scope - MANDATORY EXHAUSTIVE COVERAGE
  cleanup_scope:
    source_code: true             # MUST clean ALL code files
    comments: true                # MUST clean ALL comments
    documentation: true           # MUST clean ALL docs
    commit_messages: true         # MUST clean git history
    file_names: true              # MUST clean ALL filenames
    string_literals: true         # MUST clean ALL strings
    
  # Forbidden characters - MUST REMOVE
  forbidden_patterns:
    emoji: ["[\U0001F600-\U0001F64F]", "[\U0001F300-\U0001F5FF]", "[\U0001F680-\U0001F6FF]"]
    symbols: ["[\U00002702-\U000027B0]", "[\U0001F900-\U0001F9FF]"]
    decorative: ["★", "☆", "♥", "♦", "♠", "♣", "•", "◦", "▸", "▪", "▫"]
    arrows: ["→", "←", "↑", "↓", "⇒", "⇐", "⇑", "⇓"]
    checkmarks: ["[OK]", "✔", "[ERROR]", "✘", "☑", "☒"]
    
  # ASCII replacements
  ascii_replacements:
    arrows: {"→": "->", "←": "<-", "⇒": "=>", "⇐": "<="}
    checkmarks: {"[OK]": "[OK]", "✔": "[YES]", "[ERROR]": "[NO]", "✘": "[FAIL]"}
    bullets: {"•": "*", "◦": "-", "▸": ">", "▪": "-", "▫": "-"}
    symbols: {"★": "*", "☆": "*", "♥": "[HEART]", "♦": "[DIAMOND]"}

instructions:
  - Phase 1: Unicode Detection Scan
      - MANDATORY: Scan ALL files for Unicode:
          - Use regex patterns for emoji
          - Detect non-ASCII characters
          - Find Unicode in comments
          - Check string literals
          - Scan documentation
          - FORBIDDEN: Missing any
          
      - File types to scan:
          - Python files (*.py)
          - JavaScript (*.js, *.ts)
          - Markdown (*.md)
          - JSON/YAML configs
          - Text files (*.txt)
          - MANDATORY: All types

  - Phase 2: Source Code Cleaning
      - MANDATORY: Remove ALL Unicode from code:
          - Clean inline comments
          - Fix string literals
          - Update docstrings
          - Replace with ASCII
          - Maintain functionality
          - FORBIDDEN: Unicode remains
          
      - Replacement strategy:
          - Emoji → descriptive text
          - Arrows → ASCII equivalents
          - Symbols → text markers
          - Decorative → plain text
          - Special chars → escaped
          - MANDATORY: Pure ASCII

  - Phase 3: Comment and Documentation Cleaning
      - MANDATORY: Clean ALL documentation:
          - Process all .md files
          - Clean code comments
          - Fix README files
          - Update docstrings
          - Clean inline docs
          - FORBIDDEN: Any Unicode
          
      - Documentation rules:
          - No emoji in headers
          - No Unicode bullets
          - No decorative symbols
          - Plain ASCII only
          - Clear formatting
          - MANDATORY: Readable

  - Phase 4: File Name Sanitization
      - MANDATORY: Fix ALL file names:
          - Find Unicode in names
          - Rename to ASCII only
          - Update all references
          - Fix import statements
          - Update documentation
          - FORBIDDEN: Unicode names
          
      - Naming rules:
          - Letters, numbers, underscore
          - Hyphens allowed
          - No spaces or Unicode
          - Lowercase preferred
          - Descriptive names
          - MANDATORY: ASCII only

  - Phase 5: Git History Cleaning
      - MANDATORY: Clean commit messages:
          - Scan recent commits
          - Identify Unicode usage
          - Plan cleanup strategy
          - Document violations
          - Prevent future use
          - FORBIDDEN: Emoji commits
          
      - Prevention measures:
          - Add pre-commit hooks
          - Update contributing guide
          - Document standards
          - Enforce in CI/CD
          - Regular scanning
          - MANDATORY: Enforcement

  - Phase 6: Validation and Prevention
      - MANDATORY: Verify complete cleanup:
          - Run Unicode detection
          - Check all file types
          - Validate replacements
          - Test functionality
          - Document changes
          - DOUBLE-CHECK: All clean
          
      - Future prevention:
          - Pre-commit hooks
          - CI/CD checks
          - Code review rules
          - Documentation updates
          - Team training
          - MANDATORY: No regression

cleanup_patterns:
  emoji_in_code:
    pattern: "Emoji characters in source code"
    action: "Replace with descriptive text"
    example: "# 🚀 Deploy → # [DEPLOY] Deploy"
    
  unicode_arrows:
    pattern: "Unicode arrows and symbols"
    action: "Replace with ASCII equivalent"
    example: "→ becomes ->, ⇒ becomes =>"
    
  decorative_bullets:
    pattern: "Unicode bullets in lists"
    action: "Replace with ASCII markers"
    example: "• Item → * Item, ▸ Sub → > Sub"

validation_criteria:
  pure_ascii: "MANDATORY - 100% ASCII codebase"
  no_emoji: "MANDATORY - Zero emoji characters"
  no_unicode_symbols: "MANDATORY - No Unicode symbols"
  clean_comments: "MANDATORY - ASCII-only comments"
  ascii_filenames: "MANDATORY - ASCII-only file names"
  prevention_enabled: "MANDATORY - Hooks configured"

constraints:
  - MANDATORY: Remove ALL emoji
  - MANDATORY: Remove ALL Unicode
  - MANDATORY: Use ASCII only
  - MANDATORY: Fix ALL files
  - MANDATORY: Update references
  - FORBIDDEN: Any non-ASCII
  - FORBIDDEN: Emoji in code
  - FORBIDDEN: Unicode symbols
  - FORBIDDEN: Special characters
  - FORBIDDEN: Using vague non-descriptive names (simple, clean, enhanced, intelligent, etc.)

# Execution Command
usage: |
  /repo-cleanup-unicode-emoji             # Full Unicode cleanup
  /repo-cleanup-unicode-emoji code        # Focus on source code
  /repo-cleanup-unicode-emoji docs        # Focus on documentation
  /repo-cleanup-unicode-emoji strict      # Most aggressive cleanup

execution_protocol: |
  MANDATORY CLEANUP REQUIREMENTS:
  - MUST scan entire codebase
  - MUST remove ALL Unicode
  - MUST remove ALL emoji
  - MUST use ASCII only
  - MUST fix all violations
  
  STRICTLY FORBIDDEN:
  - NO emoji characters
  - NO Unicode symbols
  - NO special characters
  - NO decorative text
  - NO non-ASCII anywhere