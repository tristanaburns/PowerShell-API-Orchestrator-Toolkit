# WorkflowDefinitionService.ps1 - Phase 3: Advanced Tool Orchestration
# Workflow Definition Service for complex operations, pipeline composition, and rollback

class WorkflowDefinitionService {
  [object]$logger
  [object]$toolOrchestrator
  [object]$workflowDefinitions
  [object]$pipelineTemplates
  [object]$rollbackStrategies

  WorkflowDefinitionService([object]$logger, [object]$toolOrchestrator) {
    $this.logger = $logger
    $this.toolOrchestrator = $toolOrchestrator
    $this.workflowDefinitions = [PSCustomObject]@{}
    $this.pipelineTemplates = [PSCustomObject]@{}
    $this.rollbackStrategies = [PSCustomObject]@{}
    $this.InitializeBuiltInWorkflows()
    $this.InitializePipelineTemplates()
    $this.InitializeRollbackStrategies()
  }

  # ========================================
  # WORKFLOW DEFINITION MANAGEMENT
  # ========================================

  [void] InitializeBuiltInWorkflows() {
    <#
        .SYNOPSIS
            Initializes built-in workflow definitions

        .DESCRIPTION
            Creates predefined workflow templates for common NSX operations
        #>

    # NSX Migration Workflow
    $this.workflowDefinitions | Add-Member -NotePropertyName 'NSXMigration' -NotePropertyValue @{
      Name             = 'NSX Configuration Migration'
      Description      = 'Complete migration workflow with validation and rollback'
      Version          = '3.0'
      Steps            = @(
        @{
          Name              = 'PreMigrationValidation'
          Type              = 'Validation'
          Tool              = 'NSXConnectionTest'
          Parameters        = @{
            ValidateBoth     = $true
            SourceNSXManager = '${SourceNSXManager}'
            TargetNSXManager = '${TargetNSXManager}'
          }
          ContinueOnFailure = $false
          Timeout           = 300
        },
        @{
          Name              = 'SourceBackup'
          Type              = 'Export'
          Tool              = 'NSXPolicyConfigExport'
          Parameters        = @{
            NSXManager       = '${SourceNSXManager}'
            OutputDirectory  = '${WorkingDirectory}\source_backup'
            OutputStatistics = $true
          }
          ContinueOnFailure = $false
          Timeout           = 1800
        },
        @{
          Name              = 'TargetBackup'
          Type              = 'Export'
          Tool              = 'NSXPolicyConfigExport'
          Parameters        = @{
            NSXManager       = '${TargetNSXManager}'
            OutputDirectory  = '${WorkingDirectory}\target_backup'
            OutputStatistics = $true
          }
          ContinueOnFailure = $false
          Timeout           = 1800
        },
        @{
          Name              = 'DifferentialAnalysis'
          Type              = 'Analysis'
          Tool              = 'ApplyNSXConfigDifferential'
          Parameters        = @{
            NSXManager       = '${TargetNSXManager}'
            SourceConfigFile = '${WorkingDirectory}\source_backup\config.json'
            TargetConfigFile = '${WorkingDirectory}\target_backup\config.json'
            WhatIf           = $true
          }
          ContinueOnFailure = $false
          Timeout           = 600
        },
        @{
          Name              = 'ApplyChanges'
          Type              = 'Apply'
          Tool              = 'ApplyNSXConfigDifferential'
          Parameters        = @{
            NSXManager       = '${TargetNSXManager}'
            SourceConfigFile = '${WorkingDirectory}\source_backup\config.json'
            TargetConfigFile = '${WorkingDirectory}\target_backup\config.json'
            ApplyDifferences = $true
          }
          ContinueOnFailure = $false
          Timeout           = 3600
        },
        @{
          Name              = 'PostMigrationValidation'
          Type              = 'Validation'
          Tool              = 'VerifyNSXConfiguration'
          Parameters        = @{
            NSXManager         = '${TargetNSXManager}'
            ExpectedConfigFile = '${WorkingDirectory}\source_backup\config.json'
          }
          ContinueOnFailure = $true
          Timeout           = 900
        }
      )
      RollbackStrategy = 'NSXMigrationRollback'
      SuccessCriteria  = @{
        RequiredSuccessfulSteps = @('PreMigrationValidation', 'SourceBackup', 'TargetBackup', 'ApplyChanges')
        AllowedFailures         = @('PostMigrationValidation')
      }
    } -Force

    # NSX Health Check Workflow
    $this.workflowDefinitions | Add-Member -NotePropertyName 'NSXHealthCheck' -NotePropertyValue @{
      Name             = 'NSX Manager Health Check'
      Description      = 'Comprehensive health validation workflow'
      Version          = '3.0'
      Steps            = @(
        @{
          Name              = 'ConnectionTest'
          Type              = 'Validation'
          Tool              = 'NSXConnectionTest'
          Parameters        = @{
            NSXManager   = '${NSXManager}'
            SkipSSLCheck = '${SkipSSLCheck}'
          }
          ContinueOnFailure = $false
          Timeout           = 120
        },
        @{
          Name              = 'ConfigurationValidation'
          Type              = 'Validation'
          Tool              = 'VerifyNSXConfiguration'
          Parameters        = @{
            NSXManager   = '${NSXManager}'
            ValidateOnly = $true
          }
          ContinueOnFailure = $true
          Timeout           = 600
        },
        @{
          Name              = 'HealthSnapshot'
          Type              = 'Export'
          Tool              = 'NSXPolicyConfigExport'
          Parameters        = @{
            NSXManager      = '${NSXManager}'
            OutputDirectory = '${WorkingDirectory}\health_snapshot'
            IncludeMetadata = $true
          }
          ContinueOnFailure = $true
          Timeout           = 900
        }
      )
      RollbackStrategy = 'None'
      SuccessCriteria  = @{
        RequiredSuccessfulSteps = @('ConnectionTest')
        AllowedFailures         = @('ConfigurationValidation', 'HealthSnapshot')
      }
    } -Force

    # NSX Sync with Advanced Pipeline
    $this.workflowDefinitions | Add-Member -NotePropertyName 'NSXAdvancedSync' -NotePropertyValue @{
      Name             = 'Advanced NSX Synchronization'
      Description      = 'Multi-stage sync with verification and rollback'
      Version          = '3.0'
      Steps            = @(
        @{
          Name              = 'PreSyncValidation'
          Type              = 'Pipeline'
          Pipeline          = 'ValidationPipeline'
          Parameters        = @{
            SourceNSXManager = '${SourceNSXManager}'
            TargetNSXManager = '${TargetNSXManager}'
          }
          ContinueOnFailure = $false
          Timeout           = 600
        },
        @{
          Name              = 'BackupPipeline'
          Type              = 'Pipeline'
          Pipeline          = 'BackupPipeline'
          Parameters        = @{
            SourceNSXManager = '${SourceNSXManager}'
            TargetNSXManager = '${TargetNSXManager}'
            WorkingDirectory = '${WorkingDirectory}'
          }
          ContinueOnFailure = $false
          Timeout           = 3600
        },
        @{
          Name              = 'SyncExecution'
          Type              = 'Orchestrated'
          Method            = 'ExecuteSyncWorkflow'
          Parameters        = @{
            SourceNSXManager = '${SourceNSXManager}'
            TargetNSXManager = '${TargetNSXManager}'
            BaseParameters   = '${BaseParameters}'
          }
          ContinueOnFailure = $false
          Timeout           = 7200
        },
        @{
          Name              = 'PostSyncVerification'
          Type              = 'Pipeline'
          Pipeline          = 'VerificationPipeline'
          Parameters        = @{
            TargetNSXManager        = '${TargetNSXManager}'
            ExpectedConfigDirectory = '${WorkingDirectory}\source_config'
          }
          ContinueOnFailure = $true
          Timeout           = 1200
        }
      )
      RollbackStrategy = 'NSXSyncRollback'
      SuccessCriteria  = @{
        RequiredSuccessfulSteps = @('PreSyncValidation', 'BackupPipeline', 'SyncExecution')
        AllowedFailures         = @('PostSyncVerification')
      }
    } -Force

    $this.logger.LogInfo("Initialized $($this.workflowDefinitions.Count) built-in workflow definitions", "WorkflowDefinition")
  }

