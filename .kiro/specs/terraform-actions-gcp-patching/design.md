# Design Document: Terraform Actions GCP Patching Prototype

## Overview

This design describes a prototype system demonstrating HashiCorp's Terraform Actions feature for Day 2 operations management. The system integrates three key platforms:

1. **HCP Terraform** - Infrastructure orchestration and state management
2. **Google Cloud Platform** - VM hosting and OS patch management
3. **Ansible Automation Platform** - Configuration management and patching automation

The prototype showcases a complete infrastructure lifecycle:
- **Day 0/1**: Provision Ubuntu VMs on GCP using Terraform
- **Day 2**: Trigger Ansible playbooks via Terraform Actions for OS patching

This design emphasizes simplicity and demo-readiness while following enterprise best practices for credential management, infrastructure as code, and automation.

## Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "HCP Terraform"
        TF[Terraform Code]
        WS[Workspace]
        ACT[Terraform Actions]
    end
    
    subgraph "HashiCorp Vault"
        V[Vault Enterprise]
    end
    
    subgraph "Google Cloud Platform"
        VM1[Ubuntu VM 1]
        VM2[Ubuntu VM 2]
        OSC[OS Config Service]
    end
    
    subgraph "Ansible Automation Platform"
        JT[Job Template]
        PB[Patching Playbook]
        INV[Dynamic Inventory]
    end
    
    TF -->|Provisions| VM1
    TF -->|Provisions| VM2
    TF -->|Configures| OSC
    WS -->|Retrieves Credentials| V
    ACT -->|Triggers| JT
    ACT -->|Passes Inventory| INV
    JT -->|Executes| PB
    PB -->|Patches| VM1
    PB -->|Patches| VM2
    V -->|Provides GCP Creds| AAP
```

### Component Interaction Flow

**Day 0/1 - Provisioning Flow:**
1. Engineer commits Terraform code to version control
2. HCP Terraform workspace detects changes
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
8. Results visible in HCP Terraform UI

### Security Architecture

All credentials flow through Vault Enterprise:
- **GCP Service Account Keys**: Used by Terraform and Ansible
- **AAP API Tokens**: Used by Terraform Actions
- **SSH Keys**: Used by Ansible for VM access

No credentials stored in:
- Terraform code
- HCP Terraform variables (except Vault references)
- Ansible playbooks
- Version control

## Components and Interfaces

### 1. Terraform Infrastructure Code

**Purpose**: Define and provision GCP infrastructure

**Key Resources**:
- `google_compute_instance`: Ubuntu VM instances
- `google_compute_network`: VPC network (or use default)
- `google_compute_firewall`: SSH access rules
- `google_os_config_patch_deployment`: Patch management configuration

**Outputs**:
- `vm_instance_ids`: List of GCP instance IDs
- `vm_internal_ips`: List of internal IP addresses
- `vm_external_ips`: List of external IP addresses (if applicable)
- `patch_deployment_id`: OS Config patch deployment identifier

**Variables**:
- `gcp_project_id`: GCP project identifier
- `gcp_region`: Deployment region (e.g., us-central1)
- `gcp_zone`: Deployment zone (e.g., us-central1-a)
- `vm_count`: Number of VMs to provision (default: 2)
- `vm_machine_type`: GCP machine type (default: e2-medium)
- `ubuntu_image`: Ubuntu OS image (default: ubuntu-2204-lts)

### 2. Terraform Actions Configuration

**Purpose**: Define Day 2 operations that trigger AAP workflows

**Configuration Structure**:
```hcl
action "patch_vms" {
  name        = "Patch Ubuntu VMs"
  description = "Trigger Ansible playbook to patch VMs"
  
  integration {
    type = "http"
    url  = var.aap_api_url
    
    authentication {
      type  = "bearer"
      token = vault_generic_secret.aap_token.data["token"]
    }
  }
  
  payload = {
    job_template_id = var.aap_job_template_id
    inventory       = jsonencode({
      hosts = [for vm in google_compute_instance.ubuntu_vms : {
        name       = vm.name
        ip_address = vm.network_interface[0].network_ip
        instance_id = vm.instance_id
      }]
    })
  }
}
```

**Interface with AAP**:
- **Method**: HTTP POST
- **Endpoint**: `/api/v2/job_templates/{id}/launch/`
- **Authentication**: Bearer token from Vault
- **Payload**: JSON containing inventory and extra variables

### 3. Ansible Automation Platform Setup

**Purpose**: Execute patching playbooks on target VMs

**Components**:

**Job Template Configuration**:
- Name: "GCP VM Patching"
- Playbook: `gcp_vm_patching.yml`
- Inventory: Dynamic (provided by Terraform Actions)
- Credentials: GCP service account (from Vault), SSH key (from Vault)
- Extra Variables: Accepted from API calls

**Inventory Structure**:
```yaml
all:
  hosts:
    vm-1:
      ansible_host: 10.0.1.10
      instance_id: "1234567890"
    vm-2:
      ansible_host: 10.0.1.11
      instance_id: "1234567891"
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: "{{ vault_ssh_key }}"
```

**API Interface**:
- **Authentication**: Token-based (stored in Vault)
- **Job Launch Endpoint**: `/api/v2/job_templates/{id}/launch/`
- **Job Status Endpoint**: `/api/v2/jobs/{id}/`
- **Response Format**: JSON with job ID and status

### 4. Ansible Patching Playbook

**Purpose**: Perform OS patching operations on Ubuntu VMs

**Playbook Structure**:
```yaml
---
- name: Patch Ubuntu VMs
  hosts: all
  become: yes
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
      
    - name: Upgrade all security packages
      apt:
        upgrade: safe
        autoremove: yes
        autoclean: yes
      
    - name: Check if reboot required
      stat:
        path: /var/run/reboot-required
      register: reboot_required
      
    - name: Reboot if required
      reboot:
        msg: "Reboot initiated by Ansible patching"
        reboot_timeout: 300
      when: reboot_required.stat.exists
      
    - name: Report patching status
      debug:
        msg: "Patching completed successfully on {{ inventory_hostname }}"
