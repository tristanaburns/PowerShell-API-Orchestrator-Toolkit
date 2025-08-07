# Repository Documentation Cleanup Protocol (SAFE VERSION)

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:
1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**

---

## ⚠️ SAFETY-FIRST DOCUMENTATION CLEANUP ⚠️

**THIS IS THE SAFE VERSION OF DOCUMENTATION CLEANUP**

This command has been redesigned to prevent accidental deletion of important documentation while still maintaining a clean repository.

---

## CANONICAL PROTOCOL ENFORCEMENT - READ FIRST

### 1. SAFETY PRINCIPLES

**BEFORE ANY DELETION:**
1. **PREVIEW** - Show what would be deleted
2. **CONFIRM** - Get explicit user confirmation
3. **BACKUP** - Create backup branch before major deletions
4. **PRESERVE** - Keep all enduring and architectural documentation

### 2. PROTECTED PATTERNS

**NEVER DELETE FILES CONTAINING:**
- `architecture` - Architectural documentation
- `design` - Design documentation
- `api` - API documentation
- `guide` - User/developer guides
- `tutorial` - Educational content
- `reference` - Reference documentation
- `specification` - Technical specifications
- `requirements` - Project requirements
- `[ENDURING` - Enduring documents
- `CANONICAL` - Canonical documentation

**ALWAYS PRESERVE:**
- `/docs/architecture/` - All architecture docs
- `/docs/api/` - All API documentation
- `README.md` - Primary readme files
- `CLAUDE.md` - Claude configuration
- `LICENSE*` - License files
- `CONTRIBUTING*` - Contribution guides
- `CHANGELOG*` - Change logs
- `SECURITY*` - Security documentation

---

## SAFE CLEANUP PHASES

### Phase 1: Inventory and Preview

```bash
# First, create an inventory of potential cleanup candidates
echo "=== DOCUMENTATION CLEANUP PREVIEW ==="
echo "The following files are candidates for cleanup:"
echo ""

# Find temporal reports (with safe patterns)
echo "1. TEMPORAL REPORTS (safe patterns):"
find . -name "*-report-[0-9]*.md" -o -name "*-analysis-[0-9]*.md" -o -name "*-summary-[0-9]*.md" | grep -v "/docs/architecture/" | sort

# Find obvious duplicates
echo ""
echo "2. OBVIOUS DUPLICATES:"
find . -name "README_*.md" -o -name "README-old.md" -o -name "README-backup.md" -o -name "*.backup.md" | sort

# Find AI session artifacts (specific patterns only)
echo ""
echo "3. AI SESSION ARTIFACTS:"
find . -name "claude-session-*.md" -o -name "gpt-output-*.md" -o -name "ai-conversation-*.md" | sort

# Find temporary documentation
echo ""
echo "4. TEMPORARY DOCUMENTATION:"
find . -name "TODO.md" -o -name "NOTES.md" -o -name "temp-*.md" -o -name "draft-*.md" | grep -v "/docs/" | sort
```

### Phase 2: User Review and Confirmation

**MANDATORY USER INTERACTION:**
```
Please review the files listed above.
- Files marked for deletion should be reviewed
- Any file you want to keep should be noted
- Confirm you want to proceed with cleanup

Type 'CONFIRM' to proceed or 'CANCEL' to abort:
```

### Phase 3: Safe Deletion with Logging

**FOR EACH FILE TO DELETE:**
1. Log the deletion to `cleanup-log-[timestamp].txt`
2. Show file path and first 5 lines of content
3. Get individual confirmation for files > 1000 lines
4. Delete only after confirmation

### Phase 4: Documentation Consolidation (NOT Deletion)

**INSTEAD OF DELETING, CONSOLIDATE:**
- Multiple READMEs → Merge into single README.md
- Scattered docs → Organize into `/docs/` structure
- Temporal reports → Archive to `/docs/archive/[year]/`

### Phase 5: Jupyter Notebook Conversion

**SAFE CONVERSION PROCESS:**
1. Copy .md file to .ipynb (don't delete original yet)
2. Verify notebook renders correctly
3. Get user confirmation
4. Only then remove original .md

---

## SAFE PATTERNS FOR CLEANUP

### SAFE TO DELETE (with confirmation):
```yaml
safe_patterns:
  temporal_with_dates:
    - "*-report-2024-*.md"  # Reports with specific dates
    - "*-analysis-2024-*.md" # Analysis with specific dates
    - "meeting-notes-*.md"   # Meeting notes with dates
  
  obvious_temps:
    - "temp-*.md"           # Clearly temporary
    - "test-*.md"           # Test documentation
    - "draft-*.md"          # Draft documents
    
  clear_duplicates:
    - "*.backup.md"         # Explicit backups
    - "*-old.md"            # Explicit old versions
    - "*-copy.md"           # Explicit copies
```

### REQUIRES REVIEW (never auto-delete):
```yaml
review_required:
  - Files containing "analysis" without dates
  - Files containing "report" without dates  
  - Files containing "summary" without dates
  - Any file > 1000 lines
  - Any file in /docs/ directory
  - Any file with diagrams or images
```

---

## ENHANCED SAFETY COMMANDS

### Interactive Cleanup Mode:
```bash
# Start interactive cleanup session
/repo-cleanup-documentation --interactive

# Preview only (no deletions)
/repo-cleanup-documentation --preview

# Create backup before cleanup
/repo-cleanup-documentation --backup

# Archive instead of delete
/repo-cleanup-documentation --archive
```

### Safety Options:
- `--interactive` - Confirm each file individually
- `--preview` - Show what would be deleted without deleting
- `--backup` - Create backup branch first
- `--archive` - Move to archive instead of deleting
- `--dry-run` - Simulate the entire process

---

## CRITICAL SAFETY RULES

1. **NEVER** use wildcard patterns like `*analysis*.md`
2. **ALWAYS** preview before deleting
3. **REQUIRE** user confirmation for deletions
4. **PRESERVE** all architectural documentation
5. **BACKUP** before major operations
6. **LOG** all deletions for recovery
7. **ARCHIVE** instead of delete when unsure

---

## ERROR PREVENTION

**FORBIDDEN PRACTICES:**
- Deleting without preview
- Using overly broad patterns
- Ignoring user concerns
- Deleting architectural docs
- Removing files without reading them
- Batch deleting without review

**MANDATORY PRACTICES:**
- Read file content before deletion
- Check file importance
- Verify not referenced elsewhere
- Ensure proper backups exist
- Document why file was removed
- Provide recovery instructions

---

## RECOVERY PROCEDURES

**IF ACCIDENTAL DELETION OCCURS:**
```bash
# Check cleanup log
cat cleanup-log-*.txt

# Recover from git
git checkout HEAD~1 -- [deleted-file]

# Restore from backup branch
git checkout backup-cleanup-[date] -- [deleted-file]
```

---

## Usage Examples

### Safe Preview:
```bash
/repo-cleanup-documentation-safe --preview
# Shows what would be cleaned up without deleting anything
```

### Interactive Cleanup:
```bash
/repo-cleanup-documentation-safe --interactive
# Asks for confirmation on each file
```

### Archive Old Docs:
```bash
/repo-cleanup-documentation-safe --archive
# Moves old docs to /docs/archive/ instead of deleting
```

---

**REMEMBER:** The goal is a clean repository WITHOUT losing important documentation. When in doubt, preserve the file!