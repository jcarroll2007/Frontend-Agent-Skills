# Skill: scaffold-app

Scaffold a frontend application using the canonical stack: React + TypeScript (strict) + Vite + TanStack Router + TanStack Query + Tailwind + shadcn/ui + Vitest.

Works in two modes depending on context:

**Standalone** — run from any directory without a `turbo.json`. Creates a self-contained project at `./<name>`.

**Monorepo** — run from a Turborepo root (`turbo.json` + `pnpm-workspace.yaml` present). Creates `apps/<name>` with tsconfig extending `packages/typescript-config` and `packages/ui` as a workspace dependency.

## Trigger

User runs `/scaffold-app` or asks to scaffold / create a new frontend app. Also called by the scaffold-monorepo skill to add an initial app.

## Step 1 — Get the Project Name

If the user didn't provide a project name, ask for one before proceeding. All other steps are automatic.

## Step 2 — Run the Scaffold Script

Run the script from the appropriate location:

- **Standalone:** run from the parent directory where the project should be created
- **Monorepo:** run from the monorepo root

```bash
bash <path-to-skills>/scripts/scaffold-app.sh <project-name>
```

The script detects monorepo context automatically. In standalone mode it creates `./<name>` and `cd`s into it. In monorepo mode it creates `apps/<name>`.

After the script, `cd` to the app directory:
- Standalone: `cd <project-name>`
- Monorepo: `cd apps/<project-name>`

## Step 3 — Fetch Current Package Versions

Do not hardcode versions. Resolve the latest stable version of each package at runtime:

```bash
npm show @tanstack/react-router version
npm show @tanstack/router-plugin version
npm show @tanstack/react-query version
npm show @tanstack/react-query-devtools version
npm show tailwindcss version
npm show zod version
npm show lucide-react version
```

## Step 4 — Install Stack Packages

**Dependencies:**
```bash
pnpm add \
  @tanstack/react-router@<resolved-version> \
  @tanstack/react-query@<resolved-version> \
  @tanstack/react-query-devtools@<resolved-version> \
  zod@<resolved-version> \
  lucide-react@<resolved-version> \
  clsx \
  tailwind-merge
```

**Dev dependencies:**
```bash
pnpm add -D \
  @tanstack/router-plugin@<resolved-version> \
  tailwindcss@<resolved-version> \
  @tailwindcss/vite \
  vitest \
  @vitest/ui \
  @testing-library/react \
  @testing-library/user-event \
  @testing-library/jest-dom \
  jsdom
```

## Step 5 — Initialize shadcn/ui

Fetch the current shadcn init command from https://ui.shadcn.com/docs/installation/vite and run it. Use the `default` style, CSS variables on, no Tailwind prefix.

**Standalone:** accept the default components path (`src/components/ui`).

**Monorepo:** set the components path to `../../packages/ui/src/components` so shadcn components land in the shared package, not the app.

Install a baseline set of components:

```bash
pnpm dlx shadcn@latest add button card input label badge separator
```

**Monorepo only:** after installing, update `packages/ui/src/index.ts` to re-export every installed component. The consuming app imports from `@<scope>/ui`, not directly from shadcn.

## Step 6 — Configure the Stack

### vite.config.ts

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [TanStackRouterVite(), react(), tailwindcss()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
})
```

### src/routes/__root.tsx

```tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

const queryClient = new QueryClient()

export const Route = createRootRoute({
  component: () => (
    <QueryClientProvider client={queryClient}>
      <Outlet />
      <ReactQueryDevtools />
    </QueryClientProvider>
  ),
})
```

### src/routes/index.tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  return <div className="p-8"><h1 className="text-2xl font-semibold">Ready.</h1></div>
}
```

### src/main.tsx

```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'
import './index.css'

const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register { router: typeof router }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>
)
```

### src/lib/queryKeys.ts

```ts
// Central registry for all TanStack Query keys.
// Pattern: export const ENTITY_KEYS = { all: ['entity'] as const, ... }
```

### src/lib/api.ts

```ts
const BASE_URL = import.meta.env.VITE_API_URL ?? ''

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json', ...init?.headers },
    ...init,
  })
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
  return res.json() as Promise<T>
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  put: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'PUT', body: JSON.stringify(body) }),
  del: (path: string) => request<void>(path, { method: 'DELETE' }),
}
```

### vitest.config.ts

```ts
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
  },
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
})
```

## Step 7 — Verify

**Standalone:**
```bash
pnpm build
```

**Monorepo** (run from repo root):
```bash
turbo build
```

Build must pass before the skill is complete. Fix any errors — do not report success until the build is clean.

## Step 8 — Report

Tell the user:
- App location
- How to start the dev server (`pnpm dev` standalone, `pnpm --filter <name> dev` in monorepo)
- How to run tests (`pnpm test` standalone, `turbo test` in monorepo)
- The folder structure created
