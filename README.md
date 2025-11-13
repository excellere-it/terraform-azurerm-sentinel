# Terraform Azure Sentinel Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

A production-grade Terraform module for provisioning and configuring **Microsoft Sentinel** (formerly Azure Sentinel) in Azure. This module provides comprehensive SIEM (Security Information and Event Management) and SOAR (Security Orchestration, Automation, and Response) capabilities with support for data connectors, alert rules, watchlists, and complete Log Analytics workspace integration.

## Features

- **Flexible Workspace Management**
  - Create new Log Analytics workspace or use existing
  - Configurable retention periods (30-730 days)
  - Daily ingestion quota controls for cost management
  - Multiple SKU options

- **Data Connectors**
  - Azure Active Directory
  - Microsoft Defender for Cloud (formerly Azure Security Center)
  - Office 365 (Exchange, SharePoint, Teams)
  - Threat Intelligence

- **Alert Rules**
  - Scheduled alert rules with custom KQL queries
  - Configurable severity levels (High, Medium, Low, Informational)
  - Flexible query frequency and periods
  - Multiple trigger operators
  - MITRE ATT&CK tactics and techniques support
  - Suppression and event grouping options

- **Watchlists**
  - Reference data management
  - Configurable search keys and durations
  - Support for VIP users, known IPs, and custom lists

- **Enterprise-Grade Standards**
  - Consistent naming via `terraform-terraform-namer` integration
  - Standardized tagging (governance, compliance, cost tracking)
  - Comprehensive input validation
  - Complete test coverage with native Terraform tests
  - CI/CD ready with GitHub Actions

## Quick Start

### Basic Usage with New Workspace

```hcl
module "sentinel" {
  source = "path/to/terraform-azurerm-sentinel"

  # Naming variables
  contact     = "security@example.com"
  environment = "prd"
  location    = "centralus"
  repository  = "infoex-iac"
  workload    = "security"

  # Resource configuration
  resource_group_name            = "rg-security-cu-prd-kmi-0"
  create_log_analytics_workspace = true
  log_analytics_retention_in_days = 180

  # Enable data connectors
  enable_azure_active_directory_connector = true
  enable_azure_security_center_connector  = true
}
```

### Using Existing Log Analytics Workspace

```hcl
module "sentinel" {
  source = "path/to/terraform-azurerm-sentinel"

  # Naming variables
  contact     = "security@example.com"
  environment = "prd"
  location    = "centralus"
  repository  = "infoex-iac"
  workload    = "security"

  # Use existing workspace
  resource_group_name        = "rg-security-cu-prd-kmi-0"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.existing.id
}
```

## Requirements

- **Terraform**: >= 1.13.4
- **Azure Provider**: ~> 4.0
- **Azure Permissions**: Microsoft Sentinel Contributor role
- **Dependency**: `terraform-terraform-namer` module (for naming and tagging)

## Documentation

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development workflow and guidelines
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes
- **[tests/README.md](tests/README.md)** - Test documentation and strategy
- **[.github/workflows/README.md](.github/workflows/README.md)** - CI/CD pipeline documentation

<!-- BEGIN_TF_DOCS -->


## Example

```hcl
module "sentinel" {
  source = "../.."

  # Naming variables
  contact     = "security@example.com"
  environment = "dev"
  location    = "centralus"
  repository  = "infoex-iac"
  workload    = "security"

  # Resource configuration
  resource_group_name             = "rg-security-cu-dev-kmi-0"
  create_log_analytics_workspace  = true
  log_analytics_retention_in_days = 90
  log_analytics_daily_quota_gb    = 5

  # Data connectors
  enable_azure_active_directory_connector = true
  enable_azure_security_center_connector  = true
  enable_office365_connector              = true
  office365_exchange_enabled              = true
  office365_sharepoint_enabled            = true
  office365_teams_enabled                 = true
  enable_threat_intelligence_connector    = true

  # Alert rules
  alert_rules = {
    failed_logins = {
      display_name      = "Multiple Failed Login Attempts"
      severity          = "High"
      enabled           = true
      query             = "SigninLogs | where ResultType != 0 | summarize count() by UserPrincipalName, IPAddress | where count_ > 5"
      query_frequency   = "PT1H"
      query_period      = "PT1H"
      trigger_operator  = "GreaterThan"
      trigger_threshold = 0
      tactics           = ["InitialAccess", "CredentialAccess"]
    }
    security_alerts = {
      display_name      = "High Severity Security Alerts"
      severity          = "High"
      enabled           = true
      query             = "SecurityAlert | where AlertSeverity == 'High'"
      query_frequency   = "PT5M"
      query_period      = "PT5M"
      trigger_operator  = "GreaterThan"
      trigger_threshold = 0
      tactics           = ["Impact"]
    }
  }

  # Watchlists
  watchlists = {
    vip_users = {
      display_name     = "VIP Users"
      item_search_key  = "UserPrincipalName"
      description      = "List of VIP users requiring special monitoring"
      default_duration = "P90D"
    }
    known_ips = {
      display_name     = "Known IP Addresses"
      item_search_key  = "IPAddress"
      description      = "List of known safe IP addresses"
      default_duration = "P30D"
    }
  }
}
```

