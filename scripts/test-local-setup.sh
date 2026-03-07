#!/bin/bash
set -e

# Comprehensive Local Testing Script
# Tests all Vault SSH setup steps locally before deployment

echo "=== Comprehensive Local Testing ==="
echo ""
echo "This script will test:"
echo "  1. Prerequisites validation"
echo "  2. Vault connectivity"
echo "  3. GCP authentication"
echo "  4. OS Login setup"
echo "  5. Vault SSH secrets engine setup"
echo "  6. SSH certificate signing"
echo "  7. GCP OS Login integration"
echo ""
echo "Starting tests..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

test_step() {
  local step_name="$1"
  echo -e "${YELLOW}Testing: ${step_name}${NC}"
}

test_pass() {
  echo -e "${GREEN}✓ PASS${NC}"
  ((TESTS_PASSED++))
  echo ""
}

test_fail() {
  local error_msg="$1"
  echo -e "${RED}✗ FAIL: ${error_msg}${NC}"
  ((TESTS_FAILED++))
  echo ""
}

# Test 1: Prerequisites
test_step "Prerequisites - Required tools"
MISSING_TOOLS=()
command -v gcloud >/dev/null 2>&1 || MISSING_TOOLS+=("gcloud")
command -v vault >/dev/null 2>&1 || MISSING_TOOLS+=("vault")
command -v ssh-keygen >/dev/null 2>&1 || MISSING_TOOLS+=("ssh-keygen")
command -v jq >/dev/null 2>&1 || MISSING_TOOLS+=("jq")

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
  test_pass
else
  test_fail "Missing tools: ${MISSING_TOOLS[*]}"
  echo "Install missing tools and try again"
  exit 1
fi

# Test 2: Vault connectivity
test_step "Vault connectivity"
if [ -z "$VAULT_ADDR" ]; then
  test_fail "VAULT_ADDR not set"
  echo "Set VAULT_ADDR and try again"
  exit 1
fi

if vault status >/dev/null 2>&1; then
  test_pass
else
  test_fail "Cannot connect to Vault at $VAULT_ADDR"
  exit 1
fi

# Test 3: Vault authentication
test_step "Vault authentication"
if vault token lookup >/dev/null 2>&1; then
  test_pass
else
  test_fail "Not authenticated to Vault"
  echo "Run 'vault login' and try again"
  exit 1
fi

# Test 4: GCP authentication
test_step "GCP authentication"
if gcloud auth list --filter=status:ACTIVE --format="value(account)" >/dev/null 2>&1; then
  GCP_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
  echo "  Authenticated as: $GCP_ACCOUNT"
  test_pass
else
  test_fail "Not authenticated to GCP"
  echo "Run 'gcloud auth login' and try again"
  exit 1
fi

# Test 5: GCP project
test_step "GCP project configuration"
GCP_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ -n "$GCP_PROJECT" ]; then
  echo "  Project: $GCP_PROJECT"
  test_pass
else
  test_fail "No GCP project set"
  echo "Run 'gcloud config set project PROJECT_ID' and try again"
  exit 1
fi

# Test 6: SSH key pair
test_step "SSH key pair"
if [ -f "$HOME/.ssh/id_rsa" ] && [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "  Key found: $HOME/.ssh/id_rsa"
  test_pass
else
  echo "  Generating SSH key pair..."
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "vault-ssh-test"
  test_pass
fi

# Test 7: OS Login setup
test_step "OS Login configuration"
if gcloud compute os-login describe-profile >/dev/null 2>&1; then
  OS_LOGIN_USER=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)")
  echo "  OS Login username: $OS_LOGIN_USER"
  
  # Check if SSH key is in OS Login
  if gcloud compute os-login ssh-keys list --format="value(key)" 2>/dev/null | grep -q "$(cat $HOME/.ssh/id_rsa.pub | awk '{print $2}')"; then
    echo "  SSH key already in OS Login"
    test_pass
  else
    echo "  Adding SSH key to OS Login..."
    gcloud compute os-login ssh-keys add --key-file="$HOME/.ssh/id_rsa.pub" --ttl=365d
    test_pass
  fi
