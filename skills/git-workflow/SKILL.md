---
name: git-workflow
description: Commit conventions, branch naming, PR format. Use before committing or submitting PR.
---

# Git Workflow Skill

## When to Invoke

- Before creating a commit
- Before submitting a PR
- When resolving merge conflicts
- When naming a branch

## Branch Naming

```
<type>/<ticket>-<short-description>

Types:
  feat/     New feature
  fix/      Bug fix
  refactor/ Code restructure (no behavior change)
  docs/     Documentation only
  test/     Tests only
  chore/    Maintenance, deps, config
  hotfix/   Production emergency fix

Examples:
  feat/AUTH-42-add-google-oauth
  fix/PAY-15-refund-webhook-race-condition
  refactor/USR-88-extract-payment-service
  hotfix/PAY-99-card-charge-duplicate
```

## Commit Format

```
<type>(<scope>): <short summary>

[optional body - explain WHY, not WHAT]

[optional footer - BREAKING CHANGE or ticket refs]

---

Format rules:
- Subject line: 72 chars max, imperative mood, no period
- Subject: lowercase for feat/fix, uppercase for config/ci
- Body: wrap at 72 chars, explain motivation and contrast with before
- Footer: reference ticket: "Closes #123" or "Refs #456"
```

### Commit Types

| Type | When to use |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| refactor | Restructure code, no behavior change |
| docs | Documentation only |
| style | Formatting, whitespace (not CSS) |
| test | Adding/updating tests |
| chore | Build, deps, CI config |
| perf | Performance improvement |
| ci | CI/CD changes |

### Examples

```
# Good
feat(auth): add Google OAuth login
Implement OAuth 2.0 flow with Google identity platform.
Store refresh tokens encrypted. Closes #42.

# Good - bug fix
fix(payment): prevent double charge on webhook retry
Stripe may retry failed webhooks. Idempotency key now prevents
duplicate charges. Fixes #88.

# Bad - too vague
fix: bug fix

# Bad - explains what, not why
feat: add getUserById function to UserService

# Bad - imperative wrong
feat: added login feature
```

## PR Format

```markdown
## Summary
[1-3 sentences: what changed and why]

## Changes
- [file]: [what changed]
- [file]: [what changed]

## Testing
- [ ] Tested locally
- [ ] Tests pass
- [ ] Edge cases covered (if applicable)

## Screenshots (if UI change)
[Before] [After]

Closes #[ticket]
```

## Merge Strategy

```
# Use squash merge for feature branches
git merge --squash feature/AUTH-42-google-oauth

# Use merge commit for integration branches
git merge --no-ff release/v1.2.0

# Use rebase for pulling from main
git rebase main
```

## Avoiding Conflicts

1. Small, frequent commits (less surface for conflict)
2. Avoid large refactors mixed with features
3. Keep master/main clean — feature branches are disposable
4. If conflict unavoidable: resolve carefully, prefer "theirs" or "ours" explicitly, never auto-merge blindly

## Commit Message Check

Before committing, verify:
- [ ] Subject describes WHAT changed in imperative mood
- [ ] Body explains WHY, not WHAT
- [ ] No secrets, credentials, or sensitive data
- [ ] Ticket number referenced if exists
- [ ] Tests updated if behavior changed
