Write-Host "Loading Shopping-Funk.ps1..." -ForegroundColor Green

if (-not (Get-Command -Name Write-Log -ErrorAction SilentlyContinue)) {
    function Write-Log {
        param($Message, $Level = 'Info')
        Write-Host "[Shopping-Funk.ps1] [$Level] $Message" -ForegroundColor Yellow
    }
}

Write-Log "Defining Open-Shopping function..." -Level 'Info'

$script:functionDefined = $false

# Define URLs first
$script:OpenShoppingUrls = @(
    "https://www.amazon.com/",
    "https://www.walmart.com/",
    "https://www.target.com/",
    "https://www.bestbuy.com/",
    "https://www.costco.com/",
    "https://www.publix.com/",
    "https://www.aldi.com/",
    "https://www.sobeys.com/",
    "https://www.shoprite.com/",
    "https://www.safeway.com/",
    "https://www.wholefoods.com/",
    "https://www.traderjoes.com/",
    "https://www.publix.com/",
    "https://www.sobeys.com/",
    "https://www.etsy.com/",
    "https://www.ebay.com/"
    
)

# Define the function in global scope
function global:Open-Shopping {
    [CmdletBinding()]
    param(
        [switch]$ShowProgress
    )
    
    Write-Host "`n🌐 Opening Shopping Services..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray

    $total = $script:OpenShoppingUrls.Count
    $current = 0
    $failedUrls = @()

    foreach ($url in $script:OpenShoppingUrls) {
        $current++
        $cleanUrl = $url -replace '^https?://(www\.)?', '' -replace '\.(com|org|net|io|ai|dev|cloud|app|co|me|us|uk|ru|de|fr|jp|cn|in|br|au|ca|nz|za|kr|nl|pl|it|es|se|dk|no|fi|ie|at|ch|be|pt|gr|cz|hu|ro|sk|ua|il|tr|ae|sa|sg|my|th|vn|id|ph|mx|ar|cl|pe|co|za|eg|ma|ng|ke|za).*$', ''
        
        if ($ShowProgress) {
            $percentComplete = ($current / $total) * 100
            Write-Progress -Activity "Opening Shopping Services" -Status "$cleanUrl" -PercentComplete $percentComplete
        }

        try {
            Start-Process $url
            Write-Host "✓ $cleanUrl" -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        }
        catch {
            Write-Host "✗ Failed to open $cleanUrl" -ForegroundColor Red
            $failedUrls += $url
        }
    }

    if ($ShowProgress) {
        Write-Progress -Activity "Opening Shopping Services" -Completed
    }

    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    if ($failedUrls.Count -eq 0) {
        Write-Host "✨ All Shopping services opened successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Some URLs failed to open:" -ForegroundColor Yellow
        $failedUrls | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    }
    Write-Host
}

if ($script:functionDefined) {
    Write-Log "Function Open-Shopping defined successfully" -Level 'Success'
}
else {
    Write-Log "Function Open-Shopping was already defined" -Level 'Info'
}

# Create an alias for easier access
if (-not (Get-Alias -Name llm -ErrorAction SilentlyContinue)) {
    New-Alias -Name llm -Value Open-Shopping -Scope Global -Force
}

function global:amazon { Start-Process "https://www.amazon.com/" }
function global:walmart { Start-Process "https://www.walmart.com/" }
function global:target { Start-Process "https://www.target.com/" }
function global:bestbuy { Start-Process "https://www.bestbuy.com/" }
function global:costco { Start-Process "https://www.costco.com/" }
function global:publix { Start-Process "https://www.publix.com/" }
function global:aldi { Start-Process "https://www.aldi.com/" }

Write-Host "URL-Funk.ps1 loaded successfully!" -ForegroundColor Green
Write-Host "Use 'Open-Shopping' or 'shopping' to open all Shopping URLs" -ForegroundColor Cyan
Write-Host "Use 'amazon' to open Amazon" -ForegroundColor Magenta
Write-Host "Use 'walmart' to open Walmart" -ForegroundColor Magenta
Write-Host "Use 'target' to open Target" -ForegroundColor Magenta
Write-Host "Use 'bestbuy' to open Best Buy" -ForegroundColor Magenta

