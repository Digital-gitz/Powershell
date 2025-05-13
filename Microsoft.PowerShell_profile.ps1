#region Script Configuration
<#
.SYNOPSIS
Enhanced PowerShell profile with modern features and utilities.

.DESCRIPTION
A feature-rich PowerShell profile that provides:
- Modern command-line experience with syntax highlighting
- Smart command prediction and history
- Git integration and custom prompt
- Useful aliases and utility functions
- Performance-optimized module loading
- Enhanced error handling and command suggestions

.NOTES
Author: Svyatoslav Oleg Russkiy
Version: 4.3
#>

#region Initialization
$ErrorActionPreference = 'Continue'
$scriptsDir = Join-Path $PSScriptRoot "Scripts"
$coreDir = Join-Path $scriptsDir "Core"

# Load core configuration
. (Join-Path $coreDir "Configuration.ps1")

# Set up environment
$pathsToAdd = @(
    "C:\Users\Digital_Russkiy\AppData\Local\Microsoft\PowerToys\PowerToys Run",
    (Get-CommonPaths).Scripts,
    "$HOME\.local\bin",
    "$HOME\AppData\Local\Programs\Microsoft VS Code\bin"
)

$newPaths = $pathsToAdd | Where-Object { 
    Test-Path $_ 
} | ForEach-Object {
    (Resolve-Path $_).Path
}

$env:PATH = ($env:PATH.Split(';') + $newPaths | Select-Object -Unique) -join ";"

# Check for admin privileges
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "⚡ Running with administrator privileges" -ForegroundColor Yellow
}

