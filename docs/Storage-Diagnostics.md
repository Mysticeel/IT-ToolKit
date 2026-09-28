# Storage Diagnostics

The Storage Diagnostics module provides quick checks for logical drive capacity and physical disk health on Windows systems.

It is designed to help IT technicians identify common storage-related issues such as low free space, unexpected drive usage, and unhealthy physical disks.

## Features

The Storage Diagnostics module currently provides:

- Logical drive health
- Free-space analysis
- Storage severity status
- Physical disk health
- Media type
- Bus type
- Operational status

---

## Using the Toolkit

Launch IT-Toolkit from the repository root:

```powershell
.\src\Start-ITToolkit.ps1
```

From the main menu:

```text
1. System Information
2. Network Diagnostics
3. Windows Diagnostics
4. Generate Diagnostic Report
5. System Health Analysis
6. Storage Diagnostics
7. Windows Update Diagnostics

Q. Exit
```

Select:

```text
6. Storage Diagnostics
```

The Storage Diagnostics menu provides:

```text
1. Logical drive health
2. Physical disk health

B. Back
```

---

## Logical Drive Health

The Logical Drive Health check inspects fixed Windows drives.

It reports:

- Drive letter
- Volume name
- File system
- Total size
- Free space
- Free-space percentage
- Health status

### Status Thresholds

The current storage thresholds are:

- 20% or more free → `Healthy`
- 10% to 19.9% free → `Warning`
- Less than 10% free → `Critical`

These thresholds are intended as troubleshooting indicators rather than strict operational requirements.

### PowerShell Usage

Run:

```powershell
Get-ITStorageHealth
```

Example output:

```text
Drive VolumeName FileSystem SizeGB FreeGB FreePercent Status
----- ---------- ---------- ------ ------ ----------- ------
C:    Windows    NTFS       476.9  201.4  42.2        Healthy
```

Values shown above are examples only.

---

## Physical Disk Health

The Physical Disk Health check retrieves information about physical storage devices.

It reports:

- Friendly name
- Media type
- Bus type
- Size
- Health status
- Operational status

### PowerShell Usage

Run:

```powershell
Get-ITPhysicalDiskHealth
```

Example output:

```text
FriendlyName     MediaType BusType Size         HealthStatus OperationalStatus
------------     --------- ------- ----         ------------ -----------------
Example SSD      SSD       NVMe    512105932800 Healthy      OK
```

Values shown above are examples only.

### Important

Physical disk health depends on what Windows and the underlying storage driver expose.

A healthy status does not guarantee that a disk will not fail.

Likewise, missing or unknown information does not necessarily indicate a fault.

---

## Available Functions

| Function | Description |
| --- | --- |
| `Get-ITStorageHealth` | Returns fixed logical drive capacity and free-space health |
| `Get-ITPhysicalDiskHealth` | Returns physical disk health and operational information |

---

## Requirements

Storage Diagnostics requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Access to Windows storage information
- Permission to query CIM and physical disk information

Some storage information may vary depending on hardware, drivers, storage controllers, or virtualisation.

---

## Testing

The Storage Diagnostics module has a dedicated Pester test suite:

```text
tests/StorageDiagnostics.Tests.ps1
```

Run it with:

```powershell
Invoke-Pester .\tests\StorageDiagnostics.Tests.ps1 -Output Detailed
```

Run the complete project test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

GitHub Actions also runs the project test suite automatically for repository changes.

---

## Interpretation

Storage results should always be considered in context.

For example:

- Low free space may contribute to Windows Update failures
- Applications may fail when temporary storage becomes limited
- Virtual disks may report storage information differently
- Physical disk health information may depend on the storage controller

A storage warning or critical status indicates that further investigation is recommended.

---

## Privacy

Storage Diagnostics runs locally.

It does not automatically upload storage information to the project maintainer.

Diagnostic output may contain:

- Drive letters
- Volume names
- Storage capacity
- Device names
- Media type
- Disk status

Review output before sharing it externally.

---

## Security

IT-Toolkit should only be used on systems you own or are authorised to administer.

Do not commit real diagnostic output from production or business systems to the public repository.