@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'check-moon-phase.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = '12345678-1234-5678-1234-567812345678'

    # Author of this module
    Author            = 'Svyatoslav O Russkiy'

    # Company or vendor of this module
    CompanyName       = 'Digital Russkiy'

    # Copyright statement for this module
    Copyright         = '(c) 2023 Digital Russkiy. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'PowerShell module for checking moon phases with text-to-speech capability'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('Get-MoonPhase')

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module for discovery
            Tags       = @('Moon', 'Astronomy', 'TTS')

            # License URI for this module
            LicenseUri = 'https://github.com/Digital-Russkiy/PowerShell/blob/main/LICENSE'

            # Project URI for this module
            ProjectUri = 'https://github.com/Digital-Russkiy/PowerShell'
        }
    }
} 