# OpenAPISchemaService.ps1
# Universal service for retrieving and caching OpenAPI schemas from any OpenAPI-compliant service
# Following SOLID principles for schema management and validation

class OpenAPISchemaService {
  hidden [object] $logger
  hidden [object] $authService
  hidden [object] $apiService
  hidden [object] $fileNamingService
  hidden [object] $workflowService
  hidden [object] $schemaCache
  hidden [object] $config
  hidden [string] $nsxManager
  hidden [PSCredential] $credential
  hidden [DateTime] $cacheExpiry
  hidden [int] $cacheTTLMinutes
  hidden [object] $validatedEndpoints
  hidden [string] $endpointCacheFilePath
  hidden [string] $apiDataDirectory
  hidden [DateTime] $endpointCacheExpiry
  hidden [int] $endpointCacheTTLHours
  hidden [bool] $isConfigured

  # Constructor with dependency injection (basic)
  OpenAPISchemaService([object] $loggingService = $null, [object] $authService = $null, [object] $apiService = $null, [object] $fileNamingService = $null, [object] $workflowService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.fileNamingService = $fileNamingService
    $this.workflowService = $workflowService
    $this.InitializeDefaults()

    if ($this.logger) {
      $this.logger.LogInfo("OpenAPISchemaService initialized with core service dependencies", "OpenAPISchema")
    }
  }

  # Constructor with NSX Manager and credentials
  OpenAPISchemaService([object] $loggingService, [object] $authService, [object] $apiService, [string] $nsxManager, [PSCredential] $credential, [object] $fileNamingService = $null, [object] $workflowService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.fileNamingService = $fileNamingService
    $this.workflowService = $workflowService
    $this.nsxManager = $nsxManager
    $this.credential = $credential
    $this.InitializeDefaults()

    if ($this.logger) {
      $this.logger.LogInfo("OpenAPISchemaService initialized with NSX Manager: $nsxManager", "OpenAPISchema")
    }
  }

  # Constructor with cache configuration
  OpenAPISchemaService([object] $loggingService, [object] $authService, [object] $apiService, [object] $cacheConfig, [object] $fileNamingService = $null, [object] $workflowService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.fileNamingService = $fileNamingService
    $this.workflowService = $workflowService
    $this.InitializeDefaults()

    if ($cacheConfig) {
      $this.ApplyCacheConfiguration($cacheConfig)
    }

    if ($this.logger) {
      $this.logger.LogInfo("OpenAPISchemaService initialized with custom cache configuration", "OpenAPISchema")
    }
  }

  # Constructor with full configuration
  OpenAPISchemaService([object] $loggingService, [object] $authService, [object] $apiService, [string] $nsxManager, [PSCredential] $credential, [object] $cacheConfig, [object] $fileNamingService = $null, [object] $workflowService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.fileNamingService = $fileNamingService
    $this.workflowService = $workflowService
    $this.nsxManager = $nsxManager
    $this.credential = $credential
    $this.InitializeDefaults()

    if ($cacheConfig) {
      $this.ApplyCacheConfiguration($cacheConfig)
    }

    if ($this.logger) {
      $this.logger.LogInfo("OpenAPISchemaService initialized with full configuration for: $nsxManager", "OpenAPISchema")
    }
  }

  # Constructor with NSX Manager, credentials, and custom endpoints
  OpenAPISchemaService([object] $loggingService, [object] $authService, [object] $apiService, [string] $nsxManager, [PSCredential] $credential, [object] $customEndpoints, [object] $cacheConfig, [object] $fileNamingService = $null, [object] $workflowService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.fileNamingService = $fileNamingService
    $this.workflowService = $workflowService
    $this.nsxManager = $nsxManager
    $this.credential = $credential
    $this.InitializeDefaults()

    # Apply custom endpoints if provided
    if ($customEndpoints) {
      $this.UpdateEndpointConfiguration($customEndpoints)
    }

    if ($cacheConfig) {
      $this.ApplyCacheConfiguration($cacheConfig)
    }

    if ($this.logger) {
      $this.logger.LogInfo("OpenAPISchemaService initialized with NSX Manager: $nsxManager, custom endpoints, and cache config", "OpenAPISchema")
    }
  }

  # Initialize default configuration
  hidden [void] InitializeDefaults() {
    $this.schemaCache = [PSCustomObject]@{}
    $this.cacheTTLMinutes = 60  # 1 hour default cache TTL
    $this.cacheExpiry = (Get-Date).AddMinutes(-1)  # Force initial refresh

    # Initialize endpoint validation cache
    $this.validatedEndpoints = [PSCustomObject]@{}
    $this.endpointCacheTTLHours = 24  # 24 hour default endpoint cache TTL
    $this.endpointCacheExpiry = (Get-Date).AddHours(-1)  # Force initial refresh

    # Set default API data directory path
    $this.apiDataDirectory = if ($this.workflowService) {
      $this.workflowService.GetToolkitPath("APIData")
    }
    else {
      "$PSScriptRoot\..\..\data\api"
    }

    # Initialize with default cache file path (will be updated when NSX Manager is set)
    $this.endpointCacheFilePath = Join-Path $this.apiDataDirectory "validated-endpoints-cache.json"
    $this.isConfigured = $false

    # Load NSX-specific endpoint configuration from JSON file
    $nsxEndpointConfig = $this.LoadNSXEndpointConfiguration()

    # Set endpoints with NSX-specific configuration or fallback defaults
    $endpoints = [PSCustomObject]@{
      openapi_spec  = if ($nsxEndpointConfig.effective_endpoints.policy_api_json) { $nsxEndpointConfig.effective_endpoints.policy_api_json } else { "/api/v1/spec/openapi/nsx_policy_api.json" }
      swagger_spec  = if ($nsxEndpointConfig.effective_endpoints.policy_spec_json) { $nsxEndpointConfig.effective_endpoints.policy_spec_json } else { "/policy/api/v1/spec/openapi/nsx_policy_api.json" }
      api_discovery = if ($nsxEndpointConfig.effective_endpoints.management_api_json) { $nsxEndpointConfig.effective_endpoints.management_api_json } else { "/api/v1/spec/openapi/nsx_api.json" }
    }

    $this.config = @{
      endpoints           = $endpoints
      cache               = @{
        enabled     = $true
        ttl_minutes = $this.cacheTTLMinutes
        max_entries = 1000
      }
      retry               = @{
        max_attempts  = 3
        delay_seconds = 5
      }
      validation          = @{
        enabled     = $true
        strict_mode = $false
      }
      endpoint_validation = @{
        enabled              = $true
        ttl_hours            = $this.endpointCacheTTLHours
        test_timeout_seconds = 30
        max_test_endpoints   = 50
        cache_file_enabled   = $true
        validate_all_methods = $false  # Only validate GET methods by default
        exclude_patterns     = @(".*delete.*", ".*remove.*")  # Skip destructive endpoints
      }
    }

    # Load validated endpoints from cache file
    $this.LoadValidatedEndpointsCache()
  }

