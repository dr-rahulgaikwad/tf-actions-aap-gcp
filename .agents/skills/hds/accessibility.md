# HDS Accessibility (a11y) Guide

All HDS components are built to **WCAG 2.2 AA conformance** by default. This guide helps you maintain accessibility when building with HDS.

## Core Principles

### 1. Perceivable
Users must be able to perceive the information being presented.
- **Provide text alternatives** for non-text content
- **Provide captions and alternatives** for multimedia
- **Create content that can be presented differently** without losing meaning
- **Make it easier to see and hear content**

### 2. Operable
Users must be able to operate the interface.
- **Make all functionality keyboard accessible**
- **Give users enough time** to read and use content
- **Don't cause seizures** with flashing content
- **Help users navigate and find content**

### 3. Understandable
Users must be able to understand the information and interface.
- **Make text readable and understandable**
- **Make content appear and operate predictably**
- **Help users avoid and correct mistakes**

### 4. Robust
Content must be robust enough to work with assistive technologies.
- **Maximize compatibility** with current and future user tools

## Helios Design Principles for Accessibility

### Consider Everyone
"We take an inclusive approach from the start, considering the context and range of abilities for all customers."

This means:
- Design for diverse abilities (vision, motor, cognitive, hearing)
- Test with assistive technologies (screen readers, keyboard navigation)
- Provide multiple ways to accomplish tasks
- Don't rely solely on color to convey information

## HDS Components and Accessibility

All HDS components include built-in accessibility features:

### Semantic HTML
```handlebars
{{! ✅ HDS uses semantic elements }}
<Hds::Button @text="Submit" type="submit" />
{{! Renders as: <button type="submit">Submit</button> }}

{{! ❌ Don't use divs as buttons }}
<div {{on "click" this.submit}}>Submit</div>
```

### ARIA Attributes
HDS components automatically include appropriate ARIA attributes:
- `aria-label` for icon-only buttons
- `aria-describedby` for helper text associations
- `aria-expanded` for toggles/dropdowns
- `aria-invalid` for error states
- `role` attributes where needed

### Keyboard Navigation
All interactive HDS components support:
- **Tab** to navigate between elements
- **Enter/Space** to activate buttons/links
- **Arrow keys** for dropdowns, radio groups
- **Escape** to close modals/dropdowns

### Focus Management
HDS components provide visible focus indicators:
```css
/* Automatically applied */
.hds-button:focus {
  box-shadow: var(--token-focus-ring-action-box-shadow);
}
```

## Common Accessibility Patterns

### Forms

#### Always Provide Labels

```handlebars
{{! ✅ CORRECT - Visible label }}
<Hds::Form::TextInput::Field
  @value={{this.name}}
  as |F|
>
  <F.Label>Workspace Name</F.Label>
</Hds::Form::TextInput::Field>

{{! ❌ INCORRECT - No label }}
<input
  type="text"
  value={{this.name}}
  placeholder="Workspace Name"
/>
```

#### Provide Helper Text

```handlebars
<Hds::Form::TextInput::Field as |F|>
  <F.Label>API Token</F.Label>
  <F.HelperText>
    This token will have full access to your organization.
  </F.HelperText>
</Hds::Form::TextInput::Field>
```

#### Associate Errors with Fields

```handlebars
<Hds::Form::TextInput::Field as |F|>
  <F.Label>Email</F.Label>
  {{#if this.errors.email}}
    <F.Error>{{this.errors.email}}</F.Error>
  {{/if}}
</Hds::Form::TextInput::Field>
```

The Field component automatically:
- Associates label with input (`for`/`id`)
- Associates error with input (`aria-describedby`, `aria-invalid`)
- Associates helper text with input

#### Mark Required Fields

```handlebars
<Hds::Form::TextInput::Field
  @isRequired={{true}}
  as |F|
>
  <F.Label>Organization Name</F.Label>
</Hds::Form::TextInput::Field>
```

### Buttons

#### Provide Text for Icon Buttons

```handlebars
{{! ✅ CORRECT - Text provided }}
<Hds::Button @icon="trash" @text="Delete" @color="critical" />

{{! ✅ CORRECT - Icon-only with aria-label }}
<Hds::Button @icon="x" @isIconOnly={{true}} aria-label="Close dialog" />

{{! ❌ INCORRECT - Icon only, no text or label }}
<button {{on "click" this.close}}>
  <Hds::Icon @name="x" />
</button>
```

#### Use Semantic Button Types

```handlebars
{{! Use type="submit" for form submission }}
<Hds::Button @text="Create" @color="primary" type="submit" />

{{! Use type="button" (default) for other actions }}
<Hds::Button @text="Cancel" @color="secondary" type="button" />
```

#### Disable vs. Hide

