function Get-ITStorageHealth {
    [CmdletBinding()]
    param()

    $volumes = Get-CimInstance Win32_LogicalDisk |
        Where-Object {
            $_.DriveType -eq 3 -and
            $_.Size -gt 0
        }

    foreach ($volume in $volumes) {

        $sizeGB = [math]::Round(
            $volume.Size / 1GB,
            2
        )

        $freeGB = [math]::Round(
            $volume.FreeSpace / 1GB,
            2
        )

        $freePercent = [math]::Round(
            ($volume.FreeSpace / $volume.Size) * 100,
            1
        )

        $status = if ($freePercent -lt 10) {
            'Critical'
        }
        elseif ($freePercent -lt 20) {
            'Warning'
        }
        else {
            'Healthy'
        }

        [PSCustomObject]@{
            Drive       = $volume.DeviceID
            VolumeName  = $volume.VolumeName
            FileSystem  = $volume.FileSystem
            SizeGB      = $sizeGB
            FreeGB      = $freeGB
            FreePercent = $freePercent
            Status      = $status
        }
    }
}


function Get-ITPhysicalDiskHealth {
    [CmdletBinding()]
    param()

    try {

        Get-PhysicalDisk |
            Select-Object `
                FriendlyName,
                MediaType,
                BusType,
                Size,
                HealthStatus,
                OperationalStatus
    }
    catch {

        [PSCustomObject]@{
            FriendlyName      = $null
            MediaType         = $null
            BusType           = $null
            Size              = $null
            HealthStatus      = 'Unknown'
            OperationalStatus = 'Unable to retrieve physical disk information'
        }
    }
}


Export-ModuleMember -Function @(
    'Get-ITStorageHealth',
    'Get-ITPhysicalDiskHealth'
)