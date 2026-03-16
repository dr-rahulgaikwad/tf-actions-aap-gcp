output "vault_ssh_ca_public_key" {
  description = "Vault SSH CA public key — set as vault_ssh_ca_public_key in HCP Terraform workspace variables"
  value       = vault_ssh_secret_backend_ca.ssh_ca.public_key
}

output "approle_credentials" {
  description = "AppRole credentials for AAP Vault SSH credential"
  value = {
    role_id   = vault_approle_auth_backend_role.aap.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.aap.secret_id
  }
  sensitive = true
}

output "next_steps" {
  description = "Next steps after bootstrap"
  value       = <<-EOT

  ✅ Bootstrap Complete!

  Next Steps:

  1. Set vault_ssh_ca_public_key in HCP Terraform workspace:
     terraform output -raw vault_ssh_ca_public_key
     → Paste value into HCP TF → Workspace → Variables → vault_ssh_ca_public_key

  2. Create AAP Custom Credential Type (Vault SSH Certificate):
     AAP UI → Administration → Credential Types → Add
     Copy YAML from scripts/aap-vault-ssh-credential.json

  3. Create AAP Credential:
     Type: Vault SSH Certificate
     Vault Address: ${var.vault_addr}
     AppRole creds: terraform output -json approle_credentials

  4. Create AAP Job Template:
     Playbook: ansible/gcp_vm_patching_demo.yml
     Credential: Vault SSH Certificate
     Note the Template ID

  5. Set aap_job_template_id in HCP Terraform workspace variables

  6. Deploy:
     git push origin main

  EOT
}
