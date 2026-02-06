# Terraform Actions GCP Patching Prototype

Automated VM patching workflow using Terraform Actions, GCP OS Config, and Ansible Automation Platform (AAP).

## Overview

This prototype demonstrates Day 2 operations automation by integrating:
- **HCP Terraform** - Infrastructure provisioning and state management
- **Terraform Actions** - Automated workflow triggers for Day 2 operations
- **GCP OS Config** - Native patch management for Ubuntu VMs
- **Ansible Automation Platform** - Configuration management and patching orchestration
- **HashiCorp Vault** - Secure credential management

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  HCP Terraform  │────▶│ Terraform Actions│────▶│      AAP        │
│   (Provision)   │     │  (Day 2 Trigger) │     │  (Execute Job)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                                                 │
         │                                                 │
         ▼                                                 ▼
┌─────────────────┐                              ┌─────────────────┐
│   GCP VMs       │◀─────────────────────────────│  Ansible        │
│   (Ubuntu)      │      SSH Connection          │  Playbook       │
└─────────────────┘                              └─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│  OS Config      │
│  (Patching)     │
└─────────────────┘
```

## Quick Start

### Prerequisites

Install required tools:
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads) (>= 1.7.0)
- [Vault CLI](https://www.vaultproject.io/downloads)
- [Task](https://taskfile.dev/installation/)
- Python 3.8+

Check prerequisites:
```bash
task check-prereqs
```

### Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd tf-actions-aap-gcp
```

2. **Configure environment variables**
```bash
export PROJECT_ID="your-gcp-project-id"
export VAULT_ADDR="https://your-vault-cluster.vault.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"  # For HCP Vault
```

3. **Run automated setup**
```bash
# Setup GCP service account with required permissions
task gcp-setup

# Create service account key and store in Vault
task gcp-create-key

# Setup AAP and SSH credentials in Vault (interactive)
task vault-setup

# Verify all secrets are configured
task vault-verify

# Initialize Terraform
task tf-init
```

4. **Configure HCP Terraform workspace**

Go to your HCP Terraform workspace and add these variables:

**Terraform Variables:**
- `vault_addr` = Your Vault URL
- `aap_api_url` = Your AAP API URL (e.g., `https://your-aap.com/api/controller/v2`)
- `aap_job_template_id` = Your AAP job template ID
- `gcp_project_id` = Your GCP project ID

**Environment Variables:**
- `VAULT_TOKEN` = Your Vault token (mark as sensitive)
- `VAULT_NAMESPACE` = `admin` (for HCP Vault, mark as sensitive)

5. **Deploy infrastructure**
```bash
# Validate configuration
task tf-validate

# Commit and push (triggers HCP Terraform run)
git add .
git commit -m "Initial deployment"
git push origin main
```

6. **Monitor deployment**

Go to your HCP Terraform workspace to review and approve the plan:
```
https://app.terraform.io/app/<your-org>/workspaces/<workspace-name>
```

## Available Tasks

View all available tasks:
```bash
task --list
```

### Common Tasks

**Setup & Configuration:**
- `task setup` - Complete automated setup
- `task gcp-setup` - Configure GCP service account
- `task gcp-create-key` - Create and store service account key
- `task vault-setup` - Interactive Vault configuration guide
- `task vault-verify` - Verify all Vault secrets

**Terraform Operations:**
- `task tf-init` - Initialize Terraform
- `task tf-validate` - Validate configuration
- `task tf-fmt` - Format Terraform files
- `task tf-plan` - Run Terraform plan
- `task tf-apply` - Instructions for applying via HCP Terraform

**Testing:**
- `task test` - Run all tests
- `task test-terraform` - Validate Terraform
- `task test-ansible` - Validate Ansible playbooks
- `task test-python` - Run property-based tests

**Cleanup:**
- `task clean` - Clean temporary files
- `task tf-destroy` - Destroy infrastructure (via HCP Terraform)

## Project Structure

