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
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# Dynamic Vault authentication via JWT (20-min TTL)
# TFC automatically provides JWT token via TFC_VAULT_* environment variables
provider "vault" {
  address   = var.vault_addr
  namespace = var.vault_namespace

  # JWT auth is handled automatically by TFC when TFC_VAULT_PROVIDER_AUTH=true
  # No explicit auth_login_jwt block needed
}

# GCP credentials from Vault KV (static service account key)
# Note: Using static credentials as fallback - HCP Vault GCP secrets engine has timeout issues
data "vault_kv_secret_v2" "gcp_credentials" {
  mount = "secret"
  name  = "gcp/credentials"
}

provider "google" {
  credentials = data.vault_kv_secret_v2.gcp_credentials.data["json"]
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}

# Dynamic AAP OAuth2 token (10-hour TTL)
data "vault_kv_secret_v2" "aap_oauth2" {
  mount = "secret"
  name  = "aap/oauth2"
}

provider "aap" {
  host           = var.aap_hostname
  username       = data.vault_kv_secret_v2.aap_oauth2.data["username"]
  password       = data.vault_kv_secret_v2.aap_oauth2.data["password"]
  oauth_token_id = data.vault_kv_secret_v2.aap_oauth2.data["client_id"]
}

provider "tfe" {
  # Set TFE_TOKEN as workspace environment variable
}
