function Update-PesterTest {
    <#
    .SYNOPSIS
        Updates Pester tests to v5 format for dbatools commands.

    .DESCRIPTION
        Updates existing Pester tests to v5 format for dbatools commands. This function processes test files
        and converts them to use the newer Pester v5 parameter validation syntax. It skips files that have
        already been converted or exceed the specified size limit.

    .PARAMETER InputObject
        Array of objects that can be either file paths, FileInfo objects, or command objects (from Get-Command).
        If not specified, will process commands from the dbatools module.

    .PARAMETER First
        Specifies the maximum number of commands to process.

    .PARAMETER Skip
        Specifies the number of commands to skip before processing.

    .PARAMETER PromptFilePath
        The path to the template file containing the prompt structure.
        Defaults to "/workspace/.aider/prompts/template.md".

    .PARAMETER CacheFilePath
        The path to the file containing cached conventions.

    .PARAMETER MaxFileSize
        The maximum size of test files to process, in bytes. Files larger than this will be skipped.
        Defaults to 7.5kb.

    .PARAMETER Model
        The AI model to use (e.g., azure/gpt-4o, gpt-4o-mini, claude-3-5-sonnet).

    .NOTES
        Tags: Testing, Pester
        Author: dbatools team

    .EXAMPLE
        PS C:\> Update-PesterTest
        Updates all eligible Pester tests to v5 format using default parameters.

    .EXAMPLE
        PS C:\> Update-PesterTest -First 10 -Skip 5
        Updates 10 test files starting from the 6th command, skipping the first 5.

    .EXAMPLE
        PS C:\> "C:\tests\Get-DbaDatabase.Tests.ps1", "C:\tests\Get-DbaBackup.Tests.ps1" | Update-PesterTest
        Updates the specified test files to v5 format.

    .EXAMPLE
        PS C:\> Get-Command -Module dbatools -Name "*Database*" | Update-PesterTest
        Updates test files for all commands in dbatools module that match "*Database*".

    .EXAMPLE
        PS C:\> Get-ChildItem ./tests/Add-DbaRegServer.Tests.ps1 | Update-PesterTest -Verbose
        Updates the specific test file from a Get-ChildItem result.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipeline)]
        [PSObject[]]$InputObject,
        [int]$First = 10000,
        [int]$Skip,
        [string[]]$PromptFilePath = "/workspace/.aider/prompts/template.md",
        [string[]]$CacheFilePath = @("/workspace/.aider/prompts/conventions.md","/workspace/private/testing/Get-TestConfig.ps1"),
        [int]$MaxFileSize = 7.5kb,
        [string]$Model
    )
    begin {
        # Full prompt path
        if (-not (Get-Module dbatools.library -ListAvailable)) {
            Write-Warning "dbatools.library not found, installing"
            Install-Module dbatools.library -Scope CurrentUser -Force
        }
        Import-Module /workspace/dbatools.psm1 -Force

        $promptTemplate = Get-Content $PromptFilePath
        $commonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters
        $commandsToProcess = @()
    }

    process {
        if ($InputObject) {
            foreach ($item in $InputObject) {
                Write-Verbose "Processing input object of type: $($item.GetType().FullName)"

                if ($item -is [System.Management.Automation.CommandInfo]) {
                    $commandsToProcess += $item
                } elseif ($item -is [System.IO.FileInfo]) {
                    $path = $item.FullName
                    Write-Verbose "Processing FileInfo path: $path"
                    if (Test-Path $path) {
                        $cmdName = [System.IO.Path]::GetFileNameWithoutExtension($path) -replace '\.Tests$', ''
                        Write-Verbose "Extracted command name: $cmdName"
                        $cmd = Get-Command -Name $cmdName -ErrorAction SilentlyContinue
                        if ($cmd) {
                            $commandsToProcess += $cmd
                        } else {
                            Write-Warning "Could not find command for test file: $path"
                        }
                    }
                } elseif ($item -is [string]) {
                    Write-Verbose "Processing string path: $item"
                    if (Test-Path $item) {
                        $cmdName = [System.IO.Path]::GetFileNameWithoutExtension($item) -replace '\.Tests$', ''
                        Write-Verbose "Extracted command name: $cmdName"
                        $cmd = Get-Command -Name $cmdName -ErrorAction SilentlyContinue
                        if ($cmd) {
                            $commandsToProcess += $cmd
                        } else {
                            Write-Warning "Could not find command for test file: $item"
                        }
                    } else {
                        Write-Warning "File not found: $item"
                    }
                } else {
                    Write-Warning "Unsupported input type: $($item.GetType().FullName)"
                }
            }
        }
    }

    end {
        if (-not $commandsToProcess) {
            Write-Verbose "No input objects provided, getting commands from dbatools module"
            $commandsToProcess = Get-Command -Module dbatools -Type Function, Cmdlet | Select-Object -First $First -Skip $Skip
        }

        foreach ($command in $commandsToProcess) {
            $cmdName = $command.Name
            $filename = "/workspace/tests/$cmdName.Tests.ps1"

            Write-Verbose "Processing command: $cmdName"
            Write-Verbose "Test file path: $filename"

            if (-not (Test-Path $filename)) {
                Write-Warning "No tests found for $cmdName"
                Write-Warning "$filename not found"
                continue
            }

            <# Check if it's already been converted #>
            if (Select-String -Path $filename -Pattern "HaveParameter") {
                Write-Warning "Skipping $cmdName because it's already been converted to Pester v5"
                continue
            }

            # if file is larger than MaxFileSize, skip
            if ((Get-Item $filename).Length -gt $MaxFileSize) {
                Write-Warning "Skipping $cmdName because it's too large"
                continue
            }

            $parameters = $command.Parameters.Values | Where-Object Name -notin $commonParameters
            $cmdPrompt = $promptTemplate -replace "--CMDNAME--", $cmdName
            $cmdPrompt = $cmdPrompt -replace "--PARMZ--", ($parameters.Name -join "`n")
            $cmdprompt = $cmdPrompt -join "`n"

            if ($PSCmdlet.ShouldProcess($filename, "Update Pester test to v5 format and/or style")) {
                $aiderParams = @{
                    Message      = $cmdPrompt
                    File         = $filename
                    YesAlways    = $true
                    NoStream     = $true
                    CachePrompts = $true
                    ReadFile     = $CacheFilePath
                    Model        = $Model
                }

                Write-Verbose "Invoking Aider to update test file"
                Invoke-Aider @aiderParams
            }
        }
    }
}

