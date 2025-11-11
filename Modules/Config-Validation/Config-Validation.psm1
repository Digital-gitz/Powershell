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
            Errors  = $errors
        }
    }
    
    if ($Config -isnot [hashtable]) {
        $errors += "Configuration must be a hashtable"
        return @{
            IsValid = $false
            Errors  = $errors
        }
    }
    
    $requiredKeys = @('CommonPaths', 'RequiredModules')
    
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
        Errors  = $errors
    }
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

function Get-Configuration {
    param (
        [string]$ConfigPath = (Join-Path $PSScriptRoot ".." "config.psd1")
    )

    try {
        # Load the configuration file
        $config = Import-PowerShellDataFile -Path $ConfigPath -ErrorAction Stop

        # Function to expand environment variables in a string
        function Expand-EnvVars {
            param([string]$String)
            $String -replace '%(\w+)%', { ${env:$($matches[1])} }
        }

        # Function to process paths in a hashtable
        function Process-Paths {
            param([hashtable]$Hash)
            $newHash = @{}
            foreach ($key in $Hash.Keys) {
                if ($Hash[$key] -is [string]) {
                    if ($Hash[$key] -match '%\w+%') {
                        $newHash[$key] = Expand-EnvVars -String $Hash[$key]
                    }
                    else {
                        $newHash[$key] = $Hash[$key]
                    }
                }
                elseif ($Hash[$key] -is [hashtable]) {
                    $newHash[$key] = Process-Paths -Hash $Hash[$key]
                }
                else {
                    $newHash[$key] = $Hash[$key]
                }
            }
            return $newHash
        }

        # Process all paths in the configuration
        $config = Process-Paths -Hash $config

        # Convert MaxFileSize from bytes to bytes object
        if ($config.Logging.MaxFileSize -is [int]) {
            $config.Logging.MaxFileSize = [System.Convert]::ToInt64($config.Logging.MaxFileSize)
        }

        return $config
    }
    catch {
        Write-Log "Failed to load configuration: $_" -Level 'Error'
        return $null
    }
}

# Export the functions
Export-ModuleMember -Function Get-Configuration, Test-ProfileConfiguration, Write-ProfileLog 