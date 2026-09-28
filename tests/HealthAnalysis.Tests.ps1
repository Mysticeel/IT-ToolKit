$systemModulePath      = Join-Path $PSScriptRoot "..\src\Modules\SystemInformation.psm1"
$networkModulePath     = Join-Path $PSScriptRoot "..\src\Modules\NetworkDiagnostics.psm1"
$windowsModulePath     = Join-Path $PSScriptRoot "..\src\Modules\WindowsDiagnostics.psm1"
$storageModulePath     = Join-Path $PSScriptRoot "..\src\Modules\StorageDiagnostics.psm1"
$updateModulePath      = Join-Path $PSScriptRoot "..\src\Modules\WindowsUpdateDiagnostics.psm1"
$performanceModulePath = Join-Path $PSScriptRoot "..\src\Modules\PerformanceDiagnostics.psm1"
$healthModulePath      = Join-Path $PSScriptRoot "..\src\Modules\HealthAnalysis.psm1"

Import-Module $systemModulePath -Force
Import-Module $networkModulePath -Force
Import-Module $windowsModulePath -Force
Import-Module $storageModulePath -Force
Import-Module $updateModulePath -Force
Import-Module $performanceModulePath -Force
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

        It "Contains a GeneratedAt value" {
            $health.GeneratedAt |
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

        It "Returns all expected health areas" {

            $areas = @(
                $health.Findings |
                    Select-Object -ExpandProperty Area
            )

            $areas | Should -Contain 'Internet'
            $areas | Should -Contain 'DNS'
            $areas | Should -Contain 'Windows'
            $areas | Should -Contain 'Storage'
            $areas | Should -Contain 'Event Logs'
            $areas | Should -Contain 'Services'
            $areas | Should -Contain 'Windows Update'
            $areas | Should -Contain 'CPU'
            $areas | Should -Contain 'Memory'
        }

        It "Returns valid finding severities" {

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

        It "Every finding has an Area" {

            foreach ($finding in $health.Findings) {

                $finding.Area |
                    Should -Not -BeNullOrEmpty
            }
        }

        It "Every finding has a Finding message" {

            foreach ($finding in $health.Findings) {

                $finding.Finding |
                    Should -Not -BeNullOrEmpty
            }
        }

        It "Every finding exposes a Recommendation property" {

            foreach ($finding in $health.Findings) {

                $finding.PSObject.Properties.Name |
                    Should -Contain 'Recommendation'
            }
        }
    }
}