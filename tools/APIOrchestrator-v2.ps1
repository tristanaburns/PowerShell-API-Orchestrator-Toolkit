# UniversalAPIOrchestrator.ps1
# Demonstrates the API orchestration capabilities
# Tests GET/POST/PUT/DELETE operations with any REST API

[CmdletBinding()]
param(
    [string]$ConfigPath = "config\generic-api-config.json",
    [string]$LogLevel = "Info",
    [switch]$TestAll,
    [switch]$TestGet,
    [switch]$TestPost,
    [switch]$TestPut,
    [switch]$TestDelete,
    [switch]$DetailedOutput
)

# Import required services (using the existing framework)
try {
    . "$PSScriptRoot\..\src\services\LoggingService.ps1"
    . "$PSScriptRoot\..\src\services\ConfigurationService.ps1" 
    . "$PSScriptRoot\..\src\services\CoreAuthenticationService.ps1"
    . "$PSScriptRoot\..\src\services\GenericAPIService.ps1"
}
catch {
    Write-Error "Failed to import required services: $_"
    exit 1
}

function Initialize-ServiceFramework {
    [CmdletBinding()]
    param()
    
    Write-Host "=== API ORCHESTRATOR ===" -ForegroundColor Green
    Write-Host "Initializing service framework..." -ForegroundColor Cyan
    
    try {
        # Initialize logging service
        $loggingService = [LoggingService]::new()
        $loggingService.SetLogLevel($LogLevel)
        
        # Initialize configuration service with config path
        $configPath = Join-Path $PSScriptRoot "..\config"
        $configService = [ConfigurationService]::new($configPath, $loggingService)
        
        # Initialize authentication service  
        $authService = [CoreAuthenticationService]::new($loggingService, $configService)
        
        # Initialize generic API service
        $apiService = [GenericAPIService]::new($loggingService, $authService, $configService)
        
        Write-Host "[SUCCESS] Service framework initialized successfully" -ForegroundColor Green
        
        return @{
            Logging = $loggingService
            Config = $configService
            Auth = $authService
            API = $apiService
        }
    }
    catch {
        Write-Error "Failed to initialize service framework: $_"
        throw $_
    }
}

