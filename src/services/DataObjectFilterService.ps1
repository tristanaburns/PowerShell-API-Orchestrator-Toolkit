#DataObjectFilterService.ps1
# Configuration-driven service for filtering system objects from NSX configurations
# Following SOLID principles for NSX configuration management
# Property-level inclusion/exclusion filtering with multi-step nested processing

class DataObjectFilterService {
  hidden [object] $logger
  hidden [object] $filterConfig
  hidden [string] $configFilePath

  # Property-level filtering configuration paths
  hidden [string] $propertyInclusionsConfigPath
  hidden [string] $propertyExclusionsConfigPath
  hidden [string] $multiStepFilteringConfigPath
  hidden [object] $propertyInclusionsConfig
  hidden [object] $propertyExclusionsConfig
  hidden [object] $multiStepFilteringConfig

  # Default parameterless constructor
  DataObjectFilterService() {
    $this.logger = $null
    $this.configFilePath = "$PSScriptRoot\..\..\config\data-objects-filter.json"

    # Initialize property-level filtering configuration paths
    $this.InitializePropertyFilteringPaths()

    # Load configuration from JSON file
    $this.LoadFilterConfiguration()

    # Load property-level filtering configurations
    $this.LoadPropertyFilteringConfigurations()
  }

  # Constructor with dependency injection (JSON file-based)
  DataObjectFilterService([object] $loggingService) {
    $this.logger = $loggingService
    $this.configFilePath = "$PSScriptRoot\..\..\config\data-objects-filter.json"

    # Initialize property-level filtering configuration paths
    $this.InitializePropertyFilteringPaths()

    # Load configuration from JSON file
    $this.LoadFilterConfiguration()

    # Load property-level filtering configurations
    $this.LoadPropertyFilteringConfigurations()

    if ($this.logger) {
      $this.logger.LogInfo("DataObjectFilterService initialized with JSON configuration and property-level filtering", "DataObjectFilter")
    }
  }

  # Constructor with direct configuration object
  DataObjectFilterService([object] $loggingService, [object] $filterConfigObject) {
    $this.logger = $loggingService
    $this.configFilePath = $null  # No file path when using direct config

    # Initialize property-level filtering configuration paths
    $this.InitializePropertyFilteringPaths()

    # Use provided configuration object
    $this.filterConfig = $filterConfigObject
    $this.ValidateFilterConfiguration()

    # Load property-level filtering configurations from default paths
    $this.LoadPropertyFilteringConfigurations()

    if ($this.logger) {
      $this.logger.LogInfo("DataObjectFilterService initialized with direct configuration object and property-level filtering", "DataObjectFilter")
    }
  }

  # Constructor with JSON file path and optional runtime config
  DataObjectFilterService([object] $loggingService, [string] $customConfigPath, [object] $runtimeConfig = $null) {
    $this.logger = $loggingService
    $this.configFilePath = $customConfigPath

    # Initialize property-level filtering configuration paths
    $this.InitializePropertyFilteringPaths()

    # Load configuration from custom JSON file
    $this.LoadFilterConfiguration()

    # Merge with runtime configuration if provided
    if ($runtimeConfig) {
      $this.MergeFilterConfiguration($runtimeConfig)
    }

    # Load property-level filtering configurations
    $this.LoadPropertyFilteringConfigurations()

    if ($this.logger) {
      $this.logger.LogInfo("DataObjectFilterService initialized with custom path, runtime config, and property-level filtering", "DataObjectFilter")
    }
  }

  # Constructor with full property-level filtering configuration
  DataObjectFilterService([object] $loggingService, [string] $customConfigPath, [string] $propertyInclusionsPath, [string] $propertyExclusionsPath, [string] $multiStepFilteringPath) {
    $this.logger = $loggingService
    $this.configFilePath = $customConfigPath
    $this.propertyInclusionsConfigPath = $propertyInclusionsPath
    $this.propertyExclusionsConfigPath = $propertyExclusionsPath
    $this.multiStepFilteringConfigPath = $multiStepFilteringPath

    # Load all configurations
    $this.LoadFilterConfiguration()
    $this.LoadPropertyFilteringConfigurations()

    if ($this.logger) {
      $this.logger.LogInfo("DataObjectFilterService initialized with full property-level filtering configuration", "DataObjectFilter")
    }
  }

  # Initialize property-level filtering configuration paths
  hidden [void] InitializePropertyFilteringPaths() {
    $configDir = "$PSScriptRoot\..\..\config"
    $this.propertyInclusionsConfigPath = "$configDir\property-inclusions-schema.json"
    $this.propertyExclusionsConfigPath = "$configDir\property-exclusions-schema.json"
    $this.multiStepFilteringConfigPath = "$configDir\multi-step-filtering-schema.json"
  }

  # Load property-level filtering configurations
  hidden [void] LoadPropertyFilteringConfigurations() {
    # Load property inclusions configuration
    try {
      if (Test-Path $this.propertyInclusionsConfigPath) {
        $jsonContent = Get-Content -Path $this.propertyInclusionsConfigPath -Raw | ConvertFrom-Json
        $this.propertyInclusionsConfig = $this.ConvertPSObjectToHashtable($jsonContent)

        if ($this.logger) {
          $this.logger.LogDebug("Loaded property inclusions configuration", "DataObjectFilter")
        }
      }
      else {
        $this.propertyInclusionsConfig = $this.GetDefaultPropertyInclusionsConfig()
        if ($this.logger) {
          $this.logger.LogWarning("Property inclusions config not found, using defaults", "DataObjectFilter")
        }
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load property inclusions config: $($_.Exception.Message)", "DataObjectFilter")
      }
      $this.propertyInclusionsConfig = $this.GetDefaultPropertyInclusionsConfig()
    }

    # Load property exclusions configuration
    try {
      if (Test-Path $this.propertyExclusionsConfigPath) {
        $jsonContent = Get-Content -Path $this.propertyExclusionsConfigPath -Raw | ConvertFrom-Json
        $this.propertyExclusionsConfig = $this.ConvertPSObjectToHashtable($jsonContent)

        if ($this.logger) {
          $this.logger.LogDebug("Loaded property exclusions configuration", "DataObjectFilter")
        }
      }
      else {
        $this.propertyExclusionsConfig = $this.GetDefaultPropertyExclusionsConfig()
        if ($this.logger) {
          $this.logger.LogWarning("Property exclusions config not found, using defaults", "DataObjectFilter")
        }
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load property exclusions config: $($_.Exception.Message)", "DataObjectFilter")
      }
      $this.propertyExclusionsConfig = $this.GetDefaultPropertyExclusionsConfig()
    }

    # Load multi-step filtering configuration
    try {
      if (Test-Path $this.multiStepFilteringConfigPath) {
        $jsonContent = Get-Content -Path $this.multiStepFilteringConfigPath -Raw | ConvertFrom-Json
        $this.multiStepFilteringConfig = $this.ConvertPSObjectToHashtable($jsonContent)

        if ($this.logger) {
          $this.logger.LogDebug("Loaded multi-step filtering configuration", "DataObjectFilter")
        }
      }
      else {
        $this.multiStepFilteringConfig = $this.GetDefaultMultiStepFilteringConfig()
        if ($this.logger) {
          $this.logger.LogWarning("Multi-step filtering config not found, using defaults", "DataObjectFilter")
        }
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load multi-step filtering config: $($_.Exception.Message)", "DataObjectFilter")
      }
      $this.multiStepFilteringConfig = $this.GetDefaultMultiStepFilteringConfig()
    }
  }

