# HDS Content Guide

Writing UI copy that follows HashiCorp's voice, tone, and writing style guidelines.

## The HashiCorp Voice

The **voice** represents HashiCorp's consistent personality across all content. It defines **what** we communicate and remains uniform regardless of medium or context.

**Our voice is:**
- **Clear** - Easy to understand, no confusion
- **Brief** - Concise and to the point
- **Simple** - Straightforward, accessible language
- **Authentic** - Genuine and truthful
- **Helpful** - Provides tangible value
- **Confident** - Assured but not arrogant
- **Principle-aligned** - Reflects HashiCorp values

## Tone

**Tone** is **how** we deliver messages. It's flexible and adapts based on content type and context, setting the emotional mood.

### Tone Varies by Context

**Onboarding & Getting Started:**
- Encouraging and supportive
- "Let's get you set up with your first workspace"
- "You're ready to create your first run!"

**Errors & Problems:**
- Helpful and solution-oriented
- "We couldn't save your changes. Check your connection and try again."
- Avoid blame: ❌ "You entered an invalid email" → ✅ "Enter a valid email address"

**Success & Confirmation:**
- Positive but not overly celebratory
- "Workspace created" (simple)
- "Your changes have been saved" (clear)

**Technical Documentation:**
- Direct and informative
- "This workspace uses remote execution"
- "Runs are queued when triggered"

**Warnings & Important Info:**
- Serious but not alarming
- "This action cannot be undone"
- "Deleting this workspace will remove all associated runs"

## Do's ✅

### Be Clear, Brief, and Simple
```handlebars
{{! ✅ GOOD }}
<Hds::Button @text="Create workspace" />

{{! ❌ TOO WORDY }}
<Hds::Button @text="Create a new workspace in your organization" />
```

### Foster Confidence
```handlebars
{{! ✅ GOOD - Confident and helpful }}
<Hds::Alert @color="success" as |A|>
  <A.Title>Workspace created</A.Title>
  <A.Description>You can now configure your workspace settings.</A.Description>
</Hds::Alert>

{{! ❌ UNCERTAIN }}
<Hds::Alert @color="success" as |A|>
  <A.Title>We think it worked</A.Title>
  <A.Description>Your workspace might be ready now.</A.Description>
</Hds::Alert>
```

### Be Truthful
```handlebars
{{! ✅ GOOD - Honest about limitations }}
<F.HelperText>
  This feature is in beta. Some functionality may change.
</F.HelperText>

{{! ❌ OVERPROMISE }}
<F.HelperText>
  This revolutionary feature will transform your entire workflow!
</F.HelperText>
```

### Be Helpful with Examples
```handlebars
{{! ✅ GOOD - Tangible help }}
<F.HelperText>
  Use lowercase and hyphens. Example: my-production-workspace
</F.HelperText>

{{! ❌ VAGUE }}
<F.HelperText>
  Follow naming conventions.
</F.HelperText>
```

## Don'ts ❌

### Avoid Flowery Language
```handlebars
{{! ❌ BAD - Flowery }}
<A.Title>Magnificent! Your workspace has been splendidly created!</A.Title>

{{! ✅ GOOD - Simple }}
<A.Title>Workspace created</A.Title>
```

### Avoid Technical Jargon
```handlebars
{{! ❌ BAD - Jargon }}
<F.Error>API endpoint returned HTTP 422 with validation errors in payload</F.Error>

{{! ✅ GOOD - Clear }}
<F.Error>Enter a valid workspace name</F.Error>
```

### Avoid Aggressive Sales Language
```handlebars
{{! ❌ BAD - Pushy }}
<A.Description>
  Upgrade NOW to unlock amazing premium features you can't live without!
</A.Description>

{{! ✅ GOOD - Informative }}
<A.Description>
  Upgrade to enable team management and advanced features.
</A.Description>
```

### Avoid Formal or Mechanical Tone
```handlebars
{{! ❌ BAD - Formal/robotic }}
<A.Description>
  The system has successfully processed your request and the workspace entity has been persisted.
</A.Description>

{{! ✅ GOOD - Natural }}
<A.Description>
  Your workspace has been created.
</A.Description>
```

