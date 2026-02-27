---
name: hds
description: Helios Design System (HDS) - HashiCorp's design system for building consistent, accessible UI components in Ember.js and React
---

# HDS (Helios Design System)

Helios is HashiCorp's design system providing components, patterns, and design tokens for building consistent, accessible customer-facing products.

## When to Use This Skill

Use this skill when you need to:
- Build UI with HashiCorp's design system components
- Ensure accessibility compliance (WCAG 2.2 AA)
- Maintain visual consistency across HashiCorp products
- Implement forms, buttons, modals, and other common UI patterns
- Use HashiCorp design tokens in custom styles
- Work with Ember.js (Terraform Cloud, Consul, Boundary, etc.)
- Work with React (marketing website, developer.hashicorp.com)

## What is Helios?

**Helios is HashiCorp's design system** - the single authoritative source for building customer-facing UI.

### Core Purpose

Helios provides:
- **Foundations**: Colors, typography, icons, spacing
- **Components**: Pre-built, accessible UI elements (buttons, forms, modals, etc.)
- **Patterns**: Guidelines for combining components to solve common UX challenges
- **Design Tokens**: CSS variables for colors, spacing, typography, etc.

### Why Helios?

**The Problem:**
- Inconsistent UI across HashiCorp products
- Accessibility issues from custom components
- Reinventing common patterns (buttons, forms, modals)
- Hard to maintain design consistency at scale

**Helios' Solution:**
- **WCAG 2.2 AA conformance** out of the box
- **Visual consistency** across all HashiCorp products
- **Faster development** with pre-built components
- **Framework support** for Ember.js (primary) and React
- **Accessible by default** - proper ARIA, keyboard nav, focus management

**Documentation:** https://helios.hashicorp.design

## Design Principles

Helios is built on six core principles:

1. **Rooted in reality** — Decisions grounded in data and observations
2. **Guidance over control** — Balance between configurability and consistency
3. **Quality by default** — Baseline quality with iteration on features, not quality
4. **Design in context** — Consider current and future usage context
5. **Consider everyone** — Inclusive approach for all customer abilities
6. **Invite feedback** — Right conversations with appropriate stakeholders

## Framework Support

### Primary: Ember.js

HDS is built primarily for Ember.js and used in:
- **Terraform Cloud/Enterprise** (Atlas)
- **HashiCorp Cloud Platform** (HCP)
- **Consul**
- **Boundary**
- **Nomad** (UI)
- **Vault** (UI)

### Secondary: React

React components available for:
- **Marketing website** (www.hashicorp.com)
- **Developer portal** (developer.hashicorp.com)
- Other React-based projects

## Installation & Setup

### For Ember.js Projects

**Install components:**
```bash
npm install @hashicorp/design-system-components
# or
pnpm add @hashicorp/design-system-components
```

**Import styles (Sass):**
```scss
// app/styles/app.scss
@use "@hashicorp/design-system-components";
```

**Import styles (CSS):**
```javascript
// ember-cli-build.js
app.import('node_modules/@hashicorp/design-system-components/dist/styles/@hashicorp/design-system-components.css');
```

**Required global styles:**
```css
/* Box-sizing reset required by HDS */
*, *::before, *::after {
  box-sizing: border-box;
}
```

### For React Projects

**Install components:**
```bash
npm install @hashicorp/react-design-system-components
# or
pnpm add @hashicorp/react-design-system-components
```

**Import in your app:**
```javascript
import '@hashicorp/react-design-system-components/dist/styles/index.css';
```

### Design Tokens (Standalone)

For using tokens without components:

```bash
npm install @hashicorp/design-system-tokens
```

### Icons (Standalone)

Flight Icons can be used standalone:

```bash
npm install @hashicorp/flight-icons
```

## Using HDS Components

### Ember.js Components

Components use the `Hds::` namespace:

**Button:**
```handlebars
{{! Primary button }}
<Hds::Button @text="Click me" @color="primary" />

{{! Button with icon }}
<Hds::Button @text="Add Workspace" @icon="plus" @color="primary" />

{{! Button with action }}
<Hds::Button
  @text="Save"
  @color="primary"
  {{on "click" this.handleSave}}
/>
```

**Alert:**
```handlebars
<Hds::Alert @type="inline" @color="success" as |A|>
  <A.Title>Success!</A.Title>
  <A.Description>Your changes have been saved.</A.Description>
</Hds::Alert>

<Hds::Alert @type="inline" @color="critical" as |A|>
  <A.Title>Error</A.Title>
  <A.Description>{{this.error.message}}</A.Description>
</Hds::Alert>
```

**Form Input:**
```handlebars
<Hds::Form::TextInput::Field
  @type="text"
  @value={{this.workspaceName}}
  {{on "input" this.handleNameInput}}
  as |F|
>
  <F.Label>Workspace Name</F.Label>
  <F.HelperText>Choose a unique name for your workspace.</F.HelperText>
  {{#if this.errors.name}}
    <F.Error>{{this.errors.name}}</F.Error>
  {{/if}}
</Hds::Form::TextInput::Field>
```

**Modal:**
```handlebars
<Hds::Modal
  @onClose={{this.closeModal}}
  as |M|
>
  <M.Header>
    Delete Workspace
  </M.Header>
  <M.Body>
    <p>Are you sure you want to delete <strong>{{@workspace.name}}</strong>?</p>
  </M.Body>
  <M.Footer as |F|>
    <Hds::ButtonSet>
      <Hds::Button
        @text="Delete"
        @color="critical"
        {{on "click" this.confirmDelete}}
      />
      <Hds::Button
        @text="Cancel"
        @color="secondary"
        {{on "click" this.closeModal}}
      />
    </Hds::ButtonSet>
  </M.Footer>
</Hds::Modal>
```

### React Components

**Button:**
```jsx
import { Button } from '@hashicorp/react-design-system-components';

function MyComponent() {
  return (
    <>
      <Button text="Click me" color="primary" />
      <Button
        text="Add Workspace"
        icon="plus"
        color="primary"
        onClick={handleAdd}
      />
    </>
  );
}
```

**Alert:**
```jsx
import { Alert } from '@hashicorp/react-design-system-components';

function MyComponent() {
  return (
    <Alert type="inline" color="success">
      <Alert.Title>Success!</Alert.Title>
      <Alert.Description>
        Your changes have been saved.
      </Alert.Description>
    </Alert>
  );
}
```

**Form Input:**
```jsx
import { Form } from '@hashicorp/react-design-system-components';

function MyForm() {
  const [name, setName] = useState('');
  const [error, setError] = useState('');

  return (
    <Form.TextInput.Field
      value={name}
      onChange={(e) => setName(e.target.value)}
    >
      <Form.Label>Workspace Name</Form.Label>
      <Form.HelperText>
        Choose a unique name for your workspace.
      </Form.HelperText>
      {error && <Form.Error>{error}</Form.Error>}
    </Form.TextInput.Field>
  );
}
```

**Modal:**
```jsx
import { Modal, Button, ButtonSet } from '@hashicorp/react-design-system-components';

function MyComponent() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <Button text="Delete" onClick={() => setIsOpen(true)} />

      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)}>
        <Modal.Header>Delete Workspace</Modal.Header>
        <Modal.Body>
          <p>Are you sure you want to delete this workspace?</p>
        </Modal.Body>
        <Modal.Footer>
          <ButtonSet>
            <Button
              text="Delete"
              color="critical"
              onClick={handleDelete}
            />
            <Button
              text="Cancel"
              color="secondary"
              onClick={() => setIsOpen(false)}
            />
          </ButtonSet>
        </Modal.Footer>
      </Modal>
    </>
  );
}
```

## Component Categories

### Navigation
- `Hds::Breadcrumb` - Breadcrumb navigation
- `Hds::SideNav` - Sidebar navigation
- `Hds::AppHeader` - Application header
- `Hds::AppFooter` - Application footer
- `Hds::Tabs` - Tab navigation

