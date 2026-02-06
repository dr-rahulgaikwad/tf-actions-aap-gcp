# Implementation Plan: Terraform Actions GCP Patching Prototype

## Overview

This implementation plan breaks down the prototype into discrete coding tasks that build incrementally. The approach follows the Day 0/1/2 workflow: first establishing the infrastructure foundation, then adding Terraform Actions integration, and finally implementing the Ansible automation layer.

## Tasks

- [x] 1. Set up project structure and Terraform foundation
  - Create directory structure: `terraform/`, `ansible/`, `tests/`, `docs/`
  - Create main Terraform files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
  - Configure Terraform backend for HCP Terraform (remote state)
  - Define required providers: google, vault
  - Create `.gitignore` to exclude sensitive files and Terraform state
  - _Requirements: 1.4, 6.1, 6.3_

- [x] 2. Implement Vault integration for credential management
  - [x] 2.1 Create Vault data sources in Terraform
    - Define `vault_generic_secret` data sources for GCP credentials
    - Define `vault_generic_secret` data sources for AAP token
    - Define `vault_generic_secret` data sources for SSH keys
    - _Requirements: 8.1, 6.5_
  
  - [x] 2.2 Configure GCP provider with Vault credentials
    - Set up google provider using Vault-retrieved service account key
    - Configure project, region, and zone from variables
    - _Requirements: 6.2, 8.1_
  
  - [x] 2.3 Write property test for Vault credential retrieval
    - **Property 14: Vault Credential Retrieval**
    - **Validates: Requirements 8.1**
  
  - [x] 2.4 Write property test for no plaintext credentials
    - **Property 15: No Plaintext Credentials**
    - **Validates: Requirements 8.2**

- [x] 3. Implement GCP VM provisioning
  - [x] 3.1 Create VM resource definitions
    - Define `google_compute_instance` resources for Ubuntu VMs
    - Configure boot disk with Ubuntu 22.04 LTS image
    - Set machine type, zone, and count from variables
    - Add metadata for SSH keys
    - Add labels for environment, managed_by, and os
    - _Requirements: 1.1, 1.5_
  
  - [x] 3.2 Configure networking for VMs
    - Define or reference VPC network
    - Configure network interfaces with internal IPs
    - Add access_config for external IPs (optional)
    - Create firewall rule for SSH access (port 22)
    - _Requirements: 1.2, 7.5_
  
  - [x] 3.3 Define Terraform outputs
    - Output list of VM instance IDs
    - Output list of internal IP addresses
    - Output list of external IP addresses
    - Output VM names
    - _Requirements: 1.3_
  
  - [x] 3.4 Write property test for VM provisioning completeness
    - **Property 1: VM Provisioning Completeness**
    - **Validates: Requirements 1.1**
  
  - [x] 3.5 Write property test for network configuration consistency
    - **Property 2: Network Configuration Consistency**
    - **Validates: Requirements 1.2**
  
  - [x] 3.6 Write property test for output data completeness
    - **Property 3: Output Data Completeness**
    - **Validates: Requirements 1.3**
  
  - [x] 3.7 Write property test for resource labeling consistency
    - **Property 4: Resource Labeling Consistency**
    - **Validates: Requirements 1.5**

- [x] 4. Checkpoint - Validate Terraform provisioning
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement GCP OS Config patch deployment
  - [x] 5.1 Create patch deployment resource
    - Define `google_os_config_patch_deployment` resource
    - Configure instance filter using labels (environment, os)
    - Set patch_config for apt with DIST type
    - Configure one_time_schedule for on-demand execution
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  
  - [x] 5.2 Add patch deployment output
    - Output patch deployment ID
    - _Requirements: 1.3_
  
  - [x] 5.3 Write property test for patch deployment creation
    - **Property 5: Patch Deployment Resource Creation**
    - **Validates: Requirements 2.1**
  
  - [x] 5.4 Write property test for patch configuration completeness
    - **Property 6: Patch Configuration Completeness**
    - **Validates: Requirements 2.4**

- [x] 6. Implement Terraform Actions configuration
  - [x] 6.1 Define Terraform Action for AAP integration
    - Create action block named "patch_vms"
    - Configure HTTP integration with AAP API URL
    - Set up bearer token authentication using Vault
    - Define payload with job_template_id and inventory
    - Build inventory JSON from VM outputs
    - _Requirements: 3.1, 3.2, 3.3, 3.5_
  
  - [ ]* 6.2 Write property test for action payload structure
    - **Property 7: Action Payload Structure**
    - **Validates: Requirements 3.3**
  
  - [ ]* 6.3 Write property test for action execution status
    - **Property 8: Action Execution Status**
    - **Validates: Requirements 3.4**