  # Get default property inclusions configuration
  hidden [object] GetDefaultPropertyInclusionsConfig() {
    return @{
      property_inclusions = @{
        description          = "Default property inclusions for NSX configuration verification"
        enabled              = $true
        processing_mode      = "parallel"
        default_include_mode = "whitelist"
        rules                = @(
          @{
            rule_id                 = "basic_identifiers"
            property_path           = "display_name"
            match_type              = "exact"
            required                = $true
            nested_levels           = -1
            applies_to_object_types = @("*")
          },
          @{
            rule_id                 = "object_typing"
            property_path           = "type"
            match_type              = "exact"
            required                = $true
            nested_levels           = 0
            applies_to_object_types = @("*")
          }
        )
        global_settings      = @{
          case_sensitive          = $false
          preserve_property_order = $true
          include_null_values     = $false
          include_empty_arrays    = $false
          max_property_depth      = 10
        }
      }
    }
  }

  # Get default property exclusions configuration
  hidden [object] GetDefaultPropertyExclusionsConfig() {
    return @{
      property_exclusions = @{
        description          = "Default property exclusions for configuration verification"
        enabled              = $true
        processing_mode      = "parallel"
        default_exclude_mode = "blacklist"
        rules                = @(
          @{
            rule_id                 = "system_timestamps"
            property_path           = "_*_time"
            match_type              = "wildcard"
            nested_levels           = -1
            applies_to_object_types = @("*")
          },
          @{
            rule_id                 = "system_users"
            property_path           = "_*_user"
            match_type              = "wildcard"
            nested_levels           = -1
            applies_to_object_types = @("*")
          },
          @{
            rule_id                 = "system_ownership"
            property_path           = "_system_owned"
            match_type              = "exact"
            value                   = $true
            nested_levels           = -1
            applies_to_object_types = @("*")
          }
        )
        global_settings      = @{
          case_sensitive                 = $false
          preserve_property_order        = $true
          exclude_null_values            = $true
          exclude_empty_arrays           = $false
          exclude_empty_objects          = $false
          max_property_depth             = 10
          system_property_auto_exclusion = $true
        }
      }
    }
  }

  # Get default multi-step filtering configuration
  hidden [object] GetDefaultMultiStepFilteringConfig() {
    return @{
      multi_step_filtering = @{
        description       = "Default multi-step filtering for configuration processing"
        enabled           = $true
        max_nesting_depth = 5
        processing_mode   = "serial"
        failure_handling  = "continue"
        step_definitions  = @(
          @{
            step_id             = "root_level_exclusions"
            step_order          = 1
            target_level        = 0
            execution_order     = "exclusions_first"
            property_exclusions = @{
              enabled = $true
              rules   = @(
                @{
                  property_path           = "_*_time"
                  match_type              = "wildcard"
                  applies_to_object_types = @("*")
                }
              )
            }
          },
          @{
            step_id             = "nested_level_inclusions"
            step_order          = 2
            target_level        = 1
            execution_order     = "inclusions_first"
            property_inclusions = @{
              enabled = $true
              rules   = @(
                @{
                  property_path           = "display_name"
                  match_type              = "exact"
                  applies_to_object_types = @("*")
                }
              )
            }
          }
        )
      }
    }
  }

  # Load filter configuration from JSON file
  hidden [void] LoadFilterConfiguration() {
    try {
      if (Test-Path $this.configFilePath) {
        $jsonContent = Get-Content -Path $this.configFilePath -Raw | ConvertFrom-Json
        $this.filterConfig = $this.ConvertPSObjectToHashtable($jsonContent)

        if ($this.logger) {
          $ruleCount = $this.filterConfig.filter_rules.Count
          $this.logger.LogInfo("Loaded filter configuration with $ruleCount rule groups", "DataObjectFilter")
        }
      }
      else {
        if ($this.logger) {
          $this.logger.LogWarning("Filter configuration file not found: $($this.configFilePath)", "DataObjectFilter")
        }
        $this.filterConfig = [PSCustomObject]@{
          filter_rules  = [PSCustomObject]@{}
          configuration = [PSCustomObject]@{
            default_action = "exclude_matched"
            enable_logging = $true
          }
        }
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load filter configuration: $($_.Exception.Message)", "DataObjectFilter")
      }
      # Fall back to empty configuration
      $this.filterConfig = [PSCustomObject]@{
        filter_rules  = [PSCustomObject]@{}
        configuration = [PSCustomObject]@{
          default_action = "exclude_matched"
          enable_logging = $true
        }
      }
    }
  }

  # Validate filter configuration structure
  hidden [void] ValidateFilterConfiguration() {
    if (-not $this.filterConfig) {
      throw "Filter configuration is null"
    }

    # Ensure required structure exists
    if (-not $this.filterConfig.filter_rules) {
      $this.filterConfig | Add-Member -NotePropertyName "filter_rules" -NotePropertyValue ([PSCustomObject]@{})
    }

    if (-not $this.filterConfig.configuration) {
      $this.filterConfig | Add-Member -NotePropertyName "configuration" -NotePropertyValue ([PSCustomObject]@{
          version        = "1.0"
          enable_logging = $true
          case_sensitive = $false
          default_action = "exclude_matched"
        })
    }

    if (-not $this.filterConfig.metadata) {
      $this.filterConfig | Add-Member -NotePropertyName "metadata" -NotePropertyValue ([PSCustomObject]@{
          created_by = "DataObjectFilterService"
          created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        })
    }

    # Validate each rule group
    foreach ($ruleGroupName in $this.filterConfig.filter_rules.Keys) {
      $ruleGroup = $this.filterConfig.filter_rules[$ruleGroupName]

      if (-not $ruleGroup.rules) {
        $ruleGroup.rules = @()
      }

      if ($null -eq $ruleGroup.enabled) {
        $ruleGroup.enabled = $true
      }

      if (-not $ruleGroup.description) {
        $ruleGroup.description = "Filter rule group: $ruleGroupName"
      }
    }

    if ($this.logger) {
      $this.logger.LogDebug("Filter configuration validated successfully", "DataObjectFilter")
    }
  }

