# Terraform Actions for Day-2 Operations

Automate VM patching using Terraform Actions, Ansible Automation Platform, and HashiCorp Vault with GCP OS Login.

## Quick Start

### Prerequisites
- GCP Project
- HCP Terraform workspace
- HCP Vault cluster
- Ansible Automation Platform
- Tools: `gcloud`, `terraform`, `vault`

### Setup

**1. Configure GCP**
```bash
export PROJECT_ID="your-project-id"
task gcp-setup
task gcp-create-key
```

**2. Configure Vault**
```bash
# Store AAP token
vault kv put secret/aap/api-token token="YOUR_TOKEN"
```

**3. Configure HCP Terraform**

Set workspace variables:
- `vault_addr`, `aap_hostname`, `aap_job_template_id`
- `gcp_project_id`, `ansible_user`
- `aap_oidc_issuer_url`, `aap_oidc_repository`
- `VAULT_TOKEN` (sensitive), `VAULT_NAMESPACE`

**4. Setup SSH Access**
```bash
cd terraform
terraform apply

# Add SSH key to OS Login
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub
rm /tmp/key.pub

# Get your username
YOUR_USERNAME=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)")
echo "Your OS Login username: $YOUR_USERNAME"
```

**5. Configure AAP**

Create two credentials:

1. **GCP OIDC Credential**
   - Type: Google Cloud Platform
   - Auth: Workload Identity Federation
   - Use values from: `terraform output oidc_configuration`

2. **SSH Credential**
   - Type: Machine
   - Username: Your OS Login username
   - SSH Key: `terraform output -raw ansible_ssh_private_key`

Update job template to use both credentials and enable "Prompt on launch" for Variables.

**6. Deploy**
```bash
git commit --allow-empty -m "Test automation"
git push origin main
```

---

## Architecture

```
Developer → GitHub → HCP Terraform → Vault (secrets)
                          ↓
                    GCP VMs Created
                          ↓
                  Terraform Actions
                          ↓
                    AAP Job Triggered
                          ↓
                  VMs Patched via SSH
```

**Security:**
- Dynamic credentials via Vault
- OIDC Workload Identity (keyless GCP auth, 1-hour tokens)
- GCP OS Login (IAM-based SSH)
- Least privilege IAM roles
- Conditional firewall (demo vs production)

---

## Configuration

### Key Variables

```hcl
vm_count             = 5
vm_machine_type      = "e2-medium"
aap_job_template_id  = 11
ansible_user         = "your_username_com"
aap_oidc_issuer_url  = "https://aap-server"
aap_oidc_repository  = "org/repo"
environment          = "demo"  # or "production"
```

### Production Deployment

```hcl
# terraform/terraform.tfvars
environment = "production"
aap_server_ip = "YOUR_AAP_IP"  # Required for production
```

**Production changes:**
- Firewall restricted to AAP IP + Cloud IAP only
- Environment validation enforced
- Security score: 70% → 75%

---

## Testing

```bash
task test              # Run all tests
task test-terraform    # Terraform validation
task test-ansible      # Ansible syntax
task test-python       # Property-based tests
```

**Validate production readiness:**
```bash
./validate-production.sh
```

---

## Troubleshooting

### SSH Connection Fails

**Solution:**
```bash
# 1. Verify SSH key in OS Login
gcloud compute os-login ssh-keys list

# 2. Add key if missing
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub
rm /tmp/key.pub

# 3. Get correct username
YOUR_USERNAME=$(gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)")

# 4. Update AAP credential with correct username
```

### Empty Inventory in AAP

**Solution:**
- Enable "Prompt on launch" for Variables in job template
- Verify `aap_job_template_id` matches your template

### Playbook Changes Not Reflected

**Solution:**
- Sync AAP project after playbook changes
- AAP UI → Resources → Projects → Your Project → Sync

---

## Security

### Implemented
- ✅ Dynamic credentials (Vault + OIDC)
- ✅ Least privilege IAM (6 specific roles)
- ✅ Conditional firewall (environment-aware)
- ✅ GCP OS Login (no key management on VMs)
- ✅ Short-lived tokens (1-hour)
- ✅ Complete audit trail

### Production Recommendations
- Private subnet + Cloud NAT (90% attack surface reduction)
- Monitoring & alerts (proactive issue detection)
- Backup policy (daily snapshots, 7-day retention)
- Dynamic Vault tokens (JWT auth, 20-min TTL)

**Cost:** +$35/month (16% increase) for 25% security improvement

See `PRODUCTION_READINESS_REPORT.md` for details.

---

## Project Structure

```
.
├── terraform/
│   ├── main.tf           # Infrastructure
│   ├── actions.tf        # Terraform Actions
│   ├── variables.tf      # Variables
│   └── outputs.tf        # Outputs
├── ansible/
│   └── gcp_vm_patching_demo.yml
├── tests/                # Test suite
├── Taskfile.yml          # Automation tasks
└── README.md             # This file
```

---

## Documentation

- **OIDC_SETUP.md** - Keyless GCP authentication guide
- **PRODUCTION_READINESS_REPORT.md** - Production deployment guide
- **ARCHITECTURE_DIAGRAMS.md** - Architecture diagrams
- **terraform/final-blog.md** - Complete blog post

---

## Support

- **Issues:** [GitHub Issues](../../issues)
- **GCP OS Login:** [Docs](https://cloud.google.com/compute/docs/oslogin)
- **Terraform Actions:** [Docs](https://developer.hashicorp.com/terraform/cloud-docs/integrations/run-tasks)

---

**License:** MIT  
**Author:** Dr. Rahul Gaikwad
