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
Version: 4.4
#>

#region Initialization
$ErrorActionPreference = 'Continue'
$profileLoadStart = Get-Date

# Define core paths
$scriptsDir = Join-Path $PSScriptRoot "Scripts"
$coreDir = Join-Path $scriptsDir "Core"

# Load core configuration
. (Join-Path $coreDir "Configuration.ps1")

# Display PowerShell version information
Write-Host "`nPowerShell Version Information:" -ForegroundColor Cyan
Write-Host "─────────────────────────────" -ForegroundColor DarkGray
$PSVersionTable.GetEnumerator() | Sort-Object Key | ForEach-Object {
    Write-Host ("{0,-20}: {1}" -f $_.Key, $_.Value) -ForegroundColor Gray
}
Write-Host "─────────────────────────────`n" -ForegroundColor DarkGray

#region Environment Setup
$env:PATH += ";C:\Users\Digital_Russkiy\AppData\Local\Programs\lua5.1"
# Set up environment paths
$pathsToAdd = @(
    "C:\Users\Digital_Russkiy\AppData\Local\Microsoft\PowerToys\PowerToys Run",
    (Get-CommonPaths).Scripts,
    "$HOME\.local\bin",
    "$HOME\AppData\Local\Programs\Microsoft VS Code\bin"
)

$newPaths = $pathsToAdd | Where-Object { Test-Path $_ } | ForEach-Object { (Resolve-Path $_).Path }
$env:PATH = ($env:PATH.Split(';') + $newPaths | Select-Object -Unique) -join ";"

# Check for admin privileges
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "⚡ Running with administrator privileges" -ForegroundColor Yellow
}




