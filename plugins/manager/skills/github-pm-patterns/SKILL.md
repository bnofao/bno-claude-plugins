---
name: GitHub Product Management Patterns
description: Use this skill when working with PRDs, TRDs, GitHub issues, epics, sprints, or product management workflows. Provides best practices for writing effective PRDs and TRDs, structuring epics, writing good user stories, defining testable acceptance criteria, and managing sprints.
version: 2.0.0
---

# GitHub Product Management Patterns

Best practices for managing product requirements and GitHub issues effectively.

## PRD Best Practices

### Structure
A PRD should answer: What are we building? Why? For whom? How will we know it's done?

**Essential sections:**
1. **Overview** - 2-3 sentence elevator pitch
2. **Problem Statement** - Current pain, desired state, impact
3. **Goals** - Measurable objectives and explicit non-goals
4. **Success Metrics** - How we measure success (table format)
5. **Features & Requirements** - Prioritized with P0/P1/P2
6. **User Experience** - Flows and wireframes
7. **Technical Constraints** - Performance, scalability, integrations
8. **Security & Compliance** - Auth, privacy, regulations
9. **Dependencies** - Blockers and related work
10. **Timeline & Milestones** - Phased delivery plan

### Feature Priority Levels
- **P0 (Must-Have)** - Core functionality, launch blockers → `priority:high`
- **P1 (Should-Have)** - Important but not blocking → `priority:medium`
- **P2 (Nice-to-Have)** - Can defer to later release → `priority:low`

### Feature Block Format
```markdown
#### Feature 1: [Feature Name]
- **Description:** [Detailed description]
- **User Story:** As a [user type], I want to [action] so that [benefit]
- **Acceptance Criteria:**
  - [ ] [Criterion 1]
  - [ ] [Criterion 2]
- **Dependencies:** [Any dependencies]
```

### Writing Tips
- Keep overview under 50 words
- Make goals measurable ("reduce load time to <2s" not "make it faster")
- Include non-goals to prevent scope creep
- Group features by priority (P0 first)
- Link to TRD for technical details

## TRD Best Practices

### When to Create a TRD
- Complex features requiring architectural decisions
- Features with significant API or database changes
- Security-sensitive implementations
- Performance-critical features

### Structure
1. **Overview** - Technical summary and approach
2. **Architecture** - Components, data flow, tech stack
3. **API Specification** - Endpoints, request/response, errors
4. **Database Design** - Tables, schema changes, migrations
5. **Security** - Auth, authorization, threat model
6. **Performance** - Requirements, caching, scaling
7. **Observability** - Logging, metrics, alerts
8. **Dependencies** - External services, libraries
9. **Testing Strategy** - Unit, integration, load tests
10. **Rollout Plan** - Feature flags, deployment stages

### Components Table
```markdown
| Component | Technology | Purpose | Dependencies |
|-----------|------------|---------|--------------|
| Frontend | Next.js | User interface | API |
| Backend API | Laravel | Business logic | Database |
| Database | PostgreSQL | Data storage | - |
```

### API Endpoint Format
```markdown
#### `POST /auth/login`
**Description**: Authenticate user and return token

**Request**:
```json
{ "email": "string", "password": "string" }
```

**Response**:
```json
{ "token": "string", "expires_at": "datetime" }
```

**Error Codes**:
- `400` - Invalid request body
- `401` - Invalid credentials
```

## User Story Format

**Template:**
```
As a [user type]
I want to [action/capability]
So that [benefit/value]
```

**Good examples:**
- "As a customer, I want to save items to a wishlist, so that I can purchase them later"
- "As an admin, I want to export user data as CSV, so that I can analyze it in Excel"

**Bad examples:**
- "As a user, I want the system to be fast" (not specific)
- "As a developer, I want to refactor the auth module" (technical task, not user story)

### INVEST Criteria
Good user stories are:
- **I**ndependent - Can be implemented alone
- **N**egotiable - Details can be discussed
- **V**aluable - Delivers value to users
- **E**stimable - Team can estimate effort
- **S**mall - Fits in one sprint
- **T**estable - Has clear acceptance criteria

## Acceptance Criteria

### Format
Use checkboxes for clear pass/fail testing:
```
- [ ] User can enter email and password
- [ ] Invalid credentials show error message within 2 seconds
- [ ] Successful login redirects to dashboard
- [ ] Session persists across browser refresh
```

### Guidelines
- Start with action verbs (User can..., System displays..., API returns...)
- Be specific about values ("within 2 seconds" not "quickly")
- Include error cases and edge cases
- Avoid implementation details ("uses Redis cache")
- Each criterion should be independently testable

### Common Patterns

**Form validation:**
- [ ] Required fields show error if empty
- [ ] Email field validates format
- [ ] Error messages appear next to invalid fields

