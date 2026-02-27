# Interaction Patterns Reference

Common UI patterns for navigation, input, data display, and feedback.

---

## Navigation Patterns

### Top Navigation Bar

```
STRUCTURE: Horizontal bar at top of viewport
BEST FOR: Sites with 4–8 top-level sections

┌─────────────────────────────────────────────────────────────────┐
│ ◉ Logo      Home   Products   About   Contact       🔍   👤    │
└─────────────────────────────────────────────────────────────────┘

WHEN TO USE:
✓ Marketing sites
✓ Content sites with clear sections
✓ E-commerce category navigation

WHEN NOT TO USE:
✗ Apps with deep navigation needs
✗ Mobile-first products (use bottom nav)
✗ Products with > 8 top-level items

DESIGN RULES:
• Current section clearly indicated
• Logo links to home
• Utility nav (search, account) at right
• Mobile: collapses to hamburger
```

### Sidebar Navigation

```
STRUCTURE: Vertical navigation at left edge
BEST FOR: Apps with many sections, deep hierarchy

┌─────────────────┐
│ ◉ AppName       │
├─────────────────┤
│ ▸ Dashboard     │
│   Analytics     │
│   Reports       │
├─────────────────┤
│ ▸ Content       │
│   Posts         │
│   Media         │
└─────────────────┘

WHEN TO USE:
✓ Complex applications (dashboards, admin)
✓ Products with 10+ navigation items
✓ Deep hierarchies (3+ levels)

WHEN NOT TO USE:
✗ Simple sites with few pages
✗ Mobile-primary products
✗ Content-focused reading experiences

DESIGN RULES:
• Group related items
• Icons + labels (icons alone are ambiguous)
• Support keyboard navigation
• Collapsible on smaller screens
```

### Bottom Navigation (Mobile)

```
STRUCTURE: Fixed bar at bottom of viewport
BEST FOR: Mobile apps with 3–5 primary destinations

┌─────────┬─────────┬─────────┬─────────┬─────────┐
│   ⌂     │   🔍    │    +    │   ♡     │   👤    │
│  Home   │ Search  │   New   │  Saved  │   Me    │
└─────────┴─────────┴─────────┴─────────┴─────────┘

WHEN TO USE:
✓ Mobile apps with distinct top-level sections
✓ Products where section-switching is frequent

WHEN NOT TO USE:
✗ Single-purpose apps
✗ Web apps on desktop
✗ Apps with > 5 primary destinations

DESIGN RULES:
• 3–5 items maximum
• Icons with labels (not icons alone)
• Active state clearly differentiated
• Touch targets minimum 48px
```

### Hamburger Menu

```
STRUCTURE: Hidden navigation revealed by icon tap
BEST FOR: Mobile/responsive navigation overflow

LIMITATIONS:
• Low discoverability
• Adds interaction cost to all navigation
• Users may not explore hidden options

WHEN TO USE:
✓ Mobile adaptation of desktop nav
✓ Secondary/utility navigation
✓ Responsive fallback

WHEN NOT TO USE:
✗ Primary mobile app navigation
✗ Frequently accessed items
✗ When space exists for visible nav
```

### Tabs

```
STRUCTURE: Horizontal set of mutually exclusive views
BEST FOR: Switching between related content panels

┌────────┬────────┬────────┬────────┐
│  Tab 1 │  Tab 2 │  Tab 3 │  Tab 4 │
├────────┴────────┴────────┴────────┤
│ Tab content area                  │
└───────────────────────────────────┘

WHEN TO USE:
✓ Alternate views of same content
✓ Related but distinct content sections
✓ Settings or profile sections

WHEN NOT TO USE:
✗ Sequential steps (use stepper)
✗ Unrelated content
✗ More than 7 options

DESIGN RULES:
• 2–7 tabs maximum
• Active tab clearly indicated
• Tabs should be peers (same hierarchy level)
• Don't nest tabs within tabs
```

### Breadcrumbs

```
STRUCTURE: Horizontal path showing location in hierarchy
BEST FOR: Deep hierarchies where location context matters

Home  ▸  Products  ▸  Electronics  ▸  Phones

WHEN TO USE:
✓ E-commerce product pages
✓ Documentation sites
✓ Any hierarchy > 2 levels deep

WHEN NOT TO USE:
✗ Flat site structures
✗ Apps without clear hierarchy
✗ Mobile (often not enough space)

DESIGN RULES:
• Show path from root to current page
• Each level is clickable link
• Current page is not a link
• Truncate middle items if too long
```

