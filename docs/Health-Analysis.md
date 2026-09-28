# System Health Analysis

System Health Analysis adds a simple interpretation layer on top of IT-Toolkit's existing diagnostic modules.

Instead of only displaying raw information, the feature evaluates several common Windows support indicators and presents them using clear severity levels.

## Severity Levels

IT-Toolkit currently uses:

- `Healthy`
- `Information`
- `Warning`
- `Critical`

These statuses are intended as troubleshooting indicators rather than definitive diagnoses.

---

## Checks

### Internet Connectivity

- Connected: `Healthy`
- Connectivity test failed: `Critical`

### DNS Resolution

- Successful: `Healthy`
- Failed: `Critical`

### Pending Reboot

- No pending reboot: `Healthy`
- Pending reboot detected: `Warning`

### System Drive Free Space

- 20% or more free: `Healthy`
- 10% to 19.9% free: `Warning`
- Less than 10% free: `Critical`

### Recent System Errors

The current rule set checks Critical and Error events from the Windows System log over the previous 24 hours.

- 0-9 events: `Healthy`
- 10-24 events: `Warning`
- 25 or more events: `Critical`

### Stopped Automatic Services

Stopped automatic services are reported as:

`Information`

They are not automatically treated as warnings or critical issues because some Windows and third-party services may legitimately stop when not required.

---

## Overall Status

The overall status is derived from the most severe finding.

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

---

## Using the Toolkit

Launch:

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

Import the required modules and run:

```powershell
Get-ITHealthAnalysis
```

Example:

```text
OverallStatus : Warning
HealthyCount  : 3
WarningCount  : 2
CriticalCount : 0
InfoCount     : 1
```

Inspect the findings:

```powershell
$health = Get-ITHealthAnalysis

$health.Findings |
    Format-Table Area, Severity, Finding -AutoSize
```

---

## Interpretation

Health Analysis is intended to assist troubleshooting, not replace technical investigation.

For example:

- Event Log errors may be unrelated to the current issue.
- A pending reboot does not guarantee that restarting will resolve a problem.
- A stopped automatic service may be expected behaviour.
- Connectivity failures may be caused by filtering rather than a broken connection.

Results should always be interpreted in context.

---

## Testing

The module has a dedicated Pester test suite:

```text
tests/HealthAnalysis.Tests.ps1
```

Run it with:

```powershell
Invoke-Pester .\tests\HealthAnalysis.Tests.ps1 -Output Detailed
```

Run all project tests with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

---

## Privacy

Health Analysis runs locally.

It does not automatically upload diagnostic results to the project maintainer.

The analysis may process local system, network, service, storage, and Windows Event Log information.

Review output before sharing it externally.