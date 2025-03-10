function Test-ProfileConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Config
    )
    # ... existing Test-ProfileConfiguration code ...
}

function Write-ProfileLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info',
        [string]$LogDirectory = $null
    )
    # ... existing Write-ProfileLog code ...
} 