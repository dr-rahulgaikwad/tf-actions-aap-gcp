# Ansible Automation Platform (AAP) Setup Guide

This guide walks you through configuring Ansible Automation Platform (AAP) for the Terraform Actions GCP Patching prototype.

## Prerequisites

- Ansible Automation Platform instance (version 2.4+)
- AAP admin access
- HashiCorp Vault configured and accessible
- GCP service account key stored in Vault
- SSH key pair for VM access stored in Vault
- Network connectivity from AAP to GCP VMs
- Network connectivity from AAP to Vault

## AAP Installation and Access Requirements

### Installation Options

You have several options for accessing AAP for this prototype:

#### Option 1: Red Hat Ansible Automation Platform (Recommended for Production)

**Requirements:**
- Red Hat subscription with AAP entitlement
- RHEL 8 or 9 server (minimum 4 CPU, 16GB RAM, 40GB disk)
- PostgreSQL database (can be bundled or external)
- Valid SSL certificate (recommended)

**Installation Steps:**
```bash
# Download AAP installer from Red Hat Customer Portal
# https://access.redhat.com/downloads/content/480/

# Extract installer
tar xvzf ansible-automation-platform-setup-<version>.tar.gz
cd ansible-automation-platform-setup-<version>

# Edit inventory file
vi inventory

# Example minimal inventory:
[automationcontroller]
aap.example.com ansible_connection=local

[automationcontroller:vars]
admin_password='<secure-password>'
pg_host=''
pg_port=5432
pg_database='awx'
pg_username='awx'
pg_password='<secure-password>'

# Run installer
sudo ./setup.sh

# Installation takes 15-30 minutes
```

**Post-Installation:**
- Access AAP at `https://aap.example.com`
- Login with admin credentials
- Apply subscription manifest from Red Hat portal

#### Option 2: AWX (Open Source, Good for Development/Testing)

**Requirements:**
- Kubernetes cluster (minikube, k3s, or cloud-managed)
- kubectl configured
- Minimum 4GB RAM, 2 CPU for cluster

**Installation Steps:**
```bash
# Install AWX Operator
kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/devel/deploy/awx-operator.yaml

# Create AWX instance
cat <<EOF | kubectl apply -f -
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: nodeport
  nodeport_port: 30080
EOF

# Wait for deployment (5-10 minutes)
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"

# Get admin password
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode

# Access AWX at http://<node-ip>:30080
```

#### Option 3: Red Hat Demo System (Quickest for Demos)

**Requirements:**
- Red Hat account
- Access to Red Hat Demo Platform

**Access Steps:**
1. Navigate to https://demo.redhat.com
2. Search for "Ansible Automation Platform"
3. Order a demo environment (provisioned in 30-60 minutes)
4. Receive access credentials via email
5. Access AAP instance at provided URL

#### Option 4: Cloud Marketplace (AWS, Azure, GCP)

**Requirements:**
- Cloud account with billing enabled
- Appropriate IAM permissions

**Example: AWS Marketplace**
1. Navigate to AWS Marketplace
2. Search for "Red Hat Ansible Automation Platform"
3. Subscribe and launch instance
4. Configure security groups (ports 80, 443, 22)
5. Access AAP at instance public IP

### Network Requirements

AAP needs network connectivity to:

| Destination | Port | Protocol | Purpose |
|------------|------|----------|---------|
| GCP VMs | 22 | TCP | SSH for Ansible playbook execution |
| HashiCorp Vault | 8200 | TCP | Credential retrieval |
| Internet | 443 | TCP | Package downloads, Git repositories |
| PostgreSQL | 5432 | TCP | Database (if external) |

**Firewall Configuration:**
```bash
# On AAP controller (RHEL)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload

# Verify connectivity to GCP
ssh -i ~/.ssh/test-key ubuntu@<gcp-vm-ip>

# Verify connectivity to Vault
curl -k https://vault.example.com:8200/v1/sys/health
```

### AAP Architecture Overview

Understanding AAP components helps with troubleshooting:

```
┌─────────────────────────────────────────────────────────────┐
│                    AAP Controller                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web UI     │  │   REST API   │  │   Scheduler  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                           │                                  │
│                  ┌────────▼────────┐                         │
│                  │   PostgreSQL    │                         │
│                  │    Database     │                         │
│                  └─────────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Job Execution
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Execution Environments                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Container 1 │  │  Container 2 │  │  Container 3 │      │
│  │  (Ansible)   │  │  (Ansible)   │  │  (Ansible)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ SSH/WinRM
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Target Systems                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   GCP VM 1   │  │   GCP VM 2   │  │   GCP VM N   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

**Key Components:**
- **Controller:** Web UI, API, job scheduling, and orchestration
- **Database:** Stores configuration, credentials, job history
- **Execution Environments:** Containerized Ansible runtimes
- **Automation Hub:** Private repository for collections (optional)

## Overview

This setup guide covers:
1. Accessing AAP and initial configuration
2. Creating credentials (Vault integration)
3. Creating an inventory
4. Creating a project for playbooks
5. Creating a job template
6. Generating API token for Terraform Actions
7. Testing the job template
8. Integrating with Terraform Actions

## Step 1: Access AAP

### Login to AAP

1. Navigate to your AAP instance: `https://aap.example.com`
2. Login with admin credentials
3. Verify you're on the AAP dashboard

### Verify AAP Version

