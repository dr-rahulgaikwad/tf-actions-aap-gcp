---
name: prd
description: Product Requirements Document (PRD) guidance for phased requirements and acceptance criteria. Use when defining product requirements or roadmap phases.
---

# PRD (Product Requirements Document)

Guide to writing and reviewing Product Requirements Documents at HashiCorp.

## What is a PRD?

A **PRD (Product Requirements Document)** defines user problems, requirements, and phased delivery with clear acceptance criteria. PRDs translate customer research into actionable requirements for engineering teams.

PRDs are **grounded in user research** and break complex features into phases that deliver incremental customer value.

## When to Use a PRD

### Use PRD For:

- **Feature development**: New capabilities or enhancements
- **User-driven work**: Features solving specific customer problems
- **Phased delivery**: Work broken into multiple releases
- **Cross-functional features**: Requires PM, Eng, Design collaboration
- **Requirements clarity**: Engineering needs clear acceptance criteria
- **Stakeholder alignment**: Multiple teams or leaders need to approve

### Don't Use PRD For:

- **Technical implementation**: Use RFC for architecture and design
- **Product vision**: Use PRFAQ for high-level narrative
- **Bug fixes**: Direct implementation with GitHub issues
- **Internal technical work**: Use RFC for refactoring, optimizations
- **Small improvements**: Use GitHub issues or Memos

### PRD in the Planning Flow

```
Large Feature:
1. PRFAQ (optional - vision and why now)
2. PRD (requirements and phases) ← You are here
3. RFC (technical design)

Medium Feature:
1. PRD (requirements and phases)
2. RFC (technical design)

Small Feature:
1. GitHub issue → Direct implementation
```

## PRD Structure

### Required Sections

```
PRD [Title]
├─ Header (summary, owner, status, links)
├─ Introduction (write last)
├─ Background (context for readers)
├─ Problem
│  └─ Personas (affected users)
├─ Requirements and Phases
│  ├─ Phase 1
│  │  ├─ Hypothesis Outcomes & KPIs
│  │  └─ Requirements (with acceptance criteria)
│  ├─ Phase 2
│  └─ Phase N
├─ User Research (customer interviews)
└─ Approvals (stakeholder sign-off)
```

### 1. Title and Header

```
# [PRD] Confusing Widget Creation Workflow

**Summary:** Community members struggle to finish the final step in releasing widgets.

| Created: Jan 22, 2010 | Status: WIP | In Review | Approved | Obsolete |
| :---- | :---- |
| Owner: email@hashicorp.com | RFC: Link when created |
| Contributors: person1@, person2@ | |
```

**Fields**:
- **Title**: Describes the problem or opportunity (not the solution)
- **Summary**: One sentence describing the core issue
- **Created**: Date PRD was first written
- **Status**: WIP → In Review → Approved → Obsolete
- **Owner**: Product Manager responsible for this PRD
- **Contributors**: Co-authors and collaborators
- **RFC**: Link to related RFC (filled in during implementation)

### 2. Introduction

**Purpose**: Brief overview that explains the goal of the PRD.

**Guidelines**:
- **Write this LAST**: After you know the final content
- **1-2 paragraphs**: Concise summary
- **State the goal**: What will this PRD define?
- **No details yet**: High-level only
- **For skimmers**: Busy readers should understand the PRD from this alone

**Example**:
```
This PRD addresses the widget creation workflow in Terraform Cloud. User
research shows that community members struggle with the final publishing
step, leading to abandoned widgets and reduced ecosystem growth.

The PRD breaks the solution into three phases: improving widget creation
tooling, better publishing workflows, and automated widget publishing.
Each phase builds value incrementally while gathering feedback from the
community.
```

### 3. Background

**Purpose**: Provide context so readers understand the problem domain.

**Guidelines**:
- **Educate the reader**: Explain the current state
- **Sufficient detail**: Give enough context to understand the content
- **Context before content**: Set the stage before diving into problems
- **Visual explanations**: Diagrams or screenshots encouraged
- **Link to examples**: Good PRDs to reference

**Example**:
```
## Background

Terraform Cloud's widget system allows community members to extend the
product with custom visualizations. The workflow involves:
1. Developing the widget locally with our SDK
2. Testing the widget in a development environment
3. Publishing the widget to our marketplace
4. Community users discovering and installing widgets

Currently, steps 1-2 work well, but step 3 (publishing) has a 60% abandon
rate based on analytics data. Users report confusion about:
- Which files to include in the published package
- How to configure marketplace metadata
- Testing the published widget before making it public

This limits widget ecosystem growth, which is a key metric for our
developer experience team (target: 100 published widgets by Q2 2024,
currently at 23).

Good PRD examples:
- [ServiceNow PRD](link) - Similar marketplace workflow
- [Cloud Services PRD](link) - Phased delivery approach
```

