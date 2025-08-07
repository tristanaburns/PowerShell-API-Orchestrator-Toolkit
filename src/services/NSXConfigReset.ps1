# NSX Configuration Reset Module
# Provides functionality to inventory and delete all custom NSX DFW configuration objects
# Supports both dry-run and destructive modes for safe testing and cleanup

class NSXConfigReset {
    hidden [object] $logger
    hidden [object] $authService
    hidden [object] $apiService
    hidden [object] $urlMappings
    hidden [object] $objectCounts
    hidden [PSCredential] $currentCredentials
    hidden [string] $currentNSXManager

    # Constructor with dependency injection
    NSXConfigReset([object] $loggingService, [object] $authService, [object] $apiService) {
        $this.logger = $loggingService
        $this.authService = $authService
        $this.apiService = $apiService
        $this.objectCounts = [PSCustomObject]@{}

        $this.initialiseUrlMappings()

        $this.logger.LogInfo("NSXConfigReset initialised", "ConfigReset")
    }

    # initialise URL mappings for different NSX object types
    hidden [void] initialiseUrlMappings() {
        $this.urlMappings = @{
            'standalone'   = @{
                'services'          = 'infra/services'
                'tier1_services'    = 'infra/tier-1s/{tier1_id}/services'
                'groups'            = 'infra/domains/{domain}/groups'
                'security_policies' = 'infra/domains/{domain}/security-policies'
                'context_profiles'  = 'infra/context-profiles'
            }
            'mgmt_cluster' = @{
                'services'          = 'cluster-manager/api/v1/cluster/{cluster_id}/api/v1/infra/services'
                'groups'            = 'cluster-manager/api/v1/cluster/{cluster_id}/api/v1/infra/domains/{domain}/groups'
                'security_policies' = 'cluster-manager/api/v1/cluster/{cluster_id}/api/v1/infra/domains/{domain}/security-policies'
                'context_profiles'  = 'cluster-manager/api/v1/cluster/{cluster_id}/api/v1/infra/context-profiles'
            }
        }

        $this.logger.LogDebug("URL mappings initialised for reset operations", "ConfigReset")
    }



