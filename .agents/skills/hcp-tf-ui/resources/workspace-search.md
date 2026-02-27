# Workspace Search & Import

**URL**: `/app/{org}/workspaces/{workspace}/search`
**Title**: Search & Import
**Purpose**: Run Terraform queries to discover and import unmanaged cloud resources

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Workspaces/{ws}/Search & Import│
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE: "Search & Import"                   │
│ Workspace │ ID: ws-{id} [copy] | Terraform version | Updated│
│ Context   │ [New query] button (may be disabled)            │
│           ├─────────────────────────────────────────────────┤
│           │ VERSION_ALERT (if TF version < 1.14.0)          │
│           │ ┌─────────────────────────────────────────────┐ │
│           │ │ ⚠ Unsupported workspace Terraform Version   │ │
│           │ │   To run Terraform queries...               │ │
│           │ │   [Upgrade your workspace]                  │ │
│           │ └─────────────────────────────────────────────┘ │
│           ├─────────────────────────────────────────────────┤
│           │ CONFIGURATION_SECTION                           │
│           │ ┌─────────────────────────────────────────────┐ │
│           │ │ ✓ Configuration uploaded successfully       │ │
│           │ │   (or instructions for uploading)           │ │
│           │ │                                             │ │
│           │ │ CLI-driven runs                             │ │
│           │ │ 1. Run `terraform login`                    │ │
│           │ │ 2. Add cloud block to config                │ │
│           │ │    [Example code block with Copy]           │ │
│           │ │ 3. Run `terraform init`                     │ │
│           │ │ 4. Run `terraform query`                    │ │
│           │ │                                             │ │
│           │ │ API-driven runs                             │ │
│           │ │ [Guide link]                                │ │
│           │ └─────────────────────────────────────────────┘ │
│           │ (or QUERY_RESULTS when queries have been run)  │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Workspace navigation | Back link, workspace name, sub-pages | New workspace sub-pages |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Search & Import | System managed |
| PAGE_TITLE | Page identity | Heading, workspace ID, Terraform version, New query button | N/A |
| VERSION_ALERT | Compatibility warning | Alert if Terraform version doesn't support queries | N/A |
| CONFIGURATION_SECTION | Setup instructions | CLI and API workflow steps, code examples | New setup workflows |
| QUERY_RESULTS | Search results | Discovered resources list (when queries exist) | New resource types |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Action Button | `[icon] Label`, can be disabled | "New query" | Primary page action |
| Version Alert | Warning dialog + upgrade link | "Unsupported workspace Terraform Version" | Compatibility warnings |
| Code Block | Syntax highlighted with copy button | terraform cloud config | Configuration examples |
| Numbered Steps | Ordered list with code snippets | CLI workflow steps | Setup instructions |
| External Doc Link | Text with external icon | "CLI workflow guide [↗]" | Documentation references |
| Status Heading | Icon + status text | "✓ Configuration uploaded successfully" | State indicators |
| Inline Code | Monospace text | `terraform login`, `terraform init` | Commands and code references |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Workspaces | BREADCRUMB | `/app/{org}/workspaces` | workspaces-list.md |
| Breadcrumb: {workspace} | BREADCRUMB | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| ID copy button | PAGE_TITLE | Copies workspace ID | - |
| Terraform version link | PAGE_TITLE | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| [New query] button | PAGE_TITLE | Starts new query (no navigation) | - |
| Workspaces (back) | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Overview | SIDEBAR | `/workspaces/{ws}` | workspace-overview.md |
| Runs | SIDEBAR | `/workspaces/{ws}/runs` | workspace-runs.md |
| States | SIDEBAR | `/workspaces/{ws}/states` | workspace-states.md |
| Search & Import | SIDEBAR | `/workspaces/{ws}/search` | workspace-search.md |
| Variables | SIDEBAR | `/workspaces/{ws}/variables` | workspace-variables.md |
| Change requests | SIDEBAR | `/workspaces/{ws}/change-requests` | workspace-change-requests.md |
| Health | SIDEBAR | `/workspaces/{ws}/health/drift` | workspace-health.md |
| Settings | SIDEBAR | `/workspaces/{ws}/settings` | workspace-settings.md |
| Upgrade your workspace | VERSION_ALERT | `/workspaces/{ws}/settings/general` | workspace-settings.md |
| credentials block | CONFIGURATION_SECTION | External: Terraform credentials docs | - |
| [Copy] code button | CONFIGURATION_SECTION | Copies code to clipboard | - |
| CLI workflow guide | CONFIGURATION_SECTION | External: CLI workflow docs | - |
| this guide (API) | CONFIGURATION_SECTION | External: API workflow docs | - |
