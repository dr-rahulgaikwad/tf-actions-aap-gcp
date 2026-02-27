---
name: github
description: GitHub version control platform for collaborating on code, pull requests, CI/CD, and project management
---

# GitHub

This skill covers GitHub, the web-based platform for version control and collaboration built on Git.

## When to Use This Skill

Use this skill when you need to:
- Manage code repositories and version control
- Collaborate with teams using pull requests
- Set up CI/CD pipelines with GitHub Actions
- Review code and provide feedback
- Track issues and project management
- Secure repositories with branch protection
- Automate workflows and integrations
- Use GitHub CLI for command-line operations

## What is GitHub?

**GitHub is a web-based platform for version control and collaboration** that allows multiple people to work together on projects from anywhere.

### Core Purpose

GitHub provides:
- **Git hosting** - Remote repositories for code storage
- **Collaboration tools** - Pull requests, code review, discussions
- **CI/CD** - GitHub Actions for automation
- **Project management** - Issues, projects, milestones
- **Security** - Dependabot, code scanning, secret scanning
- **Documentation** - README, wikis, GitHub Pages

### Why GitHub?

**The Problem without GitHub:**
- No central repository for team code
- Difficult to track changes and history
- Manual code review processes
- No automated testing before merge
- Hard to manage contributions from multiple developers
- Security vulnerabilities go undetected

**GitHub's Solution:**
- **Centralized hosting** - Single source of truth for code
- **Pull requests** - Structured code review workflow
- **Branch protection** - Enforce quality gates
- **Actions** - Automated CI/CD pipelines
- **Security scanning** - Automatic vulnerability detection
- **Collaboration features** - Issues, discussions, projects

## Key Features

| Feature | Description |
| --- | --- |
| **Repositories** | Store and version control your code |
| **Pull Requests** | Propose, review, and merge changes |
| **GitHub Actions** | CI/CD automation and workflows |
| **Issues** | Track bugs, features, and tasks |
| **Projects** | Kanban-style project management |
| **Code Review** | Inline comments and suggestions |
| **Branch Protection** | Enforce checks before merging |
| **GitHub Pages** | Host static websites |

## Installation & Setup

### Install Git

**macOS (Homebrew):**
```bash
brew install git
```

**Linux:**
```bash
sudo apt-get install git  # Debian/Ubuntu
sudo yum install git      # RHEL/CentOS
```

**Verify Installation:**
```bash
git --version
```

### Install GitHub CLI

**macOS (Homebrew):**
```bash
brew install gh
```

