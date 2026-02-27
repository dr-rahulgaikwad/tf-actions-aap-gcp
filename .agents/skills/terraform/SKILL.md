---
name: terraform
description: HashiCorp Terraform infrastructure as code (IaC) tool for provisioning and managing cloud and on-premises resources
---

# HashiCorp Terraform

This skill covers HashiCorp Terraform, an infrastructure as code (IaC) tool that allows you to define, provision, and manage infrastructure using declarative configuration files.

## When to Use This Skill

Use this skill when you need to:
- Provision and manage cloud infrastructure (AWS, Azure, GCP, etc.)
- Define infrastructure as code using declarative syntax
- Create repeatable, consistent infrastructure deployments
- Manage infrastructure lifecycle (create, update, destroy)
- Version control your infrastructure alongside application code
- Collaborate on infrastructure changes with teams

## What is Terraform?

**Terraform is an Infrastructure as Code (IaC) tool** that allows users to **define and manage infrastructure** (cloud or on-premises) using **human-readable configuration files**.

### Core Purpose

Terraform enables you to:
- **Define infrastructure declaratively** - Describe the desired end state, not the steps to get there
- **Provision across multiple platforms** - Manage resources from 1700+ providers
- **Version control infrastructure** - Track changes like application code
- **Collaborate safely** - Review, approve, and apply changes as a team

### Why Infrastructure as Code?

**The Problem:**
- Manual infrastructure provisioning is error-prone and inconsistent
- Infrastructure sprawl across teams and clouds is difficult to manage
- No audit trail of who changed what and when
- Difficult to replicate environments (dev, staging, prod)
- Knowledge locked in individual team members' heads

**The Solution:**
Terraform centralizes infrastructure management to:
- **Codify infrastructure** in version-controlled files
- **Ensure consistency** through repeatable deployments
- **Enable collaboration** with code review workflows
- **Maintain audit trails** of all changes
- **Automate provisioning** and reduce human error

## How Terraform Works

### Providers

