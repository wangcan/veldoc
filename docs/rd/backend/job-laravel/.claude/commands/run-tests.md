# Run Tests

Run the test suite with various options.

## Usage

```
/run-tests [filter] [options]
```

## Options

- `--compact` or `-c` - Compact output
- `--parallel` or `-p` - Run tests in parallel
- `--filter=name` - Filter tests by name
- `--stop-on-failure` - Stop on first failure

## Examples

```bash
# Run all tests
/run-tests

# Run with compact output
/run-tests --compact

# Run specific test file
/run-tests tests/Feature/UserTest.php

# Run tests matching a name
/run-tests --filter=test_user_can_login

# Run in parallel
/run-tests --parallel
```

## Implementation

When invoked, I will:

1. Run `php artisan test` with the specified options
2. Show the test results
3. If tests fail, analyze the failures and suggest fixes
4. Offer to run the full test suite if running a subset

## Test Output

The command will show:
- Number of tests run
- Pass/fail status
- Error details for failures
- Time taken
- Memory usage

## Common Scenarios

### Before Committing

Run the full test suite to ensure nothing is broken:

```bash
/run-tests --compact
```

### During Development

Run specific tests related to your changes:

```bash
/run-tests --filter=AuthenticationTest
```

### After Fixing a Bug

Run the specific test case to verify the fix:

```bash
/run-tests --filter=test_user_can_login
```
