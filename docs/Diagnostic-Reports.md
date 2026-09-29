# Diagnostic Reports

IT-Toolkit includes a unified diagnostic reporting system that collects information from multiple toolkit modules and combines the results into a single report.

Diagnostic reports are designed to help IT support technicians collect a consistent snapshot of a Windows system for troubleshooting, documentation, and further analysis.

Reports can be generated in:

- HTML
- Plain text
- JSON

HTML and text reports are intended primarily for human-readable troubleshooting and review.

JSON reports provide a machine-readable representation of the same diagnostic information and can be used with automation, scripts, APIs, ticketing workflows, and other tools.

---

## Overview

Diagnostic reporting is provided by the `DiagnosticReport` module.

The main functions are:

```powershell
Get-ITDiagnosticReportData
Export-ITDiagnosticReportText
Export-ITDiagnosticReportHtml
Export-ITDiagnosticReportJson
```

The reporting process is separated into two stages:

1. Collect diagnostic information.
2. Export the collected information into the required format.

This allows the diagnostic information to be collected once and exported into multiple formats.

Example:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportHtml `
    -Report $report `
    -Path .\reports\diagnostic-report.html

Export-ITDiagnosticReportText `
    -Report $report `
    -Path .\reports\diagnostic-report.txt

Export-ITDiagnosticReportJson `
    -Report $report `
    -Path .\reports\diagnostic-report.json
```

---

## Report Contents

A unified diagnostic report contains information collected from the different IT-Toolkit diagnostic modules.

The main report sections are:

| Section | Description |
|---|---|
| `GeneratedAt` | Date and time the diagnostic information was collected |
| `System` | General Windows system and hardware information |
| `Network` | Network configuration and connectivity information |
| `Windows` | Windows health information such as reboot status, services, and recent errors |
| `Storage` | Logical drive and physical disk health |
| `WindowsUpdate` | Windows Update status |
| `Performance` | Current performance information and high-resource processes |
| `Health` | Overall system health analysis and findings |
| `Summary` | High-level diagnostic summary |

The exact information available can depend on the Windows system, permissions, installed components, and whether a particular Windows API is available.

---

## Collecting Report Data

Use:

```powershell
Get-ITDiagnosticReportData
```

Example:

```powershell
$report = Get-ITDiagnosticReportData
```

The returned object can be inspected directly:

```powershell
$report
```

Individual sections can also be accessed:

```powershell
$report.System
$report.Network
$report.Windows
$report.Storage
$report.WindowsUpdate
$report.Performance
$report.Health
$report.Summary
```

This is useful when only part of the diagnostic information is required.

---

## Report Summary

The `Summary` section provides a quick overview of some of the most useful diagnostic results.

It includes information such as:

- Overall health status
- Pending Windows Update count
- Current CPU usage
- Current memory usage

Example:

```powershell
$report = Get-ITDiagnosticReportData

$report.Summary
```

The summary is intended to provide a quick indication of the state of the system before reviewing the more detailed report sections.

---

# HTML Reports

HTML reports provide a formatted version of the diagnostic information that can be opened in a web browser.

Generate an HTML report with:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportHtml `
    -Report $report `
    -Path .\reports\diagnostic-report.html
```

The exporter creates the destination directory when required.

The generated HTML report includes sections for:

- Summary
- System Information
- Network Information
- Windows Health
- Storage
- Windows Update
- Performance
- Health Analysis

Health information is displayed using severity indicators to make warnings and critical findings easier to identify.

The generated report can then be opened locally:

```powershell
Start-Process .\reports\diagnostic-report.html
```

---

# Text Reports

Text reports provide a simple portable version of the diagnostic information.

Generate a text report with:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportText `
    -Report $report `
    -Path .\reports\diagnostic-report.txt
