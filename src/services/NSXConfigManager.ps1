# NSXConfigManager.ps1
#
# - Uses dependency injection for all service dependencies (LoggingService, AuthService, APIService, StandardFileNamingService).
# - All file naming is handled via StandardFileNamingService, ensuring consistent, timestamped, and compliant filenames.
# - Service instantiation is managed via CoreServiceFactory; no direct constructor calls outside the factory.
# - All public methods are documented for maintainability and compliance.
#
# Manages the complete lifecycle of NSX-T configuration operations:
#   1. Retrieve entire configuration from source
#   2. Save with reverse timestamp to data/exports/{hostname}/ directory
#   3. Apply configuration to target
#
# Architectural standards and compliance verified as of 2025-07-08.

class NSXConfigManager {
  hidden [object] $logger
  hidden [object] $authService
  hidden [object] $apiService
  hidden [string] $configsDirectory
  hidden [object] $urlMappings
  hidden [object] $fileNamingService

  # Constructor with dependency injection
  #
  # Parameters:
  #   [object] $loggingService - LoggingService instance
  #   [object] $authService - CoreAuthenticationService instance
  #   [object] $apiService - CoreAPIService instance
  #   [string] $configsPath - Optional path for configs directory
  #   [object] $fileNamingService - StandardFileNamingService instance (optional)
  #   [object] $workflowService - WorkflowOperationsService instance (optional, for standardized paths)
  NSXConfigManager([object] $loggingService, [object] $authService, [object] $apiService, [string] $configsPath = $null, [object] $fileNamingService = $null, [object] $workflowService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.fileNamingService = $fileNamingService

    # Set configs directory path with standardized toolkit path support
    if ($configsPath) {
      $this.configsDirectory = $configsPath
    }
    elseif ($workflowService) {
      # Use standardized toolkit path for exports
      $this.configsDirectory = $workflowService.GetToolkitPath("Exports")
      if (-not $this.configsDirectory) {
        # Fallback if path not found
        $scriptRoot = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
        $this.configsDirectory = Join-Path $scriptRoot "data\exports"
      }
    }
    else {
      $scriptRoot = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
      $this.configsDirectory = Join-Path $scriptRoot "data\exports"
    }

    # Ensure the data/exports directory exists
    if (-not (Test-Path $this.configsDirectory)) {
      New-Item -Path $this.configsDirectory -ItemType Directory -Force | Out-Null
      $this.logger.LogInfo("Created data/exports directory: $($this.configsDirectory)", "NSXConfig")
    }

    $this.logger.LogInfo("Configs directory: $($this.configsDirectory)", "NSXConfig")

    # initialise URL mappings for NSX-T API
    $this.initialiseUrlMappings()

    $this.logger.LogInfo("NSXConfigManager initialised with standardized paths support", "NSXConfig")
  }

  # Helper method to extract hostname from FQDN
  hidden [string] GetHostnameFromFQDN([string] $fqdn) {
    if ([string]::IsNullOrEmpty($fqdn)) {
      return "unknown"
    }

    # Remove protocol if present
    $cleanFqdn = $fqdn -replace '^https?://', ''

    # Extract hostname (first part before first dot)
    $hostname = $cleanFqdn.Split('.')[0]

    # Clean up any invalid filename characters
    $hostname = $hostname -replace '[^\w\-]', '_'

    return $hostname.ToLower()
  }

  # Helper method to ensure manager-specific directory exists
  hidden [string] EnsureManagerDirectory([string] $nsxManager, [string] $subdirectory = "") {
    $hostname = $this.GetHostnameFromFQDN($nsxManager)

    # Build path: base/hostname or base/hostname/subdirectory
    $managerPath = Join-Path $this.configsDirectory $hostname
    if ($subdirectory) {
      $managerPath = Join-Path $managerPath $subdirectory
    }

    if (-not (Test-Path $managerPath)) {
      New-Item -Path $managerPath -ItemType Directory -Force | Out-Null
      $this.logger.LogInfo("Created manager directory: $managerPath", "NSXConfig")
    }

    return $managerPath
  }

  # initialise URL mappings for NSX-T API
  hidden [void] initialiseUrlMappings() {
    $this.urlMappings = @{
      "infra"                = "/policy/api/v1/infra"
      "global-infra"         = "/policy/api/v1/global-infra"
      "orgs"                 = "/policy/api/v1/orgs"
      "global-manager-infra" = "/global-manager/api/v1/global-infra"
    }
  }

