# Claude Code CLI Commands Manager

This directory contains scripts for managing and updating Claude Code CLI command files with compliance requirements and best practices.

## Overview

The Commands Manager is a collection of Python scripts that systematically update Claude Code CLI command files (`.md` files in `.claude/commands/`) with mandatory compliance requirements, ensuring consistent development practices across all commands.

## Main Runner Script

### `run_all_updates.py` - Sequential Script Runner

Runs all individual update scripts in the correct sequence on one or more directories.

**Usage:**

```bash
# Update current directory
python .claude/commands-manager/run_all_updates.py

# Update specific directory
python .claude/commands-manager/run_all_updates.py C:/GitHub_Development/projects/hive-mind-nexus

# Update multiple directories
python .claude/commands-manager/run_all_updates.py . ../another-repo ../third-repo
```

The script will:

1. Change to each target directory
2. Run all update scripts in sequence
3. Show progress and results
4. Return to original directory

## Individual Update Scripts

The following scripts are run in order by `run_all_updates.py`:

1. **`update_commands_with_compliance.py`** - Adds initial compliance requirements
2. **`fix_protocol_references.py`** - Fixes protocol file references
3. **`update_git_practices.py`** - Updates Git branch naming conventions
4. **`add_devsecops_loop.py`** - Adds DevSecOps infinite loop
5. **`add_mcp_requirements.py`** - Adds MCP tool requirements
6. **`add_no_mocking_requirements.py`** - Adds no-mocking/no-shortcuts rules
7. **`add_200_verification.py`** - Adds 200% verification methodology
8. **`add_hygiene_enforcement.py`** - Adds codebase hygiene rules
9. **`add_init_requirement.py`** - Adds /init requirement
10. **`update_repo_cleanup_forbidden_words.py`** - Adds forbidden words (simple, clean, enhanced, intelligent) and vague naming instructions to repo cleanup commands

## Synchronization Script

### `sync_to_multiple_repos.py` - Multi-Repository Sync

Synchronizes updated command files to multiple repositories:

- Creates timestamped backups before overwriting
- Copies all command files, scripts, hooks, and settings
- Shows detailed progress for each repository
- Provides summary report

**Default targets:**

- `C:/GitHub_Development/projects/hive-mind-nexus/.claude`
- `C:/GitHub_Development/vscode-toolkit/.claude`
- `C:/GitHub_Development/vscode-toolkit/prompt_templates/.claude`

**Usage:**

```bash
# Sync to all configured repositories
python .claude/commands-manager/sync_to_multiple_repos.py
```

Edit the `TARGETS` list in the script to add/remove repositories or disable specific targets.

## Quick Start

### 1. Update Command Files

```bash
# Update current repository
python .claude/commands-manager/update_all_commands.py

# Update multiple repositories at once
python .claude/commands-manager/update_all_commands.py \
    .claude \
    C:/GitHub_Development/projects/hive-mind-nexus/.claude \
    C:/GitHub_Development/vscode-toolkit/.claude
```

### 2. Synchronize to Other Repositories

```bash
# Sync to all configured repositories
python .claude/commands-manager/sync_to_multiple_repos.py
```

## Workflow Example

```bash
# Step 1: Update all repositories with compliance requirements
python .claude/commands-manager/update_all_commands.py \
    .claude \
    C:/GitHub_Development/projects/hive-mind-nexus/.claude \
    C:/GitHub_Development/vscode-toolkit/.claude \
    C:/GitHub_Development/vscode-toolkit/prompt_templates/.claude

# Step 2: Review the changes
# Check the updated files in each repository

# Step 3: Commit changes in each repository
cd C:/GitHub_Development/projects/hive-mind-nexus
git add .claude/
git commit -m "feat: add Claude Code CLI compliance requirements"

cd C:/GitHub_Development/vscode-toolkit
git add .claude/
git commit -m "feat: add Claude Code CLI compliance requirements"
```

## Compliance Sections Added

The scripts add the following 11 mandatory compliance sections to command files:

1. **Protocol Compliance Requirements** - Read code-protocol before execution
2. **Git Best Practices** - branching and atomic commits
3. **Containerized Application Requirements** - Build/validate after changes
4. **Code Change Compliance** - Follow relevant Claude commands
5. **RTFM Requirements** - Read notebooks, docs, search online
6. **DevSecOps Loop** - Enforce complete development cycle
7. **Enterprise Code Safety** - No mocking, TODOs, or shortcuts
8. **MCP Server Tool Usage** - Use Claude CLI's /mcp commands
9. **Compliance Verification Checklist** - Pre-execution checks
10. **Codebase Hygiene Enforcement** - Run cleanup commands
11. **Post-Completion Reinitialization** - Run /init after cleanup

## Target Command Directories

The scripts update `.md` files in these directories:

- `.claude/commands/code/`
- `.claude/commands/repo/`
- `.claude/commands/actions/`
- `.claude/commands/testing/`
- `.claude/commands/docs/`
- `.claude/commands/composite/`
- `.claude/commands/frontend/`
- `.claude/commands/backend/`
- `.claude/commands/architecture/`
- `.claude/commands/planning/`
- `.claude/commands/implementation/`

Files that are skipped:

- `README.md` files
- Protocol files in `.claude/commands/protocol/`
- `CANONICAL-COMPLIANCE-HEADER.md`

## Customization

Each script can be modified to:

- Target specific directories
- Skip certain files
- Modify the compliance text
- Add additional requirements

The scripts use glob patterns to find files, making it easy to add new command directories.

## Best Practices

1. **Always backup** before running updates (scripts create `.backup` files when using sync)
2. **Review changes** after running scripts
3. **Test commands** after updates to ensure they work correctly
4. **Create a feature branch** before making bulk updates
5. **Run scripts in order** to ensure proper section numbering

## Troubleshooting

If a script reports "already has X section", it means the compliance requirement was previously added. The scripts are idempotent and safe to run multiple times.

If insertion points aren't found, check that the command file structure matches the expected format with proper section markers.

## Maintenance

When adding new compliance requirements:

1. Create a new script following the pattern of existing scripts
2. Update this README with the new script documentation
3. Add the script to the execution sequence
4. Update the CANONICAL-COMPLIANCE-HEADER.md if needed

---

_These scripts ensure all Claude Code CLI commands follow consistent, professional development practices with compliance requirements._
