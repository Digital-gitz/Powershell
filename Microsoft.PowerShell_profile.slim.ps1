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
#>

#region Performance Tracking
$global:ProfileStartTime = Get-Date
$global:MetricsEnabled = $true
$global:ProfileMetrics = @{}

function Register-ProfileMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][datetime]$StartTime,
        [switch]$IsError,
        [string]$Details
    )
    
    if (-not $global:MetricsEnabled) { return }
    
    $duration = (Get-Date) - $StartTime
    $global:ProfileMetrics[$Name] = @{
        Duration = $duration
        IsError = $IsError
        Timestamp = Get-Date
        Details = $Details
        Category = (Get-PSCallStack)[1].Command
    }
}

function Initialize-OhMyPosh {
    [CmdletBinding()]
    param(
        [string]$ThemeName = "clean-detailed",
        [switch]$AutoInstall
    )

    try {
        # Check if Oh My Posh is installed
        if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
            Write-Warning "Oh My Posh is not installed"
            
            if ($AutoInstall) {
                Write-Host "Attempting to install Oh My Posh..." -ForegroundColor Cyan
                try {
                    # Check if winget is available
                    if (Get-Command winget -ErrorAction SilentlyContinue) {
                        winget install JanDeDobbeleer.OhMyPosh --accept-source-agreements --accept-package-agreements
                        
                        # Refresh environment path
                        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                        
                        Write-Host "Oh My Posh installed successfully!" -ForegroundColor Green
                    } else {
                        Write-Warning "Winget is not available. Please install Oh My Posh manually:"
                        Write-Host "Visit: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Yellow
                        return
                    }
                } catch {
                    Write-Error "Failed to install Oh My Posh: $_"
                    return
                }
            } else {
                Write-Host "To install Oh My Posh, you can:" -ForegroundColor Yellow
                Write-Host "1. Run: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Cyan
                Write-Host "2. Visit: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Cyan
                Write-Host "3. Rerun this profile with -AutoInstall to install automatically" -ForegroundColor Cyan
                return
            }
        }

        # Check if theme exists
        $themePath = Join-Path $env:POSH_THEMES_PATH "$ThemeName.omp.json"
        if (-not (Test-Path $themePath)) {
            Write-Warning "Theme '$ThemeName' not found at: $themePath"
            Write-Host "Available themes:" -ForegroundColor Yellow
            Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json | 
                Select-Object -ExpandProperty BaseName |
                ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
            return
        }

        # Initialize Oh My Posh
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
        Write-Host "Oh My Posh initialized with theme: $ThemeName" -ForegroundColor Green

    } catch {
        Write-Error "Error initializing Oh My Posh: $_"
        Write-Host "For troubleshooting, visit: https://ohmyposh.dev/docs/installation/troubleshooting" -ForegroundColor Yellow
    }
}

function Show-ProfileMetrics {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [switch]$SortByDuration
    )
    
    if (-not $global:MetricsEnabled) {
        Write-Warning "Metrics are not enabled."
        return
    }
    
    $metrics = $global:ProfileMetrics.GetEnumerator()
    
    if ($SortByDuration) {
        $metrics = $metrics | Sort-Object { $_.Value.Duration.TotalMilliseconds } -Descending
    } else {
        $metrics = $metrics | Sort-Object Name
    }
    
    $totalTime = ($metrics | Measure-Object -Property { $_.Value.Duration.TotalMilliseconds } -Sum).Sum
    
    Write-Host "`nProfile Load Metrics" -ForegroundColor Cyan
    Write-Host "Total Load Time: $([math]::Round($totalTime, 2)) ms" -ForegroundColor Yellow
    
    if ($Detailed) {
        Write-Host "`nDetailed Metrics:" -ForegroundColor Cyan
        foreach ($metric in $metrics) {
            $color = if ($metric.Value.IsError) { "Red" } else { "Green" }
            $durationMs = [math]::Round($metric.Value.Duration.TotalMilliseconds, 2)
            $percentage = [math]::Round(($metric.Value.Duration.TotalMilliseconds / $totalTime) * 100, 1)
            
            Write-Host ("{0,-30}" -f $metric.Name) -NoNewline
            Write-Host ("{0,10:N2} ms" -f $durationMs) -NoNewline -ForegroundColor $color
            Write-Host ("{0,10:N1} %" -f $percentage) -ForegroundColor DarkGray
        }
    } else {
        # Show top 5 most time-consuming operations
        Write-Host "`nTop 5 operations by duration:" -ForegroundColor Cyan
        $metrics | Select-Object -First 5 | ForEach-Object {
            $durationMs = [math]::Round($_.Value.Duration.TotalMilliseconds, 2)
            $percentage = [math]::Round(($_.Value.Duration.TotalMilliseconds / $totalTime) * 100, 1)
            Write-Host ("{0,-30}" -f $_.Name) -NoNewline
            Write-Host ("{0,10:N2} ms" -f $durationMs) -NoNewline -ForegroundColor Green
            Write-Host ("{0,10:N1} %" -f $percentage) -ForegroundColor DarkGray
        }
    }
}

