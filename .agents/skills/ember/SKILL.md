---
name: ember
description: Ember.js frontend framework for building ambitious web applications with convention over configuration
---

# Ember.js

This skill covers Ember.js, a productive frontend framework for building ambitious web applications.

## When to Use This Skill

Use this skill when you need to:
- Build single-page applications (SPAs) with structured architecture
- Work with Ember.js projects following convention over configuration
- Understand Ember's component system and routing
- Debug Ember applications using Ember Inspector
- Learn Ember best practices and common patterns
- Integrate with backend APIs using Ember Data
- Use Ember Octane features (modern Ember)

## What is Ember.js?

**Ember.js is a productive, battle-tested JavaScript framework** for building modern web applications. It provides everything you need to build rich UIs that work on any device.

### Core Purpose

Ember follows a **convention over configuration** philosophy, meaning:
- Sensible defaults reduce decision fatigue
- Consistent project structure across Ember apps
- Strong opinions enable faster development
- Built-in solutions for common problems

### Why Ember?

**The Problem with Building from Scratch:**
- Every project reinvents common patterns
- No standard way to structure applications
- Integration challenges between libraries
- Difficult to onboard new developers
- Hard to maintain consistency across teams

**Ember's Solution:**
- **Convention over Configuration** - Standard patterns for routing, data, components
- **Integrated Tooling** - Ember CLI provides complete development environment
- **Stability Without Stagnation** - Backwards compatibility with modern features
- **Productive Defaults** - Everything you need built-in
- **Strong Community** - Shared patterns and addons

## Key Features

| Feature | Description |
| --- | --- |
| **Ember CLI** | Command-line interface for scaffolding, building, and testing |
| **Routing** | Powerful URL-based routing with nested routes |
| **Components** | Glimmer components for building reusable UI |
| **Ember Data** | Data persistence library for managing models |
| **Octane Edition** | Modern Ember with native classes, tracked properties, modifiers |
| **Templates** | Handlebars-based templating with helpful helpers |
| **Testing** | Built-in testing framework (QUnit or Mocha) |
| **FastBoot** | Server-side rendering for SEO and performance |

## Installation & Setup

### Prerequisites

**Install Node.js:**

Using asdf (recommended for version management):
```bash
# Install asdf
brew install asdf coreutils curl

# Add to shell (zsh)
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
source ~/.zshrc

# Install Node.js
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest
```

Using Homebrew:
```bash
brew install node
```

Verify:
```bash
node -v
npm -v
```

### Install Package Manager

**Using pnpm (recommended for monorepos):**

Option 1 - Using Corepack (comes with Node.js):
```bash
corepack enable
corepack prepare pnpm@latest --activate
```

Option 2 - Using asdf:
```bash
asdf plugin add pnpm https://github.com/jonathanmorley/asdf-pnpm.git
asdf install pnpm latest
asdf global pnpm latest
```

Option 3 - Using npm:
```bash
npm install -g pnpm
```

**Using npm (default):**
Already installed with Node.js

**Using yarn:**
```bash
npm install -g yarn
```

### Install Ember CLI

**Global Installation:**
```bash
npm install -g ember-cli
# or
pnpm install -g ember-cli
```

**Verify Installation:**
```bash
ember --version
```

### Create a New Ember App

```bash
ember new my-app
cd my-app
ember serve
```

Visit `http://localhost:4200` to see your app.

### Install Dependencies in Existing Project

**For existing Ember projects:**

```bash
cd my-app

# Install dependencies
npm install
# or with pnpm
pnpm install

# If using pnpm and it's configured in the project
pnpm install
```

**If using git hooks (Husky):**
```bash
# Install at root level first (sets up Husky)
pnpm install

# Then install app dependencies
cd frontend/my-app
pnpm install
```

### Project Structure