  # PROTOCOL COMPLIANT: Use SharedToolUtilityService for object normalization
  hidden [object] ConvertPSObjectToHashtable([object] $obj) {
    # MANDATORY PROTOCOL: Use shared utility service for PSObject normalization
    # This eliminates code duplication and ensures protocol compliance
    if ($this.sharedUtility) {
      return $this.sharedUtility.NormalizePSObject($obj)
    }
    else {
      # Fallback for compatibility - returns PSObject not hashtable
      if ($obj -is [PSCustomObject]) {
        $normalizedObject = [PSCustomObject]@{}
        foreach ($property in $obj.PSObject.Properties) {
          if ($property.Value -is [PSCustomObject] -or $property.Value -is [Array]) {
            $normalizedObject | Add-Member -NotePropertyName $property.Name -NotePropertyValue ($this.ConvertPSObjectToHashtable($property.Value))
          }
          else {
            $normalizedObject | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value
          }
        }
        return $normalizedObject
      }
      elseif ($obj -is [Array]) {
        return @($obj | ForEach-Object { $this.ConvertPSObjectToHashtable($_) })
      }
      else {
        return $obj
      }
    }
  }

  # Filter configuration to remove system objects
  [object] FilterConfiguration([object] $configuration) {
    if ($this.logger) {
      $this.logger.LogInfo("Filtering objects from configuration using JSON rules", "DataObjectFilter")
    }

    $filteredConfig = $configuration.Clone()

    if ($configuration.children -and $configuration.children.Count -gt 0) {
      $filteredChildren = @()

      foreach ($child in $configuration.children) {
        if ($this.ShouldFilterObject($child)) {
          if ($this.logger -and $this.filterConfig.configuration.enable_logging) {
            $this.logger.LogDebug("Filtered out object: $($child.resource_type) - $($child.display_name)", "DataObjectFilter")
          }
          continue
        }

        # Recursively filter child objects
        if ($child.children -and $child.children.Count -gt 0) {
          $child.children = $this.FilterChildren($child.children)
        }

        $filteredChildren += $child
      }

      $filteredConfig.children = $filteredChildren
    }

    $originalCount = if ($configuration.children) { $configuration.children.Count } else { 0 }
    $filteredCount = $filteredConfig.children.Count
    $removedCount = $originalCount - $filteredCount

    if ($this.logger) {
      $this.logger.LogInfo("Configuration filtering completed: $originalCount original, $filteredCount remaining, $removedCount filtered", "DataObjectFilter")
    }

    return $filteredConfig
  }

  # Filter children array recursively
  hidden [array] FilterChildren([array] $children) {
    $filteredChildren = @()

    foreach ($child in $children) {
      if ($this.ShouldFilterObject($child)) {
        if ($this.logger -and $this.filterConfig.configuration.enable_logging) {
          $this.logger.LogDebug("Filtered out child object: $($child.resource_type) - $($child.display_name)", "DataObjectFilter")
        }
        continue
      }

      # Recursively filter nested children
      if ($child.children -and $child.children.Count -gt 0) {
        $child.children = $this.FilterChildren($child.children)
      }

      $filteredChildren += $child
    }

    return $filteredChildren
  }

  # Main filtering logic - determines if an object should be filtered
  hidden [bool] ShouldFilterObject([object] $object) {
    if (-not $object) {
      return $false
    }

    # Process each rule group
    foreach ($ruleGroupName in $this.filterConfig.filter_rules.Keys) {
      $ruleGroup = $this.filterConfig.filter_rules[$ruleGroupName]

      # Skip disabled rule groups
      if ($ruleGroup.enabled -eq $false) {
        continue
      }

      # Get the target object to check (support for nested objects)
      $targetObject = $object
      if ($ruleGroup.target_path) {
        $targetObject = $object[$ruleGroup.target_path]
        if (-not $targetObject) {
          continue
        }
      }

      # Check if any rule in this group matches
      foreach ($rule in $ruleGroup.rules) {
        $ruleMatched = $false

        # Handle parent resource type checks for nested objects
        if ($rule.parent_resource_type -and $ruleGroup.target_path) {
          # Check if parent object has the required resource type
          if ($object["resource_type"] -eq $rule.parent_resource_type) {
            $ruleMatched = $this.EvaluateRule($targetObject, $rule)
          }
        }
        else {
          $ruleMatched = $this.EvaluateRule($targetObject, $rule)
        }

        if ($ruleMatched) {
          if ($this.logger -and $this.filterConfig.configuration.enable_logging) {
            $this.logger.LogDebug("Object matched filter rule: $ruleGroupName - $($rule.property) $($rule.match_type) $($rule.value)", "DataObjectFilter")
          }
          return $true
        }
      }
    }

    return $false
  }

  # Evaluate a single filter rule against an object
  hidden [bool] EvaluateRule([object] $object, [object] $rule) {
    if (-not $object -or -not $rule) {
      return $false
    }

    # Special handling for parent resource type checks
    if ($rule.parent_resource_type) {
      # This handles nested object filtering (e.g., Service within ChildService)
      # The object passed here is the nested object (e.g., Service), we need to check the parent
      # This requires parent context to be passed, but for now we'll handle this in ShouldFilterObject
      # For now, just do the normal property check
    }

    $propertyValue = $object[$rule.property]
    if ($null -eq $propertyValue) {
      return $false
    }

    $ruleValue = $rule.value
    $caseSensitive = $this.filterConfig.configuration.case_sensitive -eq $true

    # Main property evaluation
    $mainMatch = $false
    switch ($rule.match_type) {
      'exact' {
        if ($propertyValue -is [bool] -and $ruleValue -is [bool]) {
          $mainMatch = $propertyValue -eq $ruleValue
        }
        elseif ($caseSensitive) {
          $mainMatch = $propertyValue -ceq $ruleValue
        }
        else {
          $mainMatch = $propertyValue -eq $ruleValue
        }
      }
      'pattern' {
        if ($caseSensitive) {
          $mainMatch = $propertyValue -clike $ruleValue
        }
        else {
          $mainMatch = $propertyValue -like $ruleValue
        }
      }
      'regex' {
        if ($caseSensitive) {
          $mainMatch = $propertyValue -cmatch $ruleValue
        }
        else {
          $mainMatch = $propertyValue -match $ruleValue
        }
      }
      'partial' {
        if ($caseSensitive) {
          $mainMatch = $propertyValue -ccontains $ruleValue
        }
        else {
          $mainMatch = $propertyValue -contains $ruleValue
        }
      }
      default {
        if ($this.logger) {
          $this.logger.LogWarning("Unknown match type: $($rule.match_type)", "DataObjectFilter")
        }
        return $false
      }
    }

    # If main property doesn't match, return false
    if (-not $mainMatch) {
      return $false
    }

    # Check additional property for compound filtering (e.g., resource_type=Child* AND _system_owned=true)
    if ($rule.additional_property -and $rule.additional_value) {
      $additionalPropertyValue = $object[$rule.additional_property]
      if ($null -eq $additionalPropertyValue) {
        return $false
      }

      $additionalMatch = $additionalPropertyValue -eq $rule.additional_value
      if (-not $additionalMatch) {
        return $false
      }

      if ($this.logger -and $this.filterConfig.configuration.enable_logging) {
        $this.logger.LogDebug("COMPOUND FILTERING: Main property '$($rule.property)' = '$propertyValue' AND Additional property '$($rule.additional_property)' = '$additionalPropertyValue' (Expected: '$($rule.additional_value)')", "DataObjectFilter")
      }
    }

    # Both main property and additional property (if specified) match
    return $true
  }

