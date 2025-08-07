# Git Exhaustive File Analysis Protocol

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:

1. Analyze which files need exhaustive content analysis
2. Plan your deep file inspection approach across git history
3. Consider the implications of each file version comparison
4. Only then proceed with the exhaustive analysis execution

**This thinking requirement is MANDATORY and must be followed for every analysis action.**

---

## ⚠️ EXHAUSTIVE FILE CONTENT ANALYSIS FOR EMERGENCY RECOVERY ⚠️

### CANONICAL EXHAUSTIVE ANALYSIS DIRECTIVE

**THIS PROTOCOL PROVIDES EXHAUSTIVE FILE CONTENT ANALYSIS:**

- **MUST** perform complete content analysis of ALL file versions across git history
- **MUST** compare entire file contents, not just headers or summaries
- **SHALL** analyze function-by-function, class-by-class, and line-by-line differences
- **MUST** identify exact code blocks that are missing, broken, or corrupted
- **SHALL** create content maps of working vs broken states
- **MUST** trace exact changes that led to data corruption

---

## PHASE 1: FILE INVENTORY AND CONTENT MAPPING

### EXHAUSTIVE FILE CONTENT ANALYSIS

**STEP 1: COMPLETE FILE CONTENT EXTRACTION FROM GIT HISTORY**

```bash
# Function to perform exhaustive file content analysis across git history
exhaustive_file_analysis() {
    local file_path=$1
    local analysis_log="${file_path//\//_}_exhaustive_analysis.log"
    
    echo "=== EXHAUSTIVE ANALYSIS: $file_path ===" > "$analysis_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$analysis_log"
    echo "" >> "$analysis_log"
    
    # Get ALL commits that touched this file
    echo "=== COMMIT HISTORY FOR FILE ===" >> "$analysis_log"
    git log --follow --oneline -- "$file_path" >> "$analysis_log"
    echo "" >> "$analysis_log"
    
    # For each commit, extract and analyze complete file content
    git log --follow --format="%H|%s|%an|%ad" --date=iso -- "$file_path" | while IFS='|' read -r commit_hash commit_msg author commit_date; do
        echo "=== COMMIT: $commit_hash ===" >> "$analysis_log"
        echo "Message: $commit_msg" >> "$analysis_log"
        echo "Author: $author" >> "$analysis_log"
        echo "Date: $commit_date" >> "$analysis_log"
        echo "" >> "$analysis_log"
        
        # Extract complete file content from this commit
        if git cat-file -e ${commit_hash}:${file_path} 2>/dev/null; then
            echo "--- COMPLETE FILE CONTENT ---" >> "$analysis_log"
            git show ${commit_hash}:${file_path} >> "$analysis_log"
            echo "" >> "$analysis_log"
            
            # File statistics
            echo "--- FILE STATISTICS ---" >> "$analysis_log"
            echo "Lines: $(git show ${commit_hash}:${file_path} | wc -l)" >> "$analysis_log"
            echo "Characters: $(git show ${commit_hash}:${file_path} | wc -c)" >> "$analysis_log"  
            echo "Words: $(git show ${commit_hash}:${file_path} | wc -w)" >> "$analysis_log"
            echo "" >> "$analysis_log"
            
            # Function/class analysis for Python files
            if [[ "$file_path" == *.py ]]; then
                echo "--- PYTHON STRUCTURE ANALYSIS ---" >> "$analysis_log"
                git show ${commit_hash}:${file_path} | grep -n "^class\|^def\|^async def" >> "$analysis_log"
                echo "" >> "$analysis_log"
                
                # Import analysis
                echo "--- IMPORT ANALYSIS ---" >> "$analysis_log"
                git show ${commit_hash}:${file_path} | grep -n "^import\|^from.*import" >> "$analysis_log"
                echo "" >> "$analysis_log"
            fi
            
            # JSON structure analysis for config files
            if [[ "$file_path" == *.json ]]; then
                echo "--- JSON STRUCTURE ANALYSIS ---" >> "$analysis_log"
                git show ${commit_hash}:${file_path} | jq -r 'paths(scalars) as $p | $p | join(".")' 2>/dev/null >> "$analysis_log" || echo "JSON_PARSE_ERROR" >> "$analysis_log"
                echo "" >> "$analysis_log"
                
                # JSON key count
                echo "--- JSON KEY ANALYSIS ---" >> "$analysis_log"
                git show ${commit_hash}:${file_path} | jq -r 'keys' 2>/dev/null >> "$analysis_log" || echo "JSON_PARSE_ERROR" >> "$analysis_log"
                echo "" >> "$analysis_log"
            fi
            
            # Docker Compose analysis
            if [[ "$file_path" == *docker-compose*.yml ]]; then
                echo "--- DOCKER COMPOSE ANALYSIS ---" >> "$analysis_log"
                git show ${commit_hash}:${file_path} | grep -n "services:\|version:\|networks:\|volumes:" >> "$analysis_log"
                echo "" >> "$analysis_log"
                
                # Service list
                echo "--- SERVICE LIST ---" >> "$analysis_log"
                git show ${commit_hash}:${file_path} | yq eval '.services | keys' 2>/dev/null >> "$analysis_log" || echo "YAML_PARSE_ERROR" >> "$analysis_log"
                echo "" >> "$analysis_log"
            fi
            
        else
            echo "FILE NOT FOUND in commit $commit_hash" >> "$analysis_log"
        fi
        
        echo "========================================" >> "$analysis_log"
        echo "" >> "$analysis_log"
    done
    
    echo "✅ EXHAUSTIVE ANALYSIS COMPLETE: $analysis_log"
}
```

