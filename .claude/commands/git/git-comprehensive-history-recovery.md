# Git History Recovery Protocol

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:

1. Analyze both local and remote git history for recovery sources
2. Plan your approach to access ALL available git data sources
3. Consider the implications of local vs remote state differences
4. Only then proceed with the history recovery

**This thinking requirement is MANDATORY and must be followed for every recovery action.**

---

## ⚠️ LOCAL AND REMOTE GIT HISTORY RECOVERY ⚠️

### CANONICAL RECOVERY DIRECTIVE

**THIS PROTOCOL PROVIDES COMPLETE GIT HISTORY ACCESS:**

- **MUST** search ALL local git history including reflog, stash, and orphaned commits
- **MUST** search ALL remote origins, forks, and upstream repositories  
- **SHALL** recover from local filesystem git database directly when needed
- **MUST** access remote repository branches, tags, and pull requests for recovery
- **SHALL** search ALL GitHub/GitLab forks and related repositories
- **MUST** use git garbage collection recovery techniques for deleted content

---

## PHASE 1: LOCAL GIT HISTORY MINING

### EXHAUSTIVE LOCAL REPOSITORY ANALYSIS

**STEP 1: COMPLETE LOCAL GIT DATABASE MINING**

```bash
# Function to mine complete local git database
mine_complete_local_git_history() {
    local recovery_log="comprehensive_local_history_$(date +%Y%m%d_%H%M%S).log"
    
    echo "=== LOCAL GIT HISTORY MINING ===" > "$recovery_log"
    echo "Mining Start: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$recovery_log"
    echo "Repository Path: $(pwd)" >> "$recovery_log"
    echo "Git Directory: $(git rev-parse --git-dir)" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Git database integrity and size
    echo "=== GIT DATABASE ANALYSIS ===" >> "$recovery_log"
    echo "Git directory size: $(du -sh .git 2>/dev/null || echo 'UNKNOWN')" >> "$recovery_log"
    echo "Object count: $(find .git/objects -type f | wc -l)" >> "$recovery_log"
    echo "Packed objects: $(find .git/objects/pack -name "*.pack" | wc -l)" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # ALL local branches (including deleted ones from reflog)
    echo "=== ALL LOCAL BRANCHES (INCLUDING REFLOG HISTORY) ===" >> "$recovery_log"
    git branch -a --sort=-committerdate >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Complete reflog analysis (all refs)
    echo "=== COMPLETE REFLOG ANALYSIS ===" >> "$recovery_log"
    echo "--- HEAD reflog ---" >> "$recovery_log"
    git reflog --date=iso >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Reflog for all branches
    echo "--- ALL BRANCH REFLOGS ---" >> "$recovery_log"
    git branch | sed 's/^..//' | while read -r branch; do
        echo "Reflog for branch: $branch" >> "$recovery_log"
        git reflog --date=iso "$branch" >> "$recovery_log" 2>/dev/null || echo "NO_REFLOG_FOR_$branch" >> "$recovery_log"
        echo "" >> "$recovery_log"
    done
    
    # All stashes (including dropped stashes)
    echo "=== ALL STASHES (INCLUDING DROPPED) ===" >> "$recovery_log"
    git stash list >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Attempt to recover dropped stashes from reflog
    echo "--- DROPPED STASHES RECOVERY ---" >> "$recovery_log"
    git fsck --unreachable | grep 'commit' | cut -d' ' -f3 | while read -r commit; do
        if git log --oneline -1 $commit 2>/dev/null | grep -q 'WIP on\|On.*:'; then
            echo "Found potential dropped stash: $commit" >> "$recovery_log"
            git log --oneline -1 $commit >> "$recovery_log" 2>/dev/null
        fi
    done
    echo "" >> "$recovery_log"
    
    # All tags (including deleted ones)
    echo "=== ALL TAGS (INCLUDING DELETED) ===" >> "$recovery_log"
    git tag --sort=-version:refname >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Dangling and unreachable objects
    echo "=== DANGLING AND UNREACHABLE OBJECTS ===" >> "$recovery_log"
    echo "Dangling commits (potential recovery sources):" >> "$recovery_log"
    git fsck --dangling | grep 'dangling commit' >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    echo "Unreachable commits (potential recovery sources):" >> "$recovery_log"
    git fsck --unreachable | grep 'unreachable commit' >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # All commits reachable from any ref
    echo "=== ALL REACHABLE COMMITS ===" >> "$recovery_log"
    echo "Total commits in repository: $(git rev-list --all --count)" >> "$recovery_log"
    echo "Unique commits: $(git rev-list --all | sort -u | wc -l)" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Recent commits across all refs
    echo "--- RECENT COMMITS ACROSS ALL REFS ---" >> "$recovery_log"
    git rev-list --all --max-count=50 --pretty=format:"%h|%ad|%an|%s" --date=iso | grep "^[a-f0-9]" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    echo "✅ LOCAL GIT HISTORY MINING COMPLETE: $recovery_log"
    echo "$recovery_log"
}
```

