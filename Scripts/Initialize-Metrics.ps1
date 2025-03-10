# Performance tracking functionality
$global:ProfileStartTime = Get-Date
$global:MetricsEnabled = $true
$global:ProfileMetrics = @{}

function Register-ProfileMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][datetime]$StartTime,
        [switch]$IsError,
        [string]$Details
    )
    
    if (-not $global:MetricsEnabled) { return }

    $duration = (Get-Date) - $StartTime
    $global:ProfileMetrics[$Name] = @{
        Duration = $duration
        IsError = $IsError
        Details = $Details
    }
}

function Show-ProfileMetrics {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [switch]$SortByDuration
    )
    
    if (-not $global:MetricsEnabled) {
        Write-Warning "Metrics are not enabled"
        return
    }

    $totalDuration = (Get-Date) - $global:ProfileStartTime
    Write-Host "`nProfile Load Metrics:" -ForegroundColor Cyan
    Write-Host "Total Duration: $($totalDuration.TotalSeconds) seconds" -ForegroundColor Yellow

    $metrics = $global:ProfileMetrics.GetEnumerator()
    if ($SortByDuration) {
        $metrics = $metrics | Sort-Object { $_.Value.Duration } -Descending
    }

    foreach ($metric in $metrics) {
        $color = if ($metric.Value.IsError) { 'Red' } else { 'Green' }
        $duration = $metric.Value.Duration.TotalSeconds
        
        if ($Detailed) {
            Write-Host ("`n{0}" -f $metric.Key) -ForegroundColor Cyan
            Write-Host ("  Duration: {0:N3} seconds" -f $duration) -ForegroundColor $color
            if ($metric.Value.Details) {
                Write-Host ("  Details: {0}" -f $metric.Value.Details) -ForegroundColor Gray
            }
        } else {
            Write-Host ("{0}: {1:N3}s" -f $metric.Key, $duration) -ForegroundColor $color
        }
    }
}

write-host "Metrics initialized"