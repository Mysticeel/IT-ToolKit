# Performance Diagnostics

The Performance Diagnostics module provides read-only tools for investigating slow Windows systems, resource usage, running processes, startup activity, and short-term performance trends.

It is designed to help IT technicians move beyond a single snapshot and investigate what a computer is doing over a short period of time.

## Features

The Performance Diagnostics module currently provides:

- Performance snapshot
- CPU usage
- Memory usage
- System uptime
- Top processes by accumulated CPU time
- Top processes by working-set memory
- Startup item discovery
- Live performance sampling
- Detailed process inspection

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
5. Live performance sample
6. Process details

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

Supported range:

```text
1-50
```

Returned information includes:

- Process name
- Process ID
- Accumulated CPU time
- Working-set memory
- Handle count

### Important

The `CPU` property represents accumulated processor time used by a process during its lifetime.

It is not the same as live CPU percentage in Task Manager.

---

## Top Memory Processes

The Top Memory Processes check identifies processes using the most working-set memory.

### PowerShell Usage

```powershell
Get-ITMemoryConsumers
```

Specify the number of results:

```powershell
Get-ITMemoryConsumers -Top 20
```

Supported range:

```text
1-50
```

Returned information includes:

- Process name
- Process ID
- Working-set memory in MB
- Handle count

---

## Startup Items

Startup Items retrieves applications configured to start automatically with Windows or user sign-in.

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

A startup item does not automatically indicate a problem.

IT-Toolkit does not disable startup items automatically.

---

## Live Performance Sampling

Live Performance Sampling collects multiple CPU and memory snapshots over a configurable period.

This provides a better view of short-term performance behaviour than a single snapshot.

### PowerShell Usage

```powershell
Get-ITPerformanceSample
```

Default behaviour:

```text
Samples  : 10
Interval : 1 second
```

Specify custom values:

```powershell
Get-ITPerformanceSample `
    -Samples 20 `
    -IntervalSeconds 2
```

Supported sample range:

```text
2-60
```

Supported interval range:

```text
1-10 seconds
```

### Returned Summary

The function returns:

- Sample count
- Sampling interval
- Average CPU usage
- Peak CPU usage
- Average memory usage
- Peak memory usage
- Individual sample data

Example:

```text
SampleCount          : 10
IntervalSeconds      : 1
CPUAveragePercent    : 17.4
CPUPeakPercent       : 43
MemoryAveragePercent : 58.2
MemoryPeakPercent    : 59.1
```

Values shown above are examples only.

### Individual Samples

Individual samples include:

- Sample number
- Timestamp
- CPU usage percentage
- Memory usage percentage

Example:

```powershell
$result = Get-ITPerformanceSample `
    -Samples 5 `
    -IntervalSeconds 1

$result.Samples |
    Format-Table -AutoSize
```

### Interpretation

Sampling is useful when investigating issues such as:

- Intermittent CPU spikes
- Sustained high CPU usage
- Increasing memory usage
- Short periods of system slowdown

A short sample window may still miss intermittent problems.

Longer observation periods should be used where appropriate.

---

## Process Details

Process Details provides a deeper view of a specific running process.

### PowerShell Usage

First identify a process:

```powershell
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10 ProcessName, Id
```

Then inspect it:

```powershell
Get-ITProcessDetails -Id 1234
```

Returned information may include:

- Process name
- Process ID
- Accumulated CPU time
- Working-set memory
- Handle count
- Thread count
- Start time
- Parent process ID
- Executable path
- Command line

### Permissions

Some process properties may not be available for every process.

For example, executable paths or process details may be restricted depending on:

- Process ownership
- Windows security boundaries
- Elevation level
- Protected system processes

Missing values do not automatically indicate a fault.

### Missing Processes

If a process no longer exists, the function returns a structured result containing an `Error` property.

This allows scripts and the interactive toolkit to handle missing process IDs cleanly.

---

## Available Functions

| Function | Description |
| --- | --- |
| `Get-ITPerformanceSnapshot` | Returns current CPU, memory and uptime information |
| `Get-ITTopProcesses` | Returns processes ranked by accumulated CPU time |
| `Get-ITMemoryConsumers` | Returns processes ranked by working-set memory |
| `Get-ITStartupItems` | Returns discovered Windows startup items |
| `Get-ITPerformanceSample` | Collects repeated CPU and memory samples |
| `Get-ITProcessDetails` | Returns detailed information about a selected process |

---

## Requirements

Performance Diagnostics requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Access to Windows process information
- Access to Windows CIM information

Some process information may require elevated permissions.

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

## Performance Considerations

Live sampling intentionally pauses between samples.

For example:

```powershell
Get-ITPerformanceSample `
    -Samples 10 `
    -IntervalSeconds 1
```

takes approximately nine seconds between the first and final sample, plus the time required to collect each snapshot.

Long sample counts and intervals will therefore take longer to complete.

---

## Interpretation

Performance information should always be interpreted in context.

For example:

- Brief CPU spikes may be normal
- High memory usage may be legitimate
- Windows may use available memory for caching
- Accumulated CPU time does not indicate current CPU load
- A single process using significant resources may be expected
- A short sample window may not capture an intermittent issue

Performance Diagnostics is intended to support investigation rather than provide an automatic diagnosis.

---

## Privacy

Performance Diagnostics runs locally.

It does not automatically upload diagnostic data to the project maintainer.

Output may contain:

- Process names
- Process IDs
- Application paths
- Command-line arguments
- Usernames
- Startup commands
- Resource usage information

Command-line arguments may contain sensitive information depending on the application.

Review output before sharing it externally.

---

## Security

Performance Diagnostics is currently read-only.

IT-Toolkit does not automatically:

- Terminate processes
- Change process priorities
- Disable startup applications
- Modify command lines
- Modify Windows performance settings

IT-Toolkit should only be used on systems you own or are authorised to administer.