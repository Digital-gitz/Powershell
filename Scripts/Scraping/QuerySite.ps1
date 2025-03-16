
$url = Read-Host "Enter the URL to query"
$web = New-Object Net.WebClient
$web | Get-Member
	
$web.DownloadString("$url")

#get size of website in bytes
$size = $web.DownloadString("$url").Length
Write-Host "Size of website: $size bytes"
"{0} bytes" -f ($web.DownloadString("$url")).length.toString("###,###,##0")


#continue to attempt a connection until it is able to do so,
Begin {
    $web = New-Object System.Net.WebClient
    $flag = $false
    }
Process {
    While ($flag -eq $false) {
        Try {
            $web.DownloadString("https://hereisasite.net")
            $flag = $True
            }
        Catch {
            Write-host -fore Red -nonewline "Access down..."
            }
        }
    }    
End {
    Write-Host -fore Green "Access is back"
    }

    #Net.WebRequest
    
2
$webRequest = [net.WebRequest]::Create("$url;")
$webRequest | gm