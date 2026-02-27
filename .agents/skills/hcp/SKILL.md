---
name: hcp
description: HashiCorp Cloud Platform (HCP) - fully managed platform offering HashiCorp products as a service
---

# HashiCorp Cloud Platform (HCP)

This skill covers HashiCorp Cloud Platform (HCP), a fully managed platform offering HashiCorp products-as-a-service.

## When to Use This Skill

Use this skill when you need to:
- Deploy HashiCorp products without managing infrastructure
- Get started with HashiCorp tools quickly without installation
- Scale HashiCorp services with built-in high availability
- Reduce operational overhead of running Terraform, Vault, Consul, etc.
- Access HashiCorp products globally with multi-region deployment
- Integrate multiple HashiCorp products in a managed environment
- Ensure automatic updates and security patches for HashiCorp tools

## What is HCP?

**HCP (HashiCorp Cloud Platform) is a fully-managed platform** offering HashiCorp products-as-a-service. The platform removes the management overhead associated with deploying and maintaining HashiCorp products so teams can focus on developing and deploying applications.

### Core Purpose

HCP provides:
- **Managed services** - No infrastructure to provision or maintain
- **Automatic updates** - Always running the latest stable versions
- **Built-in security** - Enterprise-grade security and compliance
- **Global availability** - Multi-region deployment options
- **Integrated ecosystem** - Seamless integration between HashiCorp products

### The Problem with Self-Managed Infrastructure

**Running HashiCorp Products Yourself:**
- Requires dedicated infrastructure and maintenance
- Manual installation, configuration, and updates
- Complex high availability setup
- Security patching and compliance responsibilities
- Backup and disaster recovery planning
- Monitoring and troubleshooting operational issues
- Scaling challenges during growth

**HCP's Solution:**
- **Zero infrastructure management** - Fully managed by HashiCorp
- **Automatic scaling** - Grows with your needs
- **Built-in HA/DR** - High availability and disaster recovery included
- **Integrated security** - Compliance certifications maintained
- **Reduced cost** - No ops team needed for platform management
- **Faster time-to-value** - Start using products in minutes

## Available HCP Services

HCP organizes its offerings into two main categories:

### Infrastructure Lifecycle Management

**HCP Terraform (formerly Terraform Cloud)**
- Infrastructure as Code platform
- Remote state management and locking
- VCS integration for GitOps workflows
- Policy enforcement with Sentinel
- Cost estimation and management
- Private module registry
- Team collaboration and RBAC

**HCP Packer**
- Machine image management
- Golden image pipelines
- Multi-cloud image building
- Image metadata and versioning
- Integration with HCP Terraform

**HCP Nomad**
- Workload orchestration as a service
- Container and non-container workloads
- Multi-region deployment
- Service mesh integration
- No cluster management overhead

**HCP Waypoint**
- Application deployment platform
- Template-based workflows
- Developer self-service
- GitOps integration
- Add-on marketplace

**HCP Vagrant** (Coming Soon)
- Development environment management
- Consistent dev environments across teams

### Security Lifecycle Management

**HCP Vault (Dedicated & Secrets)**
- Secrets management as a service
- Dynamic secrets generation
- Encryption as a service
- PKI management
- Database credential rotation
- Multiple deployment tiers (Starter, Standard, Plus)

**HCP Boundary**
- Identity-based remote access
- Session recording and auditing
- Dynamic host discovery
- No VPN required
- Integration with HCP Vault for credentials

**HCP Vault Radar**
- Embedded secrets detection
- Scan code repositories for leaked secrets
- Security posture monitoring
- Integration with HCP Vault for remediation

**HCP Consul**
- Service mesh and service discovery
- Multi-datacenter networking
- Health checking and monitoring
- KV store for configuration
- Integration with HCP Vault and Nomad

## Key Features

| Feature | Description |
| --- | --- |
| **Fully Managed** | No infrastructure to provision, configure, or maintain |
| **Automatic Updates** | Always running latest stable versions with zero downtime |
| **High Availability** | Built-in redundancy and failover across availability zones |
| **Global Deployment** | Deploy in multiple regions worldwide |
| **Integrated Products** | Seamless integration between HCP services |
| **Enterprise Support** | 24/7 support from HashiCorp experts |
| **Compliance** | SOC 2, HIPAA, PCI-DSS certifications |
| **Cost Transparency** | Predictable pricing with usage-based billing |

## Getting Started with HCP

### Create an HCP Account

1. **Sign up at HCP Portal:**
   - Visit https://portal.cloud.hashicorp.com
   - Click "Sign Up" or "Get Started"
   - Create account with email or SSO (Google, GitHub)

2. **Create an organization:**
   - Choose organization name
   - Select billing region
   - Add team members (optional)

