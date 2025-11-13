# GitHub Actions Workflows

This directory contains GitHub Actions workflows for CI/CD automation of the `terraform-azurerm-sentinel` module.

## Workflows

### test.yml - Terraform Tests

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch
- Only runs when Terraform files, tests, or the workflow file itself changes

**Jobs:**

1. **terraform-format** (1-2 min)
   - Checks Terraform code formatting
   - Uses `terraform fmt -check -recursive`
   - Fails on formatting issues

2. **terraform-validate** (1-2 min)
   - Validates Terraform configuration
   - Initializes with `terraform init -backend=false`
   - Runs `terraform validate`

3. **security-scan** (2-5 min)
   - Runs Checkov security analysis
   - Scans for security misconfigurations
   - Soft fail (doesn't block on findings)
   - Uploads SARIF results as artifacts

4. **lint** (2-3 min)
   - Runs TFLint for code quality
   - Checks for deprecated syntax
   - Validates best practices

5. **terraform-tests** (3-5 min)
   - Runs native Terraform tests (.tftest.hcl files)
   - Executes `terraform test -verbose`
   - Tests core functionality and validation rules

6. **test-examples** (5-10 min)
   - Matrix strategy for all examples
   - Currently tests: `default`
   - Runs init, validate, and plan
   - Uploads plan artifacts
   - Requires Azure credentials

7. **test-summary** (1 min)
   - Aggregates all test results
   - Creates GitHub step summary
   - Fails if required tests fail

8. **comment-pr** (1 min)
   - Posts test results to pull requests
   - Shows status icons for each job
   - Provides quick overview of test status

**Total Runtime:** ~15-25 minutes

**Required Secrets:**
- `TF_API_TOKEN` - Terraform Cloud API token (optional)
- `INFOEX_SBX_CLIENT_ID` - Azure service principal client ID
- `INFOEX_SBX_CLIENT_SECRET` - Azure service principal client secret
- `INFOEX_SBX_TENANT_ID` - Azure tenant ID
- `INFOEX_SBX_SUBSCRIPTION_ID` - Azure subscription ID

### release-module.yml - Release Automation

**Triggers:**
- Push of version tags (e.g., `v0.1.0`, `0.1.0`)

**Jobs:**

1. **release**
   - Checks out code with full history
   - Extracts release notes from CHANGELOG.md
   - Creates GitHub release
   - Auto-generates additional release notes

**Usage:**
```bash
# Create and push a version tag
git tag v0.1.0
git push origin v0.1.0

# Or using semantic versioning without 'v' prefix
git tag 0.1.0
git push origin 0.1.0
```

## Workflow Configuration

### Branch Protection

Recommended branch protection rules for `main`:

- Require pull request reviews before merging
- Require status checks to pass:
  - `terraform-format`
  - `terraform-validate`
  - `terraform-tests`
  - `test-examples`
- Require branches to be up to date before merging
- Require linear history

### Secrets Setup

Configure the following secrets in your repository settings:

1. **Terraform Cloud (optional):**
   - `TF_API_TOKEN` - For private module registry

2. **Azure Service Principal:**
   ```bash
   # Create service principal
   az ad sp create-for-rbac --name "terraform-azurerm-sentinel-ci" \
     --role Contributor \
     --scopes /subscriptions/{subscription-id}

   # Set as GitHub secrets:
   # INFOEX_SBX_CLIENT_ID
   # INFOEX_SBX_CLIENT_SECRET
   # INFOEX_SBX_TENANT_ID
   # INFOEX_SBX_SUBSCRIPTION_ID
   ```

## Local Testing

Before pushing, run local checks:

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

## Workflow Artifacts

### Test Workflow
- **security-scan-results** - Checkov SARIF output (30 days retention)
- **tfplan-{example}** - Terraform plan files for each example

### Release Workflow
- **GitHub Release** - Created with version tag and release notes

## Troubleshooting

### Workflow Fails on Format Check

```bash
# Fix locally
make fmt

# Commit and push
git add .
git commit -m "fix: format Terraform code"
git push
```

### Workflow Fails on Validation

```bash
# Validate locally
make validate

# Fix issues and push
```

### Workflow Fails on Tests

```bash
# Run tests locally
make test

# Run specific test file
terraform test -filter=tests/basic.tftest.hcl -verbose

# Fix issues and push
```

### Example Tests Fail (Azure Auth)

Ensure Azure credentials are correctly configured in repository secrets:
- Verify service principal has appropriate permissions
- Check subscription ID is correct
- Ensure service principal hasn't expired

### Security Scan Warnings

Security scan is set to soft fail and won't block merges. Review findings and address critical issues:

```bash
# Install tfsec locally
brew install tfsec  # macOS
# or
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Run scan
tfsec .
```

## Workflow Modifications

### Adding New Examples

Update `test-examples` matrix in `test.yml`:

```yaml
strategy:
  matrix:
    example:
      - default
      - your-new-example
```

### Changing Terraform Version

Update in all jobs:

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: "1.13.4"  # Change here
```

### Adding New Test Jobs

1. Add job definition
2. Update `test-summary` needs
3. Update `comment-pr` needs and environment variables

## Best Practices

1. **Always run local tests before pushing**
   ```bash
   make pre-commit
   ```

2. **Keep workflows fast**
   - Use caching where possible
   - Run jobs in parallel
   - Use matrix strategies for similar tasks

3. **Fail fast**
   - Put format and validation checks first
   - Use `continue-on-error: false` for critical checks

4. **Provide clear feedback**
   - Use descriptive job names
   - Add step summaries
   - Comment on PRs with results

5. **Secure credentials**
   - Never commit secrets
   - Use GitHub secrets
   - Rotate credentials regularly
   - Use minimal required permissions

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [hashicorp/setup-terraform](https://github.com/hashicorp/setup-terraform)
- [Checkov GitHub Action](https://github.com/bridgecrewio/checkov-action)
- [TFLint GitHub Action](https://github.com/terraform-linters/setup-tflint)
