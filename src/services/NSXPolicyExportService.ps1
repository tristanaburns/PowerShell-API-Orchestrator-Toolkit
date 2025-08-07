# NSXPolicyExportService.ps1
# Dedicated service for NSX policy configuration exports
# Handles GET operations for policy/../infra and stores in ./data/exports/(managername) directory

class NSXPolicyExportService {
  [object] $logger
  [object] $apiService
  [string] $baseExportPath
  [object] $exportHistory
  [object] $fileNamingService
  [object] $configValidator
  [array] $usedEndpoints
  [object] $discoveredDomainDetails

  # All dependencies must be provided by the CoreServiceFactory. Do not instantiate or fetch services globally inside this class.
  NSXPolicyExportService([object] $logger, [object] $apiService, [object] $fileNamingService = $null, [object] $configValidator = $null) {
    $this.logger = $logger
    $this.apiService = $apiService
    $this.baseExportPath = "./data/exports"
    $this.exportHistory = [PSCustomObject]@{}
    $this.usedEndpoints = @()
    $this.discoveredDomainDetails = [PSCustomObject]@{}
    $this.fileNamingService = $fileNamingService
    $this.configValidator = $configValidator

    $this.initialiseExportDirectories()
    $this.logger.LogInfo("NSX Policy Export Service initialised", "PolicyExport")
  }

  # initialise export directories
  hidden [void] initialiseExportDirectories() {
    try {
      if (-not (Test-Path $this.baseExportPath)) {
        New-Item -ItemType Directory -Path $this.baseExportPath -Force | Out-Null
        $this.logger.LogInfo("Created base export directory: $($this.baseExportPath)", "PolicyExport")
      }
    }
    catch {
      $this.logger.LogError("Failed to initialise export directories: $($_.Exception.Message)", "PolicyExport")
      throw
    }
  }

  # Generate standardised filename: (datestamp)-(nsxmgrname)-(nsxdomain)-(function)
  hidden [string] GenerateStandardisedFileName([string] $nsxManager, [string] $nsxDomain, [string] $function, [string] $extension = "json") {
    # Use StandardFileNamingService if available, otherwise fallback to original method
    if ($this.fileNamingService) {
      return $this.fileNamingService.GenerateStandardizedFileName($nsxManager, $nsxDomain, $function, $extension)
    }
    else {
      # Fallback to original method
      $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
      $cleanManagerName = $this.CleanNameForFilename($nsxManager)
      $cleanDomainName = $this.CleanNameForFilename($nsxDomain)
      $cleanFunction = $this.CleanNameForFilename($function)

      return "$timestamp-$cleanManagerName-$cleanDomainName-$cleanFunction.$extension"
    }
  }

  # Clean name for filename (remove invalid characters)
  hidden [string] CleanNameForFilename([string] $name) {
    return $name -replace '[^a-zA-Z0-9\-\.]', '_'
  }

  # Get manager-specific export directory
  hidden [string] GetManagerExportDirectory([string] $nsxManager) {
    # Extract just the hostname part (before the first dot)
    $hostname = if ($nsxManager.Contains('.')) {
      $nsxManager.Split('.')[0]
    }
    else {
      $nsxManager
    }

    $cleanManagerName = $this.CleanNameForFilename($hostname)
    $managerDir = Join-Path $this.baseExportPath $cleanManagerName

    if (-not (Test-Path $managerDir)) {
      New-Item -ItemType Directory -Path $managerDir -Force | Out-Null
      $this.logger.LogInfo("Created manager export directory: $managerDir", "PolicyExport")
    }

    return $managerDir
  }

