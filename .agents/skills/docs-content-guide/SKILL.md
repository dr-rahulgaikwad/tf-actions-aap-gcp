---
name: docs-content-guide
description: Content guide for developer.hashicorp.com using the Diátaxis method, templates, and navigation guidance. Use when creating, updating, or organizing HashiCorp docs content.
---

# HashiCorp Documentation Content Guide

Guide to creating content for developer.hashicorp.com following the Diátaxis method and HashiCorp content standards.

## What is This Guide?

This guide helps HashiCorp employees and contributors create high-quality documentation for developer.hashicorp.com. It covers:
- **Content types** based on the Diátaxis method
- **Content templates** for different page types
- **Creating new pages** and adding them to navigation
- **Redirects** for moved or renamed pages
- **Style guidelines** (see `/docs-style-guide` skill)

## When to Use This Guide

Use this guide when:
- Creating new documentation pages
- Updating existing documentation
- Moving or reorganizing content
- Choosing the right content type for your topic
- Following HashiCorp documentation standards
- Contributing to product documentation repos

## Documentation Framework: Diátaxis Method

HashiCorp documentation follows the [Diátaxis method](https://diataxis.fr/), which organizes content into four types based on user needs:

```
                 Practical        Theoretical
Learning     │   Tutorials    │   Explanation   │
─────────────┼────────────────┼─────────────────┤
Using        │   Usage (How-to)│   Reference    │
```

### Content Type Definitions

**Tutorials** (Learning-oriented, practical):
- Hosted in separate repository (tutorials.hashicorp.com)
- Step-by-step learning experiences
- For beginners getting started
- **This guide focuses on the other three types**

**Usage / How-to** (Task-oriented, practical):
- Step-by-step instructions for specific tasks
- Assumes some prior knowledge
- Goal: Complete a specific operation
- Examples: "Configure TLS", "Deploy with Kubernetes"

**Explanation / Concept** (Understanding-oriented, theoretical):
- Explains how things work and why
- Provides background and context
- Goal: Understand a topic or system
- Examples: "Consul Catalog", "Vault Tokens"

**Reference** (Information-oriented, theoretical):
- Technical specifications and details
- API docs, CLI commands, configuration options
- Goal: Look up specific information
- Examples: API endpoints, CLI flags, config parameters

### Explanation Content Subtypes

Within "Explanation" content, we use three page types:

**Index Pages**:
- Provide lists of links to supporting documentation
- Organize content by topic
- Minimal explanatory text
- Example: [Deploy Consul](https://developer.hashicorp.com/consul/docs/deploy)

**Overview Pages**:
- Central information point for a topic area
- Introduce concepts and workflows
- Link to usage, tutorials, and reference docs
- Example: [Expand service network east/west](https://developer.hashicorp.com/consul/docs/east-west)

**Concept Pages**:
- Explain underlying systems and operations
- Define terms and constructs
- Provide context and background
- Example: [Consul catalog](https://developer.hashicorp.com/consul/docs/concept/catalog)

## Content Templates

### Usage / How-to Template

**Purpose**: Guide users through completing a specific task.

**Structure**:
```markdown
---
page_title: Match the H1 and nav title
description: |-
  Include target keywords and keyword phrases for searchability.
---

# Title

Explain what the topic is about.

## Requirements

Describe prerequisites:
- System requirements
- Environment setup
- Software versions
- Product version constraints

## Steps

[Introduction to the procedure or start directly with steps]

1. Set environment variables as the first step. Link to [reference docs](link):

   ```bash
   export VARIABLE_NAME="value"
   ```

   Provide additional context as needed.

2. Configure a file. Link to [reference documentation](link):

   ```hcl
   resource "example" "demo" {
     name = "example"
   }
   ```

3. Execute final command. Link to [reference docs](link):

   ```bash
   command --flag value
   ```

   Explain the response or outcome:

   ```
   Success message or output
   ```

## Next steps

Link to related tasks that enhance this topic or achieve a larger goal.
Link to other **usage pages**, not concepts or reference.

- [Related task 1](link)
- [Related task 2](link)
```

**Key Guidelines**:
- Always link to reference documentation for commands/configs
- Use appropriate code blocks with syntax highlighting
- Provide context for each step
- Next steps should be actionable tasks, not concepts

### Concept Template

**Purpose**: Explain terms, systems, and how things work.

**Structure**:
```markdown
---
page_title: Page title matches the H1
description: |-
  Learn about the {topic} concepts for using {product}. Elaborate as needed.
---

# Page Title

The first paragraph is the page description. It introduces the topic by
summarizing the content and explaining the overarching idea.

## Context (Optional)

Use one of these section types immediately after description:

- **Introduction**: Introduce terms, components, workflows
- **Background**: Provide historical or situational context

## Concept 1

*Concept* is defined in the first sentence. The second sentence explains
its importance. The third sentence provides additional information.

Use multiple paragraphs if necessary. [Link to other concepts](#concept-2)
or [external resources](https://developer.hashicorp.com) as needed.

## Concept 2

Treat concept pages as the reference for ideas and constructs. Other content
should link here for definitions. Be concise but thorough.

## Concept 3

Include images or diagrams as necessary. Always introduce images with text:

![Descriptive alt text for accessibility](/public/img/example.png)

Always follow images with explanatory text.
```

**Key Guidelines**:
- Define concepts in the first sentence
- Explain importance and relationships
- Link between related concepts
- Use diagrams to clarify complex ideas
- Keep explanations concise but complete

### Overview Template

**Purpose**: Serve as a central hub for a topic area with workflows and links.

**Structure**:
```markdown
---
page_title: Overview topic template
description: |-
  {Feature} is {description} that you can use to {actions}. Learn how
  {feature} can help you {user goals}.
---

# Title

Describe the page's content in first paragraph.

## Introduction (Optional)

Describe why the topic area is important.

## Workflows

Summarize main usage steps for this topic area.

### Primary workflow

The process for {end goal} consists of:

1. First action. Keep steps short and action-oriented.
2. Second action. Maintain symmetry in step descriptions.
3. Final action. After this, users take organization-specific actions.

Link to [dedicated usage page](link) if one exists.

### Alternative workflow

To {achieve secondary goal}, complete these steps:

- First action for this workflow.
- Second action.
- Final action.

## Subtopics

Describe additional characteristics about the topic area.

### Nested subtopic

Group information logically.

### Nested subtopic

- Use bulleted lists for three or more components.
- Include diagrams, video, and media as necessary.
- Use subheadings to organize information.

## Guidance

Help users understand where to go next.

### Tutorials

- To learn {tutorial goal}, complete [Tutorial Name](link).

### Usage documentation

Group links by workflow order and nav bar order:

- [Usage page title](link)
- [Usage page title](link)

### Runtime specific documentation

Separate by environment or runtime:

- [Usage page title](link)
- [Usage page title](link)

### Reference

List all relevant reference pages:

- [Reference page title](link)
- [Reference page title](link)

### Constraints, limitations, and troubleshooting

List limitations and workarounds:

- Limitation description and alternate approach.
- Constraint description.
```

**Key Guidelines**:
- Serve as a hub linking to other content
- Summarize workflows at high level
- Group links logically by workflow or runtime
- Include constraints and limitations
- Make it easy to find next steps

### Reference Template

**Purpose**: Provide technical specifications and lookup information.

**Guidelines**:
- Find an existing reference page in your product as a template
- Common types: Configuration, CLI, API
- Include all parameters, flags, options
- Provide default values and constraints
- Use consistent formatting within product docs

## Creating a New Page

Follow these steps to add new documentation:

### 1. Decide Content Type

Determine if your content is:
- **Usage** (how to do something)
- **Concept** (explain how something works)
- **Overview** (hub for a topic area)
- **Reference** (technical specifications)

Refer to templates above and the [Diátaxis method](https://diataxis.fr/).

### 2. Create the Page File

**Choose the directory**:
- Documentation: `docs/` directory
- CLI: `commands/`, `docs/commands/`, or `docs/cli/`
- API: `api-docs/` (check if auto-generated first)

The directory path becomes the URL. For example:
```
content/vault/v1.20.x/docs/concepts/tokens.mdx
→ https://developer.hashicorp.com/vault/docs/concepts/tokens
```

**Create the file**:
- Name: `my-page.mdx` (short, descriptive, no folder name repetition)
- Location: Appropriate subdirectory
- Format: MDX (Markdown with JSX components)

### 3. Write Your Content

Use the appropriate template:
- Usage template for how-to guides
- Concept template for explanations
- Overview template for topic hubs
- Existing reference page as template for technical specs

Follow the [Top 12 Style Guidelines](#top-12-style-guidelines).

### 4. Add to Navigation Sidebar

**Location**: Product's `<version>/data/` directory
- Example: `content/vault/v1.20.x/data/docs-nav-data.json`
- File: `docs-nav-data.json` for `docs/` directory

**Format**:
```json
{
  "title": "Section Name",
  "routes": [
    {
      "title": "Overview",
      "path": "concepts"
    },
    {
      "title": "Page Title",
      "path": "concepts/my-page"
    }
  ]
}
```

**Key Points**:
- Hierarchy must match filesystem structure
- Ordering is flexible within sections
- `title`: Human-readable name in nav
- `path`: URL path without `.mdx` extension
- Index files: Use `"path": "directory"` not `"path": "directory/index"`

**Nested sections**:
```json
{
  "title": "Parent Section",
  "routes": [
    {
      "title": "Overview",
      "path": "parent"
    },
    {
      "title": "Nested Section",
      "routes": [
        {
          "title": "Overview",
          "path": "parent/nested"
        },
        {
          "title": "Nested Page",
          "path": "parent/nested/page"
        }
      ]
    }
  ]
}
```

**External links**:
```json
{
  "title": "External Resource",
  "href": "https://www.hashicorp.com/tao-of-hashicorp"
}
```

## Using Redirects

**When to add redirects**: Whenever you move or rename an existing page.

### Unversioned Products (Cloud Products)

Add **one redirect**:

```json
{
  "source": "/old/path",
  "destination": "/new/path",
  "permanent": true
}
```

### Versioned Products

Add **three redirects** to handle all version scenarios:

1. **Latest version** (no version in URL):
```json
{
  "source": "/terraform/old-path",
  "destination": "/terraform/new-path",
  "permanent": true
}
```

2. **Back-facing** (old path in older versions):
```json
{
  "source": "/terraform/v:version(1\\.(?:[0-9])\\.x)/new-path",
  "destination": "/terraform/v:version/old-path",
  "permanent": true
}
```

3. **Forward-facing** (new path in newer versions):
```json
{
  "source": "/terraform/v:version(1\\.(?:1[0-9]|[2-9][0-9])\\.x)/old-path",
  "destination": "/terraform/v:version/new-path",
  "permanent": true
}
```

### Redirect File Location

- Versioned: `content/<product>/<version>/redirects.jsonc`
- Example: `content/vault/v1.20.x/redirects.jsonc`
- Only the **most recent** redirect file is used

### Redirect Slug Types

**Placeholders** (single path segment):
- Source: `:<name>`
- Matches: Single segment only
- Example: `/path/:slug` matches `path/foo` but not `path/foo/bar`

**Wildcards** (all subpaths):
- Source: `:<name>*`
- Destination: `:<name>*` (must include `*`)
- Matches: Root and all subpaths
- Example: `/path/:slug*` matches `path`, `path/`, `path/foo`, `path/foo/bar`

**Named parameters** (pattern matching):
- Source: `:<name>(<pattern>)`
- Destination: `:<name>`
- Example: `/:version(1\\.(?:9|1[0-5])\\.x)` matches `1.9.x` through `1.15.x`

### Pattern Matching Syntax

Special characters:
- `(` `)` - Wrap patterns and non-capture groups
- `[` `]` - Single-character ranges
- `-` - Define ranges (e.g., `[0-9]`, `[a-z]`)
- `\\` - Escape special characters or use character classes
- `*` - Match zero or more times
- `+` - Match one or more times
- `?` - Match zero or one times
- `{ min, max }` - Match between min and max times
- `?:` - Non-capture group
- `?!` - Negative look-ahead
- `|` - Alternative strings (use `\\|` in tables)

Character classes:
- `\\d` - Single digits (0-9)
- `\\w` - Word characters (alphanumeric + underscore)
- `\\s` - Whitespace

### Redirect Examples

**Redirect all child paths**:
```json
{
  "source": "/old/path/:slug*",
  "destination": "/new/path/:slug*",
  "permanent": true
}
```

**Version-specific redirects**:
```json
{
  "source": "/vault/docs/v:version(1\\.(?:12|13)\\.x)/new/path",
  "destination": "/vault/docs/v:version/old/path",
  "permanent": true
}
```

**Exclude specific paths**:
```json
{
  "source": "/vault/docs/agent/:slug((?!autoauth$).*)",
  "destination": "/vault/docs/agent-and-proxy/agent/:slug",
  "permanent": true
}
```

### Redirect Limitations

- Only the most recent redirect file is compiled
- Backfacing redirects must be perpetuated to future versions
- Cannot split redirects across multiple files
- Non-capture group for subpaths requires `/` in the path

## Top 12 Style Guidelines

From the [HashiCorp Documentation Style Guide](#):

1. **Use active voice**: "Terraform creates infrastructure" not "Infrastructure is created by Terraform"

2. **Use present tense**: "Vault stores secrets" not "Vault will store secrets"

3. **Address the reader directly**: "You can configure" not "Users can configure"

4. **Be concise**: Remove unnecessary words. "To deploy" not "In order to deploy"

5. **Use descriptive link text**: "Learn about [Terraform modules]" not "Click [here]"

6. **Write for global audience**: Avoid idioms, colloquialisms, cultural references

7. **Use sentence case for headings**: "Configure the server" not "Configure the Server"

8. **One idea per sentence**: Break complex sentences into multiple simple ones

9. **Use bullet lists for 3+ items**: Makes content scannable

10. **Spell out acronyms on first use**: "HashiCorp Configuration Language (HCL)"

11. **Use `code` formatting for**: Commands, filenames, code, variables, values

12. **Include alt text for images**: Describe what the image shows for accessibility

For complete style guidelines, see the `/docs-style-guide` skill.

## Best Practices

### Content Organization

**Front-load important information**:
- Put the most important info first
- Use inverted pyramid structure
- Don't bury key steps in long paragraphs

**Use headings to organize**:
- H1 (`#`) - Page title only
- H2 (`##`) - Main sections
- H3 (`###`) - Subsections
- Don't skip heading levels

**Make content scannable**:
- Use bullet lists
- Keep paragraphs short (3-4 sentences)
- Use bold for emphasis sparingly
- Include code examples

### Linking Best Practices

**Link to**:
- Reference docs for commands, configs, API endpoints
- Related usage docs in "Next steps"
- Concept pages for term definitions
- External resources when relevant

**Don't link to**:
- The same page (except TOC links)
- Pages that don't exist yet
- Internal HashiCorp resources (for public docs)

**Link text**:
- ✅ "See the [configuration reference](link)"
- ✅ "Learn more about [Vault tokens](link)"
- ❌ "Click [here](link) for more info"
- ❌ "[Link](link)" with no context

### Code Blocks

**Always specify language**:
```markdown
```bash
terraform init
```

```hcl
resource "aws_instance" "example" {
  ami = "ami-123456"
}
```

**Highlight important parts**:
```markdown
```hcl {2,5-7}
resource "aws_instance" "example" {
  ami = "ami-123456"  # Highlighted
  instance_type = "t2.micro"

  tags = {            # Highlighted
    Name = "example"  # Highlighted
  }                   # Highlighted
}
```

**Use appropriate language tags**:
- `bash`, `shell-session` - Commands
- `hcl` - Terraform/Nomad/Consul configs
- `json` - JSON files
- `yaml` - YAML files
- `go` - Go code
- `javascript` - JavaScript code

### Frontmatter

Always include:
```yaml
---
page_title: Page Title
description: |-
  Concise description with keywords for SEO. Shows in search results.
---
```

Optional frontmatter:
```yaml
---
page_title: Page Title
description: Description text
sidebar_title: Custom Nav Title  # If different from page_title
---
```

## Troubleshooting

### Page Not Showing in Navigation

**Problem**: Created page but it doesn't appear in sidebar.

**Solutions**:
1. Check you added entry to `docs-nav-data.json`
2. Verify path matches filesystem (minus `.mdx`)
3. Ensure JSON syntax is valid (no trailing commas)
4. Check you're editing the correct version's nav file
5. Rebuild dev server if running locally

### Redirect Not Working

**Problem**: Old URL still shows 404.

**Solutions**:
1. Verify redirect is in the most recent version's `redirects.jsonc`
2. Check JSON syntax (trailing commas break JSON)
3. Ensure source path is correct
4. Test destination path loads directly
5. Clear browser cache
6. For versioned redirects, verify version pattern matches

### Build Errors

**Problem**: Build fails with MDX errors.

**Solutions**:
1. Check all code blocks have closing ` ``` `
2. Verify frontmatter YAML syntax
3. Ensure no unescaped characters in JSX
4. Check component syntax if using MDX components
5. Look for unclosed HTML tags

## Additional Resources

### Reference Documentation

- [content-types.md](./content-types.md) - Detailed content type explanations and templates
- [create-new-page.md](./create-new-page.md) - Step-by-step page creation guide
- [redirects.md](./redirects.md) - Comprehensive redirect documentation

### Related Skills

- `/docs-style-guide` - Complete HashiCorp documentation style guide
- `/hashicorp` - How HashiCorp works (document workflows)
- `/google-docs` - Google Docs collaboration (for drafting)

### External Resources

- [Diátaxis Framework](https://diataxis.fr/) - Documentation methodology
- [developer.hashicorp.com](https://developer.hashicorp.com/) - HashiCorp Developer portal
- [Internal Technical Writing Wiki](https://hashicorp.atlassian.net/wiki/x/eYBVnw) - HashiCorp employees only

### Product Documentation Repos

Each product has its own documentation:
- Terraform: `hashicorp/terraform-docs-common`
- Vault: `hashicorp/vault-docs-common`
- Consul: `hashicorp/consul-docs-common`
- Nomad: `hashicorp/nomad-docs-common`
- [etc.]

All product docs are unified in `hashicorp/web-unified-docs` for building.

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
