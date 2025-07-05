<#
.SYNOPSIS
    Remediates STIG V-220925 by requiring SMB client packet signing.
.DESCRIPTION
    This script configures the Windows SMB client to always perform SMB packet signing
    by setting the 'RequireSecuritySignature' registry value to 1.

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-07-05
    Last Modified   : 2025-07-05
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000100

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Example syntax:
    PS C:\> .\WN10-SO-000100.ps1 
#>
#Requires -RunAsAdministrator


# --- Configuration ---
$RegPath   = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$ValueName = "RequireSecuritySignature"
$ValueData = 1
$ValueType = "DWord"

# --- Script Body ---
Write-Host "Attempting to remediate STIG V-220925..."
Write-Host "Configuring SMB client to require security signatures."

try {
    # Set the registry value to enforce SMB packet signing
    Set-ItemProperty -Path $RegPath -Name $ValueName -Value $ValueData -Type $ValueType -Force

    # --- Verification ---
    Write-Host "Verifying the setting..."
    $currentValue = (Get-ItemProperty -Path $RegPath -Name $ValueName).$ValueName

    if ($currentValue -eq $ValueData) {
        Write-Host -ForegroundColor Green "✅ SUCCESS: Remediation complete. '$ValueName' is set to '$currentValue'."
    } else {
        Write-Error "❌ FAILURE: Verification failed. The value is currently set to '$currentValue'."
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}

Write-Host "Script finished. Please reboot."
