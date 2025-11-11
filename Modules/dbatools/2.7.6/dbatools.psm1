#requires -Version 3.0
param(
    [Collections.IDictionary]
    [Alias('Options')]
    $Option = @{ }
)

$script:start = [DateTime]::Now

function Write-ImportTime {
    param (
        [string]$Text,
        $Timestamp = ([DateTime]::now)
    )
    if (-not $script:dbatools_previousImportPerformance) {
        $script:dbatools_previousImportPerformance = $script:start
    }

    $duration = New-TimeSpan -Start $script:dbatools_previousImportPerformance -End $Timestamp

    if (-not $script:dbatools_ImportPerformance) {
        $script:dbatools_ImportPerformance = New-Object Collections.ArrayList
    }

    $script:dbatools_ImportPerformance.Add(
        [pscustomobject]@{
            Action   = $Text
            Duration = $duration
        })

    $script:dbatools_previousImportPerformance = $Timestamp
}
Write-ImportTime -Text "Started" -Timestamp $script:start

$script:PSModuleRoot = $PSScriptRoot

if (-not $Env:TEMP) {
    $Env:TEMP = [System.IO.Path]::GetTempPath()
}

$script:libraryroot = Get-DbatoolsLibraryPath -ErrorAction Ignore

if (-not $script:libraryroot) {
    # for the people who bypass the psd1
    Import-Module dbatools.library -ErrorAction Ignore
    $script:libraryroot = Get-DbatoolsLibraryPath -ErrorAction Ignore

    if (-not $script:libraryroot) {
        throw "The dbatools library, dbatools.library, was module not found. Please install it from the PowerShell Gallery."
    }
    Write-ImportTime -Text "Couldn't find location for dbatools library module, loading it up"
}

try {
    # if core add core to the path, otherwise add desktop
    $dll = [System.IO.Path]::Combine($script:libraryroot, 'lib',  'dbatools.dll')
    Import-Module $dll
} catch {
    throw "Couldn't import dbatools library | $PSItem"
}
Write-ImportTime -Text "Imported dbatools library"

Import-Command -Path "$script:PSModuleRoot/bin/typealiases.ps1"
Write-ImportTime -Text "Loading type aliases"

# Tell the library where the module is based, just in case
[Dataplat.Dbatools.dbaSystem.SystemHost]::ModuleBase = $script:PSModuleRoot

If ($PSVersionTable.PSEdition -in "Desktop", $null) {
    $netversion = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse -ErrorAction Ignore | Get-ItemProperty -Name version -ErrorAction Ignore | Where-Object PSChildName -EQ Full | Select-Object -First 1 -ExpandProperty Version
    if ($netversion -lt [version]"4.6") {
        # it actually works with 4.6 somehow, but 4.6.2 and above is recommended
        throw "Modern versions of dbatools require at least .NET 4.6.2. Please update your .NET Framework or downgrade to dbatools 1.0.173"
    }
}
Write-ImportTime -Text "Checking for .NET"

# Core needs to be at least 7.4.0
if ($PSVersionTable.PSEdition -eq 'Core' -and $PSVersionTable.PSVersion -lt [version]"7.4.0") {
    throw "dbatools requires at least PowerShell 7.4.0 when running on Core. Please update your PowerShell."
}


if (($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.Platform -and $PSVersionTable.Platform -eq 'Win32NT')) {
    $script:isWindows = $true
} else {
    $script:isWindows = $false

    # this doesn't exist by default
    # https://github.com/PowerShell/PowerShell/issues/1262
    try {
        $env:COMPUTERNAME = hostname
    } catch {
        $env:COMPUTERNAME = "unknown"
    }
}

Write-ImportTime -Text "Setting some OS variables"

# Failing on newer module library
# if core then run this
if ($PSVersionTable.PSEdition -eq 'Core') {
    Add-Type -AssemblyName System.Security
}
#Write-ImportTime -Text "Loading System.Security"

# SQLSERVER:\ path not supported
if ($ExecutionContext.SessionState.Path.CurrentLocation.Drive.Name -eq 'SqlServer') {
    Write-Warning "SQLSERVER:\ provider not supported. Please change to another directory and reload the module."
    Write-Warning "Going to continue loading anyway, but expect issues."
}
Write-ImportTime -Text "Resolved path to not SQLSERVER PSDrive"

if ($PSVersionTable.PSEdition -and $PSVersionTable.PSEdition -ne 'Desktop') {
    $script:core = $true
} else {
    $script:core = $false
}

if ($psVersionTable.Platform -ne 'Unix' -and 'Microsoft.Win32.Registry' -as [Type]) {
    $regType = 'Microsoft.Win32.Registry' -as [Type]
    $hkcuNode = $regType::CurrentUser.OpenSubKey("SOFTWARE\Microsoft\WindowsPowerShell\dbatools\System")
    if ($dbaToolsSystemNode) {
        $userValues = @{ }
        foreach ($v in $hkcuNode.GetValueNames()) {
            $userValues[$v] = $hkcuNode.GetValue($v)
        }
        $dbatoolsSystemUserNode = $systemValues
    }
    $hklmNode = $regType::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\WindowsPowerShell\dbatools\System")
    if ($dbaToolsSystemNode) {
        $systemValues = @{ }
        foreach ($v in $hklmNode.GetValueNames()) {
            $systemValues[$v] = $hklmNode.GetValue($v)
        }
        $dbatoolsSystemSystemNode = $systemValues
    }
} else {
    $dbatoolsSystemUserNode = @{ }
    $dbatoolsSystemSystemNode = @{ }
}

Write-ImportTime -Text "Checking for OS and loaded registry values"

#region Dot Sourcing
# Detect whether at some level dotsourcing was enforced
$script:serialimport = $dbatools_dotsourcemodule -or
$dbatoolsSystemSystemNode.SerialImport -or
$dbatoolsSystemUserNode.SerialImport -or
$option.SerialImport


$gitDir = $script:PSModuleRoot, '.git' -join [IO.Path]::DirectorySeparatorChar
$pubDir = $script:PSModuleRoot, 'public' -join [IO.Path]::DirectorySeparatorChar

if ($dbatools_enabledebug -or $option.Debug -or $DebugPreference -ne 'SilentlyContinue' -or [IO.Directory]::Exists($gitDir)) {
    if ([IO.Directory]::Exists($pubDir)) {
        $script:serialimport = $true
    } else {
        Write-Message -Level Verbose -Message "Debugging is enabled, but the public folder is missing so we can't do a serial import to actually enable debugging."
    }
}
Write-ImportTime -Text "Checking for debugging preference"
#endregion Dot Sourcing

