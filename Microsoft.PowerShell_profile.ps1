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
# Dot-source the Initialize-OhMyPosh script using absolute path
$scriptPath = "$PSScriptRoot\Scripts\Initialize-OhMyPosh.ps1"
if (Test-Path $scriptPath) {
    . $scriptPath
} else {
    Write-Warning "Initialize-OhMyPosh.ps1 not found at: $scriptPath"
}

# Move this function definition to the top of your profile, right after any initial comments
function Register-ProfileMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [DateTime]$StartTime,
        
        [Parameter()]
        [bool]$IsError = $false
    )
    
    $duration = (Get-Date) - $StartTime
    $metrics = @{
        Name = $Name
        Duration = $duration
        IsError = $IsError
    }
    
    if (-not (Get-Variable -Name ProfileMetrics -ErrorAction SilentlyContinue)) {
        $Global:ProfileMetrics = @()
    }
    $Global:ProfileMetrics += [PSCustomObject]$metrics
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



# function Global:prompt {"PS [$Env:username]$PWD`n>"} 
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.psd1'

# Load configuration file
if (Test-Path $ConfigPath) {
    try {
        # Import the configuration file directly
        $Config = Import-PowerShellDataFile -Path $ConfigPath -ErrorAction Stop
        
        # Verify that $Config is a hashtable
        if ($Config -isnot [hashtable]) {
            throw "Configuration must be a hashtable"
        }
        
        Write-Host "Configuration loaded successfully" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to load configuration: $_"
        # Provide default configuration
        $Config = @{
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
} else {
    Write-Warning "Configuration file not found at: $ConfigPath"
    # Same default configuration as above
    $Config = @{
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


# Initialize URL collections from config with proper categorization
$UrlCollections = @{}
foreach ($category in $Config.UrlCollections.Keys) {
    $UrlCollections[$category] = @{}
    foreach ($subcategory in $Config.UrlCollections[$category].Keys) {
        $UrlCollections[$category][$subcategory] = $Config.UrlCollections[$category][$subcategory]
    }
}

# Set working directory
try {
    Set-Location $CommonPaths.PowerShell
} catch {
    Write-Warning "Failed to set location to PowerShell directory: $_"
    Set-Location $HOME
}

#region Module Management
function Import-RequiredModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose,
        [string]$Version,
        [switch]$Parallel
    )
    
    $job = {
        param($ModuleName, $Version)
        try {
            if (-not (Get-Module -Name $ModuleName -ListAvailable)) {
                if ($Version) {
                    Install-Module -Name $ModuleName -RequiredVersion $Version -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
                } else {
                    Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
                }
            }
            Import-Module -Name $ModuleName -ErrorAction Stop | Out-Null
            # Return nothing on success
            return $null
        } catch {
            return @{ Success = $false; Message = $_.Exception.Message }
        }
    }

    if ($Parallel) {
        $result = Start-Job -ScriptBlock $job -ArgumentList $Name, $Version | 
            Receive-Job -Wait -AutoRemoveJob
        # Only output if there was an error
        if ($result) {
            Write-Warning "Failed to import module $Name`: $($result.Message)"
        }
    } else {
        $result = & $job $Name $Version
        # Only output if there was an error
        if ($result) {
            Write-Warning "Failed to import module $Name`: $($result.Message)"
        }
    }
}

# Import modules if in console host
if ($host.Name -eq 'ConsoleHost' -and $Config.RequiredModules) {
    foreach ($module in $Config.RequiredModules) {
        Import-RequiredModule -Name $module.Name -Purpose $module.Purpose
    }
}

#region Custom Scripts
$CommonPaths.Scripts = $env:PS_SCRIPTS_PATH ?? (Join-Path $CommonPaths.PowerShell "Scripts")

function Import-CustomScript {
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose
    )
    
    # Ensure Scripts directory exists
    if (-not (Test-Path $CommonPaths.Scripts)) {
        New-Item -Path $CommonPaths.Scripts -ItemType Directory -Force | Out-Null
    }
    
    try {
        $scriptPath = Join-Path $CommonPaths.Scripts $Name
        if (Test-Path $scriptPath) {
            . $scriptPath
        } else {
            Write-Warning "Script not found: $scriptPath"
        }
    } catch {
        Write-Warning "Failed to load script: $Name"
    }
}

# Load custom scripts
if ($Config.CustomScripts) {
    foreach ($script in $Config.CustomScripts) {
        Import-CustomScript -Name $script.Name -Purpose $script.Purpose
    }
}

#region Utility Functions
# Generate GUID
function Get-Guid { [guid]::NewGuid().ToString() }

# Enhanced PSModulePath management
function Update-ModulePath {
    [Alias('modpath')]
    param (
        [switch]$Formatted,
        [switch]$Add,
        [string]$Path
    )
    
    if ($Add -and $Path -and (Test-Path $Path)) {
        $env:PSModulePath = "$Path;$env:PSModulePath"
    }
    
    $paths = $env:PSModulePath -split ';'
    if ($Formatted) {
        $paths | ForEach-Object { Write-Host "- $_" -ForegroundColor Cyan }
    } else {
        $paths
    }
}

Update-ModulePath

# Function to create new module

# Function to create new module
function New-PowerShellModule {
    [CmdletBinding()]
    [Alias('addmodule')]
    param (
        [Parameter(Position = 0)]
        [string]$ModuleName = $(Read-Host "Enter module name"),
        
        [Parameter()]
        [string]$Author = $env:USERNAME,
        
        [Parameter()]
        [string]$Description = "PowerShell module created by $Author",
        
        [Parameter()]
        [Version]$Version = "0.1.0",
        
        [Parameter()]
        [string]$OutputPath
    )
    
    if ([string]::IsNullOrWhiteSpace($ModuleName)) {
        Write-Error "Module name cannot be empty"
        return
    }
    
    try {
        # Determine the module path
        if (-not $OutputPath) {
            $modulePath = Join-Path $CommonPaths.Documents "PowerShell\Modules\$ModuleName"
        } else {
            $modulePath = Join-Path $OutputPath $ModuleName
        }
        
        # Create the module directory
        if (Test-Path $modulePath) {
            Write-Warning "Module directory already exists: $modulePath"
            $overwrite = Read-Host "Do you want to overwrite? (Y/N)"
            if ($overwrite -ne "Y") {
                Write-Host "Operation cancelled" -ForegroundColor Yellow
                return
            }
        }
        
        New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
        
        # Create module manifest
        $manifestPath = Join-Path $modulePath "$ModuleName.psd1"
        $moduleScriptPath = Join-Path $modulePath "$ModuleName.psm1"
        
        # Create base module file
        @"
<#
.SYNOPSIS
$Description

.DESCRIPTION
$Description

.NOTES
Author: $Author
Version: $Version
#>

# Export functions
Export-ModuleMember -Function *
"@ | Out-File -FilePath $moduleScriptPath -Encoding utf8
        
        # Create module manifest
        New-ModuleManifest -Path $manifestPath `
            -RootModule "$ModuleName.psm1" `
            -Author $Author `
            -Description $Description `
            -ModuleVersion $Version `
            -PowerShellVersion "5.1" `
            -FunctionsToExport "*" `
            -CmdletsToExport @() `
            -VariablesToExport @() `
            -AliasesToExport @()
        
        # Update module path
        Update-ModulePath -Add -Path $modulePath
        
        Write-Host "Module created successfully at $modulePath" -ForegroundColor Green
        Write-Host "Module manifest: $manifestPath" -ForegroundColor Cyan
        Write-Host "Module script: $moduleScriptPath" -ForegroundColor Cyan
    } catch {
        Write-Error "Failed to create module: $_"
    }
}

# Profile reload function
function Update-PowerShellProfile {
    [CmdletBinding()]
    [Alias('reload')]
    param(
        [switch]$SkipConfirmation
    )
    
    if (-not $SkipConfirmation) {
        Write-Host "Reloading PowerShell profile..." -ForegroundColor Yellow
    }
    
    try {
        . $PROFILE
        Write-Host "Profile reloaded successfully" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Failed to reload profile: $_"
        return $false
    }
}

# Consolidate duplicate Open-Urls functions

# Consolidate duplicate Show-Welcome functions
function Show-Welcome {
    [CmdletBinding()]
    param(
        [switch]$ShowCommands,
        [switch]$ShowSystemInfo,
        [int]$DelaySeconds = 2
    )
    
    $startTime = Get-Date
    
    $TColor = "Cyan"
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Logo = @"
 ___ _             ____  _       _ _        _      
|_ _( )_ __ ___   |  _ \(_) __ _(_) |_ __ _| |     
 | ||/| '_ ` _ \  | | | | |/ _` | | __/ _` | |     
 | |  | | | | | | | |_| | | (_| | | || (_| | |     
|___| |_| |_| |_| |____/|_|\__, |_|\__\__,_|_|____ 
                          |___/            |_____|
"@
    
    Write-Host $Logo -ForegroundColor $TColor
    Write-Host "Welcome to PowerShell! Today is $Date" -ForegroundColor $TColor
    
    try {
        $weather = Invoke-RestMethod "wttr.in/?format=%l:+%C+%t"
        Write-Host $weather -ForegroundColor Yellow
    } catch {
        Write-Warning "Could not fetch weather information"
    }

    if ($ShowSystemInfo) {
        Write-Host "`nSystem Information:" -ForegroundColor Cyan
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor
        $mem = Get-CimInstance Win32_ComputerSystem
        
        Write-Host "OS: $($os.Caption) $($os.Version)" -ForegroundColor Yellow
        Write-Host "CPU: $($cpu.Name)" -ForegroundColor Yellow
        Write-Host "Memory: $([math]::Round($mem.TotalPhysicalMemory/1GB, 2)) GB" -ForegroundColor Yellow
        Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    }

    Register-ProfileMetric -Name "Welcome-Screen" -StartTime $startTime

    if ($ShowCommands) {
        Write-Host "`nLoading command list..." -ForegroundColor Yellow
        Start-Sleep -Seconds $DelaySeconds
        Show-ProfileCommands
    }
}

# Consolidate duplicate winrun functions and add error handling
function winrun {
    [CmdletBinding()]
    param()
    
    try {
        Import-Module Selenium -ErrorAction Stop
        $driver = Start-SeEdge
        Enter-SeUrl "https://winget.run/" -Driver $driver
        $searchBox = Find-SeElement -Driver $driver -Wait -Timeout 10 -CssSelector 'input[type="text"]'
        Invoke-SeClick -Element $searchBox
    } catch {
        Write-Error "Failed to start winget.run: $_"
    }
}

function Open-Urls {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$Urls,
        [string]$Message = "Opened URLs",
        [switch]$ShowUrls
    )
    
    # Debug information
    Write-Verbose "URL Collections available: $($UrlCollections.Keys -join ', ')"
    
    # Handle null or empty URLs
    if ($null -eq $Urls -or $Urls.Count -eq 0) {
        Write-Warning "No URLs provided for $Message"
        return
    }
    
    # Filter out invalid URLs and empty strings
    $validUrls = $Urls | Where-Object { 
        $_ -and $_.Trim() -match '^https?://' 
    }
    
    if ($validUrls.Count -eq 0) {
        Write-Warning "No valid URLs found for $Message"
        return
    }
    
    $count = 0
    foreach ($url in $validUrls) {
        try {
            Start-Process $url
            $count++
            if ($ShowUrls) {
                Write-Host "  → $url" -ForegroundColor DarkGray
            }
        } catch {
            Write-Warning "Failed to open URL: $url"
        }
    }
    
    Write-Host "$Message ($count URLs)" -ForegroundColor Green
}

# Helper function to get URLs from collections
function Get-UrlCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [Parameter(Mandatory)]
        [string]$Subcategory
    )
    
    # Debug information
    Write-Verbose "Looking for Category: $Category, Subcategory: $Subcategory"
    Write-Verbose "Available Categories: $($Config.UrlCollections.Keys -join ', ')"
    
    if ($Config.UrlCollections.ContainsKey($Category)) {
        if ($Config.UrlCollections[$Category].ContainsKey($Subcategory)) {
            return $Config.UrlCollections[$Category][$Subcategory]
        }
    }
    return $null
}

# URL opening functions
function ai { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "LLM"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI/LLM sites" 
    } else {
        Write-Warning "No URLs found for AI/LLM category"
    }
}

