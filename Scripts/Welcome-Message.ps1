# Initialize the start time before any operations
$startTime = Get-Date

# Load Profile Commands script
$profileCommandsPath = Join-Path $PSScriptRoot "Profile-Commands.ps1"
if (Test-Path $profileCommandsPath) {
    . $profileCommandsPath
} else {
    Write-Warning "Profile Commands script not found at: $profileCommandsPath"
}

# Cache configuration
$script:CachePath = Join-Path $env:TEMP "PowerShellWelcome"
$script:TipsCachePath = Join-Path $script:CachePath "tips.json"
$script:WeatherCachePath = Join-Path $script:CachePath "weather.json"
$script:QuotesCachePath = Join-Path $script:CachePath "quotes.json"
$script:CacheExpiryHours = 4

function Initialize-WelcomeCache {
    if (-not (Test-Path $script:CachePath)) {
        try {
            New-Item -ItemType Directory -Path $script:CachePath -Force -ErrorAction Stop | Out-Null
            Write-Verbose "Cache directory created at: $script:CachePath"
        } catch {
            Write-Warning "Failed to create cache directory: $_"
        }
    }
}

function Get-CachedData {
    param (
        [string]$Path,
        [scriptblock]$FetchData,
        [int]$LocalExpiryHours = $script:CacheExpiryHours
    )
    
    try {
        if (Test-Path $Path) {
            $cacheData = Get-Content $Path -Raw | ConvertFrom-Json
            $cacheAge = (Get-Date) - ([DateTime]::ParseExact($cacheData.timestamp, "o", [System.Globalization.CultureInfo]::InvariantCulture))
            
            if ($cacheAge.TotalHours -lt $LocalExpiryHours) {
                Write-Verbose "Using cached data from: $Path (Age: $($cacheAge.TotalHours) hours)"
                return $cacheData.data
            }
            Write-Verbose "Cache expired for: $Path (Age: $($cacheAge.TotalHours) hours)"
        }
    } catch {
        Write-Verbose "Failed to read cache data: $_"
    }
    
    try {
        Write-Verbose "Fetching fresh data for: $Path"
        $newData = & $FetchData
        
        if ($null -ne $newData) {
            $cacheObject = @{
                timestamp = (Get-Date).ToString("o")
                data = $newData
            }
            
            $cacheObject | ConvertTo-Json | Set-Content $Path -Force
            Write-Verbose "Updated cache at: $Path"
        }
        
        return $newData
    } catch {
        Write-Verbose "Failed to fetch or cache data: $_"
        return $null
    }
}

function Get-WeatherInfo {
    try {
        $weatherRequest = @{
            Uri = "https://wttr.in/?format=%l:+%C+%t"
            TimeoutSec = 3  # Reduced timeout for better performance
            UserAgent = "PowerShell/$($PSVersionTable.PSVersion) WelcomeScript/1.1"
        }
        $result = Invoke-RestMethod @weatherRequest
        return $result.Trim()  # Trim any whitespace
    } catch {
        Write-Verbose "Weather fetch failed: $_"
        return $null
    }
}

function Get-RandomPowerShellTip {
    try {
        $tips = Get-CachedData -Path $script:TipsCachePath -FetchData {
            $redditRequest = @{
                Uri = "https://www.reddit.com/r/PowerShell/search.json?q=flair%3ATip%20OR%20flair%3ATutorial&restrict_sr=1&sort=top&limit=50"
                TimeoutSec = 3  # Reduced timeout
                UserAgent = "PowerShell/$($PSVersionTable.PSVersion) TipFetcher/1.1"
            }
            
            $response = Invoke-RestMethod @redditRequest
            return $response.data.children.data.title
        }
        
        if ($tips -and $tips.Count -gt 0) {
            return "Reddit Tip: $($tips | Get-Random)"
        }
    } catch {
        Write-Verbose "Tip fetch failed: $_"
    }
    
    # Expanded fallback tips
    $localTips = @(
        "Use 'Get-Command -Module ModuleName' to explore module commands",
        "PSReadLine's PredictionSource helps with command completion",
        "Press F7 to see command history in a popup window",
        "Use Tab completion with parameters: -Para<tab>",
        "Pipe any command to Get-Member to explore its properties",
        "Use Select-Object -First to limit output: Get-Process | Select-Object -First 5",
        "Try Out-GridView to view command output in a filterable GUI",
        "Use ConvertTo-Json | Set-Content file.json to save objects as JSON",
        "Quickly check types with 'obj.GetType()' or 'obj | Get-Member'",
        "Use Format-List (*) to see all object properties: Get-Process explorer | Format-List *"
    )
    return "PowerShell Tip: $($localTips | Get-Random)"
}

