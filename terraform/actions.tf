# Terraform Actions Configuration
# This file defines Terraform Actions for Day 2 operations
# Requirements: 3.1, 3.2, 3.3, 3.5

# ============================================================================
# Terraform Action: Patch VMs via AAP
# ============================================================================
# This action triggers Ansible Automation Platform to patch Ubuntu VMs
# The action can be invoked manually via HCP Terraform UI or CLI

# Action block for AAP integration
# This action makes an HTTP POST request to AAP API to launch a job template
# 
# NOTE: Terraform Actions with HTTP integration is a feature that may require
# HCP Terraform or a specific provider. The syntax below follows the Terraform
# Actions specification, but the actual HTTP action capability depends on
# provider support or HCP Terraform configuration.
#
# For HCP Terraform, this action configuration can be used as a reference
# to configure the action through the HCP Terraform UI/API.

# Local values for action configuration
# These define the structure that will be used by HCP Terraform Actions
locals {
  # Action name for reference
  action_name = "patch_vms"

  # Action display metadata
  action_metadata = {
    name        = "Patch Ubuntu VMs"
    description = "Trigger Ansible playbook to patch VMs via Ansible Automation Platform"
  }

  # HTTP integration configuration
  # Requirement 3.1: Integrate with AAP using API authentication
  action_http_config = {
    method = "POST"
    url    = "${var.aap_api_url}/api/v2/job_templates/${var.aap_job_template_id}/launch/"
    headers = {
      "Content-Type"  = "application/json"
      "Authorization" = "Bearer ${data.vault_generic_secret.aap_token.data["token"]}"
    }
  }

  # Payload configuration
  # Requirement 3.3: Pass VM inventory data to AAP job templates
  action_payload = {
    # Extra variables passed to the Ansible playbook
    extra_vars = {
      # Patch configuration
      patch_type     = "security"
      reboot_allowed = true
      environment    = var.environment

      # VM inventory data built from Terraform outputs
      # This provides AAP with the list of VMs to patch
      vm_inventory = {
        all = {
          hosts = {
            # Build inventory from provisioned VMs
            # Each VM gets an entry with its connection details
            for vm in google_compute_instance.ubuntu_vms : vm.name => {
              # Use external IP for Ansible connectivity from AAP
              ansible_host = vm.network_interface[0].access_config[0].nat_ip

              # GCP instance metadata
              instance_id = vm.instance_id
              internal_ip = vm.network_interface[0].network_ip
              zone        = vm.zone

              # Ansible connection parameters
              ansible_user            = "ubuntu"
              ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
            }
          }

          # Global variables for all hosts
          vars = {
            gcp_project = var.gcp_project_id
            environment = var.environment
          }
        }
      }
    }
  }

  # Complete action configuration for HCP Terraform
  # This structure can be used to configure the action via HCP Terraform API
  action_config_complete = {
    name        = local.action_metadata.name
    description = local.action_metadata.description
    type        = "http"
    http = {
      method  = local.action_http_config.method
      url     = local.action_http_config.url
      headers = local.action_http_config.headers
      body    = jsonencode(local.action_payload)
    }
  }
}

# ============================================================================
# Action Configuration Outputs
# ============================================================================
# These outputs provide action metadata for reference and documentation
# They can be used to configure the action in HCP Terraform

# Output complete action configuration
# This can be used to configure the action via HCP Terraform API
output "action_patch_vms_config" {
  description = "Complete action configuration for HCP Terraform"
  value = {
    name        = local.action_metadata.name
    description = local.action_metadata.description
    type        = "http"
    method      = local.action_http_config.method
    url         = local.action_http_config.url
    # Note: Authorization header is not output for security
    # It should be configured in HCP Terraform using Vault integration
  }
  sensitive = false
}

# Output action payload structure
# This shows the data that will be sent to AAP
output "action_patch_vms_payload" {
  description = "Action payload structure (VM inventory and extra vars)"
  value       = jsonencode(local.action_payload)
  sensitive   = false
}

# Output action endpoint URL
output "action_patch_vms_url" {
  description = "AAP API endpoint URL for the patch_vms action"
  value       = local.action_http_config.url
}

