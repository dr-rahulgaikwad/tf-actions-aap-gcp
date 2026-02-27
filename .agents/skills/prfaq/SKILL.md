---
name: prfaq
description: PRFAQ (press release + FAQ) guidance for working-backwards, customer-centric product planning. Use when crafting product vision or customer-facing narratives.
---

# PRFAQ (Press Release + FAQ)

Guide to writing PRFAQs (Press Release + Frequently Asked Questions) at HashiCorp.

## What is a PRFAQ?

A **PRFAQ** is a document written from the future point-of-view when a new product or capability is released. It combines:
- **Press Release (PR)**: Customer-facing announcement of the feature
- **Internal FAQ**: Questions from internal stakeholders
- **External FAQ**: Questions from customers

PRFAQs are **customer-centric** planning documents that force teams to think backwards from the customer experience. This methodology is borrowed from Amazon's ["Working Backwards"](http://www.workingbackwards.com) process.

## When to Use a PRFAQ

### Use PRFAQ For:

- **New product capabilities**: Major features or products
- **Customer-facing features**: Anything users will notice and use
- **Strategic initiatives**: Features tied to business goals
- **Product vision alignment**: Get leadership buy-in on direction
- **Cross-functional features**: Requires PM, Eng, Design, Marketing alignment
- **Market positioning**: Features that differentiate from competitors

### Don't Use PRFAQ For:

- **Technical implementation details**: Use RFC instead
- **Detailed requirements**: Use PRD for phased requirements
- **Internal-only changes**: Use RFC or Memo
- **Bug fixes**: Direct implementation, no PRFAQ needed
- **Small features**: Use PRD directly if no press release needed

### PRFAQ in the Planning Flow

```
Large Customer-Facing Feature:
1. PRFAQ (vision and narrative)
   └─ Answer: What's the customer value? Why now?

2. PRD (requirements and phases)
   └─ Answer: What are the problems? What are the requirements?

3. RFC (technical design)
   └─ Answer: How do we build it?

Small Feature:
1. PRD only (skip PRFAQ)

Technical Improvement:
1. RFC only (skip PRFAQ and PRD)
```

## PRFAQ Structure

### Required Sections

```
PRFAQ [Name of Capability]
├─ Header (summary, owners, status)
├─ Press Release
│  ├─ Heading (one sentence pitch)
│  ├─ Summary (problem, solution, testimonial, quote)
│  ├─ Customer experience
│  └─ Call to action
├─ Why Now? (business case)
└─ FAQs
   ├─ Internal FAQs
   └─ External FAQs
```

### 1. Title and Header

```
# PRFAQ [Name of Capability]

**Summary:** A mock press release and FAQ for [one sentence pitch].

| Created: [Date] | Status: WIP | Complete | Obsolete |
| :---- | :---- |
| Owner: [PM lead] | Related Docs: [Links] |
| Eng Lead: [Name] | |
| Design Lead: [Name] | |
| Tech Advisor: [Name] | |
| Product Advisor: [Name] | |
```

**Fields**:
- **Summary**: One sentence describing the PRFAQ
- **Created**: Date PRFAQ was first written
- **Status**: WIP → Complete → Obsolete
- **Owner**: Product Manager leading this feature
- **Eng Lead**: Engineering lead for implementation
- **Design Lead**: Designer responsible for UX
- **Tech/Product Advisors**: Senior stakeholders providing guidance
- **Related Docs**: Links to PRD, RFC, market research

### 2. Press Release

**Purpose**: Write a mock press release as if the feature has already launched. This is the core of the PRFAQ.

#### Heading (One Sentence Pitch)

**Format**:
```
Heading
One Sentence Pitch
```

**Guidelines**:
- Clear value proposition in one sentence
- Customer-focused language
- Avoid jargon or technical terms
- Make it compelling

**Examples**:
- "HashiCorp Vault Radar Automatically Detects and Remediates Secrets Sprawl"
- "Terraform Cloud Introduces Policy-as-Code for Infrastructure Governance"
- "HCP Boundary Enables Zero-Trust Access to Multi-Cloud Infrastructure"

#### Press Release Body

