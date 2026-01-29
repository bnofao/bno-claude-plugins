---
description: View status of epics and issues
argument-hint: [epic-number|all]
allowed-tools: Bash(gh:*)
---

<!--
Usage:
  /manager:status                - Show all open epics with progress
  /manager:status all            - Show all epics (including closed)
  /manager:status 42             - Show detailed status of epic #42
-->

View the status and progress of epics and their associated issues.

**Arguments received:**
- Scope: $1 (epic number, "all", or empty for open epics only)

**Instructions:**

1. Check prerequisites:
   - Verify `gh` CLI available
   - Verify authentication

2. If no argument or "all":
   - List epics:
     ```bash
     gh issue list --label "epic" --state all --json number,title,state,body
     ```
   - For each epic, calculate progress:
     - Parse task list from body
     - Count total items and checked items
     - Calculate percentage

   - Display summary table:
     ```
     | # | Epic Title | Status | Progress | Open Issues |
     |---|------------|--------|----------|-------------|
     | 42 | [Epic] User Auth | open | 3/5 (60%) | 2 |
     | 38 | [Epic] Dashboard | closed | 8/8 (100%) | 0 |
     ```

3. If specific epic number provided:
   - Fetch epic details:
     ```bash
     gh issue view $1 --json number,title,body,state,labels,createdAt,updatedAt
     ```

   - Parse task list and fetch each linked issue:
     ```bash
     gh issue view {issue-number} --json number,title,state,labels,assignees
     ```

   - Display detailed report:
     ```
     Epic #42: [Epic] User Authentication
     Status: open
     Created: 2024-01-15
     Progress: 3/5 (60%)

     Issues:
     | # | Title | Status | Assignee | Priority |
     |---|-------|--------|----------|----------|
     | 45 | As a user, I want to login | closed | @alice | high |
     | 46 | As a user, I want to logout | open | @bob | medium |
     | 47 | As a admin, I want to manage users | open | - | high |
     ...

     Blockers:
     - Issue #47 has no assignee
     - 2 high priority issues still open
     ```

4. Check if in a GitHub Project:
   - Query project items to see if epic is in a project
   - If so, show project status (e.g., "In Progress", "Done")
   - Show project URL link

5. Provide insights:
   - Identify blockers (high priority open issues)
   - Flag unassigned issues
   - Note stale issues (no updates in 7+ days)
   - Suggest actions to move forward
   - Suggest `/manager:project set-status` if in a project
