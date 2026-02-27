---
name: claude-code
description: Claude Code CLI tool for AI-assisted software development with context-aware coding assistance
---

# Claude Code

This skill covers Claude Code, Anthropic's official CLI tool for AI-assisted software development.

## When to Use This Skill

Use this skill when you need to:
- Get AI assistance for coding tasks directly in your terminal
- Understand Claude Code's features and capabilities
- Configure Claude Code for your environment
- Use Claude Code with custom settings (models, providers)
- Learn best practices for working with AI coding assistants
- Troubleshoot Claude Code issues
- Integrate Claude Code with your development workflow

## What is Claude Code?

**Claude Code is Anthropic's official CLI tool** that brings Claude's capabilities directly to your terminal, enabling AI-assisted software development with full codebase context.

### Core Purpose

Claude Code allows you to:
- **Work with full codebase context** - Claude can read your entire project
- **Execute commands** - Claude can run bash commands, read/write files
- **Use tools** - Integrated tools for file operations, searches, git operations
- **Multi-turn conversations** - Maintain context across multiple interactions
- **Local and cloud** - Works with Claude API or AWS Bedrock

### Why Claude Code?

**The Problem with Other AI Tools:**
- Limited context awareness of your codebase
- Copy-paste workflow interrupts development flow
- No ability to execute commands or modify files directly
- Separate from your terminal workflow

**Claude Code's Solution:**
- **Terminal-native** - Works in your existing workflow
- **Full codebase access** - Understands your project structure
- **Agentic capabilities** - Can read, write, execute autonomously
- **Conversational** - Natural language interactions
- **Customizable** - Configure for your needs

## Key Features

| Feature | Description |
| --- | --- |
| **Codebase Understanding** | Reads and understands your entire project |
| **File Operations** | Read, write, edit files with AI assistance |
| **Command Execution** | Run bash commands through Claude |
| **Git Integration** | Create commits, PRs with AI-generated messages |
| **Search** | Search codebase with natural language queries |
| **Multi-turn** | Maintain conversation context |
| **Customizable** | Configure models, providers, settings |
| **Skills & Hooks** | Extend with custom commands and workflows |

## Installation & Setup

### Install Claude Code

**macOS/Linux:**
```bash
# Using the install script
curl -fsSL https://code.claude.com/install.sh | sh

# Or with Homebrew (macOS)
brew install claude-code
```

**Verify Installation:**
```bash
claude --version
```

### Authentication

**Using Anthropic API:**
```bash
# Set API key
export ANTHROPIC_API_KEY="your-api-key-here"

# Or configure in profile
claude auth login
```

**Using AWS Bedrock:**
```bash
# Configure AWS credentials
export AWS_PROFILE=your-profile
export AWS_REGION=us-west-2
export CLAUDE_CODE_USE_BEDROCK=1
```

### Basic Configuration

**Create config directory:**
```bash
mkdir -p ~/.config/claude-code
```

**Set default model:**
```bash
export ANTHROPIC_MODEL="claude-sonnet-4-5"
```

## Common Commands

### Starting Claude

**Start interactive session:**
```bash
claude
```

**Ask a single question:**
```bash
claude "how do I center a div in CSS?"
```

**With specific file context:**
```bash
claude "explain this file" src/App.js
```

**Continue previous conversation:**
```bash
claude --continue
```

### Project Management

**Initialize project:**
```bash
claude init
```

**Set project context:**
```bash
claude set-context "This is a React app using TypeScript"
```

**View current context:**
```bash
claude context
```

### Skills & Slash Commands

**List available skills:**
```bash
claude skills list
```

**Use a skill:**
```bash
claude /commit
claude /review-pr 123
```

**Create custom skill:**
```bash
claude skill create my-skill
```

### Settings

**View settings:**
```bash
claude settings
```

**Update setting:**
```bash
claude settings set model claude-opus-4-5
```

## Common Workflows

### Workflow 1: Getting Help with a Feature

**Scenario:** Implement user authentication

1. **Start Claude:**
   ```bash
   claude
   ```

2. **Ask for help:**
   ```
   I need to add user authentication to this app.
   It's a Node.js Express app. Can you help me implement it?
   ```

3. **Claude will:**
   - Analyze your codebase
   - Suggest implementation approach
   - Create necessary files
   - Update existing code
   - Provide testing instructions

4. **Review changes:**
   ```
   Can you explain what you changed and why?
   ```

### Workflow 2: Debugging an Issue

**Scenario:** Fix a bug in production

1. **Provide context:**
   ```bash
   claude "Users are reporting that login fails after password reset"
   ```

2. **Claude analyzes:**
   - Searches relevant code
   - Identifies potential issues
   - Suggests fixes

3. **Apply fix:**
   ```
   That looks right. Please implement the fix.
   ```

4. **Create commit:**
   ```
   /commit
   ```

### Workflow 3: Code Review

**Scenario:** Review a pull request