#region Module Management
# Function to safely load a module
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
            Write-Host "✓ Module $Name already loaded" -ForegroundColor Green
            return
        }

        # Check if module needs to be installed
        if (-not (Get-Module -Name $Name -ListAvailable)) {
            Write-Host "Installing module $Name..." -ForegroundColor Cyan
            try {
                # First, try to uninstall any broken version
                Uninstall-Module -Name $Name -AllVersions -Force -ErrorAction SilentlyContinue
                
                # Install fresh copy with specific version if provided
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
                
                # Ensure PSGallery is trusted
                if ((Get-PSRepository -Name 'PSGallery').InstallationPolicy -ne 'Trusted') {
                    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
                }
                
                Install-Module @params
                
                # Verify installation
                if (-not (Get-Module -Name $Name -ListAvailable)) {
                    throw "Module installation appeared to succeed but module not found"
                }
            }
            catch {
                Write-Warning "Failed to install module $Name : $($_.Exception.Message)"
                return
            }
        }

        # Import module with error handling
        try {
            Import-Module -Name $Name -Force -DisableNameChecking -ErrorAction Stop
            Write-Host "✓ Loaded $Name" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Failed to import $Name - $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  Attempting to repair module..." -ForegroundColor Yellow
            
            # Try to repair by uninstalling and reinstalling
            try {
                # Remove module directory completely
                $modulePath = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\$Name"
                if (Test-Path $modulePath) {
                    Remove-Item -Path $modulePath -Recurse -Force -ErrorAction SilentlyContinue
                }
                
                # Clear module cache
                Remove-Item -Path "$modulePath*" -Recurse -Force -ErrorAction SilentlyContinue
                
                # Install module
                Install-Module -Name $Name -Force -AllowClobber -Scope $Scope
                
                # Try importing again
                Import-Module -Name $Name -Force -DisableNameChecking
                Write-Host "✓ Successfully repaired and loaded $Name" -ForegroundColor Green
            }
            catch {
                Write-Host "✗ Module repair failed - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "✗ Failed to load ${Name} - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Load essential modules
$essentialModules = @(
    @{Name = 'PSReadLine'; Purpose = 'Enhanced console experience' }
    @{Name = 'posh-git'; Purpose = 'Git integration' }
)
Import-Module Terminal-Icons


foreach ($module in $essentialModules) {
    Import-ModuleSafely -Name $module.Name -Purpose $module.Purpose
    if ($module.Name -eq 'posh-git') {
        $env:POSHGIT_CYGWIN_WARNING = 'false'  # Suppress posh-git warning
    }
}

#region Prompt Configuration
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

#region PSReadLine Configuration
if (Get-Module -Name PSReadLine) {
    try {
        # Basic options
        Set-PSReadLineOption -ShowToolTips:$true `
            -PredictionSource History `
            -PredictionViewStyle ListView `
            -EditMode Windows `
            -HistorySaveStyle SaveIncrementally

        # Set history path if configured
        if ($config.PSReadLine -and $config.PSReadLine.HistorySavePath) {
            Set-PSReadLineOption -HistorySavePath $config.PSReadLine.HistorySavePath
        }

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

#region Script Loading
# Define script categories
$scriptCategories = @{
    Core           = @("Aliases.ps1")
    FileManagement = @("bringVsCodeForeground.ps1")
    Development    = @("Notes-Function.ps1")
    UI             = @("winfetch-pro.ps1", "Stock-Market-UI.ps1")
    Networking     = @("NetworkingTools.ps1")
    URL            = @("LLM-Funk.ps1", "Shopping-Funk.ps1", "Social-Funk.ps1")
    Applications   = @("App-Functions.ps1")
    Programs       = @("Aseprite.ps1", "Doom Eternal.ps1", "godot.ps1")
}

# Function to safely load a script
function Import-ScriptSafely {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,
        
        [Parameter(Mandatory = $true)]
        [string]$ScriptName,
        
        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds = 10
    )
    
    $scriptPath = Join-Path $scriptsDir $Category $ScriptName
    
    ## Error handling.
    # Write-Host "Attempting to load script: $scriptPath" -ForegroundColor DarkGray
    
    if (Test-Path $scriptPath) {
        try {
            # Add error action preference for this specific operation
            $ErrorActionPreference = 'Stop'
            . $scriptPath
            Write-Host "✓ Successfully loaded $ScriptName" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Failed to load ${ScriptName}" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  Line: $($_.InvocationInfo.Line)" -ForegroundColor Red
            Write-Host "  Position: $($_.InvocationInfo.PositionMessage)" -ForegroundColor Red
        }
        finally {
            # Reset error action preference
            $ErrorActionPreference = 'Continue'
        }
    }
    else {
        Write-Host "! Script not found: $ScriptName at path: $scriptPath" -ForegroundColor Yellow
    }
}

# Load scripts in order
$loadOrder = @(
    "Core", 
    "UI",
    "Networking",
    "URL",
    "Development", 
    "FileManagement",
    "Games"
)

foreach ($category in $loadOrder) {
    Write-Host "`nLoading category: $category" -ForegroundColor Cyan
    if ($scriptCategories.ContainsKey($category)) {
        foreach ($script in $scriptCategories[$category]) {
            Import-ScriptSafely -Category $category -ScriptName $script
        }
    }
}

#region Utility Functions

function Startup {
    # Open current user's Startup folder
    Start-Process "explorer.exe" "shell:startup"

    # Open Startup Apps settings
    Start-Process "ms-settings:startupapps"
}
function sleep {
    Write-Host "`n💤 Putting computer to sleep..." -ForegroundColor Cyan
    try {
        # Use rundll32.exe to properly trigger sleep mode
        rundll32.exe powrprof.dll, SetSuspendState 0, 1, 0
    }
    catch {
        Write-Host "Failed to put computer to sleep: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Trying alternative method..." -ForegroundColor Yellow
        try {
            # Alternative method using psshutdown
            Start-Process "psshutdown" -ArgumentList "-d -t 0" -Wait
        }
        catch {
            Write-Host "All sleep attempts failed. Please check your system settings." -ForegroundColor Red
        }
    }
}

function restart {
    Write-Host "`n🔄 Restarting PowerShell session..." -ForegroundColor Cyan
    Clear-Host
    . $PROFILE
    Write-Host "✓ PowerShell session restarted successfully!" -ForegroundColor Green
}

function programs {
    # This function lists all installed programs from multiple package managers and sources:
    # - WMIC: Lists programs installed through Windows Installer
    # - Winget: Microsoft's newer package manager
    # - Chocolatey: Popular Windows package manager
    # - Scoop: Another popular Windows package manager
    
    Write-Host "`nWMIC Installed Programs:" -ForegroundColor Cyan
    wmic product get name | Sort-Object

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
    14
}

#region Error Handling and Logging
$ErrorView = 'ConciseView'
$Global:Error.Clear()

# Enhanced logging function
function Write-ProfileLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory = $false)]
        [string]$Source = 'Profile'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        'Info' { 'Cyan' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Success' { 'Green' }
    }
    
    Write-Host "[$timestamp] [$Source] [$Level] $Message" -ForegroundColor $color
}

