# Network Diagnostics

The Network Diagnostics module provides a collection of Windows network troubleshooting utilities.

It is designed to help IT technicians quickly inspect network configuration, test connectivity, troubleshoot DNS, check TCP ports, trace network routes, and inspect Wi-Fi connections without needing to remember multiple Windows networking commands.

## Features

The Network Diagnostics module currently provides:

- Physical network adapter information
- Optional virtual network adapter information
- Internet connectivity testing
- DNS resolution testing
- TCP port connectivity testing
- Trace route diagnostics
- Wi-Fi connection information

---

## Using the Toolkit

From the repository root, launch IT-Toolkit:

```powershell
.\src\Start-ITToolkit.ps1
```

From the main menu:

```text
1. System Information
2. Network Diagnostics
3. Windows Diagnostics

Q. Exit
```

Select:

```text
2. Network Diagnostics
```

The Network Diagnostics menu provides:

```text
1. Network adapters
2. Network adapters (include virtual)
3. Internet connectivity
4. DNS resolution
5. TCP port test
6. Trace route
7. Wi-Fi information

B. Back
```

---

## Network Adapters

The Network Adapters diagnostic displays information about active network interfaces.

Information includes:

- Interface name
- Adapter description
- Adapter type
- IPv4 address
- Default gateway
- DNS servers
- MAC address
- Link speed

### Physical Adapters

From the Network Diagnostics menu select:

```text
1. Network adapters
```

By default, IT-Toolkit attempts to hide common virtual network adapters so that the output focuses on physical network connections.

Example output:

```text
InterfaceAlias : Wi-Fi
Description    : Example Wireless Network Adapter
Type           : Physical
IPv4Address    : 192.168.1.100
Gateway        : 192.168.1.1
DNSServers     : 1.1.1.1, 8.8.8.8
MACAddress     : 00-00-00-00-00-00
LinkSpeed      : 866.7 Mbps
```

Values shown above are examples only.

### Virtual Adapters

Virtual network adapters can also be displayed.

From the Network Diagnostics menu select:

```text
2. Network adapters (include virtual)
```

This can be useful on computers running technologies such as:

- Hyper-V
- VMware
- VirtualBox
- Other virtual networking platforms

### PowerShell Usage

Run:

```powershell
Get-ITNetworkInformation
```

To include virtual adapters:

```powershell
Get-ITNetworkInformation -IncludeVirtual
```

---

## Internet Connectivity

The Internet Connectivity diagnostic performs a basic test to determine whether an external network destination can be reached.

From the Network Diagnostics menu select:

```text
3. Internet connectivity
```

### PowerShell Usage

Run:

```powershell
Test-ITInternetConnection
```

Example output:

```text
Connected : True
Target    : 1.1.1.1
Status    : Internet connectivity available
```

The function attempts multiple public connectivity targets.

### Important

The current connectivity test uses ICMP.

Some networks, firewalls, or internet services may block ICMP traffic.

A failed connectivity test therefore does not always prove that the computer has no internet access.

DNS resolution and TCP port testing can be used as additional troubleshooting checks.

---

## DNS Resolution

The DNS Resolution diagnostic tests whether a hostname can be resolved to an IP address using the computer's configured DNS infrastructure.

From the Network Diagnostics menu select:

```text
4. DNS resolution
```

The toolkit will ask for a hostname.

If no hostname is entered, the default test destination is:

```text
github.com
```

### PowerShell Usage

Run:

```powershell
Test-ITDNSResolution
```

Or specify a hostname:

```powershell
Test-ITDNSResolution -Name "example.com"
```

Example output:

```text
Name       : example.com
Successful : True
Addresses  : 93.184.216.34
Error      :
```

DNS resolution problems may indicate issues involving:

- DNS server configuration
- Local network connectivity
- VPN configuration
- Network adapter configuration
- Firewall rules
- DNS service availability

A successful DNS lookup confirms name resolution but does not necessarily confirm that the destination's application or service is reachable.

---

## TCP Port Test

The TCP Port Test checks whether a specified TCP port can be reached on a hostname or IP address.

From the Network Diagnostics menu select:

```text
5. TCP port test
```

The toolkit will request:

- Hostname or IP address
- TCP port

Valid TCP ports are:

```text
1-65535
```

### PowerShell Usage

For example:

```powershell
Test-ITTCPPort -ComputerName "github.com" -Port 443
```

Example output:

```text
ComputerName  : github.com
Port          : 443
Successful    : True
RemoteAddress : 192.0.2.10
Error         :
```

