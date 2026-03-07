#!/usr/bin/env bash
# scaffold-app.sh — Boilerplate scaffold for the canonical frontend stack.
#
# Modes:
#   Standalone  Run from any directory without a turbo.json.
#               Creates a new self-contained Vite + React + TS project.
#
#   Monorepo    Run from a Turborepo root (turbo.json + pnpm-workspace.yaml present).
#               Creates apps/<name> with tsconfig extending packages/typescript-config
#               and a dependency on packages/ui.
#
# Does NOT install stack-specific packages — the scaffold-app skill handles that.
#
# Usage: bash scaffold-app.sh <project-name>

set -euo pipefail

# ── Validation ────────────────────────────────────────────────────────────────

if [ -z "${1:-}" ]; then
  echo "Usage: bash scaffold-app.sh <project-name>" >&2
  exit 1
fi

PROJECT_NAME="$1"

NODE_VERSION=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 18 ]; then
  echo "Error: Node.js 18 or higher is required." >&2
  exit 1
fi

if ! command -v pnpm &>/dev/null; then
  echo "Installing pnpm..."
  npm install -g pnpm
fi

# ── Monorepo detection ────────────────────────────────────────────────────────

IS_MONOREPO=false
SCOPE=""
if [ -f "turbo.json" ] && [ -f "pnpm-workspace.yaml" ]; then
  IS_MONOREPO=true
  SCOPE=$(node -e "console.log(require('./package.json').name)")
fi

# ── Validate target doesn't already exist ─────────────────────────────────────

if [ "$IS_MONOREPO" = true ]; then
  TARGET_DIR="apps/$PROJECT_NAME"
else
  TARGET_DIR="$PROJECT_NAME"
fi

if [ -d "$TARGET_DIR" ]; then
  echo "Error: directory '$TARGET_DIR' already exists." >&2
  exit 1
fi

# ── Scaffold Vite project ─────────────────────────────────────────────────────

if [ "$IS_MONOREPO" = true ]; then
  echo "→ Adding app to monorepo: apps/$PROJECT_NAME"
  pnpm create vite "apps/$PROJECT_NAME" --template react-ts
  cd "apps/$PROJECT_NAME"
else
  echo "→ Creating Vite project: $PROJECT_NAME"
  pnpm create vite "$PROJECT_NAME" --template react-ts
  cd "$PROJECT_NAME"
fi

# ── TypeScript ────────────────────────────────────────────────────────────────

echo "→ Configuring TypeScript"

if [ "$IS_MONOREPO" = true ]; then
  # Extend from the shared workspace typescript-config package
  cat > tsconfig.json <<EOF
{
  "extends": "@${SCOPE}/typescript-config/react",
  "compilerOptions": {
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
EOF

  cat > tsconfig.node.json <<EOF
{
  "extends": "@${SCOPE}/typescript-config/node",
  "compilerOptions": {
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["vite.config.ts", "vitest.config.ts"]
}
EOF

else
  # Standalone strict tsconfig
  cat > tsconfig.json <<'EOF'
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
EOF

  cat > tsconfig.app.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "moduleDetection": "force",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
EOF

  cat > tsconfig.node.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "moduleDetection": "force",
    "noEmit": true,
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["vite.config.ts", "vitest.config.ts"]
}
EOF
fi

# ── Update package.json ───────────────────────────────────────────────────────

if [ "$IS_MONOREPO" = true ]; then
  node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.name = '@${SCOPE}/${PROJECT_NAME}';
pkg.scripts = {
  ...pkg.scripts,
  typecheck: 'tsc --noEmit',
  test: 'vitest run',
  'test:watch': 'vitest',
};
pkg.dependencies = {
  ...pkg.dependencies,
  '@${SCOPE}/ui': 'workspace:*',
};
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
fi

# ── Folder structure ──────────────────────────────────────────────────────────

echo "→ Creating folder structure"

mkdir -p \
  src/routes \
  src/features \
  src/components/ui \
  src/hooks \
  src/lib \
  src/types \
  src/test

# ── Clean up Vite defaults ────────────────────────────────────────────────────

rm -f src/App.tsx src/App.css src/assets/react.svg public/vite.svg

# ── index.css ────────────────────────────────────────────────────────────────

if [ "$IS_MONOREPO" = true ]; then
  # Tailwind v4 — also scan packages/ui so shared component classes are included
  cat > src/index.css <<'EOF'
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
else
  # Tailwind v4 — standalone
  cat > src/index.css <<'EOF'
@import "tailwindcss";

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
fi

# ── .env stub ─────────────────────────────────────────────────────────────────

cat > .env.local <<'EOF'
VITE_API_URL=
EOF

cat > .env.example <<'EOF'
VITE_API_URL=http://localhost:3000
EOF

# ── .gitignore (standalone only — monorepo root owns .gitignore) ───────────────

if [ "$IS_MONOREPO" = false ]; then
  cat >> .gitignore <<'EOF'
.env.local
.env.*.local
EOF
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
if [ "$IS_MONOREPO" = true ]; then
  echo "✓ App scaffold complete: apps/$PROJECT_NAME"
  echo "  Next: the scaffold-app skill will install packages and configure the stack."
else
  echo "✓ Scaffold complete: $PROJECT_NAME"
  echo "  Next: the scaffold-app skill will install packages and configure the stack."
fi
