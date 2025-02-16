
Start-Process "https://winget.run/"
Start-Process "https://github.com/microsoft/winget-pkgs/tree/master"
winget install --help
winget install -e --id IronmanSoftware.PowerShellUniversal --silent --accept-package-agreements --accept-source-agreements &&
winget install -e --id JanDeDobbeleer.OhMyPosh  --silent --accept-package-agreements --accept-source-agreements &&
winget install TranslucentTB --silent --accept-package-agreements --accept-source-agreements &&
winget install Microsoft.PowerShell.Preview --silent --accept-package-agreements --accept-source-agreements &&
winget install Microsoft.WindowsTerminal.Canary --silent --accept-package-agreements --accept-source-agreements &&
winget install Microsoft.DirectX --silent --accept-package-agreements --accept-source-agreements &&
winget install -e --id Python.Python.3.12 --scope machine --silent --accept-package-agreements --accept-source-agreements &&
winget install Rufus.Rufus --silent --accept-package-agreements --accept-source-agreements &&
winget install vim.vim.nightly --silent --accept-package-agreements --accept-source-agreements &&
winget install RevoUninstaller.RevoUninstaller --silent --accept-package-agreements --accept-source-agreements &&
winget install Anysphere.Cursor --silent --accept-package-agreements --accept-source-agreements &&
winget install Everything  --silent --accept-package-agreements --accept-source-agreements &&
winget install KeePassXCTeam.KeePassXC --silent --accept-package-agreements --accept-source-agreements &&
winget install Apple.iCloud --silent --accept-package-agreements --accept-source-agreements &&
winget install voidtools.Everything --silent --accept-package-agreements --accept-source-agreements &&
winget install Inkscape  --silent --accept-package-agreements --accept-source-agreements &&
winget install Microsoft.PowerToys --silent --accept-package-agreements --accept-source-agreements &&
winget install mpv.net --silent --accept-package-agreements --accept-source-agreements &&
winget install streamdeck --silent --accept-package-agreements --accept-source-agreements &&
winget install reddit --silent --accept-package-agreements --accept-source-agreements &&
winget install BlenderFoundation.Blender --silent --accept-package-agreements --accept-source-agreements &&
winget install --id Valve.Steam --id SteamCMD --silent --accept-package-agreements --accept-source-agreements &&
winget install --id Hyper --silent --accept-package-agreements --accept-source-agreements &&
winget install --id GoLang.Go --accept-package-agreements --accept-source-agreements &&
winget install --id OpenJS.NodeJS --accept-package-agreements --accept-source-agreements &&
winget install -e --id NodeJS.Node.LTS --scope machine
winget install -e --id Rustlang.Rustup --accept-package-agreements --accept-source-agreements &&
winget install --id Odamex.Odamex  --accept-package-agreements --accept-source-agreements &&
winget install --id  GodotEngine.GodotEngine  --accept-package-agreements --accept-source-agreements &&
#? GoDot steam?
winget install -e --id GNU.Wget2 --accept-package-agreements --accept-source-agreements 
# TEXT EDITOR'S 
winget install --id  Neovim.Neovim --accept-package-agreements --accept-source-agreements &&
#Start-Process  "https://neovim.io/"
#Start-Process  "https://github.com/neovim/neovim/blob/master/INSTALL.md"
#Start-Process  "https://www.lunarvim.org/docs/installation"
# winget install iA Writer  --silent --accept-package-agreements --accept-source-agreements &&
# Start-Process "https://ia.net/writer/support/basics/markdown-guide"

#GRAPHICS

#CLI
winget install --id GitHub.cli
#Start-Process "https://cli.github.com/"
winget install --id Microsoft.Git

winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown to see all results.


#Hardware
winget install -e --id SteelSeries.SteelSeriesEngine --silent --accept-package-agreements --accept-source-agreements


#programing Interface
winget install -e --id Anaconda.Anaconda3 --silent --accept-package-agreements --accept-source-agreements