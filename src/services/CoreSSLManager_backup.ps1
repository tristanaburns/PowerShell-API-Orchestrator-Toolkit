# CoreSSLManager.ps1
# GLOBAL AGGRESSIVE SSL/TLS BYPASS MANAGER for NSX-T Automation
# Applies session-wide SSL certificate bypass for PowerShell 5.1+ and NSX-T self-signed certificates
# Uses proven brute-force approach inherited from legacy NSX automation scripts

class CoreSSLManager {
    static hidden [bool] $isInitialized = $false
    static hidden [object] $originalCallback
    static hidden [type] $httpClientType = $null

    # Initialize global aggressive SSL bypass - applies immediately to all .NET HTTPS calls
    static [bool] Initialize() {
        try {
            if ([CoreSSLManager]::isInitialized) {
                Write-Verbose "SSL manager already initialized with global bypass active"
                return $true
            }

            # IMPORTANT: This section applies a GLOBAL aggressive SSL bypass
            # that is specifically designed for NSX-T automation environments
            # NEVER MODIFY THIS SECTION - It addresses specific NSX-T SSL compatibility requirements
            # that have been validated across multiple NSX-T versions and PowerShell environments
            # =================================================================
            # This implementation applies a GLOBAL brute-force SSL bypass inherited from legacy NSX automation scripts
            # =================================================================
            # GLOBAL AGGRESSIVE SSL BYPASS IMPLEMENTATION - APPLIED IMMEDIATELY
            # =================================================================
            # This implementation applies a GLOBAL brute-force SSL bypass inherited from legacy NSX automation scripts
            # Once applied, it affects ALL .NET HTTPS calls in the current PowerShell session
            # This is intentionally aggressive and global to handle NSX-T self-signed certificates across all operations
            #
            # CRITICAL: This global approach is required for NSX-T automation environments because:
            # - NSX-T uses self-signed certificates by default in lab/development environments
            # - Certificate validation would block ALL legitimate NSX-T API automation
            # - PowerShell/.NET SSL handling varies significantly between versions and configurations
            # - Legacy .NET Framework SSL behavior must be globally overridden for consistent operation
            # - Individual certificate bypass approaches are unreliable across different NSX-T API endpoints
            #
            # DO NOT MODIFY THIS SECTION - It addresses specific NSX-T SSL compatibility requirements
            # that have been validated across multiple NSX-T versions and PowerShell environments

            # Store original callback for potential restoration (don't store protocol as it may not be supported)
            [CoreSSLManager]::originalCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback

            # STEP 1: Apply aggressive global certificate policy that accepts ALL certificates unconditionally
            try {
                Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class NSXTrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@ -ErrorAction SilentlyContinue

                # STEP 2: Enable TLS 1.2 for NSX-T compatibility (most environments support TLS 1.2)
                try {
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                    Write-Verbose "TLS 1.2 protocol enabled successfully"
                }
                catch {
                    Write-Verbose "Failed to set TLS 1.2, using system default: $($_.Exception.Message)"
                }

                # STEP 3: Apply the global certificate policy - this affects ALL subsequent HTTPS calls
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object NSXTrustAllCertsPolicy

                Write-Verbose "GLOBAL aggressive SSL certificate policy applied - affects ALL HTTPS calls"
            }
            catch {
                # Fallback to callback method if Add-Type fails (older PowerShell versions)
                Write-Verbose "Add-Type failed, applying global callback method: $($_.Exception.Message)"

                # Enable TLS 1.2 for NSX-T compatibility
                try {
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                    Write-Verbose "TLS 1.2 protocol enabled successfully (callback method)"
                }
                catch {
                    Write-Verbose "Failed to set TLS 1.2 in callback method, using system default: $($_.Exception.Message)"
                }

                # Apply global certificate validation callback that accepts all certificates
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {
                    param($senderObj, $certificate, $chain, $sslPolicyErrors)
                    return $true
                }

                Write-Verbose "GLOBAL SSL callback applied - affects ALL HTTPS calls"
            }

            # STEP 4: Apply additional global NSX-T optimizations
            # These settings globally optimize ALL connection handling for NSX-T API performance
            [System.Net.ServicePointManager]::CheckCertificateRevocationList = $false
            [System.Net.ServicePointManager]::DefaultConnectionLimit = 50
            [System.Net.ServicePointManager]::Expect100Continue = $false

            # Initialize modern HttpClient support (for future extensibility)
            [CoreSSLManager]::InitializeModernHttpClient()

            [CoreSSLManager]::isInitialized = $true
            Write-Verbose "GLOBAL NSX-T SSL bypass applied successfully - ALL HTTPS calls now bypass certificate validation"
            return $true
        }
        catch {
            Write-Error "Failed to apply global SSL bypass: $($_.Exception.Message)"
            return $false
        }
    }

