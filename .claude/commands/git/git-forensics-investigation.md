# Git Forensics Investigation Protocol

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:

1. Analyze what forensic evidence needs to be gathered
2. Plan your investigation approach to trace corruption sources  
3. Consider the timeline and sequence of changes that led to issues
4. Only then proceed with the systematic forensics investigation

**This thinking requirement is MANDATORY and must be followed for every forensics action.**

---

## ⚠️ GIT FORENSICS INVESTIGATION FOR DATA CORRUPTION ANALYSIS ⚠️

### CANONICAL FORENSICS DIRECTIVE

**THIS PROTOCOL PROVIDES SYSTEMATIC GIT FORENSICS:**

- **MUST** trace exact sequence of changes that led to data corruption
- **SHALL** identify all commits, branches, and merge points involved in corruption
- **MUST** analyze author patterns, timestamps, and change frequency to identify anomalies  
- **SHALL** create timeline of all changes affecting corrupted components
- **MUST** identify last known good state with forensic precision
- **SHALL** map all file dependencies and cross-impacts of changes

---

## PHASE 1: CRIME SCENE INVESTIGATION

### SYSTEMATIC EVIDENCE COLLECTION

**STEP 1: ESTABLISH INVESTIGATION BASELINE**

```bash
# Function to establish forensics investigation baseline
establish_forensics_baseline() {
    local investigation_log="git_forensics_investigation_$(date +%Y%m%d_%H%M%S).log"
    
    echo "=== GIT FORENSICS INVESTIGATION ===" > "$investigation_log"
    echo "Investigation Start: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$investigation_log"
    echo "Investigator: [Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)]" >> "$investigation_log"
    echo "Current Branch: $(git branch --show-current)" >> "$investigation_log"
    echo "Current Commit: $(git rev-parse HEAD)" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Document suspected corruption symptoms
    echo "=== CORRUPTION SYMPTOMS DOCUMENTATION ===" >> "$investigation_log"
    echo "Reported Issues:" >> "$investigation_log"
    echo "- [TO BE FILLED: API endpoints failing]" >> "$investigation_log"
    echo "- [TO BE FILLED: Container build failures]" >> "$investigation_log"  
    echo "- [TO BE FILLED: Missing functionality]" >> "$investigation_log"
    echo "- [TO BE FILLED: Framework component issues]" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Repository integrity check
    echo "=== REPOSITORY INTEGRITY ASSESSMENT ===" >> "$investigation_log"
    echo "Git FSCk Results:" >> "$investigation_log"
    git fsck --full --strict >> "$investigation_log" 2>&1 || echo "REPOSITORY_INTEGRITY_ISSUES_DETECTED" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Current repository state
    echo "=== CURRENT REPOSITORY STATE ===" >> "$investigation_log"
    echo "Working Directory Status:" >> "$investigation_log"
    git status --porcelain >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    echo "Staged Changes:" >> "$investigation_log"
    git diff --cached --stat >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    echo "Unstaged Changes:" >> "$investigation_log" 
    git diff --stat >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Reference state
    echo "=== REFERENCE INFORMATION ===" >> "$investigation_log"
    echo "All Branches:" >> "$investigation_log"
    git branch -a --sort=-committerdate >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    echo "Recent Tags:" >> "$investigation_log"
    git tag --sort=-version:refname | head -10 >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    echo "Remote Information:" >> "$investigation_log"
    git remote -v >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    echo "✅ FORENSICS BASELINE ESTABLISHED: $investigation_log"
    echo "$investigation_log"
}
```

**STEP 2: TIMELINE RECONSTRUCTION**

