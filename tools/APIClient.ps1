# APIClient.ps1
# API client that can work with ANY REST API
# Completely configurable - no hardcoded endpoints or data

[CmdletBinding()]
param(
    [string]$ConfigName = "api-config",
    [string]$LogLevel = "Info",
    [switch]$TestConnection,
    [switch]$ListItems,
    [switch]$GetItem,
    [int]$ItemId = 1,
    [switch]$CreateItem,
    [switch]$UpdateItem,
    [switch]$DeleteItem,
    [switch]$RunAllTests,
    [string]$CustomEndpoint,
    [string]$Method = "GET",
    [string]$Body
)

# Import the service framework
try {
    . "$PSScriptRoot\..\src\services\LoggingService.ps1"
    . "$PSScriptRoot\..\src\services\ConfigurationService.ps1"
    . "$PSScriptRoot\..\src\services\CredentialService.ps1"
    . "$PSScriptRoot\..\src\services\CoreAuthenticationService.ps1"
    . "$PSScriptRoot\..\src\services\GenericAPIService.ps1"
}
catch {
    Write-Error "Failed to import service framework: $_"
    exit 1
}

function Initialize-Services {
    [CmdletBinding()]
    param([string]$ConfigName, [string]$LogLevel)
    
    Write-Host "=== API CLIENT ===" -ForegroundColor Green
    Write-Host "Initializing service framework..." -ForegroundColor Cyan
    
    try {
        # Initialize core services with proper parameters
        $loggingService = [LoggingService]::new($null, $true, $true)
        $loggingService.SetLogLevel($LogLevel)
        
        $configPath = Join-Path $PSScriptRoot "..\config"
        $configService = [ConfigurationService]::new($configPath, $loggingService)
        
        $credentialPath = Join-Path $PSScriptRoot "..\config\credentials"
        $credentialService = [CredentialService]::new($credentialPath, $loggingService)
        
        $authService = [CoreAuthenticationService]::new($loggingService, $credentialService, $configService)
        $apiService = [GenericAPIService]::new($loggingService, $authService, $configService)
        
        # Load the API configuration
        $apiConfig = $configService.LoadConfiguration($ConfigName)
        
        Write-Host "[SUCCESS] services initialized" -ForegroundColor Green
        Write-Host "API Base URL: $($apiConfig.BaseUrl)" -ForegroundColor White
        Write-Host "Authentication: $($apiConfig.Authentication.Type)" -ForegroundColor White
        
        return @{
            Logging = $loggingService
            Config = $configService
            Auth = $authService
            API = $apiService
            APIConfig = $apiConfig
        }
    }
    catch {
        Write-Error "Failed to initialize services: $_"
        throw $_
    }
}

