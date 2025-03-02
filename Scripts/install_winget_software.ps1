# Function to check if a package is installed
function Test-PackageInstalled {
    param (
        [string]$PackageId
    )
    
    $result = winget list --id $PackageId --exact
    return $LASTEXITCODE -eq 0
}

# Function to install a package using winget
function Install-WingetPackage {
    param (
        [string]$PackageId,
        [string]$Scope = "user", # Default scope is user
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
    winget @arguments
}

# Function to update a package using winget
function Update-WingetPackage {
    param (
        [string]$PackageId,
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
    winget @arguments
}

# Function to install or update a package
function Install-OrUpdatePackage {
    param (
        [string]$PackageId,
        [string]$Scope = "user"
    )
    
    if (Test-PackageInstalled -PackageId $PackageId) {
        Update-WingetPackage -PackageId $PackageId
    } else {
        Install-WingetPackage -PackageId $PackageId -Scope $Scope
    }
}

# Open web pages for reference
Start-Process "https://winget.run/"
Start-Process "https://github.com/microsoft/winget-pkgs/tree/master"

# List of packages to install or update (removing duplicates)
$packages = @(
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

# Install or update all packages
foreach ($package in $packages) {
    $id = $package.Id
    $scope = if ($package.ContainsKey('Scope')) { $package.Scope } else { "user" }
    
    try {
        Install-OrUpdatePackage -PackageId $id -Scope $scope
    } catch {
        Write-Host "Failed to process $id. Error: $_" -ForegroundColor Red
    }
}

Write-Host "All packages processed. Check above for any errors." -ForegroundColor Green