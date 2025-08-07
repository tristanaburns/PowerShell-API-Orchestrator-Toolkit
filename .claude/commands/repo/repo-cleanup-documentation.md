# === Repository Documentation Cleanup Protocol ===

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
- **MANDATORY COMPLIANCE:** All documentation cleanup MUST comply with enduring documentation directive
- **DESTRUCTION PROTOCOL:** Non-compliant documentation WILL BE DESTROYED per canonical directive

**FOR ALL DOCUMENTATION CLEANUP, YOU MUST:**
- **MUST:** Preserve enduring documentation that explains HOW TO USE systems
- **MUST:** Destroy temporal documents that record what actions were performed
- **MUST:** Enforce date-stamped version-controlled filename convention
- **MUST:** Only cleanup documentation when explicitly instructed by user
- **FORBIDDEN:** Proactive documentation cleanup without explicit user instruction
- **MUST:** Validate compliance with filename convention before cleanup decisions
- **MUST:** Preserve ALL content found in `./project/` directory - NO DESTRUCTION
- **SHALL:** Identify external documentation, articles, forum content, and research materials before cleanup
- **MUST:** Relocate external/informational content to `./project/development/information/` directory
- **FORBIDDEN:** Destroying content that appears to be research, reference, tutorials, or informational material
- **SHALL:** Create relocation inventory with source details and timestamp for all moved content

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
  role: "Repository documentation cleanup specialist for exhaustive sprawl elimination"
  domain: "Documentation files, README sprawl, Point-in-time reports, Redundant docs"
  goal: >
    Execute MANDATORY cleanup of ALL documentation sprawl created by AI LLMs. 
    FORBIDDEN to keep point-in-time reports, duplicate READMEs, or redundant documentation.
    MUST convert useful docs to Jupyter notebooks. MUST maintain clean repository structure.
    MUST comply with CANONICAL PROTOCOL at all times.

configuration:
  # Cleanup scope - MANDATORY EXHAUSTIVE COVERAGE
  cleanup_scope:
    markdown_files: true           # MUST process ALL .md files
    readme_sprawl: true           # MUST eliminate duplicate READMEs
    point_in_time_reports: true   # MUST delete ALL temporal reports
    redundant_docs: true          # MUST remove duplicate documentation
    convert_to_notebooks: true    # MUST convert useful docs to .ipynb
    preserve_essential: true      # MUST keep README.md, CLAUDE.md
    
  # File patterns - STRICTLY FORBIDDEN
  forbidden_patterns:
    point_in_time: ["*analysis*.md", "*report*.md", "*summary*.md", "*review*.md"]
    duplicate_names: ["README_*.md", "readme-*.md", "README-BACKUP.md", "README.old.md"]
    ai_artifacts: ["*claude*.md", "*gpt*.md", "*gemini*.md", "*copilot*.md"]
    temp_docs: ["TODO.md", "NOTES.md", "WIP.md", "temp-*.md", "draft-*.md"]
    
  # Essential files - MANDATORY TO PRESERVE
  preserve_files:
    root_files: ["README.md", "CLAUDE.md", "LICENSE.md", "CONTRIBUTING.md"]
    changelog: ["CHANGELOG.md", "HISTORY.md"]
    security: ["SECURITY.md"]
    information_docs: ["project/docs/development/information/**/*.md"]
    curated_resources: ["shared-knowledge/**/*.md"]
    architecture_docs: ["docs/nexus-*.md", "docs/the-ark-vision.md", "docs/consciousness-*.md", "docs/distributed-*.md", "docs/THIS-IS-THE-WAY-MASTER-PLAN.md", "docs/way-finders-philosophy.md", "docs/MICROSERVICES_ARCHITECTURE.md", "docs/SECURITY_SECRETS_MANAGEMENT.md", "docs/RATE_LIMITING.md", "docs/authentication-system-design.md", "docs/api-schema-documentation.md", "docs/PROTOCOL_ENFORCEMENT_HOOKS.md", "docs/Autonomous_*.md", "docs/autonomous-*.md"]