### Forms
- `Hds::Form::TextInput::Field` - Text input
- `Hds::Form::Textarea::Field` - Textarea
- `Hds::Form::Select::Field` - Dropdown select
- `Hds::Form::Checkbox::Field` - Checkbox
- `Hds::Form::Radio::Field` - Radio button
- `Hds::Form::Toggle::Field` - Toggle switch
- `Hds::Form::FileInput::Field` - File upload

### Feedback
- `Hds::Alert` - Alert messages
- `Hds::Toast` - Toast notifications
- `Hds::Badge` - Status badges
- `Hds::Tag` - Tags/labels

### Modals & Overlays
- `Hds::Modal` - Modal dialogs
- `Hds::Dropdown` - Dropdown menus
- `Hds::Tooltip` - Tooltips
- `Hds::Flyout` - Flyout panels

### Content Display
- `Hds::Card` - Card containers
- `Hds::Table` - Data tables
- `Hds::Accordion` - Accordion/collapsible content

### Actions
- `Hds::Button` - Buttons
- `Hds::ButtonSet` - Button groups
- `Hds::Link::Standalone` - Standalone links
- `Hds::Link::Inline` - Inline links
- `Hds::Copy::Button` - Copy to clipboard

### Layouts
- `Hds::AppFrame` - Application frame structure
- `Hds::PageHeader` - Page headers

## Design Tokens

Tokens are CSS variables for consistent styling. Use them for custom styles outside HDS components.

### Color Tokens

**Foreground (text):**
```css
.custom-element {
  color: var(--token-color-foreground-primary);      /* Primary text */
  color: var(--token-color-foreground-strong);       /* Emphasized text */
  color: var(--token-color-foreground-faint);        /* De-emphasized text */
  color: var(--token-color-foreground-disabled);     /* Disabled text */
  color: var(--token-color-foreground-highlight);    /* Link/interactive text */
  color: var(--token-color-foreground-critical);     /* Error text */
  color: var(--token-color-foreground-success);      /* Success text */
  color: var(--token-color-foreground-warning);      /* Warning text */
}
```

**Background (surfaces):**
```css
.custom-card {
  background: var(--token-color-surface-primary);    /* Primary surface */
  background: var(--token-color-surface-secondary);  /* Secondary surface */
  background: var(--token-color-surface-tertiary);   /* Tertiary surface */
  background: var(--token-color-surface-highlight);  /* Highlighted surface */
  background: var(--token-color-surface-critical);   /* Error background */
  background: var(--token-color-surface-success);    /* Success background */
  background: var(--token-color-surface-warning);    /* Warning background */
}
```

**Borders:**
```css
.custom-box {
  border: 1px solid var(--token-color-border-primary);    /* Primary border */
  border: 1px solid var(--token-color-border-strong);     /* Strong border */
  border: 1px solid var(--token-color-border-faint);      /* Faint border */
  border: 1px solid var(--token-color-border-critical);   /* Error border */
}
```

### Typography Tokens

```css
.custom-text {
  font-family: var(--token-typography-font-stack-text);
  font-size: var(--token-typography-body-200-font-size);       /* 14px */
  line-height: var(--token-typography-body-200-line-height);   /* 20px */
  font-weight: var(--token-typography-font-weight-regular);    /* 400 */
  font-weight: var(--token-typography-font-weight-medium);     /* 500 */
  font-weight: var(--token-typography-font-weight-semibold);   /* 600 */
  font-weight: var(--token-typography-font-weight-bold);       /* 700 */
}
```

### Spacing Tokens

```css
.custom-spacing {
  padding: var(--token-spacing-050);   /* 2px */
  padding: var(--token-spacing-100);   /* 4px */
  padding: var(--token-spacing-150);   /* 6px */
  padding: var(--token-spacing-200);   /* 8px */
  padding: var(--token-spacing-300);   /* 12px */
  padding: var(--token-spacing-400);   /* 16px */
  padding: var(--token-spacing-500);   /* 24px */
  padding: var(--token-spacing-600);   /* 32px */
  padding: var(--token-spacing-800);   /* 48px */
}
```

