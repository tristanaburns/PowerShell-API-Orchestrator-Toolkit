# DataTransformationPipeline.ps1
# Orchestrates the complete data transformation pipeline:
# 1. CSV parsing and JSON conversion
# 2. NSX hierarchical structure wrapping
# 3. Configuration validation
# 4. Configuration application

class DataTransformationPipeline {
  hidden [object] $logger
  hidden [object] $csvParser
  hidden [object] $hierarchyService
  hidden [object] $configManager
  hidden [object] $configValidator
  hidden [string] $workingDirectory
  hidden [object] $pipelineConfig

  # Constructor with dependency injection
  DataTransformationPipeline(
    [object] $loggingService,
    [object] $csvParsingService,
    [object] $hierarchicalService,
    [object] $configurationManager,
    [object] $configurationValidator,
    [string] $workingDir = $null,
    [object] $pipelineConfig = $null
  ) {
    $this.logger = $loggingService
    $this.csvParser = $csvParsingService
    $this.hierarchyService = $hierarchicalService
    $this.configManager = $configurationManager
    $this.configValidator = $configurationValidator

    # Set working directory
    if ($workingDir) {
      $this.workingDirectory = $workingDir
    }
    else {
      $scriptRoot = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
      $this.workingDirectory = Join-Path $scriptRoot "data\pipeline"
    }

    # Ensure working directory exists
    if (-not (Test-Path $this.workingDirectory)) {
      New-Item -Path $this.workingDirectory -ItemType Directory -Force | Out-Null
    }

    # initialise pipeline configuration
    if ($pipelineConfig) {
      $this.pipelineConfig = $pipelineConfig
    }
    else {
      $this.initialisePipelineConfig()
    }

    $this.logger.LogInfo("DataTransformationPipeline initialised", "Pipeline")
  }

  # initialise pipeline configuration
  [void] initialisePipelineConfig() {
    $this.pipelineConfig = @{
      # Processing order for resource types
      processing_order = @(
        "Tag",
        "VMTag",
        "Service",
        "ContextProfile",
        "Segment",
        "Group",
        "SecurityPolicy",
        "Rule"
      )

      # Validation settings
      validation       = @{
        validate_json_structure   = $true
        validate_nsx_schema       = $true
        validate_dependencies     = $true
        stop_on_validation_errors = $true
      }

      # Output settings
      output           = @{
        save_intermediate_files = $true
        save_final_config       = $true
        create_backup           = $true
        timestamp_files         = $true
      }

      # Processing settings
      processing       = @{
        default_domain      = "default"
        batch_size          = 100
        parallel_processing = $false
        error_handling      = "continue"  # continue, stop, retry
      }
    }
  }

