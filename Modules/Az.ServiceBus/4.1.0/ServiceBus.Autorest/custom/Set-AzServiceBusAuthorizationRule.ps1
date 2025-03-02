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
Updates the authorization rule of a ServiceBus namespace, queue or topic.
.Description
Updates the authorization rule of a ServiceBus namespace, queue or topic.
#>

function Set-AzServiceBusAuthorizationRule{
	[OutputType([Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Models.ISbAuthorizationRule])]
    [CmdletBinding(DefaultParameterSetName = 'SetExpandedNamespace', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
	param(
        [Parameter(ParameterSetName = 'SetExpandedTopic', Mandatory, HelpMessage = "The name of the Authorization Rule")]
        [Parameter(ParameterSetName = 'SetExpandedQueue', Mandatory, HelpMessage = "The name of the Authorization Rule")]
        [Parameter(ParameterSetName = 'SetExpandedNamespace', Mandatory, HelpMessage = "The name of the Authorization Rule")]
        [Alias('AuthorizationRuleName')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the Authorization Rule.
        ${Name},

        [Parameter(ParameterSetName = 'SetExpandedQueue', Mandatory, HelpMessage = "The name of the ServiceBus queue.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the ServiceBus queue.
        ${QueueName},

        [Parameter(ParameterSetName = 'SetExpandedTopic', Mandatory, HelpMessage = "The name of the ServiceBus topic.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the ServiceBus queue.
        ${TopicName},

        [Parameter(ParameterSetName = 'SetExpandedTopic', Mandatory, HelpMessage = "The name of the ServiceBus namespace.")]
        [Parameter(ParameterSetName = 'SetExpandedQueue', Mandatory, HelpMessage = "The name of the ServiceBus namespace.")]
        [Parameter(ParameterSetName = 'SetExpandedNamespace', Mandatory, HelpMessage = "The name of the ServiceBus namespace.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of ServiceBus namespace
        ${NamespaceName},

        [Parameter(ParameterSetName = 'SetExpandedTopic', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Parameter(ParameterSetName = 'SetExpandedQueue', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Parameter(ParameterSetName = 'SetExpandedNamespace', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the resource group.
        # The name is case insensitive.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'SetExpandedTopic', HelpMessage = "The ID of the target subscription.")]
        [Parameter(ParameterSetName = 'SetExpandedQueue', HelpMessage = "The ID of the target subscription.")]
        [Parameter(ParameterSetName = 'SetExpandedNamespace', HelpMessage = "The ID of the target subscription.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # The ID of the target subscription.
        ${SubscriptionId},

        [Parameter(ParameterSetName = 'SetViaIdentityExpanded', Mandatory, ValueFromPipeline, HelpMessage = "Identity parameter. To construct, see NOTES section for INPUTOBJECT properties and create a hash table.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Models.IServiceBusIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},

        [Parameter(Mandatory, HelpMessage = "The rights associated with the rule.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Body')]
        [System.String[]]
        # The rights associated with the rule.
        ${Rights},
		
        [Parameter(HelpMessage = "The credentials, account, tenant, and subscription used for communication with Azure.")]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter(HelpMessage = "Run the command as a job")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter(HelpMessage = "Run the command asynchronously")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
	)
	process{
		try{
            $hasRights = $PSBoundParameters.Remove('Rights')
            $hasAsJob = $PSBoundParameters.Remove('AsJob')
            $null = $PSBoundParameters.Remove('WhatIf')
            $null = $PSBoundParameters.Remove('Confirm')

            if ($PSCmdlet.ParameterSetName -eq 'SetExpandedQueue'){
                $authRule = Az.ServiceBus.private\Get-AzServiceBusQueueAuthorizationRule_Get @PSBoundParameters
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'SetExpandedTopic'){
                $authRule = Az.ServiceBus.private\Get-AzServiceBusTopicAuthorizationRule_Get @PSBoundParameters
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'SetExpandedNamespace'){
                $authRule = Az.ServiceBus.private\Get-AzServiceBusNamespaceAuthorizationRule_Get @PSBoundParameters
            }

            if ($hasAsJob) {
                $PSBoundParameters.Add('AsJob', $true)
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'SetViaIdentityExpanded'){
                
                if($InputObject.Id -ne $null){
                    $ResourceHashTable = ParseResourceId -ResourceId $InputObject.Id
                }
                else{
                    $ResourceHashTable = ParseResourceId -ResourceId $InputObject
                }

                if ($ResourceHashTable['QueueName'] -ne $null){
                    $authRule = Az.ServiceBus.private\Get-AzServiceBusQueueAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                elseif ($ResourceHashTable['TopicName'] -ne $null){
                    $authRule = Az.ServiceBus.private\Get-AzServiceBusTopicAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                elseif ($ResourceHashTable['NamespaceName'] -ne $null){
                    $authRule = Az.ServiceBus.private\Get-AzServiceBusNamespaceAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                else{
                    throw 'Invalid -InputObject. Please Check ResourceId'
                }

            }
            
            # 2. PUT
            $null = $PSBoundParameters.Remove('InputObject')
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('NamespaceName')
            $null = $PSBoundParameters.Remove('QueueName')
            $null = $PSBoundParameters.Remove('TopicName')
            $null = $PSBoundParameters.Remove('Name')
            $null = $PSBoundParameters.Remove('SubscriptionId')

            if ($hasRights) {
                $authRule.Rights = $Rights
            }
            if ($hasAsJob) {
                $PSBoundParameters.Add('AsJob', $true)
            }

            if ($PSCmdlet.ParameterSetName -eq 'SetExpandedNamespace'){
                if ($PSCmdlet.ShouldProcess("ServiceBus Namespace Authorization Rule $($authRule.Name)", "Create or update")) {
                    Az.ServiceBus.private\New-AzServiceBusNamespaceAuthorizationRule_CreateViaIdentity -InputObject $authRule -Parameter $authRule @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'SetExpandedQueue'){
                if ($PSCmdlet.ShouldProcess("ServiceBus Queue Authorization Rule $($authRule.Name)", "Create or update")) {
                    Az.ServiceBus.private\New-AzServiceBusQueueAuthorizationRule_CreateViaIdentity -InputObject $authRule -Parameter $authRule @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'SetExpandedTopic'){
                if ($PSCmdlet.ShouldProcess("ServiceBus Topic Authorization Rule $($authRule.Name)", "Create or update")) {
                    Az.ServiceBus.private\New-AzServiceBusTopicAuthorizationRule_CreateViaIdentity -InputObject $authRule -Parameter $authRule @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'SetViaIdentityExpanded'){
                
                if ($ResourceHashTable['QueueName'] -ne $null){
                    if ($PSCmdlet.ShouldProcess("ServiceBus Queue Authorization Rule $($ResourceHashTable['AuthorizationRuleName'])", "Create or update")) {
                        Az.ServiceBus.private\New-AzServiceBusQueueAuthorizationRule_CreateViaIdentity -InputObject $authRule -Parameter $authRule @PSBoundParameters
                    }
                }

                elseif ($ResourceHashTable['TopicName'] -ne $null){
                    if ($PSCmdlet.ShouldProcess("ServiceBus Topic Authorization Rule $($ResourceHashTable['AuthorizationRuleName'])", "Create or update")) {
                        Az.ServiceBus.private\New-AzServiceBusTopicAuthorizationRule_CreateViaIdentity -InputObject $authRule -Parameter $authRule @PSBoundParameters
                    }
                }

                elseif ($ResourceHashTable['NamespaceName'] -ne $null){
                    if ($PSCmdlet.ShouldProcess("ServiceBus Namespace Authorization Rule $($ResourceHashTable['AuthorizationRuleName'])", "Create or update")) {
                        Az.ServiceBus.private\New-AzServiceBusNamespaceAuthorizationRule_CreateViaIdentity -InputObject $authRule -Parameter $authRule @PSBoundParameters
                    }
                }

                else{
                    throw 'Invalid -InputObject'
                }

            }
		}
		catch{
			throw
		}
	}
}

# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCrkDL2/ssaZLry
# qdmE4FO5cLPRRV2GNUe7joopHqHY9qCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEjyOjPo3fxNGOFp46DUpXv/
# yR2FuPNbwEgiB1BNL9d1MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAn41iU0UZRip00/+tJWoRx/tVA6PaHCMwpMdfhGP4UYJhaO/s3KtSPeM1
# lyBKWF8foaLkyEg+9taTNFpTQDsjCFOyRaoWky+Y6sn5OgNJ8TF4mJgoZ/LsX4mx
# RDpM8qOEsVmhAsDy6G5Bv4HVVbi5WfiNRBDF1j8DzlyR/TiHPwPCbjWAaPz0MJBG
# Cb5dklJlcz9Lrwj7LG5YvBCz1PldBDldRl15Wz5E/mkjZT4vi1uEkSFmivDrYHGh
# FIxzuMG2jWlU3v65OFSV7AB0J6Akoj4Br/0yfGgcLXq/D9OtHnmv7PfvdMZ3Kd4/
# LWvNEiQbgI3nYtikMT6Yjj45HDJd86GCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCCyh8WsubUXiXd2RRTqdoCliUfIAFML61BtBd7zI0x76wIGZ1rou1dj
# GBMyMDI1MDEwOTA2MzY0NS45OTFaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAehQsIDPK3KZTQABAAAB6DANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# MjJaFw0yNTAzMDUxODQ1MjJaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDhQXdE0WzXG7wzeC9SGdH6eVwdGlF6YgpU7weOFBkp
# W9yuEmJSDE1ADBx/0DTuRBaplSD8CR1QqyQmxRDD/CdvDyeZFAcZ6l2+nlMssmZy
# C8TPt1GTWAUt3GXUU6g0F0tIrFNLgofCjOvm3G0j482VutKS4wZT6bNVnBVsChr2
# AjmVbGDN/6Qs/EqakL5cwpGel1te7UO13dUwaPjOy0Wi1qYNmR8i7T1luj2JdFdf
# ZhMPyqyq/NDnZuONSbj8FM5xKBoar12ragC8/1CXaL1OMXBwGaRoJTYtksi9njuq
# 4wDkcAwitCZ5BtQ2NqPZ0lLiQB7O10Bm9zpHWn9x1/HmdAn4koMWKUDwH5sd/zDu
# 4vi887FWxm54kkWNvk8FeQ7ZZ0Q5gqGKW4g6revV2IdAxBobWdorqwvzqL70Wdsg
# DU/P5c0L8vYIskUJZedCGHM2hHIsNRyw9EFoSolDM+yCedkz69787s8nIp55icLf
# DoKw5hak5G6MWF6d71tcNzV9+v9RQKMa6Uwfyquredd5sqXWCXv++hek4A15WybI
# c6ufT0ilazKYZvDvoaswgjP0SeLW7mvmcw0FELzF1/uWaXElLHOXIlieKF2i/YzQ
# 6U50K9dbhnMaDcJSsG0hXLRTy/LQbsOD0hw7FuK0nmzotSx/5fo9g7fCzoFjk3tD
# EwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFPo5W8o980kMfRVQba6T34HwelLaMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCWfcJm2rwXtPi74km6PKAkni9+BWotq+Qt
# DGgeT5F3ro7PsIUNKRkUytuGqI8thL3Jcrb03x6DOppYJEA+pb6o2qPjFddO1TLq
# vSXrYm+OgCLL+7+3FmRmfkRu8rHvprab0O19wDbukgO8I5Oi1RegMJl8t5k/UtE0
# Wb3zAlOHnCjLGSzP/Do3ptwhXokk02IvD7SZEBbPboGbtw4LCHsT2pFakpGOBh+I
# SUMXBf835CuVNfddwxmyGvNSzyEyEk5h1Vh7tpwP7z7rJ+HsiP4sdqBjj6Avopuf
# 4rxUAfrEbV6aj8twFs7WVHNiIgrHNna/55kyrAG9Yt19CPvkUwxYK0uZvPl2WC39
# nfc0jOTjivC7s/IUozE4tfy3JNkyQ1cNtvZftiX3j5Dt+eLOeuGDjvhJvYMIEkpk
# V68XLNH7+ZBfYa+PmfRYaoFFHCJKEoRSZ3PbDJPBiEhZ9yuxMddoMMQ19Tkyftot
# 6Ez0XhSmwjYBq39DvBFWhlyDGBhrU3GteDWiVd9YGSB2WnxuFMy5fbAK6o8PWz8Q
# RMiptXHK3HDBr2wWWEcrrgcTuHZIJTqepNoYlx9VRFvj/vCXaAFcmkW1nk7VE+ow
# aXr5RJjryDq9ubkyDq1mdrF/geaRALXcNZbfNXIkhXzXA6a8CiamcQW/DgmLJpiV
# QNriZYCHIDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkRDMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCM
# JG4vg0juMOVn2BuKACUvP80FuqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6ymm5TAiGA8yMDI1MDEwOTAxMzc0
# MVoYDzIwMjUwMTEwMDEzNzQxWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrKabl
# AgEAMAcCAQACAgkfMAcCAQACAhJBMAoCBQDrKvhlAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAEpuvqYAWimE3aR+q2KcX9oSBl2Vbkx7buLha6IStST4ztD6
# i7OuKIKiHh2ybmm70omfWKv/4kYvcgElPrlgNhgzwyFXV7uRX1SkPMbH9B+5oj9Z
# WOKE81lgSX0UNsgWlL92N7nGQN3G+J/4ZP3sjZdcdC6j7nqd82IucomvfqPBKX5U
# FFDRNzuxSI2vme97A73cqQ6aHzVw9h1pChOmLz62Cud0nA3xAB6CZIi+Qa2hx2J1
# IoroWK7dSDndNOjk5ZCMQAhcmdbr4uqkC1ySFtNJbQfp1GGE1vFiI3sNIKbe84XC
# u894GtoRsrGZuN1mOWMN3cTuM+1ec0q6je5corAxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAehQsIDPK3KZTQABAAAB6DAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCAljVusM7cAfmy6bRiFryv66LMnK44pjAOAn6GQC1YoxjCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EICrS2sTVAoQggkHR59pNqige0xfJ
# T2J3U8W1Sc8H+OsdMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHoULCAzytymU0AAQAAAegwIgQgQV0pW5tgGS+yeJmO/KxxySGk1pYF
# hPEuT2ZdSh5D128wDQYJKoZIhvcNAQELBQAEggIAayGr0r6LiDGLVS26wc+TRJIf
# itMgK/9H6pwLHTz48tIqB/jRiBDyPhobhdKQscrWHpCy9S7K16jW9wgzo7tkLgMz
# lPlx608X18NK7+cBMtPvkoS5Cbomf+7CqUCDmVrwhzkpI/WVxarVzEfDPFFHALYi
# RILy3oZtHo5T5JVd5jcAvLFVrqIQXeIJAuTvRCOcgcF4kOtuu4isYmUv0tndEK1/
# 1eMYuCRe5MA0JgtqoK7MB04yjE9SqOmCk8TG8iQueM+05CwMnesUV0EE47qNmvY/
# eLV2khr8Jr8L1KKMZDrDBmh1rgBpBHiUtDbKwG2v75WEvbW9ldnbc+7coZMuPqKM
# av7kh/Z2ICTEAPbuNQq7vmbIxZuRI8LKiaEYHQ2XU+terp9DIDwLGLBteThBwh0Y
# GREqUZi2qPHTV/R6wKBA34iLAHcN5bQLJ3kdDKbXh17mvL8X/jo6zEEajC/mx8vX
# eMo719NLk2g41E304eLCyvGmo4seOtJPgH1Ron7fAqIeQ6qvV10jmZkFbGeUYGrG
# skZsPl35wa+xV+6TLNypEFUdC8TUrfAdrbpCk1MyzQYgvXHNzQ9R6f3z2DPAcFrx
# zTT2GGdX4Mlj4dyxnxNZVtgNr5P9L4d3Cnroi/rHd5gLwMRG4u3vGIrd23U01KDT
# Vg0AtNZABLLW05P7HqM=
# SIG # End signature block
