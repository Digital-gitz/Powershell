function Touch {
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias('Path')]
    [string]$FileName
  )
  $FullPath = Join-Path -Path (Get-Location) -ChildPath $FileName
  New-Item -Path $FullPath -ItemType File
}

Export-ModuleMember -Function Touch 
