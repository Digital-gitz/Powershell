#region Configuration
$configPath = Join-Path $PSScriptRoot "..\..\config.psd1"

# Default configuration
$defaultConfig = @{
    CommonPaths     = @{
        PowerShell = $PSScriptRoot
        Scripts    = Join-Path $PSScriptRoot ".."
        Documents  = [Environment]::GetFolderPath('MyDocuments')
        Logs       = Join-Path $PSScriptRoot "..\..\logs"
    }
    RequiredModules = @(
        @{Name = 'Terminal-Icons'; Purpose = 'Directory and file icons'; Scope = 'CurrentUser' }
        @{Name = 'PSReadLine'; Purpose = 'Enhanced console experience'; Scope = 'CurrentUser' }
        @{Name = 'posh-git'; Purpose = 'Git integration for PowerShell'; Scope = 'CurrentUser' }
    )
    PSReadLine      = @{
        ShowToolTips        = $true
        PredictionSource    = "History"
        PredictionViewStyle = "ListView"
        EditMode            = "Windows"
        HistorySavePath     = Join-Path $env:APPDATA "PowerShell\history"
        HistorySaveStyle    = "SaveIncrementally"
    }
    Performance     = @{
        EnableModuleAutoload = $true
        MaxHistoryCount      = 1000
        EnableLogging        = $true
        CacheScripts         = $true
        ParallelLoading      = $true
        ScriptDependencies   = @{
            'Core'    = @('Config-Validation.ps1', 'Module-Management.ps1')
            'UI'      = @('Initialize-OhMyPosh.ps1', 'Initialize-PSReadLine.ps1')
            'Utility' = @('Utility-Functions.ps1', 'Script-Management.ps1')
        }
    }
}

# Try to load configuration file
$config = try {
    if (Test-Path $configPath) {
        $configData = Import-PowerShellDataFile -Path $configPath -ErrorAction Stop
        if ($configData -isnot [hashtable]) { throw "Configuration must be a hashtable" }
        
        # Merge with default config to ensure all required keys exist
        $mergedConfig = $defaultConfig.Clone()
        foreach ($key in $configData.Keys) {
            if ($configData[$key] -is [hashtable]) {
                foreach ($subKey in $configData[$key].Keys) {
                    $mergedConfig[$key][$subKey] = $configData[$key][$subKey]
                }
            }
            else {
                $mergedConfig[$key] = $configData[$key]
            }
        }
        
        Write-Log "Configuration loaded successfully" -Level 'Success'
        $mergedConfig
    }
    else {
        Write-Log "Configuration file not found, using defaults" -Level 'Warning'
        $defaultConfig
    }
}
catch {
    Write-Log "Failed to load configuration: $_" -Level 'Warning'
    Write-Log "Using default configuration" -Level 'Info'
    $defaultConfig
}

# Ensure Performance section exists
if (-not $config.Performance) {
    $config.Performance = $defaultConfig.Performance
}

# Ensure ScriptDependencies exists
if (-not $config.Performance.ScriptDependencies) {
    $config.Performance.ScriptDependencies = $defaultConfig.Performance.ScriptDependencies
}

# Initialize common paths and create necessary directories
$commonPaths = @{}
foreach ($key in $config.CommonPaths.Keys) {
    $pathValue = $ExecutionContext.InvokeCommand.ExpandString($config.CommonPaths[$key])
    $commonPaths[$key] = $pathValue
    if (-not (Test-Path $pathValue)) { 
        try {
            New-Item -ItemType Directory -Path $pathValue -Force | Out-Null
            Write-Log "Created directory: $pathValue" -Level 'Success'
        }
        catch {
            Write-Log "Failed to create directory $pathValue : $_" -Level 'Error'
        }
    }
}

# Create PSReadLine history directory with proper permissions
$historyPath = $config.PSReadLine.HistorySavePath
if (-not (Test-Path $historyPath)) {
    try {
        New-Item -ItemType Directory -Path $historyPath -Force | Out-Null
        $acl = Get-Acl $historyPath
        $acl.SetAccessRuleProtection($false, $true)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($rule)
        Set-Acl $historyPath $acl
        Write-Log "Created PSReadLine history directory: $historyPath" -Level 'Success'
    }
    catch {
        Write-Log "Failed to create PSReadLine history directory $historyPath : $_" -Level 'Error'
    }
}

function Get-Configuration {
    return $config
}

function Get-CommonPaths {
    return $commonPaths
}
#endregion Configuration 