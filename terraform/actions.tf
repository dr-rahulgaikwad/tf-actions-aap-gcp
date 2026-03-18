# Terraform Actions - AAP Integration for Automated VM Patching
#
# Pattern from pablogd-hashi/promptOPS-tf-aap:
# - No aap_host resources (avoids parallel AAP refresh on every plan)
# - No AAP inventory used by playbook (playbook builds its own via add_host)
# - Vault creds passed via extra_vars (no AAP credential config needed)
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

data "vault_kv_secret_v2" "aap_approle" {
  count = var.enable_aap ? 1 : 0
  mount = "secret"
  name  = "aap/approle"
}

locals {
  extra_vars = var.enable_aap ? {
    # VM IPs — playbook uses add_host to build inventory dynamically
    vm_hosts = { for vm in google_compute_instance.ubuntu_vms : vm.name => vm.network_interface[0].access_config[0].nat_ip }

    # SSH user
    ansible_user   = var.ansible_user
    vault_ssh_user = var.ansible_user

    # Vault SSH CA — passed directly so AAP needs no credential config
    vault_addr      = var.vault_addr
    vault_namespace = var.vault_namespace
    vault_ssh_role  = "aap-ssh"
    vault_role_id   = data.vault_kv_secret_v2.aap_approle[0].data["role_id"]
    vault_secret_id = data.vault_kv_secret_v2.aap_approle[0].data["secret_id"]

    # Patch config
    patch_type     = "security"
    reboot_allowed = true
    environment    = var.environment
    gcp_project_id = var.gcp_project_id
    gcp_zone       = var.gcp_zone
  } : {}
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
