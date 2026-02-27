---
name: azure
description: Using HashiCorp products with Microsoft Azure (Terraform, Vault, Consul, Nomad, Boundary, HCP) plus Doormat auth and Azure CLI workflows. Use for Azure setup, access, and examples.
---

# Azure with HashiCorp

Guide to using HashiCorp products with Microsoft Azure.

## HashiCorp Products on Azure

**Terraform**: Primary IaC tool for Azure infrastructure (azurerm provider)
**Vault**: Azure auth, dynamic Azure credentials, Key Vault integration
**Consul**: Service mesh on AKS and Azure VMs
**Nomad**: Workload orchestration on Azure VMs
**Boundary**: Secure access to Azure VMs and databases
**HCP**: Fully-managed HashiCorp services on Azure

## Accessing Azure at HashiCorp

### Doormat Authentication

```bash
# List available Azure subscriptions
doormat azure list

# Get Azure credentials (12-hour session)
doormat azure --subscription <subscription-name>

# Verify access
az account show
```

See `/doormat` skill for detailed usage.

### Azure CLI

```bash
# Install
brew install azure-cli

# Login (credentials auto-configured by Doormat)
az login

# List resource groups
az group list
```

## Common Workflows

### Terraform on Azure

**Basic configuration**:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}
```

**Best practices**:
- Use Azure Storage for remote state
- Enable state encryption
- Tag resources consistently (cost tracking)
- Use modules for reusability

### Vault Azure Secrets Engine

**Setup**:
```bash
# Enable Azure secrets engine
vault secrets enable azure

# Configure with Azure credentials
vault write azure/config \
  subscription_id=$AZURE_SUBSCRIPTION_ID \
  tenant_id=$AZURE_TENANT_ID \
  client_id=$AZURE_CLIENT_ID \
  client_secret=$AZURE_CLIENT_SECRET

# Create role for dynamic credentials
vault write azure/roles/app-role \
  ttl=1h \
  azure_roles=-<<EOF
  [
    {
      "role_name": "Contributor",
      "scope": "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/my-rg"
    }
  ]
EOF
```

**Generate credentials**:
```bash
vault read azure/creds/app-role
# Returns temporary Azure service principal (auto-revoked)
```

**Benefits**: Short-lived credentials, audit trail, no long-term secrets

### Vault Azure Auth

**Authenticate Azure VMs to Vault**:
```bash
# Enable Azure auth method
vault auth enable azure

# Configure
vault write auth/azure/config \
  tenant_id=$AZURE_TENANT_ID \
  resource=https://management.azure.com/

# Create role for VMs
vault write auth/azure/role/app-role \
  policies="app-policy" \
  bound_subscription_ids=$AZURE_SUBSCRIPTION_ID \
  bound_resource_groups="my-rg"
```

**From Azure VM**:
```bash
# Get access token from Azure metadata
export TOKEN=$(curl -H Metadata:true \
  "http://169.254.169.254/metadata/identity/oauth2/token?resource=https://management.azure.com/")

# Login to Vault
vault write auth/azure/login \
  role="app-role" \
  jwt=$TOKEN
```

### Consul on Azure

**Azure auto-join**:
```hcl
# consul.hcl
retry_join = [
  "provider=azure tag_name=consul_server tag_value=true subscription_id=$AZURE_SUBSCRIPTION_ID"
]
```

Automatically discovers Consul servers using Azure tags.

### Consul on AKS

**Deploy Consul service mesh on Azure Kubernetes Service**:
```bash
# Add Consul Helm repo
helm repo add hashicorp https://helm.releases.hashicorp.com

# Install Consul
helm install consul hashicorp/consul \
  --set global.name=consul \
  --set connectInject.enabled=true \
  --set server.replicas=3 \
  --set server.storage=10Gi \
  --set server.storageClass=managed-premium
