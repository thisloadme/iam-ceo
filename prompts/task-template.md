# Task Breakdown Template

Use this format when COO receives instruction from CEO and needs to delegate.

## CRITICAL: Scope is REQUIRED

**No scope = no delegation. Task will not be accepted.**

Each task MUST have explicit file/directory list. Vague scopes like "refactor auth" are rejected.

## Template

```
## Task from CEO
[Raw instruction from CEO]

## Breakdown

### Task 1: [Name]
- **Owner**: [frontend-specialist | backend-specialist | tester | perf-security-checker | architect | infra-specialist | docs-writer | self]
- **Scope**: [EXACT files/directories — REQUIRED]
  - `path/to/file1.ext`
  - `path/to/file2.ext`
  - `path/to/directory/`
- **Dependencies**: [none | Task 2, Task 3]
- **Done when**:
  - [ ] [Specific checkable criterion]
  - [ ] [Specific checkable criterion]
- **Quality gate**: required

### Task 2: [Name]
...

## Coordination

| Order | Task | Owner | Blocked by |
|-------|------|-------|------------|
| 1 | Task 1 | backend-specialist | - |
| 2 | Task 2 | frontend-specialist | Task 1 |
| 3 | Task 3 | perf-security-checker | Task 1, Task 2 |

## Parallel Work
[Tasks that can run in parallel, if any]

## Scope Conflicts Check
Before delegating:
- [ ] Run `git status`
- [ ] Verify no other task/agent owns files in scope
- [ ] Confirm files in scope are EXACT, not wildcard

## Reports
After all tasks complete, report to CEO:
- Summary of what was done
- **Files changed**: EXACT list, verified against scope
- Any new contracts/DTOs created
- Any blockers or deferrals
- Quality gate: PASS/FAIL with reason if deferred
```

## Example Usage

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
- **Dependencies**: Task 1 (needs API contract)
- **Done when**:
  - [ ] Profile page displays user data
  - [ ] Avatar upload works
  - [ ] Responsive on mobile
  - [ ] Tests pass
- **Quality gate**: required

### Task 3: Security review (avatar upload)
- **Owner**: perf-security-checker
- **Scope**:
  - `apps/api/app/Services/ProfileService.php`
- **Dependencies**: Task 1
- **Done when**:
  - [ ] File type validation enforced server-side
  - [ ] File size limits enforced
  - [ ] No path traversal possible
- **Quality gate**: mandatory

## Coordination
Task 1 → Task 2 (frontend needs API contract)
Task 1 → Task 3 (security needs to review implementation)

## Parallel Work
Task 2 and Task 3 can run in parallel after Task 1 completes.

## Scope Conflicts Check
- [ ] `apps/api/routes/api.php` only in Task 1 — no conflict
- [ ] `apps/api/app/Http/Controllers/ProfileController.php` only in Task 1 — no conflict
- [ ] `apps/web/pages/profile.vue` only in Task 2 — no conflict
```
