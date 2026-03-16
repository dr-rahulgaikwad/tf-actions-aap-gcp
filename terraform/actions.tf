# Terraform Actions - AAP Integration for Automated VM Patching

# AAP Inventory - Automatically created and managed by Terraform
resource "aap_inventory" "vms" {
  name         = "${var.environment}-gcp-vms"
  description  = "GCP VMs managed by Terraform for ${var.environment} environment"
  organization = 1
}

# AAP Credential — managed via API since the AAP provider has no credential resource
# Runs on every apply to ensure role_id, secret_id, and ssh_user are always correct
resource "terraform_data" "aap_credential" {
  # Re-run whenever AppRole creds or ansible_user changes
  input = {
    vault_addr   = var.vault_addr
    ansible_user = var.ansible_user
    role_id      = data.vault_kv_secret_v2.aap_approle.data["role_id"]
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOF
      set -e
      ROLE_ID="${data.vault_kv_secret_v2.aap_approle.data["role_id"]}"
      SECRET_ID="${data.vault_kv_secret_v2.aap_approle.data["secret_id"]}"
      AAP_HOST="${data.vault_kv_secret_v2.aap_creds.data["hostname"]}"
      AAP_USER="${data.vault_kv_secret_v2.aap_creds.data["username"]}"
      AAP_PASS="${data.vault_kv_secret_v2.aap_creds.data["password"]}"

      # Get credential type ID for "Vault SSH Certificate"
      CRED_TYPE_ID=$(curl -sk -u "$AAP_USER:$AAP_PASS" \
        "$AAP_HOST/api/controller/v2/credential_types/?name=Vault+SSH+Certificate" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['results'][0]['id'])" 2>/dev/null)

      if [ -z "$CRED_TYPE_ID" ]; then
        echo "WARNING: Vault SSH Certificate credential type not found in AAP — create it manually first"
        exit 0
      fi

      # Check if credential exists
      CRED_ID=$(curl -sk -u "$AAP_USER:$AAP_PASS" \
        "$AAP_HOST/api/controller/v2/credentials/?name=Vault+SSH" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); r=d.get('results',[]); print(r[0]['id'] if r else '')" 2>/dev/null)

      PAYLOAD=$(python3 -c "
import json
print(json.dumps({
  'name': 'Vault SSH',
  'credential_type': int('$CRED_TYPE_ID'),
  'organization': 1,
  'inputs': {
    'vault_addr': '${var.vault_addr}',
    'vault_namespace': '${var.vault_namespace}',
    'role_id': '$ROLE_ID',
    'secret_id': '$SECRET_ID',
    'ssh_role': 'aap-ssh',
    'ssh_user': '${var.ansible_user}'
  }
}))")

      if [ -n "$CRED_ID" ]; then
        curl -sk -o /dev/null -w "AAP credential update: %{http_code}\n" \
          -X PUT -u "$AAP_USER:$AAP_PASS" \
          -H "Content-Type: application/json" \
          -d "$PAYLOAD" \
          "$AAP_HOST/api/controller/v2/credentials/$CRED_ID/"
      else
        curl -sk -o /dev/null -w "AAP credential create: %{http_code}\n" \
          -X POST -u "$AAP_USER:$AAP_PASS" \
          -H "Content-Type: application/json" \
          -d "$PAYLOAD" \
          "$AAP_HOST/api/controller/v2/credentials/"
      fi
    EOF
  }

  depends_on = [time_sleep.wait_for_aap]
}
  input = {
    vm_ids = [for vm in google_compute_instance.ubuntu_vms : vm.id]
  }
  depends_on = [time_sleep.wait_for_vms]
}

resource "time_sleep" "wait_for_aap" {
  depends_on      = [aap_inventory.vms, terraform_data.vms_ready]
  create_duration = "15s"
}

# Register VMs in AAP Inventory
# depends_on terraform_data.vms_ready (not directly on GCP resources)
# so VM create/destroy is fully independent of AAP availability
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

  depends_on = [time_sleep.wait_for_aap]

  lifecycle {
    create_before_destroy = false
    # No ignore_changes — variables (ansible_host IP) must always reflect current VM state
  }
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
  extra_vars = {
    patch_type          = "security"
    reboot_allowed      = true
    environment         = var.environment
    vm_inventory        = local.vm_inventory
    gcp_project_id      = var.gcp_project_id
    gcp_zone            = var.gcp_zone
    terraform_workspace = terraform.workspace
    triggered_by        = "terraform-actions"
    # NOTE: Do NOT use timestamp() here — it changes every plan and causes
    # the action to fire on every run, crashing the sandbox AAP instance.
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
# Only triggers when aap_job_template_id is set (> 0)
resource "terraform_data" "trigger_patch" {
  count = var.aap_job_template_id > 0 ? 1 : 0

  input = {
    vm_count        = length(google_compute_instance.ubuntu_vms)
    vm_names        = [for vm in google_compute_instance.ubuntu_vms : vm.name]
    vm_ids          = [for vm in google_compute_instance.ubuntu_vms : vm.id]
    ready_timestamp = time_sleep.wait_for_vms.id
    environment     = var.environment
  }

  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.aap_job_launch.patch_vms]
    }
  }

  depends_on = [
    time_sleep.wait_for_vms,
    aap_host.vms,
    terraform_data.aap_credential
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
