---
description: Brainstorm and explore ideas before creating PRDs or TRDs
argument-hint: [name]
allowed-tools: Read, Write, Glob, AskUserQuestion
---

<!--
Usage:
  /manager:brainstorm user-auth              - Start brainstorming session for user-auth feature
  /manager:brainstorm                        - Start brainstorming session (will ask for name)
  /manager:brainstorm user-auth --continue   - Continue existing brainstorm
-->

Start a guided brainstorming session to explore ideas before creating formal documents.

**Arguments received:** $ARGUMENTS

**Template:** @${CLAUDE_PLUGIN_ROOT}/templates/brainstorm-template.md

**Output:** `docs/planning/<name>/brainstorm.md`

---

## Instructions

1. **Parse arguments:**
   - Extract feature name if provided
   - Check for --continue flag
   - If no name provided, ask user what they want to brainstorm

2. **Check for existing brainstorm:**
   - Look for `docs/planning/<name>/brainstorm.md`
   - If exists and --continue: load and continue
   - If exists and no flag: ask if user wants to continue or start fresh

3. **Create directory if needed:**
   ```bash
   mkdir -p docs/planning/<name>
   ```

4. **Trigger Briana (brainstorming agent):**

   Briana will guide the user through:

   **Phase 1: Problem Exploration**
   - What problem are we solving?
   - Who experiences this problem?
   - How painful is it?

   **Phase 2: User Understanding**
   - Who are the users?
   - What are their goals and pain points?

   **Phase 3: Solution Ideation**
   - What are possible solutions?
   - What's the simplest approach?
   - What's the ideal approach?

   **Phase 4: Evaluation**
   - Which ideas have the best impact/effort ratio?
   - What are the risks?

   **Phase 5: Scope Definition**
   - What's MVP vs future?
   - What's out of scope?

   **Phase 6: Risk Identification**
   - What could go wrong?
   - What assumptions need validation?

5. **Save brainstorm document:**
   - Create/update `docs/planning/<name>/brainstorm.md`
   - Use brainstorm template
   - Mark status as "Draft" or "Ready for PRD"

6. **Suggest next steps:**
   ```
   Brainstorm saved: docs/planning/<name>/brainstorm.md

   Next steps:
   - Continue brainstorming: /manager:brainstorm <name> --continue
   - Create PRD: /manager:prd create <name>
   - Create TRD: /manager:trd create <name>
   ```

---

## Quick Brainstorm Mode

For faster sessions, ask focused questions:

1. "What's the one-sentence problem statement?"
2. "Who's the primary user?"
3. "What's the simplest solution?"
4. "What's MVP scope?"
5. "What's the biggest risk?"

Save as a lightweight brainstorm document.

---

## Session Management

**Starting fresh:**
```
/manager:brainstorm payments
```
Creates new brainstorm session for "payments" feature.

**Continuing:**
```
/manager:brainstorm payments --continue
```
Loads existing brainstorm and continues where left off.

**Listing brainstorms:**
Check `docs/planning/*/brainstorm.md` for existing sessions.
