#region Aliases
$aliasDefinitions = @{
    'ai-search'           = 'Open-AiSearch'
    'google-core'         = 'Open-GoogleCore'
    'google-productivity' = 'Open-GoogleProductivity'
    'google-media'        = 'Open-GoogleMedia'
    'clr'                 = 'Clear-Host'
    'home'                = 'Set-HomeLocation'
    'reload'              = 'Update-PowerShellProfile'
    'checkpath'           = 'Show-Path'
    'path'                = { Show-Path -Formatted }
    'files'               = 'Get-FilesBaseName'
    'lsa'                 = 'Get-ChildItem -Force'
    'touch'               = { param($f) New-Item -ItemType File -Path $f -Force }
    'which'               = { param($c) (Get-Command $c).Path }
}

function Set-ProfileAliases {
    foreach ($alias in $aliasDefinitions.GetEnumerator()) {
        try {
            if ($alias.Value -is [scriptblock]) {
                Set-Item -Path "function:__alias_$($alias.Key)" -Value $alias.Value
                Set-Alias -Name $alias.Key -Value "__alias_$($alias.Key)" -ErrorAction Stop
            }
            else {
                Set-Alias -Name $alias.Key -Value $alias.Value -ErrorAction Stop
            }
            Write-Log "Set alias: $($alias.Key)" -Level 'Success'
        }
        catch {
            Write-Log "Failed to set alias $($alias.Key): $_" -Level 'Warning'
        }
    }

    # Add alias for singular version
    Set-Alias -Name Get-ScriptsFunction -Value Get-ScriptsFunctions
}
#endregion Aliases 