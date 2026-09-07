---
name: add-shadcn-component
description: Add a new shadcn/ui component to the frontend (new-york style, neutral base). Use when the UI needs a component not already in frontend/src/components/ui/.
---

# Add a shadcn/ui component

The frontend uses shadcn/ui (`components.json`: style `new-york`, baseColor `neutral`, `cssVariables: true`, `rsc: false`, icon lib `lucide`). Existing primitives live in `frontend/src/components/ui/` (button, card, badge, input, textarea, scroll-area, select, tabs).

## Steps
1. From `frontend/`:
   ```bash
   npx shadcn@latest add <component>
   ```
   (Already allowlisted in `.claude/settings.json`.) This drops the file into `frontend/src/components/ui/<component>.tsx` and installs any missing Radix dependency via npm.
2. If the CLI asks to confirm the style/baseColor, accept the values already in `components.json`.
3. Import using the `@` alias:
   ```tsx
   import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog";
   ```
4. Compose with the `cn()` helper from `@/lib/utils` when customizing variants.

## Conventions to preserve
- Tailwind 4 is configured via `@tailwindcss/vite` (CSS-first, no `tailwind.config.js`). Theme tokens live as CSS variables in `frontend/src/global.css` — do not add a JS config.
- Keep components client-safe (no React Server Components; `rsc: false`).
- Use `lucide-react` for icons (already a dependency).

## Verify
- `cd frontend && npm run lint` passes.
- `cd frontend && npm run build` (`tsc -b && vite build`) has no type errors.
- The new component renders in `http://localhost:5173/app` after `npm run dev`.
