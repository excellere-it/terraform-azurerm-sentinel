# Contributing to terraform-azurerm-sentinel

Thank you for your interest in contributing to the terraform-azurerm-sentinel module! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Testing Requirements](#testing-requirements)
- [Coding Standards](#coding-standards)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and professional in all interactions.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

Before you begin, ensure you have the following tools installed:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.13.4
- [terraform-docs](https://terraform-docs.io/) (for documentation generation)
- [Make](https://www.gnu.org/software/make/) (for automation)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure authentication)
- Git

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-azurerm-sentinel.git
   cd terraform-azurerm-sentinel
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/kelomai/terraform-azurerm-sentinel.git
   ```

### Development Setup

1. Verify your setup:
   ```bash
   make fmt
   make validate
   ```

2. Ensure you have Azure credentials configured:
   ```bash
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test additions or modifications
- `refactor/` - Code refactoring

### 2. Make Your Changes

- Follow the [coding standards](#coding-standards) below
- Write clear, concise commit messages
- Keep commits focused and atomic

### 3. Test Your Changes

Before submitting a pull request, ensure all tests pass:

```bash
# Format code
make fmt

# Validate configuration
make validate

# Run all tests
make test

# Generate documentation
make docs
```

### 4. Commit Your Changes

Write clear commit messages following this format:

```
<type>: <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or changes
- `refactor`: Code refactoring
- `style`: Code style changes (formatting, etc.)
- `chore`: Maintenance tasks

Example:
```
feat: Add support for custom alert rules

Added support for configuring custom scheduled alert rules with
configurable KQL queries, severity levels, and trigger conditions.

Closes #123
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## Testing Requirements

All contributions must include appropriate tests.

### Running Tests

```bash
# Run all tests (format, validate, docs, tests)
make test

# Run only Terraform native tests
make test-terraform

# Run tests with verbose output
terraform test -verbose

# Run specific test file
make test-terraform-filter FILE=tests/basic.tftest.hcl
```

### Test Coverage

- All new features must include tests
- Bug fixes should include regression tests
- Aim for comprehensive test coverage of new code

### Writing Tests

Tests use Terraform's native testing framework (.tftest.hcl files):

```hcl
run "test_basic_sentinel_onboarding" {
  command = plan

  variables {
    contact                            = "security@example.com"
    environment                        = "dev"
    location                           = "centralus"
    repository                         = "infoex-iac"
    workload                           = "security"
    resource_group_name                = "rg-test"
    create_log_analytics_workspace     = true
  }

  assert {
    condition     = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id != null
    error_message = "Sentinel workspace ID must be set"
  }
}
```

### Test Organization

Tests are organized into two main files:
- `tests/basic.tftest.hcl` - Core functionality tests
- `tests/validation.tftest.hcl` - Input validation tests

## Coding Standards

### Terraform Style

Follow the [HashiCorp Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html):

1. **Formatting**: Use `terraform fmt` for consistent formatting
2. **Naming**: Use snake_case for variables, outputs, and resources
3. **Comments**: Add section headers and explain complex logic
4. **Organization**: Group related resources together

### File Organization

```
terraform-azurerm-sentinel/
├── main.tf           # Core module logic with 80-120 line header
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output definitions
├── versions.tf       # Provider version requirements
├── examples/         # Usage examples
│   └── default/      # Minimum required example
└── tests/            # Terraform native tests
    ├── basic.tftest.hcl
    └── validation.tftest.hcl
```

### Variable Naming

- Use descriptive, lowercase names with underscores
- Prefix boolean variables with `enable_` or `create_`
- Use plural for list/map variables

### Documentation Standards

1. **Variables**: All variables must have descriptions
   ```hcl
   variable "environment" {
     type        = string
     description = "Environment name (dev, stg, prd)"
   }
   ```

2. **Outputs**: All outputs must have descriptions
   ```hcl
   output "sentinel_workspace_id" {
     value       = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
     description = "The ID of the Log Analytics workspace onboarded to Sentinel"
   }
   ```

3. **Comments**: Use section headers in main.tf
   ```hcl
   # Section: Data Connectors
   # =============================================================================
   ```

### Input Validation

Add validation rules for inputs where appropriate:

```hcl
variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "stg", "prd", "sbx", "tst", "hub", "ops"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd, sbx, tst, hub, ops"
  }
}
```

## Documentation

### README Updates

When adding features or changing behavior:

1. Update the README.md with new examples
2. Run `make docs` to regenerate terraform-docs sections
3. Ensure all examples are up to date

### terraform-docs

Documentation is automatically generated from:
- Variable descriptions in `variables.tf`
- Output descriptions in `outputs.tf`
- Header comment in `main.tf` (first 80-120 lines)

Generate documentation:
```bash
make docs
```

### Examples

Add examples for new features in the `examples/` directory:

```
examples/
└── your-feature/
    ├── main.tf
    └── versions.tf
```

## Pull Request Process

### Before Submitting

Ensure you have:

- [ ] Run `make fmt` to format code
- [ ] Run `make validate` to validate configuration
- [ ] Run `make test` and all tests pass
- [ ] Run `make docs` to update documentation
- [ ] Added tests for new functionality
- [ ] Updated README.md if needed
- [ ] Updated CHANGELOG.md with your changes
- [ ] Rebased on latest main branch

### PR Description

Include in your pull request:

1. **Summary**: Brief description of changes
2. **Motivation**: Why is this change needed?
3. **Changes**: List of specific changes made
4. **Testing**: How you tested the changes
5. **Screenshots**: If applicable (for documentation changes)
6. **Breaking Changes**: Note any breaking changes
7. **Related Issues**: Link to related issues

### Review Process

1. Automated checks will run (tests, formatting, validation, etc.)
2. Maintainers will review your code
3. Address any feedback
4. Once approved, maintainers will merge

### After Merge

1. Delete your feature branch
2. Pull the latest changes from upstream:
   ```bash
   git checkout main
   git pull upstream main
   ```

## Release Process

Releases are automated using GitHub Actions:

1. Maintainers create a version tag (e.g., `v0.1.0`)
2. GitHub Actions automatically creates a release
3. Release notes are auto-generated from CHANGELOG.md

## Security Considerations

When contributing to this security-focused module:

- Never commit sensitive data (credentials, secrets, keys)
- Review alert rules for potential false positives
- Test data connector configurations thoroughly
- Document security implications of configuration changes
- Follow Azure Sentinel best practices

## Getting Help

If you need help:

- Check existing [issues](https://github.com/kelomai/terraform-azurerm-sentinel/issues)
- Review the [README](README.md)
- Create a new issue with your question

## Additional Resources

- [Microsoft Sentinel Documentation](https://docs.microsoft.com/en-us/azure/sentinel/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

Thank you for contributing to terraform-azurerm-sentinel!