**API endpoints:**
- [ ] Returns 200 with data on success
- [ ] Returns 400 with error message for invalid input
- [ ] Returns 401 for unauthenticated requests

**UI behavior:**
- [ ] Loading indicator shows during request
- [ ] Success message appears after save
- [ ] User can undo action within 5 seconds

## Epic Structure

### What is an Epic?
An epic is a large feature broken into smaller issues. In GitHub, implement epics as tracking issues.

### Epic as Tracking Issue
Create a GitHub issue with:
- Title prefixed with `[Epic]`
- Links to source PRD and TRD
- Task list linking to child issues
- Epic-level acceptance criteria

**Template:**
```markdown
## Overview
[Brief description of the epic and its goals]

## Source Documents
- **PRD**: [Link to PRD file]
- **TRD**: [Link to TRD file or "N/A"]

## Tasks
- [ ] #123 As a user, I want to login
- [ ] #124 As a user, I want to logout
- [ ] #125 As a user, I want to reset password

## Acceptance Criteria
- [ ] All linked issues are closed
- [ ] Feature is documented
- [ ] No critical bugs remain
```

### Benefits of Task Lists
- GitHub auto-tracks completion percentage
- Checkboxes update when issues close
- Visual progress indicator in issue list
- Easy to see blocked/remaining work

## Bug Reports

### Structure
```markdown
## Bug Summary
[One sentence describing the bug]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [Step where bug occurs]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- Browser: Chrome 120.0
- OS: macOS 14.2
- App Version: v2.1.0
```

### Good Bug Reports
- Specific reproduction steps (numbered)
- Clear expected vs actual behavior
- Environment details included
- Screenshots or error logs if applicable

## Sprint Management

### Sprint Structure
```markdown
## Goals
- [ ] Complete user login flow
- [ ] Set up authentication service

## Issues
| Issue | Title | Type | Priority | Status |
|-------|-------|------|----------|--------|
| #55 | Login endpoint | task | high | open |
```

### Sprint Lifecycle
1. **Planning** - Select issues, set goals
2. **Active** - Create GitHub Milestone, assign issues
3. **Completed** - Close milestone, retrospective

### Best Practices
- Keep sprints 1-2 weeks
- Don't overcommit (leave buffer)
- Include mix of P0 and P1 items
- Track velocity over time

## Labeling Strategy

### Type Labels
- `type:feature` - New functionality
- `type:task` - Technical work (refactoring, infrastructure)
- `type:bug` - Fix to existing functionality
- `epic` - Tracking issue for epic

### Priority Labels
- `priority:high` - Must have, blocks other work (P0)
- `priority:medium` - Should have, standard priority (P1)
- `priority:low` - Nice to have, can defer (P2)

### Status Labels (optional)
- `status:blocked` - Waiting on dependency
- `status:in-review` - PR submitted
- `status:needs-info` - Waiting for clarification

## Workflow Patterns

### Full Workflow: PRD → TRD → Epic → Issues
1. Write PRD with features (P0/P1/P2)
2. Create TRD for technical specs (optional)
3. Create epic tracking issue
4. Generate user story issues from PRD
5. Generate technical issues from TRD
6. Create sprint and assign issues
7. Track progress and sync

### Sizing Guidelines
- **Epic**: 1-4 weeks of work
- **Feature/Issue**: 1-3 days of work
- **Sprint**: 1-2 weeks
- If larger, break it down

### Progress Tracking
- Update epic task list when issues close
- Use `/manager:sync` to auto-update checkboxes
- Review epic progress in `/manager:status`
- Track sprint burndown

## Common Mistakes

### PRD Mistakes
- Too vague ("make it better")
- No acceptance criteria
- Missing non-goals (scope creeps)
- Technical implementation in requirements
- No priority levels

### TRD Mistakes
- Missing API error codes
- No rollback plan
- Ignoring security considerations
- No performance requirements

### Issue Mistakes
- Title doesn't describe the work
- No acceptance criteria
- Missing context/why
- Too large (should be multiple issues)

### Epic Mistakes
- No tracking issue, just a label
- Not linking PRD/TRD
- Not linking issues to epic
- Too broad (multiple features mixed)
- Not updating progress

### Sprint Mistakes
- Overcommitting capacity
- No clear sprint goal
- Not using milestones
- Skipping retrospectives

## Quick Reference

| Item | Format |
|------|--------|
| **PRD** | What + Why + For Whom + Done When |
| **TRD** | How (architecture, APIs, database) |
| **Feature** | Description + User Story + Acceptance Criteria |
| **User Story** | As a [who], I want [what], so that [why] |
| **Acceptance Criteria** | Testable checkbox items |
| **Epic** | Tracking issue with PRD/TRD links + task list |
| **Sprint** | Goals + Issues + Milestone |
| **Labels** | type:{feature,task,bug} + priority:{high,medium,low} |
