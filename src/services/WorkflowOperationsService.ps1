# WorkflowOperationsService.ps1 - Phase 3: Operational Excellence
# Centralized configuration management, logging/telemetry, and performance monitoring

# Import dependencies
. "$PSScriptRoot\SharedToolUtilityService.ps1"

class WorkflowOperationsService {
  hidden [object] $logger
  hidden [object] $dataObjectFilter
  hidden [object] $workflowOrchestrationService
  hidden [object] $globalConfiguration
  hidden [object] $operationalPolicies
  hidden [object] $telemetryData
  hidden [object] $performanceMetrics
  hidden [object] $performanceTimer
  hidden [object] $toolkitPathsConfig
  hidden [string] $pathsConfigFilePath
  hidden [object] $sharedUtility

  # ========================================
  # CONSTRUCTORS
  # ========================================

  # Constructor - Default JSON configuration (main)
  WorkflowOperationsService([object] $loggingService) {
    $this.logger = $loggingService
    $this.pathsConfigFilePath = "$PSScriptRoot\..\..\config\toolkit-paths.json"
    # ARCHITECTURAL IMPROVEMENT: Lazy load SharedToolUtilityService instead of eager loading
    # $this.sharedUtility = [CoreServiceFactory]::GetSharedToolUtilityService()
    $this.sharedUtility = $null  # Will be lazy-loaded when first needed
    $this.LoadToolkitPathsConfiguration()
    $this.InitializeDefaults()
  }

  # Constructor - Direct configuration object
  WorkflowOperationsService([object] $loggingService, [object] $toolkitPathsConfiguration) {
    $this.logger = $loggingService
    $this.toolkitPathsConfig = $toolkitPathsConfiguration
    $this.pathsConfigFilePath = $null  # Runtime configuration
    # ARCHITECTURAL IMPROVEMENT: Lazy load SharedToolUtilityService instead of eager loading
    # $this.sharedUtility = [CoreServiceFactory]::GetSharedToolUtilityService()
    $this.sharedUtility = $null  # Will be lazy-loaded when first needed
    $this.LoadToolkitPathsConfiguration()
    $this.InitializeDefaults()
  }

  # Constructor - Custom JSON configuration file path
  WorkflowOperationsService([object] $loggingService, [string] $customPathsConfigFile, [object] $runtimeConfig = $null) {
    $this.logger = $loggingService
    $this.pathsConfigFilePath = $customPathsConfigFile
    # ARCHITECTURAL IMPROVEMENT: Lazy load SharedToolUtilityService instead of eager loading
    # $this.sharedUtility = [CoreServiceFactory]::GetSharedToolUtilityService()
    $this.sharedUtility = $null  # Will be lazy-loaded when first needed

    # Load configuration from custom file path
    $this.LoadToolkitPathsConfiguration()

    # Merge with runtime configuration if provided
    if ($runtimeConfig) {
      $this.MergeToolkitPathsConfiguration($runtimeConfig)
    }

    $this.InitializeDefaults()
  }

  # Initialize default values
  hidden [void] InitializeDefaults() {
    $this.globalConfiguration = [PSCustomObject]@{}
    $this.performanceMetrics = [PSCustomObject]@{}
    $this.telemetryData = [PSCustomObject]@{}
    $this.operationalPolicies = [PSCustomObject]@{}
    $this.performanceTimer = [System.Diagnostics.Stopwatch]::new()
  }

  # ========================================
  # CENTRALIZED CONFIGURATION MANAGEMENT
  # ========================================

  [void] LoadGlobalConfiguration() {
    <#
        .SYNOPSIS
            Loads centralized configuration for all tools and operations

        .DESCRIPTION
            Consolidates configuration from multiple sources into a unified structure
        #>

    try {
      # Load base NSX configuration
      $nsxConfig = $this.configService.GetNSXConfiguration()

      # global configuration structure
      $this.globalConfiguration = @{
        NSX         = @{
          DefaultManagers    = $nsxConfig.NSXManagers
          GlobalSSLBypass    = $nsxConfig.SkipSSLCheck
          DefaultTimeout     = 300
          MaxRetries         = 3
          ConnectionPoolSize = 10
        }

        Performance = @{
          MaxConcurrentOperations     = 5
          OperationTimeoutMinutes     = 60
          LongRunningThresholdMinutes = 30
          MemoryThresholdMB           = 2048
          LoggingLevel                = 'Info'
          EnablePerformanceMetrics    = $true
        }

        Reliability = @{
          EnableAutoRetry            = $true
          MaxRetryAttempts           = 3
          RetryDelaySeconds          = 30
          EnableCircuitBreaker       = $true
          CircuitBreakerThreshold    = 5
          EnableHealthChecks         = $true
          HealthCheckIntervalMinutes = 15
        }

        Security    = @{
          EnableCredentialEncryption = $true
          CredentialTimeoutMinutes   = 480
          EnableAuditLogging         = $true
          RequireSSLValidation       = $false  # Due to NSX labs
          EnableRBAC                 = $false
          MaxSessionDurationHours    = 8
        }

        Backup      = @{
          EnableAutoBackup          = $true
          BackupRetentionDays       = 30
          BackupCompressionEnabled  = $true
          BackupVerificationEnabled = $true
          BackupLocationBase        = './backups'
          BackupNamingPattern       = 'backup_{timestamp}_{operation}'
        }

        Monitoring  = @{
          EnableTelemetry      = $true
          MetricsRetentionDays = 7
          EnableAlerts         = $true
          AlertThresholds      = @{
            ErrorRatePercent         = 5
            LatencyMs                = 5000
            MemoryUsageMB            = 1024
            OperationDurationMinutes = 45
          }
          TelemetryExportPath  = './logs/telemetry'
        }

        Workflow    = @{
          EnableWorkflowValidation  = $true
          MaxWorkflowSteps          = 20
          StepTimeoutMinutes        = 30
          EnableStepParallelization = $true
          EnableRollbackOnFailure   = $true
          WorkflowLoggingLevel      = 'Detailed'
        }

        Integration = @{
          EnableServiceDiscovery     = $true
          ServiceRegistrationTimeout = 60
          EnableDependencyValidation = $true
          CrossToolParameterSharing  = $true
          EnableAPIVersionValidation = $true
        }
      }

      $this.logger.LogInfo("Global configuration loaded successfully", "WorkflowOperationsService")
    }
    catch {
      $this.logger.LogError("Failed to load global configuration: $($_.Exception.Message)", "WorkflowOperationsService")
      throw $_
    }
  }