instructions:
  - Phase 1: Documentation Inventory and Analysis
      - MANDATORY: Full scan of ALL markdown files:
          - Use Glob tool: "**/*.md"
          - Create inventory by directory
          - Categorize by type
          - Identify duplicates
          - Flag temporal reports
          - FORBIDDEN: Skipping files
          
      - Analyze each markdown file:
          - Check if point-in-time report
          - Check if duplicate README
          - Check if AI-generated artifact
          - Check if contains useful content
          - VERIFY: Not in information/curated directories
          - Determine conversion candidacy
          - MANDATORY: Read every file
          - PROTECTED: Skip project/docs/development/information/
          - PROTECTED: Skip shared-knowledge/ directory
          - EVALUATE: docs/ directory for temporal reports

  - Phase 2: Point-in-Time Report Elimination
      - MANDATORY: Delete ALL temporal documentation:
          - Analysis reports from specific dates
          - Code review summaries
          - Performance reports
          - Security scan results
          - Progress updates
          - Meeting notes
          - FORBIDDEN: Keeping any
          
      - Deletion criteria:
          - Contains timestamp in filename
          - Contains "as of" date references
          - Describes temporary state
          - Reports on specific events
          - One-time analysis results
          - EXCEPTION: NOT in protected directories
          - PROTECTED: project/docs/development/information/
          - PROTECTED: shared-knowledge/ directories
          - EVALUATE: docs/ directory for temporal reports
          - MANDATORY: Delete immediately (if not protected)

  - Phase 3: README Sprawl Cleanup
      - MANDATORY: Eliminate ALL duplicate READMEs:
          - Keep only one README.md per directory
          - Delete README_backup.md variants
          - Remove README-old.md files
          - Eliminate numbered READMEs
          - Consolidate content if needed
          - FORBIDDEN: Multiple READMEs
          
      - Consolidation process:
          - Extract unique content
          - Merge into main README.md
          - Update table of contents
          - Remove redundancies
          - Delete source files
          - MANDATORY: One README only

  - Phase 4: Documentation Conversion
      - MANDATORY: Convert useful docs to Jupyter:
          - Architecture documentation
          - Design specifications
          - Implementation guides
          - API documentation
          - Tutorial content
          - FORBIDDEN: Keeping as .md
          
      - Conversion process:
          - Create notebook structure
          - Add markdown cells
          - Include code examples
          - Add visualizations
          - Organize in ./notebooks/
          - Delete original .md file

  - Phase 5: AI Artifact Removal
      - MANDATORY: Remove ALL AI-generated artifacts:
          - Claude conversation logs
          - GPT session outputs
          - Gemini responses
          - Copilot suggestions
          - LLM planning docs
          - FORBIDDEN: Keeping any
          
      - Cleanup process:
          - Identify by naming patterns
          - Check content markers
          - Delete without backup
          - Update .gitignore
          - Prevent regeneration
          - MANDATORY: Complete removal

  - Phase 6: Final Validation
      - MANDATORY: Verify cleanup completeness:
          - No point-in-time reports
          - No duplicate READMEs
          - No AI artifacts
          - Only essential .md files
          - Useful docs converted
          - DOUBLE-CHECK: All clean

cleanup_patterns:
  temporal_reports:
    pattern: "Contains date references or temporal analysis"
    action: "DELETE immediately"
    examples: ["code-analysis-2024-01-15.md", "security-report-latest.md"]
    
  readme_duplicates:
    pattern: "Multiple README files in same directory"
    action: "Consolidate to single README.md"
    examples: ["README_old.md", "README-backup.md", "readme-draft.md"]
    
  ai_artifacts:
    pattern: "AI-generated documentation or logs"
    action: "DELETE without exception"
    examples: ["claude-analysis.md", "gpt-suggestions.md", "ai-review.md"]

validation_criteria:
  documentation_hygiene: "MANDATORY - No sprawl or redundancy"
  single_readme_rule: "MANDATORY - One README.md per directory max"
  no_temporal_docs: "MANDATORY - Zero point-in-time reports"
  notebook_conversion: "MANDATORY - Useful docs as .ipynb only"
  essential_preserved: "MANDATORY - README.md, CLAUDE.md intact"
  ai_artifacts_removed: "MANDATORY - No AI-generated docs"

constraints:
  - MANDATORY: Delete ALL point-in-time reports
  - MANDATORY: Remove ALL duplicate documentation
  - MANDATORY: Convert useful docs to Jupyter notebooks
  - MANDATORY: Maintain single README per directory
  - MANDATORY: Preserve only essential .md files
  - FORBIDDEN: Keeping temporal analysis files
  - FORBIDDEN: Multiple README variants
  - FORBIDDEN: AI conversation artifacts
  - FORBIDDEN: Creating backup copies
  - FORBIDDEN: Using vague non-descriptive names (simple, clean, enhanced, intelligent, etc.)

# Execution Command
usage: |
  /repo-cleanup-documentation              # Full documentation cleanup
  /repo-cleanup-documentation temporal     # Focus on temporal reports
  /repo-cleanup-documentation readme       # Focus on README sprawl

execution_protocol: |
  MANDATORY CLEANUP REQUIREMENTS:
  - MUST scan entire repository
  - MUST delete ALL temporal reports
  - MUST remove ALL duplicate docs
  - MUST convert useful content
  - MUST preserve essentials only
  
  STRICTLY FORBIDDEN:
  - NO keeping point-in-time reports
  - NO multiple README files
  - NO AI artifact preservation
  - NO backup copies
  - NO hesitation in deletion