### Avoid Condescending Language
```handlebars
{{! ❌ BAD - Condescending }}
<F.HelperText>
  Obviously, you need to enter a valid email address.
</F.HelperText>

{{! ✅ GOOD - Respectful }}
<F.HelperText>
  Enter your email address.
</F.HelperText>
```

### Avoid Vague Communication
```handlebars
{{! ❌ BAD - Vague }}
<A.Description>Something went wrong. Please try again.</A.Description>

{{! ✅ GOOD - Specific }}
<A.Description>We couldn't connect to the server. Check your connection and try again.</A.Description>
```

## Writing Style Guidelines

### Capitalization

#### Sentence Case for Most UI
Use **sentence case** for:
- Headings
- Labels
- Links
- Buttons
- Descriptions

```handlebars
{{! ✅ CORRECT - Sentence case }}
<Hds::Text::Display @tag="h2" @size="400">
  Workspace settings
</Hds::Text::Display>

<Hds::Button @text="Create workspace" />

<F.Label>Workspace name</F.Label>

{{! ❌ INCORRECT - Title case }}
<Hds::Text::Display @tag="h2" @size="400">
  Workspace Settings
</Hds::Text::Display>
```

#### Title Case Exceptions
Only use title case for:
- Product names (Terraform, Vault, Consul, etc.)
- Specific feature names that are official:
  - Terraform Registry
  - Terraform Stacks
  - Vault Agent
  - Vault Proxy
  - Boundary Client Agent
  - Nomad Autoscaler

```handlebars
{{! ✅ CORRECT }}
<p>Connect to Terraform Registry</p>
<p>Configure your private module registry</p>

{{! ❌ INCORRECT }}
<p>Connect to terraform registry</p>
<p>Configure your Private Module Registry</p>
```

#### Feature Names
**Don't capitalize** feature names as proper nouns:

```handlebars
{{! ✅ CORRECT }}
<p>Enable the private module registry</p>
<p>Configure remote state</p>
<p>Set up cost estimation</p>

{{! ❌ INCORRECT }}
<p>Enable the Private Module Registry</p>
<p>Configure Remote State</p>
<p>Set up Cost Estimation</p>
```

### Grammar

#### Address Users as "You"
```handlebars
{{! ✅ CORRECT }}
<F.HelperText>You can change this later in settings.</F.HelperText>

{{! ❌ INCORRECT }}
<F.HelperText>One can change this later in settings.</F.HelperText>
```

#### Use "We" for HashiCorp
```handlebars
{{! ✅ CORRECT }}
<A.Description>We recommend enabling auto-apply for development workspaces.</A.Description>

{{! ❌ INCORRECT - Hedging }}
<A.Description>It is generally recommended that auto-apply might be enabled...</A.Description>
```

#### Use Active Voice
```handlebars
{{! ✅ CORRECT - Active }}
<A.Description>The system deleted your workspace.</A.Description>

{{! ❌ INCORRECT - Passive }}
<A.Description>Your workspace was deleted by the system.</A.Description>
```

#### Use Present Tense & Imperatives
```handlebars
{{! ✅ CORRECT - Present/imperative }}
<Hds::Button @text="Create workspace" />
<F.HelperText>Run the command to connect.</F.HelperText>

{{! ❌ INCORRECT - Past/future }}
<Hds::Button @text="Will create workspace" />
<F.HelperText>You will need to run the command...</F.HelperText>
```

#### Acronyms
Spell out uncommon acronyms on first use:

```handlebars
{{! ✅ CORRECT }}
<p>Connect your Version Control System (VCS) provider.</p>
<p>Later references: Configure VCS settings...</p>

{{! Common acronyms don't need expansion }}
<F.Label>API token</F.Label>
<F.Label>IP address</F.Label>
<F.Label>Workspace ID</F.Label>
```

### Action Labels (Buttons)

Use **verb + noun** construction:

