# HashiCorp Personas & Frameworks Reference

This document captures the persona framework, Jobs to be Done (JTBD), and Critical User Journeys (CUJ) methodology used at HashiCorp.

Source: https://sites.google.com/hashicorp.com/personasv2/

---

## Persona Categories

HashiCorp organizes personas into three main categories based on their relationship to the product:

### 1. User Personas

**Definition**: Users who directly interact with a system interface and are most affected by it. They are the core audience for the product experience and engage with features and functionalities to achieve their goals.

Also known as: "Practitioners" or "Hands on keyboard" users

**Key User Personas:**
- Manager of Business Line
- App Developer
- Manager of CloudOps
- SRE (Site Reliability Engineer)
- Platform Engineer
- System Security Engineer
- Compliance Manager
- Finance Manager
- Procurement Manager

### 2. Buyer Personas

**Definition**: Personas affected by the product often, without directly interacting with it. They are influential in driving or facilitating buying decisions in the organization.

Also known as: "Business Decision Makers (BDM)" or occasionally "Technical Decision Makers (TDM)"

**Key Buyer Personas:**
- CEO (Chief Executive Officer)
- CTO (Chief Technology Officer)
- CIO (Chief Information Officer)
- CISO (Chief Information Security Officer)
- CFO (Chief Finance Officer)
- VP/Director of CloudOps
- VP/Director of Business Line
- VP/Director of Finance
- VP/Director of Security

**Segmentation Model** (by Lifetime Value):
| Segment | LTV Range | Characteristics |
|---------|-----------|-----------------|
| Globals | >$10M | Largest enterprise accounts; prefer self-managed Enterprise offerings; often highly regulated industries |
| Enterprise | $2.5M - $10M | Strategic accounts with high potential; focus on Extension and Expansion motions |
| Corporate | $500K - $2.5M | High-velocity segment; faster deal cycles (<100 days); cloud offerings focus |

### 3. Champion Personas

**Definition**: Individuals with influence in a company who hold power because of their position and business expertise. They are potential business champions with access to buyer personas and aim to find solutions for critical business challenges.

Also known as: "Technical Decision Makers (TDM)"

**Key Champion Personas:**
- Manager of Business Line
- Manager of CloudOps
- System Security Engineer

---

## Jobs to Be Done (JTBD)

### Background

Developed by Clayton Christensen, Harvard Business School professor, in the 1990s. The framework is inspired by the idea that customers "hire" products or services to fulfill specific jobs or tasks in their lives. It shifts focus from product features to customer needs and desired outcomes.

### JTBD Format

```
When [circumstance], I want to [user goal or need] so that [motivation]
```

**Components:**
| Component | Description |
|-----------|-------------|
| **Circumstance** | Additional information about the situation or context surrounding the job |
| **User goal or need** | The action the customer wants to accomplish |
| **Motivation** | The thing or outcome the customer is trying to achieve |

### Example JTBD

```
When deploying code to production environments,
I want to manage and access secrets
so that I can maintain the integrity and security of our applications 
without compromising developer productivity.
```

### Further Reading
- HBR: "Know Your Customers' Jobs to Be Done" (2016)
- HBR: "Marketing Malpractice: The Cause and the Cure" (2005)
- NN/g: "Personas vs. Jobs-to-Be-Done"

---

## Critical User Journeys (CUJ)

### Definition

Critical User Journeys raise product excellence and adoption by helping product teams define, prioritize, measure, and improve the experiences that users care about.

User journeys define how a user can work towards achieving a particular Job to be Done. Each CUJ defines a path to help achieve a goal and maps the various steps in completing (or not) the journey.

### Why "Critical"?

There are many journeys users can take in products. With limited resources, teams cannot measure and improve all of them. Critical User Journeys are **prioritized** based on importance to users achieving their goals.

### Types of Critical Journeys

| Type | Description | Example |
|------|-------------|---------|
| **Frequent** | Tasks users do regularly | View a PAYG bill |
| **Impactful** | Critical to achieving key goals, driving business KPIs, or meeting regulatory requirements | Emergency situations, compliance workflows |

### CUJ Format

```
As a [persona] I want to [action or task] to achieve [goal].
```

**Components:**
| Component | Description |
|-----------|-------------|
| **Persona** | Role in the organization completing the journey |
| **Action or task** | Specific action the persona wants to accomplish |
| **Goal** | Larger outcome the persona is trying to achieve with this task |

### Example CUJ

```
Role: App Developer

As an app developer I want to easily create initial secrets quickly 
in order to get my application up and running fast.
```

