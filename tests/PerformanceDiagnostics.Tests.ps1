$modulePath = Join-Path $PSScriptRoot "..\src\modules\PerformanceDiagnostics.psm1"

Import-Module $modulePath -Force


Describe "PerformanceDiagnostics Module" {

    Context "Module structure" {

        It "Exports Get-ITPerformanceSnapshot" {
            Get-Command Get-ITPerformanceSnapshot -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITTopProcesses" {
            Get-Command Get-ITTopProcesses -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITMemoryConsumers" {
            Get-Command Get-ITMemoryConsumers -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITStartupItems" {
            Get-Command Get-ITStartupItems -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITPerformanceSample" {
            Get-Command Get-ITPerformanceSample -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITProcessDetails" {
            Get-Command Get-ITProcessDetails -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }


    Context "Performance snapshot" {

        BeforeAll {
            $result = Get-ITPerformanceSnapshot
        }

        It "Returns a performance snapshot" {
            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Returns CPU usage" {
            $result.CPUUsagePercent |
                Should -BeGreaterOrEqual 0
        }

        It "Returns CPU usage no greater than 100" {
            $result.CPUUsagePercent |
                Should -BeLessOrEqual 100
        }

        It "Returns total memory greater than zero" {
            $result.TotalMemoryGB |
                Should -BeGreaterThan 0
        }

        It "Returns a valid memory percentage" {
            $result.MemoryUsedPercent |
                Should -BeGreaterOrEqual 0

            $result.MemoryUsedPercent |
                Should -BeLessOrEqual 100
        }

        It "Returns valid uptime" {
            $result.UptimeDays |
                Should -BeGreaterOrEqual 0

            $result.UptimeHours |
                Should -BeGreaterOrEqual 0
        }
    }


    Context "Top CPU processes" {

        It "Returns processes" {
            $result = Get-ITTopProcesses -Top 5

            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Returns no more than the requested number" {
            $result = @(Get-ITTopProcesses -Top 5)

            $result.Count |
                Should -BeLessOrEqual 5
        }

        It "Returns expected properties" {
            $result = Get-ITTopProcesses -Top 1

            $result.PSObject.Properties.Name |
                Should -Contain 'ProcessName'

            $result.PSObject.Properties.Name |
                Should -Contain 'Id'

            $result.PSObject.Properties.Name |
                Should -Contain 'CPU'

            $result.PSObject.Properties.Name |
                Should -Contain 'WorkingSet64'

            $result.PSObject.Properties.Name |
                Should -Contain 'Handles'
        }

        It "Rejects Top greater than 50" {
            {
                Get-ITTopProcesses -Top 51
            } | Should -Throw
        }

        It "Rejects Top below 1" {
            {
                Get-ITTopProcesses -Top 0
            } | Should -Throw
        }
    }


    Context "Memory consumers" {

        It "Returns processes" {
            $result = Get-ITMemoryConsumers -Top 5

            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Returns no more than the requested number" {
            $result = @(Get-ITMemoryConsumers -Top 5)

            $result.Count |
                Should -BeLessOrEqual 5
        }

        It "Returns MemoryMB" {
            $result = Get-ITMemoryConsumers -Top 1

            $result.MemoryMB |
                Should -BeGreaterOrEqual 0
        }

        It "Returns expected properties" {
            $result = Get-ITMemoryConsumers -Top 1

            $result.PSObject.Properties.Name |
                Should -Contain 'ProcessName'

            $result.PSObject.Properties.Name |
                Should -Contain 'Id'

            $result.PSObject.Properties.Name |
                Should -Contain 'MemoryMB'

            $result.PSObject.Properties.Name |
                Should -Contain 'Handles'
        }

        It "Rejects Top greater than 50" {
            {
                Get-ITMemoryConsumers -Top 51
            } | Should -Throw
        }

        It "Rejects Top below 1" {
            {
                Get-ITMemoryConsumers -Top 0
            } | Should -Throw
        }
    }


    Context "Startup items" {

        It "Runs without throwing" {
            {
                Get-ITStartupItems
            } | Should -Not -Throw
        }
    }


    Context "Live performance sampling" {

        BeforeAll {
            $sample = Get-ITPerformanceSample `
                -Samples 2 `
                -IntervalSeconds 1
        }

        It "Returns a performance sample result" {
            $sample |
                Should -Not -BeNullOrEmpty
        }

        It "Returns the requested sample count" {
            $sample.SampleCount |
                Should -Be 2
        }

        It "Returns the requested interval" {
            $sample.IntervalSeconds |
                Should -Be 1
        }

        It "Contains exactly the requested number of samples" {
            @($sample.Samples).Count |
                Should -Be 2
        }

        It "Returns a valid CPU average" {
            $sample.CPUAveragePercent |
                Should -BeGreaterOrEqual 0

            $sample.CPUAveragePercent |
                Should -BeLessOrEqual 100
        }

        It "Returns a valid CPU peak" {
            $sample.CPUPeakPercent |
                Should -BeGreaterOrEqual 0

            $sample.CPUPeakPercent |
                Should -BeLessOrEqual 100
        }

        It "Returns a valid memory average" {
            $sample.MemoryAveragePercent |
                Should -BeGreaterOrEqual 0

            $sample.MemoryAveragePercent |
                Should -BeLessOrEqual 100
        }

        It "Returns a valid memory peak" {
            $sample.MemoryPeakPercent |
                Should -BeGreaterOrEqual 0

            $sample.MemoryPeakPercent |
                Should -BeLessOrEqual 100
        }

        It "CPU peak is greater than or equal to CPU average" {
            $sample.CPUPeakPercent |
                Should -BeGreaterOrEqual $sample.CPUAveragePercent
        }

        It "Memory peak is greater than or equal to memory average" {
            $sample.MemoryPeakPercent |
                Should -BeGreaterOrEqual $sample.MemoryAveragePercent
        }

        It "Each sample contains the expected properties" {
            foreach ($entry in $sample.Samples) {

                $entry.PSObject.Properties.Name |
                    Should -Contain 'Sample'

                $entry.PSObject.Properties.Name |
                    Should -Contain 'Timestamp'

                $entry.PSObject.Properties.Name |
                    Should -Contain 'CPUUsagePercent'

                $entry.PSObject.Properties.Name |
                    Should -Contain 'MemoryUsedPercent'
            }
        }

        It "Rejects fewer than 2 samples" {
            {
                Get-ITPerformanceSample -Samples 1
            } | Should -Throw
        }

        It "Rejects more than 60 samples" {
            {
                Get-ITPerformanceSample -Samples 61
            } | Should -Throw
        }

        It "Rejects intervals below 1 second" {
            {
                Get-ITPerformanceSample `
                    -Samples 2 `
                    -IntervalSeconds 0
            } | Should -Throw
        }

        It "Rejects intervals greater than 10 seconds" {
            {
                Get-ITPerformanceSample `
                    -Samples 2 `
                    -IntervalSeconds 11
            } | Should -Throw
        }
    }


    Context "Process details" {

        BeforeAll {
            $currentProcess = Get-Process -Id $PID

            $details = Get-ITProcessDetails `
                -Id $currentProcess.Id
        }

        It "Returns process details for an existing process" {
            $details |
                Should -Not -BeNullOrEmpty
        }

        It "Returns the requested process ID" {
            $details.Id |
                Should -Be $PID
        }

        It "Returns a process name" {
            $details.ProcessName |
                Should -Not -BeNullOrEmpty
        }

        It "Returns memory usage" {
            $details.MemoryMB |
                Should -BeGreaterOrEqual 0
        }

        It "Returns a handle count" {
            $details.Handles |
                Should -BeGreaterOrEqual 0
        }

        It "Returns a thread count" {
            $details.Threads |
                Should -BeGreaterOrEqual 0
        }

        It "Returns an Error property" {
            $details.PSObject.Properties.Name |
                Should -Contain 'Error'
        }

        It "Returns no error for the current process" {
            $details.Error |
                Should -BeNullOrEmpty
        }

        It "Returns a structured error for a missing process" {
            $missingProcessId = 2147483647

            $missing = Get-ITProcessDetails `
                -Id $missingProcessId

            $missing.Id |
                Should -Be $missingProcessId

            $missing.Error |
                Should -Not -BeNullOrEmpty
        }

        It "Rejects process ID zero" {
            {
                Get-ITProcessDetails -Id 0
            } | Should -Throw
        }
    }
}