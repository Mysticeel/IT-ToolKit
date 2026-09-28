# Diagnostic Reports

The Diagnostic Reports feature combines information from multiple IT-Toolkit modules into a single troubleshooting report.

It is designed to give IT technicians a quick, portable overview of a Windows computer without manually collecting information from several different toolkit sections.

## Features

Diagnostic Reports currently include information from:

- System Information
- Network Diagnostics
- Windows Diagnostics

Reports can be exported as:

- HTML
- Plain text
- Both formats

---

## Using the Toolkit

Launch IT-Toolkit:

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
3. Generate both

B. Back
```

Generated reports are stored in:

```text
reports/
```

The `reports` directory is excluded from Git tracking so locally generated diagnostic reports are not automatically committed to the repository.

---

## Report Contents

The report currently contains four main sections.

### Summary

Provides a quick overview of:

- Internet connectivity
- DNS status
- Pending reboot state
- Free disk space
- Stopped automatic service count
- Recent System event error count

### System Information

Includes:

- Computer name
- Manufacturer
- Model
- Serial number
- Operating system
- OS version
- Architecture
- System uptime
- Processor
- Memory usage
- System drive usage
- Current user
- PowerShell version
- Administrator status

### Network

Includes:

- Active interface
- Adapter description
- IPv4 address
- Default gateway
- DNS servers
- MAC address
- Link speed
- Internet connectivity
- DNS resolution status

### Windows Health

Includes:

- Pending reboot status
- Pending reboot reasons
- Stopped automatic services
- Recent Critical and Error events from the Windows System log

---

## HTML Reports

HTML reports provide a formatted browser-based view of diagnostic information.

Example:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportHtml `
    -Report $report `
    -Path ".\reports\diagnostic-report.html"
```

Open the report:

```powershell
Start-Process ".\reports\diagnostic-report.html"
```

Dynamic report values are HTML encoded before being inserted into the report.

---

## Text Reports

Plain-text reports are useful for:

- Support tickets
- Email attachments
- Notes
- Command-line environments
- Simple archiving

Example:

```powershell
$report = Get-ITDiagnosticReportData

Export-ITDiagnosticReportText `
    -Report $report `
    -Path ".\reports\diagnostic-report.txt"
```

---

## Available Functions

| Function | Description |
| --- | --- |
| `Get-ITDiagnosticReportData` | Collects information from the toolkit's diagnostic modules |
| `Export-ITDiagnosticReportHtml` | Generates an HTML diagnostic report |
| `Export-ITDiagnosticReportText` | Generates a plain-text diagnostic report |

---

## Requirements

Diagnostic Reports require:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Access to the underlying IT-Toolkit diagnostic modules
- Permission to read the Windows information used by those modules

Some diagnostics may require network connectivity.

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

Run the complete project test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

GitHub Actions also runs the project's Pester tests automatically for repository changes.

---

## Privacy

Diagnostic reports can contain information about the computer and network on which they are generated.

This may include:

- Computer name
- Username
- Serial number
- IP addresses
- MAC addresses
- DNS servers
- Network gateway
- Service information
- Windows Event Log information

Reports are generated locally and are not automatically uploaded to the project maintainer.

Review reports before sharing them externally.

---

## Security

Do not commit generated diagnostic reports to the public IT-Toolkit repository.

The `reports/` directory should remain excluded through `.gitignore`.

IT-Toolkit should only be used on systems and networks you own or are authorised to administer.