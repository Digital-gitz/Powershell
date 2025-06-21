#region Social Media Functions
<#
.SYNOPSIS
Social media URL management and opening functions

.DESCRIPTION
This script provides functions to open various social media platforms
and manage social media URLs efficiently with parallel processing.

.NOTES
Author: Svyatoslav Oleg Russkiy
Version: 2.0 (Optimized)
#>

# Initialize logging if not available
if (-not (Get-Command -Name Write-ProfileLog -ErrorAction SilentlyContinue)) {
    function Write-ProfileLog {
        param($Message, $Level = 'Info', $Source = 'Social-Funk')
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $color = switch ($Level) {
            'Info' { 'Cyan' }
            'Warning' { 'Yellow' }
            'Error' { 'Red' }
            'Success' { 'Green' }
        }
        Write-Host "[$timestamp] [$Source] [$Level] $Message" -ForegroundColor $color
    }
}

Write-ProfileLog "Loading Social Media Functions..." -Level 'Info'

# Social media URL definitions with categories
$script:SocialMediaUrls = @{
    Meta          = @{
        Facebook  = "https://www.facebook.com/"
        Threads   = "https://www.threads.com/"
        Instagram = "https://www.instagram.com/"
    }
    Art           = @{
        DeviantArt = "https://www.deviantart.com/"
        ArtStation = "https://www.artstation.com/"
        Pinterest  = "https://www.pinterest.com/"
    }
    Microblogging = @{
        Twitter  = "https://x.com/"
        Bluesky  = "https://bsky.app/"
        Tumblr   = "https://www.tumblr.com/"
        Telegram = "https://web.telegram.org/"
    }
    Video         = @{
        YouTube = "https://www.youtube.com/"
        TikTok  = "https://www.tiktok.com/"
        Twitch  = "https://www.twitch.tv/"
        Kick    = "https://kick.com/"
        Rumble  = "https://rumble.com/"
    }
    Professional  = @{
        LinkedIn = "https://www.linkedin.com/"
        Reddit   = "https://www.reddit.com/"
    }
    Communication = @{
        Discord = "https://www.discord.com/"
        tiktok  = "https://www.tiktok.com/"
    }
    Music         = @{
        Spotify    = "https://open.spotify.com/"
        SpotifyAPI = "https://developer.spotify.com/documentation/web-api"
    }
}

# Flatten URLs for the Open-SocialChat function
$script:AllSocialUrls = $script:SocialMediaUrls.Values | ForEach-Object { $_.Values } | Where-Object { $_ -ne $null }

#region Core Functions

function global:Open-SocialChat {
    <#
    .SYNOPSIS
    Opens all social media services in parallel

    .DESCRIPTION
    Opens all configured social media URLs using parallel processing for better performance.
    Supports progress display and error handling.

    .PARAMETER ShowProgress
    Shows a progress bar during URL opening

    .PARAMETER Category
    Opens only URLs from a specific category (Meta, Art, Microblogging, Video, Professional, Communication, Music)

    .EXAMPLE
    Open-SocialChat
    Opens all social media services

    .EXAMPLE
    Open-SocialChat -ShowProgress
    Opens all services with progress display

    .EXAMPLE
    Open-SocialChat -Category Video
    Opens only video platforms (YouTube, TikTok, Twitch, etc.)
    #>
    [CmdletBinding()]
    param(
        [switch]$ShowProgress,
        [ValidateSet('Meta', 'Art', 'Microblogging', 'Video', 'Professional', 'Communication', 'Music')]
        [string]$Category
    )
    
    $urlsToOpen = if ($Category) {
        $script:SocialMediaUrls[$Category].Values
    }
    else {
        $script:AllSocialUrls
    }

    if (-not $urlsToOpen) {
        Write-ProfileLog "No URLs found for category: $Category" -Level 'Warning'
        return
    }

    Write-Host "`n🌐 Opening Social Media Services..." -ForegroundColor Cyan
    if ($Category) {
        Write-Host "Category: $Category" -ForegroundColor Yellow
    }
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray

    # Create a runspace pool for parallel processing
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, 10)
    $runspacePool.Open()
    $runspaces = New-Object System.Collections.ArrayList
    $failedUrls = New-Object System.Collections.ArrayList

    # Create a script block for opening URLs
    $scriptBlock = {
        param($url)
        try {
            Start-Process $url -WindowStyle Minimized
            return @{ Success = $true; Url = $url }
        }
        catch {
            return @{ Success = $false; Url = $url; Error = $_.Exception.Message }
        }
    }

    # Start all URL openings in parallel
    foreach ($url in $urlsToOpen) {
        $runspace = [powershell]::Create().AddScript($scriptBlock).AddArgument($url)
        $runspace.RunspacePool = $runspacePool
        $runspaces.Add(@{
                Runspace = $runspace
                Handle   = $runspace.BeginInvoke()
                Url      = $url
            }) | Out-Null
    }

    # Process results as they complete
    $completed = 0
    foreach ($runspace in $runspaces) {
        $result = $runspace.Runspace.EndInvoke($runspace.Handle)
        $completed++
        
        if ($ShowProgress) {
            $percentComplete = ($completed / $urlsToOpen.Count) * 100
            Write-Progress -Activity "Opening Social Media Services" -Status "$($runspace.Url)" -PercentComplete $percentComplete
        }

        if ($result.Success) {
            Write-Host "✓ $($runspace.Url)" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Failed to open $($runspace.Url)" -ForegroundColor Red
            $failedUrls.Add($runspace.Url) | Out-Null
        }

        $runspace.Runspace.Dispose()
    }

    # Cleanup
    $runspacePool.Close()
    $runspacePool.Dispose()

    if ($ShowProgress) {
        Write-Progress -Activity "Opening Social Media Services" -Completed
    }

    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    if ($failedUrls.Count -eq 0) {
        Write-ProfileLog "All social media services opened successfully!" -Level 'Success'
    }
    else {
        Write-ProfileLog "Some URLs failed to open:" -Level 'Warning'
        $failedUrls | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    }
    Write-Host
}

