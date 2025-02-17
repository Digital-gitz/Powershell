# Define common paths dynamically
$CommonPaths = @{
    Home      = [System.Environment]::GetFolderPath('UserProfile')
    Documents = [System.Environment]::GetFolderPath('MyDocuments')
    Desktop   = [System.Environment]::GetFolderPath('Desktop')
    Downloads = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'Downloads')
    Pictures  = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'Pictures')
    PowerShell = (Join-Path -Path ([System.Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell')
    GitHub    = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'GitHub')
    Scripts   = (Join-Path -Path ([System.Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell\Scripts')  # Add this line
}

# Open current directory in Explorer
function Open-ExplorerHere {
    Start-Process explorer.exe .
}

# Navigate to a predefined location
function goto {
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("home", "root", "dirps", "downloads", "documents", "pictures", "desktop", "github")]
        [string]$location
    )

    if (-not $PSBoundParameters.ContainsKey('location')) {
        Write-Host "Please specify a location. Valid locations are:" -ForegroundColor Yellow
        $CommonPaths.Keys | ForEach-Object { Write-Host " - $_" }
        return
    }

    if (Test-Path $CommonPaths.$location) {
        Set-Location $CommonPaths.$location
        Get-ChildItem
    } else {
        Write-Host "Path not found: $($CommonPaths.$location)" -ForegroundColor Red
    }
}

# Add tab completion for the goto function
Register-ArgumentCompleter -CommandName goto -ParameterName location -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $CommonPaths.Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_) }
}

# Add a custom path to $CommonPaths
function Add-CommonPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $CommonPaths[$Name] = $Path
}

#region URL_glop

# Open all AI chat websites simultaneously
function oAi {
    $aiSites = @(
        "https://chatgpt.com/",
        "https://claude.ai/new",
        "https://gemini.google.com/app?hl=en-GB", 
        "https://chat.deepseek.com/"
        "https://x.com/i/grok"
    )

    foreach ($site in $aiSites) {
        Start-Process $site
    }

    Write-Host "Opened all AI chat websites" -ForegroundColor Green
}

function StabilityAi {
    $StabilityAiSites = @(
    "https://github.com/Stability-AI/stablediffusion"
    )

    foreach ($site in $StabilityAiSites) {
        Start-Process $site
    }

    Write-Host "websites from Stability Ai" -ForegroundColor Green
}

function mysocial {
    $socialSites = @(
        "https://x.com/home",
        "https://www.reddit.com/",
        "https://www.tumblr.com/dashboard", 
        "https://www.facebook.com/"
        "https://www.instagram.com/"
        "https://www.threads.net/"
    )

    foreach ($site in $socialSites) {
        Start-Process $site
    }

    Write-Host "Opened all Social Media websites" -ForegroundColor Green
}

function mybanking {
    $bankingSites = @(

    )

    foreach ($site in $bankingSites) {
        Start-Process $site
    }

    Write-Host "Opened all Accounting and banking websites" -ForegroundColor Green
}




# Export functions (if used as a module)
Export-ModuleMember -Function Open-ExplorerHere, goto, oAi