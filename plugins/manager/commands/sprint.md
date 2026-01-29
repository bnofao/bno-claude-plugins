---
description: Manage sprints using GitHub Milestones
argument-hint: [action] [args]
allowed-tools: Read, Write, Bash(gh:*)
---

<!--
Usage:
  /manager:sprint create <name> --prd=<name> --start=DATE --end=DATE
  /manager:sprint list [--prd=<name>] [--status=S]
  /manager:sprint view <name>
  /manager:sprint update <name> <action>
  /manager:sprint status [<name>]
-->

Manage sprints for a PRD using GitHub Milestones for tracking.

**Arguments received:** $ARGUMENTS

**Template:** @${CLAUDE_PLUGIN_ROOT}/templates/sprint-template.md

**Storage:** `docs/planning/<prd>/sprints/<sprint-name>.md`

---

## Action: create

Create a new sprint for a PRD.

**Syntax:**
```
/manager:sprint create <name> --prd=<prd-name> --start=YYYY-MM-DD --end=YYYY-MM-DD
```

**Instructions:**

1. Parse arguments:
   - Extract sprint name
   - Extract --prd=<name> (required)
   - Extract --start=<date> (required)
   - Extract --end=<date> (required)

2. Validate:
   - PRD exists: `docs/planning/<prd-name>/prd.md`
   - Sprint doesn't already exist
   - End date is after start date

3. Create sprint directory if needed:
   ```bash
   mkdir -p docs/planning/<prd-name>/sprints
   ```

4. Create sprint file from template:
   - File: `docs/planning/<prd-name>/sprints/<name>.md`
   - Populate YAML frontmatter:
     - name: <sprint-name>
     - milestone: null (created when sprint starts)
     - start_date: <start>
     - end_date: <end>
     - status: planning
     - prd: <prd-name>

5. Report:
   ```
   Created sprint: <name>
   Location: docs/planning/<prd>/sprints/<name>.md
   Status: planning
   Duration: <start> to <end>

   Next steps:
   - Add issues: /manager:sprint update <name> add-issue <N>
   - Start sprint: /manager:sprint update <name> start
   ```

---

## Action: list

List sprints for a PRD or all sprints.

**Syntax:**
```
/manager:sprint list                           # List all sprints
/manager:sprint list --prd=<name>              # List sprints for specific PRD
/manager:sprint list --status=planning|active|completed
```

**Instructions:**

1. Find sprint files:
   - If --prd specified: `docs/planning/<prd>/sprints/*.md`
   - Otherwise: `docs/planning/*/sprints/*.md`

2. Read each sprint file and parse YAML frontmatter

3. Filter by --status if specified

4. Display table:
   ```
   | Sprint    | PRD          | Status    | Dates                  | Issues |
   |-----------|--------------|-----------|------------------------|--------|
   | Sprint-01 | user-auth    | active    | 2024-01-29 - 2024-02-09| 5/8    |
   | Sprint-02 | user-auth    | planning  | 2024-02-12 - 2024-02-23| 0/0    |
   | Sprint-01 | dashboard    | completed | 2024-01-15 - 2024-01-26| 6/6    |
   ```

---

## Action: view

View detailed information about a sprint.

**Syntax:**
```
/manager:sprint view <name> [--prd=<name>]
```

**Instructions:**

1. Find sprint file:
   - If --prd specified: `docs/planning/<prd>/sprints/<name>.md`
   - Otherwise: search all PRDs for sprint with matching name

2. Read and parse sprint file

3. If sprint has a GitHub milestone, fetch milestone data:
   ```bash
   gh api repos/{owner}/{repo}/milestones/<number> --jq '.title, .state, .open_issues, .closed_issues'
   ```

4. For each issue in sprint, fetch current status:
   ```bash
   gh issue view <N> --json number,title,state,assignees,labels
   ```

