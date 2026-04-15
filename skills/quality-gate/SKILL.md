---
name: quality-gate
description: Run full quality check pipeline. Tests, lint, security. MANDATORY before declaring any task done.
---

# Quality Gate Skill

**THIS SKILL IS MANDATORY. No task may be marked complete without running this.**

## When to Invoke

**BEFORE marking any task "done" — always, without exception.**

- Before handing off to another agent
- Before reporting to CEO that work is complete
- When task involves auth, payments, concurrency, data integrity

## Pipeline Steps

### 1. Verify Scope Compliance

First, verify agent stayed within scope:
```bash
git diff --name-only
git diff --cached --name-only
```

Confirm all changed files are in the task scope. If out-of-scope files were touched:
- **STOP**
- Report scope violation to COO
- Task is NOT complete

### 2. Run Checks

**Use the script when available:**
```bash
bash skills/quality-gate/run_checks.sh
```

**If script unavailable or fails, run manually:**

```bash
# Secrets scan
git diff --cached --name-only | xargs grep -l "password\s*=\s*['\"][^'\"]{8}" 2>/dev/null || true

# Debug code scan
git diff --cached --name-only | xargs grep -l "console\.log\|console\.error\|print_r\|var_dump\|fmt\.Println" 2>/dev/null || true

# TODO/FIXME scan (optional — note only)
git diff --cached --name-only | xargs grep -l "TODO\|FIXME\|XXX" 2>/dev/null || true
```

### 3. Run Tests

**PHP/Laravel:**
```bash
cd apps/api && ./vendor/bin/pest --filter="relevant_test_name" 2>/dev/null || ./vendor/bin/pest
```

**Go:**
```bash
cd apps/go-worker && go test ./... -short
```

**Node/Frontend:**
```bash
cd apps/web && npm test -- --run 2>/dev/null || npm test
```

**Python:**
```bash
cd apps/api && pytest -v --tb=short
```

### 4. Security Spot Check

For each changed file:
- [ ] No credentials/secrets inline
- [ ] No user input used directly in queries
- [ ] Error messages don't leak internal details

## Output Summary

```
## Quality Gate Results

**Task:** [one-liner]
**Scope verified:** [YES/NO — if NO, STOP here]

### Checks Run
| Check | Result |
|-------|--------|
| Scope compliance | PASS/FAIL |
| Secrets scan | CLEAN/ISSUES |
| Debug code | CLEAN/ISSUES |
| Tests | PASS/FAIL |

### Issues Found
| Severity | File | Issue |
|----------|------|-------|
| - | - | None |

**Verdict:** [PASS / FAIL / DEFERRED with CEO approval]

If DEFERRED:
- Reason: [why tests cannot pass now]
- CEO approval: [YES/NO]
```

## Fail Conditions

**Task is NOT complete if:**
- Any test fails (without CEO-approved deferral)
- Secrets or credentials found
- Security vulnerability introduced
- Scope was violated (out-of-scope files touched)

**Task CAN be complete if:**
- Linter warnings only (not errors)
- Non-critical performance suggestions

## Deferral Process

Only CEO can approve deferral. State clearly:
```
Quality gate DEFERRED (CEO approved):
- Reason: [why]
- Will be resolved by: [who]
- Deadline: [when]
```