  # Export policy configuration from NSX Manager
  [object] ExportPolicyConfiguration([string] $nsxManager, [PSCredential] $credential, [string] $nsxDomain = "default", [object] $options = [PSCustomObject]@{}) {
    try {
      $this.logger.LogStep("Exporting policy configuration from NSX Manager")
      $this.logger.LogInfo("NSX Manager: $nsxManager", "PolicyExport")
      $this.logger.LogInfo("NSX Domain: $nsxDomain", "PolicyExport")

      # Detect manager type
      $managerType = $this.DetectManagerType($nsxManager, $credential)
      $this.logger.LogInfo("Manager type detected: $managerType", "PolicyExport")

      # Reset endpoint tracking for this export
      $this.usedEndpoints = @()

      # Get configuration based on manager type
      $policyConfig = $this.RetrievePolicyConfiguration($nsxManager, $credential, $managerType, $nsxDomain, $options)

      # Save exported configuration
      $savedFiles = $this.SaveExportedConfiguration($policyConfig, $nsxManager, $nsxDomain, $managerType)

      # Update export history
      $this.UpdateExportHistory($nsxManager, $nsxDomain, $savedFiles)

      return @{
        success          = $true
        manager_type     = $managerType
        domain           = $nsxDomain
        object_count     = $this.GetObjectCount($policyConfig)
        saved_files      = $savedFiles
        export_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      }
    }
    catch {
      $this.logger.LogError("Failed to export policy configuration: $($_.Exception.Message)", "PolicyExport")
      return @{
        success          = $false
        error            = $_.Exception.Message
        manager          = $nsxManager
        domain           = $nsxDomain
        export_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      }
    }
  }

  # Discover all available domains from NSX Manager
  [array] DiscoverAllDomains([string] $nsxManager, [PSCredential] $credential) {
    try {
      $this.logger.LogInfo("Discovering all available domains from NSX Manager: $nsxManager", "PolicyExport")

      $domains = @()
      $domainEndpoints = @(
        "/policy/api/v1/global-infra/domains",
        "/policy/api/v1/infra/domains",
        "/global-manager/api/v1/global-infra/domains"
      )

      foreach ($endpoint in $domainEndpoints) {
        try {
          $this.logger.LogDebug("Trying domain discovery endpoint: $endpoint", "PolicyExport")
          $this.usedEndpoints += $endpoint

          $result = $this.apiService.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET", $null, @{})

          if ($result -and $result.results) {
            $this.logger.LogDebug("Found $($result.results.Count) domain(s) at endpoint: $endpoint", "PolicyExport")
            foreach ($domain in $result.results) {
              if ($domain.id -and $domains -notcontains $domain.id) {
                $domains += $domain.id
                $this.logger.LogDebug("Discovered domain: $($domain.id)", "PolicyExport")
              }
            }
          }
        }
        catch {
          $this.logger.LogDebug("Domain discovery failed for endpoint $endpoint : $($_.Exception.Message)", "PolicyExport")
        }
      }

      if ($domains.Count -eq 0) {
        $this.logger.LogWarning("No domains discovered from any endpoint. Adding default domain as fallback.", "PolicyExport")
        $domains += "default"
      }

      $this.logger.LogInfo("Domain discovery completed. Found $($domains.Count) domains: $($domains -join ', ')", "PolicyExport")
      return $domains
    }
    catch {
      $this.logger.LogError("Failed to discover domains: $($_.Exception.Message)", "PolicyExport")
      $this.logger.LogWarning("Falling back to default domain only", "PolicyExport")
      return @("default")
    }
  }

