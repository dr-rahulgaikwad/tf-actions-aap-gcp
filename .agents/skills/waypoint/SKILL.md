---
name: waypoint
description: HCP Waypoint internal developer platform for standardizing application deployment patterns and workflows
---

# HCP Waypoint

This skill covers HCP Waypoint, an internal developer platform designed to simplify application management by standardizing patterns and workflows.

## When to Use This Skill

Use this skill when you need to:
- Standardize application deployment patterns across teams
- Create golden path templates for developers
- Provide self-service application infrastructure
- Enable developers to deploy applications without deep platform knowledge
- Manage application add-ons (databases, caches, observability, etc.)
- Enforce organizational standards and best practices
- Build an internal developer platform (IDP)

## What is HCP Waypoint?

**HCP Waypoint is an internal developer platform** that simplifies application management by enabling organizations to standardize application patterns and workflows.

### Core Purpose

Waypoint allows **platform teams** to define golden patterns and workflows, while **application developers** can deploy and manage applications at scale without needing to understand underlying infrastructure complexity.

### The Problem Waypoint Solves

**Without an Internal Developer Platform:**
- Each team reinvents deployment patterns
- Developers spend time on infrastructure instead of features
- Inconsistent tooling and processes across organization
- Manual provisioning creates bottlenecks
- Difficult to enforce security and compliance standards
- Knowledge silos prevent developers from deploying independently

**Waypoint's Solution:**
- **Templates** - Reusable patterns for creating new applications
- **Add-ons** - Pre-configured infrastructure components (databases, caches, etc.)
- **Self-service** - Developers deploy without waiting on platform teams
- **Standardization** - Consistent patterns across all applications
- **Golden paths** - Best practices baked into templates

## How Waypoint Works

### User Roles

Waypoint serves two primary audiences:

**Platform Teams:**
- Create and maintain application templates
- Define add-ons for common infrastructure needs
- Set organizational standards and guardrails
- Manage access control and permissions
- Monitor platform usage and health

**Application Developers:**
- Use existing templates to launch new projects
- Deploy applications through standardized workflows
- Add infrastructure components via add-ons
- Focus on application code, not infrastructure
- Self-service without platform team bottlenecks

### Core Concepts

**1. Templates**
- Pre-defined application patterns (e.g., "Node.js API", "React Frontend")
- Include deployment configuration, infrastructure, and tooling
- Developers create new projects from templates in seconds
- Templates can be customized per project

**2. Add-ons**
- Additional functionality integrated into applications
- Examples: PostgreSQL database, Redis cache, monitoring, logging
- One-click deployment of complex infrastructure
- Pre-configured with security and best practices

**3. Actions**
- Automated workflows triggered by events
- Examples: Deploy on git push, run tests, update dependencies
- CI/CD pipelines built into the platform
- Customizable per application or template

**4. Variables**
- Configuration values managed centrally
- Environment-specific settings (dev, staging, prod)
- Secrets management integration
- Inherited from templates or set per application

## Key Features

| Feature | Description |
| --- | --- |
| **Application Templates** | Reusable patterns for creating applications with best practices |
| **Infrastructure Add-ons** | One-click deployment of databases, caches, and services |
| **Self-Service Deployment** | Developers deploy without platform team intervention |
| **GitOps Integration** | Deploy automatically from git repositories |
| **Multi-Cloud Support** | Deploy to AWS, Azure, GCP, Kubernetes |
| **Role-Based Access Control** | Manage who can access different Waypoint functions |
| **HCP Managed** | Fully managed service via HashiCorp Cloud Platform |
| **Terraform Integration** | Leverage Terraform modules for infrastructure |

## Installation & Setup

### HCP Waypoint (Managed Service)

Waypoint is available as a fully managed service on HCP.

**Getting Started:**

1. **Sign up for HCP:**
   - Visit https://portal.cloud.hashicorp.com
   - Create an account or sign in

2. **Create a Waypoint instance:**
   - Navigate to Waypoint in HCP
   - Click "Create Waypoint cluster"
   - Choose your cloud provider and region

