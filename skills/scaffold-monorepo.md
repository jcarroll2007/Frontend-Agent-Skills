# Skill: scaffold-monorepo

Scaffold a frontend monorepo using Turborepo + pnpm workspaces, then add an initial app using the scaffold-app skill.

Workspace layout produced:
- `apps/<name>` — frontend app added by scaffold-app (TanStack Router + Query, Tailwind, shadcn/ui, Vitest)
- `packages/typescript-config` — shared tsconfig bases consumed by all workspaces
- `packages/ui` — shared component library; shadcn/ui components live here

## Trigger

User runs `/scaffold-monorepo` or asks to scaffold / create a new frontend monorepo.

## Step 1 — Get Names

If the user didn't provide them, ask for:
1. **Monorepo name** — used as the root package name and npm scope (`@<name>/`)
2. **Initial app name** — the first app to create inside `apps/`

All other steps are automatic.

## Step 2 — Run the Monorepo Scaffold Script

```bash
bash <path-to-skills>/scripts/scaffold-monorepo.sh <monorepo-name>
cd <monorepo-name>
```

This creates the root structure (`turbo.json`, `pnpm-workspace.yaml`, root `package.json`, `.gitignore`) and the two shared packages (`packages/typescript-config`, `packages/ui`). It does not create any apps or install any packages.

## Step 3 — Fetch Current Package Versions

Do not hardcode versions. Resolve at runtime:

```bash
npm show turbo version
npm show tsup version
```

Also resolve the current pnpm version for the `packageManager` field:

```bash
pnpm --version
```

## Step 4 — Set packageManager Field

Update root `package.json`:

```json
"packageManager": "pnpm@<resolved-version>"
```

## Step 5 — Fetch Additional Versions

```bash
npm show eslint version
npm show typescript-eslint version
npm show @eslint/js version
npm show eslint-plugin-react version
npm show eslint-plugin-react-hooks version
npm show eslint-config-prettier version
npm show prettier version
npm show tsup version
```

## Step 6 — Install Root Dev Dependencies

```bash
pnpm add -D -w turbo@<resolved-version> prettier@<resolved-version>
```

## Step 7 — Install packages/eslint-config Dependencies

```bash
cd packages/eslint-config
pnpm add eslint@<resolved-version> @eslint/js@<resolved-version> typescript-eslint@<resolved-version> eslint-plugin-react@<resolved-version> eslint-plugin-react-hooks@<resolved-version> eslint-config-prettier@<resolved-version>
cd ../..
```

## Step 8 — Install packages/ui Dev Dependencies

```bash
cd packages/ui
pnpm add -D tsup@<resolved-version> typescript eslint@<resolved-version> react react-dom @types/react @types/react-dom
pnpm add tailwind-merge clsx
cd ../..
```

## Step 9 — Add the Initial App

Run the scaffold-app skill from the monorepo root, passing the initial app name. The script detects the monorepo context automatically.

The scaffold-app skill will:
- Create `apps/<app-name>` with tsconfig extending `@<scope>/typescript-config`
- Add `@<scope>/ui` and `@<scope>/eslint-config` as workspace dependencies
- Install TanStack Router + Query, Tailwind, Vitest, and ESLint
- Write `eslint.config.js` extending `@<scope>/eslint-config/react`
- Initialize shadcn/ui with components landing in `packages/ui/src/components`
- Verify with `turbo build` and `turbo lint`

## Step 10 — shadcn/ui Component Installation

When scaffold-app runs its shadcn init step inside a monorepo, direct components to `packages/ui/src/components` (not the app's own src). After init, install the baseline set:

```bash
cd apps/<app-name>
pnpm dlx shadcn@latest add button card input label badge separator
cd ../..
```

Then update `packages/ui/src/index.ts` to re-export the installed components:

```ts
export { Button } from './components/button'
export { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from './components/card'
export { Input } from './components/input'
export { Label } from './components/label'
export { Badge } from './components/badge'
export { Separator } from './components/separator'
```

## Step 11 — Verify

From the monorepo root:

```bash
turbo build
turbo lint
```

Both must pass for all workspaces. Fix any errors before reporting success.

## Step 12 — Report

Tell the user:
- Repo location and workspace layout
- `pnpm --filter <app-name> dev` to start the dev server
- `turbo test` to run all tests
- `turbo build` to build all workspaces
- `turbo lint` to lint all workspaces
- `pnpm format` to format everything with Prettier
- To add more apps: run `/scaffold-app <name>` from the monorepo root
- shadcn components go in `packages/ui/src/components` and must be re-exported from `packages/ui/src/index.ts`
