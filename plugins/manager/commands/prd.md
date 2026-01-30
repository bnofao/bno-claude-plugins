---
description: Create or update a product requirements document
argument-hint: [action] [name]
allowed-tools: Read, Write, Edit, Glob, Bash(gh:*)
---

<!--
Usage:
  /manager:prd create my-feature     - Create new PRD from template
  /manager:prd update my-feature     - Update existing PRD
  /manager:prd list                  - List all PRDs
-->

Manage product requirements documents for this project.

**Arguments received:**
- Action: $1 (create, update, or list)
- Name: $2 (PRD name, kebab-case)

**Configuration:**
- PRD directory: `docs/planning/<name>/prd.md`
- Template: @${CLAUDE_PLUGIN_ROOT}/templates/prd-template.md

**Instructions:**

1. If action is "list" or no arguments provided:
   - Search for PRDs: Use Glob to find `docs/planning/*/prd.md`
   - List all PRDs with their status (from frontmatter or first heading)
   - Show file path and last modified date

2. If action is "create":
   - Verify PRD doesn't already exist at `docs/planning/$2/prd.md`
   - If it exists, ask user to use "update" instead
   - Check if brainstorm exists at `docs/planning/$2/brainstorm.md`:
     - If brainstorm exists:
       - Read the brainstorm content
       - Ask user: "A brainstorm exists for this feature. Would you like to use it as context for the PRD?"
       - If yes: extract key insights to pre-fill PRD sections using this mapping:
         | Brainstorm Section | PRD Section |
         |-------------------|-------------|
         | Problem Statement | Problem Statement |
         | User Insights | User Experience context |
         | Selected Approach | Overview / Features |
         | In Scope (MVP) | Features P0 |
         | Out of Scope | Non-Goals |
         | Success Criteria | Success Metrics |
         | Risks | Technical Constraints |
       - If no: continue without using brainstorm
     - If brainstorm doesn't exist:
       - Ask user: "No brainstorm exists for this feature. Would you like to brainstorm first?"
       - If yes: suggest running `/manager:brainstorm $2` and stop here
       - If no: continue with normal PRD creation
   - Create directory `docs/planning/$2/` if it doesn't exist
   - Copy template to `docs/planning/$2/prd.md`
   - Replace `[Feature Name]` with formatted version of $2
   - Set Created and Last Updated dates to today
   - Ask user to provide:
     - Overview (2-3 sentences)
     - Problem statement
     - Primary goals
   - Help user fill in each section interactively

3. If action is "update":
   - Read existing PRD at `docs/planning/$2/prd.md`
   - Ask user what they want to update:
     - Add/modify user stories
     - Update acceptance criteria
     - Add technical notes
     - Change status
     - Other sections
   - Make the requested changes
   - Update "Last Updated" date

**Output format:**
After creating/updating, show:
- PRD location
- Current status
- Number of user stories
- Next steps:
  - Create TRD for technical specs: `/manager:trd create {name}`
  - Create epic: `/manager:epic create "Title" --prd={name}`
  - Parse to issues: `/manager:parse {name} --epic=N`
