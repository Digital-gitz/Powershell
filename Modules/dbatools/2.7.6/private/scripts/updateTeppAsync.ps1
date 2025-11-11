if (-not ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppAsyncDisabled -or [Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppDisabled)) {
    $scriptBlock = {
        $script:___ScriptName = 'dbatools-teppasynccache'

        # Defer module import to avoid collisions and reduce CPU impact
        Start-Sleep -Seconds 15
        $dbatoolsPath = Join-Path -Path ([Dataplat.Dbatools.dbaSystem.SystemHost]::ModuleBase) -ChildPath "dbatools.psd1"
        Import-Module $dbatoolsPath
        $script:dbatools = Get-Module dbatools

        #region Utility Functions
        function Get-PriorityServer {
            [Dataplat.Dbatools.TabExpansion.TabExpansionHost]::InstanceAccess.Values | Where-Object -Property LastUpdate -LT (New-Object System.DateTime(1, 1, 1, 1, 1, 1))
        }

        function Get-ActionableServer {
            [Dataplat.Dbatools.TabExpansion.TabExpansionHost]::InstanceAccess.Values | Where-Object -Property LastUpdate -LT ((Get-Date) - ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppUpdateInterval)) | Where-Object -Property LastUpdate -GT ((Get-Date) - ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppUpdateTimeout))
        }

        function Update-TeppCache {
            [CmdletBinding()]
            param (
                [Parameter(ValueFromPipeline)]
                $ServerAccess
            )
            process {
                if ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppUdaterStopper) { break }

                foreach ($instance in $ServerAccess) {
                    if ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppUdaterStopper) { break }
                    $server = New-Object Microsoft.SqlServer.Management.Smo.Server($instance.ConnectionObject)
                    try {
                        $server.ConnectionContext.Connect()
                    } catch {
                        & $script:dbatools { Write-Message "Failed to connect to $instance" -ErrorRecord $_ -Level Debug }
                        continue
                    }

                    $FullSmoName = ([Dataplat.Dbatools.Parameter.DbaInstanceParameter]$instance.ConnectionObject.ConnectionString).FullSmoName.ToLowerInvariant()

                    foreach ($scriptBlock in ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppGatherScriptsFast)) {
                        $scriptName = ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::Scripts.Values | Where-Object ScriptBlock -EQ $scriptBlock).Name
                        # Workaround to avoid stupid issue with scriptblock from different runspace
                        try { [ScriptBlock]::Create($scriptBlock).Invoke() }
                        catch { & $script:dbatools { Write-Message "Failed to execute TEPP $scriptName against $FullSmoName" -ErrorRecord $_ -Level Debug } }
                    }

                    foreach ($scriptBlock in ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::TeppGatherScriptsSlow)) {
                        $scriptName = ([Dataplat.Dbatools.TabExpansion.TabExpansionHost]::Scripts.Values | Where-Object ScriptBlock -EQ $scriptBlock).Name
                        # Workaround to avoid stupid issue with scriptblock from different runspace
                        try { [ScriptBlock]::Create($scriptBlock).Invoke() }
                        catch { & $script:dbatools { Write-Message "Failed to execute TEPP $scriptName against $FullSmoName" -ErrorRecord $_ -Level Debug } }
                    }

                    $server.ConnectionContext.Disconnect()
                    $instance.LastUpdate = Get-Date
                }
            }
        }
        #endregion Utility Functions

        try {
            #region Main Execution
            while ($true) {
                # This portion is critical to gracefully closing the script
                if ([Dataplat.Dbatools.Runspace.RunspaceHost]::Runspaces[$___ScriptName.ToLowerInvariant()].State -notlike "Running") {
                    break
                }

                Get-PriorityServer | Update-TeppCache
                Get-ActionableServer | Update-TeppCache
                Start-Sleep -Seconds 5
            }
            #endregion Main Execution
        } catch {
            & $script:dbatools { Write-Message "General Failure" -ErrorRecord $_ -Level Debug }
        } finally {
            [Dataplat.Dbatools.Runspace.RunspaceHost]::Runspaces[$___ScriptName.ToLowerInvariant()].SignalStopped()
        }
    }

    Register-DbaRunspace -ScriptBlock $scriptBlock -Name "dbatools-teppasynccache"
    Start-DbaRunspace -Name "dbatools-teppasynccache"
}
# SIG # Begin signature block
# MIIt2gYJKoZIhvcNAQcCoIItyzCCLccCAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAMUoWyM3Zh7OqE
# /ci5Y0gAnGF/mRUj9vLGOpEWWanyEqCCFdswggbXMIIEv6ADAgECAhMzAARmjSb9
# sTLDSn/xAAAABGaNMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBFT0MgQ0EgMDIwHhcNMjUwOTE5MTAwMDM1WhcNMjUwOTIy
# MTAwMDM1WjBXMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExDzANBgNV
# BAcTBlZpZW5uYTERMA8GA1UEChMIZGJhdG9vbHMxETAPBgNVBAMTCGRiYXRvb2xz
# MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAiOVHdBbSwMZBu5PSJY53
# rYtr1w4vun+xEx2IaYqH4uUbnVUlRhQcSTD5tIG5cGfQ7ZdMYEhM999Doex1upRj
# NmeIdk8JuDzvJ9ccbL2s/pEJ9dwmAYxJoSqK262d+5KtFsTzBz6xLHvwEAp9LUKd
# ugYjRnjTAhii84WgN1+4DSa2QIvwokpGSCjy9tnu3CtWjdG52lfsxRmG2Qm13MbK
# +haw6WAIJQ2lq0k0QlLEdgExqrIh/1sUyWAQ2LdxCJt9+hIVWP9vwkORvKr5bty0
# U3Qg0x7BZIaE7Hc7GbMwQea39TKP7xs/0ZRYuwKc+0WHcxwm6q/iGXQn7hEYNeKE
# zod/KOXvAqfCLznsde9bQZX4vB+81V2vEFeaWyBGmp8waLGTDrBy1AoGH2muTqVI
# YuNyUx/Dsr7zTivzczTZvPwlXFLAAGJdVsC0gHOXE2tzi1wnbqPlQIlEOepF9qvk
# NF5L2RqXmPhtPAZvwELP81lX9AhSxmm8ifA/7SHigd2lAgMBAAGjggIXMIICEzAM
# BgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA6BgNVHSUEMzAxBgorBgEEAYI3
# YQEABggrBgEFBQcDAwYZKwYBBAGCN2H5+cEspPS4DoOuxLIcm56wGDAdBgNVHQ4E
# FgQUPTnBhklIsdQYAYJXTyD0dlGYIh4wHwYDVR0jBBgwFoAUZZ9RzoVofy+KRYiq
# 3acxux4NAF4wZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIw
# RU9DJTIwQ0ElMjAwMi5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQGCCsGAQUFBzAC
# hlhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29m
# dCUyMElEJTIwVmVyaWZpZWQlMjBDUyUyMEVPQyUyMENBJTIwMDIuY3J0MC0GCCsG
# AQUFBzABhiFodHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwZgYDVR0g
# BF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEE
# ATANBgkqhkiG9w0BAQwFAAOCAgEAIoA0MNrmqFDfQsBZyq7hgRieVl+/+y2Nndyk
# to6SQiPwGvfPqm1J/JGcE98IABlYlcJOuMOLbEHdR0JaJzA6V2nER+GMyjFs08Gf
# Z9CwZOB0CWz4riTGe9fe5+rCfotDyMtP4J6FM8X9R82ROWgSEiKYe81hjw8K1/5Q
# GpU75/sjwKeA7NJmGEhUvA8ZEmidIMh0EPk4nNLvo56J93ZojTSeeUWpFdRyoNvy
# KDiweAM+Zd+neVUpMToqll0AhP5WENvUBBIy/Aqq9BVOx8by9HrFGlvRHMy0aO62
# K/RnR8g2P7fQUok7QPYCA5Aj47fcuuiNQmTSbK+Q2HG6bqLLm626rEToaNnN965M
# YW4sog/stcocbN3fFJpXja9DDVv3/zZnAw0d4P24ggjDIOXUSaK69ryRpSMA9Msa
# 4uNlChyP35QKgVvsCUPyVMVRU9aMhKUFVe+WmDUDJmuxEKP/iQy9MFP8nUL08tg2
# LLMi4hcFiOUXV8blO6rur7FHU8cpYp9Vj0+mvGq66C1/ouhZR7lNPGruPrbAU4VB
# oCzWhZbpVWD6mn2StWE/J8R+3k62StVjGH4LjV027qRJ+Lt8l3/FJL8Hryg6AKTh
# DHVtuQq/CMUAmZL/hVCs7iYdZCd/udXJL+vSOVaspBUMZ2hnw1FpWHhZu33m+NSj
# BtHRZ4MwggdaMIIFQqADAgECAhMzAAAABft6XDITYd9dAAAAAAAFMA0GCSqGSIb3
# DQEBDAUAMGMxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xNDAyBgNVBAMTK01pY3Jvc29mdCBJRCBWZXJpZmllZCBDb2RlIFNpZ25p
# bmcgUENBIDIwMjEwHhcNMjEwNDEzMTczMTUzWhcNMjYwNDEzMTczMTUzWjBaMQsw
# CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSswKQYD
# VQQDEyJNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ1MgRU9DIENBIDAyMIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0hqZfD8ykKTA6CDbWvshmBpDoBf7Lv13
# 2RVuSqVwQO3aALLkuRnnTIoRmMGo0fIMQrtwR6UHB06xdqOkAfqB6exubXTHu44+
# duHUCdE4ngjELBQyluMuSOnHaEdveIbt31OhMEX/4nQkph4+Ah0eR4H2sTRrVKmK
# rlOoQlhia73Qg2dHoitcX1uT1vW3Knpt9Mt76H7ZHbLNspMZLkWBabKMl6BdaWZX
# YpPGdS+qY80gDaNCvFq0d10UMu7xHesIqXpTDT3Q3AeOxSylSTc/74P3og9j3Oue
# mEFauFzL55t1MvpadEhQmD8uFMxFv/iZOjwvcdY1zhanVLLyplz13/NzSoU3QjhP
# dqAGhRIwh/YDzo3jCdVJgWQRrW83P3qWFFkxNiME2iO4IuYgj7RwseGwv7I9cxOy
# aHihKMdT9NeoSjpSNzVnKKGcYMtOdMtKFqoV7Cim2m84GmIYZTBorR/Po9iwlasT
# YKFpGZqdWKyYnJO2FV8oMmWkIK1iagLLgEt6ZaR0rk/1jUYssyTiRqWr84Qs3XL/
# V5KUBEtUEQfQ/4RtnI09uFFUIGJZV9mD/xOUksWodGrCQSem6Hy261xMJAHqTqMu
# DKgwi8xk/mflr7yhXPL73SOULmu1Aqu4I7Gpe6QwNW2TtQBxM3vtSTmdPW6rK5y0
# gED51RjsyK0CAwEAAaOCAg4wggIKMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEEAYI3
# FQEEAwIBADAdBgNVHQ4EFgQUZZ9RzoVofy+KRYiq3acxux4NAF4wVAYDVR0gBE0w
# SzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3FAIEDB4KAFMA
# dQBiAEMAQTASBgNVHRMBAf8ECDAGAQH/AgEAMB8GA1UdIwQYMBaAFNlBKbAPD2Ns
# 72nX9c0pnqRIajDmMHAGA1UdHwRpMGcwZaBjoGGGX2h0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBD
# b2RlJTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3JsMIGuBggrBgEFBQcBAQSBoTCB
# njBtBggrBgEFBQcwAoZhaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# ZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ29kZSUyMFNpZ25pbmcl
# MjBQQ0ElMjAyMDIxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29uZW9jc3AubWlj
# cm9zb2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQBFSWDUd08X4g5HzvVf
# rB1SiV8pk6XPHT9jPkCmvU/uvBzmZRAjYk2gKYR3pXoStRJaJ/lhjC5Dq/2R7P1Y
# RZHCDYyK0zvSRMdE6YQtgGjmsdhzD0nCS6hVVcgfmNQscPJ1WHxbvG5EQgYQ0ZED
# 1FN0MOPQzWe1zbH5Va0dSxtnodBVRjnyDYEm7sNEcvJHTG3eXzAyd00E5KDCsEl4
# z5O0mvXqwaH2PS0200E6P4WqLwgs/NmUu5+Aa8Lw/2En2VkIW7Pkir4Un1jG6+tj
# /ehuqgFyUPPCh6kbnvk48bisi/zPjAVkj7qErr7fSYICCzJ4s4YUNVVHgdoFn2xb
# W7ZfBT3QA9zfhq9u4ExXbrVD5rxXSTFEUg2gzQq9JHxsdHyMfcCKLFQOXODSzcYe
# LpCd+r6GcoDBToyPdKccjC6mAq6+/hiMDnpvKUIHpyYEzWUeattyKXtMf+QrJeQ+
# ny5jBL+xqdOOPEz3dg7qn8/oprUrUbGLBv9fWm18fWXdAv1PCtLL/acMLtHoyeSV
# MKQYqDHb3Qm0uQ+NQ0YE4kUxSQa+W/cCzYAI32uN0nb9M4Mr1pj4bJZidNkM4JyY
# qezohILxYkgHbboJQISrQWrm5RYdyhKBpptJ9JJn0Z63LjdnzlOUxjlsAbQir2Wm
# z/OJE703BbHmQZRwzPx1vu7S5zCCB54wggWGoAMCAQICEzMAAAAHh6M0o3uljhwA
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
# ZCBDUyBFT0MgQ0EgMDICEzMABGaNJv2xMsNKf/EAAAAEZo0wCwYJYIZIAWUDBAIB
# oHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBqn
# gERnk2TIM81huI9q2/Jca3jHapPD+lnPFn9/3BxfMAsGCSqGSIb3DQEBAQSCAYBg
# z58RdjSxPjf1CvfymKm7HW13+JXw4x70RPFCaHKAISdPnoMQr9QsB2jxdTBAChfz
# ItnuDRDpmQTO3vfsbfd22WHiLEgCiVg5CqDyZWp50YJd92YO64JJMYRg/NjsD7UR
# hlcshqqgL6mE3dcamTRBYnKR021nlN5nODHa7D52sZ6DgSgO2mN8qpQSKlupU4TG
# wMNTFnUTZgMQyZgwTq+DLK7Ha5I1C1Nhm8NlQDUggInbjIJDNyuoAzXtxWBmxBjH
# luVVESzOmHcDJmvwQrgUan0X0FcavlTCX+dmkFc4tuU4JrDHzOW2RYYjNh651BZu
# xUD2OBmWN7aSLcky/SzBgJb/yMxohNKC6C3urX8enQquR8sptOSx9EnENq5o9aMg
# RqJc1oHEc1qopKSOMouyRY+DKq60QxXc7perOsIVc4xAR/RvwjGO7NR63B/jERK/
# TV9MuiPzwY0riQeHnw4R+ID6pZVedUBVMWzRYf6ApqoIHDAXB9HujEzzgT2SUQOh
# ghS7MIIUtwYKKwYBBAGCNwMDATGCFKcwghSjBgkqhkiG9w0BBwKgghSUMIIUkAIB
# AzEPMA0GCWCGSAFlAwQCAQUAMIIBcwYLKoZIhvcNAQkQAQSgggFiBIIBXjCCAVoC
# AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQgHR+4jqQ/3Z2jU5Wmfuvq
# ug1i766oLPBLBAfONgb4XDQCBmjCIqWPmhgSMjAyNTA5MTkxMTAxMTIuMjJaMASA
# AgH0AgghDSU9br6i6qCB6aSB5jCB4zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9u
# cyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0IxQS0wNUUwLUQ5
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
# K9F6nK9ZyX4lhthsGHumaABdWzCCB58wggWHoAMCAQICEzMAAABPNLUHwSuXVPwA
# AAAAAE8wDQYJKoZIhvcNAQEMBQAwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBS
# U0EgVGltZXN0YW1waW5nIENBIDIwMjAwHhcNMjUwMjI3MTk0MDE5WhcNMjYwMjI2
# MTk0MDE5WjCB4zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEt
# MCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0IxQS0wNUUwLUQ5NDcxNTAzBgNVBAMT
# LE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwmCmWsbLOhC6M+J3M2a5zVAS
# Vviz0eHoMWN9nSJIMMZE7eUVXBLho750BXaRbMzpkw9S7nEIIf+0tYhKlWKtYc7L
# TBw9545MjU8wy7D+MYaCijPU3wqFWSEYORHDOZVqWnx5z9JBLOK5jgKfo+XHaOny
# bcQ7hw1K/Weq/Vjf4OcnPCKexj5y1ZeUQlrdHN2VFwPp74e4FFcFRT9SEyGk7VhR
# A2UWE7bYKo03KW0KhhcOmLMLU+nbV+Ty45hgw7JENaAmVZwQb/wxYRtAXh0bXjZ+
# kUjJX56wNY8yffl0HcnBntuBsm//ojmc04axiOqPM3de78WQBi4EvP5dgRej3K+2
# tabV/KUSXnYS7ulvxyYja7z1M+ohPSBJ2r2jwvQNlPvEAszkSrebqvXu6XadryLx
# ctreIt8DMQ97WuP+iDdIdVmhyIe9sXNGSN4WguzK39J0ZwzAQF7X3a+VYnU5cij/
# 8BdBuFxb5q+DPlMzI89Z4kSePOA2tmPLhysQkGsdz6DVu51G8GaPzX7B4UwGS14v
# T8CRnNV6oIekipZDgF5icbpGdzk/xp4VAQPCD/Dt3uEhXBstOjUvWZGP53FWBRi9
# wD3EwniGrKyP4D0ii8oHdNDlHYAicNFoJGQ1jJqYW/wEae+mA1DzDkmLLtT5gcwr
# VIpKjifmNyxAaltCpSECAwEAAaOCAcswggHHMB0GA1UdDgQWBBS/otO37Pxmnnm2
# R0jR7odURuo3MDAfBgNVHSMEGDAWgBRraSg6NS9IY0DPe9ivSek+2T3bITBsBgNV
# HR8EZTBjMGGgX6BdhltodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUy
# MDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0wazBpBggrBgEFBQcwAoZdaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBQdWJsaWMl
# MjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3J0MAwGA1UdEwEB/wQC
# MAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeAMGYGA1Ud
# IARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAIBgZngQwB
# BAIwDQYJKoZIhvcNAQEMBQADggIBADazNodUNiVhVdK51WV2Eb3iPz2XW3rf76Cy
# 27kqn+0xGmIO5s/xg3l7YSXaEorO8JXoHyhhLpt+nQBTry4Ih9hpSGAXJzFQjBhO
# NVLm4wTiO6bu8F+zrodhYrNMMiEgFpDEC5WiKrm7c9NZYdzs006V7g1itVPft98A
# nKxp/BvqBqX3BKltnWBawJN7jEA4a62BVtvb7ywY25ygTcgjLDIAfkRt182R7rd8
# UA6jH5WQ93berfIxgWVRWXeQcExKR6alb8oaWg1iaOHcYRHWOsNODID2qz1yJSQD
# yFzuU21mIHHh2OkwnID9wto1s1tRKxdj/o9cF28cE/o1acqKEkCU6ImvXgzijlJC
# RCelKEcHAhyeIt9uhBWQ7jmKPyryPaemDKMY/WvGcluH6FCASD1Q0Bykq3jiaJqE
# i5E7McCiejaPhw8fqaEh6kITMVFmIX9Xcz2pH+XHWjXHi+lCcatjUf18UalP6QKo
# ocMR29d0EDOvmrerIo0h8ORR3+IT3Iz6qCsqwOvJx15Tm0Z4HEH7SDRd9dUUaaJF
# PJ1pQT8SNyvksCzi7d3mKwNy7VhK/D3o+1a6pnGksw5HhgJzM2y795gD9UB1aJtw
# Yglsa1J/eKiVAjrANqGxLEXvOUdXIEIObQJqgTPbMU0V5oEzG5F3KjBIsWLOW86S
# lxZ3d/FkMYID1DCCA9ACAQEweDBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGljIFJT
# QSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAAE80tQfBK5dU/AAAAAAATzANBglg
# hkgBZQMEAgEFAKCCAS0wGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqG
# SIb3DQEJBDEiBCCVvLulXbcijYzxw+Ol3tW2pCURw3XRghWUNspz0OUdHTCB3QYL
# KoZIhvcNAQkQAi8xgc0wgcowgccwgaAEIEFmK0YPkh60cq0douR9sQ12gnOMVyDQ
# NoCykuAvguoOMHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRp
# bWVzdGFtcGluZyBDQSAyMDIwAhMzAAAATzS1B8Erl1T8AAAAAABPMCIEIOmtVVxt
# QG2DghwCwzwKxskO7oNqWmEGgtoy0Tpr+TO1MA0GCSqGSIb3DQEBCwUABIICAE36
# ny7J1NYfvte4pIJKHzidhhMyHzjsP1sKWjyQz/5+8BwbVOCB7LvYER76voZ6d59U
# 8fIOR/N+lhqkWL7Sa1HwrvHYtDfZ29WaRlzEvJvwDt3x/4uFLfQhNaUIJysqyP/q
# UhaNZfhLU0wTe26uzo9k79QP2QDSCeCgZs9Jj10FDKxlDegRISjxvuaJ8bZoyIb1
# AlD4uQQbSH2usSjHj6tVF+0vFztV9wMd1wE2xKfdbLRJeKj7sVwygTboestdZcd5
# kNEdoksvLztjCiZw+mzkkrpyrHPMUA56vcPkf/zXC5c2LV6Px3KnkMDeQNj4pDBT
# G54j4+AlSuYx6tjIRYXq/yhDXR38a788nLNWaOO+/kTs7keus7EPinTprDQrD1wH
# BHjCFYZC5Mkmkl5L8i5duXjuleYa6UR3JsXpuMxbbzv4VbgQ/+r90qhxeU3dnCKR
# p8qDfVQ7nQ6ay+ffn10gOfDsCPNp5eQf4npXnBu6dQBFVkK0+Jo+Y15UuWXJ1hu6
# WjzEoB+d1KKbvYJqAcm+Bcr++GOV9aKZV3ro3kZHneZCJfR08bgYWMeVm0I6hb/T
# j6Bq5UePri8FTHxlR1TrtqygvvY1sNCCcocyMq/YljsQxIZS8tUAPsR27iFplWbF
# 9Dtq1pIcEqZh/2cRmwpdHOo7u7JN2kI6DJh2WO4E
# SIG # End signature block
