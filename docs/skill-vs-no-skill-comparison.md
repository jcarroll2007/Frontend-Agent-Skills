# Skill vs No-Skill: Side-by-Side Prototype Comparison

**Date:** 2026-03-27
**Method:** Same prompt, same app (Linear-style epic/task manager), built twice with Claude Code — once with the frontend-agent-skills skill installed, once without.

---

## TL;DR

The skill didn't make the app look better — both produce a clean, dark-themed UI. The skill made the app **structurally better**: domain-bounded modules, container/presenter separation, centralized design tokens, error boundaries, and typed routing. The no-skill version is a demo. The skill version is a foundation you can ship from.

---

## Stack Comparison

| | No-Skill | Skill |
|---|---|---|
| **React** | 19.0.0 | 19.2.4 |
| **TypeScript** | 5.7.2 | 5.9.3 |
| **Vite** | 6.2.0 | 8.0.1 |
| **Routing** | React Router DOM 7 (string-based) | TanStack Router 1.168 (typed) |
| **Error Handling** | None | react-error-boundary + QueryErrorBoundary |
| **Design Tokens** | Hardcoded Tailwind values | CSS custom properties via `@theme` |
| **Path Aliases** | No | `@/*` → `./src/*` |
| **TS Strictness** | `strict: true` | `strict: true` + `noUnusedLocals`, `noUnusedParameters` |

The skill version aligns with the recommended stack (TanStack Router + Query, Tailwind with tokens, strict TypeScript). The no-skill version defaults to React Router and raw utility classes.

---

## Directory Structure

### No-Skill (22 files)

```
src/
├── api/
│   ├── epics.ts
│   ├── store.ts
│   └── tasks.ts
├── components/
│   ├── CreateEpicModal.tsx
│   ├── CreateTaskModal.tsx
│   ├── EditTaskModal.tsx
│   ├── EpicHeader.tsx
│   ├── Layout.tsx
│   ├── Modal.tsx
│   ├── PriorityBadge.tsx
│   ├── Sidebar.tsx
│   ├── StatusIcon.tsx
│   ├── TaskList.tsx
│   └── TaskRow.tsx
├── hooks/
│   ├── useEpics.ts
│   └── useTasks.ts
├── pages/
│   ├── AllTasksPage.tsx
│   └── EpicPage.tsx
├── App.tsx
├── index.css
├── main.tsx
├── types.ts
└── vite-env.d.ts
```

### Skill (46 files)

```
src/
├── components/                        # Shared UI primitives
│   ├── empty-state.tsx
│   ├── loading-view.tsx
│   ├── priority-badge.tsx
│   ├── query-error-boundary.tsx
│   └── status-dot.tsx
├── containers/                        # Suspense + ErrorBoundary wrappers
│   ├── EpicDetail/
│   │   ├── EpicDetailContent.tsx
│   │   ├── index.tsx
│   │   └── types.ts
│   ├── EpicSidebar/
│   │   ├── EpicSidebarContent.tsx
│   │   └── index.tsx
│   └── TaskList/
│       ├── TaskListContent.tsx
│       ├── index.tsx
│       └── types.ts
├── contexts/                          # Domain-bounded feature modules
│   ├── epics/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── types/
│   │   └── index.ts                   # Public API + dependency docs
│   └── tasks/
│       ├── components/
│       ├── containers/
│       ├── hooks/
│       ├── types/
│       └── index.ts
├── lib/
│   └── fake-db.ts
├── router/                            # Typed route definitions
│   ├── index.tsx
│   ├── root.tsx
│   └── tree.tsx
├── views/                             # File-based route views
│   └── epics/
│       ├── $epicId/
│       │   ├── tasks/$taskId/
│       │   │   └── index.tsx
│       │   └── index.tsx
│       └── index.tsx
├── App.tsx
├── index.css
└── main.tsx
```

### What changed

