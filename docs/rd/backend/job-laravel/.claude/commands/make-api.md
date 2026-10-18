# Make API Resource

Create a complete RESTful API resource including model, migration, controller, resource, requests, and tests.

## Usage

```
/make-api ResourceName
```

## What This Creates

1. **Model** - Eloquent model with relationships
2. **Migration** - Database schema migration
3. **Factory** - Model factory for testing
4. **Controller** - API controller with CRUD operations
5. **Resource** - API resource for JSON transformation
6. **Form Request** - Validation for store/update
7. **Routes** - API routes in `routes/api.php`
8. **Tests** - Feature tests for all endpoints

## Example

```bash
/make-api Product
```

This will create:

- `app/Models/Product.php`
- `database/migrations/xxxx_create_products_table.php`
- `database/factories/ProductFactory.php`
- `app/Http/Controllers/Api/V1/ProductController.php`
- `app/Http/Resources/ProductResource.php`
- `app/Http/Requests/Api/V1/StoreProductRequest.php`
- `app/Http/Requests/Api/V1/UpdateProductRequest.php`
- `routes/api.php` (adds routes)
- `tests/Feature/Api/V1/ProductTest.php`

## Implementation

When invoked, I will:

1. Ask about the resource fields and types
2. Create the migration with appropriate columns
3. Create the model with casts and relationships
4. Create the factory with field definitions
5. Create the API controller with CRUD methods
6. Create the API resource
7. Create validation requests
8. Add routes to `api.php`
9. Create comprehensive tests
10. Run Pint to format code

## Customization

After creation, you can customize:
- Add relationships to the model
- Modify validation rules in requests
- Add scopes for filtering
- Customize the resource output
