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
# Set working directory
try {
    Set-Location $CommonPaths.PowerShell
} catch {
    Write-Warning "Failed to set location to PowerShell directory: $_"
    Set-Location $HOME
}



# Execute each script individually
$scriptPaths = @(
    "C:\Users\Digital_Russkiy\Documents\PowerShell\Scripts\Initialize-OhMyPosh.ps1",
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

# Admin check
if ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "PowerShell is running with Administrator privileges"
}


# Call the function with auto-install option
Initialize-OhMyPosh -AutoInstall
# try {
#     oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\clean-detailed.omp.json" | Invoke-Expression
# } catch {
#     Write-Warning "Oh My Posh is not installed or there was an error loading the theme: $_"
#     Write-Host "To install Oh My Posh, run: winget install JanDeDobbeleer.OhMyPosh"
# }

# Initialize the start time before any operations
$startTime = Get-Date

# Add configuration validation
function Test-ProfileConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Config
    )
    
    $errors = @()
    
    # Check if Config is null or not a hashtable
    if ($null -eq $Config) {
        $errors += "Configuration is null"
        return @{
            IsValid = $false
            Errors = $errors
        }
    }
    
    if ($Config -isnot [hashtable]) {
        $errors += "Configuration must be a hashtable"
        return @{
            IsValid = $false
            Errors = $errors
        }
    }
    
    $requiredKeys = @('CommonPaths', 'UrlCollections', 'RequiredModules')
    
    foreach ($key in $requiredKeys) {
        if (-not $Config.ContainsKey($key)) {
            $errors += "Missing required configuration key: $key"
        }
    }
    
    if ($Config.ContainsKey('RequiredModules') -and $null -ne $Config.RequiredModules) {
        foreach ($module in $Config.RequiredModules) {
            if ($module -is [hashtable] -and -not $module.ContainsKey('Name')) {
                $errors += "Module configuration missing Name property"
            }
        }
    }
    
    return @{
        IsValid = ($errors.Count -eq 0)
        Errors = $errors
    }
}

# Initialize profile with validation
$configValidation = Test-ProfileConfiguration -Config $Config

if (-not $configValidation.IsValid) {
    Write-Warning "Profile configuration validation failed:"
    $configValidation.Errors | ForEach-Object { Write-Warning "  - $_" }
}

# Enhanced error logging
function Write-ProfileLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info',
        [string]$LogDirectory = $null
    )
    
    try {
        # Determine log directory with fallbacks
        $logDir = $LogDirectory ?? 
                 $CommonPaths.PowerShell ?? 
                 $PSScriptRoot ?? 
                 (Join-Path $HOME "Documents\PowerShell")

        # Ensure log directory exists
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }

        $logPath = Join-Path $logDir "profile.log"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] $Message"
        
        Add-Content -Path $logPath -Value $logMessage -ErrorAction Stop
        
        # Output to console
        switch ($Level) {
            'Info' { Write-Host $Message -ForegroundColor Gray }
            'Warning' { Write-Warning $Message }
            'Error' { Write-Error $Message }
        }
    }
    catch {
        # Fallback to just console output if logging fails
        Write-Warning "Failed to write to log file: $_"
        switch ($Level) {
            'Info' { Write-Host $Message -ForegroundColor Gray }
            'Warning' { Write-Warning $Message }
            'Error' { Write-Error $Message }
        }
    }
}


#region PSReadLine Configuration
if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    if ($Config.PSReadLine) {
        # Apply PSReadLine settings from config
        if ($Config.PSReadLine.ShowToolTips) { Set-PSReadLineOption -ShowToolTips }
        if ($Config.PSReadLine.PredictionSource) { Set-PSReadLineOption -PredictionSource $Config.PSReadLine.PredictionSource }
        if ($Config.PSReadLine.PredictionViewStyle) { Set-PSReadLineOption -PredictionViewStyle $Config.PSReadLine.PredictionViewStyle }
        if ($Config.PSReadLine.EditMode) { Set-PSReadLineOption -EditMode $Config.PSReadLine.EditMode }
    }
    
    # Custom key handlers
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
#region Aliases
function Initialize-PSReadLine {
    if (-not (Get-Module PSReadLine)) { return }
    
    $defaultConfig = @{
        ShowToolTips = $true
        PredictionSource = "History"
        PredictionViewStyle = "ListView"
        EditMode = "Windows"
    }
    
    $config = $Config.PSReadLine ?? $defaultConfig
    
    foreach ($option in $config.GetEnumerator()) {
        switch ($option.Key) {
            'Colors' {
                foreach ($color in $option.Value.GetEnumerator()) {
                    Set-PSReadLineOption -Colors @{$color.Key = $color.Value}
                }
            }
            'KeyBindings' {
                foreach ($binding in $option.Value.GetEnumerator()) {
                    Set-PSReadLineKeyHandler -Chord $binding.Key -Function $binding.Value
                }
            }
            default {
                Set-PSReadLineOption -$($option.Key) $option.Value
            }
        }
    }
    
    # Standard key bindings
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

function Import-EnvironmentSpecificConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ConfigDir = (Join-Path $PSScriptRoot "Environments")
    )
    
    # Determine environment
    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $domain = $env:USERDOMAIN
    $osVersion = [System.Environment]::OSVersion.Version
    
    # Possible config files to look for
    $configFiles = @(
        # Computer-specific config
        "$ConfigDir\computer-$computerName.psd1",
        # User-specific config
        "$ConfigDir\user-$userName.psd1",
        # Domain-specific config
        "$ConfigDir\domain-$domain.psd1",
        # OS-specific config (Windows 10/11)
        "$ConfigDir\os-win$($osVersion.Major).psd1"
    )
    
    $loadedConfigs = @()
    
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            try {
                $envConfig = Import-PowerShellDataFile -Path $file -ErrorAction Stop
                
                # Merge with main config
                foreach ($key in $envConfig.Keys) {
                    if ($Config.ContainsKey($key) -and $Config[$key] -is [hashtable] -and $envConfig[$key] -is [hashtable]) {
                        # Merge hashtables
                        foreach ($subKey in $envConfig[$key].Keys) {
                            $Config[$key][$subKey] = $envConfig[$key][$subKey]
                        }
                    }
                    else {
                        # Replace/add key
                        $Config[$key] = $envConfig[$key]
                    }
                }
                
                $loadedConfigs += (Split-Path -Path $file -Leaf)
                Write-Host "Loaded environment config: $(Split-Path -Path $file -Leaf)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to load environment config $file`: $_"
            }
        }
    }
    
    # Create the directory if it doesn't exist
    if (-not (Test-Path $ConfigDir)) {
        New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
        Write-Host "Created environments directory: $ConfigDir" -ForegroundColor Green
    }
    
    return $loadedConfigs
}

