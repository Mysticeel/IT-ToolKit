function Get-ITHealthAnalysis {
    [CmdletBinding()]
    param()

    $systemInfo = Get-ITSystemInformation
    $internetStatus = Test-ITInternetConnection
    $dnsStatus = Test-ITDNSResolution
    $pendingReboot = Get-ITPendingReboot
    $serviceHealth = Get-ITServiceHealth
    $recentErrors = Get-ITRecentSystemErrors -Hours 24 -MaxEvents 500

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


    # System drive space
    $freePercent = [double]$systemInfo.DriveFreePercent

    if ($freePercent -lt 10) {

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Critical'
            Finding        = "System drive has only $freePercent% free space"
            Recommendation = 'Free disk space as soon as possible and investigate large files, temporary data, and unused software.'
        }
    }
    elseif ($freePercent -lt 20) {

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Warning'
            Finding        = "System drive has $freePercent% free space"
            Recommendation = 'Review disk usage and consider freeing additional space.'
        }
    }
    else {

        $findings += [PSCustomObject]@{
            Area           = 'Storage'
            Severity       = 'Healthy'
            Finding        = "System drive has $freePercent% free space"
            Recommendation = $null
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
        HealthyCount  = @($findings | Where-Object Severity -eq 'Healthy').Count
        WarningCount  = @($findings | Where-Object Severity -eq 'Warning').Count
        CriticalCount = @($findings | Where-Object Severity -eq 'Critical').Count
        InfoCount     = @($findings | Where-Object Severity -eq 'Information').Count
        Findings      = $findings
    }
}


Export-ModuleMember -Function Get-ITHealthAnalysis