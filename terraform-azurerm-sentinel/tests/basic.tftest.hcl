# =============================================================================
# Basic Functionality Tests
# =============================================================================
# These tests verify the core functionality of the Sentinel module.
# All tests use the 'plan' command to avoid creating actual Azure resources.

# Test: Basic Sentinel onboarding with new workspace
run "test_basic_sentinel_creation" {
  command = plan

  variables {
    contact                         = "test@example.com"
    environment                     = "dev"
    location                        = "centralus"
    repository                      = "test-repo"
    workload                        = "security"
    resource_group_name             = "rg-test"
    create_log_analytics_workspace  = true
    log_analytics_retention_in_days = 90
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].name != null
    error_message = "Log Analytics workspace name must be generated"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].sku == "PerGB2018"
    error_message = "Default SKU should be PerGB2018"
  }

  assert {
    condition     = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id != null
    error_message = "Sentinel onboarding workspace ID must be set"
  }
}

# Test: Sentinel with existing workspace
run "test_sentinel_with_existing_workspace" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "prd"
    location                       = "eastus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = false
    log_analytics_workspace_id     = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/log-test"
  }

  assert {
    condition     = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/log-test"
    error_message = "Sentinel should use the provided workspace ID"
  }
}

# Test: Data connector configuration
run "test_data_connectors" {
  command = plan

  variables {
    contact                                 = "test@example.com"
    environment                             = "dev"
    location                                = "centralus"
    repository                              = "test-repo"
    workload                                = "security"
    resource_group_name                     = "rg-test"
    create_log_analytics_workspace          = true
    enable_azure_active_directory_connector = true
    enable_azure_security_center_connector  = true
    enable_office365_connector              = true
    enable_threat_intelligence_connector    = true
  }

  assert {
    condition     = azurerm_sentinel_data_connector_azure_active_directory.this[0].name != null
    error_message = "Azure AD connector should be created when enabled"
  }

  assert {
    condition     = azurerm_sentinel_data_connector_azure_security_center.this[0].name != null
    error_message = "Security Center connector should be created when enabled"
  }

  assert {
    condition     = azurerm_sentinel_data_connector_office_365.this[0].name != null
    error_message = "Office 365 connector should be created when enabled"
  }

  assert {
    condition     = azurerm_sentinel_data_connector_threat_intelligence.this[0].name != null
    error_message = "Threat Intelligence connector should be created when enabled"
  }
}

# Test: Alert rules configuration
run "test_alert_rules" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true

    alert_rules = {
      test_rule = {
        display_name      = "Test Alert Rule"
        severity          = "High"
        enabled           = true
        query             = "SecurityAlert | where AlertSeverity == 'High'"
        query_frequency   = "PT1H"
        query_period      = "PT1H"
        trigger_operator  = "GreaterThan"
        trigger_threshold = 0
        tactics           = ["Impact"]
      }
    }
  }

  assert {
    condition     = azurerm_sentinel_alert_rule_scheduled.this["test_rule"].display_name == "Test Alert Rule"
    error_message = "Alert rule display name should match configuration"
  }

  assert {
    condition     = azurerm_sentinel_alert_rule_scheduled.this["test_rule"].severity == "High"
    error_message = "Alert rule severity should be High"
  }

  assert {
    condition     = azurerm_sentinel_alert_rule_scheduled.this["test_rule"].enabled == true
    error_message = "Alert rule should be enabled"
  }
}

# Test: Watchlists configuration
run "test_watchlists" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true

    watchlists = {
      vip_users = {
        display_name     = "VIP Users"
        item_search_key  = "UserPrincipalName"
        description      = "List of VIP users"
        default_duration = "P90D"
      }
    }
  }

  assert {
    condition     = azurerm_sentinel_watchlist.this["vip_users"].display_name == "VIP Users"
    error_message = "Watchlist display name should match configuration"
  }

  assert {
    condition     = azurerm_sentinel_watchlist.this["vip_users"].item_search_key == "UserPrincipalName"
    error_message = "Watchlist item search key should match configuration"
  }
}

# Test: Naming module integration
run "test_naming_integration" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "app"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
  }

  assert {
    condition     = output.resource_suffix != null
    error_message = "Resource suffix from naming module must be generated"
  }

  assert {
    condition     = output.tags != null
    error_message = "Tags from naming module must be generated"
  }

  assert {
    condition     = can(output.tags["environment"])
    error_message = "Tags must include environment tag"
  }
}

# Test: Cost management - daily quota
run "test_daily_quota_configuration" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
    log_analytics_daily_quota_gb   = 10
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].daily_quota_gb == 10
    error_message = "Daily quota should be set to 10 GB"
  }
}

# Test: Multiple alert rules
run "test_multiple_alert_rules" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true

    alert_rules = {
      rule1 = {
        display_name    = "Rule 1"
        severity        = "High"
        query           = "SecurityAlert | where AlertSeverity == 'High'"
        query_frequency = "PT1H"
        query_period    = "PT1H"
      }
      rule2 = {
        display_name    = "Rule 2"
        severity        = "Medium"
        query           = "SecurityAlert | where AlertSeverity == 'Medium'"
        query_frequency = "PT2H"
        query_period    = "PT2H"
      }
    }
  }

  assert {
    condition     = length(keys(azurerm_sentinel_alert_rule_scheduled.this)) == 2
    error_message = "Should create exactly 2 alert rules"
  }
}
