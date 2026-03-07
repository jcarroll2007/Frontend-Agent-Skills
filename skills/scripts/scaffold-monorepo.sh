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

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "✓ Monorepo scaffold complete: $PROJECT_NAME"
echo ""
echo "  Packages:"
echo "    packages/ui                  — shared component library"
echo "    packages/typescript-config   — shared tsconfig bases"
echo ""
echo "  Next: run scaffold-app.sh from the monorepo root to add your first app."
