# HCP Terraform Setup - Fully Automated
# This file creates TFC project, workspace, and configures all variables

# Create GitHub OAuth Client
resource "tfe_oauth_client" "github" {
  organization        = var.tf_organization_name
  organization_scoped = var.github_organization_scoped
  api_url             = var.github_api_url
  http_url            = var.github_http_url
  oauth_token         = var.github_token
  service_provider    = var.github_service_provider
}

# Create HCP Terraform Project
resource "tfe_project" "aap_gcp_patching" {
  organization = var.tf_organization_name
  name         = var.tfc_project_name
  description  = var.tfc_project_description
}

# Create HCP Terraform Workspace
resource "tfe_workspace" "main" {
  organization = var.tf_organization_name
  project_id   = tfe_project.aap_gcp_patching.id
  name         = var.tfc_workspace_name
  description  = var.tfc_workspace_description

  vcs_repo {
    identifier     = var.github_repo
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }

  working_directory = var.tfc_working_directory
  auto_apply        = var.tfc_auto_apply
  queue_all_runs    = var.tfc_queue_all_runs
}

# Terraform Variables in Workspace
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
  value        = tostring(var.aap_job_template_id)
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
  value        = var.aap_insecure_skip_verify
  category     = "env"
  description  = "Skip TLS verification for AAP (for self-signed certs)"
}

resource "tfe_variable" "tfe_token" {
  count        = var.tfe_token != "" ? 1 : 0
  workspace_id = tfe_workspace.main.id
  key          = "TFE_TOKEN"
  value        = var.tfe_token
  category     = "env"
  sensitive    = true
  description  = "Terraform Cloud API token for TFE provider"
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
  value       = "https://app.terraform.io/app/${var.tf_organization_name}/workspaces/${tfe_workspace.main.name}"
}

output "tfc_oauth_client_id" {
  description = "GitHub OAuth Client ID"
  value       = tfe_oauth_client.github.id
}
