---
name: testing-strategy
description: What to test, test depth, avoiding flakiness. Use when writing tests or deciding test coverage.
---

# Testing Strategy Skill

## When to Invoke

- When writing tests for a new feature
- When deciding coverage targets
- When tests are flaky or over-engineered
- Before marking a task "done" — verify test coverage is appropriate

## Test Pyramid

```
        /\
       /  \     E2E (few, slow, expensive)
      /----\    ————————————————
     /      \   Integration (some, medium)
    /--------\  ——————————————————
   /          \ Unit (many, fast, cheap)
  /____________\
```

Rule: More unit tests than integration, more integration than E2E.

## What to Test

### Unit Tests (majority)

Test single functions/methods in isolation.

**Good candidates:**
- Business logic (discount calculation, validation rules)
- Service classes (PaymentService.charge())
- Utility functions (date formatting, string manipulation)
- Edge cases (empty input, max values, null handling)

**Bad candidates:**
- Framework internals (Laravel's Eloquent)
- One-line getters/setters
- Type casting that framework handles

### Integration Tests

Test how components work together.

**Good candidates:**
- Database operations (Repository + DB)
- API endpoints (full request/response cycle)
- File system operations
- Cache behavior

**Bad candidates:**
- External API calls (mock these)
- Complex async flows (test in unit + mock)

### E2E Tests (minimal)

Test critical user journeys.

**Good candidates:**
- Login flow (auth works end-to-end)
- Payment checkout (from cart to confirmation)
- Critical form submissions

**Bad candidates:**
- Every button click
- UI interactions that don't affect data

## Test Naming

```
test('[scenario] returns [expected] when [condition]')

Examples:
test('returns 404 when user not found')
test('calculates discount correctly for VIP members')
test('throws ValidationException when email invalid')
test('sends welcome email after successful registration')
```

## Avoiding Flaky Tests

1. **No async timing assumptions** — don't test real timeouts
2. **Isolate from external services** — mock HTTP, DB, file system
3. **Deterministic data** — factories with predictable values
4. **No shared state** — each test sets up its own data
5. **Avoid sleep()** — use event waiting instead

```php
// BAD - flaky
test('shows success message after save', function () {
    $form->save();
    sleep(1); // arbitrary wait
    expect($page->successMessage)->toBeVisible();
});

// GOOD - deterministic
test('shows success message after save', function () {
    $form->save();
    $this->assertDatabaseHas('forms', ['status' => 'saved']);
    expect($page->successMessage)->toBeVisible();
});
```

## Test Depth

### Too Shallow (skip this)
```javascript
test('User model exists', () => {
    expect(new User()).toBeDefined()
})
```

### Too Deep (over-engineering)
```javascript
test('User model has correct id type when created in batch of 1000 with various configurations', () => {
    // 500 lines of setup for trivial assertion
})
```

### Right Depth
```javascript
test('name is required', async () => {
    const user = await createUser({ name: null })
    expect(user.errors.name).toContain('Name is required')
})
```

## Coverage Targets

Don't chase 100% coverage — it's theater.

| Layer | Realistic Target |
|-------|------------------|
| Business logic | 80-90% |
| Service layer | 70-80% |
| API endpoints | 60-70% |
| UI components | Focus on critical paths only |

Focus coverage on:
- Logic with branches (if/else, switch)
- Edge cases (null, empty, max values)
- Error paths (exceptions, validation failures)
- Critical paths (auth, payments)

## What NOT to Test

- Framework code (Laravel, Django, Rails internals)
- Compiled output
- Private methods directly (test public behavior)
- Configuration files
- Trivial code (accessors that just return values)

## Test Checklist

Before marking tests "done":
- [ ] Happy path covered
- [ ] Main edge cases covered
- [ ] Error path tested
- [ ] No `console.log` or debug code
- [ ] Tests are deterministic (pass 3x in a row)
- [ ] Follow existing test patterns in codebase