3. **Set up billing (if not on free tier):**
   - Add payment method
   - Configure spending limits (optional)
   - Enable cost alerts

### HCP CLI Installation

**macOS (Homebrew):**
```bash
brew install hashicorp/tap/hcp
```

**Linux:**
```bash
wget https://releases.hashicorp.com/hcp/<version>/hcp_<version>_linux_amd64.zip
unzip hcp_<version>_linux_amd64.zip
sudo mv hcp /usr/local/bin/
```

**Verify Installation:**
```bash
hcp version
```

### Authenticate with HCP

**Login via CLI:**
```bash
hcp auth login
```
This opens a browser for authentication.

**Create a service principal (for automation):**
```bash
hcp service-principals create my-ci-cd \
  --role="roles/contributor"
```

**Set up credentials:**
```bash
hcp profile init
export HCP_CLIENT_ID="your-client-id"
export HCP_CLIENT_SECRET="your-client-secret"
```

## Common Workflows

### Workflow 1: Deploying HCP Vault

**Scenario:** Set up a managed Vault cluster for secrets management

1. **Create HCP Vault cluster via CLI:**
   ```bash
   hcp vault-clusters create my-vault \
     --tier=dev \
     --region=us-west-2
   ```

2. **Wait for cluster to be ready:**
   ```bash
   hcp vault-clusters wait my-vault
   ```

3. **Get cluster details:**
   ```bash
   hcp vault-clusters read my-vault
   ```

4. **Connect to Vault:**
   ```bash
   # Set Vault address
   export VAULT_ADDR=$(hcp vault-clusters read my-vault --format=json | jq -r '.vault_public_endpoint_url')

   # Get admin token
   export VAULT_TOKEN=$(hcp vault-clusters read my-vault --format=json | jq -r '.admin_token')

   # Test connection
   vault status
   ```

5. **Enable secrets engine:**
   ```bash
   vault secrets enable -path=secret kv-v2
   vault kv put secret/myapp password=secretvalue
   ```

### Workflow 2: Setting Up HCP Terraform (Terraform Cloud)

**Scenario:** Migrate from local Terraform to HCP Terraform

1. **Create a workspace via UI:**
   - Navigate to https://app.terraform.io
   - Click "New Workspace"
   - Connect to VCS repository (GitHub, GitLab, etc.)
   - Configure workspace settings

2. **Update Terraform configuration:**
   ```hcl
   terraform {
     cloud {
       organization = "my-org"

       workspaces {
         name = "my-app-production"
       }
     }
   }
   ```

3. **Login from CLI:**
   ```bash
   terraform login
   ```

4. **Initialize workspace:**
   ```bash
   terraform init
   ```

5. **Run plan and apply:**
   ```bash
   terraform plan  # Runs in HCP Terraform
   terraform apply  # Requires confirmation in UI or -auto-approve
   ```

### Workflow 3: Deploying HCP Consul Service Mesh

**Scenario:** Set up service mesh for microservices

1. **Create HCP Consul cluster:**
   ```bash
   hcp consul create my-consul \
     --tier=development \
     --region=us-west-2 \
     --size=small
   ```

2. **Get connection details:**
   ```bash
   hcp consul read my-consul
   ```

3. **Install Consul client on your servers:**
   ```bash
   # Download agent config
   hcp consul agents download-config my-consul > consul.hcl

   # Start Consul agent
   consul agent -config-file=consul.hcl
   ```

4. **Register services:**
   ```bash
   consul services register service-definition.json
   ```

5. **Configure service mesh:**
   ```bash
   consul config write proxy-defaults.hcl
   consul config write service-intentions.hcl
   ```

### Workflow 4: Integrating HCP Vault with HCP Terraform

**Scenario:** Use Vault secrets in Terraform runs

1. **Create a Vault cluster (if not exists):**
   ```bash
   hcp vault-clusters create terraform-vault --tier=dev
   ```

2. **Configure Vault provider in Terraform:**
   ```hcl
   provider "vault" {
     address = var.vault_addr
     token   = var.vault_token  # From HCP
   }

   data "vault_generic_secret" "database" {
     path = "secret/data/database"
   }

   resource "aws_db_instance" "app" {
     username = data.vault_generic_secret.database.data["username"]
     password = data.vault_generic_secret.database.data["password"]
   }
   ```

3. **Set Vault credentials in HCP Terraform workspace:**
   - Go to Workspace → Variables
   - Add `VAULT_ADDR` (environment variable)
   - Add `VAULT_TOKEN` (sensitive environment variable)

4. **Run Terraform:**
   ```bash
   terraform apply
   # Terraform fetches secrets from HCP Vault during run
   ```

