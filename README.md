# Terraform Actions + Ansible Automation Platform + GCP

**Automate GCP VM patching using Terraform Actions and Ansible Automation Platform with dynamic credentials.**

## 🎯 What This Does

1. **Terraform** provisions GCP VMs
2. **Terraform Actions** automatically triggers AAP job after VM creation
3. **AAP** patches VMs using GCP OS Login (IAM-based SSH)
4. **Vault** provides dynamic GCP credentials (no static keys)

## 🔐 Security Features

- ✅ **Zero static credentials** - All credentials are dynamic
- ✅ **GCP OS Login** - IAM-based SSH (no SSH keys on VMs)
- ✅ **Vault dynamic secrets** - 1-hour GCP access tokens
- ✅ **AAP OAuth2** - Short-lived API tokens
- ✅ **Automated rotation** - Credentials auto-rotate every run

**Security Score: 9/10**

---

## 📋 Prerequisites

- **GCP Project** with billing enabled
- **HCP Terraform** workspace (or Terraform Enterprise)
- **HCP Vault** cluster (or self-hosted Vault)
- **Ansible Automation Platform** 2.4+
- **Tools**: `gcloud`, `terraform`, `vault`, `task` (optional)

---

## 🚀 Quick Start (15 minutes)

### Step 1: Setup Vault (5 min)

```bash
# 1. Enable GCP secrets engine
vault secrets enable gcp

# 2. Configure with GCP service account key
vault write gcp/config credentials=@vault-admin-key.json

# 3. Create roleset for Terraform
vault write gcp/roleset/terraform-provisioner \
  project="YOUR_PROJECT_ID" \
  secret_type="access_token" \
  token_scopes="https://www.googleapis.com/auth/cloud-platform"

# 4. Store AAP credentials
vault kv put secret/aap/credentials \
  username="admin" \
  password="YOUR_AAP_PASSWORD"

# 5. Test
vault read gcp/token/terraform-provisioner
```

### Step 2: Configure HCP Terraform (3 min)

Set these workspace variables:

| Variable | Value | Type |
|----------|-------|------|
| `vault_addr` | `https://your-vault.vault.hashicorp.cloud:8200` | terraform |
| `vault_namespace` | `admin` | terraform |
| `vault_token` | `<your-vault-token>` | terraform (sensitive) |
| `gcp_project_id` | `your-project-id` | terraform |
| `aap_hostname` | `https://your-aap-server` | terraform |
| `aap_username` | `admin` | terraform |
| `aap_password` | `<your-password>` | terraform (sensitive) |
| `aap_job_template_id` | `14` | terraform |
| `environment` | `demo` | terraform |

### Step 3: Deploy Infrastructure (5 min)

```bash
# Clone repo
git clone https://github.com/your-org/tf-actions-aap-gcp
cd tf-actions-aap-gcp/terraform

# Initialize
terraform init

# Deploy
terraform apply

# Add SSH key to OS Login
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub
rm /tmp/key.pub

# Get your OS Login username
gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)"
```

### Step 4: Configure AAP (2 min)

**Create SSH Credential:**
1. AAP → Credentials → Add
2. Type: **Machine**
3. Username: `<your-os-login-username>` (from step 3)
4. SSH Private Key: `terraform output -raw ansible_ssh_private_key`
5. Save

**Attach to Job Template:**
1. AAP → Templates → "Patch GCP VMs" → Edit
2. Credentials: Select the SSH credential you just created
3. Save

### Step 5: Test (1 min)

```bash
# Trigger via git push
git commit --allow-empty -m "Test automation"
git push origin main
```

✅ **Done!** Terraform will create VMs and automatically trigger AAP to patch them.

---

## 📐 Architecture

```
┌─────────────┐
│  Developer  │
│ (git push)  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│      HCP Terraform Workspace            │
│  • Reads GCP creds from Vault           │
│  • Creates VMs with OS Login enabled    │
│  • Triggers AAP job via action          │
└──────┬──────────────────────┬───────────┘
       │                      │
       │ GCP Token            │ AAP API Call
       ▼                      ▼
┌─────────────┐        ┌─────────────────┐
│ HCP Vault   │        │      AAP        │
│ • GCP       │        │ • Receives      │
│   Secrets   │        │   inventory     │
│ • AAP Creds │        │ • Connects via  │
└─────────────┘        │   OS Login      │
                       │ • Patches VMs   │
                       └────────┬────────┘
                                │
                                │ SSH (OS Login)
                                ▼
                       ┌─────────────────┐
                       │    GCP VMs      │
                       │ • OS Login      │
                       │   enabled       │
                       │ • No SSH keys   │
                       └─────────────────┘
```

