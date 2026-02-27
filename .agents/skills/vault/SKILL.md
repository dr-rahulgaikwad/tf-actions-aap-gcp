---
name: vault
description: HashiCorp Vault identity-based secrets and encryption management. Use when asked about secrets management, dynamic credentials, encryption-as-a-service, PKI certificates, database credentials, AWS/Azure/GCP credentials, auth methods (AppRole, Kubernetes, OIDC), policies, Vault Agent, SSH access, or troubleshooting Vault issues. Covers architecture, HA/DR, Enterprise features, and Kubernetes integration.
---

# HashiCorp Vault

Vault is HashiCorp's identity-based secret and encryption management system. This skill covers secrets storage, dynamic credential generation, encryption-as-a-service, authentication, policies, and operations.

---

## When to Use This Skill

- **Secrets management**: Store and retrieve API keys, passwords, certificates
- **Dynamic credentials**: Generate short-lived database, cloud, or service credentials
- **Encryption-as-a-service**: Encrypt/decrypt data via Transit engine
- **PKI/Certificates**: Issue TLS certificates from internal CA
- **Authentication**: Configure AppRole, Kubernetes, OIDC, AWS, LDAP auth
- **Policies**: Write fine-grained access control policies
- **Kubernetes integration**: VSO, Agent Injector, CSI Provider
- **Troubleshooting**: Diagnose seal, auth, permission, or performance issues
- **Architecture**: Design HA clusters, DR replication, namespaces

---

## Core Concepts

### How Vault Works

1. **Authenticate**: Clients verify identity via auth methods → receive token
2. **Authorize**: Token maps to policies defining allowed operations
3. **Access**: Token used to read/write secrets, all operations audited

### Key Components

| Component | Description |
| --------- | ----------- |
| **Secrets Engines** | Store or generate secrets (KV, Database, AWS, PKI, Transit) |
| **Auth Methods** | Verify identity (AppRole, Kubernetes, OIDC, AWS, LDAP) |
| **Policies** | Define access permissions in HCL |
| **Audit Devices** | Log all operations for compliance |
| **Namespaces** | Multi-tenant isolation (Enterprise) |

### Secrets Engine Types

| Type | Examples | Use Case |
| ---- | -------- | -------- |
| **Static** | KV v1/v2 | Store arbitrary secrets |
| **Dynamic** | Database, AWS, Azure, GCP | Generate on-demand credentials |
| **Encryption** | Transit | Encrypt/decrypt without storage |
| **PKI** | PKI | Issue TLS certificates |

→ See [references/secrets-engines.md](references/secrets-engines.md) for detailed configuration.

---

## Installation

### CLI Installation

```bash
# macOS
brew install vault

# Linux
wget https://releases.hashicorp.com/vault/<VERSION>/vault_<VERSION>_linux_amd64.zip
unzip vault_<VERSION>_linux_amd64.zip && sudo mv vault /usr/local/bin/

# Windows
choco install vault

# Verify
vault version
```

### Development Server

```bash
vault server -dev
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='<root-token>'
```

⚠️ Dev mode is **NOT** for production—data is in-memory only.

---

## Quick Reference Commands

### Authentication

```bash
vault status                    # Check Vault status
vault login                     # Interactive login
vault login -method=oidc        # OIDC/SSO login
vault token lookup              # View current token
vault token renew               # Renew token TTL
```

### KV Secrets (v2)

```bash
vault kv put secret/app key=value       # Write secret
vault kv get secret/app                 # Read secret
vault kv get -field=key secret/app      # Get specific field
vault kv list secret/                   # List secrets
vault kv delete secret/app              # Delete (soft)
vault kv undelete -versions=1 secret/app # Recover
```

### Dynamic Credentials

```bash
vault read database/creds/readonly      # Database credentials
vault read aws/creds/deploy             # AWS credentials
vault read pki_int/issue/web-servers common_name=web.example.com  # TLS cert
```

### CLI Policy Commands

```bash
vault policy write app-policy policy.hcl  # Create policy
vault policy list                          # List policies
vault policy read app-policy               # View policy
vault token capabilities secret/data/app   # Check permissions
```

### Leases

```bash
vault lease lookup <lease-id>           # Check lease
vault lease renew <lease-id>            # Renew lease
vault lease revoke <lease-id>           # Revoke lease
```

### CLI Operations Commands

