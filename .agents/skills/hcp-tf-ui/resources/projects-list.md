# Projects List

**URL**: `/app/{org}/projects`
**Title**: Projects
**Purpose**: List and manage all projects in the organization

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Projects                    │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Global:   │ [icon] "Projects"                               │
│ ──────────│ Description text                                │
│ Manage    │ [New project] button                            │
│ • Projects├─────────────────────────────────────────────────┤
│ • Stacks  │ SEARCH: [Search by project name]                │
│ • Worksp  ├─────────────────────────────────────────────────┤
│ • Registry│ PROJECTS_TABLE                                  │
│ • Usage   │ ┌──────────────────────────────────────────────┐│
│ • Settings│ │ Project name↑│ Description│Teams│Workspaces│⋮││
│ ──────────│ ├──────────────────────────────────────────────┤│
│ Visibility│ │ ai-error-ex  │ Collect... │  1  │    4     │⋮││
│ • Explorer│ │ Default Proj │ No desc    │  1  │   148    │⋮││
│ ──────────│ │ ...          │            │     │          │ ││
│ Cloud Plat│ └──────────────────────────────────────────────┘│
│ • HCP     ├─────────────────────────────────────────────────┤
│           │ PAGINATION: 1-11 of 11 | Items per page [20▼]   │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Organization navigation | Grouped nav: Manage (Projects, Stacks, Workspaces, Registry, Usage, Settings), Visibility (Explorer), Cloud Platform (HCP) | New org-level nav items |
| BREADCRUMB | Current location | Org > Projects | System managed |
| PAGE_HEADER | Page identity | Icon, heading, description, New project button | N/A |
| SEARCH | Filter projects | Search box with auto-update | N/A |
| PROJECTS_TABLE | Project list | Sortable table with project details | New table columns |
| PAGINATION | Navigate pages | Count, page buttons, items per page selector | System managed |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Page Header with Icon | Large icon + heading + description + action button | Projects header | Page introduction |
| Sortable Column | Column header with sort button | "Project name ↑" | Table sorting |
| Project Row | Name link + description + team count link + workspace count link + overflow | Table row | Each project entry |
| Count Link | Number linking to filtered view | "4" linking to workspaces | Quick navigation to related items |
| Auto-destroy Badge | Info button next to project name | Clock icon button | Projects with auto-destroy enabled |
| Overflow Menu | Icon button with dropdown | `[⋮]` button | Per-row actions |
| Live Search | Search box with auto-update | "Search by project name" | Instant filtering |
| Nav Group | Header text + nav items | "Manage" section | Grouping related nav items |

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
| [New project] button | PAGE_HEADER | Opens new project modal | - |
| Sort button (Project name) | PROJECTS_TABLE | Toggles sort direction | - |
| Project name link | PROJECTS_TABLE | `/app/{org}/projects/{project}` | project-detail.md |
| auto-destroy info button | PROJECTS_TABLE | Shows auto-destroy tooltip | - |
| Teams count link | PROJECTS_TABLE | `/app/{org}/projects/{project}/access` | - |
| Workspaces count link | PROJECTS_TABLE | `/app/{org}/projects/{project}/workspaces` | - |
| Overflow options | PROJECTS_TABLE | Opens action menu | - |
| Page number | PAGINATION | Changes page | - |
| Items per page | PAGINATION | Changes page size | - |
