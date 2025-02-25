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
        @{Name = 'PowerShellGet'; Purpose = 'PowerShell module management'}
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
        @{Name = 'FileManagement.ps1'; Purpose = 'File management utilities'}
    )

    # URL collections
    UrlCollections = @{
        AiSites = @(
            "https://chatgpt.com/",
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
    }

    # PSReadLine configuration
    PSReadLine = @{
        ShowToolTips = $true
        PredictionSource = 'History'
        PredictionViewStyle = 'ListView'
        EditMode = 'Windows'
    }
}