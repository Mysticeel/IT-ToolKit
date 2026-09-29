function Get-ITPerformanceSnapshot {
    [CmdletBinding()]
    param()

    $os = Get-CimInstance Win32_OperatingSystem

    $cpu = Get-CimInstance Win32_Processor |
        Measure-Object `
            -Property LoadPercentage `
            -Average

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
        CPUUsagePercent   = [math]::Round(
            $cpu.Average,
            1
        )

        TotalMemoryGB     = $totalMemoryGB
        UsedMemoryGB      = $usedMemoryGB
        FreeMemoryGB      = $freeMemoryGB
        MemoryUsedPercent = $memoryUsedPercent
        UptimeDays        = $uptime.Days
        UptimeHours       = $uptime.Hours
    }
}


function Get-ITTopProcesses {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 50)]
        [int]$Top = 10
    )

    Get-Process |
        Sort-Object `
            -Property CPU `
            -Descending |
        Select-Object `
            -First $Top `
            -Property `
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
        Sort-Object `
            -Property WorkingSet64 `
            -Descending |
        Select-Object `
            -First $Top `
            -Property `
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

        $items += Get-CimInstance `
            -ClassName Win32_StartupCommand `
            -ErrorAction Stop |
            Select-Object `
                Name,
                Command,
                Location,
                User
    }
    catch {

        Write-Verbose `
            "Unable to query Win32_StartupCommand: $($_.Exception.Message)"
    }

    return $items
}


function Get-ITPerformanceSample {
    [CmdletBinding()]
    param(
        [ValidateRange(2, 60)]
        [int]$Samples = 10,

        [ValidateRange(1, 10)]
        [int]$IntervalSeconds = 1
    )

    $results = @()

    for (
        $i = 1
        $i -le $Samples
        $i++
    ) {

        $snapshot = Get-ITPerformanceSnapshot

        $results += [PSCustomObject]@{
            Sample            = $i
            Timestamp         = Get-Date
            CPUUsagePercent   = $snapshot.CPUUsagePercent
            MemoryUsedPercent = $snapshot.MemoryUsedPercent
        }

        if ($i -lt $Samples) {

            Start-Sleep `
                -Seconds $IntervalSeconds
        }
    }


    $cpuAverage = [math]::Round(
        (
            $results |
                Measure-Object `
                    -Property CPUUsagePercent `
                    -Average
        ).Average,
        1
    )


    $cpuPeak = [math]::Round(
        (
            $results |
                Measure-Object `
                    -Property CPUUsagePercent `
                    -Maximum
        ).Maximum,
        1
    )


    $memoryAverage = [math]::Round(
        (
            $results |
                Measure-Object `
                    -Property MemoryUsedPercent `
                    -Average
        ).Average,
        1
    )


    $memoryPeak = [math]::Round(
        (
            $results |
                Measure-Object `
                    -Property MemoryUsedPercent `
                    -Maximum
        ).Maximum,
        1
    )


    [PSCustomObject]@{
        SampleCount          = $Samples
        IntervalSeconds      = $IntervalSeconds
        CPUAveragePercent    = $cpuAverage
        CPUPeakPercent       = $cpuPeak
        MemoryAveragePercent = $memoryAverage
        MemoryPeakPercent    = $memoryPeak
        Samples              = @($results)
    }
}


function Get-ITProcessDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int]$Id
    )

    try {

        $process = Get-Process `
            -Id $Id `
            -ErrorAction Stop

        $cimProcess = Get-CimInstance `
            -ClassName Win32_Process `
            -Filter "ProcessId = $Id" `
            -ErrorAction SilentlyContinue


        $startTime = try {

            $process.StartTime
        }
        catch {

            $null
        }


        $path = try {

            $process.Path
        }
        catch {

            $null
        }


        [PSCustomObject]@{
            ProcessName = $process.ProcessName
            Id          = $process.Id

            CPUTimeSeconds = if (
                $null -ne $process.CPU
            ) {

                [math]::Round(
                    $process.CPU,
                    2
                )
            }
            else {

                0
            }

            MemoryMB = [math]::Round(
                $process.WorkingSet64 / 1MB,
                2
            )

            Handles         = $process.Handles
            Threads         = $process.Threads.Count
            StartTime       = $startTime
            Path            = $path
            CommandLine     = $cimProcess.CommandLine
            ParentProcessId = $cimProcess.ParentProcessId
            Error           = $null
        }
    }
    catch {

        [PSCustomObject]@{
            ProcessName     = $null
            Id              = $Id
            CPUTimeSeconds  = $null
            MemoryMB        = $null
            Handles         = $null
            Threads         = $null
            StartTime       = $null
            Path            = $null
            CommandLine     = $null
            ParentProcessId = $null
            Error           = $_.Exception.Message
        }
    }
}


Export-ModuleMember -Function @(
    'Get-ITPerformanceSnapshot',
    'Get-ITTopProcesses',
    'Get-ITMemoryConsumers',
    'Get-ITStartupItems',
    'Get-ITPerformanceSample',
    'Get-ITProcessDetails'
)