# Demonstration Workflow Guide

This guide provides a complete walkthrough of the Terraform Actions GCP Patching prototype, demonstrating the full Day 0 through Day 2 infrastructure lifecycle. This workflow is designed for a 15-minute demonstration showcasing HashiCorp's Terraform Actions feature for Day 2 operations management.

## Overview

This demonstration showcases:
- **Day 0/1**: Provisioning Ubuntu VMs on GCP using HCP Terraform
- **Day 2**: Triggering Ansible playbooks via Terraform Actions for OS patching
- **Integration**: Seamless integration between HCP Terraform, Ansible Automation Platform, and HashiCorp Vault

**Demo Duration**: 15 minutes  
**Target Audience**: Solutions architects, platform engineers, DevOps teams  
**Key Message**: Terraform Actions enables automated Day 2 operations from infrastructure code

## Prerequisites

Before starting the demonstration, ensure you have completed:

### 1. Environment Setup
- ✅ GCP project configured with required APIs enabled
- ✅ Service account created with appropriate IAM permissions
- ✅ HashiCorp Vault configured with all credentials
- ✅ Ansible Automation Platform accessible and configured
- ✅ HCP Terraform workspace created and configured

### 2. Credentials in Vault
Verify all required secrets are stored in Vault:

```bash
# Set Vault address and authenticate
export VAULT_ADDR="https://vault.example.com:8200"
vault login

# Verify GCP service account key
vault kv get secret/gcp/service-account

# Verify AAP API token
vault kv get secret/aap/api-token

# Verify SSH key pair
vault kv get secret/ssh/ubuntu-key
```

**Expected**: All three secrets should exist and contain valid data.

### 3. AAP Job Template
Verify the AAP job template is configured:

```bash
# Set AAP variables
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="<your-aap-token>"

# List job templates
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  ${AAP_URL}/api/v2/job_templates/ | jq '.results[] | {id, name}'
```

**Expected**: You should see "GCP VM Patching" job template with its ID.

### 4. Terraform Configuration
Verify your `terraform.tfvars` is configured:

```hcl
# GCP Configuration
gcp_project_id = "your-gcp-project-id"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# VM Configuration
vm_count        = 2
vm_machine_type = "e2-medium"

# Vault Configuration
vault_addr            = "https://vault.example.com:8200"
vault_gcp_secret_path = "secret/gcp/service-account"
vault_aap_token_path  = "secret/aap/api-token"
vault_ssh_key_path    = "secret/ssh/ubuntu-key"

# AAP Configuration
aap_api_url         = "https://aap.example.com"
aap_job_template_id = 42  # Use your actual job template ID

# Resource Tagging
environment = "demo"
managed_by  = "terraform"
```

## Demo Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    HCP Terraform                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Day 0/1    │  │   Day 2      │  │   Vault      │      │
│  │ Provisioning │  │   Actions    │  │ Integration  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │ Terraform        │ HTTP POST        │ Credential
          │ Apply            │ /api/v2/...      │ Retrieval
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   GCP VMs       │  │      AAP        │  │  Vault Server   │
│  ubuntu-vm-1    │  │  Job Template   │  │   Secrets:      │
│  ubuntu-vm-2    │  │   + Playbook    │  │   - GCP SA      │
│                 │  │   + Inventory   │  │   - AAP Token   │
│                 │  │                 │  │   - SSH Keys    │
└─────────────────┘  └────────┬────────┘  └─────────────────┘
          ▲                   │
          │                   │ SSH + Ansible
          │                   │ Patching
          └───────────────────┘
```

## Part 1: Day 0/1 - Infrastructure Provisioning

**Objective**: Provision Ubuntu VMs on GCP using HCP Terraform  
**Duration**: 5 minutes  
**Requirements**: 9.5, 10.1, 10.2

### Step 1.1: Initialize Terraform

Navigate to the Terraform directory and initialize:

```bash
cd terraform/

# Initialize Terraform (downloads providers)
terraform init

# Expected output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding latest version of hashicorp/google...
# - Finding latest version of hashicorp/vault...
# Terraform has been successfully initialized!
```

**Demo Talking Points**:
- Terraform uses HCP Terraform for remote state management
- Providers include Google Cloud and HashiCorp Vault
- Vault provider enables secure credential retrieval

### Step 1.2: Review Terraform Configuration

Show the key components of the infrastructure code:

```bash
# Show main resources
cat main.tf | grep -A 5 "resource \"google_compute_instance\""

