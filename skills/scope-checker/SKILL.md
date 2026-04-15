---
name: scope-checker
description: Verify changed files match task scope exactly. Prevents scope creep and boundary violations.
---

# Scope Checker Skill

**MANDATORY. Run before delegating any task and before marking task complete.**

## When to Invoke

1. **Before delegation** — Verify no conflicts, scope is explicit
2. **After task completion** — Verify agent stayed within scope
3. **Any time scope compliance is uncertain**

## Pipeline

### 1. Get Changed Files

```bash
# Staged changes
git diff --cached --name-only

# Unstaged changes
git diff --name-only

# All changes (staged + unstaged)
git diff --name-only HEAD
```

### 2. Verify Against Scope

Given task scope:
```
- apps/api/routes/api.php
- apps/api/app/Http/Controllers/ProfileController.php
- apps/api/app/Services/ProfileService.php
```

Check each changed file:
- Is it in scope? → OK
- Is it NOT in scope? → VIOLATION

### 3. Check for Conflicts

```bash
# Files modified but not committed (another agent working?)
git status --short
```

### 4. Output

```
## Scope Check

### Changed Files
- file1.ext
- file2.ext

### Scope Verification
| File | In Scope? |
|------|-----------|
| file1.ext | YES |
| file2.ext | NO ← VIOLATION |

### Conflicts Detected
[None / list conflicts]

**Verdict:** [CLEAN / VIOLATION / CONFLICT]

If VIOLATION:
- Out-of-scope files: [list]
- Violated by: [agent name or "self"]
- Action required: Report to COO immediately
```

## Violation Response

If scope violation detected:
1. **STOP** — do not proceed
2. Report to COO with exact list of violated files
3. Do NOT claim task is complete
4. COO will determine if scope needs expansion or agent overstepped

## Script

```bash
bash skills/scope-checker/check_scope.sh [scope_file1 scope_file2 ...]
```

If no scope files provided, script will prompt for scope entry.
