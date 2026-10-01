# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- PowerShell module manifest for IT-Toolkit.
- Support for importing the toolkit with `IT-Toolkit.psd1`.
- Explicit public function exports through the module manifest.
- Module manifest validation and export tests.
- JSON diagnostic report export with `Export-ITDiagnosticReportJson`.
- Configurable JSON serialization depth.
- Pester coverage for JSON diagnostic reports.
- JSON report generation from the interactive toolkit.
- Option to generate HTML, text, and JSON reports together.
- Diagnostic report metadata including toolkit version, schema version, PowerShell version, and collection duration.
- Event correlation with `Get-ITEventCorrelation`.
- Event correlation output in text, HTML, and JSON diagnostic reports.
- Service dependency analysis with `Get-ITServiceDependency`.
- Interactive service dependency analysis from the Windows Diagnostics menu.
- JSON report filtering with the `-Include` parameter.
- Interactive filtered JSON report generation.
- Pester coverage for event correlation, service dependency analysis, report metadata, and JSON filtering.

### Changed

- Diagnostic reporting now supports HTML, text, and JSON output.
- Interactive diagnostic report generation now collects report data once before exporting the selected formats.
- Diagnostic reports now include report metadata for versioning and troubleshooting context.
- Windows diagnostics now includes event correlation and service dependency analysis.
- JSON exports can now be limited to selected report sections while retaining `GeneratedAt`.
- `Start-ITToolkit.ps1` formatting has been cleaned up for improved readability and maintainability.
- `Start-ITToolkit.ps1` passes the current PSScriptAnalyzer checks.
- Public toolkit commands are explicitly defined through the PowerShell module manifest.
- Diagnostic report documentation expanded to cover report structure, JSON usage, privacy considerations, and programmatic usage.
- Module version updated to `1.1.0`.