# Show Vault integration
cat main.tf | grep -A 3 "data \"vault_generic_secret\""

# Show outputs
cat outputs.tf
```

**Demo Talking Points**:
- Infrastructure defined as code in Terraform
- Credentials retrieved from Vault (never hardcoded)
- Outputs provide VM details for Day 2 operations
- Resources include VMs, networking, and OS Config patch deployment

### Step 1.3: Plan Infrastructure Changes

Generate and review the execution plan:

```bash
# Create execution plan
terraform plan

# Expected output shows:
# - 2 google_compute_instance resources to be created
# - 1 google_compute_firewall resource to be created
# - 1 google_os_config_patch_deployment resource to be created
# Plan: 4 to add, 0 to change, 0 to destroy
```

**Demo Talking Points**:
- Terraform plan shows what will be created
- No credentials visible in plan output (retrieved from Vault)
- Resources include VMs, firewall rules, and patch deployment
- Plan can be reviewed before applying changes

### Step 1.4: Apply Infrastructure

Provision the infrastructure:

```bash
# Apply the configuration
terraform apply

# Review the plan and type 'yes' to confirm
# Expected: Provisioning takes 2-3 minutes
```

**Demo Talking Points**:
- Terraform provisions resources in GCP
- State is stored remotely in HCP Terraform
- Progress shown in real-time
- Outputs displayed after successful completion

### Step 1.5: Verify Infrastructure

Check the provisioned resources:

```bash
# View Terraform outputs
terraform output

# Expected output:
# vm_instance_ids = [
#   "1234567890123456789",
#   "9876543210987654321",
# ]
# vm_internal_ips = [
#   "10.128.0.2",
#   "10.128.0.3",
# ]
# vm_external_ips = [
#   "34.123.45.67",
#   "34.123.45.68",
# ]
# vm_names = [
#   "ubuntu-vm-1",
#   "ubuntu-vm-2",
# ]
# patch_deployment_id = "projects/.../patchDeployments/ubuntu-security-patches"
```

**Verify in GCP Console**:

```bash
# List VMs in GCP
gcloud compute instances list --project=<your-project-id>

# Expected: Two Ubuntu VMs running
```

**Demo Talking Points**:
- Infrastructure successfully provisioned
- VMs have both internal and external IPs
- Patch deployment configured for Day 2 operations
- Resources tagged for identification

### Step 1.6: Test VM Connectivity

Verify SSH access to VMs:

```bash
# Get VM external IP
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')

# Test SSH connection (using key from Vault)
ssh -o StrictHostKeyChecking=no ubuntu@${VM_IP} "uname -a"

# Expected output:
# Linux ubuntu-vm-1 5.15.0-xxx-generic #xxx-Ubuntu SMP ... x86_64 GNU/Linux
```

**Demo Talking Points**:
- VMs are accessible via SSH
- SSH key retrieved from Vault for authentication
- VMs running Ubuntu 22.04 LTS
- Ready for Day 2 operations

## Part 2: Day 2 - Triggering Patching via Terraform Actions

**Objective**: Trigger Ansible playbook to patch VMs using Terraform Actions  
**Duration**: 7 minutes  
**Requirements**: 9.6, 10.3, 10.4

### Step 2.1: Review Terraform Actions Configuration

Show the action configuration:

```bash
# View action configuration
cat actions.tf | grep -A 20 "action_metadata"

# View action payload structure
terraform output action_patch_vms_payload | jq .
```

**Demo Talking Points**:
- Terraform Actions defined in code
- Action integrates with AAP via HTTP API
- Payload includes VM inventory from Terraform state
- Credentials retrieved from Vault for AAP authentication

### Step 2.2: Configure Action in HCP Terraform

**Note**: This step may vary depending on HCP Terraform version and features.

**Option A: Using HCP Terraform UI**

1. Navigate to your workspace in HCP Terraform
2. Go to **Settings → Actions**
3. Click **Create Action**
4. Configure the action:
   - **Name**: `patch_vms`
   - **Display Name**: `Patch Ubuntu VMs`
   - **Description**: `Trigger Ansible playbook to patch VMs via AAP`
   - **Type**: `HTTP`
   - **Method**: `POST`
   - **URL**: Copy from `terraform output action_patch_vms_url`
   - **Headers**: 
     - `Content-Type: application/json`
   - **Authentication**: 
     - Type: `Bearer Token`
     - Token: Reference Vault secret `secret/aap/api-token`
   - **Body**: Copy from `terraform output action_patch_vms_payload`
5. Click **Save**

**Option B: Using Terraform Output as Reference**

If HCP Terraform Actions are not yet available, you can trigger AAP directly:

```bash
# Get action configuration
terraform output action_patch_vms_config

