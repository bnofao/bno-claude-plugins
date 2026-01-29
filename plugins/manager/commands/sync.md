---
description: Sync epic task lists and local files with GitHub
argument-hint: [epic-number|all|--save|--push] [prd-name]
allowed-tools: Read, Write, Bash(gh:*)
---

<!--
Usage:
  /manager:sync                      - Sync all open epics' task list states
  /manager:sync 42                   - Sync specific epic #42
  /manager:sync all                  - Sync all epics including closed
  /manager:sync --save <prd-name>    - Save GitHub epics/issues to local files
  /manager:sync --push <prd-name>    - Push local drafts to GitHub
-->

Synchronize epic task lists with GitHub issue states, and manage local file storage.

**Arguments received:** $ARGUMENTS

---

## Mode: Task List Sync (Default)

Synchronize epic task lists with the current state of linked issues on GitHub.

**Syntax:**
```
/manager:sync                      # Sync all open epics
/manager:sync <epic-number>        # Sync specific epic
/manager:sync all                  # Sync all epics including closed
```

**Instructions:**

1. Determine which epics to sync:
   - If specific number: just that epic
   - If empty: all open epics with "epic" label
   - If "all": all epics regardless of state

2. For each epic:
   a) Fetch epic body:
      ```bash
      gh issue view {epic-number} --json number,title,body
      ```

   b) Parse task list items:
      - Extract issue numbers from lines like `- [ ] #123` or `- [x] #123`
      - Build list of linked issue numbers

   c) Fetch current state of each linked issue:
      ```bash
      gh issue view {issue-number} --json number,title,state
      ```

   d) Update task list:
      - If issue is closed: mark as `- [x] #{number} {title}`
      - If issue is open: mark as `- [ ] #{number} {title}`
      - Preserve issue titles (update if changed)

   e) Compare old body with new body:
      - If changes detected, update epic:
        ```bash
        gh issue edit {epic-number} --body "{updated-body}"
        ```
      - If no changes, skip update

3. Report sync results:
   ```
   Sync Results:

   Epic #42: [Epic] User Authentication
   - Updated 2 task items
   - Progress: 3/5 (60%) -> 4/5 (80%)
   - 1 issue was closed since last sync

   Epic #38: [Epic] Dashboard
   - No changes needed
   - Progress: 8/8 (100%)

   Summary:
   - Synced 2 epics
   - Updated 1 epic
   - 1 issue state changed
   ```

4. Identify discrepancies:
   - Issues in task list that no longer exist
   - Issues linked to epic but not in task list
   - Suggest fixes for any issues found

---

## Mode: Save to Local (--save)

Download GitHub epics and issues to local markdown files for a PRD.

**Syntax:**
```
/manager:sync --save <prd-name>
```

**Storage Structure:**
```
docs/planning/<prd-name>/
  prd.md                    # (existing)
  trd.md                    # (existing, if any)
  epics/                    # Created by sync
    <epic-number>.md        # Local epic copy
  issues/                   # Created by sync
    <issue-number>.md       # Local issue copy
```

**Instructions:**

1. Verify PRD exists:
   - Check `docs/planning/<prd-name>/prd.md` exists
   - If not, inform user and exit

2. Find related epics on GitHub:
   - Search for epics that reference this PRD:
     ```bash
     gh issue list --label "epic" --state all --json number,title,body
     ```
   - Filter to epics mentioning the PRD name in body

3. Create local directories:
   ```bash
   mkdir -p docs/planning/<prd-name>/epics
   mkdir -p docs/planning/<prd-name>/issues
   ```

4. For each epic found:
   a) Fetch full epic details:
      ```bash
      gh issue view <N> --json number,title,body,state,labels,createdAt,updatedAt
      ```

   b) Create local epic file using @${CLAUDE_PLUGIN_ROOT}/templates/local-epic-template.md:
      - File: `docs/planning/<prd-name>/epics/<N>.md`
      - Populate YAML frontmatter:
        - github_number: <N>
        - title: <epic title>
        - status: synced
        - prd: <prd-name>
        - created/updated: from GitHub
      - Populate body from GitHub issue body

   c) Parse task list to find linked issues