- **22 files → 46 files.** More files, but each is smaller and single-purpose.
- **Flat → hierarchical.** No-skill puts 11 components in one folder. Skill organizes by domain (`contexts/epics`, `contexts/tasks`), each with its own components, hooks, and types.
- **No containers → container/presenter split.** Skill adds a `containers/` layer wrapping features with Suspense and error boundaries — matching the `containers` rule.
- **String routes → file-based views.** Skill mirrors URL structure in `views/epics/$epicId/tasks/$taskId/` — matching the `views` and `routing` rules.
- **Monolith hooks → single-responsibility hooks.** One `useEpics.ts` with 4 exports vs `use-create-epic.ts`, `use-delete-epic.ts`, `use-epic.ts`, etc.

---

## Architecture

### No-Skill

Flat, conventional React structure. `components/` holds everything from layout to modals to badges. Pages fetch data directly via hooks. No domain boundaries, no error handling layer, no container abstraction.

Data flow:
```
Page → useQuery hook → API function → in-memory store
```

### Skill

Feature-driven architecture with domain-bounded contexts. Each context (`epics/`, `tasks/`) owns its components, hooks, types, and exposes a public `index.ts` with explicit dependency comments. Containers wrap async operations with `QueryErrorBoundary` + `Suspense`.

Data flow:
```
View → Container (ErrorBoundary + Suspense) → Content (useSuspenseQuery) → Presenter (pure UI)
```

This directly follows the `containers`, `containers-error-boundary`, and `directory-structure` rules.

---

## Design System

### No-Skill

Colors are hardcoded Tailwind values scattered across components:
- `bg-[#0a0a0f]`, `bg-[#1a1a2e]`, `text-gray-400`, `violet-600`
- Consistent in practice, but implicit — no single source of truth
- Changing the theme means find-and-replace across 13 files

### Skill

Centralized design tokens via CSS custom properties in `index.css` using Tailwind 4's `@theme` directive:
- Semantic names: `--color-background`, `--color-surface`, `--color-accent`, `--color-priority-urgent`, `--color-status-in_progress`
- Components reference tokens: `bg-surface-hover`, `text-text-primary`
- Changing the theme means editing one file

---

## Error Handling

### No-Skill

None. No error boundaries, no loading fallbacks, no recovery UI. If an API call fails, the user sees a blank screen or a React error overlay.

### Skill

- `QueryErrorBoundary` wraps all async components
- `useSuspenseQuery` integrates with React Suspense for loading states
- `LoadingView` and `EmptyState` components for non-error edge cases
- "Try again" recovery button on errors

This directly follows the `containers-error-boundary` rule.

---

## What the Skill Improved

| Dimension | No-Skill | Skill | Rule Applied |
|---|---|---|---|
| Domain isolation | Flat folder | `contexts/` per domain | `directory-structure` |
| Container pattern | None | Container → Content → Presenter | `containers` |
| Error boundaries | None | QueryErrorBoundary + Suspense | `containers-error-boundary` |
| Routing | React Router (string) | TanStack Router (typed) | `routing` |
| View composition | Pages own everything | Views compose containers, own no logic | `views` |
| Design tokens | Hardcoded | Centralized CSS custom properties | — |
| Hook granularity | 1 file per domain | 1 file per operation | — |

---

## What the Skill Did Not Change

- **Visual quality.** Both apps look good. Clean dark theme, consistent spacing, proper hover/focus states. You cannot tell which is which from a screenshot.
- **Responsiveness.** Both are desktop-first with no mobile breakpoints. Neither collapses the sidebar on small screens.
- **Accessibility.** Both have similar baselines (semantic HTML, form labels, keyboard dismiss). Both are missing focus traps, `role="dialog"`, and comprehensive `aria-label` coverage.

---

## Conclusion

The frontend-agent-skills skill produces code that follows the documented architecture rules — domain boundaries, container patterns, error handling, typed routing, and centralized tokens. The no-skill version produces functional code with reasonable defaults but none of these structural patterns.

The skill's value is not in making the UI look better. It's in making the codebase maintainable, resilient, and aligned with a defined architecture from the first commit.
