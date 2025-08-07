# NSXConfigValidator.ps1
# Service for validating NSX-T configuration JSON against API schema and best practices
# Prevents 400 Bad Request errors by ensuring proper JSON structure and content

class NSXConfigValidator {
  hidden [object] $logger
  hidden [object] $authService
  hidden [object] $openAPISchemaService
  hidden [object] $apiSchemas
  hidden [object] $validationRules
  hidden [string] $nsxManager

  # Constructor with OpenAPISchemaService dependency injection
  NSXConfigValidator([object] $loggingService, [object] $authService, [object] $openAPISchemaService = $null) {
    $this.logger = $loggingService
    $this.authService = $authService
    $this.openAPISchemaService = $openAPISchemaService
    $this.apiSchemas = [PSCustomObject]@{}
    $this.validationRules = [PSCustomObject]@{}
    $this.initialiseValidationRules()

    # Log successful initialization with method verification
    $this.logger.LogInfo("NSXConfigValidator initialized with GetOpenAPISchemas method available", "ConfigValidator")
  }

  # initialise validation rules based on NSX-T API documentation
  [void] initialiseValidationRules() {
    $this.validationRules = @{
      # Required fields for different resource types
      "Service"                = @{
        required_fields        = @("resource_type", "id", "display_name", "service_entries")
        allowed_resource_types = @("Service")
        parent_resource_type   = "ChildService"
      }
      "Group"                  = @{
        required_fields        = @("resource_type", "id", "display_name")
        allowed_resource_types = @("Group")
        parent_resource_type   = "ChildGroup"
      }
      "SecurityPolicy"         = @{
        required_fields        = @("resource_type", "id", "display_name")
        allowed_resource_types = @("SecurityPolicy")
        parent_resource_type   = "ChildSecurityPolicy"
      }
      "ContextProfile"         = @{
        required_fields        = @("resource_type", "id", "display_name")
        allowed_resource_types = @("ContextProfile")
        parent_resource_type   = "ChildContextProfile"
      }
      # Service entry validation
      "L4PortSetServiceEntry"  = @{
        required_fields   = @("resource_type", "id", "display_name", "l4_protocol", "destination_ports")
        allowed_protocols = @("TCP", "UDP")
      }
      # Domain reference validation
      "ChildResourceReference" = @{
        required_fields      = @("resource_type", "target_type", "id")
        allowed_target_types = @("Domain")
      }
    }
  }

  # Get OpenAPI/Swagger documentation from NSX Manager
  [object] GetAPIDocumentation([string] $nsxManager, [object] $credential) {
    try {
      $this.logger.LogInfo("Retrieving API documentation from NSX Manager: $nsxManager", "ConfigValidator")

      # NSX-T API documentation endpoints (swagger removed due to 500 errors)
      $apiEndpoints = [PSCustomObject]@{
        "openapi"        = "/api/v1/spec/openapi/nsx_policy_api.json"
        "policy_openapi" = "/policy/api/v1/spec/openapi/nsx_policy_api.json"
      }

      $documentation = [PSCustomObject]@{}

      foreach ($endpointName in $apiEndpoints.Keys) {
        $endpoint = $apiEndpoints[$endpointName]
        $url = "https://$nsxManager$endpoint"

        try {
          $this.logger.LogInfo("Fetching $endpointName from: $url", "ConfigValidator")

          $headers = [PSCustomObject]@{
            Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($credential.UserName):$($credential.GetNetworkCredential().Password)"))
            Accept        = "application/json"
          }

          $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -UseBasicParsing
          $documentation[$endpointName] = $response
          $this.logger.LogInfo("Successfully retrieved $endpointName documentation", "ConfigValidator")
        }
        catch {
          $this.logger.LogWarning("Failed to retrieve $endpointName : $($_.Exception.Message)", "ConfigValidator")
        }
      }

      return $documentation
    }
    catch {
      $this.logger.LogError("Failed to retrieve API documentation: $($_.Exception.Message)", "ConfigValidator")
      return [PSCustomObject]@{}
    }
  }

  # Validate JSON structure and syntax
  [object] ValidateJSONStructure([string] $jsonContent) {
    try {
      $this.logger.LogInfo("Validating JSON structure and syntax", "ConfigValidator")

      # Test JSON parsing
      $parsedJson = $jsonContent | ConvertFrom-Json

      # Handle different JSON structures
      $configData = $null
      $metadata = $null

      # Check if we have the metadata/configuration wrapper structure
      if ($parsedJson.metadata -and $parsedJson.configuration) {
        $this.logger.LogInfo("Found metadata/configuration wrapper structure", "ConfigValidator")
        $metadata = $parsedJson.metadata
        $configData = $parsedJson.configuration
      }
      # Check if we have direct infra structure
      elseif ($parsedJson.infra) {
        $this.logger.LogInfo("Found direct infra structure", "ConfigValidator")
        $configData = $parsedJson
      }
      # Check if configuration has infra nested
      elseif ($parsedJson.configuration -and $parsedJson.configuration.infra) {
        $this.logger.LogInfo("Found nested infra in configuration", "ConfigValidator")
        $configData = $parsedJson.configuration
      }
      else {
        return @{
          valid    = $false
          errors   = @("Invalid JSON structure: Expected either 'infra' object or 'metadata/configuration' wrapper with 'infra' object")
          warnings = @()
        }
      }

      # Validate infra object exists
      if (-not $configData.infra) {
        return @{
          valid    = $false
          errors   = @("Missing required 'infra' object in configuration data")
          warnings = @()
        }
      }

      # Validate infra object structure
      $infraObj = $configData.infra
      if (-not $infraObj.resource_type -or $infraObj.resource_type -ne "Infra") {
        return @{
          valid    = $false
          errors   = @("Infra object must have resource_type = 'Infra'")
          warnings = @()
        }
      }

      if (-not $infraObj.children) {
        return @{
          valid    = $false
          errors   = @("Infra object must contain 'children' array")
          warnings = @()
        }
      }

      # Check if objects need hierarchical wrapping
      $needsWrapping = $false
      $wrappedChildren = @()

      foreach ($child in $infraObj.children) {
        $wrappedChild = $this.EnsureHierarchicalWrapper($child)
        if ($wrappedChild.needsWrapping) {
          $needsWrapping = $true
        }
        $wrappedChildren += $wrappedChild.object
      }

      # If wrapping was needed, create corrected structure
      $correctedJson = $parsedJson
      if ($needsWrapping) {
        $this.logger.LogInfo("Auto-wrapping objects for NSX hierarchical API compliance", "ConfigValidator")

        # Update the children with wrapped objects
        if ($parsedJson.metadata -and $parsedJson.configuration) {
          $correctedJson.configuration.infra.children = $wrappedChildren
        }
        else {
          $correctedJson.infra.children = $wrappedChildren
        }
      }

      $this.logger.LogInfo("JSON structure validation passed", "ConfigValidator")
      return @{
        valid          = $true
        errors         = @()
        warnings       = if ($needsWrapping) { @("Auto-wrapped objects for NSX hierarchical API compliance") } else { @() }
        parsed_json    = $correctedJson
        needs_wrapping = $needsWrapping
        original_json  = $parsedJson
      }
    }
    catch {
      return @{
        valid    = $false
        errors   = @("Invalid JSON syntax: $($_.Exception.Message)")
        warnings = @()
      }
    }
  }

