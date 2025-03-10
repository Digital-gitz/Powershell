function Invoke-PackageManager {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Install', 'Update', 'List', 'Status')]
        [string]$Action,
        [string]$PackageId,
        [string]$Scope = "user",
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    # ... existing Invoke-PackageManager code ...
}

# Package management functions and aliases
function Install-Package { ... }
function Update-AllPackages { ... }
function Get-InstalledPackages { ... }
function Get-PackageStatus { ... }
function Update-ConfiguredPackages { ... }

# Set aliases
Set-Alias -Name 'pkg-install' -Value 'Install-Package'
Set-Alias -Name 'pkg-update' -Value 'Update-AllPackages'
Set-Alias -Name 'pkg-list' -Value 'Get-InstalledPackages'
Set-Alias -Name 'pkg-status' -Value 'Get-PackageStatus' 