Terraform uses **providers** to interact with APIs from platforms like:
- **Cloud Platforms**: AWS, GCP, Azure, Oracle Cloud, Alibaba Cloud
- **Kubernetes & Container**: Kubernetes, Docker, Helm
- **SaaS**: GitHub, Datadog, PagerDuty, Okta
- **Databases**: PostgreSQL, MySQL, MongoDB Atlas
- **Network**: Cloudflare, NS1, DNS
- **And 1700+ more** via [Terraform Registry](https://registry.terraform.io/)

Each provider offers **resources** (things to create) and **data sources** (things to query).

### Core Workflow

The fundamental Terraform workflow has three steps:

1. **Write** - Define desired infrastructure using HCL (HashiCorp Configuration Language)
   ```hcl
   resource "aws_instance" "web" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
   }
   ```

2. **Plan** - Terraform creates an execution plan showing what will be created/updated/destroyed
   ```bash
   terraform plan
   ```
   Reviews changes before applying them (safety check)

3. **Apply** - Terraform provisions the infrastructure, respecting dependency order
   ```bash
   terraform apply
   ```
   Makes actual changes to match the desired state

### State Management

Terraform maintains a **state file** that:
- Tracks the current state of your infrastructure
- Maps configuration to real-world resources
- Stores metadata and performance optimizations
- Enables collaboration when stored remotely (Terraform Cloud, S3, etc.)

## Key Features

| Feature | Description |
| --- | --- |
| **Manage Any Infrastructure** | Works across multiple clouds and services via providers |
| **Immutable & Predictable** | Changes are planned first, applied only after approval |
| **Track Infrastructure** | State file serves as single source of truth |
| **Automate Safely** | Declarative configs eliminate manual provisioning logic |
| **Standardize via Modules** | Reusable modules enforce best practices and reduce duplication |
| **Collaborate with Teams** | Terraform Cloud provides remote state, RBAC, private registry, VCS-driven workflows |
| **Dependency Management** | Automatically handles resource dependencies and parallelizes operations |
| **Drift Detection** | Detects when real infrastructure differs from configuration |

## Installation & Setup

### Install Terraform CLI

**macOS (Homebrew):**
```bash
brew install terraform
```

**Linux:**
```bash
# Download from releases
wget https://releases.hashicorp.com/terraform/<version>/terraform_<version>_linux_amd64.zip
unzip terraform_<version>_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify Installation:**
```bash
terraform version
```

### Basic Project Setup

1. **Create a directory for your Terraform config:**
   ```bash
   mkdir my-infrastructure
   cd my-infrastructure
   ```

2. **Create a configuration file (`main.tf`):**
   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }

   provider "aws" {
     region = "us-west-2"
   }

   resource "aws_instance" "example" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"

     tags = {
       Name = "TerraformExample"
     }
   }
   ```

3. **Initialize the working directory:**
   ```bash
   terraform init
   ```
   This downloads provider plugins and sets up the backend.

4. **Review the execution plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Common Commands

### Essential Workflow Commands

**Initialize a working directory:**
```bash
terraform init
```
Downloads providers, initializes backend, prepares directory.

**Validate configuration syntax:**
```bash
terraform validate
```

**Format configuration files:**
```bash
terraform fmt
```
Automatically formats HCL files to canonical style.

**Plan changes:**
```bash
terraform plan
terraform plan -out=plan.tfplan   # Save plan to file
```

**Apply changes:**
```bash
terraform apply
terraform apply plan.tfplan        # Apply saved plan
terraform apply -auto-approve      # Skip confirmation (use carefully!)
```

**Destroy infrastructure:**
```bash
terraform destroy
```

### State Management

**Show current state:**
```bash
terraform show
```

**List resources in state:**
```bash
terraform state list
```

**Show specific resource:**
```bash
terraform state show aws_instance.example
```

**Remove resource from state (without destroying):**
```bash
terraform state rm aws_instance.example
```

**Import existing resource:**
```bash
terraform import aws_instance.example i-1234567890abcdef0
```

### Workspace Management

Workspaces allow multiple state files in one configuration:

```bash
terraform workspace list           # List workspaces
terraform workspace new dev        # Create workspace
terraform workspace select dev     # Switch workspace
terraform workspace show           # Show current workspace
```

### Output and Variables

**Show outputs:**
```bash
terraform output
terraform output instance_ip       # Show specific output
```

**Apply with variable:**
```bash
terraform apply -var="instance_type=t2.small"
terraform apply -var-file="prod.tfvars"
```

## Configuration Basics

### Resource Block

```hcl
resource "resource_type" "resource_name" {
  argument1 = "value1"
  argument2 = "value2"
}
```

### Variables

**Define variables:**
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "availability_zones" {
  description = "AZs to deploy to"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}
```

**Use variables:**
```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
}
```

### Outputs

```hcl
output "instance_ip" {
  description = "Public IP of instance"
  value       = aws_instance.web.public_ip
}
```

### Data Sources

Query existing infrastructure:
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
}
```

### Modules

**Using a module:**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

## Common Workflows

### Workflow 1: Creating New Infrastructure

1. **Write configuration:**
   ```hcl
   resource "aws_s3_bucket" "website" {
     bucket = "my-website-bucket"

     tags = {
       Environment = "Production"
       ManagedBy   = "Terraform"
     }
   }
   ```

2. **Initialize and validate:**
   ```bash
   terraform init
   terraform validate
   terraform fmt
   ```

3. **Review changes:**
   ```bash
   terraform plan
   ```

4. **Apply changes:**
   ```bash
   terraform apply
   ```

### Workflow 2: Updating Existing Infrastructure

1. **Modify configuration:**
   ```hcl
   resource "aws_s3_bucket" "website" {
     bucket = "my-website-bucket"

     tags = {
       Environment = "Production"
       ManagedBy   = "Terraform"
       Owner       = "Platform Team"  # Added tag
     }
   }
   ```

2. **Review what will change:**
   ```bash
   terraform plan
   ```
   Terraform shows which resources will be updated.

3. **Apply changes:**
   ```bash
   terraform apply
   ```

### Workflow 3: Using Modules for Reusability

1. **Create a module directory structure:**
   ```
   modules/
   └── web-server/
       ├── main.tf
       ├── variables.tf
       └── outputs.tf
   ```