function Get-RandomQuote {
    try {
        $quotes = Get-CachedData -Path $script:QuotesCachePath -FetchData {
            $quoteRequest = @{
                Uri = "https://api.quotable.io/quotes/random?limit=5"
                TimeoutSec = 3
                UserAgent = "PowerShell/$($PSVersionTable.PSVersion) QuoteFetcher/1.0"
            }
            
            $response = Invoke-RestMethod @quoteRequest
            return $response | ForEach-Object { 
                @{
                    content = $_.content
                    author = $_.author
                }
            }
        }
        
        if ($quotes -and $quotes.Count -gt 0) {
            $quote = $quotes | Get-Random
            return """$($quote.content)"" — $($quote.author)"
        }
    } catch {
        Write-Verbose "Quote fetch failed: $_"
    }
    
    # Fallback quotes
    $localQuotes = @(
        @{ content = "The best way to predict the future is to invent it."; author = "Alan Kay" },
        @{ content = "Talk is cheap. Show me the code."; author = "Linus Torvalds" },
        @{ content = "Simplicity is the ultimate sophistication."; author = "Leonardo da Vinci" },
        @{ content = "Any sufficiently advanced technology is indistinguishable from magic."; author = "Arthur C. Clarke" },
        @{ content = "The most powerful tool we have as developers is automation."; author = "Scott Hanselman" }
    )
    $quote = $localQuotes | Get-Random
    return """$($quote.content)"" — $($quote.author)"
}

function Get-SystemMetrics {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop
        $computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $process = Get-Process -Id $PID -ErrorAction Stop
        $startTime = $process.StartTime
        
        # Try to get more precise CPU load
        try {
            $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
        } catch {
            $cpuLoad = $null
            Write-Verbose "Failed to get CPU counter: $_"
        }
        
        # Current user and domain
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $userInfo = "$($currentUser.Name)"
        
        return @{
            ComputerName = $computerSystem.Name
            OS = "$($os.Caption) $($os.Version)"
            CPU = @{
                Name = $cpu.Name
                Load = if ($null -ne $cpuLoad) { [math]::Round($cpuLoad, 1) } else { "N/A" }
                Cores = $cpu.NumberOfCores
                LogicalProcessors = $cpu.NumberOfLogicalProcessors
            }
            Memory = @{
                Total = [math]::Round($computerSystem.TotalPhysicalMemory/1GB, 2)
                Usage = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
                Free = [math]::Round($os.FreePhysicalMemory/1MB, 2)
            }
            Disk = @{
                FreeSpace = [math]::Round($disk.FreeSpace/1GB, 2)
                TotalSpace = [math]::Round($disk.Size/1GB, 2)
                Usage = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size * 100), 1)
            }
            PowerShell = $PSVersionTable.PSVersion.ToString()
            User = $userInfo
            SessionDuration = if ($startTime) { 
                [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1) 
            } else { 
                "N/A" 
            }
        }
    } catch {
        Write-Warning "Failed to gather system metrics: $_"
        return $null
    }
}