### 4. Problem

**Purpose**: Simplify user research into clear problem statements mapped to personas.

**Guidelines**:
- **Ground in research**: Each problem should map to customer interviews (see User Research section)
- **Specific problems**: Not generic or assumed pain points
- **Persona-driven**: Link each problem to affected user type
- **Prioritized**: Order by severity or frequency
- **Validated**: Confirm these are real problems customers care about

**Structure**:
```
## Problem

[High-level summary of the core problem]

### Personas

* **Affected Persona 1** has troubles developing with this problem
* **Affected Persona 2** has troubles operating with this problem
* **Affected Persona 3** has troubles securing with this problem
```

**Example**:
```
## Problem

Widget creators struggle to publish their work to the Terraform Cloud
marketplace, resulting in a 60% abandon rate at the publishing step and
limiting ecosystem growth.

### Personas

* **Widget Developers** (open source contributors, HashiCorp partners)
  spend hours debugging publish failures due to unclear documentation
  about required files and metadata

* **Widget Publishers** (community power users, HashiCorp Field teams)
  can't test published widgets before making them public, risking
  broken experiences for end users

* **Widget Users** (Terraform Cloud customers, community members)
  discover widgets that are broken or abandoned because publishers
  couldn't complete the publishing workflow
```

**Good Examples**:
- [Cloud Services PRD](link) - Clear persona definitions
- [Nomad Audit Logging PRD](link) - Problems linked to research

### 5. Requirements and Phases

**Purpose**: Break the solution into phases that deliver incremental customer value.

**Key Principles**:
- **Sequential value**: Each phase builds on the previous
- **End-to-end value**: Each phase provides complete value to customers (not just infrastructure)
- **No internal priorities**: All requirements in a phase are equally important
- **Complete phases**: Phase is done when ALL requirements are fulfilled

**Structure**:
```
## Requirements and Phases

|  | Requirements |
| :---- | :---- |
| **Phase 1:** [Objective for customers] | Requirement 1 |
|  | Requirement 2 |
| **Phase 2:** [Next objective] | Requirement 3 |
|  | Requirement 4 |
```

**Phase Definition**:
- **Title**: Customer-focused objective (not technical task)
  - ✅ "Easier widget publishing for developers"
  - ❌ "Implement widget publishing API"
- **Requirements**: What must be built to complete this phase
- **Order matters**: Phases are sequential (Phase 1 before Phase 2)

**Example**:
```
## Requirements and Phases

|  | Requirements |
| :---- | :---- |
| **Phase 1:** Improve Widget Creation Tooling | Widget creators can create widgets with local dev environment |
|  | Widget creators have testing tooling workflow in development |
| **Phase 2:** Better Publishing Workflow | Publishing widgets is a clear documented workflow |
|  | Publishers can test widgets before making public |
| **Phase 3:** Automated Widget Publishing | Widget tooling automates published updates for widgets |
|  | Publishers receive notifications about widget health |
```

**Important**: Single-phase PRDs are fine if the feature doesn't need incremental delivery.

### 6. Phase Details

**For each phase**, provide:
- Hypothesis Outcomes & KPIs
- Requirements with acceptance criteria
- Considerations for RFC authors

#### Hypothesis Outcomes & KPIs

**Purpose**: Define success metrics and where they'll be tracked.

**Guidelines**:
- **SMART format**: Specific, Measurable, Achievable, Relevant, Time-bound
- **Customer or business outcomes**: Not just feature usage
- **Reporting location**: Looker dashboard, Heap chart, spreadsheet
- **Narrow hypotheses**: Easier to assess success
- **Priority order**: List most important first

**Structure for each hypothesis**:
```
##### Hypothesis 1

[Describe the expected outcome with specific metrics]

Example: Completion of Phase 1 should increase widget publishing
success rate from 40% to 70% within 3 months of release.

###### Supporting KPI 1

[Metric that supports the hypothesis]

Example: Monthly active widget publishers (tracked in Looker dashboard)
```

