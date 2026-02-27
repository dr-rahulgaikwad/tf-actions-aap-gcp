# Workspace Change Requests

**URL**: `/app/{org}/workspaces/{workspace}/change-requests`
**Title**: Change requests
**Purpose**: View and manage change requests for the workspace, including active requests and archived history

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Workspaces/{ws}/Change requests│
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE + METADATA_BAR + ACTIONS             │
│ Workspace │ (same as workspace-overview)                    │
│ Context   ├─────────────────────────────────────────────────┤
│           │ CHANGE_REQUESTS_HEADING: "Change requests"      │
│           │ TAB_BAR: [Change requests 10] [Archive 13]      │
│           ├─────────────────────────────────────────────────┤
│           │ CHANGE_REQUESTS_TABLE                           │
│           │ ┌──────────────────────────────────────────────┐│
│           │ │ Name        │ Message │ Created │ Actions   ││
│           │ ├──────────────────────────────────────────────┤│
│           │ │ CR by user  │ foo     │ Oct 14  │ [⋮]       ││
│           │ │ CR by user  │ dd      │ Oct 8   │ [⋮]       ││
│           │ │ ...         │         │         │           ││
│           │ └──────────────────────────────────────────────┘│
│           ├─────────────────────────────────────────────────┤
│           │ PAGINATION: 1-10 of 10 | Items per page [20▼]   │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Workspace navigation | Back link, workspace name, sub-pages | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Change requests | System managed |
| PAGE_TITLE | Workspace identity | Same header as overview with ID, metadata, actions | N/A |
| CHANGE_REQUESTS_HEADING | Section title | "Change requests" heading | N/A |
| TAB_BAR | Filter by status | Tabs: Change requests (active), Archive | New status categories |
| CHANGE_REQUESTS_TABLE | Request list | Table with name, message, created date, actions | New table columns |
| PAGINATION | Navigate pages | Count, page buttons, items per page selector | System managed |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Tab with Count | `Label count` | "Change requests 10", "Archive 13" | Filtering by category with counts |
| Change Request Row | Clickable name + message + date + overflow menu | Table row | Each change request entry |
| Overflow Menu | Icon button with dropdown | `[⋮]` button | Per-row actions |
| Change Request Name | Auto-generated or custom title | "Change request by tchaparro on Oct 14, 2025" | Request identification |
| Date Format | Month Day Year | "Oct 14 2025" | Created timestamp |
| Items Per Page | Dropdown selector | `[20▼]` with options 20, 50, 100 | Page size control |

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
| Search & Import | SIDEBAR | `/workspaces/{ws}/search` | workspace-search.md |
| Variables | SIDEBAR | `/workspaces/{ws}/variables` | workspace-variables.md |
| Change requests | SIDEBAR | `/workspaces/{ws}/change-requests` | workspace-change-requests.md |
| Health | SIDEBAR | `/workspaces/{ws}/health/drift` | workspace-health.md |
| Settings | SIDEBAR | `/workspaces/{ws}/settings` | workspace-settings.md |
| Tab: Change requests | TAB_BAR | Shows active change requests | - |
| Tab: Archive | TAB_BAR | Shows archived change requests | - |
| Change request name link | CHANGE_REQUESTS_TABLE | `/workspaces/{ws}/change-requests/{cr-id}` | - |
| Overflow Options | CHANGE_REQUESTS_TABLE | Opens action menu | - |
| Page number | PAGINATION | Changes page | - |
| Items per page | PAGINATION | Changes page size | - |
