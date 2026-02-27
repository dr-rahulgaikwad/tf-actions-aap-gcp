# UI Capture Specification

Capture any website's UI as LLM-readable documentation. Converts live pages into ASCII layouts, zone definitions, and clickable element maps.

---

## Quick Start

### Prerequisites
Requires `dev-browser` skill. Start browser server first:
```bash
~/.claude/skills/dev-browser/server.sh &
```

### Single Page Capture

```bash
cd ~/.claude/skills/dev-browser && bun x tsx <<'EOF'
import { connect, waitForPageLoad } from "@/client.js";

const client = await connect();
const page = await client.page("capture");

await page.setViewportSize({ width: 1280, height: 800 });
await page.goto("https://example.com");
await waitForPageLoad(page);

// Screenshot for visual reference
await page.screenshot({ path: "tmp/capture.png", fullPage: true });

// ARIA snapshot for structure
const snapshot = await client.getAISnapshot("capture");
console.log(snapshot);

await client.disconnect();
EOF
```

---

## Output Format

```markdown
# Page Name

**URL**: `/path/to/page`
**Title**: Browser Title
**Purpose**: What this page does
**Captured**: YYYY-MM-DD

## Layout

┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | Navigation | [Search] | UserMenu             │
├───────────┬─────────────────────────────────────────────────┤
│ SIDEBAR   │ PAGE_TITLE + ACTIONS                            │
│           ├─────────────────────────────────────────────────┤
│ • Nav 1   │ CONTENT_ZONE_1                                  │
│ • Nav 2*  ├─────────────────────────────────────────────────┤
│           │ CONTENT_ZONE_2                                  │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Links | Copyright                                   │
└─────────────────────────────────────────────────────────────┘

## Zones

| Zone | Purpose | Contents |
|------|---------|----------|
| HEADER | Global nav | Logo, nav links, user menu |
| SIDEBAR | Section nav | Navigation items |
| PAGE_TITLE | Page identity | Heading, description |
| CONTENT_ZONE_1 | Main content | Data table/form/etc |

## Clickable Elements

| Element | Location | Destination |
|---------|----------|-------------|
| Logo | HEADER | `/` |
| [Button] | ACTIONS | Opens modal |
| Row item | TABLE | `/detail/{id}` |
```

---

## ARIA to ASCII Conversion

### Landmark Roles → Zones

| ARIA Role | Zone | Position |
|-----------|------|----------|
| `banner` | HEADER | Top |
| `navigation` | SIDEBAR/NAV | Left/Top |
| `main` | MAIN_CONTENT | Center |
| `complementary` | SIDEBAR | Left/Right |
| `contentinfo` | FOOTER | Bottom |
| `region "Name"` | {NAME}_SECTION | Varies |

### Interactive Elements

| ARIA | ASCII |
|------|-------|
| `button` | `[Label]` |
| `link` | `Label` or `[Label]` |
| `textbox` | `[placeholder...]` |
| `checkbox [checked]` | `[x]` |
| `checkbox` | `[ ]` |
| `combobox` | `[Value ▼]` |
| `tab [selected]` | `[Tab*]` |

### States

| State | Indicator |
|-------|-----------|
| `[selected]` | `*` |
| `[expanded]` | `▼` |
| `[collapsed]` | `▶` |
| `[disabled]` | `(disabled)` |
| `[current]` | `*` |

---

## Layout Patterns

### Single Column
```
┌─────────────────────┐
│ HEADER              │
├─────────────────────┤
│ MAIN_CONTENT        │
├─────────────────────┤
│ FOOTER              │
└─────────────────────┘
```

### Two Column (Sidebar)
```
┌─────────────────────────────┐
│ HEADER                      │
├─────────┬───────────────────┤
│ SIDEBAR │ MAIN_CONTENT      │
├─────────┴───────────────────┤
│ FOOTER                      │
└─────────────────────────────┘
```

### Three Column
```
┌─────────────────────────────────────┐
│ HEADER                              │
├─────────┬─────────────────┬─────────┤
│ LEFT    │ MAIN_CONTENT    │ RIGHT   │
├─────────┴─────────────────┴─────────┤
│ FOOTER                              │
└─────────────────────────────────────┘
```

---

## Common UI Patterns

### Navigation
| Pattern | ASCII |
|---------|-------|
| Breadcrumb | `Home > Section > Page` |
| Tab Bar | `[Tab1] [Tab2*] [Tab3]` |
| Sidebar | `• Item1\n• Item2*` |
| Pagination | `< 1 2 [3] 4 5 >` |

### Data Display
| Pattern | ASCII |
|---------|-------|
| Table | `│ Col │ Col │` |
| Card | `┌──┐\n│  │\n└──┘` |
| Key-Value | `Label: Value` |

### Feedback
| Pattern | ASCII |
|---------|-------|
| Success | `✓ Message` |
| Error | `✗ Message` |
| Warning | `⚠ Message` |
| Loading | `[···]` or `↻` |

---

## Multi-Page Flows

For user journeys, create an `_index.md`:

```markdown
# Site Documentation

## Navigation Map

┌─────────────────┐
│   Login Page    │
└────────┬────────┘
         │ [Sign In]
         ▼
┌─────────────────┐
│    Dashboard    │
└────────┬────────┘
         │ [Settings]
         ▼
┌─────────────────┐
│    Settings     │
└─────────────────┘

## Pages

| Page | URL | Purpose |
|------|-----|---------|
| [Login](login.md) | `/login` | Authentication |
| [Dashboard](dashboard.md) | `/dashboard` | Overview |
```

---

## Zone Naming Convention

| Pattern | Use For | Example |
|---------|---------|---------|
| `HEADER` | Top nav | Global navigation |
| `FOOTER` | Bottom | Legal, links |
| `SIDEBAR` | Vertical nav | Section nav |
| `PAGE_TITLE` | Main heading | h1 + description |
| `ACTIONS` | Action buttons | Primary CTAs |
| `{NAME}_SECTION` | Grouped content | `HEALTH_SECTION` |
| `{NAME}_TABLE` | Data tables | `USERS_TABLE` |
| `{NAME}_FORM` | Forms | `LOGIN_FORM` |

---

## Box Drawing Characters

```
Standard: ┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼
Rounded:  ╭ ╮ ╰ ╯
Heavy:    ┏ ┓ ┗ ┛ ━ ┃
Double:   ╔ ╗ ╚ ╝ ═ ║
```