**STEP 2: COMPARATIVE CONTENT ANALYSIS**

```bash
# Function to compare complete file contents between commits
comparative_content_analysis() {
    local file_path=$1
    local commit1=$2
    local commit2=$3
    local comparison_log="${file_path//\//_}_comparison_${commit1:0:8}_vs_${commit2:0:8}.log"
    
    echo "=== COMPARATIVE CONTENT ANALYSIS ===" > "$comparison_log"
    echo "File: $file_path" >> "$comparison_log"
    echo "Commit 1: $commit1" >> "$comparison_log"
    echo "Commit 2: $commit2" >> "$comparison_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$comparison_log"
    echo "" >> "$comparison_log"
    
    # Extract both versions
    git show ${commit1}:${file_path} > "/tmp/version1_${commit1:0:8}"
    git show ${commit2}:${file_path} > "/tmp/version2_${commit2:0:8}"
    
    # Complete line-by-line diff
    echo "=== COMPLETE LINE-BY-LINE DIFFERENCES ===" >> "$comparison_log"
    diff -u "/tmp/version1_${commit1:0:8}" "/tmp/version2_${commit2:0:8}" >> "$comparison_log" || echo "DIFF_COMPLETE" >> "$comparison_log"
    echo "" >> "$comparison_log"
    
    # Word-level differences
    echo "=== WORD-LEVEL DIFFERENCES ===" >> "$comparison_log"
    wdiff "/tmp/version1_${commit1:0:8}" "/tmp/version2_${commit2:0:8}" >> "$comparison_log" 2>/dev/null || echo "WDIFF_NOT_AVAILABLE" >> "$comparison_log"
    echo "" >> "$comparison_log"
    
    # Character-level differences
    echo "=== CHARACTER-LEVEL DIFFERENCES ===" >> "$comparison_log"
    diff -y --left-column "/tmp/version1_${commit1:0:8}" "/tmp/version2_${commit2:0:8}" >> "$comparison_log" || echo "CHAR_DIFF_COMPLETE" >> "$comparison_log"
    echo "" >> "$comparison_log"
    
    # Function/method level analysis for Python
    if [[ "$file_path" == *.py ]]; then
        echo "=== FUNCTION-LEVEL ANALYSIS ===" >> "$comparison_log"
        
        echo "Functions in Version 1 ($commit1):" >> "$comparison_log"
        grep -n "^def\|^async def\|^class" "/tmp/version1_${commit1:0:8}" >> "$comparison_log"
        echo "" >> "$comparison_log"
        
        echo "Functions in Version 2 ($commit2):" >> "$comparison_log"
        grep -n "^def\|^async def\|^class" "/tmp/version2_${commit2:0:8}" >> "$comparison_log"
        echo "" >> "$comparison_log"
        
        # Function signature changes
        echo "=== FUNCTION SIGNATURE COMPARISON ===" >> "$comparison_log"
        comm -3 <(grep "^def\|^async def\|^class" "/tmp/version1_${commit1:0:8}" | sort) <(grep "^def\|^async def\|^class" "/tmp/version2_${commit2:0:8}" | sort) >> "$comparison_log"
        echo "" >> "$comparison_log"
    fi
    
    # JSON structure comparison
    if [[ "$file_path" == *.json ]]; then
        echo "=== JSON STRUCTURE COMPARISON ===" >> "$comparison_log"
        
        echo "Keys in Version 1 ($commit1):" >> "$comparison_log"
        jq -r 'paths(scalars) as $p | $p | join(".")' "/tmp/version1_${commit1:0:8}" 2>/dev/null | sort >> "$comparison_log" || echo "JSON_PARSE_ERROR_V1" >> "$comparison_log"
        echo "" >> "$comparison_log"
        
        echo "Keys in Version 2 ($commit2):" >> "$comparison_log"
        jq -r 'paths(scalars) as $p | $p | join(".")' "/tmp/version2_${commit2:0:8}" 2>/dev/null | sort >> "$comparison_log" || echo "JSON_PARSE_ERROR_V2" >> "$comparison_log"
        echo "" >> "$comparison_log"
        
        echo "=== JSON KEY DIFFERENCES ===" >> "$comparison_log"
        comm -3 <(jq -r 'paths(scalars) as $p | $p | join(".")' "/tmp/version1_${commit1:0:8}" 2>/dev/null | sort) <(jq -r 'paths(scalars) as $p | $p | join(".")' "/tmp/version2_${commit2:0:8}" 2>/dev/null | sort) >> "$comparison_log" 2>/dev/null || echo "JSON_COMPARISON_ERROR" >> "$comparison_log"
        echo "" >> "$comparison_log"
    fi
    
    # File size and content metrics
    echo "=== CONTENT METRICS COMPARISON ===" >> "$comparison_log"
    echo "Version 1 ($commit1):" >> "$comparison_log"
    echo "  Lines: $(wc -l < "/tmp/version1_${commit1:0:8}")" >> "$comparison_log"
    echo "  Words: $(wc -w < "/tmp/version1_${commit1:0:8}")" >> "$comparison_log"
    echo "  Characters: $(wc -c < "/tmp/version1_${commit1:0:8}")" >> "$comparison_log"
    echo "" >> "$comparison_log"
    
    echo "Version 2 ($commit2):" >> "$comparison_log"
    echo "  Lines: $(wc -l < "/tmp/version2_${commit2:0:8}")" >> "$comparison_log"
    echo "  Words: $(wc -w < "/tmp/version2_${commit2:0:8}")" >> "$comparison_log"
    echo "  Characters: $(wc -c < "/tmp/version2_${commit2:0:8}")" >> "$comparison_log"
    echo "" >> "$comparison_log"
    
    # Cleanup
    rm -f "/tmp/version1_${commit1:0:8}" "/tmp/version2_${commit2:0:8}"
    
    echo "✅ COMPARATIVE ANALYSIS COMPLETE: $comparison_log"
}
```