  # Ensure object has proper hierarchical wrapper for NSX Policy API
  [object] EnsureHierarchicalWrapper([object] $obj) {
    try {
      if (-not $obj.resource_type) {
        $this.logger.LogWarning("Object missing resource_type, skipping wrapper check", "ConfigValidator")
        return @{
          object        = $obj
          needsWrapping = $false
        }
      }

      $resourceType = $obj.resource_type

      # Check if object is already properly wrapped
      if ($resourceType.StartsWith("Child")) {
        $this.logger.LogDebug("Object already has hierarchical wrapper: $resourceType", "ConfigValidator")
        return @{
          object        = $obj
          needsWrapping = $false
        }
      }

      # Object needs wrapping - apply hierarchical container
      $this.logger.LogInfo("Wrapping object of type '$resourceType' for hierarchical API", "ConfigValidator")

      $wrappedObject = switch ($resourceType) {
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
        "Domain" {
          @{
            resource_type = "ChildDomain"
            Domain        = $obj
          }
        }
        "PolicyContextProfile" {
          @{
            resource_type        = "ChildPolicyContextProfile"
            PolicyContextProfile = $obj
          }
        }
        "ContextProfile" {
          @{
            resource_type        = "ChildPolicyContextProfile"
            PolicyContextProfile = $obj
          }
        }
        default {
          $this.logger.LogWarning("Unknown resource type '$resourceType', using generic wrapper", "ConfigValidator")
          @{
            resource_type = "Child$resourceType"
            $resourceType = $obj
          }
        }
      }

      return @{
        object        = $wrappedObject
        needsWrapping = $true
      }
    }
    catch {
      $this.logger.LogError("Failed to ensure hierarchical wrapper: $($_.Exception.Message)", "ConfigValidator")
      return @{
        object        = $obj
        needsWrapping = $false
      }
    }
  }

  # Validate configuration objects against NSX-T API schema
  [object] ValidateConfiguration([object] $configObject) {
    try {
      $this.logger.LogInfo("Validating configuration against NSX-T API schema", "ConfigValidator")

      $errors = @()
      $warnings = @()

      # Validate infra children
      foreach ($child in $configObject.infra.children) {
        $childValidation = $this.ValidateChildObject($child)
        if ($childValidation.errors.Count -gt 0) {
          $errors += $childValidation.errors
        }
        if ($childValidation.warnings.Count -gt 0) {
          $warnings += $childValidation.warnings
        }
      }

      $isValid = $errors.Count -eq 0

      $this.logger.LogInfo("Configuration validation completed - Valid: $isValid, Errors: $($errors.Count), Warnings: $($warnings.Count)", "ConfigValidator")

      return @{
        valid    = $isValid
        errors   = $errors
        warnings = $warnings
      }
    }
    catch {
      $this.logger.LogError("Configuration validation failed: $($_.Exception.Message)", "ConfigValidator")
      return @{
        valid    = $false
        errors   = @("Validation error: $($_.Exception.Message)")
        warnings = @()
      }
    }
  }

  # Validate configuration objects against OpenAPI schema
  [object] ValidateAgainstOpenAPISchema([object] $configObject, [object] $apiDocumentation) {
    try {
      $this.logger.LogInfo("Validating configuration against OpenAPI schema", "ConfigValidator")

      $errors = @()
      $warnings = @()

      # Use policy_openapi as the primary schema source
      $schema = $apiDocumentation.policy_openapi
      if (-not $schema) {
        $warnings += "OpenAPI schema not available, using basic validation"
        return @{
          valid    = $true
          errors   = $errors
          warnings = $warnings
        }
      }

      # Validate each child object against the schema
      foreach ($child in $configObject.infra.children) {
        $childValidation = $this.ValidateChildAgainstSchema($child, $schema)
        if ($childValidation.errors.Count -gt 0) {
          $errors += $childValidation.errors
        }
        if ($childValidation.warnings.Count -gt 0) {
          $warnings += $childValidation.warnings
        }
      }

      $isValid = $errors.Count -eq 0

      $this.logger.LogInfo("OpenAPI schema validation completed - Valid: $isValid, Errors: $($errors.Count), Warnings: $($warnings.Count)", "ConfigValidator")

      return @{
        valid    = $isValid
        errors   = $errors
        warnings = $warnings
      }
    }
    catch {
      $this.logger.LogError("OpenAPI schema validation failed: $($_.Exception.Message)", "ConfigValidator")
      return @{
        valid    = $false
        errors   = @("OpenAPI validation error: $($_.Exception.Message)")
        warnings = @()
      }
    }
  }

