#!/bin/bash
set -e

# Vault SSH Secrets Engine Setup for AAP
# Based on: https://www.hashicorp.com/en/blog/managing-ansible-automation-platform-aap-credentials-at-scale-with-vault

echo "=== Setting up Vault SSH Secrets Engine for AAP ==="
echo ""

# Check prerequisites
if [ -z "$VAULT_ADDR" ]; then
  echo "Error: VAULT_ADDR environment variable not set"
  exit 1
fi

if [ -z "$VAULT_NAMESPACE" ]; then
  echo "Warning: VAULT_NAMESPACE not set, using 'admin'"
  export VAULT_NAMESPACE="admin"
fi

# Check if logged in
if ! vault token lookup >/dev/null 2>&1; then
  echo "Error: Not logged into Vault. Run 'vault login' first"
  exit 1
fi

echo "✓ Vault connection verified"
echo ""

# 1. Enable SSH secrets engine
echo "1. Enabling SSH secrets engine..."
if vault secrets list | grep -q "^ssh/"; then
  echo "   SSH secrets engine already enabled"
else
  vault secrets enable -path=ssh ssh
  echo "   ✓ SSH secrets engine enabled"
fi
echo ""

# 2. Configure SSH CA
echo "2. Configuring SSH Certificate Authority..."
vault write ssh/config/ca generate_signing_key=true
echo "   ✓ SSH CA configured"
echo ""

# 3. Create SSH role for OS Login
echo "3. Creating SSH role for AAP (OS Login compatible)..."
vault write ssh/roles/aap-oslogin \
  key_type=ca \
  ttl=10m \
  max_ttl=1h \
  allow_user_certificates=true \
  allowed_users="*" \
  allowed_extensions="permit-pty,permit-port-forwarding" \
  default_extensions_template=true \
  default_extensions="permit-pty={{}}"

echo "   ✓ SSH role 'aap-oslogin' created"
echo "   - Key Type: CA (Certificate Authority)"
echo "   - TTL: 10 minutes"
echo "   - Max TTL: 1 hour"
echo "   - Allowed Users: * (any OS Login user)"
echo ""

# 4. Get CA public key for GCP OS Login
echo "4. Retrieving SSH CA public key..."
CA_PUBLIC_KEY=$(vault read -field=public_key ssh/config/ca)
echo "   ✓ CA public key retrieved"
echo ""

# 5. Add CA public key to GCP OS Login
echo "5. Adding CA public key to GCP OS Login..."
echo "$CA_PUBLIC_KEY" > /tmp/vault-ssh-ca.pub

# Get current user's OS Login profile
OS_LOGIN_USER=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)" 2>/dev/null || echo "")

if [ -z "$OS_LOGIN_USER" ]; then
  echo "   Warning: Could not determine OS Login username"
  echo "   Please add the CA public key manually:"
  echo "   gcloud compute os-login ssh-keys add --key-file=/tmp/vault-ssh-ca.pub --ttl=365d"
else
  echo "   OS Login user: $OS_LOGIN_USER"
  
  # Add SSH CA public key to OS Login
  if gcloud compute os-login ssh-keys add --key-file=/tmp/vault-ssh-ca.pub --ttl=365d 2>/dev/null; then
    echo "   ✓ CA public key added to OS Login"
  else
    echo "   Warning: Failed to add CA key automatically"
    echo "   Please add manually: gcloud compute os-login ssh-keys add --key-file=/tmp/vault-ssh-ca.pub --ttl=365d"
  fi
fi

rm -f /tmp/vault-ssh-ca.pub
echo ""

# 6. Create Vault policy for AAP
echo "6. Creating Vault policy for AAP SSH access..."
vault policy write aap-ssh-access - <<EOF
# Allow AAP to sign SSH keys
path "ssh/sign/aap-oslogin" {
  capabilities = ["create", "update"]
}

# Allow AAP to read SSH CA public key
path "ssh/config/ca" {
  capabilities = ["read"]
}
EOF

echo "   ✓ Policy 'aap-ssh-access' created"
echo ""

# 7. Create AppRole for AAP
echo "7. Creating AppRole for AAP..."
if ! vault auth list | grep -q "^approle/"; then
  vault auth enable approle
  echo "   ✓ AppRole auth enabled"
fi

vault write auth/approle/role/aap-automation \
  token_ttl=10h \
  token_max_ttl=24h \
  token_policies="aap-ssh-access" \
  bind_secret_id=true \
  secret_id_ttl=0

echo "   ✓ AppRole 'aap-automation' created"
echo ""

# 8. Generate AppRole credentials
echo "8. Generating AppRole credentials for AAP..."
ROLE_ID=$(vault read -field=role_id auth/approle/role/aap-automation/role-id)
SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/aap-automation/secret-id)

echo "   ✓ AppRole credentials generated"
echo ""

# 9. Store credentials in Vault KV for Terraform
echo "9. Storing AppRole credentials in Vault KV..."
vault kv put secret/aap/approle \
  role_id="$ROLE_ID" \
  secret_id="$SECRET_ID"

echo "   ✓ Credentials stored at secret/aap/approle"
echo ""

# 10. Display summary
echo "=== Setup Complete ==="
echo ""
echo "Vault SSH Secrets Engine Configuration:"
echo "  - SSH CA: Configured and signing key generated"
echo "  - SSH Role: aap-oslogin (10min TTL, 1h max)"
echo "  - AppRole: aap-automation"
echo "  - Policy: aap-ssh-access"
echo ""
echo "Next Steps:"
echo "  1. Create custom credential type in AAP (see scripts/aap-credential-type.json)"
echo "  2. Create credential in AAP using AppRole credentials"
echo "  3. Test SSH connection with Vault-signed certificate"
echo ""
echo "AppRole Credentials (for AAP setup):"
echo "  Role ID: $ROLE_ID"
echo "  Secret ID: $SECRET_ID"
echo ""
echo "These credentials are also stored in Vault at: secret/aap/approle"
echo ""