function aidev { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "AiPackages"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI development sites" 
    } else {
        Write-Warning "No URLs found for AI development category"
    }
}

function Open-AiSearch { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "AiSearch"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI search engines" 
    } else {
        Write-Warning "No URLs found for AI search category"
    }
}

function Open-DevDocs { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Documentation"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer documentation" 
    } else {
        Write-Warning "No URLs found for Development documentation category"
    }
}

function Open-GoogleCore { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Core"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google core services" 
    } else {
        Write-Warning "No URLs found for Google core category"
    }
}

function Open-GoogleProductivity { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Productivity"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google productivity tools" 
    } else {
        Write-Warning "No URLs found for Google productivity category"
    }
}

function Open-GoogleMedia { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Media"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google media services" 
    } else {
        Write-Warning "No URLs found for Google media category"
    }
}

function Open-GoogleBusiness { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Business"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google business tools" 
    } else {
        Write-Warning "No URLs found for Google business category"
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

#region Aliases
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name reload -Value Update-PowerShellProfile

#region Ect.

# Admin check
if ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "PowerShell is running with Administrator privileges"
}


# Function to update all packages
function Update-AllPackages {
    Write-Host "Updating all installed packages..." -ForegroundColor Yellow
    winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
}

# Function to install or update a package
function Install-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [string]$Scope = "user"
    )
    
    $result = winget list --id $PackageId --exact
    
    if ($result -match $PackageId) {
        Write-Host "Updating $PackageId..." -ForegroundColor Yellow
        winget upgrade --id $PackageId --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "Installing $PackageId..." -ForegroundColor Cyan
        winget install --id $PackageId --scope $Scope --silent --accept-package-agreements --accept-source-agreements
    }
}

