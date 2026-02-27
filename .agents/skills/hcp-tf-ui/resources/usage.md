# Usage Report

**URL**: `/app/{org}/usage`
**Title**: Usage Report | {Org Name}
**Purpose**: View organization usage statistics, subscription details, and resource consumption

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Usage                       │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Global:   │ "Usage report"                                  │
│ ──────────│ Showing current {Plan} plan subscription,       │
│ Manage    │ since {date} ({relative time})                  │
│ • Projects├─────────────────────────────────────────────────┤
│ • Stacks  │ OVERVIEW_SECTION                                │
│ • Worksp  │ "Overview"                                      │
│ • Registry│ ┌────────────┬────────────┬────────────┬──────┐ │
│ • Usage*  │ │ Active     │ Active     │ Total      │ App- │ │
│ • Settings│ │ projects   │ workspaces │ applies    │ lies │ │
│ ──────────│ │ 13         │ 154        │ 344,713    │ 81   │ │
│ Visibility│ │            │            │ since plan │ this │ │
│ • Explorer│ │            │            │ started    │ mo.  │ │
│ ──────────│ ├────────────┼────────────┼────────────┼──────┤ │
│ Cloud Plat│ │ Average    │ Billable   │ Concurrent │ Act- │ │
│ • HCP     │ │ applies/mo │ Managed    │ run limit  │ ive  │ │
│           │ │ 42,038     │ Res. [i]   │ reached    │ agen │ │
│           │ │            │ 11,822     │ 0 (*200)   │ [i]  │ │
│           │ ├────────────┼────────────┼────────────┼──────┤ │
│           │ │ Billable   │            │            │      │ │
│           │ │ Stacks [i] │            │            │      │ │
│           │ │ 0          │            │            │      │ │
│           │ └────────────┴────────────┴────────────┴──────┘ │
│           ├─────────────────────────────────────────────────┤
│           │ SUBSCRIPTION_SECTION                            │
│           │ "Subscription details"                          │
│           │ ┌─────────────────────────────────────────────┐ │
│           │ │ Plan                 │ Premium (entitlement)│ │
│           │ │ Run concurrency      │ 200                  │ │
│           │ │ Maximum agents       │ 300                  │ │
│           │ └─────────────────────────────────────────────┘ │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Organization navigation | Grouped nav: Manage, Visibility, Cloud Platform | New org-level nav items |
| BREADCRUMB | Current location | Org > Usage | System managed |
| PAGE_HEADER | Page identity | Heading, subscription summary with plan type and start date | N/A |
| OVERVIEW_SECTION | Usage statistics | Grid of stat cards with key metrics | New stat cards |
| SUBSCRIPTION_SECTION | Plan details | Table showing subscription limits | New subscription fields |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Stat Card | Label + large number + optional context | "Active projects" + "13" | Key metric display |
| Stat Card with Context | Label + number + subtext | "Total applies" + "344,713" + "since plan started" | Metric with explanation |
| Stat Card with Limit | Label + number + limit note | "0" + "*200 concurrent run limit" | Metrics with limits |
| Stat Card with Quota | Label + number + "out of X" | "0 out of 300" | Resource quota display |
| Info Button | Icon button next to label | [i] button on "Billable Managed Resources" | Metric explanation |
| Subscription Table | Two-column key-value table | Plan / Premium (entitlement) | Plan details display |
| Plan Badge | Bold text in subscription context | "Premium (entitlement)" | Plan type indicator |
| Relative Date | Date + relative time in parens | "December 16th 2025 (a month ago)" | Subscription start date |

## Overview Statistics

| Metric | Description |
|--------|-------------|
| Active projects | Number of projects with activity |
| Active workspaces | Number of workspaces with activity |
| Total applies | Total apply operations since plan started |
| Applies this month | Apply operations in current month |
| Average applies per month | Monthly average of apply operations |
| Billable Managed Resources | Resources under Terraform management (has info button) |
| Concurrent run limit reached | Times the concurrent run limit was hit |
| Active agents | Self-hosted agents currently active (has quota display) |
| Billable Stacks Resources | Resources managed by Stacks (has info button) |

## Subscription Details

| Field | Example Value | Description |
|-------|---------------|-------------|
| Plan | Premium (entitlement) | Subscription plan type |
| Run concurrency limit | 200 | Maximum concurrent runs |
| Maximum number of Agents | 300 | Maximum self-hosted agents |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Projects | SIDEBAR | `/app/{org}/projects` | projects-list.md |
| Stacks | SIDEBAR | `/app/{org}/stacks` | stacks-list.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Registry | SIDEBAR | `/app/{org}/registry` | registry-modules.md |
| Usage | SIDEBAR | `/app/{org}/usage` | usage.md |
| Settings | SIDEBAR | `/app/{org}/settings` | org-settings.md |
| Explorer | SIDEBAR | `/app/{org}/explorer` | explorer.md |
| HashiCorp Cloud Platform | SIDEBAR | External: HCP Portal | - |
| Billable Managed Resources [i] | OVERVIEW_SECTION | Opens info tooltip/modal | - |
| Active agents [i] | OVERVIEW_SECTION | Opens info tooltip/modal | - |
| Billable Stacks Resources [i] | OVERVIEW_SECTION | Opens info tooltip/modal | - |

## Notes

- The usage report shows data since the current subscription plan started
- Info buttons provide additional context about how metrics are calculated
- Quota displays (e.g., "0 out of 300") show current usage against plan limits
- The "*200 concurrent run limit" note indicates the plan's limit for concurrent runs
