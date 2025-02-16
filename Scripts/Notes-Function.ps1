# Utilities.ps1

function Note {
    param()
    
    $notes = Get-ChildItem -Filter "*.txt" -Path .
    
    Write-Host "`nNote Management:" -ForegroundColor Green
    Write-Host "1. Create new note" -ForegroundColor Green
    Write-Host "2. Add to existing note" -ForegroundColor Green
    Write-Host "3. Read existing note" -ForegroundColor Green
    Write-Host "Select an option (1-3)" -ForegroundColor Green -NoNewline
    
    $choice = Read-Host
    
    switch ($choice) {
        "1" {
            Write-Host "Enter note name (without .txt):" -ForegroundColor Green -NoNewline
            $noteName = Read-Host
            $noteName = "$noteName.txt"
            
            Write-Host "Enter note content:" -ForegroundColor Green -NoNewline
            $newNote = Read-Host
            
            try {
                $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $newNoteContent = "[$currentDateTime]`n$newNote`n"
                $newNoteFile = Join-Path -Path (Get-Location) -ChildPath $noteName
                $newNoteContent | Out-File -FilePath $newNoteFile
                Write-Host "Note created: $noteName" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to create note: $_"
            }
        }
        "2" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Green
            $notes | ForEach-Object { Write-Host " - $_" -ForegroundColor Green }
            
            Write-Host "Select note to update:" -ForegroundColor Green -NoNewline
            $selectedNote = Read-Host
            
            if (Test-Path $selectedNote) {
                Write-Host "Enter additional content:" -ForegroundColor Green -NoNewline
                $additionalText = Read-Host
                
                try {
                    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $appendContent = "`n[$currentDateTime]`n$additionalText"
                    $appendContent | Out-File -FilePath $selectedNote -Append
                    Write-Host "Note updated: $selectedNote" -ForegroundColor Green
                }
                catch {
                    Write-Error "Failed to update note: $_"
                }
            }
            else {
                Write-Error "Note not found: $selectedNote"
            }
        }
        "3" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Green
            $notes | ForEach-Object { Write-Host " - $_" -ForegroundColor Green }
            
            Write-Host "Select note to read:" -ForegroundColor Green -NoNewline
            $selectedNote = Read-Host
            
            if (Test-Path $selectedNote) {
                Write-Host "`nContents of $selectedNote:" -ForegroundColor Green
                Get-Content $selectedNote
                Write-Host "`n" -ForegroundColor Green
            }
            else {
                Write-Error "Note not found: $selectedNote"
            }
        }
        default {
            Write-Error "Invalid option."
        }
    }
}

# Export functions
Export-ModuleMember -Function Note