    # Get inventory of all NSX DFW configuration objects
    [object] GetConfigurationInventory([string] $nsxManager, [bool] $verboseLogging = $false, [bool] $useCurrentUser = $false, [bool] $nonInteractive = $false, [string] $credentialFile = $null, [bool] $forceNew = $false) {
        $this.logger.LogInfo("Starting configuration inventory for manager: $nsxManager", "ConfigReset")

        $inventory = [PSCustomObject]@{
            'services'          = @()
            'groups'            = @()
            'security_policies' = @()
            'context_profiles'  = @()
            'summary'           = [PSCustomObject]@{}
        }

        try {
            # Collect credentials and test connection to NSX manager
            $credentials = $this.authService.CollectCredentials($nsxManager, $useCurrentUser, $nonInteractive, $credentialFile, $forceNew)
            $connectionResult = $this.authService.TestConnection($nsxManager, $credentials, $true)  # Skip SSL verification for testing
            if (-not $connectionResult.Success) {
                throw "Connection failed: $($connectionResult.Error)"
            }

            # Get manager info to determine type
            $managerInfo = $this.GetManagerInfo($nsxManager)
            $managerType = $managerInfo.Type
            $clusterId = if ($managerType -eq 'mgmt_cluster') { $managerInfo.ClusterId } else { $null }

            if ($verboseLogging) {
                $this.logger.LogDebug("Manager type detected: $managerType", "ConfigReset")
                if ($clusterId) {
                    $this.logger.LogDebug("Cluster ID: $clusterId", "ConfigReset")
                }
            }

            # Inventory services
            $inventory.services = $this.InventoryServices($nsxManager, $managerType, $clusterId, $verboseLogging)

            # Inventory groups (default domain)
            $inventory.groups = $this.InventoryGroups($nsxManager, $managerType, 'default', $clusterId, $verboseLogging)

            # Inventory security policies (default domain)
            $inventory.security_policies = $this.InventorySecurityPolicies($nsxManager, $managerType, 'default', $clusterId, $verboseLogging)

            # Inventory context profiles
            $inventory.context_profiles = $this.InventoryContextProfiles($nsxManager, $managerType, $clusterId, $verboseLogging)

            # Generate summary
            $inventory.summary = @{
                'services_count'          = $inventory.services.Count
                'groups_count'            = $inventory.groups.Count
                'security_policies_count' = $inventory.security_policies.Count
                'context_profiles_count'  = $inventory.context_profiles.Count
                'total_objects'           = $inventory.services.Count + $inventory.groups.Count + $inventory.security_policies.Count + $inventory.context_profiles.Count
            }

            $this.logger.LogInfo("Configuration inventory completed successfully", "ConfigReset")
            $this.LogInventorySummary($inventory.summary)

            return $inventory

        }
        catch {
            $this.logger.LogError("Failed to get configuration inventory: $($_.Exception.Message)", "ConfigReset")
            throw
        }
    }
    # Inventory all services
    hidden [array] InventoryServices([string] $nsxManager, [string] $managerType, [string] $clusterId, [bool] $verboseLogging) {
        $this.logger.LogInfo("Inventorying services...", "ConfigReset")

        $services = @()
        $urlTemplate = $this.urlMappings[$managerType]['services']

        if ($managerType -eq 'mgmt_cluster') {
            $url = $urlTemplate -replace '\{cluster_id\}', $clusterId
        }
        else {
            $url = $urlTemplate
        }

        try {
            $response = $this.apiService.MakeNSXAPICall($nsxManager, 'GET', $url)

            if ($response.results) {
                foreach ($service in $response.results) {
                    # Only include custom services (skip system defaults)
                    if ($service.id -notmatch '^(HTTP|HTTPS|SSH|DNS|ICMP|SNMP|NTP)' -and
                        $service.display_name -notmatch '^(HTTP|HTTPS|SSH|DNS|ICMP|SNMP|NTP)') {

                        $serviceInfo = [PSCustomObject]@{
                            'id'           = $service.id
                            'display_name' = $service.display_name
                            'description'  = $service.description
                            'service_type' = $service.service_type
                            'path'         = $service.path
                        }

                        $services += $serviceInfo

                        if ($verboseLogging) {
                            $this.logger.LogDebug("Found custom service: $($service.display_name) (ID: $($service.id))", "ConfigReset")
                        }
                    }
                }
            }

            $this.logger.LogInfo("Found $($services.Count) custom services", "ConfigReset")
            return $services

        }
        catch {
            $this.logger.LogError("Failed to inventory services: $($_.Exception.Message)", "ConfigReset")
            return @()
        }
    }

    # Inventory all groups in a domain
    hidden [array] InventoryGroups([string] $nsxManager, [string] $managerType, [string] $domain, [string] $clusterId, [bool] $verboseLogging) {
        $this.logger.LogInfo("Inventorying groups in domain: $domain", "ConfigReset")

        $groups = @()
        $urlTemplate = $this.urlMappings[$managerType]['groups']

        if ($managerType -eq 'mgmt_cluster') {
            $url = $urlTemplate -replace '\{cluster_id\}', $clusterId -replace '\{domain\}', $domain
        }
        else {
            $url = $urlTemplate -replace '\{domain\}', $domain
        }

        try {
            $response = $this.apiService.MakeNSXAPICall($nsxManager, 'GET', $url)

            if ($response.results) {
                foreach ($group in $response.results) {
                    # Only include custom groups (skip system defaults)
                    if ($group.id -notmatch '^(ANY|ALL)' -and
                        $group.display_name -notmatch '^(ANY|ALL|Environment)') {

                        $groupInfo = [PSCustomObject]@{
                            'id'           = $group.id
                            'display_name' = $group.display_name
                            'description'  = $group.description
                            'group_type'   = $group.group_type
                            'path'         = $group.path
                        }

                        $groups += $groupInfo

                        if ($verboseLogging) {
                            $this.logger.LogDebug("Found custom group: $($group.display_name) (ID: $($group.id))", "ConfigReset")
                        }
                    }
                }
            }

            $this.logger.LogInfo("Found $($groups.Count) custom groups", "ConfigReset")
            return $groups

        }
        catch {
            $this.logger.LogError("Failed to inventory groups: $($_.Exception.Message)", "ConfigReset")
            return @()
        }
    }

