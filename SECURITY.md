# Security Policy

## Overview

Security and privacy are important considerations for IT-Toolkit.

IT-Toolkit is an open-source PowerShell diagnostics and troubleshooting project independently developed and maintained by [Mysticeel](https://github.com/Mysticeel).

The project aims to provide reliable diagnostic functionality while minimising security risks and unnecessary exposure of sensitive system information.

## Supported Versions

Security updates are generally focused on the latest release of IT-Toolkit.

| Version | Security Support |
|---------|------------------|
| Latest release | Supported |
| Older releases | Not actively supported |
| Development builds | Not guaranteed |

Users are encouraged to use the latest available release.

As IT-Toolkit is maintained independently, security fixes are provided on a best-effort basis.

## Reporting a Vulnerability

If you discover a potential security vulnerability, please report it privately.

**Do not disclose security vulnerabilities through public GitHub Issues, Discussions or Pull Requests.**

### Preferred Reporting Method

Use GitHub's private vulnerability reporting feature:

[Report a Security Vulnerability](https://github.com/Mysticeel/IT-ToolKit/security/advisories/new)

This allows security concerns to be submitted privately to the repository maintainer.

If private vulnerability reporting is unavailable, contact the project maintainer through an alternative private communication channel agreed with the maintainer.

### Information to Include

Where possible, include:

- A description of the vulnerability.
- The affected IT-Toolkit version.
- The affected module or function.
- Steps to reproduce the issue.
- The potential security impact.
- Any suggested mitigations.

Do not include real credentials, personal information or confidential infrastructure details.

## Vulnerability Handling

Security reports are reviewed by Mysticeel, the sole project maintainer.

The general process is:

1. Review the submitted vulnerability report.
2. Assess the potential impact and affected functionality.
3. Attempt to reproduce and validate the issue.
4. Determine whether a security fix or mitigation is required.
5. Develop and test an appropriate fix where feasible.
6. Publish an updated release or security advisory when appropriate.

Reports are handled on a best-effort basis. No guaranteed response or resolution timeframe is provided.

The maintainer retains responsibility for all security-related decisions.

## Responsible Disclosure

Security researchers and users are encouraged to practise responsible disclosure.

Please:

- Report vulnerabilities privately.
- Allow reasonable time for investigation and remediation.
- Avoid accessing or modifying systems without authorisation.
- Avoid collecting or exposing sensitive information.
- Coordinate public disclosure with the maintainer where possible.

## Sensitive Information

IT-Toolkit may collect diagnostic information about Windows systems and network environments.

When reporting issues or sharing diagnostic output, do not disclose:

- Passwords, credentials or authentication tokens.
- API keys or secrets.
- Personal or confidential information.
- Internal hostnames, IP addresses or network configurations.
- Confidential business information.
- Sensitive event logs or diagnostic reports.

Always review and sanitise diagnostic output before publishing it.

## Security Principles

IT-Toolkit development aims to follow these principles:

- **Least Privilege:** Avoid unnecessary administrative permissions.
- **Read-Only Diagnostics:** Prefer non-destructive diagnostic operations.
- **Secure Error Handling:** Avoid exposing sensitive information through errors.
- **Input Validation:** Validate user-supplied parameters where appropriate.
- **Dependency Management:** Review external dependencies and their security implications.
- **Transparency:** Clearly document functionality that changes system configuration.

These are project development objectives rather than guarantees that all functionality is free from vulnerabilities.

## Project Maintenance

IT-Toolkit is independently maintained by Mysticeel.

Security reports, fixes, advisories and release decisions remain under the control of the project maintainer.

The project is provided under the terms of its MIT License, without warranties.

---

Thank you for helping improve the security and reliability of IT-Toolkit.
