$modulePath = Join-Path $PSScriptRoot "..\src\Modules\PerformanceDiagnostics.psm1"

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

        It "Returns a valid memory percentage" {
            $result.MemoryUsedPercent |
                Should -BeGreaterOrEqual 0

            $result.MemoryUsedPercent |
                Should -BeLessOrEqual 100
        }

        It "Returns total memory greater than zero" {
            $result.TotalMemoryGB |
                Should -BeGreaterThan 0
        }

        It "Returns valid uptime" {
            $result.UptimeDays |
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

        It "Returns MemoryMB" {
            $result = Get-ITMemoryConsumers -Top 1

            $result.MemoryMB |
                Should -BeGreaterOrEqual 0
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
}