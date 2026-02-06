# Terraform Version and Provider Configuration

terraform {
  required_version = ">= 1.7.0"

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

provider "vault" {
  address   = var.vault_addr
  token     = var.vault_token != "" ? var.vault_token : null
  namespace = var.vault_namespace
}

provider "google" {
  credentials = jsonencode(data.vault_generic_secret.gcp_credentials.data)
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}
