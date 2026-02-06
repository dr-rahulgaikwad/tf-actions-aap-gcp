# Terraform Actions Configuration
# Defines Day 2 operations that trigger AAP for VM patching

locals {
  action_name = "patch_vms"

  action_metadata = {
    name        = "Patch Ubuntu VMs"
    description = "Trigger Ansible playbook to patch VMs via Ansible Automation Platform"
  }

  action_http_config = {
    method = "POST"
    url    = "${var.aap_api_url}/api/v2/job_templates/${var.aap_job_template_id}/launch/"
    headers = {
      "Content-Type"  = "application/json"
      "Authorization" = "Bearer ${data.vault_generic_secret.aap_token.data["token"]}"
    }
  }

  action_payload = {
    extra_vars = {
      patch_type     = "security"
      reboot_allowed = true
      environment    = var.environment

      vm_inventory = {
        all = {
          hosts = {
            for vm in google_compute_instance.ubuntu_vms : vm.name => {
              ansible_host            = vm.network_interface[0].access_config[0].nat_ip
              instance_id             = vm.instance_id
              internal_ip             = vm.network_interface[0].network_ip
              zone                    = vm.zone
              ansible_user            = "ubuntu"
              ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
            }
          }
          vars = {
            gcp_project = var.gcp_project_id
            environment = var.environment
          }
        }
      }
    }
  }

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

# Action Configuration Outputs
output "action_patch_vms_config" {
  description = "Complete action configuration for HCP Terraform"
  value = {
    name        = local.action_metadata.name
    description = local.action_metadata.description
    type        = "http"
    method      = local.action_http_config.method
    url         = local.action_http_config.url
  }
  sensitive = false
}

output "action_patch_vms_payload" {
  description = "Action payload structure (VM inventory and extra vars)"
  value       = jsonencode(local.action_payload)
  sensitive   = false
}

output "action_patch_vms_url" {
  description = "AAP API endpoint URL for the patch_vms action"
  value       = local.action_http_config.url
}

output "action_patch_vms_inventory" {
  description = "VM inventory for the patch_vms action"
  value       = local.action_payload.extra_vars.vm_inventory
  sensitive   = false
}

output "action_patch_vms_ready" {
  description = "Whether the patch_vms action is ready to be invoked"
  value = {
    ready           = length(google_compute_instance.ubuntu_vms) > 0
    vm_count        = length(google_compute_instance.ubuntu_vms)
    target          = "Ansible Automation Platform"
    job_template_id = var.aap_job_template_id
  }
}