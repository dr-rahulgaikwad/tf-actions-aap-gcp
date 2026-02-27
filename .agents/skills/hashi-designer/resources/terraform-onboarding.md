# Terraform Designer Onboarding

This document provides essential Terraform knowledge for designers working on Terraform products (HCP Terraform, Terraform Enterprise, or Terraform CLI).

---

## Phase 0: Design @ HashiCorp

### Design Team Structure
- Design works alongside PM and Engineering in product teams
- Research is a shared resource across teams
- Design System team maintains Helios

### Design Tools
- **Figma**: Primary design tool
- **Helios**: HashiCorp Design System
- **GitHub**: Design specs and handoff
- **Notion/Confluence**: Documentation

### Design Rituals
- Design critiques (weekly)
- Design reviews (per project milestone)
- Cross-team syncs

---

## Phase 1: HashiCorp & Terraform Context

### HashiCorp's Mission
Enable organizations to adopt consistent workflows for provisioning, securing, connecting, and running any infrastructure for any application.

### Product Portfolio
| Product | Purpose |
|---------|---------|
| **Terraform** | Infrastructure provisioning |
| **Vault** | Secrets management |
| **Consul** | Service networking |
| **Nomad** | Workload orchestration |
| **Boundary** | Access management |
| **Packer** | Machine image building |
| **Waypoint** | Application deployment |
| **Vagrant** | Development environments |

### Where Terraform Fits
Terraform is the **provisioning** layer—it creates and manages the infrastructure that other tools then secure (Vault), connect (Consul), and run workloads on (Nomad).

---

## Phase 2: Understanding Terraform

### What is Infrastructure as Code (IaC)?
Managing infrastructure through configuration files instead of manual processes. Benefits:
- **Version control**: Track changes over time
- **Reproducibility**: Same config = same infrastructure
- **Automation**: No manual clicking in cloud consoles
- **Collaboration**: Teams can review infrastructure changes

### The Terraform Workflow

```
┌─────────┐    ┌─────────┐    ┌─────────┐
│  Write  │ → │  Plan   │ → │  Apply  │
└─────────┘    └─────────┘    └─────────┘
     │              │              │
     │              │              │
   Author        Preview        Execute
    HCL          changes        changes
```

1. **Write**: Author infrastructure configuration in HCL
2. **Plan**: Preview what Terraform will create/change/destroy
3. **Apply**: Execute the plan to modify real infrastructure

### Key Terminology

| Term | Definition |
|------|------------|
| **Resource** | A single piece of infrastructure (e.g., AWS EC2 instance) |
| **Provider** | Plugin that connects Terraform to a cloud/service (e.g., AWS, Azure) |
| **Module** | Reusable group of resources |
| **State** | Terraform's record of what infrastructure exists |
| **Configuration** | The `.tf` files that define desired infrastructure |
| **Run** | One execution of the plan/apply workflow |

---

## Phase 3: CE vs HCP Terraform vs TFE

### Product Comparison

| Aspect | Terraform CLI (CE) | HCP Terraform | Terraform Enterprise |
|--------|-------------------|---------------|---------------------|
| **Hosting** | Local machine | HashiCorp managed cloud | Self-hosted |
| **Users** | Individual practitioners | Teams | Enterprise orgs |
| **State** | Local file | Remote, managed | Remote, self-managed |
| **Collaboration** | Manual | Built-in | Built-in |
| **Cost** | Free | Free tier + paid | License |
| **Compliance** | N/A | SOC2, etc. | Air-gapped, custom |

### When Customers Choose Each

- **CLI**: Learning, personal projects, simple automation
- **HCP Terraform**: Teams needing collaboration, remote state, CI/CD integration
- **Enterprise**: Large orgs with compliance requirements, air-gapped environments

### UI Implications
- CLI users may never see HCP Terraform UI
- HCP Terraform UI should make collaboration seamless
- Enterprise UI must support audit, compliance, governance features

---

## Phase 4: HCL Language & State

### HCL Basics (HashiCorp Configuration Language)

