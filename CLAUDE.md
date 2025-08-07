# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Framework Initialization
```powershell
# Load the core services framework
. ".\src\services\InitServiceFramework.ps1"
```

### Code Quality and Linting
```powershell
# Run PSScriptAnalyzer with auto-fix (recommended)
.\src\utilities\PSScriptAnalyzerUtility.ps1 -Path "." -AutoFix -Backup

# Analyze specific file without auto-fix
.\src\utilities\PSScriptAnalyzerUtility.ps1 -Path ".\src\services\ConfigurationService.ps1" -Severity Error

# Analyze entire services directory with JSON output
.\src\utilities\PSScriptAnalyzerUtility.ps1 -Path ".\src\services" -Recurse -OutputFormat JSON -OutputPath ".\logs\analysis.json"
```

### Testing Commands
```powershell
# Test API endpoint connectivity
.\tools\APIConnectionTest.ps1 -APIEndpoint "lab-api-01.test.lab"

# Run connection diagnostics
.\tools\APIConnectionDiagnostics.ps1

# Verify API configuration
.\tools\VerifyAPIConfiguration.ps1

# Test service framework availability
Test-ServiceFrameworkAvailability

# Test core service availability
Test-CoreServiceAvailability
```

## Architecture Overview

### Service Layer Architecture
The codebase follows a layered service architecture with dependency injection through the Factory Pattern:

- **Interfaces Layer** (`src/interfaces/`): Service contracts (IAuthenticationService, IConfigurationService, etc.)
- **Services Layer** (`src/services/`): Core business logic implementations
- **Models Layer** (`src/models/`): Data models and structures
- **Tools Layer** (`tools/`): End-user CLI tools and utilities

### Dependency Loading Order
Services must be loaded in specific dependency order (managed by InitServiceFramework.ps1):
1. CoreSSLManager.ps1 (no dependencies)
2. LoggingService.ps1 (no dependencies)
3. ConfigurationService.ps1 (depends on LoggingService)
4. CredentialService.ps1 (depends on LoggingService)
5. CoreAuthenticationService.ps1 (depends on multiple core services)
6. CoreAPIService.ps1 (depends on LoggingService, CoreAuthenticationService)
7. UniversalAPIService.ps1 (extends CoreAPIService)
8. Higher-level services (depend on foundation services)

### Service Factory Pattern
All services are managed through CoreServiceFactory using singleton pattern:
- Services are instantiated once and reused
- Factory handles dependency injection
- Uses PSCustomObject instead of hashtables for better PowerShell integration

### Configuration Management
- **Base Configuration**: `config/api-config.json`
- **Automation Configuration**: `config/api-automation-config.json`
- **Test Endpoints**: `config/api-test-endpoints.json`
- **Encrypted Credentials**: Stored in `config/credentials/` using Windows DPAPI

## Key Development Patterns

### Authentication Methods
The toolkit supports multiple authentication patterns:
- Windows/AD Integration (current user credentials)
- Basic Authentication (username/password)
- Cached Credentials (encrypted Windows DPAPI storage)
- Non-Interactive Mode (for automation)

### Error Handling and Logging
- All services integrate with LoggingService
- Structured logging with multiple output formats
- Error handling follows try-catch-log pattern
- Log files stored in `logs/` directory

### SSL/TLS Management
CoreSSLManager handles certificate validation and SSL protocol management across all HTTPS connections.

## Testing Requirements

### Lab Environment
All testing MUST use designated test API endpoints:
- Primary: `lab-api-01.test.lab`
- Secondary: `lab-api-02.test.lab`

### Code Quality Standards
- All code must pass PSScriptAnalyzer analysis
- Auto-fix is enabled by default for common violations
- Backups are automatically created before modifications
- Custom rules exclude toolkit-specific requirements (Write-Host usage, etc.)

## Tool Usage Patterns

### Configuration Synchronization
```powershell
# Sync configurations between API endpoints
.\tools\APIConfigSync.ps1 -SourceEndpoint "source.domain.com" -TargetEndpoint "target.domain.com"
```

### Credential Management
```powershell
# Manage encrypted credentials
.\tools\APICredentialManager.ps1

# Setup new credentials
.\tools\SetupAPICredentials.ps1
```

### Export/Import Operations
```powershell
# Export API policy configuration
.\tools\APIPolicyConfigExport.ps1

# Apply configuration changes
.\tools\ApplyAPIConfig.ps1

# Apply differential configuration
.\tools\ApplyAPIConfigDifferential.ps1
```