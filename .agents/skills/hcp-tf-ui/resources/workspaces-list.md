# Workspaces List

**URL**: `/app/{org}/workspaces`
**Title**: Workspaces
**Purpose**: List and filter all workspaces in the organization

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Workspaces                  │
│           ├─────────────────────────────────────────────────┤
│ SIDEBAR   │ PAGE_TITLE + PRIMARY_ACTION: "Workspaces" [New] │
│           ├─────────────────────────────────────────────────┤
│ Manage:   │ STATUS_SUMMARY: 2 Attention | 20 Errored |      │
│ • Projects│                 0 Running | 0 On Hold | 68 OK   │
│ • Stacks  ├─────────────────────────────────────────────────┤
│ • Worksp* │ FILTERS: [Search] [Tags▼] [Status▼] [Health▼]   │
│ • Registry├─────────────────────────────────────────────────┤
│ • Usage   │ TABLE: Name | Run Status | Repo | Latest | ⚙    │
│ • Settings│        [rows...]                                │
│           ├─────────────────────────────────────────────────┤
│ Visibility│ PAGINATION: 1-20 of 169                         │
│ • Explorer│                                                 │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context & navigation | Logo, org switcher dropdown, help menu, user menu | Global actions, notifications |
| SIDEBAR | Organization-level navigation | Grouped nav items under "Manage" and "Visibility" headings | New nav items for org-level features |
| BREADCRUMB | Current location | Org name > Page name | System managed |
| PAGE_TITLE | Page identity + primary action | Heading with action button/dropdown | Secondary actions, bulk operations |
| STATUS_SUMMARY | Aggregate status counts | Clickable pills that filter the table below | New status categories |
| FILTERS | Narrow table results | Search box + dropdown filters | New filter dimensions |
| TABLE | Primary data display | Sortable columns, clickable rows, inline badges, row actions | New columns, new badge types |
| PAGINATION | Navigate large datasets | Count display + page links | System managed |
| FOOTER | Legal/support links | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Status Pill | `[icon] count` (clickable) | `⚠ 20` Errored | Aggregate counts that filter on click |
| Filter Dropdown | `[icon] Label [▼]` | `Tags ▼` | Multi-select filtering |
| Table Row | `Name + badges | Status | Repo | Time | Action` | Workspace row | Primary data with inline metadata |
| Badge | Small inline label with optional icon | `Auto-destroy`, `Health warning` | Workspace attributes/states |
| Row Action | Icon button with menu | `⚙` → "Edit workspace settings" | Per-row actions |
| Nav Item | `[icon] Label` | `Workspaces` | Sidebar navigation |
| Nav Group | Header text + nav items | "Manage" section | Grouping related nav items |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Help menu | HEADER | Help dropdown | - |
| User menu | HEADER | User settings dropdown | - |
| Projects | SIDEBAR | `/app/{org}/projects` | - |
| Stacks | SIDEBAR | `/app/{org}/stacks` | - |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Registry | SIDEBAR | `/app/{org}/registry` | - |
| Usage | SIDEBAR | `/app/{org}/usage` | - |
| Settings | SIDEBAR | `/app/{org}/settings` | - |
| Explorer | SIDEBAR | `/app/{org}/explorer` | - |
| [New ▼] button | PAGE_TITLE | Dropdown: New workspace, etc. | - |
| Needs Attention pill | STATUS_SUMMARY | `?filter=...` (filtered list) | workspaces-list.md |
| Errored pill | STATUS_SUMMARY | `?filter=errored` | workspaces-list.md |
| Running pill | STATUS_SUMMARY | `?filter=...` | workspaces-list.md |
| On Hold pill | STATUS_SUMMARY | `?filter=...` | workspaces-list.md |
| Success pill | STATUS_SUMMARY | `?filter=...` | workspaces-list.md |
| Column header (Name) | TABLE | `?sort=-name` (sort toggle) | workspaces-list.md |
| Column header (Latest) | TABLE | `?sort=-latest-change-at` | workspaces-list.md |
| Workspace name link | TABLE ROW | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Project badge link | TABLE ROW | `?project={id}` (filtered list) | workspaces-list.md |
| ⚙ row action | TABLE ROW | Opens workspace settings | workspace-settings.md |
| Page number | PAGINATION | `?page={n}` | workspaces-list.md |
