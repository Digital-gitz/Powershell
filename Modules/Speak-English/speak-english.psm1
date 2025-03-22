# Text-to-speech script for PowerShell
function Invoke-Speech {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    try {
        # Load the System.Speech assembly
        Add-Type -AssemblyName System.Speech

        # Create a new speech synthesizer
        $speech = New-Object System.Speech.Synthesis.SpeechSynthesizer

        # Set the voice to English (if available)
        $voices = $speech.GetInstalledVoices()
        $englishVoice = $voices | Where-Object { $_.VoiceInfo.Culture.Name -like "en-*" } | Select-Object -First 1
        if ($englishVoice) {
            $speech.SelectVoice($englishVoice.VoiceInfo.Name)
        }

        # Speak the text
        $speech.Speak($Text)

        # Clean up
        $speech.Dispose()
    }
    catch {
        Write-Error "Failed to speak text: $_"
        return $false
    }
}

Export-ModuleMember -Function Invoke-Speech