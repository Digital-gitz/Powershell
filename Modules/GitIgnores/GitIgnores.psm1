#requires -version 3

function Get-GitIgnore {
    <#
    .SYNOPSIS
        Displays a list of supported .gitignore templates or retrieves the content of a specific template.
    .DESCRIPTION
        This command downloads the list of supported .gitignore templates from GitHub or retrieves the content of a specific template.
    .LINK
        https://github.com/dotCypress/ps-git-ignores
    .EXAMPLE
        Get-GitIgnore
        Lists all available .gitignore templates.
    .EXAMPLE
        Get-GitIgnore -Template Python
        Retrieves the content of the Python .gitignore template.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, HelpMessage = "The name of the template to retrieve.")]
        [string] $Template
    )

    try {
        $webClient = New-Object Net.WebClient
        $webClient.Headers['User-Agent'] = 'PowerShell/3.0'

        if ($Template) {
            $url = "https://api.github.com/gitignore/templates/$Template"
            $response = $webClient.DownloadString($url) | ConvertFrom-Json
            $response.source
        } else {
            if (-not $global:gitIgnoreTemplates) {
                $url = "https://api.github.com/gitignore/templates"
                $global:gitIgnoreTemplates = $webClient.DownloadString($url) | ConvertFrom-Json
            }
            $global:gitIgnoreTemplates
        }
    } catch [System.Net.WebException] {
        Write-Error "Failed to retrieve data from GitHub. Please check your internet connection or the template name."
    } catch {
        Write-Error "An unexpected error occurred: $_"
    }
}

function Add-GitIgnore {
    <#
    .SYNOPSIS
        Creates a .gitignore file in the current directory using a specified template.
    .DESCRIPTION
        This command downloads the content of a specified .gitignore template from GitHub and writes it to a .gitignore file in the current directory.
    .LINK
        https://github.com/dotCypress/ps-git-ignores
    .EXAMPLE
        Add-GitIgnore -Template Python
        Creates a .gitignore file for Python in the current directory.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "The name of the template to use.")]
        [ValidateNotNullOrEmpty()]
        [string] $Template
    )

    try {
        $content = Get-GitIgnore -Template $Template
        if ($content) {
            $filePath = Join-Path -Path (Get-Location) -ChildPath ".gitignore"
            Out-File -FilePath $filePath -Encoding UTF8 -InputObject $content -NoClobber
            Write-Host "Created .gitignore file for '$Template' at '$filePath'."
        } else {
            Write-Error "No content found for template '$Template'."
        }
    } catch {
        Write-Error "Failed to create .gitignore file: $_"
    }
}

# Register tab expansion if PowerTab module is available
if (Get-Module PowerTab) {
    $EventHandler = {
        param($Context, [ref]$TabExpansionHasOutput)
        $Argument = $Context.Argument
        switch -exact ($Context.Parameter) {
            'Template' {
                $TabExpansionHasOutput.Value = $true
                Get-GitIgnore | Where-Object { $_ -like "$Argument*" }
            }
        }
    }.GetNewClosure()

    Register-TabExpansion "Get-GitIgnore" $EventHandler -Type "Command"
    Register-TabExpansion "Add-GitIgnore" $EventHandler -Type "Command"
}

Export-ModuleMember -Function Get-GitIgnore, Add-GitIgnore