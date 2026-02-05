# GCP Project Setup Guide

This guide walks you through setting up a Google Cloud Platform (GCP) project for the Terraform Actions GCP Patching prototype.

## Prerequisites

- Google Cloud Platform account
- `gcloud` CLI installed and configured
- Project Owner or Editor role in your GCP organization
- Billing account linked to your project

## Overview

This setup guide covers:
1. Creating or selecting a GCP project
2. Enabling required APIs
3. Creating a service account for Terraform
4. Granting IAM permissions
5. Generating and storing service account keys in Vault
6. Configuring networking (using default VPC)

## Step 1: Create or Select a GCP Project

### Option A: Create a New Project

```bash
# Set your project ID (must be globally unique)
export PROJECT_ID="terraform-actions-demo-$(date +%s)"

# Create the project
gcloud projects create ${PROJECT_ID} \
  --name="Terraform Actions Demo" \
  --set-as-default

# Link billing account (replace with your billing account ID)
export BILLING_ACCOUNT_ID="YOUR-BILLING-ACCOUNT-ID"
gcloud billing projects link ${PROJECT_ID} \
  --billing-account=${BILLING_ACCOUNT_ID}
```

### Option B: Use an Existing Project

```bash
# Set your existing project ID
export PROJECT_ID="your-existing-project-id"

# Set as default project
gcloud config set project ${PROJECT_ID}
```

## Step 2: Enable Required APIs

The prototype requires the following GCP APIs:

```bash
# Enable Compute Engine API (for VM provisioning)
gcloud services enable compute.googleapis.com --project=${PROJECT_ID}

# Enable OS Config API (for patch management)
gcloud services enable osconfig.googleapis.com --project=${PROJECT_ID}

# Enable IAM API (for service account management)
gcloud services enable iam.googleapis.com --project=${PROJECT_ID}

# Enable Cloud Resource Manager API (for project management)
gcloud services enable cloudresourcemanager.googleapis.com --project=${PROJECT_ID}

# Verify APIs are enabled
gcloud services list --enabled --project=${PROJECT_ID}
```

**Expected Output:**
```
NAME                              TITLE
compute.googleapis.com            Compute Engine API
osconfig.googleapis.com           OS Config API
iam.googleapis.com                Identity and Access Management (IAM) API
cloudresourcemanager.googleapis.com  Cloud Resource Manager API
```

## Step 3: Create Service Account for Terraform

Create a dedicated service account for Terraform to use when provisioning infrastructure:

```bash
# Set service account name
export SA_NAME="terraform-automation"
export SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create service account
gcloud iam service-accounts create ${SA_NAME} \
  --display-name="Terraform Automation Service Account" \
  --description="Service account for Terraform to provision and manage GCP resources" \
  --project=${PROJECT_ID}

# Verify service account was created
gcloud iam service-accounts list --project=${PROJECT_ID}
```

## Step 4: Grant IAM Permissions

Grant the minimum required IAM roles to the Terraform service account following the principle of least privilege:

```bash
# Grant Compute Instance Admin role (for VM management)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.instanceAdmin.v1"

# Grant Compute Network Admin role (for firewall rules)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.networkAdmin"

# Grant OS Config Patch Deployment Admin role (for patch management)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/osconfig.patchDeploymentAdmin"

# Grant Service Account User role (for attaching service accounts to VMs)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

# Verify IAM bindings
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${SA_EMAIL}"
```

### IAM Roles Explained

| Role | Purpose | Permissions |
|------|---------|-------------|
| `roles/compute.instanceAdmin.v1` | VM Management | Create, modify, delete VM instances |
| `roles/compute.networkAdmin` | Network Management | Create firewall rules, manage VPC networks |
| `roles/osconfig.patchDeploymentAdmin` | Patch Management | Create and manage OS Config patch deployments |
| `roles/iam.serviceAccountUser` | Service Account Usage | Attach service accounts to VM instances |

## Step 5: Generate Service Account Key

Generate a JSON key file for the service account:

```bash
# Create keys directory (local only, never commit)
mkdir -p ~/.gcp-keys

# Generate service account key
gcloud iam service-accounts keys create \
  ~/.gcp-keys/${PROJECT_ID}-terraform-sa-key.json \
  --iam-account=${SA_EMAIL} \
  --project=${PROJECT_ID}

# Verify key was created
ls -lh ~/.gcp-keys/${PROJECT_ID}-terraform-sa-key.json
```

**⚠️ SECURITY WARNING:**
- Never commit this key file to version control
- Store it securely in HashiCorp Vault (see Step 6)
- Rotate keys regularly (every 90 days recommended)
- Delete local copy after storing in Vault

## Step 6: Store Service Account Key in Vault

Store the service account key in HashiCorp Vault for secure credential management:

```bash
# Set Vault address and authenticate
export VAULT_ADDR="https://vault.example.com:8200"
vault login

# Store GCP service account key in Vault
vault kv put secret/gcp/service-account \
  key=@~/.gcp-keys/${PROJECT_ID}-terraform-sa-key.json \
  project_id=${PROJECT_ID}

# Verify secret was stored
vault kv get secret/gcp/service-account

# Delete local key file (now stored securely in Vault)
rm ~/.gcp-keys/${PROJECT_ID}-terraform-sa-key.json
```

