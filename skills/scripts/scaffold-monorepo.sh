#!/usr/bin/env bash
# scaffold-monorepo.sh — Deterministic boilerplate for a Turborepo + pnpm monorepo.
# Creates the full folder structure and all config files.
# Does NOT install packages — the scaffold-monorepo skill handles that.
#
# Usage: bash scaffold-monorepo.sh <project-name>

set -euo pipefail

# ── Validation ────────────────────────────────────────────────────────────────

if [ -z "${1:-}" ]; then
  echo "Usage: bash scaffold-monorepo.sh <project-name>" >&2
  exit 1
fi

PROJECT_NAME="$1"
SCOPE="@${PROJECT_NAME}"

if [ -d "$PROJECT_NAME" ]; then
  echo "Error: directory '$PROJECT_NAME' already exists." >&2
  exit 1
fi

NODE_VERSION=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 18 ]; then
  echo "Error: Node.js 18 or higher is required." >&2
  exit 1
fi

if ! command -v pnpm &>/dev/null; then
  echo "Installing pnpm..."
  npm install -g pnpm
fi

# ── Root structure ─────────────────────────────────────────────────────────────

echo "→ Creating monorepo: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"/{apps,packages}
cd "$PROJECT_NAME"

# ── Root package.json ─────────────────────────────────────────────────────────

cat > package.json <<EOF
{
  "name": "${PROJECT_NAME}",
  "private": true,
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "test": "turbo test",
    "typecheck": "turbo typecheck",
    "lint": "turbo lint"
  },
  "devDependencies": {}
}
EOF

# ── pnpm workspace config ─────────────────────────────────────────────────────

cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

# ── Turborepo config ──────────────────────────────────────────────────────────

cat > turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "typecheck": {
      "dependsOn": ["^build"]
    },
    "lint": {}
  }
}
EOF

# ── Root .gitignore ───────────────────────────────────────────────────────────

cat > .gitignore <<'EOF'
# Dependencies
node_modules

# Build outputs
dist
.next
out

# Turbo
.turbo

# Environment
.env
.env.local
.env.*.local

# Editor
.DS_Store
*.pem
EOF

# ── packages/typescript-config ────────────────────────────────────────────────

echo "→ Creating packages/typescript-config"

mkdir -p packages/typescript-config

cat > packages/typescript-config/package.json <<EOF
{
  "name": "${SCOPE}/typescript-config",
  "version": "0.0.0",
  "private": true,
  "exports": {
    "./base": "./base.json",
    "./react": "./react.json",
    "./node": "./node.json"
  }
}
EOF

cat > packages/typescript-config/base.json <<'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "verbatimModuleSyntax": true,
    "moduleDetection": "force",
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noEmit": true
  }
}
EOF

cat > packages/typescript-config/react.json <<'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "allowImportingTsExtensions": true,
    "isolatedModules": true
  }
}
EOF

cat > packages/typescript-config/node.json <<'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "module": "CommonJS",
    "moduleResolution": "node"
  }
}
EOF

# ── packages/ui ───────────────────────────────────────────────────────────────

echo "→ Creating packages/ui"

mkdir -p packages/ui/src/components

cat > packages/ui/package.json <<EOF
{
  "name": "${SCOPE}/ui",
  "version": "0.0.0",
  "private": true,
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.cjs",
      "types": "./dist/index.d.ts"
    }
  },
  "main": "./dist/index.cjs",
  "module": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "typecheck": "tsc --noEmit"
  },
  "peerDependencies": {
    "react": "*",
    "react-dom": "*"
  },
  "devDependencies": {}
}
EOF

cat > packages/ui/tsconfig.json <<EOF
{
  "extends": "${SCOPE}/typescript-config/react",
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
EOF

cat > packages/ui/tsup.config.ts <<'EOF'
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm', 'cjs'],
  dts: true,
  clean: true,
  external: ['react', 'react-dom'],
  sourcemap: true,
})
EOF

# Starter index — re-export everything from components/
cat > packages/ui/src/index.ts <<'EOF'
// Re-export all shared UI components.
// Add exports here as components are added to src/components/.
// Example: export { Button } from './components/button'
EOF

# ── apps/web ──────────────────────────────────────────────────────────────────

echo "→ Creating apps/web"

pnpm create vite apps/web --template react-ts

# Replace tsconfig files to extend from shared package
cat > apps/web/tsconfig.json <<EOF
{
  "extends": "${SCOPE}/typescript-config/react",
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
EOF

# Node tsconfig for vite.config.ts / vitest.config.ts
cat > apps/web/tsconfig.node.json <<EOF
{
  "extends": "${SCOPE}/typescript-config/node",
  "compilerOptions": {
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["vite.config.ts", "vitest.config.ts"]
}
EOF

# Update apps/web package.json — add workspace ui dep, typecheck script
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('apps/web/package.json', 'utf8'));
pkg.name = '${SCOPE}/web';
pkg.scripts = {
  ...pkg.scripts,
  typecheck: 'tsc --noEmit',
  test: 'vitest run',
  'test:watch': 'vitest',
};
pkg.dependencies = {
  ...pkg.dependencies,
  '${SCOPE}/ui': 'workspace:*',
};
fs.writeFileSync('apps/web/package.json', JSON.stringify(pkg, null, 2) + '\n');
"

# Folder structure
mkdir -p \
  apps/web/src/routes \
  apps/web/src/features \
  apps/web/src/hooks \
  apps/web/src/lib \
  apps/web/src/types \
  apps/web/src/test

# Clean Vite defaults
rm -f apps/web/src/App.tsx apps/web/src/App.css apps/web/src/assets/react.svg apps/web/public/vite.svg

# index.css — Tailwind v4 syntax, scans packages/ui
cat > apps/web/src/index.css <<'EOF'
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
    --border: 0 0% 14.9%;
    --input: 0 0% 14.9%;
    --ring: 0 0% 83.1%;
  }
}

@layer base {
  * { @apply border-border; }
  body { @apply bg-background text-foreground; }
}
EOF

# lib stubs
cat > apps/web/src/lib/queryKeys.ts <<'EOF'
// Central registry for all TanStack Query keys.
// Pattern: export const ENTITY_KEYS = { all: ['entity'] as const, ... }
EOF

cat > apps/web/src/lib/api.ts <<'EOF'
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
EOF

# test setup stub
cat > apps/web/src/test/setup.ts <<'EOF'
import '@testing-library/jest-dom'
EOF

# .env stubs
cat > apps/web/.env.local <<'EOF'
VITE_API_URL=
EOF

cat > apps/web/.env.example <<'EOF'
VITE_API_URL=http://localhost:3000
EOF

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "✓ Monorepo scaffold complete: $PROJECT_NAME"
echo ""
echo "  Workspaces:"
echo "    apps/web                     — frontend app"
echo "    packages/ui                  — shared component library"
echo "    packages/typescript-config   — shared tsconfig bases"
echo ""
echo "  Next: the scaffold-monorepo skill will install packages and verify the build."
