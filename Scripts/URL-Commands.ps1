

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
function winrun { Start-Process "https://win.run/" }
#region AI
function llm { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "LLM"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI/LLM sites" 
    } else {
        Write-Warning "No URLs found for AI/LLM category"
    }
}

function Open-AiPKGsearch { 
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

function Open-AiArt { 
    $urls = Get-UrlCollection -Category "AI" -Subcategory "AiArt"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI art sites" 
    }
}

function Open-AiAzure {
    $urls = Get-UrlCollection -Category "AI" -Subcategory "AiAzure"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening AI Azure sites" 
    }
}   

#endregion AI
#region Google
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
function Open-GoogleCommunication { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Communication"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google communication tools" 
    } else {
        Write-Warning "No URLs found for Google communication category"
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
function Open-GoogleTools { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Tools"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google tools" 
    } else {
        Write-Warning "No URLs found for Google tools category"
    }
}
function Open-Business { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Business"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google business tools" 
    } else {
        Write-Warning "No URLs found for Google business category"
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

function Open-GoogleBlogs { 
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Blogs"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google blogs" 
    } else {
        Write-Warning "No URLs found for Google blogs category"
    }
}
function Open-GoogleCloud {
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Cloud"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google cloud services"
    } else {
        Write-Warning "No URLs found for Google cloud category"
    }
}
function Open-GoogleOther {
    $urls = Get-UrlCollection -Category "Google" -Subcategory "Other"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening Google other services"
    } else {
        Write-Warning "No URLs found for Google other category"
    }
}  
#endregion Google
#region Development
function Open-DevDocs { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Documentation"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer documentation" 
    } else {
        Write-Warning "No URLs found for Development documentation category"
    }
}

function Open-DevGit { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Git"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer git sites" 
    } else {
        Write-Warning "No URLs found for Development git category"
    }
}

function Open-DevWebDev { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "WebDev"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer web development sites" 
    } else {
        Write-Warning "No URLs found for Development web development category"
    }
}

function Open-DevJavascript { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Javascript"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer javascript sites" 
    } else {
        Write-Warning "No URLs found for Development javascript category"
    }
}

function Open-DevPython { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Python"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer python sites" 
    } else {
        Write-Warning "No URLs found for Development python category"
    }
}

function Open-DevCss { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Css"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer css sites" 
    } else {
        Write-Warning "No URLs found for Development css category"
    }
}


function Open-DevPackageManagers { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "PackageManagers"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer package managers" 
    } else {
        Write-Warning "No URLs found for Development package managers category"
    }
}


function Open-DevCloudSites { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "CloudSites"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer cloud sites" 
    } else {
        Write-Warning "No URLs found for Development cloud sites category"
    }
}   

function Open-DevCloudStorage { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "CloudStorage"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer cloud storage" 
    } else {    
        Write-Warning "No URLs found for Development cloud storage category"
    }
}   

function Open-DevMacro { 
    $urls = Get-UrlCollection -Category "Development" -Subcategory "Macro"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening developer macro sites" 
    } else {    
        Write-Warning "No URLs found for Development macro category"
    }
}      
#endregion Development
#region Finance & Investing
function Open-StockSites { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "StockSites"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing stock sites" 
    } else {    
        Write-Warning "No URLs found for Finance and investing stock sites category"
    }
}   

