# Terraform Variables
# Define all input variables for the GCP patching prototype

# GCP Project Configuration
variable "gcp_project_id" {
  description = "GCP project identifier where resources will be provisioned"
  type        = string
  default     = "hc-d3e91b0ff2b242c8a4e8a587a25"
}

variable "gcp_region" {
  description = "GCP region for resource deployment (e.g., us-central1)"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone for VM deployment (e.g., us-central1-a)"
  type        = string
  default     = "us-central1-a"
}

# VM Configuration
variable "vm_count" {
  description = "Number of Ubuntu VMs to provision"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10"
  }
}

variable "vm_machine_type" {
  description = "GCP machine type for VMs (e.g., e2-medium)"
  type        = string
  default     = "e2-medium"
}

variable "ubuntu_image" {
  description = "Ubuntu OS image for VMs"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

# Vault Configuration
variable "vault_addr" {
  description = "Vault server address for credential retrieval"
  type        = string
}

variable "vault_token" {
  description = "Vault authentication token (optional - can also use VAULT_TOKEN env var)"
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

variable "vault_ssh_key_path" {
  description = "Vault secret path for SSH private key"
  type        = string
  default     = "secret/ssh/ubuntu-key"
}

# AAP Configuration
variable "aap_api_url" {
  description = "Ansible Automation Platform API endpoint URL"
  type        = string
}

variable "aap_job_template_id" {
  description = "AAP job template ID for VM patching"
  type        = number
}

# Resource Tagging
variable "environment" {
  description = "Environment label for resources (e.g., demo, dev, prod)"
  type        = string
  default     = "demo"
}

variable "managed_by" {
  description = "Management tool identifier"
  type        = string
  default     = "terraform"
}
