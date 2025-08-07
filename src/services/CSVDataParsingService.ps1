# CSVDataParsingService.ps1
# Service for parsing CSV files and converting them to JSON format
# Extracts properties that align with NSX-T JSON object schemas

class CSVDataParsingService {
  hidden [object] $logger
  hidden [object] $schemaMapping
  hidden [string] $csvSourcePath
  hidden [string] $jsonOutputPath

  # Constructor
  CSVDataParsingService([object] $loggingService, [string] $csvPath = $null, [string] $jsonPath = $null) {
    $this.logger = $loggingService

    # Set default paths if not provided
    if ($csvPath) {
      $this.csvSourcePath = $csvPath
    }
    else {
      $scriptRoot = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
      $this.csvSourcePath = Join-Path $scriptRoot "data\csv"
    }

    if ($jsonPath) {
      $this.jsonOutputPath = $jsonPath
    }
    else {
      $scriptRoot = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
      $this.jsonOutputPath = Join-Path $scriptRoot "data\json"
    }

    # Ensure output directory exists
    if (-not (Test-Path $this.jsonOutputPath)) {
      New-Item -Path $this.jsonOutputPath -ItemType Directory -Force | Out-Null
      $this.logger.LogInfo("Created JSON output directory: $($this.jsonOutputPath)", "CSVParser")
    }

    # initialise schema mapping
    $this.initialiseSchemaMapping()

    $this.logger.LogInfo("CSVDataParsingService initialised", "CSVParser")
  }

