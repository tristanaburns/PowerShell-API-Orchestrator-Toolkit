# Git Emergency Data Recovery Protocol

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:

1. Analyze the current broken state and understand what needs to be recovered
2. Plan your git forensics approach to identify known good states
3. Consider the implications of each recovery action
4. Only then proceed with the actual recovery execution

**This thinking requirement is MANDATORY and must be followed for every recovery action.**

---

## ⚠️ EMERGENCY DATA CORRUPTION AND RECOVERY PROTOCOL ⚠️

### CANONICAL EMERGENCY DIRECTIVE - ABSOLUTE ENFORCEMENT

**THIS IS A CANONICAL MANDATORY PROTOCOL DIRECTIVE:**

- **MUST** be followed at all times during data corruption events
- **MUST NOT** create, modify, or write ANY new code
- **MUST ONLY** recover existing known good code from git history
- **SHALL** prevent any additional data loss through systematic recovery
- **MUST** use git forensics to identify and restore working states
- **FORBIDDEN:** Any code cutting, modification, or new development

### RFC 2119 COMPLIANCE - EMERGENCY RECOVERY REQUIREMENTS

**EMERGENCY RECOVERY PRINCIPLES:**

- **MUST** assess current broken state before any recovery actions
- **MUST** identify known good working commits through git analysis
- **SHALL** recover files surgically from git history without modification  
- **MUST** validate each recovery step before proceeding
- **MUST NOT** lose any additional data during recovery process
- **SHALL** document all recovery actions for audit trail

---

## PHASE 1: EMERGENCY STATE ASSESSMENT

### MANDATORY INITIAL ASSESSMENT SEQUENCE

**STEP 1: DOCUMENT CURRENT BROKEN STATE**

```bash
echo "=== EMERGENCY RECOVERY SESSION ===" > .emergency_recovery_log
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> .emergency_recovery_log
echo "Instance: [Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)]" >> .emergency_recovery_log
echo "Current Branch: $(git branch --show-current)" >> .emergency_recovery_log
echo "Last Commit: $(git log -1 --format='%h - %s (%an, %ar)')" >> .emergency_recovery_log
echo "" >> .emergency_recovery_log

# Document what is currently broken
echo "=== BROKEN STATE ASSESSMENT ===" >> .emergency_recovery_log
echo "Symptoms:" >> .emergency_recovery_log
echo "- [User to specify: API endpoints failing]" >> .emergency_recovery_log  
echo "- [User to specify: Container build failures]" >> .emergency_recovery_log
echo "- [User to specify: Missing functionality]" >> .emergency_recovery_log
echo "- [User to specify: Framework module issues]" >> .emergency_recovery_log
echo "" >> .emergency_recovery_log
```

**STEP 2: IDENTIFY AFFECTED COMPONENTS**

```bash
# Test critical application components
echo "=== COMPONENT STATUS ASSESSMENT ===" >> .emergency_recovery_log

# Check API health (if applicable)
if command -v curl &> /dev/null; then
    echo "API Health Check:" >> .emergency_recovery_log
    curl -s http://localhost:8000/api/v1/health || echo "API_FAILED" >> .emergency_recovery_log
    echo "" >> .emergency_recovery_log
fi

# Check container status (if applicable)  
if command -v docker-compose &> /dev/null; then
    echo "Container Status:" >> .emergency_recovery_log
    docker-compose ps >> .emergency_recovery_log 2>&1
    echo "" >> .emergency_recovery_log
fi

# Check build status
echo "Build Status:" >> .emergency_recovery_log
if [ -f Makefile ]; then
    make --dry-run test >> .emergency_recovery_log 2>&1 || echo "MAKE_BUILD_FAILED" >> .emergency_recovery_log
elif [ -f package.json ]; then
    npm run --dry-run test >> .emergency_recovery_log 2>&1 || echo "NPM_BUILD_FAILED" >> .emergency_recovery_log
fi
echo "" >> .emergency_recovery_log
```

**STEP 3: GIT FORENSICS - RECENT BRANCH ANALYSIS**

```bash
echo "=== GIT FORENSICS ANALYSIS ===" >> .emergency_recovery_log

# List all recent branches
echo "Recent Branches:" >> .emergency_recovery_log
git branch -a --sort=-committerdate | head -20 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log

# Analyze last 10 commits on current branch
echo "Recent Commits on Current Branch:" >> .emergency_recovery_log
git log --oneline -10 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log

# Check for recent merge activities
echo "Recent Merge Activities:" >> .emergency_recovery_log
git log --merges --oneline -5 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log

# Identify branches that might contain known good code
echo "Branches to Investigate for Recovery:" >> .emergency_recovery_log
git branch -a --sort=-committerdate | grep -E "(backup|main|development)" | head -10 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log
```

