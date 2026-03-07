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

## Step 5 — Install Root Dev Dependencies

```bash
pnpm add -D -w turbo@<resolved-version>
```

## Step 6 — Install packages/ui Dev Dependencies

```bash
cd packages/ui
pnpm add -D tsup@<resolved-version> typescript react react-dom @types/react @types/react-dom
pnpm add tailwind-merge clsx
cd ../..
```

## Step 7 — Add the Initial App

Run the scaffold-app skill from the monorepo root, passing the initial app name. The script detects the monorepo context automatically.

The scaffold-app skill will:
- Create `apps/<app-name>` with tsconfig extending `@<scope>/typescript-config`
- Add `@<scope>/ui` as a workspace dependency
- Install TanStack Router + Query, Tailwind, Vitest
- Initialize shadcn/ui with components landing in `packages/ui/src/components`
- Verify with `turbo build`

## Step 8 — shadcn/ui Component Installation

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

## Step 9 — Verify

From the monorepo root:

```bash
turbo build
```

Build must pass for all workspaces. Fix any errors before reporting success.

## Step 10 — Report

Tell the user:
- Repo location and workspace layout
- `pnpm --filter <app-name> dev` to start the dev server
- `turbo test` to run all tests
- `turbo build` to build all workspaces
- To add more apps: run `/scaffold-app <name>` from the monorepo root
- shadcn components go in `packages/ui/src/components` and must be re-exported from `packages/ui/src/index.ts`