# Function to safely load a module
function Import-ModuleSafely {
    param(
        [string]$Name,
        [string]$Scope = 'CurrentUser',
        [string]$Purpose,
        [string]$MinimumVersion
    )
    
    try {
        # Check if module is already loaded
        if (Get-Module -Name $Name) {
            return
        }

        if (-not (Get-Module -Name $Name -ListAvailable)) {
            Write-Host "Installing module $Name..." -ForegroundColor Cyan
            $params = @{
                Name  = $Name
                Force = $true
                Scope = $Scope
            }
            if ($MinimumVersion) {
                $params['MinimumVersion'] = $MinimumVersion
            }
            Install-Module @params
        }
        Import-Module -Name $Name -Force -DisableNameChecking
        Write-Host "✓ Loaded $Name" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to load ${Name} - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Load essential modules first
$essentialModules = @(
    @{Name = 'Terminal-Icons'; Purpose = 'Directory and file icons' }
    @{Name = 'PSReadLine'; Purpose = 'Enhanced console experience' }
    @{Name = 'posh-git'; Purpose = 'Git integration' }
)

foreach ($module in $essentialModules) {
    Import-ModuleSafely -Name $module.Name -Purpose $module.Purpose
    if ($module.Name -eq 'posh-git') {
        $env:POSHGIT_CYGWIN_WARNING = 'false'  # Suppress posh-git warning
    }
}

# Initialize Oh My Posh with fallback
try {
    $themeFile = "$env:POSH_THEMES_PATH\agnosterplus.omp.json"
    if (Test-Path $themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    }
    else {
        Write-Host "⚠️ Oh My Posh theme file not found: $themeFile" -ForegroundColor Yellow
        throw "Theme file not found"
    }
}
catch {
    function prompt {
        $lastCommand = Get-History -Count 1
        $lastCommandTime = if ($lastCommand) { 
            $duration = $lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime
            " [$([math]::Round($duration.TotalMilliseconds))ms]"
        }
        else { "" }

        $currentLocation = Get-Location
        $adminIndicator = if ($isAdmin) { "[ADMIN] " } else { "" }
        
        # Cache git command check result
        $gitCommand = Get-Command -Name git -ErrorAction SilentlyContinue
        $gitBranch = if ($gitCommand) { 
            $branch = git branch --show-current 2>$null
            if ($branch) { " [$branch]" } else { "" }
        }
        else { "" }

        Write-Host "`n$adminIndicator" -NoNewline -ForegroundColor Red
        Write-Host "PS" -NoNewline -ForegroundColor Blue
        Write-Host "$lastCommandTime" -NoNewline -ForegroundColor DarkGray
        Write-Host " $($currentLocation)" -NoNewline -ForegroundColor Yellow
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Green
        return "`n❯ "
    }
}

# Configure PSReadLine
if (Get-Module -Name PSReadLine) {
    try {
        # Basic options
        $psReadLineConfig = $config.PSReadLine

        # Set basic options
        Set-PSReadLineOption -ShowToolTips:$true
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -EditMode Windows
        
        # Set history path if configured
        if (-not [string]::IsNullOrEmpty($psReadLineConfig.HistorySavePath)) {
            Set-PSReadLineOption -HistorySavePath $psReadLineConfig.HistorySavePath
        }
        
        # Set history save style
        Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

        # Set colors for better visibility
        Set-PSReadLineOption -Colors @{
            Command          = 'Cyan'
            Parameter        = 'DarkCyan'
            InlinePrediction = 'DarkGray'
            Operator         = 'DarkYellow'
            String           = 'Green'
            Number           = 'DarkGreen'
            Member           = 'DarkYellow'
            Type             = 'DarkBlue'
            Variable         = 'DarkMagenta'
            Comment          = 'DarkGray'
        }

        # Key handlers for better interaction
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function AcceptSuggestion
        Set-PSReadLineKeyHandler -Key Alt+Enter -Function AcceptNextSuggestionWord

        Write-Host "✓ PSReadLine configured successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Error configuring PSReadLine - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Load script categories
$scriptCategories = @{
    Core           = @("Aliases.ps1")
    FileManagement = @("bringVsCodeForeground.ps1")
    Navigation     = @("cd-downloads.ps1")
    Development    = @("Notes-Function.ps1")
    UI             = @("winfetch-pro.ps1")
    Networking     = @("NetworkingTools.ps1")
    URL            = @("LLM-Funk.ps1", "Shopping-Funk.ps1")
}                               

# Function to safely load a script
function Import-ScriptSafely {
    param(
        [string]$Category,
        [string]$ScriptName,
        [int]$TimeoutSeconds = 10
    )
    
    $scriptPath = Join-Path $scriptsDir $Category $ScriptName
    if (Test-Path $scriptPath) {
        try {
            # Dot source the script directly instead of using jobs
            . $scriptPath
            Write-Host "✓ Loaded $ScriptName" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Failed to load ${ScriptName} - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "! Script not found: $ScriptName" -ForegroundColor Yellow
    }
}

# Load scripts in order
$loadOrder = @(
    "Core", 
    "UI",
    "Networking",
    "URL",
    "Development", 
    "Navigation",
    "FileManagement"
)
foreach ($category in $loadOrder) {
    if ($scriptCategories.ContainsKey($category)) {
        foreach ($script in $scriptCategories[$category]) {
            Import-ScriptSafely -Category $category -ScriptName $script
        }
    }
}

function Get-CommandSuggestion {
    param([string]$ErrorMessage)
    
    if ($ErrorMessage -match "The term '(.+)' is not recognized") {
        $command = $matches[1]
        $suggestions = Get-Command -ErrorAction SilentlyContinue | 
        Where-Object Name -like "*$command*" |
        Select-Object -First 3 Name
        
        if ($suggestions) {
            Write-Host "`nDid you mean:" -ForegroundColor Yellow
            $suggestions | ForEach-Object {
                Write-Host "  • $($_.Name)" -ForegroundColor Cyan
            }
        }
    }
}

function sleep {
    Write-Host "`n💤 Putting computer to sleep..." -ForegroundColor Cyan
    try {
        Shutdown.exe -h
    }
    catch {
        Write-Host "Failed to put computer to sleep: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function programs {
    Write-Host "`nWMIC Installed Programs:" -ForegroundColor Cyan
    wmic product get name | sort

    Write-Host "`nWinget Installed Programs:" -ForegroundColor Cyan
    winget list | Sort-Object -Property Name

    Write-Host "`nChocolatey Installed Programs:" -ForegroundColor Cyan
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco list --local-only | Sort-Object
    }
    else {
        Write-Host "Chocolatey is not installed" -ForegroundColor Yellow
    }

    Write-Host "`nScoop Installed Programs:" -ForegroundColor Cyan
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop list | Sort-Object
    }
    else {
        Write-Host "Scoop is not installed" -ForegroundColor Yellow
    }
}

# Error handling
$ErrorView = 'ConciseView'
$Global:Error.Clear()

# Register error handler for command suggestions
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param($CommandName, $CommandLookupEventArgs)
    Get-CommandSuggestion -ErrorMessage "The term '$CommandName' is not recognized"
}

# Function to restart PowerShell session
function restart {
    Write-Host "`n🔄 Restarting PowerShell session..." -ForegroundColor Cyan
    Clear-Host
    . $PROFILE
    Write-Host "✓ PowerShell session restarted successfully!" -ForegroundColor Green
}

$profileLoadStart = Get-Date

Write-Host "`n🚀 PowerShell profile loaded and ready!" -ForegroundColor Cyan

$loadTime = (Get-Date) - $profileLoadStart
Write-Host "`n🚀 PowerShell profile loaded in $([math]::Round($loadTime.TotalMilliseconds))ms!" -ForegroundColor Cyan

$env:NODE_OPTIONS = "--openssl-legacy-provider"

# Check if Node.js is installed
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "Node.js is installed" -ForegroundColor Green
}
else {
    Write-Host "Node.js is not installed" -ForegroundColor Red
}


function global:tabMate {
    Write-Host "Opening Clip Studio Tab Mate..." -ForegroundColor Cyan
    Start-Process "https://www.clipstudio.net/promotion/tabmate/en"
}

function global:clipStudio_web {
    Write-Host "Opening Clip Studio..." -ForegroundColor Cyan
    Start-Process "https://www.clipstudio.net/en"
}

function global:clipStudio {
    Write-Host "Opening Clip Studio Paint..." -ForegroundColor Cyan
    Start-Process "C:\Program Files\CELSYS\CLIP STUDIO 1.5\CLIP STUDIO\CLIPStudio.exe"
}

function global:edit_powershell_profile {
    Write-Host "Opening PowerShell Profile..." -ForegroundColor Cyan
    
    # Define paths
    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath -Parent
    
    # Test GitHub connectivity and open repo if available
    try {
        $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5
        Start-Process "https://github.com/Digital-gitz/PowerShell"
    }
    catch {
        Write-Warning "Could not connect to GitHub. Please check your internet connection."
    }

    # Change to PowerShell directory
    if (Test-Path $profileDir) {
        Set-Location $profileDir
    }
    else {
        Write-Warning "PowerShell profile directory not found at: $profileDir"
    }

    # Open in editor
    if (Get-Command cursor -ErrorAction SilentlyContinue) {
        Start-Process "cursor" -ArgumentList $profileDir
    }
    else {
        Write-Warning "Cursor editor not found. Please ensure it is installed and in your PATH."
    }
}


# function global:powershell_profile {
#     Write-Host "Opening PowerShell Profile..." -ForegroundColor Cyan
    
#     # Check if VS Code workspace file exists
#     $workspacePath = Join-Path $PSScriptRoot ".vscode\PowerShell.code-workspace"
#     if (Test-Path $workspacePath) {
#         Start-Process "code" -ArgumentList $workspacePath
#     }
#     else {
#         Write-Warning "VS Code workspace file not found at: $workspacePath"
#         # Fallback to opening the profile directly
#         code $PROFILE
#     }

#     # Test GitHub connectivity and open repo
#     try {
#         $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5
#         Start-Process "https://github.com/Digital-gitz/PowerShell"
#     }
#     catch {
#         Write-Warning "Could not connect to GitHub. Please check your internet connection."
#     }
# }