```bash
# SSH to AAP controller node
ssh admin@aap.example.com

# Check AAP version
ansible-automation-platform-cli --version

# Expected: 2.4 or higher
```

## Step 2: Create Credentials

AAP needs credentials to:
- Connect to VMs via SSH
- Authenticate with GCP (optional, for dynamic inventory)
- Retrieve secrets from Vault

### 2.1: Create Vault Credential Type (if not exists)

Navigate to: **Administration → Credential Types → Add**

**Name:** `HashiCorp Vault`

**Input Configuration:**
```yaml
fields:
  - id: vault_addr
    type: string
    label: Vault Server URL
  - id: vault_token
    type: string
    label: Vault Token
    secret: true
  - id: vault_namespace
    type: string
    label: Vault Namespace (optional)
    required: false
required:
  - vault_addr
  - vault_token
```

**Injector Configuration:**
```yaml
env:
  VAULT_ADDR: '{{ vault_addr }}'
  VAULT_TOKEN: '{{ vault_token }}'
  VAULT_NAMESPACE: '{{ vault_namespace }}'
```

### 2.2: Create Vault Credential

Navigate to: **Resources → Credentials → Add**

**Name:** `Vault Production`  
**Organization:** `Default`  
**Credential Type:** `HashiCorp Vault`

**Details:**
- **Vault Server URL:** `https://vault.example.com:8200`
- **Vault Token:** `<your-vault-token>`
- **Vault Namespace:** (leave empty if not using namespaces)

Click **Save**

### 2.3: Create SSH Credential with Vault Lookup

Navigate to: **Resources → Credentials → Add**

**Name:** `GCP Ubuntu SSH Key`  
**Organization:** `Default`  
**Credential Type:** `Machine`

**Details:**
- **Username:** `ubuntu`
- **SSH Private Key:** Click **Vault** and configure:
  - **Vault Credential:** `Vault Production`
  - **Secret Path:** `secret/ssh/ubuntu-key`
  - **Secret Key:** `private_key`

Click **Save**

### 2.4: Create GCP Credential (Optional)

If you need GCP API access from Ansible:

Navigate to: **Resources → Credentials → Add**

**Name:** `GCP Service Account`  
**Organization:** `Default`  
**Credential Type:** `Google Compute Engine`

**Details:**
- **Service Account JSON:** Click **Vault** and configure:
  - **Vault Credential:** `Vault Production`
  - **Secret Path:** `secret/gcp/service-account`
  - **Secret Key:** `key`

Click **Save**

## Step 3: Create Inventory

For this prototype, we'll use a **dynamic inventory** passed from Terraform Actions.

Navigate to: **Resources → Inventories → Add → Add inventory**

**Name:** `GCP Patching Demo`  
**Organization:** `Default`  
**Description:** `Dynamic inventory for GCP VMs, provided by Terraform Actions`

Click **Save**

**Note:** We don't add hosts manually. Terraform Actions will pass the inventory dynamically when triggering the job.

## Step 4: Create Project for Playbooks

AAP needs access to the Ansible playbooks. You can use a Git repository or manual project.

### Option A: Git Repository (Recommended)

Navigate to: **Resources → Projects → Add**

**Name:** `Terraform Actions GCP Patching`  
**Organization:** `Default`  
**SCM Type:** `Git`  
**SCM URL:** `https://github.com/your-org/terraform-actions-gcp-patching.git`  
**SCM Branch/Tag/Commit:** `main`  
**SCM Update Options:**
- ✅ Clean
- ✅ Delete on Update
- ✅ Update Revision on Launch

Click **Save**

### Option B: Manual Project

If not using Git, copy playbooks to AAP:

```bash
# SSH to AAP controller
ssh admin@aap.example.com

# Create project directory
sudo mkdir -p /var/lib/awx/projects/gcp-patching

# Copy playbook (from your local machine)
scp ansible/gcp_vm_patching.yml admin@aap.example.com:/tmp/
ssh admin@aap.example.com "sudo mv /tmp/gcp_vm_patching.yml /var/lib/awx/projects/gcp-patching/"

# Set permissions
sudo chown -R awx:awx /var/lib/awx/projects/gcp-patching
```

Then in AAP UI:

Navigate to: **Resources → Projects → Add**

**Name:** `Terraform Actions GCP Patching`  
**Organization:** `Default`  
**SCM Type:** `Manual`  
**Playbook Directory:** `gcp-patching`

Click **Save**

## Step 5: Create Job Template

Navigate to: **Resources → Templates → Add → Add job template**

### Basic Configuration

**Name:** `GCP VM Patching`  
**Job Type:** `Run`  
**Inventory:** `GCP Patching Demo`  
**Project:** `Terraform Actions GCP Patching`  
**Playbook:** `gcp_vm_patching.yml`  
**Credentials:**
- `GCP Ubuntu SSH Key` (Machine)
- `Vault Production` (Vault) - if using Vault lookups in playbook

### Execution Environment

**Execution Environment:** `Default execution environment`

### Options

Enable these options:
- ✅ **Prompt on launch:** Inventory
- ✅ **Prompt on launch:** Variables
- ✅ **Enable Concurrent Jobs** (optional, for parallel patching)

### Variables

Default extra variables (can be overridden by Terraform Actions):

```yaml
---
patch_type: security
reboot_allowed: true
reboot_timeout: 300
```

Click **Save**

## Step 6: Generate API Token for Terraform Actions

