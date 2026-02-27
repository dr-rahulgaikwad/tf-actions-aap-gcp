# Explorer

**URL**: `/app/{org}/explorer` (redirects to `/explorer/types`)
**Title**: Explorer
**Purpose**: Analyze organization Terraform usage through pre-built and custom queries across modules, providers, workspaces, and versions

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Explorer/Types & use cases    │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Global:   │ "Explorer"                                      │
│ ──────────│ Description: Explore your data...               │
│ Manage    │ [New query ▼] button                            │
│ • Projects├─────────────────────────────────────────────────┤
│ • Stacks  │ TAB_BAR: [Types & use cases] [Saved views 50]   │
│ • Worksp  ├─────────────────────────────────────────────────┤
│ • Registry│ TYPES_SECTION                                   │
│ • Usage   │ Heading: "Types"                                │
│ • Settings│ ┌────────────┬────────────┬────────────┬──────┐ │
│ ──────────│ │ [Modules]  │[Providers] │[Workspaces]│[TF   ││ │
│ Visibility│ │            │            │            │Vers] ││ │
│ • Explorer│ └────────────┴────────────┴────────────┴──────┘ │
│ ──────────├─────────────────────────────────────────────────┤
│ Cloud Plat│ USE_CASES_SECTION                               │
│ • HCP     │ Heading: "Use cases"                            │
│           │ Subtext + feedback link                         │
│           │ ┌─────────────────────────────────────────────┐ │
│           │ │[Top module]│[Latest TF]│[Top provider]│...  │ │
│           │ │[Workspaces]│[Workspace]│[Workspaces  ]│...  │ │
│           │ │[without VCS]│[VCS srce]│[failed checks]│... │ │
│           │ │ ...more use case cards...                   │ │
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
| BREADCRUMB | Current location | Org > Explorer > Current tab | System managed |
| PAGE_HEADER | Page identity | Heading, description, New query button | N/A |
| TAB_BAR | View switching | Types & use cases, Saved views with count | New explorer tabs |
| TYPES_SECTION | Data type selection | Cards for Modules, Providers, Workspaces, Terraform Versions | New data types |
| USE_CASES_SECTION | Pre-built queries | Grid of use case cards with feedback link | New use case templates |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Type Card | Icon + label + arrow | "Modules →" | Data type selection |
| Use Case Card | Icon + label + arrow | "Top module versions →" | Pre-built query shortcuts |
| Tab with Count | `Label count` | "Saved views 50" | Tab with item count |
| New Query Button | Button with dropdown | "New query ▼" | Creating custom queries |
| Feedback Link | Inline text link with external icon | "Send us feedback [↗]" | User feedback collection |
| Card Grid | Horizontal card layout | Types row, Use cases grid | Multiple selectable options |

## Pre-built Use Cases

| Use Case | Query Type | Purpose |
|----------|-----------|---------|
| Top module versions | modules | Most used module versions |
| Latest Terraform versions | workspaces | Workspaces with newest TF versions |
| Top provider versions | providers | Most used provider versions |
| Workspaces without VCS | workspaces | Workspaces not connected to VCS |
| Workspace VCS source | workspaces | VCS repository connections |
| Workspaces with failed checks | workspaces | Health check failures |
| Drifted workspaces | workspaces | Workspaces with configuration drift |
| All workspace versions | workspaces | TF version inventory |
| Workspaces by run status | workspaces | Run status breakdown |
| Top Terraform versions | tf_versions | Most common TF versions |
| Latest updated workspaces | workspaces | Recently modified workspaces |
| Oldest applied workspaces | workspaces | Stale workspaces |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Explorer | BREADCRUMB | `/app/{org}/explorer/types` | explorer.md |
| Breadcrumb: Types & use cases | BREADCRUMB | `/app/{org}/explorer/types` | explorer.md |
| Projects | SIDEBAR | `/app/{org}/projects` | projects-list.md |
| Stacks | SIDEBAR | `/app/{org}/stacks` | stacks-list.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Registry | SIDEBAR | `/app/{org}/registry` | - |
| Usage | SIDEBAR | `/app/{org}/usage` | usage.md |
| Settings | SIDEBAR | `/app/{org}/settings` | org-settings.md |
| Explorer | SIDEBAR | `/app/{org}/explorer` | explorer.md |
| HashiCorp Cloud Platform | SIDEBAR | External: HCP Portal | - |
| [New query] button | PAGE_HEADER | Opens query builder | - |
| Tab: Types & use cases | TAB_BAR | `/app/{org}/explorer/types` | - |
| Tab: Saved views | TAB_BAR | `/app/{org}/explorer/saved` | - |
| Modules card | TYPES_SECTION | `/app/{org}/explorer/types/Modules?type=modules` | - |
| Providers card | TYPES_SECTION | `/app/{org}/explorer/types/Providers?type=providers` | - |
| Workspaces card | TYPES_SECTION | `/app/{org}/explorer/types/Workspaces?type=workspaces` | - |
| Terraform Versions card | TYPES_SECTION | `/app/{org}/explorer/types/Terraform%20Versions?type=tf_versions` | - |
| Send us feedback | USE_CASES_SECTION | External: Google Form | - |
| Use case cards | USE_CASES_SECTION | `/app/{org}/explorer/types/{name}?...` (with query params) | - |