# Add this function to your profile script
function Install-ConfiguredPackages {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Category,
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed or not available in PATH"
        return
    }
    
    $packages = if ($Category) {
        if ($Config.WingetPackages.ContainsKey($Category)) {
            $Config.WingetPackages[$Category]
        } else {
            Write-Error "Category '$Category' not found. Available categories: $($Config.WingetPackages.Keys -join ', ')"
            return
        }
    } else {
        $Config.WingetPackages.Values | ForEach-Object { $_ }
    }
    
    $packageCount = $packages.Count
    
    if (-not $SkipConfirmation) {
        $message = if ($Category) {
            "This will install/update $packageCount packages from category '$Category'"
        } else {
            "This will install/update $packageCount packages from all categories"
        }
        $confirmation = Read-Host "$message. Continue? (Y/N)"
        if ($confirmation -ne 'Y') {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            return
        }
    }
    
    $successful = 0
    $failed = 0
    
    foreach ($package in $packages) {
        $id = $package.Id
        $scope = $package.Scope ?? "user"
        
        try {
            Write-Host "Processing package: $id" -ForegroundColor Cyan
            Install-Package -PackageId $id -Scope $scope -Force:$Force
            $successful++
        } catch {
            Write-Host "Failed to install/update $id`: $_" -ForegroundColor Red
            $failed++
        }
    }
    
    Write-Host "Package installation complete. Successful: $successful, Failed: $failed" -ForegroundColor Green
}

