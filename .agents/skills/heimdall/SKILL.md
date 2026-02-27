---
name: heimdall
description: Heimdall data reliability platform for operational metrics, service ownership, and HUTS tagging. Use when checking ops health, on-call coverage, or service ownership.
---

# Heimdall - Data Reliability Platform

A comprehensive guide to using Heimdall, HashiCorp's internal data reliability platform for operational excellence.

## What is Heimdall?

[Heimdall](https://heimdall.hashicorp.services/) is HashiCorp's internal "data reliability platform" that aggregates data from across wide and disparate sources to guide teams towards good operational standards in an org-chart aware manner.

**Key Features:**
- **Multi-Source Data Aggregation**: Collects operational data from Datadog, GitHub, PagerDuty, and Team Directory
- **Org-Chart Awareness**: Understands team structures and ownership for accurate attribution
- **Operational Standards**: Provides visibility into SRE metrics and operational health
- **Unified Tagging**: HUTS (Heimdall Unified Tagging Scheme) for consistent resource attribution
- **Extensible Architecture**: Pluggable collector system for adding new data sources

**Primary Use Cases:**
- Track service ownership and team responsibility
- Monitor operational health across services
- Identify gaps in monitoring, alerting, and on-call coverage
- Provide SRE metrics visibility
- Ensure operational standards compliance

## When to Use Heimdall

Use Heimdall when you need to:

- **Check service ownership**: Find out which team owns a specific service or resource
- **Audit operational coverage**: Verify monitoring, alerting, and on-call setup
- **Track SRE metrics**: Get visibility into MTTR, incident frequency, on-call rotations
- **Understand team topology**: See org-chart relationships and service ownership
- **Validate resource attribution**: Ensure services are properly tagged and attributed
- **Build operational dashboards**: Query aggregated data from multiple sources

**Who uses Heimdall:**
- SRE teams monitoring operational health
- Engineering managers tracking team services
- On-call engineers finding service ownership
- Platform teams ensuring operational standards

## Installation & Access

### Web Interface

Access Heimdall at: https://heimdall.hashicorp.services/

Requires HashiCorp SSO authentication.

### API Access

Heimdall provides a GraphQL API for programmatic access. See the [Heimdall Core repository](https://github.com/hashicorp/core-sre-heimdall-core) for API documentation.

## Architecture

Heimdall consists of:

### Core Platform
**Repository**: https://github.com/hashicorp/core-sre-heimdall-core

The core platform provides:
- GraphQL API for data queries
- Web UI for data visualization
- Data storage and indexing
- Collector orchestration
- HUTS (Unified Tagging Scheme) implementation

### Collectors

Collectors are specialized components that pull data from external sources:

#### Datadog Collector
**Repository**: https://github.com/hashicorp/core-sre-heimdall-datadog-collector

Collects:
- Monitor configurations
- Alert definitions
- Dashboard metadata
- Service metrics
- Downtime schedules

**RFC**: [SRE-014 Heimdall DataDog Collector](https://docs.google.com/document/d/1XMi8M1SvflKbHqxm7Gc-D0hSEAK2IoLa3l8GzNfAKws/edit)

#### GitHub Collector
**Repository**: https://github.com/hashicorp/core-sre-heimdall-github-collector

Collects:
- Repository metadata
- Team memberships
- Code ownership (CODEOWNERS)
- Repository topics and tags
- Deployment configurations

**RFC**: [SRE-013 Heimdall GitHub Collector](https://docs.google.com/document/d/1Gl0ScPA2gUfH7XohUpKQ-qoKfE0Eh3O8M0prm8e8Jgw/edit)

#### PagerDuty Collector
**Repository**: https://github.com/hashicorp/core-sre-heimdall-pagerduty-collector

Collects:
- On-call schedules
- Escalation policies
- Service configurations
- Incident history
- Team assignments

**RFC**: [SRE-016 Heimdall PagerDuty Collector](https://docs.google.com/document/d/1tt5XS6E0NORtI6K89FfNrj3xJ9mGt9O2MyUDhAcsHYw/edit)

#### Team Directory Collector
**Repository**: https://github.com/hashicorp/core-sre-heimdall-team-directory-collector

Collects:
- Team structures
- Team memberships
- Reporting relationships
- Service ownership mappings

**ADR**: [SRE-017 Heimdall Team Directory Collector](https://docs.google.com/document/d/1XfsvYNyBIF9ITrMk9Oc1Je7w_3W3reQ2mNRb7ci7yPI/edit)

### Resource Attribution Library
**Repository**: https://github.com/hashicorp/core-sre-heimdall-resource-attribution

Provides shared logic for:
- Resource tagging and attribution
- HUTS implementation
- Team ownership resolution
- Cross-platform correlation

## Common Workflows

### 1. Finding Service Ownership

**Goal**: Determine which team owns a specific service.

**Steps**:
1. Navigate to https://heimdall.hashicorp.services/
2. Search for the service name or repository
3. View the ownership information in the results
4. Check team attribution from Team Directory data

**Via API**:
```graphql
query {
  service(name: "terraform-cloud-api") {
    name
    owner {
      team
      slackChannel
      pagerdutySchedule
    }
    repositories {
      name
      url
    }
  }
}
```

### 2. Auditing Operational Coverage

**Goal**: Verify a service has proper monitoring, alerting, and on-call setup.

**Steps**:
1. Search for the service in Heimdall
2. Check Datadog monitor coverage
3. Verify PagerDuty on-call schedule exists
4. Confirm escalation policies are configured
5. Review incident history and MTTR

**What to look for**:
- ✅ Active Datadog monitors
- ✅ PagerDuty service configured
- ✅ On-call schedule populated
- ✅ Escalation policy defined
- ✅ Recent incident response data

### 3. Understanding Team Services

**Goal**: See all services owned by a specific team.

**Steps**:
1. Navigate to Teams section
2. Select the team from the directory
3. View all attributed services
4. Review operational metrics per service

**Use cases**:
- Team onboarding: Show new members what services they own
- Capacity planning: Understand team's operational load
- Service handoffs: Transfer ownership between teams

### 4. Checking Incident Metrics

**Goal**: Review incident response metrics for a service.

**Steps**:
1. Find the service in Heimdall
2. Navigate to incidents/alerts section
3. Review:
   - MTTR (Mean Time To Resolution)
   - Incident frequency
   - Alert noise ratio
   - On-call burden

**Metrics provided**:
- Total incidents per time period
- Average resolution time
- Escalation patterns
- Alert-to-incident ratio

### 5. Validating Resource Tagging

**Goal**: Ensure services follow HUTS (Heimdall Unified Tagging Scheme).

**Steps**:
1. Review the service's resource attribution
2. Verify required tags are present:
   - Team ownership
   - Service classification
   - Environment designation
   - Cost allocation tags
3. Identify missing or incorrect tags
4. Update tags in source systems (GitHub, Datadog, PagerDuty)

**HUTS Tag Requirements**:
See [ADR SRE-015](https://docs.google.com/document/d/11xkb250pUhorrvk2q0GGvOmyoWtc1swUmTSjc4K0gJA/edit) for complete tagging scheme.

## Development & Contribution

### Local Development Setup

See the [Heimdall Core README](https://github.com/hashicorp/core-sre-heimdall-core) for:
- Local development environment setup
- Running collectors locally
- Testing data collection
- API development

### Creating a New Collector

**Goal**: Add a new data source to Heimdall.

**Process**:
1. Review the [example/guide Heimdall Collector RFC](https://docs.google.com/document/d/1e5ubjwUsPG-YxK1c6kHO2bfVyfCp5A9s6WuICFc9ONs/edit#)
2. Write an RFC proposing the new collector
3. Define data model and attribution logic
4. Implement collector following existing patterns
5. Add HUTS tagging support
6. Deploy and monitor

**Existing collectors to reference**:
- GitHub Collector: Repository and team data
- Datadog Collector: Monitoring and metrics
- PagerDuty Collector: On-call and incidents
- Team Directory Collector: Org structure

### Writing Custom Checks

Heimdall supports custom checks for operational standards. See the Heimdall Core README for:
- Check authoring guide
- Check execution model
- Notification configuration
- Check result visualization

## Troubleshooting

### Data Not Appearing

**Problem**: Service data isn't showing up in Heimdall.

**Solutions**:
1. **Check collector status**: Verify the relevant collector is running
2. **Review attribution tags**: Ensure resources have proper HUTS tags
3. **Verify source access**: Confirm collector has API access to source system
4. **Check collection logs**: Review collector logs for errors
5. **Manual collection**: Trigger a manual collection run

### Incorrect Ownership Attribution

**Problem**: Service is attributed to the wrong team.

**Solutions**:
1. **Check Team Directory data**: Verify team membership is correct
2. **Review CODEOWNERS**: Update GitHub CODEOWNERS file if needed
3. **Update resource tags**: Ensure source systems have correct team tags
4. **Check attribution logic**: Review resource-attribution library rules
5. **Manual override**: Contact SRE team for manual attribution fix

### Missing Operational Data

**Problem**: Monitoring, alerting, or on-call data is missing.

**Solutions**:
1. **Verify source configuration**:
   - Datadog: Check monitor tags and naming
   - PagerDuty: Verify service is created
   - GitHub: Ensure repository topics are set
2. **Check collector filters**: Some collectors filter based on tags
3. **Review data freshness**: Check last successful collection timestamp
4. **Validate API permissions**: Ensure collectors have read access

### API Query Issues

**Problem**: GraphQL queries return errors or unexpected results.

**Solutions**:
1. **Check query syntax**: Validate GraphQL query structure
2. **Review schema**: Use GraphQL introspection to see available fields
3. **Check authentication**: Ensure API token is valid
4. **Verify field availability**: Some fields require specific collectors
5. **Check rate limits**: Heimdall API may have rate limiting

### Collector Development Issues

**Problem**: Developing or testing a new collector.

**Solutions**:
1. **Review existing collectors**: Study working collector implementations
2. **Check core API compatibility**: Ensure using correct core API version
3. **Validate data model**: Confirm data structure matches core expectations
4. **Test attribution logic**: Use resource-attribution library correctly
5. **Check HUTS compliance**: Ensure tags follow unified tagging scheme

## Best Practices

### For Service Owners

1. **Maintain accurate tagging**: Keep HUTS tags up-to-date in all systems
2. **Update CODEOWNERS**: Ensure GitHub repositories have current ownership
3. **Configure PagerDuty**: Set up proper on-call schedules and escalation
4. **Tag Datadog monitors**: Use consistent tagging for service monitors
5. **Review metrics regularly**: Check Heimdall for operational health

### For SRE Teams

1. **Monitor collector health**: Ensure all collectors are running successfully
2. **Validate data quality**: Regularly audit attribution accuracy
3. **Update documentation**: Keep collector and check documentation current
4. **Review HUTS compliance**: Identify and fix tagging gaps
5. **Communicate changes**: Notify teams of new collectors or checks

### For Platform Engineers

1. **Use Heimdall for discovery**: Query Heimdall before creating new tooling
2. **Integrate with Heimdall**: Consider adding Heimdall data to dashboards
3. **Follow HUTS**: Apply unified tagging scheme to new resources
4. **Report issues**: File GitHub issues for data quality problems
5. **Contribute collectors**: Add new data sources that benefit multiple teams

## Integration with Other HashiCorp Tools

### Datadog
- Monitors and metrics provide operational visibility
- Dashboards can embed Heimdall ownership data
- Alert annotations can include Heimdall team info

### PagerDuty
- On-call schedules drive ownership attribution
- Incident data feeds SRE metrics
- Escalation policies inform team structure

### GitHub
- CODEOWNERS files provide ownership hints
- Repository topics enable service discovery
- Team memberships map to org structure

### Slack
- Heimdall can notify teams via Slack channels
- Service ownership maps to team channels
- Incident notifications include Heimdall links

## Key Concepts

### HUTS (Heimdall Unified Tagging Scheme)
A standardized tagging system ensuring consistent resource attribution across all platforms. See [ADR SRE-015](https://docs.google.com/document/d/11xkb250pUhorrvk2q0GGvOmyoWtc1swUmTSjc4K0gJA/edit).

**Core HUTS Tags**:
- `team`: Team ownership
- `service`: Service name
- `environment`: prod/staging/dev
- `product`: HashiCorp product association

### Org-Chart Awareness
Heimdall understands organizational hierarchy through Team Directory integration, enabling:
- Hierarchical service ownership
- Escalation path discovery
- Manager visibility into team services
- Cross-team dependency mapping

### Collector Architecture
Pluggable data ingestion system where each collector:
- Pulls data from a specific source
- Normalizes data to Heimdall schema
- Applies HUTS attribution
- Updates core platform

### Resource Attribution
The process of mapping resources (services, repositories, monitors) to owning teams using:
- Explicit tags
- CODEOWNERS files
- Team Directory mappings
- PagerDuty assignments

## Additional Resources

### Documentation
- **Heimdall Web UI**: https://heimdall.hashicorp.services/
- **Core Repository**: https://github.com/hashicorp/core-sre-heimdall-core
- **Confluence Page**: https://hashicorp.atlassian.net/wiki/spaces/PRAOP/pages/2411692117/Heimdall

### RFCs and ADRs
- **Charter**: [SRE-012 Heimdall: Reliability Data Platform](https://docs.google.com/document/d/11PeTi_CXPZ-yju-o4OSg2TU70bj56-1iGRNfvseC7yo/edit)
- **PRD**: [SRE-012 Evolving the Cloud Catalog](https://docs.google.com/document/d/1mzMO1rHM1xHKfi_Ech7l30VHvvkldAure92oaPDSfPQ/edit)
- **Tagging**: [ADR SRE-015 HUTS: Heimdall Unified Tagging Scheme](https://docs.google.com/document/d/11xkb250pUhorrvk2q0GGvOmyoWtc1swUmTSjc4K0gJA/edit)

### Collector RFCs
- [SRE-013 Heimdall GitHub Collector](https://docs.google.com/document/d/1Gl0ScPA2gUfH7XohUpKQ-qoKfE0Eh3O8M0prm8e8Jgw/edit)
- [SRE-014 Heimdall DataDog Collector](https://docs.google.com/document/d/1XMi8M1SvflKbHqxm7Gc-D0hSEAK2IoLa3l8GzNfAKws/edit)
- [SRE-016 Heimdall PagerDuty Collector](https://docs.google.com/document/d/1tt5XS6E0NORtI6K89FfNrj3xJ9mGt9O2MyUDhAcsHYw/edit)
- [SRE-017 Heimdall Team Directory Collector (ADR)](https://docs.google.com/document/d/1XfsvYNyBIF9ITrMk9Oc1Je7w_3W3reQ2mNRb7ci7yPI/edit)
- [Example Collector RFC Template](https://docs.google.com/document/d/1e5ubjwUsPG-YxK1c6kHO2bfVyfCp5A9s6WuICFc9ONs/edit#)

### Repositories
- **Core**: https://github.com/hashicorp/core-sre-heimdall-core
- **Datadog Collector**: https://github.com/hashicorp/core-sre-heimdall-datadog-collector
- **GitHub Collector**: https://github.com/hashicorp/core-sre-heimdall-github-collector
- **PagerDuty Collector**: https://github.com/hashicorp/core-sre-heimdall-pagerduty-collector
- **Team Directory Collector**: https://github.com/hashicorp/core-sre-heimdall-team-directory-collector
- **Resource Attribution Library**: https://github.com/hashicorp/core-sre-heimdall-resource-attribution

### Getting Help
- **SRE Team**: Contact #sre-team in Slack
- **GitHub Issues**: File issues in core-sre-heimdall-core repository
- **RFC Process**: Propose new collectors or features via RFC

---

*This skill is maintained by the HashiCorp SRE team. For updates or corrections, please contribute to the [hashicorp-agent-skills repository](https://github.com/hashicorp/hashicorp-agent-skills).*
