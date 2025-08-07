<#
.SYNOPSIS
    Shared Tool Utility Service - Eliminates common utility function duplication across all tools

.DESCRIPTION
    Provides standardized utility functions for all NSX toolkit tools including:
    - Status reporting (SUCCESS/ERROR/WARNING patterns)
    - Progress tracking and completion messaging
    - Prerequisite validation reporting
    - Operation result formatting

    Complements StandardToolTemplate.ps1 functions and eliminates ~300+ lines of
    duplicated utility code across 6 tool scripts.

.NOTES
    Part of NSX PowerShell Toolkit Architecture Refactoring Plan Phase 4C
    Target: Eliminate common utility function duplication across all tools
    Works with existing StandardToolTemplate and SharedToolCredentialService
#>

class SharedToolUtilityService {
  [object] $logger

  # Constructor
  SharedToolUtilityService([object] $logger) {
    $this.logger = $logger
    $this.logger.LogInfo("SharedToolUtilityService initialized successfully", "SharedUtilityService")
  }

  # ========================================
  # STANDARDIZED STATUS REPORTING
  # ========================================

  # Standard success message formatting
  [void] WriteSuccess([string] $message, [string] $toolName = "Tool") {
    Write-Host "SUCCESS: $message" -ForegroundColor Green
    $this.logger.LogInfo("SUCCESS: $message", $toolName)
  }

  # Standard error message formatting
  [void] WriteError([string] $message, [string] $toolName = "Tool") {
    Write-Host "ERROR: $message" -ForegroundColor Red
    $this.logger.LogError("ERROR: $message", $toolName)
  }

  # Standard warning message formatting
  [void] WriteWarning([string] $message, [string] $toolName = "Tool") {
    Write-Host "WARNING: $message" -ForegroundColor Yellow
    $this.logger.LogWarning("WARNING: $message", $toolName)
  }

  # Standard info message formatting
  [void] WriteInfo([string] $message, [string] $toolName = "Tool") {
    Write-Host "$message" -ForegroundColor Gray
    $this.logger.LogInfo($message, $toolName)
  }

  # Standard operation status with icon formatting
  [void] WriteOperationStatus([string] $operation, [bool] $success, [string] $details = "", [string] $toolName = "Tool") {
    $icon = if ($success) { "[SUCCESS]" } else { "[ERROR]" }
    $color = if ($success) { "Green" } else { "Red" }
    $status = if ($success) { "SUCCESS" } else { "FAILED" }

    Write-Host "$icon ${operation}: $status" -ForegroundColor $color
    if ($details) {
      Write-Host "   $details" -ForegroundColor Gray
    }

    $logMessage = "${operation}: $status"
    if ($details) {
      $logMessage += " - $details"
    }
    if ($success) {
      $this.logger.LogInfo($logMessage, $toolName)
    }
    else {
      $this.logger.LogError($logMessage, $toolName)
    }
  }

  # ========================================
  # STANDARDIZED PROGRESS TRACKING
  # ========================================

  # Standard progress message formatting
  [void] WriteProgress([string] $stage, [string] $message, [string] $toolName = "Tool") {
    Write-Host "[$stage] $message" -ForegroundColor Cyan
    $this.logger.LogInfo("PROGRESS [$stage]: $message", $toolName)
  }

  # Standard operation completion reporting
  [void] WriteOperationComplete([string] $operation, [object] $statistics = [PSCustomObject]@{}, [string] $toolName = "Tool") {
    Write-Host "`n$operation COMPLETED SUCCESSFULLY" -ForegroundColor Green

    if ($statistics.Count -gt 0) {
      foreach ($key in $statistics.Keys) {
        Write-Host "   ${key}: $($statistics[$key])" -ForegroundColor Gray
      }
    }

    $this.logger.LogInfo("$operation completed successfully", $toolName)
  }

  # Standard multi-step operation status
  [void] WriteMultiStepStatus([string] $stepName, [int] $currentStep, [int] $totalSteps, [string] $details = "", [string] $toolName = "Tool") {
    $progress = "Step $currentStep/$totalSteps"
    Write-Host "[$progress] $stepName" -ForegroundColor Cyan
    if ($details) {
      Write-Host "   $details" -ForegroundColor Gray
    }

    $this.logger.LogInfo("$progress - $stepName$(if($details) { ': ' + $details } else { '' })", $toolName)
  }

  # ========================================
  # STANDARDIZED PREREQUISITE REPORTING
  # ========================================

  # Standard prerequisite validation success
  [void] WritePrerequisiteSuccess([string] $component, [string] $details = "", [string] $toolName = "Tool") {
    Write-Host "$component`: Service framework initialized successfully" -ForegroundColor Green
    if ($details) {
      Write-Host "   $details" -ForegroundColor Gray
    }

    $this.logger.LogInfo("Prerequisites validated successfully for $component$(if($details) { ' - ' + $details } else { '' })", $toolName)
  }

