# Security Patching Demo Guide - Day 2 Operations

This guide provides a complete walkthrough for demonstrating real security patching as a Day-2 operation using Terraform Actions and Ansible Automation Platform.

## Demo Overview

**Duration**: 15-20 minutes  
**Audience**: DevOps teams, Security teams, Platform engineers  
**Key Message**: Automate Day-2 operations (patching) using the same IaC tools that provision infrastructure

---

## Demo Scenario

**The Problem**: Your security team has identified critical vulnerabilities in production VMs that need immediate patching.

**The Solution**: Use Terraform Actions to automatically trigger Ansible Automation Platform jobs that patch VMs, reboot if needed, and generate compliance reports.

---

## Pre-Demo Setup (5 minutes)

### 1. Ensure Infrastructure is Running

```bash
# Verify VMs are provisioned
cd terraform
terraform output vm_names
terraform output vm_external_ips

# Expected output:
# vm_names = ["ubuntu-vm-1", "ubuntu-vm-2"]
# vm_external_ips = ["34.xx.xx.xx", "34.yy.yy.yy"]
```

### 2. Set Up Vulnerable State on VMs

SSH into each VM and run the setup script:

```bash
# Get VM IPs
VM_IPS=$(cd terraform && terraform output -json vm_external_ips | jq -r '.[]')

# For each VM, set up vulnerable state
for VM_IP in $VM_IPS; do
    echo "Setting up vulnerable state on $VM_IP..."
    
    # Copy setup script
    scp -i ~/.ssh/ubuntu-patching -o StrictHostKeyChecking=no \
        demo/setup-vulnerable-state.sh ubuntu@${VM_IP}:/tmp/
    
    # Run setup script
    ssh -i ~/.ssh/ubuntu-patching -o StrictHostKeyChecking=no \
        ubuntu@${VM_IP} "sudo bash /tmp/setup-vulnerable-state.sh"
done
```

### 3. Verify AAP Job Template

Ensure the AAP job template is configured to use the demo playbook:

- **Playbook**: `ansible/gcp_vm_patching_demo.yml`
- **Prompt on launch**: Variables (enabled)
- **Extra Variables**: Will be provided by Terraform Actions

---

## Demo Script

### Part 1: Show the Problem (3 minutes)

**Narrative**: "Let's start by looking at the current state of our infrastructure. Our security team has flagged some critical vulnerabilities."

#### 1.1 Show Infrastructure

```bash
# Show Terraform configuration
cat terraform/main.tf | grep -A 10 "resource \"google_compute_instance\""

# Show current VMs
terraform output
```

**Key Points**:
- Infrastructure provisioned with Terraform (Day 0)
- VMs are running but need security updates (Day 2)

#### 1.2 Show Vulnerability Report

```bash
# SSH to first VM
VM_IP=$(cd terraform && terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP}

# Show vulnerability report
cat /tmp/vulnerability-report.txt

# Show outdated packages
apt list --upgradable 2>/dev/null | grep -i security | head -10

# Check kernel version
uname -r

# Exit VM
exit
```

**Key Points**:
- Critical CVEs identified
- Multiple packages need updates
- Kernel may need updating (requires reboot)

### Part 2: Show the Solution - Terraform Actions (5 minutes)

**Narrative**: "Instead of manually patching each VM, we'll use Terraform Actions to automate this Day-2 operation."

#### 2.1 Show Terraform Actions Configuration

```bash
# Show the action configuration
cat terraform/actions.tf
```

**Highlight**:
```hcl
# Terraform Action: Launch AAP job to patch VMs
action "aap_job_launch" "patch_vms" {
  config {
    job_template_id                     = var.aap_job_template_id
    wait_for_completion                 = true
    wait_for_completion_timeout_seconds = 600
    extra_vars                          = jsonencode(local.extra_vars)
  }
}

# Automatic trigger on VM changes
resource "terraform_data" "trigger_patch" {
  lifecycle {
    action_trigger {
      events  = [after_create, after_update]
      actions = [action.aap_job_launch.patch_vms]
    }
  }
}
```

**Key Points**:
- Action defined in Terraform code
- Automatically triggers on infrastructure changes
- Integrates with Ansible Automation Platform
- Passes dynamic inventory from Terraform state

#### 2.2 Show Dynamic Inventory Generation

```bash
# Show how inventory is generated
cat terraform/actions.tf | grep -A 20 "locals {"
```

