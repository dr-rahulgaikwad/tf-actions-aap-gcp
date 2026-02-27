---
name: rfc
description: Guide for writing and reviewing technical RFCs at HashiCorp. Use when proposing architecture changes, API updates, or technical design decisions.
---

# RFC (Request for Comments)

Guide to writing and reviewing technical RFCs at HashiCorp.

## What is an RFC?

An **RFC (Request for Comments)** is HashiCorp's primary document for proposing technical changes, architecture decisions, and implementation details. RFCs enable asynchronous collaboration, preserve technical context, and help teams align on solutions before writing code.

RFCs are **consensus-driven** rather than requiring formal approval. The goal is to gather feedback, address concerns, and build shared understanding.

## When to Use an RFC

### Use RFC For:

- **Architecture changes**: New subsystems, refactoring, design patterns
- **API changes**: External or internal API modifications
- **Technical decisions**: Database schemas, caching strategies, data models
- **Cross-team changes**: Features spanning multiple teams or products
- **Breaking changes**: Modifications affecting backwards compatibility
- **Performance optimizations**: Major performance initiatives
- **Security changes**: Authentication, authorization, encryption approaches

### Don't Use RFC For:

- **Product requirements**: Use PRD instead (what to build, user problems)
- **Product vision**: Use PRFAQ instead (customer narrative, why now)
- **Simple bug fixes**: Direct implementation for single-component fixes
- **Quick decisions**: Use Memo for small-scope proposals
- **Code reviews**: Use GitHub pull requests for implementation feedback

### Decision Matrix:

```
Small change (< 1 week, single component)
  └─ No RFC needed, direct implementation or Memo

Medium change (1-4 weeks, multiple components)
  └─ RFC with focused scope

Large change (> 1 month, cross-team)
  ├─ PRFAQ (if customer-facing feature)
  ├─ PRD (product requirements)
  └─ RFC (technical implementation)
```

## RFC Structure

### Required Sections

```
[RFC] Title
├─ Overview (1-2 paragraphs)
├─ Background
├─ Proposal
├─ Implementation (optional but recommended)
├─ UX/UI (if user-facing changes)
└─ Abandoned Ideas (optional but valuable)
```

### 1. Title

Format: `[RFC] Enable Widgets in Product`

**Guidelines**:
- Action-oriented (Enable, Add, Update, Refactor)
- Specific and concise
- Product/component name included
- Keep under 10 words

**Examples**:
- ✅ `[RFC] Enable Widgets in Product Summary`
- ✅ `[RFC] Add Multi-Region Support to Vault`
- ✅ `[RFC] Refactor Nomad Scheduler Algorithm`
- ❌ `[RFC] Widgets` (too vague)
- ❌ `[RFC] This is about the widget feature we discussed` (too long)

### 2. Header Table

```
| [RFC] Enable Widgets in Product Summary  |  |
| :---- | :---- |
| **Created:** Jan 22, 2019 | **Status: WIP** | In-Review | Approved | Obsolete |
| **Current Version:** 1.0.4 | **Owner:** email@hashicorp.com |
| **Target Version:** 1.1.0 | **Contributors:** email@hashicorp.com |
| **PRD:** Link if applicable | **Approvers:** person@hashicorp.com |
```

**Fields**:
- **Created**: Date RFC was first written
- **Status**: WIP → In-Review → Approved → Obsolete
- **Current/Target Version**: Product versions
- **Owner**: Primary author responsible for RFC
- **Contributors**: Co-authors and major contributors
- **Approvers**: Key stakeholders (optional, RFCs are consensus-driven)
- **PRD**: Link to related Product Requirements Doc

### 3. Overview (1-2 Paragraphs)

**Purpose**: Explain the RFC's goal without diving into "why", "why now", or "how".

