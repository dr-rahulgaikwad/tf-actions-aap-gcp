# Workspace Variables

**URL**: `/app/{org}/workspaces/{workspace}/variables`
**Title**: Variables
**Purpose**: Manage Terraform and environment variables for the workspace, including variable sets

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Workspaces / {ws} / Variables│
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE + METADATA_BAR + ACTIONS             │
│ Workspace │ (same as workspace-overview)                    │
│ Context:  ├─────────────────────────────────────────────────┤
│ ──────────│ VARIABLES_HEADING: "Variables"                  │
│ • Worksp  │ VARIABLES_INFO: Explanation text with doc links │
│ • boop    │   - Terraform variables link                    │
│   ├ Overv │   - Environment variables link                  │
│   ├ Runs  │ SENSITIVE_INFO: Sensitive variables explanation │
│   ├ States├─────────────────────────────────────────────────┤
│   ├ Search│ WORKSPACE_VARS_SECTION                          │
│   ├ Vars* │ Heading: "Workspace variables (count)"          │
│   ├ Change│ Precedence info link                            │
│   ├ Health│ TABLE: Key | Value | Category | Actions         │
│   └ Settin│        [row...]                                 │
│           │ [Add variable] [Quick setup AWS...]             │
│           ├─────────────────────────────────────────────────┤
│           │ VARIABLE_SETS_SECTION                           │
│           │ Heading: "Variable sets (count)"                │
│           │ Variable sets explanation                       │
│           │ Empty state or applied sets list                │
│           │ [Apply variable set] [Learn about...]           │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Workspace navigation | Back link, workspace name, sub-pages | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Variables | System managed |
| PAGE_TITLE | Workspace identity | Same header as overview with ID, metadata, actions | N/A |
| VARIABLES_HEADING | Page title | "Variables" heading | N/A |
| VARIABLES_INFO | Context help | Explanation of Terraform and environment variables with links | New variable type documentation |
| SENSITIVE_INFO | Security guidance | Explanation of sensitive variable behavior | N/A |
| WORKSPACE_VARS_SECTION | Local variables | Table of workspace-scoped variables with precedence info | New variable attributes |
| VARIABLE_SETS_SECTION | Shared variables | Applied variable sets or empty state | New variable set features |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Variable Table | Columns: Key, Value, Category, Actions | Workspace variables table | Displaying variables |
| Variable Row | Key + Value + Category badge + Edit button | `input | food | terraform | [Edit]` | Each variable entry |
| External Doc Link | `text [icon]` linking to HashiCorp docs | "Terraform [↗]", "Environment [↗]" | Documentation references |
| Section Heading with Count | `Label (count)` | "Workspace variables (1)" | Section with item count |
| Code Inline | Monospace text | `*.auto.tfvars` | Code references |
| Empty State | Message + action buttons | "No variable sets have been applied..." | When no items exist |
| Quick Setup Link | `[icon] Label` | "Quick setup AWS dynamic credentials" | Shortcut to common configurations |
| Action Button | `[icon] Label` | "Add variable" | Primary actions |
| Edit Button | Icon-only button | Pencil icon | Row-level edit action |

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
| Terraform (doc link) | VARIABLES_INFO | External: Terraform variables docs | - |
| Environment (doc link) | VARIABLES_INFO | External: Environment variables docs | - |
| Sensitive (doc link) | SENSITIVE_INFO | External: Sensitive variables docs | - |
| precedence (doc link) | WORKSPACE_VARS_SECTION | External: Variable precedence docs | - |
| Variable key | WORKSPACE_VARS_SECTION | Expands variable details | - |
| Edit variable button | WORKSPACE_VARS_SECTION | Opens variable edit modal | - |
| [Add variable] button | WORKSPACE_VARS_SECTION | Opens add variable modal | - |
| Quick setup AWS dynamic credentials | WORKSPACE_VARS_SECTION | `/workspaces/{ws}/variables/dynamic-provider-credential/new` | - |
| Variable sets (doc link) | VARIABLE_SETS_SECTION | External: Variable sets docs | - |
| [Apply variable set] button | VARIABLE_SETS_SECTION | Opens variable set selector | - |
| Learn about variable sets | VARIABLE_SETS_SECTION | External: Variable sets docs | - |