    # Inventory all security policies in a domain
    hidden [array] InventorySecurityPolicies([string] $nsxManager, [string] $managerType, [string] $domain, [string] $clusterId, [bool] $verboseLogging) {
        $this.logger.LogInfo("Inventorying security policies in domain: $domain", "ConfigReset")

        $policies = @()
        $urlTemplate = $this.urlMappings[$managerType]['security_policies']

        if ($managerType -eq 'mgmt_cluster') {
            $url = $urlTemplate -replace '\{cluster_id\}', $clusterId -replace '\{domain\}', $domain
        }
        else {
            $url = $urlTemplate -replace '\{domain\}', $domain
        }

        try {
            $response = $this.apiService.MakeNSXAPICall($nsxManager, 'GET', $url)

            if ($response.results) {
                foreach ($policy in $response.results) {
                    # Only include custom policies (skip system defaults)
                    if ($policy.id -notmatch '^(default|allow-any|deny-any)' -and
                        $policy.display_name -notmatch '^(Default|Allow|Deny)') {

                        $policyInfo = [PSCustomObject]@{
                            'id'           = $policy.id
                            'display_name' = $policy.display_name
                            'description'  = $policy.description
                            'category'     = $policy.category
                            'path'         = $policy.path
                        }

                        $policies += $policyInfo

                        if ($verboseLogging) {
                            $this.logger.LogDebug("Found custom security policy: $($policy.display_name) (ID: $($policy.id))", "ConfigReset")
                        }
                    }
                }
            }

            $this.logger.LogInfo("Found $($policies.Count) custom security policies", "ConfigReset")
            return $policies

        }
        catch {
            $this.logger.LogError("Failed to inventory security policies: $($_.Exception.Message)", "ConfigReset")
            return @()
        }
    }
    # Inventory all context profiles
    hidden [array] InventoryContextProfiles([string] $nsxManager, [string] $managerType, [string] $clusterId, [bool] $verboseLogging) {
        $this.logger.LogInfo("Inventorying context profiles...", "ConfigReset")

        $profiles = @()
        $urlTemplate = $this.urlMappings[$managerType]['context_profiles']

        if ($managerType -eq 'mgmt_cluster') {
            $url = $urlTemplate -replace '\{cluster_id\}', $clusterId
        }
        else {
            $url = $urlTemplate
        }

        try {
            $response = $this.apiService.MakeNSXAPICall($nsxManager, 'GET', $url)

            if ($response.results) {
                foreach ($profile in $response.results) {
                    # Only include custom context profiles (skip system defaults)
                    if ($profile.id -notmatch '^(default|system)' -and
                        $profile.display_name -notmatch '^(Default|System)') {

                        $profileInfo = [PSCustomObject]@{
                            'id'           = $profile.id
                            'display_name' = $profile.display_name
                            'description'  = $profile.description
                            'path'         = $profile.path
                        }

                        $profiles += $profileInfo

                        if ($verboseLogging) {
                            $this.logger.LogDebug("Found custom context profile: $($profile.display_name) (ID: $($profile.id))", "ConfigReset")
                        }
                    }
                }
            }

            $this.logger.LogInfo("Found $($profiles.Count) custom context profiles", "ConfigReset")
            return $profiles

        }
        catch {
            $this.logger.LogError("Failed to inventory context profiles: $($_.Exception.Message)", "ConfigReset")
            return @()
        }
    }

