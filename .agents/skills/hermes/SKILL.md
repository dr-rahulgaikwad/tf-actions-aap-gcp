---
name: hermes
description: Hermes document management system for RFCs/PRDs, approvals, metadata, and SharePoint migration. Use when creating, reviewing, or managing Hermes documents.
---

# Hermes - Document Management System

A comprehensive guide to using Hermes, HashiCorp's internal document management system for collaborative documentation.

## What is Hermes?

Hermes is HashiCorp's internal document management system that provides enhanced collaboration features on top of document platforms. Originally built on Google Workspace, Hermes is currently migrating to SharePoint as part of IBM's platform unification effort.

**Key Features:**
- **Document Metadata Management**: Structured headers and metadata for documents
- **Approval Workflows**: Built-in approval process for documents (RFCs, PRDs, etc.)
- **Product Association**: Link documents to specific HashiCorp products
- **Search & Discovery**: Algolia-powered search across all documents
- **Document Templates**: RFC, PRD, and other document templates
- **Locking & Collaboration**: Document locking to prevent conflicts
- **Group Management**: Approver groups and subscriber notifications
- **Authentication**: W3ID (IBM) authentication integration

**Primary Use Cases:**
- Writing and reviewing RFCs (Request for Comments)
- Creating and managing PRDs (Product Requirement Documents)
- Collaborative document editing with approval workflows
- Searching for existing documentation across products
- Managing document approvals and stakeholder reviews
- Tracking document status and ownership

## When to Use Hermes

Use Hermes when you need to:

- **Create RFCs or PRDs**: Use Hermes templates and approval workflows
- **Manage document approvals**: Track approvers and get sign-offs
- **Search for documents**: Find RFCs, PRDs, and other docs across products
- **Associate docs with products**: Link documentation to specific HashiCorp products
- **Collaborate on documents**: Use locking and metadata features
- **Track document status**: Monitor approval progress and updates
- **Organize team documentation**: Centralized document management

**Who uses Hermes:**
- Product Managers creating PRDs
- Engineering teams writing RFCs
- Architects documenting technical decisions
- Team leads managing approval processes
- Anyone searching for existing documentation

## Accessing Hermes

### Current Platform: SharePoint (Beta)

**Dashboard**: https://hermes-sharepoint.hashicorp.services/dashboard

**Authentication**: W3ID (IBM SSO)

**Requirements**:
- Active HashiCorp IBM account
- W3ID authentication
- Microsoft Office 365 access
- Hermes Add-In (for full functionality)

### Add-In Installation

The Hermes Add-In provides metadata management and enhanced features in Microsoft Office applications:

1. **Access Outlook**: Use your IBM Outlook account
2. **Install Add-In**: Request access through the Toolbox team
3. **Authenticate**: Sign in with W3ID credentials
4. **Start Using**: Open documents in Office apps with Hermes integration

**Supported Browsers**:
- Microsoft Edge (primary)
- Google Chrome
- Firefox and Safari support in development

## Current Migration Status

Hermes is currently migrating from Google Workspace to SharePoint:

**Migration Program**: [Hermes Program Page](https://hashicorp.atlassian.net/wiki/spaces/IND/pages/4191289346/Hermes+Program+Page)

### Milestones

1. **M1 - Setup & Exploration** (Complete)
   - Local development setup
   - Current infrastructure exploration
   - Vulnerability remediation

2. **M2 - Hermes on SharePoint** (Beta Released)
   - Dev and pre-prod setup
   - Beta launch completed December 2025
   - GA (General Availability) targeted for January 16, 2026

3. **M3 - Document Migration** (In Progress)
   - Migrate existing Google Drive documents to SharePoint
   - Preserve all metadata and document structure
   - Target completion: January 16, 2026

### Current Status (Beta Release)

- ✅ Production deployment complete
- ✅ W3ID authentication working
- ✅ Algolia search integration configured
- ✅ Add-In development complete
- ✅ 116 of 118 security vulnerabilities fixed
- ✅ Application Performance Monitoring live in Datadog
- 🔄 Document migration from Google Drive in progress
- 🔄 Multi-browser support (Firefox, Safari) in development
- 🔄 IBM CSRB security review ongoing

## Key Features

### 1. Document Templates

Hermes provides templates for common document types:

**RFC (Request for Comments)**:
- Standardized format for technical proposals
- Built-in approval workflow
- Metadata headers (status, approvers, stakeholders)
- Product association

**PRD (Product Requirement Document)**:
- Product planning and requirements
- Feature specifications
- Approval tracking
- Stakeholder management

**Other Templates**:
- Team documentation
- Technical design documents
- Architecture decision records

### 2. Metadata Management

Every Hermes document includes structured metadata:

**Header Fields**:
- **Title**: Document title
- **Status**: Draft, In Review, Approved, etc.
- **Product**: Associated HashiCorp product
- **Approvers**: Required approvers for sign-off
- **Contributors**: Document authors
- **Created/Modified**: Timestamps
- **Owner**: Document owner

**Metadata Features**:
- Clickable hyperlinks to Hermes site
- Automatic metadata extraction
- Search indexing based on metadata
- Group-based approver management

### 3. Approval Workflows

Hermes provides structured approval processes:

**Workflow Steps**:
1. Create document from template
2. Add metadata (approvers, product, etc.)
3. Share with stakeholders
4. Track approval status
5. Receive notification when approved
6. Document marked as approved in system

**Approval Features**:
- Email notifications to approvers
- Approval groups (not individual approvers)
- Product subscriber emails
- Status tracking in dashboard

### 4. Search & Discovery

Algolia-powered search across all Hermes documents:

**Search Capabilities**:
- Full-text search across documents
- Metadata-based filtering
- Product-specific searches
- Author/owner filtering
- Status filtering (draft, approved, etc.)
- Date range searches

**Access Search**:
- Via Hermes dashboard
- Direct search functionality
- Filter by product, status, owner
- Sort by relevance or date

### 5. Document Locking

Prevents editing conflicts during collaboration:

**Locking Features**:
- Automatic lock when editing
- Lock released on document close
- Visual indicators for locked documents
- Prevents simultaneous edits to headers

**Note**: With the new SharePoint Add-In, locking constraints have been removed for real-time metadata updates.

### 6. Add-In Functionality

The Hermes Add-In provides enhanced features in Office apps:

**Key Functions**:
- Metadata editing in sidebar
- Document header management
- Group search and selection
- Copy document link to clipboard
- Hyperlink creation in headers
- Real-time status updates

**Technical Implementation**:
- Microsoft Office Add-In architecture
- W3ID authentication integration
- SharePoint API integration
- Algolia search integration

## Common Workflows

### 1. Creating a New RFC

**Goal**: Write and submit an RFC for technical proposal.

**Steps**:
1. Navigate to Hermes dashboard
2. Click "New RFC" or select RFC template
3. Document opens in Microsoft Word/Office 365
4. Fill in metadata:
   - Title
   - Product association
   - Approvers (use group search)
   - Contributors
5. Write RFC content following template structure
6. Set status to "In Review"
7. Share link with stakeholders
8. Track approval progress in dashboard
9. Mark as "Approved" when complete

**Best Practices**:
- Use descriptive titles
- Select appropriate product
- Add all required approvers upfront
- Keep metadata current

### 2. Searching for Existing Documentation

**Goal**: Find existing RFCs or PRDs related to your work.

**Steps**:
1. Navigate to Hermes dashboard
2. Use search bar to enter keywords
3. Apply filters:
   - Product (e.g., "Terraform", "Vault")
   - Document type (RFC, PRD)
   - Status (Approved, Draft)
   - Owner/Author
4. Review search results
5. Click document to open in Office 365

**Search Tips**:
- Use specific product names
- Search by technical terms
- Filter by status to find approved RFCs
- Search by author for team documents

### 3. Managing Document Approvals

**Goal**: Track and manage approvals for your document.

**Steps**:
1. Open your document in Hermes
2. Open Add-In sidebar (if not visible)
3. Review current approvers
4. Add/remove approvers as needed
5. Check approval status
6. Send reminder emails if needed
7. Monitor for approval notifications
8. Update status when all approvals received

**Approval Groups**:
- Use Blue Groups for organizational approvers
- Configure group membership via AccessHub
- Approvers receive email notifications
- Status updates automatically

### 4. Migrating Documents to SharePoint

**Goal**: Migrate your existing Google Drive documents to SharePoint Hermes.

**Steps** (currently in progress):
1. **Identify documents**: List documents to migrate
2. **Check metadata**: Ensure metadata is complete
3. **Migration tool**: Use Hermes migration tool (when available)
4. **Verify migration**: Check document in SharePoint
5. **Validate metadata**: Ensure all metadata preserved
6. **Update links**: Update any hardcoded links

**Note**: Full migration tooling is being developed (M3 milestone). Contact the Hermes team for current migration status.

### 5. Using Hermes with the Add-In

**Goal**: Edit document metadata and headers using the Add-In.

**Steps**:
1. Open document in Microsoft Word/Office 365
2. Ensure Hermes Add-In is installed
3. Add-In sidebar appears automatically
4. Edit metadata fields:
   - Title, Product, Status
   - Approvers, Contributors
   - Other custom fields
5. Click "Copy Link" to share document URL
6. Changes save automatically
7. Metadata updates in real-time

**Add-In Features**:
- No manual header editing needed
- Prevents metadata duplication
- Clickable hyperlinks in headers
- Real-time status updates

## Architecture & Infrastructure

### Current Architecture

**Frontend**:
- Microsoft Office 365 Add-In
- SharePoint integration
- W3ID authentication

**Backend**:
- AWS infrastructure (hashidocs_prod account)
- Hashistack deployment (VPC, IAM, RDS, EC2)
- Application Load Balancer with auto-registration
- VPC peering for database connectivity

**Search & Indexing**:
- Algolia for document search
- Indexer service for metadata extraction
- Real-time indexing on document updates

**Authentication**:
- W3ID (IBM SSO) integration
- Blue Groups for group management
- AccessHub for access control
- OAuth token exchange

**Monitoring**:
- Application Performance Monitoring in Datadog
- Infrastructure monitoring
- WAF (Web Application Firewall) enabled
- Security vulnerability scanning

### Deployment

**Environments**:
- **Production**: https://hermes-sharepoint.hashicorp.services/
- **Pre-Production**: Testing and validation environment
- **Development**: Local development setup

**Deployment Method**:
- Terraform Cloud (TFC) for infrastructure
- GitHub Workflows for CI/CD pipeline
- VCS-triggered deployments
- Docker containerization
- PSS Artifactory for image storage

### Security

**Security Measures**:
- 116 of 118 vulnerabilities remediated
- IBM CISO security tools in base images
- GitHub vulnerability scanning
- Volume encryption for data at rest
- WAF protection
- Regular security reviews

## Troubleshooting

### Cannot Access Hermes Dashboard

**Problem**: Dashboard won't load or shows authentication errors.

**Solutions**:
1. **Verify W3ID authentication**: Ensure you're logged into IBM SSO
2. **Check account access**: Confirm you have HashiCorp IBM account
3. **Clear browser cache**: Try hard refresh (Cmd+Shift+R or Ctrl+F5)
4. **Try different browser**: Use Microsoft Edge (primary supported browser)
5. **Contact support**: Reach out to Hermes team in Slack

### Add-In Not Appearing

**Problem**: Hermes Add-In doesn't show in Microsoft Office apps.

**Solutions**:
1. **Verify installation**: Confirm Add-In is deployed to your account
2. **Check Office 365 access**: Ensure you have proper licensing
3. **Reload document**: Close and reopen the document
4. **Check browser**: Use supported browser (Edge, Chrome)
5. **Request access**: Contact Toolbox team for Add-In deployment

### Search Not Finding Documents

**Problem**: Cannot find documents you know exist.

**Solutions**:
1. **Check filters**: Remove any active filters limiting results
2. **Verify permissions**: Ensure you have access to the document
3. **Try different keywords**: Use alternate search terms
4. **Check document metadata**: Verify document is properly indexed
5. **Wait for indexing**: New documents may take time to index

### Metadata Not Updating

**Problem**: Changes to metadata don't appear or save.

**Solutions**:
1. **Use Add-In**: Edit metadata through Add-In, not manually
2. **Check permissions**: Verify you have edit access
3. **Refresh document**: Close and reopen to see updates
4. **Check network**: Ensure stable connection to SharePoint
5. **Report issue**: File bug with Hermes team if persists

### Document Locking Issues

**Problem**: Document appears locked when it shouldn't be.

**Solutions**:
1. **Check who has it open**: View lock status in Hermes dashboard
2. **Wait for auto-release**: Locks release when document closes
3. **Contact document owner**: Ask them to close the document
4. **Check for zombie sessions**: User may have left document open
5. **Admin unlock**: Contact Hermes admin for manual unlock

## Migration from Google Drive

### Migration Timeline

**Current Phase**: M3 - Document Migration (In Progress)

**Target Completion**: January 16, 2026

### What's Being Migrated

1. **Documents**:
   - All RFCs, PRDs, and templates
   - Document content and formatting
   - Folder structure and organization

2. **Metadata**:
   - Headers and structured data
   - Approvers and approval status
   - Product associations
   - Created/modified dates
   - Ownership information

3. **Search Index**:
   - Algolia index updates
   - Metadata indexing
   - Full-text search capabilities

### Migration Process

1. **Preparation**: Document inventory and metadata validation
2. **Tool Development**: Migration scripts and validation tools
3. **Pilot Migration**: Test migration with small document set
4. **Bulk Migration**: Migrate all documents
5. **Validation**: Verify metadata and content integrity
6. **Cutover**: Switch from Google Drive to SharePoint

### What to Expect

- **Minimal disruption**: Migration designed to be seamless
- **Automatic updates**: Documents migrate without user action
- **Link preservation**: Document links should continue working
- **Metadata preservation**: All metadata migrated intact

## Best Practices

### For Document Authors

1. **Use templates**: Start with RFC/PRD templates for consistency
2. **Complete metadata upfront**: Add all metadata when creating documents
3. **Use groups for approvers**: Don't list individual approvers
4. **Keep status current**: Update status as document progresses
5. **Add descriptive titles**: Make documents easy to find in search

### For Approvers

1. **Respond promptly**: Check approval requests regularly
2. **Use Comments**: Provide feedback directly in document
3. **Update approval status**: Mark as approved when ready
4. **Subscribe to products**: Get notified of new docs in your area
5. **Join approver groups**: Be part of relevant Blue Groups

### For Search & Discovery

1. **Use specific keywords**: Search by product, technology, feature
2. **Filter by status**: Find approved RFCs for reference
3. **Search by author**: Find documents from specific teams
4. **Bookmark common searches**: Save frequently used search filters
5. **Check metadata**: Review metadata for context before opening

### For Migration

1. **Check document inventory**: Know what you have in Google Drive
2. **Update metadata now**: Ensure metadata is complete before migration
3. **Remove duplicates**: Clean up before migration
4. **Test in pre-prod**: Validate documents work in SharePoint
5. **Report issues early**: File bugs during beta period

## Getting Help

### Support Channels

**Slack**:
- Main channel: #hermes (check internal Slack for exact channel)
- Migration questions: Ask in Hermes channels
- Technical issues: File issues with Hermes team

**Confluence**:
- **Program Page**: https://hashicorp.atlassian.net/wiki/spaces/IND/pages/4191289346/Hermes+Program+Page
- Full documentation and weekly updates

**Jira**:
- File bugs and feature requests
- Track migration progress
- M1, M2, M3 milestone tracking

### Team Contacts

**Product Lead**: Miles Harrison
**Engineering Leads**: Shyamendra Singh, Swati Jahagirdar
**Tech Lead**: Sharad Jaiswal

**For Issues**:
1. Check Confluence documentation first
2. Search Slack channels for similar issues
3. Post question in Hermes Slack channel
4. File Jira ticket for bugs/features
5. Escalate to engineering leads if urgent

## Additional Resources

### Official Links
- **Dashboard**: https://hermes-sharepoint.hashicorp.services/dashboard
- **Confluence**: https://hashicorp.atlassian.net/wiki/spaces/IND/pages/4191289346/Hermes+Program+Page
- **Technical Docs**: Check internal documentation (Google Doc link in Confluence)

### Related Systems
- **SharePoint**: IBM SharePoint platform
- **W3ID**: IBM SSO authentication
- **Blue Groups**: IBM group management
- **AccessHub**: Access control and permissions
- **Algolia**: Search platform
- **Datadog**: Monitoring and APM

### Related Skills
- `/google-docs` - Google Docs and Drive usage (legacy Hermes)
- `/developer` - HashiCorp Developer portal for public documentation
- `/github` - Version control for code (vs. Hermes for docs)

### Technical Details
- **Infrastructure**: AWS (hashidocs_prod account)
- **Deployment**: Terraform Cloud + GitHub Actions
- **Monitoring**: Datadog APM
- **Search**: Algolia
- **Database**: RDS (via VPC peering)

---

*This skill is maintained for HashiCorp internal use. For updates or corrections, please contribute to the [hashicorp-agent-skills repository](https://github.com/hashicorp/hashicorp-agent-skills) or contact the Hermes team.*

**Note**: Hermes is currently in beta and actively migrating from Google Workspace to SharePoint. Some features may change as the migration progresses. Check the Confluence page for the latest status updates.