```
.
├── terraform/              # Terraform configuration
│   ├── main.tf            # Main infrastructure resources
│   ├── actions.tf         # Terraform Actions configuration
│   ├── variables.tf       # Variable definitions
│   ├── outputs.tf         # Output values
│   └── versions.tf        # Provider configuration
├── ansible/               # Ansible playbooks
│   └── gcp_vm_patching.yml
├── docs/                  # Documentation
│   ├── AUTOMATED_SETUP.md # Automated setup guide
│   ├── GCP_SETUP.md       # GCP configuration
│   ├── AAP_SETUP.md       # AAP configuration
│   └── DEMO_WORKFLOW.md   # Demo walkthrough
├── tests/                 # Test suite
│   ├── test_*.py          # Property-based tests
│   ├── validate_*.sh      # Validation scripts
│   └── requirements.txt   # Python dependencies
├── Taskfile.yml           # Task automation
└── README.md              # This file
```

## Configuration

### Terraform Variables

Copy and customize the example file:
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Key variables:
- `gcp_project_id` - Your GCP project ID
- `gcp_region` - GCP region (default: us-central1)
- `vm_count` - Number of VMs to provision (default: 2)
- `vault_addr` - Vault server URL
- `aap_api_url` - AAP API endpoint
- `aap_job_template_id` - AAP job template ID

### Vault Secrets

Required secrets in Vault:

1. **GCP Service Account** (`secret/gcp/service-account`)
   - Full service account JSON key

2. **AAP API Token** (`secret/aap/api-token`)
   - `token`: AAP API token

3. **SSH Keys** (`secret/ssh/ubuntu-key`)
   - `private_key`: SSH private key
   - `public_key`: SSH public key

## Workflow

### 1. Provision Infrastructure
```bash
git add .
git commit -m "Deploy infrastructure"
git push origin main
```

HCP Terraform automatically triggers a run when changes are pushed.

### 2. Trigger Patching via Terraform Actions

Terraform Actions automatically triggers AAP job templates for Day 2 operations like patching.

### 3. Monitor Execution

- **HCP Terraform**: Monitor infrastructure changes
- **AAP**: Monitor job execution and playbook runs
- **GCP Console**: View VM status and patch compliance

## Testing

Run the complete test suite:
```bash
task test
```

Individual test suites:
```bash
task test-terraform  # Terraform validation
task test-ansible    # Ansible syntax check
task test-python     # Property-based tests
```

## Documentation

Detailed documentation:
- [Automated Setup Guide](docs/AUTOMATED_SETUP.md) - Complete setup walkthrough
- [GCP Setup](docs/GCP_SETUP.md) - GCP configuration details
- [AAP Setup](docs/AAP_SETUP.md) - AAP configuration details
- [Demo Workflow](docs/DEMO_WORKFLOW.md) - Step-by-step demo

## Troubleshooting

### Common Issues

**1. Vault connection errors**
```bash
# Verify Vault connectivity
vault status

# Check environment variables
echo $VAULT_ADDR
echo $VAULT_TOKEN
```

**2. GCP permission errors**
```bash
# Verify service account roles
task gcp-setup
```

**3. Terraform state issues**
```bash
# Reinitialize Terraform
task tf-clean
task tf-init
```

**4. HCP Terraform VCS connection**

If you see "Apply not allowed for workspaces with a VCS connection":
- Commit and push your changes
- HCP Terraform will automatically trigger a run
- Review and approve in the HCP Terraform UI

## Security

- All credentials stored in HashiCorp Vault
- Service accounts follow principle of least privilege
- No plaintext credentials in code or configuration
- Firewall rules restrict access to SSH only
- Regular security audits via property-based tests

## Contributing

1. Create a feature branch
2. Make changes
3. Run tests: `task test`
4. Format code: `task tf-fmt`
5. Commit and push
6. Create pull request

## License

[Your License Here]

## Support

For issues and questions:
- Check [documentation](docs/)
- Review [troubleshooting](#troubleshooting)
- Open an issue in the repository