5. Display detailed view:
   ```
   Sprint: Sprint-01
   PRD: user-auth
   Status: active
   Duration: 2024-01-29 to 2024-02-09
   GitHub Milestone: #3

   Goals:
   - [ ] Complete user login flow
   - [x] Set up authentication service

   Progress: 5/8 issues (62.5%)

   Issues:
   | #  | Title                    | Status | Assignee | Priority |
   |----|--------------------------|--------|----------|----------|
   | 55 | As a user, I want login  | closed | @alice   | high     |
   | 56 | As a user, I want logout | open   | @bob     | medium   |
   ...

   Blockers:
   - Issue #58 has no assignee
   - 2 high priority issues still open
   ```

---

## Action: update

Update a sprint with various sub-actions.

**Syntax:**
```
/manager:sprint update <name> add-issue <N>    # Add issue to sprint
/manager:sprint update <name> remove-issue <N> # Remove issue from sprint
/manager:sprint update <name> start            # Start sprint (creates GitHub milestone)
/manager:sprint update <name> complete         # Complete sprint (closes milestone)
```

**Instructions:**

### Sub-action: add-issue

1. Find sprint file and read content
2. Verify issue exists: `gh issue view <N> --json number,title,state,labels,assignees`
3. Add issue to sprint's Issues table
4. Save sprint file
5. If sprint is active (has milestone), add milestone to issue:
   ```bash
   gh issue edit <N> --milestone "<sprint-name>"
   ```

### Sub-action: remove-issue

1. Find sprint file and read content
2. Remove issue from sprint's Issues table
3. Save sprint file
4. If sprint is active, remove milestone from issue:
   ```bash
   gh issue edit <N> --milestone ""
   ```

### Sub-action: start

1. Find sprint file and verify status is "planning"
2. Create GitHub milestone:
   ```bash
   gh api repos/{owner}/{repo}/milestones -f title="<sprint-name>" -f due_on="<end_date>T23:59:59Z" -f description="Sprint for <prd-name>"
   ```
3. Parse milestone number from response
4. Add milestone to all issues in sprint:
   ```bash
   gh issue edit <N> --milestone "<sprint-name>"
   ```
5. Update sprint file:
   - Set milestone: <number>
   - Set status: active
6. Report:
   ```
   Sprint started: <name>
   GitHub Milestone: #<number>
   Issues assigned to milestone: <count>

   Sprint runs from <start> to <end>
   Use '/manager:sprint status <name>' to track progress
   ```

### Sub-action: complete

1. Find sprint file and verify status is "active"
2. Close GitHub milestone:
   ```bash
   gh api repos/{owner}/{repo}/milestones/<number> -X PATCH -f state="closed"
   ```
3. Update sprint file:
   - Set status: completed
4. Generate summary:
   - Count completed vs incomplete issues
   - List any issues that weren't completed
5. Report:
   ```
   Sprint completed: <name>

   Summary:
   - Completed: 6/8 issues (75%)
   - Incomplete issues moved to backlog:
     - #58: As a user, I want password reset
     - #59: As a admin, I want user reports

   Reminder: Fill in the Retrospective section in the sprint file.
   ```

---

## Action: status

View sprint status and progress.

**Syntax:**
```
/manager:sprint status                         # Show active sprint(s)
/manager:sprint status <name>                  # Show specific sprint status
```

**Instructions:**

1. If no name provided:
   - Find all sprints with status "active"
   - Display brief status for each

2. If name provided:
   - Same as `/manager:sprint view <name>` but focused on progress metrics

3. Display:
   ```
   Active Sprints:

   Sprint-01 (user-auth)
   =====================
   Progress: 5/8 (62.5%)
   Days remaining: 4
   Velocity: 1.25 issues/day

   Burndown:
   - Day 1: 8 open
   - Day 2: 7 open
   - Day 3: 6 open
   - Day 4: 5 open  <- today
   - Day 5: (projected) 4 open
   ...

   At Risk:
   - #58 (high priority, unassigned)
   - #57 (no progress in 3 days)
   ```

4. Provide recommendations if sprint is at risk
