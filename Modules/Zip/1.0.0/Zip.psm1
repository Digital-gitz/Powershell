# PowerShell 5.1 doesn't have these variables so create them if they don't exist.
if( -not (Get-Variable -Name 'IsLinux' -ErrorAction Ignore) )
{
    $script:IsLinux = $false
    $script:IsMacOS = $false
    $script:IsWindows = $true
}

Add-Type -AssemblyName 'System.IO.Compression'
Add-Type -AssemblyName 'System.IO.Compression.FileSystem'

$functionsDirPath = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'
if (Test-Path -Path $functionsDirPath)
{
    Get-ChildItem -Path $functionsDirPath -Filter '*.ps1' | ForEach-Object { . $_.FullName }
}



function Add-ZipArchiveEntry
{
    <#
    .SYNOPSIS
    Adds files and directories to a ZIP archive.

    .DESCRIPTION
    The `Add-ZipArchiveEntry` function adds files and directories to a ZIP archive. The archive must exist. Use the
    `New-ZipArchive` function to create a new ZIP file. Pipe file or directory objects that you want to add to the
    pipeline. You may also pass paths directly to the `InputObject` parameter (wildcards are **NOT** supported).
    Relative paths are resolved from the current directory. If you pass a directory or path to a directory, the entire
    directory and all its sub-directories/files are added to the archive.

    Files are added to the ZIP archive using their names. They are always added to the root of the archive. For example,
    if you added `C:\Projects\Zip\Zip\Zip.psd1` to an archive, it would get added at `Zip.psd1`.

    Directories are added into a directory in the root of the archive with the source directory's name. For example, if
    you add 'C:\Projects\Zip', all items will be added to the ZIP archive at `Zip`.

    You can change the name an item will have in the archive with the `EntryName` parameter. Path separators are
    allowed, so you can put any item into any directory.

    If you don't want to add an entire directory to the archive, but instead only want a filtered set of files from that
    directory, pipe the filtered list of files to `Add-ZipArchiveEntry` and use the `BasePath` parameter to specify the
    base path of the incoming files. `Add-ZipArchiveEntry` removes the base path from each file and uses the remaining
    path as the file's name in the archive.

    If you want to change an item's parent directory structure in the archive, pass the parent path you want to the
    `EntryParentPath` parameter. For example, if you passed `package` as the `EntryParentPath`, every item added will be
    put in a `package` directory in the archive.

    You can control the compression level of items getting added with the `CompressionLevel` parameter. The default is
    `Optimal`. Other options are `Fastest` (larger files, compresses faster) and `None`.

    If your ZIP archive will be used by tools that don't support UTF8-encoded entry names, pass the encoding to use for
    entry names to the `EntryNameEncoding` parameter. The default is `UTF8`.

    This function uses the native .NET `System.IO.Compression` namespace/classes to do its work.

    .EXAMPLE
    Get-ChildItem 'C:\Projects\Zip' | Add-ZipArchiveEntry -ZipArchivePath 'zip.zip'

    Demonstrates how to pipe the files you want to add to your ZIP into `Add-ZipArchiveEntry`. In this case, all the
    files and directories in the  `C:\Projects\Zip` directory are added to the archive in the root.

    .EXAMPLE
    Get-ChildItem -Path 'C:\Projects\Zip' -Filter '*.ps1' -Recurse | Add-ZipArchiveEntry -ZipArchivePath 'zip.zip' -BasePath 'C:\Projects\Zip'

    This is like the previous example, but instead of adding every file under `C:\Projects\Zip`, we're only adding files
    with a `.ps1` extension. Since we're piping all the files to the `Add-ZipArchiveEntry` function, we need to pass the
    base path of our search to the `BasePath` parameter. Otherwise, every file would get added to the root. Instead, the
    `BasePath` is removed from every file's path and the remaining path is used as the item's path in the archive.

    .EXAMPLE
    Get-Item -Path '.\Zip' | Add-ZipArchiveEntry -ZipArchivePath 'zip.zip' -EntryParentPath 'package'

    Demonstrates how to customize the directory in the ZIP file files will be added at. In this case, all the files
    under the `Zip` directory will be put in a `packages` directory, e.g. `packages\Zip`.

    .EXAMPLE
    Get-ChildItem 'C:\Projects\Zip' | Add-ZipArchiveEntry -ZipArchivePath 'zip.zip' -EntryName 'package\ZipModule'

    Demonstrates how to change the name of an item. In this case, the `C:\Projects\Zip` directory will be added to the
    archive with a path of `package\ZipModule` instead of `Zip`.
    #>
    [CmdletBinding(DefaultParameterSetName='ItemName', SupportsShouldProcess)]
    param(
        # The path to the ZIP file. Files will be added to this ZIP archive.
        [Parameter(Mandatory)]
        [String] $ZipArchivePath,

        # The files/directories to add to the archive. Normally, you would pipe file/directory objects to
        # `Add-ZipArchiveEntry`. You may also pass any object that has a `FullName` or `Path property. You may also pass
        # the path as a string.
        #
        # If you pass a directory object or path to a directory, all files in that directory and all its sub-directories
        # will be added to the archive.
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [Alias('Path')]
        [String[]] $InputObject,

        # When determining a file's path/name in the ZIP archive, the value of this parameter is removed from the
        # beginning of each file's path. Use this parameter if you are piping in a filtered list of files from a
        # directory instead of the directory itself.
        [Parameter(ParameterSetName='BasePath')]
        [String] $BasePath,

        # By default, items are added to the ZIP archive using their name. You can change the name with this parameter.
        # For example, if you added file `Zip.psd1` and passed `NewZip.psd1` as the value to the parameter, the file
        # would get added as `NewZip.psd1`.
        [Parameter(ParameterSetName='ItemName')]
        [ValidatePattern('^[^\\/]')]
        [ValidatePattern('[^\\/]$')]
        [String] $EntryName,

        # A parent path to add to each file in the ZIP archive. If you pass 'package' to this parameter, and you're
        # adding an item named 'file.txt', the file will be added to the archive as `package\file.txt`.
        [ValidatePattern('^[^\\/]')]
        [String] $EntryParentPath,

        # The compression level of the ZIP file. The default is `Optimal`. Pass `Fastest` to compress faster but have a
        # larger file. Pass `None` to not compress at all.
        [IO.Compression.CompressionLevel] $CompressionLevel = [IO.Compression.CompressionLevel]::Optimal,

        # The encoding to use for file names in the ZIP file. The default is UTF8 encoding. You usually only need to
        # change this if your ZIP file will be used by a tool that doesn't handle UTF8 encoding.
        [Text.Encoding] $EntryNameEncoding = [Text.Encoding]::UTF8,

        # By default, if a file already exists in the ZIP file, you'll get an error. Use this switch to replace any existing entries.
        [switch] $Force,

        # Suppress progress messages while adding files to the ZIP archive.
        [switch] $Quiet
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        $directorySeparators = @( [IO.Path]::AltDirectorySeparatorChar, [IO.Path]::DirectorySeparatorChar )
        $directorySeparatorsRegex = $directorySeparators | ForEach-Object { [regex]::Escape($_) }
        $directorySeparatorsRegex = '({0})?' -f ($directorySeparatorsRegex -join '|')

        if( $BasePath )
        {
            $BasePath = $BasePath.TrimEnd($directorySeparators)
            $basePathRegex = '^{0}{1}' -f [regex]::Escape($BasePath),$directorySeparatorsRegex
        }

        $entries = @{}

        # https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.ziparchiveentry.lastwritetime#exceptions
        $ZipEntryLastWriteTime_MinimumValue = [datetime]'1/1/1980 00:00:00'
        $ZipEntryLastWriteTime_MaximumValue = [datetime]'12/31/2107 23:59:59'
    }

    process
    {
        $filePaths =
            $InputObject |
            ForEach-Object {
                $path = Resolve-Path -LiteralPath $_ -ErrorAction Ignore
                if( -not $path )
                {
                    $errorSuffix = ''
                    if( $_ -match '\*|\?|\[.*\]' )
                    {
                        $errorSuffix = ' Wildcard expressions are not supported.'
                    }

                    Write-Error -Message ('Cannot find path "{0}" because it does not exist.{1}' -f $_, $errorSuffix) -ErrorAction $ErrorActionPreference
                    return
                }
                $path | Select-Object -ExpandProperty 'ProviderPath'
            }

        foreach( $filePath in $filePaths )
        {
            if( $BasePath )
            {
                $baseEntryName = $filePath -replace $basePathRegex,''
                if( $baseEntryName -eq $filePath )
                {
                    Write-Error -Message ('Path "{0}" is not in base path "{1}". When using the BasePath parameter, all items passed in must be under that path.' -f $filePath,$BasePath)
                    continue
                }
            }
            else
            {
                $baseEntryName = $filePath | Split-Path -Leaf
                if( $EntryName )
                {
                    $baseEntryName = $EntryName
                }
            }

            $baseEntryName = $baseEntryName.TrimStart($directorySeparators)

            if( $EntryParentPath )
            {
                $baseEntryName = Join-Path -Path $EntryParentPath -ChildPath $baseEntryName
            }

            $baseEntryName = $baseEntryName -replace '\\','/'

            # Add the file.
            if( (Test-Path -LiteralPath $filePath -PathType Leaf) )
            {
                $entries[$baseEntryName] = $filePath
                continue
            }

            # Now, handle directories
            $dirEntryBasePathRegex = '^{0}{1}' -f [regex]::Escape($filePath),$directorySeparatorsRegex
            foreach( $filePath in (Get-ChildItem -LiteralPath $filePath -Recurse -File | Select-Object -ExpandProperty 'FullName') )
            {
                $fileEntryName = $filePath -replace $dirEntryBasePathRegex,''
                if( $baseEntryName )
                {
                    $fileEntryName = Join-Path -Path $baseEntryName -ChildPath $fileEntryName
                }
                $fileEntryName = $fileEntryName -replace '\\','/'
                $entries[$fileEntryName] = $filePath
            }
        }
    }

    end
    {
        $activity = 'Compressing files into ZIP archive {0}' -f $ZipArchivePath
        $writeProgress = [Environment]::UserInteractive -and -not $Quiet
        if( $writeProgress )
        {
            Write-Progress -Activity $activity
        }

        $op = "compress $($entries.Count) file"
        if ($entries.Count -gt 1)
        {
            $op = "${op}s"
        }
        $shouldProcess = $PSCmdlet.ShouldProcess($ZipArchivePath, $op)

        $bufferSize = 4kb
        [byte[]]$buffer = New-Object 'byte[]' ($bufferSize)
        [IO.Compression.ZipArchive]$zipFile = $null;

        if ($shouldProcess)
        {
            $zipFile =
                [IO.Compression.ZipFile]::Open($ZipArchivePath, [IO.Compression.ZipArchiveMode]::Update, $EntryNameEncoding)
        }

        $timer = New-Object 'Timers.Timer' 100
        $timer |
            Add-Member -Name 'ProcessedCount' -Value 0 -MemberType NoteProperty -PassThru |
            Add-Member -MemberType NoteProperty -Name 'Activity' -Value $activity -PassThru |
            Add-Member -MemberType NoteProperty -Name 'FilePath' -Value '' -PassThru|
            Add-Member -MemberType NoteProperty -Name 'EntryName' -Value '' -PassThru |
            Add-Member -MemberType NoteProperty -Name 'TotalCount' -Value $entries.Count

        if( $writeProgress )
        {
            # Write-Progress is *expensive*. Only do it if the user is interactive and only every 1/10th of a second.
            Register-ObjectEvent -InputObject $timer -EventName 'Elapsed' -Action {
                param(
                    $Timer,
                    $TimerEventArgs
                )
                Write-Progress -Activity $Timer.Activity -Status $Timer.FilePath -CurrentOperation $Timer.EntryName -PercentComplete (($Timer.ProcessedCount/$Timer.TotalCount) * 100)
            } | Out-Null
            $timer.Enabled = $true
            $timer.Start()
        }

        try
        {
            foreach( $entryName in $entries.Keys )
            {
                $timer.FilePath = $filePath = $entries[$entryName]
                $timer.ProcessedCount += 1
                $timer.EntryName = $entryName

                Write-Debug -Message ('{0} -> {1}' -f $FilePath,$EntryName)
                $entry = $null
                if ($zipFile)
                {
                    $entry = $zipFile.GetEntry($EntryName)
                }

                if( $entry )
                {
                    if ($Force)
                    {
                        if ($shouldProcess)
                        {
                            $entry.Delete()
                        }
                    }
                    else
                    {
                        Write-Error -Message ('Unable to add file "{0}" to ZIP archive "{1}": the archive already has a file named "{2}".' -f $FilePath,$ZipArchivePath,$EntryName)
                        continue
                    }
                }

                if (-not $shouldProcess)
                {
                    continue
                }

                $entry = $zipFile.CreateEntry($EntryName,$CompressionLevel)
                $fileLastWriteTime = (Get-Item -LiteralPath $filePath).LastWriteTime

                if( $fileLastWriteTime -lt $ZipEntryLastWriteTime_MinimumValue )
                {
                    $entry.LastWriteTime = $ZipEntryLastWriteTime_MinimumValue
                }
                elseif( $fileLastWriteTime -gt $ZipEntryLastWriteTime_MaximumValue )
                {
                    $entry.LastWriteTime = $ZipEntryLastWriteTime_MaximumValue
                }
                else
                {
                    $entry.LastWriteTime = $fileLastWriteTime
                }

                $stream = $entry.Open()
                try
                {
                    $writer = New-Object 'IO.BinaryWriter' ($stream)
                    try
                    {
                        [Array]::Clear($buffer,0,$bufferSize)
                        $fileReader = New-Object 'IO.FileStream' ($filePath,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read,$bufferSize,[IO.FileOptions]::SequentialScan)
                        try
                        {
                            while( $true )
                            {
                                [int]$bytesRead = $fileReader.Read($buffer, 0, $bufferSize)
                                if( -not $bytesRead )
                                {
                                    break
                                }
                                $writer.Write($buffer,0,$bytesRead)
                            }
                        }
                        finally
                        {
                            $fileReader.Close()
                            $fileREader.Dispose()
                        }
                    }
                    finally
                    {
                        $writer.Close()
                        $writer.Dispose()
                    }
                }
                finally
                {
                    $stream.Close()
                    $stream.Dispose()
                }
            }
        }
        finally
        {
            $timer.Stop()
            $timer.Dispose()
            if ($zipFile)
            {
                $zipFile.Dispose()
            }
            if( $writeProgress )
            {
                Write-Progress -Activity $activity -Status 'Writing File' -PercentComplete 99
                Write-Progress -Activity $activity -Completed
            }
        }
    }
}



