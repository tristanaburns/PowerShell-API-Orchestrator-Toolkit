# INSXApiService.ps1
# Interface for NSX-T API operations abstraction layer

<#
.SYNOPSIS
    Interface for NSX-T API operations services.

.DESCRIPTION
    Defines the contract for NSX-T API operations, providing abstraction over
    NSX-T REST API calls with retry, circuit breaker, and error handling capabilities.
    
    SOLID Principles Applied:
    - Single Responsibility: Only handles NSX-T API operations
    - Interface Segregation: Clean contract for API operations
    - Dependency Inversion: Abstract interface for concrete implementations
#>

# NSX API Service Interface Contract
<#
    NSX API Service Implementation Contract:
    
    Core API Operations:
    
    [object] Get([string]$endpoint)
        - Executes HTTP GET request to specified endpoint
        
    [object] Post([string]$endpoint, [object]$body)
        - Executes HTTP POST request with body to specified endpoint
        
    [object] Put([string]$endpoint, [object]$body)
        - Executes HTTP PUT request with body to specified endpoint
        
    [object] Patch([string]$endpoint, [object]$body)
        - Executes HTTP PATCH request with body to specified endpoint
        
    [bool] Delete([string]$endpoint)
        - Executes HTTP DELETE request to specified endpoint
    
    Specialized NSX-T Operations:
    
    [object] GetDomains()
        - Retrieves all security domains from NSX-T
        
    [object] GetGroups([string]$domain)
        - Retrieves all groups from specified domain
        
    [object] CreateGroup([string]$domain, [object]$groupConfig)
        - Creates new group in specified domain with configuration
        
    [object] GetSecurityPolicies([string]$domain)
        - Retrieves all security policies from specified domain
        
    [object] CreateSecurityPolicy([string]$domain, [object]$policyConfig)
        - Creates new security policy in specified domain with configuration
        
    [object] GetServices()
        - Retrieves all services from NSX-T
        
    [object] CreateService([object]$serviceConfig)
        - Creates new service with specified configuration
    
    Configuration and Health Operations:
    
    [object] GetNodeInfo()
        - Retrieves NSX-T node information
        
    [bool] TestConnection()
        - Tests connection to NSX-T manager
        
    [string] GetApiVersion()
        - Gets current NSX-T API version
        
    [object] ExecuteBatch([array]$operations)
        - Executes batch of operations in single transaction
    
    Error Handling and Retry Configuration:
    
    [void] SetRetryPolicy([int]$maxRetries, [int]$delayMs)
        - Configures retry policy for failed requests
        
    [void] SetCircuitBreakerPolicy([int]$failureThreshold, [int]$timeoutMs)
        - Configures circuit breaker policy for service protection
        
    [void] ResetCircuitBreaker()
        - Resets circuit breaker to closed state
#>
