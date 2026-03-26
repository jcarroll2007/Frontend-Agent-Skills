---
name: frontend-agent-skills
description: Frontend scaffolding and patterns for React + TypeScript apps. Use when the user asks to scaffold a new app, monorepo, container, or feature; or when writing frontend code that should follow established patterns for component architecture, data fetching, or state management. Triggers on /scaffold-app, /scaffold-monorepo, /scaffold-container, or any request to create or scaffold a frontend project or component.
---

# Frontend Agent Skills

Canonical stack: React + TypeScript (strict) + Vite + TanStack Router + TanStack Query + Tailwind CSS + shadcn/ui + Vitest.

## Available Commands

| Command | Description |
|---|---|
| `/scaffold-monorepo` | Turborepo + pnpm monorepo with shared packages and initial app |
| `/scaffold-app` | Standalone app or new app inside an existing monorepo |
| `/scaffold-container` | React container following the domain context architecture |

## Patterns

Before writing any frontend code, read the relevant pattern doc:

- **Component architecture:** `patterns/component-architecture.md`
- **Containers:** `patterns/containers.md`
- **Views:** `patterns/views.md`
- **Data fetching:** `patterns/data-fetching.md`
- **State management:** `patterns/state-management.md`
- **Domain context architecture:** `patterns/domain-context-architecture.md`

Stack choices and rationale: `stack/` and `decisions/`.
Naming and file conventions: `conventions/`.

---

## /scaffold-monorepo

Scaffold a frontend monorepo using Turborepo + pnpm workspaces, then add an initial app.

Workspace layout produced:
- `apps/<name>` — frontend app (TanStack Router + Query, Tailwind, shadcn/ui, Vitest)
- `packages/typescript-config` — shared tsconfig bases
- `packages/ui` — shared component library; shadcn/ui components live here
- `packages/eslint-config` — shared ESLint config

### Step 1 — Get Names

If the user didn't provide them, ask for:
1. **Monorepo name** — used as the root package name and npm scope (`@<name>/`)
2. **Initial app name** — the first app to create inside `apps/`

All other steps are automatic.

### Step 2 — Run the Monorepo Scaffold Script

```bash
bash <skill-root>/scripts/scaffold-monorepo.sh <monorepo-name>
cd <monorepo-name>
```

This creates the root structure (`turbo.json`, `pnpm-workspace.yaml`, root `package.json`, `.gitignore`) and the shared packages. It does not create any apps or install any packages.

### Step 3 — Fetch Current Package Versions

Do not hardcode versions. Resolve at runtime:

```bash
npm show turbo version
npm show tsup version
pnpm --version
```

### Step 4 — Set packageManager Field

Update root `package.json`:

```json
"packageManager": "pnpm@<resolved-version>"
```

### Step 5 — Fetch Additional Versions

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

### Step 6 — Install Root Dev Dependencies

```bash
pnpm add -D -w turbo@<resolved-version> prettier@<resolved-version>
```

### Step 7 — Install packages/eslint-config Dependencies

```bash
cd packages/eslint-config
pnpm add eslint@<resolved-version> @eslint/js@<resolved-version> typescript-eslint@<resolved-version> eslint-plugin-react@<resolved-version> eslint-plugin-react-hooks@<resolved-version> eslint-config-prettier@<resolved-version>
cd ../..
```

### Step 8 — Install packages/ui Dev Dependencies

```bash
cd packages/ui
pnpm add -D tsup@<resolved-version> typescript eslint@<resolved-version> react react-dom @types/react @types/react-dom
pnpm add tailwind-merge clsx
cd ../..
```

### Step 9 — Add the Initial App

Run `/scaffold-app` from the monorepo root, passing the initial app name. The script detects the monorepo context automatically. Follow all steps in the `/scaffold-app` section below.

### Step 10 — shadcn/ui Component Installation

