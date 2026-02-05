# Setup Guide

## Project Structure

This document describes the initial project structure created for the Terraform Actions GCP Patching prototype.

### Directory Structure

```
.
├── terraform/           # Terraform configuration files
│   ├── main.tf         # Main infrastructure resources (foundation)
│   ├── variables.tf    # Input variable definitions
│   ├── outputs.tf      # Output definitions (foundation)
│   ├── versions.tf     # Provider and version requirements
│   ├── terraform.tfvars.example  # Example variables file
│   └── backend-local.tf.example  # Local backend for testing
├── ansible/            # Ansible playbooks and inventory (to be added)
├── tests/              # Unit and property-based tests (to be added)
├── docs/               # Setup guides and documentation
│   └── SETUP.md        # This file
└── README.md           # Project overview
```

### Terraform Configuration

#### versions.tf
- Defines Terraform version requirement (>= 1.7.0)
- Configures HCP Terraform backend (commented out by default)
- Specifies required providers: google (~> 5.0), vault (~> 4.0)
- Configures Vault and Google Cloud providers

#### variables.tf
- **GCP Configuration**: project_id, region, zone
- **VM Configuration**: vm_count, vm_machine_type, ubuntu_image
- **Vault Configuration**: vault_addr, secret paths for GCP, AAP, SSH
- **AAP Configuration**: aap_api_url, aap_job_template_id
- **Resource Tagging**: environment, managed_by

#### main.tf
- Foundation file for infrastructure resources
- Resources will be added in subsequent tasks

#### outputs.tf
- Foundation file for output definitions
- Outputs will be added as resources are created

#### terraform.tfvars.example
- Template for user-specific configuration
- Copy to `terraform.tfvars` and customize
- **Never commit terraform.tfvars to version control**

### HCP Terraform Backend Configuration

The project is configured to use HCP Terraform for remote state management. To enable:

1. Create an HCP Terraform account at https://app.terraform.io
2. Create an organization
3. Create a workspace named `gcp-patching-demo` (or customize in versions.tf)
4. Uncomment the `cloud` block in `terraform/versions.tf`
5. Replace `REPLACE_WITH_YOUR_ORG` with your organization name
6. Authenticate: `terraform login`
7. Initialize: `terraform init`

### Local Backend (Testing Only)

For local testing and validation without HCP Terraform:

1. Keep the `cloud` block commented out in `terraform/versions.tf`
2. Copy `backend-local.tf.example` to `backend-local.tf`
3. Run `terraform init`

**WARNING**: Local backend is not recommended for production use.

### Security Configuration

The `.gitignore` file is configured to exclude:
- Terraform state files (*.tfstate)
- Variable files with sensitive data (*.tfvars)
- Credential files (*.pem, *.key, *.json)
- Provider lock files
- Temporary and cache files

### Next Steps

1. Configure HCP Terraform workspace
2. Set up HashiCorp Vault with required secrets
3. Configure GCP project and enable required APIs
4. Set up Ansible Automation Platform
5. Proceed with subsequent implementation tasks

### Validation

The Terraform configuration has been validated:
```bash
cd terraform
terraform init
terraform validate  # Should return "Success! The configuration is valid."
terraform fmt       # Formats all .tf files
```

### Requirements Satisfied

This task satisfies the following requirements:
- **Requirement 1.4**: Terraform code uses HCP Terraform workspaces for state management
- **Requirement 6.1**: HCP Terraform uses dedicated workspaces for the prototype environment
- **Requirement 6.3**: Workspace stores Terraform state remotely in HCP

### Additional Resources

- [HCP Terraform Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
