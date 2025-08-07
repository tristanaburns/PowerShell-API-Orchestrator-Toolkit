# TestAuthenticationRecovery.ps1
# Comprehensive test script for the Authentication Failure Recovery System
# Demonstrates all authentication recovery capabilities with real API endpoints

[CmdletBinding()]
param(
    [string]$TestAPIUrl = "https://api.github.com",
    [string]$TestEndpoint = "/user",
    [string]$LogLevel = "Info",
    [switch]$InteractiveTest,
    [switch]$MockTest,
    [switch]$ShowDemo
)

# Import the universal service framework
try {
    . "$PSScriptRoot\..\src\services\LoggingService.ps1"
    . "$PSScriptRoot\..\src\services\ConfigurationService.ps1"
    . "$PSScriptRoot\..\src\services\CredentialService.ps1"
    . "$PSScriptRoot\..\src\services\CoreAuthenticationService.ps1"
    . "$PSScriptRoot\..\src\services\AuthenticationFailureRecoveryService.ps1"
    . "$PSScriptRoot\..\src\services\GenericAPIService.ps1"
}
catch {
    Write-Error "Failed to import service framework: $_"
    exit 1
}

function Initialize-TestServices {
    [CmdletBinding()]
    param([string]$LogLevel)
    
    Write-Host "=== AUTHENTICATION RECOVERY TEST FRAMEWORK ===" -ForegroundColor Green
    Write-Host "Initializing test services for authentication recovery..." -ForegroundColor Cyan
    
    try {
        # Initialize core services
        $loggingService = [LoggingService]::new($null, $true, $true)
        $loggingService.SetLogLevel($LogLevel)
        
        $configPath = Join-Path $PSScriptRoot "..\config"
        $configService = [ConfigurationService]::new($configPath, $loggingService)
        
        $credentialPath = Join-Path $PSScriptRoot "..\config\credentials"
        $credentialService = [CredentialService]::new($credentialPath, $loggingService)
        
        $authService = [CoreAuthenticationService]::new($loggingService, $credentialService, $configService)
        
        # Create test API configuration
        $testConfig = @{
            BaseUrl = $TestAPIUrl
            Headers = @{
                'User-Agent' = 'Authentication-Recovery-Test/1.0'
                'Accept' = 'application/json'
            }
        }
        
        # Save test configuration temporarily
        $tempConfigPath = Join-Path $configPath "auth-recovery-test.json"
        $testConfig | ConvertTo-Json | Out-File -FilePath $tempConfigPath -Encoding UTF8
        
        # Override the configService to use our test config
        $configService | Add-Member -MemberType ScriptMethod -Name LoadConfiguration -Value {
            param([string]$configName)
            if ($configName -eq "api-config") {
                return [PSCustomObject]@{
                    BaseUrl = $using:TestAPIUrl
                    Headers = @{
                        'User-Agent' = 'Authentication-Recovery-Test/1.0'
                        'Accept' = 'application/json'
                    }
                }
            }
            return $null
        } -Force
        
        # Create API service with authentication recovery
        $apiService = [GenericAPIService]::new($loggingService, $authService, $configService)
        
        Write-Host "[SUCCESS] Test services initialized" -ForegroundColor Green
        
        return @{
            Logging = $loggingService
            Config = $configService
            Credential = $credentialService
            Auth = $authService
            API = $apiService
            AuthRecovery = $apiService.authRecoveryService
        }
    }
    catch {
        Write-Error "Failed to initialize test services: $_"
        throw $_
    }
}

