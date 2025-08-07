# NSXAPIService.ps1
# NSX API service with hierarchical API support extending CoreAPIService
# Functionality with bulk operations

class NSXAPIService : CoreAPIService {
    [string]$NSXManager

    NSXAPIService([string] $nsxManager, [object] $loggingService, [object] $authService, [object] $configService) : base($loggingService, $authService, $configService) {
        $this.NSXManager = $nsxManager
        $this.logger.LogInfo("NSX API Service initialised with hierarchical support", "NSXAPI")
        $this.logger.LogInfo("NSX Manager: $nsxManager", "NSXAPI")
        $this.logger.LogInfo("NSX API Service initialised with hierarchical support", "NSXAPI")
    }

    # DEDUPLICATION FIX: Implement NSX_REST_Core using inherited CoreAPIService.InvokeRestMethod
    [object] NSX_REST_Core([string] $urlbase, [string] $urlpath, [string] $method, [string] $contenttype, [object] $body) {
        try {
            # Build the full endpoint path
            $endpoint = "/$urlbase/$urlpath"
            $endpoint = $endpoint -replace '/+', '/'  # Remove duplicate slashes

            # Get current credentials from auth service
            $credential = $this.authService.GetCredential($this.NSXManager)

            # Use inherited InvokeRestMethod to eliminate duplication
            return $this.InvokeRestMethod($this.NSXManager, $credential, $endpoint, $method, $body)

        }
        catch {
            $this.logger.LogError("NSX_REST_Core failed: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # DEDUPLICATION FIX: Consolidated authentication header method
    [object] GetAuthHeaders() {
        try {
            $credential = $this.authService.GetCredential($this.NSXManager)
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
            $this.logger.LogError("Failed to get authentication headers: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    #region URL Building Helpers - DEDUPLICATION FIX

    # Consolidated URL building method to eliminate duplication
    [object] GetNSXEndpoints([string] $nsxManager, [string] $resourceType, [string] $domainId = "default") {
        $domains = $this.GetDomains($nsxManager)
        $isFederated = $this.IsFederatedEnvironment($domains)
        $this.logger.LogInfo("Federation status for $nsxManager : Federated=$isFederated, Domains=$($domains.results.Count)", "NSXAPI")

        $endpoints = [PSCustomObject]@{}

        if ($isFederated) {
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

        $endpoints.fullUrl = "https://$nsxManager/$($endpoints.urlbase)/$($endpoints.urlpath)"
        return $endpoints
    }

    #endregion

    # Deploy hierarchical configuration using PATCH for local managers (legacy method)
    [bool] DeployHierarchicalConfiguration([string] $nsxManager, [string] $jsonPayload) {
        return $this.DeployHierarchicalConfiguration($nsxManager, $jsonPayload, "PATCH")
    }

    # Deploy hierarchical configuration with configurable HTTP method
    [bool] DeployHierarchicalConfiguration([string] $nsxManager, [string] $jsonPayload, [string] $httpMethod) {
        $this.logger.LogInfo("Starting hierarchical configuration deployment", "NSXAPI")
        $this.logger.LogInfo("Target NSX Manager: $nsxManager", "NSXAPI")
        $this.logger.LogInfo("HTTP Method: $httpMethod", "NSXAPI")
        $this.logger.LogInfo("Payload Size: $($jsonPayload.Length) characters", "NSXAPI")
        $this.logger.LogInfo("Deploying hierarchical configuration to local NSX manager: $nsxManager", "NSXAPI")

        try {
            # Determine if this is a federated environment
            $this.logger.LogInfo("Checking federation status and domains", "NSXAPI")
            $domains = $this.GetDomains($nsxManager)
            $isFederated = $this.IsFederatedEnvironment($domains)
            $this.logger.LogInfo("Federation status for $nsxManager : Federated=$isFederated, Domains=$($domains.results.Count)", "NSXAPI")

            # For local-to-local testing, prefer local manager endpoints
            if ($isFederated) {
                $urlbase = "policy/api/v1"
                $urlpath = "global-infra"
                $this.logger.LogInfo("Using federated local manager endpoint for deployment")
                $this.logger.LogInfo("Using federated local manager endpoint for deployment", "NSXAPI")
            }
            else {
                $urlbase = "policy/api/v1"
                $urlpath = "infra"
                $this.logger.LogInfo("Using standalone manager endpoint for deployment")
                $this.logger.LogInfo("Using standalone manager endpoint for deployment", "NSXAPI")
            }

            $fullUrl = "https://$nsxManager/$urlbase/$urlpath"
            $this.logger.LogInfo("Deployment endpoint: $fullUrl")
            $this.logger.LogDebug("Deployment endpoint: $urlbase/$urlpath", "NSXAPI")

            # Log the API call start with full details
            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest($httpMethod, $fullUrl, $headers, $jsonPayload)

            $result = $this.NSX_REST_Core($urlbase, $urlpath, $httpMethod, "application/json", $jsonPayload)

            if ($result) {
                $this.logger.LogAPIResponse($httpMethod, $fullUrl, 200, $result)
                $this.logger.LogInfo("Hierarchical configuration deployed successfully")
                $this.logger.LogInfo("Hierarchical configuration deployed successfully to $nsxManager", "NSXAPI")
                return $true
            }
            else {
                $this.logger.LogInfo("Deployment returned null result - may indicate success for $httpMethod operations")
                $this.logger.LogWarning("Deployment returned null result", "NSXAPI")
                return $false
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Deploy hierarchical configuration")
            $this.logger.LogError("Failed to deploy hierarchical configuration to $nsxManager : $($_.Exception.Message)", "NSXAPI", $_.Exception)

            return $false
        }
    }

    # Get all services from NSX manager - DEDUPLICATION FIX
    [object] GetServices([string] $nsxManager) {
        $this.logger.LogInfo("Retrieving services from NSX manager: $nsxManager")

        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetNSXEndpoints($nsxManager, "services")
            $this.logger.LogInfo("Service retrieval endpoint: $($endpoints.fullUrl)")

            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest("GET", $endpoints.fullUrl, $headers, $null)

            $result = $this.NSX_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)

            if ($result -and $result.results) {
                $this.logger.LogAPIResponse("GET", $endpoints.fullUrl, 200, $result)
                $this.logger.LogInfo("Retrieved $($result.results.Count) services from NSX manager $nsxManager", "NSXAPI")
                return $result
            }
            else {
                $this.logger.LogInfo("No services found or empty response")
                return $result
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Get services")
            $this.logger.LogError("Failed to retrieve services: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # Get all groups from NSX manager - DEDUPLICATION FIX
    [object] GetGroups([string] $nsxManager, [string] $domainId = "default") {
        $this.logger.LogInfo("Retrieving groups from NSX manager: $nsxManager, Domain: $domainId")

        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetNSXEndpoints($nsxManager, "groups", $domainId)
            $this.logger.LogInfo("Groups retrieval endpoint: $($endpoints.fullUrl)")

            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest("GET", $endpoints.fullUrl, $headers, $null)

            $result = $this.NSX_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)

            if ($result -and $result.results) {
                $this.logger.LogAPIResponse("GET", $endpoints.fullUrl, 200, $result)
                $this.logger.LogInfo("Retrieved $($result.results.Count) groups from NSX manager $nsxManager", "NSXAPI")
                return $result
            }
            else {
                $this.logger.LogInfo("No groups found or empty response")
                return $result
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Get groups")
            $this.logger.LogError("Failed to retrieve groups: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # Get all security policies from NSX manager - DEDUPLICATION FIX
    [object] GetSecurityPolicies([string] $nsxManager, [string] $domainId = "default") {
        $this.logger.LogInfo("Retrieving security policies from NSX manager: $nsxManager, Domain: $domainId")

        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetNSXEndpoints($nsxManager, "security-policies", $domainId)
            $this.logger.LogInfo("Security policies retrieval endpoint: $($endpoints.fullUrl)")

            $headers = $this.GetAuthHeaders()
            $this.logger.LogAPIRequest("GET", $endpoints.fullUrl, $headers, $null)

            $result = $this.NSX_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)

            if ($result -and $result.results) {
                $this.logger.LogAPIResponse("GET", $endpoints.fullUrl, 200, $result)
                $this.logger.LogInfo("Retrieved $($result.results.Count) security policies from NSX manager $nsxManager", "NSXAPI")
                return $result
            }
            else {
                $this.logger.LogInfo("No security policies found or empty response")
                return $result
            }

        }
        catch {
            $this.logger.LogException($_.Exception, "Get security policies")
            $this.logger.LogError("Failed to retrieve security policies: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # Get all context profiles from NSX manager - DEDUPLICATION FIX
    [object] GetContextProfiles([string] $nsxManager, [string] $domainId = "default") {
        try {
            # DEDUPLICATION FIX: Use consolidated endpoint building
            $endpoints = $this.GetNSXEndpoints($nsxManager, "context-profiles", $domainId)

            $result = $this.NSX_REST_Core($endpoints.urlbase, $endpoints.urlpath, "GET", "application/json", $null)
            $this.logger.LogInfo("Retrieved context profiles from NSX manager", "NSXAPI")
            return $result

        }
        catch {
            $this.logger.LogError("Failed to retrieve context profiles: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # Get domains from NSX manager (for local manager testing)
    [object] GetDomains([string] $nsxManager) {
        $this.logger.LogInfo("Determining NSX Manager type and retrieving domains from: $nsxManager", "NSXAPI")

        try {
            # For local-to-local testing, start with standalone manager check
            $this.logger.LogDebug("Checking if NSX Manager is standalone", "NSXAPI")

            try {
                $urlbase = "policy/api/v1"
                $urlpath = "infra/domains"
                $result = $this.NSX_REST_Core($urlbase, $urlpath, "GET", "application/json", $null)

                if ($result -and $result.results) {
                    $this.logger.LogInfo("NSX Manager is a standalone manager with $($result.results.Count) domains", "NSXAPI")
                    return $result
                }
            }
            catch {
                $this.logger.LogDebug("Not a standalone manager: $($_.Exception.Message)", "NSXAPI")
            }

            # Try Local Manager (federated) next
            $this.logger.LogDebug("Checking if NSX Manager is a Local Manager in federation", "NSXAPI")

            try {
                $urlbase = "policy/api/v1"
                $urlpath = "global-infra/domains"
                $result = $this.NSX_REST_Core($urlbase, $urlpath, "GET", "application/json", $null)

                if ($result -and $result.results) {
                    $this.logger.LogInfo("NSX Manager is a Local Manager in federation with $($result.results.Count) domains", "NSXAPI")
                    return $result
                }
            }
            catch {
                $this.logger.LogDebug("Not a federated local manager: $($_.Exception.Message)", "NSXAPI")
            }

            # Try Global Manager last (for future testing)
            $this.logger.LogDebug("Checking if NSX Manager is a Global Manager", "NSXAPI")

            try {
                $urlbase = "global-manager/api/v1"
                $urlpath = "global-infra/domains"
                $result = $this.NSX_REST_Core($urlbase, $urlpath, "GET", "application/json", $null)

                if ($result -and $result.results) {
                    $this.logger.LogInfo("NSX Manager is a Global Manager with $($result.results.Count) domains", "NSXAPI")
                    return $result
                }
            }
            catch {
                $this.logger.LogDebug("Not a global manager: $($_.Exception.Message)", "NSXAPI")
            }

            # If all attempts failed, create a default domain response for local testing
            $this.logger.LogWarning("Unable to retrieve domains from any endpoint, creating default domain", "NSXAPI")
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
            $this.logger.LogError("Failed to get domains from $nsxManager : $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # Check if environment is federated
    [bool] IsFederatedEnvironment([object] $domains) {
        # If we can get domains from global-infra endpoints, it's federated
        # This is a simplified check - you might want to enhance this based on your specific needs
        return $domains -and $domains.results -and $domains.results.Count -gt 0
    }

    #endregion

    #region Bulk Operations

    # Create multiple objects in a single hierarchical call
    [bool] BulkCreateObjects([object] $configuration) {
        try {
            $jsonPayload = $configuration | ConvertTo-Json -Depth 20 -Compress
            return $this.DeployHierarchicalConfiguration($this.NSXManager, $jsonPayload)

        }
        catch {
            $this.logger.LogError("Bulk create operation failed: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            return $false
        }
    }

    # Update multiple objects in a single hierarchical call
    [bool] BulkUpdateObjects([object] $configuration) {
        try {
            $jsonPayload = $configuration | ConvertTo-Json -Depth 20 -Compress
            return $this.DeployHierarchicalConfiguration($this.NSXManager, $jsonPayload)

        }
        catch {
            $this.logger.LogError("Bulk update operation failed: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            return $false
        }
    }

    #endregion

    #region Migration Helpers

    # Export entire configuration in hierarchical format
    [object] ExportHierarchicalConfiguration([string] $domainId = "default") {
        try {
            $this.logger.LogInfo("Exporting hierarchical configuration", "NSXAPI")

            # Create hierarchical structure
            $config = [ordered]@{
                resource_type = "Infra"
                children      = @()
            }

            # Get services
            $services = $this.GetServices($this.NSXManager)
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
            $groups = $this.GetGroups($this.NSXManager, $domainId)
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
            $policies = $this.GetSecurityPolicies($this.NSXManager, $domainId)
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

            $this.logger.LogInfo("Hierarchical configuration exported successfully", "NSXAPI")
            return $config

        }
        catch {
            $this.logger.LogError("Failed to export hierarchical configuration: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            throw
        }
    }

    # Import hierarchical configuration from another NSX manager
    [bool] ImportHierarchicalConfiguration([string] $sourceNsxManager, [string] $targetDomainId = "default") {
        try {
            $this.logger.LogInfo("Importing hierarchical configuration from: $sourceNsxManager", "NSXAPI")

            # Create temporary service instance for source
            $sourceService = [NSXAPIService]::new($sourceNsxManager, $this.logger, $this.authService, $this.configService)

            # Export from source
            $config = $sourceService.ExportHierarchicalConfiguration($targetDomainId)

            # Import to current (target) manager
            $result = $this.BulkCreateObjects($config)

            if ($result) {
                $this.logger.LogInfo("Hierarchical configuration imported successfully", "NSXAPI")
            }
            else {
                $this.logger.LogError("Failed to import hierarchical configuration", "NSXAPI")
            }

            return $result

        }
        catch {
            $this.logger.LogError("Import operation failed: $($_.Exception.Message)", "NSXAPI", $_.Exception)
            return $false
        }
    }

    #endregion
}
