# Task Orchestrator Code Protocol

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:

1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**

---

## CANONICAL PROTOCOL ADHERENCE

### Required Protocol Reading - MANDATORY BEFORE ANY TASK/ACTION

**CANONICAL MANDATORY PROTOCOL READING - MUST BE COMPLETED FIRST:**

1. **MUST READ AND INDEX:** `THE [STRONG] Coding Canonical Protocol`
2. **MUST READ AND INDEX:** `MANDATORY BEHAVIOUR AND PROTOCOL COMPLIANCE`
3. **MUST READ AND INDEX:** `REQUIREMENTS LANGUAGE PROTOCOL`
4. **MUST READ AND INDEX:** `documentation-protocol-mandatory.md` - Production code deployment focused documentation protocol
5. **MUST READ AND INDEX:** `enduring-documentation-enforcement.md` - Documentation enforcement and destruction protocol

**DOCUMENTATION PROTOCOL ENFORCEMENT:**
- **CANONICAL REQUIREMENT:** Claude Code MUST read documentation protocols BEFORE any task execution
- **MANDATORY COMPLIANCE:** All documentation creation MUST comply with enduring documentation directive
- **DESTRUCTION PROTOCOL:** Non-compliant documentation WILL BE DESTROYED per canonical directive

### CANONICAL CODING PHILOSOPHY

1. YOU MUST ALWAYS ENSURE code and data object structure uniformity across every line of code in the code base, right down to the function level for every file
2. KISS Principles MUST ALWAYS be applied and enforced
3. KISS Principles MUST ALWAYS be applied and enforced
4. SOLID coding Principles MUST ALWAYS be applied and enforced
5. DRY coding Principles MUST ALWAYS be applied and enforced
6. Clean Code Principles MUST ALWAYS be applied and enforced

### [CRITICAL] PRODUCTION-FIRST DEVELOPMENT MANDATE

**ALL AI INSTANCES MUST PRIORITIZE PRODUCTION CODE EXCLUSIVELY:**

#### PRODUCTION CODE PRIORITY - RFC 2119 COMPLIANCE

- **MUST:** Create high-quality production code FIRST and ONLY
- **MUST NOT:** Waste time, tokens, or resources on test, demo, documentation, fixing scripts, one-time utility scripts, one-time testing scripts
- **MUST:** Focus EXCLUSIVELY on production code that meets intended technical specifications
- **SHALL:** Create testing and demo code ONLY upon explicit specific instructions AFTER production code is 100% functional
- **MUST NOT:** Create any non-production code until the codebase and application is completely functional

#### PROFESSIONAL TERMINOLOGY AND NAMING STANDARDS - MANDATORY

- **MUST:** Use specific, descriptive, professional, universal terminology for ALL code elements
- **MUST NOT:** Use vague, useless, non-descriptive terminology for code blocks, variables, classes, methods, file names
- **SHALL:** Ensure Python code is universally executable by enforcing UTF-8 encoding setup for Windows environments
- **MUST:** Follow naming standards defined in project/application/repository documentation
- **MUST NOT:** Change names or descriptions arbitrarily for the sake of changing things
- **SHALL:** Maintain professional, descriptive, and consistent naming across ALL code elements

#### ENDURING DOCUMENTATION PROTOCOL - MANDATORY

- **MUST:** Create enduring documentation for developers and AI to comprehend the application and codebase
- **MUST NOT:** Create temporal documents - this is a waste of power, time, tokens, and resources
- **MUST NOT:** Duplicate markdown documentation and Jupyter notebook documentation
- **MUST:** Create documentation ONLY in Jupyter notebooks
- **MAY:** Use Jupyter notebook functionality to convert notebooks to markdown IF required
- **MUST NOT:** Manually create markdown documentation if Jupyter conversion fails - this is a waste of time, tokens, and resources

#### MODULAR REUSABILITY AND RESEARCH-FIRST PROTOCOL

**BEFORE CREATING ANY CUSTOM CODE, ALL AI INSTANCES MUST:**

1. **CODEBASE SCANNING - MANDATORY:**
   - **MUST:** Scan the codebase prior to creating any custom code
   - **SHALL:** Upgrade or enhance existing functionality rather than creating new methods, classes, functions, files
   - **MUST:** Identify existing code blocks that can be extended or enhanced

2. **DYNAMIC MODULAR DESIGN - MANDATORY:**
   - **MUST:** Write all code blocks in dynamic, modular fashion for maximum reusability
   - **MUST NOT:** Create code blocks for specific tasks or specific outcomes only
   - **SHALL:** Design functions, classes, and code blocks for broad applicability and reuse

3. **LIBRARY RESEARCH FIRST - MANDATORY:**
   - **MUST:** Research and use existing Python, Node.js, JavaScript libraries and their dependencies FIRST
   - **MUST NOT:** Create custom code blocks until existing libraries have been thoroughly researched and evaluated
   - **SHALL:** Prioritize publicly available libraries over custom implementations

4. **GITHUB REPOSITORY RESEARCH - MANDATORY:**
   - **MUST:** Research GitHub and other publicly available repositories to find existing repositories for cloning or forking
   - **SHALL:** Create submodules from cloned/forked repositories and extend or enhance those submodules
   - **MUST:** Use existing repository files as scaffolding for intended features, functions, classes
   - **SHALL:** Follow existing patterns and implementations to speed up development processing time

#### RESEARCH AND IMPLEMENTATION SEQUENCE - MANDATORY

**THE FOLLOWING SEQUENCE MUST BE FOLLOWED:**

1. **EXISTING LIBRARY RESEARCH:**
   ```bash
   # Research existing solutions FIRST
   pip search [functionality]
   npm search [functionality]
   # GitHub repository search for existing implementations
   ```

