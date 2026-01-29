# GitHub Product Manager Plugin

A Claude Code plugin for product managers to manage GitHub issues and epics from PRDs and TRDs.

## Features

- **Brainstorming**: Explore ideas before formalizing into documents
- **PRD Management**: Create product requirements with P0/P1/P2 priorities
- **TRD Management**: Create technical requirements with API specs, database design
- **Epic Tracking**: Create epics as tracking issues with task lists
- **Issue Generation**: Parse PRDs/TRDs to generate structured issues
- **Sprint Management**: Plan sprints using GitHub Milestones
- **Local Storage**: Work offline and sync with GitHub
- **Specialized Agents**: AI assistants for brainstorming, PRDs, issues, bugs, and more

## Installation

### From GitHub

```bash
# Register marketplace if not yet
claude plugin marketplace add github:bnofao/bno-claude-plugins

# Install plugin
claude plugin install manager@bno-claude-plugins
```

### From Local Path

```bash
# Clone the marketplace repository
git clone https://github.com/bnofao/bno-claude-plugins.git

# Add the plugin to your project
claude plugin add /path/to/bno-claude-plugins/plugins/manager
```

### Manual Installation

Copy the `plugins/manager` directory to your project's `.claude/plugins/` folder:

```
your-project/
  .claude/
    plugins/
      manager/        ← Copy here
```

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Run `gh auth login` if not already authenticated

## Commands

| Command | Description |
|---------|-------------|
| `/manager:brainstorm` | Explore ideas before creating PRD/TRD |
| `/manager:prd` | Create or update a PRD |
| `/manager:trd` | Create or update a TRD |
| `/manager:epic` | Manage epics (create/update/list/view) |
| `/manager:issue` | Manage issues (create/update/list/view) |
| `/manager:parse` | Generate issues from PRD or TRD |
| `/manager:status` | View epic/issue progress |
| `/manager:sync` | Sync task lists and local files |
| `/manager:sprint` | Manage sprints with GitHub Milestones |
| `/manager:project` | Manage GitHub Projects integration |

## Usage Examples

### Brainstorm an Idea

```
/manager:brainstorm user-auth
```

Briana (brainstorming agent) will guide you through:
- Problem exploration ("What problem are we solving?")
- User understanding ("Who are the users?")
- Solution ideation ("What are possible solutions?")
- Scope definition ("What's MVP vs future?")
- Risk identification ("What could go wrong?")

Output saved to `docs/planning/user-auth/brainstorm.md`

### Create a PRD

```
/manager:prd create user-auth
```

Petra (PRD agent) will guide you through creating a PRD with:
- Overview and problem statement
- Success metrics
- Features with P0/P1/P2 priorities
- User experience flows
- Technical constraints

### Create a TRD

```
/manager:trd create user-auth
```

Creates a technical requirements document with:
- Architecture and components
- API specifications
- Database design
- Security and performance requirements

### Create an Epic

```
/manager:epic create "User Authentication" --prd=user-auth --trd
```

Creates a GitHub tracking issue linked to your PRD and TRD.

### Generate Issues from PRD

```
/manager:parse user-auth --epic=42
```

Isaac (issue generator) parses your PRD and creates issues for each feature:
- Groups by priority (P0, P1, P2)
- Includes user stories and acceptance criteria
- Links to epic #42

### Generate Technical Issues from TRD

```
/manager:parse user-auth --trd --epic=42
```

Tara (technical issue generator) creates implementation tasks:
- API endpoint issues
- Database migration issues
- Security implementation tasks

### Manage Sprints

```
# Create a sprint
/manager:sprint create Sprint-01 --prd=user-auth --start=2024-02-01 --end=2024-02-14

# Add issues to sprint
/manager:sprint update Sprint-01 add-issue 55
/manager:sprint update Sprint-01 add-issue 56

# Start the sprint (creates GitHub Milestone)
/manager:sprint update Sprint-01 start

# Track progress
/manager:sprint status Sprint-01

# Complete the sprint
/manager:sprint update Sprint-01 complete
```

### Use GitHub Projects

