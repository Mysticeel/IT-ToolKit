function Get-ITDiagnosticReportData {
    [CmdletBinding()]
    param()

    # Core diagnostic data
    $systemInfo = Get-ITSystemInformation

    $networkInfo = Get-ITNetworkInformation |
        Select-Object -First 1

    $internetStatus = Test-ITInternetConnection
    $dnsStatus = Test-ITDNSResolution

    $pendingReboot = Get-ITPendingReboot
    $serviceHealth = Get-ITServiceHealth

    $recentErrors = Get-ITRecentSystemErrors `
        -Hours 24 `
        -MaxEvents 25

    # v0.8.0 integrated diagnostics
    $storageHealth = Get-ITStorageHealth
    $physicalDisks = Get-ITPhysicalDiskHealth

    $updateStatus = Get-ITWindowsUpdateStatus

    $performance = Get-ITPerformanceSnapshot

    $topCPU = Get-ITTopProcesses `
        -Top 10

    $topMemory = Get-ITMemoryConsumers `
        -Top 10

    $healthAnalysis = Get-ITHealthAnalysis


    [PSCustomObject]@{
        GeneratedAt = Get-Date


        System = [PSCustomObject]@{
            ComputerName     = $systemInfo.ComputerName
            Manufacturer     = $systemInfo.Manufacturer
            Model            = $systemInfo.Model
            SerialNumber     = $systemInfo.SerialNumber
            OperatingSystem  = $systemInfo.OperatingSystem
            OSVersion        = $systemInfo.OSVersion
            Architecture     = $systemInfo.Architecture
            UptimeDays       = $systemInfo.UptimeDays
            UptimeHours      = $systemInfo.UptimeHours
            Processor        = $systemInfo.Processor
            TotalMemoryGB    = $systemInfo.TotalMemoryGB
            UsedMemoryGB     = $systemInfo.UsedMemoryGB
            FreeMemoryGB     = $systemInfo.FreeMemoryGB
            SystemDrive      = $systemInfo.SystemDrive
            DriveSizeGB      = $systemInfo.DriveSizeGB
            DriveFreeGB      = $systemInfo.DriveFreeGB
            DriveFreePercent = $systemInfo.DriveFreePercent
            CurrentUser      = $systemInfo.CurrentUser
            PowerShell       = $systemInfo.PowerShell
            Administrator    = $systemInfo.Administrator
        }


        Network = [PSCustomObject]@{
            InterfaceAlias      = $networkInfo.InterfaceAlias
            Description         = $networkInfo.Description
            IPv4Address         = $networkInfo.IPv4Address
            Gateway             = $networkInfo.Gateway
            DNSServers          = $networkInfo.DNSServers
            MACAddress          = $networkInfo.MACAddress
            LinkSpeed           = $networkInfo.LinkSpeed
            InternetConnected   = $internetStatus.Connected
            InternetTestTarget  = $internetStatus.Target
            DNSResolution       = $dnsStatus.Successful
            DNSResolutionTarget = $dnsStatus.Name
            DNSAddresses        = $dnsStatus.Addresses
        }


        Windows = [PSCustomObject]@{
            RebootRequired         = $pendingReboot.RebootRequired
            RebootReasons          = $pendingReboot.Reasons
            StoppedAutomaticCount  = @($serviceHealth).Count
            RecentSystemErrorCount = @($recentErrors).Count
            StoppedAutomatic       = @($serviceHealth)
            RecentSystemErrors     = @($recentErrors)
        }


        Storage = [PSCustomObject]@{
            LogicalDrives = @($storageHealth)
            PhysicalDisks = @($physicalDisks)
        }


        WindowsUpdate = [PSCustomObject]@{
            UpdateCount = $updateStatus.UpdateCount
            Updates     = @($updateStatus.Updates)
            Error       = $updateStatus.Error
        }


        Performance = [PSCustomObject]@{
            CPUUsagePercent    = $performance.CPUUsagePercent
            TotalMemoryGB      = $performance.TotalMemoryGB
            UsedMemoryGB       = $performance.UsedMemoryGB
            FreeMemoryGB       = $performance.FreeMemoryGB
            MemoryUsedPercent  = $performance.MemoryUsedPercent
            UptimeDays         = $performance.UptimeDays
            UptimeHours        = $performance.UptimeHours
            TopCPUProcesses    = @($topCPU)
            TopMemoryProcesses = @($topMemory)
        }


        Health = [PSCustomObject]@{
            OverallStatus = $healthAnalysis.OverallStatus
            HealthyCount  = $healthAnalysis.HealthyCount
            WarningCount  = $healthAnalysis.WarningCount
            CriticalCount = $healthAnalysis.CriticalCount
            InfoCount     = $healthAnalysis.InfoCount
            Findings      = @($healthAnalysis.Findings)
        }


        Summary = [PSCustomObject]@{
            OverallHealth          = $healthAnalysis.OverallStatus
            InternetConnected      = $internetStatus.Connected
            DNSWorking             = $dnsStatus.Successful
            RebootRequired         = $pendingReboot.RebootRequired
            DriveFreePercent       = $systemInfo.DriveFreePercent
            PendingUpdateCount     = $updateStatus.UpdateCount
            CPUUsagePercent        = $performance.CPUUsagePercent
            MemoryUsedPercent      = $performance.MemoryUsedPercent
            StoppedAutomaticCount  = @($serviceHealth).Count
            RecentSystemErrorCount = @($recentErrors).Count
        }
    }
}


