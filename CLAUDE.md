# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace containing reusable plugins. Each plugin is self-contained under `plugins/<plugin-name>/`.

## Repository Structure

```
.claude-plugin/
  marketplace.json        # Marketplace manifest (indexes all plugins)
plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json         # Plugin manifest (required)
    agents/               # Autonomous agents (*.md)
    commands/             # Slash commands (*.md)
    skills/               # Reusable patterns (*/SKILL.md)
    templates/            # Document templates (*.md)
    hooks/                # Event hooks (*.md)
    CLAUDE.md             # Plugin-specific instructions
    README.md             # User documentation
```

## Marketplace Manifest

The root `.claude-plugin/marketplace.json` indexes all available plugins:

```json
{
  "name": "marketplace-name",
  "version": "1.0.0",
  "description": "Marketplace description",
  "owner": {
    "name": "Your Name",
    "email": "email@example.com"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "What this plugin does",
      "version": "1.0.0",
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

**Note:** The `source` field supports:
- Relative paths: `"./plugins/my-plugin"` (works when marketplace is added via Git)
- GitHub: `{ "source": "github", "repo": "owner/repo", "ref": "v1.0.0" }`
- Git URL: `{ "source": "url", "url": "https://gitlab.com/team/plugin.git" }`

## Plugin Development

### Manifest (`plugin.json`)
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": { "name": "Name", "email": "email@example.com" },
  "keywords": ["keyword1", "keyword2"]
}
```

### Component Frontmatter Patterns

**Commands** (`commands/*.md`):
```yaml
---
description: What the command does
argument-hint: [action] [args]
allowed-tools: Read, Write, Glob, Bash(gh:*)
---
```

**Agents** (`agents/*.md`):
```yaml
---
name: AgentName
description: When to use this agent with <example> blocks
model: inherit
color: cyan
tools: ["Read", "Write", "Glob", "AskUserQuestion"]
---
```

**Skills** (`skills/*/SKILL.md`):
```yaml
---
name: Skill Name
description: When to apply this skill
version: 1.0.0
---
```

### Tool Restrictions

Commands use `allowed-tools` to restrict access:
- `Read, Write, Edit, Glob` - File operations only
- `Bash(gh:*)` - Only `gh` CLI commands
- `Bash(npm:*, pnpm:*)` - Only npm/pnpm commands

## Available Plugins

### `manager` - GitHub Product Manager
Product management workflow: PRD → TRD → Epic → Issues → Sprints

See `plugins/manager/CLAUDE.md` for details.

## Adding a New Plugin

1. Create `plugins/<name>/` directory
2. Add `.claude-plugin/plugin.json` manifest
3. Add components (commands, agents, skills, templates)
4. Create `CLAUDE.md` with plugin-specific guidance
5. Create `README.md` with user documentation
6. Add entry to `.claude-plugin/marketplace.json`
7. Update root `README.md` with plugin listing
