function Get-ITSystemInformation {
    [CmdletBinding()]
    param()

    try {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
        $processor = Get-CimInstance -ClassName Win32_Processor |
            Select-Object -First 1

        $bios = Get-CimInstance -ClassName Win32_BIOS

        $systemDrive = Get-CimInstance -ClassName Win32_LogicalDisk `
            -Filter "DeviceID='$($env:SystemDrive)'"

        $network = Get-NetIPConfiguration |
            Where-Object {
                $_.IPv4Address -and
                $_.NetAdapter.Status -eq 'Up'
            } |
            Select-Object -First 1

        $uptime = (Get-Date) - $operatingSystem.LastBootUpTime

        $totalMemoryGB = [math]::Round(
            $computerSystem.TotalPhysicalMemory / 1GB, 2
        )

        $freeMemoryGB = [math]::Round(
            $operatingSystem.FreePhysicalMemory / 1MB, 2
        )

        $usedMemoryGB = [math]::Round(
            $totalMemoryGB - $freeMemoryGB, 2
        )

        $driveSizeGB = [math]::Round(
            $systemDrive.Size / 1GB, 2
        )

        $driveFreeGB = [math]::Round(
            $systemDrive.FreeSpace / 1GB, 2
        )

        $driveFreePercent = if ($systemDrive.Size -gt 0) {
            [math]::Round(
                ($systemDrive.FreeSpace / $systemDrive.Size) * 100,
                1
            )
        }
        else {
            0
        }

        $principal = New-Object Security.Principal.WindowsPrincipal(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )

        $isAdministrator = $principal.IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )

        [PSCustomObject]@{
            ComputerName     = $env:COMPUTERNAME
            Manufacturer     = $computerSystem.Manufacturer
            Model            = $computerSystem.Model
            SerialNumber     = $bios.SerialNumber

            OperatingSystem  = $operatingSystem.Caption
            OSVersion        = $operatingSystem.Version
            Architecture     = $operatingSystem.OSArchitecture

            UptimeDays       = $uptime.Days
            UptimeHours      = $uptime.Hours

            Processor        = $processor.Name

            TotalMemoryGB    = $totalMemoryGB
            UsedMemoryGB     = $usedMemoryGB
            FreeMemoryGB     = $freeMemoryGB

            SystemDrive      = $env:SystemDrive
            DriveSizeGB      = $driveSizeGB
            DriveFreeGB      = $driveFreeGB
            DriveFreePercent = $driveFreePercent

            IPv4Address      = $network.IPv4Address.IPAddress
            DefaultGateway   = $network.IPv4DefaultGateway.NextHop
            DNSServer        = $network.DNSServer.ServerAddresses -join ', '

            CurrentUser      = [Environment]::UserName
            PowerShell       = $PSVersionTable.PSVersion.ToString()
            Administrator    = $isAdministrator
        }
    }
    catch {
        Write-Error "Unable to collect system information: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function Get-ITSystemInformation