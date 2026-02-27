# HDS Components Reference

This file provides a comprehensive catalog of all Helios Design System components available for use in Atlas.

## Interactive Elements

### Button
**Description:** An interactive element that initiates an action.
**Use for:** Primary user interactions and calls-to-action.
**Component:** `<Hds::Button>`

**Props:**
- `@text` - Button label text
- `@color` - "primary", "secondary", "tertiary", "critical"
- `@size` - "small", "medium", "large"
- `@icon` - Icon name
- `@iconPosition` - "leading" or "trailing"

**Example:**
```handlebars
<Hds::Button @text="Create Workspace" @color="primary" @icon="plus" />
<Hds::Button @text="Cancel" @color="secondary" />
<Hds::Button @text="Delete" @color="critical" @icon="trash" />
```

### Button Set
**Description:** Groups multiple buttons with consistent spacing and layout.
**Use for:** Related actions that should appear together.
**Component:** `<Hds::ButtonSet>`

**Example:**
```handlebars
<Hds::ButtonSet>
  <Hds::Button @text="Save" @color="primary" type="submit" />
  <Hds::Button @text="Cancel" @color="secondary" {{on "click" this.cancel}} />
</Hds::ButtonSet>
```

### Link
**Description:** Navigation elements.
**Types:** Inline (within text) and Standalone (independent).
**Components:** `<Hds::Link::Inline>`, `<Hds::Link::Standalone>`

**Example:**
```handlebars
<Hds::Link::Standalone @text="View Documentation" @href="/docs" @icon="arrow-right" />
<Hds::Link::Inline @route="workspace.settings">settings</Hds::Link::Inline>
```

## Data Display

### Badge
**Description:** Non-interactive metadata labels.
**Use for:** Status indicators, categories, tags.
**Component:** `<Hds::Badge>`

**Props:**
- `@text` - Badge text
- `@color` - "neutral", "highlight", "success", "warning", "critical"
- `@type` - "filled", "inverted", "outlined"
- `@size` - "small", "medium", "large"
- `@icon` - Icon name

**Example:**
```handlebars
<Hds::Badge @text="Applied" @color="success" @icon="check-circle" />
<Hds::Badge @text="Pending" @color="neutral" />
<Hds::Badge @text="Error" @color="critical" @icon="x-circle" />
```

### Badge Count
**Description:** Numeric labels for counts.
**Use for:** Notifications, item counts.
**Component:** `<Hds::BadgeCount>`

**Example:**
```handlebars
<Hds::BadgeCount @text="5" @color="neutral" />
```

### Text
**Description:** Applies typography styles.
**Use for:** Maintaining design consistency.
**Component:** `<Hds::Text>`

**Types:**
- `<Hds::Text::Display>` - Headings (sizes 100-500)
- `<Hds::Text::Body>` - Body text (sizes 100-300)
- `<Hds::Text::Code>` - Code snippets (sizes 100-300)

**Example:**
```handlebars
<Hds::Text::Display @tag="h1" @size="500">Page Title</Hds::Text::Display>
<Hds::Text::Body @tag="p" @size="200">Body content here.</Hds::Text::Body>
<Hds::Text::Code @tag="code">const foo = "bar";</Hds::Text::Code>
```

### Time
**Description:** Formats dates and times uniformly.
**Component:** `<Hds::Time>`

## Feedback & Messaging

### Alert
**Description:** Brief messages that don't interrupt user tasks.
**Use for:** System notifications, confirmations, warnings.
**Component:** `<Hds::Alert>`

**Props:**
- `@type` - "page", "inline", "compact"
- `@color` - "neutral", "highlight", "success", "warning", "critical"

**Example:**
```handlebars
<Hds::Alert @type="inline" @color="success" as |A|>
  <A.Title>Success!</A.Title>
  <A.Description>Your workspace has been created.</A.Description>
</Hds::Alert>

<Hds::Alert @type="inline" @color="critical" as |A|>
  <A.Title>Error</A.Title>
  <A.Description>Failed to save changes.</A.Description>
  <A.Button @text="Retry" @color="secondary" />
</Hds::Alert>
```

### Toast
**Description:** Displays action results without blocking workflow.
**Use for:** Non-critical feedback that appears temporarily.
**Component:** `<Hds::Toast>`

### Tooltip
**Description:** Brief contextual information.
**Use for:** Explaining icons, disabled states, or providing help text.
**Component:** `<Hds::Tooltip>`

**Example:**
```handlebars
<Hds::Tooltip @text="This action cannot be undone">
  <Hds::Button @icon="trash" @color="critical" />
</Hds::Tooltip>
```

### Rich Tooltip
**Description:** Structured, detailed information.
**Use for:** More complex contextual help.
**Component:** `<Hds::RichTooltip>`

## Form Components

