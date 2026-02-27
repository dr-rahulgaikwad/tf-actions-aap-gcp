---
name: sentinel
description: HashiCorp Sentinel policy-as-code framework for fine-grained, logic-based policy decisions across HashiCorp enterprise products
---

# HashiCorp Sentinel

This skill covers HashiCorp Sentinel, a policy-as-code framework and language for making fine-grained, logic-based policy decisions.

## When to Use This Skill

Use this skill when you need to:
- Enforce governance and compliance policies as code
- Prevent risky or costly infrastructure changes
- Implement fine-grained access control beyond basic RBAC
- Codify business and legal requirements
- Automate policy enforcement across Terraform, Vault, Consul, or Nomad
- Create guardrails for self-service infrastructure
- Audit and validate infrastructure changes before deployment

## What is Sentinel?

**Sentinel is a policy-as-code framework and language** developed by HashiCorp for making **fine-grained, logic-based policy decisions**. It is used in **enterprise editions** of HashiCorp products like **Terraform Enterprise/Cloud, Vault Enterprise, Consul Enterprise, and Nomad Enterprise**.

### Core Purpose

In modern automated infrastructure environments, **human verification is often the bottleneck**. Sentinel replaces manual checks with **automated, enforceable guardrails** that:
- Prevent costly or risky actions (e.g., ordering 5,000 servers accidentally)
- Codify and enforce business and legal requirements
- Enable real-time enforcement of policies across HashiCorp tools
- Maintain compliance without slowing down deployment velocity

### The Problem with Manual Policy Enforcement

**Traditional Approach:**
- Manual code reviews for every infrastructure change
- Human judgment required for policy compliance
- Inconsistent enforcement across teams
- Slow approval processes
- No automated prevention of policy violations
- Difficult to audit and track policy decisions

**Sentinel's Solution:**
- **Automated enforcement** - Policies run automatically on every change
- **Codified rules** - Business logic expressed as code
- **Consistent application** - Same rules applied everywhere
- **Real-time feedback** - Developers know immediately if changes violate policy
- **Audit trail** - All policy decisions logged and traceable

## How Sentinel Works

### Policy Language

Sentinel uses a custom policy language designed for readability and expressiveness:

```sentinel
import "tfplan/v2" as tfplan

# Rule: Prohibit public S3 buckets
main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is not "aws_s3_bucket" or
    rc.change.after.acl is not "public-read"
  }
}
```

### Key Features

| Feature | Description |
| --- | --- |
| **Fine-grained control** | Goes beyond basic "read/write" permissions to enforce detailed rules |
| **Logic-based policy** | Supports conditions like allowing actions only on certain days or with overrides |
| **External data access** | Pulls data from sources like Consul, HTTP APIs to inform decisions |
| **Enforcement levels** | Policies can be advisory, soft mandatory, or hard mandatory |
| **Rich imports** | Access to Terraform plans, Vault tokens, Consul KV data, and more |
| **Testing framework** | Built-in testing for policies before deployment |

### Enforcement Levels

Sentinel supports three enforcement levels:

**1. Advisory**
- Shows warnings when policy fails
- Does not block the action
- Use for: Informational policies, best practice suggestions

**2. Soft Mandatory**
- Blocks the action but can be overridden
- Requires override permissions
- Use for: Important policies that sometimes need exceptions

**3. Hard Mandatory**
- Must always pass, no overrides allowed
- Blocks the action permanently if policy fails
- Use for: Critical security/compliance requirements

## Use Cases

### Terraform Enterprise/Cloud

**Block risky infrastructure changes:**
- Prevent instances larger than a certain size
- Require specific tags on all resources
- Enforce encryption on storage
- Limit regions where resources can be created
- Validate cost estimates before apply

**Example:**
```sentinel
import "tfplan/v2" as tfplan
import "decimal"

# Limit monthly cost to $1000
main = rule {
  decimal.new(tfplan.cost_estimate.monthly) < decimal.new(1000)
}
```

### Vault Enterprise

**Control access and secrets:**
- Limit token TTL durations
- Restrict which secrets engines can be used
- Require specific authentication methods
- Enforce minimum secret complexity
- Prevent secrets from being read during business hours

**Example:**
```sentinel
import "time"

# Block secret access outside business hours (9am-5pm)
hour = time.now.hour
main = rule {
  hour >= 9 and hour < 17
}
```

### Consul Enterprise

