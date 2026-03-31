# Terraform Actions - AAP Integration for Automated VM Patching
#
# Pattern from pablogd-hashi/promptOPS-tf-aap:
# - No aap_host resources (avoids parallel AAP refresh on every plan)
# - No AAP inventory used by playbook (playbook builds its own via add_host)
# - Vault creds injected via AAP custom credential (never in state or extra_vars)
# - wait_for_completion=false (doesn't block apply, avoids sandbox timeouts)

# Remove stale resources from remote state — these were deleted from config
# but still exist in HCP TF state, causing refresh calls that crash sandbox AAP
removed {
  from = aap_host.vms
  lifecycle { destroy = false }
}

removed {
  from = aap_inventory.vms
  lifecycle { destroy = false }
}

removed {
  from = time_sleep.wait_for_aap
  lifecycle { destroy = false }
}

locals {
  extra_vars = {
    # VM inventory — non-sensitive, required for dynamic add_host in playbook
    vm_hosts = { for vm in google_compute_instance.ubuntu_vms : vm.name => vm.network_interface[0].access_config[0].nat_ip }

    # Patch config — non-sensitive operational vars
    patch_type     = "security"
    reboot_allowed = true
    environment    = var.environment
    gcp_project_id = var.gcp_project_id
    gcp_zone       = var.gcp_zone

    # ansible_user / vault_ssh_user are injected by the AAP "Vault SSH Certificate"
    # custom credential via its extra_vars injector — no need to duplicate here
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

# Triggers on VM create/update — no AAP resources to refresh during plan
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

  depends_on = [time_sleep.wait_for_vms]
}

output "action_patch_vms_ready" {
  value = {
    vm_count        = length(google_compute_instance.ubuntu_vms)
    job_template_id = var.aap_job_template_id
    environment     = var.environment
  }
}
