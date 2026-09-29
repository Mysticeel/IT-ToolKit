[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost',
    '',
    Justification = 'Write-Host is intentionally used for the interactive console user interface.'
)]
param()
$systemModulePath      = Join-Path -Path $PSScriptRoot -ChildPath "modules\SystemInformation.psm1"
$networkModulePath     = Join-Path -Path $PSScriptRoot -ChildPath "modules\NetworkDiagnostics.psm1"
$windowsModulePath     = Join-Path -Path $PSScriptRoot -ChildPath "modules\WindowsDiagnostics.psm1"
$reportModulePath      = Join-Path -Path $PSScriptRoot -ChildPath "modules\DiagnosticReport.psm1"
$healthModulePath      = Join-Path -Path $PSScriptRoot -ChildPath "modules\HealthAnalysis.psm1"
$storageModulePath     = Join-Path -Path $PSScriptRoot -ChildPath "modules\StorageDiagnostics.psm1"
$updateModulePath      = Join-Path -Path $PSScriptRoot -ChildPath "modules\WindowsUpdateDiagnostics.psm1"
$performanceModulePath = Join-Path -Path $PSScriptRoot -ChildPath "modules\PerformanceDiagnostics.psm1"
Import-Module $systemModulePath -Force
Import-Module $networkModulePath -Force
Import-Module $windowsModulePath -Force
Import-Module $reportModulePath -Force
Import-Module $healthModulePath -Force
Import-Module $storageModulePath -Force
Import-Module $updateModulePath -Force
Import-Module $performanceModulePath -Force

function Wait-ITToolkit {
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Show-Header {
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )
    Clear-Host
    Write-Host ""
    Write-Host "============================================"
    Write-Host "               IT-Toolkit"
    Write-Host "============================================"
    Write-Host " $Title"
    Write-Host "============================================"
    Write-Host ""
}

function Show-SystemInformation {
    Show-Header -Title "System Information"
    Write-Host "Collecting system information..."
    Write-Host ""
    Get-ITSystemInformation |
        Format-List
    Wait-ITToolkit
}