```bash
vault operator unseal                   # Unseal Vault
vault operator seal                     # Seal Vault (emergency)
vault operator raft list-peers          # HA cluster status
vault audit enable file file_path=/var/log/vault.log  # Enable audit
```

---

## Authentication Methods

### AppRole (Applications/CI)

```bash
vault auth enable approle
vault write auth/approle/role/my-app \
    token_policies="app-policy" \
    token_ttl=1h \
    secret_id_ttl=10m

# Get credentials
vault read auth/approle/role/my-app/role-id
vault write -f auth/approle/role/my-app/secret-id

# Login
vault write auth/approle/login role_id="<role-id>" secret_id="<secret-id>"
```

### Kubernetes

```bash
vault auth enable kubernetes
vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc:443"

vault write auth/kubernetes/role/my-app \
    bound_service_account_names=my-app-sa \
    bound_service_account_namespaces=default \
    policies=app-policy \
    ttl=1h
```

→ See [references/auth-methods.md](references/auth-methods.md) for OIDC, AWS, Azure, GCP, LDAP.

---

## Secrets Engines

### Database Dynamic Credentials

```bash
vault secrets enable database

vault write database/config/postgres \
    plugin_name=postgresql-database-plugin \
    connection_url="postgresql://{{username}}:{{password}}@db:5432/mydb" \
    username="vault" password="password"

vault write database/roles/readonly \
    db_name=postgres \
    creation_statements="CREATE ROLE \"{{name}}\" LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl=1h max_ttl=24h

vault read database/creds/readonly  # Get credentials
```

### Transit (Encryption)

```bash
vault secrets enable transit
vault write -f transit/keys/my-key

# Encrypt
vault write transit/encrypt/my-key plaintext=$(echo "secret" | base64)

# Decrypt
vault write transit/decrypt/my-key ciphertext="vault:v1:..."
```

### PKI (Certificates)

```bash
vault secrets enable pki
vault write pki/root/generate/internal common_name="Root CA" ttl=87600h

vault write pki/roles/web-servers \
    allowed_domains="example.com" \
    allow_subdomains=true max_ttl=72h

vault write pki/issue/web-servers common_name="web.example.com"
```

→ See [references/secrets-engines.md](references/secrets-engines.md) for AWS, Azure, GCP, SSH, TOTP.

---

## Policies

### Basic Policy Structure

```hcl
# Allow read access to application secrets
path "secret/data/myapp/*" {
  capabilities = ["read", "list"]
}

# Allow dynamic database credentials
path "database/creds/readonly" {
  capabilities = ["read"]
}

# Deny admin secrets
path "secret/data/admin/*" {
  capabilities = ["deny"]
}
```

### Templated Policies

```hcl
# Dynamic path based on entity
path "secret/data/users/{{identity.entity.id}}/*" {
  capabilities = ["create", "read", "update", "delete"]
}
```

→ See [references/policies.md](references/policies.md) for advanced patterns and Sentinel.

---

## Kubernetes Integration

### Vault Secrets Operator (VSO) - Recommended

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: my-app-secrets
spec:
  vaultAuthRef: vault-auth
  mount: secret
  path: myapp/config
  type: kv-v2
  destination:
    name: my-app-secret
    create: true
```

### Agent Injector (Sidecar)

```yaml
annotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/role: "my-app"
  vault.hashicorp.com/agent-inject-secret-config.txt: "secret/data/myapp/config"
```

→ See [references/kubernetes.md](references/kubernetes.md) for full VSO, Injector, and CSI configuration.

---

## Vault Agent

Vault Agent handles authentication, caching, and secret templating as a daemon or sidecar.

### Configuration

```hcl
auto_auth {
  method "kubernetes" {
    mount_path = "auth/kubernetes"
    config = { role = "my-app" }
  }
  sink "file" {
    config = { path = "/home/vault/.vault-token" }
  }
}

template {
  source      = "/etc/vault/config.ctmpl"
  destination = "/app/config.txt"
}
```

### Template Syntax

```text
{{- with secret "secret/data/myapp/config" -}}
DB_HOST={{ .Data.data.host }}
DB_USER={{ .Data.data.username }}
DB_PASS={{ .Data.data.password }}
{{- end }}
```

→ See [references/vault-agent.md](references/vault-agent.md) for auto-auth methods, caching, and sidecar patterns.

---

## Terraform Integration

### Read Secrets in Terraform

```hcl
provider "vault" {
  address = "https://vault.example.com:8200"
}

data "vault_kv_secret_v2" "db" {
  mount = "secret"
  name  = "database/config"
}

