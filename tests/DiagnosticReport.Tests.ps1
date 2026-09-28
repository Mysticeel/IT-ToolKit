$systemModulePath      = Join-Path $PSScriptRoot "..\src\Modules\SystemInformation.psm1"
$networkModulePath     = Join-Path $PSScriptRoot "..\src\Modules\NetworkDiagnostics.psm1"
$windowsModulePath     = Join-Path $PSScriptRoot "..\src\Modules\WindowsDiagnostics.psm1"
$storageModulePath     = Join-Path $PSScriptRoot "..\src\Modules\StorageDiagnostics.psm1"
$updateModulePath      = Join-Path $PSScriptRoot "..\src\Modules\WindowsUpdateDiagnostics.psm1"
$performanceModulePath = Join-Path $PSScriptRoot "..\src\Modules\PerformanceDiagnostics.psm1"
$healthModulePath      = Join-Path $PSScriptRoot "..\src\Modules\HealthAnalysis.psm1"
$reportModulePath      = Join-Path $PSScriptRoot "..\src\Modules\DiagnosticReport.psm1"

Import-Module $systemModulePath -Force
Import-Module $networkModulePath -Force
Import-Module $windowsModulePath -Force
Import-Module $storageModulePath -Force
Import-Module $updateModulePath -Force
Import-Module $performanceModulePath -Force
Import-Module $healthModulePath -Force
Import-Module $reportModulePath -Force


Describe "DiagnosticReport Module" {

    Context "Module structure" {

        It "Exports Get-ITDiagnosticReportData" {
            Get-Command Get-ITDiagnosticReportData -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Export-ITDiagnosticReportText" {
            Get-Command Export-ITDiagnosticReportText -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Export-ITDiagnosticReportHtml" {
            Get-Command Export-ITDiagnosticReportHtml -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }


    Context "Unified report data" {

        BeforeAll {
            $report = Get-ITDiagnosticReportData
        }

        It "Returns a report object" {
            $report |
                Should -Not -BeNullOrEmpty
        }

        It "Contains all report sections" {

            $report.PSObject.Properties.Name |
                Should -Contain 'System'

            $report.PSObject.Properties.Name |
                Should -Contain 'Network'

            $report.PSObject.Properties.Name |
                Should -Contain 'Windows'

            $report.PSObject.Properties.Name |
                Should -Contain 'Storage'

            $report.PSObject.Properties.Name |
                Should -Contain 'WindowsUpdate'

            $report.PSObject.Properties.Name |
                Should -Contain 'Performance'

            $report.PSObject.Properties.Name |
                Should -Contain 'Health'

            $report.PSObject.Properties.Name |
                Should -Contain 'Summary'
        }

        It "Contains an overall health status" {
            $report.Health.OverallStatus |
                Should -BeIn @(
                    'Healthy',
                    'Warning',
                    'Critical'
                )
        }

        It "Contains logical drive data" {
            $report.Storage.LogicalDrives |
                Should -Not -BeNullOrEmpty
        }

        It "Contains performance data" {
            $report.Performance.CPUUsagePercent |
                Should -BeGreaterOrEqual 0
        }

        It "Contains a Windows Update count" {
            $report.WindowsUpdate.PSObject.Properties.Name |
                Should -Contain 'UpdateCount'
        }
    }


    Context "Text export" {

        BeforeAll {
            $testDirectory = Join-Path $TestDrive "reports"
            $textPath = Join-Path $testDirectory "report.txt"

            $report = Get-ITDiagnosticReportData

            Export-ITDiagnosticReportText `
                -Report $report `
                -Path $textPath |
                Out-Null

            $textContent = Get-Content $textPath -Raw
        }

        It "Creates the text report" {
            Test-Path $textPath |
                Should -BeTrue
        }

        It "Contains all major sections" {

            $textContent | Should -Match 'SUMMARY'
            $textContent | Should -Match 'SYSTEM INFORMATION'
            $textContent | Should -Match 'NETWORK'
            $textContent | Should -Match 'WINDOWS HEALTH'
            $textContent | Should -Match 'STORAGE'
            $textContent | Should -Match 'WINDOWS UPDATE'
            $textContent | Should -Match 'PERFORMANCE'
            $textContent | Should -Match 'HEALTH ANALYSIS'
        }
    }


    Context "HTML export" {

        BeforeAll {
            $testDirectory = Join-Path $TestDrive "reports"
            $htmlPath = Join-Path $testDirectory "report.html"

            $report = Get-ITDiagnosticReportData

            Export-ITDiagnosticReportHtml `
                -Report $report `
                -Path $htmlPath |
                Out-Null

            $htmlContent = Get-Content $htmlPath -Raw
        }

        It "Creates the HTML report" {
            Test-Path $htmlPath |
                Should -BeTrue
        }

        It "Contains the report title" {
            $htmlContent |
                Should -Match 'IT-Toolkit Diagnostic Report'
        }

        It "Contains all report sections" {

            $htmlContent | Should -Match '<h2>Summary</h2>'
            $htmlContent | Should -Match '<h2>System Information</h2>'
            $htmlContent | Should -Match '<h2>Network</h2>'
            $htmlContent | Should -Match '<h2>Windows Health</h2>'
            $htmlContent | Should -Match '<h2>Storage</h2>'
            $htmlContent | Should -Match '<h2>Windows Update</h2>'
            $htmlContent | Should -Match '<h2>Performance</h2>'
            $htmlContent | Should -Match '<h2>Health Analysis</h2>'
        }

        It "Contains severity badge styling" {
            $htmlContent |
                Should -Match 'badge healthy'
        }
    }
}