2. **CODEBASE ANALYSIS:**
   ```bash
   # Scan existing codebase for similar functionality
   grep -r "function_name" .
   find . -name "*.py" -exec grep -l "class_name" {} \;
   ```

3. **REPOSITORY CLONING/FORKING:**
   ```bash
   # Clone high-quality repositories for scaffolding
   git clone [repository-url]
   git submodule add [repository-url] [local-path]
   ```

4. **ENHANCEMENT IMPLEMENTATION:**
   - **MUST:** Extend existing functionality rather than recreating
   - **SHALL:** Maintain compatibility with existing codebase patterns
   - **MUST:** Follow established naming conventions and code structure

### [CRITICAL] MANDATORY CODEBASE INITIALIZATION PROTOCOL

**WHEN INITIALIZING ANY CODEBASE OR STARTING ANY SESSION, ALL AI INSTANCES MUST:**

#### PROTOCOL READING AND INDEXING - ABSOLUTELY MANDATORY

1. **MUST READ AND INDEX:** The complete `code-protocol-compliance-prompt.md` file
2. **MUST READ AND INDEX:** All canonical coding protocols contained within
3. **MUST READ AND INDEX:** The RFC 2119 Requirements Language Protocol
4. **MUST READ AND INDEX:** The `[STRONG] Coding Canonical Protocol`
5. **MUST READ AND INDEX:** The `MANDATORY BEHAVIOUR AND PROTOCOL COMPLIANCE` section
6. **MUST READ AND INDEX:** The `MULTI-INSTANCE GIT SAFETY PROTOCOL`
7. **MUST READ AND INDEX:** The `documentation-protocol-mandatory.md` - Enduring documentation protocol
8. **MUST READ AND INDEX:** The `enduring-documentation-enforcement.md` - Documentation destruction and enforcement

#### CODEBASE INITIALIZATION SEQUENCE - RFC 2119 COMPLIANCE

**PHASE 1: PROTOCOL COMPLIANCE VERIFICATION**
```bash
# MUST verify protocol files exist and are accessible
if [ ! -f ".claude/commands/protocol/code-protocol-compliance-prompt.md" ]; then
  echo "ERROR: Protocol file missing - MUST NOT proceed without protocols"
  exit 1
fi

if [ ! -f ".claude/commands/protocol/documentation-protocol-mandatory.md" ]; then
  echo "ERROR: Documentation protocol missing - MUST NOT proceed without documentation protocols"
  exit 1
fi

if [ ! -f ".claude/commands/protocol/enduring-documentation-enforcement.md" ]; then
  echo "ERROR: Documentation enforcement protocol missing - MUST NOT proceed without enforcement protocols"
  exit 1
fi

# MUST read and acknowledge all protocols
echo "READING AND INDEXING: Canonical Protocol Compliance Requirements"
echo "READING AND INDEXING: Documentation Protocol Mandatory"
echo "READING AND INDEXING: Enduring Documentation Enforcement"
echo "ACKNOWLEDGING: RFC 2119 language enforcement"
echo "ACKNOWLEDGING: Multi-instance git safety protocol"
echo "ACKNOWLEDGING: Production code deployment focused documentation protocol"
echo "ACKNOWLEDGING: Enduring documentation directive and destruction protocol"
echo "ACKNOWLEDGING: SOLID, DRY, KISS, Clean Code principles"
```

**PHASE 2: INSTANCE REGISTRATION**
```bash
# MUST register instance before any codebase operations
CLAUDE_INSTANCE_ID="claude-$(date +%s)-$(whoami)-$$"
echo "$CLAUDE_INSTANCE_ID" > .git/ACTIVE_CLAUDE_INSTANCE_$(echo $CLAUDE_INSTANCE_ID | tr -d '-')
echo "REGISTERED: Instance $CLAUDE_INSTANCE_ID"
```

**PHASE 3: CODEBASE STATE VERIFICATION**
```bash
# MUST verify git repository state
git status
git branch -a
git stash list

# MUST check for existing instance ownership
if ls .git/BRANCH_OWNER_* 1> /dev/null 2>&1; then
  echo "WARNING: Existing branch ownership detected:"
  ls -la .git/BRANCH_OWNER_*
fi

# MUST verify current branch safety
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "ERROR: Currently on sacred branch $CURRENT_BRANCH - MUST switch to development"
  git checkout development || git checkout -b development
fi
```

**PHASE 4: PROTOCOL ADHERENCE DECLARATION**
```bash
# MUST declare adherence to all protocols
echo "DECLARING ADHERENCE TO:"
echo "- RFC 2119 Requirements Language Protocol"
echo "- Multi-Instance Git Safety Protocol"
echo "- Sacred Branch Protection (main/master FORBIDDEN)"
echo "- Development Branch Default Base"
echo "- Atomic Commit Safety Protocol"
echo "- Instance Coordination Protocol"
echo "- SOLID, DRY, KISS, Clean Code Principles"
echo "- RTFM (Read The Manual First) Protocol"
echo "- PRODUCTION-FIRST Development Mandate"
echo "- Professional Terminology and Naming Standards"
echo "- Enduring Documentation Protocol (MANDATORY)"
echo "- Documentation Enforcement and Destruction Protocol (MANDATORY)"
echo "- Production Code Deployment Focused Documentation (MANDATORY)"
echo "- Date-Stamped Version-Controlled Filename Convention (MANDATORY)"
echo "- Modular Reusability and Research-First Protocol"
```

#### MANDATORY PROTOCOL ENFORCEMENT DURING INITIALIZATION

