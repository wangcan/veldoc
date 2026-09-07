# Rule: Frontend (React/Vite/Tailwind/shadcn) style

Scope: all `frontend/src/**/*.{ts,tsx}` and frontend configs.

## Stack
- React 19 + Vite 6 (SWC). TypeScript ~5.7, strict.
- Tailwind CSS 4 via `@tailwindcss/vite` — **CSS-first config**, no `tailwind.config.js`. Theme tokens are CSS variables in `frontend/src/global.css`.
- shadcn/ui `new-york` style, `neutral` baseColor, `cssVariables: true`, `rsc: false`, icons via `lucide-react`.
- Path alias `@` -> `frontend/src` (in `vite.config.ts` + `tsconfig.json`).

## Conventions
- Import UI primitives as `@/components/ui/<name>`, feature components from `@/components/<name>`, helpers from `@/lib/utils` (`cn()`).
- Vite `base: "/app/"` — the app is mounted at `/app/`; keep asset/link paths relative to that.
- Prefer function components + hooks. No React Server Components.
- `npm run dev` skips type-checking; always run `npm run build` (`tsc -b && vite build`) before claiming frontend work is done.
- ESLint 9 flat config in `eslint.config.js` — `npm run lint` must be clean.

## Adding UI
- New shadcn primitive: `npx shadcn@latest add <component>` (allowlisted). Do not hand-write a primitive that shadcn can generate.
- Compose variants with `class-variance-authority` + `cn()`, matching the existing `button.tsx` pattern.