  # Get count of objects that would be filtered
  [object] GetFilteredObjectCount([object] $configuration) {
    $counts = [PSCustomObject]@{
      services        = 0
      groups          = 0
      policies        = 0
      contextProfiles = 0
      total           = 0
    }

    if ($configuration.children) {
      $this.CountFilteredObjects($configuration.children, $counts)
    }

    return $counts
  }

  # Recursively count filtered objects
  hidden [void] CountFilteredObjects([array] $children, [object] $counts) {
    foreach ($child in $children) {
      if ($this.ShouldFilterObject($child)) {
        $counts.total++

        switch ($child.resource_type) {
          'ChildService' { $counts.services++ }
          'ChildGroup' { $counts.groups++ }
          'ChildSecurityPolicy' { $counts.policies++ }
          'ChildContextProfile' { $counts.contextProfiles++ }
        }
      }

      if ($child.children -and $child.children.Count -gt 0) {
        $this.CountFilteredObjects($child.children, $counts)
      }
    }
  }

  # Get filtering statistics and rule group information
  [object] GetFilteringStatistics([object] $configuration) {
    $statistics = [PSCustomObject]@{
      TotalObjectsScanned  = 0
      FilteredObjectsCount = 0
      FilteringRuleGroups  = [PSCustomObject]@{}
      ConfigurationVersion = $this.filterConfig.configuration.version
      ConfigurationFile    = Split-Path $this.configFilePath -Leaf
    }

    # Add rule group statistics
    foreach ($ruleGroupName in $this.filterConfig.filter_rules.Keys) {
      $ruleGroup = $this.filterConfig.filter_rules[$ruleGroupName]
      $statistics.FilteringRuleGroups[$ruleGroupName] = @{
        Description = $ruleGroup.description
        Enabled     = $ruleGroup.enabled
        RuleCount   = $ruleGroup.rules.Count
      }
    }

    if ($configuration.children) {
      $this.AnalyzeFilteringStatistics($configuration.children, $statistics)
    }

    return $statistics
  }

  # Analyze filtering statistics recursively
  hidden [void] AnalyzeFilteringStatistics([array] $children, [object] $statistics) {
    foreach ($child in $children) {
      $statistics.TotalObjectsScanned++

      if ($this.ShouldFilterObject($child)) {
        $statistics.FilteredObjectsCount++
      }

      if ($child.children -and $child.children.Count -gt 0) {
        $this.AnalyzeFilteringStatistics($child.children, $statistics)
      }
    }
  }

  # Reload configuration from JSON file (for runtime updates)
  [void] ReloadConfiguration() {
    if ($this.logger) {
      $this.logger.LogInfo("Reloading filter configuration from JSON file", "DataObjectFilter")
    }
    $this.LoadFilterConfiguration()
  }

  # Get current configuration for debugging
  [object] GetCurrentConfiguration() {
    return $this.filterConfig
  }

  # Test if a specific object would be filtered (for debugging)
  [bool] TestObjectFiltering([object] $object) {
    return $this.ShouldFilterObject($object)
  }

  # Get detailed filter match results (for debugging)
  [object] GetDetailedFilterResults([object] $object) {
    $results = [PSCustomObject]@{
      WouldBeFiltered = $false
      MatchingRules   = @()
    }

    foreach ($ruleGroupName in $this.filterConfig.filter_rules.Keys) {
      $ruleGroup = $this.filterConfig.filter_rules[$ruleGroupName]

      if ($ruleGroup.enabled -eq $false) {
        continue
      }

      $targetObject = $object
      if ($ruleGroup.target_path) {
        $targetObject = $object[$ruleGroup.target_path]
        if (-not $targetObject) {
          continue
        }
      }

      foreach ($rule in $ruleGroup.rules) {
        if ($this.EvaluateRule($targetObject, $rule)) {
          $results.WouldBeFiltered = $true
          $results.MatchingRules += @{
            RuleGroup = $ruleGroupName
            Property  = $rule.property
            MatchType = $rule.match_type
            Value     = $rule.value
          }
        }
      }
    }

    return $results
  }

  # FLEXIBLE FILTERING METHODS

  # Filter single object with direct filter rules
  [bool] FilterObjectDirect([object] $objectToFilter, [object] $filterRules) {
    if (-not $objectToFilter) {
      return $false
    }

    if (-not $filterRules -or -not $filterRules.filter_rules) {
      return $false  # No filter rules, object passes
    }

    # Normalize object if needed
    $objectHash = if ($objectToFilter -is [object]) {
      $objectToFilter
    }
    else {
      $this.ConvertPSObjectToHashtable($objectToFilter)
    }

    # Create temporary instance with provided rules
    $tempFilterService = [DataObjectFilterService]::new($this.logger, $filterRules)

    $result = $tempFilterService.ShouldFilterObject($objectHash)
    if ($this.logger) {
      $displayName = if ($objectHash.display_name) { $objectHash.display_name } else { $objectHash.id }
      $this.logger.LogDebug("Direct filter result for '$displayName': $result", "DataObjectFilter")
    }
    return $result
  }

  # Filter array of objects with direct filter rules
  [array] FilterObjectsArrayDirect([array] $objectsToFilter, [object] $filterRules) {
    if (-not $objectsToFilter -or $objectsToFilter.Count -eq 0) {
      return @()
    }

    if (-not $filterRules -or -not $filterRules.filter_rules) {
      return $objectsToFilter  # No filter rules, return all objects
    }

    # Temporarily store current config and use provided rules
    $originalConfig = $this.filterConfig
    $this.filterConfig = $filterRules

    try {
      $filteredObjects = @()
      $originalCount = $objectsToFilter.Count
      $filteredCount = 0

      foreach ($obj in $objectsToFilter) {
        # Normalize object if needed
        $objectHash = if ($obj -is [object]) {
          $obj
        }
        else {
          $this.ConvertPSObjectToHashtable($obj)
        }

        if (-not $this.ShouldFilterObject($objectHash)) {
          $filteredObjects += $obj  # Keep original object format
          $filteredCount++
        }
        else {
          if ($this.logger) {
            $displayName = if ($objectHash.display_name) { $objectHash.display_name } else { $objectHash.id }
            $this.logger.LogDebug("Filtered out object: $displayName", "DataObjectFilter")
          }
        }
      }

      if ($this.logger) {
        $this.logger.LogInfo("Direct objects filtering completed: $originalCount original, $filteredCount remaining, $($originalCount - $filteredCount) filtered", "DataObjectFilter")
      }

      return $filteredObjects
    }
    finally {
      # Restore original configuration
      $this.filterConfig = $originalConfig
    }
  }

