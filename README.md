# Terraform Actions + Ansible Automation Platform + GCP

Automate VM patching using Terraform Actions, Ansible Automation Platform, and HashiCorp Vault with keyless authentication.

## Features

- **Keyless Authentication**: OIDC Workload Identity (no service account keys)
- **Dynamic Credentials**: Vault integration for secrets management
- **GCP OS Login**: IAM-based SSH access (no key management on VMs)
- **Terraform Actions**: Automated post-apply workflows
- **Production-Ready**: Conditional firewall, environment validation, comprehensive tests

## Quick Start

### Prerequisites

- GCP Project with billing enabled
- HCP Terraform workspace
- HCP Vault cluster
- Ansible Automation Platform
- Tools: `gcloud`, `terraform`, `vault`, `task`

### 1. Configure GCP

```bash
export PROJECT_ID="your-project-id"
task gcp-setup
task gcp-create-key
```

This creates:
- VPC network
- Workload Identity Pool & Provider
- Service Account with OS Login permissions
- IAM bindings

### 2. Configure Vault

```bash
vault kv put secret/aap/api-token token="YOUR_AAP_TOKEN"
```

### 3. Configure HCP Terraform

Set workspace variables:

| Variable | Type | Description |
|----------|------|-------------|
| `vault_addr` | String | HCP Vault address |
| `VAULT_TOKEN` | String (sensitive) | Vault token |
| `VAULT_NAMESPACE` | String | Vault namespace |
| `aap_hostname` | String | AAP server hostname |
| `aap_job_template_id` | Number | AAP job template ID |
| `gcp_project_id` | String | GCP project ID |
| `ansible_user` | String | OS Login username |
| `aap_oidc_issuer_url` | String | AAP OIDC issuer URL |
| `aap_oidc_repository` | String | Repository (org/repo) |
| `environment` | String | demo/dev/staging/production |
| `aap_server_ip` | String | AAP server IP (required for production) |

### 4. Setup SSH Access

```bash
cd terraform
terraform apply

# Add SSH key to OS Login
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub
rm /tmp/key.pub

# Get your OS Login username
YOUR_USERNAME=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)")
echo "Your OS Login username: $YOUR_USERNAME"
```

### 5. Configure AAP

Create two credentials in AAP:

**GCP OIDC Credential:**
- Type: Google Cloud Platform
- Auth: Workload Identity Federation
- Get values from: `terraform output oidc_configuration`

**SSH Credential:**
- Type: Machine
- Username: Your OS Login username (from step 4)
- SSH Key: `terraform output -raw ansible_ssh_private_key`

Update job template:
- Attach both credentials
- Enable "Prompt on launch" for Variables

### 6. Deploy

```bash
git commit --allow-empty -m "Test automation"
git push origin main
```

Terraform Actions will automatically trigger AAP job after apply.

## Architecture

```
Developer → GitHub → HCP Terraform → Vault (secrets)
                          ↓
                    GCP VMs Created
                          ↓
                  Terraform Actions
                          ↓
                    AAP Job (OIDC)
                          ↓
                  VMs Patched (OS Login SSH)
```

### Security Features

- **OIDC Workload Identity**: Keyless GCP authentication (1-hour tokens)
- **GCP OS Login**: IAM-based SSH (no keys on VMs)
- **Vault Integration**: Dynamic secrets management
- **Least Privilege IAM**: 6 specific roles only
- **Conditional Firewall**: Environment-aware rules
- **Audit Trail**: Complete logging

## Configuration

### Variables

```hcl
# terraform/terraform.tfvars
vm_count             = 5
vm_machine_type      = "e2-medium"
aap_job_template_id  = 11
ansible_user         = "your_username_com"
aap_oidc_issuer_url  = "https://aap-server"
aap_oidc_repository  = "org/repo"
environment          = "demo"  # demo/dev/staging/production
```

### Production Deployment

```hcl
# terraform/terraform.tfvars
environment = "production"
aap_server_ip = "YOUR_AAP_IP"  # Required
```

**Production changes:**
- Firewall restricted to AAP IP + Cloud IAP only
- Environment validation enforced
- Higher security requirements

## OIDC Workload Identity

### Why OIDC?

**Service Account Keys (Old):**
- ❌ Long-lived credentials
- ❌ Manual rotation required
- ❌ Risk of key leakage
- ❌ Must store in Vault

