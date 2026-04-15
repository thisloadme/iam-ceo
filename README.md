# IAM CEO Framework

**Agentic Engineering Workflow for Claude Code**

A structured workflow framework that transforms Claude Code from a solo coding assistant into an orchestrated team with clear roles, enforced boundaries, and quality gates.

---

## What is this?

IAM CEO (I'll Act as Manager, Chief Executive Officer) is a workflow framework for Claude Code that implements a **CEO → COO → Specialists** hierarchy:

```
Human (CEO)
    │
    ▼
Claude Code Session (COO)
    │
    ├──▶ frontend-specialist
    ├──▶ backend-specialist
    ├──▶ tester
    ├──▶ perf-security-checker
    ├──▶ architect
    ├──▶ infra-specialist
    └──▶ docs-writer
```

**The problem it solves:** Without structure, Claude Code handles everything — frontend, backend, security, docs — with no clear boundaries. This leads to scope creep, forgotten quality checks, and inconsistent output.

**The solution:** The COO (main Claude session) orchestrates. Specialists handle domains. Quality gates enforce standards. Scope compliance prevents drift.

---

## Features

- **Role-based specialization** — 7 specialist agents with clear boundaries
- **Mandatory quality gates** — No task marked complete without verification
- **Scope enforcement** — No vague scopes, no out-of-scope edits
- **Language-agnostic** — Works with any language (PHP, Go, JS, Python, etc.)
- **Model-agnostic** — Works with any Claude-compatible LLM
- **Token-efficient** — Self-code for trivial tasks, delegate only when needed

---

## Installation

### 1. Copy framework files to your project

```bash
# Clone or copy the framework into your project
git clone https://github.com/thisloadme/iam-ceo
cp -r iam-ceo/. /path/to/your/project/.claude/
```

Or create the structure manually:

```text
your-project/
├── .claude/
│   ├── CLAUDE.md          # COO manual (required)
│   ├── AGENTS.md          # Org chart (required)
│   ├── agents/            # Specialist definitions
│   │   ├── frontend-specialist.md
│   │   ├── backend-specialist.md
│   │   ├── tester.md
│   │   ├── perf-security-checker.md
│   │   ├── architect.md
│   │   ├── infra-specialist.md
│   │   └── docs-writer.md
│   └── skills/            # Skills with optional scripts
│       ├── quality-gate/
│       ├── scope-checker/
│       ├── api-design/
│       ├── git-workflow/
│       ├── testing-strategy/
│       ├── error-handling/
│       └── sql-migration/
└── prompts/               # Task templates
    └── task-template.md
```

### 2. Configure Claude Code

Ensure your `CLAUDE.md` in the project root (or `.claude/CLAUDE.md`) loads the framework context. The framework's `CLAUDE.md` is designed to be read as part of Claude's system prompt.

### 3. You're ready

Start a Claude Code session. Claude will read `CLAUDE.md` and `AGENTS.md` automatically.

---

## Usage

### As CEO (Human)

Give instructions to the COO (Claude Code). Be clear but don't micromanage:

```
CEO: "Add user profile page with avatar upload"
```

The COO will:
1. Break the task into atomic items
2. Assign to appropriate specialists
3. Enforce quality gates
4. Report back with verification

### As COO (Claude Code)

When CEO gives an instruction:

1. **Parse the request** — What needs to be built?
2. **Break into tasks** — Use `prompts/task-template.md` format
3. **Assign to specialists** — Match task scope to agent domain
4. **Verify scope compliance** — Run `scope-checker` before delegation
5. **Enforce quality gates** — Run `quality-gate` before completion
6. **Report to CEO** — Summary, files changed, blockers

---

## Task Breakdown Example

When you ask the COO to build something, it responds with a structured breakdown:

```
## Task from CEO
"Add user profile page with avatar upload"

## Breakdown

### Task 1: API endpoint for profile
- **Owner**: backend-specialist
- **Scope**:
  - `apps/api/routes/api.php`
  - `apps/api/app/Http/Controllers/ProfileController.php`
  - `apps/api/app/Services/ProfileService.php`
- **Dependencies**: none
- **Done when**:
  - [ ] GET /api/profile returns user data
  - [ ] PUT /api/profile updates user data
  - [ ] Avatar upload stores file, returns URL
  - [ ] Tests pass
- **Quality gate**: required

### Task 2: Frontend profile page
- **Owner**: frontend-specialist
- **Scope**:
  - `apps/web/pages/profile.vue`
  - `apps/web/components/AvatarUpload.vue`
  - `apps/web/stores/user.ts`
- **Dependencies**: Task 1
- **Quality gate**: required

### Task 3: Security review
- **Owner**: perf-security-checker
- **Scope**: `apps/api/app/Services/ProfileService.php`
- **Dependencies**: Task 1
- **Quality gate**: mandatory

## Coordination
Task 1 → Task 2, Task 3 (parallel after Task 1)
```

---

## Before vs After

### Before IAM CEO Framework

**CEO:** "Add login with Google OAuth"

**Claude (solo):**
```
Okay, I'll add Google OAuth login. Let me:
- Create the OAuth controller
- Add the Vue login component
- Set up the Google API credentials
- Handle the callback
- Add tests
- Update the README
- Check for security issues
```

**Problems:**
- Single session handles everything → inconsistent depth
- No clear scope → scope creep likely
- Quality checks forgotten → bugs slip through
- No boundaries → backend touches frontend, vice versa
- Token waste → spawning agents for trivial tasks

---

### After IAM CEO Framework

**CEO:** "Add login with Google OAuth"

**COO (Claude):**
```
## Task from CEO
Add login with Google OAuth

## Breakdown

### Task 1: Backend OAuth flow
- **Owner**: backend-specialist
- **Scope**:
  - `apps/api/routes/api.php`
  - `apps/api/app/Http/Controllers/GoogleAuthController.php`
  - `apps/api/app/Services/GoogleAuthService.php`
- **Done when**: [ ] OAuth redirect works, [ ] Callback stores user, [ ] JWT issued
- **Quality gate**: required

### Task 2: Frontend OAuth button
- **Owner**: frontend-specialist
- **Scope**:
  - `apps/web/pages/login.vue`
  - `apps/web/components/GoogleButton.vue`
- **Dependencies**: Task 1
- **Quality gate**: required

### Task 3: Security review
- **Owner**: perf-security-checker
- **Scope**: `apps/api/app/Services/GoogleAuthService.php`
- **Dependencies**: Task 1
- **Quality gate**: mandatory

## Scope conflicts check
[ ] Verified: no file conflicts

## Delegating tasks now...
```

**After specialist work, COO runs quality gate:**

```
## Quality Gate Results

**Task**: Backend OAuth flow

### Checks Run
| Check | Result |
|-------|--------|
| Scope compliance | PASS |
| Secrets scan | CLEAN |
| Debug code | CLEAN |
| Tests | PASS |

**Verdict**: PASS

---

**Task**: Frontend OAuth button

### Checks Run
| Check | Result |
|-------|--------|
| Scope compliance | PASS |
| Secrets scan | CLEAN |
| Debug code | CLEAN |
| Tests | PASS |

**Verdict**: PASS
```

**After all tasks complete, COO reports to CEO:**

```
## Completed: Google OAuth Login

### Summary
- Backend: OAuth controller + service implemented
- Frontend: Login page + Google button component
- Security: Token handling reviewed, no issues

### Files changed
- apps/api/routes/api.php
- apps/api/app/Http/Controllers/GoogleAuthController.php
- apps/api/app/Services/GoogleAuthService.php
- apps/web/pages/login.vue
- apps/web/components/GoogleButton.vue

### New API contract
POST /api/auth/google
Response: { token: string, user: User }

### Blockers
None.

### Quality gate
All tasks passed quality gate.
```

---

## Specialist Agents

| Agent | Scope | When to Use |
|-------|-------|-------------|
| `frontend-specialist` | UI, components, styling, state | UI work >2 files |
| `backend-specialist` | APIs, services, migrations, workers | Backend work >2 files |
| `tester` | Unit, integration, E2E tests | Need test coverage |
| `perf-security-checker` | Security audit, performance review | Auth, payments, concurrency |
| `architect` | System design, ADR, API contracts | Complex design decisions |
| `infra-specialist` | Docker, CI/CD, cloud configs | Explicit infra requests |
| `docs-writer` | README, API docs, ADRs | Documentation needs |

---

## Skills

Skills are invoked via the `Skill` tool in Claude Code. Each skill contains best practices and optional scripts.

| Skill | Purpose |
|-------|---------|
| `quality-gate` | Run full test + security pipeline (MANDATORY) |
| `scope-checker` | Verify changed files match task scope |
| `api-design` | REST conventions, naming, versioning |
| `git-workflow` | Commit format, branch naming, PR checklist |
| `testing-strategy` | What to test, depth, avoiding flakiness |
| `error-handling` | Exception hierarchy, response format |
| `sql-migration` | Migration format for Laravel/Go |

---

## Key Principles

### When to Delegate vs Self-Code

**Self-code (COO handles directly):**
- Trivial changes: 1-2 files, <30 min
- Fix typos, formatting, obvious bugs
- Adding comments or docs

**Delegate to specialist:**
- Multi-file changes with different domain concerns
- Tasks needing deep specialization
- Tasks needing parallel execution

### Scope is Mandatory

**No scope = no delegation.** Each task must specify exact files/directories.

### Quality Gate is Mandatory

**No exceptions.** Run `quality-gate` skill before marking any task complete.

### Boundaries are Enforced

Each specialist has explicit boundaries. Out-of-scope edits = task not done.

---

## Framework Files

```
.claude/
├── CLAUDE.md              # COO manual — rules and SOPs
├── AGENTS.md              # Org chart — roles and boundaries
├── agents/
│   ├── frontend-specialist.md
│   ├── backend-specialist.md
│   ├── tester.md
│   ├── perf-security-checker.md
│   ├── architect.md
│   ├── infra-specialist.md
│   └── docs-writer.md
├── skills/
│   ├── quality-gate/
│   │   ├── SKILL.md
│   │   └── run_checks.sh
│   ├── scope-checker/
│   │   ├── SKILL.md
│   │   └── check_scope.sh
│   ├── api-design/
│   │   └── SKILL.md
│   ├── git-workflow/
│   │   └── SKILL.md
│   ├── testing-strategy/
│   │   └── SKILL.md
│   ├── error-handling/
│   │   └── SKILL.md
│   └── sql-migration/
│       └── SKILL.md
└── prompts/
    └── task-template.md
```

---

## Extending the Framework

### Add a new agent

1. Create `agents/<name>.md` with the standard template
2. Add entry in `AGENTS.md` role matrix
3. Define: domain, boundaries, output format

### Add a new skill

1. Create `skills/<name>/SKILL.md`
2. Optionally add `run_checks.sh` or similar script
3. Document invocation in skill file

### Customize for your stack

Edit agent definitions to match your:
- Tech stack (PHP/Laravel, Go, Node, Python, etc.)
- Directory structure
- Testing framework
- Naming conventions

---

## Requirements

- Claude Code or any Claude-compatible LLM with tool use
- No external dependencies — pure markdown + optional shell scripts
- Git (for scope verification via `git diff`)

---

## License

MIT. Use freely. Modify as needed.
