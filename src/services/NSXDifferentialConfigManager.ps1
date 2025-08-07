# NSXDifferentialConfigManager.ps1
# Sophisticated differential configuration management for NSX-T
# Implements Infrastructure-as-Code best practices with delta-only operations

class NSXDifferentialConfigManager {
  hidden [object] $logger
  hidden [object] $authService
  hidden [object] $apiService
  hidden [object] $configManager
  hidden [string] $workingDirectory
  hidden [object] $operationContext
  hidden [object] $fileNamingService
  hidden [object] $configValidator
  hidden [object] $dataObjectFilter
  hidden [object] $openAPISchemaService
  hidden [object] $openApiSchemas
  hidden [string] $nsxManager # Added for OpenAPI service configuration

  # constructor with dependency injection for schema validation and system filtering
  NSXDifferentialConfigManager([object] $loggingService, [object] $authService, [object] $apiService, [object] $configManager, [string] $workingPath = $null, [object] $fileNamingService = $null, [object] $configValidator = $null, [object] $dataObjectFilter = $null, [object] $openAPISchemaService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.apiService = $apiService
    $this.configManager = $configManager
    $this.fileNamingService = $fileNamingService
    $this.configValidator = $configValidator
    $this.dataObjectFilter = $dataObjectFilter
    $this.openAPISchemaService = $openAPISchemaService
    $this.openApiSchemas = [PSCustomObject]@{}
    $this.nsxManager = $null # Initialize nsxManager

    # Set working directory to diffs directory
    if ($workingPath) {
      $this.workingDirectory = $workingPath
    }
    else {
      $scriptRoot = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
      $this.workingDirectory = Join-Path $scriptRoot "data\diffs"
    }

    # Ensure working directory exists
    if (-not (Test-Path $this.workingDirectory)) {
      New-Item -Path $this.workingDirectory -ItemType Directory -Force | Out-Null
    }

    # initialise operation context
    $this.operationContext = [PSCustomObject]@{}

    $this.logger.LogInfo("NSXDifferentialConfigManager initialised with schema validation support", "DifferentialConfig")
  }

  # Main differential configuration management workflow
  [object] ExecuteDifferentialOperation([string] $nsxManager, [PSCredential] $credentials, [string] $proposedConfigPath, [object] $options = [PSCustomObject]@{}) {
    try {
      $this.logger.LogStep("=== DIFFERENTIAL CONFIGURATION MANAGEMENT WORKFLOW ===")
      $this.logger.LogInfo("NSX Manager: $nsxManager", "DifferentialConfig")
      $this.logger.LogInfo("Proposed Config: $proposedConfigPath", "DifferentialConfig")

      # initialise operation context
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $hostname = $this.GetHostnameFromFQDN($nsxManager)
      $operationId = "${timestamp}_${hostname}_differential"

      $this.operationContext = @{
        OperationId        = $operationId
        Timestamp          = $timestamp
        NSXManager         = $nsxManager
        Hostname           = $hostname
        ProposedConfigPath = $proposedConfigPath
        Credentials        = $credentials
        Options            = $options
        Results            = [PSCustomObject]@{}
      }

      # Set NSX Manager for OpenAPI service configuration
      $this.SetNSXManager($nsxManager)

      # Step 1: GET existing configuration from NSX Manager
      $existingConfig = $this.GetExistingConfiguration($nsxManager, $credentials)

      # Step 2: SAVE existing configuration as baseline
      $existingConfigPath = $this.SaveExistingConfiguration($existingConfig, $nsxManager)

      # Step 3: LOAD proposed configuration
      $proposedConfig = $this.LoadProposedConfiguration($proposedConfigPath)

      # Step 4: COMPARE existing vs proposed -> identify differences
      $differences = $this.CompareConfigurationsWithSchema($existingConfig, $proposedConfig)

      # Step 5: SAVE differences to delta JSON file
      $deltaConfigPath = $this.SaveDifferentialConfiguration($differences, $nsxManager)

      # Step 6: APPLY only the differences (if not WhatIf Mode)
      if (-not $options.WhatIfMode) {
        $applyResult = $this.ApplyDifferentialConfiguration($nsxManager, $credentials, $differences)

        # Step 7: GET new configuration from NSX Manager
        $newConfig = $this.GetExistingConfiguration($nsxManager, $credentials)

        # Step 8: VERIFY applied configuration matches expectations
        $verificationResult = $this.VerifyAppliedConfiguration($newConfig, $proposedConfig, $differences)

        # Store verification result in operation context for tool access
        $this.operationContext.Results.Verification = $verificationResult

        # Step 9: SAVE final verification results
        $this.SaveVerificationResults($verificationResult, $nsxManager)
      }

      return $this.BuildOperationResult()

    }
    catch {
      $this.logger.LogError("Differential configuration operation failed: $($_.Exception.Message)", "DifferentialConfig")
      throw "Differential configuration operation failed: $($_.Exception.Message)"
    }
  }

  # Step 1: GET existing configuration from NSX Manager
  [object] GetExistingConfiguration([string] $nsxManager, [PSCredential] $credentials) {
    try {
      $this.logger.LogStep("Step 1: GET existing configuration from NSX Manager")

      $config = $this.configManager.GetPolicyConfiguration($nsxManager, $credentials, "infra", $false)

      $this.operationContext.Results.ExistingConfig = @{
        Retrieved   = $true
        Timestamp   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        ObjectCount = $this.CountConfigurationObjects($config)
      }

      $this.logger.LogInfo("Retrieved existing configuration with $($this.operationContext.Results.ExistingConfig.ObjectCount) objects", "DifferentialConfig")

      return $config

    }
    catch {
      $this.logger.LogError("Failed to get existing configuration: $($_.Exception.Message)", "DifferentialConfig")
      throw
    }
  }

  # Step 2: SAVE existing configuration as baseline
  [string] SaveExistingConfiguration([object] $config, [string] $nsxManager) {
    try {
      $this.logger.LogStep("Step 2: SAVE existing configuration as baseline")

      # Save to diffs directory instead of exports directory
      $hostname = $this.GetHostnameFromFQDN($nsxManager)
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

      # Generate filename using StandardFileNamingService if available, otherwise use fallback
      if ($this.fileNamingService) {
        $filename = $this.fileNamingService.GenerateStandardizedFileNameWithTimestamp($nsxManager, "default", "pre_update_baseline", $timestamp, "json")
      }
      else {
        # Fallback to original naming convention
        $filename = "${timestamp}_${hostname}_pre_update_baseline.json"
      }

      # Ensure diffs directory exists
      if (-not (Test-Path $this.workingDirectory)) {
        New-Item -Path $this.workingDirectory -ItemType Directory -Force | Out-Null
        $this.logger.LogInfo("Created diffs directory: $this.workingDirectory", "DifferentialConfig")
      }

      $filePath = Join-Path $this.workingDirectory $filename

      # Convert configuration to JSON and save
      $jsonOutput = $config | ConvertTo-Json -Depth 20 -Compress
      $jsonOutput | Out-File -FilePath $filePath -Encoding UTF8

      # Log file details
      $fileInfo = Get-Item $filePath
      $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
      $this.logger.LogInfo("Configuration saved to: $filePath", "DifferentialConfig")
      $this.logger.LogInfo("File size: $fileSizeKB KB", "DifferentialConfig")

      $this.operationContext.Results.ExistingConfigPath = $filePath
      $this.logger.LogInfo("Saved existing configuration baseline: $filePath", "DifferentialConfig")

      return $filePath

    }
    catch {
      $this.logger.LogError("Failed to save existing configuration: $($_.Exception.Message)", "DifferentialConfig")
      throw
    }
  }

