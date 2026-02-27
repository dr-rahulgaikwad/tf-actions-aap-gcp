# Feature Specification: Vault Agent Skill Improvement

**Feature Branch**: `update-vault-skill`  
**Created**: 2026-01-23  
**Status**: In Progress  
**Input**: User request: "Comprehensively analyze Agent Skills documentation and Vault developer docs, then improve the Vault skill to be specification-compliant and comprehensive."

---

## Executive Summary

This specification defines the improvements needed to bring the HashiCorp Vault Agent Skill into compliance with the [Agent Skills Specification](https://agentskills.io/specification) and [Anthropic best practices](https://platform.claude.com). The current skill has specification violations and exceeds recommended size limits. This spec outlines restructuring using progressive disclosure, fixing metadata issues, and adding missing Vault capabilities.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Developer Needs Dynamic Database Credentials (Priority: P1)

A developer building a Python application needs to connect to a PostgreSQL database without hardcoding credentials. They want Vault to generate short-lived database credentials automatically.

**Why this priority**: Dynamic secrets are Vault's core value proposition. This is the most common enterprise use case.

**Independent Test**: Can be fully tested by asking the AI "How do I configure Vault to generate dynamic PostgreSQL credentials?" and receiving accurate, actionable guidance including secrets engine configuration, role definition, and application integration patterns.

**Acceptance Scenarios**:

1. **Given** a user asks about database credential management, **When** the AI invokes this skill, **Then** it provides Database secrets engine setup with role configuration and lease/TTL guidance.
2. **Given** a developer wants to integrate Vault with their app, **When** they ask for code examples, **Then** the skill provides language-appropriate SDK examples (Python, Go, Node.js).
3. **Given** a user mentions "dynamic secrets," **When** the skill is invoked, **Then** it explains the concept and lists available dynamic secrets engines.

---

### User Story 2 - Platform Engineer Configuring Kubernetes Authentication (Priority: P1)

A platform engineer needs to configure their Kubernetes workloads to authenticate with Vault and retrieve secrets without manual token management.

**Why this priority**: Kubernetes is the dominant container orchestration platform. K8s-native auth is essential for cloud-native deployments.

**Independent Test**: Can be tested by asking "How do I configure Vault authentication for my Kubernetes pods?" and receiving complete guidance covering auth method setup, service account configuration, and workload integration patterns.

**Acceptance Scenarios**:

1. **Given** a user asks about Kubernetes integration, **When** the skill is invoked, **Then** it provides Kubernetes auth method configuration including ClusterRoleBinding setup.
2. **Given** a user asks about Vault Secrets Operator, **When** queried, **Then** the skill explains VSO installation, VaultAuth CRD, and sync patterns.
3. **Given** a user mentions "sidecar injection," **When** the skill processes the query, **Then** it explains Vault Agent Injector with annotations.

---

### User Story 3 - Security Engineer Writing Access Policies (Priority: P1)

A security engineer needs to create fine-grained access control policies for multiple teams accessing different secrets paths.

**Why this priority**: Policies are the foundation of Vault's security model. Incorrect policies create security risks or block legitimate access.

**Independent Test**: Can be tested by asking "Write a Vault policy that allows the app-team to read secrets under secret/data/app/* but not write" and receiving correct HCL policy syntax.

**Acceptance Scenarios**:

1. **Given** a user requests policy creation, **When** the skill is invoked, **Then** it generates valid HCL policy syntax with proper path patterns.
2. **Given** a user asks about templated policies, **When** queried, **Then** the skill explains identity templating with `{{identity.entity.id}}` patterns.
3. **Given** a policy debugging scenario, **When** asked "why can't my app read this secret?", **Then** the skill provides troubleshooting steps including `vault token lookup` and capability checking.

---

### User Story 4 - DevOps Engineer Setting Up PKI (Priority: P2)

A DevOps engineer needs to issue TLS certificates for internal services using Vault's PKI secrets engine.

**Why this priority**: PKI is critical for zero-trust architectures and service mesh deployments.

**Independent Test**: Can be tested by asking "How do I set up Vault as an internal Certificate Authority?" and receiving root/intermediate CA setup, role configuration, and certificate issuance commands.

**Acceptance Scenarios**:

1. **Given** a user asks about internal CA, **When** the skill is invoked, **Then** it provides PKI secrets engine setup with root and intermediate CA configuration.
2. **Given** a request for cert-manager integration, **When** queried, **Then** the skill explains Kubernetes cert-manager with Vault issuer.
3. **Given** a certificate rotation question, **When** asked, **Then** the skill provides certificate renewal and revocation patterns.

---

### User Story 5 - SRE Troubleshooting Vault Issues (Priority: P2)

An SRE needs to diagnose why Vault is responding slowly, returning errors, or failing to authenticate clients.

**Why this priority**: Production troubleshooting is a common, high-stress scenario where accurate guidance is critical.

**Independent Test**: Can be tested by asking "Vault is returning 503 errors, how do I diagnose?" and receiving structured troubleshooting steps.

**Acceptance Scenarios**:

1. **Given** a user reports Vault errors, **When** the skill is invoked, **Then** it provides systematic troubleshooting (seal status, leader election, storage health, audit logs).
2. **Given** an authentication failure, **When** asked for help, **Then** the skill identifies common causes (expired tokens, policy issues, auth method misconfiguration).
3. **Given** performance issues, **When** queried, **Then** the skill suggests telemetry analysis, connection pooling, and caching strategies.

---

### User Story 6 - Architect Designing HA/DR Deployment (Priority: P2)

A solutions architect needs to design a highly available Vault deployment with disaster recovery capabilities.

**Why this priority**: Enterprise Vault deployments require HA and DR for production readiness.

**Independent Test**: Can be tested by asking "Design a Vault architecture with 5-node HA cluster and DR to another region" and receiving accurate architecture guidance.

**Acceptance Scenarios**:

1. **Given** an HA design request, **When** the skill is invoked, **Then** it explains Integrated Storage (Raft) cluster sizing, node configuration, and leader election.
2. **Given** a DR question, **When** queried, **Then** the skill differentiates performance replication vs. DR replication with use cases.
3. **Given** an Enterprise context, **When** asked about namespaces, **Then** the skill explains multi-tenancy isolation patterns.

---

### User Story 7 - Developer Using Vault Agent (Priority: P3)

A developer needs to use Vault Agent as a sidecar to handle authentication and secret caching for their application.

**Why this priority**: Vault Agent simplifies application integration by handling token renewal and secret templating.

**Independent Test**: Can be tested by asking "Configure Vault Agent to auto-auth with AppRole and render secrets to a file" and receiving working configuration.

**Acceptance Scenarios**:

1. **Given** a Vault Agent question, **When** the skill is invoked, **Then** it provides Agent configuration with auto-auth, caching, and template stanzas.
2. **Given** a template rendering request, **When** queried, **Then** the skill shows consul-template syntax for secret templating.
3. **Given** a process supervisor question, **When** asked, **Then** the skill explains exec mode and signal handling.

---

### User Story 8 - Security Team Enabling SSH Access (Priority: P3)

A security team needs to manage SSH access to infrastructure using Vault's SSH secrets engine.

**Why this priority**: SSH credential management is a common security requirement, especially for bastion hosts.

**Independent Test**: Can be tested by asking "How do I use Vault for SSH certificate-based authentication?" and receiving OTP vs. CA mode comparison with configuration.

**Acceptance Scenarios**:

1. **Given** an SSH access question, **When** the skill is invoked, **Then** it explains SSH secrets engine modes (OTP, CA, Dynamic Keys).
2. **Given** a CA mode request, **When** queried, **Then** the skill provides SSH CA configuration with user and host certificate signing.
3. **Given** a bastion integration question, **When** asked, **Then** the skill shows `vault ssh` command usage patterns.

---

### Edge Cases

- What happens when a user asks about Vault features not yet documented in the skill?
  - *Response*: Skill should acknowledge the gap and point to official HashiCorp documentation.
- How does the skill handle version-specific features (1.15 vs. 1.17)?
  - *Response*: Include version notes where applicable, defaulting to latest stable.
- What if a user asks about Vault Enterprise features in Community context?
  - *Response*: Clearly differentiate Enterprise-only features (namespaces, MFA, Sentinel).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST have `name` field matching parent directory name (`vault`)
- **FR-002**: Skill MUST include description with trigger phrases for AI skill selection
- **FR-003**: Skill body SHOULD be under 500 lines (per Agent Skills best practices)
- **FR-004**: Skill MUST use progressive disclosure pattern with `references/` directory
- **FR-005**: Skill MUST cover all major Vault secrets engines (KV, Database, AWS, PKI, Transit, SSH)
- **FR-006**: Skill MUST cover all major auth methods (AppRole, Kubernetes, OIDC, AWS, LDAP)
- **FR-007**: Skill MUST include policy syntax and examples
- **FR-008**: Skill MUST cover Vault Agent configuration patterns
- **FR-009**: Skill MUST include Kubernetes integration patterns (VSO, Agent Injector, CSI)
- **FR-010**: Skill MUST include troubleshooting guidance
- **FR-011**: Skill MUST differentiate Enterprise features clearly
- **FR-012**: Skill MUST include CLI command reference
- **FR-013**: Skill MUST include Terraform integration examples
- **FR-014**: Reference files MUST have YAML frontmatter with `name` and `description`
- **FR-015**: Reference files MUST have "Additional Resources" section with documentation links
- **FR-016**: Reference files MUST have "Related" section for cross-referencing other reference files
- **FR-017**: SKILL.md MUST have "Summary" section with most common commands and key remember points

### Key Entities

- **SKILL.md**: Main skill file (~500 lines) - overview, quick reference, pointers to references
- **references/auth-methods.md**: Deep dive on AppRole, Kubernetes, OIDC, AWS, Azure, GCP, LDAP
- **references/secrets-engines.md**: Deep dive on KV, Database, AWS, PKI, Transit, SSH, TOTP
- **references/policies.md**: Policy syntax, templating, path patterns, sentinel policies
- **references/kubernetes.md**: VSO, Agent Injector, CSI Provider, Helm configuration
- **references/vault-agent.md**: Auto-auth, caching, templating, exec mode
- **references/production-operations.md**: Monitoring, backup, upgrades, HA/DR operations
- **references/enterprise.md**: Namespaces, replication, Sentinel, MFA, control groups
- **references/troubleshooting.md**: Common errors, diagnostic commands, performance tuning

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: SKILL.md is under 500 lines (target: ~500 lines)
- **SC-002**: `name` field equals `vault` (matches directory)
- **SC-003**: All 8 reference files exist and contain substantive content (>100 lines each)
- **SC-004**: Description includes trigger phrases for major use cases
- **SC-005**: Skill passes Agent Skills specification validation (name, description, structure)
- **SC-006**: Coverage includes all 8 user story scenarios
- **SC-007**: No placeholder or TODO markers remain in final output
- **SC-008**: Each reference file is self-contained and independently useful
- **SC-009**: Each reference file has YAML frontmatter with `name` and `description`
- **SC-010**: Each reference file has "Additional Resources" section with documentation links
- **SC-011**: Each reference file has "Related" section for cross-referencing
- **SC-012**: SKILL.md has "Summary" section with quick reference commands

### Quality Gates

- [x] Name field violation fixed (`hashicorp-vault` → `vault`)
- [x] Line count under 500
- [x] Progressive disclosure structure in place
- [x] All P1 user stories addressed
- [x] All P2 user stories addressed  
- [x] All P3 user stories addressed
- [x] Troubleshooting section complete
- [x] Enterprise features clearly marked
- [x] All reference files have YAML frontmatter
- [x] All reference files have Additional Resources section
- [x] All reference files have Related section for cross-referencing
- [x] SKILL.md has Summary section with quick reference commands

---

## Technical Context

**File Type**: Markdown (Agent Skill)  
**Target Directory**: `skills/vault/`  
**Specification**: [Agent Skills Specification](https://agentskills.io/specification)  
**Best Practices**: [Anthropic Platform Best Practices](https://platform.claude.com)

### Constraints

- SKILL.md frontmatter `name` MUST be lowercase, 1-64 chars, match directory name
- SKILL.md frontmatter `description` MUST be 1-1024 chars
- Total SKILL.md body SHOULD be under 500 lines for optimal AI loading
- Reference files use progressive disclosure (loaded only when needed)
- Reference files MUST have YAML frontmatter for discoverability
- Reference files MUST end with "Additional Resources" and "Related" sections

### Agent Skills Specification Requirements

From [agentskills.io/specification](https://agentskills.io/specification):

1. **name**: 1-64 characters, lowercase only, hyphens allowed, MUST match parent directory
2. **description**: 1-1024 characters, describe what skill does AND when to use it
3. **Body**: Detailed instructions (under 500 lines recommended)
4. **Optional directories**: `references/`, `scripts/`, `assets/`

From [Anthropic best practices](https://platform.claude.com):

1. "Keep SKILL.md body under 500 lines"
2. "Move detailed reference material to separate files"
3. "SKILL.md serves as an overview that points Claude to detailed materials"
4. "Description is critical for skill selection - include trigger phrases"

---

## Project Structure

### Final Directory Structure

```text
skills/vault/
├── SKILL.md                  # Main skill file (~500 lines)
├── SPEC.md                   # This specification file
└── references/
    ├── auth-methods.md           # Auth method deep dive
    ├── secrets-engines.md        # Secrets engines deep dive
    ├── policies.md               # Policy syntax and examples
    ├── kubernetes.md             # K8s integration patterns
    ├── vault-agent.md            # Agent auto-auth, caching, templating
    ├── production-operations.md  # Monitoring, backup, HA/DR operations
    ├── enterprise.md             # Enterprise-only features
    └── troubleshooting.md        # Diagnostics and common issues
```

### Reference File Format

Each reference file MUST follow this structure:

```yaml
---
name: vault-<topic>           # e.g., vault-auth-methods
description: <brief description of content>
---

# <Title>

<Introduction paragraph>

---

## <Content Sections>

...

---

## Additional Resources

- [Resource 1](url)
- [Resource 2](url)

---

## Related

- [Related Reference 1](file.md) - Brief description
- [Related Reference 2](file.md) - Brief description
```

### Content Distribution Strategy

| File | Target Lines | Content Focus |
| ------ | ------------- | --------------- |
| SKILL.md | ~500 | Overview, quick reference, common commands, Summary section |
| auth-methods.md | ~570 | AppRole, Kubernetes, OIDC, AWS, Azure, GCP, LDAP config details |
| secrets-engines.md | ~760 | KV, Database, AWS, PKI, Transit, SSH, TOTP setup and usage |
| policies.md | ~610 | HCL syntax, templating, path patterns, Sentinel examples |
| kubernetes.md | ~640 | VSO, Agent Injector, CSI, Helm values, CRD examples |
| vault-agent.md | ~820 | Auto-auth, caching, templating, exec mode, Kubernetes sidecar |
| production-operations.md | ~600 | Monitoring, backup/recovery, upgrades, HA/DR operations |
| enterprise.md | ~550 | Namespaces, replication types, Sentinel, MFA, HSM |
| troubleshooting.md | ~790 | Error codes, diagnostic commands, performance tuning |

---

## Implementation Plan

### Phase 1: Fix Critical Spec Violations (Immediate)

1. Change `name: hashicorp-vault` to `name: vault`
2. Update description with trigger phrases

### Phase 2: Create Reference Structure

1. Create `references/` directory
2. Extract content from current SKILL.md into reference files
3. Write new content for missing sections

### Phase 3: Restructure SKILL.md

1. Trim SKILL.md to overview + quick reference
2. Add pointers to reference files
3. Ensure skill selection description is comprehensive

### Phase 4: Add Missing Content

1. Add Vault Agent section
2. Add SSH secrets engine section
3. Add Identity system section
4. Enhance Kubernetes integration section
5. Complete troubleshooting section

### Phase 5: Validation

1. Verify line counts
2. Verify name matches directory
3. Test skill invocation with sample queries
4. Review against all user stories

---

## Implementation Checklist

### Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] All user stories have acceptance scenarios
- [x] Edge cases documented

### Specification Quality

- [x] Follows Agent Skills specification
- [x] Follows Anthropic best practices
- [x] Uses progressive disclosure pattern
- [x] Content is accurate and current
- [x] Examples are executable

### Reference File Standards (added 2026-01-23)

- [x] All reference files have YAML frontmatter (`name`, `description`)
- [x] All reference files have "Additional Resources" section with docs links
- [x] All reference files have "Related" section for cross-referencing
- [x] SKILL.md has "Summary" section per CONTRIBUTING.md template
- [x] All markdown linter warnings resolved

---

## Appendix: Current State Analysis

### Implementation Status (Updated 2026-01-23)

| Issue | Previous State | Current State | Status |
| ------- | -------------- | -------------- | -------- |
| name field | `hashicorp-vault` | `vault` | ✅ Fixed |
| Line count | 690 lines | ~500 lines | ✅ Fixed |
| Progressive disclosure | All inline | 8 reference files | ✅ Fixed |
| YAML frontmatter | Missing | All files have frontmatter | ✅ Fixed |
| Related sections | Missing | All files cross-linked | ✅ Fixed |
| Summary section | Missing | Added to SKILL.md | ✅ Fixed |

### Content Gap Analysis (Updated 2026-01-23)

| Topic | Previous Coverage | Current Coverage | Status |
| ------- | ----------------- | ----------------- | -------- |
| Vault Agent | ❌ Missing | ✅ vault-agent.md (~820 lines) | ✅ Complete |
| SSH Secrets Engine | ❌ Missing | ✅ In secrets-engines.md | ✅ Complete |
| Identity System | ❌ Missing | ✅ In auth-methods.md | ✅ Complete |
| Detailed K8s | ⚠️ Partial | ✅ kubernetes.md (~640 lines) | ✅ Complete |
| Troubleshooting | ⚠️ Partial | ✅ troubleshooting.md (~790 lines) | ✅ Complete |
| Enterprise | ⚠️ Partial | ✅ enterprise.md (~550 lines) | ✅ Complete |
| Production Ops | ❌ Missing | ✅ production-operations.md (~600 lines) | ✅ Complete |

---

## Documentation Crawl Findings (2026-01-23)

Comprehensive crawl of [HashiCorp Vault documentation](https://developer.hashicorp.com/vault) was performed to verify accuracy and identify enhancements.

### Sources Crawled

| Category | URLs Crawled |
| ---------- | -------------- |
| Core Concepts | /vault/docs, /vault/docs/concepts, /vault/docs/internals |
| Secrets Engines | KV, Database, Transit, PKI, SSH, AWS, TOTP |
| Auth Methods | AppRole, Kubernetes, JWT/OIDC, Identity |
| Vault Agent | /vault/docs/agent-and-proxy/agent, templates, Kubernetes integration |
| Kubernetes | VSO, Agent Injector, CSI Provider |
| Enterprise | Namespaces, Replication, Policies |

### Key Findings Applied to Reference Files

#### secrets-engines.md Enhancements

- **AWS Web Identity Federation (WIF)**: Added OIDC-based authentication without static credentials
- **AWS Static Roles**: Added cross-account IAM user management with automatic rotation
- **Transit BYOK**: Added Bring Your Own Key import process for Transit secrets engine

#### auth-methods.md Enhancements

- **Kubernetes 1.21+ Token Handling**: Added 3 configuration options for short-lived bound service account tokens:
  1. Local token reviewer JWT (recommended in-cluster)
  2. `disable_iss_validation=true` (cross-cluster)
  3. Explicit issuer configuration
- **use_annotations_as_alias_metadata**: Added for templated policies using ServiceAccount metadata

#### policies.md Enhancements

- **KV v2 /data/ Path Note**: Added prominent warning that policies must include `/data/` segment
- **Parameter Constraints Warning**: Clarified that `required_parameters`, `allowed_parameters`, `denied_parameters` only apply to create/update operations

#### kubernetes.md Enhancements

- **Supported Versions Table**: Added VSO (K8s 1.29-1.33), Agent Injector (1.16+), CSI (1.16+)
- **OpenShift Support**: Added Red Hat OpenShift 4.10+ support note for VSO

#### enterprise.md Enhancements

- **Namespace Naming Restrictions**: Cannot contain `/`, `\`, `..`, `%`, or `+`
- **Administrative Namespaces**: Added restricted API access pattern

#### troubleshooting.md Enhancements

- **Vault Agent Template Issues**: New section with:
  - `VAULT_AGENT_TEMPLATING_EMPTY_SECRET_ALLOW` environment variable
  - `error_on_missing_key = false` configuration
  - Template debugging techniques using `.Data.data | keys`

### Verification Status

| Reference File | Lines | YAML Frontmatter | Additional Resources | Related Section |
| ---------------- | ------- | ------------------ | ---------------------- | ----------------- |
| auth-methods.md | ~570 | ✅ | ✅ | ✅ |
| secrets-engines.md | ~760 | ✅ | ✅ | ✅ |
| policies.md | ~610 | ✅ | ✅ | ✅ |
| kubernetes.md | ~640 | ✅ | ✅ | ✅ |
| vault-agent.md | ~820 | ✅ | ✅ | ✅ |
| production-operations.md | ~600 | ✅ | ✅ | ✅ |
| enterprise.md | ~550 | ✅ | ✅ | ✅ |
| troubleshooting.md | ~790 | ✅ | ✅ | ✅ |

---

## CSA Customer Documentation Findings (2026-01-23)

Comprehensive analysis of 262 documents from the HashiCorp internal CSA (Customer Success Architecture) documentation repository. These findings represent real-world enterprise patterns from customer engagements across 30+ industries.

### Source Repository

- **Location**: `internal-csa-docs-customer-submissions`
- **Documents Analyzed**: 262 Vault-specific customer documents
- **Document Types**: Solution Architectures, Maturity Assessments, Production Readiness Reviews, Workshop Recommendations, Health Checks, Observability Guides
- **Industries Covered**: Global Banking, Insurance, Healthcare, Retail, Telecommunications, Government, Automotive, Technology, Energy, Aerospace, Payments, Logistics

### Reference Material Documents

| Document | Topics Covered |
| ---------- | --------------- |
| vault-approle.md | AppRole trusted broker pattern, CI/CD pipeline integration, wrapped SecretID workflow, anti-patterns |
| terraform-enterprise-using-vault.md | TFE + Vault integration, remote backend with team tokens, GitHub auth for developers |
| vault-pcf-auth.md | Cloud Foundry authentication, Instance Identity Credentials, Spring Vault, Vault Agent sidecar |
| EA-S001-TFE-saml-sop.md | SAML integration procedures |

---

### 1. Infrastructure Architecture Patterns

#### Cluster Sizing and Topology

| Pattern | Frequency | Description |
| --------- | ----------- | ------------- |
| 5-node Raft clusters | Very High (90%+) | Deploy 5 nodes for n-2 redundancy; maintain quorum with 2 nodes down |
| 3-AZ distribution | Very High | Spread nodes across 3 availability zones (2-2-1 pattern) |
| Integrated Storage (Raft) | High | Preferred over Consul for reduced operational complexity |
| <8ms RTT between nodes | High | Maximum acceptable latency between cluster members |
| Dedicated Vault nodes | High | Single-tenant deployments; no co-location with other workloads |
| Non-burstable instances | High | Avoid T-series/burstable instances; CPU throttling causes issues |

**Recommended Instance Sizing:**

| Size | CPU | Memory | Disk | IOPS | AWS Type |
| ------ | ----- | -------- | ------ | ------ | ---------- |
| Small (<500 clients) | 2-4 core | 8-16 GB | 50+ GB SSD | 3000+ | m5.large |
| Large (500+ clients) | 4-8 core | 32-64 GB | 100+ GB SSD | 10000+ | m5.2xlarge |
| High Transit/PKI | 8+ core | 64 GB | 200+ GB SSD | 10000+ | m5.4xlarge |

#### Disaster Recovery Architecture

```text
Primary Cluster (Region 1)              DR Secondary (Region 2)
┌──────────────────────────┐            ┌──────────────────────────┐
│  5 nodes (2-2-1 across   │    DR      │  5 nodes (mirror of      │
│  3 AZs) with Raft        │◄──────────►│  primary configuration)  │
│  Auto-unseal: HSM/KMS    │ Replication│  Auto-unseal: HSM/KMS    │
└──────────────────────────┘            └──────────────────────────┘
           ↑                                      ↑
      Active (200)                          Standby (472)
           │                                      │
    ┌──────┴──────┐                        ┌──────┴──────┐
    │Load Balancer│                        │Load Balancer│
    └─────────────┘                        └─────────────┘
```

**DR Best Practices:**

1. DR cluster MUST be in separate region from primary
2. Mirror primary cluster specifications exactly
3. Use different KMS/HSM in DR region (avoid single point of failure)
4. Take backups from DR cluster to avoid loading primary
5. Test DR failover quarterly with documented runbooks
6. Never promote PR (Performance Replica) as DR - use dedicated DR clusters

#### Multi-Region Performance Replication

| Pattern | Use Case |
| --------- | ---------- |
| Primary + DR | Business continuity, failover |
| Primary + PR | Read scaling, geographic distribution |
| Primary + PR + DR | Multi-region with PR for reads, DR for failover |
| Hub-Spoke | Edge deployments with 100+ PoPs |

**Critical Replication Considerations:**

- Local mounts are NOT replicated (verify with `/sys/mounts`)
- Tokens and leases are NOT replicated to PR clusters
- Batch tokens ARE portable across PR clusters
- Never enable two primaries simultaneously
- Upgrade DR/PR secondaries BEFORE primary

---

### 2. Security Hardening Patterns

#### Root Token Management (Critical - 100% of assessments)

| Requirement | Implementation |
| ------------- | ---------------- |
| Revoke after initial setup | `vault token revoke <root-token>` immediately after cluster init |
| Generate only when needed | `vault operator generate-root` with recovery key quorum |
| Never persist | Do not store in password managers, CI/CD, or automation |
| Alert on creation | Monitor `vault.token.create_root` metric - any increment is security event |
| Time-bound operations | Complete root operations quickly, revoke immediately after |

#### Recovery Key Management

| Requirement | Implementation |
| ------------- | ---------------- |
| PGP encryption | Initialize with `vault operator init -pgp-keys=...` |
| 5 shards, 3 threshold | Standard recommended configuration |
| Separate storage | Each keyholder stores their shard separately (different locations) |
| Rotate regularly | Every 1-3 months or when any keyholder leaves organization |
| Document distribution | Maintain organizational standard for key distribution |

**Key Ceremony Procedure:**

```bash
# Initialize with PGP encryption
vault operator init \
    -key-shares=5 \
    -key-threshold=3 \
    -pgp-keys="keybase:user1,keybase:user2,keybase:user3,keybase:user4,keybase:user5"

# Rotate keys when needed
vault operator rekey -init -key-shares=5 -key-threshold=3
vault operator rekey -pgp-keys="..." <recovery-key>
```

#### Auto-Unseal Configuration

| Method | Use Case | Priority |
| -------- | ---------- | ---------- |
| Cloud KMS (AWS/Azure/GCP) | Cloud deployments | Preferred |
| HSM (PKCS#11) | On-premises, regulated industries | Preferred |
| Transit Auto-Unseal | Multi-cluster with dedicated unseal cluster | Acceptable |
| Shamir Shards | Development only | Avoid in production |

**Seal High Availability (Vault 1.16+):**

```hcl
# Configure 2-3 seals for redundancy
seal "awskms" {
  name       = "primary"
  priority   = 1
  region     = "us-east-1"
  kms_key_id = "alias/vault-unseal-primary"
}

seal "awskms" {
  name       = "secondary"
  priority   = 2
  region     = "us-west-2"
  kms_key_id = "alias/vault-unseal-secondary"
}
```

#### Production Hardening Checklist

| Category | Requirement |
| ---------- | ------------- |
| TLS | End-to-end encryption; never terminate at load balancer |
| Memory | Disable swap (`swapoff -a`) |
| Process | Disable core dumps |
| User | Don't run Vault as root |
| Shell | Disable command history for operators |
| Network | Single-tenant deployments |
| Access | Disable SSH; use immutable infrastructure |
| Storage | Dedicated disk partitions for audit logs |

---

### 3. Audit Logging Patterns (Critical)

#### Multiple Audit Devices (Required)

> **Critical**: Vault stops ALL operations if it cannot write to at least one audit device.

| Configuration | Implementation |
| --------------- | ---------------- |
| Minimum 2 devices | File + Socket/Syslog |
| Local fallback | File audit for when remote is unavailable |
| Centralized logging | Splunk, ELK, DataDog for analysis |
| Separate volume | Dedicated partition for audit logs |
| Log rotation | Use logrotate for file-based logs |

```bash
# Enable multiple audit devices
vault audit enable file file_path=/var/log/vault/audit.log
vault audit enable syslog tag="vault" facility="AUTH"

# Or socket for centralized logging
vault audit enable socket address="127.0.0.1:9090" socket_type="tcp"
```

#### Privileged Endpoints to Monitor

Alert on any access to these `/sys` endpoints:

| Endpoint | Risk |
| ---------- | ------ |
| `/sys/generate-root` | Root token generation |
| `/sys/rekey` | Seal key regeneration |
| `/sys/rekey-recovery-keys` | Recovery key regeneration |
| `/sys/replication` | Replication configuration changes |
| `/sys/audit` | Audit device modifications |
| `/sys/rotate` | Master key rotation |
| `/sys/policy`, `/sys/policies` | Policy modifications |

---

### 4. Monitoring Metrics (Comprehensive)

#### Critical Metrics (Alert Immediately)

| Metric | Threshold | Impact |
| -------- | ----------- | -------- |
| `vault.audit.log_request_failure` | > 0 | **CRITICAL** - Vault stops if all audit devices fail |
| `vault.audit.log_response_failure` | > 0 | **CRITICAL** - Same as above |
| `vault.core.unsealed` | = 0 | Node is sealed |
| `vault.autopilot.healthy` | = 0 | Cluster health issue |

#### Leadership & Consensus Metrics

| Metric | Threshold | Meaning |
| -------- | ----------- | --------- |
| `vault.raft.leader.lastContact` | > 200ms | Cluster consensus unhealthy |
| `vault.raft.state.candidate` | > 0 | Leader elections occurring |
| `vault.raft.state.leader` | > 0 | Node became leader (watch for frequent changes) |
| `vault.core.leadership_lost` | Any occurrence | Leadership instability |

#### Performance Metrics

| Metric | Threshold | Meaning |
| -------- | ----------- | --------- |
| `vault.core.handle_request` | > 50% deviation from baseline | Request latency degradation |
| `vault.core.handle_login_request` | > 50% deviation or 3σ | Auth latency issue |
| `vault.barrier.get/put` | > 50% deviation | Storage performance |
| `vault.runtime.gc_pause_ns` | > 2s/min (warn), > 5s/min (crit) | Memory pressure |

#### WAL & Replication Metrics

| Metric | Threshold | Meaning |
| -------- | ----------- | --------- |
| `vault.wal.flushReady` | > 500ms | Replication backpressure |
| `vault.wal.persistWALs` | > 1000ms | WAL persistence issues |
| `vault.merkle.diff` | Large values | Replication sync issues |
| `vault.replication.merkleSync` | Monitor trends | Replication health |

#### Resource Metrics

| Metric | Threshold | Meaning |
| -------- | ----------- | --------- |
| `cpu.iowait_cpu` | > 10% | I/O bottleneck |
| `mem.used_percent` | > 90% | Memory pressure |
| `swap.used_percent` | > 0% | Swap should be disabled |
| `linux_sysctl_fs.file-nr` | > 80% of file-max | File descriptor exhaustion |

#### Token & Lease Metrics

| Metric | Threshold | Meaning |
| -------- | ----------- | --------- |
| `vault.expire.num_leases` | Unexpected large delta | Runaway application or misconfiguration |
| `vault.token.create_root` | Any increment | Security alert - root token created |
| `vault.core.license.expiration_time_epoch` | < 30 days | License expiring |

---

### 5. Authentication Best Practices

#### Authentication Method Selection

| Method | Use Case | Priority |
| -------- | ---------- | ---------- |
| Kubernetes | K8s workloads | Preferred for containers |
| AWS IAM | EC2/Lambda/ECS | Preferred for AWS |
| Azure AD | Azure workloads | Preferred for Azure |
| GCP IAM | GCP workloads | Preferred for GCP |
| OIDC | Human users via SSO | Preferred for humans |
| LDAP | Human users (legacy) | Acceptable |
| AppRole | CI/CD, applications without platform identity | Last resort |
| Userpass | Break-glass emergency only | Emergency only |
| Certificate (TLS) | Service-to-service mTLS | Specialized use |

#### AppRole Trusted Broker Pattern

> **Core Principle**: RoleID and SecretID should ONLY ever be together on the end-user system that consumes the secret.

**CI/CD Pipeline Architecture:**

```text
┌─────────┐                    ┌─────────┐                    ┌─────────┐
│   CI    │ 1.Auth ──────────► │  Vault  │ ◄──── 8.Auth ─────│  Runner │
│ Worker  │ ◄──── 2.Token ──── │         │ ──── 9.Token ───► │Container│
│(Broker) │ 3.Wrapped SecretID │         │ ◄── 10.Get Secret │         │
│         │ ◄──── 4.Return ─── │         │ ──── 11.Secret ──►│         │
│         │ 5.Spawn+Pass ─────────────────────────────────────►         │
└─────────┘                    └─────────┘     6.Unwrap       └─────────┘
                                               7.SecretID
```

**Workflow:**

1. CI Worker authenticates to Vault (using its own identity)
2. Vault returns token with limited policy
3. Worker requests **wrapped** SecretID for the runner role
4. Vault returns wrapped SecretID (single-use token)
5. Worker spawns runner container, passes wrapped SecretID
6. Runner unwraps the SecretID
7. Runner uses RoleID + SecretID to authenticate
8. Vault returns token with runner-specific policies
9. Runner retrieves secrets

**Worker Policy (Trusted Broker):**

```hcl
# Can only create wrapped SecretIDs, not access secrets directly
path "auth/approle/role/+/secret*" {
  capabilities = ["create", "read", "update"]
  min_wrapping_ttl = "100s"
  max_wrapping_ttl = "300s"
}
```

**Runner Policy (Scoped to Specific Secrets):**

```hcl
path "secret/data/{{identity.entity.metadata.app}}/*" {
  capabilities = ["read"]
}
```

**Security Configurations:**

| Setting | Value | Purpose |
| --------- | ------- | --------- |
| `secret_id_num_uses` | 1 | Single-use SecretIDs |
| `secret_id_ttl` | 120s | Short-lived SecretIDs |
| `secret_id_bound_cidrs` | Network range | Restrict login location |
| `wrap_ttl` | 100-300s | Response wrapping for delivery |

#### Token TTL Best Practices

| Use Case | Recommended TTL |
| ---------- | ----------------- |
| CI/CD jobs | 15 minutes - 1 hour |
| Short-lived applications | 1-4 hours |
| Long-running services | 8-24 hours with renewal |
| Human interactive | 8-12 hours |
| Batch tokens (stateless) | Match job duration |

> **Anti-pattern**: Using default 32-day (768 hour) TTL. This causes lease accumulation and increases blast radius.

---

### 6. Namespace Design Patterns

#### When to Use Namespaces

| Criterion | Use Namespace? |
| ----------- | --------------- |
| Need separate policy administration | Yes |
| Different compliance requirements | Yes |
| Distinct business units | Yes |
| Team-level isolation | Maybe (consider policies first) |
| Per-application isolation | No (use policies) |
| Per-environment (dev/prod) | No (separate clusters preferred) |

#### Namespace Architecture

**Recommended Structure (Flat):**

```text
root/
├── shared-services/     # Shared auth, PKI roots
├── business-unit-a/     # LOB-level namespace
│   ├── team-1/          # Max 2-3 levels deep
│   └── team-2/
└── business-unit-b/
```

**Anti-patterns:**

- Deep nesting (> 3 levels)
- Namespace per person
- Environment names in paths (dev/staging/prod)
- Namespace per application

#### Authentication Placement

| Auth Method | Mount Location |
| ------------- | ---------------- |
| OIDC/LDAP (human) | Root namespace |
| Kubernetes | Child namespace (per cluster) |
| AppRole | Child namespace (per application group) |
| AWS/Azure/GCP | Root or child (depends on account structure) |

**Rationale**: Human auth at root reduces entity duplication; machine auth at child namespaces for isolation.

#### Namespace Limits

| Configuration | Approximate Limit |
| --------------- | ------------------- |
| Default mount table | ~4,600 namespaces |
| With optimized settings | Higher (contact HashiCorp) |
| Recommended max depth | 2-3 levels |

---

### 7. Secrets Engine Patterns

#### Database Secrets Engine

**Configuration Best Practices:**

| Requirement | Implementation |
| ------------- | ---------------- |
| Dedicated Vault user | Create separate DB user with minimal permissions |
| Rotate root credentials | `vault write -f database/rotate-root/mydb` after initial config |
| Dynamic roles | Unique credentials per request for applications |
| Static roles | 1:1 mapping for service accounts (rotated automatically) |
| Connection limits | Configure max_open_connections appropriately |

**Oracle Plugin Note**: Not bundled with Vault - requires separate download and Oracle Instant Client installation.

**Role Design:**

```bash
# Dynamic role - new credentials each time
vault write database/roles/app-dynamic \
    db_name=mydb \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON mydb.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

# Static role - single user, password rotated
vault write database/static-roles/service-account \
    db_name=mydb \
    username="svc_account" \
    rotation_period="24h"
```

#### PKI Cross-Namespace Patterns

##### Option 1: Shared Root CA (Recommended for mTLS)

```text
root/pki_root/         # Root CA at root namespace
├── team-a/pki_int/    # Intermediate CAs in child namespaces
├── team-b/pki_int/    # Each signs certs for their services
└── team-c/pki_int/    # All can mTLS with each other
```

##### Option 2: Subsidiary CAs

Each namespace has intermediate CA signed by another namespace's root.

##### Option 3: Central PKI Endpoint

Single PKI engine at root with policy-based access control.

**PKI Performance Recommendations:**

| Setting | Value | Purpose |
| --------- | ------- | --------- |
| `no_store` | true | Don't store certificates in Vault (high-volume issuance) |
| `generate_lease` | false | Reduces storage overhead |
| Short TTLs | Hours to days | Reduces CRL size |
| `allowed_domains` | Explicit list | Enforce naming conventions |

#### SSH Secrets Engine

**Certificate Authority Mode (Recommended):**

```bash
# Configure SSH CA
vault secrets enable -path=ssh-client-signer ssh
vault write ssh-client-signer/config/ca generate_signing_key=true

# Create role
vault write ssh-client-signer/roles/admin \
    key_type=ca \
    default_user=admin \
    allowed_users="admin,ubuntu,ec2-user" \
    ttl=30m \
    max_ttl=1h \
    allow_user_certificates=true
```

**Post-Implementation:**

1. Remove `authorized_keys` files from hosts
2. Configure sshd to trust Vault CA
3. Wrap SSH binary with script for seamless integration
4. Use short TTLs (30 minutes recommended)

#### Transit Secrets Engine

**Use Cases:**

| Use Case | Pattern |
| ---------- | --------- |
| Application encryption | Apps call Transit instead of implementing crypto |
| Auto-unseal | Dedicated Transit cluster for unsealing other Vaults |
| Tokenization | Format-preserving encryption for compliance |
| BYOK | Import customer keys with audit trail |

**Auto-Unseal with Transit:**

```hcl
seal "transit" {
  address = "https://transit-vault.example.com:8200"
  token = "s.xxxxxxxx"  # Or use auth method
  key_name = "unseal-key"
  mount_path = "transit/"
}
```

**Power Management**: For cost/ESG, Transit unseal clusters can be powered down when not in active unseal use (acceptable for non-prod environments).

---

### 8. Backup & Recovery Patterns

#### Automated Snapshots

```hcl
# Automated snapshot configuration (Vault 1.12+)
automatic_snapshots {
  interval         = "1h"              # Align with RPO
  retain           = 168               # 7 days at hourly
  storage_type     = "aws-s3"
  aws_s3_bucket    = "vault-snapshots"
  aws_s3_region    = "us-east-1"
  aws_s3_kms_key   = "alias/vault-snapshots"
}
```

**Snapshot Best Practices:**

| Requirement | Implementation |
| ------------- | ---------------- |
| Frequency | Match RPO (typically hourly) |
| Storage | Off-host in geo-redundant location (S3, GCS) |
| Encryption | KMS encryption at rest |
| Take from DR | Backup from DR cluster to avoid loading primary |
| Test restores | Quarterly restore testing required |
| Retention | 7-30 days typical; align with compliance |

**Never use VM/SAN snapshots** - Raft consistency requirements mean these can cause data corruption on restore.

#### DR Failover Procedure

```bash
# 1. Verify DR secondary is caught up
vault read sys/replication/dr/status

# 2. Generate DR operation token (pre-created for emergencies)
vault operator generate-root -dr-token

# 3. Promote DR secondary
vault write sys/replication/dr/secondary/promote dr_operation_token=<token>

# 4. Update load balancer to point to new primary

# 5. After recovery, set up new DR secondary
```

**Migration Strategy (Performance Replication):**

1. Set up new Performance Secondary in target environment
2. Set up new DR Secondary attached to new Perf Secondary
3. Validate replication status and data integrity
4. Switch load balancer to new Performance Secondary
5. Demote old Primary to secondary
6. Promote new Performance Secondary to Primary
7. Clean up old clusters

---

### 9. Operations Patterns

#### Upgrade Strategy

| Upgrade Type | Method |
| -------------- | -------- |
| Patch versions | Rolling upgrade (followers first, then leader) |
| Minor versions | Rolling upgrade with Autopilot (1.11+) |
| Major versions | Blue-green via DR promotion |

**Upgrade Order:**

1. DR secondaries
2. Performance secondaries
3. Primary standbys
4. Primary leader

> **Never** replicate from newer version to older version.

**Pre-Upgrade Checklist:**

- [ ] Take Raft snapshot
- [ ] Verify within N-2 of target version
- [ ] Review version-specific upgrade guide
- [ ] Test in non-production first
- [ ] Document rollback procedure

#### Rate Limiting & Quotas

```hcl
# Global rate limit
vault write sys/quotas/rate-limit/global \
    rate=1000 \
    interval="1s"

# Lease count quota (per namespace)
vault write sys/quotas/lease-count/apps \
    max_leases=10000 \
    path="secret/"

# Path-specific rate limit
vault write sys/quotas/rate-limit/database \
    rate=100 \
    path="database/"
```

#### Load Balancer Configuration

**Health Check Endpoint:**

```text
/v1/sys/health?perfstandbyok=true&standbyok=true
```

**Response Codes:**

| Code | Meaning | Route Traffic? |
| ------ | --------- | ---------------- |
| 200 | Active, unsealed | Yes |
| 429 | Standby, unsealed | Yes (if standbyok) |
| 472 | DR secondary | No (unless failover) |
| 473 | Performance standby | Yes (if perfstandbyok) |
| 501 | Uninitialized | No |
| 503 | Sealed | No |

**Requirements:**

- Layer 4 (TCP) load balancing for TLS passthrough
- If Layer 7, must re-encrypt to Vault nodes
- Sticky sessions not required (Vault handles leader forwarding)

---

### 10. Anti-Patterns (Comprehensive)

#### Critical Anti-Patterns (Fix Immediately)

| Anti-Pattern | Risk | Correct Approach |
| -------------- | ------ | ------------------ |
| Single audit device | Vault stops if it fails | Configure 2+ audit devices |
| Stored root token | Unlimited privileged access | Revoke after init; generate on-demand |
| TLS termination at LB | Secrets exposed in transit | End-to-end TLS to Vault nodes |
| Shamir unseal in production | Manual intervention required | Use auto-unseal (KMS/HSM) |
| Default 32-day TTL | Lease accumulation, large blast radius | Set explicit short TTLs |

#### High-Risk Anti-Patterns

| Anti-Pattern | Risk | Correct Approach |
| -------------- | ------ | ------------------ |
| DR in same region as primary | Single region failure = total outage | DR in separate region |
| VM/SAN snapshots for backup | Raft consistency issues | Use Vault's snapshot utility |
| Running Vault as root | Privilege escalation risk | Dedicated service account |
| SSH access to Vault nodes | Attack surface expansion | Immutable infrastructure |
| Two primaries simultaneously | Data loss | Never - violates replication design |
| Stretched clusters across WAN | Split-brain risk | Use DR/PR replication instead |

#### Medium-Risk Anti-Patterns

| Anti-Pattern | Risk | Correct Approach |
| -------------- | ------ | ------------------ |
| Deep namespace nesting | Operational complexity | Max 2-3 levels |
| Namespace per person | Scalability issues | Use policy templating |
| Environment names in paths | Encourages cross-env access | Business-oriented naming |
| Burstable instances | CPU throttling causes issues | Dedicated instance types |
| 3-node clusters | n-1 fault tolerance only | 5 nodes for n-2 tolerance |
| Single unseal keyholder | Single point of compromise | 5 keys, 3 threshold |
| Promoting PR for DR | Loss of tokens/leases | Use dedicated DR replication |
| Passing secrets through CI | Secrets in logs, env vars | Use trusted broker pattern |
| Manual Vault configuration | Drift, human error | Terraform provider for all config |
| Untested DR procedures | Unknown RTO in disaster | Quarterly DR drills |

---

### 11. Reference File Enhancements Required

Based on comprehensive CSA analysis, the following new reference files and enhancements are required:

#### New Reference Files

| File | Content |
| ------ | --------- |
| `references/production-operations.md` | Monitoring metrics, backup/restore, upgrades, rate limiting |
| `references/vault-agent.md` | Agent configuration, auto-auth, caching, templates, sidecar patterns |

#### Existing File Enhancements

| Reference File | Additions |
| ---------------- | ----------- |
| auth-methods.md | Trusted broker pattern, response wrapping workflow, security configurations |
| enterprise.md | Namespace decision tree, replication migration, administrative namespaces |
| troubleshooting.md | Complete monitoring metrics table, privileged endpoint monitoring |
| secrets-engines.md | SSH CA workflow, PKI performance settings, Database best practices |
| policies.md | CI pipeline policies, min/max wrapping TTL, policy templating examples |
| kubernetes.md | Vault Agent sidecar patterns, VSO advanced configuration |

---

## HashiCorp Validated Designs Findings (2026-01-23)

Comprehensive crawl of the [HashiCorp Validated Designs](https://developer.hashicorp.com/validated-designs) mini-site covering all Vault-related official production guidance. These represent HashiCorp's official recommendations based on validated enterprise deployments.

### Source Documentation

| Guide | URL | Pages Crawled |
| ------- | ----- | --------------- |
| Operating Guide for Adoption | `/validated-designs/vault-operating-guides-adoption/*` | 9 |
| Operating Guide for Scaling | `/validated-designs/vault-operating-guides-scaling/*` | 5 |
| Operating Guide for Standardization | `/validated-designs/vault-operating-guides-standardization/*` | 5 |
| Solution Design Guide | `/validated-designs/vault-solution-design-guides-vault-enterprise/*` | 4 |

**Total**: 23 pages crawled from 4 Vault-specific validated design guides.

---

### 1. Maturity Model: Adopt → Standardize → Scale

> **Source**: HVD Operating Guides Introduction pages

HashiCorp defines a formal maturity progression for Vault adoption:

| Phase | Focus Areas | Secrets Engines | Auth Methods |
| ------- | ------------- | ----------------- | -------------- |
| **Adopt** | Static secrets, human auth, audit, namespaces | KV v2 | OIDC, LDAP |
| **Standardize** | MFA, dynamic secrets, K8s integration, Sentinel | Database, PKI (basic) | Kubernetes, AppRole |
| **Scale** | PKI at scale, performance replication, Transit/Transform, Key Management | Transit, Transform, PKI (full), KMIP | All enterprise methods |

**Implementation Guidance:**

- Start with Adopt phase use cases before moving to Standardize
- Do not attempt Scale phase patterns until Adopt/Standardize are mature
- Each phase builds on patterns from previous phase

---

### 2. Namespace Design Anti-Patterns (Critical)

> **Source**: HVD Adoption - Initial Configuration

**Storage and Performance Impacts:**

| Anti-Pattern | Risk | Validated Guidance |
| -------------- | ------ | ------------------- |
| No clear namespace criteria | Management chaos | Define criteria before creating any namespace |
| Strong misalignment to org structure | User confusion | Align roughly to LOB/division structure |
| Over-segmentation (namespace per app) | Hits storage limits | Use policies for app-level isolation |
| Deep nesting (> 3 levels) | Performance, complexity | Maximum 2-3 levels recommended |

**Storage Limits:**

- Each namespace requires minimum 2 secret engine mounts (sys, identity), 1 local engine (cubbyhole), 1 auth mount (token)
- Default mount table: ~4,600 namespaces maximum
- Large namespace counts impact leader election time

**When to Use Namespaces:**

| Criterion | Use Namespace? |
| ----------- | --------------- |
| Tenant isolation required (GDPR, compliance) | ✅ Yes |
| Self-management delegation needed | ✅ Yes |
| Per-application isolation | ❌ No (use policies) |
| Per-environment (dev/prod) | ❌ No (separate clusters) |

---

### 3. Kubernetes Integration Decision Matrix

> **Source**: HVD Standardization - Consume Secrets in Kubernetes

| Method | Architecture | Best For | Auth Methods | Rolling Updates |
| -------- | -------------- | ---------- | -------------- | ----------------- |
| **Vault Secrets Operator (VSO)** | Operator (controller) | Multi-Vault instances, AWS auth, native K8s secrets | All supported methods | ✅ Yes |
| **Vault Agent Sidecar Injector** | Sidecar (mutating webhook) | Legacy apps, shared memory volumes | All Agent auto-auth methods | ❌ Requires restart |
| **CSI Provider** | DaemonSet | Edge appliances, high uptime, no pod restart | Kubernetes, JWT | ❌ No (updates via volume) |

**Scenario-Based Selection:**

| Scenario | Recommended Method | Rationale |
| ---------- | ------------------- | ----------- |
| Platform team manages edge appliance with substantial uptime | CSI Provider | No pod restart for secret updates |
| Multiple Vault instances + AWS auth + rolling updates needed | VSO | Multi-vault support, rolling updates |
| App cannot be made Vault-aware | Agent Sidecar Injector | Renders to shared memory volume |
| Need native Kubernetes Secret objects | VSO | Renders as native K8s secrets |

---

### 4. Transit vs Transform Engine Decision

> **Source**: HVD Scaling - Transit and Transform

| Engine | Use Cases | License | Key Capabilities |
| -------- | ----------- | --------- | ------------------ |
| **Transit** | API payload encryption, DB field encryption, config data | Community | Encrypt, decrypt, sign, verify, rewrap |
| **Transform** | Credit cards (FPE), SSN tokenization, data masking | Enterprise (ADP) | FPE (FF1, FF3-1), tokenization, masking |

**Common Use Cases Mapped:**

| Use Case | Engine | Compliance |
| ---------- | -------- | ------------ |
| Encrypting credit card data in transit | Transit | PCI-DSS |
| Format-preserving encryption (16-digit CC stays 16-digit) | Transform FPE | PCI-DSS |
| Tokenizing SSN/PII for analytics | Transform Tokenization | HIPAA, GDPR |
| Masking phone numbers in customer service | Transform Masking | Privacy |
| Securing configuration data | Transit | General |

**Transform Security Considerations:**

| Consideration | Implementation |
| --------------- | ---------------- |
| Token storage security | Secure Vault integrated storage or external SQL with encryption |
| Access controls | Strict RBAC on encode/decode operations |
| Audit logging | Enable for all tokenization activities |
| High-volume tokenization | Use external SQL stores (MySQL, PostgreSQL, SQL Server) |

**Scaling Transit/Transform:**

| Pattern | Implementation |
| --------- | --------------- |
| Horizontal scaling | Add non-voter (performance standby) nodes |
| Tokenization writes | External SQL for token mappings |
| Connection pooling | Implement HTTP connection pooling for API calls |
| Batch processing | Use batch API for bulk operations |

---

### 5. Monitoring: 50+ Key Metrics with Thresholds

> **Source**: HVD Adoption - Monitoring and Observability

#### Host Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `swap.used_percent` | gauge | > 0% | Disable swap for Integrated Storage |
| `diskio.read_bytes` / `diskio.write_bytes` | gauge | > 50% or 3σ from mean | I/O crucial for cluster stability |
| `cpu.user_cpu` | gauge | Standard host threshold | User process CPU |
| `cpu.iowait_cpu` | gauge | > 10% | I/O wait time |
| `net.bytes_recv` / `net.bytes_sent` | gauge | > 50% deviation | Network utilization |
| `linux_sysctl_fs.file-nr` | gauge | > 80% of file-max | File descriptor exhaustion |

#### Seal Status and Leadership Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.core.unsealed` | gauge | Any host = 0 | Node is sealed |
| `vault.core.post_unseal` | gauge | INFO on occurrence | Post-unseal timing |
| `vault.core.leadership_setup_failed` | summary | > 0 | Leadership takeover failure |
| `vault.core.leadership_lost` | summary | > 0 | Lost leadership (low value = instability) |
| `vault.core.step_down` | summary | > 50% or 3σ from mean | Leadership step-downs |
| `vault.core.license.expiration_time_epoch` | gauge | < 30 days | License expiring |

#### Core Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.runtime.alloc_bytes` | summary | 3 × 20% deviations from mean | Memory allocated |
| `vault.runtime.num_goroutines` | summary | 3 × 20% deviations from mean | Blocked goroutines impact GC |
| `vault.runtime.gc_pause_ns` | sample | > 2s/min warn, > 5s/min crit | GC pause time |
| `vault.barrier.get` / `vault.barrier.put` | summary | > 50% or 3σ from mean | Storage operations |
| `vault.core.mount_table.size` | gauge | > 50% or 3σ from mean | Mount table growth |

#### Request Handling Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.core.handle_request` | summary | > 50% or 3σ from mean | Overall request latency |
| `vault.core.handle_login_request` | summary | > 50% or 3σ from mean | Login latency specifically |

#### Usage Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.token.create_root` | counter | On any change | **SECURITY ALERT** - root token created |
| `vault.token.creation` | counter | > 50% or 3σ from mean | Token creation rate |
| `vault.expire.num_leases` | gauge | > 50% or 3σ from mean | Runaway leases indicate misconfiguration |
| `vault.expire.revoke` / `vault.expire.renew` | summary | > 3σ from mean | Lease lifecycle |
| `vault.identity.num_entities` | gauge | > 50% or 3σ from mean | Entity count growth |

#### Replication Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.merkle.flushDirty` | summary | > 50% or 3σ from mean | Replication saturation |
| `vault.merkle.diff` | summary | > 50% or 3σ from mean | Replication sync issues |
| `vault.wal.persistWALs` | summary | > 1000ms | WAL persistence |
| `vault.wal.flushReady` | summary | > 500ms | WAL flush time |
| `vault.wal.write_controller.reject_fraction` | gauge | INFO (consistently high = scaling issue) | Write overload protection |

#### Integrated Storage (Raft) Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.raft.leader.lastContact` | summary | > 0 (monitor value) | Leader contact time |
| `vault.raft.state.candidate` | counter | On change | Election occurring |
| `vault.raft.state.leader` | counter | On change | New leader elected |
| `vault.raft.get` / `vault.raft.put` / `vault.raft.list` | summary | > 50% or 3σ from mean | Storage operations |

#### Audit Device Metrics

| Metric | Type | Alert Threshold | Notes |
| -------- | ------ | ----------------- | ------- |
| `vault.audit.log_request_failure` | counter | > 0 | **CRITICAL** - audit failure |
| `vault.audit.log_response_failure` | counter | > 0 | **CRITICAL** - audit failure |
| `vault.audit.file.log_request` | summary | > 50% or 3σ from mean | File audit timing |
| `vault.audit.syslog.log_request` | summary | > 50% or 3σ from mean | Syslog audit timing |

---

### 6. Audit Log Usage Patterns to Alert On

> **Source**: HVD Adoption - Monitoring and Observability

**Security-Critical Patterns:**

| Pattern | Severity | Action |
| --------- | ---------- | -------- |
| Use of root token | CRITICAL | Immediate investigation |
| Creation of new root token | CRITICAL | Verify authorized key ceremony |
| Increased invalid path attempts with same credentials | HIGH | Potential enumeration attack |
| Special tokens used from unexpected IP | HIGH | Credential compromise indicator |
| Permission denied (403) spike | MEDIUM | Policy misconfiguration or attack |
| Vault requests from unrecognized subnets | HIGH | Network perimeter breach |
| Many auth attempts with varying credentials from same subnet | HIGH | Brute force attempt |
| Many auth attempts in short time | MEDIUM | DoS or credential stuffing |
| Sealing of Vault | CRITICAL | Operational or security event |
| Changes to audit devices | HIGH | Audit tampering attempt |
| K/V secret modifications (create/update/delete) | INFO | Track for compliance |
| PKI certificate generation/revocation | INFO | Track for compliance |
| Transit key deletion | HIGH | Potential data loss |
| Changes to Transit minimum decryption version | MEDIUM | May break decryption |

---

### 7. Privileged Endpoints to Monitor

> **Source**: HVD Adoption - Monitoring and Observability

Alert on any access to these endpoints (configure SIEM):

| Endpoint | Risk | Normal Access |
| ---------- | ------ | --------------- |
| `/sys/generate-root` | Root token generation | Emergency only |
| `/sys/rekey` | Seal key regeneration | Key ceremony only |
| `/sys/rekey-recovery-keys` | Recovery key regeneration | Key ceremony only |
| `/sys/replication` | Replication configuration | Planned changes only |
| `/sys/audit` | Audit device modifications | Initial setup only |
| `/sys/audit-hash` | Audit hash comparison | Investigation only |
| `/sys/rotate` | Master key rotation | Scheduled rotation only |
| `/sys/policy` / `/sys/policies` | Policy modifications | Change-controlled |

---

### 8. AppRole Best Practices (Enhanced)

> **Source**: HVD Adoption - Authentication for Applications

**Response Wrapping Enforcement:**

```hcl
# Force response wrapping on SecretID creation
path "auth/approle/role/my-role/secret-id" {
  capabilities = ["create", "update"]
  min_wrapping_ttl = "1s"    # Minimum 1 second
  max_wrapping_ttl = "90s"   # Maximum 90 seconds
}
```

**SecretID Delivery Security:**

| Method | Security | Implementation |
| -------- | ---------- | ---------------- |
| Response wrapping | ✅ Best | Use `-wrap-ttl` for SecretID generation |
| CIDR binding | ✅ Good | Set `secret_id_bound_cidrs` |
| Short TTL | ✅ Good | Set `secret_id_ttl=15m` or less |
| Single use | ✅ Required | Set `secret_id_num_uses=1` |

**Audit Log Monitoring for Compromise:**

- Monitor for 500 errors when applications attempt SecretID unwrap
- 500 indicates wrapping token already used (potential compromise)
- Wrapping tokens are single-use; any reuse attempt = security event

**Delivery Channel Separation:**

| Component | Delivery Channel | Rationale |
| ----------- | ----------------- | ----------- |
| RoleID | Baked into image/container | Not secret, can be embedded |
| SecretID (wrapped) | Pushed at runtime by orchestrator | Secret, must be protected |

> **NEVER** deliver both RoleID and SecretID through the same channel.

---

### 9. Secrets Sync Design Considerations

> **Source**: HVD Adoption - Secrets Sync

**Architecture:**

| Consideration | Implementation |
| --------------- | ---------------- |
| Network paths | Vault must reach all sync destinations (including from DR cluster) |
| Active node only | Sync operations processed only on active node |
| No scaling benefit | Adding performance replicas does not improve sync throughput |

**Mount and Namespace Structure:**

| Pattern | Recommendation |
| --------- | --------------- |
| Multiple destinations per namespace | ✅ Supported |
| One destination per application | ✅ Recommended for policy isolation |
| Name templates | Define per destination to prevent collisions |
| Default template | `vault/{{ .NamespacePath }}{{ .MountPath }}/{{ .SecretPath }}` |

**Lifecycle Management:**

| Behavior | Description |
| ---------- | ------------- |
| Secret update | Changes sync to external systems |
| Secret removal | Removed from external systems |
| Last-write-wins | Vault overwrites existing secrets at destination |
| Rotation awareness | Applications must handle credential rotation |

**Terraform Resources:**

```hcl
# AWS Secrets Manager destination
resource "vault_secrets_sync_aws_destination" "aws" {
  name                 = "my-account"
  access_key_id        = var.access_key_id
  secret_access_key    = var.secret_access_key
  region               = "us-east-1"
  secret_name_template = "vault/{{ .NamespacePath }}{{ .MountPath }}/{{ .SecretPath }}"
}

# Secret association
resource "vault_secrets_sync_association" "example" {
  name        = vault_secrets_sync_aws_destination.aws.name
  type        = vault_secrets_sync_aws_destination.aws.type
  mount       = "secret"
  secret_name = "database/credentials"
}
```

---

### 10. Vault Agent Templates (Enhanced)

> **Source**: HVD Standardization - Vault Agent Templates

**Template Configuration:**

```hcl
template_config {
  static_secret_render_interval = "5m"
  exit_on_retry_failure         = true
}

template {
  source      = "/vault/templates/config.ctmpl"
  destination = "/app/config.json"
  perms       = "0644"
  
  # Error handling
  error_on_missing_key = false
}
```

**Environment Variable Injection:**

```hcl
env_template {
  name        = "DB_PASSWORD"
  contents    = "{{ with secret \"database/creds/app\" }}{{ .Data.password }}{{ end }}"
  exit_on_retry_failure = true
}
```

**PKI Certificate with pkiCert Function:**

```hcl
template {
  contents = <<EOF
{{ with pkiCert "pki/issue/web" "common_name=app.example.com" "ttl=24h" }}
{{ .Cert }}
{{ .CA }}
{{ .Key }}
{{ end }}
EOF
  destination = "/app/tls/bundle.pem"
}
```

**Process Supervisor Mode:**

```hcl
exec {
  command = ["/app/start.sh"]
  restart_on_secret_changes = "always"
  restart_stop_signal = "SIGTERM"
}
```

> Use Process Supervisor for applications that need secrets in environment memory (not files).

---

### 11. Terraform Deployment via HVD Modules

> **Source**: HVD Solution Design - Deploying Vault using Terraform

**Official HVD Modules:**

| Cloud | Module |
| ------- | -------- |
| AWS | `hashicorp/vault-enterprise-hvd/aws` |
| Azure | `hashicorp/vault-enterprise-hvd/azurerm` |
| GCP | `hashicorp/vault-enterprise-hvd/google` |

**Deployment Sequence:**

1. Create TLS certificate files (public, private key, CA bundle)
2. Obtain Vault Enterprise license
3. Deploy prerequisite infrastructure (VPC, subnets, KMS key)
4. Initialize Terraform workspace
5. Configure `terraform.tfvars`
6. Create and apply Terraform plan
7. Initialize Vault with PGP keys (key ceremony)

**Key Ceremony with GPG:**

```bash
# Generate GPG key for each keyholder
gpg --full-gen-key --batch <<EOF
Key-Type: 1
Key-Length: 4096
Name-Real: Alice
Name-Email: alice@example.com
Expire-Date: 1
Passphrase: <secure-passphrase>
EOF

gpg --output alice_key.pub --export alice@example.com

# Initialize Vault with PGP-encrypted keys
vault operator init \
  -recovery-pgp-keys "alice.pub,bob.pub,carol.pub,dan.pub,frank.pub" \
  -root-token-pgp-key "alice.pub"
```

---

### 12. Upgrade Best Practices (Autopilot)

> **Source**: HVD Adoption - Standard Operational Procedures

**Autopilot Upgrade Workflow (Vault 1.11+):**

1. Create new launch template with target Vault version
2. Double ASG desired capacity (e.g., 3 → 6 nodes)
3. New nodes join cluster as non-voters
4. Monitor upgrade status:

   ```bash
   vault read sys/storage/raft/autopilot/state | jq '.data.upgrade_info'
   ```

5. Wait for `status: await-server-removal`
6. Remove old nodes: `vault operator raft remove-peer <node-id>`
7. Enable scale-in protection for new nodes
8. Reduce ASG desired capacity to original
9. Verify: `vault status` shows new version
10. Remove scale-in protection

**Autopilot Benefits:**

- Minimizes administrative involvement
- Uses Raft snapshots (faster than replication)
- Built-in safety checks
- Minimal downtime

**Important Notes:**

- Autopilot does NOT auto-remove old nodes (manual step required)
- Default configs suitable for most scenarios
- Avoid tuning unless in dynamic environment (K8s, ASG)

---

### 13. Initial Configuration Best Practices

> **Source**: HVD Adoption - Initial Configuration

**Audit Device Configuration:**

| Requirement | Implementation |
| ------------- | ---------------- |
| Minimum 2 devices | File + Syslog recommended |
| Log rotation | Use `logrotate` with SIGHUP for file audit |
| Separate volume | Avoid I/O contention with Raft storage |
| Typical log size | 1-3KB per entry, 10-30MB/hour at 10K requests/hour |

**Log Rotation Configuration:**

```conf
/opt/vault/log/vault_audit.log {
  daily
  rotate 7
  notifempty
  missingok
  compress
  delaycompress
  postrotate
    /bin/systemctl reload vault 2> /dev/null || true
  endscript
  create 0644 vault vault
}
```

---

### 14. Human Authentication Configuration

> **Source**: HVD Adoption - Authentication for People

**OIDC Auth Method Workflow:**

1. Enable auth method: `vault auth enable oidc`
2. Configure provider connection
3. Create default role with claims mapping
4. Create external group + policy mapping
5. Validate login flow

**Role Configuration Example:**

```bash
vault write auth/oidc/role/default \
  user_claim="email" \
  groups_claim="groups" \
  allowed_redirect_uris="https://vault.example.com:8200/ui/vault/auth/oidc/oidc/callback,https://vault.example.com:8250/oidc/callback" \
  token_policies="default" \
  token_ttl="1h" \
  token_max_ttl="1h"
```

**External Group Mapping:**

```bash
# Create external group
GROUP_ID=$(vault write -format=json identity/group \
  name="vault-admins" type="external" policies="admin" | jq -r ".data.id")

# Get mount accessor
MOUNT_ACCESSOR=$(vault read -field=accessor sys/mounts/auth/oidc)

# Create group alias
vault write identity/group-alias \
  name="vault-admins" \
  mount_accessor=$MOUNT_ACCESSOR \
  canonical_id=$GROUP_ID
```

**Root Token Revocation:**

After configuring first auth method, immediately revoke root token:

```bash
vault token revoke <root-token>
```

Generate new root token only for emergencies:

```bash
vault operator generate-root
```

---

### 15. Machine Authentication Patterns

> **Source**: HVD Adoption - Authentication for Applications

**Secure Introduction Approaches:**

| Approach | When to Use | Methods |
| ---------- | ------------- | --------- |
| Platform Integration | AWS/Azure/GCP/K8s workloads | AWS IAM, Azure AD, GCP IAM, Kubernetes |
| Trusted Orchestrator | No platform identity available | AppRole, TLS Certs, Token |

**AWS IAM Auth Method:**

```bash
# Enable
vault auth enable aws

# Configure (if Vault not on EC2 with IAM role)
vault write auth/aws/config/client \
  secret_key="..." \
  access_key="..."

# Require X-Vault-AWS-IAM-Server-ID header (replay protection)
vault write auth/aws/config/client \
  iam_server_id_header_value=vault.example.com

# Create role
vault write auth/aws/role/app \
  auth_type=iam \
  bound_iam_principal_arn="arn:aws:iam::123456789012:role/AppRole" \
  policies=app-policy \
  token_ttl=1h
```

---

### 16. Incident Response Procedures

> **Source**: HVD Adoption - Monitoring and Observability

**Token Compromise Response:**

1. **Revoke compromised token:**

   ```bash
   vault token revoke <token_id>
   # or by accessor
   vault token revoke -accessor <accessor>
   ```

2. **Determine time frame** of unauthorized activity

3. **Search audit logs by token hash:**

   ```bash
   vault write sys/audit-hash/file input="$COMPROMISED_TOKEN"
   # Use returned hash to grep audit logs
   ```

4. **Review accessed secrets** from audit entries

5. **Rotate affected secrets:**

   ```bash
   # Revoke by lease ID
   vault lease revoke database/creds/app/<lease-id>
   
   # Revoke by prefix (bulk)
   vault lease revoke -prefix database/creds/
   ```

**Restrict Access (Emergency):**

| Method | Scope | Command |
| -------- | ------- | --------- |
| Seal Vault | All operations | `vault operator seal` |
| Lock namespace | Namespace + children | `vault namespace lock <ns>` |

**Namespace Lock/Unlock:**

```bash
# Lock (save unlock_key!)
vault namespace lock my-namespace
# Returns: unlock_key = uzkzIgUvtyj3fP1bKlclk9ox

# Unlock after remediation
vault namespace unlock -unlock-key <key> my-namespace
```

---

### 17. DR/PR Replication Patterns

> **Source**: HVD Adoption - Disaster Recovery Setup

**Replication Types:**

| Type | Token Portable? | Lease Portable? | Use Case |
| ------ | ----------------- | ----------------- | ---------- |
| DR Replication | ❌ No | ❌ No | Business continuity |
| Performance Replication | Batch only | ❌ No | Read scaling, geo-distribution |

**DR Operation Token:**

- Pre-generate batch DR operation tokens for emergencies
- Store securely (not in Vault being protected)
- Tokens generated with `vault operator generate-root -dr-token`

**Failback Considerations:**

After DR promotion:

1. Old primary becomes secondary after recovery
2. All tokens/leases from old primary are lost
3. Applications must re-authenticate

---

### 18. Dynamic Secrets Best Practices

> **Source**: HVD Standardization - Dynamic Secrets

**Database Secrets Engine:**

| Recommendation | Implementation |
| ---------------- | ---------------- |
| 1:1 root user per engine | Each database connection gets dedicated root user |
| Rotate root immediately | `vault write -f database/rotate-root/mydb` |
| Network considerations | Vault must reach database; consider firewall rules |
| TTL tuning | Balance security (short) vs connection churn (long) |

**TTL Recommendations:**

| Use Case | Recommended TTL |
| ---------- | ----------------- |
| Short-lived jobs | 15 minutes - 1 hour |
| Long-running services | 4-24 hours with renewal |
| Interactive sessions | 8-12 hours |

---

### 19. MFA Configuration

> **Source**: HVD Standardization - Secure Remote Access with MFA

**MFA Types:**

| Type | When Evaluated | Use Case |
| ------ | ---------------- | ---------- |
| Login MFA | At authentication | Protect all logins |
| Step-up MFA | At specific paths | Protect sensitive operations |

**TOTP MFA Setup:**

```bash
# Enable MFA method
vault write sys/mfa/method/totp/my-totp \
  issuer="Vault" \
  period=30 \
  key_size=20 \
  algorithm=SHA1 \
  digits=6

# Enforce on login
vault write auth/userpass/mfa_config \
  type="totp" \
  name="my-totp"
```

---

### Reference File Updates Required

Based on Validated Designs analysis, add to existing reference files:

| File | Additions |
| ------ | ----------- |
| `production-operations.md` | Autopilot upgrade workflow, incident response, namespace lock |
| `kubernetes.md` | VSO/CSI/Injector decision matrix, scenario-based selection |
| `secrets-engines.md` | Transit vs Transform comparison, Transform security considerations |
| `auth-methods.md` | Response wrapping enforcement policy, AWS IAM server ID header |
| `enterprise.md` | Maturity model phases, namespace storage limits |
| `troubleshooting.md` | Complete 50+ metrics table with thresholds |
| `vault-agent.md` | pkiCert function, process supervisor mode, env_template |

---

## References

- [Agent Skills Specification](https://agentskills.io/specification)
- [Anthropic Platform Best Practices](https://platform.claude.com)
- [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault)
- [HashiCorp Validated Designs](https://developer.hashicorp.com/validated-designs)
- [Repository CONTRIBUTING.md](../../CONTRIBUTING.md)
