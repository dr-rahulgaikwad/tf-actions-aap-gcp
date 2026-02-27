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
provider "vault" {
  address   = var.vault_addr
  namespace = var.vault_namespace

  auth_login_jwt {
    role = "terraform-cloud"
    jwt  = var.tfc_workload_identity_token
  }
}

# Dynamic GCP access token from Vault (1-hour TTL)
data "vault_generic_secret" "gcp_token" {
  path = "gcp/token/terraform-provisioner"
}

provider "google" {
  access_token = data.vault_generic_secret.gcp_token.data["token"]
  project      = var.gcp_project_id
  region       = var.gcp_region
  zone         = var.gcp_zone
}

# Dynamic AAP OAuth2 token (10-hour TTL)
data "vault_generic_secret" "aap_oauth2" {
  path = "secret/aap/oauth2"
}

data "http" "aap_oauth2_token" {
  url    = "${var.aap_hostname}/api/o/token/"
  method = "POST"

  request_headers = {
    Content-Type = "application/x-www-form-urlencoded"
  }

  request_body = join("&", [
    "grant_type=password",
    "client_id=${data.vault_generic_secret.aap_oauth2.data["client_id"]}",
    "client_secret=${data.vault_generic_secret.aap_oauth2.data["client_secret"]}",
    "username=${data.vault_generic_secret.aap_oauth2.data["username"]}",
    "password=${data.vault_generic_secret.aap_oauth2.data["password"]}"
  ])
}

provider "aap" {
  host  = var.aap_hostname
  token = jsondecode(data.http.aap_oauth2_token.response_body).access_token
}

provider "tfe" {
  # Set TFE_TOKEN as workspace environment variable
}
