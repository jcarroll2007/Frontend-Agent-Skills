---
name: frontend-agent-skills
description: How to architect frontend features in React + TypeScript apps. Use when planning or building a new frontend feature — deciding structure, component breakdown, data fetching, state, and file placement.
---

# Frontend Agent Skills

Architecture guide for React + TypeScript applications. Covers component structure, data fetching, state management, and directory conventions using a canonical stack.

**Stack:** React + TypeScript (strict) + Vite + TanStack Router + TanStack Query + Tailwind CSS + shadcn/ui + Vitest.

## Rules

Read individual rule files for explanations and code examples. Rules are prefixed by category.

### Directory Structure

| Rule | Summary |
|------|---------|
| `directory-structure` | All apps use `contexts/` for business domain isolation — ask for domains before writing any files if they're unknown |

### Routing

| Rule | Summary |
|------|---------|
| `routing` | How routes are defined and organized using TanStack Router |

### Component Architecture

| Rule | Summary |
|------|---------|
| `views` | Page-level composition root — extracts route params, composes containers, owns no data fetching or business logic |
| `containers` | Three-layer pattern: Container (boundary + Suspense), Content (useSuspenseQuery + route params), Presentation (pure UI) |
| `containers-error-boundary` | Use `QueryErrorBoundary` from the ui package — handles chunk errors, 403s, and error reporting automatically |
