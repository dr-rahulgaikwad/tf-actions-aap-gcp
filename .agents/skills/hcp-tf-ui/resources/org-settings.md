# Organization Settings

**URL**: `/app/{org}/settings` (redirects to `/app/{org}/settings/profile`)
**Title**: General | {Org Name}
**Purpose**: Configure organization-wide settings including general options, integrations, security, and version control

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Settings / General          │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Back:     │ "General Settings"                              │
│ • Worksp  ├─────────────────────────────────────────────────┤
│ ──────────│ SETTINGS_FORM                                   │
│ Org Sett: │ ┌─────────────────────────────────────────────┐ │
│ • General*│ │ ID: org-{id} [copy]                         │ │
│ • Plan &  │ │ Name: [text input]                          │ │
│   Billing │ │ Notification Email: [text input]            │ │
│ • Tags    │ │                                             │ │
│ • Teams   │ │ [✓] Workspace admins can force delete       │ │
│ • Users   │ │ [✓] Tests can be generated for modules BETA │ │
│ • Var sets│ │ [✓] Stacks                                  │ │
│ • Health  │ │ [✓] Show Terraform pre-releases             │ │
│ • Runs    │ │                                             │ │
│ ──────────│ │ Default Execution Mode:                     │ │
│ Integrat: │ │ (●) Remote  ( ) Local  ( ) Agent            │ │
│ • Cost est│ │                                             │ │
│ • Policies│ │ [Update organization]                       │ │
│ • Policy  │ └─────────────────────────────────────────────┘ │
│   sets    ├─────────────────────────────────────────────────┤
│ • Run     │ DESTRUCTION_SECTION                             │
│   tasks   │ "Destruction and Deletion"                      │
│ ──────────│ "Delete this Organization"                      │
│ Security: │ Warning text + [Delete this organization]       │
│ • API toks│                                                 │
│ • Agents  │                                                 │
│ • Auditing│                                                 │
│ • Auth    │                                                 │
│ • HYOK    │                                                 │
│ • SSH keys│                                                 │
│ • SSO     │                                                 │
│ ──────────│                                                 │
│ Version   │                                                 │
│ Control:  │                                                 │
│ • General │                                                 │
│ • Events  │                                                 │
│ • Provider│                                                 │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Settings Sub-pages

