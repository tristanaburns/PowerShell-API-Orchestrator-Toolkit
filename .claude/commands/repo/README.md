# Repository Cleanup Commands

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:
1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**


This directory contains repository cleanup commands for Claude Code CLI. These commands are designed to clean up after AI LLMs that create documentation sprawl, ad-hoc code files, and general repository mess.

## MANDATORY PROTOCOL COMPLIANCE

**CRITICAL**: Before using ANY cleanup command, the AI MUST:
1. READ AND INDEX: `./claude/commands/protocol/code-protocol-compliance-prompt.md`
2. READ AND INDEX: `./claude/commands/repo/MANDATORY-PROTOCOL-COMPLIANCE.md`
3. VERIFY explicit user permission before proceeding
4. ACKNOWLEDGE all CANONICAL PROTOCOL requirements

**FORBIDDEN**: Using these commands without protocol compliance

## Available Commands

### 1. `/repo-cleanup-documentation`
**Purpose**: Eliminates documentation sprawl and point-in-time reports
- Removes temporal analysis reports
- Consolidates duplicate README files
- Converts useful documentation to Jupyter notebooks
- Deletes AI-generated documentation artifacts
- Maintains only essential .md files (README.md, CLAUDE.md)

### 2. `/repo-cleanup-code-files`
**Purpose**: Cleans up ad-hoc code files and eliminates duplication
- Removes test scripts not in tests/ directory
- Deletes demo and example implementations
- Refactors useful code into proper modules
- Eliminates code duplication
- Organizes files into correct directories

### 3. `/repo-cleanup-config-scripts`
**Purpose**: Converts forbidden script languages and consolidates configs
- Converts shell scripts (.sh) to Python/Node.js
- Converts batch files (.bat/.cmd) to Python
- Converts PowerShell (.ps1) to Python
- Consolidates duplicate configuration files
- Organizes configs into proper structure

### 4. `/repo-cleanup-unicode-emoji`
**Purpose**: Removes all Unicode and emoji from the codebase
- Eliminates emoji from code, comments, and docs
- Replaces Unicode symbols with ASCII equivalents
- Cleans file names to ASCII-only
- Adds prevention hooks
- Ensures pure ASCII codebase

### 5. `/repo-cleanup-recursive`
**Purpose**: Applies all cleanup protocols recursively through subdirectories
- Traverses entire directory tree
- Applies all cleanup protocols to each directory
- Handles cross-directory deduplication
- Tracks progress with checkpoints
- Enables resume capability

### 6. `/repo-cleanup-master`
**Purpose**: Master orchestration of all cleanup protocols
- Executes all cleanup phases in optimal sequence
- Creates pre-cleanup backup
- Validates between phases
- Provides rollback capability
- Achieves pristine repository state

## Usage Examples

```bash
# Run complete repository cleanup
/repo-cleanup-master

# Clean up documentation only
/repo-cleanup-documentation

# Focus on removing test scripts
/repo-cleanup-code-files tests

# Convert all shell scripts
/repo-cleanup-config-scripts shell

# Remove all Unicode/emoji
/repo-cleanup-unicode-emoji

# Recursive cleanup from specific directory
/repo-cleanup-recursive --from src/

# Dry run to see what would be cleaned
/repo-cleanup-master --dry-run
```

## Cleanup Philosophy

These commands follow strict protocols:

1. **MANDATORY** actions that must be completed
2. **FORBIDDEN** patterns that must be eliminated
3. **Validation gates** between operations
4. **Atomic operations** with rollback capability
5. **Progress tracking** for resumability

## Important Notes

- Always commit your changes before running cleanup commands
- Each command validates its results before completion
- The master cleanup runs all protocols in sequence
- Cleanup is aggressive - backup important work first
- All operations maintain code functionality

## Protocol Compliance

All commands strictly enforce:
- CANONICAL PROTOCOL adherence
- SOLID/DRY/KISS principles
- No Unicode or emoji usage
- Permitted programming languages only
- Clean repository structure
- Zero code duplication