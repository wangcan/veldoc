# Claude Code Hooks

This directory contains automation hooks for Claude Code.

## Available Hooks

### pint-format.sh
Automatically formats PHP files using Laravel Pint after editing.

**Trigger**: After Edit or Write tools modify PHP files

**Usage**: Configured in `settings.json` under `hooks.PostToolUse`

### test-related.sh
Runs tests after file changes (opt-in via environment variable).

**Usage**:
```bash
RUN_TESTS=true TEST_FILTER=UserTest /path/to/test-related.sh
```

### migration-check.sh
Checks for pending migrations after database-related changes.

**Usage**: Run manually or configure as a notification hook

## Hook Types

Claude Code supports several hook types:

- **PreToolUse**: Run before a tool executes
- **PostToolUse**: Run after a tool completes
- **Notification**: Run on specific events
- **Stop**: Run when the session ends

## Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "toolName": "Edit|Write"
        },
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Creating New Hooks

1. Create a bash script in this directory
2. Make it executable: `chmod +x hook-name.sh`
3. Add configuration to `settings.json`
4. Test the hook with sample operations

## Best Practices

- Keep hooks fast (avoid long-running operations)
- Handle errors gracefully
- Use `2>/dev/null` to suppress expected errors
- Log useful information for debugging
- Don't modify files in hooks (use tools instead)
