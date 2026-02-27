# HashiCorp Designer Skill

A comprehensive design assistant for HashiCorp product designers.

## Overview

This skill provides AI agents with HashiCorp-specific design context, methodologies, and tools for product design work. It's built for designers working on any HashiCorp product, with optional add-ons for Terraform-specific context.

## Who Should Use This

- HashiCorp product designers
- UX researchers working on HashiCorp products
- Anyone creating wireframes, user flows, or design documentation for HashiCorp

## Quick Start

After installing the plugin, the skill is available automatically. Start any design conversation and the agent will:

1. Display a greeting confirming HashiCorp mode is active
2. Ask 1-2 clarifying questions (persona, JTBD, constraints)
3. Execute your request with HashiCorp context

Say `/help` to see all available commands.

## Capabilities

| Capability | Description | Command |
|------------|-------------|---------|
| **Personas** | HashiCorp User/Buyer/Champion framework | `what persona for [X]` |
| **JTBD** | Jobs to be Done statements | `write JTBD for [need]` |
| **CUJ** | Critical User Journeys | `write CUJ for [task]` |
| **Wireframes** | ASCII wireframes with zones | `wireframe [page]` |
| **User Flows** | Flow diagrams with decisions | `user flow for [task]` |
| **Heuristics** | Nielsen's 10 heuristics evaluation | `evaluate [design]` |
| **OOUX** | Object-Oriented UX (ORCA process) | `OOUX for [product]` |
| **UXDR** | UX Decision Records | `create UXDR` |

## Modes

| Mode | Description | Activation |
|------|-------------|------------|
| **HashiCorp** (default) | Personas, JTBD, CUJ, design processes | Automatic |
| **Terraform** | Adds Terraform product context | Say `terraform` |
| **Generic** | Standard product design, no HashiCorp context | Say `mode: generic` |

## Clarifying Questions

By default, the skill asks 1-2 clarifying questions before executing tasks. This is intentional—it helps catch assumptions early and keeps you thinking critically.

**Why this matters**: Designers working with AI assistants can fall into rapid execution without reflection. The questions surface hidden assumptions and reduce costly rework.

**To skip**: Say `skip questions` or `just do it`

## Add-ons

### HCP Terraform UI Reference

For complete UI wireframes of every HCP Terraform page, use the sibling `hcp-tf-ui` skill:

```
help tfc ui
```

The `hcp-tf-ui` skill contains:
- 22 page wireframes (workspaces, runs, registry, settings, etc.)
- URL → page mappings
- Zone definitions and extensibility points
- Navigation flows and clickable elements

### UI Capture (Browser Automation)

For capturing live website UIs as documentation:

```
help ui capture
```

**Note**: UI capture requires separate browser setup (dev-browser skill). It will NOT auto-start. This is intentional—browser automation should be explicitly requested.

## Resources

This skill includes reference documentation in the `resources/` folder:

| File | Contents |
|------|----------|
| `hashicorp-personas-frameworks.md` | Personas, JTBD, CUJ formats and examples |
| `terraform-onboarding.md` | Terraform product knowledge for designers |
| `wireframing.md` | ASCII wireframe component library |
| `ui-capture-spec.md` | UI capture output format specification |
| `research-synthesis.md` | Empathy maps, journey maps, personas templates |
| `ooux-methodology.md` | Full ORCA process documentation |
| `interaction-patterns.md` | Navigation, forms, data display patterns |
| `design-systems.md` | Atomic design, tokens, documentation |
| `014.UXDR-TFC-Integration.md` | Example UXDR with "invisible first" principles |

## Installation

### Claude Code CLI

```bash
claude plugin marketplace add hashicorp/hashicorp-agent-skills
claude plugin install technology@hashicorp-agent-skills
```

The `hashi-designer` skill will be available automatically.

### Manual Installation

Copy the `hashi-designer/` folder to your skills directory:
- Claude Code: `~/.claude/skills/hashi-designer/`
- OpenCode: `~/.config/opencode/skills/hashi-designer/`
- VS Code: `.github/skills/hashi-designer/`

## Usage Examples

### Design a new feature

```
User: I need to design a workspace health dashboard

Agent: Before I start, a couple questions:
       - Which persona is this for? (Platform Engineer, App Developer, etc.)
       - What's the main job they're trying to accomplish?

User: Platform Engineer, they need to quickly see which workspaces need attention

Agent: [Creates wireframe with zones, applies "attention-required over status" principle]
```

### Write a JTBD

```
User: write JTBD for secret rotation

Agent: 
When managing secrets across multiple environments,
I want to rotate credentials automatically on a schedule
so that I can maintain security compliance without manual intervention.
```

### Evaluate a design

```
User: evaluate this settings page design [provides wireframe or description]

Agent: 
# Evaluation: Settings Page

## Findings
| Finding | Severity | Heuristic | Recommendation |
|---------|----------|-----------|----------------|
| No confirmation on destructive action | Major | #5 Error Prevention | Add confirmation modal |
| 12 options visible at once | Minor | #8 Minimalist | Group into sections |

## Terraform Check
- [ ] Success state minimal - FAIL (shows "Settings saved" banner for 10s)
- [x] Manual triggers de-emphasized
- [x] Problems before status
```

### Create a UXDR

```
User: create UXDR for our decision to hide agent names by default

Agent:
# UXDR-001: Hide Agent Names by Default

**Date**: 2025-01-20
**Status**: Proposed

## Context
The TFC integration displays agent activity. Question: should we show 
which specific agent performed each action?

## Decision
Hide agent names by default. Available in expanded debug view.

## Consequences
- (+) Cleaner UI, users don't need to know implementation details
- (+) Consistent with "invisible first" principle
- (-) Harder to debug which agent had issues (mitigated by debug view)
```

## Extending This Skill

### Add new reference materials

Add markdown files to the `resources/` folder. The skill will reference them.

### Customize for your team

Fork and modify:
- **Personas**: Add your team's specific personas to `hashicorp-personas-frameworks.md`
- **Design principles**: Add product-specific principles
- **Templates**: Add your team's document templates

### Split into separate skills

This skill contains multiple capabilities that could become separate skills:

| Potential Skill | Capability |
|-----------------|------------|
| `hashi-personas` | Personas, JTBD, CUJ only |
| `wireframes` | ASCII wireframing only |
| `uxdr` | Decision records only |
| `ooux` | Object-Oriented UX only |

To split: Extract relevant sections from SKILL.md into new skill folders.

## Related Skills

| Skill | Description |
|-------|-------------|
| `hcp-tf-ui` | HCP Terraform UI wireframes and documentation (22 pages) |
| `hds` | Helios Design System components and patterns |
| `terraform` | Terraform CLI and configuration knowledge |

## Design Philosophy

This skill embeds several design principles:

1. **Questions before execution** - Clarifying questions catch assumptions early
2. **Personas ground decisions** - Every design should identify its target user
3. **JTBD over features** - Focus on user goals, not product capabilities
4. **Objects before actions** - OOUX: design the nouns, then the verbs
5. **Document decisions** - UXDRs capture rationale for future reference

For Terraform specifically:
- **Silence is success** - Minimal UI when things work
- **GitHub is primary** - TFC links to GitHub, doesn't duplicate
- **Attention-required over status** - Lead with problems, not stats

## Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines on improving this skill.

## Changelog

### 1.0.0 (2025-01-20)
- Initial release
- HashiCorp personas, JTBD, CUJ framework
- ASCII wireframing with component library
- Heuristic evaluation
- OOUX methodology
- UXDR templates
- Terraform product context (optional)
- UI capture specification (optional)
