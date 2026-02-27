# Object-Oriented UX (OOUX) Methodology

Design products around objects (nouns) rather than features (verbs).

---

## Core Philosophy

```
TRADITIONAL APPROACH: Start with user actions, then find objects
OOUX APPROACH: Start with objects, then define their behaviors

TRADITIONAL = Verbs first: "Search, Filter, Add, Edit, Delete"
OOUX = Nouns first: "Product, Cart, Order, User, Review"

WHY OBJECTS FIRST:
• Objects are more stable than actions
• Users think in terms of things, not functions
• Objects create consistent mental models
• Reduces feature creep around arbitrary actions
```

### Benefits

```
FOR USERS:
• Intuitive navigation (find the thing, then act on it)
• Consistent interaction patterns per object type
• Clear mental model of system contents

FOR DESIGN:
• Scalable information architecture
• Reusable component patterns
• Clear content strategy

FOR DEVELOPMENT:
• Natural mapping to data models
• API structure follows objects
• Easier to maintain and extend
```

---

## The ORCA Process

**ORCA = Objects, Relationships, CTAs, Attributes**

### Step 1: Objects

Objects are the "things" in your system that users interact with. They are nouns, not verbs.

#### Object Identification Process

```
1. GATHER INPUTS
   • User research data
   • Business requirements
   • Existing content/data
   • Competitor analysis

2. EXTRACT NOUNS
   • List all nouns from inputs
   • Include both concrete and abstract nouns
   • Don't filter yet

3. EVALUATE EACH NOUN
   For each noun, ask:
   • Is this a thing users care about?
   • Does it have its own identity?
   • Can you have multiple instances?
   • Does it have attributes?
   • Can users take actions on it?

4. CATEGORIZE
   • OBJECT: Yes to most questions above
   • ATTRIBUTE: Describes an object, not standalone
   • ACTION: Verb disguised as noun
   • OUT OF SCOPE: Not relevant to this system
```

#### Object Types

| Type | Definition | Examples |
|------|------------|----------|
| Core objects | Primary things users interact with | Product, Article, Project |
| Supporting objects | Enable core objects | Category, Tag, Author |
| User objects | Represent people | User, Team, Organization |
| Container objects | Group other objects | Folder, Playlist, Cart |
| System objects | Represent system concepts | Notification, Message, Setting |

#### Object Evaluation Checklist

```
☐ Does it have a clear identity?
☐ Can there be multiple instances?
☐ Does it have its own attributes?
☐ Do users perform actions on it?
☐ Does it appear in multiple contexts?
☐ Would users recognize this as a "thing"?
```

---

### Step 2: Relationships

How objects relate to and reference each other.

#### Relationship Types

```
ONE-TO-ONE (1:1)
─────────────────────────────────────────────────
Each instance of A relates to exactly one instance of B.
Example: User → Profile

ONE-TO-MANY (1:N)
─────────────────────────────────────────────────
Each A can relate to multiple Bs.
Each B relates to exactly one A.
Example: Author → Articles

MANY-TO-MANY (M:N)
─────────────────────────────────────────────────
Each A can relate to multiple Bs.
Each B can relate to multiple As.
Example: Products ↔ Categories

NESTED (COMPOSITION)
─────────────────────────────────────────────────
B exists only within A.
Deleting A deletes B.
Example: Order → Line Items

REFERENCED (ASSOCIATION)
─────────────────────────────────────────────────
B exists independently of A.
Relationship is a link, not ownership.
Example: Article → Tags
```

#### Relationship Mapping Template

```
OBJECT A          RELATIONSHIP          OBJECT B
────────────────────────────────────────────────────
User              has many              Orders
Order             belongs to            User
Order             has many              Line Items
Line Item         belongs to            Order (nested)
Line Item         references            Product
Product           has many              Line Items
Product           has many              Categories
Category          has many              Products
```

#### Relationship → Navigation Patterns

```
1:1 relationship → Show inline or tab
  User ↔ Profile → Profile is tab or section of User

1:N relationship → Show as list on parent
  Author → Articles → Article list on Author page

M:N relationship → Show on both objects
  Product ↔ Categories → Categories on Product; Products in Category

Nested → Only accessible via parent
  Order → Line Items → Line Items only shown within Order
```

---

### Step 3: CTAs (Calls to Action)

Actions that can be performed on objects. CTAs are verbs that belong to specific objects.

#### CTA Identification Process

```
FOR EACH OBJECT, ASK:
1. What can users DO to this object?
2. What can users do WITH this object?
3. What can users do WITHIN this object?
4. What lifecycle stages does this object have?

COMMON CTA CATEGORIES:
• CRUD: Create, Read, Update, Delete
• STATE CHANGES: Publish, Archive, Activate, Complete
• SOCIAL: Share, Comment, Like, Follow
• ORGANIZATIONAL: Move, Copy, Tag, Group
• TRANSACTIONAL: Add to cart, Purchase, Subscribe
```

#### CTA Mapping Template

