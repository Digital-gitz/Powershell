
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
Updates the target properties for the replicating server.
.Description
The Set-AzMigrateLocalServerReplication cmdlet updates the target properties for the replicating server.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/set-azmigratelocalserverreplication
#>
function Set-AzMigrateLocalServerReplication {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is using a preview API version and is subject to breaking change in a future release.")]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.IJobModel])]
    [CmdletBinding(DefaultParameterSetName = 'ById', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the replicating server for which the properties need to be updated. The ID should be retrieved using the Get-AzMigrateLocalServerReplication cmdlet.
        ${TargetObjectID},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int32]
        # Specifies the number of CPU cores.
        ${TargetVMCPUCore},

        [Parameter()]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if RAM is dynamic or not. 
        ${IsDynamicMemoryEnabled},
        
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemDynamicMemoryConfig]
        # Specifies the dynamic memory configration of RAM.
        ${DynamicMemoryConfig},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int64]
        # Specifies the target RAM size in MB. 
        ${TargetVMRam},
		
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.AzLocalNicInput[]]
        # Specifies the nics on the source server to be included for replication.
        ${NicToInclude},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # The subscription Id.
        ${SubscriptionId},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )
    
    process {
        Import-Module $PSScriptRoot\Helper\AzLocalCommonSettings.ps1
        Import-Module $PSScriptRoot\Helper\CommonHelper.ps1

        CheckResourcesModuleDependency
        
        $HasTargetVMCPUCore = $PSBoundParameters.ContainsKey('TargetVMCPUCore')
        $HasTargetVMRam = $PSBoundParameters.ContainsKey('TargetVMRam')
        $HasDynamicMemoryConfig = $PSBoundParameters.ContainsKey('DynamicMemoryConfig')
        $HasNicToInclude = $PSBoundParameters.ContainsKey('NicToInclude')
        $HasIsDynamicMemoryEnabled = $PSBoundParameters.ContainsKey('IsDynamicMemoryEnabled')
        if ($HasIsDynamicMemoryEnabled) {
            $isDynamicRamEnabled = [System.Convert]::ToBoolean($IsDynamicMemoryEnabled)
        }

        $null = $PSBoundParameters.Remove('TargetVMCPUCore')
        $null = $PSBoundParameters.Remove('IsDynamicMemoryEnabled')
        $null = $PSBoundParameters.Remove('DynamicMemoryConfig')
        $null = $PSBoundParameters.Remove('TargetVMRam')
        $null = $PSBoundParameters.Remove('NicToInclude')
        $null = $PSBoundParameters.Remove('TargetObjectID')
        $null = $PSBoundParameters.Remove('WhatIf')
        $null = $PSBoundParameters.Remove('Confirm')
        
        $ProtectedItemIdArray = $TargetObjectID.Split("/")
        $ResourceGroupName = $ProtectedItemIdArray[4]
        $VaultName = $ProtectedItemIdArray[8]
        $MachineName = $ProtectedItemIdArray[10]
      
        # Get existing Protected Item
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("VaultName", $VaultName)
        $null = $PSBoundParameters.Add("Name", $MachineName)
      
        $ProtectedItem = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateProtectedItem' `
            -Parameters $PSBoundParameters `
            -ErrorMessage "Replication item is not found with Id '$TargetObjectID'."
      
        $null = $PSBoundParameters.Remove("ResourceGroupName")
        $null = $PSBoundParameters.Remove("VaultName")
        $null = $PSBoundParameters.Remove("Name")
        
        $protectedItemProperties = $ProtectedItem.Property
        $customProperties = $protectedItemProperties.CustomProperty
        $MachineIdArray = $customProperties.FabricDiscoveryMachineId.Split("/")
        $SiteType = $MachineIdArray[7]
        $SiteName = $MachineIdArray[8]
       
        # No "DisableProtection" means IR has not been initiated
        # "CommitFailover" means migration has been completed
        if (!$protectedItemProperties.AllowedJob.Contains('DisableProtection') -or
            $protectedItemProperties.AllowedJob.Contains('CommitFailover')) {
            throw "Set server replication is not allowed for this item '$TargetObjectID' at the moment. Please check its status and try again later."
        }

        if ($SiteType -eq $SiteTypes.HyperVSites) {     
            $customPropertiesUpdate = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCIProtectedItemModelCustomPropertiesUpdate]::new()
            $customPropertiesUpdate.InstanceType = $AzLocalInstanceTypes.HyperVToAzLocal
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
            $customPropertiesUpdate = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCIProtectedItemModelCustomPropertiesUpdate]::new()
            $customPropertiesUpdate.InstanceType = $AzLocalInstanceTypes.VMwareToAzLocal
        }

        # Update target CPU core
        if ($HasTargetVMCPUCore) {
            if ($TargetVMCPUCore -le 0) {
                throw "Specify target CPU core greater than 0"    
            }

            $customPropertiesUpdate.TargetCpuCore = $TargetVMCPUCore
        }

        # Update VM Ram
        if ($HasTargetVMRam) {
            if ($TargetVMRam -le 0) {
                throw "Specify target RAM greater than 0"    
            }

            $customPropertiesUpdate.TargetMemoryInMegaByte = $TargetVMRam
        }
        $targetMemory = $customPropertiesUpdate.TargetMemoryInMegaByte -or $customProperties.TargetMemoryInMegaByte

        # Update IsDynamicRam 
        if ($HasIsDynamicMemoryEnabled) {
            $customPropertiesUpdate.IsDynamicRam = $isDynamicRamEnabled
        }
        elseif ($HasDynamicMemoryConfig) {
            $customPropertiesUpdate.IsDynamicRam = $customProperties.IsDynamicRam
        }

        # Dynamic memory is enabled - set provided configuration
        if ($customPropertiesUpdate.IsDynamicRam -and $HasDynamicMemoryConfig) {
            if ($targetMemory -lt $DynamicMemoryConfig.MinimumMemoryInMegaByte) {
                throw "DynamicMemoryConfig - Specify minimum memory less than $($targetMemory)"
            }
          
            if ($targetMemory -gt $DynamicMemoryConfig.MaximumMemoryInMegaByte) {
                throw "DynamicMemoryConfig - Specify maximum memory greater than $($targetMemory)"
            }

            if ($DynamicMemoryConfig.TargetMemoryBufferPercentage -NotIn $RAMConfig.MinTargetMemoryBufferPercentage..$RAMConfig.MaxTargetMemoryBufferPercentage)
            {
                throw "DynamicMemoryConfig - Specify target memory buffer percentage between $($RAMConfig.MinTargetMemoryBufferPercentage) % and $($RAMConfig.MaxTargetMemoryBufferPercentage) %."
            }

            $customPropertiesUpdate.DynamicMemoryConfig = $DynamicMemoryConfig
        }

        # Dynamic memory is enabled - set default configuration
        if ($customPropertiesUpdate.IsDynamicRam -and !$HasDynamicMemoryConfig) {
            if ($null -eq $customProperties.DynamicMemoryConfig) {
                $memoryConfig = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemDynamicMemoryConfig]::new()
                $memoryConfig.MinimumMemoryInMegaByte = [System.Math]::Min($targetMemory, $RAMConfig.DefaultMinDynamicMemoryInMB)
                $memoryConfig.MaximumMemoryInMegaByte = [System.Math]::Max($targetMemory, $RAMConfig.DefaultMaxDynamicMemoryInMB)
                $memoryConfig.TargetMemoryBufferPercentage = $RAMConfig.DefaultTargetMemoryBufferPercentage
                $customPropertiesUpdate.DynamicMemoryConfig = $memoryConfig
            }
            else {
                $customPropertiesUpdate.DynamicMemoryConfig = $customProperties.DynamicMemoryConfig
            }
        }
        
        # Update Nics
        if ($HasNicToInclude -and $NicToInclude.length -gt 0) {
            # Get discovered machine
            $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
            $null = $PSBoundParameters.Add("SiteName", $SiteName)
            $null = $PSBoundParameters.Add("MachineName", $MachineName)
            
            if ($SiteType -eq $SiteTypes.HyperVSites) {
                $machine = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVMachine' `
                    -Parameters $PSBoundParameters `
                    -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {
                $machine = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateMachine' `
                    -Parameters $PSBoundParameters `
                    -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."
            }

            $null = $PSBoundParameters.Remove("ResourceGroupName")
            $null = $PSBoundParameters.Remove("SiteName")
            $null = $PSBoundParameters.Remove("MachineName")
            
            # Nics
            [PSCustomObject[]]$nics = @()
            [PSCustomObject[]]$uniqueNics = @()
            foreach ($nic in $NicToInclude) {
                $discoveredNic = $machine.NetworkAdapter | Where-Object { $_.NicId -eq $nic.NicId }
                if ($null -eq $discoveredNic) {
                    throw "The Nic id '$($nic.NicId)' is not found."
                }

                if ($uniqueNics.Contains($nic.NicId)) {
                    throw "The Nic id '$($nic.NicId)' is already included. Please remove the duplicate entry and try again."
                }

                $uniqueNics += $nic.NicId
                
                $htNic = @{}
                $nic.PSObject.Properties | ForEach-Object { $htNic[$_.Name] = $_.Value }

                if ($htNic.SelectionTypeForFailover -eq $VMNicSelection.SelectedByUser -and
                    [string]::IsNullOrEmpty($htNic.TargetNetworkId)) {
                    throw "The TargetVirtualSwitchId parameter is required when the CreateAtTarget flag is set to 'true'. NIC '$($htNic.NicId)'. Please utilize the New-AzMigrateLocalNicMappingObject command to properly create a Nic mapping object."
                }

                $nics += [PSCustomObject]$htNic
            }

            if ($SiteType -eq $SiteTypes.HyperVSites) {     
                $customPropertiesUpdate.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCINicInput[]]$nics
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {     
                $customPropertiesUpdate.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCINicInput[]]$nics
            }
        }

        $protectedItemPropertiesUpdate = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemModelPropertiesUpdate]::new()
        $protectedItemPropertiesUpdate.CustomProperty = $customPropertiesUpdate

        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('VaultName', $vaultName)
        $null = $PSBoundParameters.Add('Name', $MachineName)
        $null = $PSBoundParameters.Add('Property', $protectedItemPropertiesUpdate)
        $null = $PSBoundParameters.Add('NoWait', $true)
        
        if ($PSCmdlet.ShouldProcess($TargetObjectID, "Updates VM replication.")) {
            $operation = Az.Migrate.Internal\Update-AzMigrateProtectedItem @PSBoundParameters
            $jobName = $operation.Target.Split("/")[-1].Split("?")[0].Split("_")[0]
            
            $null = $PSBoundParameters.Remove('Name')  
            $null = $PSBoundParameters.Remove('Property')
            $null = $PSBoundParameters.Remove('NoWait')

            $null = $PSBoundParameters.Add('JobName', $jobName)
            return Az.Migrate.Internal\Get-AzMigrateLocalReplicationJob @PSBoundParameters
        }
    }
}   
# SIG # Begin signature block
# MIIoQgYJKoZIhvcNAQcCoIIoMzCCKC8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAamq+nBxJGSgzz
# WX/o5LEX5fCg4jItLyVyxb8TorOchqCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGiIwghoeAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEICGW3j1y4Nur/G32asq5Rr+Z
# PokTE1kiepRJtSJDiToKMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAn/2XOHy5uTdFj4jfkxX4eZ1EGhXPJyr9PNbGbYwHbPj/gpIxhBip4RLD
# KinA1fLOGLeVJfDbSxcGPJRFZ7KZFQk9CvDLtwJMjcc/y/NXBu4vPsEaH6QX8lo+
# WV+ZI8HIVc9kFcS9bCHyUFaCqxoJLZqatLfx1u7axtcN22Lnxq5N9gQnMFEvxciO
# nPl8zqJWnw9TPcqiuPQ0ACtolOwdMEtFbELCzN1wQl66XxXhuMKk+au+cEXb+wy9
# +12mHCUO6vRzhDnjvnMIh1/BDjgPopxo2H1TiiDDTamaJW+o2eLyrCF6tfH5Lg45
# o4AUn00yxxR6iUxETbD7P31zm6+kL6GCF6wwgheoBgorBgEEAYI3AwMBMYIXmDCC
# F5QGCSqGSIb3DQEHAqCCF4UwgheBAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFZBgsq
# hkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDL0+GbeSWtHnm8YWMNI9b9Ee8bNbCWQRRC65n8YXlucgIGaC4ZUoCo
# GBIyMDI1MDUyODA3MzE0Ni40NVowBIACAfSggdmkgdYwgdMxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVs
# YW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNO
# OjQzMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloIIR+zCCBygwggUQoAMCAQICEzMAAAH6+ztE03czxtMAAQAAAfowDQYJ
# KoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjQw
# NzI1MTgzMTExWhcNMjUxMDIyMTgzMTExWjCB0zELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3Bl
# cmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046NDMxQS0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDKFlUEzc9lwF8SkB/t8giH
# KDBhVU/rhRJ5ltKVFHem8l5u9rQtAINbjnI6u2nAikbIMZf4RsJseFLlN3gnRiVz
# zfO0sRttAPszqSpHReP6fzZwax79CcwfRZFkufCCAl16elDpRyIzicxhm91CPJsD
# ip6M571jTvcmVe/dUht2RAfYkbJPygH8uy88v+QCcnjmhAintLHntE9D/Q7qprIn
# ZImvByMDxq4x0Cdko6LEWXOiiiHtLLJwjsEQ0dOmRUqtFXlh6VG9Y1ODWkfgQLYo
# 7ZvGwE3bdu0x5O9kWJ4Yiv4PyZ/WVBCzQe3+0w5V1qHXi3tiT7GXk/hPDfF8AaAe
# y+xrq6CvHCYpNNfWSpcflcJ3DdNV4oJrHolX7KAzmLU2ugkrAEJbXU/CLTP+SL3R
# l47pd8QT2YKcmbvpBzGLe2db9j/dm6YpDpf+JUgmjsuTRn+kBNHAAg2rB2/Ol21f
# aE4mJvgZHyKzZukqSzTga6t/B5Y+f3PqNjsYEL6OzylLAZ7Ct9/CABs0qbzZkMW+
# oEZBBUnAgdJemORL4bf17Jg4batwgsEgOXNTMwUUls2Hm0O/cZ4ncQq8Li81IDG0
# Z9ob+ZCErjdiN6+wHvYui5TvyvG02G4xdLNoerl8WIbfNyxgdprj7D5iYyuFMTMP
# hICKyHfkGOhc/U/UK3hVrQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFGOMcpsvlZXq
# R3ToqhxAemEr1T+/MB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQC4VsKisWu+h0b5
# k0kfdj43PlClTK1BU5s7JgWuBwavGroxRrjIubE3jFZ0vWTKBpbkE5nfEGU9jtWm
# 5/lvl5pc/upGrrXF46tfd/riQaJJahGL0QlrAlYLMl9RBFOEMvjPEjalhzXCc+nt
# Dr3lserBnTZ5o4G52H8h8SQZ7Q5+PohLejJmwk/XJq1ybiQGogfp1vX7B4zirjo2
# EB8B/TvTMXoX4ilQfKG0xtCDn5Ad867IHOu3rsKIwlIpwnecxXJ82We/rK+21jMs
# rfBL7RDAlSJstgkwjoUZxK5HEqWrpGM6Er0vdA6OHRUIzXWsczXVmY3R64ltsEJV
# 9AS584s2QbzwwUJQ0TXRJJsz86D8JtOSjQznBtW9AnoKosqO0dKh6gAY955fbh/l
# w9jJNwqVszouhR07Y/klJ0jmzUkX86fouJRPnRp2lGy1lqNtgR5f83tG9JuSfR2M
# PcG9PY5/dZ/2Ah5pAgdu/UnY78/lA49CJWjz7QAqbozRMo526KGErEC3/pjKTXsW
# /dEh2NPrCIvapEgSyA4mnd8gvDiZBE+7eylF9qRKhB7k3R7gdYV/xZbZkvT5zzdD
# OHdW0Q8jpjZ7YE795aFNhshsempgN8C0Bi1pgh17ztnKZcbcw7bBSOEv0e9JDOOi
# q6r46hSa98FRwHZ7kvpAIc7qpM7tajCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNWMIICPgIBATCCAQGhgdmkgdYwgdMxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVs
# YW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNO
# OjQzMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQD3hn5tQmf6crAG8gjqyDQ3Lto8NqCBgzCB
# gKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUA
# AgUA6+EpDzAiGA8yMDI1MDUyODA2MTc1MVoYDzIwMjUwNTI5MDYxNzUxWjB0MDoG
# CisGAQQBhFkKBAExLDAqMAoCBQDr4SkPAgEAMAcCAQACAhHaMAcCAQACAhOxMAoC
# BQDr4nqPAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEA
# AgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAIwdsapahaCF+jyF
# O9SYgDpoU1ZlaTU6Y+cBIAVfaQT/QzLMDdNaxCJZVMb29l6KoIFK8rBoaM8Gbu8F
# UwJMINazNWHinfG1JQKLQg0fDnLRxd42Vs/sQLhOTccbcxHFa8AXsMfRRJn3xR+G
# YxcUCUE/CtwU+iN4I7u93lMnnvZmLFuynxbdtGc2gFIVljDCMfz9kTnZhqyIlx1x
# t/rNCxqjJ/F33HFxM3kN4Vp4Uf1P8He/6xLoEN/nnL3PnV4fT9YCjLnrlZZy4RRj
# GWh86tbANzZE8kfBlY5+5D4oW3qOwQ82WR6Gn/znqqjN0g+5sKYS9dHHwiIAP5zc
# +2euocgxggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAfr7O0TTdzPG0wABAAAB+jANBglghkgBZQMEAgEFAKCCAUowGgYJKoZI
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCB6fl+GwtOujEYa
# OTgd8CuIHbAZSBMf5vHhKBINy0dxtzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQw
# gb0EIH3yfy3Jrz4HaONT92klEjAfAcelyjmiA1K1ihxuQ55WMIGYMIGApH4wfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAH6+ztE03czxtMAAQAAAfow
# IgQg1+BYE7v46Vg80wFPN7yKbazSvIUWLox712/mOn0JvF4wDQYJKoZIhvcNAQEL
# BQAEggIAqUFfM6N4arqXgL7t67CV9sh7bjzQlduSNOnzK1swIMVXOnZksOVPAfJz
# OhzaLlobgx8/Hguh4nOp9LtvlrXpQFhB8vLWmvNcNYOOWk7sYvtyf+k77w/fZeX6
# pw0nwVbStUckTkIMlozGumyQ+A1jmndwFfb6NrrxxTvMxh9OXKX21yIdwLg14Omt
# HBowHmgE0xOxQp9eD/w00t6twkYmIIZOz8m3sWfwq+JkVwfSJ/E3+i3WsM342+jz
# QDkXywhIDANiMZRU0ykWSI3yB0MomRdxqT9dmqRLOV/G6T3QoZHIOZ14+nC5Hy75
# hw37F7HeacmQsxd/R74ePNbYGdShXmYRWmxGYZZogLAdNcYNdVW7i4/c87a+hS5U
# D5pF83ayEKwyhgWuT8LuGSmrcGYG74DDwwKf6VYdWS2q2SnjMlpoqD91Z2MDO+FI
# q2/juo0d6w5unMfYDi/ky4oDjkdVy4X5JA9Ts17WlE/dPuExtq2nSv1HSLR+6ILN
# veVF1RLuvz9Vk5Ntm1PKLVdK5wS6Gv1GzKJkja2DgAxFKdNGyaS4czCesQ8hHV52
# /yaglb0iJZh808EbNeoe9GHSBA7Em0EjXqz1SWXv9GCbOCw4b4a05qLy0udiAOe9
# sjOAzeuQAr0x5getgD9dgwTI0PcvxR20W6E5zUqz+sriDilfgHQ=
# SIG # End signature block
