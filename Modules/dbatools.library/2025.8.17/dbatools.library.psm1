function Get-DbatoolsLibraryPath {
    [CmdletBinding()]
    param()
    if ($PSVersionTable.PSEdition -eq "Core") {
        Join-Path -Path $PSScriptRoot -ChildPath core
    } else {
        Join-Path -Path $PSScriptRoot -ChildPath desktop
    }
}

$script:libraryroot = Get-DbatoolsLibraryPath

if ($PSVersionTable.PSEdition -ne "Core") {
    $dir = [System.IO.Path]::Combine($script:libraryroot, "lib")
    $dir = ("$dir\").Replace('\', '\\')

    if (-not ("Redirector" -as [type])) {
        $source = @"
            using System;
            using System.Linq;
            using System.Reflection;
            using System.Text.RegularExpressions;

            public class Redirector
            {
                public Redirector()
                {
                    this.EventHandler = new ResolveEventHandler(AssemblyResolve);
                }

                public readonly ResolveEventHandler EventHandler;

                protected Assembly AssemblyResolve(object sender, ResolveEventArgs e)
                {
                    string[] dlls = {
                        "System.Memory",
                        "System.Runtime",
                        "System.Management.Automation",
                        "System.Runtime.CompilerServices.Unsafe",
                        "Microsoft.Bcl.AsyncInterfaces",
                        "System.Text.Json",
                        "System.Resources.Extensions",
                        "Microsoft.SqlServer.ConnectionInfo",
                        "Microsoft.SqlServer.Smo",
                        "Microsoft.Identity.Client",
                        "System.Diagnostics.DiagnosticSource",
                        "Microsoft.IdentityModel.Abstractions",
                        "Microsoft.Data.SqlClient",
                        "Microsoft.SqlServer.Types",
                        "System.Configuration.ConfigurationManager",
                        "Microsoft.SqlServer.Management.Sdk.Sfc",
                        "Microsoft.SqlServer.Management.IntegrationServices",
                        "Microsoft.SqlServer.Replication",
                        "Microsoft.SqlServer.Rmo",
                        "System.Private.CoreLib",
                        "Azure.Core",
                        "Azure.Identity"
                    };

                    var name = new AssemblyName(e.Name);
                    var assemblyName = name.Name.ToString();
                    foreach (string dll in dlls)
                    {
                        if (assemblyName == dll)
                        {
                            string filelocation = "$dir" + dll + ".dll";
                            //Console.WriteLine(filelocation);
                            return Assembly.LoadFrom(filelocation);
                        }
                    }

                    foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
                    {
                        // maybe this needs to change?
                        var info = assembly.GetName();
                        if (info.FullName == e.Name) {
                            return assembly;
                        }
                    }
                    return null;
                }
            }
"@

        $null = Add-Type -TypeDefinition $source
    }

    try {
        $redirector = New-Object Redirector
        [System.AppDomain]::CurrentDomain.add_AssemblyResolve($redirector.EventHandler)
    } catch {
        # unsure
    }
}

# REMOVED win-sqlclient logic - SqlClient is now directly in lib
$sqlclient = [System.IO.Path]::Combine($script:libraryroot, "lib", "Microsoft.Data.SqlClient.dll")

try {
    Import-Module $sqlclient
} catch {
    throw "Couldn't import $sqlclient | $PSItem"
}

if ($PSVersionTable.PSEdition -ne "Core") {
    [System.AppDomain]::CurrentDomain.remove_AssemblyResolve($onAssemblyResolveEventHandler)
}

if ($PSVersionTable.PSEdition -eq "Core") {
    $names = @(
        'Microsoft.SqlServer.Server',
        'Azure.Core',
        'Azure.Identity',
        'Microsoft.IdentityModel.Abstractions',
        'Microsoft.SqlServer.Dac',
        'Microsoft.SqlServer.Smo',
        'Microsoft.SqlServer.SmoExtended',
        'Microsoft.SqlServer.SqlWmiManagement',
        'Microsoft.SqlServer.WmiEnum',
        'Microsoft.SqlServer.Management.RegisteredServers',
        'Microsoft.SqlServer.Management.Collector',
        'Microsoft.SqlServer.Management.XEvent',
        'Microsoft.SqlServer.Management.XEventDbScoped',
        'Microsoft.SqlServer.XEvent.XELite'
    )
} else {
    $names = @(
        'Azure.Core',
        'Azure.Identity',
        'Microsoft.IdentityModel.Abstractions',
        'Microsoft.Data.SqlClient',
        'Microsoft.SqlServer.Dac',
        'Microsoft.SqlServer.Smo',
        'Microsoft.SqlServer.SmoExtended',
        'Microsoft.SqlServer.SqlWmiManagement',
        'Microsoft.SqlServer.WmiEnum',
        'Microsoft.SqlServer.Management.RegisteredServers',
        'Microsoft.SqlServer.Management.IntegrationServices',
        'Microsoft.SqlServer.Management.Collector',
        'Microsoft.SqlServer.Management.XEvent',
        'Microsoft.SqlServer.Management.XEventDbScoped',
        'Microsoft.SqlServer.XEvent.XELite'
    )
}

if ($Env:SMODefaultModuleName) {
    # then it's DSC, load other required assemblies
    $names += "Microsoft.AnalysisServices.Core"
    $names += "Microsoft.AnalysisServices"
    $names += "Microsoft.AnalysisServices.Tabular"
    $names += "Microsoft.AnalysisServices.Tabular.Json"
}

# XEvent stuff kills CI/CD
if ($PSVersionTable.OS -match "ARM64") {
    $names = $names | Where-Object { $PSItem -notmatch "XE" }
}
#endregion Names

# this takes 10ms
$assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies()

try {
    $null = Import-Module ([IO.Path]::Combine($script:libraryroot, "third-party", "bogus", "Bogus.dll"))
} catch {
    Write-Error "Could not import $assemblyPath : $($_ | Out-String)"
}

try {
    $null = Import-Module ([IO.Path]::Combine($script:libraryroot, "third-party", "LumenWorks", "LumenWorks.Framework.IO.dll"))
} catch {
    Write-Error "Could not import LumenWorks.Framework.IO.dll : $($_ | Out-String)"
}

foreach ($name in $names) {
    # REMOVED win-sqlclient handling and mac-specific logic since files are in standard lib folder

    $x64only = 'Microsoft.SqlServer.Replication', 'Microsoft.SqlServer.XEvent.Linq', 'Microsoft.SqlServer.BatchParser', 'Microsoft.SqlServer.Rmo', 'Microsoft.SqlServer.BatchParserClient'

    if ($name -in $x64only -and $env:PROCESSOR_ARCHITECTURE -eq "x86") {
        Write-Verbose -Message "Skipping $name. x86 not supported for this library."
        continue
    }

    $assemblyPath = [IO.Path]::Combine($script:libraryroot, "lib", "$name.dll")
    $assemblyfullname = $assemblies.FullName | Out-String
    if (-not ($assemblyfullname.Contains("$name,"))) {
        $null = try {
            $null = Import-Module $assemblyPath
        } catch {
            Write-Error "Could not import $assemblyPath : $($_ | Out-String)"
        }
    }
}
# SIG # Begin signature block
# MIIt2gYJKoZIhvcNAQcCoIItyzCCLccCAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAVei+6vHHtCw8L
# IbX5j/Y0xy+qWbPJOMqekyaOgYEN2qCCFdswggbXMIIEv6ADAgECAhMzAAUHQDUL
# WLA3jxwpAAAABQdAMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjUwODE3MTE1NDI2WhcNMjUwODIw
# MTE1NDI2WjBXMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExDzANBgNV
# BAcTBlZpZW5uYTERMA8GA1UEChMIZGJhdG9vbHMxETAPBgNVBAMTCGRiYXRvb2xz
# MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEArKyDNAcxAsfxs+Q1cYMV
# +A/pm1iM9uRH5kAQ8NegheByCaXsgmmxB4FZceY2fPneWJNo3YYAwnwOyVvVUpw7
# wCqDkCEUYwS7B+zoZfht50B7yFaCCsVKAeX15/Wj7e5gZ0bhecyJHuIGEaUhGN+s
# /ANZ6hl/c4UqZC5/avmrU0+1vRmGK8y6njsIbUSUR+wvcg5pNR1IteX8gmM8bzuY
# gw1tJdK29GvhFTQpguM3KDVJjcdY5OEC+xW4523ZO7ibXxWSj2ZpEAPrxnRcwbKb
# jjd8vHH0O2KyT6cEOqbQXhj96L34DZsJETmRREoMjFCZXmO36n7+4pJbVef5/H/q
# OTC9pfB0f6LFV/h2qf5jcEb1tkCFgVIcvE0oC53LllW2Xp9h0+rqN2zVTe7kRgMH
# bcHVmSuN06M6Bs2FuUAUCTb/Zpkb3q3t4O7m4ravBKrr+rl3J+RCYZOm/Khkoyu7
# UuXXUnUIDl4RVBPxdgjpFmboJjjBuAM+E2rZIqaOr/ZPAgMBAAGjggIXMIICEzAM
# BgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA6BgNVHSUEMzAxBgorBgEEAYI3
# YQEABggrBgEFBQcDAwYZKwYBBAGCN2H5+cEspPS4DoOuxLIcm56wGDAdBgNVHQ4E
# FgQUQTBPqQlealG1bv8FgExT8Clei8owHwYDVR0jBBgwFoAU6IPEM9fcnwycdpoK
# ptTfh6ZeWO4wZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIw
# QU9DJTIwQ0ElMjAwMS5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQGCCsGAQUFBzAC
# hlhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29m
# dCUyMElEJTIwVmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3J0MC0GCCsG
# AQUFBzABhiFodHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwZgYDVR0g
# BF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEE
# ATANBgkqhkiG9w0BAQwFAAOCAgEAeoDHKCdeH0tN09ENgCGsgRqy2rH3w9ZyJLvV
# 5zvqnILudtURUd+hJRpAq6ZCsZgcDkubXUPpsA4dkY0TUJWpUhDHjt6c0lVh7FqC
# /pn9G7UxLh51nb32rmdvBxQaB7VqVJZqc4tXxsOJi2+afICwQaTYtewxYamYG4N0
# mA56sCBWOa/wRutMk0Fp+puh3hw2q/KsWa84T4TzTnAg9OYfdI4Cg9BeSrQJALvp
# /YbKTN/RY/KB2cUih0yTduHp4mNQzSwfXUzDG58zw1mf0piqV5e9cyld1NCHr/9p
# 9NNQZjx19NNj3+S8Z/X5EPL5Ki2ylZ64IZKehqNfrTrSgl7LOrMOE+qpOhBw6z98
# gkzBhQD/UtBkFnQIO2pdEI9iR9URccJ+dldqEu+7upVYMgkp20c+C7Ppia9vDykK
# it5T4kVhy3E50LvdlhcsOp2/H1FQA1N3VKzejPq1GVLSmxEcFhGsXhB0TunKA05g
# bkY3Zw7ENptHHktrdRtnUk/At3NS4wSHn3EvDnFMsYILtqBOkneOMaQyY/M2AuET
# 2ZWQVkyX7sbtmutMFvNar+1xI4sUMc/1uMoksqU8kENFecc8oIPWU+m0uvDX2Q3n
# C8R5uYvo129SEHDMqbCsAiX2SlwDUrxpTQbbBEq0UT26GUiKWdpqhueF8z7u8RP3
# AMH37W8wggdaMIIFQqADAgECAhMzAAAABzeMW6HZW4zUAAAAAAAHMA0GCSqGSIb3
# DQEBDAUAMGMxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xNDAyBgNVBAMTK01pY3Jvc29mdCBJRCBWZXJpZmllZCBDb2RlIFNpZ25p
# bmcgUENBIDIwMjEwHhcNMjEwNDEzMTczMTU0WhcNMjYwNDEzMTczMTU0WjBaMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYD
# VQQDEyJNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ1MgQU9DIENBIDAxMIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAt/fAAygHxbo+jxA04hNI8bz+EqbWvSu9
# dRgAawjCZau1Y54IQal5ArpJWi8cIj0WA+mpwix8iTRguq9JELZvTMo2Z1U6AtE1
# Tn3mvq3mywZ9SexVd+rPOTr+uda6GVgwLA80LhRf82AvrSwxmZpCH/laT08dn7+G
# t0cXYVNKJORm1hSrAjjDQiZ1Jiq/SqiDoHN6PGmT5hXKs22E79MeFWYB4y0UlNqW
# 0Z2LPNua8k0rbERdiNS+nTP/xsESZUnrbmyXZaHvcyEKYK85WBz3Sr6Et8Vlbdid
# /pjBpcHI+HytoaUAGE6rSWqmh7/aEZeDDUkz9uMKOGasIgYnenUk5E0b2U//bQqD
# v3qdhj9UJYWADNYC/3i3ixcW1VELaU+wTqXTxLAFelCi/lRHSjaWipDeE/TbBb0z
# TCiLnc9nmOjZPKlutMNho91wxo4itcJoIk2bPot9t+AV+UwNaDRIbcEaQaBycl9p
# cYwWmf0bJ4IFn/CmYMVG1ekCBxByyRNkFkHmuMXLX6PMXcveE46jMr9syC3M8JHR
# ddR4zVjd/FxBnS5HOro3pg6StuEPshrp7I/Kk1cTG8yOWl8aqf6OJeAVyG4lyJ9V
# +ZxClYmaU5yvtKYKk1FLBnEBfDWw+UAzQV0vcLp6AVx2Fc8n0vpoyudr3SwZmckJ
# uz7R+S79BzMCAwEAAaOCAg4wggIKMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEEAYI3
# FQEEAwIBADAdBgNVHQ4EFgQU6IPEM9fcnwycdpoKptTfh6ZeWO4wVAYDVR0gBE0w
# SzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3FAIEDB4KAFMA
# dQBiAEMAQTASBgNVHRMBAf8ECDAGAQH/AgEAMB8GA1UdIwQYMBaAFNlBKbAPD2Ns
# 72nX9c0pnqRIajDmMHAGA1UdHwRpMGcwZaBjoGGGX2h0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBD
# b2RlJTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3JsMIGuBggrBgEFBQcBAQSBoTCB
# njBtBggrBgEFBQcwAoZhaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# ZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ29kZSUyMFNpZ25pbmcl
# MjBQQ0ElMjAyMDIxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWlj
# cm9zb2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQB3/utLItkwLTp4Nfh9
# 9vrbpSsL8NwPIj2+TBnZGL3C8etTGYs+HZUxNG+rNeZa+Rzu9oEcAZJDiGjEWytz
# MavD6Bih3nEWFsIW4aGh4gB4n/pRPeeVrK4i1LG7jJ3kPLRhNOHZiLUQtmrF4V6I
# xtUFjvBnijaZ9oIxsSSQP8iHMjP92pjQrHBFWHGDbkmx+yO6Ian3QN3YmbdfewzS
# vnQmKbkiTibJgcJ1L0TZ7BwmsDvm+0XRsPOfFgnzhLVqZdEyWww10bflOeBKqkb3
# SaCNQTz8nshaUZhrxVU5qNgYjaaDQQm+P2SEpBF7RolEC3lllfuL4AOGCtoNdPOW
# rx9vBZTXAVdTE2r0IDk8+5y1kLGTLKzmNFn6kVCc5BddM7xoDWQ4aUoCRXcsBeRh
# sclk7kVXP+zJGPOXwjUJbnz2Kt9iF/8B6FDO4blGuGrogMpyXkuwCC2Z4XcfyMjP
# DhqZYAPGGTUINMtFbau5RtGG1DOWE9edCahtuPMDgByfPixvhy3sn7zUHgIC/YsO
# TMxVuMQi/bgamemo/VNKZrsZaS0nzmOxKpg9qDefj5fJ9gIHXcp2F0OHcVwe3KnE
# Xa8kqzMDfrRl/wwKrNSFn3p7g0b44Ad1ONDmWt61MLQvF54LG62i6ffhTCeoFT9Z
# 9pbUo2gxlyTFg7Bm0fgOlnRfGDCCB54wggWGoAMCAQICEzMAAAAHh6M0o3uljhwA
# AAAAAAcwDQYJKoZIhvcNAQEMBQAwdzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/TWljcm9zb2Z0IElkZW50aXR5
# IFZlcmlmaWNhdGlvbiBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDIwMB4X
# DTIxMDQwMTIwMDUyMFoXDTM2MDQwMTIwMTUyMFowYzELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMrTWljcm9zb2Z0
# IElEIFZlcmlmaWVkIENvZGUgU2lnbmluZyBQQ0EgMjAyMTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBALLwwK8ZiCji3VR6TElsaQhVCbRS/3pK+MHrJSj3
# Zxd3KU3rlfL3qrZilYKJNqztA9OQacr1AwoNcHbKBLbsQAhBnIB34zxf52bDpIO3
# NJlfIaTE/xrweLoQ71lzCHkD7A4As1Bs076Iu+mA6cQzsYYH/Cbl1icwQ6C65rU4
# V9NQhNUwgrx9rGQ//h890Q8JdjLLw0nV+ayQ2Fbkd242o9kH82RZsH3HEyqjAB5a
# 8+Ae2nPIPc8sZU6ZE7iRrRZywRmrKDp5+TcmJX9MRff241UaOBs4NmHOyke8oU1T
# Yrkxh+YeHgfWo5tTgkoSMoayqoDpHOLJs+qG8Tvh8SnifW2Jj3+ii11TS8/FGngE
# aNAWrbyfNrC69oKpRQXY9bGH6jn9NEJv9weFxhTwyvx9OJLXmRGbAUXN1U9nf4lX
# ezky6Uh/cgjkVd6CGUAf0K+Jw+GE/5VpIVbcNr9rNE50Sbmy/4RTCEGvOq3GhjIT
# bCa4crCzTTHgYYjHs1NbOc6brH+eKpWLtr+bGecy9CrwQyx7S/BfYJ+ozst7+yZt
# G2wR461uckFu0t+gCwLdN0A6cFtSRtR8bvxVFyWwTtgMMFRuBa3vmUOTnfKLsLef
# RaQcVTgRnzeLzdpt32cdYKp+dhr2ogc+qM6K4CBI5/j4VFyC4QFeUP2YAidLtvpX
# RRo3AgMBAAGjggI1MIICMTAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYBBAGCNxUBBAMC
# AQAwHQYDVR0OBBYEFNlBKbAPD2Ns72nX9c0pnqRIajDmMFQGA1UdIARNMEswSQYE
# VR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBD
# AEEwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTIftJqhSobyhmYBAcnz1AQ
# T2ioojCBhAYDVR0fBH0wezB5oHegdYZzaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24l
# MjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3JpdHklMjAyMDIwLmNybDCBwwYI
# KwYBBQUHAQEEgbYwgbMwgYEGCCsGAQUFBzAChnVodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZp
# Y2F0aW9uJTIwUm9vdCUyMENlcnRpZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5j
# cnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29mdC5jb20vb2Nz
# cDANBgkqhkiG9w0BAQwFAAOCAgEAfyUqnv7Uq+rdZgrbVyNMul5skONbhls5fccP
# lmIbzi+OwVdPQ4H55v7VOInnmezQEeW4LqK0wja+fBznANbXLB0KrdMCbHQpbLvG
# 6UA/Xv2pfpVIE1CRFfNF4XKO8XYEa3oW8oVH+KZHgIQRIwAbyFKQ9iyj4aOWeAzw
# k+f9E5StNp5T8FG7/VEURIVWArbAzPt9ThVN3w1fAZkF7+YU9kbq1bCR2YD+Mtun
# SQ1Rft6XG7b4e0ejRA7mB2IoX5hNh3UEauY0byxNRG+fT2MCEhQl9g2i2fs6VOG1
# 9CNep7SquKaBjhWmirYyANb0RJSLWjinMLXNOAga10n8i9jqeprzSMU5ODmrMCJE
# 12xS/NWShg/tuLjAsKP6SzYZ+1Ry358ZTFcx0FS/mx2vSoU8s8HRvy+rnXqyUJ9H
# BqS0DErVLjQwK8VtsBdekBmdTbQVoCgPCqr+PDPB3xajYnzevs7eidBsM71PINK2
# BoE2UfMwxCCX3mccFgx6UsQeRSdVVVNSyALQe6PT12418xon2iDGE81OGCreLzDc
# MAZnrUAx4XQLUz6ZTl65yPUiOh3k7Yww94lDf+8oG2oZmDh5O1Qe38E+M3vhKwmz
# IeoB1dVLlz4i3IpaDcR+iuGjH2TdaC1ZOmBXiCRKJLj4DT2uhJ04ji+tHD6n58vh
# avFIrmcxghdVMIIXUQIBATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmll
# ZCBDUyBBT0MgQ0EgMDECEzMABQdANQtYsDePHCkAAAAFB0AwCwYJYIZIAWUDBAIB
# oHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEILFJ
# waZaqUovFbKC1nlnGYZFmkVLusZ1hrMzhL8aFedoMAsGCSqGSIb3DQEBAQSCAYBE
# f7hPQxnlDXgMndNUR62W1WmYmx9eBSQNmLjsM3fOPhO6uoYZvucoUBbX1FbBDlfF
# Z0BH9kjLaiXkwLxlAiQDtnc1T4UyWQY+Mcg2j4RVbpOQx/mNkDPuLEjLfYb5+Gzl
# Pp/89c/brC/R262TZG/MAngdvI8HzAxr9dZhcVtu6Xhv2JYCcUCQDaUkqzh8XZpQ
# gz1nPR7ecZqmO+ey+wqY3SEMGwX6CK0XhN9MHL1rRq4XeFbOD3f38XE2fizLUVYT
# pgEb38+GMAaOXWIqYeG9LGVMpJ0hfCL55rYgRoz8csHXLWi+gWZFZ9/MJbOqDkni
# 6BX0xqjbenT+EaRRRMVTvgHO8Y9Ai9T7akgBv7o0JreyOLIsmT7Bn107xzSLQ5Qb
# 8pvCOCFxtaja3/XR2ogtUcKx49SbvAkn1CkKPTYI8/KN20fPLRKdDJ79ZfpBLKvN
# QuaDob2g1uRcRQ2OBflyUZ2rffSxLCnAJafK9s2N8bCDMRhc2CQMRsfCkJ6EarWh
# ghS7MIIUtwYKKwYBBAGCNwMDATGCFKcwghSjBgkqhkiG9w0BBwKgghSUMIIUkAIB
# AzEPMA0GCWCGSAFlAwQCAQUAMIIBcwYLKoZIhvcNAQkQAQSgggFiBIIBXjCCAVoC
# AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQgSbqawElLBjFs4ECpgxi3
# NxwRskRLipvBl+JnbCS/xXYCBmieF0qImxgSMjAyNTA4MTgxMTMzNDYuMTlaMASA
# AgH0AghR+zJtFLlXGKCB6aSB5jCB4zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9u
# cyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046NDUxQS0wNUUwLUQ5
# NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcg
# QXV0aG9yaXR5oIIPKTCCB4IwggVqoAMCAQICEzMAAAAF5c8P/2YuyYcAAAAAAAUw
# DQYJKoZIhvcNAQEMBQAwdzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/TWljcm9zb2Z0IElkZW50aXR5IFZlcmlm
# aWNhdGlvbiBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDIwMB4XDTIwMTEx
# OTIwMzIzMVoXDTM1MTExOTIwNDIzMVowYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1Ymxp
# YyBSU0EgVGltZXN0YW1waW5nIENBIDIwMjAwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQCefOdSY/3gxZ8FfWO1BiKjHB7X55cz0RMFvWVGR3eRwV1wb3+y
# q0OXDEqhUhxqoNv6iYWKjkMcLhEFxvJAeNcLAyT+XdM5i2CgGPGcb95WJLiw7HzL
# iBKrxmDj1EQB/mG5eEiRBEp7dDGzxKCnTYocDOcRr9KxqHydajmEkzXHOeRGwU+7
# qt8Md5l4bVZrXAhK+WSk5CihNQsWbzT1nRliVDwunuLkX1hyIWXIArCfrKM3+RHh
# +Sq5RZ8aYyik2r8HxT+l2hmRllBvE2Wok6IEaAJanHr24qoqFM9WLeBUSudz+qL5
# 1HwDYyIDPSQ3SeHtKog0ZubDk4hELQSxnfVYXdTGncaBnB60QrEuazvcob9n4yR6
# 5pUNBCF5qeA4QwYnilBkfnmeAjRN3LVuLr0g0FXkqfYdUmj1fFFhH8k8YBozrEaX
# nsSL3kdTD01X+4LfIWOuFzTzuoslBrBILfHNj8RfOxPgjuwNvE6YzauXi4orp4Sm
# 6tF245DaFOSYbWFK5ZgG6cUY2/bUq3g3bQAqZt65KcaewEJ3ZyNEobv35Nf6xN6F
# rA6jF9447+NHvCjeWLCQZ3M8lgeCcnnhTFtyQX3XgCoc6IRXvFOcPVrr3D9RPHCM
# S6Ckg8wggTrtIVnY8yjbvGOUsAdZbeXUIQAWMs0d3cRDv09SvwVRd61evQIDAQAB
# o4ICGzCCAhcwDgYDVR0PAQH/BAQDAgGGMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1Ud
# DgQWBBRraSg6NS9IY0DPe9ivSek+2T3bITBUBgNVHSAETTBLMEkGBFUdIAAwQTA/
# BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2Nz
# L1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcU
# AgQMHgoAUwB1AGIAQwBBMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAUyH7S
# aoUqG8oZmAQHJ89QEE9oqKIwgYQGA1UdHwR9MHsweaB3oHWGc2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElkZW50aXR5JTIw
# VmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRpZmljYXRlJTIwQXV0aG9yaXR5JTIw
# MjAyMC5jcmwwgZQGCCsGAQUFBwEBBIGHMIGEMIGBBggrBgEFBQcwAoZ1aHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBJZGVu
# dGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhv
# cml0eSUyMDIwMjAuY3J0MA0GCSqGSIb3DQEBDAUAA4ICAQBfiHbHfm21WhV150x4
# aPpO4dhEmSUVpbixNDmv6TvuIHv1xIs174bNGO/ilWMm+Jx5boAXrJxagRhHQtiF
# prSjMktTliL4sKZyt2i+SXncM23gRezzsoOiBhv14YSd1Klnlkzvgs29XNjT+c8h
# IfPRe9rvVCMPiH7zPZcw5nNjthDQ+zD563I1nUJ6y59TbXWsuyUsqw7wXZoGzZwi
# jWT5oc6GvD3HDokJY401uhnj3ubBhbkR83RbfMvmzdp3he2bvIUztSOuFzRqrLfE
# vsPkVHYnvH1wtYyrt5vShiKheGpXa2AWpsod4OJyT4/y0dggWi8g/tgbhmQlZqDU
# f3UqUQsZaLdIu/XSjgoZqDjamzCPJtOLi2hBwL+KsCh0Nbwc21f5xvPSwym0Ukr4
# o5sCcMUcSy6TEP7uMV8RX0eH/4JLEpGyae6Ki8JYg5v4fsNGif1OXHJ2IWG+7zyj
# TDfkmQ1snFOTgyEX8qBpefQbF0fx6URrYiarjmBprwP6ZObwtZXJ23jK3Fg/9uqM
# 3j0P01nzVygTppBabzxPAh/hHhhls6kwo3QLJ6No803jUsZcd4JQxiYHHc+Q/wAM
# cPUnYKv/q2O444LO1+n6j01z5mggCSlRwD9faBIySAcA9S8h22hIAcRQqIGEjolC
# K9F6nK9ZyX4lhthsGHumaABdWzCCB58wggWHoAMCAQICEzMAAABUP/IAPr6h2KYA
# AAAAAFQwDQYJKoZIhvcNAQEMBQAwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBS
# U0EgVGltZXN0YW1waW5nIENBIDIwMjAwHhcNMjUwMjI3MTk0MDI3WhcNMjYwMjI2
# MTk0MDI3WjCB4zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEt
# MCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046NDUxQS0wNUUwLUQ5NDcxNTAzBgNVBAMT
# LE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArtaeeOXDn3qKAPNDtHRfbe9B
# Vr6tco0gAJ3fk4/4wPULvIClKbFNDusAewEXrqXGT7WkBTmrtTNpY5busWuQ9VeF
# 31nNwJD7JcqALBgQjtzOyeqHIdXmtcl43ScFLXRzvGTniE5CLskafwxGbmN1bpTu
# UzElua+v6tOQ7uWox70NydE4PT0ysrTdWAbM2W9q4wr2umor+ENQkeyWCLyn1SQF
# R55FJlz5z1ZwfM0XEEe/uM0H1k+doisabIGq8XXdpJdCwDc4snkSsBb60+iICF4C
# lC5CUof2XIsXQen7gN7K3tX5n1r7hSJg18wsSqX3rgEVSo+AOb2JyvyjRJQCBziK
# 1z/5dnpCbg+i4Q8rpXz26ikNLPCGU7G16GrU2XNLf+dyqVx20PWvq6oolJjLOvfj
# PpBf50A5BWtb4gW1UkDvEiiwLpR/cxPyY7p2vU+EZHwZXg0nX8FAFeDzeNh4r0Rv
# KLtSUZ9doYib6feuTlvaO4gEFp1yaFCcyWN7pJPC4KSeF4W7pRD9lQtjFxfbQj1G
# LeuKYHSejENSwzZ7eg2MKqMFJ9m7gbkpE5GX7ywREKjBrBpuBEpwkojTmAWtJXYD
# FzT408XEklwkYdNZceZ7LFQAe5bdDaWhJV/GwiypkwaeGJBfh/zG2pHb50m71MrW
# S5YNIq/sMqFIwcH3wjsCAwEAAaOCAcswggHHMB0GA1UdDgQWBBTSaTaC27NqQBAW
# puaBdYBuZzdd2TAfBgNVHSMEGDAWgBRraSg6NS9IY0DPe9ivSek+2T3bITBsBgNV
# HR8EZTBjMGGgX6BdhltodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUy
# MDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0wazBpBggrBgEFBQcwAoZdaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBQdWJsaWMl
# MjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3J0MAwGA1UdEwEB/wQC
# MAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeAMGYGA1Ud
# IARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAIBgZngQwB
# BAIwDQYJKoZIhvcNAQEMBQADggIBAHPYFN+GUlaVAVOamZeYg+H0OGwoyaATpqYl
# bJzjbM0xcTYpsq0FAKRwcUKgtOsE5G3namweabQsx1SoTF88vMiA/v6+3IGLTcFS
# QFOvR/URyAwfDNj/xpYI793HkFK2Kn/djPA8sd5sJqj+8gc2ynC/GYpk+fPrwGyX
# gZvG16zwnuEgf2ZpsdRj/aMnTIwa3vXrgBdoCAyDOI78PxlHq8imm0qwBwsCVbQH
# 4XrigU5V/kaFViyzzqEPZA35QrSdM/eydTj6utZkCXHBrDY6ytTwATJvuvpajNtX
# BPFE0hNIuuWKZtT4vWNEwV/eTN9r+E4CoQYBFbmk3hQ5T5TqcU2n7iOmuLWJKUaS
# drf5BkSlEu7O7l+cw1XyA1QGHQ8yTSmrqUwQqBqqubqwHZFW4b47/VYlABzym30Q
# cf+jC5kPprhDg2FWpRldarDN+5L7PqhPzypxQiib0BjRYOwyMDdzie9QtLqD3kU1
# DG+cmEOGrEkRV5/zjnbAROxGVjFgT4HrhQ9phYFLMkITY55rnk9LLN4EwG2w+XWG
# CWaijfIkpY5LcQGbrCi45uN+ODSjL2R5s9RxTNaz7nvrs0TxX8Gso66W9lbJP6om
# CZFcKJAFWBv/L+5oILyl7LHRBC6gOwn1WGdDlxWX37fKt1diGP2W2XJ32bVOWbg9
# XAGuSg4UMYID1DCCA9ACAQEweDBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGljIFJT
# QSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAAFQ/8gA+vqHYpgAAAAAAVDANBglg
# hkgBZQMEAgEFAKCCAS0wGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqG
# SIb3DQEJBDEiBCDx3E0M4RGaMX+uxaaafLgl/E20Xmv5bmhX0rnCodsNjzCB3QYL
# KoZIhvcNAQkQAi8xgc0wgcowgccwgaAEINSBqnpiWZhJb9YgX/6ts2MkRk0up9w0
# QKjumhCYSbALMHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRp
# bWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAVD/yAD6+odimAAAAAABUMCIEIMsgGXtD
# hEjOUr5JlConCT/UY0XTrdr5XtVvZed7WAr3MA0GCSqGSIb3DQEBCwUABIICAI13
# rhDAHujacZKDlSNtXDjbpjZr6cBb5pugJmrCmd0KNXplxeSvTm27jrVSvMDAYbvj
# tP91ZlOIeu8tEkz5nfgDvvtgdb2su+C/qt+29liJCqAaAbHTbhtSgxKr904GtYMm
# GDXXx/629n7ThY4Amy+MzMmrYxEriCcNB6iorMBdLH5bBKtGoyR9dOyTM8I9ySXO
# 0RItBvLEbRqWiucj+hn2in8A5Vb/Gje396J6pFXZRnKJeNdFPQm8MnoD9xu9bBMd
# GrYbU+02q2CLcign74OrDQae0eUYN7nFvAWA3bvZoSnTT6wTNYlqdFAkSYp348MZ
# 9m+Wep5Rld8MmA3VTiBT/EaVsdDvvfHRtbzD3jtDtOmSX9rDisr9hyVUUyq5GHJD
# mHNZAZu6a4gFusf+oJyIOQYhFZQifXiJcumLWX/DksvW/TBHItsPq8EjVvLk4iC8
# 14xCpeOa4wjoly0S8md3ZhmwJ1rkGJfK3VvGRsWz/bpg2pIBgY6TRUxI50551lD3
# UT8zyeQFxmoO/Ly+w93xTd1MjYL5P475zWaaTw5Tfq9ppyjzgymDPpha/e6Ejcln
# 3w3l2brRNeqKmJ5Do/cUKP/hLbzDnqr9rgQHwubNaQjYBrcsPvkM8Af5SuquSzSP
# hp+bppQk4Ppmj1f91avm5Yh8yHCyM2J4NjKYeQgX
# SIG # End signature block
