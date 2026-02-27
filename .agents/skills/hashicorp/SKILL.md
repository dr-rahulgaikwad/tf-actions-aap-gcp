---
name: hashicorp
description: HashiCorp ways of working -- principles, document-driven decisions, and guidance for RFCs, PRDs, PRFAQs, and Memos. Use for culture, process, and collaboration norms.
---

# HashiCorp - How We Work

Guide to HashiCorp's culture, principles, and document-driven collaboration workflows.

## Core Principles

### Beautiful is Better

HashiCorp emphasizes quality and attention to detail in everything we create:
- **Documentation**: Clear, well-structured, visually appealing
- **Code**: Readable, maintainable, elegant solutions
- **User Experience**: Intuitive, consistent, delightful
- **Internal Processes**: Organized, repeatable, efficient

This principle applies to RFCs, PRDs, code, UI/UX, and all work artifacts.

### Working Backwards

Borrowed from Amazon's methodology, HashiCorp uses customer-centric planning:
1. **Start with the customer**: Define the customer experience first
2. **Write the press release**: Articulate the value before building
3. **Define success**: Establish metrics and hypotheses
4. **Work backwards**: Design implementation from customer needs

See `/prfaq` skill for the PRFAQ (Press Release + FAQ) template.

### Document-Driven Decision Making

HashiCorp uses structured documents to drive decisions and alignment:
- **RFCs**: Technical design and implementation proposals
- **PRFAQs**: Product vision and customer value propositions
- **PRDs**: Requirements and phased delivery plans
- **Memos**: Quick decisions, impact assessments, proposals

Documents enable asynchronous review, preserve context, and create institutional knowledge.

## Document Workflows

### When to Use Each Document Type

| Document | Purpose | When to Use | Owner |
|----------|---------|-------------|-------|
| **RFC** | Technical design and implementation | Proposing technical changes, architecture decisions, API changes | Engineering |
| **PRFAQ** | Product vision and customer narrative | New features, major capabilities, market positioning | Product Management |
| **PRD** | Detailed requirements and acceptance criteria | Feature development, phased rollouts, user research | Product Management |
| **Memo** | Quick decisions and proposals | Impact assessments, evaluation requests, small decisions | Anyone |

### RFC (Request for Comments)

**Purpose**: Propose technical solutions and gather feedback before implementation.

**Structure**:
```
[RFC] Title
- Overview (1-2 paragraphs)
- Background (context for newcomers)
- Proposal (high-level solution)
- Implementation (detailed approach)
- UX/UI (user-facing changes)
- Abandoned Ideas (paths not taken)
```

**Key Guidelines**:
- Provide full context so newcomers can understand why this change is needed
- Link to prior RFCs and discussions
- Explain abandoned ideas and why they were rejected
- Include implementation details: API changes, packages affected, surface area
- Document UX changes with backwards compatibility considerations
- Use "rubber duck debugging" by typing out implementation details

**Style**:
- Use Heading 2 for sections (not Heading 1)
- Bold first phrase in lists for emphasis
- Code samples in Courier New font
- Arial 11pt for body text
- Include CLI output formatting

See `/rfc` skill and template for full guidance.

### PRFAQ (Press Release + FAQ)

**Purpose**: Define product vision from the customer's perspective, written as if the feature is already launched.

**Structure**:
```
Press Release
- Heading (one sentence pitch)
- Summary (problem, solution, testimonial, quote)
- Customer experience
- Call to action

Why Now? (Business case)
- Strategic alignment
- User need and satisfaction
- Market opportunity
- Business value vs. cost

Internal FAQs (stakeholder questions)
External FAQs (customer questions)
```

**Key Guidelines**:
- Write from the **future** when the capability is released
- Focus on customer value, not features
- Include mock customer testimonials
- Answer "why now" with business justification
- Address both internal and external questions

**Examples**: Active Policy, Plannable Import, High Assurance HCP