# Get AAP endpoint URL
AAP_URL=$(terraform output -raw action_patch_vms_url)

# Get AAP token from Vault
export VAULT_ADDR="https://vault.example.com:8200"
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Get action payload
terraform output -raw action_patch_vms_payload > /tmp/action_payload.json
```

**Demo Talking Points**:
- Terraform Actions bridge infrastructure and operations
- Action configuration stored in Terraform code
- Credentials managed securely via Vault
- Action can be triggered on-demand or scheduled

### Step 2.3: Trigger the Action

**Option A: Via HCP Terraform UI**

1. Navigate to your workspace
2. Go to **Actions** tab
3. Find **Patch Ubuntu VMs** action
4. Click **Run Action**
5. Review the action details
6. Click **Confirm** to execute

**Option B: Via API (Manual Trigger)**

```bash
# Trigger AAP job directly
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/action_payload.json \
  ${AAP_URL}

# Expected response:
# {
#   "id": 123,
#   "type": "job",
#   "url": "/api/v2/jobs/123/",
#   "status": "pending",
#   "job_template": 42
# }
```

**Demo Talking Points**:
- Action triggered with a single click
- Terraform passes VM inventory to AAP automatically
- No manual inventory management required
- Action execution tracked in both HCP Terraform and AAP

### Step 2.4: Monitor Action Execution in AAP

Navigate to AAP UI to monitor the job:

1. Open AAP UI: `https://aap.example.com`
2. Go to **Views → Jobs**
3. Find the most recent job (should be running)
4. Click on the job to view real-time output

**Expected Job Output**:

```
PLAY [Patch Ubuntu VMs] ********************************************************

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
skipped: [ubuntu-vm-1]
skipped: [ubuntu-vm-2]

TASK [Report patching status] **************************************************
ok: [ubuntu-vm-1] => {
    "msg": "Patching completed successfully on ubuntu-vm-1"
}
ok: [ubuntu-vm-2] => {
    "msg": "Patching completed successfully on ubuntu-vm-2"
}

PLAY RECAP *********************************************************************
ubuntu-vm-1                : ok=5    changed=2    unreachable=0    failed=0
ubuntu-vm-2                : ok=5    changed=2    unreachable=0    failed=0
```

**Demo Talking Points**:
- Ansible playbook executes against all VMs
- Real-time output shows progress
- Tasks include apt update, upgrade, and conditional reboot
- Job completes successfully with status summary

### Step 2.5: Verify Patching Results

Check that VMs were patched:

```bash
# SSH to first VM
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')
ssh ubuntu@${VM_IP} << 'EOF'
  # Check last apt update time
  echo "Last apt update:"
  stat /var/cache/apt/pkgcache.bin | grep Modify
  
  # Check for available updates
  echo -e "\nAvailable updates:"
  sudo apt list --upgradable 2>/dev/null | grep -v "Listing"
  
  # Check system uptime
  echo -e "\nSystem uptime:"
  uptime
EOF
```

**Expected Output**:
- Last apt update timestamp should be recent (within last few minutes)
- Available updates should be minimal or none
- Uptime shows system has been running (or recently rebooted)

**Demo Talking Points**:
- VMs successfully patched
- Security updates applied
- System remained available during patching
- Conditional reboot logic worked as expected

## Part 3: Verification and Validation

**Objective**: Verify the complete workflow and demonstrate observability  
**Duration**: 3 minutes  
**Requirements**: 10.1, 10.2, 10.3

### Step 3.1: Review Infrastructure State

Check the current state in HCP Terraform:

```bash
# Show current state
terraform show

# List all resources
terraform state list

# Expected output:
# data.google_compute_network.default
# data.vault_generic_secret.aap_token
# data.vault_generic_secret.gcp_credentials
# data.vault_generic_secret.ssh_key
# google_compute_firewall.allow_ssh
# google_compute_instance.ubuntu_vms[0]
# google_compute_instance.ubuntu_vms[1]
# google_os_config_patch_deployment.ubuntu_patches
```

**Demo Talking Points**:
- All infrastructure tracked in Terraform state
- State stored remotely in HCP Terraform
- Resources can be modified or destroyed via Terraform
- State provides single source of truth

### Step 3.2: Review AAP Job History

Check AAP for job execution history:

```bash
# List recent jobs
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  "${AAP_URL}/api/v2/jobs/?order_by=-created" | jq '.results[0:3] | .[] | {id, name, status, created}'

# Expected output:
# {
#   "id": 123,
#   "name": "GCP VM Patching",
#   "status": "successful",
#   "created": "2024-01-15T10:30:00Z"
# }
```

**Demo Talking Points**:
- AAP maintains complete job history
- Job status tracked (pending, running, successful, failed)
- Detailed logs available for troubleshooting
- Integration with monitoring and alerting systems

### Step 3.3: Review Vault Audit Logs

Check Vault for credential access:

```bash
# View recent audit logs (if audit logging is enabled)
vault audit list

# Expected: Audit device configured (file, syslog, etc.)
```

**Demo Talking Points**:
- Vault tracks all credential access
- Audit logs show who accessed what and when
- Credentials never exposed in Terraform or AAP logs
- Centralized secrets management across all systems

### Step 3.4: Review GCP Resources

Verify resources in GCP Console:

```bash
# List VMs
gcloud compute instances list --project=<your-project-id>

# List firewall rules
gcloud compute firewall-rules list --project=<your-project-id> | grep patching

# List patch deployments
gcloud compute os-config patch-deployments list --project=<your-project-id>
```

**Demo Talking Points**:
- All resources visible in GCP Console
- Resources tagged with environment and management labels
- Patch deployment configured for ongoing operations
- Infrastructure matches Terraform configuration

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Terraform Apply Fails - API Not Enabled

**Error**:
```
Error: Error creating instance: googleapi: Error 403: Compute Engine API has not been used
```

**Solution**:
```bash
# Enable required APIs
gcloud services enable compute.googleapis.com --project=<your-project-id>
gcloud services enable osconfig.googleapis.com --project=<your-project-id>

# Retry terraform apply
terraform apply
```

#### Issue 2: Vault Connection Failed

**Error**:
```
Error: Error making API request to Vault
```

**Solution**:
```bash
# Verify Vault address
echo $VAULT_ADDR

# Test Vault connectivity
vault status

# Re-authenticate
vault login

# Verify secrets exist
vault kv get secret/gcp/service-account
vault kv get secret/aap/api-token
vault kv get secret/ssh/ubuntu-key
```

#### Issue 3: SSH Connection to VMs Fails

**Error**:
```
ssh: connect to host 34.123.45.67 port 22: Connection refused
```

**Solution**:
```bash
# Check VM status
gcloud compute instances list --project=<your-project-id>

# Verify firewall rule
gcloud compute firewall-rules describe allow-ssh-patching-demo --project=<your-project-id>

# Check SSH key in VM metadata
gcloud compute instances describe ubuntu-vm-1 --zone=us-central1-a --project=<your-project-id> | grep ssh-keys

# Wait 1-2 minutes for VM to fully boot, then retry
```

#### Issue 4: AAP Job Fails - Inventory Empty

**Error**:
```
ERROR! Inventory is empty
```

**Solution**:
```bash
# Verify action payload includes inventory
terraform output action_patch_vms_payload | jq '.extra_vars.vm_inventory'

# Verify job template accepts extra_vars
# In AAP UI: Resources → Templates → GCP VM Patching → Edit
# Ensure "Prompt on launch" is enabled for "Variables"

# Verify inventory structure matches expected format
# Should have: all.hosts.<vm-name>.ansible_host
```

#### Issue 5: AAP Job Fails - SSH Authentication

**Error**:
```
FAILED! => {"msg": "Failed to connect to the host via ssh: Permission denied (publickey)"}
```