```

**Key Operations**:
1. Update package cache
2. Install security updates
3. Clean up unnecessary packages
4. Check for reboot requirement
5. Conditionally reboot system
6. Report completion status

### 5. HCP Terraform Workspace

**Purpose**: Manage infrastructure state and execute Terraform operations

**Configuration**:
- **Execution Mode**: Remote
- **Terraform Version**: Latest stable (1.7+)
- **Working Directory**: Root of repository
- **VCS Integration**: GitHub/GitLab (optional for demo)

**Variables**:
- `gcp_project_id`: GCP project ID (Terraform variable)
- `gcp_credentials`: Path to Vault secret (Environment variable)
- `aap_api_url`: AAP API endpoint (Terraform variable)
- `aap_token_path`: Path to Vault secret (Environment variable)
- `vault_addr`: Vault server address (Environment variable)
- `vault_token`: Vault authentication token (Environment variable, sensitive)

**State Backend**:
- Managed automatically by HCP Terraform
- No additional backend configuration required

### 6. Vault Enterprise Integration

**Purpose**: Centralized secrets management for all components

**Secret Paths**:
- `secret/gcp/service-account`: GCP service account JSON key
- `secret/aap/api-token`: AAP API authentication token
- `secret/ssh/ubuntu-key`: SSH private key for VM access

**Access Patterns**:

**Terraform Access**:
```hcl
data "vault_generic_secret" "gcp_creds" {
  path = "secret/gcp/service-account"
}

