function Get-ITHealthAnalysis {
    [CmdletBinding()]
    param()

    $internetStatus = Test-ITInternetConnection
    $dnsStatus = Test-ITDNSResolution
    $pendingReboot = Get-ITPendingReboot
    $serviceHealth = Get-ITServiceHealth
    $recentErrors = Get-ITRecentSystemErrors -Hours 24 -MaxEvents 500
    $storageHealth = Get-ITStorageHealth
    $updateStatus = Get-ITWindowsUpdateStatus
    $performance = Get-ITPerformanceSnapshot

    $findings = @()

    # Internet connectivity
    if ($internetStatus.Connected) {
        $findings += [PSCustomObject]@{
            Area = 'Internet'
            Severity = 'Healthy'
            Finding = 'Internet connectivity available'
            Recommendation = $null
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'Internet'
            Severity = 'Critical'
            Finding = 'Internet connectivity test failed'
            Recommendation = 'Verify the active network adapter, IP configuration, default gateway, firewall rules, and upstream connectivity.'
        }
    }

    # DNS resolution
    if ($dnsStatus.Successful) {
        $findings += [PSCustomObject]@{
            Area = 'DNS'
            Severity = 'Healthy'
            Finding = 'DNS resolution successful'
            Recommendation = $null
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'DNS'
            Severity = 'Critical'
            Finding = 'DNS resolution failed'
            Recommendation = 'Verify the configured DNS servers, test direct IP connectivity, and review VPN or firewall configuration that may affect DNS traffic.'
        }
    }

    # Pending reboot
    if ($pendingReboot.RebootRequired) {
        $reasonText = if ($pendingReboot.Reasons) {
            $pendingReboot.Reasons
        }
        else {
            'Windows reports that a reboot is pending'
        }

        $findings += [PSCustomObject]@{
            Area = 'Windows'
            Severity = 'Warning'
            Finding = "Pending reboot detected: $reasonText"
            Recommendation = 'Review the pending reboot reason and restart Windows during an appropriate maintenance window.'
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'Windows'
            Severity = 'Healthy'
            Finding = 'No pending reboot detected'
            Recommendation = $null
        }
    }

    # Storage health
    $criticalDrives = @($storageHealth | Where-Object { $_.Status -eq 'Critical' })
    $warningDrives = @($storageHealth | Where-Object { $_.Status -eq 'Warning' })

    if ($criticalDrives.Count -gt 0) {
        $driveDetails = $criticalDrives | ForEach-Object { "$($_.Drive) ($($_.FreePercent)% free)" }

        $findings += [PSCustomObject]@{
            Area = 'Storage'
            Severity = 'Critical'
            Finding = "Critical free-space condition detected on: $($driveDetails -join ', ')"
            Recommendation = 'Identify the largest consumers of disk space, review temporary data and unused files or software, and restore sufficient free capacity as soon as practical.'
        }
    }
    elseif ($warningDrives.Count -gt 0) {
        $driveDetails = $warningDrives | ForEach-Object { "$($_.Drive) ($($_.FreePercent)% free)" }

        $findings += [PSCustomObject]@{
            Area = 'Storage'
            Severity = 'Warning'
            Finding = "Low free space detected on: $($driveDetails -join ', ')"
            Recommendation = 'Review disk usage, identify large or unnecessary files, and monitor available capacity.'
        }
    }
    elseif (@($storageHealth).Count -gt 0) {
        $findings += [PSCustomObject]@{
            Area = 'Storage'
            Severity = 'Healthy'
            Finding = 'All fixed drives have at least 20% free space'
            Recommendation = $null
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'Storage'
            Severity = 'Information'
            Finding = 'Storage health could not be determined'
            Recommendation = 'Review logical drive information manually and confirm that storage information is available to the current PowerShell session.'
        }
    }

    # Recent system errors
    $errorCount = @($recentErrors).Count

    if ($errorCount -ge 25) {
        $findings += [PSCustomObject]@{
            Area = 'Event Logs'
            Severity = 'Critical'
            Finding = "$errorCount Critical/Error System events detected in the last 24 hours"
            Recommendation = 'Run Get-ITEventCorrelation to identify repeated providers and Event IDs, then investigate the most frequent or recent errors.'
        }
    }
    elseif ($errorCount -ge 10) {
        $findings += [PSCustomObject]@{
            Area = 'Event Logs'
            Severity = 'Warning'
            Finding = "$errorCount Critical/Error System events detected in the last 24 hours"
            Recommendation = 'Run Get-ITEventCorrelation and review repeated or recent System events that correspond with the reported issue.'
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'Event Logs'
            Severity = 'Healthy'
            Finding = "$errorCount Critical/Error System events detected in the last 24 hours"
            Recommendation = $null
        }
    }

    # Stopped automatic services
    $serviceCount = @($serviceHealth).Count

    $findings += [PSCustomObject]@{
        Area = 'Services'
        Severity = 'Information'
        Finding = "$serviceCount automatic service(s) are currently stopped"
        Recommendation = if ($serviceCount -gt 0) {
            'Review the stopped services and use Get-ITServiceDependency for any service relevant to the reported issue before considering corrective action.'
        }
        else {
            $null
        }
    }

    # Windows Update
    if ($updateStatus.Error) {
        $findings += [PSCustomObject]@{
            Area = 'Windows Update'
            Severity = 'Information'
            Finding = 'Windows Update status could not be determined'
            Recommendation = 'Review Windows Update manually and confirm that the Windows Update service and required management interfaces are available.'
        }
    }
    elseif ($updateStatus.UpdateCount -ge 5) {
        $findings += [PSCustomObject]@{
            Area = 'Windows Update'
            Severity = 'Warning'
            Finding = "$($updateStatus.UpdateCount) pending software updates detected"
            Recommendation = 'Review the available updates and determine whether relevant security, reliability, or compatibility updates should be scheduled for installation.'
        }
    }
    elseif ($updateStatus.UpdateCount -gt 0) {
        $findings += [PSCustomObject]@{
            Area = 'Windows Update'
            Severity = 'Information'
            Finding = "$($updateStatus.UpdateCount) pending software update(s) detected"
            Recommendation = 'Review the available updates and determine whether they are relevant to the issue or normal maintenance.'
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'Windows Update'
            Severity = 'Healthy'
            Finding = 'No pending software updates detected'
            Recommendation = $null
        }
    }

    # CPU usage
    $cpuUsage = [double]$performance.CPUUsagePercent

    if ($cpuUsage -ge 95) {
        $findings += [PSCustomObject]@{
            Area = 'CPU'
            Severity = 'Critical'
            Finding = "CPU usage is $cpuUsage%"
            Recommendation = 'Use Get-ITTopProcesses and Get-ITPerformanceSample to identify sustained CPU consumers and determine whether the workload is expected.'
        }
    }
    elseif ($cpuUsage -ge 80) {
        $findings += [PSCustomObject]@{
            Area = 'CPU'
            Severity = 'Warning'
            Finding = "CPU usage is $cpuUsage%"
            Recommendation = 'Use Get-ITTopProcesses and Get-ITPerformanceSample to determine whether elevated CPU usage persists and identify the processes contributing to it.'
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'CPU'
            Severity = 'Healthy'
            Finding = "CPU usage is $cpuUsage%"
            Recommendation = $null
        }
    }

    # Memory usage
    $memoryUsage = [double]$performance.MemoryUsedPercent

    if ($memoryUsage -ge 90) {
        $findings += [PSCustomObject]@{
            Area = 'Memory'
            Severity = 'Critical'
            Finding = "Memory usage is $memoryUsage%"
            Recommendation = 'Use Get-ITMemoryConsumers to identify the largest memory consumers and investigate sustained memory pressure or unexpected process growth.'
        }
    }
    elseif ($memoryUsage -ge 80) {
        $findings += [PSCustomObject]@{
            Area = 'Memory'
            Severity = 'Warning'
            Finding = "Memory usage is $memoryUsage%"
            Recommendation = 'Use Get-ITMemoryConsumers to identify high-memory processes and monitor whether elevated memory usage persists.'
        }
    }
    else {
        $findings += [PSCustomObject]@{
            Area = 'Memory'
            Severity = 'Healthy'
            Finding = "Memory usage is $memoryUsage%"
            Recommendation = $null
        }
    }

    # Overall status
    $overallStatus = if ($findings.Severity -contains 'Critical') {
        'Critical'
    }
    elseif ($findings.Severity -contains 'Warning') {
        'Warning'
    }
    else {
        'Healthy'
    }

    [PSCustomObject]@{
        GeneratedAt = Get-Date
        OverallStatus = $overallStatus
        HealthyCount = @($findings | Where-Object { $_.Severity -eq 'Healthy' }).Count
        WarningCount = @($findings | Where-Object { $_.Severity -eq 'Warning' }).Count
        CriticalCount = @($findings | Where-Object { $_.Severity -eq 'Critical' }).Count
        InfoCount = @($findings | Where-Object { $_.Severity -eq 'Information' }).Count
        Findings = $findings
    }
}

Export-ModuleMember -Function Get-ITHealthAnalysis