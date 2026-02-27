---
name: aws
description: Using HashiCorp products with AWS, including Doormat authentication and AWS CLI workflows. Use for AWS access, Terraform, Vault, Consul, Nomad, or Boundary examples.
---

# AWS with HashiCorp

Guide to using HashiCorp products with Amazon Web Services (AWS).

## HashiCorp Products on AWS

**Terraform**: Primary IaC tool for AWS infrastructure
**Vault**: AWS auth, secrets engines, dynamic IAM credentials
**Consul**: Service mesh with AWS auto-join
**Nomad**: Workload orchestration on EC2
**Boundary**: Secure access to EC2 and RDS
**HCP**: Fully-managed HashiCorp services on AWS

## Accessing AWS at HashiCorp

### Doormat Authentication

```bash
# List available AWS accounts
doormat aws list

# Get temporary credentials (12-hour session)
doormat aws --account <account-name> --role <role-name>

# Verify access
aws sts get-caller-identity
```

See `/doormat` skill for detailed usage.

### AWS CLI

```bash
# Install
brew install awscli

# Test (credentials auto-configured by Doormat)
aws s3 ls
```

## Common Workflows

### Terraform on AWS

**Basic configuration**:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
```

**Best practices**:
- Use S3 + DynamoDB for remote state
- Enable state encryption with KMS
- Tag all resources consistently
- Use modules for reusability

### Vault AWS Secrets Engine

**Setup**:
```bash
# Enable AWS secrets engine
vault secrets enable aws

# Configure
vault write aws/config/root \
  access_key=$AWS_ACCESS_KEY_ID \
  secret_key=$AWS_SECRET_ACCESS_KEY \
  region=us-east-1

# Create role for dynamic credentials
vault write aws/roles/ec2-admin \
  credential_type=iam_user \
  policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "ec2:*",
    "Resource": "*"
  }]
}
EOF
```

**Generate credentials**:
```bash
vault read aws/creds/ec2-admin
# Returns temporary AWS credentials (auto-revoked)
```

**Benefits**: Short-lived credentials, audit trail, no long-term keys

### Consul on AWS

**AWS auto-join**:
```hcl
# consul.hcl
retry_join = [
  "provider=aws tag_key=consul_server tag_value=true"
]
```

Automatically discovers Consul servers using EC2 tags across availability zones.

### Nomad on AWS

**Deploy to EC2**:
```hcl
job "app" {
  datacenters = ["us-east-1"]

  group "web" {
    task "server" {
      driver = "docker"

      config {
        image = "my-app:latest"
      }

      # Get AWS credentials from Vault
      vault {
        policies = ["aws-read"]
      }

      template {
        data = <<EOH
{{ with secret "aws/creds/app-role" }}
AWS_ACCESS_KEY_ID={{ .Data.access_key }}
AWS_SECRET_ACCESS_KEY={{ .Data.secret_key }}
{{ end }}
EOH
        destination = "secrets/aws.env"
        env = true
      }
    }
  }
}
```

### Boundary for AWS Access

**EC2 access without bastions**:
```bash
# Create target for EC2 instance
boundary targets create tcp \
  -name="web-server" \
  -default-port=22 \
  -address="i-0abcd1234"

# Connect via SSH
boundary connect ssh -target-id ttcp_abc123
```

**Dynamic host catalogs**:
```bash
# Auto-discover EC2 instances by tag
boundary host-sets create plugin \
  -host-catalog-id hcplg_123 \
  -attr filters="tag:Environment=production"
```

### HCP on AWS

**HCP Vault on AWS**:
1. Create HVN (HashiCorp Virtual Network)
2. Deploy HCP Vault cluster
3. Peer HVN with AWS VPC
4. Configure security groups
5. Access Vault from AWS resources

Fully managed with HA, backups, and automated upgrades.

## AWS Networking for HashiCorp

### VPC Design

```
VPC (10.0.0.0/16)
├── Public Subnets - Load Balancers, NAT
├── Private Subnets - Apps, Nomad clients
└── Database Subnets - RDS
```

**Security Groups for HashiCorp**:
- Consul: 8300-8302, 8500, 8600
- Vault: 8200-8201
- Nomad: 4646-4648

### HCP VPC Peering

1. Create HVN in HCP Console
2. Initiate peering to AWS VPC
3. Accept peering in AWS Console
4. Update route tables
5. Configure security groups

## Key AWS Services for HashiCorp

**Compute**: EC2 (Nomad, Consul, Vault servers), EKS (with Consul/Vault)
**Storage**: S3 (Terraform state, Vault snapshots), EBS (persistent volumes)
**Database**: RDS (with Vault dynamic secrets), DynamoDB (Terraform locks)
**Networking**: VPC, ALB/NLB, Route 53 (with Consul)
**Security**: IAM (Vault integration), KMS (Vault auto-unseal), Secrets Manager
**Monitoring**: CloudWatch, CloudTrail

## Troubleshooting

### Doormat Session Expired

**Problem**: AWS credentials stopped working.

**Solution**: Re-authenticate with Doormat (sessions last 12 hours)
```bash
doormat aws --account <account> --role <role>
```

### Terraform Permission Errors

**Problem**: Terraform can't create resources.

**Solutions**:
1. Verify IAM role has required permissions
2. Check you're in correct AWS account: `aws sts get-caller-identity`
3. Ensure Doormat session is active
4. Try different role if available

### Vault AWS Credentials Not Working

**Problem**: Dynamic credentials from Vault don't work.

**Solutions**:
1. Check Vault AWS secrets engine configuration
2. Verify IAM permissions for Vault's root credentials
3. Check credential lease hasn't expired: `vault list sys/leases/lookup/aws/creds`
4. Validate IAM policy in Vault role

### Consul Auto-Join Failing

**Problem**: Consul servers can't discover each other.

**Solutions**:
1. Verify EC2 instances have correct tags
2. Check security groups allow Consul ports (8300-8302)
3. Ensure IAM role has `ec2:DescribeInstances` permission
4. Verify instances are in same region/VPC

## Additional Resources

### HashiCorp Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Vault AWS Secrets](https://developer.hashicorp.com/vault/docs/secrets/aws)
- [Consul on AWS](https://developer.hashicorp.com/consul/tutorials/cloud-production/aws-reference-architecture)
- [Nomad on AWS](https://developer.hashicorp.com/nomad/tutorials/enterprise/aws-reference-architecture)

### Internal Resources
- [AWS Networking Guide](https://hashicorp.atlassian.net/wiki/spaces/~361427045/pages/2252603500/AWS+networking)

### Related Skills
- `/terraform` - Infrastructure as Code
- `/vault` - Secrets management
- `/consul` - Service mesh
- `/nomad` - Workload orchestration
- `/boundary` - Secure access
- `/hcp` - HashiCorp Cloud Platform
- `/doormat` - Authentication

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