function Show-ProgressBar {
    param (
        [int]$Percent,
        [int]$Length = 20,
        [string]$CompleteChar = "█",
        [string]$IncompleteChar = "░",
        [string]$Label = "Progress"
    )
    
    $completed = [math]::Round($Length * ($Percent / 100))
    $incomplete = $Length - $completed
    
    # Fixed the colon issue by using double quotes around the entire string
    # and using the backtick to escape the colon
    $bar = "$Label`: ["
    $bar += $CompleteChar * $completed
    $bar += $IncompleteChar * $incomplete
    $bar += "] $Percent%"
    
    return $bar
}

function Show-Welcome {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$ShowCommands,
        
        [Parameter(Mandatory=$false)]
        [switch]$ShowTips,
        
        [Parameter(Mandatory=$false)]
        [switch]$ShowQuote,
        
        [Parameter(Mandatory=$false)]
        [string]$CustomMessage,
        
        [Parameter(Mandatory=$false)]
        [switch]$ShowSystemInfo,
        
        [Parameter(Mandatory=$false)]
        [switch]$ShowAnimation,
        
        [int]$DelaySeconds = 1
    )

    $startTime = Get-Date
    $ErrorActionPreference = 'SilentlyContinue'
    
    # Clear the console for a clean start
    
    # Initialize cache
    Initialize-WelcomeCache
    
    # Define the ASCII art logo with a thematic style
    $Logo = @"
    ___                ____  _       _ _        _ 
   |_ _|_ __ ___     |  _ \(_) __ _(_) |_ __ _| |
    | || '_ ` _ \    | | | | |/ _` | | __/ _` | |
    | || | | | | |   | |_| | | (_| | | || (_| | |
   |___|_| |_| |_|   |____/|_|\__, |_|\__\__,_|_|
                                 |___/            
"@

    # Animation for terminal boot sequence
    if ($ShowAnimation) {
        $progressMessages = @(
            "Initializing system...",
            "Loading core modules...",
            "Establishing network connections...",
            "Checking environment variables...",
            "Verifying system integrity..."
        )
        
        foreach ($i in 1..5) {
            $percent = $i * 20
            $progressBar = Show-ProgressBar -Percent $percent -Label $progressMessages[$i-1]
            Write-Host "`r$progressBar" -NoNewline -ForegroundColor Yellow
            Start-Sleep -Milliseconds 200
        }
    }

    # Display theme color
    $ThemeColors = @{
        Primary = "Cyan"
        Secondary = "DarkCyan"
        Accent = "Magenta"
        AccentDark = "DarkMagenta"
        Warning = "Yellow"
        Success = "Green"
    }

    # Display ASCII art and welcome message with proper spacing
    Write-Host "`n$Logo" -ForegroundColor $ThemeColors.Primary
    Write-Host "`nInitializing Digital Environment..." -ForegroundColor $ThemeColors.Primary
    Write-Host "System Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $ThemeColors.Secondary
    
    # Display weather with cyberpunk style
    $weather = Get-WeatherInfo
    if ($weather) {
        Write-Host "`nEnvironmental Conditions:" -ForegroundColor $ThemeColors.Primary
        Write-Host "└─ $weather" -ForegroundColor $ThemeColors.Secondary
    }
    
    # Display custom message
    if ($CustomMessage) {
        Write-Host "`nUser Protocol:" -ForegroundColor Magenta
        Write-Host "└─ $CustomMessage" -ForegroundColor DarkMagenta
    }
    
    # Show available commands                         ----------Profile-Commands.ps1------------
    if ($ShowCommands) {
        Write-Host "`nLoading Command Matrix..." -ForegroundColor Cyan
        Start-Sleep -Seconds $DelaySeconds
        Show-ProfileCommands -Detailed
    }
    Get-RandomPowerShellTip 
    Write-Host "`nSystem Ready. Awaiting Input...`n" -ForegroundColor $TColor
    
    # Register metric
    try {
        Register-ProfileMetric -Name "Welcome-Screen" -StartTime $startTime
    } catch {
        Write-Verbose "Profile metrics registration failed: $_"
    }
}

