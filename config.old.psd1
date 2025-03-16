@{
    # Core Configuration
    CoreSettings = @{
        DefaultEditor = 'code'
        DefaultBrowser = (Get-ItemProperty HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice).ProgId
        DefaultTerminal = 'wt'
        ThemeName = "minimal"
        EnableLogging = $true
        CacheEnabled = $true
        AsyncLoading = $true
        DefaultShell = "pwsh"
        LogPath = Join-Path $PSScriptRoot 'Logs'
        BackupPath = Join-Path $PSScriptRoot 'Backups'
        UpdateCheckInterval = 7 # days
    }

    # Required modules with categories
    RequiredModules = @{
        Shell = @(
            @{Name = 'PSReadLine'; Purpose = 'Enhanced command line editing'},
            @{Name = 'Terminal-Icons'; Purpose = 'File and folder icons'},
            @{Name = 'z'; Purpose = 'Directory jumping'},
            @{Name = 'lolcat'; Purpose = 'Powershell port of the lolcat'}
        )
        Development = @(
            @{Name = 'posh-git'; Purpose = 'Git integration'},
            @{Name = 'GitIgnores'; Purpose = 'Git ignore templates'},
            # @{Name = 'PSScriptAnalyzer'; Purpose = 'Script linting and analysis'},
            @{Name = 'Pester'; Purpose = 'Testing framework'}
        )
        Cloud = @(
            # @{Name = 'AWS.Tools.Common'; Purpose = 'AWS CLI integration'},
            # @{Name = 'Az'; Purpose = 'Azure PowerShell'},
            @{Name = 'GoogleCloud'; Purpose = 'Google Cloud Platform tools'}
        )
        DataManagement = @(
            @{Name = 'ImportExcel'; Purpose = 'Excel manipulation'},
            @{Name = 'dbatools'; Purpose = 'SQL Server management'}
            # @{Name = 'PSMongoDB'; Purpose = 'MongoDB tools'}
        )
        Security = @(
            @{Name = 'PSPGP'; Purpose = 'PGP functionality in PowerShell'},
            @{Name = 'SecretManagement'; Purpose = 'Secure secret storage'},
            @{Name = 'PSWSMan'; Purpose = 'WS-Management security'}
        )
        PackageManagement = @(
            @{Name = 'PackageManagement'; Purpose = 'Package management'},
            @{Name = 'PowerShellGet'; Purpose = 'PowerShell module management'},
            @{Name = 'Chocolatey'; Purpose = 'Windows package manager'}
        )
    }

    # Common paths configuration with expanded locations
    CommonPaths = @{
        Home = [Environment]::GetFolderPath('UserProfile')
        Documents = [Environment]::GetFolderPath('MyDocuments')
        Desktop = [Environment]::GetFolderPath('Desktop')
        Downloads = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Downloads'
        Pictures = [Environment]::GetFolderPath('MyPictures')
        PowerShell = $PSScriptRoot
        Scripts = Join-Path $PSScriptRoot 'Scripts'
        Modules = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
        Logs = Join-Path $PSScriptRoot 'Logs'
        Backups = Join-Path $PSScriptRoot 'Backups'
        Projects = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Projects'
        Work = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Work'
        Temp = [System.IO.Path]::GetTempPath()
        GitHub = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'GitHub'
    }
      # Expanded CustomScripts with categories
      CustomScripts = @{
        Development = @(
            @{
                Name = 'Install-OrUpdateModule.ps1'
                Purpose = 'Install or update module functions'
                Path = Join-Path $PSScriptRoot 'Scripts\Development\Install-OrUpdateModule.ps1'
            }
            @{Name = 'GitHub.ps1'; Purpose = 'GitHub integration functions'},
            @{Name = 'DevEnvironmentSetup.ps1'; Purpose = 'Development environment setup'}
        )
        System = @(
            @{
                Name = 'SystemInfo.ps1'
                Purpose = 'System information functions'
                Path = Join-Path $PSScriptRoot 'Scripts\System\SystemInfo.ps1'
            }
            @{Name = 'NetworkTools.ps1'; Purpose = 'Network diagnostics'},
            @{Name = 'Security.ps1'; Purpose = 'Security utilities'},
            @{Name = 'winfetch-pro.ps1'; Purpose = 'System information utility'}
        )
        Utilities = @(
            @{Name = 'Navigation.ps1'; Purpose = 'Navigation functions'},
            @{Name = 'FileManagement.ps1'; Purpose = 'File management utilities'},
            @{Name = 'Backup.ps1'; Purpose = 'Automated backup utilities'},
            @{Name = 'UtilityFunctions.aiUpdate.ps1'; Purpose = 'General utility functions'}
        )
        Media = @(
            @{Name = 'PNGtoVECTOR.ps1'; Purpose = 'PNG conversion utilities'},
            @{Name = 'MediaProcessing.ps1'; Purpose = 'Media file processing'},
            @{Name = 'ImageOptimization.ps1'; Purpose = 'Image optimization tools'}
        )
    }

    # Winget packages organized by category
    WingetPackages = @{
        # Shell and Terminal
        ShellAndTerminal = @(
            @{ Id = "JanDeDobbeleer.OhMyPosh" },
            @{ Id = "Microsoft.PowerShell" },
            @{ Id = "Microsoft.WindowsTerminal" },
            @{ Id = "Zeit.Hyper" },
            @{ Id = "Nushell.Nushell" },
            @{ Id = "wez.wezterm" }, # New: Modern terminal
            @{ Id = "AlacrittyOrg.Alacritty" } # New: GPU-accelerated terminal
        )
        # Development Tools
        DevelopmentTools = @(
            @{ Id = "Microsoft.VisualStudioCode" },
            @{ Id = "Neovim.Neovim" },
            @{ Id = "vim.vim" },
            @{ Id = "GitHub.cli" },
            @{ Id = "Microsoft.Git" },
            @{ Id = "Docker.DockerDesktop" },
            @{ Id = "Microsoft.NuGet" },
            @{ Id = "Insomnia.Insomnia" },
            @{ Id = "Postman.Postman" }, # New: API testing
            @{ Id = "Microsoft.PowerToys" },
            @{ Id = "zyedidia.micro" },
            @{ Id = "JetBrains.Toolbox" }, # New: JetBrains IDE manager
            @{ Id = "AdoptOpenJDK.OpenJDK.16" } # New: Java Development Kit
        )
        # Programming Languages
        ProgrammingLanguages = @(
            @{ Id = "Python.Python.3.12"; Scope = "machine" },
            @{ Id = "GoLang.Go" },
            @{ Id = "OpenJS.NodeJS.LTS"; Scope = "machine" },
            @{ Id = "Rustlang.Rustup" },
            @{ Id = "Microsoft.DotNet.SDK.7" }, # New: .NET SDK
            @{ Id = "Anaconda.Miniconda3" },
            @{ Id = "PHP.PHP.8.2" } # New: PHP runtime
        )
        # Productivity
        Productivity = @(
            @{ Id = "Obsidian.Obsidian" },
            @{ Id = "Notion.Notion" }, # New: All-in-one workspace
            @{ Id = "Anysphere.Cursor" },
            @{ Id = "voidtools.Everything" },
            @{ Id = "Figma.Figma" },
            @{ Id = "Figma.FigmaAgent" },
            @{ Id = "7zip.7zip" },
            @{ Id = "SumatraPDF.SumatraPDF" },
            @{ Id = "RevoUninstaller.RevoUninstaller" },
            @{ Id = "File-New-Project.EarTrumpet" }, # New: Volume control
            @{ Id = "Lexikos.AutoHotkey" } # New: Automation tool
        )
        # Creative Tools
        CreativeTools = @(
            @{ Id = "Inkscape.Inkscape" },
            @{ Id = "BlenderFoundation.Blender" },
            @{ Id = "GIMP.GIMP" }, # New: Image editor
            @{ Id = "Audacity.Audacity" } # New: Audio editor
        )
        # System Utilities
        SystemUtilities = @(
            @{ Id = "9PCKT2B7DZMW" }, # TranslucentTB
            @{ Id = "Rufus.Rufus" },
            @{ Id = "KeePassXCTeam.KeePassXC" },
            @{ Id = "GNU.Wget2" },
            @{ Id = "hpjansson.Chafa" },
            @{ Id = "WinDirStat.WinDirStat" }, # New: Disk usage analyzer
            @{ Id = "Microsoft.Sysinternals.ProcessExplorer" }, # New: Advanced task manager
            @{ Id = "CrystalRich.LockHunter" } # New: File unlocker
        )
        # Media
        Media = @(
            @{ Id = "mpvnet.mpvnet" },
            @{ Id = "VideoLAN.VLC" } # New: Media player
        )
        # Gaming
        Gaming = @(
            @{ Id = "Valve.Steam" },
            @{ Id = "Valve.SteamCMD" },
            @{ Id = "Odamex.Odamex" },
            @{ Id = "GodotEngine.GodotEngine" },
            @{ Id = "SteelSeries.GG" },
            @{ Id = "EpicGames.EpicGamesLauncher" } # New: Epic Games
        )
        # Communication
        Communication = @(
            @{ Id = "Discord.Discord" }, # New: Communication platform
            @{ Id = "SlackTechnologies.Slack" }, # New: Team communication
            @{ Id = "Microsoft.Teams" } # New: Microsoft Teams
        )
        # Browsers
        Browsers = @(
            @{ Id = "Microsoft.Edge" },
            @{ Id = "Google.Chrome" },
            @{ Id = "Mozilla.Firefox" }
        )
        # Other
        Other = @(
            @{ Id = "Reddit.Reddit" },
            @{ Id = "achannarasappa.ticker" },
            @{ Id = "Elgato.StreamDeck" }
        )
        # Downloading
        Downloading = @(
            @{ Id = "qBittorrent.qBittorrent" }
        )
        # Database
        Database = @(
            @{ Id = "Oracle.MySQL" }
        )
    }
    
    # Expanded URL collections with better organization
    UrlCollections = @{
        # AI & LLM Resources
        AI = @{
            LLM = @(
                "https://chatgpt.com/",
                "https://chat.openai.com/",
                "https://www.eleuther.ai/",
                "https://claude.ai/new",
                "https://gemini.google.com/app?hl=en-GB", 
                "https://chat.deepseek.com/",
                "https://x.com/i/grok",
                "https://pi.ai/" # New: Pi assistant
            )
            AiPackages = @(
                "https://huggingface.co/",
                "https://www.tensorflow.org/",
                "https://pytorch.org/", # New: PyTorch
                "https://keras.io/", # New: Keras
                "https://www.deeplearning.ai/" # New: Learning resources
            )
            AiSearch = @(
                "https://www.perplexity.ai/",
                "https://www.phind.com/",
                "https://kagi.com/", # New: AI-powered search
                "https://www.consensus.app/" # New: Scientific search
            )
        }

        # Google Services - Reorganized into categories
        Google = @{
            Core = @(
                "https://www.google.com/",
                "https://myaccount.google.com/"
            )
            Productivity = @(
                "https://www.google.com/drive",
                "https://www.google.com/calendar",
                "https://www.google.com/gmail",
                "https://www.google.com/docs",
                "https://www.google.com/sheets",
                "https://www.google.com/slides",
                "https://www.google.com/forms",
                "https://www.google.com/keep"
            )
            Communication = @(
                "https://www.google.com/meet",
                "https://www.google.com/contacts"
            )
            Media = @(
                "https://www.google.com/photos",
                "https://www.google.com/youtube"
            )
            Tools = @(
                "https://www.google.com/maps",
                "https://www.google.com/translate",
                "https://www.google.com/earth"
            )
            Business = @(
                "https://www.google.com/ads",
                "https://www.google.com/analytics",
                "https://www.google.com/adsense",
                "https://www.google.com/webmasters"
            )
            Other = @(
                "https://www.google.com/news",
                "https://www.google.com/alerts",
                "https://www.google.com/books",
                "https://www.google.com/flights",
                "https://www.google.com/shopping",
                "https://www.google.com/finance"
            )
        }

        # Developer Resources
        Development = @{
            Documentation = @(
                "https://devdocs.io/", # New: Combined API documentation
                "https://docs.microsoft.com/en-us/powershell/",
                "https://developer.mozilla.org/",
                "https://kubernetes.io/docs/",
                "https://docs.aws.amazon.com/"
            )
            GitSites = @(
                "https://github.com/",
                "https://gitlab.com/",
                "https://bitbucket.org/", # New: Bitbucket
                "https://github.com/Digital-gitz" # Your account
            )
            LearnWebDev = @(
                "https://www.w3schools.com/",
                "https://www.codecademy.com/",
                "https://www.freecodecamp.org/",
                "https://developer.mozilla.org/", # New: MDN Web Docs
                "https://frontendmasters.com/" # New: Frontend Masters
            )
            Javascript = @(
                "https://lynxjs.org/",
                "https://www.pluralsight.com/",
                "https://javascript.info/", # New: Modern JavaScript Tutorial
                "https://reactjs.org/", # New: React documentation
                "https://vuejs.org/" # New: Vue documentation
            )
            Css = @(
                "https://www.w3schools.com/css/",
                "https://developer.mozilla.org/en-US/docs/Web/CSS",
                "https://css-tricks.com/",
                "https://www.sitepoint.com/css-tutorials/",
                "https://www.tutorialspoint.com/css/index.htm",
                "https://www.codecademy.com/learn/learn-css",
                "https://www.freecodecamp.org/learn/responsive-web-design/basic-css/",
                "https://tailwindcss.com/", # New: Tailwind CSS
                "https://sass-lang.com/" # New: SASS
            )
            PackageManagers = @(
                "https://pypi.org/",
                "https://www.nuget.org/",
                "https://www.npmjs.com/", # New: NPM
                "https://crates.io/", # New: Rust crates
                "https://packagist.org/" # New: PHP Composer
            )
            CloudSites = @(
                "https://portal.azure.com/",
                "https://aws.amazon.com/console/",
                "https://console.cloud.google.com/", # New: Google Cloud Console
                "https://cloud.digitalocean.com/" # New: DigitalOcean
            )
            macro = @(
                "https://www.arduino.cc/",
                "https://www.raspberrypi.org/",
                "https://www.adafruit.com/",
                "https://www.sparkfun.com/",
                "https://www.seeedstudio.com/" # New: Seeed Studio
                "https://www.clipboardfusion.com/Macros/" # New: Seeed Studio
            )
        }
        
        # Finance & Investing
        Finance = @{
            StockSites = @(
                "https://www.reddit.com/r/stocks/",
                "https://www.webull.com/center",
                "https://www.tradingview.com/", 
                "https://robinhood.com/",
                "https://robinhood.com/legend",
                "https://stockanalysis.com/stocks/",
                "https://finviz.com/", # New: Stock screener
                "https://www.morningstar.com/", # New: Investment research
                "https://seekingalpha.com/", # New: Stock analysis
                "https://www.fool.com/", # New: Investment advice
                "https://www.zacks.com/", # New: Stock research
                "https://www.tipranks.com/" # New: Stock analyst ratings
            )
            Trading = @(
                "https://tradingterminal.com/",
                "https://finviz.com/",
                "https://www.biopharmcatalyst.com/",
                "https://www.marketwatch.com/", # New: Market news
                "https://www.benzinga.com/", # New: Market news
                "https://www.investing.com/", # New: Market data
                "https://www.thinkorswim.com/", # New: TD Ameritrade platform
                "https://www.etrade.com/", # New: E*TRADE platform
                "https://www.interactivebrokers.com/", # New: Interactive Brokers
                "https://www.moomoo.com/" # New: Moomoo trading
            )
            StockTickers = @(
                "https://www.babypips.com/tools/forex-market-hours",
                "https://www.marketwatch.com/tools/quotes/lookup.asp", # New: Symbol lookup
                "https://finance.yahoo.com/lookup", # New: Yahoo Finance lookup
                "https://www.nasdaq.com/market-activity/stocks", # New: NASDAQ lookup
                "https://www.nyse.com/listings_directory/stock" # New: NYSE lookup
            )
            Forex = @(
                "https://www.babypips.com/tools/forex-market-hours",
                "https://www.forex.com/", # New: Forex trading
                "https://www.myfxbook.com/", # New: Forex community
                "https://www.fxcm.com/", # New: Forex Capital Markets
                "https://www.oanda.com/", # New: OANDA trading
                "https://www.ig.com/", # New: IG trading
                "https://www.forexfactory.com/" # New: Forex news/calendar
            )
            Crypto = @(
                "https://coinmarketcap.com/", # New: Crypto market cap
                "https://www.coingecko.com/", # New: Crypto prices
                "https://www.binance.com/", # New: Cryptocurrency exchange
                "https://www.kraken.com/", # New: Crypto exchange
                "https://www.gemini.com/", # New: Crypto exchange
                "https://www.coinbase.com/", # New: Crypto exchange
                "https://www.kucoin.com/", # New: Crypto exchange
                "https://www.bitfinex.com/", # New: Crypto exchange
                "https://www.bybit.com/", # New: Crypto derivatives
                "https://www.tradingview.com/crypto-screener/", # New: Crypto screener
                "https://www.cryptopanic.com/", # New: Crypto news aggregator
                "https://www.lunarcrush.com/", # New: Crypto social analytics
                "https://www.blockchain.com/", # New: Blockchain explorer
                "https://etherscan.io/", # New: Ethereum explorer
                "https://defillama.com/" # New: DeFi analytics
            )
            Banking = @(
                "https://www.td.com/us/en/personal-banking/my-td",
                "https://www.soa.com/relay/app/spending/transaction-history",
                "https://onlinebanking.tdbank.com/",
                "https://app.acorns.com/settings/my-subscription",
                "https://www.ally.com/", # New: Online banking
                "https://www.chime.com/", # New: Digital banking
                "https://www.marcus.com/" # New: Goldman Sachs banking
            )
            Wallets = @(
                "edge://wallet/",
                "https://www.nerdwallet.com/",
                "https://metamask.io/", # New: Crypto wallet
                "https://trustwallet.com/", # New: Multi-chain wallet
                "https://phantom.app/", # New: Solana wallet
                "https://www.ledger.com/", # New: Hardware wallet
                "https://trezor.io/" # New: Hardware wallet
            )
            CreditCards = @(
                "https://www.creditkarma.com/",
                "https://www.experian.com/",
                "https://www.equifax.com/",
                "https://www.transunion.com/",
                "https://www.annualcreditreport.com/",
                "https://www.myfico.com/",
                "https://www.capitalone.com/",
                # "https://www.americanexpress.com/", 
                # "https://www.discover.com/",
                # "https://www.chase.com/", # New: Chase credit cards
                "https://concoracredit.myfinanceservice.com/summary", # New: HomeDepot credit card
                "https://www.citi.com/", # New: Citi credit cards
                # "https://www.bankofamerica.com/credit-cards/", # New: Bank of America cards
                # "https://www.wellsfargo.com/credit-cards/", # New: Wells Fargo cards
                # "https://www.usbank.com/credit-cards/", # New: US Bank cards
                "https://www.nerdwallet.com/credit-cards", # New: Credit card comparison
                "https://www.cardratings.com/", # New: Credit card reviews
                "https://www.creditcards.com/" # New: Credit card marketplace
            )
            RealEstate = @( # New section
                "https://www.zillow.com/",
                "https://www.realtor.com/",
                "https://www.redfin.com/",
                "https://www.trulia.com/",
                "https://www.loopnet.com/" # Commercial real estate
            )
            Insurance = @( # New section
                "https://www.progressive.com/",
                "https://www.geico.com/",
                "https://www.statefarm.com/",
                "https://www.allstate.com/",
                "https://www.libertymutual.com/"
            )
            Retirement = @( # New section
                "https://www.fidelity.com/",
                "https://www.vanguard.com/",
                "https://www.schwab.com/",
                "https://www.troweprice.com/",
                "https://www.principal.com/"
            )
        }
        
        # News & Media
        News = @{
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
                "https://www.vice.com/"
            )
            TechNews = @(
                "https://daily.dev/",
                "https://www.techradar.com/",
                "https://www.theverge.com/",
                "https://www.wired.com/",
                "https://techcrunch.com/",
                "https://www.engadget.com/",
                "https://www.cnet.com/",
                "https://www.digitaltrends.com/",
                "https://www.tomsguide.com/",
                "https://www.pcmag.com/",
                "https://arstechnica.com/", # New: Ars Technica
                "https://slashdot.org/" # New: Slashdot
            )
            Music = @(
                "https://www.spotify.com/us/",
                "https://www.youtube.com/",
                "https://soundcloud.com/",
                "https://music.apple.com/", # New: Apple Music
                "https://tidal.com/" # New: Tidal
            )
        }
        # Art & Design
        Art = @{
        ArtReff = @(
            "https://www.artstation.com/",
            "https://www.deviantart.com/",
            "https://www.pinterest.com/",
            "https://www.behance.net/", 
            "https://www.art.com/", # New: Art prints
            "https://www.cgtrader.com/", # New: 3D models
            "https://sketchfab.com/", # New: 3D models
            "https://www.turbosquid.com/", # New: 3D models
            "https://www.shutterstock.com/", # New: Stock photos
            "https://unsplash.com/", # New: Free photos
            "https://www.pexels.com/", # New: Free photos
            "https://www.pixiv.net/", # New: Anime/manga art
            "https://www.artsy.net/", # New: Fine art marketplace
            "https://www.saatchiart.com/" # New: Original artwork
        )
    }
        # Social Media
        Social = @{
            Professional = @(
                "https://www.linkedin.com/"
            )
            Personal = @(
                "https://x.com/home",
                "https://www.facebook.com/",
                "https://www.instagram.com/",
                "https://www.threads.net/"
            )
            Content = @(
                "https://www.reddit.com/",
                "https://www.tumblr.com/dashboard",
                "https://www.pinterest.com/"
            )
            Community = @(
                "https://disboard.org/search"
            )
    }        
        # Learning
        Learning = @{
            Platforms = @(
                "https://learn.microsoft.com/",
                "https://www.pluralsight.com/",
                "https://www.udemy.com/", # New: Udemy
                "https://www.coursera.org/", # New: Coursera
                "https://www.edx.org/" # New: edX
            )
            Documentation = @(
                "https://docs.microsoft.com/en-us/powershell/",
                "https://learn.microsoft.com/en-us/windows/",
                "https://docs.python.org/", # New: Python docs
                "https://docs.docker.com/" # New: Docker docs
            )
        }
        
        # Utilities
        Utilities = @{
            Drawing = @(
                "https://excalidraw.com/", # New: Excalidraw 
                "https://www.figma.com/", # New: Figma
                "https://www.drawio.com/" # New: Draw.io
            )
            Loans = @(
                "https://www.td.com/us/en/personal-banking/personal-loan/about-td-fit-loan",
                "https://www.bankrate.com/loans/personal-loans/" # New: Loan comparisons
            )
            Energy = @(
                "https://www.greennetworkenergy.net/",
                "https://clayelectric.com/"
            )
        }
    }

    # PSReadLine configuration with consistent formatting
    PSReadLine = @{
        ShowToolTips = $true
        PredictionSource = 'HistoryAndPlugin'
        PredictionViewStyle = "ListView"
        EditMode = 'Windows'
        HistorySearchCursorMovesToEnd = $true
        MaximumHistoryCount = 10000
        HistoryNoDuplicates = $true
        Colors = @{
            Command = 'Cyan'
            Parameter = 'DarkCyan'
            Operator = 'Yellow'
            Variable = 'Magenta'
            String = 'DarkGreen'
            Comment = 'DarkGray'
            Error = 'Red'
            Selection = 'DarkBlue'
            Keyword = 'DarkYellow'
            Member = 'DarkMagenta'
        }
        KeyBindings = @{
            'Ctrl+Spacebar' = 'MenuComplete'
            'Ctrl+A' = 'BeginningOfLine'
            'Ctrl+E' = 'EndOfLine'
            'Ctrl+R' = 'ReverseSearchHistory'
            'Ctrl+Alt+R' = 'HistorySearchBackward'
            'Ctrl+S' = 'ForwardSearchHistory'
            'Ctrl+D' = 'DeleteChar'
            'Ctrl+K' = 'KillLine'
            'Ctrl+U' = 'BackwardKillLine'
            'Ctrl+W' = 'BackwardKillWord'
            'Ctrl+Y' = 'Yank'
            'Ctrl+Z' = 'Undo'
        }
    }

    # Environment Variables
    EnvironmentVariables = @{
        EDITOR = 'code'
        BROWSER = 'chrome'
    }

    # Aliases with consistent formatting
    Aliases = @{
        ll = 'Get-ChildItem'
        gs = 'git status'
    }

    # Profile Script
    ProfileScript = @{
        Path = '$PROFILE'
        Purpose = 'PowerShell profile configuration'
    }

    OhMyPosh = @{
        EnableCache = $true
        Theme = "minimal"
        AsyncLoad = $true
        UpdateCheck = $true
        SegmentsToDisable = @(
            "git_status"
            "node"
        )
        CustomSegments = @{
            time = @{
                style = "plain"
                format = "[$time]"
            }
            battery = @{
                display_charging = $true
                display_percentage = $true
            }
            cloud = @{
                display_env = $true
                display_profile = $true
            }
        }
        Colors = @{
            primary = "#FF479C"
            secondary = "#FF9640"
            accent = "#00897b"
        }
    }

    # New: Performance Optimization Settings
    Performance = @{
        InitialMemoryLimit = 2GB
        MaxMemoryLimit = 4GB
        ThreadLimit = 16
        GarbageCollection = @{
            Aggressive = $false
            Interval = 300 # seconds
        }
        ModuleAutoLoading = $true
        ProfileOptimization = $true
    }

    # Add new section for Terminal Integration
    TerminalIntegration = @{
        WindowsTerminal = @{
            ConfigPath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
            DefaultProfile = 'PowerShell'
            ColorScheme = 'One Half Dark'
            FontFace = 'CaskaydiaCove NF'
            FontSize = 12
            UseAcrylic = $true
            AcrylicOpacity = 0.8
        }
    }

    # Add new section for Git Configuration
    GitConfiguration = @{
        DefaultBranch = 'main'
        User = @{
            Name = $env:USERNAME
            Email = ''  # Fill in your email
        }
        Core = @{
            Editor = 'code --wait'
            AutoCRLF = 'true'
            Safecrlf = 'warn'
        }
        Aliases = @{
            st = 'status'
            co = 'checkout'
            br = 'branch'
            ci = 'commit'
            df = 'diff'
            lg = 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
        }
    }

    # Add new section for Security Settings
    SecuritySettings = @{
        ExecutionPolicy = 'RemoteSigned'
        TLS = @{
            DefaultVersion = 'Tls12'
            EnableStrongCrypto = $true
        }
        Proxy = @{
            Enabled = $false
            Address = ''
            Credentials = $null
        }
        Logging = @{
            EnableScriptBlockLogging = $true
            EnableTranscription = $true
            TranscriptionPath = Join-Path $PSScriptRoot 'Logs\Transcripts'
        }
    }
}