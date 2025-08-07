# CoreAuthenticationService.ps1
# Consolidated authentication service following SOLID principles
# Single responsibility for all authentication operations with dependency injection

class CoreAuthenticationService {
    hidden [object] $logger
    hidden [object] $credentialService
    hidden [object] $configurationService
    hidden [object] $certificateCallbacks = [PSCustomObject]@{}

    # Constructor with dependency injection
    CoreAuthenticationService([object] $loggingService, [object] $credentialService, [object] $configurationService) {
        $this.logger = $loggingService
        $this.credentialService = $credentialService
        $this.configurationService = $configurationService
        $this.logger.LogInfo("CoreAuthenticationService initialised with dependency injection", "Authentication")

        # Load config and conditionally apply SSL bypass
        $config = $this.configurationService.LoadConfiguration("nsx-config")
        $skipSSL = $false
        # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
        if ((Get-Member -InputObject $config -Name "defaultSkipSSL" -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $config.defaultSkipSSL -eq $true) {
            $skipSSL = $true
        }
        # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
        if ((Get-Member -InputObject $config -Name "validateSSL" -MemberType NoteProperty -ErrorAction SilentlyContinue) -and $config.validateSSL -eq $false) {
            $skipSSL = $true
        }
        if ($skipSSL) {
            $this.logger.LogInfo("Global SSL bypass enabled by config (defaultSkipSSL or validateSSL)", "Authentication")
            $this.SetupGlobalSSLBypass()
        }
        else {
            $this.logger.LogInfo("Global SSL bypass NOT enabled by config (defaultSkipSSL/validateSSL)", "Authentication")
        }
    }

    # Primary authentication method with auto-detection
    [PSCredential] GetCredential([string] $nsxManager, [string] $username = $null, [bool] $useCurrentUser = $false, [bool] $forceNew = $false) {
        try {
            $this.logger.LogInfo("Getting credentials for NSX Manager: $nsxManager", "Authentication")

            # Case 1: Use current user context (Windows Authentication)
            if ($useCurrentUser) {
                $this.logger.LogInfo("Using current user context for authentication", "Authentication")
                # Create secure string without plaintext conversion for current user context
                $secureString = New-Object System.Security.SecureString
                $credential = New-Object System.Management.Automation.PSCredential("CURRENT_USER", $secureString)

                # Validate current user credentials
                if ($this.ValidateCurrentUserCredentials($nsxManager, $credential)) {
                    $this.logger.LogInfo("Current user credentials validated successfully", "Authentication")
                    return $credential
                }
                else {
                    $this.logger.LogWarning("Current user credentials validation failed", "Authentication")
                    throw "Current user credentials are not valid for $nsxManager"
                }
            }

            # Case 2: Force new credentials (skip stored, prompt for new)
            if ($forceNew) {
                if (-not $username) {
                    try {
                        $username = Read-Host "Enter username for $nsxManager"
                    }
                    catch {
                        $this.logger.LogError("ForceNew: No username provided and cannot prompt for new credentials (non-interactive mode).", "Authentication")
                        throw "ForceNewCredentials specified but no username provided and cannot prompt for new credentials (non-interactive mode)."
                    }
                }
                $this.logger.LogInfo("ForceNew: Prompting for new credentials for $username@$nsxManager", "Authentication")
                $password = Read-Host "Enter password for $username@$nsxManager" -AsSecureString
                $credential = New-Object System.Management.Automation.PSCredential($username, $password)
                if ($this.ValidateBasicCredentials($nsxManager, $credential)) {
                    $this.logger.LogInfo("ForceNew: New credentials validated successfully", "Authentication")
                    # Save new credentials
                    $this.credentialService.SaveCredentials($nsxManager, $credential) | Out-Null
                    return $credential
                }
                else {
                    $this.logger.LogWarning("ForceNew: New credentials validation failed", "Authentication")
                    try {
                        $saveAnyway = Read-Host "Validation failed. Save credentials anyway? (y/n)"
                        if ($saveAnyway -match '^(y|yes)$') {
                            $this.logger.LogInfo("ForceNew: User chose to save credentials despite failed validation.", "Authentication")
                            $this.credentialService.SaveCredentials($nsxManager, $credential) | Out-Null
                            return $credential
                        }
                        else {
                            throw "New credentials are not valid for $nsxManager"
                        }
                    }
                    catch {
                        throw "New credentials are not valid for $nsxManager"
                    }
                }
            }

            # Case 3: Check for stored credentials (if not forceNew)
            if ($this.credentialService.HasCredentials($nsxManager)) {
                $this.logger.LogInfo("Found stored credentials for $nsxManager", "Authentication")
                $credential = $this.credentialService.LoadCredentials($nsxManager)
                $this.logger.LogInfo("Using stored encrypted credentials (validation skipped)", "Authentication")
                return $credential
            }

            # Case 4: Interactive credential collection
            if ($username) {
                $this.logger.LogInfo("Interactive credential collection with username: $username", "Authentication")
                $password = Read-Host "Enter password for $username@$nsxManager" -AsSecureString
                $credential = New-Object System.Management.Automation.PSCredential($username, $password)
                if ($this.ValidateBasicCredentials($nsxManager, $credential)) {
                    $this.logger.LogInfo("Interactive credentials validated successfully", "Authentication")
                    return $credential
                }
                else {
                    $this.logger.LogWarning("Interactive credentials validation failed", "Authentication")
                    throw "Interactive credentials are not valid for $nsxManager"
                }
            }

            # Case 5: No credentials available
            throw "No credentials available for $nsxManager. Use -UseCurrentUser or provide username."

        }
        catch {
            $this.logger.LogError("Failed to get credentials: $($_.Exception.Message)", "Authentication")
            throw
        }
    }

    # Validate current user credentials using Windows Authentication
    hidden [bool] ValidateCurrentUserCredentials([string] $nsxManager, [PSCredential] $credential) {
        $config = $this.configurationService.LoadConfiguration("nsx-config")
        $testEndpoints = @(
            "https://$nsxManager/api/v1/node",
            "https://$nsxManager/api/v1/cluster/status"
        )

        foreach ($uri in $testEndpoints) {
            try {
                $this.logger.LogInfo("Testing current user credentials against: $uri", "Authentication")

                # Create REST parameters with SSL bypass
                $restParams = [PSCustomObject]@{
                    Uri                   = $uri
                    Method                = 'GET'
                    UseDefaultCredentials = $true
                    TimeoutSec            = 30
                }

                $response = Invoke-RestMethod @restParams
                if ($response) {
                    $this.logger.LogInfo("Current user credentials validated successfully", "Authentication")
                    return $true
                }
            }
            catch {
                $this.logger.LogWarning("Current user validation failed for $uri`: $($_.Exception.Message)", "Authentication")
            }
        }

        return $false
    }

    # Validate basic authentication credentials
    hidden [bool] ValidateBasicCredentials([string] $nsxManager, [PSCredential] $credential) {
        $config = $this.configurationService.LoadConfiguration("nsx-config")

        $testEndpoints = @(
            "https://$nsxManager/api/v1/node",
            "https://$nsxManager/api/v1/cluster/status"
        )

        foreach ($uri in $testEndpoints) {
            try {
                $this.logger.LogInfo("Testing basic credentials against: $uri", "Authentication")

                # Create REST parameters with SSL bypass
                $restParams = [PSCustomObject]@{
                    Uri        = $uri
                    Method     = 'GET'
                    Credential = $credential
                    TimeoutSec = 30
                }

                $response = Invoke-RestMethod @restParams
                if ($response) {
                    $this.logger.LogInfo("Basic credentials validated successfully", "Authentication")
                    return $true
                }
            }
            catch {
                $this.logger.LogWarning("Basic validation failed for $uri`: $($_.Exception.Message)", "Authentication")
            }
        }

        return $false
    }

    # Test connection to NSX Manager
    [object] TestConnection([string] $nsxManager, [PSCredential] $credential, [bool] $skipSSL = $false) {
        $useCurrentUser = ($credential.GetNetworkCredential().Password -eq "CURRENT_USER_CONTEXT")
        $testUri = "https://$nsxManager/api/v1/node"

        try {
            $this.logger.LogInfo("Testing connection to NSX Manager: $nsxManager", "Authentication")

            # Determine if SSL bypass should be used (parameter override or config default)
            $config = $this.configurationService.LoadConfiguration("nsx-config")
            $shouldSkipSSL = $skipSSL -or $config.defaultSkipSSL -or (-not $config.validateSSL)

            $this.logger.LogDebug("SSL bypass parameter: $skipSSL", "Authentication")
            $this.logger.LogDebug("Config defaultSkipSSL: $($config.defaultSkipSSL)", "Authentication")
            $this.logger.LogDebug("Config validateSSL: $($config.validateSSL)", "Authentication")
            $this.logger.LogDebug("Using SSL bypass: $shouldSkipSSL", "Authentication")
            $this.logger.LogDebug("Authentication method: $(if($useCurrentUser){'Current User'}else{'Basic'})", "Authentication")

            # Ensure global SSL bypass is applied when needed
            if ($shouldSkipSSL) {
                $this.logger.LogDebug("Ensuring global SSL bypass is configured", "Authentication")
                $this.SetupGlobalSSLBypass()
            }

            # Create REST parameters with proper SSL configuration
            $restParams = [PSCustomObject]@{
                Uri        = $testUri
                Method     = 'GET'
                TimeoutSec = 30
            }

            # Add SSL bypass for PowerShell 6+ when SSL bypass is needed
            if ($shouldSkipSSL) {
                try {
                    # Check PowerShell version and apply appropriate SSL bypass
                    if ($global:PSVersionTable.PSVersion.Major -ge 6) {
                        # PowerShell 6+ supports SkipCertificateCheck parameter
                        $command = Get-Command Invoke-RestMethod
                        # CANONICAL FIX: Replace ContainsKey with PSCustomObject property access pattern
                        if ((Get-Member -InputObject $command.Parameters -Name 'SkipCertificateCheck' -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
                            $restParams.SkipCertificateCheck = $true
                            $this.logger.LogDebug("Added SkipCertificateCheck parameter for PowerShell 6+", "Authentication")
                        }
                    }
                    else {
                        # PowerShell 5.x - ensure global SSL bypass is applied
                        $this.logger.LogDebug("PowerShell 5.x detected - using global SSL bypass", "Authentication")
                        # Global SSL bypass should already be configured during initialization
                        # Additional verification that SSL bypass is active
                        if ([System.Net.ServicePointManager]::CertificatePolicy -eq $null) {
                            $this.logger.LogDebug("Re-applying global SSL bypass for PowerShell 5.x", "Authentication")
                            $this.SetupGlobalSSLBypass()
                        }
                    }
                }
                catch {
                    $this.logger.LogDebug("SSL bypass configuration failed, relying on global settings: $($_.Exception.Message)", "Authentication")
                }
            }

            # Add authentication based on credential type
            if ($useCurrentUser) {
                $restParams.UseDefaultCredentials = $true
            }
            else {
                $restParams.Credential = $credential
            }

            $this.logger.LogDebug("Making REST call to: $testUri", "Authentication")
            $response = Invoke-RestMethod @restParams

            return @{
                Success    = $true
                Response   = $response
                NodeId     = $response.node_id
                NodeType   = $response.node_type
                Version    = $response.version
                AuthMethod = if ($useCurrentUser) { "Current User" } else { "Basic" }
                SSLBypass  = $shouldSkipSSL
                TestUri    = $testUri
                Message    = "Connection successful"
            }
        }
        catch {
            $this.logger.LogError("Connection test failed: $($_.Exception.Message)", "Authentication")
            return @{
                Success    = $false
                Error      = $_.Exception.Message
                AuthMethod = if ($useCurrentUser) { "Current User" } else { "Basic" }
                SSLBypass  = $true
                TestUri    = $testUri
                Message    = "Connection failed: $($_.Exception.Message)"
            }
        }
    }

    # Set up global SSL bypass for testing environments
    hidden [void] SetupGlobalSSLBypass() {
        try {
            $this.logger.LogInfo("Setting up global SSL bypass for testing environments", "Authentication")

            # Apply manual SSL bypass for PowerShell 5.x compatibility
            # Set up certificate validation callback
            if (-not ("TrustAllCertsPolicy" -as [type])) {
                try {
                    Add-Type -TypeDefinition @"
                        using System.Net;
                        using System.Security.Cryptography.X509Certificates;

                        public class TrustAllCertsPolicy : ICertificatePolicy {
                            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                                return true;
                            }
                        }
"@
                    $this.logger.LogDebug("TrustAllCertsPolicy type added successfully", "Authentication")
                }
                catch {
                    $this.logger.LogWarning("Failed to add TrustAllCertsPolicy type: $($_.Exception.Message)", "Authentication")
                    # Type might already exist from another session, continue anyway
                }
            }

            # Apply the policy
            try {
                if ("TrustAllCertsPolicy" -as [type]) {
                    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
                    $this.logger.LogDebug("TrustAllCertsPolicy applied successfully", "Authentication")
                }
                else {
                    $this.logger.LogDebug("TrustAllCertsPolicy type not available, continuing with basic SSL settings", "Authentication")
                }

                # Apply basic SSL settings regardless
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                [System.Net.ServicePointManager]::CheckCertificateRevocationList = $false
                [System.Net.ServicePointManager]::DefaultConnectionLimit = 50
                [System.Net.ServicePointManager]::Expect100Continue = $false
            }
            catch {
                $this.logger.LogWarning("SSL policy configuration failed: $($_.Exception.Message)", "Authentication")
                # Continue anyway as basic operations might still work
            }

            $this.logger.LogInfo("Global SSL bypass configured successfully", "Authentication")
        }
        catch {
            $this.logger.LogError("Failed to set up SSL bypass: $($_.Exception.Message)", "Authentication")
            throw
        }
    }

    # Get authentication headers for API calls
    [object] GetAuthHeaders([PSCredential] $credential) {
        $headers = [PSCustomObject]@{}

        if ($credential.GetNetworkCredential().Password -ne "CURRENT_USER_CONTEXT") {
            $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($credential.UserName):$($credential.GetNetworkCredential().Password)"))
            $headers["Authorization"] = "Basic $auth"
        }

        return $headers
    }

    # Clean up method for proper resource management
    [void] Dispose() {
        if ($this.certificateCallbacks.Count -gt 0) {
            $this.logger.LogInfo("Cleaning up certificate callbacks", "Authentication")
            $this.certificateCallbacks.Clear()
        }
    }
}