```hcl
# Define a provider
provider "aws" {
  region = "us-west-2"
}

# Define a resource
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}

# Use a variable
variable "environment" {
  default = "dev"
}

# Output a value
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

### State: Why It Matters

**State** is a JSON file that maps your configuration to real infrastructure:
- Tracks resource IDs, attributes, dependencies
- Enables Terraform to know what exists vs. what's defined
- Must be stored safely (contains sensitive data)

**State Management Challenges**:
- **Locking**: Prevent concurrent modifications
- **Security**: State may contain secrets
- **Sharing**: Teams need access to same state
- **Backup**: State loss = Terraform "forgets" infrastructure

**This is why HCP Terraform exists**: It solves state management for teams.

---

## Phase 5: Terraform Ecosystem

### Providers
Plugins that connect Terraform to services:
- **Cloud**: AWS, Azure, GCP, Oracle, Alibaba
- **SaaS**: GitHub, PagerDuty, Datadog
- **Infrastructure**: Kubernetes, Docker, VMware

There are 3,000+ providers in the registry.

### Modules
Reusable infrastructure components:
- **Public Registry**: Community-contributed modules
- **Private Registry**: Organization's internal modules
- **Module composition**: Modules can call other modules

### Registry (registry.terraform.io)
- Discover providers and modules
- Version management
- Documentation hosting
- Usage examples

---

## Phase 6: Cloud Service Providers

Designers should understand these cloud concepts:

### Common Resources
| Resource Type | AWS | Azure | GCP |
|---------------|-----|-------|-----|
| Virtual Machine | EC2 | Virtual Machine | Compute Engine |
| Storage | S3 | Blob Storage | Cloud Storage |
| Database | RDS | SQL Database | Cloud SQL |
| Network | VPC | Virtual Network | VPC |
| Serverless | Lambda | Functions | Cloud Functions |

### Why This Matters for Design
- Users think in cloud provider terms ("I want an EC2")
- Error messages reference provider-specific concepts
- Documentation must bridge Terraform ↔ provider terminology

---

## Phase 7: Advanced Concepts (Optional)

### Workspaces
Isolated environments for the same configuration:
- Dev, staging, production from one codebase
- Each workspace has its own state
- Variables can differ per workspace

### Remote Operations
Running Terraform in HCP Terraform instead of locally:
- Consistent execution environment
- Centralized logs and history
- Team visibility into runs

### Policy as Code
Enforce rules on infrastructure:
- **Sentinel** (HashiCorp): Policy language for Terraform
- **OPA** (Open Policy Agent): Alternative policy engine
- Example: "No S3 buckets without encryption"

### Cost Estimation
Preview infrastructure costs before applying:
- Integrates with cloud pricing APIs
- Shows estimated monthly cost
- Helps with budget planning

---

## Key Workflows Designers Should Know

### Creating an Organization
1. Sign up / Log in
2. Create organization (name, email)
3. Invite team members
4. Configure SSO (enterprise)

### Creating a Workspace
1. Choose workflow: VCS-driven, CLI-driven, or API-driven
2. Connect to repository (if VCS)
3. Configure variables
4. Set execution mode

### Running Terraform
1. Trigger run (commit, manual, API)
2. Plan phase executes
3. Review plan output
4. Approve or discard
5. Apply phase executes
6. View results

### Using Modules
1. Browse registry
2. Read documentation
3. Add module block to configuration
4. Configure inputs
5. Run plan/apply

---

## Design Principles for Terraform Products

### From UXDR-014: Invisible First

1. **Silence is Success**
   - When automation works, UI should be minimal
   - Users shouldn't need to monitor dashboards

2. **GitHub is Primary**
   - Developers live in GitHub
   - TFC links TO GitHub, doesn't duplicate it
   - PR comments > TFC dashboard for scan results

3. **Automation Over Manual**
   - De-emphasize "Run Now" buttons
   - Trust in automation should be the default
   - Manual triggers = exception, not rule

4. **Progressive Disclosure**
   - Summary view by default
   - Details available on-demand
   - Don't front-load complexity

5. **Attention-Required Over Status**
   - Lead with problems ("3 workspaces need attention")
   - Don't lead with stats ("47 runs completed")
   - Success = quiet; problems = visible

### Practical Applications

| Instead of... | Do this... |
|---------------|------------|
| Detailed run status dashboard | Single-line health summary |
| Prominent "Scan Now" button | Overflow menu action |
| 5-stage progress indicator | 3 states: Running/Success/Failed |
| List all workspaces equally | Group by "Needs Attention" vs "Healthy" |

---

## Quick Reference

### CLI Commands
```bash
terraform init      # Initialize, download providers
terraform plan      # Preview changes
terraform apply     # Execute changes
terraform destroy   # Remove all infrastructure
terraform fmt       # Format code
terraform validate  # Check syntax
```

### Common Objects in HCP Terraform

| Object | Description |
|--------|-------------|
| Organization | Top-level container, billing entity |
| Workspace | Environment for one infrastructure config |
| Run | Single plan/apply execution |
| State Version | Snapshot of state at a point in time |
| Variable | Input value (can be sensitive) |
| Team | Group of users with permissions |
| Policy Set | Collection of Sentinel policies |
| Module | Published in private registry |

### Information Architecture

```
Organization
├── Workspaces
│   ├── Runs
│   │   └── Plan / Apply / Policy Check
│   ├── State Versions
│   ├── Variables
│   └── Settings
├── Teams
│   └── Members
├── Settings
│   ├── VCS Providers
│   ├── SSO
│   └── Cost Estimation
└── Registry
    └── Modules
```
