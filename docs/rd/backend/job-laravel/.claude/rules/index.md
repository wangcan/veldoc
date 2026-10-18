# Project Rules Index

This directory contains project-specific rules that guide AI assistants when working on this codebase.

## Rule Files

- [`laravel-version.md`](laravel-version.md) - Laravel 13 specific patterns and APIs
- [`database.md`](database.md) - MySQL database configuration and multi-database support
- [`api-development.md`](api-development.md) - API development patterns and best practices
- [`testing.md`](testing.md) - PHPUnit testing conventions
- [`frontend.md`](frontend.md) - Pure API backend architecture
- [`code-style.md`](code-style.md) - PHP code style and Pint configuration

## How Rules Work

Rules are loaded automatically when working in this project. They provide context-specific guidance that supplements the general Laravel best practices.

## Adding New Rules

When you discover patterns or decisions specific to this project:

1. Create a new markdown file in this directory
2. Add a link to it in this index
3. Keep rules concise and actionable
