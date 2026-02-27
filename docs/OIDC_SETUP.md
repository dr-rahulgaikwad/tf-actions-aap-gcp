# OIDC Workload Identity Setup

## Why OIDC Instead of Service Account Keys?

**Service Account Keys (Old Approach)**:
- ❌ Long-lived credentials (never expire)
- ❌ Must be stored securely in Vault
- ❌ Requires manual rotation
- ❌ Risk of key leakage
- ❌ Additional secret management overhead

**OIDC Workload Identity (New Approach)**:
- ✅ Keyless authentication (no credentials to manage)
- ✅ Short-lived tokens (1-hour expiration, auto-renewed)
- ✅ No secret storage needed
- ✅ Zero risk of key leakage
- ✅ Simpler, more secure workflow

## Architecture

```
AAP Job → OIDC Token → GCP Workload Identity Pool → Service Account → OS Login SSH
```

1. AAP generates OIDC token when job runs
2. Token is exchanged for GCP access token via Workload Identity Pool
3. Access token impersonates service account
4. Service account has OS Login permissions on VMs
5. SSH access granted via OS Login

## Implementation

### Terraform Resources Created

1. **Workload Identity Pool**: Container for OIDC providers
2. **Workload Identity Provider**: Maps AAP OIDC tokens to GCP identities
3. **Service Account**: Used for OS Login SSH access
4. **IAM Binding**: Allows OIDC tokens to impersonate service account
5. **Instance IAM**: Grants service account OS Login permissions on VMs

### Required Variables

```hcl
aap_oidc_issuer_url  = "https://your-aap-server"  # AAP server URL
aap_oidc_repository  = "your-org/your-repo"       # Repository identifier
```

### Terraform Outputs

```bash
terraform output oidc_configuration
# Returns:
# {
#   service_account_email = "ansible-automation@project.iam.gserviceaccount.com"
#   workload_provider     = "projects/123/locations/global/workloadIdentityPools/aap-automation-pool/providers/aap-oidc-provider"
#   project_id            = "your-project-id"
# }
```

## AAP Configuration

### 1. Create GCP OIDC Credential

**AAP UI → Resources → Credentials → Add**

- **Name**: GCP OIDC Credential
- **Credential Type**: Google Cloud Platform
- **Authentication Type**: Workload Identity Federation
- **Workload Identity Provider**: `<from terraform output>`
- **Service Account Email**: `<from terraform output>`
- **Project ID**: `<from terraform output>`

### 2. Create SSH Credential

**AAP UI → Resources → Credentials → Add**

- **Name**: GCP Ubuntu SSH Key
- **Credential Type**: Machine
- **Username**: Your OS Login username
- **SSH Private Key**: `terraform output -raw ansible_ssh_private_key`

### 3. Update Job Template

**AAP UI → Resources → Templates → Your Template → Edit**

- **Credentials**: Select BOTH credentials:
  - GCP OIDC Credential (for GCP API access)
  - GCP Ubuntu SSH Key (for SSH access)

## How It Works

### Token Flow

1. **Job Starts**: AAP job template execution begins
2. **OIDC Token Generated**: AAP creates signed JWT token with claims:
   ```json
   {
     "iss": "https://your-aap-server",
     "sub": "job:123",
     "aud": "gcp",
     "repository": "your-org/your-repo"
   }
   ```
3. **Token Exchange**: GCP Workload Identity validates token and issues access token
4. **Impersonation**: Access token allows impersonating service account
5. **API Calls**: Ansible modules use service account for GCP API calls
6. **SSH Access**: Service account has OS Login permissions, SSH succeeds

### Security Benefits

- **No Secrets**: Zero long-lived credentials in Vault or AAP
- **Automatic Expiration**: Tokens expire after 1 hour
- **Audit Trail**: GCP logs all Workload Identity token exchanges
- **Least Privilege**: Service account only has OS Login permissions
- **Revocable**: Disable Workload Identity Pool to revoke all access instantly

## Troubleshooting

### OIDC Token Not Accepted

**Symptom**: "Invalid OIDC token" or "Token validation failed"

**Solution**:
1. Verify `aap_oidc_issuer_url` matches AAP server URL exactly
2. Check `aap_oidc_repository` matches your repository
3. Ensure AAP OIDC is enabled and configured

### Service Account Impersonation Failed

**Symptom**: "Permission denied to impersonate service account"

**Solution**:
1. Verify IAM binding exists: `google_service_account_iam_member.workload_identity_user`
2. Check Workload Identity Pool and Provider are created
3. Ensure `attribute.repository` matches your repository

### SSH Still Fails

**Symptom**: SSH connection refused or permission denied

**Solution**:
- OIDC only handles GCP API authentication
- SSH still requires OS Login setup (separate from OIDC)
- Follow SSH setup steps in main README

## Migration from Service Account Keys

If you previously used service account keys:

1. **Deploy OIDC**: Apply Terraform changes to create Workload Identity resources
2. **Update AAP**: Create new GCP OIDC credential in AAP
3. **Update Job Template**: Replace old credential with new OIDC credential
4. **Test**: Run job to verify OIDC authentication works
5. **Cleanup**: Delete old service account key from Vault
6. **Remove**: Delete `vault kv delete secret/gcp/ansible-sa-key`

## References

- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [OIDC Token Format](https://openid.net/specs/openid-connect-core-1_0.html)
- [AAP Credentials](https://docs.ansible.com/automation-controller/latest/html/userguide/credentials.html)
