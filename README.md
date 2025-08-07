# PowerShell API Orchestrator Toolkit

```powershell
# Load the core services
. ".\src\services\InitServiceFramework.ps1"

# Test connectivity
.\tools\APIConnectionTest.ps1 -APIEndpoint "your-api-endpoint.domain.com"

# Manage credentials
.\tools\ManageAPICredentials.ps1

# Sync configurations between managers
.\tools\APIConfigSyncTool.ps1 -SourceManager "source.domain.com" -TargetManager "target.domain.com"

# Migrate configurations using Hierarchical API
.\tools\APIMigrationTool.ps1 -SourceManager "source.domain.com" -TargetManager "target.domain.com"
```

## 📁 Directory Structure

```
powershell-api-orchestrator-toolkit/
├── src/                        # Core source code
│   ├── services/              # Business logic services
│   ├── interfaces/            # Service contracts
│   └── models/                # Data models
├── tools/                     # End-user tools and utilities
│   ├── APIConfigSyncTool.ps1     # Configuration synchronization
│   ├── APIMigrationTool.ps1      # Hierarchical API migration
│   ├── APIConnectionTest.ps1      # Connectivity testing
│   ├── ManageAPICredentials.ps1  # Credential management
│   └── DiagnoseHTTPSConnection.ps1 # HTTPS troubleshooting
├── config/                    # Configuration files
│   ├── api-config.json           # Base configuration template
│   ├── api-automation-config.json # Enhanced automation configuration
│   ├── group-membership-config.json # Group membership operations
│   ├── credentials/              # Encrypted credential storage (.cred files)
│   ├── test_configs/             # Test environment configurations
│   └── diffs/                  # Diffs generated configs
├── tests/                     # Test files
├── docs/                      # Documentation
├── logs/                      # Diffs logs
└── README.md                  # This file
```

## Available Tools

### Core Production Tools

1. **APIConfigSyncTool.ps1** - Configuration synchronization between API endpoints
   - Compare configurations
   - Selective patching
   - Rollback capabilities
   - Current user authentication support

2. **APIMigrationTool.ps1** - Bulk configuration migration using Universal API
   - Export/import configurations
   - Multiple authentication methods
   - Non-interactive mode for automation
   - logging

3. **APIConnectionTest.ps1** - API endpoint connectivity testing
   - Multiple authentication methods
   - SSL certificate validation testing
   - Network connectivity verification

4. **ManageAPICredentials.ps1** - Credential management interface
   - Encrypted credential storage (Windows DPAPI)
   - View and manage stored credentials
   - Clear expired credentials

5. **DiagnoseHTTPSConnection.ps1** - HTTPS troubleshooting tool
   - Test various .NET connection methods
   - SSL/TLS protocol testing
   - Certificate validation testing

6. **SimpleAPICredentialTest.ps1** - Real API endpoint testing and credential setup
   - Setup and test credentials for real API endpoints
   - Connection validation
   - Configuration inventory

7. **SetupAPICredentials.ps1** - Enhanced credential setup wizard
   - Guided credential configuration
   - Multiple API endpoint support
   - Validation and testing

8. **QuickValidation.ps1** - Quick environment validation
   - Validate framework configuration
   - Test service loading
   - Environment health checks

9. **VerifyAPIConfig.ps1** - Configuration verification tool
   - Verify API endpoint configurations
   - Compare configurations between managers
   - Generate configuration reports

### Core Services Architecture

- **AuthenticationService** - Universal API authentication and session management
- **CoreAPIService** - Low-level REST API operations
- **EnhancedLoggingService** - Structured logging with multiple outputs
- **ConfigurationService** - Configuration file management
- **CredentialService** - Secure credential storage and retrieval

## Authentication Methods

- **Windows/AD Integration** - Use current user credentials
- **Basic Authentication** - Username/password
- **Cached Credentials** - Encrypted storage using Windows DPAPI
- **Non-Interactive Mode** - For scheduled tasks and automation

### Testing Requirements

- **Lab Environment**: All testing MUST use `lab-api-01.test.lab` and `lab-api-02.test.lab` as API endpoints.
