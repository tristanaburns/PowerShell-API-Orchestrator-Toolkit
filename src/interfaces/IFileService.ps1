# IFileService.ps1
# Interface for file operations following Single Responsibility Principle

<#
.SYNOPSIS
    Interface for file operations services.

.DESCRIPTION
    Defines the contract for file operations, separating from UI concerns and
    providing abstraction for file handling operations.

    SOLID Principles Applied:
    - Single Responsibility: Only handles file operations
    - Interface Segregation: Separate interfaces for different file concerns
    - Dependency Inversion: Abstract file operations from concrete implementations
#>

# Core File Service Interface Contract
<#
    File Service Implementation Contract:

    [string] GetWorkingDirectory()
        - Gets the current working directory

    [void] SetWorkingDirectory([string]$path)
        - Sets the working directory

    [bool] FileExists([string]$filePath)
        - Checks if file exists at specified path

    [bool] DirectoryExists([string]$directoryPath)
        - Checks if directory exists at specified path

    [void] EnsureDirectory([string]$directoryPath)
        - Creates directory if it doesn't exist
#>

# File Selection Interface Contract (separated from file operations)
<#
    File Selector Implementation Contract:

    [string] SelectExcelFile([string]$initialDirectory)
        - Prompts user to select an Excel file

    [string] SelectCSVFile([string]$initialDirectory)
        - Prompts user to select a CSV file

    [string] SelectJSONFile([string]$initialDirectory)
        - Prompts user to select a JSON file

    [string] SelectFile([string]$filter, [string]$initialDirectory)
        - Prompts user to select any file with custom filter
#>

# File Converter Interface Contract
<#
    File Converter Implementation Contract:

    [string[]] ConvertExcelToCSV([string]$excelFilePath)
        - Converts Excel file to CSV format

    [string[]] GetWorksheets([string]$excelFilePath)
        - Gets available worksheets from Excel file

    [string] ConvertWorksheetToCSV([string]$excelFilePath, [string]$worksheetName)
        - Converts specific worksheet to CSV
#>

# Data Import Interface Contract
<#
    Data Importer Implementation Contract:

    [object[]] ImportCSV([string]$csvFilePath)
        - Imports CSV file as PowerShell objects

    [object] ImportJSON([string]$jsonFilePath)
        - Imports JSON file as PowerShell objects

    [bool] ValidateDataStructure([object[]]$data, [string]$expectedSchema)
        - Validates imported data structure against expected schema
#>

# File Path Provider Interface Contract
<#
    File Path Provider Implementation Contract:

    [string] GetLogFilePath([string]$baseName)
        - Generates timestamped log file path

    [string] GetScriptFilePath([string]$baseName)
        - Generates master script file path

    [string] GetBackupFilePath([string]$originalPath)
        - Generates backup file path from original path

    [string] GetTempFilePath([string]$extension)
        - Gets temporary file path with specified extension
#>
