# NSX-T PowerShell Automation Toolkit

```powershell
# Load the core services
. ".\src\services\InitServiceFramework.ps1"

# Test connectivity
.\tools\NSXConnectionTest.ps1 -NSXManager "your-nsx-manager.domain.com"

# Manage credentials
.\tools\ManageNSXCredentials.ps1

# Sync configurations between managers
.\tools\NSXConfigSyncTool.ps1 -SourceManager "source.domain.com" -TargetManager "target.domain.com"

# Migrate configurations using Hierarchical API
.\tools\NSXMigrationTool.ps1 -SourceManager "source.domain.com" -TargetManager "target.domain.com"
```

## 📁 Directory Structure

```
nsx-powershell-toolkit/
├── src/                        # Core source code
│   ├── services/              # Business logic services
│   ├── interfaces/            # Service contracts
│   └── models/                # Data models
├── tools/                     # End-user tools and utilities
│   ├── NSXConfigSyncTool.ps1     # Configuration synchronization
│   ├── NSXMigrationTool.ps1      # Hierarchical API migration
│   ├── NSXConnectionTest.ps1      # Connectivity testing
│   ├── ManageNSXCredentials.ps1  # Credential management
│   └── DiagnoseHTTPSConnection.ps1 # HTTPS troubleshooting
├── config/                    # Configuration files
│   ├── nsx-config.json           # Base configuration template
│   ├── nsx-automation-config.json # Enhanced automation configuration
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

1. **NSXConfigSyncTool.ps1** - Configuration synchronization between NSX managers
   - Compare configurations
   - Selective patching
   - Rollback capabilities
   - Current user authentication support

2. **NSXMigrationTool.ps1** - Bulk configuration migration using Hierarchical API
   - Export/import configurations
   - Multiple authentication methods
   - Non-interactive mode for automation
   - logging

3. **NSXConnectionTest.ps1** - NSX manager connectivity testing
   - Multiple authentication methods
   - SSL certificate validation testing
   - Network connectivity verification

4. **ManageNSXCredentials.ps1** - Credential management interface
   - Encrypted credential storage (Windows DPAPI)
   - View and manage stored credentials
   - Clear expired credentials

5. **DiagnoseHTTPSConnection.ps1** - HTTPS troubleshooting tool
   - Test various .NET connection methods
   - SSL/TLS protocol testing
   - Certificate validation testing

6. **SimpleNSXCredentialTest.ps1** - Real NSX manager testing and credential setup
   - Setup and test credentials for real NSX managers
   - Connection validation
   - Configuration inventory

7. **SetupNSXCredentials.ps1** - Enhanced credential setup wizard
   - Guided credential configuration
   - Multiple NSX manager support
   - Validation and testing

8. **QuickValidation.ps1** - Quick environment validation
   - Validate framework configuration
   - Test service loading
   - Environment health checks

9. **VerifyNSXConfig.ps1** - Configuration verification tool
   - Verify NSX manager configurations
   - Compare configurations between managers
   - Generate configuration reports

### Core Services Architecture

- **AuthenticationService** - NSX-T authentication and session management
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

- **Lab Environment**: All testing MUST use `lab-nsxlm-01.test.lab` and `lab-nsxlm-02.test.lab` as NSX managers.