### Text Input
**Description:** Basic data entry field.
**Component:** `<Hds::Form::TextInput::Field>`

**Example:**
```handlebars
<Hds::Form::TextInput::Field
  @type="text"
  @value={{this.name}}
  {{on "input" this.handleInput}}
  as |F|
>
  <F.Label>Workspace Name</F.Label>
  <F.HelperText>Choose a unique name.</F.HelperText>
  {{#if this.errors.name}}
    <F.Error>{{this.errors.name}}</F.Error>
  {{/if}}
</Hds::Form::TextInput::Field>
```

### Textarea
**Description:** Multi-line text input.
**Component:** `<Hds::Form::Textarea::Field>`

**Example:**
```handlebars
<Hds::Form::Textarea::Field
  @value={{this.description}}
  {{on "input" this.handleInput}}
  as |F|
>
  <F.Label>Description</F.Label>
  <F.HelperText>Optional description.</F.HelperText>
</Hds::Form::Textarea::Field>
```

### Checkbox
**Description:** Multiple-selection form element.
**Component:** `<Hds::Form::Checkbox::Field>`

**Example:**
```handlebars
<Hds::Form::Checkbox::Field
  checked={{this.autoApply}}
  {{on "change" this.handleChange}}
  as |F|
>
  <F.Label>Auto-apply runs</F.Label>
</Hds::Form::Checkbox::Field>
```

### Radio
**Description:** Single-selection from grouped options.
**Component:** `<Hds::Form::Radio::Field>`

**Example:**
```handlebars
<Hds::Form::Radio::Group as |G|>
  <G.Legend>Execution Mode</G.Legend>
  <G.HelperText>Choose how runs are executed.</G.HelperText>

  <G.RadioField @value="remote" checked={{eq this.mode "remote"}} as |F|>
    <F.Label>Remote</F.Label>
  </G.RadioField>

  <G.RadioField @value="local" checked={{eq this.mode "local"}} as |F|>
    <F.Label>Local</F.Label>
  </G.RadioField>
</Hds::Form::Radio::Group>
```

### Toggle
**Description:** Binary state selector (on/off).
**Component:** `<Hds::Form::Toggle::Field>`

**Example:**
```handlebars
<Hds::Form::Toggle::Field
  checked={{this.enabled}}
  {{on "change" this.handleToggle}}
  as |F|
>
  <F.Label>Enable notifications</F.Label>
</Hds::Form::Toggle::Field>
```

### Select
**Description:** Dropdown selection.
**Component:** `<Hds::Form::Select::Field>`

**Example:**
```handlebars
<Hds::Form::Select::Field
  @value={{this.vcsProvider}}
  {{on "change" this.handleSelect}}
  as |F|
>
  <F.Label>VCS Provider</F.Label>
  <F.Options>
    <option value="">Select a provider</option>
    <option value="github">GitHub</option>
    <option value="gitlab">GitLab</option>
    <option value="bitbucket">Bitbucket</option>
  </F.Options>
</Hds::Form::Select::Field>
```

### File Input
**Description:** Enables file uploads.
**Component:** `<Hds::Form::FileInput::Field>`

### Masked Input
**Description:** Obscures sensitive data entry.
**Component:** `<Hds::Form::MaskedInput::Field>`

**Use for:** Passwords, API tokens, sensitive data.

## Navigation Components

### App Header
**Description:** Global and utility navigation.
**Component:** `<Hds::AppHeader>`

### App Side Nav
**Description:** Primary sidebar menu.
**Component:** `<Hds::AppSideNav>`

### Breadcrumb
**Description:** Shows hierarchical location.
**Component:** `<Hds::Breadcrumb>`

**Example:**
```handlebars
<Hds::Breadcrumb>
  <Hds::Breadcrumb::Item @text="Organizations" @route="organizations" />
  <Hds::Breadcrumb::Item @text={{@organization.name}} @route="organization" />
  <Hds::Breadcrumb::Item @text="Workspaces" @current={{true}} />
</Hds::Breadcrumb>
```

### Tabs
**Description:** Switches between views.
**Component:** `<Hds::Tabs>`

**Example:**
```handlebars
<Hds::Tabs as |T|>
  <T.Tab>Overview</T.Tab>
  <T.Tab>Settings</T.Tab>
  <T.Tab>Runs</T.Tab>

  <T.Panel>Overview content</T.Panel>
  <T.Panel>Settings content</T.Panel>
  <T.Panel>Runs content</T.Panel>
</Hds::Tabs>
```

### Pagination
**Description:** Navigate through paginated content.
**Component:** `<Hds::Pagination>`

## Content Organization

### Card
**Description:** Block container with elevation and styling.
**Component:** `<Hds::Card>`