  # Step 3: LOAD proposed configuration
  [object] LoadProposedConfiguration([string] $configPath) {
    try {
      $this.logger.LogStep("Step 3: LOAD proposed configuration")

      if (-not (Test-Path $configPath)) {
        throw "Proposed configuration file not found: $configPath"
      }

      $jsonContent = Get-Content $configPath -Raw | ConvertFrom-Json

      # Normalize the configuration structure
      $normalisedConfig = $this.NormalizeConfiguration($jsonContent)

      $this.operationContext.Results.ProposedConfig = @{
        Loaded      = $true
        Path        = $configPath
        ObjectCount = $this.CountConfigurationObjects($normalisedConfig)
      }

      $this.logger.LogInfo("Loaded proposed configuration with $($this.operationContext.Results.ProposedConfig.ObjectCount) objects", "DifferentialConfig")

      return $normalisedConfig

    }
    catch {
      $this.logger.LogError("Failed to load proposed configuration: $($_.Exception.Message)", "DifferentialConfig")
      throw
    }
  }

  # Step 4: COMPARE existing vs proposed -> identify differences
  [object] CompareConfigurations([object] $existingConfig, [object] $proposedConfig) {
    try {
      $this.logger.LogStep("Step 4: COMPARE existing vs proposed configurations")

      $differences = [PSCustomObject]@{
        metadata  = @{
          comparison_timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
          operation_id         = $this.operationContext.OperationId
          existing_objects     = $this.CountConfigurationObjects($existingConfig)
          proposed_objects     = $this.CountConfigurationObjects($proposedConfig)
        }
        create    = @()     # Objects that need to be created
        update    = @()     # Objects that need to be updated
        delete    = @()     # Objects that need to be deleted (if enabled)
        unchanged = @()  # Objects that are identical
      }

      # Get configuration objects for comparison
      $existingObjects = $this.ExtractConfigurationObjects($existingConfig)
      $proposedObjects = $this.ExtractConfigurationObjects($proposedConfig)

      # Build lookup tables for efficient comparison
      $existingLookup = [PSCustomObject]@{}
      foreach ($obj in $existingObjects) {
        $key = $this.GetObjectKey($obj)
        $existingLookup[$key] = $obj
      }

      $proposedLookup = [PSCustomObject]@{}
      foreach ($obj in $proposedObjects) {
        $key = $this.GetObjectKey($obj)
        $proposedLookup[$key] = $obj
      }

      # Compare proposed against existing
      foreach ($proposedObj in $proposedObjects) {
        $key = $this.GetObjectKey($proposedObj)

        if ($existingLookup.$key) {
          # Object exists - check if it needs updating
          $existingObj = $existingLookup.$key

          if ($this.ObjectsAreEqual($existingObj, $proposedObj)) {
            $differences.unchanged += @{
              key    = $key
              object = $proposedObj
            }
          }
          else {
            $differences.update += @{
              key      = $key
              existing = $existingObj
              proposed = $proposedObj
              changes  = $this.GetObjectChanges($existingObj, $proposedObj)
            }
          }
        }
        else {
          # Object doesn't exist - needs to be created
          $differences.create += @{
            key    = $key
            object = $proposedObj
          }
        }
      }

      # Check for objects that exist but aren't in proposed (potential deletes)
      foreach ($existingObj in $existingObjects) {
        $key = $this.GetObjectKey($existingObj)

        if (-not $proposedLookup.$key) {
          $differences.delete += @{
            key    = $key
            object = $existingObj
          }
        }
      }

      # Update operation context
      $this.operationContext.Results.Differences = @{
        CreateCount    = $differences.create.Count
        UpdateCount    = $differences.update.Count
        DeleteCount    = $differences.delete.Count
        UnchangedCount = $differences.unchanged.Count
        TotalChanges   = $differences.create.Count + $differences.update.Count + $differences.delete.Count
      }

      $this.logger.LogInfo("Configuration comparison complete:", "DifferentialConfig")
      $this.logger.LogInfo("  - Create: $($differences.create.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Update: $($differences.update.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Delete: $($differences.delete.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Unchanged: $($differences.unchanged.Count) objects", "DifferentialConfig")

      return $differences

    }
    catch {
      $this.logger.LogError("Failed to compare configurations: $($_.Exception.Message)", "DifferentialConfig")
      throw
    }
  }

  # Step 4: COMPARE existing vs proposed with OpenAPI schema validation
  [object] CompareConfigurationsWithSchema([object] $existingConfig, [object] $proposedConfig) {
    try {
      $this.logger.LogStep("Step 4: COMPARE existing vs proposed configurations (Schema-Aware)")

      # Step 1: Retrieve OpenAPI schemas
      $schemas = $this.GetOpenAPISchemas()

      # Step 2: Filter system objects from both configurations
      $filteredExisting = $this.FilterSystemObjects($existingConfig)
      $filteredProposed = $this.FilterSystemObjects($proposedConfig)

      # Step 3: Group objects by type for iterative processing
      $existingByType = $this.GroupObjectsByType($filteredExisting)
      $proposedByType = $this.GroupObjectsByType($filteredProposed)

      # Step 4: Perform iterative comparison
      $differences = $this.PerformIterativeComparison($existingByType, $proposedByType, $schemas)

      # Step 5: Update operation context with statistics
      $this.operationContext.Results.Differences = @{
        CreateCount             = $differences.create.Count
        UpdateCount             = $differences.update.Count
        DeleteCount             = $differences.delete.Count
        UnchangedCount          = $differences.unchanged.Count
        TotalChanges            = $differences.create.Count + $differences.update.Count + $differences.delete.Count
        ValidationErrors        = $differences.validation_errors.Count
        SystemObjectsFiltered   = $differences.metadata.system_objects_filtered
        SchemaValidationEnabled = $differences.metadata.schema_validation_enabled
        ObjectTypesProcessed    = $differences.metadata.object_types_processed
      }

      $this.logger.LogInfo("configuration comparison complete:", "DifferentialConfig")
      $this.logger.LogInfo("  - Create: $($differences.create.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Update: $($differences.update.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Delete: $($differences.delete.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Unchanged: $($differences.unchanged.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Validation errors: $($differences.validation_errors.Count)", "DifferentialConfig")
      $this.logger.LogInfo("  - Schema validation: $($differences.metadata.schema_validation_enabled)", "DifferentialConfig")
      $this.logger.LogInfo("  - System objects filtered: $($differences.metadata.system_objects_filtered)", "DifferentialConfig")

      return $differences

    }
    catch {
      $this.logger.LogError("Failed to compare configurations with schema: $($_.Exception.Message)", "DifferentialConfig")
      # Fallback to basic comparison if schema-aware comparison fails
      $this.logger.LogWarning("Falling back to basic comparison due to error", "DifferentialConfig")
      return $this.CompareConfigurations($existingConfig, $proposedConfig)
    }
  }