See `/prfaq` skill and template for full guidance.

### PRD (Product Requirements Document)

**Purpose**: Define user problems, requirements, and phased delivery with acceptance criteria.

**Structure**:
```
Summary (write last)
Background (context setting)
Problem (user research insights)
- Personas (affected users)

Requirements and Phases
- Phase 1: <Objective>
  - Hypothesis outcomes & KPIs
  - Requirements with acceptance criteria
  - Considerations for RFC authors
- Phase 2: ...

User Research (customer interviews)
Approvals (stakeholder sign-off)
```

**Key Guidelines**:
- Ground in real user research (customer interviews)
- Define personas from interviewed users
- Break into phases that build sequential value
- Each phase must provide end-to-end value
- Requirements are equally important (no priority within phase)
- Acceptance criteria written like test cases
- Hypothesis outcomes in SMART format
- Include KPI dashboards (Looker, Heap, etc.)

**Approval Process**:
- Engineering Lead must approve
- Product Manager must approve
- VP of Product, Design Lead, Sales Engineer as needed
- Release summary defines scope
- Engineering and PM agree on target release

**Examples**: Vault Marketplace, ServiceNow, PTFE Release Notes

See `/prd` skill and template for full guidance.

### Memo

**Purpose**: Quick decisions, impact assessments, or proposals that don't require full RFC/PRD.

**Structure**:
```
[Memo] ABC-123: Title
- Summary
- Created date, Status, Owner
- Product, Contributors, Approvers

Background (describe situation)
R&D Evaluation | Impact Assessment (challenges)
Proposed Solution (alternative)
Next Steps (request feedback)
```

**Key Guidelines**:
- Managed by Hermes document system
- Header auto-populated from metadata
- Status: WIP | In-Review | Approved | Obsolete
- Brief format for faster decisions
- Can reference or lead to RFC/PRD

See `/memo` skill and template for full guidance.

## Collaboration Workflows

### Document Creation

1. **Choose document type** based on decision scope (see table above)
2. **Use template**: `/rfc`, `/prfaq`, `/prd`, `/memo` skills provide templates
3. **Draft content**: Follow structure and style guidelines
4. **Add to Hermes**: Document management system (migrating to SharePoint)
5. **Share for review**: Distribute to stakeholders

### Review and Approval

**RFC Review**:
- Share with engineering team and stakeholders
- Address comments asynchronously
- Iterate on design based on feedback
- No formal approval needed (consensus-driven)

**PRFAQ Review**:
- Share with product, engineering, design, leadership
- Gather feedback on customer value and business case
- Iterate on narrative and FAQs
- Use as input for PRD creation

**PRD Approval**:
- **Required approvals** (names turn green with ✅):
  - Project Engineering Lead
  - Product Manager
  - VP of Product
  - Sales Engineer Lead
  - Product Design Lead
  - SME (subject matter expert)
- Schedule review meeting with engineering and design
- Release summary defines acceptance criteria in scope
- Agreement on target release version

**Memo Review**:
- Share with named approvers
- Gather feedback and iterate
- Mark status when approved
- Archive when obsolete

### Style Guidelines

**All Documents Follow Consistent Styling**:

**Headings**:
- Use Heading 2 for sections (Heading 1 is too large)
- Use Heading 3 for sub-sections
- Rarely go beyond Heading 4

**Lists**:
- Bold first phrase for emphasis:
  - **Format** should be widgets
  - **Protocol** should be widgets-rpc
  - **Backwards compatibility** should be considered

**Typeface**:
- Body: Arial 11pt
- Headings: Larger Arial
- Code: Courier New
- No color highlighting (except code syntax)
- Use bold, italics, underline sparingly

**Code Samples**:
- Courier New font
- Indented with tabs/spaces (be consistent)
- Syntax highlighting optional but font must be Courier New
- CLI output shows color formatting

## Common Workflows

### Starting a New Feature

