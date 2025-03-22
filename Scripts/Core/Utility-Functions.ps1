#region Utility Functions
function Get-Guid { [guid]::NewGuid().ToString() }

# Initialize Config if it doesn't exist
if (-not (Get-Variable -Name Config -Scope Global -ErrorAction SilentlyContinue)) {
    $global:Config = @{}
}

# Initialize PSReadLine configuration if it doesn't exist
if (-not $global:Config.PSReadLine) {
    $global:Config.PSReadLine = @{
        ShowToolTips        = $true
        PredictionSource    = "History"
        PredictionViewStyle = "ListView"
        EditMode            = "Windows"
    }
}

function Update-ModulePath {
    [CmdletBinding()]
    [Alias('modpath')]
    param (
        [switch]$Formatted,
        [switch]$Add,
        [string]$Path,
        [switch]$NoColor
    )
    
    if ($Add -and $Path -and (Test-Path $Path)) {
        $env:PSModulePath = "$Path;$env:PSModulePath"
    }
    
    $paths = $env:PSModulePath -split ';'
    if ($Formatted) {
        $paths | ForEach-Object { 
            $color = if ($NoColor) { $null } else { [System.ConsoleColor]::Cyan }
            try {
                Write-Host "- $_" -ForegroundColor $color
            }
            catch {
                Write-Host "- $_"
            }
        }
    }
    else {
        $paths
    }
}

# Only run Update-ModulePath if we're not in a profile reload
if (-not $global:IsProfileReload) {
    Update-ModulePath -NoColor
}

function Install-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$PackageId,
        [string]$Scope = "user",
        [switch]$Force
    )
    
    $packagesToInstall = @($PackageId)
    
    while ($true) {
        try {
            foreach ($package in $packagesToInstall) {
                $result = winget list --id $package --exact
                $action = if ($result -match $package) { "upgrade" } else { "install" }
                $message = if ($action -eq "upgrade") { "Updating" } else { "Installing" }
                
                Write-Host "$message $package..." 
                winget $action --id $package --scope $Scope --silent --accept-package-agreements --accept-source-agreements
            }
        }
        catch {
            Write-Error "Failed to $action package $package`: $_"
            throw
        }

        $response = Read-Host "Would you like to install another package? (Y/N)"
        if ($response -ne 'Y') {
            break
        }

        $newPackage = Read-Host "Enter the package ID"
        if (-not [string]::IsNullOrWhiteSpace($newPackage)) {
            $packagesToInstall += $newPackage
        }
    }
}

#region PSReadLine Configuration
function Initialize-PSReadLine {
    if (-not (Get-Module PSReadLine -ErrorAction SilentlyContinue)) { return }
    
    try {
        $defaultConfig = @{
            ShowToolTips        = $true
            PredictionSource    = "History"
            PredictionViewStyle = "ListView"
            EditMode            = "Windows"
        }
        
        $config = $global:Config.PSReadLine ?? $defaultConfig
        
        # Set basic options
        if ($config.ShowToolTips) {
            Set-PSReadLineOption -ShowToolTips
        }
        if ($config.PredictionSource) {
            Set-PSReadLineOption -PredictionSource $config.PredictionSource
        }
        if ($config.PredictionViewStyle) {
            Set-PSReadLineOption -PredictionViewStyle $config.PredictionViewStyle
        }
        if ($config.EditMode) {
            Set-PSReadLineOption -EditMode $config.EditMode
        }
        
        # Set colors if specified
        if ($config.Colors) {
            foreach ($color in $config.Colors.GetEnumerator()) {
                Set-PSReadLineOption -Colors @{$color.Key = $color.Value } -ErrorAction SilentlyContinue
            }
        }
        
        # Set key bindings if specified
        if ($config.KeyBindings) {
            foreach ($binding in $config.KeyBindings.GetEnumerator()) {
                Set-PSReadLineKeyHandler -Chord $binding.Key -Function $binding.Value -ErrorAction SilentlyContinue
            }
        }
        
        # Set standard key bindings
        @{
            UpArrow   = 'HistorySearchBackward'
            DownArrow = 'HistorySearchForward'
            Tab       = 'MenuComplete'
        }.GetEnumerator() | ForEach-Object {
            Set-PSReadLineKeyHandler -Key $_.Key -Function $_.Value -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning "Failed to initialize PSReadLine: $_"
    }
}

# Initialize PSReadLine if available
if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Initialize-PSReadLine
}

