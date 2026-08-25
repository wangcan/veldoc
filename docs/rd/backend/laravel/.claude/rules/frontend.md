# Frontend Stack Rules

This project uses **Vite 8** with **Tailwind CSS 4**.

## Technology Stack

- **Build Tool**: Vite 8.0.0
- **CSS Framework**: Tailwind CSS 4.0.0
- **Plugin**: @tailwindcss/vite
- **Laravel Integration**: laravel-vite-plugin 3.1

## Build Commands

```bash
# Development (hot reload)
npm run dev

# Production build
npm run build
```

## Entry Points

- CSS: `resources/css/app.css`
- JS: `resources/js/app.js`

## Using Assets in Blade

```blade
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>App</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <!-- Content -->
</body>
</html>
```

## Tailwind CSS 4

Tailwind 4 has a new configuration approach. Configuration is done in CSS:

```css
/* resources/css/app.css */
@import "tailwindcss";

@theme {
  --color-brand: #your-color;
}
```

### Key Changes from Tailwind 3

- No more `tailwind.config.js` (optional)
- Configuration via CSS `@theme` directive
- Improved performance
- Simplified setup

## Development Workflow

### Start Development

```bash
# Option 1: Laravel dev server (includes Vite)
composer run dev

# Option 2: Separate terminals
php artisan serve
npm run dev
```

### Production Deployment

```bash
npm run build
```

This creates optimized assets in `public/build/`.

## Troubleshooting

### Vite Manifest Error

If you see `Illuminate\Foundation\ViteException: Unable to locate file in Vite manifest`:

```bash
npm run build
# Or run dev server
npm run dev
```

### Changes Not Reflected

If frontend changes don't appear:
1. Ensure Vite dev server is running (`npm run dev`)
2. Clear browser cache
3. Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