```
1. User Research
   ├─ Interview customers
   └─ Document problems and pain points

2. PRFAQ (Optional but recommended)
   ├─ Write press release from future
   ├─ Answer why now
   └─ Define customer experience

3. PRD (Product Requirements)
   ├─ Define personas and problems
   ├─ Break into phased requirements
   ├─ Set hypothesis outcomes and KPIs
   └─ Get stakeholder approvals

4. RFC (Technical Design)
   ├─ Propose implementation approach
   ├─ Detail API/UX changes
   ├─ Document abandoned ideas
   └─ Gather engineering feedback

5. Implementation
   ├─ Build according to RFC
   ├─ Test against acceptance criteria
   └─ Track KPIs defined in PRD
```

### Making a Technical Decision

```
1. Small change (< 1 week, single component)
   └─ Memo or direct discussion

2. Medium change (1-4 weeks, multiple components)
   └─ RFC with focused scope

3. Large change (> 1 month, cross-team)
   ├─ PRFAQ (if customer-facing)
   ├─ PRD (requirements and phases)
   └─ RFC (implementation details)
```

### Requesting Feedback

**RFC Feedback**:
- Share Google Doc link in Slack channels
- Tag relevant engineers and architects
- Allow 3-5 days for async review
- Address comments inline
- Schedule sync meeting if needed

**PRD Feedback**:
- Share with PM, engineering, design leads
- Request formal approval from stakeholders
- Iterate on user research and requirements
- Schedule kickoff meeting after approval

**PRFAQ Feedback**:
- Share with leadership and product team
- Focus feedback on customer value and narrative
- Iterate on "why now" and business case
- Use as conversation starter for PRD

### Document Lifecycle

```
WIP (Work in Progress)
  ↓
In Review (shared with stakeholders)
  ↓
Approved (consensus or formal approval)
  ↓
[Implementation happens]
  ↓
Obsolete (outdated or superseded)
```