```bash
# Function to reconstruct complete timeline of changes
reconstruct_change_timeline() {
    local investigation_log=$1
    
    echo "=== CHANGE TIMELINE RECONSTRUCTION ===" >> "$investigation_log"
    
    # Last 50 commits across all branches with full details
    echo "--- COMPLETE COMMIT TIMELINE (Last 50 commits) ---" >> "$investigation_log"
    git log --all --graph --pretty=format:"%h|%ad|%an|%ae|%s|%D" --date=iso --max-count=50 | while IFS='|' read -r hash date author email subject refs; do
        echo "COMMIT: $hash" >> "$investigation_log"
        echo "  Date: $date" >> "$investigation_log"
        echo "  Author: $author <$email>" >> "$investigation_log"
        echo "  Subject: $subject" >> "$investigation_log"
        echo "  Refs: $refs" >> "$investigation_log"
        
        # Files changed in this commit
        echo "  Files Changed:" >> "$investigation_log"
        git diff-tree --no-commit-id --name-status -r $hash >> "$investigation_log" 2>/dev/null || echo "    NO_FILES_CHANGED" >> "$investigation_log"
        
        # Commit size analysis
        echo "  Change Statistics:" >> "$investigation_log"
        git show --stat $hash | tail -n 1 >> "$investigation_log" 2>/dev/null || echo "    STAT_ERROR" >> "$investigation_log"
        echo "" >> "$investigation_log"
    done
    
    # Merge commit analysis
    echo "--- MERGE COMMIT ANALYSIS ---" >> "$investigation_log"
    git log --merges --pretty=format:"%h|%ad|%an|%s" --date=iso --max-count=20 | while IFS='|' read -r hash date author subject; do
        echo "MERGE: $hash" >> "$investigation_log"
        echo "  Date: $date" >> "$investigation_log"
        echo "  Author: $author" >> "$investigation_log"
        echo "  Subject: $subject" >> "$investigation_log"
        
        # Merge parents
        echo "  Parents:" >> "$investigation_log"
        git show --no-patch --format="    %P" $hash >> "$investigation_log"
        
        # Files affected by merge
        echo "  Files Affected by Merge:" >> "$investigation_log"
        git diff-tree --cc --name-status $hash >> "$investigation_log" 2>/dev/null || echo "    MERGE_DIFF_ERROR" >> "$investigation_log"
        echo "" >> "$investigation_log"
    done
    
    # Branch creation/deletion events
    echo "--- BRANCH LIFECYCLE EVENTS ---" >> "$investigation_log"
    git reflog --date=iso | grep -E "checkout|branch" | head -20 >> "$investigation_log"
    echo "" >> "$investigation_log"
}
```

**STEP 3: AUTHOR AND PATTERN ANALYSIS**

```bash
# Function to analyze author patterns and identify anomalies
analyze_author_patterns() {
    local investigation_log=$1
    
    echo "=== AUTHOR PATTERN ANALYSIS ===" >> "$investigation_log"
    
    # Commit frequency by author
    echo "--- COMMIT FREQUENCY BY AUTHOR (Last 100 commits) ---" >> "$investigation_log"
    git log --pretty=format:"%an|%ae" --max-count=100 | sort | uniq -c | sort -nr >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Time-based commit patterns
    echo "--- COMMIT TIMING PATTERNS ---" >> "$investigation_log"
    git log --pretty=format:"%ad|%an" --date=format:"%Y-%m-%d %H" --max-count=50 | while IFS='|' read -r datetime author; do
        echo "$datetime: $author" >> "$investigation_log"
    done
    echo "" >> "$investigation_log"
    
    # Rapid-fire commit detection (potential corruption source)
    echo "--- RAPID-FIRE COMMIT DETECTION ---" >> "$investigation_log"
    echo "Commits within 5 minutes of each other:" >> "$investigation_log"
    git log --pretty=format:"%ad|%h|%s" --date=format:"%s" --max-count=50 | sort -n | awk -F'|' '
    BEGIN { prev_time = 0; prev_hash = ""; prev_msg = "" }
    {
        if ($1 - prev_time < 300 && prev_time != 0) {
            print "RAPID SEQUENCE:"
            print "  " prev_time "|" prev_hash "|" prev_msg
            print "  " $1 "|" $2 "|" $3
            print "  Time difference: " ($1 - prev_time) " seconds"
            print ""
        }
        prev_time = $1; prev_hash = $2; prev_msg = $3
    }' >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Large commit detection (potential bulk changes)
    echo "--- LARGE COMMIT DETECTION ---" >> "$investigation_log"
    git log --pretty=format:"%h|%s" --shortstat --max-count=30 | while read -r line; do
        if [[ "$line" =~ ^[a-f0-9]+\| ]]; then
            current_commit="$line"
        elif [[ "$line" =~ changed, ]]; then
            # Parse stats line
            files_changed=$(echo "$line" | grep -o '[0-9]\+ file' | grep -o '[0-9]\+')
            insertions=$(echo "$line" | grep -o '[0-9]\+ insertion' | grep -o '[0-9]\+' || echo 0)
            deletions=$(echo "$line" | grep -o '[0-9]\+ deletion' | grep -o '[0-9]\+' || echo 0)
            
            total_changes=$((insertions + deletions))
            if [[ $total_changes -gt 500 ]]; then
                echo "LARGE COMMIT: $current_commit" >> "$investigation_log"
                echo "  Files: $files_changed, Insertions: $insertions, Deletions: $deletions" >> "$investigation_log"
                echo "" >> "$investigation_log"
            fi
        fi
    done
}
```