**Enforce configuration patterns:**
- Validate service mesh configurations
- Require health checks on all services
- Enforce naming conventions
- Limit service registration to specific datacenters

### Nomad Enterprise

**Prevent bad deployments:**
- Limit resource allocations (CPU/memory)
- Require certain metadata on jobs
- Enforce Docker image registry sources
- Validate job priorities

## Installation & Setup

### Prerequisites

Sentinel is embedded in HashiCorp Enterprise products. You need:
- Terraform Enterprise/Cloud, Vault Enterprise, Consul Enterprise, or Nomad Enterprise
- Permissions to create and manage policies

### Sentinel CLI (for testing)

**macOS (Homebrew):**
```bash
brew install hashicorp/tap/sentinel
```

**Linux:**
```bash
wget https://releases.hashicorp.com/sentinel/<version>/sentinel_<version>_linux_amd64.zip
unzip sentinel_<version>_linux_amd64.zip
sudo mv sentinel /usr/local/bin/
```

**Verify Installation:**
```bash
sentinel version
```

### Creating Your First Policy

1. **Create a policy file (example.sentinel):**
   ```sentinel
   import "tfplan/v2" as tfplan

   # All EC2 instances must be t2.micro
   main = rule {
     all tfplan.resource_changes as _, rc {
       rc.type is not "aws_instance" or
       rc.change.after.instance_type is "t2.micro"
     }
   }
   ```

2. **Create a test file (example_test.sentinel):**
   ```sentinel
   import "tfplan/v2" as tfplan

   # Mock data for testing
   mock "tfplan/v2" {
     module {
       source = "mock-tfplan-v2.sentinel"
     }
   }

   test {
     rules = {
       main = true
     }
   }
   ```

3. **Test the policy:**
   ```bash
   sentinel test example.sentinel
   ```

## Common Workflows

### Workflow 1: Enforcing Resource Tags in Terraform

**Scenario:** All AWS resources must have "Owner", "Environment", and "CostCenter" tags

1. **Create policy (require-tags.sentinel):**
   ```sentinel
   import "tfplan/v2" as tfplan
   import "strings"

   # Required tags
   required_tags = ["Owner", "Environment", "CostCenter"]

   # Get all resources that support tags
   allResources = filter tfplan.resource_changes as _, rc {
     rc.mode is "managed" and
     rc.change.actions contains "create"
   }

   # Validate tags
   main = rule {
     all allResources as _, resource {
       all required_tags as tag {
         resource.change.after.tags contains tag
       }
     }
   }
   ```

2. **Add policy to Terraform Cloud:**
   ```bash
   # Via UI: Settings → Policy Sets → Create Policy Set
   # Or via API:
   curl \
     --header "Authorization: Bearer $TOKEN" \
     --header "Content-Type: application/vnd.api+json" \
     --request POST \
     --data @payload.json \
     https://app.terraform.io/api/v2/organizations/my-org/policy-sets
   ```

3. **Set enforcement level:**
   ```json
   {
     "data": {
       "type": "policies",
       "attributes": {
         "name": "require-tags",
         "enforcement-level": "hard-mandatory"
       }
     }
   }
   ```

4. **Run Terraform plan:**
   ```bash
   terraform plan
   # Sentinel policy runs automatically
   # Blocks apply if tags are missing
   ```

### Workflow 2: Limiting Terraform Cost

**Scenario:** Prevent monthly infrastructure cost from exceeding $5,000

1. **Create cost policy (cost-limit.sentinel):**
   ```sentinel
   import "tfrun"
   import "decimal"

   # Maximum monthly cost in dollars
   max_monthly_cost = decimal.new(5000)

   # Get cost estimate
   monthly_cost = decimal.new(tfrun.cost_estimate.proposed_monthly_cost)

   # Enforce limit
   main = rule {
     monthly_cost.less_than(max_monthly_cost)
   }

   # Custom violation message
   violation = func() {
     print("Monthly cost $" + string(monthly_cost) +
           " exceeds limit of $" + string(max_monthly_cost))
   }
   ```

2. **Test with mock data:**
   ```sentinel
   # cost-limit_test.sentinel
   import "tfrun"

   mock "tfrun" {
     cost_estimate = {
       "proposed_monthly_cost": "4500.00"
     }
   }

   test {
     rules = {
       main = true
     }
   }
   ```

3. **Run test:**
   ```bash
   sentinel test cost-limit.sentinel
   ```

