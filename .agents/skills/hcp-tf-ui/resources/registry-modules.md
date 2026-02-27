# Registry - Modules

**URL**: `/app/{org}/registry` (redirects to `/app/{org}/registry/private/modules`)
**Title**: Registry | {Org Name}
**Purpose**: Browse and manage private and public Terraform modules in the organization's registry

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Registry / Modules          │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ Back:     │ "Registry"                                      │
│ • Worksp  │ [Design configuration] [Search public registry] │
│ ──────────├─────────────────────────────────────────────────┤
│ Registry: │ TOOLBAR                                         │
│ • Private │ [Search filter...] [Publish ▼]                  │
│   Library*├─────────────────────────────────────────────────┤
│ • Public  │ TAB_BAR                                         │
│   Namespc │ [Modules*] [Providers] [Stack components]       │
│           │ Test generation: [On] link                      │
│           ├───────────────────┬─────────────────────────────┤
│           │ FILTERS           │ MODULE_CARDS                │
│           │ ┌───────────────┐ │ ┌─────────────────────────┐ │
│           │ │▼ No-code [i]  │ │ │ consul [no-code icon]   │ │
│           │ │ □ No-Code     │ │ │ Description...          │ │
│           │ │   ready       │ │ │ [View details]          │ │
│           │ │               │ │ │ [Private] aws v0.7.2    │ │
│           │ │▼ Providers    │ │ │ Tag-based | 6 yrs ago   │ │
│           │ │ □ aws         │ │ └─────────────────────────┘ │
│           │ │ □ google      │ │ ┌─────────────────────────┐ │
│           │ │ □ datadog     │ │ │ [logo] namespace/module │ │
│           │ │               │ │ │ Description...          │ │
│           │ │▼ Registries   │ │ │ [View details]          │ │
│           │ │ □ private     │ │ │ [Public] aws            │ │
│           │ │ □ public      │ │ └─────────────────────────┘ │
│           │ │               │ │ ...more module cards...    │
│           │ │▼ Publishing   │ │                             │
│           │ │ □ Branch      │ │ PAGINATION                  │
│           │ │ □ Tags        │ │ 1-10 of 10 | [1]            │
│           │ └───────────────┘ │                             │
├───────────┴───────────────────┴─────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Registry Tabs

| Tab | URL | Purpose |
|-----|-----|---------|
| Modules | `/registry/private/modules` | Browse private and curated public modules |
| Providers | `/registry/private/providers` | Browse private and curated public providers |
| Stack component configurations | `/registry/private/stacks` | Browse stack component configurations |

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Registry navigation | Back to Workspaces, Private Library, Public Namespaces | New registry sections |
| BREADCRUMB | Current location | Org > Registry > Modules | System managed |
| PAGE_HEADER | Page identity | Heading, Design config and Public search buttons | N/A |
| TOOLBAR | Search and actions | Filter search, Publish dropdown | N/A |
| TAB_BAR | Registry content type | Modules, Providers, Stack components tabs | New content types |
| FILTERS | Module filtering | No-code, Providers, Registries, Publishing Type | New filter categories |
| MODULE_CARDS | Module listing | Grid of module cards with metadata | N/A |
| PAGINATION | Navigate pages | Count, page buttons | System managed |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Registry Tab | Icon + label | "Modules" with icon | Content type selection |
| Filter Accordion | Heading + checkbox list | "Providers" section | Faceted filtering |
| Filter Info Popover | Info icon expanding to details | No-code Provisioning info | Feature explanation |
| Module Card (Private) | Name + description + metadata row | consul module | Private module display |
| Module Card (Public) | Logo + namespace/name + description | terraform-aws-modules/iam | Public module display |
| No-Code Badge | Icon on module name | Star icon on heading | No-code ready modules |
| Private/Public Badge | Button-style badge | "Private" or "Public" | Registry type indicator |
| Provider Badge | Icon + provider name | AWS icon + "aws" | Cloud provider indicator |
| Version Badge | Icon + version number | "v0.7.2" | Current module version |
| Publishing Type Badge | Icon + "Branch based" or "Tag based" | Git icon + type | VCS publishing method |
| Published Date | Icon + relative time | "6 years ago" | Last publish date |
| Provisions Count | Icon + count | "< 100" | Usage statistics |
| Feature Link | Label + link | "Test generation: On" | Feature status with settings link |
| Action Button Row | Multiple action buttons | Design config + Search public | Page-level actions |
| Publish Dropdown | Button with dropdown | "Publish ▼" | Publishing options |

## Filters

| Filter Category | Options | Purpose |
|-----------------|---------|---------|
| No-code Provisioning | No-Code ready | Filter modules supporting no-code workflow |
| Providers | aws, google, datadog, etc. | Filter by cloud provider |
| Registries | private, public | Filter by registry type |
| Publishing Type | Branch, Tags | Filter by VCS publishing method |

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
| [Search public registry] | PAGE_HEADER | `/app/{org}/registry/public/modules` | - |
| [Publish ▼] | TOOLBAR | Opens publish dropdown | - |
| Tab: Modules | TAB_BAR | `/app/{org}/registry/private/modules` | registry-modules.md |
| Tab: Providers | TAB_BAR | `/app/{org}/registry/private/providers` | registry-providers.md |
| Tab: Stack components | TAB_BAR | `/app/{org}/registry/private/stacks` | - |
| Test generation link | TAB_BAR | `/app/{org}/settings/profile` | org-settings.md |
| No-code info button | FILTERS | Opens info popover | - |
| Learn more (no-code) | FILTERS | External: HashiCorp Learn | - |
| Create your own (no-code) | FILTERS | External: Terraform docs | - |
| Module name link | MODULE_CARDS | Module detail page | - |
| View details link | MODULE_CARDS | `/app/{org}/registry/modules/{private|public}/{namespace}/{module}/{provider}` | - |
| Private/Public badge | MODULE_CARDS | Tooltip or info | - |
| Page number | PAGINATION | Changes page | - |

## Module Card Variants

### Private Module Card
- Module name (may include no-code icon)
- Description
- View details link
- Metadata row: Private badge, Provider, Version, Publishing type, Published date, Provisions

### Public Module Card
- Namespace logo
- Namespace / Module name
- Description
- View details link
- Metadata row: Public badge, Provider

## No-Code Provisioning Info

The No-code Provisioning filter includes an info popover explaining:
- Modules can be provisioned via no-code workflow
- Links to learn more and create no-code modules
