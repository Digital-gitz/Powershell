function Show-ProfileCommands {
    [CmdletBinding()]
    param(
        [switch]$Detailed
    )
    
    $commands = @{
        'Package Management' = @{
            'pkg-install <package>' = 'Install a package using winget'
            'pkg-update' = 'Update all installed packages'
            'pkg-list' = 'List installed packages'
            'pkg-status' = 'Show available package updates'
        }
        'Module Management' = @{
            'Import-RequiredModule' = 'Import and install if needed a PowerShell module'
            'Update-PowerShellModule' = 'Update PowerShell modules'
            'Remove-UnusedModules' = 'Clean up unused modules'
        }
        'URL Commands' = @{
            'gally' = 'Open PowerShell Gallery'
            'ythistory' = 'Open YouTube History'
            'Open-Ai' = 'Open AI-related sites'
            'Open-AiDev' = 'Open AI development sites'
            'Open-AiSearch' = 'Open AI search engines'
            'Open-GoogleCore' = 'Open Google core services'
            'Open-GoogleProductivity' = 'Open Google productivity tools'
            'Open-GoogleMedia' = 'Open Google media services'
            'Open-GoogleBusiness' = 'Open Google business tools'
            'Open-DevDocs' = 'Open developer documentation'
            'Open-DevGit' = 'Open Git platforms'
            'Open-DevLearn' = 'Open web development learning resources'
            'Open-DevJavaScript' = 'Open JavaScript resources'
            'Open-DevCss' = 'Open CSS resources'
            'Open-DevPackages' = 'Open package managers'
            'Open-DevCloud' = 'Open cloud platforms'
            'Open-FinanceStocks' = 'Open stock trading sites'
            'Open-FinanceTrading' = 'Open trading platforms'
            'Open-FinanceForex' = 'Open forex trading sites'
            'Open-FinanceCrypto' = 'Open cryptocurrency sites'
            'Open-FinanceBanking' = 'Open banking sites'
            'Open-FinanceCards' = 'Open credit card sites'
            'Open-NewsGeneral' = 'Open news sites'
            'Open-NewsTech' = 'Open tech news sites'
            'Open-NewsMusic' = 'Open music services'
            'Open-SocialPro' = 'Open professional networks'
            'Open-SocialPersonal' = 'Open personal social media'
            'Open-SocialContent' = 'Open content platforms'
            'Open-SocialCommunity' = 'Open community sites'
        }
        'Utility Commands' = @{
            'reload' = 'Reload PowerShell profile'
            'clr' = 'Clear console screen'
            'Get-Guid' = 'Generate a new GUID'
            'winrun' = 'Open winget.run in browser'
            'Show-Welcome' = 'Display welcome message'
            'Show-ProfileMetrics' = 'Display profile load metrics'
            'Show-ProfileCommands -Detailed' = 'Show detailed descriptions for commands'
            'Write-ProfileLog' = 'Write a log message to profile.log'
            'Note' = 'Create, read, and manage notes -Action [new, read, add, list, delete]'
        }
        'ect' = @{
            'Update-AllPackages' = 'Update all installed packages'
            'Install-Package <package>' = 'Install or update a package using winget'
            'Install-ConfiguredPackages' = 'Install packages configured in config.psd1'
            'Update-ConfiguredPackages' = 'Update packages configured in config.psd1'
            'Update-CustomScripts' = 'Update custom scripts from a GitHub repository'
        }
    }
    
    Write-Host "`nAvailable Profile Commands:" -ForegroundColor Cyan
    
    foreach ($category in $commands.Keys) {
        Write-Host "`n$($category):" -ForegroundColor Yellow
        
        $commands[$category].GetEnumerator() | ForEach-Object {
            if ($Detailed) {
                Write-Host ("  {0,-25}" -f $_.Key) -NoNewline -ForegroundColor Green
                Write-Host " - $($_.Value)" -ForegroundColor Gray
            } else {
                Write-Host "  $($_.Key)" -ForegroundColor Green
            }
        }
    }
    
    # Write-Host "`nTip: Use 'Show-ProfileCommands -Detailed' for command descriptions" -ForegroundColor DarkGray
}
