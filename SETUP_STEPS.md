# Complete Setup Steps - Terraform Actions GCP Patching

This document provides the exact steps to set up and run this prototype without any issues.

## Prerequisites

- GCP Project: `hc-4faa1ac49a5e46ecb46cfe87b37`
- HCP Terraform Workspace: `rahul-tfc/tf-actions-aap-gcp`
- HCP Vault: `https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200`
- AAP Sandbox: `https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com/api/controller/v2`

---

## Part 1: GCP Setup (One-Time)

### Step 1: Enable Required APIs

```bash
export PROJECT_ID="hc-4faa1ac49a5e46ecb46cfe87b37"
gcloud config set project $PROJECT_ID

# Enable APIs
gcloud services enable compute.googleapis.com
gcloud services enable osconfig.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

### Step 2: Use Existing Service Account

You already have: `terraform-automation@hc-4faa1ac49a5e46ecb46cfe87b37.iam.gserviceaccount.com`

Grant it the required permissions:

```bash
export SA_EMAIL="terraform-automation@hc-4faa1ac49a5e46ecb46cfe87b37.iam.gserviceaccount.com"

# Grant required IAM roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/osconfig.patchDeploymentAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"
```

### Step 3: Create New Service Account Key

```bash
# Create new key
gcloud iam service-accounts keys create terraform-sa-key.json \
  --iam-account="${SA_EMAIL}"

# This creates a JSON file with the service account credentials
```

### Step 4: Store Key in Vault

```bash
export VAULT_ADDR="https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200"
export VAULT_NAMESPACE="admin"
vault login

# Store the entire JSON file in Vault
vault kv put secret/gcp/service-account @terraform-sa-key.json

# Verify it's stored
vault kv get secret/gcp/service-account

# Delete local key file
rm terraform-sa-key.json
```

**IMPORTANT**: The Terraform code expects the JSON fields to be stored directly in Vault (not under a "key" field). The command above does this correctly.

---

## Part 2: SSH Key Setup (One-Time)

### Step 5: Generate SSH Key Pair

```bash
# Generate SSH key for VM access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu-patching-demo -C "ubuntu" -N ""

# This creates:
# - ~/.ssh/ubuntu-patching-demo (private key)
# - ~/.ssh/ubuntu-patching-demo.pub (public key)
```

### Step 6: Store SSH Keys in Vault

```bash
# Store both keys in Vault
vault kv put secret/ssh/ubuntu-key \
  private_key=@$HOME/.ssh/ubuntu-patching-demo \
  public_key=@$HOME/.ssh/ubuntu-patching-demo.pub

# Verify
vault kv get secret/ssh/ubuntu-key
```

---

## Part 3: AAP Setup (One-Time)

### Step 7: Create AAP Job Template

1. **Log into AAP**: https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com

2. **Create Project** (if not exists):
   - Name: `GCP Patching`
   - SCM Type: `Git`
   - SCM URL: Your repo URL with the ansible playbook
   - Update on Launch: ✓

3. **Create Credential** for SSH:
   - Name: `Ubuntu SSH Key`
   - Type: `Machine`
   - Username: `ubuntu`
   - SSH Private Key: Get from Vault or paste directly
   
4. **Create Job Template**:
   - Name: `GCP VM Patching`
   - Job Type: `Run`
   - Inventory: `Demo Inventory` (or create new)
   - Project: `GCP Patching`
   - Playbook: `ansible/gcp_vm_patching.yml`
   - Credentials: `Ubuntu SSH Key`
   - Variables: Enable "Prompt on launch" ✓
   - Extra Variables: Enable "Prompt on launch" ✓

5. **Note the Job Template ID**:
   - Go to the job template details
   - Look at the URL: `.../templates/job_template/XX/details`
   - The number `XX` is your job template ID

### Step 8: Generate AAP API Token

```bash
# In AAP UI:
# 1. Click your username (top right)
# 2. Go to "Tokens"
# 3. Click "Add"
# 4. Name: "Terraform Actions"
# 5. Scope: "Write"
# 6. Copy the token (you won't see it again!)

# Store in Vault
vault kv put secret/aap/api-token \
  token="<paste-your-token-here>"

