---
description: Manage GitHub epics (tracking issues)
argument-hint: [action] [args]
allowed-tools: Read, Write, Bash(gh:*)
---

<!--
Usage:
  /manager:epic create "Title" [--prd=name] [--project=P] [--local]  - Create new epic
  /manager:epic update <N> [action] [args]             - Update epic
  /manager:epic list [--status=open|closed|all]        - List epics
  /manager:epic view <N>                               - View epic details

  Backward compatible:
  /manager:epic "Title"                                - Same as create "Title"

  Local storage:
  /manager:epic create "Title" --prd=name --local      - Create local draft (not on GitHub)
  Storage path: docs/planning/<prd>/epics/<filename>.md
-->

Manage GitHub epics (tracking issues) with create, update, list, and view actions.

**Arguments received:** $ARGUMENTS

**Template:** @${CLAUDE_PLUGIN_ROOT}/templates/epic-template.md

---

## Action: create

Create a new epic as a GitHub tracking issue or local draft.

**Syntax:**
```
/manager:epic create "Title" [--prd=name] [--trd] [--project=P] [--local]
/manager:epic "Title" [--prd=name]            # Shorthand (backward compatible)
```

**Options:**
- `--prd=name` - Link to PRD (required for --local)
- `--trd` - Also link to TRD if it exists at `docs/planning/<prd>/trd.md`
- `--project=P` - Add epic to GitHub Project number P after creation
- `--local` - Create as local draft instead of GitHub issue

**Local Storage Path:** `docs/planning/<prd>/epics/<slug>.md`

**Template:** @${CLAUDE_PLUGIN_ROOT}/templates/local-epic-template.md (for local drafts)

**Instructions:**

1. Parse arguments:
   - Extract title (everything before flags or entire string)
   - Extract --prd=name if provided
   - Extract --local flag if provided
   - If first argument is not a known action (create/update/list/view), treat entire input as title for create

2. **If --local flag is set:**

   a) Verify --prd is provided (required for local storage)
      - If not provided, ask user for PRD name

   b) Create directory if needed:
      ```bash
      mkdir -p docs/planning/<prd>/epics
      ```

   c) Generate filename from title:
      - Convert to lowercase, replace spaces with hyphens
      - Example: "User Authentication" → `user-authentication.md`

   d) Create local file using local-epic-template.md:
      - File: `docs/planning/<prd>/epics/<slug>.md`
      - Populate YAML frontmatter:
        - github_number: null (draft)
        - title: `[Epic] {title}`
        - status: draft
        - prd: <prd-name>
        - labels: [epic]
        - created: today's date
        - updated: today's date
      - Populate body from PRD or user input

   e) Report:
      ```
      Created local epic draft:
      File: docs/planning/<prd>/epics/<slug>.md
      Status: draft

      Next steps:
      - Edit the file to add details
      - Use '/manager:sync --push <prd>' to create on GitHub
      ```

3. **If --local flag is NOT set (GitHub mode):**

   a) Check prerequisites:
      - Verify `gh` CLI is available: `gh --version`
      - Verify authenticated: `gh auth status`
      - If not authenticated, tell user to run `gh auth login`

   b) If PRD specified:
      - Read PRD from `docs/planning/<prd>/prd.md`
      - Extract overview for epic description
      - Extract user stories for task list placeholders

   c) Prepare epic content:
      - Title format: `[Epic] {title}`
      - Body based on template:
        - Overview from PRD or ask user
        - Source PRD link (if applicable)
        - Empty task list (will be populated as issues are created)
        - Epic-level acceptance criteria

   d) Create the epic:
      ```bash
      gh issue create --title "[Epic] {title}" --body "{body}" --label "epic"
      ```

   e) Capture issue number and URL from output

   f) If --project specified:
      - Add to project:
        ```bash
        gh project item-add <project-N> --owner @me --url <issue-url>
        ```
      - Report project addition

   g) Report:
      - Show epic URL
      - If added to project, show project link
      - Suggest next steps:
        - Use `/manager:parse` to generate issues from PRD
        - Use `/manager:issue` to manually add issues
        - Use `/manager:epic update` to modify the epic
        - Use `/manager:project set-status` to update project status

