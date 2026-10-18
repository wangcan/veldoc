#!/usr/bin/env bash
# Format PHP files with Pint after editing
# This hook runs after Edit or Write tools modify PHP files

# Get the list of modified PHP files
PHP_FILES=$(git diff --name-only --cached --diff-filter=ACM "*.php" 2>/dev/null | head -20)

if [ -n "$PHP_FILES" ]; then
    echo "🎨 Formatting PHP files with Pint..."
    vendor/bin/pint --dirty --format agent 2>/dev/null || true
fi
