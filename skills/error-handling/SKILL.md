---
name: error-handling
description: Error response format, logging boundaries, exception hierarchy. Use when implementing error handling or reviewing error flows.
---

# Error Handling Skill

## When to Invoke

- When implementing error handling for new features
- When creating custom exceptions
- When reviewing error responses
- When debugging unclear error messages

## Core Principle

**Errors are for humans to debug. Don't hide information. Don't leak secrets.**

## Exception Hierarchy

```
Exception (base)
├── DomainException          # Business logic violations
│   ├── ValidationException  # Input validation failed
│   ├── NotFoundException     # Resource not found
│   └── ConflictException    # State conflict (duplicate, version mismatch)
├── InfrastructureException  # External system failures
│   ├── DatabaseException    # DB connection/query failure
│   ├── ExternalAPIException # Third-party API failure
│   └── CacheException        # Cache operation failure
└── AuthenticationException # Auth-related failures
    ├── UnauthorizedException    # Not logged in
    └── ForbiddenException       # Logged in but not allowed
```

## PHP (Laravel) Error Handling

### Custom Exception
```php
<?php

namespace App\Exceptions;

use Exception;

class ValidationException extends Exception
{
    public array $errors;

    public function __construct(array $errors, string $message = 'Validation failed')
    {
        parent::__construct($message);
        $this->errors = $errors;
    }

    public function render($request)
    {
        return response()->json([
            'error' => [
                'code' => 'VALIDATION_FAILED',
                'message' => $this->getMessage(),
                'details' => $this->errors
            ]
        ], 422);
    }
}
```

### Service Layer Error Handling
```php
class PaymentService
{
    public function charge(User $user, Payment $payment): PaymentResult
    {
        try {
            $result = $this->stripe->charge($payment->amount);
            return PaymentResult::success($result);
        } catch (CardDeclinedException $e) {
            return PaymentResult::failed('CARD_DECLINED', $e->getMessage());
        } catch (InsufficientFundsException $e) {
            return PaymentResult::failed('INSUFFICIENT_FUNDS', $e->getMessage());
        } catch (Exception $e) {
            // Log unexpected errors — don't expose to client
            Log::error('Payment failed unexpectedly', [
                'user_id' => $user->id,
                'payment_id' => $payment->id,
                'error' => $e->getMessage()
            ]);
            return PaymentResult::failed('PAYMENT_FAILED', 'An error occurred. Please try again.');
        }
    }
}
```

## Go Error Handling

### Custom Error Type
```go
type ValidationError struct {
    Field   string `json:"field"`
    Message string `json:"message"`
}

type APIError struct {
    Code    string            `json:"code"`
    Message string            `json:"message"`
    Details []ValidationError `json:"details,omitempty"`
}

func (e *APIError) Error() string {
    return e.Message
}
```

### Service Layer Error Handling
```go
func (s *PaymentService) Charge(ctx context.Context, user *User, payment *Payment) (*PaymentResult, error) {
    result, err := s.stripe.Charge(ctx, payment.Amount)
    if err != nil {
        if errors.Is(err, stripe.ErrCardDeclined) {
            return nil, &APIError{
                Code:    "CARD_DECLINED",
                Message: "Your card was declined.",
            }
        }

        // Log unexpected errors with context
        log.Error(ctx, "payment charge failed",
            "user_id", user.ID,
            "payment_id", payment.ID,
            "error", err.Error(),
        )

        return nil, &APIError{
            Code:    "PAYMENT_FAILED",
            Message: "An error occurred. Please try again.",
        }
    }
    return result, nil
}
```

## Error Response Format

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "The requested user was not found.",
    "details": [],
    "trace_id": "abc123"
  }
}
```

### When to Include Details

| Situation | Include Details? |
|-----------|------------------|
| Validation errors | Yes — field-level errors |
| Not found | No — just code + message |
| Rate limited | Yes — include retry-after |
| Server error | No — generic message, log trace_id |
| Auth error | No — don't hint if user exists |

## Logging Rules

### Log at Boundaries (handler level), Not Deep in Logic

```php
// BAD — logging in service layer
class PaymentService
{
    public function charge($amount)
    {
        Log::info("Charging $amount"); // Don't do this
        // ...
    }
}

// GOOD — logging at handler level
class PaymentController
{
    public function charge(Request $request)
    {
        $result = $this->paymentService->charge($request->amount);

        if ($result->failed()) {
            Log::warning('Charge failed', [
                'amount' => $request->amount,
                'error_code' => $result->errorCode
            ]);
        }

        return $result->toResponse();
    }
}
```

### Never Log Secrets
```php
// BAD
Log::info("User login", ['password' => $password]);

// GOOD
Log::info("User login attempt", ['email' => $email]);
```

### Log Error Context (not just message)
```go
// Bad
log.Error("payment failed")

// Good
log.Error("payment failed",
    "user_id", userID,
    "payment_id", paymentID,
    "amount", amount,
    "provider", "stripe",
)
```

## Error Code Reference

| Code | HTTP Status | Use When |
|------|-------------|----------|
| VALIDATION_FAILED | 422 | Input validation fails |
| NOT_FOUND | 404 | Resource doesn't exist |
| UNAUTHORIZED | 401 | Not authenticated |
| FORBIDDEN | 403 | Authenticated but not allowed |
| CONFLICT | 409 | Duplicate or version mismatch |
| RATE_LIMITED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Unexpected server error |

## Checklist

- [ ] All exceptions have appropriate HTTP status code
- [ ] Error messages are human-readable (not internal codes leaked)
- [ ] No secrets in error messages or logs
- [ ] All errors logged at boundary with trace context
- [ ] Client gets generic message for 500 errors
- [ ] Validation errors include field-level details
