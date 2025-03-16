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
        [switch]$SkipConfirmation
    )
    
    if (-not $SkipConfirmation) {
        Write-Host "Reloading PowerShell profile..."
    }
    
    try {
        . $PROFILE
        Write-Host "Profile reloaded successfully"
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
        Write-Host "Updating $PackageId..." -ForegroundColor Yellow
        winget upgrade --id $PackageId --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "Installing $PackageId..." -ForegroundColor Cyan
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


# Set basic aliases
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name reload -Value Update-PowerShellProfile 