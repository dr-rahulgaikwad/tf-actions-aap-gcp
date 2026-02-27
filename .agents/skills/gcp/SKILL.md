---
name: gcp
description: Using HashiCorp products with Google Cloud Platform (GCP), including Doormat auth and gcloud CLI workflows. Use for GCP access, Terraform, Vault, Consul, or Nomad on GCP.
---

# GCP with HashiCorp

Guide to using HashiCorp products with Google Cloud Platform (GCP).

## HashiCorp Products on GCP

**Terraform**: Primary IaC tool for GCP infrastructure
**Vault**: GCP auth, dynamic GCP credentials, Cloud KMS integration
**Consul**: Service mesh on GKE and Compute Engine
**Nomad**: Workload orchestration on Compute Engine
**Boundary**: Secure access to GCP VMs and databases
**HCP**: Fully-managed HashiCorp services on GCP

## Accessing GCP at HashiCorp

### Doormat Authentication

```bash
# List available GCP projects
doormat gcp list

# Get GCP credentials (12-hour session)
doormat gcp --project <project-name>

# Verify access
gcloud auth list
gcloud config list
```

See `/doormat` skill for detailed usage.

### gcloud CLI

```bash
# Install
brew install --cask google-cloud-sdk

# Initialize (credentials auto-configured by Doormat)
gcloud init

# List compute instances
gcloud compute instances list
```

## Common Workflows

### Terraform on GCP

**Basic configuration**:
```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "prod"
  }
}

provider "google" {
  project = "my-project-id"
  region  = "us-central1"
}

resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}
```

**Best practices**:
- Use GCS for remote state
- Enable state encryption
- Use labels for cost tracking
- Organize with workspaces or folders

### Vault GCP Secrets Engine

**Setup**:
```bash
# Enable GCP secrets engine
vault secrets enable gcp

# Configure with service account
vault write gcp/config \
  credentials=@service-account-key.json

# Create roleset for dynamic service accounts
vault write gcp/roleset/app-role \
  project="my-project" \
  secret_type="service_account_key" \
  bindings=-<<EOF
  resource "//cloudresourcemanager.googleapis.com/projects/my-project" {
    roles = ["roles/viewer"]
  }
EOF
```

**Generate credentials**:
```bash
vault read gcp/key/app-role
# Returns temporary service account key (auto-revoked)
```

**Benefits**: Short-lived credentials, audit trail, no long-term keys

### Vault GCP Auth

**Authenticate GCE instances to Vault**:
```bash
# Enable GCP auth method
vault auth enable gcp

# Configure
vault write auth/gcp/config \
  credentials=@service-account-key.json

# Create role for GCE instances
vault write auth/gcp/role/app-role \
  type="gce" \
  policies="app-policy" \
  bound_projects="my-project" \
  bound_zones="us-central1-a" \
  bound_labels="environment=production"
```

**From GCE instance**:
```bash
# Get JWT from metadata server
export JWT=$(curl -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=vault/app-role&format=full")

# Login to Vault
vault write auth/gcp/login \
  role="app-role" \
  jwt=$JWT
```

### Consul on GCP

**GCP auto-join**:
```hcl
# consul.hcl
retry_join = [
  "provider=gce project_name=my-project tag_value=consul-server"
]
```

Automatically discovers Consul servers using GCE labels/tags.

### Consul on GKE

**Deploy Consul service mesh on Google Kubernetes Engine**:
```bash
# Add Consul Helm repo
helm repo add hashicorp https://helm.releases.hashicorp.com

# Install Consul
helm install consul hashicorp/consul \
  --set global.name=consul \
  --set connectInject.enabled=true \
  --set server.replicas=3 \
  --set server.storage=10Gi \
  --set server.storageClass=standard-rwo
```

### Nomad on GCP

**Deploy to Compute Engine**:
```hcl
job "app" {
  datacenters = ["gcp-us-central1"]

  group "web" {
    task "server" {
      driver = "docker"

      config {
        image = "my-app:latest"
      }

      # Get GCP credentials from Vault
      vault {
        policies = ["gcp-read"]
      }

      template {
        data = <<EOH
{{ with secret "gcp/key/app-role" }}
GOOGLE_CREDENTIALS={{ .Data.private_key_data }}
{{ end }}
EOH
        destination = "secrets/gcp.env"
        env = true
      }
    }
  }
}
```

