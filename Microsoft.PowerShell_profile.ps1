# Microsoft.PowerShell_profile.ps1

#region Script Configuration
<#
.SYNOPSIS
Enhanced PowerShell profile script with improved organization and functionality.

.DESCRIPTION
A comprehensive PowerShell profile that provides:
- Custom prompt and console customization
- Utility functions and aliases
- Module management and environment setup
- Directory navigation shortcuts
- GitHub integration

.NOTES
Author: Svyatoslav Oleg Russkiy
Last Updated: 2025
Version: 2.0
debug 
$DebugMode = $true
function Write-DebugLog {
    param ([string]$Message)
    if ($DebugMode) {
        Write-Host "[DEBUG] $Message" -ForegroundColor Gray
    }
}
to list all user scripts use the following command:
Get-ChildItem $scriptsPath  # Should show Install-OrUpdateModule.ps1

?For whatever reason User scripts are not loading need to load then in manualy.
?need to figure out how to load all user scripts in the profile.
$scriptPath = Join-Path $CommonPaths.Scripts "$someScript.ps1"

#>



#region Environment Setup
# Update WSL
wsl --update

# Common paths initialization
$CommonPaths = @{
    Home      = [System.Environment]::GetFolderPath('UserProfile')
    Documents = [System.Environment]::GetFolderPath('MyDocuments')
    Desktop   = [System.Environment]::GetFolderPath('Desktop')
    Downloads = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'Downloads')
    Pictures  = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'Pictures')
    PowerShell = (Join-Path -Path ([System.Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell')
    GitHub    = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'GitHub')
    Scripts   = (Join-Path -Path ([System.Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell\Scripts')
}

# Initialize working directory
Set-Location $CommonPaths.PowerShell

#region Module Management
# Required modules with their purposes
$RequiredModules = @(
    @{Name = 'PSReadLine'; Purpose = 'Enhanced command line editing'},
    @{Name = 'posh-git'; Purpose = 'Git integration'},
    @{Name = 'GitIgnores'; Purpose = 'Git ignore templates'},
    @{Name = 'Terminal-Icons'; Purpose = 'File and folder icons'},
    @{Name = 'z'; Purpose = 'Directory jumping'},
    @{Name = 'AWS.Tools.Common'; Purpose = 'AWS CLI integration'},
    @{Name = 'ImportExcel'; Purpose = 'Excel manipulation'},
    @{Name = 'PackageManagement'; Purpose = 'Package management'},
    @{Name = 'PSFzf'; Purpose = 'Fuzzy finder'},
    # @{Name = 'Navigation'; Purpose = 'Ease of Navigation to various directories and paths'},
    # @{Name = 'BuildRepo'; Purpose = 'Module for building repositories using various build systems'},
    @{Name = 'PowerShellGet'; Purpose = 'PowerShell module management'}
)

# Module import function with error handling
function Import-RequiredModule {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Purpose
    )
    
    try {
        if (-not (Get-Module -Name $Name -ListAvailable)) {
            Write-Host "Installing module: $Name ($Purpose)..." -ForegroundColor Yellow
            Install-Module -Name $Name -Scope CurrentUser -Force -AllowClobber
        }
        Import-Module -Name $Name -ErrorAction Stop
        Write-Host "Successfully imported: $Name" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to import module: $Name. Error: $_"
    }
}

# Import modules if in console host
if ($host.Name -eq 'ConsoleHost') {
    foreach ($module in $RequiredModules) {
        Import-RequiredModule -Name $module.Name -Purpose $module.Purpose
    }
}

$CommonPaths.Scripts = $env:PS_SCRIPTS_PATH ?? (Join-Path $CommonPaths.PowerShell "Scripts")

# Define and load custom scripts
$CustomScripts = @(
    @{Name = 'Install-OrUpdateModule.ps1'; Purpose = 'Install or update module functions'},
    @{Name = 'Navigation.ps1'; Purpose = 'Navigation functions'},
    @{Name = 'GitHub.ps1'; Purpose = 'GitHub integration functions'},
    @{Name = 'PNGtoVECTOR.ps1'; Purpose = 'PNG conversion utilities'},
    @{Name = 'UtilityFunctions.aiUpdate.ps1'; Purpose = 'General utility functions'},
    @{Name = 'SystemInfo.ps1'; Purpose = 'System information functions'},
    @{Name = 'FileManagement.ps1'; Purpose = 'File management utilities'}
    )
    #Define common paths dynamically

# Function to import custom scripts
function Import-CustomScript {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Purpose
    )


    # First ensure Scripts directory exists
    if (-not (Test-Path $CommonPaths.Scripts)) {
        New-Item -Path $CommonPaths.Scripts -ItemType Directory -Force
    }
    
    try {
        $scriptPath = Join-Path $CommonPaths.Scripts $Name
        if (Test-Path $scriptPath) {
            Write-Host "Debug: Found script at $scriptPath" -ForegroundColor Cyan
            . $scriptPath
            Write-Host "Successfully loaded script: $Name ($Purpose)" -ForegroundColor Green
            
            # Verify function is loaded
            $functionName = $Name -replace '\.ps1$', ''
            if (Get-Command -Name $functionName -ErrorAction SilentlyContinue) {
                Write-Host "Verified function '$functionName' is available" -ForegroundColor Green
            } else {
                Write-Warning "Function '$functionName' not found after loading script"
            }
        } else {
            Write-Warning "Script not found: $scriptPath"
        }
    }
    catch {
        Write-Warning "Failed to load script: $Name. Error: $_"
    }
}

Write-Host "Debug: Starting script loading process" -ForegroundColor Yellow
Write-Host "Debug: Scripts directory path: $($CommonPaths.Scripts)" -ForegroundColor Yellow
Write-Host "Debug: Scripts directory exists: $(Test-Path $CommonPaths.Scripts)" -ForegroundColor Yellow
Write-Host "Debug: Scripts in directory:" -ForegroundColor Yellow
Get-ChildItem -Path $CommonPaths.Scripts | ForEach-Object { Write-Host "- $($_.Name)" -ForegroundColor Cyan }


# Load custom scripts after modules are loaded
foreach ($script in $CustomScripts) {
    Write-Host "Debug: Attempting to load $($script.Name)" -ForegroundColor Yellow
    Import-CustomScript -Name $script.Name -Purpose $script.Purpose
}

#region Custom Functions
function Get-Guid {
    <#
    .SYNOPSIS
    Generates a new GUID.
    
    .EXAMPLE
    Get-Guid
    #>
    [guid]::NewGuid().ToString()
}

# Enhanced PSModulePath management
function Manage-ModulePath {
    [Alias('modpath')]
    param (
        [Parameter()]
        [switch]$Formatted,
        [Parameter()]
        [switch]$Add,
        [Parameter()]
        [string]$Path
    )
    
    if ($Add -and $Path) {
        if (Test-Path $Path) {
            $env:PSModulePath = "$Path;$env:PSModulePath"
            Write-Host "Added '$Path' to PSModulePath" -ForegroundColor Green
        }
        else {
            Write-Error "Path '$Path' does not exist"
            return
        }
    }
    
    $paths = $env:PSModulePath -split ';'
    if ($Formatted) {
        $paths | ForEach-Object { Write-Host "- $_" -ForegroundColor Cyan }
    }
    else {
        $paths
    }
}

# Function to create new module
function New-PowerShellModule {
    [Alias('addmodule')]
    param (
        [Parameter(Position=0)]
        [string]$ModuleName = $(Read-Host "Enter module name")
    )
    
    try {
        $modulePath = Join-Path $CommonPaths.Documents "PowerShell\Modules\$ModuleName"
        New-Item -Path $modulePath -ItemType Directory -ErrorAction Stop
        
        Write-Host "Created new module in:" -ForegroundColor Green
        Write-Host "- $modulePath" -ForegroundColor Green
        
        Manage-ModulePath -Add -Path $modulePath
        Write-Host "`nCurrent module paths:" -ForegroundColor Cyan
        Manage-ModulePath -Formatted
    }
    catch {
        Write-Error "Failed to create module: $_"
    }
}

# PSFzf configuration
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Enable-PsFzfAliases

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

# Profile reload function
function Update-PowerShellProfile {
    [Alias('reload')]
    param()
    . $PROFILE
    Write-Host "PowerShell profile reloaded successfully." -ForegroundColor Green
}

Set-PSReadLineOption -Colors @{
    Command = 'Green'
    Parameter = 'Cyan'
    String = 'Yellow'
}

#region Aliases
Set-Alias -Name clr -Value Clear-Host
# Open Explorer in the current directory
Set-Alias -Name here -Value Open-ExplorerHere
Set-Alias -Name ghs -Value Search-GitHubRepos
Set-Alias -Name ghl -Value Get-GitHubRepoList
Set-Alias -Name ghview -Value Get-GitHubRepoView
Set-Alias -Name ghrun -Value New-GitHubRepository
# Set-Alias -Name dirc -Value { Get-Location | clip }
Set-Alias -Name psgal -Value Open-PowerShellGallery

# PSReadLine Configuration
if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    
    # Custom key handlers
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Initial admin check
if (-not (Test-Path $CommonPaths.Scripts)) {
    New-Item -Path $CommonPaths.Scripts -ItemType Directory
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal] $identity
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "PowerShell is running with Administrator privileges. Please be cautious."
}



#region TeMpARiT FiLE.

#region URL_glop
function Open-Urls {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Urls,
        [string]$Message = "Opened all URLs"
    )
    foreach ($url in $Urls) {
        if ($url -match '^https?://') {
            Start-Process $url
        } else {
            Write-Warning "Invalid URL: $url"
        }
    }
    Write-Host $Message -ForegroundColor Green
}
# Example usage:
function oAi {
    $aiSites = @(
        "https://chatgpt.com/",
        "https://claude.ai/new",
        "https://gemini.google.com/app?hl=en-GB", 
        "https://chat.deepseek.com/",
        "https://x.com/i/grok"
    )
    Open-Urls -Urls $aiSites -Message "Opened all AI chat websites"
}