    # Delete all custom NSX DFW configuration objects
    [object] ResetConfiguration([string] $nsxManager, [bool] $dryRun = $true, [bool] $verboseLogging = $false, [bool] $useCurrentUser = $false, [bool] $nonInteractive = $false, [string] $credentialFile = $null, [bool] $forceNew = $false) {
        $this.logger.LogInfo("Starting configuration reset for manager: $nsxManager (WhatIf Mode: $dryRun)", "ConfigReset")

        $resetResults = [PSCustomObject]@{
            'success'          = $false
            'dry_run'          = $dryRun
            'deleted_objects'  = @{
                'services'          = @()
                'groups'            = @()
                'security_policies' = @()
                'context_profiles'  = @()
            }
            'failed_deletions' = @()
            'summary'          = [PSCustomObject]@{}
            'errors'           = @()
        }

        try {
            # First get inventory of what needs to be deleted
            $inventory = $this.GetConfigurationInventory($nsxManager, $verboseLogging, $useCurrentUser, $nonInteractive, $credentialFile, $forceNew)

            if ($inventory.summary.total_objects -eq 0) {
                $this.logger.LogInfo("No custom objects found to delete", "ConfigReset")
                $resetResults.success = $true
                return $resetResults
            }

            if ($dryRun) {
                $this.logger.LogInfo("WhatIf Mode MODE: Would delete $($inventory.summary.total_objects) objects", "ConfigReset")
                $resetResults.success = $true
                $resetResults.deleted_objects = $inventory
                return $resetResults
            }

            # Collect credentials and test connection to NSX manager
            $credentials = $this.authService.CollectCredentials($nsxManager, $useCurrentUser, $nonInteractive, $credentialFile, $forceNew)
            $connectionResult = $this.authService.TestConnection($nsxManager, $credentials, $true)  # Skip SSL verification for testing
            if (-not $connectionResult.Success) {
                throw "Connection failed: $($connectionResult.Error)"
            }

            # Get manager info
            $managerInfo = $this.GetManagerInfo($nsxManager)
            $managerType = $managerInfo.Type
            $clusterId = if ($managerType -eq 'mgmt_cluster') { $managerInfo.ClusterId } else { $null }

            # Delete objects in dependency order (policies first, then groups, services, profiles)
            $this.DeleteSecurityPolicies($nsxManager, $managerType, 'default', $clusterId, $inventory.security_policies, $resetResults, $verboseLogging)
            $this.DeleteGroups($nsxManager, $managerType, 'default', $clusterId, $inventory.groups, $resetResults, $verboseLogging)
            $this.DeleteServices($nsxManager, $managerType, $clusterId, $inventory.services, $resetResults, $verboseLogging)
            $this.DeleteContextProfiles($nsxManager, $managerType, $clusterId, $inventory.context_profiles, $resetResults, $verboseLogging)

            # Generate summary
            $deletedCount = $resetResults.deleted_objects.services.Count +
            $resetResults.deleted_objects.groups.Count +
            $resetResults.deleted_objects.security_policies.Count +
            $resetResults.deleted_objects.context_profiles.Count

            $resetResults.summary = @{
                'total_deleted'             = $deletedCount
                'total_failed'              = $resetResults.failed_deletions.Count
                'services_deleted'          = $resetResults.deleted_objects.services.Count
                'groups_deleted'            = $resetResults.deleted_objects.groups.Count
                'security_policies_deleted' = $resetResults.deleted_objects.security_policies.Count
                'context_profiles_deleted'  = $resetResults.deleted_objects.context_profiles.Count
            }

            $resetResults.success = ($resetResults.failed_deletions.Count -eq 0)

            if ($resetResults.success) {
                $this.logger.LogInfo("Configuration reset completed successfully. Deleted $deletedCount objects.", "ConfigReset")
            }
            else {
                $this.logger.LogWarning("Configuration reset completed with errors. $($resetResults.failed_deletions.Count) deletions failed.", "ConfigReset")
            }

            return $resetResults

        }
        catch {
            $errorMsg = "Failed to reset configuration: $($_.Exception.Message)"
            $this.logger.LogError($errorMsg, "ConfigReset")
            $resetResults.errors += $errorMsg
            return $resetResults
        }
    }
    # Delete security policies
    hidden [void] DeleteSecurityPolicies([string] $nsxManager, [string] $managerType, [string] $domain, [string] $clusterId, [array] $policies, [object] $results, [bool] $verboseLogging) {
        $this.logger.LogInfo("Deleting $($policies.Count) security policies...", "ConfigReset")

        foreach ($policy in $policies) {
            try {
                $urlTemplate = $this.urlMappings[$managerType]['security_policies'] + "/$($policy.id)"

                if ($managerType -eq 'mgmt_cluster') {
                    $url = $urlTemplate -replace '\{cluster_id\}', $clusterId -replace '\{domain\}', $domain
                }
                else {
                    $url = $urlTemplate -replace '\{domain\}', $domain
                }

                $response = $this.apiService.MakeNSXAPICall($nsxManager, 'DELETE', $url)

                $results.deleted_objects.security_policies += $policy

                if ($verboseLogging) {
                    $this.logger.LogDebug("Deleted security policy: $($policy.display_name)", "ConfigReset")
                }

            }
            catch {
                $failureInfo = [PSCustomObject]@{
                    'object_type' = 'security_policy'
                    'object_id'   = $policy.id
                    'object_name' = $policy.display_name
                    'error'       = $_.Exception.Message
                }
                $results.failed_deletions += $failureInfo
                $this.logger.LogError("Failed to delete security policy $($policy.display_name): $($_.Exception.Message)", "ConfigReset")
            }
        }
    }

