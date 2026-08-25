# PHP Code Style Rules

This project uses **Laravel Pint** for code formatting.

## Pint Configuration

Run Pint to format PHP code:

```bash
# Format all changed files
vendor/bin/pint --dirty --format agent

# Format specific file
vendor/bin/pint app/Models/User.php

# Test without changes (CI mode)
vendor/bin/pint --test
```

## Code Style Conventions

### PHP 8 Features

Use modern PHP 8.4 features:

```php
// Constructor property promotion
public function __construct(
    public string $name,
    protected User $user,
) {}

// Named arguments
User::create([
    'name' => 'John',
    'email' => 'john@example.com',
]);

// Match expressions
$status = match($code) {
    200, 300 => 'success',
    400, 500 => 'error',
    default => 'unknown',
};

// Null-safe operator
$user?->profile?->avatar;

// Null coalescing assignment
$name ??= 'default';
```

### Type Declarations

Always declare types:

```php
public function getUser(int $id): ?User
{
    return User::find($id);
}

public function process(array $data): void
{
    // ...
}
```

### Array Shapes in PHPDoc

```php
/**
 * @param array{id: int, name: string} $data
 * @return array{success: bool, message: string}
 */
public function process(array $data): array
{
    return [
        'success' => true,
        'message' => 'Processed',
    ];
}
```

### Control Structures

Always use curly braces, even for single lines:

```php
// Correct
if ($condition) {
    return true;
}

// Incorrect
if ($condition) return true;
```

### Enums

Use TitleCase for Enum keys:

```php
enum Status: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case PendingApproval = 'pending_approval';
}
```

## Before Committing

Always run Pint after modifying PHP files:

```bash
vendor/bin/pint --dirty --format agent
```

This is automatically handled by a post-tool hook when using the Edit or Write tools.
