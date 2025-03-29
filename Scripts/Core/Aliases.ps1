#region Aliases
$aliasDefinitions = @{
    'clr'       = 'Clear-Host'
    'home'      = 'Set-HomeLocation'
    'checkpath' = 'Show-Path'
    'path'      = { Show-Path -Formatted }
    'files'     = 'Get-FilesBaseName'
    'lsa'       = 'Get-ChildItem -Force'
    'touch'     = { param($f) New-Item -ItemType File -Path $f -Force }
    'which'     = { param($c) (Get-Command $c).Path }
}

function Set-ProfileAliases {
    foreach ($alias in $aliasDefinitions.GetEnumerator()) {
        try {
            if ($alias.Value -is [scriptblock]) {
                Set-Item -Path "function:global:__alias_$($alias.Key)" -Value $alias.Value
                Set-Alias -Name $alias.Key -Value "__alias_$($alias.Key)" -Scope Global -ErrorAction Stop
            }
            elseif ($alias.Value -match '\s') {
                $scriptBlock = [ScriptBlock]::Create($alias.Value)
                Set-Item -Path "function:global:__alias_$($alias.Key)" -Value $scriptBlock
                Set-Alias -Name $alias.Key -Value "__alias_$($alias.Key)" -Scope Global -ErrorAction Stop
            }
            else {
                Set-Alias -Name $alias.Key -Value $alias.Value -Scope Global -ErrorAction Stop
            }
        }
        catch {
            Write-Host "Failed to set alias '$($alias.Key)': $_" -ForegroundColor Red
        }
    }

    # Add alias for singular version
    Set-Alias -Name Get-ScriptsFunction -Value Get-ScriptsFunctions -Scope Global
}
#endregion Aliases

Set-ProfileAliases
Write-Host "Aliases loaded successfully!" -ForegroundColor Green
