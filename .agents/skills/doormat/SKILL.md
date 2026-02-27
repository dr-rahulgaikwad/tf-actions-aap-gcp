---
name: doormat
description: Work with Doormat CLI for authentication and accessing HashiCorp cloud resources (AWS, Artifactory, sessions)
---

# Doormat CLI

Doormat is HashiCorp's interactive CLI tool for accessing cloud platforms and internal services securely. It provides temporary credentials for AWS, Artifactory, and remote sessions.

## What is Doormat?

Doormat provides:
- **Authentication** - Secure Okta-based authentication
- **AWS Credentials** - Temporary AWS credentials for HashiCorp accounts
- **Artifactory Tokens** - Temporary tokens for accessing HashiCorp's Artifactory
- **Remote Sessions** - SSH/SSM access to remote servers
- **Time-limited** - Credentials expire after 12 hours for security

**Key Security Features:**
- IP-locked credentials (valid only from the IP where generated)
- 12-hour expiration
- Okta authentication required
- Audit logging for compliance

## Installation

### macOS (via Homebrew)
```bash
brew tap hashicorp/security git@github.com:hashicorp/homebrew-security.git
brew install hashicorp/security/doormat-cli
```

**If using GitHub PAT instead of SSH:**
```bash
git config --global url."https://github.com/hashicorp".insteadOf git@github.com:hashicorp
brew tap hashicorp/security git@github.com:hashicorp/homebrew-security.git
brew install hashicorp/security/doormat-cli
```

### Upgrade
```bash
brew update
brew upgrade doormat-cli
```

