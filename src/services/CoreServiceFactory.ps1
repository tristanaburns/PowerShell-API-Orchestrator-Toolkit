# CoreServiceFactory.ps1
# Factory class implementing the Factory Pattern for creating service instances
# Follows Dependency Inversion Principle by abstracting service creation
# NOTE: Service classes must be loaded BEFORE loading this factory

class CoreServiceFactory {
    # HASH TABLE ERADICATION: Replace with PSCustomObject instance management
    static hidden [object] $instances = $null
    static hidden [string] $basePath

    # Helper method to initialize instances PSCustomObject
    static hidden [void] EnsureInstancesObject() {
        if ($null -eq [CoreServiceFactory]::instances) {
            [CoreServiceFactory]::instances = [PSCustomObject]@{
                # Service instances will be dynamically added as PSCustomObject properties
            }
        }
    }

    # Helper method to check if service exists (replaces .ContainsKey())
    static hidden [bool] HasServiceInstance([string]$serviceName) {
        [CoreServiceFactory]::EnsureInstancesObject()
        return ($null -ne ([CoreServiceFactory]::instances | Get-Member -Name $serviceName -MemberType NoteProperty))
    }

    # Helper method to get service instance (replaces hash table indexing)
    static hidden [object] GetServiceInstance([string]$serviceName) {
        [CoreServiceFactory]::EnsureInstancesObject()
        if ([CoreServiceFactory]::HasServiceInstance($serviceName)) {
            return [CoreServiceFactory]::instances.$serviceName
        }
        return $null
    }

    # Helper method to set service instance (replaces hash table assignment)
    static hidden [void] SetServiceInstance([string]$serviceName, [object]$instance) {
        [CoreServiceFactory]::EnsureInstancesObject()
        if ([CoreServiceFactory]::HasServiceInstance($serviceName)) {
            [CoreServiceFactory]::instances.$serviceName = $instance
        }
        else {
            [CoreServiceFactory]::instances | Add-Member -NotePropertyName $serviceName -NotePropertyValue $instance
        }
    }

    # initialise factory with base path for services
    static [void] Initialize([string] $scriptPath) {
        [CoreServiceFactory]::basePath = $scriptPath
        # HASH TABLE ERADICATION: Initialize with PSCustomObject instead of [PSCustomObject]@{}
        [CoreServiceFactory]::instances = [PSCustomObject]@{}

        # CoreSSLManager initialization must be handled at the framework/global level before calling this method.
        Write-Verbose "CoreServiceFactory initialised - services will be created on-demand"
    }

