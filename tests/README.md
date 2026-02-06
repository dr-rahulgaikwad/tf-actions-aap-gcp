# Test Suite for Terraform Actions GCP Patching

This directory contains property-based tests and unit tests for the Terraform Actions GCP Patching prototype.

## Testing Framework

- **Property-Based Testing**: [Hypothesis](https://hypothesis.readthedocs.io/) (Python)
- **Unit Testing**: pytest
- **Minimum Iterations**: 100 per property test (as specified in design document)

## Setup

Install test dependencies:

```bash
pip install -r requirements.txt
```

## Running Tests

### Run all tests
```bash
pytest
```

### Run specific test file
```bash
pytest test_vault_credential_retrieval.py
```

### Run with verbose output
```bash
pytest -v
```

### Run property-based tests only
```bash
pytest -m property
```

### Run with coverage
```bash
pytest --cov=. --cov-report=html
```

## Test Structure

### Property-Based Tests

Property tests verify universal correctness properties across randomized inputs:

- **test_vault_credential_retrieval.py**: Tests Property 14 (Vault Credential Retrieval)
  - Validates that all credentials are retrieved from Vault data sources
  - Validates that no hardcoded credentials exist in Terraform files
  - Runs 100+ iterations per test

### Test Annotations

Each property test includes a comment referencing the design property:

```python
# Feature: terraform-actions-gcp-patching, Property 14: Vault Credential Retrieval
```

## Property Tests

### Property 14: Vault Credential Retrieval

**Validates: Requirements 8.1**

Tests that for any credential requirement in the Terraform code (GCP, AAP, SSH), the credential is retrieved from a Vault data source, not from a hardcoded value.

**Test Coverage:**
- Vault data sources exist for all credential types
- No hardcoded credentials in any Terraform file
- Provider configurations use Vault-retrieved credentials
- All credential references point to declared Vault data sources

## Validation Scripts

### Terraform Validation

The `validate_terraform.sh` script validates Terraform configuration files for syntax and formatting:

```bash
# Run from project root
./tests/validate_terraform.sh

# Or specify a custom terraform directory
./tests/validate_terraform.sh path/to/terraform
```

**What it checks:**
- Terraform syntax validation (`terraform validate`)
- Terraform formatting (`terraform fmt -check`)
- Proper initialization

**Exit codes:**
- `0`: All checks passed
- `1`: One or more checks failed

### Ansible Validation

The `validate_ansible.sh` script validates Ansible playbooks for syntax and best practices:

```bash
# Run from project root
./tests/validate_ansible.sh

# Or specify a custom ansible directory
./tests/validate_ansible.sh path/to/ansible

# Show help
./tests/validate_ansible.sh --help
```

**What it checks:**
- Ansible playbook syntax validation (`ansible-playbook --syntax-check`)
- Ansible best practices linting (`ansible-lint`)
- Automatically finds all playbook files (*.yml, *.yaml)

**Exit codes:**
- `0`: All checks passed
- `1`: One or more checks failed

**Requirements:**
- `ansible-playbook` command must be installed
- `ansible-lint` is recommended but optional (warnings shown if not available)

## Continuous Integration

These tests and validation scripts should be run:

**On every commit:**
- `./tests/validate_terraform.sh` - Terraform syntax and formatting
- `./tests/validate_ansible.sh` - Ansible syntax and linting (when available)
- Unit tests: `pytest -m "not property"`

**On every pull request:**
- All validation scripts
- Full test suite: `pytest`
- Property-based tests with 100+ iterations

**Before deployment:**
- All validation scripts
- Full test suite with integration tests
- Manual verification of demo workflow

### CI/CD Pipeline Example

**GitHub Actions:**
```yaml
name: Validate and Test

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Validate Terraform
        run: ./tests/validate_terraform.sh
      
      - name: Setup Ansible
        run: |
          pip install ansible ansible-lint
        
      - name: Validate Ansible
        run: ./tests/validate_ansible.sh
        
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
          
      - name: Install dependencies
        run: pip install -r tests/requirements.txt
        
      - name: Run tests
        run: pytest
```

**GitLab CI:**
```yaml
stages:
  - validate
  - test

terraform-validate:
  stage: validate
  image: hashicorp/terraform:latest
  script:
    - ./tests/validate_terraform.sh

ansible-validate:
  stage: validate
  image: python:3.10
  script:
    - pip install ansible ansible-lint
    - ./tests/validate_ansible.sh

python-tests:
  stage: test
  image: python:3.10
  script:
    - pip install -r tests/requirements.txt
    - pytest
```

## Troubleshooting

### Hypothesis generates too many examples
If tests are slow, you can temporarily reduce iterations:
```python
@settings(max_examples=10)  # Reduce from default 100
```

### Tests fail due to missing Terraform files
Ensure you're running tests from the project root directory where the `terraform/` directory exists.

### Import errors
Make sure all dependencies are installed:
```bash
pip install -r requirements.txt
```