**Guidelines**:
- **Be concise**: 1-2 paragraphs maximum
- **State the goal**: What will this RFC propose?
- **No details yet**: Save the "why" for Background, "how" for Proposal
- **Clarity for newcomers**: Anyone should understand the intent

**Example**:
```
This RFC proposes adding a widget system to Terraform Cloud's product summary
page. The widget system will allow community members to build custom
visualizations and integrations that expand the use cases of our product.

The proposal outlines the widget API design, security model, and integration
points with the existing product architecture. It covers both the technical
implementation and the developer experience for widget authors.
```

### 4. Background

**Purpose**: Provide full context so newcomers can understand why this change is necessary.

**Guidelines**:
- **At least 2 paragraphs**: Can take a full page for complex topics
- **Newcomer-friendly**: New employees or team transfers should understand
- **Link liberally**: Reference prior RFCs, discussions, GitHub issues, docs
- **Explain the problem**: What pain points exist today?
- **Historical context**: Previous attempts, related work, constraints
- **Don't repeat yourself**: Link to context instead of re-explaining

**Guiding Question**:
> "Can a random engineer read this section and acquire nearly full context on the necessity for this RFC?"

If not, the background section needs more detail.

**Example Structure**:
```
## Background

Currently, Terraform Cloud's product summary page displays a fixed set of
metrics and visualizations. Users have requested the ability to...
[Explain current state and limitations]

Previous attempts to solve this include:
- [Link to prior RFC] - Abandoned due to performance concerns
- [Link to GitHub issue] - User request with 50+ upvotes
[Provide historical context]

The constraint we must work within is...
[Explain technical or business constraints]
```

### 5. Proposal

**Purpose**: Propose the high-level solution. Overview of "how" without implementation details.

**Guidelines**:
- **High-level approach**: What's the solution strategy?
- **Key components**: What are the main pieces?
- **Trade-offs**: Why this approach vs. alternatives?
- **Success criteria**: How do we know this works?
- **Out of scope**: What this RFC does NOT cover

**Example Structure**:
```
## Proposal

We propose a plugin-based widget system with the following characteristics:
- Widget API: REST endpoints for widget data
- Widget SDK: JavaScript library for widget development
- Security model: Sandboxed iframe execution
- Discovery: Widget marketplace for community widgets

This approach enables community extensibility while maintaining security.
The widget system will integrate with existing RBAC policies.

Out of scope: Widget versioning and automated testing (covered in follow-up RFC).
```

### 6. Implementation (Recommended)

**Purpose**: Detail the technical implementation to catch issues before coding.

**Guidelines**:
- **API changes**: New endpoints, modified signatures, data structures
- **Package/module changes**: Which subsystems are affected?
- **Surface area**: How much code will change?
- **Data models**: Database schemas, state structures
- **Migrations**: How to handle existing data
- **Testing strategy**: Unit, integration, performance tests
- **Rollout plan**: Feature flags, phased rollout, rollback strategy

**Benefits**:
- **Rubber duck debugging**: Catch issues while typing
- **Review feedback**: Reviewers can spot problems early
- **Alternative approaches**: May reveal simpler solutions
- **Scope clarity**: Shows true complexity of the change

**Example Structure**:
```
## Implementation

### API Changes

New endpoints:
- `POST /api/v2/widgets` - Create widget
- `GET /api/v2/widgets/:id` - Fetch widget data
- `DELETE /api/v2/widgets/:id` - Remove widget

Modified endpoints:
- `GET /api/v2/products/:id` - Include widget references

### Package Changes

- `internal/widgets`: New package for widget logic
- `internal/api/widgets`: API handlers
- `internal/models`: Add Widget model
- `ui/app/components/widget-renderer`: UI component

### Database Schema

```sql
CREATE TABLE widgets (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  config JSONB,
  product_id UUID REFERENCES products(id)
);
```

### Testing

- Unit tests for widget validation
- Integration tests for widget API
- Browser tests for widget rendering
- Performance tests for 50+ widgets per page
```

