# Terraform Actions - AAP Integration for Automated VM Patching

# AAP Inventory - Automatically created and managed by Terraform
resource "aap_inventory" "vms" {
  name         = "${var.environment}-gcp-vms"
  description  = "GCP VMs managed by Terraform for ${var.environment} environment"
  organization = 1
}

resource "time_sleep" "wait_for_aap" {
  depends_on      = [aap_inventory.vms]
  create_duration = "15s"
}

# NOTE: The AAP Terraform provider (v1.4) has no credential resource.
# The "Vault SSH" credential is managed manually in AAP UI or via the bootstrap
# output. It is set once and does not change unless AppRole credentials rotate.
# See README Step 4.2 for setup instructions.

# Gate: tracks VM readiness without any AAP dependency
# VM create/destroy is fully independent of AAP availability
resource "terraform_data" "vms_ready" {
  input = {
    vm_ids = [for vm in google_compute_instance.ubuntu_vms : vm.id]
  }
  depends_on = [time_sleep.wait_for_vms]
}

# Register VMs in AAP Inventory — IPs always reflect current VM state (no ignore_changes)
resource "aap_host" "vms" {
  for_each = { for vm in google_compute_instance.ubuntu_vms : vm.name => vm }

  name         = each.value.name
  inventory_id = aap_inventory.vms.id

  variables = jsonencode({
    ansible_host = each.value.network_interface[0].access_config[0].nat_ip
    instance_id  = each.value.instance_id
    zone         = each.value.zone
    environment  = var.environment
  })

  depends_on = [
    time_sleep.wait_for_aap,
    terraform_data.vms_ready
  ]

  lifecycle {
    create_before_destroy = false
  }
}

locals {
  extra_vars = {
    patch_type          = "security"
    reboot_allowed      = true
    environment         = var.environment
    gcp_project_id      = var.gcp_project_id
    gcp_zone            = var.gcp_zone
    terraform_workspace = terraform.workspace
    triggered_by        = "terraform-actions"
    # Do NOT add timestamp() — changes every plan, fires action on every run
    # Do NOT add vm_inventory — AAP already has hosts via aap_host resources
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
    vm_count    = length(google_compute_instance.ubuntu_vms)
    vm_ids      = [for vm in google_compute_instance.ubuntu_vms : vm.id]
    environment = var.environment
  }

  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.aap_job_launch.patch_vms]
    }
  }

  depends_on = [
    time_sleep.wait_for_vms,
    aap_host.vms
  ]
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
