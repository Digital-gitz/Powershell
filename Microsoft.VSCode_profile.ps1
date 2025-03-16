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

# Execute each script individually
$scriptPaths = @(
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Initialize-OhMyPosh.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\ConfigValidation.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\winfetch-pro.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\profile-Metrics.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Welcome-Message.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Utility-Functions.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Module-Management.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Package-Management.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Initialize-PSReadLine.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\URL-Commands.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\winget-install.ps1",
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Notes-Function.ps1"
)

# Load Script-handler first
. "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Script-Managment.ps1"

# Then load other scripts
foreach ($script in $scriptPaths) {
    if (Test-Path $script) {
        . $script
    } else {
        Write-Warning "Script not found: $script"
    }
}

$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.psd1'

# Load configuration file
$Config = try {
    $configData = Import-PowerShellDataFile -Path $ConfigPath -ErrorAction Stop
    if ($configData -isnot [hashtable]) { throw "Configuration must be a hashtable" }
    Write-Host "Configuration loaded successfully" -ForegroundColor Green
    $configData
} catch {
    Write-Warning "Failed to load configuration: $_"
    # Default configuration
    @{
        CommonPaths = @{
            PowerShell = $PSScriptRoot
            Scripts = Join-Path $PSScriptRoot "Scripts"
            Documents = [Environment]::GetFolderPath('MyDocuments')
        }
        UrlCollections = @{}
        RequiredModules = @()
        PSReadLine = @{
            ShowToolTips = $true
            PredictionSource = "History"
            PredictionViewStyle = "ListView"
            EditMode = "Windows"
        }
    }
}

# Initialize paths 
$CommonPaths = @{}
foreach ($key in $Config.CommonPaths.Keys) {
    $pathValue = $Config.CommonPaths[$key]
    if ($pathValue -is [string]) {
        $pathValue = $ExecutionContext.InvokeCommand.ExpandString($pathValue)
    }
    $CommonPaths[$key] = $pathValue
}

# Set fallbacks only if needed
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

# Admin check
if ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "PowerShell is running with Administrator privileges"
}



# ----WELCOME MESSAGE----
Show-Welcome -ShowCommands 
# ----END WELCOME MESSAGE----

Import-Module -Name Terminal-Icons
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnosterplus.omp.json" | Invoke-Expression
#region Aliases
#Aliases for shorter commands
Set-Alias -Name 'aisearch' -Value 'Open-AiSearch'
Set-Alias -Name 'google-core' -Value 'Open-GoogleCore'
Set-Alias -Name 'google-productivity' -Value 'Open-GoogleProductivity'
Set-Alias -Name 'google-media' -Value 'Open-GoogleMedia'
Set-Alias -Name clr -Value Clear-Host

# Define function for home directory
function Set-HomeLocation { Set-Location $HOME }
Set-Alias -Name home -Value Set-HomeLocation
# Set basic aliases
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name reload -Value Update-PowerShellProfile 