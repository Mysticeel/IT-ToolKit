# System Health Analysis

System Health Analysis provides a severity-based interpretation layer across multiple IT-Toolkit diagnostic modules.

Instead of only displaying raw system information, it evaluates several common Windows support indicators and presents them as structured findings with recommendations.

## Severity Levels

IT-Toolkit currently uses:

- `Healthy`
- `Information`
- `Warning`
- `Critical`

These statuses are intended as troubleshooting indicators rather than definitive diagnoses.

---

## Integrated Health Areas

System Health Analysis currently evaluates:

- Internet connectivity
- DNS resolution
- Pending reboot state
- Storage health
- Recent System event errors
- Stopped automatic services
- Windows Update status
- CPU usage
- Memory usage

---

## Internet Connectivity

- Connected → `Healthy`
- Connectivity test failed → `Critical`

A failed test may also be caused by filtering or network policy, so the result should be interpreted in context.

---

## DNS Resolution

- Successful → `Healthy`
- Failed → `Critical`

Possible causes include:

- DNS server configuration
- Network connectivity
- VPN configuration
- Firewall rules
- DNS service availability

---

## Pending Reboot

- No pending reboot → `Healthy`
- Pending reboot detected → `Warning`

The toolkit checks Windows reboot indicators and may recommend restarting Windows when appropriate.

A pending reboot does not guarantee that restarting will resolve the issue being investigated.

---

## Storage Health

Storage Health is now evaluated across all detected fixed logical drives.

Current thresholds are:

- 20% or more free → `Healthy`
- 10% to 19.9% free → `Warning`
- Less than 10% free → `Critical`

If multiple drives are affected, the finding identifies the relevant drive letters and free-space percentages.

If storage status cannot be determined, the result is reported as `Information`.

---

## Recent System Errors

The toolkit evaluates Critical and Error entries in the Windows System event log over the previous 24 hours.

Current thresholds are:

- 0–9 events → `Healthy`
- 10–24 events → `Warning`
- 25 or more events → `Critical`

Event counts alone do not prove that the events caused the issue being investigated.

Repeated Event IDs and providers should be reviewed for relevance.

---

## Stopped Automatic Services

Stopped automatic services are reported as:

```text
Information
```

They are not automatically treated as a fault because some Windows and third-party services may legitimately stop when not required.

Where stopped automatic services are present, IT-Toolkit recommends reviewing them only where relevant to the reported issue.

---

## Windows Update

Windows Update status is now included in Health Analysis.

Current rules are:

- 0 pending updates → `Healthy`
- 1–4 pending updates → `Information`
- 5 or more pending updates → `Warning`
- Update status unavailable → `Information`

Pending updates are not automatically treated as faults.

IT-Toolkit does not automatically install updates.

---

## CPU Usage

CPU usage is evaluated from the current performance snapshot.

Current thresholds are:

- Below 80% → `Healthy`
- 80% to 94.9% → `Warning`
- 95% or higher → `Critical`

A single CPU snapshot may capture a temporary spike.

High CPU findings should be compared with current process activity and observed over time where appropriate.

---

## Memory Usage

Memory usage is also evaluated from the current performance snapshot.

Current thresholds are:

- Below 80% → `Healthy`
- 80% to 89.9% → `Warning`
- 90% or higher → `Critical`

High memory usage does not automatically indicate a fault because Windows may make use of available memory for caching and active applications.

---

## Overall Status

The overall health status reflects the most severe finding.

If any finding is:

```text
Critical
```

the overall status becomes:

```text
Critical
```

Otherwise, if any finding is:

```text
Warning
```

the overall status becomes:

```text
Warning
```

If no Critical or Warning findings exist, the overall status is:

```text
Healthy
```

`Information` findings do not raise the overall status by themselves.

---

## Using the Toolkit

Launch IT-Toolkit:

```powershell
.\src\Start-ITToolkit.ps1
```

Then select:

```text
5. System Health Analysis
```

The toolkit displays:

- Overall status
- Healthy finding count
- Warning count
- Critical count
- Information count
- Individual findings
- Recommended actions where applicable

---

## PowerShell Usage

Run:

```powershell
Get-ITHealthAnalysis
```

Example:

```text
OverallStatus : Warning
HealthyCount  : 5
WarningCount  : 2
CriticalCount : 0
InfoCount     : 2
```

Inspect findings:

```powershell
$health = Get-ITHealthAnalysis

$health.Findings |
    Format-Table Area, Severity, Finding -AutoSize -Wrap
```

---

## Current Health Areas

| Area | Purpose |
| --- | --- |
| Internet | External connectivity status |
| DNS | Name-resolution status |
| Windows | Pending reboot state |
| Storage | Free-space health across fixed drives |
| Event Logs | Recent System Critical/Error count |
| Services | Stopped automatic-service information |
| Windows Update | Pending update status |
| CPU | Current CPU utilisation |
| Memory | Current memory utilisation |

---

## Recommendations

Findings may include recommended troubleshooting actions.

Examples include:

- Check gateway and upstream connectivity
- Review DNS configuration
- Restart Windows when appropriate
- Free disk space
- Review repeated System Event IDs
- Review stopped services where relevant
- Review pending Windows updates
- Investigate sustained CPU usage
- Investigate high-memory processes

Recommendations are guidance only and do not perform automatic remediation.

---

## Testing

The Health Analysis module has a dedicated Pester test suite:

```text
tests/HealthAnalysis.Tests.ps1
```

Run it with:

```powershell
Invoke-Pester .\tests\HealthAnalysis.Tests.ps1 -Output Detailed
```

Run the complete project suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

---

## Privacy

Health Analysis runs locally.

It does not automatically upload diagnostic results to the project maintainer.

The analysis may process:

- System information
- Network information
- Storage information
- Windows Update information
- Service information
- Process and performance information
- Windows Event Log information

Review output before sharing it externally.

---

## Security

System Health Analysis is currently diagnostic and read-only.

It does not automatically:

- Restart Windows
- Install updates
- Stop services
- Terminate processes
- Delete files
- Modify storage configuration

IT-Toolkit should only be used on systems you own or are authorised to administer.