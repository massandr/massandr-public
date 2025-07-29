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
    PS C:\> .\WN10-AU-000565.ps1 
    This script must be run with Administrator privileges.
#>


Write-Host "--- Starting STIG Fix for WN10-CC-000391 (Disable Internet Explorer 11) ---" -ForegroundColor Yellow

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main"
$valueName = "DisableIE"
$requiredValue = 1 # 1 means Enabled for the GPO, which means IE is disabled

# The GPO setting "Disable Internet Explorer 11 as a standalone browser" with "Never"
# maps to the DisableIE registry value being 1.
# There isn't a direct registry value for the "Never" option. That "Never" option
# in the GPO is implicitly handled by setting DisableIE to 1, which means IE
# is disabled *unless* explicitly called by other applications (which is the desired behavior for this STIG).

Write-Host "Checking and setting 'Disable Internet Explorer 11 as a standalone browser'..." -ForegroundColor DarkYellow

try {
    # Check if the registry path exists, create if not
    if (-not (Test-Path $registryPath)) {
        Write-Warning "Registry path '$registryPath' does not exist. Creating it."
        New-Item -Path $registryPath -Force | Out-Null
    }

    $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $valueName

    if ($currentValue -eq $null -or $currentValue -ne $requiredValue) {
        Write-Warning "Current 'DisableIE' value is '$($currentValue)'. Setting to $requiredValue (IE Disabled)."
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $requiredValue -Force -ErrorAction Stop
        Write-Host "Successfully set 'DisableIE' to $requiredValue. Internet Explorer 11 should now be disabled as a standalone browser." -ForegroundColor Green
    }
    else {
        Write-Host "'DisableIE' is already set to $requiredValue (IE Disabled)." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure 'DisableIE' registry value: $($_.Exception.Message)"
}

Write-Host "`n--- STIG Fix Script Finished ---" -ForegroundColor Yellow
Write-Host "Please note that this disables IE11 as a standalone browser. It may still be accessible via Edge's IE Mode for compatibility purposes, which is a separate configuration." -ForegroundColor Cyan


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
