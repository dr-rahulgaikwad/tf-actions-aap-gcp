# GCP Configuration
variable "gcp_project_id" {
  description = "GCP project identifier"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_project_id))
    error_message = "GCP project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "gcp_region" {
  description = "GCP region for resource deployment"
  type        = string
  default     = "us-central1"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.gcp_region))
    error_message = "GCP region must be in format: location-area-number (e.g., us-central1)."
  }
}

variable "gcp_zone" {
  description = "GCP zone for VM deployment"
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.gcp_zone))
    error_message = "GCP zone must be in format: location-area-number-zone (e.g., us-central1-a)."
  }
}

# VM Configuration
variable "vm_count" {
  description = "Number of Ubuntu VMs to provision"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10 for cost control."
  }
}

variable "vm_machine_type" {
  description = "GCP machine type for VMs"
  type        = string
  default     = "e2-medium"

  validation {
    condition     = contains(["e2-micro", "e2-small", "e2-medium", "e2-standard-2", "e2-standard-4"], var.vm_machine_type)
    error_message = "Machine type must be one of: e2-micro, e2-small, e2-medium, e2-standard-2, e2-standard-4."
  }
}

variable "ubuntu_image" {
  description = "Ubuntu OS image for VMs"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"

  validation {
    condition     = can(regex("ubuntu", var.ubuntu_image))
    error_message = "Ubuntu image must contain 'ubuntu' in the name."
  }
}

# Vault Configuration
variable "vault_addr" {
  description = "Vault server address (e.g., https://vault.hashicorp.cloud:8200)"
  type        = string

  validation {
    condition     = can(regex("^https://", var.vault_addr))
    error_message = "Vault address must start with https://."
  }
}

variable "vault_namespace" {
  description = "Vault namespace (for HCP Vault, typically 'admin')"
  type        = string
  default     = "admin"
}

variable "vault_gcp_roleset" {
  description = "Vault GCP secrets engine roleset name for dynamic GCP tokens"
  type        = string
  default     = "terraform-provisioner"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.vault_gcp_roleset))
    error_message = "Roleset name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

# AAP Configuration
variable "aap_hostname" {
  description = "Ansible Automation Platform hostname with protocol (e.g., https://aap.example.com)"
  type        = string

  validation {
    condition     = can(regex("^https://", var.aap_hostname))
    error_message = "AAP hostname must start with https://."
  }
}

variable "aap_job_template_id" {
  description = "AAP job template ID for VM patching"
  type        = number

  validation {
    condition     = var.aap_job_template_id > 0
    error_message = "Job template ID must be a positive number."
  }
}

variable "ansible_user" {
  description = "OS Login username for Ansible SSH access (e.g., your_email_domain_com). Get this from 'gcloud compute os-login describe-profile' or 'task setup-os-login'"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.ansible_user))
    error_message = "Ansible user must be in OS Login format: start with a letter and contain only lowercase letters, numbers, and underscores (e.g., 'rahul_gaikwad_hashicorp_com'). Get your OS Login username with: gcloud compute os-login describe-profile --format='value(posixAccounts[0].username)'"
  }
}

variable "aap_oidc_issuer_url" {
  description = "AAP OIDC issuer URL for Workload Identity Federation (e.g., https://aap.example.com)"
  type        = string

  validation {
    condition     = can(regex("^https://", var.aap_oidc_issuer_url))
    error_message = "OIDC issuer URL must start with https://."
  }
}

variable "aap_oidc_repository" {
  description = "Repository identifier for OIDC authentication (e.g., your-org/your-repo)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9-]+$", var.aap_oidc_repository))
    error_message = "Repository must be in format: org/repo."
  }
}

# Resource Tagging
variable "environment" {
  description = "Environment label for resources"
  type        = string
  default     = "demo"

  validation {
    condition     = contains(["demo", "dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: demo, dev, staging, production."
  }
}

variable "managed_by" {
  description = "Management tool identifier"
  type        = string
  default     = "terraform"
}

# Security Configuration
variable "aap_server_ip" {
  description = "AAP server public IP for firewall rules (required for production)"
  type        = string
  default     = ""

  validation {
    condition     = var.environment != "production" || (var.aap_server_ip != "" && can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.aap_server_ip)))
    error_message = "AAP server IP is required for production environment and must be a valid IPv4 address."
  }
}

variable "enable_os_login" {
  description = "Enable OS Login for IAM-based SSH authentication"
  type        = bool
  default     = true
}

variable "enable_cloud_logging" {
  description = "Enable Cloud Logging for VMs"
  type        = bool
  default     = true
}

variable "enable_cloud_monitoring" {
  description = "Enable Cloud Monitoring for VMs"
  type        = bool
  default     = true
}
