$scriptBlock = {
    $script:___ScriptName = 'dbatools-logging'

    #region Helper Functions
    function Clean-ErrorXml {
        [CmdletBinding()]
        param (
            $Path
        )

        $totalLength = $Null
        $files = Get-ChildItem -Path $Path.FullName -Filter "dbatools_$($pid)_error_*.xml" | Sort-Object LastWriteTime
        $totalLength = $files | Measure-Object Length -Sum | Select-Object -ExpandProperty Sum
        if (([Dataplat.Dbatools.Message.LogHost]::MaxErrorFileBytes) -gt $totalLength) { return }

        $removed = 0
        foreach ($file in $files) {
            $removed += $file.Length
            Remove-Item -Path $file.FullName -Force -Confirm:$false

            if (($totalLength - $removed) -lt ([Dataplat.Dbatools.Message.LogHost]::MaxErrorFileBytes)) { break }
        }
    }

    function Clean-MessageLog {
        [CmdletBinding()]
        param (
            $Path
        )

        if ([Dataplat.Dbatools.Message.LogHost]::MaxMessagefileCount -eq 0) { return }

        $files = Get-ChildItem -Path $Path.FullName -Filter "dbatools_$($pid)_message_*.log" | Sort-Object LastWriteTime
        if (([Dataplat.Dbatools.Message.LogHost]::MaxMessagefileCount) -ge $files.Count) { return }

        $removed = 0
        foreach ($file in $files) {
            $removed++
            Remove-Item -Path $file.FullName -Force -Confirm:$false

            if (($files.Count - $removed) -le ([Dataplat.Dbatools.Message.LogHost]::MaxMessagefileCount)) { break }
        }
    }

    function Clean-GlobalLog {
        [CmdletBinding()]
        param (
            $Path
        )

        # Kill too old files
        Get-ChildItem -Path "$($Path.FullName)\*" -Include "*.xml", "*.log" -Filter "*" | Where-Object LastWriteTime -LT ((Get-Date) - ([Dataplat.Dbatools.Message.LogHost]::MaxLogFileAge)) |Remove-Item -Force -Confirm:$false

        # Handle the global overcrowding
        $files = Get-ChildItem -Path "$($Path.FullName)\*" -Include "*.xml", "*.log" -Filter "*" | Sort-Object LastWriteTime
        if (-not ($files)) { return }
        $totalLength = $files | Measure-Object Length -Sum | Select-Object -ExpandProperty Sum

        if (([Dataplat.Dbatools.Message.LogHost]::MaxTotalFolderSize) -gt $totalLength) { return }

        $removed = 0
        foreach ($file in $files) {
            $removed += $file.Length
            Remove-Item -Path $file.FullName -Force -Confirm:$false

            if (($totalLength - $removed) -lt ([Dataplat.Dbatools.Message.LogHost]::MaxTotalFolderSize)) { break }
        }
    }
    #endregion Helper Functions

    try {
        while ($true) {
            # This portion is critical to gracefully closing the script
            if ([Dataplat.Dbatools.Runspace.RunspaceHost]::Runspaces[$___ScriptName.ToLowerInvariant()].State -notlike "Running") {
                break
            }

            $path = [Dataplat.Dbatools.Message.LogHost]::LoggingPath
            if (-not (Test-Path $path)) {
                $root = New-Item $path -ItemType Directory -Force -ErrorAction Stop
            } else {
                $root = Get-Item -Path $path
            }

            $errorFiles = Get-ChildItem -Path $root.FullName -Filter "dbatools_$($pid)_error_*.xml" | Sort-Object LastWriteTime -Descending
            [int]$num_Error = if ($errorFiles) {
                (Select-String -InputObject $errorFiles[0].Name -Pattern "(\d+)" -AllMatches).Matches[1].Value
            } else {
                0
            }

            $messageFiles = Get-ChildItem -Path $root.FullName -Filter "dbatools_$($pid)_message_*.xml" | Sort-Object LastWriteTime -Descending
            [int]$num_Message = if ($messageFiles) {
                (Select-String -InputObject $messageFiles[0].Name -Pattern "(\d+)" -AllMatches).Matches[1].Value
            } else {
                0
            }

            #region Process Errors
            while ([Dataplat.Dbatools.Message.LogHost]::OutQueueError.Count -gt 0) {
                $num_Error++

                $Record = $null
                $null = [Dataplat.Dbatools.Message.LogHost]::OutQueueError.TryDequeue([ref]$Record)

                if ($Record) {
                    $Record | Export-Clixml -Path "$($root.FullName)\dbatools_$($pid)_error_$($num_Error).xml" -Depth 3
                }

                Clean-ErrorXml -Path $root
            }
            #endregion Process Errors

            #region Process Logs
            while ([Dataplat.Dbatools.Message.LogHost]::OutQueueLog.Count -gt 0) {
                $CurrentFile = "$($root.FullName)\dbatools_$($pid)_message_$($num_Message).log"
                if (Test-Path $CurrentFile) {
                    $item = Get-Item $CurrentFile
                    if ($item.Length -gt ([Dataplat.Dbatools.Message.LogHost]::MaxMessagefileBytes)) {
                        $num_Message++
                        $CurrentFile = "$($root.FullName)\dbatools_$($pid)_message_$($num_Message).log"
                    }
                }

                $Entry = $null
                $null = [Dataplat.Dbatools.Message.LogHost]::OutQueueLog.TryDequeue([ref]$Entry)
                if ($Entry) {
                    Add-Content -Path $CurrentFile -Value (ConvertTo-Csv -InputObject $Entry -NoTypeInformation)[1]
                }
            }
            #endregion Process Logs

            Clean-MessageLog -Path $root
            Clean-GlobalLog -Path $root

            Start-Sleep -Seconds 5
        }
    } catch { }
    finally {
        [Dataplat.Dbatools.Runspace.RunspaceHost]::Runspaces[$___ScriptName.ToLowerInvariant()].SignalStopped()
    }
}