**Key Points**:
- VM inventory automatically generated from Terraform state
- No manual inventory management
- Always up-to-date with infrastructure

### Part 3: Trigger the Patching (7 minutes)

**Narrative**: "Now let's trigger the patching operation. In a real scenario, this would happen automatically when VMs are created or updated."

#### 3.1 Trigger via Infrastructure Change

**Option A: Automatic Trigger (Recommended for Demo)**

```bash
# Make a small change to trigger the action
cd terraform

# Add a label to trigger update
cat >> main.tf << 'EOF'

# Trigger patching demo
resource "terraform_data" "demo_trigger" {
  input = timestamp()
}
EOF

# Commit and push (triggers HCP Terraform run)
git add main.tf
git commit -m "Trigger security patching demo"
git push origin main
```

**Option B: Manual Trigger (Alternative)**

```bash
# Get AAP details
cd terraform
AAP_URL=$(terraform output -raw action_patch_vms_url)
AAP_TOKEN=$(vault kv get -field=token secret/aap/api-token)

# Generate payload
terraform output -raw action_patch_vms_payload > /tmp/aap_payload.json

# Show the payload
cat /tmp/aap_payload.json | jq .

# Trigger the job
curl -k -X POST \
  -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/aap_payload.json \
  ${AAP_URL} | jq .
```

#### 3.2 Monitor in AAP UI

**Open AAP UI and show**:

1. Navigate to **Views → Jobs**
2. Find the running job
3. Show real-time output

**Highlight the phases**:
- ✅ Phase 1: Pre-Patching Assessment
- ✅ Phase 2: Applying Security Patches
- ✅ Phase 3: Post-Patching Verification
- ✅ Phase 4: Final Security Assessment
- ✅ Phase 5: Generate Compliance Report

**Key Output to Show**:
```
========================================
SECURITY UPDATES AVAILABLE: 15
========================================
openssh-server/jammy-security 1:8.9p1-3ubuntu0.6 amd64 [upgradable from: 1:8.9p1-3ubuntu0.4]
libssl3/jammy-security 3.0.2-0ubuntu1.12 amd64 [upgradable from: 3.0.2-0ubuntu1.10]
...

========================================
PATCHING RESULTS
========================================
Packages Updated: True
Patch Type: security
Status: SUCCESS
========================================

========================================
REBOOT REQUIRED: YES
========================================
Packages requiring reboot:
linux-image-5.15.0-91-generic
openssh-server
========================================

========================================
FINAL SECURITY STATUS
========================================
Host: ubuntu-vm-1
Patching Status: COMPLETED
Remaining Security Updates: 0
Patch Compliance: COMPLIANT
========================================
```

### Part 4: Verify Results (3 minutes)

**Narrative**: "Let's verify that the patching was successful and our VMs are now secure."

#### 4.1 Check VM State

```bash
# SSH to first VM
VM_IP=$(cd terraform && terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP}

# Check for remaining updates
apt list --upgradable 2>/dev/null | wc -l

# Check kernel version (should be updated if reboot occurred)
uname -r

# Check last reboot time
who -b

# Check package update history
grep "upgrade" /var/log/dpkg.log | tail -20

# Exit
exit
```

#### 4.2 Show Compliance Status

```bash
# Show the compliance report from AAP job output
# (Copy from AAP UI or show in terminal)
```

**Expected Output**:
```yaml
compliance_report:
  hostname: ubuntu-vm-1
  ip_address: 34.xx.xx.xx
  os_version: Ubuntu 22.04
  kernel_version: 5.15.0-91-generic
  patch_date: 2026-02-08T10:30:00Z
  patches_applied: true
  reboot_performed: true
  security_updates_remaining: 0
  compliance_status: COMPLIANT
```

### Part 5: Show the Value (2 minutes)

**Narrative**: "Let's recap what we just accomplished with Terraform Actions."

#### Key Benefits to Highlight:

1. **Unified Workflow**
   - Same tool (Terraform) for Day 0 and Day 2
   - No context switching between tools
   - Single source of truth

2. **Automation**
   - Automatic triggering on infrastructure changes
   - No manual intervention required
   - Consistent patching across all VMs

3. **Security**
   - Credentials managed in Vault
   - No secrets in code
   - Audit trail in HCP Terraform and AAP

4. **Compliance**
   - Automated compliance reporting
   - Proof of patching for auditors
   - Scheduled patching windows

