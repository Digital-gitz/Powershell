[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    $module = "dbatools"
)
# Which process should we be looking for?
if ($psedition -eq 'Core') {
    $process = "pwsh"
} else {
    $process = "powershell"
}
if (($PSVersionTable.PSVersion.Major -le 5) -or ($PSVersionTable.PSVersion.Major -gt 6 -and $PSVersionTable.OS -contains "Windows")) {
    $isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    $ise = Get-Process powershell_ise -ErrorAction SilentlyContinue
    if ($ise) {
        return "PowerShell ISE found in use. Please close this program before using this script."
    }
} else {
    $isElevated = $null;
    $ise = $null;
}
$installedVersion = Get-InstalledModule $module -AllVersions | Select-Object Version, InstalledLocation
Write-Output "The currently installed version(s) of $module is/are: "
$installedVersion.Version

$results =
foreach ($v in $installedVersion) {
    if ($v.InstalledLocation -match "C:\\Users") {
        Add-Member -Force -InputObject $v -MemberType NoteProperty -Name IsUserScope -value $true
    } else {
        if (-not $isElevated) {
            Write-Output "$module version $v.Version cannot be removed without elevated session."
        }
        Add-Member -Force -InputObject $v -MemberType NoteProperty -Name IsUserScope -value $false
    }
    $v
}

$newestVersion = Find-Module $module | Select-Object Version
Write-Output "`nThe latest version of $module in the PSGallery is: $($newestVersion.Version)"
$olderVersions = @( )
if ($installedVersion.Count -gt 1) {
    $olderVersions = @($installedVersion | Where-Object { [version]$_.Version -lt [version]$newestVersion.Version })
}

if ( ($olderVersions.Count -gt 0) -and $newestVersion.Version -in $installedVersion.Version ) {
    Write-Output "Latest version of $module found on $env:COMPUTERNAME."
    Write-Output "Older versions of $module also found. These will be uninstalled now."
    if ($isElevated) {
        $processes = Get-Process $process -IncludeUserName -ErrorAction SilentlyContinue | Where-Object Id -NE $pid
    } else {
        $processes = Get-Process $process -ErrorAction SilentlyContinue | Where-Object Id -NE $PID
    }
    if ($processes.Count -gt 0) {
        if ($Pscmdlet.ShouldProcess("$env:COMPUTERNAME", "Killing $($processes.Count) processes of powershell running")) {
            Write-Output "Death to the following process(es): $(($processes.Id) -join ",")"
            $processes | Stop-Process -ErrorVariable dangit -ErrorAction SilentlyContinue -Force
            if ($dangit) {
                Write-Warning "Not able to kill following processes: $((Get-Process $process | Where-Object Id -NE $pid).Id -join ",")"
            }
        }
    }
    if ($Pscmdlet.ShouldProcess("$env:COMPUTERNAME", "Removing old versions of $module.")) {
        foreach ($v in $olderVersions.Version) {
            Uninstall-Module $module -RequiredVersion $v -ErrorVariable dangit -ErrorAction SilentlyContinue -Force
            if ($dangit) {
                if ($dangit.Exception -like "*Administrator rights*") {
                    Write-Warning "Elevated session is required to uninstall $module version: $v"
                } else {
                    Write-Warning "Unable to remove $module version [$v] due to: `n`t$($dangit.Exception)"
                }
            }
        }
    }
    Write-Output "The End"
} elseif ( ($olderVersions.Count -gt 0) -and $newestVersion.Version -notin $installedVersion.Version ) {
    Write-Output "Update of $module is available"
    Write-Output "Older versions of $module found. These will be uninstalled now."
    if ($isElevated) {
        $processes = Get-Process $process -ErrorAction SilentlyContinue -IncludeUserName | Where-Object Id -NE $pid
    } else {
        $processes = Get-Process $process -ErrorAction SilentlyContinue | Where-Object Id -NE $PID
    }
    if ($processes.Count -gt 0) {
        if ($Pscmdlet.ShouldProcess("$env:COMPUTERNAME", "Killing $($processes.Count) processes of powershell running")) {
            Write-Output "Death to the following process(es): $(($processes.Id) -join ",")"
            $processes | Stop-Process -ErrorVariable dangit -ErrorAction SilentlyContinue -Force
            if ($dangit) {
                Write-Warning "Not able to kill following processes: $((Get-Process $process | Where-Object Id -NE $pid).Id -join ",")"
            }
        }
    }
    if ($Pscmdlet.ShouldProcess("$env:COMPUTERNAME", "Removing old versions of $module.")) {
        foreach ($v in $olderVersions.Version) {
            Uninstall-Module $module -RequiredVersion $v -ErrorVariable dangit -ErrorAction SilentlyContinue -Force
            if ($dangit) {
                if ($dangit.Exception -like "*Administrator rights*") {
                    Write-Warning "Elevated session is required to uninstall $module version: $v"
                } else {
                    Write-Warning "Unable to remove $module version [$v] due to: `n`t$($dangit.Exception)"
                }
            }
        }
    }
    Write-Output "Continuing to install latest release of $module"
    Install-Module $module -Force
    Write-Output "The End"
} else {
    Write-Output "No update/actions required."
}

