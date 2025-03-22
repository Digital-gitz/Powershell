# Initialize the start time before any operations
$startTime = Get-Date -AsUTC -Format "yyyy-MM-dd HH:mm:ss.ffffff"

#region Script Loading Functions
# $scriptCache = @{}
# $scriptDependencies = @{}
$loadedScripts = @{}
$scriptsRoot = Split-Path -Parent $PSScriptRoot
$functionExecutionLog = @{}
$functionStartTimes = @{}

# Function to track function execution
function Register-FunctionExecution {
    param(
        [string]$FunctionName,
        [string]$ScriptPath,
        [string]$Category
    )
    
    $functionKey = "$Category\$FunctionName"
    if (-not $functionExecutionLog.ContainsKey($functionKey)) {
        $functionExecutionLog[$functionKey] = @{
            Name            = $FunctionName
            Script          = $ScriptPath
            Category        = $Category
            ExecutionCount  = 0
            LastExecution   = $null
            AverageDuration = 0
            TotalDuration   = 0
            StartTime       = $null
            EndTime         = $null
        }
    }
}

# Function to start timing a function
function Start-FunctionTimer {
    param([string]$FunctionName)
    
    $functionStartTimes[$FunctionName] = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    if ($functionExecutionLog.ContainsKey($FunctionName)) {
        $functionExecutionLog[$FunctionName].StartTime = Get-Date
    }
}

# Function to end timing a function
function Stop-FunctionTimer {
    param([string]$FunctionName)
    
    if ($functionStartTimes.ContainsKey($FunctionName)) {
        $endTime = Get-Date
        $startTime = [DateTime]::ParseExact($functionStartTimes[$FunctionName], "yyyy-MM-dd HH:mm:ss.fff", [System.Globalization.CultureInfo]::InvariantCulture)
        $duration = $endTime - $startTime
        
        if ($functionExecutionLog.ContainsKey($FunctionName)) {
            $stats = $functionExecutionLog[$FunctionName]
            $stats.EndTime = $endTime
            $stats.ExecutionCount++
            $stats.LastExecution = $endTime
            $stats.TotalDuration += $duration.TotalMilliseconds
            $stats.AverageDuration = $stats.TotalDuration / $stats.ExecutionCount
        }
        
        $functionStartTimes.Remove($FunctionName)
    }
}

function Import-Script {
    param (
        [Parameter(Mandatory)]
        [string]$ScriptPath,
        [string]$Category = "General",
        [switch]$Force,
        [string[]]$Dependencies = @()
    )

    $scriptKey = $ScriptPath.ToLower()
    Start-FunctionTimer -FunctionName "Import-Script"

    # Check if script is already loaded
    if ($loadedScripts.ContainsKey($scriptKey) -and !$Force) {
        Write-Log "Script already loaded: $ScriptPath" -Level 'Debug'
        Stop-FunctionTimer -FunctionName "Import-Script"
        return $true
    }

    try {
        if (-not (Test-Path $ScriptPath)) {
            Write-Log "Script not found: $ScriptPath" -Level 'Warning'
            Stop-FunctionTimer -FunctionName "Import-Script"
            return $false
        }
        # Check if script requires admin privileges
        $scriptContent = Get-Content $ScriptPath -Raw -ErrorAction Stop
        if ($scriptContent -match '#Requires -RunAsAdministrator') {
            $isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            if (-not $isAdmin) {
                Write-Log "Script requires admin privileges. Elevating..." -Level 'Warning'
                $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
                $processStartInfo.FileName = "powershell.exe"
                $processStartInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
                $processStartInfo.UseShellExecute = $true
                $processStartInfo.Verb = "runas"
                
                try {
                    [System.Diagnostics.Process]::Start($processStartInfo)
                    Write-Log "Successfully launched script with admin privileges" -Level 'Success'
                }
                catch {
                    Write-Log "Failed to elevate script: $_" -Level 'Error'
                }
                
                Stop-FunctionTimer -FunctionName "Import-Script"
                return $false
            }
        }

        # Check if this is a module
        $moduleManifestPath = $ScriptPath -replace '\.ps1$', '.psd1'
        if (Test-Path $moduleManifestPath) {
            Write-Log "Loading module: $ScriptPath" -Level 'Debug'
            try {
                Import-Module $moduleManifestPath -Force -ErrorAction Stop
                Write-Log "Successfully loaded module: $ScriptPath" -Level 'Success'
                $loadedScripts[$scriptKey] = $true
                Stop-FunctionTimer -FunctionName "Import-Script"
                return $true
            }
            catch {
                Write-Log "Failed to load module $ScriptPath : $_" -Level 'Error'
                Stop-FunctionTimer -FunctionName "Import-Script"
                return $false
            }
        }

        # Validate script content
        $null = [System.Management.Automation.PSParser]::Tokenize($scriptContent, [ref]$null)
        
        # Load the script in the global scope to ensure functions are available
        . ([scriptblock]::Create(". '$ScriptPath'"))

        # Track functions in the script
        $scriptFunctions = Get-Content $ScriptPath | Select-String -Pattern '^function\s+\w+' | ForEach-Object { $_.Line -replace '^function\s+(\w+).*$', '$1' }
        foreach ($func in $scriptFunctions) {
            Register-FunctionExecution -FunctionName $func -ScriptPath $ScriptPath -Category $Category
        }

        $loadedScripts[$scriptKey] = $true
        Write-Log "Successfully loaded script: $ScriptPath (Category: $Category)" -Level 'Success'
        Stop-FunctionTimer -FunctionName "Import-Script"
        return $true
    }
    catch {
        Write-Log "Error loading script $ScriptPath : $_" -Level 'Error'
        Stop-FunctionTimer -FunctionName "Import-Script"
        return $false
    }
}

