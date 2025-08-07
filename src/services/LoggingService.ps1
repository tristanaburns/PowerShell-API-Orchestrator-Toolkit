# LoggingService.ps1
# Consolidated logging service implementing Single Responsibility Principle
# Combines functionality from multiple logging services into one cohesive implementation

# ========================================
# CANONICAL LOG DIRECTORY PATTERN (MANDATORY)
# ========================================
# All logs must go under script-relative 'logs' directories
# Examples:
#   - tools/NSXConfigSync.ps1 -> tools/logs/NSXConfigSync.log
#   - src/utilities/script.ps1 -> src/utilities/logs/script.log
# The LoggingService always ensures the log directory exists before writing any files.
# This is a non-negotiable standard for all NSX Toolkit services and scripts.
class LoggingService {
    hidden [string] $logDirectory
    hidden [bool] $consoleOutput
    hidden [bool] $fileOutput
    hidden [string] $logLevel
    hidden [object] $logLevels

    # Constructor with dependency injection
    LoggingService([string] $logDir = $null, [bool] $console = $true, [bool] $file = $true) {
        # CANONICAL PATTERN: Always ensure log directory exists before writing
        # This logic is mandatory and must not be removed or bypassed.
        $this.logLevels = @{
            'DEBUG'    = 0
            'INFO'     = 1
            'WARNING'  = 2
            'ERROR'    = 3
            'CRITICAL' = 4
        }

        # Load log level from configuration file
        $this.logLevel = $this.LoadLogLevelFromConfig()
        $this.consoleOutput = $console
        $this.fileOutput = $file

        if ($logDir) {
            $this.logDirectory = $logDir
        }
        else {
            # Detect calling script's directory and create logs subdirectory
            $this.logDirectory = $this.GetCallingScriptLogDirectory()
        }

        # Ensure log directory exists
        if ($this.fileOutput -and -not (Test-Path $this.logDirectory)) {
            New-Item -Path $this.logDirectory -ItemType Directory -Force | Out-Null
        }
    }