function mysocial {
    $socialSites = @(
        "https://x.com/home",
        "https://www.reddit.com/",
        "https://www.tumblr.com/dashboard", 
        "https://www.facebook.com/",
        "https://www.instagram.com/",
        "https://www.threads.net/"
        "https://disboard.org/search"
    )
    Open-Urls -Urls $socialSites -Message "Opened all Social Media websites"
}
    function stonks {
        $Stocksites = @(
            "",
            "https://www.reddit.com/r/stocks/",
            "https://www.webull.com/center",
            "https://www.tradingview.com/", 
            #"https://www.interactivebrokers.com/en/whyib/overview.php",
            "https://robinhood.com/",
            "https://robinhood.com/legend"
        )
        Open-Urls -Urls $Stocksites -Message "Opened all my stock trading websites"
    }

    function HVAC {
        $HvacSites = @(
            # "https://chatgpt.com/g/g-nlEQxC91L-hvac-assistant",
        )
        Open-Urls -Urls $HvacSites -Message "Opened all Social Media websites"

}
    function Open-PowerShellGallery {
        $pwshgall = @(
            "https://www.powershellgallery.com/packages/"
            )
        Open-Urls -Urls $pwshgall -Message "Opens powershell gallery"

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




# End of Microsoft.PowerShell_profile.ps1