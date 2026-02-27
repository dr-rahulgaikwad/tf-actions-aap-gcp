# Setup Guide

Complete setup guide for Terraform Actions + AAP + GCP with dynamic credentials.

## Prerequisites

- GCP Project with billing enabled
- HCP Terraform workspace
- HCP Vault cluster
- Ansible Automation Platform
- Tools: `gcloud`, `terraform`, `vault`, `task`

---

## 1. Vault Setup (Dynamic Credentials)

### Enable JWT Auth (Terraform → Vault)

```bash
# Enable JWT auth method
vault auth enable jwt

# Configure for Terraform Cloud
vault write auth/jwt/config \
  bound_issuer="https://app.terraform.io" \
  oidc_discovery_url="https://app.terraform.io"

# Create policy
vault policy write terraform-provisioner - <<EOF
# Read GCP access tokens
path "gcp/token/terraform-provisioner" {
  capabilities = ["read"]
}

# Read AAP OAuth2 credentials
path "secret/data/aap/oauth2" {
  capabilities = ["read"]
}
EOF

# Create role
vault write auth/jwt/role/terraform-cloud \
  role_type="jwt" \
  bound_audiences="vault.workload.identity" \
  bound_claims_type="glob" \
  bound_claims='{"sub":"organization:YOUR_ORG:project:*:workspace:*:run_phase:*"}' \
  user_claim="terraform_full_workspace" \
  token_ttl="20m" \
  token_policies="terraform-provisioner"
```

### Enable GCP Secrets Engine (Vault → GCP)

```bash
# Enable GCP secrets engine
vault secrets enable gcp

# Configure with service account (one-time setup)
vault write gcp/config \
  credentials=@/path/to/gcp-vault-admin-key.json

# Create roleset for Terraform
vault write gcp/roleset/terraform-provisioner \
  project="YOUR_PROJECT_ID" \
  secret_type="access_token" \
  token_scopes="https://www.googleapis.com/auth/cloud-platform" \
  bindings=-<<EOF
    resource "//cloudresourcemanager.googleapis.com/projects/YOUR_PROJECT_ID" {
      roles = [
        "roles/compute.instanceAdmin.v1",
        "roles/compute.networkAdmin",
        "roles/compute.osLogin",
        "roles/iam.serviceAccountUser",
        "roles/iam.serviceAccountAdmin",
        "roles/iam.workloadIdentityPoolAdmin"
      ]
    }
EOF

# Test token generation
vault read gcp/token/terraform-provisioner
```

### Setup AAP OAuth2 (Vault → AAP)

```bash
# 1. Create OAuth2 application in AAP
# AAP UI → Administration → Applications → Add
# - Name: Terraform Automation
# - Authorization Grant Type: Resource owner password-based
# - Client Type: Confidential

# 2. Store OAuth2 credentials in Vault
vault kv put secret/aap/oauth2 \
  client_id="YOUR_CLIENT_ID" \
  client_secret="YOUR_CLIENT_SECRET" \
  username="admin" \
  password="YOUR_AAP_PASSWORD"
```

---

## 2. GCP Setup

```bash
export PROJECT_ID="your-project-id"

# Enable required APIs
gcloud services enable compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com

# Create service account for Vault (one-time)
gcloud iam service-accounts create vault-admin \
  --display-name="Vault GCP Secrets Engine Admin"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:vault-admin@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:vault-admin@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountKeyAdmin"

# Create key for Vault configuration
gcloud iam service-accounts keys create vault-admin-key.json \
  --iam-account=vault-admin@${PROJECT_ID}.iam.gserviceaccount.com
```

---

## 3. HCP Terraform Setup

### Configure Workspace

```bash
# In TFC workspace settings:

# 1. Enable dynamic provider credentials
# Settings → General → Enable "Dynamic Provider Credentials"

# 2. Add environment variable
TFC_VAULT_BACKED_JWT_AUTH=true

# 3. Set workspace variables
vault_addr = "https://your-vault-cluster.vault.hashicorp.cloud:8200"
vault_namespace = "admin"
gcp_project_id = "your-project-id"
aap_hostname = "https://your-aap-server"
aap_job_template_id = 11
ansible_user = "your_username_com"
aap_oidc_issuer_url = "https://your-aap-server"
aap_oidc_repository = "your-org/your-repo"
environment = "demo"
```