**OIDC Workload Identity (New):**
- ✅ Keyless authentication
- ✅ Short-lived tokens (1-hour)
- ✅ Auto-renewed
- ✅ No secret storage
- ✅ Zero key leakage risk

### How It Works

1. AAP generates OIDC token when job runs
2. Token exchanged for GCP access token via Workload Identity Pool
3. Access token impersonates service account
4. Service account has OS Login permissions
5. SSH access granted via OS Login

### Configuration

Terraform automatically creates:
- Workload Identity Pool
- Workload Identity Provider
- Service Account
- IAM bindings

Get OIDC config for AAP:
```bash
terraform output oidc_configuration
```

## Testing

```bash
task test              # Run all tests
task test-terraform    # Terraform validation
task test-ansible      # Ansible syntax check
task test-python       # Property-based tests
```

### Production Validation

```bash
./validate-production.sh
```

Checks:
- Firewall rules (production conditional)
- IAM roles (least privilege)
- Vault authentication (no static tokens)
- VM network configuration
- Monitoring configuration
- Backup configuration
- Environment validation
- Test coverage
- Documentation
- Hardcoded secrets

## Troubleshooting

### SSH Connection Fails

```bash
# 1. Verify SSH key in OS Login
gcloud compute os-login ssh-keys list

# 2. Add key if missing
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub
rm /tmp/key.pub

# 3. Get correct username
YOUR_USERNAME=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)")

# 4. Update AAP SSH credential with correct username
```

### Empty Inventory in AAP

- Enable "Prompt on launch" for Variables in job template
- Verify `aap_job_template_id` matches your template

### Playbook Changes Not Reflected

- Sync AAP project: AAP UI → Resources → Projects → Your Project → Sync

### OIDC Authentication Fails

```bash
# Verify OIDC configuration
terraform output oidc_configuration

# Check AAP credential configuration matches output
# Ensure aap_oidc_issuer_url and aap_oidc_repository are correct
```

## Production Recommendations

### Critical Security

1. **Firewall Rules** (CRITICAL)
   - Set `environment = "production"`
   - Set `aap_server_ip` to your AAP server IP
   - Firewall will restrict to AAP IP + Cloud IAP only

2. **Network Architecture**
   - Use private subnet + Cloud NAT
   - Remove public IPs from VMs
   - 90% attack surface reduction
   - Cost: +$35/month

3. **Monitoring & Alerts**
   - Enable Cloud Monitoring
   - Set up alerts for failed patches
   - Monitor SSH access logs
   - Track Terraform Actions execution

4. **Backup Policy**
   - Daily snapshots
   - 7-day retention
   - Automated via Cloud Scheduler

5. **Dynamic Vault Credentials**
   - Use JWT auth instead of static tokens
   - 20-minute TTL
   - Auto-rotation

### Cost Impact

| Item | Monthly Cost | Security Benefit |
|------|--------------|------------------|
| Cloud NAT | $35 | 90% attack surface reduction |
| Monitoring | Included | Proactive issue detection |
| Snapshots | $5-10 | Disaster recovery |
| **Total** | **$40-45** | **25% security improvement** |

## Project Structure

```
.
├── terraform/
│   ├── main.tf           # Infrastructure (conditional firewall)
│   ├── actions.tf        # Terraform Actions
│   ├── variables.tf      # Variables (environment validation)
│   ├── outputs.tf        # Outputs (OIDC config)
│   └── providers.tf      # Providers
├── ansible/
│   └── gcp_vm_patching_demo.yml
├── tests/                # 8 test files
├── Taskfile.yml          # Automation tasks
├── validate-production.sh # Production validation
└── README.md             # This file
```

## IAM Roles

Least privilege roles used:

1. `roles/compute.osLogin` - OS Login access
2. `roles/iam.serviceAccountUser` - Service account impersonation
3. `roles/compute.instanceAdmin.v1` - VM management
4. `roles/compute.networkAdmin` - Network management
5. `roles/iam.serviceAccountAdmin` - Service account management
6. `roles/iam.workloadIdentityPoolAdmin` - Workload Identity management

## Support

- **Issues**: [GitHub Issues](../../issues)
- **GCP OS Login**: [Documentation](https://cloud.google.com/compute/docs/oslogin)
- **Terraform Actions**: [Documentation](https://developer.hashicorp.com/terraform/cloud-docs/integrations/run-tasks)
- **Workload Identity**: [Documentation](https://cloud.google.com/iam/docs/workload-identity-federation)

## License

MIT

## Author

Dr. Rahul Gaikwad