### Workflow 5: Cross-Service Integration (Boundary + Vault + Consul)

**Scenario:** Complete security platform with zero-trust access

1. **Deploy core services:**
   ```bash
   # Vault for secrets
   hcp vault-clusters create security-vault --tier=starter

   # Consul for service discovery
   hcp consul create security-consul --tier=development

   # Boundary for access
   hcp boundary create security-boundary --tier=standard
   ```

2. **Configure Boundary to use Vault for credentials:**
   ```bash
   # In Boundary
   boundary credential-stores create vault \
     -scope-id p_1234567890 \
     -vault-address $(hcp vault-clusters read security-vault --format=json | jq -r '.vault_public_endpoint_url')
   ```

3. **Register services in Consul:**
   ```bash
   consul services register app.json
   ```

4. **Create Boundary targets from Consul:**
   ```bash
   boundary host-catalogs create plugin \
     -scope-id p_1234567890 \
     -plugin-name consul \
     -attr consul_addr=$(hcp consul read security-consul --format=json | jq -r '.public_endpoint')
   ```

## HCP Management

### Organization Management

**Create organization:**
```bash
hcp organizations create my-org
```

**Invite team members:**
```bash
hcp organizations invite-member \
  --email user@example.com \
  --role roles/viewer
```

**Manage projects:**
```bash
# Create project
hcp projects create my-project

# List projects
hcp projects list

# Switch project
hcp project select my-project
```

### Access Control

**Roles in HCP:**
- **Admin** - Full access to all resources
- **Contributor** - Can create and manage resources
- **Viewer** - Read-only access

**Service Principals:**
```bash
# Create for CI/CD
hcp service-principals create ci-pipeline \
  --role roles/contributor

# List service principals
hcp service-principals list

# Rotate keys
hcp service-principals keys rotate <sp-id>
```

### Monitoring and Observability

**View cluster metrics:**
```bash
# Vault metrics
hcp vault-clusters metrics my-vault

# Consul metrics
hcp consul metrics my-consul
```

**Access logs:**
```bash
# Audit logs
hcp vault-clusters audit-logs my-vault

# Activity logs
hcp organizations activity-logs
```

**Set up alerts:**
- Configure in HCP Portal → Monitoring
- Email or webhook notifications
- Alert on cluster health, usage thresholds

## Troubleshooting

### Issue 1: Cannot Connect to HCP Service

**Symptoms:**
- Timeouts when connecting to Vault/Consul/etc.
- DNS resolution failures

**Cause:**
- Network connectivity issues
- Firewall blocking access
- Incorrect endpoint URL

**Solution:**
```bash
# Verify endpoint URL
hcp vault-clusters read my-vault | grep endpoint

# Test connectivity
curl -v https://<vault-endpoint>:8200/v1/sys/health

# Check DNS
nslookup <vault-endpoint>

# Verify firewall allows HTTPS (443) and service ports
```

### Issue 2: Authentication Failures

**Symptoms:**
- "Permission denied" errors
- Cannot login to HCP CLI

**Cause:**
- Expired credentials
- Insufficient permissions
- Wrong organization/project

**Solution:**
```bash
# Re-authenticate
hcp auth login

# Verify current profile
hcp profile display

# Check organization access
hcp organizations list

# Verify project
hcp projects list
```

### Issue 3: Service Principal Not Working

**Symptoms:**
- API calls fail with authentication error
- CI/CD pipeline cannot access HCP

**Cause:**
- Invalid client ID/secret
- Insufficient permissions
- Expired or rotated keys

**Solution:**
```bash
# Verify service principal exists
hcp service-principals list

# Create new keys
hcp service-principals keys create <sp-id>

# Update environment variables
export HCP_CLIENT_ID="new-id"
export HCP_CLIENT_SECRET="new-secret"

# Test authentication
hcp auth print-access-token
```

### Issue 4: Cluster Creation Fails

**Symptoms:**
- Cluster stuck in "creating" state
- Creation times out

**Cause:**
- Quota limits reached
- Region capacity issues
- Billing problems

**Solution:**
```bash
# Check status
hcp vault-clusters read my-vault

# View cluster events
hcp vault-clusters events my-vault

# Verify quotas
hcp quotas list

# Contact support if stuck
hcp support create-ticket
```

## Best Practices

### Cost Management
- **Start with dev tiers** for testing and development
- **Use appropriate sizing** - Don't over-provision
- **Monitor usage** regularly via HCP Portal
- **Set spending limits** to avoid surprises
- **Delete unused clusters** to reduce costs
- **Use cost estimation** in HCP Terraform