**Vault Secret Structure:**
```json
{
  "key": "{...service account JSON key...}",
  "project_id": "your-project-id"
}
```

## Step 7: Configure Networking

This prototype uses the default VPC network for simplicity. No additional network configuration is required.

### Verify Default Network

```bash
# Check default network exists
gcloud compute networks describe default --project=${PROJECT_ID}

# List existing firewall rules
gcloud compute firewall-rules list --project=${PROJECT_ID}
```

The Terraform configuration will create a custom firewall rule for SSH access to the demo VMs.

### Network Architecture

```
Default VPC Network (10.128.0.0/9)
├── Subnet: default (auto-created per region)
├── Firewall: allow-ssh-patching-demo (created by Terraform)
│   ├── Protocol: TCP
│   ├── Port: 22
│   └── Target: VMs with 'ssh-access' tag
└── VMs: ubuntu-vm-1, ubuntu-vm-2 (created by Terraform)
```

## Step 8: Verify Setup

Run these commands to verify your GCP project is configured correctly:

```bash
# Verify project configuration
gcloud config list

# Verify APIs are enabled
gcloud services list --enabled --project=${PROJECT_ID} | grep -E "(compute|osconfig)"

# Verify service account exists
gcloud iam service-accounts describe ${SA_EMAIL} --project=${PROJECT_ID}

# Verify IAM permissions
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${SA_EMAIL}"

# Verify Vault secret exists
vault kv get secret/gcp/service-account
```

**Expected Results:**
- ✅ Project is set as default
- ✅ Compute Engine and OS Config APIs are enabled
- ✅ Service account exists with correct email
- ✅ Service account has 4 IAM role bindings
- ✅ Service account key is stored in Vault

## Step 9: Configure Terraform Variables

Update your `terraform.tfvars` file with the GCP project details:

```hcl
# GCP Project Configuration
gcp_project_id = "your-project-id"  # Use ${PROJECT_ID}
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# Vault Configuration
vault_addr            = "https://vault.example.com:8200"
vault_gcp_secret_path = "secret/gcp/service-account"
```

## Troubleshooting

### Issue: API Not Enabled Error

**Error:**
```
Error: Error creating instance: googleapi: Error 403: Compute Engine API has not been used
```

**Solution:**
```bash
gcloud services enable compute.googleapis.com --project=${PROJECT_ID}
```

### Issue: Permission Denied Error

**Error:**
```
Error: Error creating instance: googleapi: Error 403: Required 'compute.instances.create' permission
```

**Solution:**
Verify IAM roles are granted:
```bash
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${SA_EMAIL}"
```

### Issue: Quota Exceeded Error

**Error:**
```
Error: Error creating instance: Quota 'CPUS' exceeded. Limit: 8.0 in region us-central1
```

**Solution:**
Request quota increase or use a different region:
```bash
# Check current quotas
gcloud compute project-info describe --project=${PROJECT_ID}

# Request quota increase via GCP Console
# https://console.cloud.google.com/iam-admin/quotas
```

### Issue: Vault Connection Error

**Error:**
```
Error: Error making API request to Vault
```

**Solution:**
```bash
# Verify Vault address
echo $VAULT_ADDR

# Test Vault connectivity
vault status

# Re-authenticate
vault login
```

## Security Best Practices

1. **Service Account Keys:**
   - Rotate keys every 90 days
   - Never commit keys to version control
   - Store keys only in Vault
   - Use short-lived tokens when possible

2. **IAM Permissions:**
   - Follow principle of least privilege
   - Regularly audit IAM bindings
   - Remove unused service accounts
   - Enable audit logging

3. **Network Security:**
   - Restrict SSH source ranges in production
   - Use VPC Service Controls for sensitive workloads
   - Enable VPC Flow Logs for monitoring
   - Use Cloud Armor for DDoS protection

4. **Monitoring:**
   - Enable Cloud Audit Logs
   - Set up alerts for IAM changes
   - Monitor service account key usage
   - Review security findings regularly

## Next Steps

After completing this GCP setup:

1. ✅ GCP project configured with required APIs
2. ✅ Service account created with minimal IAM permissions
3. ✅ Service account key stored in Vault
4. ➡️ **Next:** [AAP Setup Guide](AAP_SETUP.md)
5. ➡️ **Next:** [HCP Terraform Workspace Setup](HCP_TERRAFORM_SETUP.md)

## Additional Resources

- [GCP IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)
- [GCP Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
- [GCP Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [GCP OS Config Documentation](https://cloud.google.com/compute/docs/os-config-management)
- [HashiCorp Vault GCP Secrets Engine](https://www.vaultproject.io/docs/secrets/gcp)

## Requirements Satisfied

This guide satisfies the following requirements:
- **Requirement 7.1:** GCP Project has Compute Engine API enabled
- **Requirement 7.2:** GCP Project has OS Config API enabled
- **Requirement 7.3:** Service accounts granted minimum required permissions
- **Requirement 7.4:** GCP Project has appropriate IAM bindings for Terraform automation
- **Requirement 9.2:** Documentation provides high-level GCP project setup steps