- [x] 7. Implement Ansible patching playbook
  - [x] 7.1 Create base playbook structure
    - Create `ansible/gcp_vm_patching.yml`
    - Define play targeting all hosts
    - Set become: yes for privilege escalation
    - Configure ansible_user variable
    - _Requirements: 4.1_
  
  - [x] 7.2 Implement apt update and upgrade tasks
    - Add task to update apt cache
    - Add task to upgrade security packages using apt safe upgrade
    - Add task to autoremove and autoclean
    - _Requirements: 4.2, 4.3_
  
  - [x] 7.3 Implement conditional reboot logic
    - Add task to check for /var/run/reboot-required file
    - Add conditional reboot task based on file existence
    - Set reboot timeout to 300 seconds
    - _Requirements: 4.6_
  
  - [x] 7.4 Add status reporting and error handling
    - Add debug task to report completion status
    - Add error handling with meaningful messages
    - Configure failed_when conditions for critical tasks
    - _Requirements: 4.4, 4.5_
  
  - [ ]* 7.5 Write property test for playbook update execution
    - **Property 9: Playbook Update Execution**
    - **Validates: Requirements 4.3**
  
  - [ ]* 7.6 Write property test for playbook status reporting
    - **Property 10: Playbook Status Reporting**
    - **Validates: Requirements 4.4**
  
  - [ ]* 7.7 Write property test for playbook error handling
    - **Property 11: Playbook Error Handling**
    - **Validates: Requirements 4.5**
  
  - [ ]* 7.8 Write property test for conditional reboot logic
    - **Property 12: Conditional Reboot Logic**
    - **Validates: Requirements 4.6**

- [x] 8. Create Ansible inventory template
  - Create `ansible/inventory_template.yml` showing expected structure
  - Document how Terraform Actions passes inventory dynamically
  - Include example with multiple VMs
  - _Requirements: 3.3, 5.3_

- [x] 9. Implement IAM and security configurations
  - [x] 9.1 Create service account IAM bindings
    - Define minimal IAM roles for Terraform service account
    - Grant compute.instanceAdmin for VM management
    - Grant osconfig.patchDeploymentAdmin for patch management
    - _Requirements: 7.3, 8.5_
  
  - [x] 9.2 Write property test for least privilege IAM
    - **Property 16: Least Privilege IAM**
    - **Validates: Requirements 8.5**
  
  - [x] 9.3 Write property test for minimal firewall rules
    - **Property 18: Minimal Firewall Rules**
    - **Validates: Requirements 7.5**

- [x] 10. Checkpoint - Validate security and IAM
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Create setup and configuration documentation
  - [x] 11.1 Write GCP project setup guide
    - Document required APIs to enable
    - Document service account creation steps
    - Document IAM role assignments
    - Document Vault secret setup for GCP credentials
    - _Requirements: 9.2, 7.1, 7.2_
  
  - [x] 11.2 Write AAP setup guide
    - Document AAP installation or access requirements
    - Document job template creation steps
    - Document credential configuration with Vault
    - Document API token generation
    - Document Vault secret setup for AAP token
    - _Requirements: 9.1, 5.1, 5.2, 5.4, 5.5_
  
  - [x] 11.3 Write HCP Terraform workspace setup guide
    - Document workspace creation steps
    - Document variable configuration
    - Document Vault integration setup
    - Document VCS integration (optional)
    - _Requirements: 9.3, 6.1, 6.4_
  
  - [x] 11.4 Write demonstration workflow guide
    - Document Day 0/1 provisioning steps
    - Document Day 2 action triggering steps
    - Document verification steps
    - Include troubleshooting tips
    - _Requirements: 9.5, 9.6, 10.1, 10.2, 10.3, 10.4_

- [x] 12. Create Terraform variables file template
  - Create `terraform.tfvars.example` with all required variables
  - Document each variable with comments
  - Include example values
  - Add instructions for customization
  - _Requirements: 6.4_

- [x] 13. Create validation and testing scripts
  - [x] 13.1 Create Terraform validation script
    - Write script to run `terraform validate`
    - Write script to run `terraform fmt -check`
    - Add to CI/CD pipeline documentation
    - _Requirements: Testing Strategy_
  
  - [x] 13.2 Create Ansible validation script
    - Write script to run `ansible-playbook --syntax-check`
    - Write script to run `ansible-lint`
    - Add to CI/CD pipeline documentation
    - _Requirements: Testing Strategy_
  
  - [ ]* 13.3 Implement remaining property-based tests
    - Set up Hypothesis testing framework if not already configured
    - Implement Property 13: Job Template Inventory Acceptance
    - Implement Property 17: Service Account Authentication
    - Configure 100+ iterations per test
    - Add test tagging with property references
    - _Requirements: Testing Strategy, 5.3, 6.2_
  
  - [ ]* 13.4 Create integration test script
    - Write script to test end-to-end workflow
    - Include cleanup steps
    - Document test environment requirements
    - _Requirements: Testing Strategy_

- [x] 14. Create README and
 main documentation
  - Write project overview and architecture summary
  - Document prerequisites and dependencies
  - Link to setup guides
  - Include quick start instructions
  - Add troubleshooting section
  - Include demo workflow summary
  - _Requirements: 9.4, 10.4_

- [x] 15. Final checkpoint - End-to-end validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- The implementation follows Day 0 → Day 1 → Day 2 workflow progression
- Documentation tasks are integrated throughout to ensure demo-readiness
- Core infrastructure and Ansible playbook implementation are complete
- Remaining work focuses on Terraform Actions integration and documentation

