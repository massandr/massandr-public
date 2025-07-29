<#
.SYNOPSIS
    PowerShell script to fix WN10-00-000107: Copilot in Windows must be disabled.

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-07-29
    Last Modified   : 2025-07-29
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-00-000107

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Example syntax:
    PS C:\> .\WN10-AU-000565.ps1 
    This script must be run with Administrator privileges.
#>



Write-Host "--- Starting STIG Fix for WN10-00-000107 (Disable Windows Copilot) ---" -ForegroundColor Yellow

# Registry path and value for "Turn off Windows Copilot" policy
$registryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
$valueName = "TurnOffWindowsCopilot"
$requiredValue = 1 # 1 means Copilot is disabled (as per "Enabled" in GPO for "Turn off Windows Copilot")

Write-Host "Checking and setting 'Turn off Windows Copilot' to Enabled (which disables Copilot)..." -ForegroundColor DarkYellow
Write-Host "NOTE: This script modifies settings for the currently logged-in user." -ForegroundColor Cyan

try {
    # Check if the registry path exists, create it if it doesn't
    if (-not (Test-Path $registryPath)) {
        Write-Warning "Registry path '$registryPath' does not exist. Creating it."
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get the current value of TurnOffWindowsCopilot
    $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $valueName
    # Format current value for display in messages
    $displayCurrentValue = if ($currentValue -eq $null) { "(Not set or Defaulted)" } else { "$currentValue" }

    # Compare current value to required value and set if necessary
    if ($currentValue -eq $null -or $currentValue -ne $requiredValue) {
        Write-Warning "Current 'TurnOffWindowsCopilot' value is '$displayCurrentValue'. Setting to $requiredValue (Copilot Disabled)."
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $requiredValue -Force -ErrorAction Stop
        Write-Host "Successfully set 'TurnOffWindowsCopilot' to $requiredValue. Windows Copilot should now be disabled." -ForegroundColor Green
    }
    else {
        Write-Host "'TurnOffWindowsCopilot' is already set to $requiredValue (Copilot Disabled)." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure 'TurnOffWindowsCopilot' registry value: $($_.Exception.Message)"
}

Write-Host "`n--- STIG Fix Script Finished ---" -ForegroundColor Yellow
Write-Host "For changes to take full effect, you may need to log off and log back on, or restart Windows Explorer (explorer.exe)." -ForegroundColor Cyan
Write-Host "For enterprise deployment, it is highly recommended to manage this setting via Group Policy." -ForegroundColor Cyan

