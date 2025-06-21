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
$newPaths = @()
if ($Config -and $Config.EnvironmentPaths) {
    $newPaths = $Config.EnvironmentPaths | Where-Object { $_ -and (Test-Path $_) } | ForEach-Object { (Resolve-Path $_).Path }
    $env:PATH = ($env:PATH.Split(';') + $newPaths | Select-Object -Unique) -join ";"
}
# Check for admin privileges
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "⚡ Running with administrator privileges" -ForegroundColor Yellow
}
else {
    Write-Host " Is not currently Admin."
}

# node
$env:NODE_OPTIONS = "--openssl-legacy-provider"

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "Node.js is installed" -ForegroundColor Green
}
else {
    Write-Host "Node.js is not installed" -ForegroundColor Red
}

# load in Scripts
# function LoadCoreScripts {
#     [CmdletBinding()]
#     param(
#         [switch]$ShowVerbose
#     )
#     foreach ($category in $Config.LoadOrder) {
#         if ($Config.ScriptCategories.ContainsKey($category)) {
#             foreach ($script in $Config.ScriptCategories[$category]) {
#                 $scriptPath = Join-Path $CommonPaths.Scripts $category $script
#                 if (Test-Path $scriptPath) {
#                     try {
#                         if ($ShowVerbose) { Write-Host "Loading $scriptPath..." -ForegroundColor Cyan }
#                         . $scriptPath
#                         if ($ShowVerbose) { Write-Host "Loaded $scriptPath" -ForegroundColor Green }
#                     }
#                     catch {
#                         Write-Warning ("Failed to load {0}: {1}" -f $scriptPath, $_.Exception.Message)
#                     }
#                 }
#                 else {
#                     Write-Warning "Script not found: $scriptPath"
#                 }
#             }
#         }
#     }
# }

. "$PSScriptRoot\Scripts\URL\LLM-Funk.ps1"
. "$PSScriptRoot\Scripts\URL\Search-pkgs.ps1"
# . "$PSScriptRoot\Scripts\URL\Godot-Funk.ps1"
. "$PSScriptRoot\Scripts\Core\Aliases.ps1"
. "$PSScriptRoot\Scripts\Core\Module-Management.ps1"
. "$PSScriptRoot\Scripts\Networking\SSH-Tools.ps1"
. "$PSScriptRoot\Scripts\UI\Prompt-Configuration.ps1"

# Load scripts efficiently
# foreach ($category in $Config.LoadOrder) { ... }


#region Profile Completion
$loadTime = (Get-Date) - $profileLoadStart
Write-Host "PowerShell profile loaded in $([math]::Round($loadTime.TotalMilliseconds))ms!" -Level 'Success'

# Display available commands
Write-Host "`nAvailable Commands:" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

Write-Host "Start-Aseprite              - Starts Aseprite       |          Start-DoomEternal           - Starts Doom Eternal" -ForegroundColor Gray
Write-Host "Start-DoomEternal           - Starts Doom Eternal" -ForegroundColor Gray
Write-Host "godot                       - Starts godot" -ForegroundColor Gray
Write-Host "edge                        - Starts Edge" -ForegroundColor Gray

Write-Host "ghub                        - Go to Github Folder and list" -ForegroundColor Gray
Write-Host "ddump                       - Go to DigitalHubDump Folder" -ForegroundColor Gray
Write-Host "edit_powershell             - Edit my powersehll Profile" -ForegroundColor Gray

Write-Host "Search-CommandHistory or h  - Search Commands History" -ForegroundColor Gray
Write-Host "list_llm                    - List of my llms" -ForegroundColor Gray
Write-Host "h <pattern>                 - Search command history" -ForegroundColor Gray
Write-Host "programs                    - List Programs" -ForegroundColor Gray

Write-Host "TwitchOverlay               - Launches Twitch Chat OVerlay" -ForegroundColor Gray
Write-Host "Get-StockMarketSummary      - Get-StockMarketSummary" -ForegroundColor Gray
Write-Host "New-QRCode                  - Generate a QR code" -ForegroundColor Gray

Write-Host "Get-MyIP                    - Get my IP" -ForegroundColor Gray
Write-Host "Get-BIOSInfo                - Get-BIOSInfo  " -ForegroundColor Gray
Write-Host "Get-SshStatus               - Get the status of SSH (might need elevated permission)" -ForegroundColor Gray

Write-Host "Search-GoPackages           - Search Go pachages" -ForegroundColor Gray
Write-Host "Get-AllFunctions            - Show all available functions by category" -ForegroundColor Gray
Write-Host "Get-FunctionHelp            - Show detailed help for a specific function" -ForegroundColor Gray

Write-Host "TwitchOverlay               - Opens up my Twitch ocerlay" -ForegroundColor Gray

Write-Host "Search-GoPackages           - Search Go package to install " -ForegroundColor Gray
Write-Host "Search-PyPiPackages         - Search python package to install " -ForegroundColor Gray
Write-Host "Search-GitHubRepositories   - Search Github Repo package to install " -ForegroundColor Gray
Write-Host "Search-NpmPackages          - Search Node Package Manager " -ForegroundColor Gray


Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

# Display social media functions if available
if (Get-Command Get-SocialFunctions -ErrorAction SilentlyContinue) {
    Write-Host "`n📱 Social Media Functions:" -ForegroundColor Cyan
    
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    Write-Host "social [Open-SocialChat]  - Open all social media platforms" -ForegroundColor Gray
    Write-Host "listsocial [Get-SocialFunctions] - Show all social media functions" -ForegroundColor Gray
    Write-Host "socialcats [Get-SocialCategories] - Show social media categories" -ForegroundColor Gray
    Write-Host "facebook, twitter, youtube, twitch, etc. - Open specific platforms" -ForegroundColor Gray
    
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
}

#region Additional Functions
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

#region Error Handling

if (-not $global:ProfileCallDepth) { $global:ProfileCallDepth = 0 }
$global:ProfileCallDepth++
Write-Host "Profile call depth: $global:ProfileCallDepth"
if ($global:ProfileCallDepth -gt 10) {
    throw "Profile loaded too many times! Possible recursion."
}

if (-not (Get-Command Write-ProfileLog -ErrorAction SilentlyContinue)) {
    function Write-ProfileLog { param($msg, $Level) Write-Host "${Level}: ${msg}" }
}