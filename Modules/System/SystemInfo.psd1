@{
    RootModule        = 'SystemInfo.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '98765432-5432-5432-5432-321098765432'
    Author            = 'Svyatoslav Oleg Russkiy'
    Description       = 'System information gathering functions for PowerShell'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-SystemInfo',
        'Get-SystemUptime',
        'Get-SystemServices'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @()
} 