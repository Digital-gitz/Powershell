$top1000 = foreach ($p in 1..50) {
    try {
        $c = Invoke-WebRequest -Uri "https://www.powershellgallery.com/packages" -Method Post -Body "q=&sortOrder=package-download-count&page=$p" -ErrorAction Stop
        [regex]::Matches($c.Content, '<table class="width-hundred-percent">.*?</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline) | ForEach-Object {
            $name = [regex]::Match($_, "(?<=<h1><a href=.*?>).*(?=</a></h1>)").Value
            $n = [regex]::Replace($_, '^.*By:\s*<li role="menuitem">', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $n = [regex]::Replace($n, '</div>.*$', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $by = [regex]::Match($n, '(?<=">).*(?=</a>)').Value
            $qty = [regex]::Match($n, '\S*(?= downloads)').Value
            [PSCustomObject]@{
                Name      = $name
                By        = $by
                Downloads = $qty
            }
        }
    }
    catch {
        Write-Warning "Failed to retrieve page $p : $($_.Exception.Message)"
        continue
    }
}


# Install-Module -Name SteamPS

Remove-Item "~\Documents\gallery.xlsx" -ErrorAction SilentlyContinue
$pivotdef = New-PivotTableDefinition -PivotTableName 'Summary' -PivotRows by -PivotData @{
    name      = "Count"
    Downloads = "Sum"
} -PivotDataToColumn -Activate -ChartType ColumnClustered -PivotNumberFormat '#,###'
$top1000 | Export-Excel -Path '~\Documents\gallery.xlsx' -NumberFormat '#,###' -PivotTableDefinition $pivotdef -TableName 'TopDownloads' -Show