  [object] GetGlobalConfiguration([string]$section = $null) {
    <#
        .SYNOPSIS
            Retrieves global configuration settings

        .PARAMETER section
            Optional section name to retrieve specific configuration

        .OUTPUTS
            Returns configuration PSObject
        #>

    if ($section) {
      if ($this.globalConfiguration.$section) {
        return $this.globalConfiguration.$section
      }
      else {
        $this.logger.LogWarning("Configuration section '$section' not found", "WorkflowOperationsService")
        return [PSCustomObject]@{}
      }
    }

    return $this.globalConfiguration
  }

  [void] UpdateGlobalConfiguration([string]$section, [object]$updates) {
    <#
        .SYNOPSIS
            Updates global configuration settings

        .PARAMETER section
            Configuration section to update

        .PARAMETER updates
            Configuration updates to apply
        #>

    if (-not $this.globalConfiguration.$section) {
      $this.globalConfiguration.$section = [PSCustomObject]@{}
    }

    foreach ($key in $updates.Keys) {
      $this.globalConfiguration[$section][$key] = $updates[$key]
    }

    $this.logger.LogInfo("Updated configuration section '$section'", "WorkflowOperationsService")
  }

  [void] InitializeOperationalPolicies() {
    <#
        .SYNOPSIS
            Initializes operational policies and governance rules

        .DESCRIPTION
            Defines policies for tool execution, error handling, and operational procedures
        #>

    $this.operationalPolicies = @{
      ErrorHandling      = @{
        CriticalErrorActions = @('Log', 'Alert', 'Rollback', 'NotifyAdmin')
        RetryableErrors      = @('Timeout', 'ConnectionError', 'TemporaryFailure')
        NonRetryableErrors   = @('AuthenticationError', 'ConfigurationError', 'ValidationError')
        EscalationThresholds = @{
          ConsecutiveFailures = 3
          ErrorRatePercent    = 10
          CriticalErrorCount  = 1
        }
      }

      ResourceManagement = @{
        MaxMemoryUsageMB       = 2048
        MaxCPUUsagePercent     = 80
        MaxDiskUsageGB         = 10
        CleanupRetentionDays   = 7
        TempFileCleanupEnabled = $true
      }

      SecurityPolicies   = @{
        RequireCredentialValidation = $true
        EnableSessionTimeout        = $true
        RequireSSLForProduction     = $false  # Lab environment
        EnableAuditTrail            = $true
        PasswordComplexityRequired  = $false  # Lab environment
      }

      QualityAssurance   = @{
        RequirePreExecutionValidation   = $true
        EnablePostExecutionVerification = $true
        RequireChangeApproval           = $false  # Lab environment
        EnableAutomatedTesting          = $true
        QualityGates                    = @('SyntaxCheck', 'DependencyValidation', 'SecurityScan')
      }

      Compliance         = @{
        EnableChangeTracking       = $true
        RequireDocumentation       = $true
        EnableVersionControl       = $true
        RequireApprovalWorkflow    = $false  # Lab environment
        ComplianceReportingEnabled = $true
      }
    }

    $this.logger.LogInfo("Operational policies initialized", "WorkflowOperationsService")
  }

  # ========================================
  # LOGGING AND TELEMETRY
  # ========================================

  [void] InitializePerformanceMetrics() {
    <#
        .SYNOPSIS
            Initializes performance metrics collection

        .DESCRIPTION
            Sets up performance counters and telemetry collection
        #>

    $this.performanceMetrics = @{
      OperationCounts    = [PSCustomObject]@{}
      OperationDurations = [PSCustomObject]@{}
      ErrorCounts        = [PSCustomObject]@{}
      SuccessRates       = [PSCustomObject]@{}
      ResourceUsage      = @{
        MemoryPeakMB   = 0
        CPUPeakPercent = 0
        DiskUsageGB    = 0
      }
      ThroughputMetrics  = [PSCustomObject]@{}
      LatencyMetrics     = [PSCustomObject]@{}
      ConcurrencyMetrics = @{
        MaxConcurrentOperations = 0
        CurrentActiveOperations = 0
      }
    }

    $this.telemetryData = @{
      Sessions             = [PSCustomObject]@{}
      Operations           = [PSCustomObject]@{}
      Alerts               = [PSCustomObject]@{}
      SystemHealth         = [PSCustomObject]@{}
      ConfigurationChanges = [PSCustomObject]@{}
    }

    $this.logger.LogInfo("Performance metrics initialized", "WorkflowOperationsService")
  }

