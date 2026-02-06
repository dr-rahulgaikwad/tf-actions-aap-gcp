# Terraform Actions GCP Patching Prototype

A demonstration of HashiCorp's Terraform Actions feature for Day 2 operations management, integrating HCP Terraform with Ansible Automation Platform (AAP) to automate OS patching on GCP Ubuntu VMs.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Setup Guides](#setup-guides)
- [Demo Workflow](#demo-workflow)
- [Security](#security)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Requirements Satisfied](#requirements-satisfied)
- [Additional Resources](#additional-resources)

## Overview

This prototype showcases modern infrastructure lifecycle management patterns by demonstrating a complete Day 0 through Day 2 workflow:

- **Day 0/1 (Provisioning)**: Provision Ubuntu VMs on GCP using HCP Terraform with infrastructure as code
- **Day 2 (Operations)**: Trigger Ansible playbooks via Terraform Actions for automated OS patching

### Key Features

- **Infrastructure as Code**: All infrastructure defined in Terraform with version control
- **Secure Credential Management**: All secrets stored in HashiCorp Vault Enterprise
- **Automated Day 2 Operations**: Patching triggered directly from Terraform workflows
- **Integration**: Seamless integration between HCP Terraform, GCP, AAP, and Vault
- **Scalable**: Designed to scale from 2 VMs to hundreds of instances
- **Demo-Ready**: Simple enough to demonstrate in 15 minutes

### Use Cases

- Automated security patching for VM fleets
- Day 2 operations management from infrastructure code
- Integration of configuration management with infrastructure provisioning
- Demonstration of Terraform Actions capabilities
- Enterprise secrets management patterns

## Architecture

### High-Level Architecture


```
┌─────────────────────────────────────────────────────────────┐
│                    HCP Terraform                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Terraform    │  │  Terraform   │  │    Vault     │      │
│  │    Code      │  │   Actions    │  │ Integration  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │ Provisions       │ Triggers         │ Retrieves
          │ Infrastructure   │ Playbooks        │ Credentials
          ▼                  ▼                  ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Google Cloud  │  │     Ansible     │  │   HashiCorp     │
│    Platform     │  │   Automation    │  │     Vault       │
│                 │  │    Platform     │  │   Enterprise    │
│  • Ubuntu VMs   │  │  • Job Template │  │  • GCP Creds    │
│  • Networking   │  │  • Playbooks    │  │  • AAP Token    │
│  • OS Config    │  │  • Inventory    │  │  • SSH Keys     │
└─────────────────┘  └────────┬────────┘  └─────────────────┘
          ▲                   │
          │                   │ SSH + Ansible
          │                   │ Patching
          └───────────────────┘
```

### Component Interaction Flow

**Day 0/1 - Provisioning Flow:**
1. Engineer commits Terraform code to version control
2. HCP Terraform workspace detects changes and runs plan
3. Terraform retrieves GCP credentials from Vault
4. Terraform provisions Ubuntu VMs on GCP
5. Terraform configures OS Config patch deployment
6. VM details (IPs, instance IDs) stored in Terraform state

**Day 2 - Patching Flow:**
1. Engineer triggers Terraform Action from HCP UI or API
2. Terraform Action retrieves AAP credentials from Vault
3. Action invokes AAP job template via REST API
4. Action passes VM inventory data (IPs, instance IDs) to AAP
5. AAP executes Ansible playbook against target VMs
6. Playbook performs apt update and security patching
7. AAP reports execution status back to HCP Terraform
8. Results visible in HCP Terraform UI and AAP dashboard


## Prerequisites

### Required Accounts and Services

1. **HCP Terraform Account**
   - Active HCP Terraform account
   - Workspace created and configured
   - Terraform version 1.7.0 or higher

2. **Google Cloud Platform**
   - GCP project with billing enabled
   - Compute Engine API enabled
   - OS Config API enabled
   - Service account with appropriate IAM permissions

3. **Ansible Automation Platform**
   - AAP instance (version 2.4+) - Options:
     - Red Hat Ansible Automation Platform (production)
     - AWX (open source, development/testing)
     - Red Hat Demo System
     - Cloud Marketplace deployment
   - Admin access to AAP
   - Network connectivity from AAP to GCP VMs

4. **HashiCorp Vault Enterprise**
   - Vault server accessible from HCP Terraform and AAP
   - Vault token with appropriate policies
   - KV secrets engine enabled

### Required Tools

- **Terraform CLI**: >= 1.7.0 (for local development)
- **gcloud CLI**: Latest version (for GCP setup)
- **Ansible**: >= 2.14 (for playbook development)
- **vault CLI**: Latest version (for credential management)
- **Python**: >= 3.9 (for testing)
- **pytest**: >= 7.0 (for property-based tests)
- **hypothesis**: >= 6.0 (for property-based testing)

### Network Requirements

Ensure network connectivity between components:

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| HCP Terraform | GCP API | 443 | HTTPS | Infrastructure provisioning |
| HCP Terraform | Vault | 8200 | HTTPS | Credential retrieval |
| HCP Terraform | AAP API | 443 | HTTPS | Trigger actions |
| AAP | GCP VMs | 22 | SSH | Ansible playbook execution |
| AAP | Vault | 8200 | HTTPS | Credential retrieval |


## Project Structure

```
terraform-actions-gcp-patching/
├── terraform/                      # Terraform configuration files
│   ├── main.tf                    # Main infrastructure resources (VMs, networking)
│   ├── actions.tf                 # Terraform Actions configuration
│   ├── variables.tf               # Input variable definitions
│   ├── outputs.tf                 # Output definitions (IPs, instance IDs)
│   ├── versions.tf                # Provider and version requirements
│   ├── backend-local.tf.example   # Example local backend configuration
│   └── terraform.tfvars.example   # Example variables file
├── ansible/                       # Ansible playbooks and inventory
│   ├── gcp_vm_patching.yml       # Main patching playbook
│   └── inventory_template.yml     # Inventory template
├── docs/                          # Detailed setup guides
│   ├── GCP_SETUP.md              # GCP project configuration guide
│   ├── AAP_SETUP.md              # AAP configuration guide
│   └── DEMO_WORKFLOW.md          # Complete demonstration workflow
├── tests/                         # Unit and property-based tests
│   ├── validate_terraform.sh      # Terraform validation script
│   ├── validate_ansible.sh        # Ansible validation script
│   ├── test_*.py                  # Property-based tests
│   └── README.md                  # Testing documentation
├── .kiro/                         # Specification documents
│   └── specs/terraform-actions-gcp-patching/
│       ├── requirements.md        # Requirements specification
│       ├── design.md              # Design document
│       └── tasks.md               # Task list
└── README.md                      # This file
```

### Key Files

- **terraform/main.tf**: Defines GCP VMs, networking, and OS Config patch deployment
- **terraform/actions.tf**: Configures Terraform Actions for triggering AAP jobs
- **ansible/gcp_vm_patching.yml**: Ansible playbook for OS patching operations
- **docs/GCP_SETUP.md**: Step-by-step GCP project setup instructions
- **docs/AAP_SETUP.md**: Comprehensive AAP configuration guide
- **docs/DEMO_WORKFLOW.md**: Complete demonstration workflow with troubleshooting


## Quick Start

### Step 1: Set Up GCP Project

1. Create or select a GCP project
2. Enable required APIs:
   ```bash
   export PROJECT_ID="your-gcp-project-id"
   gcloud services enable compute.googleapis.com --project=${PROJECT_ID}
   gcloud services enable osconfig.googleapis.com --project=${PROJECT_ID}
   ```

3. Create service account with minimal permissions:
   ```bash
   export SA_NAME="terraform-automation"
   gcloud iam service-accounts create ${SA_NAME} --project=${PROJECT_ID}
   
   # Grant required roles
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/compute.instanceAdmin.v1"
   ```

4. Generate and store service account key in Vault

**For detailed instructions, see [docs/GCP_SETUP.md](docs/GCP_SETUP.md)**

### Step 2: Configure Ansible Automation Platform

1. Access your AAP instance
2. Create credentials (Vault integration for SSH keys)
3. Create inventory (dynamic, provided by Terraform Actions)
4. Create project (link to playbook repository)
5. Create job template for patching
6. Generate API token for Terraform Actions

**For detailed instructions, see [docs/AAP_SETUP.md](docs/AAP_SETUP.md)**

### Step 3: Store Credentials in Vault

Store all required credentials in HashiCorp Vault:

```bash
export VAULT_ADDR="https://vault.example.com:8200"
vault login

# Store GCP service account key
vault kv put secret/gcp/service-account \
  key=@/path/to/service-account-key.json \
  project_id=${PROJECT_ID}

# Store AAP API token
vault kv put secret/aap/api-token \
  token="<your-aap-token>" \
  url="https://aap.example.com"

# Store SSH private key
vault kv put secret/ssh/ubuntu-key \
  private_key=@/path/to/private-key \
  public_key=@/path/to/public-key.pub
```


### Step 4: Configure Terraform Variables

1. Copy the example variables file:
   ```bash
   cd terraform/
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   # GCP Configuration
   gcp_project_id = "your-gcp-project-id"
   gcp_region     = "us-central1"
   gcp_zone       = "us-central1-a"
   
   # VM Configuration
   vm_count        = 2
   vm_machine_type = "e2-medium"
   
   # Vault Configuration
   vault_addr            = "https://vault.example.com:8200"
   vault_gcp_secret_path = "secret/gcp/service-account"
   vault_aap_token_path  = "secret/aap/api-token"
   vault_ssh_key_path    = "secret/ssh/ubuntu-key"
   
   # AAP Configuration
   aap_api_url         = "https://aap.example.com"
   aap_job_template_id = 42  # Your job template ID
   
   # Resource Tagging
   environment = "demo"
   managed_by  = "terraform"
   ```

### Step 5: Deploy Infrastructure

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the execution plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Note the outputs (VM IPs, instance IDs):
   ```bash
   terraform output
   ```


### Step 6: Trigger Day 2 Operations

**Option A: Via HCP Terraform UI**
1. Navigate to your workspace in HCP Terraform
2. Go to **Actions** tab
3. Find "Patch Ubuntu VMs" action
4. Click **Run Action**
5. Monitor execution in AAP UI

**Option B: Via API**
```bash
# Get action configuration
AAP_URL=$(terraform output -raw action_patch_vms_url)
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Trigger action
terraform output -raw action_patch_vms_payload > /tmp/payload.json
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/payload.json \
  ${AAP_URL}
```

### Step 7: Verify Results

1. Check AAP job status:
   - Navigate to AAP UI → Views → Jobs
   - View real-time playbook output

2. Verify VMs were patched:
   ```bash
   VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')
   ssh ubuntu@${VM_IP} "sudo apt list --upgradable"
   ```


## Setup Guides

Detailed step-by-step setup guides are available in the `docs/` directory:

### [GCP Setup Guide](docs/GCP_SETUP.md)
Complete guide for configuring your GCP project:
- Creating or selecting a GCP project
- Enabling required APIs (Compute Engine, OS Config)
- Creating service accounts with minimal IAM permissions
- Generating and storing service account keys in Vault
- Configuring networking and firewall rules
- Troubleshooting common GCP issues

**Time to Complete**: 15-20 minutes  
**Requirements Satisfied**: 7.1, 7.2, 7.3, 7.4, 9.2

### [AAP Setup Guide](docs/AAP_SETUP.md)
Comprehensive guide for configuring Ansible Automation Platform:
- AAP installation options (Red Hat AAP, AWX, Demo System, Cloud Marketplace)
- Creating credentials with Vault integration
- Configuring inventories and projects
- Creating job templates for patching
- Generating API tokens for Terraform Actions
- Testing job templates and API integration
- Troubleshooting AAP issues

**Time to Complete**: 30-45 minutes  
**Requirements Satisfied**: 5.1, 5.2, 5.3, 5.4, 5.5, 9.1

### [Demo Workflow Guide](docs/DEMO_WORKFLOW.md)
Complete demonstration workflow for showcasing the prototype:
- Pre-demo checklist and preparation
- Day 0/1 provisioning demonstration
- Day 2 operations demonstration
- Verification and validation steps
- Troubleshooting guide for common demo issues
- Advanced scenarios (scheduled patching, multi-environment)

**Time to Complete**: 15 minutes (demo)  
**Requirements Satisfied**: 9.5, 9.6, 10.1, 10.2, 10.3, 10.4


## Demo Workflow

This prototype is designed for a **15-minute demonstration** showcasing Terraform Actions for Day 2 operations.

### Demo Overview

**Part 1: Day 0/1 - Infrastructure Provisioning (5 minutes)**
1. Show Terraform configuration files
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to provision VMs
4. Display outputs (VM IPs, instance IDs)
5. Verify VMs in GCP Console

**Part 2: Day 2 - Automated Patching (7 minutes)**
1. Show Terraform Actions configuration
2. Trigger action from HCP Terraform UI
3. Monitor job execution in AAP UI
4. View real-time Ansible playbook output
5. Verify patching results on VMs

**Part 3: Verification (3 minutes)**
1. Review infrastructure state in HCP Terraform
2. Check AAP job history
3. Verify Vault credential access logs
4. Show GCP resources and compliance

### Key Demo Messages

- **Infrastructure as Code**: All infrastructure defined in Terraform
- **Secure Credentials**: All secrets managed through Vault
- **Automated Operations**: Day 2 operations triggered from infrastructure code
- **Scalability**: Approach scales from 2 VMs to hundreds
- **Integration**: Seamless workflow across multiple platforms

**For complete demo workflow, see [docs/DEMO_WORKFLOW.md](docs/DEMO_WORKFLOW.md)**


## Security

This prototype implements enterprise security best practices:

### Credential Management

- **All credentials stored in HashiCorp Vault**: GCP service account keys, AAP API tokens, SSH keys
- **No plaintext credentials**: Never stored in Terraform code, variables, or version control
- **Dynamic credential retrieval**: Credentials retrieved at runtime from Vault
- **Audit logging**: All credential access tracked in Vault audit logs

### IAM and Permissions

- **Least privilege principle**: Service accounts granted minimum required permissions
- **Role-based access**: Specific IAM roles for each function:
  - `roles/compute.instanceAdmin.v1` - VM management
  - `roles/compute.networkAdmin` - Network management
  - `roles/osconfig.patchDeploymentAdmin` - Patch management
  - `roles/iam.serviceAccountUser` - Service account usage

### Network Security

- **Minimal firewall rules**: Only SSH access (port 22) to demo VMs
- **Default VPC**: Uses GCP default network for simplicity
- **Tagged resources**: VMs tagged for firewall rule targeting
- **Private communication**: AAP connects to VMs via internal IPs where possible

### Secrets Rotation

- **Service account keys**: Rotate every 90 days (recommended)
- **AAP API tokens**: Set expiration dates and rotate regularly
- **SSH keys**: Rotate as part of security policy
- **Vault tokens**: Use short-lived tokens with appropriate TTL

### Security Validation

The project includes property-based tests for security:
- **Property 14**: Vault credential retrieval (no hardcoded credentials)
- **Property 15**: No plaintext credentials in code
- **Property 16**: Least privilege IAM permissions

Run security tests:
```bash
cd tests/
pytest test_vault_credential_retrieval.py
pytest test_iam_least_privilege.py
pytest test_firewall_minimal_rules.py
```


## Testing

The project includes comprehensive testing with both unit tests and property-based tests.

### Testing Approach

- **Unit Tests**: Validate specific examples and edge cases
- **Property-Based Tests**: Verify universal properties across randomized inputs
- **Integration Tests**: Test end-to-end workflows with real infrastructure

### Running Tests

**Terraform Validation:**
```bash
./tests/validate_terraform.sh
```

**Ansible Validation:**
```bash
./tests/validate_ansible.sh
```

**Property-Based Tests:**
```bash
cd tests/
pytest -v
```

**Specific Test Suites:**
```bash
# Security tests
pytest test_vault_credential_retrieval.py
pytest test_iam_least_privilege.py
pytest test_firewall_minimal_rules.py

# Infrastructure tests
pytest test_vm_provisioning.py
pytest test_output_completeness.py
```

### Property-Based Tests

The project uses **Hypothesis** (Python) for property-based testing with a minimum of **100 iterations** per test.

**Key Properties Tested:**
- **Property 1**: VM Provisioning Completeness
- **Property 3**: Output Data Completeness
- **Property 4**: Resource Labeling Consistency
- **Property 14**: Vault Credential Retrieval
- **Property 15**: No Plaintext Credentials
- **Property 16**: Least Privilege IAM

Each property test includes a comment referencing the design property:
```python
# Feature: terraform-actions-gcp-patching, Property 15: No Plaintext Credentials
```

**For detailed testing documentation, see [tests/README.md](tests/README.md)**


## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Terraform Apply Fails - API Not Enabled

**Error:**
```
Error: Error creating instance: googleapi: Error 403: Compute Engine API has not been used
```

**Solution:**
```bash
gcloud services enable compute.googleapis.com --project=${PROJECT_ID}
gcloud services enable osconfig.googleapis.com --project=${PROJECT_ID}
terraform apply
```

#### Issue 2: Vault Connection Failed

**Error:**
```
Error: Error making API request to Vault
```

**Solution:**
```bash
# Verify Vault address
echo $VAULT_ADDR

# Test connectivity
vault status

# Re-authenticate
vault login

# Verify secrets exist
vault kv get secret/gcp/service-account
```

#### Issue 3: SSH Connection to VMs Fails

**Error:**
```
ssh: connect to host 34.123.45.67 port 22: Connection refused
```

**Solution:**
```bash
# Check VM status
gcloud compute instances list --project=${PROJECT_ID}

# Verify firewall rule
gcloud compute firewall-rules list --project=${PROJECT_ID}

# Wait 1-2 minutes for VM to fully boot, then retry
```


#### Issue 4: AAP Job Fails - Inventory Empty

**Error:**
```
ERROR! Inventory is empty
```

**Solution:**
```bash
# Verify action payload includes inventory
terraform output action_patch_vms_payload | jq '.extra_vars.vm_inventory'

# Verify job template accepts extra_vars
# In AAP UI: Resources → Templates → GCP VM Patching → Edit
# Ensure "Prompt on launch" is enabled for "Variables"
```

#### Issue 5: AAP Job Fails - SSH Authentication

**Error:**
```
FAILED! => {"msg": "Failed to connect to the host via ssh: Permission denied (publickey)"}
```

**Solution:**
```bash
# Verify SSH key in Vault matches VM metadata
vault kv get secret/ssh/ubuntu-key

# Test SSH manually
VM_IP=$(terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/test-key ubuntu@${VM_IP}

# Verify AAP credential references correct Vault path
```

#### Issue 6: Playbook Fails - apt Lock

**Error:**
```
FAILED! => {"msg": "Could not get lock /var/lib/apt/lists/lock"}
```

**Solution:**
```bash
# Another process is using apt (common on fresh VMs)
# Wait 2-3 minutes for automatic updates to complete
# The playbook includes retry logic, so retry the job
```

### Additional Troubleshooting

For comprehensive troubleshooting guides, see:
- **[docs/GCP_SETUP.md](docs/GCP_SETUP.md)** - GCP-specific issues
- **[docs/AAP_SETUP.md](docs/AAP_SETUP.md)** - AAP-specific issues
- **[docs/DEMO_WORKFLOW.md](docs/DEMO_WORKFLOW.md)** - Demo-specific issues


## Requirements Satisfied

This prototype satisfies the following requirements from the specification:

### Infrastructure Requirements
- **Requirement 1**: GCP VM Provisioning - Ubuntu VMs provisioned with Terraform ✓
- **Requirement 2**: OS Patch Management Configuration - GCP OS Config configured ✓
- **Requirement 3**: Terraform Actions Integration - Actions trigger AAP workflows ✓
- **Requirement 4**: Ansible Playbook Implementation - Patching playbook implemented ✓
- **Requirement 5**: AAP Configuration - Job templates and credentials configured ✓
- **Requirement 6**: HCP Terraform Workspace Setup - Workspace configured with Vault ✓
- **Requirement 7**: GCP Project Configuration - APIs enabled, IAM configured ✓

### Security Requirements
- **Requirement 8**: Authentication and Security - All credentials in Vault ✓
  - 8.1: Credentials retrieved from Vault
  - 8.2: No plaintext credentials in code
  - 8.3: Service account keys from Vault
  - 8.4: API token authentication
  - 8.5: Least privilege IAM permissions

### Documentation Requirements
- **Requirement 9**: Documentation and Setup ✓
  - 9.1: AAP setup instructions (docs/AAP_SETUP.md)
  - 9.2: GCP project setup steps (docs/GCP_SETUP.md)
  - 9.3: HCP Terraform workspace configuration
  - 9.4: Prerequisites and dependencies (this README)
  - 9.5: Troubleshooting guidance (this README + docs/)
  - 9.6: Demonstration workflow steps (docs/DEMO_WORKFLOW.md)

### Demo Requirements
- **Requirement 10**: Demo Readiness ✓
  - 10.1: Complete Day 0 through Day 2 workflow
  - 10.2: VM provisioning in under 5 minutes
  - 10.3: AAP job execution triggered from Terraform
  - 10.4: Simple enough to explain in 15-minute demo


## Additional Resources

### Documentation

- **[GCP Setup Guide](docs/GCP_SETUP.md)** - Detailed GCP project configuration
- **[AAP Setup Guide](docs/AAP_SETUP.md)** - Comprehensive AAP configuration
- **[Demo Workflow Guide](docs/DEMO_WORKFLOW.md)** - Complete demonstration workflow
- **[Testing Documentation](tests/README.md)** - Testing strategy and CI/CD integration

### Specification Documents

- **[Requirements](. kiro/specs/terraform-actions-gcp-patching/requirements.md)** - Complete requirements specification
- **[Design](. kiro/specs/terraform-actions-gcp-patching/design.md)** - Detailed design document with architecture
- **[Tasks](. kiro/specs/terraform-actions-gcp-patching/tasks.md)** - Implementation task list

### External Resources

- **[Terraform Actions Documentation](https://www.terraform.io/docs/cloud/actions)** - Official Terraform Actions docs
- **[HCP Terraform Documentation](https://www.terraform.io/cloud-docs)** - HCP Terraform platform docs
- **[GCP Compute Engine Documentation](https://cloud.google.com/compute/docs)** - GCP VM documentation
- **[GCP OS Config Documentation](https://cloud.google.com/compute/docs/os-config-management)** - OS patching docs
- **[Ansible Automation Platform Documentation](https://docs.ansible.com/automation-controller/)** - AAP docs
- **[HashiCorp Vault Documentation](https://www.vaultproject.io/docs)** - Vault secrets management
- **[Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)** - Playbook guidelines
- **[GCP IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)** - Security best practices

### Support and Contribution

This is a prototype for demonstration purposes. For questions or issues:

1. Review the troubleshooting sections in this README and setup guides
2. Check the specification documents for design decisions
3. Review the property-based tests for expected behavior
4. Consult the external resources for platform-specific documentation


## Project Metadata

**Project Type**: Prototype / Demonstration  
**Target Audience**: Solutions architects, platform engineers, DevOps teams  
**Complexity**: Intermediate  
**Estimated Setup Time**: 1-2 hours (first time), 15 minutes (demo)  
**Maintenance**: Minimal (rotate credentials every 90 days)

### Technology Stack

- **Infrastructure**: Terraform 1.7+, HCP Terraform
- **Cloud Platform**: Google Cloud Platform
- **Configuration Management**: Ansible 2.14+, Ansible Automation Platform 2.4+
- **Secrets Management**: HashiCorp Vault Enterprise
- **Testing**: Python 3.9+, pytest, Hypothesis
- **Operating System**: Ubuntu 22.04 LTS

### Version History

- **v1.0** (2024-01-15): Initial release
  - Day 0/1 provisioning with Terraform
  - Day 2 operations with Terraform Actions
  - Vault integration for credential management
  - Comprehensive documentation and testing

### License

This is a prototype for demonstration purposes. Use at your own discretion.

### Acknowledgments

This prototype demonstrates integration between:
- HashiCorp Terraform and HCP Terraform
- HashiCorp Vault Enterprise
- Red Hat Ansible Automation Platform
- Google Cloud Platform

---

**Ready to get started?** Follow the [Quick Start](#quick-start) guide above, or dive into the detailed [Setup Guides](#setup-guides).

**Questions?** Check the [Troubleshooting](#troubleshooting) section or review the [Additional Resources](#additional-resources).

**Want to see it in action?** Follow the [Demo Workflow Guide](docs/DEMO_WORKFLOW.md) for a complete 15-minute demonstration.
