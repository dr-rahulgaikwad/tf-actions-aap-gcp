# HDS Design Tokens Reference

Design tokens are CSS custom properties that standardize foundation styles across Helios. Use tokens instead of hardcoded values to maintain consistency.

## Token Naming Convention

Tokens follow the pattern: `--token-[category]-[property]-[variant]`

Example: `--token-color-foreground-primary`

## Color Tokens

### Palette Colors

Base color scales from 50 (lightest) to 500 (darkest):

**Blue:**
```css
--token-color-palette-blue-50
--token-color-palette-blue-100
--token-color-palette-blue-200
--token-color-palette-blue-300
--token-color-palette-blue-400
--token-color-palette-blue-500  /* #1c345f */
```

**Other Palettes:** purple, green, amber, red, neutral

### Semantic Colors

#### Border Colors
```css
--token-color-border-primary     /* Default border */
--token-color-border-faint       /* Subtle borders */
--token-color-border-strong      /* Emphasized borders */
--token-color-border-action      /* Interactive elements */
--token-color-border-highlight   /* Highlighted state */
--token-color-border-success     /* Success state */
--token-color-border-warning     /* Warning state */
--token-color-border-critical    /* Error/critical state */
```

#### Foreground (Text) Colors
```css
--token-color-foreground-strong      /* Highest emphasis text */
--token-color-foreground-primary     /* Default text */
--token-color-foreground-faint       /* De-emphasized text */
--token-color-foreground-disabled    /* Disabled state */
--token-color-foreground-action      /* Links/actions */
--token-color-foreground-action-hover
--token-color-foreground-action-active
--token-color-foreground-highlight   /* Highlighted text */
--token-color-foreground-success     /* Success text */
--token-color-foreground-warning     /* Warning text */
--token-color-foreground-critical    /* Error text */
```

#### Surface (Background) Colors
```css
--token-color-surface-primary        /* Default background */
--token-color-surface-faint          /* Subtle background */
--token-color-surface-strong         /* Emphasized background */
--token-color-surface-interactive    /* Interactive backgrounds */
--token-color-surface-highlight      /* Highlighted backgrounds */
--token-color-surface-success        /* Success backgrounds */
--token-color-surface-warning        /* Warning backgrounds */
--token-color-surface-critical       /* Error backgrounds */
```

#### Focus Ring Colors
```css
--token-focus-ring-action-box-shadow    /* Default focus ring */
--token-focus-ring-critical-box-shadow  /* Critical element focus */
```

### Product Brand Colors

HashiCorp product-specific tokens:

```css
/* Terraform */
--token-color-terraform-brand         /* #7B42BC */
--token-color-terraform-foreground
--token-color-terraform-surface
--token-color-terraform-border
--token-color-terraform-gradient-faint
--token-color-terraform-gradient-primary

/* Similar patterns for: */
/* boundary, consul, nomad, packer, vagrant, vault, waypoint */
```

## Typography Tokens

### Font Stacks

```css
--token-typography-font-stack-text    /* System fonts for text */
--token-typography-font-stack-code    /* Monospace for code */
--token-typography-font-stack-display /* System fonts for headings */
```

Values:
- Text/Display: System UI fonts (SF Pro on Mac, Segoe UI on Windows)
- Code: `ui-monospace, Menlo, Consolas, Monaco, monospace`

### Font Weights

```css
--token-typography-font-weight-regular   /* 400 */
--token-typography-font-weight-medium    /* 500 */
--token-typography-font-weight-semibold  /* 600 */
--token-typography-font-weight-bold      /* 700 */
```

### Type Scales

#### Display (Headings)

**Display 500** (Largest heading - 30px):
```css
--token-typography-display-500-font-size      /* 1.875rem (30px) */
--token-typography-display-500-line-height    /* 2.5rem (40px) */
--token-typography-display-500-font-family
--token-typography-display-500-font-weight
```

**Display 400** (24px):
```css
--token-typography-display-400-font-size      /* 1.5rem */
--token-typography-display-400-line-height    /* 2rem */
```

**Display 300** (20px):
```css
--token-typography-display-300-font-size      /* 1.25rem */
--token-typography-display-300-line-height    /* 1.75rem */
```

**Display 200** (16px):
```css
--token-typography-display-200-font-size      /* 1rem */
--token-typography-display-200-line-height    /* 1.5rem */
```

**Display 100** (13px):
```css
--token-typography-display-100-font-size      /* 0.8125rem */
--token-typography-display-100-line-height    /* 1.125rem */
```

#### Body (Content)

**Body 300** (Larger UI - 16px):
```css
--token-typography-body-300-font-size         /* 1rem */
--token-typography-body-300-line-height       /* 1.5rem */
```

**Body 200** (Default - 14px):
```css
--token-typography-body-200-font-size         /* 0.875rem */
--token-typography-body-200-line-height       /* 1.25rem */
```

**Body 100** (Small - 12px):
```css
--token-typography-body-100-font-size         /* 0.75rem */
--token-typography-body-100-line-height       /* 1rem */
```

#### Code (Monospace)

Similar pattern for Code 300, 200, 100 with monospace font stack.

## Spacing Tokens

### Standard Spacing Scale

```css
--token-spacing-025    /* 2px */
--token-spacing-050    /* 4px */
--token-spacing-100    /* 8px */
--token-spacing-150    /* 12px */
--token-spacing-200    /* 16px */
--token-spacing-300    /* 24px */
--token-spacing-400    /* 32px */
--token-spacing-500    /* 48px */
```

**Usage:**
```css
.my-component {
  padding: var(--token-spacing-200);      /* 16px */
  margin-bottom: var(--token-spacing-300); /* 24px */
  gap: var(--token-spacing-100);          /* 8px */
}
```