### Stepper/Wizard

```
STRUCTURE: Sequential steps with progress indicator
BEST FOR: Multi-step processes with defined sequence

●━━━━━━━━━━●━━━━━━━━━━○┄┄┄┄┄┄┄┄┄┄○
Account    Details    Payment    Confirm

WHEN TO USE:
✓ Checkout flows
✓ Onboarding sequences
✓ Form wizards

WHEN NOT TO USE:
✗ Non-linear tasks
✗ Very short processes (< 3 steps)
✗ When steps are optional/skippable

DESIGN RULES:
• Show all steps upfront
• Indicate current step clearly
• Allow back navigation
• Validate before allowing next
```

---

## Input Patterns

### Single-Column Form

```
STRUCTURE: Vertical stack of fields, one per row
BEST FOR: Most forms (default choice)

Label
┌─────────────────────────────────┐
│ Placeholder text...             │
└─────────────────────────────────┘

Label
┌─────────────────────────────────┐
│ Placeholder text...             │
└─────────────────────────────────┘

┏━━━━━━━━━━━━━━┓
┃    Submit    ┃
┗━━━━━━━━━━━━━━┛

ADVANTAGES:
• Clear reading path
• Works on all screen sizes
• Reduces completion errors

DESIGN RULES:
• Labels above fields (not inline placeholder)
• Clear field grouping with spacing
• Required field indication
• Inline validation
• Primary action button at end
```

### Inline Editing

```
STRUCTURE: Content becomes editable in place
BEST FOR: Quick edits without mode switch

Display mode:    Edit mode:
Project Name     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
[click to edit]  ┃ Project Name              ┃
                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                           [Cancel] [Save]

WHEN TO USE:
✓ Data tables with editable cells
✓ Settings with individual values
✓ Content management (titles, descriptions)

WHEN NOT TO USE:
✗ Complex multi-field edits
✗ When edit requires context/explanation
✗ Destructive changes needing confirmation

DESIGN RULES:
• Clear affordance that content is editable
• Click/tap to enter edit mode
• Save on blur or explicit action
• Cancel option available
```

### Autocomplete

```
STRUCTURE: Text input with suggested completions
BEST FOR: Large option sets, known-item search

┌─────────────────────────────────┐
│ New Y                           │
├─────────────────────────────────┤
│ New York, NY                    │
│ New York City, NY               │
│ New Orleans, LA                 │
│ New Jersey                      │
└─────────────────────────────────┘

WHEN TO USE:
✓ Location search
✓ User/contact lookup
✓ Tag selection from large set
✓ Any selection from > 20 options

WHEN NOT TO USE:
✗ Small option sets (use dropdown)
✗ When browsing options is needed
✗ Unfamiliar content users can't name

DESIGN RULES:
• Begin suggestions after 2–3 characters
• Highlight matching text in results
• Keyboard navigation (arrows, enter)
• Clear loading state
• Limit visible suggestions (5–10)
```

### Date Picker

```
STRUCTURE: Calendar UI for date selection

┌─────────────────────────────────┐
│     ◀  January 2025  ▶          │
├─────────────────────────────────┤
│ Su  Mo  Tu  We  Th  Fr  Sa      │
│           1   2   3   4         │
│  5   6   7   8   9  10  11      │
│ 12  13  14 [15] 16  17  18      │
│ 19  20  21  22  23  24  25      │
│ 26  27  28  29  30  31          │
└─────────────────────────────────┘

WHEN TO USE:
✓ Date selection where relative position matters
✓ Date range selection

WHEN NOT TO USE:
✗ Birth dates (use dropdowns or text input)
✗ Dates far in past/future (too much scrolling)
✗ When specific date format entry is faster

DESIGN RULES:
• Show current date clearly
• Allow direct text input as alternative
• Disable invalid dates
• Respect locale (date format, first day of week)
• Mobile: consider native picker
```

### Multi-Select Patterns

