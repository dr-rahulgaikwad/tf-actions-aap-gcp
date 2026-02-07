# HCP Terraform Project and Workspace Setup

This directory contains Terraform code to automatically create and configure the HCP Terraform project, workspace, and variables needed for this demo.

## Prerequisites

1. **HCP Terraform Account** with organization access
2. **TFE Token** with permissions to create projects and workspaces
3. **GitHub OAuth Connection** configured in HCP Terraform

## Setup Steps

### 1. Get TFE OAuth Token ID

1. Go to HCP Terraform → Settings → Version Control
2. Find your GitHub OAuth connection
3. Note the OAuth Token ID (format: `ot-xxxxxxxxxxxxx`)

### 2. Set Environment Variables

```bash
export TFE_TOKEN="your-tfe-token"
```

### 3. Create terraform.tfvars

Create a `terraform.tfvars` file in the root directory:

```hcl
# TFC Configuration
tfc_oauth_token_id = "ot-xxxxxxxxxxxxx"
tfc_organization   = "rahul-tfc"
github_repo        = "your-github-org/tf-actions-aap-gcp"

# Vault Configuration
vault_addr      = "https://your-vault-cluster.vault.hashicorp.cloud:8200"
vault_token     = "hvs.xxxxxxxxxxxxx"
vault_namespace = "admin"

# AAP Configuration
aap_hostname        = "https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com"
aap_job_template_id = 10

# GCP Configuration
gcp_project_id = "your-gcp-project-id"
```

### 4. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## What Gets Created

1. **HCP Terraform Project**: `terraform-actions-aap-gcp`
2. **HCP Terraform Workspace**: `tf-actions-aap-gcp`
   - VCS connection to GitHub repository
   - Working directory: `terraform`
   - Auto-apply: disabled (manual approval required)

3. **Terraform Variables** (in workspace):
   - `vault_addr`
   - `aap_hostname`
   - `aap_job_template_id`
   - `gcp_project_id`

4. **Environment Variables** (in workspace):
   - `VAULT_TOKEN` (sensitive)
   - `VAULT_NAMESPACE`
   - `AAP_INSECURE_SKIP_VERIFY`

## Outputs

After applying, you'll get:
- `tfc_project_id`: The project ID
- `tfc_workspace_id`: The workspace ID
- `tfc_workspace_url`: Direct URL to the workspace

## Notes

- The workspace is configured with VCS-driven workflow
- All sensitive variables are marked as sensitive
- The workspace uses the `terraform/` directory as the working directory
- Auto-apply is disabled for safety

## Cleanup

To destroy the TFC resources:

```bash
terraform destroy
```

**Warning**: This will delete the project, workspace, and all variables. The infrastructure managed by the workspace will NOT be destroyed.
