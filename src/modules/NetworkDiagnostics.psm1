function Get-ITNetworkInformation {
    [CmdletBinding()]
    param(
        [switch]$IncludeVirtual
    )

    try {
        $adapters = Get-NetIPConfiguration |
            Where-Object {
                $_.NetAdapter.Status -eq 'Up' -and
                $_.IPv4Address
            }

        foreach ($adapter in $adapters) {

            $isVirtual =
                $adapter.NetAdapter.Virtual -eq $true -or
                $adapter.InterfaceAlias -match 'VMware|vEthernet|VirtualBox|Hyper-V'

            if (-not $IncludeVirtual -and $isVirtual) {
                continue
            }

            [PSCustomObject]@{
                InterfaceAlias = $adapter.InterfaceAlias
                Description    = $adapter.NetAdapter.InterfaceDescription
                Type           = if ($isVirtual) { 'Virtual' } else { 'Physical' }
                IPv4Address    = $adapter.IPv4Address.IPAddress -join ', '
                Gateway        = $adapter.IPv4DefaultGateway.NextHop -join ', '
                DNSServers     = $adapter.DNSServer.ServerAddresses -join ', '
                MACAddress     = $adapter.NetAdapter.MacAddress
                LinkSpeed      = $adapter.NetAdapter.LinkSpeed
            }
        }
    }
    catch {
        Write-Error "Unable to retrieve network adapter information: $($_.Exception.Message)"
    }
}


function Test-ITInternetConnection {
    [CmdletBinding()]
    param()

    $targets = @(
        '1.1.1.1',
        '8.8.8.8'
    )

    foreach ($target in $targets) {

        try {
            $reachable = Test-Connection `
                -ComputerName $target `
                -Count 1 `
                -Quiet `
                -ErrorAction Stop

            if ($reachable) {

                return [PSCustomObject]@{
                    Connected = $true
                    Target    = $target
                    Status    = 'Internet connectivity available'
                }
            }
        }
        catch {
            continue
        }
    }

    [PSCustomObject]@{
        Connected = $false
        Target    = $null
        Status    = 'Internet connectivity test failed'
    }
}


function Test-ITDNSResolution {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name = 'github.com'
    )

    try {

        $result = Resolve-DnsName `
            -Name $Name `
            -ErrorAction Stop

        $addresses = $result |
            Where-Object {
                $_.IPAddress
            } |
            Select-Object -ExpandProperty IPAddress -Unique

        [PSCustomObject]@{
            Name       = $Name
            Successful = $true
            Addresses  = $addresses -join ', '
            Error      = $null
        }
    }
    catch {

        [PSCustomObject]@{
            Name       = $Name
            Successful = $false
            Addresses  = $null
            Error      = $_.Exception.Message
        }
    }
}


function Test-ITTCPPort {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [ValidateRange(1, 65535)]
        [int]$Port
    )

    try {

        $result = Test-NetConnection `
            -ComputerName $ComputerName `
            -Port $Port `
            -WarningAction SilentlyContinue `
            -ErrorAction Stop

        [PSCustomObject]@{
            ComputerName  = $ComputerName
            Port          = $Port
            Successful    = $result.TcpTestSucceeded
            RemoteAddress = $result.RemoteAddress
            Error         = $null
        }
    }
    catch {

        [PSCustomObject]@{
            ComputerName  = $ComputerName
            Port          = $Port
            Successful    = $false
            RemoteAddress = $null
            Error         = $_.Exception.Message
        }
    }
}


function Invoke-ITTraceRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName
    )

    try {

        $result = Test-NetConnection `
            -ComputerName $ComputerName `
            -TraceRoute `
            -ErrorAction Stop

        [PSCustomObject]@{
            ComputerName  = $result.ComputerName
            RemoteAddress = $result.RemoteAddress
            TraceRoute    = $result.TraceRoute
            Successful    = $true
            Error         = $null
        }
    }
    catch {

        [PSCustomObject]@{
            ComputerName  = $ComputerName
            RemoteAddress = $null
            TraceRoute    = @()
            Successful    = $false
            Error         = $_.Exception.Message
        }
    }
}


function Get-ITWiFiInformation {
    [CmdletBinding()]
    param()

    try {

        $interfaceOutput = netsh wlan show interfaces

        if ($LASTEXITCODE -ne 0 -or -not $interfaceOutput) {
            throw 'Unable to retrieve Wi-Fi information.'
        }

        $properties = @{}

        foreach ($line in $interfaceOutput) {

            if ($line -match '^\s*(.+?)\s*:\s*(.+)$') {

                $key = $matches[1].Trim()
                $value = $matches[2].Trim()

                $properties[$key] = $value
            }
        }

        if (-not $properties.ContainsKey('Name')) {

            return [PSCustomObject]@{
                Connected    = $false
                Name         = $null
                Description  = $null
                SSID         = $null
                BSSID        = $null
                RadioType    = $null
                Channel      = $null
                Signal       = $null
                ReceiveRate  = $null
                TransmitRate = $null
                Error        = 'No active Wi-Fi interface was found.'
            }
        }

        [PSCustomObject]@{
            Connected    = $true
            Name         = $properties['Name']
            Description  = $properties['Description']
            SSID         = $properties['SSID']
            BSSID        = $properties['BSSID']
            RadioType    = $properties['Radio type']
            Channel      = $properties['Channel']
            Signal       = $properties['Signal']
            ReceiveRate  = $properties['Receive rate (Mbps)']
            TransmitRate = $properties['Transmit rate (Mbps)']
            Error        = $null
        }
    }
    catch {

        [PSCustomObject]@{
            Connected    = $false
            Name         = $null
            Description  = $null
            SSID         = $null
            BSSID        = $null
            RadioType    = $null
            Channel      = $null
            Signal       = $null
            ReceiveRate  = $null
            TransmitRate = $null
            Error        = $_.Exception.Message
        }
    }
}


Export-ModuleMember -Function @(
    'Get-ITNetworkInformation',
    'Test-ITInternetConnection',
    'Test-ITDNSResolution',
    'Test-ITTCPPort',
    'Invoke-ITTraceRoute',
    'Get-ITWiFiInformation'
)