  # Export policy configuration from all discovered domains
  [object] ExportAllDomainConfigurations([string] $nsxManager, [PSCredential] $credential, [object] $options = [PSCustomObject]@{}) {
    try {
      $this.logger.LogStep("Exporting policy configuration from ALL discovered domains")
      $this.logger.LogInfo("NSX Manager: $nsxManager", "PolicyExport")

      # Detect manager type first
      $managerType = $this.DetectManagerType($nsxManager, $credential)
      $this.logger.LogInfo("Manager type detected: $managerType", "PolicyExport")

      # Reset endpoint tracking
      $this.usedEndpoints = @()
      $exportStartTime = Get-Date

      # Discover all available domains
      $this.logger.LogInfo("Discovering all available domains", "PolicyExport")
      $domains = $this.DiscoverAllDomains($nsxManager, $credential)
      $this.logger.LogInfo("Found $($domains.Count) domains for export: $($domains -join ', ')", "PolicyExport")

      # Initialize export tracking
      $domainExports = [PSCustomObject]@{}
      $allSavedFiles = [PSCustomObject]@{}
      $totalObjectCount = 0
      $successfulDomains = 0
      $exportErrors = @()

      # Export each domain individually
      $domainCounter = 0
      foreach ($domain in $domains) {
        $domainCounter++
        try {
          $this.logger.LogInfo("=== Exporting domain $domainCounter of $($domains.Count): '$domain' ===", "PolicyExport")

          # Export single domain configuration
          $domainResult = $this.ExportPolicyConfiguration($nsxManager, $credential, $domain, $options)

          if ($domainResult.success) {
            $domainExports[$domain] = $domainResult
            $totalObjectCount += $domainResult.object_count
            $successfulDomains++

            # Collect saved files
            if ($domainResult.saved_files) {
              $allSavedFiles[$domain] = $domainResult.saved_files
            }

            $this.logger.LogInfo("[SUCCESS] Domain '$domain' exported successfully: $($domainResult.object_count) objects", "PolicyExport")
          }
          else {
            throw "Export failed: $($domainResult.error)"
          }
        }
        catch {
          $errorInfo = [PSCustomObject]@{
            domain         = $domain
            error          = $_.Exception.Message
            export_time    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            exception_type = $_.Exception.GetType().Name
          }
          $exportErrors += $errorInfo

          $this.logger.LogError("[ERROR] Domain '$domain' export failed: $($_.Exception.Message)", "PolicyExport")

          $domainExports[$domain] = @{
            success          = $false
            error            = $_.Exception.Message
            domain           = $domain
            export_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            exception_type   = $_.Exception.GetType().Name
          }
        }
      }

      $totalDuration = (Get-Date) - $exportStartTime

      # Create multi-domain summary
      $allDomainsConfig = $this.CreateMultiDomainSummary($domainExports, $nsxManager, $managerType, $domains.Count, $successfulDomains, $exportErrors, $totalDuration)

      # Save multi-domain summary file
      $summaryFile = $this.SaveMultiDomainSummary($allDomainsConfig, $nsxManager, $domains.Count)

      # Update export history
      $this.UpdateMultiDomainExportHistory($nsxManager, $domains, $domainExports, $summaryFile)

      # Determine overall success
      $overallSuccess = $successfulDomains -gt 0

      $this.logger.LogInfo("=== Multi-Domain Export Completed ===", "PolicyExport")
      $this.logger.LogInfo("Domains Processed: $($domains.Count)", "PolicyExport")
      $this.logger.LogInfo("Successful: $successfulDomains", "PolicyExport")
      $this.logger.LogInfo("Failed: $($exportErrors.Count)", "PolicyExport")
      $this.logger.LogInfo("Total Objects: $totalObjectCount", "PolicyExport")

      return @{
        success                = $overallSuccess
        manager_type           = $managerType
        nsx_manager            = $nsxManager
        domains_exported       = $domains.Count
        successful_exports     = $successfulDomains
        failed_exports         = $exportErrors.Count
        total_object_count     = $totalObjectCount
        domain_results         = $domainExports
        saved_files            = $allSavedFiles
        summary_file           = $summaryFile
        exported_domains       = $domains
        export_errors          = $exportErrors
        used_endpoints         = $this.usedEndpoints
        total_duration_seconds = $totalDuration.TotalSeconds
        export_timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      }
    }
    catch {
      $this.logger.LogError("Critical failure in multi-domain export: $($_.Exception.Message)", "PolicyExport")
      return @{
        success            = $false
        error              = "Critical failure in multi-domain export: $($_.Exception.Message)"
        nsx_manager        = $nsxManager
        manager_type       = "unknown"
        total_domains      = 0
        successful_domains = 0
        failed_domains     = 0
        export_timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      }
    }
  }

  # Retrieve policy configuration based on manager type
  hidden [object] RetrievePolicyConfiguration([string] $nsxManager, [PSCredential] $credential, [string] $managerType, [string] $nsxDomain, [object] $options) {
    $this.logger.LogInfo("Retrieving policy configuration from $managerType", "PolicyExport")

    # Handle dual configuration retrieval for local managers
    if ($managerType -eq "local_manager") {
      return $this.RetrieveDualScopeConfiguration($nsxManager, $credential, $nsxDomain, $options)
    }
    else {
      return $this.RetrieveSingleScopeConfiguration($nsxManager, $credential, $managerType, $nsxDomain, $options)
    }
  }