  # initialise schema mapping for CSV columns to NSX-T JSON properties
  [void] initialiseSchemaMapping() {
    $this.schemaMapping = @{
      "Groups"               = @{
        file_pattern    = "Groups.csv"
        schema_type     = "Group"
        column_mapping  = @{
          "id"            = "id"
          "display_name"  = "display_name"
          "description"   = "description"
          "nsx_domain"    = "nsx_domain"
          "group_type"    = "group_type"
          "vm_criteria"   = "vm_criteria"
          "ip_criteria"   = "ip_criteria"
          "path_criteria" = "path_criteria"
          "condition_1"   = "condition_1"
          "condition_2"   = "condition_2"
          "condition_3"   = "condition_3"
          "condition_4"   = "condition_4"
          "condition_5"   = "condition_5"
          "condition_6"   = "condition_6"
          "condition_7"   = "condition_7"
          "condition_8"   = "condition_8"
          "condition_9"   = "condition_9"
          "condition_10"  = "condition_10"
        }
        required_fields = @("id", "display_name")
        resource_type   = "Group"
      }
      "FirewallRules"        = @{
        file_pattern    = "FirewallRules.csv"
        schema_type     = "Rule"
        column_mapping  = @{
          "id"                 = "id"
          "display_name"       = "display_name"
          "description"        = "description"
          "rule_id"            = "rule_id"
          "sequence_number"    = "sequence_number"
          "nsx_domain"         = "nsx_domain"
          "security_policy"    = "security_policy"
          "source_groups"      = "source_groups"
          "destination_groups" = "destination_groups"
          "services"           = "services"
          "direction"          = "direction"
          "action"             = "action"
          "applied_to"         = "applied_to"
          "log"                = "log"
          "disabled"           = "disabled"
          "notes"              = "notes"
          "ip_protocol"        = "ip_protocol"
          "scope"              = "scope"
        }
        required_fields = @("id", "display_name", "sequence_number")
        resource_type   = "Rule"
      }
      "SecurityPolicies"     = @{
        file_pattern    = "SecurityPolicies.csv"
        schema_type     = "SecurityPolicy"
        column_mapping  = @{
          "id"                    = "id"
          "display_name"          = "display_name"
          "description"           = "description"
          "nsx_domain"            = "nsx_domain"
          "category"              = "category"
          "precedence"            = "precedence"
          "stateful"              = "stateful"
          "tcp_strict"            = "tcp_strict"
          "connectivity_strategy" = "connectivity_strategy"
          "locked"                = "locked"
          "scope"                 = "scope"
          "applied_to"            = "applied_to"
          "scheduler_path"        = "scheduler_path"
          "comments"              = "comments"
        }
        required_fields = @("id", "display_name", "category")
        resource_type   = "SecurityPolicy"
      }
      "Services"             = @{
        file_pattern    = "L4CustomServices.csv"
        schema_type     = "Service"
        column_mapping  = @{
          "id"                = "id"
          "display_name"      = "display_name"
          "description"       = "description"
          "nsx_domain"        = "nsx_domain"
          "service_type"      = "service_type"
          "l4_protocol"       = "l4_protocol"
          "source_ports"      = "source_ports"
          "destination_ports" = "destination_ports"
          "icmp_type"         = "icmp_type"
          "icmp_code"         = "icmp_code"
          "protocol"          = "protocol"
          "alg"               = "alg"
          "ether_type"        = "ether_type"
        }
        required_fields = @("id", "display_name", "service_type")
        resource_type   = "Service"
      }
      "ContextProfiles"      = @{
        file_pattern    = "ContextProfiles.csv"
        schema_type     = "ContextProfile"
        column_mapping  = @{
          "id"                       = "id"
          "display_name"             = "display_name"
          "description"              = "description"
          "nsx_domain"               = "nsx_domain"
          "context_type"             = "context_type"
          "attributes"               = "attributes"
          "app_id"                   = "app_id"
          "application_profile_type" = "application_profile_type"
          "custom_attributes"        = "custom_attributes"
        }
        required_fields = @("id", "display_name")
        resource_type   = "ContextProfile"
      }
      "Segments"             = @{
        file_pattern    = "Segments.csv"
        schema_type     = "Segment"
        column_mapping  = @{
          "id"                  = "id"
          "display_name"        = "display_name"
          "description"         = "description"
          "nsx_domain"          = "nsx_domain"
          "connectivity_path"   = "connectivity_path"
          "transport_zone_path" = "transport_zone_path"
          "subnets"             = "subnets"
          "gateway_address"     = "gateway_address"
          "dhcp_config_path"    = "dhcp_config_path"
          "admin_state"         = "admin_state"
          "replication_mode"    = "replication_mode"
          "overlay_id"          = "overlay_id"
          "vlan_ids"            = "vlan_ids"
        }
        required_fields = @("id", "display_name")
        resource_type   = "Segment"
      }
      "VMTags"               = @{
        file_pattern    = "VM_Tags.csv"
        schema_type     = "VMTag"
        column_mapping  = @{
          "id"           = "id"
          "display_name" = "display_name"
          "description"  = "description"
          "nsx_domain"   = "nsx_domain"
          "tag1"         = "tag1"
          "tag2"         = "tag2"
          "tag3"         = "tag3"
          "tag4"         = "tag4"
          "tag5"         = "tag5"
          "tag6"         = "tag6"
          "tag7"         = "tag7"
          "tag8"         = "tag8"
          "tag9"         = "tag9"
          "tag10"        = "tag10"
        }
        required_fields = @("id", "display_name")
        resource_type   = "VMTag"
      }
      "Lists"                = @{
        file_pattern    = "Lists.csv"
        schema_type     = "ReferenceList"
        column_mapping  = @{
          "Prefix"              = "prefix"
          "Security"            = "security"
          "Delimiter"           = "delimiter"
          "SITE"                = "site"
          "Environment"         = "environment"
          "Trust"               = "trust"
          "Region"              = "region"
          "CityCode"            = "city_code"
          "Ref"                 = "ref"
          "RefB"                = "ref_b"
          "TagScope"            = "tag_scope"
          "IPSetType"           = "ip_set_type"
          "admin_state"         = "admin_state"
          "SegmentTypeRef"      = "segment_type_ref"
          "staticMembers"       = "static_members"
          "memberType"          = "member_type"
          "memberKey"           = "member_key"
          "memberOperator"      = "member_operator"
          "conjunctionOperator" = "conjunction_operator"
          "segment_type"        = "segment_type"
          "replication_mode"    = "replication_mode"
          "Service"             = "service"
          "AppID"               = "app_id"
          "FirewallCategory"    = "firewall_category"
          "Action"              = "action"
          "Protocol"            = "protocol"
          "Direction"           = "direction"
          "Ip_protocol"         = "ip_protocol"
          "resource_type"       = "resource_type"
          "service_type"        = "service_type"
          "scriptaction"        = "script_action"
          "nsx_domain"          = "nsx_domain"
        }
        required_fields = @("display_name")
        resource_type   = "ReferenceList"
      }
      "ParentCustomServices" = @{
        file_pattern    = "ParentCustomServices.csv"
        schema_type     = "Service"
        column_mapping  = @{
          "id"                  = "id"
          "display_name"        = "display_name"
          "description"         = "description"
          "parent_service"      = "parent_service"
          "tag1"                = "tag1"
          "tag2"                = "tag2"
          "tag3"                = "tag3"
          "tag4"                = "tag4"
          "tag5"                = "tag5"
          "tags"                = "tags"
          "nsx_domain"          = "nsx_domain"
          "nsxmgr"              = "nsxmgr"
          "scriptaction"        = "script_action"
          "ConfigurationStatus" = "configuration_status"
          "allscrptactions"     = "all_script_actions"
          "universal"           = "universal"
        }
        required_fields = @("display_name")
        resource_type   = "Service"
      }
      "Tags"                 = @{
        file_pattern    = "Tags.csv"
        schema_type     = "Tag"
        column_mapping  = @{
          "id"           = "id"
          "display_name" = "display_name"
          "description"  = "description"
          "scope"        = "scope"
          "tag"          = "tag"
        }
        required_fields = @("id", "display_name")
        resource_type   = "Tag"
      }
    }
  }