function Repair-Error {
    <#
    .SYNOPSIS
        Repairs errors in dbatools Pester test files.

    .DESCRIPTION
        Processes and repairs errors found in dbatools Pester test files. This function reads error
        information from a JSON file and attempts to fix the identified issues in the test files.

    .PARAMETER First
        Specifies the maximum number of commands to process.

    .PARAMETER Skip
        Specifies the number of commands to skip before processing.

    .PARAMETER PromptFilePath
        The path to the template file containing the prompt structure.
        Defaults to "/workspace/.aider/prompts/fix-errors.md".

    .PARAMETER CacheFilePath
        The path to the file containing cached conventions.
        Defaults to "/workspace/.aider/prompts/conventions.md".

    .PARAMETER ErrorFilePath
        The path to the JSON file containing error information.
        Defaults to "/workspace/.aider/prompts/errors.json".

    .NOTES
        Tags: Testing, Pester, ErrorHandling
        Author: dbatools team

    .EXAMPLE
        PS C:\> Repair-Error
        Processes and attempts to fix all errors found in the error file using default parameters.

    .EXAMPLE
        PS C:\> Repair-Error -ErrorFilePath "custom-errors.json"
        Processes and repairs errors using a custom error file.
    #>
    [CmdletBinding()]
    param (
        [int]$First = 10000,
        [int]$Skip,
        [string[]]$PromptFilePath = "/workspace/.aider/prompts/fix-errors.md",
        [string[]]$CacheFilePath = "/workspace/.aider/prompts/conventions.md",
        [string]$ErrorFilePath = "/workspace/.aider/prompts/errors.json"
    )

    $promptTemplate = Get-Content $PromptFilePath
    $testerrors = Get-Content $ErrorFilePath | ConvertFrom-Json
    $commands = $testerrors | Select-Object -ExpandProperty Command -Unique | Sort-Object

    foreach ($command in $commands) {
        $filename = "/workspace/tests/$command.Tests.ps1"
        Write-Output "Processing $command"

        if (-not (Test-Path $filename)) {
            Write-Warning "No tests found for $command"
            Write-Warning "$filename not found"
            continue
        }

        $cmdPrompt = $promptTemplate -replace "--CMDNAME--", $command

        $testerr = $testerrors | Where-Object Command -eq $command
        foreach ($err in $testerr) {
            $cmdPrompt += "`n`n"
            $cmdPrompt += "Error: $($err.ErrorMessage)`n"
            $cmdPrompt += "Line: $($err.LineNumber)`n"
        }

        $aiderParams = @{
            Message      = $cmdPrompt
            File         = $filename
            NoStream     = $true
            CachePrompts = $true
            ReadFile     = $CacheFilePath
        }

        Invoke-Aider @aiderParams
    }
}

