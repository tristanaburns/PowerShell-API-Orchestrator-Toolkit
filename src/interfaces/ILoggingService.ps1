# ILoggingService.ps1
# Interface for logging services following Single Responsibility Principle

<#
.SYNOPSIS
    Interface for logging services.

.DESCRIPTION
    Defines the contract for logging operations, extracting from the original
    monolithic Log_Output function that mixed formatting, console output, and file I/O.

    SOLID Principles Applied:
    - Single Responsibility: Only defines logging contract
    - Interface Segregation: Separate concerns for different logging aspects
    - Open/Closed: Extensible for new log destinations
#>

# Core Logging Interface Contract
<#
    Logging Service Implementation Contract:

    [void] WriteLog([string]$message, [LogLevel]$level)
        - Writes a log message with specified level

    [void] WriteLog([string]$message, [LogLevel]$level, [ConsoleColor]$color)
        - Writes a log message with color for console output

    [void] ConfigureOutput([ILogWriter[]]$writers)
        - Configures log output destinations

    [void] SetLogLevel([LogLevel]$level)
        - Sets minimum log level for filtering

    [string] StartLogSession([string]$sessionName)
        - Creates a new log session with context

    [void] EndLogSession([string]$sessionId)
        - Ends a log session and finalizes output
#>

# Log Writer Interface Contract for different output destinations
<#
    Log Writer Implementation Contract:

    [void] Write([LogEntry]$entry)
        - Writes formatted log entry to destination

    [void] Initialize()
        - Initializes the log writer

    [void] Close()
        - Closes and cleans up the log writer

    [string] GetWriterType()
        - Gets the writer type identifier
#>

# Log Formatter Interface Contract
<#
    Log Formatter Implementation Contract:

    [string] Format([LogEntry]$entry)
        - Formats a log entry for output

    [void] SetTemplate([string]$template)
        - Sets format template for log entries
#>

# Log Configuration Interface Contract
<#
    Log Configuration Implementation Contract:

    [LogLevel] GetLogLevel()
        - Gets the current log level

    [string] GetLogFilePath()
        - Gets the log file path

    [string] GetMasterLogPath()
        - Gets the master log file path

    [object] GetRotationSettings()
        - Gets log file rotation settings

    [string] GetTimestampFormat()
        - Gets timestamp format string for log entries
#>

# Log Level Enumeration
enum LogLevel {
    Trace = 0
    Debug = 1
    Information = 2
    Warning = 3
    Error = 4
    Critical = 5
}
