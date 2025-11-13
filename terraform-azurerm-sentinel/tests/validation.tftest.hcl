# =============================================================================
# Input Validation Tests
# =============================================================================
# These tests verify that input validation rules are working correctly.
# All tests should fail with expect_failures to ensure validation is enforced.

# Test: Invalid environment
run "test_invalid_environment" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "invalid"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
  }

  expect_failures = [
    var.environment,
  ]
}

# Test: Invalid contact email
run "test_invalid_contact_email" {
  command = plan

  variables {
    contact                        = "not-an-email"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
  }

  expect_failures = [
    var.contact,
  ]
}

# Test: Invalid Log Analytics SKU
run "test_invalid_log_analytics_sku" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
    log_analytics_sku              = "InvalidSKU"
  }

  expect_failures = [
    var.log_analytics_sku,
  ]
}

# Test: Invalid retention days (too low)
run "test_invalid_retention_too_low" {
  command = plan

  variables {
    contact                         = "test@example.com"
    environment                     = "dev"
    location                        = "centralus"
    repository                      = "test-repo"
    workload                        = "security"
    resource_group_name             = "rg-test"
    create_log_analytics_workspace  = true
    log_analytics_retention_in_days = 7
  }

  expect_failures = [
    var.log_analytics_retention_in_days,
  ]
}

# Test: Invalid retention days (too high)
run "test_invalid_retention_too_high" {
  command = plan

  variables {
    contact                         = "test@example.com"
    environment                     = "dev"
    location                        = "centralus"
    repository                      = "test-repo"
    workload                        = "security"
    resource_group_name             = "rg-test"
    create_log_analytics_workspace  = true
    log_analytics_retention_in_days = 1000
  }

  expect_failures = [
    var.log_analytics_retention_in_days,
  ]
}

# Test: Invalid daily quota (zero)
run "test_invalid_daily_quota_zero" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
    log_analytics_daily_quota_gb   = 0
  }

  expect_failures = [
    var.log_analytics_daily_quota_gb,
  ]
}

# Test: Invalid alert rule severity
run "test_invalid_alert_severity" {
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
        display_name    = "Test Rule"
        severity        = "Critical"
        query           = "SecurityAlert"
        query_frequency = "PT1H"
        query_period    = "PT1H"
      }
    }
  }

  expect_failures = [
    var.alert_rules,
  ]
}

# Test: Invalid alert rule trigger operator
run "test_invalid_trigger_operator" {
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
        display_name     = "Test Rule"
        severity         = "High"
        query            = "SecurityAlert"
        query_frequency  = "PT1H"
        query_period     = "PT1H"
        trigger_operator = "InvalidOperator"
      }
    }
  }

  expect_failures = [
    var.alert_rules,
  ]
}

# Test: Valid minimum retention
run "test_valid_minimum_retention" {
  command = plan

  variables {
    contact                         = "test@example.com"
    environment                     = "dev"
    location                        = "centralus"
    repository                      = "test-repo"
    workload                        = "security"
    resource_group_name             = "rg-test"
    create_log_analytics_workspace  = true
    log_analytics_retention_in_days = 30
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].retention_in_days == 30
    error_message = "Minimum retention of 30 days should be accepted"
  }
}

# Test: Valid maximum retention
run "test_valid_maximum_retention" {
  command = plan

  variables {
    contact                         = "test@example.com"
    environment                     = "dev"
    location                        = "centralus"
    repository                      = "test-repo"
    workload                        = "security"
    resource_group_name             = "rg-test"
    create_log_analytics_workspace  = true
    log_analytics_retention_in_days = 730
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].retention_in_days == 730
    error_message = "Maximum retention of 730 days should be accepted"
  }
}

# Test: Valid unlimited daily quota
run "test_valid_unlimited_quota" {
  command = plan

  variables {
    contact                        = "test@example.com"
    environment                    = "dev"
    location                       = "centralus"
    repository                     = "test-repo"
    workload                       = "security"
    resource_group_name            = "rg-test"
    create_log_analytics_workspace = true
    log_analytics_daily_quota_gb   = -1
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].daily_quota_gb == -1
    error_message = "Unlimited daily quota (-1) should be accepted"
  }
}

# Test: Valid alert rule severities
run "test_valid_alert_severities" {
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
      high_rule = {
        display_name = "High Severity Rule"
        severity     = "High"
        query        = "SecurityAlert"
      }
      medium_rule = {
        display_name = "Medium Severity Rule"
        severity     = "Medium"
        query        = "SecurityAlert"
      }
      low_rule = {
        display_name = "Low Severity Rule"
        severity     = "Low"
        query        = "SecurityAlert"
      }
      info_rule = {
        display_name = "Informational Rule"
        severity     = "Informational"
        query        = "SecurityAlert"
      }
    }
  }

  assert {
    condition     = length(keys(azurerm_sentinel_alert_rule_scheduled.this)) == 4
    error_message = "All valid severity levels should be accepted"
  }
}