  # Validate individual child object against OpenAPI schema
  [object] ValidateChildAgainstSchema([object] $childObject, [object] $schema) {
    $errors = @()
    $warnings = @()

    try {
      $resourceType = $childObject.resource_type

      if (-not $resourceType) {
        $errors += "Child object missing required 'resource_type' field"
        return [PSCustomObject]@{ errors = $errors; warnings = $warnings }
      }

      # Check if resource type exists in schema
      if ($schema.components -and $schema.components.schemas) {
        $schemaDefinition = $schema.components.schemas[$resourceType]

        if (-not $schemaDefinition) {
          $warnings += "Resource type '$resourceType' not found in OpenAPI schema"
        }
        else {
          # Validate required properties
          if ($schemaDefinition.required) {
            foreach ($requiredField in $schemaDefinition.required) {
              if (-not $childObject.PSObject.Properties.Name.Contains($requiredField)) {
                $errors += "Resource type '$resourceType' missing required field: $requiredField"
              }
            }
          }

          # Validate specific object types
          switch ($resourceType) {
            "ChildService" {
              if ($childObject.Service) {
                $serviceValidation = $this.ValidateServiceAgainstSchema($childObject.Service, $schema)
                $errors += $serviceValidation.errors
                $warnings += $serviceValidation.warnings
              }
            }
            "ChildGroup" {
              if ($childObject.Group) {
                $groupValidation = $this.ValidateGroupAgainstSchema($childObject.Group, $schema)
                $errors += $groupValidation.errors
                $warnings += $groupValidation.warnings
              }
            }
            "ChildSecurityPolicy" {
              if ($childObject.SecurityPolicy) {
                $policyValidation = $this.ValidateSecurityPolicyAgainstSchema($childObject.SecurityPolicy, $schema)
                $errors += $policyValidation.errors
                $warnings += $policyValidation.warnings
              }
            }
          }
        }
      }
    }
    catch {
      $errors += "Error validating child object against schema: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Service object against OpenAPI schema
  [object] ValidateServiceAgainstSchema([object] $serviceObject, [object] $schema) {
    $errors = @()
    $warnings = @()

    try {
      # Check Service schema
      $serviceSchema = $schema.components.schemas["Service"]
      if ($serviceSchema -and $serviceSchema.required) {
        foreach ($requiredField in $serviceSchema.required) {
          if (-not $serviceObject.PSObject.Properties.Name.Contains($requiredField)) {
            $errors += "Service missing required field: $requiredField"
          }
        }
      }

      # Validate service entries
      if ($serviceObject.service_entries) {
        foreach ($entry in $serviceObject.service_entries) {
          $entryValidation = $this.ValidateServiceEntryAgainstSchema($entry, $schema)
          $errors += $entryValidation.errors
          $warnings += $entryValidation.warnings
        }
      }
    }
    catch {
      $errors += "Error validating Service object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate ServiceEntry object against OpenAPI schema
  [object] ValidateServiceEntryAgainstSchema([object] $serviceEntry, [object] $schema) {
    $errors = @()
    $warnings = @()

    try {
      $resourceType = $serviceEntry.resource_type

      if (-not $resourceType) {
        $errors += "ServiceEntry missing required 'resource_type' field"
        return [PSCustomObject]@{ errors = $errors; warnings = $warnings }
      }

      # Check ServiceEntry schema
      $entrySchema = $schema.components.schemas[$resourceType]
      if ($entrySchema -and $entrySchema.required) {
        foreach ($requiredField in $entrySchema.required) {
          if (-not $serviceEntry.PSObject.Properties.Name.Contains($requiredField)) {
            $errors += "ServiceEntry ($resourceType) missing required field: $requiredField"
          }
        }
      }

      # Validate L4PortSetServiceEntry specific fields
      if ($resourceType -eq "L4PortSetServiceEntry") {
        if ($serviceEntry.l4_protocol -and $serviceEntry.l4_protocol -notin @("TCP", "UDP")) {
          $errors += "L4PortSetServiceEntry has invalid l4_protocol: $($serviceEntry.l4_protocol). Must be TCP or UDP"
        }

        if ($serviceEntry.destination_ports) {
          foreach ($port in $serviceEntry.destination_ports) {
            if ($port -match "^\d+$") {
              $portNum = [int]$port
              if ($portNum -lt 1 -or $portNum -gt 65535) {
                $errors += "L4PortSetServiceEntry has invalid port: $port. Must be between 1-65535"
              }
            }
            elseif (-not ($port -match "^\d+-\d+$")) {
              $errors += "L4PortSetServiceEntry has invalid port format: $port. Must be single port or range (e.g., 80 or 80-90)"
            }
          }
        }
      }
    }
    catch {
      $errors += "Error validating ServiceEntry: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Group object against OpenAPI schema
  [object] ValidateGroupAgainstSchema([object] $groupObject, [object] $schema) {
    $errors = @()
    $warnings = @()

    try {
      # Check Group schema
      $groupSchema = $schema.components.schemas["Group"]
      if ($groupSchema -and $groupSchema.required) {
        foreach ($requiredField in $groupSchema.required) {
          if (-not $groupObject.PSObject.Properties.Name.Contains($requiredField)) {
            $errors += "Group missing required field: $requiredField"
          }
        }
      }

      # Validate group expressions
      if ($groupObject.expression) {
        foreach ($expr in $groupObject.expression) {
          if (-not $expr.resource_type) {
            $errors += "Group expression missing required 'resource_type' field"
          }
        }
      }
    }
    catch {
      $errors += "Error validating Group object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate SecurityPolicy object against OpenAPI schema
  [object] ValidateSecurityPolicyAgainstSchema([object] $policyObject, [object] $schema) {
    $errors = @()
    $warnings = @()

    try {
      # Check SecurityPolicy schema
      $policySchema = $schema.components.schemas["SecurityPolicy"]
      if ($policySchema -and $policySchema.required) {
        foreach ($requiredField in $policySchema.required) {
          if (-not $policyObject.PSObject.Properties.Name.Contains($requiredField)) {
            $errors += "SecurityPolicy missing required field: $requiredField"
          }
        }
      }

      # Validate security policy rules
      if ($policyObject.rules) {
        foreach ($rule in $policyObject.rules) {
          if (-not $rule.resource_type) {
            $errors += "SecurityPolicy rule missing required 'resource_type' field"
          }
        }
      }
    }
    catch {
      $errors += "Error validating SecurityPolicy object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate individual child objects
  [object] ValidateChildObject([object] $childObject) {
    $errors = @()
    $warnings = @()

    try {
      $resourceType = $childObject.resource_type

      if (-not $resourceType) {
        $errors += "Child object missing required 'resource_type' field"
        return [PSCustomObject]@{ errors = $errors; warnings = $warnings }
      }

      switch ($resourceType) {
        "ChildService" {
          $validation = $this.ValidateServiceObject($childObject)
          $errors += $validation.errors
          $warnings += $validation.warnings
        }
        "ChildGroup" {
          $validation = $this.ValidateGroupObject($childObject)
          $errors += $validation.errors
          $warnings += $validation.warnings
        }
        "ChildResourceReference" {
          $validation = $this.ValidateResourceReference($childObject)
          $errors += $validation.errors
          $warnings += $validation.warnings
        }
        "ChildSecurityPolicy" {
          $validation = $this.ValidateSecurityPolicyObject($childObject)
          $errors += $validation.errors
          $warnings += $validation.warnings
        }
        default {
          $warnings += "Unknown child resource type: $resourceType"
        }
      }
    }
    catch {
      $errors += "Error validating child object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Service objects
  [object] ValidateServiceObject([object] $serviceChild) {
    $errors = @()
    $warnings = @()

    try {
      if (-not $serviceChild.Service) {
        $errors += "ChildService must contain a 'Service' object"
        return [PSCustomObject]@{ errors = $errors; warnings = $warnings }
      }

      $service = $serviceChild.Service
      $rules = $this.validationRules["Service"]

      # Check required fields
      foreach ($field in $rules.required_fields) {
        if (-not $service.$field) {
          $errors += "Service object missing required field: $field"
        }
      }

      # Validate service entries
      if ($service.service_entries) {
        foreach ($entry in $service.service_entries) {
          $entryValidation = $this.ValidateServiceEntry($entry)
          $errors += $entryValidation.errors
          $warnings += $entryValidation.warnings
        }
      }

      # Check for deprecated fields
      if ($service.marked_for_delete) {
        $warnings += "Service '$($service.id)' contains deprecated 'marked_for_delete' field"
      }
    }
    catch {
      $errors += "Error validating Service object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Service Entry objects
  [object] ValidateServiceEntry([object] $serviceEntry) {
    $errors = @()
    $warnings = @()

    try {
      $rules = $this.validationRules["L4PortSetServiceEntry"]

      # Check required fields
      foreach ($field in $rules.required_fields) {
        if (-not $serviceEntry.$field) {
          $errors += "ServiceEntry missing required field: $field"
        }
      }

      # Validate protocol
      if ($serviceEntry.l4_protocol -and $serviceEntry.l4_protocol -notin $rules.allowed_protocols) {
        $errors += "ServiceEntry has invalid l4_protocol: $($serviceEntry.l4_protocol). Allowed: $($rules.allowed_protocols -join ', ')"
      }

      # Validate ports
      if ($serviceEntry.destination_ports) {
        foreach ($port in $serviceEntry.destination_ports) {
          if (-not ($port -match '^\d+$' -and [int]$port -ge 1 -and [int]$port -le 65535)) {
            $errors += "ServiceEntry has invalid destination port: $port"
          }
        }
      }

      # Check for deprecated fields
      if ($serviceEntry.marked_for_delete) {
        $warnings += "ServiceEntry '$($serviceEntry.id)' contains deprecated 'marked_for_delete' field"
      }
    }
    catch {
      $errors += "Error validating ServiceEntry: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Group objects
  [object] ValidateGroupObject([object] $groupChild) {
    $errors = @()
    $warnings = @()

    try {
      if (-not $groupChild.Group) {
        $errors += "ChildGroup must contain a 'Group' object"
        return [PSCustomObject]@{ errors = $errors; warnings = $warnings }
      }

      $group = $groupChild.Group
      $rules = $this.validationRules["Group"]

      # Check required fields
      foreach ($field in $rules.required_fields) {
        if (-not $group.$field) {
          $errors += "Group object missing required field: $field"
        }
      }

      # Validate expressions if present
      if ($group.expression) {
        $expressionValidation = $this.ValidateGroupExpression($group.expression)
        $errors += $expressionValidation.errors
        $warnings += $expressionValidation.warnings
      }

      # Check for deprecated fields
      if ($group.marked_for_delete) {
        $warnings += "Group '$($group.id)' contains deprecated 'marked_for_delete' field"
      }
    }
    catch {
      $errors += "Error validating Group object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Group Expression
  [object] ValidateGroupExpression([array] $expression) {
    $errors = @()
    $warnings = @()

    try {
      foreach ($item in $expression) {
        if ($item.resource_type -eq "Condition") {
          # Validate condition
          if (-not $item.member_type -or -not $item.key -or -not $item.operator -or -not $item.value) {
            $errors += "Condition missing required fields (member_type, key, operator, value)"
          }

          # Check for deprecated fields
          if ($item.marked_for_delete) {
            $warnings += "Condition contains deprecated 'marked_for_delete' field"
          }
        }
        elseif ($item.resource_type -eq "ConjunctionOperator") {
          # Validate conjunction
          if (-not $item.conjunction_operator -or $item.conjunction_operator -notin @("AND", "OR")) {
            $errors += "ConjunctionOperator must be 'AND' or 'OR'"
          }

          # Check for deprecated fields
          if ($item.marked_for_delete) {
            $warnings += "ConjunctionOperator contains deprecated 'marked_for_delete' field"
          }
        }
      }
    }
    catch {
      $errors += "Error validating Group expression: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Resource Reference objects
  [object] ValidateResourceReference([object] $resourceRef) {
    $errors = @()
    $warnings = @()

    try {
      $rules = $this.validationRules["ChildResourceReference"]

      # Check required fields
      foreach ($field in $rules.required_fields) {
        if (-not $resourceRef.$field) {
          $errors += "ChildResourceReference missing required field: $field"
        }
      }

      # Validate target_type
      if ($resourceRef.target_type -and $resourceRef.target_type -notin $rules.allowed_target_types) {
        $errors += "ChildResourceReference has invalid target_type: $($resourceRef.target_type). Allowed: $($rules.allowed_target_types -join ', ')"
      }

      # Validate children if present
      if ($resourceRef.children) {
        foreach ($child in $resourceRef.children) {
          $childValidation = $this.ValidateChildObject($child)
          $errors += $childValidation.errors
          $warnings += $childValidation.warnings
        }
      }
    }
    catch {
      $errors += "Error validating ResourceReference: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Validate Security Policy objects
  [object] ValidateSecurityPolicyObject([object] $policyChild) {
    $errors = @()
    $warnings = @()

    try {
      if (-not $policyChild.SecurityPolicy) {
        $errors += "ChildSecurityPolicy must contain a 'SecurityPolicy' object"
        return [PSCustomObject]@{ errors = $errors; warnings = $warnings }
      }

      $policy = $policyChild.SecurityPolicy
      $rules = $this.validationRules["SecurityPolicy"]

      # Check required fields
      foreach ($field in $rules.required_fields) {
        if (-not $policy.$field) {
          $errors += "SecurityPolicy object missing required field: $field"
        }
      }

      # Check for deprecated fields
      if ($policy.marked_for_delete) {
        $warnings += "SecurityPolicy '$($policy.id)' contains deprecated 'marked_for_delete' field"
      }
    }
    catch {
      $errors += "Error validating SecurityPolicy object: $($_.Exception.Message)"
    }

    return @{
      errors   = $errors
      warnings = $warnings
    }
  }

  # Filter out system-managed objects that shouldn't be created/updated
  [object] FilterSystemObjects([object] $configObject) {
    try {
      $this.logger.LogInfo("Filtering out system-managed objects from configuration", "ConfigValidator")

      # List of system-managed resource types that should not be created/updated
      $systemResourceTypes = @(
        "ChildPolicyContextProfile",
        "PolicyContextProfile"
      )

      # Deep clone the configuration to avoid modifying the original
      $filteredConfig = $configObject | ConvertTo-Json -Depth 50 | ConvertFrom-Json

      # Remove system objects recursively
      $this.RemoveSystemObjectsRecursive($filteredConfig, $systemResourceTypes)

      $this.logger.LogInfo("System objects filtered successfully", "ConfigValidator")
      return $filteredConfig
    }
    catch {
      $this.logger.LogError("Failed to filter system objects: $($_.Exception.Message)", "ConfigValidator")
      return $configObject
    }
  }

  # Recursively remove system objects
  hidden [void] RemoveSystemObjectsRecursive([object] $obj, [string[]] $systemResourceTypes) {
    if ($obj -eq $null) { return }

    if ($obj -is [PSCustomObject]) {
      # Check if this object has children array
      if ($obj.children -and $obj.children -is [array]) {
        $childrenToKeep = @()
        foreach ($child in $obj.children) {
          if ($child.resource_type -and $child.resource_type -in $systemResourceTypes) {
            $this.logger.LogDebug("Filtering out system object: $($child.resource_type)", "ConfigValidator")
            continue
          }
          $childrenToKeep += $child
          # Recursively process remaining children
          $this.RemoveSystemObjectsRecursive($child, $systemResourceTypes)
        }
        $obj.children = $childrenToKeep
      }

      # Process other properties recursively
      foreach ($property in $obj.PSObject.Properties) {
        if ($property.Name -ne "children" -and $property.Value -ne $null) {
          $this.RemoveSystemObjectsRecursive($property.Value, $systemResourceTypes)
        }
      }
    }
    elseif ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string]) {
      # Process arrays
      foreach ($item in $obj) {
        if ($item -ne $null) {
          $this.RemoveSystemObjectsRecursive($item, $systemResourceTypes)
        }
      }
    }
  }

  # Clean deprecated fields from configuration
  [object] CleanDeprecatedFields([object] $configObject) {
    try {
      $this.logger.LogInfo("Cleaning deprecated fields from configuration", "ConfigValidator")

      # Convert to JSON and back to ensure we have a fresh object
      $jsonString = $configObject | ConvertTo-Json -Depth 20

      # regex patterns to handle all variations of marked_for_delete
      # Pattern 1: Remove "marked_for_delete": "value" with optional comma handling
      $cleanedJson = $jsonString -replace '(?:,\s*)?"marked_for_delete":\s*"[^"]*"(?:\s*,)?', ''

      # Pattern 2: Remove "marked_for_delete": value (without quotes) with optional comma handling
      $cleanedJson = $cleanedJson -replace '(?:,\s*)?"marked_for_delete":\s*[^,}\]]*(?:\s*,)?', ''

      # Pattern 3: Handle edge cases where marked_for_delete is the only field
      $cleanedJson = $cleanedJson -replace '{\s*"marked_for_delete":\s*"[^"]*"\s*,', '{'
      $cleanedJson = $cleanedJson -replace '{\s*"marked_for_delete":\s*[^,}\]]*\s*,', '{'

      # Pattern 4: Handle marked_for_delete at end of objects
      $cleanedJson = $cleanedJson -replace ',\s*"marked_for_delete":\s*"[^"]*"\s*}', '}'
      $cleanedJson = $cleanedJson -replace ',\s*"marked_for_delete":\s*[^,}\]]*\s*}', '}'

      # Fix PolicyContextProfile app_ids field (NSX-T expects app_id not app_ids)
      $cleanedJson = $cleanedJson -replace '"app_ids":', '"app_id":'

      # Fix PolicyContextProfile structure - move app_id to attributes array
      $cleanedJson = $this.FixPolicyContextProfileStructure($cleanedJson)

      # Clean up any double commas or trailing commas that might result
      $cleanedJson = $cleanedJson -replace ',\s*,', ','
      $cleanedJson = $cleanedJson -replace ',\s*}', '}'
      $cleanedJson = $cleanedJson -replace ',\s*]', ']'

      # Remove empty lines and extra whitespace
      $cleanedJson = $cleanedJson -replace '\n\s*\n', "`n"

      # Convert back to object
      $cleanedConfig = $cleanedJson | ConvertFrom-Json

      $this.logger.LogInfo("Deprecated fields cleaned successfully using regex approach", "ConfigValidator")
      return $cleanedConfig
    }
    catch {
      $this.logger.LogError("regex cleanup failed: $($_.Exception.Message)", "ConfigValidator")

      # Fallback to recursive approach
      try {
        $this.logger.LogInfo("Attempting fallback recursive cleanup", "ConfigValidator")
        $fallbackConfig = $configObject | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $this.RemoveMarkedForDeleteRecursive($fallbackConfig)
        $this.logger.LogInfo("Fallback recursive cleanup completed successfully", "ConfigValidator")
        return $fallbackConfig
      }
      catch {
        $this.logger.LogError("Fallback cleanup also failed: $($_.Exception.Message)", "ConfigValidator")
        $this.logger.LogWarning("Returning original configuration - deprecated fields may still be present", "ConfigValidator")
        return $configObject
      }
    }
  }

  # Fix PolicyContextProfile structure - move app_id and domain_names to attributes array
  hidden [string] FixPolicyContextProfileStructure([string] $jsonString) {
    try {
      $this.logger.LogInfo("Fixing PolicyContextProfile structure - moving app_id and domain_names to attributes array", "ConfigValidator")

      # Parse JSON to work with objects
      $config = $jsonString | ConvertFrom-Json

      # Recursively find and fix PolicyContextProfile objects
      $this.FixPolicyContextProfileRecursive($config)

      # Convert back to compressed JSON
      $fixedJson = $config | ConvertTo-Json -Depth 50 -Compress

      $this.logger.LogInfo("PolicyContextProfile structure fixed successfully", "ConfigValidator")
      return $fixedJson
    }
    catch {
      $this.logger.LogError("Failed to fix PolicyContextProfile structure: $($_.Exception.Message)", "ConfigValidator")
      return $jsonString
    }
  }

  # Recursively fix PolicyContextProfile objects
  hidden [void] FixPolicyContextProfileRecursive([object] $obj) {
    if ($obj -eq $null) { return }

    if ($obj -is [PSCustomObject]) {
      # Check if this is a PolicyContextProfile object and needs fixing
      if ($obj.resource_type -eq "PolicyContextProfile" -and ($obj.app_id -or $obj.domain_names)) {
        $this.logger.LogDebug("Found PolicyContextProfile with direct fields, moving to attributes", "ConfigValidator")

        # Store values before removing them
        $appIdValue = $obj.app_id
        $domainNamesValue = $obj.domain_names

        # Remove the direct properties first to prevent recursion issues
        if ($obj.app_id) { $obj.PSObject.Properties.Remove("app_id") }
        if ($obj.domain_names) { $obj.PSObject.Properties.Remove("domain_names") }

        # Ensure attributes array exists
        if (-not $obj.attributes) {
          $obj | Add-Member -MemberType NoteProperty -Name "attributes" -Value @()
        }

        # Convert existing attributes to array if it's not already
        $existingAttributes = if ($obj.attributes -is [array]) { $obj.attributes } else { @($obj.attributes) }

        # Ensure all existing attribute values are string arrays (NSX-T requirement)
        for ($i = 0; $i -lt $existingAttributes.Count; $i++) {
          if ($existingAttributes[$i].value -isnot [array]) {
            $existingAttributes[$i].value = @($existingAttributes[$i].value)
          }
        }

        # Create APP_ID attribute if app_id was present
        if ($appIdValue) {
          # Ensure APP_ID value is an array
          $appIdArray = if ($appIdValue -is [array]) { $appIdValue } else { @($appIdValue) }
          $appIdAttribute = [PSCustomObject]@{
            key   = "APP_ID"
            value = $appIdArray
          }
          $existingAttributes = $existingAttributes + $appIdAttribute
          $this.logger.LogDebug("Moved app_id to APP_ID attribute", "ConfigValidator")
        }

        # Create DOMAIN_NAME attribute if domain_names was present
        if ($domainNamesValue) {
          # Ensure DOMAIN_NAME value is an array
          $domainNamesArray = if ($domainNamesValue -is [array]) { $domainNamesValue } else { @($domainNamesValue) }
          $domainNameAttribute = [PSCustomObject]@{
            key   = "DOMAIN_NAME"
            value = $domainNamesArray
          }
          $existingAttributes = $existingAttributes + $domainNameAttribute
          $this.logger.LogDebug("Moved domain_names to DOMAIN_NAME attribute", "ConfigValidator")
        }

        # Update attributes array
        $obj.attributes = $existingAttributes

        $this.logger.LogDebug("Successfully moved direct fields to attributes array for PolicyContextProfile", "ConfigValidator")
      }

      # Recursively process properties, but skip attributes array for PolicyContextProfile to prevent infinite recursion
      foreach ($property in $obj.PSObject.Properties) {
        if ($property.Value -ne $null) {
          # Skip recursing into attributes array for PolicyContextProfile to prevent circular references
          if ($obj.resource_type -eq "PolicyContextProfile" -and $property.Name -eq "attributes") {
            continue
          }
          $this.FixPolicyContextProfileRecursive($property.Value)
        }
      }
    }
    elseif ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string]) {
      # Process arrays
      foreach ($item in $obj) {
        if ($item -ne $null) {
          $this.FixPolicyContextProfileRecursive($item)
        }
      }
    }
  }

  # Recursively remove marked_for_delete fields (fallback method)
  [void] RemoveMarkedForDeleteRecursive([object] $obj) {
    try {
      if ($obj -is [PSCustomObject]) {
        # Handle PowerShell custom objects
        $propertiesToRemove = @()
        foreach ($property in $obj.PSObject.Properties) {
          if ($property.Name -eq "marked_for_delete") {
            $propertiesToRemove += $property.Name
          }
          elseif ($property.Value -ne $null) {
            $this.RemoveMarkedForDeleteRecursive($property.Value)
          }
        }
        foreach ($propName in $propertiesToRemove) {
          $obj.PSObject.Properties.Remove($propName)
        }
      }
      elseif ($obj -is [System.Collections.IDictionary]) {
        # Handle hashtables and dictionaries
        $keysToRemove = @()
        foreach ($key in $obj.Keys) {
          if ($key -eq "marked_for_delete") {
            $keysToRemove += $key
          }
          elseif ($obj[$key] -ne $null) {
            $this.RemoveMarkedForDeleteRecursive($obj[$key])
          }
        }
        foreach ($key in $keysToRemove) {
          $obj.Remove($key)
        }
      }
      elseif ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string]) {
        # Handle arrays and lists
        foreach ($item in $obj) {
          if ($item -ne $null) {
            $this.RemoveMarkedForDeleteRecursive($item)
          }
        }
      }
    }
    catch {
      $this.logger.LogWarning("Error in recursive cleanup for object type $($obj.GetType()): $($_.Exception.Message)", "ConfigValidator")
    }
  }

  # Save payload files to data directory for inspection
  [object] SavePayloadFiles([object] $cleanedConfig, [object] $tempConfig, [string] $nsxManager, [string] $nsxDomain = "default") {
    try {
      $this.logger.LogInfo("Saving payload files to data directory with standardized naming", "ConfigValidator")

      # Get standard naming service from factory using invoke-expression to avoid early type resolution
      $factoryMethod = "CoreServiceFactory"
      $namingService = Invoke-Expression "[$factoryMethod]::GetStandardFileNamingService()"

      # Determine data directory path - use current working directory as base
      $currentPath = (Get-Location).Path

      # Check if we're in tools directory and adjust path accordingly
      $dataDir = if ($currentPath -like "*tools*") {
        Join-Path (Split-Path $currentPath -Parent) "data"
      }
      else {
        Join-Path $currentPath "data"
      }

      $this.logger.LogInfo("Current path: $currentPath", "ConfigValidator")
      $this.logger.LogInfo("Data directory: $dataDir", "ConfigValidator")

      # Create data directory if it doesn't exist
      if (-not (Test-Path $dataDir)) {
        New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
        $this.logger.LogInfo("Created data directory: $dataDir", "ConfigValidator")
      }

      # Get manager-specific directory
      $managerDir = $namingService.GetManagerDirectory($dataDir, $nsxManager)

      # Assign timestamp for file outputs
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

      # Save the actual configuration payload that will be sent to NSX-T (compressed)
      $payloadFileName = $namingService.GenerateStandardizedFileName($nsxManager, $nsxDomain, "payload-to-send")
      $payloadFile = Join-Path $managerDir $payloadFileName
      $cleanedConfig | ConvertTo-Json -Depth 50 -Compress | Out-File -FilePath $payloadFile -Encoding UTF8
      $this.logger.LogInfo("Payload saved to: $payloadFile", "ConfigValidator")

      # Save the complete temp config with metadata for reference (compressed)
      $tempConfigFileName = $namingService.GenerateStandardizedFileName($nsxManager, $nsxDomain, "temp-config")
      $tempConfigFile = Join-Path $managerDir $tempConfigFileName
      $tempConfig | ConvertTo-Json -Depth 50 -Compress | Out-File -FilePath $tempConfigFile -Encoding UTF8
      $this.logger.LogInfo("Complete config saved to: $tempConfigFile", "ConfigValidator")

      # Return file paths for caller to display
      return @{
        payload_file     = $payloadFile
        temp_config_file = $tempConfigFile
        timestamp        = $timestamp
        data_directory   = $dataDir
      }
    }
    catch {
      $this.logger.LogError("Failed to save payload files: $($_.Exception.Message)", "ConfigValidator")
      return @{
        payload_file     = $null
        temp_config_file = $null
        timestamp        = $null
        data_directory   = $null
        error            = $_.Exception.Message
      }
    }
  }

  # Main validation method
  [object] ValidateConfigurationFile([string] $filePath, [string] $nsxManager, [object] $credential) {
    try {
      $this.logger.LogInfo("Starting configuration validation for: $filePath", "ConfigValidator")

      # Read and validate JSON structure
      $jsonContent = Get-Content -Path $filePath -Raw
      $jsonContentConfig = $jsonContent.configuration | ConvertFrom-Json -Depth 50


      if ($jsonContentConfig) {
        $this.logger.LogInfo("JSON Content Config: $($jsonContentConfig.length)", "ConfigValidator")
        $structureValidation = $this.ValidateJSONStructure($jsonContentConfig)
      }
      else {
        $this.logger.LogInfo("JSON Content: $($jsonContent.length)", "ConfigValidator")
        $structureValidation = $this.ValidateJSONStructure($jsonContent)
      }


      if (-not $structureValidation.valid) {
        return $structureValidation
      }

      # Handle auto-wrapping if needed
      $correctedFilePath = $filePath
      if ($structureValidation.needs_wrapping) {
        $this.logger.LogInfo("Auto-wrapping was applied - saving corrected configuration", "ConfigValidator")

        # Generate corrected file path
        $fileInfo = Get-Item $filePath
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $correctedFileName = "$($fileInfo.BaseName)_wrapped_$timestamp.json"
        $correctedFilePath = Join-Path $fileInfo.DirectoryName $correctedFileName

        # Save corrected configuration (compressed)
        $structureValidation.parsed_json | ConvertTo-Json -Depth 50 -Compress | Out-File -FilePath $correctedFilePath -Encoding UTF8
        $this.logger.LogInfo("Corrected configuration saved to: $correctedFilePath", "ConfigValidator")

        # Add corrected file info to warnings
        $structureValidation.warnings += "Corrected configuration with hierarchical wrappers saved to: $correctedFileName"
      }

      # Clean deprecated fields BEFORE validation to fix PolicyContextProfile structure
      $this.logger.LogInfo("Cleaning deprecated fields before validation", "ConfigValidator")
      $cleanedConfig = $this.CleanDeprecatedFields($structureValidation.parsed_json)

      # Filter out system objects that shouldn't be created/updated via API
      $this.logger.LogInfo("Filtering system objects before API submission", "ConfigValidator")
      $filteredConfig = $this.FilterSystemObjects($cleanedConfig)

      # Validate against NSX-T API schema using cleaned config (before filtering system objects)
      $schemaValidation = $this.ValidateConfiguration($cleanedConfig)

      # Get API documentation for OpenAPI schema validation
      $apiDocs = $this.GetAPIDocumentation($nsxManager, $credential)

      # Perform OpenAPI schema validation using cleaned config (before filtering system objects)
      $openApiValidation = $this.ValidateAgainstOpenAPISchema($cleanedConfig, $apiDocs)

      # Combine results
      $result = [PSCustomObject]@{
        valid               = $structureValidation.valid -and $schemaValidation.valid -and $openApiValidation.valid
        errors              = $structureValidation.errors + $schemaValidation.errors + $openApiValidation.errors
        warnings            = $structureValidation.warnings + $schemaValidation.warnings + $openApiValidation.warnings
        parsed_json         = $structureValidation.parsed_json
        cleaned_config      = $cleanedConfig
        filtered_config     = $filteredConfig
        api_documentation   = $apiDocs
        needs_wrapping      = $structureValidation.needs_wrapping
        corrected_file_path = $correctedFilePath
        original_file_path  = $filePath
      }

      $this.logger.LogInfo("Configuration validation completed - Valid: $($result.valid), Errors: $($result.errors.Count), Warnings: $($result.warnings.Count)", "ConfigValidator")

      return $result
    }
    catch {
      $this.logger.LogError("Configuration validation failed: $($_.Exception.Message)", "ConfigValidator")
      return @{
        valid    = $false
        errors   = @("Validation failed: $($_.Exception.Message)")
        warnings = @()
      }
    }
  }

  # Get OpenAPI schemas using the injected OpenAPISchemaService
  [object] GetOpenAPISchemas() {
    try {
      $this.logger.LogInfo("Retrieving OpenAPI schemas using injected OpenAPISchemaService", "ConfigValidator")

      # Use injected OpenAPISchemaService
      if (-not $this.openAPISchemaService) {
        $this.logger.LogWarning("OpenAPISchemaService not injected - no schema validation available", "ConfigValidator")
        return [PSCustomObject]@{}
      }

      # Configure NSX Manager if we have one
      if ($this.nsxManager -and $this.authService) {
        try {
          $credential = $this.authService.GetCredential()
          if ($credential) {
            $this.openAPISchemaService.SetNSXManagerConfiguration($this.nsxManager, $credential)
            $this.logger.LogInfo("Configured OpenAPISchemaService with NSX Manager: $($this.nsxManager)", "ConfigValidator")
          }
        }
        catch {
          $this.logger.LogWarning("Failed to configure OpenAPISchemaService with NSX Manager: $($_.Exception.Message)", "ConfigValidator")
        }
      }

      # Get all schemas
      $schemas = $this.openAPISchemaService.GetAllSchemas()

      if ($schemas -and $schemas.Count -gt 0) {
        $this.logger.LogInfo("Successfully retrieved $($schemas.Count) OpenAPI schema types", "ConfigValidator")
        return $schemas
      }
      else {
        $this.logger.LogWarning("No OpenAPI schemas retrieved from service", "ConfigValidator")
        return [PSCustomObject]@{}
      }
    }
    catch {
      $this.logger.LogError("Failed to retrieve OpenAPI schemas: $($_.Exception.Message)", "ConfigValidator")
      return [PSCustomObject]@{}
    }
  }

  # Set NSX Manager for schema operations
  [void] SetNSXManager([string] $nsxManager) {
    $this.nsxManager = $nsxManager
    $this.logger.LogInfo("NSX Manager set for validator: $nsxManager", "ConfigValidator")
  }

  # Verify method availability for debugging production issues
  [object] VerifyMethodAvailability() {
    try {
      $methods = $this.GetType().GetMethods() | Where-Object { $_.Name -eq "GetOpenAPISchemas" }
      $hasMethod = $methods.Count -gt 0

      $result = [PSCustomObject]@{
        hasGetOpenAPISchemas = $hasMethod
        classType            = $this.GetType().Name
        classFullName        = $this.GetType().FullName
        assemblyLocation     = $this.GetType().Assembly.Location
        methodCount          = $methods.Count
        allMethods           = ($this.GetType().GetMethods() | Where-Object { $_.Name -like "*OpenAPI*" -or $_.Name -like "*Schema*" } | Select-Object -ExpandProperty Name) -join ", "
      }

      $this.logger.LogInfo("Method verification complete: GetOpenAPISchemas=$hasMethod, Type=$($result.classType)", "ConfigValidator")
      return $result
    }
    catch {
      $this.logger.LogError("Method verification failed: $($_.Exception.Message)", "ConfigValidator")
      return @{
        hasGetOpenAPISchemas = $false
        error                = $_.Exception.Message
      }
    }
  }
}
