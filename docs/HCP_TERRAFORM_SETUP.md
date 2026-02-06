# HCP Terraform Workspace Setup Guide

This guide walks you through configuring an HCP Terraform workspace for the Terraform Actions GCP Patching prototype.

## Prerequisites

- HCP Terraform account (sign up at https://app.terraform.io)
- Terraform CLI installed (version 1.7.0 or higher)
- HashiCorp Vault configured with required secrets
- GCP project configured (see [GCP Setup Guide](GCP_SETUP.md))
- AAP configured (see [AAP Setup Guide](AAP_SETUP.md))
- Git repository with Terraform code (optional but recommended)

## Overview

This setup guide covers:
1. Creating an HCP Terraform organization and workspace
2. Configuring workspace settings
3. Setting up Vault integration
4. Configuring workspace variables
5. Connecting to version control (optional)
6. Running your first Terraform plan
7. Configuring Terraform Actions
8. Testing the complete workflow

## HCP Terraform Architecture

Understanding how HCP Terraform works helps with configuration:

```
┌─────────────────────────────────────────────────────────────┐
│                    HCP Terraform Cloud                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web UI     │  │   REST API   │  │   VCS Conn   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                           │                                  │
│                  ┌────────▼────────┐                         │
│                  │   Workspace     │                         │
│                  │  - State        │                         │
│                  │  - Variables    │                         │
│                  │  - Runs         │                         │
│                  └─────────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Terraform Runs
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Terraform Execution Environment                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Plan Phase  │  │  Apply Phase │  │   Actions    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Provider API Calls
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Systems                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     GCP      │  │     Vault    │  │     AAP      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

**Key Components:**
- **Organization:** Top-level container for workspaces and teams
- **Workspace:** Isolated environment for Terraform state and configuration
- **State:** Remote storage for infrastructure state
- **Variables:** Configuration values (Terraform and environment variables)
- **Runs:** Terraform plan and apply executions
- **Actions:** Day 2 operations that trigger external systems

## Step 1: Create HCP Terraform Organization

### 1.1: Sign Up for HCP Terraform

1. Navigate to https://app.terraform.io
2. Click **Sign Up** or **Create Account**
3. Choose authentication method:
   - GitHub
   - GitLab
   - Email/Password
4. Complete registration and verify email

### 1.2: Create Organization

After signing in:

1. Click **Create Organization**
2. **Organization Name:** Choose a unique name (e.g., `my-company-terraform`)
   - Must be globally unique
   - Use lowercase letters, numbers, and hyphens
   - Cannot be changed later
3. **Email:** Your organization contact email
4. Click **Create Organization**

**Note:** You can also join an existing organization if invited by an admin.

### 1.3: Verify Organization

```bash
# Set organization name
export TFC_ORG="my-company-terraform"

# Authenticate with HCP Terraform
terraform login

# This will open a browser to generate a token
# Copy the token and paste it in the terminal
```

**Expected Output:**
```
Success! Terraform has obtained and saved an API token.

The new API token will be used for any future Terraform command that must make
authenticated requests to app.terraform.io.
```

## Step 2: Create Workspace

### 2.1: Create Workspace via UI

Navigate to: **Workspaces → New Workspace**

**Choose Workflow:**
- **Version Control Workflow:** Recommended for production (connects to Git)
- **CLI-Driven Workflow:** Good for demos and testing (manual runs)
- **API-Driven Workflow:** For advanced automation

For this guide, we'll use **CLI-Driven Workflow** for simplicity.

**Workspace Configuration:**
- **Workspace Name:** `gcp-patching-demo` (or your preferred name)
- **Description:** `Terraform Actions prototype for GCP VM patching with AAP`
- **Project:** Default (or create a new project)

Click **Create Workspace**

### 2.2: Create Workspace via Terraform CLI

Alternatively, configure the workspace in your `versions.tf`:

```hcl
terraform {
  cloud {
    organization = "my-company-terraform"  # Replace with your org

    workspaces {
      name = "gcp-patching-demo"
    }
  }
}
```

Then initialize:

```bash
cd terraform/
terraform init
```

This will create the workspace automatically if it doesn't exist.

### 2.3: Verify Workspace Creation

```bash
# List workspaces
terraform workspace list

# Or via HCP Terraform UI
# Navigate to: Workspaces → [Your Workspace]
```

## Step 3: Configure Workspace Settings

### 3.1: General Settings

Navigate to: **Workspaces → gcp-patching-demo → Settings → General**

**Execution Mode:** Remote (default)
- Terraform runs execute in HCP Terraform's infrastructure
- Provides consistent environment and audit logging

**Terraform Version:** 1.7.0 or higher
- Select latest stable version
- Or use "Latest" to auto-upgrade

**Terraform Working Directory:** (leave empty)
- Uses repository root
- Set to `terraform/` if your code is in a subdirectory

**Apply Method:**
- **Auto apply:** Automatically applies after successful plan (use with caution)
- **Manual apply:** Requires manual confirmation (recommended for demos)

**Remote State Sharing:**
- Configure if other workspaces need to read this workspace's state
- Not required for this prototype

Click **Save Settings**

### 3.2: Notifications (Optional)

Configure notifications for run events:

Navigate to: **Settings → Notifications → Add Notification**

**Notification Types:**
- Slack
- Email
- Microsoft Teams
- Webhook

**Triggers:**
- Run needs attention
- Run errored
- Run completed


### 3.3: Run Triggers (Optional)

Configure automatic runs based on other workspace changes:

Navigate to: **Settings → Run Triggers**

This is useful for multi-workspace dependencies but not required for this prototype.

## Step 4: Configure Vault Integration

HCP Terraform needs to authenticate with Vault to retrieve secrets.

### 4.1: Vault Dynamic Provider Credentials (Recommended)

HCP Terraform can authenticate to Vault using dynamic credentials without storing tokens.

**Prerequisites:**
- Vault Enterprise or HCP Vault
- JWT auth method configured in Vault

**Vault Configuration:**

```bash
# Enable JWT auth method
vault auth enable jwt

# Configure JWT auth for HCP Terraform
vault write auth/jwt/config \
  bound_issuer="https://app.terraform.io" \
  oidc_discovery_url="https://app.terraform.io"

# Create policy for Terraform
vault policy write terraform-gcp-patching - <<EOF
path "secret/data/gcp/service-account" {
  capabilities = ["read"]
}
path "secret/data/aap/api-token" {
  capabilities = ["read"]
}
path "secret/data/ssh/ubuntu-key" {
  capabilities = ["read"]
}
EOF

# Create role for workspace
vault write auth/jwt/role/gcp-patching-demo \
  role_type="jwt" \
  bound_audiences="vault.workload.identity" \
  bound_claims_type="glob" \
  bound_claims='{"sub": "organization:my-company-terraform:project:*:workspace:gcp-patching-demo:run_phase:*"}' \
  user_claim="terraform_full_workspace" \
  policies="terraform-gcp-patching" \
  ttl="1h"
```


**HCP Terraform Configuration:**

Navigate to: **Settings → Variable Sets → Create Variable Set**

**Variable Set Name:** `Vault Integration`  
**Scope:** Apply to specific workspaces → Select `gcp-patching-demo`

**Add Variables:**

| Key | Value | Category | Sensitive |
|-----|-------|----------|-----------|
| `TFC_VAULT_PROVIDER_AUTH` | `true` | Environment | No |
| `TFC_VAULT_ADDR` | `https://vault.example.com:8200` | Environment | No |
| `TFC_VAULT_RUN_ROLE` | `gcp-patching-demo` | Environment | No |

Click **Create Variable Set**

### 4.2: Vault Static Token (Alternative)

If dynamic credentials are not available, use a static Vault token:

**Generate Vault Token:**

```bash
# Create token with appropriate policy
vault token create \
  -policy=terraform-gcp-patching \
  -period=720h \
  -display-name="HCP Terraform - gcp-patching-demo"

# Copy the token value
```

**Configure in HCP Terraform:**

Navigate to: **Settings → Variables → Add Variable**

| Key | Value | Category | Sensitive |
|-----|-------|----------|-----------|
| `VAULT_TOKEN` | `<your-vault-token>` | Environment | ✅ Yes |
| `VAULT_ADDR` | `https://vault.example.com:8200` | Environment | No |

**⚠️ Security Note:** Static tokens should be rotated regularly (every 90 days recommended).

### 4.3: Verify Vault Integration

Test Vault connectivity from a Terraform run:

```bash
cd terraform/
terraform plan
```

If Vault integration is working, you should see:
```
data.vault_generic_secret.gcp_credentials: Reading...
data.vault_generic_secret.gcp_credentials: Read complete
```


## Step 5: Configure Workspace Variables

Configure all required Terraform and environment variables for the workspace.

### 5.1: Terraform Variables

Navigate to: **Variables → Add Variable → Terraform Variable**

Add the following variables:

| Variable Name | Value | Description | Sensitive |
|--------------|-------|-------------|-----------|
| `gcp_project_id` | `your-gcp-project-id` | GCP project identifier | No |
| `gcp_region` | `us-central1` | GCP region for resources | No |
| `gcp_zone` | `us-central1-a` | GCP zone for VMs | No |
| `vm_count` | `2` | Number of VMs to provision | No |
| `vm_machine_type` | `e2-medium` | GCP machine type | No |
| `ubuntu_image` | `ubuntu-os-cloud/ubuntu-2204-lts` | Ubuntu OS image | No |
| `vault_addr` | `https://vault.example.com:8200` | Vault server address | No |
| `vault_gcp_secret_path` | `secret/gcp/service-account` | Vault path for GCP creds | No |
| `vault_aap_token_path` | `secret/aap/api-token` | Vault path for AAP token | No |
| `vault_ssh_key_path` | `secret/ssh/ubuntu-key` | Vault path for SSH key | No |
| `aap_api_url` | `https://aap.example.com` | AAP API endpoint | No |
| `aap_job_template_id` | `42` | AAP job template ID | No |
| `environment` | `demo` | Environment label | No |
| `managed_by` | `terraform` | Management tool label | No |

**Tips:**
- Use HCL syntax for complex types (lists, maps)
- Mark sensitive values appropriately
- Use variable sets for shared variables across workspaces

### 5.2: Environment Variables

Environment variables are used by providers and tools during Terraform runs.

Navigate to: **Variables → Add Variable → Environment Variable**

| Variable Name | Value | Description | Sensitive |
|--------------|-------|-------------|-----------|
| `VAULT_ADDR` | `https://vault.example.com:8200` | Vault address for provider | No |
| `VAULT_TOKEN` | `<vault-token>` | Vault auth token (if not using dynamic creds) | ✅ Yes |
| `GOOGLE_CREDENTIALS` | (not needed) | GCP creds retrieved from Vault | N/A |


**Note:** We don't set `GOOGLE_CREDENTIALS` because the Terraform code retrieves GCP credentials from Vault dynamically.

### 5.3: Variable Sets (Optional but Recommended)

Variable sets allow you to share variables across multiple workspaces.

Navigate to: **Settings → Variable Sets → Create Variable Set**

**Example: Vault Configuration Variable Set**

**Name:** `Vault Configuration`  
**Scope:** Apply to all workspaces in organization

**Variables:**
- `vault_addr` = `https://vault.example.com:8200` (Terraform)
- `VAULT_ADDR` = `https://vault.example.com:8200` (Environment)

**Example: GCP Project Variable Set**

**Name:** `GCP Demo Project`  
**Scope:** Apply to specific workspaces

**Variables:**
- `gcp_project_id` = `your-gcp-project-id` (Terraform)
- `gcp_region` = `us-central1` (Terraform)
- `gcp_zone` = `us-central1-a` (Terraform)

### 5.4: Verify Variables

Check that all required variables are set:

Navigate to: **Variables** tab

You should see:
- ✅ All Terraform variables from Step 5.1
- ✅ All Environment variables from Step 5.2
- ✅ No missing required variables

## Step 6: Configure Version Control Integration (Optional)

Connecting your workspace to a Git repository enables automatic runs on code changes.

### 6.1: Connect to VCS Provider

Navigate to: **Settings → Version Control**

**Choose VCS Provider:**
- GitHub
- GitLab
- Bitbucket
- Azure DevOps

Click **Connect to [Provider]** and authorize HCP Terraform.

### 6.2: Select Repository

**Repository:** `your-org/terraform-actions-gcp-patching`  
**Branch:** `main` (or your default branch)  
**Working Directory:** (leave empty or set to `terraform/`)

**VCS Triggers:**
- ✅ Automatic speculative plans (for pull requests)
- ✅ Automatic runs (for commits to main branch)


**Trigger Patterns (Optional):**
- Trigger runs only for specific paths: `terraform/**/*`
- Skip runs for documentation changes: `!docs/**/*`

Click **Update VCS Settings**

### 6.3: Test VCS Integration

Make a small change to your Terraform code and push to the repository:

```bash
# Make a change
echo "# Test VCS integration" >> terraform/README.md

# Commit and push
git add terraform/README.md
git commit -m "Test HCP Terraform VCS integration"
git push origin main
```

Check HCP Terraform UI:
- Navigate to **Runs** tab
- You should see a new run triggered automatically
- The run should show the commit message and author

### 6.4: CLI-Driven Workflow (Alternative)

If you prefer manual control, skip VCS integration and use CLI-driven workflow:

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

This is recommended for demos and testing.

## Step 7: Run Your First Terraform Plan

### 7.1: Initialize Terraform

```bash
cd terraform/

# Initialize Terraform with HCP Terraform backend
terraform init

# Expected output:
# Initializing HCP Terraform...
# Terraform has been successfully initialized!
```

### 7.2: Run Terraform Plan

```bash
terraform plan
```

**What Happens:**
1. Terraform uploads your configuration to HCP Terraform
2. HCP Terraform starts a remote run
3. Terraform retrieves credentials from Vault
4. Terraform generates an execution plan
5. Plan output is streamed to your terminal

**Expected Output:**
```
Running plan in HCP Terraform...

Terraform will perform the following actions:

  # google_compute_instance.ubuntu_vms[0] will be created
  + resource "google_compute_instance" "ubuntu_vms" {
      + name         = "ubuntu-vm-1"
      + machine_type = "e2-medium"
      ...
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```


### 7.3: Review Plan in UI

Navigate to: **Workspaces → gcp-patching-demo → Runs**

Click on the latest run to see:
- **Plan Output:** Detailed resource changes
- **Cost Estimation:** Estimated monthly cost (if enabled)
- **Policy Checks:** Sentinel policy results (if configured)
- **Run Details:** Duration, user, commit info

### 7.4: Apply the Plan

If the plan looks good, apply it:

```bash
terraform apply
```

Or from the UI:
- Navigate to the run
- Click **Confirm & Apply**
- Add a comment (optional)
- Click **Confirm Plan**

**Monitor Progress:**
- Watch real-time logs in terminal or UI
- Typical apply time: 3-5 minutes for 2 VMs

**Expected Result:**
```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

patch_deployment_id = "ubuntu-security-patches"
vm_external_ips = [
  "34.123.45.67",
  "34.123.45.68",
]
vm_instance_ids = [
  "1234567890123456789",
  "9876543210987654321",
]
vm_internal_ips = [
  "10.128.0.2",
  "10.128.0.3",
]
vm_names = [
  "ubuntu-vm-1",
  "ubuntu-vm-2",
]
```

### 7.5: Verify Infrastructure

Check that resources were created:

```bash
# List VMs in GCP
gcloud compute instances list --project=<your-project-id>

# Check Terraform state
terraform state list

# View specific resource
terraform state show google_compute_instance.ubuntu_vms[0]
```

## Step 8: Configure Terraform Actions

Terraform Actions enable Day 2 operations by triggering external systems (like AAP) from HCP Terraform.


### 8.1: Verify Actions Configuration in Code

Check that your Terraform code includes the action definition (should be in `terraform/main.tf` or `terraform/actions.tf`):

```hcl
# Retrieve AAP token from Vault
data "vault_generic_secret" "aap_token" {
  path = var.vault_aap_token_path
}

# Define Terraform Action for VM patching
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

**Note:** As of early 2024, Terraform Actions is a preview feature. The exact syntax may vary. Check the latest documentation at https://developer.hashicorp.com/terraform/cloud-docs/actions

### 8.2: Enable Actions in Workspace

Navigate to: **Settings → Actions**

- ✅ Enable Terraform Actions
- Configure action execution permissions
- Set up action notifications (optional)

### 8.3: View Available Actions

After applying your Terraform configuration with actions defined:

Navigate to: **Actions** tab

You should see:
- **Action Name:** Patch Ubuntu VMs
- **Description:** Trigger Ansible playbook to patch VMs via AAP
- **Status:** Ready
- **Last Run:** Never (initially)


## Step 9: Test the Complete Workflow

### 9.1: Trigger Terraform Action

**Via UI:**
1. Navigate to: **Actions** tab
2. Find "Patch Ubuntu VMs" action
3. Click **Run Action**
4. Review the payload (optional)
5. Click **Confirm**

**Via API:**
```bash
# Set variables
export TFC_TOKEN="<your-hcp-terraform-token>"
export TFC_ORG="my-company-terraform"
export TFC_WORKSPACE="gcp-patching-demo"
export ACTION_ID="patch_vms"

# Trigger action
curl -X POST \
  -H "Authorization: Bearer ${TFC_TOKEN}" \
  -H "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces/${TFC_WORKSPACE}/actions/${ACTION_ID}/runs"
```

### 9.2: Monitor Action Execution

**In HCP Terraform:**
- Navigate to: **Actions → Runs**
- View action execution status
- Check logs and output

**In AAP:**
- Navigate to: **Views → Jobs**
- Find the triggered job
- View real-time playbook output
- Verify job completes successfully

### 9.3: Verify Patching Results

SSH to a VM and verify patches were applied:

```bash
# Get VM IP from Terraform outputs
terraform output vm_external_ips

# SSH to VM
ssh ubuntu@<vm-ip>

# Check last apt update
stat /var/cache/apt/pkgcache.bin

# Check for available updates
sudo apt list --upgradable

# Check system uptime (if reboot occurred)
uptime

# Check patch logs
sudo cat /var/log/apt/history.log | tail -20
```

### 9.4: End-to-End Workflow Verification

Verify the complete Day 0 → Day 1 → Day 2 workflow:

**✅ Day 0/1: Infrastructure Provisioning**
- [x] HCP Terraform workspace configured
- [x] Vault integration working
- [x] GCP VMs provisioned successfully
- [x] OS Config patch deployment created
- [x] Terraform outputs available

**✅ Day 2: Operations**
- [x] Terraform Action defined and visible
- [x] Action triggers AAP job template
- [x] AAP executes Ansible playbook
- [x] VMs receive security patches
- [x] Results visible in both HCP Terraform and AAP


## Troubleshooting

### Issue: Terraform Init Fails with Authentication Error

**Error:**
```
Error: Failed to request discovery document: 401 Unauthorized
```

**Solution:**
```bash
# Re-authenticate with HCP Terraform
terraform login

# Verify credentials
cat ~/.terraform.d/credentials.tfrc.json

# Try init again
terraform init
```

### Issue: Vault Connection Fails

**Error:**
```
Error: Error making API request to Vault
```

**Solution:**
1. Verify Vault address is correct in variables
2. Check Vault token is valid and not expired:
```bash
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="<your-token>"
vault token lookup
```
3. Verify network connectivity from HCP Terraform to Vault
4. Check Vault policy allows required paths
5. Review HCP Terraform run logs for detailed error

### Issue: GCP Provider Authentication Fails

**Error:**
```
Error: google: could not find default credentials
```

**Solution:**
1. Verify Vault secret path is correct: `vault_gcp_secret_path`
2. Check GCP service account key is stored in Vault:
```bash
vault kv get secret/gcp/service-account
```
3. Verify the key format is valid JSON
4. Check Terraform code retrieves credentials correctly:
```hcl
data "vault_generic_secret" "gcp_credentials" {
  path = var.vault_gcp_secret_path
}

provider "google" {
  credentials = data.vault_generic_secret.gcp_credentials.data["key"]
  ...
}
```

### Issue: Variables Not Set

**Error:**
```
Error: No value for required variable
```

**Solution:**
1. Navigate to: **Variables** tab in workspace
2. Verify all required variables are set
3. Check variable names match exactly (case-sensitive)
4. For Terraform variables, ensure they're marked as "Terraform variable" not "Environment variable"
5. Save and retry the run

### Issue: Workspace State Locked

**Error:**
```
Error: Error acquiring the state lock
```

**Solution:**
1. Check if another run is in progress
2. Wait for the current run to complete
3. If stuck, force unlock (use with caution):
```bash
terraform force-unlock <lock-id>
```
4. Or from UI: **Settings → General → Force Unlock**


### Issue: Cost Estimation Shows Unexpected Costs

**Error:**
High estimated monthly costs for demo resources

**Solution:**
1. Review the resources being created
2. Check machine types (e2-medium is cost-effective)
3. Verify VM count is set to 2 (not 10)
4. Remember to destroy resources after demo:
```bash
terraform destroy
```

### Issue: Terraform Actions Not Visible

**Error:**
Actions tab shows no actions

**Solution:**
1. Verify Terraform Actions is enabled in workspace settings
2. Check that action resource is defined in Terraform code
3. Ensure latest apply completed successfully
4. Refresh the page or clear browser cache
5. Check HCP Terraform version supports Actions (preview feature)

### Issue: Action Fails to Trigger AAP

**Error:**
```
Error: HTTP request failed: 401 Unauthorized
```

**Solution:**
1. Verify AAP API token is valid:
```bash
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  https://aap.example.com/api/v2/me/
```
2. Check token is stored correctly in Vault:
```bash
vault kv get secret/aap/api-token
```
3. Verify AAP URL is correct (include https://)
4. Check job template ID is correct
5. Ensure AAP is accessible from HCP Terraform (network/firewall)

### Issue: Plan Shows No Changes When Expected

**Error:**
Terraform plan shows no changes after code modifications

**Solution:**
1. Verify you're in the correct workspace:
```bash
terraform workspace show
```
2. Check that code changes were saved
3. For VCS-driven workflow, ensure changes are pushed to Git
4. Clear local cache and re-init:
```bash
rm -rf .terraform/
terraform init
```
5. Check workspace is using correct VCS branch

### Debugging Tips

**Enable Detailed Logging:**
```bash
export TF_LOG=DEBUG
terraform plan
```

**Check Workspace Run Logs:**
1. Navigate to: **Runs** tab
2. Click on the failed run
3. Expand each phase (Init, Plan, Apply)
4. Look for detailed error messages

**Verify Provider Versions:**
```bash
terraform version
terraform providers
```

**Test Vault Integration Locally:**
```bash
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="<your-token>"

# Test Vault connectivity
vault status

# Test secret retrieval
vault kv get secret/gcp/service-account
vault kv get secret/aap/api-token
```

**Check HCP Terraform Status:**
Visit https://status.hashicorp.com to check for service issues.


## Security Best Practices

### 1. Workspace Access Control

**Team Management:**
- Navigate to: **Settings → Team Access**
- Create teams with specific permissions:
  - **Admins:** Full workspace access
  - **Operators:** Can run plans and applies
  - **Viewers:** Read-only access
- Use principle of least privilege

**API Token Security:**
- Use team tokens instead of user tokens for automation
- Set token expiration dates
- Rotate tokens regularly (every 90 days)
- Store tokens only in secure systems (Vault, CI/CD secrets)

### 2. Variable Security

**Sensitive Variables:**
- Mark all credentials as sensitive
- Use Vault for credential storage, not workspace variables
- Never commit sensitive values to Git
- Regularly audit variable access

**Variable Encryption:**
- HCP Terraform encrypts all variables at rest
- Sensitive variables are encrypted in transit
- Variables are never exposed in logs or UI

### 3. State File Security

**State Encryption:**
- HCP Terraform encrypts state files at rest
- State is encrypted in transit (TLS)
- State access is logged and auditable

**State Access Control:**
- Limit state access to necessary teams
- Use remote state sharing carefully
- Enable state versioning (automatic in HCP Terraform)
- Regularly review state access logs

### 4. Run Security

**Run Approval:**
- Require manual approval for applies (disable auto-apply)
- Use Sentinel policies for automated checks
- Enable run notifications for visibility
- Review plans before applying

**Audit Logging:**
- All runs are logged with user, timestamp, and changes
- Navigate to: **Settings → Audit Logs**
- Export logs for compliance requirements
- Integrate with SIEM systems if needed

### 5. VCS Integration Security

**Repository Access:**
- Use OAuth tokens, not personal access tokens
- Limit repository access to necessary branches
- Enable branch protection in Git
- Require pull request reviews

**Webhook Security:**
- HCP Terraform uses signed webhooks
- Verify webhook signatures in Git provider
- Use HTTPS for all webhook endpoints
- Monitor webhook activity

### 6. Network Security

**IP Allowlisting:**
- Configure IP allowlists for workspace access (Enterprise)
- Restrict API access to known IPs
- Use VPN or private networking when possible

**TLS/SSL:**
- All HCP Terraform communication uses TLS 1.2+
- Verify SSL certificates for external integrations
- Use valid certificates for Vault and AAP

### 7. Compliance and Governance

**Sentinel Policies (Enterprise):**
```hcl
# Example: Require specific tags on all resources
import "tfplan/v2" as tfplan

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.change.after.labels contains "environment" and
    rc.change.after.labels contains "managed_by"
  }
}
```

**Cost Controls:**
- Enable cost estimation
- Set cost limits for workspaces
- Review cost trends regularly
- Alert on unexpected cost increases

**Policy as Code:**
- Use Sentinel for compliance checks
- Enforce naming conventions
- Require specific provider versions
- Validate resource configurations


## Advanced Configuration

### 1. Multiple Environments

Create separate workspaces for different environments:

**Development Workspace:**
- Name: `gcp-patching-dev`
- Variables: `environment = "dev"`, `vm_count = 1`
- Auto-apply: Enabled

**Staging Workspace:**
- Name: `gcp-patching-staging`
- Variables: `environment = "staging"`, `vm_count = 2`
- Auto-apply: Disabled

**Production Workspace:**
- Name: `gcp-patching-prod`
- Variables: `environment = "prod"`, `vm_count = 5`
- Auto-apply: Disabled
- Sentinel policies: Enforced

### 2. Workspace Promotion

Use run triggers to promote changes across environments:

```
Dev Workspace → (auto-apply) → Staging Workspace → (manual approval) → Prod Workspace
```

Configure in: **Settings → Run Triggers**

### 3. Private Module Registry

Publish reusable modules to your private registry:

1. Navigate to: **Registry → Publish → Module**
2. Connect to VCS repository
3. Tag releases in Git (e.g., v1.0.0)
4. Use in workspaces:

```hcl
module "gcp_vms" {
  source  = "app.terraform.io/my-org/gcp-vms/google"
  version = "1.0.0"
  