# Verify
vault kv get secret/aap/api-token
```

---

## Part 4: HCP Terraform Workspace Configuration

### Step 9: Set Terraform Variables in HCP Terraform

Go to: https://app.terraform.io/app/rahul-tfc/tf-actions-aap-gcp/variables

**Add these Terraform Variables** (Category: Terraform variable):

| Variable Name | Value | Sensitive |
|--------------|-------|-----------|
| `gcp_project_id` | `hc-4faa1ac49a5e46ecb46cfe87b37` | No |
| `gcp_region` | `us-central1` | No |
| `gcp_zone` | `us-central1-a` | No |
| `vault_addr` | `https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200` | No |
| `aap_api_url` | `https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com/api/controller/v2` | No |
| `aap_job_template_id` | `<your-job-template-id>` | No |
| `vm_count` | `2` | No |
| `vm_machine_type` | `e2-medium` | No |
| `environment` | `demo` | No |

**Add these Environment Variables** (Category: Environment variable):

| Variable Name | Value | Sensitive |
|--------------|-------|-----------|
| `VAULT_TOKEN` | `<your-vault-token>` | Yes ✓ |
| `VAULT_NAMESPACE` | `admin` | Yes ✓ |

### Step 10: Verify VCS Connection

1. Go to workspace settings
2. Verify VCS connection is active
3. Verify working directory is set correctly (or empty for root)

---

## Part 5: Deploy Infrastructure

### Step 11: Commit and Push Code

```bash
# Make sure all changes are committed
git add -A
git commit -m "fix: Remove gcp-setup.tf and update patch deployment time"
git push origin main
```

### Step 12: Monitor HCP Terraform Run

1. Go to: https://app.terraform.io/app/rahul-tfc/tf-actions-aap-gcp
2. A new run should trigger automatically
3. Review the plan
4. Click "Confirm & Apply" if plan looks good
5. Wait for apply to complete (~3-5 minutes)

### Step 13: Verify Infrastructure

```bash
# Check outputs in HCP Terraform UI or via CLI
terraform output

# You should see:
# - vm_external_ips
# - vm_instance_ids
# - vm_names
# - action_patch_vms_url
```

---

## Part 6: Test Day 2 Operations

### Step 14: Trigger Terraform Action

**Option A: Via HCP Terraform UI**
1. Go to workspace → Actions tab
2. Find "Patch Ubuntu VMs" action
3. Click "Run Action"
4. Monitor in AAP UI

**Option B: Via API**
```bash
# Get the action URL from Terraform outputs
# Trigger via curl (example - adjust based on your action configuration)
```

### Step 15: Verify Patching

1. **Check AAP Job**:
   - Go to AAP UI → Views → Jobs
   - Find the latest job
   - Verify it completed successfully

2. **SSH to VM** (optional):
   ```bash
   # Get VM IP from Terraform output
   VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')
   
   # SSH using the key
   ssh -i ~/.ssh/ubuntu-patching-demo ubuntu@${VM_IP}
   
   # Check for updates
   sudo apt list --upgradable
   ```

---

## Troubleshooting

### Issue: "Error: Invalid index" on vault credentials

**Cause**: Vault secret structure doesn't match Terraform expectations

**Fix**: The code has been updated to use `jsonencode(data.vault_generic_secret.gcp_credentials.data)` which reads the JSON directly.

Make sure you stored the service account key with:
```bash
vault kv put secret/gcp/service-account @terraform-sa-key.json
```

NOT with:
```bash
vault kv put secret/gcp/service-account key=@terraform-sa-key.json
```

### Issue: "Error 403: The caller does not have permission"

**Cause**: Service account lacks required IAM roles

**Fix**: Run the IAM binding commands from Step 2 again

### Issue: "Error 400: OneTimeSchedule execute time is in the past"

**Cause**: Patch deployment time was set to 2024

**Fix**: Already fixed in code - time is now set to 2026-12-31

### Issue: "Project #XXXXXX has been deleted"

**Cause**: Service account JSON is from an old/deleted project

**Fix**: Create a new service account key (Step 3) and store it in Vault (Step 4)

### Issue: AAP job fails with "Inventory is empty"

**Cause**: Job template not configured to accept extra variables

**Fix**: 
1. Edit job template in AAP
2. Enable "Prompt on launch" for Variables
3. Enable "Prompt on launch" for Extra Variables

---

## Summary

After completing these steps, you should have:

✓ GCP project configured with required APIs and permissions  
✓ Service account with proper IAM roles  
✓ All credentials stored securely in Vault  
✓ SSH keys generated and stored  
✓ AAP job template configured  
✓ HCP Terraform workspace configured  
✓ Infrastructure deployed successfully  
✓ Day 2 operations working via Terraform Actions  

**Total Setup Time**: ~45-60 minutes (first time)  
**Demo Time**: ~15 minutes

---

## Quick Reference

### Key URLs
- **HCP Terraform**: https://app.terraform.io/app/rahul-tfc/tf-actions-aap-gcp
- **HCP Vault**: https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200
- **AAP**: https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com
- **GCP Console**: https://console.cloud.google.com/compute/instances?project=hc-4faa1ac49a5e46ecb46cfe87b37

### Key Commands
```bash
# Check Vault secrets
vault kv get secret/gcp/service-account
vault kv get secret/aap/api-token
vault kv get secret/ssh/ubuntu-key

# Check GCP resources
gcloud compute instances list --project=hc-4faa1ac49a5e46ecb46cfe87b37

# Check Terraform state
terraform show
terraform output
```