```
my-app/
├── app/
│   ├── components/      # UI components
│   ├── controllers/     # Route controllers
│   ├── models/          # Data models
│   ├── routes/          # Route handlers
│   ├── templates/       # Handlebars templates
│   ├── styles/          # CSS/SCSS
│   ├── adapters/        # Ember Data adapters
│   ├── serializers/     # Ember Data serializers
│   └── app.js           # Application entry point
├── public/              # Static assets
├── tests/               # Test files
├── config/              # Configuration
└── ember-cli-build.js   # Build configuration
```

## Common Commands

### Development

**Start development server:**
```bash
ember serve
# or
ember s

# With proxy to backend API
ember serve --proxy=http://localhost:3000

# On different port
ember serve --port=4300
```

**Development Server Options:**

With local backend:
```bash
# Default - connects to backend at localhost:3000 (or configured proxy)
npm start
# or
pnpm start
```

With staging/production backend:
```bash
# Use environment-specific configuration
npm start -- --environment=staging

# Or with custom npm script
npm run start:staging
```

With mocked backend (Mirage):
```bash
# No backend required, uses mocked data
npm run start:mirage
# or
pnpm start-mirage
```

**Build for production:**
```bash
ember build --environment=production
# or
ember build -prod

# With pnpm
pnpm build
```

**Run tests:**
```bash
# Run all tests
ember test

# Watch mode (interactive test server)
ember test --server
# or
npm run test:server
# or
pnpm test-server

# Then visit http://localhost:7357/tests/index.html

# Run specific test
ember test --filter="component-name"

# Run in browser (recommended for development)
npm run test:server
# Visit test URL and use browser DevTools
```

**Generate components/routes/models:**
```bash
ember generate component my-component
ember generate route my-route
ember generate model user
ember generate service my-service
ember generate helper format-date
ember generate adapter application
ember generate serializer user
```

### Code Quality

**Linting:**
```bash
# Run all linters
npm run lint
# or
pnpm lint

# Individual linters
npm run lint:js        # JavaScript/TypeScript
npm run lint:hbs       # Templates (Handlebars)
npm run lint:css       # Styles (CSS/SCSS)

# Auto-fix issues
npm run lint:fix
# or
pnpm lint:fix

# Individual fixers
npm run lint:js --fix
npm run lint:hbs --fix
npm run lint:css --fix
```

**Type checking (if using TypeScript):**
```bash
# Check types
npm run lint:types
# or
pnpm glint
```

**Format code:**
```bash
npm run format         # Check formatting
npm run format:fix     # Fix formatting
# or with prettier directly
npx prettier --write "app/**/*.{js,ts,hbs}"
```

## Core Concepts

### Components

**Modern Glimmer Components:**

```javascript
// app/components/user-card.js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class UserCardComponent extends Component {
  @tracked isExpanded = false;

  @action
  toggleExpanded() {
    this.isExpanded = !this.isExpanded;
  }
}
```

```handlebars
{{! app/components/user-card.hbs }}
<div class="user-card">
  <h3>{{@user.name}}</h3>
  <button {{on "click" this.toggleExpanded}}>
    {{if this.isExpanded "Collapse" "Expand"}}
  </button>

  {{#if this.isExpanded}}
    <p>{{@user.bio}}</p>
  {{/if}}
</div>
```

**Usage:**
```handlebars
<UserCard @user={{this.currentUser}} />
```

### Routing

**Define routes in router.js:**
```javascript
// app/router.js
Router.map(function() {
  this.route('posts', function() {
    this.route('post', { path: '/:post_id' });
  });
  this.route('about');
});
```

**Route handler:**
```javascript
// app/routes/posts.js
import Route from '@ember/routing/route';

export default class PostsRoute extends Route {
  model() {
    return this.store.findAll('post');
  }
}
```

**Template:**
```handlebars
{{! app/templates/posts.hbs }}
<h1>Posts</h1>
<ul>
  {{#each this.model as |post|}}
    <li>
      <LinkTo @route="posts.post" @model={{post}}>
        {{post.title}}
      </LinkTo>
    </li>
  {{/each}}
</ul>

{{outlet}}
```

### Ember Data Models

