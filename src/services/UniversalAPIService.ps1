# UniversalAPIService.ps1
# API service with hierarchical API support extending CoreAPIService
# Generic functionality for any REST API with bulk operations

# Ensure CoreAPIService is defined or imported before this class
if (-not ('CoreAPIService' -as [type])) {
    . "$PSScriptRoot\CoreAPIService.ps1"
    if (-not ('CoreAPIService' -as [type])) {
        throw "CoreAPIService class could not be loaded. Please ensure CoreAPIService.ps1 defines the class."
    }
}

class UniversalAPIService : CoreAPIService {
    [string]$APIEndpoint

    UniversalAPIService([string] $apiEndpoint, [object] $loggingService, [object] $authService, [object] $configService) : base($loggingService, $authService, $configService) {
        $this.APIEndpoint = $apiEndpoint
        $this.logger.LogInfo("API Service initialised with hierarchical support", "UniversalAPI")
        $this.logger.LogInfo("API Endpoint: $apiEndpoint", "UniversalAPI")
    }

    # DEDUPLICATION FIX: Implement Universal_REST_Core using inherited CoreAPIService.InvokeRestMethod
    [object] Universal_REST_Core([string] $urlbase, [string] $urlpath, [string] $method, [string] $contenttype, [object] $body) {
        try {
            # Build the full endpoint path
            $endpoint = "/$urlbase/$urlpath"
            $endpoint = $endpoint -replace '/+', '/'  # Remove duplicate slashes

            # Get current credentials from auth service
            $credential = $this.authService.GetCredential($this.APIEndpoint)

            # Use inherited InvokeRestMethod to eliminate duplication
            return $this.InvokeRestMethod($this.APIEndpoint, $credential, $endpoint, $method, $body)

        }
        catch {
            $this.logger.LogError("Universal_REST_Core failed: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # DEDUPLICATION FIX: Consolidated authentication header method
    [object] GetAuthHeaders() {
        try {
            $credential = $this.authService.GetCredential($this.APIEndpoint)
            $useCurrentUser = ($credential.GetNetworkCredential().Password -eq "CURRENT_USER_CONTEXT")

            if ($useCurrentUser) {
                return @{
                    'Content-Type' = 'application/json'
                    'Accept'       = 'application/json'
                }
            }
            else {
                $authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($credential.UserName):$($credential.GetNetworkCredential().Password)"))
                return @{
                    'Authorization' = $authHeader
                    'Content-Type'  = 'application/json'
                    'Accept'        = 'application/json'
                }
            }
        }
        catch {
            $this.logger.LogError("Failed to get authentication headers: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    #region URL Building Helpers - DEDUPLICATION FIX

    # Generic endpoint builder for various API types
    [object] GetAPIEndpoints([string] $apiEndpoint, [string] $resourceType, [string] $domainId = "default") {
        $domains = $this.GetDomains($apiEndpoint)
        $isHierarchical = $this.IsHierarchicalEnvironment($domains)
        $this.logger.LogInfo("API structure for $apiEndpoint : Hierarchical=$isHierarchical, Domains=$($domains.results.Count)", "UniversalAPI")

        $endpoints = [PSCustomObject]@{}

        if ($isHierarchical) {
            switch ($resourceType) {
                "services" {
                    $endpoints.urlbase = "global-manager/api/v1"
                    $endpoints.urlpath = "global-infra/services"
                }
                "groups" {
                    $endpoints.urlbase = "global-manager/api/v1"
                    $endpoints.urlpath = "global-infra/domains/$domainId/groups"
                }
                "security-policies" {
                    $endpoints.urlbase = "global-manager/api/v1"
                    $endpoints.urlpath = "global-infra/domains/$domainId/security-policies"
                }
                "context-profiles" {
                    $endpoints.urlbase = "global-manager/api/v1"
                    $endpoints.urlpath = "global-infra/context-profiles"
                }
                "domains" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "global-infra/domains"
                }
                "deployment" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "global-infra"
                }
                default {
                    throw "Unknown resource type: $resourceType"
                }
            }
        }
        else {
            switch ($resourceType) {
                "services" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "infra/services"
                }
                "groups" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "infra/domains/$domainId/groups"
                }
                "security-policies" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "infra/domains/$domainId/security-policies"
                }
                "context-profiles" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "infra/context-profiles"
                }
                "domains" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "infra/domains"
                }
                "deployment" {
                    $endpoints.urlbase = "policy/api/v1"
                    $endpoints.urlpath = "infra"
                }
                default {
                    throw "Unknown resource type: $resourceType"
                }
            }
        }