---

## How to Use Personas

### For Marketing Professionals

**Content and Messaging Development:**
Leverage personas to understand the personas we market to, their challenges, needs, profiles, and pain points. Incorporate this knowledge into messaging and content targeting specific personas so the message resonates with them.

**Marketing Campaign Development:**
Review personas when designing marketing campaigns to ensure we are targeting the appropriate audience and using the right language, content, and channels based on the specific personas.

### For Sales Professionals

**Outreach:**
Review personas before reaching out to prospects and customers to understand how to best speak their language and present HashiCorp solutions in a way that matters to that specific persona.

**Sales Calls:**
Review personas before sales calls and meetings to understand how to best speak their language and present HashiCorp solutions in a way that matters to that specific persona.

### For Product Managers

**Requirements (PRD/RFC):**
User personas help nail the business case for a product idea. Bringing in user personas allows you to ground ideas within the bigger context of the business. What kind of users is this idea meant to help and how valuable does that make it?

**Initiatives/Epics:**
Start with your primary persona and capture the functionality as epics, as coarse-grained, high-level stories. Write all the epics necessary to meet the persona goals but keep them rough and sketchy at this stage.

**User Stories:**
With a holistic but coarse-grained description of your product in place, start progressively breaking your epics into smaller stories. Rather than detailing all epics and writing all user stories upfront, derive stories step by step.

### For Developers

**Epics:**
Start with your primary persona and capture the functionality as epics, as coarse-grained, high-level stories. Write all the epics necessary to meet the persona goals but keep them rough and sketchy at this stage.

**User Stories:**
With a holistic but coarse-grained description of your product in place, start progressively breaking your epics into smaller stories. Rather than detailing all epics and writing all user stories upfront, derive stories step by step.

### For Designers

**Requirements (PRD/RFC):**
User personas help nail the business case for a product idea. Bringing in user personas allows you to ground ideas within the bigger context of your business. What kind of users is this idea meant to help and how valuable does that make it?

**Epics:**
Start with your primary persona and capture the functionality as epics, as coarse-grained, high-level stories. Write all the epics necessary to meet the persona goals but keep them rough and sketchy at this stage.

**User Stories:**
With a holistic but coarse-grained description of your product in place, start progressively breaking your epics into smaller stories. Rather than detailing all epics and writing all user stories upfront, derive stories step by step.

**Journey Mapping:**
Select the main persona(s) of the experience you would like to describe, keep in mind their thoughts and feelings while using your product/service.

**Research:**
Use the persona to refer to the segment you need to run your research.

**Design Walkthrough:**
When doing a walkthrough of the designs, use the personas on it.

**Documentation:**
When documenting your designs, use personas to explain what the user is trying to accomplish.

**Usability Testing:**
Use the persona to refer to the segment you need to validate your designs.

### For PLs/PMM/Docs/Support

The faster and better we understand the needs of our users, the more effectively we can communicate those needs to others, align on solutions, and work together to create strong experiences for our users.

---

## Product-Specific Resources

HashiCorp maintains detailed JTBD and CUJ documentation for each product line:

### HCP (HashiCorp Cloud Platform)
- Platform JTBDs & CUJs

### Secure Products
- Boundary Personas, JTBD, CUJs
- Vault Radar Persona + JTBD + CUJ
- Vault Unified Persona + JTBD + CUJ

### Infrastructure Products
- HCP TF & Ecosystem - Persona, JTBD, CUJ
- TF Enterprise
- Packer
- Waypoint Personas + JTBDs + CUJs
- HCP Vagrant Registry Personas + JTBDs + CUJs
- Nomad Personas + JTBDs + CUJs
- Consul Personas + JTBD + CUJ

---

## Quick Reference Templates

### JTBD Template
```
When [circumstance],
I want to [user goal or need]
so that [motivation].
```

### CUJ Template
```
As a [persona]
I want to [action or task]
to achieve [goal].
```

### Persona Classification Quick Check

| Question | User | Buyer | Champion |
|----------|------|-------|----------|
| Directly uses the product? | Yes | No | Sometimes |
| Influences purchase decision? | Indirectly | Yes | Yes |
| Has budget authority? | No | Yes | Sometimes |
| Technical hands-on? | Yes | Rarely | Often |
| Also known as | Practitioner | BDM | TDM |

---

## Further Learning

- NN/g: "Why Prioritize Personas?" (Video)
- NN/g: "Personas Are Living Documents: Design Them to Evolve"
- NN/g: "Personas: Study Guide"