    # Initialize modern HttpClient with certificate bypass - simplified version
    static [void] InitializeModernHttpClient() {
        try {
            # For now, just use legacy ServicePointManager approach
            # Modern HttpClient support can be added later if needed
            Write-Verbose "Using legacy SSL approach (ServicePointManager)"
            [CoreSSLManager]::httpClientType = $null
        }
        catch {
            Write-Verbose "Modern HttpClient initialization failed: $($_.Exception.Message)"
            [CoreSSLManager]::httpClientType = $null
        }
    }

    # Test SSL configuration with global bypass applied
    static [bool] TestSSLConfiguration([string] $testUrl) {
        try {
            # FIRST PRIORITY: Ensure global SSL bypass is applied before any HTTPS test
            if (-not [CoreSSLManager]::isInitialized) {
                Write-Verbose "Applying global SSL bypass before SSL configuration test"
                [CoreSSLManager]::Initialize()
            }

            # Create a  web request to test SSL
            $request = [System.Net.WebRequest]::Create($testUrl)
            $request.Method = "GET"
            $request.Timeout = 10000  # 10 seconds

            $response = $request.GetResponse()
            $statusCode = $response.StatusCode
            $response.Close()

            Write-Verbose "SSL test successful - Status: $statusCode"
            return $true
        }
        catch {
            Write-Warning "SSL test failed: $($_.Exception.Message)"
            return $false
        }
    }

    # Create a WebClient with global SSL bypass applied
    static [System.Net.WebClient] CreateWebClient() {
        # FIRST PRIORITY: Ensure global SSL bypass is applied before any HTTPS operations
        if (-not [CoreSSLManager]::isInitialized) {
            Write-Verbose "Applying global SSL bypass before WebClient creation"
            [CoreSSLManager]::Initialize()
        }

        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "NSX-PowerShell-Toolkit/1.0")
        return $webClient
    }

    # Create properly configured parameters for Invoke-RestMethod with global SSL bypass
    static [object] CreateRestMethodParameters([string] $uri, [string] $method = "GET", [PSCredential] $credential = $null, [object] $body = $null) {
        # FIRST PRIORITY: Ensure global SSL bypass is applied before any HTTPS operations
        if (-not [CoreSSLManager]::isInitialized) {
            Write-Verbose "Applying global SSL bypass before REST method configuration"
            [CoreSSLManager]::Initialize()
        }

        $params = [PSCustomObject]@{
            Uri             = $uri
            Method          = $method
            TimeoutSec      = 30
            UseBasicParsing = $true
        }

        # Add authentication
        if ($credential) {
            $useCurrentUser = ($credential.GetNetworkCredential().Password -eq "CURRENT_USER_CONTEXT")

            if ($useCurrentUser) {
                $params.UseDefaultCredentials = $true
            }
            else {
                $authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($credential.UserName):$($credential.GetNetworkCredential().Password)"))
                $params.Headers = @{
                    'Authorization' = $authHeader
                    'Content-Type'  = 'application/json'
                    'Accept'        = 'application/json'
                }
            }
        }

        # Add body if provided
        if ($body) {
            if ($body -is [string]) {
                $params.Body = $body
            }
            else {
                $params.Body = $body | ConvertTo-Json -Depth 10
            }

            if (-not $params.Headers) {
                $params.Headers = [PSCustomObject]@{}
            }
            $params.Headers['Content-Type'] = 'application/json'
        }

        # PowerShell 6+ has SkipCertificateCheck parameter, PowerShell 5.1 relies on global callback
        # Use a  approach - assume PowerShell 5.1 and skip the parameter
        # The global SSL bypass applied in Initialize() handles certificate validation
        # for PowerShell 5.1, so we don't need to add SkipCertificateCheck parameter
        Write-Verbose "Using global SSL bypass - SkipCertificateCheck parameter not needed"

        return $params
    }

    # Restore original SSL settings
    static [void] Restore() {
        if ([CoreSSLManager]::isInitialized) {
            try {
                # Only restore callback, leave SecurityProtocol as-is
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [CoreSSLManager]::originalCallback
                [CoreSSLManager]::isInitialized = $false
                Write-Verbose "SSL callback restored to original state"
            }
            catch {
                Write-Warning "Failed to restore SSL settings: $($_.Exception.Message)"
            }
        }
    }

    # Get current SSL status
    static [object] GetStatus() {
        return @{
            IsInitialized     = [CoreSSLManager]::isInitialized
            CurrentProtocol   = [System.Net.ServicePointManager]::SecurityProtocol
            CallbackSet       = $null -ne [System.Net.ServicePointManager]::ServerCertificateValidationCallback
            PowerShellVersion = "5.1+"
        }
    }
}