**Document Updates**:
- Track version numbers for major changes
- Link to related documents (RFC ↔ PRD)
- Archive obsolete documents (don't delete)
- Update status in Hermes metadata

## Document Storage

### Hermes (Current)

HashiCorp's document management system (migrating to SharePoint):
- Metadata management (status, owner, approvers)
- Approval workflows
- Search via Algolia
- Auto-generates document headers
- W3ID authentication

**Key Folders**:
- RFCs: Google Drive shared folder
- PRFAQs: Google Drive shared folder
- PRDs: Product-specific folders

See `/hermes` skill for detailed usage.

### SharePoint (Migration in Progress)

Hermes is migrating from Google Workspace to SharePoint:
- Beta release currently available
- Document migration ongoing
- W3ID authentication working
- Will replace Google Drive for document storage

See `/hermes` skill for migration status.

## Best Practices

### For RFC Authors

1. **Provide context**: Explain why this change is needed (background section)
2. **Show your work**: Document implementation details to catch issues early
3. **Preserve rejected ideas**: Help others avoid same pitfalls
4. **Focus on UX**: User-facing changes need detailed explanation
5. **Link liberally**: Reference prior RFCs, discussions, docs

### For PRFAQ Authors

1. **Think like a customer**: Write from their perspective, not ours
2. **Be specific**: Real customer pain points, not generic problems
3. **Justify timing**: Answer "why now" with business data
4. **Include testimonials**: Mock quotes from target personas
5. **Answer objections**: Internal/external FAQs address concerns

### For PRD Authors

1. **Start with research**: Interview 5+ customers before writing
2. **Define personas**: Generic versions of actual interviewed users
3. **Phase for value**: Each phase delivers end-to-end customer value
4. **Set KPIs**: Track hypothesis outcomes in dashboards
5. **Write intro last**: Summarize final content, not initial intent

### For Memo Authors

1. **Be concise**: Memos are for quick decisions
2. **Provide context**: Background section explains situation
3. **Propose solution**: Don't just describe problems
4. **Request action**: Clear next steps and feedback needed
5. **Track in Hermes**: Use document management for discoverability

## Integration with Other Tools

### Hermes Integration

- Creates document metadata (owner, status, approvers)
- Auto-generates headers on Google Docs
- Approval workflow tracking
- Search and discovery
- Links to related documents

See `/hermes` skill for detailed workflows.

### Google Docs Integration

- Primary authoring environment
- Real-time collaboration
- Comment threads for review
- Version history for changes
- Shared drives for discoverability

See `/google-docs` skill for best practices.

### Jira Integration

- Link PRD/RFC to Jira epics/stories
- Track implementation progress
- Reference document in tickets
- Close loop from planning to delivery

See `/jira` skill for linking workflows.

### Slack Integration

- Share documents for review
- Request feedback in channels
- Announce approvals and launches
- Link to documents in discussions

See `/slack` skill for communication patterns.

## Troubleshooting

### Document Not Getting Reviewed

**Problem**: RFC/PRD shared but no feedback received.

**Solutions**:
1. Share in relevant Slack channels (engineering, product)
2. Tag specific reviewers who should provide input
3. Set deadline for feedback (e.g., "please review by Friday")
4. Schedule review meeting if async isn't working
5. Follow up with direct messages to key stakeholders

### Approval Process Stuck

**Problem**: PRD waiting on approvals, blocking implementation.

**Solutions**:
1. Check required approvers list (engineering lead, PM, VP)
2. Send reminder to approvers who haven't signed off
3. Address unresolved comments in document
4. Schedule meeting to discuss blockers
5. Clarify scope in release summary

### RFC Getting Too Large

**Problem**: RFC has grown to 20+ pages and hard to review.

**Solutions**:
1. Split into multiple RFCs (core + extensions)
2. Move detailed examples to appendix
3. Create separate UI/UX RFC if needed
4. Link to external design docs for specifics
5. Summarize complex sections with TL;DR

### Choosing Between RFC and PRD

**Problem**: Unclear which document type to use.

**Decision Matrix**:
- **Technical decision** (API design, architecture) → RFC
- **Feature requirements** (user problems, phases) → PRD
- **Product vision** (customer narrative, why now) → PRFAQ
- **Quick proposal** (small scope, fast decision) → Memo

**Often need multiple**:
- Large feature: PRFAQ → PRD → RFC(s)
- Medium feature: PRD → RFC
- Technical improvement: RFC only
- Small change: Memo only

## Additional Resources

### Templates

Use these skills to access templates and guidance:
- `/rfc` - Request for Comments template and guide
- `/prfaq` - Press Release + FAQ template and guide
- `/prd` - Product Requirements Document template and guide
- `/memo` - Memo template and guide

### Related Tools

- `/hermes` - Document management system
- `/google-docs` - Google Docs and Drive collaboration
- `/jira` - Issue tracking and project management
- `/slack` - Team communication

### External Resources

- [HashiCorp.com](https://www.hashicorp.com/)
- [How HashiCorp Works](https://www.hashicorp.com/en/how-hashicorp-works)
- [Working Backwards Book](http://www.workingbackwards.com) - Amazon's methodology
- [Amazon PRFAQ Template](https://www.workingbackwards.com/resources/working-backwards-pr-faq)

### Internal Resources

- [HashiCorp Confluence](https://hashicorp.atlassian.net/wiki/spaces/HAS/overview)
- RFCs Google Drive Folder
- PRFAQs Google Drive Folder
- PRDs in Product Folders

### Example Documents

**Good RFC Examples**:
- ServiceNow PRD
- Vault Marketplace
- Nomad Audit Logging

**Good PRFAQ Examples**:
- Active Policy
- Plannable Import
- High Assurance HCP

**Good PRD Examples**:
- Vault Marketplace
- ServiceNow
- PTFE Release Notes
- Cloud Services

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
