# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# List of packages to install
$packages = @(
    "unzip",
    "wget",
    "gzip",
    "rust",
    "composer",
    "php",
    "ruby",
    "jdk8",
    "julia",
    "luarocks",
    "mingw",
    "strawberryperl"
)

# Install each package
foreach ($package in $packages) {
    choco install $package -y
}

# Ensure Python3 and Neovim module are installed
python -m pip install neovim
