# A guide to writing HashiCorp announcement blogs

This guide has recommended patterns for writing each section of a typical HashiCorp release announcement blog. These rules aren’t ironclad but they are designed to address common deviations from our style and rules. 

*If you’re looking for a perfect announcement blog example, here’s one: [Announcing HashiCorp Waypoint](https://www.hashicorp.com/blog/announcing-waypoint)*

You can find the baseline HashiCorp writing rules and style guidelines via these links:

* [Our Principles in Our Marketing Voice & Style](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.rzmyh4ag2z8e)    
* [How We Reference Products](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.95uakj2jl8yp)  
* [How We Capitalize (Or Not) Product Features](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.njwp4ffifarg)  
* [Writing Principles and Rules](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.841yn9msz9ls)       
* [Principles](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.qziku6xhbj31)  
* [Rules](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.9828a949tpj0)  
* [Tutorial & Code Block Rules](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.iig99waycz84)  
* [Word List](https://docs.google.com/document/d/1MRvGd6tS5JkIwl_GssbyExkMJqOXKeUE00kSEtFi8m8/edit#heading=h.7xv30zvawyfc)

Below are the key elements of an announcement blog from top to bottom, with guidance for each:

## **Title**: 

Should include keywords indicating what’s notable about the release. But remember:   
*65 characters max* (unless you’re ok with characters past 65 being cut off in search results). That means sometimes you’ll be able to mention only one key feature in the title.

| Good Example: Nomad 1.7 beta improves Vault and Consul integrations, adds NUMA support Bad Example: Announcing Nomad 1.7 beta |
| :---- |

However, if the product or thing announced is completely new, you can focus the title around articulating that. For example, these would be titles for unveiling HCP Vault Secrets back when it was new:

| Good Example: Announcing HCP Vault Secrets \-*or*\- Announcing HCP Vault Secrets for synchronizing secrets Less good Example: HCP Vault Secrets centralizes secrets from everywhere *\[doesn’t tell you its new\]* |
| :---- |

A new product release is interesting in itself, so we don’t necessarily need to try and hook readers by mentioning a feature. 

Titles with *more keywords* will help with SEO, and entice people who might not be interested in the tool without knowing about key features. The tricky part is to avoid keyword stuffing and not go over the 65 character limit. Pro tip: Include the version number of new product release in the title. (e.g. 1.7)

## **Summary sentence**:

This should be **a preview summary** of the news or what’s coming in the article \- deeper detail than the title but still higher level than the blog’s first paragraph. *Make sure it’s a complete sentence*. Don’t treat it like advertising text (see “bad example” below). Keywords are also good to add here to enhance SEO. *NOTE:* The summary sentence is also the meta description that shows up under the title in search results, so it should aim to persuade searchers to click.

| Good Example: Terraform and Terraform Cloud improve developer usability and velocity with a test framework, generated module tests, and stacks. Good Example: Learn how to set up Boundary multi-hop access inside a Kubernetes cluster. |
| :---- |

| Bad Example: Improved developer usability and velocity with a test framework, generated module tests, and stacks. Bad, too long, overly advertorial example: Harness the power of HashiCorp's Terraform Cloud Operator v2 for Kubernetes to manage resources seamlessly. Simplify provisioning with YAML and scale Terraform Cloud agents with ease.  |
| :---- |

## **First sentences**:

The first sentence should either introduce the new thing being announced, or give a quick bit of context or talk about a challenge so you can introduce the new thing in the second sentence.

Try to avoid being too formulaic with the wording. While it’s fine to use the common phrase “we are excited/pleased to announce…” sometimes, *don’t use them every time*. 

| Good Example: Today, we are announcing the general availability of HashiCorp Terraform 1.6, which is [ready for download](https://developer.hashicorp.com/terraform/downloads) and immediately available for use in [Terraform Cloud](https://www.hashicorp.com/products/terraform).   Good Example: [HashiCorp Nomad](https://www.nomadproject.io/) is a simple and flexible orchestrator used to deploy and manage containers and non-containerized applications across multiple cloud, on-premises, and edge environments. Today, we are excited to launch Nomad 1.7, now generally available. Good Example: Today, we’re excited to announce the beta launch of HCP Vault, a managed offering for HashiCorp Vault. |
| :---- |

| Bad Example: HashiCorp Boundary, a modern privileged access management (PAM) offering for cloud-driven environments, provides just-in-time access to infrastructure without requiring end users to manage IP addresses or credentials. Boundary also ensures an organization’s infrastructure is secure and compliant by using identity driven controls and ensuring least-privilege access, session and credential expiration, and session recording. … *\[this is spending too much time introducing Boundary\]* |
| :---- |

## **Introduction section**:

**Keep it brief.**  If there are more than 3-4 new features, consider making a bulleted list of the features that will have section headings below. **BLUF: Bottom Line Up Front** should be your mantra when writing introductions.

Introductions for announcements *should generally be no more than 1-2 paragraphs (3-6 sentences)*. If there’s a lot of context or challenges to talk about, you can create a context section immediately after the introduction. The introduction should focus on showing the reader the key items that will be discussed in the blog so they can quickly decide if they want to read the rest.

If there’s a broader theme to the announcement or its feature list, include that.

The introduction should finish with a sentence or two that provides a summation of what the reader will get/learn from the entire post (**editors call this a “nutgraph”** \- i.e. ‘this-blog-in-a-nutshell \-graph’). In many cases, this sentence can just start with the words “In this post …” but try and add variety when you can.

One case where you might *not* need a nut graph in the introduction is when you finish the introduction with a *bulleted list of new features*.

| Good Example: Today, we are releasing [Terraform 0.3](https://www.terraform.io/?_gl=1*1474rbj*_ga*MTczNzMwODQ5My4xNjk4Njk3MTQ3*_ga_P7S46ZYEKW*MTcwNTQ0MDQ2Ny4xNjUuMS4xNzA1NDQwODg2LjIuMC4w). Terraform is a tool for safely and efficiently building, combining, and launching infrastructure. This version of Terraform introduces modules, dynamic resource counts, user input for parameterization, JSON-based state, provisioner output, improvements to existing providers, and much more. In this post, we'll highlight the major features added, as well as show videos of Terraform showcasing the new features. \_\_\_  Good Example: We’re excited to announce that HashiCorp Terraform 1.7 is now generally available, ready for download, and available for use in Terraform Cloud. Terraform 1.7 features a new mocking capability for the Terraform test framework, a new method for removing resources from state, and an enhancement for config-driven import. These additions help Terraform developers more thoroughly test their modules and gives operators safer and more efficient options for state manipulation. \_\_\_ Good Example: We’re pleased to announce that HashiCorp Consul 1.15 is now generally available to all users. This release represents yet another step forward in our effort to help organizations simplify onboarding to service mesh, improve their troubleshooting workflow, and reduce operational complexity. Important new features in Consul 1.15 include: Envoy access logging Consul Envoy extensions Service-to-service troubleshooting Linux VM runtime support in Consul-native API gateway (Beta) Consul server rate limiting Raft write-ahead log (Experimental) Let’s run through what’s new.  |
| :---- |

| Bad Example: Organizations are moving to the cloud in order to deliver new business and customer value quickly and at scale, going from traditionally “static” datacenters to “dynamic” datacenters. This shift from primarily physical on-premises to a mix of multiple public clouds in addition to their private estates has created challenges for IT organizations. These teams now have to modernize their approach to address changes the cloud brings to provisioning, security, … \[*too much background to read before getting to the point of the post\]* |
| :---- |

## **A context section**

Sometimes you’ll just want to have a super short intro section (1-3 sentences) saying we’re announcing this thing that generally does this, here’s what we’ll talk about in the blog.  Then the very next section after the intro can talk about what we’re hearing from companies, customers, and the community (give our credentials on how many people and orgs we’re gathering feedback from) and then explain what patterns we’re seeing and hearing from them that led us to want to build the thing we’re announcing.

## **A section for each major new feature**

The sections after an introduction can give background or cover various features or aspects of the new release. Having **a section for each major feature** listed in the introduction is often the most straightforward and readable approach. 

Follow this pattern in every feature’s section: 1\) Introduce **what the feature does**, 2\) Show a code block or UI screenshot **example** of the feature 3\) optional \- any more context needed after the example and a link to any new documentation on developer.hashicorp.com associated with the new feature so practitioners can dive deeper.

You can also write overarching sections with subsections for features within each category, but make sure you don’t stack a heading and subheading directly on top of each other without any buffer text between them.

| Bad example:  Security features New PKI UI The new PKI user interface will allow users to… |
| :---- |

If there are a lot of new features in a release or several miscellaneous features that don’t have much you can say about them, consider a section before the conclusion that rolls up all the rest of the features into a final list of ‘all the other features’ with a link to the changelog. Or just link to the changelog with one sentence indicating that the reader should go there for additional minor features.

## **(If necessary) Benefits connecting to speed/efficiency, savings, and/or risk mitigation** 

We want to connect new releases and their features to our themes of speed/efficiency, savings, and/or risk mitigation, *but that doesn’t mean* a blog needs a section devoted to this or that you should robotically list the words ‘reduce risk’ ‘increase speed’ and/or ‘reduce costs’ verbatim in every new release blog.  

Make the benefits specific. Don’t just say that the release delivers vague benefits like “this will save you money” or “this will reduce the time spent on manual tasks and give you back more time for innovation” or “this will reduce risk by limiting the blast radius of an attack”

Instead, tell them how the precise, specific technical processes will change compared to the previous processes now that there is a new feature or thing. Be as  technically specific as you can about how a feature reduces a particular kind of risk or which costs a feature reduces. **Let the reader make the connection** to our themes themselves.

If the post does merit having a section summarizing the technical benefits, put that section *at the end* so as not to break the flow of the article \- and because you can’t summarize benefits until you’ve described what the feature/tool is.

| Good Example: Key benefits of audit logs Collecting activity data with HCP Packer’s audit logs helps organizations improve their: Visibility: by enabling administrators to actively monitor a stream of user activity and answer important questions such as who is changing what? When? And where? Security: by providing access to a historical audit trail that enables security teams to ensure compliance standards are met in accordance with regulatory requirements  |
| :---- |

| Less Good Example: *\[This section came right after the introduction without describing the technical features of the release first. It would be better to integrate some of this info into the sections where we introduce the technical features it mentions. It also feels a bit robotic, like its trying to check each of these themes off a list\]* This new feature benefits infrastructure teams in three ways: Cost savings: They not only reduce infrastructure costs, they also give more time back to infrastructure teams since they don’t have to manually manage and track these resources. Increased efficiency: Administrators can set time-to-live (TTL) settings through the API or UI, which simplifies management and testing. Improved security: Workspaces that are not being actively watched or have been forgotten pose a security risk. Automatically destroying unused workspaces helps organizations meet compliance requirements and reduces the potential attack surface of your infrastructure. |
| :---- |

## **(Conclusion) Learn more / Get started / Next steps / Upgrade now**

Every post needs a conclusion. The conclusion should generally stick to some form of these 4 header options above and should include any summation or themes that the engineers had for this release. It *must* include one or more **calls to action** to learn more, upgrade, get started, or take next steps. This can include links to *HashiCorp Developer guides/docs*, and any pitch you’d like to make for certain product SKUs (HCP/Enterprise).

| Good Example: Get started with Terraform 1.7 For more details and to learn about all of the enhancements in Terraform 1.7, please review the full [HashiCorp Terraform 1.7 changelog](https://github.com/hashicorp/terraform/releases/tag/v1.7.0). Additional resource links include: [Download Terraform 1.7](https://developer.hashicorp.com/terraform/downloads) [Sign up for a free Terraform Cloud account](https://app.terraform.io/public/signup/account) Read the [Terraform 1.7 upgrade guide](https://developer.hashicorp.com/terraform/language/v1.7.x/upgrade-guides) Get hands-on with tutorials at [HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials) As always, this release wouldn't have been possible without all of the great community feedback we've received via GitHub issues and from our customers. Thank you\! |
| :---- |

| Bad Example:  Summary In this post we learned about Boundary 7, its new security features, and how they reduce risk.  |
| :---- |

## **Some awesome CTAs**

### Practitioner news:

This release wouldn't have been possible without all of the great community feedback we've received via GitHub issues and from our customers. Thank you\!

### BDM content:

IT leaders need more than just products — they need trusted partners who can help them untangle operational challenges before, during, and after implementation. HashiCorp is a trusted partner to thousands of customers, including 200+ of the Fortune 500\. Tell us about your biggest pain points so that we can offer our tailored guidance.
