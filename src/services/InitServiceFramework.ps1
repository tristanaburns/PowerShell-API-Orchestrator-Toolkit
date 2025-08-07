# InitServiceFramework.ps1
# Service InitServiceFramework and Initialization Script
# Handles loading and initializing all core services for NSX configuration management



# Function to initialize the service framework and return services
function Initialize-ServiceFramework {
    param(
        [string]$ServicePath = $PSScriptRoot
    )

    try {
        Write-Information "Initializing NSX Service Framework..." -InformationAction Continue

        # Get the absolute path for services
        $servicesPath = Resolve-Path $ServicePath -ErrorAction Stop
        Write-Verbose "Services path: $servicesPath"

        <#
        Dependency order:
        1.  CoreSSLManager.ps1                    # No dependencies
        2.  LoggingService.ps1                    # No dependencies
        3.  ConfigurationService.ps1              # -> LoggingService
        4.  CredentialService.ps1                 # -> LoggingService
        5.  CoreAuthenticationService.ps1         # -> Multiple core services
        6.  CoreAPIService.ps1                    # -> LoggingService, CoreAuthenticationService
        7.  StandardFileNamingService.ps1         # -> LoggingService
        8.  NSXAPIService.ps1                     # -> Extends CoreAPIService
        9.DataObjectFilterService.ps1             # -> LoggingService
        10. CSVDataParsingService.ps1             # -> LoggingService
        11. NSXHierarchicalStructureService.ps1   # -> LoggingService
        12. NSXHierarchicalAPIService.ps1         # -> LoggingService, NSXAPIService
        13. DataTransformationFactory.ps1         # -> LoggingService, ConfigurationService
        14. CoreServiceFactory.ps1                # -> All managed services
        15. NSXConfigValidator.ps1                # -> CoreServiceFactory
        16. NSXPolicyExportService.ps1            # -> Multiple services
        17. NSXConfigManager.ps1                  # -> Multiple services
        18. NSXDifferentialConfigManager.ps1      # -> CoreServiceFactory
        19. NSXConfigReset.ps1                    # -> LoggingService
        20. DataTransformationPipeline.ps1        # -> Multiple dependencies
        #>

        # Load all service classes in correct dependency order
        $serviceFiles = @(
            # Core foundational services (no dependencies)
            "CoreSSLManager.ps1",                    # No dependencies
            "LoggingService.ps1",                    # No dependencies
            "SharedToolUtilityService.ps1",          # Depends on LoggingService only
            # Basic services that depend on foundational services
            "ConfigurationService.ps1",             # Depends on LoggingService
            "CredentialService.ps1",                # Depends on LoggingService

            # Authentication and API services
            "CoreAuthenticationService.ps1",        # Depends on LoggingService, ConfigurationService, CredentialService, CoreSSLManager
            "SharedToolCredentialService.ps1",      # Depends on LoggingService, CoreAuthenticationService, CredentialService
            "CoreAPIService.ps1",                   # Depends on LoggingService, CoreAuthenticationService

            # Utility services
            "StandardFileNamingService.ps1",        # Depends on LoggingService
            "OpenAPISchemaService.ps1",             # Depends on LoggingService

            # Extended API services that build on core services
            "NSXAPIService.ps1",                    # Extends CoreAPIService
            "DataObjectFilterService.ps1",            # Depends on LoggingService
            "CSVDataParsingService.ps1",            # Depends on LoggingService
            "NSXHierarchicalStructureService.ps1",  # Depends on LoggingService
            "NSXHierarchicalAPIService.ps1",        # Depends on LoggingService, NSXAPIService
            "DataTransformationFactory.ps1",        # Depends on LoggingService, ConfigurationService

            # Service Factory (moved before WorkflowOperationsService to resolve circular dependency)
            "CoreServiceFactory.ps1",               # Must be loaded before services that reference CoreServiceFactory in constructors

            # services that depend on CoreServiceFactory
            "WorkflowOperationsService.ps1",        # Depends on LoggingService, ConfigurationService, SharedToolUtilityService (via CoreServiceFactory)

            # Tool orchestration services (loaded after CoreServiceFactory)
            "ToolOrchestrationService.ps1",         # Depends on LoggingService (via CoreServiceFactory)
            "WorkflowDefinitionService.ps1",        # Depends on LoggingService, ToolOrchestrator

            # NSX-specific services that use CoreServiceFactory
            "NSXConfigValidator.ps1",               # Uses CoreServiceFactory
            "NSXPolicyExportService.ps1",           # Depends on LoggingService, CoreAPIService, StandardFileNamingService, NSXConfigValidator
            "NSXConfigManager.ps1",                 # Depends on LoggingService, CoreAuthenticationService, CoreAPIService, StandardFileNamingService
            "NSXDifferentialConfigManager.ps1",     # Uses CoreServiceFactory
            "NSXConfigReset.ps1",                   # Depends on LoggingService

            # Complex pipeline services (loaded last due to multiple dependencies)
            "DataTransformationPipeline.ps1"        # Depends on multiple services
        )

        foreach ($serviceFile in $serviceFiles) {
            $servicePath = Join-Path $servicesPath $serviceFile
            if (-not (Test-Path $servicePath)) {
                Write-Warning "$serviceFile not found at: $servicePath - skipping"
                continue
            }

            Write-Verbose "Loading service: $serviceFile"
            try {
                # Use dot-sourcing with global scope to ensure services are available globally
                . $servicePath

                # Immediately initialize CoreSSLManager after loading it
                if ($serviceFile -eq "CoreSSLManager.ps1") {
                    if (-not ([type]::GetType('CoreSSLManager', $false))) {
                        Write-Warning "CoreSSLManager class not found immediately after loading $servicePath. Continuing initialization; static helpers may still be available."
                    }
                    try {
                        $sslInitResult = [CoreSSLManager]::Initialize()
                        if ($sslInitResult) {
                            Write-Verbose "CoreSSLManager SSL bypass initialized successfully"
                        }
                        else {
                            throw "Critical error: CoreSSLManager SSL bypass initialization failed. Aborting initialization."
                        }
                    }
                    catch {
                        throw "Critical error: Exception during CoreSSLManager SSL bypass initialization: $($_.Exception.Message)"
                    }
                }

                # Initialize CoreServiceFactory at global level immediately after loading it
                if ($serviceFile -eq "CoreServiceFactory.ps1") {
                    Write-Verbose "Initializing CoreServiceFactory at global level..."
                    [CoreServiceFactory]::Initialize($servicesPath)
                }
            }
            catch {
                Write-Warning "Failed to load $serviceFile : $($_.Exception.Message)"
                continue
            }
        }

        # Create and return services object with available factory methods at global level
        $global:services = [PSCustomObject]@{}

        # Helper function to safely get service at global level
        function Get-ServiceSafely {
            param($ServiceName, $ServiceGetter)
            try {
                $service = & $ServiceGetter
                if ($null -ne $service) {
                    # Replace hash table indexing with PSCustomObject property addition
                    $global:services | Add-Member -NotePropertyName $ServiceName -NotePropertyValue $service -Force
                    Write-Verbose "Successfully loaded service at global level: $ServiceName"
                }
                else {
                    Write-Warning "Service $ServiceName returned null"
                }
            }
            catch {
                Write-Warning "Failed to get service $ServiceName : $($_.Exception.Message)"
            }
        }

        # Load core services
        Get-ServiceSafely "Logger" { [CoreServiceFactory]::GetLoggingService() }
        Get-ServiceSafely "Configuration" { [CoreServiceFactory]::GetConfigurationService() }
        Get-ServiceSafely "CredentialService" { [CoreServiceFactory]::GetCredentialService() }
        Get-ServiceSafely "AuthService" { [CoreServiceFactory]::GetAuthenticationService() }
        Get-ServiceSafely "SharedToolCredentialService" { [CoreServiceFactory]::GetSharedToolCredentialService() }
        Get-ServiceSafely "APIService" { [CoreServiceFactory]::GetAPIService() }
        Get-ServiceSafely "StandardFileNaming" { [CoreServiceFactory]::GetStandardFileNamingService() }
        Get-ServiceSafely "OpenAPISchemaService" { [CoreServiceFactory]::GetOpenAPISchemaService() }

        # Load NSX-specific services
        Get-ServiceSafely "PolicyExportService" { [CoreServiceFactory]::GetNSXPolicyExportService() }
        Get-ServiceSafely "ConfigValidator" { [CoreServiceFactory]::GetNSXConfigValidator() }
        Get-ServiceSafely "ConfigManager" { [CoreServiceFactory]::GetNSXConfigManager() }
        Get-ServiceSafely "DifferentialConfigManager" { [CoreServiceFactory]::GetNSXDifferentialConfigManager() }
        Get-ServiceSafely "ConfigReset" { [CoreServiceFactory]::GetConfigurationResetService() }
        Get-ServiceSafely "DataObjectFilter" { [CoreServiceFactory]::GetDataObjectFilterService() }

        # Load additional services from factory
        Get-ServiceSafely "CSVDataParsing" { [CoreServiceFactory]::GetCSVDataParsingService() }
        Get-ServiceSafely "DataTransformationFactory" { [CoreServiceFactory]::GetDataTransformationFactory() }
        Get-ServiceSafely "NSXHierarchicalAPI" { [CoreServiceFactory]::GetNSXHierarchicalAPIService() }
        Get-ServiceSafely "NSXHierarchicalStructure" { [CoreServiceFactory]::GetNSXHierarchicalStructureService() }
        Get-ServiceSafely "NSXAPI" { [CoreServiceFactory]::GetNSXAPIService() }
        Get-ServiceSafely "DataTransformationPipeline" { [CoreServiceFactory]::GetDataTransformationPipeline() }

        # Load Phase 2 tool orchestration services
        Get-ServiceSafely "ToolOrchestrator" { [CoreServiceFactory]::GetToolOrchestrator() }

        # Load Phase 3 integration services
        Get-ServiceSafely "WorkflowDefinition" { [CoreServiceFactory]::GetWorkflowDefinitionService() }
        # Register workflow operations service under its canonical key
        Get-ServiceSafely "WorkflowOperationsService" { [CoreServiceFactory]::GetWorkflowOperationsService() }
        # Keep legacy alias for backward compatibility
        Get-ServiceSafely "WorkflowOperationsService" { [CoreServiceFactory]::GetWorkflowOperationsService() }

        Write-Information "Service Framework initialized successfully at global level." -InformationAction Continue
        return $global:services
    }
    catch {
        Write-Error "Failed to initialize Service Framework: $($_.Exception.Message)"
        Write-Error "Stack Trace: $($_.ScriptStackTrace)"
        return $null
    }
}