  # Get available CSV files in the source directory
  [array] GetAvailableCSVFiles() {
    try {
      $csvFiles = Get-ChildItem -Path $this.csvSourcePath -Filter "*.csv" -File
      $this.logger.LogInfo("Found $($csvFiles.Count) CSV files in source directory", "CSVParser")
      return $csvFiles
    }
    catch {
      $this.logger.LogError("Failed to get CSV files: $($_.Exception.Message)", "CSVParser")
      return @()
    }
  }

  # Parse a single CSV file and convert to JSON
  [object] ParseCSVFile([string] $csvFileName) {
    try {
      $this.logger.LogInfo("Starting to parse CSV file: $csvFileName", "CSVParser")

      # Find schema mapping for this CSV file
      $schemaKey = $null
      foreach ($key in $this.schemaMapping.Keys) {
        if ($csvFileName -match $this.schemaMapping[$key].file_pattern) {
          $schemaKey = $key
          break
        }
      }

      if (-not $schemaKey) {
        $this.logger.LogWarning("No schema mapping found for CSV file: $csvFileName", "CSVParser")
        return $null
      }

      $schema = $this.schemaMapping[$schemaKey]
      $csvFilePath = Join-Path $this.csvSourcePath $csvFileName

      # Check if file exists
      if (-not (Test-Path $csvFilePath)) {
        $this.logger.LogError("CSV file not found: $csvFilePath", "CSVParser")
        return $null
      }

      # Import CSV data
      $csvData = Import-Csv -Path $csvFilePath
      $this.logger.LogInfo("Imported $($csvData.Count) rows from CSV file", "CSVParser")

      # Convert CSV rows to JSON objects
      $jsonObjects = @()
      foreach ($row in $csvData) {
        $jsonObj = $this.ConvertCSVRowToJSON($row, $schema)
        if ($jsonObj) {
          $jsonObjects += $jsonObj
        }
      }

      # Create result object
      $result = [PSCustomObject]@{
        source_file   = $csvFileName
        schema_type   = $schema.schema_type
        resource_type = $schema.resource_type
        object_count  = $jsonObjects.Count
        objects       = $jsonObjects
        timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      }

      $this.logger.LogInfo("Successfully parsed $($jsonObjects.Count) objects from CSV file", "CSVParser")
      return $result

    }
    catch {
      $this.logger.LogError("Failed to parse CSV file $csvFileName : $($_.Exception.Message)", "CSVParser")
      return $null
    }
  }