## Border Radius Tokens

```css
--token-border-radius-x-small  /* 3px */
--token-border-radius-small    /* 5px */
--token-border-radius-medium   /* 6px */
--token-border-radius-large    /* 8px */
```

**Usage:**
```css
.card {
  border-radius: var(--token-border-radius-medium);
}
```

## Elevation (Shadow) Tokens

Elevation creates depth through shadows:

```css
--token-elevation-inset-box-shadow     /* Inset shadow */
--token-elevation-low-box-shadow       /* Subtle elevation */
--token-elevation-mid-box-shadow       /* Medium elevation */
--token-elevation-high-box-shadow      /* High elevation */
--token-elevation-higher-box-shadow    /* Dramatic elevation */
--token-elevation-overlay-box-shadow   /* Modal/overlay */
```

**Values (examples):**
- Low: `0 1px 2px 0 rgba(0, 0, 0, 0.12)`
- Mid: `0 6px 8px -2px rgba(0, 0, 0, 0.12), 0 2px 4px 0 rgba(0, 0, 0, 0.08)`
- High: `0 14px 16px -4px rgba(0, 0, 0, 0.12), 0 4px 6px 0 rgba(0, 0, 0, 0.08)`

**Usage:**
```css
.card {
  box-shadow: var(--token-elevation-mid-box-shadow);
}

.modal {
  box-shadow: var(--token-elevation-overlay-box-shadow);
}
```

### Surface Shadows

Similar to elevation but includes borders:

```css
--token-surface-low-box-shadow
--token-surface-mid-box-shadow
--token-surface-high-box-shadow
```

## Component-Specific Tokens

### App Header
```css
--token-app-header-height              /* 60px */
--token-app-header-icon-size           /* 28px */
--token-app-header-icon-size-large     /* 36px */
```

### Form Elements
```css
--token-form-checkbox-size             /* 16px */
--token-form-radio-size                /* 16px */
--token-form-control-padding
--token-form-control-border-width
```

### Pagination
```css
--token-pagination-nav-height          /* 36px */
--token-pagination-icon-spacing        /* 6px */
```

### Tabs
```css
--token-tabs-height                    /* 36px or 48px */
--token-tabs-indicator-height          /* 3px */
```

## Focus Ring Tokens

Essential for keyboard accessibility:

```css
/* Action (default) */
--token-focus-ring-action-box-shadow
/* Value: inset 0 0 0 1px #0c56e9, 0 0 0 3px #5990ff */

/* Critical (errors) */
--token-focus-ring-critical-box-shadow
/* Value: inset 0 0 0 1px #c00005, 0 0 0 3px #dd7578 */
```

**Usage:**
```css
.button:focus {
  box-shadow: var(--token-focus-ring-action-box-shadow);
  outline: none;
}
```

## Usage Examples

### Creating Custom Styles with Tokens

```css
/* Card component with tokens */
.custom-card {
  /* Layout */
  padding: var(--token-spacing-300);
  border-radius: var(--token-border-radius-medium);

  /* Colors */
  background: var(--token-color-surface-primary);
  border: 1px solid var(--token-color-border-primary);
  color: var(--token-color-foreground-primary);

  /* Elevation */
  box-shadow: var(--token-elevation-mid-box-shadow);

  /* Typography */
  font-family: var(--token-typography-font-stack-text);
  font-size: var(--token-typography-body-200-font-size);
  line-height: var(--token-typography-body-200-line-height);
}

/* Interactive state */
.custom-card:hover {
  border-color: var(--token-color-border-action);
  box-shadow: var(--token-elevation-high-box-shadow);
}

/* Focus state */
.custom-card:focus {
  box-shadow: var(--token-focus-ring-action-box-shadow);
}
```

### Status Indicators with Tokens

```css
/* Success state */
.status-success {
  color: var(--token-color-foreground-success);
  background: var(--token-color-surface-success);
  border-color: var(--token-color-border-success);
}

/* Warning state */
.status-warning {
  color: var(--token-color-foreground-warning);
  background: var(--token-color-surface-warning);
  border-color: var(--token-color-border-warning);
}

/* Critical state */
.status-critical {
  color: var(--token-color-foreground-critical);
  background: var(--token-color-surface-critical);
  border-color: var(--token-color-border-critical);
}
```

## Helper Classes

HDS provides helper classes for common token usage:

### Typography Helpers
```handlebars
<p class="hds-typography-body-200">Default body text</p>
<h2 class="hds-typography-display-400">Display heading</h2>
<code class="hds-typography-code-200">Code snippet</code>
```

### Color Helpers
```handlebars
<div class="hds-foreground-primary">Primary text color</div>
<div class="hds-foreground-faint">De-emphasized text</div>
```

## Importing Tokens

### In Sass/SCSS
```scss
@use "@hashicorp/design-system-components";

.my-component {
  color: var(--token-color-foreground-primary);
}
```

### In CSS
Import the tokens stylesheet:
```javascript
// ember-cli-build.js
app.import('node_modules/@hashicorp/design-system-tokens/dist/products/css/tokens.css');
```

## Best Practices

1. **Always use tokens** for colors, spacing, typography - never hardcode values
2. **Use semantic tokens** over palette tokens (use `--token-color-foreground-primary` not `--token-color-palette-neutral-500`)
3. **Maintain consistency** by using the spacing scale consistently
4. **Respect elevation hierarchy** - don't skip levels
5. **Include focus rings** - essential for accessibility
6. **Use type scales** - don't create custom font sizes
7. **Follow component tokens** when building custom components similar to existing ones

## Token Reference

Complete token documentation:
https://helios.hashicorp.design/foundations/tokens