**STEP 3: DIRECTORY CONTENT ANALYSIS**

```bash
# Function to perform exhaustive analysis of entire directory contents
exhaustive_directory_analysis() {
    local dir_path=$1
    local analysis_log="${dir_path//\//_}_directory_exhaustive_analysis.log"
    
    echo "=== EXHAUSTIVE DIRECTORY ANALYSIS: $dir_path ===" > "$analysis_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$analysis_log"
    echo "" >> "$analysis_log"
    
    # Get all commits that affected this directory
    echo "=== COMMITS AFFECTING DIRECTORY ===" >> "$analysis_log"
    git log --oneline -- "$dir_path" >> "$analysis_log"
    echo "" >> "$analysis_log"
    
    # For each recent commit, analyze complete directory structure
    git log --format="%H|%s|%an|%ad" --date=iso -10 -- "$dir_path" | while IFS='|' read -r commit_hash commit_msg author commit_date; do
        echo "=== DIRECTORY STATE IN COMMIT: $commit_hash ===" >> "$analysis_log"
        echo "Message: $commit_msg" >> "$analysis_log"
        echo "Author: $author" >> "$analysis_log"
        echo "Date: $commit_date" >> "$analysis_log"
        echo "" >> "$analysis_log"
        
        # List all files in directory at this commit
        echo "--- COMPLETE FILE LIST ---" >> "$analysis_log"
        git ls-tree -r --name-only $commit_hash -- "$dir_path" >> "$analysis_log" 2>/dev/null || echo "DIRECTORY_NOT_FOUND" >> "$analysis_log"
        echo "" >> "$analysis_log"
        
        # For each file in directory, show complete content
        git ls-tree -r --name-only $commit_hash -- "$dir_path" 2>/dev/null | while read -r file_in_dir; do
            echo "--- FILE: $file_in_dir ---" >> "$analysis_log"
            
            # Show complete file content
            git show ${commit_hash}:${file_in_dir} >> "$analysis_log" 2>/dev/null || echo "FILE_READ_ERROR" >> "$analysis_log"
            echo "" >> "$analysis_log"
            
            # File-specific analysis
            case "$file_in_dir" in
                *.py)
                    echo "Python Structure:" >> "$analysis_log"
                    git show ${commit_hash}:${file_in_dir} 2>/dev/null | grep -n "^class\|^def\|^async def" >> "$analysis_log"
                    echo "" >> "$analysis_log"
                    ;;
                *.json)
                    echo "JSON Structure:" >> "$analysis_log"
                    git show ${commit_hash}:${file_in_dir} 2>/dev/null | jq -r 'keys' >> "$analysis_log" 2>/dev/null || echo "JSON_PARSE_ERROR" >> "$analysis_log"
                    echo "" >> "$analysis_log"
                    ;;
                *.yml|*.yaml)
                    echo "YAML Structure:" >> "$analysis_log"
                    git show ${commit_hash}:${file_in_dir} 2>/dev/null | grep -n "^[[:alpha:]].*:" >> "$analysis_log"
                    echo "" >> "$analysis_log"
                    ;;
            esac
            
            echo "--- END FILE: $file_in_dir ---" >> "$analysis_log"
            echo "" >> "$analysis_log"
        done
        
        echo "========================================" >> "$analysis_log"
        echo "" >> "$analysis_log"
    done
    
    echo "✅ EXHAUSTIVE DIRECTORY ANALYSIS COMPLETE: $analysis_log"
}
```

