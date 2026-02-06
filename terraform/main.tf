# Main Terraform configuration for GCP VM provisioning and patching
# This file defines the core infrastructure resources

# ============================================================================
# Vault Data Sources - Credential Retrieval
# ============================================================================
# These data sources retrieve credentials from HashiCorp Vault Enterprise
# for secure authentication across GCP, AAP, and SSH connections.
# Requirements: 8.1, 6.5

# Retrieve GCP service account credentials from Vault
# Used by Terraform to authenticate with GCP APIs
data "vault_generic_secret" "gcp_credentials" {
  path = var.vault_gcp_secret_path
}

# Retrieve AAP API token from Vault
# Used by Terraform Actions to authenticate with Ansible Automation Platform
data "vault_generic_secret" "aap_token" {
  path = var.vault_aap_token_path
}

# Retrieve SSH private key from Vault
# Used by Ansible to connect to Ubuntu VMs for patching operations
data "vault_generic_secret" "ssh_key" {
  path = var.vault_ssh_key_path
}

# ============================================================================
# Infrastructure Resources
# ============================================================================

# ============================================================================
# Networking Resources
# ============================================================================
# Configure VPC network and firewall rules for VM connectivity
# Requirements: 1.2, 7.5

# Create or use the default VPC network
# For demo purposes, we'll create the network if it doesn't exist
resource "google_compute_network" "vpc_network" {
  name                    = "patching-demo-network"
  auto_create_subnetworks = true
  description             = "VPC network for GCP patching demo"
}

# Firewall rule to allow SSH access to VMs
# Requirement 7.5: Minimal firewall rules (SSH only)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-patching-demo"
  network = google_compute_network.vpc_network.name

  # Allow SSH from anywhere (for demo purposes)
  # In production, restrict source_ranges to specific IPs or ranges
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Apply to VMs with the ssh-access tag
  target_tags = ["ssh-access"]

  # Source ranges - allow from anywhere for demo
  # Restrict this in production environments
  source_ranges = ["0.0.0.0/0"]

  description = "Allow SSH access to patching demo VMs"
}

# ============================================================================
# VM Instances
# ============================================================================
# Provision Ubuntu VMs on GCP for patching demonstration
# Requirements: 1.1, 1.5

resource "google_compute_instance" "ubuntu_vms" {
  count = var.vm_count

  name         = "ubuntu-vm-${count.index + 1}"
  machine_type = var.vm_machine_type
  zone         = var.gcp_zone

  # Boot disk configuration with Ubuntu 22.04 LTS
  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = 20 # GB
      type  = "pd-standard"
    }
  }

  # Network configuration
  # Requirement 1.2: Configure standard GCP networking
  network_interface {
    # Use the created VPC network
    network = google_compute_network.vpc_network.name

    # Assign ephemeral external IP for SSH access
    # This allows Ansible to connect from AAP
    access_config {
      # Ephemeral external IP assigned automatically
      # No need to specify nat_ip for ephemeral IPs
    }
  }

  # Metadata for SSH key injection
  # SSH public key retrieved from Vault secret
  metadata = {
    ssh-keys = "ubuntu:${data.vault_generic_secret.ssh_key.data["public_key"]}"
  }

  # Resource labels for identification and management
  # Requirement 1.5: Tag resources appropriately for identification
  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    os          = "ubuntu"
  }

  # Allow Terraform to recreate the instance if needed
  allow_stopping_for_update = true

  # Network tags for firewall rule targeting
  # The ssh-access tag allows the firewall rule to apply to these VMs
  tags = ["ssh-access", "patching-demo"]

  # Ensure firewall rule is created before VMs
  depends_on = [google_compute_firewall.allow_ssh]
}

# ============================================================================
# OS Config Patch Deployment
# ============================================================================
# Configure GCP OS Config for patch management
# Requirements: 2.1, 2.2, 2.3, 2.4

resource "google_os_config_patch_deployment" "ubuntu_patches" {
  patch_deployment_id = "ubuntu-security-patches"

  # Instance filter - target VMs with specific labels
  # Requirement 2.2: Target Ubuntu operating systems specifically
  instance_filter {
    all = false

    group_labels {
      labels = {
        environment = var.environment
        os          = "ubuntu"
      }
    }
  }

  # Patch configuration for Ubuntu (apt-based)
  # Requirement 2.4: Specify patch categories and severity levels
  patch_config {
    apt {
      type     = "DIST" # Distribution upgrade (security patches)
      excludes = []     # No package exclusions for demo
    }

    # Reboot configuration
    reboot_config = "DEFAULT" # Reboot if required by packages
  }

  # One-time schedule for on-demand execution
  # Requirement 2.3: Use on-demand execution mode for demonstration
  one_time_schedule {
    execute_time = "2026-12-31T23:59:59Z" # Placeholder - manual trigger via Actions
  }

  description = "Patch deployment for Ubuntu VMs in demo environment"
}

