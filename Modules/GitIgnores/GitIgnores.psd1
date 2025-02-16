@{
    RootModule = 'GitIgnores.psm1'
    ModuleVersion = '1.0.0'
    GUID = '68b4ad81-1e55-4630-89d9-32ed86e38ad2'  # Replace with your generated GUID
    Author = 'Svyatoslav Oleg Russkiy'
    Description = 'Module for building repositories using various build systems'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-GitIgnore', 'Add-GitIgnore')  # Add your functions here
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @( 'gitignore', 'templates', 'github' ) 
            ProjectUri = 'https://github.com/ImDigitalpowershell/GitIgnores'
        }
    }
}