#endregion Core Functions

#region Individual Platform Functions

function global:facebook { 
    <#
    .SYNOPSIS
    Opens Facebook
    #>
    Write-ProfileLog "Opening Facebook..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Meta.Facebook
}

function global:threads { 
    <#
    .SYNOPSIS
    Opens Threads
    #>
    Write-ProfileLog "Opening Threads..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Meta.Threads
}

function global:instagram { 
    <#
    .SYNOPSIS
    Opens Instagram
    #>
    Write-ProfileLog "Opening Instagram..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Meta.Instagram
}

function global:deviantart { 
    <#
    .SYNOPSIS
    Opens DeviantArt
    #>
    Write-ProfileLog "Opening DeviantArt..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Art.DeviantArt
}

function global:artstation { 
    <#
    .SYNOPSIS
    Opens ArtStation
    #>
    Write-ProfileLog "Opening ArtStation..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Art.ArtStation
}

function global:pinterest { 
    <#
    .SYNOPSIS
    Opens Pinterest
    #>
    Write-ProfileLog "Opening Pinterest..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Art.Pinterest
}

function global:twitter { 
    <#
    .SYNOPSIS
    Opens Twitter/X
    #>
    Write-ProfileLog "Opening Twitter/X..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Microblogging.Twitter
}

function global:bsky { 
    <#
    .SYNOPSIS
    Opens Bluesky
    #>
    Write-ProfileLog "Opening Bluesky..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Microblogging.Bluesky
}

function global:tumblr { 
    <#
    .SYNOPSIS
    Opens Tumblr
    #>
    Write-ProfileLog "Opening Tumblr..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Microblogging.Tumblr
}

function global:youtube { 
    <#
    .SYNOPSIS
    Opens YouTube
    #>
    Write-ProfileLog "Opening YouTube..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Video.YouTube
}

function global:tiktok { 
    <#
    .SYNOPSIS
    Opens TikTok
    #>
    Write-ProfileLog "Opening TikTok..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Video.TikTok
}

function global:twitch { 
    <#
    .SYNOPSIS
    Opens Twitch with additional developer information
    #>
    Write-ProfileLog "Opening Twitch..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Video.Twitch
    
    # Display additional Twitch resources
    Write-Host "`nTwitch Developer Resources:" -ForegroundColor Cyan
    Write-Host "• API Reference: https://dev.twitch.tv/docs/api/reference" -ForegroundColor Gray
    Write-Host "• Developer Console: https://dev.twitch.tv/console" -ForegroundColor Gray
    Write-Host "• Following Streamers: https://www.twitch.tv/directory/following" -ForegroundColor Gray
    Write-Host "• Documentation: https://dev.twitch.tv/docs/" -ForegroundColor Gray
}

function global:kick { 
    <#
    .SYNOPSIS
    Opens Kick
    #>
    Write-ProfileLog "Opening Kick..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Video.Kick
}

function global:rumble { 
    <#
    .SYNOPSIS
    Opens Rumble
    #>
    Write-ProfileLog "Opening Rumble..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Video.Rumble
}

function global:linkedin { 
    <#
    .SYNOPSIS
    Opens LinkedIn
    #>
    Write-ProfileLog "Opening LinkedIn..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Professional.LinkedIn
}

function global:reddit { 
    <#
    .SYNOPSIS
    Opens Reddit
    #>
    Write-ProfileLog "Opening Reddit..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Professional.Reddit
}

function global:discord { 
    <#
    .SYNOPSIS
    Opens Discord
    #>
    Write-ProfileLog "Opening Discord..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Communication.Discord
}

function global:spotify { 
    <#
    .SYNOPSIS
    Opens Spotify and Spotify API documentation
    #>
    Write-ProfileLog "Opening Spotify with API documentation..." -Level 'Info'
    Start-Process $script:SocialMediaUrls.Music.Spotify
    Start-Process $script:SocialMediaUrls.Music.SpotifyAPI
}

#endregion Individual Platform Functions

#region Utility Functions

