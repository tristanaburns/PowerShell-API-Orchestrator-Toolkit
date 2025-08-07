@{
    # PSScriptAnalyzer settings for PowerShell API Orchestrator Toolkit
    # This configuration excludes rules that are intentionally violated for CLI tools
    
    # Exclude Write-Host rule - appropriate for CLI tools requiring colored console output
    ExcludeRules = @(
        'PSAvoidUsingWriteHost'
    )
    
    # Severity levels to check
    Severity = @(
        'Error',
        'Warning',
        'Information'
    )
    
    # Include default rules except those explicitly excluded
    IncludeDefaultRules = $true
    
    # Custom rule configuration
    Rules = @{
        # Allow Write-Host in CLI tools and interactive scripts
        PSAvoidUsingWriteHost = @{
            # This rule is disabled for this codebase because:
            # 1. This is a CLI toolkit requiring colored console output
            # 2. Write-Host is appropriate for user-facing command-line tools
            # 3. Tools in the tools/ directory need direct console interaction
            Enable = $false
        }
    }
}