  # Retrieves the entire NSX-T configuration from the specified manager.
  #
  # Parameters:
  #   [string] $nsxManager - NSX Manager FQDN
  #   [object] $credential - Credential object
  #   [string] $configType - Configuration type (default: "infra")
  #   [bool] $useSingleEndpoint - Use single endpoint (default: $false)
  # Returns: [object] Configuration object
  # Step 1: Retrieve entire configuration from NSX Manager
  [object] GetPolicyConfiguration([string] $nsxManager, [object] $credential, [string] $configType = "infra", [bool] $useSingleEndpoint = $false) {
    try {
      $this.logger.LogStep("Step 1: Retrieving entire configuration from NSX Manager")
      $this.logger.LogInfo("NSX Manager: $nsxManager", "NSXConfig")
      $this.logger.LogInfo("Config Type: $configType", "NSXConfig")
      $this.logger.LogInfo("Use Single Endpoint: $useSingleEndpoint", "NSXConfig")

      # MANDATORY: Detect actual manager type first to use correct endpoint
      $detectedManagerType = $this.DetectManagerType($nsxManager, $credential)
      $this.logger.LogInfo("Detected manager type: $detectedManagerType", "NSXConfig")

      # Determine the API endpoint based on detected manager type and config type
      $apiEndpoint = switch ($detectedManagerType) {
        "global_manager" {
          switch ($configType.ToLower()) {
            "infra" { $this.urlMappings["global-manager-infra"] }
            "global-infra" { $this.urlMappings["global-manager-infra"] }
            "auto" { $this.urlMappings["global-manager-infra"] }
            default { $this.urlMappings["global-manager-infra"] }
          }
        }
        "local_manager" {
          switch ($configType.ToLower()) {
            "infra" { $this.urlMappings["global-infra"] }
            "global-infra" { $this.urlMappings["global-infra"] }
            "auto" { $this.urlMappings["global-infra"] }
            default { $this.urlMappings["global-infra"] }
          }
        }
        "standalone" {
          switch ($configType.ToLower()) {
            "infra" { $this.urlMappings["infra"] }
            "global-infra" { $this.urlMappings["infra"] }  # Fallback to infra for standalone
            "auto" { $this.urlMappings["infra"] }
            default { $this.urlMappings["infra"] }
          }
        }
        default {
          $this.logger.LogError("Unknown manager type: $detectedManagerType", "NSXConfig")
          throw "Unknown manager type: $detectedManagerType"
        }
      }

      $this.logger.LogInfo("Selected API endpoint: $apiEndpoint for manager type: $detectedManagerType", "NSXConfig")

      # Build the full URL
      $url = "https://$nsxManager$apiEndpoint"
      $this.logger.LogInfo("API URL: $url", "NSXConfig")

      # Make the API call to retrieve the infra configuration using injected API service
      $this.logger.LogInfo("Making API call to retrieve infra configuration", "NSXConfig")

      # Use the injected API service which handles SSL and authentication properly
      try {
        $response = $this.apiService.InvokeRestMethod($nsxManager, $credential, $apiEndpoint, "GET", $null, @{})
      }
      catch {
        $this.logger.LogWarning("Policy API endpoint failed: $($_.Exception.Message)", "NSXConfig")

        # Check if this is an older NSX-T version that doesn't support policy API
        if ($_.Exception.Message -match "404|Not Found") {
          $this.logger.LogInfo("Policy API not available - attempting fallback for older NSX-T versions", "NSXConfig")

          # For older versions, create a minimal configuration structure
          $response = [PSCustomObject]@{
            resource_type = "Infra"
            id            = "infra"
            display_name  = "infra"
            children      = @()
          }

          $this.logger.LogInfo("Created minimal configuration structure for older NSX-T version", "NSXConfig")
        }
        else {
          # Re-throw if it's not a 404 error
          throw
        }
      }

      # Check if we should use only the single endpoint or if it already has children
      $hasChildren = $response.children -and $response.children.Count -gt 0

      # Handle dual configuration retrieval for local managers
      if ($detectedManagerType -eq "local_manager") {
        $this.logger.LogInfo("Local manager detected - retrieving BOTH global and local configurations", "NSXConfig")

        # Get global configuration (already retrieved above)
        $globalChildren = @()
        if ($response.children) {
          $globalChildren = $response.children
          $this.logger.LogInfo("Retrieved $($globalChildren.Count) global configuration objects", "NSXConfig")
        }

        # Also get local configuration
        $localChildren = @()
        $this.logger.LogInfo("Retrieving local configuration from local manager...", "NSXConfig")

        try {
          $localResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/policy/api/v1/infra", "GET", $null, @{})
          if ($localResponse.children) {
            $localChildren = $localResponse.children
            $this.logger.LogInfo("Retrieved $($localChildren.Count) local configuration objects", "NSXConfig")
          }
        }
        catch {
          $this.logger.LogWarning("Failed to retrieve local configuration: $($_.Exception.Message)", "NSXConfig")
        }

        # Combine global and local configurations
        $allChildren = @()

        # Add global configurations with scope marking
        foreach ($child in $globalChildren) {
          $child | Add-Member -MemberType NoteProperty -Name "_scope" -Value "global" -Force
          $allChildren += $child
        }

        # Add local configurations with scope marking
        foreach ($child in $localChildren) {
          $child | Add-Member -MemberType NoteProperty -Name "_scope" -Value "local" -Force
          $allChildren += $child
        }

        $response | Add-Member -MemberType NoteProperty -Name "children" -Value $allChildren -Force
        $this.logger.LogInfo("Combined configurations: $($globalChildren.Count) global + $($localChildren.Count) local = $($allChildren.Count) total", "NSXConfig")
      }
      elseif ($useSingleEndpoint -or $hasChildren) {
        $this.logger.LogInfo("Using single endpoint response - Children found: $($response.children.Count)", "NSXConfig")

        # Use the response as-is from the single endpoint
        $objectCount = if ($response.children) { $response.children.Count } else { 0 }
        $this.logger.LogInfo("Retrieved $objectCount configuration objects from single endpoint", "NSXConfig")
      }
      else {
        $this.logger.LogInfo("Single endpoint returned no children, retrieving complete configuration via separate API calls", "NSXConfig")

        $allChildren = @()

        # For local managers, retrieve from both global and local scopes
        if ($detectedManagerType -eq "local_manager") {
          $this.logger.LogInfo("Local manager detected - retrieving from both global and local scopes", "NSXConfig")

          # First retrieve global configuration objects
          $globalChildren = $this.RetrieveConfigurationObjectsFromSeparateAPIs($nsxManager, $credential, $detectedManagerType, "global")
          foreach ($child in $globalChildren) {
            $child | Add-Member -MemberType NoteProperty -Name "_scope" -Value "global" -Force
            $allChildren += $child
          }

          # Then retrieve local configuration objects
          $localChildren = $this.RetrieveConfigurationObjectsFromSeparateAPIs($nsxManager, $credential, $detectedManagerType, "local")
          foreach ($child in $localChildren) {
            $child | Add-Member -MemberType NoteProperty -Name "_scope" -Value "local" -Force
            $allChildren += $child
          }

          $this.logger.LogInfo("Combined separate API results: $($globalChildren.Count) global + $($localChildren.Count) local = $($allChildren.Count) total", "NSXConfig")
        }
        else {
          # For non-local managers, retrieve normally
          $allChildren = $this.RetrieveConfigurationObjectsFromSeparateAPIs($nsxManager, $credential, $detectedManagerType, "default")
        }

        # Add the populated children to the infra response
        $response | Add-Member -MemberType NoteProperty -Name "children" -Value $allChildren -Force
      }

      # Build the complete configuration object (common for both single endpoint and separate API calls)
      # Use the already detected manager type from earlier in the method
      $configuration = [PSCustomObject]@{
        metadata      = @{
          source_manager      = $nsxManager
          manager_type        = $detectedManagerType
          retrieval_timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
          config_type         = $configType
          api_endpoint        = $apiEndpoint
        }
        configuration = $response
      }

      $this.logger.LogInfo("Configuration retrieved successfully", "NSXConfig")
      $objectCount = if ($response.children) { $response.children.Count } else { 0 }
      $this.logger.LogInfo("Retrieved $objectCount configuration objects", "NSXConfig")

      return $configuration

    }
    catch {
      $this.logger.LogError("Failed to retrieve configuration: $($_.Exception.Message)", "NSXConfig")
      throw "Configuration retrieval failed: $($_.Exception.Message)"
    }
  }

