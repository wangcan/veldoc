# Database Inspect

Inspect the database schema and run queries.

## Usage

```
/db-inspect [table]
```

## Examples

```bash
# Show all tables
/db-inspect

# Show specific table details
/db-inspect users

# Run a query
/db-inspect --query "SELECT * FROM users LIMIT 10"
```

## Implementation

When invoked, I will:

1. Use the `database-schema` MCP tool to inspect tables
2. Show table structure with columns, types, and indexes
3. For specific tables, show foreign keys and relationships
4. Optionally run custom queries with `--query`

## Output

Shows:
- Table names (summary mode)
- Column names and types
- Nullable and default values
- Primary keys and indexes
- Foreign key constraints

## Use Cases

- Understand existing schema before creating migrations
- Verify migration results
- Debug database issues
- Explore data relationships
