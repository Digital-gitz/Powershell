# Open web pages for reference
Start-Process "https://winget.run/"
Start-Process "https://github.com/microsoft/winget-pkgs/tree/master"

# Display winget install help
winget install --help

# Install software packages
winget install -e --id IronmanSoftware.PowerShellUniversal --silent --accept-package-agreements --accept-source-agreements
winget install -e --id JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements --accept-source-agreements
winget install TranslucentTB --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.PowerShell.Preview --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.WindowsTerminal.Canary --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.DirectX --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Python.Python.3.12 --scope machine --silent --accept-package-agreements --accept-source-agreements
winget install Rufus.Rufus --silent --accept-package-agreements --accept-source-agreements
winget install RevoUninstaller.RevoUninstaller --silent --accept-package-agreements --accept-source-agreements
winget install Anysphere.Cursor --silent --accept-package-agreements --accept-source-agreements
winget install Everything --silent --accept-package-agreements --accept-source-agreements
winget install KeePassXCTeam.KeePassXC --silent --accept-package-agreements --accept-source-agreements
winget install Apple.iCloud --silent --accept-package-agreements --accept-source-agreements
winget install voidtools.Everything --silent --accept-package-agreements --accept-source-agreements
winget install Inkscape --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.PowerToys --silent --accept-package-agreements --accept-source-agreements
winget install mpv.net --silent --accept-package-agreements --accept-source-agreements
winget install streamdeck --silent --accept-package-agreements --accept-source-agreements
winget install reddit --silent --accept-package-agreements --accept-source-agreements
winget install BlenderFoundation.Blender --silent --accept-package-agreements --accept-source-agreements
winget install --id Valve.Steam --id SteamCMD --silent --accept-package-agreements --accept-source-agreements
winget install --id Hyper --silent --accept-package-agreements --accept-source-agreements
winget install --id GoLang.Go --accept-package-agreements --accept-source-agreements
winget install --id OpenJS.NodeJS --accept-package-agreements --accept-source-agreements
winget install -e --id NodeJS.Node.LTS --scope machine
winget install -e --id Rustlang.Rustup --accept-package-agreements --accept-source-agreements
winget install --id Odamex.Odamex --accept-package-agreements --accept-source-agreements
winget install --id GodotEngine.GodotEngine --accept-package-agreements --accept-source-agreements
winget install -e --id GNU.Wget2 --accept-package-agreements --accept-source-agreements
#windows Software
winget install --id Microsoft.WindowsTerminal --silent --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShellCore --silent --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShellPreview --silent --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShellUniversal --silent --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShellUniversalPreview --silent --accept-package-agreements --accept-source-agreements
# Text Readers & Editors
winget install --id Neovim.Neovim --accept-package-agreements --accept-source-agreements
winget install --id SumatraPDF.SumatraPDF --silent --accept-package-agreements --accept-source-agreements

# Hardware
winget install -e --id SteelSeries.SteelSeriesEngine --silent --accept-package-agreements --accept-source-agreements

# Programming Interface
winget install -e --id Anaconda.Miniconda3 --silent --accept-package-agreements --accept-source-agreements

# CLI Tools
winget install -e --id Nushell.Nushell --silent --accept-package-agreements --accept-source-agreements
winget install --id GitHub.cli
winget install --id Microsoft.Git
winget install vim.vim.nightly --silent --accept-package-agreements --accept-source-agreements
winget install hpjansson.Chafa --silent --accept-package-agreements --accept-source-agreements

# Windows Terminal
winget install GNU.Wget2 -e --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Microsoft.WindowsTerminal --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Microsoft.PowerShellCore --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Microsoft.PowerShellPreview --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Microsoft.PowerShellUniversal --silent --accept-package-agreements --accept-source-agreements

# Windows Terminal-based Apps
winget install -e --id achannarasappa.ticker --silent --accept-package-agreements --accept-source-agreements

# Programs
winget install -e --id Figma.Figma --silent --accept-package-agreements --accept-source-agreements
winget install -e --id Figma.FigmaAgent --silent --accept-package-agreements --accept-source-agreements

# Developer Tools
winget install -e --id Insomnia.Insomnia --silent --accept-package-agreements --accept-source-agreements

# Upgrade all installed packages
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown




@{ Id = "Microsoft.DirectX" },
Python.Python.3.12
RevoUninstaller.RevoUninstaller
voidtools.Everything
Apple.iCloud
Inkscape.Inkscape
Elgato.StreamDeck
BlenderFoundation.Blender
GoLang.Go
OpenJS.NodeJS.LTS
Rustlang.Rustup
Odamex.Odamex
Neovim.Neovim
SteelSeries.GG
Nushell.Nushell
vim.vim
Docker.DockerDesktop