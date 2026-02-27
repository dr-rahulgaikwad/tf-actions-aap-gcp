# About Helios Design System (HDS)

## What is Helios?

Helios is HashiCorp's design system - "a set of guidelines, standards, assets, and processes to help organizations design, build, and deploy products rapidly and consistently."

Created and maintained by HashiCorp's Design Systems Team, Helios provides a single source of truth for foundations, components, and patterns across all HashiCorp customer-facing products.

## Purpose and Goals

### Primary Purpose
Helios was specifically built for **customer-facing products** across HashiCorp's product lines (Terraform, Vault, Consul, Nomad, Boundary, Packer, Vagrant, Waypoint).

### Key Goals
1. **Accelerate development** - Rapidly design and build new products and features
2. **Ensure consistency** - Enhanced visual and functional consistency across products
3. **Reduce duplication** - Provide reusable components and foundations
4. **Guarantee accessibility** - WCAG 2.2 AA conformance built into all components

## Who Should Use Helios?

### ✅ Recommended For
- **HashiCorp product teams** building customer-facing features
- **Ember.js applications** (primary framework support)
- **Atlas frontend development** (that's us!)

### ⚠️ Case-by-Case Support
- Teams using **alternative frameworks** (React, Vue)
- Access to design assets and guidance available
- Component support may be limited

### ❌ Not Intended For
- Internal tools
- General-purpose UI development
- External/non-HashiCorp use
- Projects outside HashiCorp's product ecosystem

## Design Principles

Helios is built on six core principles that guide all design and development decisions:

### 1. Rooted in Reality
**"We ground our work and our decisions in reality through data and observations."**

**What it means:**
- Base decisions on real user data and research
- Validate design choices with evidence
- Observe how people actually use the system
- Don't rely on assumptions

**For developers:**
- Test with real data and scenarios
- Gather feedback from actual users
- Use analytics to inform decisions
- Question assumptions with data

### 2. Guidance Over Control
**"We provide balance between configurability and composability while driving consistency."**

**What it means:**
- Components are flexible but opinionated
- Provide options without overwhelming users
- Balance customization with consistency
- Guide rather than restrict

**For developers:**
- Use component variants appropriately
- Follow patterns but adapt to context
- Don't force-fit components where they don't belong
- Extend thoughtfully when needed

### 3. Quality by Default
**"We recognize that we are providing a service and commit to a baseline of quality to provide value and leverage for our consumers. We iterate on features, not quality."**

**What it means:**
- Quality is non-negotiable
- Components are polished before release
- Reliability over rushed features
- Maintain high standards consistently

**For developers:**
- Trust HDS components to work correctly
- Report bugs when quality falls short
- Don't compromise on quality for speed
- Test thoroughly before shipping

### 4. Design in Context
**"We meet consumers where they are and consider both the current and future context."**

**What it means:**
- Consider how components are actually used
- Design for current and future needs
- Understand the full user journey
- Think beyond individual interactions

**For developers:**
- Consider the user's mental model
- Think about the full workflow
- Anticipate edge cases
- Plan for growth and change

### 5. Consider Everyone
**"We take an inclusive approach from the start, considering the context and range of abilities for all customers."**

**What it means:**
- Accessibility is foundational, not an afterthought
- Design for diverse abilities (vision, motor, cognitive, hearing)
- Test with assistive technologies
- Serve all users equally

**For developers:**
- Use HDS components for built-in accessibility
- Test with keyboard navigation
- Test with screen readers
- Follow accessibility patterns
- Never remove focus indicators
- Always provide labels and alt text

### 6. Invite Feedback
**"We take time to have the right conversations with appropriate stakeholders."**

**What it means:**
- Collaborate with designers and other engineers
- Validate solutions with stakeholders
- Build trust through communication
- Improve through feedback

**For developers:**
- Ask questions in #team-design-systems
- Share your use cases and challenges
- Contribute patterns you discover
- Help improve the system

## System Architecture

Helios is organized around four pillars:

### 1. Foundations
Base elements that everything else builds on:
- **Colors** - Semantic color tokens
- **Typography** - Type scales and font stacks
- **Icons** - Flight Icons library
- **Spacing** - Consistent spacing scale
- **Elevation** - Shadow system for depth

### 2. Components
Reusable UI elements with:
- **Design specifications** in Figma
- **Development implementation** in Ember.js
- **Design tokens** for styling
- **Accessibility** built-in
- **Documentation** and examples

### 3. Patterns
Solutions for common UX challenges:
- **Button organization** - Layout and hierarchy
- **Filter patterns** - Dataset filtering
- **Form patterns** - User-centric forms
- **Table multi-select** - Bulk operations
- **Show/hide/disable** - Conditional UI
- **Description lists** - Key-value displays
- **Data visualization** - Chart guidelines

### 4. Documentation
Resources for using the system:
- **Component docs** with examples
- **Pattern guidelines** with code
- **Accessibility guides** for compliance
- **Contribution processes** for collaboration
- **This documentation** you're reading now!

## Benefits for Atlas Developers

### Faster Development
- Pre-built components ready to use
- No need to design basic UI elements
- Consistent styling out of the box
- Less time on UI, more on features

### Better Quality
- WCAG 2.2 AA accessible by default
- Tested across browsers and devices
- Professionally designed
- Battle-tested in production

### Easier Maintenance
- Updates benefit all products
- Bug fixes cascade everywhere
- Consistent patterns across Atlas
- Less custom code to maintain

### Better Collaboration
- Shared language with designers
- Consistent terminology
- Easier code reviews
- Clearer expectations

## How Helios Works with Atlas

### Atlas Uses Ember.js
Perfect match! Helios components are built for Ember.js:
```bash
cd frontend/atlas
pnpm list @hashicorp/design-system-components
```

### Components are Imported Automatically
No manual imports needed:
```handlebars
{{! Just use components directly }}
<Hds::Button @text="Click me" />
<Hds::Alert @color="success" as |A|>
  <A.Title>Success!</A.Title>
</Hds::Alert>
```

### Design Tokens are Available
Use tokens for custom styling:
```css
.my-component {
  color: var(--token-color-foreground-primary);
  padding: var(--token-spacing-200);
  border-radius: var(--token-border-radius-medium);
}
```

### Styles are Included
Import in your Sass files:
```scss
@use "@hashicorp/design-system-components";
```

## Version and Support

### Current Version
Check your version:
```bash
cd frontend/atlas
pnpm list @hashicorp/design-system-components
```

### Updating HDS
```bash
cd frontend/atlas
pnpm update @hashicorp/design-system-components
```

### Getting Help
- **Slack**: #team-design-systems
- **Documentation**: https://helios.hashicorp.design
- **GitHub**: Issues and discussions in the HDS repo
- **Office Hours**: Check team calendar for design systems sessions

## Contributing to Helios

### Reporting Issues
Found a bug or accessibility issue?
1. Check if it's already reported
2. Create a GitHub issue with details
3. Tag in #team-design-systems

### Requesting Features
Need a new component or pattern?
1. Describe the use case and context
2. Share mockups or examples if available
3. Post in #team-design-systems
4. Design Systems team will evaluate

### Sharing Patterns
Discovered a useful pattern?
1. Document it with code examples
2. Share in #team-design-systems
3. May be added to official patterns

## Evolution of Helios

### Continuous Improvement
Helios is not static - it evolves based on:
- User feedback from product teams
- New accessibility standards
- Emerging design patterns
- Technology updates

### Staying Current
- Watch release notes for updates
- Attend design systems office hours
- Follow #team-design-systems announcements
- Update regularly to get improvements

## Learning Resources

### For Engineers
- **Getting Started**: https://helios.hashicorp.design/getting-started/for-engineers
- **Components**: https://helios.hashicorp.design/components
- **Patterns**: https://helios.hashicorp.design/patterns
- **Tokens**: https://helios.hashicorp.design/foundations/tokens

### For Designers
- **Figma Libraries**: Available to HashiCorp designers
- **Design Guidelines**: In Helios documentation
- **Design Tokens**: Exported for design tools

### For Everyone
- **About HDS**: https://helios.hashicorp.design/about
- **Principles**: https://helios.hashicorp.design/about/principles
- **Accessibility**: https://helios.hashicorp.design/about/accessibility

## Quick Reference

**When to use HDS:**
- ✅ Building new UI in Atlas
- ✅ Need accessible components
- ✅ Want consistent styling
- ✅ Common UI patterns (forms, tables, modals)

**When to check with Design Systems:**
- ⚠️ Can't find the right component
- ⚠️ Need to customize significantly
- ⚠️ Building something novel
- ⚠️ Accessibility questions

**When to build custom:**
- 🛠️ Very domain-specific functionality
- 🛠️ No HDS component fits the use case
- 🛠️ After consulting with Design Systems team
- 🛠️ Still using HDS tokens for styling

## Summary

Helios Design System provides Atlas developers with:
- **Ready-to-use components** that are accessible and well-tested
- **Design tokens** for consistent custom styling
- **Patterns** for solving common UX challenges
- **Documentation** to learn and reference
- **Support** from the Design Systems team

By using Helios, we build faster, build better, and provide a consistent experience across all HashiCorp products.

For the full Helios experience, explore:
https://helios.hashicorp.design
