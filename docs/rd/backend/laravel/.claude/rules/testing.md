# PHPUnit Testing Rules

This project uses **PHPUnit 12.5** for testing (not Pest).

## Test Conventions

### Create Tests

```bash
# Feature test
php artisan make:test ExampleTest

# Unit test
php artisan make:test ExampleTest --unit
```

### Test Structure

All tests should:
- Extend `Tests\TestCase`
- Use `#[Test]` attribute for test methods
- Follow Arrange-Act-Assert pattern
- Use descriptive method names

### Example Test

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use PHPUnit\Framework\Attributes\Test;

class AuthenticationTest extends TestCase
{
    #[Test]
    public function user_can_login_with_valid_credentials(): void
    {
        // Arrange
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        // Act
        $response = $this->postJson('/api/login', [
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        // Assert
        $response->assertOk()
            ->assertJsonStructure(['token']);
    }
}
```

## Running Tests

```bash
# All tests
php artisan test

# Specific file
php artisan test tests/Feature/ExampleTest.php

# Filter by name
php artisan test --filter=test_name

# Compact output
php artisan test --compact

# Parallel execution (faster)
php artisan test --parallel
```

## Test Data

- Use model factories: `User::factory()->create()`
- Use faker: `$this->faker->word()` or `fake()->randomDigit()`
- Create states in factories for common scenarios

## Assertions

Common assertions:
- `$response->assertOk()` - 200 status
- `$response->assertCreated()` - 201 status
- `$response->assertNotFound()` - 404 status
- `$response->assertJson(['key' => 'value'])` - JSON content
- `$this->assertDatabaseHas('users', ['email' => 'test@example.com'])`

## Fake Services

Use Laravel's fakes for isolated testing:

```php
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Queue;

Mail::fake();
Queue::fake();

// Test mail was sent
Mail::assertSent(OrderShipped::class);
```
