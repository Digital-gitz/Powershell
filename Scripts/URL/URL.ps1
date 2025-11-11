function Get-UrlFunctionList {
    <#
    .SYNOPSIS
        Lists the contents of Url-Functions.txt.

    .DESCRIPTION
        Reads and outputs each line from the Url-Functions.txt file in the current directory.
    #>
    $urlFunctionsPath = Join-Path $PSScriptRoot "Url-Functions.txt"
    if (Test-Path $urlFunctionsPath) {
        Get-Content $urlFunctionsPath | ForEach-Object { Write-Output $_ }
    } else {
        Write-Warning "Url-Functions.txt not found in $PSScriptRoot."
    }
}
Write-Host "Get-UrlFunctionList"

function Get-SearchFunctionList {
    <#
    .SYNOPSIS
        Lists the contents of Search-Functions.txt.

    .DESCRIPTION
        Reads and outputs each line from the Search-Functions.txt file in the current directory.
    #>
    $searchFunctionsPath = Join-Path $PSScriptRoot "Search-Functions.txt"
    if (Test-Path $searchFunctionsPath) {
        Get-Content $searchFunctionsPath | ForEach-Object { Write-Output $_ }
    } else {
        Write-Warning "Search-Functions.txt not found in $PSScriptRoot."
    }
}

Write-Host "Get-SearchFunctionList"

#region Government 
$FloridaBlue = @{
    MemberPortal = "https://member.bcbsfl.com/member/digital/#/"
}
#region End Government URLs

#region Google 
$Google = @{
    Documents = "https://docs.google.com/document/"
    Resume = "https://docs.google.com/document/d/1UzMXCDF6FM4RGpVKbA_dt5Bi383w5BoBktMdQlPAajA/edit?usp=sharing"
    Drive = "https://drive.google.com/"
    Sheets = "https://docs.google.com/spreadsheets/"
    Slides = "https://docs.google.com/presentation/"
    Forms = "https://docs.google.com/forms/"
    Keep = "https://keep.google.com/"
    Meet = "https://meet.google.com/"
    Contacts = "https://contacts.google.com/"
    Photos = "https://photos.google.com/"
    Youtube = "https://www.youtube.com/"
    Maps = "https://www.google.com/maps/"
    Translate = "https://www.google.com/translate/"
    Earth = "https://www.google.com/earth/"
    Ads = "https://www.google.com/ads/"
    Analytics = "https://www.google.com/analytics/"
    Adsense = "https://www.google.com/adsense/"
    Webmasters = "https://www.google.com/webmasters/"
    Blog = "https://www.google.com/blog/"
    Cloud = "https://www.google.com/cloud/"
    CloudStorage = "https://www.google.com/cloud-storage/"
}
#region End Google URLs

#region Social Media URLs
$Twitter = @{
    home = "https://x.com/SvyatRusskiy"
    X = "https://www.twitter.com/"


}
$Bluesky = @{
    Home = "https://www.bluesky.app/"
}
$Tumblr = @{
    Home = "https://www.tumblr.com/"
}
$Pintrest = @{
    Home = "https://www.pinterest.com/"
}

$Meta = @{
    Facebook = "https://www.facebook.com/"
    Threads = "https://www.threads.com/"
    Instagram = "https://www.instagram.com/"
}

$Reddit = @{
    Home = "https://www.reddit.com/"
}

$ArtStation = @{
    Home = "https://www.artstation.com/"
}
#region End Social Media URLs

#region Music URLs
$spotify = @{
    Home = "https://open.spotify.com/"
    SpotifyAPI = "https://developer.spotify.com/documentation/web-api"
}
#region End Music URLs

#region End Reddit URLs
$Indeed = @{
    Home = "https://www.indeed.com/"
}

#region Functions


#region Government 
function Open-FloridaBlueMemberPortal {
    Write-Host "`n🌐 Opening Member Portal..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $FloridaBlue.MemberPortal
    Write-Host "Opened Florida Blue Member Portal: $($FloridaBlue.MemberPortal)" -ForegroundColor Green
}
#Endregion Government Functions

#region Google URLs
function Open-GoogleDocuments {
    Write-Host "`n🌐 Opening Google Documents..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Google.Documents
    Write-Host "Opened Google Documents: $($Google.Documents)" -ForegroundColor Green
}
function Open-GoogleResume {
    Write-Host "`n🌐 Opening Google Resume..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Google.Resume
    Write-Host "Opened Google Resume: $($Google.Resume)" -ForegroundColor Green
}
#Endregion Google URLs

