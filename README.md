# Terraform Actions for Day-2 Operations with Ansible

**Production-ready solution for automating VM patching using Terraform Actions, Ansible Automation Platform, and HashiCorp Vault**

## Overview

This solution demonstrates how to bridge Infrastructure as Code (IaC) with Day-2 operations by using **Terraform Actions** to trigger **Ansible Automation Platform** jobs for automated VM patching. All credentials are securely managed through **HashiCorp Vault**.

### Key Features

- ✅ **Automated VM Provisioning** - Terraform provisions Ubuntu VMs on GCP
- ✅ **Day-2 Operations** - Terraform Actions trigger AAP for patching
- ✅ **Secure Credentials** - All secrets stored in HashiCorp Vault
- ✅ **Dynamic Inventory** - VM inventory automatically generated from Terraform state
- ✅ **Production Ready** - Includes tests, validation, and best practices
- ✅ **Fully Automated** - One-command setup via Taskfile

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    HCP Terraform                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Provisioning │──│   Actions    │──│    Vault     │      │
│  │   (Day 0)    │  │   (Day 2)    │  │ Integration  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │ Provisions       │ Triggers         │ Retrieves
          │ Infrastructure   │ Patching         │ Credentials
          ▼                  ▼                  ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   GCP VMs       │  │      AAP        │  │  Vault Server   │
