# GCP Setup Automation
# This file automates GCP resource setup including service accounts and IAM
# Requirements: 7.1, 7.2, 7.3, 7.4, 8.5

# ============================================================================
# Service Accounts
# ============================================================================
# Create service accounts for different purposes

# Service account for Ansible to access VMs
resource "google_service_account" "ansible_sa" {
  account_id   = "ansible-patching-sa"
  display_name = "Ansible Patching Service Account"
  description  = "Service account used by Ansible for VM patching operations"
  project      = var.gcp_project_id
}

# Service account for OS Config
resource "google_service_account" "osconfig_sa" {
  account_id   = "osconfig-patching-sa"
  display_name = "OS Config Patching Service Account"
  description  = "Service account for OS Config patch deployments"
  project      = var.gcp_project_id
}

# ============================================================================
# IAM Role Bindings
# ============================================================================
# Grant minimal required permissions following least privilege principle
# Requirement 8.5: Principle of least privilege for all service accounts

# Grant Ansible SA permissions to access VMs
resource "google_project_iam_member" "ansible_compute_viewer" {
  project = var.gcp_project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.ansible_sa.email}"
}

resource "google_project_iam_member" "ansible_compute_oslogin" {
  project = var.gcp_project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.ansible_sa.email}"
}

# Grant OS Config SA permissions for patch management
resource "google_project_iam_member" "osconfig_patch_admin" {
  project = var.gcp_project_id
  role    = "roles/osconfig.patchDeploymentAdmin"
  member  = "serviceAccount:${google_service_account.osconfig_sa.email}"
}

resource "google_project_iam_member" "osconfig_compute_admin" {
  project = var.gcp_project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.osconfig_sa.email}"
}

# ============================================================================
# Project Services (APIs)
# ============================================================================
# Enable required GCP APIs
# Note: This requires the Service Usage API to be enabled first

resource "google_project_service" "compute" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "osconfig" {
  project = var.gcp_project_id
  service = "osconfig.googleapis.com"

  disable_on_destroy = false
  depends_on         = [google_project_service.compute]
}

resource "google_project_service" "iam" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

# ============================================================================
# Outputs
# ============================================================================

output "ansible_service_account_email" {
  description = "Email of the Ansible service account"
  value       = google_service_account.ansible_sa.email
}

output "osconfig_service_account_email" {
  description = "Email of the OS Config service account"
  value       = google_service_account.osconfig_sa.email
}

output "enabled_apis" {
  description = "List of enabled GCP APIs"
  value = [
    google_project_service.compute.service,
    google_project_service.osconfig.service,
    google_project_service.iam.service,
  ]
}