  [string] StartOperationTelemetry([string]$operationName, [object]$parameters = [PSCustomObject]@{}) {
    <#
        .SYNOPSIS
            Starts telemetry collection for an operation

        .PARAMETER operationName
            Name of the operation to track

        .PARAMETER parameters
            Operation parameters for context

        .OUTPUTS
            Returns operation tracking ID
        #>

    $operationId = [System.Guid]::NewGuid().ToString()
    $startTime = Get-Date

    $operationData = [PSCustomObject]@{
      OperationId   = $operationId
      OperationName = $operationName
      StartTime     = $startTime
      EndTime       = $null
      Duration      = $null
      Success       = $null
      Parameters    = $parameters
      Metrics       = @{
        MemoryStartMB = [System.GC]::GetTotalMemory($false) / 1MB
        CPUStartTime  = ([System.Diagnostics.Process]::GetCurrentProcess()).TotalProcessorTime
      }
      Events        = @()
      Errors        = @()
    }

    $this.telemetryData.Operations[$operationId] = $operationData

    # Update operation counts
    if (-not $this.performanceMetrics.OperationCounts.$operationName) {
      $this.performanceMetrics.OperationCounts.$operationName = 0
    }
    $this.performanceMetrics.OperationCounts.$operationName++

    # Update concurrency metrics
    $this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations++
    if ($this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations -gt $this.performanceMetrics.ConcurrencyMetrics.MaxConcurrentOperations) {
      $this.performanceMetrics.ConcurrencyMetrics.MaxConcurrentOperations = $this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations
    }

    $this.logger.LogInfo("Started operation telemetry: $operationName (ID: $operationId)", "WorkflowOperationsService")
    return $operationId
  }

  [void] EndOperationTelemetry([string]$operationId, [bool]$success, [string]$result = '', [string]$errorMessage = '') {
    <#
        .SYNOPSIS
            Ends telemetry collection for an operation

        .PARAMETER operationId
            Operation tracking ID

        .PARAMETER success
            Whether the operation succeeded

        .PARAMETER result
            Operation result information

        .PARAMETER errorMessage
            Error information if operation failed
        #>

    if (-not $this.telemetryData.Operations.$operationId) {
      $this.logger.LogWarning("Operation ID '$operationId' not found in telemetry data", "WorkflowOperationsService")
      return
    }

    $operationData = $this.telemetryData.Operations[$operationId]
    $endTime = Get-Date
    $duration = $endTime - $operationData.StartTime

    # Ensure all required metrics keys are initialized
    if (-not $operationData.Metrics) { $operationData.Metrics = [PSCustomObject]@{} }
    if (-not $operationData.Metrics.MemoryStartMB) { $operationData.Metrics.MemoryStartMB = 0 }
    if (-not $operationData.Metrics.MemoryEndMB) { $operationData.Metrics.MemoryEndMB = 0 }
    if (-not $operationData.Metrics.CPUEndTime) { $operationData.Metrics.CPUEndTime = 0 }
    if (-not $operationData.Metrics.CPUStartTime) { $operationData.Metrics.CPUStartTime = 0 }
    if (-not $operationData.Metrics.MemoryDeltaMB) { $operationData.Metrics.MemoryDeltaMB = 0 }
    if (-not $operationData.Metrics.CPUDelta) { $operationData.Metrics.CPUDelta = 0 }
    if (-not $operationData.Metrics.Result) { $operationData.Metrics.Result = '' }
    if (-not $operationData.Metrics.Success) { $operationData.Metrics.Success = $null }
    if (-not $operationData.Metrics.OperationName) { $operationData.Metrics.OperationName = '' }
    if (-not $operationData.Metrics.StartTime) { $operationData.Metrics.StartTime = (Get-Date) }
    if (-not $operationData.Metrics.EndTime) { $operationData.Metrics.EndTime = (Get-Date) }
    if (-not $operationData.Metrics.ErrorCounts) { $operationData.Metrics.ErrorCounts = 0 }
    if (-not $operationData.Metrics.SuccessRates) { $operationData.Metrics.SuccessRates = 100 }
    if (-not $operationData.Metrics.MaxConcurrentOperations) { $operationData.Metrics.MaxConcurrentOperations = 0 }
    if (-not $operationData.Metrics.CurrentActiveOperations) { $operationData.Metrics.CurrentActiveOperations = 0 }

    # Update operation data
    $operationData.EndTime = $endTime
    $operationData.Duration = $duration
    $operationData.Success = $success
    $operationData.Result = $result
    if ($errorMessage) {
      $operationData.Errors += $errorMessage
    }

    # Update final metrics
    $operationData.Metrics.MemoryEndMB = [System.GC]::GetTotalMemory($false) / 1MB
    $operationData.Metrics.MemoryDeltaMB = $operationData.Metrics.MemoryEndMB - $operationData.Metrics.MemoryStartMB
    $operationData.Metrics.CPUEndTime = ([System.Diagnostics.Process]::GetCurrentProcess()).TotalProcessorTime
    $operationData.Metrics.CPUDelta = $operationData.Metrics.CPUEndTime - $operationData.Metrics.CPUStartTime

    # Update performance metrics
    $operationName = $operationData.OperationName

    if (-not $this.performanceMetrics.OperationDurations.$operationName) {
      $this.performanceMetrics.OperationDurations.$operationName = @()
    }
    $this.performanceMetrics.OperationDurations.$operationName += $duration.TotalMilliseconds

    if (-not $this.performanceMetrics.ErrorCounts.$operationName) {
      $this.performanceMetrics.ErrorCounts.$operationName = 0
    }
    if (-not $success) {
      $this.performanceMetrics.ErrorCounts[$operationName]++
    }

    # Calculate success rate
    $totalOps = $this.performanceMetrics.OperationCounts[$operationName]
    $errorOps = $this.performanceMetrics.ErrorCounts[$operationName]
    $this.performanceMetrics.SuccessRates[$operationName] = (($totalOps - $errorOps) / $totalOps) * 100

    # Update resource usage peaks
    if (-not $this.performanceMetrics.ResourceUsage) { $this.performanceMetrics.ResourceUsage = [PSCustomObject]@{} }
    if (-not $this.performanceMetrics.ResourceUsage.MemoryPeakMB) { $this.performanceMetrics.ResourceUsage.MemoryPeakMB = 0 }
    if (-not $this.performanceMetrics.ResourceUsage.CPUPeakPercent) { $this.performanceMetrics.ResourceUsage.CPUPeakPercent = 0 }
    if (-not $this.performanceMetrics.ResourceUsage.DiskUsageGB) { $this.performanceMetrics.ResourceUsage.DiskUsageGB = 0 }
    if (-not $this.performanceMetrics.ResourceUsage.MaxConcurrentOperations) { $this.performanceMetrics.ResourceUsage.MaxConcurrentOperations = 0 }
    if (-not $this.performanceMetrics.ResourceUsage.CurrentActiveOperations) { $this.performanceMetrics.ResourceUsage.CurrentActiveOperations = 0 }
    if ($operationData.Metrics.MemoryEndMB -gt $this.performanceMetrics.ResourceUsage.MemoryPeakMB) {
      $this.performanceMetrics.ResourceUsage.MemoryPeakMB = $operationData.Metrics.MemoryEndMB
    }

    # Update concurrency
    $this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations--

    # Check for performance alerts
    $this.CheckPerformanceAlerts($operationData)

    $this.logger.LogInfo("Completed operation telemetry: $operationName (Duration: $($duration.TotalSeconds)s, Success: $success)", "WorkflowOperationsService")
  }

