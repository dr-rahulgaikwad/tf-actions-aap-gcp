# Automated Setup Guide

This guide walks through the complete automated setup process using the Taskfile automation.

## Prerequisites

### Required Tools

Install these tools before starting:

1. **gcloud CLI** - Google Cloud SDK
   ```bash
   # macOS
   brew install google-cloud-sdk
   
   # Or download from: https://cloud.google.com/sdk/docs/install
   ```

2. **Terraform** (>= 1.7.0)
   ```bash
   # macOS
   brew install terraform
   
   # Or download from: https://www.terraform.io/downloads
   ```

3. **Vault CLI** - HashiCorp Vault
   ```bash
   # macOS
   brew install vault
   
   # Or download from: https://www.vaultproject.io/downloads
   ```

4. **Task** - Task runner
   ```bash
   # macOS
   brew install go-task/tap/go-task
   
   # Or see: https://taskfile.dev/installation/
   ```

5. **Python 3.8+**
   ```bash
   # macOS (usually pre-installed)
   python3 --version
   ```

### Verify Prerequisites

Check all tools are installed:
```bash
task check-prereqs
```

Expected output:
```
Checking prerequisites...
  gcloud: ✓
  terraform: ✓
  vault: ✓
  python3: ✓
  git: ✓
```

## Setup Process

### Step 1: Environment Configuration

Set required environment variables:

```bash
# GCP Project ID
export PROJECT_ID="your-gcp-project-id"

# Vault Configuration
export VAULT_ADDR="https://your-vault-cluster.vault.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"  # For HCP Vault
```

Add to your shell profile for persistence:
```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export PROJECT_ID="your-gcp-project-id"' >> ~/.zshrc
echo 'export VAULT_ADDR="https://your-vault.vault.hashicorp.cloud:8200"' >> ~/.zshrc
echo 'export VAULT_TOKEN="your-vault-token"' >> ~/.zshrc
echo 'export VAULT_NAMESPACE="admin"' >> ~/.zshrc
```

### Step 2: GCP Service Account Setup

Automated GCP service account configuration:

```bash
# Create service account and grant required permissions
task gcp-setup
```

This task:
- Enables required GCP APIs (Compute, OS Config, IAM)
- Creates `terraform-automation` service account
- Grants required IAM roles:
  - `roles/compute.instanceAdmin.v1`
  - `roles/compute.networkAdmin`
  - `roles/compute.securityAdmin`
  - `roles/osconfig.patchDeploymentAdmin`
  - `roles/iam.serviceAccountUser`

### Step 3: Service Account Key Creation

Create and store the service account key in Vault:

```bash
# Create key and store in Vault automatically
task gcp-create-key
```

This task:
- Creates a new service account key
- Stores it in Vault at `secret/gcp/service-account`
- Verifies the secret was stored correctly
- Deletes the local key file for security

### Step 4: AAP and SSH Credentials

#### Generate SSH Keys

```bash
# Generate SSH key pair for VM access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu-patching -N ''
```

#### Store Credentials in Vault

```bash
# AAP API Token
vault kv put secret/aap/api-token token="YOUR_AAP_API_TOKEN"

# SSH Keys
vault kv put secret/ssh/ubuntu-key \
  private_key=@~/.ssh/ubuntu-patching \
  public_key=@~/.ssh/ubuntu-patching.pub
```

#### Verify All Secrets

```bash
# Verify all Vault secrets are configured
task vault-verify
```

Expected output:
```
=== Verifying Vault Secrets ===

1. GCP Service Account:
  project_id: your-gcp-project-id
  client_email: terraform-automation@...

2. AAP API Token:
  token: ***

3. SSH Keys:
  private_key: -----BEGIN OPENSSH PRIVATE KEY-----
  public_key: ssh-rsa AAAAB3...
```

### Step 5: HCP Terraform Workspace Configuration

Configure your HCP Terraform workspace variables:

1. Go to your workspace: `https://app.terraform.io/app/<org>/<workspace>/variables`

