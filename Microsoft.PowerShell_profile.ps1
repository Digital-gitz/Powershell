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
Version: 5.0 (Optimized)
#>

#region Initialization
$ErrorActionPreference = 'Continue'
$profileLoadStart = Get-Date

# Define core paths
$scriptsDir = Join-Path $PSScriptRoot "Scripts"
$coreDir = Join-Path $scriptsDir "Core"

# Load core configuration and utility functions
. (Join-Path $coreDir "Configuration.ps1")
. (Join-Path $coreDir "Utility-Functions.ps1")

# Display PowerShell version information
Write-Banner "|Power Shell!|" -FontName "Consolas" -FontSize 14
Write-Host "`nPowerShell Version Information:" -ForegroundColor Cyan
Write-Host "─────────────────────────────" -ForegroundColor DarkGray
$PSVersionTable.GetEnumerator() | Sort-Object Key | ForEach-Object {
    Write-Host ("{0,-20}: {1}" -f $_.Key, $_.Value) -ForegroundColor Gray
}
Write-Host "─────────────────────────────`n" -ForegroundColor DarkGray

#region Environment Setup
# Set up environment paths efficiently
$newPaths = $Config.EnvironmentPaths | Where-Object { Test-Path $_ } | ForEach-Object { (Resolve-Path $_).Path }
$env:PATH = ($env:PATH.Split(';') + $newPaths | Select-Object -Unique) -join ";"

# Check for admin privileges
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "⚡ Running with administrator privileges" -ForegroundColor Yellow
}

#region Module Management
# Optimized module loading function
function Import-ModuleSafely {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [string]$Scope = 'CurrentUser',
        
        [Parameter(Mandatory = $false)]
        [string]$Purpose,
        
        [Parameter(Mandatory = $false)]
        [string]$MinimumVersion
    )
    
    try {
        # Check if module is already loaded
        if (Get-Module -Name $Name) {
            return
        }

        # Check if module needs to be installed
        if (-not (Get-Module -Name $Name -ListAvailable)) {
            try {
                # Ensure PSGallery is trusted
                if ((Get-PSRepository -Name 'PSGallery').InstallationPolicy -ne 'Trusted') {
                    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
                }
                
                # Install module
                $params = @{
                    Name               = $Name
                    Force              = $true 
                    Scope              = $Scope
                    AllowClobber       = $true
                    SkipPublisherCheck = $true
                    ErrorAction        = 'Stop'
                }
                if ($MinimumVersion) {
                    $params['MinimumVersion'] = $MinimumVersion
                }
                
                Install-Module @params
            }
            catch {
                Write-Warning "Failed to install module $Name : $($_.Exception.Message)"
                return
            }
        }

        # Import module
        Import-Module -Name $Name -Force -DisableNameChecking -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to load ${Name} - $($_.Exception.Message)"
    }
}

# Load essential modules
foreach ($module in $Config.Modules.Essential) {
    Import-ModuleSafely -Name $module.Name -Purpose $module.Purpose
    if ($module.Name -eq 'posh-git') {
        $env:POSHGIT_CYGWIN_WARNING = 'false'
    }
}

# Load optional modules
foreach ($module in $Config.Modules.Optional) {
    Import-ModuleSafely -Name $module
}

