function  Download-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url
    )

    # Get the desktop path
    $desktopPath = [Environment]::GetFolderPath('Desktop')

    # Extract the file name from the URL
    $fileName = [System.IO.Path]::GetFileName($Url)

    # Combine the desktop path with the file name
    $outputPath = [System.IO.Path]::Combine($desktopPath, $fileName)

    # Download the file
    Invoke-WebRequest -Uri $Url -OutFile $outputPath

    # Return the output path
    return $outputPath
}

# Example usage:
# Download-File -Url "https://example.com/file.zip"
# Download-File -Url "https://example.com/file.zip"




function D-EXE {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url
    )

    # Get the desktop path
    $desktopPath = [Environment]::GetFolderPath('Desktop')

    # Extract the file name from the URL
    $fileName = [System.IO.Path]::GetFileName($Url)

    # Combine the desktop path with the file name
    $outputPath = [System.IO.Path]::Combine($desktopPath, $fileName)

    try {
        # Download the file
        Invoke-WebRequest -Uri $Url -OutFile $outputPath

        # Check if the file was downloaded successfully
        if (Test-Path $outputPath) {
            Write-Host "File downloaded successfully to $outputPath"

            # Execute the file
            Start-Process -FilePath $outputPath
            Write-Host "File executed successfully"
        } else {
            Write-Error "File download failed"
        }
    } catch {
        Write-Error "An error occurred: $_"
    }

    # Return the output path
    return $outputPath
}


