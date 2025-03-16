#region Module Management
function Import-RequiredModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose,
        [string]$Version,
        [switch]$Parallel
    )
    
    $job = {
        param($ModuleName, $Version)
        try {
            if (-not (Get-Module -Name $ModuleName -ListAvailable)) {
                if ($Version) {
                    Install-Module -Name $ModuleName -RequiredVersion $Version -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
                } else {
                    Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
                }
            }
            Import-Module -Name $ModuleName -ErrorAction Stop | Out-Null
            # Return nothing on success
            return $null
        } catch {
            return @{ Success = $false; Message = $_.Exception.Message }
        }
    }

    if ($Parallel) {
        $result = Start-Job -ScriptBlock $job -ArgumentList $Name, $Version | 
            Receive-Job -Wait -AutoRemoveJob
        # Only output if there was an error
        if ($result) {
            Write-Warning "Failed to import module $Name`: $($result.Message)"
        }
    } else {
        $result = & $job $Name $Version
        # Only output if there was an error
        if ($result) {
            Write-Warning "Failed to import module $Name`: $($result.Message)"
        }
    }
}

# Import modules if in console host
if ($host.Name -eq 'ConsoleHost' -and $Config.RequiredModules) {
    foreach ($module in $Config.RequiredModules) {
        Import-RequiredModule -Name $module.Name -Purpose $module.Purpose
    }
}

# Function to update all packages
function Update-AllPackages {
    Write-Host "Updating all installed packages..." -ForegroundColor Yellow
    winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
}

