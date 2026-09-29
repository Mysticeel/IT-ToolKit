# IT-Toolkit

IT-Toolkit is a modular PowerShell troubleshooting and diagnostic toolkit for Windows support technicians.

It provides a collection of read-only tools for quickly gathering system information, checking network connectivity, reviewing Windows health, analysing storage and update status, investigating performance issues, and generating diagnostic reports.

The toolkit can be used either through an interactive menu or by importing it as a PowerShell module.

---

## Features

IT-Toolkit currently includes:

| Area | Capabilities |
|---|---|
| System Information | Hardware, operating system, memory, uptime, storage and user information |
| Network Diagnostics | Network adapters, internet connectivity, DNS, TCP port tests, traceroute and Wi-Fi information |
| Windows Diagnostics | Pending reboot state, stopped automatic services and recent System errors |
| Storage Diagnostics | Logical drive health and physical disk information |
| Windows Update Diagnostics | Available updates and update history |
| Performance Diagnostics | CPU, memory, processes, startup items, live performance sampling and process inspection |
| System Health Analysis | Severity-based interpretation of diagnostic information |
| Diagnostic Reports | HTML, text and JSON diagnostic reports |

---

## Requirements

IT-Toolkit is designed for:

- Windows 10
- Windows 11
- Windows PowerShell 5.1 or later

Some diagnostic information may require elevated permissions.

Certain Windows management interfaces may not be available in every environment.

---

# Getting Started

Clone the repository:

```powershell
git clone https://github.com/Mysticeel/IT-Toolkit.git
```

Move into the repository:

```powershell
cd IT-Toolkit
```

---

## Interactive Toolkit

Start IT-Toolkit with:

```powershell
.\src\Start-ITToolkit.ps1
```

The main menu provides:

```text
============================================
               IT-Toolkit
============================================
 Windows Support Toolkit
============================================

1. System Information
2. Network Diagnostics
3. Windows Diagnostics
4. Generate Diagnostic Report
5. System Health Analysis
6. Storage Diagnostics
7. Windows Update Diagnostics
8. Performance Diagnostics

Q. Exit
```

---

# PowerShell Module

IT-Toolkit can also be imported as a PowerShell module.

From the repository root:

```powershell
Import-Module .\src\IT-Toolkit.psd1
```

View the available public commands:

```powershell
Get-Command -Module IT-Toolkit
```

This allows individual toolkit functions to be used directly in PowerShell scripts or troubleshooting sessions.

Examples:

```powershell
Get-ITSystemInformation
```

```powershell
Get-ITNetworkInformation
```

```powershell
Get-ITPerformanceSnapshot
```

```powershell
Get-ITHealthAnalysis
```

---

# System Information

System Information provides a quick overview of the current Windows system.

Information may include:

- Computer name
- Manufacturer
- Model
- Serial number
- Operating system
- OS version
- Architecture
- Processor
- Memory
- System drive information
- Current user
- PowerShell version
- Administrator status
- System uptime

Example:

```powershell
Get-ITSystemInformation
```

Documentation:

```text
docs/System-Information.md
```

---

# Network Diagnostics

Network Diagnostics provides tools for investigating Windows connectivity issues.

Available features include:

- Active physical network adapters
- Optional virtual network adapters
- Internet connectivity testing
- DNS resolution testing
- TCP port connectivity testing
- Traceroute
- Wi-Fi connection information

Example:

```powershell
Get-ITNetworkInformation
```

Test DNS:

```powershell
Test-ITDNSResolution -Name github.com
```

Test a TCP port:

```powershell
Test-ITTCPPort `
    -ComputerName github.com `
    -Port 443
```

Trace a route:

```powershell
Invoke-ITTraceRoute `
    -ComputerName github.com
