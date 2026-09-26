# Windows Diagnostics

The Windows Diagnostics module provides quick checks for common Windows support and troubleshooting scenarios.

It is designed to help IT technicians quickly identify common Windows issues without needing to remember multiple PowerShell commands or manually search through different Windows management tools.

## Features

The Windows Diagnostics module currently provides:

- Pending reboot detection
- Automatic service health checks
- Recent Windows System critical and error event analysis

---

## Pending Reboot Detection

The Pending Reboot diagnostic checks Windows for indicators that the operating system is waiting for a restart.

A pending reboot can sometimes explain unexpected behaviour after:

- Windows Updates
- Software installations
- Driver installations
- Windows servicing operations
- Application updates

The toolkit currently checks the following Windows reboot indicators:

- Component Based Servicing
- Windows Update
- Pending file rename operations

### Using the Toolkit

From the main menu:

```text
1. System Information
2. Network Diagnostics
3. Windows Diagnostics
```

Select:

```text
3. Windows Diagnostics
```

Then select:

```text
1. Pending reboot status
```

### PowerShell Usage

The function can also be used directly:

```powershell
Get-ITPendingReboot
```

Example output:

```text
RebootRequired : True
Reasons        : Windows Update
```

If no reboot is required:

```text
RebootRequired : False
Reasons        :
```

The result should be treated as a diagnostic indicator rather than proof that a restart will resolve a particular issue.

---

## Service Health

The Service Health diagnostic identifies Windows services that:

- Are configured with an Automatic startup type
- Are not currently running

This can help identify services that may have failed to start or stopped unexpectedly.

### Using the Toolkit

From the Windows Diagnostics menu select:

```text
2. Automatic services not running
```

### PowerShell Usage

The function can also be used directly:

```powershell
Get-ITServiceHealth
```

Example output:

```text
Name        DisplayName              Status   StartType
----        -----------              ------   ---------
ExampleSvc  Example Service          Stopped  Automatic
```

### Important

A stopped automatic service does not necessarily indicate a fault.

Some Windows and third-party services may:

- Start only when required
- Stop when idle
- Use trigger-based startup
- Be deliberately stopped by another application

Service results should therefore be investigated in context before making configuration changes.

---

## Recent System Errors

The Recent System Errors diagnostic searches the Windows System event log for recent:

- Critical events
- Error events

This provides a quick way to identify significant Windows events that occurred around the time a problem was reported.

### Using the Toolkit

From the Windows Diagnostics menu select:

```text
3. Recent critical and error events
```

The toolkit will ask how many hours of event history should be checked.

The default is:

```text
24 hours
```

The supported range is:

```text
1-168 hours
```

### PowerShell Usage

Run the function directly:

```powershell
Get-ITRecentSystemErrors
```

Specify a custom time period:

```powershell
Get-ITRecentSystemErrors -Hours 48
```

Limit the number of returned events:

```powershell
Get-ITRecentSystemErrors -Hours 24 -MaxEvents 20
```

The function returns information including:

- Event timestamp
- Event ID
- Event severity
- Event provider
- Event message

### Example

```text
TimeCreated          Id    LevelDisplayName   ProviderName
-----------          --    ----------------   ------------
26/09/2026 09:15     7000  Error              Service Control Manager
26/09/2026 08:42     41    Critical           Microsoft-Windows-Kernel-Power
```

Event log entries should always be investigated in context.

An Error or Critical event does not automatically mean that the event caused the issue being investigated.

---

## Available Functions

The Windows Diagnostics module currently exports the following functions:

| Function | Description |
| --- | --- |
| `Get-ITPendingReboot` | Checks whether Windows reports that a restart is pending |
| `Get-ITServiceHealth` | Finds stopped services configured for automatic startup |
| `Get-ITRecentSystemErrors` | Retrieves recent Critical and Error events from the Windows System log |

---

## Requirements

Windows Diagnostics requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Access to Windows system information
- Permission to read the relevant Windows Event Logs

Some information may require the toolkit to be run with elevated permissions.

---

## Testing

The Windows Diagnostics module has an associated Pester test suite:

```text
tests/WindowsDiagnostics.Tests.ps1
```

Run the Windows Diagnostics tests with:

```powershell
Invoke-Pester .\tests\WindowsDiagnostics.Tests.ps1 -Output Detailed
```

Run the complete IT-Toolkit test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

---

## Privacy

Windows diagnostic information is collected locally on the computer running IT-Toolkit.

IT-Toolkit does not upload collected Windows diagnostic information to the project maintainer.

Diagnostic output may contain information about the local computer, including service names and Windows Event Log information.

Review diagnostic output before sharing it publicly.

---

## Security

IT-Toolkit should only be used on systems you own or are authorised to administer.

Before publishing diagnostic output to GitHub or another public location, review it for potentially sensitive information such as:

- Usernames
- Computer names
- Internal hostnames
- IP addresses
- Installed software
- Event log contents
- Internal infrastructure information
- Personal or confidential information

Do not commit sensitive diagnostic output to the IT-Toolkit repository.