## Required Inputs

The following input variables are required:

### <a name="input_contact"></a> [contact](#input\_contact)

Description: Contact email for resource ownership and management

Type: `string`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: Environment name (e.g., dev, stg, prd)

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where resources will be deployed

Type: `string`

### <a name="input_repository"></a> [repository](#input\_repository)

Description: Repository name for tracking infrastructure as code source

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Sentinel resources

Type: `string`

### <a name="input_workload"></a> [workload](#input\_workload)

Description: Workload or application name identifier

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags)

Description: Additional tags to merge with the standard naming module tags

Type: `map(string)`

Default: `{}`

### <a name="input_alert_rules"></a> [alert\_rules](#input\_alert\_rules)

Description: Map of scheduled alert rules to create. Key is the rule name.

Type:

```hcl
map(object({
    display_name           = string
    severity               = string
    enabled                = optional(bool, true)
    query                  = string
    query_frequency        = optional(string, "PT5H")
    query_period           = optional(string, "PT5H")
    trigger_operator       = optional(string, "GreaterThan")
    trigger_threshold      = optional(number, 0)
    suppression_enabled    = optional(bool, false)
    suppression_duration   = optional(string, "PT5H")
    tactics                = optional(list(string), [])
    techniques             = optional(list(string), [])
    event_grouping         = optional(string, "SingleAlert")
    alert_details_override = optional(map(string), {})
  }))
```

Default: `{}`

### <a name="input_create_log_analytics_workspace"></a> [create\_log\_analytics\_workspace](#input\_create\_log\_analytics\_workspace)

Description: Whether to create a new Log Analytics workspace. If false, log\_analytics\_workspace\_id must be provided.

Type: `bool`

Default: `false`

### <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb)

Description: The daily ingestion quota in GB for Sentinel. -1 means unlimited.

Type: `number`

Default: `-1`

### <a name="input_enable_azure_active_directory_connector"></a> [enable\_azure\_active\_directory\_connector](#input\_enable\_azure\_active\_directory\_connector)

Description: Enable Azure Active Directory data connector

Type: `bool`

Default: `false`

### <a name="input_enable_azure_security_center_connector"></a> [enable\_azure\_security\_center\_connector](#input\_enable\_azure\_security\_center\_connector)

Description: Enable Microsoft Defender for Cloud (formerly Security Center) data connector

Type: `bool`

Default: `false`

### <a name="input_enable_office365_connector"></a> [enable\_office365\_connector](#input\_enable\_office365\_connector)

Description: Enable Office 365 data connector

Type: `bool`

Default: `false`

### <a name="input_enable_threat_intelligence_connector"></a> [enable\_threat\_intelligence\_connector](#input\_enable\_threat\_intelligence\_connector)

Description: Enable Threat Intelligence data connector

Type: `bool`

Default: `false`

### <a name="input_log_analytics_daily_quota_gb"></a> [log\_analytics\_daily\_quota\_gb](#input\_log\_analytics\_daily\_quota\_gb)

Description: The daily ingestion quota in GB. -1 means unlimited.

Type: `number`

Default: `-1`

### <a name="input_log_analytics_retention_in_days"></a> [log\_analytics\_retention\_in\_days](#input\_log\_analytics\_retention\_in\_days)

Description: The workspace data retention in days. Valid values: 30-730 days (Free tier only supports 7 days)

Type: `number`

Default: `90`

### <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku)

Description: SKU for the Log Analytics workspace. Valid values: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018

Type: `string`

Default: `"PerGB2018"`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: The ID of the Log Analytics workspace to onboard to Microsoft Sentinel. If not provided, a new workspace will be created.

Type: `string`

Default: `null`

