# Workspace Run Detail

**URL**: `/app/{org}/workspaces/{workspace}/runs/{run-id}`
**Title**: {run-id} | Runs
**Purpose**: View detailed information about a specific Terraform run including plan, cost estimation, apply phases, and resource changes

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Workspaces/{ws}/Runs/{run-id} │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE + METADATA_BAR + ACTIONS             │
│ Workspace │ (same as workspace-overview)                    │
│ Context   ├─────────────────────────────────────────────────┤
│           │ RUN_HEADER                                      │
│           │ ┌─────────────────────────────────────────────┐ │
│           │ │ Heading: "Triggered via {source}"           │ │
│           │ │ [CURRENT badge] [Status badge: Applied]     │ │
│           │ └─────────────────────────────────────────────┘ │
│           │ RUN_SUMMARY_STATS                               │
│           │ │ Est cost │ Duration │ Resources │ Actions │  │
│           │ │ change   │          │ changed   │         │  │
│           │ RUN_DETAILS_SECTION (expandable)                │
│           │ │ Time | Who triggered | Run type             │ │
│           ├─────────────────────────────────────────────────┤
│           │ PLAN_SECTION (expandable)                       │
│           │ │ Status: Plan finished | Time                 │ │
│           │ │ Resources: X to add, Y to change, Z to destroy│
│           │ │ Actions: N to invoke                         │ │
│           │ │ ┌─────────────────────────────────────────┐  │ │
│           │ │ │ Timeline: Started > Finished             │  │ │
│           │ │ │ Resource filter | Operation filter       │  │ │
│           │ │ │ Terraform version | Download raw log     │  │ │
│           │ │ │ RESOURCE_LIST: Expandable tree view      │  │ │
│           │ │ │ Sentinel mocks download                  │  │ │
│           │ │ └─────────────────────────────────────────┘  │ │
│           ├─────────────────────────────────────────────────┤
│           │ COST_ESTIMATION_SECTION                         │
│           │ │ X of Y estimated · $Z/month · +/-$           │ │
│           ├─────────────────────────────────────────────────┤
│           │ APPLY_SECTION (expandable)                      │
│           │ │ Resources: X added, Y changed, Z destroyed   │ │
│           │ │ Actions: N invoked                           │ │
│           ├─────────────────────────────────────────────────┤
│           │ COMMENT_SECTION                                 │
│           │ │ [Add comment] button                         │ │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Workspace navigation | Back link, workspace name, sub-pages | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Runs > Run ID | System managed |
| PAGE_TITLE | Workspace identity | Same header as overview with ID, metadata, actions | N/A |
| RUN_HEADER | Run identity | Trigger source heading, current badge, status badge | N/A |
| RUN_SUMMARY_STATS | Quick metrics | Cost change, duration, resources changed, actions | New summary metrics |
| RUN_DETAILS_SECTION | Run metadata | Timestamp, who triggered, run type, source | New run metadata fields |
| PLAN_SECTION | Plan phase details | Resource counts, timeline, resource tree, filters, logs | New plan outputs |
| COST_ESTIMATION_SECTION | Cost impact | Estimated vs actual, monthly cost, delta | New cost metrics |
| APPLY_SECTION | Apply phase details | Resource counts, actions invoked, timeline | New apply outputs |
| COMMENT_SECTION | Feedback | Comments list, add comment button | N/A |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Run Status Badge | `[icon] Status` | `✓ Applied`, `✗ Errored` | Run outcome status |
| Current Badge | Highlighted pill | `CURRENT` | Marking the current/active run |
| Summary Stat Card | Label + Value | "Resources changed: +0 ~0 -3" | Quick metrics display |
| Expandable Section | Header button + collapsible content | Plan section, Apply section | Phase details |
| Resource Count | `X to add, Y to change, Z to destroy` | "0 to add, 0 to change, 3 to destroy" | Resource change summary |
| Resource Tree | Provider icon + Address + Copy button | `random` → `module.hello.random_pet.server` | Listing affected resources |
| Timeline | `Started > Finished` with timestamps | "Started 2 months ago > Finished 2 months ago" | Phase duration |
| Download Link | `[icon] Label` | "Download raw log", "Download Sentinel mocks" | Artifact downloads |
| Filter Input | Text field + dropdown | Resource address filter + Operation filter | Narrowing resource list |
| Trigger Info | `{who} triggered a {type} run from {source}` | "API Integration triggered a destroy run" | Run origin details |
| Cost Summary | `X of Y estimated · $Z/month · +/-$` | "0 of 0 estimated · $0.00/month · +$0.00" | Cost estimation results |
| Comment Block | Label + description + action button | "Leave feedback or record a decision" | User comments |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Workspaces | BREADCRUMB | `/app/{org}/workspaces` | workspaces-list.md |
| Breadcrumb: {workspace} | BREADCRUMB | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Breadcrumb: Runs | BREADCRUMB | `/app/{org}/workspaces/{ws}/runs` | workspace-runs.md |
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
| Resources changed button | RUN_SUMMARY_STATS | Expands resource details | - |
| Run Details header | RUN_DETAILS_SECTION | Expands/collapses section | - |
| Plan header | PLAN_SECTION | Expands/collapses section | - |
| Filter by operation | PLAN_SECTION | Opens operation filter dropdown | - |
| Download raw log | PLAN_SECTION | Downloads plan log file | - |
| Resource address (copy) | PLAN_SECTION | Copies resource address | - |
| Resource row | PLAN_SECTION | Expands resource details | - |
| Download Sentinel mocks | PLAN_SECTION | Downloads mock data | - |
| testing your Sentinel policies | PLAN_SECTION | External: Sentinel testing docs | - |
| Cost estimation header | COST_ESTIMATION_SECTION | Expands/collapses section | - |
| Apply header | APPLY_SECTION | Expands/collapses section | - |
| [Add comment] button | COMMENT_SECTION | Opens comment editor | - |
