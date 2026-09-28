function Get-ITDiagnosticReportData {
    [CmdletBinding()]
    param()

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

        Summary = [PSCustomObject]@{
            InternetConnected      = $internetStatus.Connected
            DNSWorking             = $dnsStatus.Successful
            RebootRequired         = $pendingReboot.RebootRequired
            DriveFreePercent       = $systemInfo.DriveFreePercent
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

            $lines += "$($service.Name) - $($service.DisplayName) - $($service.Status) - $($service.StartType)"
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

    $lines += ""
    $lines += "=================================================="
    $lines += "SUMMARY"
    $lines += "=================================================="

    $lines += "Internet Connected    : $($Report.Summary.InternetConnected)"
    $lines += "DNS Working           : $($Report.Summary.DNSWorking)"
    $lines += "Reboot Required       : $($Report.Summary.RebootRequired)"
    $lines += "Drive Free Percent    : $($Report.Summary.DriveFreePercent)%"
    $lines += "Stopped Auto Services : $($Report.Summary.StoppedAutomaticCount)"
    $lines += "Recent System Errors  : $($Report.Summary.RecentSystemErrorCount)"

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


    $summaryRows = @(

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
            Label = 'Stopped Automatic Services'
            Value = $Report.Summary.StoppedAutomaticCount
        }

        [PSCustomObject]@{
            Label = 'Recent System Errors'
            Value = $Report.Summary.RecentSystemErrorCount
        }
    )


    $systemHtml = ConvertTo-ITTableRows `
        -Rows $systemRows

    $networkHtml = ConvertTo-ITTableRows `
        -Rows $networkRows

    $summaryHtml = ConvertTo-ITTableRows `
        -Rows $summaryRows


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


    $generatedAt = ConvertTo-ITHtmlEncodedValue `
        -Value $Report.GeneratedAt

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
    max-width: 1200px;
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