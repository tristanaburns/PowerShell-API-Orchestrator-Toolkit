# IAuthenticationService.ps1
# Interface for NSX authentication management following Single Responsibility Principle

<#
.SYNOPSIS
    Interface for NSX authentication services.

.DESCRIPTION
    Defines the contract for NSX authentication operations, separating concerns from
    the original monolithic Set-NSX-Credentials function.

    SOLID Principles Applied:
    - Single Responsibility: Only handles authentication operations
    - Interface Segregation: Clean contract without optional parameters
    - Dependency Inversion: Abstract interface for concrete implementations
#>

# Authentication Service Interface Contract
<#
    Authentication Service Implementation Contract:
    
    Implementations should provide the following methods:
    
    [PSCredential] CollectCredentials([string]$nsxManager)
        - Collects credentials for a specific NSX manager
        
    [bool] ValidateCredentials([string]$nsxManager, [PSCredential]$credentials)
        - Validates credentials against NSX manager
        
    [void] StoreCredentials([string]$nsxManager, [PSCredential]$credentials)
        - Stores credentials securely for reuse
        
    [PSCredential] GetCredentials([string]$nsxManager)
        - Retrieves stored credentials for NSX manager
        
    [void] ClearCredentials([string]$nsxManager)
        - Removes stored credentials for NSX manager
        
    [bool] HasCredentials([string]$nsxManager)
        - Checks if credentials exist for NSX manager
        
    [void] ClearAllCredentials()
        - Clears all stored credentials and session tokens
#>

# Credential Validation Interface Contract
<#
    Credential Validator Implementation Contract:
    
    [bool] IsValidCredential([PSCredential]$credential)
        - Validates credential format and requirements
        
    [bool] TestConnection([string]$nsxManager, [PSCredential]$credential)
        - Tests credentials against NSX manager endpoint
#>

# NSX Manager Name Service Interface Contract
<#
    NSX Manager Name Service Implementation Contract:
    
    [string] GetStandardisedName([string]$nsxManager)
        - Standardizes NSX manager names for consistent storage
        
    [bool] IsValidManager([string]$nsxManager)
        - Validates NSX manager address format
        
    [string] GetAddressType([string]$nsxManager)
        - Determines if address is IP or FQDN
#>
