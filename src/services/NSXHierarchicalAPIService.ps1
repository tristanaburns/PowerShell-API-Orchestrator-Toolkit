# NSXHierarchicalAPIService.ps1
# Service for creating and managing NSX-T Hierarchical API structures
# Supports bulk configuration deployment using declarative JSON payloads

class NSXHierarchicalAPIService {
    hidden [object] $logger
    hidden [object] $nsxApiService
    hidden [object] $DebugLogger

    NSXHierarchicalAPIService([object] $loggingService, [object] $nsxApiService) {
        $this.logger = $loggingService
        $this.nsxApiService = $nsxApiService
        $this.logger.LogInfo("NSX Hierarchical API Service initialised", "HierarchicalAPI")
        $this.logger.LogInfo("NSX Hierarchical API Service initialised", "HierarchicalAPI")
    }

    #region Hierarchical Structure Creation

    # Create the base hierarchical infrastructure structure
    [object] CreateInfrastructureBase() {
        $this.logger.LogInfo("Creating base hierarchical infrastructure structure", "HierarchicalAPI")

        $infraStructure = [ordered]@{
            resource_type = "Infra"
            children      = @()
        }

        $this.logger.LogInfo("Created base hierarchical structure with resource_type: Infra", "HierarchicalAPI")
        $this.logger.LogDebug("Created base infrastructure structure", "HierarchicalAPI")
        return $infraStructure
    }

    # Create domain reference container
    [object] CreateDomainReference([string] $domainId = "default") {
        $this.logger.LogInfo("Creating domain reference for domain: $domainId", "HierarchicalAPI")

        $domainRef = [ordered]@{
            resource_type = "ChildResourceReference"
            target_type   = "Domain"
            id            = $domainId
            children      = @()
        }

        $this.logger.LogInfo("Created domain reference: resource_type=ChildResourceReference, target_type=Domain, id=$domainId", "HierarchicalAPI")
        $this.logger.LogDebug("Created domain reference for: $domainId", "HierarchicalAPI")
        return $domainRef
    }

    # Add service to infrastructure
    [void] AddServiceToInfra([object] $infraStructure, [object] $serviceDefinition) {
        $this.logger.LogInfo("Adding service to infrastructure", "HierarchicalAPI")
        $this.logger.LogInfo("Service ID: $($serviceDefinition.id)", "HierarchicalAPI")
        $this.logger.LogInfo("Service display_name: $($serviceDefinition.display_name)", "HierarchicalAPI")

        $childService = [ordered]@{
            resource_type = "ChildService"
            Service       = $serviceDefinition
        }

        $infraStructure.children += $childService
        $this.logger.LogInfo("Service added to infrastructure children array - Total children: $($infraStructure.children.Count)", "HierarchicalAPI")
        $this.logger.LogInfo("Added service to infrastructure: $($serviceDefinition.display_name)", "HierarchicalAPI")
    }

    # Add group to domain
    [void] AddGroupToDomain([object] $domainRef, [object] $groupDefinition) {
        $childGroup = [ordered]@{
            resource_type = "ChildGroup"
            Group         = $groupDefinition
        }

        $domainRef.children += $childGroup
        $this.logger.LogInfo("Added group to domain: $($groupDefinition.display_name)", "HierarchicalAPI")
    }

    # Add security policy to domain
    [void] AddSecurityPolicyToDomain([object] $domainRef, [object] $policyDefinition) {
        $childPolicy = [ordered]@{
            resource_type  = "ChildSecurityPolicy"
            SecurityPolicy = $policyDefinition
        }

        $domainRef.children += $childPolicy
        $this.logger.LogInfo("Added security policy to domain: $($policyDefinition.display_name)", "HierarchicalAPI")
    }

    # Add context profile to domain
    [void] AddContextProfileToDomain([object] $domainRef, [object] $profileDefinition) {
        $childProfile = [ordered]@{
            resource_type  = "ChildContextProfile"
            ContextProfile = $profileDefinition
        }

        $domainRef.children += $childProfile
        $this.logger.LogInfo("Added context profile to domain: $($profileDefinition.display_name)", "HierarchicalAPI")
    }

    #endregion

    #region Configuration Retrieval

