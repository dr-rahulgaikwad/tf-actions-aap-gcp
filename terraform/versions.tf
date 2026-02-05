# Terraform Version and Provider Configuration
# Defines required Terraform version and provider requirements

terraform {
  required_version = ">= 1.7.0"

  # HCP Terraform backend configuration for remote state management
  # This enables centralized state storage and team collaboration
  # 
  # IMPORTANT: Before using, replace "REPLACE_WITH_YOUR_ORG" with your actual
  # HCP Terraform organization name and update the workspace name if needed.
  #
  # For local testing/validation, you can comment out this block and use
  # the local backend configuration from backend-local.tf.example

  cloud {
    organization = "rahul-tfc"

    workspaces {
      name = "tf-actions-aap-gcp"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# Vault provider configuration
# Authenticates to Vault for credential retrieval
provider "vault" {
  address = var.vault_addr
  # Token should be provided via VAULT_TOKEN environment variable
  # or other authentication method configured in HCP Terraform workspace
}

# Google Cloud provider configuration
# Authenticates to GCP using service account credentials retrieved from Vault
# Requirements: 6.2, 8.1
provider "google" {
  credentials = data.vault_generic_secret.gcp_credentials.data["key"]
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}
