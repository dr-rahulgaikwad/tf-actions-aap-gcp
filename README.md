# Terraform Actions GCP Patching

Automated VM patching workflow using Terraform Actions, GCP OS Config, and Ansible Automation Platform.

## Overview

This project demonstrates Day 2 operations automation by integrating:
- **HCP Terraform** - Infrastructure provisioning and state management
- **Terraform Actions** - Automated workflow triggers
- **GCP OS Config** - Native patch management for Ubuntu VMs
- **Ansible Automation Platform** - Configuration management
- **HashiCorp Vault** - Secure credential management

## Architecture

```
HCP Terraform → Terraform Actions → AAP → Ansible Playbook
      ↓                                         ↓
   GCP VMs ←──────────────────────────────────┘
      ↓
  OS Config (Patching)
```

## Quick Start

### Prerequisites

```bash
# Check prerequisites
task check-prereqs
```

Required tools:
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads) >= 1.7.0
- [Vault CLI](https://www.vaultproject.io/downloads)
- [Task](https://taskfile.dev/installation/)
- Python 3.8+

### Setup

1. **Set environment variables**
```bash
export PROJECT_ID="your-gcp-project-id"
export VAULT_ADDR="https://your-vault.vault.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"  # For HCP Vault
```

2. **Run setup tasks**
```bash
# View setup steps
task setup

# Configure GCP service account
task gcp-setup

# Create and store service account key
task gcp-create-key

# Store AAP and SSH credentials (follow prompts)
task vault-setup

# Verify all secrets
task vault-verify

# Initialize Terraform
task tf-init
```

3. **Configure HCP Terraform workspace**

Add these variables in your workspace at `https://app.terraform.io/app/<org>/<workspace>/variables`:

**Terraform Variables:**
- `vault_addr` - Your Vault URL
- `aap_api_url` - AAP API URL (e.g., `https://your-aap.com/api/controller/v2`)
- `aap_job_template_id` - AAP job template ID
- `gcp_project_id` - Your GCP project ID

**Environment Variables:**
- `VAULT_TOKEN` - Your Vault token (sensitive)
- `VAULT_NAMESPACE` - `admin` for HCP Vault (sensitive)

4. **Deploy**
```bash
# Validate configuration
task tf-validate

# Commit and push (triggers HCP Terraform)
git add .
git commit -m "Initial deployment"
git push origin main
```

## Available Tasks

```bash
task --list              # Show all tasks

# Setup
task setup               # View setup steps
task gcp-setup           # Configure GCP service account
task gcp-create-key      # Create and store key in Vault
task vault-setup         # Guide for storing credentials
task vault-verify        # Verify all Vault secrets

# Terraform
task tf-init             # Initialize Terraform
task tf-validate         # Validate and format
task tf-plan             # Run plan (local)
task tf-clean            # Clean temporary files

# Testing
task test                # Run all tests
task test-terraform      # Validate Terraform
task test-ansible        # Validate Ansible
task test-python         # Run property-based tests

# Cleanup
task clean               # Clean all temporary files
```

## Project Structure

```
.
├── terraform/           # Terraform configuration
│   ├── main.tf         # Main infrastructure
│   ├── actions.tf      # Terraform Actions
│   ├── variables.tf    # Variables
│   └── outputs.tf      # Outputs
├── ansible/            # Ansible playbooks
│   └── gcp_vm_patching.yml
├── docs/               # Documentation
│   ├── AUTOMATED_SETUP.md
│   ├── GCP_SETUP.md
│   ├── AAP_SETUP.md
│   └── DEMO_WORKFLOW.md
├── tests/              # Test suite
│   ├── test_*.py       # Property-based tests
│   └── validate_*.sh   # Validation scripts
├── Taskfile.yml        # Task automation
└── README.md           # This file
```

## Configuration

### Terraform Variables

Copy and customize:
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Key variables:
- `gcp_project_id` - GCP project ID
- `gcp_region` - GCP region (default: us-central1)
- `vm_count` - Number of VMs (default: 2)
- `vault_addr` - Vault server URL
- `aap_api_url` - AAP API endpoint
- `aap_job_template_id` - AAP job template ID

### Vault Secrets

Required secrets:

1. **GCP Service Account** (`secret/gcp/service-account`)
   - Full service account JSON key

2. **AAP API Token** (`secret/aap/api-token`)
   - `token`: AAP API token

3. **SSH Keys** (`secret/ssh/ubuntu-key`)
   - `private_key`: SSH private key
   - `public_key`: SSH public key

## Workflow

1. **Provision Infrastructure**
   - Push changes to trigger HCP Terraform run
   - Review and approve plan in HCP Terraform UI

2. **Trigger Patching**
   - Terraform Actions automatically triggers AAP job templates

3. **Monitor**
   - HCP Terraform: Infrastructure changes
   - AAP: Job execution
   - GCP Console: VM status and patch compliance

## Testing

```bash
# Run all tests
task test

# Individual test suites
task test-terraform      # Terraform validation
task test-ansible        # Ansible syntax check
task test-python         # Property-based tests
```

## Documentation

- [Automated Setup Guide](docs/AUTOMATED_SETUP.md) - Complete setup walkthrough
- [GCP Setup](docs/GCP_SETUP.md) - GCP configuration details
- [AAP Setup](docs/AAP_SETUP.md) - AAP configuration details
- [Demo Workflow](docs/DEMO_WORKFLOW.md) - Step-by-step demo

## Troubleshooting

### Vault Connection
```bash
vault status
echo $VAULT_ADDR
echo $VAULT_TOKEN
```

### GCP Permissions
```bash
task gcp-setup
```

### Terraform State
```bash
task tf-clean
task tf-init
```

### HCP Terraform VCS
If you see "Apply not allowed for workspaces with a VCS connection":
- Commit and push changes
- HCP Terraform auto-triggers a run
- Review and approve in UI

## Security

- All credentials stored in Vault
- Service accounts use least privilege
- No plaintext credentials in code
- Firewall rules restrict to SSH only
- Regular security audits via property-based tests

## License

[Your License Here]