5. **Scalability**
   - Works for 2 VMs or 2000 VMs
   - Dynamic inventory from Terraform state
   - Parallel execution

---

## Demo Variations

### Variation 1: Scheduled Patching

Show how to schedule patching during maintenance windows:

```hcl
# In actions.tf
locals {
  # Only patch during maintenance window (example: weekends)
  is_maintenance_window = formatdate("E", timestamp()) == "Sat" || formatdate("E", timestamp()) == "Sun"
  
  extra_vars = {
    patch_type     = "security"
    reboot_allowed = local.is_maintenance_window
    environment    = var.environment
    vm_inventory   = local.vm_inventory
  }
}
```

### Variation 2: Selective Patching

Show how to patch only specific VMs:

```hcl
# In actions.tf
locals {
  # Only patch VMs with specific label
  patchable_vms = {
    for vm in google_compute_instance.ubuntu_vms :
    vm.name => vm
    if lookup(vm.labels, "auto_patch", "false") == "true"
  }
}
```

### Variation 3: Multi-Environment

Show how to handle different environments:

```hcl
# In actions.tf
locals {
  extra_vars = {
    patch_type     = var.environment == "production" ? "security" : "full"
    reboot_allowed = var.environment != "production"  # No auto-reboot in prod
    environment    = var.environment
    vm_inventory   = local.vm_inventory
  }
}
```

---

## Troubleshooting During Demo

### Issue: AAP Job Fails with "Host Unreachable"

**Solution**:
```bash
# Verify SSH connectivity
VM_IP=$(cd terraform && terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP} "echo 'Connection OK'"

# Check firewall rules
cd terraform
terraform show | grep google_compute_firewall -A 10
```

### Issue: No Security Updates Available

**Solution**:
```bash
# Re-run the vulnerable state setup
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP} "sudo bash /tmp/setup-vulnerable-state.sh"
```

### Issue: Reboot Doesn't Happen

**Solution**:
- Check `reboot_allowed` variable in extra_vars
- Verify `/var/run/reboot-required` file exists on VM
- Check AAP job output for reboot task

---

## Post-Demo Cleanup

### 1. Restore Normal State

```bash
# SSH to each VM and restore
for VM_IP in $VM_IPS; do
    echo "Restoring normal state on $VM_IP..."
    scp -i ~/.ssh/ubuntu-patching demo/restore-normal-state.sh ubuntu@${VM_IP}:/tmp/
    ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP} "sudo bash /tmp/restore-normal-state.sh"
done
```

### 2. Remove Demo Trigger

```bash
# Remove the demo trigger from main.tf
cd terraform
git revert HEAD
git push origin main
```

---

## Q&A Preparation

### Common Questions

**Q: How does this compare to manual patching?**

A: Manual patching requires:
- Logging into each VM individually
- Running commands manually
- Tracking which VMs are patched
- No audit trail

Terraform Actions provides:
- Automated execution across all VMs
- Consistent patching process
- Complete audit trail
- Compliance reporting

**Q: What about patching during business hours?**

A: You can configure maintenance windows using Terraform variables and conditionals. The action can check the current time and only allow reboots during approved windows.

**Q: How do you handle rollback if patching fails?**

A: 
- AAP provides detailed error reporting
- You can configure pre-flight checks
- Terraform state tracks infrastructure changes
- VM snapshots can be taken before patching

**Q: Can this work with other cloud providers?**

A: Yes! The same pattern works with:
- AWS EC2 instances
- Azure VMs
- VMware vSphere
- Any infrastructure Terraform can manage

**Q: What about Windows servers?**

A: The same approach works with Windows:
- Use Windows Update modules in Ansible
- Adjust playbooks for PowerShell
- Same Terraform Actions integration

---

## Success Metrics to Highlight

- **Time Saved**: Manual patching of 100 VMs = 5 hours → Automated = 30 minutes
- **Consistency**: 100% of VMs patched identically
- **Compliance**: Automated reporting for auditors
- **Security**: Faster response to CVEs (minutes vs. days)

---

## Additional Resources

- [Terraform Actions Documentation](https://developer.hashicorp.com/terraform/cloud-docs/actions)
- [AAP Terraform Provider](https://registry.terraform.io/providers/ansible/aap/latest)
- [HashiCorp Vault Integration](https://developer.hashicorp.com/vault/docs)

---

**Demo Complete!** 🎉