function Update-PowerShellModules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$ModuleNames = $Config.RequiredModules.Name,
        
        [Parameter(Mandatory=$false)]
        [switch]$AutoInstall,
        
        [Parameter(Mandatory=$false)]
        [switch]$UpdateExisting
    )
    
    if (-not $ModuleNames -or $ModuleNames.Count -eq 0) {
        Write-Warning "No modules specified for installation/update"
        return
    }
    
    $results = @{
        Installed = @()
        Updated = @()
        Failed = @()
        Skipped = @()
    }
    
    foreach ($moduleName in $ModuleNames) {
        $moduleInfo = $null
        
        # Find module info if it exists in config
        if ($Config.RequiredModules) {
            $moduleInfo = $Config.RequiredModules | Where-Object { 
                ($_ -is [string] -and $_ -eq $moduleName) -or
                ($_ -is [hashtable] -and $_.Name -eq $moduleName)
            }
        }
        
        $minVersion = $null
        if ($moduleInfo -is [hashtable] -and $moduleInfo.MinimumVersion) {
            $minVersion = $moduleInfo.MinimumVersion
        }
        
        # Check if module is installed
        $installedModule = Get-Module -Name $moduleName -ListAvailable
        
        if (-not $installedModule) {
            if ($AutoInstall) {
                try {
                    Write-Host "Installing module: $moduleName" -ForegroundColor Cyan -NoNewline
                    
                    $installParams = @{
                        Name = $moduleName
                        Scope = "CurrentUser"
                        Force = $true
                        ErrorAction = "Stop"
                    }
                    
                    if ($minVersion) {
                        $installParams.MinimumVersion = $minVersion
                    }
                    
                    Install-Module @installParams
                    Write-Host " - Installed!" -ForegroundColor Green
                    $results.Installed += $moduleName
                }
                catch {
                    Write-Host " - Failed!" -ForegroundColor Red
                    Write-Warning "Failed to install module $moduleName`: $_"
                    $results.Failed += @{
                        Name = $moduleName
                        Error = $_.Exception.Message
                    }
                }
            }
            else {
                Write-Warning "Module '$moduleName' is not installed. Use -AutoInstall to install it."
                $results.Skipped += $moduleName
            }
        }
        elseif ($UpdateExisting) {
            try {
                $currentVersion = ($installedModule | Sort-Object Version -Descending | Select-Object -First 1).Version
                
                Write-Host "Checking for updates: $moduleName v$currentVersion" -ForegroundColor Cyan -NoNewline
                
                $onlineModule = Find-Module -Name $moduleName -ErrorAction Stop
                
                if ($onlineModule.Version -gt $currentVersion) {
                    Write-Host " - Updating to v$($onlineModule.Version)" -ForegroundColor Yellow
                    
                    Update-Module -Name $moduleName -Force -ErrorAction Stop
                    $results.Updated += @{
                        Name = $moduleName
                        OldVersion = $currentVersion
                        NewVersion = $onlineModule.Version
                    }
                }
                else {
                    Write-Host " - Up to date!" -ForegroundColor Green
                    $results.Skipped += $moduleName
                }
            }
            catch {
                Write-Host " - Update failed!" -ForegroundColor Red
                Write-Warning "Failed to update module $moduleName`: $_"
                $results.Failed += @{
                    Name = $moduleName
                    Error = $_.Exception.Message
                }
            }
        }
    }
    
    return $results
}

# Auto-update modules if specified in config
if ($Config.AutoUpdateModules -eq $true) {
    Update-PowerShellModules -AutoInstall -UpdateExisting
}





# ----WELCOME MESSAGE----
Show-Welcome -ShowCommands 
# ----END WELCOME MESSAGE----




#Aliases for shorter commands
Set-Alias -Name 'aisearch' -Value 'Open-AiSearch'
Set-Alias -Name 'google-core' -Value 'Open-GoogleCore'
Set-Alias -Name 'google-productivity' -Value 'Open-GoogleProductivity'
Set-Alias -Name 'google-media' -Value 'Open-GoogleMedia'
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name reload -Value Update-PowerShellProfile