$systemModulePath  = Join-Path $PSScriptRoot "..\src\Modules\SystemInformation.psm1"
$networkModulePath = Join-Path $PSScriptRoot "..\src\Modules\NetworkDiagnostics.psm1"
$windowsModulePath = Join-Path $PSScriptRoot "..\src\Modules\WindowsDiagnostics.psm1"
$healthModulePath  = Join-Path $PSScriptRoot "..\src\Modules\HealthAnalysis.psm1"

Import-Module $systemModulePath -Force
Import-Module $networkModulePath -Force
Import-Module $windowsModulePath -Force
Import-Module $healthModulePath -Force


Describe "HealthAnalysis Module" {

    Context "Module structure" {

        It "Exports Get-ITHealthAnalysis" {
            Get-Command Get-ITHealthAnalysis -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }


    Context "Health analysis output" {

        BeforeAll {
            $health = Get-ITHealthAnalysis
        }

        It "Returns an analysis object" {
            $health |
                Should -Not -BeNullOrEmpty
        }

        It "Contains an overall status" {
            $health.OverallStatus |
                Should -Not -BeNullOrEmpty
        }

        It "Uses a valid overall status" {
            $health.OverallStatus |
                Should -BeIn @(
                    'Healthy',
                    'Warning',
                    'Critical'
                )
        }

        It "Returns findings" {
            $health.Findings |
                Should -Not -BeNullOrEmpty
        }

        It "Returns a HealthyCount" {
            $health.HealthyCount |
                Should -BeOfType [int]
        }

        It "Returns a WarningCount" {
            $health.WarningCount |
                Should -BeOfType [int]
        }

        It "Returns a CriticalCount" {
            $health.CriticalCount |
                Should -BeOfType [int]
        }

        It "Returns an InfoCount" {
            $health.InfoCount |
                Should -BeOfType [int]
        }

        It "Returns matching finding totals" {

            $total =
                $health.HealthyCount +
                $health.WarningCount +
                $health.CriticalCount +
                $health.InfoCount

            @($health.Findings).Count |
                Should -Be $total
        }
    }


    Context "Finding structure" {

        BeforeAll {
            $health = Get-ITHealthAnalysis
        }

        It "Each finding contains an Area" {

            foreach ($finding in $health.Findings) {

                $finding.Area |
                    Should -Not -BeNullOrEmpty
            }
        }

        It "Each finding contains a Severity" {

            foreach ($finding in $health.Findings) {

                $finding.Severity |
                    Should -BeIn @(
                        'Healthy',
                        'Information',
                        'Warning',
                        'Critical'
                    )
            }
        }

        It "Each finding contains a Finding message" {

            foreach ($finding in $health.Findings) {

                $finding.Finding |
                    Should -Not -BeNullOrEmpty
            }
        }
    }
}