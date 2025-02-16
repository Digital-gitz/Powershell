# BuildRepo.psd1
@{
    RootModule = 'BuildRepo.psm1'
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'  # Generate a new GUID for your module
    Author = 'Svyatoslav Oleg Russkiy'
    Description = 'Module for building repositories using various build systems'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Build-Repository')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('build', 'repository', 'cmake', 'make', 'gradle')
            ProjectUri = 'https://github.com/ImDigitalpowershell/BuildRepo'
        }
    }
}