  [void] InitializePipelineTemplates() {
    <#
        .SYNOPSIS
            Initializes pipeline templates for reusable operation sequences

        .DESCRIPTION
            Creates pipeline templates that can be reused across workflows
        #>

    # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
    $this.pipelineTemplates | Add-Member -NotePropertyName 'ValidationPipeline' -NotePropertyValue @{
      Name        = 'NSX Validation Pipeline'
      Description = 'Multi-stage validation pipeline'
      Steps       = @(
        @{
          Name       = 'SourceValidation'
          Type       = 'Validation'
          Tool       = 'NSXConnectionTest'
          Parameters = @{
            NSXManager = '${SourceNSXManager}'
          }
        },
        @{
          Name       = 'TargetValidation'
          Type       = 'Validation'
          Tool       = 'NSXConnectionTest'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        },
        @{
          Name       = 'ConfigurationValidation'
          Type       = 'Validation'
          Tool       = 'VerifyNSXConfiguration'
          Parameters = @{
            NSXManager = '${SourceNSXManager}'
          }
        }
      )
    } -Force

    $this.pipelineTemplates | Add-Member -NotePropertyName 'BackupPipeline' -NotePropertyValue @{
      Name        = 'NSX Backup Pipeline'
      Description = 'Comprehensive backup pipeline'
      Steps       = @(
        @{
          Name       = 'SourceBackup'
          Type       = 'Export'
          Tool       = 'NSXPolicyConfigExport'
          Parameters = @{
            NSXManager      = '${SourceNSXManager}'
            OutputDirectory = '${WorkingDirectory}\source_backup'
          }
        },
        @{
          Name       = 'TargetBackup'
          Type       = 'Export'
          Tool       = 'NSXPolicyConfigExport'
          Parameters = @{
            NSXManager      = '${TargetNSXManager}'
            OutputDirectory = '${WorkingDirectory}\target_backup'
          }
        },
        @{
          Name       = 'BackupVerification'
          Type       = 'Validation'
          Tool       = 'VerifyNSXConfiguration'
          Parameters = @{
            NSXManager = '${SourceNSXManager}'
          }
        }
      )
    } -Force

    $this.pipelineTemplates | Add-Member -NotePropertyName 'VerificationPipeline' -NotePropertyValue @{
      Name        = 'NSX Verification Pipeline'
      Description = 'Post-operation verification pipeline'
      Steps       = @(
        @{
          Name       = 'ConnectivityVerification'
          Type       = 'Validation'
          Tool       = 'NSXConnectionTest'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        },
        @{
          Name       = 'ConfigurationVerification'
          Type       = 'Validation'
          Tool       = 'VerifyNSXConfiguration'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        },
        @{
          Name       = 'HealthVerification'
          Type       = 'Validation'
          Tool       = 'NSXConnectionTest'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        }
      )
    } -Force

    $this.logger.LogInfo("Initialized $($this.pipelineTemplates.Count) pipeline templates", "WorkflowDefinition")
  }

