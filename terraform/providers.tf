# Terraform Configuration
terraform {
  required_version = ">= 1.7.0"

  # HCP Terraform Cloud backend configuration
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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Vault Provider - JWT Authentication
# Authenticates using JWT token provided by HCP Terraform
# Required environment variables in HCP Terraform workspace:
#   - TFC_VAULT_BACKED_JWT_AUTH=true
#   - TFC_VAULT_PROVIDER_AUTH=true
#   - TFC_VAULT_ADDR=https://vault.hashicorp.cloud:8200
#   - TFC_VAULT_NAMESPACE=admin
provider "vault" {
  address   = var.vault_addr
  namespace = var.vault_namespace
  # JWT token automatically provided by HCP Terraform
  # Token TTL: 20 minutes (configured in Vault JWT role)
}

# Dynamic GCP Access Token from Vault
# Vault GCP secrets engine generates short-lived access tokens
# Token TTL: 1 hour (configured in Vault GCP roleset)
# No static service account keys required
data "vault_generic_secret" "gcp_token" {
  path = "gcp/token/${var.vault_gcp_roleset}"
}

# Google Cloud Provider - Dynamic Credentials
# Uses access token from Vault instead of static credentials
# Token automatically expires after 1 hour
provider "google" {
  access_token = data.vault_generic_secret.gcp_token.data["token"]
  project      = var.gcp_project_id
  region       = var.gcp_region
}

# Dynamic AAP OAuth2 Credentials from Vault
# Vault KV v2 stores AAP OAuth2 application credentials
# Credentials are read at runtime, not stored in code or state
data "vault_kv_secret_v2" "aap_oauth2" {
  mount = "secret"
  name  = "aap/oauth2"
}

# Ansible Automation Platform Provider - Dynamic Credentials
# Uses OAuth2 credentials from Vault
# OAuth2 token TTL: 10 hours (configured in AAP)
# Required environment variable in HCP Terraform workspace:
#   - AAP_INSECURE_SKIP_VERIFY=true (only for demo with self-signed certs)
provider "aap" {
  host     = var.aap_hostname
  username = data.vault_kv_secret_v2.aap_oauth2.data["username"]
  password = data.vault_kv_secret_v2.aap_oauth2.data["password"]
}