  # Retrieve dual scope configuration (global + local) for local managers
  hidden [object] RetrieveDualScopeConfiguration([string] $nsxManager, [PSCredential] $credential, [string] $nsxDomain, [object] $options) {
    $this.logger.LogInfo("Retrieving dual scope configuration (global + local) for domain: $nsxDomain", "PolicyExport")

    # Use domain-specific endpoints when domain is not 'default'
    if ($nsxDomain -eq "default") {
      # For default domain, use the root infra endpoints
      $globalEndpoint = "/policy/api/v1/global-infra"
      $localEndpoint = "/policy/api/v1/infra"
    }
    else {
      # For non-default domains, use domain-specific endpoints
      $globalEndpoint = "/policy/api/v1/global-infra/domains/$nsxDomain"
      $localEndpoint = "/policy/api/v1/infra/domains/$nsxDomain"
    }

    $this.logger.LogInfo("Using endpoints - Global: $globalEndpoint, Local: $localEndpoint", "PolicyExport")
    $globalConfig = $this.RetrieveConfigurationFromEndpoint($nsxManager, $credential, $globalEndpoint, "global", $options)
    $localConfig = $this.RetrieveConfigurationFromEndpoint($nsxManager, $credential, $localEndpoint, "local", $options)

    # Combine configurations with scope marking
    $combinedConfig = [PSCustomObject]@{
      resource_type = "Infra"
      id            = "infra"
      display_name  = "infra"
      children      = @()
    }

    # Add global scope objects
    if ($globalConfig.children) {
      foreach ($child in $globalConfig.children) {
        $child | Add-Member -MemberType NoteProperty -Name "_scope" -Value "global" -Force
        $combinedConfig.children += $child
      }
    }

    # Add local scope objects
    if ($localConfig.children) {
      foreach ($child in $localConfig.children) {
        $child | Add-Member -MemberType NoteProperty -Name "_scope" -Value "local" -Force
        $combinedConfig.children += $child
      }
    }

    $this.logger.LogInfo("Combined configuration: $($globalConfig.children.Count) global + $($localConfig.children.Count) local = $($combinedConfig.children.Count) total", "PolicyExport")

    return @{
      metadata      = @{
        source_manager      = $nsxManager
        manager_type        = "local_manager"
        domain              = $nsxDomain
        retrieval_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        config_type         = "dual_scope_policy_export"
        scopes              = @{
          global_objects = $globalConfig.children.Count
          local_objects  = $localConfig.children.Count
        }
      }
      configuration = $combinedConfig
    }
  }

  # Retrieve single scope configuration for non-local managers
  hidden [object] RetrieveSingleScopeConfiguration([string] $nsxManager, [PSCredential] $credential, [string] $managerType, [string] $nsxDomain, [object] $options) {
    $this.logger.LogInfo("Retrieving single scope configuration for domain: $nsxDomain (manager type: $managerType)", "PolicyExport")

    # Build domain-specific endpoints based on manager type
    if ($nsxDomain -eq "default") {
      # For default domain, use the root infra endpoints
      $endpoint = switch ($managerType) {
        "global_manager" { "/global-manager/api/v1/global-infra" }
        "standalone" { "/policy/api/v1/infra" }
        default { "/policy/api/v1/infra" }
      }
    }
    else {
      # For non-default domains, use domain-specific endpoints
      $endpoint = switch ($managerType) {
        "global_manager" { "/global-manager/api/v1/global-infra/domains/$nsxDomain" }
        "standalone" { "/policy/api/v1/infra/domains/$nsxDomain" }
        default { "/policy/api/v1/infra/domains/$nsxDomain" }
      }
    }

    $this.logger.LogInfo("Using endpoint: $endpoint for domain: $nsxDomain", "PolicyExport")

    $config = $this.RetrieveConfigurationFromEndpoint($nsxManager, $credential, $endpoint, "single", $options)

    return @{
      metadata      = @{
        source_manager      = $nsxManager
        manager_type        = $managerType
        domain              = $nsxDomain
        retrieval_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        config_type         = "single_scope_policy_export"
        api_endpoint        = $endpoint
      }
      configuration = $config
    }
  }

  # Retrieve configuration from specific endpoint
  hidden [object] RetrieveConfigurationFromEndpoint([string] $nsxManager, [PSCredential] $credential, [string] $endpoint, [string] $scope, [object] $options) {
    try {
      $this.logger.LogInfo("Retrieving configuration from endpoint: $endpoint (scope: $scope)", "PolicyExport")

      # Track this endpoint usage
      $this.usedEndpoints += $endpoint

      $response = $this.apiService.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET", $null, @{})

      if ($response.children -and $response.children.Count -gt 0) {
        $this.logger.LogInfo("Retrieved $($response.children.Count) configuration objects from endpoint", "PolicyExport")
        return $response
      }
      else {
        $this.logger.LogInfo("No children found in response, attempting separate API calls", "PolicyExport")
        return $this.RetrieveSeparateAPIObjects($nsxManager, $credential, $endpoint, $scope, $options)
      }
    }
    catch {
      $this.logger.LogWarning("Failed to retrieve from endpoint $endpoint : $($_.Exception.Message)", "PolicyExport")

      # For older NSX-T versions, create minimal structure
      if ($_.Exception.Message -match "404|Not Found") {
        $this.logger.LogInfo("Creating minimal configuration structure for older NSX-T version", "PolicyExport")
        return @{
          resource_type = "Infra"
          id            = "infra"
          display_name  = "infra"
          children      = @()
        }
      }
      else {
        throw
      }
    }
  }

