# Terraform Actions - AAP Integration for Automated VM Patching

# AAP Inventory - single static inventory, no per-VM host resources
resource "aap_inventory" "vms" {
  name         = "${var.environment}-gcp-vms"
  description  = "GCP VMs managed by Terraform for ${var.environment} environment"
  organization = 1
}

# Gate: tracks VM readiness without any AAP dependency
resource "terraform_data" "vms_ready" {
  input = {
    vm_ids = [for vm in google_compute_instance.ubuntu_vms : vm.id]
  }
  depends_on = [time_sleep.wait_for_vms]
}

locals {
  # VM IPs passed as extra_vars — Ansible builds inventory dynamically via add_host
  # This avoids aap_host resources which cause parallel AAP refresh on every plan
  vm_hosts = { for vm in google_compute_instance.ubuntu_vms : vm.name => vm.network_interface[0].access_config[0].nat_ip }

  extra_vars = {
    patch_type          = "security"
    reboot_allowed      = true
    environment         = var.environment
    gcp_project_id      = var.gcp_project_id
    gcp_zone            = var.gcp_zone
    terraform_workspace = terraform.workspace
    triggered_by        = "terraform-actions"
    vm_hosts            = local.vm_hosts
  }
}

action "aap_job_launch" "patch_vms" {
  config {
    job_template_id                     = var.aap_job_template_id
    inventory_id                        = aap_inventory.vms.id
    wait_for_completion                 = true
    wait_for_completion_timeout_seconds = 1800
    extra_vars                          = jsonencode(local.extra_vars)
  }
}

# Only triggers when aap_job_template_id > 0 and VM state changes
resource "terraform_data" "trigger_patch" {
  count = var.aap_job_template_id > 0 ? 1 : 0

  input = {
    vm_ids      = [for vm in google_compute_instance.ubuntu_vms : vm.id]
    environment = var.environment
  }

  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.aap_job_launch.patch_vms]
    }
  }

  depends_on = [terraform_data.vms_ready]
}

output "action_patch_vms_ready" {
  description = "Terraform Actions patch job status"
  value = {
    ready           = length(google_compute_instance.ubuntu_vms) > 0
    vm_count        = length(google_compute_instance.ubuntu_vms)
    job_template_id = var.aap_job_template_id
    inventory_id    = aap_inventory.vms.id
    inventory_name  = aap_inventory.vms.name
    environment     = var.environment
  }
}
