# Registry - Providers

**URL**: `/app/{org}/registry/private/providers`
**Title**: Registry | {Org Name}
**Purpose**: Browse and manage private and public Terraform providers in the organization's registry

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Registry / Providers        │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Back:     │ "Registry"                                      │
│ • Worksp  │ [Design configuration] [Search public registry] │
│ ──────────├─────────────────────────────────────────────────┤
│ Registry: │ TOOLBAR                                         │
│ • Private │ [Search filter...] [Publish ▼]                  │
│   Library ├─────────────────────────────────────────────────┤
│ • Public  │ TAB_BAR                                         │
│   Namespc │ [Modules] [Providers*] [Stack components]       │
│           │ Test generation: [On] link                      │
│           ├───────────────────┬─────────────────────────────┤
│           │ FILTERS           │ PROVIDER_CARDS              │
│           │ ┌───────────────┐ │ ┌─────────────────────────┐ │
│           │ │ No applicable │ │ │ [aws icon] aws          │ │
│           │ │ filters       │ │ │ by hashicorp            │ │
│           │ │ available     │ │ │ [View details]          │ │
│           │ │               │ │ │ [Public] v6.28.0        │ │
│           │ │               │ │ │ 6 days ago | 10.6M      │ │
│           │ │               │ │ └─────────────────────────┘ │
│           │ │               │ │ ┌─────────────────────────┐ │
│           │ │               │ │ │ [consul icon] consul    │ │
│           │ │               │ │ │ by hashicorp            │ │
│           │ │               │ │ │ [View details]          │ │
│           │ │               │ │ │ [Public]                │ │
│           │ │               │ │ └─────────────────────────┘ │
│           │ │               │ │ ...more provider cards...  │
│           │ └───────────────┘ │                             │
│           │                   │ PAGINATION                  │
│           │                   │ [Previous] [Next]           │
├───────────┴───────────────────┴─────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Registry navigation | Back to Workspaces, Private Library, Public Namespaces | New registry sections |
| BREADCRUMB | Current location | Org > Registry > Providers | System managed |
| PAGE_HEADER | Page identity | Heading, Design config and Public search buttons | N/A |
| TOOLBAR | Search and actions | Filter search, Publish dropdown | N/A |
| TAB_BAR | Registry content type | Modules, Providers, Stack components tabs | New content types |
| FILTERS | Provider filtering | May show "No applicable filters available" | New filter categories |
| PROVIDER_CARDS | Provider listing | Grid of provider cards with metadata | N/A |
| PAGINATION | Navigate pages | Previous/Next buttons | System managed |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Provider Card | Logo + name + namespace + metadata | aws by hashicorp | Provider display |
| Provider Logo | Square icon representing provider | AWS logo | Visual identification |
| Namespace Label | "by {namespace}" text | "by hashicorp" | Provider ownership |
| Public Badge | Button-style badge | "Public" | Registry type indicator |
| Version Badge | Icon + version number | "v6.28.0" | Current provider version |
| Published Date | Icon + relative time | "6 days ago" | Last publish date |
| Provisions Count | Icon + formatted number | "10.6M" | Usage statistics |
| No Filters Message | Centered text | "No applicable filters available" | Empty filter state |
| Text Pagination | Previous/Next buttons with labels | "[Previous] [Next]" | Simple page navigation |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Registry | BREADCRUMB | `/app/{org}/registry` | registry-modules.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Private Library | SIDEBAR | `/app/{org}/registry` | registry-modules.md |
| Public Namespaces | SIDEBAR | `/app/{org}/registry/public-namespaces` | - |
| [Design configuration] | PAGE_HEADER | `/app/{org}/registry/design` | - |
| [Search public registry] | PAGE_HEADER | `/app/{org}/registry/public/providers` | - |
| [Publish ▼] | TOOLBAR | Opens publish dropdown | - |
| Tab: Modules | TAB_BAR | `/app/{org}/registry/private/modules` | registry-modules.md |
| Tab: Providers | TAB_BAR | `/app/{org}/registry/private/providers` | registry-providers.md |
| Tab: Stack components | TAB_BAR | `/app/{org}/registry/private/stacks` | - |
| Test generation link | TAB_BAR | `/app/{org}/settings/profile` | org-settings.md |
| View details link | PROVIDER_CARDS | `/app/{org}/registry/providers/public/{namespace}/{provider}/latest` | - |
| Previous button | PAGINATION | Previous page of results | - |
| Next button | PAGINATION | Next page of results | - |

## Provider Card Structure

| Element | Description |
|---------|-------------|
| Provider Logo | Square icon representing the provider |
| Provider Name | Provider identifier (e.g., "aws", "consul") |
| Namespace | "by {namespace}" showing ownership |
| View details link | Link to provider detail page |
| Public/Private Badge | Registry type indicator |
| Version | Current provider version (optional) |
| Published Date | When provider was last published (optional) |
| Provisions Count | How many times provider has been provisioned (optional) |

## Notes

- The Providers tab may show "No applicable filters available" when there are no applicable filtering options
- Provider detail URLs follow pattern: `/app/{org}/registry/providers/{public|private}/{namespace}/{provider}/latest`
- Pagination uses Previous/Next buttons instead of numbered pages
- Public providers show a "Public" badge, private providers would show "Private"