---

## PHASE 2: KNOWN GOOD STATE IDENTIFICATION

### SYSTEMATIC BRANCH EVALUATION FOR RECOVERY

**STEP 1: BRANCH-BY-BRANCH ASSESSMENT**

```bash
# Function to assess a branch for known good code
assess_branch_for_recovery() {
    local branch_name=$1
    echo "=== ASSESSING BRANCH: $branch_name ===" >> .emergency_recovery_log
    
    # Checkout branch safely (stash current work first)
    git stash push -m "[Emergency-Recovery] Assessment stash $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    git checkout $branch_name
    
    # Check if key files exist and their status
    echo "Key Files Status in $branch_name:" >> .emergency_recovery_log
    
    # API Gateway files (adjust paths as needed)
    if [ -f "api-gateway-service/app/main.py" ]; then
        echo "✅ API Gateway main.py EXISTS" >> .emergency_recovery_log
        wc -l "api-gateway-service/app/main.py" >> .emergency_recovery_log
    else
        echo "❌ API Gateway main.py MISSING" >> .emergency_recovery_log
    fi
    
    # MCP Config files
    if [ -f "mcp-config-local.json" ]; then
        echo "✅ MCP Config EXISTS" >> .emergency_recovery_log
        jq -r '.mcpServers | keys | length' mcp-config-local.json >> .emergency_recovery_log 2>/dev/null || echo "JSON_PARSE_ERROR" >> .emergency_recovery_log
    else
        echo "❌ MCP Config MISSING" >> .emergency_recovery_log
    fi
    
    # Docker Compose files
    if [ -f "docker-compose.yml" ]; then
        echo "✅ Docker Compose EXISTS" >> .emergency_recovery_log
        grep -c "services:" docker-compose.yml >> .emergency_recovery_log
    else
        echo "❌ Docker Compose MISSING" >> .emergency_recovery_log
    fi
    
    # Quick build test (dry run only)
    echo "Build Test for $branch_name:" >> .emergency_recovery_log
    if [ -f Makefile ]; then
        make --dry-run build >> .emergency_recovery_log 2>&1 || echo "BUILD_TEST_FAILED" >> .emergency_recovery_log
    fi
    
    echo "Branch $branch_name assessment complete" >> .emergency_recovery_log
    echo "" >> .emergency_recovery_log
}

# Assess top candidate branches for recovery
RECOVERY_CANDIDATES=(
    "development"
    "main" 
    "feature/$(date +%Y-%m-%d -d '1 day ago')*"
    "fix/$(date +%Y-%m-%d -d '1 day ago')*"
)

for branch in "${RECOVERY_CANDIDATES[@]}"; do
    if git show-ref --verify --quiet refs/heads/$branch || git show-ref --verify --quiet refs/remotes/origin/$branch; then
        assess_branch_for_recovery $branch
    fi
done
```

**STEP 2: COMMIT-LEVEL ANALYSIS FOR KNOWN GOOD STATES**

```bash
echo "=== COMMIT-LEVEL FORENSICS ===" >> .emergency_recovery_log

# Find commits that mention working states or successful builds
echo "Commits mentioning working states:" >> .emergency_recovery_log
git log --all --grep="working" --grep="success" --grep="fix" --oneline | head -10 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log

# Find commits from recent successful sessions
echo "Recent commits with Claude Code signatures:" >> .emergency_recovery_log
git log --all --grep="Claude Code" --oneline | head -10 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log

# Identify commits before recent breaking changes
echo "Commits before potential breaking changes:" >> .emergency_recovery_log
git log --oneline --since="2 days ago" | tail -20 >> .emergency_recovery_log
echo "" >> .emergency_recovery_log
```

---

## PHASE 3: SURGICAL FILE RECOVERY PROTOCOL

### PRECISION RECOVERY OF KNOWN GOOD CODE

**STEP 1: FILE-BY-FILE RECOVERY ASSESSMENT**