**Format**:
```
SAN FRANCISCO, [Date: March 16, 2023] (GLOBE NEWSWIRE) -- HashiCorp, Inc.
(NASDAQ: HCP), a leading multi-cloud infrastructure automation software
provider, announced... [Summary]

[Multiple paragraphs covering:]
- Problem
- Solution
- Customer Testimonial
- Leadership Quote
- Customer Experience
- Call to Action
```

**Guidelines**:

**Problem (1-2 paragraphs)**:
- What pain do customers experience today?
- Why is this a significant problem?
- How does this affect their workflow or business?
- Be specific with real customer scenarios

**Solution (1-2 paragraphs)**:
- What does the new capability do?
- How does it solve the problem?
- What makes this solution unique?
- Key benefits in customer terms (not features)

**Customer Testimonial (1 paragraph)**:
- Mock quote from target persona
- Specific about the value they received
- Authentic voice (sound like a real customer)
- Include company name and title

Example:
```
"Before Vault Radar, we spent weeks manually scanning repositories for
leaked credentials. Now, Vault Radar automatically discovers secrets across
our entire infrastructure in minutes, giving us peace of mind that we're
secure," said Jane Smith, VP of Security at Acme Corp.
```

**Leadership Quote (1 paragraph)**:
- Quote from HashiCorp exec (CEO, CPO, CTO)
- Strategic importance of the capability
- Vision for how this fits into product roadmap
- Industry perspective

Example:
```
"Organizations are struggling with secrets sprawl as they adopt multi-cloud
infrastructure," said Armon Dadgar, Co-founder and CTO of HashiCorp.
"Vault Radar brings automated secrets detection to the HashiCorp Cloud
Platform, enabling teams to secure their infrastructure without slowing down
development velocity."
```

**Customer Experience (1-2 paragraphs)**:
- Walk through what it's like to use the feature
- Highlight ease of use, speed, or efficiency
- Connect to customer pain points mentioned earlier
- Show before/after transformation

**Call to Action (1 paragraph)**:
- How can customers get started?
- Pricing information (if applicable)
- Links to documentation, tutorials, or sign-up
- Availability (GA, beta, early access)

Example:
```
Vault Radar is now available in beta on HCP. Customers can sign up for early
access at https://cloud.hashicorp.com/radar. The feature will be generally
available in Q2 2024 and included in all HCP Vault Plus plans.
```

### 3. Why Now?

**Purpose**: Provide the business case for investing in this capability now.

**Questions to Answer**:
```
- How does this align to strategic goals for the product line?
- What is the current experience and how will it change?
- How important is the user need?
- How satisfied are users with current alternatives?
- Will this disrupt current alternatives?
- What value will it bring to the business?
- What is the cost to deliver this capability?
- What percentage of addressable market will value this?
- What happens if we don't invest in this?
```

**Guidelines**:
- **Be honest**: These are hypotheses that require validation
- **Use data**: Customer interviews, market research, competitor analysis
- **Quantify when possible**: Revenue impact, market size, adoption estimates
- **Address timing**: Why now vs. 6 months from now?
- **Consider alternatives**: What if we build something else instead?

**Example Structure**:
```
## Why Now?

### Strategic Alignment
This capability aligns with our FY24 goal to expand HCP adoption in
enterprise security teams. Vault Radar directly addresses the #1 request
from enterprise prospects: automated secrets detection.

### Market Opportunity
- 78% of security teams report secrets sprawl as a top concern (Gartner 2023)
- Current alternatives (GitHub Advanced Security, GitGuardian) don't integrate
  with HashiCorp Vault for automated remediation
- TAM: $500M for secrets detection market, growing 25% YoY

### Business Value
- Revenue: $10M ARR potential in first year (based on enterprise add-on pricing)
- Retention: Reduces churn in enterprise segment by addressing top pain point
- Competitive: Differentiates HCP Vault from AWS Secrets Manager

### Cost to Build
- Engineering: 3 engineers for 6 months = $450K
- ROI: Payback in ~5 months based on revenue projections

### Risk of Not Building
- Lose enterprise deals to competitors offering secrets detection
- Existing customers may churn to integrated alternatives
- Miss FY24 revenue targets for HCP Vault expansion
```

### 4. Internal FAQs