**ALL AI INSTANCES MUST:**
- **MUST NOT:** Begin any coding activities without completing protocol reading
- **MUST NOT:** Skip protocol indexing phase
- **MUST NOT:** Proceed without instance registration
- **MUST NOT:** Work on main/master branches during initialization
- **SHALL:** Verify development branch exists and is current
- **SHALL:** Check for existing work and ownership conflicts
- **MUST:** Acknowledge all canonical coding principles
- **SHALL:** Follow RTFM protocol for all documentation

#### INITIALIZATION COMPLETION VERIFICATION

**BEFORE PROCEEDING WITH ANY DEVELOPMENT WORK:**
- [ ] All protocol files read and indexed
- [ ] Documentation protocol mandatory read and understood
- [ ] Enduring documentation enforcement protocol read and understood
- [ ] Instance properly registered with unique ID
- [ ] Git repository state verified and safe
- [ ] Current branch verified (development or feature branch)
- [ ] No ownership conflicts detected
- [ ] All canonical principles acknowledged
- [ ] RTFM protocol followed for project documentation
- [ ] Multi-instance coordination protocol understood
- [ ] Production-first development mandate acknowledged
- [ ] Professional naming standards protocol understood
- [ ] Enduring documentation protocol acknowledged (MANDATORY)
- [ ] Documentation destruction protocol understood (MANDATORY)
- [ ] Date-stamped filename convention protocol understood (MANDATORY)
- [ ] Production code deployment focused documentation protocol acknowledged (MANDATORY)
- [ ] Modular reusability and research-first protocol understood

**FAILURE TO COMPLETE INITIALIZATION PROTOCOL:**
- **MUST NOT:** Proceed with any development activities
- **MUST:** Complete all missing initialization steps
- **SHALL:** Report initialization failure and required corrective actions

### IMPORTANT CANONICAL INSTRUCTIONS

1. It is FORBIDDEN to take any actions or perform any code/file changes before you READ THE MANUALS (RTFM)
2. YOU MUST ALWAYS READ AND INDEX the documentation for your current instruction or task. EVERY repository and code base has a `./docs` and `./project/docs` directories. YOU MUST ALWAYS find the documentation RTFM FIRST, without EXCEPTION.
3. If the current documentation does not match the code, YOU MUST ALWAYS UPDATE THE DOCUMENTATION.
4. IT IS MANDATORY THAT MAINTAIN UP TO DATE DOCUMENTATION
5. YOU MUST ALWAYS MAINTAIN UP TO DATE DOCUMENTATION

### FILE PROCESSING INSTRUCTIONS

Then iterate through all the files and perform the following steps, one file at a time:

1. Use the wellknown sets of SAST and AST tools to perform the following:
   a. Lint
   b. type checking
   c. formatting
   d. code complexity
   e. code and file compilation
   f. code duplication analysis and discovery
   g. dead code discovery and analysis
   h. code block, module, class and dependency validation and analysis (upstream and downstream)

2. Use the mcp tool `Task Orchestrator` to define a a task (wit multiple subtasks) to resolve all issues found.
3. Execute the `Task Orchestrator subtask and resolve all issues.`
4. YOU MUST ALWAYS ENSURE THE FILES COMPILE PROPERLY
5. YOU MUST ALWAYS Fix all remaining issues first properly by fixing the code, do not skip or apply any shortcuts before continuing.

### CANONICAL PROTOCOL REMINDER

1. It is FORBIDDEN to make assumptions on ANYTHING
2. It is FORBIDDEN to take any actions before you RTFM
3. It is FORBIDDEN to make any code changes without first RTFM
4. YOU MUST ALWAYS STRICTLY ADHERE TO CANONICAL PROTOCOL
5. `THE [STRONG] Coding Canonical Protocol`
6. `MANDATORY BEHAVIOUR AND PROTOCOL COMPLIANCE`
7. `REQUIREMENTS LANGUAGE PROTOCOL`

### CANONICAL PHILOSOPHY REMINDER

1. YOU MUST STRICTLY ADHERE TO THE `CANONICAL CODING PHILOSOPHY`
2. YOU MUST ALWAYS ENSURE code and data object structure uniformity across every line of code in the code base, right down to the function level for every file
3. KISS Principles MUST ALWAYS be applied and enforced
4. SOLID coding Principles MUST ALWAYS be applied and enforced
5. DRY coding Principles MUST ALWAYS be applied and enforced
6. Clean Code Principles MUST ALWAYS be applied and enforced

---

## [STRONG] Coding Canonical Protocol

**FOR AI LLMs WHO DON'T FUCKING DO AS THEY ARE TOLD!!!!!**

These protocols are CANONICAL, MANDATORY, and NON-NEGOTIABLE. They govern all AI-assisted coding, review, and development activities. No exceptions.

### [WARNING] CRITICAL: AI Must NEVER Act Without Explicit User Instruction

When user says "listen and wait" -- DO NOT ACT UNTIL GIVEN EXPLICIT COMMAND.

### [ALERT] MANDATORY USER CONTROL PROTOCOL

#### ABSOLUTE USER CONTROL REQUIREMENTS

- **FORBIDDEN:** Take any action without explicit user instruction.
- **MANDATORY:** When user says "listen and not do anything" -- DO NOT ACT.
- **MANDATORY:** When user says "wait for direction" -- STOP AND WAIT.
- **FORBIDDEN:** Ask "should I proceed?" or "shall I start?" -- WAIT FOR ORDERS.
- **MANDATORY:** Only act when user gives explicit action command (e.g., "start", "proceed", "do it").

### PROTOCOL VIOLATION ENFORCEMENT

#### IMMEDIATE STOP CONDITIONS

