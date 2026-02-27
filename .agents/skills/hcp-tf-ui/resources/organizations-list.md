# Organizations List

**URL**: `/app/organizations` (also `/app`)
**Title**: Organizations | HCP Terraform
**Purpose**: List and manage all organizations the user has access to, and create new organizations

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│ HEADER: Logo | OrgSwitcher("Choose an org") | Help | User   │
├───────────┬─────────────────────────────────────────────────┤
│           │ PAGE_HEADER                                     │
│ SIDEBAR   │ "Organizations"                                 │
│           │ Description: Terraform organizations let you    │
│ • Organiz*│ manage organizations, projects, and teams.      │
│           │ [Create organization] link                      │
│           ├─────────────────────────────────────────────────┤
│           │ SEARCH: [Search by organization name...]        │
│           ├─────────────────────────────────────────────────┤
│           │ ORGANIZATIONS_TABLE                             │
│           │ ┌───────────────────────────────────────────────┐
│           │ │ Org name      │ Organization type  │ Actions │
│           │ ├───────────────┼────────────────────┼─────────┤
│           │ │ ai-debugging  │ [TF] Terraform     │   [⋮]   │
│           │ │               │ standalone         │         │
│           │ ├───────────────┼────────────────────┼─────────┤
│           │ │ hashicorp-v2  │ [TF] Terraform     │   [⋮]   │
│           │ │               │ standalone         │         │
│           │ │               │ SSO enabled        │         │
│           │ ├───────────────┼────────────────────┼─────────┤
│           │ │ ...           │ ...                │   ...   │
│           │ └───────────────────────────────────────────────┘
│           ├─────────────────────────────────────────────────┤
│           │ PAGINATION                                      │
│           │ 1-10 of 17 | [1] [2] [>] | Items per page [10▼] │
├───────────┴─────────────────────────────────────────────────┤
│ FOOTER: Support | Terms | Privacy | Security | Accessibility│
└─────────────────────────────────────────────────────────────┘
```

## Zones

| Zone | Purpose | Contents | Extensibility |
|------|---------|----------|---------------|
| HEADER | Global context | Logo, org switcher (shows "Choose an organization"), help, user menu | Global actions |
| SIDEBAR | Minimal navigation | Only "Organizations" link at this level | N/A |
| PAGE_HEADER | Page identity | Heading, description, Create organization link | N/A |
| SEARCH | Filter organizations | Search box with auto-update | N/A |
| ORGANIZATIONS_TABLE | Organization list | Table with name, type, and actions | New table columns |
| PAGINATION | Navigate pages | Count, page numbers, items per page selector | System managed |
| FOOTER | Legal/support | Support, Terms, Privacy, Security, Accessibility | System managed |

## Patterns

| Pattern | Structure | Example | Used For |
|---------|-----------|---------|----------|
| Org Switcher (No Org) | Button showing "Choose an organization" | Header switcher | Before org is selected |
| Page Header with Link | Heading + description + action link | Organizations header | Page introduction |
| Live Search | Search box with auto-update results | "Search by organization name" | Instant filtering |
| Organization Row | Name link + type info + overflow menu | Table row | Each organization entry |
| Org Type Cell | Icon + type label + optional badges | Terraform icon + "Terraform standalone" | Organization type display |
| SSO Badge | Text badge in type cell | "SSO enabled" | SSO status indicator |
| Overflow Menu | Icon button with dropdown | `[⋮]` button | Per-row actions |
| Numbered Pagination | Count + page numbers + next/prev + items selector | "1-10 of 17 [1] [2]" | Page navigation |
| Items Per Page | Dropdown selector | "Items per page [10▼]" | Page size control |

## Organization Types

| Type | Icon | Description |
|------|------|-------------|
| Terraform standalone | Terraform logo | Standard HCP Terraform organization |

## Organization Row Features

| Feature | Description |
|---------|-------------|
| Organization name | Clickable link to enter organization |
| Organization type | Shows platform type with icon |
| SSO enabled badge | Displayed if SSO is configured |
| Overflow options | Actions menu (edit, delete, etc.) |

## Clickable Elements

| Element | Location | Destination | File |
|---------|----------|-------------|------|
| Logo | HEADER | `/app` (stays on org list) | organizations-list.md |
| Choose an organization | HEADER | Opens org dropdown | - |
| Help menu | HEADER | Opens help dropdown | - |
| User menu | HEADER | Opens user dropdown | - |
| Organizations | SIDEBAR | `/app/organizations` | organizations-list.md |
| [Create organization] | PAGE_HEADER | `/app/organizations/new` | - |
| Organization name link | ORGANIZATIONS_TABLE | `/app/{org}` (enters organization) | projects-list.md |
| More information button | ORGANIZATIONS_TABLE | Shows org type details tooltip | - |
| Overflow options | ORGANIZATIONS_TABLE | Opens actions dropdown | - |
| Page number | PAGINATION | `/app/organizations?page={n}` | - |
| Next page | PAGINATION | Next page of results | - |
| Items per page | PAGINATION | Changes page size | - |

## Notes

- This page is shown when no organization is selected
- The org switcher in header shows "Choose an organization" instead of an org name
- Clicking an organization name enters that organization and redirects to its projects page
- The sidebar is minimal with only "Organizations" link (no Manage/Visibility/Cloud Platform groups)
- Pagination supports page sizes: 10, 20, 50, 100