#### Create vs. Add
```handlebars
{{! CREATE - For new entities }}
<Hds::Button @text="Create workspace" />
<Hds::Button @text="Create variable" />

{{! ADD - For establishing relationships }}
<Hds::Button @text="Add team member" />
<Hds::Button @text="Add to project" />
```

#### Delete vs. Remove
```handlebars
{{! DELETE - Destroys entities }}
<Hds::Button @text="Delete workspace" @color="critical" />

{{! REMOVE - Dissolves relationships }}
<Hds::Button @text="Remove team member" />
<Hds::Button @text="Remove from project" />
```

#### Edit, View, Save
```handlebars
{{! EDIT - Modify entities }}
<Hds::Button @text="Edit settings" />

{{! VIEW - Preview entities }}
<Hds::Button @text="View details" />

{{! SAVE - Form submissions }}
<Hds::Button @text="Save" type="submit" />
<Hds::Button @text="Save changes" type="submit" />
```

#### Use Imperatives
```handlebars
{{! ✅ CORRECT - Imperative }}
<Hds::Button @text="Invite users" />
<Hds::Button @text="Export data" />

{{! ❌ INCORRECT - Not imperative }}
<Hds::Button @text="User invitation" />
<Hds::Button @text="Data export" />
```

### Punctuation

#### Oxford Comma
```handlebars
{{! ✅ CORRECT - Oxford comma }}
<p>This workspace includes runs, state files, and variables.</p>

{{! ❌ INCORRECT - Missing Oxford comma }}
<p>This workspace includes runs, state files and variables.</p>
```

#### Avoid Exclamation Points
```handlebars
{{! ✅ CORRECT - Calm }}
<A.Title>Workspace created</A.Title>

{{! ❌ INCORRECT - Overly excited }}
<A.Title>Workspace created!</A.Title>
<A.Title>Success!</A.Title>

{{! ⚠️ ACCEPTABLE - Genuine strong emotion }}
<A.Title>Warning: This will delete all data!</A.Title>
```

#### Percentages
```handlebars
{{! ✅ CORRECT - Symbol }}
<p>99.9% uptime</p>

{{! ❌ INCORRECT - Word }}
<p>99.9 percent uptime</p>
```

#### Dashes
```handlebars
{{! ✅ CORRECT - En dash for ranges }}
<p>Runs 1–10 of 50</p>

{{! ❌ INCORRECT - Hyphen }}
<p>Runs 1-10 of 50</p>
```

### Spelling

Use **American English**:
- canceled (not cancelled)
- organization (not organisation)
- color (not colour)
- analyze (not analyse)

## Content Patterns

### Form Labels

**Keep labels short:**
```handlebars
{{! ✅ GOOD }}
<F.Label>Name</F.Label>
<F.Label>Description</F.Label>
<F.Label>Execution mode</F.Label>

{{! ❌ TOO LONG }}
<F.Label>Enter a name for this workspace</F.Label>
```

**Use helper text for details:**
```handlebars
<Hds::Form::TextInput::Field as |F|>
  <F.Label>Workspace name</F.Label>
  <F.HelperText>
    Use lowercase letters, numbers, and hyphens. Example: my-prod-workspace
  </F.HelperText>
</Hds::Form::TextInput::Field>
```

### Error Messages

**Be specific and actionable:**
```handlebars
{{! ✅ GOOD - Specific solution }}
<F.Error>Workspace name must be 3-90 characters and contain only letters, numbers, and hyphens.</F.Error>

{{! ❌ BAD - Vague }}
<F.Error>Invalid name.</F.Error>
```

**Don't blame the user:**
```handlebars
{{! ✅ GOOD }}
<F.Error>Enter a valid email address.</F.Error>

{{! ❌ BAD }}
<F.Error>You entered an invalid email address.</F.Error>
```

### Success Messages

**Be clear but not overly celebratory:**
```handlebars
{{! ✅ GOOD }}
<A.Title>Workspace created</A.Title>
<A.Description>You can now configure your workspace settings.</A.Description>

{{! ❌ TOO MUCH }}
<A.Title>Congratulations! Amazing!</A.Title>
<A.Description>You've successfully created the most incredible workspace ever!</A.Description>
```