**Example**:
```
### Phase 1: Improve Widget Creation Tooling

#### Hypothesis Outcomes & KPIs

This section defines how we'll measure success. Metrics will be reported
in the Widget Ecosystem Looker Dashboard (link).

##### Hypothesis 1

Phase 1 completion will increase widget publishing success rate from 40%
to 70% within 3 months of release, measured by percentage of users who
start the publish flow and complete it successfully.

###### Supporting KPI 1

Monthly new widgets published (target: 10/month, up from 3/month)

###### Supporting KPI 2

Widget publish flow completion rate (percentage who complete vs. abandon)

##### Hypothesis 2

Developer satisfaction (CSAT) with widget creation tooling will increase
from 3.2 to 4.0 or above (5-point scale) based on quarterly survey of
widget developers.

###### Supporting KPI 1

CSAT score from widget developer survey (quarterly)

###### Supporting KPI 2

NPS (Net Promoter Score) from widget ecosystem community
```

#### Requirements

**Purpose**: Define what must be built for this phase.

**Guidelines**:
- **Equally important**: No priority within phase (split to new phase if needed)
- **Acceptance criteria**: Test cases that prove it's done
- **Considerations**: Questions for RFC authors (not suggestions)
- **One or more RFCs**: Each requirement may need an RFC

**Structure for each requirement**:
```
#### Requirement 1

[Description of what needs to be built]

##### Acceptance Criteria

1. [Test case 1]
2. [Test case 2]
3. [Test case 3]

##### Considerations

1. [Question for RFC author]
2. [Question for RFC author]
```

**Example**:
```
#### Requirement 1: Local Development Environment

Widget creators must be able to develop and test widgets locally before
publishing, with hot reload and debugging support.

##### Acceptance Criteria

1. Running `terraform-widget dev` starts a local development server
2. Changes to widget code are reflected in browser without manual refresh
3. Browser DevTools can be used to debug widget JavaScript
4. Local environment loads same APIs as production marketplace
5. Documentation includes "Getting Started" guide with local setup

##### Considerations

1. Should the local dev server use Docker or native Node.js?
2. How will widget creators authenticate with Terraform Cloud APIs locally?
3. What's the minimum supported Node.js version?
4. Should we provide example widget templates?

#### Requirement 2: Widget Testing Framework

Widget creators must be able to write automated tests for their widgets
using a provided testing framework.

##### Acceptance Criteria

1. `terraform-widget test` runs all widget tests
2. Tests can mock Terraform Cloud API responses
3. Tests can simulate different user permissions and contexts
4. Test output shows coverage percentage
5. CI/CD integration examples provided in documentation

##### Considerations

1. Should we use Jest, Mocha, or custom test runner?
2. How do we handle async testing for API calls?
3. What's the target code coverage percentage for example widgets?
```

### 7. User Research

**Purpose**: Ground the PRD in real, experienced user problems.

**Guidelines**:
- **Most important section**: Everything else derives from this
- **5+ customer interviews**: Minimum to identify patterns
- **Link to interview notes**: Provide evidence
- **Short paragraph per customer**: Current state of their workflow
- **Key takeaways**: Problems and pain points (numbered list)
- **Patterns across users**: Common themes inform Problem section

**Structure**:
```
## User Research

### Customer 1 (Company Name)

[Link to interview notes]

[Short paragraph describing their current workflow and context]

1. Problem/Takeaway
2. Problem/Takeaway
3. Problem/Takeaway

### Customer 2 (Company Name)

...
```

**Example**:
```
## User Research

### Acme Corp (Interview Notes: link)

Acme is a HashiCorp partner building custom Terraform widgets for
compliance reporting. They have published 3 widgets but abandoned 2
others due to publishing issues. Their team of 5 engineers spends ~20%
time on widget development.

1. Widget publish command fails with cryptic error "metadata.json invalid"
   but doesn't specify which field is invalid
2. After fixing publish errors, widget appears in marketplace but doesn't
   load for users - no way to test before publishing
3. Difficult to update published widgets - must manually increment version
   in multiple files

### Initech (Interview Notes: link)

Initech is a community contributor who built a cost estimation widget.
They spent 8 hours trying to publish before giving up and posting the
widget in a GitHub gist instead.

1. Documentation doesn't clearly list required files for publishing
2. Local widget works perfectly but publish fails - no local validation
3. Attempted to contact support but no response (community support only)
4. Found outdated forum posts suggesting different publish workflows

### Globex Corp (Interview Notes: link)

Globex is an enterprise customer using Terraform Cloud with custom
internal widgets. They don't publish to marketplace but face similar
issues deploying to their private registry.

1. Private registry deployment uses same publish command, inherits same issues
2. Need to test widgets with real user permissions before deployment
3. Widget versioning is manual and error-prone
```

