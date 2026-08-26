# API Development Rules

This project is a **pure backend API service**. Follow these rules when developing API endpoints.

## API Resource Pattern

### Creating Resources

Use API Resources for data transformation:

```bash
# Create a resource
php artisan make:resource UserResource

# Create a collection resource
php artisan make:resource UserCollection
```

### Resource Implementation

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
```

## Form Request Validation

Use Form Requests for validation and authorization:

```bash
php artisan make:request StoreUserRequest
```

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::defaults()],
        ];
    }
}
```

## Controller Structure

### API Controller Methods

Follow RESTful conventions:

```php
class UserController extends Controller
{
    // GET /api/users
    public function index(): JsonResponse
    {
        $users = User::paginate();

        return response()->json([
            'data' => UserResource::collection($users),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    // POST /api/users
    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());

        return response()->json([
            'data' => new UserResource($user),
            'message' => 'User created successfully',
        ], 201);
    }

    // GET /api/users/{id}
    public function show(User $user): JsonResponse
    {
        return response()->json([
            'data' => new UserResource($user),
        ]);
    }

    // PUT/PATCH /api/users/{id}
    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $user->update($request->validated());

        return response()->json([
            'data' => new UserResource($user),
            'message' => 'User updated successfully',
        ]);
    }

    // DELETE /api/users/{id}
    public function destroy(User $user): JsonResponse
    {
        $user->delete();

        return response()->json([
            'message' => 'User deleted successfully',
        ], 204);
    }
}
```

## Route Registration

### API Routes

Define routes in `routes/api.php`:

```php
use App\Http\Controllers\Api\V1\UserController;

Route::prefix('v1')->group(function () {
    Route::apiResource('users', UserController::class);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
});
```

## Error Handling

### Exception Handler

Customize API error responses in `app/Exceptions/Handler.php`:

```php
public function render($request, Throwable $e)
{
    if ($request->expectsJson()) {
        if ($e instanceof ModelNotFoundException) {
            return response()->json([
                'message' => 'Resource not found',
            ], 404);
        }

        if ($e instanceof ValidationException) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        }
    }

    return parent::render($request, $e);
}
```

## Pagination

### Standard Pagination Response

```php
$users = User::paginate(15);

return response()->json([
    'data' => UserResource::collection($users),
    'meta' => [
        'current_page' => $users->currentPage(),
        'from' => $users->firstItem(),
        'last_page' => $users->lastPage(),
        'per_page' => $users->perPage(),
        'to' => $users->lastItem(),
        'total' => $users->total(),
    ],
    'links' => [
        'first' => $users->url(1),
        'last' => $users->url($users->lastPage()),
        'prev' => $users->previousPageUrl(),
        'next' => $users->nextPageUrl(),
    ],
]);
```

## API Authentication

### Laravel Sanctum

Use Sanctum for API token authentication:

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### Token Generation

```php
// Issue token
$token = $user->createToken('api-token')->plainTextToken;

// Revoke token
$user->currentAccessToken()->delete();

// Revoke all tokens
$user->tokens()->delete();
```

## Rate Limiting

Configure rate limiting in `App\Http\Kernel.php` or route middleware:

```php
// In routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    // API routes
});
```

## Testing API Endpoints

### Feature Tests

```php
class UserApiTest extends TestCase
{
    #[Test]
    public function it_can_list_users(): void
    {
        User::factory()->count(3)->create();

        $response = $this->getJson('/api/v1/users');

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name', 'email'],
                ],
                'meta' => ['current_page', 'total'],
            ]);
    }

    #[Test]
    public function it_can_create_user(): void
    {
        $data = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ];

        $response = $this->postJson('/api/v1/users', $data);

        $response->assertCreated()
            ->assertJson(['message' => 'User created successfully']);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
        ]);
    }
}
```
