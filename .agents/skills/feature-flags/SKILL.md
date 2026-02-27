---
name: feature-flags
description: LaunchDarkly feature flags for safe feature rollouts, A/B testing, and progressive delivery across applications
---

# LaunchDarkly Feature Flags

This skill covers LaunchDarkly, a feature management platform for safely rolling out features, conducting experiments, and managing configuration across applications.

## When to Use This Skill

Use this skill when you need to:
- Implement feature flags in your application
- Roll out features gradually to subsets of users
- Conduct A/B testing and experiments
- Manage environment-specific configuration
- Decouple deployment from release
- Test features in production with limited exposure
- Implement kill switches for risky features
- Target features to specific users or organizations

## What is LaunchDarkly?

**LaunchDarkly is a feature management platform** that allows you to control feature releases independently from code deployments. It provides SDKs for multiple languages and frameworks.

### Core Purpose

LaunchDarkly enables:
- **Feature Flagging** - Toggle features on/off without deploying code
- **Targeted Rollouts** - Enable features for specific users/segments
- **Percentage Rollouts** - Gradually increase feature exposure
- **A/B Testing** - Compare feature variants
- **Configuration Management** - Manage app config across environments
- **Kill Switches** - Quickly disable problematic features

### Why LaunchDarkly?

**The Problem without Feature Flags:**
- Features tied to deployments (deploy = release)
- No way to test in production with limited exposure
- Risky big-bang releases
- Hard to roll back without redeploying
- Difficult to test features with real users
- Can't target features to specific users

**LaunchDarkly's Solution:**
- **Decouple deploy from release** - Deploy code, enable features later
- **Progressive delivery** - Gradual rollouts reduce risk
- **Targeting** - Enable features for specific users/groups
- **Instant rollback** - Disable flags without redeploying
- **Testing in production** - Safely test with real traffic

## When to Use Feature Flags

Use a feature flag if ANY of these are new or changing:
- User-facing features or UI changes
- API endpoints or backend behaviors
- Workflows or business logic
- Performance-impactful changes
- Risky or experimental features
- Database migrations or schema changes

**Best Practice:** Put ALL new code paths behind the flag, not just user-visible behavior.

## Key Concepts

### Flag Types

**Boolean Flags:**
- Simple on/off flags
- Most common type
- Example: Enable new dashboard

**Multivariate Flags:**
- Multiple variations (not just true/false)
- For A/B testing and experiments
- Example: Show variant A, B, or C of a feature

**Number/String Flags:**
- Return numeric or string values
- For configuration management
- Example: API rate limit threshold

### Contexts and Targeting

**User Context:**
- Target features to specific users
- Based on user ID, email, attributes

**Organization/Account Context:**
- Target features to groups/orgs
- Common in B2B applications

**Custom Contexts:**
- Device type, location, plan tier, etc.
- Any attribute you want to target on

### Environments

Typical LaunchDarkly environments:
- **Development** - Local development
- **Test/Staging** - Pre-production testing
- **Production** - Live users

Flags can have different values per environment.

## Installation & Setup

### 1. Create LaunchDarkly Account

Sign up at https://launchdarkly.com

### 2. Create Project and Environments

In LaunchDarkly UI:
1. Create project (e.g., "My Application")
2. Default environments created automatically
3. Get SDK keys for each environment

### 3. Install SDK

**Server-Side SDKs:**

Go:
```bash
go get github.com/launchdarkly/go-server-sdk/v7
```

Node.js:
```bash
npm install @launchdarkly/node-server-sdk
```

Ruby:
```bash
gem install launchdarkly-server-sdk
```

Python:
```bash
pip install launchdarkly-server-sdk
```

Java:
```bash
# Maven
<dependency>
  <groupId>com.launchdarkly</groupId>
  <artifactId>launchdarkly-java-server-sdk</artifactId>
</dependency>
```

**Client-Side SDKs:**

