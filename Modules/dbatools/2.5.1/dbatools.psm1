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
        'Set-DbaTempdbConfig',
        'Test-DbaTempdbConfig',
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
        'Invoke-DbaDbAzSqlTips',
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
        'New-DbaXESmartTargetResponse',
        'New-DbaXESmartTarget',
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
        'New-DbaXESmartTableWriter',
        'New-DbaXESmartReplay',
        'New-DbaXESmartEmail',
        'New-DbaXESmartQueryExec',
        'Start-DbaXESmartTarget',
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
        'Get-DbaXESmartTarget',
        'Remove-DbaXESmartTarget',
        'Stop-DbaXESmartTarget',
        'Get-DbaRegServerGroup',
        'New-DbaDbUser',
        'Measure-DbaDiskSpaceRequirement',
        'New-DbaXESmartCsvWriter',
        'Invoke-DbaXeReplay',
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
        'Test-DbaDeprecatedFeature'
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
        'Get-DbaDbFilegroup',
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
        'Get-DbaReplServer'
    )
    $script:noncoresmo = @(
        # SMO issues
        'Copy-DbaPolicyManagement',
        'Copy-DbaDataCollector',
        'Get-DbaPbmCategory',
        'Get-DbaPbmCategorySubscription',
        'Get-DbaPbmCondition',
        'Get-DbaPbmObjectSet',
        'Get-DbaPbmPolicy',
        'Get-DbaPbmStore',
        'Test-DbaReplLatency',
        'Export-DbaReplServerSetting'
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
        'Export-DbaXECsv',
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
        'Remove-DbaDbLogshipping',
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
# MIIf5wYJKoZIhvcNAQcCoIIf2DCCH9QCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDywzk2vEUC8A2g
# GNwqgZoJrczpklDbh2+GmmtgJDWKEaCCGoUwggNZMIIC36ADAgECAhAPuKdAuRWN
# A1FDvFnZ8EApMAoGCCqGSM49BAMDMGExCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xIDAeBgNVBAMT
# F0RpZ2lDZXJ0IEdsb2JhbCBSb290IEczMB4XDTIxMDQyOTAwMDAwMFoXDTM2MDQy
# ODIzNTk1OVowZDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu
# MTwwOgYDVQQDEzNEaWdpQ2VydCBHbG9iYWwgRzMgQ29kZSBTaWduaW5nIEVDQyBT
# SEEzODQgMjAyMSBDQTEwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAAS7tKwnpUgNolNf
# jy6BPi9TdrgIlKKaqoqLmLWx8PwqFbu5s6UiL/1qwL3iVWhga5c0wWZTcSP8GtXK
# IA8CQKKjSlpGo5FTK5XyA+mrptOHdi/nZJ+eNVH8w2M1eHbk+HejggFXMIIBUzAS
# BgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBSbX7A2up0GrhknvcCgIsCLizh3
# 7TAfBgNVHSMEGDAWgBSz20ik+aHF2K42QcwRY2liKbxLxjAOBgNVHQ8BAf8EBAMC
# AYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdgYIKwYBBQUHAQEEajBoMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQAYIKwYBBQUHMAKGNGh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEdsb2JhbFJvb3RHMy5jcnQw
# QgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0R2xvYmFsUm9vdEczLmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEE
# ATAKBggqhkjOPQQDAwNoADBlAjB4vUmVZXEB0EZXaGUOaKncNgjB7v3UjttAZT8N
# /5Ovwq5jhqN+y7SRWnjsBwNnB3wCMQDnnx/xB1usNMY4vLWlUM7m6jh+PnmQ5KRb
# qwIN6Af8VqZait2zULLd8vpmdJ7QFmMwggPqMIIDcaADAgECAhAOHemwPSTVqXgv
# ggZ4NPQsMAoGCCqGSM49BAMDMGQxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdp
# Q2VydCwgSW5jLjE8MDoGA1UEAxMzRGlnaUNlcnQgR2xvYmFsIEczIENvZGUgU2ln
# bmluZyBFQ0MgU0hBMzg0IDIwMjEgQ0ExMB4XDTIzMDkyMTAwMDAwMFoXDTI2MDky
# MjIzNTk1OVowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czB2MBAGByqGSM49AgEGBSuBBAAiA2IABC6YdcOODdGCkc8ZzeGbDI++qRZ9YTKK
# qUnPv5MhjMPJp8DJ4RShm9E2ca+8d0H9jnkt+ojKZHRUypRMbJwdsa1x05OWJeMs
# R/V7A1F2l0HCZKnHeGZSvT/ULgnXK/Y3AKOCAfMwggHvMB8GA1UdIwQYMBaAFJtf
# sDa6nQauGSe9wKAiwIuLOHftMB0GA1UdDgQWBBQxtF8QYL4zT3LN1Hs9UW0D6354
# KjA+BgNVHSAENzA1MDMGBmeBDAEEATApMCcGCCsGAQUFBwIBFhtodHRwOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMIGrBgNVHR8EgaMwgaAwTqBMoEqGSGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEdsb2JhbEczQ29kZVNpZ25pbmdFQ0NTSEEzODQyMDIxQ0Ex
# LmNybDBOoEygSoZIaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0R2xv
# YmFsRzNDb2RlU2lnbmluZ0VDQ1NIQTM4NDIwMjFDQTEuY3JsMIGOBggrBgEFBQcB
# AQSBgTB/MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wVwYI
# KwYBBQUHMAKGS2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEds
# b2JhbEczQ29kZVNpZ25pbmdFQ0NTSEEzODQyMDIxQ0ExLmNydDAJBgNVHRMEAjAA
# MAoGCCqGSM49BAMDA2cAMGQCMFfGfg/mKq3eZDf8HrYMtoFIyNtpBYjNKr3cXmTn
# j6OYhexOpbILTlcYRItOgS+5qAIwIauBEHKYpJc0g0RuwILa0cvI1MfL4/DeVhY5
# Iw3Q/FMrWDXnMtovGZjFRPHKD5vlMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21Di
# CEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtE
# aWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzEx
# MTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/
# 5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xuk
# OBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpz
# MpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7Fsa
# vOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qT
# XtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRz
# Km6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRc
# Ro9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADk
# RSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMY
# RJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4m
# rLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C
# 1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYD
# VR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYD
# VR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkG
# CCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQu
# Y29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6
# Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmww
# EQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+g
# o3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0
# /4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnL
# nU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU9
# 6LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ
# 9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9X
# ql4o4rmUMIIGtDCCBJygAwIBAgIQDcesVwX/IZkuQEMiDDpJhjANBgkqhkiG9w0B
# AQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVk
# IFJvb3QgRzQwHhcNMjUwNTA3MDAwMDAwWhcNMzgwMTE0MjM1OTU5WjBpMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUg
# Q0ExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtHgx0wqYQXK+PEbA
# HKx126NGaHS0URedTa2NDZS1mZaDLFTtQ2oRjzUXMmxCqvkbsDpz4aH+qbxeLho8
# I6jY3xL1IusLopuW2qftJYJaDNs1+JH7Z+QdSKWM06qchUP+AbdJgMQB3h2DZ0Ma
# l5kYp77jYMVQXSZH++0trj6Ao+xh/AS7sQRuQL37QXbDhAktVJMQbzIBHYJBYgzW
# Ijk8eDrYhXDEpKk7RdoX0M980EpLtlrNyHw0Xm+nt5pnYJU3Gmq6bNMI1I7Gb5IB
# ZK4ivbVCiZv7PNBYqHEpNVWC2ZQ8BbfnFRQVESYOszFI2Wv82wnJRfN20VRS3hpL
# gIR4hjzL0hpoYGk81coWJ+KdPvMvaB0WkE/2qHxJ0ucS638ZxqU14lDnki7CcoKC
# z6eum5A19WZQHkqUJfdkDjHkccpL6uoG8pbF0LJAQQZxst7VvwDDjAmSFTUms+wV
# /FbWBqi7fTJnjq3hj0XbQcd8hjj/q8d6ylgxCZSKi17yVp2NL+cnT6Toy+rN+nM8
# M7LnLqCrO2JP3oW//1sfuZDKiDEb1AQ8es9Xr/u6bDTnYCTKIsDq1BtmXUqEG1Nq
# zJKS4kOmxkYp2WyODi7vQTCBZtVFJfVZ3j7OgWmnhFr4yUozZtqgPrHRVHhGNKlY
# zyjlroPxul+bgIspzOwbtmsgY1MCAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFO9vU0rp5AZ8esrikFb2L9RJ7MtOMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQAXzvsWgBz+Bz0RdnEwvb4LyLU0pn/N0IfFiBowf0/Dm1wG
# c/Do7oVMY2mhXZXjDNJQa8j00DNqhCT3t+s8G0iP5kvN2n7Jd2E4/iEIUBO41P5F
# 448rSYJ59Ib61eoalhnd6ywFLerycvZTAz40y8S4F3/a+Z1jEMK/DMm/axFSgoR8
# n6c3nuZB9BfBwAQYK9FHaoq2e26MHvVY9gCDA/JYsq7pGdogP8HRtrYfctSLANEB
# fHU16r3J05qX3kId+ZOczgj5kjatVB+NdADVZKON/gnZruMvNYY2o1f4MXRJDMdT
# SlOLh0HCn2cQLwQCqjFbqrXuvTPSegOOzr4EWj7PtspIHBldNE2K9i697cvaiIo2
# p61Ed2p8xMJb82Yosn0z4y25xUbI7GIN/TpVfHIqQ6Ku/qjTY6hc3hsXMrS+U0yy
# +GWqAXam4ToWd2UQ1KYT70kZjE4YtL8Pbzg0c1ugMZyZZd/BdHLiRu7hAWE6bTEm
# 4XYRkA6Tl4KSFLFk43esaUeqGkH/wyW4N7OigizwJWeukcyIPbAvjSabnf7+Pu0V
# rFgoiovRDiyx3zEdmcif/sYQsfch28bZeUz2rtY/9TCA6TD8dC3JE3rYkrhLULy7
# Dc90G6e8BlqmyIjlgp2+VqsS9/wQD7yFylIz0scmbKvFoW2jNrbM1pD2T7m3XDCC
# Bu0wggTVoAMCAQICEAqA7xhLjfEFgtHEdqeVdGgwDQYJKoZIhvcNAQELBQAwaTEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhE
# aWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAy
# MDI1IENBMTAeFw0yNTA2MDQwMDAwMDBaFw0zNjA5MDMyMzU5NTlaMGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgU0hBMjU2IFJTQTQwOTYgVGltZXN0YW1wIFJlc3BvbmRlciAyMDI1IDEwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDQRqwtEsae0OquYFazK1e6b1H/
# hnAKAd/KN8wZQjBjMqiZ3xTWcfsLwOvRxUwXcGx8AUjni6bz52fGTfr6PHRNv6T7
# zsf1Y/E3IU8kgNkeECqVQ+3bzWYesFtkepErvUSbf+EIYLkrLKd6qJnuzK8Vcn0D
# vbDMemQFoxQ2Dsw4vEjoT1FpS54dNApZfKY61HAldytxNM89PZXUP/5wWWURK+If
# xiOg8W9lKMqzdIo7VA1R0V3Zp3DjjANwqAf4lEkTlCDQ0/fKJLKLkzGBTpx6EYev
# vOi7XOc4zyh1uSqgr6UnbksIcFJqLbkIXIPbcNmA98Oskkkrvt6lPAw/p4oDSRZr
# eiwB7x9ykrjS6GS3NR39iTTFS+ENTqW8m6THuOmHHjQNC3zbJ6nJ6SXiLSvw4Smz
# 8U07hqF+8CTXaETkVWz0dVVZw7knh1WZXOLHgDvundrAtuvz0D3T+dYaNcwafsVC
# GZKUhQPL1naFKBy1p6llN3QgshRta6Eq4B40h5avMcpi54wm0i2ePZD5pPIssosz
# QyF4//3DoK2O65Uck5Wggn8O2klETsJ7u8xEehGifgJYi+6I03UuT1j7FnrqVrOz
# aQoVJOeeStPeldYRNMmSF3voIgMFtNGh86w3ISHNm0IaadCKCkUe2LnwJKa8TIlw
# CUNVwppwn4D3/Pt5pwIDAQABo4IBlTCCAZEwDAYDVR0TAQH/BAIwADAdBgNVHQ4E
# FgQU5Dv88jHt/f3X85FxYxlQQ89hjOgwHwYDVR0jBBgwFoAU729TSunkBnx6yuKQ
# VvYv1Ensy04wDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MIGVBggrBgEFBQcBAQSBiDCBhTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGln
# aWNlcnQuY29tMF0GCCsGAQUFBzAChlFodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3RhbXBpbmdSU0E0MDk2U0hBMjU2MjAy
# NUNBMS5jcnQwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIw
# MjVDQTEuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkq
# hkiG9w0BAQsFAAOCAgEAZSqt8RwnBLmuYEHs0QhEnmNAciH45PYiT9s1i6UKtW+F
# ERp8FgXRGQ/YAavXzWjZhY+hIfP2JkQ38U+wtJPBVBajYfrbIYG+Dui4I4PCvHpQ
# uPqFgqp1PzC/ZRX4pvP/ciZmUnthfAEP1HShTrY+2DE5qjzvZs7JIIgt0GCFD9kt
# x0LxxtRQ7vllKluHWiKk6FxRPyUPxAAYH2Vy1lNM4kzekd8oEARzFAWgeW3az2xe
# jEWLNN4eKGxDJ8WDl/FQUSntbjZ80FU3i54tpx5F/0Kr15zW/mJAxZMVBrTE2oi0
# fcI8VMbtoRAmaaslNXdCG1+lqvP4FbrQ6IwSBXkZagHLhFU9HCrG/syTRLLhAezu
# /3Lr00GrJzPQFnCEH1Y58678IgmfORBPC1JKkYaEt2OdDh4GmO0/5cHelAK2/gTl
# QJINqDr6JfwyYHXSd+V08X1JUPvB4ILfJdmL+66Gp3CSBXG6IwXMZUXBhtCyIaeh
# r0XkBoDIGMUG1dUtwq1qmcwbdUfcSYCn+OwncVUXf53VJUNOaMWMts0VlRYxe5nK
# +At+DI96HAlXHAL5SlfYxJ7La54i71McVWRP66bW+yERNpbJCjyCYG2j+bdpxo/1
# Cy4uPcU3AWVPGrbn5PhDBf3Froguzzhk++ami+r3Qrx5bIbY3TVzgiFI7Gq3zWcx
# ggS4MIIEtAIBATB4MGQxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE8MDoGA1UEAxMzRGlnaUNlcnQgR2xvYmFsIEczIENvZGUgU2lnbmluZyBF
# Q0MgU0hBMzg0IDIwMjEgQ0ExAhAOHemwPSTVqXgvggZ4NPQsMA0GCWCGSAFlAwQC
# AQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZI
# hvcNAQkEMSIEIL323xcH0Gu3Hy5XJP+kXadglO1WLOIB/ep0KTp7NKX6MAsGByqG
# SM49AgEFAARoMGYCMQCVgIYmnFm66QjArUKBdgE1IbuMPPeKupAf6AQSwLFetXjp
# gydwDd92m7Q3qWVsNr8CMQCtCbS6rsHUQ6Fvn3RcXaUJulhfQJiv+I6adb/nxRbu
# AomtGIJBo7Dv56D1Sc+PXlKhggMmMIIDIgYJKoZIhvcNAQkGMYIDEzCCAw8CAQEw
# fTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNV
# BAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hB
# MjU2IDIwMjUgQ0ExAhAKgO8YS43xBYLRxHanlXRoMA0GCWCGSAFlAwQCAQUAoGkw
# GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjUwNzIz
# MTkyMzEwWjAvBgkqhkiG9w0BCQQxIgQgG2tK/9vKLFwn1GAfba/jogEQW0EDAHUx
# b5HvkftQwYgwDQYJKoZIhvcNAQEBBQAEggIAHcPucCAzUYpZcMD0WamDad0XhyDB
# 28jQHGg0UuhxtXZXL6NYa5XN3mUmWLZRwhGSVGWryghP0ZTiLqGk6beapGJ783hw
# kyMnGF7eqyVcmFQSvKfo8/o+341MMSO6PV07FZ5CogkSiGPvQ20n1F1XFJ46V6h0
# ao6O34JKz0Ahjiu+DbeViXV8E9qmP8a8+DywJf4ttFA81Qptb4YJFI4dOrKPLphK
# fwQqFxVtkkgXfsmEpPlUSISdB4vASIy4zjYP36wPKbwog+4EAAqQPSe22m3Qnlh2
# 1XHtni+z9TpOeQPTtdwx1RdLREKLFpTz09QLFRQRvB9L5r9CvBSI3td4o4noMPVi
# Pt6kTcnKDEz76s+wm6Aemt86vp2Xda4ohgUUyMHAKxlJyCY7AQvjws8kPt2FlVax
# 4EJ93P8/4Y9IfQb0Mf2lFLbvcv9fuhO1q5We1AywUNpvpYXn5IG01ZoDMLBvRxxw
# +f0KFO3iRq6xcI+kFvydR5kYu6EvBiqYlwDNAFDIaS3kNw2TPlSFaNSPwpmY/LVN
# +Hfub5wwJno2lR3wNLQQhYBSlbk5UncdMzzd9gWm/K2mAkpkJvQthAkDgpMVhbo+
# k5Qh6hOmrmLx/wb9dEuzCspD+yi4SqxZHnmcmZAB2WRRFLs0q7Grs9eMMY4TkLkc
# JDAxlX27p+jOqAU=
# SIG # End signature block
