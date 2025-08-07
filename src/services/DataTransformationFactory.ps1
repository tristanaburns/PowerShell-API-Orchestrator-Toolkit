# DataTransformationFactory.ps1
# Factory for creating data transformation services and pipelines
# Simplified version using standard PowerShell object creation patterns

class DataTransformationFactory {
  hidden [object] $logger
  hidden [object] $serviceInstances
  hidden [object] $configuration
  hidden [string] $basePath

  # Constructor
  DataTransformationFactory([object] $loggingService, [object] $configuration, [string] $basePath) {
    $this.logger = $loggingService
    $this.configuration = $configuration
    $this.basePath = $basePath
    $this.serviceInstances = [PSCustomObject]@{}
    $this.logger.LogInfo("DataTransformationFactory initialised", "Factory")
  }

  # Create CSV Data Parsing Service
  [object] CreateCSVDataParsingService() {
    try {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $this.serviceInstances -Name "CSVDataParsingService" -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        return $this.serviceInstances.CSVDataParsingService
      }

      $this.logger.LogInfo("Creating CSV Data Parsing Service", "Factory")

      # Create service instance with minimal dependencies
      $service = New-Object PSObject -Property @{
        logger = $this.logger
        Parse  = {
          param($csvPath, $outputPath)
          # CSV parsing logic would go here
          return [PSCustomObject]@{ success = $true; message = "CSV parsed successfully" }
        }
      }

      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $this.serviceInstances | Add-Member -NotePropertyName "CSVDataParsingService" -NotePropertyValue $service -Force
      $this.logger.LogInfo("CSV Data Parsing Service created successfully", "Factory")
      return $service

    }
    catch {
      $this.logger.LogError("Failed to create CSV Data Parsing Service: $($_.Exception.Message)", "Factory")
      throw
    }
  }

  # Create NSX Hierarchical Structure Service
  [object] CreateNSXHierarchicalStructureService() {
    try {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $this.serviceInstances -Name "NSXHierarchicalStructureService" -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        return $this.serviceInstances.NSXHierarchicalStructureService
      }

      $this.logger.LogInfo("Creating NSX Hierarchical Structure Service", "Factory")

      # Create service instance with minimal dependencies
      $service = New-Object PSObject -Property @{
        logger          = $this.logger
        CreateHierarchy = {
          param($data)
          # Hierarchical structure logic would go here
          return [PSCustomObject]@{ success = $true; message = "Hierarchy created successfully" }
        }
      }

      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $this.serviceInstances | Add-Member -NotePropertyName "NSXHierarchicalStructureService" -NotePropertyValue $service -Force
      $this.logger.LogInfo("NSX Hierarchical Structure Service created successfully", "Factory")
      return $service

    }
    catch {
      $this.logger.LogError("Failed to create NSX Hierarchical Structure Service: $($_.Exception.Message)", "Factory")
      throw
    }
  }

  # Create NSX Config Manager (placeholder)
  [object] CreateNSXConfigManager() {
    try {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $this.serviceInstances -Name "NSXConfigManager" -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        return $this.serviceInstances.NSXConfigManager
      }

      $this.logger.LogInfo("Creating NSX Config Manager", "Factory")

      # Create service instance with minimal dependencies
      $service = New-Object PSObject -Property @{
        logger             = $this.logger
        GetConfiguration   = {
          param($nsxManager, $credential)
          # Configuration retrieval logic would go here
          return [PSCustomObject]@{ success = $true; message = "Configuration retrieved successfully" }
        }
        ApplyConfiguration = {
          param($nsxManager, $credential, $config)
          # Configuration application logic would go here
          return [PSCustomObject]@{ success = $true; message = "Configuration applied successfully" }
        }
      }

      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $this.serviceInstances | Add-Member -NotePropertyName "NSXConfigManager" -NotePropertyValue $service -Force
      $this.logger.LogInfo("NSX Config Manager created successfully", "Factory")
      return $service

    }
    catch {
      $this.logger.LogError("Failed to create NSX Config Manager: $($_.Exception.Message)", "Factory")
      throw
    }
  }

  # Create NSX Configuration Validator (placeholder)
  [object] CreateNSXConfigValidator() {
    try {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $this.serviceInstances -Name "NSXConfigValidator" -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        return $this.serviceInstances.NSXConfigValidator
      }

      $this.logger.LogInfo("Creating NSX Configuration Validator", "Factory")

      # Create service instance with minimal dependencies
      $service = New-Object PSObject -Property @{
        logger                = $this.logger
        ValidateConfiguration = {
          param($config)
          # Configuration validation logic would go here
          return [PSCustomObject]@{ success = $true; message = "Configuration validated successfully" }
        }
      }

      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $this.serviceInstances | Add-Member -NotePropertyName "NSXConfigValidator" -NotePropertyValue $service -Force
      $this.logger.LogInfo("NSX Configuration Validator created successfully", "Factory")
      return $service

    }
    catch {
      $this.logger.LogError("Failed to create NSX Configuration Validator: $($_.Exception.Message)", "Factory")
      throw
    }
  }

  # Create Data Transformation Pipeline
  [object] CreateDataTransformationPipeline() {
    try {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $this.serviceInstances -Name "DataTransformationPipeline" -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        return $this.serviceInstances.DataTransformationPipeline
      }

      $this.logger.LogInfo("Creating Data Transformation Pipeline", "Factory")

      # Create all required services
      $csvParser = $this.CreateCSVDataParsingService()
      $hierarchyService = $this.CreateNSXHierarchicalStructureService()
      $configManager = $this.CreateNSXConfigManager()
      $configValidator = $this.CreateNSXConfigValidator()

      # Create pipeline instance
      $pipeline = New-Object PSObject -Property @{
        logger           = $this.logger
        csvParser        = $csvParser
        hierarchyService = $hierarchyService
        configManager    = $configManager
        configValidator  = $configValidator
        ExecutePipeline  = {
          param($inputPath, $outputPath)
          # Pipeline execution logic would go here
          return [PSCustomObject]@{ success = $true; message = "Pipeline executed successfully" }
        }
      }

      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $this.serviceInstances | Add-Member -NotePropertyName "DataTransformationPipeline" -NotePropertyValue $pipeline -Force
      $this.logger.LogInfo("Data Transformation Pipeline created successfully", "Factory")
      return $pipeline

    }
    catch {
      $this.logger.LogError("Failed to create Data Transformation Pipeline: $($_.Exception.Message)", "Factory")
      throw
    }
  }

  # Create all services in one go
  [object] CreateAllServices() {
    try {
      $this.logger.LogInfo("Creating all data transformation services", "Factory")

      $services = [PSCustomObject]@{
        csvParser        = $this.CreateCSVDataParsingService()
        hierarchyService = $this.CreateNSXHierarchicalStructureService()
        configManager    = $this.CreateNSXConfigManager()
        configValidator  = $this.CreateNSXConfigValidator()
        pipeline         = $this.CreateDataTransformationPipeline()
      }

      $this.logger.LogInfo("All data transformation services created successfully", "Factory")
      return $services

    }
    catch {
      $this.logger.LogError("Failed to create all services: $($_.Exception.Message)", "Factory")
      throw
    }
  }

  # Helper method to resolve paths relative to base path
  hidden [string] ResolvePath([string] $relativePath) {
    if ([System.IO.Path]::IsPathRooted($relativePath)) {
      return $relativePath
    }

    $resolvedPath = Join-Path $this.basePath $relativePath
    if (-not (Test-Path $resolvedPath)) {
      New-Item -Path $resolvedPath -ItemType Directory -Force | Out-Null
      $this.logger.LogInfo("Created directory: $resolvedPath", "Factory")
    }

    return $resolvedPath
  }

  # Clean up resources
  [void] Dispose() {
    if ($this.serviceInstances.Count -gt 0) {
      $this.logger.LogInfo("Cleaning up service instances", "Factory")
      $this.serviceInstances.Clear()
    }
  }
}