---

## PHASE 2: FUNCTION-BY-FUNCTION CODE ANALYSIS

### DETAILED CODE STRUCTURE ANALYSIS

**STEP 1: PYTHON CODE FUNCTION ANALYSIS**

```bash
# Function to analyze Python code structure exhaustively
python_function_analysis() {
    local file_path=$1
    local commit_hash=$2
    local function_log="${file_path//\//_}_functions_${commit_hash:0:8}.log"
    
    echo "=== PYTHON FUNCTION ANALYSIS ===" > "$function_log"
    echo "File: $file_path" >> "$function_log"
    echo "Commit: $commit_hash" >> "$function_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$function_log"
    echo "" >> "$function_log"
    
    # Extract complete file content
    git show ${commit_hash}:${file_path} > "/tmp/python_analysis_${commit_hash:0:8}.py"
    
    # Class analysis
    echo "=== CLASS DEFINITIONS ===" >> "$function_log"
    grep -n "^class " "/tmp/python_analysis_${commit_hash:0:8}.py" | while read -r class_line; do
        echo "$class_line" >> "$function_log"
        
        # Extract class methods
        class_name=$(echo "$class_line" | sed 's/^[0-9]*:class \([^(]*\).*/\1/')
        echo "  Methods in $class_name:" >> "$function_log"
        awk "/^class $class_name/,/^class |^$/" "/tmp/python_analysis_${commit_hash:0:8}.py" | grep -n "    def\|    async def" >> "$function_log"
        echo "" >> "$function_log"
    done
    
    # Function analysis
    echo "=== FUNCTION DEFINITIONS ===" >> "$function_log"
    grep -n "^def\|^async def" "/tmp/python_analysis_${commit_hash:0:8}.py" | while read -r func_line; do
        func_line_num=$(echo "$func_line" | cut -d: -f1)
        echo "$func_line" >> "$function_log"
        
        # Extract function body
        echo "  Function body:" >> "$function_log"
        sed -n "${func_line_num},/^def\|^async def\|^class\|^$/p" "/tmp/python_analysis_${commit_hash:0:8}.py" | head -n -1 >> "$function_log"
        echo "" >> "$function_log"
    done
    
    # Import analysis
    echo "=== IMPORT ANALYSIS ===" >> "$function_log"
    grep -n "^import\|^from.*import" "/tmp/python_analysis_${commit_hash:0:8}.py" >> "$function_log"
    echo "" >> "$function_log"
    
    # Global variables and constants
    echo "=== GLOBAL VARIABLES ===" >> "$function_log"
    grep -n "^[A-Z_][A-Z0-9_]* = " "/tmp/python_analysis_${commit_hash:0:8}.py" >> "$function_log"
    echo "" >> "$function_log"
    
    # Docstring analysis
    echo "=== DOCSTRING ANALYSIS ===" >> "$function_log"
    grep -A 10 '"""' "/tmp/python_analysis_${commit_hash:0:8}.py" >> "$function_log"
    echo "" >> "$function_log"
    
    # Cleanup
    rm -f "/tmp/python_analysis_${commit_hash:0:8}.py"
    
    echo "✅ PYTHON FUNCTION ANALYSIS COMPLETE: $function_log"
}
```