### Border Radius Tokens

```css
.custom-card {
  border-radius: var(--token-border-radius-small);    /* 4px */
  border-radius: var(--token-border-radius-medium);   /* 8px */
  border-radius: var(--token-border-radius-large);    /* 16px */
}
```

### Elevation (Shadow) Tokens

```css
.custom-card {
  box-shadow: var(--token-elevation-low-box-shadow);     /* Subtle shadow */
  box-shadow: var(--token-elevation-mid-box-shadow);     /* Medium shadow */
  box-shadow: var(--token-elevation-high-box-shadow);    /* Strong shadow */
}
```

### Focus Ring Tokens

```css
.custom-input:focus {
  box-shadow: var(--token-focus-ring-action-box-shadow);
  outline: none;
}
```

## Typography

Helios uses system fonts for performance and internationalization.

### Type Scale

**Display** (headings):
- Display 500 (30px) - Large headings
- Display 400 (24px) - Section headings
- Display 300 (20px) - Subsection headings
- Display 200 (16px) - Small headings
- Display 100 (13px) - Smallest headings

**Body** (content):
- Body 300 (16px) - Large UI elements
- Body 200 (14px) - Default body text (most common)
- Body 100 (12px) - Secondary/supporting text

**Code** (monospace):
- Code 300, 200, 100 - Different sizes for code display

### Ember Usage

```handlebars
<Hds::Text::Display @tag="h1" @size="500">
  Page Title
</Hds::Text::Display>

<Hds::Text::Body @tag="p" @size="200">
  Body text content goes here.
</Hds::Text::Body>

<Hds::Text::Code @tag="code">
  const example = "code";
</Hds::Text::Code>
```

### React Usage

```jsx
import { Text } from '@hashicorp/react-design-system-components';

<Text.Display tag="h1" size="500">
  Page Title
</Text.Display>

<Text.Body tag="p" size="200">
  Body text content goes here.
</Text.Body>

<Text.Code tag="code">
  const example = "code";
</Text.Code>
```

## Icons

HDS uses **Flight Icons**, HashiCorp's icon system with 16px and 24px variants.

### Ember Usage

```handlebars
{{! Basic icon }}
<Hds::Icon @name="info" />

{{! Icon with size }}
<Hds::Icon @name="check-circle" @size="24" />

{{! Icon with color }}
<Hds::Icon @name="alert-triangle" @color="critical" />

{{! Icons in buttons (automatic) }}
<Hds::Button @text="Add" @icon="plus" />
```

### React Usage

```jsx
import { Icon } from '@hashicorp/react-design-system-components';

<Icon name="info" />
<Icon name="check-circle" size="24" />
<Icon name="alert-triangle" color="critical" />

<Button text="Add" icon="plus" />
```

### Common Icons

**Status:**
- `info` - Information
- `check-circle` - Success/confirmation
- `alert-triangle` - Warning
- `x-circle` - Error
- `loading` - Loading spinner

**Actions:**
- `plus` - Add/create
- `trash` - Delete
- `edit` - Edit
- `copy` - Copy
- `download` - Download
- `upload` - Upload

**Navigation:**
- `chevron-down` - Expand/dropdown
- `chevron-right` - Navigate/next
- `chevron-left` - Back
- `arrow-right` - Action/forward
- `external-link` - External link

**Interface:**
- `x` - Close
- `search` - Search
- `filter` - Filter
- `settings` - Settings
- `menu` - Menu

**Browse all icons:** https://helios.hashicorp.design/icons/library

## Common Use Cases

### Form with Validation

