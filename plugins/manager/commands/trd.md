---
description: Create or update a technical requirements document
argument-hint: [action] [name]
allowed-tools: Read, Write, Edit, Glob, Bash(gh:*)
---

<!--
Usage:
  /manager:trd create my-feature     - Create new TRD from template
  /manager:trd update my-feature     - Update existing TRD
  /manager:trd list                  - List all TRDs
-->

Manage technical requirements documents for this project.

**Arguments received:**
- Action: $1 (create, update, or list)
- Name: $2 (TRD name, kebab-case)

**Configuration:**
- TRD directory: `docs/planning/<name>/trd.md`
- Template: @${CLAUDE_PLUGIN_ROOT}/templates/trd-template.md

**Instructions:**

1. If action is "list" or no arguments provided:
   - Search for TRDs: Use Glob to find `docs/planning/*/trd.md`
   - List all TRDs with their status (from frontmatter or first heading)
   - Show file path and last modified date

2. If action is "create":
   - Verify TRD doesn't already exist at `docs/planning/$2/trd.md`
   - If it exists, ask user to use "update" instead
   - Create directory `docs/planning/$2/` if it doesn't exist
   - Copy template to `docs/planning/$2/trd.md`
   - Replace `[Feature Name]` with formatted version of $2
   - Set Created and Last Updated dates to today
   - Check if PRD exists at `docs/planning/$2/prd.md`:
     - If yes, link it in Related PRD field and extract context
     - If no, leave Related PRD as N/A
   - Ask user to provide:
     - Technical overview (2-3 sentences)
     - Primary architecture approach
     - Key technical constraints
   - Help user fill in each section interactively

3. If action is "update":
   - Read existing TRD at `docs/planning/$2/trd.md`
   - Ask user what they want to update:
     - Architecture section
     - API specification
     - Database design
     - Security considerations
     - Performance requirements
     - Other sections
   - Make the requested changes
   - Update "Last Updated" date

**Output format:**
After creating/updating, show:
- TRD location
- Current status
- Related PRD (if linked)
- Next steps (review with team, create implementation issues)
