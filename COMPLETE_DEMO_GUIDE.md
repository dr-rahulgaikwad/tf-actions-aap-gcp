# Complete End-to-End Demo Guide

**Purpose**: Demonstrate Terraform Actions triggering Ansible Automation Platform for VM patching  
**Duration**: 30-45 minutes  
**Audience**: Conference talk - "From IaC to InfraOps"

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [One-Time Setup](#one-time-setup)
3. [Demo Execution](#demo-execution)
4. [Troubleshooting](#troubleshooting)
5. [Cleanup](#cleanup)

---

## Prerequisites

### Required Accounts & Access

- ✅ GCP Project: `hc-4faa1ac49a5e46ecb46cfe87b37`
- ✅ HCP Terraform Workspace: `rahul-tfc/tf-actions-aap-gcp`
- ✅ HCP Vault Cluster: `vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud`
- ✅ AAP Sandbox: `https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com`

### Required Tools

```bash
# Verify all tools are installed
task check-prereqs

# Expected output:
#   gcloud: ✓
#   terraform: ✓
#   vault: ✓
#   python3: ✓
#   git: ✓
```

---

## One-Time Setup

### Step 1: Environment Variables

```bash
# Set these in your terminal (add to ~/.zshrc for persistence)
export PROJECT_ID="hc-4faa1ac49a5e46ecb46cfe87b37"
export VAULT_ADDR="https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"
```

### Step 2: GCP Service Account Setup

```bash
# Create service account and grant permissions
task gcp-setup

# This will:
# - Enable required GCP APIs
# - Create terraform-automation service account
# - Grant required IAM roles
```

### Step 3: Generate SSH Keys

```bash
# Generate SSH key pair for VM access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu-patching -N ''

# This creates:
# - ~/.ssh/ubuntu-patching (private key)
# - ~/.ssh/ubuntu-patching.pub (public key)
```

### Step 4: Store Credentials in Vault

```bash
# 1. Store GCP service account key
task gcp-create-key

# 2. Store AAP API token
vault kv put secret/aap/api-token token="YOUR_AAP_API_TOKEN"

# 3. Store SSH keys
vault kv put secret/ssh/ubuntu-key \
  private_key=@~/.ssh/ubuntu-patching \
  public_key=@~/.ssh/ubuntu-patching.pub

# 4. Verify all secrets
task vault-verify
```

**Expected Output**:
```
=== Verifying Vault Secrets ===

1. GCP Service Account:
  project_id: hc-4faa1ac49a5e46ecb46cfe87b37
  client_email: terraform-automation@...

2. AAP API Token:
  token: ***

3. SSH Keys:
  private_key: -----BEGIN OPENSSH PRIVATE KEY-----
  public_key: ssh-rsa AAAAB3...
```

### Step 5: Configure AAP (Ansible Automation Platform)

#### 5.1 Login to AAP

1. Open browser: `https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com`
2. Login with your Red Hat Developer Sandbox credentials

#### 5.2 Create Project

1. Navigate to **Resources → Projects**
2. Click **Add** button
3. Fill in details:
   - **Name**: `GCP VM Patching`
   - **Organization**: `Default`
   - **Source Control Type**: `Git`
   - **Source Control URL**: `https://github.com/dr-rahulgaikwad/tf-actions-aap-gcp.git`
   - **Source Control Branch/Tag/Commit**: `main`
   - **Options**: Check ✓ `Update Revision on Launch`
4. Click **Save**
5. Click **Sync** button to sync the project

**Wait for sync to complete** (Status should show "Successful")

#### 5.3 Create Credential for SSH

1. Navigate to **Resources → Credentials**
2. Click **Add** button
3. Fill in details:
   - **Name**: `GCP Ubuntu SSH Key`
   - **Organization**: `Default`
   - **Credential Type**: `Machine`
   - **Username**: `ubuntu`
   - **SSH Private Key**: Paste content from Vault
     ```bash
     # Get private key from Vault
     vault kv get -field=private_key secret/ssh/ubuntu-key
     # Copy the output and paste in AAP
     ```
4. Click **Save**

#### 5.4 Create Inventory

1. Navigate to **Resources → Inventories**
2. Click **Add → Add inventory**
3. Fill in details:
   - **Name**: `GCP VMs`
   - **Organization**: `Default`
   - **Variables**: Leave empty (will be provided by Terraform Actions)
4. Click **Save**

#### 5.5 Create Job Template

1. Navigate to **Resources → Templates**
2. Click **Add → Add job template**
3. Fill in details:
   - **Name**: `GCP VM Patching`
   - **Job Type**: `Run`
   - **Inventory**: Select `GCP VMs`
   - **Project**: Select `GCP VM Patching`
   - **Playbook**: Select `ansible/gcp_vm_patching.yml`
   - **Credentials**: Select `GCP Ubuntu SSH Key`
   - **Variables**: Leave empty
   - **Options**: Check ✓ `Prompt on launch` for **Variables**
4. Click **Save**

#### 5.6 Get Job Template ID

1. In the Templates list, click on **GCP VM Patching**
2. Look at the URL in your browser
3. The ID is the number at the end: `https://.../templates/job_template/123/details`
4. Note this ID (you'll need it for Terraform configuration)

**Example**: If URL is `.../templates/job_template/42/details`, then ID is `42`

#### 5.7 Generate AAP API Token

1. Click on your username (top right)
2. Select **Users**
3. Click on your username
4. Click **Tokens** tab
5. Click **Add** button
6. Fill in details:
   - **Application**: Leave empty
   - **Description**: `Terraform Actions Token`
   - **Scope**: `Write`
7. Click **Save**
8. **IMPORTANT**: Copy the token immediately (it won't be shown again)
9. Store in Vault:
   ```bash
   vault kv put secret/aap/api-token token="YOUR_COPIED_TOKEN"
   ```

### Step 6: Configure HCP Terraform Workspace

1. Go to: `https://app.terraform.io/app/rahul-tfc/workspaces/tf-actions-aap-gcp/variables`

2. Add **Terraform Variables**:
   - `vault_addr` = `https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200`
   - `aap_api_url` = `https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com/api/controller/v2`
   - `aap_job_template_id` = `YOUR_JOB_TEMPLATE_ID` (from Step 5.6)
   - `gcp_project_id` = `hc-4faa1ac49a5e46ecb46cfe87b37`

3. Add **Environment Variables**:
   - `VAULT_TOKEN` = `your-vault-token` (mark as **Sensitive**)
   - `VAULT_NAMESPACE` = `admin` (mark as **Sensitive**)

4. Click **Save variables**

### Step 7: Initialize Terraform

```bash
cd terraform
terraform init
```

**Expected Output**:
```
Initializing HCP Terraform...
Initializing provider plugins...
- Finding hashicorp/google versions matching "~> 5.0"...
- Finding hashicorp/vault versions matching "~> 4.0"...
Terraform has been successfully initialized!
```

---

## Demo Execution

### Phase 1: Provision Infrastructure (5 minutes)

#### Step 1: Show the Code

```bash
# Show main infrastructure resources
cat terraform/main.tf | grep -A 10 "resource \"google_compute_instance\""

# Show Vault integration
cat terraform/main.tf | grep -A 5 "data \"vault_generic_secret\""

# Show Terraform Actions configuration
cat terraform/actions.tf | head -60
```

**Key Points to Highlight**:
- Infrastructure defined as code
- Credentials retrieved from Vault (never hardcoded)
- Terraform Actions configuration included

#### Step 2: Deploy Infrastructure

**Option A: Via HCP Terraform UI (Recommended)**

1. Commit and push changes:
   ```bash
   git add .
   git commit -m "Deploy infrastructure for demo"
   git push origin main
   ```

2. Open HCP Terraform workspace in browser
3. Wait for automatic plan to trigger
4. Review the plan (should show 4 resources to create)
5. Click **Confirm & Apply**
6. Wait for apply to complete (~3 minutes)

**Option B: Via Local Terraform (Alternative)**

```bash
cd terraform
terraform plan
terraform apply
```

#### Step 3: Verify Infrastructure

```bash
# View outputs
terraform output

# Expected output:
# vm_names = ["ubuntu-vm-1", "ubuntu-vm-2"]
# vm_external_ips = ["34.xx.xx.xx", "34.yy.yy.yy"]
# vm_internal_ips = ["10.128.0.2", "10.128.0.3"]
```

**Verify in GCP Console**:
1. Open: `https://console.cloud.google.com/compute/instances?project=hc-4faa1ac49a5e46ecb46cfe87b37`
2. You should see 2 VMs running: `ubuntu-vm-1` and `ubuntu-vm-2`

#### Step 4: Test SSH Access

```bash
# Get first VM IP
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')

# Test SSH (using the key from Vault)
ssh -i ~/.ssh/ubuntu-patching -o StrictHostKeyChecking=no ubuntu@${VM_IP} "hostname && uname -a"
```

**Expected Output**:
```
ubuntu-vm-1
Linux ubuntu-vm-1 5.15.0-xxx-generic #xxx-Ubuntu SMP ... x86_64 GNU/Linux
```

**If SSH fails**, see [Troubleshooting](#ssh-connection-fails) section.

---

### Phase 2: Trigger Terraform Actions (10 minutes)

#### Step 1: Review Action Configuration

```bash
# Show action configuration
cat terraform/actions.tf

# Get action details
terraform output action_patch_vms_config | jq .
```

**Key Points to Highlight**:
- Action defined in Terraform code
- Integrates with AAP via HTTP API
- Payload includes VM inventory from Terraform state
- Credentials retrieved from Vault

#### Step 2: Prepare to Trigger Action

```bash
# Get AAP job template URL
AAP_URL=$(terraform output -raw action_patch_vms_url)
echo "AAP Job Template URL: $AAP_URL"

# Get AAP token from Vault
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Generate payload
terraform output -raw action_patch_vms_payload > /tmp/aap_payload.json

# View payload
cat /tmp/aap_payload.json | jq .
```

**Payload Structure**:
```json
{
  "extra_vars": {
    "vm_inventory": {
      "all": {
        "hosts": {
          "ubuntu-vm-1": {
            "ansible_host": "34.xx.xx.xx",
            "ansible_user": "ubuntu"
          },
          "ubuntu-vm-2": {
            "ansible_host": "34.yy.yy.yy",
            "ansible_user": "ubuntu"
          }
        }
      }
    }
  }
}
```

#### Step 3: Trigger AAP Job

```bash
# Trigger the job
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/aap_payload.json \
  ${AAP_URL} | jq .
```

**Expected Response**:
```json
{
  "id": 123,
  "type": "job",
  "url": "/api/v2/jobs/123/",
  "status": "pending",
  "job_template": 42,
  "created": "2026-02-14T14:10:00.000Z"
}
```

**Note the Job ID** (e.g., `123`) - you'll use this to monitor the job.

---

### Phase 3: Monitor Execution in AAP (5 minutes)

#### Step 1: Open AAP Jobs Page

1. Open browser: `https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com`
2. Navigate to **Views → Jobs**
3. Find the most recent job (should be at the top)
4. Click on the job to view details

#### Step 2: Watch Real-Time Output

**Job Details Page Shows**:
- **Status**: Pending → Running → Successful
- **Started**: Timestamp
- **Elapsed**: Time running
- **Output**: Real-time Ansible playbook output

**Expected Output** (as job runs):

```
PLAY [Patch Ubuntu VMs on GCP] *************************************************

TASK [Gathering Facts] *********************************************************
ok: [ubuntu-vm-1]
ok: [ubuntu-vm-2]

TASK [Update apt cache] ********************************************************
changed: [ubuntu-vm-1]
changed: [ubuntu-vm-2]

TASK [Upgrade all security packages] *******************************************
changed: [ubuntu-vm-1]
changed: [ubuntu-vm-2]

TASK [Check if reboot required] ************************************************
ok: [ubuntu-vm-1]
ok: [ubuntu-vm-2]

TASK [Reboot if required] ******************************************************
skipping: [ubuntu-vm-1]
skipping: [ubuntu-vm-2]

TASK [Wait for system to come back online] *************************************
skipping: [ubuntu-vm-1]
skipping: [ubuntu-vm-2]

TASK [Report patching status] **************************************************
ok: [ubuntu-vm-1] => {
    "msg": "Patching completed successfully. 15 packages upgraded."
}
ok: [ubuntu-vm-2] => {
    "msg": "Patching completed successfully. 15 packages upgraded."
}

PLAY RECAP *********************************************************************
ubuntu-vm-1    : ok=5    changed=2    unreachable=0    failed=0    skipped=2
ubuntu-vm-2    : ok=5    changed=2    unreachable=0    failed=0    skipped=2
```

#### Step 3: Monitor via API (Alternative)

```bash
# Get job ID from previous step
JOB_ID=123

# Check job status
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com/api/v2/jobs/${JOB_ID}/" | jq '.status'

# Get job output
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com/api/v2/jobs/${JOB_ID}/stdout/?format=txt"
```

---

### Phase 4: Verify Results (5 minutes)

#### Step 1: Check Patching Results on VMs

```bash
# SSH to first VM and check results
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')

ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP} << 'EOF'
  echo "=== Last apt update ==="
  stat /var/cache/apt/pkgcache.bin | grep Modify
  
  echo -e "\n=== Available updates ==="
  sudo apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l
  
  echo -e "\n=== Recently upgraded packages ==="
  grep "upgrade " /var/log/dpkg.log | tail -5
  
  echo -e "\n=== System uptime ==="
  uptime
EOF
```

**Expected Output**:
```
=== Last apt update ===
Modify: 2026-02-14 14:15:30.000000000 +0000

=== Available updates ===
0

=== Recently upgraded packages ===
2026-02-14 14:15:45 upgrade package1:amd64 1.0-1 1.0-2
2026-02-14 14:15:46 upgrade package2:amd64 2.0-1 2.0-2
...

=== System uptime ===
 14:20:15 up 15 min,  1 user,  load average: 0.00, 0.01, 0.05
```

#### Step 2: Review Job History in AAP

1. In AAP UI, go to **Views → Jobs**
2. Click on the completed job
3. Review:
   - **Status**: Successful
   - **Elapsed Time**: ~2-3 minutes
   - **Hosts**: 2 successful
   - **Tasks**: All completed

#### Step 3: Check Terraform State

```bash
# Show current infrastructure state
terraform show | grep -A 5 "google_compute_instance"

# List all resources
terraform state list
```

---

## Troubleshooting

### SSH Connection Fails

**Error**: `Permission denied (publickey)`

**Solution**:

```bash
# 1. Verify SSH key in Vault
vault kv get secret/ssh/ubuntu-key

# 2. Check if public key matches VM metadata
gcloud compute instances describe ubuntu-vm-1 \
  --zone=us-central1-a \
  --project=hc-4faa1ac49a5e46ecb46cfe87b37 \
  --format="get(metadata.items[0].value)"

# 3. If keys don't match, update Vault and re-apply Terraform
vault kv put secret/ssh/ubuntu-key \
  private_key=@~/.ssh/ubuntu-patching \
  public_key=@~/.ssh/ubuntu-patching.pub

cd terraform
terraform apply -replace="google_compute_instance.ubuntu_vms[0]" -replace="google_compute_instance.ubuntu_vms[1]"
```

### AAP Job Fails - Inventory Empty

**Error**: `ERROR! Inventory is empty`

**Solution**:

1. Verify job template has "Prompt on launch" enabled for Variables:
   - In AAP UI: **Resources → Templates → GCP VM Patching → Edit**
   - Check ✓ **Prompt on launch** under **Variables**
   - Click **Save**

2. Verify payload includes inventory:
   ```bash
   terraform output action_patch_vms_payload | jq '.extra_vars.vm_inventory'
   ```

3. Re-trigger the job

### AAP Job Fails - SSH Authentication

**Error**: `Failed to connect to the host via ssh: Permission denied`

**Solution**:

1. Verify credential in AAP:
   - **Resources → Credentials → GCP Ubuntu SSH Key**
   - Ensure private key is correct

2. Update credential with key from Vault:
   ```bash
   vault kv get -field=private_key secret/ssh/ubuntu-key
   # Copy output and update in AAP credential
   ```

3. Test SSH manually:
   ```bash
   ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP}
   ```

### Terraform Apply Fails - API Not Enabled

**Error**: `Error 403: Compute Engine API has not been used`

**Solution**:

```bash
# Enable required APIs
gcloud services enable compute.googleapis.com --project=hc-4faa1ac49a5e46ecb46cfe87b37
gcloud services enable osconfig.googleapis.com --project=hc-4faa1ac49a5e46ecb46cfe87b37

# Retry
terraform apply
```

### Vault Connection Failed

**Error**: `Error making API request to Vault`

**Solution**:

```bash
# 1. Verify Vault address
echo $VAULT_ADDR

# 2. Test connectivity
vault status

# 3. Re-authenticate
vault login

# 4. Verify secrets exist
task vault-verify
```

### AAP Sandbox Expired

**Error**: `401 Unauthorized` when calling AAP API

**Solution**:

1. Red Hat Developer Sandbox expires after 30 days
2. Request new sandbox: https://developers.redhat.com/developer-sandbox
3. Update AAP URL in Terraform variables
4. Generate new API token
5. Update Vault:
   ```bash
   vault kv put secret/aap/api-token token="NEW_TOKEN"
   ```

---

## Cleanup

### Destroy Infrastructure

```bash
# Via HCP Terraform UI (Recommended)
# 1. Go to workspace settings
# 2. Navigate to "Destruction and Deletion"
# 3. Click "Queue destroy plan"
# 4. Confirm destruction

# Via Local Terraform (Alternative)
cd terraform
terraform destroy -auto-approve
```

### Verify Cleanup

```bash
# Check GCP
gcloud compute instances list --project=hc-4faa1ac49a5e46ecb46cfe87b37

# Should show: Listed 0 items.
```

### Clean Local Files

```bash
# Clean Terraform files
task clean

# Remove SSH keys (optional)
rm ~/.ssh/ubuntu-patching*

# Remove temporary files
rm /tmp/aap_payload.json
```

---

## Demo Tips

### Before Demo

1. **Pre-provision infrastructure** (optional):
   - Run through once before the demo
   - Keep VMs running to save time
   - Focus demo on Terraform Actions

2. **Prepare terminal windows**:
   - Terminal 1: For commands
   - Terminal 2: For monitoring logs
   - Terminal 3: Backup

3. **Prepare browser tabs**:
   - HCP Terraform workspace
   - AAP Jobs page
   - GCP Console
   - This guide

4. **Test everything**:
   - Run complete workflow once
   - Verify all credentials
   - Check network connectivity

### During Demo

1. **Set expectations**:
   - "This is a prototype demonstrating the concept"
   - "Focus on the workflow, not production-ready code"

2. **Highlight key points**:
   - Infrastructure as Code with Terraform
   - Secure credentials with Vault
   - Automated Day-2 operations with Terraform Actions
   - Integration between Terraform and Ansible

3. **Handle delays**:
   - While waiting for Terraform apply, explain the architecture
   - While waiting for AAP job, show the playbook code
   - Have backup screenshots ready

### After Demo

1. **Provide resources**:
   - GitHub repository link
   - This guide
   - Contact information

2. **Clean up**:
   - Destroy infrastructure to avoid charges
   - Thank the audience

---

## Quick Reference

### Key URLs

- **HCP Terraform**: https://app.terraform.io/app/rahul-tfc/workspaces/tf-actions-aap-gcp
- **AAP**: https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com
- **GCP Console**: https://console.cloud.google.com/compute/instances?project=hc-4faa1ac49a5e46ecb46cfe87b37
- **Vault**: https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200

### Key Commands

```bash
# Check prerequisites
task check-prereqs

# Verify Vault secrets
task vault-verify

# Initialize Terraform
cd terraform && terraform init

# View outputs
terraform output

# Trigger AAP job
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/aap_payload.json \
  ${AAP_URL}

# SSH to VM
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP}

# Destroy infrastructure
terraform destroy -auto-approve
```

### Environment Variables

```bash
export PROJECT_ID="hc-4faa1ac49a5e46ecb46cfe87b37"
export VAULT_ADDR="https://vault-cluster-public-vault-27516708.98e1242b.z1.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"
```

---

## Success Checklist

- [ ] All prerequisites installed and verified
- [ ] Vault secrets configured and verified
- [ ] AAP project, credential, inventory, and job template created
- [ ] HCP Terraform workspace variables configured
- [ ] Infrastructure provisioned successfully
- [ ] SSH access to VMs working
- [ ] Terraform Actions payload generated
- [ ] AAP job triggered successfully
- [ ] Job completed with all VMs patched
- [ ] Results verified on VMs
- [ ] Demo rehearsed at least once

---

**You're ready to demo! Good luck! 🚀**