  # Helper method to get base URL for API calls based on manager type
  hidden [string] GetBaseUrlForManagerType([string] $nsxManager, [string] $managerType) {
    $baseUrl = switch ($managerType) {
      "global_manager" { "https://$nsxManager/global-manager/api/v1/global-infra" }
      "local_manager" { "https://$nsxManager/policy/api/v1/global-infra" }
      "standalone" { "https://$nsxManager/policy/api/v1/infra" }
      default {
        $this.logger.LogError("Unknown manager type for base URL: $managerType", "NSXConfig")
        throw "Unknown manager type for base URL: $managerType"
      }
    }
    return $baseUrl
  }

  # Helper method to get correct API endpoint based on manager type and scope
  hidden [string] GetAPIEndpointForManagerType([string] $managerType, [string] $resourcePath, [string] $scope = "default") {
    $endpoint = switch ($managerType) {
      "global_manager" { "/global-manager/api/v1/global-infra/$resourcePath" }
      "local_manager" {
        if ($scope -eq "local") {
          "/policy/api/v1/infra/$resourcePath"
        }
        else {
          "/policy/api/v1/global-infra/$resourcePath"
        }
      }
      "standalone" { "/policy/api/v1/infra/$resourcePath" }
      default {
        $this.logger.LogError("Unknown manager type for API endpoint: $managerType", "NSXConfig")
        throw "Unknown manager type for API endpoint: $managerType"
      }
    }
    return $endpoint
  }

  # Helper method to retrieve configuration objects from separate API calls
  hidden [array] RetrieveConfigurationObjectsFromSeparateAPIs([string] $nsxManager, [object] $credential, [string] $managerType, [string] $scope) {
    $this.logger.LogInfo("Retrieving configuration objects from separate APIs - scope: $scope", "NSXConfig")

    $allChildren = @()

    # 1. Get all services
    $this.logger.LogInfo("Retrieving services...", "NSXConfig")
    try {
      $servicesEndpoint = $this.GetAPIEndpointForManagerType($managerType, "services", $scope)
      $servicesResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, $servicesEndpoint, "GET", $null, @{})
      if ($servicesResponse.results) {
        $this.logger.LogInfo("Retrieved $($servicesResponse.results.Count) services", "NSXConfig")
        foreach ($service in $servicesResponse.results) {
          $allChildren += @{
            resource_type = "ChildService"
            Service       = $service
          }
        }
      }
    }
    catch {
      $this.logger.LogWarning("Failed to retrieve services: $($_.Exception.Message)", "NSXConfig")

      # For older NSX-T versions, try alternative endpoints
      if ($_.Exception.Message -match "404|Not Found") {
        $this.logger.LogInfo("Policy API services endpoint not available - trying older API endpoints", "NSXConfig")

        # Try older management API endpoints for services
        try {
          $legacyServicesResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/api/v1/ns-services", "GET", $null, @{})
          if ($legacyServicesResponse.results) {
            $this.logger.LogInfo("Retrieved $($legacyServicesResponse.results.Count) services from legacy API", "NSXConfig")
            foreach ($service in $legacyServicesResponse.results) {
              $allChildren += @{
                resource_type = "ChildService"
                Service       = $service
              }
            }
          }
        }
        catch {
          $this.logger.LogWarning("Legacy services API also failed: $($_.Exception.Message)", "NSXConfig")
        }
      }
    }