  [void] LogOperationEvent([string]$operationId, [string]$eventType, [string]$message, [object]$context = [PSCustomObject]@{}) {
    <#
        .SYNOPSIS
            Logs an event during operation execution

        .PARAMETER operationId
            Operation tracking ID

        .PARAMETER eventType
            Type of event (Info, Warning, Error, etc.)

        .PARAMETER message
            Event message

        .PARAMETER context
            Additional context data
        #>

    if (-not $this.telemetryData.Operations.$operationId) {
      return
    }

    $eventData = [PSCustomObject]@{
      Timestamp = Get-Date
      EventType = $eventType
      Message   = $message
      Context   = $context
    }

    $this.telemetryData.Operations[$operationId].Events += $eventData

    # Log to standard logger as well
    switch ($eventType) {
      'Error' { $this.logger.LogError($message, "OperationTelemetry") }
      'Warning' { $this.logger.LogWarning($message, "OperationTelemetry") }
      default { $this.logger.LogInfo($message, "OperationTelemetry") }
    }
  }

  # ========================================
  # PERFORMANCE MONITORING
  # ========================================

  [void] CheckPerformanceAlerts([object]$operationData) {
    <#
        .SYNOPSIS
            Checks operation data against performance thresholds and generates alerts

        .PARAMETER operationData
            Operation telemetry data to check
        #>

    $alertConfig = $this.globalConfiguration.Monitoring.AlertThresholds
    $alerts = @()

    # Check duration threshold
    if ($operationData.Duration.TotalMinutes -gt $alertConfig.OperationDurationMinutes) {
      $alerts += @{
        Type      = 'LongRunningOperation'
        Severity  = 'Warning'
        Message   = "Operation '$($operationData.OperationName)' took $($operationData.Duration.TotalMinutes) minutes"
        Timestamp = Get-Date
      }
    }

    # Check memory usage
    if ($operationData.Metrics.MemoryEndMB -gt $alertConfig.MemoryUsageMB) {
      $alerts += @{
        Type      = 'HighMemoryUsage'
        Severity  = 'Warning'
        Message   = "Operation '$($operationData.OperationName)' used $($operationData.Metrics.MemoryEndMB)MB memory"
        Timestamp = Get-Date
      }
    }

    # Check error rate
    $operationName = $operationData.OperationName
    if ($this.performanceMetrics.SuccessRates.$operationName) {
      $successRate = $this.performanceMetrics.SuccessRates.$operationName
      $errorRate = 100 - $successRate
      if ($errorRate -gt $alertConfig.ErrorRatePercent) {
        $alerts += @{
          Type      = 'HighErrorRate'
          Severity  = 'Critical'
          Message   = "Operation '$operationName' has $errorRate% error rate"
          Timestamp = Get-Date
        }
      }
    }

    # Store alerts
    foreach ($alert in $alerts) {
      $alertId = [System.Guid]::NewGuid().ToString()
      $this.telemetryData.Alerts[$alertId] = $alert
      $this.logger.LogWarning("Performance Alert: $($alert.Message)", "PerformanceMonitoring")
    }
  }