Terraform Actions needs an API token to trigger AAP jobs.

### 6.1: Create Application Token

Navigate to: **Administration → Applications → Add**

**Name:** `Terraform Actions Integration`  
**Organization:** `Default`  
**Authorization Grant Type:** `Resource owner password-based`  
**Client Type:** `Confidential`

Click **Save**

Note the **Client ID** and **Client Secret**.

### 6.2: Create Personal Access Token

Navigate to: **User Menu (top right) → Users → Select your user → Tokens → Add**

**Application:** `Terraform Actions Integration`  
**Scope:** `Write`  
**Description:** `Token for Terraform Actions to trigger patching jobs`

Click **Save**

**Copy the token** - you won't be able to see it again!

Example token: `Bearer abc123def456ghi789jkl012mno345pqr678stu901vwx234yz`

### 6.3: Store API Token in Vault

```bash
# Set Vault address and authenticate
export VAULT_ADDR="https://vault.example.com:8200"
vault login

# Store AAP API token in Vault
vault kv put secret/aap/api-token \
  token="<your-aap-token>" \
  url="https://aap.example.com"

# Verify secret was stored
vault kv get secret/aap/api-token
```

### 6.4: Get Job Template ID

You'll need the job template ID for Terraform Actions configuration.

**Method 1: Via UI**
1. Navigate to: **Resources → Templates**
2. Click on `GCP VM Patching` template
3. Look at the URL: `https://aap.example.com/#/templates/job_template/42/details`
4. The ID is `42`

**Method 2: Via API**
```bash
# Set AAP URL and token
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="<your-aap-token>"

# List job templates
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/job_templates/ | jq '.results[] | {id, name}'

# Find your template ID
```

Note the **Job Template ID** for Terraform configuration.

## Step 7: Test Job Template

Before integrating with Terraform Actions, test the job template manually.

### 7.1: Create Test Inventory

For testing, create a simple inventory:

Navigate to: **Resources → Inventories → GCP Patching Demo → Hosts → Add**

**Name:** `test-vm`  
**Variables:**
```yaml
---
ansible_host: 10.128.0.2  # Replace with actual VM IP
instance_id: "1234567890"
```

Click **Save**

### 7.2: Launch Job Template

Navigate to: **Resources → Templates → GCP VM Patching → Launch**

**Inventory:** `GCP Patching Demo`  
**Extra Variables:**
```yaml
---
patch_type: security
reboot_allowed: false  # Set to false for testing
```

Click **Launch**

### 7.3: Monitor Job Execution

Watch the job output in real-time. Expected tasks:
1. ✅ Update apt cache
2. ✅ Upgrade security packages
3. ✅ Check if reboot required
4. ⏭️ Reboot (skipped if reboot_allowed: false)
5. ✅ Report patching status

**Expected Result:** Job completes successfully with status "Successful"

### 7.4: Test API Launch

Test launching the job via API (simulating Terraform Actions):

```bash
# Set variables
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="<your-aap-token>"
export JOB_TEMPLATE_ID="42"  # Replace with your template ID

# Create test payload
cat > /tmp/test_payload.json <<EOF
{
  "inventory": {
    "all": {
      "hosts": {
        "test-vm": {
          "ansible_host": "10.128.0.2",
          "instance_id": "1234567890"
        }
      },
      "vars": {
        "ansible_user": "ubuntu"
      }
    }
  },
  "extra_vars": {
    "patch_type": "security",
    "reboot_allowed": false
  }
}
EOF

# Launch job via API
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/test_payload.json \
  ${AAP_URL}/api/v2/job_templates/${JOB_TEMPLATE_ID}/launch/

# Expected response: Job ID and status
```

**Expected Response:**
```json
{
  "id": 123,
  "type": "job",
  "url": "/api/v2/jobs/123/",
  "status": "pending",
  "job_template": 42,
  "created": "2024-01-15T10:30:00Z"
}
```

## Step 8: Configure Terraform Variables

Update your `terraform.tfvars` with AAP details:

```hcl
# AAP Configuration
aap_api_url         = "https://aap.example.com"
aap_job_template_id = 42  # Use your actual job template ID

# Vault Configuration
vault_aap_token_path = "secret/aap/api-token"
```

## Step 9: Integration with Terraform Actions

Now that AAP is configured, you can integrate it with Terraform Actions.

### 9.1: Verify Terraform Actions Configuration

In your Terraform code, the action should look like this:

```hcl
# In terraform/main.tf or terraform/actions.tf

data "vault_generic_secret" "aap_token" {
  path = var.vault_aap_token_path
}

resource "terraform_action" "patch_vms" {
  name        = "Patch Ubuntu VMs"
  description = "Trigger Ansible playbook to patch VMs via AAP"
  
  integration {
    type = "http"
    url  = "${var.aap_api_url}/api/v2/job_templates/${var.aap_job_template_id}/launch/"
    
    authentication {
      type  = "bearer"
      token = data.vault_generic_secret.aap_token.data["token"]
    }
  }
  
  payload = jsonencode({
    inventory = {
      all = {
        hosts = {
          for vm in google_compute_instance.ubuntu_vms :
          vm.name => {
            ansible_host = vm.network_interface[0].network_ip
            instance_id  = vm.instance_id
          }
        }
        vars = {
          ansible_user = "ubuntu"
          gcp_project  = var.gcp_project_id
        }
      }
    }
    extra_vars = {
      patch_type      = "security"
      reboot_allowed  = true
      reboot_timeout  = 300
    }
  })
}
```