    # 2. Get all Tier-0 gateways
    $this.logger.LogInfo("Retrieving Tier-0 gateways...", "NSXConfig")
    try {
      $tier0Endpoint = $this.GetAPIEndpointForManagerType($managerType, "tier-0s", $scope)
      $tier0Response = $this.apiService.InvokeRestMethod($nsxManager, $credential, $tier0Endpoint, "GET", $null, @{})
      if ($tier0Response.results) {
        $this.logger.LogInfo("Retrieved $($tier0Response.results.Count) Tier-0 gateways", "NSXConfig")
        foreach ($tier0 in $tier0Response.results) {
          $allChildren += @{
            resource_type = "ChildTier0"
            Tier0         = $tier0
          }
        }
      }
    }
    catch {
      $this.logger.LogWarning("Failed to retrieve Tier-0 gateways: $($_.Exception.Message)", "NSXConfig")
    }

    # 3. Get all Tier-1 gateways
    $this.logger.LogInfo("Retrieving Tier-1 gateways...", "NSXConfig")
    try {
      $tier1Endpoint = $this.GetAPIEndpointForManagerType($managerType, "tier-1s", $scope)
      $tier1Response = $this.apiService.InvokeRestMethod($nsxManager, $credential, $tier1Endpoint, "GET", $null, @{})
      if ($tier1Response.results) {
        $this.logger.LogInfo("Retrieved $($tier1Response.results.Count) Tier-1 gateways", "NSXConfig")
        foreach ($tier1 in $tier1Response.results) {
          $allChildren += @{
            resource_type = "ChildTier1"
            Tier1         = $tier1
          }
        }
      }
    }
    catch {
      $this.logger.LogWarning("Failed to retrieve Tier-1 gateways: $($_.Exception.Message)", "NSXConfig")
    }

