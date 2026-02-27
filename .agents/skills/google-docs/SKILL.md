---
name: google-docs
description: Guidance for using Google Docs and Google Drive at HashiCorp for collaboration, file sharing, and document management. Use when working with Google Workspace docs, sheets, slides, or shared drives.
---

# Google Docs & Drive - HashiCorp Usage

A comprehensive guide to using Google Docs and Google Drive at HashiCorp for collaboration and document management.

## What is Google Docs & Drive?

Google Docs and Google Drive are HashiCorp's document collaboration and file storage platforms provided through IBM's Google Workspace integration.

**Key Features:**
- **Google Docs**: Real-time collaborative document editing
- **Google Drive**: Cloud file storage and sharing
- **Google Sheets**: Spreadsheet collaboration
- **Google Slides**: Presentation creation and sharing
- **Shared Drives**: Team-based file organization
- **Cloud Search**: Search across all Google Workspace content
- **Access Controls**: Fine-grained sharing permissions
- **Version History**: Track document changes over time

**Primary Use Cases:**
- Collaborative document writing and editing
- Team file sharing and organization
- Spreadsheet data analysis and tracking
- Presentation creation and delivery
- Real-time collaboration with multiple editors
- Document versioning and history tracking
- Cross-team knowledge sharing

## When to Use Google Docs & Drive

Use Google Docs/Drive when you need to:

- **Collaborate in real-time**: Multiple people editing simultaneously
- **Share documents across teams**: Easy sharing via links
- **Track document history**: See who changed what and when
- **Store team files**: Centralized file repository
- **Create presentations**: Slides for meetings and demos
- **Manage spreadsheets**: Data tracking and analysis
- **Quick document creation**: No local software needed
- **Mobile access**: Edit from anywhere, any device

**When to use alternatives:**
- **Hermes**: For RFCs, PRDs, and documents requiring approval workflows (migrating to SharePoint)
- **Confluence**: For team wikis and structured knowledge bases
- **GitHub**: For code documentation and technical specs
- **Local files**: For sensitive data or offline work

**Who uses Google Docs/Drive:**
- Everyone at HashiCorp for day-to-day collaboration
- Product managers for planning documents
- Engineering teams for design docs
- Marketing teams for content creation
- Sales teams for presentations and tracking

## Accessing Google Docs & Drive

### Google Drive

**URL**: https://drive.google.com/drive/u/0/

**Authentication**: IBM Google Workspace (via W3ID SSO)

**Access levels**:
- **My Drive**: Personal file storage
- **Shared Drives**: Team-based shared storage
- **Shared with Me**: Files others have shared with you
- **Recent**: Recently accessed files
- **Starred**: Files you've marked as important

### Cloud Search

**URL**: https://cloudsearch.google.com/cloudsearch

**What it does**:
- Search across all Google Workspace content
- Find documents, emails, calendar events
- Filter by file type, owner, date
- Search within shared drives
- Preview results without opening

**Best for**:
- Finding documents when you don't know location
- Discovering content across shared drives
- Searching by content, not just filename
- Locating files shared with you

### Key Folders

**RFCs**: https://drive.google.com/drive/u/0/folders/0AJA7q1x_uaLUUk9PVA

**PRFAQs**: https://drive.google.com/drive/u/0/folders/0AFh_9LDyoTsoUk9PVA

**Shared Drives**: https://drive.google.com/drive/u/0/shared-drives

## Common Workflows

### 1. Creating and Sharing a Document

**Goal**: Create a document and share it with your team.

**Steps**:
1. Navigate to https://drive.google.com
2. Click "New" → "Google Docs" (or Sheets, Slides)
3. Document opens in new tab
4. Click "Share" button (top right)
5. Add people or groups:
   - **Specific people**: Enter email addresses
   - **Groups**: Use distribution lists
   - **Anyone with link**: For broader sharing
6. Set permission level:
   - **Viewer**: Can only view
   - **Commenter**: Can add comments
   - **Editor**: Can edit content
7. Optional: Add message explaining the share
8. Click "Send" or "Copy link"

**Sharing best practices**:
- Use "Commenter" for review cycles
- Use "Editor" only for active collaborators
- Use groups instead of individual emails
- Set link sharing to "Restricted" for sensitive docs
- Add context when sharing via email