### Linux/Windows
Download from [doormat-cli releases](https://github.com/hashicorp/doormat-cli/releases/)

## Core Commands

### Authentication

#### Login to Doormat
```bash
doormat login
```

This opens your browser for Okta authentication. Credentials are valid for **12 hours** and **locked to your current IP address**.

**When to re-login:**
- After 12 hours (credentials expire)
- After changing IP/network (credentials are IP-locked)
- When you see "unauthorized response; please reauthenticate" errors

#### Check Login Status
```bash
doormat login --validate
```

Shows when your session expires:
```
INFO[0001] session expires on 2026-01-14 23:03:11 -0800 PST
```

#### Force Fresh Login
```bash
doormat login --force
```

Generates new credentials even if you're already logged in.

### Artifactory (For Atlas Development)

#### Get Artifactory Token
```bash
doormat artifactory create-token
```

Returns JSON with access token:
```json
{
  "access_token": "eyJ...",
  "expires_in": 43200,
  "scope": "applied-permissions/user",
  "token_type": "Bearer"
}
```

**Common Usage in Atlas:**
```bash
# For Bundler (Ruby gems)
export BUNDLE_ARTIFACTORY__HASHICORP__ENGINEERING="your_email%40hashicorp.com:$(doormat artifactory create-token | jq -r '.access_token')"

# For Docker (already configured if you ran onboard)
# Docker uses docker-credential-doormat automatically
```

**Token Lifetime:** 12 hours (matches Doormat session)

### AWS Credentials

#### List Available AWS Accounts
```bash
doormat aws -l
doormat aws --list
```

Shows all AWS accounts you have access to.

#### Get AWS Credentials (Export to Environment)
```bash
# Export for current shell
doormat aws export -a <account-name> -r <role-arn>

# Example
doormat aws export -a prod -r arn:aws:iam::123456789012:role/MyRole

# Then use with AWS CLI
aws s3 ls
```

#### Open AWS Console in Browser
```bash
doormat aws console -a <account-name> -r <role-arn>

# Example
doormat aws console -a staging -r arn:aws:iam::123456789012:role/Admin
```

#### Get AWS Credentials as JSON
```bash
doormat aws json -a <account-name> -r <role-arn>
```

Returns:
```json
{
  "access_key_id": "ASIA...",
  "secret_access_key": "...",
  "session_token": "...",
  "expiration": "2026-01-14T23:00:00Z"
}
```

#### Manage AWS Credentials File
```bash
# Add credentials to ~/.aws/credentials
doormat aws cred-file -a <account-name> -r <role-arn>

# Add to AWS config file
doormat aws config-file -a <account-name> -r <role-arn>
```

#### Push AWS Creds to Terraform Cloud/Enterprise
```bash
doormat aws tf-push \
  -a <account-name> \
  -r <role-arn> \
  --tf-organization <org-name> \
  --tf-workspace <workspace-name>
```

### Remote Sessions

#### SSH into a Server
```bash
doormat session -n <server-name>

# Example
doormat session -n prod-web-01
```

#### Get Your Login IP
```bash
doormat login get-ip
```

Shows the IP address your credentials are locked to. Useful for debugging authentication issues.

## Common Issues & Troubleshooting

### "unauthorized response; please reauthenticate"

**Causes:**
1. Credentials expired (12+ hours old)
2. IP address changed (switched networks, VPN toggled)
3. Never logged in

**Solution:**
```bash
doormat login
```

### "Bad username or password for artifactory.hashicorp.engineering"

**Causes:**
1. Doormat session expired
2. Wrong email format in BUNDLE_ARTIFACTORY variable

**Solution:**
```bash
# Re-authenticate
doormat login

# Regenerate Artifactory token with correct email
export BUNDLE_ARTIFACTORY__HASHICORP__ENGINEERING="your_email%40hashicorp.com:$(doormat artifactory create-token | jq -r '.access_token')"
```

**CRITICAL:** Use your actual HashiCorp email (e.g., `pthrasher@hashicorp.com`), NOT your username.

### IP Address Changed

If you switched networks or toggled VPN:
```bash
# Check current IP lock
doormat login get-ip

# Re-authenticate from new IP
doormat login --force
```

### Session Expired

Check expiration:
```bash
doormat login --validate
```

If expired or close to expiring:
```bash
doormat login --force
```

### doormat login Hangs on Browser

**On macOS:** Try specifying a browser:
```bash
export DOORMAT_URL_HANDLER_ARGS="-b com.google.Chrome"
doormat login
```

**On WSL:** Install wslutils to proxy browser opening:
```bash
sudo apt install xdg-utils
# Install wslutils from https://github.com/wslutilities/wslu
```

### Check Version
```bash
doormat --version
```

### Update Doormat
```bash
doormat update

# Or via Homebrew
brew upgrade doormat-cli
```

## Atlas Development Workflows

### Daily Startup (with atlasdev)
```bash
# 1. Check doormat status
doormat login --validate

# 2. If expired or close to expiring
doormat login

# 3. Start Atlas
cd $ATLAS_DIR
eval $(atlasdev env --export)
docker compose up -d
```

**Note:** `atlasdev env` automatically fetches fresh Artifactory tokens, so you don't need to manually set BUNDLE_ARTIFACTORY.

### Daily Startup (with tfcdev)
```bash
# 1. Authenticate
doormat login

# 2. Set Bundler credentials
export BUNDLE_ARTIFACTORY__HASHICORP__ENGINEERING="your_email%40hashicorp.com:$(doormat artifactory create-token | jq -r '.access_token')"

# 3. Start Atlas
eval "$(tfcdev rc)"
tfcdev stack up
```

### Refreshing Expired Session Mid-Work
```bash
# 1. Re-authenticate
doormat login

# 2. Refresh environment
eval $(atlasdev env --export --ignore-cache)

# 3. Restart services if needed
docker compose restart
```

### Accessing AWS for Cost Estimation Testing
```bash
# List accounts
doormat aws -l

# Get credentials for cost estimation test account
doormat aws export -a cost_est_test -r arn:aws:iam::ACCOUNT_ID:role/tfe-local

# Verify
aws sts get-caller-identity
```

## Best Practices

### 1. Proactive Re-authentication
Re-login **before** your session expires to avoid interruptions:
```bash
# Check expiration
doormat login --validate

# If < 1 hour remaining, re-login
doormat login --force
```

### 2. Add to Shell Profile
Add to `~/.zshrc` or `~/.bashrc`:
```bash
# Check doormat status on shell startup
doormat login --validate 2>/dev/null || echo "⚠️  Doormat session expired - run 'doormat login'"
```

### 3. Alias Common Commands
```bash
# Add to shell profile
alias dm='doormat'
alias dml='doormat login'
alias dmlv='doormat login --validate'
alias dmart='doormat artifactory create-token | jq -r ".access_token"'
```

### 4. Keep Doormat Updated
```bash
# Check for updates weekly
doormat update

# Or via Homebrew
brew upgrade doormat-cli
```

### 5. Document Your AWS Roles
Keep a list of AWS roles you commonly use:
```bash
# Cost estimation testing
doormat aws export -a cost_est_test -r arn:aws:iam::ACCOUNT_ID:role/tfe-local

# Production read-only
doormat aws console -a prod -r arn:aws:iam::ACCOUNT_ID:role/ReadOnly
```

## Security Notes

### Credentials are IP-Locked
Your Doormat credentials only work from the IP address where they were generated:
- **Home → Office:** Need to re-run `doormat login`
- **Toggle VPN:** Need to re-run `doormat login`
- **Change WiFi network:** Need to re-run `doormat login`

This is a security feature to prevent credential theft.

### 12-Hour Expiration
All Doormat credentials expire after 12 hours:
- Artifactory tokens: 12 hours
- AWS credentials: Varies (typically 1 hour)
- Doormat session: 12 hours

**Plan accordingly:**
- Long-running jobs may need credential refresh
- Set calendar reminders for long work sessions

### Never Share Credentials
- Don't share Artifactory tokens
- Don't share AWS credentials
- Don't commit tokens to git
- Don't send tokens in Slack

Use Doormat to generate credentials for each person individually.

## Getting Help

- **Slack:** `#auth-help` for authentication issues
- **Documentation:** https://docs.prod.secops.hashicorp.services/doormat/cli/
- **Help Command:** `doormat --help` or `doormat <command> --help`

## Summary

**Most Common Commands:**
```bash
# Authentication (do this first, every 12 hours)
doormat login

# Check if logged in
doormat login --validate

# Get Artifactory token for Ruby/Docker
doormat artifactory create-token

# List AWS accounts
doormat aws -l

# Get AWS credentials
doormat aws export -a <account> -r <role>

# Open AWS console
doormat aws console -a <account> -r <role>
```

**Remember:**
- Re-login every 12 hours
- Re-login when changing networks/IP
- Use your full HashiCorp email, not username
- Credentials are automatically used by `atlasdev` and `tfcdev`
