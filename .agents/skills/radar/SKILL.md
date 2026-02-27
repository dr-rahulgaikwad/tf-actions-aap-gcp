---
name: radar
description: HCP Vault Radar for automated secrets detection, PII scanning, and remediation across development workflows
---

# HCP Vault Radar

This skill covers HCP Vault Radar, HashiCorp's security automation tool for detecting and remediating unmanaged secrets, PII, and non-inclusive language across your development lifecycle.

## When to Use This Skill

Use this skill when you need to:
- Detect leaked secrets in code repositories and git history
- Scan for personally identifiable information (PII) in source code
- Identify and remediate unmanaged secrets before they reach production
- Monitor pull requests for sensitive data
- Integrate secrets scanning into CI/CD pipelines
- Triage and prioritize secret remediation efforts
- Prevent secret sprawl across development environments
- Scan non-inclusive language in codebases

## What is HCP Vault Radar?

**HCP Vault Radar is HashiCorp's security automation tool** that automates the detection and identification of unmanaged secrets in your code so that security teams can take appropriate actions to remediate issues.

### Origin

HCP Vault Radar is built from HashiCorp's acquisition of **BluBracket** in June 2023. BluBracket specialized in scanning, identifying, and remediating secrets inadvertently stored in source code, development environments, internal wikis, chat services, and ticketing systems.

### Core Purpose

Vault Radar reduces risk by finding and preventing leaked secrets in:
- Code repositories (GitHub, GitLab, Bitbucket, Azure DevOps)
- Collaboration tools (Slack, Confluence, Jira)
- CI/CD platforms
- Local development environments
- Cloud storage (Amazon S3)
- Infrastructure as Code (Terraform)
- Container images (Docker)

### Why Vault Radar?

**The Problem:**
- Developers accidentally commit secrets to version control
- Secrets leak into git history and remain accessible
- PII ends up in code repositories creating compliance risks
- Hard to distinguish between active and inactive credentials
- Manual secret scanning doesn't scale
- Secrets spread across multiple tools and platforms

**Vault Radar's Solution:**
- **Automated Scanning** - Continuous monitoring of repositories and pull requests
- **Git History Scanning** - Deep scans identify secrets throughout git history
- **Active Secret Detection** - Identifies which secrets are still active
- **Multi-Platform Support** - Scans cloud and on-premises data sources
- **Prioritized Remediation** - Helps teams focus on highest-risk secrets
- **Prevention** - Catches secrets before they're committed

## Key Features

| Feature | Description |
| --- | --- |
| **Secrets Detection** | Find passwords, API keys, tokens, certificates |
| **PII Scanning** | Identify personally identifiable information |
| **Non-Inclusive Language** | Flag problematic language in code |
| **Git History Scanning** | Deep scans of entire repository history |
| **Active Secret Detection** | Distinguish active vs inactive credentials |
| **PR Monitoring** | Scan pull requests before merge |
| **Multi-Source Support** | GitHub, GitLab, Bitbucket, Azure DevOps, S3, Docker |
| **Ticketing Integration** | Create tickets for remediation workflows |

## Installation & Setup

### Prerequisites

- HCP account with appropriate permissions
- Access to HCP Portal
- Source code management (SCM) system credentials
- Network access to data sources

### Access HCP Vault Radar

**Via HCP Portal:**
```
1. Log into HCP Portal (https://portal.cloud.hashicorp.com)
2. Navigate to Vault Radar
3. Create or select your organization
```

**Verify Access:**
- Ensure you have proper IAM permissions in HCP
- Check that your organization has Vault Radar enabled

### Install Vault Radar Agent (Optional)

The Vault Radar agent enables scanning of on-premises data sources not accessible by the cloud scanner, and supports correlation between secrets found by Vault Radar and secrets stored in Vault Enterprise. The agent is built into the `vault-radar` CLI binary — there is no separate agent binary.