### 2. Collaborating in Real-Time

**Goal**: Work on a document simultaneously with teammates.

**Steps**:
1. Share document with teammates as "Editor"
2. All editors open the document
3. See collaborators' cursors in real-time
4. Use comments for discussions:
   - Highlight text
   - Click "Comment" or Cmd/Ctrl+Alt+M
   - Tag teammates with @ mention
   - Resolve comments when addressed
5. Use "Suggesting" mode for tracked changes:
   - Change mode from "Editing" to "Suggesting"
   - Edits appear as suggestions
   - Owner accepts or rejects changes
6. Use built-in chat (bottom right icon) for quick questions

**Collaboration tips**:
- Announce major edits in chat
- Use comments for questions, not chat
- Resolve comments when done
- Use version history if conflicts occur
- Turn on notifications for important docs

### 3. Organizing Files in Shared Drives

**Goal**: Properly organize team files in a Shared Drive.

**Steps**:
1. Access your team's Shared Drive
2. Create folder structure:
   - By project (e.g., "Q1 2026 Planning")
   - By document type (e.g., "RFCs", "Meeting Notes")
   - By status (e.g., "Draft", "Approved", "Archived")
3. Move files to appropriate folders:
   - Right-click file → "Move to"
   - Select Shared Drive and folder
   - Files can be in multiple folders via shortcuts
4. Use naming conventions:
   - Include dates: "2026-01-16-weekly-sync.doc"
   - Include status: "[DRAFT] Product Requirements"
   - Include owner: "alice-design-proposal.doc"
5. Create shortcuts to important files:
   - Right-click → "Add shortcut to Drive"
   - Shortcut appears in multiple locations

**Organization best practices**:
- Agree on folder structure with team
- Archive old files regularly
- Use consistent naming conventions
- Don't create deeply nested folders (3-4 levels max)
- Use shortcuts instead of duplicating files

### 4. Using Version History

**Goal**: Review document changes and restore previous versions.

**Steps**:
1. Open document
2. Click "File" → "Version history" → "See version history"
3. Right panel shows all versions:
   - Timestamps
   - Editor names
   - Named versions
4. Click any version to preview
5. Compare versions:
   - Use timeline slider
   - Changes highlighted
