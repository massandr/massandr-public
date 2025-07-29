<#
.SYNOPSIS
    PowerShell script to fix WN10-CC-000370: Convenience PIN sign-in must be disabled.

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-07-29
    Last Modified   : 2025-07-29
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000370

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Example syntax:
    PS C:\> .\WN10-CC-000370.ps1 
    This script must be run with Administrator privileges.
#>


Write-Host "--- Starting STIG Fix for WN10-CC-000370 (Disable Convenience PIN Sign-in) ---" -ForegroundColor Yellow

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$valueName = "AllowDomainPINLogon"
$requiredValue = 0 # 0 means Disabled (for "Turn on convenience PIN sign-in" GPO setting)

Write-Host "Checking and setting 'Turn on convenience PIN sign-in' to Disabled..." -ForegroundColor DarkYellow

try {
    # Check if the registry path exists, create it if it doesn't
    if (-not (Test-Path $registryPath)) {
        Write-Warning "Registry path '$registryPath' does not exist. Creating it."
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get the current value of AllowDomainPINLogon
    $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $valueName
    # Format current value for display in messages
    $displayCurrentValue = if ($currentValue -eq $null) { "(Not set or Defaulted)" } else { "$currentValue" }

    # Compare current value to required value and set if necessary
    if ($currentValue -eq $null -or $currentValue -ne $requiredValue) {
        Write-Warning "Current 'AllowDomainPINLogon' value is '$displayCurrentValue'. Setting to $requiredValue (PIN Sign-in Disabled)."
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $requiredValue -Force -ErrorAction Stop
        Write-Host "Successfully set 'AllowDomainPINLogon' to $requiredValue. Convenience PIN sign-in should now be disabled." -ForegroundColor Green
    }
    else {
        Write-Host "'AllowDomainPINLogon' is already set to $requiredValue (PIN Sign-in Disabled)." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure 'AllowDomainPINLogon' registry value: $($_.Exception.Message)"
}

Write-Host "`n--- STIG Fix Script Finished ---" -ForegroundColor Yellow
Write-Host "A reboot may be required for this change to take full effect on login options." -ForegroundColor Cyan
Write-Host "For enterprise deployment, it is highly recommended to manage this setting via Group Policy." -ForegroundColor Cyan