### 9.2: Test End-to-End Integration

**Step 1: Provision Infrastructure**
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

**Step 2: Trigger Terraform Action**

From HCP Terraform UI:
1. Navigate to your workspace
2. Go to **Actions** tab
3. Find "Patch Ubuntu VMs" action
4. Click **Run Action**
5. Confirm execution

From Terraform CLI (if supported):
```bash
terraform action run patch_vms
```

**Step 3: Monitor in AAP**
1. Navigate to AAP UI: **Views → Jobs**
2. Find the newly launched job
3. Click to view real-time output
4. Verify job completes successfully

**Step 4: Verify Results**

Check that VMs were patched:
```bash
# SSH to a VM
ssh ubuntu@<vm-ip>

# Check last apt update time
stat /var/cache/apt/pkgcache.bin

# Check if reboot occurred (if reboot_allowed was true)
uptime

# Check system logs
sudo journalctl -u unattended-upgrades --since "1 hour ago"
```

### 9.3: Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    HCP Terraform                             │
│                                                              │
│  1. User triggers "Patch VMs" action                        │
│  2. Terraform retrieves AAP token from Vault                │
│  3. Terraform builds inventory from VM outputs              │
│  4. Terraform sends POST to AAP API                         │
│                                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTPS POST
                         │ /api/v2/job_templates/42/launch/
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    AAP Controller                            │
│                                                              │
│  5. AAP receives job launch request                         │
│  6. AAP validates inventory and credentials                 │
│  7. AAP retrieves SSH key from Vault                        │
│  8. AAP schedules job in execution environment              │
│  9. AAP returns job ID to Terraform                         │
│                                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Job Execution
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Execution Environment (Container)               │
│                                                              │
│  10. Ansible playbook starts execution                      │
│  11. Connects to each VM via SSH                            │
│  12. Runs apt update and upgrade                            │
│  13. Checks for reboot requirement                          │
│  14. Conditionally reboots VMs                              │
│  15. Reports status back to AAP                             │
│                                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ SSH (port 22)
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    GCP Ubuntu VMs                            │
│                                                              │
│  16. VMs receive and apply security patches                 │
│  17. VMs reboot if required                                 │
│  18. VMs return to healthy state                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 9.4: Monitoring and Observability

**AAP Job Monitoring:**
- **Real-time:** AAP UI → Views → Jobs → [Job ID]
- **API:** `GET /api/v2/jobs/{id}/`
- **Notifications:** Configure in AAP → Notifications

**Terraform Actions Monitoring:**
- **HCP Terraform UI:** Workspace → Actions → History
- **API:** HCP Terraform API for action runs
- **Logs:** Action execution logs in HCP Terraform

**VM Health Monitoring:**
```bash
# Check VM status in GCP
gcloud compute instances list --project=<project-id>

# Check OS Config patch compliance
gcloud compute os-config patch-deployments list --project=<project-id>

# SSH to VM and check
ssh ubuntu@<vm-ip>
sudo apt list --upgradable
```

### 9.5: Automation and Scheduling

**Option 1: Manual Trigger**
- Best for demos and controlled patching
- Trigger from HCP Terraform UI or API

**Option 2: Scheduled Trigger**
- Use HCP Terraform scheduled runs
- Configure in Workspace → Settings → Run Triggers

**Option 3: Event-Driven Trigger**
- Use Terraform Cloud Notifications
- Integrate with external systems (ServiceNow, PagerDuty)

**Option 4: CI/CD Integration**
- Trigger from GitHub Actions, GitLab CI, etc.
- Use HCP Terraform API

Example GitHub Actions workflow:
```yaml
name: Patch GCP VMs
on:
  schedule:
    - cron: '0 2 * * 0'  # Every Sunday at 2 AM
  workflow_dispatch:  # Manual trigger

jobs:
  patch:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Terraform Action
        env:
          TFC_TOKEN: ${{ secrets.TFC_TOKEN }}
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${TFC_TOKEN}" \
            -H "Content-Type: application/vnd.api+json" \
            https://app.terraform.io/api/v2/actions/runs \
            -d @- <<EOF
          {
            "data": {
              "type": "action-runs",
              "attributes": {
                "action-id": "patch_vms"
              }
            }
          }
          EOF
```

## Troubleshooting

### Issue: Vault Credential Lookup Fails

**Error:**
```
Failed to retrieve secret from Vault: secret/ssh/ubuntu-key
```

**Solution:**
1. Verify Vault credential is configured correctly in AAP
2. Test Vault connectivity from AAP controller:
```bash
ssh admin@aap.example.com
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="<your-token>"
vault kv get secret/ssh/ubuntu-key
```
3. Check Vault token has not expired
4. Verify Vault policy allows read access to the secret path
5. Check network connectivity from AAP to Vault (port 8200)

### Issue: SSH Connection Fails

**Error:**
```
Failed to connect to the host via ssh: Permission denied (publickey)
```

**Solution:**
1. Verify SSH public key is added to VM metadata
2. Test SSH connection manually:
```bash
ssh -i ~/.ssh/ubuntu-key ubuntu@<vm-ip>
```
3. Check VM firewall allows SSH (port 22)
4. Verify the SSH private key in Vault matches the public key on the VM
5. Check AAP can reach VM IP (test with ping or telnet)
6. Ensure ansible_user is set correctly (should be 'ubuntu' for Ubuntu VMs)

