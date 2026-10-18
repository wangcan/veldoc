# Make Model

Create a new Eloquent model with optional migration, factory, seeder, and controller.

## Usage

```
/make-model ModelName [options]
```

## Options

- `--migration` or `-m` - Create a migration file
- `--factory` or `-f` - Create a factory file
- `--seeder` or `-s` - Create a seeder file
- `--controller` or `-c` - Create a controller
- `--api` - Create an API controller
- `--all` or `-a` - Create migration, factory, seeder, and controller

## Examples

```bash
# Create model only
/make-model Post

# Create model with migration
/make-model Post -m

# Create model with all files
/make-model Post --all

# Create model with API controller
/make-model Post --api
```

## Implementation

When invoked, I will:

1. Run `php artisan make:model` with the specified options
2. Show the created files
3. Suggest next steps (define relationships, add scopes, etc.)

## Command Translation

| Option | Artisan Equivalent |
|--------|-------------------|
| `-m` | `--migration` |
| `-f` | `--factory` |
| `-s` | `--seed` |
| `-c` | `--controller` |
| `-a` | `--all` |
| `--api` | `--controller --api` |