**Purpose**: Answer questions from internal stakeholders during product discovery and delivery.

**Guidelines**:
- **Common concerns**: Engineering complexity, go-to-market strategy, pricing
- **Tough questions**: What if competitors copy this? Can we deliver on time?
- **Cross-functional**: Address questions from Eng, Sales, Marketing, Support
- **Honest answers**: Don't sugarcoat challenges
- **Link to details**: Reference PRD or RFC for technical questions

**Example Questions**:
```
## Internal FAQs

Q. What are the main technical risks?
A. The biggest risk is performance at scale. Scanning thousands of repositories
   could overload our API. We're mitigating this with:
   - Rate limiting and queuing system
   - Incremental scanning (only new commits)
   - Early performance testing with design partners
   See [RFC] for technical details.

Q. How does this compare to GitHub Advanced Security?
A. GitHub Advanced Security detects secrets in code, but doesn't integrate
   with Vault for remediation. Vault Radar goes further by:
   - Automatically rotating leaked credentials
   - Providing unified view across all cloud providers (not just GitHub)
   - Integrating with HCP Vault policies
   This makes Vault Radar better for multi-cloud enterprises.

Q. What's our go-to-market strategy?
A. Target enterprise security teams with existing HCP Vault deployments:
   - Beta program with 10 design partners (Q1)
   - GA launch at HashiConf (Q2)
   - Bundled with HCP Vault Plus plans (no separate SKU)
   - Marketing: Webinar series, case studies, SE enablement

Q. Can we deliver this in 6 months?
A. Yes, if we scope to core detection capabilities in v1:
   - In scope: GitHub, GitLab, AWS, GCP scanning
   - Out of scope: Azure DevOps, automated remediation (v2 feature)
   - Dependencies: API rate limiting RFC must be approved by end of Q4
   See [PRD] for phased requirements.

Q. What if customers want to self-host instead of using HCP?
A. Vault Radar will be HCP-only for v1 to reduce operational complexity.
   We'll evaluate self-hosted version in 2025 based on customer demand.
   Most enterprise customers prefer SaaS for security scanning tools.
```

### 5. External FAQs

**Purpose**: Answer questions that customers might have, written as public documentation.

**Guidelines**:
- **Customer perspective**: What would they ask after reading the press release?
- **Product details**: How does it work? What's included?
- **Getting started**: How do I use this?
- **Pricing and availability**: How much? When can I get it?
- **Integration**: How does this work with my existing setup?
- **Clear and concise**: Public-facing language, no jargon

**Example Questions**:
```
## External FAQs

Q. What types of secrets does Vault Radar detect?
A. Vault Radar detects common secret types including:
   - API keys and tokens
   - Database credentials
   - Private keys (SSH, TLS)
   - Cloud provider credentials (AWS, Azure, GCP)
   - Custom secret patterns you define

Q. How does Vault Radar integrate with my existing Vault deployment?
A. Vault Radar is a managed service on HCP that connects to your existing
   Vault cluster. When a secret is detected, Vault Radar can automatically:
   - Rotate the credential in Vault
   - Revoke access tokens
   - Alert your security team
   No changes needed to your existing Vault configuration.

Q. Which code repositories are supported?
A. Vault Radar supports:
   - GitHub (cloud and Enterprise Server)
   - GitLab (cloud and self-managed)
   - AWS CodeCommit
   - Google Cloud Source Repositories
   Support for Azure DevOps is planned for 2024.

Q. How much does Vault Radar cost?
A. Vault Radar is included with all HCP Vault Plus plans at no additional
   cost. HCP Vault Plus starts at $0.50/hour for a small cluster.
   See https://cloud.hashicorp.com/pricing for details.

Q. Is Vault Radar available for self-hosted Vault?
A. Vault Radar is currently available only on HCP. We're evaluating
   self-hosted options based on customer feedback. If you're interested
   in self-hosted Vault Radar, please contact your account team.

Q. How is this different from GitHub Advanced Security?
A. Vault Radar provides secrets detection with automated remediation
   integrated with HashiCorp Vault. Key differences:
   - Works across all cloud providers, not just GitHub
   - Automatically rotates leaked credentials
   - Unified dashboard for multi-cloud secrets
   - Integrates with Vault policies and access controls
```