#region Prompt Configuration
# Initialize Oh My Posh with fallback
try {
    $themeFile = "$env:POSH_THEMES_PATH\agnosterplus.omp.json"
    if (Test-Path $themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    }
    else {
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

#region PSReadLine Configuration
if (Get-Module -Name PSReadLine) {
    try {
        Set-PSReadLineOption -ShowToolTips:$Config.PSReadLine.ShowToolTips `
            -PredictionSource $Config.PSReadLine.PredictionSource `
            -PredictionViewStyle $Config.PSReadLine.PredictionViewStyle `
            -EditMode $Config.PSReadLine.EditMode `
            -HistorySaveStyle $Config.PSReadLine.HistorySaveStyle

        if ($Config.PSReadLine.HistorySavePath) {
            Set-PSReadLineOption -HistorySavePath $Config.PSReadLine.HistorySavePath
        }

        Set-PSReadLineOption -Colors $Config.PSReadLine.Colors

        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function AcceptSuggestion
        Set-PSReadLineKeyHandler -Key Alt+Enter -Function AcceptNextSuggestionWord
    }
    catch {
        Write-Warning "Error configuring PSReadLine - $($_.Exception.Message)"
    }
}

#region Script Loading
# Consolidated script loading system
function Import-ScriptSafely {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,
        
        [Parameter(Mandatory = $true)]
        [string]$ScriptName
    )
    
    $scriptPath = Join-Path $scriptsDir $Category $ScriptName
    
    if (Test-Path $scriptPath) {
        try {
            . $scriptPath
        }
        catch {
            Write-Warning "Failed to load ${ScriptName} - $($_.Exception.Message)"
        }
    }
}

# Load scripts efficiently
foreach ($category in $Config.LoadOrder) {
    if ($Config.ScriptCategories.ContainsKey($category)) {
        foreach ($script in $Config.ScriptCategories[$category]) {
            if ($script -like "*`**") {
                $categoryPath = Join-Path $scriptsDir $category
                
                if ($script -like "*/*") {
                    $subDirPattern = $script -replace "\\", "/"
                    $subDirPath = Join-Path $categoryPath ($subDirPattern -split "/")[0]
                    $filePattern = ($subDirPattern -split "/")[1]
                    
                    if (Test-Path $subDirPath) {
                        $matchingScripts = Get-ChildItem -Path $subDirPath -Name $filePattern -ErrorAction SilentlyContinue
                        foreach ($matchingScript in $matchingScripts) {
                            $fullScriptPath = Join-Path $subDirPath $matchingScript
                            try {
                                . $fullScriptPath
                            }
                            catch {
                                Write-Warning "Failed to load $matchingScript - $($_.Exception.Message)"
                            }
                        }
                    }
                }
                else {
                    $matchingScripts = Get-ChildItem -Path $categoryPath -Name $script -ErrorAction SilentlyContinue
                    foreach ($matchingScript in $matchingScripts) {
                        Import-ScriptSafely -Category $category -ScriptName $matchingScript
                    }
                }
            }
            else {
                Import-ScriptSafely -Category $category -ScriptName $script
            }
        }
    }
}

#region Node.js Configuration
$env:NODE_OPTIONS = "--openssl-legacy-provider"

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "Node.js is installed" -ForegroundColor Green
}
else {
    Write-Host "Node.js is not installed" -ForegroundColor Red
}

#region Profile Completion
$loadTime = (Get-Date) - $profileLoadStart
Write-ProfileLog "PowerShell profile loaded in $([math]::Round($loadTime.TotalMilliseconds))ms!" -Level 'Success'

# Display available commands
Write-Host "`nAvailable Commands:" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "h <pattern>                 - Search command history" -ForegroundColor Gray
Write-Host "Start-Aseprite              - Starts Aseprite" -ForegroundColor Gray
Write-Host "Start-DoomEternal           - Starts Doom Eternal" -ForegroundColor Gray
Write-Host "godot                       - Starts godot" -ForegroundColor Gray
Write-Host "ghub                        - Go to Github Folder and list" -ForegroundColor Gray
Write-Host "ddump                       - Go to DigitalHubDump Folder" -ForegroundColor Gray
Write-Host "edge                        - Starts Edge" -ForegroundColor Gray
Write-Host "Search-CommandHistory or h  - Search Commands History" -ForegroundColor Gray
Write-Host "edit_powershell             - Edit my powersehll Profile" -ForegroundColor Gray
Write-Host "list_llm                    - List of my llms" -ForegroundColor Gray
Write-Host "programs                    - List Programs" -ForegroundColor Gray
Write-Host "TwitchOverlay               - Launches Twitch Chat OVerlay" -ForegroundColor Gray
Write-Host "Get-StockMarketSummary      - Get-StockMarketSummary" -ForegroundColor Gray
Write-Host "New-QRCode                  - Generate a QR code" -ForegroundColor Gray
Write-Host "Get-MyIP                    - Get my IP" -ForegroundColor Gray
Write-Host "Search-GoPackages           - Search Go pachages" -ForegroundColor Gray
Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