```
# List available projects
/manager:project list

# View project details
/manager:project view 1

# Set a default project for the PRD
/manager:project set-default 1

# Create epic and add to project in one step
/manager:epic create "User Auth" --prd=user-auth --project=1

# Create issue and add to project
/manager:issue create --epic=42 --project=1

# Add existing issue to project
/manager:project add 55 --project=1

# Update issue status in project
/manager:project set-status 55 "In Progress"

# Remove from project
/manager:project remove 55 --project=1
```

### View Status

```
# View all epics
/manager:status

# View specific epic with issue details
/manager:status 42
```

### Work Offline with Local Storage

```
# Create local drafts
/manager:epic create "New Feature" --prd=feature --local
/manager:issue create --prd=feature --local

# Download GitHub issues to local files
/manager:sync --save user-auth

# Edit local files, then push to GitHub
/manager:sync --push user-auth
```

### Report a Bug

Just describe the bug to Blake (bug reporter agent):

```
"I found a bug - the login button doesn't work on mobile"
```

Blake will guide you through creating a proper bug report with reproduction steps.

### Triage Issues

Ask Tina (issue triager) to help organize:

```
"Help me triage our open issues"
"Which issues should we tackle next sprint?"
```

### Implement an Issue

Ask Max (implementer agent) for help:

```
"Help me implement issue #42"
```

Max will read the issue, analyze your codebase, and help implement with tests.

## Agents

| Agent | Purpose |
|-------|---------|
| **Briana** | Facilitates brainstorming before PRD/TRD creation |
| **Petra** | Creates PRDs with interactive guidance |
| **Isaac** | Generates user story issues from PRDs |
| **Tara** | Generates technical issues from TRDs/PRDs |
| **Max** | Implements issues with code and tests |
| **Tina** | Triages backlog, helps sprint planning |
| **Blake** | Creates detailed bug reports |

## Document Structure

```
docs/planning/<feature-name>/
  brainstorm.md   # Brainstorming notes (optional)
  prd.md          # Product Requirements Document
  trd.md          # Technical Requirements Document
  epics/          # Local epic copies
  issues/         # Local issue copies
  sprints/        # Sprint planning files
```

## PRD Template

PRDs use priority-based feature organization:

```markdown
## 5. Features and Requirements

### Must-Have Features (P0)
#### Feature 1: Login
- **Description:** User authentication via email/password
- **User Story:** As a user, I want to login so that I can access my account
- **Acceptance Criteria:**
  - [ ] User can enter email and password
  - [ ] Invalid credentials show error
  - [ ] Successful login redirects to dashboard

### Should-Have Features (P1)
...

### Nice-to-Have Features (P2)
...
```

## TRD Template

TRDs include technical specifications:

```markdown
## 2. Architecture
### Components
| Component | Technology | Purpose |
|-----------|------------|---------|
| Frontend | Next.js | User interface |
| Backend | Laravel | API server |
| Database | PostgreSQL | Data storage |

## 3. API Specification
#### `POST /auth/login`
**Request:** { "email": "string", "password": "string" }
**Response:** { "token": "string" }
```

## Configuration

Create `.claude/manager.local.md` in your project:

```yaml
---
repo: owner/repo-name
prd_dir: docs/planning
default_project: 1                    # Default GitHub Project number
project_owner: "@me"                  # or organization name
project_status_field: "Status"        # Name of status field in project
project_status_mapping:
  todo: "Todo"
  in_progress: "In Progress"
  in_review: "In Review"
  done: "Done"
labels:
  feature: ["type:feature"]
  task: ["type:task"]
  bug: ["type:bug"]
  priority: ["priority:high", "priority:medium", "priority:low"]
---

## Project-Specific Notes

Add any project-specific instructions here.
```

## Typical Workflow

1. **Brainstorm** (optional): `/manager:brainstorm feature-name`
2. **Create PRD**: `/manager:prd create feature-name`
3. **Create TRD**: `/manager:trd create feature-name`
4. **Create Epic**: `/manager:epic create "Title" --prd=feature-name --trd --project=1`
5. **Generate Issues**: `/manager:parse feature-name --epic=N`
6. **Generate Tech Tasks**: `/manager:parse feature-name --trd --epic=N`
7. **Add to Project** (if not using --project flag): `/manager:project add N`
8. **Create Sprint**: `/manager:sprint create Sprint-01 --prd=feature-name`
9. **Track Progress**: `/manager:status N`

## License

MIT