## PRFAQ Style Guidelines

### Writing from the Future

**Write as if the feature is already launched**:
- ✅ "Vault Radar detects secrets across your infrastructure"
- ❌ "Vault Radar will detect secrets across your infrastructure"

**Use present tense**:
- ✅ "Customers can sign up today at..."
- ❌ "Customers will be able to sign up at..."

**Be specific about dates**:
- ✅ "SAN FRANCISCO, March 16, 2024 (GLOBE NEWSWIRE) --"
- ❌ "SAN FRANCISCO, [TBD] --"

### Customer-Centric Language

**Focus on benefits, not features**:
- ✅ "Reduce time to detect secrets from weeks to minutes"
- ❌ "Automated scanning with parallel processing"

**Use customer voice**:
- ✅ "Your security team can sleep soundly knowing secrets are monitored"
- ❌ "The system provides monitoring capabilities for secrets"

**Avoid jargon**:
- ✅ "Automatically find and fix leaked passwords"
- ❌ "Leverage ML-powered heuristics for credential exfiltration detection"

### Press Release Format

**Follow standard PR structure**:
1. Dateline (SAN FRANCISCO, Date)
2. Company description (HashiCorp, Inc. (NASDAQ: HCP)...)
3. Announcement (announced today that...)
4. Problem → Solution → Benefits
5. Customer testimonial
6. Leadership quote
7. Call to action

**Professional tone**:
- No hyperbole ("revolutionary", "game-changing")
- Factual and confident
- Focus on customer value

## PRFAQ Workflow

### 1. Drafting

```
1. Start with customer problem
   ├─ Interview customers (5+ interviews minimum)
   ├─ Document pain points
   └─ Validate problem severity

2. Write press release
   ├─ Heading (one sentence pitch)
   ├─ Problem paragraphs
   ├─ Solution paragraphs
   ├─ Mock customer testimonial
   ├─ Mock leadership quote
   └─ Call to action

3. Answer "Why Now?"
   ├─ Strategic alignment
   ├─ Market opportunity
   ├─ Business value
   └─ Cost and ROI

4. Write FAQs
   ├─ Internal: Stakeholder concerns
   └─ External: Customer questions

5. Review and iterate
   └─ Share with PM team, leadership
```

### 2. Review Process

```
1. Share with stakeholders
   ├─ Product team (PMs, designers)
   ├─ Engineering leadership
   ├─ Executive team (CPO, CTO)
   └─ Go-to-market (Marketing, Sales)

2. Gather feedback
   ├─ Is the customer value clear?
   ├─ Is the "why now" compelling?
   ├─ Are concerns addressed in FAQs?
   └─ Does this align with strategy?

3. Iterate on narrative
   ├─ Refine problem/solution framing
   ├─ Strengthen business case
   ├─ Add missing FAQ questions
   └─ Improve clarity and specificity

4. Get buy-in
   ├─ No formal approval needed
   ├─ Use as input for PRD
   └─ Reference in planning discussions
```

### 3. Using the PRFAQ

```
After PRFAQ is complete:

1. Create PRD (Product Requirements)
   ├─ Reference PRFAQ for customer value
   ├─ Break down into requirements
   └─ Define phased delivery

2. Create RFC (Technical Design)
   ├─ Reference PRFAQ for context
   └─ Propose implementation approach

3. Use in planning
   ├─ Align team on vision
   ├─ Prioritize features
   └─ Communicate to leadership

4. Reference in launch
   ├─ Marketing can use PR as starting point
   └─ FAQs inform documentation
```

## Best Practices

### For PRFAQ Authors

1. **Start with customer interviews**: Don't write in a vacuum
2. **Think like a customer**: Write from their perspective, not ours
3. **Be specific**: Real problems, real testimonials (even if mock)
4. **Justify timing**: Answer "why now" with data
5. **Answer objections**: Use FAQs to address concerns
6. **Iterate on narrative**: Rewrite until it's compelling
7. **Get early feedback**: Share draft with product team
8. **Keep it concise**: 3-5 pages maximum

### For PRFAQ Reviewers