### Workflow 3: Vault Token TTL Limits

**Scenario:** Prevent creation of long-lived Vault tokens (max 24 hours)

1. **Create Vault policy (token-ttl.sentinel):**
   ```sentinel
   import "token"
   import "strings"

   # Maximum TTL in seconds (24 hours)
   max_ttl = 86400

   # Check token TTL
   main = rule {
     token.ttl <= max_ttl
   }
   ```

2. **Apply policy to Vault:**
   ```bash
   vault write sys/policies/egp/token-ttl \
     policy=@token-ttl.sentinel \
     paths="auth/token/create" \
     enforcement_level="soft-mandatory"
   ```

3. **Test the policy:**
   ```bash
   # This should fail
   vault token create -ttl=72h

   # This should succeed
   vault token create -ttl=12h
   ```

### Workflow 4: Consul Service Registration Validation

**Scenario:** All Consul services must have health checks

1. **Create Consul policy (require-health-checks.sentinel):**
   ```sentinel
   import "consul"

   # Get all service registrations
   services = consul.key_info("services/")

   # Validate health checks
   main = rule {
     all services as _, service {
       length(service.checks) > 0
     }
   }
   ```

2. **Deploy policy to Consul:**
   ```bash
   consul config write sentinel-policy.hcl
   ```

## Sentinel Language Basics

### Imports

Access external data and functionality:

```sentinel
import "tfplan/v2" as tfplan    # Terraform plan data
import "tfconfig/v2" as tfconfig  # Terraform configuration
import "tfstate/v2" as tfstate   # Terraform state
import "tfrun"                   # Terraform run data
import "time"                    # Time functions
import "strings"                 # String manipulation
import "decimal"                 # Decimal math
import "http"                    # HTTP requests
```

### Rules

Define pass/fail conditions:

```sentinel
# Simple rule
main = rule {
  true
}

# Rule with expression
main = rule {
  resource.type is "aws_instance"
}

# Named rule
instance_is_small = rule {
  instance.type is "t2.micro"
}

main = rule {
  instance_is_small
}
```

### Quantifiers

Check collections:

```sentinel
# All items must match
all resources as _, r {
  r.type is "aws_instance"
}

# Any item matches
any resources as _, r {
  r.type is "aws_instance"
}

# Filter items
small_instances = filter resources as _, r {
  r.instance_type is "t2.micro"
}
```

### Functions

Reusable logic:

```sentinel
# Define function
validate_tags = func(resource, required_tags) {
  all required_tags as tag {
    resource.tags contains tag
  }
}

# Use function
main = rule {
  all resources as _, r {
    validate_tags(r, ["Owner", "Environment"])
  }
}
```

### Conditional Logic

```sentinel
# If-else
allowed = if instance.type is "t2.micro" {
  true
} else {
  false
}

# Ternary operator
allowed = instance.type is "t2.micro" ? true : false

# Boolean operators
main = rule {
  (instance.type is "t2.micro" or instance.type is "t2.small") and
  region is "us-west-2"
}
```

## Best Practices

### Policy Design
- **Start permissive, tighten gradually** - Begin with advisory policies
- **Use meaningful names** - Policy files should describe their purpose
- **Keep policies focused** - One policy should check one thing
- **Version control policies** - Track changes like application code
- **Document intent** - Add comments explaining why policy exists

### Testing
- **Write tests for every policy** - Use Sentinel test framework
- **Test both pass and fail cases** - Ensure policy works correctly
- **Use mock data** - Create realistic test scenarios
- **Automate testing** - Run tests in CI/CD pipeline
- **Test with real data** - Validate against actual Terraform plans

### Enforcement Strategy
- **Use advisory first** - Start with warnings, not blocking
- **Graduate to soft mandatory** - Allow overrides for exceptions
- **Reserve hard mandatory for critical rules** - Only use when absolutely necessary
- **Document override process** - Make it clear how to request exceptions
- **Monitor policy violations** - Track what's being blocked and why

### Organization
- **Group related policies** - Create policy sets by theme
- **Use consistent naming** - Follow a naming convention
- **Separate by environment** - Different rules for dev vs. prod
- **Version policy sets** - Tag releases of policy collections
- **Share common functions** - Create library of reusable functions