**Solution**:
```bash
# Verify SSH key in Vault matches VM metadata
vault kv get secret/ssh/ubuntu-key

# Test SSH manually
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/test-key ubuntu@${VM_IP}

# Verify AAP credential is configured correctly
# In AAP UI: Resources → Credentials → GCP Ubuntu SSH Key
# Ensure it references the correct Vault path

# Verify AAP can reach VM IPs
# From AAP controller: ping <vm-ip>
```

#### Issue 6: Terraform Actions Not Available

**Error**:
```
Terraform Actions feature not found in HCP Terraform
```

**Solution**:
```bash
# Terraform Actions may require specific HCP Terraform tier
# Alternative: Trigger AAP directly via API

# Get action configuration
AAP_URL=$(terraform output -raw action_patch_vms_url)
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Trigger job manually
terraform output -raw action_patch_vms_payload > /tmp/payload.json
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/payload.json \
  ${AAP_URL}
```

#### Issue 7: Playbook Fails - apt Lock

**Error**:
```
FAILED! => {"msg": "Could not get lock /var/lib/apt/lists/lock"}
```

**Solution**:
```bash
# Another process is using apt (common on fresh VMs)
# Wait 2-3 minutes for automatic updates to complete

# Check if unattended-upgrades is running
ssh ubuntu@${VM_IP} "ps aux | grep apt"

# Wait for process to complete, then retry AAP job
# Or modify playbook to include retry logic (already implemented)
```

#### Issue 8: VMs Not Reachable from AAP

**Error**:
```
FAILED! => {"msg": "Failed to connect to the host via ssh: No route to host"}
```

**Solution**:
```bash
# Verify network connectivity from AAP to GCP
# From AAP controller:
ssh admin@aap.example.com
ping <vm-external-ip>
telnet <vm-external-ip> 22

# Check GCP firewall rules allow traffic from AAP
gcloud compute firewall-rules list --project=<your-project-id>

# Verify AAP has internet access to reach GCP external IPs
# Check AAP network configuration and firewall rules
```

### Debugging Tips

**Enable Verbose Terraform Output**:
```bash
export TF_LOG=DEBUG
terraform apply
```

**Enable Verbose Ansible Output**:
In AAP job template, set verbosity to 3 or 4 for detailed output.

**Check AAP Logs**:
```bash
ssh admin@aap.example.com
sudo tail -f /var/log/tower/tower.log
sudo tail -f /var/log/tower/dispatcher.log
```

**Check Vault Audit Logs**:
```bash
# If audit logging is enabled
vault audit list
# Check configured audit log location
```

**Test API Endpoints**:
```bash
# Test AAP API
curl -k https://aap.example.com/api/v2/ping/

# Test Vault API
curl -k https://vault.example.com:8200/v1/sys/health
```

## Demo Tips and Best Practices

### Before the Demo

1. **Pre-provision Infrastructure** (Optional):
   - If demo time is limited, provision VMs beforehand
   - Focus demo on Terraform Actions and Day 2 operations
   - Show Terraform code and state, but skip apply step

2. **Verify All Credentials**:
   - Test Vault connectivity and secret retrieval
   - Verify AAP is accessible and job template works
   - Test SSH access to a test VM

3. **Prepare Backup Plan**:
   - Have screenshots ready in case of connectivity issues
   - Prepare recorded video of successful workflow
   - Have pre-provisioned environment as fallback

4. **Clean Up Previous Runs**:
   ```bash
   # Destroy any existing infrastructure
   terraform destroy -auto-approve
   
   # Clear AAP job history (optional)
   # Delete old jobs in AAP UI
   ```

### During the Demo

1. **Set Expectations**:
   - Explain this is a prototype, not production-ready
   - Highlight key concepts: Day 0/1/2, Terraform Actions, Vault integration
   - Mention this approach scales to hundreds of VMs

2. **Focus on Key Messages**:
   - Infrastructure as Code with Terraform
   - Secure credential management with Vault
   - Automated Day 2 operations with Terraform Actions
   - Integration between Terraform and Ansible

3. **Handle Questions**:
   - Pause for questions at natural breakpoints
   - Offer to dive deeper into specific areas
   - Acknowledge limitations and areas for improvement

4. **Show, Don't Just Tell**:
   - Open files and show actual code
   - Display real-time output and logs
   - Navigate between HCP Terraform, AAP, and GCP Console