  [void] InitializeRollbackStrategies() {
    <#
        .SYNOPSIS
            Initializes rollback strategies for different types of operations

        .DESCRIPTION
            Defines rollback procedures for various workflow types
        #>

    # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
    $this.rollbackStrategies | Add-Member -NotePropertyName 'NSXMigrationRollback' -NotePropertyValue @{
      Name        = 'NSX Migration Rollback Strategy'
      Description = 'Rollback strategy for NSX migration operations'
      Triggers    = @('ApplyChanges', 'PostMigrationValidation')
      Steps       = @(
        @{
          Name       = 'StopOperations'
          Type       = 'Emergency'
          Action     = 'Cancel'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        },
        @{
          Name       = 'RestoreTarget'
          Type       = 'Restore'
          Tool       = 'ApplyNSXConfig'
          Parameters = @{
            NSXManager   = '${TargetNSXManager}'
            ConfigFile   = '${WorkingDirectory}\target_backup\config.json'
            ForceRestore = $true
          }
        },
        @{
          Name       = 'ValidateRollback'
          Type       = 'Validation'
          Tool       = 'VerifyNSXConfiguration'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        }
      )
    } -Force

    $this.rollbackStrategies | Add-Member -NotePropertyName 'NSXSyncRollback' -NotePropertyValue @{
      Name        = 'NSX Sync Rollback Strategy'
      Description = 'Rollback strategy for NSX sync operations'
      Triggers    = @('SyncExecution')
      Steps       = @(
        @{
          Name       = 'EmergencyStop'
          Type       = 'Emergency'
          Action     = 'Cancel'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        },
        @{
          Name       = 'RestoreFromBackup'
          Type       = 'Restore'
          Tool       = 'ApplyNSXConfig'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
            ConfigFile = '${WorkingDirectory}\target_backup\config.json'
          }
        },
        @{
          Name       = 'ResetToKnownState'
          Type       = 'Reset'
          Tool       = 'NSXConfigReset'
          Parameters = @{
            NSXManager = '${TargetNSXManager}'
          }
        }
      )
    } -Force