    # Get existing configuration from NSX manager in hierarchical format
    [object] GetExistingConfiguration([string] $nsxManager, [string] $objectType = "all") {
        $this.logger.LogInfo("Retrieving existing configuration from: $nsxManager", "HierarchicalAPI")

        $config = $this.CreateInfrastructureBase()
        $domainRef = $this.CreateDomainReference()

        try {
            switch ($objectType.ToLower()) {
                "services" {
                    $this.RetrieveServices($nsxManager, $config)
                }
                "groups" {
                    $this.RetrieveGroups($nsxManager, $domainRef)
                }
                "policies" {
                    $this.RetrieveSecurityPolicies($nsxManager, $domainRef)
                }
                "contextprofiles" {
                    $this.RetrieveContextProfiles($nsxManager, $domainRef)
                }
                "all" {
                    $this.RetrieveServices($nsxManager, $config)
                    $this.RetrieveGroups($nsxManager, $domainRef)
                    $this.RetrieveSecurityPolicies($nsxManager, $domainRef)
                    $this.RetrieveContextProfiles($nsxManager, $domainRef)
                }
            }

            # Add domain reference if it has children
            if ($domainRef.children.Count -gt 0) {
                $config.children += $domainRef
            }

            $this.logger.LogInfo("Successfully retrieved configuration", "HierarchicalAPI")
            return $config

        }
        catch {
            $this.logger.LogError("Failed to retrieve configuration: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
            throw
        }
    }

    # Retrieve services from NSX manager
    [void] RetrieveServices([string] $nsxManager, [object] $config) {
        $this.logger.LogInfo("Retrieving services from NSX manager", "HierarchicalAPI")

        try {
            $services = $this.nsxApiService.GetServices($nsxManager)

            foreach ($service in $services.results) {
                $serviceDefinition = [ordered]@{
                    resource_type     = "Service"
                    marked_for_delete = "False"
                    id                = $service.id
                    display_name      = $service.display_name
                    description       = $service.description
                    service_entries   = $service.service_entries
                }

                $this.AddServiceToInfra($config, $serviceDefinition)
            }

            $this.logger.LogInfo("Retrieved $($services.results.Count) services", "HierarchicalAPI")

        }
        catch {
            $this.logger.LogError("Failed to retrieve services: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
        }
    }

    # Retrieve groups from NSX manager
    [void] RetrieveGroups([string] $nsxManager, [object] $domainRef) {
        $this.logger.LogInfo("Retrieving groups from NSX manager", "HierarchicalAPI")

        try {
            $groups = $this.nsxApiService.GetGroups($nsxManager)

            foreach ($group in $groups.results) {
                $groupDefinition = [ordered]@{
                    resource_type     = "Group"
                    marked_for_delete = "False"
                    id                = $group.id
                    display_name      = $group.display_name
                    description       = $group.description
                    expression        = $group.expression
                }

                $this.AddGroupToDomain($domainRef, $groupDefinition)
            }

            $this.logger.LogInfo("Retrieved $($groups.results.Count) groups", "HierarchicalAPI")

        }
        catch {
            $this.logger.LogError("Failed to retrieve groups: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
        }
    }

    # Retrieve security policies from NSX manager
    [void] RetrieveSecurityPolicies([string] $nsxManager, [object] $domainRef) {
        $this.logger.LogInfo("Retrieving security policies from NSX manager", "HierarchicalAPI")

        try {
            $policies = $this.nsxApiService.GetSecurityPolicies($nsxManager)

            foreach ($policy in $policies.results) {
                $policyDefinition = [ordered]@{
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

                $this.AddSecurityPolicyToDomain($domainRef, $policyDefinition)
            }

            $this.logger.LogInfo("Retrieved $($policies.results.Count) security policies", "HierarchicalAPI")

        }
        catch {
            $this.logger.LogError("Failed to retrieve security policies: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
        }
    }

    # Retrieve context profiles from NSX manager
    [void] RetrieveContextProfiles([string] $nsxManager, [object] $domainRef) {
        $this.logger.LogInfo("Retrieving context profiles from NSX manager", "HierarchicalAPI")

        try {
            $profiles = $this.nsxApiService.GetContextProfiles($nsxManager)

            foreach ($profile in $profiles.results) {
                $profileDefinition = [ordered]@{
                    resource_type     = "ContextProfile"
                    marked_for_delete = "False"
                    id                = $profile.id
                    display_name      = $profile.display_name
                    description       = $profile.description
                    attributes        = $profile.attributes
                }

                $this.AddContextProfileToDomain($domainRef, $profileDefinition)
            }

            $this.logger.LogInfo("Retrieved $($profiles.results.Count) context profiles", "HierarchicalAPI")

        }
        catch {
            $this.logger.LogError("Failed to retrieve context profiles: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
        }
    }

    #endregion

    #region Configuration Deployment

    # Deploy hierarchical configuration to target NSX manager
    [bool] DeployConfiguration([string] $targetNsxManager, [object] $configuration) {
        $this.logger.LogInfo("Deploying hierarchical configuration to: $targetNsxManager", "HierarchicalAPI")

        try {
            # Convert configuration to JSON
            $jsonPayload = $configuration | ConvertTo-Json -Depth 20 -Compress

            # Log the payload (truncated for security)
            $payloadPreview = if ($jsonPayload.Length -gt 500) {
                $jsonPayload.Substring(0, 500) + "..."
            }
            else {
                $jsonPayload
            }
            $this.logger.LogDebug("Deployment payload preview: $payloadPreview", "HierarchicalAPI")

            # Deploy using hierarchical API endpoint
            $result = $this.nsxApiService.DeployHierarchicalConfiguration($targetNsxManager, $jsonPayload)

            if ($result) {
                $this.logger.LogInfo("Successfully deployed hierarchical configuration", "HierarchicalAPI")
                return $true
            }
            else {
                $this.logger.LogError("Failed to deploy hierarchical configuration", "HierarchicalAPI")
                return $false
            }

        }
        catch {
            $this.logger.LogError("Error during configuration deployment: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
            return $false
        }
    }

    # Save configuration to file
    [void] SaveConfigurationToFile([object] $configuration, [string] $filePath) {
        try {
            $jsonContent = $configuration | ConvertTo-Json -Depth 20
            $jsonContent | Out-File -FilePath $filePath -Encoding UTF8
            $this.logger.LogInfo("Configuration saved to file: $filePath", "HierarchicalAPI")

        }
        catch {
            $this.logger.LogError("Failed to save configuration to file: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
            throw
        }
    }

    # Load configuration from file
    [object] LoadConfigurationFromFile([string] $filePath) {
        try {
            if (-not (Test-Path $filePath)) {
                throw "Configuration file not found: $filePath"
            }

            $jsonContent = Get-Content -Path $filePath -Raw
            $configuration = $jsonContent | ConvertFrom-Json -AsHashtable

            $this.logger.LogInfo("Configuration loaded from file: $filePath", "HierarchicalAPI")
            return $configuration

        }
        catch {
            $this.logger.LogError("Failed to load configuration from file: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
            throw
        }
    }

    #endregion

    #region Utility Methods

    # Merge multiple configurations into one
    [object] MergeConfigurations([hashtable[]] $configurations) {
        $this.logger.LogInfo("Merging $($configurations.Count) configurations", "HierarchicalAPI")

        $mergedConfig = $this.CreateInfrastructureBase()
        $mergedDomainRef = $this.CreateDomainReference()

        foreach ($config in $configurations) {
            # Merge services (top-level children)
            foreach ($child in $config.children) {
                if ($child.resource_type -eq "ChildService") {
                    $mergedConfig.children += $child
                }
                elseif ($child.resource_type -eq "ChildResourceReference") {
                    # Merge domain children
                    foreach ($domainChild in $child.children) {
                        $mergedDomainRef.children += $domainChild
                    }
                }
            }
        }

        # Add merged domain reference if it has children
        if ($mergedDomainRef.children.Count -gt 0) {
            $mergedConfig.children += $mergedDomainRef
        }

        $this.logger.LogInfo("Successfully merged configurations", "HierarchicalAPI")
        return $mergedConfig
    }

    # Validate configuration structure
    [bool] ValidateConfiguration([object] $configuration) {
        try {
            # Basic validation checks
            if (-not ($configuration | Get-Member -Name "resource_type" -ErrorAction SilentlyContinue) -or $configuration.resource_type -ne "Infra") {
                $this.logger.LogError("Invalid configuration: Missing or incorrect resource_type", "HierarchicalAPI")
                return $false
            }

            if (-not ($configuration | Get-Member -Name "children" -ErrorAction SilentlyContinue)) {
                $this.logger.LogError("Invalid configuration: Missing children array", "HierarchicalAPI")
                return $false
            }

            # Validate children structure
            foreach ($child in $configuration.children) {
                if (-not ($child | Get-Member -Name "resource_type" -ErrorAction SilentlyContinue)) {
                    $this.logger.LogError("Invalid child: Missing resource_type", "HierarchicalAPI")
                    return $false
                }
            }

            $this.logger.LogInfo("Configuration validation passed", "HierarchicalAPI")
            return $true

        }
        catch {
            $this.logger.LogError("Configuration validation failed: $($_.Exception.Message)", "HierarchicalAPI", $_.Exception)
            return $false
        }
    }

    #endregion
}
