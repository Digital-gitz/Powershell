@{
    # Common paths configuration
    CommonPaths = @{
        PowerShell = '$PSScriptRoot'  # Will be evaluated later
        Scripts = '$PSScriptRoot\Scripts'  # Will be evaluated later
        Documents = '$([Environment]::GetFolderPath("MyDocuments"))'  # Will be evaluated later
    }

    # URL collections for various functions
    UrlCollections = @{
        AI = @{
            LLM = @(
                "https://chat.openai.com",
                "https://bard.google.com",
                "https://bing.com/chat"
            )
            AiPackages = @(
                "https://huggingface.co",
                "https://pytorch.org",
                "https://tensorflow.org"
            )
            AiSearch = @(
                "https://you.com",
                "https://perplexity.ai",
                "https://phind.com"
            )
        }
        Development = @{
            Documentation = @(
                "https://learn.microsoft.com",
                "https://docs.github.com",
                "https://developer.mozilla.org"
            )
        }
        Google = @{
            Core = @(
                "https://google.com",
                "https://gmail.com",
                "https://calendar.google.com"
            )
            Productivity = @(
                "https://docs.google.com",
                "https://drive.google.com",
                "https://sheets.google.com"
            )
            Media = @(
                "https://youtube.com",
                "https://photos.google.com"
            )
            Business = @(
                "https://workspace.google.com",
                "https://analytics.google.com"
            )
        }
    }

    # Required PowerShell modules
    RequiredModules = @(
        @{
            Name = "PSReadLine"
            Purpose = "Enhanced command line editing"
        }
        @{
            Name = "Terminal-Icons"
            Purpose = "Add file and folder icons to terminal"
        }
    )

    # PSReadLine configuration
    PSReadLine = @{
        ShowToolTips = $true
        PredictionSource = "History"
        PredictionViewStyle = "ListView"
        EditMode = "Windows"
    }

    # Winget package configuration
    WingetPackages = @(
        @{
            Id = "Microsoft.PowerShell"
            Scope = "machine"
        }
        @{
            Id = "Microsoft.VisualStudioCode"
            Scope = "user"
        }
        @{
            Id = "Git.Git"
            Scope = "machine"
        }
    )
}