Write-Host ""
Write-Host "═════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "🖥️  APPLICATIONS" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Start-Aseprite"; Desc = "Starts Aseprite Pixel Art Editor" }
    @{ Name = "Start-DoomEternal"; Desc = "Starts Doom Eternal" }
    @{ Name = "godot"; Desc = "Starts Godot" }
    @{ Name = "edge"; Desc = "Starts Edge" }
    @{ Name = "TwitchOverlay"; Desc = "Launches Twitch Chat Overlay" }
    @{ Name = "programs"; Desc = "List Programs" }
    @{ Name = "fonts"; Desc = "Navigate to the fonts folder" }
)

Write-Host ""
Write-Host "📂 NAVIGATION" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "ghub"; Desc = "Go to Github Folder and list" }
    @{ Name = "ddump"; Desc = "Go to DigitalHubDump Folder" }
    @{ Name = "edit_powershell"; Desc = "Edit my PowerShell Profile" }
    @{ Name = "cd_blog"; Desc = "Opens My Obsidian Blog" }
    @{ Name = "o_blog"; Desc = "Navigate To my Obsidian Hugo Blog page" }
    @{ Name = "cd_obsidianRoot"; Desc = "Navigate Obsidian cloud directory" }
)

Write-Host ""
Write-Host "🔎 SEARCH & HISTORY" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Search-CommandHistory or h"; Desc = "Search Commands History" }
    @{ Name = "h <pattern>"; Desc = "Search command history" }
    @{ Name = "list_llm"; Desc = "List of my LLMs" }
    @{ Name = "Search-GoPackages"; Desc = "Search Go packages" }
    @{ Name = "Search-PyPiPackages"; Desc = "Search Python package to install" }
    @{ Name = "Search-GitHubRepositories"; Desc = "Search GitHub Repo package to install" }
    @{ Name = "Search-GitHubRepos"; Desc = "Search GitHub Repos" }
    @{ Name = "Search-NpmPackages"; Desc = "Search Node Package Manager" }
)

Write-Host ""
Write-Host "🌐 INTERNET & UTILITIES" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Open-Gmail"; Desc = "Opens up Gmail" }
    @{ Name = "Get-MyIP"; Desc = "Get my IP" }
    @{ Name = "Get-BIOSInfo"; Desc = "Get BIOS Info" }
    @{ Name = "Get-SshStatus"; Desc = "Get the status of SSH (might need elevated permission)" }
    @{ Name = "Get-StockMarketSummary"; Desc = "Get Stock Market Summary" }
    @{ Name = "New-QRCode"; Desc = "Generate a QR code" }
    @{ Name = "Open-FloridaBlueMemberPortal"; Desc = "Open Florida Blue Member Portal" }
    @{ Name = "Open-EdgePasswords"; Desc = "Open Edge Passwords" }
    @{ Name = ".\Get-ChromeTabs.ps1"; Desc = "get chrome tabs" }
)

Write-Host ""
Write-Host "📱 SOCIAL MEDIA" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Open-SocialChat"; Desc = "Open all social media platforms" }
    @{ Name = "Get-SocialFunctions"; Desc = "Show all social media functions" }
    @{ Name = "Get-SocialCategories"; Desc = "Show social media categories" }
    @{ Name = "facebook, twitter, youtube, twitch, etc."; Desc = "Open specific platforms" }
)

Write-Host ""
Write-Host "🛠️  GITHUB & GIT" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Git-QuickPush"; Desc = "Quick push the repo" }
    @{ Name = "Git_QuickPush"; Desc = "Quick push to Repo (Warning: could be faulty)" }
    @{ Name = "gh_create_repo"; Desc = "Create a repo in the working directory" }
    @{ Name = "Update-AllRepos"; Desc = "Update Github Repos" }
    @{ Name = "New-GitHubRepository"; Desc = "New Github Repo" }
    @{ Name = "Open-GitHubRepo"; Desc = "Opens a specified GitHub repository" }
    @{ Name = "Set-GitHubRepoVisibility -Owner <myusername> -Repo <myrepo>"; Desc = "Toggle visibility of myusername/myrepo (use -Visibility <public/private>)" }
    @{ Name = "Get-GitHubRepoList"; Desc = "Get My Repo List" }
    @{ Name = "Get-GitHubRepoView"; Desc = "View Repo" }
    @{ Name = "Get-GitHubRepoclone"; Desc = "Clone repo" }
    @{ Name = "password_manager"; Desc = "Password Manager" }
)

Write-Host ""
Write-Host "📦 DOWNLOADS" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Download_File"; Desc = "Download file -Url <URL>" }
    @{ Name = "Download_AndRunFile"; Desc = "Download and run file -Url <URL>" }
)

Write-Host ""
Write-Host "❓ HELPERS" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Get-AllFunctions"; Desc = "Show all available functions by category" }
    @{ Name = "Get-FunctionHelp"; Desc = "Show detailed help for a specific function" }
    @{ Name = "Startup"; Desc = "Open Startup folder on bootup of windows." }
    @{ Name = "sleep"; Desc = "Put the computer to sleep." }
    @{ Name = "restart"; Desc = "Restart the PowerShell session." }
    @{ Name = "programs"; Desc = "List all programs installed on the computer." }
    @{ Name = "Get-AlphabeticalFileList"; Desc = "example: Get-AlphabeticalFileList -FolderPath C:\Users\\Desktop" }
)

Write-Host ""
Write-Host "🎨 ART" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "nmcal"; Desc = "Open a curated list of interesting websites" }
    @{ Name = "Show-ArtCommands"; Desc = "Show Art Commands" }
)
Write-Host ""
Write-Host "🤖 AI" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "gemini_url"; Desc = "Open Gemini URL" }
    @{ Name = "gemini_user"; Desc = "Open Gemini User" }
)

Write-Host ""
Write-Host "📁 Files & Directories" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Remove-ItemWithElevation"; Desc = "Remove file or folder with elevated permissions" }
    @{ Name = "Get-AlphabeticalFileList"; Desc = "example: Get-AlphabeticalFileList -FolderPath C:\Users\\Desktop" }
    @{ Name = "Get-My_IP"; Desc = "Get my IP" }
)

Write-Host ""
Write-Host "🔒 SECURITY" -ForegroundColor Cyan
Show-CommandList @(
    @{ Name = "Get-My_IP"; Desc = "Get my IP" }
    @{ Name = "New-SecurePassword"; Desc = "New-SecurePassword -Length [number] Options: [-NoNumbers -NoSymbols -NoUppercase -NoLowercase]" }
)




Write-Host ""
Write-Host "═════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
"─────────────────────────────────────────────────────────────────────────────"