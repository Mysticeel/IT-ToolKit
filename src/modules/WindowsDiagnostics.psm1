function Get-ITPendingReboot {
    [CmdletBinding()]
    param()

    $rebootRequired = $false
    $reasons = @()

    $checks = @(
        @{
            Path   = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
            Reason = 'Component Based Servicing'
        },
        @{
            Path   = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
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
        Write-Verbose "Unable to complete this reboot-status check: $($_.Exception.Message)"
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

function Get-ITEventCorrelation {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 168)]
        [int]$Hours = 24,

        [ValidateRange(1, 500)]
        [int]$MaxEvents = 500
    )

    $events = @(
        Get-ITRecentSystemErrors `
            -Hours $Hours `
            -MaxEvents $MaxEvents
    )

    if ($events.Count -eq 0) {
        return @()
    }

    $groups = $events |
        Group-Object ProviderName, Id, LevelDisplayName

    $results = foreach ($group in $groups) {
        $groupEvents = @(
            $group.Group |
                Sort-Object TimeCreated
        )

        $firstEvent = $groupEvents[0]
        $lastEvent = $groupEvents[-1]

        [PSCustomObject]@{
            ProviderName = $firstEvent.ProviderName
            EventId      = $firstEvent.Id
            Level        = $firstEvent.LevelDisplayName
            Count        = $group.Count
            FirstSeen    = $firstEvent.TimeCreated
            LastSeen     = $lastEvent.TimeCreated
        }
    }

    $results |
        Sort-Object `
            @{ Expression = 'Count'; Descending = $true },
            @{ Expression = 'LastSeen'; Descending = $true }
}

Export-ModuleMember -Function @(
    'Get-ITPendingReboot',
    'Get-ITServiceHealth',
    'Get-ITRecentSystemErrors',
    'Get-ITEventCorrelation'
)