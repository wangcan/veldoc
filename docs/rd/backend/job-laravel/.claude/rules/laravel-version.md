# Laravel 13 Specific Rules

This project uses **Laravel 13.26.1** with **PHP 8.4**.

## Version-Specific Features

### Anonymous Migrations

Laravel 13 supports anonymous migrations. No class name is required:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->timestamps();
        });
    }
};
```

### Attribute Casting

Use the `casts()` method instead of the `$casts` property (Laravel 11+ feature):

```php
protected function casts(): array
{
    return [
        'email_verified_at' => 'datetime',
        'options' => 'array',
    ];
}
```

### Route Files

Routes are defined in `routes/web.php` and `routes/api.php`. API routes are prefixed with `/api` automatically.

### Configuration

Use `php artisan config:show key.name` to inspect configuration values without reading files.

## API Changes from Laravel 10/11

- `Route::controller()` is deprecated, use invokable controllers or explicit routes
- `__construct()` property promotion is standard
- Use `#[Test]` attribute instead of `@test` annotation in PHPUnit tests

## Always Verify

Use `search-docs` tool to verify version-specific APIs before using them.