JavaScript:
```bash
npm install launchdarkly-js-client-sdk
```

React:
```bash
npm install launchdarkly-react-client-sdk
```

### 4. Initialize SDK

**Go:**
```go
package main

import (
    ld "github.com/launchdarkly/go-server-sdk/v7"
    "github.com/launchdarkly/go-server-sdk/v7/ldcontext"
)

func main() {
    client, err := ld.MakeClient("your-sdk-key", 5*time.Second)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()
}
```

**Node.js:**
```javascript
const LaunchDarkly = require('@launchdarkly/node-server-sdk');

const client = LaunchDarkly.init('your-sdk-key');

client.waitForInitialization().then(() => {
  console.log('LaunchDarkly initialized');
});
```

**Ruby:**
```ruby
require 'ldclient-rb'

client = LaunchDarkly::LDClient.new('your-sdk-key')
```

**JavaScript (Browser):**
```javascript
import * as LDClient from 'launchdarkly-js-client-sdk';

const client = LDClient.initialize('your-client-side-id', {
  key: 'user-key-123',
  email: 'user@example.com'
});

client.on('ready', () => {
  console.log('LaunchDarkly ready');
});
```

## Creating Feature Flags

### Via LaunchDarkly UI

1. Navigate to your project
2. Select environment
3. Click "Create flag"
4. Configure:
   - **Key**: `my-cool-feature` (immutable, use kebab-case)
   - **Name**: "My Cool Feature"
   - **Type**: Boolean
   - **Variations**: true/false
   - **Tags**: Optional organization tags

### Via Terraform

Manage flags as code using Terraform:

```hcl
terraform {
  required_providers {
    launchdarkly = {
      source = "launchdarkly/launchdarkly"
    }
  }
}

provider "launchdarkly" {
  access_token = var.launchdarkly_access_token
}

resource "launchdarkly_feature_flag" "my_feature" {
  project_key = "my-project"
  key         = "my-cool-feature"
  name        = "My Cool Feature"
  description = "Enable new dashboard design"

  variation_type = "boolean"
  variations {
    value       = true
    name        = "Enabled"
    description = "Feature is on"
  }
  variations {
    value       = false
    name        = "Disabled"
    description = "Feature is off"
  }

  defaults {
    on_variation  = 0  # true
    off_variation = 1  # false
  }

  tags = ["frontend", "dashboard"]
}
```

### Naming Conventions

**Best practices:**
- Use kebab-case: `my-cool-feature`
- Be descriptive: `enable-new-checkout-flow`
- Include context: `api-v2-endpoints`
- Avoid abbreviations
- Flag keys are immutable (careful with typos!)

## Using Feature Flags in Code

### Go

**Basic usage:**
```go
import (
    ld "github.com/launchdarkly/go-server-sdk/v7"
    "github.com/launchdarkly/go-server-sdk/v7/ldcontext"
)

// Create user context
context := ldcontext.NewBuilder("user-123").
    Name("Alice").
    Email("alice@example.com").
    Build()

// Evaluate flag
showFeature, err := client.BoolVariation("my-cool-feature", context, false)
if err != nil {
    log.Printf("Error evaluating flag: %v", err)
}

if showFeature {
    // New code path
} else {
    // Old code path
}
```

**Organization context:**
```go
// Create org context
context := ldcontext.NewBuilder("org-456").
    Kind("organization").
    Name("Acme Corp").
    Set("tier", ldvalue.String("premium")).
    Build()

enabled, _ := client.BoolVariation("premium-features", context, false)
```

**Best practice - check before expensive operations:**
```go
// Good - expensive operation only if enabled
if showFeature, _ := client.BoolVariation("my-feature", context, false); showFeature {
    result := expensiveOperation()
}

// Bad - expensive operation runs for everyone
result := expensiveOperation()
if showFeature, _ := client.BoolVariation("my-feature", context, false); showFeature {
    // use result
}
```

