# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-10-01

### Added

- PowerShell module manifest for IT-Toolkit.
- Support for importing the toolkit with `IT-Toolkit.psd1`.
- Explicit public function exports through the module manifest.
- Module manifest validation and export tests.
- JSON diagnostic report export with `Export-ITDiagnosticReportJson`.
- Configurable JSON serialization depth.
- Pester coverage for JSON diagnostic reports.
- JSON report generation from the interactive toolkit.
- Option to generate multiple diagnostic report formats from a single data collection.
- Diagnostic report metadata including toolkit version, schema version, PowerShell version, and collection duration.
- Event correlation with `Get-ITEventCorrelation`.
- Event correlation output in text, HTML, and JSON diagnostic reports.
- Service dependency analysis with `Get-ITServiceDependency`.
- Interactive service dependency analysis from the Windows Diagnostics menu.
- JSON report filtering with the `-Include` parameter.
- Interactive filtered JSON report generation.
- CSV diagnostic summary export with `Export-ITDiagnosticReportCsv`.
- Interactive CSV report generation.
- CSV output containing key diagnostic and health summary values.
- CSV generation as part of the all-formats reporting option.
- Pester coverage for event correlation, service dependency analysis, report metadata, JSON filtering, CSV reporting, and module exports.

### Changed

- Diagnostic reporting now supports HTML, text, JSON, filtered JSON, and CSV output.
- Interactive diagnostic report generation now collects report data once before exporting the selected formats.
- Diagnostic reports now include report metadata for versioning and troubleshooting context.
- Windows diagnostics now includes event correlation and service dependency analysis.
- JSON exports can now be limited to selected report sections while retaining `GeneratedAt`.
- The diagnostic report menu now provides dedicated CSV generation and an updated all-formats option.
- `Start-ITToolkit.ps1` formatting has been cleaned up for improved readability and maintainability.
- `Start-ITToolkit.ps1` passes the current PSScriptAnalyzer checks.
- Public toolkit commands are explicitly defined through the PowerShell module manifest.
- IT-Toolkit now exposes 28 public functions.
- Diagnostic report documentation expanded to cover report structure, JSON usage, privacy considerations, and programmatic usage.
- Module version updated to `1.1.0`.

### Security

- Generated diagnostic reports remain excluded from source control through the `reports/` directory.
- CSV reports are treated as diagnostic output and may contain local system information.
- Report export functionality remains read-only and does not modify Windows configuration.