# Terraform Outputs
# Define outputs that will be available after infrastructure provisioning
# Requirements: 1.3

# ============================================================================
# VM Instance Outputs
# ============================================================================
# These outputs provide VM details needed for Terraform Actions and AAP integration

# Output list of VM instance IDs
# Used by Terraform Actions to pass VM identifiers to AAP
output "vm_instance_ids" {
  description = "List of GCP VM instance IDs"
  value       = google_compute_instance.ubuntu_vms[*].instance_id
}

# Output list of internal IP addresses
# Used by Ansible for VM connectivity within GCP network
output "vm_internal_ips" {
  description = "List of internal IP addresses for VMs"
  value       = google_compute_instance.ubuntu_vms[*].network_interface[0].network_ip
}

# Output list of external IP addresses
# Used by Ansible for VM connectivity from AAP (external to GCP)
output "vm_external_ips" {
  description = "List of external IP addresses for VMs"
  value       = google_compute_instance.ubuntu_vms[*].network_interface[0].access_config[0].nat_ip
}

# Output VM names
# Used for identification and inventory management
output "vm_names" {
  description = "List of VM names"
  value       = google_compute_instance.ubuntu_vms[*].name
}

# ============================================================================
# Patch Deployment Outputs
# ============================================================================
# Output patch deployment identifier for reference and validation

# Output patch deployment ID
# Used for verification and reference in Day 2 operations
output "patch_deployment_id" {
  description = "OS Config patch deployment identifier"
  value       = google_os_config_patch_deployment.ubuntu_patches.id
}

# ============================================================================
# Terraform Actions Outputs
# ============================================================================
# These outputs provide action configuration data for HCP Terraform Actions
# Requirements: 3.1, 3.2, 3.3, 3.5

# Output AAP API endpoint URL
# Used by Terraform Actions to trigger AAP job templates
output "aap_job_launch_url" {
  description = "AAP API endpoint for job template launch"
  value       = local.aap_job_launch_url
}

# Output VM inventory in AAP-compatible format
# Used by Terraform Actions to pass dynamic inventory to AAP
output "vm_inventory_json" {
  description = "VM inventory in JSON format for AAP job templates"
  value       = jsonencode(local.vm_inventory)
}

# Output complete action payload
# Used by Terraform Actions to construct the AAP API request
output "action_payload_json" {
  description = "Complete action payload for AAP job launch"
  value       = jsonencode(local.action_payload)
}

# Output action configuration metadata
# Used to configure Terraform Actions in HCP Terraform workspace
output "action_config" {
  description = "Action configuration metadata for HCP Terraform"
  value = {
    name         = local.action_config.name
    display_name = local.action_config.display_name
    description  = local.action_config.description
    method       = local.action_config.method
    url          = local.action_config.url
  }
  sensitive = false
}

# Note: The actual AAP auth token is not output for security reasons
# It should be configured directly in HCP Terraform Actions using Vault integration