### Node.js

```javascript
const context = {
  kind: 'user',
  key: 'user-123',
  name: 'Alice',
  email: 'alice@example.com'
};

const showFeature = await client.variation('my-cool-feature', context, false);

if (showFeature) {
  // New code path
}
```

### Ruby

```ruby
context = {
  key: 'user-123',
  name: 'Alice',
  email: 'alice@example.com'
}

show_feature = client.variation('my-cool-feature', context, false)

if show_feature
  # New code path
end
```

### JavaScript (React)

```javascript
import { useFlags } from 'launchdarkly-react-client-sdk';

function MyComponent() {
  const { myCoolFeature } = useFlags();

  return (
    <div>
      {myCoolFeature && (
        <NewFeature />
      )}
    </div>
  );
}
```

### Python

```python
from ldclient import Context

context = Context.builder('user-123').name('Alice').build()
show_feature = ldclient.get().variation('my-cool-feature', context, False)

if show_feature:
    # New code path
    pass
```

## Testing with Feature Flags

### Go Tests

```go
import (
    "testing"
    "github.com/launchdarkly/go-server-sdk/v7/testhelpers/ldtestdata"
)

func TestFeature(t *testing.T) {
    // Create test data source
    testData := ldtestdata.DataSource()
    testData.Update(testData.Flag("my-feature").
        VariationForAll(true))

    // Create test client
    client, _ := ld.MakeCustomClient("sdk-key",
        ld.Config{DataSource: testData}, 5*time.Second)
    defer client.Close()

    // Test with flag enabled
    context := ldcontext.New("test-user")
    result, _ := client.BoolVariation("my-feature", context, false)

    if !result {
        t.Error("Expected feature to be enabled")
    }
}
```

### Node.js Tests

```javascript
const LaunchDarkly = require('@launchdarkly/node-server-sdk');
const { TestData } = require('@launchdarkly/node-server-sdk/integrations');

describe('Feature Tests', () => {
  let client;
  let testData;

  beforeEach(() => {
    testData = TestData();
    client = LaunchDarkly.init('sdk-key', {
      updateProcessor: testData.getFactory()
    });
  });

  it('should enable feature', async () => {
    testData.update(testData.flag('my-feature').on(true));

    const context = { key: 'test-user' };
    const result = await client.variation('my-feature', context, false);

    expect(result).toBe(true);
  });
});
```

### Ruby Tests (RSpec)

```ruby
require 'ldclient-rb'

RSpec.describe 'Feature' do
  let(:client) { LaunchDarkly::LDClient.new('sdk-key') }

  before do
    # Stub flag evaluation
    allow(client).to receive(:variation)
      .with('my-feature', anything, anything)
      .and_return(true)
  end

  it 'enables feature' do
    context = { key: 'test-user' }
    result = client.variation('my-feature', context, false)

    expect(result).to be true
  end
end
```

### Best Practices for Testing

**Default flags to false in tests:**
- Ensures tests are explicit about flag state
- Prevents flaky tests

**Use test helpers/mocking:**
- Don't hit real LaunchDarkly in unit tests
- Mock flag evaluations for speed and reliability

**Test both flag states:**
```go
func TestFeature(t *testing.T) {
    t.Run("with feature enabled", func(t *testing.T) {
        // test new behavior
    })

    t.Run("with feature disabled", func(t *testing.T) {
        // test old behavior
    })
}
```

## Testing Locally

### Environment Variables

**Set SDK key for local development:**
```bash
export LAUNCHDARKLY_SDK_KEY="sdk-dev-xxxxx"
```

**Disable LaunchDarkly in tests:**
```bash
export LAUNCHDARKLY_OFFLINE=true
```

### Local Flag Overrides

**Using environment-specific SDK keys:**
- Development environment in LaunchDarkly
- Separate from production
- Can set different default values

**File-based flags (for testing):**

Some SDKs support file-based flag data for offline testing:

```json
{
  "flags": {
    "my-feature": {
      "on": true,
      "fallthrough": {
        "variation": 0
      },
      "variations": [true, false]
    }
  }
}
```

### Browser Console (Client-Side)

For JavaScript SDK, flags are often exposed:

```javascript
// View all flags (if exposed)
window.__LD_FLAGS__

// Some apps expose helper functions
enableFeature('my-feature')
disableFeature('my-feature')
```

## Targeting and Rollout Strategies

### Target Specific Users

In LaunchDarkly UI:
1. Go to flag settings
2. Add targeting rule
3. "If user key is one of: user-123, user-456"
4. Serve: true

### Segment-Based Targeting

**Create segment:**
1. LaunchDarkly → Segments → Create segment
2. Name: "Beta Users"
3. Add users or rules

**Target segment:**
1. Flag → Add rule
2. "If user is in segment: Beta Users"
3. Serve: true

### Percentage Rollouts

**Gradual rollout:**
1. Flag → Add rule or set default rule
2. Enable percentage rollout
3. Set: 10% true, 90% false
4. Increase percentage over time

**By user attribute:**
```
If tier is "premium":
  - Rollout: 50% true, 50% false
```

### Multi-Environment Strategy

**Development:**
- Flags default to true (test new features)
- Quick iteration

**Staging:**
- Mirrors production flag states
- Test production config

**Production:**
- Conservative rollouts
- Start with internal users/segments
- Gradually increase percentage
- Monitor metrics

## Common Workflows

### Workflow 1: Rolling Out a New Feature

**Scenario:** Safely roll out new dashboard to users

1. **Create flag:**
   - Key: `new-dashboard-ui`
   - Default: false in all environments

2. **Deploy code with flag:**
   ```go
   if showNewUI, _ := client.BoolVariation("new-dashboard-ui", context, false); showNewUI {
       renderNewDashboard()
   } else {
       renderOldDashboard()
   }
   ```

3. **Test internally:**
   - Target flag to internal users/QA team
   - Verify functionality

4. **Gradual rollout:**
   - Week 1: 5% of users
   - Week 2: 25% of users
   - Week 3: 50% of users
   - Week 4: 100% of users

5. **Monitor metrics:**
   - Error rates
   - Performance
   - User feedback

6. **Complete rollout:**
   - Set default to true
   - Update fallback value in code
   - Plan flag removal

### Workflow 2: Kill Switch for Risky Feature

**Scenario:** Deploy feature with ability to disable quickly

1. **Wrap risky code:**
   ```go
   if enabled, _ := client.BoolVariation("new-payment-processor", context, false); enabled {
       processPaymentV2()
   } else {
       processPaymentV1()  // fallback
   }
   ```

2. **Deploy with flag off:**
   - Code deployed but not active
   - No risk to users

3. **Enable for testing:**
   - Turn on for test accounts
   - Verify functionality

4. **Enable in production:**
   - Turn on flag
   - Monitor closely

5. **If issues arise:**
   - Toggle flag off instantly
   - No code deployment needed
   - Investigate and fix

6. **Re-enable when fixed:**
   - Toggle back on
   - Continue monitoring

### Workflow 3: A/B Testing

**Scenario:** Test two variations of a feature

1. **Create multivariate flag:**
   - Key: `checkout-flow-variant`
   - Variations: "control", "variant-a", "variant-b"

2. **Implement variations:**
   ```go
   variant, _ := client.StringVariation("checkout-flow-variant", context, "control")

   switch variant {
   case "variant-a":
       showCheckoutA()
   case "variant-b":
       showCheckoutB()
   default:
       showCheckoutControl()
   }
   ```

3. **Configure rollout:**
   - 33% each variation
   - Track conversion metrics

4. **Analyze results:**
   - Compare conversion rates
   - Statistical significance

5. **Roll out winner:**
   - Set winning variant to 100%
   - Remove losing variants from code