  [object] GetPerformanceReport([string]$operationName = $null, [int]$lastHours = 24) {
    <#
        .SYNOPSIS
            Generates a performance report for operations

        .PARAMETER operationName
            Optional specific operation name to report on

        .PARAMETER lastHours
            Number of hours to include in the report

        .OUTPUTS
            Returns performance report
        #>

    $cutoffTime = (Get-Date).AddHours(-$lastHours)
    $report = [PSCustomObject]@{
      ReportPeriod    = "$lastHours hours"
      GeneratedAt     = Get-Date
      Summary         = [PSCustomObject]@{}
      DetailedMetrics = [PSCustomObject]@{}
      Alerts          = [PSCustomObject]@{}
      Recommendations = @()
    }

    # Filter operations by time
    $relevantOps = [PSCustomObject]@{}
    foreach ($opId in $this.telemetryData.Operations.Keys) {
      $opData = $this.telemetryData.Operations[$opId]
      if ($opData.StartTime -gt $cutoffTime) {
        if (-not $operationName -or $opData.OperationName -eq $operationName) {
          $relevantOps[$opId] = $opData
        }
      }
    }

    # Calculate summary metrics
    $totalOps = $relevantOps.Count
    $successfulOps = ($relevantOps.Values | Where-Object { $_.Success }).Count
    $failedOps = $totalOps - $successfulOps

    $report.Summary = @{
      TotalOperations        = $totalOps
      SuccessfulOperations   = $successfulOps
      FailedOperations       = $failedOps
      SuccessRate            = if ($totalOps -gt 0) { ($successfulOps / $totalOps) * 100 } else { 0 }
      AverageDurationMinutes = if ($totalOps -gt 0) {
        ($relevantOps.Values | ForEach-Object { $_.Duration.TotalMinutes } | Measure-Object -Average).Average
      }
      else { 0 }
    }

    # Detailed metrics by operation type
    $opTypes = $relevantOps.Values | Group-Object OperationName
    foreach ($opType in $opTypes) {
      $opName = $opType.Name
      $ops = $opType.Group

      $report.DetailedMetrics[$opName] = @{
        Count                  = $ops.Count
        SuccessCount           = ($ops | Where-Object { $_.Success }).Count
        FailureCount           = ($ops | Where-Object { -not $_.Success }).Count
        AverageDurationMinutes = ($ops | ForEach-Object { $_.Duration.TotalMinutes } | Measure-Object -Average).Average
        MaxDurationMinutes     = ($ops | ForEach-Object { $_.Duration.TotalMinutes } | Measure-Object -Maximum).Maximum
        AverageMemoryMB        = ($ops | ForEach-Object { $_.Metrics.MemoryEndMB } | Measure-Object -Average).Average
        MaxMemoryMB            = ($ops | ForEach-Object { $_.Metrics.MemoryEndMB } | Measure-Object -Maximum).Maximum
      }
    }

    # Recent alerts
    $recentAlerts = [PSCustomObject]@{}
    foreach ($alertId in $this.telemetryData.Alerts.Keys) {
      $alert = $this.telemetryData.Alerts[$alertId]
      if ($alert.Timestamp -gt $cutoffTime) {
        $recentAlerts[$alertId] = $alert
      }
    }
    $report.Alerts = $recentAlerts

    # Generate recommendations
    if ($report.Summary.SuccessRate -lt 95) {
      $report.Recommendations += "Success rate is below 95%. Consider investigating common failure patterns."
    }

    if ($report.Summary.AverageDurationMinutes -gt 30) {
      $report.Recommendations += "Average operation duration exceeds 30 minutes. Consider performance optimization."
    }

    if ($recentAlerts.Count -gt 5) {
      $report.Recommendations += "High number of alerts in the reporting period. Review operational procedures."
    }

    return $report
  }

