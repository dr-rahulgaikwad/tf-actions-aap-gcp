variable "vault_addr" {
  description = "Vault address"
  type        = string
}

variable "vault_namespace" {
  description = "Vault namespace"
  type        = string
  default     = "admin"
}

variable "vault_gcp_roleset" {
  description = "Vault GCP roleset name"
  type        = string
  default     = "terraform-provisioner"
}

variable "vault_ssh_role" {
  description = "Vault SSH role name"
  type        = string
  default     = "aap-ssh"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "aap_hostname" {
  description = "AAP hostname"
  type        = string
}

variable "aap_username" {
  description = "AAP username"
  type        = string
}

variable "aap_password" {
  description = "AAP password"
  type        = string
  sensitive   = true
}

variable "aap_job_template_id" {
  description = "AAP job template ID"
  type        = number
  default     = 0
}

variable "tfc_organization" {
  description = "Terraform Cloud organization"
  type        = string
}

variable "tfc_workspace_name" {
  description = "Terraform Cloud workspace name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "vm_count" {
  description = "Number of VMs"
  type        = number
  default     = 3
}
