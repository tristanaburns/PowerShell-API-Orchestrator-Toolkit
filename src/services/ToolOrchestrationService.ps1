# ToolOrchestrationService.ps1 - Phase 2: Tool-to-Tool Communication Service
# Enables standardized tool orchestration and parameter passing between NSX toolkit tools

class ToolOrchestrationService {
  [object]$logger
  [string]$toolsPath
  [object]$standardParameters

  ToolOrchestrationService([object]$logger, [string]$toolsPath) {
    $this.logger = $logger
    $this.toolsPath = $toolsPath
    $this.standardParameters = [PSCustomObject]@{}
    $this.InitializeStandardParameters()
  }

  # ========================================
  # STANDARD PARAMETER MANAGEMENT
  # ========================================

  [void] InitializeStandardParameters() {
    # Define standard parameters that can be passed between tools
    $this.standardParameters = @{
      'Authentication' = @(
        'NSXManager',
        'UseCurrentUserCredentials',
        'ForceNewCredentials',
        'SaveCredentials',
        'Username',
        'AuthenticationConfigFile'
      )
      'Operation'      = @(
        'NonInteractive',
        'LogLevel',
        'WhatIf',
        'OutputStatistics',
        'SkipSSLCheck',
        'SkipConnectionTest'
      )
      'Output'         = @(
        'OutputDirectory',
        'IncludeMetadata'
      )
    }
  }

