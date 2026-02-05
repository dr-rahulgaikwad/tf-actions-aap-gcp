# Ansible Automation Platform (AAP) Setup Guide

This guide walks you through configuring Ansible Automation Platform (AAP) for the Terraform Actions GCP Patching prototype.

## Prerequisites

- Ansible Automation Platform instance (version 2.4+)
- AAP admin access
- HashiCorp Vault configured and accessible
- GCP service account key stored in Vault
- SSH key pair for VM access stored in Vault

## Overview

This setup guide covers:
1. Accessing AAP and initial configuration
2. Creating credentials (Vault integration)
3. Creating an inventory
4. Creating a project for playbooks
5. Creating a job template
6. Generating API token for Terraform Actions
7. Testing the job template

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

### Issue: API Token Invalid

**Error:**
```
HTTP 401: Unauthorized
```

**Solution:**
1. Verify token is valid and not expired
2. Regenerate token if needed
3. Ensure token has correct scope (Write)

### Issue: Job Template Not Found

**Error:**
```
HTTP 404: Not Found
```

**Solution:**
1. Verify job template ID is correct
2. Check API endpoint URL
3. Ensure user has permission to access template

## Security Best Practices

1. **API Tokens:**
   - Use dedicated tokens for automation
   - Rotate tokens regularly (every 90 days)
   - Store tokens only in Vault
   - Use minimal scope (Write for job launch)

2. **Credentials:**
   - Use Vault for all sensitive data
   - Never hardcode credentials in playbooks
   - Enable credential auditing
   - Rotate SSH keys regularly

3. **Job Templates:**
   - Limit who can modify templates
   - Enable job approval for production
   - Use surveys for user input validation
   - Enable concurrent job limits

4. **Monitoring:**
   - Enable job notifications (email, Slack)
   - Monitor failed jobs
   - Review job logs regularly
   - Set up alerts for suspicious activity

## Next Steps

After completing this AAP setup:

1. ✅ AAP configured with job template
2. ✅ Credentials configured with Vault integration
3. ✅ API token generated and stored in Vault
4. ✅ Job template tested successfully
5. ➡️ **Next:** [HCP Terraform Workspace Setup](HCP_TERRAFORM_SETUP.md)
6. ➡️ **Next:** [Demonstration Workflow](DEMO_WORKFLOW.md)

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