```
CHECKBOX LIST (< 10 options):
┌─────────────────────────────────┐
│ ☑ Option 1                      │
│ ☑ Option 2                      │
│ ☐ Option 3                      │
│ ☐ Option 4                      │
└─────────────────────────────────┘

CHIP/TAG INPUT (freeform + predefined):
┌─────────────────────────────────┐
│ [Tag 1 ×] [Tag 2 ×] [Add...]    │
└─────────────────────────────────┘

DROPDOWN MULTI-SELECT (moderate options):
┌─────────────────────────────────┐
│ 3 selected                    ▼ │
└─────────────────────────────────┘
```

---

## Data Display Patterns

### Data Table

```
STRUCTURE: Rows and columns of structured data
BEST FOR: Comparing items across attributes

┌──────────────┬──────────────┬────────┬─────────┐
│ Name       ↓ │ Email        │ Status │ Actions │
├──────────────┼──────────────┼────────┼─────────┤
│ John Doe     │ john@ex.com  │ ● Active│ ⋮      │
│ Jane Smith   │ jane@ex.com  │ ● Active│ ⋮      │
│ Bob Wilson   │ bob@ex.com   │ ○ Pending│ ⋮     │
└──────────────┴──────────────┴────────┴─────────┘

WHEN TO USE:
✓ Structured data with multiple attributes
✓ Comparison tasks
✓ Data requiring sorting/filtering

WHEN NOT TO USE:
✗ < 3 columns (use list)
✗ Primarily browsing (use cards)
✗ Mobile-primary (consider list/cards)

DESIGN RULES:
• Sortable columns indicated
• Current sort state shown
• Row selection if actionable
• Pagination or infinite scroll
• Sticky header on scroll
```

### Card Grid

```
STRUCTURE: Grid of contained content blocks
BEST FOR: Browsable content with visual elements

╭───────────────╮ ╭───────────────╮ ╭───────────────╮
│ ░░░░░░░░░░░░░ │ │ ░░░░░░░░░░░░░ │ │ ░░░░░░░░░░░░░ │
├───────────────┤ ├───────────────┤ ├───────────────┤
│ Title 1       │ │ Title 2       │ │ Title 3       │
│ Description   │ │ Description   │ │ Description   │
│ [Action]      │ │ [Action]      │ │ [Action]      │
╰───────────────╯ ╰───────────────╯ ╰───────────────╯

WHEN TO USE:
✓ Image-heavy content
✓ Browsing/discovery experiences
✓ Products, articles, profiles

WHEN NOT TO USE:
✗ Comparison tasks (use table)
✗ Dense data (use table or list)
✗ Sequential content (use list)

DESIGN RULES:
• Consistent card dimensions
• Visual hierarchy within card
• Single primary action per card
• Responsive column count
```

### List

```
STRUCTURE: Vertical stack of items
BEST FOR: Sequential content, simple data

┌─────────────────────────────────────────────────┐
│ ○  List item title                          ▸  │
│    Secondary text here                          │
├─────────────────────────────────────────────────┤
│ ○  Another list item                        ▸  │
│    More secondary text                          │
└─────────────────────────────────────────────────┘

VARIANTS:
• Simple list (text only)
• List with icons
• List with thumbnails
• List with metadata
• List with actions

DESIGN RULES:
• Consistent item height (or clear rhythm)
• Clear item boundaries
• Touch targets full width on mobile
• Loading state (skeleton)
• Empty state
```

---

## Feedback Patterns

### Toast/Snackbar

```
STRUCTURE: Temporary message, typically bottom of screen
BEST FOR: Confirmation of completed action

┌─────────────────────────────────────────────────┐
│ ✓ Changes saved successfully              UNDO │
└─────────────────────────────────────────────────┘

WHEN TO USE:
✓ Action confirmations
✓ Non-critical notifications
✓ Background process completion

WHEN NOT TO USE:
✗ Errors requiring action
✗ Critical information
✗ Long content

DESIGN RULES:
• Auto-dismiss after 4–8 seconds
• Allow manual dismiss
• Include undo when applicable
• Don't stack multiple toasts
• Don't require action to dismiss
```

### Modal/Dialog