function Open-Trading { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Trading"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing trading sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing trading category"
    }
}   
function Open-StockTickers { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "StockTickers"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing stock tickers" 
    } else {        
        Write-Warning "No URLs found for Finance and investing stock tickers category"
    }
}     
function Open-Forex { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Forex"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing forex sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing forex category"
    }
}      
function Open-Crypto { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Crypto"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing crypto sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing crypto category"
    }
}
function Open-CryptoNews { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "CryptoNews"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing crypto news" 
    } else {        
        Write-Warning "No URLs found for Finance and investing crypto news category"
    }
}  
function Open-Banking { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Banking"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing banking sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing banking category"
    }
}
function Open-Wallets { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Wallets"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing wallets" 
    } else {        
        Write-Warning "No URLs found for Finance and investing wallets category"
    }
}
function Open-CreditCards { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "CreditCards"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing credit cards" 
    } else {        
        Write-Warning "No URLs found for Finance and investing credit cards category"
    }
}
function Open-RealEstate { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "RealEstate"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing real estate sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing real estate category"
    }
}
function Open-Insurance { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Insurance"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing insurance sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing insurance category"
    }
}
function Open-Retirement { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "Retirement"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing retirement sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing retirement category"
    }
}
#endregion Finance & Investing
#region News & Media
function Open-NewsSites { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "NewsSites"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing news sites" 
    } else {        
        Write-Warning "No URLs found for Finance and investing news sites category"
    }
}   
function Open-TechNews { 
    $urls = Get-UrlCollection -Category "Finance" -Subcategory "TechNews"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening finance and investing tech news" 
    } else {        
        Write-Warning "No URLs found for Finance and investing tech news category"
    }
}
#endregion News & Media
#region Art & Design
function Open-Art { 
    $urls = Get-UrlCollection -Category "Art" -Subcategory "Art"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening art and design sites" 
    } else {        
        Write-Warning "No URLs found for Art and design category"
    }
}
function Open-ArtReff { 
    $urls = Get-UrlCollection -Category "Art" -Subcategory "ArtReff"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening art and design sites" 
    } else {        
        Write-Warning "No URLs found for Art and design category"
    }
}   
#endregion Art & Design
#region Social Media
function Open-Social { 
    $urls = Get-UrlCollection -Category "Social" -Subcategory "Social"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening social media sites" 
    } else {        
        Write-Warning "No URLs found for Social media category"
    }
}
function Open-SocialProfessional { 
    $urls = Get-UrlCollection -Category "Social" -Subcategory "Professional"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening social media professional sites" 
    } else {        
        Write-Warning "No URLs found for Social media professional category"
    }
}
function Open-SocialPersonal { 
    $urls = Get-UrlCollection -Category "Social" -Subcategory "Personal"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening social media personal sites" 
    } else {        
        Write-Warning "No URLs found for Social media personal category"
    }
}
function Open-SocialContent { 
    $urls = Get-UrlCollection -Category "Social" -Subcategory "Content"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening social media content sites" 
    } else {        
        Write-Warning "No URLs found for Social media content category"
    }   
}
function Open-SocialCommunity { 
    $urls = Get-UrlCollection -Category "Social" -Subcategory "Community"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening social media community sites" 
    } else {        
        Write-Warning "No URLs found for Social media community category"
    }
}
#endregion Social Media
#region Learning
function Open-Learning { 
    $urls = Get-UrlCollection -Category "Learning" -Subcategory "Learning"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening learning sites" 
    } else {        
        Write-Warning "No URLs found for Learning category"
    }
}
function Open-CloudStorage {
    $urls = Get-UrlCollection -Category "Cloud" -Subcategory "CloudStorage"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening cloud storage services"
    } else {
        Write-Warning "No URLs found for cloud storage category"
    }
}   
#endregion Learning
#region Utilities
function Open-Utilities { 
    $urls = Get-UrlCollection -Category "Utilities" -Subcategory "Utilities"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening utilities sites" 
    } else {        
        Write-Warning "No URLs found for Utilities category"
    }
}
function Open-UtilitiesDrawing { 
    $urls = Get-UrlCollection -Category "Utilities" -Subcategory "Drawing"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening utilities drawing sites" 
    } else {        
        Write-Warning "No URLs found for Utilities drawing category"
    }
}
function Open-UtilitiesLoans { 
    $urls = Get-UrlCollection -Category "Utilities" -Subcategory "Loans"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening utilities loans sites" 
    } else {        
        Write-Warning "No URLs found for Utilities loans category"
    }
}
function Open-UtilitiesEnergy { 
    $urls = Get-UrlCollection -Category "Utilities" -Subcategory "Energy"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening utilities energy sites" 
    } else {        
        Write-Warning "No URLs found for Utilities energy category"
    }
}
function Open-UtilitiesOther { 
    $urls = Get-UrlCollection -Category "Utilities" -Subcategory "Other"
    if ($urls) {
        Open-Urls -Urls $urls -Message "Opening utilities other sites" 
    } else {        
        Write-Warning "No URLs found for Utilities other category"
    }
}

#endregion Utilities

    # Initialize URL collections from config with proper categorization
$UrlCollections = @{}
foreach ($category in $Config.UrlCollections.Keys) {
    $UrlCollections[$category] = @{}
    foreach ($subcategory in $Config.UrlCollections[$category].Keys) {
        $UrlCollections[$category][$subcategory] = $Config.UrlCollections[$category][$subcategory]
    }
}




# Set URL aliases
Set-Alias -Name 'ai-search' -Value 'Open-AiSearch'
Set-Alias -Name 'google-core' -Value 'Open-GoogleCore'
Set-Alias -Name 'google-productivity' -Value 'Open-GoogleProductivity'
Set-Alias -Name 'google-media' -Value 'Open-GoogleMedia' 