    # Delete groups
    hidden [void] DeleteGroups([string] $nsxManager, [string] $managerType, [string] $domain, [string] $clusterId, [array] $groups, [object] $results, [bool] $verboseLogging) {
        $this.logger.LogInfo("Deleting $($groups.Count) groups...", "ConfigReset")

        foreach ($group in $groups) {
            try {
                $urlTemplate = $this.urlMappings[$managerType]['groups'] + "/$($group.id)"

                if ($managerType -eq 'mgmt_cluster') {
                    $url = $urlTemplate -replace '\{cluster_id\}', $clusterId -replace '\{domain\}', $domain
                }
                else {
                    $url = $urlTemplate -replace '\{domain\}', $domain
                }

                $response = $this.apiService.MakeNSXAPICall($nsxManager, 'DELETE', $url)

                $results.deleted_objects.groups += $group

                if ($verboseLogging) {
                    $this.logger.LogDebug("Deleted group: $($group.display_name)", "ConfigReset")
                }

            }
            catch {
                $failureInfo = [PSCustomObject]@{
                    'object_type' = 'group'
                    'object_id'   = $group.id
                    'object_name' = $group.display_name
                    'error'       = $_.Exception.Message
                }
                $results.failed_deletions += $failureInfo
                $this.logger.LogError("Failed to delete group $($group.display_name): $($_.Exception.Message)", "ConfigReset")
            }
        }
    }

    # Delete services
    hidden [void] DeleteServices([string] $nsxManager, [string] $managerType, [string] $clusterId, [array] $services, [object] $results, [bool] $verboseLogging) {
        $this.logger.LogInfo("Deleting $($services.Count) services...", "ConfigReset")

        foreach ($service in $services) {
            try {
                $urlTemplate = $this.urlMappings[$managerType]['services'] + "/$($service.id)"

                if ($managerType -eq 'mgmt_cluster') {
                    $url = $urlTemplate -replace '\{cluster_id\}', $clusterId
                }
                else {
                    $url = $urlTemplate
                }

                $response = $this.apiService.MakeNSXAPICall($nsxManager, 'DELETE', $url)

                $results.deleted_objects.services += $service

                if ($verboseLogging) {
                    $this.logger.LogDebug("Deleted service: $($service.display_name)", "ConfigReset")
                }

            }
            catch {
                $failureInfo = [PSCustomObject]@{
                    'object_type' = 'service'
                    'object_id'   = $service.id
                    'object_name' = $service.display_name
                    'error'       = $_.Exception.Message
                }
                $results.failed_deletions += $failureInfo
                $this.logger.LogError("Failed to delete service $($service.display_name): $($_.Exception.Message)", "ConfigReset")
            }
        }
    }
    # Delete context profiles
    hidden [void] DeleteContextProfiles([string] $nsxManager, [string] $managerType, [string] $clusterId, [array] $profiles, [object] $results, [bool] $verboseLogging) {
        $this.logger.LogInfo("Deleting $($profiles.Count) context profiles...", "ConfigReset")

        foreach ($profile in $profiles) {
            try {
                $urlTemplate = $this.urlMappings[$managerType]['context_profiles'] + "/$($profile.id)"

                if ($managerType -eq 'mgmt_cluster') {
                    $url = $urlTemplate -replace '\{cluster_id\}', $clusterId
                }
                else {
                    $url = $urlTemplate
                }

                $response = $this.apiService.MakeNSXAPICall($nsxManager, 'DELETE', $url)

                $results.deleted_objects.context_profiles += $profile

                if ($verboseLogging) {
                    $this.logger.LogDebug("Deleted context profile: $($profile.display_name)", "ConfigReset")
                }

            }
            catch {
                $failureInfo = [PSCustomObject]@{
                    'object_type' = 'context_profile'
                    'object_id'   = $profile.id
                    'object_name' = $profile.display_name
                    'error'       = $_.Exception.Message
                }
                $results.failed_deletions += $failureInfo
                $this.logger.LogError("Failed to delete context profile $($profile.display_name): $($_.Exception.Message)", "ConfigReset")
            }
        }
    }

