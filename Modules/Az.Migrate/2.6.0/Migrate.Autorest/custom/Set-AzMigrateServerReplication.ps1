
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
The Set-AzMigrateServerReplication cmdlet updates the target properties for the replicating server.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/set-azmigrateserverreplication
#>
function Set-AzMigrateServerReplication {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IJob])]
    [CmdletBinding(DefaultParameterSetName = 'ByIDVMwareCbt', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ByIDVMwareCbt', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the replcating server for which the properties need to be updated. The ID should be retrieved using the Get-AzMigrateServerReplication cmdlet.
        ${TargetObjectID},

        [Parameter(ParameterSetName = 'ByInputObjectVMwareCbt', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IMigrationItem]
        # Specifies the replicating server for which the properties need to be updated. The server object can be retrieved using the Get-AzMigrateServerReplication cmdlet.
        ${InputObject},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the replcating server for which the properties need to be updated. The ID should be retrieved using the Get-AzMigrateServerReplication cmdlet.
        ${TargetVMName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure VM to be created.
        ${TargetDiskName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Updates the SKU of the Azure VM to be created.
        ${TargetVMSize},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Updates the Virtual Network id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetNetworkId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Updates the Virtual Network id within the destination Azure subscription to which the server needs to be test migrated.
        ${TestNetworkId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Updates the Resource Group id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetResourceGroupID},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtNicInput[]]
        # Updates the NIC for the Azure VM to be created.
        ${NicToUpdate},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtUpdateDiskInput[]]
        # Updates the disk for the Azure VM to be created.
        ${DiskToUpdate},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Set to be used for VM creation.
        ${TargetAvailabilitySet},
        
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Zone to be used for VM creation.
        ${TargetAvailabilityZone},

        [Parameter()]
        [ValidateSet("NoLicenseType" , "PAYG" , "AHUB")]
        [ArgumentCompleter( { "NoLicenseType" , "PAYG" , "AHUB" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit for SQL Server is applicable for the server to be migrated.
        ${SqlServerLicenseType},

        [Parameter()]
        [ValidateSet( "NotSpecified", "NoLicenseType", "LinuxServer")]
        [ArgumentCompleter( { "NotSpecified", "NoLicenseType", "LinuxServer" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit is applicable for the source linux server to be migrated.
        ${LinuxLicenseType},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Collections.Hashtable]
        # Specifies the tag to be used for Resource creation.
        ${UpdateTag},

        [Parameter()]
        [ValidateSet("Merge" , "Replace" , "Delete")]
        [ArgumentCompleter( { "Merge" , "Replace" , "Delete" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies update tag operation.
        ${UpdateTagOperation},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtEnableMigrationInputTargetVmtags]
        # Specifies the tag to be used for VM creation.
        ${UpdateVMTag},

        [Parameter()]
        [ValidateSet("Merge" , "Replace" , "Delete")]
        [ArgumentCompleter( { "Merge" , "Replace" , "Delete" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies update VM tag operation.
        ${UpdateVMTagOperation},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtEnableMigrationInputTargetNicTags]
        # Specifies the tag to be used for NIC creation.
        ${UpdateNicTag},

        [Parameter()]
        [ValidateSet("Merge" , "Replace" , "Delete")]
        [ArgumentCompleter( { "Merge" , "Replace" , "Delete" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies update NIC tag operation.
        ${UpdateNicTagOperation},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtEnableMigrationInputTargetDiskTags]
        # Specifies the tag to be used for disk creation.
        ${UpdateDiskTag},

        [Parameter()]
        [ValidateSet("Merge" , "Replace" , "Delete")]
        [ArgumentCompleter( { "Merge" , "Replace" , "Delete" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies update disk tag operation.
        ${UpdateDiskTagOperation},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the storage account to be used for boot diagnostics.
        ${TargetBootDiagnosticsStorageAccount},

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

        $HasTargetVMName = $PSBoundParameters.ContainsKey('TargetVMName')
        $HasTargetDiskName = $PSBoundParameters.ContainsKey('TargetDiskName')
        $HasTargetVmSize = $PSBoundParameters.ContainsKey('TargetVMSize')
        $HasTargetNetworkId = $PSBoundParameters.ContainsKey('TargetNetworkId')
        $HasTestNetworkId = $PSBoundParameters.ContainsKey('TestNetworkId')
        $HasTargetResourceGroupID = $PSBoundParameters.ContainsKey('TargetResourceGroupID')
        $HasNicToUpdate = $PSBoundParameters.ContainsKey('NicToUpdate')
        $HasDiskToUpdate = $PSBoundParameters.ContainsKey('DiskToUpdate')
        $HasTargetAvailabilitySet = $PSBoundParameters.ContainsKey('TargetAvailabilitySet')
        $HasTargetAvailabilityZone = $PSBoundParameters.ContainsKey('TargetAvailabilityZone')
        $HasSqlServerLicenseType = $PSBoundParameters.ContainsKey('SqlServerLicenseType')
        $HasLinuxLicenseType = $PSBoundParameters.ContainsKey('LinuxLicenseType')
        $HasUpdateTag = $PSBoundParameters.ContainsKey('UpdateTag')
        $HasUpdateTagOperation = $PSBoundParameters.ContainsKey('UpdateTagOperation')
        $HasUpdateVMTag = $PSBoundParameters.ContainsKey('UpdateVMTag')
        $HasUpdateVMTagOperation = $PSBoundParameters.ContainsKey('UpdateVMTagOperation')
        $HasUpdateNicTag = $PSBoundParameters.ContainsKey('UpdateNicTag')
        $HasUpdateNicTagOperation = $PSBoundParameters.ContainsKey('UpdateNicTagOperation')
        $HasUpdateDiskTag = $PSBoundParameters.ContainsKey('UpdateDiskTag')
        $HasUpdateDiskTagOperation = $PSBoundParameters.ContainsKey('UpdateDiskTagOperation')
        $HasTargetBootDignosticStorageAccount = $PSBoundParameters.ContainsKey('TargetBootDiagnosticsStorageAccount')

        $null = $PSBoundParameters.Remove('TargetObjectID')
        $null = $PSBoundParameters.Remove('TargetVMName')
        $null = $PSBoundParameters.Remove('TargetDiskName')
        $null = $PSBoundParameters.Remove('TargetVMSize')
        $null = $PSBoundParameters.Remove('TargetNetworkId')
        $null = $PSBoundParameters.Remove('TestNetworkId')
        $null = $PSBoundParameters.Remove('TargetResourceGroupID')
        $null = $PSBoundParameters.Remove('NicToUpdate')
        $null = $PSBoundParameters.Remove('DiskToUpdate')
        $null = $PSBoundParameters.Remove('TargetAvailabilitySet')
        $null = $PSBoundParameters.Remove('TargetAvailabilityZone')
        $null = $PSBoundParameters.Remove('SqlServerLicenseType')
        $null = $PSBoundParameters.Remove('LinuxLicenseType')
        $null = $PSBoundParameters.Remove('UpdateTag')
        $null = $PSBoundParameters.Remove('UpdateTagOperation')
        $null = $PSBoundParameters.Remove('UpdateVMTag')
        $null = $PSBoundParameters.Remove('UpdateVMTagOperation')
        $null = $PSBoundParameters.Remove('UpdateNicTag')
        $null = $PSBoundParameters.Remove('UpdateNicTagOperation')
        $null = $PSBoundParameters.Remove('UpdateDiskTag')
        $null = $PSBoundParameters.Remove('UpdateDiskTagOperation')

        $null = $PSBoundParameters.Remove('InputObject')
        $null = $PSBoundParameters.Remove('TargetBootDiagnosticsStorageAccount')
        $parameterSet = $PSCmdlet.ParameterSetName

        if ($parameterSet -eq 'ByInputObjectVMwareCbt') {
            $TargetObjectID = $InputObject.Id
        }
        $MachineIdArray = $TargetObjectID.Split("/")
        $ResourceGroupName = $MachineIdArray[4]
        $VaultName = $MachineIdArray[8]
        $FabricName = $MachineIdArray[10]
        $ProtectionContainerName = $MachineIdArray[12]
        $MachineName = $MachineIdArray[14]
            
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("ResourceName", $VaultName)
        $null = $PSBoundParameters.Add("FabricName", $FabricName)
        $null = $PSBoundParameters.Add("MigrationItemName", $MachineName)
        $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)
            
        $ReplicationMigrationItem = Az.Migrate.internal\Get-AzMigrateReplicationMigrationItem @PSBoundParameters
        if ($ReplicationMigrationItem -and ($ReplicationMigrationItem.ProviderSpecificDetail.InstanceType -eq 'VMwarecbt')) {
            $ProviderSpecificDetails = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtUpdateMigrationItemInput]::new()
                
            # Auto fill unchanged parameters
            $ProviderSpecificDetails.InstanceType = 'VMwareCbt'
            $ProviderSpecificDetails.LicenseType = $ReplicationMigrationItem.ProviderSpecificDetail.LicenseType
            $ProviderSpecificDetails.PerformAutoResync = $ReplicationMigrationItem.ProviderSpecificDetail.PerformAutoResync
                
            if ($HasTargetAvailabilitySet) {
                $ProviderSpecificDetails.TargetAvailabilitySetId = $TargetAvailabilitySet
            }
            else {
                $ProviderSpecificDetails.TargetAvailabilitySetId = $ReplicationMigrationItem.ProviderSpecificDetail.TargetAvailabilitySetId
            }

            if ($HasTargetAvailabilityZone) {
                $ProviderSpecificDetails.TargetAvailabilityZone = $TargetAvailabilityZone
            }
            else {
                $ProviderSpecificDetails.TargetAvailabilityZone = $ReplicationMigrationItem.ProviderSpecificDetail.TargetAvailabilityZone
            }

            if ($HasSqlServerLicenseType) {
                $validSqlLicenseSpellings = @{ 
                    NoLicenseType = "NoLicenseType";
                    PAYG          = "PAYG";
                    AHUB          = "AHUB"
                }
                $SqlServerLicenseType = $validSqlLicenseSpellings[$SqlServerLicenseType]
                $ProviderSpecificDetails.SqlServerLicenseType = $SqlServerLicenseType
            }
            else {
                $ProviderSpecificDetails.SqlServerLicenseType = $ReplicationMigrationItem.ProviderSpecificDetail.SqlServerLicenseType
            }

            if ($HasLinuxLicenseType) {
                $validLinuxLicenseSpellings = @{ 
                    NotSpecified  = "NotSpecified";
                    NoLicenseType = "NoLicenseType";
                    LinuxServer   = "LinuxServer";
                }
                $LinuxLicenseType = $validLinuxLicenseSpellings[$LinuxLicenseType]
                $ProviderSpecificDetails.LinuxLicenseType = $LinuxLicenseType
            }
            else {
                $ProviderSpecificDetails.LinuxLicenseType = $ReplicationMigrationItem.ProviderSpecificDetail.LinuxLicenseType
            }

            $UserProvidedTag = $null
            if ($HasUpdateTag -And $HasUpdateTagOperation -And $UpdateTag) {
                $operation = @("UpdateTag", $UpdateTagOperation)
                $UserProvidedTag += @{$operation = $UpdateTag }
            }

            if ($HasUpdateVMTag -And $HasUpdateVMTagOperation -And $UpdateVMTag) {
                $operation = @("UpdateVMTag", $UpdateVMTagOperation)
                $UserProvidedTag += @{$operation = $UpdateVMTag }
            }
            else {
                $ProviderSpecificDetails.TargetVmTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag
            }

            if ($HasUpdateNicTag -And $HasUpdateNicTagOperation -And $UpdateNicTag) {
                $operation = @("UpdateNicTag", $UpdateNicTagOperation)
                $UserProvidedTag += @{$operation = $UpdateNicTag }
            }
            else {
                $ProviderSpecificDetails.TargetNicTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag
            }

            if ($HasUpdateDiskTag -And $HasUpdateDiskTagOperation -And $UpdateDiskTag) {
                $operation = @("UpdateDiskTag", $UpdateDiskTagOperation)
                $UserProvidedTag += @{$operation = $UpdateDiskTag }
            }
            else {
                $ProviderSpecificDetails.TargetDiskTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag
            }

            foreach ($tag in $UserProvidedTag.Keys) {
                $IllegalCharKey = New-Object Collections.Generic.List[String]
                $ExceededLengthKey = New-Object Collections.Generic.List[String]
                $ExceededLengthValue = New-Object Collections.Generic.List[String]
                $ResourceTag = $($UserProvidedTag.Item($tag))

                foreach ($key in $ResourceTag.Keys) {
                    if ($key.length -eq 0) {
                        throw "InvalidTagName : The tag name must be non-null, non-empty and non-whitespace only. Please provide an actual value."
                    }

                    if ($key.length -gt 512) {
                        $ExceededLengthKey.add($key)
                    }

                    if ($key -match "[<>%&\?/.]") {
                        $IllegalCharKey.add($key)
                    }

                    if ($($ResourceTag.Item($key)).length -gt 256) {
                        $ExceededLengthValue.add($($ResourceTag.Item($key)))
                    }
                }

                if ($IllegalCharKey.Count -gt 0) {
                    throw "InvalidTagNameCharacters : The tag names '$($IllegalCharKey -join ', ')' have reserved characters '<,>,%,&,\,?,/' or control characters."
                }

                if ($ExceededLengthKey.Count -gt 0) {
                    throw "InvalidTagName : Tag key too large. Following tag name '$($ExceededLengthKey -join ', ')' exceeded the maximum length. Maximum allowed length for tag name - '512' characters."
                }

                if ($ExceededLengthValue.Count -gt 0) {
                    throw "InvalidTagValueLength : Tag value too large. Following tag value '$($ExceededLengthValue -join ', ')' exceeded the maximum length. Maximum allowed length for tag value - '256' characters."
                }

                if ($tag[1] -eq "Merge") {
                    foreach ($key in $ResourceTag.Keys) {
                        if ($ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag.ContainsKey($key) -And `
                            ($tag[0] -eq "UpdateVMTag" -or $tag[0] -eq "UpdateTag")) {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag.Remove($key)
                        }

                        if ($ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag.ContainsKey($key) -And `
                            ($tag[0] -eq "UpdateNicTag" -or $tag[0] -eq "UpdateTag")) {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag.Remove($key)
                        }

                        if ($ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag.ContainsKey($key) -And `
                            ($tag[0] -eq "UpdateDiskTag" -or $tag[0] -eq "UpdateTag")) {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag.Remove($key)
                        }

                        if ($tag[0] -eq "UpdateVMTag" -or $tag[0] -eq "UpdateTag") {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag.Add($key, $($ResourceTag.Item($key)))
                        }

                        if ($tag[0] -eq "UpdateNicTag" -or $tag[0] -eq "UpdateTag") {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag.Add($key, $($ResourceTag.Item($key)))
                        }

                        if ($tag[0] -eq "UpdateDiskTag" -or $tag[0] -eq "UpdateTag") {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag.Add($key, $($ResourceTag.Item($key)))
                        }
                    }
                    
                    $ProviderSpecificDetails.TargetVmTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag
                    $ProviderSpecificDetails.TargetNicTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag
                    $ProviderSpecificDetails.TargetDiskTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag
                }
                elseif ($tag[1] -eq "Replace") {
                    if ($tag[0] -eq "UpdateVMTag" -or $tag[0] -eq "UpdateTag") {
                        $ProviderSpecificDetails.TargetVmTag = $ResourceTag
                    }

                    if ($tag[0] -eq "UpdateNicTag" -or $tag[0] -eq "UpdateTag") {
                        $ProviderSpecificDetails.TargetNicTag = $ResourceTag
                    }

                    if ($tag[0] -eq "UpdateDiskTag" -or $tag[0] -eq "UpdateTag") {
                        $ProviderSpecificDetails.TargetDiskTag = $ResourceTag
                    }
                }
                else {
                    foreach ($key in $ResourceTag.Keys) {
                        if (($tag[0] -eq "UpdateVMTag" -or $tag[0] -eq "UpdateTag") `
                                -And $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag.ContainsKey($key) `
                                -And ($($ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag.Item($key)) `
                                    -eq $($ResourceTag.Item($key)))) {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag.Remove($key)
                        }

                        if (($tag[0] -eq "UpdateNicTag" -or $tag[0] -eq "UpdateTag") `
                                -And $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag.ContainsKey($key) `
                                -And ($($ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag.Item($key)) `
                                    -eq $($ResourceTag.Item($key)))) {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag.Remove($key)
                        }

                        if (($tag[0] -eq "UpdateDiskTag" -or $tag[0] -eq "UpdateTag") `
                                -And $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag.ContainsKey($key) `
                                -And ($($ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag.Item($key)) `
                                    -eq $($ResourceTag.Item($key)))) {
                            $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag.Remove($key)
                        }
                    }

                    $ProviderSpecificDetails.TargetVmTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmTag
                    $ProviderSpecificDetails.TargetNicTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetNicTag
                    $ProviderSpecificDetails.TargetDiskTag = $ReplicationMigrationItem.ProviderSpecificDetail.TargetDiskTag
                }

                if ($ProviderSpecificDetails.TargetVmTag.Count -gt 50) {
                    throw "InvalidTags : Too many tags specified. Requested tag count - '$($ProviderSpecificDetails.TargetVmTag.Count)'. Maximum number of tags allowed - '50'."
                }

                if ($ProviderSpecificDetails.TargetNicTag.Count -gt 50) {
                    throw "InvalidTags : Too many tags specified. Requested tag count - '$($ProviderSpecificDetails.TargetNicTag.Count)'. Maximum number of tags allowed - '50'."
                }

                if ($ProviderSpecificDetails.TargetDiskTag.Count -gt 50) {
                    throw "InvalidTags : Too many tags specified. Requested tag count - '$($ProviderSpecificDetails.TargetDiskTag.Count)'. Maximum number of tags allowed - '50'."
                }
            }

            if ($HasTargetNetworkId) {
                $ProviderSpecificDetails.TargetNetworkId = $TargetNetworkId
            }
            else {
                $ProviderSpecificDetails.TargetNetworkId = $ReplicationMigrationItem.ProviderSpecificDetail.TargetNetworkId
            }

            if ($HasTestNetworkId) {
                $ProviderSpecificDetails.TestNetworkId = $TestNetworkId
            }
            else {
                $ProviderSpecificDetails.TestNetworkId = $ReplicationMigrationItem.ProviderSpecificDetail.VMNic[0].TestNetworkId
            }

            if ($HasTargetResourceGroupID) {
                $ProviderSpecificDetails.TargetResourceGroupId = $TargetResourceGroupID
            }
            else {
                $ProviderSpecificDetails.TargetResourceGroupId = $ReplicationMigrationItem.ProviderSpecificDetail.TargetResourceGroupId
            }

            if ($HasTargetVmSize) {
                $ProviderSpecificDetails.TargetVMSize = $TargetVmSize
            }
            else {
                $ProviderSpecificDetails.TargetVMSize = $ReplicationMigrationItem.ProviderSpecificDetail.TargetVmSize
            }

            if ($HasTargetBootDignosticStorageAccount) {
                $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId = $TargetBootDiagnosticsStorageAccount
            }
            else {
                $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId = $ReplicationMigrationItem.ProviderSpecificDetail.TargetBootDiagnosticsStorageAccountId
            }

            # Storage accounts need to be in the same subscription as that of the VM.
            if (($null -ne $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId) -and ($ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId.length -gt 1)) {
                $TargetBDSASubscriptionId = $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId.Split('/')[2]
                $TargetSubscriptionId = $ProviderSpecificDetails.TargetResourceGroupId.Split('/')[2]
                if ($TargetBDSASubscriptionId -ne $TargetSubscriptionId) {
                    $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId = $null
                }
            }

            if ($HasTargetVMName) {
                if ($TargetVMName.length -gt 64 -or $TargetVMName.length -eq 0) {
                    throw "The target virtual machine name must be between 1 and 64 characters long."
                }
                $vmId = $ProviderSpecificDetails.TargetResourceGroupId + "/providers/Microsoft.Compute/virtualMachines/" + $TargetVMName
                $VMNamePresentinRg = Get-AzResource -ResourceId $vmId -ErrorVariable notPresent -ErrorAction SilentlyContinue
                if ($VMNamePresentinRg) {
                    throw "The target virtual machine name must be unique in the target resource group."
                }

                if ($TargetVMName -notmatch "^[^_\W][a-zA-Z0-9\-]{0,63}(?<![-._])$") {
                    throw "The target virtual machine name must begin with a letter or number, and can contain only letters, numbers, or hyphens(-). The names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'."
                }

                $ProviderSpecificDetails.TargetVMName = $TargetVMName
            }
            else {
                $ProviderSpecificDetails.TargetVMName = $ReplicationMigrationItem.ProviderSpecificDetail.TargetVMName
            }

            if ($HasDiskToUpdate) {
                $diskIdDiskTypeMap = @{}
                $originalDisks = $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk

                foreach($DiskObject in $originalDisks) {
                    if ($DiskObject.IsOSDisk -and $DiskObject.IsOSDisk -eq "True") {
                        $previousOsDiskId = $DiskObject.DiskId
                        Break
                    }
                }

                $diskNamePresentinRg = New-Object Collections.Generic.List[String]
                $duplicateDiskName = New-Object System.Collections.Generic.HashSet[String]
                $uniqueDiskUuids = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::InvariantCultureIgnoreCase)
                $osDiskCount = 0
                foreach($DiskObject in $DiskToUpdate) {
                    if ($DiskObject.IsOSDisk -eq "True") {
                        $osDiskCount++
                        $changeOsDiskId = $DiskObject.DiskId
                        if ($osDiskCount -gt 1) {
                            throw "Multiple disks have been selected as OS Disk."
                        }
                    }

                    $matchingUserInputDisk = $null
                    $originalDisks = $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk
                    foreach ($orgDisk in $originalDisks) {
                        if ($orgDisk.DiskId -eq $DiskObject.DiskId)
                        {
                            $matchingUserInputDisk = $orgDisk
                            break
                        }
                    }

                    if ($matchingUserInputDisk -ne $null -and [string]::IsNullOrEmpty($DiskObject.TargetDiskName)) {
                        $DiskObject.TargetDiskName = $matchingUserInputDisk.TargetDiskName
                    }

                    if ($matchingUserInputDisk -ne $null -and [string]::IsNullOrEmpty($DiskObject.IsOSDisk)) {
                        $DiskObject.IsOSDisk = $matchingUserInputDisk.IsOSDisk
                    }

                    $diskId = $ProviderSpecificDetails.TargetResourceGroupId + "/providers/Microsoft.Compute/disks/" + $DiskObject.TargetDiskName
                    $diskNamePresent = Get-AzResource -ResourceId $diskId -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    if ($diskNamePresent) {
                        $diskNamePresentinRg.Add($DiskObject.TargetDiskName)
                    }

                    if ($uniqueDiskUuids.Contains($DiskObject.DiskId)) {
                        throw "The disk uuid '$($DiskObject.DiskId)' is already taken."
                    }
                    $res = $uniqueDiskUuids.Add($DiskObject.DiskId)

                    if ($duplicateDiskName.Contains($DiskObject.TargetDiskName)) {
                        throw "The disk name '$($DiskObject.TargetDiskName)' is already taken."
                    }
                    $res = $duplicateDiskName.Add($DiskObject.TargetDiskName)
                }
                if ($diskNamePresentinRg) {
                    throw "Disks with name $($diskNamePresentinRg -join ', ')' already exists in the target resource group."
                }

                foreach($DiskObject in $DiskToUpdate) {
                    if ($DiskObject.IsOSDisk) {
                        $diskIdDiskTypeMap.Add($DiskObject.DiskId, $DiskObject.IsOSDisk)
                    }
                }

                if ($changeOsDiskId -ne $null -and $changeOsDiskId -ne $previousOsDiskId) {
                    if ($diskIdDiskTypeMap.ContainsKey($previousOsDiskId)) {
                        $rem = $diskIdDiskTypeMap.Remove($previousOsDiskId)
                        foreach($DiskObject in $DiskToUpdate) {
                            if ($DiskObject.DiskId -eq $previousOsDiskId) {
                                $DiskObject.IsOsDisk = "False"
                            }
                        }
                    }
                    else {
                        $updateDisk = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtUpdateDiskInput]::new()
                        $updateDisk.DiskId = $previousOsDiskId
                        $updateDisk.IsOSDisk = "False"
                        $originalDisks = $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk
                        foreach ($orgDisk in $originalDisks) {
                           if ($orgDisk.DiskId -eq $previousOsDiskId) {
                               $updateDisk.TargetDiskName = $orgDisk.TargetDiskName
                               break
                            }
                        }
                        $DiskToUpdate += $updateDisk
                    }
                    $diskIdDiskTypeMap.Add($previousOsDiskId, "False")
                }

                $osDiskCount = 0

                foreach ($DiskObject in $originalDisks) {
                   if ($diskIdDiskTypeMap.Contains($DiskObject.DiskId)) {
                       if ($diskIdDiskTypeMap.($DiskObject.DiskId) -eq "True") {
                           $osDiskCount++
                       }
                   }
                   elseif ($DiskObject.IsOSDisk -eq "True") {
                       $osDiskCount++
                   }
                }

                if ($osDiskCount -eq 0) {
                   throw "OS disk cannot be excluded from migration."
                }
                elseif ($osDiskCount -ne 1) {
                   throw "Multiple disks have been selected as OS Disk."
                }
               $ProviderSpecificDetails.VMDisK = $DiskToUpdate
            }

            if ($HasTargetDiskName) {
                if ($TargetDiskName.length -gt 80 -or $TargetDiskName.length -eq 0) {
                    throw "The disk name must be between 1 and 80 characters long."
                }

                if ($TargetDiskName -notmatch "^[^_\W][a-zA-Z0-9_\-\.]{0,79}(?<![-.])$") {
                    throw "The disk name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens."
                }

                $diskId = $ProviderSpecificDetails.TargetResourceGroupId + "/providers/Microsoft.Compute/disks/" + $TargetDiskName
                $diskNamePresent = Get-AzResource -ResourceId $diskId -ErrorVariable notPresent -ErrorAction SilentlyContinue

                if ($diskNamePresent) {
                    throw "A disk with name $($TargetDiskName)' already exists in the target resource group."
                }

                [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtUpdateDiskInput[]]$updateDisksArray = @()
                $originalDisks = $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk
                foreach ($DiskObject in $originalDisks) {
                    if ( $DiskObject.IsOSDisk) {
                        $updateDisk = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtUpdateDiskInput]::new()
                        $updateDisk.DiskId = $DiskObject.DiskId
                        $updateDisk.TargetDiskName = $TargetDiskName
                        $updateDisksArray += $updateDisk
                        $ProviderSpecificDetails.VMDisk = $updateDisksArray
                        break
                    }
                }
            }

            $originalNics = $ReplicationMigrationItem.ProviderSpecificDetail.VMNic
            [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtNicInput[]]$updateNicsArray = @()
            $nicNamePresentinRg = New-Object Collections.Generic.List[String]
            $duplicateNicName = New-Object System.Collections.Generic.HashSet[String]

            foreach ($storedNic in $originalNics) {
                $updateNic = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtNicInput]::new()
                $updateNic.IsPrimaryNic = $storedNic.IsPrimaryNic
                $updateNic.IsSelectedForMigration = $storedNic.IsSelectedForMigration
                $updateNic.NicId = $storedNic.NicId
                $updateNic.TargetStaticIPAddress = $storedNic.TargetIPAddress
                $updateNic.TestStaticIPAddress = $storedNic.TestIPAddress
                $updateNic.TargetSubnetName = $storedNic.TargetSubnetName
                $updateNic.TestSubnetName = $storedNic.TestSubnetName
                $updateNic.TargetNicName = $storedNic.TargetNicName

                $matchingUserInputNic = $null
                if ($HasNicToUpdate) {
                    foreach ($userInputNic in $NicToUpdate) {
                        if ($userInputNic.NicId -eq $storedNic.NicId) {
                            $matchingUserInputNic = $userInputNic
                            break
                        }
                    }
                }
                if ($null -ne $matchingUserInputNic) {
                    if ($null -ne $matchingUserInputNic.IsPrimaryNic) {
                        $updateNic.IsPrimaryNic = $matchingUserInputNic.IsPrimaryNic
                        $updateNic.IsSelectedForMigration = $matchingUserInputNic.IsSelectedForMigration
                        if ($updateNic.IsSelectedForMigration -eq "false") {
                            $updateNic.TargetSubnetName = ""
                            $updateNic.TargetStaticIPAddress = ""
                        }
                    }
                    if ($null -ne $matchingUserInputNic.TargetSubnetName) {
                        $updateNic.TargetSubnetName = $matchingUserInputNic.TargetSubnetName
                    }
                    if ($null -ne $matchingUserInputNic.TestSubnetName) {
                        $updateNic.TestSubnetName = $matchingUserInputNic.TestSubnetName
                    }
                    if ($null -ne $matchingUserInputNic.TargetNicName) {
                        $nicId = $ProviderSpecificDetails.TargetResourceGroupId + "/providers/Microsoft.Network/networkInterfaces/" + $matchingUserInputNic.TargetNicName
                        $nicNamePresent = Get-AzResource -ResourceId $nicId -ErrorVariable notPresent -ErrorAction SilentlyContinue

                        if ($nicNamePresent) {
                            $nicNamePresentinRg.Add($matchingUserInputNic.TargetNicName)
                        }
                        $updateNic.TargetNicName = $matchingUserInputNic.TargetNicName

                        if ($duplicateNicName.Contains($matchingUserInputNic.TargetNicName)) {
                            throw "The NIC name '$($matchingUserInputNic.TargetNicName)' is already taken."
                        }
                        $res = $duplicateNicName.Add($matchingUserInputNic.TargetNicName)
                    }
                    if ($null -ne $matchingUserInputNic.TargetStaticIPAddress) {
                        if ($matchingUserInputNic.TargetStaticIPAddress -eq "auto") {
                            $updateNic.TargetStaticIPAddress = $null
                        }
                        else {
                            $isValidIpAddress = [ipaddress]::TryParse($matchingUserInputNic.TargetStaticIPAddress,[ref][ipaddress]::Loopback)
                             if(!$isValidIpAddress) {
                                 throw "(InvalidPrivateIPAddressFormat) Static IP address value '$($matchingUserInputNic.TargetStaticIPAddress)' is invalid."
                             }
                             $updateNic.TargetStaticIPAddress = $matchingUserInputNic.TargetStaticIPAddress
                        }
                    }
                    if ($null -ne $matchingUserInputNic.TestStaticIPAddress) {
                        if ($matchingUserInputNic.TestStaticIPAddress -eq "auto") {
                            $updateNic.TestStaticIPAddress = $null
                        }
                        else {
                            $isValidIpAddress = [ipaddress]::TryParse($matchingUserInputNic.TestStaticIPAddress,[ref][ipaddress]::Loopback)
                             if(!$isValidIpAddress) {
                                 throw "(InvalidPrivateIPAddressFormat) Static IP address value '$($matchingUserInputNic.TestStaticIPAddress)' is invalid."
                             }
                             $updateNic.TestStaticIPAddress = $matchingUserInputNic.TestStaticIPAddress
                        }
                    }
                }
                $updateNicsArray += $updateNic
            }

            # validate there is exactly one primary nic
            $primaryNicCountInUpdate = 0
            foreach ($nic in $updateNicsArray) {
                if ($nic.IsPrimaryNic -eq "true") {
                    $primaryNicCountInUpdate += 1
                }
            }
            if ($primaryNicCountInUpdate -ne 1) {
                throw "One NIC has to be Primary."
            }

            if ($nicNamePresentinRg) {
                throw "NIC name '$($nicNamePresentinRg -join ', ')' must be unique in the target resource group."
            }

            $ProviderSpecificDetails.VMNic = $updateNicsArray
            $null = $PSBoundParameters.Add('ProviderSpecificDetail', $ProviderSpecificDetails)
            $null = $PSBoundParameters.Add('NoWait', $true)
            $output = Az.Migrate.internal\Update-AzMigrateReplicationMigrationItem @PSBoundParameters
            $JobName = $output.Target.Split("/")[12].Split("?")[0]

            $null = $PSBoundParameters.Remove('NoWait')
            $null = $PSBoundParameters.Remove('ProviderSpecificDetail')
            $null = $PSBoundParameters.Remove("ResourceGroupName")
            $null = $PSBoundParameters.Remove("ResourceName")
            $null = $PSBoundParameters.Remove("FabricName")
            $null = $PSBoundParameters.Remove("MigrationItemName")
            $null = $PSBoundParameters.Remove("ProtectionContainerName")

            $null = $PSBoundParameters.Add('JobName', $JobName)
            $null = $PSBoundParameters.Add('ResourceName', $VaultName)
            $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)

            return Az.Migrate.internal\Get-AzMigrateReplicationJob @PSBoundParameters
        }
        else {
            throw "Either machine doesn't exist or provider/action isn't supported for this machine"
        }
    }
}   
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBqMAeUjkn9cBDn
# +hu+kAKjRktCKNuDQ/8dt/5BT9LsKqCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIAyFwa8xmpg5KICPyfEH6/3y
# pWv1bowHD9vz/YRWzJDpMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAmc2H3jNeHPlSbsomQ+SIoPcKb0utsp1PDYwQpW1NBzyR1c1A0U1zDd6o
# pKk2v25faTHbbh9Kzz2yldlcdel2OpR/W1HO7/jinmFB0wOG6iT07yrA1sTZnVq6
# 7xgtyfPYmEYftJzTZY258iM8tGfXqcyzgSFKy79q2Z+6Qri/qZYOaLdq544qighl
# Fk96GDEnPkfCRNvZiv0lwfzSG2XM0xrjygH41OHKEeTcnO0NyYP9NUQ/E7IgIWpt
# 3gMfWKSVy8iIFtlRy/hXuGT6ki6muwe07nTCAz/obmB3UJdsgU6SJNDFkjWcs3iX
# aBdClB07427hmEkmXzjnXq1BMhozyKGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDE057wPTpvqxMO+DiQrx/2aIqQWUqi8jI5VBiBgADxDAIGZ1rYDqRx
# GBMyMDI1MDEwOTA2MzY1MS40ODZaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAevgGGy1tu847QABAAAB6zANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# MzRaFw0yNTAzMDUxODQ1MzRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDBFWgh2lbgV3eJp01oqiaFBuYbNc7hSKmktvJ15NrB
# /DBboUow8WPOTPxbn7gcmIOGmwJkd+TyFx7KOnzrxnoB3huvv91fZuUugIsKTnAv
# g2BU/nfN7Zzn9Kk1mpuJ27S6xUDH4odFiX51ICcKl6EG4cxKgcDAinihT8xroJWV
# ATL7p8bbfnwsc1pihZmcvIuYGnb1TY9tnpdChWr9EARuCo3TiRGjM2Lp4piT2lD5
# hnd3VaGTepNqyakpkCGV0+cK8Vu/HkIZdvy+z5EL3ojTdFLL5vJ9IAogWf3XAu3d
# 7SpFaaoeix0e1q55AD94ZwDP+izqLadsBR3tzjq2RfrCNL+Tmi/jalRto/J6bh4f
# PhHETnDC78T1yfXUQdGtmJ/utI/ANxi7HV8gAPzid9TYjMPbYqG8y5xz+gI/SFyj
# +aKtHHWmKzEXPttXzAcexJ1EH7wbuiVk3sErPK9MLg1Xb6hM5HIWA0jEAZhKEyd5
# hH2XMibzakbp2s2EJQWasQc4DMaF1EsQ1CzgClDYIYG6rUhudfI7k8L9KKCEufRb
# K5ldRYNAqddr/ySJfuZv3PS3+vtD6X6q1H4UOmjDKdjoW3qs7JRMZmH9fkFkMzb6
# YSzr6eX1LoYm3PrO1Jea43SYzlB3Tz84OvuVSV7NcidVtNqiZeWWpVjfavR+Jj/J
# OQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHSeBazWVcxu4qT9O5jT2B+qAerhMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCDdN8voPd8C+VWZP3+W87c/QbdbWK0sOt9
# Z4kEOWng7Kmh+WD2LnPJTJKIEaxniOct9wMgJ8yQywR8WHgDOvbwqdqsLUaM4Nre
# rtI6FI9rhjheaKxNNnBZzHZLDwlkL9vCEDe9Rc0dGSVd5Bg3CWknV3uvVau14F55
# ESTWIBNaQS9Cpo2Opz3cRgAYVfaLFGbArNcRvSWvSUbeI2IDqRxC4xBbRiNQ+1qH
# XDCPn0hGsXfL+ynDZncCfszNrlgZT24XghvTzYMHcXioLVYo/2Hkyow6dI7uULJb
# KxLX8wHhsiwriXIDCnjLVsG0E5bR82QgcseEhxbU2d1RVHcQtkUE7W9zxZqZ6/jP
# maojZgXQO33XjxOHYYVa/BXcIuu8SMzPjjAAbujwTawpazLBv997LRB0ZObNckJY
# yQQpETSflN36jW+z7R/nGyJqRZ3HtZ1lXW1f6zECAeP+9dy6nmcCrVcOqbQHX7Zr
# 8WPcghHJAADlm5ExPh5xi1tNRk+i6F2a9SpTeQnZXP50w+JoTxISQq7vBij2nitA
# sSLaVeMqoPi+NXlTUNZ2NdtbFr6Iir9ZK9ufaz3FxfvDZo365vLOozmQOe/Z+pu4
# vY5zPmtNiVIcQnFy7JZOiZVDI5bIdwQRai2quHKJ6ltUdsi3HjNnieuE72fT4eWh
# xtmnN5HYCDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkEwMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCA
# Bol1u1wwwYgUtUowMnqYvbul3qCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6ymWNTAiGA8yMDI1MDEwOTAwMjYy
# OVoYDzIwMjUwMTEwMDAyNjI5WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrKZY1
# AgEAMAcCAQACAhUpMAcCAQACAhMJMAoCBQDrKue1AgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAIHAmhLTSl+tqfMPnHFg24foG1zMFnOXn0DIotbJRVZDtlhF
# nPqSqCYuWMG+vt5lcw61eK9qKCrEL1Z3DME2BYjzUw4pvqj9S4ij9UXBcY7EsuZF
# xKynfZfrdMCTOQx8920OBKrkMuEZQIyhTbNOGFKIbVqAF1ZuNWC3k3d938tCrz6k
# O5nVvlHq0eMKKt0dmLBFNI5t6CmeGfb0gGg5/DxT5b7DLoU2WO/iX3YhbPO8FNpc
# g+onP0f7LP1tI4/67GHNCchp1IYsV2KHZ7V50TN63bGfo1U4AWWahgpxKX44Wl5K
# RAfCFw4sMxpUmJCvGkkLX92WpRPfW0D8+81HOZQxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAevgGGy1tu847QABAAAB6zAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCDTluC4GipVx1Sz/N2wJ/3lPfpkDxE8RBITVVnT+xZH5TCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIM63a75faQPhf8SBDTtk2DSUgIbd
# izXsz76h1JdhLCz4MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHr4BhstbbvOO0AAQAAAeswIgQg3a/qZy5c5u5kLf4EWs4lzDywFVJR
# 2BigcuxSIs4sgoQwDQYJKoZIhvcNAQELBQAEggIAPinnoqxaW3Bot0GZYzw/xFQf
# IEOJitvaR1oBuEadv+tcp0UkfsLxZaDoTtfHx7gvJLl4GToT+cO3mUtH80cJswP8
# 4+AUHI0K82jAgYeb3hJewYOxnXSvcedJ5KPrntIi8g0qzkBE2wsRlfO5n2iFZRM1
# qhMdxtOk9mBXlapXUbVGabIqXkuoDyfWfIMH65B9GiAK7s/Si54onWeVUA5s06UV
# YuZRUz4v0TJbXGnyCelpfmaICQxTRZh3uohGWLxnt+PFeC1rVftwyzCcjHFfxPlc
# QQ48OYlww10iHOR2vZtMfwwBvDiZUvv+VZ97vPqmxLflxpLrNAlDhgFJ1zkn2tnF
# wB4j6wRaUhiA8v99EupAo0L5D37eJGoMIca5f0vSo48TfaWsf1NAAkisqcSag+VA
# O2Btfa3z+MNBlRyj69wK07jFL/nWEt2n128isbxCAj4EHuJG723hv02U6ZhOmr3v
# LARBg4/DVWs48Y3aln2xrv6fXGnm+Z2OedcGDAW0sSkBk86nQBkzJ3e+HdtE4Iie
# szPT6BS5eqyHazgNFAcHfoLVCf9q2VriQiAlvMyiiyr7YoMj6QCO+nqy/OzIsZbS
# sDnSHFTypjMiiQAkV1KgBk/09TIHWKf5BZqfqR3IgyQ/d+NPT0rU8l9toqQtqcxx
# Tqa+VtgJFwP2qiujSnU=
# SIG # End signature block
