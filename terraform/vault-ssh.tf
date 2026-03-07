# Vault SSH Secrets Engine Configuration for AAP
# Based on: https://www.hashicorp.com/en/blog/managing-ansible-automation-platform-aap-credentials-at-scale-with-vault

# Use existing SSH secrets engine (already enabled)
resource "vault_mount" "ssh" {
  path        = "ssh"
  type        = "ssh"
  description = "SSH secrets engine for AAP dynamic credentials"
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

# Configure SSH CA
resource "vault_ssh_secret_backend_ca" "ssh_ca" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
  
  lifecycle {
    ignore_changes = all
  }
}

# Create SSH role for AAP (OS Login compatible)
resource "vault_ssh_secret_backend_role" "aap_oslogin" {
  backend  = vault_mount.ssh.path
  name     = "aap-oslogin"
  key_type = "ca"

  # Certificate TTL
  ttl     = "10m"
  max_ttl = "1h"

  # Certificate options
  allow_user_certificates = true
  allowed_users           = "*"
  allowed_extensions      = "permit-pty,permit-port-forwarding"
  default_extensions = {
    permit-pty = ""
  }

  # Algorithm options
  algorithm_signer = "rsa-sha2-256"
}

# Create Vault policy for AAP SSH access
resource "vault_policy" "aap_ssh_access" {
  name = "aap-ssh-access"

  policy = <<EOT
# Allow AAP to sign SSH keys
path "ssh/sign/aap-oslogin" {
  capabilities = ["create", "update"]
}

# Allow AAP to read SSH CA public key
path "ssh/config/ca" {
  capabilities = ["read"]
}
EOT
}

# Use existing AppRole auth method (already enabled)
resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle"
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

# Create AppRole for AAP
resource "vault_approle_auth_backend_role" "aap_automation" {
  backend        = vault_auth_backend.approle.path
  role_name      = "aap-automation"
  token_ttl      = 36000 # 10 hours
  token_max_ttl  = 86400 # 24 hours
  token_policies = [vault_policy.aap_ssh_access.name]

  bind_secret_id = true
  secret_id_ttl  = 0 # Never expires
}

# Read AppRole Role ID
data "vault_approle_auth_backend_role_id" "aap_role_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.aap_automation.role_name
}

# Generate AppRole Secret ID
resource "vault_approle_auth_backend_role_secret_id" "aap_secret_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.aap_automation.role_name
}

# Store AppRole credentials in Vault KV for reference
resource "vault_kv_secret_v2" "aap_approle" {
  mount = "secret"
  name  = "aap/approle"

  data_json = jsonencode({
    role_id   = data.vault_approle_auth_backend_role_id.aap_role_id.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.aap_secret_id.secret_id
  })
}

# Output SSH CA public key for GCP OS Login
output "vault_ssh_ca_public_key" {
  description = "Vault SSH CA public key to add to GCP OS Login"
  value       = vault_ssh_secret_backend_ca.ssh_ca.public_key
  sensitive   = false
}

# Output AppRole credentials for AAP setup
output "aap_approle_credentials" {
  description = "AppRole credentials for AAP Vault SSH credential type"
  value = {
    role_id         = data.vault_approle_auth_backend_role_id.aap_role_id.role_id
    secret_id       = vault_approle_auth_backend_role_secret_id.aap_secret_id.secret_id
    vault_addr      = var.vault_addr
    vault_namespace = var.vault_namespace
    ssh_role        = vault_ssh_secret_backend_role.aap_oslogin.name
  }
  sensitive = true
}

# Output instructions for AAP setup
output "vault_ssh_setup_instructions" {
  description = "Instructions for setting up Vault SSH in AAP"
  value       = <<-EOT
    === Vault SSH Secrets Engine Setup Complete ===
    
    1. Add SSH CA public key to GCP OS Login:
       gcloud compute os-login ssh-keys add --key='${vault_ssh_secret_backend_ca.ssh_ca.public_key}' --ttl=365d
    
    2. Create custom credential type in AAP:
       - Use the JSON definition in scripts/aap-credential-type.json
       - Name: Vault SSH Certificate
       - Kind: Cloud
    
    3. Create credential in AAP:
       - Type: Vault SSH Certificate
       - Vault Address: ${var.vault_addr}
       - Vault Namespace: ${var.vault_namespace}
       - AppRole Role ID: (from sensitive output)
       - AppRole Secret ID: (from sensitive output)
       - SSH Username: ${var.ansible_user}
       - SSH Public Key: (contents of ~/.ssh/id_rsa.pub)
    
    4. Use credential in job templates:
       - Credentials will be dynamically generated with 10-minute TTL
       - Automatic rotation on each job run
       - No static credentials stored in AAP
  EOT
}