**Define a model:**
```javascript
// app/models/post.js
import Model, { attr, belongsTo, hasMany } from '@ember-data/model';

export default class PostModel extends Model {
  @attr('string') title;
  @attr('string') body;
  @attr('date') publishedAt;

  @belongsTo('user') author;
  @hasMany('comment') comments;
}
```

**Fetch data:**
```javascript
// In a route
model() {
  return this.store.findAll('post');
}

// Find by ID
model(params) {
  return this.store.findRecord('post', params.post_id);
}

// Query
model() {
  return this.store.query('post', { published: true });
}
```

### Tracked Properties

**Reactive state with @tracked:**
```javascript
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class CounterComponent extends Component {
  @tracked count = 0;

  @action
  increment() {
    this.count++;
  }
}
```

### Actions

**Event handlers:**
```javascript
export default class FormComponent extends Component {
  @tracked email = '';

  @action
  updateEmail(event) {
    this.email = event.target.value;
  }

  @action
  async submitForm(event) {
    event.preventDefault();
    await this.args.onSubmit(this.email);
  }
}
```

```handlebars
<form {{on "submit" this.submitForm}}>
  <input
    type="email"
    value={{this.email}}
    {{on "input" this.updateEmail}}
  />
  <button type="submit">Submit</button>
</form>
```

## Common Workflows

### Workflow 1: Creating a New Feature

**Scenario:** Add a blog post listing page

1. **Generate route:**
   ```bash
   ember generate route posts
   ```

2. **Generate model:**
   ```bash
   ember generate model post
   ```

3. **Define model attributes:**
   ```javascript
   // app/models/post.js
   import Model, { attr } from '@ember-data/model';

   export default class PostModel extends Model {
     @attr('string') title;
     @attr('string') content;
     @attr('date') createdAt;
   }
   ```

4. **Fetch data in route:**
   ```javascript
   // app/routes/posts.js
   import Route from '@ember/routing/route';

   export default class PostsRoute extends Route {
     model() {
       return this.store.findAll('post');
     }
   }
   ```

5. **Create template:**
   ```handlebars
   {{! app/templates/posts.hbs }}
   <h1>Blog Posts</h1>
   {{#each this.model as |post|}}
     <article>
       <h2>{{post.title}}</h2>
       <p>{{post.content}}</p>
       <time>{{post.createdAt}}</time>
     </article>
   {{/each}}
   ```

### Workflow 2: Creating Reusable Components

**Scenario:** Build a reusable button component

1. **Generate component:**
   ```bash
   ember generate component ui/button
   ```

2. **Define component:**
   ```javascript
   // app/components/ui/button.js
   import Component from '@glimmer/component';
   import { action } from '@ember/object';

   export default class UiButtonComponent extends Component {
     get buttonClass() {
       return `btn btn-${this.args.variant || 'primary'}`;
     }

     @action
     handleClick(event) {
       if (this.args.onClick) {
         this.args.onClick(event);
       }
     }
   }
   ```

3. **Create template:**
   ```handlebars
   {{! app/components/ui/button.hbs }}
   <button
     class={{this.buttonClass}}
     type={{@type}}
     disabled={{@disabled}}
     {{on "click" this.handleClick}}
   >
     {{yield}}
   </button>
   ```

4. **Use component:**
   ```handlebars
   <Ui::Button @variant="primary" @onClick={{this.save}}>
     Save
   </Ui::Button>
   ```

### Workflow 3: Working with Forms

**Scenario:** Create a user registration form

1. **Generate component:**
   ```bash
   ember generate component user-registration-form
   ```

2. **Define component with validation:**
   ```javascript
   // app/components/user-registration-form.js
   import Component from '@glimmer/component';
   import { tracked } from '@glimmer/tracking';
   import { action } from '@ember/object';

   export default class UserRegistrationFormComponent extends Component {
     @tracked email = '';
     @tracked password = '';
     @tracked errors = {};

     @action
     updateEmail(event) {
       this.email = event.target.value;
       if (this.errors.email) {
         delete this.errors.email;
       }
     }

     @action
     updatePassword(event) {
       this.password = event.target.value;
       if (this.errors.password) {
         delete this.errors.password;
       }
     }

     @action
     async submit(event) {
       event.preventDefault();

       // Validate
       const errors = {};
       if (!this.email) errors.email = 'Email is required';
       if (!this.password) errors.password = 'Password is required';

       if (Object.keys(errors).length > 0) {
         this.errors = errors;
         return;
       }

       // Submit
       await this.args.onSubmit({
         email: this.email,
         password: this.password,
       });
     }
   }
   ```