  project_id = var.gcp_project_id
  vm_count   = var.vm_count
}
```

### 4. Notifications and Integrations

**Slack Integration:**
1. Navigate to: **Settings → Notifications**
2. Select Slack
3. Configure webhook URL
4. Choose triggers (run needs attention, completed, errored)

**Webhook Integration:**
```json
{
  "notification_configuration": {
    "url": "https://your-webhook-endpoint.com/terraform",
    "triggers": ["run:completed", "run:errored"],
    "enabled": true
  }
}
```

### 5. API-Driven Workflows

Automate workspace operations via API:

**Create Run:**
```bash
curl -X POST \
  -H "Authorization: Bearer ${TFC_TOKEN}" \
  -H "Content-Type: application/vnd.api+json" \
  -d @payload.json \
  https://app.terraform.io/api/v2/runs
```

**Get Run Status:**
```bash
curl -H "Authorization: Bearer ${TFC_TOKEN}" \
  https://app.terraform.io/api/v2/runs/${RUN_ID}
```

**Apply Run:**
```bash
curl -X POST \
  -H "Authorization: Bearer ${TFC_TOKEN}" \
  -H "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/runs/${RUN_ID}/actions/apply
```

### 6. Drift Detection

Enable automatic drift detection:

1. Navigate to: **Settings → Health**
2. Enable drift detection
3. Set schedule (daily, weekly)
4. Configure notifications

HCP Terraform will automatically run plans to detect infrastructure drift.


## Workspace Maintenance

### Regular Tasks

**Weekly:**
- Review run history and failures
- Check for available provider updates
- Monitor cost trends
- Review team access

**Monthly:**
- Rotate Vault tokens
- Update Terraform version
- Review and update variables
- Audit state access logs

**Quarterly:**
- Review and update Sentinel policies
- Conduct security audit
- Update documentation
- Review workspace organization

### Backup and Recovery

**State Backups:**
- HCP Terraform automatically versions state
- Download state backups:
```bash
terraform state pull > backup.tfstate
```
- Store backups securely (encrypted, access-controlled)

**State Recovery:**
```bash
# Restore from backup
terraform state push backup.tfstate