5. For each linked issue:
   a) Fetch full issue details:
      ```bash
      gh issue view <N> --json number,title,body,state,labels,assignees,createdAt,updatedAt
      ```

   b) Create local issue file using @${CLAUDE_PLUGIN_ROOT}/templates/local-issue-template.md:
      - File: `docs/planning/<prd-name>/issues/<N>.md`
      - Populate YAML frontmatter:
        - github_number: <N>
        - title: <issue title>
        - status: synced
        - type: from labels (type:feature, type:task, type:bug)
        - priority: from labels (priority:high, etc.)
        - epic: parent epic number
        - prd: <prd-name>
        - assignees: from GitHub
        - created/updated: from GitHub
      - Populate body from GitHub issue body

6. Report results:
   ```
   Saved to local files:

   PRD: docs/planning/<prd-name>/

   Epics (2):
   - epics/42.md: [Epic] User Authentication
   - epics/38.md: [Epic] Dashboard

   Issues (8):
   - issues/45.md: As a user, I want to login
   - issues/46.md: As a user, I want to logout
   ...

   All files are marked as 'synced' status.
   Edit files and use '/manager:sync --push <prd-name>' to update GitHub.
   ```

---

## Mode: Push to GitHub (--push)

Push local draft epics and issues to GitHub, update synced ones if changed.

**Syntax:**
```
/manager:sync --push <prd-name>
```

**Instructions:**

1. Verify PRD exists and has local files:
   - Check `docs/planning/<prd-name>/epics/` and `issues/` directories

2. Process local epic files:
   - Read each `.md` file in `docs/planning/<prd-name>/epics/`
   - Parse YAML frontmatter

   For **draft** epics (github_number is null):
   a) Create new GitHub issue:
      ```bash
      gh issue create --title "{title}" --body "{body}" --label "epic"
      ```
   b) Update local file:
      - Set github_number to new issue number
      - Set status to synced
      - Update updated date

   For **synced** epics (has github_number):
   a) Compare local content with GitHub:
      ```bash
      gh issue view <N> --json body
      ```
   b) If local differs from GitHub, update GitHub:
      ```bash
      gh issue edit <N> --body "{body}"
      ```
   c) Update local updated date

3. Process local issue files:
   - Read each `.md` file in `docs/planning/<prd-name>/issues/`
   - Parse YAML frontmatter

   For **draft** issues (github_number is null):
   a) Determine labels from frontmatter (type, priority)
   b) Create new GitHub issue:
      ```bash
      gh issue create --title "{title}" --body "{body}" --label "{labels}"
      ```
   c) If epic specified and exists on GitHub:
      - Add issue to epic's task list
   d) If assignees specified:
      ```bash
      gh issue edit <N> --add-assignee "{assignees}"
      ```
   e) Update local file:
      - Set github_number to new issue number
      - Set status to synced
      - Update updated date

   For **synced** issues (has github_number):
   a) Compare local content with GitHub
   b) If local differs, update GitHub:
      ```bash
      gh issue edit <N> --title "{title}" --body "{body}"
      ```
   c) Sync labels if changed:
      ```bash
      gh issue edit <N> --add-label "{new_labels}" --remove-label "{old_labels}"
      ```
   d) Update local updated date

4. Report results:
   ```
   Push Results:

   Epics:
   - Created: 1 (docs/planning/feature/epics/draft-1.md -> #52)
   - Updated: 1 (#42)
   - Unchanged: 0

   Issues:
   - Created: 3 (linked to epic #42)
   - Updated: 2
   - Unchanged: 3

   All local files updated with GitHub issue numbers.
   ```

5. Handle errors gracefully:
   - If GitHub API fails, report which files failed
   - Don't update local status to synced if push failed
   - Suggest retry or manual intervention
