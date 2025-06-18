# NetworkTools.ps1
# Created 2025-03-03
# Description: Add your description here

function Get-ScriptInfo {
    [CmdletBinding()]
    param()
    
    Write-Host "Script: NetworkTools.ps1" -ForegroundColor Cyan
    Write-Host "This is a placeholder function. Please add your actual code here."
}


function Get-My_IP {
    curl ipinfo.io
}

# Add your functions below this line