  [void] ExportTelemetryData([string]$exportPath = $null) {
    <#
        .SYNOPSIS
            Exports telemetry data to files for analysis

        .PARAMETER exportPath
            Optional custom export path
        #>

    if (-not $exportPath) {
      $exportPath = $this.globalConfiguration.Monitoring.TelemetryExportPath
    }

    if (-not (Test-Path $exportPath)) {
      New-Item -Path $exportPath -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    # Export operations data
    $operationsFile = Join-Path $exportPath "operations_$timestamp.json"
    $this.telemetryData.Operations | ConvertTo-Json -Depth 10 -Compress | Out-File $operationsFile

    # Export performance metrics
    $metricsFile = Join-Path $exportPath "metrics_$timestamp.json"
    $this.performanceMetrics | ConvertTo-Json -Depth 10 -Compress | Out-File $metricsFile

    # Export alerts
    $alertsFile = Join-Path $exportPath "alerts_$timestamp.json"
    $this.telemetryData.Alerts | ConvertTo-Json -Depth 10 -Compress | Out-File $alertsFile

    $this.logger.LogInfo("Telemetry data exported to $exportPath", "WorkflowOperationsService")
  }

  # ========================================
  # OPERATIONAL EXCELLENCE UTILITIES
  # ========================================

  [bool] ValidateOperationalReadiness([string]$operationName, [object]$parameters = [PSCustomObject]@{}) {
    <#
        .SYNOPSIS
            Validates that the system is ready for an operation

        .PARAMETER operationName
            Name of the operation to validate

        .PARAMETER parameters
            Operation parameters for validation

        .OUTPUTS
            Returns true if system is ready for the operation
        #>

    try {
      # Check resource availability
      $memoryMB = [System.GC]::GetTotalMemory($false) / 1MB
      $maxMemory = $this.globalConfiguration.Performance.MemoryThresholdMB

      if ($memoryMB -gt $maxMemory) {
        $this.logger.LogWarning("Memory usage ($memoryMB MB) exceeds threshold ($maxMemory MB)", "WorkflowOperationsService")
        return $false
      }

      # Check concurrent operation limits
      $currentOps = $this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations
      $maxOps = $this.globalConfiguration.Performance.MaxConcurrentOperations

      if ($currentOps -ge $maxOps) {
        $this.logger.LogWarning("Maximum concurrent operations ($maxOps) reached", "WorkflowOperationsService")
        return $false
      }

      # Check error rate thresholds
      if ($this.performanceMetrics.SuccessRates.$operationName) {
        $successRate = $this.performanceMetrics.SuccessRates[$operationName]
        if ($successRate -lt 80) {
          $this.logger.LogWarning("Operation '$operationName' has low success rate: $successRate%", "WorkflowOperationsService")
          return $false
        }
      }

      # Validate required parameters
      if ($this.operationalPolicies.QualityAssurance.RequirePreExecutionValidation) {
        if (-not $this.ValidateOperationParameters($operationName, $parameters)) {
          return $false
        }
      }

      return $true
    }
    catch {
      $this.logger.LogError("Operational readiness validation failed: $($_.Exception.Message)", "WorkflowOperationsService")
      return $false
    }
  }

  [bool] ValidateOperationParameters([string]$operationName, [object]$parameters) {
    <#
        .SYNOPSIS
            Validates operation parameters against operational policies

        .PARAMETER operationName
            Name of the operation

        .PARAMETER parameters
            Parameters to validate

        .OUTPUTS
            Returns true if parameters are valid
        #>

    # Basic parameter validation
    if ($parameters.NSXManager -and [string]::IsNullOrEmpty($parameters.NSXManager)) {
      $this.logger.LogError("NSXManager parameter is required but not provided", "WorkflowOperationsService")
      return $false
    }

    # Validate timeout parameters
    if ($parameters.Timeout) {
      $timeout = $parameters['Timeout']
      $maxTimeout = $this.globalConfiguration.Performance.OperationTimeoutMinutes
      if ($timeout -gt $maxTimeout) {
        $this.logger.LogError("Timeout ($timeout min) exceeds maximum allowed ($maxTimeout min)", "WorkflowOperationsService")
        return $false
      }
    }

    return $true
  }

  [void] CleanupResources([int]$retentionDays = 7) {
    <#
        .SYNOPSIS
            Performs cleanup of old data and temporary resources

        .PARAMETER retentionDays
            Number of days to retain data
        #>

    $cutoffDate = (Get-Date).AddDays(-$retentionDays)
    $cleanupCount = 0

    # Clean up old operation data
    $operationsToRemove = @()
    foreach ($opId in $this.telemetryData.Operations.Keys) {
      $opData = $this.telemetryData.Operations[$opId]
      if ($opData.StartTime -lt $cutoffDate) {
        $operationsToRemove += $opId
      }
    }

    foreach ($opId in $operationsToRemove) {
      $this.telemetryData.Operations.Remove($opId)
      $cleanupCount++
    }

    # Clean up old alerts
    $alertsToRemove = @()
    foreach ($alertId in $this.telemetryData.Alerts.Keys) {
      $alert = $this.telemetryData.Alerts[$alertId]
      if ($alert.Timestamp -lt $cutoffDate) {
        $alertsToRemove += $alertId
      }
    }

    foreach ($alertId in $alertsToRemove) {
      $this.telemetryData.Alerts.Remove($alertId)
      $cleanupCount++
    }

    # Force garbage collection
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    $this.logger.LogInfo("Cleanup completed: $cleanupCount items removed", "WorkflowOperationsService")
  }

  [object] GetSystemHealthStatus() {
    <#
        .SYNOPSIS
            Returns current system health status

        .OUTPUTS
            Returns health status report
        #>

    $healthStatus = [PSCustomObject]@{
      Timestamp       = Get-Date
      OverallHealth   = 'Healthy'
      ResourceUsage   = @{
        MemoryMB           = [System.GC]::GetTotalMemory($false) / 1MB
        ActiveOperations   = if ($this.performanceMetrics.ConcurrencyMetrics -and $this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations) { $this.performanceMetrics.ConcurrencyMetrics.CurrentActiveOperations } else { 0 }
        ProcessUptimeHours = try { ((Get-Date) - ([System.Diagnostics.Process]::GetCurrentProcess()).StartTime).TotalHours } catch { 0 }
      }
      ServiceStatus   = @{
        WorkflowOperationsService = 'Running'
        TelemetryCollection       = if ($this.globalConfiguration.Monitoring.EnableTelemetry) { 'Enabled' } else { 'Disabled' }
        PerformanceMonitoring     = if ($this.globalConfiguration.Performance.EnablePerformanceMetrics) { 'Enabled' } else { 'Disabled' }
      }
      RecentMetrics   = @{
        TotalOperationsLast24h    = ($this.telemetryData.Operations.Values | Where-Object { $_.StartTime -gt (Get-Date).AddHours(-24) }).Count
        AverageSuccessRateLast24h = if ($this.performanceMetrics.SuccessRates -and $this.performanceMetrics.SuccessRates.Count -gt 0) {
          ($this.performanceMetrics.SuccessRates.Values | Measure-Object -Average).Average
        }
        else { 100 }
        ActiveAlertsCount         = ($this.telemetryData.Alerts.Values | Where-Object { $_.Timestamp -gt (Get-Date).AddHours(-24) }).Count
      }
      Recommendations = @()
    }

    # Assess overall health
    $issues = @()

    if ($healthStatus.ResourceUsage.MemoryMB -gt $this.globalConfiguration.Performance.MemoryThresholdMB) {
      $issues += "High memory usage"
      $healthStatus.OverallHealth = 'Warning'
    }

    if ($healthStatus.RecentMetrics.AverageSuccessRateLast24h -lt 95) {
      $issues += "Low success rate"
      $healthStatus.OverallHealth = 'Warning'
    }

    if ($healthStatus.RecentMetrics.ActiveAlertsCount -gt 10) {
      $issues += "High alert count"
      $healthStatus.OverallHealth = 'Critical'
    }

    if ($issues.Count -gt 0) {
      $healthStatus.Issues = $issues
      if ($healthStatus.OverallHealth -eq 'Healthy') {
        $healthStatus.OverallHealth = 'Warning'
      }
    }

    return $healthStatus
  }

  # ========================================
  # TOOLKIT PATHS CONFIGURATION MANAGEMENT
  # ========================================

  # Load toolkit paths configuration from JSON file
  hidden [void] LoadToolkitPathsConfiguration() {
    try {
      if (Test-Path $this.pathsConfigFilePath) {
        $jsonContent = Get-Content -Path $this.pathsConfigFilePath -Raw | ConvertFrom-Json
        $this.toolkitPathsConfig = $this.ConvertPSObjectToHashtable($jsonContent)

        if ($this.logger) {
          $pathCount = $this.toolkitPathsConfig.toolkit_paths.Count
          $this.logger.LogInfo("Loaded toolkit paths configuration with $pathCount paths", "WorkflowOperationsService")
        }

        # Auto-create directories if enabled
        if ($this.toolkitPathsConfig.configuration.auto_create_directories) {
          $this.AutoCreateDirectories()
        }
      }
      else {
        if ($this.logger) {
          $this.logger.LogWarning("Toolkit paths configuration file not found: $($this.pathsConfigFilePath)", "WorkflowOperationsService")
        }
        $this.SetDefaultToolkitPathsConfiguration()
      }
    }
    catch {
      if ($this.logger) {
        $this.logger.LogError("Failed to load toolkit paths configuration: $($_.Exception.Message)", "WorkflowOperationsService")
      }
      $this.SetDefaultToolkitPathsConfiguration()
    }
  }

  # Set default toolkit paths configuration
  hidden [void] SetDefaultToolkitPathsConfiguration() {
    $this.toolkitPathsConfig = @{
      toolkit_paths   = @{
        DataRoot = "./data"
        Exports  = "./data/exports"
        Syncs    = "./data/syncs"
        Tests    = "./data/tests"
        Reports  = "./data/reports"
        APIData  = "./data/api"
        Logs     = "./logs"
        Backups  = "./backups"
      }
      configuration   = @{
        version                 = "1.0"
        enable_logging          = $true
        auto_create_directories = $true
        path_validation         = $true
        case_sensitive_keys     = $false
      }
      metadata        = @{
        created_by = "WorkflowOperationsService"
        created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
      }
      directory_rules = @{
        auto_create = @("DataRoot", "Exports", "Syncs", "Tests", "Reports", "APIData", "Logs", "Backups")
      }
    }
  }

  # Validate toolkit paths configuration structure
  hidden [void] ValidateToolkitPathsConfiguration() {
    if (-not $this.toolkitPathsConfig) {
      throw "Toolkit paths configuration is null"
    }

    # Ensure required structure exists
    if (-not $this.toolkitPathsConfig.toolkit_paths) {
      $this.toolkitPathsConfig.toolkit_paths = [PSCustomObject]@{}
    }

    if (-not $this.toolkitPathsConfig.configuration) {
      $this.toolkitPathsConfig.configuration = @{
        version                 = "1.0"
        enable_logging          = $true
        auto_create_directories = $true
        path_validation         = $true
        case_sensitive_keys     = $false
      }
    }

    if (-not $this.toolkitPathsConfig.metadata) {
      $this.toolkitPathsConfig.metadata = @{
        created_by = "WorkflowOperationsService"
        created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
      }
    }

    if ($this.logger) {
      $this.logger.LogDebug("Toolkit paths configuration validated successfully", "WorkflowOperationsService")
    }
  }

  # Use shared utility for PSObject to hashtable conversion with lazy loading
  hidden [object] ConvertPSObjectToHashtable([object] $obj) {
    # ARCHITECTURAL IMPROVEMENT: Implement lazy loading for SharedToolUtilityService
    if (-not $this.sharedUtility) {
      try {
        $this.sharedUtility = [CoreServiceFactory]::GetSharedToolUtilityService()
        if ($this.logger) {
          $this.logger.LogDebug("Lazy-loaded SharedToolUtilityService successfully", "WorkflowOperationsService")
        }
      }
      catch {
        if ($this.logger) {
          $this.logger.LogError("Failed to lazy-load SharedToolUtilityService: $($_.Exception.Message)", "WorkflowOperationsService")
        }
        throw "SharedToolUtilityService could not be loaded for PSObject conversion: $($_.Exception.Message)"
      }
    }

    return $this.sharedUtility.ConvertPSObjectToHashtable($obj)
  }

  # Auto-create directories based on configuration
  hidden [void] AutoCreateDirectories() {
    if (-not $this.toolkitPathsConfig.directory_rules -or -not $this.toolkitPathsConfig.directory_rules.auto_create) {
      return
    }

    foreach ($pathKey in $this.toolkitPathsConfig.directory_rules.auto_create) {
      if ($this.toolkitPathsConfig.toolkit_paths.$pathKey) {
        $pathValue = $this.toolkitPathsConfig.toolkit_paths.$pathKey

        if (-not (Test-Path $pathValue)) {
          try {
            New-Item -Path $pathValue -ItemType Directory -Force | Out-Null
            if ($this.logger) {
              $this.logger.LogDebug("Auto-created directory: $pathValue", "WorkflowOperationsService")
            }
          }
          catch {
            if ($this.logger) {
              $this.logger.LogWarning("Failed to auto-create directory $pathValue`: $($_.Exception.Message)", "WorkflowOperationsService")
            }
          }
        }
      }
    }
  }

  # Get toolkit path by key (instance method)
  [string] GetToolkitPath([string] $key) {
    if ($null -eq $key) { return $null }

    $keyToUse = $key
    if (-not $this.toolkitPathsConfig.configuration.case_sensitive_keys) {
      # Find case-insensitive match
      foreach ($configKey in $this.toolkitPathsConfig.toolkit_paths.Keys) {
        if ($configKey -eq $key) {
          $keyToUse = $configKey
          break
        }
      }
    }

    if ($this.toolkitPathsConfig.toolkit_paths.$keyToUse) {
      return $this.toolkitPathsConfig.toolkit_paths.$keyToUse
    }

    if ($this.logger) {
      $this.logger.LogWarning("Toolkit path key '$key' not found", "WorkflowOperationsService")
    }
    return $null
  }

  # Set toolkit path (runtime configuration)
  [void] SetToolkitPath([string] $key, [string] $path) {
    if (-not $key -or -not $path) {
      if ($this.logger) {
        $this.logger.LogWarning("Key and path are required for SetToolkitPath", "WorkflowOperationsService")
      }
      return
    }

    $this.toolkitPathsConfig.toolkit_paths[$key] = $path

    # Auto-create directory if enabled and if it's in the auto-create list
    if ($this.toolkitPathsConfig.configuration.auto_create_directories) {
      if ($this.toolkitPathsConfig.directory_rules -and
        $this.toolkitPathsConfig.directory_rules.auto_create -and
        $this.toolkitPathsConfig.directory_rules.auto_create -contains $key) {

        if (-not (Test-Path $path)) {
          try {
            New-Item -Path $path -ItemType Directory -Force | Out-Null
            if ($this.logger) {
              $this.logger.LogInfo("Auto-created directory for new path '$key': $path", "WorkflowOperationsService")
            }
          }
          catch {
            if ($this.logger) {
              $this.logger.LogWarning("Failed to auto-create directory for '$key' at $path`: $($_.Exception.Message)", "WorkflowOperationsService")
            }
          }
        }
      }
    }

    if ($this.logger) {
      $this.logger.LogInfo("Updated toolkit path '$key' to: $path", "WorkflowOperationsService")
    }
  }

  # Update multiple toolkit paths
  [void] UpdateToolkitPaths([object] $pathUpdates) {
    if (-not $pathUpdates) {
      if ($this.logger) {
        $this.logger.LogWarning("No path updates provided", "WorkflowOperationsService")
      }
      return
    }

    foreach ($key in $pathUpdates.Keys) {
      $this.SetToolkitPath($key, $pathUpdates[$key])
    }
  }

  # Merge toolkit paths configuration
  [void] MergeToolkitPathsConfiguration([object] $additionalConfig) {
    if (-not $additionalConfig) {
      return
    }

    # Merge toolkit paths
    if ($additionalConfig.toolkit_paths) {
      foreach ($pathKey in $additionalConfig.toolkit_paths.Keys) {
        $this.toolkitPathsConfig.toolkit_paths[$pathKey] = $additionalConfig.toolkit_paths[$pathKey]
      }
    }

    # Merge configuration settings
    if ($additionalConfig.configuration) {
      if (-not $this.toolkitPathsConfig.configuration) {
        $this.toolkitPathsConfig.configuration = [PSCustomObject]@{}
      }
      foreach ($configKey in $additionalConfig.configuration.Keys) {
        $this.toolkitPathsConfig.configuration[$configKey] = $additionalConfig.configuration[$configKey]
      }
    }

    # Merge metadata
    if ($additionalConfig.metadata) {
      if (-not $this.toolkitPathsConfig.metadata) {
        $this.toolkitPathsConfig.metadata = [PSCustomObject]@{}
      }
      foreach ($metaKey in $additionalConfig.metadata.Keys) {
        $this.toolkitPathsConfig.metadata[$metaKey] = $additionalConfig.metadata[$metaKey]
      }
    }

    if ($this.logger) {
      $this.logger.LogDebug("Toolkit paths configuration merged successfully", "WorkflowOperationsService")
    }
  }

  # Get current toolkit paths configuration (for inspection)
  [object] GetToolkitPathsConfiguration() {
    return $this.toolkitPathsConfig
  }

  # Reload configuration from JSON file (for runtime updates)
  [void] ReloadToolkitPathsConfiguration() {
    if ($this.logger) {
      $this.logger.LogInfo("Reloading toolkit paths configuration from JSON file", "WorkflowOperationsService")
    }
    $this.LoadToolkitPathsConfiguration()
  }

  # Get all available toolkit path keys
  [array] GetAvailablePathKeys() {
    if ($this.toolkitPathsConfig.toolkit_paths) {
      return @($this.toolkitPathsConfig.toolkit_paths.Keys)
    }
    return @()
  }

  # Validate path exists and create if needed
  [bool] ValidateAndCreatePath([string] $key) {
    $path = $this.GetToolkitPath($key)
    if (-not $path) {
      return $false
    }

    if (-not (Test-Path $path)) {
      try {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        if ($this.logger) {
          $this.logger.LogInfo("Created missing directory for '$key': $path", "WorkflowOperationsService")
        }
        return $true
      }
      catch {
        if ($this.logger) {
          $this.logger.LogError("Failed to create directory for '$key' at $path`: $($_.Exception.Message)", "WorkflowOperationsService")
        }
        return $false
      }
    }
    return $true
  }

  # ========================================
  # CANONICAL TOOLKIT DIRECTORY PATHS (STATIC - BACKWARD COMPATIBILITY)
  # ========================================
  # This section provides backward compatibility for existing code
  # New code should use instance methods for dynamic configuration support

  static [object] $ToolkitPaths = [PSCustomObject]@{
    DataRoot = "./data"
    Exports  = "./data/exports"
    Syncs    = "./data/syncs"
    Tests    = "./data/tests"
    Reports  = "./data/reports"
    APIData  = "./data/api"
    Logs     = "./logs"
    Backups  = "./backups"
  }

  <#
    .SYNOPSIS
      Returns the canonical toolkit directory path for a given key (STATIC - for backward compatibility).
    .PARAMETER key
      The directory key (e.g., 'Exports', 'Logs', 'Syncs', 'Backups', 'Tests', 'DataRoot')
    .OUTPUTS
      Returns the canonical path as a string, or $null if not found.
    .EXAMPLE
      [WorkflowOperationsService]::GetDataPath('Exports')
    .NOTES
      This static method is provided for backward compatibility.
      For new code, use instance method GetToolkitPath() for dynamic configuration support.
  #>
  static [string] GetDataPath([string] $key) {
    if ($null -eq $key) { return $null }
    if ([WorkflowOperationsService]::ToolkitPaths.$key) {
      return [WorkflowOperationsService]::ToolkitPaths.$key
    }
    return $null
  }
}