function New-ZipArchive
{
    <#
    .SYNOPSIS
    Creates a new, empty ZIP archive.

    .DESCRIPTION
    The `New-ZipArchive` function createa a new, empty ZIP archive. Pass the path to the archive to the Path parameter.
    A new, empty ZIP archive is created at that path. The function returns a `IO.FileInfo` object representing the new
    ZIP archive.

    If `Path` is relative, it is created relative to the current directory.

    If a file already exists, you'll get an error and nothing will be returned. To delete any existing file and create a
    new, empty ZIP archive, pass the `Force` switch.

    You can control the compression level of the archive by passing an `IO.Compression.CompressionLevel` value to the
    `CompressionLevel` parameter. The default is `Optimal`. Other values are `Fastest` and `None`.

    By default, entry names are encoded as UTF8 text. If your ZIP archive will be consumed by tools that don't support
    UTF8, pass the encoding they do support to the `EntryNameEncoding` parameter.

    .EXAMPLE
    New-ZipArchive -Path 'archive.zip'

    Creates a new, empty ZIP file named `archive.zip` in the current directory.

    .EXAMPLE
    New-ZipArchive -Path 'archive.zip' -Force

    Creates a new, empty ZIP file named `archive.zip` in the current directory. If a file named 'archive.zip' already
    exists in the current directory, it is deleted and a new file created.

    .EXAMPLE
    New-ZipArchive -Path 'archive.zip' -CompressionLevel Fastest -Encoding [Text.Encoding]::ASCII

    Creates a new, empty ZIP file using fastest compression and encoding entry names in ASCII.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The path to the ZIP archive to create. Should include the file name. The file must not exist.
        [Parameter(Mandatory)]
        [String] $Path,

        [IO.Compression.CompressionLevel] $CompressionLevel = [IO.Compression.CompressionLevel]::Optimal,

        [Text.Encoding] $EntryNameEncoding = [Text.Encoding]::UTF8,

        # If the ZIP file already exists, delete it and create a new file.
        [switch] $Force
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if( -not [IO.Path]::IsPathRooted($Path) )
    {
        $Path = Join-Path -Path (Get-Location) -ChildPath $Path
    }
    $Path = [IO.Path]::GetFullPath($Path)

    if( (Test-Path -LiteralPath $Path) )
    {
        if( (Test-Path -LiteralPath $Path -PathType Container) )
        {
            Write-Error -Message ('Path "{0}" is a directory. Unable to create a ZIP archive there.' -f $Path)
            return
        }

        if( $Force )
        {
            Remove-Item -LiteralPath $Path
        }
        else
        {
            Write-Error -Message ('The file "{0}" already exists. Unable to create a new ZIP archive at that path.' -f $Path)
            return
        }
    }

    $tempDir = "$($Path | Split-Path -Leaf).$([IO.Path]::GetRandomFileName())"
    $tempDir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath $tempDir
    New-Item -Path $tempDir -ItemType 'Directory' | Out-Null
    try
    {
        if ($PSCmdlet.ShouldProcess($Path, 'create ZIP archive'))
        {
            [IO.Compression.ZipFile]::CreateFromDirectory($tempDir,$Path,$CompressionLevel,$false,$EntryNameEncoding)
            Get-Item -LiteralPath $Path
        }
    }
    finally
    {
        if (Test-Path -Path $tempDir)
        {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction Ignore
        }
    }
}


