---
name: jira
description: HashiCorp Jira access and Atlassian MCP server setup. Use when working with Jira projects, issues, or automation workflows.
---

# Jira

This skill covers accessing HashiCorp's Jira instance and setting up the Atlassian MCP server for AI-assisted Jira workflows.

## Quick Links

- [HashiCorp Jira](https://hashicorp.atlassian.net/jira/for-you) - Your Jira dashboard

## Atlassian MCP Server Setup

The Atlassian MCP Server enables your AI coding tool to interact directly with Jira and Confluence - searching issues, creating tickets, reading pages, and more.

### Installation

1. **Official Documentation**: See [atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server) for complete setup instructions

2. **Claude Code Setup**: Add to `~/.claude/.mcp.json`:
   ```json
   {
     "atlassian": {
       "type": "http",
       "url": "https://mcp.atlassian.com/v1/mcp"
     }
   }
   ```

3. **Restart** your AI coding tool after configuration

4. **Authenticate**: On first use, you'll be prompted to authenticate via OAuth with your Atlassian account

### What You Can Do with the MCP Server

Once configured, you can ask your AI assistant to:

- **Search Jira**: "Find all open bugs assigned to me"
- **Create issues**: "Create a story titled 'Add dark mode support'"
- **Update issues**: "Move PROJ-123 to In Progress"
- **Bulk operations**: "Create Jira tickets from these meeting notes"
- **Link content**: "Link these tickets to the release planning Confluence page"

### Permissions

The MCP server respects your existing Jira permissions. You can only access projects and issues you have permission to view in Jira directly.

## Common Jira Workflows

### Creating Issues

When creating issues, include:
- **Project**: The project key (e.g., ATLAS, TF, VAULT)
- **Issue Type**: Story, Bug, Task, Epic, etc.
- **Summary**: Clear, concise title
- **Description**: Detailed context and acceptance criteria
- **Labels/Components**: For categorization

### JQL Quick Reference

Common JQL queries:
```
# My open issues
assignee = currentUser() AND status != Done

# Recent bugs in a project
project = PROJ AND type = Bug AND created >= -7d

# Sprint backlog
project = PROJ AND sprint in openSprints()

# Issues without estimates
project = PROJ AND "Story Points" is EMPTY
```

## Troubleshooting

### "Your site admin must authorize this app"
A site admin must complete the OAuth flow first. See [Atlassian support docs](https://support.atlassian.com/atlassian-cloud/kb/your-site-admin-must-authorize-this-app-error-in-atlassian-cloud-apps/).

### MCP server not connecting
1. Verify the `.mcp.json` file is valid JSON
2. Restart your AI coding tool
3. Check you're connected to the internet
4. Ensure you have access to `hashicorp.atlassian.net`

## Additional Resources

- [Atlassian MCP Server Documentation](https://www.atlassian.com/platform/remote-mcp-server)
- [Jira Cloud Documentation](https://support.atlassian.com/jira-software-cloud/)
