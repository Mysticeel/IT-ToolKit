function Get-ITPerformanceSnapshot {
    [CmdletBinding()]
    param()

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor |
        Measure-Object -Property LoadPercentage -Average

    $totalMemoryGB = [math]::Round(
        $os.TotalVisibleMemorySize / 1MB,
        2
    )

    $freeMemoryGB = [math]::Round(
        $os.FreePhysicalMemory / 1MB,
        2
    )

    $usedMemoryGB = [math]::Round(
        $totalMemoryGB - $freeMemoryGB,
        2
    )

    $memoryUsedPercent = if ($totalMemoryGB -gt 0) {
        [math]::Round(
            ($usedMemoryGB / $totalMemoryGB) * 100,
            1
        )
    }
    else {
        0
    }

    $uptime = (Get-Date) - $os.LastBootUpTime

    [PSCustomObject]@{
        CPUUsagePercent    = [math]::Round($cpu.Average, 1)
        TotalMemoryGB      = $totalMemoryGB
        UsedMemoryGB       = $usedMemoryGB
        FreeMemoryGB       = $freeMemoryGB
        MemoryUsedPercent  = $memoryUsedPercent
        UptimeDays         = $uptime.Days
        UptimeHours        = $uptime.Hours
    }
}


function Get-ITTopProcesses {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 50)]
        [int]$Top = 10
    )

    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First $Top `
            ProcessName,
            Id,
            CPU,
            WorkingSet64,
            Handles
}


function Get-ITMemoryConsumers {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 50)]
        [int]$Top = 10
    )

    Get-Process |
        Sort-Object WorkingSet64 -Descending |
        Select-Object -First $Top `
            ProcessName,
            Id,
            @{
                Name = 'MemoryMB'
                Expression = {
                    [math]::Round(
                        $_.WorkingSet64 / 1MB,
                        2
                    )
                }
            },
            Handles
}


function Get-ITStartupItems {
    [CmdletBinding()]
    param()

    $items = @()

    try {
        $items += Get-CimInstance Win32_StartupCommand |
            Select-Object `
                Name,
                Command,
                Location,
                User
    }
    catch {
        Write-Verbose "Unable to query Win32_StartupCommand."
    }

    return $items
}


Export-ModuleMember -Function @(
    'Get-ITPerformanceSnapshot',
    'Get-ITTopProcesses',
    'Get-ITMemoryConsumers',
    'Get-ITStartupItems'
)