3. **Create template:**
   ```handlebars
   {{! app/components/user-registration-form.hbs }}
   <form {{on "submit" this.submit}}>
     <div>
       <label>Email</label>
       <input
         type="email"
         value={{this.email}}
         {{on "input" this.updateEmail}}
       />
       {{#if this.errors.email}}
         <span class="error">{{this.errors.email}}</span>
       {{/if}}
     </div>

     <div>
       <label>Password</label>
       <input
         type="password"
         value={{this.password}}
         {{on "input" this.updatePassword}}
       />
       {{#if this.errors.password}}
         <span class="error">{{this.errors.password}}</span>
       {{/if}}
     </div>

     <button type="submit">Register</button>
   </form>
   ```

### Workflow 4: Testing Components

**Scenario:** Test a button component

1. **Create test file:**
   ```javascript
   // tests/integration/components/ui/button-test.js
   import { module, test } from 'qunit';
   import { setupRenderingTest } from 'ember-qunit';
   import { render, click } from '@ember/test-helpers';
   import { hbs } from 'ember-cli-htmlbars';

   module('Integration | Component | ui/button', function(hooks) {
     setupRenderingTest(hooks);

     test('it renders', async function(assert) {
       await render(hbs`<Ui::Button>Click me</Ui::Button>`);

       assert.dom('button').hasText('Click me');
     });

     test('it handles clicks', async function(assert) {
       let clicked = false;
       this.set('handleClick', () => clicked = true);

       await render(hbs`
         <Ui::Button @onClick={{this.handleClick}}>
           Click me
         </Ui::Button>
       `);

       await click('button');
       assert.ok(clicked, 'onClick was called');
     });

     test('it applies variant class', async function(assert) {
       await render(hbs`
         <Ui::Button @variant="danger">Delete</Ui::Button>
       `);

       assert.dom('button').hasClass('btn-danger');
     });
   });
   ```

## Troubleshooting

### Build Failures

**Dependencies Installation Fails:**
```bash
# Clear caches and lockfiles
rm -rf node_modules
rm package-lock.json  # or pnpm-lock.yaml or yarn.lock

# Reinstall
npm install
# or
pnpm install
```

**Version Mismatch Errors:**
```bash
# Check Node.js version (should match .nvmrc or .tool-versions)
node -v

# Check package manager version
npm -v    # or pnpm -v or yarn -v

# If using pnpm and version is wrong
corepack enable
corepack prepare pnpm@latest --activate

# Or with asdf
asdf reshim nodejs
asdf reshim pnpm
```

**TypeScript Compilation Errors:**
```bash
# Check for type errors
npm run lint:types

# Regenerate type definitions (if using Glint)
npm run glint

# Clear TypeScript cache
rm -rf tmp dist
npm run build
```

**Webpack/Build Tool Errors:**
```bash
# Clear build cache
rm -rf tmp dist

# Clear node_modules and reinstall
rm -rf node_modules
npm install

# Rebuild from scratch
npm run build
```

**Dependency Conflicts:**
```bash
# Check for peer dependency warnings
npm install

# Update Ember CLI and core packages
npx ember-cli-update

# Check for outdated packages
npm outdated
```

### Runtime Errors

**API Connection Issues:**

Check development server configuration:
```bash
# Verify backend is running
curl http://localhost:3000/api/health

# Check CORS configuration in backend
# Ensure backend allows localhost:4200

# Start with correct proxy
ember serve --proxy=http://localhost:3000
```

