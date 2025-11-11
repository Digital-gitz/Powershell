# GitHub Copilot commands
function Invoke-Copilot {
    gh copilot
}

function Invoke-CopilotSuggest {
    gh copilot suggest
}

function Invoke-CopilotExplain {
    gh copilot explain
}

# Set up aliases
Set-Alias -Name copilot -Value Invoke-Copilot
Set-Alias -Name ghs -Value Invoke-CopilotSuggest
Set-Alias -Name gce -Value Invoke-CopilotExplain

# Export the functions and aliases
Export-ModuleMember -Function Invoke-Copilot, Invoke-CopilotSuggest, Invoke-CopilotExplain
Export-ModuleMember -Alias copilot, ghs, gce