    # Core logging method following Open/Closed Principle
    hidden [void] WriteLog([string] $level, [string] $message, [string] $category = "General") {
        if ($this.logLevels[$level] -lt $this.logLevels[$this.logLevel]) {
            return
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $formattedMessage = "[$timestamp] [$level] [$category] $message"

        # Console output
        if ($this.consoleOutput) {
            Write-Host $formattedMessage
        }

        # File output
        if ($this.fileOutput) {
            $logFile = Join-Path $this.logDirectory $this.GetLogFileName()
            $formattedMessage | Out-File -FilePath $logFile -Append -Encoding UTF8
        }
    }

    # ILoggingService interface implementation
    [void] LogInfo([string] $message, [string] $category = "General") {
        $this.WriteLog('INFO', $message, $category)
    }

    [void] LogWarning([string] $message, [string] $category = "General") {
        $this.WriteLog('WARNING', $message, $category)
    }

    [void] LogError([string] $message, [string] $category = "General") {
        $this.WriteLog('ERROR', $message, $category)
    }

    [void] LogDebug([string] $message, [string] $category = "General") {
        $this.WriteLog('DEBUG', $message, $category)
    }

    # Specialised methods for specific use cases
    [void] LogStep([string] $message) {
        $this.WriteLog('INFO', "STEP: $message", "Workflow")
    }

    [void] LogException([System.Exception] $exception, [string] $context = "") {
        $errorMessage = if ($context) {
            "$context - Exception: $($exception.Message)"
        }
        else {
            "Exception: $($exception.Message)"
        }
        $this.WriteLog('ERROR', $errorMessage, "Exception")

        if ($exception.InnerException) {
            $this.WriteLog('ERROR', "Inner Exception: $($exception.InnerException.Message)", "Exception")
        }
    }

    # Authentication-specific logging methods
    [void] LogCurrentUserAuthAttempt([string] $manager, [string] $username) {
        $this.WriteLog('INFO', "Current user authentication attempt for '$manager' with user '$username'", "Authentication")
    }

    [void] LogCurrentUserAuthSuccess([string] $manager, [string] $message) {
        $this.WriteLog('INFO', "Current user authentication SUCCESS for '$manager': $message", "Authentication")
    }

    [void] LogCurrentUserAuthFailure([string] $manager, [string] $errorMessage) {
        $this.WriteLog('ERROR', "Current user authentication FAILED for '$manager': $errorMessage", "Authentication")
    }

    [void] LogNonInteractiveMode([string] $message) {
        $this.WriteLog('INFO', "NON-INTERACTIVE: $message", "Automation")
    }

    [void] LogScheduledTaskContext([string] $message) {
        $this.WriteLog('INFO', "SCHEDULED TASK: $message", "Automation")
    }

    # API-specific logging methods for debugging
    [void] LogAPIRequest([string] $method, [string] $uri, [object] $headers = $null, [object] $body = $null) {
        $this.WriteLog('DEBUG', "API REQUEST: $method $uri", "API")

        if ($headers) {
            $headersJson = $headers | ConvertTo-Json -Depth 5 -Compress
            $this.WriteLog('DEBUG', "API REQUEST HEADERS: $headersJson", "API")
        }

        if ($body) {
            $bodyContent = if ($body -is [string]) { $body } else { $body | ConvertTo-Json -Depth 10 }
            $this.WriteLog('DEBUG', "API REQUEST BODY: $bodyContent", "API")
        }
    }

    [void] LogAPIResponse([string] $method, [string] $uri, [int] $statusCode, [object] $response = $null, [long] $durationMs = 0) {
        $this.WriteLog('DEBUG', "API RESPONSE: $method $uri - Status: $statusCode - Duration: ${durationMs}ms", "API")

        if ($response) {
            $responseContent = if ($response -is [string]) { $response } else { $response | ConvertTo-Json -Depth 10 -Compress }
            # Truncate very large responses for readability
            if ($responseContent.Length -gt 5000) {
                $length = $responseContent.Length
                $truncated = $responseContent.Substring(0, 5000) + "... [TRUNCATED - Full response $length characters]"
                $this.WriteLog('DEBUG', "API RESPONSE BODY: $truncated", "API")
            }
            else {
                $this.WriteLog('DEBUG', "API RESPONSE BODY: $responseContent", "API")
            }
        }
    }

    [void] LogAPIError([string] $method, [string] $uri, [System.Exception] $exception, [long] $durationMs = 0) {
        $this.WriteLog('ERROR', "API ERROR: $method $uri - Duration: ${durationMs}ms - Error: $($exception.Message)", "API")

        if ($exception.InnerException) {
            $this.WriteLog('ERROR', "API ERROR INNER: $($exception.InnerException.Message)", "API")
        }

        # Log the full exception stack trace for debugging
        $this.WriteLog('DEBUG', "API ERROR STACK TRACE: $($exception.StackTrace)", "API")
    }

    [void] LogPayloadSummary([string] $operation, [object] $payload, [string] $payloadType = "Configuration") {
        if ($payload) {
            $summary = "PAYLOAD SUMMARY - $operation ($payloadType)"

            if ($payload -is [PSCustomObject] -or $payload -is [object]) {
                $summary += " - Properties: $(@($payload.PSObject.Properties).Count)"

                # Log key properties if available
                if ($payload.resource_type) { $summary += " - Type: $($payload.resource_type)" }
                if ($payload.id) { $summary += " - ID: $($payload.id)" }
                if ($payload.display_name) { $summary += " - Name: $($payload.display_name)" }
                if ($payload.results -and $payload.results.Count) { $summary += " - Results Count: $($payload.results.Count)" }
            }
            elseif ($payload -is [array]) {
                $summary += " - Array Length: $($payload.Count)"
            }
            else {
                $summary += " - Type: $($payload.GetType().Name)"
            }

            $this.WriteLog('INFO', $summary, "API")
        }
    }

    # Get calling script's log directory
    hidden [string] GetCallingScriptLogDirectory() {
        try {
            # Get the calling script's path by examining the call stack
            $callingScript = $null
            $callStack = Get-PSCallStack

            # Find the first external script (not this service)
            foreach ($frame in $callStack) {
                if ($frame.ScriptName -and $frame.ScriptName -ne $PSCommandPath) {
                    $callingScript = $frame.ScriptName
                    break
                }
            }

            if ($callingScript) {
                # Get the directory of the calling script
                $scriptDirectory = Split-Path $callingScript -Parent
                return Join-Path $scriptDirectory "logs"
            }
            else {
                # Fallback to root logs directory if no calling script detected
                $rootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
                return Join-Path $rootPath "logs"
            }
        }
        catch {
            # Fallback to root logs directory on error
            $rootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
            return Join-Path $rootPath "logs"
        }
    }

    # Get log file name based on calling script
    hidden [string] GetLogFileName() {
        try {
            # Get the calling script's name
            $callingScript = $null
            $callStack = Get-PSCallStack

            # Find the first external script (not this service)
            foreach ($frame in $callStack) {
                if ($frame.ScriptName -and $frame.ScriptName -ne $PSCommandPath) {
                    $callingScript = $frame.ScriptName
                    break
                }
            }

            if ($callingScript) {
                # Get script name without extension
                $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($callingScript)
                return "$scriptName.log"
            }
            else {
                # Fallback to generic name
                return "nsx-toolkit-$(Get-Date -Format 'yyyy-MM-dd').log"
            }
        }
        catch {
            # Fallback to generic name on error
            return "nsx-toolkit-$(Get-Date -Format 'yyyy-MM-dd').log"
        }
    }

    # Load log level from nsx-config.json
    hidden [string] LoadLogLevelFromConfig() {
        try {
            # Get root path - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
            $configPath = Join-Path $rootPath "config\nsx-config.json"

            if (Test-Path $configPath) {
                $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
                # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
                if ($config.logLevel -and ((Get-Member -InputObject $this.logLevels -Name $config.logLevel.ToUpper() -MemberType NoteProperty -ErrorAction SilentlyContinue))) {
                    Write-Host "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] [INFO] [LoggingService] Log level set to: $($config.logLevel.ToUpper()) from nsx-config.json" -ForegroundColor Green
                    return $config.logLevel.ToUpper()
                }
            }
        }
        catch {
            # If config loading fails, fall back to default
            Write-Host "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] [WARNING] [LoggingService] Failed to load log level from config, using default: INFO" -ForegroundColor Yellow
        }

        return 'INFO'
    }

    # Configuration methods
    [void] SetLogLevel([string] $level) {
        # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
        if ((Get-Member -InputObject $this.logLevels -Name $level.ToUpper() -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
            $this.logLevel = $level.ToUpper()
        }
    }

    [void] SetConsoleOutput([bool] $enabled) {
        $this.consoleOutput = $enabled
    }

    [void] SetFileOutput([bool] $enabled) {
        $this.fileOutput = $enabled
    }

    # Update log level from configuration service (for dynamic updates)
    [void] UpdateLogLevelFromConfig([object] $configurationService) {
        if ($configurationService) {
            try {
                $configLogLevel = $configurationService.GetConfigValue('nsx-config', 'logLevel', 'INFO')
                # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
                if ((Get-Member -InputObject $this.logLevels -Name $configLogLevel.ToUpper() -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
                    $this.logLevel = $configLogLevel.ToUpper()
                    $this.WriteLog('INFO', "Log level updated to: $($this.logLevel) from ConfigurationService", "LoggingService")
                }
            }
            catch {
                $this.WriteLog('WARNING', "Failed to update log level from ConfigurationService: $($_.Exception.Message)", "LoggingService")
            }
        }
    }
}
