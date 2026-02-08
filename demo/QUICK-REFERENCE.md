# Security Patching Demo - Quick Reference Card

## Pre-Demo Checklist

- [ ] VMs are running (`terraform output vm_names`)
- [ ] AAP is accessible and job template is configured
- [ ] Vault credentials are valid
- [ ] SSH keys are working
- [ ] Vulnerable state is set up on VMs

## Demo Flow (15 minutes)

### 1. Show the Problem (3 min)
```bash
# Show vulnerability report
VM_IP=$(cd terraform && terraform output -json vm_external_ips | jq -r '.[0]')
ssh -i ~/.ssh/ubuntu-patching ubuntu@${VM_IP} "cat /tmp/vulnerability-report.txt"
```

### 2. Show the Solution (5 min)
```bash
# Show Terraform Actions config
cat terraform/actions.tf | grep -A 30 "action \"aap_job_launch\""
```

### 3. Trigger Patching (7 min)
```bash
# Option A: Automatic (via git push)
git add . && git commit -m "Trigger patching" && git push

# Option B: Manual
curl -k -X POST -H "Authorization: Bearer ${AAP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/tmp/aap_payload.json ${AAP_URL}
```

### 4. Show Results (3 min)
- Open AAP UI → Views → Jobs
- Show real-time output
- Highlight compliance report

## Key Talking Points

1. **Unified Workflow**: Same tool for Day 0 and Day 2
2. **Automation**: No manual intervention
3. **Security**: Credentials in Vault, not code
4. **Compliance**: Automated reporting
5. **Scalability**: 2 VMs or 2000 VMs

## Emergency Commands

### If SSH fails:
```bash
# Check firewall
terraform show | grep google_compute_firewall -A 10
```

### If no updates available:
```bash
# Re-run vulnerable state setup
ssh ubuntu@${VM_IP} "sudo bash /tmp/setup-vulnerable-state.sh"
```

### If AAP job fails:
```bash
# Check AAP connectivity
curl -k -H "Authorization: Bearer ${AAP_TOKEN}" \
  https://your-aap-instance.com/api/v2/me/
```

## Post-Demo Cleanup

```bash
# Restore normal state
for VM_IP in $VM_IPS; do
    ssh ubuntu@${VM_IP} "sudo bash /tmp/restore-normal-state.sh"
done
```

## URLs to Have Ready

- HCP Terraform: https://app.terraform.io/app/rahul-tfc/workspaces/tf-actions-aap-gcp
- AAP UI: https://your-aap-instance.com
- GitHub Repo: https://github.com/dr-rahulgaikwad/tf-actions-aap-gcp

## Backup Slides

Have these ready in case of technical issues:
1. Architecture diagram
2. Before/After comparison
3. ROI metrics (time saved, consistency, compliance)
