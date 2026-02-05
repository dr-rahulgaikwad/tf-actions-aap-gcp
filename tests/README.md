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

## Continuous Integration

These tests should be run:
- On every commit (syntax and unit tests)
- On every pull request (all tests including property tests)
- Before deployment (full test suite with integration tests)

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
