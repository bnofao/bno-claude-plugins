---
description: Parse a PRD or TRD and generate GitHub issues
argument-hint: [prd-name] [--epic=number] [--trd] [--dry-run]
allowed-tools: Read, Write, Bash(gh:*)
---

<!--
Usage:
  /manager:parse user-auth                     - Parse PRD and preview issues
  /manager:parse user-auth --epic=42           - Parse and link to epic #42
  /manager:parse user-auth --trd               - Parse TRD for technical issues
  /manager:parse user-auth --trd --epic=42     - Parse TRD and link to epic
  /manager:parse user-auth --dry-run           - Preview only, don't create
-->

Parse a PRD or TRD document and generate structured GitHub issues.

**Arguments received:** $ARGUMENTS

---

## Mode: PRD Parsing (Default)

Generate user story issues from a PRD.

**Instructions:**

1. Parse arguments:
   - PRD name: first argument (required)
   - Epic number: from --epic=N if provided
   - Dry run: true if --dry-run flag present

2. Read the PRD:
   - Location: `docs/planning/{prd-name}/prd.md`
   - If not found, list available PRDs and ask user to specify

3. Extract features from PRD:
   - Find Section 5 "Features and Requirements"
   - Parse priority sections:
     - `### Must-Have Features (P0)` → priority: high
     - `### Should-Have Features (P1)` → priority: medium
     - `### Nice-to-Have Features (P2)` → priority: low
   - For each feature block (`#### Feature N: [Name]`), extract:
     - Feature name from heading
     - Description from `**Description:**` field
     - User Story from `**User Story:**` field (As a... I want to... So that...)
     - Acceptance Criteria from `**Acceptance Criteria:**` checklist
     - Dependencies from `**Dependencies:**` field

4. Generate issue previews:
   For each feature, prepare:
   - **Title**: "As a {user}, I want to {action}" (max 80 chars)
     - If user story is missing, use: "{Feature Name}"
   - **Body**:
     ```
     ## Context
     From PRD: {prd-name}
     Feature: {feature-name}
     Priority: {P0|P1|P2}

     ## Description
     {description}

     ## User Story
     **As a** {user}
     **I want to** {action}
     **So that** {benefit}

     ## Acceptance Criteria
     - [ ] {criterion 1}
     - [ ] {criterion 2}
     ...

     ## Dependencies
     {dependencies if any}

     ## Related
     - PRD: docs/planning/{prd-name}/prd.md
     - Epic: #{epic-number} (if provided)
     ```
   - **Labels**: type:feature, priority:{high|medium|low based on P0/P1/P2}

5. Show preview to user:
   - List all issues that will be created
   - Show title and labels for each
   - Ask for confirmation before creating
   - Allow user to:
     a) Create all issues
     b) Select specific issues to create
     c) Edit an issue before creating
     d) Cancel

6. If not dry-run and user confirms:
   - Create each issue using `gh issue create`
   - Capture issue numbers
   - If epic specified, add each issue to epic's task list
   - Track created issues

7. Report results:
   - List all created issues with URLs
   - Show epic progress if linked
   - Suggest next steps:
     - Review created issues
     - Assign issues to team members
     - Add additional details
   - If TRD exists, suggest: `/manager:parse {prd-name} --trd` for technical issues

---

## Mode: TRD Parsing (--trd flag)

Generate technical implementation issues from a TRD.

**Instructions:**

1. Parse arguments:
   - PRD/TRD name: first argument (required)
   - Epic number: from --epic=N if provided
   - Dry run: true if --dry-run flag present

2. Read the TRD:
   - Location: `docs/planning/{name}/trd.md`
   - If not found, inform user and suggest creating one with `/manager:trd create {name}`

3. Extract technical items from TRD sections:

   **From Section 3 (API Specification):**
   - For each endpoint defined (`#### METHOD /path`):
     - Generate issue: "Implement {METHOD} {path} endpoint"
     - Type: task
     - Include request/response specs in body
     - Include error codes

   **From Section 4 (Database Design):**
   - For each new table:
     - Generate issue: "Create {table_name} database table"
     - Type: task
     - Include schema in body
   - For migrations:
     - Generate issue: "Create database migration for {feature}"
     - Type: task

   **From Section 5 (Security):**
   - For authentication/authorization requirements:
     - Generate issue: "Implement {auth feature}"
     - Type: task
     - Priority: high

   **From Section 8 (Dependencies):**
   - For infrastructure changes:
     - Generate issue: "Set up {infrastructure item}"
     - Type: task

   **From Section 9 (Testing Strategy):**
   - For load testing requirements:
     - Generate issue: "Create load tests for {feature}"
     - Type: task

   **From Section 10 (Rollout Plan):**
   - For feature flags:
     - Generate issue: "Implement feature flag for {feature}"
     - Type: task

4. Generate issue previews:
   For each technical item, prepare:
   - **Title**: "{action} for {component}" (max 80 chars)
   - **Body**:
     ```
     ## Context
     From TRD: {name}
     Section: {section name}

     ## Technical Requirements
     {extracted requirements from TRD}

     ## Acceptance Criteria
     - [ ] Implementation matches TRD specification
     - [ ] Unit tests written
     - [ ] Integration tests pass
     - [ ] Code reviewed

     ## Related
     - TRD: docs/planning/{name}/trd.md
     - PRD: docs/planning/{name}/prd.md (if exists)
     - Epic: #{epic-number} (if provided)
     ```
   - **Labels**: type:task, priority:{based on section}

5. Show preview to user:
   - Group issues by TRD section (API, Database, Security, etc.)
   - Show title and labels for each
   - Ask for confirmation before creating
   - Allow user to:
     a) Create all issues
     b) Select specific sections/issues to create
     c) Edit an issue before creating
     d) Cancel

6. If not dry-run and user confirms:
   - Create each issue using `gh issue create`
   - Capture issue numbers
   - If epic specified, add each issue to epic's task list

7. Report results:
   - List all created issues by category:
     ```
     Created 8 technical issues:

     API (3):
     - #61: Implement POST /auth/login endpoint
     - #62: Implement POST /auth/logout endpoint
     - #63: Implement GET /auth/me endpoint

     Database (2):
     - #64: Create users table
     - #65: Create sessions table

     Infrastructure (2):
     - #66: Set up Redis for session storage
     - #67: Configure rate limiting

     Testing (1):
     - #68: Create load tests for auth endpoints
     ```
   - Show epic progress if linked
   - Suggest next steps:
     - Prioritize and assign issues
     - Set up dependencies between issues