#region Module-managment
function Install-RequiredModule {
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose,
        [string]$Version
    )
    
    try {
        if (-not (Get-Module -Name $Name -ListAvailable)) {
            if ($Version) {
                Install-Module -Name $Name -RequiredVersion $Version -Scope CurrentUser -Force
            } else {
                Install-Module -Name $Name -Scope CurrentUser -Force
            }
        }
        Import-Module -Name $Name -ErrorAction Stop
    } catch {
        Write-Warning "Failed to import module: $Name. Error: $_"
    }
}

#region Module Management Functions
function Remove-UnusedModules {
    [CmdletBinding()]
    param(
        [switch]$WhatIf
    )
    
    $installedModules = Get-InstalledModule
    $usedModules = Get-Module | Select-Object -ExpandProperty Name
    $unusedModules = $installedModules | Where-Object { $_.Name -notin $usedModules }
    
    if ($unusedModules) {
        if ($WhatIf) {
            Write-Host "The following modules would be removed:" -ForegroundColor Yellow
            $unusedModules | ForEach-Object {
                Write-Host "- $($_.Name) v$($_.Version)" -ForegroundColor Yellow
            }
        } else {
            $unusedModules | ForEach-Object {
                Write-Host "Removing unused module: $($_.Name) v$($_.Version)" -ForegroundColor Yellow
                try {
                    Uninstall-Module -Name $_.Name -Force -ErrorAction Stop
                    Write-Host "  ✓ Removed successfully" -ForegroundColor Green
                } catch {
                    Write-Host "  ✗ Failed to remove: $_" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "No unused modules found." -ForegroundColor Green
    }
}

# Convenience function for package installation
function Install-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)][string]$PackageId,
        [string]$Scope = "user"
    )
    
    Invoke-PackageManager -Action Install -PackageId $PackageId -Scope $Scope
}