### Issue: API Token Invalid

**Error:**
```
HTTP 401: Unauthorized
```

**Solution:**
1. Verify token is valid and not expired
2. Regenerate token if needed
3. Ensure token has correct scope (Write)
4. Check token format includes "Bearer" prefix if required
5. Verify token is stored correctly in Vault

### Issue: Job Template Not Found

**Error:**
```
HTTP 404: Not Found
```

**Solution:**
1. Verify job template ID is correct
2. Check API endpoint URL
3. Ensure user has permission to access template
4. Verify template is not deleted or archived
5. Check organization access (template must be in accessible organization)

### Issue: Playbook Not Found in Project

**Error:**
```
ERROR! the playbook: gcp_vm_patching.yml could not be found
```

**Solution:**
1. Verify project sync completed successfully
2. Check playbook path in job template matches actual file location
3. For Git projects, verify branch/tag is correct
4. For manual projects, verify file is in correct directory:
```bash
ssh admin@aap.example.com
ls -la /var/lib/awx/projects/gcp-patching/
```
5. Sync project manually: **Resources → Projects → [Your Project] → Sync**

### Issue: Dynamic Inventory Not Working

**Error:**
```
ERROR! Inventory is empty
```

**Solution:**
1. Verify "Prompt on launch" is enabled for Inventory in job template
2. Check inventory JSON format in Terraform Actions payload
3. Test with manual inventory first to isolate issue
4. Verify inventory structure matches expected format:
```json
{
  "all": {
    "hosts": {
      "vm-name": {
        "ansible_host": "10.0.0.1"
      }
    }
  }
}
```

### Issue: Execution Environment Missing Dependencies

**Error:**
```
ERROR! couldn't resolve module/action 'apt'
```

**Solution:**
1. Verify execution environment has required collections
2. Check execution environment in job template settings
3. Use default execution environment or create custom one with required collections
4. Add collections to requirements.yml in project:
```yaml
---
collections:
  - name: ansible.posix
  - name: community.general
```

### Issue: Job Stuck in Pending State

**Error:**
Job shows "Pending" status indefinitely

**Solution:**
1. Check AAP capacity: **Administration → Instance Groups**
2. Verify execution nodes are online and healthy
3. Check for resource constraints (CPU, memory)
4. Review dispatcher logs:
```bash
ssh admin@aap.example.com
sudo tail -f /var/log/tower/dispatcher.log
```
5. Restart AAP services if needed:
```bash
sudo automation-controller-service restart
```

### Issue: Terraform Actions Cannot Reach AAP

**Error:**
```
Error: Post "https://aap.example.com/api/v2/job_templates/42/launch/": dial tcp: i/o timeout
```

**Solution:**
1. Verify AAP URL is correct and accessible from HCP Terraform
2. Check AAP firewall allows HTTPS (port 443) from HCP Terraform IPs
3. Verify SSL certificate is valid (or use -k flag for testing)
4. Test connectivity from a similar network location:
```bash
curl -k https://aap.example.com/api/v2/ping/
```
5. Check AAP is running and healthy

### Issue: Vault Integration Not Working in AAP

**Error:**
```
Failed to lookup credential from Vault
```

**Solution:**
1. Verify Vault credential type is configured correctly
2. Check Vault token has not expired
3. Verify Vault namespace is correct (if using namespaces)
4. Test Vault lookup manually from AAP:
```bash
ssh admin@aap.example.com
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="<token>"
vault kv get secret/ssh/ubuntu-key
```
5. Check AAP logs for detailed error:
```bash
sudo tail -f /var/log/tower/tower.log | grep -i vault
```

### Issue: Playbook Fails on apt Update

**Error:**
```
FAILED! => {"msg": "Could not get lock /var/lib/apt/lists/lock"}
```

**Solution:**
1. Another process is using apt (common on fresh VMs)
2. Add retry logic to playbook:
```yaml
- name: Update apt cache
  apt:
    update_cache: yes
  retries: 5
  delay: 10
  register: result
  until: result is succeeded
```
3. Or wait and retry the job after a few minutes

### Issue: Permission Denied on Reboot

**Error:**
```
FAILED! => {"msg": "Failed to reboot: permission denied"}
```

**Solution:**
1. Verify playbook has `become: yes` set
2. Check sudo permissions for ubuntu user on VM
3. Test sudo manually:
```bash
ssh ubuntu@<vm-ip>
sudo reboot
```
4. Verify SSH credential has privilege escalation enabled in AAP

### Debugging Tips

**Enable Verbose Logging:**
In job template, set verbosity to 3 or 4 for detailed output:
- **Resources → Templates → [Your Template] → Edit**
- **Verbosity:** 3 (Debug) or 4 (Connection Debug)

**Check AAP Logs:**
```bash
# Main application log
sudo tail -f /var/log/tower/tower.log

# Dispatcher log (job scheduling)
sudo tail -f /var/log/tower/dispatcher.log

# Callback receiver log (job output)
sudo tail -f /var/log/tower/callback_receiver.log

# Web server log
sudo tail -f /var/log/nginx/error.log
```

**Test API Endpoints:**
```bash
# Ping endpoint (no auth required)
curl -k https://aap.example.com/api/v2/ping/

# Me endpoint (verify token)
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  https://aap.example.com/api/v2/me/

# Job templates list
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  https://aap.example.com/api/v2/job_templates/
```