The address shown above is an example only.

TCP port testing can be useful when troubleshooting services such as:

- HTTPS
- HTTP
- Remote administration services
- Application servers
- Database services
- Other TCP-based applications

### Important

A failed TCP connection does not automatically mean the remote server is unavailable.

Possible causes include:

- The service is not listening
- A firewall is blocking the connection
- Network routing problems
- DNS resolution problems
- The destination is unavailable
- The port number is incorrect

Results should therefore be investigated in context.

---

## Trace Route

The Trace Route diagnostic displays the network path towards a specified destination.

From the Network Diagnostics menu select:

```text
6. Trace route
```

Enter a hostname or IP address when prompted.

### PowerShell Usage

Run:

```powershell
Invoke-ITTraceRoute -ComputerName "github.com"
```

The result includes:

- Destination computer name
- Remote IP address
- Network route
- Success status
- Error information when applicable

Example route:

```text
Route:

  1. 192.168.1.1
  2. 192.0.2.1
  3. 198.51.100.1
```

The addresses shown above are examples only.

### Important

Some network devices do not respond to trace route probes.

Missing hops or timeouts do not automatically indicate a network fault.

Trace route results should be considered alongside other connectivity tests.

---

## Wi-Fi Information

The Wi-Fi diagnostic displays information about the current wireless network connection.

From the Network Diagnostics menu select:

```text
7. Wi-Fi information
```

Information may include:

- Wireless adapter
- Adapter description
- SSID
- Access point BSSID
- Radio type
- Wireless channel
- Signal strength
- Receive rate
- Transmit rate

Example:

```text
Name         : Wi-Fi
Description  : Example Wireless Network Adapter
SSID         : ExampleNetwork
BSSID        : 00:00:00:00:00:00
RadioType    : 802.11ac
Channel      : 36
Signal       : 92%
ReceiveRate  : 866.7
TransmitRate : 866.7
```

Values shown above are examples only.

### PowerShell Usage

Run:

```powershell
Get-ITWiFiInformation
```

### Wi-Fi Passwords

IT-Toolkit does **not** retrieve or display saved Wi-Fi passwords.

The Wi-Fi diagnostic is intended to provide troubleshooting information about the current wireless connection rather than expose stored wireless credentials.

---

## Available Functions

The Network Diagnostics module currently exports the following functions:

| Function | Description |
| --- | --- |
| `Get-ITNetworkInformation` | Displays active physical or virtual network adapter information |
| `Test-ITInternetConnection` | Performs a basic external connectivity test |
| `Test-ITDNSResolution` | Tests DNS resolution for a hostname |
| `Test-ITTCPPort` | Tests connectivity to a TCP port |
| `Invoke-ITTraceRoute` | Traces the network route towards a destination |
| `Get-ITWiFiInformation` | Displays information about the current Wi-Fi connection |

---

## Requirements

Network Diagnostics requires:

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Windows networking cmdlets
- Access to the relevant Windows networking information

Some diagnostics require network connectivity to the destination being tested.

---

## Testing

The Network Diagnostics module has an associated Pester test suite:

```text
tests/NetworkDiagnostics.Tests.ps1
```

Run the Network Diagnostics tests with:

```powershell
Invoke-Pester .\tests\NetworkDiagnostics.Tests.ps1 -Output Detailed
```

Run the complete IT-Toolkit test suite with:

```powershell
Invoke-Pester .\tests -Output Detailed
```

Automated tests are also executed through GitHub Actions when changes are submitted to the repository.

---

## Privacy

Network diagnostic information is collected locally on the computer running IT-Toolkit.

IT-Toolkit does not upload collected diagnostic information to the project maintainer.

Some diagnostics intentionally communicate with external systems.

For example:

- Internet connectivity tests contact public connectivity targets
- DNS tests resolve a hostname
- TCP port tests connect to a destination specified by the user
- Trace route tests communicate with a destination specified by the user

No diagnostic results are automatically uploaded to the project maintainer.

---

## Security

IT-Toolkit should only be used on systems and networks you own or are authorised to administer.

Before publishing Network Diagnostics output to GitHub or another public location, review it for potentially sensitive information such as:

- IP addresses
- MAC addresses
- Internal hostnames
- DNS servers
- Default gateways
- Wi-Fi SSIDs
- Wi-Fi access point BSSIDs
- Network topology
- Internal infrastructure information
- Personal or confidential information

Do not commit sensitive diagnostic output to the IT-Toolkit repository.