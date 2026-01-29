# Claude Code Plugin Marketplace

A collection of Claude Code plugins for various workflows.

## Available Plugins

| Plugin | Description | Commands |
|--------|-------------|----------|
| [manager](plugins/manager/) | GitHub product management - PRDs, TRDs, epics, issues, sprints | 10 commands, 7 agents |

## Installation

Install a plugin by pointing to its directory:

```bash
# From GitHub

# Register marketplace
claude plugin marketplace add github:bnofao/bno-claude-plugins

# Install plugin
claude plugin install <plugin-name>@bno-claude-plugins

# From local path
git clone https://github.com/bnofao/bno-claude-plugins.git
claude plugin add /path/to/bno-claude-plugins/plugins/<plugin-name>
```

## Plugin Index

### manager - GitHub Product Manager

**Commands:**
- `/manager:brainstorm` - Explore ideas before creating PRD/TRD
- `/manager:prd` - Create/update product requirements documents
- `/manager:trd` - Create/update technical requirements documents
- `/manager:epic` - Manage GitHub epics as tracking issues
- `/manager:issue` - Manage GitHub issues
- `/manager:parse` - Generate issues from PRD or TRD
- `/manager:status` - View epic/issue progress
- `/manager:sync` - Sync task lists and local files
- `/manager:sprint` - Manage sprints with GitHub Milestones
- `/manager:project` - Manage GitHub Projects integration

**Agents:**
- **Briana** - Brainstorming facilitator
- **Petra** - PRD creation guide
- **Isaac** - User story issue generator
- **Tara** - Technical issue generator
- **Max** - Implementation helper
- **Tina** - Backlog triage and sprint planning
- **Blake** - Bug report creator

**Prerequisites:** GitHub CLI (`gh`) installed and authenticated

[View full documentation →](plugins/manager/README.md)

## Contributing

To add a new plugin:

1. Create `plugins/<plugin-name>/` directory
2. Add `.claude-plugin/plugin.json` manifest
3. Add commands, agents, skills, templates as needed
4. Create `README.md` and `CLAUDE.md`
5. Update this file with the plugin entry

## License

MIT
