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
    "lint": "turbo lint",
    "format": "prettier --write .",
    "format:check": "prettier --check ."
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

# ── Prettier ──────────────────────────────────────────────────────────────────

cat > .prettierrc <<'EOF'
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
EOF

cat > .prettierignore <<'EOF'
node_modules
dist
.next
out
.turbo
pnpm-lock.yaml
routeTree.gen.ts
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
    "typecheck": "tsc --noEmit",
    "lint": "eslint ."
  },
  "peerDependencies": {
    "react": "*",
    "react-dom": "*"
  },
  "devDependencies": {
    "${SCOPE}/eslint-config": "workspace:*"
  }
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

cat > packages/ui/eslint.config.js <<EOF
// @ts-check
import reactConfig from '${SCOPE}/eslint-config/react'

/** @type {import('eslint').Linter.Config[]} */
export default [
  { ignores: ['dist/**'] },
  ...reactConfig,
]
EOF

# ── packages/eslint-config ────────────────────────────────────────────────────

echo "→ Creating packages/eslint-config"

mkdir -p packages/eslint-config

cat > packages/eslint-config/package.json <<EOF
{
  "name": "${SCOPE}/eslint-config",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    "./base": "./base.js",
    "./react": "./react.js"
  },
  "dependencies": {}
}
EOF

cat > packages/eslint-config/base.js <<'EOF'
// @ts-check
import js from '@eslint/js'
import tseslint from 'typescript-eslint'

/** @type {import('typescript-eslint').ConfigArray} */
export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
]
EOF

cat > packages/eslint-config/react.js <<'EOF'
// @ts-check
import reactPlugin from 'eslint-plugin-react'
import hooksPlugin from 'eslint-plugin-react-hooks'
import prettierConfig from 'eslint-config-prettier'
import baseConfig from './base.js'

/** @type {import('typescript-eslint').ConfigArray} */
export default [
  ...baseConfig,
  {
    ...reactPlugin.configs.flat.recommended,
    settings: { react: { version: 'detect' } },
  },
  {
    plugins: { 'react-hooks': hooksPlugin },
    rules: hooksPlugin.configs.recommended.rules,
  },
  prettierConfig,
]
EOF

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "✓ Monorepo scaffold complete: $PROJECT_NAME"
echo ""
echo "  Packages:"
echo "    packages/ui                  — shared component library"
echo "    packages/typescript-config   — shared tsconfig bases"
echo "    packages/eslint-config       — shared ESLint configs"
echo ""
echo "  Next: run scaffold-app.sh from the monorepo root to add your first app."