  # Filter objects with runtime configuration object
  [object] FilterObjectsWithRuntimeConfig([object] $configuration, [object] $runtimeFilterConfig) {
    if (-not $configuration) {
      return [PSCustomObject]@{}
    }

    if (-not $runtimeFilterConfig) {
      # No runtime config, use default filtering
      return $this.FilterConfiguration($configuration)
    }

    # Temporarily store current config and use runtime config
    $originalConfig = $this.filterConfig
    $this.filterConfig = $runtimeFilterConfig

    try {
      if ($this.logger) {
        $this.logger.LogInfo("Filtering objects with runtime configuration", "DataObjectFilter")
      }
      return $this.FilterConfiguration($configuration)
    }
    finally {
      # Restore original configuration
      $this.filterConfig = $originalConfig
    }
  }

  # Filter objects with merged configuration (file + runtime)
  [object] FilterObjectsWithMergedConfig([object] $configuration, [object] $additionalRules) {
    if (-not $configuration) {
      return [PSCustomObject]@{}
    }

    if (-not $additionalRules) {
      # No additional rules, use default filtering
      return $this.FilterConfiguration($configuration)
    }

    # Create merged configuration
    $mergedConfig = $this.filterConfig.PSObject.Copy()
    $this.MergeFilterConfiguration($additionalRules, $mergedConfig)

    # Temporarily store current config and use merged config
    $originalConfig = $this.filterConfig
    $this.filterConfig = $mergedConfig

    try {
      if ($this.logger) {
        $this.logger.LogInfo("Filtering objects with merged configuration (file + runtime)", "DataObjectFilter")
      }
      return $this.FilterConfiguration($configuration)
    }
    finally {
      # Restore original configuration
      $this.filterConfig = $originalConfig
    }
  }

  # Set runtime filter configuration
  [void] SetRuntimeFilterConfig([object] $runtimeConfig) {
    if (-not $runtimeConfig) {
      if ($this.logger) {
        $this.logger.LogWarning("No runtime configuration provided", "DataObjectFilter")
      }
      return
    }

    # Update configuration properties
    $this.filterConfig.filter_rules = $runtimeConfig.filter_rules
    $this.filterConfig.configuration = $runtimeConfig.configuration
    $this.filterConfig.metadata = $runtimeConfig.metadata
    $this.ValidateFilterConfiguration()

    if ($this.logger) {
      $this.logger.LogInfo("Runtime filter configuration set successfully", "DataObjectFilter")
    }
  }

  # Add runtime filter rules to existing configuration
  [void] AddRuntimeFilterRules([object] $additionalRules) {
    if (-not $additionalRules) {
      return
    }

    $this.MergeFilterConfiguration($additionalRules)

    if ($this.logger) {
      $this.logger.LogInfo("Runtime filter rules added to existing configuration", "DataObjectFilter")
    }
  }

  # Merge filter configuration
  [void] MergeFilterConfiguration([object] $additionalConfig, [object] $targetConfig = $null) {
    if (-not $additionalConfig) {
      return
    }

    $target = if ($targetConfig) { $targetConfig } else { $this.filterConfig }

    if (-not $target) {
      $target = [PSCustomObject]@{}
      if (-not $targetConfig) {
        # Initialize empty configuration if none exists
        $this.filterConfig = @{
          filter_rules  = [PSCustomObject]@{}
          configuration = [PSCustomObject]@{}
          metadata      = [PSCustomObject]@{}
        }
        $target = $this.filterConfig
      }
    }

    # Ensure filter_rules exists
    if (-not $target.filter_rules) {
      $target.filter_rules = [PSCustomObject]@{}
    }

    # Merge filter rules
    if ($additionalConfig.filter_rules) {
      foreach ($ruleGroupName in $additionalConfig.filter_rules.Keys) {
        $target.filter_rules[$ruleGroupName] = $additionalConfig.filter_rules[$ruleGroupName]
      }
    }

    # Merge configuration settings
    if ($additionalConfig.configuration) {
      if (-not $target.configuration) {
        $target.configuration = [PSCustomObject]@{}
      }
      foreach ($settingName in $additionalConfig.configuration.Keys) {
        $target.configuration[$settingName] = $additionalConfig.configuration[$settingName]
      }
    }

    # Merge metadata
    if ($additionalConfig.metadata) {
      if (-not $target.metadata) {
        $target.metadata = [PSCustomObject]@{}
      }
      foreach ($metaName in $additionalConfig.metadata.Keys) {
        $target.metadata[$metaName] = $additionalConfig.metadata[$metaName]
      }
    }

    if ($this.logger) {
      $this.logger.LogDebug("Filter configuration merged successfully", "DataObjectFilter")
    }
  }

  # Create filter configuration from  rules
  [object] CreateFilterConfigFromRules([array] $Rules) {
    $newFilterConfig = [PSCustomObject]@{
      filter_rules  = @{
        runtime_rules = @{
          description = "Runtime filter rules"
          enabled     = $true
          rules       = @()
        }
      }
      configuration = @{
        version        = "1.0"
        enable_logging = $true
        case_sensitive = $false
      }
      metadata      = @{
        created_by = "Runtime"
        created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
      }
    }

    foreach ($rule in $Rules) {
      $filterRule = [PSCustomObject]@{
        property   = $rule.property
        match_type = if ($rule.match_type) { $rule.match_type } else { "exact" }
        value      = $rule.value
      }
      $newFilterConfig.filter_rules.runtime_rules.rules += $filterRule
    }

    return $newFilterConfig
  }

  # Filter objects with  rules (convenience method)
  [object] FilterObjectsWithRules([object] $configuration, [array] $Rules) {
    if (-not $configuration -or -not $Rules) {
      return if ($configuration) { $configuration } else { [PSCustomObject]@{} }
    }

    $tempConfig = $this.CreateFilterConfigFromRules($Rules)
    return $this.FilterObjectsWithRuntimeConfig($configuration, $tempConfig)
  }

  # Filter array of objects with  rules
  [array] FilterObjectsArrayWithRules([array] $objectsToFilter, [array] $Rules) {
    if (-not $objectsToFilter -or -not $Rules) {
      return if ($objectsToFilter) { $objectsToFilter } else { @() }
    }

    $tempConfig = $this.CreateFilterConfigFromRules($Rules)
    return $this.FilterObjectsArrayDirect($objectsToFilter, $tempConfig)
  }

  # Get current filter configuration (for inspection)
  [object] GetCurrentFilterConfiguration() {
    return $this.filterConfig
  }

  # Check if service is using file-based or runtime configuration
  [bool] IsUsingFileBasedConfiguration() {
    return $null -ne $this.configFilePath
  }

  # Get active rule groups (enabled only)
  [array] GetActiveRuleGroups() {
    $activeGroups = @()

    if ($this.filterConfig.filter_rules) {
      foreach ($ruleGroupName in $this.filterConfig.filter_rules.Keys) {
        $ruleGroup = $this.filterConfig.filter_rules[$ruleGroupName]
        if ($ruleGroup.enabled -eq $true) {
          $activeGroups += @{
            Name        = $ruleGroupName
            Description = $ruleGroup.description
            RuleCount   = $ruleGroup.rules.Count
          }
        }
      }
    }

    return $activeGroups
  }