# People will need to unblock files for themselves, unblocking code removed

<#
    Do the rest of the loading
    # This technique helped a little bit
    # https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
#>

if (-not (Test-Path -Path "$script:PSModuleRoot\dbatools.dat") -or $script:serialimport) {
    # All internal functions privately available within the toolset
    foreach ($file in (Get-ChildItem -Path "$script:PSModuleRoot/private/functions/" -Recurse -Filter *.ps1)) {
        . $file.FullName
    }

    # All internal functions privately available within the toolset
    foreach ($file in (Get-ChildItem -Path "$script:PSModuleRoot/private/testing/" -Recurse -Filter *.ps1)) {
        . $file.FullName
    }

    Write-ImportTime -Text "Loading internal commands via dotsource"

    # All exported functions
    foreach ($file in (Get-ChildItem -Path "$script:PSModuleRoot/public/" -Recurse -Filter *.ps1)) {
        . $file.FullName
    }

    Write-ImportTime -Text "Loading external commands via dotsource"
} else {
    try {
        Import-Command -Path "$script:PSModuleRoot/dbatools.dat" -ErrorAction Stop
    } catch {
        # sometimes the file is in use by another process
        # not sure why, bc it's opened like this: using (FileStream fs = File.Open(Path, FileMode.Open, FileAccess.Read))
        function Test-FileInuse {
            param (
                [string]$FilePath
            )
            try {
                [IO.File]::OpenWrite($FilePath).Close()
                $false
            } catch {
                $true
            }
        }

        $waitsec = 0

        do {
            Write-Message -Level Verbose -Message "Waiting for dbatools.dat to be released by another process"
            Start-Sleep -Seconds 2
            $waitsec++
        } while ((Test-FileInuse -FilePath "$script:PSModuleRoot/dbatools.dat") -and $waitsec -lt 10)

        Import-Command -Path "$script:PSModuleRoot/dbatools.dat"
    }
}

# Load configuration system - Should always go after library and path setting
# this has its own Write-ImportTimes
foreach ($file in (Get-ChildItem -File -Path "$script:PSModuleRoot/private/configurations")) {
    Import-Command -Path $file.FullName
}

# Resolving the path was causing trouble when it didn't exist yet
# Not converting the path separators based on OS was also an issue.

if (-not ([Dataplat.Dbatools.Message.LogHost]::LoggingPath)) {
    [Dataplat.Dbatools.Message.LogHost]::LoggingPath = Join-DbaPath $script:AppData "PowerShell" "dbatools"
}

# Run all optional code
# Note: Each optional file must include a conditional governing whether it's run at all.
# Validations were moved into the other files, in order to prevent having to update dbatools.psm1 every time

if ($PSVersionTable.PSVersion.Major -lt 5) {
    foreach ($file in (Get-ChildItem -File -Path "$script:PSScriptRoot/opt")) {
        Import-Command -Path $file.FullName
    }
    Write-ImportTime -Text "Loading Optional Commands"
}

# Process TEPP parameters
if (-not $env:DBATOOLS_DISABLE_TEPP -and -not $script:disablerunspacetepp -and -not (Get-Runspace -Name dbatools-import-tepp)) {
    foreach ($file in (Get-ChildItem -File -Path "$script:PSModuleRoot/private/scripts/insertTepp*")) {
        Import-Command -Path $file.FullName
    }
    Write-ImportTime -Text "Loading TEPP"
}

# Process transforms
foreach ($file in (Get-ChildItem -File -Path "$script:PSModuleRoot/private/scripts/message-transforms*")) {
    Import-Command -Path $file.FullName
}
Write-ImportTime -Text "Loading Message Transforms"

# Load scripts that must be individually run at the end #
#-------------------------------------------------------#
<#
DBATOOLS_DISABLE_LOGGING    -- used to disable runspace that handles message logging to local filesystem
DBATOOLS_DISABLE_TEPP       -- used to disable TEPP, we will not even import the code behind 😉
#>
# Start the logging system (requires the configuration system up and running)
if (-not $env:DBATOOLS_DISABLE_LOGGING) {
    foreach ($file in (Get-ChildItem -File -Path "$script:PSModuleRoot/private/scripts/logfilescript*")) {
        Import-Command -Path $file.FullName
    }
    Write-ImportTime -Text "Loading Script: Logging"
}

if (-not $env:DBATOOLS_DISABLE_TEPP -and -not $script:disablerunspacetepp) {
    # Start the tepp asynchronous update system (requires the configuration system up and running)
    foreach ($file in (Get-ChildItem -File -Path "$script:PSModuleRoot/private/scripts/updateTeppAsync*")) {
        Import-Command -Path $file.FullName
    }
    Write-ImportTime -Text "Loading Script: Asynchronous TEPP Cache"
}

if (-not $env:DBATOOLS_DISABLE_LOGGING) {
    # Start the maintenance system (requires pretty much everything else already up and running)
    foreach ($file in (Get-ChildItem -File -Path "$script:PSModuleRoot/private/scripts/dbatools-maintenance*")) {
        Import-Command -Path $file.FullName
    }
    Write-ImportTime -Text "Loading Script: Maintenance"
}

# New 3-char aliases
$shortcuts = @{
    'ivq' = 'Invoke-DbaQuery'
    'cdi' = 'Connect-DbaInstance'
}
foreach ($sc in $shortcuts.GetEnumerator()) {
    New-Alias -Name $sc.Key -Value $sc.Value
}

# Leave forever
$forever = @{
    'Get-DbaRegisteredServer' = 'Get-DbaRegServer'
    'Attach-DbaDatabase'      = 'Mount-DbaDatabase'
    'Detach-DbaDatabase'      = 'Dismount-DbaDatabase'
    'Start-SqlMigration'      = 'Start-DbaMigration'
    'Write-DbaDataTable'      = 'Write-DbaDbTableData'
    'Get-DbaDbModule'         = 'Get-DbaModule'
    'Get-DbaBuildReference'   = 'Get-DbaBuild'
    'Copy-DbaSysDbUserObject' = 'Copy-DbaSystemDbUserObject'
}
foreach ($command in $forever.GetEnumerator()) {
    Set-Alias -Name $command.Key -Value $command.Value
}