    # Reset configuration on multiple NSX managers
    [object] ResetMultipleManagers([array] $nsxManagers, [bool] $dryRun = $true, [bool] $verboseLogging = $false, [bool] $useCurrentUser = $false, [bool] $nonInteractive = $false, [string] $credentialFile = $null, [bool] $forceNew = $false) {
        $this.logger.LogInfo("Starting multi-manager configuration reset (WhatIf Mode: $dryRun)", "ConfigReset")

        $multiResults = [PSCustomObject]@{
            'success'  = $true
            'managers' = [PSCustomObject]@{}
            'summary'  = @{
                'total_managers'        = $nsxManagers.Count
                'successful_resets'     = 0
                'failed_resets'         = 0
                'total_objects_deleted' = 0
            }
        }

        foreach ($manager in $nsxManagers) {
            $this.logger.LogInfo("Processing manager: $manager", "ConfigReset")

            try {
                $result = $this.ResetConfiguration($manager, $dryRun, $verboseLogging, $useCurrentUser, $nonInteractive, $credentialFile, $forceNew)
                $multiResults.managers[$manager] = $result

                if ($result.success) {
                    $multiResults.summary.successful_resets++
                    if ($result.summary) {
                        $multiResults.summary.total_objects_deleted += $result.summary.total_deleted
                    }
                }
                else {
                    $multiResults.summary.failed_resets++
                    $multiResults.success = $false
                }

            }
            catch {
                $this.logger.LogError("Failed to reset manager $manager : $($_.Exception.Message)", "ConfigReset")
                $multiResults.managers[$manager] = @{
                    'success' = $false
                    'error'   = $_.Exception.Message
                }
                $multiResults.summary.failed_resets++
                $multiResults.success = $false
            }
        }

        $this.logger.LogInfo("Multi-manager reset completed. Success: $($multiResults.summary.successful_resets)/$($multiResults.summary.total_managers)", "ConfigReset")

        return $multiResults
    }

    # Get manager info to determine type and cluster ID
    hidden [object] GetManagerInfo([string] $nsxManager) {
        try {
            # Try to get cluster information first (management cluster)
            $clusterResponse = $this.apiService.MakeNSXAPICall($nsxManager, 'GET', 'cluster-manager/api/v1/cluster')

            if ($clusterResponse -and $clusterResponse.cluster_id) {
                return @{
                    'Type'      = 'mgmt_cluster'
                    'ClusterId' = $clusterResponse.cluster_id
                }
            }
        }
        catch {
            # If cluster API fails, assume standalone
        }

        return @{
            'Type'      = 'standalone'
            'ClusterId' = $null
        }
    }

    # Log inventory summary
    hidden [void] LogInventorySummary([object] $summary) {
        $this.logger.LogInfo("=== Configuration Inventory Summary ===", "ConfigReset")
        $this.logger.LogInfo("Services: $($summary.services_count)", "ConfigReset")
        $this.logger.LogInfo("Groups: $($summary.groups_count)", "ConfigReset")
        $this.logger.LogInfo("Security Policies: $($summary.security_policies_count)", "ConfigReset")
        $this.logger.LogInfo("Context Profiles: $($summary.context_profiles_count)", "ConfigReset")
        $this.logger.LogInfo("Total Objects: $($summary.total_objects)", "ConfigReset")
        $this.logger.LogInfo("=======================================", "ConfigReset")
    }
}

# End of NSXConfigReset class
