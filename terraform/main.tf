# GCP VM Provisioning with Vault SSH CA Authentication
# OS Login is disabled — sshd trusts Vault SSH CA via startup script (TrustedUserCAKeys)

# Workload Identity Pool for AAP OIDC authentication
resource "google_iam_workload_identity_pool" "aap_pool" {
  workload_identity_pool_id = "aap-pool"
  display_name              = "AAP Automation Pool"
  description               = "Workload Identity Pool for Ansible Automation Platform OIDC"
}

resource "google_iam_workload_identity_pool_provider" "aap_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.aap_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "aap-oidc-provider"
  display_name                       = "AAP OIDC Provider"
  description                        = "OIDC provider for AAP authentication"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = var.aap_oidc_issuer_url
  }
}

# Service account for Ansible automation
resource "google_service_account" "ansible_sa" {
  account_id   = "ansible-automation"
  display_name = "Ansible Automation Service Account"
  description  = "Service account for Ansible SSH access via Vault SSH CA"
}

# Allow OIDC token to impersonate service account
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.ansible_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.aap_pool.name}/attribute.repository/${var.aap_oidc_repository}"
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

  target_tags = ["ssh-access"]

  source_ranges = var.environment == "production" ? [
    "${var.aap_server_ip}/32",
    "35.235.240.0/20", # Cloud IAP
  ] : ["0.0.0.0/0"]

  description = var.environment == "production" ? "SSH restricted to AAP and Cloud IAP" : "Demo firewall - restrict for production"
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

  # OS Login disabled — Vault SSH CA handles authentication via sshd TrustedUserCAKeys
  metadata = {
    enable-oslogin = "FALSE"
  }

  # Configure sshd to trust Vault SSH CA at first boot.
  # Equivalent to baking TrustedUserCAKeys into a Packer AMI.
  # Vault-signed ephemeral certificates (30-min TTL) are accepted by sshd.
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    echo '${var.vault_ssh_ca_public_key}' > /etc/ssh/trusted-user-ca-keys.pem
    chmod 644 /etc/ssh/trusted-user-ca-keys.pem
    grep -q '^TrustedUserCAKeys' /etc/ssh/sshd_config || \
      echo 'TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem' >> /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Vault SSH CA configured successfully" | logger -t vault-ssh-setup
  EOF

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
  create_duration = "120s" # Allow startup script to complete
}
