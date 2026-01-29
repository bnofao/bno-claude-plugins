---
description: Manage GitHub issues
argument-hint: [action] [args]
allowed-tools: Read, Write, Bash(gh:*)
---

<!--
Usage:
  /manager:issue create [--epic=N] [--priority=P] [--type=T] [--project=P] [--prd=name] [--local]
  /manager:issue update <N> [action] [args]                   - Update issue
  /manager:issue list [--epic=N] [--status=S] [--type=T]      - List issues
  /manager:issue view <N>                                     - View issue details

  Backward compatible:
  /manager:issue [--epic=N] [--priority=P]                    - Same as create

  Local storage:
  /manager:issue create --prd=name --local                    - Create local draft (not on GitHub)
  Storage path: docs/planning/<prd>/issues/<filename>.md
-->

Manage GitHub issues with create, update, list, and view actions.

**Arguments received:** $ARGUMENTS

**Template:** @${CLAUDE_PLUGIN_ROOT}/templates/issue-template.md

---

## Action: create

Create a new GitHub issue or local draft in user story format.

**Syntax:**
```
/manager:issue create [--epic=N] [--priority=P] [--type=T] [--project=P] [--prd=name] [--local]
/manager:issue [--epic=N] [--priority=P]                    # Shorthand (backward compatible)
```

**Options:**
- `--epic=N` - Link to epic issue number
- `--priority=high|medium|low` - Set priority (default: medium)
- `--type=feature|task|bug` - Issue type (default: feature)
- `--project=P` - Add issue to GitHub Project number P after creation
- `--prd=name` - PRD name (required for --local)
- `--local` - Create as local draft instead of GitHub issue

**Local Storage Path:** `docs/planning/<prd>/issues/<slug>.md`

**Template:** @${CLAUDE_PLUGIN_ROOT}/templates/local-issue-template.md (for local drafts)

**Instructions:**

1. Parse arguments:
   - Extract --epic=N if provided
   - Extract --priority=P if provided (default: medium)
   - Extract --type=T if provided (default: feature)
   - Extract --prd=name if provided
   - Extract --local flag if provided
   - If first argument is not a known action (create/update/list/view), treat as create

2. Gather issue details interactively:
   - Ask for type if not specified: feature, task, or bug

   **For feature/task types:**
   - Ask for user story components:
     - Who is the user? (e.g., "admin user", "customer", "developer")
     - What do they want to do? (the action)
     - Why? (the benefit)
   - Ask for acceptance criteria (at least 2-3 items)
   - Ask for any technical notes (optional)

   **For bug type:**
   - Ask for bug summary (short description)
   - Ask for steps to reproduce (numbered list)
   - Ask for expected behavior
   - Ask for actual behavior
   - Ask for environment details (optional)
   - Ask for any technical notes (optional)

3. **If --local flag is set:**

   a) Verify --prd is provided (required for local storage)
      - If not provided, ask user for PRD name

   b) Create directory if needed:
      ```bash
      mkdir -p docs/planning/<prd>/issues
      ```

   c) Generate filename from title:
      - For feature/task: slugify user story (e.g., `user-login.md`)
      - For bug: slugify summary (e.g., `login-fails-mobile.md`)

   d) Create local file using local-issue-template.md:
      - File: `docs/planning/<prd>/issues/<slug>.md`
      - Populate YAML frontmatter:
        - github_number: null (draft)
        - title: generated title
        - status: draft
        - type: feature|task|bug
        - priority: from --priority or medium
        - epic: from --epic or null
        - prd: <prd-name>
        - assignees: []
        - labels: []
        - created: today's date
        - updated: today's date
      - Populate body with gathered content

   e) Report:
      ```
      Created local issue draft:
      File: docs/planning/<prd>/issues/<slug>.md
      Type: feature|task|bug
      Status: draft

      Next steps:
      - Edit the file to refine details
      - Use '/manager:sync --push <prd>' to create on GitHub
      ```

4. **If --local flag is NOT set (GitHub mode):**

   a) Check prerequisites:
      - Verify `gh` CLI: `gh --version`
      - Verify authentication: `gh auth status`

   b) Generate issue content:

      **For feature/task:**
      - Title: "As a [user], I want to [action]" (truncated if too long)
      - Body using template structure:
        - Context section
        - Full user story
        - Acceptance criteria as checklist
        - Technical notes
        - Related section with epic link if provided

      **For bug:**
      - Title: "[Bug] {summary}" (truncated if too long)
      - Body using bug template structure:
        - Bug summary
        - Steps to reproduce (numbered)
        - Expected behavior
        - Actual behavior
        - Environment (if provided)
        - Technical notes
        - Related section with epic link if provided

   c) Determine labels:
      - Type label: `type:feature`, `type:task`, or `type:bug`
      - Priority label: `priority:$priority`

   d) Create the issue:
      ```bash
      gh issue create --title "{title}" --body "{body}" --label "{labels}"
      ```

   e) If epic specified:
      - Get the new issue number from output
      - Update epic to include this issue in task list:
        ```bash
        gh issue view <epic-N> --json body
        # Add task list item: - [ ] #<new-issue> {title}
        gh issue edit <epic-N> --body "{updated_body}"
        ```

   f) If --project specified:
      - Get issue URL from creation output
      - Add to project:
        ```bash
        gh project item-add <project-N> --owner @me --url <issue-url>
        ```
      - Report project addition

   g) Report results:
      - Show issue URL
      - Show applied labels
      - If linked to epic, show epic progress update
      - If added to project, show project link
      - Suggest next steps (including `/manager:project set-status`)

