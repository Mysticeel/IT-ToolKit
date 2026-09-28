# Performance Diagnostics

The Performance Diagnostics module provides quick checks for common Windows performance and slow-computer investigations.

It is designed to help IT technicians identify high resource usage, memory pressure, resource-intensive processes, and startup applications.

## Features

The Performance Diagnostics module currently provides:

- Performance snapshot
- CPU usage
- Memory usage
- System uptime
- Top processes by accumulated CPU time
- Top processes by memory usage
- Startup item discovery

---

## Using the Toolkit

Launch IT-Toolkit:

```powershell
.\src\Start-ITToolkit.ps1
```

From the main menu select:

```text
8. Performance Diagnostics
```

The menu provides:

```text
1. Performance snapshot
2. Top CPU processes
3. Top memory processes
4. Startup items

B. Back
```

---

## Performance Snapshot

The Performance Snapshot provides a quick overview of current system resource usage.

Information includes:

- CPU usage percentage
- Total physical memory
- Used memory
- Free memory
- Memory usage percentage
- System uptime

### PowerShell Usage

Run:

```powershell
Get-ITPerformanceSnapshot
```

Example output:

```text
CPUUsagePercent   : 14
TotalMemoryGB     : 16
UsedMemoryGB      : 8.4
FreeMemoryGB      : 7.6
MemoryUsedPercent : 52.5
UptimeDays        : 2
UptimeHours       : 6
```

Values shown above are examples only.

---

## Top CPU Processes

The Top CPU Processes check identifies processes with the highest accumulated processor time.

### PowerShell Usage

```powershell
Get-ITTopProcesses
```

Specify the number of results:

```powershell
Get-ITTopProcesses -Top 20
```

The supported range is:

```text
1-50
```

Returned information includes:

- Process name
- Process ID
- CPU time
- Working set
- Handle count

### Important

The `CPU` value returned by PowerShell represents accumulated processor time used by the process.

It is **not** the same as the live CPU percentage shown in Task Manager.

This feature is therefore useful for identifying processes that have consumed significant processor time during their lifetime, but it should not be treated as a live CPU utilisation ranking.

---

## Top Memory Processes

The Top Memory Processes check identifies processes using the largest working-set memory.

### PowerShell Usage

```powershell
Get-ITMemoryConsumers
```

Specify the number of results:

```powershell
Get-ITMemoryConsumers -Top 20
```

Returned information includes:

- Process name
- Process ID
- Memory usage in MB
- Handle count

Working-set memory represents the amount of physical memory currently associated with the process.

---

## Startup Items

The Startup Items diagnostic retrieves applications configured to start automatically with Windows or user sign-in.

### PowerShell Usage

```powershell
Get-ITStartupItems
```

Returned information may include:

- Name
- Command
- Startup location
- User

Startup information can be useful when investigating:

- Slow sign-in
- Long boot times
- Unexpected background applications
- Excessive startup activity

### Important

A startup application does not automatically indicate a performance problem.

Startup items should be reviewed in context before disabling or removing anything.

IT-Toolkit does not automatically disable startup applications.

---

## Available Functions

| Function | Description |
| --- | --- |
| `Get-ITPerformanceSnapshot` | Returns current CPU, memory, and uptime information |
| `Get-ITTopProcesses` | Returns processes ranked by accumulated CPU time |
| `Get-ITMemoryConsumers` | Returns processes ranked by working-set memory |
| `Get-ITStartupItems` | Returns discovered Windows startup items |

---

## Requirements

Performance Diagnostics requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Access to Windows process and CIM information

Some process information may vary depending on permissions.

---

## Testing

The Performance Diagnostics module has a dedicated Pester test suite:

```text
tests/PerformanceDiagnostics.Tests.ps1
```

Run it with:

```powershell
Invoke-Pester .\tests\PerformanceDiagnostics.Tests.ps1 -Output Detailed
```

Run the complete project test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

GitHub Actions also runs the project test suite automatically for repository changes.

---

## Interpretation

Performance information should be interpreted over time and in context.

A single snapshot may not identify intermittent performance problems.

For example:

- CPU usage may spike briefly during normal activity
- Memory usage may be high because Windows is caching data
- A process with high accumulated CPU time may not currently be busy
- Startup items may be legitimate and necessary

Performance Diagnostics is intended to provide a useful starting point for further investigation.

---

## Privacy

Performance Diagnostics runs locally.

It does not automatically upload diagnostic data to the project maintainer.

Output may contain:

- Process names
- Process IDs
- Memory usage
- Startup commands
- Usernames
- Application paths

Review output before sharing it externally.

---

## Security

IT-Toolkit does not automatically terminate processes, disable startup items, or modify Windows performance settings.

The Performance Diagnostics module is currently read-only.

IT-Toolkit should only be used on systems you own or are authorised to administer.