2. **Define module (modules/web-server/main.tf):**
   ```hcl
   resource "aws_instance" "web" {
     ami           = var.ami_id
     instance_type = var.instance_type

     tags = {
       Name = var.server_name
     }
   }
   ```

3. **Use module in root configuration:**
   ```hcl
   module "prod_server" {
     source = "./modules/web-server"

     ami_id        = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.large"
     server_name   = "prod-web-01"
   }

   module "dev_server" {
     source = "./modules/web-server"

     ami_id        = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
     server_name   = "dev-web-01"
   }
   ```

4. **Initialize and apply:**
   ```bash
   terraform init    # Downloads modules
   terraform apply
   ```

### Workflow 4: Team Collaboration with Remote State

1. **Configure remote backend (e.g., S3):**
   ```hcl
   terraform {
     backend "s3" {
       bucket = "my-terraform-state"
       key    = "prod/terraform.tfstate"
       region = "us-west-2"
     }
   }
   ```

2. **Initialize with backend:**
   ```bash
   terraform init
   ```

3. **Team members work with shared state:**
   - State is locked during operations
   - Prevents concurrent modifications
   - Everyone sees the same infrastructure state

### Workflow 5: Importing Existing Infrastructure

1. **Write configuration for existing resource:**
   ```hcl
   resource "aws_instance" "existing" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
   }
   ```

2. **Import the resource:**
   ```bash
   terraform import aws_instance.existing i-1234567890abcdef0
   ```

3. **Verify and update configuration to match:**
   ```bash
   terraform plan
   ```
   Adjust configuration until plan shows no changes.

## Troubleshooting

### Issue 1: State Lock Errors

**Symptoms:**
- Error: "Error acquiring the state lock"
- Cannot run terraform commands

**Cause:**
- Another process is modifying the state
- Previous operation crashed without releasing lock

**Solution:**
```bash
# Wait for other operation to complete, or force unlock (dangerous!)
terraform force-unlock <lock-id>

# Only use force-unlock if you're certain no other process is running
```

### Issue 2: Resource Already Exists

**Symptoms:**
- Error: "resource already exists"
- Cannot create infrastructure

**Cause:**
- Resource was created outside Terraform
- State file doesn't reflect reality

**Solution:**
```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Or remove from configuration and use data source instead
```

### Issue 3: Provider Authentication Errors

**Symptoms:**
- Error: "authentication failed"
- Cannot connect to cloud provider

**Cause:**
- Missing or invalid credentials
- Incorrect provider configuration

**Solution:**
```bash
# For AWS - check credentials
aws configure list

# For Terraform Cloud - login
terraform login

# Verify provider block has correct configuration
```

### Issue 4: Dependency Cycle Errors

**Symptoms:**
- Error: "Cycle: resource.a → resource.b → resource.a"

**Cause:**
- Circular dependency between resources

**Solution:**
- Review `depends_on` declarations
- Restructure resources to remove circular references
- Use explicit dependency ordering

### Issue 5: State Drift

**Symptoms:**
- Terraform wants to recreate resources that weren't changed
- Resources modified outside Terraform

**Cause:**
- Manual changes to infrastructure
- Other tools modifying resources

**Solution:**
```bash
# Refresh state to detect changes
terraform refresh

# Review drift
terraform plan

# Options:
# 1. Apply to revert manual changes
# 2. Update configuration to match reality
# 3. Import changed resources
```

## Best Practices

### Configuration Management
- **Use version control** for all Terraform configurations
- **Organize with modules** for reusable, maintainable code
- **Use variables** for environment-specific values
- **Document with comments** for complex logic
- **Follow naming conventions** for resources and variables

### State Management
- **Use remote state** for team collaboration (Terraform Cloud, S3, etc.)
- **Enable state locking** to prevent concurrent modifications
- **Never edit state manually** - use `terraform state` commands
- **Backup state files** regularly
- **Use separate states** for different environments (dev, staging, prod)

### Security
- **Never commit secrets** to version control
- **Use environment variables** or secret management tools (Vault)
- **Restrict backend access** with proper IAM/RBAC
- **Enable encryption** for state files (at rest and in transit)
- **Review plans carefully** before applying

