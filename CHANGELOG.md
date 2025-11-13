# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.4] - 2025-01-13

### Fixed
- **CRITICAL**: Restructured repository to move module files to root
- Module files (main.tf, variables.tf, etc.) are now at repository root instead of nested in subdirectory
- Resolves Terraform Cloud registry packaging issue
- Terraform can now properly discover module variables when downloading from registry

## [0.0.3] - 2025-01-13

### Fixed
- Corrected terraform-namer module version reference to 0.0.1 (was incorrectly using ~> 0.1)
- Resolves module compatibility issues with Terraform Cloud registry

## [0.0.2] - 2025-01-13

### Changed
- Module dependencies now use Terraform Registry references instead of relative paths
  - `terraform-terraform-namer` → `app.terraform.io/infoex/namer/terraform` version `0.0.1`
  - Ensures proper version pinning and module registry best practices

### Added
- Initial module implementation for Microsoft Sentinel
- Support for Log Analytics workspace onboarding to Sentinel
- Optional Log Analytics workspace creation
- Azure Active Directory data connector
- Microsoft Defender for Cloud (Azure Security Center) data connector
- Office 365 data connector with Exchange, SharePoint, and Teams support
- Threat Intelligence data connector
- Scheduled alert rules with customizable KQL queries
- Watchlist management for reference data
- Integration with terraform-namer for standardized naming and tagging
- Comprehensive variable validation
- Daily ingestion quota controls for cost management
- Support for multiple alert rule configurations
- Full test suite using Terraform native tests
- Complete documentation and examples
- CI/CD pipeline with GitHub Actions
- Makefile with 20+ automation targets

## [0.0.1] - 2025-01-13

### Added
- Initial release placeholder

[Unreleased]: https://github.com/excellere-it/terraform-azurerm-sentinel/compare/0.0.4...HEAD
[0.0.4]: https://github.com/excellere-it/terraform-azurerm-sentinel/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/excellere-it/terraform-azurerm-sentinel/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/excellere-it/terraform-azurerm-sentinel/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/excellere-it/terraform-azurerm-sentinel/releases/tag/0.0.1