```bash
# Function to recover a specific file from a known good commit
recover_file_from_commit() {
    local file_path=$1
    local source_commit=$2
    local recovery_reason=$3
    
    echo "=== RECOVERING FILE: $file_path ===" >> .emergency_recovery_log
    echo "Source Commit: $source_commit" >> .emergency_recovery_log
    echo "Reason: $recovery_reason" >> .emergency_recovery_log
    
    # Backup current version if it exists
    if [ -f "$file_path" ]; then
        cp "$file_path" "${file_path}.emergency_backup_$(date +%Y%m%d_%H%M%S)"
        echo "Backed up current version to ${file_path}.emergency_backup_$(date +%Y%m%d_%H%M%S)" >> .emergency_recovery_log
    fi
    
    # Check if file exists in source commit
    if git cat-file -e ${source_commit}:${file_path} 2>/dev/null; then
        echo "File exists in source commit - proceeding with recovery" >> .emergency_recovery_log
        
        # Show file differences
        echo "Changes being made:" >> .emergency_recovery_log
        git show ${source_commit}:${file_path} > /tmp/recovery_temp
        if [ -f "$file_path" ]; then
            diff "$file_path" /tmp/recovery_temp >> .emergency_recovery_log || echo "DIFF_COMPLETE" >> .emergency_recovery_log
        fi
        
        # Recover the file
        git show ${source_commit}:${file_path} > "$file_path"
        echo "✅ FILE RECOVERED: $file_path from $source_commit" >> .emergency_recovery_log
        
        # Validate recovery
        if [ -f "$file_path" ]; then
            echo "Recovery validation: File size $(wc -c < "$file_path") bytes" >> .emergency_recovery_log
        fi
        
        rm -f /tmp/recovery_temp
    else
        echo "❌ FILE NOT FOUND in source commit $source_commit" >> .emergency_recovery_log
    fi
    
    echo "" >> .emergency_recovery_log
}
```

**STEP 2: CRITICAL COMPONENT RECOVERY SEQUENCE**

```bash
echo "=== CRITICAL COMPONENT RECOVERY ===" >> .emergency_recovery_log

# Recovery sequence for critical application files
# (User must specify the known good commit hash and files to recover)

# Example recovery commands (user must specify actual values):
# recover_file_from_commit "api-gateway-service/app/main.py" "abc123def" "Restore working API gateway"
# recover_file_from_commit "mcp-config-local.json" "abc123def" "Restore working MCP configuration"  
# recover_file_from_commit "docker-compose.yml" "abc123def" "Restore working container orchestration"

echo "MANUAL INPUT REQUIRED:" >> .emergency_recovery_log
echo "User must specify:" >> .emergency_recovery_log
echo "1. Known good commit hash(es)" >> .emergency_recovery_log
echo "2. Specific files to recover" >> .emergency_recovery_log
echo "3. Recovery justification" >> .emergency_recovery_log
echo "" >> .emergency_recovery_log
```

**STEP 3: DIRECTORY-LEVEL RECOVERY PROTOCOL**

```bash
# Function to recover an entire directory from a known good state
recover_directory_from_commit() {
    local dir_path=$1
    local source_commit=$2
    local recovery_reason=$3
    
    echo "=== RECOVERING DIRECTORY: $dir_path ===" >> .emergency_recovery_log
    echo "Source Commit: $source_commit" >> .emergency_recovery_log
    echo "Reason: $recovery_reason" >> .emergency_recovery_log
    
    # Backup current directory if it exists
    if [ -d "$dir_path" ]; then
        mv "$dir_path" "${dir_path}.emergency_backup_$(date +%Y%m%d_%H%M%S)"
        echo "Backed up current directory to ${dir_path}.emergency_backup_$(date +%Y%m%d_%H%M%S)" >> .emergency_recovery_log
    fi
    
    # Check if directory exists in source commit
    if git cat-file -e ${source_commit}:${dir_path} 2>/dev/null; then
        echo "Directory exists in source commit - proceeding with recovery" >> .emergency_recovery_log
        
        # Create directory structure
        mkdir -p "$dir_path"
        
        # Recover all files in directory
        git archive $source_commit $dir_path | tar -x
        
        echo "✅ DIRECTORY RECOVERED: $dir_path from $source_commit" >> .emergency_recovery_log
        
        # Validate recovery
        if [ -d "$dir_path" ]; then
            echo "Recovery validation: $(find "$dir_path" -type f | wc -l) files recovered" >> .emergency_recovery_log
        fi
    else
        echo "❌ DIRECTORY NOT FOUND in source commit $source_commit" >> .emergency_recovery_log
    fi
    
    echo "" >> .emergency_recovery_log
}
```

---

## PHASE 4: RECOVERY VALIDATION AND ROLLBACK SAFETY

### MANDATORY VALIDATION AFTER EACH RECOVERY

**STEP 1: IMMEDIATE VALIDATION PROTOCOL**

