# Automated GCP Setup Guide

This guide explains how to use the automated setup scripts to quickly configure GCP for the Terraform Actions patching prototype.

## Overview

The setup is split into two parts:

1. **Manual Bootstrap** (one-time, ~5 minutes): Enable APIs and create initial service account
2. **Terraform Automation** (repeatable): Create all other resources automatically

## Prerequisites

- GCP account with billing enabled
- `gcloud` CLI installed and configured
- `vault` CLI installed (for credential storage)
- Terraform >= 1.7.0

## Quick Start

### Step 1: Run Bootstrap Script

This script performs the initial GCP setup that cannot be automated in Terraform:

```bash
# Run the bootstrap script
./scripts/bootstrap-gcp.sh

# Follow the prompts:
# - Enter your GCP Project ID
# - Confirm Vault storage (recommended)
```

**What it does:**
- ✅ Enables required GCP APIs (Compute, OS Config, IAM)
- ✅ Creates Terraform service account
- ✅ Grants necessary IAM roles
- ✅ Creates and downloads service account key
- ✅ Stores credentials in Vault (optional)
- ✅ Creates default VPC if needed

### Step 2: Update terraform.tfvars

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
vi terraform.tfvars
```

Update these values:
```hcl
gcp_project_id = "your-project-id"  # From bootstrap script
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"
```

### Step 3: Run Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**What Terraform automates:**
- ✅ Creates VPC network
- ✅ Creates firewall rules
- ✅ Creates additional service accounts (Ansible, OS Config)
- ✅ Grants IAM permissions
- ✅ Provisions Ubuntu VMs
- ✅ Configures OS Config patch deployments
- ✅ Sets up Terraform Actions

## Detailed Breakdown

### Manual Bootstrap (scripts/bootstrap-gcp.sh)

**Why manual?**
- Enabling APIs requires Service Usage API (chicken-and-egg)
- Creating the initial service account requires existing permissions
- Cannot be done by Terraform without existing credentials

**What it creates:**
```
Service Account: terraform-patching@PROJECT_ID.iam.gserviceaccount.com
Roles Granted:
  - roles/compute.admin
  - roles/iam.serviceAccountAdmin
  - roles/iam.serviceAccountUser
  - roles/osconfig.patchDeploymentAdmin
  - roles/resourcemanager.projectIamAdmin
  - roles/serviceusage.serviceUsageAdmin

APIs Enabled:
  - compute.googleapis.com
  - osconfig.googleapis.com
  - iam.googleapis.com
  - cloudresourcemanager.googleapis.com
  - serviceusage.googleapis.com
```

### Terraform Automation (terraform/gcp-setup.tf)

**What Terraform creates:**

```
Service Accounts:
  - ansible-patching-sa@PROJECT_ID.iam.gserviceaccount.com
  - osconfig-patching-sa@PROJECT_ID.iam.gserviceaccount.com

IAM Bindings:
  - Ansible SA: compute.viewer, compute.osLogin
  - OS Config SA: osconfig.patchDeploymentAdmin, compute.instanceAdmin.v1

Network Resources:
  - VPC: patching-demo-network (auto-subnet mode)
  - Firewall: allow-ssh-patching-demo (port 22)

Compute Resources:
  - Ubuntu VMs (count: var.vm_count)
  - OS Config patch deployment

Terraform Actions:
  - Action: patch_vms (triggers AAP)
```

## Troubleshooting

### Bootstrap Script Fails

**Error: "gcloud: command not found"**
```bash
# Install gcloud CLI
# macOS:
brew install google-cloud-sdk

# Linux:
curl https://sdk.cloud.google.com | bash

# Verify installation
gcloud version
```

**Error: "API not enabled"**
```bash
# Enable manually in GCP Console
# https://console.cloud.google.com/apis/library

# Or use gcloud
gcloud services enable compute.googleapis.com --project=PROJECT_ID
```

**Error: "Permission denied"**
- You need Owner or Editor role on the GCP project
- Or specific roles: Service Usage Admin, Project IAM Admin

### Terraform Fails

**Error: "Error 403: Required 'compute.networks.get' permission"**
```bash
# Grant additional permissions to Terraform SA
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:terraform-patching@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.networkAdmin"
```

**Error: "Service account key already exists"**
```bash
# List existing keys
gcloud iam service-accounts keys list \
  --iam-account=terraform-patching@PROJECT_ID.iam.gserviceaccount.com

# Delete old key if needed
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=terraform-patching@PROJECT_ID.iam.gserviceaccount.com
```

**Error: "Vault token not set"**
- See [HCP_TERRAFORM_SETUP.md](HCP_TERRAFORM_SETUP.md) for Vault configuration
- Ensure VAULT_TOKEN is set in HCP Terraform workspace

## Manual Setup (Alternative)

If you prefer manual setup without the bootstrap script:

### 1. Enable APIs

```bash
gcloud services enable compute.googleapis.com osconfig.googleapis.com iam.googleapis.com
```

### 2. Create Service Account

```bash
gcloud iam service-accounts create terraform-patching \
  --display-name="Terraform Patching SA"
```

### 3. Grant Roles

```bash
PROJECT_ID="your-project-id"
SA_EMAIL="terraform-patching@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/iam.serviceAccountAdmin"

# ... repeat for other roles
```

### 4. Create Key

```bash
gcloud iam service-accounts keys create ~/gcp-key.json \
  --iam-account=$SA_EMAIL
```

### 5. Store in Vault

```bash
vault kv put secret/gcp/service-account \
  key="$(cat ~/gcp-key.json)" \
  project_id="$PROJECT_ID"
```

## Security Best Practices

1. **Service Account Keys**
   - Store only in Vault, never in code
   - Delete local copies after storing in Vault
   - Rotate keys every 90 days

2. **IAM Permissions**
   - Use least privilege principle
   - Separate service accounts for different purposes
   - Regularly audit IAM bindings

3. **Network Security**
   - Restrict SSH source ranges in production
   - Use Cloud NAT for outbound traffic
   - Enable VPC Flow Logs for monitoring

4. **Credential Rotation**
   ```bash
   # Rotate service account key
   ./scripts/rotate-gcp-key.sh
   ```

## Cost Estimation

Running this prototype costs approximately:

```
2x e2-medium VMs (730 hours/month):  ~$50/month
40 GB standard persistent disk:      ~$2/month
Egress traffic (minimal):            ~$1/month
Total:                               ~$53/month
```

To minimize costs:
- Destroy resources when not in use: `terraform destroy`
- Use preemptible VMs (not covered in this demo)
- Use smaller machine types for testing

## Next Steps

After automated setup is complete:

1. ✅ Configure AAP (see [AAP_SETUP.md](AAP_SETUP.md))
2. ✅ Set up HCP Terraform workspace (see [HCP_TERRAFORM_SETUP.md](HCP_TERRAFORM_SETUP.md))
3. ✅ Run the demo workflow (see [DEMO_WORKFLOW.md](DEMO_WORKFLOW.md))

## Support

For issues or questions:
- Check [GCP_SETUP.md](GCP_SETUP.md) for detailed manual setup
- Review Terraform logs: `terraform plan -out=plan.out`
- Check GCP Console for resource status
- Verify IAM permissions in GCP Console

---

**Document Version**: 1.0  
**Last Updated**: 2024-02-06  
**Maintained By**: Platform Engineering Team
