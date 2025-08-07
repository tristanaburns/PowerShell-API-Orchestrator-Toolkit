# ConfigurationService.ps1
# Consolidated configuration management service following Single Responsibility Principle
# Handles all configuration-related operations with dependency injection

class ConfigurationService {
    hidden [string] $configurationPath
    hidden [object] $logger
    hidden [object] $configCache
    hidden [object] $defaultConfig

    # Constructor with dependency injection
    ConfigurationService([string] $configPath, [object] $loggingService) {
        $this.configurationPath = $configPath
        $this.logger = $loggingService
        $this.configCache = [PSCustomObject]@{}

        # initialise default configuration
        $this.defaultConfig = @{
            timeout                  = 30
            retryCount               = 3
            defaultSkipSSL           = $false
            logLevel                 = 'INFO'
            maxConcurrentConnections = 5
            connectionPooling        = $true
            validateSSL              = $true
            apiVersion               = 'v1'
            pageSize                 = 100
        }

        # Ensure configuration directory exists
        $this.EnsureConfigurationDirectory()
    }

    # Ensure configuration directory exists
    hidden [void] EnsureConfigurationDirectory() {
        try {
            if (-not (Test-Path $this.configurationPath)) {
                if ($this.logger) {
                    $this.logger.LogInfo("Creating configuration directory: $($this.configurationPath)", "Configuration")
                }
                New-Item -Path $this.configurationPath -ItemType Directory -Force | Out-Null
            }
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to create configuration directory")
            }
            throw "Failed to create or access configuration directory: $($this.configurationPath)"
        }
    }

    # Get configuration file path
    hidden [string] GetConfigFilePath([string] $configName) {
        return Join-Path $this.configurationPath "$configName.json"
    }

    # Load configuration with caching
    [object] LoadConfiguration([string] $configName) {
        try {
            # Check cache first - replace hash table indexing with PSCustomObject property access
            if ((Get-Member -InputObject $this.configCache -Name $configName -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
                return $this.configCache.$configName
            }

            $configFile = $this.GetConfigFilePath($configName)

            if (-not (Test-Path $configFile)) {
                if ($this.logger) {
                    $this.logger.LogInfo("Configuration file not found, creating default: $configFile", "Configuration")
                }
                $this.SaveConfiguration($configName, $this.defaultConfig)
                return $this.defaultConfig.Clone()
            }

            if ($this.logger) {
                $this.logger.LogDebug("Loading configuration from: $configFile", "Configuration")
            }

            $jsonContent = Get-Content -Path $configFile -Raw | ConvertFrom-Json
            $config = [PSCustomObject]@{}

            # Convert PSCustomObject to PSCustomObject with proper property access
            $jsonContent.PSObject.Properties | ForEach-Object {
                $config | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value -Force
            }

            # Merge with defaults to ensure all keys exist - replace hash table iteration with PSCustomObject properties
            $mergedConfig = $this.defaultConfig.Clone()
            $configProperties = ($config | Get-Member -MemberType NoteProperty).Name
            foreach ($key in $configProperties) {
                $mergedConfig | Add-Member -NotePropertyName $key -NotePropertyValue $config.$key -Force
            }

            # Cache the configuration - replace hash table assignment with PSCustomObject property addition
            $this.configCache | Add-Member -NotePropertyName $configName -NotePropertyValue $mergedConfig -Force

            return $mergedConfig
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to load configuration: $configName")
            }
            return $this.defaultConfig.Clone()
        }
    }

    # Save configuration
    [bool] SaveConfiguration([string] $configName, [object] $config) {
        try {
            $configFile = $this.GetConfigFilePath($configName)

            if ($this.logger) {
                $this.logger.LogInfo("Saving configuration to: $configFile", "Configuration")
            }

            $config | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath $configFile -Encoding UTF8 -Force

            # Update cache - replace hash table assignment with PSCustomObject property addition
            $this.configCache | Add-Member -NotePropertyName $configName -NotePropertyValue $config.Clone() -Force

            return $true
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to save configuration: $configName")
            }
            return $false
        }
    }

    # Get specific configuration value with default fallback
    [object] GetConfigValue([string] $configName, [string] $key, [object] $defaultValue = $null) {
        $config = $this.LoadConfiguration($configName)

        # Replace hash table indexing with PSCustomObject property access
        if ((Get-Member -InputObject $config -Name $key -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
            return $config.$key
        }

        # Replace hash table indexing with PSCustomObject property access for default config
        if ((Get-Member -InputObject $this.defaultConfig -Name $key -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
            return $this.defaultConfig.$key
        }

        return $defaultValue
    }

    # Set specific configuration value
    [bool] SetConfigValue([string] $configName, [string] $key, [object] $value) {
        try {
            $config = $this.LoadConfiguration($configName)
            # Replace hash table assignment with PSCustomObject property addition
            $config | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
            return $this.SaveConfiguration($configName, $config)
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to set configuration value: $configName.$key")
            }
            return $false
        }
    }

    # Get default configuration
    [object] GetDefaultConfiguration() {
        return $this.defaultConfig.Clone()
    }

    # Reset configuration to defaults
    [bool] ResetConfiguration([string] $configName) {
        return $this.SaveConfiguration($configName, $this.defaultConfig.Clone())
    }

    # List available configurations
    [string[]] ListConfigurations() {
        try {
            $configFiles = Get-ChildItem -Path $this.configurationPath -Filter "*.json" -ErrorAction SilentlyContinue
            return $configFiles | ForEach-Object { $_.BaseName }
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to list configurations")
            }
            return @()
        }
    }

    # Clear configuration cache
    [void] ClearCache() {
        $this.configCache.Clear()
        if ($this.logger) {
            $this.logger.LogInfo("Cleared configuration cache", "Configuration")
        }
    }

    # ============================================
    # NSX-T SPECIFIC: Return consolidated NSX config
    # ============================================

    [object] GetNSXConfiguration() {
        <#
            .SYNOPSIS
                Returns the consolidated NSX-T configuration used by higher-level
                operational services (e.g. WorkflowOperationsService).

            .DESCRIPTION
                Attempts to load `nsx-automation-config.json` from the main config
                directory (created via EnsureConfigurationDirectory).  If the file
                is missing or malformed, a minimal default structure is returned
                so that dependent services can continue operating.

                Expected keys by callers:
                   NSXManagers    hashtable of known manager definitions
                   SkipSSLCheck   boolean flag indicating global SSL bypass
        #>

        try {
            $filePath = $this.GetConfigFilePath('nsx-automation-config')

            if (Test-Path $filePath) {
                # PowerShell 7+ supports -AsHashtable for native hashtable output
                $json = Get-Content -Path $filePath -Raw | ConvertFrom-Json -AsHashtable

                # Normalise expected top-level keys
                $nsxManagers = if ($json['NSXManagers']) { $json['NSXManagers'] } else { [PSCustomObject]@{} }
                $skipSSL = $false
                if ($json['Security'] -and $json['Security']['RequireSSL']) {
                    $skipSSL = -not $json['Security']['RequireSSL']
                }

                return @{
                    NSXManagers  = $nsxManagers
                    SkipSSLCheck = $skipSSL
                }
            }
            else {
                if ($this.logger) { $this.logger.LogWarning("nsx-automation-config.json not found, using defaults", "Configuration") }
            }
        }
        catch {
            if ($this.logger) { $this.logger.LogException($_.Exception, "Failed to parse nsx-automation-config.json") }
        }

        # Fallback  minimal structure
        return @{
            NSXManagers  = [PSCustomObject]@{}
            SkipSSLCheck = $this.GetConfigValue('nsx-config', 'defaultSkipSSL', $false)
        }
    }

    # Validate configuration structure
    [bool] ValidateConfiguration([object] $config) {
        $requiredKeys = @('timeout', 'retryCount', 'defaultSkipSSL')

        foreach ($key in $requiredKeys) {
            # Replace hash table indexing with PSCustomObject property access
            if (-not (Get-Member -InputObject $config -Name $key -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
                if ($this.logger) {
                    $this.logger.LogWarning("Configuration missing required key: $key", "Configuration")
                }
                return $false
            }
        }

        return $true
    }

    # ============================================
    # SSL BYPASS FUNCTIONALITY
    # ============================================

    # Set trust all certificates (SSL bypass)
    [void] SetTrustAllCertificates([bool] $trustAll) {
        if ($this.logger) {
            $this.logger.LogInfo("SetTrustAllCertificates called with: $trustAll", "Configuration")
        }

        if ($trustAll) {
            # CoreSSLManager is already initialized globally by service framework
            # No additional action needed - SSL bypass is already active
            if ($this.logger) {
                $this.logger.LogInfo("SSL bypass already active via CoreSSLManager global initialization", "Configuration")
            }
        }
        else {
            # Note: Restoring SSL validation is not typically needed in NSX toolkit workflows
            # Most NSX environments use self-signed certificates that require bypass
            if ($this.logger) {
                $this.logger.LogWarning("SSL validation restore requested but not implemented - CoreSSLManager handles global state", "Configuration")
            }
        }
    }
}
