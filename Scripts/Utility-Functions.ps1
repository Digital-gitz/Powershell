#region Utility Functions
function Get-Guid { [guid]::NewGuid().ToString() }

function Update-ModulePath {
    [Alias('modpath')]
    param (
        [switch]$Formatted,
        [switch]$Add,
        [string]$Path
    )
    
    if ($Add -and $Path -and (Test-Path $Path)) {
        $env:PSModulePath = "$Path;$env:PSModulePath"
    }
    
    $paths = $env:PSModulePath -split ';'
    if ($Formatted) {
        $paths | ForEach-Object { Write-Host "- $_" -ForegroundColor Cyan }
    } else {
        $paths
    }
}

Update-ModulePath

# Profile reload function
function Update-PowerShellProfile {
    [CmdletBinding()]
    [Alias('reload')]
    param(
        [switch]$SkipConfirmation,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$IgnoredArguments
    )
    
    if (-not $SkipConfirmation) {
        Write-Host "Reloading PowerShell profile..."
    }
    
    try {
        . $PROFILE
        Write-Host "Profile reloaded successfully" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Failed to reload profile: $_"
        return $false
    }
}

# Function to install or update a package
function Install-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [string]$Scope = "user"
    )
    
    $result = winget list --id $PackageId --exact
    
    if ($result -match $PackageId) {
        Write-Host "Updating $PackageId..." 
        winget upgrade --id $PackageId --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "Installing $PackageId..." 
        winget install --id $PackageId --scope $Scope --silent --accept-package-agreements --accept-source-agreements
    }
}

# Add this function to your profile script
function Install-ConfiguredPackages {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Category,
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed or not available in PATH"
        return
    }
    
    $packages = if ($Category) {
        if ($Config.WingetPackages.ContainsKey($Category)) {
            $Config.WingetPackages[$Category]
        } else {
            Write-Error "Category '$Category' not found. Available categories: $($Config.WingetPackages.Keys -join ', ')"
            return
        }
    } else {
        $Config.WingetPackages.Values | ForEach-Object { $_ }
    }
    
    $packageCount = $packages.Count
    
    if (-not $SkipConfirmation) {
        $message = if ($Category) {
            "This will install/update $packageCount packages from category '$Category'"
        } else {
            "This will install/update $packageCount packages from all categories"
        }
        $confirmation = Read-Host "$message. Continue? (Y/N)"
        if ($confirmation -ne 'Y') {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            return
        }
    }
    
    $successful = 0
    $failed = 0
    
    foreach ($package in $packages) {
        $id = $package.Id
        $scope = $package.Scope ?? "user"
        
        try {
            Write-Host "Processing package: $id" -ForegroundColor Cyan
            Install-Package -PackageId $id -Scope $scope -Force:$Force
            $successful++
        } catch {
            Write-Host "Failed to install/update $id`: $_" -ForegroundColor Red
            $failed++
        }
    }
    
    Write-Host "Package installation complete. Successful: $successful, Failed: $failed" -ForegroundColor Green
}


#region PSReadLine Configuration
if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    if ($Config.PSReadLine) {
        # Apply PSReadLine settings from config
        if ($Config.PSReadLine.ShowToolTips) { Set-PSReadLineOption -ShowToolTips }
        if ($Config.PSReadLine.PredictionSource) { Set-PSReadLineOption -PredictionSource $Config.PSReadLine.PredictionSource }
        if ($Config.PSReadLine.PredictionViewStyle) { Set-PSReadLineOption -PredictionViewStyle $Config.PSReadLine.PredictionViewStyle }
        if ($Config.PSReadLine.EditMode) { Set-PSReadLineOption -EditMode $Config.PSReadLine.EditMode }
    }
    
    # Custom key handlers
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

function Initialize-PSReadLine {
    if (-not (Get-Module PSReadLine)) { return }
    
    $defaultConfig = @{
        ShowToolTips = $true
        PredictionSource = "History"
        PredictionViewStyle = "ListView"
        EditMode = "Windows"
    }
    
    $config = $Config.PSReadLine ?? $defaultConfig
    
    foreach ($option in $config.GetEnumerator()) {
        switch ($option.Key) {
            'Colors' {
                foreach ($color in $option.Value.GetEnumerator()) {
                    Set-PSReadLineOption -Colors @{$color.Key = $color.Value}
                }
            }
            'KeyBindings' {
                foreach ($binding in $option.Value.GetEnumerator()) {
                    Set-PSReadLineKeyHandler -Chord $binding.Key -Function $binding.Value
                }
            }
            default {
                Set-PSReadLineOption -$($option.Key) $option.Value
            }
        }
    }
    

function Import-EnvironmentSpecificConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ConfigDir = (Join-Path $PSScriptRoot "Environments")
    )
    
    # Determine environment
    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $domain = $env:USERDOMAIN
    $osVersion = [System.Environment]::OSVersion.Version
    
    # Possible config files to look for
    $configFiles = @(
        # Computer-specific config
        "$ConfigDir\computer-$computerName.psd1",
        # User-specific config
        "$ConfigDir\user-$userName.psd1",
        # Domain-specific config
        "$ConfigDir\domain-$domain.psd1",
        # OS-specific config (Windows 10/11)
        "$ConfigDir\os-win$($osVersion.Major).psd1"
    )
    
    $loadedConfigs = @()
    
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            try {
                $envConfig = Import-PowerShellDataFile -Path $file -ErrorAction Stop
                
                # Merge with main config
                foreach ($key in $envConfig.Keys) {
                    if ($Config.ContainsKey($key) -and $Config[$key] -is [hashtable] -and $envConfig[$key] -is [hashtable]) {
                        # Merge hashtables
                        foreach ($subKey in $envConfig[$key].Keys) {
                            $Config[$key][$subKey] = $envConfig[$key][$subKey]
                        }
                    }
                    else {
                        # Replace/add key
                        $Config[$key] = $envConfig[$key]
                    }
                }
                
                $loadedConfigs += (Split-Path -Path $file -Leaf)
                Write-Host "Loaded environment config: $(Split-Path -Path $file -Leaf)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to load environment config $file`: $_"
            }
        }
    }
    
    # Create the directory if it doesn't exist
    if (-not (Test-Path $ConfigDir)) {
        New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
        Write-Host "Created environments directory: $ConfigDir" -ForegroundColor Green
    }
    
    return $loadedConfigs
}

    # Standard key bindings
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}
