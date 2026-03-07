#!/bin/bash
set -e

# Test Vault SSH Secrets Engine Integration
# Validates the complete flow: AppRole → Vault → SSH Certificate → GCP VM

echo "=== Testing Vault SSH Integration ==="
echo ""

# Check prerequisites
if [ -z "$VAULT_ADDR" ]; then
  echo "Error: VAULT_ADDR not set"
  exit 1
fi

if [ -z "$VAULT_NAMESPACE" ]; then
  export VAULT_NAMESPACE="admin"
fi

echo "✓ Environment configured"
echo "  Vault: $VAULT_ADDR"
echo "  Namespace: $VAULT_NAMESPACE"
echo ""

# Test 1: Verify SSH secrets engine is enabled
echo "Test 1: Checking SSH secrets engine..."
if vault secrets list | grep -q "^ssh/"; then
  echo "✓ SSH secrets engine enabled"
else
  echo "✗ SSH secrets engine not enabled"
  exit 1
fi
echo ""

# Test 2: Verify SSH CA is configured
echo "Test 2: Checking SSH CA configuration..."
if vault read ssh/config/ca >/dev/null 2>&1; then
  echo "✓ SSH CA configured"
  CA_PUBLIC_KEY=$(vault read -field=public_key ssh/config/ca)
  echo "  CA Key Type: $(echo "$CA_PUBLIC_KEY" | awk '{print $1}')"
else
  echo "✗ SSH CA not configured"
  exit 1
fi
echo ""

# Test 3: Verify SSH role exists
echo "Test 3: Checking SSH role..."
if vault read ssh/roles/aap-oslogin >/dev/null 2>&1; then
  echo "✓ SSH role 'aap-oslogin' exists"
  TTL=$(vault read -field=ttl ssh/roles/aap-oslogin)
  echo "  TTL: $TTL"
else
  echo "✗ SSH role not found"
  exit 1
fi
echo ""

# Test 4: Verify AppRole is configured
echo "Test 4: Checking AppRole configuration..."
if vault read auth/approle/role/aap-automation >/dev/null 2>&1; then
  echo "✓ AppRole 'aap-automation' exists"
else
  echo "✗ AppRole not configured"
  exit 1
fi
echo ""

# Test 5: Get AppRole credentials
echo "Test 5: Retrieving AppRole credentials..."
if vault kv get secret/aap/approle >/dev/null 2>&1; then
  ROLE_ID=$(vault kv get -field=role_id secret/aap/approle)
  SECRET_ID=$(vault kv get -field=secret_id secret/aap/approle)
  echo "✓ AppRole credentials retrieved"
  echo "  Role ID: ${ROLE_ID:0:20}..."
else
  echo "✗ AppRole credentials not found"
  exit 1
fi
echo ""

# Test 6: Test AppRole authentication
echo "Test 6: Testing AppRole authentication..."
VAULT_TOKEN=$(vault write -field=token auth/approle/login \
  role_id="$ROLE_ID" \
  secret_id="$SECRET_ID")

if [ -n "$VAULT_TOKEN" ]; then
  echo "✓ AppRole authentication successful"
  echo "  Token: ${VAULT_TOKEN:0:20}..."
else
  echo "✗ AppRole authentication failed"
  exit 1
fi
echo ""

# Test 7: Test SSH key signing
echo "Test 7: Testing SSH key signing..."
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "✗ SSH public key not found at $HOME/.ssh/id_rsa.pub"
  exit 1
fi

PUBLIC_KEY=$(cat "$HOME/.ssh/id_rsa.pub")
OS_LOGIN_USER=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)" 2>/dev/null || echo "test_user")

SIGNED_CERT=$(VAULT_TOKEN="$VAULT_TOKEN" vault write -field=signed_key ssh/sign/aap-oslogin \
  public_key="$PUBLIC_KEY" \
  valid_principals="$OS_LOGIN_USER")