**STEP 2: ORPHANED COMMIT RECOVERY**

```bash
# Function to recover orphaned and lost commits
recover_orphaned_commits() {
    local recovery_log=$1
    
    echo "=== ORPHANED COMMIT RECOVERY ===" >> "$recovery_log"
    
    # Find all orphaned commits
    echo "--- IDENTIFYING ORPHANED COMMITS ---" >> "$recovery_log"
    git fsck --lost-found >> "$recovery_log" 2>&1
    
    # Analyze each orphaned commit
    echo "--- ANALYZING ORPHANED COMMITS ---" >> "$recovery_log"
    git fsck --unreachable | grep 'commit' | cut -d' ' -f3 | while read -r orphan_commit; do
        echo "ORPHANED COMMIT: $orphan_commit" >> "$recovery_log"
        
        # Get commit details
        if git cat-file -t $orphan_commit 2>/dev/null | grep -q 'commit'; then
            echo "  Author: $(git show --no-patch --format="%an <%ae>" $orphan_commit 2>/dev/null)" >> "$recovery_log"
            echo "  Date: $(git show --no-patch --format="%ad" --date=iso $orphan_commit 2>/dev/null)" >> "$recovery_log"
            echo "  Subject: $(git show --no-patch --format="%s" $orphan_commit 2>/dev/null)" >> "$recovery_log"
            
            # Files changed in orphaned commit
            echo "  Files changed:" >> "$recovery_log"
            git diff-tree --no-commit-id --name-status -r $orphan_commit >> "$recovery_log" 2>/dev/null || echo "    NO_FILES_CHANGED" >> "$recovery_log"
            
            # Show full commit content
            echo "  --- COMPLETE COMMIT CONTENT ---" >> "$recovery_log"
            git show $orphan_commit >> "$recovery_log" 2>/dev/null || echo "    COMMIT_READ_ERROR" >> "$recovery_log"
            echo "" >> "$recovery_log"
        fi
    done
    
    # Create recovery branches for valuable orphaned commits
    echo "--- CREATING RECOVERY BRANCHES FOR ORPHANED COMMITS ---" >> "$recovery_log"
    git fsck --unreachable | grep 'commit' | head -10 | cut -d' ' -f3 | while read -r orphan_commit; do
        recovery_branch="orphan-recovery-$(date +%Y%m%d_%H%M%S)-${orphan_commit:0:8}"
        echo "Creating recovery branch: $recovery_branch for commit $orphan_commit" >> "$recovery_log"
        
        git branch "$recovery_branch" $orphan_commit 2>/dev/null && echo "  ✅ Branch created successfully" >> "$recovery_log" || echo "  ❌ Branch creation failed" >> "$recovery_log"
    done
    echo "" >> "$recovery_log"
}
```

**STEP 3: REFLOG ARCHAEOLOGY**

