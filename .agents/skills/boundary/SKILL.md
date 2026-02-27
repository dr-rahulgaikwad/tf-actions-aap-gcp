---
name: boundary
description: HashiCorp Boundary identity-based remote access solution for securely connecting to systems from anywhere
---

# HashiCorp Boundary

This skill covers HashiCorp Boundary, an identity-based remote access solution that enables secure access to any system from anywhere based on user identity.

## When to Use This Skill

Use this skill when you need to:
- Provide secure remote access to infrastructure without VPNs
- Enable identity-based access to SSH, RDP, databases, and Kubernetes
- Replace traditional bastion hosts with dynamic access patterns
- Audit and monitor privileged sessions
- Automate access management based on user identity and role
- Connect to resources across multiple clouds and on-premises environments

## What is Boundary?

**Boundary is HashiCorp's identity-based remote access solution** that enables users to securely access any system from anywhere based on user identity.

### Core Purpose

Boundary shifts from traditional network-based access (VPNs, bastion hosts) to **identity-based access control**, where:
- Users authenticate based on **who they are** (identity), not **where they are** (network)
- Access is granted dynamically based on **roles and permissions**
- No static credentials or long-lived access keys required
- Sessions are **audited and monitored** for compliance

### The Problem with Traditional Access

**Traditional Approach (VPNs/Bastions):**
- Broad network access based on location
- Static credentials and SSH keys scattered across teams
- Manual onboarding and offboarding processes
- Limited visibility into who accessed what
- Security vulnerabilities from over-privileged access
- Complex firewall rules and network segmentation

**Boundary's Solution:**
- **Identity-based access** - Grant access based on user/service identity
- **Just-in-time credentials** - Dynamically generate credentials per session
- **Automated discovery** - Automatically discover and catalog infrastructure
- **Session recording** - Full audit trail of privileged sessions
- **Zero trust networking** - No implicit trust based on network location

## How Boundary Works

### Architecture

Boundary consists of:
- **Controllers** - Manage authentication, authorization, and session orchestration
- **Workers** - Proxy connections between users and target systems
- **Targets** - Resources users want to access (SSH hosts, databases, Kubernetes, etc.)

### Access Flow

1. **User authenticates** - Via OIDC, LDAP, or username/password
2. **User requests access** - To a specific target (e.g., production database)
3. **Boundary authorizes** - Checks user's role and permissions
4. **Worker establishes connection** - Proxies connection to target
5. **Session is monitored** - Logged and optionally recorded
6. **Credentials are ephemeral** - Automatically rotated or revoked after use

### Identity Providers

Boundary integrates with:
- **OIDC** - Okta, Auth0, Azure AD, Google Workspace
- **LDAP/Active Directory** - Enterprise directory services
- **Username/Password** - Built-in authentication method

### Session Types

Boundary supports multiple connection types:
- **SSH** - Secure shell to Linux/Unix systems
- **RDP** - Remote desktop to Windows systems
- **PostgreSQL** - Database connections
- **Kubernetes** - kubectl exec sessions
- **Custom TCP** - Any TCP-based service

## Key Features

| Feature | Description |
| --- | --- |
| **Identity-Based Access Control** | Grant access based on user identity and role, not network location |
| **Service Discovery** | Automatically discover and catalog infrastructure resources |
| **Dynamic Credentials** | Generate just-in-time credentials via Vault integration |
| **Session Recording** | Record and audit privileged sessions for compliance |
| **Multi-Cloud Support** | Access resources across AWS, Azure, GCP, on-premises |
| **No Agent Required** | Works with standard protocols (SSH, RDP, etc.) |
| **HCP Managed Option** | Fully managed service via HCP Boundary |
| **Terraform Provider** | Define policies and manage Boundary as code |

## Installation & Setup

### Option 1: HCP Boundary (Managed)

**Benefits:**
- Fully managed - no infrastructure to maintain
- Automatic updates and patches
- Built-in high availability
- Global deployment

**Getting Started:**
1. Sign up at https://portal.cloud.hashicorp.com
2. Create an HCP Boundary cluster
3. Install Boundary Desktop or CLI
4. Configure authentication and targets

### Option 2: Self-Managed Boundary

**Install Boundary CLI:**

**macOS (Homebrew):**
```bash
brew install hashicorp/tap/boundary
```

