<#
.SYNOPSIS
    PowerShell script to fix WN10-CC-000391: Disable Internet Explorer for Windows 10

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-07-28
    Last Modified   : 2025-07-28
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000391

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Example syntax:
    PS C:\> .\WWN10-CC-000391.ps1 
    This script must be run with Administrator privileges.
#>
# Requires -RunAsAdministrator

# PowerShell script to fix WN10-CC-000391: Disable Internet Explorer for Windows 10
# Also includes common fix for Tenable IPC$ connection issues for local admin accounts

Write-Host "--- Starting STIG Fix for WN10-CC-000391 (Disable Internet Explorer 11) ---" -ForegroundColor Yellow

# --- Common Fix for Tenable IPC$ connection issues (if using local admin account) ---
# This helps Tenable perform credentialed checks reliably.
Write-Host "Configuring 'LocalAccountTokenFilterPolicy' to allow remote admin access for local accounts..." -ForegroundColor DarkCyan
$systemPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$tokenFilterValueName = "LocalAccountTokenFilterPolicy"
$requiredTokenFilterValue = 1

try {
    if (-not (Test-Path $systemPolicyPath)) {
        New-Item -Path $systemPolicyPath -Force | Out-Null
    }
    Set-ItemProperty -Path $systemPolicyPath -Name $tokenFilterValueName -Value $requiredTokenFilterValue -Force -ErrorAction Stop
    Write-Host "Successfully set 'LocalAccountTokenFilterPolicy' to 1." -ForegroundColor Green
    Write-Host "NOTE: A reboot might be required for this change to take full effect on remote access." -ForegroundColor DarkGreen
}
catch {
    Write-Error "Failed to configure 'LocalAccountTokenFilterPolicy': $($_.Exception.Message)"
}


# --- Configure IE11 Disable Settings ---
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main"
$disableIEValueName = "DisableIE"
$requiredDisableIEValue = 1 # 1 means Enabled for the GPO, which means IE is disabled
$notifyValueName = "NotifyDisableIEOptions"
$requiredNotifyValue = 0 # 0 means Do not display a warning message (for the "Never" option in GPO)

Write-Host "`nChecking and setting 'Disable Internet Explorer 11 as a standalone browser'..." -ForegroundColor DarkYellow

try {
    # Check if the registry path exists, create if not
    if (-not (Test-Path $registryPath)) {
        Write-Warning "Registry path '$registryPath' does not exist. Creating it."
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Configure DisableIE
    $currentDisableIEValue = Get-ItemProperty -Path $registryPath -Name $disableIEValueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $disableIEValueName
    $displayCurrentDisableIEValue = if ($currentDisableIEValue -eq $null) { "(Not set)" } else { "$currentDisableIEValue" }

    if ($currentDisableIEValue -eq $null -or $currentDisableIEValue -ne $requiredDisableIEValue) {
        Write-Warning "Current 'DisableIE' value is '$displayCurrentDisableIEValue'. Setting to $requiredDisableIEValue (IE Disabled)."
        Set-ItemProperty -Path $registryPath -Name $disableIEValueName -Value $requiredDisableIEValue -Force -ErrorAction Stop
        Write-Host "Successfully set 'DisableIE' to $requiredDisableIEValue." -ForegroundColor Green
    }
    else {
        Write-Host "'DisableIE' is already set to $requiredDisableIEValue (IE Disabled)." -ForegroundColor Green
    }

    # Configure NotifyDisableIEOptions
    $currentNotifyValue = Get-ItemProperty -Path $registryPath -Name $notifyValueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $notifyValueName
    $displayCurrentNotifyValue = if ($currentNotifyValue -eq $null) { "(Not set)" } else { "$currentNotifyValue" }

    if ($currentNotifyValue -eq $null -or $currentNotifyValue -ne $requiredNotifyValue) {
        Write-Warning "Current 'NotifyDisableIEOptions' value is '$displayCurrentNotifyValue'. Setting to $requiredNotifyValue (No warning)."
        Set-ItemProperty -Path $registryPath -Name $notifyValueName -Value $requiredNotifyValue -Force -ErrorAction Stop
        Write-Host "Successfully set 'NotifyDisableIEOptions' to $requiredNotifyValue." -ForegroundColor Green
    }
    else {
        Write-Host "'NotifyDisableIEOptions' is already set to $requiredNotifyValue (No warning)." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure IE disable registry values: $($_.Exception.Message)"
}

Write-Host "`n--- STIG Fix Script Finished ---" -ForegroundColor Yellow
Write-Host "Please note that this disables IE11 as a standalone browser. It may still be accessible via Edge's IE Mode for compatibility purposes, which is a separate configuration." -ForegroundColor Cyan
Write-Host "If you configured 'LocalAccountTokenFilterPolicy', a reboot might be necessary for Tenable to connect properly." -ForegroundColor Cyan
<#
Explanation:

1. Requires -RunAsAdministrator: Modifying HKEY_LOCAL_MACHINE requires elevated privileges.

2. Registry Path and Value:

  - $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main": This is the exact registry path where the GPO setting "Disable Internet Explorer 11 as a standalone browser" gets applied.

  - $valueName = "DisableIE": This is the specific REG_DWORD value name that controls whether IE is disabled as a standalone browser.

  - $requiredValue = 1: A value of 1 for DisableIE corresponds to the GPO setting being "Enabled," which effectively disables IE11 as a standalone browser.

3. Check and Set Logic:

  - The script first checks if the registry path exists and creates it if it doesn't.

  - It then attempts to read the current DisableIE value.

  - If the value is not set ($null) or if it's not equal to the $requiredValue (1), it sets the value to 1.

  - Informative Write-Host messages are used to indicate the status of the configuration.

4. Error Handling (try...catch): Provides basic error handling if the registry operation fails.

5. Important Note on IE Mode: The final Write-Host message reminds you that this STIG specifically targets disabling IE11 as a standalone browser. It does not disable IE Mode within Microsoft Edge. IE Mode is a separate feature for compatibility and typically allowed or even required in some enterprise environments. The STIG is concerned with the standalone application's presence.
#>