**Common Log Patterns:**
```bash
# Search for errors
sudo grep -i error /var/log/tower/tower.log

# Search for specific job
sudo grep "job 123" /var/log/tower/tower.log

# Search for Vault issues
sudo grep -i vault /var/log/tower/tower.log

# Search for API calls
sudo grep "POST /api/v2" /var/log/nginx/access.log
```

## Security Best Practices

### 1. API Token Management

**Token Creation:**
- Use dedicated tokens for automation (not personal user tokens)
- Create separate tokens for different integrations
- Use descriptive names: "Terraform Actions - Production"

**Token Security:**
- Store tokens only in Vault, never in code or logs
- Use minimal scope (Write for job launch, Read for status checks)
- Set expiration dates (90 days recommended)
- Rotate tokens regularly

**Token Rotation Process:**
```bash
# 1. Generate new token in AAP UI
# 2. Store new token in Vault
vault kv put secret/aap/api-token-new token="<new-token>"

# 3. Update Terraform to use new token path (or update existing secret)
vault kv put secret/aap/api-token token="<new-token>"

# 4. Test with new token
curl -k -H "Authorization: Bearer <new-token>" \
  https://aap.example.com/api/v2/me/

# 5. Revoke old token in AAP UI
# Resources → Users → [User] → Tokens → [Old Token] → Delete
```

**Token Monitoring:**
- Enable audit logging for token usage
- Monitor for failed authentication attempts
- Alert on unusual API activity
- Review token usage monthly

### 2. Credential Management

**Vault Integration:**
- Use Vault for ALL sensitive data (SSH keys, API tokens, passwords)
- Never hardcode credentials in playbooks or Terraform code
- Use Vault dynamic secrets where possible
- Enable Vault audit logging

**Credential Types:**
```
┌─────────────────────────────────────────────────────────────┐
│ Credential Type    │ Storage Location │ Access Method       │
├────────────────────┼──────────────────┼─────────────────────┤
│ SSH Private Key    │ Vault            │ AAP Vault lookup    │
│ GCP Service Acct   │ Vault            │ AAP Vault lookup    │
│ AAP API Token      │ Vault            │ Terraform data src  │
│ Vault Token        │ AAP Credential   │ Environment var     │
└─────────────────────────────────────────────────────────────┘
```

**Credential Rotation:**
- SSH Keys: Rotate every 90 days
- Service Account Keys: Rotate every 90 days
- API Tokens: Rotate every 90 days
- Vault Tokens: Use short TTL (24 hours) with renewal

**Credential Auditing:**
```bash
# Enable Vault audit logging
vault audit enable file file_path=/var/log/vault/audit.log

# Review credential access
sudo grep "secret/ssh/ubuntu-key" /var/log/vault/audit.log

# Monitor for unauthorized access
sudo grep "permission denied" /var/log/vault/audit.log
```

### 3. Job Template Security

**Access Control:**
- Limit who can modify templates (use RBAC)
- Separate dev/test/prod templates
- Use different credentials for different environments
- Enable job approval for production templates

**Job Template Permissions:**
```
┌─────────────────────────────────────────────────────────────┐
│ Role               │ Permissions                            │
├────────────────────┼────────────────────────────────────────┤
│ Admin              │ Create, modify, delete, execute        │
│ Execute            │ Execute only (for automation)          │
│ Read               │ View template and job output           │
│ Auditor            │ View all, no execute                   │
└─────────────────────────────────────────────────────────────┘
```

**Template Hardening:**
- Enable "Prompt on launch" only for necessary fields
- Use surveys for user input validation
- Set concurrent job limits to prevent resource exhaustion
- Enable timeout limits (default: 0 = no timeout, set to reasonable value)
- Use execution environment with minimal required packages

**Example Secure Template Configuration:**
```yaml
Name: GCP VM Patching - Production
Job Type: Run
Inventory: Prompt on launch ✓
Credentials: Fixed (no prompt)
Variables: Prompt on launch ✓ (with survey)
Verbosity: 0 (Normal)
Timeout: 3600 (1 hour)
Concurrent Jobs: 5
Enable Privilege Escalation: ✓
```

### 4. Network Security

**AAP Controller Hardening:**
```bash
# Disable unnecessary services
sudo systemctl disable cups
sudo systemctl disable avahi-daemon

# Configure firewall (allow only necessary ports)
sudo firewall-cmd --permanent --remove-service=cockpit
sudo firewall-cmd --permanent --remove-service=dhcpv6-client
sudo firewall-cmd --reload

# Enable SELinux (RHEL)
sudo setenforce 1
sudo sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config

# Keep system updated
sudo dnf update -y
```

**Network Segmentation:**
- Place AAP in management network/VPC
- Use firewall rules to restrict access
- Allow SSH only from AAP to target VMs
- Use VPN or private connectivity for AAP-to-GCP

**TLS/SSL Configuration:**
```bash
# Use valid SSL certificate (not self-signed in production)
# Configure in AAP installer inventory:
web_server_ssl_cert=/etc/pki/tls/certs/aap.crt
web_server_ssl_key=/etc/pki/tls/private/aap.key

# Enforce HTTPS only
# In /etc/nginx/nginx.conf:
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

**IP Whitelisting:**
```bash
# Restrict API access to known IPs (HCP Terraform, CI/CD)
# In AAP settings or nginx config:
location /api/ {
    allow 1.2.3.4;      # HCP Terraform IP
    allow 5.6.7.8;      # CI/CD IP
    deny all;
}
```

### 5. Monitoring and Auditing

**Enable Audit Logging:**
```bash
# AAP audit logs are enabled by default
# Location: /var/log/tower/tower.log

