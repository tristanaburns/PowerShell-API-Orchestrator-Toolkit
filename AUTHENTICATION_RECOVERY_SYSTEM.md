# Universal API Orchestrator - Authentication Failure Recovery System

## Overview

The Authentication Failure Recovery System is a comprehensive solution that automatically handles authentication failures when making REST API calls. It provides intelligent detection, interactive recovery, secure storage, and retry management to ensure robust API interactions while preventing account lockouts.

## Key Features

### 🔍 **Authentication Failure Detection**
- Automatically detects 401 (Unauthorized) and 403 (Forbidden) HTTP responses
- Analyzes response headers and content for authentication error indicators
- Recognizes authentication keywords in error messages
- Provides detailed failure reason reporting

### 🤖 **Automatic Authentication Type Detection** 
- Analyzes WWW-Authenticate headers to determine required auth methods
- Examines response content for authentication hints (API keys, tokens, etc.)
- Uses URL patterns to identify common API authentication requirements
- Supports detection confidence levels and multiple detection methods

### 💬 **Interactive Authentication Prompts**
- User-friendly interactive prompts when authentication is required
- Guided selection of authentication methods based on detection results
- Support for multiple authentication types:
  - **API Key** authentication with customizable header names
  - **Bearer Token** authentication
  - **Basic Authentication** (Username/Password)
  - **Custom Headers** for proprietary authentication schemes

### 🔒 **Secure Credential Storage**
- Integrates with existing CredentialService for encrypted credential storage
- Saves authentication details for future automatic use
- Supports metadata storage for authentication context
- User choice for credential saving (opt-in)

### 🔄 **Intelligent Retry Mechanism**
- Maximum 2 retry attempts to prevent account lockouts
- Per-URL retry tracking to avoid cross-contamination
- Automatic retry reset after successful authentication
- Intelligent header updates between retry attempts

### 🛡️ **Account Lockout Prevention**
- Enforces maximum retry limits per API endpoint
- Tracks retry attempts across sessions
- Provides clear lockout protection messaging
- Manual retry reset functionality

## Architecture

### Core Components

#### 1. AuthenticationFailureRecoveryService
The main service class that orchestrates the entire recovery process:
- `HandleAuthenticationFailure()` - Main recovery orchestration method
- `DetectAuthenticationFailure()` - Failure detection logic
- `DetectAuthenticationTypeFromResponse()` - Authentication type analysis
- `PromptForAuthentication()` - Interactive user prompts
- `SaveAuthenticationDetails()` - Secure credential storage
- `LoadSavedAuthDetails()` - Retrieve saved credentials

#### 2. Enhanced GenericAPIService
Updated to integrate authentication recovery:
- `ExecuteRequestWithAuthRecovery()` - Main request method with recovery
- Automatic loading of saved credentials
- Retry logic with authentication recovery
- Success/failure tracking and reporting

#### 3. Integration Points
- **CredentialService**: For encrypted credential storage
- **LoggingService**: For comprehensive operation logging
- **ConfigurationService**: For service configuration
- **DynamicAPIOrchestrator**: Enhanced error reporting

## Usage Examples

### Basic API Call with Automatic Recovery

```powershell
# Initialize services
$services = Initialize-DynamicServices -LogLevel "Info"
$apiService = New-DynamicAPIService -Services $services -BaseUrl "https://api.github.com" -AuthType "None"

# Make API call - recovery will trigger automatically on auth failure
try {
    $result = $apiService.Get("/user")
    Write-Host "Success: $($result.login)"
}
catch {
    Write-Host "Failed: $($_.Exception.Message)"
}
```

### Manual Authentication Recovery Testing

```powershell
# Test the recovery system with mock failure
$recoveryResult = $apiService.TestAuthenticationRecovery("/user")

if ($recoveryResult.Success) {
    Write-Host "Recovery system working: $($recoveryResult.AuthType)"
}
```

### Using Saved Credentials

```powershell
# Credentials saved during interactive prompt are automatically loaded
$savedAuth = $apiService.authRecoveryService.LoadSavedAuthDetails("https://api.github.com")

if ($savedAuth -and $savedAuth.Success) {
    Write-Host "Found saved credentials for GitHub API"
}
```

## Interactive Flow Example

When authentication fails, the user sees:

```
=== AUTHENTICATION REQUIRED ===
API Endpoint: https://api.github.com
Detected Type: Bearer (Confidence: High)

Authentication Hints:
  - GitHub API detected - typically uses Bearer tokens
  - Bearer token authentication suggested (content analysis)

Please select authentication method:
1. API Key
2. Bearer Token
3. Basic Authentication (Username/Password)
4. Custom Headers

Enter choice (1-4) [default based on detection]: 2
Enter Bearer Token: **********************
Save credentials securely for future use? (y/N): y

[SUCCESS] Authentication details collected successfully
[SUCCESS] Bearer token authentication configured
```