### Confirmation Dialogs

**Be clear about consequences:**
```handlebars
<Hds::Modal as |M|>
  <M.Header>Delete workspace</M.Header>
  <M.Body>
    <p>Deleting <strong>{{@workspace.name}}</strong> will:</p>
    <ul>
      <li>Remove all runs and state history</li>
      <li>Delete all variables and settings</li>
      <li>Cancel any queued or running operations</li>
    </ul>
    <p>This action cannot be undone.</p>
  </M.Body>
  <M.Footer>
    <Hds::ButtonSet>
      <Hds::Button @text="Cancel" @color="secondary" />
      <Hds::Button @text="Delete workspace" @color="critical" />
    </Hds::ButtonSet>
  </M.Footer>
</Hds::Modal>
```

### Empty States

**Explain and provide next steps:**
```handlebars
<Hds::ApplicationState @media="/empty-workspaces.svg">
  <:title>No workspaces yet</:title>
  <:description>
    Workspaces organize your infrastructure. Create your first workspace to get started.
  </:description>
  <:action>
    <Hds::Button @text="Create workspace" @color="primary" />
  </:action>
</Hds::ApplicationState>
```

### Loading States

**Keep it simple:**
```handlebars
{{! ✅ GOOD }}
<p>Loading workspaces...</p>

{{! ❌ UNNECESSARY DETAIL }}
<p>Please wait while we retrieve your workspaces from the database...</p>
```

### Helper Text

**Provide context and examples:**
```handlebars
<F.HelperText>
  Your API token has full access to your organization. Store it securely.
</F.HelperText>

<F.HelperText>
  Tags help organize workspaces. Example: prod, staging, dev
</F.HelperText>
```

## Voice & Tone Examples

### Onboarding
```handlebars
<Hds::Alert @color="highlight" as |A|>
  <A.Title>Welcome to Terraform Cloud</A.Title>
  <A.Description>
    Let's create your first workspace. This will take about 2 minutes.
  </A.Description>
</Hds::Alert>
```

### Error States
```handlebars
<Hds::Alert @color="critical" as |A|>
  <A.Title>Connection failed</A.Title>
  <A.Description>
    We couldn't connect to your VCS provider. Check your credentials and try again.
  </A.Description>
  <A.Button @text="Retry" @color="secondary" />
</Hds::Alert>
```

### Success States
```handlebars
<Hds::Toast @color="success">
  Changes saved
</Hds::Toast>
```

### Warnings
```handlebars
<Hds::Alert @color="warning" as |A|>
  <A.Title>Workspace will be locked</A.Title>
  <A.Description>
    Another run is in progress. This run will queue until the current run completes.
  </A.Description>
</Hds::Alert>
```

### Informational
```handlebars
<Hds::Alert @color="neutral" as |A|>
  <A.Title>Private module registry</A.Title>
  <A.Description>
    Share Terraform modules within your organization. Modules are versioned and can be published from VCS.
  </A.Description>
</Hds::Alert>
```

## Quick Reference

**Voice Attributes:**
- Clear, brief, simple
- Authentic, helpful, confident
- Principle-aligned

**Tone Adjustments:**
- **Onboarding**: Encouraging
- **Errors**: Helpful, solution-oriented
- **Success**: Positive but restrained
- **Technical**: Direct, informative
- **Warnings**: Serious but not alarming

**Writing Style:**
- Sentence case (not title case)
- "You" and "we" (not "one" or corporate)
- Active voice (not passive)
- Present tense (not past/future)
- Verb + noun for actions
- American English spelling

**Content Patterns:**
- Short labels + detailed helper text
- Specific, actionable errors
- Clear consequences in confirmations
- Simple success messages
- Helpful empty states

## Resources

- **HDS Content Guidelines**: https://helios.hashicorp.design/content
- **Voice & Tone**: https://helios.hashicorp.design/content/voice-tone
- **Writing Style**: https://helios.hashicorp.design/content/writing-style
- **AP Style**: HashiCorp follows AP Style as baseline

For questions about content guidelines, ask in **#team-design-systems** on Slack.
