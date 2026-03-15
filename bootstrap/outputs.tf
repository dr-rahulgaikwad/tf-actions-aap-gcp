output "vault_ssh_ca_public_key" {
  description = "Vault SSH CA public key - Add this to GCP OS Login"
  value       = vault_ssh_secret_backend_ca.ssh_ca.public_key
}

output "approle_credentials" {
  description = "AppRole credentials for AAP"
  value = {
    role_id   = vault_approle_auth_backend_role.aap.role_id
    secret_id = vault_approle_auth_backend_role_secret_id.aap.secret_id
  }
  sensitive = true
}

output "next_steps" {
  description = "Next steps for deployment"
  value = <<-EOT
  
  ✅ Bootstrap Complete!
  
  Next Steps:
  
  1. Add Vault SSH CA to GCP OS Login:
     gcloud compute os-login ssh-keys add \
       --key='${vault_ssh_secret_backend_ca.ssh_ca.public_key}' \
       --ttl=365d
  
  2. Create AAP Custom Credential Type:
     - Copy from: scripts/aap-vault-ssh-credential.json
     - AAP UI: Administration → Credential Types → Add
  
  3. Create AAP Credential:
     - Type: Vault SSH Certificate
     - Vault Address: ${var.vault_addr}
     - Role ID: (see 'terraform output -json approle_credentials')
     - Secret ID: (see 'terraform output -json approle_credentials')
  
  4. Create AAP Job Template:
     - Inventory: Will be auto-created by Terraform
     - Playbook: ansible/gcp_vm_patching_demo.yml
     - Credential: Vault SSH Certificate
     - Note the Template ID
  
  5. Update TFC workspace variable:
     - aap_job_template_id = <template_id_from_step_4>
  
  6. Deploy infrastructure:
     git push origin main
  
  EOT
}