1. **Check out PR:**
   ```bash
   gh pr checkout 123
   ```

2. **Ask Claude to review:**
   ```bash
   claude "Please review the changes in this PR"
   ```

3. **Claude provides:**
   - Summary of changes
   - Potential issues
   - Improvement suggestions
   - Security concerns

4. **Get detailed feedback:**
   ```
   Can you suggest specific improvements for the validation logic?
   ```

### Workflow 4: Refactoring Code

**Scenario:** Refactor complex function

1. **Point Claude to the code:**
   ```bash
   claude "Please review the processUserData function in src/utils.js"
   ```

2. **Request refactoring:**
   ```
   This function is too complex. Can you refactor it to be more maintainable?
   ```

3. **Claude will:**
   - Analyze function complexity
   - Suggest refactoring approach
   - Break into smaller functions
   - Add tests

4. **Review and apply:**
   ```
   That looks good. Please apply the changes.
   ```

### Workflow 5: Learning a New Codebase

**Scenario:** Understand unfamiliar project

1. **Start exploration:**
   ```bash
   claude "Can you explain how this codebase is structured?"
   ```

2. **Deep dive into specific areas:**
   ```
   How does the authentication system work?
   Where are API calls made?
   What database models exist?
   ```

3. **Create documentation:**
   ```
   Can you create a README explaining the architecture?
   ```

## Best Practices

### Effective Prompts

**Be specific:**
```
❌ "Make this better"
✅ "Refactor this function to use async/await instead of callbacks"
```

**Provide context:**
```
❌ "Add a button"
✅ "Add a save button to the user profile form that validates required fields before submission"
```

**Break down complex tasks:**
```
❌ "Build a complete authentication system"
✅ "First, let's create the User model with email and password fields"
```

### Working with Claude

**Do:**
- Provide clear requirements
- Review code before applying changes
- Ask Claude to explain its reasoning
- Use multi-turn conversations for complex tasks
- Leverage Claude's codebase understanding

**Don't:**
- Blindly apply all suggestions
- Skip testing after changes
- Ignore security considerations
- Forget to commit incrementally

### Security

**Best practices:**
- **Review all code** before committing
- **Don't share sensitive data** in prompts
- **Use .claudeignore** to exclude sensitive files
- **Verify external commands** before execution
- **Check API usage** to manage costs

### File Management

**Use .claudeignore:**
```
# .claudeignore
node_modules/
.env
*.log
dist/
build/
.git/
```

**This prevents Claude from:**
- Reading sensitive files
- Wasting tokens on generated code
- Accessing large binary files

## Configuration

### Environment Variables

```bash
# API Configuration
export ANTHROPIC_API_KEY="your-key"
export ANTHROPIC_MODEL="claude-sonnet-4-5"

# AWS Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_PROFILE="bedrock"
export AWS_REGION="us-west-2"

# Performance
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024

# Behavior
export CLAUDE_AUTO_COMMIT=false
export CLAUDE_VERBOSE=true
```

### Model Selection

**Available models:**
- `claude-opus-4-5` - Most capable, slower, more expensive
- `claude-sonnet-4-5` - Balanced (recommended)
- `claude-haiku-4-5` - Faster, cheaper, less capable

**Choose based on task:**
- **Complex reasoning**: Opus
- **General coding**: Sonnet
- **Simple tasks**: Haiku

### Config File

**Create ~/.config/claude-code/config.json:**
```json
{
  "model": "claude-sonnet-4-5",
  "max_tokens": 4096,
  "auto_commit": false,
  "skills_path": "~/.config/claude-code/skills"
}
```

## Skills System

### What are Skills?

Skills are reusable commands that extend Claude Code's capabilities:
- Defined in `.claude-plugin/` or `.github/skills/`
- Invoked with `/skill-name`
- Can be shared across projects

### Using Skills

**List available:**
```bash
claude skills list
```

**Invoke a skill:**
```bash
claude /commit
claude /review-pr 123
claude /terraform plan
```

### Creating Custom Skills

1. **Create skill directory:**
   ```bash
   mkdir -p .github/skills/deploy
   ```

2. **Create SKILL.md:**
   ```markdown
   ---
   name: deploy
   description: Deploy application to staging
   ---

   # Deploy to Staging

   You are helping deploy the application to staging environment.

   Steps:
   1. Run tests
   2. Build the application
   3. Deploy to staging server
   4. Verify deployment
   5. Notify team in Slack
   ```

3. **Use skill:**
   ```bash
   claude /deploy
   ```

## Troubleshooting

### Issue 1: Authentication Fails

**Symptoms:**
- "API key invalid" error
- Cannot connect to service

**Solution:**
```bash
# Check API key
echo $ANTHROPIC_API_KEY

# Re-authenticate
claude auth login

# Or set environment variable
export ANTHROPIC_API_KEY="your-key"
```

### Issue 2: Context Too Large

