# Terraform Actions - AAP Integration for Automated VM Patching

# AAP Inventory - Automatically created and managed by Terraform
resource "aap_inventory" "vms" {
  name         = "${var.environment}-gcp-vms"
  description  = "GCP VMs managed by Terraform for ${var.environment} environment"
  organization = 1
}

# Register VMs in AAP Inventory
resource "aap_host" "vms" {
  for_each = { for idx, vm in google_compute_instance.ubuntu_vms : vm.name => vm }

  name         = each.value.name
  inventory_id = aap_inventory.vms.id

  variables = jsonencode({
    ansible_host = each.value.network_interface[0].access_config[0].nat_ip
    instance_id  = each.value.instance_id
    zone         = each.value.zone
    environment  = var.environment
  })

  depends_on = [
    google_compute_instance.ubuntu_vms,
    google_compute_instance_iam_member.ansible_oslogin_admin
  ]
}

# VM Inventory for AAP Playbook
# Structured inventory passed to Ansible via extra_vars
locals {
  # VM inventory for AAP Playbook
  vm_inventory = {
    all = {
      hosts = {
        for vm in google_compute_instance.ubuntu_vms : vm.name => {
          ansible_host = vm.network_interface[0].access_config[0].nat_ip
          instance_id  = vm.instance_id
          internal_ip  = vm.network_interface[0].network_ip
          zone         = vm.zone
        }
      }
      vars = {
        gcp_project = var.gcp_project_id
        gcp_region  = var.gcp_region
        gcp_zone    = var.gcp_zone
        environment = var.environment
      }
    }
  }

  # Extra variables passed to AAP job template
  # These variables are available in the Ansible playbook
  extra_vars = {
    # Patching configuration
    patch_type     = "security"
    reboot_allowed = true
    environment    = var.environment

    # VM inventory
    vm_inventory = local.vm_inventory

    # GCP configuration
    gcp_project_id = var.gcp_project_id
    gcp_zone       = var.gcp_zone

    # Metadata
    terraform_workspace = terraform.workspace
    triggered_by        = "terraform-actions"
    timestamp           = timestamp()
  }
}

# Terraform Action - AAP Job Launch
# Automatically triggers AAP job after VM creation/update
# Waits for job completion before marking Terraform run as successful
action "aap_job_launch" "patch_vms" {
  config {
    # AAP job template ID (must be created manually in AAP)
    job_template_id = var.aap_job_template_id

    # Use Terraform-managed inventory
    inventory_id = aap_inventory.vms.id

    # Wait for job completion
    wait_for_completion = true

    # Timeout: 30 minutes (1800 seconds)
    # Adjust based on VM count and patching requirements
    wait_for_completion_timeout_seconds = 1800

    # Pass variables to Ansible playbook
    extra_vars = jsonencode(local.extra_vars)
  }
}

# Trigger Resource - Executes Action on Infrastructure Changes
# Triggers AAP job when VMs are created or updated
resource "terraform_data" "trigger_patch" {
  # Input values that trigger the action when changed
  input = {
    vm_count        = length(google_compute_instance.ubuntu_vms)
    vm_names        = [for vm in google_compute_instance.ubuntu_vms : vm.name]
    vm_ids          = [for vm in google_compute_instance.ubuntu_vms : vm.id]
    ready_timestamp = time_sleep.wait_for_vms.id
    environment     = var.environment
  }

  # Lifecycle configuration for action triggers
  lifecycle {
    action_trigger {
      # Trigger on VM creation and updates
      events = [after_create, after_update]

      # Action to execute
      actions = [action.aap_job_launch.patch_vms]
    }
  }

  # Ensure all dependencies are ready before triggering
  depends_on = [
    time_sleep.wait_for_vms,
    aap_host.vms,
    google_compute_instance_iam_member.ansible_oslogin_admin
  ]
}

# Output - Action Status
output "action_patch_vms_ready" {
  description = "Terraform Actions patch job status and configuration"
  value = {
    ready           = length(google_compute_instance.ubuntu_vms) > 0
    vm_count        = length(google_compute_instance.ubuntu_vms)
    job_template_id = var.aap_job_template_id
    inventory_id    = aap_inventory.vms.id
    inventory_name  = aap_inventory.vms.name
    environment     = var.environment
  }
}

# Output - VM Inventory
output "action_patch_vms_inventory" {
  description = "VM inventory structure passed to AAP for patching"
  value       = local.vm_inventory
  sensitive   = false
}

# Output - Extra Variables
output "action_extra_vars" {
  description = "Extra variables passed to AAP job template"
  value = {
    patch_type     = local.extra_vars.patch_type
    reboot_allowed = local.extra_vars.reboot_allowed
    environment    = local.extra_vars.environment
    vm_count       = length(google_compute_instance.ubuntu_vms)
  }
  sensitive = false
}