```bash
validate_recovery_step() {
    local recovery_description=$1
    
    echo "=== VALIDATING RECOVERY: $recovery_description ===" >> .emergency_recovery_log
    
    # Basic file system validation
    echo "File system validation:" >> .emergency_recovery_log
    if find . -name "*.py" -exec python -m py_compile {} \; 2>/dev/null; then
        echo "✅ Python files compile successfully" >> .emergency_recovery_log
    else
        echo "❌ Python compilation errors detected" >> .emergency_recovery_log
    fi
    
    # JSON configuration validation
    if find . -name "*.json" -exec jq empty {} \; 2>/dev/null; then
        echo "✅ JSON files are valid" >> .emergency_recovery_log
    else
        echo "❌ JSON validation errors detected" >> .emergency_recovery_log
    fi
    
    # Docker compose validation (if applicable)
    if [ -f docker-compose.yml ]; then
        if docker-compose config -q; then
            echo "✅ Docker Compose configuration is valid" >> .emergency_recovery_log
        else
            echo "❌ Docker Compose validation failed" >> .emergency_recovery_log
        fi
    fi
    
    # Git repository integrity check
    if git fsck --quiet; then
        echo "✅ Git repository integrity intact" >> .emergency_recovery_log
    else
        echo "❌ Git repository integrity issues detected" >> .emergency_recovery_log
    fi
    
    echo "" >> .emergency_recovery_log
}
```

**STEP 2: ROLLBACK SAFETY PROTOCOL**

```bash
create_recovery_rollback_point() {
    local recovery_stage=$1
    
    echo "=== CREATING ROLLBACK POINT: $recovery_stage ===" >> .emergency_recovery_log
    
    # Create a branch for this recovery state
    ROLLBACK_BRANCH="emergency-recovery-$(date +%Y%m%d_%H%M%S)-$recovery_stage"
    git checkout -b $ROLLBACK_BRANCH
    
    # Commit current recovery state
    git add -A
    git commit -m "emergency-recovery: $recovery_stage rollback point

[Emergency-Recovery-Rollback-Point]
Stage: $recovery_stage
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Instance: [Claude-Sonnet-4-$(date -u +%Y-%m-%dT%H:%M:%SZ)]

This commit represents a rollback point during emergency data recovery.
All changes up to this point have been validated.

🚨 Emergency Recovery with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    # Push rollback branch immediately
    git push origin $ROLLBACK_BRANCH
    
    echo "✅ ROLLBACK POINT CREATED: $ROLLBACK_BRANCH" >> .emergency_recovery_log
    echo "✅ ROLLBACK BRANCH PUSHED TO ORIGIN" >> .emergency_recovery_log
    
    # Return to working branch
    git checkout $(git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD")
    
    echo "" >> .emergency_recovery_log
}
```

---

## PHASE 5: SYSTEMATIC APPLICATION RESTORATION

### FUNCTION-BY-FUNCTION RESTORATION PROTOCOL

**STEP 1: API ENDPOINT RESTORATION**

```bash
restore_api_functionality() {
    echo "=== API FUNCTIONALITY RESTORATION ===" >> .emergency_recovery_log
    
    # Test each critical API endpoint
    declare -a API_ENDPOINTS=(
        "/api/v1/health"
        "/api/v1/status/api"
        "/api/v1/mcp/servers"
        "/api/v1/ai/complete"
    )
    
    for endpoint in "${API_ENDPOINTS[@]}"; do
        echo "Testing endpoint: $endpoint" >> .emergency_recovery_log
        
        if curl -s -f "http://localhost:8000$endpoint" > /dev/null; then
            echo "✅ $endpoint - WORKING" >> .emergency_recovery_log
        else
            echo "❌ $endpoint - FAILED" >> .emergency_recovery_log
            echo "REQUIRES RECOVERY: Find working version of API handler" >> .emergency_recovery_log
        fi
    done
    
    echo "" >> .emergency_recovery_log
}
```

**STEP 2: FRAMEWORK MODULE RESTORATION**

```bash
restore_framework_modules() {
    echo "=== FRAMEWORK MODULE RESTORATION ===" >> .emergency_recovery_log
    
    # Test critical Python imports
    declare -a CRITICAL_MODULES=(
        "app.main"
        "app.services.mcp_manager"
        "app.auth.authentication"
        "app.middleware.logging"
    )
    
    for module in "${CRITICAL_MODULES[@]}"; do
        echo "Testing module: $module" >> .emergency_recovery_log
        
        if python -c "import $module" 2>/dev/null; then
            echo "✅ $module - IMPORTS SUCCESSFULLY" >> .emergency_recovery_log
        else
            echo "❌ $module - IMPORT FAILED" >> .emergency_recovery_log
            echo "REQUIRES RECOVERY: Find working version of $module" >> .emergency_recovery_log
        fi
    done
    
    echo "" >> .emergency_recovery_log
}
```