### Boundary for GCP Access

**Compute Engine access without bastions**:
```bash
# Create target for GCE instance
boundary targets create tcp \
  -name="app-server" \
  -default-port=22 \
  -address="compute-instance.us-central1-a.c.my-project.internal"

# Connect via SSH
boundary connect ssh -target-id ttcp_abc123
```

**Dynamic host catalogs**:
```bash
# Auto-discover GCE instances by label
boundary host-sets create plugin \
  -host-catalog-id hcplg_123 \
  -attr filter="labels.environment=production"
```

### HCP on GCP

**HCP Vault on GCP**:
1. Create HVN (HashiCorp Virtual Network)
2. Deploy HCP Vault cluster
3. Peer HVN with GCP VPC
4. Configure firewall rules
5. Access Vault from GCP resources

Fully managed with HA, backups, and automated upgrades.

## GCP Networking for HashiCorp

### VPC Design

```
VPC (10.0.0.0/16)
├── Public Subnet - Load Balancers
├── Private Subnet - Apps, Nomad clients
└── Database Subnet - Cloud SQL
```

**Firewall Rules for HashiCorp**:
- Consul: 8300-8302, 8500, 8600
- Vault: 8200-8201
- Nomad: 4646-4648

### HCP VPC Peering

1. Create HVN in HCP Console
2. Initiate peering to GCP VPC
3. Accept peering in GCP Console
4. Update routes
5. Configure firewall rules

## Key GCP Services for HashiCorp

**Compute**: Compute Engine (Nomad, Consul, Vault), GKE (with Consul/Vault), Cloud Run
**Storage**: GCS (Terraform state, Vault snapshots), Persistent Disks
**Database**: Cloud SQL (with Vault dynamic secrets), Firestore, Cloud Spanner
**Networking**: VPC, Load Balancing, Cloud DNS (with Consul)
**Security**: Cloud KMS (Vault auto-unseal), IAM, Secret Manager
**Monitoring**: Cloud Monitoring, Cloud Logging, Cloud Trace

## Troubleshooting

### Doormat Session Expired

**Problem**: GCP credentials stopped working.

**Solution**: Re-authenticate with Doormat (sessions last 12 hours)
```bash
doormat gcp --project <project>
```

### Terraform Permission Errors

**Problem**: Terraform can't create resources.

**Solutions**:
1. Verify service account has required IAM roles
2. Check correct project: `gcloud config list`
3. Ensure Doormat session is active
4. Verify APIs are enabled: `gcloud services list`

### Vault GCP Credentials Not Working

**Problem**: Dynamic credentials from Vault don't work.

**Solutions**:
1. Check Vault GCP secrets engine configuration
2. Verify service account permissions for Vault
3. Check credential lease hasn't expired
4. Validate IAM bindings in roleset

### Consul Auto-Join Failing

**Problem**: Consul servers can't discover each other.

**Solutions**:
1. Verify instances have correct labels/tags
2. Check firewall rules allow Consul ports (8300-8302)
3. Ensure service account has `compute.instances.list` permission
4. Verify instances are in same project/zone

## Additional Resources

### HashiCorp Documentation
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Vault GCP Secrets](https://developer.hashicorp.com/vault/docs/secrets/gcp)
- [Vault GCP Auth](https://developer.hashicorp.com/vault/docs/auth/gcp)
- [Consul on GCP](https://developer.hashicorp.com/consul/tutorials/cloud-production/gcp-reference-architecture)

### Internal Resources
- [Access Google Cloud with Terraform](https://hashicorp.atlassian.net/wiki/spaces/~361427045/pages/2329051882/Access+google+cloud+terraform)

### Related Skills
- `/terraform` - Infrastructure as Code
- `/vault` - Secrets management
- `/consul` - Service mesh
- `/nomad` - Workload orchestration
- `/boundary` - Secure access
- `/hcp` - HashiCorp Cloud Platform
- `/doormat` - Authentication
- `/kubernetes` - GKE integration

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
