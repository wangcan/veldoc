#!/usr/bin/env bash
# Check for pending migrations after database-related changes

# List of patterns that suggest migration-related changes
MIGRATION_PATTERNS=("database/migrations" "app/Models" "Schema::create" "Schema::table")

# Check if any migration files were created or modified
PENDING_MIGRATIONS=$(php artisan migrate:status 2>/dev/null | grep -c "Pending" || echo "0")

if [ "$PENDING_MIGRATIONS" -gt 0 ]; then
    echo "⚠️  Found $PENDING_MIGRATIONS pending migration(s)"
    echo "Run 'php artisan migrate' to apply them."
fi
