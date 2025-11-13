# Terraform Tests

This directory contains native Terraform tests for the `terraform-azurerm-sentinel` module.

## Overview

The test suite uses Terraform's native testing framework (`.tftest.hcl` files) introduced in Terraform 1.6.0. This approach provides fast, plan-only tests that verify module functionality without creating actual Azure resources.

## Test Structure

### Test Files

- **basic.tftest.hcl** - Core functionality tests
  - Basic Sentinel onboarding with new workspace
  - Sentinel with existing workspace
  - Data connector configuration
  - Alert rules configuration
  - Watchlists configuration
  - Naming module integration
  - Cost management features
  - Multiple alert rules

- **validation.tftest.hcl** - Input validation tests
  - Invalid environment values
  - Invalid contact email formats
  - Invalid Log Analytics SKU
  - Invalid retention periods
  - Invalid daily quota values
  - Invalid alert rule severities
  - Invalid trigger operators
  - Valid edge cases (min/max values)

## Running Tests

### Run All Tests

```bash
# From module root
make test

# Or directly with Terraform
terraform test
```

### Run Specific Test File

```bash
# Using Make
make test-terraform-filter FILE=tests/basic.tftest.hcl

# Or directly with Terraform
terraform test -filter=tests/basic.tftest.hcl
```

### Verbose Output

```bash
terraform test -verbose
```

## Test Strategy

### Plan-Only Testing

All tests use the `plan` command to avoid creating actual Azure resources:

```hcl
run "test_name" {
  command = plan

  variables {
    # Test variables
  }

  assert {
    # Assertions
  }
}
```

**Benefits:**
- Fast execution (no resource creation)
- No Azure costs
- No cleanup required
- Can run in CI/CD without credentials

### Validation Testing

Tests use `expect_failures` to verify that validation rules are enforced:

```hcl
run "test_invalid_input" {
  command = plan

  variables {
    invalid_variable = "bad_value"
  }

  expect_failures = [
    var.invalid_variable,
  ]
}
```

## Test Coverage

### Core Functionality

- ✅ Log Analytics workspace creation
- ✅ Log Analytics workspace integration (existing)
- ✅ Sentinel onboarding
- ✅ Data connector configuration
  - Azure Active Directory
  - Microsoft Defender for Cloud
  - Office 365
  - Threat Intelligence
- ✅ Scheduled alert rules
- ✅ Watchlists
- ✅ Naming module integration
- ✅ Cost management (daily quota)

### Input Validation

- ✅ Environment validation
- ✅ Contact email validation
- ✅ Log Analytics SKU validation
- ✅ Retention period validation
- ✅ Daily quota validation
- ✅ Alert rule severity validation
- ✅ Alert rule trigger operator validation

## CI/CD Integration

Tests are automatically run in the GitHub Actions CI/CD pipeline:

```yaml
- name: Run Terraform Tests
  run: terraform test -verbose
```

The test workflow runs on:
- Every push to main
- Every pull request
- Manual workflow dispatch

## Test Development Guidelines

### Writing New Tests

1. **Choose the appropriate test file:**
   - `basic.tftest.hcl` for functionality tests
   - `validation.tftest.hcl` for validation tests

2. **Follow naming conventions:**
   - Use descriptive test names: `test_feature_scenario`
   - Use clear variable values for test scenarios

3. **Add assertions:**
   - Verify expected outputs
   - Check resource attributes
   - Validate computed values

4. **Add comments:**
   - Explain what the test verifies
   - Document expected behavior

### Test Example

```hcl
# Test: Feature description
run "test_feature_name" {
  command = plan

  variables {
    # Required variables
    contact     = "test@example.com"
    environment = "dev"
    # ... other variables

    # Feature-specific variables
    feature_enabled = true
  }

  assert {
    condition     = resource.type.name.attribute == expected_value
    error_message = "Descriptive error message"
  }
}
```

## Debugging Tests

### View Test Output

```bash
# Verbose output
terraform test -verbose

# Filter specific test
terraform test -filter=tests/basic.tftest.hcl -verbose
```

### Common Issues

**Issue: Test fails with "No such file or directory"**
- Ensure you're running from the module root directory
- Verify test files are in the `tests/` directory

**Issue: Test fails with "Invalid test configuration"**
- Check test file syntax
- Verify variable names match module variables
- Ensure assertions reference valid resources

**Issue: Validation test doesn't fail as expected**
- Verify validation rules in `variables.tf`
- Check `expect_failures` targets correct variable
- Ensure invalid value truly violates validation

## Additional Resources

- [Terraform Testing Documentation](https://www.terraform.io/language/tests)
- [Terraform Test Syntax](https://www.terraform.io/language/tests/syntax)
- [Module Testing Best Practices](https://www.terraform.io/docs/language/modules/testing-experiment.html)

## Future Enhancements

Potential additions to the test suite:

- Integration tests with real Azure resources (using `apply` command)
- Performance tests for large configurations
- Security scanning integration
- Compliance testing
- Multi-region deployment tests
