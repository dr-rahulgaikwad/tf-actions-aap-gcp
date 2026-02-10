terraform {
  required_version = ">= 1.7.0"

  cloud {
    organization = "rahul-tfc"
    workspaces {
      name = "tf-actions-aap-gcp"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.73.0"
    }
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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    tls = {
      source  = "hashicorp/tls"
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

provider "aap" {
  host  = var.aap_hostname
  token = data.vault_generic_secret.aap_token.data["token"]
}

provider "tfe" {
  # Set TFE_TOKEN as workspace environment variable
}
