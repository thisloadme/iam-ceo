---
name: sql-migration
description: Enforce consistent SQL migration format for Laravel, Go migrations, or general DB changes.
---

# SQL Migration Format Skill

## When to Invoke

- Creating new migration
- Modifying existing migration before it's committed
- Reviewing migration for consistency

## Laravel Migration Format

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('table_name', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name', 191);
            $table->text('description')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['user_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('table_name');
    }
};
```

## Rules

1. **Naming**: `YYYY_MM_DD_HHMMSS_create_table_name.php` or `_alter_table_name.php`
2. **Indexes**: Explicit, composite indexes for frequent query patterns
3. **Foreign keys**: Always name constraints explicitly
4. **Soft deletes**: Use on user-facing tables that may need recovery
5. **Timestamps**: Always `created_at`, `updated_at`
6. **Reversible**: `down()` must fully rollback `up()`
7. **No raw SQL in migrations** unless absolutely necessary — use Schema builder

## Go Migration Format (using golang-migrate)

```bash
# Up migration
migrate -path ./migrations -database $DATABASE_URL up

# Down migration
migrate -path ./migrations -database $DATABASE_URL down 1
```

```sql
-- 001_create_users.up.sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- 001_create_users.down.sql
DROP TABLE IF EXISTS users;
```

## Rules for Go

1. **File naming**: `XXX_description.direction.sql` (e.g., `001_create_users.up.sql`)
2. **Always paired**: up + down migration together
3. **No DDL in application code** — migrations only
4. **Idempotent**: Can run multiple times safely (IF EXISTS, etc)

## Common Mistakes to Avoid

- Forgetting index on foreign key → slow queries
- Not naming constraints → hard to debug
- Using `text` when `varchar(255)` is sufficient
- Missing `NOT NULL` when column is required
- Not handling lock timeouts on large table alterations