---

## PHASE 2: CHANGE IMPACT ANALYSIS

### SYSTEMATIC IMPACT TRACING

**STEP 1: FILE DEPENDENCY MAPPING**

```bash
# Function to map file dependencies and change impacts
map_file_dependencies() {
    local investigation_log=$1
    local target_file=$2
    
    echo "=== FILE DEPENDENCY ANALYSIS: $target_file ===" >> "$investigation_log"
    
    # Direct import dependencies (Python)
    if [[ "$target_file" == *.py ]]; then
        echo "--- PYTHON IMPORT DEPENDENCIES ---" >> "$investigation_log"
        echo "Direct imports in current version:" >> "$investigation_log"
        if [ -f "$target_file" ]; then
            grep -n "^import\|^from.*import" "$target_file" >> "$investigation_log"
        else
            echo "FILE_NOT_FOUND_IN_WORKING_DIRECTORY" >> "$investigation_log"
        fi
        echo "" >> "$investigation_log"
        
        # Files that import this file
        echo "Files that import $target_file:" >> "$investigation_log"
        find . -name "*.py" -exec grep -l "$(basename "${target_file%.*}")" {} \; 2>/dev/null >> "$investigation_log"
        echo "" >> "$investigation_log"
    fi
    
    # Configuration file dependencies
    if [[ "$target_file" == *.json || "$target_file" == *.yml || "$target_file" == *.yaml ]]; then
        echo "--- CONFIGURATION FILE USAGE ---" >> "$investigation_log"
        echo "Files that reference $target_file:" >> "$investigation_log"
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" \) -exec grep -l "$(basename "$target_file")" {} \; 2>/dev/null >> "$investigation_log"
        echo "" >> "$investigation_log"
    fi
    
    # Git history of file
    echo "--- COMPLETE CHANGE HISTORY ---" >> "$investigation_log"
    git log --follow --pretty=format:"%h|%ad|%an|%s" --date=iso -- "$target_file" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Files commonly changed together with target file
    echo "--- FILES COMMONLY CHANGED TOGETHER ---" >> "$investigation_log"
    git log --name-only --pretty=format:"COMMIT:%h" -- "$target_file" | grep -v "^COMMIT:" | sort | uniq -c | sort -nr | head -10 >> "$investigation_log"
    echo "" >> "$investigation_log"
}
```

**STEP 2: CRITICAL PATH ANALYSIS**