### Security
- **Enable MFA** on all HCP accounts
- **Use service principals** for automation (not user accounts)
- **Rotate credentials** regularly
- **Apply least privilege** - Grant minimum necessary permissions
- **Enable audit logging** on all services
- **Use private networking** (HVN) for production

### Operations
- **Use HCP for production** - Reduce operational burden
- **Automate with Terraform** - Manage HCP resources as code
- **Monitor cluster health** - Set up alerts
- **Plan for DR** - Understand backup and recovery procedures
- **Test disaster recovery** - Validate your recovery process
- **Keep documentation updated** - Document your HCP architecture

### Architecture
- **Use HVN** (HashiCorp Virtual Network) for private connectivity
- **Deploy multi-region** for global applications
- **Integrate HCP services** - Leverage the ecosystem
- **Use Terraform for IaC** - Infrastructure in HCP Terraform
- **Centralize secrets** in HCP Vault
- **Implement zero-trust** with HCP Boundary and Consul

## HashiCorp-Specific Tips

### HCP Terraform (Terraform Cloud)

**Free Tier:**
- Up to 5 users
- Remote state storage
- VCS integration
- Community support

**Paid Tiers:**
- Team & Governance: Policy as code, SSO
- Business: Advanced security, audit logging

**When to Upgrade:**
- Need Sentinel policy enforcement
- Require SSO integration
- Need advanced RBAC
- Want private module registry

### HCP Vault Tiers

**Development (Free):**
- For testing and non-production
- Limited performance
- No SLA

**Starter:**
- Production-ready
- Performance guarantees
- Support SLA

**Standard/Plus:**
- Higher performance
- Replication options
- Advanced features (HSM, MFA)

### HCP Terraform Resource Management

**Manage HCP with Terraform:**
```hcl
terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.76"
    }
  }
}

provider "hcp" {}

resource "hcp_vault_cluster" "example" {
  cluster_id      = "my-vault"
  hvn_id          = hcp_hvn.main.hvn_id
  tier            = "dev"
  public_endpoint = true
}

resource "hcp_hvn" "main" {
  hvn_id         = "main-hvn"
  cloud_provider = "aws"
  region         = "us-west-2"
  cidr_block     = "172.25.16.0/20"
}
```

### Private Networking with HVN

**HashiCorp Virtual Network:**
- Private network for HCP services
- VPC peering to your cloud infrastructure
- Transit Gateway integration
- Reduced internet exposure

**Setup:**
```bash
# Create HVN
hcp hvn create main-hvn \
  --cloud-provider aws \
  --region us-west-2 \
  --cidr-block 172.25.16.0/20

# Create peering connection
hcp hvn peering create \
  --hvn main-hvn \
  --peer-vpc-id vpc-123456 \
  --peer-region us-west-2
```

## Additional Resources

- **HCP Portal**: https://portal.cloud.hashicorp.com
- **HCP Documentation**: https://developer.hashicorp.com/hcp
- **HCP Terraform**: https://app.terraform.io
- **HCP Pricing**: https://www.hashicorp.com/products/terraform/pricing
- **Support Portal**: https://support.hashicorp.com
- **Status Page**: https://status.hashicorp.com

## Summary

**Most Common Commands:**
```bash
# Authentication
hcp auth login
hcp profile init

# Vault operations
hcp vault-clusters create <name> --tier=dev --region=us-west-2
hcp vault-clusters list
hcp vault-clusters read <name>
hcp vault-clusters delete <name>

# Consul operations
hcp consul create <name> --tier=development
hcp consul list
hcp consul read <name>

# Boundary operations
hcp boundary create <name> --tier=standard
hcp boundary list

# Organization management
hcp organizations list
hcp projects list
hcp service-principals create <name> --role=roles/contributor
```

**Quick Start:**
```
1. Sign up → portal.cloud.hashicorp.com
2. Install CLI → brew install hashicorp/tap/hcp
3. Login → hcp auth login
4. Create cluster → hcp vault-clusters create my-vault --tier=dev
5. Connect → export VAULT_ADDR=$(hcp vault-clusters read my-vault ...)
```

**When to Use HCP vs. Self-Managed:**

**Use HCP when:**
- You want zero operational overhead
- Need fast time-to-value
- Limited ops team capacity
- Require global availability
- Want automatic updates
- Need enterprise support

**Use Self-Managed when:**
- Strict on-premises requirements
- Custom deployment needs
- Existing infrastructure investment
- Air-gapped environments
- Specific compliance constraints

**Remember:**
- HCP is fully managed - focus on using products, not running them
- All HCP services integrate seamlessly
- Start with dev/free tiers, upgrade as needed
- Use service principals for automation
- Monitor costs and set spending limits
- Leverage HCP Terraform to manage HCP resources
- HVN provides private networking between HCP services and your infrastructure