**Linux:**
```bash
# See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

**Authenticate:**
```bash
gh auth login
```

### Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

## Common Commands

### Repository Operations

**Clone a repository:**
```bash
git clone https://github.com/username/repo.git
# or with gh
gh repo clone username/repo
```

**Create a new repository:**
```bash
gh repo create my-project --public
gh repo create my-project --private
```

**Fork a repository:**
```bash
gh repo fork owner/repo
```

**View repository info:**
```bash
gh repo view
gh repo view owner/repo
```

### Branch Management

**Create and switch to a new branch:**
```bash
git checkout -b feature/my-feature
# or
git switch -c feature/my-feature
```

**List branches:**
```bash
git branch           # Local branches
git branch -r        # Remote branches
git branch -a        # All branches
```

**Delete a branch:**
```bash
git branch -d feature-name      # Safe delete
git branch -D feature-name      # Force delete
git push origin --delete feature-name  # Delete remote
```

### Commits

**Stage and commit changes:**
```bash
git add .
git commit -m "feat: add user authentication"
```

**Amend last commit:**
```bash
git commit --amend -m "Updated commit message"
```

**View commit history:**
```bash
git log
git log --oneline --graph --all
```

### Pull Requests

**Create a pull request:**
```bash
gh pr create --title "Add feature" --body "Description"
gh pr create --fill  # Use commit message
```

**List pull requests:**
```bash
gh pr list
gh pr list --state all
```

**View PR details:**
```bash
gh pr view 123
gh pr view --web  # Open in browser
```

**Check out a PR locally:**
```bash
gh pr checkout 123
```

**Merge a pull request:**
```bash
gh pr merge 123
gh pr merge 123 --squash
gh pr merge 123 --rebase
```

**Review a PR:**
```bash
gh pr review 123 --approve
gh pr review 123 --request-changes --body "Needs tests"
gh pr review 123 --comment --body "Looks good"
```

### Issues

**Create an issue:**
```bash
gh issue create --title "Bug: login fails" --body "Description"
```

**List issues:**
```bash
gh issue list
gh issue list --label bug
gh issue list --assignee @me
```

**View an issue:**
```bash
gh issue view 456
```

**Close an issue:**
```bash
gh issue close 456
```

### GitHub Actions

**List workflow runs:**
```bash
gh run list
gh run list --workflow=ci.yml
```

**View run details:**
```bash
gh run view 789
gh run view --log  # View logs
```

**Re-run a workflow:**
```bash
gh run rerun 789
```

**Trigger a workflow:**
```bash
gh workflow run ci.yml
```

## Common Workflows

### Workflow 1: Contributing to a Project

**Scenario:** Make a contribution to an open-source project

1. **Fork the repository:**
   ```bash
   gh repo fork original-owner/repo
   cd repo
   ```

2. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-contribution
   ```

3. **Make changes and commit:**
   ```bash
   # Edit files
   git add .
   git commit -m "feat: add new feature"
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/my-contribution
   ```

5. **Create pull request:**
   ```bash
   gh pr create --base main --head your-username:feature/my-contribution
   ```

6. **Respond to review feedback:**
   ```bash
   # Make requested changes
   git add .
   git commit -m "fix: address review feedback"
   git push
   ```

### Workflow 2: Feature Branch Workflow

**Scenario:** Team development with feature branches