6. Restore a previous version:
   - Click "Restore this version"
   - Creates new version (doesn't delete history)
7. Name important versions:
   - Click "..." → "Name this version"
   - E.g., "Final Draft Before Review"

**Version history uses**:
- Undo accidental deletions
- See who made specific changes
- Restore document after unwanted edits
- Track evolution of ideas
- Compare different approaches

### 5. Searching for Documents

**Goal**: Find a document when you don't know where it is.

**Using Drive Search**:
1. In Google Drive, use search bar (top)
2. Enter keywords from document content or title
3. Use search filters:
   - Type (Docs, Sheets, Slides, PDF)
   - Owner
   - Location (My Drive, Shared Drives, Shared with me)
   - Date modified
4. Click result to open

**Using Cloud Search**:
1. Navigate to https://cloudsearch.google.com/cloudsearch
2. Enter search query
3. More powerful filters:
   - Search inside document content
   - Search across all Google Workspace
   - Filter by shared drive
   - Filter by who shared with you
4. Preview documents without opening
5. Click to open in Google Docs/Drive

**Search tips**:
- Use quotes for exact phrases: "Q4 planning"
- Search by owner: owner:alice@hashicorp.com
- Search by date: after:2025-12-01
- Search in specific drive: location:vault-team
- Use file type: type:spreadsheet

### 6. Converting Between Formats

**Goal**: Convert documents between Google formats and Microsoft Office.

**Google → Microsoft Office**:
1. Open document in Google Docs/Sheets/Slides
2. Click "File" → "Download"
3. Select format:
   - Microsoft Word (.docx)
   - Microsoft Excel (.xlsx)
   - Microsoft PowerPoint (.pptx)
   - PDF
4. File downloads to your computer

**Microsoft Office → Google**:
1. Upload file to Google Drive
2. Right-click file → "Open with" → "Google Docs/Sheets/Slides"
3. Document opens in Google format
4. Save as Google format:
   - File → "Save as Google Docs/Sheets/Slides"
5. Original file preserved, new Google file created

**Considerations**:
- Complex formatting may not convert perfectly
- Macros don't transfer from Excel to Sheets
- Comments may not preserve perfectly
- Review converted document for issues
- Keep original if using complex features

### 7. Working with Templates

**Goal**: Use templates for consistent document formatting.

**Using Google Templates**:
1. In Google Docs/Sheets/Slides
2. Click "Template Gallery" (top right)
3. Browse categories:
   - Resumes, reports, proposals
   - Project tracking, schedules
   - Presentations, pitches
4. Click template to create new document
5. Customize with your content

**Creating Custom Templates**:
1. Create a document with desired formatting
2. Save to Shared Drive in "Templates" folder
3. Team members duplicate when needed:
   - Right-click → "Make a copy"
   - Rename copy
   - Edit as needed

**HashiCorp-Specific Templates**:
- Check your team's Shared Drive for templates
- Common templates: meeting notes, planning docs, status reports
- For RFCs/PRDs, check RFC and PRFAQ folders or use Hermes templates

### 8. Managing Permissions

**Goal**: Control who can access and edit your documents.

**Changing Permissions**:
1. Open document or file
2. Click "Share" button
3. For existing users:
   - Click dropdown next to name
   - Change role (Viewer, Commenter, Editor)
   - Or click "Remove" to revoke access
4. For link sharing:
   - Click "Change to anyone with the link"
   - Or "Restricted" for specific people only
5. Advanced settings:
   - Prevent editors from changing access
   - Disable download/print/copy
   - Set expiration date for access

**Permission levels explained**:
- **Viewer**: Read-only, can download/print (unless disabled)
- **Commenter**: Can view and add comments, cannot edit
- **Editor**: Full edit access, can share with others (unless restricted)

**Security best practices**:
- Default to "Restricted" for sensitive documents
- Use "Commenter" during review periods
- Remove access when collaboration ends
- Check permissions regularly
- Use shared drives for team content (not individual sharing)

## Troubleshooting

### Cannot Access Document

**Problem**: "You need permission" error when opening document.

**Solutions**:
1. **Request access**: Click "Request access" button
2. **Check sharing link**: Ensure link is correct and complete
3. **Use correct account**: Ensure logged in with HashiCorp IBM account
4. **Check expiration**: Access may have expired
5. **Contact owner**: Ask document owner to grant access

### Document Not Appearing in Drive

**Problem**: Can't find a document you created or were shared.

**Solutions**:
1. **Check "Shared with me"**: Document may not be in your drive
2. **Use search**: Search by title or content keywords
3. **Check Shared Drives**: May be in team drive, not personal
4. **Check trash**: May have been accidentally deleted
5. **Check filters**: Remove any active filters in Drive view

### Synchronization Issues

**Problem**: Changes not appearing for other collaborators.

**Solutions**:
1. **Check connection**: Ensure stable internet connection
2. **Refresh page**: Reload document (Cmd/Ctrl+R)
3. **Clear cache**: Hard refresh (Cmd+Shift+R or Ctrl+F5)
4. **Check browser**: Try different browser
5. **Check offline mode**: Ensure not in offline-only mode

### Version History Missing

**Problem**: Can't see version history or specific versions.

**Solutions**:
1. **Check permissions**: Need at least "Commenter" access
2. **Wait for propagation**: Changes may take moment to appear
3. **Check named versions**: May only see explicitly named versions
4. **Use "See full history"**: Shows all versions, not just major
5. **Contact support**: If versions actually deleted (rare)

### Formatting Issues

**Problem**: Document formatting looks wrong after conversion.

**Solutions**:
1. **Use Google format**: Work in Google Docs, not uploaded Word files
2. **Simplify formatting**: Avoid complex Word features
3. **Review after conversion**: Check and fix formatting issues
4. **Use PDF**: For preserving exact formatting
5. **Manual reformatting**: Some elements require manual fixes

## Best Practices

### For Document Creation

1. **Start with templates**: Use existing templates for consistency
2. **Use clear titles**: Include date, topic, and status if relevant
3. **Add document description**: Use Drive description field
4. **Set up sharing early**: Share with team from the start
5. **Use comments liberally**: Better than email for feedback

### For Collaboration

1. **Use Suggesting mode**: For review cycles and major edits
2. **Resolve comments**: Mark addressed comments as resolved
3. **@ mention teammates**: Get their attention on specific points
4. **Name versions**: Mark milestones in version history
5. **Communicate major changes**: Let team know about big edits

### For Organization

1. **Use Shared Drives**: Not personal drives for team content
2. **Follow naming conventions**: Consistent file naming
3. **Archive old files**: Move to "Archive" folder, don't delete
4. **Use folders wisely**: 3-4 levels max, clear structure
5. **Create shortcuts**: Instead of duplicating files

### For Security

1. **Default to Restricted**: Only share with specific people
2. **Remove access when done**: Clean up permissions regularly
3. **Don't share sensitive data**: Use appropriate tools for secrets
4. **Check link sharing**: Ensure not accidentally public
5. **Use groups**: Easier to manage than individual shares

### For Search & Discovery

1. **Use descriptive titles**: Make files findable
2. **Add descriptions**: Use Drive description field
3. **Use Cloud Search**: More powerful than Drive search
4. **Star important files**: Quick access to key documents
5. **Keep files organized**: Easier to find later

## Integration with Other HashiCorp Tools

### Hermes
- **Legacy**: Hermes originally built on Google Drive
- **Migration**: Now moving to SharePoint
- **Coexistence**: Both may be used during transition period
- **Use cases**: Use Hermes for RFCs/PRDs, Google Docs for other collaboration

### Confluence
- **Different purpose**: Confluence for wikis, Google Docs for collaboration
- **Link between**: Reference Google Docs in Confluence pages
- **Export**: Can export Confluence pages to Google Docs

### Slack
- **Share links**: Post Google Doc links in Slack channels
- **Preview**: Slack shows preview of Google Docs
- **Notifications**: Get notified of shares via Slack
- **Integration**: Google Drive app available in Slack

### Calendar (Google Calendar)
- **Attach docs**: Add Google Docs to calendar events
- **Meeting notes**: Create doc for meeting notes
- **Quick access**: Access docs directly from calendar

## Additional Resources

### Official Links
- **Google Drive**: https://drive.google.com/drive/u/0/
- **Cloud Search**: https://cloudsearch.google.com/cloudsearch
- **Shared Drives**: https://drive.google.com/drive/u/0/shared-drives
- **RFCs Folder**: https://drive.google.com/drive/u/0/folders/0AJA7q1x_uaLUUk9PVA
- **PRFAQs Folder**: https://drive.google.com/drive/u/0/folders/0AFh_9LDyoTsoUk9PVA

### Google Workspace Help
- **Docs Help**: https://support.google.com/docs
- **Drive Help**: https://support.google.com/drive
- **Sheets Help**: https://support.google.com/sheets
- **Slides Help**: https://support.google.com/slides

### Related Skills
- `/hermes` - Document management with approval workflows
- `/developer` - HashiCorp Developer portal
- `/github` - Code and technical documentation

### Keyboard Shortcuts

**Document Navigation**:
- **Cmd/Ctrl + F**: Find in document
- **Cmd/Ctrl + H**: Find and replace
- **Cmd/Ctrl + P**: Print
- **Cmd/Ctrl + K**: Insert link

**Formatting**:
- **Cmd/Ctrl + B**: Bold
- **Cmd/Ctrl + I**: Italic
- **Cmd/Ctrl + U**: Underline
- **Cmd/Ctrl + Alt + M**: Insert comment

**Collaboration**:
- **Cmd/Ctrl + Alt + M**: Add comment
- **Cmd/Ctrl + Alt + Shift + A**: Open comment panel
- **Cmd/Ctrl + Enter**: Send comment
- **E**: Escape out of comment

**Version Control**:
- **Cmd/Ctrl + Alt + Shift + H**: Open version history
- **Cmd/Ctrl + Z**: Undo
- **Cmd/Ctrl + Shift + Z**: Redo

---

*This skill is maintained for HashiCorp internal use. For updates or corrections, please contribute to the [hashicorp-agent-skills repository](https://github.com/hashicorp/hashicorp-agent-skills).*

**Note**: Google Workspace at HashiCorp is provided through IBM integration. For account issues or access problems, contact IBM IT support.
