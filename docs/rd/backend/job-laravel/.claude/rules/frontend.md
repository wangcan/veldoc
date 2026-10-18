# Pure API Backend Rules

This project is a **pure backend API service** with no server-side template rendering.

## Architecture

### API-Only Design

- No Blade views are rendered
- All responses are JSON
- Frontend is a separate application consuming this API
- Uses Laravel API Resources for response transformation

### API Resources

Use Eloquent API Resources to transform models into JSON responses:

```php
// Create a resource
php artisan make:resource UserResource

// In controller
public function index(): JsonResponse
{
    $users = User::with('profile')->paginate();

    return response()->json([
        'data' => UserResource::collection($users),
        'meta' => [
            'current_page' => $users->currentPage(),
            'total' => $users->total(),
        ],
    ]);
}
```

### Response Format

Standardize API responses:

```php
// Success response
return response()->json([
    'success' => true,
    'data' => $data,
    'message' => 'Operation successful',
], 200);

// Error response
return response()->json([
    'success' => false,
    'message' => 'Error description',
    'errors' => $errors,
], 400);
```

### API Versioning

Support API versioning for backward compatibility:

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::get('/users', [UserController::class, 'index']);
});

Route::prefix('v2')->group(function () {
    Route::get('/users', [UserV2Controller::class, 'index']);
});
```

## Authentication

### API Token Authentication

Use Laravel Sanctum or Passport for API authentication:

```php
// Sanctum token authentication
$user = User::where('email', $request->email)->first();

if ($user && Hash::check($request->password, $user->password)) {
    $token = $user->createToken('api-token')->plainTextToken;

    return response()->json([
        'token' => $token,
        'user' => new UserResource($user),
    ]);
}
```

## CORS Configuration

Configure CORS for frontend application in `config/cors.php`:

```php
'paths' => ['api/*'],
'allowed_methods' => ['*'],
'allowed_origins' => ['https://frontend.example.com'],
'allowed_headers' => ['*'],
```

## No Frontend Assets

Since this is a pure API:

- No Vite build process needed for this project
- No Blade templates or views
- Focus on API endpoints and data transformation
- Frontend is a separate repository/application

## Testing API Endpoints

```php
use Tests\TestCase;
use App\Models\User;

class ApiTest extends TestCase
{
    #[Test]
    public function it_returns_users_list(): void
    {
        $user = User::factory()->create();

        $response = $this->getJson('/api/v1/users');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name', 'email'],
                ],
            ]);
    }
}
```

## Documentation

Consider using tools like:
- **Swagger/OpenAPI** for API documentation
- **Scribe** for automatic API documentation generation
- **Postman** collections for testing
