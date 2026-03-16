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
  description = "Ansible service account email"
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

output "aap_inventory_id" {
  description = "AAP inventory ID for VM management"
  value       = aap_inventory.vms.id
}

output "aap_inventory_name" {
  description = "AAP inventory name"
  value       = aap_inventory.vms.name
}