# Configure log retention
# In /etc/tower/settings.py:
LOG_AGGREGATOR_ENABLED = True
LOG_AGGREGATOR_LEVEL = 'INFO'

# Rotate logs
sudo vi /etc/logrotate.d/tower
# Add:
/var/log/tower/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    missingok
}
```

**Monitor for Security Events:**
```bash
# Failed login attempts
sudo grep "Failed login" /var/log/tower/tower.log

# Unauthorized API access
sudo grep "403\|401" /var/log/nginx/access.log

# Credential access
sudo grep "credential" /var/log/tower/tower.log | grep -i "access\|retrieve"

# Job failures
sudo grep "failed" /var/log/tower/tower.log | grep "job"
```

**Set Up Alerts:**
- Configure AAP notifications (email, Slack, PagerDuty)
- Alert on failed jobs
- Alert on authentication failures
- Alert on credential access
- Alert on template modifications

**Example Notification Configuration:**
```
Type: Slack
Name: Security Alerts
Webhook URL: https://hooks.slack.com/services/...
Channel: #security-alerts

Triggers:
- Job Failed
- Job Approval Required
- Workflow Failed
```

### 6. Compliance and Governance

**Audit Trail:**
- All job executions are logged with user, timestamp, and results
- Credential access is logged in Vault audit logs
- Template changes are tracked in AAP activity stream
- API calls are logged in nginx access logs

**Compliance Reports:**
```bash
# Generate job execution report
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "https://aap.example.com/api/v2/jobs/?page_size=100" | \
  jq '.results[] | {id, name, status, created, finished, created_by}'

# Export to CSV for compliance
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "https://aap.example.com/api/v2/jobs/?page_size=1000" | \
  jq -r '.results[] | [.id, .name, .status, .created, .created_by] | @csv' \
  > job_audit_report.csv
```

**Separation of Duties:**
- Different teams for infrastructure (Terraform) and configuration (Ansible)
- Approval workflows for production changes
- Read-only access for auditors
- Separate credentials for dev/test/prod

**Backup and Recovery:**
```bash
# Backup AAP database
sudo -u postgres pg_dump awx > /backup/aap_backup_$(date +%Y%m%d).sql

# Backup AAP configuration
sudo tar czf /backup/aap_config_$(date +%Y%m%d).tar.gz \
  /etc/tower/ \
  /var/lib/awx/projects/

# Test restore procedure quarterly
```

### 7. Incident Response

**Security Incident Checklist:**
1. **Detect:** Monitor logs and alerts
2. **Contain:** Revoke compromised credentials immediately
3. **Investigate:** Review audit logs for scope of breach
4. **Remediate:** Rotate all potentially affected credentials
5. **Document:** Record incident details and response actions
6. **Review:** Update security procedures based on lessons learned

**Emergency Credential Rotation:**
```bash
# 1. Revoke all AAP API tokens
# AAP UI → Administration → Users → [Each User] → Tokens → Delete All

# 2. Rotate Vault token
vault token revoke -self
vault login  # Generate new token

# 3. Rotate SSH keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu-key-new
# Update VM metadata with new public key
# Update Vault with new private key

# 4. Rotate GCP service account key
gcloud iam service-accounts keys create new-key.json \
  --iam-account=terraform@project.iam.gserviceaccount.com
vault kv put secret/gcp/service-account key=@new-key.json
gcloud iam service-accounts keys delete OLD_KEY_ID \
  --iam-account=terraform@project.iam.gserviceaccount.com

# 5. Test all integrations with new credentials
```

**Contact Information:**
- AAP Admin: admin@example.com
- Security Team: security@example.com
- Vault Admin: vault-admin@example.com
- On-Call: +1-555-0123

## Quick Reference

### Common AAP API Endpoints

```bash
# Set environment variables
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="<your-token>"

# Ping (health check, no auth)
curl -k ${AAP_URL}/api/v2/ping/

# Current user info
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/me/

# List job templates
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/job_templates/

# Get specific job template
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/job_templates/42/

# Launch job template
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"extra_vars": {"patch_type": "security"}}' \
  ${AAP_URL}/api/v2/job_templates/42/launch/

# Get job status
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/jobs/123/

# Get job output
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/jobs/123/stdout/?format=txt

# Cancel running job
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/jobs/123/cancel/
```

### Vault Secret Paths

```bash
# AAP API Token
vault kv get secret/aap/api-token
vault kv put secret/aap/api-token token="<token>" url="https://aap.example.com"

# SSH Private Key
vault kv get secret/ssh/ubuntu-key
vault kv put secret/ssh/ubuntu-key \
  private_key=@~/.ssh/ubuntu-key \
  public_key=@~/.ssh/ubuntu-key.pub

# GCP Service Account
vault kv get secret/gcp/service-account
vault kv put secret/gcp/service-account key=@service-account.json
```

### AAP CLI Commands

```bash
# Install AAP CLI
pip3 install awxkit

# Configure AAP CLI
export CONTROLLER_HOST=https://aap.example.com
export CONTROLLER_USERNAME=admin
export CONTROLLER_PASSWORD=<password>
# Or use token:
export CONTROLLER_OAUTH_TOKEN=<token>

