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

.NOTES
Author: Svyatoslav Oleg Russkiy
Version: 5.0
#>

# Check for admin privileges and auto-elevate if needed
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevating to administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& {. '$PSCommandPath'}`""
    exit
}

# Start timing the profile load
$profileLoadTime = [System.Diagnostics.Stopwatch]::StartNew()

#region Initialization
$ErrorActionPreference = 'Continue'
$scriptsDir = Join-Path $PSScriptRoot "Scripts"
$coreDir = Join-Path $scriptsDir "Core"

# Set up environment
$env:PATH = @(
    $env:PATH,
    "C:\Users\Digital_Russkiy\AppData\Local\Microsoft\PowerToys\PowerToys Run",
    (Get-CommonPaths).Scripts
) -join ";"

# Load essential modules
$essentialModules = @(
    @{Name = 'PSReadLine'; Purpose = 'Enhanced console experience' }
    @{Name = 'posh-git'; Purpose = 'Git integration' }
)

foreach ($module in $essentialModules) {
    try {
        if (-not (Get-Module -Name $module.Name -ListAvailable)) {
            Write-Host "Installing module: $($module.Name)..." -ForegroundColor Cyan
            Install-Module -Name $module.Name -Force -Scope CurrentUser -ErrorAction Stop
        }
        Import-Module -Name $module.Name -Force -ErrorAction Stop
        Write-Host "✓ Loaded $($module.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to load $($module.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Configure PSReadLine
if (Get-Module -Name PSReadLine) {
    try {
        Set-PSReadLineOption -ShowToolTips:$true `
            -PredictionSource History `
            -PredictionViewStyle ListView `
            -EditMode Windows `
            -HistorySaveStyle SaveIncrementally

        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Write-Host "✓ PSReadLine configured" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Error configuring PSReadLine: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Initialize Oh My Posh with fallback
try {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnosterplus.omp.json" | Invoke-Expression
    Write-Host "✓ Oh My Posh initialized" -ForegroundColor Green
}
catch {
    function prompt {
        $currentLocation = Get-Location
        $gitBranch = if (Get-Command -Name git -ErrorAction SilentlyContinue) { 
            " [" + (git branch --show-current) + "]" 
        }
        else { "" }
        Write-Host "PS " -NoNewline -ForegroundColor Blue
        Write-Host "$($currentLocation)" -NoNewline -ForegroundColor Yellow
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Green
        return "> "
    }
}

#region Utility Functions
function restart {
    Write-Host "`n🔄 Restarting PowerShell session..." -ForegroundColor Cyan
    Clear-Host
    . $PROFILE
    Write-Host "✓ PowerShell session restarted successfully!" -ForegroundColor Green
}

function sleep {
    Write-Host "`n💤 Putting computer to sleep..." -ForegroundColor Cyan
    try {
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
    catch {
        Write-Host "Failed to put computer to sleep: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function programs {
    Write-Host "`n📦 Listing installed programs..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    
    Write-Host "`nWinget Programs:" -ForegroundColor Cyan
    winget list | Sort-Object -Property Name

    Write-Host "`nChocolatey Programs:" -ForegroundColor Cyan
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco list --local-only | Sort-Object
    }
    else {
        Write-Host "Chocolatey is not installed" -ForegroundColor Yellow
    }

    Write-Host "`nScoop Programs:" -ForegroundColor Cyan
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop list | Sort-Object
    }
    else {
        Write-Host "Scoop is not installed" -ForegroundColor Yellow
    }
}

# Profile completion
$profileLoadTime.Stop()
Write-Host "`n🚀 Profile loaded in $([math]::Round($profileLoadTime.ElapsedMilliseconds))ms" -ForegroundColor Cyan
Write-Host "⚡ Running with administrator privileges" -ForegroundColor Green
