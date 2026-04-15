---
name: api-design
description: REST API conventions, naming, versioning, request/response shapes. Use when designing new endpoints or reviewing API contracts.
---

# API Design Skill

## When to Invoke

- Designing new API endpoint
- Reviewing API contract before frontend-backend split
- Creating or updating an API spec

## REST Conventions

### URL Structure
```
GET    /users              # list
POST   /users              # create
GET    /users/{id}         # get one
PUT    /users/{id}         # full update
PATCH  /users/{id}         # partial update
DELETE /users/{id}         # delete

# Nested resources (max 1 level deep)
GET    /users/{id}/orders
POST   /users/{id}/orders
```

### Naming Rules
- Use nouns, not verbs: `/users` not `/getUsers`
- Plural for collections: `/users` not `/user`
- kebab-case only: `/user-profiles` not `/userProfiles`
- No trailing slash: `/users` not `/users/`

### HTTP Status Codes

| Code | Use |
|------|-----|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST that creates) |
| 204 | No content (DELETE) |
| 400 | Bad request (validation error) |
| 401 | Unauthenticated |
| 403 | Forbidden (authenticated but not authorized) |
| 404 | Not found |
| 409 | Conflict (duplicate, version mismatch) |
| 422 | Unprocessable entity (business rule violation) |
| 429 | Rate limited |
| 500 | Server error |

### Versioning
```
# Header versioning (preferred for APIs)
API-Version: 2024-01-01

# URL versioning (simpler, more visible)
GET /v1/users
GET /v2/users
```

## Response Shape

### Success
```json
{
  "data": { ... },
  "meta": { "page": 1, "total": 100 }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Invalid format" }
    ]
  }
}
```

### List/Paginated
```json
{
  "data": [ ... ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

## Request Validation Rules

1. Always validate on server side, even if client validates
2. Return 422 with field-level errors
3. Whitelist allowed fields (reject unknown)
4. Sanitize before use (never trust input)

## Documenting API Contracts

When backend-specialist finishes an endpoint, document:
```
Endpoint: POST /v1/users
Request:
  - body: { name: string required, email: string required, password: string min:8 }
Response:
  - 201: { data: { id, name, email, created_at } }
  - 422: { error: { code: "VALIDATION_FAILED", details: [...] } }
```

## Common Mistakes

- Using 200 for errors → client can't distinguish success/failure
- Returning raw DB rows → always wrap in `data` key
- Missing rate limiting on public endpoints
- No versioning → breaking changes affect all clients
- Verb endpoints: `/users/search` not `/searchUsers`