function Repair-SmallThing {
    [cmdletbinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("FullName", "FilePath", "File")]
        [object[]]$InputObject,
        [int]$First = 10000,
        [int]$Skip,
        [string]$Model = "azure/gpt-4o-mini",
        [string[]]$PromptFilePath,
        [ValidateSet("ReorgParamTest")]
        [string]$Type,
        [string]$EditorModel,
        [switch]$NoPretty,
        [switch]$NoStream,
        [switch]$YesAlways,
        [switch]$CachePrompts,
        [int]$MapTokens,
        [string]$MapRefresh,
        [switch]$NoAutoLint,
        [switch]$AutoTest,
        [switch]$ShowPrompts,
        [string]$EditFormat,
        [string]$MessageFile,
        [string[]]$ReadFile,
        [string]$Encoding
    )

    begin {
        Write-Verbose "Starting Repair-SmallThing"
        $allObjects = @()

        $prompts = @{
            ReorgParamTest = "Move the `$expected` parameter list AND the `$TestConfig.CommonParameters` part into the BeforeAll block, placing them after the `$command` assignment. Keep them within the BeforeAll block. Do not move or modify the initial `$command` assignment.

            If you can't find the `$expected` parameter list, do not make any changes.

            If it's already where it should be, do not make any changes."
        }
        Write-Verbose "Available prompt types: $($prompts.Keys -join ', ')"

        Write-Verbose "Checking for dbatools.library module"
        if (-not (Get-Module dbatools.library -ListAvailable)) {
            Write-Verbose "dbatools.library not found, installing"
            Install-Module dbatools.library -Scope CurrentUser -Force -Verbose:$false
        }
        if (-not (Get-Module dbatools)) {
            Write-Verbose "Importing dbatools module from /workspace/dbatools.psm1"
            Import-Module /workspace/dbatools.psm1 -Force -Verbose:$false
        }

        if ($PromptFilePath) {
            Write-Verbose "Loading prompt template from $PromptFilePath"
            $promptTemplate = Get-Content $PromptFilePath
            Write-Verbose "Prompt template loaded: $promptTemplate"
        }

        $commonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters

        Write-Verbose "Getting base dbatools commands with First: $First, Skip: $Skip"
        $baseCommands = Get-Command -Module dbatools -Type Function, Cmdlet | Select-Object -First $First -Skip $Skip
        Write-Verbose "Found $($baseCommands.Count) base commands"
    }

    process {
        if ($InputObject) {
            Write-Verbose "Adding objects to collection: $($InputObject -join ', ')"
            $allObjects += $InputObject
        }
    }

    end {
        Write-Verbose "Starting end block processing"

        if ($InputObject.Count -eq 0) {
            Write-Verbose "No input objects provided, getting commands from dbatools module"
            $allObjects += Get-Command -Module dbatools -Type Function, Cmdlet | Select-Object -First $First -Skip $Skip
        }

        if (-not $PromptFilePath -and -not $Type) {
            Write-Verbose "Neither PromptFilePath nor Type specified"
            throw "You must specify either PromptFilePath or Type"
        }

        # Process different input types
        $commands = @()
        foreach ($object in $allObjects) {
            switch ($object.GetType().FullName) {
                'System.IO.FileInfo' {
                    Write-Verbose "Processing FileInfo object: $($object.FullName)"
                    $cmdName = [System.IO.Path]::GetFileNameWithoutExtension($object.Name) -replace '\.Tests$', ''
                    $commands += $baseCommands | Where-Object Name -eq $cmdName
                }
                'System.Management.Automation.CommandInfo' {
                    Write-Verbose "Processing CommandInfo object: $($object.Name)"
                    $commands += $object
                }
                'System.String' {
                    Write-Verbose "Processing string path: $object"
                    if (Test-Path $object) {
                        $cmdName = [System.IO.Path]::GetFileNameWithoutExtension($object) -replace '\.Tests$', ''
                        $commands += $baseCommands | Where-Object Name -eq $cmdName
                    } else {
                        Write-Warning "Path not found: $object"
                    }
                }
                'System.Management.Automation.FunctionInfo' {
                    Write-Verbose "Processing FunctionInfo object: $($object.Name)"
                    $commands += $object
                }
                default {
                    Write-Warning "Unsupported input type: $($object.GetType().FullName)"
                }
            }
        }

        Write-Verbose "Processing $($commands.Count) unique commands"
        $commands = $commands | Select-Object -Unique

        foreach ($command in $commands) {
            $cmdName = $command.Name
            Write-Verbose "Processing command: $cmdName"

            $filename = "/workspace/tests/$cmdName.Tests.ps1"
            Write-Verbose "Using test path: $filename"

            if (-not (Test-Path $filename)) {
                Write-Warning "No tests found for $cmdName"
                Write-Warning "$filename not found"
                continue
            }

            # if file is larger than MaxFileSize, skip
            if ((Get-Item $filename).Length -gt 7.5kb) {
                Write-Warning "Skipping $cmdName because it's too large"
                continue
            }

            if ($Type) {
                Write-Verbose "Using predefined prompt for type: $Type"
                $cmdPrompt = $prompts[$Type]
            } else {
                Write-Verbose "Getting parameters for $cmdName"
                $parameters = $command.Parameters.Values | Where-Object Name -notin $commonParameters
                $parameters = $parameters.Name -join ", "
                Write-Verbose "Command parameters: $parameters"

                Write-Verbose "Using template prompt with parameters substitution"
                $cmdPrompt = $promptTemplate -replace "--PARMZ--", $parameters
            }
            Write-Verbose "Final prompt: $cmdPrompt"

            $aiderParams = @{
                Message = $cmdPrompt
                File    = $filename
            }

            $excludedParams = @(
                $commonParameters,
                'InputObject',
                'First',
                'Skip',
                'PromptFilePath',
                'Type'
            )

            $PSBoundParameters.GetEnumerator() |
                Where-Object Key -notin $excludedParams |
                ForEach-Object {
                    $aiderParams[$PSItem.Key] = $PSItem.Value
                }

            if (-not $PSBoundParameters.Model) {
                $aiderParams.Model = $Model
            }

            Write-Verbose "Invoking aider for $cmdName"
            try {
                Invoke-Aider @aiderParams
                Write-Verbose "Aider completed successfully for $cmdName"
            } catch {
                Write-Error "Error executing aider for $cmdName`: $_"
                Write-Verbose "Aider failed for $cmdName with error: $_"
            }
        }
        Write-Verbose "Repair-SmallThing completed"
    }
}

