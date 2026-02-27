# UXR: Day 0 Customer Interview — Discovery

**Date:** _______________  
**Participant:** _______________  
**Role/Title:** _______________  
**Company:** _______________

---

## Interview Goal

Understand what problems they're facing with infrastructure — without assuming they have a risk management process in place.

---

## Questions: General Discovery (~20 min)

### 1. Day-to-Day (4 min)
**What does a typical week look like for you managing infrastructure?**

_(Let them talk — listen for pain points, firefighting, toil)_

Notes:


---

### 2. Problems (5 min)
**What's frustrating you most about your infrastructure right now?**

_(Probe if needed: security gaps, surprise costs, things breaking, compliance pressure, tech debt)_

Notes:


---

### 3. Discovery (4 min)
**When something goes wrong, how do you usually find out?**

_(Probe: alerts, incidents, someone tells you, audits, luck)_

Notes:


---

### 4. Prioritization (4 min)
**When there's a lot to fix, how do you decide what to tackle first?**

_(Or: "Does that happen? How do you deal with it?")_

Notes:


---

### 5. Ideal State (3 min)
**If things were working perfectly, what would be different?**

Notes:


---

## Questions: Risk-Focused (alternate) (~20 min)

_Use this track if they're already actively managing risks._

### 1. Current Risks (5 min)
**What are the biggest infrastructure risks you're dealing with right now?**

_(Probe: security, compliance, cost, performance)_

Notes:


---

### 2. Discovery Process (4 min)
**How do you find out about risks today — proactive or reactive?**

_(Probe: tools, manual reviews, incidents, audits)_

Notes:


---

### 3. Pain Points (4 min)
**What's the hardest part about managing infrastructure risk for your team?**

Notes:


---

### 4. Prioritization (4 min)
**When you find multiple risks, how do you decide what to fix first?**

Notes:


---

### 5. Magic Wand (3 min)
**If you could fix one thing about how you handle infrastructure risk, what would it be?**

Notes:


---

## Wrap-Up

- Anything else on your mind?
- Okay if we follow up?

---

## Raw Notes

_(Voice-to-text dump — clean up later)_

Heimdall UI / catalog we mentioned:
https://heimdall.hashicorp.services/site/

We have been trying to follow the datadog schema for Heimdall as best as possible:
https://github.com/DataDog/schema/blob/main/service-catalog/README.md


use AI to solve all the incidents and drive uptime, you know, like all the common goals. We would like to use AI for that too. So I think like as we go through this, like I'm happy to be a customer, but I'm also like looking to understand if my team did have a use case of like an agentic flow that would drive reliability at Hashi and we want to deploy it onto AGF. I'm not sure if that's like the terminology. I guess so. At some point, I'd like to understand how to do that. But that's also in the back of my mind. Yeah, I mean, we're building out what the AGF actually means. It's like the security side. We've got to figure out the data infrastructure with InfraGraph, and then our side with the infrastructure remediation pathways. We're kind of just building it all in different kind of sections and then piecing it together. So, yeah, totally. So yeah, so I called this meeting together mostly because I was like, look, I'm designing a tool for you guys and I haven't met you and I don't have a mental model at all of like how you guys are approaching the work that you're doing, what kind of problems you're really encountering. Like I have documentation and I have some stuff that I've heard, but like I don't really know. And so I just wanted to say hello and just see if I could start sponging some of like the things that you're thinking about and like some of the problems that you're you're working through on a day-to-day basis um so i have questions if you want to start there or if you just want to like dump some stuff just data dump i'm happy to just kind of receive as well uh i'm here for the questions, you got anything specific i think let's go into questions first and then um we'll be about that we can add some stuff um so what are the biggest infrastructure risks you're dealing with right now the biggest infrastructure yeah i mean my assumption is you're managing infrastructure and that you're managing risks of infrastructure but let me back up and like help me ...

So we can 100% be an adopter of the tool. My understanding is it's basically like a Terraform dependabot. Yeah. Yeah. So, yeah, we can 100% be an adopter of that tool and play a customer zero role there. But also, we also want to deploy agents out into the agendic fabric ourselves and create our own tools. So, yes, we can be a customer of the Terraform dependent bot and go that route too. But we also are looking for a paved road approach on deploying agents out to the agendic fabric. And I don't know if you're there yet, because you've only deployed out one tool, so you're probably working through how other people are going to deploy tools out onto the fabric. So I think we can separate those two concerns. But those are the two things that we are interrupted in. Okay. So then on the, I can't speak for the how you integrate more agents into the future with the fabric. It's still like being built. But from the IEC side, like the infrastructure as code, like how would you envision using a tool like this that would be able to scan and identify fixes, create PRs, and then people would essentially resolve them? Like how would you envision using a tool like this? would you be enabling other people? Would you be using it for yourselves? How would you use it? We would probably use it for ourselves. Okay. So the way I would envision it, and we're working on some similar for bug fixes. So the way I envision the workflow, and I don't know if that's how it works, is that the tool is out there scanning a repository, is finding risk and then it automatically creates a PR in our code repository. And then our on-call, as part of on-call rotation, would just review PRs. And if it's all PRs, it would review it and just say yes or no. Or create some sort of chat with LLM itself. You're like, no, this is incorrect, but it's close. And you rework this in this scenario, and then it goes off and comes back with adjusted PR. Very similar to how you would interact with, you know, an entry-level engineer.


---

## Summary

| What I Heard | |
|--------------|---|
| Biggest frustration | |
| How they find issues | |
| How they prioritize | |
| Wish list | |

### Quotes

1. 
2. 

### Follow-Up

- [ ] 
