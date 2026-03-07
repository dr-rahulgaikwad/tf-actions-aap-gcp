# Deployment Checklist

## Pre-Deployment Checklist

### 1. Prerequisites Verification

#### Tools Installation
- [ ] `gcloud` CLI installed and configured
- [ ] `vault` CLI installed
- [ ] `terraform` CLI installed (optional for HCP Terraform)
- [ ] `jq` installed (optional but recommended)

#### Access Verification
- [ ] GCP project created with billing enabled
- [ ] HCP Terraform account created
- [ ] HCP Vault cluster created
- [ ] Ansible Automation Platform instance available
- [ ] GitHub repository created

### 2. GCP Setup

#### Project Configuration
- [ ] GCP project ID noted: `_________________`
- [ ] Billing enabled on project
- [ ] Authenticated to GCP: `gcloud auth login`
- [ ] Project set: `gcloud config set project PROJECT_ID`

#### API Enablement
- [ ] Compute Engine API enabled
- [ ] IAM API enabled
- [ ] Cloud Resource Manager API enabled
- [ ] OS Login API enabled
- [ ] IAM Credentials API enabled

```bash
gcloud services enable compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  oslogin.googleapis.com \
  iamcredentials.googleapis.com
```

#### Service Account for Vault
- [ ] Service account created: `vault-admin`
- [ ] Roles assigned:
  - [ ] `roles/iam.serviceAccountAdmin`
  - [ ] `roles/iam.serviceAccountKeyAdmin`
- [ ] Service account key created and downloaded
- [ ] Key stored securely (will be deleted after Vault config)

### 3. Vault Setup

#### Authentication
- [ ] Vault address set: `export VAULT_ADDR=https://...`
- [ ] Vault namespace set: `export VAULT_NAMESPACE=admin`
- [ ] Authenticated to Vault: `vault login`

#### JWT Auth Configuration
- [ ] JWT auth method enabled: `vault auth enable jwt`
- [ ] JWT config written with Terraform Cloud issuer
- [ ] Policy created: `terraform-provisioner`
- [ ] JWT role created: `terraform-cloud`
- [ ] JWT role bound_claims configured with correct org name
- [ ] JWT role tested: `vault read auth/jwt/role/terraform-cloud`

#### GCP Secrets Engine
- [ ] GCP secrets engine enabled: `vault secrets enable gcp`
- [ ] GCP config written with service account credentials
- [ ] Roleset created: `terraform-provisioner`
- [ ] Roleset configured with required IAM roles
- [ ] Token generation tested: `vault read gcp/token/terraform-provisioner`
- [ ] Service account key deleted from local system

#### KV Secrets Engine
- [ ] KV v2 enabled at `secret/` (default in HCP Vault)
- [ ] AAP OAuth2 credentials stored: `vault kv put secret/aap/oauth2 ...`
- [ ] Credentials tested: `vault kv get secret/aap/oauth2`

### 4. AAP Setup

#### OAuth2 Application
- [ ] OAuth2 application created in AAP
- [ ] Application name: `Terraform Automation`
- [ ] Grant type: Resource owner password-based
- [ ] Client type: Confidential
- [ ] Client ID noted: `_________________`
- [ ] Client Secret noted: `_________________`
- [ ] Credentials stored in Vault

#### Project Configuration
- [ ] Ansible project created in AAP
- [ ] Project synced with Git repository
- [ ] Playbook `gcp_vm_patching_demo.yml` available

### 5. OS Login Setup

#### SSH Key Configuration
- [ ] SSH key pair exists: `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
- [ ] SSH key added to OS Login: `gcloud compute os-login ssh-keys add ...`
- [ ] OS Login username obtained: `gcloud compute os-login describe-profile`
- [ ] Username noted: `_________________`

### 6. HCP Terraform Setup

#### Workspace Creation
- [ ] Workspace created: `tf-actions-aap-gcp`
- [ ] VCS connection configured (GitHub)
- [ ] Working directory set: `terraform`
- [ ] Terraform version set: `>= 1.7.0`

#### Environment Variables
- [ ] `TFC_VAULT_BACKED_JWT_AUTH=true`
- [ ] `TFC_VAULT_PROVIDER_AUTH=true`
- [ ] `TFC_VAULT_ADDR=https://vault.hashicorp.cloud:8200`
- [ ] `TFC_VAULT_NAMESPACE=admin`
- [ ] `AAP_INSECURE_SKIP_VERIFY=true` (only for demo)

