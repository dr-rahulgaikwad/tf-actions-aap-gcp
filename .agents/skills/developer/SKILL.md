---
name: developer
description: HashiCorp Developer portal guide covering product docs, tutorials, certifications, validated patterns, and community resources. Use when looking up developer.hashicorp.com content or learning HashiCorp tools.
---

# HashiCorp Developer Portal

A comprehensive guide to using the HashiCorp Developer portal for documentation, tutorials, certifications, and community resources.

## What is the HashiCorp Developer Portal?

The [HashiCorp Developer portal](https://developer.hashicorp.com/) is the centralized hub for exploring tutorials, documentation, and learning resources across HashiCorp's product ecosystem. It serves as the primary destination for developers to learn about and implement HashiCorp tools.

**Key Features:**
- **Comprehensive Product Documentation**: Official documentation for all HashiCorp products
- **Interactive Tutorials**: Hands-on learning paths for each product
- **Certification Programs**: Professional credentials to validate product proficiency
- **Validated Patterns**: Field-tested architectural approaches
- **Well-Architected Framework**: Best practices for product implementation
- **Community Resources**: Forums, discussions, and support channels

**Primary Use Cases:**
- Learning HashiCorp products from scratch
- Finding reference documentation and API guides
- Following tutorials for specific use cases
- Preparing for HashiCorp certifications
- Discovering best practices and validated patterns
- Getting help from the community

## When to Use the Developer Portal

Use the HashiCorp Developer portal when you need to:

- **Learn a new HashiCorp product**: Start with tutorials and getting-started guides
- **Find product documentation**: Access official reference materials
- **Solve specific problems**: Search for tutorials and validated patterns
- **Prepare for certification**: Study certification guides and practice exams
- **Implement best practices**: Review Well-Architected Framework guidance
- **Get community help**: Post questions and engage with other users
- **Stay updated**: Check release notes and product announcements

**Who uses the Developer portal:**
- Software engineers implementing HashiCorp tools
- DevOps engineers building infrastructure automation
- SRE teams managing cloud infrastructure
- Platform engineers designing internal platforms
- Solution architects designing systems with HashiCorp products
- Anyone preparing for HashiCorp certifications

## Portal Structure

### Product Categories

HashiCorp products are organized into two main lifecycles:

#### Infrastructure Lifecycle Management
- **Terraform**: Infrastructure as Code for provisioning and managing cloud resources
- **Packer**: Automated machine image creation
- **Nomad**: Flexible workload orchestrator for containers and non-containerized apps
- **Waypoint**: Application deployment and release lifecycle management
- **Vagrant**: Development environment automation

#### Security Lifecycle Management
- **Vault**: Secrets management and data encryption
- **Boundary**: Secure remote access to systems and services
- **HCP Vault Radar**: Secrets detection and remediation
- **Consul**: Service networking and service mesh

### Documentation Sections

Each product typically includes:

1. **Overview**: Product introduction and key concepts
2. **Getting Started**: Quick start tutorials
3. **Tutorials**: Hands-on learning paths by use case
4. **Documentation**: Complete reference materials
5. **API Reference**: API endpoints and usage
6. **CLI Reference**: Command-line interface documentation
7. **Release Notes**: Version history and changes

### Additional Resources

- **Certifications**: Professional credential programs
- **Validated Patterns**: Production-ready architectural patterns
- **Well-Architected Framework**: Best practices across products
- **Community Forum**: discuss.hashicorp.com
- **System Status**: Status monitoring for HashiCorp services

## Common Workflows

### 1. Learning a New Product

**Goal**: Get started with a HashiCorp product you haven't used before.

**Steps**:
1. Navigate to https://developer.hashicorp.com/
2. Select the product from the product menu
3. Start with the "Overview" or "Get Started" section
4. Follow the getting-started tutorial step-by-step
5. Complete additional tutorials for your specific use case
6. Reference the documentation as you build

**Example learning paths**:
- **Terraform**: "Get Started - AWS" → "Configuration Language" → "Modules"
- **Vault**: "Get Started - HCP Vault" → "Secrets Engines" → "Auth Methods"
- **Consul**: "Get Started - Service Mesh" → "Service Discovery" → "Multi-Datacenter"

### 2. Finding Documentation for a Specific Feature

**Goal**: Look up reference documentation for a specific feature or command.

**Steps**:
1. Navigate to developer.hashicorp.com
2. Select the product
3. Use the search bar or browse the documentation sidebar
4. Navigate to the relevant section (e.g., "CLI Reference", "API Reference")
5. Bookmark frequently used pages

**Quick search tips**:
- Use product-specific search: "terraform state" finds Terraform state docs
- Search includes tutorials, docs, and API references
- Use filters to narrow results by product
- Search accepts CLI commands: "vault kv put"

### 3. Solving a Specific Problem

**Goal**: Find a tutorial or pattern for your use case.

**Steps**:
1. Search the developer portal for your use case
2. Check "Tutorials" section for hands-on guides
3. Review "Validated Patterns" for production approaches
4. Check "Well-Architected Framework" for best practices
5. Search community forum for similar questions

**Common use case searches**:
- "terraform aws vpc"
- "vault kubernetes integration"
- "consul service mesh configuration"
- "nomad job specification"

### 4. Preparing for Certification

**Goal**: Study for a HashiCorp certification exam.

**Steps**:
1. Navigate to https://developer.hashicorp.com/certifications
2. Select the certification you're pursuing:
   - Terraform Associate
   - Consul Associate
   - Vault Associate
   - Vault Operations Professional
3. Review the exam objectives and study guide
4. Complete the recommended tutorials
5. Take practice exams if available
6. Schedule your exam when ready

**Certification levels**:
- **Associate**: Foundational knowledge (Terraform, Vault, Consul)
- **Professional**: Advanced operational knowledge (Vault Operations)

### 5. Getting Community Help

**Goal**: Ask questions and get help from the HashiCorp community.

**Steps**:
1. Navigate to https://discuss.hashicorp.com/
2. Search existing discussions for your question
3. If not found, create a new topic:
   - Choose the appropriate product category
   - Provide clear description of your problem
   - Include relevant code/configuration snippets
   - Specify versions and environment details
4. Monitor for responses and engage with helpers
5. Mark solution when resolved

**Best practices for asking questions**:
- Search first to avoid duplicates
- Use appropriate tags (terraform, vault, etc.)
- Provide minimal reproducible examples
- Include error messages and logs
- Specify product versions
- Update with solution when resolved

### 6. Staying Current with Products

**Goal**: Keep up with product updates and new features.

**Steps**:
1. Subscribe to product release notes on developer.hashicorp.com
2. Check "What's New" sections for recent updates
3. Follow HashiCorp blog announcements
4. Monitor changelog for breaking changes
5. Review upgrade guides before updating

**Key update types**:
- **Major releases**: New features, breaking changes
- **Minor releases**: New features, backward compatible
- **Patch releases**: Bug fixes, security updates
- **Beta/Preview**: Experimental features

## HashiCorp Cloud Platform (HCP)

The Developer portal highlights HCP as the fastest way to get up and running with HashiCorp products:

**What is HCP:**
- Fully-managed, cloud-hosted HashiCorp products
- Available on AWS, Azure, and GCP
- No installation or operational overhead
- Integrated across multiple HashiCorp products
- Production-ready in minutes

**HCP Products:**
- HCP Terraform (formerly Terraform Cloud)
- HCP Vault
- HCP Consul
- HCP Boundary
- HCP Packer
- HCP Waypoint
- HCP Vault Radar

**Getting started with HCP:**
1. Visit https://portal.cloud.hashicorp.com/
2. Create a free HCP account
3. Select a product to deploy
4. Follow the setup wizard
5. Connect your applications

See the `/hcp` skill for detailed HCP guidance.

## Product-Specific Documentation

### Terraform
**Portal**: https://developer.hashicorp.com/terraform

**Key sections**:
- **Language**: HCL syntax, expressions, functions
- **CLI**: Command reference
- **Providers**: AWS, Azure, GCP, and 1000+ providers
- **Modules**: Reusable infrastructure components
- **State**: State management and backends
- **Cloud**: HCP Terraform integration

### Vault
**Portal**: https://developer.hashicorp.com/vault

**Key sections**:
- **Secrets Engines**: KV, Database, PKI, Transit, etc.
- **Auth Methods**: AWS, Kubernetes, LDAP, Token, etc.
- **Policies**: Access control and permissions
- **API**: HTTP API reference
- **Operations**: High availability, monitoring, backups

### Consul
**Portal**: https://developer.hashicorp.com/consul

**Key sections**:
- **Service Mesh**: Traffic management, mTLS
- **Service Discovery**: DNS, HTTP API
- **Service Configuration**: KV store, intentions
- **Multi-Datacenter**: WAN federation, replication
- **Kubernetes**: Integration with K8s

### Nomad
**Portal**: https://developer.hashicorp.com/nomad

**Key sections**:
- **Job Specification**: Task definitions
- **Schedulers**: Service, batch, system
- **Drivers**: Docker, Podman, exec, Java
- **Networking**: Service mesh integration
- **Autoscaling**: Dynamic application scaling

### Boundary
**Portal**: https://developer.hashicorp.com/boundary

**Key sections**:
- **Concepts**: Targets, sessions, credentials
- **Workers**: Self-hosted and HCP workers
- **Auth Methods**: OIDC, LDAP, password
- **Session Recording**: Audit and compliance
- **Dynamic Host Catalogs**: AWS, Azure integration

## Search Tips

### Effective Searching

**Use specific terms**:
- ❌ "how to use terraform"
- ✅ "terraform aws vpc module"

**Include version context**:
- "terraform 1.6 dynamic blocks"
- "vault 1.15 kv secrets engine"

**Search by error message**:
- Copy exact error messages into search
- Often leads to troubleshooting docs

**Filter by content type**:
- Add "tutorial" for hands-on guides
- Add "reference" for API docs
- Add "cli" for command documentation

### Navigation Shortcuts

**Direct product URLs**:
- `developer.hashicorp.com/terraform`
- `developer.hashicorp.com/vault`
- `developer.hashicorp.com/consul`

**Certification URLs**:
- `developer.hashicorp.com/certifications`
- `developer.hashicorp.com/certifications/terraform`

**Community**:
- `discuss.hashicorp.com`

## Troubleshooting

### Documentation Not Loading

**Problem**: Pages fail to load or show errors.

**Solutions**:
1. **Check system status**: Visit status.hashicorp.com
2. **Clear browser cache**: Hard refresh with Cmd+Shift+R (Mac) or Ctrl+F5 (Windows)
3. **Try different browser**: Test in incognito/private mode
4. **Check network**: Verify internet connection
5. **Report issue**: File feedback using page footer

### Can't Find Specific Documentation

**Problem**: Unable to locate documentation for a feature.

**Solutions**:
1. **Use search bar**: Search by feature name or command
2. **Check product navigation**: Browse sidebar for feature category
3. **Try Google**: Search "hashicorp [product] [feature]"
4. **Check GitHub**: Product repos often have additional docs
5. **Ask community**: Post on discuss.hashicorp.com

### Tutorial Doesn't Work

**Problem**: Following a tutorial but encountering errors.

**Solutions**:
1. **Check versions**: Ensure you're using tutorial's product version
2. **Review prerequisites**: Verify all required setup is complete
3. **Check for updates**: Tutorial may have been updated
4. **Search for errors**: Copy error messages into search
5. **Ask on forum**: Post detailed question on discuss.hashicorp.com with:
   - Tutorial link
   - Exact step where you're stuck
   - Error messages
   - Your environment details

### Certification Study Materials

**Problem**: Need more resources beyond developer portal.

**Solutions**:
1. **Review exam review guide**: Each cert has detailed study guide
2. **Complete all recommended tutorials**: Listed in study guide
3. **Practice with labs**: Use free tier HCP for hands-on practice
4. **Join study groups**: Find community study groups on forum
5. **Third-party courses**: Platforms like A Cloud Guru, Linux Academy

## Best Practices

### For Learning

1. **Follow tutorials sequentially**: Start with getting-started, progress to advanced
2. **Practice hands-on**: Use HCP free tier or local environments
3. **Bookmark frequently used pages**: Create documentation bookmarks
4. **Take notes**: Document your learnings and gotchas
5. **Join the community**: Engage on discuss.hashicorp.com

### For Documentation Reference

1. **Use version-specific docs**: Ensure docs match your product version
2. **Check release notes**: Review changes when upgrading
3. **Bookmark API references**: Keep frequently used endpoints handy
4. **Enable dark mode**: Available in portal settings (if supported)
5. **Use browser search**: Cmd/Ctrl+F to find text on long pages

### For Getting Help

1. **Search first**: Check docs, tutorials, and forum before asking
2. **Provide context**: Include versions, environment, error messages
3. **Use code blocks**: Format configuration properly in forum posts
4. **Be specific**: "How do I configure Vault" vs "How do I enable KV v2 secrets engine in Vault 1.15"
5. **Give back**: Answer questions when you can

## Integration with HashiCorp Internal Resources

### For HashiCorp Employees

While the developer portal is public-facing, HashiCorp employees can:

**Cross-reference with internal docs**:
- Link customer questions to developer portal articles
- Verify documentation accuracy during development
- Suggest improvements through internal channels

**Contribute to documentation**:
- File GitHub issues for doc improvements
- Submit PRs to product doc repositories
- Share feedback through internal Slack channels

**Use for customer support**:
- Share tutorial links with customers
- Reference validated patterns for architecture discussions
- Point to Well-Architected Framework for best practices

**Internal Confluence vs Developer Portal**:
- Developer portal: Public-facing product documentation
- Internal Confluence: Internal processes, team docs, architecture decisions
- Both are valuable: Use the right resource for the audience

## Additional Resources

### Official Links
- **Developer Portal**: https://developer.hashicorp.com/
- **Community Forum**: https://discuss.hashicorp.com/
- **System Status**: https://status.hashicorp.com/
- **HCP Console**: https://portal.cloud.hashicorp.com/
- **HashiCorp Blog**: https://www.hashicorp.com/blog

### Learning Resources
- **Certifications**: https://developer.hashicorp.com/certifications
- **Validated Patterns**: Browse per-product patterns
- **Well-Architected Framework**: Best practices guidance
- **YouTube Channel**: HashiCorp official tutorials and talks
- **GitHub**: Product repositories with examples

### Support Resources
- **Community Support**: https://discuss.hashicorp.com/
- **Paid Support**: Available through HCP Console
- **Enterprise Support**: Contact HashiCorp sales
- **Bug Reports**: File issues on product GitHub repositories

### Related Skills
- `/terraform` - Terraform infrastructure as code
- `/vault` - Vault secrets management
- `/consul` - Consul service mesh
- `/nomad` - Nomad workload orchestration
- `/hcp` - HashiCorp Cloud Platform

---

*This skill is maintained for developers using HashiCorp products. For updates or corrections, please contribute to the [hashicorp-agent-skills repository](https://github.com/hashicorp/hashicorp-agent-skills).*