```
OBJECT: Product
─────────────────────────────────────────────────

PRIMARY CTAs (key actions):
• Add to Cart
• Buy Now

SECONDARY CTAs (supporting actions):
• Save to Wishlist
• Share
• Compare

MANAGEMENT CTAs (object lifecycle):
• [Admin] Edit
• [Admin] Publish / Unpublish
• [Admin] Delete

RELATIONSHIP CTAs (related objects):
• View Reviews
• See Similar Products
• Browse Category
```

#### CTA Placement Rules

```
PRIMARY CTA:
• Most prominent position
• Clear visual weight
• Reduced friction

SECONDARY CTAs:
• Visible but subordinate
• May be grouped in menu
• Lower visual weight

DESTRUCTIVE CTAs:
• Separated from primary actions
• Confirmation required
• Clear warning styling

CONTEXTUAL CTAs:
• Appear based on object state
• Example: "Mark Complete" only on incomplete items
```

---

### Step 4: Attributes

Properties that describe objects. Attributes are the metadata of objects.

#### Attribute Types

```
IDENTIFYING ATTRIBUTES:
• What makes this instance unique
• Examples: Name, Title, ID, Username

DESCRIPTIVE ATTRIBUTES:
• Additional information about the object
• Examples: Description, Bio, Summary

MEDIA ATTRIBUTES:
• Visual or file content
• Examples: Photo, Avatar, Attachment

STATUS ATTRIBUTES:
• Current state of the object
• Examples: Status, Published, Active

TEMPORAL ATTRIBUTES:
• Time-related properties
• Examples: Created, Modified, Due Date

RELATIONAL ATTRIBUTES:
• References to other objects
• Examples: Author, Category, Tags

COMPUTED ATTRIBUTES:
• Derived from other data
• Examples: Age (from birthdate), Total (from line items)
```

#### Attribute Prioritization

```
CORE ATTRIBUTES:
• Essential to object identity
• Always displayed
• Example: Product name, price

EXTENDED ATTRIBUTES:
• Useful additional detail
• Displayed in detail views
• Example: Product dimensions, materials

METADATA:
• System or management info
• Displayed in admin or on hover
• Example: Created date, view count
```

---

## Object Mapping

### Object Map Format

```
┌─────────────────────────────────────────────────────────────┐
│ OBJECT: [Object Name]                                       │
├─────────────────────────────────────────────────────────────┤
│ CORE CONTENT (identifying attributes)                       │
│ • Name/Title                                                │
│ • Description                                               │
│ • [Key visual: image, icon]                                 │
├─────────────────────────────────────────────────────────────┤
│ METADATA (extended attributes)                              │
│ • Status                                                    │
│ • Created/Modified                                          │
│ • [Additional properties]                                   │
├─────────────────────────────────────────────────────────────┤
│ NESTED OBJECTS                                              │
│ • [Child objects contained within]                          │
├─────────────────────────────────────────────────────────────┤
│ RELATED OBJECTS (M:N relationships)                         │
│ • [Linked objects]                                          │
├─────────────────────────────────────────────────────────────┤
│ CTAs                                                        │
│ Primary: [Main action]                                      │
│ Secondary: [Other actions]                                  │
└─────────────────────────────────────────────────────────────┘
```

### Example: Recipe Object

```
┌─────────────────────────────────────────────────────────────┐
│ OBJECT: Recipe                                              │
├─────────────────────────────────────────────────────────────┤
│ CORE CONTENT                                                │
│ • Title                                                     │
│ • Hero Image                                                │
│ • Description                                               │
│ • Prep Time                                                 │
│ • Cook Time                                                 │
│ • Servings                                                  │
├─────────────────────────────────────────────────────────────┤
│ METADATA                                                    │
│ • Author (→ User)                                           │
│ • Date Published                                            │
│ • Difficulty Level                                          │
│ • Rating (computed)                                         │
│ • Save Count (computed)                                     │
├─────────────────────────────────────────────────────────────┤
│ NESTED OBJECTS                                              │
│ • Ingredients (list)                                        │
│ • Steps (ordered list)                                      │
│ • Nutrition Info                                            │
├─────────────────────────────────────────────────────────────┤
│ RELATED OBJECTS                                             │
│ • Categories (M:N)                                          │
│ • Tags (M:N)                                                │
│ • Reviews (1:N)                                             │
│ • Similar Recipes (computed M:N)                            │
├─────────────────────────────────────────────────────────────┤
│ CTAs                                                        │
│ Primary: Save Recipe, Start Cooking                         │
│ Secondary: Share, Print, Rate, Comment                      │
│ Management: Edit, Delete (author only)                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Object-Oriented Navigation

### Navigation Principle

```
TRADITIONAL: Organize by feature/function
  Dashboard | Tasks | Calendar | Reports | Settings

OOUX: Organize by object type
  Projects | Tasks | People | Files

WHY OBJECT-BASED NAV:
• Users look for things, then act on them
• Objects are more memorable than features
• Consistent mental model
```

### Object-Based Navigation Patterns

**Pattern 1: Object-type navigation**
```
TOP LEVEL: List of object types
SECOND LEVEL: List of instances
THIRD LEVEL: Object detail