resource "aws_db_instance" "main" {
  username = data.vault_kv_secret_v2.db.data["username"]
  password = data.vault_kv_secret_v2.db.data["password"]
}
```

### Manage Vault with Terraform

```hcl
resource "vault_policy" "app" {
  name   = "app-policy"
  policy = file("policies/app.hcl")
}

resource "vault_approle_auth_backend_role" "app" {
  backend        = "approle"
  role_name      = "my-app"
  token_policies = [vault_policy.app.name]
}
```

---

## Enterprise Features

| Feature | Description |
| ------- | ----------- |
| **Namespaces** | Multi-tenant isolation |
| **Performance Replication** | Read replicas for scale |
| **DR Replication** | Warm standby for failover |
| **Sentinel** | Policy-as-code beyond ACLs |
| **MFA** | Multi-factor authentication |
| **Control Groups** | Multi-person approval |

→ See [references/enterprise.md](references/enterprise.md) for configuration details.

---

## Troubleshooting Quick Guide

### Vault is Sealed

```bash
vault operator unseal <key>  # Repeat for threshold
```

Consider auto-unseal with AWS KMS, Azure Key Vault, or GCP Cloud KMS.

### Permission Denied

```bash
vault token lookup                        # Check policies
vault token capabilities secret/data/app  # Check path access
```

Remember: KV v2 policies need `/data/` in path.

### Token Expired

```bash
vault token renew          # Renew before expiry
vault login -method=oidc   # Re-authenticate
```

→ See [references/troubleshooting.md](references/troubleshooting.md) for comprehensive diagnostics.

---

## Best Practices

### Security

- Use short TTLs (1h or less for tokens)
- Enable audit logging
- Use dynamic secrets over static when possible
- Implement least-privilege policies
- Never commit secrets to source control

### Operational Best Practices

- Use Integrated Storage (Raft) for HA
- Configure auto-unseal with cloud KMS
- Monitor with telemetry and alerts
- Test DR failover regularly
- Backup unseal keys securely (Shamir's secret sharing)

### Architecture

- Use namespaces for tenant isolation (Enterprise)
- Deploy performance replicas for global distribution
- Implement Vault Agent for application integration
- Use VSO for Kubernetes-native secret sync

---

## Additional Resources

- **Documentation**: [developer.hashicorp.com/vault](https://developer.hashicorp.com/vault)
- **Tutorials**: [developer.hashicorp.com/vault/tutorials](https://developer.hashicorp.com/vault/tutorials)
- **API Reference**: [developer.hashicorp.com/vault/api-docs](https://developer.hashicorp.com/vault/api-docs)
- **HCP Vault**: [developer.hashicorp.com/hcp/docs/vault](https://developer.hashicorp.com/hcp/docs/vault)

---

## Summary

**Most Common Commands:**

```bash
# Check status and authenticate
vault status
vault login -method=oidc

# Read and write secrets
vault kv get secret/myapp/config
vault kv put secret/myapp/config key=value

# Get dynamic credentials
vault read database/creds/readonly
vault read aws/creds/deploy

# Check permissions
vault token lookup
vault token capabilities secret/data/myapp

# Troubleshoot
vault operator unseal
vault audit list
```

**Remember:**

- Always use **dynamic secrets** over static when possible
- Use **short TTLs** (1h or less) for tokens
- Enable **audit logging** in production
- For KV v2, policies need `/data/` in the path
- Use **VSO** for Kubernetes-native secret sync
- Test **DR failover** regularly

---

## Reference Files

For detailed configurations, see:

- [Auth Methods](references/auth-methods.md) - AppRole, Kubernetes, OIDC, AWS, Azure, GCP, LDAP, Trusted Broker Pattern
- [Secrets Engines](references/secrets-engines.md) - KV, Database, AWS, Transit, PKI, SSH, performance tuning
- [Policies](references/policies.md) - Syntax, templating, CI/CD patterns, Sentinel
- [Kubernetes](references/kubernetes.md) - VSO, Agent Injector, CSI, sidecar patterns
- [Vault Agent](references/vault-agent.md) - Auto-auth, caching, templating, sidecar patterns
- [Production Operations](references/production-operations.md) - Monitoring, metrics, backup/recovery, upgrades
- [Enterprise](references/enterprise.md) - Namespaces, Replication, DR, MFA
- [Troubleshooting](references/troubleshooting.md) - Diagnostics, metrics, common issues