**Symptoms:**
- "Context length exceeded" error
- Slow responses

**Solution:**
```bash
# Add to .claudeignore
echo "node_modules/" >> .claudeignore
echo "dist/" >> .claudeignore
echo "*.log" >> .claudeignore

# Or reduce context
claude --max-context-files 50
```

### Issue 3: Claude Not Seeing Recent Changes

**Symptoms:**
- Claude references old code
- Missing recent files

**Solution:**
```bash
# Restart Claude session
claude --new

# Or refresh context
claude refresh
```

### Issue 4: High API Costs

**Symptoms:**
- Unexpected API bills
- Token usage too high

**Solution:**
```bash
# Use Haiku for simple tasks
export ANTHROPIC_MODEL="claude-haiku-4-5"

# Limit output tokens
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=2048

# Use .claudeignore aggressively
```

## HashiCorp-Specific Tips

### Using with AWS Bedrock

**HashiCorp configuration:**

```bash
# ~/.local/share/zsh/site-functions/claude
ANTHROPIC_MODEL='global.anthropic.claude-sonnet-4-5-20250929-v1:0' \
ANTHROPIC_SMALL_FAST_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0' \
AWS_PROFILE=${AWS_PROFILE:-bedrock} \
AWS_REGION=${AWS_REGION:-us-west-2} \
CLAUDE_CODE_USE_BEDROCK=1 \
CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096 \
MAX_THINKING_TOKENS=1024 \
command claude "${@}"
```

**AWS credentials via Doormat:**

```bash
# ~/.aws/config
[profile bedrock]
credential_process = doormat aws cred-process --port 9000 --account aws_account_name
```

**Usage:**
```bash
# Authenticate with Doormat first
doormat aws

# Then use Claude
claude "help me with this code"
```

### Internal Policies

**Responsible AI Guidelines:**
- Review all Claude-generated code
- Don't commit without testing
- Follow security best practices
- Be mindful of costs
- See: Internal Confluence on Responsible AI

**Common use cases at HashiCorp:**
- Code reviews and refactoring
- Documentation generation
- Test writing
- Debugging assistance
- Learning new codebases

### HashiCorp Skills

**Terraform skills:**
- `/terraform` - Terraform guidance
- `/sentinel` - Policy as code help
- `/hds` - Helios Design System help

**Internal tools:**
- `/doormat` - Doormat authentication help
- `/feature-flags` - LaunchDarkly integration

## Tips & Tricks

### Keyboard Shortcuts

**In interactive mode:**
- `Ctrl+C` - Cancel current operation
- `Ctrl+D` - Exit Claude
- `Ctrl+R` - Search conversation history
- `↑/↓` - Navigate command history

### Efficient Workflows

**Batch related changes:**
```
Please make the following changes:
1. Add email validation to User model
2. Update the login form to show validation errors
3. Add tests for the validation logic
```

**Iterative development:**
```
Let's start with a basic implementation, then we can improve it.
```

**Get explanations:**
```
Before implementing, can you explain your approach?
```

### Pro Tips

**Use Claude for:**
- Writing tests (saves time)
- Creating boilerplate code
- Refactoring complex logic
- Writing documentation
- Code review feedback

**Don't use Claude for:**
- Copying code from memory (use docs instead)
- Generating secure random values
- Making production deployment decisions
- Replacing human code review

## Additional Resources

- **Official Documentation**: https://code.claude.com/docs
- **GitHub Repository**: https://github.com/anthropics/claude-code
- **Claude API Docs**: https://docs.anthropic.com/
- **Community**: Discord, GitHub Discussions
- **Internal HashiCorp**: Confluence on Responsible AI

## Summary

**Quick Start:**
```bash
# Install
curl -fsSL https://code.claude.com/install.sh | sh

# Authenticate
export ANTHROPIC_API_KEY="your-key"

# Start Claude
claude

# Or with Bedrock (HashiCorp)
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_PROFILE=bedrock
claude
```

**Common Commands:**
```bash
claude                          # Start interactive session
claude "question"               # Single question
claude /commit                  # Create git commit
claude /review-pr 123           # Review PR
claude skills list              # List skills
claude --continue               # Continue conversation
```

**Environment Variables:**
```bash
export ANTHROPIC_API_KEY="key"
export ANTHROPIC_MODEL="claude-sonnet-4-5"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export CLAUDE_CODE_USE_BEDROCK=1  # For AWS Bedrock
```

**.claudeignore Example:**
```
node_modules/
.env
*.log
dist/
build/
.git/
coverage/
```

**Best Practices:**
- Review all generated code
- Use .claudeignore for large files
- Be specific in prompts
- Break down complex tasks
- Test before committing
- Monitor API usage/costs

**Remember:**
- Claude Code is a tool, not a replacement for developers
- Always review code before applying changes
- Use appropriate model for task complexity
- Leverage skills for common workflows
- Keep sensitive data out of prompts
- Follow your organization's AI usage policies
