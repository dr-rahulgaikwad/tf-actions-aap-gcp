# HDS Patterns Guide

Patterns are solutions for common UX challenges built by combining HDS components. Use these patterns to solve recurring design problems consistently.

## Button Organization

**Purpose:** Guidelines for aligning, ordering, and grouping buttons.

### Primary Action Placement

**Rule:** Primary action on the right, secondary on left.

```handlebars
{{! ✅ CORRECT }}
<Hds::ButtonSet>
  <Hds::Button @text="Cancel" @color="secondary" />
  <Hds::Button @text="Save" @color="primary" type="submit" />
</Hds::ButtonSet>

{{! ❌ INCORRECT }}
<Hds::ButtonSet>
  <Hds::Button @text="Save" @color="primary" />
  <Hds::Button @text="Cancel" @color="secondary" />
</Hds::ButtonSet>
```

### Button Hierarchy

Use `@color` to establish visual hierarchy:

1. **Primary** - Main action (create, save, submit)
2. **Secondary** - Alternative action (cancel, back)
3. **Tertiary** - Lowest priority (dismiss, skip)
4. **Critical** - Destructive action (delete, remove)

```handlebars
<Hds::ButtonSet>
  <Hds::Button @text="Back" @color="tertiary" />
  <Hds::Button @text="Skip" @color="secondary" />
  <Hds::Button @text="Continue" @color="primary" />
</Hds::ButtonSet>
```

### Destructive Actions

Always use `@color="critical"` for destructive actions:

```handlebars
<Hds::Modal as |M|>
  <M.Header>Delete Workspace</M.Header>
  <M.Body>
    This action cannot be undone.
  </M.Body>
  <M.Footer>
    <Hds::ButtonSet>
      <Hds::Button @text="Cancel" @color="secondary" />
      <Hds::Button @text="Delete" @color="critical" />
    </Hds::ButtonSet>
  </M.Footer>
</Hds::Modal>
```

### Grouping Related Buttons

Use `<Hds::ButtonSet>` for related actions:

```handlebars
{{! Form actions }}
<Hds::ButtonSet>
  <Hds::Button @text="Cancel" @color="secondary" />
  <Hds::Button @text="Save Draft" @color="secondary" />
  <Hds::Button @text="Publish" @color="primary" />
</Hds::ButtonSet>
```

## Filter Patterns

**Purpose:** Guidelines for filtering datasets using HDS components.

### Basic Filtering

Use Form::Select or Dropdown components:

```handlebars
<div class="filters">
  <Hds::Form::Select::Field @value={{this.status}} as |F|>
    <F.Label>Status</F.Label>
    <F.Options>
      <option value="">All</option>
      <option value="pending">Pending</option>
      <option value="running">Running</option>
      <option value="completed">Completed</option>
    </F.Options>
  </Hds::Form::Select::Field>
</div>
```

### Active Filter Display

Show active filters with dismissible Tags:

```handlebars
<div class="active-filters">
  {{#if this.filters.status}}
    <Hds::Tag
      @text="Status: {{this.filters.status}}"
      @onDismiss={{fn this.clearFilter "status"}}
    />
  {{/if}}

  {{#if this.filters.organization}}
    <Hds::Tag
      @text="Org: {{this.filters.organization}}"
      @onDismiss={{fn this.clearFilter "organization"}}
    />
  {{/if}}
</div>
```

### Clear All Filters

Provide a way to clear all filters at once:

```handlebars
<div class="filter-actions">
  <Hds::Button
    @text="Clear all filters"
    @color="tertiary"
    @size="small"
    {{on "click" this.clearAllFilters}}
  />
</div>
```

### Filter Pattern Example

```handlebars
<div class="filtering-interface">
  {{! Filter controls }}
  <div class="filter-controls">
    <Hds::Form::Select::Field @value={{this.statusFilter}} as |F|>
      <F.Label>Status</F.Label>
      <F.Options>
        <option value="">All statuses</option>
        <option value="applied">Applied</option>
        <option value="planned">Planned</option>
        <option value="errored">Errored</option>
      </F.Options>
    </Hds::Form::Select::Field>

    <Hds::Form::TextInput::Field
      @type="search"
      @value={{this.searchQuery}}
      {{on "input" this.handleSearch}}
      as |F|
    >
      <F.Label>Search</F.Label>
    </Hds::Form::TextInput::Field>
  </div>

  {{! Active filters }}
  <div class="active-filters">
    {{#each this.activeFilters as |filter|}}
      <Hds::Tag
        @text="{{filter.label}}: {{filter.value}}"
        @onDismiss={{fn this.removeFilter filter}}
      />
    {{/each}}

    {{#if this.hasActiveFilters}}
      <Hds::Button
        @text="Clear all"
        @color="tertiary"
        @size="small"
        {{on "click" this.clearAll}}
      />
    {{/if}}
  </div>

  {{! Results count }}
  <p class="results-count">
    Showing {{this.filteredResults.length}} of {{this.totalResults}}
  </p>
</div>
```