function Test-Connection {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== CONNECTION TEST ===" -ForegroundColor Cyan
    
    try {
        # Test basic connectivity by trying the base URL
        $testUrl = $Services.APIConfig.BaseUrl.TrimEnd('/')
        $response = Invoke-WebRequest -Uri $testUrl -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            Write-Host "[SUCCESS] Connection successful" -ForegroundColor Green
            Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor White
            Write-Host "Server: $($response.Headers.Server -join ', ')" -ForegroundColor White
            return $true
        }
        else {
            Write-Host "[WARNING] Unexpected status code: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "[FAILED] Connection failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Invoke-ListItems {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== LIST ITEMS ===" -ForegroundColor Cyan
    
    try {
        $endpoint = $Services.APIConfig.Endpoints.ListItems
        if (-not $endpoint) {
            throw "ListItems endpoint not configured"
        }
        
        Write-Host "Requesting: $endpoint" -ForegroundColor Yellow
        $items = $Services.API.Get($endpoint.TrimStart('/'))
        
        Write-Host "[SUCCESS] Retrieved $(@($items).Count) items" -ForegroundColor Green
        
        # Show first few items as sample
        $sampleCount = [Math]::Min(3, @($items).Count)
        for ($i = 0; $i -lt $sampleCount; $i++) {
            $item = $items[$i]
            Write-Host "Sample Item $($i + 1):" -ForegroundColor White
            $item | ConvertTo-Json -Depth 2 -Compress | Write-Host -ForegroundColor Gray
        }
        
        return $items
    }
    catch {
        Write-Host "[FAILED] List items failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Invoke-GetItem {
    [CmdletBinding()]
    param([object]$Services, [int]$ItemId)
    
    Write-Host ""
    Write-Host "=== GET SINGLE ITEM ===" -ForegroundColor Cyan
    
    try {
        $endpoint = $Services.APIConfig.Endpoints.GetItem
        if (-not $endpoint) {
            throw "GetItem endpoint not configured"
        }
        
        # Replace {id} placeholder with actual ID
        $actualEndpoint = $endpoint -replace '\{id\}', $ItemId
        
        Write-Host "Requesting: $actualEndpoint" -ForegroundColor Yellow
        $item = $Services.API.Get($actualEndpoint.TrimStart('/'))
        
        Write-Host "[SUCCESS] Retrieved item ID $ItemId" -ForegroundColor Green
        $item | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
        
        return $item
    }
    catch {
        Write-Host "[FAILED] Get item failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Invoke-CreateItem {
    [CmdletBinding()]
    param([object]$Services)
    
    Write-Host ""
    Write-Host "=== CREATE ITEM ===" -ForegroundColor Cyan
    
    try {
        $endpoint = $Services.APIConfig.Endpoints.CreateItem
        if (-not $endpoint) {
            throw "CreateItem endpoint not configured"
        }
        
        # Use test data from configuration
        $testData = $Services.APIConfig.TestData.SampleItem
        if (-not $testData) {
            throw "TestData.SampleItem not configured"
        }
        
        Write-Host "Creating item at: $endpoint" -ForegroundColor Yellow
        Write-Host "Data:" -ForegroundColor White
        $testData | ConvertTo-Json -Depth 2 | Write-Host -ForegroundColor Gray
        
        $newItem = $Services.API.Post($endpoint.TrimStart('/'), $testData)
        
        Write-Host "[SUCCESS] Created item with ID: $($newItem.id)" -ForegroundColor Green
        $newItem | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
        
        return $newItem
    }
    catch {
        Write-Host "[FAILED] Create item failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Invoke-UpdateItem {
    [CmdletBinding()]
    param([object]$Services, [object]$ItemToUpdate)
    
    Write-Host ""
    Write-Host "=== UPDATE ITEM ===" -ForegroundColor Cyan
    
    if (-not $ItemToUpdate) {
        Write-Host "[WARNING] No item provided to update" -ForegroundColor Yellow
        return $null
    }
    
    try {
        $endpoint = $Services.APIConfig.Endpoints.UpdateItem
        if (-not $endpoint) {
            throw "UpdateItem endpoint not configured"
        }
        
        # Replace {id} placeholder
        $actualEndpoint = $endpoint -replace '\{id\}', $ItemToUpdate.id
        
        # Modify the item data
        $updatedData = $ItemToUpdate.PSObject.Copy()
        if ($updatedData.title) {
            $updatedData.title = "UPDATED: $($updatedData.title)"
        }
        if ($updatedData.body) {
            $updatedData.body = "UPDATED: $($updatedData.body)"
        }
        
        Write-Host "Updating item at: $actualEndpoint" -ForegroundColor Yellow
        $updatedItem = $Services.API.Put($actualEndpoint.TrimStart('/'), $updatedData)
        
        Write-Host "[SUCCESS] Updated item ID: $($updatedItem.id)" -ForegroundColor Green
        $updatedItem | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
        
        return $updatedItem
    }
    catch {
        Write-Host "[FAILED] Update item failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Invoke-DeleteItem {
    [CmdletBinding()]
    param([object]$Services, [object]$ItemToDelete)
    
    Write-Host ""
    Write-Host "=== DELETE ITEM ===" -ForegroundColor Cyan
    
    if (-not $ItemToDelete) {
        Write-Host "[WARNING] No item provided to delete" -ForegroundColor Yellow
        return $false
    }
    
    try {
        $endpoint = $Services.APIConfig.Endpoints.DeleteItem
        if (-not $endpoint) {
            throw "DeleteItem endpoint not configured"
        }
        
        # Replace {id} placeholder
        $actualEndpoint = $endpoint -replace '\{id\}', $ItemToDelete.id
        
        Write-Host "Deleting item at: $actualEndpoint" -ForegroundColor Yellow
        $result = $Services.API.Delete($actualEndpoint.TrimStart('/'))
        
        Write-Host "[SUCCESS] Deleted item ID: $($ItemToDelete.id)" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "[FAILED] Delete item failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Invoke-CustomAPICall {
    [CmdletBinding()]
    param([object]$Services, [string]$Endpoint, [string]$Method, [string]$Body)
    
    Write-Host ""
    Write-Host "=== CUSTOM API CALL ===" -ForegroundColor Cyan
    
    try {
        Write-Host "Method: $Method" -ForegroundColor White
        Write-Host "Endpoint: $Endpoint" -ForegroundColor White
        
        $result = switch ($Method.ToUpper()) {
            'GET' { $Services.API.Get($Endpoint.TrimStart('/')) }
            'POST' { 
                $bodyObject = if ($Body) { $Body | ConvertFrom-Json } else { @{} }
                $Services.API.Post($Endpoint.TrimStart('/'), $bodyObject) 
            }
            'PUT' {
                $bodyObject = if ($Body) { $Body | ConvertFrom-Json } else { @{} }
                $Services.API.Put($Endpoint.TrimStart('/'), $bodyObject)
            }
            'DELETE' { $Services.API.Delete($Endpoint.TrimStart('/')) }
            default { throw "Unsupported method: $Method" }
        }
        
        Write-Host "[SUCCESS] Custom API call successful" -ForegroundColor Green
        $result | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
        
        return $result
    }
    catch {
        Write-Host "[FAILED] Custom API call failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Show-Summary {
    [CmdletBinding()]
    param([hashtable]$Results)
    
    Write-Host ""
    Write-Host "=== API CLIENT SUMMARY ===" -ForegroundColor Green
    
    $totalOperations = $Results.Count
    $successfulOperations = ($Results.Values | Where-Object { $_ -ne $null -and $_ -ne $false }).Count
    $successRate = if ($totalOperations -gt 0) { [math]::Round(($successfulOperations / $totalOperations) * 100, 1) } else { 0 }
    
    Write-Host "Total Operations: $totalOperations" -ForegroundColor White
    Write-Host "Successful: $successfulOperations" -ForegroundColor Green
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { 'Green' } else { 'Yellow' })
    
    Write-Host ""
    foreach ($result in $Results.GetEnumerator()) {
        $status = if ($result.Value -ne $null -and $result.Value -ne $false) { "[SUCCESS]" } else { "[FAILED]" }
        $color = if ($result.Value -ne $null -and $result.Value -ne $false) { "Green" } else { "Red" }
        Write-Host "$($result.Key): $status" -ForegroundColor $color
    }
    
    if ($successRate -eq 100) {
        Write-Host ""
        Write-Host "SUCCESS - API ORCHESTRATION PROVEN!" -ForegroundColor Green
        Write-Host "This framework can orchestrate ANY REST API!" -ForegroundColor Green
    }
}

# Main execution
try {
    # Initialize the service framework
    $services = Initialize-Services -ConfigName $ConfigName -LogLevel $LogLevel
    $results = @{}
    
    # Execute requested operations
    if ($TestConnection -or $RunAllTests) {
        $results['Connection Test'] = Test-Connection -Services $services
    }
    
    if ($ListItems -or $RunAllTests) {
        $items = Invoke-ListItems -Services $services
        $results['List Items'] = ($items -ne $null)
    }
    
    if ($GetItem -or $RunAllTests) {
        $item = Invoke-GetItem -Services $services -ItemId $ItemId
        $results['Get Item'] = ($item -ne $null)
    }
    
    $createdItem = $null
    if ($CreateItem -or $RunAllTests) {
        $createdItem = Invoke-CreateItem -Services $services
        $results['Create Item'] = ($createdItem -ne $null)
    }
    
    if ($UpdateItem -or $RunAllTests) {
        # Use created item or fetch item for update
        $itemToUpdate = if ($createdItem) { $createdItem } else { Invoke-GetItem -Services $services -ItemId $ItemId }
        $updatedItem = Invoke-UpdateItem -Services $services -ItemToUpdate $itemToUpdate
        $results['Update Item'] = ($updatedItem -ne $null)
    }
    
    if ($DeleteItem -or $RunAllTests) {
        # Use created item or fetch item for deletion
        $itemToDelete = if ($createdItem) { $createdItem } else { Invoke-GetItem -Services $services -ItemId $ItemId }
        $deleteResult = Invoke-DeleteItem -Services $services -ItemToDelete $itemToDelete
        $results['Delete Item'] = $deleteResult
    }
    
    if ($CustomEndpoint) {
        $customResult = Invoke-CustomAPICall -Services $services -Endpoint $CustomEndpoint -Method $Method -Body $Body
        $results['Custom API Call'] = ($customResult -ne $null)
    }
    
    # Default: run all tests if no specific operation requested
    if (-not ($TestConnection -or $ListItems -or $GetItem -or $CreateItem -or $UpdateItem -or $DeleteItem -or $CustomEndpoint)) {
        Write-Host "No specific operation requested - running all tests" -ForegroundColor Yellow
        
        $results['Connection Test'] = Test-Connection -Services $services
        $items = Invoke-ListItems -Services $services
        $results['List Items'] = ($items -ne $null)
        $item = Invoke-GetItem -Services $services -ItemId $ItemId
        $results['Get Item'] = ($item -ne $null)
        $createdItem = Invoke-CreateItem -Services $services
        $results['Create Item'] = ($createdItem -ne $null)
        $updatedItem = Invoke-UpdateItem -Services $services -ItemToUpdate $createdItem
        $results['Update Item'] = ($updatedItem -ne $null)
        $deleteResult = Invoke-DeleteItem -Services $services -ItemToDelete $createdItem
        $results['Delete Item'] = $deleteResult
    }
    
    # Show summary if we ran any operations
    if ($results.Count -gt 0) {
        Show-Summary -Results $results
    }
    
    Write-Host ""
    Write-Host "Complete - API Client execution complete!" -ForegroundColor Green
}
catch {
    Write-Error "API Client failed: $_"
    exit 1
}