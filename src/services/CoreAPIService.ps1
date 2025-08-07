# CoreAPIService.ps1
# Consolidated NSX-T API service following SOLID principles
# Single responsibility for all NSX-T API operations with dependency injection

class CoreAPIService {
    hidden [object] $logger
    hidden [object] $authService
    hidden [object] $configService
    hidden [object] $endpointCache

    # Constructor with dependency injection
    CoreAPIService([object] $loggingService, [object] $authService, [object] $configService) {
        $this.logger = $loggingService
        $this.authService = $authService
        $this.configService = $configService
        $this.endpointCache = [PSCustomObject]@{}
        $this.logger.LogInfo("CoreAPIService initialised", "API")

        # Initialize SSL certificate bypass for NSX self-signed certificates
        $this.InitializeSSLBypass()

        $this.logger.LogInfo("CoreAPIService initialized with SSL certificate bypass", "API")
    }

    # Initialize SSL certificate bypass for self-signed certificates
    hidden [void] InitializeSSLBypass() {
        try {
            # Check if TrustAllCertsPolicy is already defined to avoid redefinition errors
            if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type) {
                add-type @"
                    using System.Net;
                    using System.Security.Cryptography.X509Certificates;
                    public class TrustAllCertsPolicy : ICertificatePolicy {
                        public bool CheckValidationResult(
                            ServicePoint srvPoint, X509Certificate certificate,
                            WebRequest request, int certificateProblem) {
                            return true;
                        }
                    }
"@
            }

            # Apply the certificate policy and enable TLS protocols
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls

            $this.logger.LogDebug("SSL certificate validation bypassed globally", "API")
        }
        catch {
            $this.logger.LogWarning("Failed to initialize SSL bypass: $($_.Exception.Message)", "API")
        }
    }


    # Generic REST method following Open/Closed Principle
    [object] InvokeRestMethod([string] $nsxManager, [PSCredential] $credential, [string] $endpoint, [string] $method = 'GET', [object] $body = $null, [object] $additionalHeaders = [PSCustomObject]@{}) {



        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $config = $this.configService.LoadConfiguration("nsx-config")
        $uri = "https://$nsxManager$endpoint"
        try {

            $useCurrentUser = ($credential.GetNetworkCredential().Password -eq "CURRENT_USER_CONTEXT")

            # Prepare request parameters
            $splat = [PSCustomObject]@{
                Uri        = $uri
                Method     = $method
                TimeoutSec = $config.timeout
            }

            # Add SSL bypass for PowerShell 6+ (use -SkipCertificateCheck)
            if ($global:PSVersionTable.PSVersion.Major -ge 6) {
                $splat.SkipCertificateCheck = $true
            }

            # Add authentication and headers
            if ($useCurrentUser) {
                $splat.UseDefaultCredentials = $true
                $headers = [PSCustomObject]@{
                    'Content-Type' = 'application/json'
                    'Accept'       = 'application/json'
                }
            }
            else {
                $authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($credential.UserName):$($credential.GetNetworkCredential().Password)"))
                $headers = [PSCustomObject]@{
                    'Authorization' = $authHeader
                    'Content-Type'  = 'application/json'
                    'Accept'        = 'application/json'
                }
            }

            # Add any additional headers
            foreach ($key in $additionalHeaders.Keys) {
                $headers[$key] = $additionalHeaders[$key]
            }

            $splat.Headers = $headers

            # Add body if provided
            $requestBody = $null
            if ($body) {
                if ($body -is [string]) {
                    $requestBody = $body
                    $splat.Body = $body
                }
                else {
                    $requestBody = $body | ConvertTo-Json -Depth 10 -Compress
                    $splat.Body = $requestBody
                }
            }

            # SSL bypass handled globally by CoreAuthenticationService

            # Log the full API request details
            $this.logger.LogAPIRequest($method, $uri, $headers, $requestBody)

            # Execute the API call
            $result = Invoke-RestMethod @splat
            $stopwatch.Stop()

            # Log successful response with full details
            $statusCode = 200  # Invoke-RestMethod doesn't return status code directly, assume 200 on success
            $this.logger.LogAPIResponse($method, $uri, $statusCode, $result, $stopwatch.ElapsedMilliseconds)
            $this.logger.LogPayloadSummary("Response", $result, "API Response")

            return $result
        }
        catch {
            $stopwatch.Stop()

            # error logging for 400 errors to capture response details
            if ($_.Exception -is [System.Net.WebException] -and $_.Exception.Response) {
                $response = $_.Exception.Response
                $stream = $response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $responseBody = $reader.ReadToEnd()
                $reader.Close()
                $stream.Close()

                $this.logger.LogError("API Error Details - Status: $($response.StatusCode), Response: $responseBody", "API")
            }

            $this.logger.LogAPIError($method, $uri, $_.Exception, $stopwatch.ElapsedMilliseconds)
            throw
        }
    }

    # Get node information
    [object] GetNodeInfo([string] $nsxManager, [PSCredential] $credential) {
        return $this.InvokeRestMethod($nsxManager, $credential, "/api/v1/node", "GET", $null, @{})
    }

    # Get policy domains
    [object] GetPolicyDomains([string] $nsxManager, [PSCredential] $credential, [bool] $global = $false) {
        $endpoint = if ($global) { "/policy/api/v1/global-infra/domains" } else { "/policy/api/v1/infra/domains" }
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET")
    }

    # Get groups from specific domain
    [object] GetGroups([string] $nsxManager, [PSCredential] $credential, [string] $domainId = "default") {
        $endpoint = "/policy/api/v1/infra/domains/$domainId/groups"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET")
    }

    # Get services from specific domain
    [object] GetServices([string] $nsxManager, [PSCredential] $credential, [string] $domainId = "default") {
        $endpoint = "/policy/api/v1/infra/services"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET")
    }

    # Get security policies from specific domain
    [object] GetSecurityPolicies([string] $nsxManager, [PSCredential] $credential, [string] $domainId = "default") {
        $endpoint = "/policy/api/v1/infra/domains/$domainId/security-policies"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET")
    }

    # Get hierarchical configuration (for migration)
    [object] GetHierarchicalConfig([string] $nsxManager, [PSCredential] $credential, [string] $objectType = "infra") {
        $endpoint = "/policy/api/v1/$objectType"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "GET")
    }

    # Apply hierarchical configuration (for migration)
    [object] ApplyHierarchicalConfig([string] $nsxManager, [PSCredential] $credential, [object] $config, [string] $objectType = "infra") {
        $endpoint = "/policy/api/v1/$objectType"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "PUT", $config)
    }

    # Patch hierarchical configuration (for sync)
    [object] PatchHierarchicalConfig([string] $nsxManager, [PSCredential] $credential, [object] $patchConfig, [string] $objectType = "infra") {
        $endpoint = "/policy/api/v1/$objectType"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "PATCH", $patchConfig)
    }

    # Create or update group
    [object] CreateOrUpdateGroup([string] $nsxManager, [PSCredential] $credential, [string] $domainId, [string] $groupId, [object] $groupConfig) {
        $endpoint = "/policy/api/v1/infra/domains/$domainId/groups/$groupId"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "PUT", $groupConfig)
    }

    # Delete group
    [object] DeleteGroup([string] $nsxManager, [PSCredential] $credential, [string] $domainId, [string] $groupId) {
        $endpoint = "/policy/api/v1/infra/domains/$domainId/groups/$groupId"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "DELETE")
    }

    # Create or update service
    [object] CreateOrUpdateService([string] $nsxManager, [PSCredential] $credential, [string] $serviceId, [object] $serviceConfig) {
        $endpoint = "/policy/api/v1/infra/services/$serviceId"
        return $this.InvokeRestMethod($nsxManager, $credential, $endpoint, "PUT", $serviceConfig)
    }

    # Legacy method name for backward compatibility - wrapper around InvokeRestMethod
    [object] MakeNSXAPICall([string] $nsxManager, [string] $method, [string] $endpoint, [object] $body = $null) {
        # Get credentials for this NSX manager
        $credentials = $this.authService.CollectCredentials($nsxManager, $false, $false, $null, $false)

        # Ensure endpoint starts with /
        if (-not $endpoint.StartsWith('/')) {
            $endpoint = "/$endpoint"
        }

        # Call the main REST method
        return $this.InvokeRestMethod($nsxManager, $credentials, $endpoint, $method, $body)
    }

    # Test multiple endpoints for connectivity with configurable HTTP method and endpoint definitions
    # Universal/Generic method - accepts endpoint definitions from external configuration
    [object] TestEndpoints([string] $hostUrl, [PSCredential] $credential, [array] $endpointDefinitions, [string] $method = "GET", [object] $testBody = $null) {

        if (-not $endpointDefinitions -or $endpointDefinitions.Count -eq 0) {
            $this.logger.LogWarning("No endpoint definitions provided to TestEndpoints method", "API")
            return [PSCustomObject]@{}
        }

        $results = [PSCustomObject]@{}
        $methodUpper = $method.ToUpper()

        $this.logger.LogInfo("Testing $($endpointDefinitions.Count) endpoints with HTTP method: $methodUpper", "API")

        foreach ($endpoint in $endpointDefinitions) {
            # Validate endpoint definition structure
            if (-not $endpoint.Name -or -not $endpoint.Uri) {
                $this.logger.LogWarning("Invalid endpoint definition - missing Name or Uri properties", "API")
                continue
            }

            # Check if endpoint supports the requested method
            if ($endpoint.SupportedMethods -and $methodUpper -notin $endpoint.SupportedMethods) {
                $this.logger.LogDebug("Endpoint '$($endpoint.Name)' does not support $methodUpper method - skipping", "API")
                continue
            }

            try {
                # Use the configurable method parameter with generic endpoint
                $result = $this.InvokeRestMethod($hostUrl, $credential, $endpoint.Uri, $methodUpper, $testBody, @{})

                $results[$endpoint.Name] = @{
                    Success   = $true
                    Method    = $methodUpper
                    Uri       = $endpoint.Uri
                    ItemCount = if ($result.results) { $result.results.Count } else { if ($result) { 1 } else { 0 } }
                    Error     = $null
                    HasBody   = $testBody -ne $null
                    Category  = if ($endpoint.Category) { $endpoint.Category } else { "General" }
                }
                $this.logger.LogInfo("Endpoint test successful: $($endpoint.Name) using $methodUpper", "API")
            }
            catch {
                $results[$endpoint.Name] = @{
                    Success   = $false
                    Method    = $methodUpper
                    Uri       = $endpoint.Uri
                    ItemCount = 0
                    Error     = $_.Exception.Message
                    HasBody   = $testBody -ne $null
                    Category  = if ($endpoint.Category) { $endpoint.Category } else { "General" }
                }
                $this.logger.LogWarning("Endpoint test failed: $($endpoint.Name) using $methodUpper - $($_.Exception.Message)", "API")
            }
        }

        $this.logger.LogInfo("Completed endpoint testing with $methodUpper method. Results: $($results.Count) endpoints tested", "API")
        return $results
    }

    # Get paginated results (following DRY principle)
    [array] GetPaginatedResults([string] $nsxManager, [PSCredential] $credential, [string] $endpoint, [int] $pageSize = 100) {
        $allResults = @()
        $cursor = $null

        do {
            $uri = $endpoint
            if ($cursor) {
                $uri += if ($endpoint.Contains('?')) { "&cursor=$cursor" } else { "?cursor=$cursor" }
            }
            if ($pageSize -and $pageSize -gt 0) {
                $uri += if ($endpoint.Contains('?') -or $cursor) { "&page_size=$pageSize" } else { "?page_size=$pageSize" }
            }

            try {
                $result = $this.InvokeRestMethod($nsxManager, $credential, $uri, "GET")

                if ($result.results) {
                    $allResults += $result.results
                }

                $cursor = $result.cursor
            }
            catch {
                $this.logger.LogException($_.Exception, "Failed to get paginated results from: $uri")
                break
            }
        } while ($cursor)

        return $allResults
    }

    # Clear endpoint cache
    [void] ClearCache() {
        $this.endpointCache.Clear()
        $this.logger.LogInfo("Cleared API endpoint cache", "API")
    }
}