function Test-APIConnection {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== CONNECTION TEST ===" -ForegroundColor Cyan
    
    try {
        $connectionResult = $Services.API.TestConnection()
        
        if ($connectionResult) {
            Write-Host "[SUCCESS] API connection successful" -ForegroundColor Green
            
            $serviceInfo = $Services.API.GetServiceInfo()
            Write-Host "Base URL: $($serviceInfo.BaseUrl)" -ForegroundColor White
            Write-Host "Service Type: $($serviceInfo.ServiceType)" -ForegroundColor White
            Write-Host "Version: $($serviceInfo.Version)" -ForegroundColor White
        }
        else {
            Write-Host "[FAILED] API connection failed" -ForegroundColor Red
            return $false
        }
        
        return $true
    }
    catch {
        Write-Host "[FAILED] Connection test error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-GetOperations {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== GET OPERATIONS TEST ===" -ForegroundColor Cyan
    
    try {
        # Test 1: Get all posts
        Write-Host "Testing GET /posts (list all)..." -ForegroundColor Yellow
        $posts = $Services.API.Get("posts")
        Write-Host "[SUCCESS] Retrieved $($posts.Count) posts" -ForegroundColor Green
        
        # Test 2: Get specific post
        Write-Host "Testing GET /posts/1 (specific item)..." -ForegroundColor Yellow  
        $post = $Services.API.Get("posts/1")
        Write-Host "[SUCCESS] Retrieved post: '$($post.title)'" -ForegroundColor Green
        
        # Test 3: Get with query parameters
        Write-Host "Testing GET /posts with query params..." -ForegroundColor Yellow
        $filteredPosts = $Services.API.Get("posts", @{ userId = 1; _limit = 5 })
        Write-Host "[SUCCESS] Retrieved $($filteredPosts.Count) filtered posts" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "[FAILED] GET operations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-PostOperations {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== POST OPERATIONS TEST ===" -ForegroundColor Cyan
    
    try {
        # Get test data directly from config file for this demo
        $testPost = @{
            title = "API Orchestrator Test"
            body = "This post was created by the PowerShell API Orchestrator to demonstrate its capabilities with any REST API endpoint."
            userId = 1
        }
        
        Write-Host "Testing POST /posts (create new item)..." -ForegroundColor Yellow
        $newPost = $Services.API.Post("posts", $testPost)
        
        Write-Host "[SUCCESS] Created new post with ID: $($newPost.id)" -ForegroundColor Green
        Write-Host "Title: '$($newPost.title)'" -ForegroundColor White
        Write-Host "Body: '$($newPost.body)'" -ForegroundColor White
        
        return $newPost
    }
    catch {
        Write-Host "[FAILED] POST operations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Test-PutOperations {
    [CmdletBinding()]
    param([object]$Services, [object]$CreatedPost)
    
    Write-Host ""
    Write-Host "=== PUT OPERATIONS TEST ===" -ForegroundColor Cyan
    
    if (-not $CreatedPost) {
        Write-Host "[WARNING] Skipping PUT test - no created post available" -ForegroundColor Yellow
        return $false
    }
    
    try {
        # Update the created post
        $updatedData = @{
            id = $CreatedPost.id
            title = "Updated: $($CreatedPost.title)"
            body = "UPDATED: $($CreatedPost.body)"
            userId = $CreatedPost.userId
        }
        
        Write-Host "Testing PUT /posts/$($CreatedPost.id) (update item)..." -ForegroundColor Yellow
        $updatedPost = $Services.API.Put("posts/$($CreatedPost.id)", $updatedData)
        
        Write-Host "[SUCCESS] Updated post with ID: $($updatedPost.id)" -ForegroundColor Green
        Write-Host "New Title: '$($updatedPost.title)'" -ForegroundColor White
        
        return $true
    }
    catch {
        Write-Host "[FAILED] PUT operations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-DeleteOperations {
    [CmdletBinding()]
    param([object]$Services, [object]$CreatedPost)
    
    Write-Host ""
    Write-Host "=== DELETE OPERATIONS TEST ===" -ForegroundColor Cyan
    
    if (-not $CreatedPost) {
        Write-Host "[WARNING] Skipping DELETE test - no created post available" -ForegroundColor Yellow
        return $false
    }
    
    try {
        Write-Host "Testing DELETE /posts/$($CreatedPost.id) (delete item)..." -ForegroundColor Yellow
        $deleteResult = $Services.API.Delete("posts/$($CreatedPost.id)")
        
        Write-Host "[SUCCESS] Deleted post with ID: $($CreatedPost.id)" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "[FAILED] DELETE operations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-TestSummary {
    [CmdletBinding()]
    param([hashtable]$Results)
    
    Write-Host ""
    Write-Host "=== TEST SUMMARY ===" -ForegroundColor Green
    
    $totalTests = $Results.Count
    $passedTests = ($Results.Values | Where-Object { $_ -eq $true }).Count
    $successRate = [math]::Round(($passedTests / $totalTests) * 100, 1)
    
    Write-Host "Total Tests: $totalTests" -ForegroundColor White
    Write-Host "Passed: $passedTests" -ForegroundColor Green
    Write-Host "Failed: $($totalTests - $passedTests)" -ForegroundColor Red
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { 'Green' } else { 'Yellow' })
    
    Write-Host ""
    foreach ($test in $Results.GetEnumerator()) {
        $status = if ($test.Value) { "[PASS]" } else { "[FAIL]" }
        $color = if ($test.Value) { "Green" } else { "Red" }
        Write-Host "$($test.Key): $status" -ForegroundColor $color
    }
    
    if ($successRate -eq 100) {
        Write-Host ""
        Write-Host "SUCCESS - API ORCHESTRATION PROVEN!" -ForegroundColor Green
        Write-Host "Framework successfully orchestrated a public REST API!" -ForegroundColor Green
    }
}

# Main execution
try {
    # Initialize the service framework
    $services = Initialize-ServiceFramework
    
    # Test connection first
    $connectionOk = Test-APIConnection -Services $services
    
    if (-not $connectionOk) {
        Write-Error "Connection test failed - stopping execution"
        exit 1
    }
    
    # Initialize test results
    $testResults = @{}
    $createdPost = $null
    
    # Run tests based on parameters
    if ($TestAll -or $TestGet) {
        $testResults['GET Operations'] = Test-GetOperations -Services $services
    }
    
    if ($TestAll -or $TestPost) {
        $createdPost = Test-PostOperations -Services $services
        $testResults['POST Operations'] = ($createdPost -ne $null)
    }
    
    if ($TestAll -or $TestPut) {
        $testResults['PUT Operations'] = Test-PutOperations -Services $services -CreatedPost $createdPost
    }
    
    if ($TestAll -or $TestDelete) {
        $testResults['DELETE Operations'] = Test-DeleteOperations -Services $services -CreatedPost $createdPost
    }
    
    # If no specific tests requested, run all
    if (-not ($TestGet -or $TestPost -or $TestPut -or $TestDelete)) {
        Write-Host "No specific tests requested - running all tests" -ForegroundColor Yellow
        
        $testResults['GET Operations'] = Test-GetOperations -Services $services
        $createdPost = Test-PostOperations -Services $services  
        $testResults['POST Operations'] = ($createdPost -ne $null)
        $testResults['PUT Operations'] = Test-PutOperations -Services $services -CreatedPost $createdPost
        $testResults['DELETE Operations'] = Test-DeleteOperations -Services $services -CreatedPost $createdPost
    }
    
    # Show summary
    if ($testResults.Count -gt 0) {
        Show-TestSummary -Results $testResults
    }
    
    Write-Host ""
    Write-Host "Complete - API Orchestrator test complete!" -ForegroundColor Green
}
catch {
    Write-Error "API Orchestrator test failed: $_"
    exit 1
}