# Design Systems Reference

Foundations of design systems, atomic design, tokens, and component documentation.

---

## Design System Definition

**A design system is a collection of reusable components, guided by clear standards, that can be assembled to build applications.**

### Components

```
DESIGN TOKENS: Primitive values (colors, spacing, type)
CORE COMPONENTS: Basic UI elements (buttons, inputs, cards)
PATTERNS: Component combinations for common use cases
GUIDELINES: Principles and rules for usage
DOCUMENTATION: Reference for implementation
```

### Benefits

```
CONSISTENCY: Same component = same experience
EFFICIENCY: Build once, use everywhere
QUALITY: Tested components reduce bugs
SCALABILITY: New features from existing pieces
COMMUNICATION: Shared vocabulary for teams
```

---

## Atomic Design Methodology

### Atomic Levels

```
ATOMS
─────────────────────────────────────────────────
Smallest UI elements that can't be broken down further.
EXAMPLES: Buttons, inputs, labels, icons, colors

MOLECULES
─────────────────────────────────────────────────
Groups of atoms functioning together.
EXAMPLES: Search field (input + button), form field (label + input + error)

ORGANISMS
─────────────────────────────────────────────────
Complex components made of molecules and atoms.
EXAMPLES: Header (logo + nav + search), card (image + title + description + CTA)

TEMPLATES
─────────────────────────────────────────────────
Page-level structures with placeholder content.
EXAMPLES: Article layout, dashboard layout, settings page

PAGES
─────────────────────────────────────────────────
Templates with real content.
EXAMPLES: Specific article, actual dashboard with data
```

### Atomic Composition Example

```
PAGE: User Profile Page
└── TEMPLATE: Profile Layout
    ├── ORGANISM: Profile Header
    │   ├── MOLECULE: Avatar Group
    │   │   ├── ATOM: Avatar Image
    │   │   └── ATOM: Status Indicator
    │   └── MOLECULE: Name Block
    │       ├── ATOM: Heading (name)
    │       └── ATOM: Text (title)
    └── ORGANISM: Profile Content
        ├── MOLECULE: Stats Row
        │   └── ATOM: Stat Item (×3)
        └── MOLECULE: Action Bar
            ├── ATOM: Primary Button
            └── ATOM: Secondary Button
```

### Rules

```
1. Build from atoms up, not pages down
2. Each level should be independently testable
3. Don't skip levels (no atom → organism jumps)
4. Components should be context-agnostic at lower levels
5. Context specificity increases at higher levels
```

---

## Design Tokens

**Named entities that store visual design attributes, enabling consistent application across platforms.**

### Token Categories

```
COLOR TOKENS:
─────────────────────────────────────────────────
Brand:    color-brand-primary, color-brand-secondary
Semantic: color-text-primary, color-background-surface
State:    color-interactive-hover, color-feedback-error

SPACING TOKENS:
─────────────────────────────────────────────────
Scale:    spacing-xs (4px), spacing-sm (8px), spacing-md (16px)
Semantic: spacing-component-padding, spacing-section-gap

TYPOGRAPHY TOKENS:
─────────────────────────────────────────────────
Family:      font-family-body, font-family-display
Size:        font-size-sm, font-size-md, font-size-lg
Weight:      font-weight-regular, font-weight-bold
Line height: line-height-tight, line-height-normal

SIZE TOKENS:
─────────────────────────────────────────────────
Icons:   size-icon-sm (16px), size-icon-md (24px)
Borders: border-width-thin (1px), border-radius-md (8px)

ANIMATION TOKENS:
─────────────────────────────────────────────────
Duration: duration-fast (100ms), duration-normal (200ms)
Easing:   easing-ease-out, easing-ease-in-out
```

### Token Naming Convention

```
FORMAT: [category]-[property]-[variant]-[state]

EXAMPLES:
color-text-primary
color-background-surface-hover
spacing-component-padding-sm
font-size-heading-lg

RULES:
• Use semantic names over literal values
• Consistent naming pattern throughout
• Platform-agnostic naming (not "mobile-spacing")
```

### Token Architecture

```
LAYER 1 - PRIMITIVE TOKENS (reference values):
$blue-500: #0066CC
$spacing-16: 16px

LAYER 2 - SEMANTIC TOKENS (purpose-based):
$color-action-primary: $blue-500
$spacing-component-padding: $spacing-16

LAYER 3 - COMPONENT TOKENS (component-specific):
$button-background-color: $color-action-primary
$button-padding: $spacing-component-padding

BENEFIT: Change $blue-500 → propagates through all layers
```

---

## Component Design

### Component API Design