        $endpoints.fullUrl = "https://$apiEndpoint/$($endpoints.urlbase)/$($endpoints.urlpath)"
        return $endpoints
    }

    #endregion

    # Deploy hierarchical configuration using PATCH for endpoints (legacy method)
    [bool] DeployHierarchicalConfiguration([string] $apiEndpoint, [string] $jsonPayload) {
        return $this.DeployHierarchicalConfiguration($apiEndpoint, $jsonPayload, "PATCH")
    }

    # Deploy hierarchical configuration with configurable HTTP method
    [bool] DeployHierarchicalConfiguration([string] $apiEndpoint, [string] $jsonPayload, [string] $httpMethod) {
        $this.logger.LogInfo("Starting hierarchical configuration deployment", "UniversalAPI")
        $this.logger.LogInfo("Target API Endpoint: $apiEndpoint", "UniversalAPI")
        $this.logger.LogInfo("HTTP Method: $httpMethod", "UniversalAPI")
        $this.logger.LogInfo("Payload Size: $($jsonPayload.Length) characters", "UniversalAPI")
        $this.logger.LogInfo("Deploying hierarchical configuration to API endpoint: $apiEndpoint", "UniversalAPI")

        try {
            # Determine if this is a hierarchical environment
            $this.logger.LogInfo("Checking API structure and domains", "UniversalAPI")
            $domains = $this.GetDomains($apiEndpoint)
            $isHierarchical = $this.IsHierarchicalEnvironment($domains)
            $this.logger.LogInfo("API structure for $apiEndpoint : Hierarchical=$isHierarchical, Domains=$($domains.results.Count)", "UniversalAPI")

            # For endpoint-to-endpoint testing, prefer standard endpoints
            if ($isHierarchical) {
                $urlbase = "policy/api/v1"
                $urlpath = "global-infra"
                $this.logger.LogInfo("Using hierarchical endpoint for deployment", "UniversalAPI")
            }
            else {
                $urlbase = "policy/api/v1"
                $urlpath = "infra"
                $this.logger.LogInfo("Using standard endpoint for deployment", "UniversalAPI")
            }

            $fullUrl = "https://$apiEndpoint/$urlbase/$urlpath"
            $this.logger.LogInfo("Deployment endpoint: $fullUrl")
            $this.logger.LogDebug("Deployment endpoint: $urlbase/$urlpath", "UniversalAPI")

            # Log the API call start with full details
            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest($httpMethod, $fullUrl, $headers, $jsonPayload)

            $result = $this.Universal_REST_Core($urlbase, $urlpath, $httpMethod, "application/json", $jsonPayload)

            if ($result) {
                $this.logger.LogAPIResponse($httpMethod, $fullUrl, 200, $result)
                $this.logger.LogInfo("Hierarchical configuration deployed successfully")
                $this.logger.LogInfo("Hierarchical configuration deployed successfully to $apiEndpoint", "UniversalAPI")
                return $true
            }
            else {
                $this.logger.LogInfo("Deployment returned null result - may indicate success for $httpMethod operations")
                $this.logger.LogWarning("Deployment returned null result", "UniversalAPI")
                return $false
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Deploy hierarchical configuration")
            $this.logger.LogError("Failed to deploy hierarchical configuration to $apiEndpoint : $($_.Exception.Message)", "UniversalAPI", $_.Exception)

            return $false
        }
    }

    # Get all services from API endpoint - DEDUPLICATION FIX
    [object] GetServices([string] $apiEndpoint) {
        $this.logger.LogInfo("Retrieving services from API endpoint: $apiEndpoint")

        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetAPIEndpoints($apiEndpoint, "services")
            $this.logger.LogInfo("Service retrieval endpoint: $($endpoints.fullUrl)")

            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest("GET", $endpoints.fullUrl, $headers, $null)

            $result = $this.Universal_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)

            if ($result -and $result.results) {
                $this.logger.LogAPIResponse("GET", $endpoints.fullUrl, 200, $result)
                $this.logger.LogInfo("Retrieved $($result.results.Count) services from API endpoint $apiEndpoint", "UniversalAPI")
                return $result
            }
            else {
                $this.logger.LogInfo("No services found or empty response")
                return $result
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Get services")
            $this.logger.LogError("Failed to retrieve services: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # Get all groups from API endpoint - DEDUPLICATION FIX
    [object] GetGroups([string] $apiEndpoint, [string] $domainId = "default") {
        $this.logger.LogInfo("Retrieving groups from API endpoint: $apiEndpoint, Domain: $domainId")

        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetAPIEndpoints($apiEndpoint, "groups", $domainId)
            $this.logger.LogInfo("Groups retrieval endpoint: $($endpoints.fullUrl)")

            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest("GET", $endpoints.fullUrl, $headers, $null)

            $result = $this.Universal_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)

            if ($result -and $result.results) {
                $this.logger.LogAPIResponse("GET", $endpoints.fullUrl, 200, $result)
                $this.logger.LogInfo("Retrieved $($result.results.Count) groups from API endpoint $apiEndpoint", "UniversalAPI")
                return $result
            }
            else {
                $this.logger.LogInfo("No groups found or empty response")
                return $result
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Get groups")
            $this.logger.LogError("Failed to retrieve groups: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # Get all security policies from API endpoint - DEDUPLICATION FIX
    [object] GetSecurityPolicies([string] $apiEndpoint, [string] $domainId = "default") {
        $this.logger.LogInfo("Retrieving security policies from API endpoint: $apiEndpoint, Domain: $domainId")

        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetAPIEndpoints($apiEndpoint, "security-policies", $domainId)
            $this.logger.LogInfo("Security policies retrieval endpoint: $($endpoints.fullUrl)")

            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest("GET", $endpoints.fullUrl, $headers, $null)

            $result = $this.Universal_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)

            if ($result -and $result.results) {
                $this.logger.LogAPIResponse("GET", $endpoints.fullUrl, 200, $result)
                $this.logger.LogInfo("Retrieved $($result.results.Count) security policies from API endpoint $apiEndpoint", "UniversalAPI")
                return $result
            }
            else {
                $this.logger.LogInfo("No security policies found or empty response")
                return $result
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Get security policies")
            $this.logger.LogError("Failed to retrieve security policies: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # Get all context profiles from API endpoint - DEDUPLICATION FIX
    [object] GetContextProfiles([string] $apiEndpoint, [string] $domainId = "default") {
        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetAPIEndpoints($apiEndpoint, "context-profiles", $domainId)

            $result = $this.Universal_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)
            $this.logger.LogInfo("Retrieved context profiles from API endpoint", "UniversalAPI")
            return $result

        }
        catch {
            $this.logger.LogError("Failed to retrieve context profiles: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # Get domains from API endpoint 
    [object] GetDomains([string] $apiEndpoint) {
        $this.logger.LogInfo("Determining API endpoint type and retrieving domains from: $apiEndpoint", "UniversalAPI")

        try {
            # For endpoint-to-endpoint testing, start with standard endpoint check
            $this.logger.LogDebug("Checking if API endpoint is standard", "UniversalAPI")

            try {
                $urlbase = "policy/api/v1"
                $urlpath = "infra/domains"
                $result = $this.Universal_REST_Core($urlbase, $urlpath, "GET", "application/json", $null)

                if ($result -and $result.results) {
                    $this.logger.LogInfo("API endpoint is a standard endpoint with $($result.results.Count) domains", "UniversalAPI")
                    return $result
                }
            }
            catch {
                $this.logger.LogDebug("Not a standard endpoint: $($_.Exception.Message)", "UniversalAPI")
            }

            # Try hierarchical endpoint next
            $this.logger.LogDebug("Checking if API endpoint is hierarchical", "UniversalAPI")

            try {
                $urlbase = "policy/api/v1"
                $urlpath = "global-infra/domains"
                $result = $this.Universal_REST_Core($urlbase, $urlpath, "GET", "application/json", $null)

                if ($result -and $result.results) {
                    $this.logger.LogInfo("API endpoint is hierarchical with $($result.results.Count) domains", "UniversalAPI")
                    return $result
                }
            }
            catch {
                $this.logger.LogDebug("Not a hierarchical endpoint: $($_.Exception.Message)", "UniversalAPI")
            }

            # Try global manager pattern last
            $this.logger.LogDebug("Checking if API endpoint is a global manager", "UniversalAPI")

            try {
                $urlbase = "global-manager/api/v1"
                $urlpath = "global-infra/domains"
                $result = $this.Universal_REST_Core($urlbase, $urlpath, "GET", "application/json", $null)

                if ($result -and $result.results) {
                    $this.logger.LogInfo("API endpoint is a global manager with $($result.results.Count) domains", "UniversalAPI")
                    return $result
                }
            }
            catch {
                $this.logger.LogDebug("Not a global manager: $($_.Exception.Message)", "UniversalAPI")
            }

            # If all attempts failed, create a default domain response for testing
            $this.logger.LogWarning("Unable to retrieve domains from any endpoint, creating default domain", "UniversalAPI")
            $defaultDomains = [PSCustomObject]@{
                results      = @(
                    @{
                        id            = "default"
                        display_name  = "default"
                        resource_type = "Domain"
                    }
                )
                result_count = 1
            }

            return $defaultDomains

        }
        catch {
            $this.logger.LogError("Failed to get domains from $apiEndpoint : $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # Check if environment is hierarchical
    [bool] IsHierarchicalEnvironment([object] $domains) {
        # If we can get domains from global-infra endpoints, it's hierarchical
        # This is a simplified check - you might want to enhance this based on your specific needs
        return $domains -and $domains.results -and $domains.results.Count -gt 0
    }

    #endregion

    #region Bulk Operations

    # Create multiple objects in a single hierarchical call
    [bool] BulkCreateObjects([object] $configuration) {
        try {
            $jsonPayload = $configuration | ConvertTo-Json -Depth 20 -Compress
            return $this.DeployHierarchicalConfiguration($this.APIEndpoint, $jsonPayload)

        }
        catch {
            $this.logger.LogError("Bulk create operation failed: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            return $false
        }
    }

    # Update multiple objects in a single hierarchical call
    [bool] BulkUpdateObjects([object] $configuration) {
        try {
            $jsonPayload = $configuration | ConvertTo-Json -Depth 20 -Compress
            return $this.DeployHierarchicalConfiguration($this.APIEndpoint, $jsonPayload)

        }
        catch {
            $this.logger.LogError("Bulk update operation failed: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            return $false
        }
    }

    #endregion

    #region Migration Helpers

    # Export entire configuration in hierarchical format
    [object] ExportHierarchicalConfiguration([string] $domainId = "default") {
        try {
            $this.logger.LogInfo("Exporting hierarchical configuration", "UniversalAPI")

            # Create hierarchical structure
            $config = [ordered]@{
                resource_type = "Infra"
                children      = @()
            }

            # Get services
            $services = $this.GetServices($this.APIEndpoint)
            foreach ($service in $services.results) {
                $childService = [ordered]@{
                    resource_type = "ChildService"
                    Service       = [ordered]@{
                        resource_type     = "Service"
                        marked_for_delete = "False"
                        id                = $service.id
                        display_name      = $service.display_name
                        description       = $service.description
                        service_entries   = $service.service_entries
                    }
                }
                $config.children += $childService
            }

            # Create domain reference
            $domainRef = [ordered]@{
                resource_type = "ChildResourceReference"
                target_type   = "Domain"
                id            = $domainId
                children      = @()
            }

            # Get groups
            $groups = $this.GetGroups($this.APIEndpoint, $domainId)
            foreach ($group in $groups.results) {
                $childGroup = [ordered]@{
                    resource_type = "ChildGroup"
                    Group         = [ordered]@{
                        resource_type     = "Group"
                        marked_for_delete = "False"
                        id                = $group.id
                        display_name      = $group.display_name
                        description       = $group.description
                        expression        = $group.expression
                    }
                }
                $domainRef.children += $childGroup
            }

            # Get security policies
            $policies = $this.GetSecurityPolicies($this.APIEndpoint, $domainId)
            foreach ($policy in $policies.results) {
                $childPolicy = [ordered]@{
                    resource_type  = "ChildSecurityPolicy"
                    SecurityPolicy = [ordered]@{
                        resource_type   = "SecurityPolicy"
                        id              = $policy.id
                        display_name    = $policy.display_name
                        description     = $policy.description
                        category        = $policy.category
                        sequence_number = $policy.sequence_number
                        scope           = $policy.scope
                        stateful        = $policy.stateful
                        tcp_strict      = $policy.tcp_strict
                        rules           = $policy.rules
                    }
                }
                $domainRef.children += $childPolicy
            }

            # Add domain reference if it has children
            if ($domainRef.children.Count -gt 0) {
                $config.children += $domainRef
            }

            $this.logger.LogInfo("Hierarchical configuration exported successfully", "UniversalAPI")
            return $config

        }
        catch {
            $this.logger.LogError("Failed to export hierarchical configuration: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            throw
        }
    }

    # Import hierarchical configuration from another API endpoint
    [bool] ImportHierarchicalConfiguration([string] $sourceAPIEndpoint, [string] $targetDomainId = "default") {
        try {
            $this.logger.LogInfo("Importing hierarchical configuration from: $sourceAPIEndpoint", "UniversalAPI")

            # Create temporary service instance for source
            $sourceService = [UniversalAPIService]::new($sourceAPIEndpoint, $this.logger, $this.authService, $this.configService)

            # Export from source
            $config = $sourceService.ExportHierarchicalConfiguration($targetDomainId)

            # Import to current (target) endpoint
            $result = $this.BulkCreateObjects($config)

            if ($result) {
                $this.logger.LogInfo("Hierarchical configuration imported successfully", "UniversalAPI")
            }
            else {
                $this.logger.LogError("Failed to import hierarchical configuration", "UniversalAPI")
            }

            return $result

        }
        catch {
            $this.logger.LogError("Import operation failed: $($_.Exception.Message)", "UniversalAPI", $_.Exception)
            return $false
        }
    }

    #endregion
}