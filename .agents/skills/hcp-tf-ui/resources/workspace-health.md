# Workspace Health

**URL**: `/app/{org}/workspaces/{workspace}/health/drift` (default sub-page)
**Title**: Drift (or Continuous Validation)
**Purpose**: Monitor workspace drift detection and continuous validation status

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Workspaces/{ws}/Health/Drift  │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE: "Drift"                             │
│ Health    │ Subtitle: status message                        │
│ Context:  │ STATUS_BADGE + ACTION_BUTTON                    │
│ ──────────├─────────────────────────────────────────────────┤
│ • boop    │ PREREQUISITES_ALERT (if not met)                │
│ Health    │ ┌─────────────────────────────────────────────┐ │
│ ──────────│ │ ⚠ This workspace does not meet health      │ │
│ • Drift*  │ │   assessment prerequisites.                 │ │
│ • Contin  │ │   Resolve the following:                    │ │
│   Validat │ │   • Trigger and apply a successful run      │ │
│           │ │   [Documentation link]                      │ │
│           │ └─────────────────────────────────────────────┘ │
│           ├─────────────────────────────────────────────────┤
│           │ DRIFT_STATUS_SECTION                            │
│           │ ┌─────────────────────────────────────────────┐ │
│           │ │ "No drift detected"                         │ │
│           │ │ Your resource settings match those in       │ │
│           │ │ Terraform configuration.                    │ │
│           │ │ [Health assessments documentation]          │ │
│           │ └─────────────────────────────────────────────┘ │
│           │ (or DRIFT_RESULTS if drift is detected)        │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Health Sub-pages

| Sub-page | URL | Purpose |
|----------|-----|---------|
| Drift | `/health/drift` | Detect configuration drift between state and real infrastructure |
| Continuous Validation | `/health/continuous-validation` | Run automated checks against infrastructure |

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Health navigation | Back to workspace, health sub-pages | New health assessment types |
| BREADCRUMB | Current location | Org > Workspaces > Workspace > Health > Sub-page | System managed |
| PAGE_TITLE | Health page identity | Sub-page heading, status subtitle, status badge, action button | N/A |
| PREREQUISITES_ALERT | Requirement warning | Alert explaining what's needed before health can run | N/A |
| DRIFT_STATUS_SECTION | Drift detection results | No drift message, drift details, or drift list | New drift categories |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Health Status Badge | `[icon] Status` | `Not Ready`, `Healthy`, `Unhealthy` | Current health state |
| Action Button | Primary button, can be disabled | "Start health assessment" | Triggering health check |
| Prerequisites Alert | Warning dialog with bullet list + doc link | Requirements checklist | Explaining blockers |
| Status Message | Large heading + description + doc link | "No drift detected" | Health result summary |
| Health Category Nav | Sidebar nav item | "Drift", "Continuous Validation" | Sub-page navigation |
| External Doc Link | Text with external icon | "Health assessments documentation [↗]" | Documentation references |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Workspaces | BREADCRUMB | `/app/{org}/workspaces` | workspaces-list.md |
| Breadcrumb: {workspace} | BREADCRUMB | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Breadcrumb: Health | BREADCRUMB | `/workspaces/{ws}/health` | workspace-health.md |
| boop (back to workspace) | SIDEBAR | `/app/{org}/workspaces/{ws}` | workspace-overview.md |
| Drift | SIDEBAR | `/workspaces/{ws}/health/drift` | workspace-health.md |
| Continuous Validation | SIDEBAR | `/workspaces/{ws}/health/continuous-validation` | workspace-health.md |
| [Start health assessment] | PAGE_TITLE | Triggers health check (no navigation) | - |
| Documentation: Health assessment prerequisites | PREREQUISITES_ALERT | External: Health prerequisites docs | - |
| Health assessments documentation | DRIFT_STATUS_SECTION | External: Health docs | - |
