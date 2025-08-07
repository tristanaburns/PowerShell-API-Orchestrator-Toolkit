# PowerShell Script Analyzer Remediation Plan

## Executive Summary

Analyzed the NSX PowerShell Toolkit codebase for PSUseSingularNouns and PSUseApprovedVerbs violations:
- **PSUseSingularNouns Violations**: 33 instances (26 HIGH risk, 2 MEDIUM risk, 5 LOW risk)
- **PSUseApprovedVerbs Violations**: 13 instances (4 HIGH risk, 2 MEDIUM risk, 7 LOW risk)

## Violation Details

### PSUseSingularNouns Violations (33 instances)

#### HIGH RISK - Public API Functions (26 instances)
These are functions exposed in public tools that external scripts may depend on. Renaming these carries the highest risk of breaking external dependencies.

| File | Function Name | Suggested Name | Risk Assessment |
|------|--------------|----------------|-----------------|
| tools\NSXConfigReset.ps1 | Get-ManagerCredentials | Get-ManagerCredential | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Get-SyncManagerCredentials | Get-SyncManagerCredential | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Add-StandardCredentialParams | Add-StandardCredentialParam | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Get-ConsolidatedResourceTypes | Get-ConsolidatedResourceType | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Merge-ConfigurationObjects | Merge-ConfigurationObject | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Get-ExportResourceTypes | Get-ExportResourceType | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Get-ImportResourceTypes | Get-ImportResourceType | HIGH - Public tool function |
| tools\NSXConfigSync-v2.ps1 | Filter-ConfigurationByResourceTypes | Filter-ConfigurationByResourceType | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Get-SyncManagerCredentials | Get-SyncManagerCredential | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Add-StandardCredentialParams | Add-StandardCredentialParam | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Get-ConsolidatedResourceTypes | Get-ConsolidatedResourceType | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Merge-ConfigurationObjects | Merge-ConfigurationObject | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Get-ExportResourceTypes | Get-ExportResourceType | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Get-ImportResourceTypes | Get-ImportResourceType | HIGH - Public tool function |
| tools\NSXConfigSync.ps1 | Filter-ConfigurationByResourceTypes | Filter-ConfigurationByResourceType | HIGH - Public tool function |
| tools\NSXConnectionDiagnostics.ps1 | Test-StoredCredentials | Test-StoredCredential | HIGH - Public tool function |
| tools\NSXConnectionDiagnostics.ps1 | Repair-Credentials | Repair-Credential | HIGH - Public tool function |
| tools\NSXConnectionDiagnostics.ps1 | Start-ComprehensiveDiagnostics | Start-ComprehensiveDiagnostic | HIGH - Public tool function |
| tools\NSXConnectionTest.ps1 | Get-NSXEndpointDefinitions | Get-NSXEndpointDefinition | HIGH - Public tool function |
| tools\NSXConnectionTest.ps1 | Get-ComprehensiveNSXEndpoints | Get-ComprehensiveNSXEndpoint | HIGH - Public tool function |
| tools\NSXConnectionTest.ps1 | Save-ValidatedEndpointsForTools | Save-ValidatedEndpointForTool | HIGH - Public tool function |
| tools\NSXConnectionTest.ps1 | Assert-NSXToolkitPrerequisites | Assert-NSXToolkitPrerequisite | HIGH - Public tool function |
| tools\NSXCredentialManager.ps1 | Show-StoredCredentials | Show-StoredCredential | HIGH - Public tool function |
| tools\VerifyNSXConfiguration.ps1 | Test-ConfigurationFiles | Test-ConfigurationFile | HIGH - Public tool function |
| src\services\StandardToolTemplate.ps1 | Initialize-StandardServices | Initialize-StandardService | HIGH - Exported service function |
| src\services\StandardToolTemplate.ps1 | Get-StandardCredentials | Get-StandardCredential | HIGH - Exported service function |

#### MEDIUM RISK - Internal Service Functions (2 instances)
These are parse errors, not actual function name violations:
- src\services\NSXAPIService.ps1 (Line 5) - TypeNotFound parse error
- src\services\WorkflowOperationsService.ps1 (Line 1012) - TypeNotFound parse error

#### LOW RISK - Internal Utility Functions (5 instances)
These are internal helper functions with limited scope:

| File | Function Name | Suggested Name |
|------|--------------|----------------|
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-CmdletAliases | Fix-CmdletAlias |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-UnusedVariables | Fix-UnusedVariable |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-UnapprovedVerbs | Fix-UnapprovedVerb |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-PluralNouns | Fix-PluralNoun |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-MandatoryParameterDefaults | Fix-MandatoryParameterDefault |

### PSUseApprovedVerbs Violations (13 instances)

#### HIGH RISK - Public API Functions (4 instances)

| File | Function Name | Current Verb | Suggested Verb | Suggested Name |
|------|--------------|--------------|----------------|----------------|
| tools\NSXConfigSync-v2.ps1 | Filter-ConfigurationByResourceTypes | Filter | Select | Select-ConfigurationByResourceType |
| tools\NSXConfigSync-v2.ps1 | Filter-ConfigurationByDomain | Filter | Select | Select-ConfigurationByDomain |
| tools\NSXConfigSync.ps1 | Filter-ConfigurationByResourceTypes | Filter | Select | Select-ConfigurationByResourceType |
| tools\NSXConfigSync.ps1 | Filter-ConfigurationByDomain | Filter | Select | Select-ConfigurationByDomain |