1. **Update main branch:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/user-auth
   ```

3. **Develop and commit:**
   ```bash
   # Make changes
   git add .
   git commit -m "feat: implement user authentication"
   ```

4. **Keep branch updated:**
   ```bash
   git checkout main
   git pull
   git checkout feature/user-auth
   git rebase main
   ```

5. **Push and create PR:**
   ```bash
   git push -u origin feature/user-auth
   gh pr create --fill
   ```

6. **Merge after approval:**
   ```bash
   gh pr merge --squash
   git checkout main
   git pull
   git branch -d feature/user-auth
   ```

### Workflow 3: Reviewing Pull Requests

**Scenario:** Review a team member's PR

1. **List open PRs:**
   ```bash
   gh pr list
   ```

2. **Check out the PR:**
   ```bash
   gh pr checkout 123
   ```

3. **Test locally:**
   ```bash
   npm test
   npm run lint
   ```

4. **Leave review comments:**
   ```bash
   gh pr review 123 --comment --body "Great work! A few suggestions..."
   ```

5. **Approve or request changes:**
   ```bash
   # Approve
   gh pr review 123 --approve --body "LGTM!"

   # Request changes
   gh pr review 123 --request-changes --body "Please add tests"
   ```

### Workflow 4: Setting Up GitHub Actions

**Scenario:** Add CI/CD pipeline for testing

1. **Create workflow file:**
   ```bash
   mkdir -p .github/workflows
   ```

2. **Define workflow (.github/workflows/ci.yml):**
   ```yaml
   name: CI

   on:
     push:
       branches: [ main ]
     pull_request:
       branches: [ main ]

   jobs:
     test:
       runs-on: ubuntu-latest

       steps:
       - uses: actions/checkout@v3

       - name: Setup Node.js
         uses: actions/setup-node@v3
         with:
           node-version: '18'

       - name: Install dependencies
         run: npm ci

       - name: Run tests
         run: npm test

       - name: Run linter
         run: npm run lint
   ```

3. **Commit and push:**
   ```bash
   git add .github/workflows/ci.yml
   git commit -m "ci: add GitHub Actions workflow"
   git push
   ```

4. **View workflow runs:**
   ```bash
   gh run list
   gh run watch  # Watch in real-time
   ```

### Workflow 5: Branch Protection Rules

**Scenario:** Enforce code quality before merging

1. **Via GitHub CLI:**
   ```bash
   # Require PR reviews
   gh api repos/:owner/:repo/branches/main/protection \
     -X PUT \
     -F required_pull_request_reviews[required_approving_review_count]=1

   # Require status checks
   gh api repos/:owner/:repo/branches/main/protection \
     -X PUT \
     -F required_status_checks[strict]=true \
     -F required_status_checks[contexts][]=ci
   ```

2. **Or configure in UI:**
   - Go to Settings → Branches
   - Add rule for `main` branch
   - Enable:
     - Require pull request reviews
     - Require status checks to pass
     - Require conversation resolution
     - Restrict who can push

## Best Practices

### Commit Messages

**Use conventional commits:**
```
feat: add user authentication
fix: resolve login redirect issue
docs: update README with setup instructions
test: add unit tests for user model
refactor: simplify validation logic
chore: update dependencies
```

**Guidelines:**
- Use present tense ("add" not "added")
- Be concise but descriptive
- Reference issue numbers (#123)
- Explain "why" in commit body if needed

### Pull Requests

**Good PR practices:**
- **Keep PRs small** - Easier to review (< 400 lines)
- **Single purpose** - One feature or fix per PR
- **Clear title** - Describe what the PR does
- **Detailed description** - Include context, testing, screenshots
- **Link issues** - "Closes #123" or "Fixes #456"
- **Update documentation** - README, docs with code changes
- **Add tests** - Cover new functionality

**PR Template:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] Manually tested

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed
- [ ] Commented complex code
- [ ] Documentation updated
```

### Branch Naming

**Follow a naming convention:**
```
feature/user-authentication
fix/login-redirect-bug
docs/update-readme
refactor/simplify-validation
test/add-user-tests
chore/update-dependencies
```

### Security

**Best practices:**
- **Never commit secrets** - Use GitHub Secrets for sensitive data
- **Enable Dependabot** - Automatic dependency updates
- **Code scanning** - Enable GitHub Advanced Security
- **Branch protection** - Prevent force pushes to main
- **Require 2FA** - For all organization members
- **Review permissions** - Limit who can push to protected branches

### Repository Organization

**Structure:**
```
repo/
├── .github/
│   ├── workflows/       # GitHub Actions
│   ├── ISSUE_TEMPLATE/  # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS       # Auto-assign reviewers
├── docs/                # Documentation
├── src/                 # Source code
├── tests/               # Tests
├── .gitignore
├── README.md
└── LICENSE
```

**README essentials:**
- Project description
- Installation instructions
- Usage examples
- Contributing guidelines
- License information

## GitHub Actions Examples

### Basic CI Workflow

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: '18'
    - run: npm ci
    - run: npm test
    - run: npm run build
```

### Multi-Job Workflow

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - run: npm ci
    - run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - run: npm ci
    - run: npm run build
    - uses: actions/upload-artifact@v3
      with:
        name: dist
        path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/download-artifact@v3
      with:
        name: dist
    - name: Deploy
      run: ./deploy.sh
```

### Matrix Strategy

```yaml
name: Test Matrix

on: [push]

jobs:
  test:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: ['16', '18', '20']

    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node }}
    - run: npm ci
    - run: npm test
```

## Troubleshooting

### Issue 1: Merge Conflicts

**Symptoms:**
- Cannot merge PR due to conflicts
- Git reports conflicting files

**Solution:**
```bash
# Update your branch
git checkout feature-branch
git fetch origin
git rebase origin/main

# Resolve conflicts in editor
git add resolved-file.js
git rebase --continue

# Force push (rewrite history)
git push --force-with-lease
```

