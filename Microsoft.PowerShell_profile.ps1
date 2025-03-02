# Microsoft.PowerShell_profile.ps1

#region Configuration and Setup
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.psd1'

# Load configuration file
if (Test-Path $ConfigPath) {
    $Config = Import-PowerShellDataFile -Path $ConfigPath
    Write-Host "Configuration loaded" -ForegroundColor Green
} else {
    Write-Warning "Configuration file not found. Using defaults."
    $Config = @{ CommonPaths = @{}; UrlCollections = @{} }
}

# Initialize paths from config
$CommonPaths = @{}
foreach ($key in $Config.CommonPaths.Keys) {
    $pathValue = $Config.CommonPaths[$key]
    if ($pathValue -is [string]) {
        $pathValue = $ExecutionContext.InvokeCommand.ExpandString($pathValue)
    }
    $CommonPaths[$key] = $pathValue
}

# Initialize URL collections from config
$UrlCollections = @{}
if ($Config.UrlCollections) {
    foreach ($key in $Config.UrlCollections.Keys) {
        $UrlCollections[$key] = $Config.UrlCollections[$key]
    }
}

# Set working directory
try {
    Set-Location $CommonPaths.PowerShell
} catch {
    Set-Location $HOME
}

#region Module Management
function Import-RequiredModule {
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose
    )
    
    try {
        if (-not (Get-Module -Name $Name -ListAvailable)) {
            Install-Module -Name $Name -Scope CurrentUser -Force
        }
        Import-Module -Name $Name -ErrorAction Stop
    } catch {
        Write-Warning "Failed to import module: $Name. Error: $_"
    }
}

# Import modules if in console host
if ($host.Name -eq 'ConsoleHost' -and $Config.RequiredModules) {
    foreach ($module in $Config.RequiredModules) {
        Import-RequiredModule -Name $module.Name -Purpose $module.Purpose
    }
}

#region Custom Scripts
$CommonPaths.Scripts = $env:PS_SCRIPTS_PATH ?? (Join-Path $CommonPaths.PowerShell "Scripts")

function Import-CustomScript {
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose
    )
    
    # Ensure Scripts directory exists
    if (-not (Test-Path $CommonPaths.Scripts)) {
        New-Item -Path $CommonPaths.Scripts -ItemType Directory -Force | Out-Null
    }
    
    try {
        $scriptPath = Join-Path $CommonPaths.Scripts $Name
        if (Test-Path $scriptPath) {
            . $scriptPath
        } else {
            Write-Warning "Script not found: $scriptPath"
        }
    } catch {
        Write-Warning "Failed to load script: $Name"
    }
}

# Load custom scripts
if ($Config.CustomScripts) {
    foreach ($script in $Config.CustomScripts) {
        Import-CustomScript -Name $script.Name -Purpose $script.Purpose
    }
}

#region Utility Functions
# Generate GUID
function Get-Guid { [guid]::NewGuid().ToString() }

# Enhanced PSModulePath management
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

# Function to create new module
function New-PowerShellModule {
    [Alias('addmodule')]
    param ([string]$ModuleName = $(Read-Host "Enter module name"))
    
    try {
        $modulePath = Join-Path $CommonPaths.Documents "PowerShell\Modules\$ModuleName"
        New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
        Update-ModulePath -Add -Path $modulePath
    } catch {
        Write-Error "Failed to create module: $_"
    }
}

# Profile reload function
function Update-PowerShellProfile {
    [Alias('reload')]
    param()
    . $PROFILE
    Write-Host "Profile reloaded" -ForegroundColor Green
}

# Enhanced prompt with admin warning
function prompt {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    
    $prefix = if ($principal.IsInRole($adminRole)) {
        Write-Host "[ADMIN]" -NoNewline -ForegroundColor Red
        ": "
    } else { '' }
    
    Write-Host "PS " -NoNewline
    Write-Host "$(Get-Location)" -NoNewline -ForegroundColor Blue
    "$prefix> "
}

#region URL Functions
function Open-Urls {
    param (
        [Parameter(Mandatory = $true)][string[]]$Urls,
        [string]$Message = "Opened URLs"
    )
    foreach ($url in $Urls) {
        if ($url -match '^https?://') {
            Start-Process $url
        }
    }
    Write-Host $Message -ForegroundColor Green
}
# URL Collection Functions
function gally { Start-Process "https://www.powershellgallery.com/packages/" }
function Aio { Open-Urls -Urls $UrlCollections.AiSites -Message "Opened AI sites" }
function mysocial { Open-Urls -Urls $UrlCollections.SocialSites -Message "Opened social sites" }
function Stocks { Open-Urls -Urls $UrlCollections.StockSites -Message "Opened stock sites" }
function learnsite { Open-Urls -Urls $UrlCollections.LearningSites -Message "Opened Web Learning sites" }
function gitsites { Open-Urls -Urls $UrlCollections.GitSites -Message "Opened Git related sites" }
function cloudsite { Open-Urls -Urls $UrlCollections.CloudSites -Message "Opened CloudSites" }
function devsites { Open-Urls -Urls $UrlCollections.DeveloperSites -Message "Opened DeveloperSites" }
function learndev { Open-Urls -Urls $UrlCollections.LearnWebDev -Message "Opened Learn WebDeveloper" }
function newssites { Open-Urls -Urls $UrlCollections.NewsSites -Message "Opened Learn WebDeveloper" }

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

