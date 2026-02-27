---
name: blog
description: Template and best practices for writing blogs at HashiCorp
---

## Prerequisites

This skill works best with the **Atlassian MCP Server** configured, which enables direct access to Confluence pages containing the HashiCorp style guides.

**To set up the Atlassian MCP Server:**

1. See [atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server) for official setup instructions
2. For Claude Code, add to `~/.claude/.mcp.json`:
   ```json
   {
     "atlassian": {
       "type": "http",
       "url": "https://mcp.atlassian.com/v1/mcp"
     }
   }
   ```
3. Restart your AI coding tool after configuration

Without the MCP server configured, you can still use this skill by manually referencing the style guide links below.

---

## HashiCorp Style Guide

Read the HashiCorp Style guide's:

* [Tone](https://hashicorp.atlassian.net/wiki/spaces/CCAS/pages/3377922084/Our+tone)
* [Word list](https://hashicorp.atlassian.net/wiki/spaces/CCAS/pages/3660677125/Word+list)
* [Writing rules](https://hashicorp.atlassian.net/wiki/spaces/CCAS/pages/3660775462/Writing+rules)
* [Writing examples](https://hashicorp.atlassian.net/wiki/spaces/CCAS/pages/3660906530/Writing+examples)
* [Content taxonomy](https://hashicorp.atlassian.net/wiki/spaces/CCAS/pages/3907520089/Content+taxonomy+definitions+channel+menu)

Learn more about our blog writing style and best practices by watching this video:

HashiCorp Writing Best Practices: Fostering Intentionality

## Fill these out at the top of the blog:

### Alignment:
  * Audience: [TDMs, BDMs, and/or Practitioners? Are we introducing them to HashiCorp? Products? Or are they already a user here to learn more?]
  * Content goal: [Awareness, lead generation, customer education, internal enablement, etc.]
  * HashiCorp alignment: [How does this blog support a product, campaign, or company goal?]
  * Intended outcome for reader: [What do you want them to think, feel, and do after reading this post?]

### Ticket URL:
  * Author(s): (3 authors max) (New authors include BIO and SOCIAL URLS)
  * Release date:
  * Release time:

### Metadata
* Blog section: [Technology & Solutions, Strategy & Innovation, Customer Stories & Success]
* Topic tags: [Secrets & identity management, Infrastructure automation, AI, Risk & compliance, Optimize operations, Speed & agility],
* Tracking tags:[Developer relations, Partners, Solutions Engineering]
* Products covered: [more than just a mention of the product] (Needs to be one of Terraform, Vault, Vault Radar, Boundary, Nomad, Consul, Vagrant, Waypoint, Packer or HCP)

IMAGES - Don't just drop them in this doc only: Attach all images to the corresponding Asana task when submitting the draft. If you're not in Asana, provide a google/one drive link to the files. Diagrams that need design team revision (most) will need to be submitted to them ASAP to avoid delays. Diagrams should use color hex codes: #0D0E12 for dark background, #ECEDEB for white lines and text.

* Social: (Write a 280-character social text block. It can be similar, but not a copy-paste of the summary sentence or the first few sentences)

## Title [use sentence case, 65-70 characters max]

Summary sentence: 165 character MAX sentence describing what the reader will learn from the post or listing key new features.

[Refer here for the best practices for writing the summary sentence and how to write announcement posts](best-practices.md)

Set the context: What's new or important? Who is this for and why now?

Finish your introduction with a "this post in a nutshell" sentence: ex: "In this post, we will cover x, y, and z"

IMPORTANT: Blog length: Aim for 600-1200 words

Use active voice, keep paragraphs and sentences short and concise, avoid fluffy language and don't use jargon that the target audience might not understand

### Section heading [use sentence case]
Explain a key idea, problem, or update. Include links or visuals as needed.

### Section heading [use sentence case] - and more sections if needed

Explain a key idea, problem, or update. Include links or visuals as needed. Further develop the story. Show implications or benefits.

### Learn more or Get started or Next steps or Upgrade now
Think - What idea should stick?
Feel - Inspired, confident, informed?
Do - Click, try, explore, contact?

### Include a CTA and any relevant resources for further learning.

Examples could include
Product/solution pages for trial signup
Lead asset registration page (e.g. white paper download)
Docs or tutorials
Customer stories
Related blog posts
Events or webinars

_____
End of blog

## Final checklist

- [ ] Title and summary are clear, concise
- [ ] Social copy is unique and engaging
- [ ] Audience and goals are clearly defined
- [ ] Style guide followed throughout (don't capitalize features unless you have a rare exception granted)
- [ ] Headings use sentence case
- [ ] CTA included and outcome clear
- [ ] Content team has editing access
- [ ] Image files attached to Asana or linked in draft (gdrive, onedrive)