```
COMPONENT API ELEMENTS:
─────────────────────────────────────────────────
Props:    Configurable options
Variants: Predefined configurations
States:   Interactive states
Slots:    Content insertion points
Events:   Interaction callbacks


EXAMPLE - BUTTON COMPONENT:
─────────────────────────────────────────────────
Props:
  • label: string (required)
  • variant: 'primary' | 'secondary' | 'ghost'
  • size: 'sm' | 'md' | 'lg'
  • disabled: boolean
  • loading: boolean
  • iconLeft: Icon
  • iconRight: Icon
  
States:
  • default
  • hover
  • active
  • focus
  • disabled
  • loading

Events:
  • onClick
```

### Component Design Checklist

```
FUNCTIONALITY:
☐ Does it serve a clear purpose?
☐ Is the API minimal but sufficient?
☐ Are variants necessary or cosmetic?
☐ Are edge cases handled?

CONSISTENCY:
☐ Does it follow existing patterns?
☐ Is naming consistent with system?
☐ Are tokens used (not hardcoded values)?

ACCESSIBILITY:
☐ Is it keyboard accessible?
☐ Does it have proper ARIA attributes?
☐ Does it meet contrast requirements?
☐ Is focus state visible?

FLEXIBILITY:
☐ Does it work in different contexts?
☐ Is it responsive?
☐ Can content length vary?
☐ Is it composable with other components?
```

### Component Documentation Template

```
# Component Name

## Description
[What this component is and when to use it]

## Usage
[Code example]

## Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| ...  | ...  | ...     | ...         |

## Variants
[Visual examples of each variant]

## States
[Visual examples of each state]

## Accessibility
[ARIA requirements, keyboard behavior]

## Do's and Don'ts
✓ [Correct usage]
✗ [Incorrect usage]

## Related Components
[Links to similar or complementary components]
```

---

## Typography System

### Type Scale

```
Use a consistent mathematical ratio for size relationships.

COMMON RATIOS:
• Minor second: 1.067 (subtle, compact)
• Major second: 1.125 (moderate, readable)
• Minor third:  1.200 (balanced, popular)
• Major third:  1.250 (distinct, bold)
• Perfect fourth: 1.333 (dramatic, display)

EXAMPLE SCALE (Major Second, 16px base):
xs:    14px (16 ÷ 1.125)
sm:    16px (base)
md:    18px (16 × 1.125)
lg:    20px (16 × 1.125²)
xl:    23px (16 × 1.125³)
2xl:   26px (16 × 1.125⁴)
3xl:   29px (16 × 1.125⁵)
```

### Typography Hierarchy Mapping

```
Page title:       3xl, bold
Section heading:  xl, semibold
Card title:       lg, medium
Body text:        base, regular
Caption:          sm, regular
Label:            sm, medium
```

### Line Height & Length

```
LINE HEIGHT (leading):
• Body text: 1.4–1.6
• Headings: 1.1–1.3
• Dense UI: 1.3–1.4

LINE LENGTH:
• Optimal: 45–75 characters per line
• Constrain content width on wide screens
```

---

## Color System

### Color Roles

```
PRIMARY:   Brand identity, primary actions
SECONDARY: Supporting actions, alternative treatments
NEUTRAL:   Text, backgrounds, borders
SUCCESS:   Positive feedback, completion
WARNING:   Caution, non-critical issues
ERROR:     Errors, destructive actions
INFO:      Informational, neutral feedback
```

### Color Definition

For each role, define:
- Base shade
- Lighter shade (backgrounds)
- Darker shade (hover/active states)
- Contrast text color

### Contrast Requirements

```
TEXT:                  4.5:1 minimum (3:1 for large text)
INTERACTIVE ELEMENTS:  3:1 against background
FOCUS INDICATORS:      3:1 against adjacent colors
DISABLED STATES:       Not required to meet contrast
```

---

## Spacing System

### Spacing Scale

```
COMMON APPROACH (4px base):

0:    0px
1:    4px   (base)
2:    8px   (base × 2)
3:    12px  (base × 3)
4:    16px  (base × 4)
5:    20px  (base × 5)
6:    24px  (base × 6)
8:    32px  (base × 8)
10:   40px  (base × 10)
12:   48px  (base × 12)
16:   64px  (base × 16)
```

### Spacing Application

```
COMPONENT PADDING:     16–24px typically
ELEMENT SPACING:       8–16px within components
SECTION SPACING:       32–64px between sections
TIGHT GROUPING:        4–8px for closely related elements
```

### Spacing Principles

```
1. Related items close: Use proximity to show relationships
2. Consistent rhythm: Same spacing for same relationships
3. Hierarchy through space: More space = more separation
4. Touch targets: Minimum 44px tap target size (includes padding)
```

---

## Grid System

### Grid Types

```
COLUMN GRID:
• Fixed number of columns with gutters
• Web: 12 columns common (divisible by 2, 3, 4, 6)
• Mobile: 4–6 columns

MODULAR GRID:
• Columns plus rows for two-dimensional organization
• Useful for card layouts, dashboards

BASELINE GRID:
• Horizontal rhythm based on line height
• Aligns text across columns
```

### Responsive Grid Pattern