  # Execute the complete transformation pipeline
  [object] ExecutePipeline([object] $options = [PSCustomObject]@{}) {
    try {
      $this.logger.LogStep("Starting Data Transformation Pipeline")

      # Merge options with default config
      $config = $this.MergeConfiguration($options)

      # initialise pipeline results
      $pipelineResults = [PSCustomObject]@{
        start_time   = Get-Date
        end_time     = $null
        success      = $false
        steps        = @()
        errors       = @()
        warnings     = @()
        output_files = @()
        statistics   = [PSCustomObject]@{}
      }

      # Step 1: Parse CSV files
      $this.logger.LogStep("Step 1: Parse CSV Files")
      $csvResults = $this.ExecuteCSVParsing($config)
      $pipelineResults.steps += @{
        step    = "csv_parsing"
        success = $csvResults.success
        results = $csvResults
      }

      if (-not $csvResults.success) {
        $pipelineResults.errors += "CSV parsing failed"
        if ($config.processing.error_handling -eq "stop") {
          return $pipelineResults
        }
      }

      # Step 2: Create hierarchical structure
      $this.logger.LogStep("Step 2: Create Hierarchical Structure")
      $hierarchyResults = $this.ExecuteHierarchicalStructuring($csvResults, $config)
      $pipelineResults.steps += @{
        step    = "hierarchical_structuring"
        success = $hierarchyResults.success
        results = $hierarchyResults
      }

      if (-not $hierarchyResults.success) {
        $pipelineResults.errors += "Hierarchical structuring failed"
        if ($config.processing.error_handling -eq "stop") {
          return $pipelineResults
        }
      }

      # Step 3: Validate configuration
      $this.logger.LogStep("Step 3: Validate Configuration")
      $validationResults = $this.ExecuteConfigurationValidation($hierarchyResults, $config)
      $pipelineResults.steps += @{
        step    = "configuration_validation"
        success = $validationResults.success
        results = $validationResults
      }

      if (-not $validationResults.success) {
        $pipelineResults.errors += "Configuration validation failed"
        if ($config.validation.stop_on_validation_errors) {
          return $pipelineResults
        }
      }

      # Step 4: Prepare final configuration
      $this.logger.LogStep("Step 4: Prepare Final Configuration")
      $finalConfigResults = $this.PrepareFinalConfiguration($hierarchyResults, $validationResults, $config)
      $pipelineResults.steps += @{
        step    = "final_configuration"
        success = $finalConfigResults.success
        results = $finalConfigResults
      }

      # Step 5: Generate statistics and summary
      $this.logger.LogStep("Step 5: Generate Pipeline Statistics")
      $pipelineResults.statistics = $this.GeneratePipelineStatistics($pipelineResults)

      # Mark pipeline as successful if all critical steps completed
      $pipelineResults.success = $csvResults.success -and $hierarchyResults.success -and $finalConfigResults.success
      $pipelineResults.end_time = Get-Date

      # Save pipeline results
      $resultsFile = $this.SavePipelineResults($pipelineResults, $config)
      $pipelineResults.output_files += $resultsFile

      $this.logger.LogInfo("Data Transformation Pipeline completed successfully", "Pipeline")
      return $pipelineResults

    }
    catch {
      $this.logger.LogError("Data Transformation Pipeline failed: $($_.Exception.Message)", "Pipeline")
      return @{
        success    = $false
        error      = $_.Exception.Message
        start_time = Get-Date
        end_time   = Get-Date
      }
    }
  }

  # Execute CSV parsing step
  [object] ExecuteCSVParsing([object] $config) {
    try {
      $this.logger.LogInfo("Executing CSV parsing step", "Pipeline")

      # Get processing order
      $processingOrder = $config.processing_order

      # Process CSV files based on resource type priority
      $allResults = @()

      foreach ($resourceType in $processingOrder) {
        # Find corresponding CSV file
        $csvFile = $this.FindCSVFileForResourceType($resourceType)

        if ($csvFile) {
          $this.logger.LogInfo("Processing CSV file for $resourceType : $csvFile", "Pipeline")

          # Parse specific CSV file
          $result = $this.csvParser.ProcessSpecificCSVFile($csvFile)
          if ($result.success) {
            $allResults += $result
            $this.logger.LogInfo("Successfully parsed $($result.object_count) $resourceType objects", "Pipeline")
          }
          else {
            $this.logger.LogWarning("Failed to parse CSV file: $csvFile", "Pipeline")
          }
        }
        else {
          $this.logger.LogInfo("No CSV file found for resource type: $resourceType", "Pipeline")
        }
      }

      # Also process any remaining CSV files not in the processing order
      $remainingFiles = $this.GetRemainingCSVFiles($processingOrder)
      foreach ($csvFile in $remainingFiles) {
        $this.logger.LogInfo("Processing remaining CSV file: $csvFile", "Pipeline")
        $result = $this.csvParser.ProcessSpecificCSVFile($csvFile)
        if ($result.success) {
          $allResults += $result
        }
      }

      return @{
        success          = $allResults.Count -gt 0
        parsed_files     = $allResults
        total_files      = $allResults.Count
        successful_files = ($allResults | Where-Object { $_.success }).Count
        failed_files     = ($allResults | Where-Object { -not $_.success }).Count
      }

    }
    catch {
      $this.logger.LogError("CSV parsing step failed: $($_.Exception.Message)", "Pipeline")
      return @{
        success      = $false
        error        = $_.Exception.Message
        parsed_files = @()
      }
    }
  }