  # Apply cache configuration
  hidden [void] ApplyCacheConfiguration([object] $cacheConfig) {
    if ($cacheConfig.ttl_minutes) {
      $this.cacheTTLMinutes = $cacheConfig.ttl_minutes
      $this.config.cache.ttl_minutes = $cacheConfig.ttl_minutes
    }

    if ($cacheConfig.max_entries) {
      $this.config.cache.max_entries = $cacheConfig.max_entries
    }

    if ($null -ne $cacheConfig.enabled) {
      $this.config.cache.enabled = $cacheConfig.enabled
    }

    if ($cacheConfig.nsxManager) {
      $this.nsxManager = $cacheConfig.nsxManager
    }

    if ($cacheConfig.credential) {
      $this.credential = $cacheConfig.credential
    }

    # Apply endpoint configuration if provided
    if ($cacheConfig.endpoints) {
      $this.UpdateEndpointConfiguration($cacheConfig.endpoints)
    }

    # Apply endpoint validation configuration if provided
    if ($cacheConfig.endpoint_validation) {
      # Replace hash table iteration with PSCustomObject property access
      $validationProperties = ($cacheConfig.endpoint_validation | Get-Member -MemberType NoteProperty).Name
      foreach ($key in $validationProperties) {
        if ((Get-Member -InputObject $this.config.endpoint_validation -Name $key -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
          $this.config.endpoint_validation.$key = $cacheConfig.endpoint_validation.$key
        }
      }
    }
  }

  # Get schema for specific endpoint
  [object] GetSchemaForEndpoint([string] $endpoint) {
    if (-not $endpoint) {
      if ($this.logger) {
        $this.logger.LogWarning("No endpoint provided for schema retrieval", "OpenAPISchema")
      }
      return [PSCustomObject]@{}
    }

    $cacheKey = "endpoint_$endpoint"

    # Check cache first
    if ($this.IsCacheValid($cacheKey)) {
      if ($this.logger) {
        $this.logger.LogDebug("Returning cached schema for endpoint: $endpoint", "OpenAPISchema")
      }
      # Replace hash table indexing with PSCustomObject property access
      return $this.schemaCache.$cacheKey
    }

    # Retrieve from source
    $schema = $this.RetrieveSchemaFromSource($endpoint)

    # Cache the result
    if ($schema -and $schema.Count -gt 0) {
      $this.CacheSchema($cacheKey, $schema)
    }

    return $schema
  }

  # Get all available schemas
  [object] GetAllSchemas() {
    $cacheKey = "all_schemas"

    # Check cache first
    if ($this.IsCacheValid($cacheKey)) {
      if ($this.logger) {
        $this.logger.LogDebug("Returning cached all schemas", "OpenAPISchema")
      }
      # Replace hash table indexing with PSCustomObject property access
      return $this.schemaCache.$cacheKey
    }

    # Retrieve all schemas
    $allSchemas = $this.RetrieveAllSchemasFromSource()

    # Cache the result
    if ($allSchemas -and $allSchemas.Count -gt 0) {
      $this.CacheSchema($cacheKey, $allSchemas)
    }

    return $allSchemas
  }

  # Get schema by resource type
  [object] GetSchemaByResourceType([string] $resourceType) {
    if (-not $resourceType) {
      if ($this.logger) {
        $this.logger.LogWarning("No resource type provided for schema retrieval", "OpenAPISchema")
      }
      return [PSCustomObject]@{}
    }

    $cacheKey = "resource_$resourceType"

    # Check cache first
    if ($this.IsCacheValid($cacheKey)) {
      if ($this.logger) {
        $this.logger.LogDebug("Returning cached schema for resource type: $resourceType", "OpenAPISchema")
      }
      # Replace hash table indexing with PSCustomObject property access
      return $this.schemaCache.$cacheKey
    }

    # Get all schemas and filter by resource type
    $allSchemas = $this.GetAllSchemas()
    $resourceSchema = $this.FilterSchemaByResourceType($allSchemas, $resourceType)

    # Cache the result
    if ($resourceSchema -and $resourceSchema.Count -gt 0) {
      $this.CacheSchema($cacheKey, $resourceSchema)
    }

    return $resourceSchema
  }

  # Retrieve schema from source (NSX Manager or other OpenAPI service)
  hidden [object] RetrieveSchemaFromSource([string] $endpoint) {
    if (-not $this.nsxManager) {
      if ($this.logger) {
        $this.logger.LogWarning("No NSX Manager configured for schema retrieval", "OpenAPISchema")
      }
      return [PSCustomObject]@{}
    }

    # Check if core services are available
    if (-not $this.apiService -or -not $this.credential) {
      if ($this.logger) {
        $this.logger.LogWarning("Core API service or credentials not available for schema retrieval", "OpenAPISchema")
      }
      return [PSCustomObject]@{}
    }

    try {
      if ($this.logger) {
        $this.logger.LogDebug("Retrieving schema from endpoint: $endpoint", "OpenAPISchema")
      }

      # Make the API request
      $uri = "https://$($this.nsxManager)$endpoint"
      $response = $this.apiService.Get($uri, $this.credential)

      if (-not $response) {
        if ($this.logger) {
          $this.logger.LogWarning("No response received from schema endpoint: $endpoint", "OpenAPISchema")
        }
        return [PSCustomObject]@{}
      }

      # Handle large JSON conversion with chunking approach
      try {
        # First attempt: Direct conversion
        $convertedResponse = $this.ConvertPSObjectToHashtable($response)
        if ($this.logger) {
          $this.logger.LogDebug("Successfully converted schema response for endpoint: $endpoint", "OpenAPISchema")
        }
        return $convertedResponse
      }
      catch {
        if ($this.logger) {
          $this.logger.LogWarning("Large JSON conversion failed, attempting string-based fallback: $($_.Exception.Message)", "OpenAPISchema")
        }

        # Fallback: Convert to JSON string first, then parse in chunks
        try {
          $jsonString = $response | ConvertTo-Json -Depth 20 -Compress
          $parsedResponse = $jsonString | ConvertFrom-Json
          $fallbackResult = $this.ConvertPSObjectToHashtable($parsedResponse)

          if ($this.logger) {
            $this.logger.LogInfo("Successfully converted schema using fallback method for endpoint: $endpoint", "OpenAPISchema")
          }
          return $fallbackResult
        }
        catch {
          if ($this.logger) {
            $this.logger.LogError("Both direct and fallback JSON conversion failed for endpoint: $endpoint - Error: $($_.Exception.Message)", "OpenAPISchema")
          }

          # Final fallback: Return minimal schema structure that allows tools to continue
          return @{
            "openapi"     = "3.0.0"
            "info"        = @{
              "title"   = "NSX API"
              "version" = "1.0.0"
            }
            "paths"       = [PSCustomObject]@{}
            "definitions" = [PSCustomObject]@{}
            "error"       = "Schema conversion failed but minimal structure provided for tool continuation"
          }
        }
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to retrieve schema from endpoint: $endpoint - Error: $($_.Exception.Message)", "OpenAPISchema")
      }

      # Return minimal structure so tools can continue
      return @{
        "openapi"     = "3.0.0"
        "info"        = @{
          "title"   = "NSX API"
          "version" = "1.0.0"
        }
        "paths"       = [PSCustomObject]@{}
        "definitions" = [PSCustomObject]@{}
        "error"       = "Schema retrieval failed but minimal structure provided for tool continuation"
      }
    }
  }

  # Retrieve all schemas from source with local file caching
  hidden [object] RetrieveAllSchemasFromSource() {
    $allSchemas = [PSCustomObject]@{}

    # FIRST: Check local schema cache files (./data/api/schemas/<nsx-manager-hostname>/)
    $cachedSchemas = $this.LoadSchemasFromLocalCache()
    if ($cachedSchemas -and $cachedSchemas.Count -gt 0) {
      if ($this.logger) {
        $this.logger.LogInfo("Loaded schemas from local cache - bypassing NSX Manager requests", "OpenAPISchema")
      }
      return $cachedSchemas
    }

    # ONLY if local cache is missing/expired: Fetch from NSX Manager source
    if ($this.logger) {
      $this.logger.LogInfo("Local schema cache unavailable - fetching from NSX Manager source", "OpenAPISchema")
    }

    # Try OpenAPI spec endpoint first
    $openApiSchema = $this.RetrieveSchemaFromSource($this.config.endpoints.openapi_spec)
    if ($openApiSchema -and $openApiSchema.Count -gt 0) {
      $allSchemas["policy_openapi"] = $openApiSchema
    }

    # Try Swagger spec endpoint as fallback
    $swaggerSchema = $this.RetrieveSchemaFromSource($this.config.endpoints.swagger_spec)
    if ($swaggerSchema -and $swaggerSchema.Count -gt 0) {
      $allSchemas["policy_swagger"] = $swaggerSchema
    }

    # Try API discovery endpoint
    $discoverySchema = $this.RetrieveSchemaFromSource($this.config.endpoints.api_discovery)
    if ($discoverySchema -and $discoverySchema.Count -gt 0) {
      $allSchemas["management_api"] = $discoverySchema
    }

    # Save schemas to local cache for future use
    if ($allSchemas.Count -gt 0) {
      $this.SaveSchemasToLocalCache($allSchemas)
    }

    if ($this.logger) {
      $schemaCount = $allSchemas.Keys.Count
      $this.logger.LogInfo("Retrieved $schemaCount schema sources from NSX Manager and cached locally", "OpenAPISchema")
    }

    return $allSchemas
  }

  # Get schemas directory path for specific NSX Manager
  hidden [string] GetSchemasDirectoryPath() {
    try {
      # Get schemas base directory from toolkit paths
      $schemasBaseDir = if ($this.workflowService) {
        $this.workflowService.GetToolkitPath("Schemas")
      }
      else {
        "$PSScriptRoot\..\..\data\api\schemas"
      }

      # Create manager-specific subdirectory
      if ($this.nsxManager) {
        $hostname = if ($this.nsxManager.Contains('.')) {
          $this.nsxManager.Split('.')[0]
        }
        else {
          $this.nsxManager
        }
        $managerDir = Join-Path $schemasBaseDir $hostname
      }
      else {
        $managerDir = Join-Path $schemasBaseDir "default"
      }

      # Ensure directory exists
      if (-not (Test-Path $managerDir)) {
        New-Item -Path $managerDir -ItemType Directory -Force | Out-Null
        if ($this.logger) {
          $this.logger.LogInfo("Created schemas directory: $managerDir", "OpenAPISchema")
        }
      }

      return $managerDir
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to create schemas directory: $($_.Exception.Message)", "OpenAPISchema")
      }
      return $null
    }
  }

