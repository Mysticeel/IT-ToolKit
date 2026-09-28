# Diagnostic Reports

Diagnostic Reports combine information from multiple IT-Toolkit modules into a single troubleshooting report.

The reporting system is designed to provide a portable overview of Windows system health without requiring technicians to manually collect data from each diagnostic section.

## Report Formats

IT-Toolkit can generate:

- HTML reports
- Plain-text reports
- Both formats in one operation

Generated reports are stored under:

```text
reports/
```

The `reports/` directory should remain excluded from Git tracking.

---

## Integrated Report Sections

Diagnostic Reports now include:

- Summary
- System Information
- Network
- Windows Health
- Storage
- Windows Update
- Performance
- Health Analysis

---

## Summary

The Summary section provides a quick overview of:

- Overall health
- Internet connectivity
- DNS status
- Pending reboot state
- System drive free space
- Pending Windows Update count
- CPU usage
- Memory usage
- Stopped automatic service count
- Recent System error count

---

## System Information

Includes:

- Computer name
- Manufacturer
- Model
- Serial number
- Operating system
- OS version
- Architecture
- Uptime
- Processor
- Total memory
- Used memory
- Free memory
- System drive
- Drive capacity
- Free disk space
- Current user
- PowerShell version
- Administrator status

---

## Network

Includes:

- Active interface
- Adapter description
- IPv4 address
- Default gateway
- DNS servers
- MAC address
- Link speed
- Internet connectivity
- Connectivity-test target
- DNS resolution status
- DNS test target
- Resolved addresses

---

## Windows Health

Includes:

- Pending reboot status
- Pending reboot reasons
- Stopped automatic service count
- Stopped automatic service details
- Recent System Critical/Error count
- Recent System event details

---

## Storage

The Storage section includes logical-drive and physical-disk information.

### Logical Drives

Includes:

- Drive letter
- Volume name
- File system
- Size
- Free space
- Free-space percentage
- Health status

Storage health statuses use:

- `Healthy`
- `Warning`
- `Critical`

### Physical Disks

Includes:

- Friendly name
- Media type
- Bus type
- Size
- Health status
- Operational status

Physical disk information depends on what Windows and the storage controller expose.

---

## Windows Update

Includes:

- Pending software update count
- Update title
- KB information
- Severity where available
- Reboot requirement
- Error information if update status cannot be determined

IT-Toolkit does not automatically install updates.

---

## Performance

Includes:

- CPU usage
- Memory usage
- Total memory
- Used memory
- Free memory
- Uptime
- Top CPU processes
- Top memory processes

### Top CPU Processes

CPU values represent accumulated processor time rather than live CPU percentage.

### Top Memory Processes

Memory values are based on process working-set memory.

---

## Health Analysis

The report now includes the integrated System Health Analysis result.

It displays:

- Overall status
- Healthy count
- Warning count
- Critical count
- Information count
- Area
- Severity
- Finding
- Recommendation

HTML reports use visual severity badges for:

- Healthy
- Information
- Warning
- Critical

---

## Using the Toolkit

Launch:

```powershell
.\src\Start-ITToolkit.ps1
```

Select:

```text
4. Generate Diagnostic Report
```

Then choose:

```text
1. Generate HTML report
2. Generate text report
3. Generate both

B. Back
```

---

## PowerShell Usage

Collect the report data:

```powershell
$report = Get-ITDiagnosticReportData
```

Generate HTML:

```powershell
Export-ITDiagnosticReportHtml `
    -Report $report `
    -Path ".\reports\diagnostic-report.html"
```

Generate plain text:

```powershell
Export-ITDiagnosticReportText `
    -Report $report `
    -Path ".\reports\diagnostic-report.txt"
```

---

## Available Functions

| Function | Description |
| --- | --- |
| `Get-ITDiagnosticReportData` | Collects unified diagnostic data |
| `Export-ITDiagnosticReportHtml` | Generates the HTML report |
| `Export-ITDiagnosticReportText` | Generates the plain-text report |

---

## HTML Reports

HTML reports provide:

- Structured sections
- Tables
- Overall health banner
- Severity badges
- Logical-drive status
- Update details
- Process information
- Health findings and recommendations

Dynamic diagnostic values are HTML encoded before being inserted into the report.

---

## Text Reports

Plain-text reports provide the same main diagnostic sections in a portable format suitable for:

- Support tickets
- Notes
- Email attachments
- Command-line environments
- Troubleshooting archives

---

## Performance

Unified reports perform more checks than earlier report versions.

Generating a report may take longer because it can query:

- Windows Update
- Event Logs
- Storage
- Physical disks
- Processes
- Performance information
- Network connectivity

This is expected.

---

## Testing

The Diagnostic Reports module has a dedicated Pester test suite:

```text
tests/DiagnosticReport.Tests.ps1
```

Run it with:

```powershell
Invoke-Pester .\tests\DiagnosticReport.Tests.ps1 -Output Detailed
```

Run all tests:

```powershell
Invoke-Pester .\tests -Output Detailed
```

GitHub Actions also executes the project's automated test suite.

---

## Privacy

Diagnostic reports are generated locally.

They are not automatically uploaded to the project maintainer.

Reports may contain:

- Computer names
- Usernames
- Serial numbers
- IP addresses
- MAC addresses
- DNS servers
- Network gateways
- Disk information
- Update information
- Process names
- Process IDs
- Application paths
- Service information
- Event Log information

Review every report before sharing it externally.

---

## Security

Generated reports should not be committed to the public repository.

The `reports/` directory should remain ignored through `.gitignore`.

Diagnostic Reports are read-only and do not automatically:

- Install updates
- Stop services
- Terminate processes
- Delete files
- Modify network configuration
- Change storage configuration

IT-Toolkit should only be used on systems and networks you own or are authorised to administer.