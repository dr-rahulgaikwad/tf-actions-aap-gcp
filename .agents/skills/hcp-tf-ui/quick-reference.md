# HCP Terraform UI Quick Reference

A condensed reference for fast URL-to-page lookups. For full details, see the individual page files.

## URL → Page Mapping

### Entry Point
| URL | Page | Purpose |
|-----|------|---------|
| `/app` or `/app/organizations` | Organizations List | Select organization to enter |

### Organization Level (`/app/{org}/...`)
| URL | Page | Purpose |
|-----|------|---------|
| `/workspaces` | Workspaces List | List/filter all workspaces |
| `/projects` | Projects List | List/manage projects |
| `/projects/{project}` | Project Detail | Project overview, recent activity |
| `/stacks` | Stacks List | List/manage stacks |
| `/explorer` | Explorer | Query data across org (modules, providers, workspaces) |
| `/usage` | Usage Report | Usage stats, subscription details |
| `/settings` | Org Settings | Org configuration (general, teams, policies, security) |
| `/registry` | Registry - Modules | Private/public module browser |
| `/registry/private/providers` | Registry - Providers | Private/public provider browser |
| `/registry/design` | Config Designer | Wizard to design workspace configs |
| `/registry/public-namespaces` | Public Namespaces | Manage GitHub namespace links |

### Workspace Level (`/app/{org}/workspaces/{ws}/...`)
| URL | Page | Purpose |
|-----|------|---------|
| (root) | Workspace Overview | Status, latest run, resources, config |
| `/runs` | Runs | Run history with filters |
| `/runs/{run}` | Run Detail | Plan, apply, cost, resource changes |
| `/states` | States | State version history |
| `/search` | Search & Import | Discover/import unmanaged resources |
| `/variables` | Variables | Terraform & environment variables |
| `/change-requests` | Change Requests | Manage change request workflows |
| `/health/drift` | Health - Drift | Drift detection status |
| `/health/continuous-validation` | Health - Validation | Automated checks |
| `/settings` | Workspace Settings | Config, access, integrations |

## Navigation Hierarchy

```
/app (Organizations)
└── /{org}
    ├── /workspaces ─────────────────┐
    │   └── /{ws}                    │
    │       ├── (overview)           │
    │       ├── /runs                │
    │       │   └── /{run}           │
    │       ├── /states              │
    │       ├── /search              │
    │       ├── /variables           │
    │       ├── /change-requests     │
    │       ├── /health              │
    │       │   ├── /drift           │
    │       │   └── /continuous-validation
    │       └── /settings            │
    ├── /projects                    │
    │   └── /{project}               │
    ├── /stacks                      │
    ├── /registry                    │
    │   ├── /private/modules         │
    │   ├── /private/providers       │
    │   ├── /design                  │
    │   └── /public-namespaces       │
    ├── /explorer                    │
    ├── /usage                       │
    └── /settings                    │
```

## Common UI Patterns

| Pattern | Where Used | Example |
|---------|-----------|---------|
| Status Pill | Workspaces list, Runs | `⚠ 20 Errored` - clickable filter |
| Tab with Count | Runs, Change Requests, Explorer | `All 57 | Errored 15` |
| Copyable ID | Workspace, Project, Org pages | `ws-abc123 [copy]` |
| Action Button | Most pages | `[New run]`, `[Lock]` |
| Overflow Menu | Tables | `[⋮]` per-row actions |
| Filter Accordion | Registry, Explorer | Provider checkboxes |
| Status Badge | Runs, Health | `✓ Applied`, `✗ Errored` |
| Breadcrumb | All pages | `{org} / Workspaces / {ws}` |

## Key Actions by Context

### From Workspaces List
- **New workspace**: `[New ▼]` dropdown in header
- **Filter by status**: Click status pills (Errored, Running, etc.)
- **Enter workspace**: Click workspace name

### From Workspace Overview
- **Start a run**: `[New run]` button
- **Lock workspace**: `[Lock]` button
- **View run details**: Click latest run card or "See details"

### From Organization
- **Create project**: Projects → `[New project]`
- **Enable stacks**: Stacks → Enable via org settings
- **Publish module**: Registry → `[Publish ▼]`

## Settings Quick Reference

### Org Settings Categories
- **Organization**: General, Plan & Billing, Tags, Teams, Users, Variable sets, Health, Runs
- **Integrations**: Cost estimation, Policies, Policy sets, Run tasks
- **Security**: API tokens, Agents, Auditing, Authentication, HYOK, SSH keys, SSO
- **Version Control**: General, Events, Providers

### Workspace Settings Categories
- General, Health, Locking, Notifications, Policies, Run Tasks, Run Triggers, SSH Key, Team Access, Version Control, Destruction and Deletion