#### Terraform Variables
- [ ] `vault_addr` set
- [ ] `vault_namespace` set
- [ ] `vault_gcp_roleset` set
- [ ] `gcp_project_id` set
- [ ] `gcp_region` set
- [ ] `gcp_zone` set
- [ ] `aap_hostname` set
- [ ] `aap_oidc_issuer_url` set
- [ ] `aap_oidc_repository` set
- [ ] `aap_job_template_id` set (will update after job template creation)
- [ ] `ansible_user` set (OS Login username)
- [ ] `environment` set (`demo`, `dev`, `staging`, or `production`)
- [ ] `vm_count` set
- [ ] `aap_server_ip` set (required for production)

### 7. Initial Deployment

#### Pre-Deployment Validation
- [ ] Run validation script: `./scripts/validate.sh`
- [ ] All critical checks passed
- [ ] Warnings reviewed and addressed

#### Terraform Deployment
- [ ] Code committed to Git
- [ ] Code pushed to GitHub
- [ ] Terraform run triggered in HCP Terraform
- [ ] Plan reviewed and approved
- [ ] Apply completed successfully
- [ ] VMs created
- [ ] Workload Identity Pool created
- [ ] AAP inventory created
- [ ] Outputs reviewed

#### Post-Deployment Verification
- [ ] VMs are running: `gcloud compute instances list`
- [ ] VMs have OS Login enabled
- [ ] Workload Identity Pool exists
- [ ] AAP inventory populated with hosts

### 8. AAP Job Template Setup

#### GCP OIDC Credential
- [ ] Credential created in AAP
- [ ] Name: `GCP OIDC Production`
- [ ] Type: Google Cloud Platform
- [ ] Auth: Workload Identity Federation
- [ ] Service Account Email from Terraform output
- [ ] Workload Provider from Terraform output
- [ ] Project ID set
- [ ] Credential tested

#### SSH Credential
- [ ] Credential created in AAP
- [ ] Name: `OS Login SSH`
- [ ] Type: Machine
- [ ] Username: OS Login username
- [ ] SSH Private Key: Personal SSH key
- [ ] Credential tested

#### Job Template
- [ ] Job template created
- [ ] Name: `Patch GCP VMs`
- [ ] Inventory: `demo-gcp-vms` (from Terraform)
- [ ] Project: Ansible project with playbook
- [ ] Playbook: `ansible/gcp_vm_patching_demo.yml`
- [ ] Credentials: GCP OIDC + SSH
- [ ] Variables: Prompt on launch enabled
- [ ] Job template ID noted: `_________________`
- [ ] Terraform variable updated: `aap_job_template_id`

#### Job Template Testing
- [ ] Job template launched manually
- [ ] Job completed successfully
- [ ] VMs patched
- [ ] Logs reviewed

### 9. Terraform Actions Testing

#### Update Terraform Variable
- [ ] `aap_job_template_id` updated in HCP Terraform
- [ ] Change committed and pushed

#### Trigger Terraform Actions
- [ ] Terraform run triggered
- [ ] Terraform Actions executed
- [ ] AAP job launched automatically
- [ ] Job completed successfully
- [ ] Terraform run completed

### 10. Production Readiness

#### Security Hardening
- [ ] `environment` set to `production`
- [ ] `aap_server_ip` configured
- [ ] Firewall rules restricted
- [ ] `AAP_INSECURE_SKIP_VERIFY` removed (TLS verification enabled)
- [ ] Vault audit logging enabled
- [ ] GCP Cloud Audit Logs enabled
- [ ] AAP job notifications configured

#### Monitoring Setup
- [ ] Terraform run alerts configured
- [ ] AAP job failure alerts configured
- [ ] VM patch compliance monitoring enabled
- [ ] Cost alerts configured
- [ ] Vault token usage monitoring enabled

#### Documentation
- [ ] README.md reviewed
- [ ] ARCHITECTURE.md reviewed
- [ ] CONTEXT.md reviewed
- [ ] Team trained on deployment process
- [ ] Runbook created for common issues

#### Backup and Recovery
- [ ] Terraform state backup configured (automatic in HCP Terraform)
- [ ] Vault backup strategy documented
- [ ] AAP backup strategy documented
- [ ] Disaster recovery plan documented

---

## Post-Deployment Checklist

### Daily Operations

