# IT-Toolkit

A PowerShell toolkit for Windows system diagnostics, troubleshooting, and IT support.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Tests](https://img.shields.io/github/actions/workflow/status/Mysticeel/IT-Toolkit/pester-tests.yml?label=tests)
![License](https://img.shields.io/github/license/Mysticeel/IT-Toolkit)

## Overview

IT-Toolkit is a growing collection of Windows support and diagnostic utilities designed for IT technicians, support engineers, and homelab users.

The project focuses on quick, practical troubleshooting while keeping the code readable and easy to extend.

## Features

### System Information

- Computer manufacturer and model
- Serial number
- Operating system details
- System uptime
- Processor information
- Memory usage
- System drive capacity
- IPv4 configuration
- Default gateway
- DNS servers
- Current user
- PowerShell version
- Administrator status

### Network Diagnostics

- Active network adapter information
- Physical and virtual adapter detection
- Internet connectivity testing
- DNS resolution testing
- TCP port testing
- Trace route diagnostics
- Wi-Fi information
- Signal strength
- Channel information
- Link rates

## Quick Start

Clone the repository:

```powershell
git clone git@github.com:Mysticeel/IT-Toolkit.git
cd IT-Toolkit