---

## 4. Terraform Deployment

```bash
cd terraform

# Initialize
terraform init

# Plan (will use JWT auth automatically)
terraform plan

# Apply
terraform apply

# Get SSH key for OS Login
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub
rm /tmp/key.pub

# Get OS Login username
YOUR_USERNAME=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)")
echo "Your OS Login username: $YOUR_USERNAME"
```

---

## 5. AAP Configuration

### Create GCP OIDC Credential

```bash
# Get OIDC configuration
terraform output oidc_configuration

# In AAP UI → Resources → Credentials → Add
# Type: Google Cloud Platform
# Auth: Workload Identity Federation
# Use values from terraform output
```

### Create SSH Credential

```bash
# Get SSH private key
terraform output -raw ansible_ssh_private_key

# In AAP UI → Resources → Credentials → Add
# Type: Machine
# Username: <YOUR_OS_LOGIN_USERNAME>
# SSH Private Key: <paste from terraform output>
```

### Configure Job Template

```
# In AAP UI → Resources → Templates → Your Template
# 1. Attach both credentials (GCP OIDC + SSH)
# 2. Enable "Prompt on launch" for Variables
# 3. Save
```

---

## 6. Test Deployment

```bash
# Trigger via git push
git commit --allow-empty -m "Test automation"
git push origin main

# Or manually trigger action
terraform apply -invoke action.aap_job_launch.patch_vms
```

---

## 7. Validation

### Verify Dynamic Credentials

```bash
# Check Vault audit log for JWT auth
vault audit list

# Verify GCP token generation
vault read gcp/token/terraform-provisioner

# Check AAP OAuth2 token
curl -X POST https://your-aap-server/api/o/token/ \
  -d "grant_type=password&client_id=...&client_secret=..."
```

### Run Production Validation

```bash
./validate-production.sh
```

---

## Credential TTLs

| Credential | TTL | Auto-Rotation |
|------------|-----|---------------|
| Vault JWT Token | 20 minutes | ✅ Per run |
| GCP Access Token | 1 hour | ✅ Per run |
| AAP OAuth2 Token | 10 hours | ✅ Per run |

---

## Troubleshooting

### JWT Auth Fails

```bash
# Verify TFC variable is set
TFC_VAULT_BACKED_JWT_AUTH=true

# Check Vault JWT role configuration
vault read auth/jwt/role/terraform-cloud

# Verify bound_claims matches your org/workspace
```

### GCP Token Generation Fails

```bash
# Verify GCP secrets engine is enabled
vault secrets list

# Check roleset configuration
vault read gcp/roleset/terraform-provisioner

# Verify Vault service account has permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID
```

### AAP OAuth2 Fails

```bash
# Verify OAuth2 app exists in AAP
# AAP UI → Administration → Applications

# Test OAuth2 token generation
curl -X POST https://your-aap-server/api/o/token/ \
  -d "grant_type=password&client_id=...&client_secret=..."

# Check Vault secret
vault kv get secret/aap/oauth2
```

---

## Security Best Practices

1. ✅ **Never commit credentials** - All credentials are dynamic
2. ✅ **Use least privilege** - Each role has minimal permissions
3. ✅ **Enable audit logging** - Track all credential access
4. ✅ **Rotate regularly** - Credentials auto-rotate per run
5. ✅ **Monitor usage** - Set up alerts for unusual activity

---

## Next Steps

1. Review `README.md` for architecture overview
2. Run `./validate-production.sh` for security checks
3. Configure monitoring and alerts
4. Set up backup policies
5. Document runbook for team

---

## Support

- **Vault JWT Auth**: https://developer.hashicorp.com/vault/docs/auth/jwt
- **Vault GCP Secrets**: https://developer.hashicorp.com/vault/docs/secrets/gcp
- **TFC Dynamic Credentials**: https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials
- **GCP OS Login**: https://cloud.google.com/compute/docs/oslogin