  # Execute hierarchical structuring step
  [object] ExecuteHierarchicalStructuring([object] $csvResults, [object] $config) {
    try {
      $this.logger.LogInfo("Executing hierarchical structuring step", "Pipeline")

      if (-not $csvResults.success -or $csvResults.parsed_files.Count -eq 0) {
        return @{
          success = $false
          error   = "No parsed CSV files available for hierarchical structuring"
        }
      }

      # Create hierarchical structure from parsed files
      $domain = $config.processing.default_domain
      $hierarchicalStructure = $this.hierarchyService.CreateStructureFromParsedFiles($csvResults.parsed_files, $domain)

      if (-not $hierarchicalStructure) {
        return @{
          success = $false
          error   = "Failed to create hierarchical structure"
        }
      }

      # Validate the hierarchical structure
      $structureValidation = $this.hierarchyService.ValidateHierarchicalStructure($hierarchicalStructure)

      # Save hierarchical structure if configured
      $hierarchicalFile = $null
      if ($config.output.save_intermediate_files) {
        $hierarchicalFile = $this.hierarchyService.SaveHierarchicalStructure($hierarchicalStructure)
      }

      return @{
        success                = $true
        hierarchical_structure = $hierarchicalStructure
        validation             = $structureValidation
        output_file            = $hierarchicalFile
        domain                 = $domain
      }

    }
    catch {
      $this.logger.LogError("Hierarchical structuring step failed: $($_.Exception.Message)", "Pipeline")
      return @{
        success = $false
        error   = $_.Exception.Message
      }
    }
  }

  # Execute configuration validation step
  [object] ExecuteConfigurationValidation([object] $hierarchyResults, [object] $config) {
    try {
      $this.logger.LogInfo("Executing configuration validation step", "Pipeline")

      if (-not $hierarchyResults.success) {
        return @{
          success = $false
          error   = "No hierarchical structure available for validation"
        }
      }

      $validationResults = [PSCustomObject]@{
        json_structure = [PSCustomObject]@{ valid = $true; errors = @(); warnings = @() }
        nsx_schema     = [PSCustomObject]@{ valid = $true; errors = @(); warnings = @() }
        dependencies   = [PSCustomObject]@{ valid = $true; errors = @(); warnings = @() }
        overall_valid  = $true
      }

      # Validate JSON structure
      if ($config.validation.validate_json_structure) {
        $jsonString = $hierarchyResults.hierarchical_structure | ConvertTo-Json -Depth 20
        $validationResults.json_structure = $this.configValidator.ValidateJSONStructure($jsonString)

        if (-not $validationResults.json_structure.valid) {
          $validationResults.overall_valid = $false
          $this.logger.LogWarning("JSON structure validation failed", "Pipeline")
        }
      }

      # Validate NSX schema
      if ($config.validation.validate_nsx_schema) {
        $validationResults.nsx_schema = $this.configValidator.ValidateConfiguration($hierarchyResults.hierarchical_structure)

        if (-not $validationResults.nsx_schema.valid) {
          $validationResults.overall_valid = $false
          $this.logger.LogWarning("NSX schema validation failed", "Pipeline")
        }
      }

      # Validate dependencies
      if ($config.validation.validate_dependencies) {
        $validationResults.dependencies = $this.ValidateDependencies($hierarchyResults.hierarchical_structure)

        if (-not $validationResults.dependencies.valid) {
          $validationResults.overall_valid = $false
          $this.logger.LogWarning("Dependency validation failed", "Pipeline")
        }
      }

      return @{
        success            = $true
        validation_results = $validationResults
        overall_valid      = $validationResults.overall_valid
      }

    }
    catch {
      $this.logger.LogError("Configuration validation step failed: $($_.Exception.Message)", "Pipeline")
      return @{
        success            = $false
        error              = $_.Exception.Message
        validation_results = [PSCustomObject]@{ overall_valid = $false }
      }
    }
  }