---

## PHASE 6: FINAL VALIDATION AND DOCUMENTATION

### SYSTEM VALIDATION

**STEP 1: END-TO-END SYSTEM TEST**

```bash
final_system_validation() {
    echo "=== FINAL SYSTEM VALIDATION ===" >> .emergency_recovery_log
    
    # Container orchestration test
    if [ -f docker-compose.yml ]; then
        echo "Testing container orchestration:" >> .emergency_recovery_log
        docker-compose config -q && echo "✅ Docker Compose Config Valid" >> .emergency_recovery_log
        
        # Dry run container startup
        docker-compose up --dry-run >> .emergency_recovery_log 2>&1
    fi
    
    # MCP server configuration test
    if [ -f mcp-config-local.json ]; then
        echo "Testing MCP configuration:" >> .emergency_recovery_log
        jq -r '.mcpServers | keys[]' mcp-config-local.json >> .emergency_recovery_log 2>/dev/null
        echo "MCP servers configured: $(jq -r '.mcpServers | keys | length' mcp-config-local.json 2>/dev/null)" >> .emergency_recovery_log
    fi
    
    # Git repository health
    echo "Git repository final health check:" >> .emergency_recovery_log
    git status --porcelain >> .emergency_recovery_log
    git log --oneline -5 >> .emergency_recovery_log
    
    echo "" >> .emergency_recovery_log
}
```

**STEP 2: RECOVERY DOCUMENTATION AND AUDIT TRAIL**

```bash
finalize_recovery_documentation() {
    echo "=== RECOVERY COMPLETION SUMMARY ===" >> .emergency_recovery_log
    echo "Recovery completed at: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> .emergency_recovery_log
    echo "Total recovery time: [Manual calculation required]" >> .emergency_recovery_log
    echo "Files recovered: $(grep "FILE RECOVERED" .emergency_recovery_log | wc -l)" >> .emergency_recovery_log
    echo "Directories recovered: $(grep "DIRECTORY RECOVERED" .emergency_recovery_log | wc -l)" >> .emergency_recovery_log
    echo "Rollback points created: $(grep "ROLLBACK POINT CREATED" .emergency_recovery_log | wc -l)" >> .emergency_recovery_log
    echo "" >> .emergency_recovery_log
    
    # Create permanent recovery documentation
    cp .emergency_recovery_log "emergency_recovery_$(date +%Y%m%d_%H%M%S).log"
    
    # Commit recovery documentation
    git add "emergency_recovery_$(date +%Y%m%d_%H%M%S).log"
    git commit -m "docs: emergency recovery audit trail

[Emergency-Recovery-Documentation]
Recovery completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Files recovered: $(grep "FILE RECOVERED" .emergency_recovery_log | wc -l)
System status: [User to confirm - WORKING/PARTIAL/FAILED]

🚨 Emergency Recovery Documentation with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    git push origin $(git branch --show-current)
    
    echo "✅ EMERGENCY RECOVERY DOCUMENTATION COMPLETE"
    echo "✅ AUDIT TRAIL PRESERVED AND COMMITTED"
}
```

---

## EMERGENCY RECOVERY EXECUTION CHECKLIST

**MANDATORY PRE-RECOVERY VERIFICATION:**
- [ ] Current broken state documented
- [ ] Git forensics analysis completed  
- [ ] Known good branches/commits identified
- [ ] Recovery target files/directories specified
- [ ] Rollback strategy prepared

**RECOVERY EXECUTION SEQUENCE:**
- [ ] Phase 1: Emergency state assessment
- [ ] Phase 2: Known good state identification
- [ ] Phase 3: Surgical file recovery 
- [ ] Phase 4: Recovery validation and rollback safety
- [ ] Phase 5: Systematic application restoration
- [ ] Phase 6: Final validation and documentation

**POST-RECOVERY VALIDATION:**
- [ ] All recovered files compile/validate
- [ ] Critical API endpoints functional
- [ ] Framework modules import successfully
- [ ] Container orchestration validates
- [ ] Git repository integrity intact
- [ ] Recovery audit trail committed

---

**ENFORCEMENT:** This emergency recovery protocol is MANDATORY during data corruption events and must be followed exactly to prevent additional data loss.