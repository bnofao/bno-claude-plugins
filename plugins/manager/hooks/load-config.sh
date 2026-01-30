#!/bin/bash
# Manager Plugin - SessionStart Hook
# Loads project configuration from .claude/manager.local.md
# and injects it as context for the session.

set -euo pipefail

# Configuration file path
CONFIG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/manager.local.md"

# Quick exit if no configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  # No config - output minimal JSON (hook continues silently)
  echo '{"continue": true}'
  exit 0
fi

# Parse YAML frontmatter (content between --- markers)
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$CONFIG_FILE")

# Extract key configuration values
REPO=$(echo "$FRONTMATTER" | grep '^repo:' | sed 's/repo: *//' | sed 's/^"\(.*\)"$/\1/' | tr -d "'")
PRD_DIR=$(echo "$FRONTMATTER" | grep '^prd_dir:' | sed 's/prd_dir: *//' | sed 's/^"\(.*\)"$/\1/' | tr -d "'")
DEFAULT_PROJECT=$(echo "$FRONTMATTER" | grep '^default_project:' | sed 's/default_project: *//' | sed 's/^"\(.*\)"$/\1/' | tr -d "'")
PROJECT_OWNER=$(echo "$FRONTMATTER" | grep '^project_owner:' | sed 's/project_owner: *//' | sed 's/^"\(.*\)"$/\1/' | tr -d "'")

# Extract markdown body (content after closing ---)
BODY=$(awk '/^---$/{i++; next} i>=2' "$CONFIG_FILE")

# Set defaults if not specified
REPO="${REPO:-}"
PRD_DIR="${PRD_DIR:-docs/planning}"
DEFAULT_PROJECT="${DEFAULT_PROJECT:-}"
PROJECT_OWNER="${PROJECT_OWNER:-@me}"

# Persist environment variables for bash commands in this session
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  {
    echo "export MANAGER_REPO=\"$REPO\""
    echo "export MANAGER_PRD_DIR=\"$PRD_DIR\""
    echo "export MANAGER_DEFAULT_PROJECT=\"$DEFAULT_PROJECT\""
    echo "export MANAGER_PROJECT_OWNER=\"$PROJECT_OWNER\""
  } >> "$CLAUDE_ENV_FILE"
fi

# Build context message for Claude
CONTEXT_MSG="Manager plugin configuration loaded from .claude/manager.local.md:
- Repository: ${REPO:-<not set - will auto-detect>}
- PRD directory: ${PRD_DIR}
- Default GitHub Project: ${DEFAULT_PROJECT:-<none>}
- Project owner: ${PROJECT_OWNER}"

# Add custom notes if body is not empty
if [[ -n "${BODY// /}" ]]; then
  CONTEXT_MSG="${CONTEXT_MSG}

Project-specific notes:
${BODY}"
fi

# Escape JSON special characters
CONTEXT_MSG_ESCAPED=$(echo "$CONTEXT_MSG" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

# Output JSON with context for Claude
cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "${CONTEXT_MSG_ESCAPED}"
}
EOF
