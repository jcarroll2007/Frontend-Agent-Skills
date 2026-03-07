# Skill: scaffold-monorepo

Scaffold a frontend monorepo using Turborepo + pnpm workspaces with two workspace roots: `apps/` and `packages/`.

Workspace layout:
- `apps/web` — full frontend app (React + TypeScript + Vite + TanStack Router + TanStack Query + Tailwind + shadcn/ui + Vitest)
- `packages/typescript-config` — shared tsconfig bases consumed by all workspaces
- `packages/ui` — shared component library; shadcn/ui components live here, consumed by apps

## Trigger

User runs `/scaffold-monorepo` or asks to scaffold / create a new frontend monorepo.

## Step 1 — Get the Project Name

If the user didn't provide a project name, ask for one before proceeding. All other steps are automatic.

The npm package scope will be derived from the name: `@<project-name>/`.

## Step 2 — Run the Scaffold Script

```bash
bash <path-to-skills>/scripts/scaffold-monorepo.sh <project-name>
cd <project-name>
```

The script creates the full folder structure, all config files, and workspace `package.json` stubs. It does not install any packages.

## Step 3 — Fetch Current Package Versions

Do not hardcode versions. Resolve at runtime:

```bash
npm show turbo version
npm show tsup version
npm show @tanstack/react-router version
npm show @tanstack/router-plugin version
npm show @tanstack/react-query version
npm show @tanstack/react-query-devtools version
npm show tailwindcss version
npm show zod version
npm show lucide-react version
```

Also resolve the current pnpm version for the `packageManager` field:

```bash
pnpm --version
```

## Step 4 — Set packageManager Field

Update the root `package.json` `packageManager` field with the resolved pnpm version:

```json
"packageManager": "pnpm@<resolved-version>"
```

## Step 5 — Install Root Dev Dependencies

From the repo root, install Turborepo:

```bash
pnpm add -D -w turbo@<resolved-version>
```

## Step 6 — Install packages/ui Dev Dependencies

```bash
cd packages/ui
pnpm add -D tsup@<resolved-version> typescript react react-dom @types/react @types/react-dom
pnpm add tailwind-merge clsx lucide-react@<resolved-version>
cd ../..
```

## Step 7 — Install apps/web Dependencies

```bash
cd apps/web
```

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

```bash
cd ../..
```

## Step 8 — Initialize shadcn/ui in apps/web

Fetch the current shadcn init command from https://ui.shadcn.com/docs/installation/vite and run it from `apps/web`. Use the `default` style, CSS variables on, no Tailwind prefix.

When prompted for the components path, set it to `../../packages/ui/src/components` so shadcn components land in the shared `packages/ui` package.

Install a baseline component set into `packages/ui`:

```bash
cd apps/web
pnpm dlx shadcn@latest add button card input label badge separator
cd ../..
```

## Step 9 — Configure apps/web

### apps/web/vite.config.ts

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [TanStackRouterVite(), react(), tailwindcss()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
})
```

### apps/web/src/index.css

Configure Tailwind to also scan `packages/ui` for class names:

```css
@import "tailwindcss";

@source "../../packages/ui/src/**/*.{ts,tsx}";

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 0 0% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 0 0% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 0 0% 3.9%;
    --primary: 0 0% 9%;
    --primary-foreground: 0 0% 98%;
    --secondary: 0 0% 96.1%;
    --secondary-foreground: 0 0% 9%;
    --muted: 0 0% 96.1%;
    --muted-foreground: 0 0% 45.1%;
    --accent: 0 0% 96.1%;
    --accent-foreground: 0 0% 9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 89.8%;
    --input: 0 0% 89.8%;
    --ring: 0 0% 3.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 0 0% 3.9%;
    --foreground: 0 0% 98%;
    --card: 0 0% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 0 0% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 0 0% 9%;
    --secondary: 0 0% 14.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 0 0% 14.9%;
    --muted-foreground: 0 0% 63.9%;
    --accent: 0 0% 14.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 14.9%;
    --input: 0 0% 14.9%;
    --ring: 0 0% 83.1%;
  }
}

@layer base {
  * { @apply border-border; }
  body { @apply bg-background text-foreground; }
}
```

### apps/web/src/routes/__root.tsx

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

### apps/web/src/routes/index.tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: Index,
})

function Index() {
  return <div className="p-8"><h1 className="text-2xl font-semibold">Ready.</h1></div>
}
```

### apps/web/src/main.tsx

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

### apps/web/vitest.config.ts

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

Create `apps/web/src/test/setup.ts`:

```ts
import '@testing-library/jest-dom'
```

## Step 10 — Verify

Run from the repo root:

```bash
turbo build
```

Build must pass for all workspaces before the skill is complete. Fix any errors — do not report success until `turbo build` exits cleanly.

## Step 11 — Report

Tell the user:
- Repo location and workspace layout
- `pnpm dev --filter web` to start the dev server
- `turbo test` to run all tests
- `turbo build` to build all workspaces
- Where to add new apps (`apps/`) and shared packages (`packages/`)
- Remind them that shadcn components go in `packages/ui/src/components` and are re-exported from `packages/ui/src/index.ts`
