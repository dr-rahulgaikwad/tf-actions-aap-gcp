# Terraform configuration for GCP VM provisioning and patching

data "vault_generic_secret" "gcp_credentials" {
  path = var.vault_gcp_secret_path
}

data "vault_generic_secret" "aap_token" {
  path = var.vault_aap_token_path
}

resource "google_service_account" "ansible_sa" {
  account_id   = "ansible-automation"
  display_name = "Ansible Automation Service Account"
  description  = "Service account for Ansible OS Login SSH access"
}

resource "tls_private_key" "ansible_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance_iam_member" "ansible_oslogin" {
  count = var.vm_count

  project       = var.gcp_project_id
  zone          = var.gcp_zone
  instance_name = google_compute_instance.ubuntu_vms[count.index].name
  role          = "roles/compute.osLogin"
  member        = "serviceAccount:${google_service_account.ansible_sa.email}"
}

resource "google_compute_instance_iam_member" "ansible_oslogin_admin" {
  count = var.vm_count

  project       = var.gcp_project_id
  zone          = var.gcp_zone
  instance_name = google_compute_instance.ubuntu_vms[count.index].name
  role          = "roles/compute.osAdminLogin"
  member        = "serviceAccount:${google_service_account.ansible_sa.email}"
}

resource "google_compute_network" "vpc_network" {
  name                    = "patching-demo-network"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-patching-demo"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh-access"]
  source_ranges = ["0.0.0.0/0"] # For Demo only — restrict to trusted CIDR ranges in production
}

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
    network = google_compute_network.vpc_network.self_link
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email = google_service_account.ansible_sa.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    os          = "ubuntu"
    patch_ready = "true"
  }

  tags                      = ["ssh-access", "patching-demo"]
  allow_stopping_for_update = true

  depends_on = [google_compute_firewall.allow_ssh]
}

resource "time_sleep" "wait_for_vms" {
  depends_on      = [google_compute_instance.ubuntu_vms]
  create_duration = "120s"
}

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
}