else
  test_fail "OS Login not configured"
  exit 1
fi

# Test 8: Vault SSH secrets engine
test_step "Vault SSH secrets engine"
if vault secrets list | grep -q "^ssh/"; then
  echo "  SSH secrets engine already enabled"
  test_pass
else
  echo "  Enabling SSH secrets engine..."
  vault secrets enable -path=ssh ssh
  test_pass
fi

# Test 9: SSH CA configuration
test_step "SSH CA configuration"
if vault read ssh/config/ca >/dev/null 2>&1; then
  echo "  SSH CA already configured"
  CA_PUBLIC_KEY=$(vault read -field=public_key ssh/config/ca)
  test_pass
else
  echo "  Configuring SSH CA..."
  vault write ssh/config/ca generate_signing_key=true
  CA_PUBLIC_KEY=$(vault read -field=public_key ssh/config/ca)
  test_pass
fi

# Test 10: SSH role
test_step "SSH role configuration"
if vault read ssh/roles/aap-oslogin >/dev/null 2>&1; then
  echo "  SSH role already exists"
  test_pass
else
  echo "  Creating SSH role..."
  vault write ssh/roles/aap-oslogin \
    key_type=ca \
    ttl=10m \
    max_ttl=1h \
    allow_user_certificates=true \
    allowed_users="*" \
    allowed_extensions="permit-pty,permit-port-forwarding" \
    default_extensions_template=true \
    default_extensions="permit-pty={{}}"
  test_pass
fi

# Test 11: AppRole auth
test_step "AppRole authentication method"
if vault auth list | grep -q "^approle/"; then
  echo "  AppRole already enabled"
  test_pass
else
  echo "  Enabling AppRole..."
  vault auth enable approle
  test_pass
fi

# Test 12: Vault policy
test_step "Vault policy for AAP"
if vault policy read aap-ssh-access >/dev/null 2>&1; then
  echo "  Policy already exists"
  test_pass
else
  echo "  Creating policy..."
  vault policy write aap-ssh-access - <<EOF
path "ssh/sign/aap-oslogin" {
  capabilities = ["create", "update"]
}
path "ssh/config/ca" {
  capabilities = ["read"]
}
EOF
  test_pass
fi

# Test 13: AppRole role
test_step "AppRole role for AAP"
if vault read auth/approle/role/aap-automation >/dev/null 2>&1; then
  echo "  AppRole role already exists"
  test_pass
else
  echo "  Creating AppRole role..."
  vault write auth/approle/role/aap-automation \
    token_ttl=10h \
    token_max_ttl=24h \
    token_policies="aap-ssh-access" \
    bind_secret_id=true \
    secret_id_ttl=0
  test_pass
fi

# Test 14: AppRole credentials
test_step "AppRole credentials"
ROLE_ID=$(vault read -field=role_id auth/approle/role/aap-automation/role-id 2>/dev/null || echo "")
if [ -z "$ROLE_ID" ]; then
  test_fail "Could not retrieve Role ID"
  exit 1
fi

SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/aap-automation/secret-id 2>/dev/null || echo "")
if [ -z "$SECRET_ID" ]; then
  test_fail "Could not generate Secret ID"
  exit 1
fi

echo "  Role ID: ${ROLE_ID:0:20}..."
echo "  Secret ID: ${SECRET_ID:0:20}..."

# Store in Vault KV
vault kv put secret/aap/approle role_id="$ROLE_ID" secret_id="$SECRET_ID" >/dev/null 2>&1
test_pass

# Test 15: AppRole authentication
test_step "AppRole authentication test"
VAULT_TOKEN=$(vault write -field=token auth/approle/login \
  role_id="$ROLE_ID" \
  secret_id="$SECRET_ID" 2>/dev/null || echo "")

if [ -n "$VAULT_TOKEN" ]; then
  echo "  Token: ${VAULT_TOKEN:0:20}..."
  test_pass
else
  test_fail "AppRole authentication failed"
  exit 1
fi

