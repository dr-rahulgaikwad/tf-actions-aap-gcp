# GCP Configuration
variable "gcp_project_id" {
  description = "GCP project identifier"
  type        = string
  default     = "hc-d3e91b0ff2b242c8a4e8a587a25"
}

variable "gcp_region" {
  description = "GCP region for resource deployment"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone for VM deployment"
  type        = string
  default     = "us-central1-a"
}

# VM Configuration
variable "vm_count" {
  description = "Number of Ubuntu VMs to provision"
  type        = number
  default     = 5

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10"
  }
}

variable "vm_machine_type" {
  description = "GCP machine type for VMs"
  type        = string
  default     = "e2-medium"
}

variable "ubuntu_image" {
  description = "Ubuntu OS image for VMs"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-focal-v20230918"
}

# Vault Configuration
variable "vault_addr" {
  description = "Vault server address"
  type        = string
}

variable "vault_token" {
  description = "Vault authentication token (optional - can use VAULT_TOKEN env var)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_namespace" {
  description = "Vault namespace (for HCP Vault, typically 'admin')"
  type        = string
  default     = "admin"
}

variable "vault_gcp_secret_path" {
  description = "Vault secret path for GCP service account credentials"
  type        = string
  default     = "secret/gcp/service-account"
}

variable "vault_aap_token_path" {
  description = "Vault secret path for AAP API token"
  type        = string
  default     = "secret/aap/api-token"
}

# AAP Configuration
variable "aap_hostname" {
  description = "Ansible Automation Platform hostname with protocol (e.g., https://your-aap-instance.com)"
  type        = string
}

variable "aap_job_template_id" {
  description = "AAP job template ID for VM patching"
  type        = number
}

variable "ansible_user" {
  description = "OS Login username for Ansible SSH access (e.g., your_email_domain_com)"
  type        = string
}

# Resource Tagging
variable "environment" {
  description = "Environment label for resources"
  type        = string
  default     = "demo"
}

variable "managed_by" {
  description = "Management tool identifier"
  type        = string
  default     = "terraform"
}


# HCP Terraform Setup Variables
variable "tf_organization_name" {
  description = "HCP Terraform organization name"
  type        = string
  default     = "rahul-tfc"
}

variable "github_token" {
  description = "GitHub personal access token for OAuth"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository identifier (org/repo)"
  type        = string
  default     = ""
}


# TFC Project Configuration
variable "tfc_project_name" {
  description = "HCP Terraform project name"
  type        = string
  default     = "terraform-actions-aap-gcp"
}

variable "tfc_project_description" {
  description = "HCP Terraform project description"
  type        = string
  default     = "Terraform Actions demo with AAP and GCP for VM patching"
}

# TFC Workspace Configuration
variable "tfc_workspace_name" {
  description = "HCP Terraform workspace name"
  type        = string
  default     = "tf-actions-aap-gcp"
}

variable "tfc_workspace_description" {
  description = "HCP Terraform workspace description"
  type        = string
  default     = "Demo workspace for Terraform Actions with AAP and GCP"
}

variable "tfc_working_directory" {
  description = "Working directory for Terraform workspace"
  type        = string
  default     = "terraform"
}

variable "tfc_auto_apply" {
  description = "Enable auto-apply for workspace"
  type        = bool
  default     = false
}

variable "tfc_queue_all_runs" {
  description = "Queue all runs for workspace"
  type        = bool
  default     = false
}

# GitHub OAuth Configuration
variable "github_api_url" {
  description = "GitHub API URL"
  type        = string
  default     = "https://api.github.com"
}

variable "github_http_url" {
  description = "GitHub HTTP URL"
  type        = string
  default     = "https://github.com"
}

variable "github_service_provider" {
  description = "GitHub service provider type"
  type        = string
  default     = "github"
}

variable "github_organization_scoped" {
  description = "Whether OAuth client is scoped to all projects and workspaces"
  type        = bool
  default     = true
}

# TFC Environment Variables
variable "aap_insecure_skip_verify" {
  description = "Skip TLS verification for AAP"
  type        = string
  default     = "true"
}

variable "tfe_token" {
  description = "Terraform Cloud/Enterprise API token"
  type        = string
  sensitive   = true
  default     = ""
}