#region Additional Functions
function Get-MyIP {
    try {
        Write-Host "Fetching your IP information..." -ForegroundColor Cyan
        $response = Invoke-RestMethod -Uri "https://ipinfo.io" -Method Get
        Write-Host "IP Information:" -ForegroundColor Green
        Write-Host "IP: $($response.ip)" -ForegroundColor Gray
        Write-Host "City: $($response.city)" -ForegroundColor Gray
        Write-Host "Region: $($response.region)" -ForegroundColor Gray
        Write-Host "Country: $($response.country)" -ForegroundColor Gray
        Write-Host "Location: $($response.loc)" -ForegroundColor Gray
        Write-Host "Organization: $($response.org)" -ForegroundColor Gray
        Write-Host "Timezone: $($response.timezone)" -ForegroundColor Gray
    }
    catch {
        Write-Host "Error fetching IP information: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function global:ddump {
    try {
        $path = "C:\Users\Digital_Russkiy\Documents\DGTLHubDump"
        if (Test-Path $path) {
            Set-Location -Path $path -ErrorAction Stop
            Write-Host "Successfully changed directory to: $path" -ForegroundColor Green
        }
        else {
            Write-Host "Error: Directory does not exist at path: $path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error changing directory: $_" -ForegroundColor Red
    }

    try {
        $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5
        Start-Process "https://github.com/Digital-gitz/DGTLHubDump"
        Write-Host "Successfully Opened https://github.com/Digital-gitz/DGTLHubDump"
    }
    catch {
        Write-Warning "Could not connect to GitHub. Please check your internet connection."
    }
}

function global:ghub {
    try {
        $path = "C:\Users\Digital_Russkiy\Documents\GitHub"
        if (Test-Path $path) {
            Set-Location -Path $path -ErrorAction Stop
            Write-Host "Successfully changed directory to: $path" -ForegroundColor Green
            
            if (Get-Command gh -ErrorAction SilentlyContinue) {
                Write-Host "`nGitHub Repositories:" -ForegroundColor Cyan
                Write-Host "─────────────────────────────" -ForegroundColor DarkGray
                gh repo list --limit 100 | ForEach-Object {
                    $repo = $_ -split '\s+'
                    Write-Host ("{0,-40} {1}" -f $repo[0], $repo[1]) -ForegroundColor Gray
                }
            }
            else {
                Write-Host "GitHub CLI (gh) is not installed. Please install it to list repositories." -ForegroundColor Yellow
                Write-Host "Installation command: winget install GitHub.cli" -ForegroundColor Yellow
            }
            
            Write-Host "`nContents of GitHub directory:" -ForegroundColor Cyan
            Get-ChildItem -Path $path | Format-Table Name, LastWriteTime, Length -AutoSize
        }
        else {
            Write-Host "Error: Directory does not exist at path: $path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error changing directory: $_" -ForegroundColor Red
    }

    Start-Process "https://github.com/"
}

function Get-DirectoryFiles {
    param([string]$Path = ".")
    
    if (-not (Test-Path $Path -PathType Container)) {
        Write-Error "Directory '$Path' does not exist or is not a directory."
        return
    }
    
    Get-ChildItem -Path $Path -File | ForEach-Object {
        Write-Host $_.Name
    }
}

function New-QRCode {
    param([Parameter(Mandatory = $true)][string]$Url)
    
    try {
        if ($Url -notmatch '^https?://') {
            Write-Host "Error: Please provide a valid URL starting with http:// or https://" -ForegroundColor Red
            return
        }
        
        $qrCodeUrl = "https://qrenco.de/$Url"
        
        Write-Host "Generating QR code for: $Url" -ForegroundColor Cyan
        Write-Host "QR Code URL: $qrCodeUrl" -ForegroundColor Green
        
        Start-Process $qrCodeUrl
        
        Write-Host "QR code opened in browser successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error generating QR code: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-BIOSInfo {
    try {
        $scriptPath = Join-Path $PSScriptRoot "Scripts\Core\System\check-bios.ps1"
        
        if (Test-Path $scriptPath) {
            Write-Host "Checking BIOS information..." -ForegroundColor Cyan
            & $scriptPath
        }
        else {
            Write-Host "Error: BIOS check script not found at: $scriptPath" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error running BIOS check: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-NyanCat {
    try {
        Write-Host "Fetching Nyan Cat animation..." -ForegroundColor Cyan
        
        if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
            Write-Host "Error: curl is not available. Please install curl first." -ForegroundColor Red
            return
        }
        
        if (-not (Get-Command lolcat -ErrorAction SilentlyContinue)) {
            Write-Host "Error: lolcat is not available. Please install lolcat first." -ForegroundColor Red
            Write-Host "You can install it via: gem install lolcat" -ForegroundColor Yellow
            return
        }
        
        curl -s ascii.live/nyan | lolcat
        
        Write-Host "Nyan Cat animation completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error showing Nyan Cat: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-GoPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,
        
        [switch]$OpenInBrowser
    )
    
    try {
        Write-Host "Searching Go packages for: $SearchTerm" -ForegroundColor Cyan
        
        $searchUrl = "https://pkg.go.dev/search?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))"
        
        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }
        
        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching Go packages: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function TwitchOverlay {
    $updatePath = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\Update.exe"
    $appPath = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\TransparentTwitchChatWPF.exe"

    Write-Host "Starting Twitch Chat Overlay update..." -ForegroundColor Cyan
    Start-Process -FilePath $updatePath -Wait

    Write-Host "Launching Twitch Chat Overlay..." -ForegroundColor Green
    Start-Process -FilePath $appPath
}