**Linux:**
```bash
# Download from releases
wget https://releases.hashicorp.com/boundary/<version>/boundary_<version>_linux_amd64.zip
unzip boundary_<version>_linux_amd64.zip
sudo mv boundary /usr/local/bin/
```

**Verify Installation:**
```bash
boundary version
```

**Start Boundary Dev Mode (for testing):**
```bash
boundary dev
```
This starts Boundary with an in-memory database on `http://127.0.0.1:9200`.

### Basic Configuration

**Initialize Boundary (self-managed):**
```bash
# Create configuration file
cat > boundary.hcl <<EOF
controller {
  name = "demo-controller"
  database {
    url = "postgresql://boundary:boundary@localhost:5432/boundary"
  }
}

worker {
  name = "demo-worker"
  controllers = ["127.0.0.1"]
}

listener "tcp" {
  address = "0.0.0.0:9200"
  purpose = "api"
}
EOF

# Initialize database
boundary database init -config boundary.hcl

# Start Boundary
boundary server -config boundary.hcl
```

## Common Commands

### Authentication

**Login via CLI:**
```bash
# Username/password
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin

# OIDC
boundary authenticate oidc \
  -auth-method-id=amoidc_1234567890
```

**Login via Desktop App:**
- Download Boundary Desktop from https://boundaryproject.io/downloads
- Enter your Boundary cluster URL
- Authenticate via configured method

### Managing Targets

**List targets:**
```bash
boundary targets list -scope-id p_1234567890
```

**Connect to a target:**
```bash
# SSH
boundary connect ssh -target-id tssh_1234567890

# With specific user
boundary connect ssh -target-id tssh_1234567890 -username ubuntu

# PostgreSQL
boundary connect postgres -target-id tpg_1234567890

# RDP
boundary connect rdp -target-id trdp_1234567890

# Generic TCP
boundary connect -target-id ttcp_1234567890 -listen-port 8080
```

### Session Management

**List active sessions:**
```bash
boundary sessions list -scope-id p_1234567890
```

**Cancel a session:**
```bash
boundary sessions cancel -id s_1234567890
```

**Read session details:**
```bash
boundary sessions read -id s_1234567890
```

### Managing Resources

**Create a target:**
```bash
boundary targets create tcp \
  -scope-id p_1234567890 \
  -default-port 22 \
  -name "Production SSH Server" \
  -address 10.0.1.100
```

**Create a host catalog (for dynamic discovery):**
```bash
boundary host-catalogs create static \
  -scope-id p_1234567890 \
  -name "Static Hosts"
```

**Create a host:**
```bash
boundary hosts create static \
  -host-catalog-id hcst_1234567890 \
  -address 10.0.1.100 \
  -name "web-server-01"
```

## Common Workflows

### Workflow 1: Setting Up SSH Access to a Server

1. **Create a target for the SSH server:**
   ```bash
   boundary targets create tcp \
     -scope-id p_1234567890 \
     -name "Production Web Server" \
     -description "Ubuntu web server in production" \
     -default-port 22 \
     -address 10.0.1.100
   ```

2. **Grant access to a group:**
   ```bash
   # Assume you have a role r_1234567890 for "DevOps Team"
   # Add target to the role
   boundary roles add-grants \
     -id r_1234567890 \
     -grant "id=tssh_1234567890;actions=authorize-session"
   ```

3. **Connect to the server:**
   ```bash
   boundary connect ssh -target-id tssh_1234567890 -username ubuntu
   ```

### Workflow 2: Dynamic Host Discovery with AWS

1. **Create a dynamic host catalog for AWS:**
   ```bash
   boundary host-catalogs create plugin \
     -scope-id p_1234567890 \
     -plugin-name aws \
     -name "AWS Production Hosts" \
     -attr region=us-west-2 \
     -attr disable_credential_rotation=true
   ```

2. **Set AWS credentials (via Vault or static):**
   ```bash
   boundary host-catalogs update plugin \
     -id hcplg_1234567890 \
     -secret access_key_id=AKIAIOSFODNN7EXAMPLE \
     -secret secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```

3. **Create a host set with filters:**
   ```bash
   boundary host-sets create plugin \
     -host-catalog-id hcplg_1234567890 \
     -name "Production Web Servers" \
     -attr filters='tag:Environment=production,tag:Type=webserver'
   ```

