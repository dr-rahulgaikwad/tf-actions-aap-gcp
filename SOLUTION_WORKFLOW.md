# Solution Architecture & Workflow

## Complete Solution Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 1: Developer Commits Infrastructure Changes                          │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  Developer → Git Commit → GitHub Repository                                │
│                                                                             │
│  Changes:                                                                   │
│  • VM count adjustment (variables.tf)                                      │
│  • Machine type updates (terraform.tfvars)                                 │
│  • Network configuration changes                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ git push origin main
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 2: HCP Terraform Detects Changes                                     │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  GitHub Webhook → HCP Terraform Workspace                                  │
│                                                                             │
│  Actions:                                                                   │
│  1. Clone repository                                                        │
│  2. Load workspace variables                                               │
│  3. Initialize Terraform providers                                         │
│  4. Generate execution plan                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ terraform plan
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 3: Retrieve Secrets from Vault                                       │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  HCP Terraform → Vault API (HTTPS)                                         │
│                                                                             │
│  Secrets Retrieved:                                                         │
│  • secret/gcp/service-account → GCP credentials                            │
│  • secret/aap/api-token → AAP API token                                    │
│                                                                             │
│  Security:                                                                  │
│  • TLS encrypted connection                                                │
│  • Token-based authentication                                              │
│  • Namespace isolation (admin)                                             │
│  • Audit logging enabled                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ terraform apply (auto or manual)
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 4: Provision GCP Infrastructure                                      │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  Resources Created/Updated:                                                 │
│                                                                             │
│  1. Workload Identity Pool & Provider                                      │
│     • OIDC authentication for AAP                                          │
│     • No service account keys needed                                       │
│                                                                             │
│  2. Service Account (ansible-automation)                                   │
│     • OS Login permissions                                                 │
│     • Workload Identity binding                                            │
│                                                                             │
│  3. VPC Network (patching-demo-network)                                    │
│     • Auto-created subnets                                                 │
│     • Private Google Access enabled                                        │
│                                                                             │
│  4. Firewall Rules                                                         │
│     • SSH (port 22) access                                                 │
│     • Conditional: 0.0.0.0/0 (demo) or AAP IP (production)                │
│                                                                             │
│  5. Compute Instances (ubuntu-vm-1 to ubuntu-vm-N)                         │
│     • Ubuntu 20.04 LTS                                                     │
│     • OS Login enabled                                                     │
│     • Public IPs (demo) or Private IPs (production)                        │
│     • Labels: environment, managed_by, os, patch_ready                     │
│                                                                             │
│  6. SSH Key Pair (TLS)                                                     │
│     • 4096-bit RSA key                                                     │
│     • Private key for AAP                                                  │
│     • Public key for OS Login                                              │
│                                                                             │
│  7. OS Config Patch Deployment                                             │
│     • Security patches only                                                │
│     • Reboot policy: DEFAULT                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Wait 120 seconds (VMs boot)
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 5: Terraform Actions Trigger                                         │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  Trigger Conditions:                                                        │
│  • after_create: New VMs provisioned                                       │
│  • after_update: Existing VMs modified                                     │
│                                                                             │
│  Payload Sent to AAP:                                                       │
│  {                                                                          │
│    "job_template_id": 11,                                                  │
│    "extra_vars": {                                                         │
│      "patch_type": "security",                                             │
│      "reboot_allowed": true,                                               │
│      "vm_inventory": {                                                     │
│        "all": {                                                            │
│          "hosts": {                                                        │
│            "ubuntu-vm-1": {                                                │
│              "ansible_host": "34.123.45.67",                               │
│              "ansible_user": "your_username_com",                          │
│              "instance_id": "1234567890",                                  │
│              "zone": "us-central1-a"                                       │
│            },                                                              │
│            ...                                                             │
│          }                                                                 │
│        }                                                                   │
│      }                                                                     │
│    }                                                                       │
│  }                                                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS POST to AAP API
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 6: AAP Job Template Execution                                        │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  AAP Actions:                                                               │
│                                                                             │
│  1. Receive job trigger from Terraform Actions                             │
│  2. Load job template configuration                                        │
│  3. Merge extra_vars with template variables                               │
│  4. Authenticate to GCP via OIDC Workload Identity                         │
│     • Generate OIDC token                                                  │
│     • Exchange for GCP access token                                        │
│     • Impersonate ansible-automation service account                       │
│  5. Retrieve SSH private key from Vault                                    │
│  6. Build dynamic inventory from extra_vars                                │
│  7. Execute Ansible playbook                                               │
│                                                                             │
│  Credentials Used:                                                          │
│  • GCP OIDC Credential (keyless, 1-hour token)                             │
│  • SSH Machine Credential (from Terraform output)                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Ansible playbook execution
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 7: Ansible Playbook Execution                                        │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  Play 1: Build Dynamic Inventory (localhost)                               │
│  ────────────────────────────────────────────────────────────────────────  │
│  • Parse vm_inventory from extra_vars                                      │
│  • Add each VM to 'gcp_vms' group                                          │
│  • Set ansible_host, ansible_user, SSH options                            │
│                                                                             │
│  Play 2: Patch VMs (gcp_vms group)                                         │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  For each VM:                                                               │
│                                                                             │
│  1. Wait for SSH (180s timeout, 3 retries)                                 │
│     • Connect via OS Login                                                 │
│     • Verify SSH service ready                                             │
│                                                                             │
│  2. Gather Facts                                                            │
│     • OS version, kernel, packages                                         │
│     • System resources, network config                                     │
│                                                                             │
│  3. Update APT Cache                                                        │
│     • Refresh package lists                                                │
│     • Cache valid for 3600s                                                │
│                                                                             │
│  4. Check Available Updates (Pre-Patch)                                    │
│     • List security updates                                                │
│     • Count total updates available                                        │
│     • Display in job output                                                │
│                                                                             │
│  5. Upgrade Packages                                                        │
│     • apt-get upgrade -y                                                   │
│     • Force config defaults                                                │
│     • Capture upgraded packages                                            │
│     • Display detailed output                                              │
│                                                                             │
│  6. Check Remaining Updates (Post-Patch)                                   │
│     • Verify patch completion                                              │
│     • Display status: FULLY PATCHED or PARTIALLY PATCHED                   │
│                                                                             │
│  7. Check Reboot Requirement                                               │
│     • Test for /var/run/reboot-required                                    │
│     • Display reboot status                                                │
│                                                                             │
│  8. Reboot if Required                                                      │
│     • Graceful reboot (5s delay)                                           │
│     • Wait for system to come back (600s timeout)                          │
│     • Verify system online                                                 │
│                                                                             │
│  Output Example:                                                            │
│  ═══════════════════════════════════════════════════════════════════════   │
│  TASK [Display pre-patch status]                                           │
│  ok: [ubuntu-vm-1] => {                                                    │
│      "msg": [                                                              │
│          "=== SECURITY UPDATES AVAILABLE ===",                             │
│          "linux-image-5.15.0-1023-gcp/focal-updates,focal-security",       │
│          "linux-headers-5.15.0-1023-gcp/focal-updates,focal-security",     │
│          "Total updates available: 15"                                     │
│      ]                                                                     │
│  }                                                                          │
│                                                                             │
│  TASK [Upgrade packages and capture details]                               │
│  changed: [ubuntu-vm-1]                                                    │
│                                                                             │
│  TASK [Display upgrade results]                                            │
│  ok: [ubuntu-vm-1] => {                                                    │
│      "msg": [                                                              │
│          "=== STARTING PACKAGE UPGRADE ===",                               │
│          "=== PACKAGES UPGRADED ===",                                      │
│          "linux-image-5.15.0-1023-gcp",                                    │
│          "linux-headers-5.15.0-1023-gcp",                                  │
│          "openssh-server",                                                 │
│          "... (12 more packages)"                                          │
│      ]                                                                     │
│  }                                                                          │
│                                                                             │
│  TASK [Display post-patch status]                                          │
│  ok: [ubuntu-vm-1] => {                                                    │
│      "msg": [                                                              │
│          "=== POST-PATCH STATUS ===",                                      │
│          "Updates remaining: 0",                                           │
│          "Status: FULLY PATCHED ✓"                                         │
│      ]                                                                     │
│  }                                                                          │
│                                                                             │
│  TASK [Reboot if required]                                                 │
│  changed: [ubuntu-vm-1]                                                    │
│                                                                             │
│  PLAY RECAP                                                                │
│  ubuntu-vm-1 : ok=12 changed=2 unreachable=0 failed=0 skipped=0           │
│  ═══════════════════════════════════════════════════════════════════════   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Job completion
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  STEP 8: Results & Audit Trail                                             │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  HCP Terraform:                                                             │
│  • Terraform Actions status: SUCCESS                                       │
│  • AAP job ID: 12345                                                       │
│  • Execution time: 8 minutes 32 seconds                                    │
│  • State updated with new VM metadata                                      │
│                                                                             │
│  AAP:                                                                       │
│  • Job status: Successful                                                  │
│  • VMs patched: 7/7                                                        │
│  • Packages upgraded: 105 total                                            │
│  • Reboots performed: 7                                                    │
│  • Full job output available                                               │
│                                                                             │
│  Audit Trail:                                                               │
│  • GitHub: Commit SHA, author, timestamp                                   │
│  • HCP Terraform: Run ID, plan/apply logs, state versions                 │
│  • Vault: Secret access logs, token usage                                 │
│  • GCP: Workload Identity token exchanges, VM events                       │
│  • AAP: Job execution logs, task output, timing                            │
│                                                                             │
│  Notifications:                                                             │
│  • Slack/Email: "7 VMs successfully patched"                               │
│  • Monitoring: Metrics updated, alerts cleared                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Security Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  CREDENTIAL FLOW: Zero Long-Lived Secrets                                  │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  1. GCP Authentication (Terraform)                                         │
│     ┌──────────────────────────────────────────────────────────────────┐  │
│     │ Vault KV Secret → GCP Service Account Key → Terraform Provider  │  │
│     │ • Stored encrypted in Vault                                      │  │
│     │ • Retrieved via VAULT_TOKEN (env var)                            │  │
│     │ • Used only during terraform apply                               │  │
│     │ • Never written to disk                                          │  │
│     └──────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  2. AAP Authentication (Terraform Actions)                                 │
│     ┌──────────────────────────────────────────────────────────────────┐  │
│     │ Vault KV Secret → AAP API Token → AAP API Call                  │  │
│     │ • Retrieved during terraform apply                               │  │
│     │ • Used to trigger job template                                   │  │
│     │ • Token scoped to specific job templates                         │  │
│     └──────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  3. GCP Authentication (AAP → GCP)                                         │
│     ┌──────────────────────────────────────────────────────────────────┐  │
│     │ AAP OIDC Token → Workload Identity Pool → GCP Access Token      │  │
│     │ • AAP generates OIDC token (signed JWT)                          │  │
│     │ • GCP validates token signature                                  │  │
│     │ • Issues 1-hour access token                                     │  │
│     │ • Token auto-renewed by AAP                                      │  │
│     │ • NO service account key needed                                  │  │
│     └──────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  4. SSH Authentication (AAP → VMs)                                         │
│     ┌──────────────────────────────────────────────────────────────────┐  │
│     │ Terraform-Generated SSH Key → OS Login → VM Access              │  │
│     │ • Private key in AAP credential                                  │  │
│     │ • Public key added to OS Login profile                           │  │
│     │ • IAM-based authorization (compute.osLogin)                      │  │
│     │ • No keys stored on VMs                                          │  │
│     └──────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  Security Benefits:                                                         │
│  ✅ No long-lived GCP credentials in AAP                                   │
│  ✅ No service account keys to rotate                                      │
│  ✅ Automatic token expiration (1 hour)                                    │
│  ✅ Complete audit trail of all authentications                            │
│  ✅ Centralized secret management in Vault                                 │
│  ✅ IAM-based SSH access (no key distribution)                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Error Handling & Recovery

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  FAILURE SCENARIOS & RECOVERY                                               │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  Scenario 1: Terraform Apply Fails                                         │
│  ────────────────────────────────────────────────────────────────────────  │
│  Cause: Invalid configuration, quota exceeded, API error                   │
│  Impact: No VMs created, no Terraform Actions triggered                    │
│  Recovery:                                                                  │
│    1. Review Terraform run logs in HCP Terraform                           │
│    2. Fix configuration error                                              │
│    3. Commit and push fix                                                  │
│    4. HCP Terraform auto-triggers new run                                  │
│  Prevention: terraform validate in CI/CD                                   │
│                                                                             │
│  Scenario 2: Vault Connection Fails                                        │
│  ────────────────────────────────────────────────────────────────────────  │
│  Cause: Invalid token, network issue, Vault unavailable                    │
│  Impact: Terraform cannot retrieve secrets, apply fails                    │
│  Recovery:                                                                  │
│    1. Verify VAULT_TOKEN in HCP Terraform workspace                        │
│    2. Check Vault cluster status                                           │
│    3. Verify network connectivity                                          │
│    4. Retry terraform apply                                                │
│  Prevention: Vault health checks, token expiration monitoring              │
│                                                                             │
│  Scenario 3: AAP Job Trigger Fails                                         │
│  ────────────────────────────────────────────────────────────────────────  │
│  Cause: Invalid job template ID, AAP unavailable, auth failure             │
│  Impact: VMs created but not patched                                       │
│  Recovery:                                                                  │
│    1. Check Terraform Actions logs                                         │
│    2. Verify aap_job_template_id is correct                                │
│    3. Manually trigger AAP job with same extra_vars                        │
│    4. Or: terraform apply -replace=terraform_data.trigger_patch            │
│  Prevention: AAP health checks, job template validation                    │
│                                                                             │
│  Scenario 4: SSH Connection Fails                                          │
│  ────────────────────────────────────────────────────────────────────────  │
│  Cause: Wrong username, key not in OS Login, firewall blocking             │
│  Impact: Ansible cannot connect to VMs, patching fails                     │
│  Recovery:                                                                  │
│    1. Verify ansible_user matches OS Login username                        │
│    2. Check SSH key in OS Login: gcloud compute os-login ssh-keys list    │
│    3. Verify firewall allows AAP IP                                        │
│    4. Test manual SSH: ssh username@vm-ip                                  │
│    5. Re-run AAP job after fixing                                          │
│  Prevention: Automated SSH key sync, firewall validation                   │
│                                                                             │
│  Scenario 5: Package Upgrade Fails                                         │
│  ────────────────────────────────────────────────────────────────────────  │
│  Cause: Broken package, dependency conflict, disk full                     │
│  Impact: Some VMs not fully patched                                        │
│  Recovery:                                                                  │
│    1. Review AAP job output for specific errors                            │
│    2. SSH to affected VM for manual troubleshooting                        │
│    3. Fix package issues (apt-get -f install)                              │
│    4. Re-run AAP job for failed VMs only                                   │
│  Prevention: Pre-patch validation, disk space monitoring                   │
│                                                                             │
│  Scenario 6: Reboot Hangs                                                  │
│  ────────────────────────────────────────────────────────────────────────  │
│  Cause: Kernel panic, hardware issue, boot config error                    │
│  Impact: VM unreachable after reboot, Ansible task times out               │
│  Recovery:                                                                  │
│    1. Check GCP Console for VM status                                      │
│    2. View serial console output for boot errors                           │
│    3. Reset VM via GCP Console if needed                                   │
│    4. Restore from snapshot if boot fails                                  │
│  Prevention: Snapshot before patching, boot validation tests               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Monitoring & Observability

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  OBSERVABILITY STACK                                                        │
│  ────────────────────────────────────────────────────────────────────────  │
│                                                                             │
│  1. HCP Terraform                                                           │
│     • Run status (success/failure)                                         │
│     • Resource changes (created/updated/destroyed)                         │
│     • Terraform Actions status                                             │
│     • State version history                                                │
│     • Cost estimates                                                       │
│                                                                             │
│  2. Vault Audit Logs                                                        │
│     • Secret access (who, when, what)                                      │
│     • Token usage and expiration                                           │
│     • Authentication attempts                                              │
│     • Policy violations                                                    │
│                                                                             │
│  3. GCP Cloud Logging                                                       │
│     • VM creation/deletion events                                          │
│     • Workload Identity token exchanges                                    │
│     • Firewall rule hits                                                   │
│     • OS Login authentication                                              │
│     • API calls and errors                                                 │
│                                                                             │
│  4. AAP Job Logs                                                            │
│     • Job execution status                                                 │
│     • Task-by-task output                                                  │
│     • Timing and performance                                               │
│     • Inventory and variables                                              │
│     • Error messages and stack traces                                      │
│                                                                             │
│  5. Ansible Playbook Output                                                 │
│     • Pre-patch status (available updates)                                 │
│     • Packages upgraded (detailed list)                                    │
│     • Post-patch status (remaining updates)                                │
│     • Reboot status and timing                                             │
│     • Task success/failure per VM                                          │
│                                                                             │
│  Recommended Additions (Production):                                        │
│  • Cloud Monitoring alerts (patch failures, budget)                        │
│  • Slack/PagerDuty notifications                                           │
│  • Grafana dashboards (patch success rate, timing)                         │
│  • Log aggregation (Splunk, ELK, Datadog)                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-27  
**Author:** Platform Engineering Team