  [object] GetStandardParameterSet([object]$sourceParameters, [string[]]$includeGroups = @('Authentication', 'Operation', 'Output')) {
    <#
        .SYNOPSIS
            Extracts standard parameters from source parameters for tool-to-tool passing

        .DESCRIPTION
            Creates a parameter hashtable containing only standard parameters that should
            be passed between tools, filtered by parameter groups.

        .PARAMETER sourceParameters
            Source parameter hashtable (typically $PSBoundParameters)

        .PARAMETER includeGroups
            Array of parameter groups to include (Authentication, Operation, Output)

        .OUTPUTS
            Hashtable containing filtered standard parameters
        #>

    $standardParams = [PSCustomObject]@{}

    foreach ($group in $includeGroups) {
      # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
      if ((Get-Member -InputObject $this.standardParameters -Name $group -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
        # CANONICAL FIX: Replace hash table indexing with PSCustomObject property access
        $groupParams = $this.standardParameters.$group
        foreach ($paramName in $groupParams) {
          # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
          if ((Get-Member -InputObject $sourceParameters -Name $paramName -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
            # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
            $standardParams | Add-Member -NotePropertyName $paramName -NotePropertyValue $sourceParameters.$paramName -Force
          }
        }
      }
    }

    # CANONICAL FIX: Replace .Count property with PSCustomObject member count
    $paramCount = ($standardParams | Get-Member -MemberType NoteProperty).Count
    $this.logger.LogDebug("Extracted $paramCount standard parameters for tool orchestration", "ToolOrchestration")
    return $standardParams
  }

  # ========================================
  # TOOL EXECUTION METHODS
  # ========================================

  [object] InvokeNSXPolicyExport([object]$parameters) {
    <#
        .SYNOPSIS
            Invokes NSXPolicyConfigExport.ps1 with standardized parameters

        .DESCRIPTION
            Executes the policy export tool with proper parameter passing and result capture

        .PARAMETER parameters
            Parameters to pass to the export tool

        .OUTPUTS
            Returns execution result object
        #>

    $toolPath = Join-Path $this.toolsPath "NSXPolicyConfigExport.ps1"
    $this.logger.LogInfo("Invoking NSXPolicyConfigExport tool", "ToolOrchestration")

    try {
      # Build parameter string
      $paramString = $this.BuildParameterString($parameters)

      # Execute tool
      $this.logger.LogDebug("Executing: $toolPath $paramString", "ToolOrchestration")

      # Use splatting for proper parameter passing
      $result = & $toolPath @parameters

      $this.logger.LogInfo("NSXPolicyConfigExport completed successfully", "ToolOrchestration")
      return @{
        Success    = $true
        Tool       = "NSXPolicyConfigExport"
        Result     = $result
        Parameters = $parameters
      }
    }
    catch {
      $this.logger.LogError("NSXPolicyConfigExport failed: $($_.Exception.Message)", "ToolOrchestration")
      return @{
        Success    = $false
        Tool       = "NSXPolicyConfigExport"
        Error      = $_.Exception.Message
        Parameters = $parameters
      }
    }
  }

  [object] InvokeApplyNSXConfig([object]$parameters) {
    <#
        .SYNOPSIS
            Invokes ApplyNSXConfig.ps1 with standardized parameters

        .DESCRIPTION
            Executes the config apply tool with proper parameter passing and result capture

        .PARAMETER parameters
            Parameters to pass to the apply tool

        .OUTPUTS
            Returns execution result object
        #>

    $toolPath = Join-Path $this.toolsPath "ApplyNSXConfig.ps1"
    $this.logger.LogInfo("Invoking ApplyNSXConfig tool", "ToolOrchestration")

    try {
      # Execute tool with splatting
      $result = & $toolPath @parameters

      $this.logger.LogInfo("ApplyNSXConfig completed successfully", "ToolOrchestration")
      return @{
        Success    = $true
        Tool       = "ApplyNSXConfig"
        Result     = $result
        Parameters = $parameters
      }
    }
    catch {
      $this.logger.LogError("ApplyNSXConfig failed: $($_.Exception.Message)", "ToolOrchestration")
      return @{
        Success    = $false
        Tool       = "ApplyNSXConfig"
        Error      = $_.Exception.Message
        Parameters = $parameters
      }
    }
  }

  [object] InvokeNSXConfigDifferential([object]$parameters) {
    <#
        .SYNOPSIS
            Invokes ApplyNSXConfigDifferential.ps1 with standardized parameters

        .DESCRIPTION
            Executes the differential config tool with proper parameter passing and result capture

        .PARAMETER parameters
            Parameters to pass to the differential tool

        .OUTPUTS
            Returns execution result object
        #>

    $toolPath = Join-Path $this.toolsPath "ApplyNSXConfigDifferential.ps1"
    $this.logger.LogInfo("Invoking ApplyNSXConfigDifferential tool", "ToolOrchestration")

    try {
      # Execute tool with splatting
      $result = & $toolPath @parameters

      $this.logger.LogInfo("ApplyNSXConfigDifferential completed successfully", "ToolOrchestration")
      return @{
        Success    = $true
        Tool       = "ApplyNSXConfigDifferential"
        Result     = $result
        Parameters = $parameters
      }
    }
    catch {
      $this.logger.LogError("ApplyNSXConfigDifferential failed: $($_.Exception.Message)", "ToolOrchestration")
      return @{
        Success    = $false
        Tool       = "ApplyNSXConfigDifferential"
        Error      = $_.Exception.Message
        Parameters = $parameters
      }
    }
  }

  [object] InvokeVerifyConfiguration([object]$parameters) {
    <#
        .SYNOPSIS
            Invokes VerifyNSXConfiguration.ps1 with standardized parameters

        .DESCRIPTION
            Executes the verification tool with proper parameter passing and result capture

        .PARAMETER parameters
            Parameters to pass to the verification tool

        .OUTPUTS
            Returns execution result object
        #>

    $toolPath = Join-Path $this.toolsPath "VerifyNSXConfiguration.ps1"
    $this.logger.LogInfo("Invoking VerifyNSXConfiguration tool", "ToolOrchestration")

    try {
      # Execute tool with splatting
      $result = & $toolPath @parameters

      $this.logger.LogInfo("VerifyNSXConfiguration completed successfully", "ToolOrchestration")
      return @{
        Success    = $true
        Tool       = "VerifyNSXConfiguration"
        Result     = $result
        Parameters = $parameters
      }
    }
    catch {
      $this.logger.LogError("VerifyNSXConfiguration failed: $($_.Exception.Message)", "ToolOrchestration")
      return @{
        Success    = $false
        Tool       = "VerifyNSXConfiguration"
        Error      = $_.Exception.Message
        Parameters = $parameters
      }
    }
  }

  # ========================================
  # WORKFLOW ORCHESTRATION METHODS
  # ========================================

  [object] ExecuteExportApplyWorkflow([string]$sourceNSXManager, [string]$targetNSXManager, [object]$baseParameters) {
    <#
        .SYNOPSIS
            Executes a complete export-then-apply workflow

        .DESCRIPTION
            Orchestrates the export of configuration from source NSX manager and
            application to target NSX manager with proper parameter passing

        .PARAMETER sourceNSXManager
            Source NSX Manager to export from

        .PARAMETER targetNSXManager
            Target NSX Manager to apply to

        .PARAMETER baseParameters
            Base parameters to use for both operations

        .OUTPUTS
            Returns workflow execution result object
        #>

    $this.logger.LogInfo("Starting Export-Apply workflow: $sourceNSXManager -> $targetNSXManager", "ToolOrchestration")

    $workflowResult = [PSCustomObject]@{
      Success       = $false
      SourceManager = $sourceNSXManager
      TargetManager = $targetNSXManager
      ExportResult  = $null
      ApplyResult   = $null
      ConfigFile    = $null
    }

    try {
      # Step 1: Export from source
      $exportParams = $baseParameters.Clone()
      $exportParams['NSXManager'] = $sourceNSXManager
      $exportParams['OutputDirectory'] = $baseParameters['OutputDirectory']

      # Generate unique config file name
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
      $configFileName = "sync_config_${timestamp}.json"
      $configFilePath = Join-Path $exportParams['OutputDirectory'] $configFileName
      $exportParams['OutputFile'] = $configFilePath

      $this.logger.LogInfo("Step 1: Exporting configuration from $sourceNSXManager", "ToolOrchestration")
      $exportResult = $this.InvokeNSXPolicyExport($exportParams)
      $workflowResult.ExportResult = $exportResult
      $workflowResult.ConfigFile = $configFilePath

      if (-not $exportResult.Success) {
        throw "Export from source NSX Manager failed: $($exportResult.Error)"
      }

      # Step 2: Apply to target
      $applyParams = $baseParameters.Clone()
      $applyParams['NSXManager'] = $targetNSXManager
      $applyParams['ConfigFile'] = $configFilePath
      $applyParams['ApplyConfig'] = $true

      $this.logger.LogInfo("Step 2: Applying configuration to $targetNSXManager", "ToolOrchestration")
      $applyResult = $this.InvokeApplyNSXConfig($applyParams)
      $workflowResult.ApplyResult = $applyResult

      if (-not $applyResult.Success) {
        throw "Apply to target NSX Manager failed: $($applyResult.Error)"
      }

      $workflowResult.Success = $true
      $this.logger.LogInfo("Export-Apply workflow completed successfully", "ToolOrchestration")

      return $workflowResult
    }
    catch {
      $this.logger.LogError("Export-Apply workflow failed: $($_.Exception.Message)", "ToolOrchestration")
      $workflowResult.Error = $_.Exception.Message
      return $workflowResult
    }
  }

  [object] ExecuteSyncWorkflow([string]$sourceNSXManager, [string]$targetNSXManager, [object]$baseParameters) {
    <#
        .SYNOPSIS
            Executes a complete synchronization workflow with differential application

        .DESCRIPTION
            Orchestrates export from source, export baseline from target, differential analysis,
            and application of only the differences

        .PARAMETER sourceNSXManager
            Source NSX Manager to sync from

        .PARAMETER targetNSXManager
            Target NSX Manager to sync to

        .PARAMETER baseParameters
            Base parameters to use for operations

        .OUTPUTS
            Returns sync workflow execution result object
        #>

    $this.logger.LogInfo("Starting Sync workflow with differential analysis: $sourceNSXManager -> $targetNSXManager", "ToolOrchestration")

    $workflowResult = [PSCustomObject]@{
      Success              = $false
      SourceManager        = $sourceNSXManager
      TargetManager        = $targetNSXManager
      SourceExportResult   = $null
      TargetBaselineResult = $null
      DifferentialResult   = $null
      VerificationResult   = $null
    }

    try {
      $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

      # Step 1: Export source configuration
      $sourceParams = $baseParameters.Clone()
      $sourceParams['NSXManager'] = $sourceNSXManager
      $sourceConfigFile = Join-Path $baseParameters['OutputDirectory'] "source_config_${timestamp}.json"
      $sourceParams['OutputFile'] = $sourceConfigFile

      $this.logger.LogInfo("Step 1: Exporting source configuration from $sourceNSXManager", "ToolOrchestration")
      $sourceExportResult = $this.InvokeNSXPolicyExport($sourceParams)
      $workflowResult.SourceExportResult = $sourceExportResult

      if (-not $sourceExportResult.Success) {
        throw "Source export failed: $($sourceExportResult.Error)"
      }

      # Step 2: Export target baseline
      $targetParams = $baseParameters.Clone()
      $targetParams['NSXManager'] = $targetNSXManager
      $targetBaselineFile = Join-Path $baseParameters['OutputDirectory'] "target_baseline_${timestamp}.json"
      $targetParams['OutputFile'] = $targetBaselineFile

      $this.logger.LogInfo("Step 2: Exporting target baseline from $targetNSXManager", "ToolOrchestration")
      $targetBaselineResult = $this.InvokeNSXPolicyExport($targetParams)
      $workflowResult.TargetBaselineResult = $targetBaselineResult

      if (-not $targetBaselineResult.Success) {
        throw "Target baseline export failed: $($targetBaselineResult.Error)"
      }

      # Step 3: Apply differential configuration
      $diffParams = $baseParameters.Clone()
      $diffParams['NSXManager'] = $targetNSXManager
      $diffParams['SourceConfigFile'] = $sourceConfigFile
      $diffParams['TargetConfigFile'] = $targetBaselineFile
      $diffParams['ApplyDifferences'] = $true

      $this.logger.LogInfo("Step 3: Applying differential configuration to $targetNSXManager", "ToolOrchestration")
      $differentialResult = $this.InvokeNSXConfigDifferential($diffParams)
      $workflowResult.DifferentialResult = $differentialResult

      if (-not $differentialResult.Success) {
        throw "Differential application failed: $($differentialResult.Error)"
      }

      # Step 4: Verify final configuration
      $verifyParams = $baseParameters.Clone()
      $verifyParams['NSXManager'] = $targetNSXManager
      $verifyParams['ExpectedConfigFile'] = $sourceConfigFile

      $this.logger.LogInfo("Step 4: Verifying final configuration on $targetNSXManager", "ToolOrchestration")
      $verificationResult = $this.InvokeVerifyConfiguration($verifyParams)
      $workflowResult.VerificationResult = $verificationResult

      if (-not $verificationResult.Success) {
        $this.logger.LogWarning("Verification failed, but sync may have succeeded: $($verificationResult.Error)", "ToolOrchestration")
      }

      $workflowResult.Success = $true
      $this.logger.LogInfo("Sync workflow completed successfully", "ToolOrchestration")

      return $workflowResult
    }
    catch {
      $this.logger.LogError("Sync workflow failed: $($_.Exception.Message)", "ToolOrchestration")
      $workflowResult.Error = $_.Exception.Message
      return $workflowResult
    }
  }

  # ========================================
  # UTILITY METHODS
  # ========================================

  [string] BuildParameterString([object]$parameters) {
    <#
        .SYNOPSIS
            Builds parameter string for command line execution

        .DESCRIPTION
            Converts parameter hashtable to properly formatted command line string

        .PARAMETER parameters
            Parameter hashtable to convert

        .OUTPUTS
            Returns formatted parameter string
        #>

    $paramParts = @()

    foreach ($key in $parameters.Keys) {
      $value = $parameters[$key]

      if ($value -is [switch] -or $value -is [bool]) {
        if ($value) {
          $paramParts += "-$key"
        }
      }
      elseif ($value -is [string] -and -not [string]::IsNullOrWhiteSpace($value)) {
        $paramParts += "-$key `"$value`""
      }
      elseif ($null -ne $value) {
        $paramParts += "-$key `"$value`""
      }
    }

    return $paramParts -join " "
  }

  [bool] ValidateToolExists([string]$toolName) {
    <#
        .SYNOPSIS
            Validates that a tool script exists

        .DESCRIPTION
            Checks if the specified tool script exists in the tools directory

        .PARAMETER toolName
            Name of the tool script to validate

        .OUTPUTS
            Returns true if tool exists, false otherwise
        #>

    $toolPath = Join-Path $this.toolsPath "$toolName.ps1"
    $exists = Test-Path $toolPath

    if (-not $exists) {
      $this.logger.LogWarning("Tool not found: $toolPath", "ToolOrchestration")
    }

    return $exists
  }
}