# Function to update all packages
function Update-AllPackages {
    [CmdletBinding()]
    param ()
    
    Invoke-PackageManager -Action Update
}

# Function to list installed packages
function Get-InstalledPackages {
    [CmdletBinding()]
    param ()
    
    Invoke-PackageManager -Action List
}

function Get-PackageStatus {
    [CmdletBinding()]
    param()
    
    Invoke-PackageManager -Action Status
}

function Update-ConfiguredPackages {
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    Invoke-PackageManager -Action Install -Force:$Force -SkipConfirmation:$SkipConfirmation
}

function Update-PowerShellModule {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name,
        
        [Parameter()]
        [switch]$All,
        
        [Parameter()]
        [switch]$WhatIf
    )
    
    if (-not $All -and -not $Name) {
        Write-Error "Either specify a module name or use -All to update all modules"
        return
    }
    
    try {
        if ($All) {
            $modules = Get-InstalledModule
            Write-Host "Checking for updates to $($modules.Count) installed modules..." -ForegroundColor Yellow
            
            $updatableModules = @()
            foreach ($module in $modules) {
                try {
                    $online = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
                    if ($online.Version -gt $module.Version) {
                        $updatableModules += [PSCustomObject]@{
                            Name = $module.Name
                            CurrentVersion = $module.Version
                            NewVersion = $online.Version
                        }
                    }
                } catch {
                    Write-Warning "Could not check updates for $($module.Name): $_"
                }
            }
            
            if (-not $updatableModules) {
                Write-Host "All modules are up to date!" -ForegroundColor Green
                return
            }
            
            if ($WhatIf) {
                Write-Host "Found $($updatableModules.Count) modules with available updates:" -ForegroundColor Cyan
                $updatableModules | ForEach-Object {
                    Write-Host "- $($_.Name): $($_.CurrentVersion) → $($_.NewVersion)" -ForegroundColor Yellow
                }
                return
            }
            
            foreach ($module in $updatableModules) {
                Write-Host "Updating $($module.Name) from $($module.CurrentVersion) to $($module.NewVersion)..." -ForegroundColor Cyan
                try {
                    Update-Module -Name $module.Name -Force -ErrorAction Stop
                    Write-Host "  ✓ Updated successfully" -ForegroundColor Green
                } catch {
                    Write-Host "  ✗ Failed to update: $_" -ForegroundColor Red
                }
            }
        } else {
            $module = Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue
            if (-not $module) {
                Write-Error "Module '$Name' is not installed"
                return
            }
            
            try {
                $online = Find-Module -Name $Name -ErrorAction Stop
                if ($online.Version -gt $module.Version) {
                    Write-Host "Updating $Name from $($module.Version) to $($online.Version)..." -ForegroundColor Cyan
                    Update-Module -Name $Name -Force -ErrorAction Stop
                    Write-Host "Module updated successfully" -ForegroundColor Green
                } else {
                    Write-Host "Module '$Name' is already up to date (version $($module.Version))" -ForegroundColor Green
                }
            } catch {
                Write-Error "Failed to update module '$Name': $_"
            }
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}


function Update-CustomScripts {
    [CmdletBinding()]
    param (
        [string]$RepoUrl = "https://github.com/Digital-gitz/Powershell/tree/main/Modules",
        [string]$Branch = "main",
        [switch]$Force,
        [switch]$Preview
    )
    
    try {
        # Create temp directory
        $tempDir = Join-Path $env:TEMP "ScriptUpdates_$(Get-Random)"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        New-Item -Path $tempDir -ItemType Directory | Out-Null
        
        Write-Host "Downloading scripts from $RepoUrl..." -ForegroundColor Cyan
        
        # Download and extract repository
        $zipUrl = "$RepoUrl/archive/$Branch.zip"
        $zipFile = Join-Path $tempDir "scripts.zip"
        
        try {
            Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -ErrorAction Stop
        } catch {
            Write-Error "Failed to download from $zipUrl`: $_"
            return
        }
        
        # Extract the zip file
        Write-Host "Extracting scripts..." -ForegroundColor Cyan
        Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
        
        # Find the extracted directory
        $extractedDir = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
        if (-not $extractedDir) {
            Write-Error "No directories found in the downloaded archive"
            return
        }
        
        # Ensure scripts directory exists
        if (-not (Test-Path $CommonPaths.Scripts)) {
            New-Item -Path $CommonPaths.Scripts -ItemType Directory -Force | Out-Null
            Write-Host "Created scripts directory: $($CommonPaths.Scripts)" -ForegroundColor Yellow
        }
        
        # List files to be copied
        $filesToCopy = Get-ChildItem -Path $extractedDir.FullName -File -Recurse -Include "*.ps1"
        
        if (-not $filesToCopy) {
            Write-Warning "No script files found in the repository"
            return
        }
        
        Write-Host "Found $($filesToCopy.Count) script files to update" -ForegroundColor Cyan
        
        # Preview mode
        if ($Preview) {
            Write-Host "Preview of files to be updated:" -ForegroundColor Cyan
            $filesToCopy | ForEach-Object {
                $relativePath = $_.FullName.Replace($extractedDir.FullName, '').TrimStart('\')
                Write-Host "- $relativePath" -ForegroundColor Yellow
            }
            return
        }
        
        # Confirm the update if not forced
        if (-not $Force) {
            $confirmation = Read-Host "Do you want to update these scripts? (Y/N)"
            if ($confirmation -ne 'Y') {
                Write-Host "Script update cancelled" -ForegroundColor Yellow
                return
            }
        }
        
        # Start tracking changes
        $updatedCount = 0
        $skippedCount = 0
        $errorCount = 0
        
        # Copy files with logging
        foreach ($file in $filesToCopy) {
            try {
                $relativePath = $file.FullName.Replace($extractedDir.FullName, '').TrimStart('\')
                $destinationPath = Join-Path $CommonPaths.Scripts $relativePath
                
                # Create destination directory if it doesn't exist
                $destinationDir = Split-Path $destinationPath -Parent
                if (-not (Test-Path $destinationDir)) {
                    New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
                }
                
                # Compare files to avoid unnecessary overwrites
                $doUpdate = $true
                if (Test-Path $destinationPath) {
                    $existingFile = Get-Item $destinationPath
                    if ((Get-FileHash $file.FullName).Hash -eq (Get-FileHash $existingFile.FullName).Hash) {
                        $doUpdate = $false
                        $skippedCount++
                    }
                }
                
                if ($doUpdate) {
                    Copy-Item -Path $file.FullName -Destination $destinationPath -Force
                    Write-Host "Updated: $relativePath" -ForegroundColor Green
                    $updatedCount++
                } else {
                    Write-Host "Skipped (no changes): $relativePath" -ForegroundColor DarkGray
                }
            } catch {
                Write-Host "Error updating $relativePath`: $_" -ForegroundColor Red
                $errorCount++
            }
        }
        
        # Summary
        Write-Host "`nScript Update Summary:" -ForegroundColor Cyan
        Write-Host "- Updated:  $updatedCount" -ForegroundColor Green
        Write-Host "- Skipped:  $skippedCount" -ForegroundColor Yellow
        Write-Host "- Errors:   $errorCount" -ForegroundColor Red
        
        # Optional: Create a backup of old scripts
        $backupDir = Join-Path $env:TEMP "PowerShellScripts_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        
        Write-Host "`nBackup created at: $backupDir" -ForegroundColor Cyan
    } catch {
        Write-Error "Unexpected error during script update: $_"
    } finally {
        # Clean up temporary directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

#region Package Management
function Invoke-PackageManager {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Install', 'Update', 'List', 'Status')]
        [string]$Action,
        
        [string]$PackageId,
        [string]$Scope = "user",
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed or not available in PATH"
        return
    }
    
    switch ($Action) {
        'Install' {
            if ($PackageId) {
                # Single package installation
                $result = winget list --id $PackageId --exact
                
                if ($result -match $PackageId) {
                    Write-Host "Updating $PackageId..." -ForegroundColor Yellow
                    winget upgrade --id $PackageId --silent --accept-package-agreements --accept-source-agreements
                } else {
                    Write-Host "Installing $PackageId..." -ForegroundColor Cyan
                    winget install --id $PackageId --scope $Scope --silent --accept-package-agreements --accept-source-agreements
                }
            } else {
                # Bulk installation from config
                if (-not $Config.WingetPackages) {
                    Write-Warning "No Winget packages configured in config.psd1"
                    return
                }
                
                $packageCount = $Config.WingetPackages.Count
                
                if (-not $SkipConfirmation) {
                    $confirmation = Read-Host "This will install/update $packageCount packages. Continue? (Y/N)"
                    if ($confirmation -ne 'Y') {
                        Write-Host "Operation cancelled" -ForegroundColor Yellow
                        return
                    }
                }
                
                $successful = 0
                $failed = 0
                
                foreach ($package in $Config.WingetPackages) {
                    try {
                        Invoke-PackageManager -Action Install -PackageId $package.Id -Scope ($package.Scope ?? "user")
                        $successful++
                    } catch {
                        Write-Host "Failed to install/update $($package.Id): $_" -ForegroundColor Red
                        $failed++
                    }
                }
                
                Write-Host "Package installation complete. Successful: $successful, Failed: $failed" -ForegroundColor Green
            }
        }
        'Update' {
            Write-Host "Updating all installed packages..." -ForegroundColor Yellow
            winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
        }
        'List' {
            winget list
        }
        'Status' {
            winget upgrade
        }
    }
}

# Clean aliases for package management
Set-Alias -Name 'pkg-install' -Value 'Install-Package'
Set-Alias -Name 'pkg-update' -Value 'Update-AllPackages'
Set-Alias -Name 'pkg-list' -Value 'Get-InstalledPackages'
Set-Alias -Name 'pkg-status' -Value 'Get-PackageStatus'

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

function Show-ProfileCommands {
    [CmdletBinding()]
    param(
        [switch]$Detailed
    )
    
    $commands = @{
        'Package Management' = @{
            'pkg-install <package>' = 'Install a package using winget'
            'pkg-update' = 'Update all installed packages'
            'pkg-list' = 'List installed packages'
            'pkg-status' = 'Show available package updates'
        }
        'Module Management' = @{
            'Import-RequiredModule' = 'Import and install if needed a PowerShell module'
            'Update-PowerShellModule' = 'Update PowerShell modules'
            'Remove-UnusedModules' = 'Clean up unused modules'
        }
        'URL Commands' = @{
            'gally' = 'Open PowerShell Gallery'
            'ythistory' = 'Open YouTube History'
            'Open-Ai' = 'Open AI-related sites'
            'Open-AiDev' = 'Open AI development sites'
            'Open-AiSearch' = 'Open AI search engines'
            'Open-GoogleCore' = 'Open Google core services'
            'Open-GoogleProductivity' = 'Open Google productivity tools'
            'Open-GoogleMedia' = 'Open Google media services'
            'Open-GoogleBusiness' = 'Open Google business tools'
            'Open-DevDocs' = 'Open developer documentation'
            'Open-DevGit' = 'Open Git platforms'
            'Open-DevLearn' = 'Open web development learning resources'
            'Open-DevJavaScript' = 'Open JavaScript resources'
            'Open-DevCss' = 'Open CSS resources'
            'Open-DevPackages' = 'Open package managers'
            'Open-DevCloud' = 'Open cloud platforms'
            'Open-FinanceStocks' = 'Open stock trading sites'
            'Open-FinanceTrading' = 'Open trading platforms'
            'Open-FinanceForex' = 'Open forex trading sites'
            'Open-FinanceCrypto' = 'Open cryptocurrency sites'
            'Open-FinanceBanking' = 'Open banking sites'
            'Open-FinanceCards' = 'Open credit card sites'
            'Open-NewsGeneral' = 'Open news sites'
            'Open-NewsTech' = 'Open tech news sites'
            'Open-NewsMusic' = 'Open music services'
            'Open-SocialPro' = 'Open professional networks'
            'Open-SocialPersonal' = 'Open personal social media'
            'Open-SocialContent' = 'Open content platforms'
            'Open-SocialCommunity' = 'Open community sites'
        }
        'Utility Commands' = @{
            'reload' = 'Reload PowerShell profile'
            'clr' = 'Clear console screen'
            'Get-Guid' = 'Generate a new GUID'
            'winrun' = 'Open winget.run in browser'
            'Show-Welcome' = 'Display welcome message'
            'Show-ProfileMetrics' = 'Display profile load metrics'
            'Show-ProfileCommands -Detailed' = 'Show detailed descriptions for commands'
            'Write-ProfileLog' = 'Write a log message to profile.log'
        }
        'ect' = @{
            'Update-AllPackages' = 'Update all installed packages'
            'Install-Package <package>' = 'Install or update a package using winget'
            'Install-ConfiguredPackages' = 'Install packages configured in config.psd1'
            'Update-ConfiguredPackages' = 'Update packages configured in config.psd1'
            'Update-CustomScripts' = 'Update custom scripts from a GitHub repository'
        }
    }
    
    Write-Host "`nAvailable Profile Commands:" -ForegroundColor Cyan
    
    foreach ($category in $commands.Keys) {
        Write-Host "`n$($category):" -ForegroundColor Yellow
        
        $commands[$category].GetEnumerator() | ForEach-Object {
            if ($Detailed) {
                Write-Host ("  {0,-25}" -f $_.Key) -NoNewline -ForegroundColor Green
                Write-Host " - $($_.Value)" -ForegroundColor Gray
            } else {
                Write-Host "  $($_.Key)" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "`nTip: Use 'Show-ProfileCommands -Detailed' for command descriptions" -ForegroundColor DarkGray
}


# Call the function with auto-install option
Initialize-OhMyPosh -AutoInstall
# try {
#     oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\clean-detailed.omp.json" | Invoke-Expression
# } catch {
#     Write-Warning "Oh My Posh is not installed or there was an error loading the theme: $_"
#     Write-Host "To install Oh My Posh, run: winget install JanDeDobbeleer.OhMyPosh"
# }



# Add this line at the end of your profile to show commands at startup
Show-Welcome -ShowCommands

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
$startTime = Get-Date
$configValidation = Test-ProfileConfiguration -Config $Config

if (-not $configValidation.IsValid) {
    Write-Warning "Profile configuration validation failed:"
    $configValidation.Errors | ForEach-Object { Write-Warning "  - $_" }
}

Register-ProfileMetric -Name "Configuration-Validation" -StartTime $startTime

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

# Add PSReadLine configuration from config
if (Get-Module PSReadLine) {
    if ($Config.ContainsKey('PSReadLine') -and $null -ne $Config.PSReadLine) {
        foreach ($option in $Config.PSReadLine.GetEnumerator()) {
            switch ($option.Key) {
                'Colors' {
                    if ($null -ne $option.Value) {
                        foreach ($color in $option.Value.GetEnumerator()) {
                            Set-PSReadLineOption -Colors @{$color.Key = $color.Value}
                        }
                    }
                }
                'KeyBindings' {
                    if ($null -ne $option.Value) {
                        foreach ($binding in $option.Value.GetEnumerator()) {
                            Set-PSReadLineKeyHandler -Chord $binding.Key -Function $binding.Value
                        }
                    }
                }
                'ShowToolTips' {
                    Set-PSReadLineOption -ShowToolTips:$($option.Value)
                }
                'PredictionSource' {
                    Set-PSReadLineOption -PredictionSource $option.Value
                }
                'PredictionViewStyle' {
                    Set-PSReadLineOption -PredictionViewStyle $option.Value
                }
                'EditMode' {
                    Set-PSReadLineOption -EditMode $option.Value
                }
                default {
                    Write-Warning "Unknown PSReadLine option: $($option.Key)"
                }
            }
        }
    }
}




# Add aliases for shorter commands
Set-Alias -Name 'aisearch' -Value 'Open-AiSearch'
Set-Alias -Name 'google-core' -Value 'Open-GoogleCore'
Set-Alias -Name 'google-productivity' -Value 'Open-GoogleProductivity'
Set-Alias -Name 'google-media' -Value 'Open-GoogleMedia'