When running the shadcn init step inside a monorepo, direct components to `packages/ui/src/components` (not the app's own src). After init, install the baseline set:

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

### Step 11 — Verify

From the monorepo root:

```bash
turbo build
turbo lint
```

Both must pass for all workspaces. Fix any errors before reporting success.

### Step 12 — Report

Tell the user:
- Repo location and workspace layout
- `pnpm --filter <app-name> dev` to start the dev server
- `turbo test` / `turbo build` / `turbo lint` to run tasks across all workspaces
- `pnpm format` to format everything with Prettier
- To add more apps: run `/scaffold-app <name>` from the monorepo root
- shadcn components go in `packages/ui/src/components` and must be re-exported from `packages/ui/src/index.ts`

---

## /scaffold-app

Scaffold a frontend application using the canonical stack. Works in two modes:

**Standalone** — run from any directory without a `turbo.json`. Creates a self-contained project at `./<name>`.

**Monorepo** — run from a Turborepo root (`turbo.json` + `pnpm-workspace.yaml` present). Creates `apps/<name>` with tsconfig extending `packages/typescript-config` and `packages/ui` as a workspace dependency.

### Step 1 — Get the Project Name

If the user didn't provide a project name, ask for one before proceeding. All other steps are automatic.

### Step 2 — Run the Scaffold Script

- **Standalone:** run from the parent directory where the project should be created
- **Monorepo:** run from the monorepo root

```bash
bash <skill-root>/scripts/scaffold-app.sh <project-name>
```

The script detects monorepo context automatically. After it completes, `cd` to the app directory:
- Standalone: `cd <project-name>`
- Monorepo: `cd apps/<project-name>`

### Step 3 — Fetch Current Package Versions

Do not hardcode versions. Resolve at runtime:

```bash
npm show @tanstack/react-router version
npm show @tanstack/router-plugin version
npm show @tanstack/react-query version
npm show @tanstack/react-query-devtools version
npm show tailwindcss version
npm show zod version
npm show lucide-react version
npm show eslint version
npm show typescript-eslint version
npm show @eslint/js version
npm show eslint-plugin-react version
npm show eslint-plugin-react-hooks version
npm show eslint-config-prettier version
npm show prettier version
```

### Step 4 — Install Stack Packages

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

**Dev dependencies (all modes):**
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
  jsdom \
  eslint@<resolved-version>
```

**Standalone only** — ESLint plugins (in monorepo these come from `packages/eslint-config`):
```bash
pnpm add -D \
  @eslint/js@<resolved-version> \
  typescript-eslint@<resolved-version> \
  eslint-plugin-react@<resolved-version> \
  eslint-plugin-react-hooks@<resolved-version> \
  eslint-config-prettier@<resolved-version> \
  prettier@<resolved-version>
```

### Step 5 — Initialize shadcn/ui

Fetch the current shadcn init command from https://ui.shadcn.com/docs/installation/vite and run it. Use the `default` style, CSS variables on, no Tailwind prefix.

**Standalone:** accept the default components path (`src/components/ui`).

**Monorepo:** set the components path to `../../packages/ui/src/components` so shadcn components land in the shared package, not the app.

Install a baseline set of components:

```bash
pnpm dlx shadcn@latest add button card input label badge separator
```

**Monorepo only:** after installing, update `packages/ui/src/index.ts` to re-export every installed component. The consuming app imports from `@<scope>/ui`, not directly from shadcn.

### Step 6 — Configure the Stack

**vite.config.ts**

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

**src/routes/__root.tsx**

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

**src/routes/index.tsx**

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  return <div className="p-8"><h1 className="text-2xl font-semibold">Ready.</h1></div>
}
```

**src/main.tsx**

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

**src/lib/queryKeys.ts**

```ts
// Central registry for all TanStack Query keys.
// Pattern: export const ENTITY_KEYS = { all: ['entity'] as const, ... }
```

**src/lib/api.ts**

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

**vitest.config.ts**

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

### Step 7 — Verify

**Standalone:**
```bash
pnpm build
pnpm lint
```

**Monorepo** (run from repo root):
```bash
turbo build
turbo lint
```

Both must pass before the skill is complete. Fix any errors — do not report success until build and lint are clean.

### Step 8 — Report

Tell the user:
- App location
- How to start the dev server (`pnpm dev` standalone, `pnpm --filter <name> dev` in monorepo)
- How to run tests (`pnpm test` standalone, `turbo test` in monorepo)
- How to lint and format
- The folder structure created

---

## /scaffold-container

Read `patterns/containers.md` before writing any files.

Scaffold a new container following the structure defined in `patterns/containers.md`.

### Step 1 — Gather Context

Ask the following questions if the answers aren't already clear from context. Ask them together in one message, not one at a time.

**1. Name and purpose** — What is the container called, and what does it do?

**2. Lazy loading** — Should this container be lazy-loaded?
Default: **no**. Only lazy-load if the container is behind a route or modal that most users never reach. If unsure, default to no.

**3. Suspense** — Should this container use `Suspense` for its loading state?
Default: **yes**. Only omit if the container has meaningful static content that should render immediately. If unsure, default to yes.

### Step 2 — Determine the Directory

- Single business domain: `src/contexts/<domain>/containers/<ContainerName>/`
- Composes multiple domains: `src/containers/<ContainerName>/`

If unclear, ask.

### Step 3 — Write the Files

Create `index.ts` and `<ContainerName>Content.tsx`. Pick the variant that matches the lazy/Suspense answers from Step 1.

**index.ts — no lazy, with Suspense (default)**

```ts
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import { <ContainerName>Content } from './<ContainerName>Content';
import type { <ContainerName>ContentProps } from './<ContainerName>Content';

export type <ContainerName>Props = <ContainerName>ContentProps;

export function <ContainerName>({ ...props }: <ContainerName>Props) {
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <Suspense fallback={<div>Loading...</div>}>
        <<ContainerName>Content {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

**index.ts — no lazy, no Suspense**

```ts
import { ErrorBoundary } from 'react-error-boundary';
import { <ContainerName>Content } from './<ContainerName>Content';
import type { <ContainerName>ContentProps } from './<ContainerName>Content';

export type <ContainerName>Props = <ContainerName>ContentProps;

export function <ContainerName>({ ...props }: <ContainerName>Props) {
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <<ContainerName>Content {...props} />
    </ErrorBoundary>
  );
}
```

**index.ts — lazy, with Suspense**

```ts
import { lazy, Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import type { <ContainerName>ContentProps } from './<ContainerName>Content';

const <ContainerName>Content = lazy(() =>
  import('./<ContainerName>Content').then((m) => ({ default: m.<ContainerName>Content }))
);

export type <ContainerName>Props = <ContainerName>ContentProps;

export function <ContainerName>({ ...props }: <ContainerName>Props) {
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <Suspense fallback={<div>Loading...</div>}>
        <<ContainerName>Content {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

**index.ts — lazy, no Suspense**

Not valid — `lazy()` requires a `Suspense` boundary. If asked for this combination, clarify: either add Suspense, or don't lazy-load.

**\<ContainerName\>Content.tsx**

```tsx
export interface <ContainerName>ContentProps {
  // props passed in from the view (e.g. route params, render props)
}

export function <ContainerName>Content({ }: <ContainerName>ContentProps) {
  // Fetch data here using TanStack Query.
  // Render UI components here.
  // Accept child containers as render props, not imports.
  return null;
}
```

### Step 4 — Write the Test File

Create `__tests__/<ContainerName>.test.tsx`. Use Mock Service Worker to intercept requests — do not mock hooks or the fetch client.

```tsx
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { render, screen } from '@testing-library/react';
import { createWrapper } from '@/test/utils';
import { <ContainerName> } from '..';

const server = setupServer(
  // TODO: add happy-path handler(s) for this container's requests
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it('renders the expected content', async () => {
  render(<<ContainerName> {/* TODO: required props */} />, { wrapper: createWrapper() });
  // TODO: assert on rendered output
});

it('renders an error state when the request fails', async () => {
  server.use(
    // TODO: override with HttpResponse.error() for the relevant endpoint
  );
  render(<<ContainerName> {/* TODO: required props */} />, { wrapper: createWrapper() });
  expect(await screen.findByText('Something went wrong.')).toBeInTheDocument();
});
```

### Step 5 — Replace Placeholders

Substitute `<ContainerName>` with the actual name throughout all files.

Use the description of the container's purpose to:
- Add the correct props to `<ContainerName>ContentProps`
- Add a `useQuery` call if a specific query is already known
- Add a `render*` prop for any child containers the user mentioned

If the purpose is too vague, leave placeholders with comments noting what the user should fill in.

### Step 6 — Report

Tell the user:
- Files created and their paths
- Which lazy/Suspense variant was used and why (one sentence each if non-default)
- Anything left for them to fill in