  # Retrieve objects from separate API calls when single endpoint fails
  hidden [object] RetrieveSeparateAPIObjects([string] $nsxManager, [PSCredential] $credential, [string] $baseEndpoint, [string] $scope, [object] $options) {
    $this.logger.LogInfo("Retrieving objects from separate API calls", "PolicyExport")

    $allChildren = @()
    $resourceTypes = @("services", "tier-0s", "tier-1s", "segments", "domains")

    foreach ($resourceType in $resourceTypes) {
      try {
        $resourceEndpoint = "$baseEndpoint/$resourceType"
        $this.logger.LogInfo("Retrieving $resourceType from $resourceEndpoint", "PolicyExport")

        # Track this endpoint usage
        $this.usedEndpoints += $resourceEndpoint

        $response = $this.apiService.InvokeRestMethod($nsxManager, $credential, $resourceEndpoint, "GET", $null, @{})

        if ($response.results) {
          $this.logger.LogInfo("Retrieved $($response.results.Count) $resourceType objects", "PolicyExport")

          foreach ($obj in $response.results) {
            $wrappedObj = $this.WrapObjectForHierarchy($obj, $resourceType)
            if ($wrappedObj) {
              $allChildren += $wrappedObj
            }
          }
        }
      }
      catch {
        $this.logger.LogWarning("Failed to retrieve $resourceType : $($_.Exception.Message)", "PolicyExport")
      }
    }

    return @{
      resource_type = "Infra"
      id            = "infra"
      display_name  = "infra"
      children      = $allChildren
    }
  }

  # Wrap object for hierarchical structure
  hidden [object] WrapObjectForHierarchy([object] $obj, [string] $resourceType) {
    $wrapper = switch ($resourceType) {
      "services" { [PSCustomObject]@{ resource_type = "ChildService"; Service = $obj } }
      "tier-0s" { [PSCustomObject]@{ resource_type = "ChildTier0"; Tier0 = $obj } }
      "tier-1s" { [PSCustomObject]@{ resource_type = "ChildTier1"; Tier1 = $obj } }
      "segments" { [PSCustomObject]@{ resource_type = "ChildSegment"; Segment = $obj } }
      "domains" { [PSCustomObject]@{ resource_type = "ChildDomain"; Domain = $obj } }
      default { [PSCustomObject]@{ resource_type = "Child$resourceType"; $resourceType = $obj } }
    }
    return $wrapper
  }

  # Save exported configuration with standardised naming
  hidden [object] SaveExportedConfiguration([object] $policyConfig, [string] $nsxManager, [string] $nsxDomain, [string] $managerType) {
    $this.logger.LogInfo("Saving exported configuration with standardised naming", "PolicyExport")

    $managerDir = $this.GetManagerExportDirectory($nsxManager)
    $savedFiles = [PSCustomObject]@{}

    # Save main configuration export
    $mainExportFile = $this.GenerateStandardisedFileName($nsxManager, $nsxDomain, "policy-export", "json")
    $mainExportPath = Join-Path $managerDir $mainExportFile

    $policyConfig | ConvertTo-Json -Depth 20 -Compress | Out-File -FilePath $mainExportPath -Encoding UTF8
    $savedFiles.main_export = $mainExportPath

    # Save metadata separately
    $metadataFile = $this.GenerateStandardisedFileName($nsxManager, $nsxDomain, "export-metadata", "json")
    $metadataPath = Join-Path $managerDir $metadataFile

    $exportMetadata = [PSCustomObject]@{
      export_info = $policyConfig.metadata
      file_info   = @{
        main_export_file  = $mainExportFile
        export_directory  = $managerDir
        file_size_kb      = [math]::Round((Get-Item $mainExportPath).Length / 1KB, 2)
        created_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      }
      statistics  = @{
        total_objects = $this.GetObjectCount($policyConfig)
        manager_type  = $managerType
        domain        = $nsxDomain
      }
    }

    $exportMetadata | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath $metadataPath -Encoding UTF8
    $savedFiles.metadata = $metadataPath

    # Save configuration objects only (without metadata wrapper)
    $configOnlyFile = $this.GenerateStandardisedFileName($nsxManager, $nsxDomain, "config-only", "json")
    $configOnlyPath = Join-Path $managerDir $configOnlyFile

    $policyConfig.configuration | ConvertTo-Json -Depth 20 -Compress | Out-File -FilePath $configOnlyPath -Encoding UTF8
    $savedFiles.config_only = $configOnlyPath

    $this.logger.LogInfo("Saved exported configuration files:", "PolicyExport")
    $this.logger.LogInfo("  Main export: $mainExportPath", "PolicyExport")
    $this.logger.LogInfo("  Metadata: $metadataPath", "PolicyExport")
    $this.logger.LogInfo("  Config only: $configOnlyPath", "PolicyExport")

    return $savedFiles
  }

