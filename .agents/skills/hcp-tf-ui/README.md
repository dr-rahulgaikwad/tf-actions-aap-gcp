# HCP Terraform UI Design Reference

A comprehensive UI design reference for HashiCorp Cloud Platform (HCP) Terraform. This repository documents the complete interface architecture, page layouts, navigation patterns, and zone-based organization of the TFC web interface.

## Purpose

This repository enables:

- **AI Agents** to navigate and understand the HCP Terraform UI structure for design collaboration
- **Designers** to reference existing patterns and identify where new features should live
- **Engineers** to understand page layouts, navigation flows, and component architecture
- **Product Teams** to review feature scope and interaction patterns

## Documentation Format

Each page is documented with:

| Section | Description |
|---------|-------------|
| **URL & Purpose** | Route pattern and page function |
| **Layout** | ASCII diagram showing visual zones |
| **Zones** | Functional areas with extensibility notes |
| **Patterns** | Reusable UI components and structures |
| **Clickable Elements** | Navigation mapping (source → destination) |
| **Data Structures** | Field definitions and options |

### Example Layout Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher | Help | UserMenu                │
├───────────┬─────────────────────────────────────────────────┤
│           │ BREADCRUMB: {org} / Workspaces / {ws}           │
│ SIDEBAR   ├─────────────────────────────────────────────────┤
│           │ PAGE_TITLE + ACTIONS                            │
│           ├─────────────────────────────────────────────────┤
│           │ CONTENT_AREA                                    │
│           │                                                 │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security                │
└─────────────────────────────────────────────────────────────┘
```

## Page Index

### Workspaces
| File | Route | Description |
|------|-------|-------------|
| [workspaces-list.md](resources/workspaces-list.md) | `/app/{org}/workspaces` | Workspace listing with filters |
| [workspace-overview.md](resources/workspace-overview.md) | `/app/{org}/workspaces/{ws}` | Workspace dashboard |
| [workspace-runs.md](resources/workspace-runs.md) | `/app/{org}/workspaces/{ws}/runs` | Run history |
| [workspace-run-detail.md](resources/workspace-run-detail.md) | `/app/{org}/workspaces/{ws}/runs/{run}` | Individual run details |
| [workspace-states.md](resources/workspace-states.md) | `/app/{org}/workspaces/{ws}/states` | State management |
| [workspace-variables.md](resources/workspace-variables.md) | `/app/{org}/workspaces/{ws}/variables` | Variable configuration |
| [workspace-settings.md](resources/workspace-settings.md) | `/app/{org}/workspaces/{ws}/settings` | Workspace settings |
| [workspace-health.md](resources/workspace-health.md) | `/app/{org}/workspaces/{ws}/health/drift` | Drift detection & health |
| [workspace-search.md](resources/workspace-search.md) | `/app/{org}/workspaces/{ws}/search` | Search & import |
| [workspace-change-requests.md](resources/workspace-change-requests.md) | `/app/{org}/workspaces/{ws}/change-requests` | Change request workflows |

### Organization
| File | Route | Description |
|------|-------|-------------|
| [organizations-list.md](resources/organizations-list.md) | `/app/organizations` | Organization selection |
| [projects-list.md](resources/projects-list.md) | `/app/{org}/projects` | Project management |
| [project-detail.md](resources/project-detail.md) | `/app/{org}/projects/{project}` | Project details |
| [stacks-list.md](resources/stacks-list.md) | `/app/{org}/stacks` | Stacks management |
| [org-settings.md](resources/org-settings.md) | `/app/{org}/settings` | Organization settings |

### Registry
| File | Route | Description |
|------|-------|-------------|
| [registry-modules.md](resources/registry-modules.md) | `/app/{org}/registry/modules` | Module registry |
| [registry-providers.md](resources/registry-providers.md) | `/app/{org}/registry/providers` | Provider registry |
| [registry-design.md](resources/registry-design.md) | `/app/{org}/registry/design` | Configuration designer |
| [registry-public-namespaces.md](resources/registry-public-namespaces.md) | `/app/{org}/registry/public-namespaces` | Public namespace browser |

### Analytics
| File | Route | Description |
|------|-------|-------------|
| [explorer.md](resources/explorer.md) | `/app/{org}/explorer` | Data explorer & queries |
| [usage.md](resources/usage.md) | `/app/{org}/usage` | Usage statistics |

## Navigation Hierarchy

```
Organizations (entry point)
└── {org}
    ├── Workspaces
    │   └── {workspace}
    │       ├── Overview
    │       ├── Runs → Run Detail
    │       ├── States
    │       ├── Search & Import
    │       ├── Variables
    │       ├── Change Requests
    │       ├── Health
    │       └── Settings
    ├── Projects
    │   └── {project}
    ├── Stacks
    ├── Registry
    │   ├── Modules
    │   ├── Providers
    │   ├── Design
    │   └── Public Namespaces
    ├── Explorer
    ├── Usage
    └── Settings
```

## Why Markdown Files?

This documentation uses plain markdown files for maximum accessibility and portability:

### ✓ Universal Compatibility
- Works with **any LLM**: ChatGPT, Claude.ai, Gemini, local models, and future tools
- No special setup, dependencies, or server required
- Just copy/paste or upload files directly into your LLM of choice

### ✓ Human-Readable
- Designers and developers can read the docs without any tools
- Easy to review, edit, and understand in any text editor or GitHub
- Great for onboarding and reference outside of LLM contexts

### ✓ Version Control Friendly
- Git-native format with clear diffs
- Easy collaboration through pull requests
- Track changes over time as the UI evolves

### ✓ Zero Friction
- No installation of skills, MCP servers, or extensions
- No runtime dependencies or compatibility issues
- Works offline and in any environment

## How to Use This Documentation

### For Designers/Developers Using LLMs

**Quick Reference (Fast URL Lookups):**
1. Load `quick-reference.md` into your LLM
2. Ask: "What page handles `/app/{org}/workspaces/{ws}/runs`?"
3. Get immediate URL → page mappings and common patterns

**Single Page Context:**
1. Copy `resources/_index.md` (overview) into your LLM for navigation structure
2. Copy the specific page file you need from `resources/` (e.g., `resources/workspace-overview.md`)
3. Ask questions about layouts, zones, and clickable elements

**Multiple Pages:**
1. Start with `quick-reference.md` for orientation
2. Load relevant page files from `resources/` for your task (e.g., all `resources/workspace-*.md` files)
3. Work with complete UI context for complex design questions

### For AI Agents (Programmatic Use)

See `AGENT-INSTRUCTIONS.md` for detailed guidance on how to process and use this documentation effectively.

This documentation is structured to help AI agents understand:

1. **Where things live**: Use the URL patterns to locate features
2. **What's on each page**: Zone definitions describe every functional area
3. **How pages connect**: Clickable elements map navigation flows
4. **What patterns exist**: Reusable patterns show established conventions
5. **Where new features fit**: Extensibility notes indicate expansion points

### Common Agent Queries

When working with this reference:
- "What page handles [feature]?" → Check quick-reference.md or the page index
- "Where should [new feature] go?" → Review zones with extensibility notes
- "What patterns does TFC use for [type of UI]?" → Check patterns tables in relevant pages
- "How do users navigate from [A] to [B]?" → Check clickable elements sections

## File Naming Convention

- List pages: `{thing}s-list.md` (e.g., `workspaces-list.md`)
- Detail pages: `{thing}-detail.md` or `{thing}-{subpage}.md`
- Context prefix: `{context}-{page}.md` (e.g., `workspace-runs.md`)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding or updating page documentation.

## License

[MIT](LICENSE)
