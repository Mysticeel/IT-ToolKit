Describe "DiagnosticReport Module" {
    BeforeAll {
        $systemModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\SystemInformation.psm1"
        $networkModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\NetworkDiagnostics.psm1"
        $windowsModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\WindowsDiagnostics.psm1"
        $storageModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\StorageDiagnostics.psm1"
        $updateModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\WindowsUpdateDiagnostics.psm1"
        $performanceModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\PerformanceDiagnostics.psm1"
        $healthModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\HealthAnalysis.psm1"
        $reportModulePath = Join-Path `
            $PSScriptRoot `
            "..\src\modules\DiagnosticReport.psm1"
        Import-Module $systemModulePath -Force
        Import-Module $networkModulePath -Force
        Import-Module $windowsModulePath -Force
        Import-Module $storageModulePath -Force
        Import-Module $updateModulePath -Force
        Import-Module $performanceModulePath -Force
        Import-Module $healthModulePath -Force
        Import-Module $reportModulePath -Force
        # Generate the report once because Windows Update and
        # the other integrated diagnostics can take time.
        $report = Get-ITDiagnosticReportData
    }
    Context "Module structure" {
        It "Exports Get-ITDiagnosticReportData" {
            Get-Command `
                Get-ITDiagnosticReportData `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Export-ITDiagnosticReportText" {
            Get-Command `
                Export-ITDiagnosticReportText `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Export-ITDiagnosticReportHtml" {
            Get-Command `
                Export-ITDiagnosticReportHtml `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
        It "Exports Export-ITDiagnosticReportJson" {
            Get-Command `
                Export-ITDiagnosticReportJson `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }
    Context "Unified report data" {
        It "Returns a report object" {
            $report |
                Should -Not -BeNullOrEmpty
        }
        It "Contains all report sections" {
            $report.PSObject.Properties.Name |
                Should -Contain 'Metadata'
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
        It "Contains event correlation data" {
            $report.Windows.PSObject.Properties.Name |
                Should -Contain 'EventCorrelation'
        }
        It "Contains a correlated event count" {
            $report.Summary.PSObject.Properties.Name |
                Should -Contain 'CorrelatedEventCount'
            $report.Summary.CorrelatedEventCount |
                Should -Be @($report.Windows.EventCorrelation).Count
        }
        It "Contains report metadata" {
            $report.Metadata |
                Should -Not -BeNullOrEmpty
        }
        It "Reports toolkit version 1.1.0" {
            $report.Metadata.ToolkitVersion |
                Should -Be '1.1.0'
        }
        It "Reports schema version 1" {
            $report.Metadata.ReportSchemaVersion |
                Should -Be 1
        }
        It "Reports a PowerShell version" {
            $report.Metadata.PowerShellVersion |
                Should -Not -BeNullOrEmpty
        }
        It "Reports collection duration" {
            $report.Metadata.CollectionDurationSeconds |
                Should -BeGreaterOrEqual 0
        }
    }
    Context "Text export" {
        BeforeAll {
            $textDirectory = Join-Path `
                $TestDrive `
                "text"
            $textPath = Join-Path `
                $textDirectory `
                "report.txt"
            Export-ITDiagnosticReportText `
                -Report $report `
                -Path $textPath |
                Out-Null
            $textContent = Get-Content `
                -Path $textPath `
                -Raw
        }
        It "Creates the text report" {
            Test-Path $textPath |
                Should -BeTrue
        }
        It "Contains report metadata" {
            $textContent |
                Should -Match 'REPORT METADATA'
            $textContent |
                Should -Match 'Toolkit Version'
            $textContent |
                Should -Match 'Report Schema Version'
        }
        It "Contains all major sections" {
            $textContent |
                Should -Match 'SUMMARY'
            $textContent |
                Should -Match 'SYSTEM INFORMATION'
            $textContent |
                Should -Match 'NETWORK'
            $textContent |
                Should -Match 'WINDOWS HEALTH'
            $textContent |
                Should -Match 'STORAGE'
            $textContent |
                Should -Match 'WINDOWS UPDATE'
            $textContent |
                Should -Match 'PERFORMANCE'
            $textContent |
                Should -Match 'HEALTH ANALYSIS'
        }
        It "Contains event correlation" {
            $textContent |
                Should -Match 'Event Correlation'
            $textContent |
                Should -Match 'Correlated Event Groups'
        }
    }
    Context "HTML export" {
        BeforeAll {
            $htmlDirectory = Join-Path `
                $TestDrive `
                "html"
            $htmlPath = Join-Path `
                $htmlDirectory `
                "report.html"
            Export-ITDiagnosticReportHtml `
                -Report $report `
                -Path $htmlPath |
                Out-Null
            $htmlContent = Get-Content `
                -Path $htmlPath `
                -Raw
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
            $htmlContent |
                Should -Match '<h2>Summary</h2>'
            $htmlContent |
                Should -Match '<h2>System Information</h2>'
            $htmlContent |
                Should -Match '<h2>Network</h2>'
            $htmlContent |
                Should -Match '<h2>Windows Health</h2>'
            $htmlContent |
                Should -Match '<h2>Storage</h2>'
            $htmlContent |
                Should -Match '<h2>Windows Update</h2>'
            $htmlContent |
                Should -Match '<h2>Performance</h2>'
            $htmlContent |
                Should -Match '<h2>Health Analysis</h2>'
        }
        It "Contains event correlation" {
            $htmlContent |
                Should -Match '<h3>Event Correlation</h3>'
            $htmlContent |
                Should -Match 'Correlated Event Groups'
        }
        It "Contains severity badge styling" {
            $htmlContent |
                Should -Match 'badge healthy'
        }
    }
    Context "JSON export" {
        BeforeAll {
            $jsonDirectory = Join-Path `
                $TestDrive `
                "json"
            $jsonPath = Join-Path `
                $jsonDirectory `
                "report.json"
            Export-ITDiagnosticReportJson `
                -Report $report `
                -Path $jsonPath |
                Out-Null
            $jsonContent = Get-Content `
                -Path $jsonPath `
                -Raw
            $jsonObject = $jsonContent |
                ConvertFrom-Json
        }
        It "Creates the JSON report" {
            Test-Path $jsonPath |
                Should -BeTrue
        }
        It "Creates valid JSON" {
            {
                $jsonContent |
                    ConvertFrom-Json
            } |
                Should -Not -Throw
        }
        It "Contains GeneratedAt" {
            $jsonObject.GeneratedAt |
                Should -Not -BeNullOrEmpty
        }
        It "Contains Metadata" {
            $jsonObject.Metadata |
                Should -Not -BeNullOrEmpty
        }
        It "Preserves toolkit version" {
            $jsonObject.Metadata.ToolkitVersion |
                Should -Be $report.Metadata.ToolkitVersion
        }
        It "Preserves report schema version" {
            $jsonObject.Metadata.ReportSchemaVersion |
                Should -Be $report.Metadata.ReportSchemaVersion
        }
        It "Preserves PowerShell version" {
            $jsonObject.Metadata.PowerShellVersion |
                Should -Be $report.Metadata.PowerShellVersion
        }
        It "Preserves collection duration" {
            $jsonObject.Metadata.CollectionDurationSeconds |
                Should -Be $report.Metadata.CollectionDurationSeconds
        }
        It "Contains the Summary section" {
            $jsonObject.Summary |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the System section" {
            $jsonObject.System |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the Network section" {
            $jsonObject.Network |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the Windows section" {
            $jsonObject.Windows |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the Storage section" {
            $jsonObject.Storage |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the Windows Update section" {
            $jsonObject.WindowsUpdate |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the Performance section" {
            $jsonObject.Performance |
                Should -Not -BeNullOrEmpty
        }
        It "Contains the Health section" {
            $jsonObject.Health |
                Should -Not -BeNullOrEmpty
        }
        It "Preserves event correlation" {
            $jsonObject.Windows.PSObject.Properties.Name |
                Should -Contain 'EventCorrelation'
            @($jsonObject.Windows.EventCorrelation).Count |
                Should -Be @($report.Windows.EventCorrelation).Count
        }
        It "Preserves the correlated event count" {
            $jsonObject.Summary.CorrelatedEventCount |
                Should -Be $report.Summary.CorrelatedEventCount
        }
        It "Preserves the overall health status" {
            $jsonObject.Summary.OverallHealth |
                Should -Be $report.Summary.OverallHealth
        }
        It "Preserves the computer name" {
            $jsonObject.System.ComputerName |
                Should -Be $report.System.ComputerName
        }
        It "Preserves the Windows Update count" {
            $jsonObject.WindowsUpdate.UpdateCount |
                Should -Be $report.WindowsUpdate.UpdateCount
        }
        It "Preserves CPU usage" {
            $jsonObject.Performance.CPUUsagePercent |
                Should -Be $report.Performance.CPUUsagePercent
        }
        It "Preserves the health analysis status" {
            $jsonObject.Health.OverallStatus |
                Should -Be $report.Health.OverallStatus
        }
        It "Supports a custom JSON depth" {
            $customPath = Join-Path `
                $jsonDirectory `
                "report-custom-depth.json"
            {
                Export-ITDiagnosticReportJson `
                    -Report $report `
                    -Path $customPath `
                    -Depth 20 |
                    Out-Null
            } |
                Should -Not -Throw
        }
        It "Rejects JSON depth below 3" {
            {
                Export-ITDiagnosticReportJson `
                    -Report $report `
                    -Path $jsonPath `
                    -Depth 2
            } |
                Should -Throw
        }
        It "Rejects JSON depth above 100" {
            {
                Export-ITDiagnosticReportJson `
                    -Report $report `
                    -Path $jsonPath `
                    -Depth 101
            } |
                Should -Throw
        }
    }
}