### Workflow
- **Always run `terraform plan`** before apply
- **Use `-target` sparingly** (only for specific resource operations)
- **Format code** with `terraform fmt` before committing
- **Validate** with `terraform validate` in CI/CD
- **Use workspaces** for environment separation when appropriate
- **Tag resources** for better organization and cost tracking

### Modules
- **Keep modules focused** on a single responsibility
- **Version modules** using git tags or registry versions
- **Document module inputs/outputs** clearly
- **Test modules** before using in production
- **Use public modules** from Terraform Registry when possible

## HashiCorp-Specific Tips

### Terraform Cloud / Terraform Enterprise

**Terraform Cloud** is the managed service offering that provides:
- **Remote state management** with locking and encryption
- **VCS integration** for GitOps workflows
- **Private module registry** for sharing modules
- **Sentinel policies** for governance and compliance
- **Cost estimation** before applying changes
- **RBAC** for team collaboration
- **Run history** and audit logs

**Using Terraform Cloud:**
```hcl
terraform {
  cloud {
    organization = "my-org"

    workspaces {
      name = "my-workspace"
    }
  }
}
```

**Login:**
```bash
terraform login
```

### Integration with Other HashiCorp Tools

**With Vault:**
- Retrieve secrets from Vault during Terraform runs
- Use Vault provider to manage Vault resources
```hcl
data "vault_generic_secret" "db" {
  path = "secret/database"
}

resource "aws_db_instance" "default" {
  password = data.vault_generic_secret.db.data["password"]
}
```

**With Consul:**
- Store Terraform state in Consul
- Use Consul for service discovery in infrastructure
```hcl
terraform {
  backend "consul" {
    address = "consul.example.com"
    path    = "terraform/state"
  }
}
```

**With Nomad:**
- Provision infrastructure for Nomad clusters
- Use Terraform to deploy Nomad jobs
```hcl
resource "nomad_job" "app" {
  jobspec = file("${path.module}/app.nomad")
}
```

### HCP Terraform

**HCP Terraform** (formerly Terraform Cloud) is the fully managed platform:
- SaaS offering with enterprise features
- No infrastructure to maintain
- Built-in security and compliance
- Global availability

### Common HashiCorp Libraries

When developing Terraform providers or extending Terraform:
- `terraform-plugin-sdk` - SDK for building providers
- `terraform-plugin-framework` - Modern provider development framework
- `hcl` - HashiCorp Configuration Language parser

## Additional Resources

- **Official Terraform Documentation**: https://developer.hashicorp.com/terraform
- **Terraform Learn**: https://developer.hashicorp.com/terraform/tutorials
- **Terraform Registry**: https://registry.terraform.io
- **Terraform Language**: https://developer.hashicorp.com/terraform/language
- **Terraform CLI**: https://developer.hashicorp.com/terraform/cli
- **HCP Terraform**: https://developer.hashicorp.com/hcp/docs/terraform
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/~7120203b08a819769e47afa57115b188ef7efc/pages/4058677307/Terraform

## Summary

**Most Common Commands:**
```bash
# Workflow
terraform init                     # Initialize directory
terraform validate                 # Check syntax
terraform fmt                      # Format code
terraform plan                     # Preview changes
terraform apply                    # Apply changes
terraform destroy                  # Destroy infrastructure

# State management
terraform state list               # List resources
terraform state show <resource>    # Show resource details
terraform import <resource> <id>   # Import existing resource

# Workspaces
terraform workspace list           # List workspaces
terraform workspace new <name>     # Create workspace
terraform workspace select <name>  # Switch workspace

# Outputs
terraform output                   # Show all outputs
terraform output <name>            # Show specific output
```

**Quick Reference:**
```hcl
# Resource
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}

# Variable
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# Output
output "instance_ip" {
  value = aws_instance.web.public_ip
}

# Data source
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
}

# Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
```

**Remember:**
- Terraform workflow: **Write → Plan → Apply**
- Always run `terraform plan` before `apply`
- State file is the source of truth - protect it
- Use modules for reusable infrastructure components
- Version control everything (except secrets!)
- Use Terraform Cloud for team collaboration
- Test changes in non-production first
- Tag resources for organization and cost tracking
