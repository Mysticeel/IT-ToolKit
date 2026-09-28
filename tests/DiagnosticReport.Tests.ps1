$systemModulePath  = Join-Path $PSScriptRoot "..\src\Modules\SystemInformation.psm1"
$networkModulePath = Join-Path $PSScriptRoot "..\src\Modules\NetworkDiagnostics.psm1"
$windowsModulePath = Join-Path $PSScriptRoot "..\src\Modules\WindowsDiagnostics.psm1"
$reportModulePath  = Join-Path $PSScriptRoot "..\src\Modules\DiagnosticReport.psm1"

Import-Module $systemModulePath -Force
Import-Module $networkModulePath -Force
Import-Module $windowsModulePath -Force
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


    Context "Diagnostic report data" {

        BeforeAll {
            $report = Get-ITDiagnosticReportData
        }

        It "Returns a report object" {
            $report |
                Should -Not -BeNullOrEmpty
        }

        It "Contains a GeneratedAt value" {
            $report.GeneratedAt |
                Should -Not -BeNullOrEmpty
        }

        It "Contains a System section" {
            $report.System |
                Should -Not -BeNullOrEmpty
        }

        It "Contains a Network section" {
            $report.Network |
                Should -Not -BeNullOrEmpty
        }

        It "Contains a Windows section" {
            $report.Windows |
                Should -Not -BeNullOrEmpty
        }

        It "Contains a Summary section" {
            $report.Summary |
                Should -Not -BeNullOrEmpty
        }

        It "Returns RebootRequired as a boolean" {
            $report.Summary.RebootRequired |
                Should -BeOfType [bool]
        }

        It "Returns InternetConnected as a boolean" {
            $report.Summary.InternetConnected |
                Should -BeOfType [bool]
        }
    }


    Context "Text export" {

        BeforeAll {
            $testDirectory = Join-Path $TestDrive "reports"
            $textPath = Join-Path $testDirectory "report.txt"

            $report = Get-ITDiagnosticReportData

            $result = Export-ITDiagnosticReportText `
                -Report $report `
                -Path $textPath
        }

        It "Creates the text report" {
            Test-Path $textPath |
                Should -BeTrue
        }

        It "Returns the generated file" {
            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Contains the report title" {
            Get-Content $textPath -Raw |
                Should -Match "IT-Toolkit Diagnostic Report"
        }

        It "Contains a System Information section" {
            Get-Content $textPath -Raw |
                Should -Match "SYSTEM INFORMATION"
        }

        It "Contains a Network section" {
            Get-Content $textPath -Raw |
                Should -Match "NETWORK"
        }

        It "Contains a Windows Health section" {
            Get-Content $textPath -Raw |
                Should -Match "WINDOWS HEALTH"
        }

        It "Contains a Summary section" {
            Get-Content $textPath -Raw |
                Should -Match "SUMMARY"
        }
    }


    Context "HTML export" {

        BeforeAll {
            $testDirectory = Join-Path $TestDrive "reports"
            $htmlPath = Join-Path $testDirectory "report.html"

            $report = Get-ITDiagnosticReportData

            $result = Export-ITDiagnosticReportHtml `
                -Report $report `
                -Path $htmlPath
        }

        It "Creates the HTML report" {
            Test-Path $htmlPath |
                Should -BeTrue
        }

        It "Returns the generated file" {
            $result |
                Should -Not -BeNullOrEmpty
        }

        It "Contains the report title" {
            Get-Content $htmlPath -Raw |
                Should -Match "IT-Toolkit Diagnostic Report"
        }

        It "Contains the Summary section" {
            Get-Content $htmlPath -Raw |
                Should -Match "<h2>Summary</h2>"
        }

        It "Contains the System Information section" {
            Get-Content $htmlPath -Raw |
                Should -Match "<h2>System Information</h2>"
        }

        It "Contains the Network section" {
            Get-Content $htmlPath -Raw |
                Should -Match "<h2>Network</h2>"
        }

        It "Contains the Windows Health section" {
            Get-Content $htmlPath -Raw |
                Should -Match "<h2>Windows Health</h2>"
        }
    }
}