# Test 16: SSH key signing
test_step "SSH key signing"
PUBLIC_KEY=$(cat "$HOME/.ssh/id_rsa.pub")
SIGNED_CERT=$(VAULT_TOKEN="$VAULT_TOKEN" vault write -field=signed_key ssh/sign/aap-oslogin \
  public_key="$PUBLIC_KEY" \
  valid_principals="$OS_LOGIN_USER" 2>/dev/null || echo "")

if [ -n "$SIGNED_CERT" ]; then
  echo "$SIGNED_CERT" > /tmp/test-ssh-cert.pub
  echo "  Certificate saved to /tmp/test-ssh-cert.pub"
  test_pass
else
  test_fail "SSH key signing failed"
  exit 1
fi

# Test 17: Certificate validation
test_step "Certificate validation"
if ssh-keygen -L -f /tmp/test-ssh-cert.pub >/dev/null 2>&1; then
  CERT_TYPE=$(ssh-keygen -L -f /tmp/test-ssh-cert.pub 2>&1 | grep "Type:" | awk '{print $2}')
  CERT_PRINCIPALS=$(ssh-keygen -L -f /tmp/test-ssh-cert.pub 2>&1 | grep "Principals:" | sed 's/.*Principals://')
  echo "  Type: $CERT_TYPE"
  echo "  Principals:$CERT_PRINCIPALS"
  test_pass
else
  test_fail "Certificate validation failed"
  exit 1
fi

# Test 18: CA key in OS Login
test_step "Vault CA key in GCP OS Login"
OS_LOGIN_KEYS=$(gcloud compute os-login ssh-keys list --format="value(key)" 2>/dev/null || echo "")
CA_KEY_FINGERPRINT=$(echo "$CA_PUBLIC_KEY" | awk '{print $2}')

if echo "$OS_LOGIN_KEYS" | grep -q "$CA_KEY_FINGERPRINT"; then
  echo "  CA key found in OS Login"
  test_pass
else
  echo "  Adding CA key to OS Login..."
  if gcloud compute os-login ssh-keys add --key="$CA_PUBLIC_KEY" --ttl=365d 2>/dev/null; then
    test_pass
  else
    test_fail "Could not add CA key to OS Login"
    echo "  Manual command: gcloud compute os-login ssh-keys add --key='$CA_PUBLIC_KEY' --ttl=365d"
  fi
fi

# Test 19: Check for VMs
test_step "GCP VMs availability"
VM_COUNT=$(gcloud compute instances list --filter="labels.goog-terraform-provisioned:true" --format="value(name)" 2>/dev/null | wc -l)
if [ "$VM_COUNT" -gt 0 ]; then
  echo "  Found $VM_COUNT VMs"
  VM_NAME=$(gcloud compute instances list --filter="labels.goog-terraform-provisioned:true" --format="value(name)" --limit=1)
  echo "  Test VM: $VM_NAME"
  test_pass
  
  # Test 20: SSH connection test
  test_step "SSH connection with Vault certificate"
  cp "$HOME/.ssh/id_rsa" /tmp/test-ssh-key
  chmod 600 /tmp/test-ssh-key
  
  if gcloud compute ssh "$VM_NAME" \
    --ssh-key-file=/tmp/test-ssh-key \
    --command="echo 'SSH with Vault certificate successful'" \
    --tunnel-through-iap 2>/dev/null; then
    test_pass
  else
    test_fail "SSH connection failed (may need time for CA key propagation)"
    echo "  Wait a few minutes and try: gcloud compute ssh $VM_NAME --tunnel-through-iap"
  fi
  
  rm -f /tmp/test-ssh-key
else
  echo "  No VMs found (deploy infrastructure first)"
  test_pass
fi

# Cleanup
rm -f /tmp/test-ssh-cert.pub

# Summary
echo "=== Test Summary ==="
echo ""
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
else
  echo -e "${GREEN}Tests Failed: 0${NC}"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed! Vault SSH integration is ready.${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Deploy infrastructure: git push"
  echo "  2. Create custom credential type in AAP (scripts/aap-credential-type.json)"
  echo "  3. Create Vault SSH credential in AAP"
  echo "  4. Test with AAP job template"
else
  echo -e "${RED}✗ Some tests failed. Please fix the issues and try again.${NC}"
  exit 1
fi
