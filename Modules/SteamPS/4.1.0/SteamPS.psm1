#Region '.\Enum\Enum.ps1' 0
enum ServerType {
    Dedicated = 0x64    #d
    NonDedicated = 0x6C #l
    SourceTV = 0x70     #p
}
enum OSType {
    Linux = 108   #l
    Windows = 119 #w
    Mac = 109     #m
    MacOsX = 111  #o
}
enum VAC {
    Unsecured = 0
    Secured = 1
}
enum Visibility {
    Public = 0
    Private = 1
}

enum PersonaState {
    Offline = 0
    Online = 1
    Busy = 2
    Away = 3
    Snooze = 4
    LookingToTrade = 5
}
enum CommunityVisibilityState {
    Private = 1
    FriendsOnly = 2
    Public = 3
}

if ($PSVersionTable.PSVersion.Major -le 5 -and $PSVersionTable.PSVersion.Minor -le 1) {
    Write-Warning -Message "The support for Windows PowerShell (v5) will be deprecated in the next major version of SteamPS. Please ensure your system supports PowerShell 7."
}
#EndRegion '.\Enum\Enum.ps1' 38
#Region '.\Private\API\Get-SteamAPIKey.ps1' 0
function Get-SteamAPIKey {
    <#
    .SYNOPSIS
    Grabs API key secure string from file and converts back to plaintext.

    .DESCRIPTION
    Grabs API key secure string from file and converts back to plaintext.

    .EXAMPLE
    Get-SteamAPIKey

    Returns the API key secure string in plain text.

    .NOTES
    Author: sysgoblin (https://github.com/sysgoblin) and Frederik Hjorslev Poulsen
    #>

    [CmdletBinding()]
    Param (
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        $SteamPSKey = Test-Path -Path "$env:AppData\SteamPS\SteamPSKey.json"
        if (-not $SteamPSKey) {
            $Exception = [Exception]::new("Steam Web API configuration file not found in '$env:AppData\SteamPS\SteamPSKey.json'. Run Connect-SteamAPI to configure an API key.")
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'SteamAPIKeyNotFound',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $SteamPSKey # usually the object that triggered the error, if possible
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }
        # cmdlet terminates here, no need for an `else`, only possible way to be here is
        # if previous condition was false
        try {
            $Config = Get-Content "$env:AppData\SteamPS\SteamPSKey.json"
            $APIKeySecString = $Config | ConvertTo-SecureString
            [System.Net.NetworkCredential]::new('', $APIKeySecString).Password
        } catch {
            $Exception = [Exception]::new("Could not decrypt API key from configuration file not found in '$env:AppData\SteamPS\SteamPSKey.json'. Run Connect-SteamAPI to configure an API key.")
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'InvalidAPIKey',
                [System.Management.Automation.ErrorCategory]::ParserError,
                $APIKey # usually the object that triggered the error, if possible
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
} # Cmdlet
#EndRegion '.\Private\API\Get-SteamAPIKey.ps1' 60
#Region '.\Private\Server\Add-EnvPath.ps1' 0
function Add-EnvPath {
    <#
    .LINK
    https://gist.github.com/mkropat/c1226e0cc2ca941b23a9
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string]$Container = 'Session'
    )

    process {
        Write-Verbose -Message "Container is set to: $Container"
        $Path = $Path.Trim()

        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
            Session = [EnvironmentVariableTarget]::Process
        }

        $containerType = $containerMapping[$Container]
        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType).
            Split([System.IO.Path]::PathSeparator).Trim() -ne ''

        if ($persistedPaths -notcontains $Path) {
            # previous step with `Trim()` + `-ne ''` already takes care of empty tokens,
            # no need to filter again here
            $persistedPaths = ($persistedPaths + $Path) -join [System.IO.Path]::PathSeparator
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths, $containerType)

            Write-Verbose -Message "Adding $Path to environment path."
        } else {
            Write-Verbose -Message "$Path is already located in env:Path."
        }
    } # Process
} # Cmdlet
#EndRegion '.\Private\Server\Add-EnvPath.ps1' 42
#Region '.\Private\Server\Get-PacketString.ps1' 0
function Get-PacketString {
    <#
    .SYNOPSIS
    Get a string in a byte stream.

    .DESCRIPTION
    Get a string in a byte stream.

    .PARAMETER Stream
    Accepts BinaryReader.

    .EXAMPLE
    Get-PacketString -Stream $Stream

    Assumes that you already have a byte stream. See more detailed usage in
    Get-SteamServerInfo.

    .NOTES
    Author: Jordan Borean and Chris Dent
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.BinaryReader]$Stream
    )

    process {
        # Check if the stream has any bytes available
        if ($Stream.BaseStream.Length -gt 0) {
            # Find the end of the string, terminated with \0 and convert that byte range to a string.
            $stringBytes = while ($true) {
                $byte = $Stream.ReadByte()
                if ($byte -eq 0) {
                    break
                }
                $byte
            }
        }

        if ($stringBytes.Count -gt 0) {
            [System.Text.Encoding]::UTF8.GetString($stringBytes)
        }
    } # Process
} # Cmdlet
#EndRegion '.\Private\Server\Get-PacketString.ps1' 46
#Region '.\Private\Server\Get-SteamPath.ps1' 0
function Get-SteamPath {
    [CmdletBinding()]
    param (
    )

    process {
        $SteamCMDPath = $env:Path.Split([System.IO.Path]::PathSeparator) |
            Where-Object -FilterScript { $_ -like '*SteamCMD*' }

        if ($null -ne $SteamCMDPath) {
            [PSCustomObject]@{
                'Path'       = $SteamCMDPath
                'Executable' = "$SteamCMDPath\steamcmd.exe"
            }
        } else {
            Write-Verbose -Message 'SteamCMD where not found on the environment path.'
        }
    } # Process
} # Cmdlet
#EndRegion '.\Private\Server\Get-SteamPath.ps1' 20
#Region '.\Private\Server\Test-Admin.ps1' 0
function Test-Admin {
    <#
    .SYNOPSIS
    Checks whether the current user has administrator privileges.

    .DESCRIPTION
    This cmdlet verifies if the current user has administrator privileges on the system.

    .EXAMPLE
    PS C:\> Test-Admin
    True
    This example checks if the current user has administrator privileges and returns True if they do.

    .NOTES
    Author: Marius Storhaug <https://github.com/PSModule/Admin>
    #>

    [OutputType([System.Boolean])]
    [CmdletBinding()]
    [Alias('Test-Administrator', 'IsAdmin', 'IsAdministrator')]
    param (
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        $IsUnix = $PSVersionTable.Platform -eq 'Unix'
        if ($IsUnix) {
            Write-Verbose -Message "Running on Unix, checking if user is root."
            $whoAmI = $(whoami)
            Write-Verbose -Message "whoami: $whoAmI"
            $IsRoot = $whoAmI -eq 'root'
            Write-Verbose -Message "IsRoot: $IsRoot"
            $IsRoot
        } else {
            Write-Verbose -Message "Running on Windows, checking if user is an Administrator."
            $User = [Security.Principal.WindowsIdentity]::GetCurrent()
            $Principal = New-Object Security.Principal.WindowsPrincipal($User)
            $isAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            Write-Verbose -Message "IsAdmin: $isAdmin"
            $isAdmin
        }
    }

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
}
#EndRegion '.\Private\Server\Test-Admin.ps1' 51
#Region '.\Public\API\Connect-SteamAPI.ps1' 0
function Connect-SteamAPI {
    <#
    .SYNOPSIS
    Create or update the Steam Web API config file.

    .DESCRIPTION
    Create or update the Steam Web API config file which contains the API key
    used to authenticate to those Steam Web API's that require authentication.

    .EXAMPLE
    Connect-SteamAPI

    Prompts the user for a Steam Web API key and sets the specified input within
    the config file.

    .INPUTS
    None. You cannot pipe objects to Connect-SteamAPI.

    .OUTPUTS
    None. Nothing is returned when calling Connect-SteamAPI.

    .NOTES
    Author: sysgoblin (https://github.com/sysgoblin) and Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Connect-SteamAPI.html
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        if (-not (Test-Path -Path "$env:AppData\SteamPS\SteamPSKey.json")) {
            try {
                $TargetObject = New-Item -Path "$env:AppData\SteamPS\SteamPSKey.json" -Force
                Write-Verbose -Message "Created config file at $env:AppData\SteamPS\SteamPSKey.json"
            } catch {
                $Exception = [Exception]::new("Unable to create file $env:AppData\SteamPS\SteamPSKey.json")
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $Exception,
                    "CreateSteamAPIKeyFailed",
                    [System.Management.Automation.ErrorCategory]::WriteError,
                    $TargetObject # usually the object that triggered the error, if possible
                )
                $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            }
        }

        $APIKey = Read-Host -Prompt 'Enter your Steam Web API key' -AsSecureString
        $Key = ConvertFrom-SecureString -SecureString $APIKey
        $Key | Out-File "$($env:AppData)\SteamPS\SteamPSKey.json" -Force
        Write-Verbose -Message "Saved key as secure string to config file."
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
} # Cmdlet
#EndRegion '.\Public\API\Connect-SteamAPI.ps1' 64
#Region '.\Public\API\Disconnect-SteamAPI.ps1' 0
function Disconnect-SteamAPI {
    <#
    .SYNOPSIS
    Disconnects from the Steam API by removing the stored API key.

    .DESCRIPTION
    The Disconnect-SteamAPI cmdlet removes the stored Steam API key from the system. This effectively disconnects the current session from the Steam API.

    .PARAMETER Force
    When the Force switch is used, the cmdlet will skip the confirmation prompt and directly remove the API key.

    .EXAMPLE
    Disconnect-SteamAPI -Force

    This command will remove the stored Steam API key without asking for confirmation.

    .INPUTS
    None. You cannot pipe objects to Disconnect-SteamAPI.

    .OUTPUTS
    None. Nothing is returned when calling Disconnect-SteamAPI.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Disconnect-SteamAPI.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Skip the confirmation prompt.')][switch]$Force
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
        $SteamAPIKey = "$env:AppData\SteamPS\SteamPSKey.json"
    }

    process {
        if ($Force -or $PSCmdlet.ShouldContinue($SteamAPIKey, 'Do you want to continue removing the API key?')) {
            if (Test-Path -Path $SteamAPIKey) {
                Remove-Item -Path $SteamAPIKey -Force
                Write-Verbose -Message "$SteamAPIKey were deleted."
            } else {
                $Exception = [Exception]::new("Steam Web API configuration file not found in '$env:AppData\SteamPS\SteamPSKey.json'.")
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $Exception,
                    'SteamAPIKeyNotFound',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $SteamPSKey
                )
                $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            }
        }
    }

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
}
#EndRegion '.\Public\API\Disconnect-SteamAPI.ps1' 63
#Region '.\Public\API\Get-SteamApp.ps1' 0
function Get-SteamApp {
    <#
    .SYNOPSIS
    Retrieves the name and ID of a Steam application by searching the name or
    ID of the application.

    .DESCRIPTION
    This function searches for a Steam application by name or ID and returns the
    corresponding application ID and name. If multiple applications are found,
    the user can select the correct one from a list.

    .PARAMETER ApplicationName
    The name of the application to search for. If multiple applications are found,
    the user will be presented with a list from which they can select the correct application.

    .PARAMETER ApplicationID
    The unique identifier for a Steam application. Use this parameter to search for an application by its ID.

    .EXAMPLE
    Get-SteamApp -ApplicationName 'Ground Branch'

    Searches for applications with names that start with 'Ground Branch'. If multiple applications are found, the user can choose between them, such as the game 'Ground Branch' or 'Ground Branch Dedicated Server'.

    .EXAMPLE
    Get-SteamApp -ApplicationID 440

    Searches for the application with the AppID 440 and returns its name and ID.

    .INPUTS
    System.String or System.Int32. Get-SteamApp accepts either a string value for the application name or an integer value for the application ID.

    .OUTPUTS
    PSCustomObject. This function returns a custom object with the application name and application ID.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Get-SteamApp.html
    #>

    [CmdletBinding(DefaultParameterSetName = 'ApplicationName')]
    [Alias('Find-SteamAppID')]
    param (
        [Parameter(ParameterSetName = 'ApplicationName',
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GameName')]
        [string]$ApplicationName,

        [Parameter(ParameterSetName = 'ApplicationID',
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GameID')]
        [int]$ApplicationID
    )

    begin {
        Write-Verbose -Message 'Fetching app list from Steam Web API.'
        $SteamApps = (Invoke-RestMethod -Uri 'https://api.steampowered.com/ISteamApps/GetAppList/v2/' -UseBasicParsing).applist.apps
    }

    process {
        # ParameterSet ApplicationName
        if ($PSCmdlet.ParameterSetName -eq 'ApplicationName') {
            Write-Verbose -Message 'ParameterSetName is ApplicationName'
            # Filter on ApplicationName. Might result in multiple hits.
            # The user can then later choose their preference.
            $FilteredApps = $SteamApps.Where({ $_.name -match "^$ApplicationName" })
            # If only one application is found when searching by application name.
            if (($FilteredApps | Measure-Object).Count -eq 1 -and $null -ne $FilteredApps) {
                Write-Verbose -Message "Only one application found: $($FilteredApps.name) - $($FilteredApps.appid)."
                [PSCustomObject]@{
                    ApplicationID   = $FilteredApps.appid
                    ApplicationName = $FilteredApps.name
                }
            }
            # If more than one application is found, the user is prompted to select the exact application.
            elseif (($FilteredApps | Measure-Object).Count -ge 1) {
                # An Out-GridView is presented to the user where the exact AppID can be located. This variable contains the AppID selected in the Out-GridView.
                $SteamApp = $FilteredApps | Select-Object @{Name = 'appid'; Expression = { $_.appid.toString() } }, name | Out-GridView -Title 'Select application' -PassThru
                if ($SteamApp) {
                    Write-Verbose -Message "$(($SteamApp).name) - $(($SteamApp).appid) selected from Out-GridView."
                    [PSCustomObject]@{
                        ApplicationID   = $SteamApp.appid
                        ApplicationName = $SteamApp.name
                    }
                }
            }
            if (-not $FilteredApps) {
                $Exception = [Exception]::new("$ApplicationName could not be found.")
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $Exception,
                    'ApplicationNotFound',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $FilteredApps
                )
                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
        # ParameterSet ApplicationID
        elseif ($PSCmdlet.ParameterSetName -eq 'ApplicationID') {
            Write-Verbose -Message 'ParameterSetName is ApplicationID.'
            $SteamApp = $SteamApps.Where({ $_.appid -eq $ApplicationID })
            if ($SteamApp) {
                [PSCustomObject]@{
                    ApplicationID   = $SteamApp.appid
                    ApplicationName = $SteamApp.name
                }
            } else {
                $Exception = [Exception]::new("$ApplicationID could not be found.")
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $Exception,
                    'ApplicationNotFound',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $SteamApp
                )
                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
    } # Process
} # Cmdlet
#EndRegion '.\Public\API\Get-SteamApp.ps1' 127
#Region '.\Public\API\Get-SteamFriendList.ps1' 0
function Get-SteamFriendList {
    <#
    .SYNOPSIS
    Fetches the friend list of the specified Steam user.

    .DESCRIPTION
    This cmdlet fetches the friend list of a Steam user using the provided SteamID64. It retrieves data only from public profiles.

    .PARAMETER SteamID64
    The 64-bit Steam ID of the user whose friend list is to be fetched.

    .PARAMETER Relationship
    The relationship type used to filter the friend list. The possible values are 'all' or 'friend'. The default is 'friend'.

    .EXAMPLE
    Get-SteamFriendList -SteamID64 76561197960435530

    This example fetches the friend list of the user with the specified SteamID64.

    .INPUTS
    System.Int64

    .OUTPUTS
    PSCustomObject. It returns the following properties:
    - SteamID64: The friend's 64-bit Steam ID.
    - Relationship: The qualifier of the relationship.
    - FriendSince: The Unix timestamp indicating when the relationship was established.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Get-SteamFriendList.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Specifies the 64-bit Steam ID of the user whose friend list will be retrieved.',
            ValueFromPipelineByPropertyName = $true)]
        [int64]$SteamID64,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies the relationship type to filter the friend list. Possible values are "all" or "friend". Default is "friend".')]
        [ValidateSet('all', 'friend')]
        [string]$Relationship = 'friend'
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        $Request = Invoke-RestMethod -Uri 'https://api.steampowered.com/ISteamUser/GetFriendList/v1/' -UseBasicParsing -ErrorAction SilentlyContinue -Body @{
            key          = Get-SteamAPIKey
            steamid      = $SteamID64
            relationship = $Relationship
        }

        if ($Request) {
            foreach ($Item in $Request.friendslist.friends) {
                [PSCustomObject]@{
                    SteamID64    = [int64]$Item.steamid
                    Relationship = $Item.relationship
                    FriendSince  = ((Get-Date "01.01.1970") + ([System.TimeSpan]::FromSeconds($Item.friend_since))).ToString("yyyy-MM-dd HH:mm:ss")
                }
            }
        } elseif ($null -eq $Request) {
            $Exception = [Exception]::new("No friend list found for $SteamID64. This might be because the profile is private.")
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'NoFriendsListFound',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $Request
            )
            $PSCmdlet.WriteError($ErrorRecord)
        }
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
} # Cmdlet
#EndRegion '.\Public\API\Get-SteamFriendList.ps1' 84
#Region '.\Public\API\Get-SteamNews.ps1' 0
function Get-SteamNews {
    <#
    .SYNOPSIS
    Fetches the latest news for a game using its AppID.

    .DESCRIPTION
    Fetches the latest news for a game using its AppID from the Steam API.

    .PARAMETER AppID
    The AppID of the game for which the news is to be fetched.

    .PARAMETER Count
    The number of news entries to fetch. By default, it fetches all news entries.

    .PARAMETER MaxLength
    The maximum length for each news entry. Entries longer than this will be truncated. By default, there is no truncation.

    .EXAMPLE
    Get-SteamNews -AppID 440

    This example fetches all available news entries for the game with AppID 440.

    .EXAMPLE
    Get-SteamNews -AppID 440 -Count 1

    This example fetches the most recent news entry for the game with AppID 440.

    .EXAMPLE
    Get-SteamNews -AppID 440 -MaxLength 100

    This example fetches all available news entries for the game with AppID 440 and truncates the news content to 100 characters.

    .INPUTS
    System.Int32

    .OUTPUTS
    Outputs an object containing:
    - GID: The ID of the news item.
    - Title: The title of the news item.
    - Url: The URL of the news item.
    - IsExternalUrl: A boolean indicating if the URL is external.
    - Author: The author of the news item.
    - Contents: The content of the news item.
    - FeedLabel: The label of the news feed.
    - Date: The date and time when the news item was published.
    - FeedName: The name of the news feed.
    - FeedType: The type of the news feed.
    - AppID: The AppID of the game associated with the news item.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Get-SteamNews.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Specifies the AppID of the game for which you want to retrieve news.')]
        [int]$AppID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies the number of news entries to retrieve.')]
        [int]$Count,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies the maximum length of each news entry.')]
        [int]$MaxLength
    )


    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        # TODO: When only supporting pwsh use null coalescing operator (??)
        # to handle the case when $Count or $MaxLength is not defined
        $Body = @{
            appid = $AppID
        }
        if ($Count) {
            $Body.Add('count', $Count)
        }
        if ($MaxLength) {
            $Body.Add('maxlength', $MaxLength)
        }
        $Request = Invoke-RestMethod -Uri 'http://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/' -UseBasicParsing -Body $Body

        if ($Request) {
            foreach ($Item in $Request.appnews.newsitems) {
                [PSCustomObject]@{
                    GID           = [int64]$Item.gid
                    Title         = $Item.title
                    Url           = $Item.url
                    IsExternalUrl = [bool]$Item.is_external_url
                    Author        = $Item.author
                    Contents      = $Item.contents
                    FeedLabel     = $Item.feedlabel
                    Date          = ((Get-Date "01.01.1970") + ([System.TimeSpan]::FromSeconds($Item.date))).ToString("yyyy-MM-dd HH:mm:ss")
                    FeedName      = $Item.feedname
                    FeedType      = $Item.feed_type
                    AppID         = $Item.appid
                }
            }
        } elseif ($null -eq $Request) {
            $Exception = [Exception]::new("No news found for $AppID.")
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'NoNewsFound',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $Request
            )
            $PSCmdlet.WriteError($ErrorRecord)
        }
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
} # Cmdlet
#EndRegion '.\Public\API\Get-SteamNews.ps1' 123
#Region '.\Public\API\Get-SteamPlayerBan.ps1' 0
function Get-SteamPlayerBan {
    <#
.SYNOPSIS
    Fetches ban information for Steam players.

    .DESCRIPTION
    This cmdlet fetches ban information about Steam players. The information includes whether the players are banned from the Steam Community, have VAC bans, the number of VAC bans, days since the last ban, number of game bans, and economy ban status.

    .PARAMETER SteamID64
    Specifies one or more 64-bit Steam IDs for which to fetch ban information. Enter the Steam IDs as a comma-separated list.

    .EXAMPLE
    Get-SteamPlayerBan -SteamID64 76561197960435530,76561197960434622

    This example fetches ban information for the players with the specified Steam IDs.

    .INPUTS
    int64[]: Specifies an array of 64-bit integers representing Steam IDs.

    .OUTPUTS
    Returns a PSCustomObject with the following properties:

    - SteamID64: The player's 64-bit ID.
    - CommunityBanned: A boolean indicating whether the player is banned from the Steam Community.
    - VACBanned: A boolean indicating whether the player has VAC bans on record.
    - NumberOfVACBans: The number of VAC bans on record.
    - DaysSinceLastBan: The number of days since the last ban.
    - NumberOfGameBans: The number of bans in games, including CS:GO Overwatch bans.
    - EconomyBan: The player's ban status in the economy. If the player has no bans on record, the string will be "none". If the player is on probation, it will say "probation", etc.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Get-SteamPlayerBan.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = '64 bit Steam ID to return player bans for.',
            ValueFromPipelineByPropertyName = $true)]
        [int64[]]$SteamID64
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        $Request = Invoke-RestMethod -Uri 'https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/' -UseBasicParsing -Body @{
            key      = Get-SteamAPIKey
            steamids = ($SteamID64 -join ',')
        }

        if (-not [string]::IsNullOrEmpty($Request.players.SteamId)) {
            foreach ($Item in $Request.players) {
                [PSCustomObject]@{
                    SteamID64        = [int64]$Item.SteamId
                    CommunityBanned  = $Item.CommunityBanned
                    VACBanned        = $Item.VACBanned
                    NumberOfVACBans  = $Item.NumberOfVACBans
                    DaysSinceLastBan = $Item.DaysSinceLastBan
                    NumberOfGameBans = $Item.NumberOfGameBans
                    EconomyBan       = $Item.EconomyBan
                }
            }
        } elseif ([string]::IsNullOrEmpty($Request.players)) {
            $Exception = [Exception]::new("SteamID $SteamID64 couldn't be found.")
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'PlayerNotFound',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $Request
            )
            $PSCmdlet.WriteError($ErrorRecord)
        }
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
} # Cmdlet
#EndRegion '.\Public\API\Get-SteamPlayerBan.ps1' 84
#Region '.\Public\API\Get-SteamPlayerSummary.ps1' 0
function Get-SteamPlayerSummary {
    <#
    .SYNOPSIS
    Fetches basic profile information for a list of 64-bit Steam IDs.

    .DESCRIPTION
    Fetches basic profile information from the Steam Community.

    .PARAMETER SteamID64
    Specifies a comma-separated list of 64-bit Steam IDs to fetch profile information for. Up to 100 Steam IDs can be requested.

    .EXAMPLE
    Get-SteamPlayerSummary -SteamID64 76561197960435530, 76561197960434622

    This example fetches profile information for the players with the specified Steam IDs.

    .INPUTS
    int64[]: Specifies an array of 64-bit integers representing Steam IDs.

    .OUTPUTS
    Returns a custom object with the properties listed below.

    Some data associated with a Steam account may be hidden if the user has their profile visibility set to "Friends Only" or "Private". In that case, only public data will be returned.

    Public Data
    - steamid: 64-bit SteamID of the user.
    - personaname: The player's persona name (display name).
    - profileurl: The full URL of the player's Steam Community profile.
    - avatar: The full URL of the player's 32x32px avatar. If the user hasn't configured an avatar, this will be the default ? avatar.
    - avatarmedium: The full URL of the player's 64x64px avatar. If the user hasn't configured an avatar, this will be the default ? avatar.
    - avatarfull: The full URL of the player's 184x184px avatar. If the user hasn't configured an avatar, this will be the default ? avatar.
    - personastate: The user's current status. 0 - Offline, 1 - Online, 2 - Busy, 3 - Away, 4 - Snooze, 5 - looking to trade, 6 - looking to play. If the player's profile is private, this will always be "0", except if the user has set their status to looking to trade or looking to play, because a bug makes those status appear even if the profile is private.
    - communityvisibilitystate: This represents whether the profile is visible or not, and if it is visible, why you are allowed to see it. Note that because this WebAPI does not use authentication, there are only two possible values returned: 1 - the profile is not visible to you (Private, Friends Only, etc), 3 - the profile is "Public", and the data is visible. Mike Blaszczak's post on Steam forums says, "The community visibility state this API returns is different than the privacy state. It's the effective visibility state from the account making the request to the account being viewed given the requesting account's relationship to the viewed account."
    - profilestate: If set, indicates the user has a community profile configured (will be set to '1')
    - lastlogoff: The last time the user was online, in unix time. Only available when you are friends with the requested user (since Feb, 4).
    - commentpermission: If set, indicates the profile allows public comments.

    Private Data
    - realname: The player's "Real Name", if they have set it.
    - primaryclanid: The player's primary group, as configured in their Steam Community profile.
    - timecreated: The time the player's account was created.
    - gameid: If the user is currently in-game, this value will be returned and set to the gameid of that game.
    - gameserverip: The ip and port of the game server the user is currently playing on, if they are playing on-line in a game using Steam matchmaking. Otherwise will be set to "0.0.0.0:0".
    - gameextrainfo: If the user is currently in-game, this will be the name of the game they are playing. This may be the name of a non-Steam game shortcut.
    - cityid: This value will be removed in a future update (see loccityid)
    - loccountrycode: If set on the user's Steam Community profile, The user's country of residence, 2-character ISO country code
    - locstatecode: If set on the user's Steam Community profile, The user's state of residence
    - loccityid: An internal code indicating the user's city of residence. A future update will provide this data in a more useful way. steam_location gem/package makes player location data readable for output.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Get-SteamPlayerSummary.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = '64 bit Steam ID to return player summary for.',
            ValueFromPipelineByPropertyName = $true)]
        [int64[]]$SteamID64
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        $Request = Invoke-RestMethod -Uri 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2' -UseBasicParsing -Body @{
            key      = Get-SteamAPIKey
            steamids = ($SteamID64 -join ',')
        }

        if ($Request.response.players) {
            foreach ($Item in $Request.response.players) {
                [PSCustomObject]@{
                    SteamID64                = $Item.steamid
                    PersonaName              = $Item.personaname
                    ProfileUrl               = $Item.profileurl
                    Avatar                   = $Item.avatar
                    AvatarMedium             = $Item.avatarmedium
                    AvatarFull               = $Item.avatarfull
                    AvatarHash               = $Item.avatarhash
                    PersonaState             = [PersonaState]$Item.personastate
                    CommunityVisibilityState = [CommunityVisibilityState]$Item.communityvisibilitystate
                    ProfileState             = $Item.profilestate
                    LastLogOff               = ((Get-Date "01.01.1970") + ([System.TimeSpan]::FromSeconds($Item.lastlogoff))).ToString("yyyy-MM-dd HH:mm:ss")
                    CommentPermission        = $Item.commentpermission
                    RealName                 = $Item.realname
                    PrimaryClanID            = $Item.primaryclanid
                    TimeCreated              = ((Get-Date "01.01.1970") + ([System.TimeSpan]::FromSeconds($Item.timecreated))).ToString("yyyy-MM-dd HH:mm:ss")
                    AppID                   = $Item.gameid
                    GameServerIP             = [ipaddress]$Item.gameserverip
                    GameExtraInfo            = $Item.gameextrainfo
                    PersonaStateFlags        = $Item.personastateflags
                    LocCountryCode           = $Item.loccountrycode
                    LocStateCode             = $Item.locstatecode
                    LocCityID                = $Item.loccityid
                }
            }
        } elseif ($Request.response.players.Length -eq 0) {
            $Exception = [Exception]::new("SteamID $SteamID64 couldn't be found.")
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'NoPlayerFound',
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $Request
            )
            $PSCmdlet.WriteError($ErrorRecord)
        }
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
}
#EndRegion '.\Public\API\Get-SteamPlayerSummary.ps1' 118
#Region '.\Public\API\Resolve-VanityURL.ps1' 0
function Resolve-VanityURL {
    <#
    .SYNOPSIS
    Retrieves the SteamID64 linked to a specified vanity URL (custom URL) from the Steam Community.

    .DESCRIPTION
    Using the Steam Web API, this cmdlet fetches the SteamID64 that corresponds to a provided vanity URL (custom URL) from the Steam Community.

    .PARAMETER VanityURL
    This parameter specifies the vanity URL (custom URL) for which the SteamID64 is to be retrieved.

    .PARAMETER UrlType
    This parameter defines the type of vanity URL. The valid values are: 1 (default) for an individual profile, 2 for a group, and 3 for an official game group.

    .EXAMPLE
    Resolve-VanityURL -VanityURL user

    This example retrieves the SteamID64 linked to the vanity URL 'user'.

    .EXAMPLE
    Resolve-VanityURL -VanityURL user1, user2
    This example retrieves the SteamID64s linked to the vanity URLs 'user1' and 'user2'.

    .INPUTS
    The VanityURL parameter accepts string input.

    .OUTPUTS
    The cmdlet returns a custom object containing the VanityURL and its associated SteamID64.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Resolve-VanityURL.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the vanity URL (custom URL) for which the SteamID64 is to be retrieved.')]
        [ValidateScript( {
                if (([System.URI]$_ ).IsAbsoluteUri -eq $true) {
                    throw "Do not enter the fully qualified URL, but just the ID (e.g.) everything after https://steamcommunity.com/id/"
                }
                $true
            })]
        [string[]]$VanityURL,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The type of vanity URL. 1 (default): Individual profile, 2: Group, 3: Official game group.')]
        [ValidateSet(1, 2, 3)]
        [int]$UrlType = 1
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }

    process {
        foreach ($Item in $VanityURL) {
            $Request = Invoke-RestMethod -Uri 'https://api.steampowered.com/ISteamUser/ResolveVanityURL/v1/' -UseBasicParsing -Body @{
                key       = Get-SteamAPIKey
                vanityurl = $Item
                url_type  = $UrlType
            }

            if ($Request.response.success -eq '1') {
                [PSCustomObject]@{
                    'VanityURL' = $Item
                    'SteamID64' = ([int64]$Request.response.steamid)
                }
            } elseif ($Request.response.success -eq '42') {
                $Exception = [Exception]::new("Unable to find $Item.")
                $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $Exception,
                    "VanityURLNotFound",
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $Request.response.success
                )
                $PSCmdlet.WriteError($ErrorRecord)
            }
        }
    } # Process

    end {
        Write-Verbose -Message "[END    ] Ending: $($MyInvocation.MyCommand)"
    }
} # Cmdlet
#EndRegion '.\Public\API\Resolve-VanityURL.ps1' 89
#Region '.\Public\Server\Get-SteamServerInfo.ps1' 0
function Get-SteamServerInfo {
    <#
    .SYNOPSIS
    Query a running steam based game server.

    .DESCRIPTION
    The cmdlet fetches server information from a running game server using UDP/IP packets.
    It will return information ServerName, Map, InstallDir, GameName, AppID, Players
    MaxPlayers, Bots, ServerType, Environment, Visibility, VAC andVersion.

    .PARAMETER IPAddress
    Enter the IP address of the Steam based server.

    .PARAMETER Port
    Enter the port number of the Steam based server.

    .PARAMETER Timeout
    Timeout in milliseconds before giving up querying the server.

    .EXAMPLE
    Get-SteamServerInfo -IPAddress '185.15.73.207' -Port 27015

    ```
    Protocol      : 17
    ServerName    : SAS Proving Ground 10 (EU)
    Map           : TH-SmallTown
    InstallDir    : groundbranch
    GameName      : Ground Branch
    AppID         : 16900
    Players       : 6
    MaxPlayers    : 10
    Bots          : 0
    ServerType    : Dedicated
    Environment   : Windows
    Visibility    : Public
    VAC           : Unsecured
    Version       : 1.0.0.0
    ExtraDataFlag : 177
    IPAddress     : 185.15.73.207
    Port          : 27015
    Ping          : 65
    ```

    .NOTES
    Author: Jordan Borean, Chris Dent and Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Get-SteamServerInfo.html
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the IP address of the Steam based server.')]
        [System.Net.IPAddress]$IPAddress,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the port number of the Steam based server.')]
        [int]$Port,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Timeout in milliseconds before giving up querying the server.')]
        [int]$Timeout = 5000
    )

    begin {
        # A2S_INFO: Retrieves information about the server including, but not limited to: its name, the map currently being played, and the number of players.
        # https://developer.valvesoftware.com/wiki/Server_queries#A2S_INFO
        $A2S_INFO = [byte]0xFF, 0xFF, 0xFF, 0xFF, 0x54, 0x53, 0x6F, 0x75, 0x72, 0x63, 0x65, 0x20, 0x45, 0x6E, 0x67, 0x69, 0x6E, 0x65, 0x20, 0x51, 0x75, 0x65, 0x72, 0x79, 0x00
    }

    process {
        try {
            # Instantiate client and endpoint
            $Client = New-Object -TypeName Net.Sockets.UDPClient(0)
            $Client.Client.SendTimeout = $Timeout
            $Client.Client.ReceiveTimeout = $Timeout
            $IPEndpoint = New-Object -TypeName Net.IPEndpoint([Net.IPAddress]::Any, 0)
            $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            [void]$Client.Send($A2S_INFO, $A2S_INFO.Length, $IPAddress, $Port)

            # The first 4 bytes are 255 which seems to be some sort of header.
            $ReceivedData = $Client.Receive([Ref]$IPEndpoint) | Select-Object -Skip 4
            $Ping = $Stopwatch.ElapsedMilliseconds
            $Stream = [System.IO.BinaryReader][System.IO.MemoryStream][Byte[]]$ReceivedData

            # Challenge:
            if ($Stream.ReadByte() -eq 65) {
                # If the response is a challenge, resend query with last 4 bytes of the challenge
                $challenge = while ($Stream.BaseStream.Position -lt $Stream.BaseStream.Length) {
                    $Stream.ReadByte()
                }
                $newQuery = $A2S_INFO + $challenge

                [void]$Client.Send($newQuery, $newQuery.Length, $IPAddress, $Port)
                # The first 4 bytes are 255 which seems to be some sort of header.
                $ReceivedData = $Client.Receive([Ref]$IPEndpoint) | Select-Object -Skip 4
                $Stream = [System.IO.BinaryReader][System.IO.MemoryStream][Byte[]]$ReceivedData
            } else {
                $Stream.BaseStream.Position = 0
            }

            $Client.Close()
        } catch {
            $Exception = [Exception]::new("Could not reach server {0}:{1}.") -f $IPAddress, $Port
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                "ServerNotFound",
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $ReceivedData
            )
            $PSCmdlet.WriteError($ErrorRecord)
        }

        # If we cannot reach the server we will not display the empty object.
        if ($Stream) {
            # This is also a header - that will always be equal to 'I' (0x49).
            $Stream.ReadByte() | Out-Null
            [PSCustomObject]@{
                Protocol      = [int]$Stream.ReadByte()
                ServerName    = Get-PacketString -Stream $Stream
                Map           = Get-PacketString -Stream $Stream
                InstallDir    = Get-PacketString -Stream $Stream
                GameName      = Get-PacketString -Stream $Stream
                AppID         = [int]$Stream.ReadUInt16()
                Players       = [int]$Stream.ReadByte()
                MaxPlayers    = [int]$Stream.ReadByte()
                Bots          = $Stream.ReadByte()
                ServerType    = [ServerType]$Stream.ReadByte()
                Environment   = [OSType]$Stream.ReadByte()
                Visibility    = [Visibility]$Stream.ReadByte()
                VAC           = [VAC]$Stream.ReadByte()
                Version       = Get-PacketString -Stream $Stream
                ExtraDataFlag = $Stream.ReadByte()
                IPAddress     = $IPAddress
                Port          = $Port
                Ping          = $Ping
            } # PSCustomObject
        }
    } # Process
} # Cmdlet
#EndRegion '.\Public\Server\Get-SteamServerInfo.ps1' 142
#Region '.\Public\Server\Install-SteamCMD.ps1' 0
function Install-SteamCMD {
    <#
    .SYNOPSIS
    Install SteamCMD.

    .DESCRIPTION
    This cmdlet downloads SteamCMD and configures it in a custom or
    predefined location (C:\Program Files\SteamCMD).

    .PARAMETER InstallPath
    Specify the install location of SteamCMD.

    .PARAMETER Force
    The Force parameter allows the user to skip the "Should Continue" box.

    .EXAMPLE
    Install-SteamCMD

    Installs SteamCMD in C:\Program Files\SteamCMD.

    .EXAMPLE
    Install-SteamCMD -InstallPath 'C:'

    Installs SteamCMD in C:\SteamCMD.

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Install-SteamCMD.html
    #>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateScript( {
                if ($_.Substring(($_.Length -1)) -eq '\') {
                    throw "InstallPath may not end with a trailing slash."
                }
                $true
            })]
        [string]$InstallPath = "$env:ProgramFiles",

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    begin {
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if ($isAdmin -eq $false) {
            $Exception = [Exception]::new('The current PowerShell session is not running as Administrator. Start PowerShell by using the Run as Administrator option, and then try running the script again.')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'MissingUserPermissions',
                [System.Management.Automation.ErrorCategory]::PermissionDenied,
                $isAdmin
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }
    }

    process {
        if ($Force -or $PSCmdlet.ShouldContinue('Would you like to continue?', 'Install SteamCMD')) {
            # Ensures that SteamCMD is installed in a folder named SteamCMD.
            $InstallPath = $InstallPath + '\SteamCMD'

            if (-not ((Get-SteamPath).Path -eq $InstallPath)) {
                Write-Verbose -Message "Adding $InstallPath to Environment Variable PATH."
                Add-EnvPath -Path $InstallPath -Container Machine
            } else {
                Write-Verbose -Message "Path $((Get-SteamPath).Path) already exists."
            }

            $TempDirectory = 'C:\Temp'
            if (-not (Test-Path -Path $TempDirectory)) {
                Write-Verbose -Message 'Creating Temp directory.'
                New-Item -Path 'C:\' -Name 'Temp' -ItemType Directory | Write-Verbose
            }

            # Download SteamCMD.
            Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile "$TempDirectory\steamcmd.zip" -UseBasicParsing

            # Create SteamCMD directory if necessary.
            if (-not (Test-Path -Path $InstallPath)) {
                Write-Verbose -Message "Creating SteamCMD directory: $InstallPath"
                New-Item -Path $InstallPath -ItemType Directory | Write-Verbose
                Expand-Archive -Path "$TempDirectory\steamcmd.zip" -DestinationPath $InstallPath
            }

            # Doing some initial configuration of SteamCMD. The first time SteamCMD is launched it will need to do some updates.
            Write-Host -Object 'Configuring SteamCMD for the first time. This might take a little while.'
            Write-Host -Object 'Please wait' -NoNewline
            Start-Process -FilePath "$InstallPath\steamcmd.exe" -ArgumentList 'validate +quit' -WindowStyle Hidden
            do {
                Write-Host -Object "." -NoNewline
                Start-Sleep -Seconds 3
            }
            until (-not (Get-Process -Name "*steamcmd*"))
        }
    } # Process

    end {
        if (Test-Path -Path "$TempDirectory\steamcmd.zip") {
            Remove-Item -Path "$TempDirectory\steamcmd.zip" -Force
        }

        if (Test-Path -Path (Get-SteamPath).Executable) {
            Write-Output -InputObject "SteamCMD is now installed. Please close/open your PowerShell host."
        }
    } # End
} # Cmdlet
#EndRegion '.\Public\Server\Install-SteamCMD.ps1' 113
#Region '.\Public\Server\Update-SteamApp.ps1' 0
function Update-SteamApp {
    <#
    .SYNOPSIS
    Install or update a Steam application using SteamCMD.

    .DESCRIPTION
    Install or update a Steam application using SteamCMD. If SteamCMD is missing, it will be installed first.
    You can either search for the application by name or enter the specific Application ID.

    .PARAMETER ApplicationName
    Enter the name of the app to make a wildcard search for the application.

    .PARAMETER ApplicationID
    Enter the application ID you wish to install.

    .PARAMETER Credential
    If the app requires login to install or update, enter your Steam username and password.

    .PARAMETER Path
    Path to installation folder.

    .PARAMETER Arguments
    Enter any additional arguments here.

    Beware, the following arguments are already used:

    If you use Steam login to install/upload the app the following arguments are already used: "+force_install_dir $Path +login $SteamUserName $SteamPassword +app_update $SteamAppID $Arguments +quit"

    If you use anonymous login to install/upload the app the following arguments are already used: "+force_install_dir $Path +login anonymous +app_update $SteamAppID $Arguments +quit"

    .PARAMETER Force
    The Force parameter allows the user to skip the "Should Continue" box.

    .EXAMPLE
    Update-SteamApp -ApplicationName 'Arma 3' -Credential 'Toby' -Path 'C:\DedicatedServers\Arma3'

    Because there are multiple hits when searching for Arma 3, the user will be promted to select the right application.

    .EXAMPLE
    Update-SteamApp -AppID 376030 -Path 'C:\DedicatedServers\ARK-SurvivalEvolved'

    Here we use anonymous login because the particular application (ARK: Survival Evolved Dedicated Server) doesn't require login.

    .NOTES
    Author: Frederik Hjorslev Nylander

    SteamCMD CLI parameters: https://developer.valvesoftware.com/wiki/Command_Line_Options#Command-line_parameters_4

    .LINK
    https://hjorslev.github.io/SteamPS/Update-SteamApp.html
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification='Is implemented but not accepted by PSSA.')]
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param (
        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ApplicationName'
        )]
        [Alias('GameName')]
        [string]$ApplicationName,

        [Parameter(Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ApplicationID'
        )]
        [ValidateScript({
            if ($null -eq (Get-SteamApp -ApplicationID $_)) {
                    Write-Verbose -Message "ApplicationID $_ couldn't be found using the Steam Web API. Continuing anyway as the application might exist."
            }
            $true
        })]
        [Alias('AppID')]
        [int]$ApplicationID,

        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if ($_.Substring(($_.Length -1)) -eq '\') {
                    throw "Path may not end with a trailing slash."
                }
                $true
            })]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [string]$Arguments,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    begin {
        if ($null -eq (Get-SteamPath)) {
            throw 'SteamCMD could not be found in the env:Path. Have you executed Install-SteamCMD?'
        }

        # Install SteamCMD if it is missing.
        if (-not (Test-Path -Path (Get-SteamPath).Executable)) {
            Start-Process powershell -ArgumentList '-NoExit -Command "Install-SteamCMD; exit"' -Verb RunAs
            Write-Verbose -Message 'Installing SteamCMD in another window. Please wait and try again.'
            throw "SteamCMD is missing and is being installed in another window. Please wait until the other window closes, restart your console, and try again."
        }
    } # Begin

    process {
        function Use-SteamCMD ($SteamAppID) {
            # If Steam username and Steam password are not empty we use them for logging in.
            if ($null -ne $Credential.UserName) {
                Write-Verbose -Message "Logging into Steam as $($Credential | Select-Object -ExpandProperty UserName)."
                $SteamCMDProcess = Start-Process -FilePath (Get-SteamPath).Executable -NoNewWindow -ArgumentList "+force_install_dir `"$Path`" +login $($Credential.UserName) $($Credential.GetNetworkCredential().Password) +app_update $SteamAppID $Arguments +quit" -Wait -PassThru
                if ($SteamCMDProcess.ExitCode -ne 0) {
                    Write-Error -Message ("SteamCMD closed with ExitCode {0}" -f $SteamCMDProcess.ExitCode) -Category CloseError
                }
            }
            # If Steam username and Steam password are empty we use anonymous login.
            elseif ($null -eq $Credential.UserName) {
                Write-Verbose -Message 'Using SteamCMD as anonymous.'
                $SteamCMDProcess = Start-Process -FilePath (Get-SteamPath).Executable -NoNewWindow -ArgumentList "+force_install_dir `"$Path`" +login anonymous +app_update $SteamAppID $Arguments +quit" -Wait -PassThru
                if ($SteamCMDProcess.ExitCode -ne 0) {
                    Write-Error -Message ("SteamCMD closed with ExitCode {0}" -f $SteamCMDProcess.ExitCode) -Category CloseError
                }
            }
        }

        # If game is found by searching for game name.
        if ($PSCmdlet.ParameterSetName -eq 'ApplicationName') {
            try {
                $SteamApp = Get-SteamApp -ApplicationName $ApplicationName
                # Install selected Steam application if a SteamAppID has been selected.
                if (-not ($null -eq $SteamApp)) {
                    if ($Force -or $PSCmdlet.ShouldContinue("Do you want to install or update $($SteamApp.ApplicationName)?", "Update SteamApp $($SteamApp.ApplicationName)?")) {
                        Write-Verbose -Message "The application $($SteamApp.ApplicationName) is being updated. Please wait for SteamCMD to finish."
                        Use-SteamCMD -SteamAppID $SteamApp.ApplicationID
                    } # Should Continue
                }
            } catch {
                Throw "$ApplicationName couldn't be updated."
            }
        } # ParameterSet ApplicationName

        # If game is found by using a unique ApplicationID.
        if ($PSCmdlet.ParameterSetName -eq 'ApplicationID') {
            try {
                $SteamAppID = $ApplicationID
                # Install selected Steam application.
                if ($Force -or $PSCmdlet.ShouldContinue("Do you want to install or update $($SteamAppID)?", "Update SteamApp $($SteamAppID)?")) {
                    Write-Verbose -Message "The application with AppID $SteamAppID is being updated. Please wait for SteamCMD to finish."
                    Use-SteamCMD -SteamAppID $SteamAppID
                } # Should Continue
            } catch {
                Throw "$SteamAppID couldn't be updated."
            }
        } # ParameterSet AppID
    } # Process
} # Cmdlet
#EndRegion '.\Public\Server\Update-SteamApp.ps1' 166
#Region '.\Public\Server\Update-SteamServer.ps1' 0
function Update-SteamServer {
    <#
    .SYNOPSIS
    Update a Steam based game server.

    .DESCRIPTION
    This cmdlet presents a workflow to keep a steam based game server up to date.
    The server is expecting the game server to be running as a Windows Service.

    .PARAMETER AppID
    Enter the application ID you wish to install.

    .PARAMETER ServiceName
    Specify the Windows Service Name. You can get a list of services with Get-Service.

    .PARAMETER IPAddress
    Enter the IP address of the Steam based server.

    .PARAMETER Port
    Enter the port number of the Steam based server.

    .PARAMETER Path
    Install location of the game server.

    .PARAMETER Credential
    If the app requires login to install or update, enter your Steam username and password.

    .PARAMETER Arguments
    Enter any additional arguments here.

    .PARAMETER LogPath
    Specify the directory of the log files.

    .PARAMETER DiscordWebhookUri
    Enter a Discord Webhook Uri if you wish to get notifications about the server
    update.

    .PARAMETER AlwaysNotify
    Always receive a notification when a server has been updated. Default is
    only to send on errors.

    .PARAMETER TimeoutLimit
    Number of times the cmdlet checks if the server is online or offline. When
    the limit is reached an error is thrown.

    .EXAMPLE
    Update-SteamServer -AppID 476400 -ServiceName GB-PG10 -IPAddress '185.15.73.207' -Port 27015

    .NOTES
    Author: Frederik Hjorslev Nylander

    .LINK
    https://hjorslev.github.io/SteamPS/Update-SteamServer.html
    #>

    # TODO: Implement support for ShouldContinue. Due to compatibility we wait with this.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'High')]

    param (
        [Parameter(Mandatory = $true)]
        [int]$AppID,

        [Parameter(Mandatory = $true)]
        [ValidateScript( { Get-Service -Name $_ })]
        [string]$ServiceName,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [System.Net.IPAddress]$IPAddress,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [int]$Port,

        [Parameter(Mandatory = $false)]
        [Alias('ApplicationPath')]
        [string]$Path = "C:\DedicatedServers\$ServiceName",

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [string]$Arguments,

        [Parameter(Mandatory = $false)]
        [Alias('LogLocation')]
        [string]$LogPath = 'C:\DedicatedServers\Logs',

        [Parameter(Mandatory = $false)]
        [string]$DiscordWebhookUri,

        [Parameter(Mandatory = $false)]
        [string]$AlwaysNotify,

        [Parameter(Mandatory = $false)]
        [int]$TimeoutLimit = 10
    )

    begin {
        if ($null -eq (Get-SteamPath)) {
            $Exception = [Exception]::new('SteamCMD could not be found in the env:Path. Have you executed Install-SteamCMD?')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'SteamCMDNotInstalled',
                [System.Management.Automation.ErrorCategory]::NotInstalled,
                (Test-Admin)
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }

        if ((Test-Admin) -eq $false) {
            $Exception = [Exception]::new('The current PowerShell session is not running as Administrator. Start PowerShell by using the Run as Administrator option, and then try running the script again.')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'MissingUserPermissions',
                [System.Management.Automation.ErrorCategory]::PermissionDenied,
                (Test-Admin)
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }

        # Log settings
        $PSFLoggingProvider = @{
            Name          = 'logfile'
            InstanceName  = "Update game server $ServiceName"
            FilePath      = "$LogPath\$ServiceName\$ServiceName-%Date%.csv"
            Enabled       = $true
            LogRotatePath = "$LogPath\$ServiceName\$ServiceName-*.csv"
        }
        Set-PSFLoggingProvider @PSFLoggingProvider

        # Variable that stores how many times the cmdlet has checked whether the
        # server is offline or online.
        $TimeoutCounter = 0
    }

    process {
        # Get server status and output it.
        $ServerStatus = Get-SteamServerInfo -IPAddress $IPAddress -Port $Port -ErrorAction SilentlyContinue

        # If server is alive we check it is empty before updating it.
        if ($ServerStatus) {
            Write-PSFMessage -Level Host -Message $ServerStatus -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"

            # Waiting to server is empty. Checking every 60 seconds.
            while ($ServerStatus.Players -ne 0) {
                Write-PSFMessage -Level Host -Message 'Awaiting that the server is empty before updating.' -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
                $ServerStatus = Get-SteamServerInfo -IPAddress $IPAddress -Port $Port -ErrorAction SilentlyContinue
                Write-PSFMessage -Level Host -Message $($ServerStatus | Select-Object -Property ServerName, Port, Players) -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
                Start-Sleep -Seconds 60
            }
            # Server is now empty and we stop, update and start the server.
            Write-PSFMessage -Level Host -Message "Stopping $ServiceName..." -Tag 'ServerUpdate' -ModuleName 'SteamPS' -Target $ServiceName
            Stop-Service -Name $ServiceName
            Write-PSFMessage -Level Host -Message "$($ServiceName): $((Get-Service -Name $ServiceName).Status)." -Tag 'ServerUpdate' -ModuleName 'SteamPS' -Target $ServiceName
        } else {
            Write-PSFMessage -Level Host -Message 'Server could not be reached.' -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            Write-PSFMessage -Level Host -Message 'Continuing with updating server.' -Tag 'ServerUpdate' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
        }

        Write-PSFMessage -Level Host -Message "Updating $ServiceName..." -Tag 'ServerUpdate' -ModuleName 'SteamPS' -Target $ServiceName
        if ($null -ne $Credential) {
            Update-SteamApp -AppID $AppID -Path $Path -Credential $Credential -Arguments "$Arguments" -Force
        } else {
            Update-SteamApp -AppID $AppID -Path $Path -Arguments "$Arguments" -Force
        }

        Write-PSFMessage -Level Host -Message "Starting $ServiceName" -Tag 'ServerUpdate' -ModuleName 'SteamPS' -Target $ServiceName
        Start-Service -Name $ServiceName
        Write-PSFMessage -Level Host -Message "$($ServiceName): $((Get-Service -Name $ServiceName).Status)." -Tag 'ServerUpdate' -ModuleName 'SteamPS' -Target $ServiceName

        do {
            $TimeoutCounter++ # Add +1 for every loop.
            Write-PSFMessage -Level Host -Message 'Waiting for server to come online again.' -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            Start-Sleep -Seconds 60
            # Getting new server information.
            $ServerStatus = Get-SteamServerInfo -IPAddress $IPAddress -Port $Port -ErrorAction SilentlyContinue | Select-Object -Property ServerName, Port, Players
            Write-PSFMessage -Level Host -Message $ServerStatus -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            Write-PSFMessage -Level Host -Message "No response from $($IPAddress):$($Port)." -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            Write-PSFMessage -Level Host -Message "TimeoutCounter: $TimeoutCounter/$TimeoutLimit" -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            if ($TimeoutCounter -ge $TimeoutLimit) {
                break
            }
        } until ($null -ne $ServerStatus.ServerName)

        if ($null -ne $ServerStatus.ServerName) {
            Write-PSFMessage -Level Host -Message "$($ServerStatus.ServerName) is now ONLINE." -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            $ServerState = 'ONLINE'
            $Color = 'Green'
        } else {
            Write-PSFMessage -Level Critical -Message "Server seems to be OFFLINE after the update..." -Tag 'ServerStatus' -ModuleName 'SteamPS' -Target "$($IPAddress):$($Port)"
            $ServerState = 'OFFLINE'
            $Color = 'Red'
        }
    } # Process

    end {
        if ($null -ne $DiscordWebhookUri -and ($ServerState -eq 'OFFLINE' -or $AlwaysNotify -eq $true)) {
            # Send Message to Discord about the update.
            $ServerFact = New-DiscordFact -Name 'Game Server Info' -Value $(Get-SteamServerInfo -IPAddress $IPAddress -Port $Port -ErrorAction SilentlyContinue | Select-Object -Property ServerName, IP, Port, Players | Out-String)
            $ServerStateFact = New-DiscordFact -Name 'Server State' -Value $(Write-Output -InputObject "Server is $ServerState!")
            $LogFact = New-DiscordFact -Name 'Log Location' -Value "$LogPath\$ServiceName\$ServiceName-%Date%.csv"
            $Section = New-DiscordSection -Title "$ServiceName - Update Script Executed" -Facts $ServerStateFact, $ServerFact, $LogFact -Color $Color
            Send-DiscordMessage -WebHookUrl $DiscordWebhookUri -Sections $Section
        }
    } # End
} # Cmdlet
#EndRegion '.\Public\Server\Update-SteamServer.ps1' 213