  # Perform iterative comparison by object type
  hidden [object] PerformIterativeComparison([object] $existingByType, [object] $proposedByType, [object] $schemas) {
    try {
      $this.logger.LogInfo("Starting iterative object-type comparison", "DifferentialConfig")

      $aggregatedDifferences = [PSCustomObject]@{
        metadata          = @{
          comparison_timestamp      = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
          operation_id              = $this.operationContext.OperationId
          schema_validation_enabled = ($schemas.Count -gt 0)
          system_objects_filtered   = ($null -ne $this.dataObjectFilter)
          object_types_processed    = @()
        }
        create            = @()
        update            = @()
        delete            = @()
        unchanged         = @()
        validation_errors = @()
      }

      # Define processing order (dependencies matter)
      $processingOrder = @('Service', 'Group', 'ContextProfile', 'SecurityPolicy', 'Domain', 'Other')

      foreach ($objectType in $processingOrder) {
        $this.logger.LogInfo("Processing object type: $objectType", "DifferentialConfig")

        $existingOfType = if ($existingByType.$objectType) { $existingByType.$objectType } else { @() }
        $proposedOfType = if ($proposedByType.$objectType) { $proposedByType.$objectType } else { @() }

        if ($existingOfType.Count -eq 0 -and $proposedOfType.Count -eq 0) {
          $this.logger.LogDebug("No objects of type $objectType to process", "DifferentialConfig")
          continue
        }

        # Get type-specific schema
        $typeSchema = $this.GetSchemaForObjectType($objectType, $schemas)

        # Perform type-specific comparison
        $typeDifferences = $this.CompareObjectsOfType($existingOfType, $proposedOfType, $objectType, $typeSchema)

        # Aggregate results
        $aggregatedDifferences.create += $typeDifferences.create
        $aggregatedDifferences.update += $typeDifferences.update
        $aggregatedDifferences.delete += $typeDifferences.delete
        $aggregatedDifferences.unchanged += $typeDifferences.unchanged
        $aggregatedDifferences.validation_errors += $typeDifferences.validation_errors

        # Track processing statistics
        $typeStats = [PSCustomObject]@{
          type              = $objectType
          existing_count    = $existingOfType.Count
          proposed_count    = $proposedOfType.Count
          create_count      = $typeDifferences.create.Count
          update_count      = $typeDifferences.update.Count
          delete_count      = $typeDifferences.delete.Count
          unchanged_count   = $typeDifferences.unchanged.Count
          validation_errors = $typeDifferences.validation_errors.Count
        }
        $aggregatedDifferences.metadata.object_types_processed += $typeStats

        $this.logger.LogInfo("Completed processing $objectType : Create($($typeStats.create_count)) Update($($typeStats.update_count)) Delete($($typeStats.delete_count)) Unchanged($($typeStats.unchanged_count))", "DifferentialConfig")
      }

      $this.logger.LogInfo("Iterative comparison complete", "DifferentialConfig")
      return $aggregatedDifferences
    }
    catch {
      $this.logger.LogError("Failed to perform iterative comparison: $($_.Exception.Message)", "DifferentialConfig")
      throw
    }
  }

  # Get schema for specific object type
  hidden [object] GetSchemaForObjectType([string] $objectType, [object] $schemas) {
    try {
      if ($schemas.Count -eq 0 -or -not $schemas.policy_openapi) {
        return @{
        }
      }

      $policySchema = $schemas.policy_openapi
      if (-not $policySchema.components -or -not $policySchema.components.schemas) {
        return @{
        }
      }

      # Map object types to schema names
      $schemaName = switch ($objectType) {
        "Service" { "Service" }
        "Group" { "Group" }
        "SecurityPolicy" { "SecurityPolicy" }
        "ContextProfile" { "ContextProfile" }
        "Domain" { "Domain" }
        default { $null }
      }

      if ($schemaName -and ($policySchema.components.schemas | Get-Member -Name $schemaName -ErrorAction SilentlyContinue)) {
        return $policySchema.components.schemas.$schemaName
      }

      return @{
      }
    }
    catch {
      $this.logger.LogDebug("Failed to get schema for object type $objectType : $($_.Exception.Message)", "DifferentialConfig")
      return @{
      }
    }
  }

  # Compare objects of a specific type with schema validation
  hidden [object] CompareObjectsOfType([array] $existingObjects, [array] $proposedObjects, [string] $objectType, [object] $typeSchema) {
    try {
      $this.logger.LogDebug("Comparing objects of type: $objectType", "DifferentialConfig")

      $typeDifferences = [PSCustomObject]@{
        create            = @()
        update            = @()
        delete            = @()
        unchanged         = @()
        validation_errors = @()
      }

      # Build lookup tables for this object type
      $existingLookup = [PSCustomObject]@{}
      foreach ($obj in $existingObjects) {
        # Validate against schema before processing
        $validationResult = $this.ValidateObjectAgainstSchema($obj, $typeSchema)
        if ($validationResult.errors.Count -gt 0) {
          $typeDifferences.validation_errors += @{
            object      = $obj
            errors      = $validationResult.errors
            type        = 'existing'
            object_type = $objectType
          }
          $this.logger.LogWarning("Validation errors in existing $objectType object: $($validationResult.errors -join ', ')", "DifferentialConfig")
          continue
        }

        $key = $this.GetObjectKey($obj)
        $existingLookup[$key] = $obj
      }

      $proposedLookup = [PSCustomObject]@{}
      foreach ($obj in $proposedObjects) {
        # Validate against schema before processing
        $validationResult = $this.ValidateObjectAgainstSchema($obj, $typeSchema)
        if ($validationResult.errors.Count -gt 0) {
          $typeDifferences.validation_errors += @{
            object      = $obj
            errors      = $validationResult.errors
            type        = 'proposed'
            object_type = $objectType
          }
          $this.logger.LogWarning("Validation errors in proposed $objectType object: $($validationResult.errors -join ', ')", "DifferentialConfig")
          continue
        }

        $key = $this.GetObjectKey($obj)
        $proposedLookup[$key] = $obj
      }

      # Compare proposed against existing
      foreach ($proposedObj in $proposedObjects) {
        $key = $this.GetObjectKey($proposedObj)

        if ($existingLookup.$key) {
          $existingObj = $existingLookup.$key

          # Use schema-aware comparison
          if ($this.ObjectsAreEqualWithSchema($existingObj, $proposedObj, $typeSchema)) {
            $typeDifferences.unchanged += @{
              key         = $key
              object      = $proposedObj
              object_type = $objectType
            }
          }
          else {
            $typeDifferences.update += @{
              key         = $key
              existing    = $existingObj
              proposed    = $proposedObj
              object_type = $objectType
              changes     = $this.GetObjectChangesWithSchema($existingObj, $proposedObj, $typeSchema)
            }
          }
        }
        else {
          $typeDifferences.create += @{
            key         = $key
            object      = $proposedObj
            object_type = $objectType
          }
        }
      }

      # Check for deletes
      foreach ($existingObj in $existingObjects) {
        $key = $this.GetObjectKey($existingObj)
        if (-not $proposedLookup.$key) {
          $typeDifferences.delete += @{
            key         = $key
            object      = $existingObj
            object_type = $objectType
          }
        }
      }

      return $typeDifferences
    }
    catch {
      $this.logger.LogError("Failed to compare objects of type $objectType : $($_.Exception.Message)", "DifferentialConfig")
      throw
    }
  }

  # Validate object against schema using NSXConfigValidator
  hidden [object] ValidateObjectAgainstSchema([object] $obj, [object] $schema) {
    try {
      if (-not $this.configValidator -or $schema.Count -eq 0) {
        return [PSCustomObject]@{ errors = @(); warnings = @() }
      }

      # Use the existing schema validation from NSXConfigValidator
      return $this.configValidator.ValidateChildAgainstSchema($obj, [PSCustomObject]@{ components = [PSCustomObject]@{ schemas = [PSCustomObject]@{ ($obj.resource_type) = $schema } } })
    }
    catch {
      $this.logger.LogDebug("Schema validation failed for object: $($_.Exception.Message)", "DifferentialConfig")
      return [PSCustomObject]@{ errors = @(); warnings = @() }
    }
  }

  # Schema-aware object equality check
  hidden [bool] ObjectsAreEqualWithSchema([object] $obj1, [object] $obj2, [object] $schema) {
    try {
      # Normalize both objects using schema-aware normalization
      $normalizedObj1 = $this.NormalizeObjectForComparisonWithSchema($obj1, $schema)
      $normalizedObj2 = $this.NormalizeObjectForComparisonWithSchema($obj2, $schema)

      $json1 = $normalizedObj1 | ConvertTo-Json -Depth 20 -Compress
      $json2 = $normalizedObj2 | ConvertTo-Json -Depth 20 -Compress

      $areEqual = $json1 -eq $json2

      if ($this.logger.logLevel -eq "DEBUG") {
        $objectKey = $this.GetObjectKey($obj1)
        $this.logger.LogDebug("Schema-aware object comparison for '$objectKey': Equal = $areEqual", "DifferentialConfig")
      }

      return $areEqual
    }
    catch {
      $this.logger.LogDebug("Schema-aware comparison failed, falling back to basic comparison: $($_.Exception.Message)", "DifferentialConfig")
      return $this.ObjectsAreEqual($obj1, $obj2)
    }
  }