```
STRUCTURE: Overlay requiring user attention
BEST FOR: Focused tasks, confirmations, critical info

░░░░░░░░░╔═══════════════════════════════╗░░░░░░░░░
░░░░░░░░░║ Confirm Delete              ✕ ║░░░░░░░░░
░░░░░░░░░╠═══════════════════════════════╣░░░░░░░░░
░░░░░░░░░║                               ║░░░░░░░░░
░░░░░░░░░║  Are you sure you want to     ║░░░░░░░░░
░░░░░░░░░║  delete this item? This       ║░░░░░░░░░
░░░░░░░░░║  cannot be undone.            ║░░░░░░░░░
░░░░░░░░░║                               ║░░░░░░░░░
░░░░░░░░░╠═══════════════════════════════╣░░░░░░░░░
░░░░░░░░░║      [Cancel]      [Delete]   ║░░░░░░░░░
░░░░░░░░░╚═══════════════════════════════╝░░░░░░░░░

WHEN TO USE:
✓ Confirming destructive actions
✓ Required input before proceeding
✓ Focused sub-tasks

WHEN NOT TO USE:
✗ Non-critical information
✗ Frequent interactions (too disruptive)
✗ Long forms (use full page)

DESIGN RULES:
• Clear title describing purpose
• Close mechanism (X, click outside, Escape)
• Focus trapped within modal
• Clear primary and secondary actions
• Don't nest modals
```

### Empty State

```
STRUCTURE: Content shown when no data exists
BEST FOR: Zero-data scenarios

┌─────────────────────────────────────────────────┐
│                                                 │
│                    📭                           │
│                                                 │
│              No items found                     │
│                                                 │
│     Try adjusting your search or filters        │
│                                                 │
│           ┌────────────────────┐                │
│           │   Create New Item  │                │
│           └────────────────────┘                │
└─────────────────────────────────────────────────┘

TYPES:
• First use: "No projects yet. Create your first project."
• Search no results: "No results for 'xyz'. Try different keywords."
• Filtered empty: "No items match filters. Clear filters."

DESIGN RULES:
• Explain why empty
• Guide toward action
• Don't blame user
• Appropriate illustration (optional)
```

### Loading States

```
SKELETON (content loading):
┌─────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░                                 │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░       │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░                    │
└─────────────────────────────────────────────────┘

SPINNER (action loading):
              ◌ Loading...

PROGRESS BAR (long process):
████████████░░░░░░░░░░░░░░░░░░░░  40%

WHEN TO USE:
• Skeleton: Content loading, page transitions
• Spinner: Short actions, unknown duration
• Progress bar: Long processes, known duration
```

---

## Platform Conventions

### iOS (Key Points)

```
NAVIGATION:
• Tab bar at bottom for primary navigation
• Navigation bar at top with back button
• Swipe from left edge to go back

INTERACTION:
• 44pt minimum touch target
• Pull to refresh
• Swipe gestures for common actions

VISUAL:
• SF Symbols for iconography
• Large titles for hierarchy
• Translucent materials
```

### Material Design (Key Points)

```
NAVIGATION:
• Bottom navigation for 3–5 destinations
• Navigation drawer for many destinations
• App bar at top

INTERACTION:
• 48dp minimum touch target
• FAB for primary action
• Ripple effect for touch feedback

VISUAL:
• Material icons
• Elevation and shadow for hierarchy
• Color roles (primary, secondary, surface)
```

### Web Conventions

```
NAVIGATION:
• Logo top-left links to home
• Primary nav horizontal at top
• Utility nav top-right

INTERACTION:
• Underline for text links
• Pointer cursor for clickable
• Focus states for keyboard nav

VISUAL:
• Clear link differentiation
• Form labels above inputs
• Primary button prominence
```

---

## Pattern Selection Matrix

| Task | Pattern | Platform Notes |
|------|---------|----------------|
| Primary nav (3–5 items) | Tab bar / Bottom nav | iOS: tab bar, Android: bottom nav |
| Primary nav (6+ items) | Sidebar / Nav drawer | Collapsible on mobile |
| Primary action | Button / FAB | FAB is Material Design |
| Switching views | Tabs | Don't exceed 7 tabs |
| Showing hierarchy | Breadcrumbs | May not fit mobile |
| Multi-step process | Stepper | Allow back navigation |
| Selecting from many | Autocomplete | Need 20+ options |
| Selecting from few | Dropdown | 5-15 options ideal |
| Comparing items | Data table | Responsive strategy needed |
| Browsing items | Card grid | Visual content focus |
| Confirming action | Modal | Keep simple, allow escape |
| Showing status | Toast | Auto-dismiss, include undo |
| Zero data | Empty state | Guide toward action |
