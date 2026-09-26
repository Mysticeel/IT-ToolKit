# System Information

The System Information feature provides a quick troubleshooting snapshot of a Windows device.

It is designed to help IT technicians quickly collect common hardware, operating system, storage, memory, network, and user information without needing to run multiple Windows or PowerShell commands manually.

## Features

The System Information module currently provides:

- Computer name
- Manufacturer
- Model
- Serial number
- Operating system
- OS version
- System architecture
- System uptime
- Processor information
- Total memory
- Used memory
- Free memory
- System drive capacity
- System drive free space
- IPv4 address
- Default gateway
- DNS servers
- Current user
- PowerShell version
- Administrator status

---

## Using the Toolkit

From the repository root, launch IT-Toolkit:

```powershell
.\src\Start-ITToolkit.ps1
```

From the main menu:

```text
1. System Information
2. Network Diagnostics
3. Windows Diagnostics

Q. Exit
```

Select:

```text
1. System Information
```

The toolkit will collect the available system information and display the results.

Example:

```text
ComputerName     : DESKTOP-EXAMPLE
Manufacturer     : Example Manufacturer
Model            : Example Model
SerialNumber     : EXAMPLE123

OperatingSystem  : Microsoft Windows 11 Pro
OSVersion        : 10.0.26100
Architecture     : 64-bit

UptimeDays       : 2
UptimeHours      : 6

Processor        : Example Processor

TotalMemoryGB    : 16
UsedMemoryGB     : 8.25
FreeMemoryGB     : 7.75

SystemDrive      : C:
DriveSizeGB      : 475.72
DriveFreeGB      : 210.45
DriveFreePercent : 44.2

IPv4Address      : 192.168.1.100
DefaultGateway   : 192.168.1.1
DNSServer        : 1.1.1.1, 8.8.8.8

CurrentUser      : ExampleUser
PowerShell       : 7.5.0
Administrator    : False
```

Values shown above are examples only and will vary depending on the computer.

---

## PowerShell Usage

The System Information functionality is provided by:

```text
src/Modules/SystemInformation.psm1
```

The module exports:

```powershell
Get-ITSystemInformation
```

To use the function directly, import the module:

```powershell
Import-Module .\src\Modules\SystemInformation.psm1 -Force
```

Then run:

```powershell
Get-ITSystemInformation
```

The function returns a PowerShell object, allowing the results to be filtered, formatted, exported, or used by other scripts.

For example:

```powershell
Get-ITSystemInformation | Format-List
```

You can also store the result:

```powershell
$systemInfo = Get-ITSystemInformation
```

Then access individual properties:

```powershell
$systemInfo.ComputerName
$systemInfo.OperatingSystem
$systemInfo.TotalMemoryGB
$systemInfo.DriveFreePercent
```

---

## Hardware Information

The toolkit collects basic hardware information about the Windows device.

This includes:

- Manufacturer
- Model
- Serial number
- Processor

This information can be useful when:

- Identifying a device
- Troubleshooting hardware-specific problems
- Checking device specifications
- Preparing support information

---

## Operating System Information

The toolkit reports:

- Windows edition
- Windows version
- System architecture
- System uptime

System uptime can be particularly useful when troubleshooting devices that have not been restarted for an extended period.

A long uptime does not by itself indicate a problem, but it can provide useful context when investigating:

- Pending updates
- Performance problems
- Application issues
- Driver problems
- Pending reboot conditions

For dedicated pending reboot detection, use the Windows Diagnostics module.

---

## Memory Information

The System Information module reports:

- Total physical memory
- Used memory
- Free memory

Values are displayed in gigabytes for easier troubleshooting.

Memory information provides a quick overview of current system resources but should not be treated as a complete performance analysis.

---

## Storage Information

The toolkit reports information about the Windows system drive, including:

- Drive letter
- Total capacity
- Available free space
- Percentage of free space

Example:

```text
SystemDrive      : C:
DriveSizeGB      : 475.72
DriveFreeGB      : 210.45
DriveFreePercent : 44.2
```

Low disk space can contribute to problems including:

- Windows Update failures
- Application errors
- Poor system performance
- Temporary file issues
- Profile problems

The reported values provide a quick diagnostic snapshot rather than a full storage analysis.

---

## Network Information

The System Information module includes basic information about the active network configuration.

This includes:

- IPv4 address
- Default gateway
- DNS servers

Example:

```text
IPv4Address    : 192.168.1.100
DefaultGateway : 192.168.1.1
DNSServer      : 1.1.1.1, 8.8.8.8
```

For more detailed network troubleshooting, use the Network Diagnostics section of IT-Toolkit.

Network Diagnostics provides additional tools including:

- Network adapter information
- Virtual adapter detection
- Internet connectivity testing
- DNS resolution testing
- TCP port testing
- Trace route diagnostics
- Wi-Fi information

---

## User and PowerShell Information

The toolkit also reports:

- Current Windows user
- PowerShell version
- Administrator status

Example:

```text
CurrentUser   : ExampleUser
PowerShell    : 7.5.0
Administrator : False
```

Administrator status indicates whether the current PowerShell process is running with administrative privileges.

Some Windows diagnostic functions may require elevated permissions to retrieve all available information.

---

## Available Functions

The System Information module currently exports the following function:

| Function | Description |
| --- | --- |
| `Get-ITSystemInformation` | Collects a troubleshooting snapshot of the local Windows computer |

---

## Requirements

System Information requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- CIM access to the local Windows system

Some information may require elevated permissions depending on the Windows configuration.

---

## Testing

The System Information module has an associated Pester test suite:

```text
tests/SystemInformation.Tests.ps1
```

Run the System Information tests with:

```powershell
Invoke-Pester .\tests\SystemInformation.Tests.ps1 -Output Detailed
```

Run the complete IT-Toolkit test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

---

## Privacy

System information is collected locally on the computer running IT-Toolkit.

IT-Toolkit does not upload collected system information to the project maintainer.

The output may contain information that identifies or describes the local computer.

Review diagnostic output before sharing it publicly.

---

## Security

IT-Toolkit should only be used on systems you own or are authorised to administer.

Before publishing System Information output to GitHub or another public location, review it for potentially sensitive information such as:

- Computer names
- Usernames
- Device serial numbers
- IP addresses
- Default gateways
- DNS servers
- Hardware information
- Internal infrastructure information
- Personal or confidential information

Do not commit sensitive diagnostic output to the IT-Toolkit repository.