  # Prepare final configuration
  [object] PrepareFinalConfiguration([object] $hierarchyResults, [object] $validationResults, [object] $config) {
    try {
      $this.logger.LogInfo("Preparing final configuration", "Pipeline")

      if (-not $hierarchyResults.success) {
        return @{
          success = $false
          error   = "No hierarchical structure available for final configuration"
        }
      }

      # Get the hierarchical structure
      $finalConfig = $hierarchyResults.hierarchical_structure

      # Add metadata
      $finalConfig.metadata = @{
        created_by        = "DataTransformationPipeline"
        created_at        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        domain            = $hierarchyResults.domain
        validation_status = $validationResults.overall_valid
        source            = "CSV_Import"
        pipeline_version  = "1.0"
      }

      # Save final configuration
      $finalConfigFile = $null
      if ($config.output.save_final_config) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $fileName = "final_nsx_config_$timestamp.json"
        $finalConfigFile = $this.SaveFinalConfiguration($finalConfig, $fileName)
      }

      return @{
        success             = $true
        final_configuration = $finalConfig
        output_file         = $finalConfigFile
        validation_passed   = $validationResults.overall_valid
      }

    }
    catch {
      $this.logger.LogError("Failed to prepare final configuration: $($_.Exception.Message)", "Pipeline")
      return @{
        success = $false
        error   = $_.Exception.Message
      }
    }
  }

  # Apply configuration to NSX Manager
  [object] ApplyConfiguration([string] $nsxManager, [object] $credential, [object] $finalConfig, [object] $options = [PSCustomObject]@{}) {
    try {
      $this.logger.LogStep("Applying configuration to NSX Manager: $nsxManager")

      # Use ConfigManager to apply configuration
      $applyResults = $this.configManager.ApplyConfiguration($finalConfig, $nsxManager, $credential, $options)

      return $applyResults

    }
    catch {
      $this.logger.LogError("Failed to apply configuration: $($_.Exception.Message)", "Pipeline")
      return @{
        success = $false
        error   = $_.Exception.Message
      }
    }
  }

  # Helper methods
  [string] FindCSVFileForResourceType([string] $resourceType) {
    # Map resource types to CSV file patterns
    $csvMappings = [PSCustomObject]@{
      "Group"          = "Groups.csv"
      "Service"        = "L4CustomServices.csv"
      "SecurityPolicy" = "SecurityPolicies.csv"
      "Rule"           = "FirewallRules.csv"
      "ContextProfile" = "ContextProfiles.csv"
      "Segment"        = "Segments.csv"
      "VMTag"          = "VM_Tags.csv"
      "Tag"            = "Tags.csv"
    }

    return $csvMappings[$resourceType]
  }

  [array] GetRemainingCSVFiles([array] $processedOrder) {
    $allFiles = $this.csvParser.GetAvailableCSVFiles()
    $processed = @()

    foreach ($resourceType in $processedOrder) {
      $csvFile = $this.FindCSVFileForResourceType($resourceType)
      if ($csvFile) {
        $processed += $csvFile
      }
    }

    return $allFiles | Where-Object { $_.Name -notin $processed }
  }

  [object] MergeConfiguration([object] $options) {
    $config = $this.pipelineConfig.Clone()

    # Merge options into config
    # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
    $optionNames = ($options | Get-Member -MemberType NoteProperty).Name
    foreach ($key in $optionNames) {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $config -Name $key -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        # CANONICAL FIX: Replace hash table indexing with PSCustomObject property access
        if ($config.$key -is [object] -and $options.$key -is [object]) {
          # Merge nested hashtables
          # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
          $subOptionNames = ($options.$key | Get-Member -MemberType NoteProperty).Name
          foreach ($subKey in $subOptionNames) {
            # CANONICAL FIX: Replace hash table indexing with PSCustomObject property modification
            $config.$key | Add-Member -NotePropertyName $subKey -NotePropertyValue $options.$key.$subKey -Force
          }
        }
        else {
          # CANONICAL FIX: Replace hash table indexing with PSCustomObject property modification
          $config | Add-Member -NotePropertyName $key -NotePropertyValue $options.$key -Force
        }
      }
      else {
        # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
        $config | Add-Member -NotePropertyName $key -NotePropertyValue $options.$key -Force
      }
    }

    return $config
  }

  [object] ValidateDependencies([object] $structure) {
    # Implement dependency validation logic
    $errors = @()
    $warnings = @()

    # Check for common dependency issues
    # (This is a simplified example - expand based on NSX requirements)

    return @{
      valid    = $errors.Count -eq 0
      errors   = $errors
      warnings = $warnings
    }
  }

  [object] GeneratePipelineStatistics([object] $pipelineResults) {
    $duration = $pipelineResults.end_time - $pipelineResults.start_time

    # Calculate statistics from results
    $csvStats = $pipelineResults.steps | Where-Object { $_.step -eq "csv_parsing" } | Select-Object -First 1
    $hierarchyStats = $pipelineResults.steps | Where-Object { $_.step -eq "hierarchical_structuring" } | Select-Object -First 1

    return @{
      total_duration                 = $duration.TotalSeconds
      csv_files_processed            = if ($csvStats) { $csvStats.results.total_files } else { 0 }
      csv_files_successful           = if ($csvStats) { $csvStats.results.successful_files } else { 0 }
      hierarchical_structure_created = if ($hierarchyStats) { $hierarchyStats.success } else { $false }
      total_errors                   = $pipelineResults.errors.Count
      total_warnings                 = $pipelineResults.warnings.Count
      output_files_created           = $pipelineResults.output_files.Count
    }
  }

  [string] SavePipelineResults([object] $results, [object] $config) {
    try {
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $fileName = "pipeline_results_$timestamp.json"
      $filePath = Join-Path $this.workingDirectory $fileName

      # Convert results to JSON and save
      $jsonString = $results | ConvertTo-Json -Depth 10 -Compress:$false
      $jsonString | Out-File -FilePath $filePath -Encoding UTF8

      $this.logger.LogInfo("Saved pipeline results to: $filePath", "Pipeline")
      return $filePath

    }
    catch {
      $this.logger.LogError("Failed to save pipeline results: $($_.Exception.Message)", "Pipeline")
      return $null
    }
  }

  [string] SaveFinalConfiguration([object] $config, [string] $fileName) {
    try {
      $filePath = Join-Path $this.workingDirectory $fileName

      # Convert to JSON and save
      $jsonString = $config | ConvertTo-Json -Depth 20 -Compress:$false
      $jsonString | Out-File -FilePath $filePath -Encoding UTF8

      $this.logger.LogInfo("Saved final configuration to: $filePath", "Pipeline")
      return $filePath

    }
    catch {
      $this.logger.LogError("Failed to save final configuration: $($_.Exception.Message)", "Pipeline")
      throw
    }
  }

  # Get pipeline configuration
  [object] GetPipelineConfig() {
    return $this.pipelineConfig
  }

  # Update pipeline configuration
  [void] UpdatePipelineConfig([object] $newConfig) {
    $this.pipelineConfig = $this.MergeConfiguration($newConfig)
  }

  # Get pipeline status
  [object] GetPipelineStatus() {
    return @{
      working_directory       = $this.workingDirectory
      csv_parser_ready        = $this.csvParser -ne $null
      hierarchy_service_ready = $this.hierarchyService -ne $null
      config_manager_ready    = $this.configManager -ne $null
      config_validator_ready  = $this.configValidator -ne $null
      pipeline_config         = $this.pipelineConfig
    }
  }
}
