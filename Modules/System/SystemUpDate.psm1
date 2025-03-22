# System update functions
function Update-WindowsSystem {
    try {
        Write-Log "Checking for Windows updates..." -Level 'Info'
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0")
        
        if ($searchResult.Updates.Count -gt 0) {
            Write-Log "Found $($searchResult.Updates.Count) updates" -Level 'Info'
            $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($update in $searchResult.Updates) {
                $updatesToInstall.Add($update) | Out-Null
            }
            
            $installer = $updateSession.CreateUpdateInstaller()
            $installer.Updates = $updatesToInstall
            $installationResult = $installer.Install()
            
            Write-Log "Update installation completed with result code: $($installationResult.ResultCode)" -Level 'Success'
            return $true
        }
        else {
            Write-Log "No updates available" -Level 'Info'
            return $true
        }
    }
    catch {
        Write-Log "Failed to update Windows: $_" -Level 'Error'
        return $false
    }
}

function Update-ChocolateyPackages {
    try {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Log "Updating Chocolatey packages..." -Level 'Info'
            choco upgrade all -y
            Write-Log "Chocolatey packages updated successfully" -Level 'Success'
            return $true
        }
        else {
            Write-Log "Chocolatey is not installed" -Level 'Warning'
            return $false
        }
    }
    catch {
        Write-Log "Failed to update Chocolatey packages: $_" -Level 'Error'
        return $false
    }
}

# Export functions
Export-ModuleMember -Function Update-WindowsSystem, Update-ChocolateyPackages 