## Best Practices

### Flag Lifecycle Management

**Creation:**
- Name clearly and descriptively
- Document purpose in LaunchDarkly
- Tag for organization
- Set appropriate fallback values

**During Rollout:**
- Start with small percentage
- Monitor metrics closely
- Communicate with team
- Document any issues

**After 100% Rollout:**
- Update fallback value to true
- Keep flag active for 1-2 release cycles
- Plan removal in backlog

**Removal:**
- Remove flag checks from code
- Delete flag from LaunchDarkly
- Update documentation

### Code Organization

**Centralize flag keys:**
```go
// flags/flags.go
package flags

const (
    NewDashboard = "new-dashboard-ui"
    PaymentV2    = "payment-processor-v2"
    BetaFeatures = "beta-features"
)
```

**Wrap SDK calls:**
```go
// features/features.go
package features

func IsNewDashboardEnabled(ctx context.Context, user User) bool {
    context := buildLDContext(user)
    enabled, _ := ldClient.BoolVariation(flags.NewDashboard, context, false)
    return enabled
}
```

### Performance

**Cache flag evaluations:**
- Most SDKs cache automatically
- Minimize network calls

**Use fallback values wisely:**
- Consider what happens if LaunchDarkly is down
- Critical features: fallback to true (enabled)
- Risky features: fallback to false (disabled)

**Batch evaluations:**
```go
// Evaluate multiple flags at once
flags := client.AllFlagsState(context)
```

### Security

**Protect SDK keys:**
- Never commit to version control
- Use environment variables
- Rotate keys if compromised

**Server-side vs client-side:**
- Use server-side SDK for sensitive flags
- Client-side SDK exposes flag values to browser
- Don't use client-side SDK for authorization

**Least privilege:**
- Use environment-specific keys
- Limit access to production flags

## Troubleshooting

### Issue 1: Flag Not Updating

**Symptoms:**
- Flag value doesn't change
- Old value still returned

**Causes:**
- SDK not connected to LaunchDarkly
- Caching issue
- Wrong environment key

**Solutions:**
```go
// Check SDK initialization
if !client.IsInitialized() {
    log.Error("LaunchDarkly not initialized")
}

// Verify SDK key is correct
// Check environment in LaunchDarkly UI

// Force refresh (if supported)
client.Flush()
```

### Issue 2: Different Values in Different Environments

**Symptoms:**
- Flag works in dev, not in prod
- Inconsistent behavior

**Causes:**
- Using wrong SDK key
- Different targeting rules per environment
- Fallback value issue

**Solutions:**
```bash
# Verify SDK key for environment
echo $LAUNCHDARKLY_SDK_KEY

# Check targeting rules in UI for each environment
# Verify fallback value in code
```

### Issue 3: Performance Impact

**Symptoms:**
- Slow flag evaluations
- High latency

**Causes:**
- Too many flag checks
- Network issues
- SDK not initialized properly

**Solutions:**
```go
// Initialize SDK once, reuse
var ldClient *ld.LDClient

func init() {
    client, err := ld.MakeClient(sdkKey, 5*time.Second)
    if err != nil {
        log.Fatal(err)
    }
    ldClient = client
}

// Cache results if needed
type FeatureCache struct {
    mu sync.RWMutex
    flags map[string]bool
}

// Batch evaluations
allFlags := client.AllFlagsState(context)
```

## HashiCorp-Specific Tips

### Common Patterns

**User vs Organization context:**

Many HashiCorp products are multi-tenant (organizations):

```go
// User context
userContext := ldcontext.NewBuilder(user.ID).
    Email(user.Email).
    Build()

// Organization context
orgContext := ldcontext.NewBuilder(org.ID).
    Kind("organization").
    Name(org.Name).
    Set("tier", ldvalue.String(org.Tier)).
    Build()

// Check for org first, fall back to user
if org != nil {
    enabled, _ = client.BoolVariation(flagKey, orgContext, false)
} else {
    enabled, _ = client.BoolVariation(flagKey, userContext, false)
}
```

