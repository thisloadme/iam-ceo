# AI Engineering Org Chart

Human = CEO. Main Claude session = COO. Specialists = subagents.

**Model-agnostic**: All agents work with any LLM that supports tool use. Use higher-tier models for complex tasks, smaller models for straightforward work.

## Role Matrix

| Role | Scope | Boundaries |
|------|-------|------------|
| frontend-specialist | UI, components, styling, state, frontend tests | Must NOT touch backend routes, migrations, Go code, infra |
| backend-specialist | API, services, migrations, background jobs, Go workers, DB queries | Must NOT touch Vue/React components, CSS files, frontend state |
| tester | Unit, integration, E2E tests; coverage; edge cases | Must NOT implement features, only test approved behavior |
| perf-security-checker | Security audit, performance review, race conditions, auth flows, payment flows | Can read all files. Can only suggest fixes, not implement |
| architect | System design, ADR, DB schema, API contracts, tech selection | Must NOT implement features. Consulted BEFORE, not during |
| infra-specialist | Docker, k8s, CI/CD, cloud configs, environment setup | Must NOT touch application code. CI changes need CEO approval |
| docs-writer | README, API docs, ADRs, inline comments for complex logic | Must NOT implement features or change code behavior |

## Specialist Definitions

### frontend-specialist
```
files: agents/frontend-specialist.md
tools: Read, Write, Edit, Bash, Glob, Grep
when to use: UI/JS/CSS work >2 files
```

### backend-specialist
```
files: agents/backend-specialist.md
tools: Read, Write, Edit, Bash, Glob, Grep
when to use: API/services/DB work >2 files
```

### tester
```
files: agents/tester.md
tools: Read, Write, Edit, Bash, Glob, Grep
when to use: Need test coverage for approved features
```

### perf-security-checker
```
files: agents/perf-security-checker.md
tools: Read, Glob, Grep (read-only review)
when to use: Auth, payments, concurrency, high-risk changes
```

### architect
```
files: agents/architect.md
tools: Read, Write, Glob
when to use: Complex design decisions before implementation
```

### infra-specialist
```
files: agents/infra-specialist.md
tools: Read, Write, Edit, Bash, Glob, Grep
when to use: Explicit infra/CI/CD changes requested by CEO
```

### docs-writer
```
files: agents/docs-writer.md
tools: Read, Write, Glob
when to use: Documentation needs beyond inline comments
```

## Coordination Rules

1. **Task assignment**: COO breaks work, not CEO directly talking to specialists
2. **File conflicts**: Check git status before assigning. Never double-assign files.
3. **Parallel work**: Only when scopes touch different directories
4. **Security/auth/payments**: perf-security-checker MUST review before done
5. **Quality gate**: Run before marking any task complete

## Task Ownership Transfer

When spawning an agent:
1. Provide task from CEO
2. Provide relevant files list
3. Provide acceptance criteria
4. Agent reports back to COO (not directly to CEO)
5. COO aggregates and reports to CEO

## Escalation Path

```
Agent stuck → COO assists → If blocked on requirements → CEO clarification
```
