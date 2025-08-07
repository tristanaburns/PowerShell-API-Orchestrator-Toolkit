# IUniversalApiService.ps1
# Interface for API operations abstraction layer

<#
.SYNOPSIS
    Interface for API operations services.

.DESCRIPTION
    Defines the contract for API operations, providing abstraction over
    REST API calls with retry, circuit breaker, and error handling capabilities.

    SOLID Principles Applied:
    - Single Responsibility: Only handles API operations
    - Interface Segregation: contract for API operations
    - Dependency Inversion: Abstract interface for concrete implementations
#>

# API Service Interface Contract
<#
    API Service Implementation Contract:

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

    Specialized API Operations:

    [object] GetDomains()
        - Retrieves all domains from API

    [object] GetGroups([string]$domain)
        - Retrieves all groups from specified domain

    [object] CreateGroup([string]$domain, [object]$groupConfig)
        - Creates new group in specified domain with configuration

    [object] GetSecurityPolicies([string]$domain)
        - Retrieves all security policies from specified domain

    [object] CreateSecurityPolicy([string]$domain, [object]$policyConfig)
        - Creates new security policy in specified domain with configuration

    [object] GetServices()
        - Retrieves all services from API

    [object] CreateService([object]$serviceConfig)
        - Creates new service with specified configuration

    Configuration and Health Operations:

    [object] GetNodeInfo()
        - Retrieves API endpoint information

    [bool] TestConnection()
        - Tests connection to API endpoint

    [string] GetApiVersion()
        - Gets current API version

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