function Import-ScriptCategory {
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [string[]]$Scripts,
        [switch]$Parallel
    )

    $categoryTimer = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Log "Loading $Category category scripts..." -Level 'Info'

    if ($Parallel -and (Get-Configuration).Performance.ParallelLoading) {
        $jobs = @()
        foreach ($script in $Scripts) {
            $scriptPath = Join-Path $scriptsRoot $Category $script
            $scriptTimer = [System.Diagnostics.Stopwatch]::StartNew()
            $jobs += Start-Job -ScriptBlock {
                param($path, $cat)
                . $path
            } -ArgumentList $scriptPath, $Category
            Write-Log "Started loading: $script" -Level 'Debug'
        }
        
        foreach ($job in $jobs) {
            Wait-Job $job | Out-Null
            if ($job.State -eq 'Failed') {
                Write-Log "Failed to load script in parallel: $($job.Name)" -Level 'Error'
            }
        }
    }
    else {
        foreach ($script in $Scripts) {
            $scriptPath = Join-Path $scriptsRoot $Category $script
            $scriptTimer = [System.Diagnostics.Stopwatch]::StartNew()
            
            # Check if this is a module
            $moduleManifestPath = $scriptPath -replace '\.(ps1|psm1)$', '.psd1'
            if (Test-Path $moduleManifestPath) {
                Write-Log "Loading module: $script" -Level 'Debug'
                try {
                    Import-Module $moduleManifestPath -Force -ErrorAction Stop
                    $scriptTimer.Stop()
                    Write-Log "Successfully loaded module: $script (${$scriptTimer.ElapsedMilliseconds}ms)" -Level 'Success'
                }
                catch {
                    $scriptTimer.Stop()
                    Write-Log "Failed to load module $script : $_ (${$scriptTimer.ElapsedMilliseconds}ms)" -Level 'Error'
                }
            }
            else {
                $result = Import-Script -ScriptPath $scriptPath -Category $Category
                $scriptTimer.Stop()
                if ($result) {
                    Write-Log "Successfully loaded: $script (${$scriptTimer.ElapsedMilliseconds}ms)" -Level 'Success'
                }
                else {
                    Write-Log "Failed to load: $script (${$scriptTimer.ElapsedMilliseconds}ms)" -Level 'Error'
                }
            }
        }
    }

    $categoryTimer.Stop()
    Write-Log "Finished loading $Category category (${$categoryTimer.ElapsedMilliseconds}ms)" -Level 'Info'
}

# Define script categories and their files with dependencies
$scriptCategories = @{
    Core           = @(
        "Config-Validation.ps1",
        "Module-Management.ps1",
        "Package-Management.ps1",
        "Utility-Functions.ps1",
        "Script-Management.ps1",
        "Profile-Commands.ps1",
        "RunCommands.ps1",
        "ImprovedScriptloading.ps1"
    )
    FileManagement = @(
        "FileManagement.ps1",
        "PNGtoVECTOR.ps1",
        "FetchDownload.ps1",
        "bringVsCodeForeground.ps1"
    )
    Navigation     = @(
        "Navigation.ps1",
        "cd-docs.ps1",
        "cd-downloads.ps1"
    )
    # Networking scripts should be loaded without parallel processing
    Networking     = @(
        "URL-Funk.ps1"
    )
    Development    = @(
        "GitHub.ps1",
        "githubCommands.ps1",
        "Notes-Function.ps1"
    )
    Utility        = @(
        "MathOperations.ps1",
        "Security.ps1",
        "HVAC.ps1",
        "Backup.ps1"
    )
    UI             = @(
        "Initialize-OhMyPosh.ps1",
        "Initialize-PSReadLine.ps1",
        "winfetch-pro.ps1",
        "Welcome-Message.ps1"
    )
    Installation   = @(
        "install_dependencies.ps1",
        "Install-OrUpdateModule.ps1"
    )
}