function Remove-UnusedModules {
    [CmdletBinding()]
    param(
        [switch]$WhatIf
    )
    
    $installedModules = Get-InstalledModule
    $usedModules = Get-Module | Select-Object -ExpandProperty Name
    $unusedModules = $installedModules | Where-Object { $_.Name -notin $usedModules }
    
    if ($unusedModules) {
        if ($WhatIf) {
            Write-Host "The following modules would be removed:" -ForegroundColor Yellow
            $unusedModules | ForEach-Object {
                Write-Host "- $($_.Name) v$($_.Version)" -ForegroundColor Yellow
            }
        } else {
            $unusedModules | ForEach-Object {
                Write-Host "Removing unused module: $($_.Name) v$($_.Version)" -ForegroundColor Yellow
                try {
                    Uninstall-Module -Name $_.Name -Force -ErrorAction Stop
                    Write-Host "  ✓ Removed successfully" -ForegroundColor Green
                } catch {
                    Write-Host "  ✗ Failed to remove: $_" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "No unused modules found." -ForegroundColor Green
    }
}


function Update-PowerShellModules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$ModuleNames = $Config.RequiredModules.Name,
        
        [Parameter(Mandatory=$false)]
        [switch]$AutoInstall,
        
        [Parameter(Mandatory=$false)]
        [switch]$UpdateExisting
    )
    
    if (-not $ModuleNames -or $ModuleNames.Count -eq 0) {
        Write-Warning "No modules specified for installation/update"
        return
    }
    
    $results = @{
        Installed = @()
        Updated = @()
        Failed = @()
        Skipped = @()
    }
    
    foreach ($moduleName in $ModuleNames) {
        $moduleInfo = $null
        
        # Find module info if it exists in config
        if ($Config.RequiredModules) {
            $moduleInfo = $Config.RequiredModules | Where-Object { 
                ($_ -is [string] -and $_ -eq $moduleName) -or
                ($_ -is [hashtable] -and $_.Name -eq $moduleName)
            }
        }
        
        $minVersion = $null
        if ($moduleInfo -is [hashtable] -and $moduleInfo.MinimumVersion) {
            $minVersion = $moduleInfo.MinimumVersion
        }
        
        # Check if module is installed
        $installedModule = Get-Module -Name $moduleName -ListAvailable
        
        if (-not $installedModule) {
            if ($AutoInstall) {
                try {
                    Write-Host "Installing module: $moduleName" -ForegroundColor Cyan -NoNewline
                    
                    $installParams = @{
                        Name = $moduleName
                        Scope = "CurrentUser"
                        Force = $true
                        ErrorAction = "Stop"
                    }
                    
                    if ($minVersion) {
                        $installParams.MinimumVersion = $minVersion
                    }
                    
                    Install-Module @installParams
                    Write-Host " - Installed!" -ForegroundColor Green
                    $results.Installed += $moduleName
                }
                catch {
                    Write-Host " - Failed!" -ForegroundColor Red
                    Write-Warning "Failed to install module $moduleName`: $_"
                    $results.Failed += @{
                        Name = $moduleName
                        Error = $_.Exception.Message
                    }
                }
            }
            else {
                Write-Warning "Module '$moduleName' is not installed. Use -AutoInstall to install it."
                $results.Skipped += $moduleName
            }
        }
        elseif ($UpdateExisting) {
            try {
                $currentVersion = ($installedModule | Sort-Object Version -Descending | Select-Object -First 1).Version
                
                Write-Host "Checking for updates: $moduleName v$currentVersion" -ForegroundColor Cyan -NoNewline
                
                $onlineModule = Find-Module -Name $moduleName -ErrorAction Stop
                
                if ($onlineModule.Version -gt $currentVersion) {
                    Write-Host " - Updating to v$($onlineModule.Version)" -ForegroundColor Yellow
                    
                    Update-Module -Name $moduleName -Force -ErrorAction Stop
                    $results.Updated += @{
                        Name = $moduleName
                        OldVersion = $currentVersion
                        NewVersion = $onlineModule.Version
                    }
                }
                else {
                    Write-Host " - Up to date!" -ForegroundColor Green
                    $results.Skipped += $moduleName
                }
            }
            catch {
                Write-Host " - Update failed!" -ForegroundColor Red
                Write-Warning "Failed to update module $moduleName`: $_"
                $results.Failed += @{
                    Name = $moduleName
                    Error = $_.Exception.Message
                }
            }
        }
    }
    
    return $results
}

# Auto-update modules if specified in config
if ($Config.AutoUpdateModules -eq $true) {
    Update-PowerShellModules -AutoInstall -UpdateExisting
}

function Initialize-EdgeDriver {
    [CmdletBinding()]
    param()
    
    $startTime = Get-Date
    try {
        # Create drivers directory if it doesn't exist
        $driversPath = Join-Path $env:USERPROFILE "WebDrivers"
        if (-not (Test-Path $driversPath)) {
            New-Item -ItemType Directory -Path $driversPath -Force | Out-Null
        }

        # Use a known stable version
        $driverVersion = "122.0.2365.92"  # Update this version periodically
        $driverUrl = "https://msedgedriver.azureedge.net/$driverVersion/edgedriver_win64.zip"
        $zipPath = Join-Path $driversPath "edgedriver.zip"
        $driverPath = Join-Path $driversPath "msedgedriver.exe"

        # Only download if driver doesn't exist
        if (-not (Test-Path $driverPath)) {
            Write-Host "Downloading Edge WebDriver..."
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $driverUrl -OutFile $zipPath -UseBasicParsing

            Write-Host "Extracting Edge WebDriver..."
            if (Test-Path $driverPath) {
                Remove-Item $driverPath -Force
            }
            Expand-Archive -Path $zipPath -DestinationPath $driversPath -Force
            Remove-Item $zipPath -Force
        }

        # Add driver path to environment if not already present
        if (-not ($env:PATH -split ';' -contains $driversPath)) {
            $env:PATH += ";$driversPath"
        }

        # Load Selenium assemblies
        $seleniumModule = Get-Module -Name Selenium -ListAvailable | Select-Object -First 1
        if ($seleniumModule) {
            $webDriverPath = Join-Path $seleniumModule.ModuleBase "assemblies\WebDriver.dll"
            if (Test-Path $webDriverPath) {
                Add-Type -Path $webDriverPath
            }
        }

        Register-ProfileMetric -Name "EdgeDriver-Setup" -StartTime $startTime -Details "Successfully installed Edge WebDriver $driverVersion"
        return $true
    }
    catch {
        Register-ProfileMetric -Name "EdgeDriver-Setup" -StartTime $startTime -IsError -Details $_.Exception.Message
        Write-Error "Failed to initialize Edge WebDriver: $_"
        return $false
    }
}


function Install-RequiredModule {
    param(
        [Parameter(Mandatory)][string]$ModuleName
    )
    
    $startTime = Get-Date
    try {
        if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Host "Installing required module: $ModuleName"
            Install-Module -Name $ModuleName -Force -Scope CurrentUser
            Register-ProfileMetric -Name "Module-Install-$ModuleName" -StartTime $startTime
        }
        Import-Module $ModuleName -Force
        Register-ProfileMetric -Name "Module-Import-$ModuleName" -StartTime $startTime
    } catch {
        Register-ProfileMetric -Name "Module-Setup-$ModuleName" -StartTime $startTime -IsError -Details $_.Exception.Message
        Write-Error "Failed to setup module $ModuleName : $_"
        return $false
    }
    return $true
}


