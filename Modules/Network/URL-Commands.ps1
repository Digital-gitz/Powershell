# URL utility functions
function Open-URL {
    param(
        [Parameter(Mandatory)]
        [string]$URL
    )
    Start-Process $URL
}

function Get-URLContent {
    param(
        [Parameter(Mandatory)]
        [string]$URL
    )
    try {
        $response = Invoke-WebRequest -Uri $URL
        return $response.Content
    }
    catch {
        Write-Log "Failed to fetch URL content: $_" -Level 'Error'
        return $null
    }
}

function Test-URL {
    param(
        [Parameter(Mandatory)]
        [string]$URL
    )
    try {
        $response = Invoke-WebRequest -Uri $URL -Method Head
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

# Export functions
Export-ModuleMember -Function Open-URL, Get-URLContent, Test-URL 