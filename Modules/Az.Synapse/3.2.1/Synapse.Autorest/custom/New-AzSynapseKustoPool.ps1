
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Create or update a Kusto pool.
.Description
Create or update a Kusto pool.
.Example
PS C:\> New-AzSynapseKustoPool -ResourceGroupName testrg -WorkspaceName testws -Name testnewkustopool -Location 'East US' -SkuName "Storage optimized" -SkuSize Medium

Location  Name                    Type                                    Etag
--------  ----                    ----                                    ----
East US 2 testws/testnewkustopool Microsoft.Synapse/workspaces/kustoPools 

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api20210601Preview.IKustoPool
.Link
https://learn.microsoft.com/powershell/module/az.synapse/new-azsynapsekustopool
#>
function New-AzSynapseKustoPool {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api20210601Preview.IKustoPool])]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [Alias('KustoPoolName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [System.String]
        # The name of the Kusto pool.
        ${Name},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [System.String]
        # The name of the resource group.
        # The name is case insensitive.
        ${ResourceGroupName},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [System.String]
        # The name of the workspace
        ${WorkspaceName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [System.String]
        # The ID of the target subscription.
        ${SubscriptionId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Header')]
        [System.String]
        # The ETag of the Kusto Pool.
        # Omit this value to always overwrite the current Kusto Pool.
        # Specify the last-seen ETag value to prevent accidentally overwriting concurrent changes.
        ${IfMatch},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Header')]
        [System.String]
        # Set to '*' to allow a new Kusto Pool to be created, but to prevent updating an existing Kusto Pool.
        # Other values will result in a 412 Pre-condition Failed response.
        ${IfNoneMatch},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.String]
        # The geo-location where the resource lives
        ${Location},

        [Parameter(Mandatory)]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuName])]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuName]
        # SKU name.
        ${SkuName},

        [Parameter(Mandatory)]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuSize])]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuSize]
        # SKU size.
        ${SkuSize},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # A boolean value that indicates if the purge operations are enabled.
        ${EnablePurge},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # A boolean value that indicates if the streaming ingest is enabled.
        ${EnableStreamingIngest},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # A boolean value that indicate if the optimized autoscale feature is enabled or not.
        ${OptimizedAutoscaleIsEnabled},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # Maximum allowed instances count.
        ${OptimizedAutoscaleMaximum},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # Minimum allowed instances count.
        ${OptimizedAutoscaleMinimum},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # The version of the template defined, for instance 1.
        ${OptimizedAutoscaleVersion},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # The number of instances of the cluster.
        ${SkuCapacity},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api10.ITrackedResourceTags]))]
        [System.Collections.Hashtable]
        # Resource tags.
        ${Tag},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {
        try {
            $Parameter = [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api20210601Preview.KustoPool]::new()

            $Parameter.Location = $PSBoundParameters['Location']
            $null = $PSBoundParameters.Remove('Location')

            $Parameter.SkuName = $PSBoundParameters['SkuName']
            $null = $PSBoundParameters.Remove('SkuName')

            $Parameter.SkuSize = $PSBoundParameters['SkuSize']
            $null = $PSBoundParameters.Remove('SkuSize')

            $ws = Get-AzSynapseWorkspace -ResourceGroupName $PSBoundParameters['ResourceGroupName'] -Name $PSBoundParameters['WorkspaceName']

            $Parameter.WorkspaceUid = $ws.WorkspaceUid

            if ($PSBoundParameters.ContainsKey('EnablePurge')) {
                $Parameter.EnablePurge = $PSBoundParameters['EnablePurge']
                $null = $PSBoundParameters.Remove('EnablePurge')
            }

            if ($PSBoundParameters.ContainsKey('EnableStreamingIngest')) {
                $Parameter.EnableStreamingIngest = $PSBoundParameters['EnableStreamingIngest']
                $null = $PSBoundParameters.Remove('EnableStreamingIngest')
            }
            
            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleIsEnabled')) {
                $Parameter.OptimizedAutoscaleIsEnabled = $PSBoundParameters['OptimizedAutoscaleIsEnabled']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleIsEnabled')
            }

            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleMaximum')) {
                $Parameter.OptimizedAutoscaleMaximum = $PSBoundParameters['OptimizedAutoscaleMaximum']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleMaximum')
            }

            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleMinimum')) {
                $Parameter.OptimizedAutoscaleMinimum = $PSBoundParameters['OptimizedAutoscaleMinimum']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleMinimum')
            }

            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleVersion')) {
                $Parameter.OptimizedAutoscaleVersion = $PSBoundParameters['OptimizedAutoscaleVersion']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleVersion')
            }

            if ($PSBoundParameters.ContainsKey('SkuCapacity')) {
                $Parameter.SkuCapacity = $PSBoundParameters['SkuCapacity']
                $null = $PSBoundParameters.Remove('SkuCapacity')
            }

            if ($PSBoundParameters.ContainsKey('Tag')) {
                $Parameter.Tag = $PSBoundParameters['Tag']
                $null = $PSBoundParameters.Remove('Tag')
            }

            $null = $PSBoundParameters.Add('Parameter', $Parameter)

            Az.Synapse.internal\New-AzSynapseKustoPool @PSBoundParameters
        } catch {
            throw
        }
    }
}



# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCyseCw5leULIHj
# 0qqmGPcCMuwC2GsUc6OTFUBAujmTG6CCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEStAXl+PzumUPy3jP55o0QU
# XrUgLVgOUs8rj1pWxRC2MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAm2VrNBQRpCDAXlBXryz+gZQDODcprUuv1GSvNzbWsrErejkZY7OQPH1l
# eN4tW27rRcicw5eEzCvpORyAEnisaKSyayLs0V+er6Ka4IDfzjBz/6vL1u5bNBQU
# VUjcjZMXKOwIf8HcfzTxpd6f3Tt3EBxVJ8TZy89DkA8fLRxD2idduj0Y6lVEj0nt
# QkhIxaTxIJ6Uu5k5CbAoYa8Ao4S1IWPHG+7JlLr8hEM7jWDejzPjTkDb2Y41aY1A
# /noq/NMl7ZGrmLsQ1ouHxyEDl3GqVXCzL+O2IAWOjWniMVWLglBmD/nD76f2G18x
# CRh3lafSmW5Gcs16ELnzIP4DxOhyGqGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAabj+Op/Dgs1RDvybUzAYp5Khg/65ZzGs0wT/AzQlMSQIGZ/g1cUGa
# GBMyMDI1MDQzMDAyMzE1OC42NzVaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RjAwMi0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgU8dWyCRIfN/gABAAACBTANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NDlaFw0yNjA0MjIxOTQyNDlaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RjAwMi0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCSkvLfd7gF1r2wGdy85CFYXHUC8ywEyD4LRLv0WYEX
# eeZ0u5YuK7p2cXVzQmZPOHTN8TWqG2SPlUb+7PldzFDDAlR3vU8piOjmhu9rHW43
# M2dbor9jl9gluhzwUd2SciVGa7f9t67tM3KFKRSMXFtHKF3KwBB7aVo+b1qy5p9D
# Wlo2N5FGrBqHMEVlNyzreHYoDLL+m8fSsqMu/iYUqxzK5F4S7IY5NemAB8B+A3Qg
# wVIi64KJIfeKZUeiWKCTf4odUgP3AQilxh48P6z7AT4IA0dMEtKhYLFs4W/KNDMs
# Yr7KpQPKVCcC5E8uDHdKewubyzenkTxy4ff1N3g8yho5Pi9BfjR0VytrkmpDfep8
# JPwcb4BNOIXOo1pfdHZ8EvnR7JFZFQiqpMZFlO5CAuTYH8ujc5PUHlaMAJ8NEa9T
# FJTOSBrB7PRgeh/6NJ2xu9yxPh/kVN9BGss93MC6UjpoxeM4x70bwbwiK8SNHIO8
# D8cql7VSevUYbjN4NogFFwhBClhodE/zeGPq6y6ixD4z65IHY3zwFQbBVX/w+L/V
# HNn/BMGs2PGHnlRjO/Kk8NIpN4shkFQqA1fM08frrDSNEY9VKDtpsUpAF51Y1oQ6
# tJhWM1d3neCXh6b/6N+XeHORCwnY83K+pFMMhg8isXQb6KRl65kg8XYBd4JwkbKo
# VQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHR6Wrs27b6+yJ3bEZ9o5NdL1bLwMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQAOuxk47b1i75V81Tx6xo10xNIr4zZxYVfk
# F5TFq2kndPHgzVyLnssw/HKkEZRCgZVpkKEJ6Y4jvG5tugMi+Wjt7hUMSipk+RpB
# 5gFQvh1xmAEL2flegzTWEsnj0wrESplI5Z3vgf2eGXAr/RcqGjSpouHbD2HY9Y3F
# 0Ol6FRDCV/HEGKRHzn2M5rQpFGSjacT4DkqVYmem/ArOfSvVojnKEIW914UxGtuh
# JSr9jOo5RqTX7GIqbtvN7zhWld+i3XxdhdNcflQz9YhoFqQexBenoIRgAPAtwH68
# xczr9LMC3l9ALEpnsvO0RiKPXF4l22/OfcFffaphnl/TDwkiJfxOyAMfUF3xI9+3
# izT1WX2CFs2RaOAq3dcohyJw+xRG0E8wkCHqkV57BbUBEzLX8L9lGJ1DoxYNpoDX
# 7iQzJ9Qdkypi5fv773E3Ch8A+toxeFp6FifQZyCc8IcIBlHyak6MbT6YTVQNgQ/h
# 8FF+S5OqP7CECFvIH2Kt2P0GlOu9C0BfashnTjodmtZFZsptUvirk/2HOLLjBiMj
# DwJsQAFAzJuz4ZtTyorrvER10Gl/mbmViHqhvNACfTzPiLfjDgyvp9s7/bHu/Cal
# KmeiJULGjh/lwAj5319pggsGJqbhJ4FbFc+oU5zffbm/rKjVZ8kxND3im10Qp41n
# 2t/qpyP6ETCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNQ
# MIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkYwMDItMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDV
# sH9p1tJn+krwCMvqOhVvXrbetKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA67u+1TAiGA8yMDI1MDQyOTIxMTA0
# NVoYDzIwMjUwNDMwMjExMDQ1WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDru77V
# AgEAMAoCAQACAhRYAgH/MAcCAQACAhSNMAoCBQDrvRBVAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAK4dGQLgeUZl60ziYoyqtQGeHKVCFq8m992L8bwcoopq
# sgnG/3NKs9+kWufLS5chEmurnAnpQClJed+wD2Pa9U/qW+TVwlsdSIlNShhY54MR
# ly2LzDmonNLS4LDyHrRxrdFArNC3KQuG31GzA3oRxvue7e7pGz4XlmOZCZgmfYop
# QCpgtHvqWr6nvEjyMAXwOzBh9E9HwAHkX0o38J52IclU8Crx1OZEsymi1hF5C6Go
# zKhsHPoQNnQvWZzr3JiAptgex/xuUHx2RSnTK1r9EseQq5sEAkgmnnLeC0Ap8Ey7
# 8FYBnb3CB3H5qPxVYZYNEk3ODJso5QCSrU4SKK66Xx0xggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgU8dWyCRIfN/gABAAAC
# BTANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCDDtzO6C7+0w82QDFl6YU4pZPhwuSjj2c5E4mW1PLEn
# yzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIIANAz3ceY0umhdWLR2sJpq0
# OPqtJDTAYRmjHVkwEW9IMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIFPHVsgkSHzf4AAQAAAgUwIgQgY4KZg3CYiLgPO5abKS85unDm
# 3/qjksynLHbwt4LbvNowDQYJKoZIhvcNAQELBQAEggIAAUoRQHjoqEghZGjplvk/
# 8/9E/2o3oXQzEYzvHQSVVzjCfC5ci/R9QH/EwlgnJnh6wOY9cTe7nkD5Oh3lxICL
# 3NDSYfpTAUNzjXZQHfpVSfOh5fv1kqsqmb8565TsH7IGZh5/iWvUEtoMy7MkYPN6
# iVBlqbAD20v8PMsdvhRQfJriVRLIlt02+geJP2R2hzlmtWYVDnqXHZ0BY2OSgO44
# 6+M0JS1LtjoQHFGsl/iq5Xk+Rl/JkEgcUN4Z3tthW+OeveWTcLFTQNbaNz9pxJE3
# uSt3ZW5aLdWCJLY0EjIgw8oN6Cr72ewEoike89gWHiH/sU47Zk0t/FTF0QcAGWAa
# H4wYgFg5UMwXx1O8OTbsYLgkVfl5VzndHos4cGHlhOOY7TaffkLiEkM1TJhLA9JJ
# mX5M/PSrvtU1Xo8xZjprgui1Dhfwa0qCZ8/jOEpNXgqCN52TrfMIOuvyDq5w2wpv
# nKzoXAKEjxRJ+3MQa7htlAnIHfb/3tuxpGaJk/v8JU9XIlfKBBjiGG2zPcPowvk3
# 2ZCQn6taK9OwPpaXJD/Mgo/uBiZesFWAgE+wHQZf0JIB0dybA+LDgkhPOYS5ZgEc
# ouEmdXoA2qhRHASllaIovEjNM2BxPYSVmOBYW/Iu55MwkaYTM4QBS7dlGhMAz5GG
# vWMuJYu2NN4OGluQZek/0NM=
# SIG # End signature block
