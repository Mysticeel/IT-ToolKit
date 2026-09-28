# Windows Update Diagnostics

The Windows Update Diagnostics module provides quick checks for available Windows software updates and recent update history.

It is designed to help IT technicians investigate common Windows Update issues without manually navigating multiple Windows interfaces.

## Features

The Windows Update Diagnostics module currently provides:

- Available software update detection
- Update count
- Update titles
- KB article information
- Update severity where available
- Reboot requirement information
- Windows Update history
- Update result codes
- HRESULT values

---

## Using the Toolkit

Launch IT-Toolkit:

```powershell
.\src\Start-ITToolkit.ps1
```

From the main menu select:

```text
7. Windows Update Diagnostics
```

The menu provides:

```text
1. Available updates
2. Update history

B. Back
```

---

## Available Updates

The Available Updates check searches Windows Update for software updates that are not currently installed.

From the Windows Update Diagnostics menu select:

```text
1. Available updates
```

The toolkit may take a few moments while Windows searches for updates.

Information returned may include:

- Update title
- Severity
- KB number
- Reboot requirement

### PowerShell Usage

Run:

```powershell
Get-ITWindowsUpdateStatus
```

Example output:

```text
UpdateCount : 2
Updates     : {...}
Error       :
```

Inspect individual updates:

```powershell
$result = Get-ITWindowsUpdateStatus

$result.Updates |
    Format-Table Title, Severity, KB, RebootNeeded -AutoSize
```

### No Updates Found

If no pending software updates are detected, the function returns:

```text
UpdateCount : 0
```

---

## Windows Update History

The Update History feature retrieves recent Windows Update history entries.

From the Windows Update Diagnostics menu select:

```text
2. Update history
```

### PowerShell Usage

Run:

```powershell
Get-ITWindowsUpdateHistory
```

By default, the function returns up to 20 entries.

Specify a custom number:

```powershell
Get-ITWindowsUpdateHistory -MaxEntries 10
```

The supported range is:

```text
1-100
```

Returned information includes:

- Date
- Update title
- Result code
- HRESULT

---

## Result Codes

Windows Update history may return numeric result codes.

These values should be interpreted alongside the update title and HRESULT.

A failed update entry does not automatically indicate an ongoing issue.

For example:

- A later installation may have succeeded
- An update may have been superseded
- A temporary network issue may have caused an earlier failure
- A restart may have completed the installation later

---

## Errors

If Windows Update information cannot be retrieved, the toolkit returns error information where possible.

Possible causes include:

- Windows Update service problems
- Windows Update API errors
- Network connectivity issues
- Update service configuration
- Policy restrictions
- Insufficient permissions

Results should be investigated in context.

---

## Available Functions

| Function | Description |
| --- | --- |
| `Get-ITWindowsUpdateStatus` | Searches for pending Windows software updates |
| `Get-ITWindowsUpdateHistory` | Retrieves recent Windows Update history |

---

## Requirements

Windows Update Diagnostics requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Windows Update components
- Access to the Microsoft Update COM interfaces used by Windows
- Appropriate permissions to query update information

The update search may require network connectivity depending on the system configuration.

---

## Testing

The Windows Update Diagnostics module has a dedicated Pester test suite:

```text
tests/WindowsUpdateDiagnostics.Tests.ps1
```

Run it with:

```powershell
Invoke-Pester .\tests\WindowsUpdateDiagnostics.Tests.ps1 -Output Detailed
```

Run the complete project test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

GitHub Actions also executes the project test suite automatically when repository changes are submitted.

---

## Performance

Searching for Windows Updates may take longer than other IT-Toolkit diagnostics.

This is expected because the Windows Update API may need to query the local update configuration and available update sources.

The toolkit displays a message before beginning the search.

---

## Privacy

Windows Update diagnostics run locally.

IT-Toolkit does not automatically upload update information to the project maintainer.

Diagnostic output may contain:

- Installed or pending update titles
- KB numbers
- Update history
- Error codes
- Update timestamps

Review output before sharing it externally.

---

## Security

IT-Toolkit does not automatically install updates.

The Windows Update Diagnostics module currently performs read-only diagnostic checks.

IT-Toolkit should only be used on systems you own or are authorised to administer.