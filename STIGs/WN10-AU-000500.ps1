<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-06-26
    Last Modified   : 2025-06-26
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000500

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AU-000500.ps1 
#>
#Requires -RunAsAdministrator

# --- Configuration ---
$PolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$ValueName  = "MaxSize"
$ValueData  = 32768 # Value in Kilobytes (KB) as per STIG

# --- Script Body ---
Write-Host "Attempting to remediate STIG WN10-AU-000500..."

try {
    # Check if the registry path exists. If not, create it.
    if (-not (Test-Path -Path $PolicyPath)) {
        Write-Host "Registry path not found. Creating path: $PolicyPath"
        New-Item -Path $PolicyPath -Force | Out-Null
    }

    # Set the registry value for the maximum log size.
    Write-Host "Setting '$ValueName' to '$ValueData' KB at '$PolicyPath'."
    Set-ItemProperty -Path $PolicyPath -Name $ValueName -Value $ValueData -Type DWord -Force

    # --- Verification ---
    Write-Host "Verifying the setting..."
    $currentValue = (Get-ItemProperty -Path $PolicyPath -Name $ValueName).$ValueName

    if ($currentValue -ge $ValueData) {
        Write-Host -ForegroundColor Green "SUCCESS: Remediation complete. '$ValueName' is set to $currentValue KB."
    } else {
        Write-Error "FAILURE: Verification failed. The value is currently set to '$currentValue' KB."
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}

Write-Host "Script finished."