  # Get object count from configuration
  hidden [int] GetObjectCount([object] $policyConfig) {
    if ($policyConfig.configuration.children) {
      return $policyConfig.configuration.children.Count
    }
    return 0
  }

  # Update export history
  hidden [void] UpdateExportHistory([string] $nsxManager, [string] $nsxDomain, [object] $savedFiles) {
    $exportKey = "$nsxManager-$nsxDomain"

    if (-not $this.exportHistory.$exportKey) {
      $this.exportHistory.$exportKey = @()
    }

    $this.exportHistory[$exportKey] += @{
      timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      files     = $savedFiles
    }
  }

  # Detect NSX Manager type
  hidden [string] DetectManagerType([string] $nsxManager, [PSCredential] $credential) {
    try {
      $this.logger.LogInfo("Detecting NSX Manager type for: $nsxManager", "PolicyExport")

      # Test global manager endpoint
      try {
        $globalResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/global-manager/api/v1/global-infra", "GET", $null, @{})
        if ($globalResponse) {
          $this.logger.LogInfo("Global manager endpoint responded successfully", "PolicyExport")
          return "global_manager"
        }
      }
      catch {
        $this.logger.LogDebug("Global manager endpoint failed: $($_.Exception.Message)", "PolicyExport")
      }

      # Test local manager endpoint
      try {
        $localResponse = $this.apiService.InvokeRestMethod($nsxManager, $credential, "/policy/api/v1/global-infra", "GET", $null, @{})
        if ($localResponse) {
          $this.logger.LogInfo("Local manager endpoint responded successfully", "PolicyExport")
          return "local_manager"
        }
      }
      catch {
        $this.logger.LogDebug("Local manager endpoint failed: $($_.Exception.Message)", "PolicyExport")
      }

      # Default to standalone if both fail
      $this.logger.LogInfo("Defaulting to standalone manager type", "PolicyExport")
      return "standalone"
    }
    catch {
      $this.logger.LogWarning("Manager type detection failed: $($_.Exception.Message)", "PolicyExport")
      return "standalone"
    }
  }

  # List exported configurations
  [array] ListExportedConfigurations([string] $nsxManager = $null) {
    try {
      $this.logger.LogInfo("Listing exported configurations", "PolicyExport")

      if ($nsxManager) {
        $managerDir = $this.GetManagerExportDirectory($nsxManager)
        $configFiles = Get-ChildItem -Path $managerDir -Filter "*-policy-export.json" -ErrorAction SilentlyContinue
      }
      else {
        $configFiles = Get-ChildItem -Path $this.baseExportPath -Filter "*-policy-export.json" -Recurse -ErrorAction SilentlyContinue
      }

      $exports = @()
      foreach ($file in $configFiles) {
        $exports += $this.ParseExportFileInfo($file)
      }

      return $exports | Sort-Object timestamp -Descending
    }
    catch {
      $this.logger.LogError("Failed to list exported configurations: $($_.Exception.Message)", "PolicyExport")
      return @()
    }
  }

