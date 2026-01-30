# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GitHub Product Manager Plugin (`manager`) is a Claude Code plugin that helps product managers manage GitHub issues and epics from PRDs. It provides a complete workflow: PRD → Epic → Issues → Status Tracking.

**Prerequisites:** GitHub CLI (`gh`) must be installed and authenticated via `gh auth login`.

## Plugin Architecture

This is a Claude Code plugin (not a Node.js project). All functionality is defined in markdown files with YAML frontmatter:

- **Commands** (`commands/*.md`): User-invocable slash commands with restricted tool access
- **Agents** (`agents/*.md`): Autonomous agents for complex multi-step workflows
- **Skills** (`skills/*/SKILL.md`): Reusable patterns and best practices
- **Templates** (`templates/*.md`): Document structure templates for PRDs, epics, and issues
- **Hooks** (`hooks/`): Event-driven automation (SessionStart for config loading)

Entry point: `.claude-plugin/plugin.json`

## Command System

Commands use YAML frontmatter to declare:
- `description`: What the command does
- `argument-hint`: Expected arguments
- `allowed-tools`: Restricted tool access (e.g., `Bash(gh:*)` allows only gh CLI commands)

| Command | Purpose |
|---------|---------|
| `/manager:brainstorm` | Explore ideas before creating PRD/TRD |
| `/manager:prd` | Create/update PRDs |
| `/manager:trd` | Create/update TRDs |
| `/manager:epic` | Manage epics (create/update/list/view) |
| `/manager:issue` | Manage issues (create/update/list/view) |
| `/manager:parse` | Generate issues from PRD or TRD |
| `/manager:status` | View epic/issue progress |
| `/manager:sync` | Sync task lists and local files |
| `/manager:sprint` | Manage sprints with GitHub Milestones |
| `/manager:project` | Manage GitHub Projects integration |

## Agent System

Specialized agents handle complex workflows:

| Agent | Color | Purpose |
|-------|-------|---------|
| **Briana** | blue | Facilitates brainstorming sessions before PRD/TRD creation |
| **Petra** | cyan | Guides users through PRD creation with interactive questions |
| **Isaac** | green | Parses PRDs and generates user story issues |
| **Tara** | yellow | Parses TRDs and/or PRDs to generate technical implementation issues |
| **Max** | magenta | Reads issues and helps implement with code and tests |
| **Tina** | orange | Analyzes backlog, prioritizes issues, helps sprint planning |
| **Blake** | red | Guides through bug report creation with reproduction steps |

Agents are triggered automatically when commands require multi-step workflows or can be invoked based on user intent.

## Template-Driven Content

All generated content follows templates in `templates/`:

**PRDs** (`prd-template.md`):
- Overview, Problem Statement, Goals
- Success Metrics table
- Features with P0/P1/P2 priorities (Must-Have, Should-Have, Nice-to-Have)
- User Experience (flows, wireframes)
- Technical Constraints, Security & Compliance
- Dependencies, Timeline & Milestones

**TRDs** (`trd-template.md`):
- Architecture (components table, data flow)
- API Specification, Database Design
- Security, Performance, Observability
- Dependencies, Testing Strategy, Rollout Plan

**Other templates:**
- Epics use GitHub task lists (`- [ ] #ISSUE_NUMBER`) for automatic progress tracking
- Issues follow user story format (features/tasks) or bug format with reproduction steps
- Sprints use GitHub Milestones and include goals, capacity, and retrospectives

## Local Storage

Epics and issues can be stored locally for offline editing and batch operations:

```
docs/planning/<prd-name>/
  brainstorm.md             # Brainstorming notes (optional)
  prd.md                    # PRD document
  trd.md                    # TRD document (optional)
  epics/                    # Local epic copies
    <epic-number>.md
  issues/                   # Local issue copies
    <issue-number>.md
  sprints/                  # Sprint planning
    <sprint-name>.md
```

**Creating local drafts directly:**
- `/manager:epic create "Title" --prd=feature --local` - Create local epic draft
- `/manager:issue create --prd=feature --local` - Create local issue draft

**Syncing with GitHub:**
- `/manager:sync --save <prd>` - Download GitHub epics/issues to local files
- `/manager:sync --push <prd>` - Push local drafts to GitHub

## Project Configuration

Projects using this plugin create `.claude/manager.local.md` with YAML frontmatter. The configuration is **automatically loaded at session start** via the SessionStart hook.

```yaml
---
repo: owner/repo-name
prd_dir: docs/planning
default_project: 1                    # Default GitHub Project number
project_owner: "@me"                  # or organization name
labels:
  feature: ["type:feature"]
  priority: ["priority:high", "priority:medium", "priority:low"]
---

## Project-Specific Notes

Add any custom notes or instructions here. This content will be
included in the session context.
```

### Configuration Loading

The `hooks/load-config.sh` hook runs automatically when Claude Code starts:

1. Reads `.claude/manager.local.md` if it exists
2. Parses YAML frontmatter for configuration values
3. Exports environment variables for bash commands:
   - `MANAGER_REPO` - Repository in owner/repo format
   - `MANAGER_PRD_DIR` - Directory for PRD documents
   - `MANAGER_DEFAULT_PROJECT` - Default GitHub Project number
   - `MANAGER_PROJECT_OWNER` - Project owner (@me or organization)
4. Injects configuration summary as session context

### Configuration Fields

| Field | Default | Description |
|-------|---------|-------------|
| `repo` | auto-detect | GitHub repository (owner/repo format) |
| `prd_dir` | `docs/planning` | Base directory for PRD/TRD documents |
| `default_project` | none | Default GitHub Project number |
| `project_owner` | `@me` | Project owner for `gh project` commands |
| `labels` | none | Label mappings for issue types |

**Note:** Changes to configuration require restarting Claude Code to take effect.

## Typical Workflow

1. Brainstorm (optional): `/manager:brainstorm feature-name`
2. Create PRD: `/manager:prd create feature-name`
3. Create TRD (optional): `/manager:trd create feature-name`
4. Create epic tracking issue: `/manager:epic create "Title" --prd=feature-name --trd`
5. Generate user story issues from PRD: `/manager:parse feature-name --epic=N`
6. Generate technical issues from TRD: `/manager:parse feature-name --trd --epic=N`
7. Monitor progress: `/manager:status N`
8. Sync task lists: `/manager:sync N`

## Sprint Workflow

1. Create sprint: `/manager:sprint create Sprint-01 --prd=feature-name --start=2024-01-29 --end=2024-02-09`
2. Add issues: `/manager:sprint update Sprint-01 add-issue 55`
3. Start sprint: `/manager:sprint update Sprint-01 start` (creates GitHub Milestone)
4. Track progress: `/manager:sprint status Sprint-01`
5. Complete sprint: `/manager:sprint update Sprint-01 complete`

## GitHub Projects Workflow

1. List available projects: `/manager:project list`
2. Set default project: `/manager:project set-default 1`
3. Create epic with project: `/manager:epic create "Title" --prd=feature --project=1`
4. Create issue with project: `/manager:issue create --epic=42 --project=1`
5. Add existing issue to project: `/manager:project add 55 --project=1`
6. Update status in project: `/manager:project set-status 55 "In Progress"`