```bash
# Function to perform deep reflog archaeology
perform_reflog_archaeology() {
    local recovery_log=$1
    
    echo "=== REFLOG ARCHAEOLOGY ===" >> "$recovery_log"
    
    # Extended reflog analysis beyond default expire time
    echo "--- EXTENDED REFLOG ANALYSIS ---" >> "$recovery_log"
    
    # Check reflog configuration
    echo "Reflog expire configuration:" >> "$recovery_log"
    git config --get gc.reflogExpire >> "$recovery_log" || echo "DEFAULT (90 days)" >> "$recovery_log"
    git config --get gc.reflogExpireUnreachable >> "$recovery_log" || echo "DEFAULT (30 days)" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # reflog for ALL refs
    echo "--- REFLOG FOR ALL REFS ---" >> "$recovery_log"
    find .git/logs -type f | while read -r reflog_file; do
        ref_name=$(echo "$reflog_file" | sed 's|.git/logs/||')
        echo "=== REFLOG: $ref_name ===" >> "$recovery_log"
        
        if [ -f "$reflog_file" ]; then
            # Parse reflog entries manually for complete history
            while IFS= read -r reflog_line; do
                if [[ -n "$reflog_line" ]]; then
                    # Extract commit hash, author, timestamp, action
                    old_sha=$(echo "$reflog_line" | cut -d' ' -f1)
                    new_sha=$(echo "$reflog_line" | cut -d' ' -f2)
                    author_info=$(echo "$reflog_line" | cut -d' ' -f3-4)
                    action=$(echo "$reflog_line" | cut -d$'\t' -f2 2>/dev/null || echo "NO_ACTION")
                    
                    echo "  $new_sha ($author_info): $action" >> "$recovery_log"
                    
                    # Check if this commit still exists and get details
                    if git cat-file -e $new_sha 2>/dev/null; then
                        commit_date=$(git show --no-patch --format="%ad" --date=iso $new_sha 2>/dev/null)
                        commit_subject=$(git show --no-patch --format="%s" $new_sha 2>/dev/null)
                        echo "    Date: $commit_date" >> "$recovery_log"
                        echo "    Subject: $commit_subject" >> "$recovery_log"
                    else
                        echo "    COMMIT_NO_LONGER_EXISTS" >> "$recovery_log"
                    fi
                fi
            done < "$reflog_file"
        else
            echo "  REFLOG_FILE_NOT_FOUND" >> "$recovery_log"
        fi
        echo "" >> "$recovery_log"
    done
    
    # Find commits that existed but are now unreachable
    echo "--- COMMITS LOST FROM REFLOG ---" >> "$recovery_log"
    find .git/logs -type f -exec cat {} \; | cut -d' ' -f2 | sort -u | while read -r commit_sha; do
        if [[ -n "$commit_sha" && "$commit_sha" =~ ^[a-f0-9]+$ ]]; then
            # Check if commit exists but is unreachable
            if git cat-file -e $commit_sha 2>/dev/null; then
                if ! git merge-base --is-ancestor $commit_sha HEAD 2>/dev/null && ! git branch --contains $commit_sha 2>/dev/null | grep -q .; then
                    echo "UNREACHABLE COMMIT FROM REFLOG: $commit_sha" >> "$recovery_log"
                    git show --no-patch --format="  %ad %an: %s" --date=short $commit_sha >> "$recovery_log" 2>/dev/null
                fi
            fi
        fi
    done
    echo "" >> "$recovery_log"
}
```

---

## PHASE 2: REMOTE REPOSITORY MINING

### EXHAUSTIVE REMOTE HISTORY ACCESS

**STEP 1: COMPLETE REMOTE REPOSITORY ANALYSIS**

```bash
# Function to analyze all remote repositories and origins
analyze_all_remote_repositories() {
    local recovery_log=$1
    
    echo "=== REMOTE REPOSITORY ANALYSIS ===" >> "$recovery_log"
    
    # List all configured remotes
    echo "--- ALL CONFIGURED REMOTES ---" >> "$recovery_log"
    git remote -v >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # For each remote, get complete information
    git remote | while read -r remote_name; do
        echo "=== REMOTE: $remote_name ===" >> "$recovery_log"
        
        remote_url=$(git remote get-url $remote_name)
        echo "URL: $remote_url" >> "$recovery_log"
        
        # Fetch latest information from remote
        echo "Fetching latest remote information..." >> "$recovery_log"
        git fetch $remote_name --prune >> "$recovery_log" 2>&1 || echo "FETCH_FAILED" >> "$recovery_log"
        
        # All remote branches
        echo "--- ALL REMOTE BRANCHES ---" >> "$recovery_log"
        git branch -r | grep "^  $remote_name/" | sort >> "$recovery_log"
        echo "" >> "$recovery_log"
        
        # All remote tags
        echo "--- ALL REMOTE TAGS ---" >> "$recovery_log"
        git ls-remote --tags $remote_name >> "$recovery_log" 2>/dev/null || echo "REMOTE_TAGS_FETCH_FAILED" >> "$recovery_log"
        echo "" >> "$recovery_log"
        
        # Remote HEAD and default branch
        echo "--- REMOTE HEAD INFORMATION ---" >> "$recovery_log"
        git ls-remote --symref $remote_name HEAD >> "$recovery_log" 2>/dev/null || echo "REMOTE_HEAD_FETCH_FAILED" >> "$recovery_log"
        echo "" >> "$recovery_log"
        
        # Recent commits on remote branches
        echo "--- RECENT COMMITS ON REMOTE BRANCHES ---" >> "$recovery_log"
        git branch -r | grep "^  $remote_name/" | sed "s/^  //" | head -10 | while read -r remote_branch; do
            echo "Recent commits on $remote_branch:" >> "$recovery_log"
            git log --oneline -5 $remote_branch >> "$recovery_log" 2>/dev/null || echo "  BRANCH_ACCESS_FAILED" >> "$recovery_log"
            echo "" >> "$recovery_log"
        done
    done
    
    # Check for additional remotes that might exist (upstream, forks)
    echo "=== POTENTIAL ADDITIONAL REMOTES ===" >> "$recovery_log"
    
    # If this is a GitHub repository, check for common patterns
    git remote get-url origin 2>/dev/null | if grep -q "github.com"; then
        origin_url=$(git remote get-url origin 2>/dev/null)
        echo "Detected GitHub repository: $origin_url" >> "$recovery_log"
        
        # Extract repository information
        if [[ "$origin_url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
            github_user="${BASH_REMATCH[1]}"
            github_repo="${BASH_REMATCH[2]}"
            
            echo "GitHub User: $github_user" >> "$recovery_log"
            echo "GitHub Repo: $github_repo" >> "$recovery_log"
            
            # Check for upstream remote
            if ! git remote | grep -q upstream; then
                echo "POTENTIAL UPSTREAM: Consider adding upstream remote if this is a fork" >> "$recovery_log"
            fi
        fi
    fi
    echo "" >> "$recovery_log"
}
```