**Ember:**
```handlebars
<form {{on "submit" this.handleSubmit}}>
  <Hds::Form::TextInput::Field
    @value={{this.workspaceName}}
    {{on "input" this.handleNameInput}}
    @isRequired={{true}}
    as |F|
  >
    <F.Label>Workspace Name</F.Label>
    <F.HelperText>Choose a unique name for your workspace.</F.HelperText>
    {{#if this.errors.name}}
      <F.Error>{{this.errors.name}}</F.Error>
    {{/if}}
  </Hds::Form::TextInput::Field>

  <Hds::Form::Select::Field
    {{on "change" this.handleTierChange}}
    as |F|
  >
    <F.Label>Tier</F.Label>
    <F.Options>
      <option value="free">Free</option>
      <option value="team">Team</option>
      <option value="business">Business</option>
    </F.Options>
  </Hds::Form::Select::Field>

  <Hds::Form::Checkbox::Field
    {{on "change" this.handleAgreeChange}}
    as |F|
  >
    <F.Label>I agree to the terms and conditions</F.Label>
  </Hds::Form::Checkbox::Field>

  <Hds::ButtonSet>
    <Hds::Button @text="Create Workspace" type="submit" @color="primary" />
    <Hds::Button @text="Cancel" @color="secondary" {{on "click" this.cancel}} />
  </Hds::ButtonSet>
</form>
```

**React:**
```jsx
function WorkspaceForm() {
  const [name, setName] = useState('');
  const [tier, setTier] = useState('free');
  const [agreed, setAgreed] = useState(false);
  const [errors, setErrors] = useState({});

  const handleSubmit = (e) => {
    e.preventDefault();
    // validation and submission
  };

  return (
    <form onSubmit={handleSubmit}>
      <Form.TextInput.Field
        value={name}
        onChange={(e) => setName(e.target.value)}
        isRequired
      >
        <Form.Label>Workspace Name</Form.Label>
        <Form.HelperText>Choose a unique name for your workspace.</Form.HelperText>
        {errors.name && <Form.Error>{errors.name}</Form.Error>}
      </Form.TextInput.Field>

      <Form.Select.Field onChange={(e) => setTier(e.target.value)}>
        <Form.Label>Tier</Form.Label>
        <Form.Options>
          <option value="free">Free</option>
          <option value="team">Team</option>
          <option value="business">Business</option>
        </Form.Options>
      </Form.Select.Field>

      <Form.Checkbox.Field
        checked={agreed}
        onChange={(e) => setAgreed(e.target.checked)}
      >
        <Form.Label>I agree to the terms and conditions</Form.Label>
      </Form.Checkbox.Field>

      <ButtonSet>
        <Button text="Create Workspace" type="submit" color="primary" />
        <Button text="Cancel" color="secondary" onClick={handleCancel} />
      </ButtonSet>
    </form>
  );
}
```

### Status Display with Badges

**Ember:**
```handlebars
{{#if (eq @run.status "applied")}}
  <Hds::Badge @text="Applied" @color="success" @icon="check-circle" />
{{else if (eq @run.status "errored")}}
  <Hds::Badge @text="Errored" @color="critical" @icon="x-circle" />
{{else if (eq @run.status "running")}}
  <Hds::Badge @text="Running" @color="neutral" @icon="loading" />
{{else if (eq @run.status "planned")}}
  <Hds::Badge @text="Planned" @color="highlight" />
{{/if}}
```

**React:**
```jsx
function RunStatus({ status }) {
  const statusConfig = {
    applied: { text: 'Applied', color: 'success', icon: 'check-circle' },
    errored: { text: 'Errored', color: 'critical', icon: 'x-circle' },
    running: { text: 'Running', color: 'neutral', icon: 'loading' },
    planned: { text: 'Planned', color: 'highlight' },
  };

  const config = statusConfig[status] || {};

  return <Badge text={config.text} color={config.color} icon={config.icon} />;
}
```

### Page Navigation

**Ember:**
```handlebars
<Hds::Breadcrumb>
  <Hds::Breadcrumb::Item @text="Organizations" @route="organizations" />
  <Hds::Breadcrumb::Item
    @text={{@organization.name}}
    @route="organization"
    @model={{@organization.id}}
  />
  <Hds::Breadcrumb::Item @text="Workspaces" @current={{true}} />
</Hds::Breadcrumb>
```

