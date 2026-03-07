output "vm_instance_ids" {
  description = "List of GCP VM instance IDs"
  value       = google_compute_instance.ubuntu_vms[*].instance_id
}

output "vm_external_ips" {
  description = "List of external IP addresses for VMs"
  value       = google_compute_instance.ubuntu_vms[*].network_interface[0].access_config[0].nat_ip
}

output "vm_names" {
  description = "List of VM names"
  value       = google_compute_instance.ubuntu_vms[*].name
}

output "ansible_sa_email" {
  description = "Ansible service account email for OS Login"
  value       = google_service_account.ansible_sa.email
}

output "workload_identity_pool_name" {
  description = "Workload Identity Pool full resource name"
  value       = google_iam_workload_identity_pool.aap_pool.name
}

output "workload_identity_provider_name" {
  description = "Workload Identity Provider full resource name"
  value       = google_iam_workload_identity_pool_provider.aap_provider.name
}

output "oidc_configuration" {
  description = "OIDC configuration for AAP credential"
  value = {
    service_account_email = google_service_account.ansible_sa.email
    workload_provider     = google_iam_workload_identity_pool_provider.aap_provider.name
    project_id            = var.gcp_project_id
  }
}

output "os_login_setup_command" {
  description = "Command to add SSH key to OS Login"
  value       = "gcloud compute os-login ssh-keys add --key-file=~/.ssh/id_rsa.pub"
}

output "os_login_username_command" {
  description = "Command to get OS Login username"
  value       = "gcloud compute os-login describe-profile"
}

output "aap_inventory_id" {
  description = "AAP inventory ID for VM management"
  value       = aap_inventory.vms.id
}

output "aap_inventory_name" {
  description = "AAP inventory name"
  value       = aap_inventory.vms.name
}