**STEP 2: REMOTE BRANCH EXHAUSTIVE MINING**

```bash
# Function to exhaustively mine all remote branches
mine_all_remote_branches() {
    local recovery_log=$1
    
    echo "=== EXHAUSTIVE REMOTE BRANCH MINING ===" >> "$recovery_log"
    
    # Get all remote branches across all remotes
    git branch -r | sed 's/^..//' | while read -r remote_branch; do
        if [[ "$remote_branch" != *"->"* ]]; then  # Skip symbolic refs
            echo "=== MINING REMOTE BRANCH: $remote_branch ===" >> "$recovery_log"
            
            # Branch information
            echo "Branch: $remote_branch" >> "$recovery_log"
            echo "Latest commit: $(git rev-parse $remote_branch 2>/dev/null)" >> "$recovery_log"
            echo "Latest author: $(git show --no-patch --format="%an <%ae>" $remote_branch 2>/dev/null)" >> "$recovery_log"
            echo "Latest date: $(git show --no-patch --format="%ad" --date=iso $remote_branch 2>/dev/null)" >> "$recovery_log"
            echo "Latest subject: $(git show --no-patch --format="%s" $remote_branch 2>/dev/null)" >> "$recovery_log"
            echo "" >> "$recovery_log"
            
            # Complete commit history for this branch
            echo "--- COMPLETE COMMIT HISTORY ---" >> "$recovery_log"
            git log --oneline --max-count=20 $remote_branch >> "$recovery_log" 2>/dev/null || echo "BRANCH_LOG_FAILED" >> "$recovery_log"
            echo "" >> "$recovery_log"
            
            # Files in this branch (current state)
            echo "--- FILES IN BRANCH ---" >> "$recovery_log"
            git ls-tree -r --name-only $remote_branch >> "$recovery_log" 2>/dev/null || echo "BRANCH_TREE_FAILED" >> "$recovery_log"
            echo "" >> "$recovery_log"
            
            # Check for critical files in this branch
            declare -a critical_files=(
                "api-gateway-service/app/main.py"
                "mcp-config-local.json"
                "docker-compose.yml"
                "package.json"
                "requirements.txt"
                "Makefile"
            )
            
            echo "--- CRITICAL FILES ANALYSIS ---" >> "$recovery_log"
            for critical_file in "${critical_files[@]}"; do
                if git cat-file -e ${remote_branch}:${critical_file} 2>/dev/null; then
                    echo "✅ $critical_file EXISTS in $remote_branch" >> "$recovery_log"
                    
                    # File size and last modified
                    file_size=$(git cat-file -s ${remote_branch}:${critical_file} 2>/dev/null || echo 0)
                    echo "  Size: $file_size bytes" >> "$recovery_log"
                    
                    # Last commit that modified this file
                    last_commit=$(git log -1 --format="%h|%ad|%s" --date=short $remote_branch -- $critical_file 2>/dev/null)
                    echo "  Last modified: $last_commit" >> "$recovery_log"
                    
                    # Syntax validation if possible
                    case "$critical_file" in
                        *.py)
                            if git show ${remote_branch}:${critical_file} | python -m py_compile - 2>/dev/null; then
                                echo "  Python syntax: VALID" >> "$recovery_log"
                            else
                                echo "  Python syntax: INVALID" >> "$recovery_log"
                            fi
                            ;;
                        *.json)
                            if git show ${remote_branch}:${critical_file} | jq empty 2>/dev/null; then
                                echo "  JSON syntax: VALID" >> "$recovery_log"
                            else
                                echo "  JSON syntax: INVALID" >> "$recovery_log"
                            fi
                            ;;
                        *.yml|*.yaml)
                            # Basic YAML validation if python available
                            if command -v python >/dev/null 2>&1; then
                                if git show ${remote_branch}:${critical_file} | python -c "import yaml, sys; yaml.safe_load(sys.stdin)" 2>/dev/null; then
                                    echo "  YAML syntax: VALID" >> "$recovery_log"
                                else
                                    echo "  YAML syntax: INVALID" >> "$recovery_log"
                                fi
                            fi
                            ;;
                    esac
                else
                    echo "❌ $critical_file MISSING in $remote_branch" >> "$recovery_log"
                fi
            done
            echo "" >> "$recovery_log"
            
            # Create local tracking branch if it doesn't exist
            local_branch_name=$(echo "$remote_branch" | sed 's|.*/||')
            if ! git branch | grep -q " $local_branch_name$"; then
                echo "Creating local tracking branch: $local_branch_name" >> "$recovery_log"
                git branch --track "$local_branch_name" "$remote_branch" >> "$recovery_log" 2>&1 || echo "TRACKING_BRANCH_CREATION_FAILED" >> "$recovery_log"
            fi
            
            echo "========================================" >> "$recovery_log"
            echo "" >> "$recovery_log"
        fi
    done
}
```

