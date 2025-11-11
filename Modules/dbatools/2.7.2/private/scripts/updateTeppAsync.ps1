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
# MIIt3AYJKoZIhvcNAQcCoIItzTCCLckCAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAMUoWyM3Zh7OqE
# /ci5Y0gAnGF/mRUj9vLGOpEWWanyEqCCFdswggbXMIIEv6ADAgECAhMzAAUcRKhb
# XX8fIZY5AAAABRxEMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjUwODIyMTEzNTAzWhcNMjUwODI1
# MTEzNTAzWjBXMQswCQYDVQQGEwJVUzERMA8GA1UECBMIVmlyZ2luaWExDzANBgNV
# BAcTBlZpZW5uYTERMA8GA1UEChMIZGJhdG9vbHMxETAPBgNVBAMTCGRiYXRvb2xz
# MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEArfBsHtCw2dEl9Gan980W
# lCGfkXIZoPtPF5FagUC0LjxgCDRLZN0JRC2axWg1/CIrYcz0feRNyDrfrjF5M/Tl
# Zq60hduT3cs8BPylvAXMxlkluLoDTEBp1+ZBHFd+73o9rRR5z4c8y5VSAzEC/ZXY
# ISJfZbFDpkgJNlB5OHHWeypzv5Ez3wBjLVCSJPJakQD8514vfbXMZGLM5zoZgN9Q
# yLhlG+9shOIQ344xqNfSDNwEM/jzTeX8ePKv2RwMA+a7jRsMqVaBQMrswblc5aku
# iM5pTdZo8Kuwi1Hh+2BapwjRGaHdKjGI1XNu4XWqHdldHn4w47IAIUEj0D/WcjFd
# 5oa/vkPurN5iCCSiUoGOLmEl4g0R9G8bv7Syp9TPolwcZuRub0SkU6Wj2ZRFkADk
# DXo6X6sSPSVaVRMEIwuTGIVtPjc0UhSB3AwVkzWmXuNsuCdkamO1PQsjCUHoSyKn
# Gn2XQXZ0hEEN2aBzWfhf7ala+f7R4YV+TbQe6ndl39wLAgMBAAGjggIXMIICEzAM
# BgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA6BgNVHSUEMzAxBgorBgEEAYI3
# YQEABggrBgEFBQcDAwYZKwYBBAGCN2H5+cEspPS4DoOuxLIcm56wGDAdBgNVHQ4E
# FgQUoCqTdEgBTOeT92HGay3oVjYbhMMwHwYDVR0jBBgwFoAU6IPEM9fcnwycdpoK
# ptTfh6ZeWO4wZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIw
# QU9DJTIwQ0ElMjAwMS5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQGCCsGAQUFBzAC
# hlhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29m
# dCUyMElEJTIwVmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3J0MC0GCCsG
# AQUFBzABhiFodHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwZgYDVR0g
# BF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEE
# ATANBgkqhkiG9w0BAQwFAAOCAgEAVyT7XXJqstnpv+oYnxt5SLX4jo0BytlVsdzr
# sh70h1C6jh73ii3Nkupu2BXDO+yexevdZ5gpZuapAu1Pm6JlsOHjOHT05ArF8nuW
# kuBsV7DDkajgnuRU5Co9irH6FYpr3zBwC6J8zwjxDv1+JjeApis/wFpGziwby1GS
# F9Jb13uBxSe+Qda9OZTuboOu4RZ2HHCYYnM0LhXkYievUngRnZLfB4ryvoqi1/Di
# fXuWBHHgwWXQk7z6GWuSFumjzf7Ezk5NGCjqZG+iTv4v6B+ojVwnCHLLXenDc9sU
# W91fcJcErVxNw/W4Sz1oKqufhD8sxh7/6lJMtOWcVa48udTnlLVp+31JEyLoTSqU
# oTYAfQGzJLYhjgBJXvdUKe8dZ6peRkj89BkNhLOBvt9Jv6NYqL0IH/+rXCAdSY2K
# rgW46tEI2cjusSMcYuOWek/WDbCoDrcuERfJFWkMYL9LU8Mgh2OVgFTVD+XS+Z6R
# EOIeRW4jUk1MTalr9TPpf+wSROe/EWkRINSzuYYcS7GlipN41lFIwaquvUenySBJ
# 1eMhabePKsc3TpPSukw/i+xLHxFo6SnCR5ScFQIb6oRBDQJy2kvjREZtl96Tl/4n
# juTeeBubXiIhTNhljWAwe5cznHZlQ1QdbQ0gWOa9fsec9B7R2jmFZlLSHmwhSgAs
# F+wJsZcwggdaMIIFQqADAgECAhMzAAAABzeMW6HZW4zUAAAAAAAHMA0GCSqGSIb3
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
# avFIrmcxghdXMIIXUwIBATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmll
# ZCBDUyBBT0MgQ0EgMDECEzMABRxEqFtdfx8hljkAAAAFHEQwCwYJYIZIAWUDBAIB
# oHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBqn
# gERnk2TIM81huI9q2/Jca3jHapPD+lnPFn9/3BxfMAsGCSqGSIb3DQEBAQSCAYCq
# K94u2vQFVSgn7PuDisjJfeXLCLbGWn5PWfkMX4atP5TF0ItcXEeP0HTtTGMcuWe2
# T791SqgjO8QgjMO+NcEs0w1F9SsTn6zrEBzZLWljMPf0udgloBmr+n41d6bBcLH2
# YU98wJAqqkOcDjCiDqbv+C5Ve6KAfH9VaN6qp4idsb4iQWTWTEWyegxPIaecCD0u
# OCezHipFjP8YqiO/FRC6aYFoYSXnyDR0H8Ybb/wCJxQlwDaNieS0kCpknr5mDS+D
# qK2TNHf8O4JcBe1D1WvGzeZO677UEBRb8w8cwlSsW79Q4qtKeITjznshFCZERsDc
# lwFS9PB2mbaVqgSYfqG0hkZHsGnFwzFLBfx4YfG3BCXlZeJxthljTe+/zAx8Q/X0
# ajb3CgOfZKOyOqUdsxiuwolVE6ZW7PCsyeg/40Y6otBWx1/FQTjjbZYOUZw6/6HH
# ZuEarpFKk1SiHTk0aKs3x+/TnUmqYM/PsRbjebUN+ncbZoFk3TWc4rHyeyBCmBKh
# ghS9MIIUuQYKKwYBBAGCNwMDATGCFKkwghSlBgkqhkiG9w0BBwKgghSWMIIUkgIB
# AzEPMA0GCWCGSAFlAwQCAQUAMIIBdQYLKoZIhvcNAQkQAQSgggFkBIIBYDCCAVwC
# AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQgpyL0LwCDUDR8Gr6+0p7Z
# N1QrJdLPMJdEEzG+HyOrVw4CBmieUTWP8BgTMjAyNTA4MjMxMTI3NDUuMTE4WjAE
# gAIB9AIJAOm2nY4Jbzc+oIHppIHmMIHjMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRp
# b25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo3QTFBLTA1RTAt
# RDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGlu
# ZyBBdXRob3JpdHmggg8pMIIHgjCCBWqgAwIBAgITMwAAAAXlzw//Zi7JhwAAAAAA
# BTANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9NaWNyb3NvZnQgSWRlbnRpdHkgVmVy
# aWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMjAwHhcNMjAx
# MTE5MjAzMjMxWhcNMzUxMTE5MjA0MjMxWjBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBAJ5851Jj/eDFnwV9Y7UGIqMcHtfnlzPREwW9ZUZHd5HBXXBv
# f7KrQ5cMSqFSHGqg2/qJhYqOQxwuEQXG8kB41wsDJP5d0zmLYKAY8Zxv3lYkuLDs
# fMuIEqvGYOPURAH+Ybl4SJEESnt0MbPEoKdNihwM5xGv0rGofJ1qOYSTNcc55EbB
# T7uq3wx3mXhtVmtcCEr5ZKTkKKE1CxZvNPWdGWJUPC6e4uRfWHIhZcgCsJ+sozf5
# EeH5KrlFnxpjKKTavwfFP6XaGZGWUG8TZaiTogRoAlqcevbiqioUz1Yt4FRK53P6
# ovnUfANjIgM9JDdJ4e0qiDRm5sOTiEQtBLGd9Vhd1MadxoGcHrRCsS5rO9yhv2fj
# JHrmlQ0EIXmp4DhDBieKUGR+eZ4CNE3ctW4uvSDQVeSp9h1SaPV8UWEfyTxgGjOs
# RpeexIveR1MPTVf7gt8hY64XNPO6iyUGsEgt8c2PxF87E+CO7A28TpjNq5eLiiun
# hKbq0XbjkNoU5JhtYUrlmAbpxRjb9tSreDdtACpm3rkpxp7AQndnI0Shu/fk1/rE
# 3oWsDqMX3jjv40e8KN5YsJBnczyWB4JyeeFMW3JBfdeAKhzohFe8U5w9WuvcP1E8
# cIxLoKSDzCCBOu0hWdjzKNu8Y5SwB1lt5dQhABYyzR3dxEO/T1K/BVF3rV69AgMB
# AAGjggIbMIICFzAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQAwHQYD
# VR0OBBYEFGtpKDo1L0hjQM972K9J6T7ZPdshMFQGA1UdIARNMEswSQYEVR0gADBB
# MD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0Rv
# Y3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGC
# NxQCBAweCgBTAHUAYgBDAEEwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTI
# ftJqhSobyhmYBAcnz1AQT2ioojCBhAYDVR0fBH0wezB5oHegdYZzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSWRlbnRpdHkl
# MjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3JpdHkl
# MjAyMDIwLmNybDCBlAYIKwYBBQUHAQEEgYcwgYQwgYEGCCsGAQUFBzAChnVodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElk
# ZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRpZmljYXRlJTIwQXV0
# aG9yaXR5JTIwMjAyMC5jcnQwDQYJKoZIhvcNAQEMBQADggIBAF+Idsd+bbVaFXXn
# THho+k7h2ESZJRWluLE0Oa/pO+4ge/XEizXvhs0Y7+KVYyb4nHlugBesnFqBGEdC
# 2IWmtKMyS1OWIviwpnK3aL5JedwzbeBF7POyg6IGG/XhhJ3UqWeWTO+Czb1c2NP5
# zyEh89F72u9UIw+IfvM9lzDmc2O2END7MPnrcjWdQnrLn1Ntday7JSyrDvBdmgbN
# nCKNZPmhzoa8PccOiQljjTW6GePe5sGFuRHzdFt8y+bN2neF7Zu8hTO1I64XNGqs
# t8S+w+RUdie8fXC1jKu3m9KGIqF4aldrYBamyh3g4nJPj/LR2CBaLyD+2BuGZCVm
# oNR/dSpRCxlot0i79dKOChmoONqbMI8m04uLaEHAv4qwKHQ1vBzbV/nG89LDKbRS
# SvijmwJwxRxLLpMQ/u4xXxFfR4f/gksSkbJp7oqLwliDm/h+w0aJ/U5ccnYhYb7v
# PKNMN+SZDWycU5ODIRfyoGl59BsXR/HpRGtiJquOYGmvA/pk5vC1lcnbeMrcWD/2
# 6ozePQ/TWfNXKBOmkFpvPE8CH+EeGGWzqTCjdAsno2jzTeNSxlx3glDGJgcdz5D/
# AAxw9Sdgq/+rY7jjgs7X6fqPTXPmaCAJKVHAP19oEjJIBwD1LyHbaEgBxFCogYSO
# iUIr0Xqcr1nJfiWG2GwYe6ZoAF1bMIIHnzCCBYegAwIBAgITMwAAAFNSwgOL5Zr4
# TgAAAAAAUzANBgkqhkiG9w0BAQwFADBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGlj
# IFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDAeFw0yNTAyMjcxOTQwMjZaFw0yNjAy
# MjYxOTQwMjZaMIHjMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo3QTFBLTA1RTAtRDk0NzE1MDMGA1UE
# AxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHkw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCXOSn6L/MK7VDnekzGNs0X
# qqHB0czxIKpnZAI1P+3xYzKHepGcRdg9OvMwLzc73F/pyJz+4zdxStivUenadt3j
# T2Fwzv0sYnX6N3SsfWDibuAZi5gdHEoicXtToZxbgmH+XMLMGWbQNjax669P8UnB
# UXg/Vbs4zVX7XxBrwW8HaXFuH6zmIkcFNGjMRjSn0DRE+TbuCjCIwDU416gEc8V5
# 2T4f8HVF28EQiPERlHRe3k1Dcy//az5s3z0ia3t60PkMwfU9smSx+rX/XEjpCW6K
# vilIEvLV6I4Qk5XcafdIGIPBTzYYKg5AQNo9vaXhqakIWYWzD6B741aNi8Mi8I+d
# ea8Tv1sT2tmyiwsYyCB2RhKJpDlEXccFFPVqXO1lgoRYYspZ3Pi0otni8OZN7bV0
# ObWg12qjmqEQ2AGfuMav5vKir/HmLE0S8ijJBsEIvlasNLug6g/jvULlakCNKobX
# BAsiMT/XWDHChXnZouyhxiSKLsJuv7mrcJ2xO5TduBGkM6ldTq3g8j9bRAyoSXq4
# P7EJUSjQ1XJk0SFGVU1aJjJWUAPTRviyZHuIYBbLfXh39Hsf3loNPDIrXJTL6+CI
# tkHtWdrrK5xOBu6Kva1I2R+ksM/W+6hV/cL1RTxATfEqcF/bCnH+NGwxM4rwD4Hs
# rak5kjIjYdUD4jKUId7OQQIDAQABo4IByzCCAccwHQYDVR0OBBYEFG5kRKsjYxof
# BbNCPSHW9GT/9o9qMB8GA1UdIwQYMBaAFGtpKDo1L0hjQM972K9J6T7ZPdshMGwG
# A1UdHwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENB
# JTIwMjAyMC5jcmwweQYIKwYBBQUHAQEEbTBrMGkGCCsGAQUFBzAChl1odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFB1Ymxp
# YyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcnQwDAYDVR0TAQH/
# BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwZgYD
# VR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeB
# DAEEAjANBgkqhkiG9w0BAQwFAAOCAgEAiHP/ZU8yUtIadMSan32pDcYZSfGFusAx
# s9/VivZs+jLrHeXGneLdhI43te0wCiZsEMDhICzE/HxjYbwiL3lzm5rOLA7htAsB
# uUYmyHX7SVmHOgBDHM4jkw+myrcXe37wIeHolRqTy7cwmxxU9g0r+Q9AAnT8d12T
# 438BUSgFYiMjLS/9m22Y617uVizIV0+a4vvgW4uRDtsoHoBZAAfgEaA4NKxuT3bg
# 1enWJlTaB1XQDJlwtih8qyKx8NSdmzxsAu3BSAc9YW5X6WLm+dtRQKZnR5rlPOft
# CflceMpV4PMtP6cEHHoYw9FRoRN8hYLzw5cDHmOIxXiOezYocWMzDj3VSRyKPe9T
# vkzrG2qI15nt7xHSeemqXb4s3Ku+ZgJWM/TKb5CVBmzK8soo6I/f1BsrErtjyXmX
# EYnDEXY3YKYSC1hlVqkEqPQ4p5cYMS/iQD90kYE6VI4oK5wgedeUMEUg7AxUytEW
# qGtrgkErD5glMixzgVq5KAlzj61yRo7riqSMdVYrWcuv3FeZWhhrL7mOo67rcjrh
# poXVHi5MKVbm4KaCxhCfnPjLa4CA0qYGbhSAYpjUPfGwAqs4ix8hGh1E0iY4wW6g
# 19GNWnIjOr9PWrBbFqu9oEVchWcNg3tdsChcYvDJ1/uKTTpoJAsFyC3ML/NDneOO
# pr4tQTmo6I0xggPUMIID0AIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMg
# UlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAU1LCA4vlmvhOAAAAAABTMA0G
# CWCGSAFlAwQCAQUAoIIBLTAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEIHheQBGZ9i+HRKvijBfqAehi24bHYlIWGO9gNOfoiNolMIHd
# BgsqhkiG9w0BCRACLzGBzTCByjCBxzCBoAQgQH8fBGKMq5T++MBTsF0cGn+0dF+t
# Ew+Q16OV0Z/aHSMwfDBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0Eg
# VGltZXN0YW1waW5nIENBIDIwMjACEzMAAABTUsIDi+Wa+E4AAAAAAFMwIgQg2cFn
# Kjua1Uai4R8qelHX7/GkFVqSyU3zHpOQ71gEyPQwDQYJKoZIhvcNAQELBQAEggIA
# iInQHsupIcVE60kgK0TPMYagq14O2XGH6V9s9sWkaywSOpsgnL3Aw6tPEA+lLvop
# v1nKCL8tYLzloIVqMGsBck0On+vozOzhAkScUM4ecVXFKjSYDdpSsWbM39SQu6rw
# 75ql2vMNy2Z6ns3zOpUEmkab2kY0OFblgkIhAIU9bs80V3rBeNx2T7RaYXet0Gk3
# cBkce5KkJbn1sK2/5fMWKIIMbkbLNYAElXz6HCBSrh1vkA6T1C9rzGWpL4pFDiBf
# 9hi6fmd431CE5O2iaNLVA0TmqiNwMi76uB/w0Z5vx5am1SvgrbFwtriNhpfHuZ/h
# zUHefOSKCruGrEEqJCDc4B60YuSo6GsC3nphAcsry2w70e5dHWUzCfqA4jIkw982
# cETZWyxzvvtjHomboBwCM9YqSCGfbRFMiOAf62rDwZGYBerw04kN83sgsWKQBqoQ
# qmfP+CO+2uBmSDkkHDD5cgG6hE7JK5ow9Q11tBNrqbjOtuYdSUdmga7aN3abCcNu
# V77M2eUtKcFuwZdwLc+Y9mmHL6BH3qteueW9hLMSXj0IE0asXyDWbVK5ZewIZu4g
# VeOmeN7QlV9/mQC7E5d94MN2Gw/Y+GnqMsO8AFk0WjtzAYuKpdJxjYVS6eBjJJsD
# jA+6p/il+oOUwWK4rk0r19too6sz3Z5M3tP+AcPZ+jk=
# SIG # End signature block
