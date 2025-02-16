<#
.SYNOPSIS
    Adds firewall rules for executables (needs admin rights).
.DESCRIPTION
    This PowerShell script adds firewall rules for executable files in a specified directory.
    It includes input validation, error handling, and detailed logging.
.PARAMETER PathToExecutables
    Specifies the path to the executables.
.PARAMETER Direction
    Specifies the direction for the firewall rule. Valid values: 'Inbound' or 'Outbound'.
.PARAMETER Profile 
    Specifies the firewall profile(s). Valid values: 'Domain', 'Private', 'Public'.
.PARAMETER Protocol
    Specifies the protocol for the firewall rule. Valid values: 'TCP', 'UDP', 'Any'.
.PARAMETER Action
    Specifies whether to allow or block. Valid values: 'Allow', 'Block'.
.EXAMPLE
    PS> ./add-firewall-rules.ps1 -PathToExecutables C:\MyApp\bin -Direction Outbound -Profile Private
.EXAMPLE
    PS> ./add-firewall-rules.ps1 -PathToExecutables "C:\Program Files\MyApp" -Direction Inbound -Profile @("Domain","Private") -Protocol TCP
.LINK
    https://github.com/fleschutz/PowerShell
.NOTES
    Author: Markus Fleschutz | License: CC0
    Enhanced by: Claude

	toUse
# Basic usage
./add-firewall-rules.ps1 -PathToExecutables "C:\MyApp\bin"

# Advanced usage with all parameters
./add-firewall-rules.ps1 -PathToExecutables "C:\Program Files\MyApp" `
                        -Direction Inbound `
                        -FirewallProfile @("Domain","Private") `
                        -Protocol TCP `
                        -Action Allow
#>

#Requires -RunAsAdministrator

param(
    [Parameter(Mandatory=$true,
               HelpMessage="Enter the path to the directory containing executables")]
    [ValidateScript({Test-Path $_})]
    [string]$PathToExecutables,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction = "Inbound",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Domain", "Private", "Public")]
    [array]$FirewallProfile = @("Domain", "Private"),

    [Parameter(Mandatory=$false)]
    [ValidateSet("TCP", "UDP", "Any")]
    [string]$Protocol = "Any",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Allow", "Block")]
    [string]$Action = "Allow"
)

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "Info"    { Write-Host $logMessage }
        "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
        "Error"   { Write-Host $logMessage -ForegroundColor Red }
    }
}

function Test-FirewallRuleExists {
    param(
        [string]$RuleName,
        [string]$ProgramPath
    )
    
    $existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue |
        Get-NetFirewallApplicationFilter | 
        Where-Object { $_.Program -eq $ProgramPath }
    
    return $null -ne $existingRule
}

try {
    # Validate and resolve the path
    $AbsPath = Resolve-Path -Path $PathToExecutables -ErrorAction Stop
    Write-Log "Scanning directory: $AbsPath"
    
    # Get all executables in the directory
    $Executables = Get-ChildItem -Path $AbsPath -Filter "*.exe" -ErrorAction Stop
    
    if (-not $Executables) {
        Write-Log "No executables found in the specified directory." -Level Warning
        exit
    }
    
    Write-Log "Found $($Executables.Count) executable(s)"
    
    # Process each executable
    foreach ($exe in $Executables) {
        $exeName = $exe.Name
        $exeFullPath = $exe.FullName
        
        # Check if rule already exists
        if (Test-FirewallRuleExists -RuleName $exeName -ProgramPath $exeFullPath) {
            Write-Log "Firewall rule already exists for $exeName - skipping" -Level Warning
            continue
        }
        
        Write-Log "Adding firewall rule for: $exeName"
        
        # Create the firewall rule
        $params = @{
            DisplayName = $exeName
            Direction = $Direction
            Program = $exeFullPath
            Profile = $FirewallProfile
            Action = $Action
            Protocol = if ($Protocol -eq "Any") { "TCP", "UDP" } else { $Protocol }
            Enabled = "True"
        }
        
        New-NetFirewallRule @params -ErrorAction Stop
        Write-Log "Successfully created firewall rule for $exeName"
    }
    
    Write-Log "Script completed successfully" -Level Info
    
} catch {
    Write-Log "Error occurred: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}