**Terraform-managed flags:**

HashiCorp often manages LaunchDarkly flags via Terraform:

```hcl
# terraform/launchdarkly/flags.tf
module "my_feature_flag" {
  source = "./modules/basic_flag"

  project_key = var.project_key
  flag_key    = "my-cool-feature"
  name        = "My Cool Feature"
  tags        = ["backend", "api"]
}
```

**Internal testing segments:**

Create segments for HashiCorp employees/internal orgs:

```
Segment: "Internal Orgs"
Rules:
  - Organization email ends with "@hashicorp.com"
  - OR Organization ID in [list of test org IDs]
```

### Integration with HashiCorp Products

**With Vault (dynamic secrets):**
```go
// Don't use feature flags for authorization!
// Flags are for features, Vault is for secrets
```

**With Terraform:**
```hcl
# Manage LaunchDarkly resources
resource "launchdarkly_feature_flag" "example" {
  # ...
}
```

**With Consul (service discovery):**
```go
// Use flags to control service routing
if useNewService, _ := client.BoolVariation("use-service-v2", ctx, false); useNewService {
    endpoint = consul.GetService("my-service-v2")
} else {
    endpoint = consul.GetService("my-service-v1")
}
```

## Additional Resources

- **LaunchDarkly Documentation**: https://docs.launchdarkly.com/
- **SDK Documentation**: https://docs.launchdarkly.com/sdk
- **Best Practices Guide**: https://docs.launchdarkly.com/guides/best-practices
- **Feature Flag Patterns**: https://martinfowler.com/articles/feature-toggles.html
- **Go SDK**: https://pkg.go.dev/github.com/launchdarkly/go-server-sdk/v7
- **Terraform Provider**: https://registry.terraform.io/providers/launchdarkly/launchdarkly

## Summary

**Quick Start:**
```bash
# 1. Install SDK (Go example)
go get github.com/launchdarkly/go-server-sdk/v7

# 2. Set SDK key
export LAUNCHDARKLY_SDK_KEY="sdk-xxxxx"

# 3. Initialize in code
client, _ := ld.MakeClient(os.Getenv("LAUNCHDARKLY_SDK_KEY"), 5*time.Second)
defer client.Close()

# 4. Evaluate flag
context := ldcontext.New("user-123")
enabled, _ := client.BoolVariation("my-feature", context, false)
```

**Common Flag Patterns:**
```go
// Simple boolean check
if enabled, _ := client.BoolVariation("feature", ctx, false); enabled {
    // new code
}

// Performance-conscious check
enabled, _ := client.BoolVariation("expensive-feature", ctx, false)
if enabled {
    result := expensiveOperation()  // only if enabled
}

// Multivariate flag
variant, _ := client.StringVariation("ui-variant", ctx, "control")
switch variant {
case "variant-a":
    // ...
case "variant-b":
    // ...
}
```

**Rollout Strategy:**
1. **Create flag** - Start with default false
2. **Deploy code** - Behind flag, not active
3. **Internal testing** - Enable for team/test accounts
4. **Gradual rollout** - 5% → 25% → 50% → 100%
5. **Monitor** - Watch metrics at each stage
6. **Full rollout** - Set default to true
7. **Clean up** - Remove flag after stable

**Best Practices:**
- Use descriptive, immutable flag keys
- Put ALL new code behind flags
- Test both flag states
- Start rollouts small (5-10%)
- Monitor metrics closely
- Set appropriate fallback values
- Remove flags after full rollout
- Never use flags for authorization
- Document flag purpose and lifecycle

**Remember:**
- Flags are for features, not secrets
- Server-side SDK for sensitive logic
- Client-side SDK exposes values
- Cache flag evaluations when possible
- Plan flag removal from day one
- Communicate rollout schedule with team