function Show-NetworkDiagnosticsMenu {
    do {
        Show-Header -Title "Network Diagnostics"
        Write-Host "1. Network adapters"
        Write-Host "2. Network adapters (include virtual)"
        Write-Host "3. Internet connectivity"
        Write-Host "4. DNS resolution"
        Write-Host "5. TCP port test"
        Write-Host "6. Trace route"
        Write-Host "7. Wi-Fi information"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""
        $choice = Read-Host "Select an option"
        switch ($choice.ToUpper()) {
            "1" {
                Show-Header -Title "Network Adapters"
                Write-Host "Active physical network adapters"
                Write-Host ""
                Get-ITNetworkInformation |
                    Format-List
                Wait-ITToolkit
            }
            "2" {
                Show-Header -Title "All Network Adapters"
                Write-Host "Active physical and virtual network adapters"
                Write-Host ""
                Get-ITNetworkInformation -IncludeVirtual |
                    Format-List
                Wait-ITToolkit
            }
            "3" {
                Show-Header -Title "Internet Connectivity"
                Write-Host "Testing internet connectivity..."
                Write-Host ""
                Test-ITInternetConnection |
                    Format-List
                Wait-ITToolkit
            }
            "4" {
                Show-Header -Title "DNS Resolution"
                $hostname = Read-Host "Enter hostname (default: github.com)"
                if ([string]::IsNullOrWhiteSpace($hostname)) {
                    $hostname = "github.com"
                }
                Write-Host ""
                Write-Host "Resolving $hostname..."
                Write-Host ""
                Test-ITDNSResolution -Name $hostname |
                    Format-List
                Wait-ITToolkit
            }
            "5" {
                Show-Header -Title "TCP Port Test"
                $hostname = Read-Host "Enter hostname or IP address"
                if ([string]::IsNullOrWhiteSpace($hostname)) {
                    Write-Host ""
                    Write-Host "A hostname or IP address is required."
                    Wait-ITToolkit
                    continue
                }
                $portInput = Read-Host "Enter TCP port"
                if ($portInput -notmatch '^\d+$') {
                    Write-Host ""
                    Write-Host "Invalid port number."
                    Wait-ITToolkit
                    continue
                }
                $port = [int]$portInput
                if ($port -lt 1 -or $port -gt 65535) {
                    Write-Host ""
                    Write-Host "Port must be between 1 and 65535."
                    Wait-ITToolkit
                    continue
                }
                Write-Host ""
                Write-Host "Testing $hostname on TCP port $port..."
                Write-Host ""
                Test-ITTCPPort `
                    -ComputerName $hostname `
                    -Port $port |
                    Format-List
                Wait-ITToolkit
            }
            "6" {
                Show-Header -Title "Trace Route"
                $hostname = Read-Host "Enter hostname or IP address"
                if ([string]::IsNullOrWhiteSpace($hostname)) {
                    Write-Host ""
                    Write-Host "A hostname or IP address is required."
                    Wait-ITToolkit
                    continue
                }
                Write-Host ""
                Write-Host "Tracing route to $hostname..."
                Write-Host ""
                $result = Invoke-ITTraceRoute `
                    -ComputerName $hostname
                Write-Host "Computer Name  : $($result.ComputerName)"
                Write-Host "Remote Address : $($result.RemoteAddress)"
                Write-Host "Successful     : $($result.Successful)"
                Write-Host ""
                if ($result.TraceRoute) {
                    Write-Host "Route:"
                    Write-Host ""
                    $hop = 1
                    foreach ($address in $result.TraceRoute) {
                        Write-Host ("{0,3}. {1}" -f $hop, $address)
                        $hop++
                    }
                }
                if ($result.Error) {
                    Write-Host ""
                    Write-Host "Error: $($result.Error)"
                }
                Wait-ITToolkit
            }
            "7" {
                Show-Header -Title "Wi-Fi Information"
                $wifi = Get-ITWiFiInformation
                if ($wifi.Connected) {
                    $wifi |
                        Select-Object -Property Name, Description, SSID, BSSID, RadioType, Channel, Signal, ReceiveRate, TransmitRate |
                        Format-List
                }
                else {
                    Write-Host "No active Wi-Fi connection was detected."
                    if ($wifi.Error) {
                        Write-Host ""
                        Write-Host "Details: $($wifi.Error)"
                    }
                }
                Wait-ITToolkit
            }
            "B" {
                return
            }
            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

function Show-WindowsDiagnosticsMenu {
    do {
        Show-Header -Title "Windows Diagnostics"
        Write-Host "1. Pending reboot status"
        Write-Host "2. Automatic services not running"
        Write-Host "3. Recent critical and error events"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""
        $choice = Read-Host "Select an option"
        switch ($choice.ToUpper()) {
            "1" {
                Show-Header -Title "Pending Reboot"
                $result = Get-ITPendingReboot
                Write-Host "Reboot Required : $($result.RebootRequired)"
                if ($result.Reasons) {
                    Write-Host "Reasons         : $($result.Reasons)"
                }
                else {
                    Write-Host "Reasons         : None"
                }
                Wait-ITToolkit
            }
            "2" {
                Show-Header -Title "Service Health"
                Write-Host "Checking automatic services..."
                Write-Host ""
                $services = Get-ITServiceHealth
                if ($services) {
                    $services |
                        Format-Table -Property Name, DisplayName, Status, StartType -AutoSize
                }
                else {
                    Write-Host "No stopped automatic services were found."
                }
                Wait-ITToolkit
            }
            "3" {
                Show-Header -Title "Recent System Errors"
                $hoursInput = Read-Host "Hours to check (default: 24)"
                if ([string]::IsNullOrWhiteSpace($hoursInput)) {
                    $hours = 24
                }
                elseif (
                    $hoursInput -match '^\d+$' -and
                    [int]$hoursInput -ge 1 -and
                    [int]$hoursInput -le 168
                ) {
                    $hours = [int]$hoursInput
                }
                else {
                    Write-Host ""
                    Write-Host "Enter a value between 1 and 168 hours."
                    Wait-ITToolkit
                    continue
                }
                Write-Host ""
                Write-Host "Checking the last $hours hour(s)..."
                Write-Host ""
                $events = Get-ITRecentSystemErrors `
                    -Hours $hours
                if ($events) {
                    $events |
                        Format-Table -Property TimeCreated, Id, LevelDisplayName, ProviderName -AutoSize
                    Write-Host ""
                    Write-Host "Full event messages are available by running:"
                    Write-Host "Get-ITRecentSystemErrors -Hours $hours"
                }
                else {
                    Write-Host "No critical or error events were found."
                }
                Wait-ITToolkit
            }
            "B" {
                return
            }
            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

function Show-DiagnosticReportMenu {
    do {
        Show-Header -Title "Generate Diagnostic Report"
        Write-Host "1. Generate HTML report"
        Write-Host "2. Generate text report"
        Write-Host "3. Generate JSON report"
        Write-Host "4. Generate HTML + text"
        Write-Host "5. Generate all formats"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""
        $choice = Read-Host "Select an option"
        if ($choice.ToUpper() -eq "B") {
            return
        }
        if ($choice -notin @("1", "2", "3", "4", "5")) {
            Write-Host ""
            Write-Host "Invalid selection."
            Start-Sleep -Seconds 1
            continue
        }
        Show-Header -Title "Generating Diagnostic Report"
        Write-Host "Collecting diagnostic information..."
        Write-Host ""
        Write-Host "This may take a few moments."
        Write-Host ""
        try {
            $report = Get-ITDiagnosticReportData
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $reportDirectory = Join-Path -Path $PSScriptRoot -ChildPath "..
eports"
            $reportDirectory = [System.IO.Path]::GetFullPath(
                $reportDirectory
            )
            if (-not (Test-Path -LiteralPath $reportDirectory)) {
                New-Item -ItemType Directory -Path $reportDirectory -Force |
                    Out-Null
            }
            $htmlPath = Join-Path -Path $reportDirectory -ChildPath "IT-Toolkit-Diagnostic-$timestamp.html"
            $textPath = Join-Path -Path $reportDirectory -ChildPath "IT-Toolkit-Diagnostic-$timestamp.txt"
            $jsonPath = Join-Path -Path $reportDirectory -ChildPath "IT-Toolkit-Diagnostic-$timestamp.json"
            switch ($choice) {
                "1" {
                    Export-ITDiagnosticReportHtml `
                        -Report $report `
                        -Path $htmlPath |
                        Out-Null
                    Write-Host "HTML report generated successfully."
                    Write-Host ""
                    Write-Host "Location:"
                    Write-Host $htmlPath
                    Write-Host ""
                    $openReport = Read-Host "Open the report now? (Y/N)"
                    if ($openReport.ToUpper() -eq "Y") {
                        Start-Process $htmlPath
                    }
                }
                "2" {
                    Export-ITDiagnosticReportText `
                        -Report $report `
                        -Path $textPath |
                        Out-Null
                    Write-Host "Text report generated successfully."
                    Write-Host ""
                    Write-Host "Location:"
                    Write-Host $textPath
                }
                "3" {
                    Export-ITDiagnosticReportJson `
                        -Report $report `
                        -Path $jsonPath |
                        Out-Null
                    Write-Host "JSON report generated successfully."
                    Write-Host ""
                    Write-Host "Location:"
                    Write-Host $jsonPath
                }
                "4" {
                    Export-ITDiagnosticReportHtml `
                        -Report $report `
                        -Path $htmlPath |
                        Out-Null
                    Export-ITDiagnosticReportText `
                        -Report $report `
                        -Path $textPath |
                        Out-Null
                    Write-Host "HTML and text reports generated successfully."
                    Write-Host ""
                    Write-Host "HTML:"
                    Write-Host $htmlPath
                    Write-Host ""
                    Write-Host "Text:"
                    Write-Host $textPath
                    Write-Host ""
                    $openReport = Read-Host "Open the HTML report now? (Y/N)"
                    if ($openReport.ToUpper() -eq "Y") {
                        Start-Process $htmlPath
                    }
                }
                "5" {
                    Export-ITDiagnosticReportHtml `
                        -Report $report `
                        -Path $htmlPath |
                        Out-Null
                    Export-ITDiagnosticReportText `
                        -Report $report `
                        -Path $textPath |
                        Out-Null
                    Export-ITDiagnosticReportJson `
                        -Report $report `
                        -Path $jsonPath |
                        Out-Null
                    Write-Host "All report formats generated successfully."
                    Write-Host ""
                    Write-Host "HTML:"
                    Write-Host $htmlPath
                    Write-Host ""
                    Write-Host "Text:"
                    Write-Host $textPath
                    Write-Host ""
                    Write-Host "JSON:"
                    Write-Host $jsonPath
                    Write-Host ""
                    $openReport = Read-Host "Open the HTML report now? (Y/N)"
                    if ($openReport.ToUpper() -eq "Y") {
                        Start-Process $htmlPath
                    }
                }
            }
        }
        catch {
            Write-Host ""
            Write-Host "Unable to generate the diagnostic report."
            Write-Host ""
            Write-Host "Error:"
            Write-Host $_.Exception.Message
        }
        Wait-ITToolkit
    } while ($true)
}

function Show-SystemHealthAnalysis {
    Show-Header -Title "System Health Analysis"
    Write-Host "Analysing system health..."
    Write-Host ""
    try {
        $health = Get-ITHealthAnalysis
        Write-Host "Overall Status : $($health.OverallStatus)"
        Write-Host ""
        Write-Host "Healthy        : $($health.HealthyCount)"
        Write-Host "Warnings       : $($health.WarningCount)"
        Write-Host "Critical       : $($health.CriticalCount)"
        Write-Host "Information    : $($health.InfoCount)"
        Write-Host ""
        Write-Host "Findings"
        Write-Host "========"
        Write-Host ""
        foreach ($finding in $health.Findings) {
            Write-Host "[$($finding.Severity)] $($finding.Area)"
            Write-Host "  $($finding.Finding)"
            if ($finding.Recommendation) {
                Write-Host "  Recommendation: $($finding.Recommendation)"
            }
            Write-Host ""
        }
        $recommendations = $health.Findings |
            Where-Object {
                $_.Recommendation
            }
        if ($recommendations) {
            Write-Host "Recommended Actions"
            Write-Host "==================="
            Write-Host ""
            foreach ($item in $recommendations) {
                Write-Host "- $($item.Recommendation)"
            }
            Write-Host ""
        }
    }
    catch {
        Write-Host "Unable to complete the system health analysis."
        Write-Host ""
        Write-Host "Error:"
        Write-Host $_.Exception.Message
    }
    Wait-ITToolkit
}

function Show-StorageDiagnosticsMenu {
    do {
        Show-Header -Title "Storage Diagnostics"
        Write-Host "1. Logical drive health"
        Write-Host "2. Physical disk health"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""
        $choice = Read-Host "Select an option"
        switch ($choice.ToUpper()) {
            "1" {
                Show-Header -Title "Logical Drive Health"
                Write-Host "Checking logical drives..."
                Write-Host ""
                $volumes = Get-ITStorageHealth
                if ($volumes) {
                    $volumes |
                        Format-Table -Property Drive, VolumeName, FileSystem, SizeGB, FreeGB, FreePercent, Status -AutoSize
                }
                else {
                    Write-Host "No fixed logical drives were found."
                }
                Wait-ITToolkit
            }
            "2" {
                Show-Header -Title "Physical Disk Health"
                Write-Host "Checking physical disks..."
                Write-Host ""
                $disks = Get-ITPhysicalDiskHealth
                if ($disks) {
                    $disks |
                        Format-Table -Property FriendlyName, MediaType, BusType, Size, HealthStatus, OperationalStatus -AutoSize
                }
                else {
                    Write-Host "No physical disk information was returned."
                }
                Wait-ITToolkit
            }
            "B" {
                return
            }
            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

function Show-WindowsUpdateDiagnosticsMenu {
    do {
        Show-Header -Title "Windows Update Diagnostics"
        Write-Host "1. Available updates"
        Write-Host "2. Update history"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""
        $choice = Read-Host "Select an option"
        switch ($choice.ToUpper()) {
            "1" {
                Show-Header -Title "Available Windows Updates"
                Write-Host "Checking for available updates..."
                Write-Host ""
                Write-Host "This may take a few moments."
                Write-Host ""
                $result = Get-ITWindowsUpdateStatus
                if ($result.Error) {
                    Write-Host "Unable to retrieve update information."
                    Write-Host ""
                    Write-Host "Error:"
                    Write-Host $result.Error
                }
                elseif ($result.UpdateCount -eq 0) {
                    Write-Host "No pending software updates were found."
                }
                else {
                    Write-Host "Updates found: $($result.UpdateCount)"
                    Write-Host ""
                    $result.Updates |
                        Format-Table -Property Title, Severity, KB, RebootNeeded -AutoSize
                }
                Wait-ITToolkit
            }
            "2" {
                Show-Header -Title "Windows Update History"
                Write-Host "Retrieving Windows Update history..."
                Write-Host ""
                $history = Get-ITWindowsUpdateHistory
                if ($history) {
                    $history |
                        Format-Table -Property @{ Name = 'Date'; Expression = { $_.Date } }, Title, ResultCode, HResult -AutoSize
                }
                else {
                    Write-Host "No Windows Update history was returned."
                }
                Wait-ITToolkit
            }
            "B" {
                return
            }
            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

function Show-PerformanceDiagnosticsMenu {
    do {
        Show-Header -Title "Performance Diagnostics"
        Write-Host "1. Performance snapshot"
        Write-Host "2. Top CPU processes"
        Write-Host "3. Top memory processes"
        Write-Host "4. Startup items"
        Write-Host "5. Live performance sample"
        Write-Host "6. Process details"
        Write-Host ""
        Write-Host "B. Back"
        Write-Host ""
        $choice = Read-Host "Select an option"
        switch ($choice.ToUpper()) {
            "1" {
                Show-Header -Title "Performance Snapshot"
                Write-Host "Collecting current performance information..."
                Write-Host ""
                Get-ITPerformanceSnapshot |
                    Format-List
                Wait-ITToolkit
            }
            "2" {
                Show-Header -Title "Top CPU Processes"
                $topInput = Read-Host "Number of processes to show (default: 10)"
                if ([string]::IsNullOrWhiteSpace($topInput)) {
                    $top = 10
                }
                elseif (
                    $topInput -match '^\d+$' -and
                    [int]$topInput -ge 1 -and
                    [int]$topInput -le 50
                ) {
                    $top = [int]$topInput
                }
                else {
                    Write-Host ""
                    Write-Host "Enter a value between 1 and 50."
                    Wait-ITToolkit
                    continue
                }
                Write-Host ""
                Write-Host "Top $top processes by accumulated CPU time"
                Write-Host ""
                Get-ITTopProcesses -Top $top |
                    Format-Table -Property ProcessName, Id, CPU, WorkingSet64, Handles -AutoSize
                Write-Host ""
                Write-Host "Note: CPU represents accumulated processor time, not live CPU percentage."
                Wait-ITToolkit
            }
            "3" {
                Show-Header -Title "Top Memory Processes"
                $topInput = Read-Host "Number of processes to show (default: 10)"
                if ([string]::IsNullOrWhiteSpace($topInput)) {
                    $top = 10
                }
                elseif (
                    $topInput -match '^\d+$' -and
                    [int]$topInput -ge 1 -and
                    [int]$topInput -le 50
                ) {
                    $top = [int]$topInput
                }
                else {
                    Write-Host ""
                    Write-Host "Enter a value between 1 and 50."
                    Wait-ITToolkit
                    continue
                }
                Write-Host ""
                Write-Host "Top $top processes by working-set memory"
                Write-Host ""
                Get-ITMemoryConsumers -Top $top |
                    Format-Table -Property ProcessName, Id, MemoryMB, Handles -AutoSize
                Wait-ITToolkit
            }
            "4" {
                Show-Header -Title "Startup Items"
                Write-Host "Collecting startup items..."
                Write-Host ""
                $items = Get-ITStartupItems
                if ($items) {
                    $items |
                        Format-Table -Property Name, Command, Location, User -AutoSize -Wrap
                }
                else {
                    Write-Host "No startup items were returned."
                }
                Wait-ITToolkit
            }
            "5" {
                Show-Header -Title "Live Performance Sample"
                $sampleInput = Read-Host "Number of samples (default: 10, range: 2-60)"
                if ([string]::IsNullOrWhiteSpace($sampleInput)) {
                    $samples = 10
                }
                elseif (
                    $sampleInput -match '^\d+$' -and
                    [int]$sampleInput -ge 2 -and
                    [int]$sampleInput -le 60
                ) {
                    $samples = [int]$sampleInput
                }
                else {
                    Write-Host ""
                    Write-Host "Enter a value between 2 and 60."
                    Wait-ITToolkit
                    continue
                }
                $intervalInput = Read-Host "Interval in seconds (default: 1, range: 1-10)"
                if ([string]::IsNullOrWhiteSpace($intervalInput)) {
                    $interval = 1
                }
                elseif (
                    $intervalInput -match '^\d+$' -and
                    [int]$intervalInput -ge 1 -and
                    [int]$intervalInput -le 10
                ) {
                    $interval = [int]$intervalInput
                }
                else {
                    Write-Host ""
                    Write-Host "Enter a value between 1 and 10 seconds."
                    Wait-ITToolkit
                    continue
                }
                Write-Host ""
                Write-Host "Collecting $samples performance samples..."
                Write-Host ""
                Write-Host "Interval: $interval second(s)"
                Write-Host ""
                try {
                    $result = Get-ITPerformanceSample `
                        -Samples $samples `
                        -IntervalSeconds $interval
                    Write-Host "Summary"
                    Write-Host "======="
                    Write-Host ""
                    Write-Host "Samples          : $($result.SampleCount)"
                    Write-Host "Interval         : $($result.IntervalSeconds) second(s)"
                    Write-Host "Average CPU      : $($result.CPUAveragePercent)%"
                    Write-Host "Peak CPU         : $($result.CPUPeakPercent)%"
                    Write-Host "Average Memory   : $($result.MemoryAveragePercent)%"
                    Write-Host "Peak Memory      : $($result.MemoryPeakPercent)%"
                    Write-Host ""
                    Write-Host "Samples"
                    Write-Host "======="
                    Write-Host ""
                    $result.Samples |
                        Format-Table -Property Sample, Timestamp, CPUUsagePercent, MemoryUsedPercent -AutoSize
                }
                catch {
                    Write-Host ""
                    Write-Host "Unable to collect performance samples."
                    Write-Host ""
                    Write-Host "Error:"
                    Write-Host $_.Exception.Message
                }
                Wait-ITToolkit
            }
            "6" {
                Show-Header -Title "Process Details"
                Write-Host "Use Top CPU or Top Memory Processes to identify a process ID."
                Write-Host ""
                $processIdInput = Read-Host "Enter process ID"
                if (
                    $processIdInput -notmatch '^\d+$' -or
                    [int64]$processIdInput -lt 1 -or
                    [int64]$processIdInput -gt 2147483647
                ) {
                    Write-Host ""
                    Write-Host "Enter a valid process ID."
                    Wait-ITToolkit
                    continue
                }
                $processId = [int]$processIdInput
                Write-Host ""
                Write-Host "Collecting details for process ID $processId..."
                Write-Host ""
                $process = Get-ITProcessDetails `
                    -Id $processId
                if ($process.Error) {
                    Write-Host "Unable to retrieve process details."
                    Write-Host ""
                    Write-Host "Error:"
                    Write-Host $process.Error
                }
                else {
                    $process |
                        Format-List -Property ProcessName, Id, CPUTimeSeconds, MemoryMB, Handles, Threads, StartTime, ParentProcessId, Path, CommandLine
                }
                Wait-ITToolkit
            }
            "B" {
                return
            }
            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

function Show-MainMenu {
    do {
        Show-Header -Title "Windows Support Toolkit"
        Write-Host "1. System Information"
        Write-Host "2. Network Diagnostics"
        Write-Host "3. Windows Diagnostics"
        Write-Host "4. Generate Diagnostic Report"
        Write-Host "5. System Health Analysis"
        Write-Host "6. Storage Diagnostics"
        Write-Host "7. Windows Update Diagnostics"
        Write-Host "8. Performance Diagnostics"
        Write-Host ""
        Write-Host "Q. Exit"
        Write-Host ""
        $selection = Read-Host "Select an option"
        switch ($selection.ToUpper()) {
            "1" {
                Show-SystemInformation
            }
            "2" {
                Show-NetworkDiagnosticsMenu
            }
            "3" {
                Show-WindowsDiagnosticsMenu
            }
            "4" {
                Show-DiagnosticReportMenu
            }
            "5" {
                Show-SystemHealthAnalysis
            }
            "6" {
                Show-StorageDiagnosticsMenu
            }
            "7" {
                Show-WindowsUpdateDiagnosticsMenu
            }
            "8" {
                Show-PerformanceDiagnosticsMenu
            }
            "Q" {
                return
            }
            default {
                Write-Host ""
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

Show-MainMenu
