function Search-Art {
    param(
        [string]$Query
    )
    $pythonScript = "C:\Users\Digital_Russkiy\Documents\Python_Scripts\art_search.py"
    if (-not (Test-Path $pythonScript)) {
        Write-Host "Python script not found at $pythonScript" -ForegroundColor Red
        return
    }
    if (-not $Query) {
        Write-Host "Please provide a search query." -ForegroundColor Yellow
        return
    }
    Write-Host "Running: python $pythonScript `"$Query`"" -ForegroundColor Cyan
    python "$pythonScript" "$Query"
}