**Labels to apply (GitHub mode):**
- `epic` (create if doesn't exist)
- `type:feature` if this is a feature epic

---

## Action: update

Update an existing epic on GitHub.

**Syntax:**
```
/manager:epic update <N>                       # Interactive update menu
/manager:epic update <N> add-issue <issue-N>   # Add issue to task list
/manager:epic update <N> remove-issue <issue-N># Remove issue from task list
/manager:epic update <N> close                 # Close the epic
/manager:epic update <N> reopen                # Reopen the epic
```

**Instructions:**

1. Validate epic exists:
   ```bash
   gh issue view <N> --json title,body,state,labels
   ```
   - Verify it has "epic" label or title starts with "[Epic]"
   - If not an epic, inform user and suggest correct command

2. If no sub-action specified, show interactive menu:
   - Current epic status and progress
   - List of linked issues with their status
   - Available actions:
     a) Add issue to epic
     b) Remove issue from epic
     c) Update description
     d) Close epic
     e) Reopen epic
   - Ask user which action to perform

3. For "add-issue" sub-action:
   - Verify issue exists: `gh issue view <issue-N>`
   - Fetch current epic body
   - Add task list item: `- [ ] #<issue-N> {issue title}`
   - Update epic body: `gh issue edit <N> --body "{new_body}"`
   - Confirm addition

4. For "remove-issue" sub-action:
   - Fetch current epic body
   - Remove line containing `#<issue-N>` from task list
   - Update epic body
   - Confirm removal

5. For "close" sub-action:
   - Check all task list items are complete
   - If incomplete tasks exist, warn user and ask for confirmation
   - Close epic: `gh issue close <N>`

6. For "reopen" sub-action:
   - Reopen epic: `gh issue reopen <N>`

7. After any update:
   - Show updated epic summary
   - Display progress (X of Y issues complete)
   - Show epic URL

---

## Action: list

List epics from the repository.

**Syntax:**
```
/manager:epic list                             # List open epics (default)
/manager:epic list --status=open               # List open epics
/manager:epic list --status=closed             # List closed epics
/manager:epic list --status=all                # List all epics
```

**Instructions:**

1. Parse --status flag (default: open)

2. Query GitHub for epics:
   ```bash
   gh issue list --label "epic" --state <status> --json number,title,state,body
   ```

3. For each epic, calculate progress:
   - Parse task list from body
   - Count total items and checked items
   - Calculate percentage

4. Display summary table:
   ```
   | #  | Epic Title              | Status | Progress    |
   |----|-------------------------|--------|-------------|
   | 42 | [Epic] User Auth        | open   | 3/5 (60%)   |
   | 38 | [Epic] Dashboard        | closed | 8/8 (100%)  |
   ```

5. Show total counts and suggest actions

---

## Action: view

View detailed information about a specific epic.

**Syntax:**
```
/manager:epic view <N>
```

**Instructions:**

1. Fetch epic details:
   ```bash
   gh issue view <N> --json number,title,body,state,labels,createdAt,updatedAt,url
   ```

2. Verify it's an epic (has "epic" label or title starts with "[Epic]")

3. Parse task list from body and fetch each linked issue:
   ```bash
   gh issue view <issue-N> --json number,title,state,labels,assignees
   ```

4. Display detailed report:
   ```
   Epic #42: [Epic] User Authentication
   URL: https://github.com/owner/repo/issues/42
   Status: open
   Created: 2024-01-15
   Progress: 3/5 (60%)

   Issues:
   | #  | Title                             | Status | Assignee | Priority |
   |----|-----------------------------------|--------|----------|----------|
   | 45 | As a user, I want to login        | closed | @alice   | high     |
   | 46 | As a user, I want to logout       | open   | @bob     | medium   |
   | 47 | As a admin, I want to manage users| open   | -        | high     |

   Description:
   [Epic description from body]
   ```

5. Provide insights:
   - Identify blockers (high priority open issues)
   - Flag unassigned issues
   - Note stale issues (no updates in 7+ days)