#region Aliases
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name reload -Value Update-PowerShellProfile

#region Ect.

# Admin check
if ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "PowerShell is running with Administrator privileges"
}

# Welcome message
function Show-Welcome {
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "Welcome to PowerShell! $Date" -ForegroundColor Cyan
}

Show-Welcome
$ProfileStartTime = Get-Date
$ProfileLoadTime = (Get-Date) - $ProfileStartTime
Write-Host "Profile loaded in $($ProfileLoadTime.TotalMilliseconds) ms" -ForegroundColor Cyan


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

# Function to update all packages
function Update-AllPackages {
    Write-Host "Updating all installed packages..." -ForegroundColor Yellow
    winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
}

function Install-RequiredModule {
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose,
        [string]$Version
    )
    
    try {
        if (-not (Get-Module -Name $Name -ListAvailable)) {
            if ($Version) {
                Install-Module -Name $Name -RequiredVersion $Version -Scope CurrentUser -Force
            } else {
                Install-Module -Name $Name -Scope CurrentUser -Force
            }
        }
        Import-Module -Name $Name -ErrorAction Stop
    } catch {
        Write-Warning "Failed to import module: $Name. Error: $_"
    }
}

 function Remove-UnusedModules {
    $installedModules = Get-InstalledModule
    $usedModules = Get-Module | Select-Object -ExpandProperty Name
    $unusedModules = $installedModules | Where-Object { $_.Name -notin $usedModules }
    
    if ($unusedModules) {
        $unusedModules | ForEach-Object {
            Write-Host "Removing unused module: $($_.Name)" -ForegroundColor Yellow
            Uninstall-Module -Name $_.Name -Force
        }
    } else {
        Write-Host "No unused modules found." -ForegroundColor Green
    }
}
 function Update-CustomScripts {
    param (
        [string]$RepoUrl = "https://github.com/your-repo/scripts"
    )
    
    try {
        $tempDir = Join-Path $env:TEMP "ScriptUpdates"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        New-Item -Path $tempDir -ItemType Directory | Out-Null
        
        Invoke-WebRequest -Uri "$RepoUrl/archive/main.zip" -OutFile "$tempDir\scripts.zip"
        Expand-Archive -Path "$tempDir\scripts.zip" -DestinationPath $tempDir -Force
        
        $scriptsDir = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
        Copy-Item -Path "$($scriptsDir.FullName)\*" -Destination $CommonPaths.Scripts -Recurse -Force
        
        Write-Host "Custom scripts updated successfully." -ForegroundColor Green
    } catch {
        Write-Error "Failed to update custom scripts: $_"
    } finally {
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

function Install-ConfiguredPackages {
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed or not available in PATH"
        return
    }
    
    if (-not $Config.WingetPackages) {
        Write-Warning "No Winget packages configured in config.psd1"
        return
    }
    
    $packageCount = $Config.WingetPackages.Count
    
    if (-not $SkipConfirmation) {
        $confirmation = Read-Host "This will install/update $packageCount packages. Continue? (Y/N)"
        if ($confirmation -ne 'Y') {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            return
        }
    }
    
    $successful = 0
    $failed = 0
    
    foreach ($package in $Config.WingetPackages) {
        $id = $package.Id
        $scope = $package.Scope ?? "user"
        
        try {
            Write-Host "Processing package: $id" -ForegroundColor Cyan
            
            # Check if package is already installed
            $isInstalled = winget list --id $id --exact
            
            if ($isInstalled -match $id -and -not $Force) {
                Write-Host "Updating $id..." -ForegroundColor Yellow
                winget upgrade --id $id --silent --accept-package-agreements --accept-source-agreements
            } else {
                Write-Host "Installing $id..." -ForegroundColor Cyan
                winget install --id $id --scope $scope --silent --accept-package-agreements --accept-source-agreements
            }
            
            $successful++
        } catch {
            Write-Host "Failed to install/update $id`: $_" -ForegroundColor Red
            $failed++
        }
    }
    
    Write-Host "Package installation complete. Successful: $successful, Failed: $failed" -ForegroundColor Green
}

function Show-Welcome {
    [CmdletBinding()]
    param()
    
    $TColor = "Cyan"
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "Welcome to PowerShell! Today is $Date" -ForegroundColor $TColor
    $Logo = @"
 ___ _             ____  _       _ _        _      
|_ _( )_ __ ___   |  _ \(_) __ _(_) |_ __ _| |     
 | ||/| '_ ` _ \  | | | | |/ _` | | __/ _` | |     
 | |  | | | | | | | |_| | | (_| | | || (_| | |     
|___| |_| |_| |_| |____/|_|\__, |_|\__\__,_|_|____ 
                          |___/            |_____|
"@
    
    Write-Host $Logo -ForegroundColor $TColor

}
Show-Welcome
$ProfileStartTime = Get-Date
# ... (rest of the profile script)
$ProfileLoadTime = (Get-Date) - $ProfileStartTime
Write-Host "Profile loaded in $($ProfileLoadTime.TotalMilliseconds) ms" -ForegroundColor Cyan