```handlebars
{{! If user might gain permission, show disabled with explanation }}
<Hds::Button
  @text="Delete Workspace"
  @isDisabled={{not this.canDelete}}
/>
{{#if (not this.canDelete)}}
  <Hds::Tooltip @text="Only owners can delete workspaces">
    <Hds::Icon @name="info" />
  </Hds::Tooltip>
{{/if}}

{{! If user will never have permission, hide entirely }}
{{#if this.canAccessAdminPanel}}
  <Hds::Button @text="Admin Panel" />
{{/if}}
```

### Links

#### Use Descriptive Link Text

```handlebars
{{! ✅ CORRECT - Descriptive }}
<Hds::Link::Standalone @route="documentation">
  View complete documentation
</Hds::Link::Standalone>

{{! ❌ INCORRECT - Generic }}
<Hds::Link::Standalone @route="documentation">
  Click here
</Hds::Link::Standalone>
```

#### Links vs. Buttons

```handlebars
{{! Use links for navigation }}
<Hds::Link::Standalone @route="workspace.settings">
  Settings
</Hds::Link::Standalone>

{{! Use buttons for actions }}
<Hds::Button @text="Save Changes" {{on "click" this.save}} />
```

### Images and Icons

#### Provide Alt Text for Images

```handlebars
{{! ✅ CORRECT - Descriptive alt text }}
<img src="/logo.png" alt="HashiCorp Terraform logo" />

{{! ✅ CORRECT - Decorative image }}
<img src="/decoration.png" alt="" />

{{! ❌ INCORRECT - Missing alt }}
<img src="/logo.png" />
```

#### Icons with Text

```handlebars
{{! Icons with adjacent text don't need labels }}
<Hds::Button @text="Delete" @icon="trash" />

{{! Icon-only needs label }}
<Hds::Button @icon="trash" @isIconOnly={{true}} aria-label="Delete item" />
```

### Color and Contrast

#### Don't Rely on Color Alone

```handlebars
{{! ✅ CORRECT - Icon + color + text }}
<Hds::Badge @text="Success" @color="success" @icon="check-circle" />

{{! ❌ INCORRECT - Color only }}
<span class="success-color">Success</span>
```

#### Use Semantic Colors

HDS tokens ensure proper contrast:
```css
.status {
  /* ✅ These have proper contrast */
  color: var(--token-color-foreground-success);
  background: var(--token-color-surface-success);
}
```

### Headings

#### Maintain Heading Hierarchy

```handlebars
{{! ✅ CORRECT - Sequential hierarchy }}
<Hds::Text::Display @tag="h1" @size="500">Page Title</Hds::Text::Display>
<Hds::Text::Display @tag="h2" @size="400">Section</Hds::Text::Display>
<Hds::Text::Display @tag="h3" @size="300">Subsection</Hds::Text::Display>

{{! ❌ INCORRECT - Skipped h2 }}
<Hds::Text::Display @tag="h1" @size="500">Page Title</Hds::Text::Display>
<Hds::Text::Display @tag="h3" @size="300">Section</Hds::Text::Display>
```

#### Visual Size vs. Semantic Level

You can decouple visual appearance from semantic level:
```handlebars
{{! h2 that looks like h3 }}
<Hds::Text::Display @tag="h2" @size="300">Visually Small H2</Hds::Text::Display>
```

### Modals and Dialogs

#### Focus Management

HDS Modals automatically:
- Trap focus inside the modal
- Return focus to trigger element on close
- Support Escape key to close

```handlebars
<Hds::Modal @onClose={{this.closeModal}} as |M|>
  <M.Header>Delete Workspace</M.Header>
  <M.Body>
    Are you sure? This cannot be undone.
  </M.Body>
  <M.Footer>
    <Hds::ButtonSet>
      <Hds::Button @text="Cancel" {{on "click" this.closeModal}} />
      <Hds::Button @text="Delete" @color="critical" />
    </Hds::ButtonSet>
  </M.Footer>
</Hds::Modal>
```

### Tables

#### Provide Table Headings

```handlebars
<Hds::Table as |T|>
  <T.Head>
    {{! Always include proper headings }}
    <T.HeadCell>Name</T.HeadCell>
    <T.HeadCell>Status</T.HeadCell>
    <T.HeadCell>Actions</T.HeadCell>
  </T.Head>
  <T.Body>
    {{#each @items as |item|}}
      <T.Row>
        <T.Cell>{{item.name}}</T.Cell>
        <T.Cell><Hds::Badge @text={{item.status}} /></T.Cell>
        <T.Cell>
          <Hds::Button @text="View" @size="small" />
        </T.Cell>
      </T.Row>
    {{/each}}
  </T.Body>
</Hds::Table>
```

#### Provide Table Caption

```handlebars
<Hds::Table @caption="List of workspaces in your organization" as |T|>
  {{! ... }}
</Hds::Table>
```

### Loading States

#### Provide Loading Feedback

```handlebars
{{#if this.isLoading}}
  <Hds::ApplicationState @media="/loading.svg">
    <:title>Loading workspaces...</:title>
  </Hds::ApplicationState>
{{else}}
  {{! Content }}
{{/if}}
```