```

### Nomad on Azure

**Deploy to Azure VMs**:
```hcl
job "app" {
  datacenters = ["azure-eastus"]

  group "web" {
    task "server" {
      driver = "docker"

      config {
        image = "my-app:latest"
      }

      # Get Azure credentials from Vault
      vault {
        policies = ["azure-read"]
      }

      template {
        data = <<EOH
{{ with secret "azure/creds/app-role" }}
AZURE_CLIENT_ID={{ .Data.client_id }}
AZURE_CLIENT_SECRET={{ .Data.client_secret }}
{{ end }}
EOH
        destination = "secrets/azure.env"
        env = true
      }
    }
  }
}
```

### Boundary for Azure Access

**VM access without bastions**:
```bash
# Create target for Azure VM
boundary targets create tcp \
  -name="app-server" \
  -default-port=22 \
  -address="myvm.eastus.cloudapp.azure.com"

# Connect via SSH
boundary connect ssh -target-id ttcp_abc123
```

**Dynamic host catalogs**:
```bash
# Auto-discover Azure VMs by tag
boundary host-sets create plugin \
  -host-catalog-id hcplg_123 \
  -attr filter="tagName eq 'Environment' and tagValue eq 'Production'"
```

### HCP on Azure

**HCP Vault on Azure**:
1. Create HVN (HashiCorp Virtual Network)
2. Deploy HCP Vault cluster
3. Peer HVN with Azure VNet
4. Configure network security groups
5. Access Vault from Azure resources

Fully managed with HA, backups, and automated upgrades.

## Azure Networking for HashiCorp

### VNet Design

```
VNet (10.0.0.0/16)
├── Public Subnet - Load Balancers, App Gateway
├── Private Subnet - Apps, Nomad clients
└── Database Subnet - Azure SQL, Cosmos DB
```

**Network Security Groups for HashiCorp**:
- Consul: 8300-8302, 8500, 8600
- Vault: 8200-8201
- Nomad: 4646-4648

### HCP VNet Peering

1. Create HVN in HCP Console
2. Initiate peering to Azure VNet
3. Accept peering in Azure Portal
4. Update route tables
5. Configure NSGs

## Key Azure Services for HashiCorp

**Compute**: VMs (Nomad, Consul, Vault), AKS (with Consul/Vault), Container Instances
**Storage**: Blob Storage (Terraform state, Vault snapshots), Managed Disks
**Database**: Azure SQL (with Vault dynamic secrets), Cosmos DB, PostgreSQL
**Networking**: VNet, Load Balancer, Application Gateway, Traffic Manager
**Security**: Key Vault (integration with Vault), Managed Identities, Azure AD
**Monitoring**: Azure Monitor, Application Insights, Log Analytics

## Troubleshooting

### Doormat Session Expired

**Problem**: Azure credentials stopped working.

**Solution**: Re-authenticate with Doormat (sessions last 12 hours)
```bash
doormat azure --subscription <subscription>
```

### Terraform Permission Errors

**Problem**: Terraform can't create resources.

**Solutions**:
1. Verify service principal has required permissions
2. Check correct subscription: `az account show`
3. Ensure Doormat session is active
4. Verify resource provider is registered: `az provider list`

### Vault Azure Credentials Not Working

**Problem**: Dynamic credentials from Vault don't work.

**Solutions**:
1. Check Vault Azure secrets engine configuration
2. Verify service principal permissions for Vault
3. Check credential lease hasn't expired
4. Validate Azure role assignments

### Consul Auto-Join Failing

**Problem**: Consul servers can't discover each other.

**Solutions**:
1. Verify VMs have correct tags
2. Check NSGs allow Consul ports (8300-8302)
3. Ensure managed identity has Reader permission
4. Verify VMs are in same subscription/region

## Additional Resources

### HashiCorp Documentation
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Vault Azure Secrets](https://developer.hashicorp.com/vault/docs/secrets/azure)
- [Vault Azure Auth](https://developer.hashicorp.com/vault/docs/auth/azure)
- [Consul on Azure](https://developer.hashicorp.com/consul/tutorials/cloud-production/azure-reference-architecture)

### Internal Resources
- [Azure Doormat Guide](https://hashicorp.atlassian.net/wiki/spaces/~361427045/pages/2832400487/azurerm+doormat)

### Related Skills
- `/terraform` - Infrastructure as Code
- `/vault` - Secrets management
- `/consul` - Service mesh
- `/nomad` - Workload orchestration
- `/boundary` - Secure access
- `/hcp` - HashiCorp Cloud Platform
- `/doormat` - Authentication
- `/kubernetes` - AKS integration

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