# Enhanced command suggestion system
function Get-CommandSuggestion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowHelp
    )

    # Extract the command name from the error message
    $commandName = if ($ErrorMessage -match "The term '([^']+)'") {
        $matches[1]
    }
    else {
        return
    }

    Write-ProfileLog "Looking for suggestions for command: $commandName" -Level 'Info' -Source 'CommandSuggestion'

    # Get all available commands with their help info - with timeout
    $allCommands = Get-Command -All -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -notlike "Microsoft.PowerShell*" } |
    Select-Object -First 100  # Limit to first 100 commands for performance

    # Find similar commands using Levenshtein distance
    $suggestions = $allCommands | ForEach-Object {
        $distance = Get-LevenshteinDistance -String1 $commandName -String2 $_.Name
        [PSCustomObject]@{
            Name     = $_.Name
            Distance = $distance
            Type     = $_.CommandType
        }
    } | Where-Object { $_.Distance -le 3 } | Sort-Object Distance | Select-Object -First 5

    if ($suggestions) {
        Write-Host "`nDid you mean one of these commands?" -ForegroundColor Yellow
        $suggestions | ForEach-Object {
            Write-Host "  $($_.Name) ($($_.Type))" -ForegroundColor Cyan
            
            # Only try to get help if explicitly requested and with timeout
            if ($ShowHelp) {
                try {
                    $helpInfo = Get-Help $_.Name -ErrorAction SilentlyContinue -Timeout 1
                    if ($helpInfo.Synopsis) {
                        Write-Host "    $($helpInfo.Synopsis)" -ForegroundColor DarkGray
                    }
                }
                catch {
                    # Silently continue if help lookup fails
                }
            }
        }
        Write-Host ""
    }
}

# Enhanced Levenshtein distance calculation with memoization
$script:levenshteinCache = @{}
function Get-LevenshteinDistance {
    param(
        [Parameter(Mandatory = $true)]
        [string]$String1,
        
        [Parameter(Mandatory = $true)]
        [string]$String2
    )

    $cacheKey = "$String1|$String2"
    if ($script:levenshteinCache.ContainsKey($cacheKey)) {
        return $script:levenshteinCache[$cacheKey]
    }

    $n = $String1.Length
    $m = $String2.Length
    $d = New-Object 'int[,]' ($n + 1), ($m + 1)

    for ($i = 0; $i -le $n; $i++) {
        $d[$i, 0] = $i
    }
    for ($j = 0; $j -le $m; $j++) {
        $d[0, $j] = $j
    }

    for ($i = 1; $i -le $n; $i++) {
        for ($j = 1; $j -le $m; $j++) {
            if ($String1[$i - 1] -eq $String2[$j - 1]) {
                $d[$i, $j] = $d[($i - 1), ($j - 1)]
            }
            else {
                $d[$i, $j] = [Math]::Min(
                    [Math]::Min(
                        $d[($i - 1), $j] + 1, # deletion
                        $d[$i, ($j - 1)] + 1     # insertion
                    ),
                    $d[($i - 1), ($j - 1)] + 1  # substitution
                )
            }
        }
    }

    $result = $d[$n, $m]
    $script:levenshteinCache[$cacheKey] = $result
    return $result
}