function Show-Path {
    $env:PATH -split ';' | ForEach-Object {
        $color = if (Test-Path $_) { [System.ConsoleColor]::Green } else { [System.ConsoleColor]::Red }
        Write-Host $_ -ForegroundColor $color
    }
}

function Show-LLMConfig {
    Write-Output "/agent config openai-gpt"
}

function Find-AndInstallModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    try {
        $module = Find-Module -Name $ModuleName
        if ($module) {
            Write-Host "Found module: $($module.Name) - $($module.Description)"
            if ((Read-Host "Do you want to install this module? (Y/N)") -eq 'Y') {
                Install-Module -Name $ModuleName -Force
                Write-Host "Module $ModuleName installed successfully." -ForegroundColor Green
            }
        }
        else {
            Write-Host "Module $ModuleName not found." -ForegroundColor Red
        }
    }
    catch {
        Write-Error "Failed to process module $ModuleName`: $_"
    }
}

function Import-EnvironmentSpecificConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ConfigDir = (Join-Path $PSScriptRoot "Environments")
    )
    
    $envInfo = @{
        ComputerName = $env:COMPUTERNAME
        UserName     = $env:USERNAME
        Domain       = $env:USERDOMAIN
        OSVersion    = [System.Environment]::OSVersion.Version.Major
    }
    
    $configFiles = @(
        "$ConfigDir\computer-$($envInfo.ComputerName).psd1",
        "$ConfigDir\user-$($envInfo.UserName).psd1",
        "$ConfigDir\domain-$($envInfo.Domain).psd1",
        "$ConfigDir\os-win$($envInfo.OSVersion).psd1"
    )
    
    $loadedConfigs = @()
    
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            try {
                $envConfig = Import-PowerShellDataFile -Path $file -ErrorAction Stop
                
                foreach ($key in $envConfig.Keys) {
                    if ($Config.ContainsKey($key) -and $Config[$key] -is [hashtable] -and $envConfig[$key] -is [hashtable]) {
                        $Config[$key] = @($Config[$key].Clone(), $envConfig[$key]) | Merge-Hashtables
                    }
                    else {
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
    
    if (-not (Test-Path $ConfigDir)) {
        New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
        Write-Host "Created environments directory: $ConfigDir" -ForegroundColor Green
    }
    
    return $loadedConfigs
}

function New-Script {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        $scriptPath = Join-Path $CommonPaths.Scripts "$Name.ps1"
        if (!(Test-Path $scriptPath)) {
            $content = @"
# $Name
# Created on $(Get-Date -Format 'yyyy-MM-dd')

"@
            New-Item -Path $scriptPath -ItemType File -Value $content | Out-Null
        }
        code $scriptPath
    }
    catch {
        Write-Error "Failed to create script: $_"
    }
}

function Get-PSVersion {
    $PSVersionTable.PSVersion
}

function Get-TimeInfo {
    [CmdletBinding()]
    param()
    
    $currentDate = Get-Date
    $timeZone = [System.TimeZoneInfo]::Local
    
    [PSCustomObject]@{
        Year          = $currentDate.Year
        Month         = $currentDate.ToString("MMMM")
        Day           = $currentDate.Day
        DayOfWeek     = $currentDate.DayOfWeek
        Hour          = $currentDate.Hour
        Minute        = $currentDate.Minute
        Second        = $currentDate.Second
        TimeZone      = $timeZone.DisplayName
        UnixTimestamp = [int64](([datetime]::UtcNow) - (get-date "1/1/1970")).TotalSeconds
    }
}

function Search-History {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Keyword
    )

    Get-History | Where-Object { $_.CommandLine -like "*$Keyword*" } | 
    Format-Table Id, CommandLine -AutoSize
}