```

Text reports are useful when:

- HTML is unnecessary
- Diagnostic information needs to be viewed in a terminal
- A lightweight report is preferred
- Report contents need to be copied into another troubleshooting system

---

# JSON Reports

IT-Toolkit can export the unified diagnostic report as JSON.

JSON provides a structured, machine-readable representation of the diagnostic information.

Generate a JSON report with:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportJson `
    -Report $report `
    -Path .\reports\diagnostic-report.json
```

The exporter creates the destination directory when required.

---

## Why JSON Support Is Useful

JSON output makes IT-Toolkit diagnostic information easier to use with other scripts and systems.

Possible uses include:

- PowerShell automation
- API integrations
- Ticketing workflows
- Log processing
- Diagnostic data processing
- Dashboard integrations
- Automated analysis
- Archiving structured diagnostic results

IT-Toolkit does not automatically transmit JSON reports anywhere.

The report is written to the path specified by the user.

---

## Reading a JSON Report

A generated report can be imported back into PowerShell:

```powershell
$json = Get-Content `
    .\reports\diagnostic-report.json `
    -Raw |
    ConvertFrom-Json
```

The complete report can then be inspected:

```powershell
$json
```

Or individual sections can be accessed:

```powershell
$json.System
$json.Network
$json.Windows
$json.Storage
$json.WindowsUpdate
$json.Performance
$json.Health
$json.Summary
```

For example:

```powershell
$json.Summary
```

can be used to inspect the high-level diagnostic results.

---

## JSON Serialization Depth

PowerShell's `ConvertTo-Json` command requires a serialization depth when working with nested objects.

IT-Toolkit therefore allows the JSON depth to be configured.

The default depth is:

```text
10
```

The supported range is:

```text
3-100
```

For most IT-Toolkit reports, the default value should be sufficient.

A custom depth can be specified when required:

```powershell
Export-ITDiagnosticReportJson `
    -Report $report `
    -Path .\reports\diagnostic-report.json `
    -Depth 20