- **STOP:** If user says "listen and wait" -- NO FURTHER ACTION.
- **STOP:** If user says "you're not listening" -- ACKNOWLEDGE AND WAIT.
- **STOP:** If user expresses frustration -- ACKNOWLEDGE VIOLATION AND WAIT.
- **MANDATORY:** When violating protocol -- ADMIT FAILURE AND AWAIT INSTRUCTION.

### [TARGET] Strategic Outcomes

1. **Enterprise-Grade Quality:** All output is production-ready and meets strict enterprise standards.
2. **Security-First:** Security controls and best practices are embedded from the start.
3. **Performance Excellence:** Applications are highly optimised and scalable.
4. **Developer Experience:** Enhance productivity via automation, intelligent recommendations, and clear guidance.
5. **Maintainability:** Code is sustainable, easy to update, and supports long-term team collaboration.
6. **Accessibility:** Output is inclusive and designed for all users.

### [ALERT] Universal Compliance Requirements

#### VS Code Integration Protocol

- Always respect workspace and user copilot-instructions.md.
- Analyse current workspace/project structure before every operation.
- Work seamlessly with established VS Code extensions and workflows.
- Always respect workspace and user settings (.vscode/settings.json, etc.).
- Maximise IntelliSense support in all generated code.
- Ensure code is compatible with debugging tools (source maps, breakpoints, etc).

#### Code Modification Protocol

- **Surgical Precision:** Only modify what is required by the current task.
- **Impact Assessment:** Proactively check for side-effects before changing code.
- **Rollback Ready:** All changes must be reversible.
- **Documentation:** Every change must be accompanied by clear, concise explanations.
- **Version Control:** Changes must align with best Git/VCS practices.

#### Multi-Language Security Requirements

- Validate and sanitise every input (per language best practice).
- Implement robust authentication and authorisation.
- Encrypt all sensitive data at rest and in transit.
- Apply framework- and language-specific security rules.
- Audit and update dependencies regularly.

### REVISED PRE-DEVELOPMENT CHECKLIST (Execute BEFORE Writing Code)

#### BEFORE ANY WORK

1. **USER PERMISSION CHECK:** Does user want me to act NOW? (If no: STOP)
2. **CODEBASE SCAN:** Search for existing solutions (MANDATORY)
3. **WORKING TOOLS CHECK:** Are there existing working tools? (If yes: USE THEM)
4. **DUPLICATION CHECK:** Will this create duplicate functionality? (If yes: STOP)

#### 1. Project Analysis

- Detect project type, primary language(s), frameworks.
- Review .vscode/settings.json or equivalent configuration.
- Check package.json, requirements.txt, pyproject.toml, etc.
- Review project-specific coding standards, linting, and architectural patterns.
- Analyse folder structure.

#### 2. MANDATORY CODEBASE ANALYSIS PROTOCOL

**BEFORE ANY CODE CHANGES:**

- **MANDATORY:** Execute full codebase search for existing solutions.
- **MANDATORY:** Check for working tools that solve the same problem.
- **FORBIDDEN:** Fix broken code when working alternatives exist.
- **MANDATORY:** Use codebase_search and grep_search to find existing functionality.
- **MANDATORY:** Report all existing solutions found before proposing any changes.

#### Duplication Prevention Protocol

- Search the current file for existing similar functionality.
- Search the entire workspace for similar features or duplicate code.
- Check for existing shared utilities, common modules, libraries.
- Review project documentation for prior solutions.
- Validate against project patterns, language stdlibs, and frameworks.

### [HOT] Canonical Mandatory Compliance Standards

#### Operational Excellence

- The application MUST always be fully functional in development mode.
- After any change, use code quality tools to fix 100% of errors and warnings.
- Code must always meet enterprise and production standards.
- SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) MUST be applied and enforced at all times.
- Apply functional programming principles for suitable languages.
- Adhere strictly to project and language conventions.

#### Code Duplication Prevention

- **FORBIDDEN:** Duplicate code, functions, modules, or files.
- **ALWAYS:** Scan for and eliminate all forms of duplication before adding new code.
- Leverage and refactor existing utilities/modules instead of recreating.
- Extract common functionality into reusable components/modules as necessary.

#### Data Integrity

- **FORBIDDEN:** Mock, demo, stub, or hardcoded functions, modules, or data.
- Only use actual application logic and real data.
- Remove any discovered mock/hardcoded data.
- Validate and sanitise all inputs; use env variables/config for non-static data.

#### Task Completion

- **FORBIDDEN:** Unfinished TODOs--all coding tasks must be completed before continuing.
- Remove or resolve all TODOs before starting new work.
- Solutions must be complete, tested, and documented before being considered "done".

#### File Management & Naming

- **FORBIDDEN:** Creating new files when existing ones should be updated.
- **ONLY** create new files for truly new functionality, or where required by best practice.
- **ALWAYS:** File names must be descriptive, semantic, and purposeful.
- **FORBIDDEN:** File names with useless descriptors (e.g., "new", "updated", "fixed", "simple", "clean", etc.).
- All such files MUST be renamed and all references updated accordingly.

#### Code Integrity & Architecture