function Export-ITDiagnosticReportText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$Report,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $lines = @()

    $lines += "IT-Toolkit Diagnostic Report"
    $lines += "Generated: $($Report.GeneratedAt)"
    $lines += ""


    # Summary
    $lines += "=================================================="
    $lines += "SUMMARY"
    $lines += "=================================================="

    $lines += "Overall Health         : $($Report.Summary.OverallHealth)"
    $lines += "Internet Connected     : $($Report.Summary.InternetConnected)"
    $lines += "DNS Working            : $($Report.Summary.DNSWorking)"
    $lines += "Reboot Required        : $($Report.Summary.RebootRequired)"
    $lines += "Drive Free Percent     : $($Report.Summary.DriveFreePercent)%"
    $lines += "Pending Updates        : $($Report.Summary.PendingUpdateCount)"
    $lines += "CPU Usage              : $($Report.Summary.CPUUsagePercent)%"
    $lines += "Memory Usage           : $($Report.Summary.MemoryUsedPercent)%"
    $lines += "Stopped Auto Services  : $($Report.Summary.StoppedAutomaticCount)"
    $lines += "Recent System Errors   : $($Report.Summary.RecentSystemErrorCount)"


    # System Information
    $lines += ""
    $lines += "=================================================="
    $lines += "SYSTEM INFORMATION"
    $lines += "=================================================="

    $lines += "Computer Name      : $($Report.System.ComputerName)"
    $lines += "Manufacturer       : $($Report.System.Manufacturer)"
    $lines += "Model              : $($Report.System.Model)"
    $lines += "Serial Number      : $($Report.System.SerialNumber)"
    $lines += "Operating System   : $($Report.System.OperatingSystem)"
    $lines += "OS Version         : $($Report.System.OSVersion)"
    $lines += "Architecture       : $($Report.System.Architecture)"
    $lines += "Uptime             : $($Report.System.UptimeDays) day(s), $($Report.System.UptimeHours) hour(s)"
    $lines += "Processor          : $($Report.System.Processor)"
    $lines += "Total Memory       : $($Report.System.TotalMemoryGB) GB"
    $lines += "Used Memory        : $($Report.System.UsedMemoryGB) GB"
    $lines += "Free Memory        : $($Report.System.FreeMemoryGB) GB"
    $lines += "System Drive       : $($Report.System.SystemDrive)"
    $lines += "Drive Size         : $($Report.System.DriveSizeGB) GB"
    $lines += "Drive Free         : $($Report.System.DriveFreeGB) GB"
    $lines += "Drive Free Percent : $($Report.System.DriveFreePercent)%"
    $lines += "Current User       : $($Report.System.CurrentUser)"
    $lines += "PowerShell         : $($Report.System.PowerShell)"
    $lines += "Administrator      : $($Report.System.Administrator)"


    # Network
    $lines += ""
    $lines += "=================================================="
    $lines += "NETWORK"
    $lines += "=================================================="

    $lines += "Interface          : $($Report.Network.InterfaceAlias)"
    $lines += "Description        : $($Report.Network.Description)"
    $lines += "IPv4 Address       : $($Report.Network.IPv4Address)"
    $lines += "Gateway            : $($Report.Network.Gateway)"
    $lines += "DNS Servers        : $($Report.Network.DNSServers)"
    $lines += "MAC Address        : $($Report.Network.MACAddress)"
    $lines += "Link Speed         : $($Report.Network.LinkSpeed)"
    $lines += "Internet Connected : $($Report.Network.InternetConnected)"
    $lines += "Internet Test      : $($Report.Network.InternetTestTarget)"
    $lines += "DNS Working        : $($Report.Network.DNSResolution)"
    $lines += "DNS Test Target    : $($Report.Network.DNSResolutionTarget)"
    $lines += "Resolved Addresses : $($Report.Network.DNSAddresses)"


    # Windows Health
    $lines += ""
    $lines += "=================================================="
    $lines += "WINDOWS HEALTH"
    $lines += "=================================================="

    $lines += "Reboot Required       : $($Report.Windows.RebootRequired)"
    $lines += "Reboot Reasons        : $($Report.Windows.RebootReasons)"
    $lines += "Stopped Auto Services : $($Report.Windows.StoppedAutomaticCount)"
    $lines += "Recent System Errors  : $($Report.Windows.RecentSystemErrorCount)"


    if ($Report.Windows.StoppedAutomaticCount -gt 0) {

        $lines += ""
        $lines += "Stopped Automatic Services"
        $lines += "--------------------------"

        foreach ($service in $Report.Windows.StoppedAutomatic) {

            $lines += "$($service.Name) | $($service.DisplayName) | $($service.Status) | $($service.StartType)"
        }
    }


    if ($Report.Windows.RecentSystemErrorCount -gt 0) {

        $lines += ""
        $lines += "Recent System Errors"
        $lines += "--------------------"

        foreach ($event in $Report.Windows.RecentSystemErrors) {

            $lines += "$($event.TimeCreated) | ID $($event.Id) | $($event.LevelDisplayName) | $($event.ProviderName)"
        }
    }


    # Storage
    $lines += ""
    $lines += "=================================================="
    $lines += "STORAGE"
    $lines += "=================================================="

    if (@($Report.Storage.LogicalDrives).Count -gt 0) {

        $lines += "Logical Drives"
        $lines += "--------------"

        foreach ($drive in $Report.Storage.LogicalDrives) {

            $lines += "$($drive.Drive) | $($drive.SizeGB) GB | $($drive.FreeGB) GB free | $($drive.FreePercent)% free | $($drive.Status)"
        }
    }
    else {

        $lines += "No logical drive information was returned."
    }


    $lines += ""
    $lines += "Physical Disks"
    $lines += "--------------"

    if (@($Report.Storage.PhysicalDisks).Count -gt 0) {

        foreach ($disk in $Report.Storage.PhysicalDisks) {

            $sizeGB = if ($disk.Size) {
                [math]::Round(
                    $disk.Size / 1GB,
                    2
                )
            }
            else {
                'Unknown'
            }

            $lines += "$($disk.FriendlyName) | $($disk.MediaType) | $($disk.BusType) | $sizeGB GB | $($disk.HealthStatus) | $($disk.OperationalStatus)"
        }
    }
    else {

        $lines += "No physical disk information was returned."
    }


    # Windows Update
    $lines += ""
    $lines += "=================================================="
    $lines += "WINDOWS UPDATE"
    $lines += "=================================================="

    if ($Report.WindowsUpdate.Error) {

        $lines += "Status : Unable to determine"
        $lines += "Error  : $($Report.WindowsUpdate.Error)"
    }
    else {

        $lines += "Pending Updates : $($Report.WindowsUpdate.UpdateCount)"

        if ($Report.WindowsUpdate.UpdateCount -gt 0) {

            $lines += ""

            foreach ($update in $Report.WindowsUpdate.Updates) {

                $lines += "$($update.Title) | KB: $($update.KB) | Severity: $($update.Severity) | Reboot Needed: $($update.RebootNeeded)"
            }
        }
    }


    # Performance
    $lines += ""
    $lines += "=================================================="
    $lines += "PERFORMANCE"
    $lines += "=================================================="

    $lines += "CPU Usage          : $($Report.Performance.CPUUsagePercent)%"
    $lines += "Memory Usage       : $($Report.Performance.MemoryUsedPercent)%"
    $lines += "Total Memory       : $($Report.Performance.TotalMemoryGB) GB"
    $lines += "Used Memory        : $($Report.Performance.UsedMemoryGB) GB"
    $lines += "Free Memory        : $($Report.Performance.FreeMemoryGB) GB"
    $lines += "Uptime             : $($Report.Performance.UptimeDays) day(s), $($Report.Performance.UptimeHours) hour(s)"


    $lines += ""
    $lines += "Top CPU Processes"
    $lines += "-----------------"

    foreach ($process in $Report.Performance.TopCPUProcesses) {

        $cpuValue = if ($null -ne $process.CPU) {
            [math]::Round(
                [double]$process.CPU,
                2
            )
        }
        else {
            0
        }

        $lines += "$($process.ProcessName) | PID $($process.Id) | CPU Time: $cpuValue | Handles: $($process.Handles)"
    }


    $lines += ""
    $lines += "Top Memory Processes"
    $lines += "--------------------"

    foreach ($process in $Report.Performance.TopMemoryProcesses) {

        $lines += "$($process.ProcessName) | PID $($process.Id) | $($process.MemoryMB) MB | Handles: $($process.Handles)"
    }


    # Health Analysis
    $lines += ""
    $lines += "=================================================="
    $lines += "HEALTH ANALYSIS"
    $lines += "=================================================="

    $lines += "Overall Status : $($Report.Health.OverallStatus)"
    $lines += "Healthy        : $($Report.Health.HealthyCount)"
    $lines += "Warnings       : $($Report.Health.WarningCount)"
    $lines += "Critical       : $($Report.Health.CriticalCount)"
    $lines += "Information    : $($Report.Health.InfoCount)"
    $lines += ""


    foreach ($finding in $Report.Health.Findings) {

        $lines += "[$($finding.Severity)] $($finding.Area)"
        $lines += "  $($finding.Finding)"

        if ($finding.Recommendation) {

            $lines += "  Recommendation: $($finding.Recommendation)"
        }

        $lines += ""
    }


    # Ensure destination exists
    $directory = Split-Path $Path -Parent

    if (
        $directory -and
        -not (Test-Path $directory)
    ) {

        New-Item `
            -ItemType Directory `
            -Path $directory `
            -Force |
            Out-Null
    }


    $lines |
        Set-Content `
            -Path $Path `
            -Encoding UTF8


    Get-Item $Path
}


function Export-ITDiagnosticReportHtml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$Report,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )


    function ConvertTo-ITHtmlEncodedValue {
        param(
            [AllowNull()]
            [object]$Value
        )

        if ($null -eq $Value) {
            return ''
        }

        return [System.Net.WebUtility]::HtmlEncode(
            [string]$Value
        )
    }


    function ConvertTo-ITTableRows {
        param(
            [Parameter(Mandatory)]
            [array]$Rows
        )

        $htmlRows = foreach ($row in $Rows) {

            $label = ConvertTo-ITHtmlEncodedValue `
                -Value $row.Label

            $value = ConvertTo-ITHtmlEncodedValue `
                -Value $row.Value

            "<tr><th>$label</th><td>$value</td></tr>"
        }

        return $htmlRows
    }


    function Get-ITSeverityClass {
        param(
            [AllowNull()]
            [string]$Severity
        )

        switch ($Severity) {

            'Healthy' {
                'healthy'
            }

            'Information' {
                'information'
            }

            'Warning' {
                'warning'
            }

            'Critical' {
                'critical'
            }

            default {
                'neutral'
            }
        }
    }


    # Summary
    $summaryRows = @(

        [PSCustomObject]@{
            Label = 'Overall Health'
            Value = $Report.Summary.OverallHealth
        }

        [PSCustomObject]@{
            Label = 'Internet Connected'
            Value = $Report.Summary.InternetConnected
        }

        [PSCustomObject]@{
            Label = 'DNS Working'
            Value = $Report.Summary.DNSWorking
        }

        [PSCustomObject]@{
            Label = 'Reboot Required'
            Value = $Report.Summary.RebootRequired
        }

        [PSCustomObject]@{
            Label = 'Drive Free Percent'
            Value = "$($Report.Summary.DriveFreePercent)%"
        }

        [PSCustomObject]@{
            Label = 'Pending Updates'
            Value = $Report.Summary.PendingUpdateCount
        }

        [PSCustomObject]@{
            Label = 'CPU Usage'
            Value = "$($Report.Summary.CPUUsagePercent)%"
        }

        [PSCustomObject]@{
            Label = 'Memory Usage'
            Value = "$($Report.Summary.MemoryUsedPercent)%"
        }

        [PSCustomObject]@{
            Label = 'Stopped Automatic Services'
            Value = $Report.Summary.StoppedAutomaticCount
        }

        [PSCustomObject]@{
            Label = 'Recent System Errors'
            Value = $Report.Summary.RecentSystemErrorCount
        }
    )


    # System Information
    $systemRows = @(

        [PSCustomObject]@{
            Label = 'Computer Name'
            Value = $Report.System.ComputerName
        }

        [PSCustomObject]@{
            Label = 'Manufacturer'
            Value = $Report.System.Manufacturer
        }

        [PSCustomObject]@{
            Label = 'Model'
            Value = $Report.System.Model
        }

        [PSCustomObject]@{
            Label = 'Serial Number'
            Value = $Report.System.SerialNumber
        }

        [PSCustomObject]@{
            Label = 'Operating System'
            Value = $Report.System.OperatingSystem
        }

        [PSCustomObject]@{
            Label = 'OS Version'
            Value = $Report.System.OSVersion
        }

        [PSCustomObject]@{
            Label = 'Architecture'
            Value = $Report.System.Architecture
        }

        [PSCustomObject]@{
            Label = 'Uptime'
            Value = "$($Report.System.UptimeDays) day(s), $($Report.System.UptimeHours) hour(s)"
        }

        [PSCustomObject]@{
            Label = 'Processor'
            Value = $Report.System.Processor
        }

        [PSCustomObject]@{
            Label = 'Total Memory'
            Value = "$($Report.System.TotalMemoryGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Used Memory'
            Value = "$($Report.System.UsedMemoryGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Free Memory'
            Value = "$($Report.System.FreeMemoryGB) GB"
        }

        [PSCustomObject]@{
            Label = 'System Drive'
            Value = $Report.System.SystemDrive
        }

        [PSCustomObject]@{
            Label = 'Drive Size'
            Value = "$($Report.System.DriveSizeGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Drive Free'
            Value = "$($Report.System.DriveFreeGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Drive Free Percent'
            Value = "$($Report.System.DriveFreePercent)%"
        }

        [PSCustomObject]@{
            Label = 'Current User'
            Value = $Report.System.CurrentUser
        }

        [PSCustomObject]@{
            Label = 'PowerShell'
            Value = $Report.System.PowerShell
        }

        [PSCustomObject]@{
            Label = 'Administrator'
            Value = $Report.System.Administrator
        }
    )


    # Network
    $networkRows = @(

        [PSCustomObject]@{
            Label = 'Interface'
            Value = $Report.Network.InterfaceAlias
        }

        [PSCustomObject]@{
            Label = 'Description'
            Value = $Report.Network.Description
        }

        [PSCustomObject]@{
            Label = 'IPv4 Address'
            Value = $Report.Network.IPv4Address
        }

        [PSCustomObject]@{
            Label = 'Gateway'
            Value = $Report.Network.Gateway
        }

        [PSCustomObject]@{
            Label = 'DNS Servers'
            Value = $Report.Network.DNSServers
        }

        [PSCustomObject]@{
            Label = 'MAC Address'
            Value = $Report.Network.MACAddress
        }

        [PSCustomObject]@{
            Label = 'Link Speed'
            Value = $Report.Network.LinkSpeed
        }

        [PSCustomObject]@{
            Label = 'Internet Connected'
            Value = $Report.Network.InternetConnected
        }

        [PSCustomObject]@{
            Label = 'Internet Test Target'
            Value = $Report.Network.InternetTestTarget
        }

        [PSCustomObject]@{
            Label = 'DNS Working'
            Value = $Report.Network.DNSResolution
        }

        [PSCustomObject]@{
            Label = 'DNS Test Target'
            Value = $Report.Network.DNSResolutionTarget
        }

        [PSCustomObject]@{
            Label = 'Resolved Addresses'
            Value = $Report.Network.DNSAddresses
        }
    )


    # Performance summary
    $performanceRows = @(

        [PSCustomObject]@{
            Label = 'CPU Usage'
            Value = "$($Report.Performance.CPUUsagePercent)%"
        }

        [PSCustomObject]@{
            Label = 'Memory Usage'
            Value = "$($Report.Performance.MemoryUsedPercent)%"
        }

        [PSCustomObject]@{
            Label = 'Total Memory'
            Value = "$($Report.Performance.TotalMemoryGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Used Memory'
            Value = "$($Report.Performance.UsedMemoryGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Free Memory'
            Value = "$($Report.Performance.FreeMemoryGB) GB"
        }

        [PSCustomObject]@{
            Label = 'Uptime'
            Value = "$($Report.Performance.UptimeDays) day(s), $($Report.Performance.UptimeHours) hour(s)"
        }
    )


    $summaryHtml = ConvertTo-ITTableRows `
        -Rows $summaryRows

    $systemHtml = ConvertTo-ITTableRows `
        -Rows $systemRows

    $networkHtml = ConvertTo-ITTableRows `
        -Rows $networkRows

    $performanceHtml = ConvertTo-ITTableRows `
        -Rows $performanceRows


    # Stopped services
    $servicesHtml = if (
        $Report.Windows.StoppedAutomaticCount -gt 0
    ) {

        $rows = foreach (
            $service in $Report.Windows.StoppedAutomatic
        ) {

            $name = ConvertTo-ITHtmlEncodedValue `
                -Value $service.Name

            $displayName = ConvertTo-ITHtmlEncodedValue `
                -Value $service.DisplayName

            $status = ConvertTo-ITHtmlEncodedValue `
                -Value $service.Status

            $startType = ConvertTo-ITHtmlEncodedValue `
                -Value $service.StartType

            @"
<tr>
<td>$name</td>
<td>$displayName</td>
<td>$status</td>
<td>$startType</td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Name</th>
<th>Display Name</th>
<th>Status</th>
<th>Start Type</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No stopped automatic services were found.</p>"
    }


    # Recent events
    $eventsHtml = if (
        $Report.Windows.RecentSystemErrorCount -gt 0
    ) {

        $rows = foreach (
            $event in $Report.Windows.RecentSystemErrors
        ) {

            $timeCreated = ConvertTo-ITHtmlEncodedValue `
                -Value $event.TimeCreated

            $eventId = ConvertTo-ITHtmlEncodedValue `
                -Value $event.Id

            $level = ConvertTo-ITHtmlEncodedValue `
                -Value $event.LevelDisplayName

            $provider = ConvertTo-ITHtmlEncodedValue `
                -Value $event.ProviderName

            @"
<tr>
<td>$timeCreated</td>
<td>$eventId</td>
<td>$level</td>
<td>$provider</td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Time</th>
<th>Event ID</th>
<th>Level</th>
<th>Provider</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No recent Critical or Error events were found.</p>"
    }


    # Logical drives
    $logicalDrivesHtml = if (
        @($Report.Storage.LogicalDrives).Count -gt 0
    ) {

        $rows = foreach (
            $drive in $Report.Storage.LogicalDrives
        ) {

            $driveName = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.Drive

            $volumeName = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.VolumeName

            $fileSystem = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.FileSystem

            $size = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.SizeGB

            $free = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.FreeGB

            $freePercent = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.FreePercent

            $status = ConvertTo-ITHtmlEncodedValue `
                -Value $drive.Status

            $statusClass = Get-ITSeverityClass `
                -Severity $drive.Status

            @"
<tr>
<td>$driveName</td>
<td>$volumeName</td>
<td>$fileSystem</td>
<td>$size GB</td>
<td>$free GB</td>
<td>$freePercent%</td>
<td><span class="badge $statusClass">$status</span></td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Drive</th>
<th>Volume</th>
<th>File System</th>
<th>Size</th>
<th>Free</th>
<th>Free %</th>
<th>Status</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No logical drive information was returned.</p>"
    }


    # Physical disks
    $physicalDisksHtml = if (
        @($Report.Storage.PhysicalDisks).Count -gt 0
    ) {

        $rows = foreach (
            $disk in $Report.Storage.PhysicalDisks
        ) {

            $friendlyName = ConvertTo-ITHtmlEncodedValue `
                -Value $disk.FriendlyName

            $mediaType = ConvertTo-ITHtmlEncodedValue `
                -Value $disk.MediaType

            $busType = ConvertTo-ITHtmlEncodedValue `
                -Value $disk.BusType

            $sizeGB = if ($disk.Size) {

                [math]::Round(
                    $disk.Size / 1GB,
                    2
                )
            }
            else {

                'Unknown'
            }

            $sizeGB = ConvertTo-ITHtmlEncodedValue `
                -Value $sizeGB

            $health = ConvertTo-ITHtmlEncodedValue `
                -Value $disk.HealthStatus

            $operational = ConvertTo-ITHtmlEncodedValue `
                -Value $disk.OperationalStatus

            @"
<tr>
<td>$friendlyName</td>
<td>$mediaType</td>
<td>$busType</td>
<td>$sizeGB GB</td>
<td>$health</td>
<td>$operational</td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Disk</th>
<th>Media Type</th>
<th>Bus Type</th>
<th>Size</th>
<th>Health</th>
<th>Operational Status</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No physical disk information was returned.</p>"
    }


    # Windows Updates
    $updatesHtml = if ($Report.WindowsUpdate.Error) {

        $errorText = ConvertTo-ITHtmlEncodedValue `
            -Value $Report.WindowsUpdate.Error

        @"
<p class="notice">
Windows Update status could not be determined.
</p>

<p>$errorText</p>
"@
    }
    elseif ($Report.WindowsUpdate.UpdateCount -gt 0) {

        $rows = foreach (
            $update in $Report.WindowsUpdate.Updates
        ) {

            $title = ConvertTo-ITHtmlEncodedValue `
                -Value $update.Title

            $severity = ConvertTo-ITHtmlEncodedValue `
                -Value $update.Severity

            $kb = ConvertTo-ITHtmlEncodedValue `
                -Value $update.KB

            $rebootNeeded = ConvertTo-ITHtmlEncodedValue `
                -Value $update.RebootNeeded

            @"
<tr>
<td>$title</td>
<td>$kb</td>
<td>$severity</td>
<td>$rebootNeeded</td>
</tr>
"@
        }

        @"
<p>Pending updates: $($Report.WindowsUpdate.UpdateCount)</p>

<table>
<thead>
<tr>
<th>Title</th>
<th>KB</th>
<th>Severity</th>
<th>Reboot Needed</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No pending software updates were detected.</p>"
    }


    # Top CPU
    $topCPUHtml = if (
        @($Report.Performance.TopCPUProcesses).Count -gt 0
    ) {

        $rows = foreach (
            $process in $Report.Performance.TopCPUProcesses
        ) {

            $name = ConvertTo-ITHtmlEncodedValue `
                -Value $process.ProcessName

            $id = ConvertTo-ITHtmlEncodedValue `
                -Value $process.Id

            $cpu = if ($null -ne $process.CPU) {

                [math]::Round(
                    [double]$process.CPU,
                    2
                )
            }
            else {

                0
            }

            $cpu = ConvertTo-ITHtmlEncodedValue `
                -Value $cpu

            $handles = ConvertTo-ITHtmlEncodedValue `
                -Value $process.Handles

            @"
<tr>
<td>$name</td>
<td>$id</td>
<td>$cpu</td>
<td>$handles</td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Process</th>
<th>PID</th>
<th>CPU Time</th>
<th>Handles</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No process information was returned.</p>"
    }


    # Top Memory
    $topMemoryHtml = if (
        @($Report.Performance.TopMemoryProcesses).Count -gt 0
    ) {

        $rows = foreach (
            $process in $Report.Performance.TopMemoryProcesses
        ) {

            $name = ConvertTo-ITHtmlEncodedValue `
                -Value $process.ProcessName

            $id = ConvertTo-ITHtmlEncodedValue `
                -Value $process.Id

            $memory = ConvertTo-ITHtmlEncodedValue `
                -Value $process.MemoryMB

            $handles = ConvertTo-ITHtmlEncodedValue `
                -Value $process.Handles

            @"
<tr>
<td>$name</td>
<td>$id</td>
<td>$memory MB</td>
<td>$handles</td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Process</th>
<th>PID</th>
<th>Memory</th>
<th>Handles</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No process information was returned.</p>"
    }


    # Health findings
    $healthFindingsHtml = if (
        @($Report.Health.Findings).Count -gt 0
    ) {

        $rows = foreach (
            $finding in $Report.Health.Findings
        ) {

            $area = ConvertTo-ITHtmlEncodedValue `
                -Value $finding.Area

            $severity = ConvertTo-ITHtmlEncodedValue `
                -Value $finding.Severity

            $findingText = ConvertTo-ITHtmlEncodedValue `
                -Value $finding.Finding

            $recommendation = ConvertTo-ITHtmlEncodedValue `
                -Value $finding.Recommendation

            $severityClass = Get-ITSeverityClass `
                -Severity $finding.Severity

            @"
<tr>
<td>$area</td>
<td><span class="badge $severityClass">$severity</span></td>
<td>$findingText</td>
<td>$recommendation</td>
</tr>
"@
        }

        @"
<table>
<thead>
<tr>
<th>Area</th>
<th>Severity</th>
<th>Finding</th>
<th>Recommendation</th>
</tr>
</thead>
<tbody>
$($rows -join "`n")
</tbody>
</table>
"@
    }
    else {

        "<p>No health findings were returned.</p>"
    }


    $generatedAt = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.GeneratedAt

    $overallHealth = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.Health.OverallStatus

    $overallHealthClass = Get-ITSeverityClass `
        -Severity $Report.Health.OverallStatus

    $rebootRequired = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.Windows.RebootRequired

    $rebootReasons = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.Windows.RebootReasons

    $stoppedServiceCount = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.Windows.StoppedAutomaticCount

    $recentErrorCount = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.Windows.RecentSystemErrorCount


    $html = @"
<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
>

<title>IT-Toolkit Diagnostic Report</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 40px;
    font-family: "Segoe UI", Arial, Helvetica, sans-serif;
    background: #f3f4f6;
    color: #1f2937;
}

.container {
    max-width: 1300px;
    margin: 0 auto;
}

header {
    padding: 30px;
    margin-bottom: 24px;
    border-radius: 12px;
    background: #111827;
    color: #ffffff;
}

header h1 {
    margin: 0 0 8px 0;
    font-size: 30px;
}

header p {
    margin: 0;
    color: #d1d5db;
}

section {
    margin-bottom: 24px;
    padding: 24px;
    border-radius: 12px;
    background: #ffffff;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

h2 {
    margin-top: 0;
    padding-bottom: 10px;
    border-bottom: 1px solid #e5e7eb;
    font-size: 22px;
}

h3 {
    margin-top: 28px;
    font-size: 18px;
}

table {
    width: 100%;
    margin-top: 16px;
    border-collapse: collapse;
}

th,
td {
    padding: 10px 12px;
    border-bottom: 1px solid #e5e7eb;
    text-align: left;
    vertical-align: top;
}

th {
    background: #f9fafb;
    font-weight: 600;
}

section > table th {
    width: 270px;
}

tbody tr:hover {
    background: #f9fafb;
}

.badge {
    display: inline-block;
    padding: 4px 9px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 600;
}

.badge.healthy {
    background: #dcfce7;
    color: #166534;
}

.badge.information {
    background: #dbeafe;
    color: #1e40af;
}

.badge.warning {
    background: #fef3c7;
    color: #92400e;
}

.badge.critical {
    background: #fee2e2;
    color: #991b1b;
}

.badge.neutral {
    background: #e5e7eb;
    color: #374151;
}

.health-banner {
    margin-top: 16px;
    padding: 16px;
    border-radius: 10px;
    background: #f9fafb;
    font-size: 18px;
    font-weight: 600;
}

.notice {
    padding: 12px;
    border-radius: 8px;
    background: #fef3c7;
}

.footer {
    margin-top: 30px;
    padding: 10px;
    text-align: center;
    color: #6b7280;
    font-size: 12px;
}

</style>

</head>

<body>

<div class="container">

<header>

<h1>IT-Toolkit Diagnostic Report</h1>

<p>Generated: $generatedAt</p>

</header>


<section>

<h2>Summary</h2>

<div class="health-banner">
Overall Health:
<span class="badge $overallHealthClass">$overallHealth</span>
</div>

<table>
<tbody>
$($summaryHtml -join "`n")
</tbody>
</table>

</section>


<section>

<h2>System Information</h2>

<table>
<tbody>
$($systemHtml -join "`n")
</tbody>
</table>

</section>


<section>

<h2>Network</h2>

<table>
<tbody>
$($networkHtml -join "`n")
</tbody>
</table>

</section>


<section>

<h2>Windows Health</h2>

<table>
<tbody>

<tr>
<th>Reboot Required</th>
<td>$rebootRequired</td>
</tr>

<tr>
<th>Reboot Reasons</th>
<td>$rebootReasons</td>
</tr>

<tr>
<th>Stopped Automatic Services</th>
<td>$stoppedServiceCount</td>
</tr>

<tr>
<th>Recent System Errors</th>
<td>$recentErrorCount</td>
</tr>

</tbody>
</table>

<h3>Stopped Automatic Services</h3>

$servicesHtml

<h3>Recent System Errors</h3>

$eventsHtml

</section>


<section>

<h2>Storage</h2>

<h3>Logical Drives</h3>

$logicalDrivesHtml

<h3>Physical Disks</h3>

$physicalDisksHtml

</section>


<section>

<h2>Windows Update</h2>

$updatesHtml

</section>


<section>

<h2>Performance</h2>

<table>
<tbody>
$($performanceHtml -join "`n")
</tbody>
</table>

<h3>Top CPU Processes</h3>

<p>
CPU represents accumulated processor time rather than live CPU percentage.
</p>

$topCPUHtml

<h3>Top Memory Processes</h3>

$topMemoryHtml

</section>


<section>

<h2>Health Analysis</h2>

<div class="health-banner">
Overall Status:
<span class="badge $overallHealthClass">$overallHealth</span>
</div>

<p>
Healthy: $($Report.Health.HealthyCount)
&nbsp; | &nbsp;
Warnings: $($Report.Health.WarningCount)
&nbsp; | &nbsp;
Critical: $($Report.Health.CriticalCount)
&nbsp; | &nbsp;
Information: $($Report.Health.InfoCount)
</p>

$healthFindingsHtml

</section>


<div class="footer">

Generated locally by IT-Toolkit.

</div>

</div>

</body>

</html>
"@


    $directory = Split-Path $Path -Parent

    if (
        $directory -and
        -not (Test-Path $directory)
    ) {

        New-Item `
            -ItemType Directory `
            -Path $directory `
            -Force |
            Out-Null
    }


    $html |
        Set-Content `
            -Path $Path `
            -Encoding UTF8


    Get-Item $Path
}


Export-ModuleMember -Function @(
    'Get-ITDiagnosticReportData',
    'Export-ITDiagnosticReportText',
    'Export-ITDiagnosticReportHtml'
)