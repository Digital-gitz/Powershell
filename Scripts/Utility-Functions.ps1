function Get-Guid { [guid]::NewGuid().ToString() }

function Update-ModulePath {
    [Alias('modpath')]
    param (
        [switch]$Formatted,
        [switch]$Add,
        [string]$Path
    )
    # ... existing Update-ModulePath code ...
}

function Update-PowerShellProfile {
    [CmdletBinding()]
    [Alias('reload')]
    param(
        [switch]$SkipConfirmation
    )
    # ... existing Update-PowerShellProfile code ...
}

# Set basic aliases
Set-Alias -Name clr -Value Clear-Host
Set-Alias -Name reload -Value Update-PowerShellProfile 