3. **Install Waypoint CLI:**

   **macOS (Homebrew):**
   ```bash
   brew install hashicorp/tap/waypoint
   ```

   **Linux:**
   ```bash
   wget https://releases.hashicorp.com/waypoint/<version>/waypoint_<version>_linux_amd64.zip
   unzip waypoint_<version>_linux_amd64.zip
   sudo mv waypoint /usr/local/bin/
   ```

4. **Verify Installation:**
   ```bash
   waypoint version
   ```

5. **Connect to HCP Waypoint:**
   ```bash
   waypoint login -from-hcp
   ```

### Setting Up Your First Template

**As a Platform Team Member:**

1. **Create a template configuration:**
   ```hcl
   # waypoint.hcl
   template "nodejs-api" {
     name        = "Node.js API"
     description = "Standard Node.js REST API with PostgreSQL"

     labels = {
       "template-type" = "backend"
       "language"      = "nodejs"
     }
   }
   ```

2. **Define template infrastructure:**
   ```hcl
   variable "app_name" {
     type        = string
     description = "Name of the application"
   }

   app "api" {
     build {
       use "docker" {}
     }

     deploy {
       use "kubernetes" {
         namespace = var.app_name
       }
     }
   }
   ```

3. **Publish the template:**
   ```bash
   waypoint template create -hcl=waypoint.hcl
   ```

## Common Commands

### Working with Templates

**List available templates:**
```bash
waypoint template list
```

**Create a new application from a template:**
```bash
waypoint app create -from-template=nodejs-api -name=my-new-api
```

**Inspect a template:**
```bash
waypoint template inspect nodejs-api
```

### Managing Applications

**List applications:**
```bash
waypoint app list
```

**Deploy an application:**
```bash
waypoint up
```

**View deployment status:**
```bash
waypoint status
```

**View application logs:**
```bash
waypoint logs
```

**Destroy an application:**
```bash
waypoint destroy
```

### Working with Add-ons

**List available add-ons:**
```bash
waypoint addon list
```

**Add infrastructure to your application:**
```bash
waypoint addon create postgres -name=my-database
```

**View add-on details:**
```bash
waypoint addon inspect my-database
```

**Remove an add-on:**
```bash
waypoint addon destroy my-database
```

### Variables and Configuration

**Set a variable:**
```bash
waypoint var set DATABASE_URL="postgres://..."
```

**List variables:**
```bash
waypoint var list
```

**Delete a variable:**
```bash
waypoint var delete DATABASE_URL
```

## Common Workflows

### Workflow 1: Platform Team Creating a Template

**Scenario:** Create a standardized Python Flask API template

1. **Create template structure:**
   ```
   python-flask-template/
   ├── waypoint.hcl
   ├── Dockerfile
   ├── app/
   │   └── main.py
   └── requirements.txt
   ```

2. **Define waypoint.hcl:**
   ```hcl
   template "python-flask-api" {
     name        = "Python Flask API"
     description = "Standard Flask REST API with PostgreSQL and Redis"

     labels = {
       "type"     = "backend"
       "language" = "python"
     }
   }

   variable "app_name" {
     type        = string
     description = "Application name"
   }

   variable "environment" {
     type        = string
     default     = "development"
     description = "Deployment environment"
   }

   app "flask-api" {
     build {
       use "docker" {}
     }

     deploy {
       use "kubernetes" {
         namespace = var.app_name
         replicas  = var.environment == "production" ? 3 : 1

         service_port = 8080
       }
     }
   }

   # Add PostgreSQL database
   addon "database" {
     use "postgres" {
       version = "15"
     }
   }

   # Add Redis cache
   addon "cache" {
     use "redis" {
       version = "7"
     }
   }
   ```

3. **Publish template to HCP Waypoint:**
   ```bash
   cd python-flask-template
   waypoint template create -hcl=waypoint.hcl
   ```

4. **Test the template:**
   ```bash
   waypoint app create -from-template=python-flask-api -name=test-api
   ```

### Workflow 2: Developer Creating Application from Template

**Scenario:** Developer wants to create a new microservice

1. **Browse available templates:**
   ```bash
   waypoint template list
   ```