  # Get object changes with schema awareness
  hidden [object] GetObjectChangesWithSchema([object] $existing, [object] $proposed, [object] $schema) {
    try {
      # Use schema-aware normalization for more accurate change detection
      $normalizedExisting = $this.NormalizeObjectForComparisonWithSchema($existing, $schema)
      $normalizedProposed = $this.NormalizeObjectForComparisonWithSchema($proposed, $schema)

      $changes = [PSCustomObject]@{
        modified_properties = @()
        added_properties    = @()
        removed_properties  = @()
      }

      # Compare properties
      $existingProps = $normalizedExisting.PSObject.Properties.Name
      $proposedProps = $normalizedProposed.PSObject.Properties.Name

      # Check for modified and added properties
      foreach ($prop in $proposedProps) {
        if ($prop -in $existingProps) {
          $existingValue = $normalizedExisting.$prop
          $proposedValue = $normalizedProposed.$prop

          if (($existingValue | ConvertTo-Json -Depth 10 -Compress) -ne ($proposedValue | ConvertTo-Json -Depth 10 -Compress)) {
            $changes.modified_properties += @{
              property  = $prop
              old_value = $existingValue
              new_value = $proposedValue
            }
          }
        }
        else {
          $changes.added_properties += @{
            property = $prop
            value    = $normalizedProposed.$prop
          }
        }
      }

      # Check for removed properties
      foreach ($prop in $existingProps) {
        if ($prop -notin $proposedProps) {
          $changes.removed_properties += @{
            property = $prop
            value    = $normalizedExisting.$prop
          }
        }
      }

      return $changes
    }
    catch {
      $this.logger.LogDebug("Schema-aware change detection failed, falling back to basic method: $($_.Exception.Message)", "DifferentialConfig")
      return $this.GetObjectChanges($existing, $proposed)
    }
  }

  # Helper methods...

  # Helper method to extract hostname from FQDN
  hidden [string] GetHostnameFromFQDN([string] $fqdn) {
    if ([string]::IsNullOrEmpty($fqdn)) {
      return "unknown"
    }
    $cleanFqdn = $fqdn -replace '^https?://', ''
    $hostname = $cleanFqdn.Split('.')[0]
    return $hostname.ToLower()
  }

  # Helper method to count configuration objects
  hidden [int] CountConfigurationObjects([object] $config) {
    if ($config.configuration -and $config.configuration.infra -and $config.configuration.infra.children) {
      return $config.configuration.infra.children.Count
    }
    elseif ($config.configuration -and $config.configuration.children) {
      return $config.configuration.children.Count
    }
    elseif ($config.children) {
      return $config.children.Count
    }
    return 0
  }

  # Helper method to normalize configuration structure
  hidden [object] NormalizeConfiguration([object] $config) {
    if ($config.configuration) {
      return $config
    }
    return @{
      metadata      = @{
        source    = "proposed"
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
      }
      configuration = $config
    }
  }

  # Helper method to extract configuration objects for comparison
  hidden [array] ExtractConfigurationObjects([object] $config) {
    $objects = @()

    if ($config.configuration -and $config.configuration.infra -and $config.configuration.infra.children) {
      $objects += $config.configuration.infra.children
    }
    elseif ($config.configuration -and $config.configuration.children) {
      $objects += $config.configuration.children
    }
    elseif ($config.children) {
      $objects += $config.children
    }

    return $objects
  }

  # Helper method to generate object key for comparison
  hidden [string] GetObjectKey([object] $obj) {
    $resourceType = $obj.resource_type
    $id = $obj.id

    # Handle different object structures
    if ($resourceType.StartsWith("Child")) {
      $actualResourceType = $resourceType.Replace("Child", "")
      if ($obj.$actualResourceType) {
        $id = $obj.$actualResourceType.id
      }
    }

    return "$resourceType|$id"
  }

  # Helper method to check if objects are equal
  hidden [bool] ObjectsAreEqual([object] $obj1, [object] $obj2) {
    # Normalize both objects by removing NSX metadata before comparison
    $normalisedObj1 = $this.NormalizeObjectForComparison($obj1)
    $normalisedObj2 = $this.NormalizeObjectForComparison($obj2)

    $json1 = $normalisedObj1 | ConvertTo-Json -Depth 20 -Compress
    $json2 = $normalisedObj2 | ConvertTo-Json -Depth 20 -Compress

    $areEqual = $json1 -eq $json2

    if ($this.logger.logLevel -eq "DEBUG") {
      $objectKey = $this.GetObjectKey($obj1)
      $this.logger.LogDebug("Object comparison for '$objectKey': Equal = $areEqual", "DifferentialConfig")
    }

    return $areEqual
  }

  # Helper method to normalize objects for comparison by removing NSX metadata
  hidden [object] NormalizeObjectForComparison([object] $obj) {
    # Create a copy of the object
    $normalised = $obj.PSObject.Copy()

    # List of NSX metadata properties to exclude from comparison
    $metadataProperties = @(
      'path', 'relative_path', 'parent_path', 'unique_id', 'marked_for_delete', 'overridden',
      '_create_user', '_create_time', '_last_modified_user', '_last_modified_time',
      '_system_owned', '_protection', '_revision'
    )

    # Remove metadata properties from the main object
    foreach ($prop in $metadataProperties) {
      if ($normalised.PSObject.Properties.Name -contains $prop) {
        $normalised.PSObject.Properties.Remove($prop)
      }
    }

    # Handle nested objects (like Service entries, Group members, etc.)
    if ($normalised.service_entries) {
      for ($i = 0; $i -lt $normalised.service_entries.Count; $i++) {
        $entry = $normalised.service_entries[$i]
        foreach ($prop in $metadataProperties) {
          if ($entry.PSObject.Properties.Name -contains $prop) {
            $entry.PSObject.Properties.Remove($prop)
          }
        }
      }
    }

    if ($normalised.expression) {
      for ($i = 0; $i -lt $normalised.expression.Count; $i++) {
        $expr = $normalised.expression[$i]
        foreach ($prop in $metadataProperties) {
          if ($expr.PSObject.Properties.Name -contains $prop) {
            $expr.PSObject.Properties.Remove($prop)
          }
        }
      }
    }

    # Handle ChildService, ChildGroup, etc. structures
    if ($normalised.resource_type -and $normalised.resource_type.StartsWith("Child")) {
      $actualResourceType = $normalised.resource_type.Replace("Child", "")
      if ($normalised.$actualResourceType) {
        # Recursively normalize the nested object
        $normalised.$actualResourceType = $this.NormalizeObjectForComparison($normalised.$actualResourceType)
      }
    }

    return $normalised
  }

  # Helper method to get object changes
  hidden [object] GetObjectChanges([object] $existing, [object] $proposed) {
    return @{
      summary = "Object modified"
      # More sophisticated diff logic could be added here
    }
  }

  # Helper method to generate delta payload
  hidden [object] GenerateDeltaPayload([object] $differences) {
    $children = @()

    # Add create operations
    foreach ($item in $differences.create) {
      $children += $item.object
    }

    # Add update operations
    foreach ($item in $differences.update) {
      $children += $item.proposed
    }

    return @{
      resource_type = "Infra"
      id            = "infra"
      display_name  = "infra"
      children      = $children
    }
  }

