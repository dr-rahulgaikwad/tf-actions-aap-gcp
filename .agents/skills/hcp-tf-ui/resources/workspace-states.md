# Workspace States

**URL**: `/app/{org}/workspaces/{workspace}/states`
**Title**: States
**Purpose**: View state version history for the workspace, showing each state snapshot with its source run

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Workspaces / {ws} / States  │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE + METADATA_BAR + ACTIONS             │
│ Workspace │ (same as workspace-overview)                    │
│ Context:  ├─────────────────────────────────────────────────┤
│ ──────────│ STATE_LIST                                      │
│ • Worksp  │ [State Version 1]                               │
│ • boop    │   Icon | Trigger | ID | User | Time | Run Link  │
│   ├ Overv │ [State Version 2]                               │
│   ├ Runs  │   Icon | Trigger | ID | User | Time | Run Link  │
│   ├ State*│ [State Version 3]                               │
│   ├ Search│   ...                                           │
│   ├ Vars  │                                                 │
│   ├ Change│                                                 │
│   ├ Health│                                                 │
│   └ Settin│                                                 │
│           ├─────────────────────────────────────────────────┤
│           │ PAGINATION                                      │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Workspace navigation | Back link, workspace name, sub-pages | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > States | System managed |
| PAGE_TITLE | Workspace identity | Same header as overview with ID, metadata, actions | N/A |
| STATE_LIST | State version history | Chronological list of state versions with metadata | New state metadata fields |
| PAGINATION | Navigate pages | Page navigation controls | System managed |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| State Version Row | Avatar/icon + Trigger link + ID + User + Time + Run link | State list entry | Each state version |
| Trigger Link | Bold clickable trigger source | "Triggered via infrastructure lifecycle" | Navigates to state detail |
| State ID | `#sv-{id}` format | `#sv-qENRi3FwyATo69ax` | State identification |
| Run Link | `#run-{id}` format | `#run-tNgtgLVkD9FKKQra` | Links to source run |
| User Avatar | Circular image with name | `tchaparro` avatar | Who triggered the state |
| Trigger Source Badge | Text indicating source | "triggered from Terraform" | How state was created |
| Relative Time | Human-readable time | "2 months ago", "a year ago" | When state was created |
| Infrastructure Lifecycle Icon | Gears/cog icon | API-triggered states | System-triggered states |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
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
| Trigger link (in row) | STATE_LIST | `/workspaces/{ws}/states/{state-id}` | workspace-state-detail.md |
| Run link (in row) | STATE_LIST | `/workspaces/{ws}/runs/{run-id}` | workspace-run-detail.md |
| Page number | PAGINATION | Changes page | - |