2. Add **Terraform Variables**:
   - `vault_addr` = `https://your-vault.vault.hashicorp.cloud:8200`
   - `aap_api_url` = `https://your-aap.com/api/controller/v2`
   - `aap_job_template_id` = `<your-template-id>`
   - `gcp_project_id` = `your-gcp-project-id`

3. Add **Environment Variables**:
   - `VAULT_TOKEN` = `your-vault-token` (mark as sensitive)
   - `VAULT_NAMESPACE` = `admin` (mark as sensitive, for HCP Vault)

### Step 6: Terraform Initialization

Initialize Terraform:

```bash
task tf-init
```

### Step 7: Validate Configuration

Validate the Terraform configuration:

```bash
task tf-validate
```

### Step 8: Deploy Infrastructure

Since you're using HCP Terraform with VCS connection:

```bash
# Commit and push changes
git add .
git commit -m "Initial infrastructure deployment"
git push origin main
```

HCP Terraform will automatically:
1. Detect the push
2. Trigger a plan
3. Wait for your approval
4. Apply the changes

Monitor the run:
```
https://app.terraform.io/app/<org>/<workspace>
```

## Complete Setup Command

Run the entire setup process:

```bash
task setup
```

This runs:
1. `task check-prereqs` - Verify tools
2. `task gcp-setup` - Configure GCP
3. `task gcp-create-key` - Create and store key
4. `task vault-setup` - Guide for AAP/SSH secrets
5. `task tf-init` - Initialize Terraform

## Verification

### Verify GCP Resources

```bash
# List service accounts
gcloud iam service-accounts list

# Check IAM roles
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:terraform-automation@*"
```

### Verify Vault Secrets

```bash
task vault-verify
```

### Verify Terraform

```bash
# Validate configuration
task tf-validate

# Check formatting
task tf-fmt
```

## Troubleshooting

### GCP Authentication Issues

```bash
# Login to gcloud
gcloud auth login

# Set project
gcloud config set project $PROJECT_ID

# Verify authentication
gcloud auth list
```

### Vault Connection Issues

```bash
# Check Vault status
vault status

# Test authentication
vault token lookup

# List secrets
vault kv list secret/
```

### Permission Errors

If you see permission errors during `task gcp-setup`:

```bash
# Ensure you have Owner or Editor role
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:$(gcloud config get-value account)"
```

### HCP Terraform Issues

If HCP Terraform doesn't trigger automatically:

1. Check VCS connection in workspace settings
2. Verify webhook is configured in your Git repository
3. Manually trigger a run from the UI

## Next Steps

After successful setup:

1. **Review the deployment**
   - Check HCP Terraform run logs
   - Verify VMs are created in GCP Console
   - Confirm firewall rules are in place

2. **Test the workflow**
   - Follow [Demo Workflow](DEMO_WORKFLOW.md)
   - Trigger Terraform Actions
   - Monitor AAP job execution

3. **Run tests**
   ```bash
   task test
   ```

4. **Explore documentation**
   - [GCP Setup Details](GCP_SETUP.md)
   - [AAP Configuration](AAP_SETUP.md)
   - [Demo Walkthrough](DEMO_WORKFLOW.md)

## Cleanup

To destroy all resources:

```bash
# Via HCP Terraform UI
task tf-destroy

# Follow the instructions to queue a destroy plan
```

## Security Best Practices

1. **Never commit secrets**
   - All secrets in Vault
   - `terraform.tfvars` is gitignored
   - Service account keys deleted after storing

2. **Rotate credentials regularly**
   ```bash
   # Create new service account key
   task gcp-create-key
   ```

3. **Use least privilege**
   - Service accounts have minimal required permissions
   - Review IAM roles periodically

4. **Enable audit logging**
   - GCP Cloud Audit Logs
   - Vault audit logs
   - HCP Terraform run history

## Support

For issues:
1. Check this guide
2. Review [troubleshooting](#troubleshooting)
3. Check [main README](../README.md)
4. Open an issue in the repository