```bash
# Function to identify critical paths affected by changes
analyze_critical_paths() {
    local investigation_log=$1
    
    echo "=== CRITICAL PATH ANALYSIS ===" >> "$investigation_log"
    
    # Identify critical application components
    declare -a CRITICAL_COMPONENTS=(
        "api-gateway-service/app/main.py"
        "mcp-config-local.json"
        "docker-compose.yml"
        "package.json"
        "requirements.txt"
        "Makefile"
    )
    
    for component in "${CRITICAL_COMPONENTS[@]}"; do
        if [ -f "$component" ] || git ls-files | grep -q "$component"; then
            echo "--- CRITICAL COMPONENT: $component ---" >> "$investigation_log"
            
            # Recent changes to this component
            echo "Recent changes (last 10 commits):" >> "$investigation_log"
            git log --oneline -10 -- "$component" >> "$investigation_log" 2>/dev/null || echo "NO_RECENT_CHANGES" >> "$investigation_log"
            echo "" >> "$investigation_log"
            
            # Current status
            if [ -f "$component" ]; then
                echo "Current status: EXISTS" >> "$investigation_log"
                echo "Current size: $(wc -l < "$component" 2>/dev/null || echo 0) lines" >> "$investigation_log"
                
                # Validate syntax/format
                case "$component" in
                    *.py)
                        python -m py_compile "$component" 2>/dev/null && echo "Python syntax: VALID" >> "$investigation_log" || echo "Python syntax: INVALID" >> "$investigation_log"
                        ;;
                    *.json)
                        jq empty "$component" 2>/dev/null && echo "JSON syntax: VALID" >> "$investigation_log" || echo "JSON syntax: INVALID" >> "$investigation_log"
                        ;;
                    *.yml|*.yaml)
                        python -c "import yaml; yaml.safe_load(open('$component'))" 2>/dev/null && echo "YAML syntax: VALID" >> "$investigation_log" || echo "YAML syntax: INVALID" >> "$investigation_log"
                        ;;
                esac
            else
                echo "Current status: MISSING" >> "$investigation_log"
            fi
            echo "" >> "$investigation_log"
        fi
    done
    
    # Cross-component impact analysis
    echo "--- CROSS-COMPONENT IMPACT ANALYSIS ---" >> "$investigation_log"
    echo "Recent commits affecting multiple critical components:" >> "$investigation_log"
    
    for component in "${CRITICAL_COMPONENTS[@]}"; do
        git log --pretty=format:"%h" -- "$component" | head -5
    done | sort | uniq -c | sort -nr | while read -r count commit; do
        if [[ $count -gt 1 ]]; then
            echo "Commit $commit affected $count critical components:" >> "$investigation_log"
            git show --name-only --pretty=format:"  %s (%an, %ar)" $commit >> "$investigation_log"
            echo "" >> "$investigation_log"
        fi
    done
}
```

---

## PHASE 3: CORRUPTION SOURCE IDENTIFICATION

### SYSTEMATIC CORRUPTION TRACING

**STEP 1: BINARY SEARCH FOR CORRUPTION POINT**

```bash
# Function to perform binary search to find exact corruption point
binary_search_corruption() {
    local investigation_log=$1
    local good_commit=$2
    local bad_commit=$3
    local test_command=$4
    
    echo "=== BINARY SEARCH FOR CORRUPTION POINT ===" >> "$investigation_log"
    echo "Good Commit: $good_commit" >> "$investigation_log"
    echo "Bad Commit: $bad_commit" >> "$investigation_log"
    echo "Test Command: $test_command" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Start git bisect
    echo "Starting binary search..." >> "$investigation_log"
    git bisect start >> "$investigation_log" 2>&1
    git bisect bad $bad_commit >> "$investigation_log" 2>&1
    git bisect good $good_commit >> "$investigation_log" 2>&1
    
    # Manual bisect process (automated version would need actual test)
    echo "--- BISECT PROCESS ---" >> "$investigation_log"
    echo "Manual bisect required - test each suggested commit:" >> "$investigation_log"
    
    # Get bisect suggestions
    local bisect_count=0
    while [[ $bisect_count -lt 10 ]]; do
        local current_commit=$(git rev-parse HEAD)
        echo "Test Commit: $current_commit" >> "$investigation_log"
        echo "  Date: $(git show --no-patch --format="%ad" --date=iso $current_commit)" >> "$investigation_log"
        echo "  Author: $(git show --no-patch --format="%an" $current_commit)" >> "$investigation_log"
        echo "  Subject: $(git show --no-patch --format="%s" $current_commit)" >> "$investigation_log"
        echo "  Files Changed: $(git diff-tree --no-commit-id --name-only -r $current_commit | wc -l)" >> "$investigation_log"
        echo "" >> "$investigation_log"
        
        # Manual testing required here
        echo "MANUAL TEST REQUIRED: Run '$test_command' and mark as good/bad" >> "$investigation_log"
        echo "Then continue bisect process" >> "$investigation_log"
        echo "" >> "$investigation_log"
        
        bisect_count=$((bisect_count + 1))
        break  # Manual intervention required
    done
    
    # Reset bisect (when manual process is complete)
    echo "After completing manual bisect, run: git bisect reset" >> "$investigation_log"
    echo "" >> "$investigation_log"
}
```