```
MOBILE (< 640px):    4 columns, 16px margins
TABLET (640–1024px): 8 columns, 24px margins
DESKTOP (> 1024px):  12 columns, 32px margins, max-width container
```

---

## Design System Governance

### Contribution Models

```
CENTRALIZED:
• Dedicated design system team
• Changes go through formal process
• High consistency, slower iteration
• Best for: Large orgs, mature systems

FEDERATED:
• Distributed ownership across teams
• System team coordinates
• Faster iteration, consistency risk
• Best for: Multiple product lines

HYBRID:
• Core components centralized
• Extensions federated
• Balance of consistency and speed
• Best for: Most organizations
```

### Contribution Process

```
1. PROPOSAL
   • Need identified and documented
   • Existing alternatives evaluated
   • Usage scenarios defined

2. DESIGN
   • Component designed following standards
   • Variants and states defined
   • Accessibility reviewed

3. REVIEW
   • System team review
   • Cross-team feedback
   • Standards compliance check

4. IMPLEMENTATION
   • Code development
   • Testing (unit, visual, accessibility)
   • Documentation written

5. RELEASE
   • Version increment
   • Changelog updated
   • Teams notified

6. ADOPTION
   • Migration guidance
   • Deprecation of old patterns
```

### Versioning Strategy

```
SEMANTIC VERSIONING: MAJOR.MINOR.PATCH

MAJOR (breaking changes):
• Removed components
• Changed APIs
• Visual changes affecting layouts

MINOR (new features):
• New components
• New variants
• New tokens

PATCH (fixes):
• Bug fixes
• Documentation updates
• Minor visual fixes

DEPRECATION POLICY:
1. Mark as deprecated in docs
2. Console warning in code
3. Migration guidance provided
4. Removal after N versions or M months
```

---

## Design-Development Handoff

### Handoff Checklist

```
VISUAL SPECS:
☐ Component dimensions
☐ Spacing values (using tokens)
☐ Color values (using tokens)
☐ Typography specs (using tokens)
☐ Border/radius/shadow specs

BEHAVIORAL SPECS:
☐ All interactive states
☐ Hover/focus/active/disabled states
☐ Transitions and animations
☐ Loading states
☐ Error states

RESPONSIVE SPECS:
☐ Breakpoint behaviors
☐ Layout changes per breakpoint
☐ Touch target sizes
☐ Content reflow

ACCESSIBILITY SPECS:
☐ Focus order
☐ Screen reader behavior
☐ ARIA attributes needed
☐ Keyboard interactions

CONTENT SPECS:
☐ Min/max content lengths
☐ Truncation behavior
☐ Empty states
☐ Localization considerations
```

### Annotation Format

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │                                         │   │
│  │         Component                       │◄──┼── padding: spacing-md (16px)
│  │                                         │   │
│  └─────────────────────────────────────────┘   │
│  ▲                                             │
│  │                                             │
│  └── margin-bottom: spacing-lg (24px)          │
│                                                 │
│  Font: font-body-md (16px/24px)                │
│  Color: color-text-primary (#1A1A1A)           │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Accessibility in Design Systems

### Accessibility Checklist for Components

```
VISUAL:
☐ Color contrast meets WCAG AA (4.5:1 text, 3:1 UI)
☐ Focus indicator clearly visible
☐ State changes don't rely on color alone
☐ Text resizable to 200%

KEYBOARD:
☐ All interactive elements focusable
☐ Focus order matches visual order
☐ Custom components have appropriate keyboard interactions
☐ No keyboard traps

SCREEN READER:
☐ Proper semantic HTML
☐ ARIA labels for icons/images
☐ Live regions for dynamic content
☐ Form labels properly associated

MOTION:
☐ Respects prefers-reduced-motion
☐ No auto-playing video/animation
☐ Essential animations kept simple
```

### Common ARIA Patterns

```
DISCLOSURE:
button[aria-expanded] + content region

MODAL:
[role="dialog"][aria-modal="true"][aria-labelledby]

TAB PANEL:
[role="tablist"] + [role="tab"][aria-selected] + [role="tabpanel"]

COMBOBOX:
input[role="combobox"] + listbox

ALERT:
[role="alert"] for important messages

LIVE REGION:
[aria-live="polite|assertive"] for updates
```

---

## Design System Metrics

### Adoption Metrics

```
COVERAGE:
• % of product using design system components
• # of custom components vs. system components

CONSISTENCY:
• # of design system violations
• # of one-off implementations

EFFICIENCY:
• Time to build new features
• Designer-developer handoff time

QUALITY:
• Accessibility audit scores
• Bug count in system components
```

### Health Indicators

```
HEALTHY SYSTEM:
✓ Regular contributions from multiple teams
✓ Active documentation updates
✓ Decreasing custom implementations
✓ Positive developer satisfaction

WARNING SIGNS:
⚠ Stale documentation
⚠ Growing custom implementations
⚠ Low contribution rate
⚠ Complaints about inflexibility
```
