<#
.SYNOPSIS
    This script sets the account lockout duration to 15 minutes or greater to comply
    with STIG WN10-AC-000005

.NOTES
    Author          : Andrey Massalskiy
    LinkedIn        : linkedin.com/in/massandr/
    GitHub          : github.com/massandr
    Date Created    : 2025-06-27
    Last Modified   : 2025-06-27
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AC-000005

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    # Requires -RunAsAdministrator
    
    # To set the duration to 15 minutes (the default)
    .\WN10-AC-000005.ps1

    # To set the duration to 30 minutes
    .\WN10-AC-000005.ps1 -LockoutDuration 30
#>


param(
    [Parameter(Mandatory=$false)]
    [ValidateRange(15, 99999)]
    [int]$LockoutDuration = 15
)

Write-Host "Attempting to remediate STIG V-220739..."

try {
    # This also requires Account lockout threshold to be set to a non-zero value.
    # We will first check and set it to a compliant value (e.g., 5) if it's currently 0.
    $CurrentThreshold = (net accounts | Select-String "Lockout threshold").ToString().Split()[-1]
    if ($CurrentThreshold -eq 'Never') {
        Write-Warning "Account lockout threshold is not set. Setting to 5 failed attempts to enable lockout duration."
        net accounts /lockoutthreshold:5
    }

    Write-Host "Setting Account Lockout Duration to $LockoutDuration minutes."
    
    # Execute the net accounts command to set the lockout duration
    net accounts /lockoutduration:$LockoutDuration
    
    # --- Verification ---
    Write-Host "Verifying the setting..."
    $CurrentDuration = (net accounts | Select-String "Lockout duration").ToString().Split()[-1]

    if ($CurrentDuration -eq $LockoutDuration) {
        Write-Host -ForegroundColor Green "SUCCESS: Account lockout duration is now set to $CurrentDuration minutes."
    } else {
        Write-Error "FAILURE: The lockout duration could not be set. Current value is $CurrentDuration."
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}

Write-Host "Script finished."