### <a name="input_office365_exchange_enabled"></a> [office365\_exchange\_enabled](#input\_office365\_exchange\_enabled)

Description: Enable Exchange logs for Office 365 connector

Type: `bool`

Default: `true`

### <a name="input_office365_sharepoint_enabled"></a> [office365\_sharepoint\_enabled](#input\_office365\_sharepoint\_enabled)

Description: Enable SharePoint logs for Office 365 connector

Type: `bool`

Default: `true`

### <a name="input_office365_teams_enabled"></a> [office365\_teams\_enabled](#input\_office365\_teams\_enabled)

Description: Enable Teams logs for Office 365 connector

Type: `bool`

Default: `true`

### <a name="input_watchlists"></a> [watchlists](#input\_watchlists)

Description: Map of watchlists to create. Key is the watchlist name.

Type:

```hcl
map(object({
    display_name     = string
    item_search_key  = string
    description      = optional(string, "")
    default_duration = optional(string, "P30D")
    items            = optional(list(map(string)), [])
  }))
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_alert_rule_ids"></a> [alert\_rule\_ids](#output\_alert\_rule\_ids)

Description: Map of alert rule names to their resource IDs

### <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names)

Description: Map of alert rule keys to their resource names

### <a name="output_azure_ad_connector_id"></a> [azure\_ad\_connector\_id](#output\_azure\_ad\_connector\_id)

Description: The ID of the Azure Active Directory data connector (if enabled)

### <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id)

Description: The ID of the Log Analytics workspace used by Sentinel

### <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name)

Description: The name of the Log Analytics workspace (if created by this module)

### <a name="output_log_analytics_workspace_primary_shared_key"></a> [log\_analytics\_workspace\_primary\_shared\_key](#output\_log\_analytics\_workspace\_primary\_shared\_key)

Description: The primary shared key of the Log Analytics workspace (if created by this module)

### <a name="output_log_analytics_workspace_workspace_id"></a> [log\_analytics\_workspace\_workspace\_id](#output\_log\_analytics\_workspace\_workspace\_id)

Description: The workspace ID (GUID) of the Log Analytics workspace (if created by this module)

### <a name="output_office365_connector_id"></a> [office365\_connector\_id](#output\_office365\_connector\_id)

Description: The ID of the Office 365 data connector (if enabled)

### <a name="output_resource_suffix"></a> [resource\_suffix](#output\_resource\_suffix)

Description: The standardized resource name suffix from the naming module

### <a name="output_security_center_connector_id"></a> [security\_center\_connector\_id](#output\_security\_center\_connector\_id)

Description: The ID of the Microsoft Defender for Cloud data connector (if enabled)

### <a name="output_sentinel_resource_group_name"></a> [sentinel\_resource\_group\_name](#output\_sentinel\_resource\_group\_name)

Description: The name of the resource group containing Sentinel resources

### <a name="output_sentinel_workspace_id"></a> [sentinel\_workspace\_id](#output\_sentinel\_workspace\_id)

Description: The ID of the Log Analytics workspace onboarded to Sentinel

### <a name="output_tags"></a> [tags](#output\_tags)

Description: The tags applied to all resources

### <a name="output_threat_intelligence_connector_id"></a> [threat\_intelligence\_connector\_id](#output\_threat\_intelligence\_connector\_id)

Description: The ID of the Threat Intelligence data connector (if enabled)

### <a name="output_watchlist_ids"></a> [watchlist\_ids](#output\_watchlist\_ids)

Description: Map of watchlist names to their resource IDs

### <a name="output_watchlist_names"></a> [watchlist\_names](#output\_watchlist\_names)

Description: Map of watchlist keys to their resource names

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_sentinel_alert_rule_scheduled.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_alert_rule_scheduled) (resource)
- [azurerm_sentinel_data_connector_azure_active_directory.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_azure_active_directory) (resource)
- [azurerm_sentinel_data_connector_azure_security_center.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_azure_security_center) (resource)
- [azurerm_sentinel_data_connector_office_365.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_office_365) (resource)
- [azurerm_sentinel_data_connector_threat_intelligence.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_data_connector_threat_intelligence) (resource)
- [azurerm_sentinel_log_analytics_workspace_onboarding.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_log_analytics_workspace_onboarding) (resource)
- [azurerm_sentinel_watchlist.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_watchlist) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.4)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (4.52.0)

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: app.terraform.io/infoex/namer/terraform

Version: ~> 0.1
<!-- END_TF_DOCS -->