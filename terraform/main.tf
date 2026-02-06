# Main Terraform configuration for GCP VM provisioning and patching

# Vault Data Sources - Retrieve credentials securely
data "vault_generic_secret" "gcp_credentials" {
  path = var.vault_gcp_secret_path
}

data "vault_generic_secret" "aap_token" {
  path = var.vault_aap_token_path
}

data "vault_generic_secret" "ssh_key" {
  path = var.vault_ssh_key_path
}

# Networking Resources
resource "google_compute_network" "vpc_network" {
  name                    = "patching-demo-network"
  auto_create_subnetworks = true
  description             = "VPC network for GCP patching demo"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-patching-demo"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh-access"]
  source_ranges = ["0.0.0.0/0"] # Restrict in production

  description = "Allow SSH access to patching demo VMs"
}

# VM Instances
resource "google_compute_instance" "ubuntu_vms" {
  count = var.vm_count

  name         = "ubuntu-vm-${count.index + 1}"
  machine_type = var.vm_machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${data.vault_generic_secret.ssh_key.data["public_key"]}"
  }

  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    os          = "ubuntu"
  }

  tags                      = ["ssh-access", "patching-demo"]
  allow_stopping_for_update = true

  depends_on = [google_compute_firewall.allow_ssh]
}

# OS Config Patch Deployment
resource "google_os_config_patch_deployment" "ubuntu_patches" {
  patch_deployment_id = "ubuntu-security-patches"

  instance_filter {
    all = false
    group_labels {
      labels = {
        environment = var.environment
        os          = "ubuntu"
      }
    }
  }

  patch_config {
    apt {
      type     = "DIST"
      excludes = []
    }
    reboot_config = "DEFAULT"
  }

  one_time_schedule {
    execute_time = "2026-12-31T23:59:59Z"
  }

  description = "Patch deployment for Ubuntu VMs in demo environment"
}

# IAM Configuration Notes
# =======================
# Required IAM roles for Terraform service account:
# - roles/compute.instanceAdmin.v1
# - roles/compute.networkAdmin
# - roles/compute.securityAdmin
# - roles/osconfig.patchDeploymentAdmin
# - roles/iam.serviceAccountUser
#
# Grant these roles using: task gcp-setup
