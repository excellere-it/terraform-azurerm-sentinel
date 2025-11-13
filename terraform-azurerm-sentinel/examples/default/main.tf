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