# Or rollback to previous version in UI:
# Settings → States → Select version → Restore
```

**Configuration Backups:**
- Use VCS for configuration versioning
- Tag releases in Git
- Maintain separate branches for environments

### Cleanup

**Destroy Resources:**
```bash
# Destroy all resources
terraform destroy

# Or from UI:
# Settings → Destruction and Deletion → Queue destroy plan
```

**Delete Workspace:**
1. Destroy all resources first
2. Navigate to: **Settings → Destruction and Deletion**
3. Click **Delete workspace**
4. Confirm deletion

**⚠️ Warning:** Deleting a workspace permanently removes:
- State history
- Run history
- Variables
- Configuration

## Cost Optimization

### Estimated Costs

For this prototype with default settings:

| Resource | Quantity | Monthly Cost (USD) |
|----------|----------|-------------------|
| e2-medium VMs | 2 | ~$50 |
| External IPs | 2 | ~$7 |
| Disk storage (10GB each) | 2 | ~$2 |
| **Total** | | **~$59/month** |

**Note:** Costs vary by region and usage. Use GCP pricing calculator for accurate estimates.

### Cost Reduction Tips

1. **Use Preemptible VMs:**
```hcl
resource "google_compute_instance" "ubuntu_vms" {
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}
```
Savings: ~70% reduction

2. **Remove External IPs:**
```hcl
network_interface {
  network = "default"
  # Remove access_config block
}
```
Savings: ~$7/month

3. **Use Smaller Machine Types:**
```hcl
vm_machine_type = "e2-micro"  # Free tier eligible
```
Savings: ~$40/month

4. **Destroy When Not in Use:**
```bash
terraform destroy
```
Savings: 100% when not running

5. **Use Spot VMs:**
Similar to preemptible but with more flexibility
Savings: ~60-90% reduction


## Demo Preparation Checklist

Use this checklist to prepare for a Terraform Actions demo:

### Pre-Demo Setup (1-2 hours)

- [ ] HCP Terraform organization and workspace created
- [ ] Vault configured with all required secrets
- [ ] GCP project configured with APIs enabled
- [ ] AAP configured with job template
- [ ] All workspace variables set correctly
- [ ] Terraform code committed to Git (if using VCS)
- [ ] Initial `terraform apply` completed successfully
- [ ] VMs are running and accessible
- [ ] Terraform Actions visible in UI
- [ ] Test action execution completed successfully

### Demo Script (15 minutes)

**Part 1: Infrastructure Overview (3 minutes)**
1. Show HCP Terraform workspace
2. Explain remote state management
3. Show Terraform outputs (VM IPs, instance IDs)
4. Show GCP console with running VMs

**Part 2: Day 2 Operations (5 minutes)**
1. Navigate to Actions tab
2. Explain Terraform Actions concept
3. Show action configuration (payload, integration)
4. Trigger "Patch Ubuntu VMs" action
5. Show action execution in HCP Terraform

**Part 3: AAP Integration (5 minutes)**
1. Switch to AAP UI
2. Show triggered job in Jobs view
3. Watch real-time playbook execution
4. Show successful completion
5. Explain inventory passed from Terraform

**Part 4: Verification (2 minutes)**
1. SSH to a VM
2. Show updated packages
3. Check system logs
4. Explain end-to-end workflow

### Post-Demo Cleanup

- [ ] Destroy infrastructure: `terraform destroy`
- [ ] Verify all resources deleted in GCP
- [ ] Review costs in GCP billing
- [ ] Document any issues or improvements
- [ ] Update demo script based on feedback

## Next Steps

After completing this HCP Terraform workspace setup:

1. ✅ HCP Terraform workspace configured and operational
2. ✅ Vault integration working
3. ✅ Infrastructure provisioned successfully
4. ✅ Terraform Actions configured
5. ➡️ **Next:** [Demonstration Workflow Guide](DEMO_WORKFLOW.md)
6. ➡️ **Next:** Test end-to-end workflow
7. ➡️ **Next:** Prepare demo presentation

## Additional Resources

### HCP Terraform Documentation
- [HCP Terraform Overview](https://developer.hashicorp.com/terraform/cloud-docs)
- [Workspaces](https://developer.hashicorp.com/terraform/cloud-docs/workspaces)
- [Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables)
- [VCS Integration](https://developer.hashicorp.com/terraform/cloud-docs/vcs)
- [Terraform Actions](https://developer.hashicorp.com/terraform/cloud-docs/actions) (Preview)

### Terraform Provider Documentation
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)

### HashiCorp Learning Resources
- [HCP Terraform Getting Started](https://learn.hashicorp.com/collections/terraform/cloud-get-started)
- [Terraform Actions Tutorial](https://learn.hashicorp.com/tutorials/terraform/actions)
- [Vault Integration](https://learn.hashicorp.com/tutorials/terraform/secrets-vault)

### Community Resources
- [HCP Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-cloud)
- [Terraform Registry](https://registry.terraform.io)
- [HashiCorp Blog](https://www.hashicorp.com/blog)

## Requirements Satisfied

This guide satisfies the following requirements:
- **Requirement 6.1:** HCP Terraform uses dedicated workspaces for the prototype environment
- **Requirement 6.2:** Workspaces connect to GCP using service account credentials
- **Requirement 6.3:** Workspace stores Terraform state remotely in HCP
- **Requirement 6.4:** Workspaces provide variables securely to Terraform runs
- **Requirement 6.5:** Workspace integrates with Vault Enterprise for credential management
- **Requirement 9.3:** Documentation explains HCP Terraform workspace configuration

---

**Document Version:** 1.0  
**Last Updated:** 2024-01-15  
**Maintained By:** Platform Engineering Team