function Backup-Profile {
    [CmdletBinding()]
    param(
        [string]$BackupPath = (Join-Path $CommonPaths.PowerShell "profile_backup_$(Get-Date -Format 'yyyyMMddHHmmss').ps1")
    )
    
    try {
        Copy-Item -Path $PROFILE -Destination $BackupPath
        Write-Host "Profile backed up to: $BackupPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to backup profile: $_"
    }
}

function Update-Profile {
    [CmdletBinding()]
    param()
    
    try {
        . $PROFILE
        Write-Host "PowerShell profile has been reloaded successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to reload profile: $_"
    }
}

function Get-RecentFiles {
    [CmdletBinding()]
    param (
        [string]$Path = ".",
        [int]$LastDays = 1
    )
    
    Get-ChildItem -Path $Path -Recurse |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$LastDays) } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 10
}

function Edit-HostsFile {
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    if (Test-Path $hostsPath) {
        Start-Process notepad -ArgumentList $hostsPath -Verb RunAs
    }
    else {
        throw "Hosts file not found at $hostsPath"
    }
}

function Get-SystemInfo {
    [CmdletBinding()]
    param()
    
    try {
        $computerInfo = Get-ComputerInfo
        $processor = Get-WmiObject Win32_Processor
        $memory = Get-WmiObject Win32_OperatingSystem
        
        [PSCustomObject]@{
            OS                = "$($computerInfo.OsName) $($computerInfo.OsArchitecture) $($computerInfo.OsVersion)"
            PowerShellVersion = $PSVersionTable.PSVersion
            Username          = $env:USERNAME
            ComputerName      = $env:COMPUTERNAME
            Processor         = $processor.Name
            Memory            = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
            FreeMemory        = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
            LastBootTime      = $computerInfo.OsLastBootUpTime
            HomeDrive         = $env:HOMEDRIVE
            HomePath          = $env:HOMEPATH
        }
    }
    catch {
        Write-Error "Failed to get system info: $_"
        throw
    }
}

function Get-Weather {
    [CmdletBinding()]
    param(
        [string]$Location = "",
        [ValidateSet("1", "2", "3")]
        [string]$Format = "3"
    )
    
    try {
        $WeatherUrl = "http://wttr.in/${Location}?format=$Format"
        Invoke-RestMethod -Uri $WeatherUrl
    }
    catch {
        Write-Error "Unable to fetch weather information: $_"
        throw
    }
}

function Get-FileHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Path,
        [ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512")]
        [string]$Algorithm = "SHA256"
    )
    
    process {
        try {
            $file = Get-Item $Path
            Write-Progress -Activity "Calculating $Algorithm hash" -Status "Processing $($file.Name)"
            $hash = Microsoft.PowerShell.Utility\Get-FileHash -Path $Path -Algorithm $Algorithm
            Write-Progress -Activity "Calculating $Algorithm hash" -Completed
            return $hash
        }
        catch {
            Write-Error "Failed to get file hash for $Path`: $_"
            throw
        }
    }
}

# Helper function to merge hashtables
function Merge-Hashtables {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable[]]$Hashtables
    )
    
    $merged = @{}
    foreach ($ht in $Hashtables) {
        foreach ($key in $ht.Keys) {
            $merged[$key] = $ht[$key]
        }
    }
    return $merged
}

function Get-MoonPhaseInfo {
    $modulePath = Join-Path $PSScriptRoot ".." "Utility" "check-moon-phase.psd1"
    if (-not (Get-Module -Name "check-moon-phase")) {
        Import-Module $modulePath -Force
    }
    Get-MoonPhase
}