```

Documentation:

```text
docs/Network-Diagnostics.md
```

---

# Windows Diagnostics

Windows Diagnostics provides checks for common Windows support issues.

Features include:

- Pending reboot detection
- Stopped automatic services
- Recent Critical and Error events from the System log

Examples:

```powershell
Get-ITPendingReboot
```

```powershell
Get-ITServiceHealth
```

```powershell
Get-ITRecentSystemErrors -Hours 24
```

---

# Storage Diagnostics

Storage Diagnostics provides information about logical drives and available physical disks.

Features include:

- Drive size
- Free space
- Free-space percentage
- Logical drive health status
- Physical disk health
- Media type
- Bus type
- Operational status

Examples:

```powershell
Get-ITStorageHealth
```

```powershell
Get-ITPhysicalDiskHealth
```

---

# Windows Update Diagnostics

Windows Update Diagnostics provides read-only information about update status.

Features include:

- Pending software updates
- Update count
- Update title
- KB information
- Severity
- Reboot requirement
- Windows Update history

Examples:

```powershell
Get-ITWindowsUpdateStatus
```

```powershell
Get-ITWindowsUpdateHistory
```

IT-Toolkit does not automatically install Windows Updates.

---

# Performance Diagnostics

Performance Diagnostics provides tools for investigating slow or resource-constrained Windows systems.

Features include:

- Performance snapshot
- CPU usage
- Memory usage
- System uptime
- Top processes by accumulated CPU time
- Top memory consumers
- Startup items
- Live performance sampling
- Detailed process inspection

Example:

```powershell
Get-ITPerformanceSnapshot
```

Top CPU processes:

```powershell
Get-ITTopProcesses -Top 10
```

Top memory processes:

```powershell
Get-ITMemoryConsumers -Top 10
```

Live performance sampling:

```powershell
Get-ITPerformanceSample `
    -Samples 10 `
    -IntervalSeconds 1
```

Inspect a process:

```powershell
Get-ITProcessDetails -Id 1234
```

Documentation:

```text
docs/Performance-Diagnostics.md
```

---

# System Health Analysis

System Health Analysis combines information from multiple toolkit modules and produces severity-based findings.

Health areas currently include:

- Internet connectivity
- DNS
- Windows reboot state
- Storage
- Windows System event errors
- Automatic services
- Windows Update
- CPU usage
- Memory usage

Severity values include:

```text
Healthy
Information
Warning
Critical
```

Example:

```powershell
Get-ITHealthAnalysis
```

Health Analysis is designed to support troubleshooting and does not replace administrator investigation.

Documentation:

```text
docs/Health-Analysis.md
```

---

# Diagnostic Reports

IT-Toolkit can generate a unified diagnostic report containing information from multiple modules.

Supported formats:

- HTML
- Plain text
- JSON

Collect report data:

```powershell
$report = Get-ITDiagnosticReportData
```

Generate HTML:

```powershell
Export-ITDiagnosticReportHtml `
    -Report $report `
    -Path .\reports\diagnostic-report.html
```

Generate text:

```powershell
Export-ITDiagnosticReportText `
    -Report $report `
    -Path .\reports\diagnostic-report.txt
```

Generate JSON:

```powershell
Export-ITDiagnosticReportJson `
    -Report $report `
    -Path .\reports\diagnostic-report.json
```

The interactive toolkit also provides:

```text
1. Generate HTML report
2. Generate text report
3. Generate JSON report
4. Generate HTML + text
5. Generate all formats
```

Documentation:

```text
docs/Diagnostic-Reports.md
```

---

# JSON Integration

JSON reports provide a machine-readable representation of diagnostic information.

Example:

```powershell
$json = Get-Content `
    .\reports\diagnostic-report.json `
    -Raw |
    ConvertFrom-Json
```

Then access individual areas:

```powershell
$json.Summary
$json.System
$json.Network
$json.Storage
$json.WindowsUpdate
$json.Performance
$json.Health
```

Potential use cases include:

- Automation
- Ticketing integrations
- APIs
- Reporting systems
- Dashboards
- Diagnostic processing

IT-Toolkit does not automatically transmit report information anywhere.

---

# Public Commands

The module currently exposes functions including:

```text
Get-ITSystemInformation

Get-ITNetworkInformation
Test-ITInternetConnection
Test-ITDNSResolution
Test-ITTCPPort
Invoke-ITTraceRoute
Get-ITWiFiInformation

Get-ITPendingReboot
Get-ITServiceHealth
Get-ITRecentSystemErrors

Get-ITDiagnosticReportData
Export-ITDiagnosticReportText
Export-ITDiagnosticReportHtml
Export-ITDiagnosticReportJson

Get-ITHealthAnalysis

Get-ITStorageHealth
Get-ITPhysicalDiskHealth

Get-ITWindowsUpdateStatus
Get-ITWindowsUpdateHistory

