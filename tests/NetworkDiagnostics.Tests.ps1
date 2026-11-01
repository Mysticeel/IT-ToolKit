
$modulePath = Join-Path $PSScriptRoot "..\src\Modules\NetworkDiagnostics.psm1"

Import-Module $modulePath -Force

Describe "NetworkDiagnostics Module" {

    Context "Module structure" {

        It "Exports Get-ITNetworkInformation" {
            Get-Command Get-ITNetworkInformation -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Test-ITInternetConnection" {
            Get-Command Test-ITInternetConnection -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Test-ITDNSResolution" {
            Get-Command Test-ITDNSResolution -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Test-ITTCPPort" {
            Get-Command Test-ITTCPPort -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Invoke-ITTraceRoute" {
            Get-Command Invoke-ITTraceRoute -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Exports Get-ITWiFiInformation" {
            Get-Command Get-ITWiFiInformation -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Network information" {

        It "Returns physical adapter information" {
            Mock Get-NetIPConfiguration {
                [PSCustomObject]@{
                    InterfaceAlias = 'Ethernet'
                    NetAdapter = [PSCustomObject]@{
                        Status = 'Up'
                        Virtual = $false
                        InterfaceDescription = 'Intel Ethernet Adapter'
                        MacAddress = '00-11-22-33-44-55'
                        LinkSpeed = '1 Gbps'
                    }
                    IPv4Address = [PSCustomObject]@{ IPAddress = '192.0.2.10' }
                    IPv4DefaultGateway = [PSCustomObject]@{ NextHop = '192.0.2.1' }
                    DNSServer = [PSCustomObject]@{ ServerAddresses = @('192.0.2.53') }
                }
            } -ModuleName NetworkDiagnostics

            $result = Get-ITNetworkInformation
            $result.InterfaceAlias | Should -Be 'Ethernet'
            $result.Description | Should -Be 'Intel Ethernet Adapter'
            $result.Type | Should -Be 'Physical'
            $result.IPv4Address | Should -Be '192.0.2.10'
            $result.Gateway | Should -Be '192.0.2.1'
            $result.DNSServers | Should -Be '192.0.2.53'
            $result.MACAddress | Should -Be '00-11-22-33-44-55'
            $result.LinkSpeed | Should -Be '1 Gbps'
            Should -Invoke Get-NetIPConfiguration -ModuleName NetworkDiagnostics -Times 1 -Exactly
        }

        It "Excludes virtual adapters by default" {
            Mock Get-NetIPConfiguration {
                @(
                    [PSCustomObject]@{
                        InterfaceAlias = 'Ethernet'
                        NetAdapter = [PSCustomObject]@{ Status = 'Up'; Virtual = $false }
                        IPv4Address = [PSCustomObject]@{ IPAddress = '192.0.2.10' }
                    }
                    [PSCustomObject]@{
                        InterfaceAlias = 'vEthernet (Default Switch)'
                        NetAdapter = [PSCustomObject]@{ Status = 'Up'; Virtual = $true }
                        IPv4Address = [PSCustomObject]@{ IPAddress = '198.51.100.10' }
                    }
                )
            } -ModuleName NetworkDiagnostics

            $result = @(Get-ITNetworkInformation)
            $result.Count | Should -Be 1
            $result[0].InterfaceAlias | Should -Be 'Ethernet'
        }

        It "Includes virtual adapters when requested" {
            Mock Get-NetIPConfiguration {
                @(
                    [PSCustomObject]@{
                        InterfaceAlias = 'Ethernet'
                        NetAdapter = [PSCustomObject]@{ Status = 'Up'; Virtual = $false }
                        IPv4Address = [PSCustomObject]@{ IPAddress = '192.0.2.10' }
                    }
                    [PSCustomObject]@{
                        InterfaceAlias = 'vEthernet (Default Switch)'
                        NetAdapter = [PSCustomObject]@{ Status = 'Up'; Virtual = $true }
                        IPv4Address = [PSCustomObject]@{ IPAddress = '198.51.100.10' }
                    }
                )
            } -ModuleName NetworkDiagnostics

            $result = @(Get-ITNetworkInformation -IncludeVirtual)
            $result.Count | Should -Be 2
            $result.Type | Should -Contain 'Physical'
            $result.Type | Should -Contain 'Virtual'
        }

        It "Excludes disconnected adapters" {
            Mock Get-NetIPConfiguration {
                [PSCustomObject]@{
                    InterfaceAlias = 'Disconnected Ethernet'
                    NetAdapter = [PSCustomObject]@{ Status = 'Down'; Virtual = $false }
                    IPv4Address = [PSCustomObject]@{ IPAddress = '192.0.2.20' }
                }
            } -ModuleName NetworkDiagnostics

            $result = @(Get-ITNetworkInformation)
            $result.Count | Should -Be 0
        }

        It "Excludes adapters without IPv4 addresses" {
            Mock Get-NetIPConfiguration {
                [PSCustomObject]@{
                    InterfaceAlias = 'No IPv4'
                    NetAdapter = [PSCustomObject]@{ Status = 'Up'; Virtual = $false }
                    IPv4Address = $null
                }
            } -ModuleName NetworkDiagnostics

            $result = @(Get-ITNetworkInformation)
            $result.Count | Should -Be 0
        }

        It "Reports errors when network configuration cannot be retrieved" {
            Mock Get-NetIPConfiguration {
                throw 'Network configuration unavailable'
            } -ModuleName NetworkDiagnostics

            $errorRecords = @()
            $result = @(
                Get-ITNetworkInformation -ErrorAction SilentlyContinue -ErrorVariable +errorRecords
            )
            $result.Count | Should -Be 0
            $errorRecords.Count | Should -BeGreaterThan 0
            $errorRecords[0].ToString() | Should -Match 'Network configuration unavailable'
        }
    }

    Context "Internet connectivity" {

        It "Returns connected when the primary target responds" {

            Mock Test-Connection {
                return $true
            } -ModuleName NetworkDiagnostics

            $result = Test-ITInternetConnection

            $result.Connected |
                Should -BeTrue

            $result.Target |
                Should -Be '1.1.1.1'

            $result.Status |
                Should -Be 'Internet connectivity available'

            Should -Invoke Test-Connection `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly
        }

        It "Falls back to the secondary target when the primary fails" {

            Mock Test-Connection {
                return $false
            } -ModuleName NetworkDiagnostics

            Mock Test-Connection {
                return $true
            } -ModuleName NetworkDiagnostics -ParameterFilter {
                $ComputerName -eq '8.8.8.8'
            }

            $result = Test-ITInternetConnection

            $result.Connected |
                Should -BeTrue

            $result.Target |
                Should -Be '8.8.8.8'

            $result.Status |
                Should -Be 'Internet connectivity available'

            Should -Invoke Test-Connection `
                -ModuleName NetworkDiagnostics `
                -Times 2 `
                -Exactly

            Should -Invoke Test-Connection `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly `
                -ParameterFilter {
                    $ComputerName -eq '1.1.1.1'
                }

            Should -Invoke Test-Connection `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly `
                -ParameterFilter {
                    $ComputerName -eq '8.8.8.8'
                }
        }

        It "Returns disconnected when both targets fail" {

            Mock Test-Connection {
                return $false
            } -ModuleName NetworkDiagnostics

            $result = Test-ITInternetConnection

            $result.Connected |
                Should -BeFalse

            $result.Target |
                Should -BeNullOrEmpty

            $result.Status |
                Should -Be 'Internet connectivity test failed'

            Should -Invoke Test-Connection `
                -ModuleName NetworkDiagnostics `
                -Times 2 `
                -Exactly
        }

        It "Handles connection errors without throwing" {

            Mock Test-Connection {
                throw 'Network unreachable'
            } -ModuleName NetworkDiagnostics

            $result = Test-ITInternetConnection

            $result |
                Should -Not -BeNullOrEmpty

            $result.Connected |
                Should -BeFalse

            $result.Target |
                Should -BeNullOrEmpty

            $result.Status |
                Should -Be 'Internet connectivity test failed'

            Should -Invoke Test-Connection `
                -ModuleName NetworkDiagnostics `
                -Times 2 `
                -Exactly
        }
    }

    Context "DNS resolution" {

        It "Successfully resolves a DNS name" {

            Mock Resolve-DnsName {
                [PSCustomObject]@{
                    Name      = 'example.com'
                    Type      = 'A'
                    IPAddress = '93.184.215.14'
                }
            } -ModuleName NetworkDiagnostics

            $result = Test-ITDNSResolution -Name 'example.com'

            $result.Name |
                Should -Be 'example.com'

            $result.Successful |
                Should -BeTrue

            $result.Addresses |
                Should -Be '93.184.215.14'

            $result.Error |
                Should -BeNullOrEmpty

            Should -Invoke Resolve-DnsName `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly
        }

        It "Returns multiple unique IP addresses" {

            Mock Resolve-DnsName {
                @(
                    [PSCustomObject]@{
                        IPAddress = '192.0.2.10'
                    }

                    [PSCustomObject]@{
                        IPAddress = '192.0.2.11'
                    }

                    [PSCustomObject]@{
                        IPAddress = '192.0.2.10'
                    }
                )
            } -ModuleName NetworkDiagnostics

            $result = Test-ITDNSResolution -Name 'example.com'

            $result.Successful |
                Should -BeTrue

            $result.Addresses |
                Should -Be '192.0.2.10, 192.0.2.11'
        }

        It "Handles DNS resolution failures" {

            Mock Resolve-DnsName {
                throw 'DNS lookup failed'
            } -ModuleName NetworkDiagnostics

            $result = Test-ITDNSResolution -Name 'invalid.example'

            $result.Successful |
                Should -BeFalse

            $result.Addresses |
                Should -BeNullOrEmpty

            $result.Error |
                Should -Match 'DNS lookup failed'
        }

        It "Preserves the requested hostname on failure" {

            Mock Resolve-DnsName {
                throw 'DNS server unavailable'
            } -ModuleName NetworkDiagnostics

            $result = Test-ITDNSResolution -Name 'example.com'

            $result.Name |
                Should -Be 'example.com'

            $result.Successful |
                Should -BeFalse

            $result.Error |
                Should -Match 'DNS server unavailable'

            Should -Invoke Resolve-DnsName `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly
        }
    }

    Context "TCP port validation" {

        It "Returns success when a TCP port is open" {

            $testComputerName = 'example.com'

            Mock Test-NetConnection {
                [PSCustomObject]@{
                    TcpTestSucceeded = $true
                    RemoteAddress    = '192.0.2.10'
                }
            } -ModuleName NetworkDiagnostics

            $result = Test-ITTCPPort `
                -ComputerName $testComputerName `
                -Port 443

            $result.ComputerName |
                Should -Be 'example.com'

            $result.Port |
                Should -Be 443

            $result.Successful |
                Should -BeTrue

            $result.RemoteAddress.ToString() |
                Should -Be '192.0.2.10'

            $result.Error |
                Should -BeNullOrEmpty

            Should -Invoke Test-NetConnection `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly `
                -ParameterFilter {
                    $ComputerName -eq 'example.com' -and
                    $Port -eq 443
                }
        }

        It "Returns failure when a TCP port is closed" {

            $testComputerName = 'example.com'

            Mock Test-NetConnection {
                [PSCustomObject]@{
                    TcpTestSucceeded = $false
                    RemoteAddress    = '192.0.2.10'
                }
            } -ModuleName NetworkDiagnostics

            $result = Test-ITTCPPort `
                -ComputerName $testComputerName `
                -Port 3389

            $result.Successful |
                Should -BeFalse

            $result.RemoteAddress.ToString() |
                Should -Be '192.0.2.10'

            $result.Error |
                Should -BeNullOrEmpty

            Should -Invoke Test-NetConnection `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly
        }

        It "Handles TCP connection errors" {

            $testComputerName = 'example.com'

            Mock Test-NetConnection {
                throw 'Connection timed out'
            } -ModuleName NetworkDiagnostics

            $result = Test-ITTCPPort `
                -ComputerName $testComputerName `
                -Port 443

            $result.ComputerName |
                Should -Be 'example.com'

            $result.Port |
                Should -Be 443

            $result.Successful |
                Should -BeFalse

            $result.RemoteAddress |
                Should -BeNullOrEmpty

            $result.Error |
                Should -Match 'Connection timed out'

            Should -Invoke Test-NetConnection `
                -ModuleName NetworkDiagnostics `
                -Times 1 `
                -Exactly
        }

        It "Rejects ports greater than 65535" {

            $testComputerName = 'example.com'

            {
                Test-ITTCPPort `
                    -ComputerName $testComputerName `
                    -Port 65536
            } | Should -Throw
        }

        It "Rejects port zero" {

            $testComputerName = 'example.com'

            {
                Test-ITTCPPort `
                    -ComputerName $testComputerName `
                    -Port 0
            } | Should -Throw
        }
    }

    Context "Traceroute" {

        It "Returns successful traceroute information" {
            $testComputerName = 'example.com'

            Mock Test-NetConnection {
                [PSCustomObject]@{
                    ComputerName  = 'example.com'
                    RemoteAddress = '192.0.2.10'
                    TraceRoute    = @('192.0.2.1', '198.51.100.1', '192.0.2.10')
                }
            } -ModuleName NetworkDiagnostics

            $result = Invoke-ITTraceRoute -ComputerName $testComputerName

            $result.ComputerName | Should -Be 'example.com'
            $result.RemoteAddress | Should -Be '192.0.2.10'
            $result.Successful | Should -BeTrue
            $result.TraceRoute.Count | Should -Be 3
            $result.TraceRoute[0] | Should -Be '192.0.2.1'
            $result.TraceRoute[-1] | Should -Be '192.0.2.10'
            $result.Error | Should -BeNullOrEmpty

            Should -Invoke Test-NetConnection -ModuleName NetworkDiagnostics -Times 1 -Exactly -ParameterFilter {
                $ComputerName -eq 'example.com' -and $TraceRoute
            }
        }

        It "Handles traceroute execution errors" {
            $testComputerName = 'example.com'

            Mock Test-NetConnection {
                throw 'Destination unreachable'
            } -ModuleName NetworkDiagnostics

            $result = Invoke-ITTraceRoute -ComputerName $testComputerName

            $result.ComputerName | Should -Be 'example.com'
            $result.RemoteAddress | Should -BeNullOrEmpty
            $result.TraceRoute.Count | Should -Be 0
            $result.Successful | Should -BeFalse
            $result.Error | Should -Match 'Destination unreachable'

            Should -Invoke Test-NetConnection -ModuleName NetworkDiagnostics -Times 1 -Exactly
        }

        It "Rejects an empty computer name" {
            $emptyComputerName = ''
            { Invoke-ITTraceRoute -ComputerName $emptyComputerName } | Should -Throw
        }

        It "Rejects a null computer name" {
            { Invoke-ITTraceRoute -ComputerName $null } | Should -Throw
        }
    }

    Context "Wi-Fi information" {

        It "Returns connected Wi-Fi information" {
            Mock netsh {
                @(
                    '    Name                   : Wi-Fi'
                    '    Description            : Intel Wireless Adapter'
                    '    State                  : connected'
                    '    SSID                   : TestNetwork'
                    '    BSSID                  : 00:11:22:33:44:55'
                    '    Radio type             : 802.11ax'
                    '    Channel                : 36'
                    '    Signal                 : 85%'
                    '    Receive rate (Mbps)    : 1201'
                    '    Transmit rate (Mbps)   : 1201'
                )
            } -ModuleName NetworkDiagnostics

            $result = Get-ITWiFiInformation

            $result.Connected | Should -BeTrue
            $result.Name | Should -Be 'Wi-Fi'
            $result.Description | Should -Be 'Intel Wireless Adapter'
            $result.SSID | Should -Be 'TestNetwork'
            $result.BSSID | Should -Be '00:11:22:33:44:55'
            $result.RadioType | Should -Be '802.11ax'
            $result.Channel | Should -Be '36'
            $result.Signal | Should -Be '85%'
            $result.ReceiveRate | Should -Be '1201'
            $result.TransmitRate | Should -Be '1201'
            $result.Error | Should -BeNullOrEmpty
            Should -Invoke netsh -ModuleName NetworkDiagnostics -Times 1 -Exactly
        }

        It "Returns disconnected when no Wi-Fi interface is found" {
            Mock netsh {
                'There is no wireless interface on the system.'
            } -ModuleName NetworkDiagnostics

            $result = Get-ITWiFiInformation

            $result.Connected | Should -BeFalse
            $result.Name | Should -BeNullOrEmpty
            $result.SSID | Should -BeNullOrEmpty
            $result.Error | Should -Be 'No active Wi-Fi interface was found.'
        }

        It "Handles empty netsh output" {
            Mock netsh { $null } -ModuleName NetworkDiagnostics

            $result = Get-ITWiFiInformation

            $result.Connected | Should -BeFalse
            $result.Error | Should -Match 'Unable to retrieve Wi-Fi information'
        }

        It "Handles netsh execution errors" {
            Mock netsh {
                throw 'Wireless service unavailable'
            } -ModuleName NetworkDiagnostics

            $result = Get-ITWiFiInformation

            $result.Connected | Should -BeFalse
            $result.Error | Should -Match 'Wireless service unavailable'
        }
    }
}