---

## Action: update

Update an existing GitHub issue.

**Syntax:**
```
/manager:issue update <N>                      # Interactive update menu
/manager:issue update <N> close                # Close the issue
/manager:issue update <N> reopen               # Reopen the issue
/manager:issue update <N> label add <label>    # Add label
/manager:issue update <N> label remove <label> # Remove label
/manager:issue update <N> assign <user>        # Assign to user
/manager:issue update <N> priority <P>         # Change priority (high|medium|low)
```

**Instructions:**

1. Fetch current issue state:
   ```bash
   gh issue view <N> --json title,body,state,labels,assignees
   ```

2. If no sub-action specified, show interactive menu:
   - Current issue details (title, state, labels, assignees)
   - Available actions:
     a) Edit title
     b) Edit description
     c) Add/remove labels
     d) Assign/unassign users
     e) Change priority
     f) Close issue
     g) Reopen issue
   - Ask user which action to perform

3. For "close" sub-action:
   ```bash
   gh issue close <N>
   ```

4. For "reopen" sub-action:
   ```bash
   gh issue reopen <N>
   ```

5. For "label add" sub-action:
   ```bash
   gh issue edit <N> --add-label "<label>"
   ```

6. For "label remove" sub-action:
   ```bash
   gh issue edit <N> --remove-label "<label>"
   ```

7. For "assign" sub-action:
   ```bash
   gh issue edit <N> --add-assignee "<user>"
   ```

8. For "priority" sub-action:
   - Remove existing priority labels:
     ```bash
     gh issue edit <N> --remove-label "priority:high,priority:medium,priority:low"
     ```
   - Add new priority label:
     ```bash
     gh issue edit <N> --add-label "priority:<P>"
     ```

9. For title/description edits (interactive):
   - Show current content
   - Ask for new content
   - Update:
     ```bash
     gh issue edit <N> --title "{new}" --body "{new}"
     ```

10. After any update:
    - Show updated issue summary
    - Show issue URL

---

## Action: list

List issues from the repository.

**Syntax:**
```
/manager:issue list                            # List open issues (default)
/manager:issue list --epic=N                   # List issues linked to epic #N
/manager:issue list --status=open|closed|all   # Filter by status
/manager:issue list --type=feature|task|bug    # Filter by type
```

**Instructions:**

1. Parse filter flags:
   - --epic=N: Filter to issues in specific epic
   - --status: open (default), closed, or all
   - --type: feature, task, or bug

2. Query GitHub:
   ```bash
   gh issue list --state <status> --json number,title,state,labels,assignees
   ```

   If --type specified, add label filter:
   ```bash
   gh issue list --state <status> --label "type:<type>" --json number,title,state,labels,assignees
   ```

3. If --epic specified:
   - Fetch epic body: `gh issue view <N> --json body`
   - Parse task list to get issue numbers
   - Filter results to only those issues

4. Display results:
   ```
   | #  | Title                              | Status | Type    | Assignee | Priority |
   |----|----------------------------------- |--------|---------|----------|----------|
   | 55 | As a user, I want to login         | open   | feature | @alice   | high     |
   | 56 | [Bug] Login fails on mobile        | open   | bug     | -        | high     |
   | 57 | Set up CI pipeline                 | closed | task    | @bob     | medium   |
   ```

5. Show summary counts and suggest actions

---

## Action: view

View detailed information about a specific issue.

**Syntax:**
```
/manager:issue view <N>
```

**Instructions:**

1. Fetch issue details:
   ```bash
   gh issue view <N> --json number,title,body,state,labels,assignees,createdAt,updatedAt,url,comments
   ```

2. Display formatted output:
   ```
   Issue #55: As a user, I want to login
   URL: https://github.com/owner/repo/issues/55
   Status: open
   Type: feature
   Priority: high
   Assignee: @alice
   Created: 2024-01-15
   Updated: 2024-01-20

   Description:
   [Full issue body]

   Comments: 3
   [Show recent comments if any]
   ```

3. If linked to an epic, show epic reference

4. Suggest available actions