# ============================================================================
# Terraform Actions Configuration
# ============================================================================
# Define Day 2 operations that trigger AAP workflows
# Requirements: 3.1, 3.2, 3.3, 3.5
#
# NOTE: Terraform Actions configuration has been moved to actions.tf
# for better organization and maintainability. See actions.tf for the
# complete action configuration including HTTP integration with AAP.

# ============================================================================
# IAM Configuration - Service Account Permissions
# ============================================================================
# Configure minimal IAM permissions for Terraform service account
# Requirements: 7.3, 8.5

# Note: These IAM bindings assume you have a service account for Terraform.
# The service account email should be provided via variable or data source.
# For this demo, we document the required roles that should be granted
# to the Terraform service account in your GCP project.

# Required IAM Roles for Terraform Service Account:
# ==================================================
# 
# The service account used by Terraform (configured in versions.tf provider)
# requires the following IAM roles at the PROJECT level:
#
# 1. roles/compute.instanceAdmin.v1
#    - Create, modify, and delete VM instances
#    - Manage instance metadata and network interfaces
#    - Required for: google_compute_instance resources
#
# 2. roles/compute.networkAdmin
#    - Create and manage firewall rules
#    - View and use VPC networks
#    - Required for: google_compute_firewall resources
#
# 3. roles/osconfig.patchDeploymentAdmin
#    - Create and manage OS Config patch deployments
#    - Required for: google_os_config_patch_deployment resources
#
# 4. roles/iam.serviceAccountUser
#    - Use service accounts for VM instances
#    - Required for: Attaching service accounts to VMs (if needed)
#
# These roles follow the principle of least privilege (Requirement 8.5)
# by granting only the minimum permissions needed for this prototype.

# To grant these roles to your Terraform service account, run:
# 
# export PROJECT_ID="your-gcp-project-id"
# export SA_EMAIL="terraform@${PROJECT_ID}.iam.gserviceaccount.com"
# 
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:${SA_EMAIL}" \
#   --role="roles/compute.instanceAdmin.v1"
# 
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:${SA_EMAIL}" \
#   --role="roles/compute.networkAdmin"
# 
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:${SA_EMAIL}" \
#   --role="roles/osconfig.patchDeploymentAdmin"
# 
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:${SA_EMAIL}" \
#   --role="roles/iam.serviceAccountUser"

# IAM Bindings for VM Service Account (Optional)
# ===============================================
# 
# If you want VMs to have their own service account for accessing GCP services,
# create a separate service account with minimal permissions:
#
# resource "google_service_account" "vm_service_account" {
#   account_id   = "vm-patching-demo"
#   display_name = "VM Service Account for Patching Demo"
#   description  = "Service account for VMs in patching demo"
# }
#
# # Grant minimal permissions to VM service account
# resource "google_project_iam_member" "vm_logging" {
#   project = var.gcp_project_id
#   role    = "roles/logging.logWriter"
#   member  = "serviceAccount:${google_service_account.vm_service_account.email}"
# }
#
# resource "google_project_iam_member" "vm_monitoring" {
#   project = var.gcp_project_id
#   role    = "roles/monitoring.metricWriter"
#   member  = "serviceAccount:${google_service_account.vm_service_account.email}"
# }
#
# Then attach to VMs:
# service_account {
#   email  = google_service_account.vm_service_account.email
#   scopes = ["cloud-platform"]
# }

# IAM Best Practices for This Prototype:
# =======================================
# 
# 1. Separate Service Accounts:
#    - Terraform service account: Infrastructure management
#    - VM service account: Runtime operations (logging, monitoring)
#    - AAP service account: Ansible operations (if needed)
#
# 2. Least Privilege:
#    - Grant only the minimum roles required
#    - Avoid roles/owner or roles/editor
#    - Use predefined roles when possible
#    - Create custom roles for more granular control (advanced)
#
# 3. Credential Management:
#    - Store service account keys in Vault (never in code)
#    - Rotate keys regularly
#    - Use short-lived tokens when possible
#    - Enable audit logging for service account usage
#
# 4. Monitoring and Auditing:
#    - Enable Cloud Audit Logs for IAM changes
#    - Monitor service account key usage
#    - Set up alerts for suspicious activity
#    - Review IAM permissions regularly

# Requirements Satisfied:
# =======================
# - Requirement 7.3: Service accounts granted minimum required permissions
# - Requirement 8.5: Configuration follows principle of least privilege