**Example:**
```handlebars
<Hds::Card as |C|>
  <C.Header>
    <h3>Workspace Details</h3>
  </C.Header>
  <C.Body>
    <p>Content goes here</p>
  </C.Body>
  <C.Footer>
    <Hds::ButtonSet>
      <Hds::Button @text="Edit" />
    </Hds::ButtonSet>
  </C.Footer>
</Hds::Card>
```

### Accordion
**Description:** Toggleable list items.
**Component:** `<Hds::Accordion>`

### Modal
**Description:** Pop-up window for important information.
**Component:** `<Hds::Modal>`

**Example:**
```handlebars
<Hds::Modal
  @onClose={{this.closeModal}}
  as |M|
>
  <M.Header>
    Confirm Deletion
  </M.Header>
  <M.Body>
    <p>Are you sure you want to delete this workspace?</p>
  </M.Body>
  <M.Footer as |F|>
    <Hds::ButtonSet>
      <Hds::Button @text="Delete" @color="critical" {{on "click" this.confirm}} />
      <Hds::Button @text="Cancel" @color="secondary" {{on "click" this.closeModal}} />
    </Hds::ButtonSet>
  </M.Footer>
</Hds::Modal>
```

### Flyout
**Description:** Overlaid panel with additional details.
**Component:** `<Hds::Flyout>`

### Table
**Description:** Tabular data display.
**Component:** `<Hds::Table>`

**Example:**
```handlebars
<Hds::Table as |T|>
  <T.Head>
    <T.HeadCell>Name</T.HeadCell>
    <T.HeadCell>Status</T.HeadCell>
    <T.HeadCell>Actions</T.HeadCell>
  </T.Head>
  <T.Body>
    {{#each @workspaces as |workspace|}}
      <T.Row>
        <T.Cell>{{workspace.name}}</T.Cell>
        <T.Cell><Hds::Badge @text={{workspace.status}} /></T.Cell>
        <T.Cell>
          <Hds::Button @text="View" @size="small" />
        </T.Cell>
      </T.Row>
    {{/each}}
  </T.Body>
</Hds::Table>
```

### Page Header
**Description:** Page title and metadata.
**Component:** `<Hds::PageHeader>`

## Specialized Components

### Code Block
**Description:** Displays code with syntax highlighting.
**Component:** `<Hds::CodeBlock>`

**Example:**
```handlebars
<Hds::CodeBlock @language="hcl" @value={{this.terraformCode}} />
```

### Copy Button
**Description:** Copies text to clipboard.
**Component:** `<Hds::Copy::Button>`

**Example:**
```handlebars
<Hds::Copy::Button @text="Copy to clipboard" @textToCopy={{this.apiToken}} />
```

### Icon
**Description:** Displays icons consistently.
**Component:** `<Hds::Icon>`

**Example:**
```handlebars
<Hds::Icon @name="info" />
<Hds::Icon @name="check-circle" @size="24" />
<Hds::Icon @name="alert-triangle" @color="critical" />
```

### Tag
**Description:** Categorization indicators.
**Component:** `<Hds::Tag>`

**Example:**
```handlebars
<Hds::Tag @text="Production" @color="highlight" @onDismiss={{this.removeTag}} />
```

### Dropdown
**Description:** Shows/hides action lists.
**Component:** `<Hds::Dropdown>`

**Example:**
```handlebars
<Hds::Dropdown as |D|>
  <D.ToggleIcon @icon="more-horizontal" @text="Actions" />
  <D.Interactive @text="Edit" @icon="edit" {{on "click" this.edit}} />
  <D.Interactive @text="Delete" @icon="trash" @color="critical" {{on "click" this.delete}} />
</Hds::Dropdown>
```

### Reveal
**Description:** Toggle that exposes additional content.
**Component:** `<Hds::Reveal>`

### Separator
**Description:** Visual breaks between content.
**Component:** `<Hds::Separator>`

### Stepper
**Description:** Multi-step process guidance.
**Components:** `<Hds::Stepper::Indicator>`, `<Hds::Stepper::Step>`

## Layout Components

### AppFrame
**Description:** Top-level application container.
**Component:** `<Hds::AppFrame>`

### Flex
**Description:** Flexbox-based layout.
**Component:** `<Hds::Flex>`

### Grid
**Description:** Grid-based layout.
**Component:** `<Hds::Grid>`

## Best Practices

1. **Use semantic components** - Choose components that match your use case semantically (buttons for actions, links for navigation)
2. **Follow form patterns** - Always use Field components for forms (automatic labels, errors, helper text)
3. **Maintain hierarchy** - Use appropriate heading levels with Text::Display
4. **Provide feedback** - Use Alerts/Toasts for user actions
5. **Be accessible** - HDS components are accessible by default, don't remove or override accessibility features

## Component Documentation

For detailed documentation on each component, including all props, variants, and examples:
https://helios.hashicorp.design/components