#### Monitoring
- [ ] Check Terraform run status
- [ ] Check AAP job status
- [ ] Review VM patch compliance
- [ ] Review cost reports
- [ ] Check for security alerts

#### Maintenance
- [ ] Review Vault audit logs
- [ ] Review GCP audit logs
- [ ] Review AAP job logs
- [ ] Update playbooks as needed
- [ ] Update Terraform code as needed

### Weekly Operations

#### Security Review
- [ ] Review IAM permissions
- [ ] Review firewall rules
- [ ] Review credential usage
- [ ] Check for security updates
- [ ] Review compliance reports

#### Performance Review
- [ ] Review job execution times
- [ ] Review VM performance
- [ ] Review cost trends
- [ ] Optimize resource usage

### Monthly Operations

#### Compliance
- [ ] Generate compliance reports
- [ ] Review patch compliance
- [ ] Review security posture
- [ ] Update documentation

#### Planning
- [ ] Review capacity needs
- [ ] Plan infrastructure changes
- [ ] Review and update runbooks
- [ ] Team training updates

---

## Rollback Procedures

### Rollback Terraform Changes

```bash
# Option 1: Revert Git commit
git revert HEAD
git push origin main

# Option 2: Rollback in HCP Terraform UI
# Workspaces → Runs → Select previous successful run → Rollback

# Option 3: Destroy and recreate
terraform destroy -auto-approve
# Fix issues
terraform apply -auto-approve
```

### Rollback AAP Changes

```bash
# Revert playbook changes in Git
git revert HEAD
git push origin main

# AAP will sync automatically
```

### Emergency Procedures

#### Stop All Patching
```bash
# Option 1: Disable job template in AAP
# Templates → Patch GCP VMs → Edit → Enabled: No

# Option 2: Remove Terraform Actions trigger
# Comment out lifecycle block in actions.tf
```

#### Restore VM from Snapshot
```bash
# Create snapshot before major changes
gcloud compute disks snapshot DISK_NAME \
  --snapshot-names=SNAPSHOT_NAME

# Restore from snapshot
gcloud compute disks create NEW_DISK \
  --source-snapshot=SNAPSHOT_NAME

# Attach to VM
gcloud compute instances attach-disk VM_NAME \
  --disk=NEW_DISK
```

---

## Troubleshooting Quick Reference

### Vault Issues
```bash
# Check Vault status
vault status

# Check authentication
vault token lookup

# Test GCP token generation
vault read gcp/token/terraform-provisioner

# Test AAP credentials
vault kv get secret/aap/oauth2
```

### GCP Issues
```bash
# Check VMs
gcloud compute instances list

# Check OS Login
gcloud compute os-login describe-profile
gcloud compute os-login ssh-keys list

# Check Workload Identity
gcloud iam workload-identity-pools list --location=global
```

### AAP Issues
```bash
# Check job status
curl -k https://aap-server/api/v2/jobs/

# Check inventory
curl -k https://aap-server/api/v2/inventories/

# Test SSH connection
gcloud compute ssh ubuntu-vm-1 --tunnel-through-iap
```

### Terraform Issues
```bash
# Check workspace status
terraform workspace show

# Validate configuration
terraform validate

# Check state
terraform state list

# Refresh state
terraform refresh
```

---

## Success Criteria

### Deployment Success
- [ ] All VMs created and running
- [ ] OS Login enabled and working
- [ ] Workload Identity configured
- [ ] AAP inventory populated
- [ ] Job template working
- [ ] Terraform Actions triggering successfully
- [ ] VMs being patched automatically

### Security Success
- [ ] Zero static credentials in use
- [ ] All credentials dynamic and rotating
- [ ] Audit logging enabled
- [ ] Firewall rules restrictive
- [ ] IAM permissions least-privilege

### Operational Success
- [ ] GitOps workflow functioning
- [ ] Monitoring and alerting active
- [ ] Documentation complete
- [ ] Team trained
- [ ] Runbooks available

---

## Sign-Off

### Deployment Team

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Solutions Architect | | | |
| DevOps Engineer | | | |
| Security Engineer | | | |
| Operations Manager | | | |

### Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Technical Lead | | | |
| Security Lead | | | |
| Operations Lead | | | |

---

**Deployment Date:** _______________  
**Environment:** _______________  
**Version:** v2.0.0  
**Status:** ☐ Pending ☐ In Progress ☐ Completed ☐ Failed