  # Convert a single CSV row to JSON object
  [object] ConvertCSVRowToJSON([object] $csvRow, [object] $schema) {
    try {
      $jsonObj = [PSCustomObject]@{
        resource_type = $schema.resource_type
      }

      # Map CSV columns to JSON properties
      foreach ($csvColumn in $schema.column_mapping.Keys) {
        $jsonProperty = $schema.column_mapping[$csvColumn]
        $csvValue = $csvRow.$csvColumn

        # Skip empty values
        if ([string]::IsNullOrWhiteSpace($csvValue)) {
          continue
        }

        # Process special field types
        $processedValue = $this.ProcessFieldValue($csvValue, $jsonProperty, $schema.resource_type)
        if ($processedValue -ne $null) {
          $jsonObj[$jsonProperty] = $processedValue
        }
      }

      # Validate required fields and generate IDs/display_names if missing
      foreach ($requiredField in $schema.required_fields) {
        # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
        if (-not ((Get-Member -InputObject $jsonObj -Name $requiredField -MemberType NoteProperty -ErrorAction SilentlyContinue)) -or [string]::IsNullOrWhiteSpace($jsonObj.$requiredField)) {
          # Special handling for missing ID field - generate one
          if ($requiredField -eq "id") {
            # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
            if ((Get-Member -InputObject $jsonObj -Name "display_name" -MemberType NoteProperty -ErrorAction SilentlyContinue) -and -not [string]::IsNullOrWhiteSpace($jsonObj.display_name)) {
              # Generate ID from display_name
              $generatedId = $this.GenerateIdFromDisplayName($jsonObj.display_name)
              $jsonObj.id = $generatedId
              $this.logger.LogInfo("Generated ID '$generatedId' from display_name for CSV row", "CSVParser")
            }
            else {
              # Generate random ID as last resort
              $generatedId = "generated-" + [System.Guid]::NewGuid().ToString().Substring(0, 8)
              $jsonObj.id = $generatedId
              $this.logger.LogInfo("Generated random ID '$generatedId' for CSV row", "CSVParser")
            }
          }
          # Special handling for missing display_name field - generate one from id
          elseif ($requiredField -eq "display_name") {
            # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
            if ((Get-Member -InputObject $jsonObj -Name "id" -MemberType NoteProperty -ErrorAction SilentlyContinue) -and -not [string]::IsNullOrWhiteSpace($jsonObj.id)) {
              # Generate display_name from id, but avoid UUID strings
              $idValue = $jsonObj.id
              if ($idValue -match "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$" -or $idValue -match "^generated-[0-9a-f]{8}$") {
                # This is a UUID or generated ID, create a more meaningful display name
                $generatedDisplayName = "Object " + ($idValue -replace "generated-", "")
              }
              else {
                # Convert id to display_name format (replace underscores with spaces, capitalize)
                $generatedDisplayName = $idValue -replace "_", " "
                $generatedDisplayName = (Get-Culture).TextInfo.ToTitleCase($generatedDisplayName.ToLower())
              }
              $jsonObj.display_name = $generatedDisplayName
              $this.logger.LogInfo("Generated display_name '$generatedDisplayName' from id '$idValue' for CSV row", "CSVParser")
            }
            else {
              # Generate a fallback display_name from other fields or use a generic name
              $generatedDisplayName = "Unnamed Object"
              $jsonObj.display_name = $generatedDisplayName
              $this.logger.LogInfo("Generated fallback display_name '$generatedDisplayName' for CSV row", "CSVParser")
            }
          }
          else {
            $this.logger.LogWarning("Missing required field '$requiredField' in CSV row", "CSVParser")
            return $null
          }
        }
      }

      return $jsonObj

    }
    catch {
      $this.logger.LogError("Failed to convert CSV row to JSON: $($_.Exception.Message)", "CSVParser")
      return $null
    }
  }