1. **Read as a customer**: Would this resonate with you?
2. **Challenge assumptions**: Is the "why now" convincing?
3. **Ask tough questions**: Add to Internal FAQs
4. **Focus on value**: Is the customer benefit clear?
5. **Check feasibility**: Can we actually deliver this?
6. **Provide constructive feedback**: Improve the narrative
7. **Don't nitpick format**: Focus on substance over style

### Common Pitfalls

**❌ Feature list instead of narrative**:
- Fix: Focus on customer story, not technical capabilities

**❌ Vague customer problems**:
- Fix: Use specific examples from customer interviews

**❌ Weak "why now" section**:
- Fix: Add market data, competitive analysis, business metrics

**❌ Defensive FAQs**:
- Fix: Address real concerns honestly, not marketing speak

**❌ Writing from HashiCorp perspective**:
- Fix: Rewrite from customer perspective throughout

## Integration with Other Tools

### PRD Relationship

```
PRFAQ → PRD:
- PRFAQ defines vision and customer value
- PRD defines requirements and acceptance criteria
- Reference PRFAQ in PRD header
```

### RFC Relationship

```
PRFAQ → PRD → RFC:
- PRFAQ: What's the customer value?
- PRD: What are the requirements?
- RFC: How do we build it?
```

### Hermes Integration

- Create PRFAQ in Google Docs
- Add to Hermes for tracking
- Link to related PRDs and RFCs
- Track status (WIP → Complete → Obsolete)

See `/hermes` skill for document management.

### Slack Integration

- Share PRFAQ link for feedback
- Use for alignment discussions
- Reference in planning conversations

See `/slack` skill for communication patterns.

## Troubleshooting

### PRFAQ Feels Too Abstract

**Problem**: Press release is vague and generic.

**Solutions**:
1. Add specific customer examples
2. Include concrete metrics (time savings, cost reduction)
3. Use real quotes from customer interviews
4. Describe detailed use cases
5. Add before/after scenarios

### "Why Now" Is Weak

**Problem**: Business case isn't convincing.

**Solutions**:
1. Add market research data
2. Include competitor analysis
3. Quantify revenue opportunity
4. Show customer demand evidence
5. Explain strategic importance

### Too Many Open Questions

**Problem**: FAQs raise more questions than answers.

**Solutions**:
1. Mark questions as "TBD" with plan to answer
2. Use PRFAQ to identify what needs research
3. Iterate PRFAQ after gathering more data
4. Be honest about unknowns
5. Propose hypotheses to validate

### Leadership Not Aligned

**Problem**: Exec team doesn't buy into the vision.

**Solutions**:
1. Strengthen "why now" with business metrics
2. Address concerns in Internal FAQs
3. Invite exec sponsor to co-author
4. Present PRFAQ in leadership meeting
5. Be open to pivoting based on feedback

## Examples

### Good PRFAQ Examples

Available in HashiCorp's PRFAQ folder:
- **Active Policy**: Clear customer problem, strong business case
- **Plannable Import**: Excellent before/after customer experience
- **High Assurance HCP**: Compelling "why now", thorough FAQs

See PRFAQ folder in Google Drive.

## Additional Resources

### Amazon PRFAQ Resources

- [Working Backwards Book](http://www.workingbackwards.com) - Amazon's methodology
- [Amazon PRFAQ Template](https://www.workingbackwards.com/resources/working-backwards-pr-faq)
- [PRFAQ Guide by Amazon Executive](https://coda.io/@colin-bryar/working-backwards-how-write-an-amazon-pr-faq)

### HashiCorp Resources

- PRFAQ template (this skill)
- PRFAQ examples folder (Google Drive)
- [PRFAQ Presentation](https://docs.google.com/presentation/d/1fSPM7dRHn9XdnNbwZhApdMkt7t9hXQAg/edit#slide=id.p1)
- [PRFAQ Tutorial](https://drive.google.com/file/d/13yLmZDmpIKTGHT6yT0bR8DnH2qvyJ1m7/view?usp=share_link)

### Related Skills

- `/hashicorp` - How we work (PRFAQ process overview)
- `/prd` - Product Requirements Documents
- `/rfc` - Request for Comments (technical design)
- `/memo` - Quick decision memos
- `/hermes` - Document management
- `/google-docs` - Google Docs collaboration

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
