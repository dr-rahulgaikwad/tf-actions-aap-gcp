locals {
  vm_inventory = {
    all = {
      hosts = {
        for vm in google_compute_instance.ubuntu_vms : vm.name => {
          ansible_host            = vm.network_interface[0].access_config[0].nat_ip
          instance_id             = vm.instance_id
          internal_ip             = vm.network_interface[0].network_ip
          zone                    = vm.zone
          ansible_user            = var.ansible_user
          ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
        }
      }
      vars = {
        gcp_project = var.gcp_project_id
        environment = var.environment
      }
    }
  }

  extra_vars = {
    patch_type     = "security"
    reboot_allowed = true
    environment    = var.environment
    vm_inventory   = local.vm_inventory
  }
}

action "aap_job_launch" "patch_vms" {
  config {
    job_template_id                     = var.aap_job_template_id
    wait_for_completion                 = true
    wait_for_completion_timeout_seconds = 1800
    extra_vars                          = jsonencode(local.extra_vars)
  }
}

resource "terraform_data" "trigger_patch" {
  input = {
    vm_count        = length(google_compute_instance.ubuntu_vms)
    vm_names        = [for vm in google_compute_instance.ubuntu_vms : vm.name]
    vm_ids          = [for vm in google_compute_instance.ubuntu_vms : vm.id]
    ready_timestamp = time_sleep.wait_for_vms.id
  }

  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.aap_job_launch.patch_vms]
    }
  }

  depends_on = [time_sleep.wait_for_vms]
}

output "action_patch_vms_ready" {
  description = "Patch action status"
  value = {
    ready           = length(google_compute_instance.ubuntu_vms) > 0
    vm_count        = length(google_compute_instance.ubuntu_vms)
    job_template_id = var.aap_job_template_id
  }
}

output "action_patch_vms_inventory" {
  description = "VM inventory for patching"
  value       = local.vm_inventory
  sensitive   = false
}
