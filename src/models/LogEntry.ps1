# LogEntry.ps1
# Domain model for log entries

<#
.SYNOPSIS
    Domain model representing a log entry.

.DESCRIPTION
    Represents a structured log entry with all necessary properties for logging operations.

    SOLID Principles Applied:
    - Single Responsibility: Only represents log entry data
    - Open/Closed: Extensible through inheritance
#>

# Log Level enumeration (must be defined before use in class)
enum LogLevel {
    Trace = 0
    Debug = 1
    Information = 2
    Warning = 3
    Error = 4
    Critical = 5
}

class LogEntry {
    [DateTime]$Timestamp
    [LogLevel]$Level
    [string]$Message
    [string]$Source
    [string]$SessionId
    [ConsoleColor]$Color
    [object]$Properties

    # Default constructor
    LogEntry() {
        $this.Timestamp = Get-Date
        $this.Properties = [PSCustomObject]@{}
        $this.Color = [ConsoleColor]::White
    }

    # Constructor with message and level
    LogEntry([string]$message, [LogLevel]$level) {
        $this.Timestamp = Get-Date
        $this.Message = $message
        $this.Level = $level
        $this.Properties = [PSCustomObject]@{}
        $this.Color = $this.GetDefaultColor($level)
    }

    # Constructor with all properties
    LogEntry([string]$message, [LogLevel]$level, [string]$source, [string]$sessionId) {
        $this.Timestamp = Get-Date
        $this.Message = $message
        $this.Level = $level
        $this.Source = $source
        $this.SessionId = $sessionId
        $this.Properties = [PSCustomObject]@{}
        $this.Color = $this.GetDefaultColor($level)
    }

    # Method to add custom property
    [void] AddProperty([string]$key, [object]$value) {
        $this.Properties[$key] = $value
    }

    # Method to get formatted timestamp
    [string] GetFormattedTimestamp([string]$format) {
        if ([string]::IsNullOrEmpty($format)) {
            $format = "dd-MM-yyyy_HH:mm:ss.fff"
        }
        return $this.Timestamp.ToString($format)
    }

    # Method to get default color based on log level
    [ConsoleColor] GetDefaultColor([LogLevel]$level) {
        switch ($level) {
            ([LogLevel]::Trace) { return [ConsoleColor]::Gray }
            ([LogLevel]::Debug) { return [ConsoleColor]::Cyan }
            ([LogLevel]::Information) { return [ConsoleColor]::White }
            ([LogLevel]::Warning) { return [ConsoleColor]::Yellow }
            ([LogLevel]::Error) { return [ConsoleColor]::Red }
            ([LogLevel]::Critical) { return [ConsoleColor]::Magenta }
            default { return [ConsoleColor]::White }
        }
        # Explicit return to ensure all code paths return a value
        return [ConsoleColor]::White
    }

    # Method to convert to hashtable for serialization
    [object] ToHashTable() {
        return @{
            Timestamp  = $this.Timestamp
            Level      = $this.Level.ToString()
            Message    = $this.Message
            Source     = $this.Source
            SessionId  = $this.SessionId
            Color      = $this.Color.ToString()
            Properties = $this.Properties
        }
    }

    # Static method to create from hashtable
    static [LogEntry] FromHashTable([object]$data) {
        $entry = [LogEntry]::new()
        $entry.Timestamp = $data.Timestamp
        $entry.Level = [LogLevel]$data.Level
        $entry.Message = $data.Message
        $entry.Source = $data.Source
        $entry.SessionId = $data.SessionId
        $entry.Color = [ConsoleColor]$data.Color
        $entry.Properties = $data.Properties
        return $entry
    }
}
