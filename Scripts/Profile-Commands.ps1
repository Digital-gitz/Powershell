function Show-ProfileCommands {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [string]$Category,
        [switch]$NoColor
    )
    
    $commands = @{
        'Package Management' = @{
            'pkg-install <package>' = 'Install a package using winget'
            'pkg-update' = 'Update all installed packages'
            'pkg-list' = 'List installed packages'
            'pkg-status' = 'Show available package updates'
            'Install-Package' = 'Install or update a specific package using winget'
            'Install-ConfiguredPackages' = 'Install packages from config.psd1'
        }
        'Module Management' = @{
            'Import-RequiredModule' = 'Import and install if needed a PowerShell module'
            'Update-PowerShellModule' = 'Update PowerShell modules'
            'Remove-UnusedModules' = 'Clean up unused modules'
            'Update-ModulePath' = 'Display or update PowerShell module paths'
            'modpath' = 'Alias for Update-ModulePath'
        }
        'URL Commands' = @{
            'llm' = 'Open AI sites (ChatGPT, Claude, Gemini, etc.)'
            'Open-AiPKGsearch' = 'Open AI development sites (HuggingFace, TensorFlow, etc.)'
            'Open-AiSearch' = 'Open AI search engines (Perplexity, Phind, etc.)'
            'Open-DevDocs' = 'Open developer documentation'
            'Open-GoogleCore' = 'Open Google core services'
            'Open-GoogleProductivity' = 'Open Google productivity tools'
            'Open-GoogleMedia' =  'Open Google media services'
            'Open-GoogleBusiness' = 'Open Google business tools'
            # 'Open-AiArt' = 'Open AI art generation sites'
            # 'Open-GoogleBusiness' = 'Open Google business tools'
            # 'Open-DevGit' = 'Open Git platforms'
            # 'Open-DevLearn' = 'Open web development learning resources'
            # 'Open-DevJavaScript' = 'Open JavaScript resources'
            # 'Open-DevCss' = 'Open CSS resources'
            # 'Open-DevPackages' = 'Open package managers'
            # 'Open-DevCloud' = 'Open cloud platforms'
            # 'Open-DevMacro' = 'Open microcontroller and hardware sites'
            # 'Open-FinanceStocks' = 'Open stock trading sites'
            # 'Open-FinanceTrading' = 'Open trading platforms'
            # 'Open-FinanceForex' = 'Open forex trading sites'
            # 'Open-FinanceCrypto' = 'Open cryptocurrency sites'
            # 'Open-FinanceBanking' = 'Open banking sites'
            # 'Open-FinanceWallets' = 'Open digital wallet sites'
            # 'Open-FinanceCards' = 'Open credit card sites'
            # 'Open-FinanceRealEstate' = 'Open real estate sites'
            # 'Open-FinanceInsurance' = 'Open insurance sites'
            # 'Open-FinanceRetirement' = 'Open retirement planning sites'
            # 'Open-NewsGeneral' = 'Open general news sites'
            # 'Open-NewsTech' = 'Open tech news sites'
            # 'Open-NewsMusic' = 'Open music services'
            # 'Open-ArtReff' = 'Open art reference and resource sites'
            # 'Open-SocialPro' = 'Open professional networks'
            # 'Open-SocialPersonal' = 'Open personal social media'
            # 'Open-SocialContent' = 'Open content platforms'
            # 'Open-SocialCommunity' = 'Open community sites'
            # 'Open-LearningPlatforms' = 'Open educational platforms'
            # 'Open-LearningDocs' = 'Open documentation sites'
            # 'Open-UtilityDrawing' = 'Open drawing and design tools'
            # 'Open-UtilityLoans' = 'Open loan services'
            # 'Open-UtilityEnergy' = 'Open energy provider sites'
        }
        'Utility Commands' = @{
            'reload' = 'Reload PowerShell profile'
            'clr' = 'Clear console screen'
            'Get-Guid' = 'Generate a new GUID'
            'Show-Welcome' = 'Display welcome message'
            'Show-ProfileMetrics' = 'Display profile load metrics'
            'Show-ProfileCommands -Detailed' = 'Show detailed descriptions for commands'
            'Write-ProfileLog' = 'Write a log message to profile.log'
            'Note' = 'Create, read, and manage notes -Action [new, read, add, list, delete]'
        }
    }
    
    # Color configuration
    $colors = @{
        Header = if ($NoColor) { 'White' } else { 'Cyan' }
        Category = if ($NoColor) { 'White' } else { 'Yellow' }
        Command = if ($NoColor) { 'White' } else { 'Green' }
        Description = if ($NoColor) { 'White' } else { 'Gray' }
        Tip = if ($NoColor) { 'White' } else { 'DarkGray' }
    }

    # Header
    Write-Host "`nAvailable Profile Commands:" -ForegroundColor $colors.Header
    
    # Filter categories if specified
    $categoriesToShow = if ($Category) {
        $commands.Keys | Where-Object { $_ -like "*$Category*" }
    } else {
        $commands.Keys
    }

    # Display commands
    foreach ($category in $categoriesToShow) {
        Write-Host "`n$($category):" -ForegroundColor $colors.Category
        
        $commands[$category].GetEnumerator() | Sort-Object Key | ForEach-Object {
            if ($Detailed) {
                Write-Host ("  {0,-30}" -f $_.Key) -NoNewline -ForegroundColor $colors.Command
                Write-Host " - $($_.Value)" -ForegroundColor $colors.Description
            } else {
                Write-Host "  $($_.Key)" -ForegroundColor $colors.Command
            }
        }
    }
    
    # Show tips
    if (-not $Category) {
        Write-Host "`nTips:" -ForegroundColor $colors.Tip
        Write-Host "- Use 'Show-ProfileCommands -Detailed' for command descriptions" -ForegroundColor $colors.Tip
        Write-Host "- Use 'Show-ProfileCommands -Category <name>' to filter by category" -ForegroundColor $colors.Tip
        Write-Host "- Use 'Show-ProfileCommands -NoColor' for plain text output" -ForegroundColor $colors.Tip
    }
}
