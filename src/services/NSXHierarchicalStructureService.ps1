# NSXHierarchicalStructureService.ps1
# Service for creating and managing NSX-T Hierarchical API structures
# Handles both raw JSON objects and already-hierarchical objects with auto-detection

class NSXHierarchicalStructureService {
  hidden [object] $logger
  hidden [string] $defaultDomain
  hidden [object] $config

  # Constructor
  NSXHierarchicalStructureService([object] $loggingService, [object] $config = [PSCustomObject]@{}) {
    $this.logger = $loggingService
    $this.config = $config
    $this.defaultDomain = if ($config.default_domain) { $config.default_domain } else { "default" }

    $this.logger.LogInfo("NSX Hierarchical Structure Service initialised", "HierarchicalStructure")
    $this.logger.LogInfo("NSX Hierarchical Structure Service initialised with auto-detection", "HierarchicalStructure")
  }

  #region Auto-Detection and Wrapping Methods

  # Master method to intelligently wrap objects - handles both raw and hierarchical objects
  [object] WrapObjectIntelligently([object] $obj) {
    try {
      if (-not $obj) {
        $this.logger.LogWarning("Received null object, skipping wrap operation", "HierarchicalStructure")
        return $null
      }

      # Check if object has resource_type
      if (-not $obj.resource_type) {
        $this.logger.LogWarning("Object missing resource_type, attempting to determine type from properties", "HierarchicalStructure")
        $obj = $this.DetermineResourceType($obj)
      }

      $resourceType = $obj.resource_type
      $this.logger.LogInfo("Processing object of type: $resourceType", "HierarchicalStructure")

      # Check if object is already in hierarchical format
      if ($this.IsAlreadyHierarchical($obj)) {
        $this.logger.LogInfo("Object already in hierarchical format: $resourceType", "HierarchicalStructure")
        return $this.ProcessExistingHierarchicalObject($obj)
      }

      # Wrap raw object in appropriate hierarchical container
      return $this.WrapRawObjectInHierarchicalContainer($obj)
    }
    catch {
      $this.logger.LogError("Failed to wrap object intelligently: $($_.Exception.Message)", "HierarchicalStructure")
      return $null
    }
  }

  # Determine if an object is already in hierarchical format
  [bool] IsAlreadyHierarchical([object] $obj) {
    if (-not $obj.resource_type) {
      return $false
    }

    $resourceType = $obj.resource_type

    # Check if it starts with "Child" - this indicates hierarchical format
    if ($resourceType.StartsWith("Child")) {
      return $true
    }

    # Check if it has nested child objects with Child prefixes
    if ($obj.children) {
      foreach ($child in $obj.children) {
        if ($child.resource_type -and $child.resource_type.StartsWith("Child")) {
          return $true
        }
      }
    }

    return $false
  }

  # Process existing hierarchical objects and ensure they're properly formatted
  [object] ProcessExistingHierarchicalObject([object] $obj) {
    try {
      $resourceType = $obj.resource_type

      # Handle special case: ChildResourceReference conversion
      if ($resourceType -eq "ChildResourceReference" -and $obj.target_type) {
        return $this.ConvertChildResourceReference($obj)
      }

      # Process nested children if they exist
      if ($obj.children) {
        $processedChildren = @()
        foreach ($child in $obj.children) {
          $wrappedChild = $this.WrapObjectIntelligently($child)
          if ($wrappedChild) {
            $processedChildren += $wrappedChild
          }
        }

        # Update the object with processed children
        $obj.children = $processedChildren
        $this.logger.LogInfo("Processed $($processedChildren.Count) nested children for $resourceType", "HierarchicalStructure")
      }

      # Handle child objects within hierarchical wrappers
      if ($resourceType.StartsWith("Child")) {
        $obj = $this.ProcessChildWrapper($obj)
      }

      return $obj
    }
    catch {
      $this.logger.LogError("Failed to process existing hierarchical object: $($_.Exception.Message)", "HierarchicalStructure")
      return $obj
    }
  }

