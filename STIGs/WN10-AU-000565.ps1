<#
.SYNOPSIS
    PowerShell script to fix WN10-AU-000565: Audit Other Logon/Logoff Events Failures

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-07-27
    Last Modified   : 2025-07-27
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000565

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


Write-Host "--- Starting STIG Fix for WN10-AU-000565 (Audit Other Logon/Logoff Events Failures) ---" -ForegroundColor Yellow

# 1. Prerequisite: Ensure "Audit: Force audit policy subcategory settings..." is Enabled
# This ensures advanced audit policies are enforced.
Write-Host "Setting 'Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' to Enabled..." -ForegroundColor DarkYellow
$lsaPolicyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$lsaPolicyValueName = "SCENoApplyLegacyAuditPolicy"
$requiredLsaPolicyValue = 1 # 1 for Enabled

try {
    # Create the path if it doesn't exist
    if (-not (Test-Path $lsaPolicyPath)) {
        New-Item -Path $lsaPolicyPath -Force | Out-Null
    }
    Set-ItemProperty -Path $lsaPolicyPath -Name $lsaPolicyValueName -Value $requiredLsaPolicyValue -Force -ErrorAction Stop
    Write-Host "Prerequisite registry setting successfully configured." -ForegroundColor Green
}
catch {
    Write-Error "Failed to configure prerequisite registry setting: $($_.Exception.Message)"
    # Script will continue, but be aware of this potential issue.
}

# 2. Configure "Logon/Logoff >> Other Logon/Logoff Events" for Failure auditing
Write-Host "`nConfiguring 'Logon/Logoff >> Other Logon/Logoff Events' for Failure auditing..." -ForegroundColor DarkYellow
$subcategoryName = "Other Logon/Logoff Events"
$successSetting = "disable" # STIG only requires Failure
$failureSetting = "enable"

# Construct the auditpol command
$auditpolCommand = "auditpol /set /subcategory:`"$subcategoryName`" /success:$successSetting /failure:$failureSetting"

try {
    # Execute the auditpol command
    Write-Host "Executing: $auditpolCommand" -ForegroundColor DarkGray
    $auditResult = cmd.exe /c $auditpolCommand 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully set '$subcategoryName' to audit Failures." -ForegroundColor Green
    } else {
        Write-Error "Failed to set '$subcategoryName' audit policy. Error: $($auditResult -join "`n")"
    }
}
catch {
    Write-Error "An error occurred during audit policy configuration: $($_.Exception.Message)"
}

Write-Host "`n--- STIG Fix Script Finished ---" -ForegroundColor Yellow
Write-Host "It is recommended to run 'gpupdate /force' to ensure the policy is applied immediately." -ForegroundColor Yellow
