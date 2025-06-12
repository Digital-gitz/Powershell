
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
Retrieves the details of the replicating server status.
.Description
The Get-AzMigrateServerMigrationStatus cmdlet retrieves the replication status for the replicating server.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/get-azmigrateservermigrationstatus
#>
function Get-AzMigrateServerMigrationStatus {
    [OutputType([PSCustomObject[]])]
    [CmdletBinding(DefaultParameterSetName = 'ListByName', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ListByName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        #[Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group of the Azure Migrate Project in the current subscription.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'ListByName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        #[Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Azure Migrate project  in the current subscription.
        ${ProjectName},

        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        #[Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the display name of the replicating machine.
        ${MachineName},

        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the appliance.
        ${ApplianceName},

        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Management.Automation.SwitchParameter]
        # Specifies whether the health issues to show for replicating server.
        ${Health},

        [Parameter(ParameterSetName = 'ListByName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Query')]
        [System.String]
        # OData filter options.
        ${Filter},
    
        [Parameter(ParameterSetName = 'ListByName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Query')]
        [System.String]
        # The pagination token.
        ${SkipToken},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Azure Subscription ID.
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
        Function MakeTable ($TableName, $ColumnArray) {
            foreach($Col in $ColumnArray) {
                $MCol = New-Object System.Data.DataColumn $Col;
                $TableName.Columns.Add($MCol)
            }
        }

        $appMap = @{}

        Function PopulateApplianceDetails ($projName, $rgName) {
            # Get vault name from SMS solution.
            $smsSolution = Get-AzMigrateSolution -MigrateProjectName $projName -ResourceGroupName $rgName -Name "Servers-Migration-ServerMigration"

            if (-not $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId) {
                throw 'Azure Migrate appliance not configured. Setup Azure Migrate appliance before proceeding.'
            }

            $VaultName = $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]

            # Get all appliances and sites in the project from SDS solution.
            $sdsSolution = Get-AzMigrateSolution -MigrateProjectName $projName -ResourceGroupName $rgName -Name "Servers-Discovery-ServerDiscovery"

            if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
                $appMapV2 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
                # Fetch all appliances from V2 map first. Then these can be updated if found again in V3 map.
                foreach ($item in $appMapV2) {
                    $appMap[$item.SiteId.Split('/')[-1]] = $item.ApplianceName
                }
            }

            if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
                $appMapV3 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
                foreach ($item in $appMapV3) {
                    $t = $item.psobject.properties
                    $appMap[$t.Value.SiteId.Split('/')[-1]] = $t.Name
                }
            }
        }

        Function GetApplianceName ($site) {
            if (!$appMap.ContainsKey($site)) {
                return "No appliance found for site name: $site"
            }
            return $appMap[$site]
        }

        Function GetState {
            param(
                [string]$State,
                [object]$ReplicationMigrationItem
            )

            if ([string]::IsNullOrEmpty($State)) {
                if ($ReplicationMigrationItem.MigrationState -match "InitialSeedingInProgress" -or $ReplicationMigrationItem.MigrationState -match "EnableMigrationInProgress" -or $ReplicationMigrationItem.MigrationState -match "Replicating") {
                    return "InitialReplication Queued"
                }
                elseif ($ReplicationMigrationItem.MigrationState -match "InitialSeedingFailed") {
                    return "InitialReplication Failed"
                }
                return $ReplicationMigrationItem.MigrationState
            }

            if ($ReplicationMigrationItem.MigrationState -match "MigrationInProgress" -and $ReplicationMigrationItem.migrationProgressPercentage -eq $null) {
                return "FinalDeltaReplication Queued"
            }

            if ($ReplicationMigrationItem.MigrationState -eq "MigrationSucceeded") {
                return "Migration Completed"
            }

            $State = $State -replace "PlannedFailoverOverDeltaReplication", "FinalDeltaReplication"
            return $State
        }

        function Convert-MillisecondsToTime {
            param (
                [int]$Milliseconds
            )

            if ($Milliseconds -eq $null) {
                return $null
            }

            $TotalMinutes = [math]::Floor($Milliseconds / 60000)
            $Hours = [math]::Floor($TotalMinutes / 60)
            $Minutes = $TotalMinutes % 60

            if ($Hours -eq 0) {
                if ($Minutes -eq 0)
                {
                    return "-"
                }
                return "$Minutes min"
            } else {
                return "$Hours hr $Minutes min"
            }
        }

        function Convert-ToMbps {
            param (
                [double]$UploadSpeedInBytesPerSecond
            )

            if ($UploadSpeedInBytesPerSecond -eq $null -or $UploadSpeedInBytesPerSecond -eq 0) {
                return "-"
            }

            # Conversion factor: 1 byte = 8 bits
            $UploadSpeedInBitsPerSecond = $UploadSpeedInBytesPerSecond * 8

            # Conversion factor: 1 megabit = 1,000,000 bits
            $UploadSpeedInMbps = [math]::Round($UploadSpeedInBitsPerSecond / 1e6)

            return "$UploadSpeedInMbps Mbps"
        }

        function Add-Percent {
            param (
                [double]$Value
            )

            if ($Value -ne $null -and $Value -ne 0) {
                return "$Value%"
            } else {
                return "-"
            }
        }

        function ConvertToCustomTimeFormat {
            param (
                [string]$LocalTimeString
            )
            
            if ([string]::IsNullOrEmpty($LocalTimeString)) {
                return "-"
            }

            # Parse the input string
            $localTime = [datetime]::ParseExact($LocalTimeString, "MM/dd/yyyy HH:mm:ss", $null)

            # Format the local time as desired
            $formattedTime = Get-Date $localTime -Format "M/d/yyyy, h:mm:ss tt"

            return $formattedTime
        }

        $parameterSet = $PSCmdlet.ParameterSetName
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ProjectName')
        $HasFilter = $PSBoundParameters.ContainsKey('Filter')
        $HasSkipToken = $PSBoundParameters.ContainsKey('SkipToken')
        $null = $PSBoundParameters.Remove('Filter')
        $null = $PSBoundParameters.Remove('SkipToken')
        $null = $PSBoundParameters.Remove('MachineName')
        $null = $PSBoundParameters.Remove('ApplianceName')
        $null = $PSBoundParameters.Remove('Health')
        #$null = $PSBoundParameters.Remove('Expedite')

        $output = New-Object System.Collections.ArrayList  # Create a hashtable to store the output.

        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("Name", "Servers-Migration-ServerMigration")
        $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)

        $solution = Az.Migrate\Get-AzMigrateSolution @PSBoundParameters
        if ($solution -and ($solution.Count -ge 1)) {
            $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
        }
        else {
            throw "Solution not found."
        }


        $null = $PSBoundParameters.Remove("Name")
        $null = $PSBoundParameters.Remove("MigrateProjectName")
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)

        if ($HasFilter) {
            $null = $PSBoundParameters.Add("Filter", $Filter)
        }
        if ($HasSkipToken) {
            $null = $PSBoundParameters.Add("SkipToken", $SkipToken)
        }

        PopulateApplianceDetails $ProjectName $ResourceGroupName

        if ($parameterSet -eq "GetByApplianceName" -and !$appMap.ContainsValue($ApplianceName))
        {
            throw "No appliance found with name $ApplianceName"
        }

        if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
            $ReplicationMigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName -MachineName $MachineName
        }
        else {
            $ReplicationMigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName
        }

        if ($ReplicationMigrationItems -eq $null) {
            if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName") {
                Write-Host "No replicating machine found with name $MachineName."
            }
            else {
                Write-Host "No replicating machine found."
            }
            return;
        }

        $vmMigrationStatusTable = New-Object System.Data.DataTable("")

        if ($parameterSet -eq "GetByApplianceName") {
            $column = @("Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Health", "LastSync", "Datastore")
        }
        elseif ($parameterSet -eq "ListByName") {
            $column = @("Appliance", "Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Health", "LastSync", "Datastore")
        }
        else {
            $column = @("Appliance", "Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "LastSync", "Datastore")
        }

        MakeTable $vmMigrationStatusTable $column

        foreach ($ReplicationMigrationItem in $ReplicationMigrationItems) {
            if ($parameterSet -eq "GetByMachineName") {
                if ($ReplicationMigrationItem.health -eq "Normal") {
                    $op = $output.Add("`nServer $MachineName is currently healthy.")
                }
                elseif ($ReplicationMigrationItem.health -eq "None") {
                    $op = $output.Add("`nServer $MachineName is in $($ReplicationMigrationItems.ReplicationStatus) state.")
                }
                else {
                    $op = $output.Add("`nServer $MachineName is currently facing critical error/ warning. Please run the command given below to know about the errors and resolutions.`n`nGet-AzMigrateServerMigrationStatus -ProjectName <String> -ResourceGroupName <String> -Appliance <String> -MachineName <String> -Health")
                }
            }

            if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                $ReplicationMigrationItem = Get-AzMigrateServerReplication -TargetObjectID $ReplicationMigrationItem.Id
            }

            $site = $ReplicationMigrationItem.ProviderSpecificDetail.vmwareMachineId.Split('/')[-3]
            $appName = GetApplianceName $site
            $row1 = $vmMigrationStatusTable.NewRow()
            if ($parameterSet -eq "GetByApplianceName" -and $appName -ne $ApplianceName) {
                continue;
            }
            if ($parameterSet -ne "GetByApplianceName") {
                $row1["Appliance"] = $appName
            }

            $row1["Server"] = $ReplicationMigrationItem.MachineName
            $row1["State"] = GetState -State $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem
            if ($ReplicationMigrationItem.ReplicationStatus -match "Pause" -and $ReplicationMigrationItem.MigrationState -notmatch "migration") {
                $row1["State"] = $ReplicationMigrationItem.ReplicationStatus
                $row1["TimeRemaining"] = "-"
                $row1["UploadSpeed"] = "-"
                $row1["Progress"] = "-"
                $row1["TimeElapsed"] = "-"
            }
            elseif ($ReplicationMigrationItem.ReplicationStatus -match "Resum") {
                $row1["State"] = $ReplicationMigrationItem.ReplicationStatus
                $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                $row1["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailUploadSpeed
                $row1["Progress"] = Add-Percent -Value $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailProgressPercentage
                $row1["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeElapsed
            }
            elseif ($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -match "Completed") {
                $row1["TimeRemaining"] = "-"
                $row1["UploadSpeed"] = "-"
                $row1["Progress"] = "-"
                $row1["TimeElapsed"] = "-"
            }
            else {
                $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                $row1["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailUploadSpeed
                $row1["Progress"] = Add-Percent -Value $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailProgressPercentage
                $row1["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeElapsed
            }

            if ($parameterSet -eq "ListByName" -or $parameterSet -eq "GetByApplianceName") {
                if ([string]::IsNullOrEmpty($ReplicationMigrationItem.health) -or $ReplicationMigrationItem.health -eq "None") {
                    $row1["Health"] = "-"
                }
                else {
                    $row1["Health"] = $ReplicationMigrationItem.health
                }
            }
            $row1["LastSync"] = ConvertToCustomTimeFormat -LocalTimeString $ReplicationMigrationItem.ProviderSpecificDetail.lastRecoveryPointReceived

            #$row1["ESXiHost"] = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
            if (-not [string]::IsNullOrEmpty($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore)) {
                $row1["Datastore"] = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore -join ', '
            }
            else {
                $row1["Datastore"] = "-"
            }

            $vmMigrationStatusTable.Rows.Add($row1)

            if( $parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                if ($parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                    $op = $output.Add("`nServer Information:")
                }

                $vmMigrationStatusTable = $vmMigrationStatusTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($vmMigrationStatusTable)  # Store the table in the output hashtable

                $diskStatusTable = New-Object System.Data.DataTable("")
                $diskcolumn = @("Disk", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Datastore")

                MakeTable $diskStatusTable $diskcolumn

                foreach($disk in $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk) {
                    $row = $diskStatusTable.NewRow()
                    $row["Disk"] = $disk.DiskName
                    $row["State"] = GetState -State $disk.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem

                    if ($ReplicationMigrationItem.ReplicationStatus -match "Pause" -and $ReplicationMigrationItem.MigrationState -notmatch "migration") {
                        $row["State"] = $ReplicationMigrationItem.ReplicationStatus
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                    }
                    elseif ($ReplicationMigrationItem.ReplicationStatus -match "Resum") {
                        $row["State"] = $ReplicationMigrationItem.ReplicationStatus
                        #$row["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeRemaining
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                        #$row["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $disk.GatewayOperationDetailUploadSpeed
                        #$row["Progress"] = Add-Percent -Value $disk.GatewayOperationDetailProgressPercentage
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                        #$row["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeElapsed
                    }
                    elseif ($disk.GatewayOperationDetailState -match "Completed") {
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                    }
                    else {
                        $row["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeRemaining
                        $row["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $disk.GatewayOperationDetailUploadSpeed
                        $row["Progress"] = Add-Percent -Value $disk.GatewayOperationDetailProgressPercentage
                        $row["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeElapsed
                    }

                    if (-not [string]::IsNullOrEmpty($disk.GatewayOperationDetailDataStore)) {
                        $row["Datastore"] = $disk.GatewayOperationDetailDataStore -join ', '
                    }
                    else {
                        $row["Datastore"] = "-"
                    }
                    $diskStatusTable.Rows.Add($row)
                }

                if ($parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                    $op = $output.Add("`nDisk Level Operation Status:")
                }

                $diskStatusTable = $diskStatusTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($diskStatusTable)  # Store the table in the output hashtable
            }

            if ($parameterSet -eq "GetHealthByMachineName") {
                if ($ReplicationMigrationItem.health -eq "Normal") {
                    $op = $output.Add("No warnings or critical errors for this server.")
                }
                else {
                    $op = $output.Add("List of warning or critical errors for this server with their resolutions: `n")
                    $healthError = $ReplicationMigrationItem.HealthError
                    foreach ($error in $healthError) {
                        $op = $output.Add("Error Message: $($error.ErrorMessage)`nPossible Causes: $($error.PossibleCaus)`nRecommended Actions: $($error.RecommendedAction)`n`n")
                    }
                }
            }

            <#if( $parameterSet -eq "GetByPrioritiseServer") {
                $vmMigrationTable = New-Object System.Data.DataTable("")
                $column = @("Appliance", "Server", "State", "TimeRemaining", "ESXiHost", "Datastore")
                MakeTable $vmMigrationTable $column

                foreach($MigrationItem in $ReplicationMigrationItems) {
                    $site = $MigrationItem.ProviderSpecificDetail.vmwareMachineId.Split('/')[-3]
                    $appName1 = GetApplianceName $site
                    if ($MigrationItem.MachineName -eq $ReplicationMigrationItem.MachineName -and $appName1 -eq $appName) {
                        continue;
                    }

                    if ($appName1 -ne $appName) {
                        continue;
                    }

                    $row1 = $vmMigrationTable.NewRow()
                    $row1["Appliance"] = $appName1
                    $row1["Server"] = $MigrationItem.MachineName
                    $row1["State"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailState
                    $row1["TimeRemaining"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                    $row1["ESXiHost"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
                    $row1["Datastore"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore
                    $vmMigrationTable.Rows.Add($row1)
                }
                $op = $output.Add("Resource Sharing: `n`nVM $($ReplicationMigrationItem.MachineName) shares at least one resource with the following VM. These include ESXi host, Datastore or primary appliance.")
                $vmMigrationTable = $vmMigrationTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($vmMigrationTable)

                $resourceUtilizationTable = New-Object System.Data.DataTable("")
                $column = @("Resource", "Capacity", "Utilization for server migrations", "Total utilization", "Status")
                MakeTable $resourceUtilizationTable $column
                $row1 = $resourceUtilizationTable.NewRow()
                $row1["Resource"] = "Appliance RAM Sum : Primary and scale out appliances"
                $row1["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailCapacity
                $row1["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailProcessUtilization
                $row1["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailTotalUtilization
                $row1["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailStatus
                $resourceUtilizationTable.Rows.Add($row1)

                $row2 = $resourceUtilizationTable.NewRow()
                $row2["Resource"] = "Appliance CPU Sum : Primary and scale out appliances"
                $row2["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailCapacity
                $row2["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailProcessUtilization
                $row2["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailTotalUtilization
                $row2["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailStatus
                $resourceUtilizationTable.Rows.Add($row2)

                $row3 = $resourceUtilizationTable.NewRow()
                $row3["Resource"] = "Network bandwidth Sum : Primary and scale out appliances"
                $row3["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthCapacity
                $row3["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthProcessUtilization
                $row3["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthTotalUtilization
                $row3["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthStatus
                $resourceUtilizationTable.Rows.Add($row3)

                $row4 = $resourceUtilizationTable.NewRow()
                $row4["Resource"] = "ESXi host NFC buffer"
                $row4["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferCapacity
                $row4["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferProcessUtilization
                $row4["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferTotalUtilization
                $row4["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferStatus
                $resourceUtilizationTable.Rows.Add($row4)

                $row5 = $resourceUtilizationTable.NewRow()
                $row5["Resource"] = "Parallel Disks Replicated Sum : Primary and scale out appliances"
                $row5["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailCapacity
                $row5["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailProcessUtilization
                $row5["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailTotalUtilization
                $row5["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailStatus
                $resourceUtilizationTable.Rows.Add($row5)

                $row6 = $resourceUtilizationTable.NewRow()
                $row6["Resource"] = "Datastore Snapshot Count (for each datastore corresponding to the server s disks)"
                $row6["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotCapacity
                $row6["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotProcessUtilization
                $row6["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotTotalUtilization
                $row6["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotStatus
                $resourceUtilizationTable.Rows.Add($row6)

                $op = $output.Add("Resource utilization information for migration operations:")
                $resourceUtilizationTable = $resourceUtilizationTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($resourceUtilizationTable)
                
                # <To-do> Add Recomendation actions logic for expedite.

                Write-Host "Based on the resource utilization seen above following are suggestion you can take to expedite server $($ReplicationMigrationItem.MachineName) migration :" -ForegroundColor White
                Write-Host "1. Pause replication for servers S2, S3, in delta sync who are migrating under appliance A1."
                Write-Host "2. Stop replication for servers S4 in Initial replication migrating under appliance A1."
                Write-Host "3. Increase the Network bandwidth available for appliances so that upload speeds can increase."
                Write-Host "4. Increase the NFC buffer size to increase the upload speed."
                Write-Host "5. Perform storage Vmotion on server $($ReplicationMigrationItem.MachineName)."
            }#>
        }

        if ($parameterSet -eq "GetByApplianceName" -or $parameterSet -eq "ListByName") {
            $vmMigrationStatusTable = $vmMigrationStatusTable | Format-Table -AutoSize | Out-String
            $op = $output.Add($vmMigrationStatusTable)

            $diskStatusTable = $diskStatusTable | Format-Table -AutoSize | Out-String
            $op = $output.Add($diskStatusTable)
#            $op = $output.Add("To check expedite the operation of a server use the command")
#            $op = $output.Add("Get-AzMigrateServerMigrationStatus  -ProjectName <String> -ResourceGroupName <String> -MachineName <String> -Expedite`n")
            $op = $output.Add("To resolve the health issue use the command")
            $op = $output.Add("Get-AzMigrateServerMigrationStatus -ProjectName <String> -ResourceGroupName <String> -MachineName <String> -Health`n")
        }

        return $output;
    }
}
# SIG # Begin signature block
# MIIoKQYJKoZIhvcNAQcCoIIoGjCCKBYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBkr1wIzgucZv2W
# v4mEXapKOWkMgux0FqttHlvui46WO6CCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgkwghoFAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIH6T36RjJdcIp5xjXChvMkpq
# OGRaKunMLtPEsP8b2tnMMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAkffO1f3h7gpDzD7IDmzm0GLlYT3LYxbM1FJjMdg7hyJZ5Y8IFeJRgU2U
# /1sAkimtmB/aNMAJtVxf0uC87GGvplDxp0MynU0IOqyZplxtWqKrtLZOr9soJQaG
# 6cRlxH7WCpIDPSBdaaR3lauJu5I0BcaAXZT7pQpCFEQKdFUb8ym9K1Mi8Kyr+Owf
# v4qAxgSuh0CAPLaCfAA2W7LX/qhltgLXFflZ/ZktrsC0+NiCgN47Adh2lt0xYbyE
# ySNHm6Cz6Erq0oQPE0h/uRV9ZY+GlkrW7DXuDZzKNnoX9ocmfVZizxIfw1eZagU0
# 26q9alEAWt0yWxx5KoMWiDpcFBsvz6GCF5MwghePBgorBgEEAYI3AwMBMYIXfzCC
# F3sGCSqGSIb3DQEHAqCCF2wwghdoAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFRBgsq
# hkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCCqQaWNCTAQUk3bLEJrgUICTWVkVHqz/Xdqty2LgQcBqAIGaCYfsE7T
# GBIyMDI1MDUyODA3MzE0My45N1owBIACAfSggdGkgc4wgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpEQzAwLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaCC
# EeowggcgMIIFCKADAgECAhMzAAACA7seXAA4bHTKAAEAAAIDMA0GCSqGSIb3DQEB
# CwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI1MDEzMDE5NDI0
# NloXDTI2MDQyMjE5NDI0NlowgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpEQzAwLTA1RTAtRDk0NzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAKGXQwfnACc7HxSHxG2J0XQnTJoUMclgdOk+9FHXpfUr
# EYNh9Pw+twaMIsKJo67crUOZQhThFzmiWd2Nqmk246DPBSiPjdVtsnHk8VNj9rVn
# zS2mpU/Q6gomVSR8M9IEsWBdaPpWBrJEIg20uxRqzLTDmDKwPsgs9m6JCNpx7krE
# BKMp/YxVfWp8TNgFtMY0SKNJAIrDDJzR5q+vgWjdf/6wK64C2RNaKyxTriTysrrS
# OwZECmIRJ1+4evTJYCZzuNM4814YDHooIvaS2mcZ6AsN3UiUToG7oFLAAgUevvM7
# AiUWrJC4J7RJAAsJsmGxP3L2LLrVEkBexTS7RMLlhiZNJsQjuDXR1jHxSP6+H0ic
# ugpgLkOkpvfXVthV3RvK1vOV9NGyVFMmCi2d8IAgYwuoSqT3/ZVEa72SUmLWP2dV
# +rJgdisw84FdytBhbSOYo2M4vjsJoQCs3OEMGJrXBd0kA0qoy8nylB7abz9yJvIM
# z7UFVmq40Ci/03i0kXgAK2NfSONc0NQy1JmhUVAf4WRZ189bHW4EiRz3tH7FEu4+
# NTKkdnkDcAAtKR7hNpEG9u9MFjJbYd6c5PudgspM7iPDlCrpzDdn3NMpI9DoPmXK
# Jil6zlFHYx0y8lLh8Jw8kV5pU6+5YVJD8Qa1UFKGGYsH7l7DMXN2l/VS4ma45BNP
# AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUsilZQH4R55Db2xZ7RV3PFZAYkn0wHwYD
# VR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
# BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0
# cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwDQYJKoZIhvcNAQELBQADggIBAJAQxt6wPpMLTxHShgJ1ILjnYBCsZ/87z0ZD
# ngK2ASxvHPAYNVRyaNcVydolJM150EpVeQGBrBGic/UuDEfhvPNWPZ5Y2bMYjA7U
# WWGV0A84cDMsEQdGhJnil10W1pDGhptT83W9bIgKI3rQi3zmCcXkkPgwxfJ3qlLx
# 4AMiLpO2N+Ao+i6ZZrQEVD9oTONSt883Wvtysr6qSYvO3D8Q1LvN6Z/LHiQZGDBj
# VYF8Wqb+cWUkM9AGJyp5Td06n2GPtaoPRFz7/hVnrBCN6wjIKS/m6FQ3LYuE0OLa
# V5i0CIgWmaN82TgaeAu8LZOP0is4y/bRKvKbkn8WHvJYCI94azfIDdBqmNlO1+vs
# 1/OkEglDjFP+JzhYZaqEaVGVUEjm7o6PDdnFJkIuDe9ELgpjKmSHwV0hagqKuOJ0
# QaVew06j5Q/9gbkqF5uK51MHEZ5x8kK65Sykh1GFK0cBCyO/90CpYEuWGiurY4Jo
# /7AWETdY+CefHml+W+W6Ohw+Cw3bj7510euXc7UUVptbybRSQMdIoKHxBPBORg7C
# 732ITEFVaVthlHPao4gGMv+jMSG0IHRq4qF9Mst640YFRoHP6hln5f1QAQKgyGQR
# ONvph81ojVPu9UBqK6EGhX8kI5BP5FhmuDKTI+nOmbAw0UEPW91b/b2r2eRNagSF
# wQ47Qv03MIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG
# 9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
# MTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az
# /1xPx2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V2
# 9YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oa
# ezOtgFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkN
# yjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7K
# MtXAhjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRf
# NN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SU
# HDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoY
# WmEBc8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5
# C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8
# FdsaN8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TAS
# BgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1
# Kc8Q/y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUw
# UzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fO
# mhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9w
# a2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggr
# BgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3
# DQEBCwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEz
# tTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJW
# AAOwBb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G
# 82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/Aye
# ixmJ5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI9
# 5ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1j
# dEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZ
# KCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xB
# Zj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuP
# Ntq6TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvp
# e784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCA00w
# ggI1AgEBMIH5oYHRpIHOMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046REMwMC0wNUUwLUQ5NDcxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAM2v
# FFf+LPqyzWUEJcbw/UsXEPR7oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDr4Rf3MCIYDzIwMjUwNTI4MDUwNDU1
# WhgPMjAyNTA1MjkwNTA0NTVaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOvhF/cC
# AQAwBwIBAAICD8EwBwIBAAICEnQwCgIFAOviaXcCAQAwNgYKKwYBBAGEWQoEAjEo
# MCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
# 9w0BAQsFAAOCAQEAcLNEXyfSiv5aQoyEyemFpzGigfKbARaxhPb6QC1sXIfxuCc5
# +9JkxBh5YLY3D4HuZGMw+9D3Y4KVOSd5sTN92D4oSv7YLI8tAo9clK4G2OiWi06E
# xgsFhnMw+YlvLCWn3pCZ6i36TdGtAGKVv4SJxPj0OgDGO597j4658U4+12yy7tF4
# vT27uDtlUuMoIZZ9NZWTnYNJoffig2Bclrp9CxRi+Gi0hLFZqCJ43rMOEYwcIPAs
# yptp+8LDGHhGXsZvtko/QO6HAPWML1Leh4EENiM3xIAMZiT23Thm53tx9naM9Va8
# +/3XKTBvQhYF8xZ0QPRjpMKUN1zI5pXRZNG0VDGCBA0wggQJAgEBMIGTMHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACA7seXAA4bHTKAAEAAAIDMA0G
# CWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEII3LuQvewuGPAga7odqXAcBEtX+8yfQlHkWpIRI+ibneMIH6
# BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgSwPdG3GW9pPEU5lmelDDQOSw+ZV2
# 6jlLIr2H3D76Ey0wgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAgO7HlwAOGx0ygABAAACAzAiBCAF4OMRiceGtMP+lQJ1DszZ6stakShp
# epuRygyyyF1AZzANBgkqhkiG9w0BAQsFAASCAgBVjO74J4hLdwMDY06YeuZeJoRr
# b8B0m468+p0eZF7dG5Tj94Y1qII0xo6YkIBIgKYLQSbcvc4ib29Mij2xlRXlLxX2
# 5k+ONlh7Bc5zbi8Z/sQNwBPffSbhEneMfIlDagVXIYLbgay9R5F3MQ7pOpmN5plx
# Ty4Oiobaw/qOUbFwZlIq4JzxZqOJkd5RAAmpHP2rljJc6vwzqLxxDrAG4qGgjcmu
# nYYEeLKBkNw5sgXedOnroFa4PiPde5fO/hsaVt7Y8OdZybPTy/xC3UNfzpYoiDTD
# eGi6axKVDN2Sd/o9fedBcED42Uor67EgtjDhR9+0acBmGB+ieKgLs7iji0zDUHUq
# 1IAF2fpgaw42mzYY3Chqq3H3XwSKDkN2JI0qa5ttfogI2w/sNiNLyeNI39sYKcoK
# f1H576nv1VJ8jFtfoBPkWTmQLSwxToPPe2cG/13rPyZwFWh/mhXuLkFyy/MYGnkn
# sePJour1webXQIiJn46lSIYNyLvEJ5dWUhwrjxJO5toyMa0GCLnLKlw/C+NbE/UW
# h1navWzhSnN5Q2WOf1yepYbk3EzPfFYZ535/DbN3sGjrO3kBBYuC9/p0YoRjbfrD
# AmjYNi04aZM14uqN1uhFoFBMKxAXqzp5/CHOWI9FNVigAbKf1YLDlrjlfsvBe+Ce
# ZpzM+jhQi8j0w3DIBw==
# SIG # End signature block
