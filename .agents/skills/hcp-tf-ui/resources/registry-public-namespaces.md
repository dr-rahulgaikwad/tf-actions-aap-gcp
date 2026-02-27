# Registry - Public Namespaces

**URL**: `/app/{org}/registry/public-namespaces`
**Title**: Public Namespaces | Registry | {Org Name}
**Purpose**: Manage public registry namespaces linked to GitHub accounts for publishing modules and providers

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Registry / Public Namespaces│
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Back:     │ "Namespaces"                                    │
│ • Worksp  │ [New Namespace] button                          │
│ ──────────├─────────────────────────────────────────────────┤
│ Registry: │ ─────────────────────────────────────────────── │
│ • Private │ CLAIM_INFO                                      │
│   Library │ [i] Claim an existing namespace?                │
│ • Public  │ Choose the New Namespace button and select      │
│   Namespc*│ your Github account. [Learn more about claiming]│
│           ├─────────────────────────────────────────────────┤
│           │ EMPTY_STATE (when no namespaces)                │
│           │ "Create your first namespace"                   │
│           │ Namespaces in HCP Terraform manage public       │
│           │ Registry content from a linked Github account.  │
│           │ [Learn more]                                    │
│           │ [New Namespace] button                          │
│           │                                                 │
│           │ OR                                              │
│           │                                                 │
│           │ NAMESPACES_LIST (when namespaces exist)         │
│           │ [List of linked namespaces...]                  │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Registry navigation | Back to Workspaces, Private Library, Public Namespaces | New registry sections |
| BREADCRUMB | Current location | Org > Registry > Public Namespaces | System managed |
| PAGE_HEADER | Page identity | "Namespaces" heading, New Namespace button | N/A |
| CLAIM_INFO | Guidance | Info callout about claiming existing namespaces | N/A |
| EMPTY_STATE | No namespaces | Explanation and call-to-action when no namespaces exist | N/A |
| NAMESPACES_LIST | Namespace list | List of linked GitHub namespaces (when populated) | N/A |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Page Header with Action | Heading + action button | "Namespaces" + [New Namespace] | Page introduction |
| Info Callout | Icon + heading + description + link | "Claim an existing namespace?" | Contextual guidance |
| Empty State | Heading + description + learn more + action | "Create your first namespace" | No content state |
| Section Separator | Horizontal line | Separator between header and content | Visual separation |
| Learn More Link | Text link with external icon | "Learn more about claiming" | Documentation links |
| Action Button | Primary button with icon | "New Namespace" | Main page action |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Registry | BREADCRUMB | `/app/{org}/registry` | registry-modules.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Private Library | SIDEBAR | `/app/{org}/registry` | registry-modules.md |
| Public Namespaces | SIDEBAR | `/app/{org}/registry/public-namespaces` | registry-public-namespaces.md |
| [New Namespace] button | PAGE_HEADER | `/app/{org}/registry/public-namespaces/new` | - |
| Learn more about claiming | CLAIM_INFO | External: Documentation | - |
| Learn more | EMPTY_STATE | External: Documentation | - |
| [New Namespace] button | EMPTY_STATE | `/app/{org}/registry/public-namespaces/new` | - |

## States

### Empty State
When no namespaces are configured:
- Shows "Create your first namespace" heading
- Explains that namespaces manage public Registry content from linked GitHub accounts
- Provides Learn more link and New Namespace button

### Populated State
When namespaces exist:
- Would show list of linked GitHub namespaces
- Each namespace would link to its management page

## Notes

- Public namespaces link HCP Terraform to GitHub accounts for publishing to the public Terraform Registry
- Users can "claim" existing namespaces that match their GitHub account
- This feature enables organizations to manage their public modules and providers from within HCP Terraform
