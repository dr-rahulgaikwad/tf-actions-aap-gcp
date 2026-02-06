# Terraform Actions for Day-2 Operations with Ansible

**Production-ready solution for automating VM patching using Terraform Actions, Ansible Automation Platform, and HashiCorp Vault**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.7.0-623CE4)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/ansible-%3E%3D2.9-EE0000)](https://www.ansible.com/)

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

## Quick Start

### Prerequisites

- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads) >= 1.7.0
- [Vault CLI](https://www.vaultproject.io/downloads)
- [Task](https://taskfile.dev/installation/)
- Python 3.8+
- GCP Project with billing enabled
- HCP Terraform account
- HCP Vault cluster
- Ansible Automation Platform (AAP) access

### Installation

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

## Configuration

### 1. GCP Setup

```bash
# Create service account with required permissions
task gcp-setup

# Create and store service account key in Vault
task gcp-create-key
```

**Required GCP Roles:**
- `roles/compute.instanceAdmin.v1`
- `roles/compute.networkAdmin`
- `roles/compute.securityAdmin`
- `roles/osconfig.patchDeploymentAdmin`
- `roles/iam.serviceAccountUser`

### 2. Vault Configuration

```bash
# Generate SSH keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ubuntu-patching -N ''

# Store credentials in Vault
vault kv put secret/ssh/ubuntu-key \
  private_key=@$HOME/.ssh/ubuntu-patching \
  public_key=@$HOME/.ssh/ubuntu-patching.pub

vault kv put secret/aap/api-token token="YOUR_AAP_TOKEN"

# Verify all secrets
task vault-verify
```

**Required Vault Secrets:**
- `secret/gcp/service-account` - GCP service account JSON key
- `secret/aap/api-token` - AAP API authentication token
- `secret/ssh/ubuntu-key` - SSH key pair for VM access

### 3. AAP Configuration

**Manual Steps Required:**

1. **Create Project**
   - Name: `GCP VM Patching`
   - SCM Type: `Git`
   - SCM URL: `https://github.com/your-org/tf-actions-aap-gcp.git`
   - Branch: `main`

2. **Create Credential**
   - Name: `GCP Ubuntu SSH Key`
   - Type: `Machine`
   - Username: `ubuntu`
   - SSH Private Key: (from Vault: `vault kv get -field=private_key secret/ssh/ubuntu-key`)

3. **Create Inventory**
   - Name: `GCP VMs`
   - (Leave empty - populated dynamically)

4. **Create Job Template**
   - Name: `GCP VM Patching`
   - Inventory: `GCP VMs`
   - Project: `GCP VM Patching`
   - Playbook: `ansible/gcp_vm_patching.yml`
   - Credentials: `GCP Ubuntu SSH Key`
   - Variables: ✓ Prompt on launch

5. **Generate API Token**
   - User → Tokens → Add
   - Scope: `Write`
   - Copy token and store in Vault

**Detailed AAP setup**: See [COMPLETE_DEMO_GUIDE.md](COMPLETE_DEMO_GUIDE.md) for step-by-step AAP configuration

### 4. HCP Terraform Workspace

Configure these variables in your HCP Terraform workspace:

**Terraform Variables:**
- `vault_addr` - Your Vault cluster URL
- `aap_api_url` - AAP API endpoint (e.g., `https://your-aap.com/api/controller/v2`)
- `aap_job_template_id` - Job template ID from AAP
- `gcp_project_id` - Your GCP project ID

**Environment Variables:**
- `VAULT_TOKEN` - Vault authentication token (mark as sensitive)
- `VAULT_NAMESPACE` - Vault namespace, typically `admin` (mark as sensitive)

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
open https://app.terraform.io/app/<your-org>/<workspace>
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
├── COMPLETE_DEMO_GUIDE.md     # Conference demo guide
├── README.md                   # This file
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

**Detailed troubleshooting**: See [COMPLETE_DEMO_GUIDE.md](COMPLETE_DEMO_GUIDE.md#troubleshooting)

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

- **Documentation**: [COMPLETE_DEMO_GUIDE.md](COMPLETE_DEMO_GUIDE.md)
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