# Start timing the profile load
$global:ProfileStartTime = Get-Date

# Initialize base paths and configuration
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.psd1'

# Load configuration file
try {
    $Config = Import-PowerShellDataFile -Path $ConfigPath
    Write-Host "Configuration loaded" -ForegroundColor Green
} catch {
    Write-Warning "Failed to load configuration: $_"
    $Config = @{
        CommonPaths = @{
            PowerShell = $PSScriptRoot
            Scripts = Join-Path $PSScriptRoot "Scripts"
            Documents = [Environment]::GetFolderPath('MyDocuments')
        }
        UrlCollections = @{}
    }
}

# Initialize paths from config with variable expansion
$CommonPaths = @{}
foreach ($key in $Config.CommonPaths.Keys) {
    $pathValue = $Config.CommonPaths[$key]
    if ($pathValue -is [string]) {
        $pathValue = $ExecutionContext.InvokeCommand.ExpandString($pathValue)
    }
    $CommonPaths[$key] = $pathValue
}

# Ensure essential paths exist
$CommonPaths.PowerShell ??= $PSScriptRoot
$CommonPaths.Scripts ??= Join-Path $CommonPaths.PowerShell "Scripts"
$CommonPaths.Documents ??= [Environment]::GetFolderPath('MyDocuments')

# Set working directory
try {
    Set-Location $CommonPaths.PowerShell
} catch {
    Write-Warning "Failed to set location to PowerShell directory: $_"
    Set-Location $HOME
}

# Import modular scripts in specific order
$ScriptModules = @(
    'Initialize-Metrics.ps1'      # Must be first
    'Initialize-Config.ps1'
    'Initialize-OhMyPosh.ps1'
    'Initialize-PSReadLine.ps1'
    'Package-Management.ps1'
    'Module-Management.ps1'
    'URL-Commands.ps1'
    'Utility-Functions.ps1'
    'Profile-Commands.ps1'
)

# Load each module with error handling
foreach ($module in $ScriptModules) {
    $modulePath = Join-Path $CommonPaths.Scripts $module
    $startTime = Get-Date
    try {
        if (Test-Path $modulePath) {
            . $modulePath
            Register-ProfileMetric -Name "Load:$module" -StartTime $startTime
            Write-Verbose "Loaded module: $module"
        } else {
            Write-Warning "Module script not found: $module"
            Register-ProfileMetric -Name "Load:$module" -StartTime $startTime -IsError -Details "File not found"
        }
    } catch {
        Write-Error "Failed to load module $module`: $_"
        Register-ProfileMetric -Name "Load:$module" -StartTime $startTime -IsError -Details $_.Exception.Message
    }
}

# Configure PSReadLine if available
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
}

# Initialize Oh My Posh
Initialize-OhMyPosh -AutoInstall

# Admin check
if ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "PowerShell is running with Administrator privileges"
}

# Show welcome screen and metrics
Show-Welcome -ShowCommands
Show-ProfileMetrics -Detailed

# Clear any leftover variables
$Global:OhMyPoshCache = $null
