# Network Diagnostics

IT-Toolkit includes a collection of Windows network troubleshooting utilities.

## Features

### Network Adapters

Displays active network interfaces including:

- Interface name
- Adapter description
- IPv4 address
- Default gateway
- DNS servers
- MAC address
- Link speed

Virtual adapters are hidden by default and can optionally be displayed.

### Internet Connectivity

Tests connectivity using multiple external targets.

### DNS Resolution

Tests whether a hostname can be successfully resolved using the configured DNS infrastructure.

### TCP Port Test

Tests connectivity to a specified hostname or IP address on a TCP port.

Valid TCP ports are:

`1-65535`

### Trace Route

Displays the network route between the local computer and a specified destination.

### Wi-Fi Information

Displays information about the current wireless connection including:

- SSID
- Access point BSSID
- Radio type
- Channel
- Signal strength
- Receive rate
- Transmit rate

The toolkit does not retrieve or display saved Wi-Fi passwords.

## Privacy

All diagnostics run locally.

IT-Toolkit does not transmit collected diagnostic information to the project maintainer.

Some diagnostic tests contact user-specified destinations or public connectivity test endpoints.