  # Process field values based on type and convert to appropriate format
  [object] ProcessFieldValue([string] $value, [string] $fieldName, [string] $resourceType) {
    try {
      # Handle boolean fields
      if ($fieldName -in @("stateful", "tcp_strict", "locked", "disabled", "log")) {
        return $value.ToLower() -eq "true"
      }

      # Handle numeric fields
      if ($fieldName -in @("sequence_number", "precedence", "overlay_id")) {
        if ([int]::TryParse($value, [ref] $null)) {
          return [int]$value
        }
      }

      # Handle array fields (comma-separated values)
      if ($fieldName -in @("source_groups", "destination_groups", "services", "applied_to", "scope", "vlan_ids", "subnets")) {
        if ($value.Contains(",")) {
          return $value.Split(",").Trim()
        }
        else {
          return @($value.Trim())
        }
      }

      # Handle tag fields for VM Tags
      if ($fieldName -match "^tag\d+$" -and $resourceType -eq "VMTag") {
        return $this.ProcessVMTagValue($value)
      }

      # Handle condition fields for Groups
      if ($fieldName -match "^condition_\d+$" -and $resourceType -eq "Group") {
        return $this.ProcessGroupConditionValue($value)
      }

      # Handle port ranges
      if ($fieldName -in @("source_ports", "destination_ports")) {
        return $this.ProcessPortValue($value)
      }

      # Default: return as string, trimmed
      return $value.Trim()

    }
    catch {
      $this.logger.LogWarning("Failed to process field value for '$fieldName': $($_.Exception.Message)", "CSVParser")
      return $value
    }
  }

  # Process VM tag values (format: scope|tag or just tag)
  [object] ProcessVMTagValue([string] $tagValue) {
    if ($tagValue.Contains("|")) {
      $parts = $tagValue.Split("|")
      return @{
        scope = $parts[0].Trim()
        tag   = $parts[1].Trim()
      }
    }
    else {
      return @{
        tag = $tagValue.Trim()
      }
    }
  }

  # Process group condition values
  [object] ProcessGroupConditionValue([string] $conditionValue) {
    # Parse condition format: key=value or key!=value or key IN [value1,value2]
    if ($conditionValue.Contains("=")) {
      $parts = $conditionValue.Split("=", 2)
      $operator = if ($parts[0].EndsWith("!")) { "NOTEQUALS" } else { "EQUALS" }
      $key = $parts[0].Replace("!", "").Trim()
      $value = $parts[1].Trim()

      return @{
        key         = $key
        member_type = "VirtualMachine"
        operator    = $operator
        value       = $value
      }
    }

    # Return as string if can't parse
    return $conditionValue
  }

  # Process port values (handle ranges and single ports)
  [object] ProcessPortValue([string] $portValue) {
    if ($portValue.Contains("-")) {
      $parts = $portValue.Split("-")
      return @{
        start = $parts[0].Trim()
        end   = $parts[1].Trim()
      }
    }
    else {
      return @($portValue.Trim())
    }
  }

  # Generate ID from display name
  [string] GenerateIdFromDisplayName([string] $displayName) {
    if ([string]::IsNullOrWhiteSpace($displayName)) {
      return "generated_" + [System.Guid]::NewGuid().ToString().Substring(0, 8)
    }

    # Create a clean ID from display name by replacing spaces with underscores
    $cleanId = $displayName.Trim()
    # Replace spaces with underscores
    $cleanId = $cleanId -replace '\s+', '_'
    # Remove any remaining special characters except underscores, hyphens, and alphanumeric
    $cleanId = $cleanId -replace '[^a-zA-Z0-9_-]', ''

    # Ensure it's not empty
    if ([string]::IsNullOrWhiteSpace($cleanId) -or $cleanId.Length -lt 1) {
      return "generated_" + [System.Guid]::NewGuid().ToString().Substring(0, 8)
    }

    # Limit length to 100 characters
    if ($cleanId.Length -gt 100) {
      $cleanId = $cleanId.Substring(0, 100).TrimEnd('_')
    }

    return $cleanId
  }

