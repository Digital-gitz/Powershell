# Microsoft.PowerShell_profile.ps1

#region Environment Setup
<#
.SYNOPSIS
Enhanced PowerShell profile script with improved organization and functionality.

.DESCRIPTION
A comprehensive PowerShell profile that provides:
- Custom prompt and console customization
- Useful utility functions and aliases
- Module imports and environment setup
- Directory navigation shortcuts
- GitHub integration helpers

.NOTES
Author: Svyatoslav Oleg Russkiy
Last Updated: 2025
#>

wsl --update

# Initialize working directory
Set-Location $CommonPaths.PowerShell

$script:CommonPaths = @{
    Home = $HOME
    Documents = [Environment]::GetFolderPath('MyDocuments')
    Desktop = [Environment]::GetFolderPath('Desktop')
    PowerShell = Split-Path $PROFILE
    GitHub = Join-Path $HOME "Github"
    Scripts = Join-Path (Split-Path $PROFILE) "Scripts"
}

#region CustomAliases
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name here -Value Open-ExplorerHere
# GitHub Aliases
Set-Alias -Name ghs -Value Search-GitHubRepos
Set-Alias -Name ghl -Value Get-GitHubRepoList
Set-Alias -Name ghview -Value Get-GitHubRepoView
Set-Alias -Name ghrun -Value New-GitHubRepository
#Set-Alias -Name mod -Value 
# Set alias for 'dirc' with a function

#region Handling Imports
#?! Import separate function modules need to clean up scripts change their extension to be a module export functions an them to the correct location.
$ModuleFiles = @(
    'Navigation.ps1',                    # Navigation-related functions.
    'GitHub.ps1',                        # GitHub-related functions.
    'PNGtoVECTOR.ps1',                   # Function to call on bash script.
    'UtilityFunctions.aiUpdate.ps1',     # Utility functions.
    'SystemInfo.ps1',                    # System information functions.
    'FileManagement.ps1'                 # File management functions.
    'AWS.Tools.Common',                  # AWS CLI tools.
    'ImportExcel',                       # Excel manipulation.
    'PackageManagement',                 # Enhanced package management.
    'PSFzf'                              # Fuzzy finder integration.
    
)

# Import all module files
foreach ($file in $ModuleFiles) {
    $modulePath = Join-Path $CommonPaths.Scripts $file
    if (Test-Path $modulePath) {
        . $modulePath
    }
}

# Module imports with error handling
if ($host.Name -eq 'ConsoleHost') {
    $ModulesToImport = @(
        'PSReadLine'
        #'BuildRepo' #!builds for some reson
        'posh-git'
        'GitIgnores'         #Get-GitIgnore -Template <language> 
        #'add-gitattributes'
        #'add-firewall-rule'
        #'Microsoft.PowerShell.SecretManagement'
        #'Microsoft.PowerShell.SecretStore'
        #'Microsoft.PowerShell.UnixUtils'
        'Terminal-Icons'
        'z'

    )
    
    foreach ($Module in $ModulesToImport) {
        try {
            if (-not (Get-Module -Name $Module -ListAvailable)) {
                Install-Module -Name $Module -Scope CurrentUser -Force -AllowClobber
            }
            Import-Module -Name $Module -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to import module: $Module. Error: $_"
        }
    }
    #region Functions
# Function to manage PSModulePath
# Usage examples:
#   modpath                     # Display PSModulePath as array
#   modpath -Formatted         # Display formatted PSModulePath with bullets
#   modpath -Add "C:\Modules"  # Add new path to PSModulePath
function Get-Guid {
    $guid = [guid]::NewGuid()
    $guid.ToString()
}
function modpath {
    param (
        [Parameter()]
        [switch]$Formatted,
        
        [Parameter()]
        [switch]$Add,
        
        [Parameter()]
        [string]$Path
    )
    
    if ($Add) {
        if (-not $Path) {
            Write-Error "Path parameter is required when using -Add switch"
            return
        }
        
        if (Test-Path $Path) {
            $env:PSModulePath = "$Path;$env:PSModulePath"
            Write-Host "Added '$Path' to PSModulePath" -ForegroundColor Green
        }
        else {
            Write-Error "Path '$Path' does not exist"
        }
    }
    
    if ($Formatted) {
        $env:PSModulePath -split ';' | ForEach-Object { 
            Write-Host "- $_" -ForegroundColor Cyan
        }
    }
    else {
        $env:PSModulePath -split ';'
    }
}

function addmodule {
    param (
        [Parameter(Position=0)]
        [string]$mod = $(Read-Host "Enter module name")
    )
    
    try {
        # Create module directory in Documents
        $documentsPath = "$HOME\Documents\PowerShell\Modules\$mod"
        
        # Create directory
        New-Item -Path $documentsPath -ItemType Directory -ErrorAction Stop
        
        Write-Host "Created new module in:" -ForegroundColor Green
        Write-Host "- $documentsPath" -ForegroundColor Green
        Write-Host "Module location: $documentsPath" -ForegroundColor Yellow
        
        # Add path to PSModulePath
        modpath -Add -Path $documentsPath
        
        Write-Host "`nCurrent module paths:" -ForegroundColor Cyan
        modpath -Formatted
    }
    catch {
        Write-Error "Failed to create module: $_"
    }
}

# Create Scripts directory if it doesn't exist
if (-not (Test-Path $CommonPaths.Scripts)) {
    New-Item -Path $CommonPaths.Scripts -ItemType Directory
}


    # PSReadLine configuration
    if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
        Set-PSReadLineOption -ShowToolTips
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -EditMode Windows
    } else {
        Write-Warning "PSReadLine options 'PredictionSource' or 'PredictionViewStyle' not supported."
    }

    # Custom key handlers
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Prompt configuration
function prompt {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    
    $prefix = if ($principal.IsInRole($adminRole)) {
        Write-Host "[ADMIN]" -NoNewline -ForegroundColor Red
        ": "
    } else { '' }
    
    $location = Get-Location
    Write-Host "PS " -NoNewline
    Write-Host "$location" -NoNewline -ForegroundColor Blue
    
    "$prefix> "
}