# Enhanced command history search
function Search-CommandHistory {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Pattern,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $history = Get-Content (Get-PSReadLineOption).HistorySavePath -ErrorAction SilentlyContinue
    if ($Pattern) {
        $history = $history | Where-Object { $_ -like "*$Pattern*" }
    }
    $history | Select-Object -Last $Count | ForEach-Object {
        Write-Host $_ -ForegroundColor Cyan
    }
}

# Register enhanced error handler with timeout
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param($CommandName, $CommandLookupEventArgs)
    # Add a timeout to prevent hanging
    $job = Start-Job -ScriptBlock {
        param($cmdName)
        Get-CommandSuggestion -ErrorMessage "The term '$cmdName' is not recognized" -ShowHelp
    } -ArgumentList $CommandName
    
    # Wait for the job with a timeout
    $job | Wait-Job -Timeout 3 | Out-Null
    if ($job.State -eq 'Running') {
        Stop-Job $job
        Write-Host "`nCommand suggestion timed out. Try using 'h' to search command history." -ForegroundColor Yellow
    }
    Remove-Job $job -Force
}

# Add command history search alias
Set-Alias -Name h -Value Search-CommandHistory -Scope Global

#region Node.js Configuration
$env:NODE_OPTIONS = "--openssl-legacy-provider"

# Check if Node.js is installed
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
Write-Host "─────────────────────────────" -ForegroundColor DarkGray
Write-Host "h <pattern>       - Search command history" -ForegroundColor Gray
Write-Host "llm               - Open all LLM chat services" -ForegroundColor Gray
Write-Host "chatgpt           - Open ChatGPT" -ForegroundColor Gray
Write-Host "claude            - Open Claude" -ForegroundColor Gray
Write-Host "gemini            - Open Gemini" -ForegroundColor Gray
Write-Host "perplexity        - Open Perplexity AI" -ForegroundColor Gray
Write-Host "edit_profile      - Edit PowerShell profile" -ForegroundColor Gray
Write-Host "Start-Aseprite    - Starts Aseprite" -ForegroundColor Gray
Write-Host "Start-DoomEternal - Starts Doom Eternal" -ForegroundColor Gray
Write-Host "godot             - Starts godot" -ForegroundColor Gray
Write-Host "─────────────────────────────" -ForegroundColor DarkGray

#region Ect
function Start-Aseprite {
    # Check if Aseprite is already running
    $aspriteProcess = Get-Process | Where-Object { $_.MainWindowTitle -like "*Aseprite*" -or $_.ProcessName -like "*aseprite*" }
    
    if ($null -eq $aspriteProcess) {
        Write-Host "Aseprite is not running. Starting it up!"
    }
    else {
        Write-Host "Stopping Aseprite."
        $aspriteProcess | Stop-Process -Force
        # Give it a moment to fully close
        Start-Sleep -Seconds 2
    }

    # Verify the path exists before trying to start
    $aspritePath = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"
    if (Test-Path $aspritePath) {
        Start-Process -FilePath $aspritePath
    }
    else {
        Write-Host "Could not find Aseprite executable at expected path." -ForegroundColor Red
        Write-Host "Please verify the installation path: $aspritePath" -ForegroundColor Yellow
    }
}
function global:edge {
    Start-Process "C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe"
}
function global:devEdge {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Url
    )
    
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe"
    
    if ($Url) {
        Start-Process -FilePath $edgePath -ArgumentList $Url
    }
    else {
        Start-Process -FilePath $edgePath
    }
}

function globalL:ddump{}

#endregionste