  # Process child wrapper objects to ensure inner objects are properly structured
  [object] ProcessChildWrapper([object] $obj) {
    try {
      $resourceType = $obj.resource_type

      # Get the inner object type (remove "Child" prefix)
      $innerType = $resourceType.Substring(5)  # Remove "Child" prefix

      # Check if the inner object exists and process it
      if ($obj.$innerType) {
        $innerObject = $obj.$innerType

        # Ensure inner object has correct resource_type
        if (-not $innerObject.resource_type) {
          $innerObject.resource_type = $innerType
        }

        # Process nested children in inner object
        if ($innerObject.children) {
          $processedChildren = @()
          foreach ($child in $innerObject.children) {
            $wrappedChild = $this.WrapObjectIntelligently($child)
            if ($wrappedChild) {
              $processedChildren += $wrappedChild
            }
          }
          $innerObject.children = $processedChildren
        }

        # Update the wrapper with processed inner object
        $obj.$innerType = $innerObject
      }

      return $obj
    }
    catch {
      $this.logger.LogError("Failed to process child wrapper: $($_.Exception.Message)", "HierarchicalStructure")
      return $obj
    }
  }

  # Convert ChildResourceReference to appropriate type
  [object] ConvertChildResourceReference([object] $obj) {
    try {
      $targetType = $obj.target_type
      $this.logger.LogInfo("Converting ChildResourceReference with target_type '$targetType' to Child$targetType", "HierarchicalStructure")

      if ($targetType -eq "Domain") {
        # Process nested children for Domain
        $processedChildren = @()
        if ($obj.children) {
          foreach ($child in $obj.children) {
            $wrappedChild = $this.WrapObjectIntelligently($child)
            if ($wrappedChild) {
              $processedChildren += $wrappedChild
            }
          }
        }

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
    catch {
      $this.logger.LogError("Failed to convert ChildResourceReference: $($_.Exception.Message)", "HierarchicalStructure")
      return $obj
    }
  }

  # Wrap raw objects in appropriate hierarchical containers
  [object] WrapRawObjectInHierarchicalContainer([object] $obj) {
    try {
      $resourceType = $obj.resource_type
      $this.logger.LogInfo("Wrapping raw object of type: $resourceType", "HierarchicalStructure")

      # Process nested children first if they exist
      if ($obj.children) {
        $processedChildren = @()
        foreach ($child in $obj.children) {
          $wrappedChild = $this.WrapObjectIntelligently($child)
          if ($wrappedChild) {
            $processedChildren += $wrappedChild
          }
        }
        $obj.children = $processedChildren
      }

      # Create hierarchical wrapper based on resource type
      $result = $null
      switch ($resourceType) {
        "Service" {
          $result = [PSCustomObject]@{
            resource_type = "ChildService"
            Service       = $obj
          }
        }
        "Group" {
          $result = [PSCustomObject]@{
            resource_type = "ChildGroup"
            Group         = $obj
          }
        }
        "SecurityPolicy" {
          $result = [PSCustomObject]@{
            resource_type  = "ChildSecurityPolicy"
            SecurityPolicy = $obj
          }
        }
        "Domain" {
          $result = [PSCustomObject]@{
            resource_type = "ChildDomain"
            Domain        = $obj
          }
        }
        "PolicyContextProfile" {
          $result = [PSCustomObject]@{
            resource_type        = "ChildPolicyContextProfile"
            PolicyContextProfile = $obj
          }
        }
        "ContextProfile" {
          $result = [PSCustomObject]@{
            resource_type  = "ChildContextProfile"
            ContextProfile = $obj
          }
        }
        "Rule" {
          $result = [PSCustomObject]@{
            resource_type = "ChildRule"
            Rule          = $obj
          }
        }
        "Segment" {
          $result = [PSCustomObject]@{
            resource_type = "ChildSegment"
            Segment       = $obj
          }
        }
        "Tag" {
          $result = [PSCustomObject]@{
            resource_type = "ChildTag"
            Tag           = $obj
          }
        }
        default {
          $this.logger.LogWarning("Unknown raw resource type '$resourceType', using generic wrapper", "HierarchicalStructure")

          # Create a proper wrapper object to avoid key conflicts
          $wrapperKey = $resourceType
          $result = [PSCustomObject]@{
            resource_type = "Child$resourceType"
          }

          # Add the object under the appropriate key name
          $result[$wrapperKey] = $obj
        }
      }

      return $result
    }
    catch {
      $this.logger.LogError("Failed to wrap raw object in hierarchical container: $($_.Exception.Message)", "HierarchicalStructure")
      return $obj
    }
  }

  # Attempt to determine resource type from object properties
  [object] DetermineResourceType([object] $obj) {
    try {
      # Check for common patterns to determine resource type
      if ($obj.expression -or $obj.criteria) {
        $obj.resource_type = "Group"
        $this.logger.LogInfo("Determined resource type as Group based on expression/criteria", "HierarchicalStructure")
      }
      elseif ($obj.service_entries -or $obj.nested_service_ids) {
        $obj.resource_type = "Service"
        $this.logger.LogInfo("Determined resource type as Service based on service entries", "HierarchicalStructure")
      }
      elseif ($obj.rules -or $obj.category) {
        $obj.resource_type = "SecurityPolicy"
        $this.logger.LogInfo("Determined resource type as SecurityPolicy based on rules/category", "HierarchicalStructure")
      }
      elseif ($obj.connectivity_path -or $obj.transport_zone_path) {
        $obj.resource_type = "Segment"
        $this.logger.LogInfo("Determined resource type as Segment based on connectivity/transport zone", "HierarchicalStructure")
      }
      elseif ($obj.scope -and $obj.tag) {
        $obj.resource_type = "Tag"
        $this.logger.LogInfo("Determined resource type as Tag based on scope/tag properties", "HierarchicalStructure")
      }
      elseif ($obj.attributes -or $obj.app_id) {
        $obj.resource_type = "PolicyContextProfile"
        $this.logger.LogInfo("Determined resource type as PolicyContextProfile based on attributes", "HierarchicalStructure")
      }
      else {
        $this.logger.LogWarning("Unable to determine resource type from object properties", "HierarchicalStructure")
        $obj.resource_type = "Unknown"
      }

      return $obj
    }
    catch {
      $this.logger.LogError("Failed to determine resource type: $($_.Exception.Message)", "HierarchicalStructure")
      $obj.resource_type = "Unknown"
      return $obj
    }
  }

  #endregion

  #region Batch Processing Methods

  # Process multiple objects intelligently
  [array] WrapObjectsIntelligently([array] $objects) {
    try {
      $wrappedObjects = @()
      $this.logger.LogInfo("Processing $($objects.Count) objects for intelligent wrapping", "HierarchicalStructure")

      foreach ($obj in $objects) {
        $wrappedObj = $this.WrapObjectIntelligently($obj)
        if ($wrappedObj) {
          $wrappedObjects += $wrappedObj
        }
      }

      $this.logger.LogInfo("Successfully wrapped $($wrappedObjects.Count) objects", "HierarchicalStructure")
      return $wrappedObjects
    }
    catch {
      $this.logger.LogError("Failed to wrap objects intelligently: $($_.Exception.Message)", "HierarchicalStructure")
      return @()
    }
  }

  # Create complete hierarchical structure from mixed object types
  [object] CreateHierarchicalStructureFromObjects([array] $objects, [string] $domainId = $null) {
    try {
      if (-not $domainId) {
        $domainId = $this.defaultDomain
      }

      $this.logger.LogInfo("Creating hierarchical structure from $($objects.Count) objects for domain: $domainId", "HierarchicalStructure")

      # Create base infrastructure
      $this.logger.LogDebug("Creating base infrastructure", "HierarchicalStructure")
      $infrastructure = $this.CreateBaseInfrastructure()

      # Process and categorize objects
      $this.logger.LogDebug("Processing and categorizing objects", "HierarchicalStructure")
      $processedObjects = $this.WrapObjectsIntelligently($objects)

      # Create domain structure
      $this.logger.LogDebug("Creating domain structure for: $domainId", "HierarchicalStructure")
      $domainStructure = $this.CreateDomainStructure($domainId)

      # Add objects to appropriate locations
      $this.logger.LogDebug("Adding $($processedObjects.Count) objects to appropriate locations", "HierarchicalStructure")
      foreach ($obj in $processedObjects) {
        $resourceType = $obj.resource_type
        $this.logger.LogDebug("Processing object with resource_type: $resourceType", "HierarchicalStructure")

        try {
          switch ($resourceType) {
            "ChildService" {
              $this.logger.LogDebug("Adding ChildService to infrastructure", "HierarchicalStructure")
              $infrastructure.children += $obj
            }
            { $_ -in @("ChildGroup", "ChildSecurityPolicy", "ChildPolicyContextProfile", "ChildContextProfile", "ChildRule", "ChildSegment") } {
              $this.logger.LogDebug("Adding $resourceType to domain structure", "HierarchicalStructure")
              $domainStructure.Domain.children += $obj
            }
            "ChildDomain" {
              $this.logger.LogDebug("Adding ChildDomain to infrastructure", "HierarchicalStructure")
              $infrastructure.children += $obj
            }
            default {
              $this.logger.LogWarning("Unknown child resource type: $resourceType, adding to domain", "HierarchicalStructure")
              $domainStructure.Domain.children += $obj
            }
          }
        }
        catch {
          $this.logger.LogError("Error adding object with resource_type '$resourceType': $($_.Exception.Message)", "HierarchicalStructure")
          throw
        }
      }

      # Add domain to infrastructure if it has children
      $this.logger.LogDebug("Adding domain to infrastructure if it has children", "HierarchicalStructure")
      if ($domainStructure.Domain.children.Count -gt 0) {
        $infrastructure.children += $domainStructure
      }

      $this.logger.LogInfo("Created hierarchical structure with $($infrastructure.children.Count) top-level children", "HierarchicalStructure")
      return $infrastructure
    }
    catch {
      $this.logger.LogError("Failed to create hierarchical structure from objects: $($_.Exception.Message)", "HierarchicalStructure")
      return $null
    }
  }

  #endregion

  #region Legacy Methods (preserved for backward compatibility)

  # Create the base hierarchical infrastructure structure
  [object] CreateBaseInfrastructure() {
    $this.logger.LogInfo("Creating base hierarchical infrastructure structure", "HierarchicalStructure")

    $infrastructure = [ordered]@{
      resource_type = "Infra"
      children      = @()
    }

    $this.logger.LogDebug("Created base infrastructure structure", "HierarchicalStructure")
    return $infrastructure
  }

  # Create domain structure
  [object] CreateDomainStructure([string] $domainId) {
    $domainStructure = [ordered]@{
      resource_type = "ChildDomain"
      Domain        = [ordered]@{
        resource_type = "Domain"
        id            = $domainId
        display_name  = $domainId
        children      = @()
      }
    }

    $this.logger.LogDebug("Created domain reference for: $domainId", "HierarchicalStructure")
    return $domainStructure
  }

  # Add service to infrastructure
  [void] AddServiceToInfrastructure([object] $infraStructure, [object] $serviceDefinition) {
    $childService = $this.WrapObjectIntelligently($serviceDefinition)
    $infraStructure.children += $childService
    $this.logger.LogInfo("Added service to infrastructure: $($serviceDefinition.display_name)", "HierarchicalStructure")
  }

  # Add group to domain
  [void] AddGroupToDomain([object] $domainRef, [object] $groupDefinition) {
    $childGroup = $this.WrapObjectIntelligently($groupDefinition)
    $domainRef.Domain.children += $childGroup
    $this.logger.LogInfo("Added group to domain: $($groupDefinition.display_name)", "HierarchicalStructure")
  }

  # Add security policy to domain
  [void] AddSecurityPolicyToDomain([object] $domainRef, [object] $policyDefinition) {
    $childSecurityPolicy = $this.WrapObjectIntelligently($policyDefinition)
    $domainRef.Domain.children += $childSecurityPolicy
    $this.logger.LogInfo("Added security policy to domain: $($policyDefinition.display_name)", "HierarchicalStructure")
  }

  # Add context profile to domain
  [void] AddContextProfileToDomain([object] $domainRef, [object] $profileDefinition) {
    $childContextProfile = $this.WrapObjectIntelligently($profileDefinition)
    $domainRef.Domain.children += $childContextProfile
    $this.logger.LogInfo("Added context profile to domain: $($profileDefinition.display_name)", "HierarchicalStructure")
  }

  #endregion

  #region Pipeline Integration Methods

  # Create structure from parsed files (DataTransformationPipeline integration)
  [object] CreateStructureFromParsedFiles([array] $parsedFiles, [string] $domainId = $null) {
    try {
      if (-not $domainId) {
        $domainId = $this.defaultDomain
      }

      $this.logger.LogInfo("Creating hierarchical structure from $($parsedFiles.Count) parsed files for domain: $domainId", "HierarchicalStructure")

      # Collect all objects from parsed files
      $allObjects = @()
      foreach ($parsedFile in $parsedFiles) {
        # Handle different data structures from CSV parser
        $objects = $null
        $sourceFile = "unknown"

        if ($parsedFile.parsed_data -and $parsedFile.parsed_data.objects) {
          # Objects from ProcessSpecificCSVFile method
          $objects = $parsedFile.parsed_data.objects
          $sourceFile = $parsedFile.source_csv
        }
        elseif ($parsedFile.objects) {
          # Objects from ParseCSVFile method
          $objects = $parsedFile.objects
          $sourceFile = $parsedFile.source_file
        }

        if ($objects -and $objects.Count -gt 0) {
          $this.logger.LogInfo("Processing $($objects.Count) objects from file: $sourceFile", "HierarchicalStructure")
          $allObjects += $objects
        }
        else {
          $this.logger.LogWarning("No objects found in parsed file: $sourceFile", "HierarchicalStructure")
        }
      }

      if ($allObjects.Count -eq 0) {
        $this.logger.LogWarning("No objects found in parsed files", "HierarchicalStructure")
        return $null
      }

      # Use intelligent wrapping to create hierarchical structure
      $hierarchicalStructure = $this.CreateHierarchicalStructureFromObjects($allObjects, $domainId)

      # Validate the structure
      $isValid = $this.ValidateHierarchicalStructure($hierarchicalStructure)
      if (-not $isValid) {
        $this.logger.LogWarning("Created hierarchical structure failed validation", "HierarchicalStructure")
      }

      $this.logger.LogInfo("Successfully created hierarchical structure from parsed files", "HierarchicalStructure")
      return $hierarchicalStructure

    }
    catch {
      $this.logger.LogError("Failed to create structure from parsed files: $($_.Exception.Message)", "HierarchicalStructure")
      return $null
    }
  }

  # Save hierarchical structure to file
  [string] SaveHierarchicalStructure([object] $structure, [string] $filePath = $null) {
    try {
      if (-not $filePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $fileName = "hierarchical_structure_$timestamp.json"
        $filePath = Join-Path (Get-Location) $fileName
      }

      # Ensure directory exists
      $directory = Split-Path $filePath -Parent
      if (-not (Test-Path $directory)) {
        New-Item -Path $directory -ItemType Directory -Force | Out-Null
      }

      # Convert to JSON and save
      $jsonContent = $structure | ConvertTo-Json -Depth 20
      $jsonContent | Out-File -FilePath $filePath -Encoding UTF8

      $this.logger.LogInfo("Hierarchical structure saved to: $filePath", "HierarchicalStructure")
      return $filePath

    }
    catch {
      $this.logger.LogError("Failed to save hierarchical structure: $($_.Exception.Message)", "HierarchicalStructure")
      return $null
    }
  }

  # Load hierarchical structure from file
  [object] LoadHierarchicalStructure([string] $filePath) {
    try {
      if (-not (Test-Path $filePath)) {
        throw "File not found: $filePath"
      }

      $this.logger.LogInfo("Loading hierarchical structure from: $filePath", "HierarchicalStructure")
      $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json

      # Validate loaded structure
      $isValid = $this.ValidateHierarchicalStructure($content)
      if (-not $isValid) {
        $this.logger.LogWarning("Loaded hierarchical structure failed validation", "HierarchicalStructure")
      }

      return $content

    }
    catch {
      $this.logger.LogError("Failed to load hierarchical structure: $($_.Exception.Message)", "HierarchicalStructure")
      return $null
    }
  }

  #endregion

  #region Utility Methods

  # Validate hierarchical structure
  [bool] ValidateHierarchicalStructure([object] $structure) {
    try {
      if (-not $structure.resource_type) {
        $this.logger.LogError("Structure missing resource_type", "HierarchicalStructure")
        return $false
      }

      if ($structure.resource_type -ne "Infra") {
        $this.logger.LogError("Root structure must be of type 'Infra'", "HierarchicalStructure")
        return $false
      }

      if (-not $structure.children) {
        $this.logger.LogWarning("Structure has no children", "HierarchicalStructure")
        return $true
      }

      # Validate each child
      foreach ($child in $structure.children) {
        if (-not $child.resource_type) {
          $this.logger.LogError("Child missing resource_type", "HierarchicalStructure")
          return $false
        }

        if (-not $child.resource_type.StartsWith("Child")) {
          $this.logger.LogError("Child resource_type must start with 'Child': $($child.resource_type)", "HierarchicalStructure")
          return $false
        }
      }

      $this.logger.LogInfo("Hierarchical structure validation passed", "HierarchicalStructure")
      return $true
    }
    catch {
      $this.logger.LogError("Hierarchical structure validation failed: $($_.Exception.Message)", "HierarchicalStructure")
      return $false
    }
  }

  # Get statistics about hierarchical structure
  [object] GetHierarchicalStatistics([object] $structure) {
    try {
      $stats = [PSCustomObject]@{
        total_children          = 0
        child_services          = 0
        child_groups            = 0
        child_security_policies = 0
        child_domains           = 0
        child_context_profiles  = 0
        child_segments          = 0
        child_tags              = 0
        unknown_children        = 0
      }

      if ($structure.children) {
        $stats.total_children = $structure.children.Count

        foreach ($child in $structure.children) {
          switch ($child.resource_type) {
            "ChildService" { $stats.child_services++ }
            "ChildGroup" { $stats.child_groups++ }
            "ChildSecurityPolicy" { $stats.child_security_policies++ }
            "ChildDomain" { $stats.child_domains++ }
            "ChildPolicyContextProfile" { $stats.child_context_profiles++ }
            "ChildSegment" { $stats.child_segments++ }
            "ChildTag" { $stats.child_tags++ }
            default { $stats.unknown_children++ }
          }
        }
      }

      return $stats
    }
    catch {
      $this.logger.LogError("Failed to get hierarchical statistics: $($_.Exception.Message)", "HierarchicalStructure")
      return [PSCustomObject]@{}
    }
  }

  #endregion
}