**STEP 2: CONFIGURATION FILE DEEP ANALYSIS**

```bash
# Function to analyze configuration files exhaustively
config_file_deep_analysis() {
    local file_path=$1
    local commit_hash=$2
    local config_log="${file_path//\//_}_config_${commit_hash:0:8}.log"
    
    echo "=== CONFIGURATION FILE DEEP ANALYSIS ===" > "$config_log"
    echo "File: $file_path" >> "$config_log"
    echo "Commit: $commit_hash" >> "$config_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$config_log"
    echo "" >> "$config_log"
    
    # Extract complete file content
    git show ${commit_hash}:${file_path} > "/tmp/config_analysis_${commit_hash:0:8}"
    
    case "$file_path" in
        *.json)
            echo "=== JSON STRUCTURE ANALYSIS ===" >> "$config_log"
            
            # Complete JSON pretty-printed
            echo "--- COMPLETE JSON CONTENT ---" >> "$config_log"
            jq . "/tmp/config_analysis_${commit_hash:0:8}" >> "$config_log" 2>/dev/null || {
                echo "JSON_PARSE_ERROR - Raw content:" >> "$config_log"
                cat "/tmp/config_analysis_${commit_hash:0:8}" >> "$config_log"
            }
            echo "" >> "$config_log"
            
            # All JSON paths
            echo "=== ALL JSON PATHS ===" >> "$config_log"
            jq -r 'paths as $p | $p | join(".")' "/tmp/config_analysis_${commit_hash:0:8}" 2>/dev/null >> "$config_log" || echo "JSON_PATH_ERROR" >> "$config_log"
            echo "" >> "$config_log"
            
            # All values with paths
            echo "=== ALL VALUES WITH PATHS ===" >> "$config_log"
            jq -r 'paths(scalars) as $p | "\($p | join(".")): \(getpath($p))"' "/tmp/config_analysis_${commit_hash:0:8}" 2>/dev/null >> "$config_log" || echo "JSON_VALUE_ERROR" >> "$config_log"
            echo "" >> "$config_log"
            ;;
            
        *.yml|*.yaml)
            echo "=== YAML STRUCTURE ANALYSIS ===" >> "$config_log"
            
            # Complete YAML content
            echo "--- COMPLETE YAML CONTENT ---" >> "$config_log"
            cat "/tmp/config_analysis_${commit_hash:0:8}" >> "$config_log"
            echo "" >> "$config_log"
            
            # YAML keys and structure
            echo "=== YAML KEYS AND STRUCTURE ===" >> "$config_log"
            grep -n "^[[:alpha:]].*:" "/tmp/config_analysis_${commit_hash:0:8}" >> "$config_log"
            echo "" >> "$config_log"
            
            # YAML values
            echo "=== YAML VALUES ===" >> "$config_log"
            yq eval -o json "/tmp/config_analysis_${commit_hash:0:8}" 2>/dev/null | jq -r 'paths(scalars) as $p | "\($p | join(".")): \(getpath($p))"' >> "$config_log" 2>/dev/null || echo "YAML_PARSE_ERROR" >> "$config_log"
            echo "" >> "$config_log"
            ;;
            
        *.env|*.env.*)
            echo "=== ENVIRONMENT FILE ANALYSIS ===" >> "$config_log"
            
            # Complete env content (excluding sensitive values)
            echo "--- ENVIRONMENT VARIABLES ---" >> "$config_log"
            while IFS= read -r line; do
                if [[ "$line" =~ ^[A-Z_][A-Z0-9_]*= ]]; then
                    var_name=$(echo "$line" | cut -d= -f1)
                    if [[ "$var_name" =~ (PASSWORD|SECRET|KEY|TOKEN) ]]; then
                        echo "$var_name=***REDACTED***" >> "$config_log"
                    else
                        echo "$line" >> "$config_log"
                    fi
                elif [[ ! "$line" =~ ^# ]] && [[ -n "$line" ]]; then
                    echo "$line" >> "$config_log"
                fi
            done < "/tmp/config_analysis_${commit_hash:0:8}"
            echo "" >> "$config_log"
            ;;
    esac
    
    # File integrity checks
    echo "=== FILE INTEGRITY ANALYSIS ===" >> "$config_log"
    echo "File size: $(wc -c < "/tmp/config_analysis_${commit_hash:0:8}") bytes" >> "$config_log"
    echo "Line count: $(wc -l < "/tmp/config_analysis_${commit_hash:0:8}")" >> "$config_log"
    echo "Word count: $(wc -w < "/tmp/config_analysis_${commit_hash:0:8}")" >> "$config_log"
    echo "MD5 hash: $(md5sum "/tmp/config_analysis_${commit_hash:0:8}" | cut -d' ' -f1)" >> "$config_log"
    echo "" >> "$config_log"
    
    # Cleanup
    rm -f "/tmp/config_analysis_${commit_hash:0:8}"
    
    echo "✅ CONFIGURATION FILE ANALYSIS COMPLETE: $config_log"
}
```