**STEP 2: COMMIT CONTENT FORENSICS**

```bash
# Function to perform detailed forensics on suspicious commits
commit_content_forensics() {
    local investigation_log=$1
    local suspicious_commit=$2
    
    echo "=== COMMIT CONTENT FORENSICS: $suspicious_commit ===" >> "$investigation_log"
    
    # Complete commit information
    echo "--- COMPLETE COMMIT DETAILS ---" >> "$investigation_log"
    git show --no-patch --format="Hash: %H%nAuthor: %an <%ae>%nAuthor Date: %ad%nCommitter: %cn <%ce>%nCommitter Date: %cd%nSubject: %s%n%nBody:%n%b" --date=iso $suspicious_commit >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Parent analysis
    echo "--- PARENT COMMIT ANALYSIS ---" >> "$investigation_log"
    git show --no-patch --format="Parents: %P" $suspicious_commit >> "$investigation_log"
    
    local parents=($(git show --no-patch --format="%P" $suspicious_commit))
    for parent in "${parents[@]}"; do
        echo "Parent $parent:" >> "$investigation_log"
        git show --no-patch --format="  %s (%an, %ar)" $parent >> "$investigation_log"
    done
    echo "" >> "$investigation_log"
    
    # Files changed analysis
    echo "--- FILES CHANGED ANALYSIS ---" >> "$investigation_log"
    git diff-tree --no-commit-id --name-status -r $suspicious_commit >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Detailed change analysis
    echo "--- DETAILED CHANGE CONTENT ---" >> "$investigation_log"
    git show $suspicious_commit >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Change statistics
    echo "--- CHANGE STATISTICS ---" >> "$investigation_log"
    git show --stat $suspicious_commit >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Identify high-risk changes
    echo "--- HIGH-RISK CHANGE DETECTION ---" >> "$investigation_log"
    
    # Look for dangerous patterns
    git show $suspicious_commit | grep -n -E "(import|from.*import|def|class|async|await)" >> "$investigation_log" && echo "Code structure changes detected" >> "$investigation_log"
    git show $suspicious_commit | grep -n -E "(TODO|FIXME|HACK|XXX)" >> "$investigation_log" && echo "Temporary code markers detected" >> "$investigation_log"
    git show $suspicious_commit | grep -n -E "(print|console\.log|debug)" >> "$investigation_log" && echo "Debug code detected" >> "$investigation_log"
    git show $suspicious_commit | grep -n -E "(password|secret|key|token)" -i >> "$investigation_log" && echo "Sensitive data patterns detected" >> "$investigation_log"
    
    echo "" >> "$investigation_log"
    
    # Context analysis - what was happening around this commit
    echo "--- TEMPORAL CONTEXT ANALYSIS ---" >> "$investigation_log"
    echo "Commits before and after:" >> "$investigation_log"
    git log --oneline -5 ${suspicious_commit}~2..${suspicious_commit}+2 >> "$investigation_log" 2>/dev/null || git log --oneline -5 $suspicious_commit >> "$investigation_log"
    echo "" >> "$investigation_log"
}
```

---

## PHASE 4: RECOVERY STRATEGY FORENSICS

### FORENSICS-GUIDED RECOVERY PLANNING

**STEP 1: EVIDENCE-BASED RECOVERY PRIORITIZATION**

