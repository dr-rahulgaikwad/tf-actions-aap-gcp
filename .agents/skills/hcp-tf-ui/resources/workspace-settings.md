# Workspace Settings

**URL**: `/app/{org}/workspaces/{workspace}/settings` (redirects to `/settings/general`)
**Title**: General Settings (varies by sub-page)
**Purpose**: Configure workspace behavior, access, integrations, and lifecycle options

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Workspaces/{ws}/Settings/General│
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE: "General Settings"                  │
│ Settings  │ ID: ws-{id} [copy]                              │
│ Context:  ├─────────────────────────────────────────────────┤
│ ──────────│ SETTINGS_FORM                                   │
│ • boop    │ ┌─────────────────────────────────────────────┐ │
│ Workspace │ │ Name: [text input]                          │ │
│ Settings  │ │ Project: [dropdown] (with warning banner)   │ │
│ ──────────│ │ Description: [text input] (optional)        │ │
│ • General*│ ├─────────────────────────────────────────────┤ │
│ • Health  │ │ EXECUTION_MODE: Radio group                 │ │
│ • Locking │ │   ○ Project Default (remote)                │ │
│ • Notific │ │   ○ Remote (custom)                         │ │
│ • Policies│ │   ○ Local (custom)                          │ │
│ • Run Task│ │   ○ Agent (custom) [disabled if no pools]   │ │
│ • Run Trig│ ├─────────────────────────────────────────────┤ │
│ • SSH Key │ │ AUTO_APPLY: Checkboxes                      │ │
│ • Team Acc│ │   □ Auto-apply API, UI, & VCS runs          │ │
│ • Version │ │   □ Auto-apply run triggers                 │ │
│ • Destruct│ ├─────────────────────────────────────────────┤ │
│           │ │ Terraform Version: [dropdown]               │ │
│           │ │ Terraform Working Directory: [text input]   │ │
│           │ ├─────────────────────────────────────────────┤ │
│           │ │ REMOTE_STATE_SHARING: Radio group           │ │
│           │ │   ○ Share with all workspaces               │ │
│           │ │   ○ Share with specific workspaces          │ │
│           │ │   [workspace selector if specific]          │ │
│           │ ├─────────────────────────────────────────────┤ │
│           │ │ USER_INTERFACE: Radio group                 │ │
│           │ │   ○ Structured Run Output                   │ │
│           │ │   ○ Console UI                              │ │
│           │ └─────────────────────────────────────────────┘ │
│           │ [Save settings]                                 │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Settings Sub-pages

| Sub-page | URL | Purpose |
|----------|-----|---------|
| General | `/settings/general` | Name, project, execution mode, auto-apply, version, state sharing |
| Health | `/settings/health` | Drift detection, continuous validation settings |
| Locking | `/settings/lock` | Workspace locking configuration |
| Notifications | `/settings/notifications` | Webhook and notification integrations |
| Policies | `/settings/policies` | Sentinel/OPA policy set attachments |
| Run Tasks | `/settings/tasks` | Pre/post plan and apply task integrations |
| Run Triggers | `/settings/run-triggers` | Source workspace trigger configuration |
| SSH Key | `/settings/ssh` | SSH key for private module access |
| Team Access | `/settings/access` | Team permissions and access levels |
| Version Control | `/settings/version-control` | VCS provider connection and settings |
| Destruction and Deletion | `/settings/delete` | Auto-destroy, queue destroy, delete workspace |

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Settings navigation | Back to workspace, settings categories | New settings categories |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Settings > Sub-page | System managed |
| PAGE_TITLE | Settings identity | Sub-page heading + workspace ID | N/A |
| SETTINGS_FORM | Configuration options | Form fields organized by section | New configuration options |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Settings Category | Sidebar nav item | "General", "Health", "Locking" | Navigation between settings pages |
| Form Section | Group heading + fields | "Execution Mode" radio group | Grouping related settings |
| Radio Group | Label + description + radio options | Execution Mode selector | Single-select options |
| Checkbox Group | Label + description + checkboxes | Auto-apply options | Multi-select options |
| Text Input | Label + optional badge + input field | "Name" field | Free-form text entry |
| Dropdown Select | Label + combobox | Terraform Version selector | Selection from predefined options |
| Warning Banner | Icon + title + message + link | Project change warning | Alerting users to side effects |
| Info Button | `[?]` button next to label | Auto-apply info buttons | Contextual help tooltips |
| Save Button | Primary action button | "Save settings" | Persisting form changes |
| Disabled Option | Grayed option with explanation | Agent mode when no pools | Unavailable features |
| Copyable ID | ID value + copy button | `ws-j2sAeWRxou1b5HYf` | Workspace identification |
| External Doc Link | Text with external icon | "version constraint [↗]" | Links to documentation |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Workspaces | BREADCRUMB | `/app/{org}/workspaces` | workspaces-list.md |
| Breadcrumb: {workspace} | BREADCRUMB | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Breadcrumb: Settings | BREADCRUMB | `/workspaces/{ws}/settings` | workspace-settings.md |
| boop (back to workspace) | SIDEBAR | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| General | SIDEBAR | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| Health | SIDEBAR | `/workspaces/{ws}/settings/health` | - |
| Locking | SIDEBAR | `/workspaces/{ws}/settings/lock` | - |
| Notifications | SIDEBAR | `/workspaces/{ws}/settings/notifications` | - |
| Policies | SIDEBAR | `/workspaces/{ws}/settings/policies` | - |
| Run Tasks | SIDEBAR | `/workspaces/{ws}/settings/tasks` | - |
| Run Triggers | SIDEBAR | `/workspaces/{ws}/settings/run-triggers` | - |
| SSH Key | SIDEBAR | `/workspaces/{ws}/settings/ssh` | - |
| Team Access | SIDEBAR | `/workspaces/{ws}/settings/access` | - |
| Version Control | SIDEBAR | `/workspaces/{ws}/settings/version-control` | - |
| Destruction and Deletion | SIDEBAR | `/workspaces/{ws}/settings/delete` | - |
| ID copy button | PAGE_TITLE | Copies workspace ID | - |
| project-level permissions | WARNING_BANNER | External: Project permissions docs | - |
| remote (project link) | EXECUTION_MODE | `/projects/{project}/settings` | - |
| Learn more about Terraform Agents | EXECUTION_MODE | External: Agents docs | - |
| auto-apply-info button | AUTO_APPLY | Opens tooltip | - |
| version constraint | TERRAFORM_VERSION | External: Version constraints docs | - |
| [Save settings] | SETTINGS_FORM | Saves form (no navigation) | - |
