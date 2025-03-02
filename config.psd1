@{
    # Required modules with their purposes
    RequiredModules = @(
        @{Name = 'PSReadLine'; Purpose = 'Enhanced command line editing'},
        @{Name = 'posh-git'; Purpose = 'Git integration'},
        @{Name = 'GitIgnores'; Purpose = 'Git ignore templates'},
        @{Name = 'Terminal-Icons'; Purpose = 'File and folder icons'},
        @{Name = 'z'; Purpose = 'Directory jumping'},
        @{Name = 'AWS.Tools.Common'; Purpose = 'AWS CLI integration'},
        @{Name = 'ImportExcel'; Purpose = 'Excel manipulation'},
        @{Name = 'PackageManagement'; Purpose = 'Package management'},
        @{Name = 'PSFzf'; Purpose = 'Fuzzy finder'},
        @{Name = 'PowerShellGet'; Purpose = 'PowerShell module management'},
        @{Name = 'PSScriptAnalyzer'; Purpose = 'Script linting and analysis'},
        @{Name = 'dbatools'; Purpose = 'SQL Server management'},
        @{Name = 'Pester'; Purpose = 'Testing framework'},
        @{Name = 'PSPGP'; Purpose = ' PGP functionality in PowerShell'}
        )   
    # Common paths configuration
    CommonPaths = @{
        Home      = '$HOME'
        Documents = '$HOME\Documents'
        Desktop   = '$HOME\Desktop'
        Downloads = '$HOME\Downloads'
        Pictures  = '$HOME\Pictures'
        PowerShell = '$HOME\Documents\PowerShell'
        GitHub    = '$HOME\GitHub'
        Scripts   = '$HOME\Documents\PowerShell\Scripts'
    }

      # Custom scripts to load
      CustomScripts = @(
        @{Name = 'Install-OrUpdateModule.ps1'; Purpose = 'Install or update module functions'},
        @{Name = 'Navigation.ps1'; Purpose = 'Navigation functions'},
        @{Name = 'GitHub.ps1'; Purpose = 'GitHub integration functions'},
        @{Name = 'PNGtoVECTOR.ps1'; Purpose = 'PNG conversion utilities'},
        @{Name = 'UtilityFunctions.aiUpdate.ps1'; Purpose = 'General utility functions'},
        @{Name = 'SystemInfo.ps1'; Purpose = 'System information functions'},
        @{Name = 'FileManagement.ps1'; Purpose = 'File management utilities'},
        @{ Name = "WingetManager.ps1"; Purpose = "Manage software packages with Winget" },
        @{Name = 'Backup.ps1'; Purpose = 'Automated backup utilities'},
        @{Name = 'NetworkTools.ps1'; Purpose = 'Network diagnostics'},
        @{Name = 'Security.ps1'; Purpose = 'Security utilities'}
        )

    #Winget Packages
    WingetPackages = @(
        @{ Id = "IronmanSoftware.PowerShellUniversal" },
        @{ Id = "JanDeDobbeleer.OhMyPosh" },
        @{ Id = "9PCKT2B7DZMW" }, # TranslucentTB (using Microsoft Store ID)
        @{ Id = "Microsoft.PowerShell" },
        @{ Id = "Microsoft.WindowsTerminal" },
        @{ Id = "Microsoft.DirectX" },
        @{ Id = "Python.Python.3.12"; Scope = "machine" },
        @{ Id = "Rufus.Rufus" },
        @{ Id = "RevoUninstaller.RevoUninstaller" },
        @{ Id = "Anysphere.Cursor" },
        @{ Id = "voidtools.Everything" },
        @{ Id = "KeePassXCTeam.KeePassXC" },
        @{ Id = "Apple.iCloud" },
        @{ Id = "Inkscape.Inkscape" },
        @{ Id = "Microsoft.PowerToys" },
        @{ Id = "mpvnet.mpvnet" },
        @{ Id = "Elgato.StreamDeck" },
        @{ Id = "Reddit.Reddit" },
        @{ Id = "BlenderFoundation.Blender" },
        @{ Id = "Valve.Steam" },
        @{ Id = "Valve.SteamCMD" },
        @{ Id = "Zeit.Hyper" },
        @{ Id = "GoLang.Go" },
        @{ Id = "OpenJS.NodeJS.LTS"; Scope = "machine" },
        @{ Id = "Rustlang.Rustup" },
        @{ Id = "Odamex.Odamex" },
        @{ Id = "GodotEngine.GodotEngine" },
        @{ Id = "GNU.Wget2" },
        @{ Id = "Neovim.Neovim" },
        @{ Id = "SumatraPDF.SumatraPDF" },
        @{ Id = "SteelSeries.GG" },
        @{ Id = "Anaconda.Miniconda3" },
        @{ Id = "Nushell.Nushell" },
        @{ Id = "GitHub.cli" },
        @{ Id = "Microsoft.Git" },
        @{ Id = "vim.vim" },
        @{ Id = "hpjansson.Chafa" },
        @{ Id = "achannarasappa.ticker" },
        @{ Id = "Figma.Figma" },
        @{ Id = "Figma.FigmaAgent" },
        @{ Id = "Insomnia.Insomnia" },
        @{ Id = "7zip.7zip" },
        @{ Id = "Microsoft.VisualStudioCode" },
        @{ Id = "Docker.DockerDesktop" }
    )

    # URL collections need to include to Collection Function line 174 in profile.ps1
    UrlCollections = @{
        AiSites = @(
            "https://chatgpt.com/",
            "https://chat.openai.com/",
            "https://www.eleuther.ai/",
            "https://claude.ai/new",
            "https://gemini.google.com/app?hl=en-GB", 
            "https://chat.deepseek.com/",
            "https://x.com/i/grok"
        )
        SocialSites = @(
            "https://x.com/home",
            "https://www.reddit.com/",
            "https://www.tumblr.com/dashboard", 
            "https://www.facebook.com/",
            "https://www.instagram.com/",
            "https://www.threads.net/",
            "https://disboard.org/search"
        )
        StockSites = @(
            "https://www.reddit.com/r/stocks/",
            "https://www.webull.com/center",
            "https://www.tradingview.com/", 
            "https://robinhood.com/",
            "https://robinhood.com/legend"
        )
        LearningSites = @(
            "https://learn.microsoft.com/",
            "https://www.pluralsight.com/"
        )
        GitSites = @(
            "https://github.com/",
            "https://gitlab.com/"
        )
        CloudSites = @(
            "https://portal.azure.com/",
            "https://aws.amazon.com/console/"
        )
        LearnWebDev = @(
            "https://www.w3schools.com/",
            "https://www.codecademy.com/",
            "https://www.freecodecamp.org/"
        )
        NewsSites = @(
            "https://www.bbc.co.uk/news",
            "https://www.aljazeera.com/",
            "https://www.reuters.com/",
            "https://www.bloomberg.com/",
            "https://www.ft.com/",
            "https://www.economist.com/",
            "https://www.theguardian.com/",
            "https://www.independent.co.uk/",
            "https://www.telegraph.co.uk/",
            "https://www.nytimes.com/",
            "https://www.washingtonpost.com/",
            "https://www.wsj.com/",
            "https://www.npr.org/",
            "https://www.buzzfeed.com/",
            "https://www.huffpost.com/",
            "https://www.vice.com/",
            "https://www.bbc.co.uk/news",
            "https://www.aljazeera.com/",
            "https://www.reuters.com/",
            "https://www.bloomberg.com/",
            "https://www.ft.com/"
            )
            Css = @(
                "https://www.w3schools.com/css/",
                "https://developer.mozilla.org/en-US/docs/Web/CSS",
                "https://css-tricks.com/",
                "https://www.sitepoint.com/css-tutorials/",
                "https://www.tutorialspoint.com/css/index.htm",
                "https://www.codecademy.com/learn/learn-css",
                "https://www.freecodecamp.org/learn/responsive-web-design/basic-css/"
                ""
                )
    }

    # PSReadLine configuration
    PSReadLine = @{
        ShowToolTips = $true
        PredictionSource = 'History'
        PredictionViewStyle = "InlineView" # Options: InlineView, ListView
        EditMode = 'Windows'
        Colors = @{
            Command = 'Green'
            Parameter = 'Cyan'
            Operator = 'Yellow'
        }
        KeyBindings = @{
            'Ctrl+Spacebar' = 'MenuComplete'
            'Ctrl+A' = 'BeginningOfLine'
            'Ctrl+E' = 'EndOfLine'
        }
    }

    # Environment Variables
    EnvironmentVariables = @{
        EDITOR = 'code'
        BROWSER = 'chrome'
    }

    # Aliases
    Aliases = @{
        ll = 'Get-ChildItem'
        gs = 'git status'
    }

    # Profile Script
    ProfileScript = @{
        Path = '$PROFILE'
        Purpose = 'PowerShell profile configuration'
    }
}