```bash
# Function to create recovery strategy based on forensics evidence
create_forensics_recovery_strategy() {
    local investigation_log=$1
    
    echo "=== FORENSICS-BASED RECOVERY STRATEGY ===" >> "$investigation_log"
    
    # Analyze corruption severity by component
    echo "--- CORRUPTION SEVERITY ASSESSMENT ---" >> "$investigation_log"
    
    declare -A corruption_severity
    declare -a critical_files=(
        "api-gateway-service/app/main.py"
        "mcp-config-local.json" 
        "docker-compose.yml"
        "package.json"
    )
    
    for file in "${critical_files[@]}"; do
        echo "Analyzing corruption severity for: $file" >> "$investigation_log"
        
        # Check if file exists and is valid
        if [ -f "$file" ]; then
            echo "  Status: EXISTS" >> "$investigation_log"
            
            # Syntax validation
            case "$file" in
                *.py)
                    if python -m py_compile "$file" 2>/dev/null; then
                        corruption_severity["$file"]=1  # Minor
                        echo "  Syntax: VALID (corruption level: MINOR)" >> "$investigation_log"
                    else
                        corruption_severity["$file"]=3  # Severe
                        echo "  Syntax: INVALID (corruption level: SEVERE)" >> "$investigation_log"
                    fi
                    ;;
                *.json)
                    if jq empty "$file" 2>/dev/null; then
                        corruption_severity["$file"]=1  # Minor
                        echo "  Syntax: VALID (corruption level: MINOR)" >> "$investigation_log"
                    else
                        corruption_severity["$file"]=3  # Severe  
                        echo "  Syntax: INVALID (corruption level: SEVERE)" >> "$investigation_log"
                    fi
                    ;;
                *)
                    corruption_severity["$file"]=2  # Moderate
                    echo "  Status: UNKNOWN (corruption level: MODERATE)" >> "$investigation_log"
                    ;;
            esac
        else
            corruption_severity["$file"]=4  # Critical - missing
            echo "  Status: MISSING (corruption level: CRITICAL)" >> "$investigation_log"
        fi
        echo "" >> "$investigation_log"
    done
    
    # Recovery priority order
    echo "--- RECOVERY PRIORITY ORDER ---" >> "$investigation_log"
    echo "Based on forensics evidence, recover in this order:" >> "$investigation_log"
    
    # Sort by corruption severity (highest first)
    for file in "${critical_files[@]}"; do
        echo "${corruption_severity[$file]}|$file"
    done | sort -nr | while IFS='|' read -r severity file; do
        case $severity in
            4) echo "1. IMMEDIATE: $file (MISSING - critical system component)" >> "$investigation_log" ;;
            3) echo "2. HIGH: $file (SEVERE corruption - system breaking)" >> "$investigation_log" ;;
            2) echo "3. MEDIUM: $file (MODERATE corruption - functionality impacted)" >> "$investigation_log" ;;
            1) echo "4. LOW: $file (MINOR corruption - system functional)" >> "$investigation_log" ;;
        esac
    done
    echo "" >> "$investigation_log"
    
    # Recommended recovery commits
    echo "--- RECOMMENDED RECOVERY COMMITS ---" >> "$investigation_log"
    echo "Based on forensics analysis, these commits contain known good versions:" >> "$investigation_log"
    
    # Find last known good commit for each critical file
    for file in "${critical_files[@]}"; do
        echo "Last known good commits for $file:" >> "$investigation_log"
        
        # Get recent commits that modified this file
        git log --pretty=format:"%h|%ad|%s" --date=short -10 -- "$file" | while IFS='|' read -r commit date subject; do
            # Check if this version would be valid
            if git show ${commit}:${file} >/dev/null 2>&1; then
                case "$file" in
                    *.py)
                        if git show ${commit}:${file} | python -m py_compile - 2>/dev/null; then
                            echo "  ✅ $commit ($date): $subject" >> "$investigation_log"
                            break
                        fi
                        ;;
                    *.json)
                        if git show ${commit}:${file} | jq empty 2>/dev/null; then
                            echo "  ✅ $commit ($date): $subject" >> "$investigation_log"
                            break
                        fi
                        ;;
                    *)
                        echo "  ⚠️  $commit ($date): $subject (validation needed)" >> "$investigation_log"
                        break
                        ;;
                esac
            fi
        done
        echo "" >> "$investigation_log"
    done
}
```

**STEP 2: FORENSICS AUDIT TRAIL**

