# =============================================================================
# Module: terraform-azurerm-sentinel
# =============================================================================
#
# Purpose:
#   This module provisions and configures Microsoft Sentinel (formerly Azure Sentinel)
#   for security information and event management (SIEM) and security orchestration,
#   automation, and response (SOAR) capabilities in Azure.
#
# Features:
#   - Onboard Log Analytics workspace to Microsoft Sentinel
#   - Optional Log Analytics workspace creation
#   - Configurable data connectors (Azure AD, Defender for Cloud, Office 365, Threat Intelligence)
#   - Scheduled alert rules with customizable KQL queries
#   - Watchlist management for reference data
#   - Consistent naming and tagging via terraform-namer integration
#   - Daily ingestion quota controls for cost management
#   - Support for multiple alert rule configurations
#   - Compliance with Azure security best practices
#
# Resources Created:
#   - azurerm_log_analytics_workspace (optional)
#   - azurerm_sentinel_log_analytics_workspace_onboarding
#   - azurerm_sentinel_data_connector_azure_active_directory (optional)
#   - azurerm_sentinel_data_connector_azure_security_center (optional)
#   - azurerm_sentinel_data_connector_office_365 (optional)
#   - azurerm_sentinel_data_connector_threat_intelligence (optional)
#   - azurerm_sentinel_alert_rule_scheduled (multiple, based on configuration)
#   - azurerm_sentinel_watchlist (multiple, based on configuration)
#
# Dependencies:
#   - terraform-terraform-namer (required) - Provides standardized naming and tagging
#   - azurerm provider >= 4.0
#   - Existing Log Analytics workspace (if not creating new one)
#   - Appropriate Azure RBAC permissions (Microsoft Sentinel Contributor role)
#
# Usage Example:
#   module "sentinel" {
#     source = "../terraform-azurerm-sentinel"
#
#     # Naming variables
#     contact     = "security@example.com"
#     environment = "prd"
#     location    = "centralus"
#     repository  = "infoex-iac"
#     workload    = "security"
#
#     # Resource configuration
#     resource_group_name            = "rg-security-cu-prd-kmi-0"
#     create_log_analytics_workspace = true
#     log_analytics_retention_in_days = 90
#
#     # Data connectors
#     enable_azure_active_directory_connector = true
#     enable_azure_security_center_connector  = true
#     enable_office365_connector              = true
#
#     # Alert rules
#     alert_rules = {
#       failed_logins = {
#         display_name    = "Multiple Failed Login Attempts"
#         severity        = "High"
#         query           = "SigninLogs | where ResultType != 0 | summarize count() by UserPrincipalName"
#         query_frequency = "PT1H"
#         query_period    = "PT1H"
#       }
#     }
#   }
#
# =============================================================================

# Section: Naming and Tagging
# =============================================================================

module "naming" {
  source = "git::https://github.com/excellere-it/terraform-terraform-namer.git"

  contact     = var.contact
  environment = var.environment
  location    = var.location
  repository  = var.repository
  workload    = var.workload
}

# Section: Local Variables
# =============================================================================

locals {
  # Determine the Log Analytics workspace ID to use
  log_analytics_workspace_id = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.this[0].id : var.log_analytics_workspace_id

  # Merge standard tags with any additional tags
  tags = merge(
    module.naming.tags,
    var.additional_tags
  )
}

# Section: Data Sources
# =============================================================================

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Section: Log Analytics Workspace (Optional)
# =============================================================================

resource "azurerm_log_analytics_workspace" "this" {
  count = var.create_log_analytics_workspace ? 1 : 0

  name                = "log-${module.naming.resource_suffix}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_in_days
  daily_quota_gb      = var.log_analytics_daily_quota_gb
  tags                = local.tags
}

# Section: Sentinel Onboarding
# =============================================================================

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  workspace_id                 = local.log_analytics_workspace_id
  customer_managed_key_enabled = false

  # Ensure workspace exists before onboarding
  depends_on = [
    azurerm_log_analytics_workspace.this
  ]
}

# Section: Data Connectors
# =============================================================================

resource "azurerm_sentinel_data_connector_azure_active_directory" "this" {
  count = var.enable_azure_active_directory_connector ? 1 : 0

  name                       = "dc-aad-${module.naming.resource_suffix}"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
}

resource "azurerm_sentinel_data_connector_azure_security_center" "this" {
  count = var.enable_azure_security_center_connector ? 1 : 0

  name                       = "dc-asc-${module.naming.resource_suffix}"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
}

resource "azurerm_sentinel_data_connector_office_365" "this" {
  count = var.enable_office365_connector ? 1 : 0

  name                       = "dc-o365-${module.naming.resource_suffix}"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
  exchange_enabled           = var.office365_exchange_enabled
  sharepoint_enabled         = var.office365_sharepoint_enabled
  teams_enabled              = var.office365_teams_enabled
}

resource "azurerm_sentinel_data_connector_threat_intelligence" "this" {
  count = var.enable_threat_intelligence_connector ? 1 : 0

  name                       = "dc-ti-${module.naming.resource_suffix}"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
}

# Section: Alert Rules
# =============================================================================

resource "azurerm_sentinel_alert_rule_scheduled" "this" {
  for_each = var.alert_rules

  name                       = each.key
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
  display_name               = each.value.display_name
  severity                   = each.value.severity
  enabled                    = each.value.enabled
  query                      = each.value.query
  query_frequency            = each.value.query_frequency
  query_period               = each.value.query_period
  trigger_operator           = each.value.trigger_operator
  trigger_threshold          = each.value.trigger_threshold
  suppression_enabled        = each.value.suppression_enabled
  suppression_duration       = each.value.suppression_duration
  tactics                    = length(each.value.tactics) > 0 ? each.value.tactics : null
  techniques                 = length(each.value.techniques) > 0 ? each.value.techniques : null

  event_grouping {
    aggregation_method = each.value.event_grouping
  }

  dynamic "alert_details_override" {
    for_each = length(each.value.alert_details_override) > 0 ? [each.value.alert_details_override] : []
    content {
      description_format   = lookup(alert_details_override.value, "description_format", null)
      display_name_format  = lookup(alert_details_override.value, "display_name_format", null)
      severity_column_name = lookup(alert_details_override.value, "severity_column_name", null)
      tactics_column_name  = lookup(alert_details_override.value, "tactics_column_name", null)
    }
  }
}

# Section: Watchlists
# =============================================================================

resource "azurerm_sentinel_watchlist" "this" {
  for_each = var.watchlists

  name                       = each.key
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
  display_name               = each.value.display_name
  item_search_key            = each.value.item_search_key
  description                = each.value.description
  default_duration           = each.value.default_duration
}
