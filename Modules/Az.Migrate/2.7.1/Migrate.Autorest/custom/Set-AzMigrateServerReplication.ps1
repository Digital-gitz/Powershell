
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
# MIIoQgYJKoZIhvcNAQcCoIIoMzCCKC8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGiIwghoeAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
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
# aBdClB07427hmEkmXzjnXq1BMhozyKGCF6wwgheoBgorBgEEAYI3AwMBMYIXmDCC
# F5QGCSqGSIb3DQEHAqCCF4UwgheBAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFWBgsq
# hkiG9w0BCRABBKCCAUUEggFBMIIBPQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDE057wPTpvqxMO+DiQrx/2aIqQWUqi8jI5VBiBgADxDAIGaBLCzWR5
# GA8yMDI1MDUxNDA5MTk1N1owBIACAfSggdmkgdYwgdMxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5k
# IE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjJB
# MUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2
# aWNloIIR/jCCBygwggUQoAMCAQICEzMAAAH5H2eNdauk8bEAAQAAAfkwDQYJKoZI
# hvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEm
# MCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjQwNzI1
# MTgzMTA5WhcNMjUxMDIyMTgzMTA5WjCB0zELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0
# aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MkExQS0wNUUw
# LUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0PUwffIAdYc1WyUL4IFOP8yl3
# nksM+1CuE3tZ6oWFF4L3EpdKOhtbVkfMdTxXYE4lSJiDt8MnYDEZUbKi9S2AZmDb
# 4Zq4UqTdmOOwtKyp6FgixRCuBf6v9UBNpbz841bLqU7IZnBmnF9XYRfioCHqZvaF
# p0C691tGXVArW18GVHd914IFAb7JvP0kVnjks3amzw1zXGvjU3xCLcpUkthfSJsR
# sCSSxHhtuzMLO9j691KuNbIoCNHpiBiFoFoPETYoMnaxBEUUX96ALEqCiB0XdUgm
# gIT9a7L0y4SDKl5rUd6LuUUa90tBkfkmjZBHm43yGIxzxnjtFEm4hYI57IgnVidG
# KKJulRnvb7Cm/wtOi/TIfoLkdH8Pz4BPi+q0/nshNewP0M86hvy2O2x589xAl5tQ
# 2KrJ/JMvmPn8n7Z34Y8JxcRih5Zn6euxlJ+t3kMczii8KYPeWJ+BifOM6vLiCFBP
# 9y+Z0fAWvrIkamFb8cbwZB35wHjDvAak6EdUlvLjiQZUrwzNj2zfYPLVMecmDynv
# LWwQbP8DXLzhm3qAiwhNhpxweEEqnhw5U2t+hFVTHYb/ROvsOTd+kJTy77miWo8/
# AqBmznuOX6U6tFWxfUBgSYCfILIaupEDOkZfKTUe80gGlI025MFCTsUG+75imLoD
# tLZXZOPqXNhZUG+4YQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFInto7qclckj16KP
# NLlCRHZGWeAAMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1Ud
# HwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3Js
# L01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggr
# BgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIw
# MTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# DgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBmIAmAVuR/uN+HH+aZ
# mWcZmulp74canFbGzwjv29RvwZCi7nQzWezuLAbYJx2hdqrtWClWQ1/W68iGsZik
# oIFdD5JonY7QG/C4lHtSyBNoo3SP/J/d+kcPSS0f4SQS4Zez0MEvK3vWK61WTCjD
# 2JCZKTiggrxLwCs0alI7N6671N0mMGOxqya4n7arlOOauAQrI97dMCkCKjxx3D9v
# VwECaO0ju2k1hXk/JEjcrU2G4OB8SPmTKcYX+6LM/U24dLEX9XWSz/a0ISiuKJwz
# iTU8lNMDRMKM1uSmYFywAyXFPMGdayqcEK3135R31VrcjD0GzhxyuSAGMu2De9gZ
# hqvrXmh9i1T526n4u5TR3bAEMQbWeFJYdo767bLpKLcBo0g23+k4wpTqXgBbS4NZ
# Qff04cfcSoUe1OyxldoM6O3JGBuowaaR/wojeohUFknZdCmeES5FuH4CCmZGf9rj
# XQOTtW0+Da4LjbZYsLwfwhWT8V6iJJLi8Wh2GdwV60nRkrfrDEBrcWI+AF5tFbJW
# 1nvreoMPPENvSYHocv0cR9Ns37igcKRlrUcqXwHSzxGIUEx/9bv47sQ9n7AwfzB2
# SNntJux1211GBEBGpHwgU9a6tD6yft+0SJ9qiPO4IRqFIByrzrKPBB5M831gb1vf
# hFO6ueSkP7A8ZMHVZxwymwuUzTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkA
# AAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRl
# IEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVow
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX
# 9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1q
# UoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8d
# q6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byN
# pOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2k
# rnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4d
# Pf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgS
# Uei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8
# QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6Cm
# gyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzF
# ER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQID
# AQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQU
# KqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1
# GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0
# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0
# bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMA
# QTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbL
# j+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1p
# Y3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0w
# Ni0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIz
# LmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwU
# tj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN
# 3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU
# 5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5
# KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGy
# qVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB6
# 2FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltE
# AY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFp
# AUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcd
# FYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRb
# atGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQd
# VTNYs6FwZvKhggNZMIICQQIBATCCAQGhgdmkgdYwgdMxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5k
# IE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjJB
# MUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2
# aWNloiMKAQEwBwYFKw4DAhoDFQCqzlaNY7vNUAqYhx3CGqBm/KnpRqCBgzCBgKR+
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA
# 685j+zAiGA8yMDI1MDUxNDAwMzYxMVoYDzIwMjUwNTE1MDAzNjExWjB3MD0GCisG
# AQQBhFkKBAExLzAtMAoCBQDrzmP7AgEAMAoCAQACAgxMAgH/MAcCAQACAhJqMAoC
# BQDrz7V7AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEA
# AgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBADb7OLcf3pqm2QO6
# BxKfmfX72w2patOMnP7OR1tk6S9yDtNHbyMJK5rTCko+bwixo13LRFPdXrxSQiGW
# 3Kig7BdN7QDMmyKh3EEcOEj0c07cuQPO3Hrwx0mr6oKfXZZRBCU6K+ReKnYIILEM
# PFCPVWLg309HQE7hV+o8dipyTdL2jKjqD+7NsY3TvapjdAwJs+RKdf4UZ9ajqJlR
# 1UXbUQLmkAVqmbR3pZ0M76Hcu65aLy/Cq85HrkcO+zQXDmPpfkVHQvhuddBeb3g+
# WGqElD5Q1Gsue9H4nyosahxnWo19QcaDbKKObW47tcrU0t1yjzP5hx3YxzoCqkck
# SpDTDk8xggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAfkfZ411q6TxsQABAAAB+TANBglghkgBZQMEAgEFAKCCAUowGgYJKoZI
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAp6KYS511z26Dm
# vDfTJKt9o3h/10i8hwWYxg7HscVq5DCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQw
# gb0EIDkjjMge8I37ZPrpFQ4sJmtQRV2gqUqXxV4I7lJsYtgQMIGYMIGApH4wfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAH5H2eNdauk8bEAAQAAAfkw
# IgQgP9zBqx85P8/R5IINhfWNOhkB7gcbKalylrKFpE2FbJMwDQYJKoZIhvcNAQEL
# BQAEggIApyPPMp39WGnU3UwxFulTFueb+vLMhNHPTYZA1p03H9fjG2plT/xMTEFe
# G1ZX1apVVrW++yAH/FJ8uRsged3N9TdoTpOlIzr9bd0TbAYm49H9hxQWBT0qOgmo
# E6QQCWjIkGckYj/eK2CPGkZKjmq7WlCT6K3tADQpeGedrBOnMkXiKBuwjnI1RSTq
# GsWnOxFGKtf1JlhqU4xQiucZWYzKoH5X/NBaZdcsGGZRcmhURlCnBYTkiWhVUeeV
# iMOkg+IYO3draJkxEwGL76yZ5w/+JBAz10allwPfL0xhLT7HCZ9xjTzSfTbGgHHt
# kamc8HlSyfOV/Xbgf0PppbqZn1+pbmb50RhJJXM0lK0nyYVippqFEAHvqLVUwUg/
# wdIahQLoWPip8Or+/pCyl6dO4gyn3rNGrmcNqhDya+vpKcjhtnfI7qtxDWR39h6g
# zPwhE/9PaavZ5XLkINLx2RS9dXFM5hJUL1Ob3sV1ftEBuNmc6bbLACsgCj7YNL+G
# 2YyU5t2yf3CtofS+Iccf4w+ywCtdnuu/jZ0Jdo+HHmNPP+ENZdAU7tFT2IWJRG1H
# +mZe5WiWYVbd3qfVeQ/gKLuLFqDT21UOlXcAR0Rr5M8zL8e4NKQLzDjZRXoL5R7J
# QZbEhBY9VjB/3/Fhhh3MnRBzDp0+6y64zbmPK4482ctEEQkJ5gY=
# SIG # End signature block
