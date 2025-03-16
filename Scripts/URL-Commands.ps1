

function Open-Urls {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$Urls,
        [string]$Message = "Opened URLs",
        [switch]$ShowUrls
    )
    
    # Debug information
    Write-Verbose "URL Collections available: $($UrlCollections.Keys -join ', ')"
    
    # Handle null or empty URLs
    if ($null -eq $Urls -or $Urls.Count -eq 0) {
        Write-Warning "No URLs provided for $Message"
        return
    }
    
    # Filter out invalid URLs and empty strings
    $validUrls = $Urls | Where-Object { 
        $_ -and $_.Trim() -match '^https?://' 
    }
    
    if ($validUrls.Count -eq 0) {
        Write-Warning "No valid URLs found for $Message"
        return
    }
    
    $count = 0
    foreach ($url in $validUrls) {
        try {
            Start-Process $url
            $count++
            if ($ShowUrls) {
                Write-Host "  → $url" -ForegroundColor DarkGray
            }
        } catch {
            Write-Warning "Failed to open URL: $url"
        }
    }
    
    Write-Host "$Message ($count URLs)" -ForegroundColor Green
}

# Helper function to get URLs from collections
function Get-UrlCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [Parameter(Mandatory)]
        [string]$Subcategory
    )
    
    # Debug information
    Write-Verbose "Looking for Category: $Category, Subcategory: $Subcategory"
    Write-Verbose "Available Categories: $($Config.UrlCollections.Keys -join ', ')"
    
    if ($Config.UrlCollections.ContainsKey($Category)) {
        if ($Config.UrlCollections[$Category].ContainsKey($Subcategory)) {
            return $Config.UrlCollections[$Category][$Subcategory]
        }
    }
    return $null
}

# URL opening functions
function gally { Start-Process "https://www.powershellgallery.com/" }
function ythistory { Start-Process "https://www.youtube.com/feed/history" }
function ai { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "LLM"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI/LLM sites" 
    } else {
        Write-Warning "No URLs found for AI/LLM category"
    }
}

function aidev { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "AiPackages"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI development sites" 
    } else {
        Write-Warning "No URLs found for AI development category"
    }
}

function Open-AiSearch { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "AiSearch"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI search engines" 
    } else {
        Write-Warning "No URLs found for AI search category"
    }
}

function Open-DevDocs { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Documentation"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer documentation" 
    } else {
        Write-Warning "No URLs found for Development documentation category"
    }
}

function Open-GoogleCore { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Core"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google core services" 
    } else {
        Write-Warning "No URLs found for Google core category"
    }
}

function Open-GoogleProductivity { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Productivity"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google productivity tools" 
    } else {
        Write-Warning "No URLs found for Google productivity category"
    }
}

function Open-GoogleMedia { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Media"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google media services" 
    } else {
        Write-Warning "No URLs found for Google media category"
    }
}

function Open-GoogleBusiness { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Business"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google business tools" 
    } else {
        Write-Warning "No URLs found for Google business category"
    }
}

# Initialize URL collections from config with proper categorization
$UrlCollections = @{}
foreach ($category in $Config.UrlCollections.Keys) {
    $UrlCollections[$category] = @{}
    foreach ($subcategory in $Config.UrlCollections[$category].Keys) {
        $UrlCollections[$category][$subcategory] = $Config.UrlCollections[$category][$subcategory]
    }
}



# Set URL aliases
Set-Alias -Name 'aisearch' -Value 'Open-AiSearch'
Set-Alias -Name 'google-core' -Value 'Open-GoogleCore'
Set-Alias -Name 'google-productivity' -Value 'Open-GoogleProductivity'
Set-Alias -Name 'google-media' -Value 'Open-GoogleMedia' 