#### MEDIUM RISK - Internal Service Functions (2 instances)
These are parse errors, not actual verb violations:
- src\services\NSXAPIService.ps1 (Line 5) - TypeNotFound parse error
- src\services\WorkflowOperationsService.ps1 (Line 1012) - TypeNotFound parse error

#### LOW RISK - Internal Utility Functions (7 instances)

| File | Function Name | Current Verb | Suggested Verb | Suggested Name |
|------|--------------|--------------|----------------|----------------|
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-WriteHost | Fix | Repair | Repair-WriteHost |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-CmdletAliases | Fix | Repair | Repair-CmdletAlias |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-UnusedVariables | Fix | Repair | Repair-UnusedVariable |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-PlainTextPassword | Fix | Repair | Repair-PlainTextPassword |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-ConvertToSecureString | Fix | Repair | Repair-ConvertToSecureString |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-UnapprovedVerbs | Fix | Repair | Repair-UnapprovedVerb |
| src\utilities\PSScriptAnalyzerUtility.ps1 | Fix-PluralNouns | Fix | Repair | Repair-PluralNoun |

## Prioritized Remediation Plan

### Phase 1: LOW RISK - Internal Utilities (Immediate)
**Target Files**: src\utilities\PSScriptAnalyzerUtility.ps1

**Actions**:
1. Rename all Fix-* functions to Repair-* (approved verb)
2. Convert all plural nouns to singular
3. Update all internal references within the same file
4. Test the utility functions in isolation

**Functions to Rename**:
- Fix-WriteHost → Repair-WriteHost
- Fix-CmdletAliases → Repair-CmdletAlias
- Fix-UnusedVariables → Repair-UnusedVariable
- Fix-PlainTextPassword → Repair-PlainTextPassword
- Fix-ConvertToSecureString → Repair-ConvertToSecureString
- Fix-UnapprovedVerbs → Repair-UnapprovedVerb
- Fix-PluralNouns → Repair-PluralNoun
- Fix-MandatoryParameterDefaults → Repair-MandatoryParameterDefault

### Phase 2: MEDIUM RISK - Address Parse Errors (Immediate)
**Target Files**: 
- src\services\NSXAPIService.ps1
- src\services\WorkflowOperationsService.ps1

**Actions**:
1. Investigate and resolve TypeNotFound parse errors
2. Ensure proper class/type definitions are available at parse time
3. Consider using explicit type imports or module dependencies

### Phase 3: HIGH RISK - Evaluation Required (Deferred)
**Target Files**: All tools\*.ps1 files and exported service functions

**Recommended Approach**:
1. **Create Wrapper Functions**: Instead of directly renaming high-risk functions, create new compliant wrapper functions that call the existing ones
2. **Deprecation Strategy**: Mark old functions as deprecated but keep them functional
3. **Gradual Migration**: Update internal calls to use new names while maintaining backward compatibility

**Example Wrapper Implementation**:
```powershell
# New compliant function
function Get-ManagerCredential {
    [CmdletBinding()]
    param($Manager, $NSXManager)
    
    # Call the existing function for backward compatibility
    Get-ManagerCredentials @PSBoundParameters
}

# Mark old function as deprecated
function Get-ManagerCredentials {
    [CmdletBinding()]
    [Obsolete("This function is deprecated. Use Get-ManagerCredential instead.")]
    param($Manager, $NSXManager)
    
    # Existing implementation...
}
```

### Phase 4: Documentation and Communication
1. Document all function renames in release notes
2. Create migration guide for external scripts
3. Update all internal documentation
4. Consider semantic versioning (major version bump for breaking changes)

## Risk Mitigation Strategies

### For HIGH RISK Functions:
1. **Maintain Backward Compatibility**: Keep old function names as aliases or wrappers
2. **Deprecation Warnings**: Add warnings when old functions are called
3. **Grace Period**: Allow 2-3 release cycles before removing deprecated functions
4. **External Communication**: Notify users of upcoming changes in advance

### For MEDIUM RISK Functions:
1. **Search Entire Codebase**: Use grep/search to find all references
2. **Update Cross-File References**: Ensure all calls are updated
3. **Test Integration**: Run full integration tests after changes

### For LOW RISK Functions:
1. **Direct Rename**: Safe to rename immediately
2. **Local Testing**: Test within the file scope
3. **Update Comments**: Ensure documentation matches new names

## Verification Steps

After each phase:
1. Run PSScriptAnalyzer to verify violations are resolved
2. Execute all affected scripts to ensure functionality
3. Run integration tests if available
4. Check for any broken references using grep/search

## Recommended Execution Order

1. **Week 1**: Complete Phase 1 (LOW RISK) and Phase 2 (Parse Errors)
2. **Week 2**: Plan and implement wrapper functions for Phase 3
3. **Week 3**: Test and document changes
4. **Week 4**: Communicate changes and prepare for release

## Alternative Approach: Suppression

For functions that cannot be renamed due to external dependencies, consider using suppression:

```powershell
function Get-ManagerCredentials {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseSingularNouns', '')]
    [CmdletBinding()]
    param(...)
    # Implementation
}
```

## Conclusion

The codebase has 46 total violations, with the majority being naming convention issues in public tool functions. The recommended approach is to:
1. Fix low-risk internal functions immediately
2. Resolve parse errors
3. Implement a backward-compatible migration strategy for high-risk public functions
4. Use suppression for functions that absolutely cannot be changed

This phased approach minimizes breaking changes while gradually improving code compliance with PowerShell best practices.