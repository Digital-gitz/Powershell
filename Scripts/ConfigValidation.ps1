# Add configuration validation
function Test-ProfileConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $Config
    )
    
    $errors = @()
    
    # Check if Config is null or not a hashtable
    if ($null -eq $Config) {
        $errors += "Configuration is null"
        return @{
            IsValid = $false
            Errors = $errors
        }
    }
    
    if ($Config -isnot [hashtable]) {
        $errors += "Configuration must be a hashtable"
        return @{
            IsValid = $false
            Errors = $errors
        }
    }
    
    $requiredKeys = @('CommonPaths', 'UrlCollections', 'RequiredModules')
    
    foreach ($key in $requiredKeys) {
        if (-not $Config.ContainsKey($key)) {
            $errors += "Missing required configuration key: $key"
        }
    }
    
    if ($Config.ContainsKey('RequiredModules') -and $null -ne $Config.RequiredModules) {
        foreach ($module in $Config.RequiredModules) {
            if ($module -is [hashtable] -and -not $module.ContainsKey('Name')) {
                $errors += "Module configuration missing Name property"
            }
        }
    }
    
    return @{
        IsValid = ($errors.Count -eq 0)
        Errors = $errors
    }
}

# Initialize profile with validation
$configValidation = Test-ProfileConfiguration -Config $Config

if (-not $configValidation.IsValid) {
    Write-Warning "Profile configuration validation failed:"
    $configValidation.Errors | ForEach-Object { Write-Warning "  - $_" }
}

# Enhanced error logging
function Write-ProfileLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info',
        [string]$LogDirectory = $null
    )
    
    try {
        # Determine log directory with fallbacks
        $logDir = $LogDirectory ?? 
                 $CommonPaths.PowerShell ?? 
                 $PSScriptRoot ?? 
                 (Join-Path $HOME "Documents\PowerShell")

        # Ensure log directory exists
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }

        $logPath = Join-Path $logDir "profile.log"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] $Message"
        
        Add-Content -Path $logPath -Value $logMessage -ErrorAction Stop
        
        # Output to console
        switch ($Level) {
            'Info' { Write-Host $Message -ForegroundColor Gray }
            'Warning' { Write-Warning $Message }
            'Error' { Write-Error $Message }
        }
    }
    catch {
        # Fallback to just console output if logging fails
        Write-Warning "Failed to write to log file: $_"
        switch ($Level) {
            'Info' { Write-Host $Message -ForegroundColor Gray }
            'Warning' { Write-Warning $Message }
            'Error' { Write-Error $Message }
        }
    }
}