  # ================================================================================
  # PROPERTY-LEVEL FILTERING METHODS
  # ================================================================================

  # Method 1: Filter object properties with inclusion rules
  [object] FilterObjectPropertiesWithInclusions([object] $objectToFilter) {
    if (-not $objectToFilter) {
      return [PSCustomObject]@{}
    }

    if (-not $this.propertyInclusionsConfig.property_inclusions.enabled) {
      if ($this.logger) {
        $this.logger.LogDebug("Property inclusions disabled, returning original object", "DataObjectFilter")
      }
      return $objectToFilter
    }

    $filteredObject = [PSCustomObject]@{}
    $inclusionRules = $this.propertyInclusionsConfig.property_inclusions.rules
    $globalSettings = $this.propertyInclusionsConfig.property_inclusions.global_settings

    if ($this.logger) {
      $this.logger.LogDebug("Filtering object properties with inclusion rules ($(($inclusionRules).Count) rules)", "DataObjectFilter")
    }

    # Process inclusion rules
    foreach ($rule in $inclusionRules) {
      if ($this.ShouldApplyPropertyRule($objectToFilter, $rule)) {
        $propertyValue = $this.GetPropertyValue($objectToFilter, $rule.property_path, $rule.match_type)

        if ($null -ne $propertyValue -or $globalSettings.include_null_values) {
          if ($propertyValue -is [array] -and $propertyValue.Count -eq 0 -and -not $globalSettings.include_empty_arrays) {
            continue
          }

          $this.SetPropertyValue($filteredObject, $rule.property_path, $propertyValue)

          if ($this.logger) {
            $this.logger.LogDebug("Included property: $($rule.property_path)", "DataObjectFilter")
          }
        }
      }
    }

    return $filteredObject
  }

  # Method 2: Filter object properties with exclusion rules
  [object] FilterObjectPropertiesWithExclusions([object] $objectToFilter) {
    if (-not $objectToFilter) {
      return [PSCustomObject]@{}
    }

    if (-not $this.propertyExclusionsConfig.property_exclusions.enabled) {
      if ($this.logger) {
        $this.logger.LogDebug("Property exclusions disabled, returning original object", "DataObjectFilter")
      }
      return $objectToFilter
    }

    $filteredObject = $objectToFilter.Clone()
    $exclusionRules = $this.propertyExclusionsConfig.property_exclusions.rules
    $globalSettings = $this.propertyExclusionsConfig.property_exclusions.global_settings

    if ($this.logger) {
      $this.logger.LogDebug("Filtering object properties with exclusion rules ($(($exclusionRules).Count) rules)", "DataObjectFilter")
    }

    # Process exclusion rules
    foreach ($rule in $exclusionRules) {
      if ($this.ShouldApplyPropertyRule($objectToFilter, $rule)) {
        $propertiesToRemove = $this.FindMatchingProperties($filteredObject, $rule.property_path, $rule.match_type)

        foreach ($propertyPath in $propertiesToRemove) {
          $this.RemovePropertyValue($filteredObject, $propertyPath)

          if ($this.logger) {
            $this.logger.LogDebug("Excluded property: $propertyPath", "DataObjectFilter")
          }
        }
      }
    }

    # Apply global exclusion settings
    if ($globalSettings.exclude_null_values) {
      $this.RemoveNullProperties($filteredObject)
    }

    if ($globalSettings.exclude_empty_arrays) {
      $this.RemoveEmptyArrayProperties($filteredObject)
    }

    if ($globalSettings.exclude_empty_objects) {
      $this.RemoveEmptyObjectProperties($filteredObject)
    }

    return $filteredObject
  }

  # Method 3: Filter object properties with combined inclusion/exclusion rules
  [object] FilterObjectPropertiesWithCombinedRules([object] $objectToFilter) {
    if (-not $objectToFilter) {
      return [PSCustomObject]@{}
    }

    $executionOrder = $this.propertyInclusionsConfig.property_inclusions.execution_order

    if ($executionOrder -eq "inclusions_first") {
      $tempResult = $this.FilterObjectPropertiesWithInclusions($objectToFilter)
      return $this.FilterObjectPropertiesWithExclusions($tempResult)
    }
    else {
      $tempResult = $this.FilterObjectPropertiesWithExclusions($objectToFilter)
      return $this.FilterObjectPropertiesWithInclusions($tempResult)
    }
  }

  # Method 4: Filter object with multi-step nested processing
  [object] FilterObjectWithMultiStepProcessing([object] $objectToFilter, [int] $currentLevel = 0) {
    if (-not $objectToFilter) {
      return [PSCustomObject]@{}
    }

    if (-not $this.multiStepFilteringConfig.multi_step_filtering.enabled) {
      return $this.FilterObjectPropertiesWithCombinedRules($objectToFilter)
    }

    $maxDepth = $this.multiStepFilteringConfig.multi_step_filtering.max_nesting_depth
    if ($currentLevel -gt $maxDepth) {
      if ($this.logger) {
        $this.logger.LogWarning("Reached maximum nesting depth ($maxDepth), stopping multi-step processing", "DataObjectFilter")
      }
      return $objectToFilter
    }

    $filteredObject = $objectToFilter.Clone()
    $stepDefinitions = $this.multiStepFilteringConfig.multi_step_filtering.step_definitions

    # Sort steps by step_order
    $sortedSteps = $stepDefinitions | Sort-Object { $_.step_order }

    if ($this.logger) {
      $this.logger.LogDebug("Processing multi-step filtering at level $currentLevel with $(($sortedSteps).Count) steps", "DataObjectFilter")
    }

    foreach ($step in $sortedSteps) {
      if ($step.target_level -eq $currentLevel -or $step.target_level -eq -1) {
        if ($this.ShouldExecuteStep($filteredObject, $step, $currentLevel)) {
          $filteredObject = $this.ExecuteFilteringStep($filteredObject, $step, $currentLevel)
        }
      }
    }

    # Recursively process nested objects (children)
    if ($filteredObject.children -and $filteredObject.children.Count -gt 0) {
      $filteredChildren = @()
      foreach ($child in $filteredObject.children) {
        $filteredChild = $this.FilterObjectWithMultiStepProcessing($child, $currentLevel + 1)
        if ($filteredChild.Count -gt 0) {
          $filteredChildren += $filteredChild
        }
      }
      $filteredObject.children = $filteredChildren
    }

    return $filteredObject
  }

  # Method 5: Filter configuration for verification comparison
  [object] FilterConfigurationForVerificationComparison([object] $configuration) {
    if (-not $configuration) {
      return [PSCustomObject]@{}
    }

    if ($this.logger) {
      $this.logger.LogInfo("Filtering configuration for verification comparison using property-level filtering", "DataObjectFilter")
    }

    # Apply multi-step filtering to the entire configuration
    $filteredConfig = $this.FilterObjectWithMultiStepProcessing($configuration, 0)

    # Apply object-level filtering (existing functionality) as final step
    $finalFilteredConfig = $this.FilterConfiguration($filteredConfig)

    if ($this.logger) {
      $this.logger.LogInfo("Verification comparison filtering completed", "DataObjectFilter")
    }

    return $finalFilteredConfig
  }