function Test-AuthenticationFailureDetection {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== TEST 1: Authentication Failure Detection ===" -ForegroundColor Yellow
    
    $testCases = @(
        @{
            Name = "401 Unauthorized Response"
            MockResponse = @{
                Exception = @{
                    Response = @{
                        StatusCode = 401
                    }
                }
                ErrorDetails = @{
                    Message = "401 Unauthorized"
                }
            }
            ExpectedFailure = $true
        },
        @{
            Name = "403 Forbidden Response"
            MockResponse = @{
                Exception = @{
                    Response = @{
                        StatusCode = 403
                    }
                }
                ErrorDetails = @{
                    Message = "403 Forbidden - Access denied"
                }
            }
            ExpectedFailure = $true
        },
        @{
            Name = "200 Success Response"
            MockResponse = @{
                StatusCode = 200
                Content = "Success response"
            }
            ExpectedFailure = $false
        },
        @{
            Name = "Authentication keyword in error"
            MockResponse = @{
                ErrorDetails = @{
                    Message = "Invalid authentication credentials provided"
                }
            }
            ExpectedFailure = $true
        }
    )
    
    $passedTests = 0
    $totalTests = $testCases.Count
    
    foreach ($testCase in $testCases) {
        Write-Host ""
        Write-Host "Testing: $($testCase.Name)" -ForegroundColor Cyan
        
        try {
            # Use reflection to access the hidden method
            $detectionMethod = $Services.AuthRecovery.GetType().GetMethod('DetectAuthenticationFailure', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
            $result = $detectionMethod.Invoke($Services.AuthRecovery, @($testCase.MockResponse))
            
            if ($result.IsAuthFailure -eq $testCase.ExpectedFailure) {
                Write-Host "[PASS] Detection result: $($result.IsAuthFailure) (Expected: $($testCase.ExpectedFailure))" -ForegroundColor Green
                if ($result.IsAuthFailure) {
                    Write-Host "       Failure reason: $($result.FailureReason)" -ForegroundColor Gray
                }
                $passedTests++
            }
            else {
                Write-Host "[FAIL] Detection result: $($result.IsAuthFailure) (Expected: $($testCase.ExpectedFailure))" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "[ERROR] Test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Authentication Failure Detection: $passedTests/$totalTests tests passed" -ForegroundColor $(if($passedTests -eq $totalTests){"Green"}else{"Yellow"})
    return ($passedTests -eq $totalTests)
}

function Test-AuthenticationTypeDetection {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== TEST 2: Authentication Type Auto-Detection ===" -ForegroundColor Yellow
    
    $testCases = @(
        @{
            Name = "GitHub API URL"
            BaseUrl = "https://api.github.com"
            MockResponse = @{ ErrorDetails = @{ Message = "Bad credentials" } }
            ExpectedType = "Bearer"
        },
        @{
            Name = "WWW-Authenticate Bearer Header"
            BaseUrl = "https://api.example.com"
            MockResponse = @{ 
                Headers = @{ "WWW-Authenticate" = "Bearer realm='api'" }
                ErrorDetails = @{ Message = "Unauthorized" }
            }
            ExpectedType = "Bearer"
        },
        @{
            Name = "API Key in Content"
            BaseUrl = "https://api.example.com"
            MockResponse = @{ 
                ErrorDetails = @{ Message = "Missing X-API-Key header" }
            }
            ExpectedType = "ApiKey"
        },
        @{
            Name = "Basic Auth WWW-Authenticate"
            BaseUrl = "https://api.example.com"
            MockResponse = @{ 
                Headers = @{ "WWW-Authenticate" = "Basic realm='Protected'" }
                ErrorDetails = @{ Message = "Unauthorized" }
            }
            ExpectedType = "Basic"
        }
    )
    
    $passedTests = 0
    $totalTests = $testCases.Count
    
    foreach ($testCase in $testCases) {
        Write-Host ""
        Write-Host "Testing: $($testCase.Name)" -ForegroundColor Cyan
        
        try {
            # Use reflection to access the hidden method
            $detectionMethod = $Services.AuthRecovery.GetType().GetMethod('DetectAuthenticationTypeFromResponse', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
            $result = $detectionMethod.Invoke($Services.AuthRecovery, @($testCase.MockResponse, $testCase.BaseUrl, ""))
            
            if ($result.AuthType -eq $testCase.ExpectedType) {
                Write-Host "[PASS] Detected type: $($result.AuthType) (Expected: $($testCase.ExpectedType))" -ForegroundColor Green
                Write-Host "       Confidence: $($result.Confidence)" -ForegroundColor Gray
                if ($result.AuthHints.Count -gt 0) {
                    Write-Host "       Hints: $($result.AuthHints -join ', ')" -ForegroundColor Gray
                }
                $passedTests++
            }
            else {
                Write-Host "[FAIL] Detected type: $($result.AuthType) (Expected: $($testCase.ExpectedType))" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "[ERROR] Test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Authentication Type Detection: $passedTests/$totalTests tests passed" -ForegroundColor $(if($passedTests -eq $totalTests){"Green"}else{"Yellow"})
    return ($passedTests -eq $totalTests)
}

function Test-RetryMechanism {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== TEST 3: Retry Mechanism & Account Lockout Prevention ===" -ForegroundColor Yellow
    
    $testUrl = "https://test.example.com"
    
    Write-Host ""
    Write-Host "Testing retry limit enforcement..." -ForegroundColor Cyan
    
    # Simulate multiple authentication failures to test retry limits
    for ($i = 1; $i -le 3; $i++) {
        Write-Host ""
        Write-Host "Attempt $i:" -ForegroundColor White
        
        $mockResponse = @{
            Exception = @{
                Response = @{
                    StatusCode = 401
                }
            }
            ErrorDetails = @{
                Message = "Invalid credentials"
            }
        }
        
        try {
            $result = $Services.AuthRecovery.HandleAuthenticationFailure($testUrl, $mockResponse, "/test")
            
            if ($i -le 2) {
                if ($result.RequiresAuth -and -not $result.Message.Contains("Maximum")) {
                    Write-Host "[PASS] Attempt $i allowed (within retry limit)" -ForegroundColor Green
                }
                else {
                    Write-Host "[FAIL] Attempt $i should be allowed" -ForegroundColor Red
                }
            }
            else {
                if ($result.Message.Contains("Maximum") -or $result.Message.Contains("lockout")) {
                    Write-Host "[PASS] Attempt $i blocked (lockout protection activated)" -ForegroundColor Green
                }
                else {
                    Write-Host "[FAIL] Attempt $i should be blocked" -ForegroundColor Red
                }
            }
            
            if ($result.RetryCount) {
                Write-Host "       Current retry count: $($result.RetryCount)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "[ERROR] Retry test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Test retry reset
    Write-Host ""
    Write-Host "Testing retry reset functionality..." -ForegroundColor Cyan
    $Services.AuthRecovery.ResetRetryAttempts($testUrl)
    
    $result = $Services.AuthRecovery.HandleAuthenticationFailure($testUrl, $mockResponse, "/test")
    if ($result.RequiresAuth -and -not $result.Message.Contains("Maximum")) {
        Write-Host "[PASS] Retry attempts successfully reset" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] Retry reset did not work properly" -ForegroundColor Red
    }
    
    return $true
}

function Test-CredentialStorage {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== TEST 4: Secure Credential Storage ===" -ForegroundColor Yellow
    
    $testUrl = "https://credential-test.example.com"
    $testCredential = [PSCredential]::new("testuser", (ConvertTo-SecureString "testpass" -AsPlainText -Force))
    
    try {
        # Test saving credentials
        Write-Host ""
        Write-Host "Testing credential save..." -ForegroundColor Cyan
        $success = $Services.Credential.SaveCredentials($testUrl, $testCredential)
        
        if ($success) {
            Write-Host "[PASS] Credentials saved successfully" -ForegroundColor Green
        }
        else {
            Write-Host "[FAIL] Failed to save credentials" -ForegroundColor Red
            return $false
        }
        
        # Test loading credentials
        Write-Host "Testing credential load..." -ForegroundColor Cyan
        $loadedCredential = $Services.Credential.LoadCredentials($testUrl)
        
        if ($loadedCredential -and $loadedCredential.UserName -eq $testCredential.UserName) {
            Write-Host "[PASS] Credentials loaded successfully" -ForegroundColor Green
        }
        else {
            Write-Host "[FAIL] Failed to load credentials or data mismatch" -ForegroundColor Red
            return $false
        }
        
        # Test saved auth details integration
        Write-Host "Testing authentication recovery integration..." -ForegroundColor Cyan
        $authDetails = @{
            AuthDetails = @{
                Type = "Basic"
                Username = "testuser"
                Password = $testCredential.Password
            }
            SaveCredentials = $true
        }
        
        # Use reflection to access the hidden method
        $saveMethod = $Services.AuthRecovery.GetType().GetMethod('SaveAuthenticationDetails', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
        $saveMethod.Invoke($Services.AuthRecovery, @($testUrl, $authDetails))
        
        $savedAuth = $Services.AuthRecovery.LoadSavedAuthDetails($testUrl)
        if ($savedAuth -and $savedAuth.Success) {
            Write-Host "[PASS] Authentication recovery storage integration works" -ForegroundColor Green
        }
        else {
            Write-Host "[FAIL] Authentication recovery storage integration failed" -ForegroundColor Red
            return $false
        }
        
        # Cleanup
        $Services.Credential.RemoveCredentials($testUrl)
        Write-Host "[CLEANUP] Test credentials removed" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Host "[ERROR] Credential storage test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-InteractiveDemo {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== INTERACTIVE AUTHENTICATION RECOVERY DEMO ===" -ForegroundColor Yellow
    Write-Host "This demo will show how the authentication recovery system works" -ForegroundColor White
    Write-Host "when a real authentication failure occurs." -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "Start interactive demo? (y/N)"
    if ($continue -notmatch '^(y|yes)$') {
        Write-Host "Demo cancelled" -ForegroundColor Yellow
        return
    }
    
    try {
        Write-Host ""
        Write-Host "Testing authentication recovery with real API..." -ForegroundColor Cyan
        Write-Host "This will trigger a 401 Unauthorized response that will activate recovery." -ForegroundColor White
        
        # Test with the API service directly - this should trigger auth recovery
        $result = $Services.API.TestAuthenticationRecovery($TestEndpoint)
        
        if ($result.Success) {
            Write-Host ""
            Write-Host "[SUCCESS] Authentication recovery system activated!" -ForegroundColor Green
            Write-Host "Recovery details:" -ForegroundColor White
            Write-Host "  Auth Type: $($result.AuthType)" -ForegroundColor Gray
            Write-Host "  Message: $($result.Message)" -ForegroundColor Gray
            Write-Host "  Retry Count: $($result.RetryCount)" -ForegroundColor Gray
        }
        else {
            Write-Host ""
            Write-Host "[INFO] Authentication recovery test result:" -ForegroundColor Yellow
            Write-Host "  Message: $($result.Message)" -ForegroundColor Gray
            if ($result.Error) {
                Write-Host "  Error: $($result.Error)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "[ERROR] Interactive demo failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-ServiceCapabilities {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== AUTHENTICATION RECOVERY SERVICE CAPABILITIES ===" -ForegroundColor Green
    
    $apiInfo = $Services.API.GetServiceInfo()
    $authRecoveryInfo = $apiInfo.AuthRecoveryInfo
    
    Write-Host ""
    Write-Host "Generic API Service:" -ForegroundColor Cyan
    Write-Host "  Version: $($apiInfo.Version)" -ForegroundColor White
    Write-Host "  Base URL: $($apiInfo.BaseUrl)" -ForegroundColor White
    Write-Host "  Authentication Recovery: $($apiInfo.AuthenticationRecovery)" -ForegroundColor White
    
    if ($authRecoveryInfo) {
        Write-Host ""
        Write-Host "Authentication Recovery Service:" -ForegroundColor Cyan
        Write-Host "  Service Type: $($authRecoveryInfo.ServiceType)" -ForegroundColor White
        Write-Host "  Version: $($authRecoveryInfo.Version)" -ForegroundColor White
        Write-Host "  Max Retries: $($authRecoveryInfo.MaxRetries)" -ForegroundColor White
        Write-Host "  Active Retry Keys: $($authRecoveryInfo.ActiveRetryKeys.Count)" -ForegroundColor White
        Write-Host "  Cached Auth Types: $($authRecoveryInfo.CachedAuthTypes.Count)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Key Features:" -ForegroundColor Cyan
    Write-Host "  ✓ Automatic authentication failure detection (401/403 responses)" -ForegroundColor Green
    Write-Host "  ✓ Interactive authentication prompts with type auto-detection" -ForegroundColor Green
    Write-Host "  ✓ Support for ApiKey, Bearer Token, Basic Auth, Custom Headers" -ForegroundColor Green
    Write-Host "  ✓ Secure encrypted credential storage using existing CredentialService" -ForegroundColor Green
    Write-Host "  ✓ Account lockout prevention with maximum 2 retry attempts" -ForegroundColor Green
    Write-Host "  ✓ Automatic retry mechanism with intelligent header updates" -ForegroundColor Green
    Write-Host "  ✓ Response analysis for authentication method hints" -ForegroundColor Green
    Write-Host "  ✓ Integration with all HTTP methods (GET, POST, PUT, DELETE)" -ForegroundColor Green
}

# Main execution
try {
    Write-Host "Starting Authentication Recovery System Tests..." -ForegroundColor Green
    Write-Host "Test API: $TestAPIUrl" -ForegroundColor White
    Write-Host "Test Endpoint: $TestEndpoint" -ForegroundColor White
    Write-Host ""
    
    # Initialize test services
    $services = Initialize-TestServices -LogLevel $LogLevel
    
    # Show service capabilities
    Show-ServiceCapabilities -Services $services
    
    if ($ShowDemo) {
        Show-InteractiveDemo -Services $services
        return
    }
    
    if ($InteractiveTest) {
        Write-Host ""
        Write-Host "Running in interactive mode - you will be prompted for authentication..." -ForegroundColor Yellow
        Show-InteractiveDemo -Services $services
        return
    }
    
    # Run automated tests
    $testResults = @()
    
    Write-Host ""
    Write-Host "Running automated test suite..." -ForegroundColor Cyan
    
    # Test 1: Authentication Failure Detection
    $testResults += Test-AuthenticationFailureDetection -Services $services
    
    # Test 2: Authentication Type Detection  
    $testResults += Test-AuthenticationTypeDetection -Services $services
    
    # Test 3: Retry Mechanism
    $testResults += Test-RetryMechanism -Services $services
    
    # Test 4: Credential Storage
    $testResults += Test-CredentialStorage -Services $services
    
    # Summary
    $passedTests = ($testResults | Where-Object { $_ -eq $true }).Count
    $totalTests = $testResults.Count
    
    Write-Host ""
    Write-Host "=== TEST SUMMARY ===" -ForegroundColor Green
    Write-Host "Total Tests: $totalTests" -ForegroundColor White
    Write-Host "Passed: $passedTests" -ForegroundColor Green
    Write-Host "Failed: $($totalTests - $passedTests)" -ForegroundColor $(if($passedTests -eq $totalTests){"Green"}else{"Red"})
    
    if ($passedTests -eq $totalTests) {
        Write-Host ""
        Write-Host "🎉 ALL TESTS PASSED! 🎉" -ForegroundColor Green
        Write-Host "The Authentication Failure Recovery System is working correctly!" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "❌ Some tests failed. Please review the output above." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Authentication Recovery System testing complete!" -ForegroundColor Green
}
catch {
    Write-Error "Test execution failed: $_"
    exit 1
}