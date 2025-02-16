# Navigation.ps1

function Open-ExplorerHere {
    explorer.exe .
}

function goto {
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            "home",
            "root",
            "dirps",
            "downloads",
            "documents",
            "pictures",
            "desktop",
            "github"
        )]
        [string]$location
    )
    
    $validLocations = @(
        "home",
        "root",
        "dirps",
        "downloads",
        "documents",
        "pictures",
        "desktop",
        "github"
    )
    
    if (-not $PSBoundParameters.ContainsKey('location')) {
        Write-Output "Please specify a location. Valid locations are:"
        $validLocations | ForEach-Object { Write-Output " - $_" }
        return
    }
    
    switch ($location) {
        "root" { Set-Location "C:\" }
        "home" { Set-Location $CommonPaths.Home }
        "dirps" { Set-Location $CommonPaths.PowerShell }
        "downloads" { Set-Location (Join-Path $CommonPaths.Home "Downloads") }
        "documents" { Set-Location $CommonPaths.Documents }
        "pictures" { Set-Location (Join-Path $CommonPaths.Home "Pictures") }
        "desktop" { Set-Location $CommonPaths.Desktop }
        "github" { Set-Location $CommonPaths.GitHub }
        default { Write-Error "Unknown location: $location"; return }
    }
    
    Get-ChildItem
}

# Export functions
Export-ModuleMember -Function Open-ExplorerHere, goto