provider "google" {
  credentials = data.vault_generic_secret.gcp_creds.data["key"]
  project     = var.gcp_project_id
  region      = var.gcp_region
}
```

**AAP Access**:
- Configure Vault credential type in AAP
- Reference Vault paths in AAP credentials
- AAP retrieves secrets at job execution time

### 7. GCP OS Config Service

**Purpose**: Native GCP patch management capabilities

**Patch Deployment Configuration**:
```hcl
resource "google_os_config_patch_deployment" "ubuntu_patches" {
  patch_deployment_id = "ubuntu-security-patches"
  
  instance_filter {
    all = false
    
    group_labels {
      labels = {
        environment = "demo"
        os          = "ubuntu"
      }
    }
  }
  
  patch_config {
    apt {
      type = "DIST"
      excludes = []
    }
  }
  
  one_time_schedule {
    execute_time = "2024-01-01T00:00:00Z"  # Placeholder for on-demand
  }
}
```

**Integration Points**:
- Terraform provisions patch deployment configuration
- Ansible playbook performs actual patching (alternative to OS Config execution)
- OS Config provides visibility and compliance reporting

## Data Models

### VM Instance Data

```hcl
# Terraform representation
resource "google_compute_instance" "ubuntu_vm" {
  name         = string
  machine_type = string
  zone         = string
  
  boot_disk {
    initialize_params {
      image = string  # Ubuntu image
      size  = number  # GB
    }
  }
  
  network_interface {
    network    = string
    access_config {}  # Ephemeral external IP
  }
  
  metadata = {
    ssh-keys = string
    environment = string
  }
  
  labels = {
    environment = string
    managed_by  = string
    os          = string
  }
}
```

### Terraform Action Payload

```json
{
  "job_template_id": 42,
  "inventory": {
    "all": {
      "hosts": {
        "vm-1": {
          "ansible_host": "10.0.1.10",
          "instance_id": "1234567890"
        },
        "vm-2": {
          "ansible_host": "10.0.1.11",
          "instance_id": "1234567891"
        }
      },
      "vars": {
        "ansible_user": "ubuntu",
        "gcp_project": "my-project-id"
      }
    }
  },
  "extra_vars": {
    "patch_type": "security",
    "reboot_allowed": true
  }
}
```

### AAP Job Response

```json
{
  "id": 12345,
  "type": "job",
  "url": "/api/v2/jobs/12345/",
  "status": "pending",
  "job_template": 42,
  "inventory": 15,
  "created": "2024-01-15T10:30:00Z",
  "started": null,
  "finished": null,
  "elapsed": 0.0
}
```

### Vault Secret Structure

**GCP Service Account**:
```json
{
  "type": "service_account",
  "project_id": "my-gcp-project",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "terraform@my-project.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token"
}
```

**AAP API Token**:
```json
{
  "token": "Bearer abc123def456...",
  "expires": "2024-12-31T23:59:59Z"
}
```

**SSH Private Key**:
```json
{
  "private_key": "-----BEGIN OPENSSH PRIVATE KEY-----\n...",
  "public_key": "ssh-rsa AAAAB3NzaC1yc2EA..."
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Infrastructure Provisioning Properties

**Property 1: VM Provisioning Completeness**
*For any* valid Terraform configuration with VM specifications, applying the configuration should result in all specified VMs being created in GCP with matching names, machine types, and zones.
**Validates: Requirements 1.1**

**Property 2: Network Configuration Consistency**
*For any* provisioned VM, the VM should have exactly one network interface with a valid internal IP address and network configuration.
**Validates: Requirements 1.2**

**Property 3: Output Data Completeness**
*For any* successful Terraform apply operation, the outputs should contain lists of instance IDs, internal IPs, and external IPs with lengths matching the number of provisioned VMs.
**Validates: Requirements 1.3**

**Property 4: Resource Labeling Consistency**
*For any* provisioned VM, the VM should have all required labels (environment, managed_by, os) with non-empty values.
**Validates: Requirements 1.5**

### Patch Management Properties

**Property 5: Patch Deployment Resource Creation**
*For any* Terraform configuration including patch deployment, applying the configuration should create a google_os_config_patch_deployment resource with a valid ID.
**Validates: Requirements 2.1**

**Property 6: Patch Configuration Completeness**
*For any* created patch deployment, the configuration should specify patch categories and severity levels in the patch_config block.
**Validates: Requirements 2.4**

### Terraform Actions Properties

**Property 7: Action Payload Structure**
*For any* Terraform Action invocation, the payload should contain a valid job_template_id and an inventory object with all provisioned VM details (name, IP, instance_id).
**Validates: Requirements 3.3**

**Property 8: Action Execution Status**
*For any* triggered Terraform Action, the system should return a response containing a job ID and status field.
**Validates: Requirements 3.4**

### Ansible Playbook Properties

**Property 9: Playbook Update Execution**
*For any* Ubuntu VM with available package updates, executing the patching playbook should result in the package cache being updated and security packages being upgraded.
**Validates: Requirements 4.3**

**Property 10: Playbook Status Reporting**
*For any* playbook execution (successful or failed), the playbook should return an exit code (0 for success, non-zero for failure) and status message.
**Validates: Requirements 4.4**

**Property 11: Playbook Error Handling**
*For any* playbook execution that encounters an error, the error message should contain the task name and a description of the failure.
**Validates: Requirements 4.5**

**Property 12: Conditional Reboot Logic**
*For any* VM state, if the file /var/run/reboot-required exists after patching, the playbook should execute the reboot task; if the file does not exist, the reboot task should be skipped.
**Validates: Requirements 4.6**

### AAP Integration Properties

**Property 13: Job Template Inventory Acceptance**
*For any* AAP job template launch request with inventory in the payload, the API should accept the request and return a job ID.
**Validates: Requirements 5.3**

### Security Properties

**Property 14: Vault Credential Retrieval**
*For any* credential requirement in the Terraform code (GCP, AAP, SSH), the credential should be retrieved from a Vault data source, not from a hardcoded value.
**Validates: Requirements 8.1**

**Property 15: No Plaintext Credentials**
*For any* Terraform file in the codebase, scanning the file content should not reveal any plaintext credentials (API keys, passwords, private keys, tokens).
**Validates: Requirements 8.2**

**Property 16: Least Privilege IAM**
*For any* service account IAM binding, the granted roles should be limited to the minimum set required for the service account's function (compute.instanceAdmin, osconfig.patchDeploymentAdmin, etc.).
**Validates: Requirements 8.5**

### Configuration Validation Properties

**Property 17: Service Account Authentication**
*For any* GCP provider configuration, the credentials should reference a Vault data source containing a service account key.
**Validates: Requirements 6.2**

**Property 18: Minimal Firewall Rules**
*For any* firewall rule configuration, the number of custom firewall rules should be minimal (≤ 2) and should only allow SSH access.
**Validates: Requirements 7.5**

## Error Handling

### Terraform Errors

**VM Provisioning Failures**:
- **Cause**: Insufficient GCP quotas, invalid machine type, zone unavailable
- **Handling**: Terraform will fail with descriptive error message
- **Recovery**: User adjusts configuration or requests quota increase

**Credential Retrieval Failures**:
- **Cause**: Vault unavailable, invalid token, secret path not found
- **Handling**: Terraform fails during plan phase with Vault error
- **Recovery**: Verify Vault connectivity and secret paths

**State Lock Conflicts**:
- **Cause**: Multiple concurrent Terraform runs
- **Handling**: HCP Terraform prevents concurrent runs automatically
- **Recovery**: Wait for current run to complete

### Terraform Actions Errors

**AAP API Failures**:
- **Cause**: AAP unavailable, invalid credentials, job template not found
- **Handling**: Action returns error status with HTTP error code
- **Recovery**: Verify AAP connectivity and job template configuration

**Payload Validation Failures**:
- **Cause**: Invalid inventory format, missing required fields
- **Handling**: AAP API returns 400 Bad Request with validation errors
- **Recovery**: Fix action payload structure in Terraform code

**Timeout Errors**:
- **Cause**: AAP job takes longer than action timeout
- **Handling**: Action returns timeout error, job may still be running in AAP
- **Recovery**: Check AAP UI for job status, increase timeout if needed

### Ansible Playbook Errors

**Connection Failures**:
- **Cause**: VM not reachable, SSH key invalid, firewall blocking
- **Handling**: Playbook fails with connection error for affected hosts
- **Recovery**: Verify network connectivity, SSH keys, and firewall rules

**Package Manager Errors**:
- **Cause**: apt lock held by another process, repository unavailable
- **Handling**: Task fails with apt error message
- **Recovery**: Retry playbook after ensuring apt is available

**Reboot Failures**:
- **Cause**: System unable to reboot, timeout exceeded
- **Handling**: Reboot task fails with timeout error
- **Recovery**: Manually verify VM status in GCP console

**Partial Failures**:
- **Cause**: Some VMs succeed, others fail
- **Handling**: Playbook continues, reports per-host status
- **Recovery**: Review failed hosts, address specific issues, re-run

### GCP API Errors

**API Not Enabled**:
- **Cause**: Required GCP APIs not enabled in project
- **Handling**: Terraform fails with API enablement error
- **Recovery**: Enable Compute Engine and OS Config APIs

**Permission Denied**:
- **Cause**: Service account lacks required IAM permissions
- **Handling**: Terraform fails with permission error
- **Recovery**: Grant necessary IAM roles to service account

**Resource Quota Exceeded**:
- **Cause**: Project quota limits reached
- **Handling**: Terraform fails with quota error
- **Recovery**: Request quota increase or reduce resource count

## Testing Strategy

### Dual Testing Approach

This prototype requires both **unit tests** and **property-based tests** for comprehensive validation:

- **Unit Tests**: Validate specific examples, edge cases, and integration points
- **Property Tests**: Verify universal properties across randomized inputs

Together, these approaches ensure both concrete correctness (unit tests) and general correctness (property tests).

### Unit Testing

**Terraform Code Testing**:
- Use `terraform validate` to check syntax and configuration
- Use `terraform plan` to verify resource definitions
- Test specific VM configurations (single VM, multiple VMs)
- Test edge cases: minimal configuration, maximum configuration
- Verify output structure with known inputs

**Ansible Playbook Testing**:
- Use `ansible-playbook --syntax-check` for syntax validation
- Use `ansible-lint` for best practices validation
- Test playbook with mock inventory
- Test specific scenarios:
  - VM with updates available
  - VM with no updates
  - VM requiring reboot
  - VM not requiring reboot
  - Connection failures
  - Package manager errors

**Integration Testing**:
- Test Terraform → GCP provisioning flow
- Test Terraform Actions → AAP API flow
- Test AAP → Ansible → VM patching flow
- Test end-to-end workflow with real infrastructure

### Property-Based Testing

**Testing Library**: Use **Hypothesis** (Python) for property-based testing of validation scripts and integration tests.

**Configuration**: Each property test should run a minimum of **100 iterations** to ensure comprehensive input coverage.

**Test Tagging**: Each property test must include a comment referencing the design property:
```python
# Feature: terraform-actions-gcp-patching, Property 1: VM Provisioning Completeness
```

**Property Test Implementation**:

**Property 1: VM Provisioning Completeness**
- Generate random VM configurations (count, machine type, zone)
- Apply Terraform with generated config
- Verify all VMs exist in GCP with correct properties
- **Feature: terraform-actions-gcp-patching, Property 1: VM Provisioning Completeness**

**Property 3: Output Data Completeness**
- Generate random number of VMs (1-10)
- Apply Terraform
- Verify output lists have correct length
- Verify all IDs and IPs are non-empty
- **Feature: terraform-actions-gcp-patching, Property 3: Output Data Completeness**

**Property 4: Resource Labeling Consistency**
- Generate random VM configurations
- Apply Terraform
- Verify all VMs have required labels
- Verify label values are non-empty
- **Feature: terraform-actions-gcp-patching, Property 4: Resource Labeling Consistency**

**Property 7: Action Payload Structure**
- Generate random VM inventory data
- Construct action payload
- Verify payload contains job_template_id
- Verify inventory contains all VM details
- **Feature: terraform-actions-gcp-patching, Property 7: Action Payload Structure**

**Property 10: Playbook Status Reporting**
- Generate random playbook execution scenarios (success/failure)
- Execute playbook
- Verify exit code matches expected result
- Verify status message is non-empty
- **Feature: terraform-actions-gcp-patching, Property 10: Playbook Status Reporting**

**Property 12: Conditional Reboot Logic**
- Generate random VM states (reboot-required file present/absent)
- Execute playbook
- Verify reboot task executed only when file present
- **Feature: terraform-actions-gcp-patching, Property 12: Conditional Reboot Logic**

**Property 15: No Plaintext Credentials**
- Generate list of all Terraform files
- Scan each file for credential patterns (regex)
- Verify no matches found
- **Feature: terraform-actions-gcp-patching, Property 15: No Plaintext Credentials**

**Property 16: Least Privilege IAM**
- Generate list of all service account IAM bindings
- Verify each binding uses minimal required roles
- Verify no overly permissive roles (owner, editor)
- **Feature: terraform-actions-gcp-patching, Property 16: Least Privilege IAM**

### Test Environment

**Local Testing**:
- Use Terraform with local backend for syntax validation
- Use Ansible with local connection for playbook testing
- Mock external APIs (GCP, AAP) for unit tests

**Integration Testing**:
- Use GCP test project with isolated resources
- Use AAP test instance
- Use HCP Terraform test workspace
- Clean up resources after each test run

**CI/CD Integration**:
- Run `terraform validate` on every commit
- Run `ansible-lint` on every commit
- Run unit tests on every pull request
- Run integration tests on merge to main branch
- Use GitHub Actions or GitLab CI for automation

### Testing Checklist

- [ ] Terraform syntax validation passes
- [ ] Terraform plan succeeds with valid configuration
- [ ] All Terraform outputs are correctly defined
- [ ] Ansible playbook syntax check passes
- [ ] Ansible lint passes with no errors
- [ ] Unit tests cover all edge cases
- [ ] Property tests run 100+ iterations each
- [ ] Integration tests pass in test environment
- [ ] Security scan finds no plaintext credentials
- [ ] IAM permissions follow least privilege
- [ ] Documentation includes testing instructions