#### Use aria-live for Dynamic Updates

```handlebars
<div aria-live="polite" aria-atomic="true">
  {{#if this.saveSuccess}}
    <Hds::Alert @color="success" as |A|>
      <A.Title>Changes saved</A.Title>
    </Hds::Alert>
  {{/if}}
</div>
```

## Testing Accessibility

### Keyboard Testing

Test all interactions with keyboard only:

1. **Tab navigation** - Can you reach all interactive elements?
2. **Enter/Space** - Do buttons and links activate?
3. **Arrow keys** - Do dropdowns and radio groups work?
4. **Escape** - Do modals and dropdowns close?
5. **Focus visible** - Can you always see where focus is?

### Screen Reader Testing

Test with screen readers:
- **macOS**: VoiceOver (Cmd+F5)
- **Windows**: NVDA (free) or JAWS
- **iOS**: VoiceOver (Settings → Accessibility)
- **Android**: TalkBack (Settings → Accessibility)

Check:
- All content is announced
- Form labels are read with inputs
- Errors are announced
- Button purposes are clear
- Heading levels make sense

### Automated Testing

Use automated tools to catch common issues:
- **ember-a11y-testing** (already in Atlas)
- **axe DevTools** browser extension
- **Lighthouse** accessibility audit

```javascript
// In Ember acceptance tests
import a11yAudit from 'ember-a11y-testing/test-support/audit';

test('workspace page is accessible', async function(assert) {
  await visit('/workspaces');
  await a11yAudit();
  assert.ok(true, 'no a11y violations');
});
```

## Common Mistakes to Avoid

### ❌ Missing Labels
```handlebars
{{! BAD }}
<input type="text" placeholder="Name" />

{{! GOOD }}
<Hds::Form::TextInput::Field as |F|>
  <F.Label>Name</F.Label>
</Hds::Form::TextInput::Field>
```

### ❌ Divs as Buttons
```handlebars
{{! BAD }}
<div {{on "click" this.save}} class="button">Save</div>

{{! GOOD }}
<Hds::Button @text="Save" {{on "click" this.save}} />
```

### ❌ Icon-Only with No Label
```handlebars
{{! BAD }}
<button>
  <Hds::Icon @name="trash" />
</button>

{{! GOOD }}
<Hds::Button @icon="trash" @text="Delete" />
{{! OR }}
<Hds::Button @icon="trash" @isIconOnly={{true}} aria-label="Delete" />
```

### ❌ Color as Only Indicator
```handlebars
{{! BAD }}
<span class="text-red">Error</span>

{{! GOOD }}
<Hds::Badge @text="Error" @color="critical" @icon="x-circle" />
```

### ❌ Low Contrast Text
```handlebars
{{! BAD }}
<p style="color: #999; background: #fff;">Hard to read</p>

{{! GOOD - Use tokens }}
<p style="color: var(--token-color-foreground-faint);">Readable</p>
```

### ❌ Skip Heading Levels
```handlebars
{{! BAD }}
<h1>Title</h1>
<h3>Section</h3>

{{! GOOD }}
<h1>Title</h1>
<h2>Section</h2>
```

### ❌ No Focus Indicator
```css
/* BAD */
button:focus {
  outline: none; /* Never do this without replacement */
}

/* GOOD - HDS provides this automatically */
.hds-button:focus {
  box-shadow: var(--token-focus-ring-action-box-shadow);
}
```

## Resources

### Documentation
- **WCAG 2.2 Guidelines**: https://www.w3.org/WAI/WCAG22/quickref/
- **HDS Accessibility**: https://helios.hashicorp.design/about/accessibility
- **WebAIM**: https://webaim.org/

### Tools
- **axe DevTools**: Browser extension for accessibility testing
- **WAVE**: Web accessibility evaluation tool
- **Color Contrast Checker**: https://webaim.org/resources/contrastchecker/

### Testing
- **ember-a11y-testing**: Automated accessibility testing in Ember
- **Lighthouse**: Built into Chrome DevTools
- **Screen readers**: VoiceOver (Mac), NVDA (Windows), TalkBack (Android)

### HashiCorp
- **#team-design-systems**: Slack channel for HDS questions
- **Accessibility office hours**: Check team calendar

## Summary

**Key Takeaways:**
1. ✅ Use HDS components - they're accessible by default
2. ✅ Always provide labels for form inputs
3. ✅ Use semantic HTML (buttons, not divs)
4. ✅ Don't rely on color alone
5. ✅ Test with keyboard navigation
6. ✅ Test with screen readers
7. ✅ Maintain heading hierarchy
8. ✅ Provide text alternatives for images
9. ✅ Use focus indicators (don't remove outlines)
10. ✅ Associate errors with form fields

Accessibility is not optional - it's a legal and ethical requirement. HDS makes it easy to build accessible UIs by providing compliant components out of the box.