---

## PHASE 3: DIFF ANALYSIS

### EXHAUSTIVE CHANGE DETECTION

**STEP 1: MULTI-LEVEL DIFF ANALYSIS**

```bash
# Function to perform exhaustive diff analysis between any two commits
exhaustive_diff_analysis() {
    local commit1=$1
    local commit2=$2
    local diff_log="exhaustive_diff_${commit1:0:8}_to_${commit2:0:8}.log"
    
    echo "=== EXHAUSTIVE DIFF ANALYSIS ===" > "$diff_log"
    echo "From Commit: $commit1" >> "$diff_log"
    echo "To Commit: $commit2" >> "$diff_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$diff_log"
    echo "" >> "$diff_log"
    
    # High-level commit information
    echo "=== COMMIT INFORMATION ===" >> "$diff_log"
    echo "Commit 1 Details:" >> "$diff_log"
    git show --no-patch --format="Hash: %H%nAuthor: %an <%ae>%nDate: %ad%nSubject: %s%nBody: %b" $commit1 >> "$diff_log"
    echo "" >> "$diff_log"
    
    echo "Commit 2 Details:" >> "$diff_log"
    git show --no-patch --format="Hash: %H%nAuthor: %an <%ae>%nDate: %ad%nSubject: %s%nBody: %b" $commit2 >> "$diff_log"
    echo "" >> "$diff_log"
    
    # Files changed between commits
    echo "=== FILES CHANGED ===" >> "$diff_log"
    git diff --name-status $commit1..$commit2 >> "$diff_log"
    echo "" >> "$diff_log"
    
    # Complete diff with full context
    echo "=== COMPLETE DIFF WITH FULL CONTEXT ===" >> "$diff_log"
    git diff -U1000 $commit1..$commit2 >> "$diff_log"
    echo "" >> "$diff_log"
    
    # File-by-file exhaustive analysis
    git diff --name-only $commit1..$commit2 | while read -r changed_file; do
        echo "=== EXHAUSTIVE ANALYSIS: $changed_file ===" >> "$diff_log"
        
        # File status (added, modified, deleted)
        file_status=$(git diff --name-status $commit1..$commit2 -- "$changed_file" | cut -f1)
        echo "Status: $file_status" >> "$diff_log"
        
        case "$file_status" in
            A)
                echo "FILE ADDED - Complete content:" >> "$diff_log"
                git show ${commit2}:${changed_file} >> "$diff_log" 2>/dev/null || echo "FILE_READ_ERROR" >> "$diff_log"
                ;;
            D)
                echo "FILE DELETED - Previous content:" >> "$diff_log"
                git show ${commit1}:${changed_file} >> "$diff_log" 2>/dev/null || echo "FILE_READ_ERROR" >> "$diff_log"
                ;;
            M)
                echo "FILE MODIFIED - Detailed analysis:" >> "$diff_log"
                
                # Before version
                echo "--- BEFORE (${commit1:0:8}) ---" >> "$diff_log"
                git show ${commit1}:${changed_file} >> "$diff_log" 2>/dev/null || echo "FILE_READ_ERROR" >> "$diff_log"
                echo "" >> "$diff_log"
                
                # After version
                echo "--- AFTER (${commit2:0:8}) ---" >> "$diff_log"
                git show ${commit2}:${changed_file} >> "$diff_log" 2>/dev/null || echo "FILE_READ_ERROR" >> "$diff_log"
                echo "" >> "$diff_log"
                
                # Line-by-line diff
                echo "--- LINE-BY-LINE CHANGES ---" >> "$diff_log"
                git diff -U1000 $commit1..$commit2 -- "$changed_file" >> "$diff_log"
                echo "" >> "$diff_log"
                
                # Word-level diff (if wdiff available)
                echo "--- WORD-LEVEL CHANGES ---" >> "$diff_log"
                git show ${commit1}:${changed_file} > "/tmp/before_${changed_file//\//_}"
                git show ${commit2}:${changed_file} > "/tmp/after_${changed_file//\//_}"
                wdiff "/tmp/before_${changed_file//\//_}" "/tmp/after_${changed_file//\//_}" >> "$diff_log" 2>/dev/null || echo "WDIFF_NOT_AVAILABLE" >> "$diff_log"
                rm -f "/tmp/before_${changed_file//\//_}" "/tmp/after_${changed_file//\//_}"
                echo "" >> "$diff_log"
                ;;
        esac
        
        # File-specific analysis
        case "$changed_file" in
            *.py)
                echo "--- PYTHON-SPECIFIC ANALYSIS ---" >> "$diff_log"
                echo "Functions/Classes before:" >> "$diff_log"
                git show ${commit1}:${changed_file} 2>/dev/null | grep -n "^class\|^def\|^async def" >> "$diff_log" || echo "NO_BEFORE_VERSION" >> "$diff_log"
                echo "Functions/Classes after:" >> "$diff_log"
                git show ${commit2}:${changed_file} 2>/dev/null | grep -n "^class\|^def\|^async def" >> "$diff_log" || echo "NO_AFTER_VERSION" >> "$diff_log"
                ;;
            *.json)
                echo "--- JSON-SPECIFIC ANALYSIS ---" >> "$diff_log"
                echo "JSON keys before:" >> "$diff_log"
                git show ${commit1}:${changed_file} 2>/dev/null | jq -r 'keys' >> "$diff_log" 2>/dev/null || echo "JSON_PARSE_ERROR_BEFORE" >> "$diff_log"
                echo "JSON keys after:" >> "$diff_log"
                git show ${commit2}:${changed_file} 2>/dev/null | jq -r 'keys' >> "$diff_log" 2>/dev/null || echo "JSON_PARSE_ERROR_AFTER" >> "$diff_log"
                ;;
        esac
        
        echo "--- END ANALYSIS: $changed_file ---" >> "$diff_log"
        echo "" >> "$diff_log"
    done
    
    echo "✅ EXHAUSTIVE DIFF ANALYSIS COMPLETE: $diff_log"
}
```