2. **Create application from template:**
   ```bash
   waypoint app create \
     -from-template=nodejs-api \
     -name=user-service \
     -var="environment=development"
   ```

3. **Clone generated repository:**
   ```bash
   git clone <generated-repo-url>
   cd user-service
   ```

4. **Customize application code:**
   ```bash
   # Edit application files as needed
   vim src/index.js
   ```

5. **Deploy the application:**
   ```bash
   waypoint up
   ```

6. **View the deployed application:**
   ```bash
   waypoint status
   waypoint logs -f
   ```

### Workflow 3: Adding Infrastructure with Add-ons

**Scenario:** Add PostgreSQL database to an existing application

1. **View available add-ons:**
   ```bash
   waypoint addon list
   ```

2. **Add PostgreSQL database:**
   ```bash
   waypoint addon create postgres \
     -name=user-db \
     -var="size=small" \
     -var="version=15"
   ```

3. **Get connection details:**
   ```bash
   waypoint addon inspect user-db
   ```

4. **Add connection string as variable:**
   ```bash
   waypoint var set DATABASE_URL="$(waypoint addon output user-db connection_string)"
   ```

5. **Re-deploy application with new variable:**
   ```bash
   waypoint up
   ```

### Workflow 4: GitOps Deployment

**Scenario:** Automatically deploy on git push

1. **Configure git repository in waypoint.hcl:**
   ```hcl
   app "my-app" {
     runner {
       enabled = true

       poll {
         enabled  = true
         interval = "30s"
       }
     }

     build {
       use "docker" {}
     }

     deploy {
       use "kubernetes" {}
     }
   }
   ```

2. **Connect repository:**
   ```bash
   waypoint config source-git set \
     -git-url="https://github.com/org/my-app.git" \
     -git-ref="main"
   ```

3. **Initialize runner:**
   ```bash
   waypoint runner install
   ```

4. **Push code to trigger deployment:**
   ```bash
   git commit -am "Update feature"
   git push origin main
   # Waypoint automatically builds and deploys
   ```

## Troubleshooting

### Issue 1: Template Creation Fails

**Symptoms:**
- Error: "template validation failed"
- Template not appearing in list

**Cause:**
- Invalid HCL syntax
- Missing required fields
- Incorrect template structure

**Solution:**
```bash
# Validate HCL syntax
waypoint template validate waypoint.hcl

# Check for required fields
cat waypoint.hcl | grep -E "(name|description)"

# View detailed error
waypoint template create -hcl=waypoint.hcl -verbose
```

### Issue 2: Application Won't Deploy

**Symptoms:**
- `waypoint up` fails
- Deployment stuck in pending state

**Cause:**
- Missing credentials or permissions
- Resource constraints (CPU/memory)
- Network connectivity issues
- Invalid configuration

**Solution:**
```bash
# Check deployment logs
waypoint logs -deployment=<deployment-id>

# Verify credentials
waypoint config get

# Check resource availability
kubectl get nodes  # for Kubernetes deployments

# Validate configuration
waypoint config validate
```

### Issue 3: Add-on Not Connecting

**Symptoms:**
- Application can't connect to database
- Connection timeouts

**Cause:**
- Incorrect connection string
- Network policies blocking traffic
- Add-on not fully provisioned

**Solution:**
```bash
# Check add-on status
waypoint addon inspect <addon-name>

# Verify connection details
waypoint addon output <addon-name>

# Test connectivity from application
waypoint exec -- curl <addon-endpoint>

# Check network policies
kubectl get networkpolicies
```

### Issue 4: Variables Not Updating

**Symptoms:**
- Application still using old variable values
- Environment variables not reflected

**Cause:**
- Application not redeployed after variable change
- Variable scope incorrect
- Cached values

**Solution:**
```bash
# Verify variable is set
waypoint var list

# Redeploy application
waypoint up

# Force restart
waypoint destroy
waypoint up

# Check variable scope
waypoint var get <var-name> -verbose
```

## Best Practices

### Template Design
- **Keep templates simple** - Start with minimal configuration
- **Use variables** for customization points
- **Include documentation** in template descriptions
- **Version templates** to allow updates without breaking existing apps
- **Test thoroughly** before publishing to developers

