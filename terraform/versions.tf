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
    aap = {
      source  = "ansible/aap"
      version = "~> 1.4"
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

provider "aap" {
  host  = var.aap_hostname
  token = data.vault_generic_secret.aap_token.data["token"]
  # Note: Set AAP_INSECURE_SKIP_VERIFY=true environment variable in HCP Terraform workspace
  # for self-signed certificates
}