  # Parse export file information
  hidden [object] ParseExportFileInfo([System.IO.FileInfo] $file) {
    $fileInfo = [PSCustomObject]@{
      filename  = $file.Name
      full_path = $file.FullName
      size_kb   = [math]::Round($file.Length / 1KB, 2)
      created   = $file.CreationTime
      modified  = $file.LastWriteTime
      directory = $file.DirectoryName
    }

    # Parse standardised filename: (datestamp)-(nsxmgrname)-(nsxdomain)-(function).json
    if ($file.Name -match '^(\d{8}-\d{6})-(.+?)-(.+?)-(.+?)\.json$') {
      $fileInfo.timestamp = $matches[1]
      $fileInfo.nsx_manager = $matches[2] -replace '_', '.'
      $fileInfo.nsx_domain = $matches[3] -replace '_', '.'
      $fileInfo.function = $matches[4] -replace '_', '-'
    }

    return $fileInfo
  }

  # Get export statistics
  [object] GetExportStatistics() {
    $stats = [PSCustomObject]@{
      total_exports  = 0
      managers       = [PSCustomObject]@{}
      domains        = [PSCustomObject]@{}
      export_history = $this.exportHistory
    }

    $allExports = $this.ListExportedConfigurations()
    $stats.total_exports = $allExports.Count

    foreach ($export in $allExports) {
      if ($export.nsx_manager) {
        if (-not $stats.managers.($export.nsx_manager)) {
          $stats.managers.($export.nsx_manager) = 0
        }
        $stats.managers.($export.nsx_manager)++
      }

      if ($export.nsx_domain) {
        if (-not $stats.domains.($export.nsx_domain)) {
          $stats.domains.($export.nsx_domain) = 0
        }
        $stats.domains.($export.nsx_domain)++
      }
    }

    return $stats
  }

  # Create multi-domain summary configuration
  hidden [object] CreateMultiDomainSummary([object] $domainExports, [string] $nsxManager, [string] $managerType, [int] $totalDomains, [int] $successfulDomains, [array] $exportErrors, [timespan] $totalDuration) {
    $this.logger.LogDebug("Creating multi-domain summary configuration", "PolicyExport")

    $totalObjects = 0
    foreach ($domain in $domainExports.Keys) {
      $export = $domainExports[$domain]
      if ($export.success -and $export.object_count) {
        $totalObjects += $export.object_count
      }
    }

    $allDomainsConfig = [PSCustomObject]@{
      metadata                  = @{
        export_type            = "multi_domain_export"
        nsx_manager            = $nsxManager
        manager_type           = $managerType
        export_timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        total_domains          = $totalDomains
        successful_domains     = $successfulDomains
        failed_domains         = $exportErrors.Count
        total_duration_seconds = $totalDuration.TotalSeconds
        total_objects_exported = $totalObjects
        used_endpoints         = $this.usedEndpoints
      }
      domain_results            = [PSCustomObject]@{}
      successful_configurations = [PSCustomObject]@{}
      failed_domains            = [PSCustomObject]@{}
      export_summary            = @{
        success_rate           = if ($totalDomains -gt 0) { [math]::Round(($successfulDomains / $totalDomains) * 100, 1) } else { 0 }
        total_objects_exported = $totalObjects
        domain_count           = $totalDomains
        successful_count       = $successfulDomains
        failed_count           = $exportErrors.Count
      }
    }

    # Process each domain export result
    foreach ($domain in $domainExports.Keys) {
      $export = $domainExports[$domain]
      $domainInfo = [PSCustomObject]@{
        domain_id        = $domain
        success          = $export.success
        export_timestamp = $export.export_timestamp
        manager_type     = if ($export.manager_type) { $export.manager_type } else { $managerType }
      }

      if ($export.success) {
        # Store successful configuration data
        if ($export.configuration) {
          $allDomainsConfig.successful_configurations[$domain] = $export.configuration
          $domainInfo.object_count = $export.object_count
        }

        # Add saved file information
        if ($export.saved_files) {
          $domainInfo.saved_files = $export.saved_files
          $domainInfo.file_count = $export.saved_files.Keys.Count
        }
      }
      else {
        # Store failure information
        $failureInfo = [PSCustomObject]@{
          domain_id        = $domain
          error_message    = $export.error
          export_timestamp = $export.export_timestamp
        }

        if ($export.exception_type) {
          $failureInfo.exception_type = $export.exception_type
        }

        $allDomainsConfig.failed_domains[$domain] = $failureInfo
        $domainInfo.error = $export.error

        if ($export.exception_type) {
          $domainInfo.exception_type = $export.exception_type
        }
      }

      $allDomainsConfig.domain_results[$domain] = $domainInfo
    }

    # Add detailed error information if any failures occurred
    if ($exportErrors.Count -gt 0) {
      $allDomainsConfig.detailed_errors = $exportErrors
    }

    $this.logger.LogDebug("Multi-domain summary created with $($allDomainsConfig.successful_configurations.Keys.Count) successful and $($allDomainsConfig.failed_domains.Keys.Count) failed domains", "PolicyExport")
    return $allDomainsConfig
  }

