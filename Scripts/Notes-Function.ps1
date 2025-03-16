# Utilities.ps1

function Note {
    param(
        [Parameter(Position = 0)]
        [ValidateSet('new', 'add', 'read', 'list', 'delete', 'open')]
        [string]$Action
    )

    # Create notes directory if it doesn't exist
    $notesDir = Join-Path (Get-Location) "notes"
    if (-not (Test-Path $notesDir)) {
        New-Item -ItemType Directory -Path $notesDir | Out-Null
    }

    # Get all notes
    $notes = Get-ChildItem -Filter "*.txt" -Path $notesDir

    # Show menu if no action specified
    if (-not $Action) {
        Write-Host "`nNote Management:" -ForegroundColor Cyan
        Write-Host "1. Create new note" -ForegroundColor White
        Write-Host "2. Add to existing note" -ForegroundColor White
        Write-Host "3. Read existing note" -ForegroundColor White
        Write-Host "4. List all notes" -ForegroundColor White
        Write-Host "5. Delete note" -ForegroundColor White
        Write-Host "6. Open note in default editor" -ForegroundColor White
        Write-Host "7. Exit" -ForegroundColor White
        
        $choice = Read-Host "`nSelect an option (1-7)"
        
        switch ($choice) {
            "1" { $Action = "new" }
            "2" { $Action = "add" }
            "3" { $Action = "read" }
            "4" { $Action = "list" }
            "5" { $Action = "delete" }
            "6" { $Action = "open" }
            "7" { return }
            default { 
                Write-Host "Invalid option. Please try again." -ForegroundColor Red
                return
            }
        }
    }

    switch ($Action.ToLower()) {
        "new" {
            do {
                $noteName = Read-Host "Enter note name (without .txt)"
                if ([string]::IsNullOrWhiteSpace($noteName)) {
                    Write-Host "Note name cannot be empty." -ForegroundColor Yellow
                    continue
                }
                break
            } while ($true)

            $notePath = Join-Path $notesDir "$noteName.txt"
            
            if (Test-Path $notePath) {
                Write-Host "Note already exists. Use 'add' to append content." -ForegroundColor Yellow
                return
            }

            Write-Host "Enter note content (press Ctrl+Z and Enter when done):"
            $newNote = @()
            while ($line = Read-Host) {
                $newNote += $line
            }
            
            try {
                $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $newNoteContent = "[$currentDateTime]`n$($newNote -join "`n")`n"
                Set-Content -Path $notePath -Value $newNoteContent
                Write-Host "Note created successfully: $noteName.txt" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to create note: $_" -ForegroundColor Red
            }
        }

        "add" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to update (without .txt)"
            $notePath = Join-Path $notesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                Write-Host "Enter additional content (press Ctrl+Z and Enter when done):"
                $additionalText = @()
                while ($line = Read-Host) {
                    $additionalText += $line
                }
                
                try {
                    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $appendContent = "`n[$currentDateTime]`n$($additionalText -join "`n")"
                    Add-Content -Path $notePath -Value $appendContent
                    Write-Host "Note updated successfully: $selectedNote.txt" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to update note: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "read" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to read (without .txt)"
            $notePath = Join-Path $notesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                Write-Host "`nContents of '$selectedNote.txt':`n" -ForegroundColor Cyan
                Get-Content $notePath | ForEach-Object {
                    if ($_ -match '^\[\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\]$') {
                        Write-Host $_ -ForegroundColor Yellow
                    } else {
                        Write-Host $_
                    }
                }
                Write-Host ""
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "list" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nAvailable notes:" -ForegroundColor Cyan
            $notes | ForEach-Object {
                $lastWriteTime = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                $size = [math]::Round($_.Length / 1KB, 2)
                Write-Host "$($_.Name)" -ForegroundColor White
                Write-Host "  Last modified: $lastWriteTime" -ForegroundColor Gray
                Write-Host "  Size: $size KB" -ForegroundColor Gray
            }
            Write-Host ""
        }

        "delete" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to delete (without .txt)"
            $notePath = Join-Path $notesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                $confirmation = Read-Host "Are you sure you want to delete '$selectedNote.txt'? (y/n)"
                if ($confirmation -eq 'y') {
                    try {
                        Remove-Item $notePath
                        Write-Host "Note deleted successfully: $selectedNote.txt" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Failed to delete note: $_" -ForegroundColor Red
                    }
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }

        "open" {
            if ($notes.Count -eq 0) {
                Write-Host "No notes found." -ForegroundColor Yellow
                return
            }
            
            Write-Host "`nExisting notes:" -ForegroundColor Cyan
            $notes | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor White }
            
            $selectedNote = Read-Host "`nSelect note to open (without .txt)"
            $notePath = Join-Path $notesDir "$selectedNote.txt"
            
            if (Test-Path $notePath) {
                try {
                    Start-Process $notePath
                    Write-Host "Opening note in default editor: $selectedNote.txt" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to open note: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Note not found: $selectedNote.txt" -ForegroundColor Red
            }
        }
    }
}