| Sub-page | URL | Category | Purpose |
|----------|-----|----------|---------|
| General | `/settings/profile` | Organization Settings | Org name, email, feature toggles, execution mode |
| Plan & Billing | `/settings/billing` | Organization Settings | Subscription and payment management |
| Tags | `/settings/tags` | Organization Settings | Organization-wide tag management |
| Teams | `/settings/teams` | Organization Settings | Team management and permissions |
| Users | `/settings/users` | Organization Settings | User management |
| Variable sets | `/settings/varsets` | Organization Settings | Shared variable set management |
| Health | `/settings/assessments` | Organization Settings | Health assessment configuration |
| Runs | `/settings/runs` | Organization Settings | Run configuration defaults |
| Cost estimation | `/settings/cost-estimation` | Integrations | Cloud cost estimation settings |
| Policies | `/settings/policies` | Integrations | Sentinel/OPA policy management |
| Policy sets | `/settings/policy-sets` | Integrations | Policy set configuration |
| Run tasks | `/settings/tasks` | Integrations | Pre/post-plan task integrations |
| API tokens | `/settings/authentication-tokens` | Security | Organization API token management |
| Agents | `/settings/agents` | Security | Self-hosted agent pool management |
| Auditing | `/settings/auditing` | Security | Audit log configuration |
| Authentication | `/settings/authentication` | Security | Authentication settings |
| HYOK encryption | `/settings/hyok-encryption` | Security | Hold Your Own Key encryption |
| SSH keys | `/settings/manage-ssh-keys` | Security | SSH key management for VCS |
| SSO | `/settings/sso` | Security | Single sign-on configuration |
| VCS General | `/settings/vcs-general` | Version Control | General VCS settings |
| VCS Events | `/settings/vcs-events` | Version Control | VCS event configuration |
| VCS Providers | `/settings/version-control` | Version Control | VCS provider connections |

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Settings navigation | Back to Workspaces, grouped settings: Org Settings, Integrations, Security, Version Control | New settings sub-pages |
| BREADCRUMB | Current location | Org > Settings > Current page | System managed |
| PAGE_HEADER | Page identity | Heading for current settings page | N/A |
| SETTINGS_FORM | Configuration | Form fields specific to settings page | New form fields |
| DESTRUCTION_SECTION | Dangerous actions | Delete organization option | N/A |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Copyable ID | `ID: {value} [copy]` | `org-vN4Q8wUJw88tm9V8` | Organization identification |
| Text Input Field | Label + text input | Name, Notification Email | Editable text values |
| Feature Toggle | Checkbox + label + description | "Stacks" toggle | Enable/disable features |
| Beta Badge | Label with "BETA" indicator | "Tests can be generated BETA" | Beta feature indication |
| Radio Group | Group label + radio options + descriptions | Default Execution Mode | Mutually exclusive options |
| Execution Mode Option | Radio + label + description | Remote/Local/Agent | Execution mode selection |
| Info Callout | Icon + message + optional link | Stacks execution note | Contextual information |
| Section Heading | Heading level 2 | "Destruction and Deletion" | Group related settings |
| Danger Zone | Heading + warning + destructive button | Delete organization | Irreversible actions |
| Destructive Button | Red button with warning context | "Delete this organization" | Permanent deletion |
| Settings Nav Group | Group header + nav items | "Organization Settings" | Grouping related pages |
| External Link | Link with external icon | Documentation links | External resources |
| Form Submit Button | Primary button | "Update organization" | Save form changes |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Settings | BREADCRUMB | `/app/{org}/settings` | org-settings.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| General | SIDEBAR | `/app/{org}/settings/profile` | org-settings.md |
| Plan & Billing | SIDEBAR | `/app/{org}/settings/billing` | - |
| Tags | SIDEBAR | `/app/{org}/settings/tags` | - |
| Teams | SIDEBAR | `/app/{org}/settings/teams` | - |
| Users | SIDEBAR | `/app/{org}/settings/users` | - |
| Variable sets | SIDEBAR | `/app/{org}/settings/varsets` | - |
| Health | SIDEBAR | `/app/{org}/settings/assessments` | - |
| Runs | SIDEBAR | `/app/{org}/settings/runs` | - |
| Cost estimation | SIDEBAR | `/app/{org}/settings/cost-estimation` | - |
| Policies | SIDEBAR | `/app/{org}/settings/policies` | - |
| Policy sets | SIDEBAR | `/app/{org}/settings/policy-sets` | - |
| Run tasks | SIDEBAR | `/app/{org}/settings/tasks` | - |
| API tokens | SIDEBAR | `/app/{org}/settings/authentication-tokens` | - |
| Agents | SIDEBAR | `/app/{org}/settings/agents` | - |
| Auditing | SIDEBAR | `/app/{org}/settings/auditing` | - |
| Authentication | SIDEBAR | `/app/{org}/settings/authentication` | - |
| HYOK encryption | SIDEBAR | `/app/{org}/settings/hyok-encryption` | - |
| SSH keys | SIDEBAR | `/app/{org}/settings/manage-ssh-keys` | - |
| SSO | SIDEBAR | `/app/{org}/settings/sso` | - |
| VCS General | SIDEBAR | `/app/{org}/settings/vcs-general` | - |
| VCS Events | SIDEBAR | `/app/{org}/settings/vcs-events` | - |
| VCS Providers | SIDEBAR | `/app/{org}/settings/version-control` | - |
| ID copy button | SETTINGS_FORM | Copies organization ID | - |
| Learn more link | SETTINGS_FORM | External: Terraform docs | - |
| Stack config docs | SETTINGS_FORM | External: Stack configuration | - |
| [Update organization] | SETTINGS_FORM | Saves form (stays on page) | - |
| [Delete this organization] | DESTRUCTION_SECTION | Opens delete confirmation | - |

## General Settings Form Fields

| Field | Type | Description |
|-------|------|-------------|
| ID | Display + copy | Organization unique identifier |
| Name | Text input | Organization display name |
| Notification Email | Text input | Email for organization notifications |
| Workspace admin force delete | Checkbox | Allow workspace admins to force delete |
| Tests for private modules | Checkbox (BETA) | Enable test generation for modules |
| Stacks | Checkbox | Enable Stacks feature |
| Show Terraform pre-releases | Checkbox | Show alpha/beta/RC versions |
| Default Execution Mode | Radio group | Remote, Local, or Agent |