  # Save multi-domain summary
  hidden [string] SaveMultiDomainSummary([object] $summaryConfig, [string] $nsxManager, [int] $domainCount) {
    try {
      $this.logger.LogDebug("Saving multi-domain summary files", "PolicyExport")

      $managerDir = $this.GetManagerExportDirectory($nsxManager)

      # Primary JSON summary
      $summaryFile = $this.GenerateStandardisedFileName($nsxManager, "all-domains", "multi-domain-export", "json")
      $summaryPath = Join-Path $managerDir $summaryFile
      $summaryConfig | ConvertTo-Json -Depth 20 | Out-File -FilePath $summaryPath -Encoding UTF8

      $this.logger.LogInfo("Multi-domain summary saved: $summaryPath", "PolicyExport")
      $this.logger.LogDebug("Summary contains data for $domainCount domains", "PolicyExport")

      return $summaryPath
    }
    catch {
      $this.logger.LogError("Failed to save multi-domain summary: $($_.Exception.Message)", "PolicyExport")
      return $null
    }
  }

  # Update export history with multi-domain session tracking
  hidden [void] UpdateMultiDomainExportHistory([string] $nsxManager, [array] $domains, [object] $domainExports, [string] $summaryFile) {
    try {
      $this.logger.LogDebug("Updating export history for multi-domain session", "PolicyExport")

      $exportKey = "$nsxManager-multi-domain"
      $sessionId = [guid]::NewGuid().ToString().Substring(0, 8)

      if (-not $this.exportHistory.$exportKey) {
        $this.exportHistory.$exportKey = @()
      }

      $successfulDomains = ($domainExports.Values | Where-Object { $_.success }).Count
      $failedDomains = ($domainExports.Values | Where-Object { -not $_.success }).Count
      $totalObjects = 0

      foreach ($domain in $domains) {
        if ($domainExports.$domain -and $domainExports.$domain.success -and $domainExports.$domain.object_count) {
          $totalObjects += $domainExports.$domain.object_count
        }
      }

      $sessionInfo = [PSCustomObject]@{
        session_type            = "multi_domain_export"
        session_id              = $sessionId
        timestamp               = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        nsx_manager             = $nsxManager
        total_domains           = $domains.Count
        successful_domains      = $successfulDomains
        failed_domains          = $failedDomains
        exported_domains        = $domains
        total_objects_exported  = $totalObjects
        success_rate_percentage = if ($domains.Count -gt 0) { [math]::Round(($successfulDomains / $domains.Count) * 100, 1) } else { 0 }
        summary_file            = $summaryFile
      }

      $this.exportHistory[$exportKey] += $sessionInfo

      # Update individual domain histories
      foreach ($domain in $domains) {
        $domainKey = "$nsxManager-$domain"
        if (-not $this.exportHistory.$domainKey) {
          $this.exportHistory.$domainKey = @()
        }

        $domainSessionInfo = [PSCustomObject]@{
          timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
          session_type      = "multi_domain_batch"
          parent_session_id = $sessionId
          success           = $domainExports.$domain -and $domainExports.$domain.success
        }

        if ($domainExports.$domain -and $domainExports.$domain.saved_files) {
          $domainSessionInfo.saved_files = $domainExports.$domain.saved_files
          $domainSessionInfo.file_count = $domainExports.$domain.saved_files.Keys.Count
        }

        if (-not $domainSessionInfo.success) {
          $domainSessionInfo.error_details = @{
            error_message   = if ($domainExports.$domain) { $domainExports.$domain.error } else { "Domain export not attempted" }
            error_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
          }
        }

        $this.exportHistory[$domainKey] += $domainSessionInfo
      }

      $this.logger.LogInfo("Export history updated for multi-domain session", "PolicyExport")
      $this.logger.LogDebug("Session ID: $sessionId | Domains: $($domains.Count) | Success Rate: $($sessionInfo.success_rate_percentage)", "PolicyExport")
    }
    catch {
      $this.logger.LogWarning("Failed to update multi-domain export history: $($_.Exception.Message)", "PolicyExport")
    }
  }
}