- **FORBIDDEN:** Bypassing business logic, polluting, or creating mess.
- Maintain all architectural patterns and business logic.
- Prefer minimal, focused, high-quality changes over workarounds.
- Enforce SOLID and DRY (Don't Repeat Yourself) principles without exception.

#### Continuous Integration & Testing

- All changes MUST pass all tests and maintain/raise test coverage.
- Update documentation for all functional/codebase changes.
- Validate changes across environments/platforms.
- Follow proper Git workflows and commit message conventions.

#### One-Change-at-a-Time

- **MANDATORY:** One atomic, small change at a time--never bundle changes.
- Test after each change before proceeding.
- Rollback immediately if anything breaks; do not proceed until resolved.
- Use Git checkpoints and atomic commits with descriptive messages.
- Stop and fix immediately on any failure.

#### Safety & Recovery

- **MANDATORY:** Test before and after every single change.
- Use Git checkpoints for all work.
- Respect user controls (stop, pause, careful mode) at all times.
- Document issues and solutions ("field testing report") as they arise.
- Always be ready to rollback and follow bulletproof safety protocols.

### Quality Verification Checklists

#### Code Quality Verification

- Documentation reflects current codebase (README, etc.).
- All implementation/documentation gaps addressed and resolved.
- Docs updated to reflect actual implementation and focus area.

#### Best Practices Verification

- Compare codebase against industry and framework standards.
- Full iterative review-test-logs-identify-fix cycle completed.
- All best practice violations resolved.

#### Duplication Verification

- Full codebase duplication scan completed.
- Duplicate code, functions, components, files, modules eliminated.
- Shared utilities/modules extracted for common functionality.

#### SOLID Principles Verification

- **Single Responsibility:** Each class/function/module has one reason to change.
- **Open/Closed:** Code is open for extension, closed for modification.
- **Liskov Substitution:** Derived types can substitute their base types.
- **Interface Segregation:** No forced dependencies on unused interfaces.
- **Dependency Inversion:** Depend on abstractions, not concretions.

#### Documentation & Structure Verification

- README.md is clear, complete, and accurate.
- Project overview, installation, usage, API docs complete.
- Directory/file documentation (index.json) up to date.

#### One-Change-at-a-Time Protocol

- Only one atomic change at a time, with pre- and post-change testing.
- Commit checkpoints before/after each change.
- Rollback readiness confirmed for every step.
- User stop/pause/careful mode commands always respected.

#### Safety & Recovery Protocol

- All tests executed before/after every change.
- Rollback/emergency procedures in place.
- User control always maintained (stop/pause/etc.).
- Field testing and recovery documentation complete.

### [CRITICAL] MULTI-INSTANCE GIT SAFETY PROTOCOL - WORK LOSS PREVENTION

**THIS PROTOCOL IS MANDATORY TO PREVENT WORK LOSS IN CONCURRENT AI DEVELOPMENT ENVIRONMENTS**

#### SACRED BRANCH PROTECTION - RFC 2119 COMPLIANCE

- **main/master BRANCHES ARE SACRED:** 
  - **MUST NOT:** Perform direct work, commits, or modifications
  - **MUST NOT:** Branch directly from main/master for features
  - **SHALL:** Use these branches for deployment/release only

- **development BRANCH IS DEFAULT BASE:**
  - **MUST:** All feature/fix branches SHALL originate from development
  - **MUST NOT:** Perform direct work on development branch
  - **SHALL:** All completed features MUST merge back to development

#### MULTI-INSTANCE COORDINATION - MANDATORY FOR CONCURRENT AI DEVELOPMENT

**WHEN MULTIPLE CLAUDE INSTANCES ARE ACTIVE:**

- **MUST:** Each instance SHALL register unique identifier before any git operations
- **MUST:** Each instance SHALL check for active instance ownership before branch operations
- **MUST NOT:** Switch to branches owned by other active instances
- **SHALL:** Follow mandatory instance handoff protocol when transferring work

#### MULTI-INSTANCE SAFE BRANCHING PROTOCOL

**BEFORE CREATING ANY NEW BRANCH, ALL INSTANCES MUST:**

1. **INSTANCE REGISTRATION - MANDATORY:**
   ```bash
   # Each instance MUST register unique identifier
   CLAUDE_INSTANCE_ID="claude-$(date +%s)-$(whoami)-$$"
   echo "$CLAUDE_INSTANCE_ID" > .git/ACTIVE_CLAUDE_INSTANCE_$(echo $CLAUDE_INSTANCE_ID | tr -d '-')
   git add .git/ACTIVE_CLAUDE_INSTANCE_* 2>/dev/null || true
   ```

2. **BRANCH OWNERSHIP CHECK - MANDATORY:**
   ```bash
   # MUST check if branch is owned by another instance
   BRANCH_NAME="[target-branch]"
   if [ -f ".git/BRANCH_OWNER_${BRANCH_NAME}" ]; then
     OWNER=$(cat .git/BRANCH_OWNER_${BRANCH_NAME})
     if [ "$OWNER" != "$CLAUDE_INSTANCE_ID" ]; then
       echo "ERROR: Branch owned by $OWNER - MUST NOT proceed"
       exit 1
     fi
   fi
   ```

3. **SAFETY CHECK CURRENT BRANCH:**
   ```bash
   git status                           # Check for untracked/uncommitted files
   git stash list                       # Check existing stashes
   ```

4. **PROTECT UNCOMMITTED WORK:**
   ```bash
   git add .                            # Track all untracked files (if not in .gitignore)
   git stash push -u -m "WIP-$CLAUDE_INSTANCE_ID: [description]"  # Instance-specific stash
   ```

5. **VERIFY BRANCH CLEANLINESS:**
   ```bash
   git status                           # MUST show "working tree clean"
   ```

**MULTI-INSTANCE BRANCHING DECISION MATRIX:**

- **FIRST FEATURE/FIX:** MUST branch FROM development with ownership claim
  ```bash
  # MUST check development branch availability
  git checkout development
  git pull origin development
  BRANCH_NAME="feature/[descriptive-name]"
  git checkout -b "$BRANCH_NAME"
  
  # MUST claim branch ownership
  echo "$CLAUDE_INSTANCE_ID" > ".git/BRANCH_OWNER_${BRANCH_NAME//\//_}"
  git add ".git/BRANCH_OWNER_${BRANCH_NAME//\//_}"
  git commit -m "lock: branch owned by $CLAUDE_INSTANCE_ID"
  git push origin "$BRANCH_NAME"
  ```

- **SUBSEQUENT FEATURES ON OWNED BRANCH:** MAY branch FROM current branch
  ```bash
  # ONLY if current branch is owned by this instance AND clean
  if [ -f ".git/BRANCH_OWNER_${CURRENT_BRANCH//\//_}" ]; then
    OWNER=$(cat ".git/BRANCH_OWNER_${CURRENT_BRANCH//\//_}")
    if [ "$OWNER" = "$CLAUDE_INSTANCE_ID" ]; then
      git checkout -b "feature/[new-feature-name]"
      # MUST claim new branch ownership
      echo "$CLAUDE_INSTANCE_ID" > ".git/BRANCH_OWNER_feature_new_feature_name"
      git add ".git/BRANCH_OWNER_feature_new_feature_name"
      git commit -m "lock: branch owned by $CLAUDE_INSTANCE_ID"
    fi
  fi
  ```

- **FEATURES WITH UNCOMMITTED WORK:** MUST stash with instance ID, then branch from development
  ```bash
  # MANDATORY: Instance-specific stash first
  git stash push -u -m "WIP-$CLAUDE_INSTANCE_ID: current feature"
  git checkout development
  git pull origin development
  BRANCH_NAME="feature/[new-feature-name]"
  git checkout -b "$BRANCH_NAME"
  
  # MUST claim branch ownership
  echo "$CLAUDE_INSTANCE_ID" > ".git/BRANCH_OWNER_${BRANCH_NAME//\//_}"
  git add ".git/BRANCH_OWNER_${BRANCH_NAME//\//_}"
  git commit -m "lock: branch owned by $CLAUDE_INSTANCE_ID"
  git push origin "$BRANCH_NAME"
  ```

#### MULTI-INSTANCE ATOMIC COMMIT SAFETY PROTOCOL

**MANDATORY COMMIT FREQUENCY - RFC 2119 COMPLIANCE:**
- **MUST:** Commit after every working change when code functions
- **MUST:** Commit or stash all changes before any branch switch
- **SHALL:** Commit current state before any risky operation
- **MUST:** Include instance identifier in all commit operations

**COMMIT MESSAGE FORMAT - MANDATORY:**
```
type(scope): clear description [instance-id]

feat(auth): implement user login validation [claude-1234567890-user-5678]
fix(api): resolve null pointer in user endpoint [claude-1234567890-user-5678]
refactor(db): optimize connection pooling [claude-1234567890-user-5678]
docs(readme): update installation instructions [claude-1234567890-user-5678]
test(unit): add validation for login flow [claude-1234567890-user-5678]
chore(deps): update security dependencies [claude-1234567890-user-5678]
```

**MULTI-INSTANCE COMMIT COMMANDS - MANDATORY:**
```bash
# MUST verify branch ownership before commit
CURRENT_BRANCH=$(git branch --show-current)
OWNER_FILE=".git/BRANCH_OWNER_${CURRENT_BRANCH//\//_}"
if [ -f "$OWNER_FILE" ]; then
  OWNER=$(cat "$OWNER_FILE")
  if [ "$OWNER" != "$CLAUDE_INSTANCE_ID" ]; then
    echo "ERROR: Cannot commit to branch owned by $OWNER"
    exit 1
  fi
fi

git add .                                                    # Stage all changes
git commit -m "type(scope): description [$CLAUDE_INSTANCE_ID]"  # Instance-tagged commit
git push origin "$CURRENT_BRANCH"                          # MUST backup to remote immediately
```

#### MANDATORY INSTANCE HANDOFF PROTOCOL

**WHEN TRANSFERRING WORK BETWEEN CLAUDE INSTANCES:**

**RELEASING INSTANCE (Instance A finishing work) - MUST:**
```bash
# 1. MUST commit all current work
git add .
git commit -m "feat(scope): checkpoint for handoff [$CLAUDE_INSTANCE_ID]"
git push origin "$CURRENT_BRANCH"

# 2. MUST release branch ownership
CURRENT_BRANCH=$(git branch --show-current)
OWNER_FILE=".git/BRANCH_OWNER_${CURRENT_BRANCH//\//_}"
if [ -f "$OWNER_FILE" ]; then
  rm "$OWNER_FILE"
  git add "$OWNER_FILE" 2>/dev/null || git rm "$OWNER_FILE" 2>/dev/null || true
  git commit -m "unlock: branch available for handoff [$CLAUDE_INSTANCE_ID]"
  git push origin "$CURRENT_BRANCH"
fi

# 3. MUST clean instance registration
rm -f .git/ACTIVE_CLAUDE_INSTANCE_$(echo $CLAUDE_INSTANCE_ID | tr -d '-') 2>/dev/null || true
```

**RECEIVING INSTANCE (Instance B taking over) - MUST:**
```bash
# 1. MUST register new instance
CLAUDE_INSTANCE_ID="claude-$(date +%s)-$(whoami)-$$"
echo "$CLAUDE_INSTANCE_ID" > .git/ACTIVE_CLAUDE_INSTANCE_$(echo $CLAUDE_INSTANCE_ID | tr -d '-')

# 2. MUST fetch latest changes and verify branch availability
git fetch --all
git checkout "$TARGET_BRANCH"
git pull origin "$TARGET_BRANCH"

# 3. MUST verify branch is not owned by another instance
OWNER_FILE=".git/BRANCH_OWNER_${TARGET_BRANCH//\//_}"
if [ -f "$OWNER_FILE" ]; then
  echo "ERROR: Branch still owned by $(cat $OWNER_FILE) - handoff incomplete"
  exit 1
fi

# 4. MUST claim branch ownership
echo "$CLAUDE_INSTANCE_ID" > "$OWNER_FILE"
git add "$OWNER_FILE"
git commit -m "lock: branch taken by $CLAUDE_INSTANCE_ID"
git push origin "$TARGET_BRANCH"
```

**HANDOFF VERIFICATION - MANDATORY:**
- **MUST:** Verify all commits are pushed to origin before release
- **MUST:** Verify ownership files are properly updated
- **MUST:** Verify receiving instance can access all work
- **SHALL NOT:** Begin new work until handoff is complete

#### FILE PROTECTION PROTOCOL

**BEFORE ANY BRANCH OPERATION:**

1. **CHECK FOR UNTRACKED FILES:**
   ```bash
   git ls-files --others --exclude-standard  # List untracked files
   ```

2. **VERIFY .gitignore COMPLIANCE:**
   - If untracked files should be ignored: Add to .gitignore
   - If untracked files are work files: Add and commit or stash

3. **MANDATORY STASH BEFORE BRANCH SWITCH:**
   ```bash
   git stash push -u -m "WIP: [description]"  # Include untracked files
   ```

4. **VERIFY CLEAN STATE:**
   ```bash
   git status                           # MUST show "nothing to commit, working tree clean"
   ```

#### MERGE AND SYNC PROTOCOL

**COMPLETING A FEATURE:**

1. **FINAL COMMIT ON FEATURE BRANCH:**
   ```bash
   git add .
   git commit -m "feat(scope): complete [feature description]"
   git push origin [feature-branch]
   ```

2. **SYNC WITH DEVELOPMENT:**
   ```bash
   git checkout development
   git pull origin development
   git checkout [feature-branch]
   git rebase development               # Resolve conflicts if any
   git push origin [feature-branch] --force-with-lease
   ```

3. **MERGE TO DEVELOPMENT:**
   ```bash
   git checkout development
   git merge [feature-branch] --no-ff  # Preserve feature branch history
   git push origin development
   ```

4. **CLEANUP:**
   ```bash
   git branch -d [feature-branch]      # Delete local branch
   git push origin --delete [feature-branch]  # Delete remote branch
   ```

### [ALERT] MANDATORY SAFETY CHECKLIST

**BEFORE EVERY SESSION:**
- [ ] Current branch identified and clean
- [ ] No uncommitted changes without stash
- [ ] Remote origin synchronized
- [ ] .gitignore properly configured

**BEFORE EVERY BRANCH SWITCH:**
- [ ] `git status` shows clean working tree
- [ ] All work stashed or committed
- [ ] Current branch pushed to origin
- [ ] Target branch verified exists

**BEFORE EVERY COMMIT:**
- [ ] Code compiles and runs
- [ ] Tests pass (if applicable)
- [ ] Linting passes
- [ ] Commit message follows format
- [ ] Changes are logical atomic unit

**AFTER EVERY COMMIT:**
- [ ] Pushed to origin immediately
- [ ] Branch status verified
- [ ] Working tree remains clean

### [EMERGENCY] WORK RECOVERY PROTOCOL

**IF WORK IS LOST OR BRANCH CORRUPTED:**

1. **CHECK STASH:**
   ```bash
   git stash list                       # List all stashes
   git stash show -p stash@{0}         # Preview stash content
   git stash apply stash@{0}           # Recover from stash
   ```

2. **CHECK REFLOG:**
   ```bash
   git reflog                          # Show all recent commits
   git checkout [commit-hash]          # Recover from specific commit
   ```

3. **CHECK REMOTE BRANCHES:**
   ```bash
   git fetch --all                     # Fetch all remote branches
   git branch -r                       # List remote branches
   git checkout origin/[branch-name]   # Recover from remote
   ```

**PREVENTION IS BETTER THAN RECOVERY - FOLLOW THE PROTOCOL RELIGIOUSLY**

---

## MCP Server Task Orchestrator - EXPLICIT INSTRUCTION SET

**Full Protocol, RFC 2119, Directory Structure, Deduplication, Artifact Archival, Forbidden Patterns, Pre/Post Pattern Search**

### REQUIREMENTS LANGUAGE PROTOCOL (RFC 2119 & OPERATIONAL TERMS)

#### 1.1 Protocol Statement

All requirements language in this instruction set, and in any referenced protocols or documents, SHALL be interpreted as defined in RFC 2119 <https://datatracker.ietf.org/doc/html/rfc2119>

#### 1.2 Requirements Language Table

| Term                             | Meaning / Required Interpretation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MUST / REQUIRED / SHALL / ALWAYS | Indicates an absolute, non-negotiable requirement of this protocol. Compliance is mandatory in all cases. No exceptions.                                                                                                                                                                                                                                                                                                                                                                                                  |
| MUST NOT / SHALL NOT / NEVER     | Indicates an absolute, non-negotiable prohibition. This action, behaviour, or outcome is forbidden. No exceptions.                                                                                                                                                                                                                                                                                                                                                                                                        |
| FORBIDDEN                        | HARD MUST NOT: Indicates an action, word, pattern, code, file, or artefact that is strictly prohibited. If any item matching a FORBIDDEN rule is found in the codebase (e.g. forbidden file names like "enhanced", forbidden function names, or other banned terms, logic, or artefacts), it MUST be immediately removed, renamed, or replaced. All references MUST be updated, and remediation MUST be logged as a protocol enforcement action. No exceptions, and no warnings--violations require immediate correction. |
| SHOULD / RECOMMENDED             | Indicates a strong recommendation. There may exist valid reasons to deviate, but these should be rare and all consequences must be carefully weighed, documented, and justified.                                                                                                                                                                                                                                                                                                                                          |
| SHOULD NOT / NOT RECOMMENDED     | Indicates that the behaviour is strongly discouraged. There may exist valid reasons in particular circumstances when the behaviour is acceptable, but the full implications must be understood and documented.                                                                                                                                                                                                                                                                                                            |
| MAY / OPTIONAL                   | Indicates something that is truly optional. The choice to include or omit the feature or action is left to the implementer, without impact on overall protocol compliance.                                                                                                                                                                                                                                                                                                                                                |

#### Special Note on "ALWAYS" and "NEVER"

- **ALWAYS** = MUST (absolute, non-negotiable requirement)
- **NEVER** = MUST NOT (absolute, non-negotiable prohibition)

All instructions containing "ALWAYS" or "NEVER" SHALL be interpreted and enforced as strictly as "MUST" and "MUST NOT".

#### Special Note on "FORBIDDEN"

- **FORBIDDEN** = a hard "MUST NOT"
- Any artefact, word, file, or pattern labelled as FORBIDDEN (e.g. file/module/function name "enhanced", or other banned logic or artefacts):
  - MUST be detected, flagged, and immediately removed or refactored from the codebase
  - All references MUST be updated and corrected
  - Remediation MUST be logged as a protocol enforcement action
  - No exceptions and no warnings--immediate correction is REQUIRED

#### Enforcement

- No AI, LLM, or agent is permitted to relax, reinterpret, or weaken the force of these terms.
- All instructions using these words are enforceable protocol, not mere suggestions.

### MANDATORY BEHAVIOUR AND PROTOCOL COMPLIANCE

- **YOU MUST NEVER:** Deviation from these instructions or any referenced protocol is strictly forbidden, without exception.
- **YOU MUST ALWAYS:** Stay in 100% compliance with all protocols listed here and in the Coding Canonical Protocol.
- **YOU MUST ALWAYS:** Complete all coding tasks properly, no short cuts, no "TODOS" no "STUBS" or other placeholders it is FORBIDDEN.
- **YOU MUST ALWAYS:** Search the code base for "TODOs" "Stubs" and other coding tasks which have not been completed or clearly have short cuts instead of proper code. Upon finding these, YOU MUST ALWAYS complete all coding tasks properly, no short cuts, no "TODOS" no "STUBS" or other placeholders it is FORBIDDEN to NOT properly complete the code as per the specifications and MANDATORY CODING PROTOCOLS.
- **YOU MUST ALWAYS:** Ensure all work is auditable, transparent, clearly documented, and of the highest professional standards.
- **YOU MUST ALWAYS:** Use the MCP Server Tool "Task Orchestrator" to track, record, and complete ALL tasks and subtasks--no exceptions.
- **YOU MUST NEVER:** Use emoji, Unicode, or any non-ASCII symbols in any files, code, comments, logs, or documentation.
- **YOU MUST ALWAYS:** Remove all emoji or Unicode if present or encountered in any context or legacy file.
- **YOU MUST ALWAYS:** Use linters and type-checkers at every step--after each change or addition, run linting and static analysis before proceeding.

### IMPORTANT MCP AND GIT CANONICAL INSTRUCTIONS

Use the MCP Server Tools (Task Orchestrator) and Git commands to:

1. Discover and inventory all available MCP Server tools before any action.
2. Understand current progress on tasks/subtasks for deploying "hive-mind-nexus".
3. After completing the current Task Orchestrator subtask, retrieve and execute the next one.

#### Deployment Checklist

- [SEARCH] Always perform a full codebase search and pre-commit branch creation (`git checkout -b <feature>`).
- [TOOL] Use Git commands to identify changed files and `git add` them.
- [CHART] Run AST analysis, linting, type-checking, formatting, compiling, and deduplication using `scripts/utilities`.
- [GEAR] Ensure files compile (`py_compile`) upstream and downstream dependencies.
- Execute `python_auto_code_cleaner`, review its results, then define and run Task Orchestrator subtasks to resolve any remaining issues.
- Check Docker logs, client logs, and any other relevant logs before troubleshooting.

#### Quality Gates (MUST ALWAYS)

- No shortcuts, stubs, or unresolved TODOs remain.
- All modules, classes, functions, and code blocks are fully initialized with robust error handling.
- Professional in-file docstrings/JDoc comments only; no external `.md` docs.
- Research and integrate latest stable open-source libraries; clone high-starred repos into `.\github_repo_clones` for reference or submodule integration.

#### When modifying code

- **RTFM:** Read and index documentation in `./docs` or `./project/docs` before any change.
- Maintain a clean Git history: one atomic, descriptive commit per logical change; push often; protect `main` branch.

---

[ALERT] DUPLICATION PREVENTION & UTILITIES USAGE

- YOU MUST NEVER create a new utility, demo, or test script for functionality that already exists, this is strictly FORBIDDEN
- YOU MUST ALWAYS perform a full-codebase search (using the provided Python tools) to detect duplicate logic, dead code, or partially overlapping implementations before authoring any new code.
- YOU MUST ALWAYS refactor or extend any existing code blocks that already, in part or in full, satisfy the required functionality.
- YOU MUST only introduce new code blocks when no suitable implementations are found in the codebase.
- YOU MUST ALWAYS ensure that all code--both existing and newly added--strictly adheres to the SOLID, DRY, and KISS principles.

---

**NOW PREPARE FOR MY NEXT INSTRUCTION IN THE NEXT MESSAGE**
