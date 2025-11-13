# =============================================================================
# Required Variables - Naming
# =============================================================================

variable "contact" {
  type        = string
  description = "Contact email for resource ownership and management"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.contact))
    error_message = "Contact must be a valid email address"
  }
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, stg, prd)"

  validation {
    condition     = contains(["dev", "stg", "prd", "sbx", "tst", "hub", "ops"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd, sbx, tst, hub, ops"
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"
}

variable "repository" {
  type        = string
  description = "Repository name for tracking infrastructure as code source"
}

variable "workload" {
  type        = string
  description = "Workload or application name identifier"
}

# =============================================================================
# Required Variables - Log Analytics
# =============================================================================

variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics workspace to onboard to Microsoft Sentinel. If not provided, a new workspace will be created."
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Sentinel resources"
}

# =============================================================================
# Optional Variables - Log Analytics Workspace Creation
# =============================================================================

variable "create_log_analytics_workspace" {
  type        = bool
  description = "Whether to create a new Log Analytics workspace. If false, log_analytics_workspace_id must be provided."
  default     = false
}

variable "log_analytics_sku" {
  type        = string
  description = "SKU for the Log Analytics workspace. Valid values: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018"
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.log_analytics_sku)
    error_message = "Invalid Log Analytics SKU. Must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018"
  }
}

variable "log_analytics_retention_in_days" {
  type        = number
  description = "The workspace data retention in days. Valid values: 30-730 days (Free tier only supports 7 days)"
  default     = 90

  validation {
    condition     = var.log_analytics_retention_in_days >= 30 && var.log_analytics_retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days"
  }
}

variable "log_analytics_daily_quota_gb" {
  type        = number
  description = "The daily ingestion quota in GB. -1 means unlimited."
  default     = -1

  validation {
    condition     = var.log_analytics_daily_quota_gb == -1 || var.log_analytics_daily_quota_gb >= 1
    error_message = "Daily quota must be -1 (unlimited) or >= 1 GB"
  }
}

# =============================================================================
# Optional Variables - Sentinel Configuration
# =============================================================================

variable "daily_quota_gb" {
  type        = number
  description = "The daily ingestion quota in GB for Sentinel. -1 means unlimited."
  default     = -1

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb >= 1
    error_message = "Daily quota must be -1 (unlimited) or >= 1 GB"
  }
}

# =============================================================================
# Optional Variables - Alert Rules
# =============================================================================

variable "alert_rules" {
  type = map(object({
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
  description = "Map of scheduled alert rules to create. Key is the rule name."
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.alert_rules : contains(["High", "Medium", "Low", "Informational"], v.severity)
    ])
    error_message = "Alert rule severity must be one of: High, Medium, Low, Informational"
  }

  validation {
    condition = alltrue([
      for k, v in var.alert_rules : contains(["GreaterThan", "LessThan", "Equal", "NotEqual"], v.trigger_operator)
    ])
    error_message = "Alert rule trigger_operator must be one of: GreaterThan, LessThan, Equal, NotEqual"
  }
}

# =============================================================================
# Optional Variables - Data Connectors
# =============================================================================

variable "enable_azure_active_directory_connector" {
  type        = bool
  description = "Enable Azure Active Directory data connector"
  default     = false
}

variable "enable_azure_security_center_connector" {
  type        = bool
  description = "Enable Microsoft Defender for Cloud (formerly Security Center) data connector"
  default     = false
}

variable "enable_office365_connector" {
  type        = bool
  description = "Enable Office 365 data connector"
  default     = false
}

variable "office365_exchange_enabled" {
  type        = bool
  description = "Enable Exchange logs for Office 365 connector"
  default     = true
}

variable "office365_sharepoint_enabled" {
  type        = bool
  description = "Enable SharePoint logs for Office 365 connector"
  default     = true
}

variable "office365_teams_enabled" {
  type        = bool
  description = "Enable Teams logs for Office 365 connector"
  default     = true
}

variable "enable_threat_intelligence_connector" {
  type        = bool
  description = "Enable Threat Intelligence data connector"
  default     = false
}

# =============================================================================
# Optional Variables - Watchlists
# =============================================================================

variable "watchlists" {
  type = map(object({
    display_name     = string
    item_search_key  = string
    description      = optional(string, "")
    default_duration = optional(string, "P30D")
    items            = optional(list(map(string)), [])
  }))
  description = "Map of watchlists to create. Key is the watchlist name."
  default     = {}
}

# =============================================================================
# Optional Variables - Tagging
# =============================================================================

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to merge with the standard naming module tags"
  default     = {}
}