Register-DbaRunspace -ScriptBlock $scriptBlock -Name "dbatools-logging"
Start-DbaRunspace -Name "dbatools-logging"
# SIG # Begin signature block
# MIIt2wYJKoZIhvcNAQcCoIItzDCCLcgCAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCIiVU8AKz9mdHY
# nVoRGv/hsyZ2M0kd1XNZ0GLkGBf4waCCFdswggbXMIIEv6ADAgECAhMzAAUcRKhb
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
# avFIrmcxghdWMIIXUgIBATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmll
# ZCBDUyBBT0MgQ0EgMDECEzMABRxEqFtdfx8hljkAAAAFHEQwCwYJYIZIAWUDBAIB
# oHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIJcx
# OPjOi0LyPr0/O/neHJquwA1VmZnZU6PF0kScm4EAMAsGCSqGSIb3DQEBAQSCAYBi
# zyD/Nl/BtajUfCHlfXmQu3tIZeRVRNP6CIeasN8S0oC7GPITP74hSiqV/LFNvv3Z
# 76eUZXMtrogelJJ4bjeGfRWMvnOD6kxmrm8wH35KgjlluqFpRw8fNWN9lJE8a34/
# 5kE9Z9V3SbQoIkO3Hs93ph7UaLzv+Z5n3nayG9TorE9R/JEOsNfMbNQs5V47m6Kn
# pGeVNRKAvQ11rdSghhCbc8rjV6o+GGV0MAK05O6MORUA2hkTyM42AeK/KzhgmQ/q
# OTG5bret3Tk4z94YwkxfGfx/AW/2oQTv45M4SnKOCu3T1vrKJeah6PC4j+jI4Egc
# 0+gPpL/3QieJN4JNAX+CcUWTwSduiu9gJKZQxr2Z/8ikgXjfcZhKZs2k4wJQNHmt
# KfSE6eqbvyHKW45+byvBG8a1w1xDEk/pI8v2Lb23erG5aa2paXZoQhri13KXoOVL
# KbougpxT69FgEeQQjc3U9pxD7aFG7OeCIIZ+/0zCfVvrtB0k7SiNspCZ60dKbRWh
# ghS8MIIUuAYKKwYBBAGCNwMDATGCFKgwghSkBgkqhkiG9w0BBwKgghSVMIIUkQIB
# AzEPMA0GCWCGSAFlAwQCAQUAMIIBdAYLKoZIhvcNAQkQAQSgggFjBIIBXzCCAVsC
# AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQgP4sW0GIaEFU3vPedWjed
# +jkmFjYGGfUj6LhnZBpNrVUCBmieF6ApAxgTMjAyNTA4MjMxMTI3NDIuMDA4WjAE
# gAIB9AIICUFRXLZnFVKggemkgeYwgeMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlv
# bnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjQ1MUEtMDVFMC1E
# OTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0YW1waW5n
# IEF1dGhvcml0eaCCDykwggeCMIIFaqADAgECAhMzAAAABeXPD/9mLsmHAAAAAAAF
# MA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVudGl0eSBWZXJp
# ZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAyMDAeFw0yMDEx
# MTkyMDMyMzFaFw0zNTExMTkyMDQyMzFaMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMIICIjANBgkqhkiG9w0BAQEFAAOC
# Ag8AMIICCgKCAgEAnnznUmP94MWfBX1jtQYioxwe1+eXM9ETBb1lRkd3kcFdcG9/
# sqtDlwxKoVIcaqDb+omFio5DHC4RBcbyQHjXCwMk/l3TOYtgoBjxnG/eViS4sOx8
# y4gSq8Zg49REAf5huXhIkQRKe3Qxs8Sgp02KHAznEa/Ssah8nWo5hJM1xznkRsFP
# u6rfDHeZeG1Wa1wISvlkpOQooTULFm809Z0ZYlQ8Lp7i5F9YciFlyAKwn6yjN/kR
# 4fkquUWfGmMopNq/B8U/pdoZkZZQbxNlqJOiBGgCWpx69uKqKhTPVi3gVErnc/qi
# +dR8A2MiAz0kN0nh7SqINGbmw5OIRC0EsZ31WF3Uxp3GgZwetEKxLms73KG/Z+Mk
# euaVDQQheangOEMGJ4pQZH55ngI0Tdy1bi69INBV5Kn2HVJo9XxRYR/JPGAaM6xG
# l57Ei95HUw9NV/uC3yFjrhc087qLJQawSC3xzY/EXzsT4I7sDbxOmM2rl4uKK6eE
# purRduOQ2hTkmG1hSuWYBunFGNv21Kt4N20AKmbeuSnGnsBCd2cjRKG79+TX+sTe
# hawOoxfeOO/jR7wo3liwkGdzPJYHgnJ54UxbckF914AqHOiEV7xTnD1a69w/UTxw
# jEugpIPMIIE67SFZ2PMo27xjlLAHWW3l1CEAFjLNHd3EQ79PUr8FUXetXr0CAwEA
# AaOCAhswggIXMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADAdBgNV
# HQ4EFgQUa2koOjUvSGNAz3vYr0npPtk92yEwVAYDVR0gBE0wSzBJBgRVHSAAMEEw
# PwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9j
# cy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFMh+
# 0mqFKhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmgd6B1hnNodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJZGVudGl0eSUy
# MFZlcmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhvcml0eSUy
# MDIwMjAuY3JsMIGUBggrBgEFBQcBAQSBhzCBhDCBgQYIKwYBBQUHMAKGdWh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwSWRl
# bnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRo
# b3JpdHklMjAyMDIwLmNydDANBgkqhkiG9w0BAQwFAAOCAgEAX4h2x35ttVoVdedM
# eGj6TuHYRJklFaW4sTQ5r+k77iB79cSLNe+GzRjv4pVjJviceW6AF6ycWoEYR0LY
# haa0ozJLU5Yi+LCmcrdovkl53DNt4EXs87KDogYb9eGEndSpZ5ZM74LNvVzY0/nP
# ISHz0Xva71QjD4h+8z2XMOZzY7YQ0Psw+etyNZ1CesufU211rLslLKsO8F2aBs2c
# Io1k+aHOhrw9xw6JCWONNboZ497mwYW5EfN0W3zL5s3ad4Xtm7yFM7Ujrhc0aqy3
# xL7D5FR2J7x9cLWMq7eb0oYioXhqV2tgFqbKHeDick+P8tHYIFovIP7YG4ZkJWag
# 1H91KlELGWi3SLv10o4KGag42pswjybTi4toQcC/irAodDW8HNtX+cbz0sMptFJK
# +KObAnDFHEsukxD+7jFfEV9Hh/+CSxKRsmnuiovCWIOb+H7DRon9TlxydiFhvu88
# o0w35JkNbJxTk4MhF/KgaXn0GxdH8elEa2Imq45gaa8D+mTm8LWVydt4ytxYP/bq
# jN49D9NZ81coE6aQWm88TwIf4R4YZbOpMKN0CyejaPNN41LGXHeCUMYmBx3PkP8A
# DHD1J2Cr/6tjuOOCztfp+o9Nc+ZoIAkpUcA/X2gSMkgHAPUvIdtoSAHEUKiBhI6J
# QivRepyvWcl+JYbYbBh7pmgAXVswggefMIIFh6ADAgECAhMzAAAAVD/yAD6+odim
# AAAAAABUMA0GCSqGSIb3DQEBDAUAMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMg
# UlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMB4XDTI1MDIyNzE5NDAyN1oXDTI2MDIy
# NjE5NDAyN1owgeMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# LTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjQ1MUEtMDVFMC1EOTQ3MTUwMwYDVQQD
# EyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0YW1waW5nIEF1dGhvcml0eTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK7Wnnjlw596igDzQ7R0X23v
# QVa+rXKNIACd35OP+MD1C7yApSmxTQ7rAHsBF66lxk+1pAU5q7UzaWOW7rFrkPVX
# hd9ZzcCQ+yXKgCwYEI7czsnqhyHV5rXJeN0nBS10c7xk54hOQi7JGn8MRm5jdW6U
# 7lMxJbmvr+rTkO7lqMe9DcnROD09MrK03VgGzNlvauMK9rpqK/hDUJHslgi8p9Uk
# BUeeRSZc+c9WcHzNFxBHv7jNB9ZPnaIrGmyBqvF13aSXQsA3OLJ5ErAW+tPoiAhe
# ApQuQlKH9lyLF0Hp+4Deyt7V+Z9a+4UiYNfMLEql964BFUqPgDm9icr8o0SUAgc4
# itc/+XZ6Qm4PouEPK6V89uopDSzwhlOxtehq1NlzS3/ncqlcdtD1r6uqKJSYyzr3
# 4z6QX+dAOQVrW+IFtVJA7xIosC6Uf3MT8mO6dr1PhGR8GV4NJ1/BQBXg83jYeK9E
# byi7UlGfXaGIm+n3rk5b2juIBBadcmhQnMlje6STwuCknheFu6UQ/ZULYxcX20I9
# Ri3rimB0noxDUsM2e3oNjCqjBSfZu4G5KRORl+8sERCowawabgRKcJKI05gFrSV2
# Axc0+NPFxJJcJGHTWXHmeyxUAHuW3Q2loSVfxsIsqZMGnhiQX4f8xtqR2+dJu9TK
# 1kuWDSKv7DKhSMHB98I7AgMBAAGjggHLMIIBxzAdBgNVHQ4EFgQU0mk2gtuzakAQ
# FqbmgXWAbmc3XdkwHwYDVR0jBBgwFoAUa2koOjUvSGNAz3vYr0npPtk92yEwbAYD
# VR0fBGUwYzBhoF+gXYZbaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# cmwvTWljcm9zb2Z0JTIwUHVibGljJTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0El
# MjAyMDIwLmNybDB5BggrBgEFBQcBAQRtMGswaQYIKwYBBQUHMAKGXWh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwUHVibGlj
# JTIwUlNBJTIwVGltZXN0YW1waW5nJTIwQ0ElMjAyMDIwLmNydDAMBgNVHRMBAf8E
# AjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDBmBgNV
# HSAEXzBdMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wCAYGZ4EM
# AQQCMA0GCSqGSIb3DQEBDAUAA4ICAQBz2BTfhlJWlQFTmpmXmIPh9DhsKMmgE6am
# JWyc42zNMXE2KbKtBQCkcHFCoLTrBORt52psHmm0LMdUqExfPLzIgP7+vtyBi03B
# UkBTr0f1EcgMHwzY/8aWCO/dx5BStip/3YzwPLHebCao/vIHNspwvxmKZPnz68Bs
# l4Gbxtes8J7hIH9mabHUY/2jJ0yMGt7164AXaAgMgziO/D8ZR6vIpptKsAcLAlW0
# B+F64oFOVf5GhVYss86hD2QN+UK0nTP3snU4+rrWZAlxwaw2OsrU8AEyb7r6Wozb
# VwTxRNITSLrlimbU+L1jRMFf3kzfa/hOAqEGARW5pN4UOU+U6nFNp+4jpri1iSlG
# kna3+QZEpRLuzu5fnMNV8gNUBh0PMk0pq6lMEKgaqrm6sB2RVuG+O/1WJQAc8pt9
# EHH/owuZD6a4Q4NhVqUZXWqwzfuS+z6oT88qcUIom9AY0WDsMjA3c4nvULS6g95F
# NQxvnJhDhqxJEVef8452wETsRlYxYE+B64UPaYWBSzJCE2Oea55PSyzeBMBtsPl1
# hglmoo3yJKWOS3EBm6wouObjfjg0oy9kebPUcUzWs+5767NE8V/BrKOulvZWyT+q
# JgmRXCiQBVgb/y/uaCC8peyx0QQuoDsJ9VhnQ5cVl9+3yrdXYhj9ltlyd9m1Tlm4
# PVwBrkoOFDGCA9QwggPQAgEBMHgwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBS
# U0EgVGltZXN0YW1waW5nIENBIDIwMjACEzMAAABUP/IAPr6h2KYAAAAAAFQwDQYJ
# YIZIAWUDBAIBBQCgggEtMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkq
# hkiG9w0BCQQxIgQgI1Ju1v1YObZu0Arl99lDttLqEtHHb+ov7L7Mo7YfaOIwgd0G
# CyqGSIb3DQEJEAIvMYHNMIHKMIHHMIGgBCDUgap6YlmYSW/WIF/+rbNjJEZNLqfc
# NECo7poQmEmwCzB8MGWkYzBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGljIFJTQSBU
# aW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAAFQ/8gA+vqHYpgAAAAAAVDAiBCD3OXLp
# 011X77khZBWvEilX4ujilH+SFNaySlDnEW2+2zANBgkqhkiG9w0BAQsFAASCAgA3
# m/q5mVkwrn5ywllIqrKjySzfxv2nqU0a5H6BcWQQDyAu8TSQdtnpcp1OwBx3VB68
# nV1fLcadHd20Bo5V/bSg3w/U5DExBcDdPQpzdtiMny9MgdN+b0JNO2nSMzCt5guG
# Xf6ZFrpgk9rsqWerwQBceo9XYq136vYTsL7zNN8bZ46sOBCHr5jpHRUJltBDkHt5
# agtbaMqwBUL/NmVrFPf/BPt+fxzstw7/SN0jfBqyXhwAAYysrt7G0SMop5IEYcEC
# XFWwBJc4Ht2NBSyKdKhSj/zDVwDubZdMVCDPDok3eo6RpNEQw5vS6lI9h4dWq94N
# e9ohdKYyirpWRF/IQ/dxQ4HqR95Y3r2Z9ZS7fS5muOYGXH1i5FFYjUP7iwEotZhF
# J8wwTZzZomy4VA7cZhQIPXtHv/HoGp3nvUhJ9hnVz7LtS05jg0C+mWovKfZQjlN2
# X/u/MCHO6CHCQG9W0F6zRbOJoU86xZsRmIX3HyRn0+GKZWqcDZ2ttdh+OV55jfCs
# jeOJAqTaNgCTlZlaktqIVAc6RFIdgN4OUWzxG8JNqE44m2vgrShYQOvhXGLxu0Xy
# xnfWYlxelouDhbtCuAtDSCWVKVb8E3AJTavxbiWOlrcF/yXInhSjZCznwtlBveMl
# F9VW2sc0+MwMlQnzyzs47dYzcmlW/vnGYlir+Uzkqw==
# SIG # End signature block
