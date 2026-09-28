function Get-ITHealthAnalysis {
    [CmdletBinding()]
    param()

    $systemInfo = Get-ITSystemInformation
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
            Area           = 'Internet'
            Severity       = 'Healthy'
            Finding        = 'Internet connectivity available'
            Recommendation = $null
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Internet'
            Severity       = 'Critical'
            Finding        = 'Internet connectivity test failed'
            Recommendation = 'Check network connectivity, gateway configuration, firewall rules, and upstream connectivity.'
        }
    }


    # DNS resolution
    if ($dnsStatus.Successful) {

        $findings += [PSCustomObject]@{
            Area           = 'DNS'
            Severity       = 'Healthy'
            Finding        = 'DNS resolution successful'
            Recommendation = $null
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'DNS'
            Severity       = 'Critical'
            Finding        = 'DNS resolution failed'
            Recommendation = 'Check configured DNS servers, network connectivity, VPN configuration, and firewall rules.'
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
            Area           = 'Windows'
            Severity       = 'Warning'
            Finding        = "Pending reboot detected: $reasonText"
            Recommendation = 'Restart Windows when appropriate to complete pending operations.'
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Windows'
            Severity       = 'Healthy'
            Finding        = 'No pending reboot detected'
            Recommendation = $null
        }
    }


    # Storage health across all fixed drives
    $criticalDrives = @(
        $storageHealth |
            Where-Object {
                $_.Status -eq 'Critical'
            }
    )

    $warningDrives = @(
        $storageHealth |
            Where-Object {
                $_.Status -eq 'Warning'
            }
    )

    if ($criticalDrives.Count -gt 0) {

        $driveDetails = $criticalDrives |
            ForEach-Object {
                "$($_.Drive) ($($_.FreePercent)% free)"
            }

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Critical'
            Finding        = "Critical free-space condition detected on: $($driveDetails -join ', ')"
            Recommendation = 'Free disk space as soon as possible and investigate large files, temporary data, and unused software.'
        }
    }
    elseif ($warningDrives.Count -gt 0) {

        $driveDetails = $warningDrives |
            ForEach-Object {
                "$($_.Drive) ($($_.FreePercent)% free)"
            }

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Warning'
            Finding        = "Low free space detected on: $($driveDetails -join ', ')"
            Recommendation = 'Review disk usage and consider freeing additional space.'
        }
    }
    elseif (@($storageHealth).Count -gt 0) {

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Healthy'
            Finding        = 'All fixed drives have at least 20% free space'
            Recommendation = $null
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Information'
            Finding        = 'Storage health could not be determined'
            Recommendation = 'Review storage information manually if disk capacity is relevant to the issue.'
        }
    }


    # Recent system errors
    $errorCount = @($recentErrors).Count

    if ($errorCount -ge 25) {

        $findings += [PSCustomObject]@{
            Area           = 'Event Logs'
            Severity       = 'Critical'
            Finding        = "$errorCount Critical/Error System events detected in the last 24 hours"
            Recommendation = 'Review the recent System event log entries and identify repeated providers or Event IDs.'
        }
    }
    elseif ($errorCount -ge 10) {

        $findings += [PSCustomObject]@{
            Area           = 'Event Logs'
            Severity       = 'Warning'
            Finding        = "$errorCount Critical/Error System events detected in the last 24 hours"
            Recommendation = 'Review recent System errors for repeated or relevant events.'
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Event Logs'
            Severity       = 'Healthy'
            Finding        = "$errorCount Critical/Error System events detected in the last 24 hours"
            Recommendation = $null
        }
    }


    # Stopped automatic services
    $serviceCount = @($serviceHealth).Count

    $findings += [PSCustomObject]@{
        Area           = 'Services'
        Severity       = 'Information'
        Finding        = "$serviceCount automatic service(s) are currently stopped"
        Recommendation = if ($serviceCount -gt 0) {
            'Review stopped automatic services where relevant to the issue being investigated.'
        }
        else {
            $null
        }
    }


    # Windows Update
    if ($updateStatus.Error) {

        $findings += [PSCustomObject]@{
            Area           = 'Windows Update'
            Severity       = 'Information'
            Finding        = 'Windows Update status could not be determined'
            Recommendation = 'Review Windows Update manually if update status is relevant to the issue.'
        }
    }
    elseif ($updateStatus.UpdateCount -ge 5) {

        $findings += [PSCustomObject]@{
            Area           = 'Windows Update'
            Severity       = 'Warning'
            Finding        = "$($updateStatus.UpdateCount) pending software updates detected"
            Recommendation = 'Review and apply appropriate Windows updates when suitable.'
        }
    }
    elseif ($updateStatus.UpdateCount -gt 0) {

        $findings += [PSCustomObject]@{
            Area           = 'Windows Update'
            Severity       = 'Information'
            Finding        = "$($updateStatus.UpdateCount) pending software update(s) detected"
            Recommendation = 'Review available updates where relevant.'
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Windows Update'
            Severity       = 'Healthy'
            Finding        = 'No pending software updates detected'
            Recommendation = $null
        }
    }


    # CPU usage
    $cpuUsage = [double]$performance.CPUUsagePercent

    if ($cpuUsage -ge 95) {

        $findings += [PSCustomObject]@{
            Area           = 'CPU'
            Severity       = 'Critical'
            Finding        = "CPU usage is $cpuUsage%"
            Recommendation = 'Identify processes consuming significant CPU and determine whether the load is expected.'
        }
    }
    elseif ($cpuUsage -ge 80) {

        $findings += [PSCustomObject]@{
            Area           = 'CPU'
            Severity       = 'Warning'
            Finding        = "CPU usage is $cpuUsage%"
            Recommendation = 'Review running processes and monitor whether high CPU usage persists.'
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'CPU'
            Severity       = 'Healthy'
            Finding        = "CPU usage is $cpuUsage%"
            Recommendation = $null
        }
    }


    # Memory usage
    $memoryUsage = [double]$performance.MemoryUsedPercent

    if ($memoryUsage -ge 90) {

        $findings += [PSCustomObject]@{
            Area           = 'Memory'
            Severity       = 'Critical'
            Finding        = "Memory usage is $memoryUsage%"
            Recommendation = 'Review high-memory processes and investigate sustained memory pressure.'
        }
    }
    elseif ($memoryUsage -ge 80) {

        $findings += [PSCustomObject]@{
            Area           = 'Memory'
            Severity       = 'Warning'
            Finding        = "Memory usage is $memoryUsage%"
            Recommendation = 'Review memory consumers and monitor whether high usage persists.'
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Memory'
            Severity       = 'Healthy'
            Finding        = "Memory usage is $memoryUsage%"
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
        GeneratedAt   = Get-Date
        OverallStatus = $overallStatus

        HealthyCount = @(
            $findings |
                Where-Object {
                    $_.Severity -eq 'Healthy'
                }
        ).Count

        WarningCount = @(
            $findings |
                Where-Object {
                    $_.Severity -eq 'Warning'
                }
        ).Count

        CriticalCount = @(
            $findings |
                Where-Object {
                    $_.Severity -eq 'Critical'
                }
        ).Count

        InfoCount = @(
            $findings |
                Where-Object {
                    $_.Severity -eq 'Information'
                }
        ).Count

        Findings = $findings
    }
}


Export-ModuleMember -Function Get-ITHealthAnalysis