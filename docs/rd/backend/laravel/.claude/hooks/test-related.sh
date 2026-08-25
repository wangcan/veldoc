#!/usr/bin/env bash
# Run related tests after file changes
# This hook can be triggered manually or configured for specific file types

# Check if we should run tests
SHOULD_RUN=${RUN_TESTS:-false}
TEST_FILTER=${TEST_FILTER:-""}

if [ "$SHOULD_RUN" = "true" ]; then
    if [ -n "$TEST_FILTER" ]; then
        echo "🧪 Running tests with filter: $TEST_FILTER"
        php artisan test --compact --filter="$TEST_FILTER" 2>/dev/null || true
    else
        echo "🧪 Running all tests..."
        php artisan test --compact 2>/dev/null || true
    fi
fi