### Application Management
- **Use GitOps** for deployment automation
- **Set sensible defaults** in templates for common configurations
- **Tag applications** with metadata (team, environment, cost-center)
- **Monitor resource usage** to optimize costs
- **Automate cleanup** of old deployments

### Add-on Strategy
- **Pre-configure add-ons** with security best practices
- **Use managed services** where possible for reliability
- **Standardize naming** for consistency
- **Document connection patterns** for each add-on type
- **Enable monitoring** by default on all add-ons

### Security
- **Use RBAC** to control access to templates and applications
- **Store secrets** in integrated secret managers (Vault)
- **Scan container images** in templates
- **Enable audit logging** for compliance
- **Enforce network policies** between applications

### Platform Team Operations
- **Gather feedback** from developers regularly
- **Iterate on templates** based on usage patterns
- **Provide examples** and documentation
- **Monitor platform health** and performance
- **Plan for disaster recovery** and backup

## HashiCorp-Specific Tips

### Integration with Terraform

Waypoint templates can leverage Terraform for infrastructure:

```hcl
addon "infrastructure" {
  use "terraform" {
    module = "git::https://github.com/org/terraform-modules//vpc"

    variables = {
      vpc_cidr = "10.0.0.0/16"
      region   = var.region
    }
  }
}
```

### HCP Waypoint Benefits

**Why Use HCP Waypoint:**
- Fully managed - no infrastructure to maintain
- Automatic updates and patches
- Built-in high availability
- Integration with HCP Vault for secrets
- Global deployment options

### Waypoint vs. Other HashiCorp Tools

**Waypoint vs. Terraform:**
- **Terraform** - Infrastructure provisioning (lower level)
- **Waypoint** - Application deployment platform (higher level)
- Use together: Terraform for infrastructure, Waypoint for applications

**Waypoint vs. Nomad:**
- **Nomad** - Workload orchestrator (like Kubernetes)
- **Waypoint** - Developer platform built on top of orchestrators
- Waypoint can deploy to Nomad clusters

### Common Template Patterns

**Multi-tier Application:**
```hcl
app "frontend" {
  build { use "docker" {} }
  deploy { use "kubernetes" {} }
}

app "backend" {
  build { use "docker" {} }
  deploy { use "kubernetes" {} }
}

addon "database" {
  use "postgres" {}
}

addon "cache" {
  use "redis" {}
}
```

## Additional Resources

- **Official Waypoint Documentation**: https://developer.hashicorp.com/waypoint
- **HCP Waypoint**: https://portal.cloud.hashicorp.com
- **Waypoint Learn**: https://developer.hashicorp.com/waypoint/tutorials
- **Waypoint GitHub**: https://github.com/hashicorp/waypoint
- **Community Forum**: https://discuss.hashicorp.com/c/waypoint

## Summary

**Most Common Commands:**
```bash
# Template management (platform teams)
waypoint template list
waypoint template create -hcl=waypoint.hcl
waypoint template inspect <name>

# Application management (developers)
waypoint app create -from-template=<template> -name=<app>
waypoint up                    # Deploy
waypoint status                # Check deployment
waypoint logs                  # View logs
waypoint destroy               # Remove deployment

# Add-on management
waypoint addon list
waypoint addon create <type> -name=<name>
waypoint addon inspect <name>

# Variable management
waypoint var set KEY=value
waypoint var list
```

**Quick Start for Developers:**
```
1. List templates → waypoint template list
2. Create app → waypoint app create -from-template=nodejs-api -name=my-app
3. Clone repo → git clone <repo-url>
4. Deploy → waypoint up
5. View status → waypoint status
```

**Quick Start for Platform Teams:**
```
1. Create template → waypoint.hcl
2. Define infrastructure → apps, add-ons, variables
3. Publish → waypoint template create
4. Document → provide examples and guides
5. Iterate → gather feedback and improve
```

**Remember:**
- Waypoint is a platform for platforms - enables self-service
- Templates encode organizational best practices
- Add-ons provide one-click infrastructure
- GitOps enables automated deployments
- HCP Waypoint is fully managed
- Focus on developer experience and productivity
