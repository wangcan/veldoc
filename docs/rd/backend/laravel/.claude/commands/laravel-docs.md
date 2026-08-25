# Laravel Docs

Search Laravel documentation for the installed version.

## Usage

```
/laravel-docs query [query...]
```

## Examples

```bash
# Search for validation
/laravel-docs validation

# Search multiple terms
/laravel-docs "rate limiting" middleware

# Search specific package
/laravel-docs --package=laravel/framework routing
```

## Implementation

When invoked, I will:

1. Use the `search-docs` MCP tool
2. Search the Laravel documentation for the installed version (13.26.1)
3. Return relevant documentation snippets
4. Show API examples and usage patterns

## Why Use This

- Get version-specific documentation
- Ensure API compatibility
- Find best practices
- Discover new features

## Notes

- Documentation is version-specific to Laravel 13
- Results include code examples
- Links to full documentation sections are provided