### After the Demo

1. **Provide Resources**:
   - Share GitHub repository link
   - Provide setup documentation
   - Offer follow-up consultation

2. **Clean Up Resources**:
   ```bash
   # Destroy infrastructure to avoid charges
   terraform destroy
   
   # Verify all resources deleted
   gcloud compute instances list --project=<your-project-id>
   ```

3. **Gather Feedback**:
   - Ask for questions and feedback
   - Note areas of interest for follow-up
   - Identify potential use cases for the audience

## Advanced Scenarios

### Scenario 1: Scheduled Patching

**Objective**: Automate patching on a schedule

**Implementation**:
1. Configure HCP Terraform scheduled runs
2. Set schedule (e.g., every Sunday at 2 AM)
3. Terraform Action triggers automatically on schedule
4. VMs patched without manual intervention

**Demo Talking Points**:
- Patching can be fully automated
- Schedule aligns with maintenance windows
- Notifications sent on success or failure
- Audit trail maintained in HCP Terraform and AAP

### Scenario 2: Multi-Environment Patching

**Objective**: Patch dev, staging, and production environments

**Implementation**:
1. Create separate HCP Terraform workspaces per environment
2. Use workspace-specific variables
3. Trigger actions per environment
4. Implement approval gates for production

**Demo Talking Points**:
- Same code, different environments
- Progressive rollout (dev → staging → prod)
- Approval workflows for production changes
- Environment-specific configurations

### Scenario 3: Emergency Patching

**Objective**: Rapidly patch critical vulnerabilities

**Implementation**:
1. Trigger Terraform Action immediately
2. Override reboot_allowed to true
3. Monitor job execution in real-time
4. Verify patch applied across all VMs

**Demo Talking Points**:
- On-demand patching for critical issues
- Rapid response to security vulnerabilities
- Automated rollout across entire fleet
- Verification and compliance reporting

### Scenario 4: Integration with ServiceNow

**Objective**: Create change tickets for patching operations

**Implementation**:
1. Configure HCP Terraform notifications
2. Integrate with ServiceNow via webhook
3. Create change ticket when action triggered
4. Update ticket with job status

**Demo Talking Points**:
- Integration with ITSM processes
- Automated change management
- Compliance and audit requirements
- Notification to stakeholders

## Conclusion

This demonstration showcases a complete infrastructure lifecycle:

1. **Day 0/1**: Infrastructure provisioned with Terraform
2. **Day 2**: Operations automated with Terraform Actions
3. **Security**: Credentials managed with Vault
4. **Integration**: Seamless workflow across multiple platforms

**Key Takeaways**:
- Terraform Actions bridge infrastructure and operations
- Day 2 operations automated from infrastructure code
- Secure credential management with Vault
- Scalable approach for managing hundreds of VMs
- Integration between Terraform, Ansible, and cloud platforms

**Next Steps**:
- Explore additional Day 2 operations (backups, monitoring, scaling)
- Implement in your own environment
- Extend to other cloud platforms (AWS, Azure)
- Integrate with existing ITSM and monitoring tools

## Requirements Satisfied

This demonstration workflow guide satisfies the following requirements:

- **Requirement 9.5**: Documentation provides troubleshooting guidance for common issues ✓
- **Requirement 9.6**: Documentation includes demonstration workflow steps ✓
- **Requirement 10.1**: Prototype demonstrates complete Day 0 through Day 2 workflow ✓
- **Requirement 10.2**: System shows VM provisioning in under 5 minutes ✓
- **Requirement 10.3**: System shows AAP job execution triggered from Terraform ✓
- **Requirement 10.4**: Implementation is simple enough to explain in a 15-minute demo ✓

## Additional Resources

- [GCP Setup Guide](GCP_SETUP.md) - Detailed GCP project configuration
- [AAP Setup Guide](AAP_SETUP.md) - Ansible Automation Platform configuration
- [HCP Terraform Workspace Setup](HCP_TERRAFORM_SETUP.md) - Workspace configuration
- [Terraform Actions Documentation](https://www.terraform.io/docs/cloud/actions) - Official documentation
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) - Ansible playbook guidelines
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs) - Vault secrets management

---

**Document Version**: 1.0  
**Last Updated**: 2024-01-15  
**Maintained By**: Platform Engineering Team
