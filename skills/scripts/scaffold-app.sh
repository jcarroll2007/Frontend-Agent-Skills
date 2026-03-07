#!/usr/bin/env bash
# scaffold-app.sh — Boilerplate scaffold for the canonical frontend stack.
# Creates a Vite + React + TypeScript project with strict config and folder structure.
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

# ── Scaffold Vite project ─────────────────────────────────────────────────────

echo "→ Creating Vite project: $PROJECT_NAME"
pnpm create vite "$PROJECT_NAME" --template react-ts
cd "$PROJECT_NAME"

# ── TypeScript — strict config ────────────────────────────────────────────────

echo "→ Configuring TypeScript"

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

cat > src/index.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

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
EOF

# ── .env stub ─────────────────────────────────────────────────────────────────

cat > .env.local <<'EOF'
VITE_API_URL=
EOF

cat > .env.example <<'EOF'
VITE_API_URL=http://localhost:3000
EOF

# ── .gitignore ────────────────────────────────────────────────────────────────

cat >> .gitignore <<'EOF'
.env.local
.env.*.local
EOF

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "✓ Scaffold complete: $PROJECT_NAME"
echo "  Next: the scaffold-app skill will install packages and configure the stack."