4. **Create a target using the dynamic host set:**
   ```bash
   boundary targets create tcp \
     -scope-id p_1234567890 \
     -name "Production Web Fleet" \
     -default-port 22 \
     -host-source-id hsplg_1234567890
   ```

### Workflow 3: Database Access with Vault Integration

1. **Configure Vault credential store:**
   ```bash
   boundary credential-stores create vault \
     -scope-id p_1234567890 \
     -vault-address https://vault.example.com \
     -vault-token s.abc123... \
     -name "Vault Production"
   ```

2. **Create a credential library:**
   ```bash
   boundary credential-libraries create vault \
     -credential-store-id csvlt_1234567890 \
     -vault-path database/creds/readonly \
     -name "PostgreSQL Read-Only Creds"
   ```

3. **Create a database target with dynamic credentials:**
   ```bash
   boundary targets create tcp \
     -scope-id p_1234567890 \
     -name "Production PostgreSQL" \
     -default-port 5432 \
     -address postgres.example.com \
     -brokered-credential-source-id clvlt_1234567890
   ```

4. **Connect to database (credentials injected automatically):**
   ```bash
   boundary connect postgres -target-id tpg_1234567890
   ```

### Workflow 4: Terraform-Managed Boundary Configuration

1. **Create Terraform configuration:**
   ```hcl
   terraform {
     required_providers {
       boundary = {
         source  = "hashicorp/boundary"
         version = "~> 1.1"
       }
     }
   }

   provider "boundary" {
     addr             = "https://boundary.example.com"
     auth_method_id   = "ampw_1234567890"
     password_auth_method_login_name = "admin"
     password_auth_method_password   = var.admin_password
   }

   resource "boundary_target" "ssh_servers" {
     name         = "Production SSH Servers"
     description  = "All production SSH servers"
     type         = "tcp"
     default_port = 22
     scope_id     = boundary_scope.production.id

     host_source_ids = [
       boundary_host_set_static.web_servers.id,
     ]
   }
   ```

2. **Apply configuration:**
   ```bash
   terraform init
   terraform apply
   ```

## Troubleshooting

### Issue 1: Cannot Connect to Target

**Symptoms:**
- Error: "failed to authorize session"
- Connection times out

**Cause:**
- Insufficient permissions
- Target misconfiguration
- Network connectivity issues

**Solution:**
```bash
# Check if you have permission
boundary targets authorize-session -id tssh_1234567890

# Verify target configuration
boundary targets read -id tssh_1234567890

# Check worker connectivity
boundary workers list

# Test network path
ping <target-address>
```

### Issue 2: Session Recording Not Working

**Symptoms:**
- Sessions complete but no recordings available
- Error in session logs

**Cause:**
- Storage bucket not configured
- Worker lacks permissions to write to storage
- Session recording not enabled on target

**Solution:**
```bash
# Verify storage bucket configuration
boundary storage-buckets read -id sb_1234567890

# Check target has storage bucket attached
boundary targets read -id tssh_1234567890

# Enable session recording on target
boundary targets update \
  -id tssh_1234567890 \
  -enable-session-recording=true \
  -storage-bucket-id sb_1234567890
```

### Issue 3: Dynamic Host Discovery Not Finding Hosts

**Symptoms:**
- Host sets are empty
- AWS/Azure resources not appearing

**Cause:**
- Incorrect credentials
- Wrong filters
- Missing IAM permissions

**Solution:**
```bash
# Test credentials manually
aws ec2 describe-instances --region us-west-2

# Check host catalog configuration
boundary host-catalogs read -id hcplg_1234567890

# Verify filters in host set
boundary host-sets read -id hsplg_1234567890

# Update filters
boundary host-sets update plugin \
  -id hsplg_1234567890 \
  -attr filters='tag:Environment=production'
```

### Issue 4: Worker Offline or Unreachable

**Symptoms:**
- Error: "No workers are available"
- Targets show as unhealthy

**Cause:**
- Worker process stopped
- Network connectivity to controllers
- Certificate issues

**Solution:**
```bash
# Check worker status
boundary workers list

# Restart worker service
sudo systemctl restart boundary-worker

# Check worker logs
journalctl -u boundary-worker -f

# Test connectivity to controllers
curl -k https://controller.example.com:9200/health
```

## Best Practices