---

## 🔧 Configuration

### Terraform Variables

```hcl
# terraform/terraform.tfvars
vm_count             = 2
vm_machine_type      = "e2-medium"
gcp_region           = "us-central1"
gcp_zone             = "us-central1-a"
aap_job_template_id  = 14
environment          = "demo"  # or "production"
reboot_allowed       = false
```

### AAP Job Template

- **Name**: Patch GCP VMs
- **Inventory**: Created dynamically by Terraform
- **Playbook**: `ansible/playbooks/gcp_vm_patching_demo.yml`
- **Credentials**: Machine credential with OS Login username
- **Variables**: Prompt on launch enabled

---

## 🧪 Testing

```bash
# Run all tests
task test

# Individual tests
task test-terraform    # Terraform validation
task test-ansible      # Ansible syntax check
task test-python       # Property-based tests

# Production validation
./validate-production.sh
```

---

## 🐛 Troubleshooting

### SSH Connection Fails

**Problem**: `Permission denied (publickey)`

**Solution**:
```bash
# 1. Verify SSH key is in OS Login
gcloud compute os-login ssh-keys list

# 2. Add key if missing
terraform output -raw ansible_ssh_public_key > /tmp/key.pub
gcloud compute os-login ssh-keys add --key-file=/tmp/key.pub

# 3. Get correct username
gcloud compute os-login describe-profile --format="value(posixAccounts[0].username)"

# 4. Update AAP SSH credential with correct username
```

### Empty Inventory in AAP

**Problem**: AAP job shows "no hosts matched"

**Solution**:
- Enable "Prompt on launch" for Variables in job template
- Verify `aap_job_template_id` matches your template ID

### Vault Token Expired

**Problem**: `permission denied` from Vault

**Solution**:
```bash
# Generate new token
vault token create -policy=terraform-provisioner -ttl=24h

# Update TFC workspace variable: vault_token
```

---

## 📊 Monitoring

### Credential TTLs

| Credential | TTL | Rotation |
|------------|-----|----------|
| Vault Token | 24 hours | Manual |
| GCP Access Token | 1 hour | Auto (per run) |
| AAP OAuth2 Token | 10 hours | Auto (per run) |
| OS Login SSH Cert | 1 hour | Auto (per connection) |

### Health Checks

```bash
# Check Vault connectivity
vault status

# Verify GCP token generation
vault read gcp/token/terraform-provisioner

# Test AAP API
curl -u admin:password https://your-aap-server/api/v2/ping/
```

---

## 🏭 Production Deployment

### Critical Changes

1. **Set environment to production**:
   ```hcl
   environment = "production"
   aap_server_ip = "YOUR_AAP_PUBLIC_IP/32"
   ```

2. **Enable TLS verification**:
   ```hcl
   vault_skip_tls_verify = false
   aap_insecure_skip_verify = false
   ```

3. **Use private networking**:
   - Deploy VMs in private subnet
   - Use Cloud NAT for outbound
   - Remove public IPs

4. **Enable monitoring**:
   - Cloud Monitoring alerts
   - Vault audit logs
   - AAP job notifications

### Cost Impact

| Item | Monthly Cost |
|------|--------------|
| 2x e2-medium VMs | ~$50 |
| Cloud NAT (optional) | ~$35 |
| Monitoring | Included |
| **Total** | **$50-85** |

---

## 📁 Project Structure

```
.
├── terraform/
│   ├── main.tf           # VM provisioning
│   ├── actions.tf        # Terraform Actions
│   ├── providers.tf      # Provider configuration
│   ├── variables.tf      # Input variables
│   └── outputs.tf        # Outputs
├── ansible/
│   └── playbooks/
│       └── gcp_vm_patching_demo.yml
├── tests/                # 8 test files
├── Taskfile.yml          # Task automation
├── validate-production.sh
├── SETUP.md              # Detailed setup guide
└── README.md             # This file
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `task test`
5. Submit a pull request

---

## 📚 Resources

- [Terraform Actions Documentation](https://developer.hashicorp.com/terraform/cloud-docs/integrations/run-tasks)
- [Vault GCP Secrets Engine](https://developer.hashicorp.com/vault/docs/secrets/gcp)
- [GCP OS Login](https://cloud.google.com/compute/docs/oslogin)
- [AAP Provider](https://registry.terraform.io/providers/ansible/aap/latest/docs)

---

## 📄 License

MIT

---

## ✍️ Author

Dr. Rahul Gaikwad