**CORS Errors:**
- Backend isn't running or wrong URL
- Backend doesn't allow localhost:4200 origin
- Check backend CORS configuration
- Use proxy in ember-cli-build.js or --proxy flag

**Ember Data Errors:**
- Check browser Network tab for API responses
- Verify JSON:API format (if using JSONAPIAdapter)
- Check adapter configuration in app/adapters
- Verify serializer transformations in app/serializers

**Authentication Issues:**
- Clear browser cookies for localhost:4200
- Check session storage/local storage
- Verify authentication token is being sent
- Check backend session validity

**Component Not Rendering:**
1. Check browser console for errors
2. Verify component is properly imported
3. Check template syntax (angle brackets vs curly braces)
4. Verify component arguments with @
5. Install and use Ember Inspector

### Test Failures

**Test Server Won't Start:**
```bash
# Kill existing test server process
lsof -ti:7357 | xargs kill -9
# Or find and kill manually
ps aux | grep ember
kill -9 <PID>

# Start fresh
npm run test:server
```

**Memory Issues with Headless Tests:**
```bash
# Known issue running all tests headlessly locally
# Use interactive test server instead
npm run test:server

# Then visit http://localhost:7357/tests

# Or run specific test modules
ember test --filter="acceptance"
```

**Mirage/Mock Issues in Tests:**
- Check Mirage routes are defined in mirage/config.js
- Look for console errors about missing routes
- Verify Mirage is enabled for test environment
- Check serializer configuration for test data

**Flaky Tests:**
- Check for race conditions (missing await)
- Look for async operations without proper waiting
- Verify test isolation (no leaked state between tests)
- Check for proper test cleanup in hooks
- Use await settled() after async operations

**Test Assertions Failing:**
```bash
# Run single test to debug
ember test --filter="specific test name"

# Use test server for better debugging
npm run test:server
# Use browser DevTools to debug

# Add debugger or this.pauseTest()
await this.pauseTest();  // In test
```

### Linting Errors

**ESLint Errors:**
```bash
# Check what's failing
npm run lint:js

# Auto-fix what's possible
npm run lint:js --fix

# Check specific file
npx eslint app/components/my-component.js

# Disable rule for specific line (use sparingly)
// eslint-disable-next-line rule-name
```

**Template Lint Errors:**
```bash
# Check template errors
npm run lint:hbs

# Auto-fix
npm run lint:hbs --fix

# Common issues:
# - Missing alt text on images
# - Incorrect attribute usage
# - Bare strings (should be in translation files)
```

**Stylelint Errors:**
```bash
# Check style errors
npm run lint:css

# Auto-fix
npm run lint:css --fix

# Common issues:
# - Property order
# - Color format
# - Unused selectors
```

**Prettier Formatting:**
```bash
# Check formatting
npm run format

# Fix formatting
npm run format:fix

# Format specific file
npx prettier --write app/components/my-component.js
```

### Performance Issues

**Slow Development Server:**
```bash
# Check node_modules size
du -sh node_modules

# Clear tmp directory
rm -rf tmp

# Restart dev server
# Ctrl+C then
npm start

# Check for large dependencies
npm ls --depth=0
```

**Slow Build Times:**
```bash
# Analyze build
BROCCOLI_VIZ=1 ember build

# Check for unnecessary includes
# Review ember-cli-build.js

# Consider code splitting for large apps
```

**Slow Tests:**
```bash
# Run subset of tests
ember test --filter="unit"

# Check for N+1 API calls
# Verify Mirage is being used (not real API)

# Profile tests in browser
npm run test:server
# Use browser Performance tab
```

**HMR (Hot Module Replacement) Not Working:**
```bash
# Restart dev server
# Ctrl+C
npm start

# Hard refresh browser
# Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)

# Clear browser cache
# In DevTools: Network tab → Disable cache

# Check console for HMR errors
```

### TypeScript/Glint Issues

**Type Errors:**
```bash
# Check types
npm run lint:types

# Regenerate types
npm run glint

# Common issues:
# - Missing type definitions for packages
# - Incorrect component signatures
# - Missing @tracked on properties
```