## Form Patterns

**Purpose:** Guidelines for user-centric forms using HDS components.

### Form Structure

Use Field components for automatic structure:

```handlebars
<form {{on "submit" this.handleSubmit}}>
  {{! Always use Field components }}
  <Hds::Form::TextInput::Field
    @value={{this.name}}
    {{on "input" this.handleInput}}
    as |F|
  >
    <F.Label>Name</F.Label>
    <F.HelperText>A unique identifier</F.HelperText>
    {{#if this.errors.name}}
      <F.Error>{{this.errors.name}}</F.Error>
    {{/if}}
  </Hds::Form::TextInput::Field>

  {{! Submit buttons }}
  <Hds::ButtonSet>
    <Hds::Button @text="Cancel" @color="secondary" />
    <Hds::Button @text="Create" @color="primary" type="submit" />
  </Hds::ButtonSet>
</form>
```

### Required Fields

Mark required fields clearly:

```handlebars
<Hds::Form::TextInput::Field
  @isRequired={{true}}
  @value={{this.email}}
  as |F|
>
  <F.Label>Email</F.Label>
  <F.HelperText>We'll never share your email</F.HelperText>
</Hds::Form::TextInput::Field>
```

### Error Handling

Show errors inline and at form level:

```handlebars
{{! Form-level errors }}
{{#if this.formError}}
  <Hds::Alert @type="inline" @color="critical" as |A|>
    <A.Title>Unable to save</A.Title>
    <A.Description>{{this.formError}}</A.Description>
  </Hds::Alert>
{{/if}}

{{! Field-level errors }}
<Hds::Form::TextInput::Field as |F|>
  <F.Label>Workspace Name</F.Label>
  {{#if this.errors.name}}
    <F.Error>{{this.errors.name}}</F.Error>
  {{/if}}
</Hds::Form::TextInput::Field>
```

### Grouping Related Fields

Use fieldsets for related fields:

```handlebars
<fieldset>
  <legend>Organization Settings</legend>

  <Hds::Form::TextInput::Field as |F|>
    <F.Label>Organization Name</F.Label>
  </Hds::Form::TextInput::Field>

  <Hds::Form::TextInput::Field as |F|>
    <F.Label>Email</F.Label>
  </Hds::Form::TextInput::Field>
</fieldset>
```

### Progressive Disclosure

Show/hide fields based on selections:

```handlebars
<Hds::Form::Radio::Group as |G|>
  <G.Legend>VCS Provider</G.Legend>

  <G.RadioField @value="github" as |F|>
    <F.Label>GitHub</F.Label>
  </G.RadioField>

  <G.RadioField @value="gitlab" as |F|>
    <F.Label>GitLab</F.Label>
  </G.RadioField>
</Hds::Form::Radio::Group>

{{#if (eq this.vcsProvider "gitlab")}}
  <Hds::Form::TextInput::Field as |F|>
    <F.Label>GitLab Instance URL</F.Label>
    <F.HelperText>URL of your self-hosted GitLab</F.HelperText>
  </Hds::Form::TextInput::Field>
{{/if}}
```

## Table Multi-Select

**Purpose:** Selecting and transforming table results.

### Checkbox in First Column

```handlebars
<Hds::Table as |T|>
  <T.Head>
    <T.HeadCell>
      <Hds::Form::Checkbox
        checked={{this.allSelected}}
        {{on "change" this.toggleAll}}
      />
    </T.HeadCell>
    <T.HeadCell>Name</T.HeadCell>
    <T.HeadCell>Status</T.HeadCell>
  </T.Head>
  <T.Body>
    {{#each @workspaces as |workspace|}}
      <T.Row>
        <T.Cell>
          <Hds::Form::Checkbox
            checked={{includes this.selected workspace.id}}
            {{on "change" (fn this.toggleSelect workspace)}}
          />
        </T.Cell>
        <T.Cell>{{workspace.name}}</T.Cell>
        <T.Cell><Hds::Badge @text={{workspace.status}} /></T.Cell>
      </T.Row>
    {{/each}}
  </T.Body>
</Hds::Table>
```

### Bulk Actions Toolbar

Show toolbar when items are selected:

```handlebars
{{#if this.hasSelection}}
  <div class="bulk-actions">
    <p>{{this.selected.length}} selected</p>
    <Hds::ButtonSet>
      <Hds::Button
        @text="Archive"
        @icon="archive"
        {{on "click" this.archiveSelected}}
      />
      <Hds::Button
        @text="Delete"
        @color="critical"
        @icon="trash"
        {{on "click" this.deleteSelected}}
      />
    </Hds::ButtonSet>
  </div>
{{/if}}
```

### Select All with Pagination

Handle select all across pages:

```handlebars
{{#if this.someSelected}}
  <Hds::Alert @type="inline" @color="highlight" as |A|>
    <A.Description>
      {{this.selected.length}} items selected.
      <Hds::Link::Inline {{on "click" this.selectAll}}>
        Select all {{this.total}} items
      </Hds::Link::Inline>
    </A.Description>
  </Hds::Alert>
{{/if}}
```

## Show, Hide, and Disable

**Purpose:** Managing UI element visibility based on permissions.

### Conditional Rendering

```handlebars
{{! Show only if user has permission }}
{{#if this.canEdit}}
  <Hds::Button @text="Edit" @icon="edit" />
{{/if}}

{{! Show disabled if user lacks permission }}
<Hds::Button
  @text="Delete"
  @color="critical"
  @isDisabled={{not this.canDelete}}
/>

{{#if (not this.canDelete)}}
  <Hds::Tooltip @text="You don't have permission to delete">
    <Hds::Icon @name="info" />
  </Hds::Tooltip>
{{/if}}
```

### Permission-Based UI

```handlebars
{{! Admin-only features }}
{{#if this.currentUser.isAdmin}}
  <Hds::Dropdown as |D|>
    <D.ToggleIcon @icon="settings" />
    <D.Interactive @text="Admin Settings" />
  </Hds::Dropdown>
{{/if}}

{{! Owner vs. Member actions }}
{{#if this.isOwner}}
  <Hds::Button @text="Transfer Ownership" />
{{else}}
  <Hds::Button @text="Leave Organization" />
{{/if}}
```

### Disabled State with Explanation

Always explain why something is disabled:

```handlebars
<div class="action-with-tooltip">
  <Hds::Button
    @text="Apply Run"
    @isDisabled={{this.applyDisabled}}
  />

  {{#if this.applyDisabled}}
    <Hds::Tooltip @text={{this.applyDisabledReason}}>
      <Hds::Icon @name="help" />
    </Hds::Tooltip>
  {{/if}}
</div>
```

## Description List

**Purpose:** Structured key-value displays.

### Basic Description List

```handlebars
<dl class="description-list">
  <div class="description-item">
    <dt><Hds::Text::Body @weight="semibold">Organization</Hds::Text::Body></dt>
    <dd>{{@workspace.organization.name}}</dd>
  </div>

  <div class="description-item">
    <dt><Hds::Text::Body @weight="semibold">Created</Hds::Text::Body></dt>
    <dd><Hds::Time @date={{@workspace.createdAt}} /></dd>
  </div>

  <div class="description-item">
    <dt><Hds::Text::Body @weight="semibold">Status</Hds::Text::Body></dt>
    <dd><Hds::Badge @text={{@workspace.status}} /></dd>
  </div>
</dl>
```

### Styling with Tokens

```css
.description-list {
  display: grid;
  gap: var(--token-spacing-200);
}

.description-item {
  display: grid;
  grid-template-columns: 200px 1fr;
  gap: var(--token-spacing-150);
  padding: var(--token-spacing-150) 0;
  border-bottom: 1px solid var(--token-color-border-faint);
}

.description-item:last-child {
  border-bottom: none;
}

.description-item dt {
  color: var(--token-color-foreground-faint);
}

.description-item dd {
  color: var(--token-color-foreground-primary);
}
```

## Data Visualization

**Purpose:** Best practices for displaying data visually.

### Key Principles

1. **Use appropriate chart types** for your data
2. **Provide context** with labels and legends
3. **Make it accessible** with proper ARIA labels
4. **Use HDS color tokens** for consistency
5. **Provide text alternatives** for screen readers

### Chart Colors

Use semantic color tokens:

```javascript
const chartColors = {
  success: 'var(--token-color-palette-green-300)',
  warning: 'var(--token-color-palette-amber-300)',
  critical: 'var(--token-color-palette-red-300)',
  neutral: 'var(--token-color-palette-neutral-300)',
  primary: 'var(--token-color-palette-blue-300)',
};
```

## Pattern Resources

For detailed documentation and more patterns:
https://helios.hashicorp.design/patterns

## Contributing Patterns

If you identify a recurring UX challenge that could benefit from a pattern:
1. Document the problem and context
2. Propose a solution using HDS components
3. Share with #team-design-systems on Slack
4. Contribute to HDS pattern library