### Performance
- **Minimize API calls** - Cache external data lookups
- **Use filters efficiently** - Reduce collection sizes early
- **Avoid complex calculations** - Keep policy evaluation fast
- **Profile slow policies** - Use Sentinel profiling tools
- **Parallelize when possible** - Structure policies for parallel execution

## Troubleshooting

### Issue 1: Policy Always Fails

**Symptoms:**
- Policy blocks all changes
- No violations shown

**Cause:**
- Logic error in policy
- Incorrect import usage
- Wrong enforcement level

**Solution:**
```bash
# Test policy with verbose output
sentinel test -verbose policy.sentinel

# Check policy logic
sentinel apply -trace policy.sentinel

# Verify imports are correct
grep "import" policy.sentinel
```

### Issue 2: External Data Not Loading

**Symptoms:**
- Policy can't access HTTP data
- Consul/Vault lookups fail

**Cause:**
- Network connectivity
- Authentication issues
- Wrong endpoint URL

**Solution:**
```bash
# Test HTTP import separately
sentinel apply -trace http-policy.sentinel

# Verify credentials
echo $VAULT_TOKEN

# Check connectivity
curl -H "Authorization: Bearer $TOKEN" https://api.example.com
```

### Issue 3: Policy Evaluation Too Slow

**Symptoms:**
- Terraform runs timeout
- Long policy evaluation times

**Cause:**
- Too many resources being checked
- Inefficient filtering
- External API latency

**Solution:**
```sentinel
# Before: Checking all resources
all resources as _, r {
  check(r)
}

# After: Filter first, then check
filtered = filter resources as _, r {
  r.type is "aws_instance"
}

all filtered as _, r {
  check(r)
}
```

## HashiCorp-Specific Tips

### Terraform Cloud Integration

**Policy Sets:**
- Group related policies together
- Apply to specific workspaces or all workspaces
- Version control in VCS (GitHub, GitLab)
- Automatic updates on git push

**Sentinel Parameters:**
- Pass runtime values to policies
- Environment-specific configuration
- Override defaults without changing policy code

```sentinel
param max_cost default 1000

main = rule {
  cost < max_cost
}
```

### Integration with Vault

**EGP (Endpoint Governing Policies):**
- Apply to Vault API endpoints
- Control token creation, secret access
- Enforce authentication requirements

**RGP (Role Governing Policies):**
- Apply to specific Vault roles
- Fine-grained control per role

### Common Terraform Imports

```sentinel
import "tfplan/v2" as tfplan      # Proposed changes
import "tfconfig/v2" as tfconfig  # Configuration files
import "tfstate/v2" as tfstate    # Current state
import "tfrun"                    # Run metadata (cost, workspace)
```

### Policy Libraries

**HashiCorp provides example policies:**
- https://github.com/hashicorp/terraform-guides
- Pre-built policies for AWS, Azure, GCP
- Common compliance frameworks (CIS, PCI-DSS)

## Additional Resources

- **Official Sentinel Documentation**: https://developer.hashicorp.com/sentinel
- **Sentinel Language Specification**: https://docs.hashicorp.com/sentinel/language
- **Terraform Sentinel Policies**: https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement
- **Vault Sentinel Policies**: https://developer.hashicorp.com/vault/docs/enterprise/sentinel
- **Example Policies**: https://github.com/hashicorp/terraform-guides/tree/master/governance
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/~7120203b08a819769e47afa57115b188ef7efc/pages/4114448903/What+is+Sentinel

## Summary

**Most Common Policy Pattern:**
```sentinel
import "tfplan/v2" as tfplan

# Define what to check
resources = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_instance" and
  rc.change.actions contains "create"
}

# Define the rule
main = rule {
  all resources as _, resource {
    resource.change.after.instance_type in ["t2.micro", "t2.small"]
  }
}
```

**Enforcement Levels:**
```
advisory          → Warning only (doesn't block)
soft-mandatory    → Blocks but can be overridden
hard-mandatory    → Always blocks (no override)
```

**Testing Workflow:**
```bash
# Create policy
vim policy.sentinel

# Create test
vim policy_test.sentinel

# Run test
sentinel test policy.sentinel

# Apply to Terraform Cloud/Vault/Consul
# (method varies by product)
```

**Remember:**
- Sentinel enforces policy as code automatically
- Use advisory enforcement first, then tighten
- Test policies thoroughly before deploying
- Version control all policies
- Monitor policy violations for insights
- Document exception/override processes
- Start with HashiCorp's example policies
- Use soft-mandatory for most policies
