# WingetManager.ps1
# Purpose: Manages installation and updating of software packages using Winget
# Add this to your PowerShell Scripts directory

# Configuration for common packages
$Global:WingetPackages = @(
    @{ Id = "IronmanSoftware.PowerShellUniversal" },
    @{ Id = "JanDeDobbeleer.OhMyPosh" },
    @{ Id = "9PCKT2B7DZMW" }, # TranslucentTB (using Microsoft Store ID)
    @{ Id = "Microsoft.PowerShell" },
    @{ Id = "Microsoft.WindowsTerminal" },
    @{ Id = "Microsoft.DirectX" },
    @{ Id = "Python.Python.3.12"; Scope = "machine" },
    @{ Id = "Rufus.Rufus" },
    @{ Id = "RevoUninstaller.RevoUninstaller" },
    @{ Id = "Anysphere.Cursor" },
    @{ Id = "voidtools.Everything" },
    @{ Id = "KeePassXCTeam.KeePassXC" },
    @{ Id = "Apple.iCloud" },
    @{ Id = "Inkscape.Inkscape" },
    @{ Id = "Microsoft.PowerToys" },
    @{ Id = "mpvnet.mpvnet" },
    @{ Id = "Elgato.StreamDeck" },
    @{ Id = "Reddit.Reddit" },
    @{ Id = "BlenderFoundation.Blender" },
    @{ Id = "Valve.Steam" },
    @{ Id = "Valve.SteamCMD" },
    @{ Id = "Zeit.Hyper" },
    @{ Id = "GoLang.Go" },
    @{ Id = "OpenJS.NodeJS.LTS"; Scope = "machine" },
    @{ Id = "Rustlang.Rustup" },
    @{ Id = "Odamex.Odamex" },
    @{ Id = "GodotEngine.GodotEngine" },
    @{ Id = "GNU.Wget2" },
    @{ Id = "Neovim.Neovim" },
    @{ Id = "SumatraPDF.SumatraPDF" },
    @{ Id = "SteelSeries.GG" },
    @{ Id = "Anaconda.Miniconda3" },
    @{ Id = "Nushell.Nushell" },
    @{ Id = "GitHub.cli" },
    @{ Id = "Microsoft.Git" },
    @{ Id = "vim.vim" },
    @{ Id = "hpjansson.Chafa" },
    @{ Id = "achannarasappa.ticker" },
    @{ Id = "Figma.Figma" },
    @{ Id = "Figma.FigmaAgent" },
    @{ Id = "Insomnia.Insomnia" }
)

# Function to check if a package is installed
function Test-PackageInstalled {
    param (
        [Parameter(Mandatory)][string]$PackageId
    )
    
    $output = winget list --id $PackageId --exact 2>&1
    return $output -match $PackageId
}

# Function to install a package using winget
function Install-WingetPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [string]$Scope = "user",
        [switch]$Silent = $true,
        [switch]$AcceptAgreements = $true
    )

    $arguments = @(
        "install",
        "--id", $PackageId,
        "--scope", $Scope
    )

    if ($Silent) {
        $arguments += "--silent"
    }

    if ($AcceptAgreements) {
        $arguments += "--accept-package-agreements", "--accept-source-agreements"
    }

    # Execute the winget command
    Write-Host "Installing $PackageId..." -ForegroundColor Cyan
    & winget @arguments
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully installed $PackageId" -ForegroundColor Green
    } else {
        Write-Warning "Failed to install $PackageId. Exit code: $LASTEXITCODE"
    }
}

# Function to update a package using winget
function Update-WingetPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [switch]$Silent = $true,
        [switch]$AcceptAgreements = $true
    )

    $arguments = @(
        "upgrade",
        "--id", $PackageId
    )

    if ($Silent) {
        $arguments += "--silent"
    }

    if ($AcceptAgreements) {
        $arguments += "--accept-package-agreements", "--accept-source-agreements"
    }

    # Execute the winget command
    Write-Host "Updating $PackageId..." -ForegroundColor Yellow
    & winget @arguments
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully updated $PackageId" -ForegroundColor Green
    } else {
        Write-Host "No update needed or update failed for $PackageId" -ForegroundColor DarkYellow
    }
}

# Function to install or update a package
function Install-OrUpdatePackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [string]$Scope = "user"
    )
    
    if (Test-PackageInstalled -PackageId $PackageId) {
        Update-WingetPackage -PackageId $PackageId
    } else {
        Install-WingetPackage -PackageId $PackageId -Scope $Scope
    }
}

# Function to process all packages
function Install-AllPackages {
    [CmdletBinding()]
    param(
        [switch]$SkipInstalled
    )
    
    $total = $Global:WingetPackages.Count
    $current = 0
    
    foreach ($package in $Global:WingetPackages) {
        $current++
        $id = $package.Id
        $scope = if ($package.ContainsKey('Scope')) { $package.Scope } else { "user" }
        
        Write-Progress -Activity "Processing Packages" -Status "Package $current of $total: $id" -PercentComplete (($current / $total) * 100)
        
        if ($SkipInstalled -and (Test-PackageInstalled -PackageId $id)) {
            Write-Host "Skipping already installed package: $id" -ForegroundColor DarkGray
            continue
        }
        
        try {
            Install-OrUpdatePackage -PackageId $id -Scope $scope
        } catch {
            Write-Host "Failed to process $id. Error: $_" -ForegroundColor Red
        }
    }
    
    Write-Progress -Activity "Processing Packages" -Completed
    Write-Host "All packages processed. Check above for any errors." -ForegroundColor Green
}

# Function to update all installed packages
function Update-AllInstalledPackages {
    [CmdletBinding()]
    param()
    
    Write-Host "Updating all installed packages..." -ForegroundColor Yellow
    & winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "All packages updated successfully" -ForegroundColor Green
    } else {
        Write-Warning "Some packages may have failed to update"
    }
}

# Function to open reference URLs
function Open-WingetReferences {
    [CmdletBinding()]
    param()
    
    $urls = @(
        "https://winget.run/",
        "https://github.com/microsoft/winget-pkgs/tree/master"
    )
    
    foreach ($url in $urls) {
        Start-Process $url
    }
    
    Write-Host "Opened Winget reference sites" -ForegroundColor Green
}

# Add aliases
Set-Alias -Name winget-install -Value Install-AllPackages
Set-Alias -Name winget-update -Value Update-AllInstalledPackages
Set-Alias -Name winget-refs -Value Open-WingetReferences

# Export functions and aliases
Export-ModuleMember -Function Test-PackageInstalled, Install-WingetPackage, Update-WingetPackage, Install-OrUpdatePackage, Install-AllPackages, Update-AllInstalledPackages, Open-WingetReferences -Alias winget-install, winget-update, winget-refs