### Access Management
- **Use OIDC/LDAP** for authentication (not username/password)
- **Apply least privilege** - Grant minimum necessary permissions
- **Use dynamic credentials** via Vault integration when possible
- **Regularly audit** active sessions and permissions
- **Enable session recording** for compliance and security

### Infrastructure Organization
- **Use scopes** to organize resources by environment (dev, staging, prod)
- **Tag targets** with metadata for easier discovery
- **Automate discovery** using dynamic host catalogs
- **Version control** Boundary configuration with Terraform
- **Document target names** clearly for team understanding

### Security
- **Enable MFA** for authentication methods
- **Rotate credentials** regularly for static credentials
- **Monitor session logs** for suspicious activity
- **Use worker filters** to control which workers can access targets
- **Encrypt traffic** between all components (TLS)
- **Backup Boundary database** regularly

### Operations
- **Use HCP Boundary** for production to reduce operational burden
- **Deploy multiple workers** for high availability
- **Monitor worker health** and capacity
- **Test disaster recovery** procedures
- **Keep Boundary updated** to latest stable version

## HashiCorp-Specific Tips

### Integration with Vault

**Dynamic Database Credentials:**
```hcl
# Boundary retrieves credentials from Vault automatically
resource "boundary_credential_library_vault" "postgres" {
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = "database/creds/readonly"
  http_method         = "GET"
}
```

**SSH Certificate Signing:**
- Use Vault's SSH secrets engine with Boundary
- Short-lived SSH certificates instead of static keys
- Automatic credential injection

### HCP Boundary

**Benefits over Self-Managed:**
- Fully managed controllers (no database management)
- Automatic updates and security patches
- Global deployment options
- Built-in high availability
- Integrated with HCP Vault for credentials

**When to Use HCP:**
- Production deployments requiring high availability
- Teams without infrastructure management capacity
- Multi-region deployments
- Rapid deployment needs

### Boundary Desktop

**Features:**
- GUI for browsing and connecting to targets
- Credential caching for seamless re-authentication
- Session management dashboard
- Cross-platform (macOS, Windows, Linux)

**Download:**
https://developer.hashicorp.com/boundary/downloads

### Terraform Provider

**Common Resources:**
- `boundary_auth_method` - OIDC, LDAP, or password authentication
- `boundary_target` - SSH, TCP, or PostgreSQL targets
- `boundary_host_catalog` - Static or dynamic (AWS, Azure) host discovery
- `boundary_role` - Role-based access control
- `boundary_credential_store` - Vault integration for dynamic credentials

## Additional Resources

- **Official Boundary Documentation**: https://developer.hashicorp.com/boundary
- **Boundary Learn Tutorials**: https://developer.hashicorp.com/boundary/tutorials
- **Boundary GitHub**: https://github.com/hashicorp/boundary
- **HCP Boundary**: https://portal.cloud.hashicorp.com
- **Boundary Desktop**: https://developer.hashicorp.com/boundary/downloads
- **Terraform Provider**: https://registry.terraform.io/providers/hashicorp/boundary

## Summary

**Most Common Commands:**
```bash
# Authentication
boundary authenticate password -auth-method-id=ampw_1234567890
boundary authenticate oidc -auth-method-id=amoidc_1234567890

# Connecting to targets
boundary connect ssh -target-id tssh_1234567890
boundary connect postgres -target-id tpg_1234567890
boundary connect rdp -target-id trdp_1234567890

# Managing sessions
boundary sessions list
boundary sessions cancel -id s_1234567890

# Managing targets
boundary targets list
boundary targets read -id tssh_1234567890
boundary targets create tcp -name "My Server" -address 10.0.1.100

# Managing resources
boundary hosts list -host-catalog-id hcst_1234567890
boundary workers list
```

**Quick Access Pattern:**
```
1. Authenticate → boundary authenticate
2. Find target → boundary targets list
3. Connect → boundary connect ssh -target-id <id>
4. Session proxied through worker
5. Automatic credential injection (if configured)
6. Session logged and optionally recorded
```

**Remember:**
- Boundary replaces VPNs and bastion hosts with identity-based access
- No static credentials needed when integrated with Vault
- All sessions are audited for compliance
- Use HCP Boundary for production deployments
- Manage as code with Terraform
- Enable session recording for privileged access
- Dynamic host discovery reduces manual configuration