  # Method 6: Filter array of objects with property-level filtering (parallel processing)
  [array] FilterObjectsArrayWithPropertyFilteringParallel([array] $objectsToFilter) {
    if (-not $objectsToFilter -or $objectsToFilter.Count -eq 0) {
      return @()
    }

    if ($this.logger) {
      $this.logger.LogInfo("Starting parallel property-level filtering for $(($objectsToFilter).Count) objects", "DataObjectFilter")
    }

    $filteredObjects = @()
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, 4)
    $runspacePool.Open()
    $jobs = @()

    try {
      foreach ($obj in $objectsToFilter) {
        $powershell = [powershell]::Create().AddScript({
            param($object, $service)
            return $service.FilterObjectWithMultiStepProcessing($object, 0)
          }).AddParameter("object", $obj).AddParameter("service", $this)

        $powershell.RunspacePool = $runspacePool
        $jobs += @{
          PowerShell = $powershell
          Result     = $powershell.BeginInvoke()
        }
      }

      # Collect results
      foreach ($job in $jobs) {
        $result = $job.PowerShell.EndInvoke($job.Result)
        if ($result -and $result.Count -gt 0) {
          $filteredObjects += $result
        }
        $job.PowerShell.Dispose()
      }
    }
    finally {
      $runspacePool.Close()
      $runspacePool.Dispose()
    }

    if ($this.logger) {
      $this.logger.LogInfo("Parallel property-level filtering completed: $(($filteredObjects).Count) objects remaining", "DataObjectFilter")
    }

