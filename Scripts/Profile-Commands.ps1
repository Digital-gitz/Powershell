function Show-ProfileCommands {
    [CmdletBinding()]
    param(
        [switch]$Detailed
    )
    # ... existing Show-ProfileCommands code ...
}

function Show-Welcome {
    [CmdletBinding()]
    param(
        [switch]$ShowCommands,
        [switch]$ShowSystemInfo,
        [int]$DelaySeconds = 2
    )
    # ... existing Show-Welcome code ...
} 