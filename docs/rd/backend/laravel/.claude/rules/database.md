# SQLite Database Rules

This project uses **SQLite** as the database engine.

## SQLite Considerations

### Database Location

The SQLite database is located at `database/database.sqlite`. It must exist before migrations run:

```bash
touch database/database.sqlite
```

### SQLite Limitations

1. **No Foreign Key Enforcement by Default**: SQLite doesn't enforce foreign keys unless enabled. Laravel enables this by default.

2. **ALTER TABLE Limitations**: SQLite has limited ALTER TABLE support. For complex schema changes:
   - Use the `doctrine/dbal` package (not installed by default)
   - Create new tables and migrate data
   - Use SQLite-specific workarounds

3. **No JSON Column Type**: Use `text` columns for JSON data and cast to array in models.

4. **Concurrent Writes**: SQLite handles concurrent reads well but locks on writes. Suitable for development and low-traffic production.

### Testing with SQLite

Tests use an in-memory SQLite database (`:memory:`). This is fast but data doesn't persist between tests.

### Migration Considerations

For SQLite compatibility:
- Avoid `DROP COLUMN` in migrations (create new table instead)
- Use `$table->renameColumn()` with caution
- Test migrations on SQLite before production

## Commands

```bash
# Create database file if missing
php artisan db --create

# Run migrations
php artisan migrate

# Fresh migration (reset everything)
php artisan migrate:fresh
```

## Schema Inspection

Use the `database-schema` MCP tool to inspect tables:

```bash
# Via MCP
database-schema --summary
database-schema --filter=users --include_column_details
```
