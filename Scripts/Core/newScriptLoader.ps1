# Lightweight Script Loader
# This script provides basic script loading functionality with minimal overhead

# Initialize core variables
$script:loadedScripts = @{}
$script:scriptsRoot = Split-Path -Parent $PSScriptRoot

function Import-Script {
    param (
        [Parameter(Mandatory)]
        [string]$ScriptPath,
        [string]$Category = "General",
        [switch]$Force
    )

    $scriptKey = $ScriptPath.ToLower()
    
    # Check if script is already loaded
    if ($script:loadedScripts.ContainsKey($scriptKey) -and !$Force) {
        Write-Host "Script already loaded: $ScriptPath" -ForegroundColor Yellow
        return $true
    }

    try {
        if (-not (Test-Path $ScriptPath)) {
            Write-Host "Script not found: $ScriptPath" -ForegroundColor Red
            return $false
        }

        # Check if script requires admin privileges
        $scriptContent = Get-Content $ScriptPath -Raw -ErrorAction Stop
        if ($scriptContent -match '#Requires -RunAsAdministrator') {
            $isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            if (-not $isAdmin) {
                Write-Host "Script requires admin privileges. Elevating..." -ForegroundColor Yellow
                Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
                return $false
            }
        }

        # Check if this is a module
        $moduleManifestPath = $ScriptPath -replace '\.ps1$', '.psd1'
        if (Test-Path $moduleManifestPath) {
            Write-Host "Loading module: $ScriptPath" -ForegroundColor Cyan
            Import-Module $moduleManifestPath -Force -ErrorAction Stop
            $script:loadedScripts[$scriptKey] = $true
            return $true
        }

        # Load the script
        . ([scriptblock]::Create(". '$ScriptPath'"))
        $script:loadedScripts[$scriptKey] = $true
        Write-Host "Successfully loaded script: $ScriptPath (Category: $Category)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error loading script $ScriptPath : $_" -ForegroundColor Red
        return $false
    }
}

function Import-ScriptCategory {
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [string[]]$Scripts
    )

    Write-Host "Loading $Category category scripts..." -ForegroundColor Cyan
    
    foreach ($script in $Scripts) {
        $scriptPath = Join-Path $script:scriptsRoot $Category $script
        Import-Script -ScriptPath $scriptPath -Category $Category
    }
}

# Define script categories and their files
$scriptCategories = @{
    Core           = @(
        "Aliases.ps1"
    )
    FileManagement = @(
        "bringVsCodeForeground.ps1"
    )
    Navigation     = @(
        "cd-downloads.ps1"
    )
    Networking     = @(
        "URL-Funk.ps1"
    )
    Development    = @(
        "Notes-Function.ps1"
    )
    Utility        = @(
        "MathOperations.ps1",
        "Security.ps1",
        "HVAC.ps1",
        "Backup.ps1"
    )
    # UI             = @(
    #     "winfetch-pro.ps1",
    #     "Welcome-Message.ps1"
    # )
}

function Import-AllScripts {
    # Load Core scripts first
    Write-Host "Loading Core scripts first..." -ForegroundColor Cyan
    Import-ScriptCategory -Category "Core" -Scripts $scriptCategories["Core"]

    # Load remaining scripts by category
    foreach ($category in $scriptCategories.Keys | Where-Object { $_ -ne "Core" }) {
        Import-ScriptCategory -Category $category -Scripts $scriptCategories[$category]
    }
}

# Export functions
Export-ModuleMember -Function Import-Script, Import-ScriptCategory, Import-AllScripts
