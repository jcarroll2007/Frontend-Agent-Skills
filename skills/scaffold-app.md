# Skill: scaffold-app

Scaffold a new frontend application using the canonical stack: React + TypeScript (strict) + Vite + TanStack Router + TanStack Query + Tailwind + shadcn/ui + Vitest.

## Trigger

User runs `/scaffold-app` or asks to scaffold / create a new frontend app.

## Step 1 — Get the Project Name

If the user didn't provide a project name, ask for one before proceeding. All other steps are automatic.

## Step 2 — Run the Scaffold Script

Run the boilerplate script from this skills directory. It creates the Vite project, strict TypeScript config, folder structure, and config file stubs. It does not install stack-specific packages.

```bash
bash <path-to-skills>/scripts/scaffold-app.sh <project-name>
cd <project-name>
```

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

Install with the resolved versions. Use pnpm.

**Dependencies:**
- `@tanstack/react-router`
- `@tanstack/react-query`
- `@tanstack/react-query-devtools`
- `zod`
- `lucide-react`
- `clsx`
- `tailwind-merge`

**Dev dependencies:**
- `@tanstack/router-plugin` (Vite plugin for file-based routing)
- `tailwindcss`
- `@tailwindcss/vite`
- `vitest`
- `@vitest/ui`
- `@testing-library/react`
- `@testing-library/user-event`
- `jsdom`

## Step 5 — Initialize shadcn/ui

Fetch the current shadcn init command from https://ui.shadcn.com/docs/installation/vite and run it. Use the `default` style, CSS variables on, no Tailwind prefix. Accept all defaults.

Install a baseline set of components:
```bash
pnpm dlx shadcn@latest add button card input label badge separator
```

## Step 6 — Configure the Stack

Apply these configurations to the scaffolded project:

### vite.config.ts
Add `@tanstack/router-plugin/vite` to the plugins array before the React plugin.

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'
import path from 'path'

export default defineConfig({
  plugins: [TanStackRouterVite(), react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
})
```

### src/routes/__root.tsx
Create the root route with a QueryClientProvider wrapping the outlet:

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
Create a minimal index route so the app renders:

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
Wire up TanStack Router with the generated routeTree:

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
Create an empty query keys registry:

```ts
// Central registry for all TanStack Query keys.
// Pattern: export const ENTITY_KEYS = { all: ['entity'] as const, ... }
```

### src/lib/api.ts
Create a typed fetch wrapper:

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
Create alongside vite.config.ts:

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

Create `src/test/setup.ts`:

```ts
import '@testing-library/jest-dom'
```

Install `@testing-library/jest-dom` as a dev dependency.

## Step 7 — Verify

```bash
pnpm run build
```

Build must pass before the skill is complete. If it fails, fix the errors — do not report success until the build is clean.

## Step 8 — Report

Tell the user:
- Project location
- How to start the dev server (`pnpm dev`)
- How to run tests (`pnpm test`)
- The folder structure created