**React:**
```jsx
function Navigation({ organization }) {
  return (
    <Breadcrumb>
      <Breadcrumb.Item text="Organizations" href="/organizations" />
      <Breadcrumb.Item
        text={organization.name}
        href={`/organizations/${organization.id}`}
      />
      <Breadcrumb.Item text="Workspaces" current />
    </Breadcrumb>
  );
}
```

## Patterns

HDS provides patterns for common UX scenarios:

### Button Organization

**Guidelines:**
- Primary action on the right, secondary on the left (in LTR languages)
- Use `ButtonSet` for proper spacing and alignment
- Maximum 2-3 buttons per action group
- Destructive actions use `@color="critical"`

**Example:**
```handlebars
<Hds::ButtonSet>
  <Hds::Button @text="Cancel" @color="secondary" {{on "click" this.cancel}} />
  <Hds::Button @text="Save" @color="primary" {{on "click" this.save}} />
</Hds::ButtonSet>

<Hds::ButtonSet>
  <Hds::Button @text="Cancel" @color="secondary" />
  <Hds::Button @text="Delete" @color="critical" />
</Hds::ButtonSet>
```

### Form Patterns

**Best practices:**
- Always provide labels (required for accessibility)
- Use helper text to provide context
- Show errors inline, associated with fields
- Group related fields together
- Use appropriate field types (text, email, password, etc.)

### Filter Patterns

**Using dropdown:**
```handlebars
<Hds::Dropdown @isOpen={{this.isFilterOpen}} @onClose={{this.closeFilter}}>
  <:toggle>
    <Hds::Button @text="Filter" @icon="filter" />
  </:toggle>
  <:content as |dd|>
    <dd.Interactive @text="Status: Active" {{on "click" this.filterActive}} />
    <dd.Interactive @text="Status: Archived" {{on "click" this.filterArchived}} />
  </:content>
</Hds::Dropdown>

{{! Show active filters }}
{{#each this.activeFilters as |filter|}}
  <Hds::Tag @text={{filter.label}} @onDismiss={{fn this.removeFilter filter}} />
{{/each}}
```

## Accessibility

All HDS components are built to **WCAG 2.2 AA conformance** by default.

### Built-in Features

- ✅ Semantic HTML
- ✅ Proper ARIA attributes
- ✅ Keyboard navigation
- ✅ Focus management
- ✅ Color contrast compliance
- ✅ Screen reader support

### Best Practices

**Always provide labels:**
```handlebars
{{! Good }}
<Hds::Form::TextInput::Field as |F|>
  <F.Label>Email address</F.Label>
</Hds::Form::TextInput::Field>

{{! Bad - missing label (fails accessibility) }}
<input type="email" placeholder="Email" />
```

**Use semantic elements:**
```handlebars
{{! Good - button for actions }}
<Hds::Button @text="Delete" {{on "click" this.delete}} />

{{! Bad - div with click handler (not keyboard accessible) }}
<div {{on "click" this.delete}}>Delete</div>
```

**Provide alt text:**
```handlebars
{{! For icons that convey meaning }}
<Hds::Icon @name="check-circle" aria-label="Success" />

{{! For decorative icons }}
<Hds::Icon @name="check-circle" aria-hidden="true" />
```

### Testing Accessibility

1. **Keyboard navigation:** Tab through interface, ensure all interactive elements reachable
2. **Screen reader:** Test with VoiceOver (Mac) or NVDA (Windows)
3. **Color contrast:** Use browser DevTools to check contrast ratios
4. **Focus indicators:** Verify focus rings visible on all interactive elements

## Troubleshooting

### Component Not Rendering

**Ember:**
1. Check package installed: `pnpm list @hashicorp/design-system-components`
2. Verify using `Hds::` namespace
3. Check required props (e.g., Button needs `@text` or block content)

**React:**
1. Check package installed: `npm list @hashicorp/react-design-system-components`
2. Verify import statement
3. Check prop names (camelCase in React vs kebab-case in Ember)