EXAMPLE (Project Management):
Projects → Project List → Project Detail
   └── Tasks → Task List → Task Detail
   └── People → People List → Person Detail
```

**Pattern 2: Object as context**
```
SELECT CONTEXT OBJECT, THEN SEE RELATED OBJECTS

EXAMPLE:
Select Project: "Website Redesign"
   └── Now see: Tasks, Files, People for THIS project

BENEFITS:
• Scopes data to relevant context
• Reduces cognitive load
• Natural mental model
```

**Pattern 3: Object-focused dashboard**
```
INSTEAD OF: Feature widgets (Activity, Analytics, etc.)
USE: Object counts and previews

┌─────────────┬─────────────┬─────────────┐
│ 12 Projects │ 45 Tasks    │ 8 People    │
│ 3 need attn │ 12 due soon │ 2 pending   │
│ [View all]  │ [View all]  │ [View all]  │
└─────────────┴─────────────┴─────────────┘
```

---

## Object Instance Views

### Collection View (List/Grid)

```
PURPOSE: Browse and find instances
SHOWS: Core content, key metadata, primary CTA
PATTERN: Card grid, data table, or list

DESIGN RULES:
• Scannable format
• Enough info to differentiate instances
• Sort and filter options
• Primary CTA accessible (e.g., "Open")
```

### Detail View (Single Instance)

```
PURPOSE: Full information and actions on one object
SHOWS: All attributes, nested objects, related objects, all CTAs

STRUCTURE:
1. Header: Title, key visual, primary CTA
2. Core content: Description, main attributes
3. Nested objects: Inline or tabbed
4. Related objects: Linked lists
5. Metadata: Secondary info, timestamps
6. Actions: All available CTAs
```

### Compact View (Preview/Snippet)

```
PURPOSE: Reference when object appears in context
SHOWS: Identifying info only
EXAMPLE: Author byline, product in cart, mention in text

DESIGN RULES:
• Minimal but recognizable
• Link to detail view
• Consistent treatment everywhere
```

### Object Component Pattern

```
PRINCIPLE: Same object, same component, everywhere

EXAMPLE - User object appears:
• In article byline → User snippet
• In team list → User card
• On profile page → User detail
• In comment → User avatar + name

ALL USE SAME:
• Visual treatment
• Data structure
• Interaction pattern (click → profile)
```

---

## OOUX Evaluation

### Audit Checklist

```
OBJECT IDENTIFICATION:
☐ Are all core objects identified?
☐ Are objects distinct (no overlap)?
☐ Are objects at appropriate granularity?
☐ Do users recognize these as "things"?

RELATIONSHIPS:
☐ Are all relationships mapped?
☐ Is relationship cardinality clear?
☐ Do relationships match user mental models?
☐ Are nested vs. referenced objects correct?

CTAs:
☐ Does each object have clear CTAs?
☐ Are CTAs prioritized appropriately?
☐ Are CTAs consistent across object types?
☐ Are destructive CTAs protected?

ATTRIBUTES:
☐ Are core attributes identified?
☐ Is attribute priority clear?
☐ Are computed attributes identified?
☐ Are attributes consistent with data model?

NAVIGATION:
☐ Is navigation object-based?
☐ Can users find any object type?
☐ Can users find specific instances?
☐ Are object relationships navigable?
```

### Common OOUX Mistakes

```
MISTAKE: Treating features as objects
EXAMPLE: "Search" is not an object; "Saved Search" might be
FIX: Objects have instances; features don't

MISTAKE: Over-nesting objects
EXAMPLE: Making "Address" a nested object when it could be reused
FIX: If object is referenced elsewhere, don't nest

MISTAKE: Missing relationship navigation
EXAMPLE: Showing Order but not linking to Customer
FIX: All relationships should be navigable

MISTAKE: Inconsistent object treatment
EXAMPLE: "User" card looks different in different contexts
FIX: Same object = same component = same styling

MISTAKE: Verb-based navigation
EXAMPLE: "Create | Manage | Analyze" instead of "Projects | Reports"
FIX: Navigate to objects, then act on them
```

---

## OOUX Workshop Template

### Part 1: Object Extraction (30 min)

```
1. Share research findings, requirements, existing content
2. Each participant writes nouns on sticky notes (5 min)
3. Post all notes on wall
4. Group similar notes
5. Vote on which are true objects vs. attributes/actions
```

### Part 2: Relationship Mapping (30 min)

```
1. Place confirmed objects as nodes
2. Draw lines between related objects
3. Label each relationship (1:1, 1:N, M:N)
4. Identify nested vs. referenced
5. Check for missing connections
```

### Part 3: CTA Definition (30 min)

```
For each object:
1. List all possible actions
2. Categorize as Primary/Secondary/Management
3. Identify state-dependent CTAs
4. Map CTAs to user roles
```

### Part 4: Attribute Priority (30 min)

```
For each object:
1. List all attributes
2. Sort into Core/Extended/Metadata
3. Define which views show which attributes
4. Identify computed attributes
```

### Output: Object Map Document

```
For each object, create documentation:
• Object map diagram
• Attribute specification
• Relationship list
• CTA inventory
• View specifications (collection, detail, compact)
```