  # Standard toolkit prerequisite validation
  [void] WriteToolkitPrerequisiteValidation([string] $managerName, [bool] $success, [string] $errorMessage = "", [string] $toolName = "Tool") {
    if ($success) {
      Write-Host "NSX toolkit prerequisites validated successfully for $managerName" -ForegroundColor Green
      $this.logger.LogInfo("NSX toolkit prerequisites validated successfully for $managerName", $toolName)
    }
    else {
      Write-Host " TOOLKIT PREREQUISITE WARNING" -ForegroundColor Yellow
      Write-Host "Error: $errorMessage" -ForegroundColor Red
      $this.logger.LogError("NSX toolkit prerequisite validation failed for $managerName`: $errorMessage", $toolName)
    }
  }

  # ========================================
  # STANDARDIZED RESULT FORMATTING
  # ========================================

  # Standard result summary table
  [void] WriteResultSummary([object] $results, [string] $title = "Operation Results", [string] $toolName = "Tool") {
    Write-Host "`n${title}:" -ForegroundColor Yellow
    Write-Host ("=" * 50) -ForegroundColor Yellow

    foreach ($key in $results.Keys) {
      $value = $results[$key]
      $color = "Gray"

      # Color-code based on common patterns
      if ($key -match "Success|Completed|Created" -or $value -match "SUCCESS|[SUCCESS]") {
        $color = "Green"
      }
      elseif ($key -match "Error|Failed|Problem" -or $value -match "ERROR|FAILED|[ERROR]") {
        $color = "Red"
      }
      elseif ($key -match "Warning|Skip" -or $value -match "WARNING|") {
        $color = "Yellow"
      }

      Write-Host "  ${key}: $value" -ForegroundColor $color
    }

    Write-Host ("=" * 50) -ForegroundColor Yellow
    $this.logger.LogInfo("$title summary displayed with $($results.Count) items", $toolName)
  }

  # Standard configuration comparison result
  [void] WriteConfigurationComparison([object] $comparisonResult, [string] $toolName = "Tool") {
    $sourceStatus = if ($comparisonResult.source_success) { "SUCCESS" } else { "FAILED" }
    $targetStatus = if ($comparisonResult.target_success) { "SUCCESS" } else { "FAILED" }

    Write-Host "Source Configuration:" -ForegroundColor Yellow
    Write-Host "   Status: $sourceStatus" -ForegroundColor $(if ($comparisonResult.source_success) { 'Green' } else { 'Red' })

    Write-Host "Target Configuration:" -ForegroundColor Yellow
    Write-Host "   Status: $targetStatus" -ForegroundColor $(if ($comparisonResult.target_success) { 'Green' } else { 'Red' })

    if ($comparisonResult.differences) {
      Write-Host "Configuration Differences: $($comparisonResult.differences)" -ForegroundColor Cyan
    }

    $this.logger.LogInfo("Configuration comparison displayed - Source: $sourceStatus, Target: $targetStatus", $toolName)
  }

  # ========================================
  # STANDARDIZED DATA CONVERSION UTILITIES
  # ========================================

  <#
  .SYNOPSIS
      Normalizes and cleans PSCustomObject structure recursively

  .DESCRIPTION
      Eliminates duplicate object conversion methods across services.
      Handles nested objects and arrays properly for JSON configuration processing.
      MANDATORY: Uses PSObject patterns only - no hashtable constructs.

  .PARAMETER obj
      The object to normalize (PSCustomObject, array, or primitive type)

  .OUTPUTS
      Returns normalized PSCustomObject for objects, array for arrays, or original value for primitives

  .NOTES
      Replaces duplicated hashtable conversion methods in:
      - WorkflowOperationsService.ps1
      - DataObjectFilterService.ps1
      - OpenAPISchemaService.ps1

      Part of canonical protocol compliance - PSObject patterns only.
  #>
  [object] NormalizePSObject([object] $obj) {
    if ($obj -is [PSCustomObject]) {
      $normalizedObject = [PSCustomObject]@{}
      foreach ($property in $obj.PSObject.Properties) {
        if ($property.Value -is [PSCustomObject] -or $property.Value -is [Array]) {
          $normalizedObject | Add-Member -NotePropertyName $property.Name -NotePropertyValue ($this.NormalizePSObject($property.Value))
        }
        else {
          $normalizedObject | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value
        }
      }
      return $normalizedObject
    }
    elseif ($obj -is [Array]) {
      return @($obj | ForEach-Object { $this.NormalizePSObject($_) })
    }
    else {
      return $obj
    }
  }

  <#
  .SYNOPSIS
      DEPRECATED: Backward compatibility method - use NormalizePSObject instead

  .DESCRIPTION
      Provides backward compatibility for services still calling ConvertPSObjectToHashtable.
      MANDATORY PROTOCOL: This method now returns PSObject, not hashtable.
      WARNING: Will be removed in future versions.

