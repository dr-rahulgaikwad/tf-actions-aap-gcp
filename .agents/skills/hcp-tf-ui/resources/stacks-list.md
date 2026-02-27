# Stacks List

**URL**: `/app/{org}/stacks`
**Title**: Stacks
**Purpose**: List and manage all stacks in the organization (orchestrated infrastructure deployments)

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Stacks                      │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Global:   │ [icon] "Stacks"                                 │
│ ──────────├─────────────────────────────────────────────────┤
│ Manage    │ CONTENT (varies by state)                       │
│ • Projects│                                                 │
│ • Stacks* │ STATE: Disabled                                 │
│ • Worksp  │ ┌─────────────────────────────────────────────┐ │
│ • Registry│ │ [icon]                                      │ │
│ • Usage   │ │ "Stacks are disabled for your organization" │ │
│ • Settings│ │ You can enable Stacks in the org settings.  │ │
│ ──────────│ │ [Enable stacks →]                           │ │
│ Visibility│ └─────────────────────────────────────────────┘ │
│ • Explorer│                                                 │
│ ──────────│ STATE: Enabled (with stacks)                    │
│ Cloud Plat│ ┌─────────────────────────────────────────────┐ │
│ • HCP     │ │ [Search] [Filters] [New stack]              │ │
│           │ │ TABLE: Name | Project | Status | Updated    │ │
│           │ │        [rows...]                            │ │
│           │ │ PAGINATION                                  │ │
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
| BREADCRUMB | Current location | Org > Stacks | System managed |
| PAGE_HEADER | Page identity | Icon and heading | N/A |
| CONTENT | Main content area | Disabled state message OR stacks table | N/A |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Disabled Feature State | Large icon + heading + description + enable link | "Stacks are disabled" | Features not yet enabled |
| Enable Feature Link | Text link with arrow icon | "Enable stacks →" | Navigating to settings to enable |
| Page Header with Icon | Icon + heading | Stacks header | Page introduction |
| Stack Row | Name link + project + status + time | Table row (when enabled) | Each stack entry |
| New Button | Primary action button | "New stack" (when enabled) | Creating new stacks |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Projects | SIDEBAR | `/app/{org}/projects` | projects-list.md |
| Stacks | SIDEBAR | `/app/{org}/stacks` | stacks-list.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Registry | SIDEBAR | `/app/{org}/registry` | - |
| Usage | SIDEBAR | `/app/{org}/usage` | usage.md |
| Settings | SIDEBAR | `/app/{org}/settings` | org-settings.md |
| Explorer | SIDEBAR | `/app/{org}/explorer` | explorer.md |
| HashiCorp Cloud Platform | SIDEBAR | External: HCP Portal | - |
| Enable stacks | CONTENT (disabled state) | `/app/{org}/settings/profile` | org-settings.md |
| Stack name link | CONTENT (enabled state) | `/app/{org}/stacks/{stack}` | - |
| [New stack] button | CONTENT (enabled state) | Opens new stack modal | - |
