# Define common paths dynamically
$CommonPaths = @{
    Home      = [System.Environment]::GetFolderPath('UserProfile')
    Documents = [System.Environment]::GetFolderPath('MyDocuments')
    Desktop   = [System.Environment]::GetFolderPath('Desktop')
    Downloads = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'Downloads')
    Pictures  = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'Pictures')
    PowerShell = (Join-Path -Path ([System.Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell')
    GitHub    = (Join-Path -Path ([System.Environment]::GetFolderPath('UserProfile')) -ChildPath 'GitHub')
    Scripts   = (Join-Path -Path ([System.Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell\Scripts')
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

    if ($CommonPaths.ContainsKey($location)) {
        if (Test-Path $CommonPaths.$location) {
            Set-Location $CommonPaths.$location
            Get-ChildItem
        } else {
            Write-Host "Path not found: $($CommonPaths.$location)" -ForegroundColor Red
        }
    } else {
        Write-Host "Location '$location' is not defined in `$CommonPaths." -ForegroundColor Red
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
    if (Test-Path $Path) {
        $CommonPaths[$Name] = $Path
        Write-Host "Path '$Path' added as '$Name'" -ForegroundColor Green
    } else {
        Write-Host "Path '$Path' does not exist. Please provide a valid path." -ForegroundColor Red
    }
}
#region URL_glop
function Open-Urls {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Urls,
        [Parameter(Mandatory = $false)]
        [string]$Message = "Opened all URLs"
    )

    foreach ($url in $Urls) {
        Start-Process $url
    }

    Write-Host $Message -ForegroundColor Green
}

# Example usage:
function oAi {
    $aiSites = @(
        "https://chatgpt.com/",
        "https://claude.ai/new",
        "https://gemini.google.com/app?hl=en-GB", 
        "https://chat.deepseek.com/",
        "https://x.com/i/grok"
    )
    Open-Urls -Urls $aiSites -Message "Opened all AI chat websites"
}

function mysocial {
    $socialSites = @(
        "https://x.com/home",
        "https://www.reddit.com/",
        "https://www.tumblr.com/dashboard", 
        "https://www.facebook.com/",
        "https://www.instagram.com/",
        "https://www.threads.net/"
    )
    Open-Urls -Urls $socialSites -Message "Opened all Social Media websites"
}