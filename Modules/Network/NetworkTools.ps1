# Network utility functions
function Test-NetworkConnection {
    param(
        [string]$HostName = "8.8.8.8",
        [int]$Count = 4
    )
    Test-Connection -ComputerName $HostName -Count $Count
}

function Get-NetworkInterfaces {
    Get-NetAdapter | Where-Object Status -eq "Up"
}

function Get-NetworkIPConfig {
    Get-NetIPConfiguration | Format-Table -AutoSize
}

function Test-Port {
    param(
        [string]$ComputerName,
        [int]$Port
    )
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    try {
        $tcpClient.Connect($ComputerName, $Port)
        Write-Log "Port $Port is open on $ComputerName" -Level 'Success'
        return $true
    }
    catch {
        Write-Log "Port $Port is closed on $ComputerName" -Level 'Warning'
        return $false
    }
    finally {
        $tcpClient.Close()
    }
}

# Export functions
Export-ModuleMember -Function Test-NetworkConnection, Get-NetworkInterfaces, Get-NetworkIPConfig, Test-Port 