### Styling Issues

1. **Check CSS import:** Verify styles imported in main stylesheet
2. **Check box-sizing reset:** Global reset may be missing
3. **Check token usage:** Ensure correct `--token-` prefix

### TypeScript/Glint Errors (Ember)

1. Regenerate types: `pnpm build`
2. Import component signatures if needed:
   ```typescript
   import type { HdsButtonSignature } from '@hashicorp/design-system-components/components/hds/button';
   ```

## Best Practices

### Do's

✅ Use HDS components instead of building custom UI
✅ Use design tokens for custom styles
✅ Follow documented patterns for common scenarios
✅ Test with keyboard navigation
✅ Provide labels and helper text for all inputs
✅ Use appropriate colors (critical for errors, success for confirmations)
✅ Check Helios docs before building custom solutions

### Don'ts

❌ Don't build custom buttons/inputs when HDS components exist
❌ Don't hardcode colors - use tokens or HDS components
❌ Don't skip labels on form inputs (accessibility issue)
❌ Don't use divs with click handlers - use buttons
❌ Don't override HDS styles without good reason
❌ Don't mix different versions of HDS

## HashiCorp Product Usage

### Terraform Cloud/Enterprise (Ember)

Primary HDS consumer, uses most components:
- Full application UI built with HDS
- Custom patterns for runs, workspaces, variables
- Extensive form usage

### HCP Console (Ember)

Uses HDS for consistent platform experience:
- Shared navigation components
- Service-specific pages with HDS patterns

### Consul UI (Ember)

Service mesh visualization with HDS:
- Tables for service catalog
- Forms for configuration
- Status badges for health checks

### Marketing Site (React)

React components for marketing pages:
- Buttons and CTAs
- Forms for lead capture
- Navigation components

### Developer Portal (React)

Documentation site using React HDS:
- Code blocks with HDS styling
- Navigation and breadcrumbs
- Search interface

## Getting Help

- **Helios Documentation**: https://helios.hashicorp.design
- **Slack**: #team-design-systems (internal HashiCorp)
- **GitHub**: `@hashicorp/design-system-components` repo
- **Component Showcase**: https://helios.hashicorp.design/components

## Additional Resources

- **Foundations**: https://helios.hashicorp.design/foundations
- **Components**: https://helios.hashicorp.design/components
- **Patterns**: https://helios.hashicorp.design/patterns
- **Icons Library**: https://helios.hashicorp.design/icons/library
- **Design Tokens**: https://helios.hashicorp.design/foundations/tokens
- **Accessibility Guidelines**: https://helios.hashicorp.design/about/accessibility

## Summary

**Quick Start (Ember):**
```bash
# Install
pnpm add @hashicorp/design-system-components

# Import styles
# In app/styles/app.scss:
@use "@hashicorp/design-system-components";

# Use components
<Hds::Button @text="Click me" @color="primary" />
```

**Quick Start (React):**
```bash
# Install
npm install @hashicorp/react-design-system-components

# Import styles
import '@hashicorp/react-design-system-components/dist/styles/index.css';

# Use components
<Button text="Click me" color="primary" />
```

**Most Used Components:**
- `Hds::Button` - Primary actions
- `Hds::Form::*` - All form inputs
- `Hds::Alert` - Success/error messages
- `Hds::Badge` - Status indicators
- `Hds::Modal` - Dialogs and confirmations
- `Hds::Table` - Data display

**Common Patterns:**
- Forms with validation
- Status badges
- Action buttons (primary + secondary)
- Confirmation modals
- Breadcrumb navigation
- Filter interfaces

**Remember:**
- HDS components are accessible by default (WCAG 2.2 AA)
- Always provide labels for form inputs
- Use design tokens for custom styling
- Check Helios docs before building custom components
- Test with keyboard navigation
- Use semantic HTML (buttons for actions, links for navigation)
- HashiCorp uses Ember.js (primary) and React (secondary)
