Write-Host "Loading Social-Funk.ps1..." -ForegroundColor Green

if (-not (Get-Command -Name Write-Log -ErrorAction SilentlyContinue)) {
    function Write-Log {
        param($Message, $Level = 'Info')
        Write-Host "[Social-Funk.ps1] [$Level] $Message" -ForegroundColor Yellow
    }
}
Write-Log "Defining Open-SocialChat function..." -Level 'Info'

# Define URLs first
$script:OpenSocialUrls = @(
    # meta apps
    "https://www.facebook.com/",
    "https://www.threads.com/",
    "https://www.tumblr.com/",
    # Art Socail media apps
    "https://www.deviantart.com/",
    "https://www.Artstation.com"

    "https://x.com/",
    "https://bsky.app/",    
    "https://www.youtube.com/",
    "https://www.instagram.com/",
    "https://www.reddit.com/",
    "https://www.linkedin.com/",
    "https://www.tiktok.com/",
    "https://www.discord.com/",
    "https://kick.com/",
    "https://www.pinterest.com/",
    "https://www.twitch.tv/",
    "https://rumble.com/"
)

# Define the function in global scope
function global:Open-SocialChat {
    [CmdletBinding()]
    param(
        [switch]$ShowProgress
    )
    
    Write-Host "`n🌐 Opening Social Media Services..." -ForegroundColor Cyan
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
    foreach ($url in $script:OpenSocialUrls) {
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
            $percentComplete = ($completed / $script:OpenSocialUrls.Count) * 100
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
        Write-Host "✨ All social media services opened successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Some URLs failed to open:" -ForegroundColor Yellow
        $failedUrls | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    }
    Write-Host
}

# Create an alias for easier access
if (-not (Get-Alias -Name social -ErrorAction SilentlyContinue)) {
    New-Alias -Name social -Value Open-SocialChat -Scope Global -Force
}

# Individual social media functions
function global:twitch { 
    Write-Host "Opening Twitch..." -ForegroundColor Cyan
    Start-Process "https://www.twitch.tv/"
    Write-Host "Cli api can be found at https://dev.twitch.tv/docs/api/reference  "
    Write-Host "the Developer Console can be found at https://dev.twitch.tv/console"
    Write-Host "followed Streamers can be found at https://www.twitch.tv/directory/following"
    Write-Host "the Docs can be found https://dev.twitch.tv/docs/"
}

function global:twitter { 
    Write-Host "Opening Twitter/X..." -ForegroundColor Cyan
    Start-Process "https://x.com/"
}

function global:facebook { 
    Write-Host "Opening Facebook..." -ForegroundColor Cyan
    Start-Process "https://www.facebook.com/"
}

function global:instagram { 
    Write-Host "Opening Instagram..." -ForegroundColor Cyan
    Start-Process "https://www.instagram.com/"
}

function global:reddit { 
    Write-Host "Opening Reddit..." -ForegroundColor Cyan
    Start-Process "https://www.reddit.com/"
}

function global:youtube { 
    Write-Host "Opening YouTube..." -ForegroundColor Cyan
    Start-Process "https://www.youtube.com/"
}

function global:linkedin { 
    Write-Host "Opening LinkedIn..." -ForegroundColor Cyan
    Start-Process "https://www.linkedin.com/"
}

function global:tiktok { 
    Write-Host "Opening TikTok..." -ForegroundColor Cyan
    Start-Process "https://www.tiktok.com/"
}

function global:discord { 
    Write-Host "Opening Discord..." -ForegroundColor Cyan
    Start-Process "https://www.discord.com/"
}

function global:pinterest { 
    Write-Host "Opening Pinterest..." -ForegroundColor Cyan
    Start-Process "https://www.pinterest.com/"
}

function global:tumblr { 
    Write-Host "Opening Tumblr..." -ForegroundColor Cyan
    Start-Process "https://www.tumblr.com/"
}

function global:rumble { 
    Write-Host "Opening Rumble..." -ForegroundColor Cyan
    Start-Process "https://rumble.com/"
}

function global:deviantart { 
    Write-Host "Opening DeviantArt..." -ForegroundColor Cyan
    Start-Process "https://www.deviantart.com/"
}

function global:threads { 
    Write-Host "Opening Threads..." -ForegroundColor Cyan
    Start-Process "https://www.threads.com/"
}

function global:bsky { 
    Write-Host "Opening Bluesky..." -ForegroundColor Cyan
    Start-Process "https://bsky.app/"
}

function global:kick { 
    Write-Host "Opening Kick..." -ForegroundColor Cyan
    Start-Process "https://kick.com/"
}

function Spot {
    Write-Host "Opening Spotify with api builder"
    Start-Process "https://open.spotify.com/"
    Start-Process "https://developer.spotify.com/documentation/web-api"
    

}



Write-Host "Social-Funk.ps1 loaded successfully!" -ForegroundColor Green
Write-Host "Use 'Open-SocialChat' or 'social' to open all social media URLs" -ForegroundColor Cyan
Write-Host "Use individual commands (twitch, twitter, facebook, etc.) to open specific sites" -ForegroundColor Blue


function global:listsocial {
    Write-Host "`nAvailable Social Media Services:" -ForegroundColor Yellow
    Write-Host "1. Facebook (facebook)" -ForegroundColor Cyan
    Write-Host "2. Threads (threads)" -ForegroundColor Cyan
    Write-Host "3. Tumblr (tumblr)" -ForegroundColor Cyan
    Write-Host "4. DeviantArt (deviantart)" -ForegroundColor Cyan
    Write-Host "5. Twitter/X (twitter)" -ForegroundColor Cyan
    Write-Host "6. Bluesky (bsky)" -ForegroundColor Cyan
    Write-Host "7. YouTube (youtube)" -ForegroundColor Cyan
    Write-Host "8. Instagram (instagram)" -ForegroundColor Cyan
    Write-Host "9. Reddit (reddit)" -ForegroundColor Cyan
    Write-Host "10. LinkedIn (linkedin)" -ForegroundColor Cyan
    Write-Host "11. TikTok (tiktok)" -ForegroundColor Cyan
    Write-Host "12. Discord (discord)" -ForegroundColor Cyan
    Write-Host "13. Kick (kick)" -ForegroundColor Cyan
    Write-Host "14. Pinterest (pinterest)" -ForegroundColor Cyan
    Write-Host "15. Twitch (twitch)" -ForegroundColor Cyan
    Write-Host "16. Rumble (rumble)" -ForegroundColor Cyan
    Write-Host "`nUse the command in parentheses to open the respective service" -ForegroundColor Green
}