**Missing Type Definitions:**
```bash
# Check if package has types
npm info @types/package-name

# Install type definitions
npm install --save-dev @types/package-name

# Or add to types/ directory for custom types
```

**Component Signature Issues:**
```javascript
// Define proper component signature
import Component from '@glimmer/component';

interface MyComponentSignature {
  Args: {
    name: string;
    age?: number;
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class MyComponent extends Component<MyComponentSignature> {
  // ...
}
```

## Debugging

### Ember Inspector

**Install browser extension:**
- [Chrome](https://chrome.google.com/webstore/detail/ember-inspector/bmdblncegkenkacieihfhpjfppoconhi)
- [Firefox](https://addons.mozilla.org/en-US/firefox/addon/ember-inspector/)

**Features:**
- **View Info** - Component tree and route hierarchy
- **Data** - Inspect Ember Data records and relationships
- **Routes** - View route hierarchy and current route info
- **Deprecations** - See deprecation warnings
- **Promises** - Monitor promise states
- **Container** - Inspect container registrations
- **Render Performance** - Profile component renders

**Common Ember Inspector Tasks:**
1. Find component in tree → Right-click → Send to Console
2. Inspect model data → Data tab → Click record
3. Check current route → Routes tab → Highlight current route
4. Find slow renders → Render Performance tab → Record

### Browser DevTools

**Console Tab:**
- View errors, warnings, and log statements
- Access Ember application: `require('my-app/app').default`
- Access Ember Inspector selected component: `$E`

**Network Tab:**
- Monitor API calls and responses
- Check request/response headers
- Verify JSON:API format
- Debug CORS issues
- Filter by XHR to see only API calls

**Sources Tab:**
- Set breakpoints in code
- Step through execution
- Inspect variable values
- Use `debugger;` statement

**Performance Tab:**
- Profile application performance
- Find slow component renders
- Check for memory leaks
- Monitor FPS during interactions

**Application Tab:**
- View localStorage/sessionStorage
- Inspect cookies
- Check service worker status

### Common Debugging Techniques

**JavaScript Debugger:**
```javascript
import Component from '@glimmer/component';
import { action } from '@ember/object';

export default class MyComponent extends Component {
  @action
  handleClick() {
    debugger; // Pauses execution here
    console.log('Component args:', this.args);
    this.count++;
  }

  get computedValue() {
    debugger; // Debug computed properties
    return this.args.value * 2;
  }
}
```

**Template Debugging:**
```handlebars
{{! Log value to console }}
{{log "Current user:" this.user}}

{{! Log multiple values }}
{{log "Debug:" this.value this.other}}

{{! Pause execution in template }}
{{debugger}}

{{! Inspect element }}
<div {{log "Element rendered"}}>
  Content
</div>
```

**Conditional Debugging:**
```javascript
@action
handleSubmit() {
  if (this.args.debug) {
    debugger;
  }
  // ... rest of code
}
```

**Test Debugging:**
```javascript
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';

module('Component test', function(hooks) {
  setupRenderingTest(hooks);

  test('it works', async function(assert) {
    await render(hbs`<MyComponent />`);

    // Pause test to inspect in browser
    await this.pauseTest();

    // View rendered element
    console.log(this.element);
    console.log(this.element.querySelector('.my-class'));

    // Continue test manually in browser console:
    // resumeTest()
  });
});
```

**Finding Code:**
```bash
# Find template with specific text/class
git grep "some-class-name" app/templates
git grep "Welcome" app/templates

# Find component definition
git grep "class UserCard" app/components
git grep "export default class" app/components

# Find component usage
git grep "<UserCard" app
git grep "{{user-card" app

# Find route definition
git grep "this.route" app/router.js

# Find model definition
git grep "export default class.*Model" app/models
```

**Debugging Ember Data:**
```javascript
// In browser console or component

// Get store
let store = this.owner.lookup('service:store');

// Peek at record (without fetching)
let user = store.peekRecord('user', 1);

// See all cached records
let users = store.peekAll('user');

// Debug adapter requests
store.adapterFor('user').findAll()
  .then(data => console.log('Raw response:', data));

// Check if record is dirty
let post = store.peekRecord('post', 1);
console.log('Is dirty:', post.hasDirtyAttributes);
console.log('Dirty attrs:', post.changedAttributes());
```

**Debugging Services:**
```javascript
// Access service in console (requires Ember Inspector)
// 1. Select component with service in Ember Inspector
// 2. In console:
$E.router  // If service is injected as 'router'
$E.session
$E.currentUser

// Or via owner lookup
let owner = window.MyApp.__container__.lookup('-application-instance:main');
let router = owner.lookup('service:router');
console.log('Current route:', router.currentRouteName);
```

**Debugging Actions:**
```javascript
export default class MyComponent extends Component {
  @action
  handleClick(event) {
    console.log('Action called with:', event);
    console.log('Component args:', this.args);
    console.log('Component state:', {
      prop1: this.prop1,
      prop2: this.prop2
    });

    // Your action logic
  }
}
```

**Common Debug Patterns:**
```javascript
// Log all tracked property changes
import { tracked } from '@glimmer/tracking';

export default class MyComponent extends Component {
  _count = 0;

  @tracked
  get count() {
    return this._count;
  }

  set count(value) {
    console.log(`Count changing from ${this._count} to ${value}`);
    this._count = value;
  }
}
```

**Debugging Route Transitions:**
```javascript
// app/routes/application.js
import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service router;

  constructor() {
    super(...arguments);

    this.router.on('routeWillChange', (transition) => {
      console.log('Transitioning from:', transition.from?.name);
      console.log('Transitioning to:', transition.to.name);
      console.log('Transition params:', transition.to.params);
    });

    this.router.on('routeDidChange', (transition) => {
      console.log('Route changed to:', transition.to.name);
    });
  }
}
```

## Notable Addons

### Essential Addons

**Ember Concurrency:**
Manage async code with tasks
```bash
ember install ember-concurrency
```

**Ember CLI Mirage:**
API mocking for development and testing
```bash
ember install ember-cli-mirage
```

**Ember Power Select:**
Powerful select component
```bash
ember install ember-power-select
```

**Ember CLI Page Object:**
Page objects for acceptance tests
```bash
ember install ember-cli-page-object
```

**Ember Composable Helpers:**
Additional template helpers
```bash
ember install ember-composable-helpers
```

## Best Practices

### Component Design
- **Single Responsibility** - Each component should do one thing
- **Composition over Inheritance** - Build complex UIs from simple components
- **Arguments with @** - Use `@args` for data passed to components
- **Tracked Properties** - Use `@tracked` for reactive state
- **Actions for Events** - Use `@action` for event handlers

### Data Management
- **Use Ember Data** for structured API integration
- **Adapters** for API communication patterns
- **Serializers** for data transformation
- **Models** for domain objects with relationships

### Routing
- **Nested Routes** for hierarchical URLs
- **Loading/Error Routes** for better UX
- **Query Params** for stateful URLs
- **beforeModel Hook** for authentication/redirects

### Testing
- **Test Every Component** - Write integration tests
- **Acceptance Tests** for user flows
- **Page Objects** for maintainable tests
- **Mirage** for API mocking

### Code Organization
- **Co-locate Templates** with components when possible
- **Consistent Naming** - Follow Ember conventions
- **Reuse Components** - DRY principle
- **Feature Folders** - Group related files together

## HashiCorp-Specific Tips

### Helios Design System (HDS)

HashiCorp's design system for Ember applications:
- Pre-built components (buttons, forms, modals)
- Consistent styling and theming
- Accessibility (WCAG 2.2 AA) built-in
- See `/hds` skill for details

### Common HashiCorp Patterns

**Feature Flags:**
```javascript
import Component from '@glimmer/component';
import { inject as service } from '@ember/service';

export default class MyComponent extends Component {
  @service features;

  get showNewFeature() {
    return this.features.isEnabled('new-feature');
  }
}
```

**Permissions/Abilities:**
```javascript
import Component from '@glimmer/component';
import { inject as service } from '@ember/service';

export default class MyComponent extends Component {
  @service abilities;

  get canEdit() {
    return this.abilities.can('edit workspace');
  }
}
```

## Learning Resources

### Official Resources
- **Official Tutorial**: https://guides.emberjs.com/release/tutorial/
- **Ember Guides**: https://guides.emberjs.com/
- **API Documentation**: https://api.emberjs.com/
- **Ember CLI**: https://cli.emberjs.com/

### Learning Platforms
- **EmberMap**: https://embermap.com/ (video tutorials)
- **Frontend Masters**: https://frontendmasters.com/ (courses)
- **Rock & Roll with Ember Octane**: https://balinterdi.com/rock-and-roll-with-emberjs/

### Community
- **Ember Discord**: https://discord.gg/emberjs
- **Ember Forum**: https://discuss.emberjs.com/
- **EmberConf**: Annual Ember conference

## Additional Resources

- **Ember.js Official Site**: https://emberjs.com/
- **Ember CLI**: https://cli.emberjs.com/
- **Ember Observer**: https://emberobserver.com/ (addon directory)
- **The Ember Atlas**: https://www.notion.so/emberatlas/The-Ember-Atlas-4094f81c86c34badb4a562ed29414ae1
- **5 Essential Ember Concepts**: https://emberigniter.com/5-essential-ember-concepts/
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/TerraformFrontend/pages/2256437380/Ember

## Summary

**Quick Start:**
```bash
# Install Ember CLI
npm install -g ember-cli

# Create new app
ember new my-app
cd my-app

# Start dev server
ember serve

# Visit http://localhost:4200
```

**Common Generators:**
```bash
ember generate component my-component
ember generate route my-route
ember generate model user
ember generate service auth
ember generate helper format-date
```

**Project Structure:**
```
app/
├── components/      # Reusable UI components
├── routes/          # Route handlers (fetch data)
├── templates/       # Handlebars templates
├── models/          # Ember Data models
├── adapters/        # API communication
├── serializers/     # Data transformation
└── services/        # Singleton services
```

**Key Concepts:**
- **Components** - Building blocks of UI
- **Routing** - URL-driven architecture
- **Ember Data** - Data layer and ORM
- **Tracked Properties** - Reactivity system
- **Actions** - Event handlers
- **Services** - Shared state and logic

**Development Workflow:**
1. **Setup** - Install Node.js, pnpm, Ember CLI
2. **Install** - `pnpm install` for dependencies
3. **Start** - `pnpm start` for local dev, `pnpm start-mirage` for mocked backend
4. **Lint** - `pnpm lint` and `pnpm lint:fix` before committing
5. **Test** - `pnpm test-server` for interactive debugging
6. **Build** - `pnpm build` for production

**Troubleshooting:**
- Build failures: Clear `node_modules`, `rm -rf tmp dist`, reinstall
- Runtime errors: Check browser console, Network tab, Ember Inspector
- Test failures: Use test server (`pnpm test-server`) for debugging
- Linting: Run `pnpm lint:fix` to auto-fix issues
- Performance: Clear tmp, restart dev server, check for large dependencies
- TypeScript: Run `pnpm lint:types` and `pnpm glint`

**Debugging Tools:**
- **Ember Inspector** - Component tree, routes, data, performance
- **Browser DevTools** - Console, Network, Sources, Performance tabs
- **Template** - `{{log}}` and `{{debugger}}` helpers
- **Tests** - `await this.pauseTest()` for interactive debugging
- **JavaScript** - `debugger;` statements and console.log

**Remember:**
- Convention over Configuration - Follow Ember patterns
- Use Ember Inspector for debugging
- Test your components and routes
- Reuse components whenever possible
- Leverage the addon ecosystem
- Modern Ember = Octane (native classes, tracked properties)
- Check browser console first when debugging
- Use test server for better test debugging
- Run linters before committing