# Function to get initialized service factory from global scope
function Get-InitializedServiceFactory {
    try {
        # Test if CoreServiceFactory class is available at global level
        try {
            $global:testService = [CoreServiceFactory]::GetLoggingService()
            if ($null -eq $global:testService) {
                throw "CoreServiceFactory returned null service from global scope"
            }
        }
        catch {
            throw "CoreServiceFactory class not available at global level. Please run Initialize-ServiceFramework first."
        }

        # Initialize global services hashtable
        $global:services = [PSCustomObject]@{}

        # Helper function to safely get service at global level
        function Get-ServiceSafely {
            param($ServiceName, $ServiceGetter)
            try {
                $service = & $ServiceGetter
                if ($null -ne $service) {
                    # Replace hash table indexing with PSCustomObject property addition
                    $global:services | Add-Member -NotePropertyName $ServiceName -NotePropertyValue $service -Force
                    Write-Verbose "Successfully loaded service at global level: $ServiceName"
                }
                else {
                    Write-Warning "Service $ServiceName returned null"
                }
            }
            catch {
                Write-Warning "Failed to get service $ServiceName : $($_.Exception.Message)"
            }
        }

        # Load core services safely
        Get-ServiceSafely "Logging" { [CoreServiceFactory]::GetLoggingService() }
        Get-ServiceSafely "Configuration" { [CoreServiceFactory]::GetConfigurationService() }
        Get-ServiceSafely "Credential" { [CoreServiceFactory]::GetCredentialService() }
        Get-ServiceSafely "Authentication" { [CoreServiceFactory]::GetAuthenticationService() }
        Get-ServiceSafely "API" { [CoreServiceFactory]::GetAPIService() }
        Get-ServiceSafely "StandardFileNaming" { [CoreServiceFactory]::GetStandardFileNamingService() }

        # Load NSX-specific services
        Get-ServiceSafely "NSXConfigValidator" { [CoreServiceFactory]::GetNSXConfigValidator() }
        Get-ServiceSafely "NSXPolicyExport" { [CoreServiceFactory]::GetNSXPolicyExportService() }
        Get-ServiceSafely "NSXConfig" { [CoreServiceFactory]::GetNSXConfigManager() }
        Get-ServiceSafely "ConfigReset" { [CoreServiceFactory]::GetConfigurationResetService() }
        Get-ServiceSafely "DataObjectFilter" { [CoreServiceFactory]::GetDataObjectFilterService() }
        Get-ServiceSafely "DifferentialConfigManager" { [CoreServiceFactory]::GetNSXDifferentialConfigManager() }

        # Load services not in factory but available as classes (create directly)
        Get-ServiceSafely "CSVDataParsing" { [CoreServiceFactory]::GetCSVDataParsingService() }
        Get-ServiceSafely "DataTransformationFactory" { [CoreServiceFactory]::GetDataTransformationFactory() }
        Get-ServiceSafely "NSXHierarchicalAPI" { [CoreServiceFactory]::GetNSXHierarchicalAPIService() }
        Get-ServiceSafely "NSXHierarchicalStructure" { [CoreServiceFactory]::GetNSXHierarchicalStructureService() }
        Get-ServiceSafely "NSXAPI" { [CoreServiceFactory]::GetNSXAPIService() }
        Get-ServiceSafely "DataTransformationPipeline" { [CoreServiceFactory]::GetDataTransformationPipeline() }

        Write-Verbose "All services initialized successfully at global level"
        return $global:services
    }
    catch {
        Write-Error "Failed to get initialized services from global scope: $($_.Exception.Message)"
        return $null
    }
}

# Function to validate service initialization
function Test-ServiceInitialization {
    try {
        $services = Get-InitializedServiceFactory
        if ($null -eq $services) {
            return $false
        }

        # Test each service - replace hash table access with PSCustomObject property access
        $serviceProperties = ($services | Get-Member -MemberType NoteProperty).Name
        foreach ($serviceName in $serviceProperties) {
            if ($null -eq $services.$serviceName) {
                Write-Warning "Service '$serviceName' is null"
                return $false
            }
            Write-Verbose "Service '$serviceName' initialized successfully at global level"
        }

        return $true
    }
    catch {
        Write-Error "Service validation failed: $($_.Exception.Message)"
        return $false
    }
}

# Functions are ready for use after dot-sourcing at global level
# Call Initialize-ServiceFramework manually if needed for testing
# The main script handles CoreServiceFactory initialization directly at global level

# Export functions for external use only when running as module
if ($MyInvocation.MyCommand.Path -and $MyInvocation.MyCommand.Module) {
    Export-ModuleMember -Function Initialize-ServiceFramework, Get-InitializedServiceFactory, Test-ServiceInitialization
}