# Copyright 2012 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Use-CallerPreference
{
    <#
    .SYNOPSIS
    Sets the PowerShell preference variables in a module's function based on the callers preferences.

    .DESCRIPTION
    Script module functions do not automatically inherit their caller's variables, including preferences set by common parameters. This means if you call a script with switches like `-Verbose` or `-WhatIf`, those that parameter don't get passed into any function that belongs to a module. 

    When used in a module function, `Use-CallerPreference` will grab the value of these common parameters used by the function's caller:

     * ErrorAction
     * Debug
     * Confirm
     * InformationAction
     * Verbose
     * WarningAction
     * WhatIf
    
    This function should be used in a module's function to grab the caller's preference variables so the caller doesn't have to explicitly pass common parameters to the module function.

    This function is adapted from the [`Get-CallerPreference` function written by David Wyatt](https://gallery.technet.microsoft.com/scriptcenter/Inherit-Preference-82343b9d).

    There is currently a [bug in PowerShell](https://connect.microsoft.com/PowerShell/Feedback/Details/763621) that causes an error when `ErrorAction` is implicitly set to `Ignore`. If you use this function, you'll need to add explicit `-ErrorAction $ErrorActionPreference` to every function/cmdlet call in your function. Please vote up this issue so it can get fixed.

    .LINK
    about_Preference_Variables

    .LINK
    about_CommonParameters

    .LINK
    https://gallery.technet.microsoft.com/scriptcenter/Inherit-Preference-82343b9d

    .LINK
    http://powershell.org/wp/2014/01/13/getting-your-script-module-functions-to-inherit-preference-variables-from-the-caller/

    .EXAMPLE
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Demonstrates how to set the caller's common parameter preference variables in a module function.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        #[Management.Automation.PSScriptCmdlet]
        # The module function's `$PSCmdlet` object. Requires the function be decorated with the `[CmdletBinding()]` attribute.
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [Management.Automation.SessionState]
        # The module function's `$ExecutionContext.SessionState` object.  Requires the function be decorated with the `[CmdletBinding()]` attribute. 
        #
        # Used to set variables in its callers' scope, even if that caller is in a different script module.
        $SessionState
    )

    Set-StrictMode -Version 'Latest'

    # List of preference variables taken from the about_Preference_Variables and their common parameter name (taken from about_CommonParameters).
    $commonPreferences = @{
                              'ErrorActionPreference' = 'ErrorAction';
                              'DebugPreference' = 'Debug';
                              'ConfirmPreference' = 'Confirm';
                              'InformationPreference' = 'InformationAction';
                              'VerbosePreference' = 'Verbose';
                              'WarningPreference' = 'WarningAction';
                              'WhatIfPreference' = 'WhatIf';
                          }

    foreach( $prefName in $commonPreferences.Keys )
    {
        $parameterName = $commonPreferences[$prefName]

        # Don't do anything if the parameter was passed in.
        if( $Cmdlet.MyInvocation.BoundParameters.ContainsKey($parameterName) )
        {
            continue
        }

        $variable = $Cmdlet.SessionState.PSVariable.Get($prefName)
        # Don't do anything if caller didn't use a common parameter.
        if( -not $variable )
        {
            continue
        }

        if( $SessionState -eq $ExecutionContext.SessionState )
        {
            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
        }
        else
        {
            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
        }
    }

}