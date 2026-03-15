# Bootstrap Module - Automates initial setup for HCP Terraform + Vault + AAP + GCP

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.51"
    }
  }
}

provider "vault" {
  address   = var.vault_addr
  namespace = var.vault_namespace
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "tfe" {
  organization = var.tfc_organization
}

# 1. Enable Vault JWT Auth for HCP Terraform
resource "vault_jwt_auth_backend" "tfc" {
  path               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_policy" "terraform_provisioner" {
  name = "terraform-provisioner"
  policy = <<EOT
# GCP token generation
path "gcp/token/${var.vault_gcp_roleset}" { capabilities = ["read"] }

# AAP credentials
path "secret/data/aap/*" { capabilities = ["read"] }

# SSH CA
path "ssh/sign/${var.vault_ssh_role}" { capabilities = ["create", "update"] }
EOT
}

resource "vault_jwt_auth_backend_role" "tfc" {
  backend        = vault_jwt_auth_backend.tfc.path
  role_name      = "terraform-cloud"
  token_policies = [vault_policy.terraform_provisioner.name]

  bound_audiences    = ["vault.workload.identity"]
  bound_claims_type  = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:*:workspace:*:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

# 2. GCP Service Account for Vault
resource "google_service_account" "vault_admin" {
  account_id   = "vault-admin"
  display_name = "Vault Admin"
}

resource "google_project_iam_member" "vault_admin_roles" {
  for_each = toset([
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/resourcemanager.projectIamAdmin",
  ])
  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vault_admin.email}"
}

resource "google_service_account_key" "vault_admin" {
  service_account_id = google_service_account.vault_admin.name
}

# 3. Vault GCP Secrets Engine
resource "vault_gcp_secret_backend" "gcp" {
  path        = "gcp"
  credentials = base64decode(google_service_account_key.vault_admin.private_key)
}

resource "vault_gcp_secret_roleset" "terraform_provisioner" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = var.vault_gcp_roleset

  project      = var.gcp_project_id
  secret_type  = "access_token"
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project_id}"
    roles = [
      "roles/compute.instanceAdmin.v1",
      "roles/compute.networkAdmin",
      "roles/compute.osLogin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.workloadIdentityPoolAdmin",
    ]
  }
}

# 4. Vault SSH CA
resource "vault_mount" "ssh" {
  path = "ssh"
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "ssh_ca" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "aap_role" {
  backend  = vault_mount.ssh.path
  name     = var.vault_ssh_role
  key_type = "ca"

  allow_user_certificates = true
  allowed_users           = "*"
  default_extensions = {
    permit-pty = ""
  }
  ttl     = 1800
  max_ttl = 1800
}

# 5. AppRole for AAP
resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_policy" "aap_ssh" {
  name = "aap-ssh-signer"
  policy = <<EOT
path "ssh/sign/${var.vault_ssh_role}" {
  capabilities = ["create", "update"]
}
EOT
}

resource "vault_approle_auth_backend_role" "aap" {
  backend        = vault_auth_backend.approle.path
  role_name      = "aap-automation"
  token_policies = [vault_policy.aap_ssh.name]
  token_ttl      = 36000
  token_max_ttl  = 36000
}

resource "vault_approle_auth_backend_role_secret_id" "aap" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.aap.role_name
}

# 6. Store AAP credentials in Vault
resource "vault_kv_secret_v2" "aap_creds" {
  mount = "secret"
  name  = "aap/credentials"
  data_json = jsonencode({
    hostname = var.aap_hostname
    username = var.aap_username
    password = var.aap_password
  })
}

resource "vault_kv_secret_v2" "aap_approle" {
  mount = "secret"
  name  = "aap/approle"
  data_json = jsonencode({
    role_id   = vault_approle_auth_backend_role.aap.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.aap.secret_id
  })
}

# 7. Configure TFC Workspace Variables
data "tfe_workspace" "main" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization
}

resource "tfe_variable" "vault_config" {
  for_each = {
    TFC_VAULT_PROVIDER_AUTH   = "true"
    TFC_VAULT_ADDR            = var.vault_addr
    TFC_VAULT_NAMESPACE       = var.vault_namespace
    TFC_VAULT_RUN_ROLE        = "terraform-cloud"
    TFC_VAULT_BACKED_JWT_AUTH = "true"
  }

  workspace_id = data.tfe_workspace.main.id
  key          = each.key
  value        = each.value
  category     = "env"
}

resource "tfe_variable" "terraform_vars" {
  for_each = {
    vault_addr          = var.vault_addr
    vault_namespace     = var.vault_namespace
    gcp_project_id      = var.gcp_project_id
    gcp_region          = var.gcp_region
    gcp_zone            = var.gcp_zone
    aap_hostname        = var.aap_hostname
    aap_job_template_id = var.aap_job_template_id
    environment         = var.environment
    vm_count            = tostring(var.vm_count)
  }

  workspace_id = data.tfe_workspace.main.id
  key          = each.key
  value        = each.value
  category     = "terraform"
}