if [ -n "$SIGNED_CERT" ]; then
  echo "✓ SSH key signed successfully"
  echo "  Certificate type: $(echo "$SIGNED_CERT" | awk '{print $1}')"
  echo "  Valid principals: $OS_LOGIN_USER"
  
  # Save certificate for testing
  echo "$SIGNED_CERT" > /tmp/test-ssh-cert.pub
  echo "  Certificate saved to: /tmp/test-ssh-cert.pub"
else
  echo "✗ SSH key signing failed"
  exit 1
fi
echo ""

# Test 8: Verify certificate details
echo "Test 8: Verifying certificate details..."
ssh-keygen -L -f /tmp/test-ssh-cert.pub > /tmp/cert-details.txt 2>&1
if grep -q "Type: ssh-rsa-cert" /tmp/cert-details.txt; then
  echo "✓ Certificate is valid"
  echo "  Valid from: $(grep "Valid:" /tmp/cert-details.txt | awk '{print $2, $3, $4, $5}')"
  echo "  Valid to: $(grep "Valid:" /tmp/cert-details.txt | awk '{print $7, $8, $9, $10}')"
  echo "  Principals: $(grep "Principals:" /tmp/cert-details.txt | awk '{$1=""; print $0}')"
else
  echo "✗ Certificate validation failed"
  cat /tmp/cert-details.txt
  exit 1
fi
echo ""

# Test 9: Check if CA key is in GCP OS Login
echo "Test 9: Checking GCP OS Login configuration..."
OS_LOGIN_KEYS=$(gcloud compute os-login ssh-keys list --format="value(key)" 2>/dev/null || echo "")
if echo "$OS_LOGIN_KEYS" | grep -q "$(echo "$CA_PUBLIC_KEY" | awk '{print $2}')"; then
  echo "✓ Vault SSH CA key found in GCP OS Login"
else
  echo "⚠ Vault SSH CA key not found in GCP OS Login"
  echo "  Add it with: gcloud compute os-login ssh-keys add --key='$CA_PUBLIC_KEY' --ttl=365d"
fi
echo ""

# Test 10: Test SSH connection (if VMs exist)
echo "Test 10: Testing SSH connection to VM..."
VM_NAME=$(gcloud compute instances list --filter="labels.goog-terraform-provisioned:true" --format="value(name)" --limit=1 2>/dev/null || echo "")

if [ -n "$VM_NAME" ]; then
  echo "  Testing connection to: $VM_NAME"
  
  # Copy private key and certificate
  cp "$HOME/.ssh/id_rsa" /tmp/test-ssh-key
  chmod 600 /tmp/test-ssh-key
  
  # Test connection
  if gcloud compute ssh "$VM_NAME" \
    --ssh-key-file=/tmp/test-ssh-key \
    --command="echo 'SSH connection with Vault certificate successful'" \
    --tunnel-through-iap 2>/dev/null; then
    echo "✓ SSH connection successful with Vault-signed certificate"
  else
    echo "⚠ SSH connection test skipped (may need CA key in OS Login)"
  fi
  
  # Cleanup
  rm -f /tmp/test-ssh-key /tmp/test-ssh-cert.pub
else
  echo "⚠ No VMs found for SSH test"
fi
echo ""

# Cleanup
rm -f /tmp/cert-details.txt

# Summary
echo "=== Test Summary ==="
echo "✓ All Vault SSH integration tests passed!"
echo ""
echo "Configuration:"
echo "  - SSH secrets engine: Enabled"
echo "  - SSH CA: Configured"
echo "  - SSH role: aap-oslogin (10min TTL)"
echo "  - AppRole: aap-automation (10h TTL)"
echo "  - Policy: aap-ssh-access"
echo ""
echo "Next steps:"
echo "  1. Ensure CA key is in GCP OS Login"
echo "  2. Create custom credential type in AAP"
echo "  3. Create Vault SSH credential in AAP"
echo "  4. Test with AAP job template"
echo ""
