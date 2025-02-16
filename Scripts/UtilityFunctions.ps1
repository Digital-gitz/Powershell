#region Utility Functions
# Enhanced Get-TimeInfo with time zone
function Find-AndInstallModule {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )

    $module = Find-Module -Name $ModuleName
    if ($module) {
        Write-Host "Found module: $($module.Name) - $($module.Description)"
        $install = Read-Host "Do you want to install this module? (Y/N)"
        if ($install -eq 'Y') {
            Install-Module -Name $ModuleName -Force
            Write-Host "Module $ModuleName installed successfully." -ForegroundColor Green
        }
    } else {
        Write-Host "Module $ModuleName not found." -ForegroundColor Red
    }
}
function New-Script {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $scriptPath = Join-Path $CommonPaths.Scripts "$Name.ps1"
    if (!(Test-Path $scriptPath)) {
        New-Item -Path $scriptPath -ItemType File
        Add-Content -Path $scriptPath -Value "# $Name`n# Created on $(Get-Date -Format 'yyyy-MM-dd')`n`n"
    }
    code $scriptPath  # Opens with VS Code, change to your preferred editor if needed
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
        Year = $currentDate.Year
        Month = $currentDate.ToString("MMMM")
        Day = $currentDate.Day
        DayOfWeek = $currentDate.DayOfWeek
        Hour = $currentDate.Hour
        Minute = $currentDate.Minute
        Second = $currentDate.Second
        TimeZone = $timeZone.DisplayName
        UnixTimestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalSeconds
    }
}
function Edit-HostsFile {
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    if (Test-Path $hostsPath) {
        Start-Process notepad -ArgumentList $hostsPath -Verb RunAs
    } else {
        Write-Error "Hosts file not found at $hostsPath"
    }
}
function Search-History {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Keyword
    )

    Get-History | Where-Object { $_.CommandLine -like "*$Keyword*" } | 
        Format-Table Id, CommandLine -AutoSize
}
function Get-RecentFiles {
    param (
        [string]$Path = ".",
        [int]$LastDays = 1
    )
    
    Get-ChildItem -Path $Path -Recurse |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$LastDays) } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10
}

function Backup-Profile {
    $backupPath = "C:\Users\YourUsername\Documents\PowerShellProfileBackup"
    if (!(Test-Path -Path $backupPath)) {
        New-Item -Path $backupPath -ItemType Directory
    }
    Copy-Item $PROFILE -Destination $backupPath
    Write-Host "Profile backed up to $backupPath"
}
# Enhanced Get-SystemInfo with more details
function Get-SystemInfo {
    [CmdletBinding()]
    param()
    
    $computerInfo = Get-ComputerInfo
    $processor = Get-WmiObject Win32_Processor
    $memory = Get-WmiObject Win32_OperatingSystem
    
    [PSCustomObject]@{
        OS = "$($computerInfo.OsName) $($computerInfo.OsArchitecture) $($computerInfo.OsVersion)"
        PowerShellVersion = $PSVersionTable.PSVersion
        Username = $env:USERNAME
        ComputerName = $env:COMPUTERNAME
        Processor = $processor.Name
        Memory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
        FreeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
        LastBootTime = $computerInfo.OsLastBootUpTime
        HomeDrive = $env:HOMEDRIVE
        HomePath = $env:HOMEPATH
    }
}
# Profile management functions
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

# Welcome function with ASCII art and system info
function Show-Welcome {
    [CmdletBinding()]
    param()
    
    $TColor = "Cyan"
    $Logo = @"
 ___ _             ____  _       _ _        _      
|_ _( )_ __ ___   |  _ \(_) __ _(_) |_ __ _| |     
 | ||/| '_ ` _ \  | | | | |/ _` | | __/ _` | |     
 | |  | | | | | | | |_| | | (_| | | || (_| | |     
|___| |_| |_| |_| |____/|_|\__, |_|\__\__,_|_|____ 
                          |___/            |_____|
"@
    
    Write-Host $Logo -ForegroundColor $TColor
    Write-Host $script:MyName
    
    $TimeInfo = Get-TimeInfo
    $SystemInfo = Get-SystemInfo
    
    Write-Output "`nCurrent Time:"
    $TimeInfo | Format-List
    
    Write-Output "`nSystem Information:"
    $SystemInfo | Format-List
}

# Enhanced weather function with more options
function Get-Weather {
    [CmdletBinding()]
    param(
        [string]$Location = "",
        [ValidateSet("1", "2", "3")]
        [string]$Format = "3"
    )
    
    $WeatherUrl = "http://wttr.in/${Location}?format=$Format"
    try {
        $Weather = Invoke-RestMethod -Uri $WeatherUrl
        Write-Output $Weather
    }
    catch {
        Write-Warning "Unable to fetch weather information: $_"
    }
}

function Get-Weather {
    $WeatherUrl = "http://wttr.in/?format=3"
    try {
        $Weather = Invoke-RestMethod -Uri $WeatherUrl
        Write-Output $Weather
    }
    catch {
        Write-Warning "Unable to fetch weather information"
    }
}

# File hash function with progress bar
function Get-FileHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
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
            $errorMessage = $_.Exception.Message
            Write-Error "Failed to get file hash for $Path`: $errorMessage"
        }
    }
}


#function to convert an svg to Vector
function svg2vec {
  $svg2vecScrip = "C:\Users\russk\OneDrive\Documentos\PowerShell\Scripts\Bash"

}


#endregion