function Test-AdminWarning {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    
    if ($principal.IsInRole($adminRole)) {
        Write-Warning "You are running PowerShell with Administrator privileges. Be cautious."
    }
}

# Call this at startup
Test-AdminWarning


Function Dirc { Get-Location | clip }
Set-Alias -Name dirc -Value Dirc

# Optional: Load welcome message (can be commented out if not needed)
# Show-Welcome





# Import module if it exists
if (Get-Module -ListAvailable -Name Microsoft.WinGet.CommandNotFound) {
    Import-Module -Name Microsoft.WinGet.CommandNotFound
} else {
    Write-Warning "Module 'Microsoft.WinGet.CommandNotFound' not found."
}

# Function to reload PowerShell profile
function reload {
    #. $PROFILE
    # . $PROFILE.AllUsersAllHosts
    #. $PROFILE.CurrentUserAllHosts
    . C:\Users\russk.DISDM\Documents\PowerShell\Microsoft.VSCode_profile.ps1
    Write-Host "PowerShell profile reloaded successfully." -ForegroundColor Green
}
function powershell_gal {
    Write-Host "Invoked Find-Module -Name <SearchTerm> & Find Script -Name <SerchTerm>" -ForegroundColor Green
    Write-Host "use Get-PSRepository to see if registerd" -ForegroundColor Green
    Write-Host "can register new module with Register-PSRepository -Default" -ForegroundColor Green
    Write-Host "PowerShell Gallery Search Options:" -ForegroundColor Cyan
    Write-Host "-Tag: Search by tags" -ForegroundColor Yellow
    Write-Host "-Repository: Specify a different repository" -ForegroundColor Yellow 
    Write-Host "-AllVersions: Show all versions" -ForegroundColor Yellow
    Write-Host "-IncludeDependencies: Include dependencies" -ForegroundColor Yellow
    Write-Host ""

    $searchType = Read-Host "Would you like to search for a (M)odule or (S)cript?"
    $searchTerm = Read-Host "Enter search term"
    $searchByTag = Read-Host "Would you like to search by tag? (Y/N)"
    
    if ($searchByTag.ToLower() -eq 'y') {
        $tag = Read-Host "Enter tag to search by"
    }

    try {
        if ($searchType.ToLower() -eq 'm') {
            Write-Host "`nSearching for modules matching '$searchTerm'..." -ForegroundColor Cyan
            if ($searchByTag.ToLower() -eq 'y') {
                Find-Module -Name $searchTerm -Tag $tag | Format-Table Name, Version, Description, Tags -AutoSize
            } else {
                Find-Module -Name $searchTerm | Format-Table Name, Version, Description, Tags -AutoSize
            }
        }
        elseif ($searchType.ToLower() -eq 's') {
            Write-Host "`nSearching for scripts matching '$searchTerm'..." -ForegroundColor Cyan
            if ($searchByTag.ToLower() -eq 'y') {
                Find-Script -Name $searchTerm -Tag $tag | Format-Table Name, Version, Description, Tags -AutoSize
            } else {
                Find-Script -Name $searchTerm | Format-Table Name, Version, Description, Tags -AutoSize
            }
        }
        else {
            Write-Host "Invalid selection. Please enter 'M' for Module or 'S' for Script." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "No matches found in PowerShell Gallery. Opening PowerShell Gallery website..." -ForegroundColor Yellow
        Start-Process "https://www.powershellgallery.com/packages?q=$searchTerm"
    }
}
# This alias won't work as intended since $searchTerm won't be available in this context
# Instead, create a function to open PowerShell Gallery with optional search
function Open-PowerShellGallery {
    param(
        [Parameter()]
        [string]$SearchTerm
    )
    
    $url = if ($SearchTerm) {
        "https://www.powershellgallery.com/packages?q=$SearchTerm"
    } else {
        "https://www.powershellgallery.com"
    }
    
    Start-Process $url
}
Set-Alias -Name psgal -Value Open-PowerShellGallery
function reload {
    #. $PROFILE
    # . $PROFILE.AllUsersAllHosts
    #. $PROFILE.CurrentUserAllHosts
    . C:\Users\russk.DISDM\Documents\PowerShell\Microsoft.VSCode_profile.ps1
    Write-Host "PowerShell profile reloaded successfully." -ForegroundColor Green
}