**STEP 3: GITHUB/GITLAB FORK AND PR MINING**

```bash
# Function to mine GitHub/GitLab forks and pull requests
mine_github_forks_and_prs() {
    local recovery_log=$1
    
    echo "=== GITHUB/GITLAB FORK AND PR MINING ===" >> "$recovery_log"
    
    # Check if this is a GitHub/GitLab repository
    origin_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    if [[ "$origin_url" =~ github\.com ]]; then
        echo "--- GITHUB REPOSITORY DETECTED ---" >> "$recovery_log"
        echo "Origin URL: $origin_url" >> "$recovery_log"
        
        # Extract repository information
        if [[ "$origin_url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
            github_user="${BASH_REMATCH[1]}"
            github_repo="${BASH_REMATCH[2]}"
            
            echo "GitHub User: $github_user" >> "$recovery_log"
            echo "GitHub Repository: $github_repo" >> "$recovery_log"
            echo "" >> "$recovery_log"
            
            # Use GitHub CLI if available
            if command -v gh >/dev/null 2>&1; then
                echo "--- GITHUB CLI AVAILABLE - ENHANCED MINING ---" >> "$recovery_log"
                
                # List all forks
                echo "All forks of this repository:" >> "$recovery_log"
                gh repo list --fork --limit 50 >> "$recovery_log" 2>/dev/null || echo "FORK_LISTING_FAILED" >> "$recovery_log"
                echo "" >> "$recovery_log"
                
                # List all pull requests (including closed ones)
                echo "All pull requests (open and closed):" >> "$recovery_log"
                gh pr list --state all --limit 100 >> "$recovery_log" 2>/dev/null || echo "PR_LISTING_FAILED" >> "$recovery_log"
                echo "" >> "$recovery_log"
                
                # Recent releases and tags
                echo "Recent releases:" >> "$recovery_log"
                gh release list --limit 20 >> "$recovery_log" 2>/dev/null || echo "RELEASE_LISTING_FAILED" >> "$recovery_log"
                echo "" >> "$recovery_log"
                
            else
                echo "--- GITHUB CLI NOT AVAILABLE - BASIC MINING ---" >> "$recovery_log"
                echo "Install 'gh' CLI for enhanced GitHub repository mining" >> "$recovery_log"
                echo "" >> "$recovery_log"
            fi
            
            # Manual fork detection using git
            echo "--- MANUAL FORK DETECTION ---" >> "$recovery_log"
            echo "Potential fork remotes to investigate:" >> "$recovery_log"
            echo "  - upstream (if this is a fork)" >> "$recovery_log"
            echo "  - Other contributors' forks" >> "$recovery_log"
            echo "" >> "$recovery_log"
        fi
        
    elif [[ "$origin_url" =~ gitlab\. ]]; then
        echo "--- GITLAB REPOSITORY DETECTED ---" >> "$recovery_log"
        echo "Origin URL: $origin_url" >> "$recovery_log"
        
        # GitLab-specific mining would go here
        echo "GitLab repository mining - manual investigation required" >> "$recovery_log"
        echo "" >> "$recovery_log"
        
    else
        echo "--- NON-GITHUB/GITLAB REPOSITORY ---" >> "$recovery_log"
        echo "Origin URL: $origin_url" >> "$recovery_log"
        echo "Manual investigation required for additional remotes" >> "$recovery_log"
        echo "" >> "$recovery_log"
    fi
}
```