# Replication Aliases
$replAliases = @{
    'Get-DbaRepServer'           = 'Get-DbaReplServer'
    'Export-DbaRepServerSetting' = 'Export-DbaReplServerSetting'
    'Get-DbaRepDistributor'      = 'Get-DbaReplDistributor'
    'Test-DbaRepLatency'         = 'Test-DbaReplLatency'
    'Get-DbaRepPublication'      = 'Get-DbaReplPublication'
}
foreach ($command in $replAliases.GetEnumerator()) {
    Set-Alias -Name $command.Key -Value $command.Value
}
#endregion Aliases

# apparently this is no longer required? :O
if ($PSVersionTable.PSVersion.Major -lt 5) {
    # region Commands
    $script:xplat = @(
        'Start-DbaMigration',
        'Copy-DbaDatabase',
        'Copy-DbaLogin',
        'Copy-DbaAgentServer',
        'Copy-DbaSpConfigure',
        'Copy-DbaDbMail',
        'Copy-DbaDbAssembly',
        'Copy-DbaAgentSchedule',
        'Copy-DbaAgentOperator',
        'Copy-DbaAgentJob',
        'Copy-DbaCustomError',
        'Copy-DbaInstanceAuditSpecification',
        'Copy-DbaEndpoint',
        'Copy-DbaInstanceAudit',
        'Copy-DbaServerRole',
        'Copy-DbaResourceGovernor',
        'Copy-DbaXESession',
        'Copy-DbaInstanceTrigger',
        'Copy-DbaRegServer',
        'Copy-DbaSystemDbUserObject',
        'Copy-DbaAgentProxy',
        'Copy-DbaAgentAlert',
        'Copy-DbaStartupProcedure',
        'Get-DbaDbDetachedFileInfo',
        'Copy-DbaAgentJobCategory',
        'Get-DbaLinkedServerLogin',
        'Test-DbaPath',
        'Export-DbaLogin',
        'Watch-DbaDbLogin',
        'Expand-DbaDbLogFile',
        'Test-DbaMigrationConstraint',
        'Test-DbaNetworkLatency',
        'Find-DbaDbDuplicateIndex',
        'Remove-DbaDatabaseSafely',
        'Set-DbaTempDbConfig',
        'Test-DbaTempDbConfig',
        'Repair-DbaDbOrphanUser',
        'Remove-DbaDbOrphanUser',
        'Find-DbaDbUnusedIndex',
        'Get-DbaDbSpace',
        'Test-DbaDbOwner',
        'Set-DbaDbOwner',
        'Test-DbaAgentJobOwner',
        'Set-DbaAgentJobOwner',
        'Measure-DbaDbVirtualLogFile',
        'Get-DbaDbRestoreHistory',
        'Get-DbaTcpPort',
        'Test-DbaDbCompatibility',
        'Test-DbaDbCollation',
        'Test-DbaConnectionAuthScheme',
        'Test-DbaInstanceName',
        'Repair-DbaInstanceName',
        'Stop-DbaProcess',
        'Find-DbaOrphanedFile',
        'Get-DbaAvailabilityGroup',
        'Get-DbaLastGoodCheckDb',
        'Get-DbaProcess',
        'Get-DbaRunningJob',
        'Set-DbaMaxDop',
        'Test-DbaDbRecoveryModel',
        'Test-DbaMaxDop',
        'Remove-DbaBackup',
        'Get-DbaPermission',
        'Get-DbaLastBackup',
        'Connect-DbaInstance',
        'Get-DbaDbBackupHistory',
        'Get-DbaAgBackupHistory',
        'Read-DbaBackupHeader',
        'Test-DbaLastBackup',
        'Get-DbaMaxMemory',
        'Set-DbaMaxMemory',
        'Get-DbaDbSnapshot',
        'Remove-DbaDbSnapshot',
        'Get-DbaDbRoleMember',
        'Get-DbaServerRoleMember',
        'Get-DbaDbAsymmetricKey',
        'New-DbaDbAsymmetricKey',
        'Remove-DbaDbAsymmetricKey',
        'Invoke-DbaDbTransfer',
        'New-DbaDbTransfer',
        'Remove-DbaDbData',
        'Resolve-DbaNetworkName',
        'Export-DbaAvailabilityGroup',
        'Write-DbaDbTableData',
        'New-DbaDbSnapshot',
        'Restore-DbaDbSnapshot',
        'Get-DbaInstanceTrigger',
        'Get-DbaDbTrigger',
        'Get-DbaDbState',
        'Set-DbaDbState',
        'Get-DbaHelpIndex',
        'Get-DbaAgentAlert',
        'Get-DbaAgentOperator',
        'Get-DbaSpConfigure',
        'Rename-DbaLogin',
        'Find-DbaAgentJob',
        'Find-DbaDatabase',
        'Get-DbaXESession',
        'Export-DbaXESession',
        'Test-DbaOptimizeForAdHoc',
        'Find-DbaStoredProcedure',
        'Measure-DbaBackupThroughput',
        'Get-DbaDatabase',
        'Find-DbaUserObject',
        'Get-DbaDependency',
        'Find-DbaCommand',
        'Backup-DbaDatabase',
        'Test-DbaBackupEncrypted',
        'New-DbaDirectory',
        'Get-DbaDbQueryStoreOption',
        'Set-DbaDbQueryStoreOption',
        'Restore-DbaDatabase',
        'Get-DbaDbFileMapping',
        'Copy-DbaDbQueryStoreOption',
        'Get-DbaExecutionPlan',
        'Export-DbaExecutionPlan',
        'Set-DbaSpConfigure',
        'Test-DbaIdentityUsage',
        'Get-DbaDbAssembly',
        'Get-DbaAgentJob',
        'Get-DbaCustomError',
        'Get-DbaCredential',
        'Get-DbaBackupDevice',
        'Get-DbaAgentProxy',
        'Get-DbaDbEncryption',
        'Disable-DbaDbEncryption',
        'Enable-DbaDbEncryption',
        'Get-DbaDbEncryptionKey',
        'New-DbaDbEncryptionKey',
        'Remove-DbaDbEncryptionKey',
        'Start-DbaDbEncryption',
        'Stop-DbaDbEncryption',
        'Remove-DbaDatabase',
        'Get-DbaQueryExecutionTime',
        'Get-DbaTempdbUsage',
        'Find-DbaDbGrowthEvent',
        'Test-DbaLinkedServerConnection',
        'Get-DbaDbFile',
        'Get-DbaDbFileGrowth',
        'Set-DbaDbFileGrowth',
        'Read-DbaTransactionLog',
        'Get-DbaDbTable',
        'Remove-DbaDbTable',
        'Invoke-DbaDbShrink',
        'Get-DbaEstimatedCompletionTime',
        'Get-DbaLinkedServer',
        'New-DbaAgentJob',
        'Get-DbaLogin',
        'New-DbaScriptingOption',
        'Save-DbaDiagnosticQueryScript',
        'Invoke-DbaDiagnosticQuery',
        'Export-DbaDiagnosticQuery',
        'Invoke-DbaWhoIsActive',
        'Set-DbaAgentJob',
        'Remove-DbaAgentJob',
        'New-DbaAgentJobStep',
        'Set-DbaAgentJobStep',
        'Remove-DbaAgentJobStep',
        'New-DbaAgentSchedule',
        'Set-DbaAgentSchedule',
        'Remove-DbaAgentSchedule',
        'Backup-DbaDbCertificate',
        'Get-DbaDbCertificate',
        'Copy-DbaDbCertificate',
        'Get-DbaEndpoint',
        'Get-DbaDbMasterKey',
        'Get-DbaSchemaChangeHistory',
        'Get-DbaInstanceAudit',
        'Get-DbaInstanceAuditSpecification',
        'Get-DbaProductKey',
        'Get-DbatoolsError',
        'Get-DbatoolsLog',
        'Restore-DbaDbCertificate',
        'New-DbaDbCertificate',
        'New-DbaDbMasterKey',
        'New-DbaServiceMasterKey',
        'Remove-DbaDbCertificate',
        'Remove-DbaDbMasterKey',
        'Get-DbaInstanceProperty',
        'Get-DbaInstanceUserOption',
        'New-DbaConnectionString',
        'Get-DbaAgentSchedule',
        'Read-DbaTraceFile',
        'Get-DbaInstanceInstallDate',
        'Backup-DbaDbMasterKey',
        'Get-DbaAgentJobHistory',
        'Get-DbaMaintenanceSolutionLog',
        'Invoke-DbaDbLogShipRecovery',
        'Find-DbaTrigger',
        'Find-DbaView',
        'Invoke-DbaDbUpgrade',
        'Get-DbaDbUser',
        'Get-DbaAgentLog',
        'Get-DbaDbMailLog',
        'Get-DbaDbMailHistory',
        'Get-DbaDbView',
        'Remove-DbaDbView',
        'New-DbaSqlParameter',
        'Get-DbaDbUdf',
        'Get-DbaDbPartitionFunction',
        'Get-DbaDbPartitionScheme',
        'Remove-DbaDbPartitionScheme',
        'Remove-DbaDbPartitionFunction',
        'Get-DbaDefaultPath',
        'Get-DbaDbStoredProcedure',
        'Test-DbaDbCompression',
        'Mount-DbaDatabase',
        'Dismount-DbaDatabase',
        'Get-DbaAgReplica',
        'Get-DbaAgDatabase',
        'Get-DbaModule',
        'Sync-DbaLoginPermission',
        'New-DbaCredential',
        'Get-DbaFile',
        'Set-DbaDbCompression',
        'Get-DbaTraceFlag',
        'Invoke-DbaCycleErrorLog',
        'Get-DbaAvailableCollation',
        'Get-DbaUserPermission',
        'Get-DbaAgHadr',
        'Find-DbaSimilarTable',
        'Get-DbaTrace',
        'Get-DbaSuspectPage',
        'Get-DbaWaitStatistic',
        'Clear-DbaWaitStatistics',
        'Get-DbaTopResourceUsage',
        'New-DbaLogin',
        'Get-DbaAgListener',
        'Invoke-DbaDbClone',
        'Disable-DbaTraceFlag',
        'Enable-DbaTraceFlag',
        'Start-DbaAgentJob',
        'Stop-DbaAgentJob',
        'New-DbaAgentProxy',
        'Test-DbaDbLogShipStatus',
        'Get-DbaXESessionTarget',
        'Get-DbaDbVirtualLogFile',
        'Get-DbaBackupInformation',
        'Start-DbaXESession',
        'Stop-DbaXESession',
        'Set-DbaDbRecoveryModel',
        'Get-DbaDbRecoveryModel',
        'Get-DbaWaitingTask',
        'Remove-DbaDbUser',
        'Get-DbaDump',
        'Invoke-DbaAdvancedRestore',
        'Format-DbaBackupInformation',
        'Get-DbaAgentJobStep',
        'Test-DbaBackupInformation',
        'Invoke-DbaBalanceDataFiles',
        'Select-DbaBackupInformation',
        'Publish-DbaDacPackage',
        'Copy-DbaDbTableData',
        'Copy-DbaDbViewData',
        'Invoke-DbaQuery',
        'Remove-DbaLogin',
        'Get-DbaAgentJobCategory',
        'New-DbaAgentJobCategory',
        'Remove-DbaAgentJobCategory',
        'Set-DbaAgentJobCategory',
        'Get-DbaServerRole',
        'Find-DbaBackup',
        'Remove-DbaXESession',
        'New-DbaXESession',
        'Get-DbaXEStore',
        'Get-DbaDbOrphanUser',
        'Get-DbaOpenTransaction',
        'Get-DbaDbLogShipError',
        'Test-DbaBuild',
        'Get-DbaXESessionTemplate',
        'ConvertTo-DbaXESession',
        'Start-DbaTrace',
        'Stop-DbaTrace',
        'Remove-DbaTrace',
        'Set-DbaLogin',
        'Copy-DbaXESessionTemplate',
        'Get-DbaXEObject',
        'ConvertTo-DbaDataTable',
        'Find-DbaDbDisabledIndex',
        'Get-DbaRegServerGroup',
        'New-DbaDbUser',
        'Measure-DbaDiskSpaceRequirement',
        'Find-DbaInstance',
        'Test-DbaDiskSpeed',
        'Get-DbaDbExtentDiff',
        'Read-DbaAuditFile',
        'Get-DbaDbCompression',
        'Invoke-DbaDbDecryptObject',
        'Get-DbaDbForeignKey',
        'Get-DbaDbCheckConstraint',
        'Remove-DbaDbCheckConstraint',
        'Set-DbaAgentAlert',
        'Get-DbaWaitResource',
        'Get-DbaDbPageInfo',
        'Get-DbaConnection',
        'Test-DbaLoginPassword',
        'Get-DbaErrorLogConfig',
        'Set-DbaErrorLogConfig',
        'Get-DbaPlanCache',
        'Clear-DbaPlanCache',
        'ConvertTo-DbaTimeline',
        'Get-DbaDbMail',
        'Get-DbaDbMailAccount',
        'Get-DbaDbMailProfile',
        'Get-DbaDbMailConfig',
        'Get-DbaDbMailServer',
        'New-DbaDbMailServer',
        'New-DbaDbMailAccount',
        'New-DbaDbMailProfile',
        'Get-DbaResourceGovernor',
        'Get-DbaRgResourcePool',
        'Get-DbaRgWorkloadGroup',
        'Get-DbaRgClassifierFunction',
        'Export-DbaInstance',
        'Invoke-DbatoolsRenameHelper',
        'Measure-DbatoolsImport',
        'Get-DbaDeprecatedFeature',
        'Get-DbaDbFeatureUsage',
        'Stop-DbaEndpoint',
        'Start-DbaEndpoint',
        'Set-DbaDbMirror',
        'Repair-DbaDbMirror',
        'Remove-DbaEndpoint',
        'Remove-DbaDbMirrorMonitor',
        'Remove-DbaDbMirror',
        'New-DbaEndpoint',
        'Invoke-DbaDbMirroring',
        'Invoke-DbaDbMirrorFailover',
        'Get-DbaDbMirrorMonitor',
        'Get-DbaDbMirror',
        'Add-DbaDbMirrorMonitor',
        'Test-DbaEndpoint',
        'Get-DbaDbSharePoint',
        'Get-DbaDbMemoryUsage',
        'Clear-DbaLatchStatistics',
        'Get-DbaCpuRingBuffer',
        'Get-DbaIoLatency',
        'Get-DbaLatchStatistic',
        'Get-DbaSpinLockStatistic',
        'Add-DbaAgDatabase',
        'Add-DbaAgListener',
        'Add-DbaAgReplica',
        'Grant-DbaAgPermission',
        'Invoke-DbaAgFailover',
        'Join-DbaAvailabilityGroup',
        'New-DbaAvailabilityGroup',
        'Remove-DbaAgDatabase',
        'Remove-DbaAgListener',
        'Remove-DbaAvailabilityGroup',
        'Revoke-DbaAgPermission',
        'Get-DbaDbCompatibility',
        'Set-DbaDbCompatibility',
        'Invoke-DbatoolsFormatter',
        'Remove-DbaAgReplica',
        'Resume-DbaAgDbDataMovement',
        'Set-DbaAgListener',
        'Set-DbaAgReplica',
        'Set-DbaAvailabilityGroup',
        'Set-DbaEndpoint',
        'Suspend-DbaAgDbDataMovement',
        'Sync-DbaAvailabilityGroup',
        'Get-DbaMemoryCondition',
        'Remove-DbaDbBackupRestoreHistory',
        'New-DbaDatabase'
        'New-DbaDacOption',
        'Get-DbaDbccHelp',
        'Get-DbaDbccMemoryStatus',
        'Get-DbaDbccProcCache',
        'Get-DbaDbccUserOption',
        'Get-DbaAgentServer',
        'Set-DbaAgentServer',
        'Invoke-DbaDbccFreeCache'
        'Export-DbatoolsConfig',
        'Import-DbatoolsConfig',
        'Reset-DbatoolsConfig',
        'Unregister-DbatoolsConfig',
        'Join-DbaPath',
        'Resolve-DbaPath',
        'Import-DbaCsv',
        'Invoke-DbaDbDataMasking',
        'New-DbaDbMaskingConfig',
        'Get-DbaDbccSessionBuffer',
        'Get-DbaDbccStatistic',
        'Get-DbaDbDbccOpenTran',
        'Invoke-DbaDbccDropCleanBuffer',
        'Invoke-DbaDbDbccCheckConstraint',
        'Invoke-DbaDbDbccCleanTable',
        'Invoke-DbaDbDbccUpdateUsage',
        'Get-DbaDbIdentity',
        'Set-DbaDbIdentity',
        'Get-DbaRegServer',
        'Get-DbaRegServerStore',
        'Add-DbaRegServer',
        'Add-DbaRegServerGroup',
        'Export-DbaRegServer',
        'Import-DbaRegServer',
        'Move-DbaRegServer',
        'Move-DbaRegServerGroup',
        'Remove-DbaRegServer',
        'Remove-DbaRegServerGroup',
        'New-DbaCustomError',
        'Remove-DbaCustomError',
        'Get-DbaDbSequence',
        'New-DbaDbSequence',
        'Remove-DbaDbSequence',
        'Select-DbaDbSequenceNextValue',
        'Set-DbaDbSequence',
        'Get-DbaDbUserDefinedTableType',
        'Get-DbaDbServiceBrokerService',
        'Get-DbaDbServiceBrokerQueue ',
        'Set-DbaResourceGovernor',
        'New-DbaRgResourcePool',
        'Set-DbaRgResourcePool',
        'Remove-DbaRgResourcePool',
        'Get-DbaDbServiceBrokerQueue',
        'New-DbaLinkedServer',
        # Config system
        'Get-DbatoolsConfig',
        'Get-DbatoolsConfigValue',
        'Set-DbatoolsConfig',
        'Register-DbatoolsConfig',
        # Data generator
        'New-DbaDbDataGeneratorConfig',
        'Invoke-DbaDbDataGenerator',
        'Get-DbaRandomizedValue',
        'Get-DbaRandomizedDatasetTemplate',
        'Get-DbaRandomizedDataset',
        'Get-DbaRandomizedType',
        'Export-DbaDbTableData',
        'Export-DbaBinaryFile',
        'Import-DbaBinaryFile',
        'Get-DbaBinaryFileTable',
        'Backup-DbaServiceMasterKey',
        'Invoke-DbaDbPiiScan',
        'New-DbaAzAccessToken',
        'Add-DbaDbRoleMember',
        'Disable-DbaStartupProcedure',
        'Enable-DbaStartupProcedure',
        'Get-DbaDbFileGroup',
        'Get-DbaDbObjectTrigger',
        'Get-DbaStartupProcedure',
        'Get-DbatoolsChangeLog',
        'Get-DbaXESessionTargetFile',
        'Get-DbaDbRole',
        'New-DbaDbRole',
        'New-DbaDbTable',
        'New-DbaDiagnosticAdsNotebook',
        'New-DbaServerRole',
        'Remove-DbaDbRole',
        'Remove-DbaDbRoleMember',
        'Remove-DbaServerRole',
        'Test-DbaDbDataGeneratorConfig',
        'Test-DbaDbDataMaskingConfig',
        'Get-DbaAgentAlertCategory',
        'New-DbaAgentAlertCategory',
        'Install-DbaAgentAdminAlert',
        'Remove-DbaAgentAlert',
        'Remove-DbaAgentAlertCategory',
        'Save-DbaKbUpdate',
        'Get-DbaKbUpdate',
        'Get-DbaDbLogSpace',
        'Export-DbaDbRole',
        'Export-DbaServerRole',
        'Get-DbaBuild',
        'Update-DbaBuildReference',
        'Install-DbaFirstResponderKit',
        'Install-DbaSqlPackage',
        'Install-DbaWhoIsActive',
        'Update-Dbatools',
        'Add-DbaServerRoleMember',
        'Get-DbatoolsPath',
        'Set-DbatoolsPath',
        'Export-DbaSysDbUserObject',
        'Test-DbaDbQueryStore',
        'Install-DbaMultiTool',
        'New-DbaAgentOperator',
        'Remove-DbaAgentOperator',
        'Remove-DbaDbTableData',
        'Get-DbaDbSchema',
        'New-DbaDbSchema',
        'Set-DbaDbSchema',
        'Remove-DbaDbSchema',
        'Get-DbaDbSynonym',
        'New-DbaDbSynonym',
        'Remove-DbaDbSynonym',
        'Install-DbaDarlingData',
        'New-DbaDbFileGroup',
        'Remove-DbaDbFileGroup',
        'Set-DbaDbFileGroup',
        'Remove-DbaLinkedServer',
        'Test-DbaAvailabilityGroup',
        'Export-DbaUser',
        'Get-DbaSsisExecutionHistory',
        'New-DbaConnectionStringBuilder',
        'New-DbatoolsSupportPackage',
        'Export-DbaScript',
        'Get-DbaAgentJobOutputFile',
        'Set-DbaAgentJobOutputFile',
        'Import-DbaXESessionTemplate',
        'Export-DbaXESessionTemplate',
        'Import-DbaSpConfigure',
        'Export-DbaSpConfigure',
        'Test-DbaMaxMemory',
        'Install-DbaMaintenanceSolution',
        'Get-DbaManagementObject',
        'Set-DbaAgentOperator',
        'Remove-DbaExtendedProperty',
        'Get-DbaExtendedProperty',
        'Set-DbaExtendedProperty',
        'Add-DbaExtendedProperty',
        'Get-DbaOleDbProvider',
        'Get-DbaConnectedInstance',
        'Disconnect-DbaInstance',
        'Set-DbaDefaultPath',
        'New-DbaDacProfile',
        'Export-DbaDacPackage',
        'Remove-DbaDbUdf',
        'Save-DbaCommunitySoftware',
        'Update-DbaMaintenanceSolution',
        'Remove-DbaServerRoleMember',
        'Remove-DbaDbMailProfile',
        'Remove-DbaDbMailAccount',
        'Set-DbaRgWorkloadGroup',
        'New-DbaRgWorkloadGroup',
        'Remove-DbaRgWorkloadGroup',
        'New-DbaLinkedServerLogin',
        'Remove-DbaLinkedServerLogin',
        'Remove-DbaCredential',
        'Remove-DbaAgentProxy',
        'Invoke-DbaDbAzSqlTip',
        'New-DbaAgentAlert',
        'Set-DbatoolsInsecureConnection',
        'Test-DbaAgSpn'
    )
    $script:noncoresmo = @(
        # SMO issues
        'Copy-DbaSsisCatalog',
        'Get-DbaSsisEnvironmentVariable',
        'New-DbaSsisCatalog',
        'Copy-DbaPolicyManagement',
        'Copy-DbaDataCollector',
        'Get-DbaPbmCategory',
        'Get-DbaPbmCategorySubscription',
        'Get-DbaPbmCondition',
        'Get-DbaPbmObjectSet',
        'Get-DbaPbmPolicy',
        'Get-DbaPbmStore',
        'Test-DbaReplLatency',
        'Export-DbaReplServerSetting',
        'Disable-DbaReplDistributor',
        'Enable-DbaReplDistributor',
        'Disable-DbaReplPublishing',
        'Enable-DbaReplPublishing',
        'New-DbaReplPublication',
        'Get-DbaReplArticle',
        'Get-DbaReplArticleColumn',
        'Add-DbaReplArticle',
        'Remove-DbaReplArticle',
        'Remove-DbaReplPublication',
        'New-DbaReplSubscription',
        'Remove-DbaReplSubscription',
        'New-DbaReplCreationScriptOptions',
        'Get-DbaReplSubscription',
        'Get-DbaReplDistributor',
        'Get-DbaReplPublication',
        'Get-DbaReplServer',
        'Get-DbaReplPublisher'
    )
    $script:windowsonly = @(
        # filesystem (\\ related),
        'Move-DbaDbFile'
        'Copy-DbaBackupDevice',
        'Read-DbaXEFile',
        'Watch-DbaXESession',
        # Registry
        'Get-DbaRegistryRoot',
        # GAC
        'Test-DbaManagementObject',
        # CM and Windows functions
        'Get-DbaInstalledPatch',
        'Get-DbaFirewallRule',
        'New-DbaFirewallRule',
        'Remove-DbaFirewallRule',
        'Rename-DbaDatabase',
        'Get-DbaNetworkConfiguration',
        'Set-DbaNetworkConfiguration',
        'Get-DbaExtendedProtection',
        'Set-DbaExtendedProtection',
        'Install-DbaInstance',
        'Invoke-DbaAdvancedInstall',
        'Update-DbaInstance',
        'Invoke-DbaAdvancedUpdate',
        'Invoke-DbaPfRelog',
        'Get-DbaPfDataCollectorCounter',
        'Get-DbaPfDataCollectorCounterSample',
        'Get-DbaPfDataCollector',
        'Get-DbaPfDataCollectorSet',
        'Start-DbaPfDataCollectorSet',
        'Stop-DbaPfDataCollectorSet',
        'Export-DbaPfDataCollectorSetTemplate',
        'Get-DbaPfDataCollectorSetTemplate',
        'Import-DbaPfDataCollectorSetTemplate',
        'Remove-DbaPfDataCollectorSet',
        'Add-DbaPfDataCollectorCounter',
        'Remove-DbaPfDataCollectorCounter',
        'Get-DbaPfAvailableCounter',
        'Get-DbaOperatingSystem',
        'Get-DbaComputerSystem',
        'Set-DbaPrivilege',
        'Set-DbaTcpPort',
        'Set-DbaCmConnection',
        'Get-DbaUptime',
        'Get-DbaMemoryUsage',
        'Clear-DbaConnectionPool',
        'Get-DbaLocaleSetting',
        'Get-DbaFilestream',
        'Enable-DbaFilestream',
        'Disable-DbaFilestream',
        'Get-DbaCpuUsage',
        'Get-DbaPowerPlan',
        'Get-DbaWsfcAvailableDisk',
        'Get-DbaWsfcCluster',
        'Get-DbaWsfcDisk',
        'Get-DbaWsfcNetwork',
        'Get-DbaWsfcNetworkInterface',
        'Get-DbaWsfcNode',
        'Get-DbaWsfcResource',
        'Get-DbaWsfcResourceGroup',
        'Get-DbaWsfcResourceType',
        'Get-DbaWsfcRole',
        'Get-DbaWsfcSharedVolume',
        'Export-DbaCredential',
        'Export-DbaLinkedServer',
        'Get-DbaFeature',
        'Update-DbaServiceAccount',
        'Remove-DbaClientAlias',
        'Disable-DbaAgHadr',
        'Enable-DbaAgHadr',
        'Stop-DbaService',
        'Start-DbaService',
        'Restart-DbaService',
        'New-DbaClientAlias',
        'Get-DbaClientAlias',
        'Stop-DbaExternalProcess',
        'Get-DbaExternalProcess',
        'Remove-DbaNetworkCertificate',
        'Enable-DbaForceNetworkEncryption',
        'Disable-DbaForceNetworkEncryption',
        'Get-DbaForceNetworkEncryption',
        'Get-DbaHideInstance',
        'Enable-DbaHideInstance',
        'Disable-DbaHideInstance',
        'New-DbaComputerCertificateSigningRequest',
        'Remove-DbaComputerCertificate',
        'New-DbaComputerCertificate',
        'Get-DbaComputerCertificate',
        'Add-DbaComputerCertificate',
        'Backup-DbaComputerCertificate',
        'Test-DbaComputerCertificateExpiration',
        'Get-DbaNetworkCertificate',
        'Set-DbaNetworkCertificate',
        'Remove-DbaDbLogShipping',
        'Invoke-DbaDbLogShipping',
        'New-DbaCmConnection',
        'Get-DbaCmConnection',
        'Remove-DbaCmConnection',
        'Test-DbaCmConnection',
        'Get-DbaCmObject',
        'Set-DbaStartupParameter',
        'Get-DbaNetworkActivity',
        'Get-DbaInstanceProtocol',
        'Get-DbaPrivilege',
        'Get-DbaMsdtc',
        'Get-DbaPageFileSetting',
        'Copy-DbaCredential',
        'Test-DbaConnection',
        'Reset-DbaAdmin',
        'Copy-DbaLinkedServer',
        'Get-DbaDiskSpace',
        'Test-DbaDiskAllocation',
        'Test-DbaPowerPlan',
        'Set-DbaPowerPlan',
        'Test-DbaDiskAlignment',
        'Get-DbaStartupParameter',
        'Get-DbaSpn',
        'Test-DbaSpn',
        'Set-DbaSpn',
        'Remove-DbaSpn',
        'Get-DbaService',
        'Get-DbaClientProtocol',
        'Get-DbaWindowsLog',
        # WPF
        'Show-DbaInstanceFileSystem',
        'Show-DbaDbList',
        # AD
        'Test-DbaWindowsLogin',
        'Find-DbaLoginInGroup',
        # 3rd party non-core DLL or sqlpackage.exe
        'Install-DbaSqlWatch',
        'Uninstall-DbaSqlWatch',
        # Unknown
        'Get-DbaErrorLog'
    )

    # If a developer or appveyor calls the psm1 directly, they want all functions
    # So do not explicitly export because everything else is then implicitly excluded
    if (-not $script:serialimport) {
        $exports =
        @(if (($PSVersionTable.Platform)) {
                if ($PSVersionTable.Platform -ne "Win32NT") {
                    $script:xplat
                } else {
                    $script:xplat
                    $script:windowsonly
                }
            } else {
                $script:xplat
                $script:windowsonly
                $script:noncoresmo
            })

        $aliasExport = @(
            foreach ($k in $script:Renames.Keys) {
                $k
            }
            foreach ($k in $script:Forever.Keys) {
                $k
            }
            foreach ($c in $script:shortcuts.Keys) {
                $c
            }
        )

        Export-ModuleMember -Alias $aliasExport -Function $exports -Cmdlet Select-DbaObject, Set-DbatoolsConfig
        Write-ImportTime -Text "Exporting explicit module members"
    } else {
        Export-ModuleMember -Alias * -Function * -Cmdlet *
        Write-ImportTime -Text "Exporting all module members"
    }
}

