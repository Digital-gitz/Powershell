#region Script Configuration
<#
.SYNOPSIS
Optimized PowerShell profile script with essential functionality.

.DESCRIPTION
A streamlined PowerShell profile that provides:
- Custom prompt and console customization
- Utility functions and aliases
- Module management and environment setup
- Enhanced error handling and logging
- Performance optimization
- Improved script loading with dependency management
- Better error recovery and fallback mechanisms

.NOTES
Author: Svyatoslav Oleg Russkiy
Version: 4.0
#>

# Start timing the profile load
# This creates a stopwatch object to measure how long it takes to load the PowerShell profile
# The StartNew() method creates and starts the stopwatch immediately
# The $profileLoadTime variable will be used later to report the total load time
$profileLoadTime = [System.Diagnostics.Stopwatch]::StartNew()

#region Initialization
$ErrorActionPreference = 'Continue'
$scriptsDir = Join-Path $PSScriptRoot "Scripts"
$coreDir = Join-Path $scriptsDir "Core"

# Load core modules first
. (Join-Path $coreDir "Logging.ps1")
. (Join-Path $coreDir "Configuration.ps1")
. (Join-Path $coreDir "ScriptLoading.ps1")
. (Join-Path $coreDir "Aliases.ps1")

# Set up environment
$env:PATH = @($env:PATH, "C:\Users\Digital_Russkiy\AppData\Local\Microsoft\PowerToys\PowerToys Run", (Get-CommonPaths).Scripts) -join ";"
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) { Write-Log "PowerShell is running with Administrator privileges" -Level 'Warning' }

# Load required modules
$config = Get-Configuration
foreach ($module in $config.RequiredModules) {
    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $installedModule = Get-Module -Name $module.Name -ListAvailable
        if (-not $installedModule) {
            Write-Log "Installing module: $($module.Name)" -Level 'Info'
            Install-Module -Name $module.Name -Force -Scope ($module.Scope ?? 'CurrentUser') -ErrorAction Stop
        }
        Import-Module -Name $module.Name -Force -ErrorAction Stop
        $sw.Stop()
        $performanceMetrics.ModuleLoadTimes[$module.Name] = $sw.ElapsedMilliseconds
        Write-Log "Imported module: $($module.Name) in $($sw.ElapsedMilliseconds)ms" -Level 'Success'
    }
    catch {
        Write-Log "Error managing module $($module.Name) : $_" -Level 'Error'
    }
}
curl terminal-stocks.dev/market-summary
# Configure PSReadLine
if (Get-Module -Name PSReadLine) {
    try {
        Set-PSReadLineOption -ShowToolTips:$config.PSReadLine.ShowToolTips
        Set-PSReadLineOption -PredictionSource $config.PSReadLine.PredictionSource
        Set-PSReadLineOption -PredictionViewStyle $config.PSReadLine.PredictionViewStyle
        Set-PSReadLineOption -EditMode $config.PSReadLine.EditMode
        Set-PSReadLineOption -HistorySavePath $config.PSReadLine.HistorySavePath
        Set-PSReadLineOption -HistorySaveStyle $config.PSReadLine.HistorySaveStyle

        Set-PSReadLineKeyHandler -Key Tab -Function Complete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Write-Log "PSReadLine configured successfully" -Level 'Success'
    }
    catch {
        Write-Log "Error configuring PSReadLine: $_" -Level 'Error'
    }
}

# Initialize Oh My Posh with fallback
try {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnosterplus.omp.json" | Invoke-Expression
    Write-Log "Oh My Posh initialized successfully" -Level 'Success'
}
catch {
    Write-Log "Failed to initialize Oh My Posh: $_" -Level 'Error'
    function prompt {
        $currentLocation = Get-Location
        $adminIndicator = if ($isAdmin) { "[ADMIN] " } else { "" }
        $gitBranch = if (Get-Command -Name git -ErrorAction SilentlyContinue) { 
            " [" + (git branch --show-current) + "]" 
        }
        else { "" }
        Write-Host "$adminIndicator" -NoNewline -ForegroundColor Red
        Write-Host "PS " -NoNewline -ForegroundColor Blue
        Write-Host "$($currentLocation)" -NoNewline -ForegroundColor Yellow
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Green
        return "> "
    }
}

# Load all scripts
Import-AllScripts

# Set up aliases
Set-ProfileAliases

# Profile load completion and performance reporting
$profileLoadTime.Stop()
$performanceMetrics.TotalLoadTime = $profileLoadTime.ElapsedMilliseconds

Write-Log "Profile loaded in $($profileLoadTime.ElapsedMilliseconds)ms" -Level 'Success'
Write-Log "Script load times:" -Level 'Debug'
$performanceMetrics.ScriptLoadTimes.GetEnumerator() | ForEach-Object {
    Write-Log "  $($_.Key): $($_.Value)ms" -Level 'Debug' -NoConsole
}
Write-Log "Module load times:" -Level 'Debug'
$performanceMetrics.ModuleLoadTimes.GetEnumerator() | ForEach-Object {
    Write-Log "  $($_.Key): $($_.Value)ms" -Level 'Debug' -NoConsole
}

# Display welcome information
try {
    if (Get-Command -Name Get-ScriptsFunctions -ErrorAction SilentlyContinue) { 
        Get-ScriptsFunctions 
    }
    else {
        Write-Log "Get-ScriptsFunctions command not found" -Level 'Warning'
    }
}
catch {
    Write-Log "Error executing Get-ScriptsFunctions: $_" -Level 'Error'
}

try {
    if (Get-Command -Name Show-Welcome -ErrorAction SilentlyContinue) { 
        Show-Welcome -ShowSystemInfo -ShowCommands 
    }
    else {
        Write-Log "Show-Welcome command not found" -Level 'Warning'
    }
}
catch {
    Write-Log "Error executing Show-Welcome: $_" -Level 'Error'
} 

function restart {
    Write-Host "`n🔄 Restarting PowerShell session..." -ForegroundColor Cyan
    Clear-Host
    . $PROFILE
    Write-Host "✓ PowerShell session restarted successfully!" -ForegroundColor Green
}

function sleep {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class SleepHelper {
        [DllImport("powrprof.dll", SetLastError = true)]
        public static extern bool SetSuspendState(bool hibernate, bool forceCritical, bool disableWakeEvent);
    }
"@ -PassThru | Out-Null

    [SleepHelper]::SetSuspendState($false, $true, $true)
}

# $global:PSColor = @{
#     File = @{
#         Default    = @{ Color = 'White' }
#         Directory  = @{ Color = 'Cyan' }
#         Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' } 
#         Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
#         Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
#         Text       = @{ Color = 'Yellow'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
#         Compressed = @{ Color = 'Green'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
#     }
# }


#endregion Initialization
# $env:Path = "C:\Users\Digital_Russkiy\.local\bin;$env:Path"
# clear catch 
# $env:PSModulePath  #get modpath 
# Get-ChildItem $env:TEMP\NuGetScratch -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force 
# telnet mapscii.me   