Get-ITPerformanceSnapshot
Get-ITTopProcesses
Get-ITMemoryConsumers
Get-ITStartupItems
Get-ITPerformanceSample
Get-ITProcessDetails
```

The public command interface is defined through:

```text
src/IT-Toolkit.psd1
```

---

# Repository Structure

```text
IT-Toolkit/
│
├── README.md
├── CHANGELOG.md
├── LICENSE
│
├── docs/
│   ├── Diagnostic-Reports.md
│   ├── Health-Analysis.md
│   ├── Network-Diagnostics.md
│   ├── Performance-Diagnostics.md
│   └── System-Information.md
│
├── src/
│   ├── IT-Toolkit.psd1
│   ├── Start-ITToolkit.ps1
│   │
│   └── modules/
│       ├── DiagnosticReport.psm1
│       ├── HealthAnalysis.psm1
│       ├── NetworkDiagnostics.psm1
│       ├── PerformanceDiagnostics.psm1
│       ├── StorageDiagnostics.psm1
│       ├── SystemInformation.psm1
│       ├── WindowsDiagnostics.psm1
│       └── WindowsUpdateDiagnostics.psm1
│
└── tests/
```

Generated diagnostic reports are stored under:

```text
reports/
```

and should not be committed to the repository.

---

# Testing

IT-Toolkit uses Pester for automated testing.

Run all tests:

```powershell
Invoke-Pester .\tests -Output Detailed
```

Individual suites can also be run:

```powershell
Invoke-Pester .\tests\PerformanceDiagnostics.Tests.ps1 -Output Detailed
```

```powershell
Invoke-Pester .\tests\DiagnosticReport.Tests.ps1 -Output Detailed
```

```powershell
Invoke-Pester .\tests\ModuleManifest.Tests.ps1 -Output Detailed
```

---

# Static Analysis

IT-Toolkit uses PSScriptAnalyzer for PowerShell static analysis.

Run:

```powershell
Invoke-ScriptAnalyzer .\src\Start-ITToolkit.ps1
```

No output indicates that no findings were returned for the analyzed script under the active rules.

---

# Security

IT-Toolkit is currently designed around read-only troubleshooting and diagnostics.

It does not intentionally:

- Terminate processes
- Restart computers
- Modify network settings
- Install updates
- Delete files
- Change Windows services
- Disable startup applications
- Modify Windows performance settings

Some commands may require elevated permissions to return complete information.

Only use IT-Toolkit on systems you own or are authorised to administer.

---

# Privacy

Diagnostic output can contain system-specific information.

Examples include:

- Computer names
- Usernames
- Serial numbers
- IP addresses
- MAC addresses
- DNS information
- Service information
- Process information
- Event information
- Storage information
- Windows Update information

Detailed process inspection can also expose executable paths and command-line arguments.

Review diagnostic information before sharing it externally.

Generated reports should not be committed to a public repository.

---

# Development

The project is designed around small PowerShell modules rather than one large script.

When adding functionality:

1. Keep diagnostic collection inside an appropriate module.
2. Export only intended public functions.
3. Add Pester coverage.
4. Update documentation.
5. Run PSScriptAnalyzer.
6. Run the full test suite before merging.

---

# Versioning

IT-Toolkit uses semantic versioning.

Examples:

```text
v0.8.0
v0.9.0
v1.0.0
```

Major releases represent significant compatibility or project milestones.

Minor releases introduce new functionality while preserving compatibility where practical.

Patch releases are intended for fixes and smaller maintenance changes.

---

# v1.0.0

The v1.0.0 milestone introduces the first stable module packaging and reporting interface.

Highlights include:

- PowerShell module manifest
- Explicit public command interface
- Importable IT-Toolkit module
- HTML diagnostic reporting
- Text diagnostic reporting
- JSON diagnostic reporting
- Unified health analysis
- Storage diagnostics
- Windows Update diagnostics
- Performance diagnostics
- Live performance sampling
- Detailed process inspection
- Pester test coverage
- PSScriptAnalyzer compatibility

---

# License

See:

```text
LICENSE
```

for the project licence.

---

# Disclaimer

IT-Toolkit is intended to support troubleshooting and diagnostics.

Diagnostic results should be interpreted by an appropriate administrator or technician.

The toolkit does not guarantee that a system is healthy or unhealthy based solely on automated checks.