---

## PHASE 4: RECOVERY CANDIDATE SCORING

### SYSTEMATIC ANALYSIS OF RECOVERY CANDIDATES

**STEP 1: RECOVERY CANDIDATE SCORING SYSTEM**

```bash
# Function to score recovery candidates based on exhaustive analysis
score_recovery_candidates() {
    local analysis_log="recovery_candidates_scoring.log"
    
    echo "=== RECOVERY CANDIDATE SCORING ===" > "$analysis_log"
    echo "Analysis Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$analysis_log"
    echo "" >> "$analysis_log"
    
    # Get all branches and recent commits
    declare -A candidate_scores
    
    # Analyze each branch for recovery potential
    git branch -a --sort=-committerdate | head -20 | while read -r branch_ref; do
        branch_name=$(echo "$branch_ref" | sed 's/^[ *]*//' | sed 's/remotes\/origin\///')
        
        if [[ "$branch_name" != "HEAD" && "$branch_name" != "->" ]]; then
            echo "=== SCORING BRANCH: $branch_name ===" >> "$analysis_log"
            
            local score=0
            
            # Check if branch has working Docker Compose
            if git show ${branch_name}:docker-compose.yml &>/dev/null; then
                if git show ${branch_name}:docker-compose.yml | docker-compose -f - config -q &>/dev/null; then
                    score=$((score + 10))
                    echo "+10 points: Valid Docker Compose configuration" >> "$analysis_log"
                fi
            fi
            
            # Check if branch has valid MCP config
            if git show ${branch_name}:mcp-config-local.json &>/dev/null; then
                if git show ${branch_name}:mcp-config-local.json | jq empty &>/dev/null; then
                    score=$((score + 10))
                    echo "+10 points: Valid MCP configuration" >> "$analysis_log"
                    
                    # Bonus for more MCP servers
                    mcp_count=$(git show ${branch_name}:mcp-config-local.json | jq -r '.mcpServers | keys | length' 2>/dev/null || echo 0)
                    if [[ "$mcp_count" -gt 50 ]]; then
                        score=$((score + 5))
                        echo "+5 points: High MCP server count ($mcp_count)" >> "$analysis_log"
                    fi
                fi
            fi
            
            # Check API gateway completeness
            if git show ${branch_name}:api-gateway-service/app/main.py &>/dev/null; then
                api_size=$(git show ${branch_name}:api-gateway-service/app/main.py | wc -l)
                if [[ "$api_size" -gt 100 ]]; then
                    score=$((score + 8))
                    echo "+8 points: Substantial API gateway ($api_size lines)" >> "$analysis_log"
                fi
            fi
            
            # Check for test files
            test_count=$(git ls-tree -r --name-only ${branch_name} | grep -c "test.*\.py$" || echo 0)
            if [[ "$test_count" -gt 10 ]]; then
                score=$((score + 5))
                echo "+5 points: Good test coverage ($test_count test files)" >> "$analysis_log"
            fi
            
            # Check commit freshness
            commit_age_days=$(git log -1 --format="%ad" --date=format:"%s" ${branch_name} | xargs -I{} bash -c 'echo $(( ($(date +%s) - {}) / 86400 ))')
            if [[ "$commit_age_days" -lt 7 ]]; then
                score=$((score + 3))
                echo "+3 points: Recent commits (${commit_age_days} days old)" >> "$analysis_log"
            fi
            
            # Check for Claude Code signatures (indicates AI-generated quality)
            claude_commits=$(git log --grep="Claude Code" --oneline ${branch_name} | wc -l)
            if [[ "$claude_commits" -gt 0 ]]; then
                score=$((score + 2))
                echo "+2 points: Contains Claude Code commits ($claude_commits)" >> "$analysis_log"
            fi
            
            # Penalty for broken builds (if we can detect)
            if git show ${branch_name}:Makefile &>/dev/null; then
                # This would need to be implemented based on actual project structure
                echo "Build check would be performed here" >> "$analysis_log"
            fi
            
            echo "TOTAL SCORE for $branch_name: $score points" >> "$analysis_log"
            echo "" >> "$analysis_log"
            
            # Store score (would need actual storage mechanism)
            candidate_scores["$branch_name"]=$score
        fi
    done
    
    echo "=== RECOVERY RECOMMENDATIONS ===" >> "$analysis_log"
    echo "Recommended recovery order (highest score first):" >> "$analysis_log"
    
    # This would sort and display recommendations
    # Implementation depends on shell capabilities
    echo "Manual sorting required based on scores above" >> "$analysis_log"
    echo "" >> "$analysis_log"
    
    echo "✅ RECOVERY CANDIDATE SCORING COMPLETE: $analysis_log"
}
```

---

## INTEGRATION WITH EMERGENCY RECOVERY PROTOCOL

### USAGE WITH EMERGENCY RECOVERY

**To use this exhaustive analysis with the emergency recovery protocol:**

```bash
# Step 1: Perform exhaustive analysis of current broken state
exhaustive_file_analysis "api-gateway-service/app/main.py"
exhaustive_file_analysis "mcp-config-local.json"
exhaustive_directory_analysis "api-gateway-service/app"

# Step 2: Score recovery candidates
score_recovery_candidates

# Step 3: Perform comparative analysis between current and best candidate
comparative_content_analysis "api-gateway-service/app/main.py" "HEAD" "best-candidate-commit-hash"

# Step 4: Perform exhaustive diff analysis
exhaustive_diff_analysis "HEAD" "best-candidate-commit-hash"

# Step 5: Use results to guide surgical recovery using git-emergency-data-recovery.md
```

**ENFORCEMENT:** This exhaustive analysis protocol MUST be used before any recovery operations to ensure complete understanding of code state differences and optimal recovery decisions.