---

## PHASE 3: RECOVERY SOURCE PRIORITIZATION

### UNIFIED LOCAL AND REMOTE RECOVERY STRATEGY

**STEP 1: RECOVERY SOURCE SCORING**

```bash
# Function to score all recovery sources (local and remote)
score_all_recovery_sources() {
    local recovery_log=$1
    
    echo "=== RECOVERY SOURCE SCORING ===" >> "$recovery_log"
    
    declare -A recovery_scores
    declare -a all_sources
    
    # Score local branches
    echo "--- SCORING LOCAL BRANCHES ---" >> "$recovery_log"
    git branch | sed 's/^..//' | while read -r local_branch; do
        if [[ "$local_branch" != "HEAD" ]]; then
            echo "Scoring local branch: $local_branch" >> "$recovery_log"
            
            local score=0
            
            # Recency score
            days_old=$(git log -1 --format="%ad" --date=format:"%s" $local_branch | xargs -I{} bash -c 'echo $(( ($(date +%s) - {}) / 86400 ))')
            if [[ $days_old -lt 1 ]]; then
                score=$((score + 10))
                echo "  +10: Very recent (< 1 day)" >> "$recovery_log"
            elif [[ $days_old -lt 7 ]]; then
                score=$((score + 5))
                echo "  +5: Recent (< 1 week)" >> "$recovery_log"
            elif [[ $days_old -lt 30 ]]; then
                score=$((score + 2))
                echo "  +2: Moderately recent (< 1 month)" >> "$recovery_log"
            fi
            
            # Critical file presence and validity
            declare -a critical_files=("api-gateway-service/app/main.py" "mcp-config-local.json" "docker-compose.yml")
            for critical_file in "${critical_files[@]}"; do
                if git cat-file -e ${local_branch}:${critical_file} 2>/dev/null; then
                    score=$((score + 5))
                    echo "  +5: Has $critical_file" >> "$recovery_log"
                    
                    # Syntax validation bonus
                    case "$critical_file" in
                        *.py)
                            if git show ${local_branch}:${critical_file} | python -m py_compile - 2>/dev/null; then
                                score=$((score + 3))
                                echo "    +3: Valid Python syntax" >> "$recovery_log"
                            fi
                            ;;
                        *.json)
                            if git show ${local_branch}:${critical_file} | jq empty 2>/dev/null; then
                                score=$((score + 3))
                                echo "    +3: Valid JSON syntax" >> "$recovery_log"
                            fi
                            ;;
                    esac
                fi
            done
            
            # Commit count (indicates development activity)
            commit_count=$(git rev-list --count $local_branch)
            if [[ $commit_count -gt 100 ]]; then
                score=$((score + 3))
                echo "  +3: High commit count ($commit_count)" >> "$recovery_log"
            elif [[ $commit_count -gt 50 ]]; then
                score=$((score + 1))
                echo "  +1: Moderate commit count ($commit_count)" >> "$recovery_log"
            fi
            
            echo "  TOTAL SCORE: $score" >> "$recovery_log"
            recovery_scores["local:$local_branch"]=$score
            all_sources+=("local:$local_branch")
            echo "" >> "$recovery_log"
        fi
    done
    
    # Score remote branches
    echo "--- SCORING REMOTE BRANCHES ---" >> "$recovery_log"
    git branch -r | sed 's/^..//' | while read -r remote_branch; do
        if [[ "$remote_branch" != *"->"* ]]; then
            echo "Scoring remote branch: $remote_branch" >> "$recovery_log"
            
            local score=0
            
            # Remote branches get base credibility score
            score=$((score + 15))
            echo "  +15: Remote branch (higher credibility)" >> "$recovery_log"
            
            # Same scoring criteria as local branches
            days_old=$(git log -1 --format="%ad" --date=format:"%s" $remote_branch 2>/dev/null | xargs -I{} bash -c 'echo $(( ($(date +%s) - {}) / 86400 ))' 2>/dev/null || echo 999)
            if [[ $days_old -lt 1 ]]; then
                score=$((score + 10))
                echo "  +10: Very recent (< 1 day)" >> "$recovery_log"
            elif [[ $days_old -lt 7 ]]; then
                score=$((score + 5))
                echo "  +5: Recent (< 1 week)" >> "$recovery_log"
            elif [[ $days_old -lt 30 ]]; then
                score=$((score + 2))
                echo "  +2: Moderately recent (< 1 month)" >> "$recovery_log"
            fi
            
            # Critical file analysis (same as local)
            declare -a critical_files=("api-gateway-service/app/main.py" "mcp-config-local.json" "docker-compose.yml")
            for critical_file in "${critical_files[@]}"; do
                if git cat-file -e ${remote_branch}:${critical_file} 2>/dev/null; then
                    score=$((score + 5))
                    echo "  +5: Has $critical_file" >> "$recovery_log"
                    
                    case "$critical_file" in
                        *.py)
                            if git show ${remote_branch}:${critical_file} | python -m py_compile - 2>/dev/null; then
                                score=$((score + 3))
                                echo "    +3: Valid Python syntax" >> "$recovery_log"
                            fi
                            ;;
                        *.json)
                            if git show ${remote_branch}:${critical_file} | jq empty 2>/dev/null; then
                                score=$((score + 3))
                                echo "    +3: Valid JSON syntax" >> "$recovery_log"
                            fi
                            ;;
                    esac
                fi
            done
            
            echo "  TOTAL SCORE: $score" >> "$recovery_log"
            recovery_scores["remote:$remote_branch"]=$score
            all_sources+=("remote:$remote_branch")
            echo "" >> "$recovery_log"
        fi
    done
    
    # Score orphaned commits
    echo "--- SCORING ORPHANED COMMITS ---" >> "$recovery_log"
    git fsck --unreachable | grep 'commit' | head -5 | cut -d' ' -f3 | while read -r orphan_commit; do
        echo "Scoring orphaned commit: $orphan_commit" >> "$recovery_log"
        
        local score=5  # Base score for orphaned commits
        echo "  +5: Orphaned commit (potential unique content)" >> "$recovery_log"
        
        # Check if it has critical files
        files_changed=$(git diff-tree --no-commit-id --name-only -r $orphan_commit 2>/dev/null | wc -l)
        if [[ $files_changed -gt 0 ]]; then
            score=$((score + files_changed))
            echo "  +$files_changed: Files changed" >> "$recovery_log"
        fi
        
        echo "  TOTAL SCORE: $score" >> "$recovery_log"
        recovery_scores["orphan:$orphan_commit"]=$score
        all_sources+=("orphan:$orphan_commit")
        echo "" >> "$recovery_log"
    done
    
    # Final recommendations
    echo "=== FINAL RECOVERY RECOMMENDATIONS ===" >> "$recovery_log"
    echo "Recovery sources ranked by score (highest first):" >> "$recovery_log"
    
    # Sort all sources by score
    for source in "${all_sources[@]}"; do
        echo "${recovery_scores[$source]}|$source"
    done | sort -nr | head -10 | while IFS='|' read -r score source; do
        echo "  Score $score: $source" >> "$recovery_log"
    done
    echo "" >> "$recovery_log"
}
```

