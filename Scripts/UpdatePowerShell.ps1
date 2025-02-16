function Update-PowerShell {
    [CmdletBinding()]
    param (
        [switch]$Preview
    )

    # Determine the OS platform
    if ($IsWindows) {
        Write-Host "Updating PowerShell on Windows..."
        if ($Preview) {
            iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Preview"
        } else {
            iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
        }
    }
    elseif ($IsLinux) {
        Write-Host "Updating PowerShell on Linux..."
        if ($Preview) {
            sudo apt-get update
            sudo apt-get install -y powershell-preview
        } else {
            sudo apt-get update
            sudo apt-get install -y powershell
        }
    }
    elseif ($IsMacOS) {
        Write-Host "Updating PowerShell on macOS..."
        if ($Preview) {
            brew update
            brew install --cask powershell-preview
        } else {
            brew update
            brew install --cask powershell
        }
    }
    else {
        Write-Error "Unsupported operating system."
    }
}

# To update to the preview version, call the function with the -Preview switch:
# Update-PowerShell -Preview

# To update to the stable version, call the function without the -Preview switch:


function Get-SystemInfo {
    [CmdletBinding()]
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )

    # Get computer information
    $computerInfo = Get-WmiObject -Class Win32_ComputerSystem
    $osInfo = Get-WmiObject -Class Win32_OperatingSystem
    $biosInfo = Get-WmiObject -Class Win32_BIOS
    $processorInfo = Get-WmiObject -Class Win32_Processor
    $memoryInfo = Get-WmiObject -Class Win32_PhysicalMemory
    $networkInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
}

    # ? Display computer information rememeber to hash shit out.
    [PSCustomObject]@{
        ComputerName = $ComputerName
        Manufacturer = $Manufacturer
    }
    
        function UpDit  {
            $UpD
        }

$UpD = Update-PowerShell



#npm install -g npm@latest
#choco install update   note: this is not the command I need to figure out how to update choco

