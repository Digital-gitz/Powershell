#region Configuration
$configPath = Join-Path $PSScriptRoot "..\..\config.psd1"

# Default configuration
$defaultConfig = @{
    CommonPaths     = @{
        PowerShell = $PSScriptRoot
        Scripts    = Join-Path $PSScriptRoot ".."
        Documents  = [Environment]::GetFolderPath('MyDocuments')
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
        $mergedConfig
    }
    else {
        $defaultConfig
    }
}
catch {
    Write-Host "Using default configuration" -ForegroundColor Yellow
    $defaultConfig
}

# Ensure PSReadLine settings are valid
if (-not $config.PSReadLine) {
    $config.PSReadLine = $defaultConfig.PSReadLine
}
else {
    # Validate and set default values for each PSReadLine setting
    $config.PSReadLine.ShowToolTips = if ($config.PSReadLine.ShowToolTips -eq $null) { $true } else { $config.PSReadLine.ShowToolTips }
    $config.PSReadLine.PredictionSource = if ($config.PSReadLine.PredictionSource -notin @("None", "History", "Plugin", "HistoryAndPlugin")) { "History" } else { $config.PSReadLine.PredictionSource }
    $config.PSReadLine.PredictionViewStyle = if ($config.PSReadLine.PredictionViewStyle -notin @("InlineView", "ListView")) { "ListView" } else { $config.PSReadLine.PredictionViewStyle }
    $config.PSReadLine.EditMode = if ($config.PSReadLine.EditMode -notin @("Windows", "Emacs", "Vi")) { "Windows" } else { $config.PSReadLine.EditMode }
    $config.PSReadLine.HistorySavePath = if ([string]::IsNullOrEmpty($config.PSReadLine.HistorySavePath)) { $defaultConfig.PSReadLine.HistorySavePath } else { $config.PSReadLine.HistorySavePath }
    $config.PSReadLine.HistorySaveStyle = if ($config.PSReadLine.HistorySaveStyle -notin @("SaveIncrementally", "SaveAtExit", "SaveNothing")) { "SaveIncrementally" } else { $config.PSReadLine.HistorySaveStyle }
}

# Initialize common paths and create necessary directories
$commonPaths = @{}
foreach ($key in $config.CommonPaths.Keys) {
    $pathValue = $ExecutionContext.InvokeCommand.ExpandString($config.CommonPaths[$key])
    $commonPaths[$key] = $pathValue
    if (-not (Test-Path $pathValue)) { 
        try {
            New-Item -ItemType Directory -Path $pathValue -Force | Out-Null
        }
        catch {
            Write-Host "Failed to create directory $pathValue" -ForegroundColor Red
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
    }
    catch {
        Write-Host "Failed to create PSReadLine history directory" -ForegroundColor Red
    }
}

function Get-Configuration {
    return $config
}

function Get-CommonPaths {
    return $commonPaths
}
#endregion Configuration 