# Function to create new module
function New-PowerShellModule {
    [CmdletBinding()]
    [Alias('addmodule')]
    param (
        [Parameter(Position = 0)]
        [string]$ModuleName = $(Read-Host "Enter module name"),
        
        [Parameter()]
        [string]$Author = $env:USERNAME,
        
        [Parameter()]
        [string]$Description = "PowerShell module created by $Author",
        
        [Parameter()]
        [Version]$Version = "0.1.0",
        
        [Parameter()]
        [string]$OutputPath
    )
    
    if ([string]::IsNullOrWhiteSpace($ModuleName)) {
        Write-Error "Module name cannot be empty"
        return
    }
    
    try {
        # Determine the module path
        if (-not $OutputPath) {
            $modulePath = Join-Path $CommonPaths.Documents "PowerShell\Modules\$ModuleName"
        } else {
            $modulePath = Join-Path $OutputPath $ModuleName
        }
        
        # Create the module directory
        if (Test-Path $modulePath) {
            Write-Warning "Module directory already exists: $modulePath"
            $overwrite = Read-Host "Do you want to overwrite? (Y/N)"
            if ($overwrite -ne "Y") {
                Write-Host "Operation cancelled" -ForegroundColor Yellow
                return
            }
        }
        
        New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
        
        # Create module manifest
        $manifestPath = Join-Path $modulePath "$ModuleName.psd1"
        $moduleScriptPath = Join-Path $modulePath "$ModuleName.psm1"
        
        # Create base module file
        @"
<#
.SYNOPSIS
$Description

.DESCRIPTION
$Description

.NOTES
Author: $Author
Version: $Version
#>

# Export functions
Export-ModuleMember -Function *
"@ | Out-File -FilePath $moduleScriptPath -Encoding utf8
        
        # Create module manifest
        New-ModuleManifest -Path $manifestPath `
            -RootModule "$ModuleName.psm1" `
            -Author $Author `
            -Description $Description `
            -ModuleVersion $Version `
            -PowerShellVersion "5.1" `
            -FunctionsToExport "*" `
            -CmdletsToExport @() `
            -VariablesToExport @() `
            -AliasesToExport @()
        
        # Update module path
        Update-ModulePath -Add -Path $modulePath
        
        Write-Host "Module created successfully at $modulePath" -ForegroundColor Green
        Write-Host "Module manifest: $manifestPath" -ForegroundColor Cyan
        Write-Host "Module script: $moduleScriptPath" -ForegroundColor Cyan
    } catch {
        Write-Error "Failed to create module: $_"
    }
}



