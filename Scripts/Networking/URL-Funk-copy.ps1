Write-Host "Loading URL-Funk.ps1..." -ForegroundColor Green

if (-not (Get-Command -Name Write-Log -ErrorAction SilentlyContinue)) {
    function Write-Log {
        param($Message, $Level = 'Info')
        Write-Host "[URL-Funk.ps1] [$Level] $Message" -ForegroundColor Yellow
    }
}

Write-Log "Defining Open-LLMChat function..." -Level 'Info'

$script:functionDefined = $false

# Define URLs first
$script:OpenLLMUrls = @(
    "https://chat.openai.com/",
    "https://claude.ai/new",
    "https://x.com/i/grok",
    "https://you.com/",
    "https://pi.ai/",
    "https://chatgpt.com/",
    "https://chat.openai.com/",
    "https://claude.ai/new",
    "https://gemini.google.com/app?hl=en-GB",
    "https://chat.deepseek.com/"
)

# Define the function in global scope
function global:Open-LLMChat {
    [CmdletBinding()]
    param(
        [switch]$ShowProgress
    )
    
    Write-Host "`n🌐 Opening LLM Chat Services..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray

    $total = $script:OpenLLMUrls.Count
    $current = 0
    $failedUrls = @()

    foreach ($url in $script:OpenLLMUrls) {
        $current++
        $cleanUrl = $url -replace '^https?://(www\.)?', '' -replace '\.(com|org|net|io|ai|dev|cloud|app|co|me|us|uk|ru|de|fr|jp|cn|in|br|au|ca|nz|za|kr|nl|pl|it|es|se|dk|no|fi|ie|at|ch|be|pt|gr|cz|hu|ro|sk|ua|il|tr|ae|sa|sg|my|th|vn|id|ph|mx|ar|cl|pe|co|za|eg|ma|ng|ke|za).*$', ''
        
        if ($ShowProgress) {
            $percentComplete = ($current / $total) * 100
            Write-Progress -Activity "Opening LLM Services" -Status "$cleanUrl" -PercentComplete $percentComplete
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
        Write-Progress -Activity "Opening LLM Services" -Completed
    }

    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    if ($failedUrls.Count -eq 0) {
        Write-Host "✨ All LLM services opened successfully!" -ForegroundColor Green
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
    Write-Log "Function Open-LLMChat defined successfully" -Level 'Success'
}
else {
    Write-Log "Function Open-LLMChat was already defined" -Level 'Info'
}

# Create an alias for easier access
if (-not (Get-Alias -Name llm -ErrorAction SilentlyContinue)) {
    New-Alias -Name llm -Value Open-LLMChat -Scope Global -Force
}

function chat-gpt { Start-Process "https://chatgpt.com/" }
function claude { Start-Process "https://claude.ai/new" }
function gemini { Start-Process "https://gemini.google.com/app?hl=en-GB" }
function deepseek { Start-Process "https://chat.deepseek.com/" }
function grok { Start-Process "https://x.com/i/grok" }
function you { Start-Process "https://you.com/" }
function pi { Start-Process "https://pi.ai/" }

Write-Host "URL-Funk.ps1 loaded successfully!" -ForegroundColor Green
Write-Host "Use 'Open-LLMChat' or 'llm' to open all LLM chat URLs" -ForegroundColor Cyan
Write-Host "Use 'chat-gpt' to open ChatGPT" -ForegroundColor Cyan
Write-Host "Use 'claude' to open Claude" -ForegroundColor Cyan
Write-Host "Use 'gemini' to open Gemini" -ForegroundColor Cyan
Write-Host "Use 'deepseek' to open DeepSeek" -ForegroundColor Cyan
Write-Host "Use 'grok' to open Grok" -ForegroundColor Cyan
Write-Host "Use 'you' to open You" -ForegroundColor Cyan
Write-Host "Use 'pi' to open Pi" -ForegroundColor Cyan