**STEP 2: MULTI-SOURCE RECOVERY EXECUTION PLAN**

```bash
# Function to create execution plan using all recovery sources
create_multi_source_recovery_plan() {
    local recovery_log=$1
    
    echo "=== MULTI-SOURCE RECOVERY EXECUTION PLAN ===" >> "$recovery_log"
    
    # Phase 1: High-priority remote sources
    echo "--- PHASE 1: HIGH-PRIORITY REMOTE SOURCES ---" >> "$recovery_log"
    echo "1. Fetch all remotes to ensure latest data:" >> "$recovery_log"
    echo "   git fetch --all --prune" >> "$recovery_log"
    echo "   git fetch --all --tags" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    echo "2. Check remote branches with highest scores:" >> "$recovery_log"
    git branch -r | sed 's/^..//' | head -5 | while read -r remote_branch; do 
        if [[ "$remote_branch" != *"->"* ]]; then
            echo "   - Analyze: $remote_branch" >> "$recovery_log"
            echo "     git show $remote_branch:api-gateway-service/app/main.py" >> "$recovery_log"
            echo "     git show $remote_branch:mcp-config-local.json" >> "$recovery_log"
        fi
    done
    echo "" >> "$recovery_log"
    
    # Phase 2: Local sources with unique content
    echo "--- PHASE 2: LOCAL SOURCES WITH UNIQUE CONTENT ---" >> "$recovery_log"  
    echo "1. Check local branches not synced with remote:" >> "$recovery_log"
    git branch | sed 's/^..//' | while read -r local_branch; do
        # Check if branch has upstream
        if ! git branch -vv | grep "$local_branch" | grep -q '\[.*\]'; then
            echo "   - Analyze local-only branch: $local_branch" >> "$recovery_log"
        fi
    done
    echo "" >> "$recovery_log"
    
    echo "2. Check reflog for lost commits:" >> "$recovery_log"
    echo "   git reflog --all | head -20" >> "$recovery_log"
    echo "   # Manually investigate any interesting lost commits" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Phase 3: Orphaned commit recovery
    echo "--- PHASE 3: ORPHANED COMMIT RECOVERY ---" >> "$recovery_log"
    echo "1. Create recovery branches for orphaned commits:" >> "$recovery_log"
    git fsck --unreachable | grep 'commit' | head -3 | cut -d' ' -f3 | while read -r orphan_commit; do
        echo "   git branch orphan-recovery-${orphan_commit:0:8} $orphan_commit" >> "$recovery_log"
    done
    echo "" >> "$recovery_log"
    
    # Phase 4: Cross-source validation
    echo "--- PHASE 4: CROSS-SOURCE VALIDATION ---" >> "$recovery_log"
    echo "1. Compare file versions across all sources:" >> "$recovery_log"
    echo "   Use git-exhaustive-file-analysis.md for detailed comparison" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    echo "2. Validate syntax across all recovered versions:" >> "$recovery_log"
    echo "   python -m py_compile [recovered-python-files]" >> "$recovery_log"
    echo "   jq empty [recovered-json-files]" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    # Phase 5: Surgical recovery
    echo "--- PHASE 5: SURGICAL RECOVERY EXECUTION ---" >> "$recovery_log"
    echo "1. Use git-emergency-data-recovery.md protocol" >> "$recovery_log"
    echo "2. Apply best version of each critical file" >> "$recovery_log"
    echo "3. Create rollback points after each recovery step" >> "$recovery_log"
    echo "4. Validate system functionality after each component recovery" >> "$recovery_log"
    echo "" >> "$recovery_log"
    
    echo "✅ MULTI-SOURCE RECOVERY PLAN COMPLETE" >> "$recovery_log"
}
```

