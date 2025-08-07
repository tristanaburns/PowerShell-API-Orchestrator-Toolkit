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

## Directory Structure

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
│   ├── api-automation-config.json # automation configuration
│   ├── group-membership-config.json # Group membership operations
│   ├── credentials/              # Encrypted credential storage (.cred files)
│   ├── test_configs/             # Test environment configurations
│   └── diffs/                  # Diffs generated configs
├── tests/                     # Test files
├── docs/                      # Documentation
├── logs/                      # Diffs logs
└── README.md                  # This file
```

### Core Services Architecture

- **AuthenticationService** - API authentication and session management
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