    # 4. Get all network segments
    $this.logger.LogInfo("Retrieving network segments...", "NSXConfig")
    try {
      $segmentsEndpoint = $this.GetAPIEndpointForManagerType($managerType, "segments", $scope)
      $segmentsResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, $segmentsEndpoint, "GET", $null, @{})
      if ($segmentsResponse.results) {
        $this.logger.LogInfo("Retrieved $($segmentsResponse.results.Count) network segments", "NSXConfig")
        foreach ($segment in $segmentsResponse.results) {
          $allChildren += @{
            resource_type = "ChildSegment"
            Segment       = $segment
          }
        }
      }
    }
    catch {
      $this.logger.LogWarning("Failed to retrieve network segments: $($_.Exception.Message)", "NSXConfig")
    }

    # 5. Get all domains with their groups and security policies
    $this.logger.LogInfo("Retrieving domains...", "NSXConfig")
    try {
      $domainsEndpoint = $this.GetAPIEndpointForManagerType($managerType, "domains", $scope)
      $domainsResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, $domainsEndpoint, "GET", $null, @{})
      if ($domainsResponse.results) {
        $this.logger.LogInfo("Retrieved $($domainsResponse.results.Count) domains", "NSXConfig")

        foreach ($domain in $domainsResponse.results) {
          $domainChildren = @()

          # Get groups for this domain
          try {
            $groupsEndpoint = $this.GetAPIEndpointForManagerType($managerType, "domains/$($domain.id)/groups", $scope)
            $groupsResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, $groupsEndpoint, "GET", $null, @{})
            if ($groupsResponse.results) {
              $this.logger.LogInfo("Retrieved $($groupsResponse.results.Count) groups for domain '$($domain.id)'", "NSXConfig")
              foreach ($group in $groupsResponse.results) {
                $domainChildren += @{
                  resource_type = "ChildGroup"
                  Group         = $group
                }
              }
            }
          }
          catch {
            $this.logger.LogWarning("Failed to retrieve groups for domain '$($domain.id)': $($_.Exception.Message)", "NSXConfig")
          }

          # Get security policies for this domain
          try {
            $policiesEndpoint = $this.GetAPIEndpointForManagerType($managerType, "domains/$($domain.id)/security-policies", $scope)
            $policiesResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, $policiesEndpoint, "GET", $null, @{})
            if ($policiesResponse.results) {
              $this.logger.LogInfo("Retrieved $($policiesResponse.results.Count) security policies for domain '$($domain.id)'", "NSXConfig")
              foreach ($policy in $policiesResponse.results) {
                $domainChildren += @{
                  resource_type  = "ChildSecurityPolicy"
                  SecurityPolicy = $policy
                }
              }
            }
          }
          catch {
            $this.logger.LogWarning("Failed to retrieve security policies for domain '$($domain.id)': $($_.Exception.Message)", "NSXConfig")
          }

          # Add domain with its children
          $allChildren += @{
            resource_type = "ChildDomain"
            Domain        = @{
              resource_type = $domain.resource_type
              id            = $domain.id
              display_name  = $domain.display_name
              children      = $domainChildren
            }
          }
        }
      }
    }
    catch {
      $this.logger.LogWarning("Failed to retrieve domains: $($_.Exception.Message)", "NSXConfig")
    }

    $this.logger.LogInfo("Retrieved $($allChildren.Count) configuration objects from separate APIs", "NSXConfig")
    return $allChildren
  }

  # Detects the NSX Manager type (global_manager, local_manager, standalone).
  #
  # Parameters:
  #   [string] $nsxManager - NSX Manager FQDN
  #   [object] $credential - Credential object
  # Returns: [string] Manager type
  [string] DetectManagerType([string] $nsxManager, [object] $credential) {
    try {
      $this.logger.LogInfo("Detecting NSX Manager type for: $nsxManager", "NSXConfig")

      # Test 1: Try global manager specific endpoint
      $this.logger.LogInfo("Testing global manager endpoint", "NSXConfig")
      try {
        $globalResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/global-manager/api/v1/global-infra", "GET", $null, @{})
        if ($globalResponse) {
          $this.logger.LogInfo("Global manager endpoint responded successfully", "NSXConfig")
          return "global_manager"
        }
      }
      catch {
        $this.logger.LogDebug("Global manager endpoint failed: $($_.Exception.Message)", "NSXConfig")
      }

      # Test 2: Try local manager specific endpoint
      $this.logger.LogInfo("Testing local manager endpoint", "NSXConfig")
      try {
        $localResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/policy/api/v1/global-infra", "GET", $null, @{})
        if ($localResponse) {
          $this.logger.LogInfo("Local manager endpoint responded successfully", "NSXConfig")
          return "local_manager"
        }
      }
      catch {
        $this.logger.LogDebug("Local manager endpoint failed: $($_.Exception.Message)", "NSXConfig")
      }

      # Test 3: Try standalone manager endpoint
      $this.logger.LogInfo("Testing standalone manager endpoint", "NSXConfig")
      try {
        $standaloneResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/policy/api/v1/infra", "GET", $null, @{})
        if ($standaloneResponse) {
          $this.logger.LogInfo("Standalone manager endpoint responded successfully", "NSXConfig")
          return "standalone"
        }
      }
      catch {
        $this.logger.LogDebug("Standalone manager endpoint failed: $($_.Exception.Message)", "NSXConfig")
      }

      # Test 4: Check system information
      $this.logger.LogInfo("Testing system information", "NSXConfig")
      try {
        $systemResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/api/v1/node", "GET", $null, @{})
        if ($systemResponse) {
          $this.logger.LogInfo("System info retrieved successfully", "NSXConfig")

          # Check if node_type field exists (newer versions)
          if ($systemResponse.node_type) {
            $this.logger.LogInfo("System info detected - node_type: $($systemResponse.node_type)", "NSXConfig")

            switch ($systemResponse.node_type.ToUpper()) {
              "GLOBAL_MANAGER" { return "global_manager" }
              "LOCAL_MANAGER" { return "local_manager" }
              "MANAGER" { return "standalone" }
              default {
                $this.logger.LogWarning("Unknown node_type: $($systemResponse.node_type)", "NSXConfig")
              }
            }
          }
          else {
            # Older versions don't have node_type field
            $this.logger.LogInfo("System info response doesn't contain node_type field - likely older NSX-T version", "NSXConfig")
            $this.logger.LogInfo("Product version: $($systemResponse.product_version)", "NSXConfig")

            # For older versions, if we can connect to system API, it's likely a standalone manager
            # Test if we can access basic management API endpoints
            try {
              $clustersResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/api/v1/clusters", "GET", $null, @{})
              if ($clustersResponse) {
                $this.logger.LogInfo("Management API accessible - treating as standalone manager", "NSXConfig")
                return "standalone"
              }
            }
            catch {
              $this.logger.LogDebug("Clusters API test failed: $($_.Exception.Message)", "NSXConfig")
            }
          }
        }
      }
      catch {
        $this.logger.LogDebug("System info test failed: $($_.Exception.Message)", "NSXConfig")
      }

      # Test 5: Final fallback - Check federation configuration
      $this.logger.LogInfo("Testing federation configuration", "NSXConfig")
      try {
        $federationResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/api/v1/global-infra/federation-config", "GET", $null, @{})
        if ($federationResponse -and $federationResponse.mode) {
          $this.logger.LogInfo("Federation config detected - mode: $($federationResponse.mode)", "NSXConfig")

          switch ($federationResponse.mode.ToUpper()) {
            "GLOBAL_MANAGER" { return "global_manager" }
            "LOCAL_MANAGER" { return "local_manager" }
            default {
              $this.logger.LogWarning("Unknown federation mode: $($federationResponse.mode)", "NSXConfig")
            }
          }
        }
      }
      catch {
        $this.logger.LogDebug("Federation config test failed: $($_.Exception.Message)", "NSXConfig")
      }

      # Test 6: Ultimate fallback - If we can connect to system info but no other endpoints work
      # This handles older NSX-T versions that don't have modern API endpoints
      $this.logger.LogInfo("Testing ultimate fallback for older NSX-T versions", "NSXConfig")
      try {
        $systemResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/api/v1/node", "GET", $null, @{})
        if ($systemResponse -and $systemResponse.product_version) {
          $this.logger.LogInfo("System API accessible with product version: $($systemResponse.product_version)", "NSXConfig")
          $this.logger.LogInfo("Policy API endpoints not available - likely older NSX-T version", "NSXConfig")
          $this.logger.LogInfo("Defaulting to standalone manager type for older version", "NSXConfig")
          return "standalone"
        }
      }
      catch {
        $this.logger.LogDebug("Ultimate fallback test failed: $($_.Exception.Message)", "NSXConfig")
      }

      # If all detection methods fail, this is a critical error
      $this.logger.LogError("CRITICAL: Unable to determine NSX Manager type for $nsxManager", "NSXConfig")
      throw "CRITICAL: Unable to determine NSX Manager type for $nsxManager - All detection methods failed"

    }
    catch {
      $this.logger.LogError("Failed to detect manager type: $($_.Exception.Message)", "NSXConfig")
      throw "Manager type detection failed: $($_.Exception.Message)"
    }
  }

  # Retrieves the entire configuration using the single endpoint approach.
  #
  # Parameters:
  #   [string] $nsxManager - NSX Manager FQDN
  #   [object] $credential - Credential object
  #   [string] $configType - Configuration type (default: "infra")
  # Returns: [object] Configuration object
  [object] GetPolicyConfigurationFromSingleEndpoint([string] $nsxManager, [object] $credential, [string] $configType = "infra") {
    $this.logger.LogInfo("Using single endpoint approach to retrieve entire configuration", "NSXConfig")
    return $this.GetPolicyConfiguration($nsxManager, $credential, $configType, $true)
  }

  # Saves the configuration to the data/exports/{hostname}/ directory using standardized file naming.
  #
  # Parameters:
  #   [object] $configuration - Configuration object
  #   [string] $sourceManager - Source NSX Manager FQDN
  #   [string] $operation - Operation type (default: "full_backup")
  # Returns: [string] Path to saved file
  [string] SaveConfiguration([object] $configuration, [string] $sourceManager, [string] $operation = "full_backup") {
    try {
      $this.logger.LogStep("Step 2: Saving configuration to data/exports/{hostname}/ directory")

      # Generate reverse timestamp (YYYYMMDD_HHMMSS format for sorting)
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

      # Extract hostname and create manager-specific directory
      $hostname = $this.GetHostnameFromFQDN($sourceManager)
      $managerDirectory = $this.EnsureManagerDirectory($sourceManager, "")

      # Generate filename using StandardFileNamingService if available, otherwise use fallback
      if ($this.fileNamingService) {
        $filename = $this.fileNamingService.GenerateStandardizedFileNameWithTimestamp($sourceManager, "default", $operation, $timestamp, "json")
      }
      else {
        # Fallback to original naming convention
        $filename = "${timestamp}_${hostname}_${operation}.json"
      }
      $filePath = Join-Path $managerDirectory $filename

      # Convert configuration to JSON and save
      $jsonOutput = $configuration | ConvertTo-Json -Depth 20 -Compress
      $jsonOutput | Out-File -FilePath $filePath -Encoding UTF8

      $this.logger.LogInfo("Configuration saved to: $filePath", "NSXConfig")

      # Log file details
      $fileInfo = Get-Item $filePath
      $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
      $this.logger.LogInfo("File size: $fileSizeKB KB", "NSXConfig")

      return $filePath

    }
    catch {
      $this.logger.LogError("Failed to save configuration: $($_.Exception.Message)", "NSXConfig")
      throw "Configuration save failed: $($_.Exception.Message)"
    }
  }

  # Applies the configuration to the target NSX Manager.
  #
  # Parameters:
  #   [string] $targetManager - Target NSX Manager FQDN
  #   [object] $credential - Credential object
  #   [object] $configuration - Configuration object
  #   [string] $httpMethod - HTTP method (default: "PATCH")
  # Returns: [object] Result object with success status and response
  [object] ApplyConfiguration([string] $targetManager, [object] $credential, [object] $configuration, [string] $httpMethod = "PATCH") {
    try {
      $this.logger.LogStep("Step 3: Applying configuration to target NSX Manager")
      $this.logger.LogInfo("Target Manager: $targetManager", "NSXConfig")
      $this.logger.LogInfo("HTTP Method: $httpMethod", "NSXConfig")

      # Extract the configuration data (remove metadata wrapper)
      $configData = $configuration.configuration

      # Debug logging to understand data structure
      $this.logger.LogInfo("ConfigData structure - Has children: $($configData.children -ne $null), Has infra: $($configData.infra -ne $null)", "NSXConfig")

      # Transform configuration to hierarchical structure required by NSX-T Policy API
      $hierarchicalChildren = @()
      $originalChildren = $null

      if ($configData.children) {
        $originalChildren = $configData.children
      }
      elseif ($configData.infra -and $configData.infra.children) {
        $originalChildren = $configData.infra.children
      }

      if ($originalChildren) {
        foreach ($child in $originalChildren) {
          $wrappedChild = $this.WrapObjectInHierarchicalContainer($child)
          if ($wrappedChild) {
            $hierarchicalChildren += $wrappedChild
          }
        }
      }

      # Build the correct hierarchical infra structure
      $payloadData = [PSCustomObject]@{
        resource_type = "Infra"
        id            = "infra"
        display_name  = "infra"
        children      = $hierarchicalChildren
      }

      $this.logger.LogInfo("Transformed $($hierarchicalChildren.Count) objects to hierarchical structure", "NSXConfig")

      # Convert configuration to JSON for the request
      $jsonPayload = $payloadData | ConvertTo-Json -Depth 20 -Compress

      # Log payload structure for debugging
      $this.logger.LogInfo("Request payload size: $($jsonPayload.Length) characters", "NSXConfig")
      $this.logger.LogInfo("Applying configuration via $httpMethod method", "NSXConfig")

      # Log full request body in debug mode for detailed troubleshooting
      if ($this.logger.logLevel -eq "DEBUG") {
        $this.logger.LogDebug("FULL REQUEST BODY: $jsonPayload", "NSXConfig")
      }
      else {
        $this.logger.LogInfo("Payload structure preview: $($jsonPayload.Substring(0, [Math]::Min(200, $jsonPayload.Length)))", "NSXConfig")
      }

      # Determine API endpoint based on target manager type
      $targetManagerType = $this.DetectManagerType($targetManager, $credential)
      $this.logger.LogInfo("Target manager type detected: $targetManagerType", "NSXConfig")

      # Handle dual scope application for local managers
      if ($targetManagerType -eq "local_manager") {
        $this.logger.LogInfo("Local manager detected - checking for dual scope configuration", "NSXConfig")

        # Separate objects by scope
        $globalScopeObjects = @()
        $localScopeObjects = @()
        $noScopeObjects = @()

        foreach ($child in $hierarchicalChildren) {
          if ($child._scope -eq "global") {
            $globalScopeObjects += $child
          }
          elseif ($child._scope -eq "local") {
            $localScopeObjects += $child
          }
          else {
            $noScopeObjects += $child
          }
        }

        $this.logger.LogInfo("Scope distribution: Global=$($globalScopeObjects.Count), Local=$($localScopeObjects.Count), No scope=$($noScopeObjects.Count)", "NSXConfig")

        $results = @()

        # Apply global scope objects to global-infra endpoint
        if ($globalScopeObjects.Count -gt 0) {
          $this.logger.LogInfo("Applying $($globalScopeObjects.Count) global scope objects", "NSXConfig")

          # Remove scope metadata before applying
          foreach ($obj in $globalScopeObjects) {
            $obj.PSObject.Properties.Remove("_scope")
          }

          $globalPayload = [PSCustomObject]@{
            resource_type = "Infra"
            id            = "infra"
            display_name  = "infra"
            children      = $globalScopeObjects
          }

          $globalJsonPayload = $globalPayload | ConvertTo-Json -Depth 20 -Compress
          $globalResponse = $this.apiService.InvokeRestMethod($targetManager, $credential, "/policy/api/v1/global-infra", $httpMethod, $globalJsonPayload, @{})

          $results += @{
            scope    = "global"
            endpoint = "/policy/api/v1/global-infra"
            count    = $globalScopeObjects.Count
            response = $globalResponse
          }
        }

        # Apply local scope objects to infra endpoint
        if ($localScopeObjects.Count -gt 0) {
          $this.logger.LogInfo("Applying $($localScopeObjects.Count) local scope objects", "NSXConfig")

          # Remove scope metadata before applying
          foreach ($obj in $localScopeObjects) {
            $obj.PSObject.Properties.Remove("_scope")
          }

          $localPayload = [PSCustomObject]@{
            resource_type = "Infra"
            id            = "infra"
            display_name  = "infra"
            children      = $localScopeObjects
          }

          $localJsonPayload = $localPayload | ConvertTo-Json -Depth 20 -Compress
          $localResponse = $this.apiService.InvokeRestMethod($targetManager, $credential, "/policy/api/v1/infra", $httpMethod, $localJsonPayload, @{})

          $results += @{
            scope    = "local"
            endpoint = "/policy/api/v1/infra"
            count    = $localScopeObjects.Count
            response = $localResponse
          }
        }

        # Apply no scope objects to global-infra endpoint (default for local managers)
        if ($noScopeObjects.Count -gt 0) {
          $this.logger.LogInfo("Applying $($noScopeObjects.Count) no-scope objects to global-infra endpoint", "NSXConfig")

          $noScopePayload = [PSCustomObject]@{
            resource_type = "Infra"
            id            = "infra"
            display_name  = "infra"
            children      = $noScopeObjects
          }

          $noScopeJsonPayload = $noScopePayload | ConvertTo-Json -Depth 20 -Compress
          $noScopeResponse = $this.apiService.InvokeRestMethod($targetManager, $credential, "/policy/api/v1/global-infra", $httpMethod, $noScopeJsonPayload, @{})

          $results += @{
            scope    = "no-scope"
            endpoint = "/policy/api/v1/global-infra"
            count    = $noScopeObjects.Count
            response = $noScopeResponse
          }
        }

        $this.logger.LogInfo("Dual scope configuration applied successfully", "NSXConfig")
        $response = [PSCustomObject]@{
          dual_scope_results = $results
          total_objects      = $hierarchicalChildren.Count
        }
      }
      else {
        # Single scope application for non-local managers
        $apiEndpoint = switch ($targetManagerType) {
          "global_manager" { "/global-manager/api/v1/global-infra" }
          "standalone" { "/policy/api/v1/infra" }
          default { "/policy/api/v1/infra" }  # Default fallback
        }

        $this.logger.LogInfo("API Endpoint: $apiEndpoint", "NSXConfig")

        # Use the injected API service to make the call with configurable method
        $response = $this.apiService.InvokeRestMethod($targetManager, $credential, $apiEndpoint, $httpMethod, $jsonPayload, @{})

        $this.logger.LogInfo("Configuration applied successfully", "NSXConfig")
      }

      return @{
        success           = $true
        response          = $response
        target_manager    = $targetManager
        applied_timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        http_method       = $httpMethod
      }

    }
    catch {
      $this.logger.LogError("Failed to apply configuration: $($_.Exception.Message)", "NSXConfig")
      return @{
        success          = $false
        error            = $_.Exception.Message
        target_manager   = $targetManager
        failed_timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        http_method      = $httpMethod
      }
    }
  }

  # Helper method to wrap objects in hierarchical containers as required by NSX-T Policy API
  [object] WrapObjectInHierarchicalContainer([object] $obj) {
    try {
      if (-not $obj.resource_type) {
        $this.logger.LogWarning("Object missing resource_type, skipping: $($obj | ConvertTo-Json -Depth 2)", "NSXConfig")
        return $null
      }

      $resourceType = $obj.resource_type
      $this.logger.LogInfo("Processing object of type: $resourceType", "NSXConfig")

      # Check if object is already in hierarchical format (starts with "Child")
      if ($resourceType.StartsWith("Child")) {
        $this.logger.LogInfo("Object already in hierarchical format: $resourceType", "NSXConfig")

        # Handle special case: ChildResourceReference should be converted to appropriate type
        if ($resourceType -eq "ChildResourceReference" -and $obj.target_type) {
          $targetType = $obj.target_type
          $this.logger.LogInfo("Converting ChildResourceReference with target_type '$targetType' to Child$targetType", "NSXConfig")

          # Create proper hierarchical structure for the target type
          if ($targetType -eq "Domain") {
            # Process nested children through hierarchical wrapping logic
            $processedChildren = @()
            if ($obj.children) {
              foreach ($child in $obj.children) {
                $wrappedChild = $this.WrapObjectInHierarchicalContainer($child)
                if ($wrappedChild) {
                  $processedChildren += $wrappedChild
                }
              }
            }

            $this.logger.LogInfo("Processed $($processedChildren.Count) nested children for Domain", "NSXConfig")

            return @{
              resource_type = "ChildDomain"
              Domain        = @{
                resource_type = "Domain"
                id            = $obj.id
                display_name  = if ($obj.display_name) { $obj.display_name } else { $obj.id }
                children      = $processedChildren
              }
            }
          }
          else {
            # Generic conversion for other target types
            $convertedObj = $obj.PSObject.Copy()
            $convertedObj.resource_type = "Child$targetType"
            $convertedObj.PSObject.Properties.Remove("target_type")
            return $convertedObj
          }
        }
        else {
          # Object is already in proper hierarchical format
          return $obj
        }
      }

      # Transform regular objects to hierarchical format
      $hierarchicalObj = switch ($resourceType) {
        "Service" {
          @{
            resource_type = "ChildService"
            Service       = $obj
          }
        }
        "Group" {
          @{
            resource_type = "ChildGroup"
            Group         = $obj
          }
        }
        "SecurityPolicy" {
          @{
            resource_type  = "ChildSecurityPolicy"
            SecurityPolicy = $obj
          }
        }
        "Rule" {
          @{
            resource_type = "ChildRule"
            Rule          = $obj
          }
        }
        "Domain" {
          # Process nested children for Domain
          $processedChildren = @()
          if ($obj.children) {
            foreach ($child in $obj.children) {
              $wrappedChild = $this.WrapObjectInHierarchicalContainer($child)
              if ($wrappedChild) {
                $processedChildren += $wrappedChild
              }
            }
          }

          @{
            resource_type = "ChildDomain"
            Domain        = @{
              resource_type = "Domain"
              id            = $obj.id
              display_name  = if ($obj.display_name) { $obj.display_name } else { $obj.id }
              children      = $processedChildren
            }
          }
        }
        "Tier0" {
          @{
            resource_type = "ChildTier0"
            Tier0         = $obj
          }
        }
        "Tier1" {
          @{
            resource_type = "ChildTier1"
            Tier1         = $obj
          }
        }
        "Segment" {
          @{
            resource_type = "ChildSegment"
            Segment       = $obj
          }
        }
        default {
          $this.logger.LogWarning("Unknown resource type '$resourceType', creating generic child wrapper", "NSXConfig")
          @{
            resource_type = "Child$resourceType"
            $resourceType = $obj
          }
        }
      }

      return $hierarchicalObj

    }
    catch {
      $this.logger.LogError("Failed to wrap object in hierarchical container: $($_.Exception.Message)", "NSXConfig")
      return $null
    }
  }

  # List all saved configurations in the data/exports directory
  #
  # Parameters:
  #   [string] $nsxManager - Optional NSX Manager FQDN to filter
  # Returns: [array] List of configuration file metadata
  [array] ListSavedConfigurations([string] $nsxManager = $null) {
    try {
      $this.logger.LogInfo("Listing saved configurations", "NSXConfig")

      if ($nsxManager) {
        # List configurations for a specific manager
        $hostname = $this.GetHostnameFromFQDN($nsxManager)
        $managerDirectory = Join-Path $this.configsDirectory $hostname

        if (-not (Test-Path $managerDirectory)) {
          $this.logger.LogWarning("No configurations found for manager: $nsxManager", "NSXConfig")
          return @()
        }

        $configFiles = Get-ChildItem -Path $managerDirectory -Filter "*.json" | Sort-Object Name -Descending

        $this.logger.LogInfo("Found $($configFiles.Count) configuration files for manager: $nsxManager", "NSXConfig")
      }
      else {
        # List all configurations across all managers
        if (-not (Test-Path $this.configsDirectory)) {
          $this.logger.LogWarning("No configurations directory found", "NSXConfig")
          return @()
        }

        $configFiles = Get-ChildItem -Path $this.configsDirectory -Filter "*.json" -Recurse | Sort-Object Name -Descending

        $this.logger.LogInfo("Found $($configFiles.Count) configuration files across all managers", "NSXConfig")
      }

      $configurations = @()
      foreach ($file in $configFiles) {
        $configurations += @{
          filename  = $file.Name
          full_path = $file.FullName
          size_kb   = [math]::Round($file.Length / 1KB, 2)
          created   = $file.CreationTime
          modified  = $file.LastWriteTime
          directory = $file.DirectoryName
          manager   = Split-Path $file.DirectoryName -Leaf
        }
      }

      return $configurations

    }
    catch {
      $this.logger.LogError("Failed to list saved configurations: $($_.Exception.Message)", "NSXConfig")
      return @()
    }
  }

  # Loads a configuration from a file.
  #
  # Parameters:
  #   [string] $filePath - Path to configuration file
  # Returns: [object] Configuration object
  [object] LoadConfiguration([string] $filePath) {
    try {
      $this.logger.LogInfo("Loading configuration from: $filePath", "NSXConfig")

      if (-not (Test-Path $filePath)) {
        throw "Configuration file not found: $filePath"
      }

      $jsonContent = Get-Content $filePath -Raw
      $configuration = $jsonContent | ConvertFrom-Json

      $this.logger.LogInfo("Configuration loaded successfully", "NSXConfig")

      return $configuration

    }
    catch {
      $this.logger.LogError("Failed to load configuration: $($_.Exception.Message)", "NSXConfig")
      throw "Configuration load failed: $($_.Exception.Message)"
    }
  }
}