---

## RECOVERY EXECUTION SEQUENCE

### COMPLETE WORKFLOW FOR LOCAL AND REMOTE RECOVERY

**To execute local and remote recovery:**

```bash
# Step 1: Mine complete local git history
local_log=$(mine_complete_local_git_history)

# Step 2: Recover orphaned commits
recover_orphaned_commits "$local_log"

# Step 3: Perform reflog archaeology
perform_reflog_archaeology "$local_log"

# Step 4: Analyze all remote repositories
analyze_all_remote_repositories "$local_log"

# Step 5: Mine all remote branches exhaustively
mine_all_remote_branches "$local_log"

# Step 6: Mine GitHub/GitLab forks and PRs
mine_github_forks_and_prs "$local_log"

# Step 7: Score all recovery sources
score_all_recovery_sources "$local_log"

# Step 8: Create multi-source recovery plan
create_multi_source_recovery_plan "$local_log"

echo "🔍 LOCAL AND REMOTE ANALYSIS COMPLETE"
echo "📋 Analysis Report: $local_log"
echo "🚨 Execute recovery using multi-source strategy"
echo "📦 ALL local git history and remote origins analyzed"
```

---

**ENFORCEMENT:** This history recovery protocol MUST include ALL local git history (including reflog, stash, orphaned commits) AND ALL remote origins (including forks, PRs, and upstream repositories) to ensure no recoverable data is missed during emergency recovery operations.