$myInv = $MyInvocation
if ($option.LoadTypes -or
    ($myInv.Line -like '*.psm1*' -and
        (-not (Get-TypeData -TypeName Microsoft.SqlServer.Management.Smo.Server)
        ))) {
    Update-TypeData -AppendPath (Resolve-Path -Path "$script:PSModuleRoot\xml\dbatools.Types.ps1xml")
    Write-ImportTime -Text "Updating type data"
}

$loadedModuleNames = (Get-Module sqlserver, sqlps -ErrorAction Ignore).Name
if ($loadedModuleNames -contains 'sqlserver' -or $loadedModuleNames -contains 'sqlps') {
    if (Get-DbatoolsConfigValue -FullName Import.SqlpsCheck) {
        Write-Warning -Message 'SQLPS or SqlServer was previously imported during this session. If you encounter weird issues with dbatools, please restart PowerShell, then import dbatools without loading SQLPS or SqlServer first.'
        Write-Warning -Message 'To disable this message, type: Set-DbatoolsConfig -Name Import.SqlpsCheck -Value $false -PassThru | Register-DbatoolsConfig'
    }
}
Write-ImportTime -Text "Checking for SqlServer or SQLPS"
#endregion Post-Import Cleanup

# Removal of runspaces is needed to successfully close PowerShell ISE
if (Test-Path -Path Variable:global:psISE) {
    $onRemoveScript = {
        Get-Runspace | Where-Object Name -Like dbatools* | ForEach-Object -Process { $_.Dispose() }
    }
    $ExecutionContext.SessionState.Module.OnRemove += $onRemoveScript
    Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $onRemoveScript
}
Write-ImportTime -Text "Checking for some ISE stuff"