  # Save parsed JSON to file
  [string] SaveJSONToFile([object] $jsonData, [string] $fileName) {
    try {
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $cleanFileName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
      $jsonFileName = "${timestamp}_${cleanFileName}.json"
      $jsonFilePath = Join-Path $this.jsonOutputPath $jsonFileName

      # Convert to JSON with proper formatting
      $jsonString = $jsonData | ConvertTo-Json -Depth 10 -Compress:$false

      # Save to file
      $jsonString | Out-File -FilePath $jsonFilePath -Encoding UTF8

      $this.logger.LogInfo("Saved JSON data to: $jsonFilePath", "CSVParser")

      # Log file details
      $fileInfo = Get-Item $jsonFilePath
      $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
      $this.logger.LogInfo("File size: $fileSizeKB KB", "CSVParser")

      return $jsonFilePath

    }
    catch {
      $this.logger.LogError("Failed to save JSON file: $($_.Exception.Message)", "CSVParser")
      throw
    }
  }

  # Process all CSV files in the source directory
  [array] ProcessAllCSVFiles() {
    try {
      $this.logger.LogStep("Processing all CSV files in source directory")

      $csvFiles = $this.GetAvailableCSVFiles()
      $results = @()

      foreach ($csvFile in $csvFiles) {
        $this.logger.LogInfo("Processing CSV file: $($csvFile.Name)", "CSVParser")

        # Parse CSV file
        $parsedData = $this.ParseCSVFile($csvFile.Name)
        if ($parsedData) {
          # Save to JSON file
          $jsonFilePath = $this.SaveJSONToFile($parsedData, $csvFile.Name)

          $results += @{
            source_csv    = $csvFile.Name
            json_file     = $jsonFilePath
            object_count  = $parsedData.object_count
            resource_type = $parsedData.resource_type
            success       = $true
          }
        }
        else {
          $results += @{
            source_csv    = $csvFile.Name
            json_file     = $null
            object_count  = 0
            resource_type = $null
            success       = $false
          }
        }
      }

      $this.logger.LogInfo("Processed $($csvFiles.Count) CSV files, $($results.Where({$_.success}).Count) successful", "CSVParser")
      return $results

    }
    catch {
      $this.logger.LogError("Failed to process CSV files: $($_.Exception.Message)", "CSVParser")
      return @()
    }
  }

  # Process a specific CSV file by name
  [object] ProcessSpecificCSVFile([string] $fileName) {
    try {
      $this.logger.LogInfo("Processing specific CSV file: $fileName", "CSVParser")

      # Parse CSV file
      $parsedData = $this.ParseCSVFile($fileName)
      if ($parsedData) {
        # Save to JSON file
        $jsonFilePath = $this.SaveJSONToFile($parsedData, $fileName)

        return @{
          source_csv    = $fileName
          json_file     = $jsonFilePath
          object_count  = $parsedData.object_count
          resource_type = $parsedData.resource_type
          parsed_data   = $parsedData
          success       = $true
        }
      }
      else {
        return @{
          source_csv    = $fileName
          json_file     = $null
          object_count  = 0
          resource_type = $null
          parsed_data   = $null
          success       = $false
        }
      }

    }
    catch {
      $this.logger.LogError("Failed to process CSV file $fileName : $($_.Exception.Message)", "CSVParser")
      return @{
        source_csv = $fileName
        success    = $false
        error      = $_.Exception.Message
      }
    }
  }

  # Get schema information for a specific resource type
  [object] GetSchemaMapping([string] $resourceType) {
    foreach ($key in $this.schemaMapping.Keys) {
      if ($this.schemaMapping[$key].resource_type -eq $resourceType -or $this.schemaMapping[$key].schema_type -eq $resourceType) {
        return $this.schemaMapping[$key]
      }
    }
    return $null
  }

  # Get all available schema types
  [array] GetAvailableSchemaTypes() {
    $types = @()
    foreach ($key in $this.schemaMapping.Keys) {
      $types += $this.schemaMapping[$key].schema_type
    }
    return $types
  }
}