    return $filteredObjects
  }

  # Method 7: Filter array of objects with property-level filtering (serial processing)
  [array] FilterObjectsArrayWithPropertyFilteringSerial([array] $objectsToFilter) {
    if (-not $objectsToFilter -or $objectsToFilter.Count -eq 0) {
      return @()
    }

    if ($this.logger) {
      $this.logger.LogInfo("Starting serial property-level filtering for $(($objectsToFilter).Count) objects", "DataObjectFilter")
    }

    $filteredObjects = @()
    $processedCount = 0

    foreach ($obj in $objectsToFilter) {
      $processedCount++

      if ($this.logger -and $processedCount % 100 -eq 0) {
        $this.logger.LogDebug("Processed $processedCount objects", "DataObjectFilter")
      }

      $filteredObject = $this.FilterObjectWithMultiStepProcessing($obj, 0)
      if ($filteredObject -and $filteredObject.Count -gt 0) {
        $filteredObjects += $filteredObject
      }
    }

    if ($this.logger) {
      $this.logger.LogInfo("Serial property-level filtering completed: $(($filteredObjects).Count) objects remaining", "DataObjectFilter")
    }

    return $filteredObjects
  }

  # Method 8: Get property filtering statistics
  [object] GetPropertyFilteringStatistics([object] $configuration) {
    $statistics = [PSCustomObject]@{
      PropertyInclusionsEnabled = $this.propertyInclusionsConfig.property_inclusions.enabled
      PropertyExclusionsEnabled = $this.propertyExclusionsConfig.property_exclusions.enabled
      MultiStepFilteringEnabled = $this.multiStepFilteringConfig.multi_step_filtering.enabled
      InclusionRulesCount       = $this.propertyInclusionsConfig.property_inclusions.rules.Count
      ExclusionRulesCount       = $this.propertyExclusionsConfig.property_exclusions.rules.Count
      MultiStepDefinitionsCount = $this.multiStepFilteringConfig.multi_step_filtering.step_definitions.Count
      ConfigurationFile         = Split-Path $this.configFilePath -Leaf
      PropertyInclusionsFile    = Split-Path $this.propertyInclusionsConfigPath -Leaf
      PropertyExclusionsFile    = Split-Path $this.propertyExclusionsConfigPath -Leaf
      MultiStepFilteringFile    = Split-Path $this.multiStepFilteringConfigPath -Leaf
      TotalPropertiesProcessed  = 0
      TotalPropertiesIncluded   = 0
      TotalPropertiesExcluded   = 0
    }

    if ($configuration) {
      $this.AnalyzePropertyFilteringStatistics($configuration, $statistics, 0)
    }

    return $statistics
  }

  # Method 9: Reload all property filtering configurations
  [void] ReloadPropertyFilteringConfigurations() {
    if ($this.logger) {
      $this.logger.LogInfo("Reloading all property filtering configurations", "DataObjectFilter")
    }

    $this.LoadPropertyFilteringConfigurations()

    if ($this.logger) {
      $this.logger.LogInfo("Property filtering configurations reloaded successfully", "DataObjectFilter")
    }
  }



  # ================================================================================
  # PROPERTY-LEVEL FILTERING HELPER METHODS
  # ================================================================================



  # Helper: Check if property rule should be applied to object
  hidden [bool] ShouldApplyPropertyRule([object] $object, [object] $rule) {
    # Check object type applicability
    $objectType = $object["type"]
    if (-not $objectType) {
      $objectType = $object["resource_type"]  # Fallback for legacy compatibility
    }
    $appliesToTypes = $rule.applies_to_object_types

    if ($appliesToTypes -and $appliesToTypes.Count -gt 0) {
      $applies = $false
      foreach ($type in $appliesToTypes) {
        if ($type -eq "*" -or $objectType -eq $type -or $objectType -like $type) {
          $applies = $true
          break
        }
      }

      if (-not $applies) {
        return $false
      }
    }

    # Check conditional logic if present
    if ($rule.conditional_logic) {
      return $this.EvaluateConditionalLogic($object, $rule.conditional_logic)
    }

    return $true
  }

  # Helper: Get property value with pattern matching support
  hidden [object] GetPropertyValue([object] $object, [string] $propertyPath, [string] $matchType) {
    if ($matchType -eq "exact") {
      return $object[$propertyPath]
    }

    if ($matchType -eq "wildcard") {
      foreach ($key in $object.Keys) {
        if ($key -like $propertyPath) {
          return $object[$key]
        }
      }
    }

    if ($matchType -eq "regex") {
      foreach ($key in $object.Keys) {
        if ($key -match $propertyPath) {
          return $object[$key]
        }
      }
    }

    return $null
  }

  # Helper: Set property value in object
  hidden [void] SetPropertyValue([object] $object, [string] $propertyPath, [object] $value) {
    $object[$propertyPath] = $value
  }

  # Helper: Find matching properties for exclusion
  hidden [array] FindMatchingProperties([object] $object, [string] $propertyPath, [string] $matchType) {
    $matchingProperties = @()

    if ($matchType -eq "exact") {
      if ($object.$propertyPath) {
        $matchingProperties += $propertyPath
      }
    }
    elseif ($matchType -eq "wildcard") {
      foreach ($key in $object.Keys) {
        if ($key -like $propertyPath) {
          $matchingProperties += $key
        }
      }
    }
    elseif ($matchType -eq "regex") {
      foreach ($key in $object.Keys) {
        if ($key -match $propertyPath) {
          $matchingProperties += $key
        }
      }
    }
    elseif ($matchType -eq "prefix") {
      foreach ($key in $object.Keys) {
        if ($key.StartsWith($propertyPath)) {
          $matchingProperties += $key
        }
      }
    }
    elseif ($matchType -eq "suffix") {
      foreach ($key in $object.Keys) {
        if ($key.EndsWith($propertyPath)) {
          $matchingProperties += $key
        }
      }
    }

    return $matchingProperties
  }

  # Helper: Remove property value from object
  hidden [void] RemovePropertyValue([object] $object, [string] $propertyPath) {
    if ($object.$propertyPath) {
      $object.Remove($propertyPath)
    }
  }

  # Helper: Remove null properties
  hidden [void] RemoveNullProperties([object] $object) {
    $keysToRemove = @()
    foreach ($key in $object.Keys) {
      if ($null -eq $object[$key]) {
        $keysToRemove += $key
      }
    }

    foreach ($key in $keysToRemove) {
      $object.Remove($key)
    }
  }

  # Helper: Remove empty array properties
  hidden [void] RemoveEmptyArrayProperties([object] $object) {
    $keysToRemove = @()
    foreach ($key in $object.Keys) {
      if ($object[$key] -is [array] -and $object[$key].Count -eq 0) {
        $keysToRemove += $key
      }
    }

    foreach ($key in $keysToRemove) {
      $object.Remove($key)
    }
  }

  # Helper: Remove empty object properties
  hidden [void] RemoveEmptyObjectProperties([object] $object) {
    $keysToRemove = @()
    foreach ($key in $object.Keys) {
      if ($object[$key] -is [object] -and $object[$key].Count -eq 0) {
        $keysToRemove += $key
      }
    }

    foreach ($key in $keysToRemove) {
      $object.Remove($key)
    }
  }

  # Helper: Check if step should be executed
  hidden [bool] ShouldExecuteStep([object] $object, [object] $step, [int] $currentLevel) {
    # Check target level
    if ($step.target_level -ne -1 -and $step.target_level -ne $currentLevel) {
      return $false
    }

    # Check parent property filter
    if ($step.parent_property_filter) {
      if (-not ($object | Get-Member -Name $step.parent_property_filter -ErrorAction SilentlyContinue)) {
        return $false
      }
    }

    # Check parent resource type filter
    if ($step.parent_resource_type_filter) {
      $resourceType = $object["resource_type"]
      if (-not $resourceType -or -not ($resourceType -like $step.parent_resource_type_filter)) {
        return $false
      }
    }

    # Check conditional execution
    if ($step.conditional_execution) {
      return $this.EvaluateConditionalLogic($object, $step.conditional_execution)
    }

    return $true
  }

  # Helper: Execute filtering step
  hidden [object] ExecuteFilteringStep([object] $object, [object] $step, [int] $currentLevel) {
    $result = $object

    if ($step.execution_order -eq "exclusions_first") {
      if ($step.property_exclusions -and $step.property_exclusions.enabled) {
        $result = $this.ApplyStepExclusions($result, $step.property_exclusions)
      }

      if ($step.property_inclusions -and $step.property_inclusions.enabled) {
        $result = $this.ApplyStepInclusions($result, $step.property_inclusions)
      }
    }
    elseif ($step.execution_order -eq "inclusions_first") {
      if ($step.property_inclusions -and $step.property_inclusions.enabled) {
        $result = $this.ApplyStepInclusions($result, $step.property_inclusions)
      }

      if ($step.property_exclusions -and $step.property_exclusions.enabled) {
        $result = $this.ApplyStepExclusions($result, $step.property_exclusions)
      }
    }
    elseif ($step.execution_order -eq "exclusions_only") {
      if ($step.property_exclusions -and $step.property_exclusions.enabled) {
        $result = $this.ApplyStepExclusions($result, $step.property_exclusions)
      }
    }
    elseif ($step.execution_order -eq "inclusions_only") {
      if ($step.property_inclusions -and $step.property_inclusions.enabled) {
        $result = $this.ApplyStepInclusions($result, $step.property_inclusions)
      }
    }

    return $result
  }

  # Helper: Apply step exclusions
  hidden [object] ApplyStepExclusions([object] $object, [object] $exclusionConfig) {
    $result = $object.Clone()

    foreach ($rule in $exclusionConfig.rules) {
      if ($this.ShouldApplyPropertyRule($object, $rule)) {
        $propertiesToRemove = $this.FindMatchingProperties($result, $rule.property_path, $rule.match_type)

        foreach ($propertyPath in $propertiesToRemove) {
          $this.RemovePropertyValue($result, $propertyPath)
        }
      }
    }

    return $result
  }

  # Helper: Apply step inclusions
  hidden [object] ApplyStepInclusions([object] $object, [object] $inclusionConfig) {
    $result = [PSCustomObject]@{}

    foreach ($rule in $inclusionConfig.rules) {
      if ($this.ShouldApplyPropertyRule($object, $rule)) {
        $propertyValue = $this.GetPropertyValue($object, $rule.property_path, $rule.match_type)

        if ($null -ne $propertyValue) {
          $this.SetPropertyValue($result, $rule.property_path, $propertyValue)
        }
      }
    }

    return $result
  }

  # Helper: Evaluate conditional logic
  hidden [bool] EvaluateConditionalLogic([object] $object, [object] $conditionalLogic) {
    if ($conditionalLogic.if_property_exists) {
      if (-not ($object | Get-Member -Name $conditionalLogic.if_property_exists -ErrorAction SilentlyContinue)) {
        return $false
      }
    }

    if ($conditionalLogic.if_property_value) {
      $propertyName = $conditionalLogic.if_property_exists
      if ($propertyName -and ($object | Get-Member -Name $propertyName -ErrorAction SilentlyContinue)) {
        if ($object[$propertyName] -ne $conditionalLogic.if_property_value) {
          return $false
        }
      }
    }

    if ($conditionalLogic.if_resource_type) {
      $resourceType = $object["resource_type"]
      if (-not $resourceType -or $resourceType -ne $conditionalLogic.if_resource_type) {
        return $false
      }
    }

    return $true
  }

  # Helper: Analyze property filtering statistics
  hidden [void] AnalyzePropertyFilteringStatistics([object] $object, [object] $statistics, [int] $currentLevel) {
    if (-not $object) {
      return
    }

    $statistics.TotalPropertiesProcessed += $object.Keys.Count

    # Recursively analyze children
    if ($object.children -and $object.children.Count -gt 0) {
      foreach ($child in $object.children) {
        $this.AnalyzePropertyFilteringStatistics($child, $statistics, $currentLevel + 1)
      }
    }
  }
}