│  ubuntu-vm-*    │◀─│  Job Template   │  │   Secrets:      │
│                 │  │   + Playbook    │  │   - GCP SA      │
│                 │  │   + Inventory   │  │   - AAP Token   │
│                 │  │                 │  │   - SSH Keys    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Installation & Setup](#installation--setup)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Demo Walkthrough](#demo-walkthrough)
7. [Testing](#testing)
8. [Security](#security-best-practices)
9. [Troubleshooting](#troubleshooting)
10. [Contributing](#contributing)

---

## Quick Start

```bash
# 1. Clone the repository
git clone <repository-url>
cd tf-actions-aap-gcp

# 2. Verify prerequisites
task check-prereqs

# 3. Set environment variables
export PROJECT_ID="your-gcp-project-id"
export VAULT_ADDR="https://your-vault-cluster.vault.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"

# 4. Run automated setup
task setup
```

---

## Prerequisites

### Required Accounts & Access

- **GCP Project** with billing enabled
- **HCP Terraform** account and workspace
- **HCP Vault** cluster or Vault server
- **Ansible Automation Platform** (AAP) access

### Required Tools

- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads) >= 1.7.0
- [Vault CLI](https://www.vaultproject.io/downloads)
- [Task](https://taskfile.dev/installation/)
- Python 3.8+

### Verify Prerequisites

```bash
task check-prereqs

# Expected output:
#   gcloud: ✓
#   terraform: ✓
#   vault: ✓
#   python3: ✓
#   git: ✓
```

---

## Installation & Setup

### Step 1: Environment Variables

```bash
# Set these in your terminal (add to ~/.zshrc or ~/.bashrc for persistence)
export PROJECT_ID="your-gcp-project-id"
export VAULT_ADDR="https://your-vault-cluster.vault.hashicorp.cloud:8200"
export VAULT_TOKEN="your-vault-token"
export VAULT_NAMESPACE="admin"
```

### Step 2: GCP Service Account Setup

```bash
# Create service account with required permissions
task gcp-setup
```

**Required GCP Roles:**
- `roles/compute.instanceAdmin.v1`
- `roles/compute.networkAdmin`
- `roles/compute.securityAdmin`
- `roles/osconfig.patchDeploymentAdmin`
- `roles/iam.serviceAccountUser`

### Step 3: Generate SSH Keys

```bash
# Generate SSH key pair for VM access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu-patching -N ''
```

### Step 4: Store Credentials in Vault

```bash
# 1. Store GCP service account key
task gcp-create-key

# 2. Store AAP API token
vault kv put secret/aap/api-token token="YOUR_AAP_API_TOKEN"

# 3. Store SSH keys
vault kv put secret/ssh/ubuntu-key \
  private_key=@$HOME/.ssh/ubuntu-patching \
  public_key=@$HOME/.ssh/ubuntu-patching.pub

# 4. Verify all secrets
task vault-verify
```

**Required Vault Secrets:**
- `secret/gcp/service-account` - GCP service account JSON key
- `secret/aap/api-token` - AAP API authentication token
- `secret/ssh/ubuntu-key` - SSH key pair for VM access

---

## Configuration

### 1. AAP Configuration

**Create Project:**
1. Navigate to **Resources → Projects → Add**
2. Configure:
   - **Name**: `GCP VM Patching`
   - **SCM Type**: `Git`
   - **SCM URL**: `https://github.com/your-org/tf-actions-aap-gcp.git`
   - **Branch**: `main`
   - **Options**: ✓ Update Revision on Launch
3. Click **Save** and **Sync**

**Create Credential:**
1. Navigate to **Resources → Credentials → Add**
2. Configure:
   - **Name**: `GCP Ubuntu SSH Key`
   - **Type**: `Machine`
   - **Username**: `ubuntu`
   - **SSH Private Key**: (from Vault: `vault kv get -field=private_key secret/ssh/ubuntu-key`)
3. Click **Save**

**Create Inventory:**
1. Navigate to **Resources → Inventories → Add inventory**
2. Configure:
   - **Name**: `GCP VMs`
   - **Variables**: Leave empty (populated dynamically)
3. Click **Save**

**Create Job Template:**
1. Navigate to **Resources → Templates → Add job template**
2. Configure:
   - **Name**: `GCP VM Patching`
   - **Inventory**: `GCP VMs`
   - **Project**: `GCP VM Patching`
   - **Playbook**: `ansible/gcp_vm_patching.yml`
   - **Credentials**: `GCP Ubuntu SSH Key`
   - **Options**: ✓ Prompt on launch for Variables
3. Click **Save**
4. Note the Job Template ID from the URL

**Generate API Token:**
1. User Menu → Tokens → Add
2. Configure:
   - **Scope**: `Write`
   - **Description**: `Terraform Actions Token`
3. Copy token and store in Vault

### 2. HCP Terraform Workspace

Configure these variables in your HCP Terraform workspace:

**Terraform Variables:**
- `vault_addr` = `https://your-vault-cluster.vault.hashicorp.cloud:8200`
- `aap_api_url` = `https://your-aap-instance.com/api/controller/v2`
- `aap_job_template_id` = `<your-job-template-id>`
- `gcp_project_id` = `your-gcp-project-id`

**Environment Variables:**
- `VAULT_TOKEN` = `your-vault-token` (mark as sensitive)
- `VAULT_NAMESPACE` = `admin` (mark as sensitive)

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

---

## Usage

### Deploy Infrastructure

```bash
# Validate configuration
task tf-validate

# Deploy via HCP Terraform (VCS-driven)
git add .
git commit -m "Deploy infrastructure"
git push origin main

# Monitor in HCP Terraform UI
```

### Trigger VM Patching

```bash
# Generate payload
cd terraform
terraform output -raw action_patch_vms_payload > /tmp/aap_payload.json

# Get AAP details
AAP_URL=$(terraform output -raw action_patch_vms_url)
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Trigger patching job
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/aap_payload.json \
  ${AAP_URL}
```

### Monitor Execution

1. **HCP Terraform**: Monitor infrastructure changes
2. **AAP UI**: View job execution and playbook output
3. **GCP Console**: Verify VM status and patch compliance

---

## Demo Walkthrough

### Phase 1: Provision Infrastructure (5 minutes)

**Show the Code:**
```bash
# Show main infrastructure resources
cat terraform/main.tf | grep -A 10 "resource \"google_compute_instance\""

# Show Vault integration
cat terraform/main.tf | grep -A 5 "data \"vault_generic_secret\""

# Show Terraform Actions configuration
cat terraform/actions.tf | head -60
```

**Deploy Infrastructure:**

Via HCP Terraform UI (Recommended):
```bash
git add .
git commit -m "Deploy infrastructure for demo"
git push origin main
```

Via Local Terraform (Alternative):
```bash
cd terraform
terraform plan
terraform apply
```

**Verify Infrastructure:**
```bash
# View outputs
terraform output

# Expected output:
# vm_names = ["ubuntu-vm-1", "ubuntu-vm-2"]
# vm_external_ips = ["34.xx.xx.xx", "34.yy.yy.yy"]
```

**Test SSH Access:**
```bash
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/ubuntu-patching -o StrictHostKeyChecking=no ubuntu@${VM_IP} "hostname && uname -a"
```

### Phase 2: Trigger Terraform Actions (10 minutes)

**Prepare to Trigger Action:**
```bash
# Get AAP job template URL
AAP_URL=$(terraform output -raw action_patch_vms_url)

# Get AAP token from Vault
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Generate payload
terraform output -raw action_patch_vms_payload > /tmp/aap_payload.json

# View payload
cat /tmp/aap_payload.json | jq .
```

**Trigger AAP Job:**
```bash
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/aap_payload.json \
  ${AAP_URL} | jq .
```

### Phase 3: Monitor Execution (5 minutes)

**In AAP UI:**
1. Navigate to **Views → Jobs**
2. Find the most recent job
3. Watch real-time playbook output

**Expected Output:**
```
PLAY [Patch Ubuntu VMs] ************************************************

TASK [Gathering Facts] *************************************************
ok: [ubuntu-vm-1]
ok: [ubuntu-vm-2]

TASK [Update apt cache] ************************************************
changed: [ubuntu-vm-1]
changed: [ubuntu-vm-2]

TASK [Upgrade all security packages] ***********************************
changed: [ubuntu-vm-1]
changed: [ubuntu-vm-2]

PLAY RECAP *************************************************************
ubuntu-vm-1    : ok=5    changed=2    unreachable=0    failed=0
ubuntu-vm-2    : ok=5    changed=2    unreachable=0    failed=0
```

### Phase 4: Verify Results (5 minutes)

```bash
# SSH to VM and check results
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')

ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP} << 'EOF'
  echo "=== Last apt update ==="
  stat /var/cache/apt/pkgcache.bin | grep Modify
  
  echo -e "\n=== Available updates ==="
  sudo apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l
  
  echo -e "\n=== System uptime ==="
  uptime
EOF
```

---

## Project Structure

```
.
├── ansible/
│   └── gcp_vm_patching.yml    # VM patching playbook
├── terraform/                  # Terraform configuration
│   ├── main.tf                # Main infrastructure
│   ├── actions.tf             # Terraform Actions config
│   ├── variables.tf           # Variable definitions
│   ├── outputs.tf             # Output values
│   └── versions.tf            # Provider configuration
├── tests/                      # Test suite
│   ├── test_*.py              # Property-based tests
│   ├── validate_*.sh          # Validation scripts
│   └── requirements.txt       # Python dependencies
├── README.md                   # This file
├── LICENSE                     # MIT License
└── Taskfile.yml               # Task automation
```

---

## Available Tasks

```bash
# Setup & Configuration
task setup              # Complete automated setup
task gcp-setup          # Configure GCP service account
task gcp-create-key     # Create and store GCP key in Vault
task vault-setup        # Guide for Vault configuration
task vault-verify       # Verify all Vault secrets

# Terraform Operations
task tf-init            # Initialize Terraform
task tf-validate        # Validate and format Terraform
task tf-plan            # Run Terraform plan (local)
task tf-clean           # Clean Terraform temporary files

# Testing
task test               # Run all tests
task test-terraform     # Validate Terraform configuration
task test-ansible       # Validate Ansible playbooks
task test-python        # Run property-based tests

# Utilities
task check-prereqs      # Check all prerequisites
task clean              # Clean all temporary files
task help               # Show available tasks
```

---

## Testing

```bash
# Run complete test suite
task test

# Run specific tests
task test-terraform     # Terraform validation
task test-ansible       # Ansible syntax check
task test-python        # Property-based tests

# Run tests manually
cd tests
python -m pytest -v
```

**Test Coverage:**
- ✅ Terraform configuration validation
- ✅ Ansible playbook syntax
- ✅ Firewall rules (minimal access)
- ✅ IAM permissions (least privilege)
- ✅ Vault credential retrieval
- ✅ VM provisioning completeness
- ✅ No plaintext credentials

---

## Security Best Practices

### Implemented Security Measures

1. **Credential Management**
   - All secrets stored in HashiCorp Vault
   - No credentials in code or configuration files
   - Vault audit logging enabled
   - Short-lived tokens recommended

2. **Network Security**
   - Minimal firewall rules (SSH only)
   - Custom VPC network
   - No public access except SSH
   - Source IP restrictions recommended for production

3. **IAM & Access Control**
   - Principle of least privilege
   - Service accounts with minimal permissions
   - Role-based access control (RBAC)
   - Separate service accounts per function

4. **Infrastructure Security**
   - Encrypted state in HCP Terraform
   - VCS-driven workflow (audit trail)
   - Immutable infrastructure
   - Regular security updates via patching

5. **Operational Security**
   - Property-based testing
   - Automated validation
   - Change approval workflows
   - Complete audit trail

### Production Recommendations

1. **Restrict SSH Access**
   ```hcl
   # In terraform/main.tf, update firewall rule:
   source_ranges = ["YOUR_OFFICE_IP/32"]  # Instead of 0.0.0.0/0
   ```

2. **Enable Vault Audit Logging**
   ```bash
   vault audit enable file file_path=/var/log/vault/audit.log
   ```

3. **Rotate Credentials Regularly**
   ```bash
   # Rotate GCP service account key
   task gcp-create-key
   
   # Rotate AAP token (in AAP UI)
   # Update Vault with new token
   ```

4. **Use Private VMs** (Optional)
   - Remove external IPs
   - Use Cloud NAT for outbound
   - Access via bastion host or VPN

5. **Enable GCP Security Features**
   - OS Login
   - Shielded VMs
   - Binary Authorization
   - Security Command Center

---

## Troubleshooting

### Common Issues

**1. SSH Connection Fails**
```bash
# Verify SSH key in Vault matches VM metadata
vault kv get secret/ssh/ubuntu-key

# Test SSH manually
VM_IP=$(cd terraform && terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP}

# If keys don't match, update Vault and re-apply Terraform
vault kv put secret/ssh/ubuntu-key \
  private_key=@$HOME/.ssh/ubuntu-patching \
  public_key=@$HOME/.ssh/ubuntu-patching.pub

cd terraform
terraform apply -replace="google_compute_instance.ubuntu_vms[0]"
```

**2. AAP Job Shows Empty Inventory**
- Ensure job template has "Prompt on launch" enabled for Variables
- Verify AAP project is synced with latest playbook
- Check extra_vars in job output

**3. Vault Connection Errors**
```bash
# Verify Vault connectivity
vault status

# Re-authenticate
vault login

# Check secrets exist
task vault-verify
```

**4. Terraform Apply Fails (VCS Mode)**
- Commit and push changes to trigger HCP Terraform
- Cannot run `terraform apply` locally with VCS connection
- Use HCP Terraform UI to approve and apply

**5. GCP Permission Errors**
```bash
# Verify service account has required roles
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:terraform-automation@*"
```

**6. AAP API Authentication Fails**
```bash
# Verify AAP token is valid
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  https://your-aap-instance.com/api/v2/me/
```

---

## Production Deployment Checklist

- [ ] Review and customize `terraform/terraform.tfvars`
- [ ] Restrict firewall source IPs to known ranges
- [ ] Enable Vault audit logging
- [ ] Configure HCP Terraform notifications
- [ ] Set up monitoring and alerting
- [ ] Document runbooks for common operations
- [ ] Establish credential rotation schedule
- [ ] Configure backup and disaster recovery
- [ ] Review and approve IAM permissions
- [ ] Enable GCP security features (OS Login, Shielded VMs)
- [ ] Set up cost monitoring and budgets
- [ ] Configure log aggregation and retention
- [ ] Establish change management process
- [ ] Train team on operational procedures
- [ ] Perform security audit and penetration testing

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes and test (`task test`)
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/your-org/tf-actions-aap-gcp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/tf-actions-aap-gcp/discussions)

---

## Acknowledgments

- HashiCorp for Terraform and Vault
- Red Hat for Ansible Automation Platform
- Google Cloud Platform
- Conference talk: "From IaC to InfraOps: Automating Day-2 Operations with Terraform Actions & Ansible"

---

**Built with ❤️ for automating Day-2 operations**