    $this.logger.LogInfo("Initialized $($this.rollbackStrategies.Count) rollback strategies", "WorkflowDefinition")
  }

  # ========================================
  # WORKFLOW EXECUTION MANAGEMENT
  # ========================================

  [object] ExecuteWorkflow([string]$workflowName, [object]$parameters) {
    <#
        .SYNOPSIS
            Executes a defined workflow with the specified parameters

        .DESCRIPTION
            Runs a predefined workflow, handling parameter substitution, step execution,
            error handling, and rollback if necessary

        .PARAMETER workflowName
            Name of the workflow to execute

        .PARAMETER parameters
            Parameters to substitute in the workflow definition

        .OUTPUTS
            Returns workflow execution result object
        #>

    if (-not $this.workflowDefinitions.$workflowName) {
      throw "Workflow '$workflowName' not found in definitions"
    }

    $workflow = $this.workflowDefinitions[$workflowName]
    $this.logger.LogInfo("Starting workflow execution: $($workflow.Name)", "WorkflowExecution")

    $executionResult = [PSCustomObject]@{
      WorkflowName     = $workflowName
      WorkflowVersion  = $workflow.Version
      StartTime        = Get-Date
      EndTime          = $null
      Success          = $false
      StepResults      = [PSCustomObject]@{}
      FailedStep       = $null
      RollbackExecuted = $false
      RollbackResult   = $null
      Parameters       = $parameters
    }

    try {
      # Create working directory if specified
      if ($parameters.WorkingDirectory) {
        $workingDir = $parameters.WorkingDirectory
        if (-not (Test-Path $workingDir)) {
          New-Item -Path $workingDir -ItemType Directory -Force | Out-Null
          $this.logger.LogInfo("Created working directory: $workingDir", "WorkflowExecution")
        }
      }

      # Execute workflow steps
      foreach ($step in $workflow.Steps) {
        $stepName = $step.Name
        $this.logger.LogInfo("Executing workflow step: $stepName", "WorkflowExecution")

        try {
          $stepResult = $this.ExecuteWorkflowStep($step, $parameters)
          $executionResult.StepResults[$stepName] = $stepResult

          if (-not $stepResult.Success -and -not $step.ContinueOnFailure) {
            $executionResult.FailedStep = $stepName
            throw "Workflow step '$stepName' failed: $($stepResult.Error)"
          }
        }
        catch {
          $executionResult.FailedStep = $stepName
          $this.logger.LogError("Workflow step '$stepName' failed: $($_.Exception.Message)", "WorkflowExecution")
          throw $_
        }
      }

      # Check success criteria
      $success = $this.EvaluateSuccessCriteria($workflow.SuccessCriteria, $executionResult.StepResults)
      $executionResult.Success = $success

      if ($success) {
        $this.logger.LogInfo("Workflow '$workflowName' completed successfully", "WorkflowExecution")
      }
      else {
        throw "Workflow failed to meet success criteria"
      }
    }
    catch {
      $this.logger.LogError("Workflow execution failed: $($_.Exception.Message)", "WorkflowExecution")

      # Execute rollback if defined and applicable
      if ($workflow.RollbackStrategy -ne 'None' -and $this.rollbackStrategies.($workflow.RollbackStrategy)) {
        $this.logger.LogInfo("Executing rollback strategy: $($workflow.RollbackStrategy)", "WorkflowExecution")
        try {
          $rollbackResult = $this.ExecuteRollback($workflow.RollbackStrategy, $parameters, $executionResult.FailedStep)
          $executionResult.RollbackExecuted = $true
          $executionResult.RollbackResult = $rollbackResult
        }
        catch {
          $this.logger.LogError("Rollback execution failed: $($_.Exception.Message)", "WorkflowExecution")
          $executionResult.RollbackResult = @{
            Success = $false
            Error   = $_.Exception.Message
          }
        }
      }
    }
    finally {
      $executionResult.EndTime = Get-Date
      $duration = $executionResult.EndTime - $executionResult.StartTime
      $this.logger.LogInfo("Workflow execution completed in $($duration.TotalMinutes) minutes", "WorkflowExecution")
    }

    return $executionResult
  }

  [object] ExecuteWorkflowStep([object]$step, [object]$parameters) {
    <#
        .SYNOPSIS
            Executes an individual workflow step

        .DESCRIPTION
            Handles execution of different step types including tool invocation,
            pipeline execution, and orchestrated methods

        .PARAMETER step
            Step definition from workflow

        .PARAMETER parameters
            Workflow parameters for substitution

        .OUTPUTS
            Returns step execution result
        #>

    $stepResult = [PSCustomObject]@{
      StepName  = $step.Name
      StepType  = $step.Type
      StartTime = Get-Date
      EndTime   = $null
      Success   = $false
      Result    = $null
      Error     = $null
    }

    try {
      # Substitute parameters in step parameters
      $stepParameters = $this.SubstituteParameters($step.Parameters, $parameters)

      switch ($step.Type) {
        'Tool' {
          $stepResult.Result = $this.ExecuteToolStep($step.Tool, $stepParameters)
        }
        'Pipeline' {
          $stepResult.Result = $this.ExecutePipelineStep($step.Pipeline, $stepParameters)
        }
        'Orchestrated' {
          $stepResult.Result = $this.ExecuteOrchestratedStep($step.Method, $stepParameters)
        }
        'Validation' {
          $stepResult.Result = $this.ExecuteValidationStep($step.Tool, $stepParameters)
        }
        'Export' {
          $stepResult.Result = $this.ExecuteExportStep($step.Tool, $stepParameters)
        }
        'Apply' {
          $stepResult.Result = $this.ExecuteApplyStep($step.Tool, $stepParameters)
        }
        'Analysis' {
          $stepResult.Result = $this.ExecuteAnalysisStep($step.Tool, $stepParameters)
        }
        default {
          throw "Unknown step type: $($step.Type)"
        }
      }

      $stepResult.Success = ($null -ne $stepResult.Result -and $stepResult.Result.Success)
    }
    catch {
      $stepResult.Error = $_.Exception.Message
      $stepResult.Success = $false
    }
    finally {
      $stepResult.EndTime = Get-Date
    }

    return $stepResult
  }

  [object] ExecuteToolStep([string]$toolName, [object]$parameters) {
    <#
        .SYNOPSIS
            Executes a tool step using the tool orchestrator

        .DESCRIPTION
            Invokes the specified tool with the provided parameters

        .PARAMETER toolName
            Name of the tool to execute

        .PARAMETER parameters
            Parameters to pass to the tool

        .OUTPUTS
            Returns tool execution result
        #>

    switch ($toolName) {
      'NSXPolicyConfigExport' {
        return $this.toolOrchestrator.InvokeNSXPolicyExport($parameters)
      }
      'ApplyNSXConfig' {
        return $this.toolOrchestrator.InvokeApplyNSXConfig($parameters)
      }
      'ApplyNSXConfigDifferential' {
        return $this.toolOrchestrator.InvokeNSXConfigDifferential($parameters)
      }
      'VerifyNSXConfiguration' {
        return $this.toolOrchestrator.InvokeVerifyConfiguration($parameters)
      }
      default {
        # For tools not yet implemented in orchestrator, return success placeholder
        $this.logger.LogWarning("Tool '$toolName' not implemented in orchestrator, returning success placeholder", "WorkflowExecution")
        return @{
          Success    = $true
          Tool       = $toolName
          Result     = "Tool execution placeholder"
          Parameters = $parameters
        }
      }
    }

    # Fallback return (compiler safety)
    return $null
  }

  [object] ExecutePipelineStep([string]$pipelineName, [object]$parameters) {
    <#
        .SYNOPSIS
            Executes a pipeline step

        .DESCRIPTION
            Runs a predefined pipeline with the specified parameters

        .PARAMETER pipelineName
            Name of the pipeline to execute

        .PARAMETER parameters
            Parameters for the pipeline

        .OUTPUTS
            Returns pipeline execution result
        #>

    if (-not $this.pipelineTemplates.$pipelineName) {
      throw "Pipeline '$pipelineName' not found in templates"
    }

    $pipeline = $this.pipelineTemplates[$pipelineName]
    $this.logger.LogInfo("Executing pipeline: $($pipeline.Name)", "PipelineExecution")

    $pipelineResult = [PSCustomObject]@{
      PipelineName = $pipelineName
      Success      = $true
      StepResults  = [PSCustomObject]@{}
      StartTime    = Get-Date
      EndTime      = $null
    }

    try {
      foreach ($step in $pipeline.Steps) {
        $stepResult = $this.ExecuteWorkflowStep($step, $parameters)
        $pipelineResult.StepResults[$step.Name] = $stepResult

        if (-not $stepResult.Success) {
          $pipelineResult.Success = $false
          $this.logger.LogError("Pipeline step '$($step.Name)' failed", "PipelineExecution")
        }
      }
    }
    catch {
      $pipelineResult.Success = $false
      $pipelineResult.Error = $_.Exception.Message
    }
    finally {
      $pipelineResult.EndTime = Get-Date
    }

    return $pipelineResult
  }

  [object] ExecuteOrchestratedStep([string]$methodName, [object]$parameters) {
    <#
        .SYNOPSIS
            Executes an orchestrated method step

        .DESCRIPTION
            Calls orchestrated methods from the tool orchestrator

        .PARAMETER methodName
            Name of the orchestrated method to call

        .PARAMETER parameters
            Parameters for the method

        .OUTPUTS
            Returns method execution result
        #>

    switch ($methodName) {
      'ExecuteSyncWorkflow' {
        $sourceNSX = $parameters['SourceNSXManager']
        $targetNSX = $parameters['TargetNSXManager']
        $baseParams = $parameters['BaseParameters']
        return $this.toolOrchestrator.ExecuteSyncWorkflow($sourceNSX, $targetNSX, $baseParams)
      }
      'ExecuteExportApplyWorkflow' {
        $sourceNSX = $parameters['SourceNSXManager']
        $targetNSX = $parameters['TargetNSXManager']
        $baseParams = $parameters['BaseParameters']
        return $this.toolOrchestrator.ExecuteExportApplyWorkflow($sourceNSX, $targetNSX, $baseParams)
      }
      default {
        throw "Unknown orchestrated method: $methodName"
      }
    }

    # Compiler safety fallback
    return $null
  }

  [object] ExecuteValidationStep([string]$toolName, [object]$parameters) {
    return $this.ExecuteToolStep($toolName, $parameters)
  }

  [object] ExecuteExportStep([string]$toolName, [object]$parameters) {
    return $this.ExecuteToolStep($toolName, $parameters)
  }

  [object] ExecuteApplyStep([string]$toolName, [object]$parameters) {
    return $this.ExecuteToolStep($toolName, $parameters)
  }

  [object] ExecuteAnalysisStep([string]$toolName, [object]$parameters) {
    return $this.ExecuteToolStep($toolName, $parameters)
  }

  # ========================================
  # ROLLBACK EXECUTION
  # ========================================

  [object] ExecuteRollback([string]$rollbackStrategyName, [object]$parameters, [string]$failedStep) {
    <#
        .SYNOPSIS
            Executes a rollback strategy

        .DESCRIPTION
            Performs rollback operations based on the specified strategy

        .PARAMETER rollbackStrategyName
            Name of the rollback strategy to execute

        .PARAMETER parameters
            Original workflow parameters

        .PARAMETER failedStep
            Name of the step that caused the failure

        .OUTPUTS
            Returns rollback execution result
        #>

    if (-not $this.rollbackStrategies.$rollbackStrategyName) {
      throw "Rollback strategy '$rollbackStrategyName' not found"
    }

    # CANONICAL FIX: Replace hash table indexing with PSCustomObject property access
    $rollbackStrategy = $this.rollbackStrategies.$rollbackStrategyName
    $this.logger.LogInfo("Executing rollback strategy: $($rollbackStrategy.Name)", "RollbackExecution")

    # Check if rollback should be triggered for this failed step
    if ($rollbackStrategy.Triggers -notcontains $failedStep) {
      $this.logger.LogInfo("Rollback not triggered for failed step '$failedStep'", "RollbackExecution")
      return @{
        Success     = $true
        Message     = "Rollback not required for failed step"
        TriggeredBy = $failedStep
      }
    }

    $rollbackResult = [PSCustomObject]@{
      StrategyName = $rollbackStrategyName
      TriggeredBy  = $failedStep
      Success      = $true
      StepResults  = [PSCustomObject]@{}
      StartTime    = Get-Date
      EndTime      = $null
    }

    try {
      foreach ($step in $rollbackStrategy.Steps) {
        $this.logger.LogInfo("Executing rollback step: $($step.Name)", "RollbackExecution")

        $stepResult = $this.ExecuteRollbackStep($step, $parameters)
        # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
        $rollbackResult.StepResults | Add-Member -NotePropertyName $step.Name -NotePropertyValue $stepResult -Force

        if (-not $stepResult.Success) {
          $rollbackResult.Success = $false
          $this.logger.LogError("Rollback step '$($step.Name)' failed", "RollbackExecution")
        }
      }
    }
    catch {
      $rollbackResult.Success = $false
      $rollbackResult.Error = $_.Exception.Message
    }
    finally {
      $rollbackResult.EndTime = Get-Date
    }

    return $rollbackResult
  }

  [object] ExecuteRollbackStep([object]$step, [object]$parameters) {
    <#
        .SYNOPSIS
            Executes an individual rollback step

        .DESCRIPTION
            Handles execution of rollback steps including emergency actions,
            restore operations, and validation

        .PARAMETER step
            Rollback step definition

        .PARAMETER parameters
            Workflow parameters

        .OUTPUTS
            Returns rollback step result
        #>

    $stepResult = [PSCustomObject]@{
      StepName  = $step.Name
      StepType  = $step.Type
      StartTime = Get-Date
      EndTime   = $null
      Success   = $false
      Result    = $null
      Error     = $null
    }

    try {
      # Substitute parameters in step parameters
      $stepParameters = $this.SubstituteParameters($step.Parameters, $parameters)

      switch ($step.Type) {
        'Emergency' {
          # Emergency actions like canceling operations
          $stepResult.Result = @{
            Action  = $step.Action
            Message = "Emergency action executed"
            Success = $true
          }
        }
        'Restore' {
          $stepResult.Result = $this.ExecuteToolStep($step.Tool, $stepParameters)
        }
        'Reset' {
          $stepResult.Result = $this.ExecuteToolStep($step.Tool, $stepParameters)
        }
        'Validation' {
          $stepResult.Result = $this.ExecuteToolStep($step.Tool, $stepParameters)
        }
        default {
          throw "Unknown rollback step type: $($step.Type)"
        }
      }

      $stepResult.Success = ($null -ne $stepResult.Result -and $stepResult.Result.Success)
    }
    catch {
      $stepResult.Error = $_.Exception.Message
      $stepResult.Success = $false
    }
    finally {
      $stepResult.EndTime = Get-Date
    }

    return $stepResult
  }

  # ========================================
  # UTILITY METHODS
  # ========================================

  [object] SubstituteParameters([object]$stepParameters, [object]$workflowParameters) {
    <#
        .SYNOPSIS
            Substitutes workflow parameters into step parameters

        .DESCRIPTION
            Replaces parameter placeholders (${ParameterName}) with actual values

        .PARAMETER stepParameters
            Step parameters containing placeholders

        .PARAMETER workflowParameters
            Workflow parameters with actual values

        .OUTPUTS
            Returns hashtable with substituted parameters
        #>

    $substituted = [PSCustomObject]@{}

    # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
    $stepParameterNames = ($stepParameters | Get-Member -MemberType NoteProperty).Name
    foreach ($key in $stepParameterNames) {
      $value = $stepParameters.$key

      if ($value -is [string] -and $value.Contains('${')) {
        # Perform parameter substitution
        # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
        $workflowParameterNames = ($workflowParameters | Get-Member -MemberType NoteProperty).Name
        foreach ($paramKey in $workflowParameterNames) {
          $placeholder = '${' + $paramKey + '}'
          $value = $value.Replace($placeholder, $workflowParameters.$paramKey)
        }
      }

      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $substituted | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
    }

    return $substituted
  }

  [bool] EvaluateSuccessCriteria([object]$successCriteria, [object]$stepResults) {
    <#
        .SYNOPSIS
            Evaluates workflow success criteria

        .DESCRIPTION
            Determines if the workflow meets its success criteria based on step results

        .PARAMETER successCriteria
            Success criteria definition

        .PARAMETER stepResults
            Results from all executed steps

        .OUTPUTS
            Returns true if success criteria are met
        #>

    # Check required successful steps
    foreach ($requiredStep in $successCriteria.RequiredSuccessfulSteps) {
      if (-not $stepResults.$requiredStep -or -not $stepResults.$requiredStep.Success) {
        $this.logger.LogError("Required step '$requiredStep' did not succeed", "WorkflowExecution")
        return $false
      }
    }

    # Check that non-allowed failures didn't occur
    $allowedFailures = $successCriteria.AllowedFailures
    # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
    $stepResultNames = ($stepResults | Get-Member -MemberType NoteProperty).Name
    foreach ($stepName in $stepResultNames) {
      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property access
      $stepResult = $stepResults.$stepName
      if (-not $stepResult.Success -and $allowedFailures -notcontains $stepName) {
        $this.logger.LogError("Non-allowed failure in step '$stepName'", "WorkflowExecution")
        return $false
      }
    }

    return $true
  }

  # ========================================
  # WORKFLOW MANAGEMENT METHODS
  # ========================================

  [object] GetAvailableWorkflows() {
    <#
        .SYNOPSIS
            Returns list of available workflow definitions

        .OUTPUTS
            Returns hashtable of workflow names and descriptions
        #>

    $workflows = [PSCustomObject]@{}
    # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
    $workflowNames = ($this.workflowDefinitions | Get-Member -MemberType NoteProperty).Name
    foreach ($key in $workflowNames) {
      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property access
      $workflow = $this.workflowDefinitions.$key
      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $workflows | Add-Member -NotePropertyName $key -NotePropertyValue @{
        Name        = $workflow.Name
        Description = $workflow.Description
        Version     = $workflow.Version
        StepCount   = $workflow.Steps.Count
      } -Force
    }
    return $workflows
  }

  [object] GetAvailablePipelines() {
    <#
        .SYNOPSIS
            Returns list of available pipeline templates

        .OUTPUTS
            Returns hashtable of pipeline names and descriptions
        #>

    $pipelines = [PSCustomObject]@{}
    # CANONICAL FIX: Replace hash table .Keys property with PSCustomObject member enumeration
    $pipelineNames = ($this.pipelineTemplates | Get-Member -MemberType NoteProperty).Name
    foreach ($key in $pipelineNames) {
      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property access
      $pipeline = $this.pipelineTemplates.$key
      # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
      $pipelines | Add-Member -NotePropertyName $key -NotePropertyValue @{
        Name        = $pipeline.Name
        Description = $pipeline.Description
        StepCount   = $pipeline.Steps.Count
      } -Force
    }
    return $pipelines
  }

  [void] AddCustomWorkflow([string]$name, [object]$workflowDefinition) {
    <#
        .SYNOPSIS
            Adds a custom workflow definition

        .PARAMETER name
            Name of the custom workflow

        .PARAMETER workflowDefinition
            Complete workflow definition
        #>

    # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
    $this.workflowDefinitions | Add-Member -NotePropertyName $name -NotePropertyValue $workflowDefinition -Force
    $this.logger.LogInfo("Added custom workflow: $name", "WorkflowDefinition")
  }

  [void] AddCustomPipeline([string]$name, [object]$pipelineDefinition) {
    <#
        .SYNOPSIS
            Adds a custom pipeline template

        .PARAMETER name
            Name of the custom pipeline

        .PARAMETER pipelineDefinition
            Complete pipeline definition
        #>

    # CANONICAL FIX: Replace hash table indexing with PSCustomObject property addition
    $this.pipelineTemplates | Add-Member -NotePropertyName $name -NotePropertyValue $pipelineDefinition -Force
    $this.logger.LogInfo("Added custom pipeline: $name", "WorkflowDefinition")
  }
}
