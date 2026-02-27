# Workspace Overview

**URL**: `/app/{org}/workspaces/{workspace}`
**Title**: Overview
**Purpose**: Display workspace status, latest run, resources, and configuration details

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Workspaces / {ws} / Overview│
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE: "boop"                              │
│ Workspace │ METADATA_BAR: ID | Description | Lock | Resources│
│ Context:  │              | Tags | Terraform Ver | Updated   │
│ ──────────│ ACTIONS: [Lock] [New run]                       │
│ • Worksp  ├──────────────────────────┬──────────────────────┤
│ • boop    │                          │ SIDEBAR_DETAILS      │
│   ├ Overv*│ LATEST_RUN_CARD          │ • Execution mode     │
│   ├ Runs  │ • Trigger info           │ • Auto-apply settings│
│   ├ States│ • Policy checks          │ • Auto-destroy       │
│   ├ Search│ • Cost estimate          │ • Project            │
│   ├ Vars  │ • Duration               │ ──────────────────── │
│   ├ Change│ • Resources changed      │ HEALTH_SECTION       │
│   ├ Health│ • Status + See details   │ • Drift status       │
│   └ Settin├──────────────────────────│ • Checks status      │
│           │ RESOURCES_PANEL          │ ──────────────────── │
│           │ [Resources] [Outputs]    │ METRICS_TABLE        │
│           │ (empty state or list)    │ • Avg plan duration  │
│           │                          │ • Avg apply duration │
│           │                          │ • Failed runs        │
│           │                          │ ──────────────────── │
│           │                          │ TAGS_SECTION         │
│           │                          │ ──────────────────── │
│           │                          │ RUN_TRIGGERS         │
│           │                          │ ──────────────────── │
│           │                          │ CONTRIBUTORS         │
├───────────┴──────────────────────────┴──────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context & navigation | Logo, org switcher, help, user menu | Global actions, notifications |
| SIDEBAR | Workspace-level navigation | Back to Workspaces, workspace name, sub-pages (Overview, Runs, States, Search & Import, Variables, Change requests, Health, Settings) | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Page | System managed |
| PAGE_TITLE | Workspace identity | Workspace name as heading with link | N/A |
| METADATA_BAR | Quick workspace info | ID (copyable), description link, lock status, resource count, tag count, Terraform version, last updated | New metadata items |
| ACTIONS | Primary workspace actions | Lock/Unlock button, New run button | Additional action buttons |
| LATEST_RUN_CARD | Most recent run summary | Trigger source, policy checks, cost estimate, duration, resources changed, status badge, link to details | New run metadata fields |
| RESOURCES_PANEL | Workspace resources | Tab group (Resources/Outputs), resource list or empty state | New resource tabs |
| SIDEBAR_DETAILS | Configuration summary | Execution mode, auto-apply settings, auto-destroy, project link | New configuration summaries |
| HEALTH_SECTION | Drift and checks status | Drift summary with counts, Checks summary with pass/fail/unknown | New health dimensions |
| METRICS_TABLE | Run statistics | Average plan/apply duration, failed runs count, policy failures | New metrics rows |
| TAGS_SECTION | Workspace tags | Tag list or empty state, Manage Tags button | N/A |
| RUN_TRIGGERS | Source workspace triggers | Trigger list or empty state, settings link | N/A |
| CONTRIBUTORS | Team access | Avatar buttons for contributors, link to access settings | N/A |
| FOOTER | Legal/support links | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Copyable ID | `ID: {value} [copy icon]` | `ws-j2sAeWRxou1b5HYf` | Workspace/resource IDs |
| Metadata Item | `[icon] Label: Value` or `[icon] Label {count}` | `🔓 Unlocked`, `Resources 0` | Inline workspace properties |
| Action Button | `[icon] Label` | `[▶] New run` | Primary actions |
| Card Section | Heading + content rows + link | Latest Run card | Grouped related information |
| Status Badge | `[icon] Status` | `✓ Applied` | Run/resource status |
| Detail Row | `Label: Value` or `Label [link]` | `Execution mode: Remote` | Configuration details |
| Health Summary | Label + View Details link + metric bars | Drift section | Health status with drill-down |
| Metric Row | `Label | Value` in table | `Avg plan duration | < 1 min` | Statistics display |
| Tab Group | `[Tab1] [Tab2]` + panel | Resources / Outputs | Switching content views |
| Empty State | Message + learn more link | "No resources" | When data is absent |
| Avatar Group | Circular initial buttons | `[O] [I] [T]` | Contributors/team members |
| Info Tooltip | `[?]` button | health-info-tooltip | Contextual help |
| Dismissable Banner | Message + action link + dismiss | "Run triggers can be set..." | Contextual suggestions |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Workspaces | BREADCRUMB | `/app/{org}/workspaces` | workspaces-list.md |
| Breadcrumb: {workspace} | BREADCRUMB | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Workspace name (heading) | PAGE_TITLE | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| ID copy button | METADATA_BAR | Copies workspace ID | - |
| Description link | METADATA_BAR | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| Tags count button | METADATA_BAR | Opens tag management | - |
| Terraform version link | METADATA_BAR | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| [Lock] button | ACTIONS | Locks/unlocks workspace | - |
| [New run] button | ACTIONS | Triggers new run modal | - |
| Workspaces (back) | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Overview | SIDEBAR | `/workspaces/{ws}` | workspace-overview.md |
| Runs | SIDEBAR | `/workspaces/{ws}/runs` | workspace-runs.md |
| States | SIDEBAR | `/workspaces/{ws}/states` | workspace-states.md |
| Search & Import | SIDEBAR | `/workspaces/{ws}/search` | - |
| Variables | SIDEBAR | `/workspaces/{ws}/variables` | workspace-variables.md |
| Change requests | SIDEBAR | `/workspaces/{ws}/change-requests` | - |
| Health | SIDEBAR | `/workspaces/{ws}/health/drift` | workspace-health.md |
| Settings | SIDEBAR | `/workspaces/{ws}/settings` | workspace-settings.md |
| Run trigger link | LATEST_RUN_CARD | `/workspaces/{ws}/runs/{run-id}` | workspace-run-detail.md |
| Policy checks: Add | LATEST_RUN_CARD | `/app/{org}/settings/policy-sets` | - |
| Resources changed button | LATEST_RUN_CARD | Expands resource details | - |
| See details link | LATEST_RUN_CARD | `/workspaces/{ws}/runs/{run-id}` | workspace-run-detail.md |
| View all runs | LATEST_RUN_CARD | `/workspaces/{ws}/runs` | workspace-runs.md |
| Resources tab | RESOURCES_PANEL | Shows resources list | - |
| Outputs tab | RESOURCES_PANEL | Shows outputs list | - |
| Learn about resources | RESOURCES_PANEL | External docs link | - |
| Execution mode link | SIDEBAR_DETAILS | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| Auto-apply link | SIDEBAR_DETAILS | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| Auto-destroy link | SIDEBAR_DETAILS | `/workspaces/{ws}/settings/delete` | workspace-settings.md |
| Project link | SIDEBAR_DETAILS | `/app/{org}/projects/{project-id}` | project-detail.md |
| Drift: View Details | HEALTH_SECTION | `/workspaces/{ws}/health/drift` | workspace-health.md |
| Checks: View Details | HEALTH_SECTION | `/workspaces/{ws}/health/continuous-validation` | workspace-health.md |
| Manage Tags button | TAGS_SECTION | Opens tag editor | - |
| Run triggers link | RUN_TRIGGERS | `/workspaces/{ws}/settings/run-triggers` | workspace-settings.md |
| Update settings link | RUN_TRIGGERS | `/workspaces/{ws}/settings/run-triggers` | workspace-settings.md |
| Contributors link | CONTRIBUTORS | `/workspaces/{ws}/settings/access` | workspace-settings.md |
| Contributor avatar | CONTRIBUTORS | Shows user details | - |