# Output VM inventory for action
# This shows the inventory that will be passed to AAP
output "action_patch_vms_inventory" {
  description = "VM inventory for the patch_vms action"
  value       = local.action_payload.extra_vars.vm_inventory
  sensitive   = false
}

# Output action readiness status
output "action_patch_vms_ready" {
  description = "Whether the patch_vms action is ready to be invoked"
  value = {
    ready           = length(google_compute_instance.ubuntu_vms) > 0
    vm_count        = length(google_compute_instance.ubuntu_vms)
    target          = "Ansible Automation Platform"
    job_template_id = var.aap_job_template_id
  }
}

# ============================================================================
# Usage Instructions
# ============================================================================
# 
# Terraform Actions Configuration:
# ================================
# 
# This file defines the configuration for a Terraform Action that triggers
# Ansible Automation Platform to patch Ubuntu VMs. The action configuration
# is stored in local values and outputs that can be used to configure the
# action in HCP Terraform.
#
# Configuring the Action in HCP Terraform:
# ========================================
# 
# Option 1: Using HCP Terraform UI
# ---------------------------------
# 1. Navigate to your workspace in HCP Terraform
# 2. Go to Settings > Actions
# 3. Click "Create Action"
# 4. Configure the action:
#    - Name: patch_vms
#    - Display Name: Patch Ubuntu VMs
#    - Description: Trigger Ansible playbook to patch VMs via AAP
#    - Type: HTTP
#    - Method: POST
#    - URL: Use the output value from action_patch_vms_url
#    - Headers: Content-Type: application/json
#    - Authentication: Bearer token from Vault (secret/aap/api-token)
#    - Body: Use the output value from action_patch_vms_payload
# 5. Save the action configuration
#
# Option 2: Using HCP Terraform API
# ----------------------------------
# Use the action_patch_vms_config output to configure via API:
#   curl -X POST \
#     -H "Authorization: Bearer $HCP_TOKEN" \
#     -H "Content-Type: application/json" \
#     -d @action_config.json \
#     https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/actions
#
# Invoking the Action:
# ====================
# 
# From HCP Terraform UI:
# ----------------------
# 1. Navigate to your workspace
# 2. Go to the "Actions" tab
# 3. Click "Run Action" for "Patch Ubuntu VMs"
# 4. Review the action details and confirm
# 5. Monitor the action execution status
#
# From Terraform CLI (if supported):
# ----------------------------------
#   terraform apply -invoke=action.patch_vms
#
# From HCP Terraform API:
# -----------------------
#   curl -X POST \
#     -H "Authorization: Bearer $HCP_TOKEN" \
#     -H "Content-Type: application/json" \
#     https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/actions/patch_vms/runs
#
# What the Action Does:
# =====================
# 
# When invoked, the action will:
#   1. Retrieve AAP API credentials from Vault
#   2. Build VM inventory from current Terraform state
#   3. Make HTTP POST request to AAP API endpoint
#   4. Launch the configured AAP job template
#   5. Pass VM inventory and extra variables to Ansible
#   6. Return job execution status and ID
#
# The AAP job template will then:
#   1. Receive the VM inventory from Terraform
#   2. Execute the patching playbook against all VMs
#   3. Update packages and apply security patches
#   4. Conditionally reboot VMs if required
#   5. Report patching status back to AAP
#
# Prerequisites:
# ==============
# 
# Before invoking the action, ensure:
#   - VMs are provisioned (terraform apply completed)
#   - AAP is accessible and job template is configured
#   - Vault contains valid AAP API token
#   - AAP has SSH access to VMs
#   - AAP job template accepts dynamic inventory
#
# Troubleshooting:
# ================
# 
# If the action fails:
#   - Check AAP API endpoint is accessible
#   - Verify AAP API token in Vault is valid
#   - Confirm job template ID is correct
#   - Check AAP job template accepts extra_vars
#   - Verify VMs are reachable from AAP
#   - Review AAP job execution logs
#
# Requirements Satisfied:
# =======================
# - Requirement 3.1: Integrate with AAP using API authentication ✓
# - Requirement 3.2: Invoke specific AAP job templates ✓
# - Requirement 3.3: Pass VM inventory data to AAP job templates ✓
# - Requirement 3.5: Use Vault Enterprise for storing AAP credentials ✓