function Import-AllScripts {
    $totalTimer = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Load Core scripts first as they contain essential functions
    Write-Log "Loading Core scripts first..." -Level 'Info'
    Import-ScriptCategory -Category "Core" -Scripts $scriptCategories["Core"] -Parallel:$false

    # Load Networking scripts next, without parallel processing
    Write-Log "Loading Networking scripts..." -Level 'Info'
    Import-ScriptCategory -Category "Networking" -Scripts $scriptCategories["Networking"] -Parallel:$false

    # Load remaining scripts by category
    foreach ($category in $scriptCategories.Keys | Where-Object { $_ -notin @("Core", "Networking") }) {
        Write-Log "Loading $category scripts..." -Level 'Info'
        
        # Get dependencies for the category
        $deps = @()
        if ((Get-Configuration).Performance.ScriptDependencies -and 
            (Get-Configuration).Performance.ScriptDependencies.ContainsKey($category)) {
            $deps = (Get-Configuration).Performance.ScriptDependencies[$category]
        }
        
        # Load dependencies first
        foreach ($dep in $deps) {
            $depPath = Join-Path $scriptsRoot $dep
            if (Test-Path $depPath) {
                Import-Script -ScriptPath $depPath -Category "Dependency"
            }
            else {
                Write-Log "Dependency not found: $dep" -Level 'Warning'
            }
        }
        
        # Load category scripts
        Import-ScriptCategory -Category $category -Scripts $scriptCategories[$category] -Parallel:(Get-Configuration).Performance.ParallelLoading
    }

    # Load any additional scripts from directories not covered by categories
    $allCategoryDirs = $scriptCategories.Keys
    $additionalDirs = @(
        "Prompt",
        "helpers",
        "Scraping",
        "InstalledScriptInfos"
    ) | Where-Object { $_ -notin $allCategoryDirs }

    foreach ($dir in $additionalDirs) {
        $dirPath = Join-Path $scriptsRoot $dir
        if (Test-Path $dirPath) {
            Write-Log "Loading scripts from $dir directory..." -Level 'Info'
            $dirTimer = [System.Diagnostics.Stopwatch]::StartNew()
            $scripts = Get-ChildItem -Path $dirPath -Filter "*.ps1" -Recurse
            foreach ($script in $scripts) {
                $scriptTimer = [System.Diagnostics.Stopwatch]::StartNew()
                $result = Import-Script -ScriptPath $script.FullName -Category $dir
                $scriptTimer.Stop()
                if ($result) {
                    Write-Log "Successfully loaded: $($script.Name) (${$scriptTimer.ElapsedMilliseconds}ms)" -Level 'Success'
                }
            }
            $dirTimer.Stop()
            Write-Log "Finished loading $dir directory (${$dirTimer.ElapsedMilliseconds}ms)" -Level 'Info'
        }
    }

    $totalTimer.Stop()
    Write-Log "Total script loading time: ${$totalTimer.ElapsedMilliseconds}ms" -Level 'Info'
}

# Function to display function execution statistics
function Show-FunctionExecutionStats {
    Write-Log "Function Execution Statistics:" -Level 'Info'
    Write-Log "=============================" -Level 'Info'
    
    foreach ($func in $functionExecutionLog.GetEnumerator()) {
        $stats = $func.Value
        Write-Log "Function: $($stats.Name)" -Level 'Info'
        Write-Log "  Category: $($stats.Category)" -Level 'Info'
        Write-Log "  Script: $($stats.Script)" -Level 'Info'
        Write-Log "  Execution Count: $($stats.ExecutionCount)" -Level 'Info'
        if ($stats.LastExecution) {
            Write-Log "  Last Execution: $($stats.LastExecution)" -Level 'Info'
        }
        if ($stats.StartTime -and $stats.EndTime) {
            $duration = $stats.EndTime - $stats.StartTime
            Write-Log "  Last Duration: $($duration.TotalMilliseconds.ToString('0.00'))ms" -Level 'Info'
        }
        Write-Log "  Average Duration: $($stats.AverageDuration.ToString('0.00'))ms" -Level 'Info'
        Write-Log "  Total Duration: $($stats.TotalDuration.ToString('0.00'))ms" -Level 'Info'
        Write-Log "-----------------------------" -Level 'Info'
    }
}
# Load Welcome-Message script
$welcomeMessagePath = Join-Path $scriptsRoot "UI\Welcome-Message.ps1"
if (Test-Path $welcomeMessagePath) {
    Write-Log "Loading Welcome-Message script..." -Level 'Info'
    $welcomeTimer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        . $welcomeMessagePath
        $welcomeTimer.Stop()
        Write-Log "Successfully loaded Welcome-Message script (${$welcomeTimer.ElapsedMilliseconds}ms)" -Level 'Success'
    }
    catch {
        Write-Log "Failed to load Welcome-Message script: $_" -Level 'Error'
    }
}
else {
    Write-Log "Welcome-Message script not found at: $welcomeMessagePath" -Level 'Warning'
}

#endregion Script Loading Functions 