**Good Examples**:
- [ServiceNow PRD](link) - Excellent user research
- [PTFE Release Notes PRD](link) - Good problem/takeaway format

### 8. Approvals

**Purpose**: Document required stakeholder sign-off before implementation begins.

**Approval Criteria**:
- ✅ Release summary defines which acceptance criteria are in scope
- ✅ Engineering and PM agree on target release version
- ✅ PRD provides sufficient clarity to author RFCs
- ✅ Review meeting scheduled with engineering and design

**Required Approvers**:
- Project Engineering Lead
- Product Manager (PRD owner)
- VP of Product
- Sales Engineer Lead
- Product Design Lead
- SME (subject matter expert)
- [Additional approvers as needed]

**Format**:
```
## Approvals

Red names require approval. Green names with ✅ have approved.

**Approved names will have a ✅**
Project Engineering Lead: ✅ Jane Smith
Product Manager: ✅ John Doe
VP of Product: ✅ Alice Johnson
Sales Engineer Lead: Bob Wilson
Product Design Lead: ✅ Sarah Chen
SME: ✅ Dr. Expert
```

## PRD Style Guidelines

### Beautiful is Better

HashiCorp's core principle applies to PRDs. Well-formatted documents are easier to read and review.

### Heading Styles

- **Heading 2**: Section titles (not Heading 1)
- **Heading 3**: Sub-sections
- **Heading 4+**: Nested sections (rare)

### Lists

Bold first phrase for emphasis:

- **Format** should be widgets
- **Protocol** should be widgets-rpc
- **Backwards compatibility** should be considered

### Typeface

- **Body**: Arial 11pt
- **Headings**: Larger Arial (auto-sized)
- **Code**: Courier New
- **No color highlighting**: Except code syntax
- **Minimal formatting**: Bold, italics, underline

### Code Samples

- **Font**: Courier New
- **Indentation**: Consistent tabs or spaces
- **CLI output**: Show formatting with colors

```bash
terraform-widget publish --name "My Widget"
✓ Widget published successfully
```

## PRD Workflow

### 1. User Research (Before Writing PRD)

```
1. Interview customers
   ├─ Schedule 5-10 customer interviews
   ├─ Ask about pain points and workflows
   └─ Document in interview notes

2. Identify patterns
   ├─ What problems appear across multiple customers?
   ├─ Which pain points are most severe?
   └─ What personas are affected?

3. Validate problem severity
   ├─ Quantify impact (time wasted, money lost)
   ├─ Check analytics data
   └─ Review support tickets
```

### 2. Drafting PRD

```
1. Create Google Doc from PRD template

2. Fill in header
   ├─ Title (problem-focused)
   ├─ Summary (one sentence)
   └─ Owner and contributors

3. Write Background
   ├─ Explain current state
   ├─ Provide context for newcomers
   └─ Link to examples

4. Write Problem section
   ├─ Define personas
   └─ List problems (grounded in research)

5. Write User Research section
   ├─ Summarize each customer interview
   └─ List key takeaways

6. Define Requirements and Phases
   ├─ Break into phases with sequential value
   ├─ Each phase has objective + requirements
   └─ Order phases by priority

7. For each phase
   ├─ Define hypothesis outcomes & KPIs
   ├─ List requirements
   ├─ Write acceptance criteria
   └─ Add considerations for RFC authors

8. Write Introduction (do this last)
   └─ Summarize the final PRD

9. Add to Hermes
   └─ Track metadata and approvals
```

### 3. Review and Approval

```
1. Share with stakeholders
   ├─ Engineering lead
   ├─ Product manager (self-review)
   ├─ Design lead
   └─ VP of Product

2. Schedule review meeting
   └─ Walk through PRD with eng and design

3. Address feedback
   ├─ Clarify acceptance criteria
   ├─ Refine phasing
   ├─ Add missing research
   └─ Update requirements

4. Define release scope
   ├─ Create release summary
   └─ Document which acceptance criteria are in scope

5. Get approvals
   ├─ Check required approvers list
   ├─ Follow up with pending approvers
   └─ Mark names with ✅ when approved

6. Agree on target release
   └─ Engineering and PM align on version

7. Kick off implementation
   ├─ Engineering writes RFC
   └─ Track progress in Jira
```

### 4. During Implementation

```
1. Track against acceptance criteria
   └─ Product manager tests each criterion

2. Update PRD if needed
   ├─ Document changes from RFC
   └─ Note scope reductions

3. Measure KPIs
   ├─ Set up dashboards
   └─ Track hypothesis outcomes

4. Plan next phase
   └─ After Phase 1 ships, kick off Phase 2
```

