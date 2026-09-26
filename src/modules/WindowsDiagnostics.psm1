function Get-ITPendingReboot {
    [CmdletBinding()]
    param()

    $rebootRequired = $false
    $reasons = @()

    $checks = @(
        @{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
            Reason = 'Component Based Servicing'
        },
        @{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
            Reason = 'Windows Update'
        }
    )

    foreach ($check in $checks) {
        if (Test-Path $check.Path) {
            $rebootRequired = $true
            $reasons += $check.Reason
        }
    }

    try {
        $pendingFileRename = Get-ItemProperty `
            'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
            -Name PendingFileRenameOperations `
            -ErrorAction Stop

        if ($pendingFileRename.PendingFileRenameOperations) {
            $rebootRequired = $true
            $reasons += 'Pending File Rename Operations'
        }
    }
    catch {
        # No pending file rename value found
    }

    [PSCustomObject]@{
        RebootRequired = $rebootRequired
        Reasons        = $reasons -join ', '
    }
}


function Get-ITServiceHealth {
    [CmdletBinding()]
    param()

    Get-Service |
        Where-Object {
            $_.StartType -eq 'Automatic' -and
            $_.Status -ne 'Running'
        } |
        Select-Object Name, DisplayName, Status, StartType
}


function Get-ITRecentSystemErrors {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 168)]
        [int]$Hours = 24,

        [ValidateRange(1, 500)]
        [int]$MaxEvents = 50
    )

    $startTime = (Get-Date).AddHours(-$Hours)

    Get-WinEvent `
        -FilterHashtable @{
            LogName   = 'System'
            Level     = 1, 2
            StartTime = $startTime
        } `
        -ErrorAction SilentlyContinue |
        Select-Object -First $MaxEvents `
            TimeCreated,
            Id,
            LevelDisplayName,
            ProviderName,
            Message
}


Export-ModuleMember -Function @(
    'Get-ITPendingReboot',
    'Get-ITServiceHealth',
    'Get-ITRecentSystemErrors'
)