## Configuration

### Service Initialization

```powershell
# The recovery service is automatically initialized with GenericAPIService
$apiService = [GenericAPIService]::new($loggingService, $authService, $configService)

# Recovery service is available at:
$recoveryService = $apiService.authRecoveryService
```

### Retry Limits

The system enforces a maximum of **2 retry attempts** per API endpoint to prevent account lockouts:

```powershell
# Default maximum retries (can be configured)
$maxRetries = 2

# Reset retry attempts for specific URL
$recoveryService.ResetRetryAttempts("https://api.example.com")
```

## Authentication Types Supported

### 1. API Key Authentication
```powershell
# Prompts for API key and header name
# Example result:
Headers["X-API-Key"] = "your-api-key-here"
```

### 2. Bearer Token Authentication  
```powershell
# Prompts for bearer token
# Example result:
Headers["Authorization"] = "Bearer your-token-here"
```

### 3. Basic Authentication
```powershell
# Prompts for username and password
# Example result:
Headers["Authorization"] = "Basic dXNlcjpwYXNzd29yZA=="
```

### 4. Custom Headers
```powershell
# Prompts for custom header key-value pairs
# Example result:
Headers["Custom-Auth"] = "custom-value"
Headers["X-Custom-Token"] = "token-value"
```

## Security Features

### Encrypted Storage
- All credentials are encrypted using Windows DPAPI
- Stored in secure credential files with .cred extension
- Metadata stored separately with authentication context

### Account Protection
- Maximum retry limits prevent brute force attempts
- Per-URL tracking prevents cross-contamination
- Clear lockout messaging to users
- Manual override capabilities for legitimate retries

### Secure Handling
- Secure strings used for sensitive data
- Automatic credential cleanup options
- No plain-text credential logging
- Memory-safe credential handling

## Testing

### Automated Test Suite

Run comprehensive tests:
```powershell
.\tools\TestAuthenticationRecovery.ps1
```

### Interactive Testing
```powershell
# Test with real API endpoints
.\tools\TestAuthenticationRecovery.ps1 -InteractiveTest

# Show capabilities demo
.\tools\TestAuthenticationRecovery.ps1 -ShowDemo
```

### Test Coverage
- ✅ Authentication failure detection (401/403 responses)
- ✅ Authentication type auto-detection from responses
- ✅ Retry mechanism and lockout prevention
- ✅ Secure credential storage and retrieval
- ✅ Interactive prompt system
- ✅ Integration with GenericAPIService

## Integration with Existing Tools

### DynamicAPIOrchestrator
Enhanced error reporting for authentication failures:
```powershell
.\tools\DynamicAPIOrchestrator.ps1 -BaseUrl "https://api.github.com" -Endpoint "/user" -Get
# Will automatically trigger recovery on auth failure
```

### Universal API Client
All existing tools automatically benefit from authentication recovery:
```powershell
.\tools\UniversalAPIClient.ps1 -BaseUrl "https://api.example.com" -Endpoint "/protected"
# Recovery system activates automatically on 401/403 responses
```

## Troubleshooting

### Common Issues

1. **"Maximum retry attempts exceeded"**
   - Indicates lockout protection activated
   - Reset with: `$recoveryService.ResetRetryAttempts($url)`

2. **"Authentication recovery service not available"**  
   - Service failed to initialize
   - Check logs for initialization errors

3. **Credentials not saving**
   - Verify credential directory permissions
   - Check available disk space

### Debug Information

Enable detailed logging:
```powershell
$loggingService.SetLogLevel("Debug")
# Shows detailed authentication recovery flow
```

## Future Enhancements

### Planned Features
- OAuth 2.0 flow support
- JWT token validation and refresh
- Multi-factor authentication support
- Certificate-based authentication
- Automatic token refresh workflows

### API Extensions
- REST API for remote authentication management
- Bulk credential management operations
- Authentication policy enforcement
- Audit trail and compliance reporting

## Conclusion

The Authentication Failure Recovery System provides a comprehensive, user-friendly, and secure solution for handling authentication challenges in API interactions. It seamlessly integrates with the existing Universal API Orchestrator infrastructure while providing robust protection against account lockouts and ensuring a smooth user experience.

The system follows security best practices, implements intelligent automation, and provides clear feedback to users, making it an essential component for production API orchestration workflows.