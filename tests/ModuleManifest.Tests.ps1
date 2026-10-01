Describe "IT-Toolkit Module Manifest" {
    BeforeAll {
        $manifestPath = Join-Path $PSScriptRoot "..\src\IT-Toolkit.psd1"
        $manifestPath = [System.IO.Path]::GetFullPath($manifestPath)
    }

    Context "Manifest validation" {
        It "Manifest exists" {
            Test-Path -LiteralPath $manifestPath |
                Should -BeTrue
        }

        It "Manifest is valid" {
            {
                Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
            } | Should -Not -Throw
        }

        It "Module version is 1.1.0" {
            $manifest = Test-ModuleManifest -Path $manifestPath

            $manifest.Version.ToString() |
                Should -Be '1.1.0'
        }

        It "Has the expected module name" {
            $manifest = Test-ModuleManifest -Path $manifestPath

            $manifest.Name |
                Should -Be 'IT-Toolkit'
        }
    }

    Context "Module import" {
        BeforeAll {
            Remove-Module -Name IT-Toolkit -Force -ErrorAction SilentlyContinue
            Import-Module -Name $manifestPath -Force -ErrorAction Stop
        }

        AfterAll {
            Remove-Module -Name IT-Toolkit -Force -ErrorAction SilentlyContinue
        }

        It "Imports successfully" {
            Get-Module -Name IT-Toolkit |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITSystemInformation" {
            Get-Command -Name Get-ITSystemInformation -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITHealthAnalysis" {
            Get-Command -Name Get-ITHealthAnalysis -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITPerformanceSample" {
            Get-Command -Name Get-ITPerformanceSample -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITProcessDetails" {
            Get-Command -Name Get-ITProcessDetails -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITEventCorrelation" {
            Get-Command -Name Get-ITEventCorrelation -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITServiceDependency" {
            Get-Command -Name Get-ITServiceDependency -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Export-ITDiagnosticReportCsv" {
            Get-Command -Name Export-ITDiagnosticReportCsv -Module IT-Toolkit -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Public command surface" {
        BeforeAll {
            Remove-Module -Name IT-Toolkit -Force -ErrorAction SilentlyContinue
            Import-Module -Name $manifestPath -Force -ErrorAction Stop

            $commands = @(
                Get-Command -Module IT-Toolkit
            )
        }

        AfterAll {
            Remove-Module -Name IT-Toolkit -Force -ErrorAction SilentlyContinue
        }

        It "Exports commands" {
            $commands.Count |
                Should -BeGreaterThan 0
        }

        It "Exports no aliases" {
            @(
                $commands |
                    Where-Object {
                        $_.CommandType -eq 'Alias'
                    }
            ).Count |
                Should -Be 0
        }

        It "Exports no compiled cmdlets" {
            @(
                $commands |
                    Where-Object {
                        $_.CommandType -eq 'Cmdlet'
                    }
            ).Count |
                Should -Be 0
        }

        It "Exports exactly 28 public functions" {
            @(
                $commands |
                    Where-Object {
                        $_.CommandType -eq 'Function'
                    }
            ).Count |
                Should -Be 28
        }

        It "Exports only the expected public functions" {
            $expectedFunctions = @(
                'Get-ITSystemInformation',
                'Get-ITNetworkInformation',
                'Test-ITInternetConnection',
                'Test-ITDNSResolution',
                'Test-ITTCPPort',
                'Invoke-ITTraceRoute',
                'Get-ITWiFiInformation',
                'Get-ITPendingReboot',
                'Get-ITServiceHealth',
                'Get-ITRecentSystemErrors',
                'Get-ITEventCorrelation',
                'Get-ITServiceDependency',
                'Get-ITDiagnosticReportData',
                'Export-ITDiagnosticReportText',
                'Export-ITDiagnosticReportHtml',
                'Export-ITDiagnosticReportJson',
                'Export-ITDiagnosticReportCsv',
                'Get-ITHealthAnalysis',
                'Get-ITStorageHealth',
                'Get-ITPhysicalDiskHealth',
                'Get-ITWindowsUpdateStatus',
                'Get-ITWindowsUpdateHistory',
                'Get-ITPerformanceSnapshot',
                'Get-ITTopProcesses',
                'Get-ITMemoryConsumers',
                'Get-ITStartupItems',
                'Get-ITPerformanceSample',
                'Get-ITProcessDetails'
            )

            $actualFunctions = @(
                $commands |
                    Where-Object {
                        $_.CommandType -eq 'Function'
                    } |
                    Select-Object -ExpandProperty Name |
                    Sort-Object
            )

            $expectedFunctions = @(
                $expectedFunctions |
                    Sort-Object
            )

            $actualFunctions |
                Should -Be $expectedFunctions
        }
    }
}