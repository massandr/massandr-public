<#
.SYNOPSIS
    PowerShell script to fix WN10-CC-000327: Enable PowerShell Transcription

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-07-27
    Last Modified   : 2025-07-27
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000327

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Example syntax:
    PS C:\> .\WN10-CC-000327.ps1 
    This script must be run with Administrator privileges.
#>

Write-Host "--- Starting STIG Fix for WN10-CC-000327 (Enable PowerShell Transcription) ---" -ForegroundColor Yellow

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"
$valueName = "EnableTranscripting"
$requiredValue = 1 # 1 means Enabled
$transcriptLogPathValueName = "OutputDirectory" # For the specified output directory
$recommendedLogPath = "C:\Windows\System32\LogFiles\PowerShell\Transcripts" # Example local secure path, adjust as needed or use a UNC path

# --- Step 1: Ensure PowerShell Transcription is Enabled (EnableTranscripting) ---
Write-Host "Checking and setting 'EnableTranscripting' to 1 (Enabled)..." -ForegroundColor DarkYellow

try {
    # Check if the registry path exists, create if not
    if (-not (Test-Path $registryPath)) {
        Write-Warning "Registry path '$registryPath' does not exist. Creating it."
        New-Item -Path $registryPath -Force | Out-Null
    }

    $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $valueName
    # Simplify the display of currentValue to avoid parser error
    $displayCurrentValue = if ($currentValue -eq $null) { "(Not set)" } else { "$currentValue" }

    if ($currentValue -eq $null -or $currentValue -ne $requiredValue) {
        Write-Warning "Current 'EnableTranscripting' value is '$displayCurrentValue'. Setting to $requiredValue."
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $requiredValue -Force -ErrorAction Stop
        Write-Host "Successfully set 'EnableTranscripting' to Enabled." -ForegroundColor Green
    }
    else {
        Write-Host "'EnableTranscripting' is already set to $requiredValue (Enabled)." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure 'EnableTranscripting': $($_.Exception.Message)"
}

# --- Step 2: Configure Transcript Output Directory (OutputDirectory) ---
# The STIG specifies "Specify the Transcript output directory to point to a Central Log Server or another secure location".
# This script provides an example local secure path. In a production environment,
# you would highly likely want to point this to a central log server (e.g., UNC path).
Write-Host "`nChecking and setting 'OutputDirectory' for PowerShell Transcripts..." -ForegroundColor DarkYellow
Write-Host "Recommended local path for transcripts (adjust if using a central log server): $recommendedLogPath" -ForegroundColor DarkCyan

try {
    # Ensure the local output directory exists if we are setting a local path
    if ($recommendedLogPath -notlike "\\*" -and -not (Test-Path $recommendedLogPath)) {
        Write-Warning "Recommended local transcript directory '$recommendedLogPath' does not exist. Creating it."
        New-Item -Path $recommendedLogPath -ItemType Directory -Force | Out-Null
    }

    $currentLogPath = Get-ItemProperty -Path $registryPath -Name $transcriptLogPathValueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $transcriptLogPathValueName
    # Simplify the display of currentLogPath to avoid parser error
    $displayCurrentLogPath = if ($currentLogPath -eq $null) { "(Not set)" } else { "'$currentLogPath'" }


    if ($currentLogPath -eq $null -or $currentLogPath -ne $recommendedLogPath) {
        Write-Warning "Current 'OutputDirectory' is $displayCurrentLogPath. Setting to '$recommendedLogPath'."
        Set-ItemProperty -Path $registryPath -Name $transcriptLogPathValueName -Value $recommendedLogPath -Force -ErrorAction Stop
        Write-Host "Successfully set 'OutputDirectory' to '$recommendedLogPath'." -ForegroundColor Green
    }
    else {
        Write-Host "'OutputDirectory' is already set to '$recommendedLogPath'." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure 'OutputDirectory': $($_.Exception.Message)"
}

Write-Host "`n--- STIG Fix Script Finished ---" -ForegroundColor Yellow
Write-Host "PowerShell Transcription changes may require a new PowerShell session to take full effect." -ForegroundColor Green
Write-Host "Remember to adjust the 'OutputDirectory' to a central log server if applicable for your environment." -ForegroundColor Green
