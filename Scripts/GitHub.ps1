# GitHub.ps1
#
# Set a new token
# Set-GitHubToken -Token "ghp_yourTokenHere" -Store

# Create aliases for GitHub functions are at root script.
#Set-Alias -Name ghs -Value Search-GitHubRepos
#Set-Alias -Name ghl -Value Get-GitHubRepoList
# Set-Alias -Name ghmr -Value Get-GitHubRepoView
#Set-Alias -Name ghc -Value Get-GitHubRepoclone
# Get token info
# gh-tokeninfo

# Create a new token in browser
# gh-newtoken

 # GitHub Token Management
function Set-GitHubToken {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Token,
        [switch]$Store
    )
    $env:GH_TOKEN = $Token
    if ($Store) {
        $secureToken = ConvertTo-SecureString $Token -AsPlainText -Force
        New-StoredCredential -Target "GitHub:CLI" -UserName $env:USERNAME -Password $secureToken -Persist LocalComputer
    }
}

Write-Output("Github UserScript Uploaded...")

function Open-GitHubRepo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RepoName
    )
    
    $repoUrl = "https://github.com/$RepoName"
    try {
        Start-Process $repoUrl
        Write-Host "Opened GitHub repository: $RepoName" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to open GitHub repository: $_"
    }
}

function Update-AllRepos {
    $currentLocation = Get-Location
    Get-ChildItem -Directory | ForEach-Object {
        Set-Location $_
        if (Test-Path .git) {
            Write-Host "Updating $($_.Name)..." -ForegroundColor Cyan
            git pull
        }
        Set-Location $currentLocation
    }
}

function New-GitHubRepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$RepoName,
        [switch]$Private,
        [string]$Description
    )
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it first."
        return
    }
    
    if (-not $RepoName) {
        $RepoName = Read-Host -Prompt "Enter the repository name"
    }
    
    if ([string]::IsNullOrWhiteSpace($RepoName)) {
        Write-Error "Repository name cannot be empty."
        return
    }
    
    $visibility = if ($Private) { "--private" } else { "--public" }
    $descParam = if ($Description) { "--description `"$Description`"" } else { "" }
    
    try {
        $result = gh repo create $RepoName $visibility $descParam -y
        Write-Host "Repository '$RepoName' created successfully." -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "Failed to create repository: $_"
    }
}

# GitHub helper functions
function Search-GitHubRepos { 
    [CmdletBinding()]
    param([string]$Query)
    gh search repos $Query 
}

function Get-GitHubRepoList { 
    [CmdletBinding()]
    param([switch]$All)
    if ($All) {
        gh repo list --limit 1000
    } else {
        gh repo list
    }
}

function Get-GitHubRepoView { 
    [CmdletBinding()]
    param([string]$Repo)
    gh repo view $Repo 
}

function gitstatus {
    git status -s
}

function Get-GitHubRepoclone {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RepoName
    )
}
# function Get-GitHubRepoclone {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory=$true)]
#         [string]$RepoName
#     )
    
   #  $repoUrl = "

