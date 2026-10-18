# MySQL Database Rules

This project uses **MySQL** as the primary database engine, with support for multiple database connections across different modules.

## Database Connections

### Multiple Database Configuration

Different modules may use different databases. Configure connections in `config/database.php`:

```php
'connections' => [
    'mysql' => [
        'driver' => 'mysql',
        'host' => env('DB_HOST', '127.0.0.1'),
        'port' => env('DB_PORT', '3306'),
        'database' => env('DB_DATABASE', 'forge'),
        'username' => env('DB_USERNAME', 'forge'),
        'password' => env('DB_PASSWORD', ''),
        // ... other options
    ],

    'mysql_logs' => [
        'driver' => 'mysql',
        'host' => env('DB_LOGS_HOST', '127.0.0.1'),
        'database' => env('DB_LOGS_DATABASE', 'logs'),
        // ... other options
    ],
],
```

### Using Multiple Connections

```php
// Specify connection on query
DB::connection('mysql_logs')->table('audit_logs')->get();

// Specify connection on model
class AuditLog extends Model
{
    protected $connection = 'mysql_logs';
}
```

## MySQL Specific Features

### Transaction Support

MySQL fully supports transactions with row-level locking:

```php
DB::transaction(function () {
    // Operations within transaction
    User::create([...]);
    Profile::create([...]);
});

// Or manual transaction control
DB::beginTransaction();
try {
    // Operations
    DB::commit();
} catch (\Exception $e) {
    DB::rollBack();
    throw $e;
}
```

### Foreign Key Constraints

MySQL enforces foreign key constraints by default:

```php
Schema::create('posts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')
        ->constrained('users')
        ->cascadeOnDelete()
        ->cascadeOnUpdate();
});
```

### JSON Column Support

MySQL 5.7+ supports native JSON columns:

```php
$table->json('metadata')->nullable();

// In model
protected function casts(): array
{
    return [
        'metadata' => 'array',
    ];
}
```

### Index Optimization

Create indexes for frequently queried columns:

```php
$table->index(['user_id', 'created_at']); // Composite index
$table->unique('email'); // Unique index
$table->fullText('content'); // Full-text index for MySQL 5.6+
```

## Testing

Tests use an in-memory SQLite database by default for speed. For MySQL-specific tests:

```php
// In phpunit.xml or test class
'connection' => 'mysql_testing',
```

## Schema Inspection

Use the `database-schema` MCP tool to inspect tables:

```bash
# Via MCP
database-schema --summary
database-schema --filter=users --include_column_details

# Or via Artisan
php artisan db:table users
```

## Common Commands

```bash
# Run migrations
php artisan migrate

# Fresh migration (reset everything) - USE WITH CAUTION
php artisan migrate:fresh --seed

# Check migration status
php artisan migrate:status

# Rollback last batch
php artisan migrate:rollback
```
