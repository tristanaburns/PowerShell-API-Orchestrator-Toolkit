# IConfigurationService.ps1
# Interface for configuration management service

<#
.SYNOPSIS
    Interface for configuration management services.

.DESCRIPTION
    Defines the contract for configuration management operations, providing
    abstraction for configuration loading, saving, validation, and manipulation.

    SOLID Principles Applied:
    - Single Responsibility: Only handles configuration management operations
    - Interface Segregation: contract for configuration services
    - Dependency Inversion: Abstract interface for concrete implementations
#>

# Configuration Service Interface Contract
<#
    Configuration Service Implementation Contract:

    Implementations should provide the following methods:

    [object] LoadConfiguration([string]$configPath)
        - Loads configuration from specified file path

    [void] SaveConfiguration([string]$configPath, [object]$config)
        - Saves configuration to specified file path

    [object] GetEnvironmentConfig([string]$environment)
        - Gets configuration for specific environment

    [void] SetEnvironmentConfig([string]$environment, [object]$config)
        - Sets configuration for specific environment

    [bool] ValidateConfiguration([object]$config)
        - Validates configuration object structure and values

    [array] GetConfigurationErrors([object]$config)
        - Returns array of validation errors for configuration

    [void] EncryptSensitiveValues([object]$config)
        - Encrypts sensitive configuration values

    [void] DecryptSensitiveValues([object]$config)
        - Decrypts sensitive configuration values

    [object] MergeConfigurations([object]$baseConfig, [object]$overrideConfig)
        - Merges base configuration with override configuration

    [object] SubstituteVariables([object]$config, [object]$variables)
        - Substitutes template variables in configuration with actual values
#>
