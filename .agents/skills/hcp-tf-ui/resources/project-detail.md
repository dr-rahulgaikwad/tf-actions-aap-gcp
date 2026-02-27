# Project Detail (Overview)

**URL**: `/app/{org}/projects/{project}`
**Title**: {Project Name}
**Purpose**: View project overview including recent workspaces, stacks, and project metadata

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Projects / {project}        │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PROJECT_HEADER                                  │
│ Project   │ [icon] "{Project Name}"                         │
│ Context:  │ ID: prj-{id} [copy]                             │
│ ──────────│ [Add project description] link                  │
│ • Projects│ Teams: [N] | Workspaces: [N] | Auto-destroy | Tags│
│ • {name}  │ [New ▼] button                                  │
│   ├ Overv*├─────────────────────────────────────────────────┤
│   ├ Worksp│ RECENT_WORKSPACES_SECTION                       │
│   ├ Stacks│ Heading: "Workspaces recently updated"          │
│   └ Settin│ [View all Workspaces →]                         │
│           │ TABLE: Workspace name│Repository│Health│Latest  │
│           │        [rows...]                                │
│           ├─────────────────────────────────────────────────┤
│           │ (Additional sections for Stacks if present)     │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Project Sub-pages

| Sub-page | URL | Purpose |
|----------|-----|---------|
| Overview | `/projects/{project}` | Project summary with recent activity |
| Workspaces | `/projects/{project}/workspaces` | All workspaces in project |
| Stacks | `/projects/{project}/stacks` | All stacks in project |
| Settings | `/projects/{project}/settings` | Project configuration |
| Access | `/projects/{project}/access` | Team permissions |
| Auto-destroy | `/projects/{project}/auto-destroy` | Auto-destroy settings |

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Project navigation | Back to Projects, project name, sub-pages with counts | New project sub-pages |
| BREADCRUMB | Current location | Org > Projects > Project | System managed |
| PROJECT_HEADER | Project identity | Icon, name, ID, description link, metadata stats, New button | New metadata items |
| RECENT_WORKSPACES_SECTION | Recent activity | Table of recently updated workspaces | New activity types |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Project Header with Icon | Large folder icon + heading + metadata | Project header | Page introduction |
| Copyable ID | `ID: {value} [copy]` | `prj-V6Q1LE8tsv4NvVZG` | Project identification |
| Metadata Link | `[icon] Label: Value` linking somewhere | "Teams: 1" linking to access | Quick stats with navigation |
| Auto-destroy Info | `[icon] Auto-destroy: If inactive for X days` | "If inactive for 14 days" | Auto-destroy status |
| New Dropdown | Button with dropdown menu | `[New ▼]` | Create workspace/stack |
| Section Heading with Link | Heading + "View all" link | "Workspaces recently updated [→]" | Section with drill-down |
| Workspace Row | Status icon + name + tags + status text + repo + health + time | Table row | Recent workspace entry |
| Run Status Button | Icon button showing run status | Status indicator button | Quick status with tooltip |
| Health Warning | Icon + "Warning" text | Health column indicator | Health status |
| Tags Button | Icon button for viewing tags | Tags indicator | Workspace tags |
| Nav Item with Count | `Label count` | "Workspaces 148" | Sidebar counts |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Projects | BREADCRUMB | `/app/{org}/projects` | projects-list.md |
| Projects (back) | SIDEBAR | `/app/{org}/projects` | projects-list.md |
| Overview | SIDEBAR | `/projects/{project}` | project-detail.md |
| Workspaces | SIDEBAR | `/projects/{project}/workspaces` | - |
| Stacks | SIDEBAR | `/projects/{project}/stacks` | - |
| Settings | SIDEBAR | `/projects/{project}/settings` | - |
| ID copy button | PROJECT_HEADER | Copies project ID | - |
| Add project description | PROJECT_HEADER | `/projects/{project}/settings` | - |
| Teams count link | PROJECT_HEADER | `/projects/{project}/access` | - |
| Workspaces count link | PROJECT_HEADER | `/projects/{project}/workspaces` | - |
| Auto-destroy link | PROJECT_HEADER | `/projects/{project}/auto-destroy` | - |
| Tags count button | PROJECT_HEADER | Opens tag management | - |
| [New ▼] button | PROJECT_HEADER | Dropdown: New workspace, New stack | - |
| View all Workspaces | RECENT_WORKSPACES_SECTION | `/projects/{project}/workspaces` | - |
| Run status button | RECENT_WORKSPACES_SECTION | Shows run status tooltip | - |
| Workspace name link | RECENT_WORKSPACES_SECTION | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| View tags button | RECENT_WORKSPACES_SECTION | Shows workspace tags | - |
| Health warning button | RECENT_WORKSPACES_SECTION | Shows health details | - |
