# HCP Terraform Setup - Fully Automated
# This file creates TFC project, workspace, and configures all variables
# NOTE: These resources are commented out because the workspace already exists
# Uncomment and set github_token/github_repo variables if you need to recreate

# # Create GitHub OAuth Client
# resource "tfe_oauth_client" "github" {
#   count               = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   organization        = var.tf_organization_name
#   organization_scoped = var.github_organization_scoped
#   api_url             = var.github_api_url
#   http_url            = var.github_http_url
#   oauth_token         = var.github_token
#   service_provider    = var.github_service_provider
# }

# # Create HCP Terraform Project
# resource "tfe_project" "aap_gcp_patching" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   organization = var.tf_organization_name
#   name         = var.tfc_project_name
#   description  = var.tfc_project_description
# }

# # Create HCP Terraform Workspace
# resource "tfe_workspace" "main" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   organization = var.tf_organization_name
#   project_id   = tfe_project.aap_gcp_patching[0].id
#   name         = var.tfc_workspace_name
#   description  = var.tfc_workspace_description

#   vcs_repo {
#     identifier     = var.github_repo
#     oauth_token_id = tfe_oauth_client.github[0].oauth_token_id
#   }

#   working_directory = var.tfc_working_directory
#   auto_apply        = var.tfc_auto_apply
#   queue_all_runs    = var.tfc_queue_all_runs
# }

# # Terraform Variables in Workspace
# resource "tfe_variable" "vault_addr" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "vault_addr"
#   value        = var.vault_addr
#   category     = "terraform"
#   description  = "Vault server address"
# }

# resource "tfe_variable" "aap_hostname" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "aap_hostname"
#   value        = var.aap_hostname
#   category     = "terraform"
#   description  = "AAP hostname with protocol"
# }

# resource "tfe_variable" "aap_job_template_id" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "aap_job_template_id"
#   value        = tostring(var.aap_job_template_id)
#   category     = "terraform"
#   description  = "AAP job template ID"
# }

# resource "tfe_variable" "gcp_project_id" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "gcp_project_id"
#   value        = var.gcp_project_id
#   category     = "terraform"
#   description  = "GCP project ID"
# }

# # Environment Variables (Sensitive)
# resource "tfe_variable" "vault_token" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "VAULT_TOKEN"
#   value        = var.vault_token
#   category     = "env"
#   sensitive    = true
#   description  = "Vault authentication token"
# }

# resource "tfe_variable" "vault_namespace" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "VAULT_NAMESPACE"
#   value        = var.vault_namespace
#   category     = "env"
#   description  = "Vault namespace (admin for HCP Vault)"
# }

# resource "tfe_variable" "aap_insecure_skip_verify" {
#   count        = var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "AAP_INSECURE_SKIP_VERIFY"
#   value        = var.aap_insecure_skip_verify
#   category     = "env"
#   description  = "Skip TLS verification for AAP (for self-signed certs)"
# }

# resource "tfe_variable" "tfe_token" {
#   count        = var.tfe_token != "" && var.github_token != "" && var.github_repo != "" ? 1 : 0
#   workspace_id = tfe_workspace.main[0].id
#   key          = "TFE_TOKEN"
#   value        = var.tfe_token
#   category     = "env"
#   sensitive    = true
#   description  = "Terraform Cloud API token for TFE provider"
# }

# # Outputs
# output "tfc_project_id" {
#   description = "HCP Terraform Project ID"
#   value       = var.github_token != "" && var.github_repo != "" ? tfe_project.aap_gcp_patching[0].id : null
# }

# output "tfc_workspace_id" {
#   description = "HCP Terraform Workspace ID"
#   value       = var.github_token != "" && var.github_repo != "" ? tfe_workspace.main[0].id : null
# }

# output "tfc_workspace_url" {
#   description = "HCP Terraform Workspace URL"
#   value       = var.github_token != "" && var.github_repo != "" ? "https://app.terraform.io/app/${var.tf_organization_name}/workspaces/${tfe_workspace.main[0].name}" : null
# }

# output "tfc_oauth_client_id" {
#   description = "GitHub OAuth Client ID"
#   value       = var.github_token != "" && var.github_repo != "" ? tfe_oauth_client.github[0].id : null
# }
