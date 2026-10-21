# Contributing to IT-Toolkit

Thank you for your interest in IT-Toolkit!

IT-Toolkit is an open-source PowerShell diagnostics and troubleshooting toolkit developed and maintained by [Mysticeel](https://github.com/Mysticeel).

The project aims to provide practical, reliable and easy-to-use diagnostic tools for Windows IT support professionals, system administrators and technical enthusiasts.

## 1. Project Ownership and Contributions

**IT-Toolkit is an independently developed and owner-maintained project.**

The official repository is maintained exclusively by Mysticeel.

- Only the repository owner is authorised to directly commit changes to the official project.
- External contributors are not granted write or administrative access by default.
- Bug reports, feature suggestions and documentation feedback are welcome.
- Pull requests may be submitted for consideration but are not guaranteed to be accepted.
- All changes to the official project require approval from the repository owner.
- The repository owner retains final authority over development decisions, releases and project direction.

Contributing does not grant ownership, administrative privileges or commit access to the official repository.

As the project is distributed under the MIT License, users may fork, modify and redistribute their own copies in accordance with the license.

## 2. Ways to Contribute

Contributions are welcome in the following forms:

### Reporting Bugs

If you encounter an issue, open a GitHub Issue containing:

- A clear description of the problem.
- Steps to reproduce the issue.
- Expected and actual behaviour.
- Windows version.
- PowerShell version.
- Relevant error messages or sanitized logs.

Please check existing issues before creating a new report.

### Suggesting Features

Feature requests should explain:

- The problem the proposed feature would solve.
- How it would benefit IT support professionals.
- How it would integrate with existing functionality.
- Any relevant security or compatibility considerations.

Feature requests will be reviewed at the project owner's discretion.

### Documentation Improvements

Suggestions to improve installation instructions, command examples, troubleshooting guides and module documentation are welcome.

### Pull Requests

Pull requests may be submitted for review. However, the repository owner is under no obligation to merge proposed changes.

## 3. Development Environment

For anyone wishing to propose code changes, the recommended development environment includes:

- Windows 10 or Windows 11.
- Windows PowerShell 5.1 or later.
- Git.
- Visual Studio Code with the PowerShell extension.
- Pester 6.2.0.
- PSScriptAnalyzer.

### Clone the Repository

```powershell
git clone https://github.com/Mysticeel/IT-ToolKit.git
cd IT-ToolKit
```

External contributors should fork the repository into their own GitHub account before creating changes.

### Install Development Dependencies

```powershell
Install-Module Pester -RequiredVersion 6.2.0 -Scope CurrentUser -Force -SkipPublisherCheck

Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
```

## 4. PowerShell Coding Standards

Any proposed code should follow established PowerShell development practices.

### Naming Conventions

- Use approved PowerShell Verb-Noun naming conventions.
- Use PascalCase for functions and parameters.
- Use descriptive variable names.
- Use four spaces for indentation.
- Keep functions focused and reusable.
- Avoid unnecessary complexity and duplication.

Example:

```powershell
function Get-SystemUptime {
    [CmdletBinding()]
    param()

    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem

    $Uptime = (Get-Date) - $OperatingSystem.LastBootUpTime

    [PSCustomObject]@{
        UptimeDays = [math]::Round($Uptime.TotalDays, 2)
    }
}
```

### Error Handling

- Handle expected errors gracefully.
- Use `try` and `catch` where appropriate.
- Provide meaningful error messages.
- Avoid silently suppressing failures.
- Ensure individual diagnostic failures do not unnecessarily terminate the entire toolkit.

### Output Standards

- Prefer structured PowerShell objects.
- Use `Write-Verbose` for additional diagnostic information.
- Avoid unnecessary `Write-Host` output in reusable functions.
- Maintain consistent output formats across modules.

## 5. Security and Privacy

Security and privacy are important considerations for IT-Toolkit.

All proposed changes must follow these principles:

- Never hardcode passwords, API keys or credentials.
- Never include confidential infrastructure information.
- Avoid exposing sensitive system or user information.
- Keep diagnostic operations read-only by default.
- Avoid unnecessary administrative privileges.
- Clearly document any operation that modifies system configuration.
- Do not introduce destructive functionality without explicit safeguards.

Security vulnerabilities should be reported privately using the instructions in `SECURITY.md`, rather than through public GitHub Issues.

## 6. Testing Requirements

Proposed code changes should be tested before submitting a pull request.

### Pester

Run the existing test suite from the repository root:

```powershell
Import-Module Pester -RequiredVersion 6.2.0 -Force

Invoke-Pester -Path ./tests -CI
```

New functionality should include appropriate tests covering successful execution, invalid inputs and expected failures.

### PSScriptAnalyzer

Run static analysis using the repository's existing configuration:

```powershell
Import-Module PSScriptAnalyzer

Invoke-ScriptAnalyzer `
    -Path ./src `
    -Recurse `
    -Settings ./PSScriptAnalyzerSettings.psd1
```

Proposed changes should not introduce new static analysis warnings or errors.

## 7. Documentation Requirements

Where applicable, contributions should include:

- Updated README instructions.
- Documentation for new or modified functions.
- Parameter descriptions.
- Example commands and expected output.
- Dependency and permission requirements.
- Relevant changes to `CHANGELOG.MD`.

Documentation should remain clear and accessible to IT support professionals.

## 8. Pull Request Process

External contributors must work from their own fork of the repository.

### Create a Feature Branch

```powershell
git checkout -b feature/example-improvement
```

Suggested branch naming conventions:

| Prefix | Purpose |
|---|---|
| `feature/` | New functionality |
| `fix/` | Bug fixes |
| `docs/` | Documentation |
| `test/` | Test improvements |
| `refactor/` | Code improvements |

### Commit Changes

Use clear commit messages, such as:

```text
feat: add additional network diagnostics
fix: improve service error handling
docs: update installation instructions
test: add diagnostic failure scenarios
refactor: simplify system information collection
```

### Submit a Pull Request

Before submitting:

- [ ] Code follows the project's coding standards.
- [ ] Relevant Pester tests pass.
- [ ] PSScriptAnalyzer checks pass.
- [ ] New functionality includes appropriate tests.
- [ ] Documentation is updated where required.
- [ ] No credentials or sensitive information are included.
- [ ] The pull request explains the purpose of the changes.

Pull requests should target the `main` branch of the official repository.

**Only the repository owner decides whether a pull request is accepted and merged.**

## 9. Code Review and Approval

All proposed changes are subject to review by the project owner.

Reviews may consider:

- Functionality and correctness.
- Security and privacy.
- Code quality and maintainability.
- Compatibility.
- Test coverage.
- Documentation.
- Alignment with the project's objectives.

The repository owner reserves the right to request changes, reject contributions or close pull requests.

Submitting a pull request does not guarantee inclusion in a future release.

## 10. Project Governance

IT-Toolkit follows a sole-maintainer governance model.

Mysticeel is responsible for:

- Repository administration and permissions.
- Development priorities.
- Code reviews and merge decisions.
- Release management and versioning.
- Security decisions.
- Project direction and maintenance.

There is no formal external maintainer programme.

## 11. Community Conduct

All participants are expected to communicate respectfully and constructively.

Please refer to `CODE_OF_CONDUCT.md` for the project's community guidelines.

## 12. License

IT-Toolkit is distributed under the MIT License.

By submitting a contribution, you agree that your contribution may be distributed under the project's existing MIT License if accepted.

The MIT License permits others to use, modify and redistribute their own copies of the project, but does not grant them permission to modify the official repository.

---

Thank you for your interest in IT-Toolkit and for helping make Windows diagnostics more accessible and reliable.