# SIG # Begin signature block
# MIIt3AYJKoZIhvcNAQcCoIItzTCCLckCAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBbC7m38uJKN0Fh
# yce8/lpvD8KrpB4HRQCSsGB5ShHRlaCCFdswggbXMIIEv6ADAgECAhMzAAUcRKhb
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFKD
# rUC9MfUl6WviS5DsMj8L+CQLkDYrBgi30kFi7KjkMAsGCSqGSIb3DQEBAQSCAYBj
# 0mQ49V3xJmIWPDlGGokYpc34WGGQqRpvicD5BGbTcEVwXecLrrdyYg5y38yy8ldQ
# M+DHJRDHfh0Gqxctx6Rf+eCY+K/0za5FcYyi11k+9P3z57EACkRx/U3Djouft6FW
# xUsZ/X71YfIKcf8oMKe2u6bjYlU8DYixAbpc/5l695qYaSlsYXOtAbYNr8LF/mAJ
# DMvpcKrKL+G8jRTDhiXEFebdaD5vkNUrgmucqu+C3hYqT+HBkAQ+Eqzo0oUY8kKm
# DeEMmBWLnn6hWZzaJXIZYqd1lAv3gSzp/KjY6lKsPD9Anlr1g5Y8dDhzUWVQucj1
# qvoVWNYRUZBiQtUXoJJDgRlNVpGf52rfQEpoTKDNvhcRFSsvnjGc25vZaEo6jH2i
# mN6IzRUufOKYsnC2WC/trV8D6vomeq6wZ0yurqilQk1+Uha0PjbMEq3YYW4FjRG3
# 4zil+b85jM7pWh44yXhIbD9RQP7B/1Xa4TheNo0BErOXfav+Hnp7ZMq9JVPksJOh
# ghS9MIIUuQYKKwYBBAGCNwMDATGCFKkwghSlBgkqhkiG9w0BBwKgghSWMIIUkgIB
# AzEPMA0GCWCGSAFlAwQCAQUAMIIBdQYLKoZIhvcNAQkQAQSgggFkBIIBYDCCAVwC
# AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQgRumGwWKHqZEJuLm4iTkp
# IBbFxUX6LqMh9TxOy4ZRdSUCBmieF6ApVBgTMjAyNTA4MjMxMTI3NDguNzc3WjAE
# gAIB9AIJAK8oxGuJI8FDoIHppIHmMIHjMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRp
# b25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo0NTFBLTA1RTAt
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
# iUIr0Xqcr1nJfiWG2GwYe6ZoAF1bMIIHnzCCBYegAwIBAgITMwAAAFQ/8gA+vqHY
# pgAAAAAAVDANBgkqhkiG9w0BAQwFADBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGlj
# IFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDAeFw0yNTAyMjcxOTQwMjdaFw0yNjAy
# MjYxOTQwMjdaMIHjMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo0NTFBLTA1RTAtRDk0NzE1MDMGA1UE
# AxMsTWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHkw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCu1p545cOfeooA80O0dF9t
# 70FWvq1yjSAAnd+Tj/jA9Qu8gKUpsU0O6wB7AReupcZPtaQFOau1M2ljlu6xa5D1
# V4XfWc3AkPslyoAsGBCO3M7J6och1ea1yXjdJwUtdHO8ZOeITkIuyRp/DEZuY3Vu
# lO5TMSW5r6/q05Du5ajHvQ3J0Tg9PTKytN1YBszZb2rjCva6aiv4Q1CR7JYIvKfV
# JAVHnkUmXPnPVnB8zRcQR7+4zQfWT52iKxpsgarxdd2kl0LANziyeRKwFvrT6IgI
# XgKULkJSh/ZcixdB6fuA3sre1fmfWvuFImDXzCxKpfeuARVKj4A5vYnK/KNElAIH
# OIrXP/l2ekJuD6LhDyulfPbqKQ0s8IZTsbXoatTZc0t/53KpXHbQ9a+rqiiUmMs6
# 9+M+kF/nQDkFa1viBbVSQO8SKLAulH9zE/Jjuna9T4RkfBleDSdfwUAV4PN42Hiv
# RG8ou1JRn12hiJvp965OW9o7iAQWnXJoUJzJY3ukk8LgpJ4XhbulEP2VC2MXF9tC
# PUYt64pgdJ6MQ1LDNnt6DYwqowUn2buBuSkTkZfvLBEQqMGsGm4ESnCSiNOYBa0l
# dgMXNPjTxcSSXCRh01lx5nssVAB7lt0NpaElX8bCLKmTBp4YkF+H/MbakdvnSbvU
# ytZLlg0ir+wyoUjBwffCOwIDAQABo4IByzCCAccwHQYDVR0OBBYEFNJpNoLbs2pA
# EBam5oF1gG5nN13ZMB8GA1UdIwQYMBaAFGtpKDo1L0hjQM972K9J6T7ZPdshMGwG
# A1UdHwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENB
# JTIwMjAyMC5jcmwweQYIKwYBBQUHAQEEbTBrMGkGCCsGAQUFBzAChl1odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFB1Ymxp
# YyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcnQwDAYDVR0TAQH/
# BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwZgYD
# VR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeB
# DAEEAjANBgkqhkiG9w0BAQwFAAOCAgEAc9gU34ZSVpUBU5qZl5iD4fQ4bCjJoBOm
# piVsnONszTFxNimyrQUApHBxQqC06wTkbedqbB5ptCzHVKhMXzy8yID+/r7cgYtN
# wVJAU69H9RHIDB8M2P/Glgjv3ceQUrYqf92M8Dyx3mwmqP7yBzbKcL8ZimT58+vA
# bJeBm8bXrPCe4SB/Zmmx1GP9oydMjBre9euAF2gIDIM4jvw/GUeryKabSrAHCwJV
# tAfheuKBTlX+RoVWLLPOoQ9kDflCtJ0z97J1OPq61mQJccGsNjrK1PABMm+6+lqM
# 21cE8UTSE0i65Ypm1Pi9Y0TBX95M32v4TgKhBgEVuaTeFDlPlOpxTafuI6a4tYkp
# RpJ2t/kGRKUS7s7uX5zDVfIDVAYdDzJNKaupTBCoGqq5urAdkVbhvjv9ViUAHPKb
# fRBx/6MLmQ+muEODYValGV1qsM37kvs+qE/PKnFCKJvQGNFg7DIwN3OJ71C0uoPe
# RTUMb5yYQ4asSRFXn/OOdsBE7EZWMWBPgeuFD2mFgUsyQhNjnmueT0ss3gTAbbD5
# dYYJZqKN8iSljktxAZusKLjm4344NKMvZHmz1HFM1rPue+uzRPFfwayjrpb2Vsk/
# qiYJkVwokAVYG/8v7mggvKXssdEELqA7CfVYZ0OXFZfft8q3V2IY/ZbZcnfZtU5Z
# uD1cAa5KDhQxggPUMIID0AIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMg
# UlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAVD/yAD6+odimAAAAAABUMA0G
# CWCGSAFlAwQCAQUAoIIBLTAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEIFNvKkuwFjnuJxfe/BB6hzg9TfgTY+eHRJ1jThH89ZpBMIHd
# BgsqhkiG9w0BCRACLzGBzTCByjCBxzCBoAQg1IGqemJZmElv1iBf/q2zYyRGTS6n
# 3DRAqO6aEJhJsAswfDBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0Eg
# VGltZXN0YW1waW5nIENBIDIwMjACEzMAAABUP/IAPr6h2KYAAAAAAFQwIgQg9zly
# 6dNdV++5IWQVrxIpV+Lo4pR/khTWskpQ5xFtvtswDQYJKoZIhvcNAQELBQAEggIA
# UT3c5m5Y+3YJXmOoO6MPyM/wN5zCMbOfQisx7dbXrly/0DD3HOJ5vDs2A62p/uBg
# 5Xz+gLt4Txnc4pVLgugd0BEncGKCr7zsc68Rr400UWEFeOIrAO4kQ7KRG0GFAIdN
# mSgNj+jSaVThdIyGDzK6SgRXbqoheAqShWAisn/Ze+enL8uq1tOEq0BOM9gwkZiP
# urldxjBe3dcbsJ9lL93a0C++aDLnnRjOiCF+GttWNhrTYccZ2J4qshPgQXbB+rvH
# AUTMwqIdsQyOjtMyh2RHr8puOTeyFvhJJEhf9p3ddDrBnBsT2TyIoEAttqTw2t6J
# POqiN7RRHdbTgsLvghWWDPbUmrOteMX6EMhzQJiU651ihWOagzY6U78pQx48qGdD
# 9mVIMzUYh0uiYa8FIFYaF34mwIRCkzZmcYfwgtaYluuY7LuDjw2NBJOw7OxkF3lT
# 2Y6zsAJ9fgT+/CzR0C4qyXDnfOn4iNbXfkpi9y2pr/q6G4nO8S4tFO/ZKI7EMXPN
# o8pb1xAbTPyJTkAiBH4sGB2io+Aa7ER9QZvZZrwbQwU8g5eA5tthbFq9ZVWQc5dr
# ELRBzpt07w4VjQ7CTrtG7YF96aEQsIRtJ5rG5+zEW/wVopAhAfi3/ue+twvzLnQT
# tO7zE4GzZTqIPEPvhQLrkQGhAIQrjEr0cS7zAEr8XgA=
# SIG # End signature block