  # Load schemas from local cache files
  hidden [object] LoadSchemasFromLocalCache() {
    try {
      $schemasDir = $this.GetSchemasDirectoryPath()
      if (-not $schemasDir -or -not (Test-Path $schemasDir)) {
        return [PSCustomObject]@{}
      }

      $allSchemas = [PSCustomObject]@{}
      $cacheValidHours = 24  # 24-hour TTL for schema cache files

      # Check for cached schema files
      $schemaFiles = [PSCustomObject]@{
        "policy_openapi" = "policy_openapi_schema.json"
        "policy_swagger" = "policy_swagger_schema.json"
        "management_api" = "management_api_schema.json"
      }

      # Replace hash table iteration with PSCustomObject property access
      $schemaFileProperties = ($schemaFiles | Get-Member -MemberType NoteProperty).Name
      foreach ($schemaType in $schemaFileProperties) {
        $fileName = $schemaFiles.$schemaType
        $filePath = Join-Path $schemasDir $fileName

        if (Test-Path $filePath) {
          try {
            $fileInfo = Get-Item $filePath
            $fileAge = (Get-Date) - $fileInfo.LastWriteTime

            # Check if cache file is still valid (within TTL)
            if ($fileAge.TotalHours -lt $cacheValidHours) {
              $schemaContent = Get-Content $filePath -Raw | ConvertFrom-Json
              # Replace hash table assignment with PSCustomObject property addition
              $allSchemas | Add-Member -NotePropertyName $schemaType -NotePropertyValue ($this.ConvertPSObjectToHashtable($schemaContent)) -Force

              if ($this.logger) {
                $this.logger.LogDebug("Loaded cached $schemaType schema (age: $([math]::Round($fileAge.TotalHours, 1))h)", "OpenAPISchema")
              }
            }
            else {
              if ($this.logger) {
                $this.logger.LogDebug("Cached $schemaType schema expired (age: $([math]::Round($fileAge.TotalHours, 1))h)", "OpenAPISchema")
              }
            }
          }
          catch {
            if ($this.logger) {
              $this.logger.LogWarning("Failed to load cached $schemaType schema: $($_.Exception.Message)", "OpenAPISchema")
            }
          }
        }
      }

      # Replace hash table Count property with PSCustomObject property count
      $allSchemasCount = ($allSchemas | Get-Member -MemberType NoteProperty).Count
      if ($allSchemasCount -gt 0) {
        if ($this.logger) {
          $this.logger.LogInfo("Successfully loaded $allSchemasCount schemas from local cache", "OpenAPISchema")
        }
      }

      return $allSchemas
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load schemas from local cache: $($_.Exception.Message)", "OpenAPISchema")
      }
      return [PSCustomObject]@{}
    }
  }

  # Save schemas to local cache files
  hidden [void] SaveSchemasToLocalCache([object] $allSchemas) {
    try {
      $schemasDir = $this.GetSchemasDirectoryPath()
      if (-not $schemasDir) {
        return
      }

      # Schema file mapping
      $schemaFiles = [PSCustomObject]@{
        "policy_openapi" = "policy_openapi_schema.json"
        "policy_swagger" = "policy_swagger_schema.json"
        "management_api" = "management_api_schema.json"
      }

      # Replace hash table iteration with PSCustomObject property access
      $allSchemasProperties = ($allSchemas | Get-Member -MemberType NoteProperty).Name
      foreach ($schemaType in $allSchemasProperties) {
        if ((Get-Member -InputObject $schemaFiles -Name $schemaType -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
          $fileName = $schemaFiles.$schemaType
          $filePath = Join-Path $schemasDir $fileName

          try {
            # Convert schema to compressed JSON and save - replace hash table indexing with PSCustomObject property access
            $jsonContent = $allSchemas.$schemaType | ConvertTo-Json -Depth 50 -Compress
            $jsonContent | Out-File -FilePath $filePath -Encoding UTF8

            if ($this.logger) {
              $this.logger.LogDebug("Saved $schemaType schema to: $filePath", "OpenAPISchema")
            }
          }
          catch {
            if ($this.logger) {
              $this.logger.LogWarning("Failed to save $schemaType schema: $($_.Exception.Message)", "OpenAPISchema")
            }
          }
        }
      }

      if ($this.logger) {
        # Replace hash table Count property with PSCustomObject property count
        $allSchemasCount = ($allSchemas | Get-Member -MemberType NoteProperty).Count
        $this.logger.LogInfo("Successfully cached $allSchemasCount schemas to local files", "OpenAPISchema")
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to save schemas to local cache: $($_.Exception.Message)", "OpenAPISchema")
      }
    }
  }

  # Filter schema by resource type
  hidden [object] FilterSchemaByResourceType([object] $allSchemas, [string] $resourceType) {
    $filteredSchema = [PSCustomObject]@{}

    # Replace hash table iteration with PSCustomObject property access
    $allSchemasProperties = ($allSchemas | Get-Member -MemberType NoteProperty).Name
    foreach ($schemaSource in $allSchemasProperties) {
      $schema = $allSchemas.$schemaSource

      if ($schema.definitions -and $schema.definitions.$resourceType) {
        # Replace hash table assignment with PSCustomObject property addition
        $filteredSchema | Add-Member -NotePropertyName $schemaSource -NotePropertyValue @{
          definition = $schema.definitions.$resourceType
          paths      = $this.GetPathsForResourceType($schema, $resourceType)
        } -Force
      }

      if ($schema.components -and $schema.components.schemas -and $schema.components.schemas.$resourceType) {
        # Replace hash table assignment with PSCustomObject property addition
        $filteredSchema | Add-Member -NotePropertyName $schemaSource -NotePropertyValue @{
          definition = $schema.components.schemas.$resourceType
          paths      = $this.GetPathsForResourceType($schema, $resourceType)
        } -Force
      }
    }

    return $filteredSchema
  }

  # Get paths for specific resource type
  hidden [object] GetPathsForResourceType([object] $schema, [string] $resourceType) {
    $relevantPaths = [PSCustomObject]@{}

    if ($schema.paths) {
      # Replace hash table iteration with PSCustomObject property access
      $pathProperties = ($schema.paths | Get-Member -MemberType NoteProperty).Name
      foreach ($path in $pathProperties) {
        $pathInfo = $schema.paths.$path

        # Check if path is related to resource type
        if ($path -match $resourceType -or
          ($pathInfo.get -and $pathInfo.get.tags -contains $resourceType) -or
          ($pathInfo.post -and $pathInfo.post.tags -contains $resourceType) -or
          ($pathInfo.put -and $pathInfo.put.tags -contains $resourceType) -or
          ($pathInfo.delete -and $pathInfo.delete.tags -contains $resourceType)) {

          # Replace hash table assignment with PSCustomObject property addition
          $relevantPaths | Add-Member -NotePropertyName $path -NotePropertyValue $pathInfo -Force
        }
      }
    }

    return $relevantPaths
  }

  # Check if cache is valid
  hidden [bool] IsCacheValid([string] $cacheKey) {
    if (-not $this.config.cache.enabled) {
      return $false
    }

    # Replace hash table indexing with PSCustomObject property access
    if (-not (Get-Member -InputObject $this.schemaCache -Name $cacheKey -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
      return $false
    }

    # Replace hash table indexing with PSCustomObject property access
    $cacheEntry = $this.schemaCache.$cacheKey
    if (-not $cacheEntry.timestamp) {
      return $false
    }

    $expiryTime = $cacheEntry.timestamp.AddMinutes($this.cacheTTLMinutes)
    return (Get-Date) -lt $expiryTime
  }

  # Cache schema
  hidden [void] CacheSchema([string] $cacheKey, [object] $schema) {
    if (-not $this.config.cache.enabled) {
      return
    }

    # Check cache size limit - replace hash table Count property with PSCustomObject property count
    $currentCacheCount = ($this.schemaCache | Get-Member -MemberType NoteProperty).Count
    if ($currentCacheCount -ge $this.config.cache.max_entries) {
      $this.CleanupOldCacheEntries()
    }

    # Replace hash table assignment with PSCustomObject property addition
    $this.schemaCache | Add-Member -NotePropertyName $cacheKey -NotePropertyValue @{
      data      = $schema
      timestamp = Get-Date
    } -Force

    if ($this.logger) {
      $this.logger.LogDebug("Cached schema with key: $cacheKey", "OpenAPISchema")
    }
  }

  # Cleanup old cache entries
  hidden [void] CleanupOldCacheEntries() {
    $currentTime = Get-Date
    $keysToRemove = @()

    foreach ($key in $this.schemaCache.Keys) {
      $cacheEntry = $this.schemaCache[$key]
      if ($cacheEntry.timestamp) {
        $expiryTime = $cacheEntry.timestamp.AddMinutes($this.cacheTTLMinutes)
        if ($currentTime -gt $expiryTime) {
          $keysToRemove += $key
        }
      }
    }

    foreach ($key in $keysToRemove) {
      $this.schemaCache.Remove($key)
    }

    if ($this.logger -and $keysToRemove.Count -gt 0) {
      $this.logger.LogDebug("Cleaned up $($keysToRemove.Count) expired cache entries", "OpenAPISchema")
    }
  }

  # Convert PSObject to hashtable recursively
  hidden [object] ConvertPSObjectToHashtable([object] $obj) {
    if ($obj -is [PSObject]) {
      $hashtable = [PSCustomObject]@{}
      foreach ($property in $obj.PSObject.Properties) {
        if ($property.Value -is [PSObject] -or $property.Value -is [Array]) {
          $hashtable[$property.Name] = $this.ConvertPSObjectToHashtable($property.Value)
        }
        else {
          $hashtable[$property.Name] = $property.Value
        }
      }
      return $hashtable
    }
    elseif ($obj -is [Array]) {
      return @($obj | ForEach-Object { $this.ConvertPSObjectToHashtable($_) })
    }
    else {
      return $obj
    }
  }

  # Refresh schema cache
  [void] RefreshSchemaCache() {
    if ($this.logger) {
      $this.logger.LogInfo("Refreshing schema cache", "OpenAPISchema")
    }

    $this.schemaCache.Clear()
    $this.cacheExpiry = (Get-Date).AddMinutes(-1)

    # Pre-populate cache with all schemas
    $allSchemas = $this.GetAllSchemas()

    if ($this.logger) {
      $this.logger.LogInfo("Schema cache refreshed successfully", "OpenAPISchema")
    }
  }

  # Get cache statistics
  [object] GetCacheStatistics() {
    $stats = [PSCustomObject]@{
      CacheEnabled = $this.config.cache.enabled
      CacheSize    = $this.schemaCache.Count
      MaxEntries   = $this.config.cache.max_entries
      TTLMinutes   = $this.cacheTTLMinutes
      CacheKeys    = @($this.schemaCache.Keys)
    }

    if ($this.schemaCache.Count -gt 0) {
      $timestamps = @()
      foreach ($key in $this.schemaCache.Keys) {
        $entry = $this.schemaCache[$key]
        if ($entry.timestamp) {
          $timestamps += $entry.timestamp
        }
      }

      if ($timestamps.Count -gt 0) {
        $stats | Add-Member -NotePropertyName "OldestEntry" -NotePropertyValue (($timestamps | Sort-Object)[0])
        $stats | Add-Member -NotePropertyName "NewestEntry" -NotePropertyValue (($timestamps | Sort-Object)[-1])
      }
    }

    return $stats
  }

  # Validate schema availability
  [bool] ValidateSchemaAvailability([string] $endpoint) {
    try {
      $schema = $this.GetSchemaForEndpoint($endpoint)
      return $schema -and $schema.Count -gt 0
    }
    catch {
      if ($this.logger) {
        $this.logger.LogWarning("Schema validation failed for endpoint $endpoint`: $($_.Exception.Message)", "OpenAPISchema")
      }
      return $false
    }
  }

  # Set NSX Manager configuration after service creation
  [void] SetNSXManagerConfiguration([string] $nsxManager, [PSCredential] $credential) {
    if (-not $nsxManager) {
      if ($this.logger) {
        $this.logger.LogError("NSX Manager hostname cannot be empty", "OpenAPISchema")
      }
      throw "NSX Manager hostname is required"
    }

    $this.nsxManager = $nsxManager
    $this.credential = $credential
    $this.isConfigured = $true

    # Update API data directory and cache file path to be NSX Manager specific using standardized structure
    if ($this.fileNamingService) {
      # Use StandardFileNamingService for proper path management
      $this.endpointCacheFilePath = $this.fileNamingService.GenerateEndpointCacheFilePath($this.apiDataDirectory, $nsxManager)
    }
    else {
      # Fallback to manual path construction
      $safeManagerName = $nsxManager -replace '[^\w\-.]', '_'
      $managerApiDir = Join-Path $this.apiDataDirectory $safeManagerName
      if (-not (Test-Path $managerApiDir)) {
        New-Item -ItemType Directory -Path $managerApiDir -Force | Out-Null
      }
      $this.endpointCacheFilePath = Join-Path $managerApiDir "validated-endpoints-cache-$safeManagerName.json"
    }

    if ($this.logger) {
      $this.logger.LogInfo("NSX Manager configuration set: $nsxManager", "OpenAPISchema")
      $this.logger.LogInfo("API data will be stored in: $this.apiDataDirectory", "OpenAPISchema")
      $this.logger.LogInfo("Endpoint cache file: $this.endpointCacheFilePath", "OpenAPISchema")
    }

    # Load validated endpoints specific to this NSX Manager
    $this.LoadValidatedEndpointsCache()
  }

  # Get current configuration
  [object] GetCurrentConfiguration() {
    return [PSCustomObject]@{
      NSXManager       = $this.nsxManager
      CacheConfig      = $this.config.cache
      RetryConfig      = $this.config.retry
      ValidationConfig = $this.config.validation
      Endpoints        = $this.config.endpoints
    }
  }

  # Test connectivity to NSX Manager
  [object] TestConnectivity() {
    if (-not $this.isConfigured) {
      return [PSCustomObject]@{
        Success = $false
        Errors  = @("No NSX Manager configured for schema retrieval")
      }
    }

    $testUri = "https://$($this.nsxManager)/api/v1/node"

    try {
      # Check if core services are available
      if (-not $this.apiService -or -not $this.credential) {
        return [PSCustomObject]@{
          Success    = $false
          Errors     = @("Core API service or credentials not configured")
          TestUri    = $testUri
          StatusCode = 0
        }
      }

      # Use CoreAPIService to test connectivity
      $response = $this.apiService.InvokeRestMethod($this.nsxManager, $this.credential, "/api/v1/node", "GET", $null, @{})

      if ($this.logger) {
        $this.logger.LogInfo("NSX Manager connectivity test successful", "OpenAPISchema")
      }

      return [PSCustomObject]@{
        Success    = $true
        NodeInfo   = $response
        Errors     = @()
        TestUri    = $testUri
        StatusCode = 200
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("NSX Manager connectivity test failed: $($_.Exception.Message)", "OpenAPISchema")
      }

      $statusCode = 0
      if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
      }

      return [PSCustomObject]@{
        Success    = $false
        Errors     = @($_.Exception.Message)
        TestUri    = $testUri
        StatusCode = $statusCode
      }
    }
  }

  # Discover and validate active endpoints
  [object] DiscoverAndValidateEndpoints([int] $maxEndpoints = 50) {
    if (-not $this.isConfigured) {
      if ($this.logger) {
        $this.logger.LogWarning("No NSX Manager configured for endpoint discovery", "OpenAPISchema")
      }
      return @{
        Success          = $false
        DiscoveredCount  = 0
        ValidatedCount   = 0
        ActiveEndpoints  = @()
        ValidationErrors = @("No NSX Manager configured")
        CacheStatus      = "Not Updated"
      }
    }

    $discoveryResult = [PSCustomObject]@{
      Success          = $false
      DiscoveredCount  = 0
      ValidatedCount   = 0
      ActiveEndpoints  = @()
      ValidationErrors = @()
      CacheStatus      = "Not Updated"
      DiscoveryTime    = Get-Date
    }

    try {
      if ($this.logger) {
        $this.logger.LogInfo("Starting endpoint discovery for NSX Manager: $($this.nsxManager)", "OpenAPISchema")
      }

      # Get basic NSX-T Policy API endpoints for discovery
      $baseEndpoints = @(
        "/policy/api/v1/infra/domains",
        "/policy/api/v1/infra/domains/default/groups",
        "/policy/api/v1/infra/domains/default/services",
        "/policy/api/v1/infra/domains/default/security-policies",
        "/policy/api/v1/infra/domains/default/context-profiles",
        "/policy/api/v1/infra/tier-0s",
        "/policy/api/v1/infra/tier-1s",
        "/policy/api/v1/infra/segments",
        "/api/v1/logical-switches",
        "/api/v1/logical-routers",
        "/api/v1/ns-groups",
        "/api/v1/firewall/sections"
      )

      # Check if core services are available
      if (-not $this.apiService -or -not $this.credential) {
        $discoveryResult.ValidationErrors += "Core API service or credentials not configured"
        return $discoveryResult
      }

      # Test each endpoint
      $localValidatedEndpoints = @()

      foreach ($endpoint in $baseEndpoints) {
        if ($localValidatedEndpoints.Count -ge $maxEndpoints) {
          break
        }

        $endpointResult = $this.TestSingleEndpoint($endpoint)

        if ($endpointResult.Success) {
          $localValidatedEndpoints += @{
            endpoint     = $endpoint
            itemCount    = $endpointResult.ItemCount
            responseTime = $endpointResult.ResponseTime
            lastTested   = Get-Date
            hasData      = $endpointResult.ItemCount -gt 0
          }
          $discoveryResult.ValidatedCount++
        }
        else {
          $discoveryResult.ValidationErrors += "Endpoint $endpoint failed: $($endpointResult.Error)"
        }

        $discoveryResult.DiscoveredCount++
      }

      $discoveryResult.ActiveEndpoints = $localValidatedEndpoints
      $discoveryResult.Success = $discoveryResult.ValidatedCount -gt 0

      # Cache the validated endpoints
      if ($discoveryResult.ValidatedCount -gt 0) {
        $this.CacheValidatedEndpoints($localValidatedEndpoints)
        $discoveryResult.CacheStatus = "Updated"
      }

      if ($this.logger) {
        $this.logger.LogInfo("Endpoint discovery completed: $($discoveryResult.ValidatedCount)/$($discoveryResult.DiscoveredCount) endpoints validated", "OpenAPISchema")
      }

    }
    catch {
      $discoveryResult.ValidationErrors += "Discovery failed: $($_.Exception.Message)"
      if ($this.logger) {
        $this.logger.LogError("Endpoint discovery failed: $($_.Exception.Message)", "OpenAPISchema")
      }
    }

    return $discoveryResult
  }

  # Test a single endpoint
  hidden [object] TestSingleEndpoint([string] $endpoint) {
    $result = [PSCustomObject]@{
      Success      = $false
      ItemCount    = 0
      ResponseTime = 0
      Error        = $null
    }

    # Check if core services are available
    if (-not $this.apiService -or -not $this.credential) {
      $result.Error = "Core API service or credentials not configured"
      return $result
    }

    try {
      $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

      # Use CoreAPIService to test the endpoint
      $response = $this.apiService.InvokeRestMethod($this.nsxManager, $this.credential, $endpoint, "GET", $null, @{})
      $stopwatch.Stop()

      $result.ResponseTime = $stopwatch.ElapsedMilliseconds
      $result.Success = $true

      # Count items in response
      if ($response.results) {
        $result.ItemCount = $response.results.Count
      }
      elseif ($response -is [Array]) {
        $result.ItemCount = $response.Count
      }
      elseif ($response.id -or $response.node_version) {
        $result.ItemCount = 1
      }
    }
    catch {
      $result.Error = $_.Exception.Message
    }

    return $result
  }

  # Get cached validated endpoints
  [array] GetValidatedEndpoints() {
    # Check if cache needs refresh
    if ((Get-Date) -gt $this.endpointCacheExpiry -or $this.validatedEndpoints.Count -eq 0) {
      if ($this.isConfigured) {
        $discoveryResult = $this.DiscoverAndValidateEndpoints()
        if (-not $discoveryResult.Success) {
          if ($this.logger) {
            $this.logger.LogWarning("Endpoint discovery failed, returning empty list", "OpenAPISchema")
          }
          return @()
        }
      }
      else {
        if ($this.logger) {
          $this.logger.LogWarning("No NSX Manager configured, cannot discover endpoints", "OpenAPISchema")
        }
        return @()
      }
    }

    return $this.validatedEndpoints.Values
  }

  # Get optimized export endpoints (active endpoints with data)
  [array] GetOptimizedExportEndpoints([array] $resourceTypes = @()) {
    $localValidatedEndpoints = $this.GetValidatedEndpoints()

    # Filter for endpoints with data
    $activeEndpoints = $localValidatedEndpoints | Where-Object { $_.hasData -eq $true }

    # Apply resource type filtering if specified
    if ($resourceTypes.Count -gt 0) {
      $activeEndpoints = $activeEndpoints | Where-Object {
        $endpoint = $_.endpoint
        $resourceTypes | ForEach-Object {
          $resourceType = $_
          if ($endpoint -match $resourceType) { return $true }
        }
        return $false
      }
    }

    # Sort by item count (endpoints with more data first)
    return ($activeEndpoints | Sort-Object itemCount -Descending)
  }

  # ===============================================================================
  # ENDPOINT CONFIGURATION MANAGEMENT METHODS
  # ===============================================================================

  # Update endpoint configuration dynamically
  [void] UpdateEndpointConfiguration([object] $endpointConfig) {
    if (-not $endpointConfig) {
      if ($this.logger) {
        $this.logger.LogWarning("No endpoint configuration provided for update", "OpenAPISchema")
      }
      return
    }

    $updatedEndpoints = @()

    # Update individual endpoint configurations
    foreach ($endpointName in $endpointConfig.Keys) {
      $newEndpoint = $endpointConfig[$endpointName]

      if ($this.config.endpoints.$endpointName) {
        $oldEndpoint = $this.config.endpoints.$endpointName
        $this.config.endpoints.$endpointName = $newEndpoint
        $updatedEndpoints += "$endpointName`: $oldEndpoint -> $newEndpoint"

        if ($this.logger) {
          $this.logger.LogInfo("Updated endpoint $endpointName from '$oldEndpoint' to '$newEndpoint'", "OpenAPISchema")
        }
      }
      else {
        # Add new endpoint
        $this.config.endpoints[$endpointName] = $newEndpoint
        $updatedEndpoints += "$endpointName`: (new) -> $newEndpoint"

        if ($this.logger) {
          $this.logger.LogInfo("Added new endpoint $endpointName`: '$newEndpoint'", "OpenAPISchema")
        }
      }
    }

    # Clear schema cache when endpoints change
    if ($updatedEndpoints.Count -gt 0) {
      $this.schemaCache.Clear()
      $this.cacheExpiry = (Get-Date).AddMinutes(-1)

      # Clear endpoint validation cache as endpoints may have changed
      $this.validatedEndpoints = [PSCustomObject]@{}
      $this.endpointCacheExpiry = (Get-Date).AddHours(-1)

      if ($this.logger) {
        $this.logger.LogInfo("Cleared schema and endpoint validation caches due to endpoint configuration changes", "OpenAPISchema")
      }
    }
  }

  # Set individual endpoint
  [void] SetEndpoint([string] $endpointName, [string] $endpointPath) {
    if (-not $endpointName -or -not $endpointPath) {
      if ($this.logger) {
        $this.logger.LogWarning("Endpoint name and path are required", "OpenAPISchema")
      }
      return
    }

    $endpointConfig = [PSCustomObject]@{ $endpointName = $endpointPath }
    $this.UpdateEndpointConfiguration($endpointConfig)
  }

  # Get current endpoint configuration
  [object] GetEndpointConfiguration() {
    return $this.config.endpoints.Clone()
  }

  # Set OpenAPI specification endpoint
  [void] SetOpenAPISpecEndpoint([string] $endpoint) {
    if (-not $endpoint) {
      if ($this.logger) {
        $this.logger.LogWarning("OpenAPI spec endpoint path is required", "OpenAPISchema")
      }
      return
    }

    $this.SetEndpoint("openapi_spec", $endpoint)
  }

  # Set Swagger specification endpoint
  [void] SetSwaggerSpecEndpoint([string] $endpoint) {
    if (-not $endpoint) {
      if ($this.logger) {
        $this.logger.LogWarning("Swagger spec endpoint path is required", "OpenAPISchema")
      }
      return
    }

    $this.SetEndpoint("swagger_spec", $endpoint)
  }

  # Set API discovery endpoint
  [void] SetAPIDiscoveryEndpoint([string] $endpoint) {
    if (-not $endpoint) {
      if ($this.logger) {
        $this.logger.LogWarning("API discovery endpoint path is required", "OpenAPISchema")
      }
      return
    }

    $this.SetEndpoint("api_discovery", $endpoint)
  }

  # Add custom endpoint (for extending beyond standard OpenAPI/Swagger)
  [void] AddCustomEndpoint([string] $endpointName, [string] $endpointPath) {
    if (-not $endpointName -or -not $endpointPath) {
      if ($this.logger) {
        $this.logger.LogWarning("Custom endpoint name and path are required", "OpenAPISchema")
      }
      return
    }

    $this.SetEndpoint($endpointName, $endpointPath)
  }

  # Remove endpoint
  [void] RemoveEndpoint([string] $endpointName) {
    if (-not $endpointName) {
      if ($this.logger) {
        $this.logger.LogWarning("Endpoint name is required for removal", "OpenAPISchema")
      }
      return
    }

    if ($this.config.endpoints.$endpointName) {
      $removedEndpoint = $this.config.endpoints.$endpointName
      $this.config.endpoints.Remove($endpointName)

      # Clear caches when endpoints are removed
      $this.schemaCache.Clear()
      $this.cacheExpiry = (Get-Date).AddMinutes(-1)
      $this.validatedEndpoints.Clear()
      $this.endpointCacheExpiry = (Get-Date).AddHours(-1)

      if ($this.logger) {
        $this.logger.LogInfo("Removed endpoint $endpointName`: '$removedEndpoint'", "OpenAPISchema")
      }
    }
    else {
      if ($this.logger) {
        $this.logger.LogWarning("Endpoint '$endpointName' not found for removal", "OpenAPISchema")
      }
    }
  }

  # Reset endpoints to defaults
  [void] ResetEndpointsToDefaults() {
    $defaultEndpoints = [PSCustomObject]@{
      openapi_spec  = "/api/v1/spec/openapi/"
      swagger_spec  = "/api/v1/spec/swagger.json"
      api_discovery = "/api/v1/"
    }

    $this.config.endpoints = $defaultEndpoints

    # Clear caches when endpoints are reset
    $this.schemaCache.Clear()
    $this.cacheExpiry = (Get-Date).AddMinutes(-1)
    $this.validatedEndpoints.Clear()
    $this.endpointCacheExpiry = (Get-Date).AddHours(-1)

    if ($this.logger) {
      $this.logger.LogInfo("Reset endpoints to default configuration", "OpenAPISchema")
    }
  }

  # Validate endpoint configuration (check if endpoints are reachable)
  [object] ValidateEndpointConfiguration() {
    $validationResult = [PSCustomObject]@{
      totalEndpoints   = $this.config.endpoints.Count
      validEndpoints   = 0
      invalidEndpoints = 0
      endpointResults  = [PSCustomObject]@{}
      errors           = @()
    }

    if (-not $this.nsxManager) {
      $validationResult.errors += "No NSX Manager configured"
      return $validationResult
    }

    foreach ($endpointName in $this.config.endpoints.Keys) {
      $endpointPath = $this.config.endpoints[$endpointName]

      try {
        $testResult = $this.TestEndpoint($endpointPath)
        $validationResult.endpointResults[$endpointName] = $testResult

        if ($testResult.isValid) {
          $validationResult.validEndpoints++
        }
        else {
          $validationResult.invalidEndpoints++
          if ($testResult.error) {
            $validationResult.errors += "$endpointName ($endpointPath): $($testResult.error)"
          }
        }
      }
      catch {
        $validationResult.invalidEndpoints++
        $validationResult.errors += "$endpointName ($endpointPath): $($_.Exception.Message)"
      }
    }

    if ($this.logger) {
      $this.logger.LogInfo("Endpoint configuration validation completed: $($validationResult.validEndpoints)/$($validationResult.totalEndpoints) endpoints valid", "OpenAPISchema")
    }

    return $validationResult
  }

  # Get endpoint configuration as exportable format (for saving/sharing configurations)
  [object] ExportEndpointConfiguration() {
    return @{
      endpoints = $this.config.endpoints.Clone()
      metadata  = @{
        exportedBy = "OpenAPISchemaService"
        exportedAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        nsxManager = $this.nsxManager
        version    = "1.0"
      }
    }
  }

  # Import endpoint configuration from external source
  [void] ImportEndpointConfiguration([object] $endpointConfigData) {
    if (-not $endpointConfigData -or -not $endpointConfigData.endpoints) {
      if ($this.logger) {
        $this.logger.LogWarning("No valid endpoint configuration data provided for import", "OpenAPISchema")
      }
      return
    }

    $this.UpdateEndpointConfiguration($endpointConfigData.endpoints)

    if ($this.logger) {
      $importSource = if ($endpointConfigData.metadata -and $endpointConfigData.metadata.exportedAt) {
        "exported at $($endpointConfigData.metadata.exportedAt)"
      }
      else {
        "external source"
      }

      $this.logger.LogInfo("Imported endpoint configuration from $importSource", "OpenAPISchema")
    }
  }

  # ===============================================================================
  # ENDPOINT VALIDATION AND CACHING METHODS
  # ===============================================================================

  # Load NSX-specific endpoint configuration from JSON file
  hidden [object] LoadNSXEndpointConfiguration() {
    try {
      $configPath = Join-Path $PSScriptRoot "..\..\config\nsx-openapi-endpoints.json"

      if (-not (Test-Path $configPath)) {
        if ($this.logger) {
          $this.logger.LogWarning("NSX OpenAPI endpoint configuration file not found: $configPath. Using fallback endpoints.", "OpenAPISchema")
        }
        return $this.GetFallbackEndpointConfiguration()
      }

      $configJson = Get-Content $configPath -Raw | ConvertFrom-Json

      # Convert PSObject to hashtable for easier manipulation
      $configHash = [PSCustomObject]@{}
      foreach ($property in $configJson.PSObject.Properties) {
        if ($property.Value -is [PSCustomObject]) {
          $nestedHash = [PSCustomObject]@{}
          foreach ($nestedProperty in $property.Value.PSObject.Properties) {
            if ($nestedProperty.Value -is [PSCustomObject]) {
              $deepHash = [PSCustomObject]@{}
              foreach ($deepProperty in $nestedProperty.Value.PSObject.Properties) {
                $deepHash[$deepProperty.Name] = $deepProperty.Value
              }
              $nestedHash[$nestedProperty.Name] = $deepHash
            }
            else {
              $nestedHash[$nestedProperty.Name] = $nestedProperty.Value
            }
          }
          $configHash[$property.Name] = $nestedHash
        }
        else {
          $configHash[$property.Name] = $property.Value
        }
      }

      # Auto-detect NSX manager type and set appropriate endpoints
      $managerType = $this.DetectNSXManagerType()
      $endpointGroup = $this.SelectEndpointGroup($configHash, $managerType)

      if ($this.logger) {
        $this.logger.LogInfo("Loaded NSX OpenAPI endpoint configuration. Manager type: $managerType", "OpenAPISchema")
      }

      return @{
        config              = $configHash
        manager_type        = $managerType
        endpoint_group      = $endpointGroup
        effective_endpoints = $endpointGroup
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load NSX endpoint configuration: $($_.Exception.Message)", "OpenAPISchema")
      }
      return $this.GetFallbackEndpointConfiguration()
    }
  }

  # Detect NSX manager type based on available endpoints
  hidden [string] DetectNSXManagerType() {
    if (-not $this.nsxManager -or -not $this.credential) {
      return "nsx_standard"  # Default assumption
    }

    # Try to detect Global Manager first
    try {
      $globalInfraUri = "https://$($this.nsxManager)/global-manager/api/v1/global-infra"
      $response = $this.apiService.InvokeRestMethod($this.nsxManager, $this.credential, "/global-manager/api/v1/global-infra", "GET")
      if ($response) {
        return "nsx_global_manager"
      }
    }
    catch {
      # Not a global manager, continue checking
    }

    # Try to detect VMC
    try {
      $vmcResponse = $this.apiService.InvokeRestMethod($this.nsxManager, $this.credential, "/api/v1/vmc", "GET")
      if ($vmcResponse) {
        return "nsx_vmc"
      }
    }
    catch {
      # Not VMC, continue checking
    }

    # Default to standard NSX manager
    return "nsx_standard"
  }

  # Select appropriate endpoint group based on manager type
  hidden [object] SelectEndpointGroup([object] $config, [string] $managerType) {
    $result = [PSCustomObject]@{}

    switch ($managerType) {
      "nsx_global_manager" {
        $result = if ($config.nsx_global_manager_endpoints) { $config.nsx_global_manager_endpoints } else { [PSCustomObject]@{} }
      }
      "nsx_vmc" {
        $result = if ($config.nsx_vmc_endpoints) { $config.nsx_vmc_endpoints } else { [PSCustomObject]@{} }
      }
      default {
        $result = if ($config.nsx_manager_endpoints) { $config.nsx_manager_endpoints } else { [PSCustomObject]@{} }
      }
    }

    return $result
  }

  # Provide fallback configuration if JSON file is not available
  hidden [object] GetFallbackEndpointConfiguration() {
    if ($this.logger) {
      $this.logger.LogInfo("Using fallback NSX endpoint configuration", "OpenAPISchema")
    }

    return @{
      config              = [PSCustomObject]@{}
      manager_type        = "nsx_standard"
      endpoint_group      = @{
        policy_api_json     = "/api/v1/spec/openapi/nsx_policy_api.json"
        policy_spec_json    = "/policy/api/v1/spec/openapi/nsx_policy_api.json"
        management_api_json = "/api/v1/spec/openapi/nsx_api.json"
      }
      effective_endpoints = @{
        policy_api_json     = "/api/v1/spec/openapi/nsx_policy_api.json"
        policy_spec_json    = "/policy/api/v1/spec/openapi/nsx_policy_api.json"
        management_api_json = "/api/v1/spec/openapi/nsx_api.json"
      }
    }
  }

  # Load validated endpoints from cache file
  hidden [void] LoadValidatedEndpointsCache() {
    try {
      if (-not (Test-Path $this.endpointCacheFilePath)) {
        if ($this.logger) {
          $this.logger.LogDebug("No endpoint cache file found: $($this.endpointCacheFilePath)", "OpenAPISchema")
        }
        return
      }

      $cacheContent = Get-Content -Path $this.endpointCacheFilePath -Raw | ConvertFrom-Json

      # Check if cache is expired
      $expiresAt = [DateTime]::Parse($cacheContent.expiresAt)
      if ((Get-Date) -gt $expiresAt) {
        if ($this.logger) {
          $this.logger.LogDebug("Endpoint cache expired, will refresh on next use", "OpenAPISchema")
        }
        return
      }

      # Load valid cache
      $this.validatedEndpoints = [PSCustomObject]@{}
      foreach ($endpoint in $cacheContent.endpoints) {
        $this.validatedEndpoints[$endpoint.endpoint] = $endpoint
      }
      $this.endpointCacheExpiry = $expiresAt

      if ($this.logger) {
        $this.logger.LogInfo("Loaded $($cacheContent.endpointCount) validated endpoints from cache", "OpenAPISchema")
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogWarning("Failed to load endpoint cache: $($_.Exception.Message)", "OpenAPISchema")
      }
    }
  }

  # Save validated endpoints to cache file
  hidden [void] SaveValidatedEndpointsCache() {
    if (-not $this.config.endpoint_validation.cache_file_enabled) {
      return
    }

    try {
      # Ensure API data directory structure exists
      if ($this.fileNamingService -and $this.nsxManager) {
        # Use StandardFileNamingService to ensure proper directory structure
        $apiManagerDir = $this.fileNamingService.GetAPIDataDirectory($this.apiDataDirectory, $this.nsxManager)
        # Update cache file path to use proper structure
        $this.endpointCacheFilePath = $this.fileNamingService.GenerateEndpointCacheFilePath($this.apiDataDirectory, $this.nsxManager)
      }
      else {
        # Fallback: Ensure data directory exists
        $dataDir = Split-Path $this.endpointCacheFilePath -Parent
        if (-not (Test-Path $dataDir)) {
          New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
        }
      }

      $cacheData = [PSCustomObject]@{
        timestamp  = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        ttl_hours  = $this.endpointCacheTTLHours
        nsxManager = $this.nsxManager
        endpoints  = $this.validatedEndpoints
        summary    = @{
          total_endpoints = $this.validatedEndpoints.Count
          valid_endpoints = ($this.validatedEndpoints.Values | Where-Object { $_.isValid -eq $true }).Count
          last_validation = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }
        metadata   = @{
          api_data_directory = $this.apiDataDirectory
          cache_file_path    = $this.endpointCacheFilePath
          service_version    = "OpenAPISchemaService v2.0"
        }
      }

      $json = $cacheData | ConvertTo-Json -Depth 10 -Compress
      $json | Set-Content $this.endpointCacheFilePath -Encoding UTF8

      if ($this.logger) {
        $this.logger.LogInfo("Saved $($this.validatedEndpoints.Count) validated endpoints to standardized cache file: $($this.endpointCacheFilePath)", "OpenAPISchema")
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to save validated endpoints cache: $($_.Exception.Message)", "OpenAPISchema")
      }
    }
  }

  # Test individual endpoint for validity and data availability
  [object] TestEndpoint([string] $endpoint, [string] $method = "GET") {
    $testResult = [PSCustomObject]@{
      endpoint     = $endpoint
      method       = $method
      isValid      = $false
      hasData      = $false
      responseTime = $null
      statusCode   = $null
      error        = $null
      timestamp    = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
      dataCount    = 0
      responseSize = 0
    }

    if (-not $this.nsxManager) {
      $testResult.error = "No NSX Manager configured"
      return $testResult
    }

    # Skip destructive endpoints
    foreach ($pattern in $this.config.endpoint_validation.exclude_patterns) {
      if ($endpoint -match $pattern) {
        $testResult.error = "Endpoint excluded by pattern: $pattern"
        return $testResult
      }
    }

    try {
      # Check if core services are available
      if (-not $this.apiService -or -not $this.credential) {
        $testResult.error = "Core API service or credentials not configured"
        return $testResult
      }

      $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

      if ($this.logger) {
        $this.logger.LogDebug("Testing endpoint: $method $endpoint", "OpenAPISchema")
      }

      # Use CoreAPIService to test the endpoint
      $response = $this.apiService.InvokeRestMethod($this.nsxManager, $this.credential, $endpoint, $method, $null, @{})

      $stopwatch.Stop()
      $testResult.responseTime = $stopwatch.ElapsedMilliseconds
      $testResult.isValid = $true

      # Check if endpoint returns data
      if ($response) {
        $testResult.hasData = $true

        # Calculate response size and data count
        $responseJson = $response | ConvertTo-Json -Depth 10 -Compress
        $testResult.responseSize = [System.Text.Encoding]::UTF8.GetByteCount($responseJson)

        if ($response -is [Array]) {
          $testResult.dataCount = $response.Count
        }
        elseif ($response.results -and $response.results -is [Array]) {
          $testResult.dataCount = $response.results.Count
        }
        elseif ($response.PSObject.Properties.Name -contains "cursor") {
          # NSX paginated response
          $testResult.dataCount = if ($response.results) { $response.results.Count } else { 1 }
        }
        else {
          $testResult.dataCount = 1
        }
      }

      $testResult.statusCode = 200  # Successful response

      if ($this.logger) {
        $this.logger.LogDebug("Endpoint test successful: $endpoint ($($testResult.responseTime)ms, $($testResult.dataCount) items)", "OpenAPISchema")
      }
    }
    catch {
      $testResult.error = $_.Exception.Message

      # Try to extract status code from web exception
      if ($_.Exception.Response) {
        $testResult.statusCode = [int]$_.Exception.Response.StatusCode
      }

      if ($this.logger) {
        $this.logger.LogDebug("Endpoint test failed: $endpoint - $($_.Exception.Message)", "OpenAPISchema")
      }
    }

    return $testResult
  }

  # Validate all endpoints from OpenAPI schema
  [object] ValidateAllEndpoints([bool] $forceRefresh = $false) {
    if (-not $forceRefresh -and $this.IsEndpointCacheValid()) {
      if ($this.logger) {
        $this.logger.LogInfo("Using cached endpoint validation results", "OpenAPISchema")
      }

      return @{
        fromCache      = $true
        totalEndpoints = $this.validatedEndpoints.Count
        validEndpoints = ($this.validatedEndpoints.Values | Where-Object { $_.isValid -eq $true }).Count
        timestamp      = $this.endpointCacheExpiry.AddHours(-$this.endpointCacheTTLHours).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
      }
    }

    if ($this.logger) {
      $this.logger.LogInfo("Starting endpoint validation", "OpenAPISchema")
    }

    $validationResults = [PSCustomObject]@{
      fromCache        = $false
      totalEndpoints   = 0
      validEndpoints   = 0
      invalidEndpoints = 0
      testedEndpoints  = 0
      skippedEndpoints = 0
      errors           = @()
      timestamp        = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
      performance      = @{
        totalTime           = $null
        averageResponseTime = 0
        slowestEndpoint     = $null
        fastestEndpoint     = $null
      }
    }

    try {
      $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

      # Get all schemas and extract endpoints
      $allSchemas = $this.GetAllSchemas()
      $endpoints = $this.ExtractEndpointsFromSchemas($allSchemas)

      $validationResults.totalEndpoints = $endpoints.Count
      $maxEndpoints = $this.config.endpoint_validation.max_test_endpoints

      # Limit endpoints to test if configured
      if ($maxEndpoints -gt 0 -and $endpoints.Count -gt $maxEndpoints) {
        $endpoints = $endpoints | Select-Object -First $maxEndpoints
        $validationResults.skippedEndpoints = $validationResults.totalEndpoints - $endpoints.Count
      }

      $responseTimes = @()
      $slowestTime = 0
      $fastestTime = [int]::MaxValue

      foreach ($endpoint in $endpoints) {
        $testResult = $this.TestEndpoint($endpoint.path, $endpoint.method)
        $this.validatedEndpoints[$endpoint.path] = $testResult

        $validationResults.testedEndpoints++

        if ($testResult.isValid) {
          $validationResults.validEndpoints++

          if ($testResult.responseTime) {
            $responseTimes += $testResult.responseTime

            if ($testResult.responseTime -gt $slowestTime) {
              $slowestTime = $testResult.responseTime
              $validationResults.performance.slowestEndpoint = $endpoint.path
            }

            if ($testResult.responseTime -lt $fastestTime) {
              $fastestTime = $testResult.responseTime
              $validationResults.performance.fastestEndpoint = $endpoint.path
            }
          }
        }
        else {
          $validationResults.invalidEndpoints++
          if ($testResult.error) {
            $validationResults.errors += "$($endpoint.path): $($testResult.error)"
          }
        }

        # Progress logging every 10 endpoints
        if ($validationResults.testedEndpoints % 10 -eq 0 -and $this.logger) {
          $this.logger.LogDebug("Validated $($validationResults.testedEndpoints)/$($endpoints.Count) endpoints", "OpenAPISchema")
        }
      }

      $stopwatch.Stop()
      $validationResults.performance.totalTime = $stopwatch.ElapsedMilliseconds

      if ($responseTimes.Count -gt 0) {
        $validationResults.performance.averageResponseTime = ($responseTimes | Measure-Object -Average).Average
      }

      # Update cache timestamp
      $this.endpointCacheExpiry = (Get-Date).AddHours($this.endpointCacheTTLHours)

      # Save to cache file
      $this.SaveValidatedEndpointsCache()

      if ($this.logger) {
        $this.logger.LogInfo("Endpoint validation completed: $($validationResults.validEndpoints)/$($validationResults.testedEndpoints) endpoints valid", "OpenAPISchema")
      }
    }
    catch {
      $validationResults.errors += "Validation process failed: $($_.Exception.Message)"

      if ($this.logger) {
        $this.logger.LogError("Endpoint validation failed: $($_.Exception.Message)", "OpenAPISchema")
      }
    }

    return $validationResults
  }

  # Get only validated (working) endpoints
  [object] GetValidatedEndpoints([bool] $dataEndpointsOnly = $true) {
    # Ensure we have up-to-date validation
    if (-not $this.IsEndpointCacheValid()) {
      $this.ValidateAllEndpoints($false)
    }

    $validEndpoints = [PSCustomObject]@{}

    foreach ($endpoint in $this.validatedEndpoints.Keys) {
      $endpointData = $this.validatedEndpoints[$endpoint]

      if ($endpointData.isValid) {
        # Filter by data availability if requested
        if (-not $dataEndpointsOnly -or $endpointData.hasData) {
          $validEndpoints[$endpoint] = $endpointData
        }
      }
    }

    return $validEndpoints
  }

  # Extract endpoints from OpenAPI schemas
  hidden [array] ExtractEndpointsFromSchemas([object] $schemas) {
    $endpoints = @()

    foreach ($schemaType in $schemas.Keys) {
      $schema = $schemas[$schemaType]

      if ($schema.paths) {
        foreach ($path in $schema.paths.PSObject.Properties.Name) {
          $pathData = $schema.paths.$path

          # Extract supported HTTP methods
          $methods = @("get", "post", "put", "patch", "delete", "head", "options")

          foreach ($method in $methods) {
            if ($pathData.PSObject.Properties.Name -contains $method) {
              # Skip non-GET methods if configured
              if (-not $this.config.endpoint_validation.validate_all_methods -and $method -ne "get") {
                continue
              }

              $endpoints += @{
                path       = $path
                method     = $method.ToUpper()
                schemaType = $schemaType
                operation  = $pathData.$method
              }
            }
          }
        }
      }
    }

    return $endpoints
  }

  # Check if endpoint cache is valid
  hidden [bool] IsEndpointCacheValid() {
    return $this.validatedEndpoints.Count -gt 0 -and (Get-Date) -lt $this.endpointCacheExpiry
  }

  # Get endpoint validation statistics
  [object] GetEndpointValidationStatistics() {
    $stats = [PSCustomObject]@{
      cacheEnabled     = $this.config.endpoint_validation.cache_file_enabled
      cacheValid       = $this.IsEndpointCacheValid()
      cacheExpiry      = $this.endpointCacheExpiry.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
      totalEndpoints   = $this.validatedEndpoints.Count
      validEndpoints   = ($this.validatedEndpoints.Values | Where-Object { $_.isValid -eq $true }).Count
      dataEndpoints    = ($this.validatedEndpoints.Values | Where-Object { $_.isValid -eq $true -and $_.hasData -eq $true }).Count
      invalidEndpoints = ($this.validatedEndpoints.Values | Where-Object { $_.isValid -eq $false }).Count
      cacheFilePath    = $this.endpointCacheFilePath
      ttlHours         = $this.endpointCacheTTLHours
    }

    if ($this.validatedEndpoints.Count -gt 0) {
      $responseTimes = $this.validatedEndpoints.Values | Where-Object { $_.responseTime } | ForEach-Object { $_.responseTime }

      if ($responseTimes.Count -gt 0) {
        $stats.performance = @{
          averageResponseTime = ($responseTimes | Measure-Object -Average).Average
          minResponseTime     = ($responseTimes | Measure-Object -Minimum).Minimum
          maxResponseTime     = ($responseTimes | Measure-Object -Maximum).Maximum
          totalDataSize       = ($this.validatedEndpoints.Values | Where-Object { $_.responseSize } | Measure-Object -Property responseSize -Sum).Sum
        }
      }
    }

    return $stats
  }

  # Force refresh of endpoint validation cache
  [object] RefreshEndpointValidation() {
    if ($this.logger) {
      $this.logger.LogInfo("Forcing refresh of endpoint validation cache", "OpenAPISchema")
    }

    $this.validatedEndpoints.Clear()
    $this.endpointCacheExpiry = (Get-Date).AddHours(-1)

    return $this.ValidateAllEndpoints($true)
  }





  # Cache validated endpoints to file
  hidden [void] CacheValidatedEndpoints([array] $endpoints) {
    try {
      # Generate timestamped discovery file if we have file naming service
      if ($this.fileNamingService -and $this.nsxManager) {
        $discoveryFilePath = $this.fileNamingService.GenerateEndpointDiscoveryFilePath($this.apiDataDirectory, $this.nsxManager, "comprehensive")

        # Save detailed discovery results with timestamp
        $discoveryData = [PSCustomObject]@{
          nsxManager         = $this.nsxManager
          discoveryTimestamp = Get-Date
          discoveryType      = "comprehensive"
          endpointCount      = $endpoints.Count
          endpoints          = $endpoints
          ttlHours           = $this.endpointCacheTTLHours
          expiresAt          = (Get-Date).AddHours($this.endpointCacheTTLHours)
          metadata           = @{
            api_data_directory = $this.apiDataDirectory
            service_version    = "OpenAPISchemaService v2.0"
            discovery_method   = "automated"
          }
        }

        $discoveryData | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath $discoveryFilePath -Encoding UTF8

        if ($this.logger) {
          $this.logger.LogInfo("Saved endpoint discovery results to: $discoveryFilePath", "OpenAPISchema")
        }
      }

      # Cache data for current session
      $cacheData = [PSCustomObject]@{
        nsxManager    = $this.nsxManager
        lastUpdated   = Get-Date
        endpointCount = $endpoints.Count
        endpoints     = $endpoints
        ttlHours      = $this.endpointCacheTTLHours
        expiresAt     = (Get-Date).AddHours($this.endpointCacheTTLHours)
        metadata      = @{
          api_data_directory = $this.apiDataDirectory
          service_version    = "OpenAPISchemaService v2.0"
        }
      }

      # Ensure API data directory structure exists
      if ($this.fileNamingService -and $this.nsxManager) {
        $apiManagerDir = $this.fileNamingService.GetAPIDataDirectory($this.apiDataDirectory, $this.nsxManager)
        $this.endpointCacheFilePath = $this.fileNamingService.GenerateEndpointCacheFilePath($this.apiDataDirectory, $this.nsxManager)
      }
      else {
        # Fallback: Ensure directory exists
        $cacheDir = Split-Path $this.endpointCacheFilePath -Parent
        if (-not (Test-Path $cacheDir)) {
          New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
        }
      }

      $cacheData | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath $this.endpointCacheFilePath -Encoding UTF8

      # Update in-memory cache
      $this.validatedEndpoints = [PSCustomObject]@{}
      foreach ($endpoint in $endpoints) {
        $this.validatedEndpoints[$endpoint.endpoint] = $endpoint
      }
      $this.endpointCacheExpiry = $cacheData.expiresAt

      if ($this.logger) {
        $this.logger.LogInfo("Cached $($endpoints.Count) validated endpoints to standardized location: $($this.endpointCacheFilePath)", "OpenAPISchema")
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to cache validated endpoints: $($_.Exception.Message)", "OpenAPISchema")
      }
    }
  }
}