#region SocialMedia Funct
function Open-Pintrest {
    Write-Host "`n🌐 Opening Pintrest..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Pintrest.Home
    Write-Host "Opened Pintrest: $($Pintrest.Home)" -ForegroundColor Green
}

function Open-Reddit {
    Write-Host "`n🌐 Opening Reddit..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Reddit.Home
    Write-Host "Opened Reddit: $($Reddit.Home)" -ForegroundColor Green
}
#endregion Social Media Functions

function Open-X{
    Write-Host "`n🌐 Opening X..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Twitter.Home
    Write-Host "Opened Twitter: $($Twitter.Home)" -ForegroundColor Green
}

function Open-Twitter {
    Write-Host "`n🌐 Opening Twitter..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Twitter.Home
    Write-Host "Opened Twitter: $($Twitter.Home)" -ForegroundColor Green
}

function Open-Bluesky {
    Write-Host "`n🌐 Opening Bluesky..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Bluesky.Home
    Write-Host "Opened Bluesky: $($Bluesky.Home)" -ForegroundColor Green
}

function Open-Tumblr {
    Write-Host "`n🌐 Opening Tumblr..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Tumblr.Home
    Write-Host "Opened Tumblr: $($Tumblr.Home)" -ForegroundColor Green
}

function Open-Meta {
    Write-Host "`n🌐 Opening Meta..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Meta.Facebook
    Write-Host "Opened Meta: $($Meta.Facebook)" -ForegroundColor Green
}

function Open-Threads {
    Write-Host "`n🌐 Opening Threads..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Meta.Threads
    Write-Host "Opened Threads: $($Meta.Threads)" -ForegroundColor Green
}

function Open-Instagram {
    Write-Host "`n🌐 Opening Instagram..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Meta.Instagram
    Write-Host "Opened Instagram: $($Meta.Instagram)" -ForegroundColor Green
}

function Open-Spotify {
    Write-Host "`n🌐 Opening Spotify..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $spotify.Home
    Write-Host "Opened Spotify: $($spotify.Home)" -ForegroundColor Green
}

function Open-SpotifyAPI {
    Write-Host "`n🌐 Opening Spotify API..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $spotify.SpotifyAPI
    Write-Host "Opened Spotify API: $($spotify.SpotifyAPI)" -ForegroundColor Green
}

function Open-ArtStation {
    Write-Host "`n🌐 Opening ArtStation..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $ArtStation.Home
    Write-Host "Opened ArtStation: $($ArtStation.Home)" -ForegroundColor Green
}

function Open-Indeed {
    Write-Host "`n🌐 Opening Indeed..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Indeed.Home
    Write-Host "Opened Indeed: $($Indeed.Home)" -ForegroundColor Green
}

function Open-Discord {
    Write-Host "`n🌐 Opening Discord..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Discord.Home
    Write-Host "Opened Discord: $($Discord.Home)" -ForegroundColor Green
}

function Open-Github {
    Write-Host "`n🌐 Opening Github..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Github.Home
    Write-Host "Opened Github: $($Github.Home)" -ForegroundColor Green
}

function Open-Youtube {
    Write-Host "`n🌐 Opening Youtube..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Youtube.Home
    Write-Host "Opened Youtube: $($Youtube.Home)" -ForegroundColor Green
}

function Open-Perplexity {
    Write-Host "`n🌐 Opening Perplexity..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Perplexity.Home
    Write-Host "Opened Perplexity: $($Perplexity.Home)" -ForegroundColor Green
}

function Open-Phind {
    Write-Host "`n🌐 Opening Phind..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Phind.Home
    Write-Host "Opened Phind: $($Phind.Home)" -ForegroundColor Green
}

function Open-Grapevine {
    Write-Host "`n🌐 Opening Grapevine..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Start-Process $Grapevine.Home
    Write-Host "Opened Grapevine: $($Grapevine.Home)" -ForegroundColor Green
}

#region Error Handling
Write-Host "C:\Users\Digital_Russkiy\Documents\Powershell\Scripts\URL\URL.ps1 loaded successfully!" -ForegroundColor Green
#endregion Error Handling