function Invoke-Aider {
    <#
    .SYNOPSIS
        Invokes the aider AI pair programming tool.

    .DESCRIPTION
        The Invoke-Aider function provides a PowerShell interface to the aider AI pair programming tool.
        It supports all aider CLI options and can accept files via pipeline from Get-ChildItem.

    .PARAMETER Message
        The message to send to the AI. This is the primary way to communicate your intent.

    .PARAMETER File
        The files to edit. Can be piped in from Get-ChildItem.

    .PARAMETER Model
        The AI model to use (e.g., gpt-4, claude-3-opus-20240229).

    .PARAMETER EditorModel
        The model to use for editor tasks.

    .PARAMETER NoPretty
        Disable pretty, colorized output.

    .PARAMETER NoStream
        Disable streaming responses.

    .PARAMETER YesAlways
        Always say yes to every confirmation.

    .PARAMETER CachePrompts
        Enable caching of prompts.

    .PARAMETER MapTokens
        Suggested number of tokens to use for repo map.

    .PARAMETER MapRefresh
        Control how often the repo map is refreshed.

    .PARAMETER NoAutoLint
        Disable automatic linting after changes.

    .PARAMETER AutoTest
        Enable automatic testing after changes.

    .PARAMETER ShowPrompts
        Print the system prompts and exit.

    .PARAMETER EditFormat
        Specify what edit format the LLM should use.

    .PARAMETER MessageFile
        Specify a file containing the message to send.

    .PARAMETER ReadFile
        Specify read-only files.

    .PARAMETER Encoding
        Specify the encoding for input and output.

    .EXAMPLE
        Invoke-Aider -Message "Fix the bug" -File script.ps1

        Asks aider to fix a bug in script.ps1.

    .EXAMPLE
        Get-ChildItem *.ps1 | Invoke-Aider -Message "Add error handling"

        Adds error handling to all PowerShell files in the current directory.

    .EXAMPLE
        Invoke-Aider -Message "Update API" -Model gpt-4 -NoStream

        Uses GPT-4 to update API code without streaming output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]]$File,
        [string]$Model,
        [string]$EditorModel,
        [switch]$NoPretty,
        [switch]$NoStream,
        [switch]$YesAlways,
        [switch]$CachePrompts,
        [int]$MapTokens,
        [ValidateSet('auto', 'always', 'files', 'manual')]
        [string]$MapRefresh,
        [switch]$NoAutoLint,
        [switch]$AutoTest,
        [switch]$ShowPrompts,
        [string]$EditFormat,
        [string]$MessageFile,
        [string[]]$ReadFile,
        [ValidateSet('utf-8', 'ascii', 'unicode', 'utf-16', 'utf-32', 'utf-7')]
        [string]$Encoding
    )

    begin {
        $allFiles = @()

        if (-not (Get-Command -Name aider -ErrorAction SilentlyContinue)) {
            throw "Aider executable not found. Please ensure it is installed and in your PATH."
        }
    }

    process {
        if ($File) {
            $allFiles += $File
        }
    }

    end {
        $arguments = @()

        # Add files if any were specified or piped in
        if ($allFiles) {
            $arguments += $allFiles
        }

        # Add mandatory message parameter
        if ($Message) {
            $arguments += "--message", $Message
        }

        # Add optional parameters only if they are present
        if ($Model) {
            $arguments += "--model", $Model
        }

        if ($EditorModel) {
            $arguments += "--editor-model", $EditorModel
        }

        if ($NoPretty) {
            $arguments += "--no-pretty"
        }

        if ($NoStream) {
            $arguments += "--no-stream"
        }

        if ($YesAlways) {
            $arguments += "--yes-always"
        }

        if ($CachePrompts) {
            $arguments += "--cache-prompts"
        }

        if ($PSBoundParameters.ContainsKey('MapTokens')) {
            $arguments += "--map-tokens", $MapTokens
        }

        if ($MapRefresh) {
            $arguments += "--map-refresh", $MapRefresh
        }

        if ($NoAutoLint) {
            $arguments += "--no-auto-lint"
        }

        if ($AutoTest) {
            $arguments += "--auto-test"
        }

        if ($ShowPrompts) {
            $arguments += "--show-prompts"
        }

        if ($EditFormat) {
            $arguments += "--edit-format", $EditFormat
        }

        if ($MessageFile) {
            $arguments += "--message-file", $MessageFile
        }

        if ($ReadFile) {
            foreach ($file in $ReadFile) {
                $arguments += "--read", $file
            }
        }

        if ($Encoding) {
            $arguments += "--encoding", $Encoding
        }

        if ($VerbosePreference -eq 'Continue') {
            Write-Verbose "Executing: aider $($arguments -join ' ')"
        }

        aider @arguments
    }
}

