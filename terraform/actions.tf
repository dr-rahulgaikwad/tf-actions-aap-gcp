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

# AAP Credential — auto-managed via API on every apply
# The AAP Terraform provider has no credential resource, so we use local-exec.
# Reads AppRole creds from Vault KV (written by bootstrap) to ensure
# role_id, secret_id, and ssh_user are always correct without manual steps.
resource "terraform_data" "aap_credential" {
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

      CRED_TYPE_ID=$(curl -sk -u "$AAP_USER:$AAP_PASS" \
        "$AAP_HOST/api/controller/v2/credential_types/?name=Vault+SSH+Certificate" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['results'][0]['id'])" 2>/dev/null)

      if [ -z "$CRED_TYPE_ID" ]; then
        echo "WARNING: Vault SSH Certificate credential type not found in AAP — create it manually (Step 4.1)"
        exit 0
      fi

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

  extra_vars = {
    patch_type          = "security"
    reboot_allowed      = true
    environment         = var.environment
    vm_inventory        = local.vm_inventory
    gcp_project_id      = var.gcp_project_id
    gcp_zone            = var.gcp_zone
    terraform_workspace = terraform.workspace
    triggered_by        = "terraform-actions"
    # Do NOT add timestamp() — changes every plan, fires action on every run
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
    aap_host.vms,
    terraform_data.aap_credential
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

output "action_patch_vms_inventory" {
  description = "VM inventory passed to AAP"
  value       = local.vm_inventory
  sensitive   = false
}