### 7. UX/UI (If User-Facing)

**Purpose**: Document user experience changes, CLI output, configuration formats.

**Guidelines**:
- **User-facing changes**: External APIs, CLI commands, config files
- **Before/after examples**: Show current vs. proposed UX
- **Backwards compatibility**: Breaking changes, migration paths
- **Error messages**: New errors, improved messaging
- **Documentation needs**: What docs need updating?
- **Visual mockups**: Include screenshots or wireframes if UI changes

**Key Review Questions**:
- Does this *feel* like HashiCorp products?
- Are flags/options consistent with existing patterns?
- Can users migrate without breaking changes?
- Are error messages helpful and actionable?

**Example Structure**:
```
## UX

### CLI Changes

New command:
```bash
terraform cloud widgets create --name "Coverage Chart" --config config.json
```

Output format:
```
Creating widget "Coverage Chart"...
✓ Widget created successfully
  ID: widget-abc123
  View at: https://app.terraform.io/app/widgets/widget-abc123
```

### Configuration Format

widgets.json:
```json
{
  "name": "Coverage Chart",
  "type": "chart",
  "datasource": "coverage-api",
  "config": {
    "chartType": "line",
    "metrics": ["coverage_percentage"]
  }
}
```

### Backwards Compatibility

No breaking changes. Existing product pages will render normally without widgets.
Widget API is additive only (new endpoints, no modified existing ones).
```

### 8. Abandoned Ideas (Optional but Valuable)

**Purpose**: Document paths explored and rejected to help others avoid the same pitfalls.

**Guidelines**:
- **Explain what was considered**: Alternative approaches
- **Why abandoned**: Technical, UX, complexity, cost reasons
- **Link to discussions**: Slack threads, GitHub comments
- **Preserve institutional knowledge**: Future readers benefit

**Benefits**:
- **Avoid repeating history**: Reviewers won't suggest already-rejected ideas
- **Show thoroughness**: Demonstrates multiple approaches considered
- **Speed up future work**: Others can learn from exploration

**Example Structure**:
```
## Abandoned Ideas

### Server-Side Rendering

Initially considered rendering widgets server-side to avoid client-side
JavaScript execution. Abandoned because:
- Performance impact: Server CPU usage would spike with many widgets
- Flexibility: Limited widget capabilities (no interactive charts)
- Complexity: Would require sandboxed execution environment on server

Discussion: [Link to Slack thread]

### WebAssembly Widgets

Explored using WebAssembly for widget execution. Abandoned because:
- Browser support: Not all target browsers support WASM
- Developer experience: Higher barrier for widget authors
- Ecosystem: Fewer libraries available vs. JavaScript

Discussion: [Link to GitHub comment]
```

## RFC Style Guidelines

### Beautiful is Better

HashiCorp's "Beautiful is Better" principle applies to RFCs. Well-formatted documents are easier to read and review.

### Heading Styles

- **Heading 2**: Section titles (not Heading 1, text too large)
- **Heading 3**: Sub-sections
- **Heading 4**: Rarely needed, for nested sections
- **Google Docs**: Uses Heading 2 for outline navigation

### Lists

Bold first phrase for emphasis:

- **Format** should be widgets
- **Protocol** should be widgets-rpc
- **Backwards compatibility** should be considered

### Typeface

- **Body text**: Arial 11pt
- **Headings**: Larger Arial (auto-sized)
- **Code**: Courier New font
- **No color highlighting**: Except code syntax
- **Minimal formatting**: Bold, italics, underline only

### Code Samples

- **Font**: Courier New
- **Indentation**: Tabs or spaces (be consistent)
- **Syntax highlighting**: Optional but must use Courier New
- **CLI output**: Show color formatting if known

```go
func example() {
  <-make(chan struct{})
}
```

### Links