**Prerequisites:**
- `vault-radar` CLI installed (see [Vault Radar CLI](#vault-radar-cli) section below)
- `git` installed on the host machine
- HCP service principal with the **Vault Radar Agent** role

**Step 1: Create a Service Principal**

Create a project-level service principal with the **Vault Radar Agent** role in HCP, generate a key, then export the credentials:

```bash
export HCP_CLIENT_ID=<your-client-id>
export HCP_CLIENT_SECRET=<your-client-secret>
```

**Step 2: Create an Agent Pool in HCP Portal**

```
HCP Portal → Vault Radar → Settings → Agent → Add an agent pool
```

Copy the pool ID and project ID from the final page, then export them:

```bash
export HCP_RADAR_AGENT_POOL_ID=<your-pool-id>
export HCP_PROJECT_ID=<your-project-id>
```

**Step 3: Connect a Data Source**

Configure the data source through the HCP Portal:

```
HCP Portal → Vault Radar → Settings → Data Sources → Add data source → Agent scan
```

For GitHub data sources, generate a GitHub PAT and set it as an environment variable in the environment where the Vault Radar agent runs (for example, `VAULT_RADAR_GIT_TOKEN` in your host, container, or pod). In the HCP Portal, when prompted for credentials, enter the URI `env://VAULT_RADAR_GIT_TOKEN` to tell Vault Radar to read the token from that environment variable on the agent.

**Step 4: Run the Agent**

#### Kubernetes (Helm — recommended)

Deploy the agent to Kubernetes using the official [vault-radar-agent-helm](https://github.com/hashicorp/vault-radar-agent-helm) Helm chart. See the [Helm chart README](https://github.com/hashicorp/vault-radar-agent-helm/blob/main/README.md) for full details including advanced configuration, multiple workers, and RBAC setup.

```bash
helm upgrade --install \
  --create-namespace \
  --namespace vault-radar \
  --set env.normal.HCP_PROJECT_ID=$HCP_PROJECT_ID \
  --set env.normal.HCP_RADAR_AGENT_POOL_ID=$HCP_RADAR_AGENT_POOL_ID \
  --set env.normal.HCP_CLIENT_ID=$HCP_CLIENT_ID \
  --set env.secrets.HCP_CLIENT_SECRET=$HCP_CLIENT_SECRET \
  --set env.secrets.VAULT_RADAR_GIT_TOKEN=$VAULT_RADAR_GIT_TOKEN \
  vault-radar-agent hashicorp/vault-radar-agent
```

> `VAULT_RADAR_GIT_TOKEN` is a PAT with read access to the target repositories (for BitBucket/Azure DevOps use `<username>:<PAT>`).

#### Linux (direct)

With all four environment variables set, run:

```bash
vault-radar agent exec
```

The agent runs in the foreground and logs to `stderr`.

## Vault Radar CLI

The `vault-radar` CLI scans a variety of data sources for unmanaged secrets directly from the command line. Requires version 0.17.0 or higher.

### Installation

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap
brew install vault-radar
```

**Linux (apt):**
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault-radar -y
```

**Linux (yum/rpm):**
```bash
curl -fsSL https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo | sudo tee /etc/yum.repos.d/hashicorp.repo
sudo yum update && sudo yum install vault-radar -y
```

**Docker:**
```bash
export VAULT_RADAR_VERSION=0.17.0
docker pull hashicorp/vault-radar:${VAULT_RADAR_VERSION}
docker run --rm hashicorp/vault-radar:${VAULT_RADAR_VERSION} vault-radar --help
```

**Verify installation:**
```bash
vault-radar --help
```

### Authentication & Configuration

Most scan commands require a connection to HCP. Set these environment variables from your HCP project:

```bash
export HCP_PROJECT_ID=<your-project-id>
export HCP_CLIENT_ID=<your-client-id>
export HCP_CLIENT_SECRET=<your-client-secret>
```

The CLI also requires access to `api.cloud.hashicorp.com` and `auth.idp.hashicorp.com`. Ensure your network allows these.

**Dependencies:**
- `git` — required for `scan repo` and `scan confluence` commands
- Docker engine — required for `scan docker-image` command

### Base Usage

```
Usage: vault-radar [--version] [--help] <command> [<args>]

Available commands are:
    agent      Agent management
    govern     Govern commands
    index      Index commands
    install    Install commands
    meter      Meter commands
    scan       Scan commands
    version    Shows the vault-radar cli version and golang version
```

Run `vault-radar` with no arguments to see available commands. Use `-h` on any subcommand for detailed help:

```bash
vault-radar scan repo -h
```

### Scanning a Git Repository (`scan repo`)

The `scan repo` command scans a git repository for secrets throughout its commit history.

**Clone and scan a remote repo:**
```bash
# Set a git token for private repos
export VAULT_RADAR_GIT_TOKEN=<github-pat>

# Clone and scan all commits, upload results to HCP
vault-radar scan repo -u https://github.com/myorg/myrepo

# Scan and write results to a local CSV file
vault-radar scan repo -u https://github.com/myorg/myrepo -o results.csv

# Scan and output JSON
vault-radar scan repo -u https://github.com/myorg/myrepo -o results.jsonl -f json
```

**Scan an existing local clone:**
```bash
vault-radar scan repo -c /path/to/local/clone -o results.csv
```

**Incremental scanning with a baseline (only report new secrets):**
```bash
vault-radar scan repo -u https://github.com/myorg/myrepo \
  -b previous-results.csv \
  -o new-results.csv
```

**Limit the scan scope:**
```bash
# Stop after finding 10 secrets
vault-radar scan repo -u https://github.com/myorg/myrepo -l 10

# Scan only the last 100 commits
vault-radar scan repo -u https://github.com/myorg/myrepo --commit-limit 100
```

**Correlate with Vault (requires an index file):**
```bash
vault-radar scan repo -u https://github.com/myorg/myrepo \
  --index-file vault-index.jsonl
```

### Global Flags

| Flag | Description |
| --- | --- |
| `--disable-ui` | Suppress progress/summary output to stdout — useful in CI/CD pipelines |
| `--index-file` | Path to a Vault index file; marks secrets that are already managed in Vault |
| `--limit, -l` | Stop scanning after reporting this many secrets |
| `--format, -f` | Output format: `csv` (default), `json`, or `sarif` |
| `--outfile, -o` | File path for scan results |
| `--baseline, -b` | Previous scan results file; only new secrets are reported |

**Log level** can be configured via the `VAULT_RADAR_LOG_LEVEL` environment variable (`trace`, `debug`, `info`, `warn`, `error`; default: `info`).

## Common Workflows

### Workflow 1: Connect GitHub Repository for Scanning

**Scenario:** Scan a GitHub repository for secrets

1. **Navigate to Data Sources:**
   ```
   HCP Portal → Vault Radar → Data Sources → Add Data Source
   ```

2. **Select GitHub:**
   - Choose GitHub as the data source type
   - Authenticate with GitHub OAuth or personal access token
   - Grant required permissions (read repository, read pull requests)

3. **Select Repositories:**
   - Choose organization or user account
   - Select specific repositories to scan
   - Or select all repositories

4. **Initiate Scan:**
   - Vault Radar performs initial scan automatically
   - Review scan results in the Events dashboard

### Workflow 2: Review and Remediate Secrets

**Scenario:** Triage and fix discovered secrets

1. **View Events:**
   ```
   HCP Portal → Vault Radar → Events
   ```

2. **Filter and Prioritize:**
   ```
   - Filter by: Active secrets, Secret type, Repository, Severity
   - Sort by: Risk score, Date found, Repository
   - Focus on active secrets first (highest risk)
   ```

3. **Investigate Risks:**
   ```
   - Click on event to view details
   - Review: File path, Line number, Git commit, Secret type
   - Check if secret is active or inactive
   - View affected branches
   ```

4. **Remediate:**

   **For Active Secrets:**
   ```bash
   # 1. Rotate the secret immediately
   # In the service that uses the secret

   # 2. Remove from code
   git rm <file-with-secret>
   # Or edit file to remove secret

   # 3. Add to .gitignore if it's a file
   echo "config/secrets.yml" >> .gitignore

   # 4. Use Vault to manage the secret instead
   vault kv put secret/myapp/api-key value="<new-rotated-key>"

   # 5. Update application to read from Vault
   # (See /vault skill for integration examples)
   ```

   **Remove from Git History:**
   ```bash
   # Use git filter-branch or BFG Repo-Cleaner
   # WARNING: This rewrites history

   # Using BFG (recommended)
   bfg --replace-text passwords.txt repo.git

   # Or git filter-branch
   git filter-branch --tree-filter 'rm -f config/secrets.yml' HEAD

   # Force push (coordinate with team!)
   git push origin --force --all
   ```

5. **Mark as Resolved:**
   - In Vault Radar UI, mark event as resolved
   - Add notes about remediation steps taken
   - Link to ticket if using ticketing integration

### Workflow 3: Set Up Pull Request Scanning

**Scenario:** Prevent secrets from being committed

1. **Enable PR Scanning:**
   ```
   HCP Portal → Vault Radar → Data Sources → <Your Repo>
   Settings → Enable Pull Request Scanning
   ```

2. **Configure PR Checks:**
   - Block merge on secret detection (recommended)
   - Or warn but allow merge
   - Set notification channels

3. **Configure GitHub Branch Protection:**
   ```
   GitHub → Repository → Settings → Branches
   Add rule for main/master branch
   Enable: Require status checks to pass before merging
   Select: HCP Vault Radar scan
   ```

4. **Test PR Scanning:**
   ```bash
   # Create test branch
   git checkout -b test-radar-scanning

   # Add file with test secret
   echo "api_key=sk_test_1234567890" > test-secret.txt
   git add test-secret.txt
   git commit -m "Test Radar scanning"
   git push origin test-radar-scanning

   # Create PR
   gh pr create --title "Test PR scanning"

   # Check PR status - should show Vault Radar events
   ```

5. **Workflow for Developers:**
   ```
   When PR fails Vault Radar check:
   1. Review findings in PR comments
   2. Remove secrets from code
   3. Add secrets to Vault instead
   4. Update code to read from Vault
   5. Push changes
   6. Radar re-scans automatically
   ```

### Workflow 4: Local Development Protection

Vault Radar offers two approaches to catch secrets before they leave your machine.

#### Option A: Pre-commit Hook

**Scenario:** Automatically block commits that contain secrets.

The `vault-radar` CLI can install itself as a git pre-commit hook. When you commit, it scans the diff and rejects the commit if secrets above the configured severity threshold are found.

1. **Install the pre-commit hook** (run from inside your git repo):
   ```bash
   vault-radar install git pre-commit-hook
   ```

   This adds a `vault-radar scan git pre-commit` call to the repo's existing pre-commit script without overwriting other hooks.

2. **Configure the fail threshold** (optional):

   Create `.hashicorp/vault-radar/config.json` in the repo root (per-repo) or `~/.hashicorp/vault-radar/config.json` (global):
   ```json
   {
     "fail_severity": "high"
   }
   ```

   Valid severity values: `low`, `medium`, `high`, `critical`. If not set, all detected risks are allowed through (no blocking).

3. **When a commit is rejected:**
   - Review the detected risks in the terminal output
   - Remove or replace the secret, or add an inline or custom ignore rule
   - Re-attempt the commit

   To run the scan manually outside of a commit:
   ```bash
   vault-radar scan git pre-commit
   ```

> **Note:** This command requires a valid `vault-radar` license configured via `VAULT_RADAR_LICENSE` environment variable or a license file.

#### Option B: VS Code IDE Extension

**Scenario:** See secrets highlighted in your editor as you type, before you even commit.

The HCP Vault Radar extension for VS Code automatically scans files when you open or save them and highlights secrets inline.

1. **Install the extension:**
   - Open VS Code and click the Extensions icon in the Activity Bar
   - Search for `HCP Vault Radar`
   - Click **Install**

2. **Set the license key** (choose one method):

   *Interactively:*
   ```
   When prompted, click "Set license key" and paste the key, then restart VS Code.
   ```

   *Via environment variable (recommended for automation):*
   ```bash
   export VAULT_RADAR_LICENSE="<your-license-key>"
   source ~/.zshrc   # or equivalent for your shell
   code              # launch VS Code from the shell to inherit the variable
   ```

3. **Optional: Integrate with HashiCorp Vault**

   The extension can correlate secrets it finds in your source code with secrets already stored in a Vault cluster:
   - Click the HCP Vault Radar icon in the Activity Bar
   - Click **Add Vault Connection**
   - Enter a nickname, the Vault cluster address, optional namespace, and choose an auth method (Token, AppRole, or OIDC)

   Once connected, the extension indexes Vault and marks any detected secrets that are already stored there.

4. **Re-index Vault** at any time via the command palette:
   ```
   > Vault Radar: Index Vault
   ```

### Workflow 5: Set Up Ticketing Integration

**Scenario:** Create Jira tickets for secret findings

1. **Configure Integration:**
   ```
   HCP Portal → Vault Radar → Settings → Integrations
   Add Integration → Jira
   ```

2. **Provide Jira Credentials:**
   ```
   - Jira URL: https://yourcompany.atlassian.net
   - Email: your-email@company.com
   - API Token: <jira-api-token>
   ```

3. **Map Fields:**
   ```
   - Project: SECURITY
   - Issue Type: Security Vulnerability
   - Priority Mapping:
     - Critical → Highest
     - High → High
     - Medium → Medium
     - Low → Low
   ```

4. **Configure Ticket Creation Rules:**
   ```
   Create ticket when:
   - New active secret found
   - Secret severity >= High
   - Secret in production branch
   ```

5. **Test Integration:**
   ```
   Trigger test finding → Check Jira for created ticket
   Verify ticket contains:
   - Secret type
   - Repository and file path
   - Risk level
   - Remediation guidance
   ```

## Scanning Capabilities

### Supported Data Sources

**Source Code Management:**
- GitHub (Cloud and Enterprise)
- GitLab (Cloud and Self-Managed)
- Bitbucket (Cloud and Server)
- Azure DevOps

**Storage:**
- Amazon S3
- Local filesystem
- Docker containers

**Infrastructure as Code:**
- Terraform Cloud/Enterprise
- Terraform state files

**Collaboration Tools (via agent):**
- Slack
- Confluence
- Jira

### Types of Findings

**Secrets:**
- API keys and tokens
- Database credentials
- Private keys and certificates
- OAuth tokens
- Cloud provider credentials (AWS, Azure, GCP)
- HashiCorp Vault tokens
- CI/CD secrets

**Personally Identifiable Information (PII):**
- Social Security Numbers
- Credit card numbers
- Email addresses
- Phone numbers
- Passport numbers
- Driver's license numbers

**Non-Inclusive Language:**
- Terms flagged for diversity and inclusion
- Alternative suggestions provided

### Scan Triggers

**Automatic Scans:**
- Initial repository connection
- New commits pushed to monitored branches
- Pull request creation or updates
- Scheduled scans (configurable)

**Manual Scans:**
- On-demand repository scan
- CLI-based local scans
- Agent-triggered scans

## Best Practices

### Prevention

**Pre-commit Scanning:**
- Use Vault Radar CLI locally before committing
- Add pre-commit hooks to scan changes
- Educate developers on secret management

**PR Scanning:**
- Enable PR scanning on all repositories
- Block merges when secrets detected
- Require Vault Radar status check

**Use Vault for Secrets:**
- Never commit secrets to version control
- Store secrets in HashiCorp Vault
- Use dynamic secrets when possible
- Rotate secrets regularly

### Detection

**Comprehensive Scanning:**
- Enable git history scanning (deeper but slower)
- Scan all branches, not just main
- Don't exclude old or archived repositories
- Scan documentation repositories too

**Active Secret Prioritization:**
- Focus remediation on active secrets first
- Use risk scoring to prioritize
- Check if secret has access to production

### Remediation

**Secret Rotation:**
- Rotate secrets immediately upon detection
- Don't just remove from code - rotate the actual credential
- Update applications to use new credentials
- Revoke old credentials

**Git History Cleanup:**
- Remove secrets from git history (rewrites history)
- Coordinate with team before force pushing
- Consider if history rewrite is necessary (vs just rotation)
- Use BFG Repo-Cleaner or git filter-branch

**Documentation:**
- Document remediation steps taken
- Share learnings with team
- Update runbooks and procedures

### Integration

**Ticketing Systems:**
- Integrate with Jira, ServiceNow, or GitHub Issues
- Automate ticket creation for findings
- Track remediation progress
- Set SLAs for secret remediation

**Alerting:**
- Configure Slack/email notifications
- Alert security team for critical findings
- Escalate active secrets in production

**Metrics:**
- Track mean time to remediation
- Monitor secret sprawl over time
- Measure effectiveness of prevention efforts

## Troubleshooting

### Issue 1: Repository Not Scanning

**Symptoms:**
- Repository connected but no scan results
- Scan status shows "pending" indefinitely

**Cause:**
- Insufficient permissions
- Network connectivity issues
- Repository too large

**Solution:**
```
1. Check SCM permissions
   - Vault Radar needs read access to repository
   - Check OAuth token or PAT permissions

2. Check repository size
   - Very large repos may timeout
   - Consider excluding large binary files

3. Review scan logs
   HCP Portal → Vault Radar → Scan History → View Logs

4. Re-trigger scan
   Data Sources → <Repository> → Scan Now
```

### Issue 2: False Positives

**Symptoms:**
- Secrets detected that aren't actually secrets
- Test data flagged as PII
- Example code flagged as secrets

**Cause:**
- Detection patterns too broad
- Test fixtures containing example secrets
- Documentation with example credentials

**Solution:**
```
1. Mark as false positive in UI
   - Helps improve detection algorithm

2. Use exclusion patterns
   Settings → Exclusions → Add Pattern
   Example: tests/fixtures/*.json

3. Use allowlist for known false positives
   - Document why it's safe

4. Update .gitignore to exclude test data
```

### Issue 3: Git History Scan Taking Too Long

**Symptoms:**
- History scan runs for hours or days
- Scan appears stuck

**Cause:**
- Large repository with extensive history
- Many branches and commits

**Solution:**
```
1. Scan only recent history
   - Configure max depth in settings
   - Focus on last 12 months of commits

2. Exclude old branches
   - Only scan active development branches
   - Archive and exclude obsolete branches

3. Use incremental scanning
   - Scan new commits only
   - Periodic deep scans (quarterly)

4. Consider repository cleanup
   - Remove large binary files from history
   - Split monorepo into smaller repos
```

### Issue 4: Agent Not Reporting Findings

**Symptoms:**
- Agent running but no findings in HCP
- Agent scan logs show findings but UI doesn't

**Cause:**
- Agent not authenticated correctly (missing or wrong env vars)
- Network/firewall blocking HCP connection
- Agent version mismatch

**Solution:**
```bash
# Verify all required environment variables are set
echo $HCP_CLIENT_ID
echo $HCP_CLIENT_SECRET
echo $HCP_PROJECT_ID
echo $HCP_RADAR_AGENT_POOL_ID

# Check network connectivity to HCP
curl https://api.cloud.hashicorp.com

# Check agent logs (Kubernetes)
kubectl logs -n vault-radar <pod-name> -f

# Update the vault-radar CLI to latest version (macOS)
brew upgrade vault-radar

# Re-run the agent with debug logging
export VAULT_RADAR_LOG_LEVEL=debug
vault-radar agent exec
```

### Issue 5: PR Check Not Blocking Merge

**Symptoms:**
- PR with secrets can be merged
- Radar check passes even with findings

**Cause:**
- PR scanning not configured to block
- Branch protection not enforced
- GitHub app permissions insufficient

**Solution:**
```
1. Check Vault Radar PR settings
   Settings → PR Scanning → Block on Detection ✓

2. Verify GitHub branch protection
   GitHub → Settings → Branches → main
   ✓ Require status checks to pass
   ✓ Require HCP Vault Radar
   ✓ Include administrators

3. Check GitHub App permissions
   GitHub → Settings → Integrations → HCP Vault Radar
   Verify: Read/Write access to checks

4. Re-trigger PR check
   Comment on PR: /radar rescan
```

## Security Considerations

**Secret Handling:**
- Vault Radar scans but doesn't store full secret values
- Only fingerprints/hashes stored for matching
- Findings show partial secrets (masked)

**Permissions:**
- Use least-privilege access for SCM integrations
- Limit Vault Radar to read-only access where possible
- Audit Vault Radar access logs regularly

**Compliance:**
- Use PII scanning for GDPR/CCPA compliance
- Enable audit logging for compliance requirements
- Retain finding history for audits

**False Negatives:**
- No scanner is 100% accurate
- Still follow secure coding practices
- Don't rely solely on automated scanning
- Combine with code review and security training

## HashiCorp-Specific Tips

### Integration with HashiCorp Products

**Vault Integration:**
```
When Vault Radar finds secrets:
1. Rotate secret in source system
2. Store new secret in Vault
3. Update application to read from Vault
4. Use dynamic secrets when possible

See /vault skill for integration examples
```

**Terraform Integration:**
```bash
# Scan Terraform state files for secrets
vault-radar scan terraform \
  --state-file terraform.tfstate

# Scan Terraform Cloud workspaces
vault-radar scan terraform-cloud \
  --organization my-org \
  --workspace my-workspace
```

**HCP Integration:**
```
Vault Radar is part of HCP:
- Single sign-on with HCP account
- Shared IAM policies
- Integrated billing
- Cross-product insights (Vault + Radar)

See /hcp skill for platform details
```

### Common Use Cases at HashiCorp

**Pre-Production Scanning:**
- Scan feature branches before merge
- Automated in CI/CD pipelines
- Gate deployments on clean scan

**Compliance:**
- PII scanning for customer data protection
- Regular audits of repositories
- Remediation tracking for SOC 2

**Onboarding:**
- Scan newly acquired codebases
- Identify legacy secret sprawl
- Migration to Vault-managed secrets

## Additional Resources

- **Official Documentation**: https://developer.hashicorp.com/hcp/docs/vault-radar
- **Getting Started Tutorial**: https://developer.hashicorp.com/hcp/tutorials/get-started-hcp-vault-radar
- **Secret Scanning Guide**: https://developer.hashicorp.com/hcp/tutorials/get-started-hcp-vault-radar/vault-radar-secret-scanning
- **CLI Reference**: https://developer.hashicorp.com/hcp/docs/vault-radar/cli
- **Agent Overview**: https://developer.hashicorp.com/hcp/docs/vault-radar/agent
- **Agent Deployment**: https://developer.hashicorp.com/hcp/docs/vault-radar/agent/deploy
- **Pre-commit Hook**: https://developer.hashicorp.com/hcp/docs/vault-radar/cli/install/git
- **IDE Extension Overview**: https://developer.hashicorp.com/hcp/docs/vault-radar/ide
- **VS Code Extension Install**: https://developer.hashicorp.com/hcp/docs/vault-radar/ide/install/vscode
- **Product Page**: https://www.hashicorp.com/en/products/vault/hcp-vault-radar
- **HashiConf Announcement**: https://www.hashicorp.com/en/blog/new-hcp-vault-secrets-radar-and-other-features-fight-secrets-sprawl

## Summary

**Quick Start:**
```
1. Access HCP Portal (https://portal.cloud.hashicorp.com)
2. Navigate to Vault Radar
3. Add Data Source (GitHub/GitLab/etc.)
4. Authenticate and select repositories
5. Initial scan runs automatically
6. Review findings in dashboard
7. Remediate secrets and mark as resolved
```

**Most Common Commands (CLI):**
```bash
# Scan a remote git repository (clones and scans all history)
vault-radar scan repo -u https://github.com/myorg/myrepo -o results.csv

# Scan a local git repo clone
vault-radar scan repo -c /path/to/local/clone -o results.csv

# Scan with JSON output
vault-radar scan repo -u https://github.com/myorg/myrepo -o results.jsonl -f json

# Incremental scan (only report new secrets vs baseline)
vault-radar scan repo -u https://github.com/myorg/myrepo -b prev.csv -o new.csv

# Run the agent (on-premises data sources)
vault-radar agent exec

# Install pre-commit hook in current git repo
vault-radar install git pre-commit-hook
```

**Types of Scans:**
- **Repository Scan** - Scans connected Git repositories
- **PR Scan** - Scans pull requests before merge
- **History Scan** - Deep scan of entire git history
- **Local Scan** - CLI scan of local directories
- **Agent Scan** - On-premises data sources via agent

**Remediation Workflow:**
1. **Identify** - Review findings in HCP Portal
2. **Prioritize** - Focus on active secrets first
3. **Rotate** - Change the actual credential
4. **Remove** - Delete from code (and history if needed)
5. **Replace** - Use Vault for secret management
6. **Verify** - Re-scan to confirm fix
7. **Document** - Mark as resolved with notes

**Remember:**
- Enable PR scanning to prevent secrets from being committed
- Focus remediation on active secrets (highest risk)
- Rotate secrets immediately, don't just remove from code
- Use HashiCorp Vault for proper secrets management
- Scan git history for complete coverage
- Integrate with ticketing for tracking remediation
- Never commit secrets - use environment variables or Vault
- Test with your own repository before rolling out widely

## Sources

- [HCP Vault Radar Product Page](https://www.hashicorp.com/en/products/vault/hcp-vault-radar)
- [What is Vault Radar? | HashiCorp Developer](https://developer.hashicorp.com/hcp/docs/vault-radar)
- [Scan a repository for secrets with HCP Vault Radar](https://developer.hashicorp.com/hcp/tutorials/get-started-hcp-vault-radar/vault-radar-secret-scanning)
- [New HCP Vault Radar features fight secret sprawl](https://www.hashicorp.com/en/blog/new-hcp-vault-secrets-radar-and-other-features-fight-secrets-sprawl)
- [HashiCorp's HCP Vault Radar Achieves GA - InfoQ](https://www.infoq.com/news/2025/05/hcp-vault-radar-ga/)