    # Get or create logging service instance (Singleton pattern)
    static [object] GetLoggingService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('Logging')) {
            # Use root logs directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $logDir = Join-Path $rootPath "logs"
            $instance = New-Object LoggingService($logDir, $true, $true)
            [CoreServiceFactory]::SetServiceInstance('Logging', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('Logging')
    }

    # Get or create configuration service instance (Singleton pattern)
    static [object] GetConfigurationService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('Configuration')) {
            # Use root config directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $configPath = Join-Path $rootPath "config"
            $instance = New-Object ConfigurationService($configPath, [CoreServiceFactory]::GetLoggingService())
            [CoreServiceFactory]::SetServiceInstance('Configuration', $instance)

            # Update the logging service with the correct log level from config
            $loggingService = [CoreServiceFactory]::GetLoggingService()
            $loggingService.UpdateLogLevelFromConfig($instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('Configuration')
    }

    # Get or create credential service instance (Singleton pattern)
    static [object] GetCredentialService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('Credential')) {
            $credentialPath = Join-Path (Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent) "config\credentials"
            $instance = New-Object CredentialService($credentialPath, [CoreServiceFactory]::GetLoggingService())
            [CoreServiceFactory]::SetServiceInstance('Credential', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('Credential')
    }

    # Get or create authentication service instance (Singleton pattern)
    static [object] GetAuthenticationService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('Authentication')) {
            $instance = New-Object CoreAuthenticationService([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetCredentialService(), [CoreServiceFactory]::GetConfigurationService())
            [CoreServiceFactory]::SetServiceInstance('Authentication', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('Authentication')
    }

    # Get or create shared tool credential service instance (Singleton pattern)
    static [object] GetSharedToolCredentialService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('SharedToolCredential')) {
            $instance = New-Object SharedToolCredentialService([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), [CoreServiceFactory]::GetCredentialService())
            [CoreServiceFactory]::SetServiceInstance('SharedToolCredential', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('SharedToolCredential')
    }

    # Get or create shared tool utility service instance (Singleton pattern)
    static [object] GetSharedToolUtilityService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('SharedToolUtility')) {
            $instance = New-Object SharedToolUtilityService([CoreServiceFactory]::GetLoggingService())
            [CoreServiceFactory]::SetServiceInstance('SharedToolUtility', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('SharedToolUtility')
    }

    # Get or create hash table eradication utility service instance (Singleton pattern)
    static [object] GetHashTableEradicationUtility() {
        if (-not [CoreServiceFactory]::HasServiceInstance('HashTableEradicationUtility')) {
            # Create utility service wrapper for the hash table eradication script
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $utilityScriptPath = Join-Path $rootPath "src\utilities\HashTableEradicationUtility.ps1"

            # Verify the utility script exists
            if (-not (Test-Path $utilityScriptPath)) {
                $logger = [CoreServiceFactory]::GetLoggingService()
                $logger.LogError("CRITICAL: HashTableEradicationUtility.ps1 not found at expected path: $utilityScriptPath", "CoreServiceFactory")
                throw "Hash Table Eradication Utility script not found - this is a mandatory protocol enforcement tool"
            }

            # Create utility wrapper with execution capabilities
            $utilityWrapper = [PSCustomObject]@{
                ScriptPath      = $utilityScriptPath
                Logger          = [CoreServiceFactory]::GetLoggingService()
                UtilityPurpose  = "MANDATORY HASH TABLE ERADICATION ENFORCEMENT"
                Version         = "1.0.0"
                Status          = "CRITICAL SYSTEM UTILITY - DO NOT REMOVE OR MODIFY"

                # Method to scan for violations
                ScanViolations  = {
                    param(
                        [string]$Path = ".",
                        [string]$Output = "",
                        [switch]$Verbose
                    )

                    $paramsList = [PSCustomObject]@{
                        Path = $Path
                    }

                    if ($Output) {
                        $paramsList | Add-Member -NotePropertyName "Output" -NotePropertyValue $Output
                    }

                    if ($Verbose) {
                        $paramsList | Add-Member -NotePropertyName "Verbose" -NotePropertyValue $true
                    }

                    try {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentScriptPath = $utilityScriptPath

                        $currentLogger.LogInfo("Executing Hash Table Eradication Utility scan on path: $Path", "HashTableEradicationUtility")

                        # Execute the utility script with named parameters (protocol compliant)
                        if ($Output -and $Verbose) {
                            $result = & $currentScriptPath -Path $Path -Output $Output -Verbose
                        }
                        elseif ($Output) {
                            $result = & $currentScriptPath -Path $Path -Output $Output
                        }
                        elseif ($Verbose) {
                            $result = & $currentScriptPath -Path $Path -Verbose
                        }
                        else {
                            $result = & $currentScriptPath -Path $Path
                        }

                        $currentLogger.LogInfo("Hash Table Eradication Utility scan completed", "HashTableEradicationUtility")
                        return $result
                    }
                    catch {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentLogger.LogError("Hash Table Eradication Utility execution failed: $($_.Exception.Message)", "HashTableEradicationUtility")
                        throw "CRITICAL: Hash Table Protocol Enforcement failed - $($_.Exception.Message)"
                    }
                }

                # Method to get utility information
                GetUtilityInfo  = {
                    return [PSCustomObject]@{
                        Purpose            = "MANDATORY HASH TABLE ERADICATION ENFORCEMENT"
                        Version            = "1.0.0"
                        Status             = "CRITICAL SYSTEM UTILITY - DO NOT REMOVE OR MODIFY"
                        ScriptPath         = $utilityScriptPath
                        LastChecked        = Get-Date
                        ProtocolCompliance = "MANDATORY - ALL HASH TABLES FORBIDDEN"
                    }
                }

                # Method to validate utility integrity
                ValidateUtility = {
                    $currentScriptPath = $utilityScriptPath
                    $currentLogger = [CoreServiceFactory]::GetLoggingService()

                    if (-not (Test-Path $currentScriptPath)) {
                        $currentLogger.LogError("CRITICAL: Hash Table Eradication Utility script missing from expected path", "HashTableEradicationUtility")
                        return $false
                    }

                    # Check if the script contains the required warning text
                    $scriptContent = Get-Content $currentScriptPath -Raw
                    $requiredWarnings = @(
                        "DO NOT REMOVE OR MODIFY",
                        "MANDATORY PROTOCOL ENFORCEMENT",
                        "PERMANENT SYSTEM UTILITY"
                    )

                    foreach ($warning in $requiredWarnings) {
                        if ($scriptContent -notmatch [regex]::Escape($warning)) {
                            $currentLogger.LogError("CRITICAL: Hash Table Eradication Utility missing required warning: $warning", "HashTableEradicationUtility")
                            return $false
                        }
                    }

                    $currentLogger.LogInfo("Hash Table Eradication Utility integrity validated successfully", "HashTableEradicationUtility")
                    return $true
                }
            }

            # Validate utility integrity on creation
            if (-not $utilityWrapper.ValidateUtility.Invoke()) {
                throw "CRITICAL: Hash Table Eradication Utility failed integrity validation"
            }

            $logger = [CoreServiceFactory]::GetLoggingService()
            $logger.LogInfo("Hash Table Eradication Utility service initialized successfully", "CoreServiceFactory")
            $logger.LogWarning("PROTOCOL REMINDER: Hash Table Eradication Utility must NEVER be removed or modified", "CoreServiceFactory")

            [CoreServiceFactory]::SetServiceInstance('HashTableEradicationUtility', $utilityWrapper)
        }
        return [CoreServiceFactory]::GetServiceInstance('HashTableEradicationUtility')
    }

    # Get or create PSScriptAnalyzer utility service instance (Singleton pattern)
    static [object] GetPSScriptAnalyzerUtility() {
        if (-not [CoreServiceFactory]::HasServiceInstance('PSScriptAnalyzerUtility')) {
            # Create utility service wrapper for the PSScriptAnalyzer script
            # Calculate utilities path - services and utilities are sibling directories under src
            $srcPath = Split-Path ([CoreServiceFactory]::basePath) -Parent
            $utilityScriptPath = Join-Path $srcPath "utilities\PSScriptAnalyzerUtility.ps1"

            # Verify the utility script exists
            if (-not (Test-Path $utilityScriptPath)) {
                $logger = [CoreServiceFactory]::GetLoggingService()
                $logger.LogError("CRITICAL: PSScriptAnalyzerUtility.ps1 not found at expected path: $utilityScriptPath", "CoreServiceFactory")
                throw "PSScriptAnalyzer Utility script not found - this is a mandatory code quality enforcement tool"
            }

            # Create utility wrapper with analysis capabilities
            $utilityWrapper = [PSCustomObject]@{
                ScriptPath       = $utilityScriptPath
                Logger           = [CoreServiceFactory]::GetLoggingService()
                UtilityPurpose   = "MANDATORY CODE QUALITY ENFORCEMENT"
                Version          = "1.0.0"
                Status           = "CRITICAL SYSTEM UTILITY - DO NOT REMOVE OR MODIFY"

                # Method to analyze single file
                AnalyzeFile      = {
                    param(
                        [string]$FilePath,
                        [string]$Severity = "All",
                        [string]$OutputFormat = "Console",
                        [string]$OutputPath = "",
                        [switch]$Verbose
                    )

                    try {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentScriptPath = $utilityScriptPath

                        $currentLogger.LogInfo("Executing PSScriptAnalyzer analysis on file: $FilePath", "PSScriptAnalyzerUtility")

                        # Execute the utility script with named parameters
                        if ($OutputPath -and $Verbose) {
                            $result = & $currentScriptPath -Path $FilePath -Severity $Severity -OutputFormat $OutputFormat -OutputPath $OutputPath -Verbose
                        }
                        elseif ($OutputPath) {
                            $result = & $currentScriptPath -Path $FilePath -Severity $Severity -OutputFormat $OutputFormat -OutputPath $OutputPath
                        }
                        elseif ($Verbose) {
                            $result = & $currentScriptPath -Path $FilePath -Severity $Severity -OutputFormat $OutputFormat -Verbose
                        }
                        else {
                            $result = & $currentScriptPath -Path $FilePath -Severity $Severity -OutputFormat $OutputFormat
                        }

                        $currentLogger.LogInfo("PSScriptAnalyzer file analysis completed", "PSScriptAnalyzerUtility")
                        return $result
                    }
                    catch {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentLogger.LogError("PSScriptAnalyzer file analysis failed: $($_.Exception.Message)", "PSScriptAnalyzerUtility")
                        throw "CRITICAL: Code Quality Analysis failed - $($_.Exception.Message)"
                    }
                }

                # Method to analyze directory
                AnalyzeDirectory = {
                    param(
                        [string]$DirectoryPath,
                        [string]$Severity = "All",
                        [string]$OutputFormat = "Console",
                        [string]$OutputPath = "",
                        [switch]$Recurse,
                        [string[]]$ExcludeRules = [PSCustomObject]@{},
                        [switch]$Verbose
                    )

                    try {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentScriptPath = $utilityScriptPath

                        $currentLogger.LogInfo("Executing PSScriptAnalyzer analysis on directory: $DirectoryPath", "PSScriptAnalyzerUtility")

                        # Build parameter collection using PSCustomObject approach
                        $analysisParams = [PSCustomObject]@{
                            Path         = $DirectoryPath
                            Severity     = $Severity
                            OutputFormat = $OutputFormat
                        }

                        if ($OutputPath) {
                            $analysisParams | Add-Member -NotePropertyName "OutputPath" -NotePropertyValue $OutputPath
                        }

                        if ($Recurse) {
                            $analysisParams | Add-Member -NotePropertyName "Recurse" -NotePropertyValue $true
                        }

                        if ($ExcludeRules.Count -gt 0) {
                            $analysisParams | Add-Member -NotePropertyName "ExcludeRules" -NotePropertyValue $ExcludeRules
                        }

                        if ($Verbose) {
                            $analysisParams | Add-Member -NotePropertyName "Verbose" -NotePropertyValue $true
                        }

                        # Execute with named parameters (protocol compliant)
                        if ($analysisParams.PSObject.Properties.Name -contains "OutputPath" -and $analysisParams.PSObject.Properties.Name -contains "Recurse" -and $analysisParams.PSObject.Properties.Name -contains "Verbose") {
                            $result = & $currentScriptPath -Path $analysisParams.Path -Severity $analysisParams.Severity -OutputFormat $analysisParams.OutputFormat -OutputPath $analysisParams.OutputPath -Recurse -ExcludeRules $analysisParams.ExcludeRules -Verbose
                        }
                        elseif ($analysisParams.PSObject.Properties.Name -contains "OutputPath" -and $analysisParams.PSObject.Properties.Name -contains "Recurse") {
                            $result = & $currentScriptPath -Path $analysisParams.Path -Severity $analysisParams.Severity -OutputFormat $analysisParams.OutputFormat -OutputPath $analysisParams.OutputPath -Recurse -ExcludeRules $analysisParams.ExcludeRules
                        }
                        elseif ($analysisParams.PSObject.Properties.Name -contains "Recurse" -and $analysisParams.PSObject.Properties.Name -contains "Verbose") {
                            $result = & $currentScriptPath -Path $analysisParams.Path -Severity $analysisParams.Severity -OutputFormat $analysisParams.OutputFormat -Recurse -ExcludeRules $analysisParams.ExcludeRules -Verbose
                        }
                        elseif ($analysisParams.PSObject.Properties.Name -contains "Recurse") {
                            $result = & $currentScriptPath -Path $analysisParams.Path -Severity $analysisParams.Severity -OutputFormat $analysisParams.OutputFormat -Recurse -ExcludeRules $analysisParams.ExcludeRules
                        }
                        else {
                            $result = & $currentScriptPath -Path $analysisParams.Path -Severity $analysisParams.Severity -OutputFormat $analysisParams.OutputFormat -ExcludeRules $analysisParams.ExcludeRules
                        }

                        $currentLogger.LogInfo("PSScriptAnalyzer directory analysis completed", "PSScriptAnalyzerUtility")
                        return $result
                    }
                    catch {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentLogger.LogError("PSScriptAnalyzer directory analysis failed: $($_.Exception.Message)", "PSScriptAnalyzerUtility")
                        throw "CRITICAL: Code Quality Analysis failed - $($_.Exception.Message)"
                    }
                }

                # Method to analyze entire codebase
                AnalyzeCodebase  = {
                    param(
                        [string]$Severity = "All",
                        [string]$OutputFormat = "JSON",
                        [string]$OutputPath = ".\logs\codebase-analysis.json",
                        [string[]]$ExcludeRules = @("PSAvoidUsingWriteHost", "PSUseShouldProcessForStateChangingFunctions"),
                        [switch]$Verbose
                    )

                    try {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentScriptPath = $utilityScriptPath
                        $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent

                        $currentLogger.LogInfo("Executing PSScriptAnalyzer analysis on entire codebase", "PSScriptAnalyzerUtility")

                        # Execute with full codebase parameters
                        if ($Verbose) {
                            $result = & $currentScriptPath -Path $rootPath -Severity $Severity -OutputFormat $OutputFormat -OutputPath $OutputPath -Recurse -ExcludeRules $ExcludeRules -Verbose
                        }
                        else {
                            $result = & $currentScriptPath -Path $rootPath -Severity $Severity -OutputFormat $OutputFormat -OutputPath $OutputPath -Recurse -ExcludeRules $ExcludeRules
                        }

                        $currentLogger.LogInfo("PSScriptAnalyzer codebase analysis completed", "PSScriptAnalyzerUtility")
                        return $result
                    }
                    catch {
                        $currentLogger = [CoreServiceFactory]::GetLoggingService()
                        $currentLogger.LogError("PSScriptAnalyzer codebase analysis failed: $($_.Exception.Message)", "PSScriptAnalyzerUtility")
                        throw "CRITICAL: Code Quality Analysis failed - $($_.Exception.Message)"
                    }
                }

                # Method to get utility information
                GetUtilityInfo   = {
                    return [PSCustomObject]@{
                        Purpose              = "MANDATORY CODE QUALITY ENFORCEMENT"
                        Version              = "1.0.0"
                        Status               = "CRITICAL SYSTEM UTILITY - DO NOT REMOVE OR MODIFY"
                        ScriptPath           = $utilityScriptPath
                        LastChecked          = Get-Date
                        ProtocolCompliance   = "MANDATORY - ALL CODE MUST PASS ANALYSIS"
                        SupportedSeverities  = @("Error", "Warning", "Information", "All")
                        SupportedFormats     = @("Console", "JSON", "XML", "CSV")
                        DefaultExcludedRules = @("PSAvoidUsingWriteHost", "PSUseShouldProcessForStateChangingFunctions")
                    }
                }

                # Method to validate utility integrity
                ValidateUtility  = {
                    $currentScriptPath = $utilityScriptPath
                    $currentLogger = [CoreServiceFactory]::GetLoggingService()

                    if (-not (Test-Path $currentScriptPath)) {
                        $currentLogger.LogError("CRITICAL: PSScriptAnalyzer Utility script missing from expected path", "PSScriptAnalyzerUtility")
                        return $false
                    }

                    # Check if the script contains the required warning text
                    $scriptContent = Get-Content $currentScriptPath -Raw
                    $requiredWarnings = @(
                        "DO NOT REMOVE OR MODIFY",
                        "MANDATORY CODE QUALITY ENFORCEMENT",
                        "CRITICAL SYSTEM UTILITY"
                    )

                    foreach ($warning in $requiredWarnings) {
                        if ($scriptContent -notmatch [regex]::Escape($warning)) {
                            $currentLogger.LogError("CRITICAL: PSScriptAnalyzer Utility missing required warning: $warning", "PSScriptAnalyzerUtility")
                            return $false
                        }
                    }

                    $currentLogger.LogInfo("PSScriptAnalyzer Utility integrity validated successfully", "PSScriptAnalyzerUtility")
                    return $true
                }
            }

            # Validate utility integrity on creation
            if (-not $utilityWrapper.ValidateUtility.Invoke()) {
                throw "CRITICAL: PSScriptAnalyzer Utility failed integrity validation"
            }

            $logger = [CoreServiceFactory]::GetLoggingService()
            $logger.LogInfo("PSScriptAnalyzer Utility service initialized successfully", "CoreServiceFactory")
            $logger.LogWarning("PROTOCOL REMINDER: PSScriptAnalyzer Utility must NEVER be removed or modified", "CoreServiceFactory")

            [CoreServiceFactory]::SetServiceInstance('PSScriptAnalyzerUtility', $utilityWrapper)
        }
        return [CoreServiceFactory]::GetServiceInstance('PSScriptAnalyzerUtility')
    }

    # Get or create workflow orchestration service instance (Singleton pattern)
    static [object] GetWorkflowOrchestrationService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('WorkflowOrchestration')) {
            $instance = New-Object WorkflowOrchestrationService(
                [CoreServiceFactory]::GetLoggingService(),
                [CoreServiceFactory]::GetSharedToolUtilityService(),
                [CoreServiceFactory]::GetWorkflowOperationsService()
            )
            [CoreServiceFactory]::SetServiceInstance('WorkflowOrchestration', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('WorkflowOrchestration')
    }

    # Get or create API service instance
    static [object] GetAPIService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('API')) {
            $instance = New-Object CoreAPIService([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), [CoreServiceFactory]::GetConfigurationService())
            [CoreServiceFactory]::SetServiceInstance('API', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('API')
    }

    # Get or create NSX configuration manager instance
    static [object] GetNSXConfigManager() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXConfig')) {
            # Use data/exports directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $configsPath = Join-Path $rootPath "data\exports"
            $instance = New-Object NSXConfigManager([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), [CoreServiceFactory]::GetAPIService(), $configsPath, [CoreServiceFactory]::GetStandardFileNamingService(), [CoreServiceFactory]::GetWorkflowOperationsService())
            [CoreServiceFactory]::SetServiceInstance('NSXConfig', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXConfig')
    }

    # Get or create NSX configuration reset service instance
    static [object] GetConfigurationResetService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('ConfigReset')) {
            $instance = New-Object NSXConfigReset([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), [CoreServiceFactory]::GetAPIService())
            [CoreServiceFactory]::SetServiceInstance('ConfigReset', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('ConfigReset')
    }

    # Get or create standard file naming service instance (Singleton pattern)
    static [object] GetStandardFileNamingService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('StandardFileNaming')) {
            $instance = New-Object StandardFileNamingService([CoreServiceFactory]::GetLoggingService())
            [CoreServiceFactory]::SetServiceInstance('StandardFileNaming', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('StandardFileNaming')
    }

    # Get or create NSX Policy Export Service instance
    static [object] GetNSXPolicyExportService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXPolicyExport')) {
            $instance = New-Object NSXPolicyExportService([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAPIService(), [CoreServiceFactory]::GetStandardFileNamingService(), [CoreServiceFactory]::GetOpenAPISchemaService())
            [CoreServiceFactory]::SetServiceInstance('NSXPolicyExport', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXPolicyExport')
    }

    # Get or create NSX differential configuration manager instance
    static [object] GetNSXDifferentialConfigManager() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXDifferentialConfig')) {
            # Use diffs directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $diffsPath = Join-Path $rootPath "data\diffs"

            # Get dependencies for functionality
            $configValidator = [CoreServiceFactory]::GetNSXConfigValidator()
            $dataObjectFilter = [CoreServiceFactory]::GetDataObjectFilterService()
            $openAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()

            $instance = New-Object NSXDifferentialConfigManager(
                [CoreServiceFactory]::GetLoggingService(),
                [CoreServiceFactory]::GetAuthenticationService(),
                [CoreServiceFactory]::GetAPIService(),
                [CoreServiceFactory]::GetNSXConfigManager(),
                $diffsPath,
                [CoreServiceFactory]::GetStandardFileNamingService(),
                $configValidator,
                $dataObjectFilter,
                $openAPISchemaService
            )
            [CoreServiceFactory]::SetServiceInstance('NSXDifferentialConfig', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXDifferentialConfig')
    }

    # Get or create NSX config validator instance with OpenAPI schema service integration
    static [object] GetNSXConfigValidator() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXConfigValidator')) {
            $openAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()
            $instance = New-Object NSXConfigValidator([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), $openAPISchemaService)

            # CRITICAL: Verify the instance has the GetOpenAPISchemas method to prevent production errors
            $methodExists = $instance.PSObject.Methods.Name -contains "GetOpenAPISchemas"
            if (-not $methodExists) {
                $logger = [CoreServiceFactory]::GetLoggingService()
                $logger.LogError("CRITICAL: NSXConfigValidator instance missing GetOpenAPISchemas method - this indicates class loading issues", "CoreServiceFactory")
                $logger.LogError("Class type: $($instance.GetType().Name)", "CoreServiceFactory")
                $logger.LogError("Class full name: $($instance.GetType().FullName)", "CoreServiceFactory")
                $logger.LogError("Assembly location: $($instance.GetType().Assembly.Location)", "CoreServiceFactory")

                # Force class reload by creating a fresh instance
                try {
                    $logger.LogWarning("Attempting to force reload NSXConfigValidator class", "CoreServiceFactory")
                    $instance = New-Object NSXConfigValidator([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), $openAPISchemaService)
                    $retestMethodExists = $instance.PSObject.Methods.Name -contains "GetOpenAPISchemas"
                    if ($retestMethodExists) {
                        $logger.LogInfo("SUCCESS: NSXConfigValidator class reload successful - GetOpenAPISchemas method now available", "CoreServiceFactory")
                    }
                    else {
                        $logger.LogError("FAILURE: NSXConfigValidator class reload failed - GetOpenAPISchemas method still missing", "CoreServiceFactory")
                    }
                }
                catch {
                    $logger.LogError("Exception during NSXConfigValidator class reload: $($_.Exception.Message)", "CoreServiceFactory")
                }
            }
            else {
                $logger = [CoreServiceFactory]::GetLoggingService()
                $logger.LogInfo("NSXConfigValidator instance created successfully with GetOpenAPISchemas method available", "CoreServiceFactory")
            }

            [CoreServiceFactory]::SetServiceInstance('NSXConfigValidator', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXConfigValidator')
    }

    # Alias for GetNSXConfigValidator for backward compatibility
    static [object] GetConfigurationValidator() {
        return [CoreServiceFactory]::GetNSXConfigValidator()
    }

    # Get or create NSX system object filter instance
    static [object] GetDataObjectFilterService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('DataObjectFilterService')) {
            $instance = New-Object DataObjectFilterService([CoreServiceFactory]::GetLoggingService())
            [CoreServiceFactory]::SetServiceInstance('DataObjectFilterService', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('DataObjectFilterService')
    }

    # Get or create OpenAPI schema service instance
    static [object] GetOpenAPISchemaService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('OpenAPISchemaService')) {
            $instance = New-Object OpenAPISchemaService(
                [CoreServiceFactory]::GetLoggingService(),
                [CoreServiceFactory]::GetAuthenticationService(),
                [CoreServiceFactory]::GetAPIService(),
                [CoreServiceFactory]::GetStandardFileNamingService(),
                [CoreServiceFactory]::GetWorkflowOperationsService()
            )
            [CoreServiceFactory]::SetServiceInstance('OpenAPISchemaService', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('OpenAPISchemaService')
    }

    # Get or create OpenAPI schema service instance with custom configuration
    static [object] GetOpenAPISchemaService([object] $customEndpoints, [object] $cacheConfig) {
        $serviceKey = 'OpenAPISchemaService_Custom'

        if (-not [CoreServiceFactory]::HasServiceInstance($serviceKey)) {
            $instance = New-Object OpenAPISchemaService(
                [CoreServiceFactory]::GetLoggingService(),
                [CoreServiceFactory]::GetAuthenticationService(),
                [CoreServiceFactory]::GetAPIService(),
                $cacheConfig,
                [CoreServiceFactory]::GetStandardFileNamingService(),
                [CoreServiceFactory]::GetWorkflowOperationsService()
            )
            [CoreServiceFactory]::SetServiceInstance($serviceKey, $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance($serviceKey)
    }

    # Get or create OpenAPI schema service instance with NSX Manager and custom endpoints
    static [object] GetOpenAPISchemaService([string] $nsxManager, [PSCredential] $credential, [object] $customEndpoints) {
        $serviceKey = "OpenAPISchemaService_$nsxManager"

        if (-not [CoreServiceFactory]::HasServiceInstance($serviceKey)) {
            $instance = New-Object OpenAPISchemaService(
                [CoreServiceFactory]::GetLoggingService(),
                [CoreServiceFactory]::GetAuthenticationService(),
                [CoreServiceFactory]::GetAPIService(),
                $nsxManager,
                $credential,
                $customEndpoints,
                $null,
                [CoreServiceFactory]::GetStandardFileNamingService(),
                [CoreServiceFactory]::GetWorkflowOperationsService()
            )
            [CoreServiceFactory]::SetServiceInstance($serviceKey, $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance($serviceKey)
    }

    # Get or create CSV Data Parsing Service instance
    static [object] GetCSVDataParsingService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('CSVDataParsing')) {
            # Use data directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $csvPath = Join-Path $rootPath "data"
            $jsonPath = Join-Path $rootPath "data"
            $instance = New-Object CSVDataParsingService([CoreServiceFactory]::GetLoggingService(), $csvPath, $jsonPath)
            [CoreServiceFactory]::SetServiceInstance('CSVDataParsing', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('CSVDataParsing')
    }

    # Get or create Data Transformation Factory instance
    static [object] GetDataTransformationFactory() {
        if (-not [CoreServiceFactory]::HasServiceInstance('DataTransformationFactory')) {
            # Use data directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $dataPath = Join-Path $rootPath "data"
            $instance = New-Object DataTransformationFactory([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetConfigurationService(), $dataPath)
            [CoreServiceFactory]::SetServiceInstance('DataTransformationFactory', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('DataTransformationFactory')
    }

    # Get or create NSX API Service instance
    static [object] GetNSXAPIService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXAPI')) {
            # NSXAPIService requires an NSX Manager parameter - use placeholder for factory
            $nsxManager = "placeholder.local"
            $instance = New-Object NSXAPIService($nsxManager, [CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetAuthenticationService(), [CoreServiceFactory]::GetConfigurationService())
            [CoreServiceFactory]::SetServiceInstance('NSXAPI', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXAPI')
    }

    # Get or create NSX Hierarchical API Service instance
    static [object] GetNSXHierarchicalAPIService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXHierarchicalAPI')) {
            $instance = New-Object NSXHierarchicalAPIService([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetNSXAPIService())
            [CoreServiceFactory]::SetServiceInstance('NSXHierarchicalAPI', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXHierarchicalAPI')
    }

    # Get or create NSX Hierarchical Structure Service instance
    static [object] GetNSXHierarchicalStructureService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('NSXHierarchicalStructure')) {
            # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
            $config = [PSCustomObject]@{ default_domain = "default" }
            $instance = New-Object NSXHierarchicalStructureService([CoreServiceFactory]::GetLoggingService(), $config)
            [CoreServiceFactory]::SetServiceInstance('NSXHierarchicalStructure', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('NSXHierarchicalStructure')
    }

    # Get or create Data Transformation Pipeline instance
    static [object] GetDataTransformationPipeline() {
        if (-not [CoreServiceFactory]::HasServiceInstance('DataTransformationPipeline')) {
            # Use data directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $workingDir = Join-Path $rootPath "data"

            # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
            $pipelineConfig = [PSCustomObject]@{
                csv_source_directory    = Join-Path $workingDir "csv"
                json_output_directory   = Join-Path $workingDir "json"
                config_output_directory = Join-Path $workingDir "configs"
                validation_enabled      = $true
                auto_apply              = $false
            }

            $instance = New-Object DataTransformationPipeline(
                [CoreServiceFactory]::GetLoggingService(),
                [CoreServiceFactory]::GetCSVDataParsingService(),
                [CoreServiceFactory]::GetNSXHierarchicalStructureService(),
                [CoreServiceFactory]::GetNSXConfigManager(),
                [CoreServiceFactory]::GetNSXConfigValidator(),
                $workingDir,
                $pipelineConfig
            )
            [CoreServiceFactory]::SetServiceInstance('DataTransformationPipeline', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('DataTransformationPipeline')
    }

    # ========================================
    # PHASE 2: TOOL ORCHESTRATION SERVICES
    # ========================================

    # Get or create Tool Orchestration Service instance
    static [object] GetToolOrchestrator() {
        if (-not [CoreServiceFactory]::HasServiceInstance('ToolOrchestrator')) {
            # Use tools directory - go up two levels from src/services to get to root
            $rootPath = Split-Path (Split-Path ([CoreServiceFactory]::basePath) -Parent) -Parent
            $toolsPath = Join-Path $rootPath "tools"
            $instance = New-Object ToolOrchestrationService([CoreServiceFactory]::GetLoggingService(), $toolsPath)
            [CoreServiceFactory]::SetServiceInstance('ToolOrchestrator', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('ToolOrchestrator')
    }

    # ========================================
    # PHASE 3: INTEGRATION SERVICES
    # ========================================

    # Get or create Workflow Definition Service instance
    static [object] GetWorkflowDefinitionService() {
        if (-not [CoreServiceFactory]::HasServiceInstance('WorkflowDefinition')) {
            $instance = New-Object WorkflowDefinitionService([CoreServiceFactory]::GetLoggingService(), [CoreServiceFactory]::GetToolOrchestrator())
            [CoreServiceFactory]::SetServiceInstance('WorkflowDefinition', $instance)
        }
        return [CoreServiceFactory]::GetServiceInstance('WorkflowDefinition')
    }

    # Get or create Operational Excellence Service instance (default JSON configuration)
    static [object] GetWorkflowOperationsService() {
        # Ensure the workflow operations service is registered under both the legacy
        # key ('WorkflowOperationsService') and the canonical key ('WorkflowOperationsService').
        # Tools reference the canonical key, while some Phase-3 helpers may still use
        # the legacy alias - this guarantees backward compatibility without forcing
        # a broad rename across the codebase.

        if (-not [CoreServiceFactory]::HasServiceInstance('WorkflowOperationsService')) {
            try {
                $instance = New-Object WorkflowOperationsService(
                    [CoreServiceFactory]::GetLoggingService()
                )
            }
            catch {
                # Constructor failed (likely due to missing ConfigService method). Log and register null placeholder
                Write-Warning "WorkflowOperationsService instantiation failed: $($_.Exception.Message). Static methods will remain available."
                $instance = $null
            }

            # Register under both keys regardless (null allowed)
            [CoreServiceFactory]::SetServiceInstance('WorkflowOperationsService', $instance)
            [CoreServiceFactory]::SetServiceInstance('WorkflowOperationsService', $instance)
        }
        # If the legacy key exists but the canonical one does not (edge-case for older
        # initialisations), create the canonical alias to point to the same object.
        elseif (-not [CoreServiceFactory]::HasServiceInstance('WorkflowOperationsService') -and [CoreServiceFactory]::HasServiceInstance('WorkflowOperationsService')) {
            [CoreServiceFactory]::SetServiceInstance('WorkflowOperationsService', [CoreServiceFactory]::GetServiceInstance('WorkflowOperationsService'))
        }

        return [CoreServiceFactory]::GetServiceInstance('WorkflowOperationsService')
    }

    # Get or create Operational Excellence Service instance with direct toolkit paths configuration
    static [object] GetWorkflowOperationsService([object] $toolkitPathsConfig) {
        $serviceKey = 'WorkflowOperationsService_CustomPaths'

        if (-not [CoreServiceFactory]::HasServiceInstance($serviceKey)) {
            try {
                $instance = New-Object WorkflowOperationsService(
                    [CoreServiceFactory]::GetLoggingService(),
                    $toolkitPathsConfig
                )
                [CoreServiceFactory]::SetServiceInstance($serviceKey, $instance)
            }
            catch {
                Write-Warning "WorkflowOperationsService with custom paths failed: $($_.Exception.Message)"
                [CoreServiceFactory]::SetServiceInstance($serviceKey, $null)
            }
        }
        return [CoreServiceFactory]::GetServiceInstance($serviceKey)
    }

    # Get or create Operational Excellence Service instance with custom JSON file path and runtime config
    static [object] GetWorkflowOperationsService([string] $customConfigPath, [object] $runtimePathsConfig = $null) {
        $serviceKey = "WorkflowOperationsService_CustomConfig_$([System.IO.Path]::GetFileNameWithoutExtension($customConfigPath))"

        if (-not [CoreServiceFactory]::HasServiceInstance($serviceKey)) {
            try {
                $instance = New-Object WorkflowOperationsService(
                    [CoreServiceFactory]::GetLoggingService(),
                    $customConfigPath,
                    $runtimePathsConfig
                )
                [CoreServiceFactory]::SetServiceInstance($serviceKey, $instance)
            }
            catch {
                Write-Warning "WorkflowOperationsService with custom config path failed: $($_.Exception.Message)"
                [CoreServiceFactory]::SetServiceInstance($serviceKey, $null)
            }
        }
        return [CoreServiceFactory]::GetServiceInstance($serviceKey)
    }

    # Get all integration services as a collection
    static [object] GetEnhancedIntegrationServices() {
        <#
        .SYNOPSIS
            Returns all Phase 3 integration services

        .DESCRIPTION
            Provides access to workflow definition, operational excellence,
            and advanced tool orchestration capabilities

        .OUTPUTS
            PSCustomObject containing all integration services
        #>

        # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
        return [PSCustomObject]@{
            WorkflowDefinition        = [CoreServiceFactory]::GetWorkflowDefinitionService()
            WorkflowOperationsService = [CoreServiceFactory]::GetWorkflowOperationsService()
            ToolOrchestrator          = [CoreServiceFactory]::GetToolOrchestrator()
        }
    }

    # Get tool-specific service subset for focused tool operations
    static [object] GetToolServices([string]$toolName) {
        <#
        .SYNOPSIS
            Returns tool-specific service subset for optimized tool operations

        .DESCRIPTION
            Provides only the services needed by specific tools to reduce overhead
            and improve focus. Each tool gets exactly what it needs.

        .PARAMETER toolName
            Name of the tool to get services for

        .OUTPUTS
            PSCustomObject containing tool-specific services
        #>

        # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
        $coreServices = [PSCustomObject]@{
            Logger                      = [CoreServiceFactory]::GetLoggingService()
            CredentialService           = [CoreServiceFactory]::GetCredentialService()
            AuthService                 = [CoreServiceFactory]::GetAuthenticationService()
            ConfigurationService        = [CoreServiceFactory]::GetConfigurationService()
            SharedToolCredentialService = [CoreServiceFactory]::GetSharedToolCredentialService()
        }

        $toolSpecificServices = switch ($toolName) {
            "NSXPolicyConfigExport" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService           = [CoreServiceFactory]::GetAPIService()
                    PolicyExportService  = [CoreServiceFactory]::GetNSXPolicyExportService()
                    ConfigValidator      = [CoreServiceFactory]::GetNSXConfigValidator()
                    FileNamingService    = [CoreServiceFactory]::GetStandardFileNamingService()
                    OpenAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
            "ApplyNSXConfig" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService           = [CoreServiceFactory]::GetAPIService()
                    ConfigManager        = [CoreServiceFactory]::GetNSXConfigManager()
                    ConfigValidator      = [CoreServiceFactory]::GetNSXConfigValidator()
                    FileNamingService    = [CoreServiceFactory]::GetStandardFileNamingService()
                    OpenAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
            "ApplyNSXConfigDifferential" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService                = [CoreServiceFactory]::GetAPIService()
                    DifferentialConfigManager = [CoreServiceFactory]::GetNSXDifferentialConfigManager()
                    ConfigValidator           = [CoreServiceFactory]::GetNSXConfigValidator()
                    DataObjectFilterService   = [CoreServiceFactory]::GetDataObjectFilterService()
                    OpenAPISchemaService      = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
            "NSXConfigSync" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService                = [CoreServiceFactory]::GetAPIService()
                    ToolOrchestrator          = [CoreServiceFactory]::GetToolOrchestrator()
                    PolicyExportService       = [CoreServiceFactory]::GetNSXPolicyExportService()
                    DifferentialConfigManager = [CoreServiceFactory]::GetNSXDifferentialConfigManager()
                    ConfigValidator           = [CoreServiceFactory]::GetNSXConfigValidator()
                    OpenAPISchemaService      = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
            "NSXConfigReset" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService           = [CoreServiceFactory]::GetAPIService()
                    ConfigResetService   = [CoreServiceFactory]::GetConfigurationResetService()
                    ConfigValidator      = [CoreServiceFactory]::GetNSXConfigValidator()
                    OpenAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
            "NSXConnectionTest" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService = [CoreServiceFactory]::GetAPIService()
                }
            }
            "NSXCredentialManager" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    # Core services only - credential management focused
                }
            }
            "VerifyNSXConfiguration" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService           = [CoreServiceFactory]::GetAPIService()
                    ConfigValidator      = [CoreServiceFactory]::GetNSXConfigValidator()
                    PolicyExportService  = [CoreServiceFactory]::GetNSXPolicyExportService()
                    OpenAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
            "FixRangeAssociations" {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    APIService    = [CoreServiceFactory]::GetAPIService()
                    ConfigManager = [CoreServiceFactory]::GetNSXConfigManager()
                }
            }
            default {
                # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
                [PSCustomObject]@{
                    # Default: provide common services
                    APIService           = [CoreServiceFactory]::GetAPIService()
                    ConfigValidator      = [CoreServiceFactory]::GetNSXConfigValidator()
                    OpenAPISchemaService = [CoreServiceFactory]::GetOpenAPISchemaService()
                }
            }
        }

        # Merge core services with tool-specific services
        # HASH TABLE ERADICATION: Replace service merging with PSCustomObject pattern
        # Instead of .Clone() and .Keys property (hash table methods), use PSCustomObject merging
        $allServices = [PSCustomObject]@{}

        # Copy all core service properties
        $coreServices.PSObject.Properties | ForEach-Object {
            $allServices | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
        }

        # Copy all tool-specific service properties
        $toolSpecificServices.PSObject.Properties | ForEach-Object {
            $allServices | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
        }

        return $allServices
    }

    # Get standardized parameter service for tool parameter management
    static [object] GetStandardParameterService() {
        <#
        .SYNOPSIS
            Returns standardized parameter management capabilities

        .DESCRIPTION
            Provides parameter standardization and validation services for tool integration

        .OUTPUTS
            PSCustomObject containing parameter management utilities
        #>

        # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
        return [PSCustomObject]@{
            ToolOrchestrator     = [CoreServiceFactory]::GetToolOrchestrator()
            Logger               = [CoreServiceFactory]::GetLoggingService()
            ConfigurationService = [CoreServiceFactory]::GetConfigurationService()
        }
    }

    # Generic service retrieval method
    static [object] GetService([string] $serviceName) {
        $result = switch ($serviceName) {
            "LoggingService" { [CoreServiceFactory]::GetLoggingService() }
            "ConfigurationService" { [CoreServiceFactory]::GetConfigurationService() }
            "CredentialService" { [CoreServiceFactory]::GetCredentialService() }
            "CoreAuthenticationService" { [CoreServiceFactory]::GetAuthenticationService() }
            "SharedToolCredentialService" { [CoreServiceFactory]::GetSharedToolCredentialService() }
            "CoreAPIService" { [CoreServiceFactory]::GetAPIService() }
            "NSXConfigManager" { [CoreServiceFactory]::GetNSXConfigManager() }
            "NSXDifferentialConfigManager" { [CoreServiceFactory]::GetNSXDifferentialConfigManager() }
            "NSXConfigReset" { [CoreServiceFactory]::GetConfigurationResetService() }
            "NSXConfigValidator" { [CoreServiceFactory]::GetNSXConfigValidator() }
            "DataObjectFilterService" { [CoreServiceFactory]::GetDataObjectFilterService() }
            "OpenAPISchemaService" { [CoreServiceFactory]::GetOpenAPISchemaService() }
            "NSXPolicyExportService" { [CoreServiceFactory]::GetNSXPolicyExportService() }
            "StandardFileNamingService" { [CoreServiceFactory]::GetStandardFileNamingService() }
            "CSVDataParsingService" { [CoreServiceFactory]::GetCSVDataParsingService() }
            "DataTransformationFactory" { [CoreServiceFactory]::GetDataTransformationFactory() }
            "NSXAPIService" { [CoreServiceFactory]::GetNSXAPIService() }
            "NSXHierarchicalAPIService" { [CoreServiceFactory]::GetNSXHierarchicalAPIService() }
            "NSXHierarchicalStructureService" { [CoreServiceFactory]::GetNSXHierarchicalStructureService() }
            "DataTransformationPipeline" { [CoreServiceFactory]::GetDataTransformationPipeline() }
            "ToolOrchestrationService" { [CoreServiceFactory]::GetToolOrchestrator() }
            "WorkflowDefinitionService" { [CoreServiceFactory]::GetWorkflowDefinitionService() }
            "WorkflowOperationsService" { [CoreServiceFactory]::GetWorkflowOperationsService() }
            default { throw "Unknown service: $serviceName" }
        }
        return $result
    }

    # Clear all instances (for testing or reset)
    static [void] Reset() {
        # HASH TABLE ERADICATION: Replace hash table with PSCustomObject
        [CoreServiceFactory]::instances = [PSCustomObject]@{}
    }
}
