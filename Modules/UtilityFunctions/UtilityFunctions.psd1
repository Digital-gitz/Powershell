@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'UtilityFunctions.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = '87654321-4321-8765-4321-876543210987'

    # Author of this module
    Author            = 'Svyatoslav O Russkiy'

    # Company or vendor of this module
    CompanyName       = 'Digital Russkiy'

    # Copyright statement for this module
    Copyright         = '(c) 2023 Digital Russkiy. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Core utility functions for PowerShell environment'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-Guid',
        'Update-ModulePath',
        'Install-Package',
        'Initialize-PSReadLine',
        'Show-Path',
        'Show-LLMConfig',
        'Find-AndInstallModule',
        'Import-EnvironmentSpecificConfig',
        'New-Script'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module for discovery
            Tags       = @('Utility', 'Core', 'Functions')

            # License URI for this module
            LicenseUri = 'https://github.com/Digital-Russkiy/PowerShell/blob/main/LICENSE'

            # Project URI for this module
            ProjectUri = 'https://github.com/Digital-Russkiy/PowerShell'
        }
    }
} 