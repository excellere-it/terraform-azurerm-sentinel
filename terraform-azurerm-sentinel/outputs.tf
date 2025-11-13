# =============================================================================
# Sentinel Onboarding Outputs
# =============================================================================

output "sentinel_workspace_id" {
  value       = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
  description = "The ID of the Log Analytics workspace onboarded to Sentinel"
}

output "sentinel_resource_group_name" {
  value       = data.azurerm_resource_group.this.name
  description = "The name of the resource group containing Sentinel resources"
}

# =============================================================================
# Log Analytics Workspace Outputs
# =============================================================================

output "log_analytics_workspace_id" {
  value       = local.log_analytics_workspace_id
  description = "The ID of the Log Analytics workspace used by Sentinel"
}

output "log_analytics_workspace_name" {
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.this[0].name : null
  description = "The name of the Log Analytics workspace (if created by this module)"
}

output "log_analytics_workspace_primary_shared_key" {
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.this[0].primary_shared_key : null
  description = "The primary shared key of the Log Analytics workspace (if created by this module)"
  sensitive   = true
}

output "log_analytics_workspace_workspace_id" {
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.this[0].workspace_id : null
  description = "The workspace ID (GUID) of the Log Analytics workspace (if created by this module)"
}

# =============================================================================
# Data Connector Outputs
# =============================================================================

output "azure_ad_connector_id" {
  value       = var.enable_azure_active_directory_connector ? azurerm_sentinel_data_connector_azure_active_directory.this[0].id : null
  description = "The ID of the Azure Active Directory data connector (if enabled)"
}

output "security_center_connector_id" {
  value       = var.enable_azure_security_center_connector ? azurerm_sentinel_data_connector_azure_security_center.this[0].id : null
  description = "The ID of the Microsoft Defender for Cloud data connector (if enabled)"
}

output "office365_connector_id" {
  value       = var.enable_office365_connector ? azurerm_sentinel_data_connector_office_365.this[0].id : null
  description = "The ID of the Office 365 data connector (if enabled)"
}

output "threat_intelligence_connector_id" {
  value       = var.enable_threat_intelligence_connector ? azurerm_sentinel_data_connector_threat_intelligence.this[0].id : null
  description = "The ID of the Threat Intelligence data connector (if enabled)"
}

# =============================================================================
# Alert Rule Outputs
# =============================================================================

output "alert_rule_ids" {
  value = {
    for k, v in azurerm_sentinel_alert_rule_scheduled.this : k => v.id
  }
  description = "Map of alert rule names to their resource IDs"
}

output "alert_rule_names" {
  value = {
    for k, v in azurerm_sentinel_alert_rule_scheduled.this : k => v.name
  }
  description = "Map of alert rule keys to their resource names"
}

# =============================================================================
# Watchlist Outputs
# =============================================================================

output "watchlist_ids" {
  value = {
    for k, v in azurerm_sentinel_watchlist.this : k => v.id
  }
  description = "Map of watchlist names to their resource IDs"
}

output "watchlist_names" {
  value = {
    for k, v in azurerm_sentinel_watchlist.this : k => v.name
  }
  description = "Map of watchlist keys to their resource names"
}

# =============================================================================
# Naming Module Outputs
# =============================================================================

output "resource_suffix" {
  value       = module.naming.resource_suffix
  description = "The standardized resource name suffix from the naming module"
}

output "tags" {
  value       = local.tags
  description = "The tags applied to all resources"
}