  .PARAMETER obj
      The object to normalize

  .OUTPUTS
      Returns normalized PSCustomObject (NOT hashtable)

  .NOTES
      DEPRECATED: Use NormalizePSObject method directly.
      This method violates naming conventions and will be removed.
  #>
  [object] ConvertPSObjectToHashtable([object] $obj) {
    # PROTOCOL COMPLIANCE: Return PSObject, not hashtable
    return $this.NormalizePSObject($obj)
  }

  <#
  .SYNOPSIS
      Safely checks if an object has a specific property

  .DESCRIPTION
      Provides safe property checking for PSCustomObject and dictionary objects.
      Eliminates property access issues across different object types.

  .PARAMETER obj
      The object to check

  .PARAMETER propertyName
      The property name to check for

  .OUTPUTS
      Returns true if the property exists, false otherwise
  #>
  [bool] HasProperty([object] $obj, [string] $propertyName) {
    if ($null -eq $obj) { return $false }

    # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
    if ($obj -is [System.Collections.IDictionary]) {
      # Check if the dictionary contains the key using safer method
      try {
        return $obj.Keys -contains $propertyName
      }
      catch {
        return $false
      }
    }
    elseif ($obj -is [PSCustomObject]) {
      return $null -ne ($obj | Get-Member -Name $propertyName -ErrorAction SilentlyContinue)
    }
    else {
      return $false
    }
  }

  <#
  .SYNOPSIS
      Safely gets property value from an object

  .DESCRIPTION
      Provides safe property access for PSCustomObject and dictionary objects.

  .PARAMETER obj
      The object to get property from

  .PARAMETER propertyName
      The property name to get

  .OUTPUTS
      Returns property value if exists, null otherwise
  #>
  [object] GetPropertyValue([object] $obj, [string] $propertyName) {
    if ($null -eq $obj) { return $null }

    # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
    if ($obj -is [System.Collections.IDictionary]) {
      # Use safer key checking method
      try {
        if ($obj.Keys -contains $propertyName) {
          return $obj[$propertyName]
        }
        else {
          return $null
        }
      }
      catch {
        return $null
      }
    }
    elseif ($obj -is [PSCustomObject]) {
      return if ($obj | Get-Member -Name $propertyName -ErrorAction SilentlyContinue) { $obj.$propertyName } else { $null }
    }
    else {
      return $null
    }
  }

  # ========================================
  # STANDARDIZED TOOL ORCHESTRATION REPORTING
  # ========================================

  # Standard tool orchestration call reporting
  [void] WriteToolOrchestrationCall([string] $toolPath, [object] $parameters, [string] $operation, [string] $toolName = "Tool") {
    Write-Host "$operation via $(Split-Path $toolPath -Leaf)" -ForegroundColor Cyan

    if ($parameters.Count -gt 0) {
      Write-Host "   Parameters:" -ForegroundColor Gray
      foreach ($key in $parameters.Keys) {
        $value = $parameters[$key]
        # Mask credential parameters for security
        if ($key -match "Credential|Password|Secret") {
          $value = "***MASKED***"
        }
        Write-Host "     ${key}: $value" -ForegroundColor Gray
      }
    }

    $this.logger.LogInfo("Tool orchestration call: $operation via $(Split-Path $toolPath -Leaf)", $toolName)
  }

  # Standard tool orchestration result reporting
  [void] WriteToolOrchestrationResult([string] $toolName, [bool] $success, [string] $result = "", [string] $callingTool = "Tool") {
    if ($success) {
      Write-Host "$result completed via $toolName" -ForegroundColor Cyan
      $this.logger.LogInfo("Tool orchestration success: $result completed via $toolName", $callingTool)
    }
    else {
      Write-Host "Tool orchestration failed: $toolName returned error" -ForegroundColor Red
      if ($result) {
        Write-Host "   Error: $result" -ForegroundColor Red
      }
      $this.logger.LogError("Tool orchestration failed: $toolName - $result", $callingTool)
    }
  }

  # ========================================
  # UTILITY HELPER METHODS
  # ========================================

  # Get standardized timestamp for reporting
  [string] GetTimestamp() {
    return Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  }

  # Get standardized file timestamp for naming
  [string] GetFileTimestamp() {
    return Get-Date -Format "yyyyMMdd_HHmmss"
  }

  # Mask sensitive information in output
  [string] MaskSensitiveInfo([string] $input) {
    $masked = $input
    $masked = $masked -replace "password\s*=\s*[^;\s]+", "password=***MASKED***"
    $masked = $masked -replace "credential\s*:\s*[^,\s]+", "credential:***MASKED***"
    $masked = $masked -replace "token\s*:\s*[^,\s]+", "token:***MASKED***"
    return $masked
  }
}
