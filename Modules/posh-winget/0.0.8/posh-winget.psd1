@{
    RootModule = 'posh-winget.psm1'
    ModuleVersion = '0.0.8'
    GUID = '9b311919-2cd3-4c9f-bf8f-b35cf063da58'
    Author = 'nuits.jp'
    Copyright = '(c) nuits.jp. All rights reserved.'
    PowerShellVersion = '3.0'
    Description = 'Support PowerShell module for winget.'
    FunctionsToExport = @(
        'Invoke-WingetList'
        'Invoke-WingetImport'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            ProjectUri = 'https://github.com/nuitsjp/posh-winget'
            LicenseUri = 'https://raw.githubusercontent.com/nuitsjp/posh-winget/main/LICENSE'
            ReleaseNotes = 'https://github.com/nuitsjp/posh-winget/releases'
            Tags = @('winget')
            IconUri = 'https://raw.githubusercontent.com/nuitsjp/posh-winget/main/nuits.jp.256x256.png'
            RequireLicenseAcceptance = $false
            ExternalModuleDependencies = @('powershell-yaml')
        }
    }
}