## Best Practices

### For PRD Authors

1. **Start with research**: Interview 5+ customers before writing
2. **Define personas**: Generic versions of interviewed users
3. **Phase for value**: Each phase delivers end-to-end customer value
4. **Write acceptance criteria like tests**: Objective and verifiable
5. **Set KPIs in SMART format**: Specific, measurable, time-bound
6. **Write intro last**: Summarize final content, not initial intent
7. **Link to research**: Ground every problem in customer evidence
8. **Get early feedback**: Share draft with eng lead before review meeting

### For PRD Reviewers

1. **Check research**: Is this grounded in real customer problems?
2. **Validate phases**: Does each phase provide end-to-end value?
3. **Review acceptance criteria**: Can we test against these objectively?
4. **Question assumptions**: Are KPIs realistic and measurable?
5. **Consider scope**: Is this achievable in target release?
6. **Provide constructive feedback**: Help improve clarity
7. **Approve when ready**: Don't block on minor issues

### Common Pitfalls

**❌ No user research**: Assumptions instead of validated problems
- Fix: Interview customers before writing PRD

**❌ Phases that don't deliver value**: Infrastructure-only phases
- Fix: Ensure each phase provides customer-visible value

**❌ Vague acceptance criteria**: "Widget publishing should be better"
- Fix: Write specific, testable criteria

**❌ Unrealistic KPIs**: "Increase revenue by 10x"
- Fix: Base KPIs on data and comparable features

**❌ Writing intro first**: Doesn't match final content
- Fix: Write introduction last after finalizing requirements

## Integration with Other Tools

### PRFAQ Relationship

```
Optional: PRFAQ → PRD
- PRFAQ defines vision and why now
- PRD defines requirements and phases
- Link to PRFAQ in PRD header if applicable
```

### RFC Relationship

```
PRD → RFC(s)
- PRD approved
- Engineering writes RFC for technical design
- Reference PRD in RFC header
- Link RFC in PRD when created
```

### Hermes Integration

- Create PRD in Google Docs
- Add to Hermes for metadata tracking
- Approval workflow in Hermes
- Link to RFCs and PRFAQs

See `/hermes` skill.

### Jira Integration

- Create epic from PRD
- Link PRD to epic
- Break requirements into stories
- Track implementation progress

See `/jira` skill.

## Troubleshooting

### Not Getting Approvals

**Problem**: PRD stuck waiting for approvals.

**Solutions**:
1. Follow up with pending approvers via Slack
2. Address unresolved comments
3. Schedule meeting to discuss blockers
4. Clarify scope in release summary
5. Break into smaller PRD if too large

### Acceptance Criteria Too Vague

**Problem**: Engineering can't tell when requirement is done.

**Solutions**:
1. Rewrite as specific test cases
2. Add concrete examples
3. Define success metrics
4. Show before/after states
5. Review with engineering lead

### Phases Don't Build Value

**Problem**: Phase 1 is just infrastructure, no user value.

**Solutions**:
1. Combine Phase 1 + Phase 2 for complete feature
2. Redefine phases around user journeys
3. Deliver minimal end-to-end feature in Phase 1
4. Cut infrastructure-only work (do as prerequisite)

### KPIs Are Unrealistic

**Problem**: Hypotheses can't be measured or are too ambitious.

**Solutions**:
1. Base KPIs on comparable features
2. Use data from user research
3. Set ranges instead of exact targets
4. Define how/where metrics will be tracked
5. Mark as hypotheses requiring validation

## Examples

### Good PRD Examples

Available in HashiCorp's product folders:
- **Vault Marketplace PRD**: Excellent phasing and acceptance criteria
- **ServiceNow PRD**: Thorough user research section
- **PTFE Release Notes PRD**: Clear problem/persona mapping
- **Cloud Services PRD**: Good hypothesis outcomes

See product-specific folders in Google Drive.

## Additional Resources

### Templates and Tools

- `/hashicorp` - How we work (PRD process overview)
- `/prfaq` - Press Release + FAQ (optional precursor)
- `/rfc` - Request for Comments (follows PRD)
- `/memo` - Quick decision memos

### Related Skills

- `/hermes` - Document management and approvals
- `/google-docs` - Google Docs collaboration
- `/jira` - Epic and story tracking
- `/slack` - Communication patterns

### External Resources

- Product folders in Google Drive
- [SMART Goals](https://en.wikipedia.org/wiki/SMART_criteria)
- PRD template (Google Docs)

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
