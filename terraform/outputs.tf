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

output "ansible_ssh_public_key" {
  description = "SSH public key to add to your OS Login profile"
  value       = tls_private_key.ansible_ssh.public_key_openssh
  sensitive   = true
}

output "ansible_ssh_private_key" {
  description = "SSH private key for AAP credential (sensitive)"
  value       = tls_private_key.ansible_ssh.private_key_pem
  sensitive   = true
}