# Create collection for servers
$script:connectionhash = @{ }


if (Get-DbatoolsConfigValue -FullName Import.EncryptionMessageCheck) {
    $trustcert = Get-DbatoolsConfigValue -FullName sql.connection.trustcert
    $encrypt = Get-DbatoolsConfigValue -FullName sql.connection.encrypt
    # support old settings as well for those whose settings are stuck on string
    if (-not $trustcert -or $encrypt -in @("Mandatory", "$true", $true)) {
        # keep it write-host for psv3
        Write-Message -Level Output -Message '
/   /                                                                     /   /
| O |                                                                     | O |
|   |- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -|   |
| O |                                                                     | O |
|   |                                                                     |   |
| O |                                                                     | O |
|   |                       C O M P U T E R                               |   |
| O |                                                                     | O |
|   |                               M E S S A G E                         |   |
| O |                                                                     | O |
|   |                                                                     |   |
| O |- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -| O |
|   |                                                                     |   |

Microsoft changed the encryption defaults in their SqlClient library, which may
cause your connections to fail.

You can change the defaults with Set-DbatoolsConfig but dbatools also makes it
easy to setup encryption. Check out dbatools.io/newdefaults for more information.

To disable this message, run:

Set-DbatoolsConfig -Name Import.EncryptionMessageCheck -Value $false -PassThru |
Register-DbatoolsConfig'
    }
}

