function Start-Aseprite {
    # Check if Aseprite is already running
    $aspriteProcess = Get-Process | Where-Object { $_.MainWindowTitle -like "*Aseprite*" -or $_.ProcessName -like "*aseprite*" }
    
    if ($null -eq $aspriteProcess) {
        Write-Host "Aseprite is not running. Starting it up!"
    }
    else {
        Write-Host "Stopping Aseprite."
        $aspriteProcess | Stop-Process -Force
        # Give it a moment to fully close
        Start-Sleep -Seconds 2
    }

    # Verify the path exists before trying to start
    $aspritePath = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"
    if (Test-Path $aspritePath) {
        Start-Process -FilePath $aspritePath
    }
    else {
        Write-Host "Could not find Aseprite executable at expected path." -ForegroundColor Red
        Write-Host "Please verify the installation path: $aspritePath" -ForegroundColor Yellow
    }
}