# List resources
awx job_templates list
awx jobs list --status failed
awx credentials list

# Launch job
awx job_templates launch 42 --extra_vars '{"patch_type": "security"}'

# Monitor job
awx jobs monitor 123

# Get job output
awx jobs stdout 123
```

### Useful AAP Queries

```bash
# Find failed jobs in last 24 hours
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "${AAP_URL}/api/v2/jobs/?status=failed&created__gte=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S)" | \
  jq '.results[] | {id, name, created, failed_reason: .result_traceback}'

# Find jobs by template
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "${AAP_URL}/api/v2/jobs/?job_template=42" | \
  jq '.results[] | {id, status, created}'

# Find long-running jobs
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "${AAP_URL}/api/v2/jobs/?status=running" | \
  jq '.results[] | select(.elapsed > 3600) | {id, name, elapsed}'
```

### Configuration File Locations

```bash
# AAP Configuration
/etc/tower/settings.py              # Main settings
/etc/tower/conf.d/                  # Additional settings
/etc/nginx/nginx.conf               # Web server config

# AAP Data
/var/lib/awx/projects/              # Project files
/var/lib/awx/job_status/            # Job artifacts
/var/lib/awx/venv/                  # Virtual environments

# Logs
/var/log/tower/tower.log            # Main application log
/var/log/tower/dispatcher.log       # Job dispatcher
/var/log/tower/callback_receiver.log # Job output receiver
/var/log/nginx/access.log           # Web access log
/var/log/nginx/error.log            # Web error log

# Database
/var/lib/pgsql/data/                # PostgreSQL data (if local)
```

### Terraform Variables Reference

```hcl
# Required variables for AAP integration
variable "aap_api_url" {
  description = "AAP API base URL"
  type        = string
  default     = "https://aap.example.com"
}

variable "aap_job_template_id" {
  description = "AAP job template ID for VM patching"
  type        = number
  default     = 42
}

variable "vault_aap_token_path" {
  description = "Vault path for AAP API token"
  type        = string
  default     = "secret/aap/api-token"
}

variable "vault_addr" {
  description = "Vault server address"
  type        = string
  default     = "https://vault.example.com:8200"
}
```

## Next Steps

After completing this AAP setup:

1. ✅ AAP installed and accessible
2. ✅ Credentials configured with Vault integration
3. ✅ Job template created and tested
4. ✅ API token generated and stored in Vault
5. ✅ Integration with Terraform Actions configured
6. ➡️ **Next:** [HCP Terraform Workspace Setup](HCP_TERRAFORM_SETUP.md)
7. ➡️ **Next:** [Demonstration Workflow](DEMO_WORKFLOW.md)
8. ➡️ **Next:** [Troubleshooting Guide](TROUBLESHOOTING.md)

### Checklist for Production Deployment

Before deploying to production, ensure:

- [ ] AAP is installed with valid SSL certificate
- [ ] AAP is backed up regularly (database + configuration)
- [ ] All credentials are stored in Vault (no hardcoded secrets)
- [ ] API tokens are rotated on schedule (90 days)
- [ ] SSH keys are rotated on schedule (90 days)
- [ ] Job templates have appropriate access controls
- [ ] Audit logging is enabled and monitored
- [ ] Notifications are configured for failed jobs
- [ ] Network security is configured (firewall, IP whitelisting)
- [ ] Incident response procedures are documented
- [ ] Team is trained on AAP operations
- [ ] Disaster recovery plan is tested

### Performance Tuning

For large-scale deployments:

**Increase AAP Capacity:**
```python
# In /etc/tower/settings.py
SYSTEM_TASK_ABS_MEM = 6144  # MB
SYSTEM_TASK_ABS_CPU = 6     # CPU cores
```

**Scale Execution Nodes:**
- Add execution nodes for parallel job execution
- Use instance groups for workload distribution
- Configure capacity-based scheduling

**Database Optimization:**
```bash
# Tune PostgreSQL for AAP workload
sudo vi /var/lib/pgsql/data/postgresql.conf

# Recommended settings:
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10MB
min_wal_size = 1GB
max_wal_size = 4GB
```

**Job Optimization:**
```yaml
# In job template settings:
- Use forks for parallel execution
- Enable fact caching
- Use strategy: free for independent hosts
- Limit verbosity in production
```

## Additional Resources

- [AAP Documentation](https://docs.ansible.com/automation-controller/latest/)
- [AAP API Guide](https://docs.ansible.com/automation-controller/latest/html/controllerapi/)
- [AAP Credential Types](https://docs.ansible.com/automation-controller/latest/html/userguide/credentials.html)
- [Ansible Vault Integration](https://docs.ansible.com/automation-controller/latest/html/userguide/credential_plugins.html)
- [AAP Best Practices](https://docs.ansible.com/automation-controller/latest/html/userguide/best_practices.html)

## Requirements Satisfied

This guide satisfies the following requirements:
- **Requirement 5.1:** AAP has job templates configured for VM patching operations
- **Requirement 5.2:** Job templates linked to patching playbook
- **Requirement 5.3:** Job template accepts dynamic inventory from Terraform Actions
- **Requirement 5.4:** AAP retrieves credentials from Vault Enterprise
- **Requirement 5.5:** AAP provides API endpoints for Terraform Actions integration
- **Requirement 9.1:** Documentation provides step-by-step AAP setup instructions