[Dataplat.Dbatools.dbaSystem.SystemHost]::ModuleImported = $true
# SIG # Begin signature block
# MIIt3AYJKoZIhvcNAQcCoIItzTCCLckCAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCi52FijtDMjga0
# W+yHZ7qlwBtGmByJPQto31AqtgbmV6CCFdswggbXMIIEv6ADAgECAhMzAARmjSb9
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
# avFIrmcxghdXMIIXUwIBATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmll
# ZCBDUyBFT0MgQ0EgMDICEzMABGaNJv2xMsNKf/EAAAAEZo0wCwYJYIZIAWUDBAIB
# oHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIsY
# TnwkHPibPcJ8rqIJgoY5UrkTvaW77NWwar5dpkZ6MAsGCSqGSIb3DQEBAQSCAYAP
# MezKUkxFySAkaSLhekWwbsGJOdrprSKkpyfSHdAN9fwqQbRFPrm1YRkKwg+Q07f1
# LfQMckwEyXtFcuzbMaURBwNi+qMmm2BuWTpqKWn4QHrUi5jG2EBPYCM3ewUAqvvx
# K4xKTT7crW+Qijada+SBJYVamX6G+epzQG+D1a6bZH3X384ryw34D8nDXlzc3xcf
# tkQSJ4+wu/u0cYWRY1RfhSHafdq8+8yZ+9n7BuUDS8X+oDzciuLMBQbb0/9goZv/
# Z01wUdXgEVxWjYqGmHsFzez1R/e8fr0AY8NqkEusKsnevua0f05aEZvMGe9OyrbV
# rbD83jkrICcCVIUF+De0+xASSTSLahJAvjYD4zkUgDEVYAysOTCEvjDlkevuz9cG
# r/IoMqowdyZCQQ/ftdK7if0y6qxc7coBORbXbZq83TZ0iurVAyITmtxjHmR96hKg
# o8s+BZAy3oMUh08VkjCDp+SeXLySdome39ZbBcIlRKD/99C8ZyPhdr3mGnKn666h
# ghS9MIIUuQYKKwYBBAGCNwMDATGCFKkwghSlBgkqhkiG9w0BBwKgghSWMIIUkgIB
# AzEPMA0GCWCGSAFlAwQCAQUAMIIBdQYLKoZIhvcNAQkQAQSgggFkBIIBYDCCAVwC
# AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQgxl0k5iPRGokHYJ/WcAv8
# 42wrXxQ3f+if1uWdJj2kA/cCBmjCIoyczBgTMjAyNTA5MTkxMTAxMTcuMTIyWjAE
# gAIB9AIJAPWoUtcT0W1NoIHppIHmMIHjMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
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
# KoZIhvcNAQkEMSIEIKYeHNMT1/glXnirhB8YNaYXzD3TW9t1kZ7Equ31ZtiPMIHd
# BgsqhkiG9w0BCRACLzGBzTCByjCBxzCBoAQgQH8fBGKMq5T++MBTsF0cGn+0dF+t
# Ew+Q16OV0Z/aHSMwfDBlpGMwYTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFB1YmxpYyBSU0Eg
# VGltZXN0YW1waW5nIENBIDIwMjACEzMAAABTUsIDi+Wa+E4AAAAAAFMwIgQgD0DM
# GQmb1VTTcX7TxVLeoKcWOxOT5NpDnyl0NpHBAowwDQYJKoZIhvcNAQELBQAEggIA
# gemiw96mHE6ztKMBvgmBK4ldyZbNvgq9ih0Wr6VzcaXqofQIks+hoemH8M1Kw169
# s9t5GhFwyndBaxCSeJaUBl7nWZLb29ExQxSMDTppftyOwLdTn0pFdrwsOIBDDany
# 551qQEZtwFYsCgnWk4R6T54ScSJLkMEz7Q2LvzdgJR272kRpvxqS1Ewj0t+hPiR2
# dnIsE9EO/9g9SpSOFAWSgNAYsKSFz/7CD1/3jiUbRWfrXJfmfnxVi2ldWcsTg0IT
# p54n+IuUOFA55PurISZrxb3VhjugWDfReVYODC9S7WulyI2yeGNO8D09DCg1hMIP
# aRLLJPw1B0lDngjJebr5+SQ9utBmHCFmaXiADlWcmW+WSyU4QJ7ipSNgbPzrPdNd
# PnsK7iFgRzXDMedvcVm7dxrWvm3+8SOdwuCv/6+DB66wpPOapmM4gjfdt/ywJah8
# 3vvV7os2ol9B0TOxhGy6f4g1qn/driaEYy5pSQEbJF9OzVqcpRJXzZWCrC8jNuNH
# sgs564yZMVgCLgVmRhvUCwELtG9U5WkkDoT53+SNO+N4aBE0DFHDachWigplOOjs
# nJbDZ6dXZmkp1Fh+VsxlTEBednDJh9E76TGR6D1gCecnZC5gfsryqTsJl1YIQxv4
# hTEAzzt6j8jkiTT7afxEWMSTsKqNseQAVNRnlLmyWAY=
# SIG # End signature block