function global:Get-SocialFunctions {
    <#
    .SYNOPSIS
    Displays all available social media functions

    .DESCRIPTION
    Lists all available social media functions organized by category,
    including their descriptions and usage examples.

    .EXAMPLE
    Get-SocialFunctions
    Shows all available social media functions
    #>
    
    Write-Host "`n📱 Available Social Media Functions" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor DarkGray
    
    # Core functions
    Write-Host "`n🌐 Core Functions:" -ForegroundColor Yellow
    Write-Host "• Open-SocialChat [social] - Open all social media services" -ForegroundColor Gray
    Write-Host "• Open-SocialChat -Category <category> - Open specific category" -ForegroundColor Gray
    Write-Host "• Open-SocialChat -ShowProgress - Open with progress bar" -ForegroundColor Gray
    Write-Host "• Get-SocialFunctions [listsocial] - Show this help" -ForegroundColor Gray
    
    # Meta platforms
    Write-Host "`n📘 Meta Platforms:" -ForegroundColor Yellow
    Write-Host "• facebook - Open Facebook" -ForegroundColor Gray
    Write-Host "• threads - Open Threads" -ForegroundColor Gray
    Write-Host "• instagram - Open Instagram" -ForegroundColor Gray
    
    # Art platforms
    Write-Host "`n🎨 Art Platforms:" -ForegroundColor Yellow
    Write-Host "• deviantart - Open DeviantArt" -ForegroundColor Gray
    Write-Host "• artstation - Open ArtStation" -ForegroundColor Gray
    Write-Host "• pinterest - Open Pinterest" -ForegroundColor Gray
    
    # Microblogging platforms
    Write-Host "`n🐦 Microblogging Platforms:" -ForegroundColor Yellow
    Write-Host "• twitter - Open Twitter/X" -ForegroundColor Gray
    Write-Host "• bsky - Open Bluesky" -ForegroundColor Gray
    Write-Host "• tumblr - Open Tumblr" -ForegroundColor Gray
    
    # Video platforms
    Write-Host "`n📹 Video Platforms:" -ForegroundColor Yellow
    Write-Host "• youtube - Open YouTube" -ForegroundColor Gray
    Write-Host "• tiktok - Open TikTok" -ForegroundColor Gray
    Write-Host "• twitch - Open Twitch (with dev resources)" -ForegroundColor Gray
    Write-Host "• kick - Open Kick" -ForegroundColor Gray
    Write-Host "• rumble - Open Rumble" -ForegroundColor Gray
    
    # Professional platforms
    Write-Host "`n💼 Professional Platforms:" -ForegroundColor Yellow
    Write-Host "• linkedin - Open LinkedIn" -ForegroundColor Gray
    Write-Host "• reddit - Open Reddit" -ForegroundColor Gray
    
    # Communication platforms
    Write-Host "`n💬 Communication Platforms:" -ForegroundColor Yellow
    Write-Host "• discord - Open Discord" -ForegroundColor Gray
    
    # Music platforms
    Write-Host "`n🎵 Music Platforms:" -ForegroundColor Yellow
    Write-Host "• spotify - Open Spotify (with API docs)" -ForegroundColor Gray
    
    Write-Host "`n💡 Usage Examples:" -ForegroundColor Cyan
    Write-Host "• social - Open all platforms" -ForegroundColor Gray
    Write-Host "• Open-SocialChat -Category Video - Open only video platforms" -ForegroundColor Gray
    Write-Host "• twitter - Open Twitter/X" -ForegroundColor Gray
    Write-Host "• twitch - Open Twitch with developer resources" -ForegroundColor Gray
}

function global:Get-SocialCategories {
    <#
    .SYNOPSIS
    Displays available social media categories

    .DESCRIPTION
    Shows all available categories for the Open-SocialChat function
    #>
    
    Write-Host "`n📂 Available Social Media Categories:" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor DarkGray
    
    $script:SocialMediaUrls.Keys | ForEach-Object {
        $category = $_
        $count = $script:SocialMediaUrls[$category].Count
        Write-Host "• $category ($count platforms)" -ForegroundColor Yellow
        $script:SocialMediaUrls[$category].Keys | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n💡 Usage: Open-SocialChat -Category <category>" -ForegroundColor Cyan
}

#endregion Utility Functions

#region Aliases and Initialization

# Create aliases for easier access
$aliases = @{
    'social'     = 'Open-SocialChat'
    'listsocial' = 'Get-SocialFunctions'
    'socialcats' = 'Get-SocialCategories'
}

foreach ($alias in $aliases.GetEnumerator()) {
    if (-not (Get-Alias -Name $alias.Key -ErrorAction SilentlyContinue)) {
        New-Alias -Name $alias.Key -Value $alias.Value -Scope Global -Force
    }
}

#endregion Aliases and Initialization

Write-ProfileLog "Social Media Functions loaded successfully!" -Level 'Success'
Write-ProfileLog "Use 'Get-SocialFunctions' or 'listsocial' to see all available functions" -Level 'Info'
Write-ProfileLog "Use 'Open-SocialChat' or 'social' to open all social media platforms" -Level 'Info'
