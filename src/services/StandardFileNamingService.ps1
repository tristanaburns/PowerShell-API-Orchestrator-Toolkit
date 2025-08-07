# StandardFileNamingService.ps1
# Helper service for consistent file naming across the NSX PowerShell Toolkit
# Provides standardized naming: (datestamp)-(nsxmgrname)-(nsxdomain)-(function/purpose)

class StandardFileNamingService {
  [object] $logger

  StandardFileNamingService([object] $logger) {
    $this.logger = $logger
    $this.logger.LogInfo("Standard File Naming Service initialised", "FileNaming")
  }

  # Generate standardized filename: (datestamp)-(nsxmgrname)-(nsxdomain)-(function)
  [string] GenerateStandardizedFileName([string] $nsxManager, [string] $nsxDomain, [string] $function, [string] $extension = "json") {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)
    $cleanDomainName = $this.CleanNameForFilename($nsxDomain)
    $cleanFunction = $this.CleanNameForFilename($function)

    $filename = "$timestamp-$cleanManagerName-$cleanDomainName-$cleanFunction.$extension"

    if ($this.logger) {
      $this.logger.LogDebug("Generated standardized filename: $filename", "FileNaming")
    }

    return $filename
  }

  # Generate filename with custom timestamp format
  [string] GenerateStandardizedFileNameWithTimestamp([string] $nsxManager, [string] $nsxDomain, [string] $function, [string] $timestamp, [string] $extension = "json") {
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)
    $cleanDomainName = $this.CleanNameForFilename($nsxDomain)
    $cleanFunction = $this.CleanNameForFilename($function)

    $filename = "$timestamp-$cleanManagerName-$cleanDomainName-$cleanFunction.$extension"

    if ($this.logger) {
      $this.logger.LogDebug("Generated standardized filename with custom timestamp: $filename", "FileNaming")
    }

    return $filename
  }

  # Clean name for filename (extract hostname and remove invalid characters)
  [string] CleanNameForFilename([string] $name) {
    if (-not $name) {
      return "unknown"
    }

    # Extract hostname only (first part before the first dot)
    # e.g., "lab-nsxgm-01.lab.vdcninja.com"  "lab-nsxgm-01"
    $hostname = $name
    if ($name.Contains('.')) {
      $hostname = $name.Split('.')[0]
    }

    # Replace invalid filename characters with underscores
    $cleaned = $hostname -replace '[\\/:*?"<>|]', '_'
    # Remove any remaining dots (shouldn't be any after hostname extraction)
    $cleaned = $cleaned -replace '\.+', '_'
    # Remove leading/trailing underscores and spaces
    $cleaned = $cleaned.Trim('_', ' ')

    # Ensure we have a valid name
    if (-not $cleaned) {
      $cleaned = "unknown"
    }

    if ($this.logger) {
      if ($name -ne $cleaned) {
        $this.logger.LogDebug("Extracted hostname for file naming: '$name'  '$cleaned'", "FileNaming")
      }
    }

    return $cleaned
  }

  # Parse standardized filename to extract components
  [object] ParseStandardizedFileName([string] $filename) {
    $parsed = [PSCustomObject]@{
      timestamp   = $null
      nsx_manager = $null
      nsx_domain  = $null
      function    = $null
      extension   = $null
      is_valid    = $false
    }

    # Parse standardized filename: (datestamp)-(nsxmgrname)-(nsxdomain)-(function).extension
    if ($filename -match '^(\d{8}-\d{6})-(.+?)-(.+?)-(.+?)\.(.+)$') {
      $parsed.timestamp = $matches[1]
      $parsed.nsx_manager = $matches[2] -replace '_', '.'
      $parsed.nsx_domain = $matches[3] -replace '_', '.'
      $parsed.function = $matches[4] -replace '_', '-'
      $parsed.extension = $matches[5]
      $parsed.is_valid = $true
    }

    return $parsed
  }

  # Generate directory path for manager-specific files
  [string] GetManagerDirectory([string] $baseDirectory, [string] $nsxManager) {
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)
    $managerDir = Join-Path $baseDirectory $cleanManagerName

    if (-not (Test-Path $managerDir)) {
      New-Item -ItemType Directory -Path $managerDir -Force | Out-Null
      if ($this.logger) {
        $this.logger.LogInfo("Created manager directory: $managerDir", "FileNaming")
      }
    }

    return $managerDir
  }

  # Generate full file path with standardized naming
  [string] GenerateStandardizedFilePath([string] $baseDirectory, [string] $nsxManager, [string] $nsxDomain, [string] $function, [string] $extension = "json") {
    $managerDir = $this.GetManagerDirectory($baseDirectory, $nsxManager)
    $filename = $this.GenerateStandardizedFileName($nsxManager, $nsxDomain, $function, $extension)

    return Join-Path $managerDir $filename
  }

  # Validate filename format
  [bool] IsValidStandardizedFileName([string] $filename) {
    return $filename -match '^\d{8}-\d{6}-.+-.+-.+\..+$'
  }

  # Get timestamp from filename
  [string] GetTimestampFromFilename([string] $filename) {
    if ($filename -match '^(\d{8}-\d{6})-') {
      return $matches[1]
    }
    return $null
  }

  # Convert timestamp to DateTime
  [DateTime] ConvertTimestampToDateTime([string] $timestamp) {
    try {
      if ($timestamp -match '^(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})$') {
        $year = [int]$matches[1]
        $month = [int]$matches[2]
        $day = [int]$matches[3]
        $hour = [int]$matches[4]
        $minute = [int]$matches[5]
        $second = [int]$matches[6]

        return [DateTime]::new($year, $month, $day, $hour, $minute, $second)
      }
      else {
        throw "Invalid timestamp format: $timestamp"
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogWarning("Failed to convert timestamp '$timestamp' to DateTime: $($_.Exception.Message)", "FileNaming")
      }
      return [DateTime]::MinValue
    }
  }

  # Generate backup filename
  [string] GenerateBackupFileName([string] $originalFilename) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($originalFilename)
    $extension = [System.IO.Path]::GetExtension($originalFilename)

    return "$timestamp-backup-$baseName$extension"
  }

  # Generate configuration comparison filename
  [string] GenerateComparisonFileName([string] $sourceManager, [string] $targetManager, [string] $nsxDomain, [string] $comparisonType) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $cleanSource = $this.CleanNameForFilename($sourceManager)
    $cleanTarget = $this.CleanNameForFilename($targetManager)
    $cleanDomain = $this.CleanNameForFilename($nsxDomain)
    $cleanType = $this.CleanNameForFilename($comparisonType)

    return "$timestamp-$cleanSource-to-$cleanTarget-$cleanDomain-$cleanType.json"
  }

  # Generate deployment record filename
  [string] GenerateDeploymentRecordFileName([string] $nsxManager, [string] $nsxDomain, [string] $deploymentType) {
    return $this.GenerateStandardizedFileName($nsxManager, $nsxDomain, "deployment-$deploymentType", "json")
  }

  # Generate test result filename
  [string] GenerateTestResultFileName([string] $nsxManager, [string] $nsxDomain, [string] $testType) {
    return $this.GenerateStandardizedFileName($nsxManager, $nsxDomain, "test-$testType", "json")
  }

  # Generate validation report filename
  [string] GenerateValidationReportFileName([string] $nsxManager, [string] $nsxDomain, [string] $validationType) {
    return $this.GenerateStandardizedFileName($nsxManager, $nsxDomain, "validation-$validationType", "json")
  }

  # Generate sync result filename
  [string] GenerateSyncResultFileName([string] $sourceManager, [string] $targetManager, [string] $nsxDomain, [string] $syncOperation) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $cleanSource = $this.CleanNameForFilename($sourceManager)
    $cleanTarget = $this.CleanNameForFilename($targetManager)
    $cleanDomain = $this.CleanNameForFilename($nsxDomain)
    $cleanOperation = $this.CleanNameForFilename($syncOperation)

    return "$timestamp-$cleanSource-to-$cleanTarget-$cleanDomain-sync-$cleanOperation.json"
  }

  # Generate differential configuration filename
  [string] GenerateDifferentialConfigFileName([string] $nsxManager, [string] $nsxDomain, [string] $operationType) {
    return $this.GenerateStandardizedFileName($nsxManager, $nsxDomain, "differential-$operationType", "json")
  }

  # Get file age in days
  [int] GetFileAgeInDays([string] $filename) {
    $timestamp = $this.GetTimestampFromFilename($filename)
    if ($timestamp) {
      $fileDate = $this.ConvertTimestampToDateTime($timestamp)
      if ($fileDate -ne [DateTime]::MinValue) {
        return [int]((Get-Date) - $fileDate).TotalDays
      }
    }
    return -1
  }

  # List files matching pattern
  [array] ListFilesByPattern([string] $directory, [string] $nsxManager = $null, [string] $nsxDomain = $null, [string] $function = $null) {
    $pattern = "*"

    if ($nsxManager) {
      $cleanManager = $this.CleanNameForFilename($nsxManager)
      $pattern = "*-$cleanManager-*"
    }

    if ($nsxDomain) {
      $cleanDomain = $this.CleanNameForFilename($nsxDomain)
      $pattern = "*-$cleanDomain-*"
    }

    if ($function) {
      $cleanFunction = $this.CleanNameForFilename($function)
      $pattern = "*-$cleanFunction.*"
    }

    try {
      $files = Get-ChildItem -Path $directory -Filter $pattern -File -ErrorAction SilentlyContinue
      return $files | Sort-Object Name -Descending
    }
    catch {
      if ($this.logger) {
        $this.logger.LogWarning("Failed to list files with pattern '$pattern' in directory '$directory': $($_.Exception.Message)", "FileNaming")
      }
      return @()
    }
  }

  # Clean up old files (keep only the most recent N files)
  [int] CleanupOldFiles([string] $directory, [int] $keepMostRecent = 10, [string] $filePattern = "*.json") {
    try {
      $files = Get-ChildItem -Path $directory -Filter $filePattern -File | Sort-Object Name -Descending

      if ($files.Count -le $keepMostRecent) {
        return 0
      }

      $filesToDelete = $files | Select-Object -Skip $keepMostRecent
      $deletedCount = 0

      foreach ($file in $filesToDelete) {
        try {
          Remove-Item -Path $file.FullName -Force
          $deletedCount++
          if ($this.logger) {
            $this.logger.LogInfo("Deleted old file: $($file.Name)", "FileNaming")
          }
        }
        catch {
          if ($this.logger) {
            $this.logger.LogWarning("Failed to delete file '$($file.Name)': $($_.Exception.Message)", "FileNaming")
          }
        }
      }

      return $deletedCount
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to cleanup old files: $($_.Exception.Message)", "FileNaming")
      }
      return 0
    }
  }

  # ========================================
  # API DATA FILE NAMING AND MANAGEMENT
  # ========================================

  # Generate API data directory for manager-specific files
  [string] GetAPIDataDirectory([string] $baseAPIDirectory, [string] $nsxManager) {
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)
    $apiManagerDir = Join-Path $baseAPIDirectory $cleanManagerName

    if (-not (Test-Path $apiManagerDir)) {
      New-Item -ItemType Directory -Path $apiManagerDir -Force | Out-Null
      if ($this.logger) {
        $this.logger.LogInfo("Created API data directory: $apiManagerDir", "FileNaming")
      }
    }

    return $apiManagerDir
  }

  # Generate OpenAPI schema cache filename
  [string] GenerateOpenAPISchemaFileName([string] $nsxManager, [string] $schemaType = "openapi") {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)

    return "$timestamp-$cleanManagerName-schema-$schemaType.json"
  }

  # Generate endpoint validation cache filename
  [string] GenerateEndpointCacheFileName([string] $nsxManager) {
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)

    return "validated-endpoints-cache-$cleanManagerName.json"
  }

  # Generate endpoint discovery results filename
  [string] GenerateEndpointDiscoveryFileName([string] $nsxManager, [string] $discoveryType = "comprehensive") {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)

    return "$timestamp-$cleanManagerName-endpoint-discovery-$discoveryType.json"
  }

  # Generate API configuration filename
  [string] GenerateAPIConfigFileName([string] $nsxManager, [string] $configType = "endpoints") {
    $cleanManagerName = $this.CleanNameForFilename($nsxManager)

    return "$cleanManagerName-api-$configType.json"
  }

  # Generate full API data file path with standardized naming
  [string] GenerateAPIDataFilePath([string] $baseAPIDirectory, [string] $nsxManager, [string] $filename) {
    $apiManagerDir = $this.GetAPIDataDirectory($baseAPIDirectory, $nsxManager)

    return Join-Path $apiManagerDir $filename
  }

  # Generate OpenAPI schema full path
  [string] GenerateOpenAPISchemaFilePath([string] $baseAPIDirectory, [string] $nsxManager, [string] $schemaType = "openapi") {
    $filename = $this.GenerateOpenAPISchemaFileName($nsxManager, $schemaType)

    return $this.GenerateAPIDataFilePath($baseAPIDirectory, $nsxManager, $filename)
  }

  # Generate endpoint cache full path
  [string] GenerateEndpointCacheFilePath([string] $baseAPIDirectory, [string] $nsxManager) {
    $filename = $this.GenerateEndpointCacheFileName($nsxManager)

    return $this.GenerateAPIDataFilePath($baseAPIDirectory, $nsxManager, $filename)
  }

  # Generate endpoint discovery full path
  [string] GenerateEndpointDiscoveryFilePath([string] $baseAPIDirectory, [string] $nsxManager, [string] $discoveryType = "comprehensive") {
    $filename = $this.GenerateEndpointDiscoveryFileName($nsxManager, $discoveryType)

    return $this.GenerateAPIDataFilePath($baseAPIDirectory, $nsxManager, $filename)
  }

  # List API data files for a specific manager
  [array] ListAPIDataFiles([string] $baseAPIDirectory, [string] $nsxManager, [string] $fileType = "*") {
    $apiManagerDir = $this.GetAPIDataDirectory($baseAPIDirectory, $nsxManager)

    if (-not (Test-Path $apiManagerDir)) {
      return @()
    }

    try {
      $pattern = switch ($fileType) {
        "schema" { "*-schema-*.json" }
        "endpoints" { "*-endpoint-*.json" }
        "cache" { "*-cache-*.json" }
        "config" { "*-api-*.json" }
        default { "*.json" }
      }

      $files = Get-ChildItem -Path $apiManagerDir -Filter $pattern -File | Sort-Object Name -Descending

      $apiFiles = @()
      foreach ($file in $files) {
        $apiFiles += @{
          filename    = $file.Name
          full_path   = $file.FullName
          size_kb     = [math]::Round($file.Length / 1KB, 2)
          created     = $file.CreationTime
          modified    = $file.LastWriteTime
          file_type   = $this.DetermineAPIFileType($file.Name)
          nsx_manager = $nsxManager
        }
      }

      return $apiFiles
    }
    catch {
      if ($this.logger) {
        $this.logger.LogWarning("Failed to list API data files for manager '$nsxManager': $($_.Exception.Message)", "FileNaming")
      }
      return @()
    }
  }

  # Determine API file type from filename
  hidden [string] DetermineAPIFileType([string] $filename) {
    if ($filename -match "schema") { return "schema" }
    if ($filename -match "endpoint.*discovery") { return "endpoint_discovery" }
    if ($filename -match "endpoint.*cache") { return "endpoint_cache" }
    if ($filename -match "validated.*endpoints") { return "endpoint_validation" }
    if ($filename -match "api.*config") { return "api_config" }
    return "unknown"
  }

  # Clean up old API data files (keep only the most recent N files per type)
  [int] CleanupOldAPIDataFiles([string] $baseAPIDirectory, [string] $nsxManager, [int] $keepMostRecent = 5) {
    $apiManagerDir = $this.GetAPIDataDirectory($baseAPIDirectory, $nsxManager)

    if (-not (Test-Path $apiManagerDir)) {
      return 0
    }

    try {
      $totalDeleted = 0
      $fileTypes = @("schema", "endpoint_discovery", "endpoint_cache")

      foreach ($fileType in $fileTypes) {
        $pattern = switch ($fileType) {
          "schema" { "*-schema-*.json" }
          "endpoint_discovery" { "*-endpoint-discovery-*.json" }
          "endpoint_cache" { "*-cache-*.json" }
        }

        $files = Get-ChildItem -Path $apiManagerDir -Filter $pattern -File | Sort-Object Name -Descending

        if ($files.Count -gt $keepMostRecent) {
          $filesToDelete = $files | Select-Object -Skip $keepMostRecent

          foreach ($file in $filesToDelete) {
            try {
              Remove-Item -Path $file.FullName -Force
              $totalDeleted++
              if ($this.logger) {
                $this.logger.LogInfo("Deleted old API data file: $($file.Name)", "FileNaming")
              }
            }
            catch {
              if ($this.logger) {
                $this.logger.LogWarning("Failed to delete API data file '$($file.Name)': $($_.Exception.Message)", "FileNaming")
              }
            }
          }
        }
      }

      return $totalDeleted
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to cleanup old API data files: $($_.Exception.Message)", "FileNaming")
      }
      return 0
    }
  }
}
