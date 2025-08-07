# CredentialService.ps1
# Consolidated credential management service following Single Responsibility Principle
# Replaces multiple credential management classes with one cohesive implementation

class CredentialService {
    hidden [string] $credentialBasePath
    hidden [object] $logger
    hidden [object] $memoryCache

    # Constructor with dependency injection
    CredentialService([string] $basePath, [object] $loggingService) {
        if ([string]::IsNullOrWhiteSpace($basePath)) {
            throw "Base path cannot be null or empty"
        }

        $this.credentialBasePath = $basePath
        $this.logger = $loggingService
        $this.memoryCache = [PSCustomObject]@{}

        # Ensure credentials directory exists
        $this.EnsureCredentialDirectory()
    }

    # Ensure credential directory exists (Single Responsibility)
    hidden [void] EnsureCredentialDirectory() {
        try {
            if (-not (Test-Path $this.credentialBasePath)) {
                if ($this.logger) {
                    $this.logger.LogInfo("Creating credentials directory: $($this.credentialBasePath)", "Credential")
                }
                New-Item -Path $this.credentialBasePath -ItemType Directory -Force | Out-Null
            }
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to create credential directory")
            }
            throw "Failed to create or access credential directory: $($this.credentialBasePath)"
        }
    }

    # Get standardised file path for NSX manager credentials
    hidden [string] GetCredentialFilePath([string] $nsxManager) {
        $safeName = $nsxManager.Replace('.', '_').Replace(':', '_').Replace('/', '_')
        return Join-Path $this.credentialBasePath "$safeName.cred"
    }

    # Save encrypted credentials to file
    [bool] SaveCredentials([string] $nsxManager, [PSCredential] $credential) {
        try {
            # Don't save current user credentials (they're not real credentials)
            if ($credential.GetNetworkCredential().Password -eq "CURRENT_USER_CONTEXT") {
                if ($this.logger) {
                    $this.logger.LogInfo("Skipping save for current user credential context", "Credential")
                }
                return $true
            }

            $filePath = $this.GetCredentialFilePath($nsxManager)
            if ($this.logger) {
                $this.logger.LogInfo("Saving encrypted credentials for $nsxManager", "Credential")
            }

            $credential | Export-Clixml -Path $filePath -Force

            # Cache in memory for current session - replace hash table assignment with PSCustomObject property addition
            $this.memoryCache | Add-Member -NotePropertyName $nsxManager -NotePropertyValue $credential -Force

            if ($this.logger) {
                $this.logger.LogInfo("Credentials saved successfully for $nsxManager", "Credential")
            }
            return $true
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to save credentials for $nsxManager")
            }
            return $false
        }
    }

    # Load encrypted credentials from file
    [PSCredential] LoadCredentials([string] $nsxManager) {
        try {
            # Check memory cache first - replace hash table indexing with PSCustomObject property access
            if ((Get-Member -InputObject $this.memoryCache -Name $nsxManager -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
                if ($this.logger) {
                    $this.logger.LogDebug("Loading credentials from memory cache for $nsxManager", "Credential")
                }
                return $this.memoryCache.$nsxManager
            }

            $filePath = $this.GetCredentialFilePath($nsxManager)
            if (-not (Test-Path $filePath)) {
                if ($this.logger) {
                    $this.logger.LogDebug("No saved credentials found for $nsxManager", "Credential")
                }
                return $null
            }

            if ($this.logger) {
                $this.logger.LogInfo("Loading encrypted credentials for $nsxManager", "Credential")
            }

            $credential = Import-Clixml -Path $filePath

            # Cache in memory - replace hash table assignment with PSCustomObject property addition
            $this.memoryCache | Add-Member -NotePropertyName $nsxManager -NotePropertyValue $credential -Force

            return $credential
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to load credentials for $nsxManager")
            }
            return $null
        }
    }

    # Load credentials from custom file path
    [PSCredential] LoadCredentialsFromFile([string] $filePath) {
        try {
            if (-not (Test-Path $filePath)) {
                if ($this.logger) {
                    $this.logger.LogWarning("Credential file not found: $filePath", "Credential")
                }
                return $null
            }

            if ($this.logger) {
                $this.logger.LogInfo("Loading credentials from custom file: $filePath", "Credential")
            }

            return Import-Clixml -Path $filePath
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to load credentials from file: $filePath")
            }
            return $null
        }
    }

    # Check if credentials exist for NSX manager
    [bool] HasCredentials([string] $nsxManager) {
        # Replace hash table indexing with PSCustomObject property access
        return ((Get-Member -InputObject $this.memoryCache -Name $nsxManager -MemberType NoteProperty -ErrorAction SilentlyContinue) -or (Test-Path $this.GetCredentialFilePath($nsxManager)))
    }

    # Remove credentials for NSX manager
    [bool] RemoveCredentials([string] $nsxManager) {
        try {
            $filePath = $this.GetCredentialFilePath($nsxManager)

            # Remove from memory cache - replace hash table access with PSCustomObject property removal
            if ((Get-Member -InputObject $this.memoryCache -Name $nsxManager -MemberType NoteProperty -ErrorAction SilentlyContinue)) {
                $this.memoryCache.PSObject.Properties.Remove($nsxManager)
            }

            # Remove file if it exists
            if (Test-Path $filePath) {
                Remove-Item -Path $filePath -Force
                if ($this.logger) {
                    $this.logger.LogInfo("Removed stored credentials for $nsxManager", "Credential")
                }
            }

            return $true
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to remove credentials for $nsxManager")
            }
            return $false
        }
    }

    # List all stored credential managers
    [string[]] ListStoredManagers() {
        try {
            $credFiles = Get-ChildItem -Path $this.credentialBasePath -Filter "*.cred" -ErrorAction SilentlyContinue
            return $credFiles | ForEach-Object { $_.BaseName.Replace('_', '.') }
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to list stored credential managers")
            }
            return @()
        }
    }

    # Create current user credential context
    [PSCredential] CreateCurrentUserCredentials() {
        try {
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            # Use empty secure string for current user context - Windows handles authentication
            $securePassword = [System.Security.SecureString]::new()
            return [PSCredential]::new($currentUser.Name, $securePassword)
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to create current user credential context")
            }
            return $null
        }
    }

    # Clear all cached credentials
    [void] ClearCache() {
        $this.memoryCache.Clear()
        if ($this.logger) {
            $this.logger.LogInfo("Cleared credential memory cache", "Credential")
        }
    }

    # List stored credentials with metadata (compatibility method)
    [object[]] ListStoredCredentials() {
        try {
            $credFiles = Get-ChildItem -Path $this.credentialBasePath -Filter "*.cred" -ErrorAction SilentlyContinue
            $results = @()

            foreach ($file in $credFiles) {
                try {
                    $nsxManager = $file.BaseName.Replace('_', '.')
                    $credential = Import-Clixml -Path $file.FullName

                    # Mask username for security (only show first 2 chars + ***)
                    $maskedUsername = if ($credential.UserName.Length -gt 2) {
                        $credential.UserName.Substring(0, 2) + "***"
                    }
                    else {
                        "***"
                    }

                    $results += [PSCustomObject]@{
                        NSXManager = $nsxManager
                        Username   = $maskedUsername
                        Created    = $file.CreationTime
                        Modified   = $file.LastWriteTime
                        FilePath   = $file.FullName
                    }
                }
                catch {
                    if ($this.logger) {
                        $this.logger.LogWarning("Failed to read credential file: $($file.Name)", "Credential")
                    }
                }
            }

            return $results
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to list stored credentials")
            }
            return @()
        }
    }

    # Show credential storage information
    [void] ShowCredentialStorageInfo() {
        Write-Host ""
        Write-Host "=== NSX CREDENTIAL STORAGE INFORMATION ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Storage Directory: $($this.credentialBasePath)" -ForegroundColor White
        Write-Host "Directory Exists: $(Test-Path $this.credentialBasePath)" -ForegroundColor White

        $credFiles = Get-ChildItem -Path $this.credentialBasePath -Filter "*.cred" -ErrorAction SilentlyContinue
        Write-Host "Total Credential Files: $($credFiles.Count)" -ForegroundColor White

        if ($credFiles.Count -gt 0) {
            Write-Host ""
            Write-Host "Stored Credentials:" -ForegroundColor Yellow
            foreach ($file in $credFiles) {
                $nsxManager = $file.BaseName.Replace('_', '.')
                $sizeKB = [math]::Round($file.Length / 1KB, 2)
                Write-Host "  - $nsxManager ($sizeKB KB, Modified: $($file.LastWriteTime.ToString('yyyy-MM-dd HH:mm')))" -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "Memory Cache:" -ForegroundColor Yellow
        Write-Host "  Cached Managers: $($this.memoryCache.Count)" -ForegroundColor White
        if ($this.memoryCache.Count -gt 0) {
            foreach ($key in $this.memoryCache.Keys) {
                Write-Host "    - $key" -ForegroundColor Gray
            }
        }
    }

    # Clear credentials for specific manager (compatibility method)
    [bool] ClearCredentials([string] $nsxManager) {
        return $this.RemoveCredentials($nsxManager)
    }

    # Clear all stored credentials
    [bool] ClearAllCredentials() {
        try {
            $credFiles = Get-ChildItem -Path $this.credentialBasePath -Filter "*.cred" -ErrorAction SilentlyContinue
            $successCount = 0
            $totalCount = $credFiles.Count

            foreach ($file in $credFiles) {
                try {
                    Remove-Item -Path $file.FullName -Force
                    $successCount++
                }
                catch {
                    if ($this.logger) {
                        $this.logger.LogWarning("Failed to remove credential file: $($file.Name)", "Credential")
                    }
                }
            }

            # Clear memory cache
            $this.ClearCache()

            if ($this.logger) {
                $this.logger.LogInfo("Cleared $successCount of $totalCount credential files", "Credential")
            }

            return ($successCount -eq $totalCount)
        }
        catch {
            if ($this.logger) {
                $this.logger.LogException($_.Exception, "Failed to clear all credentials")
            }
            return $false
        }
    }

    # Show interactive credential management menu
    [void] ShowCredentialManagementMenu() {
        Write-Host ""
        Write-Host "=== INTERACTIVE CREDENTIAL MANAGEMENT ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Available stored credentials:" -ForegroundColor Yellow

        $credentials = $this.ListStoredCredentials()
        if ($credentials.Count -eq 0) {
            Write-Host "  No stored credentials found." -ForegroundColor Gray
        }
        else {
            $credentials | Format-Table -Property NSXManager, Username, [PSCustomObject]@ { Name = "Modified"; Expression = { $_.Modified.ToString("yyyy-MM-dd HH:mm") } } -AutoSize
        }

        Write-Host ""
        Write-Host "Interactive menu functionality requires additional implementation." -ForegroundColor Yellow
        Write-Host "Use command-line parameters for now:" -ForegroundColor White
        Write-Host "  -ListOnly                List all stored credentials" -ForegroundColor Gray
        Write-Host "  -ClearSpecific <manager> Clear specific manager credentials" -ForegroundColor Gray
        Write-Host "  -ClearAll                Clear all stored credentials" -ForegroundColor Gray
        Write-Host "  -ShowInfo                Show storage information" -ForegroundColor Gray
    }
}
