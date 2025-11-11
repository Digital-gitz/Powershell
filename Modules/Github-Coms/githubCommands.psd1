@{
    RootModule        = 'githubCommands.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '87654321-4321-4321-4321-210987654321'
    Author            = 'Svyatoslav Oleg Russkiy'
    Description       = 'GitHub Copilot and related commands for PowerShell'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Invoke-Copilot',
        'Invoke-CopilotSuggest',
        'Invoke-CopilotExplain'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @(
        'copilot',
        'ghs',
        'gce'
    )
} 