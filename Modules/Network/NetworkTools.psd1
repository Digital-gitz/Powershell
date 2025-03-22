@{
    RootModule        = 'NetworkTools.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '12345678-1234-1234-1234-123456789012'
    Author            = 'Svyatoslav Oleg Russkiy'
    Description       = 'Network utility functions for PowerShell'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Test-NetworkConnection',
        'Get-NetworkInterfaces',
        'Get-NetworkIPConfig',
        'Test-Port'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @()
} 