  # Helper method to apply object operation
  hidden [object] ApplyObjectOperation([string] $nsxManager, [PSCredential] $credentials, [object] $obj, [string] $operation) {
    try {
      # Use the existing config manager to apply the single object
      $singleObjectConfig = [PSCustomObject]@{
        metadata      = @{
          operation = $operation
          timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
        configuration = @{
          resource_type = "Infra"
          id            = "infra"
          display_name  = "infra"
          children      = @($obj)
        }
      }

      $result = $this.configManager.ApplyConfiguration($nsxManager, $credentials, $singleObjectConfig, "PATCH")

      return @{
        success    = $result.success
        operation  = $operation
        object_key = $this.GetObjectKey($obj)
        result     = $result
      }
    }
    catch {
      return @{
        success    = $false
        operation  = $operation
        object_key = $this.GetObjectKey($obj)
        error      = $_.Exception.Message
      }
    }
  }

  # Helper method to verify object exists
  hidden [object] VerifyObjectExists([object] $config, [object] $expectedObject) {
    $objects = $this.ExtractConfigurationObjects($config)
    $expectedKey = $this.GetObjectKey($expectedObject)

    foreach ($obj in $objects) {
      $key = $this.GetObjectKey($obj)
      if ($key -eq $expectedKey) {
        return @{
          success      = $true
          object_key   = $key
          verification = "Object exists"
        }
      }
    }

    return @{
      success      = $false
      object_key   = $expectedKey
      verification = "Object not found"
    }
  }

  # Helper method to verify object updated
  hidden [object] VerifyObjectUpdated([object] $config, [object] $expectedObject, [object] $changes) {
    $existsResult = $this.VerifyObjectExists($config, $expectedObject)

    if ($existsResult.success) {
      return @{
        success      = $true
        object_key   = $existsResult.object_key
        verification = "Object updated"
      }
    }

    return @{
      success      = $false
      object_key   = $existsResult.object_key
      verification = "Updated object not found"
    }
  }

  # Helper method to build operation result
  hidden [object] BuildOperationResult() {
    return @{
      success      = $true
      operation_id = $this.operationContext.OperationId
      timestamp    = $this.operationContext.Timestamp
      nsx_manager  = $this.operationContext.NSXManager
      results      = $this.operationContext.Results
    }
  }

  # schema-aware object normalization for comparison
  hidden [object] NormalizeObjectForComparisonWithSchema([object] $obj, [object] $schema) {
    try {
      $normalized = $obj.PSObject.Copy()

      # Get schema-required properties if schema is available
      $requiredProperties = $this.GetSchemaRequiredProperties($schema)
      $allSchemaProperties = $this.GetAllSchemaProperties($schema)

      # metadata exclusion list (combines existing + schema-based)
      $metadataProperties = @(
        # NSX system metadata (existing)
        'path', 'relative_path', 'parent_path', 'unique_id', 'marked_for_delete', 'overridden',
        '_create_user', '_create_time', '_last_modified_user', '_last_modified_time',
        '_system_owned', '_protection', '_revision',

        # Additional schema-based exclusions (read-only computed properties)
        '_schema_version', '_links', '_self', 'results_count', 'cursor',

        # System object indicators (should already be filtered, but safety net)
        'is_default', 'system_owned', 'managed_by', 'origin_type',

        # NSX-specific timestamp and computed fields
        'create_time', 'last_modified_time', 'last_modified_user', 'create_user',
        'realization_id', 'state', 'intent_path', 'realized_path'
      )

      # Remove metadata properties
      foreach ($prop in $metadataProperties) {
        if ($normalized.PSObject.Properties.Name -contains $prop) {
          $normalized.PSObject.Properties.Remove($prop)
        }
      }

      # Remove properties not in schema (if schema is available and has properties)
      if ($allSchemaProperties.Count -gt 0) {
        $objectProperties = @($normalized.PSObject.Properties.Name)
        foreach ($prop in $objectProperties) {
          if ($prop -notin $allSchemaProperties -and $prop -notin $requiredProperties) {
            $this.logger.LogDebug("Removing non-schema property: $prop", "DifferentialConfig")
            $normalized.PSObject.Properties.Remove($prop)
          }
        }
      }

      # Recursively normalize nested objects
      $normalized = $this.NormalizeNestedObjectsWithSchema($normalized, $schema)

      return $normalized
    }
    catch {
      $this.logger.LogDebug("Schema-aware normalization failed, falling back to basic normalization: $($_.Exception.Message)", "DifferentialConfig")
      return $this.NormalizeObjectForComparison($obj)
    }
  }

  # Get required properties from schema
  hidden [array] GetSchemaRequiredProperties([object] $schema) {
    try {
      if ($schema -and $schema.required) {
        return $schema.required
      }
      return @()
    }
    catch {
      return @()
    }
  }

  # Get all properties from schema
  hidden [array] GetAllSchemaProperties([object] $schema) {
    try {
      if ($schema -and $schema.properties) {
        return $schema.properties.PSObject.Properties.Name
      }
      return @()
    }
    catch {
      return @()
    }
  }

  # Recursively normalize nested objects with schema awareness
  hidden [object] NormalizeNestedObjectsWithSchema([object] $obj, [object] $schema) {
    try {
      # Handle service entries
      if ($obj.service_entries) {
        for ($i = 0; $i -lt $obj.service_entries.Count; $i++) {
          $entry = $obj.service_entries[$i]
          # Get schema for service entry if available
          $entrySchema = $this.GetNestedObjectSchema($schema, "service_entries")
          $obj.service_entries[$i] = $this.NormalizeObjectForComparisonWithSchema($entry, $entrySchema)
        }
      }

      # Handle group expressions
      if ($obj.expression) {
        for ($i = 0; $i -lt $obj.expression.Count; $i++) {
          $expr = $obj.expression[$i]
          # Get schema for expression if available
          $exprSchema = $this.GetNestedObjectSchema($schema, "expression")
          $obj.expression[$i] = $this.NormalizeObjectForComparisonWithSchema($expr, $exprSchema)
        }
      }

      # Handle security policy rules
      if ($obj.rules) {
        for ($i = 0; $i -lt $obj.rules.Count; $i++) {
          $rule = $obj.rules[$i]
          # Get schema for rule if available
          $ruleSchema = $this.GetNestedObjectSchema($schema, "rules")
          $obj.rules[$i] = $this.NormalizeObjectForComparisonWithSchema($rule, $ruleSchema)
        }
      }

      # Handle ChildService, ChildGroup, etc. structures
      if ($obj.resource_type -and $obj.resource_type.StartsWith("Child")) {
        $actualResourceType = $obj.resource_type.Replace("Child", "")
        if ($obj.$actualResourceType) {
          # Get nested object schema
          $nestedSchema = $this.GetSchemaForObjectType($actualResourceType, [PSCustomObject]@{ policy_openapi = [PSCustomObject]@{ components = [PSCustomObject]@{ schemas = [PSCustomObject]@{ $actualResourceType = $schema } } } })
          $obj.$actualResourceType = $this.NormalizeObjectForComparisonWithSchema($obj.$actualResourceType, $nestedSchema)
        }
      }

      return $obj
    }
    catch {
      $this.logger.LogDebug("Nested object normalization failed: $($_.Exception.Message)", "DifferentialConfig")
      return $obj
    }
  }

  # Get schema for nested object property
  hidden [object] GetNestedObjectSchema([object] $parentSchema, [string] $propertyName) {
    try {
      if ($parentSchema -and $parentSchema.properties -and $parentSchema.properties.$propertyName) {
        $propSchema = $parentSchema.properties.$propertyName

        # Handle array types
        if ($propSchema.type -eq "array" -and $propSchema.items) {
          return $propSchema.items
        }

        # Handle object types
        if ($propSchema.type -eq "object") {
          return $propSchema
        }

        # Handle reference types
        if ($propSchema.'$ref') {
          # This would need more sophisticated reference resolution
          return @{
          }
        }
      }

      return @{
      }
    }
    catch {
      return @{
      }
    }
  }

  # Get OpenAPI schemas from the service chain with configuration
  hidden [object] GetOpenAPISchemas() {
    # Return cached schemas if available and fresh
    if ($this.openApiSchemas -and $this.openApiSchemas.Count -gt 0) {
      $this.logger.LogDebug("Returning cached OpenAPI schemas", "DifferentialConfig")
      return $this.openApiSchemas
    }

    # Try OpenAPI schema service first if available
    if ($this.openAPISchemaService) {
      try {
        $this.logger.LogInfo("Retrieving OpenAPI schemas from openAPISchemaService", "DifferentialConfig")

        # Configure the OpenAPI service with NSX Manager if not already configured
        if ($this.nsxManager -and -not $this.openAPISchemaService.isConfigured) {
          $this.logger.LogInfo("Configuring OpenAPI schema service with NSX Manager: $($this.nsxManager)", "DifferentialConfig")

          # Get credentials from authentication service
          $credential = $null
          if ($this.authService) {
            $credential = $this.authService.GetCredential($this.nsxManager, $null, $false, $false)
          }

          if ($credential) {
            $this.openAPISchemaService.SetNSXManagerConfiguration($this.nsxManager, $credential)
            $this.logger.LogInfo("OpenAPI schema service configured successfully", "DifferentialConfig")
          }
          else {
            $this.logger.LogWarning("No credentials available for OpenAPI schema service configuration", "DifferentialConfig")
          }
        }

        $schemas = $this.openAPISchemaService.GetAllSchemas()
        if ($schemas -and $schemas.Count -gt 0) {
          $this.openApiSchemas = $schemas
          $this.logger.LogInfo("OpenAPI schemas successfully retrieved from openAPISchemaService and cached", "DifferentialConfig")
          return $this.openApiSchemas
        }
        else {
          $this.logger.LogWarning("openAPISchemaService.GetAllSchemas returned empty or null result", "DifferentialConfig")
        }
      }
      catch {
        $this.logger.LogError("Failed to retrieve OpenAPI schemas from openAPISchemaService: $($_.Exception.Message)", "DifferentialConfig")
      }
    }

    # fallback to configValidator with robust validation
    if ($this.configValidator) {
      try {
        # method validation with multiple checks
        $validator = $this.configValidator
        $hasMethod = $false

        # Check 1: PSObject.Methods collection
        if ($validator.PSObject.Methods.Name -contains "GetOpenAPISchemas") {
          $hasMethod = $true
          $this.logger.LogDebug("Method found via PSObject.Methods check", "DifferentialConfig")
        }

        # Check 2: Get-Member verification (additional safety)
        if (-not $hasMethod) {
          $methods = $validator | Get-Member -MemberType Method | Where-Object { $_.Name -eq "GetOpenAPISchemas" }
          if ($methods) {
            $hasMethod = $true
            $this.logger.LogDebug("Method found via Get-Member check", "DifferentialConfig")
          }
        }

        # Check 3: Reflection-based method check (final verification)
        if (-not $hasMethod) {
          try {
            $type = $validator.GetType()
            $method = $type.GetMethod("GetOpenAPISchemas")
            if ($method) {
              $hasMethod = $true
              $this.logger.LogDebug("Method found via reflection check", "DifferentialConfig")
            }
          }
          catch {
            $this.logger.LogDebug("Reflection check failed: $($_.Exception.Message)", "DifferentialConfig")
          }
        }

        if ($hasMethod) {
          $this.logger.LogInfo("Retrieving OpenAPI schemas from configValidator (method verified)", "DifferentialConfig")

          # Additional safety: Verify object type before method call
          $validatorType = $validator.GetType().Name
          if ($validatorType -eq "NSXConfigValidator") {
            # Use invoke-expression for additional safety in production
            $schemas = & { $validator.GetOpenAPISchemas() }

            if ($schemas -and $schemas.Count -gt 0) {
              $this.openApiSchemas = $schemas
              $this.logger.LogInfo("OpenAPI schemas successfully retrieved from configValidator and cached", "DifferentialConfig")
              return $this.openApiSchemas
            }
            else {
              $this.logger.LogWarning("configValidator.GetOpenAPISchemas returned empty or null result", "DifferentialConfig")
            }
          }
          else {
            $this.logger.LogError("ConfigValidator object type mismatch: expected 'NSXConfigValidator', got '$validatorType'", "DifferentialConfig")
          }
        }
        else {
          $this.logger.LogWarning("configValidator does not have GetOpenAPISchemas method (verified with multiple checks)", "DifferentialConfig")

          # debugging with method verification
          if ($validator.PSObject.Methods.Name -contains "VerifyMethodAvailability") {
            try {
              $verification = $validator.VerifyMethodAvailability()
              $this.logger.LogError("NSXConfigValidator verification results:", "DifferentialConfig")
              $this.logger.LogError("  - hasGetOpenAPISchemas: $($verification.hasGetOpenAPISchemas)", "DifferentialConfig")
              $this.logger.LogError("  - classType: $($verification.classType)", "DifferentialConfig")
              $this.logger.LogError("  - classFullName: $($verification.classFullName)", "DifferentialConfig")
              $this.logger.LogError("  - assemblyLocation: $($verification.assemblyLocation)", "DifferentialConfig")
              $this.logger.LogError("  - availableMethods: $($verification.allMethods)", "DifferentialConfig")
            }
            catch {
              $this.logger.LogError("Failed to run VerifyMethodAvailability: $($_.Exception.Message)", "DifferentialConfig")
            }
          }

          # Log available methods for debugging
          $availableMethods = $validator.PSObject.Methods.Name | Where-Object { $_ -like "*OpenAPI*" -or $_ -like "*Schema*" } | Sort-Object
          if ($availableMethods) {
            $this.logger.LogDebug("Available OpenAPI/Schema methods: $($availableMethods -join ', ')", "DifferentialConfig")
          }
          else {
            $this.logger.LogDebug("No OpenAPI or Schema methods found on configValidator", "DifferentialConfig")
          }
        }
      }
      catch {
        $this.logger.LogError("Failed to retrieve OpenAPI schemas from configValidator: $($_.Exception.Message)", "DifferentialConfig")

        # error logging for production debugging
        $this.logger.LogError("ConfigValidator type: $($this.configValidator.GetType().Name)", "DifferentialConfig")
        $this.logger.LogError("Error details: $($_.Exception.GetType().Name) - $($_.Exception.Message)", "DifferentialConfig")
        if ($_.Exception.InnerException) {
          $this.logger.LogError("Inner exception: $($_.Exception.InnerException.Message)", "DifferentialConfig")
        }
      }
    }
    else {
      $this.logger.LogWarning("No configValidator available for OpenAPI schema retrieval", "DifferentialConfig")
    }

    # Final fallback: Log warning about missing OpenAPI schema service
    if (-not $this.openAPISchemaService) {
      $this.logger.LogWarning("OpenAPI schema service not available - schema validation will be limited", "DifferentialConfig")
    }

    $this.logger.LogWarning("No OpenAPI schemas available from any service - proceeding without schema validation", "DifferentialConfig")
    $this.openApiSchemas = [PSCustomObject]@{}
    return $this.openApiSchemas
  }

  # Set NSX Manager for OpenAPI service configuration
  [void] SetNSXManager([string] $nsxManager) {
    $this.nsxManager = $nsxManager

    # Configure OpenAPI service if available
    if ($this.openAPISchemaService -and $nsxManager) {
      try {
        $credential = $null
        if ($this.authService) {
          $credential = $this.authService.GetCredential($this.nsxManager, $null, $false, $false)
        }

        if ($credential) {
          $this.openAPISchemaService.SetNSXManagerConfiguration($nsxManager, $credential)
          $this.logger.LogInfo("OpenAPI schema service configured with NSX Manager: $nsxManager", "DifferentialConfig")

          # Clear cached schemas to force refresh with new configuration
          $this.openApiSchemas = [PSCustomObject]@{}
        }
        else {
          $this.logger.LogWarning("No credentials available for OpenAPI service configuration", "DifferentialConfig")
        }
      }
      catch {
        $this.logger.LogError("Failed to configure OpenAPI service with NSX Manager: $($_.Exception.Message)", "DifferentialConfig")
      }
    }
  }

  # post-update verification: Compare delta objects to new export and report/save results
  hidden [object] VerifyAppliedConfiguration([object] $newConfig, [object] $proposedConfig, [object] $differences) {
    try {
      $this.logger.LogStep("Step 8: VERIFY applied configuration matches expectations (Post-Update Verification)")

      # Extract objects from delta (create/update only)
      $deltaObjects = @()
      if ($differences.create) { $deltaObjects += $differences.create | ForEach-Object { $_.object } }
      if ($differences.update) { $deltaObjects += $differences.update | ForEach-Object { $_.proposed } }

      # Extract objects from new config
      $newConfigObjects = $this.ExtractConfigurationObjects($newConfig)
      $newConfigLookup = [PSCustomObject]@{}
      foreach ($obj in $newConfigObjects) {
        $key = $this.GetObjectKey($obj)
        $newConfigLookup[$key] = $obj
      }

      $verificationResults = @()
      foreach ($deltaObj in $deltaObjects) {
        $key = $this.GetObjectKey($deltaObj)
        if ($newConfigLookup.$key) {
          $appliedObj = $newConfigLookup.$key
          # Use schema-aware comparison if possible
          $objectType = $deltaObj.resource_type
          $schemas = $this.GetOpenAPISchemas()
          $typeSchema = $this.GetSchemaForObjectType($objectType, $schemas)
          $equal = $this.ObjectsAreEqualWithSchema($appliedObj, $deltaObj, $typeSchema)
          $verificationResults += @{
            key         = $key
            object_type = $objectType
            status      = if ($equal) { 'MATCH' } else { 'MISMATCH' }
            details     = if ($equal) { 'Object matches intended delta' } else { 'Object differs from intended delta' }
            applied     = $appliedObj
            intended    = $deltaObj
          }
        }
        else {
          $verificationResults += @{
            key         = $key
            object_type = $deltaObj.resource_type
            status      = 'NOT_FOUND'
            details     = 'Object not found in new configuration after update'
            intended    = $deltaObj
          }
        }
      }

      # Summarize results
      $summary = [PSCustomObject]@{
        total_delta_objects = $deltaObjects.Count
        matches             = ($verificationResults | Where-Object { $_.status -eq 'MATCH' }).Count
        mismatches          = ($verificationResults | Where-Object { $_.status -eq 'MISMATCH' }).Count
        not_found           = ($verificationResults | Where-Object { $_.status -eq 'NOT_FOUND' }).Count
      }

      $this.logger.LogInfo("Post-update verification complete: $($summary.matches) match, $($summary.mismatches) mismatch, $($summary.not_found) not found", "DifferentialConfig")

      return @{
        summary = $summary
        results = $verificationResults
      }
    }
    catch {
      $this.logger.LogError("Failed post-update verification: $($_.Exception.Message)", "DifferentialConfig")
      return @{
        summary = [PSCustomObject]@{ error = $_.Exception.Message }
        results = @()
      }
    }
  }

  # Save verification results to file (JSON)
  hidden [void] SaveVerificationResults([object] $verificationResult, [string] $nsxManager) {
    try {
      $hostname = $this.GetHostnameFromFQDN($nsxManager)
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $filename = if ($this.fileNamingService) {
        $this.fileNamingService.GenerateStandardizedFileNameWithTimestamp($nsxManager, "default", "post_update_verification", $timestamp, "json")
      }
      else {
        "${timestamp}_${hostname}_post_update_verification.json"
      }
      # Ensure diffs directory exists
      if (-not (Test-Path $this.workingDirectory)) {
        New-Item -Path $this.workingDirectory -ItemType Directory -Force | Out-Null
      }
      $filePath = Join-Path $this.workingDirectory $filename
      $jsonOutput = $verificationResult | ConvertTo-Json -Depth 20 -Compress
      $jsonOutput | Out-File -FilePath $filePath -Encoding UTF8
      $this.logger.LogInfo("Verification results saved to: $filePath", "DifferentialConfig")
      $this.operationContext.Results.VerificationResultsPath = $filePath
    }
    catch {
      $this.logger.LogError("Failed to save verification results: $($_.Exception.Message)", "DifferentialConfig")
    }
  }

  # Save actual payload for debugging purposes
  hidden [void] SaveActualPayload([object] $payload, [string] $nsxManager, [string] $fileType) {
    try {
      $hostname = $this.GetHostnameFromFQDN($nsxManager)
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $filename = if ($this.fileNamingService) {
        $this.fileNamingService.GenerateStandardizedFileNameWithTimestamp($nsxManager, "default", $fileType, $timestamp, "json")
      }
      else {
        "${timestamp}_${hostname}_${fileType}.json"
      }
      # Ensure diffs directory exists
      if (-not (Test-Path $this.workingDirectory)) {
        New-Item -Path $this.workingDirectory -ItemType Directory -Force | Out-Null
      }
      $filePath = Join-Path $this.workingDirectory $filename
      $jsonOutput = $payload | ConvertTo-Json -Depth 20 -Compress
      $jsonOutput | Out-File -FilePath $filePath -Encoding UTF8
      $this.logger.LogInfo("Actual payload saved for debugging: $filePath", "DifferentialConfig")
      $this.operationContext.Results.ActualPayloadPath = $filePath
    }
    catch {
      $this.logger.LogError("Failed to save actual payload: $($_.Exception.Message)", "DifferentialConfig")
    }
  }

  # Analyze payload contents for debugging
  hidden [void] AnalyzePayloadContents([object] $payload) {
    try {
      $this.logger.LogInfo("=== PAYLOAD ANALYSIS FOR DEBUGGING ===", "DifferentialConfig")

      if ($payload.children) {
        $objectTypes = [PSCustomObject]@{}
        $systemObjectCount = 0
        $userObjectCount = 0

        foreach ($child in $payload.children) {
          $resourceType = $child.resource_type
          if (-not $objectTypes.$resourceType) {
            $objectTypes.$resourceType = 0
          }
          $objectTypes.$resourceType++

          # Check for system object indicators
          $isSystemObject = $false
          if ($child.is_default -eq $true) { $isSystemObject = $true }
          if ($child._system_owned -eq $true) { $isSystemObject = $true }  # FIXED: Added missing underscore
          if ($child._create_user -eq "system") { $isSystemObject = $true }
          if ($child._last_modified_user -eq "system") { $isSystemObject = $true }
          if ($child.managed_by) { $isSystemObject = $true }
          if ($child.origin_type -eq "SYSTEM") { $isSystemObject = $true }
          if ($child.id -and $child.id.ToString().StartsWith("default-")) { $isSystemObject = $true }
          if ($child.display_name -and $child.display_name.ToString().StartsWith("default")) { $isSystemObject = $true }

          # Check for Child + _system_owned combination (user's specific requirement)
          if ($child.resource_type -and $child.resource_type.ToString().StartsWith("Child") -and $child._system_owned -eq $true) {
            $isSystemObject = $true
            $this.logger.LogWarning("DETECTED: Child resource type with _system_owned = true: $($child.resource_type) - $($child.display_name)", "DifferentialConfig")
          }

          # Check nested objects (like Service within ChildService)
          if ($child.Service -and $child.Service._system_owned -eq $true -and $child.resource_type -and $child.resource_type.ToString().StartsWith("Child")) {
            $isSystemObject = $true
            $this.logger.LogWarning("DETECTED: Child resource type with nested _system_owned = true: $($child.resource_type) - $($child.display_name)", "DifferentialConfig")
          }

          if ($isSystemObject) {
            $systemObjectCount++
            $this.logger.LogWarning("SYSTEM OBJECT DETECTED: $resourceType - $($child.display_name) ($($child.id))", "DifferentialConfig")
          }
          else {
            $userObjectCount++
          }
        }

        $this.logger.LogInfo("Total objects in payload: $($payload.children.Count)", "DifferentialConfig")
        $this.logger.LogInfo("System objects detected: $systemObjectCount", "DifferentialConfig")
        $this.logger.LogInfo("User objects detected: $userObjectCount", "DifferentialConfig")

        $this.logger.LogInfo("Object types breakdown:", "DifferentialConfig")
        foreach ($type in $objectTypes.Keys) {
          $this.logger.LogInfo("  - ${type}: $($objectTypes[$type])", "DifferentialConfig")
        }

        if ($systemObjectCount -gt 0) {
          $this.logger.LogWarning("SYSTEM OBJECTS FOUND IN PAYLOAD - This may cause verification failures", "DifferentialConfig")
        }
      }
    }
    catch {
      $this.logger.LogError("Failed to analyze payload contents: $($_.Exception.Message)", "DifferentialConfig")
    }
  }

  # Optimize delta.json generation: ensure only create/update objects are included, no duplicates
  hidden [object] SaveDifferentialConfiguration([object] $differences, [string] $nsxManager) {
    try {
      $this.logger.LogStep("Step 5: SAVE differences to delta JSON file (Optimized)")
      $hostname = $this.GetHostnameFromFQDN($nsxManager)
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $filename = if ($this.fileNamingService) {
        $this.fileNamingService.GenerateStandardizedFileNameWithTimestamp($nsxManager, "default", "delta", $timestamp, "json")
      }
      else {
        "${timestamp}_${hostname}_delta.json"
      }
      # Ensure diffs directory exists
      if (-not (Test-Path $this.workingDirectory)) {
        New-Item -Path $this.workingDirectory -ItemType Directory -Force | Out-Null
      }
      # Only include create/update objects, deduplicate by key
      $deltaObjects = [PSCustomObject]@{
      }
      if ($differences.create) { foreach ($item in $differences.create) { $deltaObjects[$item.key] = $item.object } }
      if ($differences.update) { foreach ($item in $differences.update) { $deltaObjects[$item.key] = $item.proposed } }
      $children = $deltaObjects.Values
      $deltaPayload = [PSCustomObject]@{
        resource_type = "Infra"
        id            = "infra"
        display_name  = "infra"
        children      = $children
      }
      $filePath = Join-Path $this.workingDirectory $filename
      $jsonOutput = $deltaPayload | ConvertTo-Json -Depth 20 -Compress
      $jsonOutput | Out-File -FilePath $filePath -Encoding UTF8
      $this.logger.LogInfo("Delta configuration saved to: $filePath", "DifferentialConfig")
      $this.operationContext.Results.DeltaConfigPath = $filePath
      return $filePath
    }
    catch {
      $this.logger.LogError("Failed to save delta configuration: $($_.Exception.Message)", "DifferentialConfig")
      return $null
    }
  }

  # Step 6: APPLY differential configuration to NSX Manager
  [object] ApplyDifferentialConfiguration([string] $nsxManager, [PSCredential] $credentials, [object] $differences) {
    $totalChanges = 0
    try {
      $this.logger.LogStep("Step 6: APPLY differential configuration to NSX Manager")

      # Check if there are any changes to apply
      $totalChanges = $differences.create.Count + $differences.update.Count
      if ($totalChanges -eq 0) {
        $this.logger.LogInfo("No changes to apply - configuration is already up to date", "DifferentialConfig")
        return @{
          success         = $true
          applied_objects = 0
          skipped_objects = 0
          failed_objects  = 0
          message         = "No changes required"
        }
      }

      # Use the configManager to apply the differential configuration
      $deltaConfigPath = $this.operationContext.Results.DeltaConfigPath
      if (-not $deltaConfigPath -or -not (Test-Path $deltaConfigPath)) {
        throw "Delta configuration file not found or not created"
      }

      $this.logger.LogInfo("Applying $totalChanges changes to NSX Manager: $nsxManager", "DifferentialConfig")
      $this.logger.LogInfo("  - Create: $($differences.create.Count) objects", "DifferentialConfig")
      $this.logger.LogInfo("  - Update: $($differences.update.Count) objects", "DifferentialConfig")

      # DEBUGGING: Save actual payload before applying to NSX Manager
      $actualPayload = Get-Content $deltaConfigPath -Raw | ConvertFrom-Json
      $this.SaveActualPayload($actualPayload, $nsxManager, "pre_apply_payload")

      # DEBUGGING: Analyze and log payload contents
      $this.AnalyzePayloadContents($actualPayload)

      # Use configManager to apply the delta configuration
      $applyResult = $this.configManager.ApplyPolicyConfiguration($nsxManager, $credentials, $deltaConfigPath, $false)

      # Update operation context
      $this.operationContext.Results.ApplyResult = $applyResult

      if ($applyResult.success) {
        $this.logger.LogInfo("Differential configuration applied successfully", "DifferentialConfig")
        return @{
          success         = $true
          applied_objects = $totalChanges
          skipped_objects = 0
          failed_objects  = 0
          message         = "Configuration applied successfully"
        }
      }
      else {
        $this.logger.LogError("Failed to apply differential configuration: $($applyResult.error)", "DifferentialConfig")
        return @{
          success         = $false
          applied_objects = 0
          skipped_objects = 0
          failed_objects  = $totalChanges
          message         = $applyResult.error
        }
      }

    }
    catch {
      $this.logger.LogError("Failed to apply differential configuration: $($_.Exception.Message)", "DifferentialConfig")
      return @{
        success         = $false
        applied_objects = 0
        skipped_objects = 0
        failed_objects  = $totalChanges
        message         = $_.Exception.Message
      }
    }
  }

  # Filter system objects usingDataObjectFilterService
  hidden [object] FilterSystemObjects([object] $configuration) {
    try {
      if (-not $this.dataObjectFilter) {
        $this.logger.LogWarning("No system object filter available - returning configuration unfiltered", "DifferentialConfig")
        return $configuration
      }

      $this.logger.LogInfo("Filtering system objects from configuration", "DifferentialConfig")

      # Use DataObjectFilterService to filter the configuration
      $filteredConfig = $this.dataObjectFilter.FilterConfiguration($configuration)

      # Get filtering statistics
      $originalCount = $this.CountConfigurationObjects($configuration)
      $filteredCount = $this.CountConfigurationObjects($filteredConfig)
      $removedCount = $originalCount - $filteredCount

      $this.logger.LogInfo("System object filtering completed: $originalCount original, $filteredCount remaining, $removedCount filtered", "DifferentialConfig")

      return $filteredConfig
    }
    catch {
      $this.logger.LogError("Failed to filter system objects: $($_.Exception.Message)", "DifferentialConfig")
      $this.logger.LogWarning("Returning unfiltered configuration due to filtering error", "DifferentialConfig")
      return $configuration
    }
  }

  # Get filtering statistics and information
  hidden [object] GetSystemFilteringInfo([object] $configuration) {
    try {
      if (-not $this.dataObjectFilter) {
        return @{
          filtering_enabled = $false
          message           = "No system object filter available"
        }
      }

      $filterStats = $this.dataObjectFilter.GetFilteringStatistics($configuration)

      return @{
        filtering_enabled  = $true
        total_scanned      = $filterStats.TotalObjectsScanned
        filtered_count     = $filterStats.FilteredObjectsCount
        configuration_file = $filterStats.ConfigurationFile
        rule_groups        = $filterStats.FilteringRuleGroups
      }
    }
    catch {
      $this.logger.LogError("Failed to get filtering information: $($_.Exception.Message)", "DifferentialConfig")
      return @{
        filtering_enabled = $false
        error             = $_.Exception.Message
      }
    }
  }

  # Validate constructor signatures and service instantiation consistency (no-op, doc only)
  # All constructors use dependency injection and optional params for future extensibility.
  # CoreServiceFactory and all consumers should be checked for matching signatures.
  # No code change required here; see CoreServiceFactory.ps1 for instantiation logic.
}