```

Values outside the supported range are rejected by parameter validation.

---

# Interactive Report Generation

Diagnostic reports can also be generated from the interactive IT-Toolkit interface.

Start the toolkit:

```powershell
.\src\Start-ITToolkit.ps1
```

From the main menu select:

```text
4. Generate Diagnostic Report
```

The report menu provides:

```text
1. Generate HTML report
2. Generate text report
3. Generate JSON report
4. Generate HTML + text
5. Generate all formats
B. Back
```

Diagnostic information is collected once and then exported into the selected format or formats.

---

## Generated Filenames

Interactive reports use a timestamp in their filename.

For example:

```text
IT-Toolkit-Diagnostic-20260929-221500.html
IT-Toolkit-Diagnostic-20260929-221500.txt
IT-Toolkit-Diagnostic-20260929-221500.json
```

The timestamp format is:

```text
yyyyMMdd-HHmmss
```

Reports generated through the interactive toolkit are stored in:

```text
reports\
```

The `reports` directory is excluded from Git by the repository `.gitignore`.

This helps prevent locally generated diagnostic information from being accidentally committed to the repository.

---

# Generate All Formats

Selecting:

```text
5. Generate all formats
```

generates HTML, text, and JSON versions from the same collected diagnostic data.

For example:

```text
reports\
├── IT-Toolkit-Diagnostic-20260929-221500.html
├── IT-Toolkit-Diagnostic-20260929-221500.txt
└── IT-Toolkit-Diagnostic-20260929-221500.json
```

Using the same timestamp makes it easy to identify reports that belong to the same diagnostic collection.

---

# Performance Information

Diagnostic reports include a performance snapshot.

The performance section includes information such as:

- CPU usage
- Total memory
- Used memory
- Free memory
- Memory usage percentage
- System uptime
- Top processes by accumulated CPU time
- Top processes by memory usage

The top CPU process information represents accumulated processor time.

It should not be interpreted as a live CPU usage percentage.

For live performance investigation, use the Performance Diagnostics functionality from the interactive toolkit.

---

# Health Analysis

Diagnostic reports include the results of the IT-Toolkit health analysis.

The health analysis evaluates several diagnostic areas and classifies findings using statuses such as:

```text
Healthy
Information
Warning
Critical
```

The report also includes an overall health status.

Health analysis is intended to highlight information that may deserve further investigation.

It should be treated as diagnostic guidance rather than a replacement for administrator investigation.

---

# Windows Update Information

The report includes the current Windows Update status.

This can include:

- Number of available updates
- Update information
- Whether update information could be retrieved successfully

Windows Update diagnostics are read-only.

IT-Toolkit does not automatically install updates or modify Windows Update configuration when generating a report.

---

# Storage Information

Storage reporting includes information about logical drives and available physical disk health information.

Logical drive information can include:

- Drive
- Volume name
- File system
- Total size
- Free space
- Free-space percentage
- Health status

The toolkit currently classifies logical drive free space using the following thresholds:

| Free Space | Status |
|---|---|
| 20% or more | Healthy |
| 10% to less than 20% | Warning |
| Less than 10% | Critical |

Physical disk information depends on what Windows exposes through `Get-PhysicalDisk`.

---

# Privacy and Sensitive Information

Diagnostic reports are designed for troubleshooting and may contain information about the computer on which the toolkit is run.

Depending on the available diagnostic information, reports may contain data such as:

- Computer name
- Current username
- Hardware manufacturer and model
- Device serial number
- Operating system information
- IP addresses
- Gateway information
- DNS server information
- Network adapter information
- Storage information
- Windows Update information
- Service information
- Event information
- Process information
- System health findings

Treat generated reports as diagnostic data.

Review a report before:

- Uploading it to GitHub
- Attaching it to a public issue
- Posting it in a forum
- Sending it to another person
- Uploading it to a third-party service

Generated diagnostic reports should not be committed to the IT-Toolkit repository.

The repository `.gitignore` excludes:

```text
reports/
```

However, `.gitignore` should not be treated as a security control.

Always review files before committing them.

---

## Process Privacy

Some process diagnostic commands available elsewhere in IT-Toolkit can return information such as:

- Executable paths
- Command-line arguments
- User-specific paths

Command-line arguments can potentially contain sensitive values.

Detailed process command lines are therefore not automatically added to the standard diagnostic report.

If process details are collected manually, review the information before sharing it.

---

# Read-Only Design

Diagnostic reporting is designed to collect and present information.

Generating a report does not intentionally:

- Change Windows settings
- Restart the computer
- Stop or start services
- Install Windows Updates
- Delete files
- Modify network configuration
- Terminate processes

Some diagnostic operations may require access to Windows management interfaces or elevated permissions to return complete information.

---

# Importing IT-Toolkit

From v1.0.0, the toolkit can be imported using its PowerShell module manifest.

From the repository root:

```powershell
Import-Module .\src\IT-Toolkit.psd1
```

The diagnostic reporting commands can then be viewed with:

```powershell
Get-Command -Module IT-Toolkit
```

For example:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportJson `
    -Report $report `
    -Path .\reports\diagnostic-report.json
```

The module manifest defines the public IT-Toolkit command interface rather than exposing every internal implementation detail.

---

# Testing

Diagnostic reporting is covered by Pester tests.

The test suite validates areas including:

- Report data collection
- Required report sections
- HTML export
- Text export
- JSON export
- JSON validity
- JSON report structure
- Custom JSON depth
- JSON depth validation
- Module exports

Run the complete test suite from the repository root:

```powershell
Invoke-Pester .\tests -Output Detailed
```

Static analysis can also be run against the interactive launcher:

```powershell
Invoke-ScriptAnalyzer .\src\Start-ITToolkit.ps1
```

No output from `Invoke-ScriptAnalyzer` indicates that no findings were returned for the analyzed script under the active rule set.