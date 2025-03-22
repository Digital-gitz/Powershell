# System information functions
function Get-SystemInfo {
    $systemInfo = @{
        ComputerName = $env:COMPUTERNAME
        OSVersion    = [System.Environment]::OSVersion.Version.ToString()
        Processor    = (Get-WmiObject Win32_Processor).Name
        Memory       = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        DiskSpace    = Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, @{Name = "FreeSpace(GB)"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } }
    }
    return $systemInfo
}

function Get-SystemUptime {
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    return @{
        Days       = $uptime.Days
        Hours      = $uptime.Hours
        Minutes    = $uptime.Minutes
        TotalHours = [math]::Round($uptime.TotalHours, 2)
    }
}

function Get-SystemServices {
    param(
        [string]$Status = "Running"
    )
    Get-Service | Where-Object Status -eq $Status
}

# Export functions
Export-ModuleMember -Function Get-SystemInfo, Get-SystemUptime, Get-SystemServices 