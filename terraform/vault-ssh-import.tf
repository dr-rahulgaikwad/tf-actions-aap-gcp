# Import existing Vault resources into Terraform state
# Run these commands manually in HCP Terraform workspace or locally:
# terraform import vault_mount.ssh ssh
# terraform import vault_auth_backend.approle approle

# After import, these resources will be managed by Terraform
# The lifecycle rules prevent accidental destruction
