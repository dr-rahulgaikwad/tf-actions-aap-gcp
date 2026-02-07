# HCP Terraform Project and Workspace Setup
# This file creates the TFC project, workspace, and variables

# Create HCP Terraform Project
resource "tfe_project" "aap_gcp_patching" {
  organization = "rahul-tfc"
  name         = "terraform-actions-aap-gcp"
  description  = "Terraform Actions demo with AAP and GCP for VM patching"
}

# Create HCP Terraform Workspace
resource "tfe_workspace" "main" {
  organization = "rahul-tfc"
  project_id   = tfe_project.aap_gcp_patching.id
  name         = "tf-actions-aap-gcp"
  description  = "Demo workspace for Terraform Actions with AAP and GCP"

  vcs_repo {
    identifier     = "your-github-org/tf-actions-aap-gcp"  # Update with your repo
    oauth_token_id = var.tfc_oauth_token_id
  }

  working_directory = "terraform"
  auto_apply        = false
  queue_all_runs    = false
}

# Terraform Variables
resource "tfe_variable" "vault_addr" {
  workspace_id = tfe_workspace.main.id
  key          = "vault_addr"
  value        = var.vault_addr
  category     = "terraform"
  description  = "Vault server address"
}

resource "tfe_variable" "aap_hostname" {
  workspace_id = tfe_workspace.main.id
  key          = "aap_hostname"
  value        = var.aap_hostname
  category     = "terraform"
  description  = "AAP hostname with protocol"
}

resource "tfe_variable" "aap_job_template_id" {
  workspace_id = tfe_workspace.main.id
  key          = "aap_job_template_id"
  value        = var.aap_job_template_id
  category     = "terraform"
  description  = "AAP job template ID"
}

resource "tfe_variable" "gcp_project_id" {
  workspace_id = tfe_workspace.main.id
  key          = "gcp_project_id"
  value        = var.gcp_project_id
  category     = "terraform"
  description  = "GCP project ID"
}

# Environment Variables (Sensitive)
resource "tfe_variable" "vault_token" {
  workspace_id = tfe_workspace.main.id
  key          = "VAULT_TOKEN"
  value        = var.vault_token
  category     = "env"
  sensitive    = true
  description  = "Vault authentication token"
}

resource "tfe_variable" "vault_namespace" {
  workspace_id = tfe_workspace.main.id
  key          = "VAULT_NAMESPACE"
  value        = var.vault_namespace
  category     = "env"
  description  = "Vault namespace (admin for HCP Vault)"
}

resource "tfe_variable" "aap_insecure_skip_verify" {
  workspace_id = tfe_workspace.main.id
  key          = "AAP_INSECURE_SKIP_VERIFY"
  value        = "true"
  category     = "env"
  description  = "Skip TLS verification for AAP (for self-signed certs)"
}

# Outputs
output "tfc_project_id" {
  description = "HCP Terraform Project ID"
  value       = tfe_project.aap_gcp_patching.id
}

output "tfc_workspace_id" {
  description = "HCP Terraform Workspace ID"
  value       = tfe_workspace.main.id
}

output "tfc_workspace_url" {
  description = "HCP Terraform Workspace URL"
  value       = "https://app.terraform.io/app/rahul-tfc/workspaces/${tfe_workspace.main.name}"
}
