# Registry - Configuration Designer

**URL**: `/app/{org}/registry/design` (redirects to `/app/{org}/registry/design/modules`)
**Title**: Configuration Designer | Registry | {Org Name}
**Purpose**: Multi-step wizard to design and publish workspace configurations using registry modules

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org}/Registry/Config Designer/Step │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ STEPPER_HEADER                                  │
│ Back:     │ [Select Modules] → [Set Variables] → [Publish]  │
│ • Worksp  │                                        [Next >] │
│ ──────────├─────────────────────────────────────────────────┤
│ Registry: │ TOOLBAR                                         │
│ • Private │ [Search Modules...] [Providers ▼]               │
│   Library ├─────────────────────────────────────────────────┤
│ • Public  │ CONTENT                                         │
│   Namespc │ ┌─────────────────────────┬───────────────────┐ │
│           │ │ "Add Modules to         │ Selected          │ │
│           │ │ Workspace"              │ Modules 0         │ │
│           │ │                         │                   │ │
│           │ │ ┌───────────────────┐   │ (empty state or   │ │
│           │ │ │ consul            │   │ list of selected) │ │
│           │ │ │ Description...    │   │                   │ │
│           │ │ │ [Select consul]   │   │                   │ │
│           │ │ │ Private|aws|v0.7.4│   │                   │ │
│           │ │ │ [Details] [Add]   │   │                   │ │
│           │ │ └───────────────────┘   │                   │ │
│           │ │ ┌───────────────────┐   │                   │ │
│           │ │ │ tflocal-cloud     │   │                   │ │
│           │ │ │ ...               │   │                   │ │
│           │ │ └───────────────────┘   │                   │ │
│           │ │ ...more modules...      │                   │ │
│           │ └─────────────────────────┴───────────────────┘ │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Wizard Steps

| Step | URL | Purpose |
|------|-----|---------|
| Select Modules | `/registry/design/modules` | Choose modules to include in configuration |
| Set Variables | `/registry/design/variables` | Configure variables for selected modules |
| Publish | `/registry/design/publish` | Publish the configuration |

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher, help, user menu | Global actions |
| SIDEBAR | Registry navigation | Back to Workspaces, Private Library, Public Namespaces | New registry sections |
| BREADCRUMB | Current location | Org > Registry > Configuration Designer > Current step | System managed |
| STEPPER_HEADER | Wizard progress | Step links with arrows, Next button | N/A |
| TOOLBAR | Module filtering | Search box, Providers dropdown filter | New filters |
| CONTENT | Module selection | Available modules list + Selected modules panel | N/A |
| FOOTER | Legal/support | Standard footer | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Wizard Stepper | Step links with arrow separators | "Select Modules → Set Variables → Publish" | Multi-step progress |
| Step Link (Current) | Bold/highlighted link | Current step highlighted | Active step indicator |
| Step Link (Available) | Clickable link | Other steps clickable | Navigation between steps |
| Next Button | Action button with arrow | "Next >" | Advance to next step |
| Module Select Card | Module info + Select button + Details/Add | Module selection UI | Choosing modules |
| Select Button | "Select {name}" button | "Select consul" | Select module for details |
| Add Button | Add button with icon | "Add" | Add module to selection |
| Details Link | External link | "Details" | View module details |
| Selected Modules Panel | Heading with count + list | "Selected Modules 0" | Show current selections |
| Providers Filter | Dropdown button | "Providers ▼" | Filter by provider |

## Module Card (Designer Variant)

| Element | Description |
|---------|-------------|
| Module name | Clickable heading |
| Description | Module description text |
| Select button | "Select {name}" to expand details |
| Metadata row | Private badge, Provider, Version, Published, Provisions |
| Details link | Opens module detail page |
| Add button | Adds module to selection |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (org list) | - |
| OrgSwitcher | HEADER | Dropdown to switch orgs | - |
| Breadcrumb: {org} | BREADCRUMB | `/app/{org}` | - |
| Breadcrumb: Registry | BREADCRUMB | `/app/{org}/registry` | registry-modules.md |
| Breadcrumb: Configuration Designer | BREADCRUMB | `/app/{org}/registry/design` | registry-design.md |
| Workspaces | SIDEBAR | `/app/{org}/workspaces` | workspaces-list.md |
| Private Library | SIDEBAR | `/app/{org}/registry` | registry-modules.md |
| Public Namespaces | SIDEBAR | `/app/{org}/registry/public-namespaces` | registry-public-namespaces.md |
| Select Modules step | STEPPER_HEADER | `/app/{org}/registry/design/modules` | registry-design.md |
| Set Variables step | STEPPER_HEADER | `/app/{org}/registry/design/variables` | - |
| Publish step | STEPPER_HEADER | `/app/{org}/registry/design/publish` | - |
| [Next] button | STEPPER_HEADER | Next step in wizard | - |
| [Providers ▼] | TOOLBAR | Opens provider filter dropdown | - |
| [Select {module}] | CONTENT | Expands module details | - |
| [Details] | CONTENT | Module detail page in registry | - |
| [Add] | CONTENT | Adds module to Selected Modules | - |

## Selected Modules Panel

When modules are selected:
- Shows count badge (e.g., "Selected Modules 2")
- Lists selected modules with remove option
- Updates as modules are added/removed

## Notes

- The Configuration Designer is accessed from the "Design configuration" button on the Registry page
- Enables no-code/low-code workspace creation using registry modules
- Wizard maintains state across steps
- Users can navigate between steps using the stepper links
- Final Publish step creates the workspace configuration