```bash
# Function to create audit trail of forensics investigation
create_forensics_audit_trail() {
    local investigation_log=$1
    
    echo "=== FORENSICS INVESTIGATION AUDIT TRAIL ===" >> "$investigation_log"
    echo "Investigation completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Summary of findings
    echo "--- INVESTIGATION SUMMARY ---" >> "$investigation_log"
    echo "Repository Status: $(git fsck --quiet && echo "HEALTHY" || echo "CORRUPTED")" >> "$investigation_log"
    echo "Total Commits Analyzed: $(git rev-list --all --count)" >> "$investigation_log"
    echo "Branches Examined: $(git branch -a | wc -l)" >> "$investigation_log"
    echo "Critical Files Assessed: $(echo "${critical_files[@]}" | wc -w)" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Key findings
    echo "--- KEY FINDINGS ---" >> "$investigation_log"
    echo "Corruption Source: [TO BE DETERMINED FROM ANALYSIS]" >> "$investigation_log"
    echo "Last Known Good State: [TO BE DETERMINED FROM BISECT]" >> "$investigation_log"
    echo "Recovery Complexity: [TO BE ASSESSED]" >> "$investigation_log"
    echo "Data Loss Risk: [TO BE EVALUATED]" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Recommendations
    echo "--- FORENSICS RECOMMENDATIONS ---" >> "$investigation_log"
    echo "1. Implement regular backup strategy to prevent future data loss" >> "$investigation_log"
    echo "2. Add pre-commit hooks for syntax validation" >> "$investigation_log"
    echo "3. Implement branch protection rules for critical branches" >> "$investigation_log"
    echo "4. Add automated testing to catch corruption early" >> "$investigation_log"
    echo "5. Document recovery procedures for team reference" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    # Next steps
    echo "--- RECOMMENDED NEXT STEPS ---" >> "$investigation_log"
    echo "1. Use git-emergency-data-recovery.md protocol for actual recovery" >> "$investigation_log"
    echo "2. Apply git-exhaustive-file-analysis.md for detailed file comparison" >> "$investigation_log"
    echo "3. Implement surgical recovery based on forensics findings" >> "$investigation_log"
    echo "4. Validate recovery at each step using rollback points" >> "$investigation_log"
    echo "5. Document lessons learned for future prevention" >> "$investigation_log"
    echo "" >> "$investigation_log"
    
    echo "✅ FORENSICS INVESTIGATION COMPLETE: $investigation_log"
}
```

---

## FORENSICS INVESTIGATION EXECUTION SEQUENCE

### COMPLETE INVESTIGATION WORKFLOW

**To execute full forensics investigation:**

```bash
# Step 1: Establish baseline and collect evidence
investigation_log=$(establish_forensics_baseline)

# Step 2: Reconstruct timeline
reconstruct_change_timeline "$investigation_log"

# Step 3: Analyze patterns
analyze_author_patterns "$investigation_log"

# Step 4: Map dependencies for critical files
map_file_dependencies "$investigation_log" "api-gateway-service/app/main.py"
map_file_dependencies "$investigation_log" "mcp-config-local.json"
map_file_dependencies "$investigation_log" "docker-compose.yml"

# Step 5: Analyze critical paths
analyze_critical_paths "$investigation_log"

# Step 6: Identify corruption source (if specific commit suspected)
# commit_content_forensics "$investigation_log" "suspicious-commit-hash"

# Step 7: Binary search for corruption point (if good/bad commits known)
# binary_search_corruption "$investigation_log" "good-commit" "bad-commit" "test-command"

# Step 8: Create recovery strategy
create_forensics_recovery_strategy "$investigation_log"

# Step 9: Finalize audit trail
create_forensics_audit_trail "$investigation_log"

echo "🔍 FORENSICS INVESTIGATION COMPLETE"
echo "📋 Investigation Report: $investigation_log"
echo "🚨 Proceed with recovery using evidence-based strategy"
```

---

**ENFORCEMENT:** This forensics investigation protocol MUST be completed before any recovery operations to ensure scientific, evidence-based recovery decisions and prevent additional data loss.