function Repair-Error {
    <#
    .SYNOPSIS
        Repairs errors in dbatools Pester test files.

    .DESCRIPTION
        Processes and repairs errors found in dbatools Pester test files. This function reads error
        information from a JSON file and attempts to fix the identified issues in the test files.

    .PARAMETER First
        Specifies the maximum number of commands to process.

    .PARAMETER Skip
        Specifies the number of commands to skip before processing.

    .PARAMETER PromptFilePath
        The path to the template file containing the prompt structure.
        Defaults to "/workspace/.aider/prompts/fix-errors.md".

    .PARAMETER CacheFilePath
        The path to the file containing cached conventions.
        Defaults to "/workspace/.aider/prompts/conventions.md".

    .PARAMETER ErrorFilePath
        The path to the JSON file containing error information.
        Defaults to "/workspace/.aider/prompts/errors.json".

    .NOTES
        Tags: Testing, Pester, ErrorHandling
        Author: dbatools team

    .EXAMPLE
        PS C:\> Repair-Error
        Processes and attempts to fix all errors found in the error file using default parameters.

    .EXAMPLE
        PS C:\> Repair-Error -ErrorFilePath "custom-errors.json"
        Processes and repairs errors using a custom error file.
    #>
    [CmdletBinding()]
    param (
        [int]$First = 10000,
        [int]$Skip,
        [string[]]$PromptFilePath = "/workspace/.aider/prompts/fix-errors.md",
        [string[]]$CacheFilePath = "/workspace/.aider/prompts/conventions.md",
        [string]$ErrorFilePath = "/workspace/.aider/prompts/errors.json"
    )

    $promptTemplate = Get-Content $PromptFilePath
    $testerrors = Get-Content $ErrorFilePath | ConvertFrom-Json
    $commands = $testerrors | Select-Object -ExpandProperty Command -Unique | Sort-Object

    foreach ($command in $commands) {
        $filename = "/workspace/tests/$command.Tests.ps1"
        Write-Output "Processing $command"

        if (-not (Test-Path $filename)) {
            Write-Warning "No tests found for $command"
            Write-Warning "$filename not found"
            continue
        }

        $cmdPrompt = $promptTemplate -replace "--CMDNAME--", $command

        $testerr = $testerrors | Where-Object Command -eq $command
        foreach ($err in $testerr) {
            $cmdPrompt += "`n`n"
            $cmdPrompt += "Error: $($err.ErrorMessage)`n"
            $cmdPrompt += "Line: $($err.LineNumber)`n"
        }

        $aiderParams = @{
            Message      = $cmdPrompt
            File         = $filename
            NoStream     = $true
            CachePrompts = $true
            ReadFile     = $CacheFilePath
        }

        Invoke-Aider @aiderParams
    }
}
# SIG # Begin signature block
# MIIfqQYJKoZIhvcNAQcCoIIfmjCCH5YCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDDUqAFxAw/Hczk
# 6Q3WkXUQ4JTpzf6kuJ+7/SUKiUmKZ6CCGk4wggNZMIIC36ADAgECAhAPuKdAuRWN
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
# ql4o4rmUMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0B
# AQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVk
# IFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKR
# N6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZz
# lm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1Oco
# LevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH
# 92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRA
# p8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+g
# GkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU
# 8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/
# FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwj
# jVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQ
# EgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUae
# tdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAw
# HQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LS
# cV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYy
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5j
# cmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEB
# CwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftw
# ig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalW
# zxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQm
# h2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScb
# qyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLaf
# zYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbD
# Qc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0K
# XzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm
# 8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9
# gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8a
# pIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBrwwggSk
# oAMCAQICEAuuZrxaun+Vh8b56QTjMwQwDQYJKoZIhvcNAQELBQAwYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0y
# NDA5MjYwMDAwMDBaFw0zNTExMjUyMzU5NTlaMEIxCzAJBgNVBAYTAlVTMREwDwYD
# VQQKEwhEaWdpQ2VydDEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjQw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC+anOf9pUhq5Ywultt5lmj
# tej9kR8YxIg7apnjpcH9CjAgQxK+CMR0Rne/i+utMeV5bUlYYSuuM4vQngvQepVH
# VzNLO9RDnEXvPghCaft0djvKKO+hDu6ObS7rJcXa/UKvNminKQPTv/1+kBPgHGlP
# 28mgmoCw/xi6FG9+Un1h4eN6zh926SxMe6We2r1Z6VFZj75MU/HNmtsgtFjKfITL
# utLWUdAoWle+jYZ49+wxGE1/UXjWfISDmHuI5e/6+NfQrxGFSKx+rDdNMsePW6FL
# rphfYtk/FLihp/feun0eV+pIF496OVh4R1TvjQYpAztJpVIfdNsEvxHofBf1BWka
# dc+Up0Th8EifkEEWdX4rA/FE1Q0rqViTbLVZIqi6viEk3RIySho1XyHLIAOJfXG5
# PEppc3XYeBH7xa6VTZ3rOHNeiYnY+V4j1XbJ+Z9dI8ZhqcaDHOoj5KGg4YuiYx3e
# Ym33aebsyF6eD9MF5IDbPgjvwmnAalNEeJPvIeoGJXaeBQjIK13SlnzODdLtuThA
# LhGtyconcVuPI8AaiCaiJnfdzUcb3dWnqUnjXkRFwLtsVAxFvGqsxUA2Jq/WTjbn
# NjIUzIs3ITVC6VBKAOlb2u29Vwgfta8b2ypi6n2PzP0nVepsFk8nlcuWfyZLzBaZ
# 0MucEdeBiXL+nUOGhCjl+QIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WM
# aiCPnshvMB0GA1UdDgQWBBSfVywDdw4oFZBmpWNe7k+SH3agWzBaBgNVHR8EUzBR
# ME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVk
# RzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsG
# AQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQA9rR4fdplb4ziEEkfZQ5H2EdubTggd0ShPz9Pce4FLJl6reNKLkZd5
# Y/vEIqFWKt4oKcKz7wZmXa5VgW9B76k9NJxUl4JlKwyjUkKhk3aYx7D8vi2mpU1t
# KlY71AYXB8wTLrQeh83pXnWwwsxc1Mt+FWqz57yFq6laICtKjPICYYf/qgxACHTv
# ypGHrC8k1TqCeHk6u4I/VBQC9VK7iSpU5wlWjNlHlFFv/M93748YTeoXU/fFa9hW
# JQkuzG2+B7+bMDvmgF8VlJt1qQcl7YFUMYgZU1WM6nyw23vT6QSgwX5Pq2m0xQ2V
# 6FJHu8z4LXe/371k5QrN9FQBhLLISZi2yemW0P8ZZfx4zvSWzVXpAb9k4Hpvpi6b
# Ue8iK6WonUSV6yPlMwerwJZP/Gtbu3CKldMnn+LmmRTkTXpFIEB06nXZrDwhCGED
# +8RsWQSIXZpuG4WLFQOhtloDRWGoCwwc6ZpPddOFkM2LlTbMcqFSzm4cd0boGhBq
# 7vkqI1uHRz6Fq1IX7TaRQuR+0BGOzISkcqwXu7nMpFu3mgrlgbAW+BzikRVQ3K2Y
# HcGkiKjA4gi4OA/kz1YCsdhIBHXqBzR0/Zd2QwQ/l4Gxftt/8wY3grcc/nS//TVk
# ej9nmUYu83BDtccHHXKibMs/yXHhDXNkoPIdynhVAku7aRZOwqw6pDGCBLEwggSt
# AgEBMHgwZDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTww
# OgYDVQQDEzNEaWdpQ2VydCBHbG9iYWwgRzMgQ29kZSBTaWduaW5nIEVDQyBTSEEz
# ODQgMjAyMSBDQTECEA4d6bA9JNWpeC+CBng09CwwDQYJYIZIAWUDBAIBBQCggYQw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
# IgQg0TDAP6Trs/8mzmpOxiOuPemTZdmoseNtfkB+V6DW2LgwCwYHKoZIzj0CAQUA
# BGcwZQIwC+yHADxF9HBFlNpQBluHI0fegs9YzlD0/Qv9FaMTTGURX1GbDFeWNK8R
# Z0dqeNyxAjEA+p7ZUZQYlOsdZrZhvU3Eece8QRLy/gNsP9hKIKDz53sTt3+SViZj
# pxCkKpLJm7PVoYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# C65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI1MDUwNzEzMDkxM1owLwYJKoZI
# hvcNAQkEMSIEIICofgLjoKMOdIge4MatoIadWowa2cTvo176Va3y2NfAMA0GCSqG
# SIb3DQEBAQUABIICAA9jK1ilhCxyO+C84BW2yilgCvvPiuKFaGNpr8pqZVxrepdl
# pdjNxjmFeVEhLYnvrD7T9JrhNzAbR6whB5oKNsJXyyhYqqRi0n9fMfy7ADgayXdi
# 7plMqa22Q/IFNivxR6tW0N8oDtmWdbp+UiwEtbKmD0lhpNk1xQGPlM6gFTpdOeZV
# CwJXaoOM7E8JtR3R7gvNSuP0N/GfxHnS1xlivVkQInlBFyeIkEj7C1yd2Kk4Tv7X
# E/o57cUYYpTP39ycZdkFJ/e8qmq9JO7/U8wfBm5sBErlhaG8UOFeMZbxifqrokmn
# auJaFxUEkfL0JsIxpk6lWL1k/ofPkTEjSiVHdE+CMilFy/3tdsuz+xeuF8kbdeD7
# uB7O9pR/cuAY3vLVKWy+xum62BwyUSjVXbRhatYI3ndrttfzR4zDARntp4HWdeli
# 9m/Q9Fmc/xZwqHeeZHZfkppIKSy/xqm5exxPtBLRpH2LcKXLGzlEI4FexZ8kLrVy
# yUZZoxohKm3z/1KR/nVHK59mjnft62bxoPCCHj3SCQiXAbqfQQievZWWhiivQ3kI
# rUW7oo+ufueusKUuvpn5EASOCwLz8U51XdEpMSf8Uq1pOKXUvH4nnrLvEXOxvEie
# UWNSri9FKCcuQk5Ptmw266o1mMZxXITaY3IHGzTTFNOUIxeoNNJdEtuKzAW9
# SIG # End signature block
