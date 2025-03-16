@{
    # Common paths configuration
    CommonPaths = @{
        PowerShell = '$PSScriptRoot'  # Will be evaluated later
        Scripts = '$PSScriptRoot\Scripts'  # Will be evaluated later
        Documents = '$([Environment]::GetFolderPath("MyDocuments"))'  # Will be evaluated later
    }


    
    # URL collections for various functions
    UrlCollections = @{
        #region AI
        AI = @{
            LLM = @{
                Dashboard = @(
                    "https://platform.deepseek.com/",
                    "https://localai.io/"
                )
                Chat = @(
                    "https://chat.openai.com/",
                    "https://claude.ai/new",
                    "https://x.com/i/grok",
                    "https://you.com/",
                    "https://pi.ai/",
                    "https://chatgpt.com/",
                    "https://chat.openai.com/",
                    "https://claude.ai/new",
                    "https://gemini.google.com/app?hl=en-GB",
                    "https://chat.deepseek.com/"
                )
                deepseek = @(
                    "https://chat.deepseek.com/"
                    "https://platform.deepseek.com/"
                    "https://deepseekcoder.github.io/",
                    "https://api-docs.deepseek.com/api/deepseek-api/"
                    )
                Resources = @(
                    "https://www.openai.com/api/introduction/", # OpenAI API docs
                    "https://www.eleuther.ai/", # Open source LLM research
                    "https://chatgpt.com/" # ChatGPT community
                )
                aiDocs = @(
                    "https://www.deepseek.com/docs/overview",
                    "https://ai.google.dev/gemini-api/docs/openai"
                    
                )
            }
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
            AiArt = @(
                "https://anything.world/"
            )
            Azure = @(
                "https://portal.azure.com/"
                "https://learn.microsoft.com/en-us/azure/"
                "https://learn.microsoft.com/en-us/azure/openai/"
                "https://learn.microsoft.com/en-us/azure/cognitive-services/"
            )   
        }
        #endregion AI
        #region Google Services
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
            Blogs = @(
                "https://www.google.com/blog",
                "https://www.google.com/blog",
                "https://www.google.com/blog",
                "https://www.google.com/blog"
            )
            Cloud = @(
                "https://www.google.com/cloud",
                "https://www.google.com/cloud-storage",
                "https://www.google.com/cloud-storage",
                "https://www.google.com/cloud-storage"
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
        #endregion Google Services
        #region Developer Resources
        Development = @{
            Documentation = @(
                "https://devdocs.io/", # New: Combined API documentation
                "https://docs.microsoft.com/en-us/powershell/",
                "https://developer.mozilla.org/",
                "https://kubernetes.io/docs/",
                "https://docs.cursor.com/get-started/welcome",
                "https://docs.aws.amazon.com/",
                "https://tpo.pages.torproject.net/core/arti/guides/compiling-arti"
            )
            VersionControl = @(
                "https://github.com/",
                "https://gitlab.com/",
                "https://bitbucket.org/"
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
            CloudStorage = @(
                "https://www.dropbox.com/",
                "https://www.google.com/drive",
                "https://www.microsoft.com/en-us/microsoft-365/onedrive/online-cloud-storage",
                "https://www.pcloud.com/",
                "https://www.mega.nz/",
                "https://www.icloud.com/"
            )

            macro = @(
                "https://www.arduino.cc/",
                "https://www.raspberrypi.org/",
                "https://www.adafruit.com/",
                "https://www.sparkfun.com/",
                "https://www.seeedstudio.com/" # New: Seeed Studio
                "https://www.clipboardfusion.com/Macros/" # New: Seeed Studio
            )
            plugins = @(
                "https://www.powershellgallery.com/",
                "https://github.com/microsoft/PowerToys/blob/main/doc/thirdPartyRunPlugins.md"
            )
        }
        #endregion Developer Resources
        #region Finance & Investing
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
            CryptoNews = @(
                "https://www.cryptopotato.com/" # New: Crypto news
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
        #endregion Finance & Investing
        #region News & Media
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
        #endregion News & Media
        #region Art & Design
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
        #endregion Art & Design
        #region Social Media
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
        #endregion Social Media
        #region Learning
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
        #endregion Learning
        #region Utilities
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
        Search = @(
            "https://www.google.com/",
            "https://www.bing.com/",
            "https://www.yahoo.com/",
            "https://www.duckduckgo.com/"
        )
        Other = @(
            "https://github.com/ChrisTitusTech/winutil"
        )
        #endregion Utilities
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