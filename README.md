# Terraform Actions GCP Patching Prototype

A demonstration of HashiCorp's Terraform Actions feature for Day 2 operations management, integrating HCP Terraform with Ansible Automation Platform (AAP) to automate OS patching on GCP Ubuntu VMs.

## Overview

This prototype showcases modern infrastructure lifecycle management:
- **Day 0/1**: Provision Ubuntu VMs on GCP using Terraform
- **Day 2**: Trigger Ansible playbooks via Terraform Actions for OS patching

## Architecture

The system integrates three key platforms:
1. **HCP Terraform** - Infrastructure orchestration and state management
2. **Google Cloud Platform** - VM hosting and OS patch management
3. **Ansible Automation Platform** - Configuration management and patching automation

All credentials are managed securely through HashiCorp Vault Enterprise.

## Project Structure

```
.
├── terraform/           # Terraform configuration files
│   ├── main.tf         # Main infrastructure resources
│   ├── variables.tf    # Input variable definitions
│   ├── outputs.tf      # Output definitions
│   ├── versions.tf     # Provider and version requirements
│   └── terraform.tfvars.example  # Example variables file
├── ansible/            # Ansible playbooks and inventory
├── tests/              # Unit and property-based tests
├── docs/               # Setup guides and documentation
└── README.md           # This file
```

## Prerequisites

- HCP Terraform account with workspace configured
- GCP project with Compute Engine and OS Config APIs enabled
- Ansible Automation Platform instance
- HashiCorp Vault Enterprise for credential management
- Terraform >= 1.7.0
- Ansible >= 2.14

## Quick Start

1. **Configure HCP Terraform Workspace**
   - Create workspace in HCP Terraform
   - Configure Vault integration
   - Set required environment variables

2. **Set Up Credentials in Vault**
   - Store GCP service account key
   - Store AAP API token
   - Store SSH private key

3. **Configure Variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Trigger Day 2 Operations**
   - Use HCP Terraform UI or API to trigger Terraform Actions
   - Monitor AAP job execution

## Documentation

Detailed setup guides will be available in the `docs/` directory:
- GCP Project Setup Guide
- AAP Configuration Guide
- HCP Terraform Workspace Setup Guide
- Demonstration Workflow Guide

## Security

- All credentials stored in HashiCorp Vault
- No plaintext credentials in code or version control
- Least privilege IAM permissions
- Service account authentication for all integrations

## Testing

The project includes comprehensive testing:
- Unit tests for specific scenarios
- Property-based tests for universal correctness
- Integration tests for end-to-end workflows

Run tests:
```bash
# Terraform validation
terraform validate
terraform fmt -check

# Ansible validation
ansible-playbook --syntax-check ansible/*.yml
ansible-lint ansible/

# Property-based tests
pytest tests/
```

## License

This is a prototype for demonstration purposes.

## Support

For issues or questions, please refer to the documentation in the `docs/` directory.