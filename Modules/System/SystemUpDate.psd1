@{
    RootModule        = 'SystemUpDate.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '11223344-5544-5544-5544-443322110000'
    Author            = 'Svyatoslav Oleg Russkiy'
    Description       = 'System update management functions for PowerShell'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Update-WindowsSystem',
        'Update-ChocolateyPackages'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @()
} 