### Issue 2: Failed GitHub Action

**Symptoms:**
- Red X on commit/PR
- Workflow run fails

**Solution:**
```bash
# View logs
gh run view --log

# Re-run failed jobs
gh run rerun --failed

# Debug locally
act  # Using 'act' tool to run Actions locally
```

### Issue 3: Permission Denied

**Symptoms:**
- Cannot push to repository
- 403 or permission errors

**Solution:**
```bash
# Check authentication
gh auth status

# Re-authenticate
gh auth login

# Or use SSH keys
ssh -T git@github.com
```

### Issue 4: Large Files

**Symptoms:**
- Push rejected due to large files
- Repository size bloated

**Solution:**
```bash
# Use Git LFS for large files
git lfs install
git lfs track "*.psd"
git add .gitattributes

# Remove large file from history
git filter-branch --tree-filter 'rm -f large-file.zip' HEAD
# Or use BFG Repo-Cleaner
```

## HashiCorp-Specific Tips

### GitHub Enterprise

HashiCorp may use GitHub Enterprise with:
- Custom domains (github.ibm.com, etc.)
- Organization-wide policies
- Advanced security features
- Private runners for GitHub Actions

### Internal Workflows

**Common patterns:**
- **Mono-repos** - Large repos with multiple projects
- **Required reviews** - 1-2 approving reviews before merge
- **Protected branches** - Main/master cannot be pushed directly
- **Automated testing** - CI must pass before merge
- **CODEOWNERS** - Auto-assign reviewers by file path

### GitHub Actions at HashiCorp

**Common workflows:**
- Automated testing on every PR
- Dependency updates with Dependabot
- Security scanning with CodeQL
- Terraform plan/apply automation
- Docker image building and pushing

**Example CODEOWNERS:**
```
# Backend team owns Go code
*.go @hashicorp/backend-team

# Frontend team owns JS/TS
*.js @hashicorp/frontend-team
*.ts @hashicorp/frontend-team

# Docs team owns documentation
/docs/ @hashicorp/docs-team
*.md @hashicorp/docs-team
```

## Additional Resources

- **GitHub Docs**: https://docs.github.com/
- **GitHub CLI Manual**: https://cli.github.com/manual/
- **GitHub Actions**: https://docs.github.com/en/actions
- **Git Book**: https://git-scm.com/book/en/v2
- **GitHub Skills**: https://skills.github.com/
- **GitHub Blog**: https://github.blog/

## Summary

**Most Common Commands:**
```bash
# Repository operations
gh repo clone owner/repo
gh repo create my-project
gh repo fork owner/repo

# Pull requests
gh pr create --fill
gh pr list
gh pr view 123
gh pr checkout 123
gh pr merge 123 --squash

# Issues
gh issue create
gh issue list
gh issue close 123

# Actions
gh run list
gh run view --log
gh workflow run ci.yml
```

**Git Workflow:**
```bash
# Start feature
git checkout -b feature/my-feature

# Make changes
git add .
git commit -m "feat: add feature"

# Push and create PR
git push -u origin feature/my-feature
gh pr create --fill

# After merge
git checkout main
git pull
git branch -d feature/my-feature
```

**Branch Protection Checklist:**
- ✅ Require pull request reviews (1-2 reviewers)
- ✅ Require status checks to pass before merging
- ✅ Require conversation resolution before merging
- ✅ Require signed commits (optional)
- ✅ Include administrators in restrictions
- ✅ Restrict who can push to matching branches

**Remember:**
- Keep commits small and focused
- Write clear commit messages (conventional commits)
- Review your own PR first before requesting reviews
- Keep PRs under 400 lines when possible
- Always pull before starting new work
- Use branch protection on main/master
- Enable 2FA on your GitHub account
- Never commit secrets or credentials
