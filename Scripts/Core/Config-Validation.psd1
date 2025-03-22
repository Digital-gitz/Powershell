@{
    RootModule        = 'Config-Validation.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '12345678-1234-1234-1234-123456789012'
    Author            = 'Svyatoslav Oleg Russkiy'
    Description       = 'Configuration validation and management for PowerShell profile'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-Configuration',
        'Test-ProfileConfiguration',
        'Write-ProfileLog'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @()
} 