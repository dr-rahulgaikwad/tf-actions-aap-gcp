output "vm_instance_ids" {
  description = "List of GCP VM instance IDs"
  value       = google_compute_instance.ubuntu_vms[*].instance_id
}

output "vm_internal_ips" {
  description = "List of internal IP addresses for VMs"
  value       = google_compute_instance.ubuntu_vms[*].network_interface[0].network_ip
}

output "vm_external_ips" {
  description = "List of external IP addresses for VMs"
  value       = google_compute_instance.ubuntu_vms[*].network_interface[0].access_config[0].nat_ip
}

output "vm_names" {
  description = "List of VM names"
  value       = google_compute_instance.ubuntu_vms[*].name
}

output "patch_deployment_id" {
  description = "OS Config patch deployment identifier"
  value       = google_os_config_patch_deployment.ubuntu_patches.id
}

