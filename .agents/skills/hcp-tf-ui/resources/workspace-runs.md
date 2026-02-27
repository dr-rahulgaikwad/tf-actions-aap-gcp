# Workspace Runs

**URL**: `/app/{org}/workspaces/{workspace}/runs`
**Title**: Runs
**Purpose**: View run history, filter by status, and access individual run details

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Workspaces / {ws} / Runs    │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE + METADATA_BAR + ACTIONS             │
│ Workspace │ (same as workspace-overview)                    │
│ Context:  ├─────────────────────────────────────────────────┤
│ ──────────│ CURRENT_RUN_CARD (if exists)                    │
│ • Worksp  │ Run trigger, ID, type, status, time             │
│ • boop    ├─────────────────────────────────────────────────┤
│   ├ Overv │ RUN_LIST_HEADER: "Run List"                     │
│   ├ Runs* ├─────────────────────────────────────────────────┤
│   ├ States│ TAB_BAR: All 57 | Needs Attention | Errored |   │
│   ├ Search│          Running | On Hold | Success            │
│   ├ Vars  ├─────────────────────────────────────────────────┤
│   ├ Change│ FILTERS: [Search] [Status▼] [Type▼] [Source▼]   │
│   ├ Health├─────────────────────────────────────────────────┤
│   └ Settin│ RUN_LIST: Run cards (trigger, ID, user, status) │
│           │   [Run 1]                                       │
│           │   [Run 2]                                       │
│           │   ...                                           │
│           ├─────────────────────────────────────────────────┤
│           │ PAGINATION: 1-20 of 57 | Items per page [20▼]   │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Workspace navigation | Back link, workspace name, sub-pages | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Runs | System managed |
| PAGE_TITLE | Workspace identity | Same header as overview with ID, metadata, actions | N/A |
| CURRENT_RUN_CARD | Highlight active run | Clickable card showing current/latest run details | N/A |
| RUN_LIST_HEADER | Section title | "Run List" heading | N/A |
| TAB_BAR | Filter by status category | Tabs with counts: All, Needs Attention, Errored, Running, On Hold, Success | New status categories |
| FILTERS | Narrow run list | Search box, Status dropdown, Type dropdown, Source dropdown | New filter dimensions |
| RUN_LIST | Run history | List of run cards with trigger info, ID, user, status, time | New run metadata |
| PAGINATION | Navigate pages | Count, page buttons, items per page selector | System managed |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Current Run Card | Large clickable card with icon, trigger, ID, type, status, time | "Triggered via infrastructure lifecycle" card | Highlighting active run |
| Run List Item | Clickable row: avatar/icon + trigger + ID + user + status + time | Run history entries | Each run in list |
| Status Tab | `Label count` with icon | `Errored 15` | Filtering by status |
| Filter Dropdown | `[icon] Label` button | `Status`, `Type`, `Source` | Multi-select filtering |
| Run ID | `#run-{id}` format | `#run-tNgtgLVkD9FKKQra` | Run identification |
| Trigger Badge | Text label | "Triggered via UI", "Triggered via CLI", "Triggered via infrastructure lifecycle" | Run source |
| User Avatar | Circular image with name | `tchaparro` avatar | Who triggered run |
| Status Badge | `[icon] Status` | `Applied`, `Errored`, `Discarded` | Run outcome |
| Items Per Page | Dropdown selector | `[20▼]` with options 5, 10, 20, 30 | Page size control |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Workspaces | BREADCRUMB | `/app/{org}/workspaces` | workspaces-list.md |
| Breadcrumb: {workspace} | BREADCRUMB | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Workspaces (back) | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Overview | SIDEBAR | `/workspaces/{ws}` | workspace-overview.md |
| Runs | SIDEBAR | `/workspaces/{ws}/runs` | workspace-runs.md |
| States | SIDEBAR | `/workspaces/{ws}/states` | workspace-states.md |
| Search & Import | SIDEBAR | `/workspaces/{ws}/search` | - |
| Variables | SIDEBAR | `/workspaces/{ws}/variables` | workspace-variables.md |
| Change requests | SIDEBAR | `/workspaces/{ws}/change-requests` | - |
| Health | SIDEBAR | `/workspaces/{ws}/health/drift` | workspace-health.md |
| Settings | SIDEBAR | `/workspaces/{ws}/settings` | workspace-settings.md |
| Current Run card | CURRENT_RUN_CARD | `/workspaces/{ws}/runs/{run-id}` | workspace-run-detail.md |
| Tab: All | TAB_BAR | Filters list to all runs | - |
| Tab: Needs Attention | TAB_BAR | Filters list to needs attention | - |
| Tab: Errored | TAB_BAR | Filters list to errored | - |
| Tab: Running | TAB_BAR | Filters list to running | - |
| Tab: On Hold | TAB_BAR | Filters list to on hold | - |
| Tab: Success | TAB_BAR | Filters list to success | - |
| Run list item | RUN_LIST | `/workspaces/{ws}/runs/{run-id}` | workspace-run-detail.md |
| Page number | PAGINATION | Changes page | - |
| Items per page | PAGINATION | Changes page size | - |
