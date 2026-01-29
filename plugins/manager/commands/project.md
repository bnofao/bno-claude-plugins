---
description: Manage GitHub Projects integration
argument-hint: [action] [args]
allowed-tools: Read, Bash(gh:*)
---

<!--
Usage:
  /manager:project list                           - List available projects
  /manager:project view <project>                 - View project details
  /manager:project add <issue-N> [--project=P]   - Add issue to project
  /manager:project remove <issue-N> [--project=P] - Remove issue from project
  /manager:project set-status <issue-N> <status>  - Update issue status in project
  /manager:project set-default <project>          - Set default project for this PRD
-->

Manage GitHub Projects integration for epics and issues.

**Arguments received:** $ARGUMENTS

---

## Action: list

List available GitHub Projects in the repository/organization.

**Syntax:**
```
/manager:project list
/manager:project list --org                    # List organization projects
```

**Instructions:**

1. List repository projects:
   ```bash
   gh project list --owner @me --format json
   ```

   Or for organization:
   ```bash
   gh project list --owner <org> --format json
   ```

2. Display projects:
   ```
   | # | Project Title        | Status | Items |
   |---|---------------------|--------|-------|
   | 1 | Q1 Roadmap          | open   | 24    |
   | 2 | User Auth Feature   | open   | 8     |
   | 3 | Bug Tracker         | open   | 15    |
   ```

---

## Action: view

View details of a specific project.

**Syntax:**
```
/manager:project view <project-number>
/manager:project view "Project Title"
```

**Instructions:**

1. Fetch project details:
   ```bash
   gh project view <N> --owner @me --format json
   ```

2. Fetch project items:
   ```bash
   gh project item-list <N> --owner @me --format json
   ```

3. Display project:
   ```
   Project #1: Q1 Roadmap
   Status: open
   URL: https://github.com/users/owner/projects/1

   Fields:
   - Status: Todo | In Progress | In Review | Done
   - Priority: High | Medium | Low
   - Sprint: Sprint 1 | Sprint 2

   Items (24):
   | # | Title | Status | Priority | Type |
   |---|-------|--------|----------|------|
   | 42 | [Epic] User Auth | In Progress | High | epic |
   | 55 | Login endpoint | Todo | High | issue |
   ```

---

## Action: add

Add an issue or epic to a GitHub Project.

**Syntax:**
```
/manager:project add <issue-N> [--project=P]
/manager:project add 42 --project=1
```

**Instructions:**

1. Determine project:
   - Use --project if provided
   - Otherwise use default from config
   - Otherwise ask user

2. Get issue details:
   ```bash
   gh issue view <N> --json id,title,labels
   ```

3. Add to project:
   ```bash
   gh project item-add <project-N> --owner @me --url <issue-url>
   ```

4. Optionally set initial status:
   ```bash
   gh project item-edit --project-id <project-id> --id <item-id> --field-id <status-field-id> --single-select-option-id <option-id>
   ```

5. Report:
   ```
   Added issue #42 to project "Q1 Roadmap"
   - Title: [Epic] User Authentication
   - Status: Todo (default)

   View in project: https://github.com/users/owner/projects/1
   ```

---

## Action: remove

Remove an issue from a GitHub Project.

**Syntax:**
```
/manager:project remove <issue-N> [--project=P]
```

**Instructions:**

1. Find item ID in project:
   ```bash
   gh project item-list <project-N> --owner @me --format json | jq '.items[] | select(.content.number == <N>)'
   ```

2. Remove from project:
   ```bash
   gh project item-delete <project-N> --owner @me --id <item-id>
   ```

3. Report:
   ```
   Removed issue #42 from project "Q1 Roadmap"
   ```

---

## Action: set-status

Update the status of an issue in a project.

**Syntax:**
```
/manager:project set-status <issue-N> <status> [--project=P]
/manager:project set-status 42 "In Progress"
/manager:project set-status 42 done
```

**Instructions:**

1. Get project field info:
   ```bash
   gh project field-list <project-N> --owner @me --format json
   ```

2. Find the Status field and available options

3. Find item ID:
   ```bash
   gh project item-list <project-N> --owner @me --format json
   ```

4. Update status:
   ```bash
   gh project item-edit --project-id <project-id> --id <item-id> --field-id <status-field-id> --single-select-option-id <option-id>
   ```

5. Report:
   ```
   Updated issue #42 status in "Q1 Roadmap"
   - Previous: Todo
   - New: In Progress
   ```

---

## Action: set-default

Set the default project for the current feature/PRD.

**Syntax:**
```
/manager:project set-default <project-number>
/manager:project set-default 1
```

**Instructions:**

1. Verify project exists:
   ```bash
   gh project view <N> --owner @me
   ```

2. Update config file `.claude/manager.local.md`:
   - Add or update `default_project: <N>` in frontmatter

3. Report:
   ```
   Set default project to #1 "Q1 Roadmap"

   New issues created with /manager:issue will automatically be added to this project.
   ```

---

## Bulk Operations

### Add all issues from an epic to a project:
```
/manager:project add --epic=42 --project=1
```

This will:
1. Fetch all issues linked to epic #42
2. Add each to project #1
3. Report results

### Sync epic progress to project:
When issues in a project change status, the epic task list can be synced with `/manager:sync`.

---

## Project Status Mapping

| Issue State | Typical Project Status |
|-------------|----------------------|
| Open (new) | Todo |
| Open (assigned) | In Progress |
| In review (has PR) | In Review |
| Closed | Done |

---

## Configuration

In `.claude/manager.local.md`:

```yaml
---
repo: owner/repo-name
default_project: 1                    # Default project number
project_owner: "@me"                  # or organization name
project_status_field: "Status"        # Name of status field
project_status_mapping:
  todo: "Todo"
  in_progress: "In Progress"
  in_review: "In Review"
  done: "Done"
---
```