- Link to prior RFCs, GitHub issues, docs
- Use descriptive link text (not "click here")
- Example: See [prior RFC on widget security](#) for context

## RFC Workflow

### 1. Drafting

```
1. Create Google Doc
   └─ Use RFC template or copy existing RFC

2. Fill in header table
   ├─ Title, created date, owner
   ├─ Status: WIP
   └─ Link to related PRD if applicable

3. Write Overview (do this first or last)
   └─ 1-2 paragraph summary of goal

4. Write Background
   ├─ Provide full context
   ├─ Link to prior work
   └─ Explain why this is needed

5. Write Proposal
   ├─ High-level approach
   └─ Key components

6. Write Implementation (recommended)
   ├─ API changes
   ├─ Package changes
   ├─ Data models
   └─ Testing strategy

7. Write UX/UI (if applicable)
   ├─ Before/after examples
   └─ Backwards compatibility

8. Document Abandoned Ideas (optional)
   └─ What was tried and why it was rejected
```

### 2. Review Process

```
1. Share in Slack
   ├─ Post link in relevant channels (#engineering, #product)
   ├─ Tag key reviewers (@architect, @team-lead)
   └─ Set expectations ("please review by Friday")

2. Address comments
   ├─ Respond inline in Google Doc
   ├─ Update RFC based on feedback
   └─ Mark comments as resolved

3. Iterate
   ├─ Allow 3-5 days for async review
   ├─ Schedule sync meeting if needed
   └─ Continue until consensus reached

4. Mark as Approved
   ├─ Update status to "Approved"
   ├─ No formal sign-off required (consensus-driven)
   └─ Ready for implementation
```

### 3. Implementation

```
1. Reference RFC in code
   ├─ Link to RFC in pull request description
   └─ Comment references for complex logic

2. Track deviations
   ├─ Update RFC if implementation differs
   └─ Document reasons for changes

3. Archive when obsolete
   ├─ Mark status as "Obsolete" when superseded
   ├─ Link to new RFC that replaces it
   └─ Don't delete (preserve history)
```

## Common Workflows

### Starting an RFC

```bash
# 1. Copy existing RFC or use template
# 2. Fill in header table
# 3. Write sections in order (or Overview last)
# 4. Share when Background + Proposal are solid
```

### Responding to Comments

**Good responses**:
- "Great point. Updated the Implementation section to address this."
- "I considered this but abandoned it because [reason]. Added to Abandoned Ideas."
- "Can you elaborate on this concern? I want to make sure I understand."

**Avoid**:
- Defensive responses to feedback
- Ignoring comments (resolve or respond to all)
- Copying and pasting generic replies

### Handling Disagreement

**If reviewers disagree with approach**:
1. Understand their concern (ask clarifying questions)
2. Explain your reasoning (trade-offs, constraints)
3. Explore compromise (can you meet in the middle?)
4. Escalate if needed (bring in architect, engineering lead)
5. Document decision (even if you disagree, note the choice)

**RFCs are consensus-driven**: Aim for agreement, not forced approval.

### Splitting an RFC

**If RFC becomes too large (> 20 pages)**:
1. Split into core RFC + extension RFCs
2. Example: "Widget System RFC" → "Widget API RFC" + "Widget Security RFC"
3. Link RFCs to each other
4. Mark original as "Superseded by [RFC links]"

## Best Practices

### For RFC Authors

1. **Provide context**: Background section should explain why to any newcomer
2. **Show your work**: Implementation details catch issues via "rubber duck debugging"
3. **Preserve rejected ideas**: Help others avoid the same pitfalls
4. **Focus on UX**: User-facing changes need detailed explanation
5. **Link liberally**: Reference prior RFCs, discussions, docs
6. **Be specific**: Concrete examples better than abstract descriptions
7. **Update based on feedback**: Iterate until consensus is reached
8. **Keep it current**: Update RFC if implementation changes

### For RFC Reviewers

1. **Read Background first**: Understand context before critiquing solution
2. **Ask questions**: Seek to understand before suggesting changes
3. **Suggest alternatives**: Propose different approaches with reasoning
4. **Check consistency**: Does this feel like HashiCorp products?
5. **Focus on substance**: Don't bikeshed formatting (unless egregious)
6. **Be constructive**: Frame feedback as questions or suggestions
7. **Approve consensus**: RFCs don't need 100% agreement, just no major blockers

### Common Pitfalls

**❌ Too abstract**: Generic descriptions without concrete examples
- Fix: Add code samples, API examples, CLI output

**❌ Missing context**: Assumes reader knows the problem
- Fix: Expand Background section with links and history

**❌ No implementation details**: "We'll figure it out during implementation"
- Fix: Add Implementation section with API/package changes

**❌ Ignoring UX**: Technical changes without user experience consideration
- Fix: Add UX section with before/after examples

**❌ No alternatives considered**: Only one approach presented
- Fix: Add Abandoned Ideas or discuss trade-offs in Proposal

## Integration with Other Tools

### Hermes Integration

- Create RFC in Google Docs
- Add to Hermes for metadata management
- Track status (WIP → In-Review → Approved → Obsolete)
- Link to related PRDs, PRFAQs, GitHub issues

See `/hermes` skill for document management.

### PRD Relationship

- **PRD defines** what to build and why (user problems, requirements)
- **RFC defines** how to build it (technical approach, implementation)
- PRD approved → RFC written → Implementation begins

Link RFC to PRD in header table.

### GitHub Integration

- Reference RFC in pull request descriptions
- Link GitHub issues to RFC for tracking
- Comment in code linking to relevant RFC sections

### Slack Integration

- Share RFC link in engineering channels
- Request reviews from specific people
- Announce when RFC is approved
- Use threads for focused discussions

See `/slack` skill for communication patterns.

## Troubleshooting

### RFC Not Getting Reviews

**Problem**: Shared RFC but no one is reviewing it.

**Solutions**:
1. Tag specific reviewers in Slack post
2. Set deadline: "Please review by Friday"
3. Share in multiple relevant channels
4. Schedule sync review meeting
5. DM key stakeholders directly

### Too Many Conflicting Comments

**Problem**: Reviewers disagree on approach.

**Solutions**:
1. Synthesize concerns into common themes
2. Schedule meeting with disagreeing parties
3. Escalate to architect or engineering lead
4. Document trade-offs of each approach
5. Make a decision and document reasoning

### RFC Scope Creeping

**Problem**: RFC keeps growing as more topics are added.

**Solutions**:
1. Define "out of scope" section clearly
2. Split into multiple RFCs (core + extensions)
3. Defer topics to follow-up RFCs
4. Link to related RFCs instead of expanding

### Implementation Deviating from RFC

**Problem**: Code is different from RFC proposal.

**Solutions**:
1. Update RFC to reflect implementation reality
2. Document why deviation was necessary
3. Link to pull requests showing changes
4. Mark sections as "Updated during implementation"

## Examples

### Good RFC Examples

Available in HashiCorp's RFC folder:
- **ServiceNow Integration RFC**: Clear background, thorough implementation
- **Vault Marketplace RFC**: Good UX section, abandoned ideas
- **Nomad Audit Logging RFC**: Well-structured, great code examples

See RFC folder in Google Drive.

## Additional Resources

### Templates and Tools

- `/hashicorp` - How we work (RFC process overview)
- `/prd` - Product Requirements Documents
- `/prfaq` - Press Release + FAQ documents
- `/memo` - Quick decision memos

### Related Skills

- `/hermes` - Document management system
- `/google-docs` - Google Docs collaboration
- `/github` - GitHub integration
- `/slack` - Communication patterns

### External Resources

- RFCs Google Drive Folder
- [HashiCorp Confluence](https://hashicorp.atlassian.net/wiki/spaces/HAS/overview)

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
